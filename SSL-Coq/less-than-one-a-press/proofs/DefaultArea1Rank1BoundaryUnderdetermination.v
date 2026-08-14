(** Why the declared default-start boundary cannot by itself close rank 1.

    [DefaultArea1ActivePreapplyProjection] connects a pre-apply chronology to
    an active selected run only through the retail version and the decoded
    run-start [gMarioPlatform] seed.  It does not derive the chronology
    events, collision sample, queried owner, or apply-time owner from that
    run.  Consequently, whenever an active JP run satisfying that boundary
    is supplied, the current interface also accepts a fabricated, geometric
    pyramid-top query at one sample together with upper-warp collision at a
    different sample.

    This file deliberately does *not* call that fabricated record a retail
    counterexample.  Instead, the last theorem proves a diagnostic fact: an
    impossibility theorem quantified only over the current active-preapply
    interface is false whenever the declared JP run-nonvacuity obligation is
    inhabited.  Any argument that uses this interface must therefore add a
    linked run-to-preapply construction (or an equivalently strong rejecting
    premise).  A proof or counterexample built directly from stronger run
    semantics could bypass this wrapper. *)

From Coq Require Import Lia List ZArith.
From LessThanOneAPress.Proofs Require Import
  Area1PlatformExhaustiveness ClightRefinement
  DefaultArea1StartChronology GameTypes PyramidTopPU
  StateFirstPlatformChronology StockProjectionExhaustiveness.

Local Open Scope Z_scope.
Import ListNotations.

(** A conservative full-float point on the stock top envelope.  The owner
    candidate calculation below is only the existing envelope/tolerance
    predicate with a top label.  It is not a live triangle, surface-list,
    [find_floor], memory-selection, or canonical-slot claim. *)
Definition rank1_boundary_top_query_position : PositionZ := {|
  position_x := -2047;
  position_y := 1536;
  position_z := -1023
|}.

Definition rank1_boundary_top_owner_ref : ObjectRef := {|
  object_slot := 0%nat;
  object_epoch := 0%nat
|}.

Definition rank1_boundary_top_owner : Area1DynamicOwnerObservation := {|
  observed_owner_ref := rank1_boundary_top_owner_ref;
  observed_owner_kind := Some A1PyramidTop;
  observed_owner_query_position := rank1_boundary_top_query_position;
  observed_owner_floor_y := 1536
|}.

Lemma rank1_boundary_top_query_is_modeled_candidate :
  stock_area1_dynamic_floor_candidate A1PyramidTop
    rank1_boundary_top_query_position 1536.
Proof.
  unfold stock_area1_dynamic_floor_candidate,
    inside_horizontal_envelope, area1_owner_envelope,
    rank1_boundary_top_query_position,
    pyramid_top_floor_min_y, platform_floor_tolerance.
  cbn. lia.
Qed.

Lemma rank1_boundary_top_query_differs_from_upper_warp :
  rank1_boundary_top_query_position <> upper_warp_center.
Proof.
  intro Hequal.
  pose proof (f_equal position_y Hequal) as Hy.
  unfold rank1_boundary_top_query_position,
    upper_warp_center, upper_warp_y in Hy.
  cbn in Hy. lia.
Qed.

(** This record is intentionally constructed without consulting a Clight
    run.  Its constructibility is the point of the underdetermination proof. *)
Definition rank1_boundary_fabricated_preapply :
    UpperWarpPrecollisionApplyProjection.
Proof.
  refine
    {| projected_platform_version := PlatformJP;
       projected_jp_inbound_seed := None;
       projected_platform_events :=
         [ChronologyCompletedFinalQuery
            rank1_boundary_top_query_position
            (Some rank1_boundary_top_owner)];
       projected_collision_position := upper_warp_center;
       projected_loaded_platform_owner := Some rank1_boundary_top_owner |}.
  - constructor; [reflexivity | constructor].
  - reflexivity.
  - exact upper_warp_center_has_integer_contact.
  - discriminate.
Defined.

(** The exact rank-1 installer shape admitted by the weak boundary.  It stops
    at the non-null top-owned completed query and distinct upper-warp sample;
    inactive-slot lifetime, retained bytes, first apply, and star collection
    are intentionally absent and must come from later linked evidence. *)
Definition BoundaryAdmittedRank1TopInstaller
    (preapply : UpperWarpPrecollisionApplyProjection) : Prop :=
  projected_platform_version preapply = PlatformJP /\
  projected_jp_inbound_seed preapply = None /\
  projected_final_lineage preapply =
    PlatformLineageFinalQuery rank1_boundary_top_query_position
      rank1_boundary_top_owner 0 /\
  observed_owner_kind rank1_boundary_top_owner = Some A1PyramidTop /\
  stock_area1_dynamic_floor_candidate A1PyramidTop
    rank1_boundary_top_query_position
    (observed_owner_floor_y rank1_boundary_top_owner) /\
  projected_collision_position preapply = upper_warp_center /\
  rank1_boundary_top_query_position <>
    projected_collision_position preapply.

(** Conditional on the displayed canonical-ref equality, the fabricated
    record inhabits the canonical-modeled residual branch.  No theorem here
    establishes that equality for a live top slot.  Thus even eliminating the
    other abstract owner alternatives would not repair this wrapper by itself. *)
Definition BoundaryAdmittedCanonicalRank1Residual
    (canonical_ref : Area1SurfaceOwnerKind -> ObjectRef)
    (preapply : UpperWarpPrecollisionApplyProjection) : Prop :=
  canonical_ref A1PyramidTop = rank1_boundary_top_owner_ref /\
  CompletedQueryUpperWarpInstallerResidual canonical_ref
    (projected_collision_position preapply)
    (projected_final_lineage preapply).

Lemma rank1_boundary_fabricated_preapply_has_top_installer_shape :
  BoundaryAdmittedRank1TopInstaller rank1_boundary_fabricated_preapply.
Proof.
  unfold BoundaryAdmittedRank1TopInstaller,
    rank1_boundary_fabricated_preapply.
  cbn.
  split; [reflexivity |].
  split; [reflexivity |].
  split; [reflexivity |].
  split; [reflexivity |].
  split; [exact rank1_boundary_top_query_is_modeled_candidate |].
  split; [reflexivity |].
  exact rank1_boundary_top_query_differs_from_upper_warp.
Qed.

Theorem rank1_boundary_fabricated_preapply_inhabits_canonical_residual :
  forall canonical_ref,
    canonical_ref A1PyramidTop = rank1_boundary_top_owner_ref ->
    BoundaryAdmittedCanonicalRank1Residual canonical_ref
      rank1_boundary_fabricated_preapply.
Proof.
  intros canonical_ref Hcanonical.
  split; [exact Hcanonical |].
  exists rank1_boundary_top_query_position,
    rank1_boundary_top_owner, 0%nat.
  split; [reflexivity |].
  left.
  split.
  - exists A1PyramidTop.
    split; [reflexivity |].
    split.
    + cbn. symmetry. exact Hcanonical.
    + exact rank1_boundary_top_query_is_modeled_candidate.
  - exact rank1_boundary_top_query_differs_from_upper_warp.
Qed.

(** Every active JP run at the declared boundary can be paired with the same
    fabricated pre-apply record, because the interface checks only version
    and the null seed decoded from run-start memory. *)
Theorem default_area1_active_jp_boundary_accepts_fabricated_rank1_installer :
  forall projection run initial world previous_down current_down,
    DefaultArea1ActiveSelectedRun projection run initial world
      previous_down current_down ->
    projection_version projection = VersionJP ->
    exists preapply,
      DefaultArea1ActivePreapplyProjection projection run initial world
        previous_down current_down preapply /\
      BoundaryAdmittedRank1TopInstaller preapply.
Proof.
  intros projection run initial world previous_down current_down
    Hactive Hjp.
  exists rank1_boundary_fabricated_preapply.
  split.
  - constructor.
    + exact Hactive.
    + cbn. now rewrite Hjp.
    + cbn.
      exact (proj1 (default_area1_active_run_decodes_null_chronology_seed
        projection run initial world previous_down current_down Hactive)).
  - exact rank1_boundary_fabricated_preapply_has_top_installer_shape.
Qed.

(** Rigorous diagnostic: with a non-vacuous active JP run, the universal
    exclusion statement written below is false.  More generally, any proof
    whose only connection between the run and the pre-apply chronology is
    [DefaultArea1ActivePreapplyProjection] must add a premise which rejects
    this fabricated record.  This does not establish a retail route; it
    establishes that the current boundary is too weak to disprove one. *)
Theorem jp_default_boundary_alone_cannot_exclude_rank1_top_installer :
  forall projection,
    DefaultArea1StartProjectionNonvacuityObligation projection ->
    projection_version projection = VersionJP ->
    ~ (forall run initial world previous_down current_down preapply,
      DefaultArea1ActivePreapplyProjection projection run initial world
        previous_down current_down preapply ->
      ~ BoundaryAdmittedRank1TopInstaller preapply).
Proof.
  intros projection Hnonvacuous Hjp Hexclusion.
  destruct Hnonvacuous as
    (run & initial & world & previous_down & current_down & Hactive).
  destruct
    (default_area1_active_jp_boundary_accepts_fabricated_rank1_installer
      projection run initial world previous_down current_down Hactive Hjp)
    as (preapply & Hpreapply & Hrank1).
  exact (Hexclusion run initial world previous_down current_down preapply
    Hpreapply Hrank1).
Qed.
