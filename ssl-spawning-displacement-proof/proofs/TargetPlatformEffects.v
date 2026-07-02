From Coq Require Import ZArith Lia.
From SSLSpawning.Proofs Require Import Spec SSLFacts.

Local Open Scope Z_scope.

Definition vertical_only_platform_fields
    (kind : object_kind) (vertical_velocity : Z) : object_fields := {|
  field_kind := kind;
  field_active := true;
  field_oVelX := 0;
  field_oVelY := vertical_velocity;
  field_oVelZ := 0;
  field_oAngleVelPitch := 0;
  field_oAngleVelYaw := 0;
  field_oAngleVelRoll := 0;
  field_oFaceAnglePitch := 0;
  field_oFaceAngleYaw := 0;
  field_oFaceAngleRoll := 0
|}.

Definition ssl_spindel_first_update_fields : object_fields :=
  spindel_active_fields 4 SpindelForward.

Theorem ssl_spindel_first_update_is_active_motion :
  field_oVelZ ssl_spindel_first_update_fields = 5 /\
  field_oAngleVelPitch ssl_spindel_first_update_fields = 256 /\
  platform_has_useful_spawning_displacement
    ssl_spindel_first_update_fields.
Proof.
  repeat split; try reflexivity.
  left. discriminate.
Qed.

Theorem ssl_spindel_rest_state_has_no_useful_displacement :
  ~ platform_has_useful_spawning_displacement spindel_rest_fields.
Proof.
  apply spindel_rest_fields_are_not_useful.
Qed.

Theorem ssl_spindel_rest_observation_zeroes_useful_components :
  forall slot,
    let observation := observe_platform_fields slot spindel_rest_fields in
    observation_oVelZ observation = 0 /\
    observation_oAngleVelPitch observation = 0.
Proof.
  intros slot.
  split; reflexivity.
Qed.

Theorem vertical_only_platform_fields_not_useful :
  forall kind vertical_velocity,
    ~ platform_has_useful_spawning_displacement
      (vertical_only_platform_fields kind vertical_velocity).
Proof.
  intros kind vertical_velocity [Hz | Hpitch].
  - apply Hz. reflexivity.
  - apply Hpitch. reflexivity.
Qed.

Definition pyramid_elevator_first_update_fields : object_fields :=
  vertical_only_platform_fields KindPyramidElevator 0.

Definition pyramid_elevator_constant_velocity_fields : object_fields :=
  vertical_only_platform_fields KindPyramidElevator (-10).

Theorem pyramid_elevator_first_update_has_no_useful_displacement :
  ~ platform_has_useful_spawning_displacement
    pyramid_elevator_first_update_fields.
Proof.
  apply vertical_only_platform_fields_not_useful.
Qed.

Theorem pyramid_elevator_constant_vertical_motion_has_no_useful_displacement :
  ~ platform_has_useful_spawning_displacement
    pyramid_elevator_constant_velocity_fields.
Proof.
  apply vertical_only_platform_fields_not_useful.
Qed.

Theorem moving_pyramid_wall_vertical_motion_has_no_useful_displacement :
  forall vertical_velocity,
    ~ platform_has_useful_spawning_displacement
      (vertical_only_platform_fields KindMovingPyramidWall vertical_velocity).
Proof.
  apply vertical_only_platform_fields_not_useful.
Qed.

Theorem grindel_vertical_motion_has_no_useful_displacement :
  forall vertical_velocity,
    ~ platform_has_useful_spawning_displacement
      (vertical_only_platform_fields KindGrindel vertical_velocity).
Proof.
  apply vertical_only_platform_fields_not_useful.
Qed.

Definition horizontal_grindel_first_update_fields : object_fields :=
  vertical_only_platform_fields KindHorizontalGrindel 0.

Theorem horizontal_grindel_first_update_has_no_useful_displacement :
  ~ platform_has_useful_spawning_displacement
    horizontal_grindel_first_update_fields.
Proof.
  apply vertical_only_platform_fields_not_useful.
Qed.

Definition horizontal_grindel_later_yaw_0_fields : object_fields := {|
  field_kind := KindHorizontalGrindel;
  field_active := true;
  field_oVelX := 0;
  field_oVelY := 70;
  field_oVelZ := 11;
  field_oAngleVelPitch := 0;
  field_oAngleVelYaw := 0;
  field_oAngleVelRoll := 0;
  field_oFaceAnglePitch := 0;
  field_oFaceAngleYaw := 0;
  field_oFaceAngleRoll := 0
|}.

Definition horizontal_grindel_later_yaw_180_fields : object_fields := {|
  field_kind := KindHorizontalGrindel;
  field_active := true;
  field_oVelX := 0;
  field_oVelY := 70;
  field_oVelZ := -11;
  field_oAngleVelPitch := 0;
  field_oAngleVelYaw := 0;
  field_oAngleVelRoll := 0;
  field_oFaceAnglePitch := 0;
  field_oFaceAngleYaw := 0;
  field_oFaceAngleRoll := 0
|}.

Theorem horizontal_grindel_later_forward_motion_can_be_useful :
  platform_has_useful_spawning_displacement
    horizontal_grindel_later_yaw_0_fields /\
  platform_has_useful_spawning_displacement
    horizontal_grindel_later_yaw_180_fields.
Proof.
  split; unfold platform_has_useful_spawning_displacement;
    simpl; left; discriminate.
Qed.

Definition ssl_inside_ancient_pyramid_star : ssl_object := {|
  ssl_object_kind := KindOther;
  ssl_object_x := 500;
  ssl_object_y := 5050;
  ssl_object_z := -500
|}.

Definition ssl_moving_pyramid_wall_high : ssl_object := {|
  ssl_object_kind := KindMovingPyramidWall;
  ssl_object_x := 858;
  ssl_object_y := 1927;
  ssl_object_z := -2307
|}.

Definition ssl_moving_pyramid_wall_middle_lower_x : ssl_object := {|
  ssl_object_kind := KindMovingPyramidWall;
  ssl_object_x := 730;
  ssl_object_y := 1927;
  ssl_object_z := -2307
|}.

Definition ssl_moving_pyramid_wall_middle_upper_x : ssl_object := {|
  ssl_object_kind := KindMovingPyramidWall;
  ssl_object_x := 1473;
  ssl_object_y := 2567;
  ssl_object_z := -2307
|}.

Definition ssl_moving_pyramid_wall_low : ssl_object := {|
  ssl_object_kind := KindMovingPyramidWall;
  ssl_object_x := 1345;
  ssl_object_y := 2567;
  ssl_object_z := -2307
|}.

Definition ssl_horizontal_grindel_upper : ssl_object := {|
  ssl_object_kind := KindHorizontalGrindel;
  ssl_object_x := -870;
  ssl_object_y := 3840;
  ssl_object_z := 105
|}.

Definition ssl_horizontal_grindel_lower : ssl_object := {|
  ssl_object_kind := KindHorizontalGrindel;
  ssl_object_x := -3362;
  ssl_object_y := 0;
  ssl_object_z := -1385
|}.

Definition ssl_regular_grindel : ssl_object := {|
  ssl_object_kind := KindGrindel;
  ssl_object_x := 3297;
  ssl_object_y := 0;
  ssl_object_z := 95
|}.

Definition ssl_spindel_after_first_z_step : ssl_object := {|
  ssl_object_kind := KindSpindel;
  ssl_object_x := -2458;
  ssl_object_y := 2109;
  ssl_object_z := -1425
|}.

Definition ssl_area2_lower_entry_mario_spawn : ssl_object := {|
  ssl_object_kind := KindOther;
  ssl_object_x := 0;
  ssl_object_y := 300;
  ssl_object_z := 6451
|}.

Definition ssl_area2_top_entry_mario_spawn : ssl_object := {|
  ssl_object_kind := KindOther;
  ssl_object_x := 0;
  ssl_object_y := 5500;
  ssl_object_z := 256
|}.

Definition ssl_pyramid_elevator_top_local_y : Z := 256.

Definition ssl_pyramid_elevator_top_world_y : Z :=
  ssl_object_y ssl_pyramid_elevator + ssl_pyramid_elevator_top_local_y.

Definition square (n : Z) : Z := n * n.

Definition horizontal_distance2 (a b : ssl_object) : Z :=
  square (ssl_object_x a - ssl_object_x b) +
  square (ssl_object_z a - ssl_object_z b).

Definition vertical_delta (a b : ssl_object) : Z :=
  ssl_object_y a - ssl_object_y b.

Theorem top_entry_mario_spawn_is_airborne_above_pyramid_elevator :
  ssl_object_x ssl_area2_top_entry_mario_spawn =
    ssl_object_x ssl_pyramid_elevator /\
  ssl_object_z ssl_area2_top_entry_mario_spawn =
    ssl_object_z ssl_pyramid_elevator /\
  ssl_pyramid_elevator_top_world_y = 5222 /\
  vertical_delta ssl_area2_top_entry_mario_spawn
    ssl_pyramid_elevator = 534 /\
  ssl_object_y ssl_area2_top_entry_mario_spawn -
    ssl_pyramid_elevator_top_world_y = 278.
Proof.
  vm_compute. repeat split.
Qed.

Theorem target_horizontal_distances_to_inside_ancient_pyramid_star :
  horizontal_distance2 ssl_pyramid_elevator
    ssl_inside_ancient_pyramid_star = 821536 /\
  horizontal_distance2 ssl_horizontal_grindel_upper
    ssl_inside_ancient_pyramid_star = 2242925 /\
  horizontal_distance2 ssl_moving_pyramid_wall_middle_lower_x
    ssl_inside_ancient_pyramid_star = 3318149 /\
  horizontal_distance2 ssl_moving_pyramid_wall_high
    ssl_inside_ancient_pyramid_star = 3393413 /\
  horizontal_distance2 ssl_moving_pyramid_wall_low
    ssl_inside_ancient_pyramid_star = 3979274 /\
  horizontal_distance2 ssl_moving_pyramid_wall_middle_upper_x
    ssl_inside_ancient_pyramid_star = 4211978 /\
  horizontal_distance2 ssl_regular_grindel
    ssl_inside_ancient_pyramid_star = 8177234 /\
  horizontal_distance2 ssl_spindel
    ssl_inside_ancient_pyramid_star = 9614664 /\
  horizontal_distance2 ssl_spindel_after_first_z_step
    ssl_inside_ancient_pyramid_star = 9605389 /\
  horizontal_distance2 ssl_horizontal_grindel_lower
    ssl_inside_ancient_pyramid_star = 15698269.
Proof.
  vm_compute. repeat split.
Qed.

Theorem target_vertical_deltas_to_inside_ancient_pyramid_star :
  vertical_delta ssl_pyramid_elevator
    ssl_inside_ancient_pyramid_star = -84 /\
  vertical_delta ssl_horizontal_grindel_upper
    ssl_inside_ancient_pyramid_star = -1210 /\
  vertical_delta ssl_spindel
    ssl_inside_ancient_pyramid_star = -2941 /\
  vertical_delta ssl_moving_pyramid_wall_high
    ssl_inside_ancient_pyramid_star = -3123 /\
  vertical_delta ssl_regular_grindel
    ssl_inside_ancient_pyramid_star = -5050.
Proof.
  vm_compute. repeat split.
Qed.

Theorem area2_mario_spawn_distances_to_inside_ancient_pyramid_star :
  horizontal_distance2 ssl_area2_top_entry_mario_spawn
    ssl_inside_ancient_pyramid_star = 821536 /\
  vertical_delta ssl_area2_top_entry_mario_spawn
    ssl_inside_ancient_pyramid_star = 450 /\
  horizontal_distance2 ssl_area2_lower_entry_mario_spawn
    ssl_inside_ancient_pyramid_star = 48566401 /\
  vertical_delta ssl_area2_lower_entry_mario_spawn
    ssl_inside_ancient_pyramid_star = -4750.
Proof.
  vm_compute. repeat split.
Qed.

Theorem vertical_only_first_update_keeps_mario_velocity_component :
  forall mario kind vertical_velocity,
    mario_position_after_velocity_component
      mario (vertical_only_platform_fields kind vertical_velocity) = mario.
Proof.
  intros mario kind vertical_velocity.
  destruct mario.
  unfold mario_position_after_velocity_component,
    vertical_only_platform_fields.
  simpl.
  repeat rewrite Z.add_0_r.
  reflexivity.
Qed.

Theorem only_pyramid_elevator_is_within_1000_horizontal_units_of_star :
  horizontal_distance2 ssl_pyramid_elevator
    ssl_inside_ancient_pyramid_star <= square 1000 /\
  square 1000 <
    horizontal_distance2 ssl_horizontal_grindel_upper
      ssl_inside_ancient_pyramid_star /\
  square 1000 <
    horizontal_distance2 ssl_moving_pyramid_wall_middle_lower_x
      ssl_inside_ancient_pyramid_star /\
  square 1000 <
    horizontal_distance2 ssl_moving_pyramid_wall_high
      ssl_inside_ancient_pyramid_star /\
  square 1000 <
    horizontal_distance2 ssl_spindel_after_first_z_step
      ssl_inside_ancient_pyramid_star /\
  square 1000 <
    horizontal_distance2 ssl_regular_grindel
      ssl_inside_ancient_pyramid_star /\
  square 1000 <
    horizontal_distance2 ssl_horizontal_grindel_lower
      ssl_inside_ancient_pyramid_star.
Proof.
  unfold horizontal_distance2, square.
  simpl. repeat split; lia.
Qed.

Theorem nearest_scripted_motion_target_is_elevator_by_horizontal_distance :
  horizontal_distance2 ssl_pyramid_elevator
    ssl_inside_ancient_pyramid_star <
    horizontal_distance2 ssl_horizontal_grindel_upper
      ssl_inside_ancient_pyramid_star /\
  horizontal_distance2 ssl_pyramid_elevator
    ssl_inside_ancient_pyramid_star <
    horizontal_distance2 ssl_moving_pyramid_wall_middle_lower_x
      ssl_inside_ancient_pyramid_star /\
  horizontal_distance2 ssl_pyramid_elevator
    ssl_inside_ancient_pyramid_star <
    horizontal_distance2 ssl_spindel_after_first_z_step
      ssl_inside_ancient_pyramid_star /\
  horizontal_distance2 ssl_pyramid_elevator
    ssl_inside_ancient_pyramid_star <
    horizontal_distance2 ssl_regular_grindel
      ssl_inside_ancient_pyramid_star.
Proof.
  unfold horizontal_distance2, square.
  simpl. repeat split; lia.
Qed.
