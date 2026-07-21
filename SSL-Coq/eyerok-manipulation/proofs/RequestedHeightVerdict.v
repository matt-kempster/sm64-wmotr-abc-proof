From Coq Require Import Lia ZArith.
From SSLEyerok.Proofs Require Import Area2Route FirstHandBarrier
  HeightMilestones LowerArea2Entry NoA1280Barrier RouteModel Spec
  TwoHandBarrier.

Local Open Scope Z_scope.

(** This file packages three deliberately different proof scopes.  It does
    not turn any of them into an unqualified theorem about every execution of
    the original game:

    - [source_shaped_requested_height_verdict] concerns the finite
      source-shaped barrier relations;
    - [conditional_fresh_a_modeled_landing_verdict] is an arithmetic route
      witness whose Y=1809 departure has not been proved authentically
      reachable; and
    - [ordinary_seam_free_no_a_wall_verdict] excludes only the ordinary,
      seam-free, speed-at-most-48 wall-avoiding class from [NoA1280Barrier].

    The observation relations below are intentionally field-specific.  Hand
    origins, transformed hand surfaces, Mario Y, and a floor-query Y are not
    interchangeable observations. *)

Definition observes_first_hand_surface
    (state : first_hand_barrier_state) (observation : height_observation)
    : Prop :=
  observed_first_hand_surface_y observation =
    Some (first_barrier_y state + hand_collision_top_max).

Definition observes_second_hand_origin
    (state : second_hand_barrier_state) (observation : height_observation)
    : Prop :=
  observed_second_hand_origin_y observation = second_barrier_y state.

Definition observes_second_hand_surface
    (state : second_hand_barrier_state) (observation : height_observation)
    : Prop :=
  observed_second_hand_surface_y observation =
    Some (second_barrier_y state + hand_collision_top_max).

Definition observes_modeled_mario_peak
    (state : second_hand_barrier_state) (observation : height_observation)
    : Prop :=
  observed_mario_y observation =
    second_barrier_y state + hand_collision_top_max +
      mario_triple_jump_rise_max.

(** This is a floor-query observation, not another name for Mario reaching
    Y=1967.  The Area 2 floor at Y=1967 accepts only query points no more than
    78 units below it. *)
Definition queries_area2_floor_y1967
    (observation : height_observation) : Prop :=
  observed_area_of observation = ObservedArea2 /\
  floor_query_eligible (observed_mario_y observation) 1967.

Theorem source_shaped_first_surface_1179_impossible :
  forall state observation,
    first_hand_barrier_reachable state ->
    observes_first_hand_surface state observation ->
    ~ reaches_first_surface_1179 observation.
Proof.
  intros state observation Hreachable Hobservation.
  unfold reaches_first_surface_1179, optional_height_at_least.
  unfold observes_first_hand_surface in Hobservation.
  rewrite Hobservation.
  intros [surface_y [Hsurface Hthreshold]].
  inversion Hsurface; subst surface_y.
  pose proof (first_hand_cannot_reach_legacy_surface_1179
    state Hreachable) as Hbelow.
  lia.
Qed.

Theorem source_shaped_second_origin_1467_impossible :
  forall state observation,
    second_hand_barrier_reachable state ->
    observes_second_hand_origin state observation ->
    ~ reaches_second_origin_1467 observation.
Proof.
  intros state observation Hreachable Hobservation.
  unfold reaches_second_origin_1467, observes_second_hand_origin.
  rewrite Hobservation.
  pose proof (second_hand_cannot_reach_legacy_origin_1467
    state Hreachable) as Hbelow.
  lia.
Qed.

Theorem source_shaped_second_surface_1974_impossible :
  forall state observation,
    second_hand_barrier_reachable state ->
    observes_second_hand_surface state observation ->
    ~ reaches_second_surface_1974 observation.
Proof.
  intros state observation Hreachable Hobservation.
  unfold reaches_second_surface_1974, optional_height_at_least.
  unfold observes_second_hand_surface in Hobservation.
  rewrite Hobservation.
  intros [surface_y [Hsurface Hthreshold]].
  inversion Hsurface; subst surface_y.
  pose proof (second_hand_cannot_reach_legacy_surface_1974
    state Hreachable) as Hbelow.
  lia.
Qed.

Theorem source_shaped_mario_y2604_impossible :
  forall state observation,
    second_hand_barrier_reachable state ->
    observes_modeled_mario_peak state observation ->
    ~ reaches_mario_y_2604 observation.
Proof.
  intros state observation Hreachable Hobservation.
  unfold reaches_mario_y_2604, observes_modeled_mario_peak.
  rewrite Hobservation.
  pose proof (modeled_mario_cannot_reach_legacy_peak_2604
    state Hreachable) as Hbelow.
  lia.
Qed.

Theorem source_shaped_area2_y1967_query_impossible :
  forall state observation,
    second_hand_barrier_reachable state ->
    observes_modeled_mario_peak state observation ->
    ~ queries_area2_floor_y1967 observation.
Proof.
  intros state observation Hreachable Hobservation
    [_ Hquery_eligible].
  unfold observes_modeled_mario_peak in Hobservation.
  rewrite Hobservation in Hquery_eligible.
  pose proof (modeled_mario_cannot_query_area2_y1967
    state Hreachable) as Hbelow_query_minimum.
  unfold floor_query_eligible, area2_y1967_query_min in *.
  lia.
Qed.

Definition source_shaped_requested_height_verdict : Prop :=
  (forall state observation,
    first_hand_barrier_reachable state ->
    observes_first_hand_surface state observation ->
    ~ reaches_first_surface_1179 observation) /\
  (forall state observation,
    second_hand_barrier_reachable state ->
    observes_second_hand_origin state observation ->
    ~ reaches_second_origin_1467 observation) /\
  (forall state observation,
    second_hand_barrier_reachable state ->
    observes_second_hand_surface state observation ->
    ~ reaches_second_surface_1974 observation) /\
  (forall state observation,
    second_hand_barrier_reachable state ->
    observes_modeled_mario_peak state observation ->
    ~ reaches_mario_y_2604 observation) /\
  (forall state observation,
    second_hand_barrier_reachable state ->
    observes_modeled_mario_peak state observation ->
    ~ queries_area2_floor_y1967 observation).

Theorem source_shaped_requested_height_verdict_holds :
  source_shaped_requested_height_verdict.
Proof.
  unfold source_shaped_requested_height_verdict.
  repeat split.
  - exact source_shaped_first_surface_1179_impossible.
  - exact source_shaped_second_origin_1467_impossible.
  - exact source_shaped_second_surface_1974_impossible.
  - exact source_shaped_mario_y2604_impossible.
  - exact source_shaped_area2_y1967_query_impossible.
Qed.

(** [press_and_hold_from_start] supplies one fresh A edge.  The route theorem
    below merely records that edge beside the already proved modeled route;
    it does not claim that the edge causes the modeled triple jump, nor that
    the route's Y=1809 Area 3 departure is authentically reachable. *)
Definition conditional_fresh_a_modeled_landing_verdict : Prop :=
  a_press_edge press_and_hold_from_start O /\
  route_y conditional_lower_area3_entry =
    second_hand_modeled_mario_peak /\
  in_area3_warp_footprint conditional_lower_area3_entry /\
  instant_warp_step conditional_lower_area3_entry
    conditional_lower_area2_arrival /\
  selected_mid1280_landing_step
    conditional_lower_after_16 conditional_lower_landing /\
  route_area conditional_lower_landing = Area2 /\
  route_y conditional_lower_landing = 1280 /\
  route_floor_of conditional_lower_landing = Area2Mid1280.

Theorem conditional_fresh_a_modeled_landing_verdict_holds :
  conditional_fresh_a_modeled_landing_verdict.
Proof.
  unfold conditional_fresh_a_modeled_landing_verdict.
  refine (conj (proj1 press_and_hold_has_one_fresh_edge) _).
  refine (conj eq_refl _).
  refine (conj conditional_lower_entry_is_in_warp_footprint _).
  refine (conj conditional_lower_entry_warps_to_area2 _).
  refine (conj conditional_lower_first_qstep_lands_on_y1280 _).
  refine (conj (proj1 conditional_lower_landing_values) _).
  refine (conj
    (proj1 (proj2 (proj2 conditional_lower_landing_values))) _).
  exact (proj1 (proj2 (proj2 (proj2 (proj2
    conditional_lower_landing_values))))).
Qed.

(** This certificate retains all of the no-A theorem's restrictions: the
    modeled B-only departure begins at Y=1179, horizontal speed is at most 48,
    every eligible quarter-step is bounded by 12 units, and the route class
    omits seam misses and other collision glitches. *)
Definition ordinary_seam_free_no_a_wall_verdict : Prop :=
  no_a_surface_y = 1179 /\
  no_a_horizontal_speed_max = 48 /\
  no_a_qstep_distance_max = 12 /\
  no_a_path_length_max = 420 /\
  ~ clears_wall_vertically no_a_peak_y /\
  ~ ordinary_no_a_wall_avoiding_entry.

Theorem ordinary_seam_free_no_a_wall_verdict_holds :
  ordinary_seam_free_no_a_wall_verdict.
Proof.
  unfold ordinary_seam_free_no_a_wall_verdict.
  refine (conj (proj1 no_a_speed_kick_values) _).
  refine (conj eq_refl _).
  refine (conj (proj1 no_a_path_budget_values) _).
  refine (conj (proj2 no_a_path_budget_values) _).
  refine (conj no_a_peak_cannot_clear_y1280_wall _).
  exact no_ordinary_no_a_wall_avoiding_y1280_entry.
Qed.

Record requested_height_verdict_package : Prop := {
  requested_source_shaped_scope :
    source_shaped_requested_height_verdict;
  requested_conditional_fresh_a_scope :
    conditional_fresh_a_modeled_landing_verdict;
  requested_ordinary_seam_free_no_a_scope :
    ordinary_seam_free_no_a_wall_verdict
}.

Theorem requested_height_verdict_package_holds :
  requested_height_verdict_package.
Proof.
  constructor.
  - exact source_shaped_requested_height_verdict_holds.
  - exact conditional_fresh_a_modeled_landing_verdict_holds.
  - exact ordinary_seam_free_no_a_wall_verdict_holds.
Qed.
