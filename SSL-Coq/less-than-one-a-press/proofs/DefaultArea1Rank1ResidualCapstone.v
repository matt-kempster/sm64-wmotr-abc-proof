(** Default-start residual capstone for the rank-1 JP installer route.

    The declared default SSL Area-1 boundary fixes [gMarioPlatform] to null.
    When a caller also supplies an [UpperWarpPrecollisionApplyProjection]
    tied to the same active run, the finite platform chronology therefore
    cannot end in the inherited-JP-lineage constructor.  The generic
    upper-warp classification then leaves only a completed-query residual.

    This is not a proof that the rank-1 route is impossible.  In particular,
    [DefaultArea1ActivePreapplyProjection] does not construct the pre-apply
    projection from linked Clight small steps, and [CompletedQueryScheduleBridge]
    does not prove that the faithful schedule constructor applies.  The second
    theorem below only says that a supplied different-sample completed query
    and supplied schedule bridge land in one of the already enumerated seven
    schedule/projection approaches. *)

From compcert Require Import Integers.
From LessThanOneAPress.Proofs Require Import
  Area1GapApproachCoverage DefaultArea1StartChronology
  StateFirstPlatformChronology.

(** The null default-start seed eliminates the retained-inbound disjunct from
    the generic upper-warp installer classification.  Live-query geometry,
    owner identity, slot/epoch provenance, and linked chronology remain inside
    [CompletedQueryUpperWarpInstallerResidual]. *)
Theorem default_area1_active_preapply_requires_completed_query_residual :
  forall canonical_ref projection run initial world
      previous_down current_down preapply,
    DefaultArea1ActivePreapplyProjection projection run initial world
      previous_down current_down preapply ->
    CompletedQueryUpperWarpInstallerResidual
      canonical_ref
      (projected_collision_position preapply)
      (projected_final_lineage preapply).
Proof.
  intros canonical_ref projection run initial world
    previous_down current_down preapply Hpreapply.
  destruct
    (projected_state_first_platform_installer_is_exhaustively_classified
      canonical_ref preapply) as [Hcompleted | Hinbound].
  - exact Hcompleted.
  - destruct Hinbound as
      (node & owner & skipped & Hlineage & _).
    exfalso.
    eapply (default_area1_active_preapply_has_no_jp_inbound_final_lineage
      projection run initial world previous_down current_down preapply
      node owner skipped Hpreapply).
    exact Hlineage.
Qed.

(** A different completed-query source is not silently collapsed to one
    opaque mismatch.  Under a supplied scheduler bridge, it belongs to one of
    pre-geometry State, Graphics retry, cached-floor snap, post-copy
    discrepancy, interaction writer, moving skipped-query frame, or
    unclassified projection.  The active-preapply premise ties this statement
    to the same scoped default run; the route remains open until linked
    execution constructs the projection and eliminates or realizes a case. *)
Theorem default_area1_completed_query_difference_expands_to_seven_approaches :
  forall projection run initial world previous_down current_down preapply
      source owner skipped,
    DefaultArea1ActivePreapplyProjection projection run initial world
      previous_down current_down preapply ->
    projected_final_lineage preapply =
      PlatformLineageFinalQuery source owner skipped ->
    source <> projected_collision_position preapply ->
    CompletedQueryScheduleBridge preapply source ->
    CompletedQueryDifferentSampleApproach preapply source.
Proof.
  intros projection run initial world previous_down current_down preapply
    source owner skipped _ Hlineage Hdifferent Hbridge.
  eapply completed_query_different_sample_expands_to_seven_approaches.
  - exact Hlineage.
  - exact Hdifferent.
  - exact Hbridge.
Qed.

(** Assumption-audit target.  It packages the two residual reductions without
    asserting that an active projection or a schedule bridge exists. *)
Definition DefaultArea1Rank1ResidualCheckedBoundary : Prop :=
  (forall canonical_ref projection run initial world
      previous_down current_down preapply,
    DefaultArea1ActivePreapplyProjection projection run initial world
      previous_down current_down preapply ->
    CompletedQueryUpperWarpInstallerResidual
      canonical_ref
      (projected_collision_position preapply)
      (projected_final_lineage preapply)) /\
  (forall projection run initial world previous_down current_down preapply
      source owner skipped,
    DefaultArea1ActivePreapplyProjection projection run initial world
      previous_down current_down preapply ->
    projected_final_lineage preapply =
      PlatformLineageFinalQuery source owner skipped ->
    source <> projected_collision_position preapply ->
    CompletedQueryScheduleBridge preapply source ->
    CompletedQueryDifferentSampleApproach preapply source).

Theorem default_area1_rank1_residual_checked_boundary_holds :
  DefaultArea1Rank1ResidualCheckedBoundary.
Proof.
  split.
  - exact default_area1_active_preapply_requires_completed_query_residual.
  - exact default_area1_completed_query_difference_expands_to_seven_approaches.
Qed.
