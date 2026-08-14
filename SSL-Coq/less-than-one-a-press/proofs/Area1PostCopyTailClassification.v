(**
  A bounded abstract classification of caller-supplied snapshots intended to
  represent a frame tail after Mario's State-to-Object copy.  The formal trace
  below carries no Clight adjacency relation or phase marker; a future linked
  projection must supply those semantics.

  [Area1PolePushSchedule] shows why a State-only writer before the player
  callback is insufficient: a successful [copy_mario_state_to_object]
  resynchronizes the two coordinate views.  This file states the next proof
  target as a value taxonomy.  Starting from a supplied copy observation and a supplied
  tail trace, either:

    - the copy is faithful and every tail edge preserves values, bindings,
      allocation epochs, liveness, and the absence of a residual effect; or
    - the observation exposes a classified residual: a State-only, Object-only,
      or joint projected-value change; skipped/misdirected copy; MarioState/gMarioObject
      retarget; lifecycle/unload/reuse change; alias or external effect; or a
      scheduler/unclassified effect.

  The model is intentionally generic in coordinate and endpoint-reference
  types.  Effect tags and snapshots are evidence supplied by a future linked
  execution projection.  No theorem here claims that retail Clight constructs
  any escape, or that the supplied trace corresponds to SSL Area 1.
*)

From Coq Require Import Classical_Prop List.
From LessThanOneAPress.Proofs Require Import Area1GapApproachCoverage.

Section PostCopyTailClassification.

Context {Coordinate EndpointRef : Type}.

Record PostCopyTailSnapshot : Type := {
  postcopy_tail_views : @StateObjectViews Coordinate;
  postcopy_tail_state_target : EndpointRef;
  postcopy_tail_object_target : EndpointRef;
  postcopy_tail_state_epoch : nat;
  postcopy_tail_object_epoch : nat;
  postcopy_tail_state_live : bool;
  postcopy_tail_object_live : bool
}.

(** A call/return observation is weaker than a faithful copy: the source and
    destination can be retargeted, the transfer can be skipped, or lifecycle
    changes can invalidate the projected endpoints. *)
Record StateToObjectCopyObservation : Type := {
  copy_snapshot_before : PostCopyTailSnapshot;
  copy_snapshot_after : PostCopyTailSnapshot;
  copy_expected_state_target : EndpointRef;
  copy_expected_object_target : EndpointRef;
  copy_actual_state_target : EndpointRef;
  copy_actual_object_target : EndpointRef;
  copy_call_entered : bool;
  copy_call_returned : bool
}.

Definition copy_control_completed
    (observation : StateToObjectCopyObservation) : Prop :=
  copy_call_entered observation = true /\
  copy_call_returned observation = true.

Definition copy_targets_are_expected
    (observation : StateToObjectCopyObservation) : Prop :=
  copy_actual_state_target observation =
      copy_expected_state_target observation /\
  copy_actual_object_target observation =
      copy_expected_object_target observation /\
  postcopy_tail_state_target (copy_snapshot_before observation) =
      copy_expected_state_target observation /\
  postcopy_tail_object_target (copy_snapshot_before observation) =
      copy_expected_object_target observation /\
  postcopy_tail_state_target (copy_snapshot_after observation) =
      copy_expected_state_target observation /\
  postcopy_tail_object_target (copy_snapshot_after observation) =
      copy_expected_object_target observation.

Definition copy_values_are_faithful
    (observation : StateToObjectCopyObservation) : Prop :=
  gap_state_view
      (postcopy_tail_views (copy_snapshot_after observation)) =
    gap_state_view
      (postcopy_tail_views (copy_snapshot_before observation)) /\
  gap_object_view
      (postcopy_tail_views (copy_snapshot_after observation)) =
    gap_state_view
      (postcopy_tail_views (copy_snapshot_before observation)).

Definition copy_lifecycle_is_stable
    (observation : StateToObjectCopyObservation) : Prop :=
  postcopy_tail_state_epoch (copy_snapshot_after observation) =
      postcopy_tail_state_epoch (copy_snapshot_before observation) /\
  postcopy_tail_object_epoch (copy_snapshot_after observation) =
      postcopy_tail_object_epoch (copy_snapshot_before observation) /\
  postcopy_tail_state_live (copy_snapshot_before observation) = true /\
  postcopy_tail_object_live (copy_snapshot_before observation) = true /\
  postcopy_tail_state_live (copy_snapshot_after observation) = true /\
  postcopy_tail_object_live (copy_snapshot_after observation) = true.

Record FaithfulSuccessfulStateToObjectCopy
    (observation : StateToObjectCopyObservation) : Prop := {
  faithful_copy_control : copy_control_completed observation;
  faithful_copy_targets : copy_targets_are_expected observation;
  faithful_copy_values : copy_values_are_faithful observation;
  faithful_copy_lifecycle : copy_lifecycle_is_stable observation
}.

(** These four constructors are one user-facing escape family: the projected
    State-to-Object copy was skipped, did not return, was directed at the
    wrong endpoints, did not transfer the expected value, or crossed a
    lifecycle discontinuity. *)
Inductive StateToObjectCopyBoundaryEscape
    (observation : StateToObjectCopyObservation) : Prop :=
| CopyCallSkippedOrDidNotReturn :
    ~ copy_control_completed observation ->
    StateToObjectCopyBoundaryEscape observation
| CopyEndpointMisdirected :
    copy_control_completed observation ->
    ~ copy_targets_are_expected observation ->
    StateToObjectCopyBoundaryEscape observation
| CopyTransferMisdirected :
    copy_control_completed observation ->
    copy_targets_are_expected observation ->
    ~ copy_values_are_faithful observation ->
    StateToObjectCopyBoundaryEscape observation
| CopyCrossedLifecycleDiscontinuity :
    copy_control_completed observation ->
    copy_targets_are_expected observation ->
    copy_values_are_faithful observation ->
    ~ copy_lifecycle_is_stable observation ->
    StateToObjectCopyBoundaryEscape observation.

Theorem supplied_copy_is_faithful_or_skipped_misdirected :
  forall observation,
    FaithfulSuccessfulStateToObjectCopy observation \/
    StateToObjectCopyBoundaryEscape observation.
Proof.
  intro observation.
  destruct (classic (copy_control_completed observation)) as
    [Hcontrol | Hcontrol].
  2: right; now apply CopyCallSkippedOrDidNotReturn.
  destruct (classic (copy_targets_are_expected observation)) as
    [Htargets | Htargets].
  2: right; now apply CopyEndpointMisdirected.
  destruct (classic (copy_values_are_faithful observation)) as
    [Hvalues | Hvalues].
  2: right; now apply CopyTransferMisdirected.
  destruct (classic (copy_lifecycle_is_stable observation)) as
    [Hlifecycle | Hlifecycle].
  - left. constructor; assumption.
  - right. now apply CopyCrossedLifecycleDiscontinuity.
Qed.

Lemma faithful_copy_establishes_synchronization :
  forall observation,
    FaithfulSuccessfulStateToObjectCopy observation ->
    state_object_synchronized
      (postcopy_tail_views (copy_snapshot_after observation)).
Proof.
  intros observation Hcopy.
  destruct (faithful_copy_values observation Hcopy) as
    [Hstate Hobject].
  unfold state_object_synchronized.
  rewrite Hstate, Hobject. reflexivity.
Qed.

(** * Tail edges *)

Inductive FrameTailResidualOrigin : Type :=
| FrameTailNoResidualEffect
| FrameTailAliasEffect (site : nat)
| FrameTailExternalEffect (symbol : nat)
| FrameTailSchedulerEffect (phase : nat)
| FrameTailUnclassifiedEffect (tag : nat).

Definition tail_state_value_unchanged
    (before after : PostCopyTailSnapshot) : Prop :=
  gap_state_view (postcopy_tail_views after) =
    gap_state_view (postcopy_tail_views before).

Definition tail_object_value_unchanged
    (before after : PostCopyTailSnapshot) : Prop :=
  gap_object_view (postcopy_tail_views after) =
    gap_object_view (postcopy_tail_views before).

Definition tail_targets_unchanged
    (before after : PostCopyTailSnapshot) : Prop :=
  postcopy_tail_state_target after = postcopy_tail_state_target before /\
  postcopy_tail_object_target after = postcopy_tail_object_target before.

Definition tail_lifecycle_unchanged
    (before after : PostCopyTailSnapshot) : Prop :=
  postcopy_tail_state_epoch after = postcopy_tail_state_epoch before /\
  postcopy_tail_object_epoch after = postcopy_tail_object_epoch before /\
  postcopy_tail_state_live after = postcopy_tail_state_live before /\
  postcopy_tail_object_live after = postcopy_tail_object_live before.

Record FrameTailStepPreservesSynchronization
    (origin : FrameTailResidualOrigin)
    (before after : PostCopyTailSnapshot) : Prop := {
  preserving_tail_state_value : tail_state_value_unchanged before after;
  preserving_tail_object_value : tail_object_value_unchanged before after;
  preserving_tail_targets : tail_targets_unchanged before after;
  preserving_tail_lifecycle : tail_lifecycle_unchanged before after;
  preserving_tail_has_no_residual_effect :
    origin = FrameTailNoResidualEffect
}.

Inductive EndpointRetargetShape
    (before after : PostCopyTailSnapshot) : Prop :=
| MarioStateEndpointRetargeted :
    postcopy_tail_state_target after <>
      postcopy_tail_state_target before ->
    EndpointRetargetShape before after
| MarioObjectEndpointRetargeted :
    postcopy_tail_object_target after <>
      postcopy_tail_object_target before ->
    EndpointRetargetShape before after.

Lemma changed_tail_targets_have_retarget_shape :
  forall before after,
    ~ tail_targets_unchanged before after ->
    EndpointRetargetShape before after.
Proof.
  intros before after Hchanged.
  destruct (classic (postcopy_tail_state_target after =
      postcopy_tail_state_target before)) as [Hstate | Hstate].
  - apply MarioObjectEndpointRetargeted. intro Hobject.
    apply Hchanged. now split.
  - now apply MarioStateEndpointRetargeted.
Qed.

Inductive LifecycleUnloadReuseShape
    (before after : PostCopyTailSnapshot) : Prop :=
| MarioStateEpochChanged :
    postcopy_tail_state_epoch after <>
      postcopy_tail_state_epoch before ->
    LifecycleUnloadReuseShape before after
| MarioObjectEpochChanged :
    postcopy_tail_object_epoch after <>
      postcopy_tail_object_epoch before ->
    LifecycleUnloadReuseShape before after
| MarioStateLivenessChanged :
    postcopy_tail_state_live after <>
      postcopy_tail_state_live before ->
    LifecycleUnloadReuseShape before after
| MarioObjectLivenessChanged :
    postcopy_tail_object_live after <>
      postcopy_tail_object_live before ->
    LifecycleUnloadReuseShape before after.

Lemma changed_tail_lifecycle_has_unload_reuse_shape :
  forall before after,
    ~ tail_lifecycle_unchanged before after ->
    LifecycleUnloadReuseShape before after.
Proof.
  intros before after Hchanged.
  destruct (classic (postcopy_tail_state_epoch after =
      postcopy_tail_state_epoch before)) as [Hstate_epoch | Hstate_epoch].
  2: now apply MarioStateEpochChanged.
  destruct (classic (postcopy_tail_object_epoch after =
      postcopy_tail_object_epoch before)) as [Hobject_epoch | Hobject_epoch].
  2: now apply MarioObjectEpochChanged.
  destruct (classic (postcopy_tail_state_live after =
      postcopy_tail_state_live before)) as [Hstate_live | Hstate_live].
  2: now apply MarioStateLivenessChanged.
  apply MarioObjectLivenessChanged. intro Hobject_live.
  apply Hchanged. repeat split; assumption.
Qed.

(** The value-change constructors retain the actual before/after snapshots and
    the supplied origin, but do not prove what caused the change.  A future
    linked projection must identify the concrete store or other semantic
    event.  Retarget and lifecycle constructors are reached only
    when both projected coordinate values are unchanged, keeping categories
    non-overlapping under the theorem's priority order. *)
Inductive PostCopyFrameTailEscape
    (origin : FrameTailResidualOrigin)
    (before after : PostCopyTailSnapshot) : Prop :=
| PostCopyStateOnlyValueChange :
    ~ tail_state_value_unchanged before after ->
    tail_object_value_unchanged before after ->
    PostCopyFrameTailEscape origin before after
| PostCopyObjectOnlyValueChange :
    tail_state_value_unchanged before after ->
    ~ tail_object_value_unchanged before after ->
    PostCopyFrameTailEscape origin before after
| PostCopyJointValueChange :
    ~ tail_state_value_unchanged before after ->
    ~ tail_object_value_unchanged before after ->
    PostCopyFrameTailEscape origin before after
| PostCopyMarioEndpointRetarget :
    tail_state_value_unchanged before after ->
    tail_object_value_unchanged before after ->
    EndpointRetargetShape before after ->
    PostCopyFrameTailEscape origin before after
| PostCopyLifecycleUnloadOrReuse :
    tail_state_value_unchanged before after ->
    tail_object_value_unchanged before after ->
    tail_targets_unchanged before after ->
    LifecycleUnloadReuseShape before after ->
    PostCopyFrameTailEscape origin before after
| PostCopyAliasOrForgedEffect : forall site,
    tail_state_value_unchanged before after ->
    tail_object_value_unchanged before after ->
    tail_targets_unchanged before after ->
    tail_lifecycle_unchanged before after ->
    origin = FrameTailAliasEffect site ->
    PostCopyFrameTailEscape origin before after
| PostCopyExternalEffect : forall symbol,
    tail_state_value_unchanged before after ->
    tail_object_value_unchanged before after ->
    tail_targets_unchanged before after ->
    tail_lifecycle_unchanged before after ->
    origin = FrameTailExternalEffect symbol ->
    PostCopyFrameTailEscape origin before after
| PostCopySchedulerEscape : forall phase,
    tail_state_value_unchanged before after ->
    tail_object_value_unchanged before after ->
    tail_targets_unchanged before after ->
    tail_lifecycle_unchanged before after ->
    origin = FrameTailSchedulerEffect phase ->
    PostCopyFrameTailEscape origin before after
| PostCopyUnclassifiedEscape : forall tag,
    tail_state_value_unchanged before after ->
    tail_object_value_unchanged before after ->
    tail_targets_unchanged before after ->
    tail_lifecycle_unchanged before after ->
    origin = FrameTailUnclassifiedEffect tag ->
    PostCopyFrameTailEscape origin before after.

Theorem supplied_tail_step_preserves_or_exposes_escape :
  forall origin before after,
    FrameTailStepPreservesSynchronization origin before after \/
    PostCopyFrameTailEscape origin before after.
Proof.
  intros origin before after.
  destruct (classic (tail_state_value_unchanged before after)) as
    [Hstate | Hstate];
  destruct (classic (tail_object_value_unchanged before after)) as
    [Hobject | Hobject].
  2: right; now apply PostCopyObjectOnlyValueChange.
  2: right; now apply PostCopyStateOnlyValueChange.
  2: right; now apply PostCopyJointValueChange.
  destruct (classic (tail_targets_unchanged before after)) as
    [Htargets | Htargets].
  2: right; apply PostCopyMarioEndpointRetarget; try assumption;
     now apply changed_tail_targets_have_retarget_shape.
  destruct (classic (tail_lifecycle_unchanged before after)) as
    [Hlifecycle | Hlifecycle].
  2: right; apply PostCopyLifecycleUnloadOrReuse; try assumption;
     now apply changed_tail_lifecycle_has_unload_reuse_shape.
  destruct origin as [| site | symbol | phase | tag].
  - left. constructor; try assumption; reflexivity.
  - right. now apply PostCopyAliasOrForgedEffect with (site := site).
  - right. now apply PostCopyExternalEffect with (symbol := symbol).
  - right. now apply PostCopySchedulerEscape with (phase := phase).
  - right. now apply PostCopyUnclassifiedEscape with (tag := tag).
Qed.

(** * Supplied frame-tail traces and first escape *)

Inductive SuppliedPostCopyFrameTail :
    PostCopyTailSnapshot -> PostCopyTailSnapshot -> Type :=
| SuppliedFrameTailNil : forall snapshot,
    SuppliedPostCopyFrameTail snapshot snapshot
| SuppliedFrameTailCons : forall before middle finish
    (origin : FrameTailResidualOrigin),
    SuppliedPostCopyFrameTail middle finish ->
    SuppliedPostCopyFrameTail before finish.

Inductive SynchronizationPreservingFrameTail :
    PostCopyTailSnapshot -> PostCopyTailSnapshot -> Prop :=
| PreservingFrameTailNil : forall snapshot,
    SynchronizationPreservingFrameTail snapshot snapshot
| PreservingFrameTailCons : forall before middle finish origin,
    FrameTailStepPreservesSynchronization origin before middle ->
    SynchronizationPreservingFrameTail middle finish ->
    SynchronizationPreservingFrameTail before finish.

Inductive FrameTailContainsClassifiedResidual :
    PostCopyTailSnapshot -> PostCopyTailSnapshot -> Prop :=
| FrameTailResidualHere : forall before middle finish origin,
    PostCopyFrameTailEscape origin before middle ->
    SuppliedPostCopyFrameTail middle finish ->
    FrameTailContainsClassifiedResidual before finish
| FrameTailResidualLater : forall before middle finish origin,
    FrameTailStepPreservesSynchronization origin before middle ->
    FrameTailContainsClassifiedResidual middle finish ->
    FrameTailContainsClassifiedResidual before finish.

Theorem supplied_frame_tail_is_preserving_or_contains_classified_residual :
  forall start finish,
    SuppliedPostCopyFrameTail start finish ->
    SynchronizationPreservingFrameTail start finish \/
    FrameTailContainsClassifiedResidual start finish.
Proof.
  intros start finish Htail.
  induction Htail as
    [snapshot | before middle finish origin Htail IH].
  - left. apply PreservingFrameTailNil.
  - destruct (supplied_tail_step_preserves_or_exposes_escape
      origin before middle) as [Hpreserve | Hescape].
    + destruct IH as [Hrest | Hrest].
      * left. now apply PreservingFrameTailCons with
          (middle := middle) (origin := origin).
      * right. now apply FrameTailResidualLater with
          (middle := middle) (origin := origin).
    + right. now apply FrameTailResidualHere with
        (middle := middle) (origin := origin).
Qed.

(** Unlike the broad residual relation above, this edge relation records an
    actual coordinate-value change.  Retarget, lifecycle, alias, external,
    scheduler, and unclassified tags do not inhabit it when both projected
    values are unchanged. *)
Inductive PostCopyValueChangingEdge
    (origin : FrameTailResidualOrigin)
    (before after : PostCopyTailSnapshot) : Prop :=
| PostCopyStateOnlyValueChangingEdge :
    ~ tail_state_value_unchanged before after ->
    tail_object_value_unchanged before after ->
    PostCopyValueChangingEdge origin before after
| PostCopyObjectOnlyValueChangingEdge :
    tail_state_value_unchanged before after ->
    ~ tail_object_value_unchanged before after ->
    PostCopyValueChangingEdge origin before after
| PostCopyJointValueChangingEdge :
    ~ tail_state_value_unchanged before after ->
    ~ tail_object_value_unchanged before after ->
    PostCopyValueChangingEdge origin before after.

Inductive FrameTailContainsValueChangingEdge :
    PostCopyTailSnapshot -> PostCopyTailSnapshot -> Prop :=
| FrameTailValueChangingEdgeHere : forall before middle finish origin,
    PostCopyValueChangingEdge origin before middle ->
    SuppliedPostCopyFrameTail middle finish ->
    FrameTailContainsValueChangingEdge before finish
| FrameTailValueChangingEdgeLater : forall before middle finish,
    tail_state_value_unchanged before middle ->
    tail_object_value_unchanged before middle ->
    FrameTailContainsValueChangingEdge middle finish ->
    FrameTailContainsValueChangingEdge before finish.

(** This theorem scans through arbitrary value-preserving residuals.  It does
    not need them to be fully preserving steps: a retarget, lifecycle event,
    or alias/external/scheduler tag is skipped exactly when both projected
    coordinate values stay unchanged. *)
Theorem synchronized_tail_ending_split_contains_value_changing_edge :
  forall start finish,
    SuppliedPostCopyFrameTail start finish ->
    state_object_synchronized (postcopy_tail_views start) ->
    state_object_split (postcopy_tail_views finish) ->
    FrameTailContainsValueChangingEdge start finish.
Proof.
  intros start finish Htail.
  induction Htail as
    [snapshot | before middle finish origin Htail IH];
    intros Hsync Hsplit.
  - exfalso. now apply Hsplit.
  - destruct (classic (tail_state_value_unchanged before middle)) as
      [Hstate | Hstate];
    destruct (classic (tail_object_value_unchanged before middle)) as
      [Hobject | Hobject].
    + apply FrameTailValueChangingEdgeLater with
      (middle := middle); try assumption.
      apply IH; [| exact Hsplit].
      unfold state_object_synchronized,
        tail_state_value_unchanged, tail_object_value_unchanged in *.
      rewrite Hstate, Hobject. exact Hsync.
    + apply FrameTailValueChangingEdgeHere with
        (middle := middle) (origin := origin).
      * now apply PostCopyObjectOnlyValueChangingEdge.
      * exact Htail.
    + apply FrameTailValueChangingEdgeHere with
        (middle := middle) (origin := origin).
      * now apply PostCopyStateOnlyValueChangingEdge.
      * exact Htail.
    + apply FrameTailValueChangingEdgeHere with
        (middle := middle) (origin := origin).
      * now apply PostCopyJointValueChangingEdge.
      * exact Htail.
Qed.

Theorem preserving_frame_tail_preserves_synchronization :
  forall start finish,
    SynchronizationPreservingFrameTail start finish ->
    state_object_synchronized (postcopy_tail_views start) ->
    state_object_synchronized (postcopy_tail_views finish).
Proof.
  intros start finish Htail.
  induction Htail as
    [snapshot | before middle finish origin Hstep Htail IH];
    intro Hsync.
  - exact Hsync.
  - apply IH.
    destruct Hstep as [Hstate Hobject _ _ _].
    unfold state_object_synchronized,
      tail_state_value_unchanged, tail_object_value_unchanged in *.
    rewrite Hstate, Hobject. exact Hsync.
Qed.

(** * Copy-to-next-precollision capstones *)

Record SynchronizedCopyToPrecollisionPreservation
    (observation : StateToObjectCopyObservation)
    (finish : PostCopyTailSnapshot) : Prop := {
  synchronized_tail_copy_is_faithful :
    FaithfulSuccessfulStateToObjectCopy observation;
  synchronized_tail_edges_preserve :
    SynchronizationPreservingFrameTail
      (copy_snapshot_after observation) finish;
  synchronized_tail_finish_is_synchronized :
    state_object_synchronized (postcopy_tail_views finish)
}.

Inductive CopyToPrecollisionClassifiedResidual
    (observation : StateToObjectCopyObservation)
    (finish : PostCopyTailSnapshot) : Prop :=
| CopyToPrecollisionCopyBoundaryResidual :
    StateToObjectCopyBoundaryEscape observation ->
    CopyToPrecollisionClassifiedResidual observation finish
| CopyToPrecollisionFrameTailResidual :
    FrameTailContainsClassifiedResidual
      (copy_snapshot_after observation) finish ->
    CopyToPrecollisionClassifiedResidual observation finish.

Theorem supplied_copy_to_precollision_is_preserving_or_classified_residual :
  forall observation finish,
    SuppliedPostCopyFrameTail (copy_snapshot_after observation) finish ->
    SynchronizedCopyToPrecollisionPreservation observation finish \/
    CopyToPrecollisionClassifiedResidual observation finish.
Proof.
  intros observation finish Htail.
  destruct (supplied_copy_is_faithful_or_skipped_misdirected observation) as
    [Hcopy | Hcopy].
  2: right; now apply CopyToPrecollisionCopyBoundaryResidual.
  destruct (supplied_frame_tail_is_preserving_or_contains_classified_residual
      _ _ Htail) as [Hpreserve | Hescape].
  - left. constructor.
    + exact Hcopy.
    + exact Hpreserve.
    + eapply preserving_frame_tail_preserves_synchronization.
      * exact Hpreserve.
      * now apply faithful_copy_establishes_synchronization.
  - right. now apply CopyToPrecollisionFrameTailResidual.
Qed.

(** Once a future linked proof really supplies a faithful successful copy,
    the copy-boundary escape disappears and the entire remaining obligation is
    an all-preserving tail or one of the explicit post-copy escape families. *)
Theorem successful_copy_tail_is_preserving_or_classified_residual :
  forall observation finish,
    FaithfulSuccessfulStateToObjectCopy observation ->
    SuppliedPostCopyFrameTail (copy_snapshot_after observation) finish ->
    (SynchronizationPreservingFrameTail
       (copy_snapshot_after observation) finish /\
     state_object_synchronized (postcopy_tail_views finish)) \/
    FrameTailContainsClassifiedResidual
      (copy_snapshot_after observation) finish.
Proof.
  intros observation finish Hcopy Htail.
  destruct (supplied_frame_tail_is_preserving_or_contains_classified_residual
      _ _ Htail) as [Hpreserve | Hescape].
  - left. split; [exact Hpreserve |].
    eapply preserving_frame_tail_preserves_synchronization.
    + exact Hpreserve.
    + now apply faithful_copy_establishes_synchronization.
  - now right.
Qed.

Theorem successful_copy_final_split_requires_value_changing_tail_edge :
  forall observation finish,
    FaithfulSuccessfulStateToObjectCopy observation ->
    SuppliedPostCopyFrameTail (copy_snapshot_after observation) finish ->
    state_object_split (postcopy_tail_views finish) ->
    FrameTailContainsValueChangingEdge
      (copy_snapshot_after observation) finish.
Proof.
  intros observation finish Hcopy Htail Hsplit.
  eapply synchronized_tail_ending_split_contains_value_changing_edge.
  - exact Htail.
  - now apply faithful_copy_establishes_synchronization.
  - exact Hsplit.
Qed.

Definition Area1PostCopyTailClassificationCheckedBoundary : Prop :=
  (forall observation finish,
    SuppliedPostCopyFrameTail (copy_snapshot_after observation) finish ->
    SynchronizedCopyToPrecollisionPreservation observation finish \/
    CopyToPrecollisionClassifiedResidual observation finish) /\
  (forall observation finish,
    FaithfulSuccessfulStateToObjectCopy observation ->
    SuppliedPostCopyFrameTail (copy_snapshot_after observation) finish ->
    state_object_split (postcopy_tail_views finish) ->
    FrameTailContainsValueChangingEdge
      (copy_snapshot_after observation) finish).

Theorem area1_postcopy_tail_classification_checked_boundary_holds :
  Area1PostCopyTailClassificationCheckedBoundary.
Proof.
  split.
  - exact supplied_copy_to_precollision_is_preserving_or_classified_residual.
  - exact successful_copy_final_split_requires_value_changing_tail_edge.
Qed.

End PostCopyTailClassification.
