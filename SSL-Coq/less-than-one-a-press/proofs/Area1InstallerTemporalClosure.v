(** Temporal closure for the stock Area-1 platform-installer model.

    The older [StockArea1PreapplyPlatform] relation is intentionally local to
    one sample.  A retained pointer, however, was written at an earlier floor
    query, so using that relation alone can accidentally identify the old
    query position with the current collision Object position.

    This file keeps those samples separate by modeling complete scheduler
    boundaries.  An active frame may move Mario arbitrarily, but its final
    platform query writes the pointer associated with the new Object sample.
    A query-skipping/frozen frame preserves both the Object sample and the
    pointer.  US spawn clears the pointer, while a JP retained entry starts at
    one of the checked inbound positions.

    The resulting induction proves that no finite composition of those stock
    shapes can arrive at the upper-warp collision sample with a non-null
    platform pointer.  Thus stock platform displacement cannot install the
    local-Object/nonlocal-State candidate.  The live linked-execution
    projection, alias/external stores, post-query Object writers, moving skip
    frames, and non-stock/relocated/cloned owners remain explicit escape
    classes rather than being assumed away. *)

From Coq Require Import List.
From LessThanOneAPress.Proofs Require Import
  Area1PlatformExhaustiveness GameTypes PyramidTopPU.

Import ListNotations.

Record Area1PrecollisionSnapshot : Type := {
  precollision_object_position : PositionZ;
  precollision_platform_owner : option Area1SurfaceOwnerKind
}.

Definition stock_precollision_snapshot_safe
    (snapshot : Area1PrecollisionSnapshot) : Prop :=
  upper_warp_contact (precollision_object_position snapshot) ->
  precollision_platform_owner snapshot = None.

(** These are scheduler-boundary transitions, not arbitrary C statements.
    In particular, [StockSchedulerCompletedFinalQuery] represents the next
    pre-apply boundary after an active frame has completed its final query.
    The new position need not equal the old one. *)
Inductive StockArea1SchedulerBoundaryStep :
    Area1PrecollisionSnapshot -> Area1PrecollisionSnapshot -> Prop :=
| StockSchedulerCompletedFinalQuery :
    forall before next_position next_platform,
      stock_area1_final_platform_query next_position next_platform ->
      StockArea1SchedulerBoundaryStep before
        {| precollision_object_position := next_position;
           precollision_platform_owner := next_platform |}
| StockSchedulerFrozenCarry :
    forall snapshot,
      StockArea1SchedulerBoundaryStep snapshot snapshot
| StockSchedulerUSSpawnClear :
    forall before entry_position,
      StockArea1SchedulerBoundaryStep before
        {| precollision_object_position := entry_position;
           precollision_platform_owner := None |}
| StockSchedulerJPInboundRetention :
    forall before node retained,
      StockArea1SchedulerBoundaryStep before
        {| precollision_object_position := area1_inbound_position node;
           precollision_platform_owner := retained |}.

Theorem stock_scheduler_boundary_step_preserves_upper_warp_null :
  forall before after,
    stock_precollision_snapshot_safe before ->
    StockArea1SchedulerBoundaryStep before after ->
    stock_precollision_snapshot_safe after.
Proof.
  intros before after Hsafe Hstep.
  destruct Hstep as
    [before next_position next_platform Hquery
    |snapshot
    |before entry_position
    |before node retained].
  - intros Hwarp.
    eapply stock_upper_warp_final_query_clears_platform; eauto.
  - exact Hsafe.
  - intros _. reflexivity.
  - intros Hwarp.
    exfalso.
    eapply no_stock_area1_inbound_node_overlaps_upper_warp; eauto.
Qed.

Inductive StockArea1SchedulerBoundaryTrace :
    Area1PrecollisionSnapshot -> Area1PrecollisionSnapshot -> Prop :=
| StockSchedulerTraceNil :
    forall snapshot,
      StockArea1SchedulerBoundaryTrace snapshot snapshot
| StockSchedulerTraceCons :
    forall before middle after,
      StockArea1SchedulerBoundaryStep before middle ->
      StockArea1SchedulerBoundaryTrace middle after ->
      StockArea1SchedulerBoundaryTrace before after.

Theorem stock_scheduler_boundary_trace_preserves_upper_warp_null :
  forall before after,
    stock_precollision_snapshot_safe before ->
    StockArea1SchedulerBoundaryTrace before after ->
    stock_precollision_snapshot_safe after.
Proof.
  intros before after Hsafe Htrace.
  induction Htrace as
    [snapshot
    |before middle after Hstep Htail IH].
  - exact Hsafe.
  - apply IH.
    eapply stock_scheduler_boundary_step_preserves_upper_warp_null; eauto.
Qed.

(** A source-bounded entry may begin with a null pointer, with the result of a
    completed stock query, or with the JP pointer retained at a checked inbound
    node.  This is an abstract seed classification; deriving it from clean
    linked memory remains open. *)
Inductive StockArea1InstallerSeed : Area1PrecollisionSnapshot -> Prop :=
| StockInstallerSeedNull :
    forall position,
      StockArea1InstallerSeed
        {| precollision_object_position := position;
           precollision_platform_owner := None |}
| StockInstallerSeedCompletedQuery :
    forall position platform,
      stock_area1_final_platform_query position platform ->
      StockArea1InstallerSeed
        {| precollision_object_position := position;
           precollision_platform_owner := platform |}
| StockInstallerSeedJPInboundRetention :
    forall node retained,
      StockArea1InstallerSeed
        {| precollision_object_position := area1_inbound_position node;
           precollision_platform_owner := retained |}.

Theorem stock_area1_installer_seed_is_upper_warp_null :
  forall snapshot,
    StockArea1InstallerSeed snapshot ->
    stock_precollision_snapshot_safe snapshot.
Proof.
  intros snapshot Hseed.
  destruct Hseed as
    [position
    |position platform Hquery
    |node retained].
  - intros _. reflexivity.
  - intros Hwarp.
    eapply stock_upper_warp_final_query_clears_platform; eauto.
  - intros Hwarp.
    exfalso.
    eapply no_stock_area1_inbound_node_overlaps_upper_warp; eauto.
Qed.

Record StockTemporalPlatformInstallerAttempt : Type := {
  temporal_installer_start : Area1PrecollisionSnapshot;
  temporal_installer_preapply : Area1PrecollisionSnapshot;
  temporal_installer_seed :
    StockArea1InstallerSeed temporal_installer_start;
  temporal_installer_trace :
    StockArea1SchedulerBoundaryTrace
      temporal_installer_start temporal_installer_preapply;
  temporal_installer_object_hits_upper_warp :
    upper_warp_contact
      (precollision_object_position temporal_installer_preapply);
  temporal_installer_platform_is_nonnull :
    precollision_platform_owner temporal_installer_preapply <> None
}.

(** This is the useful new exclusion: it permits the query sample to move
    between active frames and permits arbitrarily many frozen carries.  It
    does not rely on the old same-position pre-apply relation. *)
Theorem no_stock_temporal_platform_installer :
  StockTemporalPlatformInstallerAttempt -> False.
Proof.
  intros attempt.
  pose proof
    (stock_area1_installer_seed_is_upper_warp_null
      (temporal_installer_start attempt)
      (temporal_installer_seed attempt)) as Hseed_safe.
  pose proof
    (stock_scheduler_boundary_trace_preserves_upper_warp_null
      (temporal_installer_start attempt)
      (temporal_installer_preapply attempt)
      Hseed_safe
      (temporal_installer_trace attempt)) as Hfinal_safe.
  apply (temporal_installer_platform_is_nonnull attempt).
  apply Hfinal_safe.
  exact (temporal_installer_object_hits_upper_warp attempt).
Qed.

(** A linked run can escape the preceding induction only through a property
    that is deliberately absent from the stock transition constructors. *)
Inductive Area1InstallerProjectionEscape : Type :=
| EscapePlatformGlobalAliasOrExternalStore
| EscapeFinalQueryOwnerOrSurfaceProjection
| EscapePostQueryObjectCoordinateWriter
| EscapeSkippedQueryCoordinateWriter
| EscapeRetainedEntryOutsideCheckedInboundNodes
| EscapeUnclassifiedSchedulerShape.

(** The concrete remaining bridge.  A future linked proof must show that the
    clean entry projects to [StockArea1InstallerSeed] and that every boundary
    transition either refines [StockArea1SchedulerBoundaryStep] or produces
    one of the six named escape cases above.  It must then eliminate an
    observed escape or carry it into a concrete installer trace.  This
    definition is not used as an assumption by any theorem in this file. *)
Definition LinkedArea1InstallerTemporalProjectionObligation
    (linked_boundary_state : Type)
    (linked_clean_entry : linked_boundary_state -> Prop)
    (linked_boundary_step :
      linked_boundary_state -> linked_boundary_state -> Prop)
    (project_snapshot :
      linked_boundary_state -> option Area1PrecollisionSnapshot)
    (projects_escape :
      Area1InstallerProjectionEscape ->
      linked_boundary_state -> linked_boundary_state -> Prop) : Prop :=
  (exists state snapshot,
    linked_clean_entry state /\
    project_snapshot state = Some snapshot) /\
  (forall state,
    linked_clean_entry state ->
    exists snapshot,
      project_snapshot state = Some snapshot /\
      StockArea1InstallerSeed snapshot) /\
  (forall before_state after_state,
    linked_boundary_step before_state after_state ->
    exists before after,
      project_snapshot before_state = Some before /\
      project_snapshot after_state = Some after /\
      (StockArea1SchedulerBoundaryStep before after \/
       exists escape,
         projects_escape escape before_state after_state)).

Definition Area1InstallerTemporalCheckedBoundary : Prop :=
  (forall before after,
    stock_precollision_snapshot_safe before ->
    StockArea1SchedulerBoundaryTrace before after ->
    stock_precollision_snapshot_safe after) /\
  (StockTemporalPlatformInstallerAttempt -> False).

Theorem area1_installer_temporal_checked_boundary_holds :
  Area1InstallerTemporalCheckedBoundary.
Proof.
  split.
  - exact stock_scheduler_boundary_trace_preserves_upper_warp_null.
  - exact no_stock_temporal_platform_installer.
Qed.
