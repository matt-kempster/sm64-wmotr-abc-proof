From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Events Floats Globalenvs Integers
  Memory Smallstep Values.
From LessThanOneAPress.Generated Require Import jp_platform_displacement.
From LessThanOneAPress.Proofs Require Import
  GameTypes InputSemantics ObjectProvenance CleanEntry CollisionRegions
  AreaTransitions StarCollection HiddenStar ClightRefinement RouteEvidence
  TranscriptRouteModel.

Import ListNotations.
Local Open Scope Z_scope.

(** * Indexed occurrences in the certified event semantics

    [CertifiedExecution] deliberately records one abstract event per modeled
    frame but did not previously expose the state immediately before and after
    an event at a particular list index.  The indexed relation below supplies
    that missing, non-oracular payload. *)

Inductive CertifiedStepAt :
    GameState -> list FrameEvent -> GameState ->
    nat -> FrameEvent -> GameState -> GameState -> Prop :=
| CertifiedStepAtHead :
    forall before middle final event events,
      CertifiedStep before event middle ->
      CertifiedExecution middle events final ->
      CertifiedStepAt before (event :: events) final
        0%nat event before middle
| CertifiedStepAtTail :
    forall initial middle final head events index event before after,
      CertifiedStep initial head middle ->
      CertifiedStepAt middle events final index event before after ->
      CertifiedStepAt initial (head :: events) final
        (S index) event before after.

Lemma certified_step_at_is_step :
  forall initial events final index event before after,
    CertifiedStepAt initial events final index event before after ->
    CertifiedStep before event after.
Proof.
  intros initial events final index event before after Hoccurrence.
  induction Hoccurrence; assumption.
Qed.

Lemma certified_step_successor_is_well_formed :
  forall before event after,
    CertifiedStep before event after ->
    frame_well_formed after.
Proof.
  intros before event after Hstep.
  inversion Hstep; subst; assumption.
Qed.

Lemma clean_entry_is_frame_well_formed :
  forall state,
    CleanPyramidEntry state ->
    frame_well_formed state.
Proof.
  intros state Hclean.
  unfold frame_well_formed.
  split; [exact (clean_pool state Hclean) |].
  split; [exact (clean_lists state Hclean) |].
  split; [exact (clean_target_provenance state Hclean) |].
  split; [exact (clean_hidden_trigger_provenance state Hclean) |].
  split; [exact (clean_hidden_trigger_refs_distinct state Hclean) |].
  split; [exact (clean_macro_spawn state Hclean) |].
  split; [exact (clean_platform state Hclean) |].
  exact (clean_entry_snapshot state Hclean).
Qed.

Lemma certified_step_at_before_is_well_formed :
  forall initial events final index event before after,
    frame_well_formed initial ->
    CertifiedStepAt initial events final index event before after ->
    frame_well_formed before.
Proof.
  intros initial events final index event before after
    Hinitial Hoccurrence.
  induction Hoccurrence.
  - exact Hinitial.
  - apply IHHoccurrence.
    eapply certified_step_successor_is_well_formed; eauto.
Qed.

Lemma certified_execution_nth_has_step_at :
  forall initial events final,
    CertifiedExecution initial events final ->
    forall index event,
      nth_error events index = Some event ->
      exists before after,
        CertifiedStepAt initial events final index event before after.
Proof.
  intros initial events final Hexec.
  induction Hexec as
    [state | before middle final head events Hhead Htail IH];
    intros index event Hat.
  - destruct index; discriminate.
  - destruct index as [|index].
    + cbn in Hat. inversion Hat; subst event.
      exists before, middle.
      econstructor; eauto.
    + cbn in Hat.
      destruct (IH index event Hat) as [step_before [step_after Hoccurrence]].
      exists step_before, step_after.
      econstructor 2; eauto.
Qed.

(** * Concrete Clight-frame evidence

    This record is intentionally stronger than
    [ClightFrameRefinementCertificate].  It names the actual Clight states on
    both sides of a projected frame, gives a decomposition of the CompCert
    trace through that segment, projects both states, and connects the frame
    to the indexed certified step.  No constructor below is merely a route
    class tag.  Constructing these records from the generated programs is a
    genuine remaining simulation obligation. *)

Definition clight_run_star
    (run : ImportedClightRun)
    (before : Clight.state) (trace : Events.trace)
    (after : Clight.state) : Prop :=
  @Smallstep.star _ _ Clight.step2
    (Clight.globalenv (run_program run)) before trace after.

Record ClightFrameEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (index : nat) (event : FrameEvent)
    (before after : GameState) : Type := {
  frame_before_clight : Clight.state;
  frame_after_clight : Clight.state;
  frame_prefix_trace : Events.trace;
  frame_segment_trace : Events.trace;
  frame_suffix_trace : Events.trace;
  frame_run_uses_projection :
    RunUsesProjection projection run;
  frame_trace_decomposition :
    run_trace run =
      frame_prefix_trace ++ frame_segment_trace ++ frame_suffix_trace;
  frame_prefix_steps :
    clight_run_star run (run_start run)
      frame_prefix_trace frame_before_clight;
  frame_segment_steps :
    clight_run_star run frame_before_clight
      frame_segment_trace frame_after_clight;
  frame_suffix_steps :
    clight_run_star run frame_after_clight
      frame_suffix_trace (run_final run);
  frame_segment_nonempty :
    frame_before_clight <> frame_after_clight \/
    frame_segment_trace <> [];
  frame_before_projection :
    project_state projection frame_before_clight = Some before;
  frame_after_projection :
    project_state projection frame_after_clight = Some after;
  frame_projected_event :
    nth_error (project_events projection run) index = Some event;
  frame_certified_occurrence :
    CertifiedStepAt initial (project_events projection run)
      (refined_final_state projection run initial certificate)
      index event before after
}.

(** The writer inventory below is deliberately broader than the historical
    bypass tags.  In particular [WriterMarioStep] includes ordinary action
    dispatch, fixed-position actions, and cutscene/spawn actions once those
    Clight calls are projected. *)
Inductive ProjectedWriterClass :=
| WriterMarioStep
| WriterPlatformDisplacement
| WriterInteractionOrObjectImpulse
| WriterExplicitWarp
| WriterLifecycleOrEntry
| WriterTargetInteraction
| WriterSaveBit
| WriterUnmodeled.

Definition writer_class_of_event (event : FrameEvent)
    : ProjectedWriterClass :=
  match event with
  | EventMarioMotion MotionPhysicsFrame _ _ => WriterMarioStep
  | EventMarioMotion MotionPlatformDisplacement _ _ =>
      WriterPlatformDisplacement
  | EventMarioMotion MotionObjectPush _ _ =>
      WriterInteractionOrObjectImpulse
  | EventMarioMotion MotionCollisionClip _ _ => WriterMarioStep
  | EventInstantWarp2To3
  | EventInstantWarp3To2 => WriterExplicitWarp
  | EventSpawnAct3 _
  | EventSpawnAct6 _
  | EventConsumeTrigger _ _ _
  | EventCollectAct3 _ _
  | EventCollectAct6 _ _ => WriterTargetInteraction
  | EventCollectOther _
  | EventSaveFileReload => WriterSaveBit
  | EventDeactivate _
  | EventReuseSlot _ _
  | EventMacroRespawn
  | EventAreaUnload
  | EventAreaReload
  | EventCollisionRefresh => WriterLifecycleOrEntry
  | EventOrdinary => WriterUnmodeled
  end.

Theorem projected_event_writer_inventory_is_total :
  forall event,
    exists class, writer_class_of_event event = class.
Proof.
  intro event. exists (writer_class_of_event event). reflexivity.
Qed.

Record FirstTargetWriterEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (target_frame : nat) : Type := {
  first_writer_frame : nat;
  first_writer_event : FrameEvent;
  first_writer_before : GameState;
  first_writer_after : GameState;
  first_writer_class : ProjectedWriterClass;
  first_writer_not_after_target :
    (first_writer_frame <= target_frame)%nat;
  first_writer_clight_frame :
    ClightFrameEvidence projection run initial certificate
      first_writer_frame first_writer_event
      first_writer_before first_writer_after;
  first_writer_class_exact :
    writer_class_of_event first_writer_event = first_writer_class
}.

(** This is the precise missing coverage theorem for the writer inventory:
    every exact first target observation must be tied to an actual Clight
    segment no later than that observation.  Unlike the old classifier, its
    witness contains both Clight endpoint states and their projections. *)
Definition FirstTargetWriterCoverageObligation
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (trace : RouteTrace) : Prop :=
  forall region target_frame target_observation,
    first_target_observation_at
      trace region target_frame target_observation ->
    exists evidence :
      FirstTargetWriterEvidence
        projection run initial certificate target_frame,
      True.

(** The object-collision pass samples Mario's collision object, whereas
    platform displacement writes MarioState first and the Mario object is
    synchronized later by Mario's object-list update.  The current
    [CollisionPhase] booleans alone do not encode that distinction.  This
    record names both values and a concrete Clight collision control point. *)
Record MarioStateObjectCollisionSamplingEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    : Type := {
  sampling_frame : nat;
  sampling_before : GameState;
  sampling_after_platform : GameState;
  sampling_platform_from : MarioKinematics;
  sampling_platform_to : MarioKinematics;
  sampling_platform_clight_frame :
    ClightFrameEvidence projection run initial certificate sampling_frame
      (EventMarioMotion MotionPlatformDisplacement
        sampling_platform_from sampling_platform_to)
      sampling_before sampling_after_platform;
  sampling_collision_clight_state : Clight.state;
  sampling_collision_prefix_trace : Events.trace;
  sampling_collision_suffix_trace : Events.trace;
  sampling_collision_trace_decomposition :
    run_trace run =
      sampling_collision_prefix_trace ++ sampling_collision_suffix_trace;
  sampling_collision_reached :
    clight_run_star run (run_start run)
      sampling_collision_prefix_trace sampling_collision_clight_state;
  sampling_collision_reaches_final :
    clight_run_star run sampling_collision_clight_state
      sampling_collision_suffix_trace (run_final run);
  sampling_collision_object : ObjectState;
  sampling_collision_phase : CollisionPhase;
  sampling_collision_observed :
    In {| observed_object := sampling_collision_object;
          observed_phase := sampling_collision_phase |}
      (project_collision_observations projection run);
  sampling_phase_after_platform :
    collision_after_platform_displacement sampling_collision_phase = true;
  sampling_phase_before_behaviors :
    collision_before_behavior_update sampling_collision_phase = true;
  sampling_mario_state_after_platform :
    mario_position (state_mario_kinematics sampling_after_platform) =
      mario_position sampling_platform_to;
  sampling_mario_object_uses_pre_displacement_position :
    collision_mario_position sampling_collision_phase =
      mario_position sampling_platform_from
}.

Theorem one_event_slot_cannot_encode_platform_and_act3_collection :
  forall events index from to star phase,
    nth_error events index =
      Some (EventMarioMotion MotionPlatformDisplacement from to) ->
    nth_error events index = Some (EventCollectAct3 star phase) ->
    False.
Proof.
  intros events index from to star phase Hplatform Htarget.
  rewrite Hplatform in Htarget. discriminate.
Qed.

Theorem one_event_slot_cannot_encode_platform_and_upper_consumption :
  forall events index from to trigger_object phase,
    nth_error events index =
      Some (EventMarioMotion MotionPlatformDisplacement from to) ->
    nth_error events index =
      Some (EventConsumeTrigger TriggerUpper trigger_object phase) ->
    False.
Proof.
  intros events index from to trigger_object phase Hplatform Htarget.
  rewrite Hplatform in Htarget. discriminate.
Qed.

(** * Conditional JP Area-1 pyramid-top stale-pointer prelude

    The stock area script places source warp node [0x1E] in Area 1 at
    [(-2048.0f, 768.0f, -1024.0f)] and destination node [0x14] in Area 2 at
    [(0.0f, 5500.0f, 256.0f)].  The current source-node position is projected
    separately because a warp-to-top construction may relocate node [0x1E].
    Consequently, capture of an object-owned
    pyramid-top floor, area unload, and optional pool-slot reuse cannot be
    predecessor frames of an execution whose initial state is already a clean
    Area-2 upper entry.  They belong to a separate actual Clight prelude whose
    final Clight state is the clean entry run's start state.

    The records below are conditional evidence types.  They do not establish
    that any of the three coincidence mechanisms is reachable.  In particular,
    the clone constructor does not assume that ordinary object cloning
    preserves collision; inhabiting [ObjectOwnedArea1UpperSourceWarpFloorEvidence]
    still requires an active Area-1 object to own Mario's projected floor. *)

Definition ssl_area1_id : Int.int := Int.repr 1.

Definition area1_upper_source_warp_node : Int.int := Int.repr 30. (* 0x1E *)

Definition area1_upper_source_warp_position : Vec3f :=
  {| vec_x := f32_bits 3305111552;        (* -2048.0f *)
     vec_y := f32_bits 1145044992;        (*   768.0f *)
     vec_z := f32_bits 3296722944 |}.     (* -1024.0f *)

Inductive UpperWarpTopCoincidenceMechanism :=
| Area1SourceWarpLoadsOnPyramidTop
| PyramidTopTransportedToArea1SourceWarp
| CollisionPreservingPyramidTopCloneAtUpperWarp.

Definition upper_warp_top_mechanism_position_valid
    (mechanism : UpperWarpTopCoincidenceMechanism)
    (current_node_position : Vec3f) : Prop :=
  match mechanism with
  | Area1SourceWarpLoadsOnPyramidTop =>
      True
  | PyramidTopTransportedToArea1SourceWarp =>
      current_node_position = area1_upper_source_warp_position
  | CollisionPreservingPyramidTopCloneAtUpperWarp =>
      current_node_position = area1_upper_source_warp_position
  end.

(** This is a projection witness, not a reachability theorem.  A concrete
    Clight/collision refinement must recover the source warp node and dynamic
    surface owner from memory and justify every field below. *)
Record ObjectOwnedArea1UpperSourceWarpFloorEvidence
    (state : GameState) : Type := {
  area1_upper_top_mechanism : UpperWarpTopCoincidenceMechanism;
  area1_upper_source_node : Int.int;
  area1_upper_current_node_position : Vec3f;
  area1_upper_top_object : ObjectState;
  area1_upper_floor_surface : SurfaceRef;
  area1_upper_floor_owner_ref : ObjectRef;
  area1_upper_source_is_jp :
    state_version state = VersionJP;
  area1_upper_source_is_area1 :
    state_area state = ssl_area1_id;
  area1_upper_source_node_is_1e :
    area1_upper_source_node = area1_upper_source_warp_node;
  area1_upper_source_position_coincides :
    mario_position (state_mario_kinematics state) =
      area1_upper_current_node_position;
  area1_upper_mechanism_position_is_valid :
    upper_warp_top_mechanism_position_valid
      area1_upper_top_mechanism area1_upper_current_node_position;
  area1_upper_floor_is_mario_floor :
    mario_floor (state_mario_kinematics state) =
      area1_upper_floor_surface;
  area1_upper_floor_owner_is_top :
    object_ref_equal area1_upper_floor_owner_ref
      (object_ref area1_upper_top_object);
  area1_upper_top_is_in_pool :
    In area1_upper_top_object (state_object_pool state);
  area1_upper_top_is_active :
    object_active area1_upper_top_object = true;
  area1_upper_top_is_area1 :
    object_area area1_upper_top_object = ssl_area1_id
}.

(** Exact-width payload read by [apply_platform_displacement].  Positions and
    velocities are CompCert binary32 values.  The source object fields for
    face angle and angular velocity are signed 32-bit slots; assignments to
    the local [Vec3s rotation] truncate them with [Int.sign_ext 16].  Keeping
    both raw slots and the truncation functions makes the C integer behavior
    explicit and avoids a mathematical-real displacement model. *)
Record PlatformDisplacementRawPayload : Type := {
  platform_payload_position : Vec3f;
  platform_payload_velocity : Vec3f;
  platform_payload_face_angle_pitch_s32 : Int.int;
  platform_payload_face_angle_yaw_s32 : Int.int;
  platform_payload_face_angle_roll_s32 : Int.int;
  platform_payload_angle_velocity_pitch_s32 : Int.int;
  platform_payload_angle_velocity_yaw_s32 : Int.int;
  platform_payload_angle_velocity_roll_s32 : Int.int
}.

Definition platform_payload_rotation_pitch_s16
    (payload : PlatformDisplacementRawPayload) : Int.int :=
  Int.sign_ext 16 (platform_payload_angle_velocity_pitch_s32 payload).

Definition platform_payload_rotation_yaw_s16
    (payload : PlatformDisplacementRawPayload) : Int.int :=
  Int.sign_ext 16 (platform_payload_angle_velocity_yaw_s32 payload).

Definition platform_payload_rotation_roll_s16
    (payload : PlatformDisplacementRawPayload) : Int.int :=
  Int.sign_ext 16 (platform_payload_angle_velocity_roll_s32 payload).

Definition platform_payload_previous_face_pitch_s16
    (payload : PlatformDisplacementRawPayload) : Int.int :=
  Int.sign_ext 16
    (Int.sub
      (platform_payload_face_angle_pitch_s32 payload)
      (platform_payload_angle_velocity_pitch_s32 payload)).

Definition platform_payload_previous_face_yaw_s16
    (payload : PlatformDisplacementRawPayload) : Int.int :=
  Int.sign_ext 16
    (Int.sub
      (platform_payload_face_angle_yaw_s32 payload)
      (platform_payload_angle_velocity_yaw_s32 payload)).

Definition platform_payload_previous_face_roll_s16
    (payload : PlatformDisplacementRawPayload) : Int.int :=
  Int.sign_ext 16
    (Int.sub
      (platform_payload_face_angle_roll_s32 payload)
      (platform_payload_angle_velocity_roll_s32 payload)).

Definition platform_payload_current_face_pitch_s16
    (payload : PlatformDisplacementRawPayload) : Int.int :=
  Int.sign_ext 16 (platform_payload_face_angle_pitch_s32 payload).

Definition platform_payload_current_face_yaw_s16
    (payload : PlatformDisplacementRawPayload) : Int.int :=
  Int.sign_ext 16 (platform_payload_face_angle_yaw_s32 payload).

Definition platform_payload_current_face_roll_s16
    (payload : PlatformDisplacementRawPayload) : Int.int :=
  Int.sign_ext 16 (platform_payload_face_angle_roll_s32 payload).

Definition clight_state_memory (state : Clight.state) : Mem.mem :=
  match state with
  | Clight.State _ _ _ _ _ memory => memory
  | Clight.Callstate _ _ _ memory => memory
  | Clight.Returnstate _ _ memory => memory
  end.

(** Concrete memory-load obligation for the fields read by
    [platform_displacement.c].  The byte offsets are the object layout offsets
    in [object_fields.h]: position 0xA0, velocity 0xAC, face angle 0xD0, and
    angle velocity 0x114.  This record is intentionally not constructed here;
    a source-backed witness must exhibit the actual linked-program blocks and
    successful CompCert loads. *)
Record PlatformDisplacementPayloadMemoryWitness
    (program : Clight.program)
    (state : Clight.state)
    (payload : PlatformDisplacementRawPayload) : Type := {
  platform_payload_global_block : Values.block;
  platform_payload_object_block : Values.block;
  platform_payload_object_offset : Ptrofs.int;
  platform_payload_global_symbol :
    Genv.find_symbol (Clight.globalenv program)
      jp_platform_displacement._gMarioPlatform =
      Some platform_payload_global_block;
  platform_payload_global_pointer_load :
    Mem.load AST.Mptr (clight_state_memory state)
      platform_payload_global_block 0 =
      Some
        (Values.Vptr
          platform_payload_object_block platform_payload_object_offset);
  platform_payload_pos_x_load :
    Mem.load AST.Mfloat32 (clight_state_memory state)
      platform_payload_object_block
      (Ptrofs.unsigned
        (Ptrofs.add platform_payload_object_offset (Ptrofs.repr 160))) =
      Some (Values.Vsingle (vec_x (platform_payload_position payload)));
  platform_payload_pos_y_load :
    Mem.load AST.Mfloat32 (clight_state_memory state)
      platform_payload_object_block
      (Ptrofs.unsigned
        (Ptrofs.add platform_payload_object_offset (Ptrofs.repr 164))) =
      Some (Values.Vsingle (vec_y (platform_payload_position payload)));
  platform_payload_pos_z_load :
    Mem.load AST.Mfloat32 (clight_state_memory state)
      platform_payload_object_block
      (Ptrofs.unsigned
        (Ptrofs.add platform_payload_object_offset (Ptrofs.repr 168))) =
      Some (Values.Vsingle (vec_z (platform_payload_position payload)));
  platform_payload_vel_x_load :
    Mem.load AST.Mfloat32 (clight_state_memory state)
      platform_payload_object_block
      (Ptrofs.unsigned
        (Ptrofs.add platform_payload_object_offset (Ptrofs.repr 172))) =
      Some (Values.Vsingle (vec_x (platform_payload_velocity payload)));
  platform_payload_vel_y_load :
    Mem.load AST.Mfloat32 (clight_state_memory state)
      platform_payload_object_block
      (Ptrofs.unsigned
        (Ptrofs.add platform_payload_object_offset (Ptrofs.repr 176))) =
      Some (Values.Vsingle (vec_y (platform_payload_velocity payload)));
  platform_payload_vel_z_load :
    Mem.load AST.Mfloat32 (clight_state_memory state)
      platform_payload_object_block
      (Ptrofs.unsigned
        (Ptrofs.add platform_payload_object_offset (Ptrofs.repr 180))) =
      Some (Values.Vsingle (vec_z (platform_payload_velocity payload)));
  platform_payload_face_pitch_load :
    Mem.load AST.Mint32 (clight_state_memory state)
      platform_payload_object_block
      (Ptrofs.unsigned
        (Ptrofs.add platform_payload_object_offset (Ptrofs.repr 208))) =
      Some
        (Values.Vint
          (platform_payload_face_angle_pitch_s32 payload));
  platform_payload_face_yaw_load :
    Mem.load AST.Mint32 (clight_state_memory state)
      platform_payload_object_block
      (Ptrofs.unsigned
        (Ptrofs.add platform_payload_object_offset (Ptrofs.repr 212))) =
      Some
        (Values.Vint
          (platform_payload_face_angle_yaw_s32 payload));
  platform_payload_face_roll_load :
    Mem.load AST.Mint32 (clight_state_memory state)
      platform_payload_object_block
      (Ptrofs.unsigned
        (Ptrofs.add platform_payload_object_offset (Ptrofs.repr 216))) =
      Some
        (Values.Vint
          (platform_payload_face_angle_roll_s32 payload));
  platform_payload_angle_velocity_pitch_load :
    Mem.load AST.Mint32 (clight_state_memory state)
      platform_payload_object_block
      (Ptrofs.unsigned
        (Ptrofs.add platform_payload_object_offset (Ptrofs.repr 276))) =
      Some
        (Values.Vint
          (platform_payload_angle_velocity_pitch_s32 payload));
  platform_payload_angle_velocity_yaw_load :
    Mem.load AST.Mint32 (clight_state_memory state)
      platform_payload_object_block
      (Ptrofs.unsigned
        (Ptrofs.add platform_payload_object_offset (Ptrofs.repr 280))) =
      Some
        (Values.Vint
          (platform_payload_angle_velocity_yaw_s32 payload));
  platform_payload_angle_velocity_roll_load :
    Mem.load AST.Mint32 (clight_state_memory state)
      platform_payload_object_block
      (Ptrofs.unsigned
        (Ptrofs.add platform_payload_object_offset (Ptrofs.repr 284))) =
      Some
        (Values.Vint
          (platform_payload_angle_velocity_roll_s32 payload))
}.

(** The equality side of the memory projection.  It ties the concrete
    [gMarioPlatform] load and fixture fields above to the same abstract state
    whose raw platform slot/epoch is used by the route proof. *)
Record PlatformDisplacementPayloadProjectionEvidence
    (projection : ClightObservationProjection)
    (state : Clight.state)
    (abstract_state : GameState)
    (platform : RawPlatformPointer)
    (payload : PlatformDisplacementRawPayload) : Type := {
  displacement_payload_projected_state :
    project_state projection state = Some abstract_state;
  displacement_payload_projected_platform :
    state_mario_platform abstract_state = Some platform;
  displacement_payload_memory_witness :
    PlatformDisplacementPayloadMemoryWitness
      (projection_program projection) state payload
}.

Record UpperWarpTopPreludeCaptureEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    : Type := {
  prelude_top_capture_frame : nat;
  prelude_top_capture_event : FrameEvent;
  prelude_top_capture_before : GameState;
  prelude_top_capture_state : GameState;
  prelude_top_capture_segment :
    ClightFrameEvidence projection run initial certificate
      prelude_top_capture_frame prelude_top_capture_event
      prelude_top_capture_before prelude_top_capture_state;
  prelude_top_floor_coincidence :
    ObjectOwnedArea1UpperSourceWarpFloorEvidence prelude_top_capture_state
}.

Record UpperWarpTopPreludeUnloadRetentionEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    : Type := {
  prelude_top_capture_evidence :
    UpperWarpTopPreludeCaptureEvidence
      projection run initial certificate;
  prelude_top_unload_frame : nat;
  prelude_top_pre_unload_state : GameState;
  prelude_top_unloaded_state : GameState;
  prelude_top_retained_platform : RawPlatformPointer;
  prelude_top_unloaded_slot_object : ObjectState;
  prelude_top_unload_follows_capture :
    (prelude_top_capture_frame _ _ _ _ prelude_top_capture_evidence <
      prelude_top_unload_frame)%nat;
  prelude_top_unload_segment :
    ClightFrameEvidence projection run initial certificate
      prelude_top_unload_frame EventAreaUnload
      prelude_top_pre_unload_state prelude_top_unloaded_state;
  prelude_top_platform_captured_at_source :
    state_mario_platform
      (prelude_top_capture_state _ _ _ _ prelude_top_capture_evidence) =
      Some prelude_top_retained_platform;
  prelude_top_platform_retained_before_unload :
    state_mario_platform prelude_top_pre_unload_state =
      Some prelude_top_retained_platform;
  prelude_top_platform_retained_after_unload :
    state_mario_platform prelude_top_unloaded_state =
      Some prelude_top_retained_platform;
  prelude_top_captured_ref_is_live_top :
    object_ref_equal
      (captured_platform_ref prelude_top_retained_platform)
      (object_ref
        (area1_upper_top_object _
          (prelude_top_floor_coincidence _ _ _ _
            prelude_top_capture_evidence)));
  prelude_top_unloaded_slot_lookup :
    nth_error (state_object_pool prelude_top_unloaded_state)
      (platform_slot prelude_top_retained_platform) =
      Some prelude_top_unloaded_slot_object;
  prelude_top_unloaded_slot_number :
    object_slot (object_ref prelude_top_unloaded_slot_object) =
      platform_slot prelude_top_retained_platform;
  prelude_top_unloaded_is_inactive :
    object_active prelude_top_unloaded_slot_object = false;
  prelude_top_unloaded_same_epoch :
    object_epoch (object_ref prelude_top_unloaded_slot_object) =
      platform_captured_epoch prelude_top_retained_platform
}.

(** Reuse is a separate actual Clight/event segment.  This prevents a proof
    from silently treating slot reuse as part of unload or assuming that a
    cloned top retains its collision surfaces. *)
Record UpperWarpTopPreludeReuseEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    : Type := {
  prelude_top_unload_retention :
    UpperWarpTopPreludeUnloadRetentionEvidence
      projection run initial certificate;
  prelude_top_reuse_frame : nat;
  prelude_top_pre_reuse_state : GameState;
  prelude_top_reused_state : GameState;
  prelude_top_reused_slot_object : ObjectState;
  prelude_top_reuse_follows_unload :
    (prelude_top_unload_frame _ _ _ _ prelude_top_unload_retention <
      prelude_top_reuse_frame)%nat;
  prelude_top_pre_reuse_slot_lookup :
    nth_error (state_object_pool prelude_top_pre_reuse_state)
      (platform_slot
        (prelude_top_retained_platform
          _ _ _ _ prelude_top_unload_retention)) =
      Some
        (prelude_top_unloaded_slot_object
          _ _ _ _ prelude_top_unload_retention);
  prelude_top_reuse_segment :
    ClightFrameEvidence projection run initial certificate
      prelude_top_reuse_frame
      (EventReuseSlot
        (prelude_top_unloaded_slot_object
          _ _ _ _ prelude_top_unload_retention)
        prelude_top_reused_slot_object)
      prelude_top_pre_reuse_state prelude_top_reused_state;
  prelude_top_pointer_retained_before_reuse :
    state_mario_platform prelude_top_pre_reuse_state =
      Some
        (prelude_top_retained_platform
          _ _ _ _ prelude_top_unload_retention);
  prelude_top_pointer_retained_after_reuse :
    state_mario_platform prelude_top_reused_state =
      Some
        (prelude_top_retained_platform
          _ _ _ _ prelude_top_unload_retention);
  prelude_top_reused_slot_lookup :
    nth_error (state_object_pool prelude_top_reused_state)
      (platform_slot
        (prelude_top_retained_platform
          _ _ _ _ prelude_top_unload_retention)) =
      Some prelude_top_reused_slot_object;
  prelude_top_reused_slot_number :
    object_slot (object_ref prelude_top_reused_slot_object) =
      platform_slot
        (prelude_top_retained_platform
          _ _ _ _ prelude_top_unload_retention);
  prelude_top_reuse_is_fresh :
    fresh_slot_reuse
      (prelude_top_unloaded_slot_object
        _ _ _ _ prelude_top_unload_retention)
      prelude_top_reused_slot_object
}.

Inductive UpperWarpStaleTopPreludeCandidateEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    : Type :=
| PreludeRetainedInactiveTopCandidate :
    UpperWarpTopPreludeUnloadRetentionEvidence
      projection run initial certificate ->
    UpperWarpStaleTopPreludeCandidateEvidence
      projection run initial certificate
| PreludeReusedTopSlotCandidate :
    UpperWarpTopPreludeReuseEvidence projection run initial certificate ->
    UpperWarpStaleTopPreludeCandidateEvidence
      projection run initial certificate.

Definition prelude_candidate_platform
    {projection : ClightObservationProjection}
    {run : ImportedClightRun}
    {initial : GameState}
    {certificate : ClightFrameRefinementCertificate projection run initial}
    (candidate : UpperWarpStaleTopPreludeCandidateEvidence
      projection run initial certificate) : RawPlatformPointer.
Proof.
  destruct candidate as [retention | reuse].
  - exact (prelude_top_retained_platform _ _ _ _ retention).
  - exact (prelude_top_retained_platform _ _ _ _
      (prelude_top_unload_retention _ _ _ _ reuse)).
Defined.

Theorem prelude_retained_inactive_top_slot_is_a_raw_platform_case :
  forall projection run initial certificate
      (evidence : UpperWarpTopPreludeUnloadRetentionEvidence
        projection run initial certificate),
    RawPlatformSlotCase
      (state_object_pool
        (prelude_top_unloaded_state _ _ _ _ evidence))
      (prelude_top_retained_platform _ _ _ _ evidence).
Proof.
  intros projection run initial certificate evidence.
  econstructor 2.
  - exact (prelude_top_unloaded_slot_lookup _ _ _ _ evidence).
  - exact (prelude_top_unloaded_slot_number _ _ _ _ evidence).
  - exact (prelude_top_unloaded_is_inactive _ _ _ _ evidence).
  - exact (prelude_top_unloaded_same_epoch _ _ _ _ evidence).
Qed.

Theorem prelude_reused_top_slot_is_a_raw_platform_case :
  forall projection run initial certificate
      (evidence : UpperWarpTopPreludeReuseEvidence
        projection run initial certificate),
    RawPlatformSlotCase
      (state_object_pool
        (prelude_top_reused_state _ _ _ _ evidence))
      (prelude_top_retained_platform _ _ _ _
        (prelude_top_unload_retention _ _ _ _ evidence)).
Proof.
  intros projection run initial certificate evidence.
  econstructor 3.
  - exact (prelude_top_reused_slot_lookup _ _ _ _ evidence).
  - exact (prelude_top_reused_slot_number _ _ _ _ evidence).
  - intro Hequal.
    pose proof (prelude_top_reuse_is_fresh _ _ _ _ evidence)
      as [_ Hfresh_epoch].
    pose proof (prelude_top_unloaded_same_epoch _ _ _ _
      (prelude_top_unload_retention _ _ _ _ evidence)) as Hsame_epoch.
    lia.
Qed.

Record UpperWarpTopPreludeToCleanEntryBridge
    (prelude_projection : ClightObservationProjection)
    (prelude_run : ImportedClightRun)
    (prelude_initial : GameState)
    (prelude_certificate :
      ClightFrameRefinementCertificate
        prelude_projection prelude_run prelude_initial)
    (entry_projection : ClightObservationProjection)
    (entry_run : ImportedClightRun)
    (entry_initial : GameState)
    (entry_certificate :
      ClightFrameRefinementCertificate
        entry_projection entry_run entry_initial)
    : Type := {
  prelude_entry_candidate :
    UpperWarpStaleTopPreludeCandidateEvidence
      prelude_projection prelude_run prelude_initial prelude_certificate;
  prelude_entry_same_version :
    projection_version prelude_projection =
      projection_version entry_projection;
  prelude_entry_same_program :
    projection_program prelude_projection =
      projection_program entry_projection;
  prelude_entry_clight_boundary :
    run_final prelude_run = run_start entry_run;
  prelude_entry_abstract_boundary :
    refined_final_state
      prelude_projection prelude_run prelude_initial prelude_certificate =
      entry_initial;
  prelude_entry_clean :
    CleanPyramidEntry entry_initial;
  prelude_entry_is_jp :
    state_version entry_initial = VersionJP;
  prelude_entry_is_upper :
    state_entrance entry_initial = UpperEntrance;
  prelude_entry_no_a_edges :
    fewer_than_one_a_press (project_inputs entry_projection entry_run);
  prelude_entry_platform_retained :
    state_mario_platform entry_initial =
      Some (prelude_candidate_platform prelude_entry_candidate);
  prelude_entry_platform_payload :
    PlatformDisplacementRawPayload;
  prelude_entry_payload_at_prelude_final :
    PlatformDisplacementPayloadProjectionEvidence
      prelude_projection (run_final prelude_run)
      (refined_final_state
        prelude_projection prelude_run prelude_initial prelude_certificate)
      (prelude_candidate_platform prelude_entry_candidate)
      prelude_entry_platform_payload;
  prelude_entry_payload_at_entry_start :
    PlatformDisplacementPayloadProjectionEvidence
      entry_projection (run_start entry_run) entry_initial
      (prelude_candidate_platform prelude_entry_candidate)
      prelude_entry_platform_payload
}.

Theorem prelude_bridge_enters_clean_jp_upper_with_retained_platform :
  forall prelude_projection prelude_run prelude_initial prelude_certificate
      entry_projection entry_run entry_initial entry_certificate
      (bridge : UpperWarpTopPreludeToCleanEntryBridge
        prelude_projection prelude_run prelude_initial prelude_certificate
        entry_projection entry_run entry_initial entry_certificate),
    CleanPyramidEntry entry_initial /\
    state_version entry_initial = VersionJP /\
    state_entrance entry_initial = UpperEntrance /\
    state_mario_platform entry_initial =
      Some
        (prelude_candidate_platform
          (prelude_entry_candidate _ _ _ _ _ _ _ _ bridge)) /\
    valid_platform_state entry_initial.
Proof.
  intros prelude_projection prelude_run prelude_initial prelude_certificate
    entry_projection entry_run entry_initial entry_certificate bridge.
  pose proof (prelude_entry_clean _ _ _ _ _ _ _ _ bridge) as Hclean.
  split; [exact Hclean |].
  split; [exact (prelude_entry_is_jp _ _ _ _ _ _ _ _ bridge) |].
  split; [exact (prelude_entry_is_upper _ _ _ _ _ _ _ _ bridge) |].
  split.
  - exact (prelude_entry_platform_retained _ _ _ _ _ _ _ _ bridge).
  - exact (clean_platform entry_initial Hclean).
Qed.

Definition prelude_bridge_exposes_exact_platform_payload :
  forall prelude_projection prelude_run prelude_initial prelude_certificate
      entry_projection entry_run entry_initial entry_certificate
      (bridge : UpperWarpTopPreludeToCleanEntryBridge
        prelude_projection prelude_run prelude_initial prelude_certificate
        entry_projection entry_run entry_initial entry_certificate),
    { payload : PlatformDisplacementRawPayload &
      (PlatformDisplacementPayloadProjectionEvidence
         prelude_projection (run_final prelude_run)
         (refined_final_state
           prelude_projection prelude_run prelude_initial prelude_certificate)
         (prelude_candidate_platform
           (prelude_entry_candidate _ _ _ _ _ _ _ _ bridge))
         payload *
       PlatformDisplacementPayloadProjectionEvidence
         entry_projection (run_start entry_run) entry_initial
         (prelude_candidate_platform
           (prelude_entry_candidate _ _ _ _ _ _ _ _ bridge))
         payload)%type }.
Proof.
  intros prelude_projection prelude_run prelude_initial prelude_certificate
    entry_projection entry_run entry_initial entry_certificate bridge.
  exists (prelude_entry_platform_payload _ _ _ _ _ _ _ _ bridge).
  split.
  - exact (prelude_entry_payload_at_prelude_final
      _ _ _ _ _ _ _ _ bridge).
  - exact (prelude_entry_payload_at_entry_start
      _ _ _ _ _ _ _ _ bridge).
Defined.

Inductive StepBeforeTarget
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (target_frame : nat) (event : FrameEvent) : Prop :=
| StepBeforeTargetEvidence :
    forall index before after,
      (index < target_frame)%nat ->
      ClightFrameEvidence projection run initial certificate
        index event before after ->
      StepBeforeTarget projection run initial certificate
        target_frame event.

(** A cut is represented by concrete collision support identifiers, dynamic
    object identities, and finite Float32 open cells.  This deliberately
    avoids a height-only predicate: the upper trigger is below the nominal
    pole top, and the elevator cage is a moving component.  A future
    mesh-extraction theorem must validate the particular lists/cells used for
    US and JP; this file does not assert that an arbitrary descriptor is a
    separator. *)
Record AxisAlignedOpenCell := {
  open_cell_min : Vec3f;
  open_cell_max : Vec3f
}.

Definition f32_closed_between
    (lower value upper : float32) : bool :=
  andb (Float32.cmp Ceq value value)
    (andb
      (negb (Float32.cmp Clt value lower))
      (negb (Float32.cmp Clt upper value))).

Definition position_in_open_cell
    (position : Vec3f) (cell : AxisAlignedOpenCell) : bool :=
  andb
    (f32_closed_between
      (vec_x (open_cell_min cell)) (vec_x position)
      (vec_x (open_cell_max cell)))
    (andb
      (f32_closed_between
        (vec_y (open_cell_min cell)) (vec_y position)
        (vec_y (open_cell_max cell)))
      (f32_closed_between
        (vec_z (open_cell_min cell)) (vec_z position)
        (vec_z (open_cell_max cell)))).

Record CollisionSupportCut := {
  cut_entrance : PyramidEntrance;
  cut_source_static_supports : list SurfaceRef;
  cut_target_static_supports : list SurfaceRef;
  cut_source_dynamic_supports : list ObjectRef;
  cut_target_dynamic_supports : list ObjectRef;
  cut_source_open_cells : list AxisAlignedOpenCell;
  cut_target_open_cells : list AxisAlignedOpenCell
}.

Inductive StateOnCollisionSide
    (static_supports : list SurfaceRef)
    (dynamic_supports : list ObjectRef)
    (open_cells : list AxisAlignedOpenCell)
    (state : GameState) : Prop :=
| OnStaticCollisionSupport :
    In (mario_floor (state_mario_kinematics state)) static_supports ->
    StateOnCollisionSide static_supports dynamic_supports open_cells state
| OnDynamicCollisionSupport :
    forall platform,
      state_mario_platform state = Some platform ->
      In (captured_platform_ref platform) dynamic_supports ->
      StateOnCollisionSide static_supports dynamic_supports open_cells state
| InCollisionOpenCell :
    forall cell,
      In cell open_cells ->
      position_in_open_cell
        (mario_position (state_mario_kinematics state)) cell = true ->
      StateOnCollisionSide static_supports dynamic_supports open_cells state.

Definition StateOnCutSourceSide
    (cut : CollisionSupportCut) (state : GameState) : Prop :=
  StateOnCollisionSide
    (cut_source_static_supports cut)
    (cut_source_dynamic_supports cut)
    (cut_source_open_cells cut) state.

Definition StateOnCutTargetSide
    (cut : CollisionSupportCut) (state : GameState) : Prop :=
  StateOnCollisionSide
    (cut_target_static_supports cut)
    (cut_target_dynamic_supports cut)
    (cut_target_open_cells cut) state.

Record MotionCrossesCollisionCutEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (target_frame : nat) (kind : MarioMotionKind) : Type := {
  motion_cut : CollisionSupportCut;
  motion_crossing_frame : nat;
  motion_crossing_before : GameState;
  motion_crossing_after : GameState;
  motion_crossing_from : MarioKinematics;
  motion_crossing_to : MarioKinematics;
  motion_crossing_precedes_target :
    (motion_crossing_frame < target_frame)%nat;
  motion_crossing_clight_frame :
    ClightFrameEvidence projection run initial certificate
      motion_crossing_frame
      (EventMarioMotion kind motion_crossing_from motion_crossing_to)
      motion_crossing_before motion_crossing_after;
  motion_cut_matches_entry :
    cut_entrance motion_cut = state_entrance initial;
  motion_crossing_source_side :
    StateOnCutSourceSide motion_cut motion_crossing_before;
  motion_crossing_target_side :
    StateOnCutTargetSide motion_cut motion_crossing_after
}.

(** The displacement and cut crossing are deliberately separate from the
    unload/reuse witness.  Existence of this record is the narrow remaining
    reachability/arithmetic obligation for the stale-top candidate. *)
Record UpperWarpStaleTopConditionalPathEvidence
    (prelude_projection : ClightObservationProjection)
    (prelude_run : ImportedClightRun)
    (prelude_initial : GameState)
    (prelude_certificate :
      ClightFrameRefinementCertificate
        prelude_projection prelude_run prelude_initial)
    (entry_projection : ClightObservationProjection)
    (entry_run : ImportedClightRun)
    (entry_initial : GameState)
    (entry_certificate :
      ClightFrameRefinementCertificate
        entry_projection entry_run entry_initial)
    (target_frame : nat) : Type := {
  upper_stale_top_bridge :
    UpperWarpTopPreludeToCleanEntryBridge
      prelude_projection prelude_run prelude_initial prelude_certificate
      entry_projection entry_run entry_initial entry_certificate;
  upper_stale_top_cut_crossing :
    MotionCrossesCollisionCutEvidence
      entry_projection entry_run entry_initial entry_certificate
      target_frame MotionPlatformDisplacement
}.

(** * Evidence-bearing bypass classes *)

Inductive ConcreteBypassClass :=
| BypassOrdinaryMarioMotionOrStaticGeometry
| BypassPlatformDisplacement
| BypassObjectPushOrMovingGeometry
| BypassWarpOrArea3
| BypassCollisionClipOrTunnel
| BypassParallelUniverseOrOutOfBounds
| BypassTargetRelocationOrSubstitution
| BypassMacroOrLifecycleAnomaly
| BypassSaveReloadOrCorruption
| BypassMemoryOrUndefinedBehavior.

Definition upper_tag_of (class : ConcreteBypassClass)
    : option UpperBypassWitness :=
  match class with
  | BypassOrdinaryMarioMotionOrStaticGeometry => None
  | BypassPlatformDisplacement => Some UpperPlatformDisplacementBypass
  | BypassObjectPushOrMovingGeometry =>
      Some UpperObjectPushOrMovingGeometryBypass
  | BypassWarpOrArea3 => Some UpperWarpOrArea3Bypass
  | BypassCollisionClipOrTunnel => Some UpperCollisionClipOrTunnelBypass
  | BypassParallelUniverseOrOutOfBounds =>
      Some UpperParallelUniverseOrOutOfBoundsBypass
  | BypassTargetRelocationOrSubstitution =>
      Some UpperTargetRelocationOrSubstitutionBypass
  | BypassMacroOrLifecycleAnomaly =>
      Some UpperMacroOrLifecycleAnomalyBypass
  | BypassSaveReloadOrCorruption =>
      Some UpperSaveReloadOrCorruptionBypass
  | BypassMemoryOrUndefinedBehavior =>
      Some UpperMemoryOrUndefinedBehaviorBypass
  end.

Definition lower_tag_of (class : ConcreteBypassClass)
    : option LowerBypassWitness :=
  match class with
  | BypassOrdinaryMarioMotionOrStaticGeometry => None
  | BypassPlatformDisplacement => Some LowerPlatformDisplacementBypass
  | BypassObjectPushOrMovingGeometry =>
      Some LowerObjectPushOrMovingGeometryBypass
  | BypassWarpOrArea3 => Some LowerWarpOrArea3Bypass
  | BypassCollisionClipOrTunnel => Some LowerCollisionClipOrTunnelBypass
  | BypassParallelUniverseOrOutOfBounds =>
      Some LowerParallelUniverseOrOutOfBoundsBypass
  | BypassTargetRelocationOrSubstitution =>
      Some LowerTargetRelocationOrSubstitutionBypass
  | BypassMacroOrLifecycleAnomaly =>
      Some LowerMacroOrLifecycleAnomalyBypass
  | BypassSaveReloadOrCorruption =>
      Some LowerSaveReloadOrCorruptionBypass
  | BypassMemoryOrUndefinedBehavior =>
      Some LowerMemoryOrUndefinedBehaviorBypass
  end.

Definition bypass_tag_precedes_target
    (trace : RouteTrace) (entrance : PyramidEntrance)
    (class : ConcreteBypassClass) (region : TargetRouteRegion)
    (target_frame target_observation : nat) : Prop :=
  match entrance with
  | UpperEntrance =>
      match upper_tag_of class with
      | Some tag =>
          upper_bypass_precedes_exact_target trace tag
            region target_frame target_observation
      | None => True
      end
  | LowerEntrance =>
      match lower_tag_of class with
      | Some tag =>
          lower_bypass_precedes_exact_target trace tag
            region target_frame target_observation
      | None => True
      end
  end.

(** The area-2/area-3 instant warp is a candidate bypass only if the warp
    itself changes the projected Mario position.  Merely observing the
    ordinary zero-offset area change is not classified as a bypass. *)
Inductive DirectWarpDisplacementEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (target_frame : nat) : Prop :=
| DirectWarp23Displacement :
    forall cut index before after,
      (index < target_frame)%nat ->
      ClightFrameEvidence projection run initial certificate index
        EventInstantWarp2To3 before after ->
      cut_entrance cut = state_entrance initial ->
      StateOnCutSourceSide cut before ->
      StateOnCutTargetSide cut after ->
      mario_position (state_mario_kinematics after) <>
        mario_position (state_mario_kinematics before) ->
      DirectWarpDisplacementEvidence
        projection run initial certificate target_frame
| DirectWarp32Displacement :
    forall cut index before after,
      (index < target_frame)%nat ->
      ClightFrameEvidence projection run initial certificate index
        EventInstantWarp3To2 before after ->
      cut_entrance cut = state_entrance initial ->
      StateOnCutSourceSide cut before ->
      StateOnCutTargetSide cut after ->
      mario_position (state_mario_kinematics after) <>
        mario_position (state_mario_kinematics before) ->
      DirectWarpDisplacementEvidence
        projection run initial certificate target_frame.

Inductive HorizontalAxis := AxisX | AxisZ.

Definition horizontal_axis_coordinate
    (axis : HorizontalAxis) (kinematics : MarioKinematics) : float32 :=
  match axis with
  | AxisX => vec_x (mario_position kinematics)
  | AxisZ => vec_z (mario_position kinematics)
  end.

(** This is a checkable coordinate-alias witness, rather than an opaque
    "parallel universe happened" proposition.  The two Float32 coordinates
    must convert to the supplied signed integers, the starting coordinate is
    local, and the ending coordinate is a non-zero 65536-period alias of a
    local coordinate.  General reachability of such a witness remains open. *)
Record CoordinateAliasEscapeWitness
    (before after : MarioKinematics) : Type := {
  alias_axis : HorizontalAxis;
  alias_before_integer : Z;
  alias_after_integer : Z;
  alias_local_integer : Z;
  alias_period_index : Z;
  alias_before_exact :
    Float32.to_int (horizontal_axis_coordinate alias_axis before) =
      Some (Int.repr alias_before_integer);
  alias_before_signed :
    Int.signed (Int.repr alias_before_integer) = alias_before_integer;
  alias_after_exact :
    Float32.to_int (horizontal_axis_coordinate alias_axis after) =
      Some (Int.repr alias_after_integer);
  alias_after_signed :
    Int.signed (Int.repr alias_after_integer) = alias_after_integer;
  alias_before_local :
    legacy_pu_local_coordinate alias_before_integer;
  alias_target_local :
    legacy_pu_local_coordinate alias_local_integer;
  alias_nonzero_period :
    alias_period_index <> 0;
  alias_equation :
    alias_after_integer =
      alias_local_integer +
      legacy_pu_coordinate_period * alias_period_index;
  alias_after_nonlocal :
    ~ legacy_pu_local_coordinate alias_after_integer
}.

Record CoordinateAliasBeforeTargetEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (target_frame : nat) : Type := {
  coordinate_alias_cut : CollisionSupportCut;
  coordinate_alias_frame : nat;
  coordinate_alias_before_state : GameState;
  coordinate_alias_after_state : GameState;
  coordinate_alias_before_kinematics : MarioKinematics;
  coordinate_alias_after_kinematics : MarioKinematics;
  coordinate_alias_precedes :
    (coordinate_alias_frame < target_frame)%nat;
  coordinate_alias_clight_frame :
    ClightFrameEvidence projection run initial certificate
      coordinate_alias_frame
      (EventMarioMotion MotionPhysicsFrame
        coordinate_alias_before_kinematics
        coordinate_alias_after_kinematics)
      coordinate_alias_before_state coordinate_alias_after_state;
  coordinate_alias_cut_matches_entry :
    cut_entrance coordinate_alias_cut = state_entrance initial;
  coordinate_alias_source_side :
    StateOnCutSourceSide coordinate_alias_cut
      coordinate_alias_before_state;
  coordinate_alias_target_side :
    StateOnCutTargetSide coordinate_alias_cut
      coordinate_alias_after_state;
  coordinate_alias_payload :
    CoordinateAliasEscapeWitness
      coordinate_alias_before_kinematics
      coordinate_alias_after_kinematics
}.

(** A relocated/substituted target is an exact target event whose object
    violates the provenance predicate in its actual pre-frame state.  The
    collision observation is also tied to the run projection. *)
Inductive TargetIdentityAnomalyEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    : Prop :=
| Act3IdentityAnomaly :
    forall index before after star phase,
      ClightFrameEvidence projection run initial certificate index
        (EventCollectAct3 star phase) before after ->
      In {| observed_object := star; observed_phase := phase |}
        (project_collision_observations projection run) ->
      ~ valid_target_origin before star ->
      TargetIdentityAnomalyEvidence projection run initial certificate
| UpperTriggerIdentityAnomaly :
    forall index before after trigger_object phase,
      ClightFrameEvidence projection run initial certificate index
        (EventConsumeTrigger TriggerUpper trigger_object phase) before after ->
      In {| observed_object := trigger_object; observed_phase := phase |}
        (project_collision_observations projection run) ->
      ~ valid_hidden_trigger_object
          before TriggerUpper trigger_object ->
      TargetIdentityAnomalyEvidence projection run initial certificate.

Inductive MacroLifecycleAnomalyEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    : Prop :=
| ConsumedTriggerLifecycleAnomaly :
    forall index before after trigger trigger_object phase,
      ClightFrameEvidence projection run initial certificate index
        (EventConsumeTrigger trigger trigger_object phase) before after ->
      ~ (state_macro_respawn_state after trigger = true /\
         no_active_hidden_trigger_kind after trigger) ->
      MacroLifecycleAnomalyEvidence projection run initial certificate
| Act6ControllerLifecycleAnomaly :
    forall index before after star,
      ClightFrameEvidence projection run initial certificate index
        (EventSpawnAct6 star) before after ->
      ~ (all_five_consumed (state_triggers before) /\
         hidden_controller_present before /\
         state_hidden_controller_ref after =
           state_hidden_controller_ref before /\
         object_parent_ref star =
           Some (state_hidden_controller_ref before) /\
         object_area star = pyramid_area_id /\
         object_position star = hidden_controller_position /\
         object_home_position star = hidden_controller_position /\
         object_hitbox star = collect_star_hitbox) ->
      MacroLifecycleAnomalyEvidence projection run initial certificate.

(** Area reload is not itself an anomaly: the abstract semantics permits it
    to restore the selected entry snapshot.  If that state change is used as
    a route cut crossing, it must remain an explicit, currently open
    lifecycle/entry writer rather than being silently folded into a warp. *)
Inductive LifecycleEntryDisplacementEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (target_frame : nat) : Prop :=
| AreaReloadEntryDisplacement :
    forall cut index before after,
      (index < target_frame)%nat ->
      ClightFrameEvidence projection run initial certificate index
        EventAreaReload before after ->
      cut_entrance cut = state_entrance initial ->
      StateOnCutSourceSide cut before ->
      StateOnCutTargetSide cut after ->
      mario_position (state_mario_kinematics after) <>
        mario_position (state_mario_kinematics before) ->
      LifecycleEntryDisplacementEvidence
        projection run initial certificate target_frame.

Inductive SaveReloadMutationEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (target_frame : nat) : Prop :=
| SaveReloadMutatesTarget :
    forall index before after,
      (index < target_frame)%nat ->
      ClightFrameEvidence projection run initial certificate index
        EventSaveFileReload before after ->
      (newly_collected
         (state_save_flags before) (state_save_flags after) act3_index \/
       newly_collected
         (state_save_flags before) (state_save_flags after) act6_index) ->
      SaveReloadMutationEvidence
        projection run initial certificate target_frame.

(** This constructor identifies the exact endpoint-only refinement failure:
    a projected event exists at an index, and concrete Clight states project on
    both sides of its segment, but no indexed [CertifiedStep] explains it. *)
Record ProjectionMismatchEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (target_frame : nat) : Type := {
  mismatch_frame : nat;
  mismatch_event : FrameEvent;
  mismatch_before_clight : Clight.state;
  mismatch_after_clight : Clight.state;
  mismatch_before_state : GameState;
  mismatch_after_state : GameState;
  mismatch_prefix_trace : Events.trace;
  mismatch_segment_trace : Events.trace;
  mismatch_suffix_trace : Events.trace;
  mismatch_precedes_target :
    (mismatch_frame < target_frame)%nat;
  mismatch_trace_decomposition :
    run_trace run =
      mismatch_prefix_trace ++ mismatch_segment_trace ++ mismatch_suffix_trace;
  mismatch_prefix_steps :
    clight_run_star run (run_start run)
      mismatch_prefix_trace mismatch_before_clight;
  mismatch_segment_steps :
    clight_run_star run mismatch_before_clight
      mismatch_segment_trace mismatch_after_clight;
  mismatch_suffix_steps :
    clight_run_star run mismatch_after_clight
      mismatch_suffix_trace (run_final run);
  mismatch_before_projection :
    project_state projection mismatch_before_clight =
      Some mismatch_before_state;
  mismatch_after_projection :
    project_state projection mismatch_after_clight =
      Some mismatch_after_state;
  mismatch_projected_event :
    nth_error (project_events projection run) mismatch_frame =
      Some mismatch_event;
  mismatch_has_no_certified_step :
    forall before after,
      ~ CertifiedStepAt initial (project_events projection run)
          (refined_final_state projection run initial certificate)
          mismatch_frame mismatch_event before after
}.

Inductive SemanticBypassEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (target_frame : nat) : ConcreteBypassClass -> Prop :=
| SemanticOrdinaryMarioMotion :
    MotionCrossesCollisionCutEvidence projection run initial certificate
      target_frame MotionPhysicsFrame ->
      SemanticBypassEvidence projection run initial certificate target_frame
        BypassOrdinaryMarioMotionOrStaticGeometry
| SemanticPlatformDisplacement :
    MotionCrossesCollisionCutEvidence projection run initial certificate
      target_frame MotionPlatformDisplacement ->
      SemanticBypassEvidence projection run initial certificate target_frame
        BypassPlatformDisplacement
| SemanticObjectPush :
    MotionCrossesCollisionCutEvidence projection run initial certificate
      target_frame MotionObjectPush ->
      SemanticBypassEvidence projection run initial certificate target_frame
        BypassObjectPushOrMovingGeometry
| SemanticWarpDisplacement :
    DirectWarpDisplacementEvidence
      projection run initial certificate target_frame ->
    SemanticBypassEvidence projection run initial certificate target_frame
      BypassWarpOrArea3
| SemanticCollisionClip :
    MotionCrossesCollisionCutEvidence projection run initial certificate
      target_frame MotionCollisionClip ->
      SemanticBypassEvidence projection run initial certificate target_frame
        BypassCollisionClipOrTunnel
| SemanticCoordinateAlias :
    CoordinateAliasBeforeTargetEvidence
      projection run initial certificate target_frame ->
    SemanticBypassEvidence projection run initial certificate target_frame
      BypassParallelUniverseOrOutOfBounds
| SemanticTargetIdentityAnomaly :
    TargetIdentityAnomalyEvidence projection run initial certificate ->
    SemanticBypassEvidence projection run initial certificate target_frame
      BypassTargetRelocationOrSubstitution
| SemanticMacroLifecycleAnomaly :
    MacroLifecycleAnomalyEvidence projection run initial certificate ->
    SemanticBypassEvidence projection run initial certificate target_frame
      BypassMacroOrLifecycleAnomaly
| SemanticLifecycleEntryDisplacement :
    LifecycleEntryDisplacementEvidence
      projection run initial certificate target_frame ->
    SemanticBypassEvidence projection run initial certificate target_frame
      BypassMacroOrLifecycleAnomaly
| SemanticSaveReloadMutation :
    SaveReloadMutationEvidence
      projection run initial certificate target_frame ->
    SemanticBypassEvidence projection run initial certificate target_frame
      BypassSaveReloadOrCorruption
| SemanticProjectionMismatch :
    ProjectionMismatchEvidence
      projection run initial certificate target_frame ->
    SemanticBypassEvidence projection run initial certificate target_frame
      BypassMemoryOrUndefinedBehavior.

Theorem upper_warp_stale_top_conditional_path_is_platform_evidence :
  forall prelude_projection prelude_run prelude_initial prelude_certificate
      entry_projection entry_run entry_initial entry_certificate
      target_frame,
    UpperWarpStaleTopConditionalPathEvidence
      prelude_projection prelude_run prelude_initial prelude_certificate
      entry_projection entry_run entry_initial entry_certificate
      target_frame ->
    SemanticBypassEvidence
      entry_projection entry_run entry_initial entry_certificate
      target_frame BypassPlatformDisplacement.
Proof.
  intros prelude_projection prelude_run prelude_initial prelude_certificate
    entry_projection entry_run entry_initial entry_certificate
    target_frame Hevidence.
  constructor.
  exact (upper_stale_top_cut_crossing
    _ _ _ _ _ _ _ _ _ Hevidence).
Qed.

Record EvidenceBearingBypassAt
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (trace : RouteTrace) (entrance : PyramidEntrance)
    (class : ConcreteBypassClass) (region : TargetRouteRegion)
    (target_frame target_observation : nat) : Prop := {
  concrete_bypass_semantics :
    SemanticBypassEvidence projection run initial certificate
      target_frame class;
  concrete_bypass_tag_alignment :
    bypass_tag_precedes_target trace entrance class region
      target_frame target_observation
}.

(** * Eliminations available from the current certified semantics *)

Theorem direct_instant_warp_displacement_is_impossible :
  forall projection run initial certificate target_frame,
    ~ DirectWarpDisplacementEvidence
        projection run initial certificate target_frame.
Proof.
  intros projection run initial certificate target_frame Hevidence.
  destruct Hevidence as
    [cut index before after Hbefore Hframe Hcut Hsource Htarget Hchanged |
     cut index before after Hbefore Hframe Hcut Hsource Htarget Hchanged].
  - pose proof (certified_step_at_is_step
      _ _ _ _ _ _ _
      (frame_certified_occurrence _ _ _ _ _ _ _ _ Hframe)) as Hstep.
    pose proof (instant_warp_has_zero_displacement_core
      before after EventInstantWarp2To3 (or_introl eq_refl) Hstep)
      as Hcore.
    apply Hchanged. exact (proj1 Hcore).
  - pose proof (certified_step_at_is_step
      _ _ _ _ _ _ _
      (frame_certified_occurrence _ _ _ _ _ _ _ _ Hframe)) as Hstep.
    pose proof (instant_warp_has_zero_displacement_core
      before after EventInstantWarp3To2 (or_intror eq_refl) Hstep)
      as Hcore.
    apply Hchanged. exact (proj1 Hcore).
Qed.

Lemma collect_act3_step_has_target_membership :
  forall before after star phase,
    CertifiedStep before (EventCollectAct3 star phase) after ->
    In star (state_object_pool before) /\
    active_star_or_key act3_index star.
Proof.
  intros before after star phase Hstep.
  inversion Hstep; subst.
  - inversion H.
  - auto.
Qed.

Lemma consume_upper_step_has_valid_trigger :
  forall before after trigger_object phase,
    CertifiedStep before
      (EventConsumeTrigger TriggerUpper trigger_object phase) after ->
    valid_hidden_trigger_object before TriggerUpper trigger_object.
Proof.
  intros before after trigger_object phase Hstep.
  inversion Hstep; subst.
  - inversion H.
  - assumption.
Qed.

Theorem target_identity_anomaly_is_impossible :
  forall projection run initial certificate,
    CleanPyramidEntry initial ->
    ~ TargetIdentityAnomalyEvidence projection run initial certificate.
Proof.
  intros projection run initial certificate Hclean Hanomaly.
  inversion Hanomaly as
    [index before after star phase Hframe Hobservation Hinvalid |
     index before after trigger_object phase Hframe Hobservation Hinvalid];
    subst.
  - pose proof (frame_certified_occurrence _ _ _ _ _ _ _ _ Hframe)
      as Hoccurrence.
    pose proof (certified_step_at_before_is_well_formed
      _ _ _ _ _ _ _
      (clean_entry_is_frame_well_formed initial Hclean) Hoccurrence)
      as Hbefore_well_formed.
    pose proof (certified_step_at_is_step
      _ _ _ _ _ _ _ Hoccurrence) as Hstep.
    destruct (collect_act3_step_has_target_membership
      before after star phase Hstep) as [Hin Hactive].
    apply Hinvalid.
    unfold frame_well_formed in Hbefore_well_formed.
    destruct Hbefore_well_formed as
      (_ & _ & Hprovenance & _).
    exact (Hprovenance star Hin).
  - apply Hinvalid.
    apply consume_upper_step_has_valid_trigger with (after := after)
      (phase := phase).
    eapply certified_step_at_is_step.
    exact (frame_certified_occurrence _ _ _ _ _ _ _ _ Hframe).
Qed.

Theorem macro_lifecycle_anomaly_is_impossible :
  forall projection run initial certificate,
    ~ MacroLifecycleAnomalyEvidence projection run initial certificate.
Proof.
  intros projection run initial certificate Hanomaly.
  inversion Hanomaly as
    [index before after trigger trigger_object phase Hframe Hinvalid |
     index before after star Hframe Hinvalid];
    subst.
  - apply Hinvalid.
    eapply consumed_trigger_successor_updates_macro_and_deactivates_kind.
    eapply certified_step_at_is_step.
    exact (frame_certified_occurrence _ _ _ _ _ _ _ _ Hframe).
  - apply Hinvalid.
    pose proof (certified_step_at_is_step
      _ _ _ _ _ _ _
      (frame_certified_occurrence _ _ _ _ _ _ _ _ Hframe)) as Hstep.
    inversion Hstep; subst.
    + inversion H.
    + pose proof (act6_spawn_uses_designated_controller_lineage
        before after star Hstep) as
        (Hcontroller & Hsame_controller & Hparent & Harea &
         Hposition & Hhome & Hhitbox).
      repeat split; assumption.
Qed.

Theorem save_reload_target_mutation_is_impossible :
  forall projection run initial certificate target_frame,
    ~ SaveReloadMutationEvidence
        projection run initial certificate target_frame.
Proof.
  intros projection run initial certificate target_frame Hevidence.
  inversion Hevidence as
    [index before after Hbefore Hframe Hmutation]; subst.
  pose proof (certified_step_at_is_step
    _ _ _ _ _ _ _
    (frame_certified_occurrence _ _ _ _ _ _ _ _ Hframe)) as Hstep.
  pose proof (certified_save_file_reload_cannot_introduce_target_bit
    before after Hstep) as Hpreserved.
  unfold target_bits_preserved in Hpreserved.
  destruct Hpreserved as [Hact3 Hact6].
  destruct Hmutation as [[Hclear Hset] | [Hclear Hset]].
  - rewrite Hact3 in Hset. rewrite Hclear in Hset. discriminate.
  - rewrite Hact6 in Hset. rewrite Hclear in Hset. discriminate.
Qed.

Theorem projection_mismatch_is_impossible_with_certificate :
  forall projection run initial certificate target_frame,
    ProjectionMismatchEvidence
      projection run initial certificate target_frame ->
    False.
Proof.
  intros projection run initial certificate target_frame Hmismatch.
  pose proof (certified_execution_nth_has_step_at
    initial
    (project_events projection run)
    (refined_final_state projection run initial certificate)
    (refined_execution projection run initial certificate)
    (mismatch_frame _ _ _ _ _ Hmismatch)
    (mismatch_event _ _ _ _ _ Hmismatch)
    (mismatch_projected_event _ _ _ _ _ Hmismatch))
    as [before [after Hoccurrence]].
  exact (mismatch_has_no_certified_step _ _ _ _ _ Hmismatch
    before after Hoccurrence).
Qed.

(** The old alias-gap lemma discharges a useful but narrow subcase of the
    general coordinate-alias evidence: a single accepted static quarter-step
    with absolute delta at most 256 cannot leave the local alias period. *)
Definition BoundedStaticAliasSubcase
    {before after : MarioKinematics}
    (witness : CoordinateAliasEscapeWitness before after) : Prop :=
  LegacyAcceptedStaticQstep
    (alias_before_integer _ _ witness)
    (alias_after_integer _ _ witness).

Theorem bounded_static_alias_subcase_is_impossible :
  forall before after
      (witness : CoordinateAliasEscapeWitness before after),
    ~ BoundedStaticAliasSubcase witness.
Proof.
  intros before after witness Hbounded.
  apply (alias_after_nonlocal _ _ witness).
  eapply legacy_bounded_static_qstep_cannot_change_alias_period.
  exact Hbounded.
Qed.

(** The six surviving classes are precisely the places where the present
    project lacks collision-mesh/writer coverage.  In particular, the general
    coordinate-alias constructor is not eliminated by the narrow bounded
    static lemma above.  Ordinary Mario physics/static-support movement is
    explicit because the historical nine tags did not include that writer. *)
Theorem evidence_bypass_reduces_to_open_route_writer_classes :
  forall projection run initial certificate trace entrance class region
      target_frame target_observation,
    CleanPyramidEntry initial ->
    EvidenceBearingBypassAt projection run initial certificate trace
      entrance class region target_frame target_observation ->
    class = BypassOrdinaryMarioMotionOrStaticGeometry \/
    class = BypassPlatformDisplacement \/
    class = BypassObjectPushOrMovingGeometry \/
    class = BypassCollisionClipOrTunnel \/
    class = BypassParallelUniverseOrOutOfBounds \/
    class = BypassMacroOrLifecycleAnomaly.
Proof.
  intros projection run initial certificate trace entrance class region
    target_frame target_observation Hclean Hevidence.
  destruct Hevidence as [Hsemantic Htag].
  inversion Hsemantic; subst.
  - left. reflexivity.
  - right. left. reflexivity.
  - right. right. left. reflexivity.
  - exfalso.
    eapply direct_instant_warp_displacement_is_impossible; eauto.
  - right. right. right. left. reflexivity.
  - right. right. right. right. left. reflexivity.
  - exfalso.
    eapply target_identity_anomaly_is_impossible; eauto.
  - exfalso.
    eapply macro_lifecycle_anomaly_is_impossible; eauto.
  - right. right. right. right. right. reflexivity.
  - exfalso.
    eapply save_reload_target_mutation_is_impossible; eauto.
  - exfalso.
    eapply projection_mismatch_is_impossible_with_certificate; eauto.
Qed.

(** * Bridge to the historical payload-free classification

    The bridge does not prove the classifier.  It shows exactly what must be
    constructed from Clight: input/event alignment plus an evidence-bearing
    first-cut classification. *)

Record ClightRouteTraceProjection
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (trace : RouteTrace) : Prop := {
  clight_route_inputs_exact :
    route_inputs trace = project_inputs projection run;
  clight_route_execution_alignment :
    RouteTraceExecutionAlignment initial trace
      (project_events projection run)
      (refined_final_state projection run initial certificate)
}.

Record EvidenceBearingFirstTargetCutClassification
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (trace : RouteTrace) : Prop := {
  evidence_classify_upper_first_target :
    forall region target_frame target_observation,
      state_entrance initial = UpperEntrance ->
      first_target_observation_at
        trace region target_frame target_observation ->
      gate_a_press_precedes_exact_target trace ElevatorJumpOutGate
        region target_frame target_observation \/
      exists class,
        EvidenceBearingBypassAt projection run initial certificate trace
          UpperEntrance class region target_frame target_observation;
  evidence_classify_lower_first_target :
    forall region target_frame target_observation,
      state_entrance initial = LowerEntrance ->
      first_target_observation_at
        trace region target_frame target_observation ->
      gate_a_press_precedes_exact_target trace SecondPoleJumpOffGate
        region target_frame target_observation \/
      exists class,
        EvidenceBearingBypassAt projection run initial certificate trace
          LowerEntrance class region target_frame target_observation
}.

Definition OrdinaryStaticGeometryClassUnreachable
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (trace : RouteTrace) : Prop :=
  forall entrance region target_frame target_observation,
    ~ EvidenceBearingBypassAt projection run initial certificate trace
        entrance BypassOrdinaryMarioMotionOrStaticGeometry
        region target_frame target_observation.

Theorem evidence_classifier_refines_first_target_cut_obligation :
  forall projection run initial certificate trace,
    CleanPyramidEntry initial ->
    ClightRouteTraceProjection projection run initial certificate trace ->
    EvidenceBearingFirstTargetCutClassification
      projection run initial certificate trace ->
    OrdinaryStaticGeometryClassUnreachable
      projection run initial certificate trace ->
    FirstTargetCutClassificationObligation initial trace.
Proof.
  intros projection run initial certificate trace
    Hclean Hroute Hclassifier Hno_ordinary.
  constructor.
  - exact Hclean.
  - rewrite (clight_route_inputs_exact _ _ _ _ _ Hroute).
    exact (refined_input_history projection run initial certificate).
  - exists (refined_final_state projection run initial certificate).
    exists (project_events projection run).
    exact (clight_route_execution_alignment _ _ _ _ _ Hroute).
  - intros region target_frame target_observation Hupper Hfirst.
    destruct (evidence_classify_upper_first_target
      _ _ _ _ _ Hclassifier region target_frame target_observation
      Hupper Hfirst) as [Hgate | [class Hevidence]].
    + left. exact Hgate.
    + destruct class.
      * exfalso. exact (Hno_ordinary UpperEntrance region
          target_frame target_observation Hevidence).
      * right. exists UpperPlatformDisplacementBypass.
        exact (concrete_bypass_tag_alignment
          _ _ _ _ _ _ _ _ _ _ Hevidence).
      * right. exists UpperObjectPushOrMovingGeometryBypass.
        exact (concrete_bypass_tag_alignment
          _ _ _ _ _ _ _ _ _ _ Hevidence).
      * right. exists UpperWarpOrArea3Bypass.
        exact (concrete_bypass_tag_alignment
          _ _ _ _ _ _ _ _ _ _ Hevidence).
      * right. exists UpperCollisionClipOrTunnelBypass.
        exact (concrete_bypass_tag_alignment
          _ _ _ _ _ _ _ _ _ _ Hevidence).
      * right. exists UpperParallelUniverseOrOutOfBoundsBypass.
        exact (concrete_bypass_tag_alignment
          _ _ _ _ _ _ _ _ _ _ Hevidence).
      * right. exists UpperTargetRelocationOrSubstitutionBypass.
        exact (concrete_bypass_tag_alignment
          _ _ _ _ _ _ _ _ _ _ Hevidence).
      * right. exists UpperMacroOrLifecycleAnomalyBypass.
        exact (concrete_bypass_tag_alignment
          _ _ _ _ _ _ _ _ _ _ Hevidence).
      * right. exists UpperSaveReloadOrCorruptionBypass.
        exact (concrete_bypass_tag_alignment
          _ _ _ _ _ _ _ _ _ _ Hevidence).
      * right. exists UpperMemoryOrUndefinedBehaviorBypass.
        exact (concrete_bypass_tag_alignment
          _ _ _ _ _ _ _ _ _ _ Hevidence).
  - intros region target_frame target_observation Hlower Hfirst.
    destruct (evidence_classify_lower_first_target
      _ _ _ _ _ Hclassifier region target_frame target_observation
      Hlower Hfirst) as [Hgate | [class Hevidence]].
    + left. exact Hgate.
    + destruct class.
      * exfalso. exact (Hno_ordinary LowerEntrance region
          target_frame target_observation Hevidence).
      * right. exists LowerPlatformDisplacementBypass.
        exact (concrete_bypass_tag_alignment
          _ _ _ _ _ _ _ _ _ _ Hevidence).
      * right. exists LowerObjectPushOrMovingGeometryBypass.
        exact (concrete_bypass_tag_alignment
          _ _ _ _ _ _ _ _ _ _ Hevidence).
      * right. exists LowerWarpOrArea3Bypass.
        exact (concrete_bypass_tag_alignment
          _ _ _ _ _ _ _ _ _ _ Hevidence).
      * right. exists LowerCollisionClipOrTunnelBypass.
        exact (concrete_bypass_tag_alignment
          _ _ _ _ _ _ _ _ _ _ Hevidence).
      * right. exists LowerParallelUniverseOrOutOfBoundsBypass.
        exact (concrete_bypass_tag_alignment
          _ _ _ _ _ _ _ _ _ _ Hevidence).
      * right. exists LowerTargetRelocationOrSubstitutionBypass.
        exact (concrete_bypass_tag_alignment
          _ _ _ _ _ _ _ _ _ _ Hevidence).
      * right. exists LowerMacroOrLifecycleAnomalyBypass.
        exact (concrete_bypass_tag_alignment
          _ _ _ _ _ _ _ _ _ _ Hevidence).
      * right. exists LowerSaveReloadOrCorruptionBypass.
        exact (concrete_bypass_tag_alignment
          _ _ _ _ _ _ _ _ _ _ Hevidence).
      * right. exists LowerMemoryOrUndefinedBehaviorBypass.
        exact (concrete_bypass_tag_alignment
          _ _ _ _ _ _ _ _ _ _ Hevidence).
Qed.

Definition OpenRouteWriterClassesUnreachable
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (trace : RouteTrace) : Prop :=
  forall entrance class region target_frame target_observation,
    (class = BypassOrdinaryMarioMotionOrStaticGeometry \/
     class = BypassPlatformDisplacement \/
     class = BypassObjectPushOrMovingGeometry \/
     class = BypassCollisionClipOrTunnel \/
     class = BypassParallelUniverseOrOutOfBounds \/
     class = BypassMacroOrLifecycleAnomaly) ->
    ~ EvidenceBearingBypassAt projection run initial certificate trace
        entrance class region target_frame target_observation.

Theorem evidence_classifier_with_open_writers_closed_requires_a_edge :
  forall projection run initial certificate trace,
    CleanPyramidEntry initial ->
    ClightRouteTraceProjection projection run initial certificate trace ->
    EvidenceBearingFirstTargetCutClassification
      projection run initial certificate trace ->
    OpenRouteWriterClassesUnreachable
      projection run initial certificate trace ->
    reaches_any_target_region trace ->
    trace_contains_a_press trace.
Proof.
  intros projection run initial certificate trace Hclean Hroute
    Hclassifier Hclosed Htarget.
  destruct (reaches_any_target_has_first_exact_occurrence trace Htarget)
    as [region [target_frame [target_observation Hfirst]]].
  destruct (state_entrance initial) eqn:Hentrance.
  - destruct (evidence_classify_lower_first_target
      _ _ _ _ _ Hclassifier region target_frame target_observation
      Hentrance Hfirst) as [Hgate | [class Hevidence]].
    + eapply exact_gate_a_press_is_trace_press. exact Hgate.
    + exfalso.
      pose proof (evidence_bypass_reduces_to_open_route_writer_classes
        projection run initial certificate trace LowerEntrance class region
        target_frame target_observation Hclean Hevidence) as Hopen.
      exact (Hclosed LowerEntrance class region target_frame
        target_observation Hopen Hevidence).
  - destruct (evidence_classify_upper_first_target
      _ _ _ _ _ Hclassifier region target_frame target_observation
      Hentrance Hfirst) as [Hgate | [class Hevidence]].
    + eapply exact_gate_a_press_is_trace_press. exact Hgate.
    + exfalso.
      pose proof (evidence_bypass_reduces_to_open_route_writer_classes
        projection run initial certificate trace UpperEntrance class region
        target_frame target_observation Hclean Hevidence) as Hopen.
      exact (Hclosed UpperEntrance class region target_frame
        target_observation Hopen Hevidence).
Qed.

(** * Target-bit bridge to the evidence-bearing route cut

    This is the direction needed by the impossibility theorem.  It does not
    claim that merely observing a region sets a save bit.  Instead, the
    certified Layer-A execution first supplies the required collection or
    upper-trigger event, and the bidirectional route alignment places that
    event at the matching collision-region cut. *)

Theorem aligned_newly_collected_act3_reaches_act3_cut :
  forall initial trace events final,
    RouteTraceExecutionAlignment initial trace events final ->
    newly_collected
      (state_save_flags initial) (state_save_flags final) act3_index ->
    reaches_target_region trace Act3InteractionRegionNode.
Proof.
  intros initial trace events final Haligned Hnew.
  destruct (newly_collected_act3_requires_collection_event
    initial events final
    (aligned_certified_execution initial trace events final Haligned)
    Hnew) as
    [star [phase [Hin [Hactive [Horigin Hoverlap]]]]].
  apply In_nth_error in Hin.
  destruct Hin as [index Hevent].
  destruct (aligned_act3_event_to_observation
    initial trace events final Haligned index star phase Hevent)
    as [frame [Hframe Hobservation]].
  unfold reaches_target_region.
  eapply route_frame_observation_is_observed.
  - eapply nth_error_In. exact Hframe.
  - exact Hobservation.
Qed.

Theorem aligned_newly_collected_act6_reaches_upper_trigger_cut :
  forall initial trace events final,
    CleanPyramidEntry initial ->
    RouteTraceExecutionAlignment initial trace events final ->
    newly_collected
      (state_save_flags initial) (state_save_flags final) act6_index ->
    reaches_target_region trace UpperHiddenStarTriggerNode.
Proof.
  intros initial trace events final Hclean Haligned Hnew.
  destruct (spawning_act6_requires_all_five_and_upper_overlap
    initial events final Hclean
    (aligned_certified_execution initial trace events final Haligned)
    Hnew) as
    [Hspawn [trigger_object [phase [Hin Hoverlap]]]].
  apply In_nth_error in Hin.
  destruct Hin as [index Hevent].
  destruct (aligned_upper_event_to_observation
    initial trace events final Haligned index trigger_object phase Hevent)
    as [frame [Hframe Hobservation]].
  unfold reaches_target_region.
  eapply route_frame_observation_is_observed.
  - eapply nth_error_In. exact Hframe.
  - exact Hobservation.
Qed.

Theorem aligned_newly_collected_target_reaches_first_cut_domain :
  forall initial trace events final,
    CleanPyramidEntry initial ->
    RouteTraceExecutionAlignment initial trace events final ->
    (newly_collected
       (state_save_flags initial) (state_save_flags final) act3_index \/
     newly_collected
       (state_save_flags initial) (state_save_flags final) act6_index) ->
    reaches_any_target_region trace.
Proof.
  intros initial trace events final Hclean Haligned [Hact3 | Hact6].
  - exists Act3InteractionRegionNode.
    eapply aligned_newly_collected_act3_reaches_act3_cut; eauto.
  - exists UpperHiddenStarTriggerNode.
    eapply aligned_newly_collected_act6_reaches_upper_trigger_cut; eauto.
Qed.

Lemma fewer_than_one_a_press_excludes_trace_press :
  forall trace,
    fewer_than_one_a_press (route_inputs trace) ->
    ~ trace_contains_a_press trace.
Proof.
  intros trace Hnoa
    [frame [Hframe Hpressed]].
  unfold fewer_than_one_a_press in Hnoa.
  rewrite Forall_forall in Hnoa.
  specialize (Hnoa (route_frame_input frame)).
  assert (Hinput :
      In (route_frame_input frame) (route_inputs trace)).
  { unfold route_inputs. apply in_map. exact Hframe. }
  specialize (Hnoa Hinput).
  unfold frame_has_no_a_press in Hnoa.
  rewrite Hnoa in Hpressed. discriminate.
Qed.

(** Unlike [first_target_cut_with_all_bypasses_excluded_requires_a_edge],
    this capstone never passes through the payload-free
    [FirstTargetCutClassificationObligation].  Its residuals name the actual
    Clight run/certificate projection, the evidence-bearing classification,
    and the six still-open writer/geometry classes. *)
Theorem evidence_classifier_with_open_writers_closed_blocks_new_target_bits :
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
  intros projection run initial certificate trace Hclean Hroute
    Hclassifier Hclosed Hnoa.
  assert (Hnoa_trace :
      fewer_than_one_a_press (route_inputs trace)).
  {
    rewrite (clight_route_inputs_exact
      projection run initial certificate trace Hroute).
    exact Hnoa.
  }
  assert (Hno_trace_press : ~ trace_contains_a_press trace).
  {
    eapply fewer_than_one_a_press_excludes_trace_press.
    exact Hnoa_trace.
  }
  split; intro Hnew.
  - apply Hno_trace_press.
    eapply evidence_classifier_with_open_writers_closed_requires_a_edge;
      eauto.
    exists Act3InteractionRegionNode.
    eapply aligned_newly_collected_act3_reaches_act3_cut.
    + exact (clight_route_execution_alignment
        projection run initial certificate trace Hroute).
    + exact Hnew.
  - apply Hno_trace_press.
    eapply evidence_classifier_with_open_writers_closed_requires_a_edge;
      eauto.
    exists UpperHiddenStarTriggerNode.
    eapply aligned_newly_collected_act6_reaches_upper_trigger_cut.
    + exact Hclean.
    + exact (clight_route_execution_alignment
        projection run initial certificate trace Hroute).
    + exact Hnew.
Qed.

(** These two residuals expose the exact route-classification work needed on
    top of [WholeProgramClightRefinementObligation].  The first must construct
    a frame-aligned route and evidence-bearing first-cut classification for the
    concrete imported run.  The second must eliminate only the six writer and
    geometry classes that remain after the checked Layer-A exclusions.  Neither
    residual assumes that a target bit stays clear. *)
Definition EvidenceBearingRouteClassificationRefinementObligation
    (projection : ClightObservationProjection) : Prop :=
  forall run initial
      (certificate :
        ClightFrameRefinementCertificate projection run initial),
    CleanPyramidEntry initial ->
    exists trace,
      ClightRouteTraceProjection
        projection run initial certificate trace /\
      EvidenceBearingFirstTargetCutClassification
        projection run initial certificate trace.

Definition NoAOpenRouteWriterClassesUnreachableObligation
    (projection : ClightObservationProjection) : Prop :=
  forall run initial
      (certificate :
        ClightFrameRefinementCertificate projection run initial)
      trace,
    CleanPyramidEntry initial ->
    ClightRouteTraceProjection
      projection run initial certificate trace ->
    EvidenceBearingFirstTargetCutClassification
      projection run initial certificate trace ->
    fewer_than_one_a_press (project_inputs projection run) ->
    OpenRouteWriterClassesUnreachable
      projection run initial certificate trace.

(** * Endpoint-only insufficiency countermodel schema

    A one-frame abstract execution can align a target collection event with a
    target observation while containing no earlier observation at all.  Thus
    endpoint projection plus target-event alignment cannot, by pure logic,
    manufacture an elevator/pole gate or a bypass occurrence.  The premise is
    a real [CertifiedStep], not an axiom asserting the conclusion. *)

Definition boundary_frame_input (initial : GameState) : FrameInput :=
  {| frame_previous_down :=
       state_first_frame_previous_down_seed initial;
     frame_current_down := state_entry_button_down initial |}.

Definition single_act3_target_trace (initial : GameState) : RouteTrace :=
  {| route_frames :=
      [{| route_frame_input := boundary_frame_input initial;
          route_frame_observations :=
            [ObservedTargetRegion Act3InteractionRegionNode] |}] |}.

Lemma single_act3_target_is_first :
  forall initial,
    first_target_observation_at
      (single_act3_target_trace initial)
      Act3InteractionRegionNode 0%nat 0%nat.
Proof.
  intros initial. split.
  - exists {| route_frame_input := boundary_frame_input initial;
              route_frame_observations :=
                [ObservedTargetRegion Act3InteractionRegionNode] |}.
    split; reflexivity.
  - intros earlier_region earlier_frame earlier_observation
      Hearlier Hprecedes.
    unfold route_position_precedes in Hprecedes.
    lia.
Qed.

Lemma single_act3_trace_alignment :
  forall initial final star phase,
    CertifiedStep initial (EventCollectAct3 star phase) final ->
    RouteTraceExecutionAlignment initial
      (single_act3_target_trace initial)
      [EventCollectAct3 star phase] final.
Proof.
  intros initial final star phase Hstep.
  constructor.
  - econstructor.
    + exact Hstep.
    + constructor.
  - reflexivity.
  - intros index frame Hframe Hobservation.
    destruct index as [|index].
    + cbn in Hframe. inversion Hframe; subst frame.
      exists star, phase. reflexivity.
    + assert (Hbound :
        (S index <
          length (route_frames (single_act3_target_trace initial)))%nat).
      { apply nth_error_Some. rewrite Hframe. discriminate. }
      cbn in Hbound. lia.
  - intros index frame Hframe Hobservation.
    destruct index as [|index].
    + cbn in Hframe. inversion Hframe; subst frame.
      cbn in Hobservation. destruct Hobservation as [H | []].
      discriminate.
    + assert (Hbound :
        (S index <
          length (route_frames (single_act3_target_trace initial)))%nat).
      { apply nth_error_Some. rewrite Hframe. discriminate. }
      cbn in Hbound. lia.
  - intros index selected_star selected_phase Hevent.
    destruct index as [|index].
    + cbn in Hevent. inversion Hevent; subst.
      exists {| route_frame_input := boundary_frame_input initial;
                route_frame_observations :=
                  [ObservedTargetRegion Act3InteractionRegionNode] |}.
      split; [reflexivity |]. cbn. auto.
    + assert (Hbound :
        (S index < length [EventCollectAct3 star phase])%nat).
      { apply nth_error_Some. rewrite Hevent. discriminate. }
      cbn in Hbound. lia.
  - intros index trigger_object trigger_phase Hevent.
    destruct index as [|index].
    + cbn in Hevent. inversion Hevent.
    + assert (Hbound :
        (S index < length [EventCollectAct3 star phase])%nat).
      { apply nth_error_Some. rewrite Hevent. discriminate. }
      cbn in Hbound. lia.
Qed.

Lemma no_position_precedes_zero_zero :
  forall earlier_frame earlier_observation,
    ~ route_position_precedes
        earlier_frame earlier_observation 0%nat 0%nat.
Proof.
  intros earlier_frame earlier_observation Hprecedes.
  unfold route_position_precedes in Hprecedes.
  lia.
Qed.

Theorem endpoint_only_alignment_does_not_imply_cut_classification :
  forall initial final star phase,
    CleanPyramidEntry initial ->
    CertifiedStep initial (EventCollectAct3 star phase) final ->
    coherent_input_history
      (state_first_frame_previous_down_seed initial)
      (route_inputs (single_act3_target_trace initial)) /\
    RealizedRouteTrace initial (single_act3_target_trace initial) /\
    ~ FirstTargetCutClassificationObligation
        initial (single_act3_target_trace initial).
Proof.
  intros initial final star phase Hclean Hstep.
  split.
  - cbn. split; [reflexivity | exact I].
  - split.
    + exists final, [EventCollectAct3 star phase].
      exact (single_act3_trace_alignment initial final star phase Hstep).
    + intro Hclassification.
      pose proof (single_act3_target_is_first initial) as Hfirst.
      destruct (state_entrance initial) eqn:Hentrance.
      * destruct (classify_lower_first_target
          initial (single_act3_target_trace initial) Hclassification
          Act3InteractionRegionNode 0%nat 0%nat Hentrance Hfirst)
          as [Hgate | [witness Hbypass]].
        -- destruct Hgate as
             [gate_frame [gate_observation [frame
               [Hframe [Hgate [Hpressed [Htarget Hprecedes]]]]]]].
           exact (no_position_precedes_zero_zero
             gate_frame gate_observation Hprecedes).
        -- destruct Hbypass as
             [bypass_frame [bypass_observation
               [Hoccurrence [Htarget Hprecedes]]]].
           exact (no_position_precedes_zero_zero
             bypass_frame bypass_observation Hprecedes).
      * destruct (classify_upper_first_target
          initial (single_act3_target_trace initial) Hclassification
          Act3InteractionRegionNode 0%nat 0%nat Hentrance Hfirst)
          as [Hgate | [witness Hbypass]].
        -- destruct Hgate as
             [gate_frame [gate_observation [frame
               [Hframe [Hgate [Hpressed [Htarget Hprecedes]]]]]]].
           exact (no_position_precedes_zero_zero
             gate_frame gate_observation Hprecedes).
        -- destruct Hbypass as
             [bypass_frame [bypass_observation
               [Hoccurrence [Htarget Hprecedes]]]].
           exact (no_position_precedes_zero_zero
             bypass_frame bypass_observation Hprecedes).
Qed.
