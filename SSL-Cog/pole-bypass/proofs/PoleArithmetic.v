From Coq Require Import Lia ZArith.
From SSLPoleBypass.Proofs Require Import Spec.

Local Open Scope Z_scope.

Lemma soft_last_eligible_frame :
  forall frames, 0 <= frames ->
    sixth_floor_y <= soft_height_upper frames -> frames <= 6.
Proof.
  intros frames Hnonnegative Hheight.
  unfold sixth_floor_y, soft_height_upper, pole_top_y, pole_base_y,
    pole_hitbox_height, pole_parameter, pole_top_offset in *.
  nia.
Qed.

Lemma soft_max_radius_before_floor :
  forall frames, 0 <= frames ->
    sixth_floor_y <= soft_height_upper frames -> soft_radius_upper frames <= 82.
Proof.
  intros frames Hnonnegative Hheight.
  pose proof (soft_last_eligible_frame frames Hnonnegative Hheight).
  unfold soft_radius_upper, pole_push_radius, non_a_speed_upper.
  lia.
Qed.

Theorem soft_bonk_never_clearable :
  forall frames, 0 <= frames -> ~ soft_clearable frames.
Proof.
  intros frames Hnonnegative [Hradius Hheight].
  pose proof (soft_max_radius_before_floor frames Hnonnegative Hheight).
  unfold hole_west_clearance in Hradius.
  lia.
Qed.

Lemma soft_deadline_certificate :
  soft_height_upper 6 = 3960 /\ soft_height_upper 7 = 3936 /\
  soft_radius_upper 6 = 82.
Proof. repeat split; reflexivity. Qed.

Lemma jump_clear_certificate :
  hole_west_clearance <= jump_west_distance_lower 5 /\
  sixth_floor_y <= jump_height 5.
Proof.
  change (101 <= 110 /\ 3942 <= 4290).
  lia.
Qed.

Lemma jump_landing_certificate : jump_landing_window 33.
Proof.
  change (101 <= 110 /\ 792 <= 1535 /\ 3942 <= 3954 /\ 3884 < 3942).
  lia.
Qed.

Theorem local_motion_arithmetic_certificate :
  (forall frames, 0 <= frames -> ~ soft_clearable frames) /\
  (hole_west_clearance <= jump_west_distance_lower 5 /\
   sixth_floor_y <= jump_height 5) /\ jump_landing_window 33.
Proof.
  split.
  - exact soft_bonk_never_clearable.
  - split.
    + exact jump_clear_certificate.
    + exact jump_landing_certificate.
Qed.
