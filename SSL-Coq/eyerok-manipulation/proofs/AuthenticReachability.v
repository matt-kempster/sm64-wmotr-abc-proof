From Coq Require Import Lia ZArith.
From SSLEyerok.Proofs Require Import Area2Route AuthenticKernel GeneratedFacts
  RouteModel Spec StateMachine UpperRoute VerticalBound.

Local Open Scope Z_scope.

(** This module defines an audited model with a kernel-controlled runaway
    gate.  A finite frame advances both the source-shaped launch kernel and the
    conservative vertical relation.  Those ordinary finite choices are still
    independent abstractions: no shared-height or event-compatibility theorem
    is claimed here.  If the dangerous kernel seed were reachable, however, a
    separate frame constructor would put the vertical state into [Runaway] and
    the height invariant would fail.  The kernel proof is therefore causally
    required for the runaway case rather than merely conjoined afterward.

    The remaining trust boundary is explicit: no theorem in this module says
    that every linked Clight or ROM frame refines [audited_coupled_frame]. *)

Record audited_coupled_state : Type := {
  coupled_kernel : kernel_state;
  coupled_vertical : vertical_state
}.

Definition audited_coupled_initial (rank : hand_rank)
    : audited_coupled_state :=
  {| coupled_kernel := kernel_initial;
     coupled_vertical := initial_vertical_state rank |}.

Definition runaway_vertical_successor
    (before : vertical_state) : vertical_state :=
  {| state_rank := state_rank before;
     state_mode := Runaway;
     state_y := state_y before + runaway_delta;
     state_budget := 0 |}.

Inductive audited_coupled_frame (a_down : bool)
    : audited_coupled_state -> audited_coupled_state -> Prop :=
| coupled_finite_frame : forall before event next_vertical,
    ~ (event = EventLaunch100 /\
       gravity_zero_runaway_seed (coupled_kernel before)) ->
    vertical_step (coupled_vertical before) next_vertical ->
    audited_coupled_frame a_down before
      {| coupled_kernel :=
           kernel_step a_down event (coupled_kernel before);
         coupled_vertical := next_vertical |}
| coupled_seed_frame : forall before,
    gravity_zero_runaway_seed (coupled_kernel before) ->
    audited_coupled_frame a_down before
      {| coupled_kernel :=
           kernel_step a_down EventLaunch100 (coupled_kernel before);
         coupled_vertical :=
           runaway_vertical_successor (coupled_vertical before) |}
| coupled_runaway_continue : forall before,
    state_mode (coupled_vertical before) = Runaway ->
    audited_coupled_frame a_down before
      {| coupled_kernel := coupled_kernel before;
         coupled_vertical :=
           runaway_vertical_successor (coupled_vertical before) |}.

Inductive audited_coupled_reachable
    (a_policy : nat -> bool) (rank : hand_rank)
    : nat -> audited_coupled_state -> Prop :=
| audited_coupled_reachable_initial :
    audited_coupled_reachable a_policy rank O
      (audited_coupled_initial rank)
| audited_coupled_reachable_step : forall frame before after,
    audited_coupled_reachable a_policy rank frame before ->
    audited_coupled_frame (a_policy frame) before after ->
    audited_coupled_reachable a_policy rank (S frame) after.

Definition audited_coupled_invariant
    (rank : hand_rank) (state : audited_coupled_state) : Prop :=
  kernel_safe (coupled_kernel state) /\
  safe_envelope (coupled_vertical state) /\
  state_rank (coupled_vertical state) = rank.

Lemma kernel_safe_excludes_runaway_seed : forall state,
  kernel_safe state -> ~ gravity_zero_runaway_seed state.
Proof.
  intros state (_ & _ & Hzero & _) (Haction & Hgravity & Hgrounded).
  specialize (Hzero Haction Hgravity).
  congruence.
Qed.

Lemma audited_coupled_initial_invariant : forall rank,
  audited_coupled_invariant rank (audited_coupled_initial rank).
Proof.
  intros rank. unfold audited_coupled_invariant; cbn.
  split; [exact kernel_initial_safe |].
  split; [exact (initial_vertical_state_safe rank) | reflexivity].
Qed.

Theorem audited_coupled_frame_preserves_invariant :
  forall a_down rank before after,
    audited_coupled_invariant rank before ->
    audited_coupled_frame a_down before after ->
    audited_coupled_invariant rank after.
Proof.
  intros a_down rank before after (Hkernel & Hvertical & Hrank) Hframe.
  inversion Hframe; subst; cbn in *.
  - unfold audited_coupled_invariant; cbn.
    split.
    + apply kernel_step_preserves_safe. exact Hkernel.
    + split.
      * eapply vertical_step_preserves_safe; eauto.
      * rewrite (vertical_step_preserves_rank
        (coupled_vertical before) next_vertical H0).
        reflexivity.
  - exfalso. exact (kernel_safe_excludes_runaway_seed
      (coupled_kernel before) Hkernel H).
  - destruct Hvertical as (Hnot_runaway & _).
    exfalso. exact (Hnot_runaway H).
Qed.

Theorem every_audited_coupled_state_satisfies_invariant :
  forall a_policy rank frame state,
    audited_coupled_reachable a_policy rank frame state ->
    audited_coupled_invariant rank state.
Proof.
  intros a_policy rank frame state Hreach.
  induction Hreach.
  - exact (audited_coupled_initial_invariant rank).
  - eapply audited_coupled_frame_preserves_invariant; eauto.
Qed.

Definition star_platform_query_min : Z := 4815 - 78.
Definition upper_platform_query_min : Z := 4429 - 78.
Definition mid2940_query_min : Z := 2940 - 78.

Lemma direct_shortcut_threshold_values :
  mid2940_query_min = 2862 /\
  upper_platform_query_min = 4351 /\
  star_platform_query_min = 4737.
Proof. repeat split; reflexivity. Qed.

Theorem audited_coupled_reachability_excludes_runaway_seed :
  forall a_policy rank frame state,
    audited_coupled_reachable a_policy rank frame state ->
    ~ gravity_zero_runaway_seed (coupled_kernel state).
Proof.
  intros a_policy rank frame state Hreach.
  apply kernel_safe_excludes_runaway_seed.
  exact (proj1 (every_audited_coupled_state_satisfies_invariant
    a_policy rank frame state Hreach)).
Qed.

Theorem audited_coupled_hand_origin_bounded :
  forall a_policy rank frame state,
    audited_coupled_reachable a_policy rank frame state ->
    state_y (coupled_vertical state) <= global_height_ceiling.
Proof.
  intros a_policy rank frame state Hreach.
  destruct (every_audited_coupled_state_satisfies_invariant
    a_policy rank frame state Hreach)
    as (_ & (_ & (Hbudget_nonnegative & _) & Hsum) & Hrank).
  rewrite Hrank in Hsum.
  pose proof (height_ceiling_le_global rank) as Hglobal.
  lia.
Qed.

Theorem audited_coupled_hand_surface_bounded :
  forall a_policy rank frame state,
    audited_coupled_reachable a_policy rank frame state ->
    state_y (coupled_vertical state) + hand_collision_top_max <= 1974.
Proof.
  intros a_policy rank frame state Hreach.
  pose proof (audited_coupled_hand_origin_bounded
    a_policy rank frame state Hreach) as Horigin.
  cbv [global_height_ceiling hand_collision_top_max] in *.
  lia.
Qed.

Theorem audited_coupled_mario_departure_peak_bounded :
  forall a_policy rank frame state,
    audited_coupled_reachable a_policy rank frame state ->
    state_y (coupled_vertical state) + hand_collision_top_max +
      mario_triple_jump_rise_max <= 2604.
Proof.
  intros a_policy rank frame state Hreach.
  pose proof (audited_coupled_hand_origin_bounded
    a_policy rank frame state Hreach) as Horigin.
  cbv [global_height_ceiling hand_collision_top_max
    mario_triple_jump_rise_max] in *.
  lia.
Qed.

Theorem no_a_audited_model_cannot_enable_star_platform :
  forall rank frame state,
    audited_coupled_reachable never_press_a rank frame state ->
    state_y (coupled_vertical state) + hand_collision_top_max +
      mario_triple_jump_rise_max < star_platform_query_min.
Proof.
  intros rank frame state Hreach.
  pose proof (audited_coupled_mario_departure_peak_bounded
    never_press_a rank frame state Hreach) as Hpeak.
  cbv [star_platform_query_min]. lia.
Qed.

Theorem held_a_audited_model_cannot_enable_star_platform :
  forall rank frame state,
    audited_coupled_reachable continuously_hold_a rank frame state ->
    state_y (coupled_vertical state) + hand_collision_top_max +
      mario_triple_jump_rise_max < star_platform_query_min.
Proof.
  intros rank frame state Hreach.
  pose proof (audited_coupled_mario_departure_peak_bounded
    continuously_hold_a rank frame state Hreach) as Hpeak.
  cbv [star_platform_query_min]. lia.
Qed.

Theorem arbitrary_a_policy_cannot_enable_star_platform :
  forall a_policy rank frame state,
    audited_coupled_reachable a_policy rank frame state ->
    state_y (coupled_vertical state) + hand_collision_top_max +
      mario_triple_jump_rise_max < star_platform_query_min.
Proof.
  intros a_policy rank frame state Hreach.
  pose proof (audited_coupled_mario_departure_peak_bounded
    a_policy rank frame state Hreach) as Hpeak.
  cbv [star_platform_query_min]. lia.
Qed.

Theorem audited_model_cannot_supply_counterfactual_upper_route_height :
  forall a_policy rank frame state,
    audited_coupled_reachable a_policy rank frame state ->
    state_y (coupled_vertical state) < upper_shortcut_hand_origin_required.
Proof.
  intros a_policy rank frame state Hreach.
  pose proof (audited_coupled_hand_origin_bounded
    a_policy rank frame state Hreach) as Horigin.
  cbv [global_height_ceiling upper_shortcut_hand_origin_required] in *.
  lia.
Qed.

Inductive audited_higher_tier : Type :=
| Higher2940
| Higher4429
| Higher4815.

Definition audited_higher_tier_y (tier : audited_higher_tier) : Z :=
  match tier with
  | Higher2940 => 2940
  | Higher4429 => 4429
  | Higher4815 => 4815
  end.

Theorem peak_2604_cannot_directly_select_any_tier_above_1967 :
  forall tier query_y,
    query_y <= 2604 ->
    ~ floor_query_eligible query_y (audited_higher_tier_y tier).
Proof.
  intros [] query_y Hpeak Heligible;
    unfold floor_query_eligible, audited_higher_tier_y in *; lia.
Qed.

Theorem audited_policy_cannot_directly_select_any_tier_above_1967 :
  forall a_policy rank frame state tier,
    audited_coupled_reachable a_policy rank frame state ->
    ~ floor_query_eligible
      (state_y (coupled_vertical state) + hand_collision_top_max +
       mario_triple_jump_rise_max)
      (audited_higher_tier_y tier).
Proof.
  intros a_policy rank frame state tier Hreach.
  apply peak_2604_cannot_directly_select_any_tier_above_1967.
  exact (audited_coupled_mario_departure_peak_bounded
    a_policy rank frame state Hreach).
Qed.

Corollary no_a_cannot_directly_select_any_tier_above_1967 :
  forall rank frame state tier,
    audited_coupled_reachable never_press_a rank frame state ->
    ~ floor_query_eligible
      (state_y (coupled_vertical state) + hand_collision_top_max +
       mario_triple_jump_rise_max)
      (audited_higher_tier_y tier).
Proof. exact (audited_policy_cannot_directly_select_any_tier_above_1967
  never_press_a). Qed.

Corollary held_a_cannot_directly_select_any_tier_above_1967 :
  forall rank frame state tier,
    audited_coupled_reachable continuously_hold_a rank frame state ->
    ~ floor_query_eligible
      (state_y (coupled_vertical state) + hand_collision_top_max +
       mario_triple_jump_rise_max)
      (audited_higher_tier_y tier).
Proof. exact (audited_policy_cannot_directly_select_any_tier_above_1967
  continuously_hold_a). Qed.

(** This is the missing bridge for a linked or ROM theorem, stated rather than
    assumed.  A future refinement must exhibit a coupled model state for every
    external frame and preserve the observed hand height. *)
Definition execution_height_refines_audited_model
    (external_state : Type) (external_height : external_state -> Z)
    (external_run : nat -> external_state) (a_policy : nat -> bool)
    (rank : hand_rank) : Prop :=
  forall frame, exists modeled,
    audited_coupled_reachable a_policy rank frame modeled /\
    external_height (external_run frame) =
      state_y (coupled_vertical modeled).

Theorem external_execution_height_bounded_if_refined :
  forall (external_state : Type) external_height external_run a_policy rank,
    execution_height_refines_audited_model
      external_state external_height external_run a_policy rank ->
    forall frame,
      external_height (external_run frame) <= global_height_ceiling.
Proof.
  intros external_state external_height external_run a_policy rank Href frame.
  destruct (Href frame) as (modeled & Hreach & Hheight).
  rewrite Hheight.
  exact (audited_coupled_hand_origin_bounded
    a_policy rank frame modeled Hreach).
Qed.

Definition audited_coupled_reachability_certificate : Prop :=
  generated_critical_source_shape /\
  (forall a_policy frame state,
      kernel_reachable a_policy frame state ->
      ~ gravity_zero_runaway_seed state) /\
  (forall a_policy rank frame state,
      audited_coupled_reachable a_policy rank frame state ->
      state_y (coupled_vertical state) <= 1467) /\
  (forall a_policy rank frame state,
      audited_coupled_reachable a_policy rank frame state ->
      state_y (coupled_vertical state) + 507 + 630 < 4737) /\
  counterfactual_upper_route_claim.

Theorem audited_coupled_reachability_certificate_holds :
  audited_coupled_reachability_certificate.
Proof.
  unfold audited_coupled_reachability_certificate.
  refine (conj generated_critical_source_shape_holds _).
  refine (conj no_player_policy_reaches_gravity_zero_runaway_seed _).
  refine (conj _ _).
  - intros a_policy rank frame state Hreach.
    exact (audited_coupled_hand_origin_bounded
      a_policy rank frame state Hreach).
  - refine (conj _ counterfactual_upper_route_collects_the_star).
    intros a_policy rank frame state Hreach.
    exact (arbitrary_a_policy_cannot_enable_star_platform
      a_policy rank frame state Hreach).
Qed.
