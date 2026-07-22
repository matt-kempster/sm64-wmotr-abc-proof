From Coq Require Import Lia ZArith.
From SSLEyerok.Proofs Require Import Area2Route FirstHandBarrier Spec.

Local Open Scope Z_scope.

(** The second-updated hand can see the first hand's dynamic collision.  This
    module grants that contact at every horizontal position and grants the
    tallest open-eye mesh in every phase.  The first-hand barrier still puts
    that dynamic support below the maximum audited static Area 3 floor. *)
Definition second_hand_support_ceiling : Z := area3_upward_floor_y_max.
Definition second_hand_finite_origin_peak : Z :=
  second_hand_support_ceiling + upward_travel_max.
Definition second_hand_open_surface_peak : Z :=
  second_hand_finite_origin_peak + hand_collision_top_max.
Definition second_hand_modeled_mario_peak : Z :=
  second_hand_open_surface_peak + mario_triple_jump_rise_max.
Definition area2_y1967_query_min : Z := 1967 - 78.

Lemma two_hand_barrier_values :
  second_hand_support_ceiling = 384 /\
  second_hand_finite_origin_peak = 672 /\
  second_hand_open_surface_peak = 1179 /\
  second_hand_modeled_mario_peak = 1809 /\
  area2_y1967_query_min = 1889.
Proof. repeat split; reflexivity. Qed.

Lemma first_dynamic_support_below_static_ceiling : forall first floor_y,
  first_hand_barrier_reachable first ->
  floor_y <= first_barrier_y first + hand_collision_top_max ->
  floor_y <= second_hand_support_ceiling.
Proof.
  intros first floor_y Hreach Hfloor.
  pose proof (first_hand_open_surface_bounded first Hreach) as Hsurface.
  unfold second_hand_support_ceiling, area3_upward_floor_y_max,
    first_hand_open_surface_peak, first_hand_finite_origin_peak,
    arena_upward_floor_y_max, upward_travel_max,
    hand_collision_top_max in *.
  lia.
Qed.

Inductive second_hand_barrier_mode : Type :=
| SecondControlled
| SecondBallistic
| SecondDeleted.

Record second_hand_barrier_state : Type := {
  second_barrier_mode : second_hand_barrier_mode;
  second_barrier_y : Z;
  second_barrier_budget : Z
}.

Definition second_hand_barrier_initial : second_hand_barrier_state :=
  {| second_barrier_mode := SecondControlled;
     second_barrier_y := eyerok_home_y;
     second_barrier_budget := 0 |}.

Definition second_hand_barrier_safe (state : second_hand_barrier_state) : Prop :=
  0 <= second_barrier_budget state <= upward_travel_max /\
  second_barrier_y state + second_barrier_budget state <=
    second_hand_finite_origin_peak.

(** This relation over-approximates the second hand by granting every static
    Area 3 upward floor, every first-hand surface below its proved ceiling,
    arbitrary partial-update stuttering, and preservation of unused upward
    budget across a floor snap.  The load-bearing source-refinement premise is
    that a new positive-velocity episode begins from classified support and
    has total remaining rise at most [upward_travel_max].  A linked Clight
    proof of that episode classification remains separate. *)
Inductive second_hand_barrier_step
    : second_hand_barrier_state -> second_hand_barrier_state -> Prop :=
| second_step_direct : forall before target,
    target <= direct_position_y_max ->
    second_hand_barrier_step before
      {| second_barrier_mode := SecondControlled;
         second_barrier_y := target;
         second_barrier_budget := 0 |}
| second_step_static_support : forall before floor_y,
    floor_y <= area3_upward_floor_y_max ->
    second_hand_barrier_step before
      {| second_barrier_mode := second_barrier_mode before;
         second_barrier_y := floor_y;
         second_barrier_budget := second_barrier_budget before |}
| second_step_first_support : forall before first floor_y,
    first_hand_barrier_reachable first ->
    floor_y <= first_barrier_y first + hand_collision_top_max ->
    second_hand_barrier_step before
      {| second_barrier_mode := second_barrier_mode before;
         second_barrier_y := floor_y;
         second_barrier_budget := second_barrier_budget before |}
| second_step_launch : forall before budget,
    second_barrier_y before <= second_hand_support_ceiling ->
    0 <= budget <= upward_travel_max ->
    second_hand_barrier_step before
      {| second_barrier_mode := SecondBallistic;
         second_barrier_y := second_barrier_y before;
         second_barrier_budget := budget |}
| second_step_rise : forall before delta,
    second_barrier_mode before = SecondBallistic ->
    0 <= delta <= second_barrier_budget before ->
    second_hand_barrier_step before
      {| second_barrier_mode := SecondBallistic;
         second_barrier_y := second_barrier_y before + delta;
         second_barrier_budget := second_barrier_budget before - delta |}
| second_step_nonrise : forall before next_y,
    next_y <= second_barrier_y before ->
    second_hand_barrier_step before
      {| second_barrier_mode := second_barrier_mode before;
         second_barrier_y := next_y;
         second_barrier_budget := second_barrier_budget before |}
| second_step_partial_update : forall state,
    second_hand_barrier_step state state
| second_step_delete : forall before,
    second_hand_barrier_step before
      {| second_barrier_mode := SecondDeleted;
         second_barrier_y := second_barrier_y before;
         second_barrier_budget := 0 |}.

Lemma second_hand_barrier_initial_safe :
  second_hand_barrier_safe second_hand_barrier_initial.
Proof.
  unfold second_hand_barrier_safe, second_hand_barrier_initial,
    second_hand_finite_origin_peak, second_hand_support_ceiling,
    area3_upward_floor_y_max, upward_travel_max, eyerok_home_y.
  cbn. lia.
Qed.

Theorem second_hand_barrier_step_preserves_safe : forall before after,
  second_hand_barrier_safe before ->
  second_hand_barrier_step before after ->
  second_hand_barrier_safe after.
Proof.
  intros before after Hsafe Hstep.
  unfold second_hand_barrier_safe in *.
  destruct Hsafe as (Hbudget & Hsum).
  destruct Hstep; cbn in *.
  - unfold second_hand_finite_origin_peak, second_hand_support_ceiling,
      direct_position_y_max, area3_upward_floor_y_max,
      upward_travel_max in *.
    split; [split |]; lia.
  - unfold second_hand_finite_origin_peak, second_hand_support_ceiling,
      area3_upward_floor_y_max, upward_travel_max in *.
    split; [exact Hbudget | lia].
  - pose proof (first_dynamic_support_below_static_ceiling
      first floor_y H H0) as Hdynamic.
    unfold second_hand_finite_origin_peak, second_hand_support_ceiling,
      area3_upward_floor_y_max, upward_travel_max in *.
    split; [exact Hbudget | lia].
  - unfold second_hand_finite_origin_peak, second_hand_support_ceiling,
      area3_upward_floor_y_max, upward_travel_max in *.
    split; [exact H0 | lia].
  - split; [split; lia | lia].
  - split; [exact Hbudget | lia].
  - split; assumption.
  - split; [split; lia | lia].
Qed.

Inductive second_hand_barrier_reachable : second_hand_barrier_state -> Prop :=
| second_barrier_reachable_initial :
    second_hand_barrier_reachable second_hand_barrier_initial
| second_barrier_reachable_step : forall before after,
    second_hand_barrier_reachable before ->
    second_hand_barrier_step before after ->
    second_hand_barrier_reachable after.

Theorem every_second_hand_barrier_state_safe : forall state,
  second_hand_barrier_reachable state -> second_hand_barrier_safe state.
Proof.
  intros state Hreach. induction Hreach.
  - exact second_hand_barrier_initial_safe.
  - eapply second_hand_barrier_step_preserves_safe; eauto.
Qed.

Theorem second_hand_barrier_origin_bounded : forall state,
  second_hand_barrier_reachable state ->
  second_barrier_y state <= second_hand_finite_origin_peak.
Proof.
  intros state Hreach.
  destruct (every_second_hand_barrier_state_safe state Hreach)
    as ((Hbudget_nonnegative & _) & Hsum).
  lia.
Qed.

Theorem second_hand_barrier_surface_bounded : forall state,
  second_hand_barrier_reachable state ->
  second_barrier_y state + hand_collision_top_max <=
    second_hand_open_surface_peak.
Proof.
  intros state Hreach.
  pose proof (second_hand_barrier_origin_bounded state Hreach) as Horigin.
  unfold second_hand_open_surface_peak. lia.
Qed.

Theorem second_hand_barrier_mario_peak_bounded : forall state,
  second_hand_barrier_reachable state ->
  second_barrier_y state + hand_collision_top_max +
      mario_triple_jump_rise_max <= second_hand_modeled_mario_peak.
Proof.
  intros state Hreach.
  pose proof (second_hand_barrier_origin_bounded state Hreach) as Horigin.
  unfold second_hand_modeled_mario_peak, second_hand_open_surface_peak.
  lia.
Qed.

Corollary second_hand_cannot_reach_legacy_origin_1467 : forall state,
  second_hand_barrier_reachable state -> second_barrier_y state < 1467.
Proof.
  intros state Hreach.
  pose proof (second_hand_barrier_origin_bounded state Hreach).
  change (second_barrier_y state <= 672) in H. lia.
Qed.

Corollary second_hand_cannot_reach_legacy_surface_1974 : forall state,
  second_hand_barrier_reachable state ->
  second_barrier_y state + hand_collision_top_max < 1974.
Proof.
  intros state Hreach.
  pose proof (second_hand_barrier_surface_bounded state Hreach).
  change (second_barrier_y state + hand_collision_top_max <= 1179) in H.
  lia.
Qed.

Corollary modeled_mario_cannot_reach_legacy_peak_2604 : forall state,
  second_hand_barrier_reachable state ->
  second_barrier_y state + hand_collision_top_max +
      mario_triple_jump_rise_max < 2604.
Proof.
  intros state Hreach.
  pose proof (second_hand_barrier_mario_peak_bounded state Hreach).
  change (second_barrier_y state + hand_collision_top_max +
    mario_triple_jump_rise_max <= 1809) in H. lia.
Qed.

Corollary modeled_mario_cannot_query_area2_y1967 : forall state,
  second_hand_barrier_reachable state ->
  second_barrier_y state + hand_collision_top_max +
      mario_triple_jump_rise_max < area2_y1967_query_min.
Proof.
  intros state Hreach.
  pose proof (second_hand_barrier_mario_peak_bounded state Hreach).
  unfold area2_y1967_query_min.
  change (second_barrier_y state + hand_collision_top_max +
    mario_triple_jump_rise_max <= 1809) in H. lia.
Qed.

Definition two_hand_barrier_certificate : Prop :=
  second_hand_finite_origin_peak = 672 /\
  second_hand_open_surface_peak = 1179 /\
  second_hand_modeled_mario_peak = 1809 /\
  (forall state, second_hand_barrier_reachable state ->
    second_barrier_y state < 1467) /\
  (forall state, second_hand_barrier_reachable state ->
    second_barrier_y state + hand_collision_top_max < 1974) /\
  (forall state, second_hand_barrier_reachable state ->
    second_barrier_y state + hand_collision_top_max +
      mario_triple_jump_rise_max < 2604) /\
  (forall state, second_hand_barrier_reachable state ->
    second_barrier_y state + hand_collision_top_max +
      mario_triple_jump_rise_max < area2_y1967_query_min).

Theorem two_hand_barrier_certificate_holds : two_hand_barrier_certificate.
Proof.
  unfold two_hand_barrier_certificate.
  refine (conj (proj1 (proj2 two_hand_barrier_values)) _).
  refine (conj (proj1 (proj2 (proj2 two_hand_barrier_values))) _).
  refine (conj (proj1 (proj2 (proj2 (proj2 two_hand_barrier_values)))) _).
  repeat split.
  - exact second_hand_cannot_reach_legacy_origin_1467.
  - exact second_hand_cannot_reach_legacy_surface_1974.
  - exact modeled_mario_cannot_reach_legacy_peak_2604.
  - exact modeled_mario_cannot_query_area2_y1967.
Qed.
