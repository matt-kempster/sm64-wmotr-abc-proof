(** Actual idle cancellation after its earlier guards have continued.
    OFF_FLOOR selects the real FREEFALL request and returns one before the
    later sliding/walking/Z guards. Callee effects remain in the execution;
    neither high-entry reachability nor a whole knockback history is assumed
    proved by this reached-cut result. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import
  us_mario_actions_stationary jp_mario_actions_stationary.
From LessThanOneAPress.Proofs Require Import GameTypes InkBackwardSource
  InkBackwardExecution InkMovingBackwardSource InkLandingHistory
  InkLandingHistoryReturn InkLandingExecution InkMarioInputFlag
  InkActionPassHistory InkMarioEntryGuards ObjectContactNecessity
  ContactConsumerExecution Area2Rank12BContact SelectedClightTarget.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Local Opaque selected_clight_target.
Module IIO := us_mario_actions_stationary.

Definition iio_body version := match version with
| VersionUS => us_mario_actions_stationary.f_check_common_idle_cancels
| VersionJP => jp_mario_actions_stationary.f_check_common_idle_cancels end.
Definition iio_prefix version := ocn_prefix_items 4 (fn_body (iio_body version)).
Definition iio_tail version := rank12b_drop_sequences 4 (fn_body (iio_body version)).
Definition iio_guard version := ibk_head (iio_tail version).
Definition iio_later version := rank12b_drop_sequences 1 (iio_tail version).
Definition iio_request := Scall (Some IIO._t'4)
  (Evar IIO._set_mario_action ilh_set_action_type)
  [Etempvar IIO._m (tptr (Tstruct IIO._MarioState noattr));
   Econst_int (Int.repr 16779404) tint; Econst_int Int.zero tint].
Definition iio_yes := Ssequence iio_request
  (Sreturn (Some (Etempvar IIO._t'4 tuint))).

Lemma iio_generated_source : forall version,
  fn_body (iio_body version) = ocn_prepend (iio_prefix version) (iio_tail version) /\
  iio_tail version = Ssequence (iio_guard version) (iio_later version) /\
  iio_guard version = ilh_input_guard IIO._t'16 (Int.repr 4) iio_yes /\
  ibk_normal iio_request = true.
Proof. intros []; repeat split; reflexivity. Qed.

(** The existing selected set_mario_action resolution/return theorem is used,
    not an assumption that the action request is harmless or always returns. *)
Lemma iio_freefall_request_returns_one : forall version e le m t le' after out,
  e ! IIO._set_mario_action = None ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    iio_yes t le' after out ->
  out = Out_return (Some (Vint Int.one, tuint)) /\
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    iio_request t le' after Out_normal.
Proof.
  intros version e le m t le' after out Hlocal Hrun.
  unfold iio_yes in Hrun.
  destruct (ibk_split_sequence _ _ _ _ iio_request _ _ _ _ _ eq_refl Hrun)
    as (middle & memory & pre & suf & Htrace & Hcall & Hreturn).
  pose proof (ilh_actual_set_action_statement_returns_one version e le m IIO._t'4
    _ pre middle memory Out_normal Hlocal Hcall) as [Htemps _].
  subst middle. inversion Hreturn; subst.
  match goal with Hr : eval_expr _ _ _ _ (Etempvar IIO._t'4 _) ?v |- _ =>
    assert (v = Vint Int.one) by (eapply ocn_temp_value; [exact Hr|apply PTree.gss]); subst v end.
  rewrite E0_right. split; [reflexivity|exact Hcall].
Qed.

Lemma iio_set_off_floor_selects_request :
  forall version e le m mb mo flags t le' after out,
  e ! IIO._set_mario_action = None ->
  le ! IIO._m = Some (Vptr mb mo) ->
  imf_input_load m mb mo = Some (Vint flags) ->
  Int.and flags (Int.repr 4) <> Int.zero ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (iio_guard version) t le' after out ->
  out = Out_return (Some (Vint Int.one, tuint)) /\
  ocn_exec (Clight.globalenv (selected_clight_target version)) e
    (PTree.set IIO._t'16 (Vint flags) le) m iio_request t le' after Out_normal.
Proof.
  intros version e le m mb mo flags t le' after out Hlocal Hm Hload Hset Hrun.
  rewrite (proj1 (proj2 (proj2 (iio_generated_source version)))) in Hrun.
  unfold ilh_input_guard in Hrun.
  destruct (ibk_split_sequence _ _ _ _ (Sset IIO._t'16 imb_input)
    _ _ _ _ _ eq_refl Hrun) as (middle & memory & pre & suf & Htrace & Hread & Hbranch).
  inversion Hread; subst.
  match goal with Hr : eval_expr _ _ _ _ imb_input ?v |- _ =>
    assert (v = Vint flags) by (eapply imb_ushort_field_read;
      [exact Hm|exact (proj2 (imb_control_fields version))|exact Hload|exact Hr]); subst v end.
  inversion Hbranch; subst.
  match goal with Hr : eval_expr ?ge ?env ?temps ?memory (Ebinop Oand _ _ _) ?v |- _ =>
    assert (v = Vint (Int.and flags (Int.repr 4))) by
      (eapply (imf_and_constant_value ge env temps memory IIO._t'16 (Int.repr 4) flags);
        [apply PTree.gss|exact Hr]); subst v end.
  match goal with Hb : bool_val (Vint (Int.and flags (Int.repr 4))) _ _ = Some ?choice |- _ =>
    change (Some (negb (Int.eq (Int.and flags (Int.repr 4)) Int.zero)) = Some choice) in Hb;
    rewrite (Int.eq_false _ _ Hset) in Hb; inversion Hb; subst choice end.
  eapply iio_freefall_request_returns_one; eauto.
Qed.

Definition InkIdleOffFloorTailExclusion : Prop :=
  forall version e le m mb mo flags t le' after out,
  e ! IIO._set_mario_action = None ->
  le ! IIO._m = Some (Vptr mb mo) ->
  imf_input_load m mb mo = Some (Vint flags) ->
  Int.and flags (Int.repr 4) <> Int.zero ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (iio_tail version) t le' after out ->
  out = Out_return (Some (Vint Int.one, tuint)) /\
  ocn_exec (Clight.globalenv (selected_clight_target version)) e
    (PTree.set IIO._t'16 (Vint flags) le) m iio_request t le' after Out_normal.

Theorem iio_off_floor_returns_before_later_idle_controls : InkIdleOffFloorTailExclusion.
Proof.
  intros version e le m mb mo flags t le' after out Hlocal Hm Hload Hset Hrun.
  rewrite (proj1 (proj2 (iio_generated_source version))) in Hrun.
  inversion Hrun; subst.
  all: match goal with Hr : ClightBigstep.exec_stmt _ _ _ _ _ (iio_guard _) _ _ _ _ |- _ =>
    destruct (iio_set_off_floor_selects_request version e le m mb mo flags _ _ _ _
      Hlocal Hm Hload Hset Hr) as [Hout Hrequest] end.
  - discriminate.
  - split; assumption.
Qed.

(** An actually executed prefix may be attached without framing its calls.
    Its final memory supplies the live OFF_FLOOR load used by the tail. *)
Definition InkIdleOffFloorPrefixJoin : Prop :=
  forall version e le m ready ready_m pre mb mo flags t le' after out,
  iap_stage_chain (Clight.globalenv (selected_clight_target version)) e
    le m (iio_prefix version) pre ready ready_m ->
  e ! IIO._set_mario_action = None ->
  ready ! IIO._m = Some (Vptr mb mo) ->
  imf_input_load ready_m mb mo = Some (Vint flags) ->
  Int.and flags (Int.repr 4) <> Int.zero ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e ready ready_m
    (iio_tail version) t le' after out ->
  out = Out_return (Some (Vint Int.one, tuint)) /\
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (fn_body (iio_body version)) (pre ++ t) le' after
    (Out_return (Some (Vint Int.one, tuint))).

Theorem iio_actual_idle_prefix_joins_off_floor_return : InkIdleOffFloorPrefixJoin.
Proof.
  intros version e le m ready ready_m pre mb mo flags t le' after out
    Hprefix Hlocal Hm Hload Hset Hrun.
  destruct (iio_off_floor_returns_before_later_idle_controls version e ready ready_m
    mb mo flags t le' after out Hlocal Hm Hload Hset Hrun) as [Hout _].
  subst out. split; [reflexivity|].
  rewrite (proj1 (iio_generated_source version)).
  eapply imeg_append_stage_chain; eauto.
Qed.

Definition InkIdleOffFloorGuardBoundary : Prop :=
  InkIdleOffFloorTailExclusion /\ InkIdleOffFloorPrefixJoin.
Theorem iio_idle_off_floor_guard_checked : InkIdleOffFloorGuardBoundary.
Proof. split; [exact iio_off_floor_returns_before_later_idle_controls|
  exact iio_actual_idle_prefix_joins_off_floor_return]. Qed.
