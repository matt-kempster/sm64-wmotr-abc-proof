From Coq Require Import List.
From compcert Require Import Linking.
From Pedro.Proofs Require Import
  GameTypes RNGAdvance DustClightLink DustBehavior DustPool DustPRNG.

Import ListNotations.

(** The structural slice contains the selected generated definitions and is
    accepted by CompCert's official linker.  It deliberately does not claim
    that the normalized slice refines separate compilation of the retail
    translation units. *)
Definition dust_structural_link_exists (version : GameVersion) : Prop :=
  match version with
  | VersionUS =>
      exists linked,
        link us_dust_core_program us_dust_leaf_program = Some linked
  | VersionJP =>
      exists linked,
        link jp_dust_core_program jp_dust_leaf_program = Some linked
  end.

Theorem dust_structural_link_supported_us_jp :
  forall version, dust_structural_link_exists version.
Proof.
  intros []; [exact us_dust_slice_link_succeeds |
              exact jp_dust_slice_link_succeeds].
Qed.

(** Derive events from the objects consumed by the source-derived scheduler.
    Thus the four-event list is not an independent assertion detached from the
    computed Mist/Puff1/Puff2 execution result. *)
Definition dust_events_for_object
    (tap_frame : nat) (object : dust_runtime_object) : list DustRNGEvent :=
  match object with
  | RuntimeMist => []
  | RuntimePuff1 =>
      [DustEvent Puff1X tap_frame DefaultPhase;
       DustEvent Puff1Z tap_frame DefaultPhase]
  | RuntimePuff2 =>
      [DustEvent Puff2X tap_frame UnimportantPhase;
       DustEvent Puff2Z tap_frame UnimportantPhase]
  end.

Definition dust_events_from_schedule
    (tap_frame : nat) (state : dust_schedule_state) : list DustRNGEvent :=
  flat_map (dust_events_for_object tap_frame) (schedule_executed state).

Theorem successful_source_derived_schedule_has_exact_event_trace :
  forall version tap_frame state,
    execute_source_derived_dust_frame version true true true = Some state ->
    dust_events_from_schedule tap_frame state = dust_rng_trace tap_frame /\
    length (dust_events_from_schedule tap_frame state) =
      schedule_rng_advances state.
Proof.
  intros version tap_frame state Hrun.
  rewrite (source_derived_dust_frame_supported version) in Hrun.
  inversion Hrun; subst state.
  split; reflexivity.
Qed.

(** One certificate collecting the independent, source-tethered reductions.

    The three Boolean [true] arguments below mean "accepted dust", "normal
    time frame", and "allocations succeed" in [DustBehavior].  The reserve
    hypothesis discharges the allocation projection, but no theorem here
    derives any of these premises from a reachable retail state.  Likewise,
    the link witness and executable source-derived projection are separate
    conjuncts, not a Clight big-step execution theorem. *)
Definition dust_runtime_projection_claim
    (version : GameVersion) (tap_frame : nat)
    (pool : PoolReserve) (initial_dust_bit : bool) : Prop :=
  dust_structural_link_exists version /\
  execute_source_derived_dust_frame version true true true =
    Some completed_dust_frame /\
  rng_source_chain_receipt version /\
  dust_pool_source_receipt version /\
  (exists pool_after,
    dust_three_allocation_trace pool = Some pool_after) /\
  dust_request_accepted (run_dust_bit_same_frame initial_dust_bit) = true /\
  bit_after_spawn_particle (run_dust_bit_same_frame initial_dust_bit) = true /\
  bit_after_default_spawner (run_dust_bit_same_frame initial_dust_bit) = false /\
  dust_events_from_schedule tap_frame completed_dust_frame =
    dust_rng_trace tap_frame /\
  length (dust_events_from_schedule tap_frame completed_dust_frame) =
    schedule_rng_advances completed_dust_frame /\
  dust_prng_timing_claim version tap_frame /\
  schedule_rng_advances completed_dust_frame = 4%nat /\
  (forall seed_before_puff1 seed_before_puff2,
    no_intervening_rng_consumer seed_before_puff1 seed_before_puff2 ->
    rng_steps 2 seed_before_puff2 = rng_steps 4 seed_before_puff1).

Theorem checked_dust_runtime_projection_us_jp :
  forall version tap_frame pool initial_dust_bit,
    3 <= usable_reserve pool ->
    initial_dust_bit = false ->
    dust_runtime_projection_claim
      version tap_frame pool initial_dust_bit.
Proof.
  intros version tap_frame pool initial_dust_bit Hreserve Hclear_initial.
  pose proof
    (clear_active_dust_bit_accepts_then_clears_in_same_frame_model
      initial_dust_bit Hclear_initial) as [Haccepted [Hset Hcleared]].
  unfold dust_runtime_projection_claim.
  refine (conj (dust_structural_link_supported_us_jp version) _).
  refine (conj (source_derived_dust_frame_supported version) _).
  refine (conj (rng_source_chain_receipt_supported version) _).
  refine (conj (dust_pool_source_receipt_supported version) _).
  refine (conj _ _).
  - apply (proj2
      (dust_three_allocations_exist_iff_reserve_at_least_three pool)).
    exact Hreserve.
  - refine (conj Haccepted _).
    refine (conj Hset _).
    refine (conj Hcleared _).
    pose proof
      (successful_source_derived_schedule_has_exact_event_trace
        version tap_frame completed_dust_frame
        (source_derived_dust_frame_supported version)) as [Hevents Hcount].
    refine (conj Hevents _).
    refine (conj Hcount _).
    refine (conj (dust_prng_timing_checked_us_jp version tap_frame) _).
    refine (conj eq_refl _).
    exact dust_is_four_steps_under_no_intervening_consumer.
Qed.
