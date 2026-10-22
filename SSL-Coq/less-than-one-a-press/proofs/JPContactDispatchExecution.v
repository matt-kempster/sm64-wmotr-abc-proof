(** A same-execution C1 slice of the selected JP dispatcher.  The contact
    list may be stale and the mask store may alias other data.  Neither is
    ruled out: the store's actual output memory is retained at the handler. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Coqlib
  Ctypes Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Proofs Require Import GameTypes ContactConsumerSource
  ContactConsumerExecution ContactCreditExecution SecretContactExecution
  ObjectContactNecessity SelectedClightTarget InkBackwardExecution.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

Definition jcd_ge := Clight.globalenv (selected_clight_target VersionJP).
Definition jcd_mario_type := tptr (Tstruct CCI._MarioState noattr).
Definition jcd_object_type := tptr (Tstruct CCI._Object noattr).

(** Extract the interaction-type branch from the generated dispatcher;
    no surrogate dispatcher or independent execution witness is used. *)
Definition jcd_branch :=
  match fn_body (ccs_body VersionJP CCStarDispatch) with
  | Ssequence _ (Ssequence _
      (Ssequence (Ssequence _ (Sifthenelse _
        (Ssequence _ (Sloop (Ssequence _ (Ssequence _
          (Ssequence _ (Sifthenelse _ branch _)))) _)) _)) _)) => branch
  | _ => Sskip end.
Definition jcd_search := match jcd_branch with
  | Ssequence (Ssequence search _) _ => search | _ => Sskip end.
Definition jcd_mask := match jcd_branch with
  | Ssequence _ (Ssequence mask _) => mask | _ => Sskip end.
Definition jcd_status_read := match jcd_branch with
  | Ssequence _ (Ssequence _ (Ssequence status _)) => status | _ => Sskip end.
Definition jcd_status_guard := match jcd_branch with
  | Ssequence _ (Ssequence _ (Ssequence _ (Sifthenelse guard _ _))) => guard
  | _ => Econst_int Int.zero tint end.
Definition jcd_handler := match jcd_branch with
  | Ssequence _ (Ssequence _ (Ssequence _
      (Sifthenelse _ (Ssequence handler _) _))) => handler | _ => Sskip end.
Definition jcd_handler_read := match jcd_handler with
  | Ssequence read _ => read | _ => Sskip end.
Definition jcd_handler_call := match jcd_handler with
  | Ssequence _ call => call | _ => Sskip end.
Definition jcd_break_guard := match jcd_branch with
  | Ssequence _ (Ssequence _ (Ssequence _
      (Sifthenelse _ (Ssequence _ guard) _))) => guard | _ => Sskip end.
Definition jcd_before_status :=
  Ssequence (Ssequence jcd_search
    (Sset CCI._object (Etempvar CCI._t'2 jcd_object_type)))
    (Ssequence jcd_mask jcd_status_read).
Definition jcd_handler_type :=
  Tfunction [jcd_mario_type; tuint; jcd_object_type] tuint cc_default.

Lemma jcd_generated_branch_shape :
  jcd_search = Scall (Some CCI._t'2)
    (Evar CCI._mario_get_collided_object
      (Tfunction [jcd_mario_type; tuint] jcd_object_type cc_default))
    [Etempvar CCI._m jcd_mario_type; Etempvar CCI._interactType tuint] /\
  jcd_branch = Ssequence
    (Ssequence jcd_search (Sset CCI._object (Etempvar CCI._t'2 jcd_object_type)))
    (Ssequence jcd_mask (Ssequence jcd_status_read
      (Sifthenelse jcd_status_guard
        (Ssequence jcd_handler jcd_break_guard) Sskip))) /\
  jcd_handler_call = Scall (Some CCI._t'3)
    (Etempvar CCI._t'16 (tptr jcd_handler_type))
    [Etempvar CCI._m jcd_mario_type; Etempvar CCI._interactType tuint;
     Etempvar CCI._object jcd_object_type].
Proof. repeat split; reflexivity. Qed.

Lemma jcd_uint_cast_identity : forall value m cast,
  sem_cast value tuint tuint m = Some cast -> cast = value.
Proof.
  intros value m cast Hcast.
  change (match value with
    | Vint _ => Some value | Vptr _ _ => Some value | _ => None end = Some cast)
    in Hcast.
  destruct value; congruence.
Qed.

Lemma jcd_temp_arguments : forall ge e le m mario kind candidate args,
  le ! CCI._m = Some mario -> le ! CCI._interactType = Some kind ->
  le ! CCI._object = Some candidate ->
  eval_exprlist ge e le m
    [Etempvar CCI._m jcd_mario_type; Etempvar CCI._interactType tuint;
     Etempvar CCI._object jcd_object_type]
    [jcd_mario_type; tuint; jcd_object_type] args ->
  args = [mario; kind; candidate].
Proof.
  intros ge e le m mario kind candidate args Hm Hk Ho Hargs.
  repeat match goal with Hlist : eval_exprlist _ _ _ _ _ _ _ |- _ =>
    inversion Hlist; subst; clear Hlist end.
  repeat match goal with Hexpr : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inversion Hexpr; subst; clear Hexpr end.
  all: try match goal with Hlv : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
    inversion Hlv end.
  repeat match goal with Hcast : sem_cast _ (typeof _) _ _ = _ |- _ =>
    cbn [typeof] in Hcast end.
  repeat match goal with Hcast : sem_cast ?v tuint tuint _ = Some ?c |- _ =>
    apply jcd_uint_cast_identity in Hcast; subst c end.
  repeat match goal with Hcast : sem_cast ?v ?ty ?ty _ = Some ?c |- _ =>
    change (sem_cast v sce_object_pointer sce_object_pointer m = Some c) in Hcast;
    apply sce_object_cast_identity in Hcast; subst c end.
  f_equal; congruence.
Qed.

(** This checker is used only to invert the concrete search-copy/mask/read
    prefixes.  It permits stores and makes no memory-frame claim. *)
Fixpoint jcd_silent_normal (s : statement) : bool := match s with
| Sskip | Sset _ _ | Sassign _ _ => true
| Ssequence a b => jcd_silent_normal a && jcd_silent_normal b
| _ => false end.

Lemma jcd_silent_normal_execution : forall ge e le m s t le' m' out,
  ocn_exec ge e le m s t le' m' out -> jcd_silent_normal s = true ->
  t = E0 /\ out = Out_normal.
Proof.
  intros ge e le m s t le' m' out Hrun.
  induction Hrun; cbn; intro Hshape; try discriminate;
    try (split; reflexivity).
  - apply andb_true_iff in Hshape as [Ha Hb].
    destruct (IHHrun1 Ha) as [-> _].
    destruct (IHHrun2 Hb) as [-> ->]. split; reflexivity.
  - apply andb_true_iff in Hshape as [Ha Hb].
    destruct (IHHrun Ha) as [_ Hnormal]. contradiction.
Qed.

Lemma jcd_search_calls_selected_body : forall le m t le' m' out,
  ocn_exec jcd_ge empty_env le m jcd_search t le' m' out ->
  exists mario kind candidate,
    le ! CCI._m = Some mario /\ le ! CCI._interactType = Some kind /\
    ClightBigstep.Clight2.eval_funcall jcd_ge m
      (Internal (ccs_body VersionJP CCStarSearch)) [mario; kind] E0 m candidate /\
    t = E0 /\ m' = m /\ out = Out_normal /\
    le' = PTree.set CCI._t'2 candidate le.
Proof.
  intros le m t le' m' out Hrun.
  destruct (ccs_selected_consumer_resolves VersionJP CCStarSearch)
    as (function_block & Hsymbol & Hfunction).
  fold jcd_ge in Hsymbol, Hfunction.
  rewrite (proj1 jcd_generated_branch_shape) in Hrun. inversion Hrun; subst.
  match goal with Hclass : classify_fun _ = _ |- _ =>
    cbn in Hclass; inversion Hclass; subst end.
  assert (vf = Vptr function_block Ptrofs.zero) as Hnamed.
  { exact (sce_function_name_value jcd_ge empty_env le m
      CCI._mario_get_collided_object [jcd_mario_type; tuint]
      jcd_object_type cc_default function_block vf eq_refl Hsymbol H3). }
  subst vf.
  rewrite Genv.find_funct_find_funct_ptr in H8.
  rewrite Hfunction in H8. inversion H8; subst f.
  pose proof (cce_search_call_preserves_memory VersionJP CCStarSearch
    vargs m t m' vres (or_intror eq_refl) H14) as [Ht Hmemory].
  subst t m'.
  repeat match goal with Hargs : eval_exprlist _ _ _ _ _ _ _ |- _ =>
    inversion Hargs; subst; clear Hargs end.
  repeat match goal with Hexpr : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inversion Hexpr; subst; clear Hexpr end.
  all: try match goal with Hlv : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
    inversion Hlv end.
  repeat match goal with Hcast : sem_cast _ (typeof _) _ _ = _ |- _ =>
    cbn [typeof] in Hcast end.
  repeat match goal with Hcast : sem_cast ?v tuint tuint _ = Some ?c |- _ =>
    apply jcd_uint_cast_identity in Hcast; subst c end.
  repeat match goal with Hcast : sem_cast ?v jcd_mario_type jcd_mario_type _ = Some ?c |- _ =>
    change (sem_cast v sce_object_pointer sce_object_pointer m = Some c) in Hcast;
    apply sce_object_cast_identity in Hcast; subst c end.
  eauto 10.
Qed.

Definition jcd_search_copy := Ssequence jcd_search
  (Sset CCI._object (Etempvar CCI._t'2 jcd_object_type)).

Lemma jcd_search_copy_execution : forall le m t le' m' out,
  ocn_exec jcd_ge empty_env le m jcd_search_copy t le' m' out ->
  exists mario kind candidate,
    le ! CCI._m = Some mario /\ le ! CCI._interactType = Some kind /\
    ClightBigstep.Clight2.eval_funcall jcd_ge m
      (Internal (ccs_body VersionJP CCStarSearch)) [mario; kind] E0 m candidate /\
    t = E0 /\ m' = m /\ out = Out_normal /\
    le' = PTree.set CCI._object candidate (PTree.set CCI._t'2 candidate le).
Proof.
  intros le m t le' m' out Hrun. unfold jcd_search_copy in Hrun.
  inversion Hrun; subst.
  all: match goal with Hsearch : ClightBigstep.exec_stmt _ _ _ _ _ jcd_search _ _ _ _ |- _ =>
    destruct (jcd_search_calls_selected_body _ _ _ _ _ _ Hsearch)
      as (mario & kind & candidate & Hmario & Hkind & Hcall & Ht & Hmemory & Hout & Hlocals);
    subst end.
  2: contradiction.
  match goal with Hcopy : ClightBigstep.exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ =>
    inversion Hcopy; subst end.
  match goal with Hread : eval_expr _ _ _ _ (Etempvar CCI._t'2 _) ?v |- _ =>
    assert (v = candidate) by (eapply ocn_temp_value; [exact Hread | apply PTree.gss]);
    subst v end.
  exists mario, kind, candidate. repeat split; try assumption; reflexivity.
Qed.

(** The real status dereference requires a pointer-valued candidate.  This
    follows from defined execution, including when the guard suppresses the
    handler; it is not an additional pointer or object-lifetime premise. *)
Lemma jcd_status_read_requires_pointer :
  forall le m t le' m' out candidate,
  le ! CCI._object = Some candidate ->
  ocn_exec jcd_ge empty_env le m jcd_status_read t le' m' out ->
  exists b ofs, candidate = Vptr b ofs.
Proof.
  intros le m t le' m' out candidate Ho Hrun.
  cbn [jcd_status_read jcd_branch ccs_body fn_body
    jp_interaction.f_mario_process_interactions] in Hrun.
  inversion Hrun; subst; clear Hrun.
  all: repeat match goal with
  | H : eval_expr _ _ _ _ (Ederef _ _) _ |- _ =>
      inversion H; subst; clear H
  | H : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      inversion H; subst; clear H
  | H : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ =>
      inversion H; subst; clear H
  | H : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
      inversion H; subst; clear H
  | H : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
      inversion H; subst; clear H
  | H : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ =>
      inversion H
  end.
  all: match goal with
  | Htemp : eval_expr _ _ _ _ (Etempvar _ _) (Vptr ?b ?ofs) |- _ =>
      exists b, ofs; symmetry;
      eapply ocn_temp_value; [exact Htemp | exact Ho]
  end.
Qed.

(** Derived observations of the same selected search, in its input memory.
    This packages a conclusion, not an assumed reachability certificate. *)
Definition jcd_search_readback (mario requested_kind candidate : val)
  (m : Mem.mem) : Prop :=
  exists target offset, candidate = Vptr target offset /\
  exists il first_owner count second_owner kind,
    il ! CCI._m = Some mario /\
    il ! CCI._interactType = Some requested_kind /\
    eval_expr jcd_ge empty_env il m cce_star_owner_expression first_owner /\
    eval_expr jcd_ge empty_env (PTree.set CCI._t'3 first_owner il) m
      cce_star_count_expression count /\
    ocn_test_value jcd_ge empty_env
      (cce_star_count_locals il first_owner count) m cce_star_count_guard true /\
    eval_expr jcd_ge empty_env (cce_star_count_locals il first_owner count) m
      cce_star_owner_expression second_owner /\
    eval_expr jcd_ge empty_env
      (cce_star_entry_locals il first_owner count second_owner) m
      cce_star_entry_expression (Vptr target offset) /\
    eval_expr jcd_ge empty_env
      (PTree.set CCI._object (Vptr target offset)
        (cce_star_entry_locals il first_owner count second_owner)) m
      (cce_star_type_expression VersionJP) kind /\
    ocn_test_value jcd_ge empty_env
      (cce_star_match_locals il first_owner count second_owner (Vptr target offset) kind)
      m cce_star_match_guard true.

(** A complete execution of this actual branch either suppresses the
    handler at its status guard, or calls it with exactly the search result.
    Both zero and nonzero handler returns are covered.  Its callee is NOT
    assumed to be the star-award function. *)
Theorem jcd_branch_search_to_handler_identity : forall le m t le' m' out,
  ocn_exec jcd_ge empty_env le m jcd_branch t le' m' out ->
  exists mario kind candidate status_le status_m,
    le ! CCI._m = Some mario /\ le ! CCI._interactType = Some kind /\
    ClightBigstep.Clight2.eval_funcall jcd_ge m
      (Internal (ccs_body VersionJP CCStarSearch)) [mario; kind] E0 m candidate /\
    jcd_search_readback mario kind candidate m /\
    ocn_exec jcd_ge empty_env le m jcd_before_status E0 status_le status_m Out_normal /\
    status_le ! CCI._m = Some mario /\
    status_le ! CCI._interactType = Some kind /\
    status_le ! CCI._object = Some candidate /\
    ((ocn_test_value jcd_ge empty_env status_le status_m jcd_status_guard false /\
       t = E0 /\ m' = status_m /\ out = Out_normal) \/
     (ocn_test_value jcd_ge empty_env status_le status_m jcd_status_guard true /\
       exists handler_le vf fd result,
         ocn_exec jcd_ge empty_env status_le status_m jcd_handler_read
           E0 handler_le status_m Out_normal /\
         eval_expr jcd_ge empty_env handler_le status_m
           (Etempvar CCI._t'16 (tptr jcd_handler_type)) vf /\
         Genv.find_funct jcd_ge vf = Some fd /\
         type_of_fundef fd = jcd_handler_type /\
         ClightBigstep.Clight2.eval_funcall jcd_ge status_m fd
           [mario; kind; candidate] t m' result)).
Proof.
  intros le m t le' m' out Hrun.
  rewrite (proj1 (proj2 jcd_generated_branch_shape)) in Hrun.
  destruct (ibk_split_sequence _ _ _ _ jcd_search_copy _ _ _ _ _ eq_refl Hrun)
    as (copy_le & copy_m & copy_t & rest_t & Htrace & Hcopy & Hrest).
  destruct (jcd_search_copy_execution _ _ _ _ _ _ Hcopy)
    as (mario & kind & candidate & Hmario & Hkind & Hcall & Hcopyt & Hcopym & _ & Hcopylocals).
  subst copy_t copy_m copy_le.
  destruct (ibk_split_sequence _ _ _ _ jcd_mask _ _ _ _ _ eq_refl Hrest)
    as (mask_le & mask_m & mask_t & status_t & Hresttrace & Hmask & Hstatus).
  pose proof (jcd_silent_normal_execution _ _ _ _ _ _ _ _ _ Hmask eq_refl)
    as [Hmaskt _]. subst mask_t.
  destruct (ibk_split_sequence _ _ _ _ jcd_status_read _ _ _ _ _ eq_refl Hstatus)
    as (status_le & status_m & read_t & guard_t & Hstatustrace & Hread & Hguard).
  pose proof (jcd_silent_normal_execution _ _ _ _ _ _ _ _ _ Hread eq_refl)
    as [Hreadt _]. subst read_t.
  assert (Hafter : ocn_exec jcd_ge empty_env
    (PTree.set CCI._object candidate (PTree.set CCI._t'2 candidate le)) m
    (Ssequence jcd_mask jcd_status_read) E0 status_le status_m Out_normal).
  { eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); eassumption. }
  assert (Hprefix : ocn_exec jcd_ge empty_env le m jcd_before_status
    E0 status_le status_m Out_normal).
  { unfold jcd_before_status.
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); eassumption. }
  assert (Hm : status_le ! CCI._m = Some mario).
  { rewrite (cce_argument_temporary_is_preserved _ _ _ _ _ _ _ _ _ CCI._m Hafter eq_refl).
    rewrite !PTree.gso by discriminate. exact Hmario. }
  assert (Hk : status_le ! CCI._interactType = Some kind).
  { rewrite (cce_argument_temporary_is_preserved _ _ _ _ _ _ _ _ _ CCI._interactType Hafter eq_refl).
    rewrite !PTree.gso by discriminate. exact Hkind. }
  assert (Ho : status_le ! CCI._object = Some candidate).
  { rewrite (cce_argument_temporary_is_preserved _ _ _ _ _ _ _ _ _ CCI._object Hafter eq_refl).
    apply PTree.gss. }
  assert (Ho_mask : mask_le ! CCI._object = Some candidate).
  { rewrite <- (cce_argument_temporary_is_preserved
      _ _ _ _ _ _ _ _ _ CCI._object Hread eq_refl). exact Ho. }
  destruct (jcd_status_read_requires_pointer _ _ _ _ _ _ _ Ho_mask Hread)
    as (target & offset & Hcandidate).
  assert (Hreads : jcd_search_readback mario kind candidate m).
  { unfold jcd_search_readback. exists target, offset.
    split; [exact Hcandidate |].
    assert (Hpointer_call : ClightBigstep.Clight2.eval_funcall jcd_ge m
      (Internal (ccs_body VersionJP CCStarSearch)) [mario; kind]
      E0 m (Vptr target offset)).
    { rewrite <- Hcandidate. exact Hcall. }
    destruct (ccr_star_call_reads_returned_object VersionJP mario kind
      target offset m E0 m Hpointer_call) as (_ & _ & Hobservations).
    exact Hobservations. }
  clear Hcandidate target offset.
  assert (Ht : t = guard_t) by (rewrite Htrace, Hresttrace, Hstatustrace; reflexivity).
  subst t.
  exists mario, kind, candidate, status_le, status_m.
  split; [exact Hmario |]. split; [exact Hkind |]. split; [exact Hcall |].
  split; [exact Hreads |].
  split; [exact Hprefix |]. split; [exact Hm |]. split; [exact Hk |].
  split; [exact Ho |].
  inversion Hguard; subst.
  destruct b; cbn beta iota in *.
  - right. split; [unfold ocn_test_value; eauto |].
    match goal with Hyes : ClightBigstep.exec_stmt _ _ _ _ _
      (Ssequence jcd_handler jcd_break_guard) _ _ _ _ |- _ =>
      destruct (ibk_split_sequence _ _ _ _ jcd_handler _ _ _ _ _ eq_refl Hyes)
        as (handler_end_le & handler_end_m & handler_t & break_t & Hyestrace & Hhandler & Hbreak)
    end.
    destruct (cce_readonly_frame _ _ _ _ _ _ _ _ _ CCI._m Hbreak eq_refl)
      as (Hbreakt & Hbreakm & _). subst break_t handler_end_m.
    rewrite app_nil_r in Hyestrace. subst guard_t.
    change (ocn_exec jcd_ge empty_env status_le status_m
      (Ssequence jcd_handler_read jcd_handler_call) handler_t
      handler_end_le m' Out_normal) in Hhandler.
    destruct (ibk_split_sequence _ _ _ _ jcd_handler_read _ _ _ _ _ eq_refl Hhandler)
      as (handler_le & handler_m & load_t & call_t & Hhandlertrace & Hload & Hinvoke).
    destruct (cce_readonly_frame _ _ _ _ _ _ _ _ _ CCI._m Hload eq_refl)
      as (Hloadt & Hloadm & Hload_m).
    pose proof (cce_readonly_frame _ _ _ _ _ _ _ _ _ CCI._interactType Hload eq_refl)
      as (_ & _ & Hload_k).
    pose proof (cce_readonly_frame _ _ _ _ _ _ _ _ _ CCI._object Hload eq_refl)
      as (_ & _ & Hload_o).
    subst load_t handler_m.
    cbn [E0 app] in Hhandlertrace. subst handler_t.
    rewrite (proj2 (proj2 jcd_generated_branch_shape)) in Hinvoke.
    inversion Hinvoke; subst.
    match goal with Hclass : classify_fun _ = _ |- _ =>
      cbn in Hclass; inversion Hclass; subst end.
    match goal with Hargs : eval_exprlist _ _ _ _ _ _ ?args |- _ =>
      assert (args = [mario; kind; candidate])
        by (eapply jcd_temp_arguments; [rewrite Hload_m; exact Hm |
          rewrite Hload_k; exact Hk | rewrite Hload_o; exact Ho | exact Hargs]);
      subst args end.
    do 4 eexists. repeat split; eassumption.
  - left. match goal with Hskip : ClightBigstep.exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ =>
      inversion Hskip; subst end.
    repeat split; try reflexivity. unfold ocn_test_value; eauto.
Qed.
