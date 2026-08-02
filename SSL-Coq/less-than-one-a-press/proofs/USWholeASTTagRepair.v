From Coq Require Import List ZArith.
From compcert Require Import AST Clight Coqlib Ctypes Errors Maps Smallstep.
From LessThanOneAPress.Proofs Require Import
  NormalizedClightPrograms CleanedClightPrograms
  CompositeLayoutRefinement CompositeOfficialLinkBridge.

Import ListNotations.

(** A whole-Clight-AST alpha-renaming for one composite tag.  Unlike the
    layout-only construction in [CompositeLayoutRefinement], this operation
    visits every type annotation in expressions, statements, function
    declarations and definitions, and global-variable declarations. *)

Definition rename_typed_ident_tag (old fresh : ident)
    (entry : ident * type) : ident * type :=
  (fst entry, rename_type_tag old fresh (snd entry)).

Fixpoint rename_expr_tag (old fresh : ident) (a : expr) : expr :=
  match a with
  | Econst_int i ty => Econst_int i (rename_type_tag old fresh ty)
  | Econst_float f ty => Econst_float f (rename_type_tag old fresh ty)
  | Econst_single f ty => Econst_single f (rename_type_tag old fresh ty)
  | Econst_long i ty => Econst_long i (rename_type_tag old fresh ty)
  | Evar id ty => Evar id (rename_type_tag old fresh ty)
  | Etempvar id ty => Etempvar id (rename_type_tag old fresh ty)
  | Ederef inner ty =>
      Ederef (rename_expr_tag old fresh inner)
        (rename_type_tag old fresh ty)
  | Eaddrof inner ty =>
      Eaddrof (rename_expr_tag old fresh inner)
        (rename_type_tag old fresh ty)
  | Eunop op inner ty =>
      Eunop op (rename_expr_tag old fresh inner)
        (rename_type_tag old fresh ty)
  | Ebinop op lhs rhs ty =>
      Ebinop op (rename_expr_tag old fresh lhs)
        (rename_expr_tag old fresh rhs) (rename_type_tag old fresh ty)
  | Ecast inner ty =>
      Ecast (rename_expr_tag old fresh inner)
        (rename_type_tag old fresh ty)
  | Efield inner field ty =>
      Efield (rename_expr_tag old fresh inner) field
        (rename_type_tag old fresh ty)
  | Esizeof measured ty =>
      Esizeof (rename_type_tag old fresh measured)
        (rename_type_tag old fresh ty)
  | Ealignof measured ty =>
      Ealignof (rename_type_tag old fresh measured)
        (rename_type_tag old fresh ty)
  end.

Fixpoint rename_statement_tag (old fresh : ident) (s : statement)
    : statement :=
  match s with
  | Sskip => Sskip
  | Sassign lhs rhs =>
      Sassign (rename_expr_tag old fresh lhs)
        (rename_expr_tag old fresh rhs)
  | Sset id value => Sset id (rename_expr_tag old fresh value)
  | Scall result function arguments =>
      Scall result (rename_expr_tag old fresh function)
        (map (rename_expr_tag old fresh) arguments)
  | Sbuiltin result ef types arguments =>
      Sbuiltin result ef (map (rename_type_tag old fresh) types)
        (map (rename_expr_tag old fresh) arguments)
  | Ssequence first second =>
      Ssequence (rename_statement_tag old fresh first)
        (rename_statement_tag old fresh second)
  | Sifthenelse condition yes no =>
      Sifthenelse (rename_expr_tag old fresh condition)
        (rename_statement_tag old fresh yes)
        (rename_statement_tag old fresh no)
  | Sloop body increment =>
      Sloop (rename_statement_tag old fresh body)
        (rename_statement_tag old fresh increment)
  | Sbreak => Sbreak
  | Scontinue => Scontinue
  | Sreturn result =>
      Sreturn (option_map (rename_expr_tag old fresh) result)
  | Sswitch value cases =>
      Sswitch (rename_expr_tag old fresh value)
        (rename_labeled_statements_tag old fresh cases)
  | Slabel label body =>
      Slabel label (rename_statement_tag old fresh body)
  | Sgoto label => Sgoto label
  end
with rename_labeled_statements_tag (old fresh : ident)
    (cases : labeled_statements) : labeled_statements :=
  match cases with
  | LSnil => LSnil
  | LScons label body rest =>
      LScons label (rename_statement_tag old fresh body)
        (rename_labeled_statements_tag old fresh rest)
  end.

Definition rename_function_tag (old fresh : ident)
    (f : Clight.function) : Clight.function :=
  {| fn_return := rename_type_tag old fresh (fn_return f);
     fn_callconv := fn_callconv f;
     fn_params := map (rename_typed_ident_tag old fresh) (fn_params f);
     fn_vars := map (rename_typed_ident_tag old fresh) (fn_vars f);
     fn_temps := map (rename_typed_ident_tag old fresh) (fn_temps f);
     fn_body := rename_statement_tag old fresh (fn_body f) |}.

Definition rename_fundef_tag (old fresh : ident)
    (fd : Clight.fundef) : Clight.fundef :=
  match fd with
  | Internal f => Internal (rename_function_tag old fresh f)
  | External ef arguments result convention =>
      External ef (map (rename_type_tag old fresh) arguments)
        (rename_type_tag old fresh result) convention
  end.

Definition rename_globvar_tag (old fresh : ident) (v : globvar type)
    : globvar type :=
  {| gvar_info := rename_type_tag old fresh (gvar_info v);
     gvar_init := gvar_init v;
     gvar_readonly := gvar_readonly v;
     gvar_volatile := gvar_volatile v |}.

Definition rename_globdef_tag (old fresh : ident)
    (definition : globdef Clight.fundef type)
    : globdef Clight.fundef type :=
  match definition with
  | Gfun fd => Gfun (rename_fundef_tag old fresh fd)
  | Gvar v => Gvar (rename_globvar_tag old fresh v)
  end.

(** [__540] is the viewport wrapper tag.  It does not occur in the unrelated
    game-initialization Gfx payload.  Consequently it is a source-backed
    discriminator for the selected definitions that must receive the
    [__538]-to-fresh rewrite. *)
Definition us_selected_definition_needs_viewport_repair
    (entry : ident * globdef Clight.fundef type) : bool :=
  globdef_mentions_any [us_area.__540] (snd entry).

Definition repair_us_selected_global_definition
    (entry : ident * globdef Clight.fundef type)
    : ident * globdef Clight.fundef type :=
  if us_selected_definition_needs_viewport_repair entry
  then (fst entry,
        rename_globdef_tag us_area.__538 us_area_viewport_fresh_tag
          (snd entry))
  else entry.

Definition us_viewport_repaired_global_definitions :=
  map repair_us_selected_global_definition us_normalized_global_definitions.

(** Keep the selected game-initialization [__538], rewrite only definitions
    that mention the viewport wrapper, and prepend the fresh viewport payload
    definition before the wrapper is laid out. *)
Definition repair_us_normalized_composite
    (definition : composite_definition) : composite_definition :=
  if peq (composite_ident definition) us_area.__540
  then rename_composite_type_tag
         us_area.__538 us_area_viewport_fresh_tag definition
  else definition.

Definition us_area_viewport_payload_composite : composite_definition :=
  rename_composite_type_tag us_area.__538 us_area_viewport_fresh_tag
    (Composite us_area.__538 Struct
      [Member_plain us_area._vscale
         (Tarray (Tint I16 Signed noattr) 4 noattr);
       Member_plain us_area._vtrans
         (Tarray (Tint I16 Signed noattr) 4 noattr)] noattr).

Definition us_viewport_repaired_composites : list composite_definition :=
  us_area_viewport_payload_composite ::
  map repair_us_normalized_composite us_normalized_composites.

Definition us_viewport_repaired_composite_env : composite_env :=
  normalized_composite_env us_viewport_repaired_composites.

Definition us_viewport_repaired_program_result : res Clight.program :=
  Ctypes.make_program us_viewport_repaired_composites
    us_viewport_repaired_global_definitions
    (prog_public us_official_cleaned_slice)
    (prog_main us_official_cleaned_slice).

Definition us_viewport_repaired_program : Clight.program :=
  match us_viewport_repaired_program_result with
  | OK program => program
  | Error _ => us_official_cleaned_slice
  end.

Definition us_viewport_repaired_program_builds : bool :=
  match us_viewport_repaired_program_result with
  | OK _ => true
  | Error _ => false
  end.

(** Basic algebraic facts establish that this really is an alpha-renaming:
    term/global identifiers, initializer bytes, calling conventions, and the
    control-flow graph are unchanged. *)

Lemma typeof_rename_expr_tag :
  forall old fresh a,
    typeof (rename_expr_tag old fresh a) =
      rename_type_tag old fresh (typeof a).
Proof. intros old fresh []; reflexivity. Qed.

Lemma rename_typed_ident_tag_preserves_identifier :
  forall old fresh entry,
    fst (rename_typed_ident_tag old fresh entry) = fst entry.
Proof. intros old fresh []; reflexivity. Qed.

Lemma rename_globdef_tag_preserves_initializer :
  forall old fresh v,
    gvar_init (rename_globvar_tag old fresh v) = gvar_init v.
Proof. reflexivity. Qed.

Lemma repair_us_selected_global_definition_preserves_identifier :
  forall entry,
    fst (repair_us_selected_global_definition entry) = fst entry.
Proof.
  intros [id definition]. unfold repair_us_selected_global_definition.
  destruct (us_selected_definition_needs_viewport_repair (id, definition));
    reflexivity.
Qed.

Lemma map_fst_repair_us_selected_global_definitions :
  map fst us_viewport_repaired_global_definitions =
    map fst us_normalized_global_definitions.
Proof.
  unfold us_viewport_repaired_global_definitions.
  induction us_normalized_global_definitions as [| entry rest IH]; cbn; auto.
  rewrite repair_us_selected_global_definition_preserves_identifier, IH.
  reflexivity.
Qed.

Lemma rename_type_tag_same :
  forall old ty, rename_type_tag old old ty = ty.
Proof.
  intros old. fix IH 1. intro ty. destruct ty; cbn; try reflexivity.
  - now rewrite IH.
  - now rewrite IH.
  - assert (Hparams:
        map (rename_type_tag old old) l = l).
    { induction l as [| parameter rest IHrest]; cbn; auto.
      rewrite IH, IHrest. reflexivity. }
    now rewrite Hparams, IH.
  - unfold rename_tag_ident. destruct (peq i old); subst; reflexivity.
  - unfold rename_tag_ident. destruct (peq i old); subst; reflexivity.
Qed.

Lemma rename_type_tag_fresh_idempotent :
  forall old fresh ty,
    old <> fresh ->
    rename_type_tag old fresh (rename_type_tag old fresh ty) =
      rename_type_tag old fresh ty.
Proof.
  intros old fresh. fix IH 1. intros ty Hneq. destruct ty; cbn;
    try reflexivity.
  - now rewrite IH by exact Hneq.
  - now rewrite IH by exact Hneq.
  - assert (Hparams:
        map (rename_type_tag old fresh)
          (map (rename_type_tag old fresh) l) =
        map (rename_type_tag old fresh) l).
    { induction l as [| parameter rest IHrest]; cbn; auto.
      rewrite IH by exact Hneq. now rewrite IHrest. }
    rewrite Hparams. now rewrite IH by exact Hneq.
  - unfold rename_tag_ident.
    destruct (peq i old) as [-> | Hnotold].
    + destruct (peq fresh old) as [Heq |]; [symmetry in Heq; contradiction|].
      reflexivity.
    + now destruct (peq i old).
  - unfold rename_tag_ident.
    destruct (peq i old) as [-> | Hnotold].
    + destruct (peq fresh old) as [Heq |]; [symmetry in Heq; contradiction|].
      reflexivity.
    + now destruct (peq i old).
Qed.

(** Renaming does not alter labels, so label lookup and continuation
    construction commute exactly. *)
Fixpoint rename_cont_tag (old fresh : ident) (k : cont) : cont :=
  match k with
  | Kstop => Kstop
  | Kseq s rest =>
      Kseq (rename_statement_tag old fresh s)
        (rename_cont_tag old fresh rest)
  | Kloop1 first second rest =>
      Kloop1 (rename_statement_tag old fresh first)
        (rename_statement_tag old fresh second)
        (rename_cont_tag old fresh rest)
  | Kloop2 first second rest =>
      Kloop2 (rename_statement_tag old fresh first)
        (rename_statement_tag old fresh second)
        (rename_cont_tag old fresh rest)
  | Kswitch rest => Kswitch (rename_cont_tag old fresh rest)
  | Kcall result f e le rest =>
      Kcall result (rename_function_tag old fresh f) e le
        (rename_cont_tag old fresh rest)
  end.

Lemma call_cont_rename_cont_tag :
  forall old fresh k,
    call_cont (rename_cont_tag old fresh k) =
      rename_cont_tag old fresh (call_cont k).
Proof. intros old fresh k; induction k; cbn; auto. Qed.

Definition rename_state_tag (old fresh : ident) (st : Clight.state)
    : Clight.state :=
  match st with
  | State f s k e le m =>
      State (rename_function_tag old fresh f)
        (rename_statement_tag old fresh s)
        (rename_cont_tag old fresh k) e le m
  | Callstate fd arguments k m =>
      Callstate (rename_fundef_tag old fresh fd) arguments
        (rename_cont_tag old fresh k) m
  | Returnstate result k m =>
      Returnstate result (rename_cont_tag old fresh k) m
  end.

(** Concrete receipts for the repaired linked header and program. *)

Definition us_selected_viewport_definition_ids : list ident :=
  globals_mentioning_any [us_area.__540] us_normalized_global_definitions.

(** Runtime states contain function values rather than their global names.
    The same wrapper-tag discriminator therefore selects exactly the runtime
    syntax requiring repair, without rewriting legitimate Gfx uses of
    [__538]. *)
Definition repair_us_function (f : Clight.function) : Clight.function :=
  if function_mentions_any [us_area.__540] f
  then rename_function_tag us_area.__538 us_area_viewport_fresh_tag f
  else f.

Definition repair_us_fundef (fd : Clight.fundef) : Clight.fundef :=
  if fundef_mentions_any [us_area.__540] fd
  then rename_fundef_tag us_area.__538 us_area_viewport_fresh_tag fd
  else fd.

Definition repair_us_statement (s : statement) : statement :=
  if statement_mentions_any [us_area.__540] s
  then rename_statement_tag us_area.__538 us_area_viewport_fresh_tag s
  else s.

Fixpoint repair_us_cont (k : cont) : cont :=
  match k with
  | Kstop => Kstop
  | Kseq s rest => Kseq (repair_us_statement s) (repair_us_cont rest)
  | Kloop1 first second rest =>
      Kloop1 (repair_us_statement first) (repair_us_statement second)
        (repair_us_cont rest)
  | Kloop2 first second rest =>
      Kloop2 (repair_us_statement first) (repair_us_statement second)
        (repair_us_cont rest)
  | Kswitch rest => Kswitch (repair_us_cont rest)
  | Kcall result f e le rest =>
      Kcall result (repair_us_function f) e le (repair_us_cont rest)
  end.

Definition repair_us_state (st : Clight.state) : Clight.state :=
  match st with
  | State f s k e le m =>
      State (repair_us_function f) (repair_us_statement s)
        (repair_us_cont k) e le m
  | Callstate fd arguments k m =>
      Callstate (repair_us_fundef fd) arguments (repair_us_cont k) m
  | Returnstate result k m =>
      Returnstate result (repair_us_cont k) m
  end.

(** The remaining semantic boundary is stated constructively: it asks for a
    forward simulation between two concrete CompCert semantics.  No premise
    assumes target-star unreachability or any gameplay conclusion. *)
Definition USViewportWholeASTExecutionSimulationObligation : Prop :=
  exists match_states : Clight.state -> Clight.state -> Prop,
    (forall source,
      match_states source
        (repair_us_state source)) /\
    (forall source trace source',
      Clight.step2 (Clight.globalenv us_official_cleaned_slice)
        source trace source' ->
      forall target,
        match_states source target ->
        exists target',
          Smallstep.plus
            (fun (_ : unit) =>
              Clight.step2 (Clight.globalenv us_viewport_repaired_program))
            tt target trace target' /\
          match_states source' target').

(** This obligation is intentionally not inhabited here.  Its proof requires
    the concrete global-block/memory injection and external-call frames; a
    syntactic alpha-renaming cannot manufacture those semantic facts. *)
