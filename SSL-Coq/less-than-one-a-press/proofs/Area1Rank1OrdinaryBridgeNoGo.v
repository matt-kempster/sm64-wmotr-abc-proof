(** Integration/no-go capstone for the ordinary Area-1 collision/query split.

    The currently constructed source-backed split is the cached-floor witness:
    collision sees (-2048, 818, -1024), the completed final query sees
    (-2048, 768, -1024), X/Z are preserved, and the finite stock-owner query
    is null.  This module does not claim that this is the only split a linked
    retail execution could realize.

    Instead, it names the five concrete bridges under which the same ordinary
    accepted-warp tail would have to operate.  Those bridges are jointly
    inconsistent with a modeled top installation.  Quantifying over an
    arbitrary separately supplied cached-payload fate shows that the
    contradiction is logically independent of that argument.  It does not
    couple a lifecycle fate to the install or prove their trace ordering.

    Failure of this record is not a retail impossibility theorem.  It points
    to the remaining work: linked scheduler/callback refinement, selected
    geometry provenance, alias/external/final-receiver framing, or live
    surface-owner/list/query refinement. *)

From Coq Require Import ZArith.
From LessThanOneAPress.Proofs Require Import
  PyramidTopPU Area1PostCopyObjectWriterClosure
  Area1QueryScheduleClosure Area1InteractionShortCircuitClosure
  Area1PlatformExhaustiveness Area1SurfaceEpochLifecycle
  Area1CachedFloorSelectionClosure Area1CachedFloorSplitWitness
  Area1SchedulerSurfaceLifecycleSplit.

Local Open Scope Z_scope.

(** A [Type]-valued package, rather than an opaque proposition, keeps each
    linked bridge inspectable.  The fourth field is itself the existing
    explicit runtime record: its fields separately name faithful callback
    dispatch, selection/collision sample equality, the alias and external
    frames, and the final live-Mario-Object receiver. *)
Record Rank1OrdinaryTopInstallBridge
    (schedule : UpperWarpSelectionPositionSchedule)
    (shape : ModeledArea1FrameSchedule) : Type := {
  ordinary_bridge_modeled_same_frame_scheduler :
    schedule_contains ScheduleSelectUpperWarpDisappeared
      (stock_area1_schedule_events shape) /\
    schedule_contains ScheduleFinalPlatformQuery
      (stock_area1_schedule_events shape);

  ordinary_bridge_upper_warp_collision_contact :
    upper_warp_contact
      (position_z_of_schedule (schedule_collision_object schedule));

  ordinary_bridge_selected_cached_floor_refinement :
    floor_query_can_return
      (position_z_of_schedule (schedule_state_at_selection schedule))
      (schedule_y (schedule_state_after_disappeared schedule));

  ordinary_bridge_dispatch_selection_and_memory_projection :
    AcceptedNonfadingWarpRuntimeProjection schedule;

  ordinary_bridge_surface_owner_list_query_refinement :
    stock_area1_final_platform_query
      (position_z_of_schedule (schedule_final_query schedule))
      (Some A1PyramidTop)
}.

(** The lifecycle argument is intentionally arbitrary, separately supplied,
    and unused by the contradiction.  This proves logical independence, not a
    coupled lifecycle chronology.  Likewise, the same-frame scheduler field
    is packaged evidence for the intended live chronology, but the arithmetic
    contradiction does not need it once the runtime projection and final
    stock query are supplied.  The ordinary selected-floor theorem already
    makes that query null. *)
Theorem ordinary_top_install_no_go_is_independent_of_supplied_lifecycle_fate :
  forall schedule shape lifecycle_state,
    CachedApplyPayloadFate lifecycle_state ->
    Rank1OrdinaryTopInstallBridge schedule shape ->
    False.
Proof.
  intros schedule shape lifecycle_state _ bridge.
  pose proof
    (accepted_nonfading_warp_cached_floor_selection_stock_query_is_null
      schedule (Some A1PyramidTop)
      (ordinary_bridge_dispatch_selection_and_memory_projection
        schedule shape bridge)
      (ordinary_bridge_upper_warp_collision_contact
        schedule shape bridge)
      (ordinary_bridge_selected_cached_floor_refinement
        schedule shape bridge)
      (ordinary_bridge_surface_owner_list_query_refinement
        schedule shape bridge)) as Hnull.
  discriminate Hnull.
Qed.

(** The capstone packages, without strengthening, the two compiled boundaries:

    - the exact downward/Y-only/null ordinary witness and its static face
      receipt; and
    - the scheduler/owner theorem that any modeled non-null top query must use
      a position distinct from the collision sample.

    The final conjunct is the new integration result above, not a claim that a
    clean linked run satisfies the five-field bridge. *)
Definition Area1Rank1OrdinaryBridgeNoGoBoundary : Prop :=
  Area1CachedFloorSplitWitnessBoundary /\
  schedule_y
      (schedule_final_query cached_floor_collision_query_split_schedule) -
    schedule_y
      (schedule_collision_object cached_floor_collision_query_split_schedule) =
    -50 /\
  Area1SchedulerSurfaceLifecycleSplitCheckedBoundary /\
  (forall (schedule : UpperWarpSelectionPositionSchedule) shape,
    schedule_contains ScheduleSelectUpperWarpDisappeared
      (stock_area1_schedule_events shape) ->
    upper_warp_contact
      (position_z_of_schedule (schedule_collision_object schedule)) ->
    stock_area1_final_platform_query
      (position_z_of_schedule (schedule_final_query schedule))
      (Some A1PyramidTop) ->
    schedule_contains ScheduleFinalPlatformQuery
        (stock_area1_schedule_events shape) /\
      position_z_of_schedule (schedule_final_query schedule) <>
        position_z_of_schedule (schedule_collision_object schedule)) /\
  (forall schedule shape lifecycle_state,
    CachedApplyPayloadFate lifecycle_state ->
    Rank1OrdinaryTopInstallBridge schedule shape ->
    False).

Theorem area1_rank1_ordinary_bridge_no_go_boundary_holds :
  Area1Rank1OrdinaryBridgeNoGoBoundary.
Proof.
  unfold Area1Rank1OrdinaryBridgeNoGoBoundary.
  split; [exact area1_cached_floor_split_witness_boundary_holds |].
  split; [exact cached_floor_split_moves_fifty_units_downward |].
  split;
    [exact area1_scheduler_surface_lifecycle_split_checked_boundary_holds |].
  split.
  - exact
      modeled_accepted_warp_schedule_top_installer_derives_collision_query_split.
  - exact
      ordinary_top_install_no_go_is_independent_of_supplied_lifecycle_fate.
Qed.
