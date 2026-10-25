(* ====================================================================== *)
(* ObjTable.v -- GENERATED (scratchpad gen_objtable.py, from the ObjKit    *)
(* sig-inference probe): the class signature of every body a non-Mario    *)
(* object slot runs in WMotR (the behavior VM's command functions, the    *)
(* live natives, and everything they call directly), and of the leaves   *)
(* the walk stops at.  Nothing here is trusted: ObjKit re-checks every     *)
(* entry against the generated Clight (ot_walk_ok, one vm sweep).          *)
(* Part of OBJECTS S3 (spine via ObjKit).                                 *)
(* ====================================================================== *)
From Coq Require Import List Bool.
From compcert Require Import Coqlib Maps AST Ctypes Clight Clightdefs.
From SM64.Generated Require mario audio_external behavior_actions behavior_script camera debug
  graph_node mario_actions_cutscene math_util memory obj_behaviors obj_behaviors_2
  object_helpers object_list_processor print save_file spawn_object spawn_sound
  surface_collision surface_load.
From SM64.Proofs Require Import UcKit LinkedTwelve CensusV2 SpawnInit.
Import ListNotations.

(* the linked TUs, mario.c first (LinkedTwelve.linked12's order) *)
Definition lprogs : list Clight.program := mario.prog :: tu_rest.

(* the SafeB-classified globals: every variable of a linked TU outside
   non_safeb_syms (any SafeB_wit-shaped SafeB contains their blocks; the
   walk's premise Hgs) *)
Definition gs_of (l : list Clight.program) : list ident :=
  flat_map (fun p => flat_map (fun '(id, g) =>
    match g with
    | Gvar _ => if mem_id id non_safeb_syms then nil else [id]
    | _ => nil
    end) (prog_defs p)) l.

Definition obj_gs : list ident := gs_of lprogs.

(* over an ABSTRACT TU list (never unfold the linked programs) *)
Lemma gs_of_not_nonsafe : forall l x, mem_id x (gs_of l) = true -> mem_id x non_safeb_syms = false.
Proof.
  intros l x H. unfold mem_id in H. apply existsb_exists in H as (y & Hy & E).
  apply Pos.eqb_eq in E. subst y. unfold gs_of in Hy.
  apply in_flat_map in Hy as (p & _ & Hy). apply in_flat_map in Hy as ([id g] & _ & Hy).
  destruct g as [fd | v]; [ destruct Hy | ].
  destruct (mem_id id non_safeb_syms) eqn:E; [ destruct Hy | ].
  destruct Hy as [<- | []]. exact E.
Qed.

Lemma obj_gs_not_nonsafe : forall x, mem_id x obj_gs = true -> mem_id x non_safeb_syms = false.
Proof. exact (gs_of_not_nonsafe lprogs). Qed.

(* the walked bodies: (function, index of its TU in lprogs, signature) *)
Definition otab : list (ident * nat * usig) := [
  (obj_behaviors._wing_vanish_cap_act_0, 43%nat, ([], kN, false));
  (graph_node._geo_obj_init_animation, 18%nat, ([kS; kS], kN, false));
  (graph_node._geo_obj_init, 18%nat, ([kS; kS; kS; kS], kN, false));
  (graph_node._geo_add_child, 18%nat, ([kS; kS], kS, false));
  (graph_node._geo_remove_child, 18%nat, ([kS], kS, false));
  (object_helpers._get_object_list_from_behavior, 21%nat, ([kS], kN, false));
  (obj_behaviors._object_step, 43%nat, ([], kN, false));
  (obj_behaviors._obj_orient_graph, 43%nat, ([kS; kN; kN; kN], kN, false));
  (object_helpers._obj_copy_angle, 21%nat, ([kS; kS], kN, false));
  (object_helpers._obj_copy_pos_and_angle, 21%nat, ([kS; kS], kN, false));
  (object_helpers._obj_copy_pos, 21%nat, ([kS; kS], kN, false));
  (object_helpers._obj_check_if_collided_with_object, 21%nat, ([kS; kS], kN, false));
  (obj_behaviors._obj_check_floor_death, 43%nat, ([kN; kS], kN, false));
  (object_helpers._obj_scale_xyz, 21%nat, ([kS; kN; kN; kN], kN, false));
  (object_helpers._obj_scale_random, 21%nat, ([kS; kN; kN], kN, false));
  (object_helpers._obj_scale, 21%nat, ([kS; kN], kN, false));
  (object_helpers._obj_set_angle, 21%nat, ([kS; kN; kN; kN], kN, false));
  (object_helpers._obj_set_hitbox, 21%nat, ([kS; kS], kN, false));
  (object_helpers._obj_set_pos, 21%nat, ([kS; kN; kN; kN], kN, false));
  (object_helpers._obj_set_parent_relative_pos, 21%nat, ([kS; kW; kW; kW], kN, false));
  (object_helpers._obj_set_billboard, 21%nat, ([kS], kN, false));
  (object_helpers._obj_spawn_loot_coins, 21%nat, ([kS; kS; kN; kS; kN; kN], kN, false));
  (object_helpers._obj_spawn_loot_yellow_coins, 21%nat, ([kS; kS; kN], kN, false));
  (object_helpers._obj_spawn_loot_blue_coins, 21%nat, ([kS; kS; kN; kN], kN, false));
  (obj_behaviors._obj_splash, 43%nat, ([kN; kN], kN, false));
  (object_helpers._obj_init_animation_with_sound, 21%nat, ([kS; kS; kN], kN, false));
  (object_helpers._obj_apply_scale_to_matrix, 21%nat, ([kS; kL; kS], kN, false));
  (obj_behaviors._obj_move_xyz_using_fvel_and_yaw, 43%nat, ([kS], kN, false));
  (object_helpers._obj_mark_for_deletion, 21%nat, ([kS], kN, false));
  (object_helpers._obj_explode_and_spawn_coins, 21%nat, ([kN; kN], kN, false));
  (obj_behaviors._obj_update_pos_vel_xz, 43%nat, ([], kN, false));
  (object_helpers._obj_turn_toward_object, 21%nat, ([kS; kS; kN; kN], kN, false));
  (object_helpers._obj_translate_xyz_random, 21%nat, ([kS; kN], kN, false));
  (object_helpers._obj_translate_xz_random, 21%nat, ([kS; kN], kN, false));
  (object_helpers._obj_translate_local, 21%nat, ([kS; kN; kN], kN, false));
  (object_helpers._obj_build_transform_from_pos_and_angle, 21%nat, ([kS; kN; kN], kN, false));
  (object_helpers._obj_build_relative_transform, 21%nat, ([kS], kN, false));
  (obj_behaviors._obj_find_wall, 43%nat, ([kN; kN; kN; kN; kN], kN, false));
  (obj_behaviors._obj_flicker_and_disappear, 43%nat, ([kS; kN], kN, false));
  (obj_behaviors._one_up_move_away_from_mario, 43%nat, ([kN], kN, false));
  (obj_behaviors._one_up_loop_in_air, 43%nat, ([], kN, false));
  (behavior_actions._koopa_shell_spawn_water_drop, 9%nat, ([], kN, false));
  (behavior_actions._koopa_shell_spawn_sparkles, 9%nat, ([kN], kN, false));
  (obj_behaviors._coin_collected, 43%nat, ([], kN, false));
  (obj_behaviors._coin_step, 43%nat, ([kL], kN, false));
  (object_helpers._count_objects_with_behavior, 21%nat, ([kS], kN, false));
  (obj_behaviors._cap_check_quicksand, 43%nat, ([], kN, false));
  (obj_behaviors._cap_scale_vertically, 43%nat, ([], kN, false));
  (obj_behaviors._cap_sink_quicksand, 43%nat, ([], kN, false));
  (obj_behaviors._cap_set_hitbox, 43%nat, ([], kN, false));
  (obj_behaviors._cap_despawn, 43%nat, ([], kN, false));
  (obj_behaviors._calc_obj_friction, 43%nat, ([kL; kN], kN, false));
  (obj_behaviors._calc_new_obj_vel_and_pos_y_underwater, 43%nat, ([kS; kN; kN; kN; kN], kN, false));
  (obj_behaviors._calc_new_obj_vel_and_pos_y, 43%nat, ([kS; kN; kN; kN], kN, false));
  (obj_behaviors._cannon_door_act_opening, 43%nat, ([], kN, false));
  (obj_behaviors._celeb_star_act_spin_around_mario, 43%nat, ([], kN, false));
  (obj_behaviors._celeb_star_act_face_camera, 43%nat, ([], kN, false));
  (camera._cutscene_object_with_dialog, 34%nat, ([kN; kS; kS], kN, false));
  (camera._cutscene_object, 34%nat, ([kN; kS], kN, false));
  (object_helpers._cur_obj_within_12k_bounds, 21%nat, ([], kN, false));
  (object_helpers._cur_obj_wait_then_blink, 21%nat, ([kN; kN], kN, false));
  (object_helpers._cur_obj_get_dropped, 21%nat, ([], kN, false));
  (object_helpers._cur_obj_get_thrown_or_placed, 21%nat, ([kN; kN; kN], kN, false));
  (object_helpers._cur_obj_compute_vel_xz, 21%nat, ([], kN, false));
  (object_helpers._cur_obj_check_if_near_animation_end, 21%nat, ([], kN, false));
  (object_helpers._cur_obj_scale, 21%nat, ([kN], kN, false));
  (object_helpers._cur_obj_set_model, 21%nat, ([kN], kN, false));
  (object_helpers._cur_obj_set_pos_relative_to_parent, 21%nat, ([kN; kN; kN], kN, false));
  (object_helpers._cur_obj_set_pos_relative, 21%nat, ([kS; kN; kN; kN], kN, false));
  (object_helpers._cur_obj_set_behavior, 21%nat, ([kS], kN, false));
  (object_helpers._cur_obj_spawn_particles, 21%nat, ([kS], kN, false));
  (object_helpers._cur_obj_init_animation_with_sound, 21%nat, ([kN], kN, false));
  (object_helpers._cur_obj_if_hit_wall_bounce_away, 21%nat, ([], kN, false));
  (object_helpers._cur_obj_apply_drag_xz, 21%nat, ([kN], kN, false));
  (object_helpers._cur_obj_angle_to_home, 21%nat, ([], kN, false));
  (object_helpers._cur_obj_move_standard, 21%nat, ([kN], kN, false));
  (object_helpers._cur_obj_move_y_and_get_water_level, 21%nat, ([kN; kN], kN, false));
  (object_helpers._cur_obj_move_y, 21%nat, ([kN; kN; kN], kN, false));
  (object_helpers._cur_obj_move_after_thrown_or_dropped, 21%nat, ([kN; kN], kN, false));
  (object_helpers._cur_obj_move_using_fvel_and_gravity, 21%nat, ([], kN, false));
  (object_helpers._cur_obj_move_using_vel_and_gravity, 21%nat, ([], kN, false));
  (object_helpers._cur_obj_move_update_ground_air_flags, 21%nat, ([kN; kN], kN, false));
  (object_helpers._cur_obj_move_update_underwater_flags, 21%nat, ([], kN, false));
  (object_helpers._cur_obj_move_xz, 21%nat, ([kN; kN], kN, false));
  (object_helpers._cur_obj_enable_rendering, 21%nat, ([], kN, false));
  (object_helpers._cur_obj_update_floor_and_walls, 21%nat, ([], kN, false));
  (object_helpers._cur_obj_update_floor_and_resolve_wall_collisions, 21%nat, ([kN], kN, false));
  (object_helpers._cur_obj_update_floor_height_and_get_floor, 21%nat, ([], kW, false));
  (object_helpers._cur_obj_update_floor_height, 21%nat, ([], kN, false));
  (object_helpers._cur_obj_unrender_set_action_and_anim, 21%nat, ([kN; kN], kN, false));
  (object_helpers._cur_obj_hide, 21%nat, ([], kN, false));
  (object_helpers._cur_obj_has_model, 21%nat, ([kN], kN, false));
  (object_helpers._cur_obj_has_behavior, 21%nat, ([kS], kN, false));
  (spawn_sound._cur_obj_play_sound_2, 46%nat, ([kN], kN, false));
  (spawn_sound._cur_obj_play_sound_1, 46%nat, ([kN], kN, false));
  (object_helpers._cur_obj_disable_rendering, 21%nat, ([], kN, false));
  (object_helpers._cur_obj_detect_steep_floor, 21%nat, ([kN], kN, false));
  (object_helpers._cur_obj_become_intangible, 21%nat, ([], kN, false));
  (object_helpers._cur_obj_become_tangible, 21%nat, ([], kN, false));
  (behavior_script._cur_obj_bhv_stack_pop, 42%nat, ([], kS, false));
  (behavior_script._cur_obj_bhv_stack_push, 42%nat, ([kS], kN, false));
  (object_helpers._cur_obj_rotate_yaw_toward, 21%nat, ([kN; kN], kN, false));
  (object_helpers._cur_obj_rotate_face_angle_using_vel, 21%nat, ([], kN, false));
  (object_helpers._cur_obj_resolve_wall_collisions, 21%nat, ([], kN, false));
  (object_helpers._cur_obj_nearest_object_with_behavior, 21%nat, ([kS], kS, false));
  (object_helpers._cur_obj_find_nearest_object_with_behavior, 21%nat, ([kS; kL], kS, false));
  (obj_behaviors._curr_obj_random_blink, 43%nat, ([kS], kN, false));
  (object_helpers._clear_move_flag, 21%nat, ([kS; kN], kN, false));
  (behavior_actions._clear_particle_flags, 9%nat, ([kN], kN, false));
  (object_helpers._clear_time_stop_flags, 21%nat, ([kN], kN, false));
  (spawn_object._create_object, 30%nat, ([kS], kS, false));
  (spawn_sound._create_sound_spawner, 46%nat, ([kN], kN, false));
  (behavior_actions._scale_bubble_sin, 9%nat, ([], kN, false));
  (save_file._save_file_get_star_flags, 19%nat, ([kN; kN], kN, false));
  (save_file._save_file_get_flags, 19%nat, ([], kA, false));
  (save_file._save_file_clear_flags, 19%nat, ([kN], kN, false));
  (save_file._save_file_set_cap_pos, 19%nat, ([kN; kN; kN], kN, false));
  (save_file._save_file_set_cannon_unlocked, 19%nat, ([], kN, false));
  (save_file._save_file_set_flags, 19%nat, ([kN], kN, false));
  (save_file._save_file_is_cannon_unlocked, 19%nat, ([], kN, false));
  (memory._segmented_to_virtual, 14%nat, ([kS], kS, false));
  (audio_external._seq_player_play_sequence, 39%nat, ([kN; kN; kN], kN, true));
  (audio_external._seq_player_fade_to_target_volume, 39%nat, ([kN; kN; kN], kN, false));
  (audio_external._seq_player_fade_to_normal_volume, 39%nat, ([kN; kN], kN, false));
  (object_list_processor._set_object_respawn_info_bits, 16%nat, ([kS; kN], kN, false));
  (obj_behaviors._set_object_visibility, 43%nat, ([kS; kN], kN, false));
  (behavior_actions._set_koopa_shell_underwater_hitbox, 9%nat, ([], kN, false));
  (behavior_actions._set_sparkle_spawn_star_hitbox, 9%nat, ([], kN, false));
  (behavior_actions._set_y_home_to_pos, 9%nat, ([], kN, false));
  (behavior_actions._set_home_to_mario, 9%nat, ([], kN, false));
  (object_helpers._set_time_stop_flags, 21%nat, ([kN], kN, false));
  (surface_load._surface_has_force, 31%nat, ([kN], kN, false));
  (surface_load._surf_has_no_cam_collision, 31%nat, ([kN], kN, false));
  (object_helpers._spawn_water_droplet, 21%nat, ([kS; kS], kS, false));
  (object_helpers._spawn_object_with_scale, 21%nat, ([kS; kN; kS; kN], kS, false));
  (object_helpers._spawn_object_at_origin, 21%nat, ([kS; kN; kS; kS], kS, false));
  (object_helpers._spawn_object_abs_with_rot, 21%nat, ([kS; kN; kN; kS; kN; kN; kN; kN; kN; kN], kS, false));
  (object_helpers._spawn_object_relative, 21%nat, ([kS; kW; kW; kW; kS; kN; kS], kS, false));
  (object_helpers._spawn_object, 21%nat, ([kS; kN; kS], kS, false));
  (obj_behaviors._spawn_orange_number, 43%nat, ([kS; kN; kN; kN], kN, false));
  (behavior_actions._spawn_coin_in_formation, 9%nat, ([kN; kS], kN, false));
  (obj_behaviors._spawn_star, 43%nat, ([kS; kN; kN; kN], kS, false));
  (behavior_actions._spawn_mist_particles_variable, 9%nat, ([kN; kN; kN], kN, false));
  (object_helpers._spawn_mist_particles, 21%nat, ([], kN, false));
  (behavior_actions._spawn_mist_from_global, 9%nat, ([], kN, false));
  (behavior_actions._spawn_triangle_break_particles, 9%nat, ([kN; kN; kN; kN], kN, false));
  (obj_behaviors._spawn_red_coin_cutscene_star, 43%nat, ([kN; kN; kN], kN, false));
  (behavior_actions._slow_star_rotation, 9%nat, ([], kN, false));
  (audio_external._stop_sounds_from_source, 39%nat, ([kS], kN, false));
  (spawn_object._snap_object_to_floor, 30%nat, ([kS], kN, false));
  (object_helpers._is_item_in_array, 21%nat, ([kN; kS], kN, false));
  (obj_behaviors._is_point_within_radius_of_mario, 43%nat, ([kN; kN; kN; kN], kN, false));
  (print._int_pow, 41%nat, ([kN; kN], kN, false));
  (object_helpers._apply_drag_to_value, 21%nat, ([kS; kN], kN, false));
  (object_helpers._approach_s16_symmetric, 21%nat, ([kS; kS; kN], kS, false));
  (spawn_object._allocate_object, 30%nat, ([kS], kS, false));
  (surface_load._alloc_surface_node, 31%nat, ([], kS, false));
  (surface_load._alloc_surface, 31%nat, ([], kS, false));
  (memory._alloc_display_list, 14%nat, ([kN], kS, false));
  (surface_load._add_surface_to_cell, 31%nat, ([kN; kN; kN; kS], kN, false));
  (surface_load._add_surface, 31%nat, ([kS; kN], kN, false));
  (math_util._atan2s, 13%nat, ([kA; kN], kN, false));
  (math_util._atan2_lookup, 13%nat, ([kA; kA], kN, false));
  (object_helpers._abs_angle_diff, 21%nat, ([kS; kS], kN, false));
  (object_helpers._absf, 21%nat, ([kN], kN, false));
  (obj_behaviors._moving_coin_flicker, 43%nat, ([], kN, false));
  (surface_load._min_3, 31%nat, ([kN; kN; kN], kN, false));
  (surface_load._max_3, 31%nat, ([kN; kN; kN], kN, false));
  (spawn_object._mark_obj_for_deletion, 30%nat, ([kS], kN, false));
  (memory._mem_pool_alloc, 14%nat, ([kS; kN], kS, false));
  (obj_behaviors._metal_cap_act_0, 43%nat, ([], kN, false));
  (math_util._mtxf_identity, 13%nat, ([kS], kN, false));
  (math_util._mtxf_align_terrain_normal, 13%nat, ([kS; kL; kL; kS], kN, false));
  (math_util._mtxf_rotate_zxy_and_translate, 13%nat, ([kS; kL; kL], kN, false));
  (surface_load._upper_cell_index, 31%nat, ([kN], kN, false));
  (audio_external._update_background_music_after_sound, 39%nat, ([kN; kN], kN, false));
  (spawn_object._unload_object, 30%nat, ([kS], kN, false));
  (obj_behaviors._pole_1up_move_towards_mario, 43%nat, ([], kN, false));
  (print._parse_width_field, 41%nat, ([kS; kL; kL; kL], kN, false));
  (audio_external._play_power_star_jingle, 39%nat, ([kN], kN, true));
  (debug._print_checkinfo, 47%nat, ([], kN, false));
  (debug._print_stageinfo, 47%nat, ([], kN, false));
  (debug._print_mapinfo, 47%nat, ([], kN, false));
  (debug._print_debug_top_down_mapinfo, 47%nat, ([kS; kN], kN, false));
  (debug._print_debug_top_down_normal, 47%nat, ([kS; kN], kN, false));
  (debug._print_text_array_info, 47%nat, ([kS; kS; kN], kN, false));
  (print._print_text_fmt_int, 41%nat, ([kN; kN; kS; kN], kN, false));
  (print._print_text, 41%nat, ([kN; kN; kS], kN, false));
  (surface_load._lower_cell_index, 31%nat, ([kN], kN, false));
  (surface_load._load_object_collision_model, 31%nat, ([], kN, false));
  (surface_load._load_object_surfaces, 31%nat, ([kL; kL], kN, false));
  (object_helpers._dist_between_objects, 21%nat, ([kS; kS], kA, false));
  (spawn_object._deallocate_object, 30%nat, ([kS; kS], kN, false));
  (obj_behaviors._turn_obj_away_from_surface, 43%nat, ([kN; kN; kN; kN; kN; kL; kL], kN, false));
  (obj_behaviors._turn_obj_away_from_steep_floor, 43%nat, ([kS; kN; kN; kN], kN, false));
  (spawn_object._try_allocate_object, 30%nat, ([kS; kS], kS, false));
  (debug._try_print_debug_mario_level_info, 47%nat, ([], kN, false));
  (debug._try_do_mario_debug_object_spawn, 47%nat, ([], kN, false));
  (object_helpers._try_to_spawn_object, 21%nat, ([kN; kN; kS; kN; kS], kS, false));
  (surface_load._transform_object_vertices, 31%nat, ([kL; kL], kN, false));
  (behavior_actions._jumping_box_free_update, 9%nat, ([], kN, true));
  (obj_behaviors._bobomb_buddy_cannon_dialog, 43%nat, ([kN; kN], kN, true));
  (obj_behaviors._bobomb_buddy_actions, 43%nat, ([], kN, true));
  (obj_behaviors._bobomb_buddy_act_idle, 43%nat, ([], kN, false));
  (obj_behaviors._bobomb_buddy_act_talk, 43%nat, ([], kN, true));
  (obj_behaviors._bobomb_buddy_act_turn_to_talk, 43%nat, ([], kN, false));
  (object_helpers._bit_shift_left, 21%nat, ([kS], kN, false));
  (audio_external._begin_background_music_fade, 39%nat, ([kN], kN, false));
  (obj_behaviors._bhv_wing_cap_init, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_wing_vanish_cap_loop, 43%nat, ([], kN, false));
  (behavior_actions._bhv_wind_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_wall_tiny_star_particle_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_water_waves_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_water_splash_spawn_droplets, 9%nat, ([], kN, false));
  (behavior_actions._bhv_water_mist_spawn_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_water_mist_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_water_droplet_splash_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_water_droplet_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_wave_trail_shrink, 9%nat, ([], kN, false));
  (behavior_actions._bhv_white_puff_2_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_white_puff_exploding_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_white_puff_1_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_golden_coin_sparkles_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_ground_sand_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_ground_snow_init, 9%nat, ([], kN, false));
  (obj_behaviors._bhv_object_water_wave_init, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_object_water_wave_loop, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_object_bubble_init, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_object_bubble_loop, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_orange_number_init, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_orange_number_loop, 43%nat, ([], kN, false));
  (behavior_actions._bhv_koopa_shell_underwater_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_koopa_shell_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_koopa_shell_flame_spawn, 9%nat, ([], kN, false));
  (behavior_actions._bhv_koopa_shell_flame_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_coin_sparkles_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_coin_sparkles_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_coin_formation_spawn_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_coin_formation_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_coin_formation_loop, 9%nat, ([], kN, false));
  (obj_behaviors._bhv_collect_star_init, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_collect_star_loop, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_cannon_closed_init, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_cannon_closed_loop, 43%nat, ([], kN, false));
  (behavior_actions._bhv_cannon_base_loop, 9%nat, ([], kN, true));
  (behavior_actions._bhv_cannon_barrel_loop, 9%nat, ([], kN, false));
  (behavior_script._bhv_cmd_goto, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_or_int, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_call, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_scale, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_set_obj_physics, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_set_interact_subtype, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_set_interact_type, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_set_int_unused, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_set_int_rand_rshift, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_set_int, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_set_model, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_set_home, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_set_hitbox_with_offset, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_set_hitbox, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_set_hurtbox, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_set_random_int, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_set_random_float, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_set_float, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_sum_int, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_sum_float, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_spawn_water_droplet, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_spawn_obj, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_spawn_child_with_param, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_spawn_child, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_add_int_rand_rshift, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_add_int, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_add_random_float, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_add_float, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_animate_texture, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_animate, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_end_loop, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_end_repeat_continue, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_end_repeat, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_hide, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_parent_bit_clear, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_load_collision_data, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_load_animations, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_disable_rendering, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_deactivate, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_delay_var, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_delay, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_drop_to_floor, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_billboard, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_bit_clear, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_begin_loop, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_begin_repeat_unused, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_begin_repeat, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_begin, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_break_unused, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_break, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_return, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_nop_4, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_nop_2, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_nop_1, 42%nat, ([], kN, false));
  (behavior_script._bhv_cmd_nop_3, 42%nat, ([], kN, false));
  (obj_behaviors._bhv_celebration_star_sparkle_loop, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_celebration_star_init, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_celebration_star_loop, 43%nat, ([], kN, false));
  (behavior_actions._bhv_sound_spawner_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_small_water_wave_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_shallow_water_splash_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_spawned_coin_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_spawned_coin_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_spawned_star_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_spawned_star_loop, 9%nat, ([], kN, true));
  (behavior_actions._bhv_sparkle_spawn_loop, 9%nat, ([], kN, false));
  (obj_behaviors._bhv_star_key_collection_puff_spawner_loop, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_star_spawn_init, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_star_spawn_loop, 43%nat, ([], kN, true));
  (behavior_actions._bhv_snow_leaf_particle_spawn_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_yellow_coin_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_yellow_coin_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_idle_water_wave_loop, 9%nat, ([], kN, false));
  (object_helpers._bhv_init_room, 21%nat, ([], kN, false));
  (obj_behaviors._bhv_metal_cap_init, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_metal_cap_loop, 43%nat, ([], kN, false));
  (behavior_actions._bhv_exclamation_box_loop, 9%nat, ([], kN, true));
  (mario_actions_cutscene._bhv_end_peach_loop, 5%nat, ([], kN, false));
  (mario_actions_cutscene._bhv_end_toad_loop, 5%nat, ([], kN, false));
  (obj_behaviors._bhv_1up_walking_loop, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_1up_common_init, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_1up_init, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_1up_hidden_in_pole_spawner_loop, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_1up_hidden_in_pole_loop, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_1up_hidden_in_pole_trigger_loop, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_1up_loop, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_1up_running_away_loop, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_hidden_red_coin_star_init, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_hidden_red_coin_star_loop, 43%nat, ([], kN, false));
  (behavior_actions._bhv_pound_white_puffs_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_pound_tiny_star_particle_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_pound_tiny_star_particle_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_pole_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_pole_base_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_particle_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_particle_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_punch_tiny_triangle_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_punch_tiny_triangle_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_tiny_star_particles_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_tree_snow_or_leaf_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_jumping_box_loop, 9%nat, ([], kN, true));
  (behavior_actions._bhv_bowser_key_course_exit_loop, 9%nat, ([], kN, false));
  (behavior_actions._bhv_bowser_key_unlock_door_loop, 9%nat, ([], kN, false));
  (obj_behaviors._bhv_bobomb_buddy_init, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_bobomb_buddy_loop, 43%nat, ([], kN, true));
  (behavior_actions._bhv_bubble_wave_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_bubble_splash_init, 9%nat, ([], kN, false));
  (behavior_actions._bhv_black_smoke_mario_loop, 9%nat, ([], kN, false));
  (obj_behaviors._bhv_blue_coin_sliding_jumping_init, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_blue_coin_jumping_loop, 43%nat, ([], kN, false));
  (behavior_actions._bhv_rotating_exclamation_box_loop, 9%nat, ([], kN, false));
  (obj_behaviors_2._bhv_red_coin_star_marker_init, 49%nat, ([], kN, false));
  (obj_behaviors._bhv_red_coin_init, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_red_coin_loop, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_normal_cap_init, 43%nat, ([], kN, false));
  (obj_behaviors._bhv_normal_cap_loop, 43%nat, ([], kN, false));
  (behavior_actions._bhv_flame_mario_loop, 9%nat, ([], kN, false));
  (obj_behaviors._bhv_vanish_cap_init, 43%nat, ([], kN, false));
  (obj_behaviors._blue_coin_sliding_slow_down, 43%nat, ([], kN, false));
  (obj_behaviors._blue_coin_sliding_away_from_mario, 43%nat, ([], kN, false));
  (behavior_script._random_u16, 42%nat, ([], kN, false));
  (behavior_script._random_float, 42%nat, ([], kN, false));
  (object_helpers._random_f32_around_zero, 21%nat, ([kN], kN, false));
  (surface_load._read_surface_data, 31%nat, ([kL; kL], kS, false));
  (obj_behaviors._normal_cap_set_save_flags, 43%nat, ([], kN, false));
  (obj_behaviors._normal_cap_act_0, 43%nat, ([], kN, false));
  (print._format_integer, 41%nat, ([kN; kN; kW; kL; kN; kN], kN, false));
  (surface_collision._find_wall_collisions_from_list, 12%nat, ([kS; kL], kN, false));
  (surface_collision._find_wall_collisions, 12%nat, ([kL], kN, false));
  (surface_collision._find_water_level, 12%nat, ([kN; kN], kN, false));
  (object_helpers._find_unimportant_object, 21%nat, ([], kS, false));
  (surface_collision._find_floor_height, 12%nat, ([kN; kN; kN], kN, false));
  (surface_collision._find_floor_from_list, 12%nat, ([kS; kN; kN; kN; kL], kS, false));
  (surface_collision._find_floor, 12%nat, ([kN; kN; kN; kT], kN, false));
  (audio_external._func_8031D690, 39%nat, ([kN; kN], kN, false));
  (math_util._vec3s_copy, 13%nat, ([kS; kS], kL, false));
  (math_util._vec3s_set, 13%nat, ([kW; kN; kN; kN], kL, false));
  (math_util._vec3f_copy, 13%nat, ([kS; kS], kL, false));
  (math_util._vec3f_cross, 13%nat, ([kL; kL; kL], kL, false));
  (math_util._vec3f_set, 13%nat, ([kT; kN; kN; kN], kL, false));
  (math_util._vec3f_normalize, 13%nat, ([kL], kL, false))
].

(* the leaves the walk stops at (ObjKit section 3 proves or premises each) *)
Definition oleaf : utab := [
  (math_util._sqrtf, ([kN], kA, false));
  (audio_external._play_sound, ([kA; kA], kA, false));
  (audio_external._load_sequence, ([kN; kN; kN], kA, true));
  (mario_actions_cutscene._set_mario_npc_dialog, ([kN], kA, true));
  (camera._start_object_cutscene, ([kN; kS], kA, false));
  (object_helpers._cur_obj_update_floor, ([], kA, false));
  (object_helpers._cur_obj_call_action_function, ([kS], kA, true));
  (obj_behaviors._bhv_1up_interact, ([], kA, false));
  (object_helpers._cur_obj_push_mario_away, ([kN], kA, false))
].

Definition oit : uitab := nil.

Definition out : utab := map (fun e => let '(fid, _, s) := e in (fid, s)) otab ++ oleaf.

Definition ot_ent_ok (gs : list ident) (ut : utab) (e : ident * nat * usig) : bool :=
  let '(fid, i, s) := e in
  match nth_error lprogs i with
  | Some p =>
      match (prog_defmap p) ! fid with
      | Some (Gfun (Internal f)) => uchk gs ut oit s f
      | _ => false
      end
  | None => false
  end.
