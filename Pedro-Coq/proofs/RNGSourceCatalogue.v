From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From Pedro.Proofs Require Import ASTFacts GameTypes RNGEffectSyntax.
From Pedro.Generated Require Import
  us_mario
  us_mario_step
  us_mario_actions_airborne
  us_mario_actions_moving
  us_mario_actions_stationary
  us_mario_actions_automatic
  us_mario_actions_submerged
  us_mario_actions_cutscene
  us_mario_actions_object
  us_interaction
  us_camera
  us_envfx_snow
  us_envfx_bubbles
  us_mario_misc
  us_ingame_menu
  us_level_geo
  us_area
  us_level_scripts
  us_save_file
  us_spawn_sound
  us_memory
  us_object_list_processor
  us_behavior_script
  us_graph_node
  us_audio_external
  us_spawn_object
  us_macro_special_objects
  us_math_util
  us_surface_load
  us_surface_collision
  us_object_helpers
  us_obj_behaviors
  us_behavior_actions
  us_obj_behaviors_2
  us_behavior_data
  us_platform_displacement
  us_ttc_level_script
  us_ttc_geo
  us_ttc_area1_macro
  us_ttc_spinner_collision
  us_ttc_cog_collision.
From Pedro.Generated Require Import
  jp_mario
  jp_mario_step
  jp_mario_actions_airborne
  jp_mario_actions_moving
  jp_mario_actions_stationary
  jp_mario_actions_automatic
  jp_mario_actions_submerged
  jp_mario_actions_cutscene
  jp_mario_actions_object
  jp_interaction
  jp_camera
  jp_envfx_snow
  jp_envfx_bubbles
  jp_mario_misc
  jp_ingame_menu
  jp_level_geo
  jp_area
  jp_level_scripts
  jp_save_file
  jp_spawn_sound
  jp_memory
  jp_object_list_processor
  jp_behavior_script
  jp_graph_node
  jp_audio_external
  jp_spawn_object
  jp_macro_special_objects
  jp_math_util
  jp_surface_load
  jp_surface_collision
  jp_object_helpers
  jp_obj_behaviors
  jp_behavior_actions
  jp_obj_behaviors_2
  jp_behavior_data
  jp_platform_displacement
  jp_ttc_level_script
  jp_ttc_geo
  jp_ttc_area1_macro
  jp_ttc_spinner_collision
  jp_ttc_cog_collision.
Import ListNotations.
Inductive RNGSourceUnit : Type :=
  | Unit_mario
  | Unit_mario_step
  | Unit_mario_actions_airborne
  | Unit_mario_actions_moving
  | Unit_mario_actions_stationary
  | Unit_mario_actions_automatic
  | Unit_mario_actions_submerged
  | Unit_mario_actions_cutscene
  | Unit_mario_actions_object
  | Unit_interaction
  | Unit_camera
  | Unit_envfx_snow
  | Unit_envfx_bubbles
  | Unit_mario_misc
  | Unit_ingame_menu
  | Unit_level_geo
  | Unit_area
  | Unit_level_scripts
  | Unit_save_file
  | Unit_spawn_sound
  | Unit_memory
  | Unit_object_list_processor
  | Unit_behavior_script
  | Unit_graph_node
  | Unit_audio_external
  | Unit_spawn_object
  | Unit_macro_special_objects
  | Unit_math_util
  | Unit_surface_load
  | Unit_surface_collision
  | Unit_object_helpers
  | Unit_obj_behaviors
  | Unit_behavior_actions
  | Unit_obj_behaviors_2
  | Unit_behavior_data
  | Unit_platform_displacement
  | Unit_ttc_level_script
  | Unit_ttc_geo
  | Unit_ttc_area1_macro
  | Unit_ttc_spinner_collision
  | Unit_ttc_cog_collision.
Definition rng_source_program (version : GameVersion) (unit : RNGSourceUnit) : Clight.program :=
  match version, unit with
  | VersionUS, Unit_mario => us_mario.prog
  | VersionUS, Unit_mario_step => us_mario_step.prog
  | VersionUS, Unit_mario_actions_airborne => us_mario_actions_airborne.prog
  | VersionUS, Unit_mario_actions_moving => us_mario_actions_moving.prog
  | VersionUS, Unit_mario_actions_stationary => us_mario_actions_stationary.prog
  | VersionUS, Unit_mario_actions_automatic => us_mario_actions_automatic.prog
  | VersionUS, Unit_mario_actions_submerged => us_mario_actions_submerged.prog
  | VersionUS, Unit_mario_actions_cutscene => us_mario_actions_cutscene.prog
  | VersionUS, Unit_mario_actions_object => us_mario_actions_object.prog
  | VersionUS, Unit_interaction => us_interaction.prog
  | VersionUS, Unit_camera => us_camera.prog
  | VersionUS, Unit_envfx_snow => us_envfx_snow.prog
  | VersionUS, Unit_envfx_bubbles => us_envfx_bubbles.prog
  | VersionUS, Unit_mario_misc => us_mario_misc.prog
  | VersionUS, Unit_ingame_menu => us_ingame_menu.prog
  | VersionUS, Unit_level_geo => us_level_geo.prog
  | VersionUS, Unit_area => us_area.prog
  | VersionUS, Unit_level_scripts => us_level_scripts.prog
  | VersionUS, Unit_save_file => us_save_file.prog
  | VersionUS, Unit_spawn_sound => us_spawn_sound.prog
  | VersionUS, Unit_memory => us_memory.prog
  | VersionUS, Unit_object_list_processor => us_object_list_processor.prog
  | VersionUS, Unit_behavior_script => us_behavior_script.prog
  | VersionUS, Unit_graph_node => us_graph_node.prog
  | VersionUS, Unit_audio_external => us_audio_external.prog
  | VersionUS, Unit_spawn_object => us_spawn_object.prog
  | VersionUS, Unit_macro_special_objects => us_macro_special_objects.prog
  | VersionUS, Unit_math_util => us_math_util.prog
  | VersionUS, Unit_surface_load => us_surface_load.prog
  | VersionUS, Unit_surface_collision => us_surface_collision.prog
  | VersionUS, Unit_object_helpers => us_object_helpers.prog
  | VersionUS, Unit_obj_behaviors => us_obj_behaviors.prog
  | VersionUS, Unit_behavior_actions => us_behavior_actions.prog
  | VersionUS, Unit_obj_behaviors_2 => us_obj_behaviors_2.prog
  | VersionUS, Unit_behavior_data => us_behavior_data.prog
  | VersionUS, Unit_platform_displacement => us_platform_displacement.prog
  | VersionUS, Unit_ttc_level_script => us_ttc_level_script.prog
  | VersionUS, Unit_ttc_geo => us_ttc_geo.prog
  | VersionUS, Unit_ttc_area1_macro => us_ttc_area1_macro.prog
  | VersionUS, Unit_ttc_spinner_collision => us_ttc_spinner_collision.prog
  | VersionUS, Unit_ttc_cog_collision => us_ttc_cog_collision.prog
  | VersionJP, Unit_mario => jp_mario.prog
  | VersionJP, Unit_mario_step => jp_mario_step.prog
  | VersionJP, Unit_mario_actions_airborne => jp_mario_actions_airborne.prog
  | VersionJP, Unit_mario_actions_moving => jp_mario_actions_moving.prog
  | VersionJP, Unit_mario_actions_stationary => jp_mario_actions_stationary.prog
  | VersionJP, Unit_mario_actions_automatic => jp_mario_actions_automatic.prog
  | VersionJP, Unit_mario_actions_submerged => jp_mario_actions_submerged.prog
  | VersionJP, Unit_mario_actions_cutscene => jp_mario_actions_cutscene.prog
  | VersionJP, Unit_mario_actions_object => jp_mario_actions_object.prog
  | VersionJP, Unit_interaction => jp_interaction.prog
  | VersionJP, Unit_camera => jp_camera.prog
  | VersionJP, Unit_envfx_snow => jp_envfx_snow.prog
  | VersionJP, Unit_envfx_bubbles => jp_envfx_bubbles.prog
  | VersionJP, Unit_mario_misc => jp_mario_misc.prog
  | VersionJP, Unit_ingame_menu => jp_ingame_menu.prog
  | VersionJP, Unit_level_geo => jp_level_geo.prog
  | VersionJP, Unit_area => jp_area.prog
  | VersionJP, Unit_level_scripts => jp_level_scripts.prog
  | VersionJP, Unit_save_file => jp_save_file.prog
  | VersionJP, Unit_spawn_sound => jp_spawn_sound.prog
  | VersionJP, Unit_memory => jp_memory.prog
  | VersionJP, Unit_object_list_processor => jp_object_list_processor.prog
  | VersionJP, Unit_behavior_script => jp_behavior_script.prog
  | VersionJP, Unit_graph_node => jp_graph_node.prog
  | VersionJP, Unit_audio_external => jp_audio_external.prog
  | VersionJP, Unit_spawn_object => jp_spawn_object.prog
  | VersionJP, Unit_macro_special_objects => jp_macro_special_objects.prog
  | VersionJP, Unit_math_util => jp_math_util.prog
  | VersionJP, Unit_surface_load => jp_surface_load.prog
  | VersionJP, Unit_surface_collision => jp_surface_collision.prog
  | VersionJP, Unit_object_helpers => jp_object_helpers.prog
  | VersionJP, Unit_obj_behaviors => jp_obj_behaviors.prog
  | VersionJP, Unit_behavior_actions => jp_behavior_actions.prog
  | VersionJP, Unit_obj_behaviors_2 => jp_obj_behaviors_2.prog
  | VersionJP, Unit_behavior_data => jp_behavior_data.prog
  | VersionJP, Unit_platform_displacement => jp_platform_displacement.prog
  | VersionJP, Unit_ttc_level_script => jp_ttc_level_script.prog
  | VersionJP, Unit_ttc_geo => jp_ttc_geo.prog
  | VersionJP, Unit_ttc_area1_macro => jp_ttc_area1_macro.prog
  | VersionJP, Unit_ttc_spinner_collision => jp_ttc_spinner_collision.prog
  | VersionJP, Unit_ttc_cog_collision => jp_ttc_cog_collision.prog
  end.

Definition gameplay_rng_primitives : list ident :=
  [us_behavior_script._random_u16; us_behavior_script._random_float;
   us_behavior_script._random_sign].

Definition rng_source_sites version unit : list (ident * ident) :=
  named_call_sites gameplay_rng_primitives (prog_defs (rng_source_program version unit)).

Definition rng_source_bodies version unit : list (ident * function) :=
  flat_map (fun entry => match snd entry with
    | Gfun (Internal f) => [(fst entry, f)] | _ => [] end)
    (prog_defs (rng_source_program version unit)).

Definition rng_primitive_escapers version unit : list ident :=
  map fst (filter (fun entry => named_reference_outside_call gameplay_rng_primitives
    (fn_body (snd entry))) (rng_source_bodies version unit)).

Definition rng_seed_referencers version unit : list ident :=
  map fst (filter (fun entry => statement_mentions_ident_s
    us_behavior_script._gRandomSeed16 (fn_body (snd entry)))
    (rng_source_bodies version unit)).

Definition rng_primitive_initializer_references version unit : list ident :=
  filter (fun id => existsb (Pos.eqb id)
    (us_behavior_script._gRandomSeed16 :: gameplay_rng_primitives))
    (flat_map (fun entry => match snd entry with
       | Gvar variable => initializer_addrof_idents (gvar_init variable)
       | _ => [] end) (prog_defs (rng_source_program version unit))).

Definition rng_computed_callers version unit : list ident :=
  map fst (filter (fun entry => existsb computed_call (call_expressions (fn_body (snd entry))))
    (rng_source_bodies version unit)).

Definition rng_particle_field_writers version unit : list ident :=
  map fst (filter (fun entry => field_assignment us_mario._particleFlags
    (fn_body (snd entry))) (rng_source_bodies version unit)).

(** Expected lists below are checked by reduction of the original generated
    bodies. This file proves direct-call coverage, not a reachable-state or
    preserving-control theorem. Computed calls are retained as a frontier. *)
Definition expected_rng_source_sites (version : GameVersion) (unit : RNGSourceUnit)
    : list (ident * ident) :=
  match version, unit with
  | VersionUS, Unit_camera =>
    [(us_camera._set_camera_shake_from_hit, us_camera._random_float);
     (us_camera._set_camera_shake_from_hit, us_camera._random_float);
     (us_camera._shake_camera_handheld, us_camera._random_float);
     (us_camera._random_vec3s, us_camera._random_float);
     (us_camera._random_vec3s, us_camera._random_float);
     (us_camera._random_vec3s, us_camera._random_float);
     (us_camera._bhv_end_birds_1_loop, us_camera._random_float);
     (us_camera._bhv_end_birds_2_loop, us_camera._random_float);
     (us_camera._bhv_end_birds_2_loop, us_camera._random_float);
     (us_camera._spawn_child_obj_relative, us_camera._random_float)]
  | VersionUS, Unit_envfx_snow =>
    [(us_envfx_snow._envfx_update_snow_normal, us_envfx_snow._random_float);
     (us_envfx_snow._envfx_update_snow_normal, us_envfx_snow._random_float);
     (us_envfx_snow._envfx_update_snow_normal, us_envfx_snow._random_float);
     (us_envfx_snow._envfx_update_snow_normal, us_envfx_snow._random_float);
     (us_envfx_snow._envfx_update_snow_normal, us_envfx_snow._random_float);
     (us_envfx_snow._envfx_update_snow_blizzard, us_envfx_snow._random_float);
     (us_envfx_snow._envfx_update_snow_blizzard, us_envfx_snow._random_float);
     (us_envfx_snow._envfx_update_snow_blizzard, us_envfx_snow._random_float);
     (us_envfx_snow._envfx_update_snow_blizzard, us_envfx_snow._random_float);
     (us_envfx_snow._envfx_update_snow_blizzard, us_envfx_snow._random_float);
     (us_envfx_snow._envfx_update_snow_water, us_envfx_snow._random_float);
     (us_envfx_snow._envfx_update_snow_water, us_envfx_snow._random_float);
     (us_envfx_snow._envfx_update_snow_water, us_envfx_snow._random_float)]
  | VersionUS, Unit_envfx_bubbles =>
    [(us_envfx_bubbles._random_flower_offset, us_envfx_bubbles._random_float);
     (us_envfx_bubbles._envfx_update_flower, us_envfx_bubbles._random_float);
     (us_envfx_bubbles._envfx_set_lava_bubble_position, us_envfx_bubbles._random_float);
     (us_envfx_bubbles._envfx_set_lava_bubble_position, us_envfx_bubbles._random_float);
     (us_envfx_bubbles._envfx_update_lava, us_envfx_bubbles._random_float);
     (us_envfx_bubbles._envfx_update_whirlpool, us_envfx_bubbles._random_float);
     (us_envfx_bubbles._envfx_update_whirlpool, us_envfx_bubbles._random_float);
     (us_envfx_bubbles._envfx_update_whirlpool, us_envfx_bubbles._random_float);
     (us_envfx_bubbles._envfx_update_jetstream, us_envfx_bubbles._random_float);
     (us_envfx_bubbles._envfx_update_jetstream, us_envfx_bubbles._random_u16);
     (us_envfx_bubbles._envfx_update_jetstream, us_envfx_bubbles._random_float);
     (us_envfx_bubbles._envfx_init_bubble, us_envfx_bubbles._random_float)]
  | VersionUS, Unit_behavior_script =>
    [(us_behavior_script._random_float, us_behavior_script._random_u16);
     (us_behavior_script._random_sign, us_behavior_script._random_u16);
     (us_behavior_script._bhv_cmd_set_random_float, us_behavior_script._random_float);
     (us_behavior_script._bhv_cmd_set_random_int, us_behavior_script._random_float);
     (us_behavior_script._bhv_cmd_set_int_rand_rshift, us_behavior_script._random_u16);
     (us_behavior_script._bhv_cmd_add_random_float, us_behavior_script._random_float);
     (us_behavior_script._bhv_cmd_add_int_rand_rshift, us_behavior_script._random_u16)]
  | VersionUS, Unit_object_helpers =>
    [(us_object_helpers._spawn_water_droplet, us_object_helpers._random_u16);
     (us_object_helpers._spawn_water_droplet, us_object_helpers._random_float);
     (us_object_helpers._spawn_water_droplet, us_object_helpers._random_float);
     (us_object_helpers._spawn_water_droplet, us_object_helpers._random_float);
     (us_object_helpers._random_f32_around_zero, us_object_helpers._random_float);
     (us_object_helpers._obj_scale_random, us_object_helpers._random_float);
     (us_object_helpers._obj_translate_xyz_random, us_object_helpers._random_float);
     (us_object_helpers._obj_translate_xyz_random, us_object_helpers._random_float);
     (us_object_helpers._obj_translate_xyz_random, us_object_helpers._random_float);
     (us_object_helpers._obj_translate_xz_random, us_object_helpers._random_float);
     (us_object_helpers._obj_translate_xz_random, us_object_helpers._random_float);
     (us_object_helpers._cur_obj_spawn_particles, us_object_helpers._random_float);
     (us_object_helpers._cur_obj_spawn_particles, us_object_helpers._random_u16);
     (us_object_helpers._cur_obj_spawn_particles, us_object_helpers._random_float);
     (us_object_helpers._cur_obj_spawn_particles, us_object_helpers._random_float)]
  | VersionUS, Unit_obj_behaviors =>
    [(us_obj_behaviors._obj_return_and_displace_home, us_obj_behaviors._random_float);
     (us_obj_behaviors._obj_return_and_displace_home, us_obj_behaviors._random_float);
     (us_obj_behaviors._obj_return_and_displace_home, us_obj_behaviors._random_float);
     (us_obj_behaviors._obj_spawn_yellow_coins, us_obj_behaviors._random_float);
     (us_obj_behaviors._obj_spawn_yellow_coins, us_obj_behaviors._random_float);
     (us_obj_behaviors._obj_spawn_yellow_coins, us_obj_behaviors._random_u16);
     (us_obj_behaviors._obj_lava_death, us_obj_behaviors._random_float);
     (us_obj_behaviors._obj_lava_death, us_obj_behaviors._random_float);
     (us_obj_behaviors._obj_lava_death, us_obj_behaviors._random_float);
     (us_obj_behaviors._obj_lava_death, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_seaweed_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_seaweed_bundle_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_seaweed_bundle_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_seaweed_bundle_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._curr_obj_random_blink, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_bobomb_fuse_smoke_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_bobomb_fuse_smoke_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_bobomb_fuse_smoke_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_circling_amp_init, us_obj_behaviors._random_u16);
     (us_obj_behaviors._bhv_butterfly_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_butterfly_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_object_bubble_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_object_bubble_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_object_bubble_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_bobomb_explosion_bubble_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_bobomb_explosion_bubble_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_bobomb_explosion_bubble_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_bobomb_explosion_bubble_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bully_spawn_coin, us_obj_behaviors._random_float);
     (us_obj_behaviors._water_ring_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._water_ring_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._water_ring_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_bowser_bomb_explosion_loop, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_bowser_bomb_explosion_loop, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_bowser_bomb_explosion_loop, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_small_bomp_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_large_bomp_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_wf_sliding_platform_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._moneybag_act_move_around, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_generic_bowling_ball_spawner_loop, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_thi_bowling_ball_spawner_loop, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_pyramid_top_spinning, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_pyramid_top_spinning, us_obj_behaviors._random_u16);
     (us_obj_behaviors._bhv_pyramid_top_spinning, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_pyramid_top_explode, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_pyramid_top_explode, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_pyramid_top_explode, us_obj_behaviors._random_u16);
     (us_obj_behaviors._bhv_pyramid_top_explode, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_castle_flag_init, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_big_boulder_generator_loop, us_obj_behaviors._random_float);
     (us_obj_behaviors._bhv_big_boulder_generator_loop, us_obj_behaviors._random_float);
     (us_obj_behaviors._small_breakable_box_spawn_dust, us_obj_behaviors._random_float);
     (us_obj_behaviors._small_breakable_box_spawn_dust, us_obj_behaviors._random_float);
     (us_obj_behaviors._yoshi_idle_loop, us_obj_behaviors._random_float)]
  | VersionUS, Unit_behavior_actions =>
    [(us_behavior_actions._bhv_piranha_particle_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_piranha_particle_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_piranha_particle_loop, us_behavior_actions._random_u16);
     (us_behavior_actions._mr_i_act_2, us_behavior_actions._random_float);
     (us_behavior_actions._mr_i_act_2, us_behavior_actions._random_float);
     (us_behavior_actions._mr_i_act_1, us_behavior_actions._random_float);
     (us_behavior_actions._mr_i_act_1, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_beta_chest_bottom_init, us_behavior_actions._random_u16);
     (us_behavior_actions._bhv_water_air_bubble_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_water_air_bubble_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_bubble_wave_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_bubble_wave_init, us_behavior_actions._random_float);
     (us_behavior_actions._scale_bubble_random, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_bubble_maybe_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_bubble_maybe_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_bubble_maybe_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_particle_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_particle_init, us_behavior_actions._random_float);
     (us_behavior_actions._chuckya_act_1, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_spawned_coin_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_spawned_coin_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_spawned_coin_init, us_behavior_actions._random_u16);
     (us_behavior_actions._bhv_golden_coin_sparkles_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_golden_coin_sparkles_loop, us_behavior_actions._random_float);
     (us_behavior_actions._grindel_thwomp_act_idle_at_bottom, us_behavior_actions._random_float);
     (us_behavior_actions._grindel_thwomp_act_idle_at_top, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_tumbling_bridge_platform_loop, us_behavior_actions._random_sign);
     (us_behavior_actions._spawn_triangle_break_particles, us_behavior_actions._random_u16);
     (us_behavior_actions._spawn_triangle_break_particles, us_behavior_actions._random_u16);
     (us_behavior_actions._spawn_triangle_break_particles, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_water_mist_2_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_wind_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_wind_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_wind_loop, us_behavior_actions._random_u16);
     (us_behavior_actions._bhv_wind_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_wind_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_flamethrower_flame_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_bouncing_fireball_flame_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_bouncing_fireball_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_black_smoke_bowser_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_black_smoke_bowser_loop, us_behavior_actions._random_u16);
     (us_behavior_actions._bhv_black_smoke_mario_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_black_smoke_mario_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_tree_snow_or_leaf_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_tree_snow_or_leaf_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_tree_snow_or_leaf_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_snow_leaf_particle_spawn_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_snow_leaf_particle_spawn_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_snow_leaf_particle_spawn_init, us_behavior_actions._random_u16);
     (us_behavior_actions._bhv_snow_leaf_particle_spawn_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_snow_leaf_particle_spawn_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_snow_leaf_particle_spawn_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_snow_leaf_particle_spawn_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_snow_leaf_particle_spawn_init, us_behavior_actions._random_u16);
     (us_behavior_actions._bhv_snow_leaf_particle_spawn_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_snow_leaf_particle_spawn_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_snow_leaf_particle_spawn_init, us_behavior_actions._random_u16);
     (us_behavior_actions._bhv_snow_leaf_particle_spawn_init, us_behavior_actions._random_u16);
     (us_behavior_actions._bhv_snow_leaf_particle_spawn_init, us_behavior_actions._random_u16);
     (us_behavior_actions._bhv_piranha_plant_waking_bubbles_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_piranha_plant_waking_bubbles_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_piranha_plant_waking_bubbles_loop, us_behavior_actions._random_u16);
     (us_behavior_actions._jumping_box_act_0, us_behavior_actions._random_float);
     (us_behavior_actions._jumping_box_act_0, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_white_puff_smoke_init, us_behavior_actions._random_float);
     (us_behavior_actions._bowser_bitdw_actions, us_behavior_actions._random_float);
     (us_behavior_actions._bowser_bitfs_actions, us_behavior_actions._random_float);
     (us_behavior_actions._bowser_bits_action_list, us_behavior_actions._random_float);
     (us_behavior_actions._bowser_act_spit_fire_onto_floor, us_behavior_actions._random_float);
     (us_behavior_actions._bowser_flame_despawn, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_flame_bowser_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_flame_bowser_init, us_behavior_actions._random_u16);
     (us_behavior_actions._bhv_flame_bowser_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_flame_bowser_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_flame_large_burning_out_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_flame_large_burning_out_init, us_behavior_actions._random_u16);
     (us_behavior_actions._bhv_flame_bowser_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_flame_moving_forward_growing_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_flame_floating_landing_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_flame_floating_landing_init, us_behavior_actions._random_u16);
     (us_behavior_actions._bhv_flame_floating_landing_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_flame_floating_landing_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_flame_floating_landing_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_flame_floating_landing_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_blue_bowser_flame_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_blue_bowser_flame_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_blue_bowser_flame_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_flame_bouncing_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_flame_bouncing_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_blue_fish_movement_loop, us_behavior_actions._random_sign);
     (us_behavior_actions._bhv_blue_fish_movement_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_blue_fish_movement_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_blue_fish_movement_loop, us_behavior_actions._random_float);
     (us_behavior_actions._idle_ukiki_taunt, us_behavior_actions._random_float);
     (us_behavior_actions._idle_ukiki_taunt, us_behavior_actions._random_float);
     (us_behavior_actions._ukiki_act_turn_to_mario, us_behavior_actions._random_float);
     (us_behavior_actions._ukiki_act_run, us_behavior_actions._random_float);
     (us_behavior_actions._ukiki_act_jump, us_behavior_actions._random_float);
     (us_behavior_actions._hexagonal_ring_spawn_flames, us_behavior_actions._random_u16);
     (us_behavior_actions._hexagonal_ring_spawn_flames, us_behavior_actions._random_float);
     (us_behavior_actions._hexagonal_ring_spawn_flames, us_behavior_actions._random_float);
     (us_behavior_actions._hexagonal_ring_spawn_flames, us_behavior_actions._random_float);
     (us_behavior_actions._hexagonal_ring_spawn_flames, us_behavior_actions._random_float);
     (us_behavior_actions._koopa_shell_spawn_water_drop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_koopa_shell_flame_loop, us_behavior_actions._random_u16);
     (us_behavior_actions._bhv_koopa_shell_flame_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_koopa_shell_flame_loop, us_behavior_actions._random_float);
     (us_behavior_actions._small_penguin_act_0, us_behavior_actions._random_float);
     (us_behavior_actions._small_penguin_act_0, us_behavior_actions._random_float);
     (us_behavior_actions._small_penguin_act_0, us_behavior_actions._random_float);
     (us_behavior_actions._fish_act_roam, us_behavior_actions._random_float);
     (us_behavior_actions._fish_act_roam, us_behavior_actions._random_float);
     (us_behavior_actions._fish_act_roam, us_behavior_actions._random_float);
     (us_behavior_actions._fish_act_roam, us_behavior_actions._random_float);
     (us_behavior_actions._fish_act_flee, us_behavior_actions._random_float);
     (us_behavior_actions._fish_act_flee, us_behavior_actions._random_float);
     (us_behavior_actions._fish_act_flee, us_behavior_actions._random_float);
     (us_behavior_actions._fish_act_init, us_behavior_actions._random_float);
     (us_behavior_actions._fish_act_init, us_behavior_actions._random_float);
     (us_behavior_actions._fish_act_init, us_behavior_actions._random_float);
     (us_behavior_actions._bub_act_0, us_behavior_actions._random_float);
     (us_behavior_actions._bub_act_0, us_behavior_actions._random_float);
     (us_behavior_actions._bub_act_1, us_behavior_actions._random_float);
     (us_behavior_actions._bub_act_1, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_tweester_sand_particle_loop, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_tweester_sand_particle_loop, us_behavior_actions._random_u16);
     (us_behavior_actions._bhv_tweester_sand_particle_loop, us_behavior_actions._random_u16);
     (us_behavior_actions._bhv_courtyard_boo_triplet_init, us_behavior_actions._random_u16);
     (us_behavior_actions._boo_act_1, us_behavior_actions._random_float);
     (us_behavior_actions._boo_act_1, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_water_droplet_loop, us_behavior_actions._random_u16);
     (us_behavior_actions._bhv_water_droplet_splash_init, us_behavior_actions._random_float);
     (us_behavior_actions._bhv_shallow_water_splash_init, us_behavior_actions._random_u16)]
  | VersionUS, Unit_obj_behaviors_2 =>
    [(us_obj_behaviors_2._random_linear_offset, us_obj_behaviors_2._random_float);
     (us_obj_behaviors_2._random_mod_offset, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._obj_random_fixed_turn, us_obj_behaviors_2._random_sign);
     (us_obj_behaviors_2._koopa_shelled_act_stopped, us_obj_behaviors_2._random_sign);
     (us_obj_behaviors_2._fly_guy_act_idle, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._fly_guy_act_approach_mario, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._fly_guy_act_lunge, us_obj_behaviors_2._random_float);
     (us_obj_behaviors_2._goomba_act_walk, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._chain_chomp_released_lunge_around, us_obj_behaviors_2._random_sign);
     (us_obj_behaviors_2._wiggler_act_walk, us_obj_behaviors_2._random_sign);
     (us_obj_behaviors_2._spiny_act_walk, us_obj_behaviors_2._random_sign);
     (us_obj_behaviors_2._monty_mole_select_available_hole, us_obj_behaviors_2._random_float);
     (us_obj_behaviors_2._monty_mole_act_select_hole, us_obj_behaviors_2._random_sign);
     (us_obj_behaviors_2._bhv_ttc_pendulum_update, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._bhv_ttc_pendulum_update, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._bhv_ttc_treadmill_update, us_obj_behaviors_2._random_sign);
     (us_obj_behaviors_2._ttc_moving_bar_act_wait, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._ttc_moving_bar_act_wait, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._ttc_moving_bar_act_extend, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._bhv_ttc_cog_update, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._bhv_ttc_cog_update, us_obj_behaviors_2._random_sign);
     (us_obj_behaviors_2._bhv_ttc_elevator_update, us_obj_behaviors_2._random_sign);
     (us_obj_behaviors_2._bhv_ttc_2d_rotator_update, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._bhv_ttc_spinner_update, us_obj_behaviors_2._random_sign);
     (us_obj_behaviors_2._water_bomb_cannon_act_1, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._water_bomb_cannon_act_1, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._bhv_book_switch_loop, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._bhv_small_piranha_flame_loop, us_obj_behaviors_2._random_float);
     (us_obj_behaviors_2._bhv_small_piranha_flame_loop, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._eyerok_boss_act_fight, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._eyerok_hand_act_idle, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._klepto_change_target, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._bird_act_inactive, us_obj_behaviors_2._random_float);
     (us_obj_behaviors_2._bird_act_inactive, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._skeeter_act_lunge, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._skeeter_act_walk, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._triplet_butterfly_act_init, us_obj_behaviors_2._random_u16);
     (us_obj_behaviors_2._bhv_bubba_loop, us_obj_behaviors_2._random_u16)]
  | VersionJP, Unit_camera =>
    [(jp_camera._set_camera_shake_from_hit, jp_camera._random_float);
     (jp_camera._set_camera_shake_from_hit, jp_camera._random_float);
     (jp_camera._shake_camera_handheld, jp_camera._random_float);
     (jp_camera._random_vec3s, jp_camera._random_float);
     (jp_camera._random_vec3s, jp_camera._random_float);
     (jp_camera._random_vec3s, jp_camera._random_float);
     (jp_camera._bhv_end_birds_1_loop, jp_camera._random_float);
     (jp_camera._bhv_end_birds_2_loop, jp_camera._random_float);
     (jp_camera._bhv_end_birds_2_loop, jp_camera._random_float);
     (jp_camera._spawn_child_obj_relative, jp_camera._random_float)]
  | VersionJP, Unit_envfx_snow =>
    [(jp_envfx_snow._envfx_update_snow_normal, jp_envfx_snow._random_float);
     (jp_envfx_snow._envfx_update_snow_normal, jp_envfx_snow._random_float);
     (jp_envfx_snow._envfx_update_snow_normal, jp_envfx_snow._random_float);
     (jp_envfx_snow._envfx_update_snow_normal, jp_envfx_snow._random_float);
     (jp_envfx_snow._envfx_update_snow_normal, jp_envfx_snow._random_float);
     (jp_envfx_snow._envfx_update_snow_blizzard, jp_envfx_snow._random_float);
     (jp_envfx_snow._envfx_update_snow_blizzard, jp_envfx_snow._random_float);
     (jp_envfx_snow._envfx_update_snow_blizzard, jp_envfx_snow._random_float);
     (jp_envfx_snow._envfx_update_snow_blizzard, jp_envfx_snow._random_float);
     (jp_envfx_snow._envfx_update_snow_blizzard, jp_envfx_snow._random_float);
     (jp_envfx_snow._envfx_update_snow_water, jp_envfx_snow._random_float);
     (jp_envfx_snow._envfx_update_snow_water, jp_envfx_snow._random_float);
     (jp_envfx_snow._envfx_update_snow_water, jp_envfx_snow._random_float)]
  | VersionJP, Unit_envfx_bubbles =>
    [(jp_envfx_bubbles._random_flower_offset, jp_envfx_bubbles._random_float);
     (jp_envfx_bubbles._envfx_update_flower, jp_envfx_bubbles._random_float);
     (jp_envfx_bubbles._envfx_set_lava_bubble_position, jp_envfx_bubbles._random_float);
     (jp_envfx_bubbles._envfx_set_lava_bubble_position, jp_envfx_bubbles._random_float);
     (jp_envfx_bubbles._envfx_update_lava, jp_envfx_bubbles._random_float);
     (jp_envfx_bubbles._envfx_update_whirlpool, jp_envfx_bubbles._random_float);
     (jp_envfx_bubbles._envfx_update_whirlpool, jp_envfx_bubbles._random_float);
     (jp_envfx_bubbles._envfx_update_whirlpool, jp_envfx_bubbles._random_float);
     (jp_envfx_bubbles._envfx_update_jetstream, jp_envfx_bubbles._random_float);
     (jp_envfx_bubbles._envfx_update_jetstream, jp_envfx_bubbles._random_u16);
     (jp_envfx_bubbles._envfx_update_jetstream, jp_envfx_bubbles._random_float);
     (jp_envfx_bubbles._envfx_init_bubble, jp_envfx_bubbles._random_float)]
  | VersionJP, Unit_behavior_script =>
    [(jp_behavior_script._random_float, jp_behavior_script._random_u16);
     (jp_behavior_script._random_sign, jp_behavior_script._random_u16);
     (jp_behavior_script._bhv_cmd_set_random_float, jp_behavior_script._random_float);
     (jp_behavior_script._bhv_cmd_set_random_int, jp_behavior_script._random_float);
     (jp_behavior_script._bhv_cmd_set_int_rand_rshift, jp_behavior_script._random_u16);
     (jp_behavior_script._bhv_cmd_add_random_float, jp_behavior_script._random_float);
     (jp_behavior_script._bhv_cmd_add_int_rand_rshift, jp_behavior_script._random_u16)]
  | VersionJP, Unit_object_helpers =>
    [(jp_object_helpers._spawn_water_droplet, jp_object_helpers._random_u16);
     (jp_object_helpers._spawn_water_droplet, jp_object_helpers._random_float);
     (jp_object_helpers._spawn_water_droplet, jp_object_helpers._random_float);
     (jp_object_helpers._spawn_water_droplet, jp_object_helpers._random_float);
     (jp_object_helpers._random_f32_around_zero, jp_object_helpers._random_float);
     (jp_object_helpers._obj_scale_random, jp_object_helpers._random_float);
     (jp_object_helpers._obj_translate_xyz_random, jp_object_helpers._random_float);
     (jp_object_helpers._obj_translate_xyz_random, jp_object_helpers._random_float);
     (jp_object_helpers._obj_translate_xyz_random, jp_object_helpers._random_float);
     (jp_object_helpers._obj_translate_xz_random, jp_object_helpers._random_float);
     (jp_object_helpers._obj_translate_xz_random, jp_object_helpers._random_float);
     (jp_object_helpers._cur_obj_spawn_particles, jp_object_helpers._random_float);
     (jp_object_helpers._cur_obj_spawn_particles, jp_object_helpers._random_u16);
     (jp_object_helpers._cur_obj_spawn_particles, jp_object_helpers._random_float);
     (jp_object_helpers._cur_obj_spawn_particles, jp_object_helpers._random_float)]
  | VersionJP, Unit_obj_behaviors =>
    [(jp_obj_behaviors._obj_return_and_displace_home, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._obj_return_and_displace_home, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._obj_return_and_displace_home, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._obj_spawn_yellow_coins, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._obj_spawn_yellow_coins, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._obj_spawn_yellow_coins, jp_obj_behaviors._random_u16);
     (jp_obj_behaviors._obj_lava_death, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._obj_lava_death, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._obj_lava_death, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._obj_lava_death, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_seaweed_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_seaweed_bundle_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_seaweed_bundle_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_seaweed_bundle_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._curr_obj_random_blink, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_bobomb_fuse_smoke_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_bobomb_fuse_smoke_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_bobomb_fuse_smoke_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_circling_amp_init, jp_obj_behaviors._random_u16);
     (jp_obj_behaviors._bhv_butterfly_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_butterfly_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_object_bubble_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_object_bubble_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_object_bubble_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_bobomb_explosion_bubble_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_bobomb_explosion_bubble_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_bobomb_explosion_bubble_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_bobomb_explosion_bubble_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bully_spawn_coin, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._water_ring_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._water_ring_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._water_ring_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_bowser_bomb_explosion_loop, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_bowser_bomb_explosion_loop, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_bowser_bomb_explosion_loop, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_small_bomp_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_large_bomp_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_wf_sliding_platform_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._moneybag_act_move_around, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_generic_bowling_ball_spawner_loop, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_thi_bowling_ball_spawner_loop, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_pyramid_top_spinning, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_pyramid_top_spinning, jp_obj_behaviors._random_u16);
     (jp_obj_behaviors._bhv_pyramid_top_spinning, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_pyramid_top_explode, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_pyramid_top_explode, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_pyramid_top_explode, jp_obj_behaviors._random_u16);
     (jp_obj_behaviors._bhv_pyramid_top_explode, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_castle_flag_init, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_big_boulder_generator_loop, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._bhv_big_boulder_generator_loop, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._small_breakable_box_spawn_dust, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._small_breakable_box_spawn_dust, jp_obj_behaviors._random_float);
     (jp_obj_behaviors._yoshi_idle_loop, jp_obj_behaviors._random_float)]
  | VersionJP, Unit_behavior_actions =>
    [(jp_behavior_actions._bhv_piranha_particle_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_piranha_particle_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_piranha_particle_loop, jp_behavior_actions._random_u16);
     (jp_behavior_actions._mr_i_act_2, jp_behavior_actions._random_float);
     (jp_behavior_actions._mr_i_act_2, jp_behavior_actions._random_float);
     (jp_behavior_actions._mr_i_act_1, jp_behavior_actions._random_float);
     (jp_behavior_actions._mr_i_act_1, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_beta_chest_bottom_init, jp_behavior_actions._random_u16);
     (jp_behavior_actions._bhv_water_air_bubble_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_water_air_bubble_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_bubble_wave_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_bubble_wave_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._scale_bubble_random, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_bubble_maybe_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_bubble_maybe_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_bubble_maybe_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_particle_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_particle_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._chuckya_act_1, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_spawned_coin_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_spawned_coin_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_spawned_coin_init, jp_behavior_actions._random_u16);
     (jp_behavior_actions._bhv_golden_coin_sparkles_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_golden_coin_sparkles_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._grindel_thwomp_act_idle_at_bottom, jp_behavior_actions._random_float);
     (jp_behavior_actions._grindel_thwomp_act_idle_at_top, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_tumbling_bridge_platform_loop, jp_behavior_actions._random_sign);
     (jp_behavior_actions._spawn_triangle_break_particles, jp_behavior_actions._random_u16);
     (jp_behavior_actions._spawn_triangle_break_particles, jp_behavior_actions._random_u16);
     (jp_behavior_actions._spawn_triangle_break_particles, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_water_mist_2_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_wind_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_wind_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_wind_loop, jp_behavior_actions._random_u16);
     (jp_behavior_actions._bhv_wind_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_wind_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_flamethrower_flame_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_bouncing_fireball_flame_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_bouncing_fireball_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_black_smoke_bowser_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_black_smoke_bowser_loop, jp_behavior_actions._random_u16);
     (jp_behavior_actions._bhv_black_smoke_mario_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_black_smoke_mario_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_tree_snow_or_leaf_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_tree_snow_or_leaf_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_tree_snow_or_leaf_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_snow_leaf_particle_spawn_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_snow_leaf_particle_spawn_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_snow_leaf_particle_spawn_init, jp_behavior_actions._random_u16);
     (jp_behavior_actions._bhv_snow_leaf_particle_spawn_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_snow_leaf_particle_spawn_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_snow_leaf_particle_spawn_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_snow_leaf_particle_spawn_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_snow_leaf_particle_spawn_init, jp_behavior_actions._random_u16);
     (jp_behavior_actions._bhv_snow_leaf_particle_spawn_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_snow_leaf_particle_spawn_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_snow_leaf_particle_spawn_init, jp_behavior_actions._random_u16);
     (jp_behavior_actions._bhv_snow_leaf_particle_spawn_init, jp_behavior_actions._random_u16);
     (jp_behavior_actions._bhv_snow_leaf_particle_spawn_init, jp_behavior_actions._random_u16);
     (jp_behavior_actions._bhv_piranha_plant_waking_bubbles_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_piranha_plant_waking_bubbles_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_piranha_plant_waking_bubbles_loop, jp_behavior_actions._random_u16);
     (jp_behavior_actions._jumping_box_act_0, jp_behavior_actions._random_float);
     (jp_behavior_actions._jumping_box_act_0, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_white_puff_smoke_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bowser_bitdw_actions, jp_behavior_actions._random_float);
     (jp_behavior_actions._bowser_bitfs_actions, jp_behavior_actions._random_float);
     (jp_behavior_actions._bowser_bits_action_list, jp_behavior_actions._random_float);
     (jp_behavior_actions._bowser_act_spit_fire_onto_floor, jp_behavior_actions._random_float);
     (jp_behavior_actions._bowser_flame_despawn, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_flame_bowser_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_flame_bowser_init, jp_behavior_actions._random_u16);
     (jp_behavior_actions._bhv_flame_bowser_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_flame_bowser_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_flame_large_burning_out_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_flame_large_burning_out_init, jp_behavior_actions._random_u16);
     (jp_behavior_actions._bhv_flame_bowser_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_flame_moving_forward_growing_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_flame_floating_landing_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_flame_floating_landing_init, jp_behavior_actions._random_u16);
     (jp_behavior_actions._bhv_flame_floating_landing_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_flame_floating_landing_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_flame_floating_landing_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_flame_floating_landing_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_blue_bowser_flame_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_blue_bowser_flame_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_blue_bowser_flame_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_flame_bouncing_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_flame_bouncing_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_blue_fish_movement_loop, jp_behavior_actions._random_sign);
     (jp_behavior_actions._bhv_blue_fish_movement_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_blue_fish_movement_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_blue_fish_movement_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._idle_ukiki_taunt, jp_behavior_actions._random_float);
     (jp_behavior_actions._idle_ukiki_taunt, jp_behavior_actions._random_float);
     (jp_behavior_actions._ukiki_act_turn_to_mario, jp_behavior_actions._random_float);
     (jp_behavior_actions._ukiki_act_run, jp_behavior_actions._random_float);
     (jp_behavior_actions._ukiki_act_jump, jp_behavior_actions._random_float);
     (jp_behavior_actions._hexagonal_ring_spawn_flames, jp_behavior_actions._random_u16);
     (jp_behavior_actions._hexagonal_ring_spawn_flames, jp_behavior_actions._random_float);
     (jp_behavior_actions._hexagonal_ring_spawn_flames, jp_behavior_actions._random_float);
     (jp_behavior_actions._hexagonal_ring_spawn_flames, jp_behavior_actions._random_float);
     (jp_behavior_actions._hexagonal_ring_spawn_flames, jp_behavior_actions._random_float);
     (jp_behavior_actions._koopa_shell_spawn_water_drop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_koopa_shell_flame_loop, jp_behavior_actions._random_u16);
     (jp_behavior_actions._bhv_koopa_shell_flame_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_koopa_shell_flame_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._small_penguin_act_0, jp_behavior_actions._random_float);
     (jp_behavior_actions._small_penguin_act_0, jp_behavior_actions._random_float);
     (jp_behavior_actions._small_penguin_act_0, jp_behavior_actions._random_float);
     (jp_behavior_actions._fish_act_roam, jp_behavior_actions._random_float);
     (jp_behavior_actions._fish_act_roam, jp_behavior_actions._random_float);
     (jp_behavior_actions._fish_act_roam, jp_behavior_actions._random_float);
     (jp_behavior_actions._fish_act_roam, jp_behavior_actions._random_float);
     (jp_behavior_actions._fish_act_flee, jp_behavior_actions._random_float);
     (jp_behavior_actions._fish_act_flee, jp_behavior_actions._random_float);
     (jp_behavior_actions._fish_act_flee, jp_behavior_actions._random_float);
     (jp_behavior_actions._fish_act_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._fish_act_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._fish_act_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bub_act_0, jp_behavior_actions._random_float);
     (jp_behavior_actions._bub_act_0, jp_behavior_actions._random_float);
     (jp_behavior_actions._bub_act_1, jp_behavior_actions._random_float);
     (jp_behavior_actions._bub_act_1, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_tweester_sand_particle_loop, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_tweester_sand_particle_loop, jp_behavior_actions._random_u16);
     (jp_behavior_actions._bhv_tweester_sand_particle_loop, jp_behavior_actions._random_u16);
     (jp_behavior_actions._bhv_courtyard_boo_triplet_init, jp_behavior_actions._random_u16);
     (jp_behavior_actions._boo_act_1, jp_behavior_actions._random_float);
     (jp_behavior_actions._boo_act_1, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_water_droplet_loop, jp_behavior_actions._random_u16);
     (jp_behavior_actions._bhv_water_droplet_splash_init, jp_behavior_actions._random_float);
     (jp_behavior_actions._bhv_shallow_water_splash_init, jp_behavior_actions._random_u16)]
  | VersionJP, Unit_obj_behaviors_2 =>
    [(jp_obj_behaviors_2._random_linear_offset, jp_obj_behaviors_2._random_float);
     (jp_obj_behaviors_2._random_mod_offset, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._obj_random_fixed_turn, jp_obj_behaviors_2._random_sign);
     (jp_obj_behaviors_2._koopa_shelled_act_stopped, jp_obj_behaviors_2._random_sign);
     (jp_obj_behaviors_2._fly_guy_act_idle, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._fly_guy_act_approach_mario, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._fly_guy_act_lunge, jp_obj_behaviors_2._random_float);
     (jp_obj_behaviors_2._goomba_act_walk, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._chain_chomp_released_lunge_around, jp_obj_behaviors_2._random_sign);
     (jp_obj_behaviors_2._wiggler_act_walk, jp_obj_behaviors_2._random_sign);
     (jp_obj_behaviors_2._spiny_act_walk, jp_obj_behaviors_2._random_sign);
     (jp_obj_behaviors_2._monty_mole_select_available_hole, jp_obj_behaviors_2._random_float);
     (jp_obj_behaviors_2._monty_mole_act_select_hole, jp_obj_behaviors_2._random_sign);
     (jp_obj_behaviors_2._bhv_ttc_pendulum_update, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._bhv_ttc_pendulum_update, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._bhv_ttc_treadmill_update, jp_obj_behaviors_2._random_sign);
     (jp_obj_behaviors_2._ttc_moving_bar_act_wait, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._ttc_moving_bar_act_wait, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._ttc_moving_bar_act_extend, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._bhv_ttc_cog_update, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._bhv_ttc_cog_update, jp_obj_behaviors_2._random_sign);
     (jp_obj_behaviors_2._bhv_ttc_elevator_update, jp_obj_behaviors_2._random_sign);
     (jp_obj_behaviors_2._bhv_ttc_2d_rotator_update, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._bhv_ttc_spinner_update, jp_obj_behaviors_2._random_sign);
     (jp_obj_behaviors_2._water_bomb_cannon_act_1, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._water_bomb_cannon_act_1, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._bhv_book_switch_loop, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._bhv_small_piranha_flame_loop, jp_obj_behaviors_2._random_float);
     (jp_obj_behaviors_2._bhv_small_piranha_flame_loop, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._eyerok_boss_act_fight, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._eyerok_hand_act_idle, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._klepto_change_target, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._bird_act_inactive, jp_obj_behaviors_2._random_float);
     (jp_obj_behaviors_2._bird_act_inactive, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._skeeter_act_lunge, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._skeeter_act_walk, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._triplet_butterfly_act_init, jp_obj_behaviors_2._random_u16);
     (jp_obj_behaviors_2._bhv_bubba_loop, jp_obj_behaviors_2._random_u16)]
  | _, _ => []
  end.
Definition expected_rng_computed_callers (version : GameVersion) (unit : RNGSourceUnit) : list ident :=
  match version, unit with
  | VersionUS, Unit_mario_actions_moving =>
    [us_mario_actions_moving._common_landing_cancels]
  | VersionUS, Unit_interaction =>
    [us_interaction._mario_process_interactions]
  | VersionUS, Unit_camera =>
    [us_camera._set_camera_mode;
     us_camera._camera_course_processing;
     us_camera._play_cutscene;
     us_camera._cutscene_event]
  | VersionUS, Unit_behavior_script =>
    [us_behavior_script._bhv_cmd_call_native;
     us_behavior_script._cur_obj_update]
  | VersionUS, Unit_graph_node =>
    [us_graph_node._init_graph_node_perspective;
     us_graph_node._init_graph_node_switch_case;
     us_graph_node._init_graph_node_camera;
     us_graph_node._init_graph_node_generated;
     us_graph_node._init_graph_node_background;
     us_graph_node._init_graph_node_held_object;
     us_graph_node._geo_call_global_function_nodes_helper]
  | VersionUS, Unit_object_helpers =>
    [us_object_helpers._cur_obj_call_action_function]
  | VersionJP, Unit_mario_actions_moving =>
    [jp_mario_actions_moving._common_landing_cancels]
  | VersionJP, Unit_interaction =>
    [jp_interaction._mario_process_interactions]
  | VersionJP, Unit_camera =>
    [jp_camera._set_camera_mode;
     jp_camera._camera_course_processing;
     jp_camera._play_cutscene;
     jp_camera._cutscene_event]
  | VersionJP, Unit_behavior_script =>
    [jp_behavior_script._bhv_cmd_call_native;
     jp_behavior_script._cur_obj_update]
  | VersionJP, Unit_graph_node =>
    [jp_graph_node._init_graph_node_perspective;
     jp_graph_node._init_graph_node_switch_case;
     jp_graph_node._init_graph_node_camera;
     jp_graph_node._init_graph_node_generated;
     jp_graph_node._init_graph_node_background;
     jp_graph_node._init_graph_node_held_object;
     jp_graph_node._geo_call_global_function_nodes_helper]
  | VersionJP, Unit_object_helpers =>
    [jp_object_helpers._cur_obj_call_action_function]
  | _, _ => []
  end.
Definition expected_rng_particle_field_writers (version : GameVersion) (unit : RNGSourceUnit) : list ident :=
  match version, unit with
  | VersionUS, Unit_mario =>
    [us_mario._play_sound_and_spawn_particles;
     us_mario._update_mario_inputs;
     us_mario._set_submerged_cam_preset_and_spawn_bubbles]
  | VersionUS, Unit_mario_actions_airborne =>
    [us_mario_actions_airborne._check_fall_damage_or_get_stuck;
     us_mario_actions_airborne._common_air_action_step;
     us_mario_actions_airborne._act_dive;
     us_mario_actions_airborne._act_ground_pound;
     us_mario_actions_airborne._act_burning_jump;
     us_mario_actions_airborne._act_burning_fall;
     us_mario_actions_airborne._act_crazy_box_bounce;
     us_mario_actions_airborne._act_air_hit_wall;
     us_mario_actions_airborne._act_butt_slide_air;
     us_mario_actions_airborne._act_hold_butt_slide_air;
     us_mario_actions_airborne._act_lava_boost;
     us_mario_actions_airborne._act_slide_kick;
     us_mario_actions_airborne._act_shot_from_cannon;
     us_mario_actions_airborne._act_flying;
     us_mario_actions_airborne._act_special_triple_jump]
  | VersionUS, Unit_mario_actions_moving =>
    [us_mario_actions_moving._push_or_sidle_wall;
     us_mario_actions_moving._act_walking;
     us_mario_actions_moving._act_move_punching;
     us_mario_actions_moving._act_hold_walking;
     us_mario_actions_moving._act_turning_around;
     us_mario_actions_moving._act_braking;
     us_mario_actions_moving._act_decelerating;
     us_mario_actions_moving._act_hold_decelerating;
     us_mario_actions_moving._act_riding_shell_ground;
     us_mario_actions_moving._act_burning_ground;
     us_mario_actions_moving._common_slide_action;
     us_mario_actions_moving._act_slide_kick_slide;
     us_mario_actions_moving._common_landing_action;
     us_mario_actions_moving._mario_execute_moving_action]
  | VersionUS, Unit_mario_actions_stationary =>
    [us_mario_actions_stationary._act_shivering;
     us_mario_actions_stationary._mario_execute_stationary_action]
  | VersionUS, Unit_mario_actions_automatic =>
    [us_mario_actions_automatic._add_tree_leaf_particles;
     us_mario_actions_automatic._act_holding_pole]
  | VersionUS, Unit_mario_actions_submerged =>
    [us_mario_actions_submerged._set_swimming_at_surface_particles;
     us_mario_actions_submerged._act_water_plunge;
     us_mario_actions_submerged._play_metal_water_jumping_sound;
     us_mario_actions_submerged._play_metal_water_walking_sound;
     us_mario_actions_submerged._act_metal_water_standing]
  | VersionUS, Unit_mario_actions_cutscene =>
    [us_mario_actions_cutscene._act_fall_after_star_grab;
     us_mario_actions_cutscene._act_exit_airborne;
     us_mario_actions_cutscene._act_falling_exit_airborne;
     us_mario_actions_cutscene._act_special_exit_airborne;
     us_mario_actions_cutscene._jumbo_star_cutscene_taking_off;
     us_mario_actions_cutscene._jumbo_star_cutscene_flying;
     us_mario_actions_cutscene._end_peach_cutscene_run_to_peach;
     us_mario_actions_cutscene._act_credits_cutscene;
     us_mario_actions_cutscene._mario_execute_cutscene_action]
  | VersionUS, Unit_mario_actions_object =>
    [us_mario_actions_object._mario_execute_object_action]
  | VersionUS, Unit_interaction =>
    [us_interaction._bounce_back_from_attack;
     us_interaction._check_kick_or_punch_wall]
  | VersionJP, Unit_mario =>
    [jp_mario._play_sound_and_spawn_particles;
     jp_mario._update_mario_inputs;
     jp_mario._set_submerged_cam_preset_and_spawn_bubbles]
  | VersionJP, Unit_mario_actions_airborne =>
    [jp_mario_actions_airborne._check_fall_damage_or_get_stuck;
     jp_mario_actions_airborne._common_air_action_step;
     jp_mario_actions_airborne._act_dive;
     jp_mario_actions_airborne._act_ground_pound;
     jp_mario_actions_airborne._act_burning_jump;
     jp_mario_actions_airborne._act_burning_fall;
     jp_mario_actions_airborne._act_crazy_box_bounce;
     jp_mario_actions_airborne._act_air_hit_wall;
     jp_mario_actions_airborne._act_butt_slide_air;
     jp_mario_actions_airborne._act_hold_butt_slide_air;
     jp_mario_actions_airborne._act_lava_boost;
     jp_mario_actions_airborne._act_slide_kick;
     jp_mario_actions_airborne._act_shot_from_cannon;
     jp_mario_actions_airborne._act_flying;
     jp_mario_actions_airborne._act_special_triple_jump]
  | VersionJP, Unit_mario_actions_moving =>
    [jp_mario_actions_moving._push_or_sidle_wall;
     jp_mario_actions_moving._act_walking;
     jp_mario_actions_moving._act_move_punching;
     jp_mario_actions_moving._act_hold_walking;
     jp_mario_actions_moving._act_turning_around;
     jp_mario_actions_moving._act_braking;
     jp_mario_actions_moving._act_decelerating;
     jp_mario_actions_moving._act_hold_decelerating;
     jp_mario_actions_moving._act_riding_shell_ground;
     jp_mario_actions_moving._act_burning_ground;
     jp_mario_actions_moving._common_slide_action;
     jp_mario_actions_moving._act_slide_kick_slide;
     jp_mario_actions_moving._common_landing_action;
     jp_mario_actions_moving._mario_execute_moving_action]
  | VersionJP, Unit_mario_actions_stationary =>
    [jp_mario_actions_stationary._act_shivering;
     jp_mario_actions_stationary._mario_execute_stationary_action]
  | VersionJP, Unit_mario_actions_automatic =>
    [jp_mario_actions_automatic._add_tree_leaf_particles;
     jp_mario_actions_automatic._act_holding_pole]
  | VersionJP, Unit_mario_actions_submerged =>
    [jp_mario_actions_submerged._set_swimming_at_surface_particles;
     jp_mario_actions_submerged._act_water_plunge;
     jp_mario_actions_submerged._play_metal_water_jumping_sound;
     jp_mario_actions_submerged._play_metal_water_walking_sound;
     jp_mario_actions_submerged._act_metal_water_standing]
  | VersionJP, Unit_mario_actions_cutscene =>
    [jp_mario_actions_cutscene._act_fall_after_star_grab;
     jp_mario_actions_cutscene._act_exit_airborne;
     jp_mario_actions_cutscene._act_falling_exit_airborne;
     jp_mario_actions_cutscene._act_special_exit_airborne;
     jp_mario_actions_cutscene._jumbo_star_cutscene_taking_off;
     jp_mario_actions_cutscene._jumbo_star_cutscene_flying;
     jp_mario_actions_cutscene._end_peach_cutscene_run_to_peach;
     jp_mario_actions_cutscene._act_credits_cutscene;
     jp_mario_actions_cutscene._mario_execute_cutscene_action]
  | VersionJP, Unit_mario_actions_object =>
    [jp_mario_actions_object._mario_execute_object_action]
  | VersionJP, Unit_interaction =>
    [jp_interaction._bounce_back_from_attack;
     jp_interaction._check_kick_or_punch_wall]
  | _, _ => []
  end.

Definition rng_unit_catalogue_claim version unit : Prop :=
  rng_source_sites version unit = expected_rng_source_sites version unit /\
  rng_primitive_escapers version unit = [] /\
  rng_primitive_initializer_references version unit = [] /\
  rng_computed_callers version unit = expected_rng_computed_callers version unit /\
  rng_particle_field_writers version unit = expected_rng_particle_field_writers version unit /\
  rng_seed_referencers version unit =
    match unit with Unit_behavior_script => [us_behavior_script._random_u16] | _ => [] end.

Theorem generated_rng_unit_catalogues_us_jp :
  forall version unit, rng_unit_catalogue_claim version unit.
Proof. intros [] []; vm_compute; repeat split; reflexivity. Qed.

Theorem generated_rng_source_site_coverage_us_jp :
  forall version unit caller f callee ty,
    In (caller, Gfun (Internal f)) (prog_defs (rng_source_program version unit)) ->
    In callee gameplay_rng_primitives -> call_occurs (Evar callee ty) (fn_body f) ->
    In (caller, callee) (expected_rng_source_sites version unit).
Proof.
  intros version unit caller f callee ty Hfunction Hprimitive Hcall.
  destruct (generated_rng_unit_catalogues_us_jp version unit) as [Hsites _].
  rewrite <- Hsites. unfold rng_source_sites.
  eapply named_call_sites_complete; eauto.
Qed.

Definition all_rng_source_units : list RNGSourceUnit :=
  [Unit_mario; Unit_mario_step; Unit_mario_actions_airborne; Unit_mario_actions_moving; Unit_mario_actions_stationary; Unit_mario_actions_automatic; Unit_mario_actions_submerged; Unit_mario_actions_cutscene; Unit_mario_actions_object; Unit_interaction; Unit_camera; Unit_envfx_snow; Unit_envfx_bubbles; Unit_mario_misc; Unit_ingame_menu; Unit_level_geo; Unit_area; Unit_level_scripts; Unit_save_file; Unit_spawn_sound; Unit_memory; Unit_object_list_processor; Unit_behavior_script; Unit_graph_node; Unit_audio_external; Unit_spawn_object; Unit_macro_special_objects; Unit_math_util; Unit_surface_load; Unit_surface_collision; Unit_object_helpers; Unit_obj_behaviors; Unit_behavior_actions; Unit_obj_behaviors_2; Unit_behavior_data; Unit_platform_displacement; Unit_ttc_level_script; Unit_ttc_geo; Unit_ttc_area1_macro; Unit_ttc_spinner_collision; Unit_ttc_cog_collision].

Definition rng_source_catalogue_claim : Prop :=
  (forall version unit, rng_unit_catalogue_claim version unit) /\
  (forall version unit caller f callee ty,
    In (caller, Gfun (Internal f)) (prog_defs (rng_source_program version unit)) ->
    In callee gameplay_rng_primitives -> call_occurs (Evar callee ty) (fn_body f) ->
    In (caller, callee) (expected_rng_source_sites version unit)).

Theorem checked_rng_source_catalogue_us_jp : rng_source_catalogue_claim.
Proof. exact (conj generated_rng_unit_catalogues_us_jp generated_rng_source_site_coverage_us_jp). Qed.
