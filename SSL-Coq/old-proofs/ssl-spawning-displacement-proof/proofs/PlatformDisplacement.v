From Coq Require Import ZArith.
From SSLSpawning.Proofs Require Import Spec.

Local Open Scope Z_scope.

Definition apply_mario_platform_displacement_model
    (state : game_state) : option platform_displacement_observation :=
  match state_time_stop_active state,
        state_has_mario_object state,
        state_gMarioPlatform state with
  | false, true, Some platform =>
      Some (observe_platform_fields
        platform (state_object_memory state platform))
  | _, _, _ => None
  end.

Theorem apply_displacement_uses_current_gMarioPlatform_pointer :
  forall state platform observation,
    state_time_stop_active state = false ->
    state_has_mario_object state = true ->
    state_gMarioPlatform state = Some platform ->
    apply_mario_platform_displacement_model state = Some observation ->
    observation_slot observation = platform.
Proof.
  intros state platform observation Htime Hmario Hplatform Happly.
  unfold apply_mario_platform_displacement_model in Happly.
  rewrite Htime, Hmario, Hplatform in Happly.
  inversion Happly.
  reflexivity.
Qed.

Theorem apply_mario_platform_displacement_uses_stale_pointer :
  forall state stale_slot,
    state_time_stop_active state = false ->
    state_has_mario_object state = true ->
    state_gMarioPlatform state = Some stale_slot ->
    exists observation,
      apply_mario_platform_displacement_model state = Some observation /\
      observation_slot observation = stale_slot.
Proof.
  intros state stale_slot Htime Hmario Hplatform.
  unfold apply_mario_platform_displacement_model.
  rewrite Htime, Hmario, Hplatform.
  eexists.
  split; reflexivity.
Qed.

Theorem apply_platform_displacement_depends_only_on_object_fields :
  forall state1 state2 platform,
    state_time_stop_active state1 = state_time_stop_active state2 ->
    state_has_mario_object state1 = state_has_mario_object state2 ->
    state_gMarioPlatform state1 = Some platform ->
    state_gMarioPlatform state2 = Some platform ->
    state_object_memory state1 platform =
    state_object_memory state2 platform ->
    apply_mario_platform_displacement_model state1 =
    apply_mario_platform_displacement_model state2.
Proof.
  intros state1 state2 platform Htime Hmario Hplatform1 Hplatform2 Hfields.
  unfold apply_mario_platform_displacement_model.
  rewrite Htime.
  rewrite Hmario.
  rewrite Hplatform1, Hplatform2.
  rewrite Hfields.
  reflexivity.
Qed.

Theorem platform_displacement_adds_xz_velocity_and_rotation :
  forall platform fields,
    let observation := observe_platform_fields platform fields in
    observation_oVelX observation = field_oVelX fields /\
    observation_oVelZ observation = field_oVelZ fields /\
    observation_oAngleVelPitch observation = field_oAngleVelPitch fields /\
    observation_oAngleVelYaw observation = field_oAngleVelYaw fields /\
    observation_oAngleVelRoll observation = field_oAngleVelRoll fields.
Proof.
  intros platform fields.
  repeat split.
Qed.

Theorem platform_displacement_performs_no_platform_validity_checks :
  forall platform fields,
    let observation := observe_platform_fields platform fields in
    observation_checked_active_flags observation = false /\
    observation_checked_behavior observation = false /\
    observation_checked_collision_data observation = false /\
    observation_checked_floor_owner observation = false.
Proof.
  intros platform fields.
  repeat split.
Qed.

Theorem apply_displacement_reads_fields_even_when_slot_inactive :
  forall state platform,
    state_time_stop_active state = false ->
    state_has_mario_object state = true ->
    state_gMarioPlatform state = Some platform ->
    field_active (state_object_memory state platform) = false ->
    exists observation,
      apply_mario_platform_displacement_model state = Some observation /\
      observation_oVelZ observation =
        field_oVelZ (state_object_memory state platform) /\
      observation_oAngleVelPitch observation =
        field_oAngleVelPitch (state_object_memory state platform).
Proof.
  intros state platform Htime Hmario Hplatform _.
  unfold apply_mario_platform_displacement_model.
  rewrite Htime, Hmario, Hplatform.
  eexists.
  repeat split.
Qed.
