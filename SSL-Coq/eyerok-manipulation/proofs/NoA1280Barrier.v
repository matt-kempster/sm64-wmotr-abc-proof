From Coq Require Import Lia List ZArith.
From SSLEyerok.Proofs Require Import MarioHandContact RouteModel TwoHandBarrier.

Import ListNotations.
Local Open Scope Z_scope.

(** A source-shaped, deliberately generous obstruction for the B-only
    speed-kick candidate.  This module is not a linked Clight refinement.

    The modeled route starts after an Area 3 dive frame has left the dynamic
    hand, selected the instant-warp floor at Z=-1024, moved Mario from Y=1179
    to Y=1199, and reduced vertical velocity from 20 to 16.  Authentic
    reachability of that departure state remains a separate obligation. *)
Definition no_a_surface_y : Z := second_hand_open_surface_peak.
Definition speed_kick_initial_vy : Z := 20.
Definition ordinary_air_gravity : Z := 4.
Definition no_a_positive_steps : list Z := [20; 16; 12; 8; 4].
Definition no_a_peak_y : Z := no_a_surface_y + sum_z no_a_positive_steps.
Definition no_a_postwarp_y : Z := no_a_surface_y + speed_kick_initial_vy.
Definition no_a_postwarp_vy : Z := speed_kick_initial_vy - ordinary_air_gravity.

Lemma no_a_speed_kick_values :
  no_a_surface_y = 1179 /\
  sum_z no_a_positive_steps = 60 /\
  no_a_peak_y = 1239 /\
  no_a_postwarp_y = 1199 /\
  no_a_postwarp_vy = 16.
Proof. repeat split; reflexivity. Qed.

(** Quarter-step query Ys in Area 2, starting at Y=1199 with vy=16.
    [perform_air_step] uses the current velocity for four queries and applies
    gravity only after those queries. *)
Definition no_a_area2_qstep_query_ys : list Z :=
  [1203; 1207; 1211; 1215;
   1218; 1221; 1224; 1227;
   1229; 1231; 1233; 1235;
   1236; 1237; 1238; 1239;
   1239; 1239; 1239; 1239;
   1238; 1237; 1236; 1235;
   1233; 1231; 1229; 1227;
   1224; 1221; 1218; 1215;
   1211; 1207; 1203; 1199].

Definition no_a_eligible_qsteps : Z := 35.

Lemma no_a_first_35_qsteps_are_y1280_eligible :
  Forall (fun query_y => floor_query_eligible query_y 1280)
    (firstn 35 no_a_area2_qstep_query_ys).
Proof.
  unfold no_a_area2_qstep_query_ys.
  cbn [firstn].
  repeat constructor; unfold floor_query_eligible; lia.
Qed.

Lemma no_a_qstep_36_is_below_y1280_query_window :
  nth 35 no_a_area2_qstep_query_ys 0 = 1199 /\
  ~ floor_query_eligible (nth 35 no_a_area2_qstep_query_ys 0) 1280.
Proof.
  unfold no_a_area2_qstep_query_ys, floor_query_eligible.
  cbn. split; lia.
Qed.

(** At speed at most 48, a quarter-step has Euclidean length at most 12.
    The list stores integer upper bounds on those lengths.  Granting 35
    independently steerable maximum-length quarter-steps is more permissive
    than the source's actual dive air control. *)
Definition no_a_horizontal_speed_max : Z := 48.
Definition no_a_qsteps_per_frame : Z := 4.
Definition no_a_qstep_distance_max : Z :=
  no_a_horizontal_speed_max / no_a_qsteps_per_frame.
Definition no_a_path_length_max : Z :=
  no_a_eligible_qsteps * no_a_qstep_distance_max.

Definition ordinary_qstep_budget (lengths : list Z) : Prop :=
  Forall (fun distance => 0 <= distance <= no_a_qstep_distance_max) lengths /\
  Z.of_nat (length lengths) <= no_a_eligible_qsteps.

Lemma no_a_path_budget_values :
  no_a_qstep_distance_max = 12 /\
  no_a_path_length_max = 420.
Proof. split; reflexivity. Qed.

Lemma bounded_sum_z : forall lengths,
  Forall (fun distance => 0 <= distance <= 12) lengths ->
  0 <= sum_z lengths /\
  sum_z lengths <= Z.of_nat (length lengths) * 12.
Proof.
  intros lengths Hbounded.
  induction Hbounded as [| distance rest Hdistance Hrest IH]; cbn.
  - split; lia.
  - destruct Hdistance as [Hnonnegative Hupper].
    destruct IH as [IHnonnegative IHupper].
    split; lia.
Qed.

Lemma ordinary_qstep_budget_at_most_420 : forall lengths,
  ordinary_qstep_budget lengths ->
  0 <= sum_z lengths <= no_a_path_length_max.
Proof.
  intros lengths [Hsteps Hcount].
  unfold no_a_qstep_distance_max, no_a_horizontal_speed_max,
    no_a_qsteps_per_frame in Hsteps.
  pose proof (bounded_sum_z lengths Hsteps) as [Hnonnegative Hsum].
  unfold no_a_path_length_max, no_a_eligible_qsteps,
    no_a_qstep_distance_max, no_a_horizontal_speed_max,
    no_a_qsteps_per_frame in *.
  split; [exact Hnonnegative |].
  change (sum_z lengths <= 420).
  eapply Z.le_trans; [exact Hsum |].
  replace 420 with (35 * 12) by reflexivity.
  apply Z.mul_le_mono_nonneg_r; [lia | exact Hcount].
Qed.

(** Pinned static-geometry constants for the nearby Y=1280 floor.

    The south wall is at Z=-844 over X=[-2201,205].  Its east continuation is
    at X=205 through Z=-537.  Both walls have geometry Y=[1152,1280].
    Surface loading expands upperY by five, and the lower Mario wall query is
    made at base Y+30 with radius 50. *)
Definition y1280_wall_top : Z := 1280.
Definition surface_upper_y_margin : Z := 5.
Definition mario_lower_wall_sample_offset : Z := 30.
Definition mario_wall_radius : Z := 50.
Definition y1280_south_wall_west_x : Z := -2201.
Definition y1280_wall_east_x : Z := 205.
Definition y1280_east_wall_north_z : Z := -537.
Definition corrected_warp_z : Z := -1024.
Definition warp_west_x : Z := -191.
Definition warp_east_x : Z := 192.

Definition over_wall_base_y_exclusive : Z :=
  y1280_wall_top + surface_upper_y_margin - mario_lower_wall_sample_offset.
Definition east_clearance_x : Z := y1280_wall_east_x + mario_wall_radius.
Definition east_clearance_z : Z := y1280_east_wall_north_z + mario_wall_radius.
Definition west_clearance_x : Z := y1280_south_wall_west_x - mario_wall_radius.

Lemma no_a_wall_clearance_values :
  over_wall_base_y_exclusive = 1255 /\
  east_clearance_x = 255 /\
  east_clearance_z = -487 /\
  west_clearance_x = -2251.
Proof. repeat split; reflexivity. Qed.

Definition squared_horizontal_displacement
    (start_x start_z finish_x finish_z : Z) : Z :=
  (finish_x - start_x) * (finish_x - start_x) +
  (finish_z - start_z) * (finish_z - start_z).

Definition clears_wall_vertically (base_y : Z) : Prop :=
  over_wall_base_y_exclusive < base_y.

Definition reaches_east_clearance (x z : Z) : Prop :=
  east_clearance_x <= x /\ east_clearance_z <= z.

Definition reaches_west_clearance (x : Z) : Prop := x <= west_clearance_x.

(** This inductive relation classifies wall-avoiding, ordinary approaches to
    the nearby Y=1280 top.  It grants arbitrary steering and the best warp X
    for each detour.  [chord <= path length] is recorded explicitly because
    this arithmetic model does not contain a full sequence of X/Z positions.

    There is intentionally no constructor for seam misses, quantum tunneling,
    parallel-universe casts, or other collision glitches.  The theorem below
    therefore cannot rule out such a counterexample.  A source refinement must
    also justify that over/east/west exhaust the ordinary wall-avoiding routes. *)
Inductive ordinary_no_a_wall_avoiding_entry : Prop :=
| ordinary_entry_over :
    clears_wall_vertically no_a_peak_y ->
    ordinary_no_a_wall_avoiding_entry
| ordinary_entry_east : forall lengths x z,
    ordinary_qstep_budget lengths ->
    reaches_east_clearance x z ->
    squared_horizontal_displacement warp_east_x corrected_warp_z x z <=
      sum_z lengths * sum_z lengths ->
    ordinary_no_a_wall_avoiding_entry
| ordinary_entry_west : forall lengths x z,
    ordinary_qstep_budget lengths ->
    reaches_west_clearance x ->
    squared_horizontal_displacement warp_west_x corrected_warp_z x z <=
      sum_z lengths * sum_z lengths ->
    ordinary_no_a_wall_avoiding_entry.

Lemma no_a_peak_cannot_clear_y1280_wall :
  ~ clears_wall_vertically no_a_peak_y.
Proof.
  unfold clears_wall_vertically.
  rewrite (proj1 no_a_wall_clearance_values).
  rewrite (proj1 (proj2 (proj2 no_a_speed_kick_values))).
  lia.
Qed.

Lemma east_clearance_exceeds_path_budget : forall lengths x z,
  ordinary_qstep_budget lengths ->
  reaches_east_clearance x z ->
  ~ squared_horizontal_displacement warp_east_x corrected_warp_z x z <=
      sum_z lengths * sum_z lengths.
Proof.
  intros lengths x z Hbudget [Hx Hz] Hchord.
  pose proof (ordinary_qstep_budget_at_most_420 lengths Hbudget)
    as [Hsum_nonnegative Hsum_upper].
  unfold reaches_east_clearance, east_clearance_x,
    y1280_wall_east_x, mario_wall_radius,
    east_clearance_z, y1280_east_wall_north_z,
    squared_horizontal_displacement, warp_east_x, corrected_warp_z,
    no_a_path_length_max, no_a_eligible_qsteps,
    no_a_qstep_distance_max, no_a_horizontal_speed_max,
    no_a_qsteps_per_frame in *.
  assert (Hdx : 63 <= x - 192) by lia.
  assert (Hdz : 537 <= z - (-1024)).
  { change (-487 <= z) in Hz.
    change (537 <= z + 1024).
    clear Hbudget Hchord Hsum_nonnegative Hsum_upper Hx Hdx lengths x.
    lia. }
  assert (Hdistance :
      63 * 63 + 537 * 537 <=
      (x - 192) * (x - 192) +
      (z - (-1024)) * (z - (-1024))) by nia.
  change (0 <= sum_z lengths) in Hsum_nonnegative.
  change (sum_z lengths <= 420) in Hsum_upper.
  assert (Hrequired :
      63 * 63 + 537 * 537 <= sum_z lengths * sum_z lengths).
  { eapply Z.le_trans; [exact Hdistance | exact Hchord]. }
  assert (Havailable :
      sum_z lengths * sum_z lengths <= 420 * 420) by nia.
  lia.
Qed.

Lemma west_clearance_exceeds_path_budget : forall lengths x z,
  ordinary_qstep_budget lengths ->
  reaches_west_clearance x ->
  ~ squared_horizontal_displacement warp_west_x corrected_warp_z x z <=
      sum_z lengths * sum_z lengths.
Proof.
  intros lengths x z Hbudget Hx Hchord.
  pose proof (ordinary_qstep_budget_at_most_420 lengths Hbudget)
    as [Hsum_nonnegative Hsum_upper].
  unfold reaches_west_clearance, west_clearance_x,
    y1280_south_wall_west_x, mario_wall_radius,
    squared_horizontal_displacement, warp_west_x, corrected_warp_z,
    no_a_path_length_max, no_a_eligible_qsteps,
    no_a_qstep_distance_max, no_a_horizontal_speed_max,
    no_a_qsteps_per_frame in *.
  assert (Hdx : x - (-191) <= -2060) by lia.
  pose proof (Z.square_nonneg (z - (-1024))) as Hzsquare.
  assert (Hdistance :
      2060 * 2060 <=
      (x - (-191)) * (x - (-191)) +
      (z - (-1024)) * (z - (-1024))) by nia.
  change (0 <= sum_z lengths) in Hsum_nonnegative.
  change (sum_z lengths <= 420) in Hsum_upper.
  assert (Hrequired :
      2060 * 2060 <= sum_z lengths * sum_z lengths).
  { eapply Z.le_trans; [exact Hdistance | exact Hchord]. }
  assert (Havailable :
      sum_z lengths * sum_z lengths <= 420 * 420) by nia.
  lia.
Qed.

Theorem no_ordinary_no_a_wall_avoiding_y1280_entry :
  ~ ordinary_no_a_wall_avoiding_entry.
Proof.
  intros Hentry.
  destruct Hentry as
      [Hover
      | lengths x z Hbudget Hclear Hchord
      | lengths x z Hbudget Hclear Hchord].
  - exact (no_a_peak_cannot_clear_y1280_wall Hover).
  - exact (east_clearance_exceeds_path_budget
      lengths x z Hbudget Hclear Hchord).
  - exact (west_clearance_exceeds_path_budget
      lengths x z Hbudget Hclear Hchord).
Qed.

(** Within this explicitly seam-free route classification, reaching the
    nearby Y=1280 top without first resolving against its perimeter wall is
    impossible. *)
Definition ordinary_path_must_resolve_wall_before_y1280 : Prop :=
  ~ ordinary_no_a_wall_avoiding_entry.

Theorem ordinary_path_must_resolve_wall_before_y1280_holds :
  ordinary_path_must_resolve_wall_before_y1280.
Proof. exact no_ordinary_no_a_wall_avoiding_y1280_entry. Qed.

Definition no_a_1280_barrier_certificate : Prop :=
  no_a_surface_y = 1179 /\
  no_a_peak_y = 1239 /\
  no_a_postwarp_y = 1199 /\
  no_a_postwarp_vy = 16 /\
  no_a_qstep_distance_max = 12 /\
  no_a_path_length_max = 420 /\
  over_wall_base_y_exclusive = 1255 /\
  (forall lengths,
      ordinary_qstep_budget lengths ->
      sum_z lengths <= no_a_path_length_max) /\
  ordinary_path_must_resolve_wall_before_y1280.

Theorem no_a_1280_barrier_certificate_holds :
  no_a_1280_barrier_certificate.
Proof.
  unfold no_a_1280_barrier_certificate.
  refine (conj (proj1 no_a_speed_kick_values) _).
  refine (conj (proj1 (proj2 (proj2 no_a_speed_kick_values))) _).
  refine (conj (proj1 (proj2 (proj2 (proj2 no_a_speed_kick_values)))) _).
  refine (conj (proj2 (proj2 (proj2 (proj2 no_a_speed_kick_values)))) _).
  refine (conj (proj1 no_a_path_budget_values) _).
  refine (conj (proj2 no_a_path_budget_values) _).
  refine (conj (proj1 no_a_wall_clearance_values) _).
  refine (conj _ ordinary_path_must_resolve_wall_before_y1280_holds).
  intros lengths Hbudget.
  exact (proj2 (ordinary_qstep_budget_at_most_420 lengths Hbudget)).
Qed.
