From Coq Require Import List ZArith Lia.
From SSLSpawning.Proofs Require Import Spec JPSpawn PlatformDisplacement
  FreeListReuse SSLFacts PyramidTopWarp.

Import ListNotations.
Local Open Scope Z_scope.

Definition exclamation_box_behavior_is_surface_object : bool := true.
Definition exclamation_box_behavior_loads_collision_data : bool := true.
Definition exclamation_box_tangible_action_loads_collision_model : bool := true.
Definition dynamic_surface_loader_assigns_owner_object : bool := true.

Theorem source_exclamation_box_loads_owned_surface_collision :
  exclamation_box_behavior_is_surface_object = true /\
  exclamation_box_behavior_loads_collision_data = true /\
  exclamation_box_tangible_action_loads_collision_model = true /\
  dynamic_surface_loader_assigns_owner_object = true.
Proof.
  repeat split.
Qed.

Definition exclamation_box_outline_top_relative_y : Z := 52.
Definition exclamation_box_outline_half_width : Z := 26.
Definition exclamation_box_runtime_scale : Z := 2.

Definition exclamation_box_scaled_top_relative_y : Z :=
  exclamation_box_outline_top_relative_y * exclamation_box_runtime_scale.

Definition exclamation_box_scaled_half_width : Z :=
  exclamation_box_outline_half_width * exclamation_box_runtime_scale.

Definition cloned_platform_slot : slot := 1.

Definition cloned_exclamation_box_x : Z := ssl_top_entry_warp_x.
Definition cloned_exclamation_box_y : Z :=
  ssl_top_entry_warp_y - exclamation_box_scaled_top_relative_y.
Definition cloned_exclamation_box_z : Z := ssl_top_entry_warp_z.

Definition cloned_exclamation_box_top_floor_y : Z :=
  cloned_exclamation_box_y + exclamation_box_scaled_top_relative_y.

Definition cloned_route_mario_hitbox_height : Z := 160.

Definition cloned_route_mario : mario_state := {|
  mario_pos_x := ssl_top_entry_warp_x;
  mario_pos_y := ssl_top_entry_warp_y;
  mario_pos_z := ssl_top_entry_warp_z;
  mario_face_yaw := 0
|}.

Definition within_axis (value center half_width : Z) : Prop :=
  center - half_width <= value <= center + half_width.

Definition point_on_cloned_exclamation_box_top (x y z : Z) : Prop :=
  y = cloned_exclamation_box_top_floor_y /\
  within_axis x cloned_exclamation_box_x exclamation_box_scaled_half_width /\
  within_axis z cloned_exclamation_box_z exclamation_box_scaled_half_width.

Definition within_update_mario_platform_epsilon
    (mario_y floor_y : Z) : Prop :=
  Z.abs (mario_y - floor_y) < 4.

Definition cloned_exclamation_box_fields : object_fields := {|
  field_kind := KindExclamationBox;
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

Definition inactive_other_fields : object_fields := {|
  field_kind := KindOther;
  field_active := false;
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

Definition object_memory_with
    (watched : slot) (fields : object_fields) : slot -> object_fields :=
  fun query =>
    if Z.eqb query watched then fields else inactive_other_fields.

Definition cloned_route_pre_update_state : game_state := {|
  state_mario := cloned_route_mario;
  state_gMarioPlatform := None;
  state_has_mario_object := true;
  state_time_stop_active := false;
  state_object_memory :=
    object_memory_with cloned_platform_slot cloned_exclamation_box_fields;
  state_free_list := []
|}.

Definition update_mario_platform_from_owned_floor_model
    (state : game_state) (owner : slot) : game_state := {|
  state_mario := state_mario state;
  state_gMarioPlatform :=
    if state_has_mario_object state then Some owner else state_gMarioPlatform state;
  state_has_mario_object := state_has_mario_object state;
  state_time_stop_active := state_time_stop_active state;
  state_object_memory := state_object_memory state;
  state_free_list := state_free_list state
|}.

Definition cloned_route_seed_state : game_state :=
  update_mario_platform_from_owned_floor_model
    cloned_route_pre_update_state cloned_platform_slot.

Record cloned_exclamation_box_seed_route
    (state : game_state) (watched : slot) : Prop := {
  cloned_seed_source_facts :
    exclamation_box_behavior_is_surface_object = true /\
    exclamation_box_behavior_loads_collision_data = true /\
    exclamation_box_tangible_action_loads_collision_model = true /\
    dynamic_surface_loader_assigns_owner_object = true;
  cloned_seed_slot :
    watched = cloned_platform_slot;
  cloned_seed_mario_on_box_top :
    point_on_cloned_exclamation_box_top
      (mario_pos_x (state_mario state))
      (mario_pos_y (state_mario state))
      (mario_pos_z (state_mario state));
  cloned_seed_within_floor_epsilon :
    within_update_mario_platform_epsilon
      (mario_pos_y (state_mario state))
      cloned_exclamation_box_top_floor_y;
  cloned_seed_warp_vertical_overlap :
    mario_hitbox_overlaps_top_entry_warp_y
      (mario_pos_y (state_mario state))
      cloned_route_mario_hitbox_height;
  cloned_seed_warp_horizontal_overlap :
    horizontal_distance_squared
      (mario_pos_x (state_mario state))
      (mario_pos_z (state_mario state))
      ssl_top_entry_warp_x
      ssl_top_entry_warp_z <
    ssl_top_entry_warp_radius * ssl_top_entry_warp_radius;
  cloned_seed_object_kind :
    field_kind (state_object_memory state watched) = KindExclamationBox;
  cloned_seed_object_active :
    field_active (state_object_memory state watched) = true;
  cloned_seed_platform_after_update :
    state_gMarioPlatform state = Some watched
}.

Theorem cloned_exclamation_box_top_floor_y_is_warp_y :
  cloned_exclamation_box_top_floor_y = ssl_top_entry_warp_y.
Proof.
  reflexivity.
Qed.

Theorem cloned_exclamation_box_object_y_is_664 :
  cloned_exclamation_box_y = 664.
Proof.
  reflexivity.
Qed.

Theorem cloned_exclamation_box_top_contains_warp_center :
  point_on_cloned_exclamation_box_top
    ssl_top_entry_warp_x ssl_top_entry_warp_y ssl_top_entry_warp_z.
Proof.
  unfold point_on_cloned_exclamation_box_top, within_axis.
  rewrite cloned_exclamation_box_top_floor_y_is_warp_y.
  unfold cloned_exclamation_box_x, cloned_exclamation_box_z,
    exclamation_box_scaled_half_width, exclamation_box_outline_half_width,
    exclamation_box_runtime_scale.
  repeat split; lia.
Qed.

Theorem cloned_exclamation_box_top_is_within_platform_update_epsilon :
  within_update_mario_platform_epsilon
    ssl_top_entry_warp_y cloned_exclamation_box_top_floor_y.
Proof.
  unfold within_update_mario_platform_epsilon.
  rewrite cloned_exclamation_box_top_floor_y_is_warp_y.
  simpl.
  lia.
Qed.

Theorem cloned_exclamation_box_top_overlaps_top_entry_warp_y :
  mario_hitbox_overlaps_top_entry_warp_y
    ssl_top_entry_warp_y cloned_route_mario_hitbox_height.
Proof.
  unfold mario_hitbox_overlaps_top_entry_warp_y,
    vertical_intervals_overlap, cloned_route_mario_hitbox_height.
  destruct ssl_top_entry_warp_vertical_interval_is_768_to_818
    as [Hlow Hhigh].
  rewrite Hlow, Hhigh.
  unfold ssl_top_entry_warp_y.
  lia.
Qed.

Theorem cloned_exclamation_box_top_is_inside_top_entry_warp_radius :
  horizontal_distance_squared
    ssl_top_entry_warp_x ssl_top_entry_warp_z
    ssl_top_entry_warp_x ssl_top_entry_warp_z <
  ssl_top_entry_warp_radius * ssl_top_entry_warp_radius.
Proof.
  unfold horizontal_distance_squared.
  rewrite ssl_top_entry_warp_radius_is_150.
  lia.
Qed.

Theorem update_mario_platform_sets_owned_cloned_surface :
  state_gMarioPlatform cloned_route_seed_state = Some cloned_platform_slot.
Proof.
  reflexivity.
Qed.

Theorem cloned_route_seed_state_is_seed_route :
  cloned_exclamation_box_seed_route
    cloned_route_seed_state cloned_platform_slot.
Proof.
  constructor.
  - apply source_exclamation_box_loads_owned_surface_collision.
  - reflexivity.
  - apply cloned_exclamation_box_top_contains_warp_center.
  - apply cloned_exclamation_box_top_is_within_platform_update_epsilon.
  - apply cloned_exclamation_box_top_overlaps_top_entry_warp_y.
  - apply cloned_exclamation_box_top_is_inside_top_entry_warp_radius.
  - reflexivity.
  - reflexivity.
  - apply update_mario_platform_sets_owned_cloned_surface.
Qed.

Theorem cloned_exclamation_box_seed_route_exists :
  exists state watched,
    cloned_exclamation_box_seed_route state watched.
Proof.
  exists cloned_route_seed_state, cloned_platform_slot.
  apply cloned_route_seed_state_is_seed_route.
Qed.

Theorem jp_spawn_preserves_cloned_exclamation_box_seed :
  forall state watched,
    cloned_exclamation_box_seed_route state watched ->
    state_gMarioPlatform (spawn_objects_from_info_jp_model state) =
    Some watched.
Proof.
  intros state watched Hroute.
  destruct Hroute as [_ _ _ _ _ _ _ _ Hplatform].
  rewrite jp_spawn_preserves_gMarioPlatform.
  exact Hplatform.
Qed.

Definition cloned_route_newer_unload_slots : list slot :=
  map (fun n => Z.of_nat n + 2) (seq 0 60).

Definition cloned_route_unload_order : list slot :=
  cloned_platform_slot :: cloned_route_newer_unload_slots.

Definition cloned_route_spindel_first_update_state : game_state := {|
  state_mario := cloned_route_mario;
  state_gMarioPlatform := Some cloned_platform_slot;
  state_has_mario_object := true;
  state_time_stop_active := false;
  state_object_memory :=
    object_memory_with cloned_platform_slot
      (spindel_active_fields 1 SpindelForward);
  state_free_list := []
|}.

Theorem cloned_route_newer_unload_slot_count_is_60 :
  length cloned_route_newer_unload_slots =
  ssl_area2_spindel_required_free_list_depth.
Proof.
  unfold cloned_route_newer_unload_slots.
  rewrite map_length, seq_length.
  apply ssl_area2_spindel_required_free_list_depth_is_60.
Qed.

Theorem cloned_platform_slot_reused_by_ssl_spindel_allocation :
  nth_allocation_reuses_slot
    (free_list_after_unloads [] cloned_route_unload_order)
    ssl_area2_spindel_allocation_index
    cloned_platform_slot.
Proof.
  unfold cloned_route_unload_order.
  replace ssl_area2_spindel_allocation_index with
    (S (length cloned_route_newer_unload_slots)).
  - change (nth_allocation_reuses_slot
      (free_list_after_unloads []
        ([] ++ cloned_platform_slot :: cloned_route_newer_unload_slots))
      (S (length cloned_route_newer_unload_slots))
      cloned_platform_slot).
    apply unload_suffix_depth_gives_exact_reuse_allocation.
  - rewrite ssl_area2_spindel_allocation_position_including_macros.
    rewrite cloned_route_newer_unload_slot_count_is_60.
    rewrite ssl_area2_spindel_required_free_list_depth_is_60.
    lia.
Qed.

Theorem cloned_platform_route_can_feed_spindel_displacement :
  exists seed_state after_jp_spawn first_update_state observation,
    cloned_exclamation_box_seed_route
      seed_state cloned_platform_slot /\
    after_jp_spawn = spawn_objects_from_info_jp_model seed_state /\
    state_gMarioPlatform after_jp_spawn = Some cloned_platform_slot /\
    nth_allocation_reuses_slot
      (free_list_after_unloads [] cloned_route_unload_order)
      ssl_area2_spindel_allocation_index
      cloned_platform_slot /\
    apply_mario_platform_displacement_model first_update_state =
      Some observation /\
    observation_slot observation = cloned_platform_slot /\
    observation_oVelZ observation = 20 /\
    observation_oAngleVelPitch observation = 1024.
Proof.
  exists cloned_route_seed_state.
  exists (spawn_objects_from_info_jp_model cloned_route_seed_state).
  exists cloned_route_spindel_first_update_state.
  exists (observe_platform_fields cloned_platform_slot
    (spindel_active_fields 1 SpindelForward)).
  split.
  - apply cloned_route_seed_state_is_seed_route.
  - split.
    + reflexivity.
    + split.
      * apply jp_spawn_preserves_cloned_exclamation_box_seed.
        apply cloned_route_seed_state_is_seed_route.
      * split.
        -- apply cloned_platform_slot_reused_by_ssl_spindel_allocation.
        -- split.
           ++ reflexivity.
           ++ repeat split; reflexivity.
Qed.
