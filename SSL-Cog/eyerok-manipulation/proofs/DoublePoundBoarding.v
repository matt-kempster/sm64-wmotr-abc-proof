From Coq Require Import Bool Lia List ZArith.
From SSLEyerok.Proofs Require Import HeightMilestones MarioHandContact
  RouteModel.

Import ListNotations.
Local Open Scope Z_scope.

(** A source-audited vertical model of the first normal DOUBLE_POUND rise.
    The hand object moves before Mario.  Direct platform displacement does
    not add the hand's Y velocity to Mario, and an air step performs four
    quarter-step floor queries before applying gravity.

    This module proves the resulting vertical arithmetic and A-input
    classification.  It deliberately assumes the ordinary central X/Z
    witness established by the source audit; it is not, by itself, a linked
    Clight refinement or a proof that Mario can first reach that witness. *)

Definition double_pound_first_rise : Z := 85.
Definition prelaunch_vertical_impulse : Z := 20.
Definition first_wait_frame_vertical_velocity : Z := 16.
Definition launch_frame_vertical_velocity : Z := 12.
Definition air_quarters_per_frame : Z := 4.
Definition first_air_quarter_displacement : Z :=
  launch_frame_vertical_velocity / air_quarters_per_frame.

Record boarding_vertical_state : Type := {
  boarding_hand_top_y : Z;
  boarding_mario_y : Z;
  boarding_mario_vy : Z
}.

Definition standing_on_hand (origin : Z) : boarding_vertical_state :=
  {| boarding_hand_top_y := origin;
     boarding_mario_y := origin;
     boarding_mario_vy := 0 |}.

(** The authenticated US-ROM schedule enters the launch action early enough
    for two complete Mario updates before the hand's +85 update.  The action
    entry frame moves Mario by +20 and leaves velocity 16. *)
Definition first_prelaunch_player_update
    (state : boarding_vertical_state) : boarding_vertical_state :=
  {| boarding_hand_top_y := boarding_hand_top_y state;
     boarding_mario_y :=
       boarding_mario_y state + prelaunch_vertical_impulse;
     boarding_mario_vy := first_wait_frame_vertical_velocity |}.

(** The intervening player update moves Mario by the inherited +16 and then
    gravity leaves velocity 12 for the hand-launch frame. *)
Definition second_prelaunch_player_update
    (state : boarding_vertical_state) : boarding_vertical_state :=
  {| boarding_hand_top_y := boarding_hand_top_y state;
     boarding_mario_y :=
       boarding_mario_y state + first_wait_frame_vertical_velocity;
     boarding_mario_vy := launch_frame_vertical_velocity |}.

Definition authenticated_prelaunch
    (state : boarding_vertical_state) : boarding_vertical_state :=
  second_prelaunch_player_update (first_prelaunch_player_update state).

(** On the DOUBLE_POUND launch frame the hand update precedes Mario's update. *)
Definition hand_first_launch_step
    (state : boarding_vertical_state) : boarding_vertical_state :=
  {| boarding_hand_top_y :=
       boarding_hand_top_y state + double_pound_first_rise;
     boarding_mario_y := boarding_mario_y state;
     boarding_mario_vy := boarding_mario_vy state |}.

Definition mario_first_air_quarter
    (state : boarding_vertical_state) : boarding_vertical_state :=
  {| boarding_hand_top_y := boarding_hand_top_y state;
     boarding_mario_y :=
       boarding_mario_y state +
         boarding_mario_vy state / air_quarters_per_frame;
     boarding_mario_vy := boarding_mario_vy state |}.

Definition hand_above_mario_gap (state : boarding_vertical_state) : Z :=
  boarding_hand_top_y state - boarding_mario_y state.

Definition hand_floor_query_eligible
    (state : boarding_vertical_state) : Prop :=
  floor_query_eligible
    (boarding_mario_y state) (boarding_hand_top_y state).

(** [Some hand_top] records the source's ordinary floor-buffer snap.  X/Z
    containment and floor priority are premises of this vertical projection. *)
Definition ordinary_vertical_snap
    (state : boarding_vertical_state) : option Z :=
  if Z.leb
       (boarding_hand_top_y state - floor_query_vertical_buffer)
       (boarding_mario_y state)
  then Some (boarding_hand_top_y state)
  else None.

Lemma first_air_quarter_displacement_is_three :
  first_air_quarter_displacement = 3.
Proof. reflexivity. Qed.

Lemma stationary_mario_loses_first_rise : forall origin,
  hand_above_mario_gap
    (hand_first_launch_step (standing_on_hand origin)) = 85 /\
  ~ hand_floor_query_eligible
      (hand_first_launch_step (standing_on_hand origin)) /\
  ordinary_vertical_snap
    (hand_first_launch_step (standing_on_hand origin)) = None.
Proof.
  intros origin.
  unfold hand_above_mario_gap, hand_floor_query_eligible,
    ordinary_vertical_snap, hand_first_launch_step, standing_on_hand,
    double_pound_first_rise, floor_query_vertical_buffer,
    floor_query_eligible; cbn.
  repeat split; try lia.
  destruct (Z.leb (origin + 85 - 78) origin) eqn:Heligible.
  - apply Z.leb_le in Heligible. lia.
  - reflexivity.
Qed.

Lemma authenticated_prelaunch_moves_mario_thirty_six : forall origin,
  boarding_mario_y
    (authenticated_prelaunch (standing_on_hand origin)) = origin + 36 /\
  boarding_mario_vy
    (authenticated_prelaunch (standing_on_hand origin)) = 12.
Proof.
  intros origin.
  unfold authenticated_prelaunch, second_prelaunch_player_update,
    first_prelaunch_player_update, standing_on_hand,
    prelaunch_vertical_impulse, first_wait_frame_vertical_velocity,
    launch_frame_vertical_velocity; cbn.
  split; lia.
Qed.

Lemma authenticated_prelaunch_leaves_gap_forty_nine : forall origin,
  hand_above_mario_gap
    (hand_first_launch_step
      (authenticated_prelaunch (standing_on_hand origin))) = 49.
Proof.
  intros origin.
  unfold hand_above_mario_gap, hand_first_launch_step,
    authenticated_prelaunch, second_prelaunch_player_update,
    first_prelaunch_player_update, standing_on_hand,
    double_pound_first_rise, prelaunch_vertical_impulse,
    first_wait_frame_vertical_velocity; cbn.
  lia.
Qed.

Lemma first_quarter_leaves_eligible_gap_forty_six : forall origin,
  let query := mario_first_air_quarter
    (hand_first_launch_step
      (authenticated_prelaunch (standing_on_hand origin))) in
  hand_above_mario_gap query = 46 /\
  46 <= floor_query_vertical_buffer /\
  hand_floor_query_eligible query /\
  ordinary_vertical_snap query =
    Some (boarding_hand_top_y query).
Proof.
  intros origin; cbn.
  unfold hand_above_mario_gap, hand_floor_query_eligible,
    ordinary_vertical_snap, mario_first_air_quarter,
    hand_first_launch_step, authenticated_prelaunch,
    second_prelaunch_player_update, first_prelaunch_player_update,
    standing_on_hand,
    double_pound_first_rise, prelaunch_vertical_impulse,
    first_wait_frame_vertical_velocity, launch_frame_vertical_velocity,
    air_quarters_per_frame,
    floor_query_vertical_buffer, floor_query_eligible; cbn.
  repeat split; try lia.
  destruct (Z.leb (origin + 85 - 78) (origin + 20 + 16 + 3))
    eqn:Heligible.
  - reflexivity.
  - apply Z.leb_gt in Heligible. lia.
Qed.

Definition double_pound_steps_after_first : list Z := [70; 55; 40; 25; 10].

Lemma remaining_double_pound_steps_are_floor_eligible :
  double_pound_steps_after_first = tl double_pound_positive_steps /\
  height_only_followable double_pound_steps_after_first.
Proof.
  unfold double_pound_steps_after_first, double_pound_positive_steps,
    height_only_followable, height_step_eligible,
    floor_query_vertical_buffer; cbn.
  split; [reflexivity |].
  repeat constructor; lia.
Qed.

(** Both routes arrange action entry early enough for the two player updates
    modeled above.  The first has A already held on entry (the ABC 0.5-A
    classification); the second keeps A released throughout (the zero-A
    B-only speed-kick classification). *)
Record boarding_input_frame : Type := {
  boarding_a_schedule : a_schedule;
  boarding_b_pressed : bool
}.

Definition boarding_held_a_schedule : a_schedule :=
  {| a_before_start := true;
     a_down_at := fun _ => true |}.

Definition held_a_jump_kick_input : boarding_input_frame :=
  {| boarding_a_schedule := boarding_held_a_schedule;
     boarding_b_pressed := true |}.

Definition boarding_never_a_schedule : a_schedule :=
  {| a_before_start := false;
     a_down_at := fun _ => false |}.

Definition b_only_speed_kick_input : boarding_input_frame :=
  {| boarding_a_schedule := boarding_never_a_schedule;
     boarding_b_pressed := true |}.

Definition held_a_jump_kick_class
    (input : boarding_input_frame) : Prop :=
  continuously_held_a (boarding_a_schedule input) /\
  boarding_b_pressed input = true.

Definition b_only_speed_kick_class
    (input : boarding_input_frame) : Prop :=
  always_released_a (boarding_a_schedule input) /\
  boarding_b_pressed input = true.

Lemma held_a_jump_kick_is_preheld_without_fresh_edge :
  held_a_jump_kick_class held_a_jump_kick_input /\
  a_before_start
    (boarding_a_schedule held_a_jump_kick_input) = true /\
  a_down_at
    (boarding_a_schedule held_a_jump_kick_input) O = true /\
  ~ a_press_edge
      (boarding_a_schedule held_a_jump_kick_input) O.
Proof.
  unfold held_a_jump_kick_class, held_a_jump_kick_input,
    boarding_held_a_schedule, continuously_held_a; cbn.
  repeat split; try reflexivity.
  intros (_ & Hbefore). discriminate.
Qed.

Lemma b_only_speed_kick_uses_no_a :
  b_only_speed_kick_class b_only_speed_kick_input /\
  a_down_at
    (boarding_a_schedule b_only_speed_kick_input) O = false /\
  forall frame,
    ~ a_press_edge
        (boarding_a_schedule b_only_speed_kick_input) frame.
Proof.
  unfold b_only_speed_kick_class, b_only_speed_kick_input,
    boarding_never_a_schedule, always_released_a; cbn.
  repeat split; try reflexivity.
  intros frame (Hdown & _). discriminate.
Qed.

(** The pinned collision audit checks these scaled-thousandth X/Z points
    directly against the two transformed closed-top triangles.  The list is
    the B-only witness around the authenticated catch and the five remaining
    positive hand steps.  This Rocq predicate records the
    strict interior box containing those audited points; it is not a generic
    polygon-refinement theorem. *)
Definition b_only_closed_top_xz_trace : list (Z * Z) :=
  [(0, -55850); (30000, -45150); (30000, -5774); (30000, 30452);
   (30000, 63780); (30000, 94442); (30000, 122651)].

Definition audited_closed_top_interior_box (point : Z * Z) : Prop :=
  let '(x, z) := point in
  -30000 <= x <= 30000 /\ -56000 <= z <= 123000.

Lemma b_only_xz_trace_stays_in_audited_interior_box :
  Forall audited_closed_top_interior_box b_only_closed_top_xz_trace.
Proof.
  unfold b_only_closed_top_xz_trace, audited_closed_top_interior_box.
  repeat constructor; lia.
Qed.

(** Fixed-point arithmetic in half-units avoids hiding the source's 4.5-unit
    closed-hand underside offset.  After the hand's +85 step, the underside
    is 179 half-units = 89.5 units above the arena floor.  Mario's ordinary
    central collision check requires 300 half-units = 150 units of clearance.
    Consequently INPUT_SQUISHED is established before ACT_WALKING can process
    a B-only speed kick entered on this same launch frame. *)
Definition launch_frame_underside_above_arena_half_units : Z := 179.
Definition mario_required_clearance_half_units : Z := 300.

Definition launch_frame_central_setup_has_clearance : Prop :=
  mario_required_clearance_half_units <=
    launch_frame_underside_above_arena_half_units.

Lemma launch_frame_underside_is_eighty_nine_point_five :
  launch_frame_underside_above_arena_half_units = 2 * 89 + 1.
Proof. reflexivity. Qed.

Lemma launch_frame_central_setup_is_squished_before_input :
  launch_frame_underside_above_arena_half_units <
    mario_required_clearance_half_units /\
  ~ launch_frame_central_setup_has_clearance.
Proof.
  unfold launch_frame_underside_above_arena_half_units,
    mario_required_clearance_half_units,
    launch_frame_central_setup_has_clearance.
  split.
  - lia.
  - intros Hclearance. apply Hclearance. reflexivity.
Qed.

Definition double_pound_boarding_certificate : Prop :=
  (forall origin,
    hand_above_mario_gap
      (hand_first_launch_step (standing_on_hand origin)) = 85 /\
    ~ hand_floor_query_eligible
        (hand_first_launch_step (standing_on_hand origin)) /\
    ordinary_vertical_snap
      (hand_first_launch_step (standing_on_hand origin)) = None) /\
  (forall origin,
    boarding_mario_y
      (authenticated_prelaunch (standing_on_hand origin)) = origin + 36 /\
    boarding_mario_vy
      (authenticated_prelaunch (standing_on_hand origin)) = 12) /\
  (forall origin,
    hand_above_mario_gap
      (hand_first_launch_step
        (authenticated_prelaunch (standing_on_hand origin))) = 49) /\
  (forall origin,
    let query := mario_first_air_quarter
      (hand_first_launch_step
        (authenticated_prelaunch (standing_on_hand origin))) in
    hand_above_mario_gap query = 46 /\
    hand_floor_query_eligible query /\
    ordinary_vertical_snap query = Some (boarding_hand_top_y query)) /\
  height_only_followable double_pound_steps_after_first /\
  held_a_jump_kick_class held_a_jump_kick_input /\
  ~ a_press_edge
      (boarding_a_schedule held_a_jump_kick_input) O /\
  b_only_speed_kick_class b_only_speed_kick_input /\
  (forall frame,
    ~ a_press_edge
        (boarding_a_schedule b_only_speed_kick_input) frame) /\
  Forall audited_closed_top_interior_box b_only_closed_top_xz_trace /\
  launch_frame_underside_above_arena_half_units = 179 /\
  ~ launch_frame_central_setup_has_clearance.

Theorem double_pound_boarding_certificate_holds :
  double_pound_boarding_certificate.
Proof.
  unfold double_pound_boarding_certificate.
  refine (conj stationary_mario_loses_first_rise _).
  refine (conj authenticated_prelaunch_moves_mario_thirty_six _).
  refine (conj authenticated_prelaunch_leaves_gap_forty_nine _).
  split.
  - intros origin.
    pose proof (first_quarter_leaves_eligible_gap_forty_six origin)
      as (Hgap & _ & Heligible & Hsnap).
    exact (conj Hgap (conj Heligible Hsnap)).
  - refine (conj (proj2 remaining_double_pound_steps_are_floor_eligible) _).
    refine (conj (proj1 held_a_jump_kick_is_preheld_without_fresh_edge) _).
    refine (conj
      (proj2 (proj2 (proj2
        held_a_jump_kick_is_preheld_without_fresh_edge))) _).
    refine (conj (proj1 b_only_speed_kick_uses_no_a) _).
    refine (conj (proj2 (proj2 b_only_speed_kick_uses_no_a)) _).
    refine (conj b_only_xz_trace_stays_in_audited_interior_box _).
    refine (conj eq_refl _).
    exact (proj2 launch_frame_central_setup_is_squished_before_input).
Qed.
