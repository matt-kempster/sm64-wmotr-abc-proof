(** Exact platform-payload witness for the rank-3 nonlocal-State alias.

    The previously checked State-first endpoint needs MarioState at
    [(-1862, 67314, -902)] while the collision Object remains local.  This
    file shows that [apply_platform_displacement]'s arithmetic is numerically
    capable of producing that exact endpoint in one call.  The original
    rotation-only receipt starts from [(-1862, 768, -902)], a point which is
    already horizontally separated from the upper-warp Object sample.  The
    strengthened receipt below starts instead from the actual synchronized
    warp centre [(-2048, 768, -1024)]: the platform's ordinary X/Z velocity
    addition first supplies [(186, 0, 122)], then a 180-degree pitch rotation
    around the pivot [(-1862, 34041, -902)] supplies the vertical mirror.  The
    midpoint identity

      2 * 34041 - 768 = 67314

    makes the operation a binary32-exact mirror.  The generated US and JP
    sine tables contain exact [0], [1], [0], and [-1] values at the four
    indices consumed by the identity and half-turn matrices.

    This is an engine/payload capability, not a clean route.  No theorem here
    installs a non-null platform pointer, produces an object with this remote
    pivot, translation velocity, and angle velocity, or links the functional
    matrix mirror to a live Clight call.  Those are now the precise remaining
    rank-3 obligations. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import AST Floats Integers.
From LessThanOneAPress.Generated Require Import
  us_math_util jp_math_util.
From LessThanOneAPress.Proofs Require Import
  Area1NonlocalEndpointBoundary Area1NonlocalYCastArithmetic Area1PhaseSplit
  FirstTargetRefinement GameTypes PyramidTopPU PyramidTopSurface
  StockWarpTopMotion.

Import ListNotations.
Local Open Scope Z_scope.

Module A1NPM_USMath := us_math_util.
Module A1NPM_JPMath := jp_math_util.

Definition rank3_local_collision_f32 : F32Vec3 := {|
  f32_x := f32_of_Z (-1862);
  f32_y := f32_of_Z 768;
  f32_z := f32_of_Z (-902)
|}.

(** The historical name above denotes the State point used by the first
    rotation-only receipt.  It is not the raw Object sample in the injected
    State-first trace.  That Object is the upper-warp centre below. *)
Definition rank3_synchronized_upper_warp_f32 : F32Vec3 := {|
  f32_x := f32_of_Z (-2048);
  f32_y := f32_of_Z 768;
  f32_z := f32_of_Z (-1024)
|}.

Definition rank3_required_horizontal_velocity_f32 : F32Vec3 := {|
  f32_x := f32_of_Z 186;
  f32_y := f32_of_Z 0;
  f32_z := f32_of_Z 122
|}.

Definition rank3_half_turn_pivot_f32 : F32Vec3 := {|
  f32_x := f32_of_Z (-1862);
  f32_y := f32_of_Z 34041;
  f32_z := f32_of_Z (-902)
|}.

Definition rank3_identity_matrix : F32LinearMatrix :=
  f32_rotate_zxy_from_trig
    (f32_of_Z 0) (f32_of_Z 1)
    (f32_of_Z 0) (f32_of_Z 1)
    (f32_of_Z 0) (f32_of_Z 1).

Definition rank3_pitch_half_turn_matrix : F32LinearMatrix :=
  f32_rotate_zxy_from_trig
    (f32_of_Z 0) (f32_of_Z (-1))
    (f32_of_Z 0) (f32_of_Z 1)
    (f32_of_Z 0) (f32_of_Z 1).

(** This follows the rotation branch of [apply_platform_displacement]:
    subtract the platform pivot, express the vector in the previous frame,
    apply the current frame, and add the pivot back.  X/Z velocity is zero. *)
Definition rank3_half_turn_displaced_state : F32Vec3 :=
  let offset :=
    f32_vec_sub rank3_local_collision_f32 rank3_half_turn_pivot_f32 in
  let relative :=
    f32_linear_transpose_mul rank3_identity_matrix offset in
  let new_offset :=
    f32_linear_mul rank3_pitch_half_turn_matrix relative in
  f32_vec_add rank3_half_turn_pivot_f32 new_offset.

(** The complete one-call source-shaped transform.  The C body adds only the
    platform's X/Z velocity before entering the rotation branch; the Y
    velocity field is ignored. *)
Definition rank3_full_split_velocity_adjusted_state : F32Vec3 := {|
  f32_x := Float32.add
    (f32_x rank3_synchronized_upper_warp_f32)
    (f32_x rank3_required_horizontal_velocity_f32);
  f32_y := f32_y rank3_synchronized_upper_warp_f32;
  f32_z := Float32.add
    (f32_z rank3_synchronized_upper_warp_f32)
    (f32_z rank3_required_horizontal_velocity_f32)
|}.

Definition rank3_full_split_displaced_state : F32Vec3 :=
  let offset :=
    f32_vec_sub rank3_full_split_velocity_adjusted_state
      rank3_half_turn_pivot_f32 in
  let relative :=
    f32_linear_transpose_mul rank3_identity_matrix offset in
  let new_offset :=
    f32_linear_mul rank3_pitch_half_turn_matrix relative in
  f32_vec_add rank3_half_turn_pivot_f32 new_offset.

Theorem rank3_horizontal_velocity_exactly_aligns_mirror_input :
  Float32.cmp Ceq (f32_x rank3_full_split_velocity_adjusted_state)
      (f32_x rank3_local_collision_f32) = true /\
  Float32.cmp Ceq (f32_y rank3_full_split_velocity_adjusted_state)
      (f32_y rank3_local_collision_f32) = true /\
  Float32.cmp Ceq (f32_z rank3_full_split_velocity_adjusted_state)
      (f32_z rank3_local_collision_f32) = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem rank3_full_split_displacement_is_exact_timer131_state :
  Float32.to_bits (f32_x rank3_full_split_displaced_state) =
      Int.repr 3303587840 /\
  Float32.to_bits (f32_y rank3_full_split_displaced_state) =
      Int.repr 1199798528 /\
  Float32.to_bits (f32_z rank3_full_split_displaced_state) =
      Int.repr 3294724096 /\
  Float32.cmp Ceq (f32_x rank3_full_split_displaced_state)
      (vec_x timer131_nonlocal_y_state_float) = true /\
  Float32.cmp Ceq (f32_y rank3_full_split_displaced_state)
      (vec_y timer131_nonlocal_y_state_float) = true /\
  Float32.cmp Ceq (f32_z rank3_full_split_displaced_state)
      (vec_z timer131_nonlocal_y_state_float) = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem rank3_half_turn_displacement_is_exact_timer131_state :
  Float32.to_bits (f32_x rank3_half_turn_displaced_state) =
      Int.repr 3303587840 /\
  Float32.to_bits (f32_y rank3_half_turn_displaced_state) =
      Int.repr 1199798528 /\
  Float32.to_bits (f32_z rank3_half_turn_displaced_state) =
      Int.repr 3294724096 /\
  Float32.cmp Ceq (f32_x rank3_half_turn_displaced_state)
      (vec_x timer131_nonlocal_y_state_float) = true /\
  Float32.cmp Ceq (f32_y rank3_half_turn_displaced_state)
      (vec_y timer131_nonlocal_y_state_float) = true /\
  Float32.cmp Ceq (f32_z rank3_half_turn_displaced_state)
      (vec_z timer131_nonlocal_y_state_float) = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem rank3_half_turn_uses_exact_required_vertical_delta :
  2 * 34041 - 768 = 67314 /\
  67314 - 768 = 66546 /\
  signed16 67314 = 1778.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** A concrete raw payload whose truncated previous pitch is zero and whose
    current pitch is exactly the signed-halfword half-turn. *)
Definition rank3_half_turn_payload : PlatformDisplacementRawPayload := {|
  platform_payload_position := {|
    vec_x := f32_of_Z (-1862);
    vec_y := f32_of_Z 34041;
    vec_z := f32_of_Z (-902)
  |};
  platform_payload_velocity := {|
    vec_x := f32_of_Z 0;
    vec_y := f32_of_Z 0;
    vec_z := f32_of_Z 0
  |};
  platform_payload_face_angle_pitch_s32 := Int.repr 32768;
  platform_payload_face_angle_yaw_s32 := Int.zero;
  platform_payload_face_angle_roll_s32 := Int.zero;
  platform_payload_angle_velocity_pitch_s32 := Int.repr 32768;
  platform_payload_angle_velocity_yaw_s32 := Int.zero;
  platform_payload_angle_velocity_roll_s32 := Int.zero
|}.

(** The payload which supplies the complete synchronized-centre-to-alias
    transform.  It differs from [rank3_half_turn_payload] only in the two
    velocity fields that the C implementation adds before rotating. *)
Definition rank3_full_split_payload : PlatformDisplacementRawPayload := {|
  platform_payload_position := platform_payload_position rank3_half_turn_payload;
  platform_payload_velocity := {|
    vec_x := f32_of_Z 186;
    vec_y := f32_of_Z 0;
    vec_z := f32_of_Z 122
  |};
  platform_payload_face_angle_pitch_s32 :=
    platform_payload_face_angle_pitch_s32 rank3_half_turn_payload;
  platform_payload_face_angle_yaw_s32 :=
    platform_payload_face_angle_yaw_s32 rank3_half_turn_payload;
  platform_payload_face_angle_roll_s32 :=
    platform_payload_face_angle_roll_s32 rank3_half_turn_payload;
  platform_payload_angle_velocity_pitch_s32 :=
    platform_payload_angle_velocity_pitch_s32 rank3_half_turn_payload;
  platform_payload_angle_velocity_yaw_s32 :=
    platform_payload_angle_velocity_yaw_s32 rank3_half_turn_payload;
  platform_payload_angle_velocity_roll_s32 :=
    platform_payload_angle_velocity_roll_s32 rank3_half_turn_payload
|}.

Definition rank3_full_split_payload_claim : Prop :=
  Float32.cmp Ceq
      (vec_x (platform_payload_position rank3_full_split_payload))
      (f32_of_Z (-1862)) = true /\
  Float32.cmp Ceq
      (vec_y (platform_payload_position rank3_full_split_payload))
      (f32_of_Z 34041) = true /\
  Float32.cmp Ceq
      (vec_z (platform_payload_position rank3_full_split_payload))
      (f32_of_Z (-902)) = true /\
  Float32.cmp Ceq
      (vec_x (platform_payload_velocity rank3_full_split_payload))
      (f32_of_Z 186) = true /\
  Float32.cmp Ceq
      (vec_z (platform_payload_velocity rank3_full_split_payload))
      (f32_of_Z 122) = true /\
  platform_payload_previous_face_pitch_s16 rank3_full_split_payload =
      Int.zero /\
  platform_payload_current_face_pitch_s16 rank3_full_split_payload =
      Int.repr (-32768).

Theorem rank3_full_split_payload_fields_are_exact :
  rank3_full_split_payload_claim.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem rank3_half_turn_payload_angles_are_exact :
  platform_payload_previous_face_pitch_s16 rank3_half_turn_payload =
      Int.zero /\
  platform_payload_current_face_pitch_s16 rank3_half_turn_payload =
      Int.repr (-32768) /\
  platform_payload_rotation_pitch_s16 rank3_half_turn_payload =
      Int.repr (-32768) /\
  platform_payload_previous_face_yaw_s16 rank3_half_turn_payload =
      Int.zero /\
  platform_payload_current_face_yaw_s16 rank3_half_turn_payload =
      Int.zero /\
  platform_payload_previous_face_roll_s16 rank3_half_turn_payload =
      Int.zero /\
  platform_payload_current_face_roll_s16 rank3_half_turn_payload =
      Int.zero.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** [sins]/[coss] consume the low signed-halfword angle through a 4096-entry
    table.  These indices tie the raw payload theorem above to the exact table
    entries and matrices used by [rank3_half_turn_displaced_state]. *)
Definition rank3_sine_index (angle : Int.int) : nat :=
  Z.to_nat
    (Z.shiftr (Z.land (Int.unsigned angle) 65535) 4).

Definition rank3_cosine_index (angle : Int.int) : nat :=
  ((rank3_sine_index angle + 1024) mod 4096)%nat.

Theorem rank3_half_turn_payload_trig_indices_are_exact :
  rank3_sine_index
      (platform_payload_previous_face_pitch_s16 rank3_half_turn_payload) =
      0%nat /\
  rank3_cosine_index
      (platform_payload_previous_face_pitch_s16 rank3_half_turn_payload) =
      1024%nat /\
  rank3_sine_index
      (platform_payload_current_face_pitch_s16 rank3_half_turn_payload) =
      2048%nat /\
  rank3_cosine_index
      (platform_payload_current_face_pitch_s16 rank3_half_turn_payload) =
      3072%nat.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition rank3_half_turn_sine_table_claim : Prop :=
  nth_error (gvar_init A1NPM_USMath.v_gSineTable) 0 =
      Some (Init_float32 (Float32.of_bits (Int.repr 0))) /\
  nth_error (gvar_init A1NPM_USMath.v_gSineTable) 1024 =
      Some (Init_float32 (Float32.of_bits (Int.repr 1065353216))) /\
  nth_error (gvar_init A1NPM_USMath.v_gSineTable) 2048 =
      Some (Init_float32 (Float32.of_bits (Int.repr 0))) /\
  nth_error (gvar_init A1NPM_USMath.v_gSineTable) 3072 =
      Some (Init_float32 (Float32.of_bits (Int.repr 3212836864))) /\
  nth_error (gvar_init A1NPM_JPMath.v_gSineTable) 0 =
      Some (Init_float32 (Float32.of_bits (Int.repr 0))) /\
  nth_error (gvar_init A1NPM_JPMath.v_gSineTable) 1024 =
      Some (Init_float32 (Float32.of_bits (Int.repr 1065353216))) /\
  nth_error (gvar_init A1NPM_JPMath.v_gSineTable) 2048 =
      Some (Init_float32 (Float32.of_bits (Int.repr 0))) /\
  nth_error (gvar_init A1NPM_JPMath.v_gSineTable) 3072 =
      Some (Init_float32 (Float32.of_bits (Int.repr 3212836864))).

Theorem rank3_half_turn_sine_table_checked :
  rank3_half_turn_sine_table_claim.
Proof.
  unfold rank3_half_turn_sine_table_claim.
  vm_compute. repeat split; reflexivity.
Qed.

Definition Area1NonlocalPlatformMirrorCheckedBoundary : Prop :=
  rank3_half_turn_sine_table_claim /\
  rank3_full_split_payload_claim /\
  (Float32.to_bits (f32_x rank3_half_turn_displaced_state) =
      Int.repr 3303587840 /\
   Float32.to_bits (f32_y rank3_half_turn_displaced_state) =
      Int.repr 1199798528 /\
   Float32.to_bits (f32_z rank3_half_turn_displaced_state) =
      Int.repr 3294724096) /\
  platform_payload_previous_face_pitch_s16 rank3_half_turn_payload =
      Int.zero /\
  platform_payload_current_face_pitch_s16 rank3_half_turn_payload =
      Int.repr (-32768) /\
  rank3_sine_index
      (platform_payload_previous_face_pitch_s16 rank3_half_turn_payload) =
      0%nat /\
  rank3_sine_index
      (platform_payload_current_face_pitch_s16 rank3_half_turn_payload) =
      2048%nat /\
  signed16 67314 = 1778 /\
  Float32.cmp Ceq (f32_x rank3_full_split_velocity_adjusted_state)
      (f32_x rank3_local_collision_f32) = true /\
  Float32.cmp Ceq (f32_z rank3_full_split_velocity_adjusted_state)
      (f32_z rank3_local_collision_f32) = true /\
  Float32.to_bits (f32_x rank3_full_split_displaced_state) =
      Int.repr 3303587840 /\
  Float32.to_bits (f32_y rank3_full_split_displaced_state) =
      Int.repr 1199798528 /\
  Float32.to_bits (f32_z rank3_full_split_displaced_state) =
      Int.repr 3294724096.

Theorem area1_nonlocal_platform_mirror_checked_boundary_holds :
  Area1NonlocalPlatformMirrorCheckedBoundary.
Proof.
  unfold Area1NonlocalPlatformMirrorCheckedBoundary.
  split; [exact rank3_half_turn_sine_table_checked |].
  split; [exact rank3_full_split_payload_fields_are_exact |].
  pose proof rank3_half_turn_displacement_is_exact_timer131_state as Hstate.
  destruct Hstate as (Hx & Hy & Hz & _).
  split; [repeat split; assumption |].
  pose proof rank3_half_turn_payload_angles_are_exact as Hangles.
  destruct Hangles as (Hprevious & Hcurrent & _).
  split; [exact Hprevious |].
  split; [exact Hcurrent |].
  pose proof rank3_half_turn_payload_trig_indices_are_exact as Hindices.
  destruct Hindices as (Hprevious_index & _ & Hcurrent_index & _).
  split; [exact Hprevious_index |].
  split; [exact Hcurrent_index |].
  split.
  - exact (proj2 (proj2 rank3_half_turn_uses_exact_required_vertical_delta)).
  - pose proof rank3_horizontal_velocity_exactly_aligns_mirror_input as
      (Hxaligned & _ & Hzaligned).
    split; [exact Hxaligned |].
    split; [exact Hzaligned |].
    pose proof rank3_full_split_displacement_is_exact_timer131_state as
      (Hxfull & Hyfull & Hzfull & _).
    repeat split; assumption.
Qed.
