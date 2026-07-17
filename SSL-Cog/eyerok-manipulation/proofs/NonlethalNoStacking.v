From Coq Require Import Bool Lia List ZArith.
From SSLEyerok.Proofs Require Import AttackedReboard GeneratedFacts.

Import ListNotations.
Local Open Scope Z_scope.

(** A source-shaped lifecycle for one initialized Eyerok hand, beginning at
    an exposed eye.  The pinned source audit establishes the correspondence
    between these labels and the original handlers.  In particular, it
    checks the one-time health initialization, the sole SHOW_EYE attack
    consumer, the complete recovery graph, the attack-latch overwrite, and
    the RETREAT home-Y guard.

    Heights are relative to [oHomeY].  [nl_impulse_rise] is proof-only ghost
    state: it records upward displacement supplied by the current nonlethal
    +30/-4 impulse.  A floor snap may put the hand at some independently
    raised support, but it cannot add to this impulse budget. *)

Inductive nonlethal_action : Type :=
| NLShowEye
| NLAttacked
| NLRecover
| NLBecomeActive
| NLRetreat
| NLIdle
| NLOpen
| NLClose
| NLOther.

Inductive nonlethal_event : Type :=
| NLWholeUpdateFrozen
| NLAttackLatchRefresh
| NLAcceptNonlethal
| NLAttackedAirMove
| NLAttackedFloorSnap
| NLAttackedGroundMove
| NLAttackedToRecover
| NLRecoverWait
| NLRecoverToBecomeActive
| NLBecomeActiveWait
| NLBecomeActiveToRetreat
| NLRetreatProgress
| NLRetreatToIdleHomeReset
| NLIdleWait
| NLIdleToOpen
| NLIdleToOther
| NLOtherWait
| NLOtherToRetreat
| NLOpenWait
| NLOpenToShowEye
| NLShowEyeToClose
| NLCloseWait
| NLCloseToRetreat
| NLCloseToIdle.

Definition nonlethal_event_eq_dec : forall lhs rhs : nonlethal_event,
  {lhs = rhs} + {lhs <> rhs}.
Proof. decide equality. Defined.

Record nonlethal_state : Type := {
  nl_action : nonlethal_action;
  nl_health : Z;
  nl_y : Z;
  nl_velocity_y : Z;
  nl_gravity : Z;
  nl_grounded : bool;
  nl_attack_latched : bool;
  nl_attacked_age : nat;
  nl_attack_origin_y : Z;
  nl_impulse_rise : Z;
  nl_nonlethal_hits : nat;
  nl_home_reset_owed : bool
}.

(** Health 4 is the post-[obj_set_hitbox] boundary.  The source initializes
    it lazily on the first non-SLEEP [obj_check_attacks] call; the source audit
    proves that this occurs before an attack can be consumed in SHOW_EYE. *)
Definition nonlethal_initial : nonlethal_state :=
  {| nl_action := NLShowEye;
     nl_health := 4;
     nl_y := 0;
     nl_velocity_y := 0;
     nl_gravity := -4;
     nl_grounded := true;
     nl_attack_latched := false;
     nl_attacked_age := O;
     nl_attack_origin_y := 0;
     nl_impulse_rise := 0;
     nl_nonlethal_hits := O;
     nl_home_reset_owed := false |}.

Definition attack_step_rise (age : nat) : Z :=
  match age with
  | O => 26
  | S O => 22
  | S (S O) => 18
  | S (S (S O)) => 14
  | S (S (S (S O))) => 10
  | S (S (S (S (S O)))) => 6
  | S (S (S (S (S (S O))))) => 2
  | _ => 0
  end.

Definition attack_rise_cap (age : nat) : Z :=
  match age with
  | O => 0
  | S O => 26
  | S (S O) => 48
  | S (S (S O)) => 66
  | S (S (S (S O))) => 80
  | S (S (S (S (S O)))) => 90
  | S (S (S (S (S (S O))))) => 96
  | _ => 98
  end.

Lemma attack_step_rise_nonnegative : forall age,
  0 <= attack_step_rise age.
Proof.
  intros [|[|[|[|[|[|[|age]]]]]]]; cbn; lia.
Qed.

Lemma attack_rise_cap_step : forall age,
  attack_rise_cap (S age) =
    attack_rise_cap age + attack_step_rise age.
Proof.
  intros [|[|[|[|[|[|[|age]]]]]]]; reflexivity.
Qed.

Lemma attack_rise_cap_bounded : forall age,
  0 <= attack_rise_cap age <= 98.
Proof.
  intros [|[|[|[|[|[|[|age]]]]]]]; cbn; lia.
Qed.

Lemma attack_velocity_step_le_rise : forall age,
  30 - 4 * Z.of_nat age - 4 <= attack_step_rise age.
Proof.
  intros age.
  destruct age as [|age]; [cbn; lia|]. rewrite Nat2Z.inj_succ.
  destruct age as [|age]; [cbn; lia|]. rewrite Nat2Z.inj_succ.
  destruct age as [|age]; [cbn; lia|]. rewrite Nat2Z.inj_succ.
  destruct age as [|age]; [cbn; lia|]. rewrite Nat2Z.inj_succ.
  destruct age as [|age]; [cbn; lia|]. rewrite Nat2Z.inj_succ.
  destruct age as [|age]; [cbn; lia|]. rewrite Nat2Z.inj_succ.
  destruct age as [|age]; [cbn; lia|]. rewrite Nat2Z.inj_succ.
  cbn [attack_step_rise].
  pose proof (Nat2Z.is_nonneg age). lia.
Qed.

Lemma attack_velocity_after_successor : forall age,
  (30 - 4 * Z.of_nat age) - 4 =
    30 - 4 * Z.of_nat (S age).
Proof.
  intros age. rewrite Nat2Z.inj_succ. lia.
Qed.

Definition nl_refresh_latch
    (fresh : bool) (before : nonlethal_state) : nonlethal_state :=
  {| nl_action := nl_action before;
     nl_health := nl_health before;
     nl_y := nl_y before;
     nl_velocity_y := nl_velocity_y before;
     nl_gravity := nl_gravity before;
     nl_grounded := nl_grounded before;
     nl_attack_latched := fresh;
     nl_attacked_age := nl_attacked_age before;
     nl_attack_origin_y := nl_attack_origin_y before;
     nl_impulse_rise := nl_impulse_rise before;
     nl_nonlethal_hits := nl_nonlethal_hits before;
     nl_home_reset_owed := nl_home_reset_owed before |}.

Definition nl_set_control
    (action : nonlethal_action) (fresh : bool)
    (before : nonlethal_state) : nonlethal_state :=
  {| nl_action := action;
     nl_health := nl_health before;
     nl_y := nl_y before;
     nl_velocity_y := nl_velocity_y before;
     nl_gravity := nl_gravity before;
     nl_grounded := nl_grounded before;
     nl_attack_latched := fresh;
     nl_attacked_age := nl_attacked_age before;
     nl_attack_origin_y := nl_attack_origin_y before;
     nl_impulse_rise := nl_impulse_rise before;
     nl_nonlethal_hits := nl_nonlethal_hits before;
     nl_home_reset_owed := nl_home_reset_owed before |}.

Definition nl_set_motion
    (action : nonlethal_action) (y velocity gravity : Z)
    (grounded fresh : bool) (before : nonlethal_state)
    : nonlethal_state :=
  {| nl_action := action;
     nl_health := nl_health before;
     nl_y := y;
     nl_velocity_y := velocity;
     nl_gravity := gravity;
     nl_grounded := grounded;
     nl_attack_latched := fresh;
     nl_attacked_age := nl_attacked_age before;
     nl_attack_origin_y := nl_attack_origin_y before;
     nl_impulse_rise := nl_impulse_rise before;
     nl_nonlethal_hits := nl_nonlethal_hits before;
     nl_home_reset_owed := nl_home_reset_owed before |}.

Definition nl_accept_state (before : nonlethal_state) : nonlethal_state :=
  {| nl_action := NLAttacked;
     nl_health := nl_health before - 1;
     nl_y := nl_y before;
     nl_velocity_y := 30;
     nl_gravity := -4;
     nl_grounded := false;
     nl_attack_latched := nl_attack_latched before;
     nl_attacked_age := O;
     nl_attack_origin_y := nl_y before;
     nl_impulse_rise := 0;
     nl_nonlethal_hits := S (nl_nonlethal_hits before);
     nl_home_reset_owed := true |}.

Definition nl_air_move_state
    (fresh : bool) (before : nonlethal_state) : nonlethal_state :=
  let next_velocity := nl_velocity_y before - 4 in
  {| nl_action := NLAttacked;
     nl_health := nl_health before;
     nl_y := nl_y before + next_velocity;
     nl_velocity_y := next_velocity;
     nl_gravity := -4;
     nl_grounded := false;
     nl_attack_latched := fresh;
     nl_attacked_age := S (nl_attacked_age before);
     nl_attack_origin_y := nl_attack_origin_y before;
     nl_impulse_rise :=
       nl_impulse_rise before + attack_step_rise (nl_attacked_age before);
     nl_nonlethal_hits := nl_nonlethal_hits before;
     nl_home_reset_owed := true |}.

Definition nl_floor_snap_state
    (floor_y : Z) (fresh : bool) (before : nonlethal_state)
    : nonlethal_state :=
  {| nl_action := NLAttacked;
     nl_health := nl_health before;
     nl_y := floor_y;
     nl_velocity_y := 0;
     nl_gravity := -4;
     nl_grounded := true;
     nl_attack_latched := fresh;
     nl_attacked_age := S (nl_attacked_age before);
     nl_attack_origin_y := nl_attack_origin_y before;
     nl_impulse_rise := nl_impulse_rise before;
     nl_nonlethal_hits := nl_nonlethal_hits before;
     nl_home_reset_owed := true |}.

Definition nl_ground_move_state
    (fresh : bool) (before : nonlethal_state) : nonlethal_state :=
  {| nl_action := NLAttacked;
     nl_health := nl_health before;
     nl_y := nl_y before;
     nl_velocity_y := 0;
     nl_gravity := -4;
     nl_grounded := true;
     nl_attack_latched := fresh;
     nl_attacked_age := S (nl_attacked_age before);
     nl_attack_origin_y := nl_attack_origin_y before;
     nl_impulse_rise := nl_impulse_rise before;
     nl_nonlethal_hits := nl_nonlethal_hits before;
     nl_home_reset_owed := true |}.

Definition nl_home_reset_state
    (fresh : bool) (before : nonlethal_state) : nonlethal_state :=
  {| nl_action := NLIdle;
     nl_health := nl_health before;
     nl_y := 0;
     nl_velocity_y := nl_velocity_y before;
     nl_gravity := nl_gravity before;
     nl_grounded := nl_grounded before;
     nl_attack_latched := fresh;
     nl_attacked_age := nl_attacked_age before;
     nl_attack_origin_y := nl_attack_origin_y before;
     nl_impulse_rise := nl_impulse_rise before;
     nl_nonlethal_hits := nl_nonlethal_hits before;
     nl_home_reset_owed := false |}.

Inductive nonlethal_step
    : nonlethal_state -> nonlethal_event -> nonlethal_state -> Prop :=
| nl_step_frozen : forall state,
    nonlethal_step state NLWholeUpdateFrozen state
| nl_step_refresh : forall before fresh,
    nonlethal_step before NLAttackLatchRefresh
      (nl_refresh_latch fresh before)
| nl_step_accept : forall before,
    nl_action before = NLShowEye ->
    nl_attack_latched before = true ->
    3 <= nl_health before ->
    nonlethal_step before NLAcceptNonlethal (nl_accept_state before)
| nl_step_attacked_air : forall before fresh,
    nl_action before = NLAttacked ->
    nl_grounded before = false ->
    (nl_attacked_age before < 25)%nat ->
    nonlethal_step before NLAttackedAirMove
      (nl_air_move_state fresh before)
| nl_step_attacked_snap : forall before floor_y fresh,
    nl_action before = NLAttacked ->
    nl_grounded before = false ->
    (nl_attacked_age before < 25)%nat ->
    nonlethal_step before NLAttackedFloorSnap
      (nl_floor_snap_state floor_y fresh before)
| nl_step_attacked_ground : forall before fresh,
    nl_action before = NLAttacked ->
    nl_grounded before = true ->
    (nl_attacked_age before < 25)%nat ->
    nonlethal_step before NLAttackedGroundMove
      (nl_ground_move_state fresh before)
| nl_step_attacked_recover : forall before fresh,
    nl_action before = NLAttacked ->
    nl_attacked_age before = 25%nat ->
    nonlethal_step before NLAttackedToRecover
      (nl_set_control NLRecover fresh before)
| nl_step_recover_wait : forall before y velocity grounded fresh,
    nl_action before = NLRecover ->
    velocity <= 0 ->
    nonlethal_step before NLRecoverWait
      (nl_set_motion NLRecover y velocity (-4) grounded fresh before)
| nl_step_recover_become : forall before fresh,
    nl_action before = NLRecover ->
    nonlethal_step before NLRecoverToBecomeActive
      (nl_set_control NLBecomeActive fresh before)
| nl_step_become_wait : forall before y velocity grounded fresh,
    nl_action before = NLBecomeActive ->
    velocity <= 0 ->
    nonlethal_step before NLBecomeActiveWait
      (nl_set_motion NLBecomeActive y velocity (-4) grounded fresh before)
| nl_step_become_retreat : forall before fresh,
    nl_action before = NLBecomeActive ->
    nonlethal_step before NLBecomeActiveToRetreat
      (nl_set_control NLRetreat fresh before)
| nl_step_retreat_progress : forall before y velocity gravity grounded fresh,
    nl_action before = NLRetreat ->
    velocity <= 0 ->
    nonlethal_step before NLRetreatProgress
      (nl_set_motion NLRetreat y velocity gravity grounded fresh before)
| nl_step_retreat_idle : forall before fresh,
    nl_action before = NLRetreat ->
    nl_velocity_y before <= 0 ->
    nonlethal_step before NLRetreatToIdleHomeReset
      (nl_home_reset_state fresh before)
| nl_step_idle_wait : forall before y velocity gravity grounded fresh,
    nl_action before = NLIdle ->
    nl_home_reset_owed before = false ->
    velocity <= 0 ->
    nonlethal_step before NLIdleWait
      (nl_set_motion NLIdle y velocity gravity grounded fresh before)
| nl_step_idle_open : forall before fresh,
    nl_action before = NLIdle ->
    nl_home_reset_owed before = false ->
    nonlethal_step before NLIdleToOpen
      (nl_set_control NLOpen fresh before)
| nl_step_idle_other : forall before y velocity gravity grounded fresh,
    nl_action before = NLIdle ->
    nl_home_reset_owed before = false ->
    nonlethal_step before NLIdleToOther
      (nl_set_motion NLOther y velocity gravity grounded fresh before)
| nl_step_other_wait : forall before y velocity gravity grounded fresh,
    nl_action before = NLOther ->
    nl_home_reset_owed before = false ->
    nonlethal_step before NLOtherWait
      (nl_set_motion NLOther y velocity gravity grounded fresh before)
| nl_step_other_retreat : forall before y velocity gravity grounded fresh,
    nl_action before = NLOther ->
    nl_home_reset_owed before = false ->
    velocity <= 0 ->
    nonlethal_step before NLOtherToRetreat
      (nl_set_motion NLRetreat y velocity gravity grounded fresh before)
| nl_step_open_wait : forall before y velocity gravity grounded fresh,
    nl_action before = NLOpen ->
    nl_home_reset_owed before = false ->
    velocity <= 0 ->
    nonlethal_step before NLOpenWait
      (nl_set_motion NLOpen y velocity gravity grounded fresh before)
| nl_step_open_show_eye : forall before y velocity gravity grounded fresh,
    nl_action before = NLOpen ->
    nl_home_reset_owed before = false ->
    velocity <= 0 ->
    nonlethal_step before NLOpenToShowEye
      (nl_set_motion NLShowEye y velocity gravity grounded fresh before)
| nl_step_show_eye_close : forall before fresh,
    nl_action before = NLShowEye ->
    nl_home_reset_owed before = false ->
    nonlethal_step before NLShowEyeToClose
      (nl_set_control NLClose fresh before)
| nl_step_close_wait : forall before y velocity gravity grounded fresh,
    nl_action before = NLClose ->
    nl_home_reset_owed before = false ->
    velocity <= 0 ->
    nonlethal_step before NLCloseWait
      (nl_set_motion NLClose y velocity gravity grounded fresh before)
| nl_step_close_retreat : forall before fresh,
    nl_action before = NLClose ->
    nl_home_reset_owed before = false ->
    nl_velocity_y before <= 0 ->
    nonlethal_step before NLCloseToRetreat
      (nl_set_control NLRetreat fresh before)
| nl_step_close_idle : forall before fresh,
    nl_action before = NLClose ->
    nl_home_reset_owed before = false ->
    nonlethal_step before NLCloseToIdle
      (nl_set_control NLIdle fresh before).

Definition owed_action (action : nonlethal_action) : Prop :=
  action = NLAttacked \/ action = NLRecover \/
  action = NLBecomeActive \/ action = NLRetreat.

Definition attacked_shape (state : nonlethal_state) : Prop :=
  (nl_attacked_age state <= 25)%nat /\
  0 <= nl_impulse_rise state <=
    attack_rise_cap (nl_attacked_age state) /\
  nl_gravity state = -4 /\
  (nl_grounded state = true -> nl_velocity_y state = 0) /\
  (nl_grounded state = false ->
    nl_velocity_y state =
      30 - 4 * Z.of_nat (nl_attacked_age state) /\
    nl_y state <= nl_attack_origin_y state + nl_impulse_rise state).

Definition nonlethal_safe (state : nonlethal_state) : Prop :=
  2 <= nl_health state <= 4 /\
  nl_health state + Z.of_nat (nl_nonlethal_hits state) = 4 /\
  (nl_nonlethal_hits state <= 2)%nat /\
  (nl_home_reset_owed state = true -> owed_action (nl_action state)) /\
  (nl_action state = NLShowEye -> nl_home_reset_owed state = false).

Lemma nonlethal_initial_safe : nonlethal_safe nonlethal_initial.
Proof.
  unfold nonlethal_safe, nonlethal_initial, owed_action.
  cbn. repeat split; try discriminate; lia.
Qed.

Theorem nonlethal_step_preserves_safe : forall before event after,
  nonlethal_safe before ->
  nonlethal_step before event after ->
  nonlethal_safe after.
Proof.
  intros before event after Hsafe Hstep.
  destruct Hsafe as (Hhealth & Hcount & Hhits & Howed & Hshow).
  destruct Hstep; subst; unfold nonlethal_safe in *;
    unfold nl_refresh_latch, nl_set_control, nl_set_motion,
      nl_accept_state, nl_air_move_state, nl_floor_snap_state,
      nl_ground_move_state, nl_home_reset_state in *; cbn in *.
  all: repeat split; try assumption; try congruence; try lia;
    try (intros _; unfold owed_action; tauto);
    try (intros Hbad; discriminate).
Qed.

Inductive nonlethal_reachable : nonlethal_state -> Prop :=
| nl_reachable_initial : nonlethal_reachable nonlethal_initial
| nl_reachable_step : forall before event after,
    nonlethal_reachable before ->
    nonlethal_step before event after ->
    nonlethal_reachable after.

Theorem every_nonlethal_reachable_state_safe : forall state,
  nonlethal_reachable state -> nonlethal_safe state.
Proof.
  intros state Hreach. induction Hreach.
  - exact nonlethal_initial_safe.
  - eapply nonlethal_step_preserves_safe; eauto.
Qed.

Theorem every_reachable_attacked_state_has_source_shape : forall state,
  nonlethal_reachable state ->
  nl_action state = NLAttacked ->
  attacked_shape state.
Proof.
  intros state Hreach.
  induction Hreach as
      [|before event after Hbefore IH Hstep]; intros Haction.
  - discriminate.
  - destruct Hstep; subst; cbn in Haction; try discriminate.
    + apply IH. exact Haction.
    + apply IH. exact Haction.
    + unfold attacked_shape, nl_accept_state. cbn.
      repeat split; try reflexivity; lia.
    + specialize (IH H) as
        (Hage & Hrise & Hgravity & Hground & Hair).
      specialize (Hair H0) as (Hvelocity & Hy).
      unfold attacked_shape, nl_air_move_state. cbn.
      repeat split; try reflexivity; try lia.
      * pose proof (attack_step_rise_nonnegative
          (nl_attacked_age before)). lia.
      * change
          (nl_impulse_rise before +
             attack_step_rise (nl_attacked_age before) <=
           attack_rise_cap (S (nl_attacked_age before))).
        rewrite attack_rise_cap_step. lia.
      * change
          (nl_velocity_y before - 4 =
           30 - 4 * Z.of_nat (S (nl_attacked_age before))).
        rewrite Hvelocity. apply attack_velocity_after_successor.
      * pose proof (attack_velocity_step_le_rise
          (nl_attacked_age before)).
        rewrite Hvelocity. lia.
    + specialize (IH H) as
        (Hage & Hrise & Hgravity & Hground & Hair).
      unfold attacked_shape, nl_floor_snap_state. cbn.
      repeat split; try reflexivity; try lia.
      change
        (nl_impulse_rise before <=
         attack_rise_cap (S (nl_attacked_age before))).
      rewrite attack_rise_cap_step.
      pose proof (attack_step_rise_nonnegative
        (nl_attacked_age before)). lia.
    + specialize (IH H) as
        (Hage & Hrise & Hgravity & Hground & Hair).
      unfold attacked_shape, nl_ground_move_state. cbn.
      repeat split; try reflexivity; try lia.
      change
        (nl_impulse_rise before <=
         attack_rise_cap (S (nl_attacked_age before))).
      rewrite attack_rise_cap_step.
      pose proof (attack_step_rise_nonnegative
        (nl_attacked_age before)). lia.
Qed.

Inductive nonlethal_run
    : nonlethal_state -> list nonlethal_event -> nonlethal_state -> Prop :=
| nl_run_nil : forall state, nonlethal_run state [] state
| nl_run_cons : forall before event middle events after,
    nonlethal_step before event middle ->
    nonlethal_run middle events after ->
    nonlethal_run before (event :: events) after.

Lemma nonlethal_run_preserves_reachable : forall before events after,
  nonlethal_reachable before ->
  nonlethal_run before events after ->
  nonlethal_reachable after.
Proof.
  intros before events after Hreach Hrun.
  induction Hrun.
  - exact Hreach.
  - apply IHHrun. eapply nl_reachable_step; eauto.
Qed.

Lemma owed_step_without_home_reset_remains_owed : forall before event after,
  nl_home_reset_owed before = true ->
  nonlethal_step before event after ->
  event <> NLRetreatToIdleHomeReset ->
  nl_home_reset_owed after = true.
Proof.
  intros before event after Howed Hstep Hnotreset.
  destruct Hstep; cbn in *; try assumption; try congruence.
Qed.

Theorem owed_run_to_show_eye_contains_home_reset :
  forall before events after,
    nonlethal_reachable before ->
    nl_home_reset_owed before = true ->
    nonlethal_run before events after ->
    nl_action after = NLShowEye ->
    In NLRetreatToIdleHomeReset events.
Proof.
  intros before events after Hreach Howed Hrun.
  induction Hrun as
      [state | state event middle events final Hstep Hrun IH]; intros Hshow.
  - pose proof (every_nonlethal_reachable_state_safe state Hreach) as Hsafe.
    destruct Hsafe as (_ & _ & _ & Howed_action & Hshow_clear).
    specialize (Hshow_clear Hshow). congruence.
  - destruct (nonlethal_event_eq_dec event NLRetreatToIdleHomeReset) as
      [Hevent | Hevent].
    + subst event. cbn. tauto.
    + right. apply IH.
      * eapply nl_reachable_step; eauto.
      * eapply owed_step_without_home_reset_remains_owed; eauto.
      * exact Hshow.
Qed.

Theorem accepted_nonlethal_starts_only_in_show_eye : forall before after,
  nonlethal_step before NLAcceptNonlethal after ->
  nl_action before = NLShowEye /\
  nl_attack_latched before = true /\
  3 <= nl_health before /\
  nl_action after = NLAttacked /\
  nl_health after = nl_health before - 1 /\
  nl_velocity_y after = 30 /\
  nl_gravity after = -4 /\
  nl_attack_origin_y after = nl_y before /\
  nl_home_reset_owed after = true.
Proof.
  intros before after Hstep. inversion Hstep; subst.
  unfold nl_accept_state. cbn. repeat split; assumption || reflexivity.
Qed.

Theorem successive_nonlethal_accepts_have_home_reset_between :
  forall first after_first events second after_second,
    nonlethal_reachable first ->
    nonlethal_step first NLAcceptNonlethal after_first ->
    nonlethal_run after_first events second ->
    nonlethal_step second NLAcceptNonlethal after_second ->
    In NLRetreatToIdleHomeReset events.
Proof.
  intros first after_first events second after_second
    Hreach Hfirst Hrun Hsecond.
  destruct (accepted_nonlethal_starts_only_in_show_eye
    first after_first Hfirst) as (_ & _ & _ & _ & _ & _ & _ & _ & Howed).
  destruct (accepted_nonlethal_starts_only_in_show_eye
    second after_second Hsecond) as (Hshow & _).
  eapply owed_run_to_show_eye_contains_home_reset.
  - eapply nl_reachable_step; eauto.
  - exact Howed.
  - exact Hrun.
  - exact Hshow.
Qed.

Theorem home_reset_event_reaches_exact_home_with_nonpositive_velocity :
  forall before after,
    nonlethal_reachable before ->
    nonlethal_step before NLRetreatToIdleHomeReset after ->
    nl_action before = NLRetreat /\
    nl_velocity_y before <= 0 /\
    nl_action after = NLIdle /\
    nl_y after = 0 /\
    nl_velocity_y after <= 0 /\
    nl_home_reset_owed after = false.
Proof.
  intros before after _ Hstep. inversion Hstep; subst.
  unfold nl_home_reset_state. cbn. repeat split; assumption || reflexivity.
Qed.

Theorem reachable_nonlethal_impulse_is_bounded : forall state,
  nonlethal_reachable state ->
  nl_action state = NLAttacked ->
  0 <= nl_impulse_rise state <= 98.
Proof.
  intros state Hreach Haction.
  destruct (every_reachable_attacked_state_has_source_shape
    state Hreach Haction) as (_ & Hrise & _).
  pose proof (attack_rise_cap_bounded (nl_attacked_age state)). lia.
Qed.

Theorem airborne_nonlethal_height_is_origin_plus_at_most_98 : forall state,
  nonlethal_reachable state ->
  nl_action state = NLAttacked ->
  nl_grounded state = false ->
  nl_y state <= nl_attack_origin_y state + 98.
Proof.
  intros state Hreach Haction Hairborne.
  destruct (every_reachable_attacked_state_has_source_shape
    state Hreach Haction) as (_ & Hrise & _ & _ & Hair).
  destruct (Hair Hairborne) as (_ & Hy).
  pose proof (attack_rise_cap_bounded (nl_attacked_age state)). lia.
Qed.

Theorem at_most_two_nonlethal_accepts_per_hand : forall state,
  nonlethal_reachable state ->
  (nl_nonlethal_hits state <= 2)%nat.
Proof.
  intros state Hreach.
  destruct (every_nonlethal_reachable_state_safe state Hreach)
    as (_ & _ & Hhits & _). exact Hhits.
Qed.

Lemma audited_health_branch_values :
  4 - 1 = 3 /\ 3 - 1 = 2 /\ 2 - 1 = 1 /\
  3 >= 2 /\ 2 >= 2 /\ 1 < 2.
Proof. repeat split; lia. Qed.

Definition nonlethal_no_stacking_certificate : Prop :=
  generated_nonlethal_lifecycle_shape /\
  (forall before after,
      nonlethal_step before NLAcceptNonlethal after ->
      nl_action before = NLShowEye /\
      nl_attack_latched before = true /\
      3 <= nl_health before /\
      nl_action after = NLAttacked /\
      nl_health after = nl_health before - 1 /\
      nl_velocity_y after = 30 /\
      nl_gravity after = -4 /\
      nl_attack_origin_y after = nl_y before /\
      nl_home_reset_owed after = true) /\
  (forall first after_first events second after_second,
      nonlethal_reachable first ->
      nonlethal_step first NLAcceptNonlethal after_first ->
      nonlethal_run after_first events second ->
      nonlethal_step second NLAcceptNonlethal after_second ->
      In NLRetreatToIdleHomeReset events) /\
  (forall before after,
      nonlethal_reachable before ->
      nonlethal_step before NLRetreatToIdleHomeReset after ->
      nl_action before = NLRetreat /\
      nl_velocity_y before <= 0 /\
      nl_action after = NLIdle /\
      nl_y after = 0 /\
      nl_velocity_y after <= 0 /\
      nl_home_reset_owed after = false) /\
  (forall state,
      nonlethal_reachable state ->
      nl_action state = NLAttacked ->
      0 <= nl_impulse_rise state <= 98) /\
  (forall state,
      nonlethal_reachable state ->
      nl_action state = NLAttacked ->
      nl_grounded state = false ->
      nl_y state <= nl_attack_origin_y state + 98) /\
  (forall state,
      nonlethal_reachable state ->
      (nl_nonlethal_hits state <= 2)%nat) /\
  last nonlethal_complete_origin_trace 0 = 0 /\
  (4 - 1 = 3 /\ 3 - 1 = 2 /\ 2 - 1 = 1 /\
   3 >= 2 /\ 2 >= 2 /\ 1 < 2).

Theorem nonlethal_no_stacking_certificate_holds :
  nonlethal_no_stacking_certificate.
Proof.
  unfold nonlethal_no_stacking_certificate.
  refine (conj generated_nonlethal_lifecycle_shape_holds _).
  refine (conj accepted_nonlethal_starts_only_in_show_eye _).
  refine (conj successive_nonlethal_accepts_have_home_reset_between _).
  refine (conj home_reset_event_reaches_exact_home_with_nonpositive_velocity _).
  refine (conj reachable_nonlethal_impulse_is_bounded _).
  refine (conj airborne_nonlethal_height_is_origin_plus_at_most_98 _).
  refine (conj at_most_two_nonlethal_accepts_per_hand _).
  refine (conj nonlethal_complete_origin_trace_ends_at_home _).
  exact audited_health_branch_values.
Qed.
