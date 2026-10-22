(** Collection consumers in the actual selected program. These theorems
    retain the real call, its memory, and its argument reads. They do not
    assume that an old contact-list entry is a fresh collision. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Coqlib
  Ctypes Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Proofs Require Import GameTypes ContactConsumerSource
  ContactConsumerExecution ObjectContactNecessity Area2Rank12BContact
  Area2Rank9AStarSource SelectedClightTarget InkPlatformWriteFrame.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

Fixpoint ccr_boolean_returns (s : statement) : bool := match s with
| Sskip | Sset _ _ | Sbreak | Scontinue => true
| Ssequence a b | Sifthenelse _ a b | Sloop a b =>
    ccr_boolean_returns a && ccr_boolean_returns b
| Sreturn (Some (Econst_int n (Tint I32 Signed attr))) =>
    if attr.(attr_volatile) then false else
    match attr.(attr_alignas) with
    | None => Int.eq n Int.zero || Int.eq n Int.one | _ => false end
| _ => false end.

Lemma ccr_boolean_return_values : forall ge e le m s t le' m' out,
  ocn_exec ge e le m s t le' m' out -> ccr_boolean_returns s = true ->
  forall value ty, out = Out_return (Some (value, ty)) ->
  ty = tint /\ (value = Vint Int.zero \/ value = Vint Int.one).
Proof.
  intros ge e le m s t le' m' out Hrun.
  induction Hrun; cbn; intros Hshape value ty Hout; try discriminate;
    try solve [apply andb_true_iff in Hshape as [Ha Hb]; eauto].
  - destruct b; apply andb_true_iff in Hshape as [Ha Hb]; eauto.
  - destruct a; try discriminate.
    match goal with Hexpr : eval_expr _ _ _ _ (Econst_int _ ?aty) _ |- _ =>
      destruct aty; try discriminate end.
    match goal with size : intsize |- _ => destruct size; try discriminate end.
    match goal with sign : signedness |- _ => destruct sign; try discriminate end.
    match goal with attr : attr |- _ => destruct attr as [volatile alignas] end.
    destruct volatile; try discriminate.
    destruct alignas; try discriminate. inversion Hout; subst.
    apply ocn_const_int_value in H. subst.
    apply orb_true_iff in Hshape as [Hn | Hn];
      match type of Hn with Int.eq ?n ?k = true =>
        pose proof (Int.eq_spec n k) as Heq; rewrite Hn in Heq; subst n end;
      split; auto.
  - apply andb_true_iff in Hshape as [Ha Hb].
    match goal with Hstop : out_break_or_return _ _ |- _ =>
      inversion Hstop; subst end; eauto; discriminate.
  - apply andb_true_iff in Hshape as [Ha Hb].
    match goal with Hstop : out_break_or_return _ _ |- _ =>
      inversion Hstop; subst end; eauto; discriminate.
  - eapply IHHrun3; eauto.
Qed.

Lemma ccr_pair_return_is_boolean : forall version ge e le m t le' m' value ty,
  ocn_exec ge e le m (fn_body (ccs_body version CCPairSearch))
    t le' m' (Out_return (Some (value, ty))) ->
  ty = tint /\ (value = Vint Int.zero \/ value = Vint Int.one).
Proof.
  intros. eapply ccr_boolean_return_values; [eassumption | | reflexivity].
  destruct version; vm_compute; reflexivity.
Qed.

(** Actual function entry for the search allocates no local blocks. *)
Lemma ccr_search_call_body : forall version consumer args m t m' result,
  consumer = CCPairSearch \/ consumer = CCStarSearch ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) m
    (Internal (ccs_body version consumer)) args t m' result ->
  exists le le' out,
    bind_parameter_temps (fn_params (ccs_body version consumer)) args
      (create_undef_temps (fn_temps (ccs_body version consumer))) = Some le /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) empty_env le m
      (fn_body (ccs_body version consumer)) E0 le' m out /\
    outcome_result_value out (fn_return (ccs_body version consumer)) result m.
Proof.
  intros version consumer args m t m' result Hconsumer Hcall.
  assert (fn_vars (ccs_body version consumer) = []) as Hvars
    by (destruct version; destruct Hconsumer as [Hc | Hc]; subst consumer; reflexivity).
  pose proof (cce_search_call_preserves_memory _ _ _ _ _ _ _ Hconsumer Hcall)
    as [Ht Hm]. subst t m'.
  inversion Hcall; subst.
  match goal with Hentry : function_entry2 _ _ _ _ _ _ _ |- _ =>
    inversion Hentry; subst; clear Hentry end.
  match goal with Halloc : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Halloc; inversion Halloc; subst end.
  match goal with Hfree : Mem.free_list ?before (blocks_of_env _ empty_env) = Some ?after |- _ =>
    change (Some before = Some after) in Hfree; inversion Hfree; subst end.
  eauto 8.
Qed.

Theorem ccr_pair_call_reads_requested_object :
  forall version source target offset m t m',
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) m
    (Internal (ccs_body version CCPairSearch)) [source; Vptr target offset]
    t m' (Vint Int.one) ->
  t = E0 /\ m' = m /\ exists il count,
    il ! CCH._obj1 = Some source /\
    il ! CCH._obj2 = Some (Vptr target offset) /\
    eval_expr (Clight.globalenv (selected_clight_target version)) empty_env il m
      cce_pair_count_expression count /\
    eval_expr (Clight.globalenv (selected_clight_target version)) empty_env
      (PTree.set CCH._t'2 count il) m cce_pair_entry_expression (Vptr target offset) /\
    ocn_test_value (Clight.globalenv (selected_clight_target version)) empty_env
      (PTree.set CCH._t'2 count il) m cce_pair_count_guard true.
Proof.
  intros version source target offset m t m' Hcall.
  pose proof (cce_search_call_preserves_memory _ _ _ _ _ _ _ (or_introl eq_refl) Hcall)
    as [Ht Hm]. split; [assumption |]. split; [assumption |].
  destruct (ccr_search_call_body _ _ _ _ _ _ _ (or_introl eq_refl) Hcall)
    as (le & le' & out & Hbind & Hbody & Hresult).
  assert (fn_return (ccs_body version CCPairSearch) = tint) as Hreturn
    by (destruct version; reflexivity).
  rewrite Hreturn in Hresult. destruct out; try contradiction.
  destruct o as [[value ty] |]; try contradiction.
  destruct (ccr_pair_return_is_boolean _ _ _ _ _ _ _ _ _ _ Hbody)
    as [Hty [Hz | Ho]]; subst.
  - change (tint <> tvoid /\ Some (Vint Int.zero) = Some (Vint Int.one)) in Hresult.
    vm_compute in Hresult. destruct Hresult as [_ Hbad]. discriminate.
  - assert (le ! CCH._obj1 = Some source /\
      le ! CCH._obj2 = Some (Vptr target offset)) as [Hone Htwo].
    { destruct version; cbn in Hbind; inversion Hbind; subst;
        split; reflexivity. }
    destruct (cce_successful_pair_search_reads_requested_object
      _ _ _ _ _ _ _ _ _ Htwo Hbody) as (_ & _ & il & count & Hreads).
    exists il, count. rewrite <- Hone. tauto.
Qed.

Theorem ccr_pair_call_returns_boolean : forall version args m t m' result,
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) m
    (Internal (ccs_body version CCPairSearch)) args t m' result ->
  result = Vint Int.zero \/ result = Vint Int.one.
Proof.
  intros version args m t m' result Hcall.
  destruct (ccr_search_call_body _ _ _ _ _ _ _ (or_introl eq_refl) Hcall)
    as (le & le' & out & Hbind & Hbody & Hresult).
  assert (fn_return (ccs_body version CCPairSearch) = tint) as Hreturn
    by (destruct version; reflexivity).
  rewrite Hreturn in Hresult. destruct out; try contradiction.
  destruct o as [[value ty] |]; try contradiction.
  destruct (ccr_pair_return_is_boolean _ _ _ _ _ _ _ _ _ _ Hbody)
    as [Hty [Hz | Ho]]; subst;
    destruct Hresult as [_ Hvalue]; cbn in Hvalue; inversion Hvalue; auto.
Qed.

(** A returned Object pointer is the pointer actually read by the star
    consumer in the input memory. Function entry binds the real Mario and
    interaction-type arguments; the return cast cannot invent or replace a
    pointer. This establishes cached-list consumption, not fresh collision
    registration, object lifetime, or target-star provenance. *)
Theorem ccr_star_call_reads_returned_object :
  forall version mario requested_kind target offset m t m',
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) m
    (Internal (ccs_body version CCStarSearch)) [mario; requested_kind]
    t m' (Vptr target offset) ->
  t = E0 /\ m' = m /\ exists il first_owner count second_owner kind,
    il ! CCI._m = Some mario /\
    il ! CCI._interactType = Some requested_kind /\
    eval_expr (Clight.globalenv (selected_clight_target version)) empty_env il m
      cce_star_owner_expression first_owner /\
    eval_expr (Clight.globalenv (selected_clight_target version)) empty_env
      (PTree.set CCI._t'3 first_owner il) m cce_star_count_expression count /\
    ocn_test_value (Clight.globalenv (selected_clight_target version)) empty_env
      (cce_star_count_locals il first_owner count) m cce_star_count_guard true /\
    eval_expr (Clight.globalenv (selected_clight_target version)) empty_env
      (cce_star_count_locals il first_owner count) m
      cce_star_owner_expression second_owner /\
    eval_expr (Clight.globalenv (selected_clight_target version)) empty_env
      (cce_star_entry_locals il first_owner count second_owner) m
      cce_star_entry_expression (Vptr target offset) /\
    eval_expr (Clight.globalenv (selected_clight_target version)) empty_env
      (PTree.set CCI._object (Vptr target offset)
        (cce_star_entry_locals il first_owner count second_owner)) m
      (cce_star_type_expression version) kind /\
    ocn_test_value (Clight.globalenv (selected_clight_target version)) empty_env
      (cce_star_match_locals il first_owner count second_owner (Vptr target offset) kind)
      m cce_star_match_guard true.
Proof.
  intros version mario requested_kind target offset m t m' Hcall.
  pose proof (cce_search_call_preserves_memory _ _ _ _ _ _ _
    (or_intror eq_refl) Hcall) as [Ht Hm].
  split; [exact Ht |]. split; [exact Hm |].
  destruct (ccr_search_call_body _ _ _ _ _ _ _ (or_intror eq_refl) Hcall)
    as (le & le' & out & Hbind & Hbody & Hresult).
  assert (fn_return (ccs_body version CCStarSearch) = cce_star_object_type) as Hreturn
    by (destruct version; reflexivity).
  rewrite Hreturn in Hresult. destruct out; try contradiction.
  destruct o as [[value ty] |]; try contradiction.
  cbn [outcome_result_value] in Hresult. destruct Hresult as [_ Hcast].
  apply ipw_cast_keeps_block in Hcast. subst value.
  assert (le ! CCI._m = Some mario /\
    le ! CCI._interactType = Some requested_kind) as [Hmario Hkind].
  { destruct version; cbn in Hbind; inversion Hbind; subst;
      split; reflexivity. }
  destruct (cce_successful_star_search_reads_returned_object
    _ _ _ _ _ _ _ _ _ _ Hbody)
    as (_ & _ & il & first_owner & count & second_owner & kind & Hreads).
  exists il, first_owner, count, second_owner, kind.
  rewrite <- Hmario, <- Hkind. exact Hreads.
Qed.
