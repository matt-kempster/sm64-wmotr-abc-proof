From Coq Require Import Bool Lia ZArith.

Local Open Scope Z_scope.

(** This finite kernel isolates the fields that guard Eyerok's only positive
    100-unit write.  Its events over-approximate boss choices, random choices,
    and player-dependent branch choices; invalid events stutter.

    [a_down] is intentionally a ghost input: the audited Eyerok hand functions
    never read Mario's A button.  Quantifying over it shows that changing only
    A cannot change this hand-control result.  It is not a controller-accurate
    model of Mario or of ABC press counting. *)

Inductive kernel_action : Type :=
| KernelIdle
| KernelBeginDouble
| KernelDouble
| KernelOther.

Inductive kernel_gravity : Type :=
| GravityZero
| GravityNeg4
| GravityNeg15
| GravityNeg20.

Inductive kernel_event : Type :=
| EventStutter
| EventStartDouble
| EventEnterDouble
| EventFirstDescentAir
| EventFirstDescentLand
| EventLand
| EventPound
| EventLaunch100
| EventExit
| EventNormalize.

Record kernel_state : Type := {
  kernel_action_of : kernel_action;
  kernel_gravity_of : kernel_gravity;
  kernel_grounded : bool;
  kernel_position_y : Z;
  kernel_floor_y : Z
}.

Definition kernel_initial : kernel_state :=
  {| kernel_action_of := KernelIdle;
     kernel_gravity_of := GravityZero;
     kernel_grounded := true;
     kernel_position_y := 0;
     kernel_floor_y := 0 |}.

(** The source integrates velocity and gravity before testing the strict
    [new_y < floor_y] grounding condition. *)
Definition strict_ground_after_move
    (position_y floor_y velocity_y gravity : Z) : bool :=
  Z.ltb (position_y + velocity_y + gravity) floor_y.

Lemma zero_motion_at_or_above_floor_clears_ground :
  forall position_y floor_y,
    floor_y <= position_y ->
    strict_ground_after_move position_y floor_y 0 0 = false.
Proof.
  intros position_y floor_y Hfloor.
  unfold strict_ground_after_move.
  apply Z.ltb_ge.
  lia.
Qed.

Definition nonstrict_ground_after_move
    (position_y floor_y velocity_y gravity : Z) : bool :=
  Z.leb (position_y + velocity_y + gravity) floor_y.

Lemma nonstrict_ground_test_keeps_equality_grounded :
  nonstrict_ground_after_move 0 0 0 0 = true.
Proof. reflexivity. Qed.

(** Eyerok has bounciness zero.  A hand that carried a ground bit into the
    idle handler therefore has zero vertical velocity after the preceding
    collision response.  The separate source/geometry audit establishes that
    no newly selected floor is above the hand in the begin-double corridor.
    This function models the actual zero-velocity end-of-frame comparison; it
    does not assign the resulting ground bit by fiat. *)
Definition zero_velocity_source_move
    (next_action : kernel_action) (before : kernel_state) : kernel_state :=
  {| kernel_action_of := next_action;
     kernel_gravity_of := GravityZero;
     kernel_grounded := strict_ground_after_move
       (kernel_position_y before) (kernel_floor_y before) 0 0;
     kernel_position_y := kernel_position_y before;
     kernel_floor_y := kernel_floor_y before |}.

Definition kernel_step
    (_a_down : bool) (event : kernel_event) (before : kernel_state)
    : kernel_state :=
  match event,
        kernel_action_of before,
        kernel_gravity_of before,
        kernel_grounded before with
  | EventStartDouble, KernelIdle, _, _ =>
      zero_velocity_source_move KernelBeginDouble before
  | EventEnterDouble, KernelBeginDouble, GravityZero, _ =>
      zero_velocity_source_move KernelDouble before
  | EventFirstDescentAir, KernelDouble, GravityZero, false =>
      {| kernel_action_of := KernelDouble;
         kernel_gravity_of := GravityNeg20;
         kernel_grounded := false;
         kernel_position_y := kernel_position_y before;
         kernel_floor_y := kernel_floor_y before |}
  | EventFirstDescentLand, KernelDouble, GravityZero, false =>
      {| kernel_action_of := KernelDouble;
         kernel_gravity_of := GravityNeg20;
         kernel_grounded := true;
         kernel_position_y := kernel_floor_y before;
         kernel_floor_y := kernel_floor_y before |}
  | EventLand, KernelDouble, GravityNeg20, false =>
      {| kernel_action_of := KernelDouble;
         kernel_gravity_of := GravityNeg20;
         kernel_grounded := true;
         kernel_position_y := kernel_floor_y before;
         kernel_floor_y := kernel_floor_y before |}
  | EventLand, KernelDouble, GravityNeg15, false =>
      {| kernel_action_of := KernelDouble;
         kernel_gravity_of := GravityNeg15;
         kernel_grounded := true;
         kernel_position_y := kernel_floor_y before;
         kernel_floor_y := kernel_floor_y before |}
  | EventPound, KernelDouble, GravityNeg20, true =>
      {| kernel_action_of := KernelDouble;
         kernel_gravity_of := GravityNeg15;
         kernel_grounded := true;
         kernel_position_y := kernel_floor_y before;
         kernel_floor_y := kernel_floor_y before |}
  | EventLaunch100, KernelDouble, GravityZero, true =>
      {| kernel_action_of := KernelDouble;
         kernel_gravity_of := GravityZero;
         kernel_grounded := false;
         kernel_position_y := kernel_position_y before + 100;
         kernel_floor_y := kernel_floor_y before |}
  | EventLaunch100, KernelDouble, GravityNeg15, true =>
      {| kernel_action_of := KernelDouble;
         kernel_gravity_of := GravityNeg15;
         kernel_grounded := false;
         kernel_position_y := kernel_position_y before + 85;
         kernel_floor_y := kernel_floor_y before |}
  | EventExit, _, gravity, grounded =>
      {| kernel_action_of := KernelOther;
         kernel_gravity_of := gravity;
         kernel_grounded := grounded;
         kernel_position_y := kernel_position_y before;
         kernel_floor_y := kernel_floor_y before |}
  | EventNormalize, KernelOther, _, _ => kernel_initial
  | _, _, _, _ => before
  end.

Definition zero_move_floor_ready (state : kernel_state) : Prop :=
  kernel_floor_y state <= kernel_position_y state.

Definition kernel_safe (state : kernel_state) : Prop :=
  (kernel_action_of state = KernelIdle -> zero_move_floor_ready state) /\
  (kernel_action_of state = KernelBeginDouble ->
   kernel_gravity_of state = GravityZero /\
   zero_move_floor_ready state /\
   kernel_grounded state = false) /\
  (kernel_action_of state = KernelDouble ->
   kernel_gravity_of state = GravityZero ->
   kernel_grounded state = false) /\
  (kernel_action_of state = KernelDouble ->
   kernel_grounded state = true ->
   kernel_gravity_of state = GravityNeg15 \/
   kernel_gravity_of state = GravityNeg20).

Definition gravity_zero_runaway_seed (state : kernel_state) : Prop :=
  kernel_action_of state = KernelDouble /\
  kernel_gravity_of state = GravityZero /\
  kernel_grounded state = true.

Lemma kernel_initial_safe : kernel_safe kernel_initial.
Proof.
  repeat split; intros; try discriminate.
Qed.

Lemma zero_velocity_source_move_safe_ground :
  forall action before,
    zero_move_floor_ready before ->
    kernel_grounded (zero_velocity_source_move action before) = false.
Proof.
  intros action before Hready.
  apply zero_motion_at_or_above_floor_clears_ground.
  exact Hready.
Qed.

Theorem kernel_step_preserves_safe :
  forall a_down event before,
    kernel_safe before ->
    kernel_safe (kernel_step a_down event before).
Proof.
  intros a_down event [action gravity grounded position_y floor_y] Hsafe.
  unfold kernel_safe, zero_move_floor_ready in *; cbn in *.
  destruct Hsafe as (Hidle & Hbegin & Hzero & Hground).
  destruct event, action, gravity, grounded; cbn in *;
    repeat split; intros; try discriminate; try assumption; try reflexivity;
    try (apply zero_motion_at_or_above_floor_clears_ground; firstorder);
    try lia; try (firstorder congruence).
  assert (Hready : floor_y <= position_y) by firstorder.
  pose proof (zero_motion_at_or_above_floor_clears_ground
    position_y floor_y Hready) as Hclear.
  congruence.
Qed.

Inductive kernel_reachable (a_policy : nat -> bool)
    : nat -> kernel_state -> Prop :=
| kernel_reachable_initial :
    kernel_reachable a_policy O kernel_initial
| kernel_reachable_step : forall frame before event,
    kernel_reachable a_policy frame before ->
    kernel_reachable a_policy (S frame)
      (kernel_step (a_policy frame) event before).

Theorem every_kernel_reachable_state_safe :
  forall a_policy frame state,
    kernel_reachable a_policy frame state ->
    kernel_safe state.
Proof.
  intros a_policy frame state Hreach.
  induction Hreach.
  - exact kernel_initial_safe.
  - apply kernel_step_preserves_safe.
    exact IHHreach.
Qed.

Theorem no_player_policy_reaches_gravity_zero_runaway_seed :
  forall a_policy frame state,
    kernel_reachable a_policy frame state ->
    ~ gravity_zero_runaway_seed state.
Proof.
  intros a_policy frame state Hreach (Haction & Hgravity & Hgrounded).
  destruct (every_kernel_reachable_state_safe
    a_policy frame state Hreach) as (_ & _ & Hzero & _).
  specialize (Hzero Haction Hgravity).
  rewrite Hgrounded in Hzero.
  discriminate.
Qed.

Definition never_press_a (_ : nat) : bool := false.
Definition continuously_hold_a (_ : nat) : bool := true.

Corollary no_a_run_cannot_reach_runaway_seed :
  forall frame state,
    kernel_reachable never_press_a frame state ->
    ~ gravity_zero_runaway_seed state.
Proof. exact (no_player_policy_reaches_gravity_zero_runaway_seed never_press_a). Qed.

Corollary held_a_run_cannot_reach_runaway_seed :
  forall frame state,
    kernel_reachable continuously_hold_a frame state ->
    ~ gravity_zero_runaway_seed state.
Proof.
  exact (no_player_policy_reaches_gravity_zero_runaway_seed
    continuously_hold_a).
Qed.

(** Sensitivity model.  If movement/ground clearing can stutter across the two
    action changes, the stale ground bit survives and the seed is reached by
    an actual two-step trace. *)
Definition weak_step_without_ground_clear
    (event : kernel_event) (before : kernel_state) : kernel_state :=
  match event, kernel_action_of before with
  | EventStartDouble, KernelIdle =>
      {| kernel_action_of := KernelBeginDouble;
         kernel_gravity_of := GravityZero;
         kernel_grounded := kernel_grounded before;
         kernel_position_y := kernel_position_y before;
         kernel_floor_y := kernel_floor_y before |}
  | EventEnterDouble, KernelBeginDouble =>
      {| kernel_action_of := KernelDouble;
         kernel_gravity_of := kernel_gravity_of before;
         kernel_grounded := kernel_grounded before;
         kernel_position_y := kernel_position_y before;
         kernel_floor_y := kernel_floor_y before |}
  | _, _ => before
  end.

Definition weak_after_start : kernel_state :=
  weak_step_without_ground_clear EventStartDouble kernel_initial.

Definition weak_after_enter : kernel_state :=
  weak_step_without_ground_clear EventEnterDouble weak_after_start.

Theorem omitting_strict_clear_exposes_the_seed_in_two_steps :
  weak_after_start =
    weak_step_without_ground_clear EventStartDouble kernel_initial /\
  weak_after_enter =
    weak_step_without_ground_clear EventEnterDouble weak_after_start /\
  gravity_zero_runaway_seed weak_after_enter.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem replacing_strict_with_nonstrict_exposes_the_same_two_step_seed :
  nonstrict_ground_after_move 0 0 0 0 = true /\
  gravity_zero_runaway_seed weak_after_enter.
Proof.
  split.
  - exact nonstrict_ground_test_keeps_equality_grounded.
  - vm_compute. repeat split; reflexivity.
Qed.
