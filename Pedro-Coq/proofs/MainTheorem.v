From Coq Require Import List ZArith.
From Pedro.Proofs Require Import
  GameTypes PedroCollision LandingDust RNGAdvance InputSemantics TTCSpinners
  TTCSpinnerGeometry TTCSpinnerSchedule DustPool TTCRuntimePremises DustRuntime
  DustClightExec DustBehaviorCommandExecution DustCurObjUpdateExecution
  DustSpawnParticleExecution DustSpawnParticleExecutionJP
  SegmentedPointerBoundary TTCDebugBoundary TTCRNGWindow TTCRNGCensus
  TTCRetailSqrt TTCCogGeometry TTCCogRNG TTCCogExecution
  GroundGapReturn SlideKickDustExecution MarioDustSources
  RNGSourceCoverage MarioParticleCatalogue EnvironmentNoRNG
  SoundRequestExecution SlideKickAnimationExecution SlideKickHelperDischarge
  CogActionExecution CogReflectionExecution CogSlideExecution CogDustClearing
  CogParticleAcceptance.

Module MainSpawnUS := DustSpawnParticleExecution.
Module MainSpawnJP := DustSpawnParticleExecutionJP.
Module MainSegmented := SegmentedPointerBoundary.

(** Exact generated action/collision frontier. The direct-writer census has
    only the two stated translation units as its scope. The ground theorem
    begins after the queries. The slide-kick caller executes its cached
    animation, sound, no-wall reflection and action transition; two actual
    helper-execution premises and their anchor-boundary conditions remain.
    The dispatcher dust-clearing suffix is also executed. None is
    an existence theorem for a reachable in-spot dust event. *)
Definition ttc_cog_dust_action_frontier_claim : Prop :=
  mario_direct_dust_inventory_claim /\
  cog_gap_return_claim /\
  slide_layout_receipt /\
  animation_layout_receipt /\
  sound_layout_receipt /\
  cog_action_layout_receipt /\
  cog_reflection_layout_receipt /\
  cog_trig_table_bounds_claim /\
  (forall version, cog_slide_two_helper_claim version) /\
  (forall version, cog_dust_clearing_claim version) /\
  (forall version, cog_terrain_execution_claim version) /\
  cog_particle_acceptance_frontier_claim.

Theorem checked_ttc_cog_dust_action_frontier_us_jp :
  ttc_cog_dust_action_frontier_claim.
Proof.
  exact (conj generated_mario_direct_dust_inventory_us_jp
    (conj checked_cog_gap_return_us_jp
      (conj slide_caller_and_anchor_offsets_generated_us_jp
        (conj animation_layout_generated_us_jp
          (conj sound_layout_generated_us_jp
            (conj cog_action_layout_generated_us_jp
              (conj cog_reflection_layout_generated_us_jp
                (conj cog_trig_table_bounds_generated_us_jp
                 (conj generated_cog_slide_with_two_helpers_us_jp
                  (conj generated_cog_dispatcher_dust_clearing_us_jp
                    (conj generated_cog_stone_terrain_addend_us_jp
                      checked_cog_particle_acceptance_frontier_us_jp))))))))))).
Qed.

(** Active cog target: exact stock inventory and a pairwise binary32 geometry
    certificate. Entry, query selection, and controller preservation remain
    open; this is not the final gameplay theorem. *)
Theorem checked_ttc_cog_source_geometry_us_jp :
  ttc_cog_geometry_reduction_claim.
Proof. exact checked_ttc_cog_geometry_reduction_us_jp. Qed.

(** Exhaustive syntactic inventories within the 41 generated units: all direct
    primitive calls, all computed-call callers, and all particle-field writers.
    The separate authenticated source-token/include gate accounts for every
    pinned C/header file naming the gameplay RNG. Neither gate is a semantic
    linkage/aliasing theorem. The environmental conjunct executes a real
    NONE-mode update; connecting its entry globals to TTC remains open.
    This frontier does not assert exhaustive preserving controller choices. *)
Definition ttc_cog_rng_source_frontier_claim : Prop :=
  rng_source_coverage_claim /\
  mario_particle_catalogue_claim /\
  environment_exclusion_frontier_claim.

Theorem checked_ttc_cog_rng_source_frontier_us_jp :
  ttc_cog_rng_source_frontier_claim.
Proof.
  exact (conj checked_rng_source_coverage_us_jp
    (conj checked_mario_particle_catalogue_us_jp
      checked_environment_exclusion_frontier_us_jp)).
Qed.

(** The full generated cog update executes both real RNG draws and preserves
    yaw from the specified zero-speed image. The separate recurrence window
    illustrates a four-draw choice; it is not an executed dust/frame schedule.
    Legal reachability of the memory image, actual collision query selection,
    the second cog's execution, and repeated controller control remain open. *)
Theorem checked_ttc_cog_local_mechanism_us_jp :
  ttc_cog_geometry_reduction_claim /\
  ttc_cog_rng_reduction_claim /\
  (forall version, cog_zero_update_execution_claim version) /\
  ttc_cog_dust_action_frontier_claim /\
  ttc_cog_rng_source_frontier_claim.
Proof.
  destruct TTCCogExecution.checked_ttc_cog_local_mechanism_us_jp
    as [Hgeometry [Hrng Hexecution]].
  exact (conj Hgeometry (conj Hrng (conj Hexecution
    (conj checked_ttc_cog_dust_action_frontier_us_jp
      checked_ttc_cog_rng_source_frontier_us_jp)))).
Qed.

(** Initial source-and-arithmetic capstone. Every conjunct is tied either to a
    generated Clight AST or to CompCert's executable binary32 operations. This
    theorem does not assert gameplay reachability or repeatability. *)
Theorem checked_pedro_rng_mechanism_us_jp :
  forall version,
    pedro_collision_source_receipt version /\
    landing_dust_source_receipt version /\
    rng_source_chain_receipt version /\
    (forall class,
      flat_landing_tap_witness class (flat_tap_speed class)).
Proof.
  intro version.
  refine (conj (pedro_collision_source_receipt_supported version) _).
  refine (conj (landing_dust_source_receipt_supported version) _).
  refine (conj (rng_source_chain_receipt_supported version) _).
  exact every_flat_floor_class_has_landing_tap.
Qed.

(** Linked-symbol and source-derived execution projection for the dust episode.
    [pool] is the isolated reserve available to the three dust allocations;
    the theorem does not derive that reserve, the initially clear bit, or a
    dust-producing tap from a reachable retail TTC state. *)
Theorem checked_dust_source_projection_us_jp :
  forall version tap_frame pool,
    (3 <= usable_reserve pool)%nat ->
    dust_runtime_projection_claim version tap_frame pool false.
Proof.
  intros version tap_frame pool Hreserve.
  apply checked_dust_runtime_projection_us_jp.
  - exact Hreserve.
  - reflexivity.
Qed.

(** Checked reductions for the three remaining retail-strength dust
    obligations.  This theorem adds a genuine generated-Clight PRNG leaf
    execution, an exact fresh TTC source inventory/clear-bit reduction, and
    an interference-aware finite spinner-window census.  It does not discharge
    the retained live-snapshot, no-outside-call, linked-object execution, or
    reachable-tap premises. *)
Theorem checked_dust_frontier_reductions_us_jp :
  random_u16_zero_step_clight_claim /\
  ttc_fresh_runtime_premise_reduction_claim /\
  ttc_rng_window_reduction_claim.
Proof.
  exact (conj checked_random_u16_zero_step_clight
    (conj checked_ttc_fresh_runtime_premise_reduction_us_jp
          checked_ttc_rng_window_reduction_us_jp)).
Qed.

(** TTC source reduction plus the concrete geometry and schedule model.
    Reachable entry, linked Clight execution, and a positive bounded-oscillation
    control witness remain explicit checklist obligations. *)
Theorem checked_ttc_spinner_source_reduction_us_jp :
  forall version,
    ttc_spinner_source_receipt version /\
    ttc_geometry_source_receipt version /\
    ttc_schedule_source_receipt version /\
    (forall pitch,
      15664 <= pitch <= 16031 ->
      spinner_geometry_certificate version (pitch_table_index pitch) = true) /\
    pedro_collision_source_receipt version /\
    landing_dust_source_receipt version /\
    rng_source_chain_receipt version.
Proof.
  intro version.
  refine (conj (ttc_spinner_source_receipt_supported version) _).
  refine (conj (ttc_geometry_source_receipt_supported version) _).
  refine (conj (ttc_schedule_source_receipt_supported version) _).
  refine (conj (concrete_ttc_spinner_pitch_interval version) _).
  refine (conj (pedro_collision_source_receipt_supported version) _).
  refine (conj (landing_dust_source_receipt_supported version) _).
  exact (rng_source_chain_receipt_supported version).
Qed.

(** Executable and census frontier for the three dust-to-PRNG obligations.
    The first conjunct is a genuine linked Clight big-step through one exact
    [cur_obj_update] dispatch cycle, the generated CALL_NATIVE handler,
    white-puff-2 loop, random translation, and two PRNG calls in both supported
    versions.  The remaining conjuncts pair a complete finite debug-replay
    pool/RNG receipt with the fail-closed static TTC consumer census.  The
    debug origin is explicitly non-stock and SLOW; this theorem therefore does
    not assert a reachable Pedro tap or RANDOM-mode spinner execution. *)
Theorem checked_dust_linked_runtime_census_frontier_us_jp :
  linked_cur_obj_update_call_native_dispatch_cycle_us_jp_claim /\
  ttc_debug_replay_boundary_reduction_claim /\
  ttc_rng_static_census_claim /\
  ttc_debug_slow_observed_rng_census_claim.
Proof.
  refine (conj
    checked_linked_cur_obj_update_call_native_dispatch_cycle_us_jp _).
  refine (conj checked_ttc_debug_replay_boundary_reduction_us_jp _).
  refine (conj checked_ttc_rng_static_census_us_jp _).
  exact checked_ttc_debug_slow_observed_rng_census_us_jp.
Qed.

(** The static Clight census is paired with a check of the complete four-word
    retail [sqrtf] leaf for nested call/store instructions.  This does not turn
    the external [sqrtf] declaration into a MIPS semantic contract. *)
Theorem checked_static_terminal_frontier_us_jp :
  ttc_rng_static_census_claim /\
  RetailSqrtfInstructionReceipt.
Proof.
  exact (conj checked_ttc_rng_static_census_us_jp
    retail_sqrtf_instruction_receipt_checked).
Qed.

(** Exact accepted-branch executions for the generated US and JP
    [spawn_particle] callers, paired with the formal reason the first call
    inside [spawn_object_at_origin] cannot yet execute directly from a
    symbolic CompCert pointer.  Each caller theorem retains exact [eval_funcall]
    premises for [spawn_object_at_origin] and [obj_copy_pos_and_angle]; this
    capstone therefore closes the caller, not the complete allocation chain. *)
Theorem checked_spawn_particle_caller_and_segmented_boundary_us_jp :
  MainSpawnUS.us_spawn_particle_execution_claim /\
  MainSpawnJP.jp_spawn_particle_execution_claim /\
  MainSegmented.segmented_pointer_boundary_claim.
Proof.
  refine (conj
    MainSpawnUS.us_generated_spawn_particle_accepts_clear_dust_in_any_genv _).
  exact (conj
    MainSpawnJP.jp_generated_spawn_particle_accepts_clear_dust_in_any_genv
    MainSegmented.checked_segmented_pointer_boundary_us_jp).
Qed.
