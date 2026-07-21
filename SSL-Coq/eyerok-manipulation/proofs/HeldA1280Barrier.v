From Coq Require Import Lia List ZArith.
From SSLEyerok.Proofs Require Import GeneratedFacts HeightMilestones
  MarioHandContact NoA1280Barrier RouteModel.

Import ListNotations.
Local Open Scope Z_scope.

(** A read-only arithmetic obstruction for the continuously-held-A jump-kick
    candidate.  The generated Clight AST independently pins the
    [ACT_JUMP_KICK] switch case's vertical slot 1 assignment to binary32 20.
    This model instantiates that same number by reusing [NoA1280Barrier]'s
    Y=1179, velocity-20 trajectory and its first 35 Y=1280-eligible
    quarter-step queries.

    This is not a linked Clight refinement and it is not an authentic boarding
    witness.  In particular, it does not prove that Mario can reach the
    Y=1179 hand surface, leave it on the Area 3 warp, or enter jump-kick from
    the required predecessor action. *)

Definition held_a_schedule : a_schedule :=
  {| a_before_start := true;
     a_down_at := fun _ => true |}.

Lemma held_a_schedule_is_continuously_held :
  continuously_held_a held_a_schedule.
Proof.
  unfold continuously_held_a, held_a_schedule. cbn.
  split; [reflexivity | intros; reflexivity].
Qed.

Lemma held_a_schedule_has_no_fresh_press_edge : forall frame,
  ~ a_press_edge held_a_schedule frame.
Proof.
  intros frame.
  exact (continuously_held_has_no_press_edge
    held_a_schedule frame held_a_schedule_is_continuously_held).
Qed.

Definition held_a_surface_y : Z := no_a_surface_y.
Definition held_a_initial_vertical_velocity : Z := speed_kick_initial_vy.
Definition held_a_positive_vertical_steps : list Z := no_a_positive_steps.
Definition held_a_peak_y : Z := held_a_surface_y +
  sum_z held_a_positive_vertical_steps.
Definition held_a_area2_qstep_query_ys : list Z :=
  no_a_area2_qstep_query_ys.
Definition held_a_eligible_qsteps : Z := no_a_eligible_qsteps.

Lemma held_a_vertical_trajectory_values :
  held_a_surface_y = 1179 /\
  held_a_initial_vertical_velocity = 20 /\
  sum_z held_a_positive_vertical_steps = 60 /\
  held_a_peak_y = 1239 /\
  held_a_eligible_qsteps = 35.
Proof. repeat split; reflexivity. Qed.

Lemma held_a_first_35_qsteps_are_y1280_eligible :
  Forall (fun query_y => floor_query_eligible query_y 1280)
    (firstn 35 held_a_area2_qstep_query_ys).
Proof. exact no_a_first_35_qsteps_are_y1280_eligible. Qed.

Lemma held_a_qstep_36_is_below_y1280_query_window :
  nth 35 held_a_area2_qstep_query_ys 0 = 1199 /\
  ~ floor_query_eligible
      (nth 35 held_a_area2_qstep_query_ys 0) 1280.
Proof. exact no_a_qstep_36_is_below_y1280_query_window. Qed.

(** [update_air_without_turn] has uncapped air-speed behavior.  Consequently
    the inherited |forwardVel| <= 48 condition below is a premise, not a
    global fact about original-game jump kicks.  The 13-unit quarter-step cap
    is a conservative integer abstraction that also grants arbitrary steering
    and sideways input; a later source refinement must connect the float
    update to this budget. *)
Definition held_a_inherited_forward_speed_limit : Z := 48.
Definition held_a_qstep_distance_max : Z := 13.
Definition held_a_path_length_max : Z :=
  held_a_eligible_qsteps * held_a_qstep_distance_max.

Definition inherited_forward_speed_within_48 (forward_vel : Z) : Prop :=
  Z.abs forward_vel <= held_a_inherited_forward_speed_limit.

Definition capped_held_a_qstep_budget
    (inherited_forward_vel : Z) (lengths : list Z) : Prop :=
  inherited_forward_speed_within_48 inherited_forward_vel /\
  Forall
    (fun distance => 0 <= distance <= held_a_qstep_distance_max)
    lengths /\
  Z.of_nat (length lengths) <= held_a_eligible_qsteps.

Lemma held_a_path_budget_values :
  held_a_qstep_distance_max = 13 /\
  held_a_path_length_max = 455.
Proof. split; reflexivity. Qed.

Lemma held_a_bounded_sum_z : forall lengths,
  Forall (fun distance => 0 <= distance <= 13) lengths ->
  0 <= sum_z lengths /\
  sum_z lengths <= Z.of_nat (length lengths) * 13.
Proof.
  intros lengths Hbounded.
  induction Hbounded as [| distance rest Hdistance Hrest IH]; cbn.
  - split; lia.
  - destruct Hdistance as [Hnonnegative Hupper].
    destruct IH as [IHnonnegative IHupper].
    split; lia.
Qed.

Lemma capped_held_a_qstep_budget_at_most_455 :
  forall inherited_forward_vel lengths,
    capped_held_a_qstep_budget inherited_forward_vel lengths ->
    0 <= sum_z lengths <= held_a_path_length_max.
Proof.
  intros inherited_forward_vel lengths
    [_ [Hsteps Hcount]].
  unfold held_a_qstep_distance_max in Hsteps.
  pose proof (held_a_bounded_sum_z lengths Hsteps)
    as [Hnonnegative Hsum].
  unfold held_a_path_length_max, held_a_eligible_qsteps,
    held_a_qstep_distance_max.
  split; [exact Hnonnegative |].
  change (sum_z lengths <= 455).
  eapply Z.le_trans; [exact Hsum |].
  replace 455 with (35 * 13) by reflexivity.
  apply Z.mul_le_mono_nonneg_r; [lia | exact Hcount].
Qed.

(** The route class stops at the first perimeter-wall resolution.  There is no
    constructor for hitting the wall, changing action, and continuing toward
    Y=1280 afterward.  Post-wall bonks, recovery, and subsequent launches are
    therefore outside the theorem, as are seams, quantum tunneling,
    parallel-universe casts, and inherited speed whose magnitude exceeds 48. *)
Inductive ordinary_held_a_wall_avoiding_entry : Prop :=
| held_a_entry_over :
    clears_wall_vertically held_a_peak_y ->
    ordinary_held_a_wall_avoiding_entry
| held_a_entry_east : forall inherited_forward_vel lengths x z,
    capped_held_a_qstep_budget inherited_forward_vel lengths ->
    reaches_east_clearance x z ->
    squared_horizontal_displacement warp_east_x corrected_warp_z x z <=
      sum_z lengths * sum_z lengths ->
    ordinary_held_a_wall_avoiding_entry
| held_a_entry_west : forall inherited_forward_vel lengths x z,
    capped_held_a_qstep_budget inherited_forward_vel lengths ->
    reaches_west_clearance x ->
    squared_horizontal_displacement warp_west_x corrected_warp_z x z <=
      sum_z lengths * sum_z lengths ->
    ordinary_held_a_wall_avoiding_entry.

Lemma held_a_peak_cannot_clear_y1280_wall :
  ~ clears_wall_vertically held_a_peak_y.
Proof.
  unfold held_a_peak_y, held_a_surface_y,
    held_a_positive_vertical_steps.
  exact no_a_peak_cannot_clear_y1280_wall.
Qed.

Lemma held_a_east_clearance_exceeds_455 :
  forall inherited_forward_vel lengths x z,
    capped_held_a_qstep_budget inherited_forward_vel lengths ->
    reaches_east_clearance x z ->
    ~ squared_horizontal_displacement warp_east_x corrected_warp_z x z <=
        sum_z lengths * sum_z lengths.
Proof.
  intros inherited_forward_vel lengths x z Hbudget [Hx Hz] Hchord.
  pose proof (capped_held_a_qstep_budget_at_most_455
    inherited_forward_vel lengths Hbudget)
    as [Hsum_nonnegative Hsum_upper].
  unfold reaches_east_clearance, east_clearance_x,
    y1280_wall_east_x, mario_wall_radius,
    east_clearance_z, y1280_east_wall_north_z,
    squared_horizontal_displacement, warp_east_x, corrected_warp_z,
    held_a_path_length_max, held_a_eligible_qsteps,
    held_a_qstep_distance_max in *.
  assert (Hdx : 63 <= x - 192) by lia.
  assert (Hdz : 537 <= z - (-1024)).
  { change (-487 <= z) in Hz.
    change (537 <= z + 1024).
    clear Hbudget Hchord Hsum_nonnegative Hsum_upper Hx Hdx
      inherited_forward_vel lengths x.
    lia. }
  assert (Hdistance :
      63 * 63 + 537 * 537 <=
      (x - 192) * (x - 192) +
      (z - (-1024)) * (z - (-1024))) by nia.
  change (0 <= sum_z lengths) in Hsum_nonnegative.
  change (sum_z lengths <= 455) in Hsum_upper.
  assert (Hrequired :
      63 * 63 + 537 * 537 <= sum_z lengths * sum_z lengths).
  { eapply Z.le_trans; [exact Hdistance | exact Hchord]. }
  assert (Havailable :
      sum_z lengths * sum_z lengths <= 455 * 455) by nia.
  lia.
Qed.

Lemma held_a_west_clearance_exceeds_455 :
  forall inherited_forward_vel lengths x z,
    capped_held_a_qstep_budget inherited_forward_vel lengths ->
    reaches_west_clearance x ->
    ~ squared_horizontal_displacement warp_west_x corrected_warp_z x z <=
        sum_z lengths * sum_z lengths.
Proof.
  intros inherited_forward_vel lengths x z Hbudget Hx Hchord.
  pose proof (capped_held_a_qstep_budget_at_most_455
    inherited_forward_vel lengths Hbudget)
    as [Hsum_nonnegative Hsum_upper].
  unfold reaches_west_clearance, west_clearance_x,
    y1280_south_wall_west_x, mario_wall_radius,
    squared_horizontal_displacement, warp_west_x, corrected_warp_z,
    held_a_path_length_max, held_a_eligible_qsteps,
    held_a_qstep_distance_max in *.
  assert (Hdx : x - (-191) <= -2060) by lia.
  pose proof (Z.square_nonneg (z - (-1024))) as Hzsquare.
  assert (Hdistance :
      2060 * 2060 <=
      (x - (-191)) * (x - (-191)) +
      (z - (-1024)) * (z - (-1024))) by nia.
  change (0 <= sum_z lengths) in Hsum_nonnegative.
  change (sum_z lengths <= 455) in Hsum_upper.
  assert (Hrequired :
      2060 * 2060 <= sum_z lengths * sum_z lengths).
  { eapply Z.le_trans; [exact Hdistance | exact Hchord]. }
  assert (Havailable :
      sum_z lengths * sum_z lengths <= 455 * 455) by nia.
  lia.
Qed.

Theorem no_ordinary_capped_held_a_wall_avoiding_y1280_entry :
  ~ ordinary_held_a_wall_avoiding_entry.
Proof.
  intros Hentry.
  destruct Hentry as
      [Hover
      | inherited_forward_vel lengths x z Hbudget Hclear Hchord
      | inherited_forward_vel lengths x z Hbudget Hclear Hchord].
  - exact (held_a_peak_cannot_clear_y1280_wall Hover).
  - exact (held_a_east_clearance_exceeds_455
      inherited_forward_vel lengths x z Hbudget Hclear Hchord).
  - exact (held_a_west_clearance_exceeds_455
      inherited_forward_vel lengths x z Hbudget Hclear Hchord).
Qed.

(** Optional tighter submodel for a jump kick whose stationary predecessor
    supplies zero inherited forward speed.  It assumes a conservative
    four-unit bound for each of the same 35 quarter-steps.  The arithmetic
    result is useful, but this file does not prove from Clight that every
    original-game stationary predecessor establishes this budget. *)
Definition stationary_predecessor_qstep_distance_max : Z := 4.
Definition stationary_predecessor_path_length_max : Z :=
  held_a_eligible_qsteps * stationary_predecessor_qstep_distance_max.

Definition stationary_predecessor_qstep_budget (lengths : list Z) : Prop :=
  Forall
    (fun distance =>
      0 <= distance <= stationary_predecessor_qstep_distance_max)
    lengths /\
  Z.of_nat (length lengths) <= held_a_eligible_qsteps.

Lemma stationary_predecessor_path_budget_value :
  stationary_predecessor_path_length_max = 140.
Proof. reflexivity. Qed.

Lemma stationary_predecessor_budget_refines_capped_budget : forall lengths,
  stationary_predecessor_qstep_budget lengths ->
  capped_held_a_qstep_budget 0 lengths.
Proof.
  intros lengths [Hsteps Hcount].
  unfold capped_held_a_qstep_budget,
    inherited_forward_speed_within_48,
    held_a_inherited_forward_speed_limit.
  split; [cbn; lia |].
  split; [| exact Hcount].
  unfold stationary_predecessor_qstep_distance_max in Hsteps.
  unfold held_a_qstep_distance_max.
  clear Hcount.
  induction Hsteps as [| distance rest Hdistance Hrest IH].
  - constructor.
  - constructor; [lia | exact IH].
Qed.

Lemma stationary_predecessor_budget_at_most_140 : forall lengths,
  stationary_predecessor_qstep_budget lengths ->
  0 <= sum_z lengths <= stationary_predecessor_path_length_max.
Proof.
  intros lengths [Hsteps Hcount].
  unfold stationary_predecessor_qstep_distance_max in Hsteps.
  assert (Hbounded :
      0 <= sum_z lengths /\
      sum_z lengths <= Z.of_nat (length lengths) * 4).
  { clear Hcount.
    induction Hsteps as [| distance rest Hdistance Hrest IH]; cbn.
    - split; lia.
    - destruct Hdistance as [Hnonnegative Hupper].
      destruct IH as [IHnonnegative IHupper].
      split; lia. }
  destruct Hbounded as [Hnonnegative Hsum].
  unfold stationary_predecessor_path_length_max,
    held_a_eligible_qsteps,
    stationary_predecessor_qstep_distance_max.
  split; [exact Hnonnegative |].
  change (sum_z lengths <= 140).
  eapply Z.le_trans; [exact Hsum |].
  replace 140 with (35 * 4) by reflexivity.
  apply Z.mul_le_mono_nonneg_r; [lia | exact Hcount].
Qed.

Definition ordinary_capped_held_a_wall_verdict : Prop :=
  generated_jump_kick_vertical_shape /\
  continuously_held_a held_a_schedule /\
  (forall frame, ~ a_press_edge held_a_schedule frame) /\
  held_a_surface_y = 1179 /\
  held_a_initial_vertical_velocity = 20 /\
  held_a_peak_y = 1239 /\
  held_a_eligible_qsteps = 35 /\
  held_a_inherited_forward_speed_limit = 48 /\
  held_a_qstep_distance_max = 13 /\
  held_a_path_length_max = 455 /\
  ~ clears_wall_vertically held_a_peak_y /\
  ~ ordinary_held_a_wall_avoiding_entry /\
  stationary_predecessor_path_length_max = 140.

Theorem ordinary_capped_held_a_wall_verdict_holds :
  ordinary_capped_held_a_wall_verdict.
Proof.
  unfold ordinary_capped_held_a_wall_verdict.
  refine (conj generated_jump_kick_vertical_shape_holds _).
  refine (conj held_a_schedule_is_continuously_held _).
  refine (conj held_a_schedule_has_no_fresh_press_edge _).
  refine (conj (proj1 held_a_vertical_trajectory_values) _).
  refine (conj (proj1 (proj2 held_a_vertical_trajectory_values)) _).
  refine (conj
    (proj1 (proj2 (proj2 (proj2 held_a_vertical_trajectory_values)))) _).
  refine (conj
    (proj2 (proj2 (proj2 (proj2 held_a_vertical_trajectory_values)))) _).
  refine (conj eq_refl _).
  refine (conj (proj1 held_a_path_budget_values) _).
  refine (conj (proj2 held_a_path_budget_values) _).
  refine (conj held_a_peak_cannot_clear_y1280_wall _).
  refine (conj no_ordinary_capped_held_a_wall_avoiding_y1280_entry _).
  exact stationary_predecessor_path_budget_value.
Qed.
