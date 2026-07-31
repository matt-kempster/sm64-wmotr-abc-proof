(** Source-bounded analysis of the proposed State-first upper-warp installer.

    The proposed scheduling shape is:

      1. a prior frame leaves [gMarioPlatform] non-null;
      2. the next [apply_mario_platform_displacement] changes MarioState;
      3. [detect_object_collisions] still sees the old MarioObject at SSL
         Area-1 warp node 0x1E; and
      4. MarioState's first geometry query selects the pyramid top, avoiding
         the graphical fallback.

    This file proves that shape impossible for the finite stock pre-apply
    origins in [Area1PlatformExhaustiveness].  It also proves that a pre-query
    writer which preserves Y -- in particular the source-shaped wall push --
    cannot bridge the top's vertical gap.  The live Clight-memory projection
    into the finite origin relation remains an explicit obligation; these
    theorems do not exclude Ink's distinct graphical-retry installer.

    The final section records exact binary32 arithmetic for the downstream JP
    boundary fixture.  That fixture is an emulator observation from an
    injected post-installer state, not a clean-retail reachability theorem. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import Floats Integers.
From LessThanOneAPress.Proofs Require Import
  ASTFacts Area1PhaseSplit Area1PlatformExhaustiveness ClightFacts
  CollisionRegions GameTypes InputSemantics PyramidTopPU.

Import ListNotations.
Local Open Scope Z_scope.

(** A data-bearing statement of the State-first proposal.  The pre-apply
    platform must be non-null for the platform-displacement body to run.  The
    first State query is required to be numerically capable of returning a top
    floor, independently of the still stronger live-list/ownership question. *)
Record StockStateFirstInstallerAttempt : Type := {
  state_first_boundary : Area1StateObjectPhaseBoundary;
  state_first_preapply_platform : option Area1SurfaceOwnerKind;
  state_first_candidate_floor_y : Z;
  state_first_platform_origin :
    StockArea1PreapplyPlatform
      (area1_collision_object_position state_first_boundary)
      state_first_preapply_platform;
  state_first_apply_body_runs :
    state_first_preapply_platform <> None;
  state_first_collision_hits_upper_warp :
    upper_warp_contact
      (area1_collision_object_position state_first_boundary);
  state_first_candidate_is_top_height :
    pyramid_top_floor_min_y <= state_first_candidate_floor_y;
  state_first_query_accepts_height :
    floor_query_can_return
      (area1_displaced_state_position state_first_boundary)
      state_first_candidate_floor_y
}.

(** The contradiction occurs before matrix arithmetic or surface selection:
    every source-bounded stock origin is null at a node-0x1E collision sample,
    so the displacement body cannot run. *)
Theorem no_source_bounded_stock_state_first_installer :
  StockStateFirstInstallerAttempt -> False.
Proof.
  intros attempt.
  pose proof
    (stock_area1_upper_warp_preapply_platform_null
      (area1_collision_object_position (state_first_boundary attempt))
      (state_first_preapply_platform attempt)
      (state_first_platform_origin attempt)
      (state_first_collision_hits_upper_warp attempt)) as Hnull.
  exact (state_first_apply_body_runs attempt Hnull).
Qed.

(** Equivalent negative form, useful when a linked-memory projection produces
    the position and raw platform owner separately. *)
Theorem upper_warp_nonnull_preapply_escapes_stock_origin :
  forall position platform,
    upper_warp_contact position ->
    platform <> None ->
    ~ StockArea1PreapplyPlatform position platform.
Proof.
  intros position platform Hwarp Hnon_null Hstock.
  apply Hnon_null.
  eapply stock_area1_upper_warp_preapply_platform_null; eauto.
Qed.

(** The exact remaining bridge for the preceding theorems.  This is named as
    a proposition, not postulated as an axiom: no result below assumes it. *)
Definition StateFirstStockProjectionObligation
    (project :
      Clight.state ->
        option (PositionZ * option Area1SurfaceOwnerKind)) : Prop :=
  Area1StockPreapplyProjectionSound project.

Theorem projected_stock_state_first_preapply_is_impossible :
  forall project state position platform,
    StateFirstStockProjectionObligation project ->
    project state = Some (position, platform) ->
    upper_warp_contact position ->
    platform <> None ->
    False.
Proof.
  intros project state position platform
    Hsound Hproject Hwarp Hnon_null.
  apply Hnon_null.
  eapply sound_projected_upper_warp_preapply_platform_null; eauto.
Qed.

(** Wall collision may change State X/Z before the first floor query, but the
    stock wall-list update does not change the stored Y.  This relation states
    only the semantic fact needed by the arithmetic proof; connecting every
    live US/JP wall execution to it remains part of the linked writer audit. *)
Definition prequery_writer_preserves_y
    (collision_object displaced_state : PositionZ) : Prop :=
  position_y displaced_state = position_y collision_object.

Theorem y_preserving_prequery_writer_cannot_select_live_top :
  forall collision_object displaced_state floor_y,
    upper_warp_contact collision_object ->
    prequery_writer_preserves_y collision_object displaced_state ->
    pyramid_top_floor_min_y <= floor_y ->
    ~ floor_query_can_return displaced_state floor_y.
Proof.
  intros collision_object displaced_state floor_y
    Hwarp Hy Hfloor.
  apply upper_warp_altitude_cannot_query_live_top_floor.
  - pose proof (upper_warp_contact_y_bounds collision_object Hwarp).
    unfold prequery_writer_preserves_y in Hy.
    lia.
  - exact Hfloor.
Qed.

Record WallOnlyStateFirstAttempt : Type := {
  wall_first_collision_object : PositionZ;
  wall_first_displaced_state : PositionZ;
  wall_first_floor_y : Z;
  wall_first_upper_warp_contact :
    upper_warp_contact wall_first_collision_object;
  wall_first_y_preserved :
    prequery_writer_preserves_y
      wall_first_collision_object wall_first_displaced_state;
  wall_first_top_height :
    pyramid_top_floor_min_y <= wall_first_floor_y;
  wall_first_query_accepts_top :
    floor_query_can_return wall_first_displaced_state wall_first_floor_y
}.

Theorem no_wall_only_state_first_installer :
  WallOnlyStateFirstAttempt -> False.
Proof.
  intros attempt.
  pose proof
    (y_preserving_prequery_writer_cannot_select_live_top
      (wall_first_collision_object attempt)
      (wall_first_displaced_state attempt)
      (wall_first_floor_y attempt)
      (wall_first_upper_warp_contact attempt)
      (wall_first_y_preserved attempt)
      (wall_first_top_height attempt)) as Hcannot.
  exact (Hcannot (wall_first_query_accepts_top attempt)).
Qed.

(** Both generated versions contain the same relevant syntax: the platform
    apply precedes object-collision detection, the apply dereferences the raw
    platform without active/behavior/collision guards, and the geometry path
    performs two wall passes before its first floor query.  These are syntax
    receipts, not small-step execution or pointer-alias proofs. *)
Definition StateFirstSourceShapeReceipts : Prop :=
  wall_position_writer_source_shape_us_claim /\
  wall_position_writer_source_shape_jp_claim /\
  graphical_floor_fallback_source_shape_us_claim /\
  graphical_floor_fallback_source_shape_jp_claim.

Theorem state_first_source_shape_receipts_checked :
  StateFirstSourceShapeReceipts.
Proof.
  unfold StateFirstSourceShapeReceipts.
  split; [exact wall_position_writer_source_shape_us |].
  split; [exact wall_position_writer_source_shape_jp |].
  split; [exact graphical_floor_fallback_source_shape_us |].
  exact graphical_floor_fallback_source_shape_jp.
Qed.

Definition StateFirstSchedulingSourceShapeReceipts : Prop :=
  ident_subsequenceb
    [UOL._clear_dynamic_surfaces;
     UOL._update_terrain_objects;
     UOL._apply_mario_platform_displacement;
     UOL._detect_object_collisions;
     UOL._update_non_terrain_objects;
     UOL._unload_deactivated_objects;
     UOL._update_mario_platform]
    (direct_callees_s (Clight.fn_body UOL.f_update_objects)) = true /\
  ident_subsequenceb
    [JOL._clear_dynamic_surfaces;
     JOL._update_terrain_objects;
     JOL._apply_mario_platform_displacement;
     JOL._detect_object_collisions;
     JOL._update_non_terrain_objects;
     JOL._unload_deactivated_objects;
     JOL._update_mario_platform]
    (direct_callees_s (Clight.fn_body JOL.f_update_objects)) = true /\
  statement_mentions_ident_s UPD._gMarioPlatform
    (Clight.fn_body UPD.f_apply_mario_platform_displacement) = true /\
  assigns_global_ident_s UPD._gMarioPlatform
    (Clight.fn_body UPD.f_apply_mario_platform_displacement) = false /\
  assigns_global_ident_s UPD._gMarioPlatform
    (Clight.fn_body UPD.f_update_mario_platform) = true /\
  assigns_global_ident_s UPD._gMarioPlatform
    (Clight.fn_body UPD.f_clear_mario_platform) = true /\
  statement_mentions_ident_s JPD._gMarioPlatform
    (Clight.fn_body JPD.f_apply_mario_platform_displacement) = true /\
  assigns_global_ident_s JPD._gMarioPlatform
    (Clight.fn_body JPD.f_apply_mario_platform_displacement) = false /\
  assigns_global_ident_s JPD._gMarioPlatform
    (Clight.fn_body JPD.f_update_mario_platform) = true.

Theorem state_first_scheduling_source_shape_receipts_checked :
  StateFirstSchedulingSourceShapeReceipts.
Proof.
  unfold StateFirstSchedulingSourceShapeReceipts.
  vm_compute.
  repeat split.
Qed.

(** The destination entry descent is a cutscene action.  Its generated body
    advances by [mario_set_forward_vel] and [perform_air_step], and contains no
    direct reference to the controller or [intendedYaw].  The action setter
    contains the exact binary32 literal 2.0f and the forward-speed call in both
    translations.  This is a syntax receipt, not a trajectory bound. *)
Definition SpawnSpinDescentSourceShapeReceipts : Prop :=
  calls_ident_s UCutscene._mario_set_forward_vel
    (Clight.fn_body UCutscene.f_act_spawn_spin_airborne) = true /\
  calls_ident_s UCutscene._perform_air_step
    (Clight.fn_body UCutscene.f_act_spawn_spin_airborne) = true /\
  statement_mentions_ident_s UCutscene._controller
    (Clight.fn_body UCutscene.f_act_spawn_spin_airborne) = false /\
  statement_mentions_ident_s UCutscene._intendedYaw
    (Clight.fn_body UCutscene.f_act_spawn_spin_airborne) = false /\
  calls_ident_s JCutscene._mario_set_forward_vel
    (Clight.fn_body JCutscene.f_act_spawn_spin_airborne) = true /\
  calls_ident_s JCutscene._perform_air_step
    (Clight.fn_body JCutscene.f_act_spawn_spin_airborne) = true /\
  statement_mentions_ident_s JCutscene._controller
    (Clight.fn_body JCutscene.f_act_spawn_spin_airborne) = false /\
  statement_mentions_ident_s JCutscene._intendedYaw
    (Clight.fn_body JCutscene.f_act_spawn_spin_airborne) = false /\
  calls_ident_s UMI._mario_set_forward_vel
    (Clight.fn_body UMI.f_set_mario_action_cutscene) = true /\
  statement_mentions_float32_bits_s 1073741824
    (Clight.fn_body UMI.f_set_mario_action_cutscene) = true /\
  calls_ident_s JMI._mario_set_forward_vel
    (Clight.fn_body JMI.f_set_mario_action_cutscene) = true /\
  statement_mentions_float32_bits_s 1073741824
    (Clight.fn_body JMI.f_set_mario_action_cutscene) = true.

Theorem spawn_spin_descent_source_shape_receipts_checked :
  SpawnSpinDescentSourceShapeReceipts.
Proof.
  unfold SpawnSpinDescentSourceShapeReceipts.
  vm_compute.
  repeat split.
Qed.

(** Exact observations from the authentic-JP post-installer boundary fixture.
    At global timer 516 the first Area-2 poll sees the already-displaced State.
    The fixture then holds stick (-127,-96) for 60 polls and releases it.  At
    timer 594 the following Mario sample overlaps the upper hidden-star
    trigger in the project's binary32 hitbox model; the trace first observes
    the trigger inactive and the hidden-star counter equal to one at timer
    595. *)
Definition jp_observed_first_area2_state : Vec3f := {|
  vec_x := f32_bits 1136053216;  (* 365.5927734375f *)
  vec_y := f32_bits 1168891904;  (* 5500.0f *)
  vec_z := f32_bits 3297319343   (* -1096.8026123046875f *)
|}.

Definition jp_observed_upper_trigger_collision_sample : Vec3f := {|
  vec_x := f32_bits 1136866788;  (* 390.4210205078125f *)
  vec_y := f32_bits 1165660160;  (* 4009.0f *)
  vec_z := f32_bits 3289674026   (* -593.7681884765625f *)
|}.

Definition ssl_upper_hidden_trigger_position : Vec3f := {|
  vec_x := f32_bits 1132593152;  (* 260.0f *)
  vec_y := f32_bits 1165266944;  (* 3913.0f *)
  vec_z := f32_bits 3289776128   (* -600.0f *)
|}.

Theorem jp_observed_upper_trigger_sample_overlaps_binary32_model :
  hitboxes_overlap
    jp_observed_upper_trigger_collision_sample mario_standard_hitbox_f32
    ssl_upper_hidden_trigger_position hidden_trigger_hitbox = true.
Proof. vm_compute. reflexivity. Qed.

(** The same fixture's spawn-spin descent reaches the Act-3 star's vertical
    band while still far outside its horizontal interaction radius.  This is
    a rejection of the observed payload/sample, not every possible stale-slot
    payload or a later return route. *)
Definition jp_observed_act3_height_sample : Vec3f := {|
  vec_x := f32_bits 1136053216;  (* 365.5927734375f *)
  vec_y := f32_bits 1168031744;  (* 5080.0f *)
  vec_z := f32_bits 3297140736   (* -1075.0f *)
|}.

Theorem jp_observed_act3_height_sample_does_not_collect_act3 :
  hitboxes_overlap
    jp_observed_act3_height_sample mario_standard_hitbox_f32
    act3_static_position collect_star_hitbox = false.
Proof. vm_compute. reflexivity. Qed.

Definition zero_a_frame : FrameInput := {|
  frame_previous_down := Int.zero;
  frame_current_down := Int.zero
|}.

(** Timer 516 through timer 595 inclusive contains eighty controller samples.
    The joystick axes are orthogonal to this button history. *)
Definition jp_observed_first_apply_to_upper_trigger_inputs : list FrameInput :=
  repeat zero_a_frame 80.

Theorem jp_observed_downstream_schedule_has_no_a_edge :
  length jp_observed_first_apply_to_upper_trigger_inputs = 80%nat /\
  fewer_than_one_a_press
    jp_observed_first_apply_to_upper_trigger_inputs.
Proof.
  split.
  - reflexivity.
  - unfold jp_observed_first_apply_to_upper_trigger_inputs,
      fewer_than_one_a_press.
    repeat constructor; vm_compute.
Qed.

(** What is closed, and what remains.  In particular, the downstream witness
    establishes a viable continuation *conditional on installer injection*;
    it does not supply the missing clean-retail Layer-1 installer. *)
Definition StateFirstCheckedBoundary : Prop :=
  (StockStateFirstInstallerAttempt -> False) /\
  (WallOnlyStateFirstAttempt -> False) /\
  StateFirstSourceShapeReceipts /\
  StateFirstSchedulingSourceShapeReceipts /\
  SpawnSpinDescentSourceShapeReceipts /\
  hitboxes_overlap
    jp_observed_upper_trigger_collision_sample mario_standard_hitbox_f32
    ssl_upper_hidden_trigger_position hidden_trigger_hitbox = true /\
  hitboxes_overlap
    jp_observed_act3_height_sample mario_standard_hitbox_f32
    act3_static_position collect_star_hitbox = false /\
  fewer_than_one_a_press
    jp_observed_first_apply_to_upper_trigger_inputs.

Theorem state_first_checked_boundary_holds :
  StateFirstCheckedBoundary.
Proof.
  unfold StateFirstCheckedBoundary.
  split; [exact no_source_bounded_stock_state_first_installer |].
  split; [exact no_wall_only_state_first_installer |].
  split; [exact state_first_source_shape_receipts_checked |].
  split; [exact state_first_scheduling_source_shape_receipts_checked |].
  split; [exact spawn_spin_descent_source_shape_receipts_checked |].
  split; [exact jp_observed_upper_trigger_sample_overlaps_binary32_model |].
  split; [exact jp_observed_act3_height_sample_does_not_collect_act3 |].
  exact (proj2 jp_observed_downstream_schedule_has_no_a_edge).
Qed.
