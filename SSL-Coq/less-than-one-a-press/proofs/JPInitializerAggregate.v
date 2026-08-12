(** Resource-bounded aggregation of the per-unit JP initializer receipts. *)

From Coq Require Import List.
From LessThanOneAPress.Proofs Require Import
  LinkedClightPrograms NormalizedClightPrograms ClightInitialMemoryFacts
  JPInitializerReceipt01 JPInitializerReceipt02 JPInitializerReceipt03
  JPInitializerReceipt04 JPInitializerReceipt05 JPInitializerReceipt06
  JPInitializerReceipt07 JPInitializerReceipt08 JPInitializerReceipt09
  JPInitializerReceipt10 JPInitializerReceipt11 JPInitializerReceipt12.

Theorem jp_units_initializers_aligned :
  NListProgramInitializersAligned jp_units.
Proof.
  unfold jp_units.
  apply nlist_program_initializers_aligned_cons;
    [exact jp_game_init_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_mario_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_mario_actions_airborne_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_mario_actions_automatic_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_mario_actions_cutscene_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_mario_actions_moving_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_mario_actions_object_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_mario_actions_stationary_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_mario_actions_submerged_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_mario_step_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_interaction_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_save_file_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_object_collision_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_object_list_processor_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_behavior_script_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_level_script_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_graph_node_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_rendering_graph_node_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_spawn_object_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_object_helpers_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_debug_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_memory_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_mario_misc_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_obj_behaviors_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_obj_behaviors_2_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_behavior_actions_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_behavior_data_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_area_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_level_update_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_platform_displacement_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_math_util_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_surface_collision_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_surface_load_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_macro_special_objects_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_ssl_script_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_ssl_area1_macro_initializers_aligned |].
  apply nlist_program_initializers_aligned_cons;
    [exact jp_ssl_area2_macro_initializers_aligned |].
  apply nlist_program_initializers_aligned_base.
  exact jp_ssl_collision_initializers_aligned.
Qed.
Lemma unit_global_definitions_are_nlist_program_definitions :
  forall programs,
    unit_global_definitions programs = nlist_program_definitions programs.
Proof.
  intros programs. unfold unit_global_definitions.
  induction programs as [program | program rest IH]; cbn.
  - now rewrite app_nil_r.
  - now rewrite IH.
Qed.
