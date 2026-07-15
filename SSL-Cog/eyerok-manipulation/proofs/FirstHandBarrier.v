From Coq Require Import Lia ZArith.
From SSLEyerok.Proofs Require Import RouteModel Spec.

Local Open Scope Z_scope.

(** Pinned Area 3 collision separates the boss arena from the tunnel by a
    vertical gap.  These constants are checked by [audit_eyerok_source.py]. *)
Definition arena_upward_floor_y_max : Z := -1150.
Definition tunnel_upward_floor_y_min : Z := -562.
Definition tunnel_floor_query_y_min : Z := tunnel_upward_floor_y_min - 78.

Definition first_hand_finite_origin_peak : Z :=
  arena_upward_floor_y_max + upward_travel_max.

Definition first_hand_open_surface_peak : Z :=
  first_hand_finite_origin_peak + hand_collision_top_max.

Lemma first_hand_barrier_values :
  tunnel_floor_query_y_min = -640 /\
  first_hand_finite_origin_peak = -862 /\
  first_hand_open_surface_peak = -355.
Proof. repeat split; reflexivity. Qed.

Inductive first_hand_barrier_mode : Type :=
| FirstControlled
| FirstBallistic
| FirstDeleted.

Record first_hand_barrier_state : Type := {
  first_barrier_mode : first_hand_barrier_mode;
  first_barrier_y : Z;
  first_barrier_budget : Z
}.

Definition first_hand_barrier_initial : first_hand_barrier_state :=
  {| first_barrier_mode := FirstControlled;
     first_barrier_y := eyerok_home_y;
     first_barrier_budget := 0 |}.

Definition first_hand_barrier_safe (state : first_hand_barrier_state) : Prop :=
  0 <= first_barrier_budget state <= upward_travel_max /\
  first_barrier_y state + first_barrier_budget state <=
    first_hand_finite_origin_peak.

(** This relation over-approximates every source-shaped first-hand vertical
    transition before tunnel entry.  The load-bearing launch premise is that
    ATTACKED, DIE, and DOUBLE_POUND begin their positive flight from an arena
    support.  The source audit protects the writers and phase structure; a
    linked Clight refinement remains a separate theorem obligation. *)
Inductive first_hand_barrier_step
    : first_hand_barrier_state -> first_hand_barrier_state -> Prop :=
| first_step_direct : forall before target,
    target <= direct_position_y_max ->
    first_hand_barrier_step before
      {| first_barrier_mode := FirstControlled;
         first_barrier_y := target;
         first_barrier_budget := 0 |}
| first_step_land : forall before floor_y,
    floor_y <= arena_upward_floor_y_max ->
    first_hand_barrier_step before
      {| first_barrier_mode := FirstControlled;
         first_barrier_y := floor_y;
         first_barrier_budget := 0 |}
| first_step_launch : forall before budget,
    first_barrier_y before <= arena_upward_floor_y_max ->
    0 <= budget <= upward_travel_max ->
    first_hand_barrier_step before
      {| first_barrier_mode := FirstBallistic;
         first_barrier_y := first_barrier_y before;
         first_barrier_budget := budget |}
| first_step_rise : forall before delta,
    first_barrier_mode before = FirstBallistic ->
    0 <= delta <= first_barrier_budget before ->
    first_hand_barrier_step before
      {| first_barrier_mode := FirstBallistic;
         first_barrier_y := first_barrier_y before + delta;
         first_barrier_budget := first_barrier_budget before - delta |}
| first_step_nonrise : forall before next_y,
    next_y <= first_barrier_y before ->
    first_hand_barrier_step before
      {| first_barrier_mode := first_barrier_mode before;
         first_barrier_y := next_y;
         first_barrier_budget := first_barrier_budget before |}
| first_step_partial_update : forall state,
    first_hand_barrier_step state state
| first_step_delete : forall before,
    first_hand_barrier_step before
      {| first_barrier_mode := FirstDeleted;
         first_barrier_y := first_barrier_y before;
         first_barrier_budget := 0 |}.

Lemma first_hand_barrier_initial_safe :
  first_hand_barrier_safe first_hand_barrier_initial.
Proof.
  unfold first_hand_barrier_safe, first_hand_barrier_initial,
    first_hand_finite_origin_peak, arena_upward_floor_y_max,
    upward_travel_max, eyerok_home_y. cbn. lia.
Qed.

Theorem first_hand_barrier_step_preserves_safe : forall before after,
  first_hand_barrier_safe before ->
  first_hand_barrier_step before after ->
  first_hand_barrier_safe after.
Proof.
  intros before after Hsafe Hstep.
  unfold first_hand_barrier_safe in *.
  destruct Hsafe as (Hbudget & Hsum).
  destruct Hstep; cbn in *;
    unfold first_hand_finite_origin_peak, arena_upward_floor_y_max,
      direct_position_y_max, upward_travel_max in *; cbn in *.
  - split; [split; lia | lia].
  - split; [split; lia | lia].
  - split; [exact H0 | lia].
  - split; [split; lia | lia].
  - split; [exact Hbudget | lia].
  - split; assumption.
  - split; [split; lia | lia].
Qed.

Inductive first_hand_barrier_reachable : first_hand_barrier_state -> Prop :=
| first_barrier_reachable_initial :
    first_hand_barrier_reachable first_hand_barrier_initial
| first_barrier_reachable_step : forall before after,
    first_hand_barrier_reachable before ->
    first_hand_barrier_step before after ->
    first_hand_barrier_reachable after.

Theorem every_first_hand_barrier_state_safe : forall state,
  first_hand_barrier_reachable state -> first_hand_barrier_safe state.
Proof.
  intros state Hreach. induction Hreach.
  - exact first_hand_barrier_initial_safe.
  - eapply first_hand_barrier_step_preserves_safe; eauto.
Qed.

Theorem first_hand_barrier_origin_bounded : forall state,
  first_hand_barrier_reachable state ->
  first_barrier_y state <= first_hand_finite_origin_peak.
Proof.
  intros state Hreach.
  destruct (every_first_hand_barrier_state_safe state Hreach)
    as ((Hbudget_nonnegative & _) & Hsum).
  lia.
Qed.

Lemma first_hand_cannot_query_tunnel : forall query_y floor_y,
  query_y <= first_hand_finite_origin_peak ->
  tunnel_upward_floor_y_min <= floor_y ->
  ~ floor_query_eligible query_y floor_y.
Proof.
  intros query_y floor_y Hquery Hfloor Heligible.
  unfold first_hand_finite_origin_peak, arena_upward_floor_y_max,
    upward_travel_max, tunnel_upward_floor_y_min,
    floor_query_eligible in *.
  lia.
Qed.

Theorem reachable_first_hand_cannot_select_tunnel : forall state floor_y,
  first_hand_barrier_reachable state ->
  tunnel_upward_floor_y_min <= floor_y ->
  ~ floor_query_eligible (first_barrier_y state) floor_y.
Proof.
  intros state floor_y Hreach Hfloor.
  apply first_hand_cannot_query_tunnel; [| exact Hfloor].
  exact (first_hand_barrier_origin_bounded state Hreach).
Qed.

Theorem first_hand_open_surface_bounded : forall state,
  first_hand_barrier_reachable state ->
  first_barrier_y state + hand_collision_top_max <=
    first_hand_open_surface_peak.
Proof.
  intros state Hreach.
  pose proof (first_hand_barrier_origin_bounded state Hreach) as Horigin.
  unfold first_hand_open_surface_peak. lia.
Qed.

Corollary first_hand_cannot_reach_legacy_surface_1179 : forall state,
  first_hand_barrier_reachable state ->
  first_barrier_y state + hand_collision_top_max < 1179.
Proof.
  intros state Hreach.
  pose proof (first_hand_open_surface_bounded state Hreach) as Hsurface.
  change (first_barrier_y state + hand_collision_top_max <= -355) in Hsurface.
  lia.
Qed.

Definition first_hand_barrier_certificate : Prop :=
  first_hand_finite_origin_peak = -862 /\
  first_hand_open_surface_peak = -355 /\
  (forall state, first_hand_barrier_reachable state ->
    first_barrier_y state <= -862) /\
  (forall state floor_y,
    first_hand_barrier_reachable state ->
    -562 <= floor_y ->
    ~ floor_query_eligible (first_barrier_y state) floor_y) /\
  (forall state, first_hand_barrier_reachable state ->
    first_barrier_y state + hand_collision_top_max < 1179).

Theorem first_hand_barrier_certificate_holds :
  first_hand_barrier_certificate.
Proof.
  unfold first_hand_barrier_certificate.
  refine (conj (proj1 (proj2 first_hand_barrier_values)) _).
  refine (conj (proj2 (proj2 first_hand_barrier_values)) _).
  refine (conj _ _).
  - intros state Hreach.
    exact (first_hand_barrier_origin_bounded state Hreach).
  - refine (conj _ first_hand_cannot_reach_legacy_surface_1179).
    intros state floor_y Hreach Hfloor.
    exact (reachable_first_hand_cannot_select_tunnel
      state floor_y Hreach Hfloor).
Qed.
