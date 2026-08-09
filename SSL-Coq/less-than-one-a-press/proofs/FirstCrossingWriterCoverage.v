From Coq Require Import Classical_Prop List.
From compcert Require Import Events Floats Integers.
From LessThanOneAPress.Proofs Require Import
  GameTypes InputSemantics ObjectProvenance CleanEntry AreaTransitions
  RouteEvidence
  TranscriptRouteModel
  ClightRefinement FirstTargetRefinement
  PyramidTopPU Area1PhaseSplit Area1PlatformExhaustiveness.

Import ListNotations.

(** * A sound first-crossing boundary

    The older [FirstTargetWriterCoverageObligation] only asks for an arbitrary
    projected event no later than the target.  It neither identifies a cut
    crossing nor proves that the event caused one.  The definitions below
    replace that unused boundary with:

    - run-local initial-state membership plus endpoint-local separation;
    - an actual source-to-target Clight frame segment;
    - minimality among earlier projected frame endpoints; and
    - a classification of the state fields that can change cut membership.

    This file proves the classification for a crossing carried by a
    non-target abstract event.  Constructing such an evidence record from
    linked Clight control points, and treating a crossing that occurs inside
    the same frame as the target collision, remain explicit refinement
    obligations. *)

(** [CollisionSupportCut] is just data.  Without a validity predicate its two
    sides may overlap.  This concrete construction proves that the old
    unrestricted quantification over all descriptors cannot be used as a
    geometric separator theorem. *)
Definition overlapping_floor_cut
    (entrance : PyramidEntrance) (state : GameState)
    : CollisionSupportCut :=
  {| cut_entrance := entrance;
     cut_source_static_supports :=
       [mario_floor (state_mario_kinematics state)];
     cut_target_static_supports :=
       [mario_floor (state_mario_kinematics state)];
     cut_source_dynamic_supports := [];
     cut_target_dynamic_supports := [];
     cut_source_open_cells := [];
     cut_target_open_cells := [] |}.

Theorem an_unvalidated_cut_can_place_one_state_on_both_sides :
  forall entrance state,
    StateOnCutSourceSide (overlapping_floor_cut entrance state) state /\
    StateOnCutTargetSide (overlapping_floor_cut entrance state) state.
Proof.
  intros entrance state. split;
    unfold StateOnCutSourceSide, StateOnCutTargetSide,
      overlapping_floor_cut;
    constructor 1; cbn; auto.
Qed.

(** Legacy universal snapshot schema retained for the standalone reload helper
    below.  It is intentionally not a field of [FirstValidatedCutCrossingAt]:
    arbitrary abstract states can carry floor names unrelated to a linked
    projection. *)
Record EntranceCollisionCutEntryContract
    (version : GameVersion)
    (entrance : PyramidEntrance)
    (cut : CollisionSupportCut) : Prop := {
  cut_contract_entrance :
    cut_entrance cut = entrance;
  cut_contract_clean_entry_source :
    forall initial,
      CleanPyramidEntry initial ->
      state_version initial = version ->
      state_entrance initial = entrance ->
      StateOnCutSourceSide cut initial;
  cut_contract_entry_snapshot_excluded :
    forall state,
      state_version state = version ->
      state_entrance state = entrance ->
      entry_snapshot_for entrance (state_entry_snapshot state) ->
      state_mario_kinematics state =
        entry_kinematics (state_entry_snapshot state) ->
      ~ StateOnCutTargetSide cut state
}.

(** Numeric event indices are not enough to order two independently supplied
    [ClightFrameEvidence] records.  This relation puts both segments in one
    decomposition of the imported run and supplies the intervening Clight
    execution, including when all three subtraces are silent. *)
Definition ClightFrameEvidenceChronologicallyPrecedes
    {projection run initial certificate
     earlier_index earlier_event earlier_before earlier_after
     later_index later_event later_before later_after}
    (earlier :
      ClightFrameEvidence projection run initial certificate
        earlier_index earlier_event earlier_before earlier_after)
    (later :
      ClightFrameEvidence projection run initial certificate
        later_index later_event later_before later_after) : Prop :=
  exists between : Events.trace,
    run_trace run =
      frame_prefix_trace _ _ _ _ _ _ _ _ earlier ++
      frame_segment_trace _ _ _ _ _ _ _ _ earlier ++
      between ++
      frame_segment_trace _ _ _ _ _ _ _ _ later ++
      frame_suffix_trace _ _ _ _ _ _ _ _ later /\
    clight_run_star run
      (frame_after_clight _ _ _ _ _ _ _ _ earlier)
      between
      (frame_before_clight _ _ _ _ _ _ _ _ later).

Record FirstValidatedCutCrossingAt
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (region : TargetRouteRegion)
    (target_frame : nat) : Type := {
  first_crossing_cut : CollisionSupportCut;
  (** These facts are deliberately about the actual projected initial state.
      The older [EntranceCollisionCutEntryContract] quantifies over arbitrary
      ghost [GameState] values whose floor identifiers need not come from the
      linked run, so it cannot serve as the boundary of a retail crossing. *)
  first_crossing_cut_entrance :
    cut_entrance first_crossing_cut = state_entrance initial;
  first_crossing_initial_source :
    StateOnCutSourceSide first_crossing_cut initial;
  first_crossing_initial_not_target :
    ~ StateOnCutTargetSide first_crossing_cut initial;
  first_crossing_frame : nat;
  first_crossing_event : FrameEvent;
  first_crossing_before : GameState;
  first_crossing_after : GameState;
  first_crossing_precedes_target :
    (first_crossing_frame < target_frame)%nat;
  first_crossing_clight_frame :
    ClightFrameEvidence projection run initial certificate
      first_crossing_frame first_crossing_event
      first_crossing_before first_crossing_after;
  first_crossing_target_event : FrameEvent;
  first_crossing_target_before : GameState;
  first_crossing_target_after : GameState;
  first_crossing_target_event_matches_region :
    TargetEventForRegion region first_crossing_target_event;
  first_crossing_target_clight_frame :
    ClightFrameEvidence projection run initial certificate
      target_frame first_crossing_target_event
      first_crossing_target_before first_crossing_target_after;
  first_crossing_segment_precedes_target_segment :
    ClightFrameEvidenceChronologicallyPrecedes
      first_crossing_clight_frame first_crossing_target_clight_frame;
  first_crossing_is_non_target_event :
    non_target_event first_crossing_event;
  first_crossing_starts_on_source_side :
    StateOnCutSourceSide first_crossing_cut first_crossing_before;
  first_crossing_ends_on_target_side :
    StateOnCutTargetSide first_crossing_cut first_crossing_after;
  (** Global disjointness over arbitrary [GameState] values would be too
      strong: the abstract record does not yet connect a floor identifier,
      platform pointer, and XYZ to one collision query.  Require separation
      only at the actual projected endpoint.  The linked collision/mesh
      construction must prove this field. *)
  first_crossing_after_sides_separated :
    StateOnCutSourceSide first_crossing_cut first_crossing_after ->
    StateOnCutTargetSide first_crossing_cut first_crossing_after ->
    False;
  first_crossing_earlier_evidence_total :
    forall earlier,
      (earlier < first_crossing_frame)%nat ->
      exists event before after
          (evidence :
            ClightFrameEvidence projection run initial certificate
              earlier event before after),
        ClightFrameEvidenceChronologicallyPrecedes
          evidence first_crossing_clight_frame;
  first_crossing_is_minimal :
    forall earlier event before after
        (evidence :
          ClightFrameEvidence projection run initial certificate
            earlier event before after),
      (earlier < first_crossing_frame)%nat ->
      ~ StateOnCutTargetSide first_crossing_cut after
}.

(** The current evidence record is frame-based and requires the cut crossing
    to precede the target frame strictly.  Until target-interaction program
    points and collision-phase substates are imported, the sound residual is
    to prove that every actual projected target-event frame has such an earlier
    crossing.  A real same-frame or earlier transient crossing would refute
    this obligation and require a richer, source-backed interface; it cannot be
    discharged by choosing unrelated abstract states. *)
Definition NoSameFrameOrTransientCutEscape
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (cut : CollisionSupportCut) : Prop :=
  forall region target_frame target_event target_before target_after
      (target_evidence :
        ClightFrameEvidence projection run initial certificate
          target_frame target_event target_before target_after)
      (_ : TargetEventForRegion region target_event),
    exists crossing :
      FirstValidatedCutCrossingAt
        projection run initial certificate region target_frame,
      first_crossing_cut _ _ _ _ _ _ crossing = cut.

(** A family fixes the concrete separator used for each retail
    version/entrance/target combination.  The crossing record requires
    run-local initial membership and separation at its actual endpoint.
    Showing that a selected family
    corresponds to the actual target collision and collision mesh is part of
    the open first-crossing construction obligation below. *)
Definition TargetCollisionCutFamily : Type :=
  GameVersion -> PyramidEntrance -> TargetRouteRegion ->
  CollisionSupportCut.

Definition CrossingUsesTargetCutFamily
    (cuts : TargetCollisionCutFamily)
    {projection run initial certificate region target_frame}
    (crossing :
      FirstValidatedCutCrossingAt
        projection run initial certificate region target_frame) : Prop :=
  first_crossing_cut _ _ _ _ _ _ crossing =
    cuts (state_version initial) (state_entrance initial) region.

(** * Abstract writer coverage *)

Inductive FirstCrossingPositionWriter :=
| FirstWriterOrdinaryPhysics
| FirstWriterPlatformDisplacement
| FirstWriterObjectImpulse
| FirstWriterCollisionClip
| FirstWriterLifecycleEntry.

Inductive EventHasPositionWriter :
    FrameEvent -> FirstCrossingPositionWriter -> Prop :=
| EventWriterOrdinaryPhysics :
    forall before after,
      EventHasPositionWriter
        (EventMarioMotion MotionPhysicsFrame before after)
        FirstWriterOrdinaryPhysics
| EventWriterPlatformDisplacement :
    forall before after,
      EventHasPositionWriter
        (EventMarioMotion MotionPlatformDisplacement before after)
        FirstWriterPlatformDisplacement
| EventWriterObjectImpulse :
    forall before after,
      EventHasPositionWriter
        (EventMarioMotion MotionObjectPush before after)
        FirstWriterObjectImpulse
| EventWriterCollisionClip :
    forall before after,
      EventHasPositionWriter
        (EventMarioMotion MotionCollisionClip before after)
        FirstWriterCollisionClip
| EventWriterLifecycleEntry :
    EventHasPositionWriter EventAreaReload FirstWriterLifecycleEntry.

Lemma certified_non_target_spatial_effect :
  forall before event after,
    CertifiedStep before event after ->
    non_target_event event ->
    non_target_spatial_effect event before after.
Proof.
  intros before event after Hstep Hnon_target.
  inversion Hstep; subst; try assumption; inversion Hnon_target.
Qed.

Theorem changed_non_target_position_has_a_complete_writer_class :
  forall before event after,
    non_target_event event ->
    non_target_spatial_effect event before after ->
    mario_position (state_mario_kinematics after) <>
      mario_position (state_mario_kinematics before) ->
    exists writer, EventHasPositionWriter event writer.
Proof.
  intros before event after Hnon_target Hspatial Hchanged.
  inversion Hnon_target; subst; cbn in Hspatial.
  - exfalso. apply Hchanged.
    apply (f_equal mario_position). tauto.
  - destruct kind.
    + exists FirstWriterOrdinaryPhysics. constructor.
    + exists FirstWriterPlatformDisplacement. constructor.
    + exists FirstWriterObjectImpulse. constructor.
    + exists FirstWriterCollisionClip. constructor.
  - exfalso. apply Hchanged.
    apply (f_equal mario_position). tauto.
  - exfalso. apply Hchanged.
    apply (f_equal mario_position). tauto.
  - exfalso. apply Hchanged.
    apply (f_equal mario_position). tauto.
  - exfalso. apply Hchanged.
    apply (f_equal mario_position). tauto.
  - exfalso. apply Hchanged.
    apply (f_equal mario_position). tauto.
  - exists FirstWriterLifecycleEntry. constructor.
  - exfalso. apply Hchanged.
    apply (f_equal mario_position). tauto.
  - exfalso. apply Hchanged.
    unfold kinematic_core_equal in Hspatial. tauto.
  - exfalso. apply Hchanged.
    unfold kinematic_core_equal in Hspatial. tauto.
  - exfalso. apply Hchanged.
    apply (f_equal mario_position). tauto.
Qed.

Corollary certified_changed_non_target_position_has_a_complete_writer_class :
  forall before event after,
    CertifiedStep before event after ->
    non_target_event event ->
    mario_position (state_mario_kinematics after) <>
      mario_position (state_mario_kinematics before) ->
    exists writer, EventHasPositionWriter event writer.
Proof.
  intros before event after Hstep Hnon_target Hchanged.
  eapply changed_non_target_position_has_a_complete_writer_class; eauto.
  eapply certified_non_target_spatial_effect; eauto.
Qed.

(** A cut side depends only on Mario's position, floor reference, and captured
    platform.  This extensionality lemma is what lets the coverage theorem
    distinguish an actual position writer from a support-selection change. *)
Lemma state_on_collision_side_extensional :
  forall static_supports dynamic_supports open_cells before after,
    mario_position (state_mario_kinematics after) =
      mario_position (state_mario_kinematics before) ->
    mario_floor (state_mario_kinematics after) =
      mario_floor (state_mario_kinematics before) ->
    state_mario_platform after = state_mario_platform before ->
    StateOnCollisionSide
      static_supports dynamic_supports open_cells before ->
    StateOnCollisionSide
      static_supports dynamic_supports open_cells after.
Proof.
  intros static_supports dynamic_supports open_cells before after
    Hposition Hfloor Hplatform Hside.
  inversion Hside as
    [Hstatic | platform Hcaptured Hdynamic |
     cell Hcell Hinside]; subst.
  - constructor 1. rewrite Hfloor. exact Hstatic.
  - constructor 2 with (platform := platform).
    + rewrite Hplatform. exact Hcaptured.
    + exact Hdynamic.
  - constructor 3 with (cell := cell).
    + exact Hcell.
    + rewrite Hposition. exact Hinside.
Qed.

Lemma same_position_valid_cut_crossing_changes_support_selection :
  forall cut before after,
    StateOnCutSourceSide cut before ->
    StateOnCutTargetSide cut after ->
    (StateOnCutSourceSide cut after ->
     StateOnCutTargetSide cut after ->
     False) ->
    mario_position (state_mario_kinematics after) =
      mario_position (state_mario_kinematics before) ->
    mario_floor (state_mario_kinematics after) <>
      mario_floor (state_mario_kinematics before) \/
    state_mario_platform after <> state_mario_platform before.
Proof.
  intros cut before after Hsource Htarget Hseparated Hposition.
  destruct (classic
    (mario_floor (state_mario_kinematics after) =
     mario_floor (state_mario_kinematics before))) as [Hfloor | Hfloor].
  - destruct (classic
      (state_mario_platform after =
       state_mario_platform before)) as [Hplatform | Hplatform].
    + exfalso.
      eapply Hseparated.
      * unfold StateOnCutSourceSide in *.
        eapply state_on_collision_side_extensional; eauto.
      * exact Htarget.
    + right. exact Hplatform.
  - left. exact Hfloor.
Qed.

Inductive FirstCrossingWriterCause
    (event : FrameEvent) (before after : GameState) : Prop :=
| FirstCrossingByPositionWriter :
    forall writer,
      EventHasPositionWriter event writer ->
      mario_position (state_mario_kinematics after) <>
        mario_position (state_mario_kinematics before) ->
      FirstCrossingWriterCause event before after
| FirstCrossingBySupportSelection :
    mario_position (state_mario_kinematics after) =
      mario_position (state_mario_kinematics before) ->
    (mario_floor (state_mario_kinematics after) <>
       mario_floor (state_mario_kinematics before) \/
     state_mario_platform after <> state_mario_platform before) ->
    FirstCrossingWriterCause event before after.

Theorem validated_pre_target_first_crossing_writer_coverage :
  forall projection run initial certificate region target_frame
      (crossing :
        FirstValidatedCutCrossingAt
          projection run initial certificate region target_frame),
    FirstCrossingWriterCause
      (first_crossing_event _ _ _ _ _ _ crossing)
      (first_crossing_before _ _ _ _ _ _ crossing)
      (first_crossing_after _ _ _ _ _ _ crossing).
Proof.
  intros projection run initial certificate region target_frame crossing.
  destruct (classic
    (mario_position
       (state_mario_kinematics
         (first_crossing_after _ _ _ _ _ _ crossing)) =
     mario_position
       (state_mario_kinematics
         (first_crossing_before _ _ _ _ _ _ crossing))))
    as [Hsame | Hchanged].
  - apply FirstCrossingBySupportSelection.
    + exact Hsame.
    + eapply same_position_valid_cut_crossing_changes_support_selection.
      * exact (first_crossing_starts_on_source_side _ _ _ _ _ _ crossing).
      * exact (first_crossing_ends_on_target_side _ _ _ _ _ _ crossing).
      * exact (first_crossing_after_sides_separated
          _ _ _ _ _ _ crossing).
      * exact Hsame.
  - pose proof
      (certified_step_at_is_step
        _ _ _ _ _ _ _
        (frame_certified_occurrence
          _ _ _ _ _ _ _ _
          (first_crossing_clight_frame _ _ _ _ _ _ crossing)))
      as Hstep.
    destruct
      (certified_changed_non_target_position_has_a_complete_writer_class
        _ _ _ Hstep
        (first_crossing_is_non_target_event _ _ _ _ _ _ crossing)
        Hchanged) as [writer Hwriter].
    eapply FirstCrossingByPositionWriter with (writer := writer).
    + exact Hwriter.
    + exact Hchanged.
Qed.

(** * Lifecycle and ordinary-admin eliminations *)

Inductive NonSpatialAdminEvent : FrameEvent -> Prop :=
| AdminOrdinary : NonSpatialAdminEvent EventOrdinary
| AdminCollectOther : forall index,
    index <> act3_index ->
    index <> act6_index ->
    NonSpatialAdminEvent (EventCollectOther index)
| AdminDeactivate : forall object,
    NonSpatialAdminEvent (EventDeactivate object)
| AdminReuseSlot : forall old_object new_object,
    fresh_slot_reuse old_object new_object ->
    NonSpatialAdminEvent (EventReuseSlot old_object new_object)
| AdminMacroRespawn : NonSpatialAdminEvent EventMacroRespawn
| AdminAreaUnload : NonSpatialAdminEvent EventAreaUnload
| AdminSaveFileReload : NonSpatialAdminEvent EventSaveFileReload
| AdminCollisionRefresh : NonSpatialAdminEvent EventCollisionRefresh.

Lemma nonspatial_admin_is_non_target :
  forall event,
    NonSpatialAdminEvent event ->
    non_target_event event.
Proof.
  intros event Hadmin. inversion Hadmin; subst; constructor; auto.
Qed.

Theorem certified_nonspatial_admin_preserves_kinematics :
  forall before event after,
    NonSpatialAdminEvent event ->
    CertifiedStep before event after ->
    state_mario_kinematics after = state_mario_kinematics before.
Proof.
  intros before event after Hadmin Hstep.
  pose proof
    (certified_non_target_spatial_effect
      before event after Hstep
      (nonspatial_admin_is_non_target event Hadmin)) as Hspatial.
  inversion Hadmin; subst; cbn in Hspatial; tauto.
Qed.

Theorem certified_area_reload_spatial_cases :
  forall before after,
    CertifiedStep before EventAreaReload after ->
    (state_area after = state_area before /\
     state_mario_kinematics after = state_mario_kinematics before) \/
    (state_area after = pyramid_area_id /\
     state_mario_kinematics after =
       entry_kinematics (state_entry_snapshot after)).
Proof.
  intros before after Hstep.
  exact
    (certified_non_target_spatial_effect
      before EventAreaReload after Hstep NonTargetAreaReload).
Qed.

Theorem changed_area_reload_returns_to_entry_snapshot :
  forall before after,
    CertifiedStep before EventAreaReload after ->
    mario_position (state_mario_kinematics after) <>
      mario_position (state_mario_kinematics before) ->
    state_area after = pyramid_area_id /\
    state_mario_kinematics after =
      entry_kinematics (state_entry_snapshot after).
Proof.
  intros before after Hstep Hchanged.
  destruct (certified_area_reload_spatial_cases before after Hstep)
    as [[Harea Hsame] | Hentry].
  - exfalso. apply Hchanged.
    apply (f_equal mario_position). exact Hsame.
  - exact Hentry.
Qed.

Definition SharesInitialRouteContext
    (initial state : GameState) : Prop :=
  state_version state = state_version initial /\
  state_entrance state = state_entrance initial /\
  state_entry_snapshot state = state_entry_snapshot initial.

Theorem lifecycle_entry_displacement_is_impossible_for_validated_cut :
  forall projection run initial certificate target_frame
      cut index before after,
    (index < target_frame)%nat ->
    ClightFrameEvidence projection run initial certificate index
      EventAreaReload before after ->
    cut_entrance cut = state_entrance initial ->
    StateOnCutSourceSide cut before ->
    StateOnCutTargetSide cut after ->
    mario_position (state_mario_kinematics after) <>
      mario_position (state_mario_kinematics before) ->
    EntranceCollisionCutEntryContract
      (state_version initial) (state_entrance initial)
      cut ->
    SharesInitialRouteContext initial after ->
    False.
Proof.
  intros projection run initial certificate target_frame
    cut index before after Hprecedes Hframe Hentrance
    Hsource Htarget Hchanged Hvalid Hcontext.
  pose proof
    (certified_step_at_is_step
      _ _ _ _ _ _ _
      (frame_certified_occurrence _ _ _ _ _ _ _ _ Hframe))
    as Hstep.
  destruct
    (changed_area_reload_returns_to_entry_snapshot
      before after Hstep Hchanged) as [_ Hentry].
  pose proof (certified_step_successor_is_well_formed
    before EventAreaReload after Hstep) as Hwell_formed.
  unfold frame_well_formed in Hwell_formed.
  destruct Hwell_formed as
    (_ & _ & _ & _ & _ & _ & _ & Hsnapshot).
  destruct Hcontext as [Hversion [Hentry_kind Hsnapshot_same]].
  eapply (cut_contract_entry_snapshot_excluded
    _ _ _ Hvalid after).
  - exact Hversion.
  - exact Hentry_kind.
  - rewrite Hentry_kind in Hsnapshot. exact Hsnapshot.
  - exact Hentry.
  - exact Htarget.
Qed.

(** * General coordinate aliases are outcomes, not independent writers *)

Definition HorizontalCoordinatesLocal
    (kinematics : MarioKinematics) : Prop :=
  forall axis integer,
    Float32.to_int (horizontal_axis_coordinate axis kinematics) =
      Some (Int.repr integer) ->
    Int.signed (Int.repr integer) = integer ->
    legacy_pu_local_coordinate integer.

Inductive MarioCoordinateAxis :=
| MarioCoordinateX
| MarioCoordinateY
| MarioCoordinateZ.

Definition mario_coordinate
    (axis : MarioCoordinateAxis)
    (kinematics : MarioKinematics) : float32 :=
  match axis with
  | MarioCoordinateX => vec_x (mario_position kinematics)
  | MarioCoordinateY => vec_y (mario_position kinematics)
  | MarioCoordinateZ => vec_z (mario_position kinematics)
  end.

(** This domain predicate is stronger than merely saying that every
    successful conversion is local.  It requires each X/Y/Z conversion to
    succeed, records the exact signed result, and bounds that result to the
    local SSL coordinate interval.  Its negation therefore includes failed
    conversions, NaNs/infinities, compiled out-of-range behavior still lacking
    refinement, and nonlocal 65536-period aliases. *)
Definition CoordinatesInLocalCastDomain
    (kinematics : MarioKinematics) : Prop :=
  forall axis,
    exists integer,
      Float32.to_int (mario_coordinate axis kinematics) =
        Some (Int.repr integer) /\
      Int.signed (Int.repr integer) = integer /\
      legacy_pu_local_coordinate integer.

Lemma local_cast_domain_implies_horizontal_coordinates_local :
  forall kinematics,
    CoordinatesInLocalCastDomain kinematics ->
    HorizontalCoordinatesLocal kinematics.
Proof.
  intros kinematics Hdomain axis integer Hexact Hsigned.
  destruct axis.
  - destruct (Hdomain MarioCoordinateX)
    as [local [Hlocal_exact [Hlocal_signed Hlocal]]].
    cbn in Hexact, Hlocal_exact.
    assert (Hrepr : Int.repr integer = Int.repr local) by congruence.
    assert (integer = local).
    {
      pose proof (f_equal Int.signed Hrepr) as Hsigned_equal.
      rewrite Hsigned, Hlocal_signed in Hsigned_equal.
      exact Hsigned_equal.
    }
    subst integer. exact Hlocal.
  - destruct (Hdomain MarioCoordinateZ)
    as [local [Hlocal_exact [Hlocal_signed Hlocal]]].
    cbn in Hexact, Hlocal_exact.
    assert (Hrepr : Int.repr integer = Int.repr local) by congruence.
    assert (integer = local).
    {
      pose proof (f_equal Int.signed Hrepr) as Hsigned_equal.
      rewrite Hsigned, Hlocal_signed in Hsigned_equal.
      exact Hsigned_equal.
    }
    subst integer. exact Hlocal.
Qed.

Theorem local_horizontal_coordinates_exclude_alias_witness :
  forall before after,
    HorizontalCoordinatesLocal after ->
    forall witness : CoordinateAliasEscapeWitness before after,
      False.
Proof.
  intros before after Hlocal witness.
  apply (alias_after_nonlocal _ _ witness).
  eapply Hlocal.
  - exact (alias_after_exact _ _ witness).
  - exact (alias_after_signed _ _ witness).
Qed.

Definition ProjectedPhysicsEndpointsStayLocal
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    : Prop :=
  forall index before after from to,
    ClightFrameEvidence projection run initial certificate index
      (EventMarioMotion MotionPhysicsFrame from to) before after ->
    HorizontalCoordinatesLocal to.

Theorem coordinate_alias_is_impossible_if_projected_endpoints_stay_local :
  forall projection run initial certificate target_frame,
    ProjectedPhysicsEndpointsStayLocal
      projection run initial certificate ->
    forall evidence :
      CoordinateAliasBeforeTargetEvidence
        projection run initial certificate target_frame,
      False.
Proof.
  intros projection run initial certificate target_frame
    Hlocal evidence.
  destruct evidence as
    [cut index before after from to Hprecedes Hframe
     Hentrance Hsource Htarget Halias].
  eapply (local_horizontal_coordinates_exclude_alias_witness
    from to).
  - eapply Hlocal. exact Hframe.
  - exact Halias.
Qed.

(** * The corrected no-A exclusion interface

    Coordinate aliases are not stores: they are a domain/result class of a
    physics endpoint.  Ordinary physics is therefore split into local-cast and
    nonlocal/undefined-cast cases.  A same-position floor/platform transition
    is a seventh support-selection case that the historical six classes
    omitted; it cannot soundly be called a nonspatial lifecycle event. *)

Definition CrossingUsesPositionWriter
    {projection run initial certificate region target_frame}
    (crossing :
      FirstValidatedCutCrossingAt
        projection run initial certificate region target_frame)
    (writer : FirstCrossingPositionWriter) : Prop :=
  EventHasPositionWriter
    (first_crossing_event _ _ _ _ _ _ crossing) writer /\
  mario_position
      (state_mario_kinematics
        (first_crossing_after _ _ _ _ _ _ crossing)) <>
    mario_position
      (state_mario_kinematics
        (first_crossing_before _ _ _ _ _ _ crossing)).

Definition CrossingUsesLocalOrdinaryPhysics
    {projection run initial certificate region target_frame}
    (crossing :
      FirstValidatedCutCrossingAt
        projection run initial certificate region target_frame) : Prop :=
  exists from to,
    first_crossing_event _ _ _ _ _ _ crossing =
      EventMarioMotion MotionPhysicsFrame from to /\
    CoordinatesInLocalCastDomain to /\
    mario_position
        (state_mario_kinematics
          (first_crossing_after _ _ _ _ _ _ crossing)) <>
      mario_position
        (state_mario_kinematics
          (first_crossing_before _ _ _ _ _ _ crossing)).

Definition CrossingUsesCoordinateAliasOrOutOfBounds
    {projection run initial certificate region target_frame}
    (crossing :
      FirstValidatedCutCrossingAt
        projection run initial certificate region target_frame) : Prop :=
  exists from to,
    first_crossing_event _ _ _ _ _ _ crossing =
      EventMarioMotion MotionPhysicsFrame from to /\
    ~ CoordinatesInLocalCastDomain to /\
    mario_position
        (state_mario_kinematics
          (first_crossing_after _ _ _ _ _ _ crossing)) <>
      mario_position
        (state_mario_kinematics
          (first_crossing_before _ _ _ _ _ _ crossing)).

Definition CrossingUsesSupportSelection
    {projection run initial certificate region target_frame}
    (crossing :
      FirstValidatedCutCrossingAt
        projection run initial certificate region target_frame) : Prop :=
  mario_position
      (state_mario_kinematics
        (first_crossing_after _ _ _ _ _ _ crossing)) =
    mario_position
      (state_mario_kinematics
        (first_crossing_before _ _ _ _ _ _ crossing)) /\
  (mario_floor
      (state_mario_kinematics
        (first_crossing_after _ _ _ _ _ _ crossing)) <>
     mario_floor
      (state_mario_kinematics
        (first_crossing_before _ _ _ _ _ _ crossing)) \/
   state_mario_platform
      (first_crossing_after _ _ _ _ _ _ crossing) <>
     state_mario_platform
      (first_crossing_before _ _ _ _ _ _ crossing)).

Definition NoALocalOrdinaryFirstCrossing
    (projection : ClightObservationProjection)
    (cuts : TargetCollisionCutFamily) : Prop :=
  forall run initial certificate region target_frame
      (crossing :
        FirstValidatedCutCrossingAt
          projection run initial certificate region target_frame),
    CleanPyramidEntry initial ->
    CrossingUsesTargetCutFamily cuts crossing ->
    fewer_than_one_a_press (project_inputs projection run) ->
    ~ CrossingUsesLocalOrdinaryPhysics crossing.

Definition NoAPlatformFirstCrossing
    (projection : ClightObservationProjection)
    (cuts : TargetCollisionCutFamily) : Prop :=
  forall run initial certificate region target_frame
      (crossing :
        FirstValidatedCutCrossingAt
          projection run initial certificate region target_frame),
    CleanPyramidEntry initial ->
    CrossingUsesTargetCutFamily cuts crossing ->
    fewer_than_one_a_press (project_inputs projection run) ->
    ~ CrossingUsesPositionWriter
        crossing FirstWriterPlatformDisplacement.

Definition NoAObjectImpulseFirstCrossing
    (projection : ClightObservationProjection)
    (cuts : TargetCollisionCutFamily) : Prop :=
  forall run initial certificate region target_frame
      (crossing :
        FirstValidatedCutCrossingAt
          projection run initial certificate region target_frame),
    CleanPyramidEntry initial ->
    CrossingUsesTargetCutFamily cuts crossing ->
    fewer_than_one_a_press (project_inputs projection run) ->
    ~ CrossingUsesPositionWriter crossing FirstWriterObjectImpulse.

Definition NoACollisionClipOrTunnelFirstCrossing
    (projection : ClightObservationProjection)
    (cuts : TargetCollisionCutFamily) : Prop :=
  forall run initial certificate region target_frame
      (crossing :
        FirstValidatedCutCrossingAt
          projection run initial certificate region target_frame),
    CleanPyramidEntry initial ->
    CrossingUsesTargetCutFamily cuts crossing ->
    fewer_than_one_a_press (project_inputs projection run) ->
    ~ CrossingUsesPositionWriter crossing FirstWriterCollisionClip.

Definition NoACoordinateAliasOrOutOfBoundsFirstCrossing
    (projection : ClightObservationProjection)
    (cuts : TargetCollisionCutFamily) : Prop :=
  forall run initial certificate region target_frame
      (crossing :
        FirstValidatedCutCrossingAt
          projection run initial certificate region target_frame),
    CleanPyramidEntry initial ->
    CrossingUsesTargetCutFamily cuts crossing ->
    fewer_than_one_a_press (project_inputs projection run) ->
    ~ CrossingUsesCoordinateAliasOrOutOfBounds crossing.

Definition NoALifecycleOrEntryFirstCrossing
    (projection : ClightObservationProjection)
    (cuts : TargetCollisionCutFamily) : Prop :=
  forall run initial certificate region target_frame
      (crossing :
        FirstValidatedCutCrossingAt
          projection run initial certificate region target_frame),
    CleanPyramidEntry initial ->
    CrossingUsesTargetCutFamily cuts crossing ->
    fewer_than_one_a_press (project_inputs projection run) ->
    ~ CrossingUsesPositionWriter crossing FirstWriterLifecycleEntry.

Definition NoASupportSelectionFirstCrossing
    (projection : ClightObservationProjection)
    (cuts : TargetCollisionCutFamily) : Prop :=
  forall run initial certificate region target_frame
      (crossing :
        FirstValidatedCutCrossingAt
          projection run initial certificate region target_frame),
    CleanPyramidEntry initial ->
    CrossingUsesTargetCutFamily cuts crossing ->
    fewer_than_one_a_press (project_inputs projection run) ->
    ~ CrossingUsesSupportSelection crossing.

Theorem no_a_complete_writer_exclusions_rule_out_validated_first_crossing :
  forall projection cuts,
    NoALocalOrdinaryFirstCrossing projection cuts ->
    NoAPlatformFirstCrossing projection cuts ->
    NoAObjectImpulseFirstCrossing projection cuts ->
    NoACollisionClipOrTunnelFirstCrossing projection cuts ->
    NoACoordinateAliasOrOutOfBoundsFirstCrossing projection cuts ->
    NoALifecycleOrEntryFirstCrossing projection cuts ->
    NoASupportSelectionFirstCrossing projection cuts ->
    forall run initial certificate region target_frame
        (crossing :
          FirstValidatedCutCrossingAt
            projection run initial certificate region target_frame),
      CleanPyramidEntry initial ->
      CrossingUsesTargetCutFamily cuts crossing ->
      fewer_than_one_a_press (project_inputs projection run) ->
      False.
Proof.
  intros projection cuts Hordinary Hplatform Hobject Hclip Halias
    Hlifecycle Hsupport run initial certificate region target_frame
    crossing Hclean Hcut Hno_a.
  pose proof
    (validated_pre_target_first_crossing_writer_coverage
      projection run initial certificate region target_frame crossing)
    as Hcoverage.
  inversion Hcoverage as
    [writer Hwriter Hchanged | Hsame Hsupport_change]; subst.
  - inversion Hwriter; subst.
    + destruct (classic (CoordinatesInLocalCastDomain after))
        as [Hlocal | Hnonlocal].
      * eapply (Hordinary run initial certificate region target_frame
          crossing Hclean Hcut Hno_a).
        exists before, after. split; [symmetry; assumption |].
        split; assumption.
      * eapply (Halias run initial certificate region target_frame
          crossing Hclean Hcut Hno_a).
        exists before, after. split; [symmetry; assumption |].
        split; assumption.
    + eapply (Hplatform run initial certificate region target_frame
        crossing Hclean Hcut Hno_a).
      split; [exact Hwriter | exact Hchanged].
    + eapply (Hobject run initial certificate region target_frame
        crossing Hclean Hcut Hno_a).
      split; [exact Hwriter | exact Hchanged].
    + eapply (Hclip run initial certificate region target_frame
        crossing Hclean Hcut Hno_a).
      split; [exact Hwriter | exact Hchanged].
    + eapply (Hlifecycle run initial certificate region target_frame
        crossing Hclean Hcut Hno_a).
      split; [exact Hwriter | exact Hchanged].
  - eapply (Hsupport run initial certificate region target_frame
      crossing Hclean Hcut Hno_a).
    split; assumption.
Qed.

(** The Area-1 node-0x1E platform bootstrap is the one platform subcase that
    the finite source model has closed.  This theorem deliberately does not
    generalize it to Area-2 platform displacement or stale/reused pointers. *)
Theorem area1_upper_warp_platform_bootstrap_closed_subcase :
  forall position platform,
    StockArea1PreapplyPlatform position platform ->
    upper_warp_contact position ->
    platform = None.
Proof.
  exact stock_area1_upper_warp_preapply_platform_null.
Qed.

(** The corrected construction obligation is intentionally about the actual
    first validated crossing.  It is not discharged by the totality of
    [writer_class_of_event]. *)
Definition FirstValidatedCrossingConstructionObligation
    (projection : ClightObservationProjection)
    (cuts : TargetCollisionCutFamily) : Prop :=
  forall run initial
      (certificate :
        ClightFrameRefinementCertificate projection run initial)
      trace region target_frame target_observation,
    CleanPyramidEntry initial ->
    ClightRouteTraceProjection
      projection run initial certificate trace ->
    first_target_observation_at
      trace region target_frame target_observation ->
    exists crossing :
      FirstValidatedCutCrossingAt
        projection run initial certificate region target_frame,
      CrossingUsesTargetCutFamily cuts crossing.
