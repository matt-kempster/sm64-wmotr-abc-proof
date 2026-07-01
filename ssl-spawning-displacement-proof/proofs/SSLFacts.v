From Coq Require Import List ZArith Lia.
From SSLSpawning.Proofs Require Import Spec.

Import ListNotations.
Local Open Scope Z_scope.

Record ssl_object := {
  ssl_object_kind : object_kind;
  ssl_object_x : Z;
  ssl_object_y : Z;
  ssl_object_z : Z
}.

Definition ssl_pyramid_top : ssl_object := {|
  ssl_object_kind := KindPyramidTop;
  ssl_object_x := -2047;
  ssl_object_y := 1536;
  ssl_object_z := -1023
|}.

Definition ssl_tox_box_1 : ssl_object := {|
  ssl_object_kind := KindToxBox;
  ssl_object_x := -1284;
  ssl_object_y := 0;
  ssl_object_z := -5895
|}.

Definition ssl_tox_box_2 : ssl_object := {|
  ssl_object_kind := KindToxBox;
  ssl_object_x := 1283;
  ssl_object_y := 0;
  ssl_object_z := -4865
|}.

Definition ssl_tox_box_3 : ssl_object := {|
  ssl_object_kind := KindToxBox;
  ssl_object_x := 4873;
  ssl_object_y := 0;
  ssl_object_z := -3335
|}.

Definition ssl_spindel : ssl_object := {|
  ssl_object_kind := KindSpindel;
  ssl_object_x := -2458;
  ssl_object_y := 2109;
  ssl_object_z := -1430
|}.

Definition ssl_pyramid_elevator : ssl_object := {|
  ssl_object_kind := KindPyramidElevator;
  ssl_object_x := 0;
  ssl_object_y := 4966;
  ssl_object_z := 256
|}.

Definition ssl_area1_seed_platforms : list ssl_object := [
  ssl_pyramid_top;
  ssl_tox_box_1;
  ssl_tox_box_2;
  ssl_tox_box_3
].

Definition ssl_area2_regular_spawn_order : list object_kind := [
  KindOther;
  KindOther;
  KindOther;
  KindOther;
  KindOther;
  KindPyramidElevator;
  KindMovingPyramidWall;
  KindMovingPyramidWall;
  KindMovingPyramidWall;
  KindMovingPyramidWall;
  KindSpindel;
  KindHorizontalGrindel;
  KindHorizontalGrindel;
  KindGrindel;
  KindOther;
  KindOther;
  KindOther;
  KindOther;
  KindOther;
  KindOther
].

Definition ssl_area1_macro_object_count : nat := 46.
Definition ssl_area2_macro_object_count : nat := 50.

Theorem ssl_area2_macro_count_is_50 :
  ssl_area2_macro_object_count = 50%nat.
Proof.
  reflexivity.
Qed.

Theorem ssl_area1_macro_count_is_46 :
  ssl_area1_macro_object_count = 46%nat.
Proof.
  reflexivity.
Qed.

Theorem ssl_area2_regular_spawn_count_is_20 :
  length ssl_area2_regular_spawn_order = 20%nat.
Proof.
  reflexivity.
Qed.

Theorem ssl_area2_spindel_regular_spawn_position :
  nth_error ssl_area2_regular_spawn_order 10 = Some KindSpindel.
Proof.
  reflexivity.
Qed.

Theorem ssl_area2_pyramid_elevator_regular_spawn_position :
  nth_error ssl_area2_regular_spawn_order 5 = Some KindPyramidElevator.
Proof.
  reflexivity.
Qed.

Theorem ssl_area2_spindel_allocation_position_including_macros :
  (ssl_area2_macro_object_count + 11 = 61)%nat.
Proof.
  reflexivity.
Qed.

Theorem ssl_area2_pyramid_elevator_allocation_position_including_macros :
  (ssl_area2_macro_object_count + 6 = 56)%nat.
Proof.
  reflexivity.
Qed.

Theorem ssl_area2_moving_wall_allocation_positions_including_macros :
  (ssl_area2_macro_object_count + 7 = 57)%nat /\
  (ssl_area2_macro_object_count + 8 = 58)%nat /\
  (ssl_area2_macro_object_count + 9 = 59)%nat /\
  (ssl_area2_macro_object_count + 10 = 60)%nat.
Proof.
  repeat split.
Qed.

Theorem ssl_area2_grindel_allocation_positions_including_macros :
  (ssl_area2_macro_object_count + 12 = 62)%nat /\
  (ssl_area2_macro_object_count + 13 = 63)%nat /\
  (ssl_area2_macro_object_count + 14 = 64)%nat.
Proof.
  repeat split.
Qed.

Theorem ssl_spindel_has_useful_z_velocity_and_pitch_angle_velocity :
  forall divisor direction,
    valid_spindel_divisor divisor ->
    platform_has_useful_spawning_displacement
      (spindel_active_fields divisor direction).
Proof.
  apply spindel_active_fields_are_useful.
Qed.

Theorem ssl_spindel_active_values_are_source_values :
  forall direction,
    (field_oVelZ (spindel_active_fields 4 direction) = signed_by_direction 5 direction /\
     field_oAngleVelPitch (spindel_active_fields 4 direction) =
       signed_by_direction 256 direction) /\
    (field_oVelZ (spindel_active_fields 2 direction) = signed_by_direction 10 direction /\
     field_oAngleVelPitch (spindel_active_fields 2 direction) =
       signed_by_direction 512 direction) /\
    (field_oVelZ (spindel_active_fields 1 direction) = signed_by_direction 20 direction /\
     field_oAngleVelPitch (spindel_active_fields 1 direction) =
       signed_by_direction 1024 direction).
Proof.
  intros direction.
  destruct direction; repeat split; reflexivity.
Qed.

Theorem pyramid_top_yaw_can_be_useful_when_offset_is_nonzero :
  forall yaw_delta mario_x platform_x mario_z platform_z,
    yaw_delta <> 0 ->
    (mario_x <> platform_x \/ mario_z <> platform_z) ->
    yaw_delta <> 0 /\
    (mario_x - platform_x <> 0 \/ mario_z - platform_z <> 0).
Proof.
  intros yaw_delta mario_x platform_x mario_z platform_z Hyaw Hoffset.
  split; [exact Hyaw |].
  destruct Hoffset as [Hx | Hz].
  - left. lia.
  - right. lia.
Qed.
