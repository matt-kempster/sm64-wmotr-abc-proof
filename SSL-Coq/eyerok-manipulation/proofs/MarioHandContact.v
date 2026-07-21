From Coq Require Import Lia List ZArith.
From SSLEyerok.Proofs Require Import HeightMilestones RouteModel.

Import ListNotations.
Local Open Scope Z_scope.

(** Source-audited vertical constants.  This module proves only the vertical
    eligibility and hitbox arithmetic.  X/Z overlap, selected-floor priority,
    Mario action execution, and an initial boarding trace remain separate. *)
Definition floor_query_vertical_buffer : Z := 78.
Definition mario_platform_latch_tolerance : Z := 4.
Definition eyerok_hitbox_top_offset : Z := 150.
Definition closed_hand_top_offset : Z := 306.
Definition open_hand_top_offset : Z := 507.
Definition target_mario_lift_step : Z := 20.
Definition closed_to_open_top_jump : Z :=
  open_hand_top_offset - closed_hand_top_offset.

Definition attacked_positive_steps : list Z := [26; 22; 18; 14; 10; 6; 2].
Definition die_positive_steps : list Z :=
  [46; 42; 38; 34; 30; 26; 22; 18; 14; 10; 6; 2].
Definition double_pound_positive_steps : list Z := [85; 70; 55; 40; 25; 10].
Definition backflip_positive_steps : list Z :=
  [62; 58; 54; 50; 46; 42; 38; 34; 30; 26; 22; 18; 14; 10; 6; 2].
Definition triple_jump_positive_steps : list Z :=
  [69; 65; 61; 57; 53; 49; 45; 41; 37; 33; 29; 25; 21; 17; 13; 9; 5; 1].

Fixpoint sum_z (values : list Z) : Z :=
  match values with
  | [] => 0
  | value :: rest => value + sum_z rest
  end.

Definition height_step_eligible (delta : Z) : Prop :=
  0 <= delta <= floor_query_vertical_buffer.

Definition height_only_followable (steps : list Z) : Prop :=
  Forall height_step_eligible steps.

Lemma mario_hand_contact_values :
  sum_z attacked_positive_steps = 98 /\
  sum_z die_positive_steps = 288 /\
  sum_z double_pound_positive_steps = 285 /\
  closed_to_open_top_jump = 201.
Proof. repeat split; reflexivity. Qed.

Lemma mario_jump_envelope_values :
  sum_z backflip_positive_steps = 512 /\
  sum_z triple_jump_positive_steps = 630.
Proof. split; reflexivity. Qed.

Lemma floor_query_eligibility_for_vertical_step : forall floor_y delta,
  floor_query_eligible floor_y (floor_y + delta) <->
  delta <= floor_query_vertical_buffer.
Proof.
  intros floor_y delta.
  unfold floor_query_eligible, floor_query_vertical_buffer. lia.
Qed.

Lemma attacked_rise_is_height_only_followable :
  height_only_followable attacked_positive_steps.
Proof.
  unfold height_only_followable, attacked_positive_steps,
    height_step_eligible, floor_query_vertical_buffer.
  repeat constructor; lia.
Qed.

Lemma die_rise_is_height_only_followable :
  height_only_followable die_positive_steps.
Proof.
  unfold height_only_followable, die_positive_steps,
    height_step_eligible, floor_query_vertical_buffer.
  repeat constructor; lia.
Qed.

Lemma target_lift_step_is_height_only_eligible :
  height_step_eligible target_mario_lift_step.
Proof.
  unfold height_step_eligible, target_mario_lift_step,
    floor_query_vertical_buffer. lia.
Qed.

Lemma double_pound_first_step_exceeds_floor_buffer :
  ~ height_step_eligible 85.
Proof.
  unfold height_step_eligible, floor_query_vertical_buffer. lia.
Qed.

Lemma runaway_step_exceeds_floor_buffer :
  ~ height_step_eligible 100.
Proof.
  unfold height_step_eligible, floor_query_vertical_buffer. lia.
Qed.

Lemma closed_to_open_switch_exceeds_floor_buffer :
  ~ height_step_eligible closed_to_open_top_jump.
Proof.
  unfold height_step_eligible, closed_to_open_top_jump,
    open_hand_top_offset, closed_hand_top_offset,
    floor_query_vertical_buffer. lia.
Qed.

(** The source's direct platform translation adds oVelX and oVelZ, but no
    oVelY.  Rotation can change Y; Eyerok's relevant hand rotation is handled
    separately.  This projection represents only the direct velocity add. *)
Definition direct_platform_displacement_y (mario_y : Z) : Z := mario_y.

Lemma direct_platform_velocity_does_not_change_mario_y : forall mario_y,
  direct_platform_displacement_y mario_y = mario_y.
Proof. reflexivity. Qed.

(** This is the inclusive vertical-overlap test used by object collision after
    the source's two strict separation checks. *)
Definition vertical_hitboxes_overlap
    (first_bottom first_height second_bottom second_height : Z) : Prop :=
  first_bottom <= second_bottom + second_height /\
  second_bottom <= first_bottom + first_height.

Lemma standing_on_closed_top_has_no_vertical_hitbox_overlap :
  forall hand_y mario_height,
    ~ vertical_hitboxes_overlap
        (hand_y + closed_hand_top_offset) mario_height
        hand_y eyerok_hitbox_top_offset.
Proof.
  intros hand_y mario_height Hoverlap.
  unfold vertical_hitboxes_overlap, closed_hand_top_offset,
    eyerok_hitbox_top_offset in Hoverlap.
  lia.
Qed.

Lemma standing_on_open_top_has_no_vertical_hitbox_overlap :
  forall hand_y mario_height,
    ~ vertical_hitboxes_overlap
        (hand_y + open_hand_top_offset) mario_height
        hand_y eyerok_hitbox_top_offset.
Proof.
  intros hand_y mario_height Hoverlap.
  unfold vertical_hitboxes_overlap, open_hand_top_offset,
    eyerok_hitbox_top_offset in Hoverlap.
  lia.
Qed.

Definition ordinary_attack_bounce_y (hand_y : Z) : Z :=
  hand_y + eyerok_hitbox_top_offset.

Lemma ordinary_attack_bounce_is_below_open_surface : forall hand_y,
  ordinary_attack_bounce_y hand_y < hand_y + open_hand_top_offset.
Proof.
  intros hand_y.
  unfold ordinary_attack_bounce_y, eyerok_hitbox_top_offset,
    open_hand_top_offset. lia.
Qed.

(** A deliberately generous arithmetic check: even if Mario receives the
    full 30-unit bounce displacement before the hand's first lethal +46
    displacement, the new open top is still rejected by the 78-unit filter.
    This is not a scheduling theorem about which update happens first. *)
Lemma ordinary_bounce_cannot_height_follow_first_die_step : forall hand_y,
  ~ floor_query_eligible
      (ordinary_attack_bounce_y hand_y + 30)
      (hand_y + 46 + open_hand_top_offset).
Proof.
  intros hand_y Heligible.
  unfold floor_query_eligible, ordinary_attack_bounce_y,
    eyerok_hitbox_top_offset, open_hand_top_offset in Heligible.
  lia.
Qed.

Lemma released_a_cannot_supply_press_gated_launch : forall schedule frame,
  always_released_a schedule -> ~ a_press_edge schedule frame.
Proof. exact always_released_has_no_press_edge. Qed.

Lemma held_before_start_cannot_supply_press_gated_launch : forall schedule frame,
  continuously_held_a schedule -> ~ a_press_edge schedule frame.
Proof. exact continuously_held_has_no_press_edge. Qed.

Lemma fresh_press_and_hold_supplies_frame_zero_edge :
  a_press_edge press_and_hold_from_start O.
Proof. exact (proj1 press_and_hold_has_one_fresh_edge). Qed.

Definition mario_hand_contact_certificate : Prop :=
  sum_z attacked_positive_steps = 98 /\
  sum_z die_positive_steps = 288 /\
  sum_z double_pound_positive_steps = 285 /\
  sum_z backflip_positive_steps = 512 /\
  sum_z triple_jump_positive_steps = 630 /\
  height_only_followable attacked_positive_steps /\
  height_only_followable die_positive_steps /\
  height_step_eligible target_mario_lift_step /\
  ~ height_step_eligible 85 /\
  ~ height_step_eligible 100 /\
  ~ height_step_eligible closed_to_open_top_jump /\
  (forall hand_y mario_height,
    ~ vertical_hitboxes_overlap
        (hand_y + closed_hand_top_offset) mario_height
        hand_y eyerok_hitbox_top_offset) /\
  (forall hand_y mario_height,
    ~ vertical_hitboxes_overlap
        (hand_y + open_hand_top_offset) mario_height
        hand_y eyerok_hitbox_top_offset) /\
  (forall hand_y,
    ~ floor_query_eligible
        (ordinary_attack_bounce_y hand_y + 30)
        (hand_y + 46 + open_hand_top_offset)) /\
  a_press_edge press_and_hold_from_start O.

Theorem mario_hand_contact_certificate_holds :
  mario_hand_contact_certificate.
Proof.
  unfold mario_hand_contact_certificate.
  refine (conj (proj1 mario_hand_contact_values) _).
  refine (conj (proj1 (proj2 mario_hand_contact_values)) _).
  refine (conj (proj1 (proj2 (proj2 mario_hand_contact_values))) _).
  refine (conj (proj1 mario_jump_envelope_values) _).
  refine (conj (proj2 mario_jump_envelope_values) _).
  refine (conj attacked_rise_is_height_only_followable _).
  refine (conj die_rise_is_height_only_followable _).
  refine (conj target_lift_step_is_height_only_eligible _).
  refine (conj double_pound_first_step_exceeds_floor_buffer _).
  refine (conj runaway_step_exceeds_floor_buffer _).
  refine (conj closed_to_open_switch_exceeds_floor_buffer _).
  refine (conj standing_on_closed_top_has_no_vertical_hitbox_overlap _).
  refine (conj standing_on_open_top_has_no_vertical_hitbox_overlap _).
  refine (conj ordinary_bounce_cannot_height_follow_first_die_step _).
  exact fresh_press_and_hold_supplies_frame_zero_edge.
Qed.
