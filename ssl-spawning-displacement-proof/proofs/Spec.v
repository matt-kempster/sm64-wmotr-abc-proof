From Coq Require Import List ZArith Lia.

Import ListNotations.
Local Open Scope Z_scope.

Definition slot : Type := Z.

Inductive object_kind : Type :=
| KindPyramidTop
| KindToxBox
| KindExclamationBox
| KindPyramidElevator
| KindMovingPyramidWall
| KindSpindel
| KindGrindel
| KindHorizontalGrindel
| KindOther.

Record object_fields := {
  field_kind : object_kind;
  field_active : bool;
  field_oVelX : Z;
  field_oVelY : Z;
  field_oVelZ : Z;
  field_oAngleVelPitch : Z;
  field_oAngleVelYaw : Z;
  field_oAngleVelRoll : Z;
  field_oFaceAnglePitch : Z;
  field_oFaceAngleYaw : Z;
  field_oFaceAngleRoll : Z
}.

Record mario_state := {
  mario_pos_x : Z;
  mario_pos_y : Z;
  mario_pos_z : Z;
  mario_face_yaw : Z
}.

Record game_state := {
  state_mario : mario_state;
  state_gMarioPlatform : option slot;
  state_has_mario_object : bool;
  state_time_stop_active : bool;
  state_object_memory : slot -> object_fields;
  state_free_list : list slot
}.

Record platform_displacement_observation := {
  observation_slot : slot;
  observation_oVelX : Z;
  observation_oVelZ : Z;
  observation_oAngleVelPitch : Z;
  observation_oAngleVelYaw : Z;
  observation_oAngleVelRoll : Z;
  observation_checked_active_flags : bool;
  observation_checked_behavior : bool;
  observation_checked_collision_data : bool;
  observation_checked_floor_owner : bool
}.

Definition observe_platform_fields
    (watched_slot : slot) (fields : object_fields)
    : platform_displacement_observation := {|
  observation_slot := watched_slot;
  observation_oVelX := field_oVelX fields;
  observation_oVelZ := field_oVelZ fields;
  observation_oAngleVelPitch := field_oAngleVelPitch fields;
  observation_oAngleVelYaw := field_oAngleVelYaw fields;
  observation_oAngleVelRoll := field_oAngleVelRoll fields;
  observation_checked_active_flags := false;
  observation_checked_behavior := false;
  observation_checked_collision_data := false;
  observation_checked_floor_owner := false
|}.

Definition platform_has_rotation (fields : object_fields) : Prop :=
  field_oAngleVelPitch fields <> 0 \/
  field_oAngleVelYaw fields <> 0 \/
  field_oAngleVelRoll fields <> 0.

Definition platform_has_useful_spawning_displacement
    (fields : object_fields) : Prop :=
  field_oVelZ fields <> 0 \/ field_oAngleVelPitch fields <> 0.

Definition mario_position_after_velocity_component
    (mario : mario_state) (fields : object_fields) : mario_state := {|
  mario_pos_x := mario_pos_x mario + field_oVelX fields;
  mario_pos_y := mario_pos_y mario;
  mario_pos_z := mario_pos_z mario + field_oVelZ fields;
  mario_face_yaw := mario_face_yaw mario + field_oAngleVelYaw fields
|}.

Definition object_slot_reused_as
    (before after : game_state) (watched_slot : slot)
    (target_kind : object_kind) : Prop :=
  field_active (state_object_memory before watched_slot) = false /\
  field_active (state_object_memory after watched_slot) = true /\
  field_kind (state_object_memory after watched_slot) = target_kind.

Definition stale_platform_pointer_survives
    (before after : game_state) (watched_slot : slot) : Prop :=
  state_gMarioPlatform before = Some watched_slot /\
  state_gMarioPlatform after = Some watched_slot.

Inductive spindel_direction : Type :=
| SpindelForward
| SpindelBackward.

Definition signed_by_direction (amount : Z) (direction : spindel_direction) : Z :=
  match direction with
  | SpindelForward => amount
  | SpindelBackward => - amount
  end.

Definition valid_spindel_divisor (divisor : Z) : Prop :=
  divisor = 1 \/ divisor = 2 \/ divisor = 4.

Definition spindel_active_fields
    (divisor : Z) (direction : spindel_direction) : object_fields := {|
  field_kind := KindSpindel;
  field_active := true;
  field_oVelX := 0;
  field_oVelY := 0;
  field_oVelZ := signed_by_direction (20 / divisor) direction;
  field_oAngleVelPitch := signed_by_direction (1024 / divisor) direction;
  field_oAngleVelYaw := 0;
  field_oAngleVelRoll := 0;
  field_oFaceAnglePitch := 0;
  field_oFaceAngleYaw := 0;
  field_oFaceAngleRoll := 0
|}.

Definition spindel_rest_fields : object_fields := {|
  field_kind := KindSpindel;
  field_active := true;
  field_oVelX := 0;
  field_oVelY := 0;
  field_oVelZ := 0;
  field_oAngleVelPitch := 0;
  field_oAngleVelYaw := 0;
  field_oAngleVelRoll := 0;
  field_oFaceAnglePitch := 0;
  field_oFaceAngleYaw := 0;
  field_oFaceAngleRoll := 0
|}.

Theorem spindel_active_fields_are_useful :
  forall divisor direction,
    valid_spindel_divisor divisor ->
    platform_has_useful_spawning_displacement
      (spindel_active_fields divisor direction).
Proof.
  intros divisor direction Hvalid.
  unfold valid_spindel_divisor in Hvalid.
  destruct Hvalid as [-> | [-> | ->]];
    destruct direction; vm_compute; left; discriminate.
Qed.

Theorem spindel_rest_fields_are_not_useful :
  ~ platform_has_useful_spawning_displacement spindel_rest_fields.
Proof.
  unfold platform_has_useful_spawning_displacement, spindel_rest_fields.
  simpl.
  tauto.
Qed.
