From Coq Require Import Lia List ZArith.

Import ListNotations.
Local Open Scope Z_scope.

(** A Pedro landing needs a selected floor and ceiling separated by at least
    two units and at most the retail 160-unit clearance cutoff.  This file
    deliberately separates raw mesh geometry from Mario's ability to enter it
    after the two radius-50 wall-resolution calls. *)
Definition pedro_clearance (floor_y ceiling_y : Z) : Prop :=
  2 <= ceiling_y - floor_y <= 160.

Definition sleep_floor_y : Z := -1459.
Definition sleep_ceiling_y : Z := -1421.
Definition sleep_query_min : Z := -1537.
Definition sleep_query_max : Z := -1500.

Definition sleep_strip_point (x z query_y : Z) : Prop :=
  x = 254 /\ -3243 <= z <= -3166 /\
  sleep_query_min <= query_y <= sleep_query_max.

Lemma sleeping_hand_has_raw_pedro_clearance :
  pedro_clearance sleep_floor_y sleep_ceiling_y.
Proof. unfold pedro_clearance, sleep_floor_y, sleep_ceiling_y; lia. Qed.

Lemma sleeping_hand_arena_query_selects_lower_candidate :
  sleep_query_min <= -1534 <= sleep_query_max.
Proof. unfold sleep_query_min, sleep_query_max; lia. Qed.

(** The exterior wall leaves Mario at or outside Z=-3116.  The half of the
    strip that survives both wall calls at useful airborne heights is strictly
    inside Z=-3216. *)
Definition sleep_exterior (z : Z) : Prop := -3116 <= z.
Definition sleep_wall_free_interior (z : Z) : Prop := z < -3216.
Definition inward_qstep (start_z target_z : Z) : Z := start_z - target_z.

Lemma sleeping_strip_entry_requires_over_100_units :
  forall start_z target_z,
    sleep_exterior start_z ->
    sleep_wall_free_interior target_z ->
    100 < inward_qstep start_z target_z.
Proof.
  intros start_z target_z Hstart Htarget.
  unfold sleep_exterior, sleep_wall_free_interior, inward_qstep in *.
  lia.
Qed.

Theorem ordinary_qstep_cannot_enter_sleeping_strip :
  forall start_z target_z,
    sleep_exterior start_z ->
    sleep_wall_free_interior target_z ->
    inward_qstep start_z target_z <= 13 -> False.
Proof.
  intros start_z target_z Hstart Htarget Hordinary.
  pose proof (sleeping_strip_entry_requires_over_100_units
    start_z target_z Hstart Htarget).
  lia.
Qed.

(** This is the local high-speed witness exercised by the US-ROM probe.  It
    is a counterexample to unconditional entry impossibility, not a proof that
    ordinary controller input can first obtain that speed. *)
Lemma preloaded_speed_fixture_crosses_wall_band :
  sleep_exterior (-3115) /\
  sleep_wall_free_interior (-3221) /\
  inward_qstep (-3115) (-3221) = 106.
Proof. unfold sleep_exterior, sleep_wall_free_interior, inward_qstep; lia. Qed.

(** During the one-time wake animation the two sleeping collision meshes have
    a genuine floor/ceiling overlap for exactly these seven audited updates.
    The following update has gap 162 and no longer takes the Pedro branch. *)
Definition wake_pedro_gaps : list Z := [16; 39; 63; 84; 105; 126; 144].

Lemma wake_pedro_gaps_are_valid :
  Forall (fun gap => 2 <= gap <= 160) wake_pedro_gaps.
Proof. unfold wake_pedro_gaps; repeat constructor; lia. Qed.

Lemma wake_pedro_window_length : length wake_pedro_gaps = 7%nat.
Proof. reflexivity. Qed.

Lemma wake_next_gap_closes_window : ~ (2 <= 162 <= 160).
Proof. lia. Qed.

Definition wake_height_pairs : list (Z * Z) :=
  [(-1357, -1341); (-1344, -1305); (-1332, -1269);
   (-1319, -1235); (-1307, -1202); (-1295, -1169);
   (-1284, -1140)].

Definition wake_wall_free_points : list (Z * Z) :=
  [(33, -3406); (47, -3383); (61, -3377); (79, -3385);
   (97, -3396); (115, -3401); (130, -3391)].

Lemma wake_height_pairs_have_audited_gaps :
  map (fun pair => snd pair - fst pair) wake_height_pairs = wake_pedro_gaps.
Proof. reflexivity. Qed.

Lemma wake_wall_free_witness_count : length wake_wall_free_points = 7%nat.
Proof. reflexivity. Qed.

(** Frames 5--10 have no vertical lane that rejects both hands' walls.  Such
    a lane requires gap >130.  Frame 11 has gap 144 and therefore is a real
    exception to a blanket wall-blocking claim. *)
Lemma early_wake_gaps_have_no_vertical_wall_bypass :
  forall gap floor_y mario_y,
    gap <= 126 ->
    floor_y - 25 < mario_y ->
    mario_y <= floor_y + gap - 156 -> False.
Proof. intros; lia. Qed.

Definition wake_frame11_floor : Z := -1284.
Definition wake_frame11_ceiling : Z := -1140.
Definition wake_frame11_query_y : Z := -1304.
Definition wake_frame11_start : Z * Z := (-121, -3240).
Definition wake_frame11_target : Z * Z := (-121, -3241).

Lemma wake_frame11_has_vertical_wall_bypass :
  wake_frame11_floor - 25 < wake_frame11_query_y /\
  wake_frame11_query_y <= wake_frame11_floor + 144 - 156 /\
  wake_frame11_floor - 78 <= wake_frame11_query_y <= wake_frame11_floor.
Proof.
  unfold wake_frame11_floor, wake_frame11_query_y.
  lia.
Qed.

Lemma wake_frame11_ordinary_qstep_witness :
  snd wake_frame11_target - snd wake_frame11_start = -1 /\
  fst wake_frame11_target - fst wake_frame11_start = 0 /\
  0 * 0 + (-1) * (-1) = 1.
Proof.
  unfold wake_frame11_start, wake_frame11_target; simpl; lia.
Qed.

Record collision_state : Type := {
  collision_x : Z;
  collision_y : Z;
  collision_z : Z;
  referenced_floor_y : Z
}.

(** A [collision_query] records the facts that the retail quarter-step obtains
    after its two wall-resolution calls.  In particular, [query_post_wall_*]
    are the coordinates actually passed to [find_floor] and
    [vec3f_find_ceil], not merely Mario's intended coordinates.

    This is an explicit refinement boundary: constructing such a record does
    not prove that an original-game execution produced it.  The source audit
    or an instrumented trace must separately justify the selected surfaces
    and the four booleans. *)
Record collision_query : Type := {
  query_intended_x : Z;
  query_intended_y : Z;
  query_intended_z : Z;
  query_post_wall_x : Z;
  query_post_wall_y : Z;
  query_post_wall_z : Z;
  query_upper_wall_clear : bool;
  query_lower_wall_clear : bool;
  query_floor_found : bool;
  query_ceiling_found : bool;
  query_selected_floor_y : Z;
  query_selected_ceiling_y : Z
}.

Definition walls_preserve_intended_position (query : collision_query) : Prop :=
  query_upper_wall_clear query = true /\
  query_lower_wall_clear query = true /\
  query_post_wall_x query = query_intended_x query /\
  query_post_wall_y query = query_intended_y query /\
  query_post_wall_z query = query_intended_z query.

Definition pedro_query_ready (query : collision_query) : Prop :=
  query_floor_found query = true /\
  query_ceiling_found query = true /\
  walls_preserve_intended_position query /\
  query_post_wall_y query <= query_selected_floor_y query /\
  pedro_clearance
    (query_selected_floor_y query) (query_selected_ceiling_y query).

Definition apply_audited_quarter_step
    (old : collision_state) (query : collision_query) : collision_state :=
  if (query_floor_found query &&
      Z.leb (query_post_wall_y query) (query_selected_floor_y query) &&
      Z.leb
        (query_selected_ceiling_y query - query_selected_floor_y query) 160)%bool
  then
    {| collision_x := collision_x old;
       collision_y := query_selected_floor_y query;
       collision_z := collision_z old;
       referenced_floor_y := referenced_floor_y old |}
  else
    {| collision_x := query_post_wall_x query;
       collision_y := query_post_wall_y query;
       collision_z := query_post_wall_z query;
       referenced_floor_y := query_selected_floor_y query |}.

Lemma ready_pedro_query_cancels_horizontal_step :
  forall old query,
    pedro_query_ready query ->
    apply_audited_quarter_step old query =
      {| collision_x := collision_x old;
         collision_y := query_selected_floor_y query;
         collision_z := collision_z old;
         referenced_floor_y := referenced_floor_y old |}.
Proof.
  intros old query
    [Hfloor [_ [_ [Hbelow [_ Hgap]]]]].
  unfold apply_audited_quarter_step.
  rewrite Hfloor.
  rewrite (proj2 (Z.leb_le _ _) Hbelow).
  rewrite (proj2 (Z.leb_le _ _) Hgap).
  reflexivity.
Qed.

Definition wake_frame11_old_state : collision_state :=
  {| collision_x := -121;
     collision_y := -1304;
     collision_z := -3240;
     referenced_floor_y := -1534 |}.

Definition wake_frame11_query : collision_query :=
  {| query_intended_x := -121;
     query_intended_y := -1304;
     query_intended_z := -3241;
     query_post_wall_x := -121;
     query_post_wall_y := -1304;
     query_post_wall_z := -3241;
     query_upper_wall_clear := true;
     query_lower_wall_clear := true;
     query_floor_found := true;
     query_ceiling_found := true;
     query_selected_floor_y := wake_frame11_floor;
     query_selected_ceiling_y := wake_frame11_ceiling |}.

Lemma wake_frame11_query_is_locally_ready :
  pedro_query_ready wake_frame11_query.
Proof.
  unfold pedro_query_ready, walls_preserve_intended_position,
    wake_frame11_query, wake_frame11_floor, wake_frame11_ceiling,
    pedro_clearance.
  simpl; lia.
Qed.

(** This theorem is conditional on the concrete query record above.  It says
    what the quarter-step does if the source wall/floor/ceiling searches return
    those audited values; it is not a controller-reachability theorem. *)
Theorem wake_frame_11_pedro_quarter_step :
  apply_audited_quarter_step wake_frame11_old_state wake_frame11_query =
  {| collision_x := -121;
     collision_y := -1284;
     collision_z := -3240;
     referenced_floor_y := -1534 |}.
Proof.
  apply ready_pedro_query_cancels_horizontal_step.
  exact wake_frame11_query_is_locally_ready.
Qed.

(** The first wake query window starts 99 units above the Y=-1534 arena.
    Therefore the direct 60-unit B-only speed kick and held-A jump kick do not
    by themselves reach it.  This does not exclude boarding a hand first or
    carrying in another airborne state. *)
Lemma direct_sixty_unit_rise_misses_first_wake_window :
  -1534 + 60 < -1435.
Proof. lia. Qed.

(** [update_air_without_turn] is piecewise.  Speeds and gains are represented
    in hundredths of a world unit:

    - a negative [forwardVel] can move 0.35 toward zero, receive at most 1.50
      from analog input, and then receive the 2.00 negative-speed correction;
    - a value in [0,0.35) can be clamped to zero before the 1.50 input;
    - a value at least 0.35 loses 0.35 before receiving at most 1.50.  The
      positive-speed drag can only reduce the result further.

    Thus 3.85 is the exact global per-update envelope in this ideal decimal
    arithmetic model, 1.50 is valid when the incoming speed is nonnegative,
    and 1.15 needs the explicit [forwardVel >= 0.35] precondition.

    The [ideal_air_*] definitions intentionally do not model binary32 values,
    operations, or rounding.  They are an ideal-arithmetic abstraction shaped
    like the audited C branches, not an IEEE-754 or Clight refinement.  The
    rounded-up 4.00/28.00 consequences below remain theorems about this same
    abstraction; connecting even those conservative figures to retail f32
    execution requires a separate floating-point refinement. *)
Definition ideal_air_gain_bound (speed_before : Z) : Z :=
  if speed_before <? 0 then 385
  else if speed_before <? 35 then 150
  else 115.

Definition ideal_air_speed_step
    (speed_before speed_after : Z) : Prop :=
  speed_after <= speed_before + ideal_air_gain_bound speed_before.

Lemma ideal_air_gain_bound_global :
  forall speed, ideal_air_gain_bound speed <= 385.
Proof.
  intro speed.
  unfold ideal_air_gain_bound.
  destruct (speed <? 0); destruct (speed <? 35); lia.
Qed.

Lemma ideal_air_gain_bound_nonnegative :
  forall speed,
    0 <= speed -> ideal_air_gain_bound speed <= 150.
Proof.
  intros speed Hspeed.
  unfold ideal_air_gain_bound.
  destruct (speed <? 0) eqn:Hnegative.
  - apply Z.ltb_lt in Hnegative; lia.
  - destruct (speed <? 35); lia.
Qed.

Lemma ideal_air_gain_bound_settled_positive :
  forall speed,
    35 <= speed -> ideal_air_gain_bound speed <= 115.
Proof.
  intros speed Hspeed.
  unfold ideal_air_gain_bound.
  destruct (speed <? 0) eqn:Hnegative.
  - apply Z.ltb_lt in Hnegative; lia.
  - destruct (speed <? 35) eqn:Hsmall.
    + apply Z.ltb_lt in Hsmall; lia.
    + lia.
Qed.

Lemma ideal_air_speed_step_global_gain :
  forall speed_before speed_after,
    ideal_air_speed_step speed_before speed_after ->
    speed_after <= speed_before + 385.
Proof.
  intros speed_before speed_after Hstep.
  unfold ideal_air_speed_step in Hstep.
  pose proof (ideal_air_gain_bound_global speed_before).
  lia.
Qed.

Lemma ideal_air_speed_step_nonnegative_gain :
  forall speed_before speed_after,
    0 <= speed_before ->
    ideal_air_speed_step speed_before speed_after ->
    speed_after <= speed_before + 150.
Proof.
  intros speed_before speed_after Hnonnegative Hstep.
  unfold ideal_air_speed_step in Hstep.
  pose proof
    (ideal_air_gain_bound_nonnegative speed_before Hnonnegative).
  lia.
Qed.

Lemma ideal_air_speed_step_settled_positive_gain :
  forall speed_before speed_after,
    35 <= speed_before ->
    ideal_air_speed_step speed_before speed_after ->
    speed_after <= speed_before + 115.
Proof.
  intros speed_before speed_after Hpositive Hstep.
  unfold ideal_air_speed_step in Hstep.
  pose proof
    (ideal_air_gain_bound_settled_positive speed_before Hpositive).
  lia.
Qed.

(** Unlike the previous aggregate premise, this trace requires one ideal
    source-shaped step for every represented air update. *)
Inductive ideal_air_speed_trace : Z -> nat -> Z -> Prop :=
| AirSpeedTraceZero :
    forall speed, ideal_air_speed_trace speed O speed
| AirSpeedTraceStep :
    forall speed_before speed_next frames speed_after,
      ideal_air_speed_step speed_before speed_next ->
      ideal_air_speed_trace speed_next frames speed_after ->
      ideal_air_speed_trace speed_before (S frames) speed_after.

Lemma ideal_air_speed_trace_global_gain :
  forall speed_before frames speed_after,
    ideal_air_speed_trace speed_before frames speed_after ->
    speed_after <= speed_before + 385 * Z.of_nat frames.
Proof.
  intros speed_before frames speed_after Htrace.
  induction Htrace as
    [speed | speed_before speed_next frames speed_after Hstep _ IH].
  - simpl; lia.
  - rewrite Nat2Z.inj_succ.
    pose proof
      (ideal_air_speed_step_global_gain speed_before speed_next Hstep).
    lia.
Qed.

(** These variants record the extra invariant needed to use the tighter
    source bounds on every frame, rather than silently assuming it. *)
Inductive ideal_nonnegative_air_speed_trace : Z -> nat -> Z -> Prop :=
| NonnegativeAirSpeedTraceZero :
    forall speed,
      0 <= speed ->
      ideal_nonnegative_air_speed_trace speed O speed
| NonnegativeAirSpeedTraceStep :
    forall speed_before speed_next frames speed_after,
      0 <= speed_before ->
      ideal_air_speed_step speed_before speed_next ->
      ideal_nonnegative_air_speed_trace speed_next frames speed_after ->
      ideal_nonnegative_air_speed_trace speed_before (S frames) speed_after.

Lemma ideal_nonnegative_air_speed_trace_gain :
  forall speed_before frames speed_after,
    ideal_nonnegative_air_speed_trace speed_before frames speed_after ->
    speed_after <= speed_before + 150 * Z.of_nat frames.
Proof.
  intros speed_before frames speed_after Htrace.
  induction Htrace as
    [speed Hnonnegative |
     speed_before speed_next frames speed_after
       Hnonnegative Hstep _ IH].
  - simpl; lia.
  - rewrite Nat2Z.inj_succ.
    pose proof
      (ideal_air_speed_step_nonnegative_gain
        speed_before speed_next Hnonnegative Hstep).
    lia.
Qed.

Inductive ideal_settled_positive_air_speed_trace : Z -> nat -> Z -> Prop :=
| SettledPositiveAirSpeedTraceZero :
    forall speed,
      35 <= speed ->
      ideal_settled_positive_air_speed_trace speed O speed
| SettledPositiveAirSpeedTraceStep :
    forall speed_before speed_next frames speed_after,
      35 <= speed_before ->
      ideal_air_speed_step speed_before speed_next ->
      ideal_settled_positive_air_speed_trace speed_next frames speed_after ->
      ideal_settled_positive_air_speed_trace speed_before (S frames) speed_after.

Lemma ideal_settled_positive_air_speed_trace_gain :
  forall speed_before frames speed_after,
    ideal_settled_positive_air_speed_trace speed_before frames speed_after ->
    speed_after <= speed_before + 115 * Z.of_nat frames.
Proof.
  intros speed_before frames speed_after Htrace.
  induction Htrace as
    [speed Hpositive |
     speed_before speed_next frames speed_after Hpositive Hstep _ IH].
  - simpl; lia.
  - rewrite Nat2Z.inj_succ.
    pose proof
      (ideal_air_speed_step_settled_positive_gain
        speed_before speed_next Hpositive Hstep).
    lia.
Qed.

Definition wake_window_frames : nat := 7%nat.

Theorem wake_pedro_window_ideal_gain_at_most_2695 :
  forall speed_before speed_after,
    ideal_air_speed_trace
      speed_before wake_window_frames speed_after ->
    speed_after <= speed_before + 2695.
Proof.
  intros speed_before speed_after Htrace.
  pose proof
    (ideal_air_speed_trace_global_gain
      speed_before wake_window_frames speed_after Htrace).
  unfold wake_window_frames in *; simpl in *; lia.
Qed.

(** Rounded-up reporting bounds for the ideal relation.  These deliberately
    leave 0.15 per call beyond its exact decimal envelope, but are still not
    theorems about binary32 execution. *)
Theorem wake_pedro_window_ideal_conservative_gain_at_most_2800 :
  forall speed_before speed_after,
    ideal_air_speed_trace
      speed_before wake_window_frames speed_after ->
    speed_after <= speed_before + 2800.
Proof.
  intros speed_before speed_after Htrace.
  pose proof
    (wake_pedro_window_ideal_gain_at_most_2695
      speed_before speed_after Htrace).
  lia.
Qed.

Theorem wake_pedro_window_ideal_nonnegative_gain_at_most_1050 :
  forall speed_before speed_after,
    ideal_nonnegative_air_speed_trace
      speed_before wake_window_frames speed_after ->
    speed_after <= speed_before + 1050.
Proof.
  intros speed_before speed_after Htrace.
  pose proof
    (ideal_nonnegative_air_speed_trace_gain
      speed_before wake_window_frames speed_after Htrace).
  unfold wake_window_frames in *; simpl in *; lia.
Qed.

Theorem wake_pedro_window_ideal_settled_gain_at_most_805 :
  forall speed_before speed_after,
    ideal_settled_positive_air_speed_trace
      speed_before wake_window_frames speed_after ->
    speed_after <= speed_before + 805.
Proof.
  intros speed_before speed_after Htrace.
  pose proof
    (ideal_settled_positive_air_speed_trace_gain
      speed_before wake_window_frames speed_after Htrace).
  unfold wake_window_frames in *; simpl in *; lia.
Qed.

(** An entry first achieved on wake update 11 has only this one update before
    update 12's 162-unit gap closes the Pedro condition. *)
Theorem frame11_single_ideal_update_gain_at_most_385 :
  forall speed_before speed_after,
    ideal_air_speed_trace speed_before 1 speed_after ->
    speed_after <= speed_before + 385.
Proof.
  intros speed_before speed_after Htrace.
  pose proof
    (ideal_air_speed_trace_global_gain speed_before 1 speed_after Htrace).
  simpl in *; lia.
Qed.

Theorem frame11_single_ideal_conservative_gain_at_most_400 :
  forall speed_before speed_after,
    ideal_air_speed_trace speed_before 1 speed_after ->
    speed_after <= speed_before + 400.
Proof.
  intros speed_before speed_after Htrace.
  pose proof
    (frame11_single_ideal_update_gain_at_most_385
      speed_before speed_after Htrace).
  lia.
Qed.

Theorem frame11_single_ideal_nonnegative_gain_at_most_150 :
  forall speed_before speed_after,
    ideal_nonnegative_air_speed_trace speed_before 1 speed_after ->
    speed_after <= speed_before + 150.
Proof.
  intros speed_before speed_after Htrace.
  pose proof
    (ideal_nonnegative_air_speed_trace_gain
      speed_before 1 speed_after Htrace).
  simpl in *; lia.
Qed.

Theorem frame11_single_ideal_settled_gain_at_most_115 :
  forall speed_before speed_after,
    ideal_settled_positive_air_speed_trace speed_before 1 speed_after ->
    speed_after <= speed_before + 115.
Proof.
  intros speed_before speed_after Htrace.
  pose proof
    (ideal_settled_positive_air_speed_trace_gain
      speed_before 1 speed_after Htrace).
  simpl in *; lia.
Qed.

(** Ordinary post-wake closed hands cannot form a positive sandwich: the
    lower top is origin+306, the opposite hand's downward underside is at
    most origin+5 after TerrainData casts, and ordinary origin separation is
    at most 300. *)
Definition closed_pair_gap (origin_separation : Z) : Z :=
  origin_separation + 5 - 306.

Lemma ordinary_closed_pair_is_not_pedro :
  forall separation,
    separation <= 300 -> ~ pedro_clearance 0 (closed_pair_gap separation).
Proof.
  intros separation Hseparation.
  unfold pedro_clearance, closed_pair_gap.
  lia.
Qed.

Definition pedro_scenario_certificate : Prop :=
  pedro_clearance sleep_floor_y sleep_ceiling_y /\
  (forall start_z target_z,
      sleep_exterior start_z ->
      sleep_wall_free_interior target_z ->
      inward_qstep start_z target_z <= 13 -> False) /\
  (sleep_exterior (-3115) /\
   sleep_wall_free_interior (-3221) /\
   inward_qstep (-3115) (-3221) = 106) /\
  Forall (fun gap => 2 <= gap <= 160) wake_pedro_gaps /\
  length wake_pedro_gaps = 7%nat /\
  ~ (2 <= 162 <= 160) /\
  map (fun pair => snd pair - fst pair) wake_height_pairs = wake_pedro_gaps /\
  length wake_wall_free_points = 7%nat /\
  (forall gap floor_y mario_y,
      gap <= 126 ->
      floor_y - 25 < mario_y ->
      mario_y <= floor_y + gap - 156 -> False) /\
  (wake_frame11_floor - 25 < wake_frame11_query_y /\
   wake_frame11_query_y <= wake_frame11_floor + 144 - 156 /\
   wake_frame11_floor - 78 <= wake_frame11_query_y <= wake_frame11_floor) /\
  (snd wake_frame11_target - snd wake_frame11_start = -1 /\
   fst wake_frame11_target - fst wake_frame11_start = 0 /\
   0 * 0 + (-1) * (-1) = 1) /\
  pedro_query_ready wake_frame11_query /\
  apply_audited_quarter_step wake_frame11_old_state wake_frame11_query =
    {| collision_x := -121;
       collision_y := -1284;
       collision_z := -3240;
       referenced_floor_y := -1534 |} /\
  -1534 + 60 < -1435 /\
  (forall speed_before speed_after,
      ideal_air_speed_trace
        speed_before wake_window_frames speed_after ->
      speed_after <= speed_before + 2695) /\
  (forall speed_before speed_after,
      ideal_air_speed_trace
        speed_before wake_window_frames speed_after ->
      speed_after <= speed_before + 2800) /\
  (forall speed_before speed_after,
      ideal_nonnegative_air_speed_trace
        speed_before wake_window_frames speed_after ->
      speed_after <= speed_before + 1050) /\
  (forall speed_before speed_after,
      ideal_settled_positive_air_speed_trace
        speed_before wake_window_frames speed_after ->
      speed_after <= speed_before + 805) /\
  (forall speed_before speed_after,
      ideal_air_speed_trace speed_before 1 speed_after ->
      speed_after <= speed_before + 385) /\
  (forall speed_before speed_after,
      ideal_air_speed_trace speed_before 1 speed_after ->
      speed_after <= speed_before + 400) /\
  (forall speed_before speed_after,
      ideal_nonnegative_air_speed_trace speed_before 1 speed_after ->
      speed_after <= speed_before + 150) /\
  (forall speed_before speed_after,
      ideal_settled_positive_air_speed_trace speed_before 1 speed_after ->
      speed_after <= speed_before + 115) /\
  (forall separation,
      separation <= 300 ->
      ~ pedro_clearance 0 (closed_pair_gap separation)).

Theorem pedro_scenario_certificate_holds : pedro_scenario_certificate.
Proof.
  refine (conj sleeping_hand_has_raw_pedro_clearance _).
  refine (conj ordinary_qstep_cannot_enter_sleeping_strip _).
  refine (conj preloaded_speed_fixture_crosses_wall_band _).
  refine (conj wake_pedro_gaps_are_valid _).
  refine (conj wake_pedro_window_length _).
  refine (conj wake_next_gap_closes_window _).
  refine (conj wake_height_pairs_have_audited_gaps _).
  refine (conj wake_wall_free_witness_count _).
  refine (conj early_wake_gaps_have_no_vertical_wall_bypass _).
  refine (conj wake_frame11_has_vertical_wall_bypass _).
  refine (conj wake_frame11_ordinary_qstep_witness _).
  refine (conj wake_frame11_query_is_locally_ready _).
  refine (conj wake_frame_11_pedro_quarter_step _).
  refine (conj direct_sixty_unit_rise_misses_first_wake_window _).
  refine (conj wake_pedro_window_ideal_gain_at_most_2695 _).
  refine (conj wake_pedro_window_ideal_conservative_gain_at_most_2800 _).
  refine (conj wake_pedro_window_ideal_nonnegative_gain_at_most_1050 _).
  refine (conj wake_pedro_window_ideal_settled_gain_at_most_805 _).
  refine (conj frame11_single_ideal_update_gain_at_most_385 _).
  refine (conj frame11_single_ideal_conservative_gain_at_most_400 _).
  refine (conj frame11_single_ideal_nonnegative_gain_at_most_150 _).
  refine (conj frame11_single_ideal_settled_gain_at_most_115 _).
  exact ordinary_closed_pair_is_not_pedro.
Qed.
