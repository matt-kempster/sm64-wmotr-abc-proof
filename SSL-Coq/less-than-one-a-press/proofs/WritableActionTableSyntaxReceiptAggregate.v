(** Structural aggregate of the cached per-unit syntax receipts.

    This proposition-valued certificate avoids reducing one enormous Boolean
    expression.  Each constructor stores exactly one already-kernel-checked
    translation-unit receipt, so interrupted builds retain all expensive work. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Linking.
From LessThanOneAPress.Proofs Require Import
  LinkedClightPrograms WritableActionTableSyntaxBase.
From LessThanOneAPress.Proofs.WritableActionTableSyntaxReceipts Require Import
  GameInit Mario MarioActionsAirborne MarioActionsAutomatic
  MarioActionsCutscene MarioActionsMoving MarioActionsObject
  MarioActionsStationary MarioActionsSubmerged MarioStep Interaction SaveFile
  ObjectCollision ObjectListProcessor BehaviorScript LevelScript GraphNode
  RenderingGraphNode SpawnObject ObjectHelpers Debug Memory MarioMisc
  ObjBehaviors ObjBehaviors2 BehaviorActions BehaviorData Area LevelUpdate
  PlatformDisplacement MathUtil SurfaceCollision SurfaceLoad
  MacroSpecialObjects SslScript SslArea1Macro SslArea2Macro SslCollision.

Inductive watsc_source_units_covered (targets : list ident) :
    nlist Clight.program -> Prop :=
| WatscSourceBase : forall unit,
    watsc_program_access_safe targets unit = true ->
    watsc_source_units_covered targets (nbase unit)
| WatscSourceCons : forall unit rest,
    watsc_program_access_safe targets unit = true ->
    watsc_source_units_covered targets rest ->
    watsc_source_units_covered targets (ncons unit rest).

Theorem watsc_us_source_units_covered :
  watsc_source_units_covered watsc_us_table_ids us_units.
Proof.
  unfold us_units.
  constructor; [exact (proj1 watsc_game_init_unit_receipt) |].
  constructor; [exact (proj1 watsc_mario_unit_receipt) |].
  constructor; [exact (proj1 watsc_mario_actions_airborne_unit_receipt) |].
  constructor; [exact (proj1 watsc_mario_actions_automatic_unit_receipt) |].
  constructor; [exact (proj1 watsc_mario_actions_cutscene_unit_receipt) |].
  constructor; [exact (proj1 watsc_mario_actions_moving_unit_receipt) |].
  constructor; [exact (proj1 watsc_mario_actions_object_unit_receipt) |].
  constructor; [exact (proj1 watsc_mario_actions_stationary_unit_receipt) |].
  constructor; [exact (proj1 watsc_mario_actions_submerged_unit_receipt) |].
  constructor; [exact (proj1 watsc_mario_step_unit_receipt) |].
  constructor; [exact (proj1 watsc_interaction_unit_receipt) |].
  constructor; [exact (proj1 watsc_save_file_unit_receipt) |].
  constructor; [exact (proj1 watsc_object_collision_unit_receipt) |].
  constructor; [exact (proj1 watsc_object_list_processor_unit_receipt) |].
  constructor; [exact (proj1 watsc_behavior_script_unit_receipt) |].
  constructor; [exact (proj1 watsc_level_script_unit_receipt) |].
  constructor; [exact (proj1 watsc_graph_node_unit_receipt) |].
  constructor; [exact (proj1 watsc_rendering_graph_node_unit_receipt) |].
  constructor; [exact (proj1 watsc_spawn_object_unit_receipt) |].
  constructor; [exact (proj1 watsc_object_helpers_unit_receipt) |].
  constructor; [exact (proj1 watsc_debug_unit_receipt) |].
  constructor; [exact (proj1 watsc_memory_unit_receipt) |].
  constructor; [exact (proj1 watsc_mario_misc_unit_receipt) |].
  constructor; [exact (proj1 watsc_obj_behaviors_unit_receipt) |].
  constructor; [exact (proj1 watsc_obj_behaviors_2_unit_receipt) |].
  constructor; [exact (proj1 watsc_behavior_actions_unit_receipt) |].
  constructor; [exact (proj1 watsc_behavior_data_unit_receipt) |].
  constructor; [exact (proj1 watsc_area_unit_receipt) |].
  constructor; [exact (proj1 watsc_level_update_unit_receipt) |].
  constructor; [exact (proj1 watsc_platform_displacement_unit_receipt) |].
  constructor; [exact (proj1 watsc_math_util_unit_receipt) |].
  constructor; [exact (proj1 watsc_surface_collision_unit_receipt) |].
  constructor; [exact (proj1 watsc_surface_load_unit_receipt) |].
  constructor; [exact (proj1 watsc_macro_special_objects_unit_receipt) |].
  constructor; [exact (proj1 watsc_ssl_script_unit_receipt) |].
  constructor; [exact (proj1 watsc_ssl_area1_macro_unit_receipt) |].
  constructor; [exact (proj1 watsc_ssl_area2_macro_unit_receipt) |].
  constructor. exact (proj1 watsc_ssl_collision_unit_receipt).
Qed.

Theorem watsc_jp_source_units_covered :
  watsc_source_units_covered watsc_jp_table_ids jp_units.
Proof.
  unfold jp_units.
  constructor; [exact (proj2 watsc_game_init_unit_receipt) |].
  constructor; [exact (proj2 watsc_mario_unit_receipt) |].
  constructor; [exact (proj2 watsc_mario_actions_airborne_unit_receipt) |].
  constructor; [exact (proj2 watsc_mario_actions_automatic_unit_receipt) |].
  constructor; [exact (proj2 watsc_mario_actions_cutscene_unit_receipt) |].
  constructor; [exact (proj2 watsc_mario_actions_moving_unit_receipt) |].
  constructor; [exact (proj2 watsc_mario_actions_object_unit_receipt) |].
  constructor; [exact (proj2 watsc_mario_actions_stationary_unit_receipt) |].
  constructor; [exact (proj2 watsc_mario_actions_submerged_unit_receipt) |].
  constructor; [exact (proj2 watsc_mario_step_unit_receipt) |].
  constructor; [exact (proj2 watsc_interaction_unit_receipt) |].
  constructor; [exact (proj2 watsc_save_file_unit_receipt) |].
  constructor; [exact (proj2 watsc_object_collision_unit_receipt) |].
  constructor; [exact (proj2 watsc_object_list_processor_unit_receipt) |].
  constructor; [exact (proj2 watsc_behavior_script_unit_receipt) |].
  constructor; [exact (proj2 watsc_level_script_unit_receipt) |].
  constructor; [exact (proj2 watsc_graph_node_unit_receipt) |].
  constructor; [exact (proj2 watsc_rendering_graph_node_unit_receipt) |].
  constructor; [exact (proj2 watsc_spawn_object_unit_receipt) |].
  constructor; [exact (proj2 watsc_object_helpers_unit_receipt) |].
  constructor; [exact (proj2 watsc_debug_unit_receipt) |].
  constructor; [exact (proj2 watsc_memory_unit_receipt) |].
  constructor; [exact (proj2 watsc_mario_misc_unit_receipt) |].
  constructor; [exact (proj2 watsc_obj_behaviors_unit_receipt) |].
  constructor; [exact (proj2 watsc_obj_behaviors_2_unit_receipt) |].
  constructor; [exact (proj2 watsc_behavior_actions_unit_receipt) |].
  constructor; [exact (proj2 watsc_behavior_data_unit_receipt) |].
  constructor; [exact (proj2 watsc_area_unit_receipt) |].
  constructor; [exact (proj2 watsc_level_update_unit_receipt) |].
  constructor; [exact (proj2 watsc_platform_displacement_unit_receipt) |].
  constructor; [exact (proj2 watsc_math_util_unit_receipt) |].
  constructor; [exact (proj2 watsc_surface_collision_unit_receipt) |].
  constructor; [exact (proj2 watsc_surface_load_unit_receipt) |].
  constructor; [exact (proj2 watsc_macro_special_objects_unit_receipt) |].
  constructor; [exact (proj2 watsc_ssl_script_unit_receipt) |].
  constructor; [exact (proj2 watsc_ssl_area1_macro_unit_receipt) |].
  constructor; [exact (proj2 watsc_ssl_area2_macro_unit_receipt) |].
  constructor. exact (proj2 watsc_ssl_collision_unit_receipt).
Qed.

Lemma watsc_source_units_covered_member :
  forall targets units unit,
    watsc_source_units_covered targets units ->
    nIn unit units ->
    watsc_program_access_safe targets unit = true.
Proof.
  intros targets units unit Hcovered Hin.
  induction Hcovered as [head Hhead | head rest Hhead Hrest IH].
  - cbn in Hin. subst unit. exact Hhead.
  - cbn in Hin. destruct Hin as [<- | Hin];
      [exact Hhead | exact (IH Hin)].
Qed.
