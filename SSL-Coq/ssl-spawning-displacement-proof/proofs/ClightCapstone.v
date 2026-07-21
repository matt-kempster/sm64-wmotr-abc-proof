From Coq Require Import List ZArith.
From SSLSpawning.Proofs Require Import GeneratedClightFacts Spec
  PlatformDisplacement FreeListReuse UpdateOrder SSLFacts SpawningDisplacement.

Local Open Scope Z_scope.
Import ListNotations.

Record linked_jp_clight_spindel_state
    (state : game_state) (platform_slot : slot)
    (divisor : Z) (direction : spindel_direction) : Prop := {
  linked_clight_certificate :
    jp_clight_source_certificate;
  linked_time_stop_inactive :
    state_time_stop_active state = false;
  linked_mario_object_present :
    state_has_mario_object state = true;
  linked_platform_pointer :
    state_gMarioPlatform state = Some platform_slot;
  linked_spindel_slot_fields :
    state_object_memory state platform_slot =
      spindel_active_fields divisor direction;
  linked_spindel_divisor :
    valid_spindel_divisor divisor
}.

Theorem linked_jp_clight_conditional_spindel_capstone :
  forall state platform_slot divisor direction,
    linked_jp_clight_spindel_state
      state platform_slot divisor direction ->
    exists observation,
      apply_mario_platform_displacement_model state = Some observation /\
      observation_slot observation = platform_slot /\
      observation_oVelZ observation =
        signed_by_direction (20 / divisor) direction /\
      observation_oAngleVelPitch observation =
        signed_by_direction (1024 / divisor) direction /\
      (observation_oVelZ observation <> 0 \/
       observation_oAngleVelPitch observation <> 0).
Proof.
  intros state platform_slot divisor direction Hlinked.
  destruct Hlinked as
    [Hcert Htime Hmario Hplatform Hfields Hdivisor].
  pose proof (cert_spawn_no_clear Hcert).
  pose proof (cert_apply_reads_platform Hcert).
  pose proof (cert_apply_calls_platform_displacement Hcert).
  pose proof (cert_apply_no_active_check Hcert).
  pose proof (cert_apply_no_behavior_check Hcert).
  pose proof (cert_apply_no_collision_check Hcert).
  pose proof (cert_update_order Hcert).
  pose proof (cert_area2_macro_count Hcert).
  pose proof (cert_area2_script_has_spindel Hcert).
  pose proof (cert_spindel_behavior_loads_collision_and_loop Hcert).
  pose proof (cert_spindel_loop_raw_slots Hcert).
  eapply jp_ssl_spindel_stale_platform_core; eauto.
  apply first_object_update_applies_before_platform_recompute.
Qed.

Theorem generated_jp_clight_conditional_spindel_capstone :
  forall state platform_slot divisor direction,
    state_time_stop_active state = false ->
    state_has_mario_object state = true ->
    state_gMarioPlatform state = Some platform_slot ->
    state_object_memory state platform_slot =
      spindel_active_fields divisor direction ->
    valid_spindel_divisor divisor ->
    exists observation,
      apply_mario_platform_displacement_model state = Some observation /\
      observation_slot observation = platform_slot /\
      observation_oVelZ observation =
        signed_by_direction (20 / divisor) direction /\
      observation_oAngleVelPitch observation =
        signed_by_direction (1024 / divisor) direction /\
      (observation_oVelZ observation <> 0 \/
       observation_oAngleVelPitch observation <> 0).
Proof.
  intros state platform_slot divisor direction Htime Hmario Hplatform
    Hfields Hdivisor.
  eapply linked_jp_clight_conditional_spindel_capstone.
  econstructor; eauto.
  exact generated_jp_clight_source_certificate.
Qed.

Theorem generated_jp_clight_concrete_spindel_depth_capstone :
  forall initial_free_list unload_prefix unload_suffix old_platform_slot
      state divisor direction,
    length unload_suffix = ssl_area2_spindel_required_free_list_depth ->
    state_time_stop_active state = false ->
    state_has_mario_object state = true ->
    state_gMarioPlatform state = Some old_platform_slot ->
    state_object_memory state old_platform_slot =
      spindel_active_fields divisor direction ->
    valid_spindel_divisor divisor ->
    exists observation,
      nth_allocation_reuses_slot
        (free_list_after_unloads initial_free_list
          (unload_prefix ++ old_platform_slot :: unload_suffix))
        ssl_area2_spindel_allocation_index
        old_platform_slot /\
      nth_error ssl_area2_regular_spawn_order (11 - 1) =
        Some KindSpindel /\
      apply_mario_platform_displacement_model state = Some observation /\
      observation_slot observation = old_platform_slot /\
      observation_oVelZ observation =
        signed_by_direction (20 / divisor) direction /\
      observation_oAngleVelPitch observation =
        signed_by_direction (1024 / divisor) direction /\
      (observation_oVelZ observation <> 0 \/
       observation_oAngleVelPitch observation <> 0).
Proof.
  intros initial_free_list unload_prefix unload_suffix old_platform_slot
    state divisor direction Hdepth Htime Hmario Hplatform Hfields Hdivisor.
  pose proof (cert_area2_macro_count generated_jp_clight_source_certificate).
  pose proof (cert_area2_script_has_spindel generated_jp_clight_source_certificate).
  eapply concrete_ssl_spindel_route_allocation_feeds_first_update; eauto.
Qed.
