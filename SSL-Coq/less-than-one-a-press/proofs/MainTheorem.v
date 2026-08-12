From Coq Require Import List ZArith.
From LessThanOneAPress.Proofs Require Import
  GameTypes InputSemantics CleanEntry ObjectProvenance StarCollection
  CollisionRegions AreaTransitions HiddenStar LowerEntrance UpperEntrance
  ClightFacts ClightRefinement SelectedClightTarget ClightProjectionChronology
  ArchivedProofIntegration RouteEvidence
  TranscriptRouteModel
  FirstTargetRefinement JPSlotLifetime JPFirstApply FirstCrossingWriterCoverage
  OrdinaryMotion GoombaRaising PyramidTopPU InkFallback RetailFatalLatch
  InkPayloadInstaller TurningAnimation.

Import ListNotations.
Local Open Scope Z_scope.

(** This capstone is intentionally local to Marbler's proposed mechanism.  It
    combines the fully checked US/JP source/arithmetic boundary with the
    metadata-model theorem.  The DMA/memory and linked-transition refinement
    obligations in [TurningAnimation.v] remain open, so this is not a global
    animation or route-exhaustiveness theorem. *)
Theorem turning_part2_animation_metadata_boundary_excludes_ink_split :
  turning_animation_source_kernel /\
  forall before after,
    TurningPart2MetadataStep before after ->
    three_views_synchronized before ->
    three_views_synchronized after.
Proof.
  split.
  - exact turning_animation_source_kernel_checked.
  - exact turning_part2_metadata_cannot_create_ink_split.
Qed.

Definition CollectionProvenanceReductionClaim : Prop :=
  forall initial events final,
    CleanPyramidEntry initial ->
    CertifiedExecution initial events final ->
    (newly_collected
       (state_save_flags initial) (state_save_flags final) act3_index ->
      exists star phase,
        In (EventCollectAct3 star phase) events /\
        active_star_or_key act3_index star /\
        object_origin star = StaticAct3PyramidStar /\
        act3_star_interaction_region phase star) /\
    (newly_collected
       (state_save_flags initial) (state_save_flags final) act6_index ->
      (exists star phase,
        In (EventCollectAct6 star phase) events /\
        active_star_or_key act6_index star /\
        object_origin star = PyramidHiddenStarController /\
        overlaps_object phase star) /\
      (exists spawned_star,
        In (EventSpawnAct6 spawned_star) events) /\
      all_five_trigger_consumption_events events /\
      (exists trigger_object phase,
        In (EventConsumeTrigger TriggerUpper trigger_object phase) events /\
        upper_hidden_trigger_overlap phase trigger_object)).

Theorem collection_provenance_reduction :
  CollectionProvenanceReductionClaim.
Proof.
  unfold CollectionProvenanceReductionClaim.
  intros initial events final Hclean Hexec. split.
  - apply newly_collected_act3_requires_collection_event. exact Hexec.
  - intro Hnew. split.
    + apply newly_collected_act6_requires_collection_event with
        (initial := initial) (final := final).
      * exact Hexec.
      * exact Hnew.
    + destruct (spawning_act6_requires_all_five_and_upper_overlap
        initial events final Hclean Hexec Hnew) as [Hspawn Hupper].
      split.
      * exact Hspawn.
      * split.
        -- eapply newly_collected_act6_from_clean_requires_all_five_trigger_consumptions;
          eauto.
        -- exact Hupper.
Qed.

(* This packages the current checked archive kernels and the JP slot-lifetime
   staging boundary with the certified-event reduction so they are on the
   project verification spine.  The conjunction is intentionally not
   described as a semantic bridge between them, and is not the ultimate
   gameplay theorem. *)
Theorem current_verified_evidence_and_collection_reduction :
  ArchivedProofIntegrationKernel /\
  JPDelayedWarpSlotBoundaryClaim /\
  CollectionProvenanceReductionClaim.
Proof.
  split.
  - exact archived_proof_integration_kernel_holds.
  - split.
    + exact jp_delayed_warp_slot_boundary_checked.
    + exact collection_provenance_reduction.
Qed.

(** This capstone exposes only the corrected finite JP boundary.  The `84/85`
    totals and free-list windows are conditional arithmetic; the concrete
    destination-scoped Clight census is still
    [JPFirstApplySourceProjectionObligation].  In particular, this theorem
    does not claim that an early-freed top has any selected depth. *)
Theorem current_jp_first_apply_finite_boundary :
  jp_loader_fresh_allocations = 74%nat /\
  jp_pre_true_first_apply_fresh_allocations false = 84%nat /\
  jp_pre_true_first_apply_fresh_allocations true = 85%nat /\
  jp_spindel_conditional_free_list_depth_zero_based = 63%nat /\
  (forall depth,
    jp_free_list_depth_is_popped false depth <-> (depth <= 83)%nat) /\
  (forall depth,
    jp_free_list_depth_survives true depth <-> (85 <= depth)%nat).
Proof.
  split; [exact jp_loader_allocation_decomposition_is_74 |].
  split; [exact jp_pre_true_first_apply_count_without_saved_cap |].
  split; [exact jp_pre_true_first_apply_count_with_saved_cap |].
  split; [exact jp_spindel_conditional_free_list_depth_is_63 |].
  split.
  - exact jp_no_cap_popped_depths_are_exactly_0_through_83.
  - exact jp_saved_cap_surviving_depths_begin_at_85.
Qed.

(** Ink's graphics split is one possible Layer-1 installer; the JP pointer
    fate is Layer 2.  This capstone exposes only the exact conditional timer
    arithmetic used by that composition.  It does not inhabit any of the
    Clight installer or first-apply refinement obligations. *)
Theorem current_ink_payload_installer_timer_boundary :
  timer_schedule_is_consistent exact_installer_timer_schedule /\
  (forall f0_timer,
    unit_timer_increments 19%nat f0_timer = 150%nat ->
    f0_timer = 131%nat).
Proof.
  split.
  - exact exact_installer_timer_schedule_is_consistent.
  - exact f0_top_timer_is_forced_to_131.
Qed.

(* The ordinary-motion tranche intentionally exposes both sides of the
   current upper arithmetic boundary: the non-Wing source/mesh/arithmetic
   kernel stays below the integer-translation vertical rejection threshold,
   while the retained-Wing-Cap arithmetic countermodel exceeds the non-Wing
   rollout bound without a new A edge but still stays below that threshold.
   The changed gravity is why cap initialization is an explicit refinement
   obligation.  Neither conjunction is a retail collision-containment or
   route theorem. *)
Theorem current_ordinary_motion_evidence_boundary :
  UpperOrdinaryAscentKernel /\
  follows_vertical_step
      wing_cap_held_gravity_step wing_cap_rollout_velocity_trace = true /\
  wing_cap_rollout_relative_rise = 228 /\
  220 < wing_cap_rollout_relative_rise /\
  wing_cap_rollout_relative_rise < pyramid_elevator_cage_clearance /\
  fewer_than_one_a_press
    (repeat held_a_frame (length wing_cap_rollout_velocity_trace)).
Proof.
  split.
  - exact upper_ordinary_ascent_kernel_checked.
  - exact wing_cap_rollout_arithmetic_countermodel.
Qed.

(* The transcript's regular-Goomba observation is a real but bounded,
   conditional state-machine primitive.  The idealized Z-valued H/F/R model
   adds 21 per cycle; binary32 proves the 25 + (-4) velocity update and the
   concrete integer-aligned Y=51 computations at 31 and 83 rises, but not a
   universal exact-21 position recurrence.  This capstone also records the
   binary32 fixed-point witness at 2^29, the integer-abstraction Spindel
   height-band exclusion for the Area-2 Y=778 singleton, and the 31-hit bound
   for the specific post-collision H/F/R top-window schedule.  It does not
   provide linked binary32 hitbox bounds or inhabit the
   full-float shuttle, alternate pre-collision writer, PU capture/transport,
   or height-handoff obligations. *)
Theorem current_goomba_raising_bounded_boundary :
  goomba_raising_bounded_claim.
Proof.
  exact goomba_raising_bounded_kernel.
Qed.

(* This packages the bounded model beside the generated US/JP source receipts
   on the verification spine.  It is only a conjunction: no conjunct states
   that a linked Clight execution refines the H/F/R transition system. *)
Theorem current_goomba_raising_source_event_boundary :
  goomba_raising_bounded_claim /\
  goomba_state_machine_source_shape_us_claim /\
  goomba_state_machine_source_shape_jp_claim /\
  goomba_player_collision_source_shape_us_claim /\
  goomba_player_collision_source_shape_jp_claim /\
  spindel_pu_station_source_shape_us_claim /\
  spindel_pu_station_source_shape_jp_claim.
Proof.
  split; [exact goomba_raising_bounded_kernel |].
  split; [exact goomba_state_machine_source_shape_us |].
  split; [exact goomba_state_machine_source_shape_jp |].
  split; [exact goomba_player_collision_source_shape_us |].
  split; [exact goomba_player_collision_source_shape_jp |].
  split; [exact spindel_pu_station_source_shape_us |].
  exact spindel_pu_station_source_shape_jp.
Qed.

(* The graphical-fallback tranche shows that update order does not by itself
   refute the scheduling shape; it does not execute the branch in Clight or
   settle clean-entry reachability.  It provides local and PU conditional
   pipeline-coordinate witnesses, exact nearby static-mesh arithmetic, the
   fifteen-owner abstract dynamic-floor exclusion for the first query, and the
   invariant that State-only ordinary/PU writes preserve Object and Graphics.
   The linked branch/surface refinement and writer/action closure are explicit
   obligations in [InkFallback], so this is not the ultimate theorem. *)
Theorem current_ink_fallback_evidence_boundary :
  InkFallbackCheckedBoundary /\
  (forall owner floor_y,
    ~ stock_dynamic_geometry_floor_candidate
        owner ink_warp_floor_miss_position floor_y) /\
  (forall object_position graphics_position floor_y,
    upper_warp_contact object_position ->
    -32768 <= position_y graphics_position < 32768 ->
    position_y graphics_position - position_y object_position <= 45 ->
    pyramid_top_floor_min_y <= floor_y ->
    ~ floor_query_can_return graphics_position floor_y).
Proof.
  split; [exact ink_fallback_checked_boundary |].
  split.
  - exact ink_first_query_has_no_modeled_stock_dynamic_floor_candidate.
  - exact dry_graphics_offset_cannot_supply_top_retry.
Qed.

(* Within the finite event system, the retail fatal-latch tranche closes the
   scheduler-level loophole in the double-NULL graphical fallback.  Once
   death/game-over wins the empty first-writer latch, a later ACT_DISAPPEARED
   tick cannot replace it.  Every modeled clear event is an atomic barrier that
   destroys the old continuation.  The checked boundary includes the
   direct-writer and explicit address-taking censuses for the generated US/JP
   level-update units, but is not an iterated linked-Clight alias,
   memory-safety, clear-order, or destination-selection theorem. *)
Theorem current_retail_fatal_latch_boundary :
  RetailFatalLatchCheckedBoundary /\
  forall kind events,
    retail_fatal_or_old_continuation_destroyed
      (retail_latch_run events (retail_after_both_null_frame kind)) /\
    retail_upper_request_accepted
      (retail_latch_run events (retail_after_both_null_frame kind)) = false.
Proof.
  split.
  - exact retail_fatal_latch_checked_boundary.
  - exact retail_fatal_persists_or_reset_destroys_disappeared.
Qed.

(* Capstone exposure of the transcript-derived route-gate reduction.  The
   [TranscriptRouteGateModel] premise is an unproved abstract route-coverage
   certificate, not a consequence of the generated Clight modules.  Likewise,
   the separate downstream-completeness premises used by the sufficiency
   theorems remain open. *)
Theorem transcript_route_gate_reduction :
  forall initial trace,
    TranscriptRouteGateModel initial trace ->
    fewer_than_one_a_press (route_inputs trace) ->
    reaches_any_target_region trace ->
    (state_entrance initial = UpperEntrance /\
       elevator_escape_observed trace) \/
    (state_entrance initial = LowerEntrance /\
       above_second_pole_observed trace).
Proof.
  exact no_a_target_access_requires_gate_bypass.
Qed.

(* Corrected first-crossing coverage.  Unlike the older unused writer
   inventory, the premise names an entrance-contracted cut, endpoint-local
   side separation, an actual source-to-target Clight segment, and its
   minimality.  The conclusion is exhaustive for non-target projected events:
   either the position writer is ordinary physics, platform displacement,
   object impulse, collision clip, or area reload, or unchanged coordinates
   crossed the cut through a floor/platform support-selection change.
   Selecting and constructing the target-specific cut from a linked run
   remains open. *)
Theorem validated_first_crossing_writer_reduction :
  forall projection run initial certificate region target_frame
      (crossing :
        FirstValidatedCutCrossingAt
          projection run initial certificate region target_frame),
    FirstCrossingWriterCause
      (first_crossing_event _ _ _ _ _ _ crossing)
      (first_crossing_before _ _ _ _ _ _ crossing)
      (first_crossing_after _ _ _ _ _ _ crossing).
Proof.
  exact validated_pre_target_first_crossing_writer_coverage.
Qed.

(* This is the stronger first-crossing formulation.  Its coverage premise is
   deliberately named [FirstTargetCutClassificationObligation]: proving that
   premise from Clight plus the collision mesh is the still-open route
   exhaustiveness task.  The conclusion identifies the exact preceding gate A
   edge or a finite entrance-specific bypass class tag.  Those tags are
   payload-free bookkeeping, not evidence of the classified trajectory. *)
Theorem first_target_cut_coverage_reduction :
  forall initial trace,
    FirstTargetCutClassificationObligation initial trace ->
    reaches_any_target_region trace ->
    exists region target_frame target_observation,
      first_target_observation_at
        trace region target_frame target_observation /\
      ((state_entrance initial = UpperEntrance /\
        (gate_a_press_precedes_exact_target trace ElevatorJumpOutGate
           region target_frame target_observation \/
         exists witness,
           upper_bypass_precedes_exact_target trace witness
             region target_frame target_observation)) \/
       (state_entrance initial = LowerEntrance /\
        (gate_a_press_precedes_exact_target trace SecondPoleJumpOffGate
           region target_frame target_observation \/
         exists witness,
           lower_bypass_precedes_exact_target trace witness
             region target_frame target_observation))).
Proof.
  exact first_target_access_requires_gate_a_or_explicit_bypass.
Qed.

Theorem first_target_cut_with_all_bypasses_excluded_requires_a_edge :
  forall initial trace,
    FirstTargetCutClassificationObligation initial trace ->
    reaches_any_target_region trace ->
    ExcludesAllUpperBypassWitnesses trace ->
    ExcludesAllLowerBypassWitnesses trace ->
    trace_contains_a_press trace.
Proof.
  exact first_target_access_with_all_bypasses_excluded_requires_a_edge.
Qed.

(* This is the target-bit-facing route capstone.  In contrast with the older
   payload-free cut theorem above, every bypass alternative carries a concrete
   Clight frame segment and projected before/after states.  The remaining
   premises are explicit: constructing that evidence-bearing classification
   and proving the six open writer/geometry classes unreachable are the Layer-B
   residuals; constructing the frame certificate and route projection remains
   part of the whole-program refinement residual. *)
Theorem evidence_bearing_route_cut_blocks_new_target_bits :
  forall projection run initial certificate trace,
    CleanPyramidEntry initial ->
    ClightRouteTraceProjection projection run initial certificate trace ->
    EvidenceBearingFirstTargetCutClassification
      projection run initial certificate trace ->
    OpenRouteWriterClassesUnreachable
      projection run initial certificate trace ->
    fewer_than_one_a_press (project_inputs projection run) ->
    ~ newly_collected
        (state_save_flags initial)
        (state_save_flags
          (refined_final_state projection run initial certificate))
        act3_index /\
    ~ newly_collected
        (state_save_flags initial)
        (state_save_flags
          (refined_final_state projection run initial certificate))
        act6_index.
Proof.
  exact evidence_classifier_with_open_writers_closed_blocks_new_target_bits.
Qed.

(* Whole-program exposure of the evidence-bearing route path.  This theorem
   deliberately keeps three independent residuals visible:

   - construct the ordinary Clight frame/event refinement certificate;
   - construct an evidence-bearing first-cut classification for its route;
   - exclude the six surviving writer/geometry classes under no A edge.

   The first residual includes Layer A.  The latter two are the current Layer B
   route-exhaustiveness boundary. *)
Theorem conditional_evidence_bearing_clight_run_impossibility :
  forall projection,
    WholeProgramClightRefinementObligation projection ->
    EvidenceBearingRouteClassificationRefinementObligation projection ->
    NoAOpenRouteWriterClassesUnreachableObligation projection ->
    forall run initial,
      RunUsesProjection projection run ->
      project_state projection (run_start run) = Some initial ->
      RunEndsAtSelectedFrameBoundary projection run ->
      CleanPyramidEntry initial ->
      fewer_than_one_a_press (project_inputs projection run) ->
      exists final,
        project_state projection (run_final run) = Some final /\
        ~ newly_collected
            (state_save_flags initial) (state_save_flags final) act3_index /\
        ~ newly_collected
            (state_save_flags initial) (state_save_flags final) act6_index.
Proof.
  intros projection Hwhole Hclassify Hclose run initial
    Huses Hstart Hend Hclean Hnoa.
  destruct (Hwhole run initial Huses Hstart Hend) as [certificate _].
  destruct (Hclassify run initial certificate Hclean)
    as [trace [Hroute Hclassifier]].
  pose proof (Hclose run initial certificate trace
    Hclean Hroute Hclassifier Hnoa) as Hclosed.
  exists (refined_final_state projection run initial certificate).
  split.
  - exact (refined_final_matches projection run initial certificate).
  - eapply evidence_bearing_route_cut_blocks_new_target_bits; eauto.
Qed.

Theorem conditional_less_than_one_a_press_impossibility :
  forall projection,
  LowerEntranceReachabilityObligation projection ->
  UpperEntranceReachabilityObligation projection ->
  forall run initial
      (certificate : ClightFrameRefinementCertificate projection run initial),
    CleanPyramidEntry initial ->
    fewer_than_one_a_press (project_inputs projection run) ->
    ~ newly_collected
        (state_save_flags initial)
        (state_save_flags
           (refined_final_state projection run initial certificate)) act3_index /\
    ~ newly_collected
        (state_save_flags initial)
        (state_save_flags
           (refined_final_state projection run initial certificate)) act6_index.
Proof.
  intros projection Hlower [Hupper_us Hupper_jp]
    run initial certificate Hclean Hnoa.
  assert (Hregions :
    NoAct3InteractionOverlap
      (project_collision_observations projection run) /\
    NoUpperTriggerOverlap
      (project_collision_observations projection run)).
  {
    destruct (clean_selected_entrance initial Hclean) as [Hentry | Hentry].
    - eapply Hlower; eauto.
    - destruct (state_version initial) eqn:Hversion.
      + eapply Hupper_us; eauto.
      + eapply Hupper_jp; eauto.
  }
  destruct Hregions as [Hnoact3 Hnoupper]. split.
  - intro Hnew.
    destruct (newly_collected_act3_requires_collection_event
      initial (project_events projection run)
      (refined_final_state projection run initial certificate)
      (refined_execution projection run initial certificate) Hnew)
      as (star & phase & Hin & Hactive & Horigin & Hoverlap).
    pose proof
      (refined_act3_collections_observed projection run initial certificate
        star phase Hin) as Hobserved.
    exact (Hnoact3 star phase Hobserved Hoverlap).
  - intro Hnew.
    destruct (spawning_act6_requires_all_five_and_upper_overlap
      initial (project_events projection run)
      (refined_final_state projection run initial certificate) Hclean
      (refined_execution projection run initial certificate) Hnew)
      as (_ & trigger_object & phase & Hin & Hoverlap).
    pose proof
      (refined_trigger_consumptions_observed projection run initial certificate
        TriggerUpper trigger_object phase Hin) as Hobserved.
    exact (Hnoupper trigger_object phase Hobserved Hoverlap).
Qed.

Theorem conditional_target_clight_run_impossibility :
  forall projection,
  ObservedSelectedTargetClightRefinementObligation projection ->
  LowerEntranceReachabilityObligation projection ->
  UpperEntranceReachabilityObligation projection ->
  forall run initial,
    RunUsesProjection projection run ->
    project_state projection (run_start run) = Some initial ->
    RunEndsAtSelectedFrameBoundary projection run ->
    CleanPyramidEntry initial ->
    fewer_than_one_a_press (project_inputs projection run) ->
    exists final,
      project_state projection (run_final run) = Some final /\
      ~ newly_collected
          (state_save_flags initial) (state_save_flags final) act3_index /\
      ~ newly_collected
          (state_save_flags initial) (state_save_flags final) act6_index.
Proof.
  intros projection Hobserved Hlower Hupper run initial
    Huses Hstart Hend Hclean Hnoa.
  destruct Hobserved as
    [Hselected_program [Hsource [Haudit
      [observer [Hobserved_chronology Hentries]]]]].
  pose proof
    (observed_selected_target_refinement_supplies_selected_refinement
      projection
      (conj Hselected_program
        (conj Hsource
            (conj Haudit
            (ex_intro _ observer
              (conj Hobserved_chronology Hentries)))))) as Hselected.
  destruct Hselected as [_ [_ [_ [Hrefine _]]]].
  destruct (Hrefine run initial Huses Hstart Hend) as [certificate _].
  exists (refined_final_state projection run initial certificate).
  split.
  - exact (refined_final_matches projection run initial certificate).
  - eapply conditional_less_than_one_a_press_impossibility; eauto.
Qed.
