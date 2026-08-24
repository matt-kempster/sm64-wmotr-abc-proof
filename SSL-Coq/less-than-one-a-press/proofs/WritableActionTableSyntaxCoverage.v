(** Whole-program source-syntax coverage for the private action tables.

    Each of the 38 US/JP translation-unit checks is compiled and cached in a
    separate receipt module.  A proposition-valued structural certificate
    then records those receipts in the exact [us_units]/[jp_units] order.
    Consequently this aggregate performs no whole-program Boolean reduction
    and an interrupted build never discards completed source checks.

    The checker itself remains the occurrence-sensitive production checker
    from [WritableActionTableAliasExternalClosure]; this file does not weaken
    its rooted-pointer or terminal-read grammar. *)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Coqlib Ctypes Linking.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms ClightLinkExecution LinkedClightPrograms
  NormalizedClightPrograms WritableActionTableAliasExternalClosure
  WritableActionTableSyntaxBase WritableActionTableSyntaxReceiptAggregate.
From LessThanOneAPress.Proofs.WritableActionTableSyntaxReceipts Require Import
  GameInit Mario MarioActionsAirborne MarioActionsAutomatic
  MarioActionsCutscene MarioActionsMoving MarioActionsObject
  MarioActionsStationary MarioActionsSubmerged MarioStep Interaction SaveFile
  ObjectCollision ObjectListProcessor BehaviorScript LevelScript GraphNode
  RenderingGraphNode SpawnObject ObjectHelpers Debug Memory MarioMisc
  ObjBehaviors ObjBehaviors2 BehaviorActions BehaviorData Area LevelUpdate
  PlatformDisplacement MathUtil SurfaceCollision SurfaceLoad
  MacroSpecialObjects SslScript SslArea1Macro SslArea2Macro SslCollision.

Import ListNotations.

Local Notation watwg_us_table_ids := watsc_us_table_ids.
Local Notation watwg_jp_table_ids := watsc_jp_table_ids.

Theorem watsc_game_init_unit :
  watsc_program_access_safe watwg_us_table_ids us_game_init.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_game_init.prog = true.
Proof. exact watsc_game_init_unit_receipt. Qed.

Theorem watsc_mario_unit :
  watsc_program_access_safe watwg_us_table_ids us_mario.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_mario.prog = true.
Proof. exact watsc_mario_unit_receipt. Qed.

Theorem watsc_mario_actions_airborne_unit :
  watsc_program_access_safe watwg_us_table_ids us_mario_actions_airborne.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_mario_actions_airborne.prog = true.
Proof. exact watsc_mario_actions_airborne_unit_receipt. Qed.

Theorem watsc_mario_actions_automatic_unit :
  watsc_program_access_safe watwg_us_table_ids us_mario_actions_automatic.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_mario_actions_automatic.prog = true.
Proof. exact watsc_mario_actions_automatic_unit_receipt. Qed.

Theorem watsc_mario_actions_cutscene_unit :
  watsc_program_access_safe watwg_us_table_ids us_mario_actions_cutscene.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_mario_actions_cutscene.prog = true.
Proof. exact watsc_mario_actions_cutscene_unit_receipt. Qed.

Theorem watsc_mario_actions_moving_unit :
  watsc_program_access_safe watwg_us_table_ids us_mario_actions_moving.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_mario_actions_moving.prog = true.
Proof. exact watsc_mario_actions_moving_unit_receipt. Qed.

Theorem watsc_mario_actions_object_unit :
  watsc_program_access_safe watwg_us_table_ids us_mario_actions_object.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_mario_actions_object.prog = true.
Proof. exact watsc_mario_actions_object_unit_receipt. Qed.

Theorem watsc_mario_actions_stationary_unit :
  watsc_program_access_safe watwg_us_table_ids us_mario_actions_stationary.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_mario_actions_stationary.prog = true.
Proof. exact watsc_mario_actions_stationary_unit_receipt. Qed.

Theorem watsc_mario_actions_submerged_unit :
  watsc_program_access_safe watwg_us_table_ids us_mario_actions_submerged.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_mario_actions_submerged.prog = true.
Proof. exact watsc_mario_actions_submerged_unit_receipt. Qed.

Theorem watsc_mario_step_unit :
  watsc_program_access_safe watwg_us_table_ids us_mario_step.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_mario_step.prog = true.
Proof. exact watsc_mario_step_unit_receipt. Qed.

Theorem watsc_interaction_unit :
  watsc_program_access_safe watwg_us_table_ids us_interaction.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_interaction.prog = true.
Proof. exact watsc_interaction_unit_receipt. Qed.

Theorem watsc_save_file_unit :
  watsc_program_access_safe watwg_us_table_ids us_save_file.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_save_file.prog = true.
Proof. exact watsc_save_file_unit_receipt. Qed.

Theorem watsc_object_collision_unit :
  watsc_program_access_safe watwg_us_table_ids us_object_collision.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_object_collision.prog = true.
Proof. exact watsc_object_collision_unit_receipt. Qed.

Theorem watsc_object_list_processor_unit :
  watsc_program_access_safe watwg_us_table_ids us_object_list_processor.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_object_list_processor.prog = true.
Proof. exact watsc_object_list_processor_unit_receipt. Qed.

Theorem watsc_behavior_script_unit :
  watsc_program_access_safe watwg_us_table_ids us_behavior_script.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_behavior_script.prog = true.
Proof. exact watsc_behavior_script_unit_receipt. Qed.

Theorem watsc_level_script_unit :
  watsc_program_access_safe watwg_us_table_ids us_level_script.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_level_script.prog = true.
Proof. exact watsc_level_script_unit_receipt. Qed.

Theorem watsc_graph_node_unit :
  watsc_program_access_safe watwg_us_table_ids us_graph_node.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_graph_node.prog = true.
Proof. exact watsc_graph_node_unit_receipt. Qed.

Theorem watsc_rendering_graph_node_unit :
  watsc_program_access_safe watwg_us_table_ids us_rendering_graph_node.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_rendering_graph_node.prog = true.
Proof. exact watsc_rendering_graph_node_unit_receipt. Qed.

Theorem watsc_spawn_object_unit :
  watsc_program_access_safe watwg_us_table_ids us_spawn_object.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_spawn_object.prog = true.
Proof. exact watsc_spawn_object_unit_receipt. Qed.

Theorem watsc_object_helpers_unit :
  watsc_program_access_safe watwg_us_table_ids us_object_helpers.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_object_helpers.prog = true.
Proof. exact watsc_object_helpers_unit_receipt. Qed.

Theorem watsc_debug_unit :
  watsc_program_access_safe watwg_us_table_ids us_debug.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_debug.prog = true.
Proof. exact watsc_debug_unit_receipt. Qed.

Theorem watsc_memory_unit :
  watsc_program_access_safe watwg_us_table_ids us_memory.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_memory.prog = true.
Proof. exact watsc_memory_unit_receipt. Qed.

Theorem watsc_mario_misc_unit :
  watsc_program_access_safe watwg_us_table_ids us_mario_misc.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_mario_misc.prog = true.
Proof. exact watsc_mario_misc_unit_receipt. Qed.

Theorem watsc_obj_behaviors_unit :
  watsc_program_access_safe watwg_us_table_ids us_obj_behaviors.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_obj_behaviors.prog = true.
Proof. exact watsc_obj_behaviors_unit_receipt. Qed.

Theorem watsc_obj_behaviors_2_unit :
  watsc_program_access_safe watwg_us_table_ids us_obj_behaviors_2.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_obj_behaviors_2.prog = true.
Proof. exact watsc_obj_behaviors_2_unit_receipt. Qed.

Theorem watsc_behavior_actions_unit :
  watsc_program_access_safe watwg_us_table_ids us_behavior_actions.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_behavior_actions.prog = true.
Proof. exact watsc_behavior_actions_unit_receipt. Qed.

Theorem watsc_behavior_data_unit :
  watsc_program_access_safe watwg_us_table_ids us_behavior_data.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_behavior_data.prog = true.
Proof. exact watsc_behavior_data_unit_receipt. Qed.

Theorem watsc_area_unit :
  watsc_program_access_safe watwg_us_table_ids us_area.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_area.prog = true.
Proof. exact watsc_area_unit_receipt. Qed.

Theorem watsc_level_update_unit :
  watsc_program_access_safe watwg_us_table_ids us_level_update.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_level_update.prog = true.
Proof. exact watsc_level_update_unit_receipt. Qed.

Theorem watsc_platform_displacement_unit :
  watsc_program_access_safe watwg_us_table_ids us_platform_displacement.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_platform_displacement.prog = true.
Proof. exact watsc_platform_displacement_unit_receipt. Qed.

Theorem watsc_math_util_unit :
  watsc_program_access_safe watwg_us_table_ids us_math_util.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_math_util.prog = true.
Proof. exact watsc_math_util_unit_receipt. Qed.

Theorem watsc_surface_collision_unit :
  watsc_program_access_safe watwg_us_table_ids us_surface_collision.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_surface_collision.prog = true.
Proof. exact watsc_surface_collision_unit_receipt. Qed.

Theorem watsc_surface_load_unit :
  watsc_program_access_safe watwg_us_table_ids us_surface_load.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_surface_load.prog = true.
Proof. exact watsc_surface_load_unit_receipt. Qed.

Theorem watsc_macro_special_objects_unit :
  watsc_program_access_safe watwg_us_table_ids us_macro_special_objects.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_macro_special_objects.prog = true.
Proof. exact watsc_macro_special_objects_unit_receipt. Qed.

Theorem watsc_ssl_script_unit :
  watsc_program_access_safe watwg_us_table_ids us_ssl_script.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_ssl_script.prog = true.
Proof. exact watsc_ssl_script_unit_receipt. Qed.

Theorem watsc_ssl_area1_macro_unit :
  watsc_program_access_safe watwg_us_table_ids us_ssl_area1_macro.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_ssl_area1_macro.prog = true.
Proof. exact watsc_ssl_area1_macro_unit_receipt. Qed.

Theorem watsc_ssl_area2_macro_unit :
  watsc_program_access_safe watwg_us_table_ids us_ssl_area2_macro.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_ssl_area2_macro.prog = true.
Proof. exact watsc_ssl_area2_macro_unit_receipt. Qed.

Theorem watsc_ssl_collision_unit :
  watsc_program_access_safe watwg_us_table_ids us_ssl_collision.prog = true /\
  watsc_program_access_safe watwg_jp_table_ids jp_ssl_collision.prog = true.
Proof. exact watsc_ssl_collision_unit_receipt. Qed.

(** All 38 source units, reconstructed only from independently checked
    receipts and the exact source-unit order. *)
Theorem watsc_all_source_units :
  watsc_source_units_covered watwg_us_table_ids us_units /\
  watsc_source_units_covered watwg_jp_table_ids jp_units.
Proof.
  split; [exact watsc_us_source_units_covered |
          exact watsc_jp_source_units_covered].
Qed.

Lemma watsc_program_access_safe_sound :
  forall targets program function_id body target,
    watsc_program_access_safe targets program = true ->
    In (function_id, Gfun (Internal body)) (prog_defs program) ->
    In target targets ->
    wat_statement_access_safe_s target (fn_body body) = true.
Proof.
  intros targets program function_id body target Hall Hin Htarget.
  unfold watsc_program_access_safe in Hall.
  rewrite forallb_forall in Hall.
  specialize (Hall (function_id, Gfun (Internal body)) Hin).
  change
    (forallb
      (fun found =>
        wat_statement_access_safe_s found (fn_body body))
      targets = true) in Hall.
  rewrite forallb_forall in Hall.
  exact (Hall target Htarget).
Qed.

Lemma watsc_source_union_access_safe_sound :
  forall targets units function_id body target,
    watsc_source_units_covered targets units ->
    In (function_id, Gfun (Internal body))
      (unit_global_definitions units) ->
    In target targets ->
    wat_statement_access_safe_s target (fn_body body) = true.
Proof.
  intros targets units function_id body target Hcovered Hin Htarget.
  destruct (unit_global_definition_has_owner
    units function_id (Gfun (Internal body)) Hin)
    as [owner [Howner Hdefinition]].
  eapply watsc_program_access_safe_sound; eauto.
  eapply watsc_source_units_covered_member; eauto.
Qed.

(** Exact selected-source result: no linked internal body is omitted, because
    official-source provenance supplies the identical source definition and
    the structural certificate covers all 38 source units. *)
Theorem us_selected_source_internal_bodies_action_table_safe :
  forall function_id body target,
    In (function_id, Gfun (Internal body))
      (prog_defs us_official_cleaned_slice) ->
    In target watsc_us_table_ids ->
    wat_statement_access_safe_s target (fn_body body) = true.
Proof.
  intros function_id body target Hbody Htarget.
  eapply watsc_source_union_access_safe_sound.
  - exact watsc_us_source_units_covered.
  - exact (us_official_source_definition_provenance
      function_id (Gfun (Internal body)) Hbody).
  - exact Htarget.
Qed.

Theorem jp_selected_source_internal_bodies_action_table_safe :
  forall function_id body target,
    In (function_id, Gfun (Internal body))
      (prog_defs jp_official_cleaned_slice) ->
    In target watsc_jp_table_ids ->
    wat_statement_access_safe_s target (fn_body body) = true.
Proof.
  intros function_id body target Hbody Htarget.
  eapply watsc_source_union_access_safe_sound.
  - exact watsc_jp_source_units_covered.
  - exact (jp_official_source_definition_provenance
      function_id (Gfun (Internal body)) Hbody).
  - exact Htarget.
Qed.
