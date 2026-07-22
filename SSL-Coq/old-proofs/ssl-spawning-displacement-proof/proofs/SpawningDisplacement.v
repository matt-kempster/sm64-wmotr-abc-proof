From Coq Require Import List ZArith Lia.
From SSLSpawning.Proofs Require Import Spec JPSpawn PlatformDisplacement
  FreeListReuse UpdateOrder SSLFacts.

Local Open Scope Z_scope.

Record jp_area_transition_reuse_witness
    (before_spawn after_spawn first_update_state : game_state)
    (old_platform_slot reused_slot : slot) : Prop := {
  witness_platform_before_spawn :
    state_gMarioPlatform before_spawn = Some old_platform_slot;
  witness_spawn_is_jp :
    after_spawn = spawn_objects_from_info_jp_model before_spawn;
  witness_slot_reused :
    reused_slot = old_platform_slot;
  witness_first_update_platform :
    state_gMarioPlatform first_update_state = Some reused_slot;
  witness_first_update_can_apply :
    state_time_stop_active first_update_state = false /\
    state_has_mario_object first_update_state = true
}.

Theorem jp_stale_platform_pointer_can_be_reused_after_area_transition :
  forall before_spawn after_spawn first_update_state
      old_platform_slot reused_slot,
    jp_area_transition_reuse_witness
      before_spawn after_spawn first_update_state
      old_platform_slot reused_slot ->
    state_gMarioPlatform after_spawn = Some old_platform_slot /\
    state_gMarioPlatform first_update_state = Some old_platform_slot.
Proof.
  intros before_spawn after_spawn first_update_state old_platform_slot
    reused_slot Hwitness.
  destruct Hwitness as
    [Hbefore Hspawn Hreuse Hfirst _].
  subst after_spawn reused_slot.
  split.
  - rewrite jp_spawn_preserves_gMarioPlatform.
    exact Hbefore.
  - exact Hfirst.
Qed.

Record ssl_spindel_reuse_first_update
    (state : game_state) (slot : slot) : Prop := {
  ssl_reuse_platform_slot :
    state_gMarioPlatform state = Some slot;
  ssl_reuse_time_active :
    state_time_stop_active state = false;
  ssl_reuse_has_mario :
    state_has_mario_object state = true;
  ssl_reuse_spindel_kind :
    field_kind (state_object_memory state slot) = KindSpindel;
  ssl_reuse_spindel_useful :
    platform_has_useful_spawning_displacement
      (state_object_memory state slot)
}.

Theorem ssl_spindel_reuse_first_update_applies_spindel_fields :
  forall state slot,
    ssl_spindel_reuse_first_update state slot ->
    exists observation,
      apply_mario_platform_displacement_model state = Some observation /\
      observation_slot observation = slot /\
      observation_oVelZ observation =
        field_oVelZ (state_object_memory state slot) /\
      observation_oAngleVelPitch observation =
        field_oAngleVelPitch (state_object_memory state slot) /\
      (observation_oVelZ observation <> 0 \/
       observation_oAngleVelPitch observation <> 0).
Proof.
  intros state slot Hreuse.
  destruct Hreuse as [Hplatform Htime Hmario _ Huseful].
  unfold apply_mario_platform_displacement_model.
  rewrite Htime, Hmario, Hplatform.
  eexists.
  repeat split.
  exact Huseful.
Qed.

Theorem jp_ssl_spindel_stale_platform_core :
  forall state slot divisor direction,
    state_time_stop_active state = false ->
    state_has_mario_object state = true ->
    state_gMarioPlatform state = Some slot ->
    state_object_memory state slot =
      spindel_active_fields divisor direction ->
    valid_spindel_divisor divisor ->
    (event_index UpdateApplyMarioPlatformDisplacement <
     event_index UpdateMarioPlatform)%nat ->
    exists observation,
      apply_mario_platform_displacement_model state = Some observation /\
      observation_slot observation = slot /\
      observation_oVelZ observation =
        signed_by_direction (20 / divisor) direction /\
      observation_oAngleVelPitch observation =
        signed_by_direction (1024 / divisor) direction /\
      (observation_oVelZ observation <> 0 \/
       observation_oAngleVelPitch observation <> 0).
Proof.
  intros state slot divisor direction Htime Hmario Hplatform Hfields
    Hdivisor _.
  unfold apply_mario_platform_displacement_model.
  rewrite Htime, Hmario, Hplatform.
  rewrite Hfields.
  eexists.
  repeat split.
  apply spindel_active_fields_are_useful.
  exact Hdivisor.
Qed.

Theorem unloading_then_spawning_spindel_can_feed_first_update :
  forall free_before free_after_unload free_after_alloc
      old_platform_slot allocated_slot state divisor direction,
    unload_object_pushes free_before old_platform_slot free_after_unload ->
    allocate_object_pops
      free_after_unload allocated_slot free_after_alloc ->
    state_time_stop_active state = false ->
    state_has_mario_object state = true ->
    state_gMarioPlatform state = Some old_platform_slot ->
    state_object_memory state allocated_slot =
      spindel_active_fields divisor direction ->
    valid_spindel_divisor divisor ->
    exists observation,
      allocated_slot = old_platform_slot /\
      apply_mario_platform_displacement_model state = Some observation /\
      observation_slot observation = old_platform_slot /\
      (observation_oVelZ observation <> 0 \/
       observation_oAngleVelPitch observation <> 0).
Proof.
  intros free_before free_after_unload free_after_alloc old_platform_slot
    allocated_slot state divisor direction Hunload Halloc Htime Hmario
    Hplatform Hfields Hdivisor.
  pose proof
    (unload_then_allocate_reuses_same_slot
      free_before free_after_unload free_after_alloc old_platform_slot
      allocated_slot Hunload Halloc) as Hsame.
  subst allocated_slot.
  unfold apply_mario_platform_displacement_model.
  rewrite Htime, Hmario, Hplatform, Hfields.
  eexists.
  repeat split.
  apply spindel_active_fields_are_useful.
  exact Hdivisor.
Qed.

Theorem ssl_spindel_exact_reuse_from_area_unload_depth :
  forall initial_free_list unload_prefix unload_suffix old_platform_slot,
    length unload_suffix = ssl_area2_spindel_required_free_list_depth ->
    nth_allocation_reuses_slot
      (free_list_after_unloads initial_free_list
        (unload_prefix ++ old_platform_slot :: unload_suffix))
      ssl_area2_spindel_allocation_index
      old_platform_slot.
Proof.
  intros initial_free_list unload_prefix unload_suffix old_platform_slot
    Hdepth.
  rewrite ssl_area2_spindel_allocation_position_including_macros.
  rewrite ssl_area2_spindel_required_free_list_depth_is_60 in Hdepth.
  replace 61%nat with (S (length unload_suffix)) by lia.
  apply unload_suffix_depth_gives_exact_reuse_allocation.
Qed.

Theorem concrete_ssl_spindel_route_allocation_feeds_first_update :
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
  exists (observe_platform_fields old_platform_slot
    (spindel_active_fields divisor direction)).
  split.
  - eapply ssl_spindel_exact_reuse_from_area_unload_depth.
    exact Hdepth.
  - split.
    + apply ssl_area2_spindel_is_regular_position_11.
    + split.
      * unfold apply_mario_platform_displacement_model.
        rewrite Htime, Hmario, Hplatform, Hfields.
        reflexivity.
      * split; [reflexivity |].
        split; [reflexivity |].
        split; [reflexivity |].
        apply spindel_active_fields_are_useful.
        exact Hdivisor.
Qed.
