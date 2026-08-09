(** Versioned downstream suffix schemas for the concrete Area-2 cuts.

    Geometry and emulator receipts are imported but remain distinct from the
    abstract executions below.  A linked refinement record is required before
    a suffix can be attributed to an imported Clight run. *)

From Coq Require Import List ZArith.
From compcert Require Import Integers.
From LessThanOneAPress.Proofs Require Import
  GameTypes InputSemantics CleanEntry CollisionRegions
  AreaTransitions FirstTargetRefinement CollisionMeshFacts
  ClightRefinement Area2DownstreamGeometry Area2DownstreamReceipts.
From LessThanOneAPress.Proofs Require
  Area2ElevatorCut Area2LowerTargetCut.

Import ListNotations.

Definition ProjectedArea2Frame := (FrameInput * FrameEvent)%type.

Definition projected_area2_inputs
    (frames : list ProjectedArea2Frame) : list FrameInput :=
  map fst frames.

Definition projected_area2_events
    (frames : list ProjectedArea2Frame) : list FrameEvent :=
  map snd frames.

(** The transcript gives two distinct post-gate Act-3 itineraries.  This
    finite vocabulary records their order without pretending that the prose
    stages have already been refined to Clight program points. *)
Inductive TranscriptAct3Stage :=
| UpperSpawnHundredCoinStarNearAct3Platform
| UpperStoreRolloutVerticalSpeed
| UpperReactivateSpeedAndGroundPoundIntoHundredCoinStar
| UpperStarDanceClipToAct3Platform
| LowerLureHomingAmpFromNextFloor
| LowerUseHomingAmpShockLedgeGrab
| LowerTraverseRampToUpperGrindel
| LowerEnterUpperGrindelMisalignment
| LowerRolloutToUndescendedElevatorMisalignment
| LowerTriggerElevatorDescent
| LowerMountElevatorTop
| ReachAct3Platform
| RolloutCollectAct3.

Definition upper_transcript_act3_stages : list TranscriptAct3Stage :=
  [UpperSpawnHundredCoinStarNearAct3Platform;
   UpperStoreRolloutVerticalSpeed;
   UpperReactivateSpeedAndGroundPoundIntoHundredCoinStar;
   UpperStarDanceClipToAct3Platform;
   RolloutCollectAct3].

Definition lower_transcript_act3_stages : list TranscriptAct3Stage :=
  [LowerLureHomingAmpFromNextFloor;
   LowerUseHomingAmpShockLedgeGrab;
   LowerTraverseRampToUpperGrindel;
   LowerEnterUpperGrindelMisalignment;
   LowerRolloutToUndescendedElevatorMisalignment;
   LowerTriggerElevatorDescent;
   LowerMountElevatorTop;
   ReachAct3Platform;
   RolloutCollectAct3].

Theorem transcript_act3_stage_orders_checked :
  upper_transcript_act3_stages =
    [UpperSpawnHundredCoinStarNearAct3Platform;
     UpperStoreRolloutVerticalSpeed;
     UpperReactivateSpeedAndGroundPoundIntoHundredCoinStar;
     UpperStarDanceClipToAct3Platform;
     RolloutCollectAct3] /\
  lower_transcript_act3_stages =
    [LowerLureHomingAmpFromNextFloor;
     LowerUseHomingAmpShockLedgeGrab;
     LowerTraverseRampToUpperGrindel;
     LowerEnterUpperGrindelMisalignment;
     LowerRolloutToUndescendedElevatorMisalignment;
     LowerTriggerElevatorDescent;
     LowerMountElevatorTop;
     ReachAct3Platform;
     RolloutCollectAct3] /\
  length upper_transcript_act3_stages = 5%nat /\
  last upper_transcript_act3_stages ReachAct3Platform = RolloutCollectAct3 /\
  length lower_transcript_act3_stages = 9%nat /\
  last lower_transcript_act3_stages ReachAct3Platform = RolloutCollectAct3.
Proof. repeat split; reflexivity. Qed.

(** A suffix begins at the target side of an already selected cut.  It does
    not assume a clean prefix crossing that cut. *)
Record CutDownstreamSuffix
    (version : GameVersion) (cut : CollisionSupportCut) : Type := {
  suffix_initial_state : GameState;
  suffix_final_state : GameState;
  suffix_frames : list ProjectedArea2Frame;
  suffix_initial_version :
    state_version suffix_initial_state = version;
  suffix_initial_matches_cut_entrance :
    state_entrance suffix_initial_state = cut_entrance cut;
  suffix_initial_is_target_side :
    StateOnCutTargetSide cut suffix_initial_state;
  suffix_execution :
    CertifiedExecution suffix_initial_state
      (projected_area2_events suffix_frames)
      suffix_final_state;
  suffix_no_a_edge :
    fewer_than_one_a_press (projected_area2_inputs suffix_frames);
  suffix_input_history :
    coherent_input_history
      (state_first_frame_previous_down_seed suffix_initial_state)
      (projected_area2_inputs suffix_frames)
}.

Arguments suffix_initial_state {version cut} _.
Arguments suffix_final_state {version cut} _.
Arguments suffix_frames {version cut} _.
Arguments suffix_execution {version cut} _.
Arguments suffix_no_a_edge {version cut} _.
Arguments suffix_input_history {version cut} _.

Fixpoint final_button_down
    (initial_down : Int.int) (inputs : list FrameInput) : Int.int :=
  match inputs with
  | [] => initial_down
  | input :: rest => final_button_down (frame_current_down input) rest
  end.

(** The clean prefix is a distinct gate-closure obligation. *)
Record CleanCutPrefix
    (version : GameVersion) (cut : CollisionSupportCut)
    (boundary : GameState) : Type := {
  clean_prefix_initial : GameState;
  clean_prefix_frames : list ProjectedArea2Frame;
  clean_prefix_initial_is_clean :
    CleanPyramidEntry clean_prefix_initial;
  clean_prefix_initial_version :
    state_version clean_prefix_initial = version;
  clean_prefix_matches_cut_entrance :
    state_entrance clean_prefix_initial = cut_entrance cut;
  clean_prefix_execution :
    CertifiedExecution clean_prefix_initial
      (projected_area2_events clean_prefix_frames) boundary;
  clean_prefix_no_a_edge :
    fewer_than_one_a_press (projected_area2_inputs clean_prefix_frames);
  clean_prefix_input_history :
    coherent_input_history
      (state_first_frame_previous_down_seed clean_prefix_initial)
      (projected_area2_inputs clean_prefix_frames);
  clean_prefix_final_down_matches_suffix_seed :
    final_button_down
      (state_first_frame_previous_down_seed clean_prefix_initial)
      (projected_area2_inputs clean_prefix_frames) =
    state_first_frame_previous_down_seed boundary
}.

Arguments clean_prefix_initial {version cut boundary} _.
Arguments clean_prefix_frames {version cut boundary} _.
Arguments clean_prefix_initial_is_clean {version cut boundary} _.
Arguments clean_prefix_execution {version cut boundary} _.
Arguments clean_prefix_no_a_edge {version cut boundary} _.
Arguments clean_prefix_input_history {version cut boundary} _.
Arguments clean_prefix_final_down_matches_suffix_seed
  {version cut boundary} _.

Record CleanComposedCutContinuation
    (version : GameVersion) (cut : CollisionSupportCut) : Type := {
  composed_suffix : CutDownstreamSuffix version cut;
  composed_clean_prefix :
    CleanCutPrefix version cut (suffix_initial_state composed_suffix)
}.

Arguments composed_suffix {version cut} _.
Arguments composed_clean_prefix {version cut} _.

Definition composed_frames
    {version cut}
    (continuation : CleanComposedCutContinuation version cut)
    : list ProjectedArea2Frame :=
  clean_prefix_frames (composed_clean_prefix continuation) ++
  suffix_frames (composed_suffix continuation).

Definition suffix_reaches_act3_region
    {version : GameVersion} {cut : CollisionSupportCut}
    (suffix : CutDownstreamSuffix version cut) : Prop :=
  exists star phase,
    In (EventCollectAct3 star phase)
      (projected_area2_events (suffix_frames suffix)) /\
    object_origin star = StaticAct3PyramidStar /\
    act3_star_interaction_region phase star.

(** An inhabitant carries both the exact transcript itinerary and an actual
    no-A suffix reaching Act 3.  The equality below records the vocabulary; it
    does not assert that a linked Clight execution realizes each prose stage.
    Amp routing, 100-coin placement, exact misalignment cells, dynamic-owner
    identity, quarter-step execution, elevator state, and star collision remain
    the stage-to-Clight refinement work. *)
Record TranscriptAct3RouteSuffix
    (version : GameVersion) (cut : CollisionSupportCut)
    (expected_stages : list TranscriptAct3Stage) : Type := {
  transcript_act3_recorded_stages : list TranscriptAct3Stage;
  transcript_act3_recorded_stages_exact :
    transcript_act3_recorded_stages = expected_stages;
  transcript_act3_suffix : CutDownstreamSuffix version cut;
  transcript_act3_suffix_reaches_region :
    suffix_reaches_act3_region transcript_act3_suffix
}.

Definition UpperTranscriptAct3ContinuationObligation
    (version : GameVersion)
    (projection : Area2ElevatorCut.ElevatorCutSurfaceProjection) : Type :=
  TranscriptAct3RouteSuffix version
    (Area2ElevatorCut.upper_elevator_absolute_adapter_cut projection)
    upper_transcript_act3_stages.

Definition LowerTranscriptAct3ContinuationObligation
    (version : GameVersion)
    (projection : Area2LowerTargetCut.LowerTargetCutProjection) : Type :=
  TranscriptAct3RouteSuffix version
    (Area2LowerTargetCut.selected_lower_target_cut projection)
    lower_transcript_act3_stages.

Definition source_trigger_interaction_region
    (trigger : HiddenTrigger) (phase : CollisionPhase)
    (trigger_object : ObjectState) : Prop :=
  active_object trigger_object /\
  object_behavior trigger_object = BehaviorHiddenStarTrigger /\
  object_origin trigger_object = PyramidMacroTrigger /\
  object_trigger_kind trigger_object = Some trigger /\
  object_area trigger_object = pyramid_area_id /\
  object_position trigger_object = hidden_trigger_position trigger /\
  object_hitbox trigger_object = hidden_trigger_hitbox /\
  overlaps_object phase trigger_object.

Definition suffix_reaches_trigger_region
    {version : GameVersion} {cut : CollisionSupportCut}
    (suffix : CutDownstreamSuffix version cut)
    (trigger : HiddenTrigger) : Prop :=
  exists trigger_object phase,
    In (EventConsumeTrigger trigger trigger_object phase)
      (projected_area2_events (suffix_frames suffix)) /\
    source_trigger_interaction_region trigger phase trigger_object.

Definition suffix_reaches_all_five_trigger_regions
    {version : GameVersion} {cut : CollisionSupportCut}
    (suffix : CutDownstreamSuffix version cut) : Prop :=
  forall trigger, suffix_reaches_trigger_region suffix trigger.

Definition suffix_newly_collects_act6
    {version : GameVersion} {cut : CollisionSupportCut}
    (suffix : CutDownstreamSuffix version cut) : Prop :=
  newly_collected
    (state_save_flags (suffix_initial_state suffix))
    (state_save_flags (suffix_final_state suffix)) act6_index.

Definition suffix_reaches_act6_star_region
    {version : GameVersion} {cut : CollisionSupportCut}
    (suffix : CutDownstreamSuffix version cut) : Prop :=
  exists star phase,
    In (EventCollectAct6 star phase)
      (projected_area2_events (suffix_frames suffix)) /\
    active_star_or_key act6_index star /\
    object_origin star = PyramidHiddenStarController /\
    overlaps_object phase star.

(** All-five reachability and actual Act-6 collection remain separate fields. *)
Record CutDownstreamCoverage
    (version : GameVersion) (cut : CollisionSupportCut) : Type := {
  cut_act3_suffix : CutDownstreamSuffix version cut;
  cut_act3_region_reached : suffix_reaches_act3_region cut_act3_suffix;
  cut_all_five_suffix : CutDownstreamSuffix version cut;
  cut_all_five_regions_reached :
    suffix_reaches_all_five_trigger_regions cut_all_five_suffix;
  cut_act6_collection_suffix : CutDownstreamSuffix version cut;
  cut_act6_collection_all_five_regions_reached :
    suffix_reaches_all_five_trigger_regions cut_act6_collection_suffix;
  cut_act6_star_region_reached :
    suffix_reaches_act6_star_region cut_act6_collection_suffix;
  cut_act6_newly_collected :
    suffix_newly_collects_act6 cut_act6_collection_suffix
}.

Arguments cut_act3_suffix {version cut} _.
Arguments cut_all_five_suffix {version cut} _.
Arguments cut_act6_collection_suffix {version cut} _.

Definition UpperElevatorDownstreamCoverageObligation
    (version : GameVersion)
    (projection : Area2ElevatorCut.ElevatorCutSurfaceProjection) : Type :=
  CutDownstreamCoverage version
    (Area2ElevatorCut.upper_elevator_absolute_adapter_cut projection).

Definition LowerSupportOpenCellDownstreamCoverageObligation
    (version : GameVersion)
    (projection : Area2LowerTargetCut.LowerTargetCutProjection) : Type :=
  CutDownstreamCoverage version
    (Area2LowerTargetCut.selected_lower_target_cut projection).

Definition UpperElevatorUSDownstreamCoverageObligation
    (projection : Area2ElevatorCut.ElevatorCutSurfaceProjection) : Type :=
  UpperElevatorDownstreamCoverageObligation VersionUS projection.

Definition UpperElevatorJPDownstreamCoverageObligation
    (projection : Area2ElevatorCut.ElevatorCutSurfaceProjection) : Type :=
  UpperElevatorDownstreamCoverageObligation VersionJP projection.

Definition LowerSupportOpenCellUSDownstreamCoverageObligation
    (projection : Area2LowerTargetCut.LowerTargetCutProjection) : Type :=
  LowerSupportOpenCellDownstreamCoverageObligation VersionUS projection.

Definition LowerSupportOpenCellJPDownstreamCoverageObligation
    (projection : Area2LowerTargetCut.LowerTargetCutProjection) : Type :=
  LowerSupportOpenCellDownstreamCoverageObligation VersionJP projection.

Record LinkedCutDownstreamSuffixRefinement
    (version : GameVersion) (cut : CollisionSupportCut)
    (suffix : CutDownstreamSuffix version cut) : Type := {
  linked_suffix_projection : ClightObservationProjection;
  linked_suffix_projection_version :
    projection_version linked_suffix_projection = version;
  linked_suffix_run : ImportedClightRun;
  linked_suffix_certificate :
    ClightFrameRefinementCertificate
      linked_suffix_projection linked_suffix_run
      (suffix_initial_state suffix);
  linked_suffix_events_exact :
    project_events linked_suffix_projection linked_suffix_run =
      projected_area2_events (suffix_frames suffix);
  linked_suffix_inputs_exact :
    project_inputs linked_suffix_projection linked_suffix_run =
      projected_area2_inputs (suffix_frames suffix);
  linked_suffix_final_exact :
    refined_final_state linked_suffix_projection linked_suffix_run
      (suffix_initial_state suffix) linked_suffix_certificate =
        suffix_final_state suffix
}.

(** This checked boundary contains only static initializer facts and a finite
    mirror of conditional JP observations.  It does not inhabit a downstream coverage
    obligation or linked refinement. *)
Definition Area2DownstreamCheckedBoundary : Prop :=
  downstream_support_vertex_receipts area2_collision_vertices_us /\
  downstream_support_vertex_receipts area2_collision_vertices_jp /\
  downstream_support_triangle_word_receipts area2_collision_words_us /\
  downstream_support_triangle_word_receipts area2_collision_words_jp /\
  static_support_receipt_fully_valid
    area2_collision_words_us area2_collision_vertices_us
    act3_support_receipt /\
  static_support_receipt_fully_valid
    area2_collision_words_jp area2_collision_vertices_jp
    act3_support_receipt /\
  (forall trigger,
    static_support_receipt_fully_valid area2_collision_words_us
      area2_collision_vertices_us (trigger_support_receipt trigger)) /\
  (forall trigger,
    static_support_receipt_fully_valid area2_collision_words_jp
      area2_collision_vertices_jp (trigger_support_receipt trigger)) /\
  Forall milestone_overlap_flag_is_true conditional_jp_trigger_milestone_pairs /\
  ~ newly_collected Int.zero Int.zero act6_index.

Theorem area2_downstream_checked_boundary :
  Area2DownstreamCheckedBoundary.
Proof.
  unfold Area2DownstreamCheckedBoundary.
  split; [exact downstream_support_vertices_exact_us |].
  split; [exact downstream_support_vertices_exact_jp |].
  split; [exact downstream_support_triangle_words_exact_us |].
  split; [exact downstream_support_triangle_words_exact_jp |].
  split; [exact act3_support_receipt_fully_valid_us |].
  split; [exact act3_support_receipt_fully_valid_jp |].
  split; [exact every_trigger_support_receipt_fully_valid_us |].
  split; [exact every_trigger_support_receipt_fully_valid_jp |].
  split; [exact conditional_jp_milestone_overlap_flags_are_true |].
  exact (proj2 all_five_consumed_alone_does_not_imply_act6_collection).
Qed.
