(** A bounded audit of the Area-1 node-0x1E / pyramid-top Parallel
    Universe proposal.

    This module deliberately separates:

    - one full-coordinate sample, where warp contact and top ownership are
      vertically incompatible;
    - the real update-order split between MarioState and MarioObject, for
      which two different samples can satisfy those facts; and
    - reachability/lifetime, which is not proved here.

    The integer coordinates below are exactly representable in binary32.
    The generated-AST checks live in [ClightFacts].  Authenticated US/JP retail
    disassembly and the arithmetic in [PyramidTopSurface] close the exact
    [trunc.w.s; mfc1; sh; lh] results for the three concrete inputs; they do not
    establish a general out-of-range compiler theorem.  Connecting the
    hand-mirrored transform/edge arithmetic to linked Clight memory execution
    and actual [find_floor] surface selection remains open.  The relevant
    matrix and dynamic-surface helper bodies are now generated in
    [PyramidTopSurface]. *)

From Coq Require Import List ZArith Lia.
From compcert Require Import Floats Integers.
From LessThanOneAPress.Proofs Require Import
  ClightFacts CollisionMeshFacts GameTypes CollisionRegions
  PyramidTopSurface.

Import ListNotations.
Local Open Scope Z_scope.

Record PositionZ : Type := {
  position_x : Z;
  position_y : Z;
  position_z : Z
}.

Definition upper_warp_x : Z := -2048.
Definition upper_warp_y : Z := 768.
Definition upper_warp_z : Z := -1024.
Definition upper_warp_radius : Z := 150.
Definition upper_warp_height : Z := 50.
Definition mario_hitbox_radius : Z := 37.
Definition mario_hitbox_height : Z := 160.

Definition pyramid_top_home_x : Z := -2047.
Definition pyramid_top_home_y : Z := 1536.
Definition pyramid_top_home_z : Z := -1023.
Definition pyramid_top_floor_min_y : Z := 1281.
Definition platform_floor_tolerance : Z := 4.
Definition find_floor_upward_buffer : Z := 78.

(** Numeric equalities for the exact packed LevelScript coordinates/parameter
    bytes checked in [ssl_pu_level_script_claim] and the separately modeled
    hitbox constants.  This is not a LevelScript decoder or behavior-dataflow
    refinement. *)
Definition pyramid_top_pu_modeled_source_constants : Prop :=
  -134216960 = upper_warp_x * 65536 + upper_warp_y /\
  -67108864 = upper_warp_z * 65536 /\
  253624320 = 15 * 16777216 + 30 * 65536 /\
  upper_warp_radius = 15 * 10 /\
  upper_warp_height = 50 /\
  -134150656 = pyramid_top_home_x * 65536 + pyramid_top_home_y /\
  -67043328 = pyramid_top_home_z * 65536.

Theorem pyramid_top_pu_modeled_source_constants_checked :
  pyramid_top_pu_modeled_source_constants.
Proof.
  unfold pyramid_top_pu_modeled_source_constants, upper_warp_x, upper_warp_y,
    upper_warp_z, upper_warp_radius, upper_warp_height, pyramid_top_home_x,
    pyramid_top_home_y, pyramid_top_home_z.
  repeat split; reflexivity.
Qed.

Definition upper_warp_position_f32 : Vec3f := {|
  vec_x := f32_bits 3305111552;  (* -2048.0f *)
  vec_y := f32_bits 1145044992;  (* 768.0f *)
  vec_z := f32_bits 3296722944   (* -1024.0f *)
|}.

Definition pu_top_floor_candidate_f32 : Vec3f := {|
  vec_x := f32_bits 1199046656;  (* 63488.0f *)
  vec_y := f32_bits 1155522560;  (* 1791.0f *)
  vec_z := f32_bits 3296722944   (* -1024.0f *)
|}.

Definition upper_warp_hitbox_f32 : Hitbox := {|
  hitbox_radius := f32_bits 1125515264;     (* 150.0f *)
  hitbox_height := f32_bits 1112014848;     (* 50.0f *)
  hitbox_down_offset := f32_zero
|}.

Definition mario_standard_hitbox_f32 : Hitbox := {|
  hitbox_radius := f32_bits 1108606976;     (* 37.0f *)
  hitbox_height := f32_bits 1126170624;     (* 160.0f *)
  hitbox_down_offset := f32_zero
|}.

(** Exact binary32 checks for the two concrete samples.  The handwritten
    [hitboxes_overlap] formula is itself still awaiting its generated-Clight
    execution refinement, but this avoids silently replacing these sample
    calculations with real or unbounded arithmetic. *)
Theorem upper_warp_center_overlaps_in_float32_model :
  hitboxes_overlap
    upper_warp_position_f32 mario_standard_hitbox_f32
    upper_warp_position_f32 upper_warp_hitbox_f32 = true.
Proof. vm_compute. reflexivity. Qed.

Theorem pu_top_candidate_does_not_overlap_warp_in_float32_model :
  hitboxes_overlap
    pu_top_floor_candidate_f32 mario_standard_hitbox_f32
    upper_warp_position_f32 upper_warp_hitbox_f32 = false.
Proof. vm_compute. reflexivity. Qed.

Theorem float32_warp_top_is_below_platform_capture_lower_bound :
  Float32.cmp Clt
    (f32_bits 1145864192)  (* 818.0f *)
    (f32_bits 1151311872)  (* 1277.0f *) = true.
Proof. vm_compute. reflexivity. Qed.

(** Mathematical signed-16 wrapping.  [ClightFacts] proves that the C source
    was translated with float-to-[tshort] casts.  This definition records the
    intended compiled wrapping arithmetic; it is not an ISO-C theorem about
    every out-of-range float conversion. *)
Definition signed16 (value : Z) : Z :=
  ((value + 32768) mod 65536) - 32768.

Lemma signed16_in_range :
  forall value,
    -32768 <= value < 32768 ->
    signed16 value = value.
Proof.
  intros value Hrange.
  unfold signed16.
  rewrite Z.mod_small; lia.
Qed.

Definition horizontal_distance_squared
    (a b : PositionZ) : Z :=
  let dx := position_x a - position_x b in
  let dz := position_z a - position_z b in
  dx * dx + dz * dz.

Definition upper_warp_center : PositionZ := {|
  position_x := upper_warp_x;
  position_y := upper_warp_y;
  position_z := upper_warp_z
|}.

(** Integer form of the strict horizontal and inclusive vertical tests in
    [detect_object_hitbox_overlap]. *)
Definition upper_warp_contact (mario : PositionZ) : Prop :=
  horizontal_distance_squared mario upper_warp_center <
    (upper_warp_radius + mario_hitbox_radius) *
    (upper_warp_radius + mario_hitbox_radius) /\
  position_y mario <= upper_warp_y + upper_warp_height /\
  upper_warp_y <= position_y mario + mario_hitbox_height.

Definition live_top_platform_capture
    (mario : PositionZ) (floor_y : Z) : Prop :=
  pyramid_top_floor_min_y <= floor_y /\
  floor_y - platform_floor_tolerance < position_y mario /\
  position_y mario < floor_y + platform_floor_tolerance.

Definition floor_query_can_return
    (query : PositionZ) (floor_y : Z) : Prop :=
  floor_y - find_floor_upward_buffer <= signed16 (position_y query).

Theorem upper_warp_contact_y_bounds :
  forall mario,
    upper_warp_contact mario ->
    608 <= position_y mario <= 818.
Proof.
  intros mario (_ & Htop & Hbottom).
  unfold upper_warp_y, upper_warp_height, mario_hitbox_height in *.
  lia.
Qed.

Theorem live_top_capture_y_lower_bound :
  forall mario floor_y,
    live_top_platform_capture mario floor_y ->
    1277 < position_y mario.
Proof.
  intros mario floor_y (Hfloor & Hnear & _).
  unfold pyramid_top_floor_min_y, platform_floor_tolerance in *.
  lia.
Qed.

(** This is the valid same-sample vertical argument. *)
Theorem one_coordinate_cannot_contact_warp_and_capture_live_top :
  forall mario floor_y,
    upper_warp_contact mario ->
    live_top_platform_capture mario floor_y ->
    False.
Proof.
  intros mario floor_y Hwarp Htop.
  pose proof (upper_warp_contact_y_bounds mario Hwarp).
  pose proof (live_top_capture_y_lower_bound mario floor_y Htop).
  lia.
Qed.

(** The 78-unit floor-search allowance cannot bridge the stock vertical gap
    when the displaced State has retained the warp-contact Y coordinate. *)
Theorem upper_warp_altitude_cannot_query_live_top_floor :
  forall query floor_y,
    608 <= position_y query <= 818 ->
    pyramid_top_floor_min_y <= floor_y ->
    ~ floor_query_can_return query floor_y.
Proof.
  intros query floor_y Hy Hfloor Hquery.
  unfold floor_query_can_return in Hquery.
  rewrite signed16_in_range in Hquery by lia.
  unfold pyramid_top_floor_min_y, find_floor_upward_buffer in *.
  lia.
Qed.

(** Quantitative form of the phase-split residual.  Once the post-copy Y
    coordinate is still in the signed-16 range, a full-coordinate upper-warp
    overlap followed by an accepted numeric floor query at height 1281 or
    above requires at least 385 units of upward State displacement.  The
    historical theorem name does not assert a live, owned, or selected top
    surface.  Nor does the theorem assert that such a writer is reachable; it
    states the narrow lower bound that a reused-slot payload would have to
    meet. *)
Theorem upper_warp_to_live_top_query_requires_385_y_units :
  forall before after floor_y,
    upper_warp_contact before ->
    -32768 <= position_y after < 32768 ->
    pyramid_top_floor_min_y <= floor_y ->
    floor_query_can_return after floor_y ->
    384 < position_y after - position_y before.
Proof.
  intros before after floor_y Hwarp Hafter_range Hfloor Hquery.
  pose proof (upper_warp_contact_y_bounds before Hwarp) as Hbefore.
  unfold floor_query_can_return in Hquery.
  rewrite signed16_in_range in Hquery by exact Hafter_range.
  unfold pyramid_top_floor_min_y, find_floor_upward_buffer in *.
  lia.
Qed.

Definition yaw_only_state_displacement
    (before after : PositionZ) : Prop :=
  position_y after = position_y before.

(** Arithmetic exclusion under the explicit premise that displacement
    preserves Y.  [ClightFacts] checks the stock top's yaw-only source shape,
    and [PyramidTopSurface] imports the concrete matrix-helper bodies and checks
    the concrete home transform.  Connecting their linked Clight memory
    execution to this premise remains an execution-refinement obligation. *)
Theorem stock_yaw_only_top_cannot_seed_upper_warp_bridge :
  forall before after floor_y,
    upper_warp_contact before ->
    yaw_only_state_displacement before after ->
    pyramid_top_floor_min_y <= floor_y ->
    ~ floor_query_can_return after floor_y.
Proof.
  intros before after floor_y Hwarp Hyaw Hfloor.
  apply upper_warp_altitude_cannot_query_live_top_floor.
  - pose proof (upper_warp_contact_y_bounds before Hwarp).
    unfold yaw_only_state_displacement in Hyaw.
    lia.
  - exact Hfloor.
Qed.

(** Transient State/Object separation created by [set_mario_pos] before
    [copy_mario_state_to_object]. *)
Record MarioCoordinatePair : Type := {
  pair_state_position : PositionZ;
  pair_object_position : PositionZ
}.

Definition synchronized_pair (position : PositionZ) : MarioCoordinatePair := {|
  pair_state_position := position;
  pair_object_position := position
|}.

Definition apply_state_only_displacement
    (displaced : PositionZ) (coordinates : MarioCoordinatePair)
    : MarioCoordinatePair := {|
  pair_state_position := displaced;
  pair_object_position := pair_object_position coordinates
|}.

Definition copy_state_position_to_object
    (coordinates : MarioCoordinatePair) : MarioCoordinatePair := {|
  pair_state_position := pair_state_position coordinates;
  pair_object_position := pair_state_position coordinates
|}.

Definition pu_top_floor_candidate : PositionZ := {|
  position_x := 63488;  (* -2048 + 65536 *)
  position_y := 1791;   (* home 1536 + local face height 255 *)
  position_z := -1024
|}.

Definition phase_split_after_displacement : MarioCoordinatePair :=
  apply_state_only_displacement pu_top_floor_candidate
    (synchronized_pair upper_warp_center).

Definition phase_split_after_copy : MarioCoordinatePair :=
  copy_state_position_to_object phase_split_after_displacement.

Theorem concrete_pu_alias_coordinates :
  signed16 (position_x pu_top_floor_candidate) = -2048 /\
  signed16 (position_y pu_top_floor_candidate) = 1791 /\
  signed16 (position_z pu_top_floor_candidate) = -1024 /\
  position_x pu_top_floor_candidate - upper_warp_x = 65536.
Proof. vm_compute. repeat split. Qed.

(** At local X/Z [-1,-1] relative to the home top, the relevant sloped face
    has equation [local_y = local_z + 256], hence local Y 255 and world Y
    1791.  Parsing the five source vertices is separately checked in
    [CollisionMeshFacts]. *)
Theorem concrete_top_face_height_arithmetic :
  signed16 (position_x pu_top_floor_candidate) - pyramid_top_home_x = -1 /\
  signed16 (position_z pu_top_floor_candidate) - pyramid_top_home_z = -1 /\
  (-1 + 256 = 255) /\
  pyramid_top_home_y + 255 = position_y pu_top_floor_candidate.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** The candidate local point [-1,255,-1] lies on the edge from generated
    vertex 4 [-511,-255,-511] to vertex 3 [0,256,0] of generated triangle
    [1,4,3].  The scale 511 avoids introducing mathematical reals.  This is
    source-parsed, manually mirrored arithmetic, not extracted Clight
    transform or edge-test execution. *)
Definition pyramid_top_negative_z_edge_witness : Prop :=
  pyramid_top_negative_z_edge_claim
    pyramid_top_triangles pyramid_top_vertices /\
  511 * (-1) = 1 * (-511) + 510 * 0 /\
  511 * 255 = 1 * (-255) + 510 * 256 /\
  511 * (-1) = 1 * (-511) + 510 * 0.

Theorem pyramid_top_negative_z_edge_witness_holds :
  pyramid_top_negative_z_edge_witness.
Proof.
  unfold pyramid_top_negative_z_edge_witness.
  split.
  - exact pyramid_top_negative_z_edge_claim_holds.
  - repeat split; reflexivity.
Qed.

(** Arithmetic needed for the chosen wrapped top-face candidate.  This does
    not assert that a loaded dynamic surface owns the sample or that
    [find_floor] selects that surface; those remain Clight/surface-refinement
    obligations. *)
Definition pu_top_alias_floor_arithmetic
    (sample : PositionZ) (floor_y : Z) : Prop :=
  signed16 (position_x sample) = -2048 /\
  signed16 (position_y sample) = floor_y /\
  signed16 (position_z sample) = -1024 /\
  signed16 (position_x sample) - pyramid_top_home_x = -1 /\
  signed16 (position_z sample) - pyramid_top_home_z = -1 /\
  (-1 + 256 = 255) /\
  pyramid_top_home_y + 255 = floor_y /\
  floor_y = position_y sample /\
  floor_query_can_return sample floor_y /\
  pyramid_top_negative_z_edge_witness.

Theorem pu_top_candidate_alias_floor_arithmetic :
  pu_top_alias_floor_arithmetic pu_top_floor_candidate 1791.
Proof.
  assert (Hquery :
      floor_query_can_return pu_top_floor_candidate 1791).
  {
    unfold floor_query_can_return, pu_top_floor_candidate,
      find_floor_upward_buffer.
    change (1791 - 78 <= signed16 1791).
    rewrite signed16_in_range by lia.
    lia.
  }
  pose proof pyramid_top_negative_z_edge_witness_holds as Hedge.
  unfold pyramid_top_negative_z_edge_witness in Hedge.
  destruct Hedge as (HsourceEdge & HedgeX & HedgeY & HedgeZ).
  unfold pyramid_top_negative_z_edge_claim in HsourceEdge.
  destruct HsourceEdge as (Hface & Hvertex4 & Hvertex3).
  unfold pu_top_alias_floor_arithmetic, pu_top_floor_candidate,
    pyramid_top_home_x, pyramid_top_home_y, pyramid_top_home_z.
  repeat split; try reflexivity; try lia; assumption.
Qed.

Theorem pu_top_candidate_is_a_capture_sample :
  live_top_platform_capture pu_top_floor_candidate 1791.
Proof.
  unfold live_top_platform_capture, pu_top_floor_candidate,
    pyramid_top_floor_min_y, platform_floor_tolerance.
  cbn.
  lia.
Qed.

Theorem pu_top_candidate_is_not_a_full_float_warp_contact :
  ~ upper_warp_contact pu_top_floor_candidate.
Proof.
  unfold upper_warp_contact, horizontal_distance_squared,
    pu_top_floor_candidate, upper_warp_center, upper_warp_radius,
    mario_hitbox_radius.
  cbn.
  lia.
Qed.

(** Checkable two-sample coordinate countermodel: the collision phase can
    observe the old object at the warp while later phases observe the displaced
    State/copied object at an arithmetic PU top-face candidate.  It is not a
    stale-slot model, a surface-selection theorem, or an execution-reachability
    proof. *)
Theorem phase_split_countermodel_exists :
  upper_warp_contact
    (pair_object_position phase_split_after_displacement) /\
  pair_state_position phase_split_after_displacement =
    pu_top_floor_candidate /\
  pair_object_position phase_split_after_displacement =
    upper_warp_center /\
  pair_object_position phase_split_after_copy =
    pu_top_floor_candidate /\
  live_top_platform_capture
    (pair_object_position phase_split_after_copy) 1791 /\
  pu_top_alias_floor_arithmetic
    (pair_object_position phase_split_after_copy) 1791.
Proof.
  unfold phase_split_after_displacement, phase_split_after_copy,
    apply_state_only_displacement, synchronized_pair,
    copy_state_position_to_object.
  cbn.
  split.
  - unfold upper_warp_contact, horizontal_distance_squared,
      upper_warp_center, upper_warp_radius, mario_hitbox_radius,
      upper_warp_y, upper_warp_height, mario_hitbox_height.
    cbn. repeat split; lia.
  - split; [reflexivity |].
    split; [reflexivity |].
    split; [reflexivity |].
    split.
    + apply pu_top_candidate_is_a_capture_sample.
    + apply pu_top_candidate_alias_floor_arithmetic.
Qed.

Theorem phase_split_candidate_requires_vertical_displacement :
  position_y (pair_state_position phase_split_after_displacement) -
  position_y (pair_object_position phase_split_after_displacement) = 1023.
Proof. reflexivity. Qed.

Theorem xz_only_displacement_cannot_realize_phase_split_candidate :
  ~ yaw_only_state_displacement upper_warp_center pu_top_floor_candidate.
Proof.
  unfold yaw_only_state_displacement, upper_warp_center,
    pu_top_floor_candidate, upper_warp_y.
  cbn. lia.
Qed.

(** Node 0x1E starts a delayed warp.  A one-frame phase split therefore still
    needs a cross-frame lifetime proof showing that the relevant
    platform-transform or top-surface epoch is safe before every platform apply
    and, for the JP retained-pointer construction, survives or is recaptured at
    the Area-2 spawn boundary.

    For each object-update frame, the epoch fields below are sampled after
    terrain-object updates and immediately before platform displacement; this
    prevents a frame-end sample from hiding intervening slot reuse.  The
    phase/timer fields describe the end of that same frame after any
    [initiate_delayed_warp] call, except that the final constructor stops at the
    first Area-2 pre-displacement sample.  Thus the trigger frame ends at timer
    19:
    timer 20 exists only between [level_trigger_warp] and the same frame's
    [initiate_delayed_warp].  Only the relevant action-argument low-word prelude
    from 1 to 0 is constrained; later action updates underflow that low word
    while the delayed timer runs.  After the timer-1 frame comes one normal
    frame that decrements to zero and schedules a two-frame change-area pause.
    Those two pause frames do not run object updates; the following normal
    frame runs [warp_area] before the first Area-2 object update.

    This is a precise shape for the remaining trace obligation, not a theorem
    that such a source execution exists. *)
Inductive DelayedWarpTracePhase : Type :=
| WarpCollisionFrameEnd
| WarpCountdownFrameEnd
| WarpChangeAreaScheduledFrameEnd
| WarpChangeAreaWaitFrameEnd (remaining : nat)
| WarpAreaChangePendingFrameEnd
| WarpArea2FirstPlatformApplyPhase.

Record DelayedWarpFrame : Type := {
  delayed_frame_number : nat;
  delayed_frame_version : GameVersion;
  delayed_frame_phase : DelayedWarpTracePhase;
  delayed_frame_area : nat;
  delayed_frame_action_arg_low : nat;
  delayed_frame_warp_timer : nat;
  delayed_frame_object_update_runs : bool;
  delayed_frame_preapply_platform_transform_epoch : option nat;
  delayed_frame_preapply_top_surface_owner_epoch : option nat;
  delayed_frame_preapply_platform_pointer_epoch : option nat;
  delayed_frame_still_in_area1 : bool;
  delayed_frame_area2_spawn_boundary : bool
}.

Definition delayed_frame_platform_pointer_valid
    (frame : DelayedWarpFrame) : Prop :=
  exists epoch,
    delayed_frame_preapply_platform_pointer_epoch frame = Some epoch /\
    (delayed_frame_preapply_platform_transform_epoch frame = Some epoch \/
     delayed_frame_preapply_top_surface_owner_epoch frame = Some epoch).

Definition delayed_warp_frame_step
    (before after : DelayedWarpFrame) : Prop :=
  delayed_frame_number after = S (delayed_frame_number before) /\
  delayed_frame_version after = delayed_frame_version before /\
  match delayed_frame_phase before with
  | WarpCollisionFrameEnd =>
      delayed_frame_phase after = WarpCountdownFrameEnd /\
      delayed_frame_area before = 1%nat /\
      delayed_frame_area after = 1%nat /\
      delayed_frame_action_arg_low before = 1%nat /\
      delayed_frame_action_arg_low after = 0%nat /\
      delayed_frame_warp_timer before = 0%nat /\
      delayed_frame_warp_timer after = 19%nat /\
      delayed_frame_object_update_runs before = true /\
      delayed_frame_object_update_runs after = true
  | WarpCountdownFrameEnd =>
      delayed_frame_area before = 1%nat /\
      delayed_frame_area after = 1%nat /\
      delayed_frame_object_update_runs before = true /\
      delayed_frame_object_update_runs after = true /\
      ((1 < delayed_frame_warp_timer before)%nat /\
       delayed_frame_phase after = WarpCountdownFrameEnd /\
       S (delayed_frame_warp_timer after) =
         delayed_frame_warp_timer before \/
       delayed_frame_warp_timer before = 1%nat /\
       delayed_frame_phase after = WarpChangeAreaScheduledFrameEnd /\
       delayed_frame_warp_timer after = 0%nat)
  | WarpChangeAreaScheduledFrameEnd =>
      delayed_frame_phase after = WarpChangeAreaWaitFrameEnd 1%nat /\
      delayed_frame_area before = 1%nat /\
      delayed_frame_area after = 1%nat /\
      delayed_frame_warp_timer before = 0%nat /\
      delayed_frame_warp_timer after = 0%nat /\
      delayed_frame_object_update_runs before = true /\
      delayed_frame_object_update_runs after = false
  | WarpChangeAreaWaitFrameEnd remaining =>
      delayed_frame_area before = 1%nat /\
      delayed_frame_area after = 1%nat /\
      delayed_frame_warp_timer before = 0%nat /\
      delayed_frame_warp_timer after = 0%nat /\
      delayed_frame_object_update_runs before = false /\
      delayed_frame_object_update_runs after = false /\
      remaining = 1%nat /\
      delayed_frame_phase after = WarpAreaChangePendingFrameEnd
  | WarpAreaChangePendingFrameEnd =>
      delayed_frame_phase after = WarpArea2FirstPlatformApplyPhase /\
      delayed_frame_area before = 1%nat /\
      delayed_frame_area after = 2%nat /\
      delayed_frame_warp_timer before = 0%nat /\
      delayed_frame_warp_timer after = 0%nat /\
      delayed_frame_object_update_runs before = false /\
      delayed_frame_object_update_runs after = true /\
      delayed_frame_area2_spawn_boundary after = true
  | WarpArea2FirstPlatformApplyPhase =>
      False
  end.

Fixpoint consecutive_delayed_warp_frames
    (frames : list DelayedWarpFrame) : Prop :=
  match frames with
  | before :: (after :: _ as rest) =>
      delayed_warp_frame_step before after /\
      consecutive_delayed_warp_frames rest
  | _ => True
  end.

Definition delayed_warp_top_lifetime_obligation
    (frames : list DelayedWarpFrame) : Prop :=
  exists first_frame final_frame,
    hd_error frames = Some first_frame /\
    last frames first_frame = final_frame /\
    delayed_frame_version first_frame = VersionJP /\
    delayed_frame_phase first_frame = WarpCollisionFrameEnd /\
    delayed_frame_area first_frame = 1%nat /\
    delayed_frame_still_in_area1 first_frame = true /\
    delayed_frame_action_arg_low first_frame = 1%nat /\
    delayed_frame_warp_timer first_frame = 0%nat /\
    delayed_frame_object_update_runs first_frame = true /\
    delayed_frame_platform_pointer_valid first_frame /\
    consecutive_delayed_warp_frames frames /\
    Forall
      (fun frame =>
         (delayed_frame_still_in_area1 frame = true <->
          delayed_frame_area frame = 1%nat) /\
         (delayed_frame_area2_spawn_boundary frame = true ->
          delayed_frame_phase frame = WarpArea2FirstPlatformApplyPhase))
      frames /\
    Forall
      (fun frame =>
         delayed_frame_object_update_runs frame = true ->
         delayed_frame_platform_pointer_valid frame)
      frames /\
    delayed_frame_phase final_frame = WarpArea2FirstPlatformApplyPhase /\
    delayed_frame_area final_frame = 2%nat /\
    delayed_frame_area2_spawn_boundary final_frame = true /\
    delayed_frame_object_update_runs final_frame = true /\
    delayed_frame_platform_pointer_valid final_frame.

(** A small state-level consequence of the US spawn clear.  The generated AST
    contains the US-only direct clear call; deriving [after = None] from its
    Clight memory execution remains a separate refinement obligation. *)
Definition same_platform_epoch
    (before after : option nat) : Prop :=
  exists epoch, before = Some epoch /\ after = Some epoch.

Theorem us_spawn_clear_blocks_retained_epoch_before_first_apply :
  forall before after,
    after = None ->
    ~ same_platform_epoch before after.
Proof.
  intros before after Hclear (epoch & _ & Hretained).
  rewrite Hclear in Hretained.
  discriminate.
Qed.

(** The admission-free arithmetic proposition exported for assumption
    auditing. *)
Definition pyramid_top_pu_arithmetic_claim : Prop :=
  (forall mario floor_y,
      upper_warp_contact mario ->
      live_top_platform_capture mario floor_y ->
      False) /\
  (forall before after floor_y,
      upper_warp_contact before ->
      -32768 <= position_y after < 32768 ->
      pyramid_top_floor_min_y <= floor_y ->
      floor_query_can_return after floor_y ->
      384 < position_y after - position_y before) /\
  (forall before after floor_y,
      upper_warp_contact before ->
      yaw_only_state_displacement before after ->
      pyramid_top_floor_min_y <= floor_y ->
      ~ floor_query_can_return after floor_y) /\
  upper_warp_contact
    (pair_object_position phase_split_after_displacement) /\
  live_top_platform_capture
    (pair_object_position phase_split_after_copy) 1791 /\
  ~ upper_warp_contact pu_top_floor_candidate /\
  pu_top_alias_floor_arithmetic
    (pair_object_position phase_split_after_copy) 1791.

Theorem pyramid_top_pu_arithmetic_kernel :
  pyramid_top_pu_arithmetic_claim.
Proof.
  unfold pyramid_top_pu_arithmetic_claim.
  split.
  - exact one_coordinate_cannot_contact_warp_and_capture_live_top.
  - split.
    + exact upper_warp_to_live_top_query_requires_385_y_units.
    + split.
      * exact stock_yaw_only_top_cannot_seed_upper_warp_bridge.
      * split.
        -- exact (proj1 phase_split_countermodel_exists).
        -- split.
           ++ exact pu_top_candidate_is_a_capture_sample.
           ++ split.
              ** exact pu_top_candidate_is_not_a_full_float_warp_contact.
              ** exact pu_top_candidate_alias_floor_arithmetic.
Qed.

(** Checked bundle, deliberately not a refinement theorem: the exact packed
    LevelScript records, parsed US/JP mesh words, concrete Clight/retail cast
    values, helper-body and guarded-assignment source shapes, and manually
    mirrored transform/edge/integer arithmetic all hold side by side.  The
    missing theorem is what connects those source anchors to one linked Clight
    memory execution and actual live dynamic-surface selection. *)
Theorem pyramid_top_pu_checked_bundle :
  ssl_pu_level_script_claim /\
  pyramid_top_pu_modeled_source_constants /\
  pyramid_top_source_mesh_claim /\
  pyramid_top_source_edge_claim /\
  pyramid_top_surface_semantic_claim /\
  pyramid_top_pu_arithmetic_claim.
Proof.
  split.
  - exact ssl_pu_level_script_checked.
  - split.
    + exact pyramid_top_pu_modeled_source_constants_checked.
    + split.
      * exact pyramid_top_source_mesh_checked.
      * split.
        -- exact pyramid_top_source_edge_checked.
        -- split.
           ++ exact pyramid_top_surface_semantic_kernel.
           ++ exact pyramid_top_pu_arithmetic_kernel.
Qed.
