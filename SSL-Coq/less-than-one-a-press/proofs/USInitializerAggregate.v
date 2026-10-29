(** Resource-bounded aggregation of the per-unit US initializer receipts. *)

From Coq Require Import List.
From LessThanOneAPress.Proofs Require Import
  LinkedClightPrograms NormalizedClightPrograms ClightInitialMemoryFacts
  USInitializerReceipt01 USInitializerReceipt02 USInitializerReceipt03
  USInitializerReceipt04 USInitializerReceipt05 USInitializerReceipt06
  USInitializerReceipt07 USInitializerReceipt08 USInitializerReceipt09
  USInitializerReceipt10 USInitializerReceipt11 USInitializerReceipt12.

Theorem us_units_initializers_aligned :
  NListProgramInitializersAligned us_units.
Proof.
  unfold us_units.
  apply nlist_program_initializers_aligned_cons;
    [exact us_game_init_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_mario_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_mario_actions_airborne_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_mario_actions_automatic_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_mario_actions_cutscene_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_mario_actions_moving_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_mario_actions_object_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_mario_actions_stationary_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_mario_actions_submerged_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_mario_step_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_interaction_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_save_file_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_object_collision_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_object_list_processor_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_behavior_script_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_level_script_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_graph_node_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_rendering_graph_node_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_spawn_object_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_object_helpers_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_debug_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_memory_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_mario_misc_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_obj_behaviors_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_obj_behaviors_2_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_behavior_actions_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_behavior_data_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_area_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_level_update_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_platform_displacement_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_math_util_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_surface_collision_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_surface_load_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_macro_special_objects_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_ssl_script_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_ssl_area1_macro_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_ssl_area2_macro_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact us_ssl_collision_initializers_aligned |].
  apply nlist_program_initializers_aligned_base.
  exact us_bobomb_animation_data_initializers_aligned.
Qed.
