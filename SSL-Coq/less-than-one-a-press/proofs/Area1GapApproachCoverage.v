(** Exhaustive conditional coverage for ways a local-Object/nonlocal-State
    gap can first appear or survive into the SSL Area-1 pre-collision sample.

    The existing four null-seed lineage fields classify a completed platform
    query.  They do not by themselves classify a split created without a
    platform pointer, a query/current sample mismatch, a moving skipped
    frame, an interaction-stage writer, or a failure of one of the three
    pre-collision stage refinements.  This module makes those alternatives
    explicit without pretending that a linked retail run has supplied the
    required projection. *)

From Coq Require Import Classical_Prop List ZArith.
From LessThanOneAPress.Proofs Require Import
  Area1PrecollisionWriterClosure Area1QueryScheduleClosure CollisionRegions
  GameTypes PyramidTopPU StateFirstPlatformChronology.

Import ListNotations.

(** * First divergence of the State/Object views *)

Section FirstDivergence.

Context {Coordinate : Type}.

Record StateObjectViews : Type := {
  gap_state_view : Coordinate;
  gap_object_view : Coordinate
}.

Definition state_object_synchronized (views : StateObjectViews) : Prop :=
  gap_state_view views = gap_object_view views.

Definition state_object_split (views : StateObjectViews) : Prop :=
  gap_state_view views <> gap_object_view views.

Inductive GapCreationShape
    (before after : StateObjectViews) : Prop :=
| GapCreatedByStateEndpoint :
    gap_state_view after <> gap_state_view before ->
    gap_object_view after = gap_object_view before ->
    GapCreationShape before after
| GapCreatedByObjectEndpoint :
    gap_state_view after = gap_state_view before ->
    gap_object_view after <> gap_object_view before ->
    GapCreationShape before after
| GapCreatedByBothEndpoints :
    gap_state_view after <> gap_state_view before ->
    gap_object_view after <> gap_object_view before ->
    GapCreationShape before after.

Theorem synchronized_to_split_has_one_of_three_creation_shapes :
  forall before after,
    state_object_synchronized before ->
    state_object_split after ->
    GapCreationShape before after.
Proof.
  intros before after Hbefore Hafter.
  destruct (classic
    (gap_state_view after = gap_state_view before)) as [Hstate | Hstate];
  destruct (classic
    (gap_object_view after = gap_object_view before)) as [Hobject | Hobject].
  - exfalso. apply Hafter. rewrite Hstate, Hobject. exact Hbefore.
  - now apply GapCreatedByObjectEndpoint.
  - now apply GapCreatedByStateEndpoint.
  - now apply GapCreatedByBothEndpoints.
Qed.

Inductive StateObjectTrace
    (step : StateObjectViews -> StateObjectViews -> Prop) :
    StateObjectViews -> StateObjectViews -> Prop :=
| StateObjectTraceNil :
    forall views, StateObjectTrace step views views
| StateObjectTraceCons :
    forall before middle after,
      step before middle ->
      StateObjectTrace step middle after ->
      StateObjectTrace step before after.

(** A prefix certificate that exposes the property needed to call the next
    edge the first divergence: every state through the end of this prefix is
    synchronized.  A plain [StateObjectTrace] prefix does not retain that
    invariant in its conclusion. *)
Inductive SynchronizedStateObjectTrace
    (step : StateObjectViews -> StateObjectViews -> Prop) :
    StateObjectViews -> StateObjectViews -> Prop :=
| SynchronizedStateObjectTraceNil :
    forall views,
      state_object_synchronized views ->
      SynchronizedStateObjectTrace step views views
| SynchronizedStateObjectTraceCons :
    forall before middle after,
      state_object_synchronized before ->
      step before middle ->
      SynchronizedStateObjectTrace step middle after ->
      SynchronizedStateObjectTrace step before after.

Theorem synchronized_trace_ending_split_exposes_first_divergence :
  forall step start finish,
    StateObjectTrace step start finish ->
    state_object_synchronized start ->
    state_object_split finish ->
    exists before after,
      SynchronizedStateObjectTrace step start before /\
      step before after /\
      state_object_synchronized before /\
      state_object_split after /\
      StateObjectTrace step after finish.
Proof.
  intros step start finish Htrace.
  induction Htrace as
    [views | before middle after Hstep Htail IH];
    intros Hsync Hsplit.
  - contradiction.
  - destruct (classic (state_object_synchronized middle)) as
      [Hmiddle_sync | Hmiddle_split].
    + destruct (IH Hmiddle_sync Hsplit) as
        (first_before & first_after & Hprefix & Hfirst & Hfirst_sync &
         Hfirst_split & Hsuffix).
      exists first_before, first_after.
      repeat split.
      * now apply SynchronizedStateObjectTraceCons with (middle := middle).
      * exact Hfirst.
      * exact Hfirst_sync.
      * exact Hfirst_split.
      * exact Hsuffix.
    + exists before, middle.
      repeat split.
      * now apply SynchronizedStateObjectTraceNil.
      * exact Hstep.
      * exact Hsync.
      * exact Hmiddle_split.
      * exact Htail.
Qed.

Theorem trace_ending_in_gap_has_state_object_or_joint_first_creator :
  forall step start finish,
    StateObjectTrace step start finish ->
    state_object_synchronized start ->
    state_object_split finish ->
    exists before after,
      SynchronizedStateObjectTrace step start before /\
      step before after /\
      state_object_synchronized before /\
      state_object_split after /\
      GapCreationShape before after /\
      StateObjectTrace step after finish.
Proof.
  intros step start finish Htrace Hsync Hsplit.
  destruct (synchronized_trace_ending_split_exposes_first_divergence
    step start finish Htrace Hsync Hsplit) as
    (before & after & Hprefix & Hstep & Hbefore & Hafter & Hsuffix).
  exists before, after.
  repeat split; try assumption.
  now apply synchronized_to_split_has_one_of_three_creation_shapes.
Qed.

(** * Survival after the first divergence

    Creation and survival are different obligations.  Once both endpoints are
    unequal before and after a step, their value-level evolution has exactly
    four shapes: neither endpoint changed, only State changed, only Object
    changed, or both changed.  These constructors retain both split facts so a
    later proof cannot mistake an intermediate resynchronization for a
    sustained gap. *)
Inductive GapPersistenceShape
    (before after : StateObjectViews) : Prop :=
| GapPersistsWithoutEndpointChange :
    state_object_split before ->
    state_object_split after ->
    gap_state_view after = gap_state_view before ->
    gap_object_view after = gap_object_view before ->
    GapPersistenceShape before after
| GapPersistsThroughStateEndpointChange :
    state_object_split before ->
    state_object_split after ->
    gap_state_view after <> gap_state_view before ->
    gap_object_view after = gap_object_view before ->
    GapPersistenceShape before after
| GapPersistsThroughObjectEndpointChange :
    state_object_split before ->
    state_object_split after ->
    gap_state_view after = gap_state_view before ->
    gap_object_view after <> gap_object_view before ->
    GapPersistenceShape before after
| GapPersistsThroughBothEndpointChanges :
    state_object_split before ->
    state_object_split after ->
    gap_state_view after <> gap_state_view before ->
    gap_object_view after <> gap_object_view before ->
    GapPersistenceShape before after.

Theorem split_to_split_has_one_of_four_persistence_shapes :
  forall before after,
    state_object_split before ->
    state_object_split after ->
    GapPersistenceShape before after.
Proof.
  intros before after Hbefore Hafter.
  destruct (classic
    (gap_state_view after = gap_state_view before)) as [Hstate | Hstate];
  destruct (classic
    (gap_object_view after = gap_object_view before)) as [Hobject | Hobject].
  - now apply GapPersistsWithoutEndpointChange.
  - now apply GapPersistsThroughObjectEndpointChange.
  - now apply GapPersistsThroughStateEndpointChange.
  - now apply GapPersistsThroughBothEndpointChanges.
Qed.

(** Every edge of this suffix is explicitly certified split-to-split and is
    classified by its endpoint changes. *)
Inductive SplitStateObjectTrace
    (step : StateObjectViews -> StateObjectViews -> Prop) :
    StateObjectViews -> StateObjectViews -> Prop :=
| SplitStateObjectTraceNil :
    forall views,
      state_object_split views ->
      SplitStateObjectTrace step views views
| SplitStateObjectTraceCons :
    forall before middle after,
      state_object_split before ->
      state_object_split middle ->
      step before middle ->
      SplitStateObjectTrace step middle after ->
      SplitStateObjectTrace step before after.

Inductive SplitPreservingStateObjectTrace
    (step : StateObjectViews -> StateObjectViews -> Prop) :
    StateObjectViews -> StateObjectViews -> Prop :=
| SplitPreservingStateObjectTraceNil :
    forall views,
      state_object_split views ->
      SplitPreservingStateObjectTrace step views views
| SplitPreservingStateObjectTraceCons :
    forall before middle after,
      step before middle ->
      GapPersistenceShape before middle ->
      SplitPreservingStateObjectTrace step middle after ->
      SplitPreservingStateObjectTrace step before after.

Theorem split_state_object_trace_has_classified_persistence_steps :
  forall step start finish,
    SplitStateObjectTrace step start finish ->
    SplitPreservingStateObjectTrace step start finish.
Proof.
  intros step start finish Htrace.
  induction Htrace as
    [views Hsplit |
     before middle after Hbefore Hmiddle Hstep Htail IH].
  - now apply SplitPreservingStateObjectTraceNil.
  -
    apply SplitPreservingStateObjectTraceCons with (middle := middle).
    + exact Hstep.
    + now apply split_to_split_has_one_of_four_persistence_shapes.
    + exact IH.
Qed.

(** Trace-local evidence for an actually sustained gap.  Unlike a global
    closure assumption on [step], this record constrains only the supplied
    prefix, creator, and suffix.  Linked Clight must construct the suffix or
    expose the first step that resynchronizes the endpoints. *)
Record SustainedGapExecution
    (step : StateObjectViews -> StateObjectViews -> Prop)
    (start finish : StateObjectViews) : Type := {
  sustained_gap_creator_before : StateObjectViews;
  sustained_gap_creator_after : StateObjectViews;
  sustained_gap_synchronized_prefix :
    SynchronizedStateObjectTrace step start sustained_gap_creator_before;
  sustained_gap_creator_step :
    step sustained_gap_creator_before sustained_gap_creator_after;
  sustained_gap_creator_before_synchronized :
    state_object_synchronized sustained_gap_creator_before;
  sustained_gap_creator_after_split :
    state_object_split sustained_gap_creator_after;
  sustained_gap_split_suffix :
    SplitStateObjectTrace step sustained_gap_creator_after finish
}.

(** Conditional capstone: the supplied trace-local sustained-gap evidence has
    a classified first creator and a four-way-classified survival suffix. *)
Theorem gap_preserving_trace_has_first_creator_and_classified_suffix :
  forall step start finish,
    SustainedGapExecution step start finish ->
    exists before after,
      SynchronizedStateObjectTrace step start before /\
      step before after /\
      state_object_synchronized before /\
      state_object_split after /\
      GapCreationShape before after /\
      SplitPreservingStateObjectTrace step after finish.
Proof.
  intros step start finish Hexecution.
  destruct Hexecution as
    [before after Hprefix Hstep Hbefore Hafter Hsuffix].
  exists before, after.
  repeat split; try assumption.
  - now apply synchronized_to_split_has_one_of_three_creation_shapes.
  - now apply split_state_object_trace_has_classified_persistence_steps.
Qed.

End FirstDivergence.

(** None of the three value-level creators is contradictory in isolation.
    The next proof layer must classify the first transition as an internal
    writer, retarget/lifecycle effect, alias, or external effect. *)
Definition state_endpoint_countermodel_before : @StateObjectViews nat :=
  {| gap_state_view := 0%nat; gap_object_view := 0%nat |}.
Definition state_endpoint_countermodel_after : @StateObjectViews nat :=
  {| gap_state_view := 1%nat; gap_object_view := 0%nat |}.
Definition object_endpoint_countermodel_after : @StateObjectViews nat :=
  {| gap_state_view := 0%nat; gap_object_view := 1%nat |}.
Definition joint_endpoint_countermodel_after : @StateObjectViews nat :=
  {| gap_state_view := 1%nat; gap_object_view := 2%nat |}.

Theorem all_three_gap_creation_shapes_are_abstractly_inhabited :
  GapCreationShape
    state_endpoint_countermodel_before state_endpoint_countermodel_after /\
  GapCreationShape
    state_endpoint_countermodel_before object_endpoint_countermodel_after /\
  GapCreationShape
    state_endpoint_countermodel_before joint_endpoint_countermodel_after.
Proof.
  split.
  - apply GapCreatedByStateEndpoint; [cbn; discriminate | reflexivity].
  - split.
    + apply GapCreatedByObjectEndpoint; [reflexivity | cbn; discriminate].
    + apply GapCreatedByBothEndpoints; cbn; discriminate.
Qed.

Definition persistence_countermodel_before : @StateObjectViews nat :=
  {| gap_state_view := 0%nat; gap_object_view := 1%nat |}.
Definition persistence_countermodel_state_after : @StateObjectViews nat :=
  {| gap_state_view := 2%nat; gap_object_view := 1%nat |}.
Definition persistence_countermodel_object_after : @StateObjectViews nat :=
  {| gap_state_view := 0%nat; gap_object_view := 2%nat |}.
Definition persistence_countermodel_both_after : @StateObjectViews nat :=
  {| gap_state_view := 2%nat; gap_object_view := 3%nat |}.

Theorem all_four_gap_persistence_shapes_are_abstractly_inhabited :
  GapPersistenceShape
    persistence_countermodel_before persistence_countermodel_before /\
  GapPersistenceShape
    persistence_countermodel_before persistence_countermodel_state_after /\
  GapPersistenceShape
    persistence_countermodel_before persistence_countermodel_object_after /\
  GapPersistenceShape
    persistence_countermodel_before persistence_countermodel_both_after.
Proof.
  repeat split.
  - apply GapPersistsWithoutEndpointChange.
    + cbn. discriminate.
    + cbn. discriminate.
    + reflexivity.
    + reflexivity.
  - apply GapPersistsThroughStateEndpointChange.
    + cbn. discriminate.
    + cbn. discriminate.
    + cbn. discriminate.
    + reflexivity.
  - apply GapPersistsThroughObjectEndpointChange.
    + cbn. discriminate.
    + cbn. discriminate.
    + reflexivity.
    + cbn. discriminate.
  - apply GapPersistsThroughBothEndpointChanges.
    + cbn. discriminate.
    + cbn. discriminate.
    + cbn. discriminate.
    + cbn. discriminate.
Qed.

(** * Completed-query source/current mismatch *)

Definition schedule_position_of_position_z (position : PositionZ) :
    SchedulePosition :=
  {| schedule_x := position_x position;
     schedule_y := position_y position;
     schedule_z := position_z position |}.

Lemma unequal_position_z_has_schedule_component_difference :
  forall left right,
    left <> right ->
    position_differs
      (schedule_position_of_position_z left)
      (schedule_position_of_position_z right).
Proof.
  intros [lx ly lz] [rx ry rz] Hneq.
  unfold position_differs, schedule_position_of_position_z; cbn.
  destruct (Z.eq_dec lx rx) as [Hx | Hx]; [right | now left].
  destruct (Z.eq_dec ly ry) as [Hy | Hy]; [right | now left].
  destruct (Z.eq_dec lz rz) as [Hz | Hz].
  - exfalso. apply Hneq. now subst.
  - exact Hz.
Qed.

Inductive CompletedQueryScheduleBridge
    (projection : UpperWarpPrecollisionApplyProjection)
    (source : PositionZ) : Type :=
| CompletedQueryHasFaithfulSchedule :
    forall schedule,
      schedule_final_query schedule =
        schedule_position_of_position_z source ->
      schedule_collision_object schedule =
        schedule_position_of_position_z
          (projected_collision_position projection) ->
      CompletedQueryScheduleBridge projection source
| CompletedQueryInteractionSelectionWriterEscape :
    CompletedQueryScheduleBridge projection source
| CompletedQueryMovingSkippedFrameEscape :
    CompletedQueryScheduleBridge projection source
| CompletedQueryUnclassifiedProjectionEscape :
    CompletedQueryScheduleBridge projection source.

Inductive CompletedQueryDifferentSampleApproach
    (projection : UpperWarpPrecollisionApplyProjection)
    (source : PositionZ) : Prop :=
| DifferentSampleFromPregeometryState : forall schedule,
    schedule_final_query schedule =
      schedule_position_of_position_z source ->
    schedule_collision_object schedule =
      schedule_position_of_position_z
        (projected_collision_position projection) ->
    position_differs
      (schedule_state_before_geometry schedule)
      (schedule_collision_object schedule) ->
    CompletedQueryDifferentSampleApproach projection source
| DifferentSampleFromGraphicsRetry : forall schedule,
    schedule_final_query schedule =
      schedule_position_of_position_z source ->
    schedule_collision_object schedule =
      schedule_position_of_position_z
        (projected_collision_position projection) ->
    position_differs
      (schedule_graphics_before_geometry schedule)
      (schedule_collision_object schedule) ->
    CompletedQueryDifferentSampleApproach projection source
| DifferentSampleFromCachedFloorSnap : forall schedule,
    schedule_final_query schedule =
      schedule_position_of_position_z source ->
    schedule_collision_object schedule =
      schedule_position_of_position_z
        (projected_collision_position projection) ->
    cached_floor_snap_differs_from_collision schedule ->
    CompletedQueryDifferentSampleApproach projection source
| DifferentSampleFromPostCopyDiscrepancy : forall schedule,
    schedule_final_query schedule =
      schedule_position_of_position_z source ->
    schedule_collision_object schedule =
      schedule_position_of_position_z
        (projected_collision_position projection) ->
    post_copy_sample_discrepancy schedule ->
    CompletedQueryDifferentSampleApproach projection source
| DifferentSampleFromInteractionSelectionWriter :
    CompletedQueryDifferentSampleApproach projection source
| DifferentSampleFromMovingSkippedFrame :
    CompletedQueryDifferentSampleApproach projection source
| DifferentSampleFromUnclassifiedProjection :
    CompletedQueryDifferentSampleApproach projection source.

Theorem completed_query_different_sample_expands_to_seven_approaches :
  forall projection source owner skipped,
    projected_final_lineage projection =
      PlatformLineageFinalQuery source owner skipped ->
    source <> projected_collision_position projection ->
    CompletedQueryScheduleBridge projection source ->
    CompletedQueryDifferentSampleApproach projection source.
Proof.
  intros projection source owner skipped _ Hdifferent Hbridge.
  destruct Hbridge as
    [schedule Hquery Hcollision | | |].
  - assert (Hgap : position_differs
      (schedule_final_query schedule)
      (schedule_collision_object schedule)).
    { rewrite Hquery, Hcollision.
      now apply unequal_position_z_has_schedule_component_difference. }
    destruct (final_query_gap_fits_four_abstract_cases schedule Hgap) as
      [Hstate | [Hgraphics | [Hfloor | Hpostcopy]]].
    + now apply DifferentSampleFromPregeometryState with (schedule := schedule).
    + now apply DifferentSampleFromGraphicsRetry with (schedule := schedule).
    + now apply DifferentSampleFromCachedFloorSnap with (schedule := schedule).
    + now apply DifferentSampleFromPostCopyDiscrepancy with (schedule := schedule).
  - apply DifferentSampleFromInteractionSelectionWriter.
  - apply DifferentSampleFromMovingSkippedFrame.
  - apply DifferentSampleFromUnclassifiedProjection.
Qed.

(** * Pre-collision stage failures *)

Section PrecollisionStageFailures.

Context {Coordinate : Type}.

Inductive PrecollisionGapApproach
    (entry terrain_sample platform_sample collision_sample :
      @MarioXYZViews Coordinate)
    (terrain_writer platform_refinement_escape collision_writer :
      @MarioXYZViews Coordinate -> @MarioXYZViews Coordinate -> Prop) : Prop :=
| PrecollisionGapWasAlreadyPresent :
    precollision_state_xyz entry <> precollision_object_xyz entry ->
    PrecollisionGapApproach entry terrain_sample platform_sample
      collision_sample terrain_writer platform_refinement_escape
      collision_writer
| PrecollisionTerrainFrameHasWriter :
    terrain_writer entry terrain_sample ->
    PrecollisionGapApproach entry terrain_sample platform_sample
      collision_sample terrain_writer platform_refinement_escape
      collision_writer
| PrecollisionPlatformRefinementEscapes :
    platform_refinement_escape terrain_sample platform_sample ->
    PrecollisionGapApproach entry terrain_sample platform_sample
      collision_sample terrain_writer platform_refinement_escape
      collision_writer
| PrecollisionEffectiveStateOnlyApply : forall next_state,
    collision_sample = write_precollision_state_only next_state entry ->
    next_state <> precollision_object_xyz entry ->
    PrecollisionGapApproach entry terrain_sample platform_sample
      collision_sample terrain_writer platform_refinement_escape
      collision_writer
| PrecollisionCollisionFrameHasWriter :
    collision_writer platform_sample collision_sample ->
    PrecollisionGapApproach entry terrain_sample platform_sample
      collision_sample terrain_writer platform_refinement_escape
      collision_writer.

Theorem precollision_split_expands_to_data_bearing_stage_approach :
  forall (entry terrain_sample platform_sample collision_sample :
      @MarioXYZViews Coordinate)
      (terrain_writer platform_refinement_escape collision_writer :
        @MarioXYZViews Coordinate -> @MarioXYZViews Coordinate -> Prop),
    (forall before after,
      ~ MarioXYZFrame before after -> terrain_writer before after) ->
    (forall before after,
      ~ PlatformMarioPhase before after ->
      platform_refinement_escape before after) ->
    (forall before after,
      ~ MarioXYZFrame before after -> collision_writer before after) ->
    precollision_state_xyz collision_sample <>
      precollision_object_xyz collision_sample ->
    PrecollisionGapApproach entry terrain_sample platform_sample
      collision_sample terrain_writer platform_refinement_escape
      collision_writer.
Proof.
  intros entry terrain_sample platform_sample collision_sample
    terrain_writer platform_escape collision_writer
    Hterrain_writer Hplatform_escape Hcollision_writer Hsplit.
  destruct (classic
    (precollision_state_xyz entry = precollision_object_xyz entry)) as
    [Hentry | Hentry].
  2: now apply PrecollisionGapWasAlreadyPresent.
  destruct (classic (MarioXYZFrame entry terrain_sample)) as
    [Hterrain | Hterrain].
  2: apply PrecollisionTerrainFrameHasWriter;
     now apply Hterrain_writer.
  destruct (classic
    (PlatformMarioPhase terrain_sample platform_sample)) as
    [Hplatform | Hplatform].
  2: apply PrecollisionPlatformRefinementEscapes;
     now apply Hplatform_escape.
  destruct (classic
    (MarioXYZFrame platform_sample collision_sample)) as
    [Hcollision | Hcollision].
  2: apply PrecollisionCollisionFrameHasWriter;
     now apply Hcollision_writer.
  destruct (framed_precollision_state_first_installer_classification
    entry terrain_sample platform_sample collision_sample
    Hterrain Hplatform Hcollision Hentry Hsplit) as
    (next_state & Hafter & Hnext).
  now apply PrecollisionEffectiveStateOnlyApply with
    (next_state := next_state).
Qed.

End PrecollisionStageFailures.

(** * Accepted upper-warp collision-cache provenance

    This is an abstract conditional bridge for a mechanism that does not need
    a State/Object coordinate gap at all: the interaction handler may consume
    a stale, forged, or wrong-owner entry from Mario's collision cache.  The
    observation deliberately records frame, receiver/list, ghost slot/epoch,
    liveness, writer-origin, and overlap-phase data.  Thus the theorem below
    classifies supplied evidence; it does not assume the desired conclusion as
    an input and does not claim that linked retail memory supplies the record. *)

Inductive CollisionCacheWriteOrigin : Type :=
| CollisionCacheDetectorWrite
| CollisionCacheAliasWrite
| CollisionCacheExternalWrite
| CollisionCacheCorruptionWrite
| CollisionCacheUnclassifiedWrite (tag : nat).

Record UpperWarpCollisionCacheObservation : Type := {
  cache_current_frame : nat;
  cache_clear_frame : option nat;
  cache_write_frame : option nat;
  cache_consume_frame : nat;
  cache_expected_receiver : ObjectRef;
  cache_write_receiver : ObjectRef;
  cache_consume_receiver : ObjectRef;
  cache_expected_list : nat;
  cache_write_list : nat;
  cache_consume_list : nat;
  cache_expected_upper_warp : ObjectRef;
  cache_cached_owner : ObjectRef;
  cache_consumed_owner : ObjectRef;
  cache_owner_live_at_write : bool;
  cache_owner_live_at_consume : bool;
  cache_overlap_phase : option CollisionPhase;
  cache_write_origin : CollisionCacheWriteOrigin;
  cache_upper_warp_bit_accepted : bool
}.

(** [cache_expected_list] is a ghost identity for the live Mario collision
    list.  It is intentionally separate from the receiver identity so that a
    correct Mario pointer paired with the wrong list remains visible. *)
Record AcceptedUpperWarpCacheInteraction
    (observation : UpperWarpCollisionCacheObservation) : Prop := {
  accepted_upper_warp_interaction_bit :
    cache_upper_warp_bit_accepted observation = true;
  accepted_upper_warp_interaction_owner :
    cache_consumed_owner observation = cache_expected_upper_warp observation
}.

Inductive CollisionCacheReceiverOrListMismatch
    (observation : UpperWarpCollisionCacheObservation) : Prop :=
| CollisionCacheWriteReceiverMismatch :
    cache_write_receiver observation <>
      cache_expected_receiver observation ->
    CollisionCacheReceiverOrListMismatch observation
| CollisionCacheConsumeReceiverMismatch :
    cache_consume_receiver observation <>
      cache_expected_receiver observation ->
    CollisionCacheReceiverOrListMismatch observation
| CollisionCacheWriteListMismatch :
    cache_write_list observation <> cache_expected_list observation ->
    CollisionCacheReceiverOrListMismatch observation
| CollisionCacheConsumeListMismatch :
    cache_consume_list observation <> cache_expected_list observation ->
    CollisionCacheReceiverOrListMismatch observation.

Inductive CollisionCacheStaleOrWrongOwner
    (observation : UpperWarpCollisionCacheObservation) : Prop :=
| CollisionCacheWriteNotCurrent :
    cache_write_frame observation <>
      Some (cache_current_frame observation) ->
    CollisionCacheStaleOrWrongOwner observation
| CollisionCacheConsumeNotCurrent :
    cache_consume_frame observation <> cache_current_frame observation ->
    CollisionCacheStaleOrWrongOwner observation
| CollisionCacheCachedOwnerWrong :
    cache_cached_owner observation <>
      cache_expected_upper_warp observation ->
    CollisionCacheStaleOrWrongOwner observation
| CollisionCacheOwnerChangedBeforeConsume :
    cache_cached_owner observation <> cache_consumed_owner observation ->
    CollisionCacheStaleOrWrongOwner observation
| CollisionCacheOwnerNotLiveAtWrite :
    cache_owner_live_at_write observation <> true ->
    CollisionCacheStaleOrWrongOwner observation
| CollisionCacheOwnerNotLiveAtConsume :
    cache_owner_live_at_consume observation <> true ->
    CollisionCacheStaleOrWrongOwner observation
| CollisionCacheOverlapMarioWrong : forall phase,
    cache_overlap_phase observation = Some phase ->
    collision_mario_ref phase <> cache_expected_receiver observation ->
    CollisionCacheStaleOrWrongOwner observation
| CollisionCacheOverlapOwnerWrong : forall phase,
    cache_overlap_phase observation = Some phase ->
    collision_target_ref phase <> cache_expected_upper_warp observation ->
    CollisionCacheStaleOrWrongOwner observation.

Record FaithfulSameFrameLiveCollisionCacheProvenance
    (observation : UpperWarpCollisionCacheObservation) : Prop := {
  faithful_cache_acceptance : AcceptedUpperWarpCacheInteraction observation;
  faithful_cache_origin :
    cache_write_origin observation = CollisionCacheDetectorWrite;
  faithful_cache_clear :
    cache_clear_frame observation = Some (cache_current_frame observation);
  faithful_cache_write :
    cache_write_frame observation = Some (cache_current_frame observation);
  faithful_cache_consume :
    cache_consume_frame observation = cache_current_frame observation;
  faithful_cache_write_receiver :
    cache_write_receiver observation = cache_expected_receiver observation;
  faithful_cache_consume_receiver :
    cache_consume_receiver observation = cache_expected_receiver observation;
  faithful_cache_write_list :
    cache_write_list observation = cache_expected_list observation;
  faithful_cache_consume_list :
    cache_consume_list observation = cache_expected_list observation;
  faithful_cache_cached_owner :
    cache_cached_owner observation = cache_expected_upper_warp observation;
  faithful_cache_owner_unchanged :
    cache_cached_owner observation = cache_consumed_owner observation;
  faithful_cache_live_at_write :
    cache_owner_live_at_write observation = true;
  faithful_cache_live_at_consume :
    cache_owner_live_at_consume observation = true;
  faithful_cache_current_phase :
    exists phase,
      cache_overlap_phase observation = Some phase /\
      collision_mario_ref phase = cache_expected_receiver observation /\
      collision_target_ref phase = cache_expected_upper_warp observation /\
      collision_phase_overlap phase
}.

Inductive WarpInteractionCacheProvenanceEscape
    (observation : UpperWarpCollisionCacheObservation) : Prop :=
| WarpCacheMissedClear :
    AcceptedUpperWarpCacheInteraction observation ->
    cache_clear_frame observation <>
      Some (cache_current_frame observation) ->
    WarpInteractionCacheProvenanceEscape observation
| WarpCacheWrongReceiverOrList :
    AcceptedUpperWarpCacheInteraction observation ->
    CollisionCacheReceiverOrListMismatch observation ->
    WarpInteractionCacheProvenanceEscape observation
| WarpCacheStaleOrWrongOwner :
    AcceptedUpperWarpCacheInteraction observation ->
    CollisionCacheStaleOrWrongOwner observation ->
    WarpInteractionCacheProvenanceEscape observation
| WarpCacheAliasEffect :
    AcceptedUpperWarpCacheInteraction observation ->
    cache_write_origin observation = CollisionCacheAliasWrite ->
    WarpInteractionCacheProvenanceEscape observation
| WarpCacheExternalEffect :
    AcceptedUpperWarpCacheInteraction observation ->
    cache_write_origin observation = CollisionCacheExternalWrite ->
    WarpInteractionCacheProvenanceEscape observation
| WarpCacheCorruptionEffect :
    AcceptedUpperWarpCacheInteraction observation ->
    cache_write_origin observation = CollisionCacheCorruptionWrite ->
    WarpInteractionCacheProvenanceEscape observation
| WarpCacheUnclassifiedWriter : forall tag,
    AcceptedUpperWarpCacheInteraction observation ->
    cache_write_origin observation = CollisionCacheUnclassifiedWrite tag ->
    WarpInteractionCacheProvenanceEscape observation
| WarpCacheUnclassifiedMissingPhase :
    AcceptedUpperWarpCacheInteraction observation ->
    cache_overlap_phase observation = None ->
    WarpInteractionCacheProvenanceEscape observation
| WarpCacheUnclassifiedRejectedPhase : forall phase,
    AcceptedUpperWarpCacheInteraction observation ->
    cache_overlap_phase observation = Some phase ->
    ~ collision_phase_overlap phase ->
    WarpInteractionCacheProvenanceEscape observation.

Theorem accepted_upper_warp_interaction_has_faithful_cache_or_escape :
  forall observation,
    AcceptedUpperWarpCacheInteraction observation ->
    FaithfulSameFrameLiveCollisionCacheProvenance observation \/
    WarpInteractionCacheProvenanceEscape observation.
Proof.
  intros observation Haccepted.
  destruct (cache_write_origin observation) as [| | | | tag] eqn:Horigin.
  - destruct (classic (cache_clear_frame observation =
        Some (cache_current_frame observation))) as [Hclear | Hclear].
    2: right; now apply WarpCacheMissedClear.
    destruct (classic (cache_write_receiver observation =
        cache_expected_receiver observation)) as [Hwrite_receiver | Hwrite_receiver].
    2: right; apply WarpCacheWrongReceiverOrList; [exact Haccepted |
         now apply CollisionCacheWriteReceiverMismatch].
    destruct (classic (cache_consume_receiver observation =
        cache_expected_receiver observation)) as [Hconsume_receiver | Hconsume_receiver].
    2: right; apply WarpCacheWrongReceiverOrList; [exact Haccepted |
         now apply CollisionCacheConsumeReceiverMismatch].
    destruct (classic (cache_write_list observation =
        cache_expected_list observation)) as [Hwrite_list | Hwrite_list].
    2: right; apply WarpCacheWrongReceiverOrList; [exact Haccepted |
         now apply CollisionCacheWriteListMismatch].
    destruct (classic (cache_consume_list observation =
        cache_expected_list observation)) as [Hconsume_list | Hconsume_list].
    2: right; apply WarpCacheWrongReceiverOrList; [exact Haccepted |
         now apply CollisionCacheConsumeListMismatch].
    destruct (classic (cache_write_frame observation =
        Some (cache_current_frame observation))) as [Hwrite | Hwrite].
    2: right; apply WarpCacheStaleOrWrongOwner; [exact Haccepted |
         now apply CollisionCacheWriteNotCurrent].
    destruct (classic (cache_consume_frame observation =
        cache_current_frame observation)) as [Hconsume | Hconsume].
    2: right; apply WarpCacheStaleOrWrongOwner; [exact Haccepted |
         now apply CollisionCacheConsumeNotCurrent].
    destruct (classic (cache_cached_owner observation =
        cache_expected_upper_warp observation)) as [Hcached_owner | Hcached_owner].
    2: right; apply WarpCacheStaleOrWrongOwner; [exact Haccepted |
         now apply CollisionCacheCachedOwnerWrong].
    destruct (classic (cache_cached_owner observation =
        cache_consumed_owner observation)) as [Howner_unchanged | Howner_unchanged].
    2: right; apply WarpCacheStaleOrWrongOwner; [exact Haccepted |
         now apply CollisionCacheOwnerChangedBeforeConsume].
    destruct (classic (cache_owner_live_at_write observation = true)) as
      [Hlive_write | Hlive_write].
    2: right; apply WarpCacheStaleOrWrongOwner; [exact Haccepted |
         now apply CollisionCacheOwnerNotLiveAtWrite].
    destruct (classic (cache_owner_live_at_consume observation = true)) as
      [Hlive_consume | Hlive_consume].
    2: right; apply WarpCacheStaleOrWrongOwner; [exact Haccepted |
         now apply CollisionCacheOwnerNotLiveAtConsume].
    destruct (cache_overlap_phase observation) as [phase |] eqn:Hphase.
    2: right; now apply WarpCacheUnclassifiedMissingPhase.
    destruct (classic (collision_mario_ref phase =
        cache_expected_receiver observation)) as [Hmario | Hmario].
    2: right; apply WarpCacheStaleOrWrongOwner; [exact Haccepted |
         now apply CollisionCacheOverlapMarioWrong with (phase := phase)].
    destruct (classic (collision_target_ref phase =
        cache_expected_upper_warp observation)) as [Htarget | Htarget].
    2: right; apply WarpCacheStaleOrWrongOwner; [exact Haccepted |
         now apply CollisionCacheOverlapOwnerWrong with (phase := phase)].
    destruct (classic (collision_phase_overlap phase)) as [Hoverlap | Hoverlap].
    2: right; now apply WarpCacheUnclassifiedRejectedPhase with (phase := phase).
    left. refine
      {| faithful_cache_acceptance := Haccepted;
         faithful_cache_origin := Horigin;
         faithful_cache_clear := Hclear;
         faithful_cache_write := Hwrite;
         faithful_cache_consume := Hconsume;
         faithful_cache_write_receiver := Hwrite_receiver;
         faithful_cache_consume_receiver := Hconsume_receiver;
         faithful_cache_write_list := Hwrite_list;
         faithful_cache_consume_list := Hconsume_list;
         faithful_cache_cached_owner := Hcached_owner;
         faithful_cache_owner_unchanged := Howner_unchanged;
         faithful_cache_live_at_write := Hlive_write;
         faithful_cache_live_at_consume := Hlive_consume;
         faithful_cache_current_phase := _ |}.
    exists phase. split; [exact Hphase |].
    split; [exact Hmario |].
    split; [exact Htarget | exact Hoverlap].
  - right. now apply WarpCacheAliasEffect.
  - right. now apply WarpCacheExternalEffect.
  - right. now apply WarpCacheCorruptionEffect.
  - right. now apply WarpCacheUnclassifiedWriter with (tag := tag).
Qed.

Definition Area1WarpInteractionCacheCoverageCheckedBoundary : Prop :=
  forall observation,
    AcceptedUpperWarpCacheInteraction observation ->
    FaithfulSameFrameLiveCollisionCacheProvenance observation \/
    WarpInteractionCacheProvenanceEscape observation.

Theorem area1_warp_interaction_cache_coverage_checked_boundary_holds :
  Area1WarpInteractionCacheCoverageCheckedBoundary.
Proof.
  exact accepted_upper_warp_interaction_has_faithful_cache_or_escape.
Qed.

(** Assumption-audit target: value-level first divergence and persistence,
    query-sample expansion, and the data-bearing pre-collision stage
    classification. *)
Definition Area1GapApproachCoverageCheckedBoundary : Prop :=
  (forall (Coordinate : Type) (before after : @StateObjectViews Coordinate),
    state_object_synchronized before ->
    state_object_split after ->
    GapCreationShape before after) /\
  (forall (Coordinate : Type) (before after : @StateObjectViews Coordinate),
    state_object_split before ->
    state_object_split after ->
    GapPersistenceShape before after) /\
  (forall projection source owner skipped,
    projected_final_lineage projection =
      PlatformLineageFinalQuery source owner skipped ->
    source <> projected_collision_position projection ->
    CompletedQueryScheduleBridge projection source ->
    CompletedQueryDifferentSampleApproach projection source).

Theorem area1_gap_approach_coverage_checked_boundary_holds :
  Area1GapApproachCoverageCheckedBoundary.
Proof.
  split.
  - exact @synchronized_to_split_has_one_of_three_creation_shapes.
  - split.
    + exact @split_to_split_has_one_of_four_persistence_shapes.
    + exact completed_query_different_sample_expands_to_seven_approaches.
Qed.
