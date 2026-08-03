(** Concrete external-call framing at the retail Clight boundary.

    CompCert deliberately gives unresolved [EF_external] calls an abstract
    semantics.  Consequently, a declaration such as [sqrtf] or [play_sound]
    cannot be assigned an arbitrary writable-memory frame merely from its C
    prototype.  In contrast, an [EF_builtin] or [EF_runtime] whose name and
    signature are recognized by CompCert executes [known_builtin_sem], which
    leaves the complete memory unchanged.

    This file separates those two cases and computes the direct external-call
    inventory of the actual linked US and JP slices.  "Direct" means a
    [Scall] whose callee expression is syntactically [Evar]; indirect function
    pointer calls are counted separately and remain a whole-program control-
    flow obligation. *)

From Coq Require Import List ZArith String.
From compcert Require Import AST Builtins Clight Coqlib Ctypes Events Globalenvs
  Maps Memory Values.
From LessThanOneAPress.Proofs Require Import LinkedClightPrograms
  CleanedClightPrograms ClightLinkExecution.

Import ListNotations.
Local Open Scope Z_scope.

(** The direct-[Sbuiltin] side of the retail frame audit is empty, rather than
    guarded by an assumed frame condition: exhaustive recursion over every
    official internal body found no such statement in either version. *)
Definition OfficialDirectSbuiltinFrameBoundary : Prop :=
  program_direct_sbuiltins us_official_cleaned_slice = [] /\
  program_direct_sbuiltins jp_official_cleaned_slice = [].

Theorem official_direct_sbuiltin_frame_boundary_closed :
  OfficialDirectSbuiltinFrameBoundary.
Proof.
  split.
  - exact us_official_target_has_no_direct_sbuiltin.
  - exact jp_official_target_has_no_direct_sbuiltin.
Qed.

(** * Frames justified by CompCert's concrete known-builtin semantics *)

Lemma known_builtin_external_call_memory_identity :
  forall name signature builtin ge arguments before trace result after,
    lookup_builtin_function name signature = Some builtin ->
    external_call (EF_builtin name signature) ge arguments before trace
      result after ->
    trace = E0 /\ after = before.
Proof.
  intros name signature builtin ge arguments before trace result after
    Hlookup Hcall.
  unfold external_call, builtin_or_external_sem in Hcall.
  rewrite Hlookup in Hcall.
  inversion Hcall; subst; auto.
Qed.

Lemma known_runtime_external_call_memory_identity :
  forall name signature builtin ge arguments before trace result after,
    lookup_builtin_function name signature = Some builtin ->
    external_call (EF_runtime name signature) ge arguments before trace
      result after ->
    trace = E0 /\ after = before.
Proof.
  intros name signature builtin ge arguments before trace result after
    Hlookup Hcall.
  unfold external_call, builtin_or_external_sem in Hcall.
  rewrite Hlookup in Hcall.
  inversion Hcall; subst; auto.
Qed.

Theorem recognized_builtin_has_every_writable_frame :
  forall name signature builtin protected,
    lookup_builtin_function name signature = Some builtin ->
    ExternalCallFrame protected (EF_builtin name signature).
Proof.
  intros name signature builtin protected Hlookup ge arguments before trace
    result after Hcall.
  destruct (known_builtin_external_call_memory_identity name signature builtin
    ge arguments before trace result after Hlookup Hcall) as [_ ->].
  apply Mem.unchanged_on_refl.
Qed.

Theorem recognized_runtime_has_every_writable_frame :
  forall name signature builtin protected,
    lookup_builtin_function name signature = Some builtin ->
    ExternalCallFrame protected (EF_runtime name signature).
Proof.
  intros name signature builtin protected Hlookup ge arguments before trace
    result after Hcall.
  destruct (known_runtime_external_call_memory_identity name signature builtin
    ge arguments before trace result after Hlookup Hcall) as [_ ->].
  apply Mem.unchanged_on_refl.
Qed.

(** The same fact stated for an entire byte footprint.  In particular, it
    applies without a non-aliasing premise to writable MarioState, Object, and
    controller blocks: a recognized builtin/runtime changes no memory at all. *)
Corollary recognized_builtin_preserves_load :
  forall name signature builtin ge arguments before trace result after
      chunk block offset value,
    lookup_builtin_function name signature = Some builtin ->
    external_call (EF_builtin name signature) ge arguments before trace
      result after ->
    Mem.load chunk before block offset = Some value ->
    Mem.load chunk after block offset = Some value.
Proof.
  intros name signature builtin ge arguments before trace result after chunk
    block offset value Hlookup Hcall Hload.
  destruct (known_builtin_external_call_memory_identity name signature builtin
    ge arguments before trace result after Hlookup Hcall) as [_ ->].
  exact Hload.
Qed.

Corollary recognized_runtime_preserves_load :
  forall name signature builtin ge arguments before trace result after
      chunk block offset value,
    lookup_builtin_function name signature = Some builtin ->
    external_call (EF_runtime name signature) ge arguments before trace
      result after ->
    Mem.load chunk before block offset = Some value ->
    Mem.load chunk after block offset = Some value.
Proof.
  intros name signature builtin ge arguments before trace result after chunk
    block offset value Hlookup Hcall Hload.
  destruct (known_runtime_external_call_memory_identity name signature builtin
    ge arguments before trace result after Hlookup Hcall) as [_ ->].
  exact Hload.
Qed.

(** * Syntactic direct-call inventory *)

Definition direct_callee (callee : expr) : option ident :=
  match callee with
  | Evar id _ => Some id
  | _ => None
  end.

Fixpoint statement_direct_callees (statement : statement) : list ident :=
  match statement with
  | Sskip | Sassign _ _ | Sset _ _ | Sbreak | Scontinue | Sgoto _ => []
  | Scall _ callee _ =>
      match direct_callee callee with Some id => [id] | None => [] end
  | Sbuiltin _ _ _ _ => []
  | Ssequence first second | Sloop first second =>
      statement_direct_callees first ++ statement_direct_callees second
  | Sifthenelse _ yes no =>
      statement_direct_callees yes ++ statement_direct_callees no
  | Sreturn _ => []
  | Sswitch _ cases => labeled_direct_callees cases
  | Slabel _ body => statement_direct_callees body
  end
with labeled_direct_callees (cases : labeled_statements) : list ident :=
  match cases with
  | LSnil => []
  | LScons _ statement rest =>
      statement_direct_callees statement ++ labeled_direct_callees rest
  end.

Definition definition_direct_callees
    (definition : globdef Clight.fundef type) : list ident :=
  match definition with
  | Gfun (Internal function) => statement_direct_callees (fn_body function)
  | _ => []
  end.

Definition program_direct_callees (program : Clight.program) : list ident :=
  concat (map (fun entry => definition_direct_callees (snd entry))
    (prog_defs program)).

Definition program_unique_direct_callees (program : Clight.program) : list ident :=
  nodup peq (program_direct_callees program).

Definition direct_external_call
    (program : Clight.program) (id : ident) : bool :=
  match (prog_defmap program) ! id with
  | Some (Gfun (External _ _ _ _)) => true
  | _ => false
  end.

Definition program_direct_external_callees
    (program : Clight.program) : list ident :=
  filter (direct_external_call program) (program_unique_direct_callees program).

Fixpoint direct_indirect_call_count_statement
    (statement : statement) : nat :=
  match statement with
  | Sskip | Sassign _ _ | Sset _ _ | Sbreak | Scontinue | Sgoto _ => 0
  | Scall _ callee _ =>
      match direct_callee callee with Some _ => 0 | None => 1 end
  | Sbuiltin _ _ _ _ => 0
  | Ssequence first second | Sloop first second =>
      direct_indirect_call_count_statement first +
      direct_indirect_call_count_statement second
  | Sifthenelse _ yes no =>
      direct_indirect_call_count_statement yes +
      direct_indirect_call_count_statement no
  | Sreturn _ => 0
  | Sswitch _ cases => direct_indirect_call_count_labeled cases
  | Slabel _ body => direct_indirect_call_count_statement body
  end
with direct_indirect_call_count_labeled
    (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0
  | LScons _ body rest =>
      direct_indirect_call_count_statement body +
      direct_indirect_call_count_labeled rest
  end.

Definition program_indirect_call_count (program : Clight.program) : nat :=
  fold_left Nat.add
    (map (fun entry =>
      match snd entry with
      | Gfun (Internal function) =>
          direct_indirect_call_count_statement (fn_body function)
      | _ => 0%nat
      end) (prog_defs program)) 0%nat.

Definition recognized_builtin_or_runtime_definition
    (definition : globdef Clight.fundef type) : bool :=
  match definition with
  | Gfun (External (EF_builtin name signature) _ _ _)
  | Gfun (External (EF_runtime name signature) _ _ _) =>
      match lookup_builtin_function name signature with
      | Some _ => true
      | None => false
      end
  | _ => false
  end.

Definition unresolved_external_definition
    (definition : globdef Clight.fundef type) : bool :=
  match definition with
  | Gfun (External (EF_external _ _) _ _ _) => true
  | _ => false
  end.

Definition direct_external_callees_all_recognized_or_unresolved
    (program : Clight.program) : bool :=
  forallb (fun id =>
    match (prog_defmap program) ! id with
    | Some definition =>
        recognized_builtin_or_runtime_definition definition ||
        unresolved_external_definition definition
    | None => false
    end) (program_direct_external_callees program).

(** * Concrete writable retail-state footprints *)

Definition named_global_bytes
    (program : Clight.program) (identifiers : list ident)
    (block : Values.block) (_ : Z) : Prop :=
  exists id,
    In id identifiers /\
    Genv.find_symbol (Clight.globalenv program) id = Some block.

Definition us_retail_state_global_identifiers : list ident :=
  [us_object_list_processor._gMarioStates;
   us_object_list_processor._gObjectPool;
   us_area._gMarioObject;
   us_game_init._gControllers;
   us_game_init._gPlayer1Controller].

Definition jp_retail_state_global_identifiers : list ident :=
  [jp_object_list_processor._gMarioStates;
   jp_object_list_processor._gObjectPool;
   jp_area._gMarioObject;
   jp_game_init._gControllers;
   jp_game_init._gPlayer1Controller].

Definition us_retail_state_writable_footprint : Values.block -> Z -> Prop :=
  named_global_bytes us_official_cleaned_slice
    us_retail_state_global_identifiers.

Definition jp_retail_state_writable_footprint : Values.block -> Z -> Prop :=
  named_global_bytes jp_official_cleaned_slice
    jp_retail_state_global_identifiers.

(** Recognized CompCert builtins/runtime helpers preserve the entire memory, so
    in particular they preserve every byte of MarioState, the object pool,
    the Mario-object pointer, and controller state. *)

Corollary recognized_builtin_preserves_us_retail_state :
  forall name signature builtin,
    lookup_builtin_function name signature = Some builtin ->
    ExternalCallFrame us_retail_state_writable_footprint
      (EF_builtin name signature).
Proof.
  intros. eapply recognized_builtin_has_every_writable_frame; eauto.
Qed.

Corollary recognized_runtime_preserves_us_retail_state :
  forall name signature builtin,
    lookup_builtin_function name signature = Some builtin ->
    ExternalCallFrame us_retail_state_writable_footprint
      (EF_runtime name signature).
Proof.
  intros. eapply recognized_runtime_has_every_writable_frame; eauto.
Qed.

Corollary recognized_builtin_preserves_jp_retail_state :
  forall name signature builtin,
    lookup_builtin_function name signature = Some builtin ->
    ExternalCallFrame jp_retail_state_writable_footprint
      (EF_builtin name signature).
Proof.
  intros. eapply recognized_builtin_has_every_writable_frame; eauto.
Qed.

Corollary recognized_runtime_preserves_jp_retail_state :
  forall name signature builtin,
    lookup_builtin_function name signature = Some builtin ->
    ExternalCallFrame jp_retail_state_writable_footprint
      (EF_runtime name signature).
Proof.
  intros. eapply recognized_runtime_has_every_writable_frame; eauto.
Qed.

(** CompCert intentionally leaves [EF_external] effects abstract.  These
    concrete propositions are therefore the remaining per-external contracts;
    they are not inhabited here and cannot be derived from a declaration
    prototype alone. *)
Definition USRetailStateExternalFramesObligation : Prop :=
  TrueUnresolvedExternalFrames us_official_cleaned_slice
    us_retail_state_writable_footprint.

Definition JPRetailStateExternalFramesObligation : Prop :=
  TrueUnresolvedExternalFrames jp_official_cleaned_slice
    jp_retail_state_writable_footprint.

Record RetailExternalFrameBoundary : Prop := {
  us_retail_external_frames : USRetailStateExternalFramesObligation;
  jp_retail_external_frames : JPRetailStateExternalFramesObligation
}.
