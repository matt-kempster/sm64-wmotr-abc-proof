From Coq Require Import List ZArith.
From compcert Require Import AST Clight Floats Integers.
From LessThanOneAPress.Generated Require Import
  us_game_init us_mario us_mario_actions_airborne us_mario_actions_automatic
  us_mario_actions_cutscene
  us_mario_actions_moving us_mario_actions_object us_mario_actions_stationary
  us_mario_actions_submerged us_mario_step us_interaction us_save_file us_object_collision
  us_object_list_processor us_behavior_script us_level_script us_graph_node
  us_rendering_graph_node
  us_spawn_object us_object_helpers us_debug us_memory us_mario_misc
  us_obj_behaviors
  us_obj_behaviors_2 us_behavior_actions us_behavior_data us_area
  us_level_update us_platform_displacement us_surface_collision us_surface_load
  us_macro_special_objects us_ssl_script
  us_ssl_area2_macro us_ssl_collision
  jp_game_init jp_mario jp_mario_actions_airborne jp_mario_actions_automatic
  jp_mario_actions_cutscene
  jp_mario_actions_moving jp_mario_actions_object jp_mario_actions_stationary
  jp_mario_actions_submerged jp_mario_step jp_interaction jp_save_file jp_object_collision
  jp_object_list_processor jp_behavior_script jp_level_script jp_graph_node
  jp_rendering_graph_node
  jp_spawn_object jp_object_helpers jp_debug jp_memory jp_mario_misc
  jp_obj_behaviors
  jp_obj_behaviors_2 jp_behavior_actions jp_behavior_data jp_area
  jp_level_update jp_platform_displacement jp_surface_collision jp_surface_load
  jp_macro_special_objects jp_ssl_script
  jp_ssl_area2_macro jp_ssl_collision.
From LessThanOneAPress.Proofs Require Import ASTFacts.

Import ListNotations.
Local Open Scope Z_scope.

Module UGI := us_game_init.
Module UMI := us_mario.
Module UAir := us_mario_actions_airborne.
Module UAuto := us_mario_actions_automatic.
Module UCutscene := us_mario_actions_cutscene.
Module UMove := us_mario_actions_moving.
Module UObjectActions := us_mario_actions_object.
Module UStationary := us_mario_actions_stationary.
Module USubmerged := us_mario_actions_submerged.
Module UStep := us_mario_step.
Module UI := us_interaction.
Module USF := us_save_file.
Module UOC := us_object_collision.
Module UOL := us_object_list_processor.
Module UBS := us_behavior_script.
Module ULS := us_level_script.
Module UGraph := us_graph_node.
Module URender := us_rendering_graph_node.
Module USO := us_spawn_object.
Module UOH := us_object_helpers.
Module UDebug := us_debug.
Module UMemory := us_memory.
Module UMisc := us_mario_misc.
Module UOB := us_obj_behaviors.
Module UEye := us_obj_behaviors_2.
Module UBA := us_behavior_actions.
Module UBD := us_behavior_data.
Module UAR := us_area.
Module ULU := us_level_update.
Module UPD := us_platform_displacement.
Module USurface := us_surface_collision.
Module USurfaceLoad := us_surface_load.
Module UMS := us_macro_special_objects.
Module USS := us_ssl_script.
Module UAM := us_ssl_area2_macro.
Module UCollision := us_ssl_collision.

Module JGI := jp_game_init.
Module JMI := jp_mario.
Module JAir := jp_mario_actions_airborne.
Module JAuto := jp_mario_actions_automatic.
Module JCutscene := jp_mario_actions_cutscene.
Module JMove := jp_mario_actions_moving.
Module JObjectActions := jp_mario_actions_object.
Module JStationary := jp_mario_actions_stationary.
Module JSubmerged := jp_mario_actions_submerged.
Module JStep := jp_mario_step.
Module JI := jp_interaction.
Module JSF := jp_save_file.
Module JOC := jp_object_collision.
Module JOL := jp_object_list_processor.
Module JBS := jp_behavior_script.
Module JLS := jp_level_script.
Module JGraph := jp_graph_node.
Module JRender := jp_rendering_graph_node.
Module JSO := jp_spawn_object.
Module JOH := jp_object_helpers.
Module JDebug := jp_debug.
Module JMemory := jp_memory.
Module JMisc := jp_mario_misc.
Module JOB := jp_obj_behaviors.
Module JEye := jp_obj_behaviors_2.
Module JBA := jp_behavior_actions.
Module JBD := jp_behavior_data.
Module JAR := jp_area.
Module JLU := jp_level_update.
Module JPD := jp_platform_displacement.
Module JSurface := jp_surface_collision.
Module JSurfaceLoad := jp_surface_load.
Module JMS := jp_macro_special_objects.
Module JSS := jp_ssl_script.
Module JAM := jp_ssl_area2_macro.
Module JCollision := jp_ssl_collision.

Theorem controller_pressed_operator_source_shape_us :
  assigns_pressed_operator_shape_s UGI._buttonPressed
    (fn_body UGI.f_read_controller_inputs) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem controller_pressed_operator_source_shape_jp :
  assigns_pressed_operator_shape_s JGI._buttonPressed
    (fn_body JGI.f_read_controller_inputs) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem mario_input_distinguishes_a_pressed_from_a_down_us :
  statement_mentions_ident_s UMI._buttonPressed
    (fn_body UMI.f_update_mario_button_inputs) = true /\
  statement_mentions_ident_s UMI._buttonDown
    (fn_body UMI.f_update_mario_button_inputs) = true /\
  statement_mentions_int_s 2 (fn_body UMI.f_update_mario_button_inputs) = true /\
  statement_mentions_int_s 128 (fn_body UMI.f_update_mario_button_inputs) = true.
Proof. vm_compute. repeat split. Qed.

Theorem mario_input_distinguishes_a_pressed_from_a_down_jp :
  statement_mentions_ident_s JMI._buttonPressed
    (fn_body JMI.f_update_mario_button_inputs) = true /\
  statement_mentions_ident_s JMI._buttonDown
    (fn_body JMI.f_update_mario_button_inputs) = true /\
  statement_mentions_int_s 2 (fn_body JMI.f_update_mario_button_inputs) = true /\
  statement_mentions_int_s 128 (fn_body JMI.f_update_mario_button_inputs) = true.
Proof. vm_compute. repeat split. Qed.

Theorem star_interaction_index_save_source_shape_us :
  statement_mentions_ident_s UI._rawData
    (fn_body UI.f_interact_star_or_key) = true /\
  statement_mentions_ident_s UI._asS32
    (fn_body UI.f_interact_star_or_key) = true /\
  statement_mentions_int_s 64 (fn_body UI.f_interact_star_or_key) = true /\
  statement_mentions_int_s 31 (fn_body UI.f_interact_star_or_key) = true /\
  calls_ident_s UI._save_file_collect_star_or_key
    (fn_body UI.f_interact_star_or_key) = true.
Proof. vm_compute. repeat split. Qed.

Theorem star_interaction_index_save_source_shape_jp :
  statement_mentions_ident_s JI._rawData
    (fn_body JI.f_interact_star_or_key) = true /\
  statement_mentions_ident_s JI._asS32
    (fn_body JI.f_interact_star_or_key) = true /\
  statement_mentions_int_s 64 (fn_body JI.f_interact_star_or_key) = true /\
  statement_mentions_int_s 31 (fn_body JI.f_interact_star_or_key) = true /\
  calls_ident_s JI._save_file_collect_star_or_key
    (fn_body JI.f_interact_star_or_key) = true.
Proof. vm_compute. repeat split. Qed.

Theorem save_collection_writer_call_source_shape_us :
  calls_ident_s USF._save_file_set_star_flags
    (fn_body USF.f_save_file_collect_star_or_key) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem save_collection_writer_call_source_shape_jp :
  calls_ident_s JSF._save_file_set_star_flags
    (fn_body JSF.f_save_file_collect_star_or_key) = true.
Proof. vm_compute. reflexivity. Qed.

(* A target-bit transition theorem must distinguish star collection from the
   game-over path that restores the active save slot from its backup.  These
   facts only establish that both operations occur in the generated syntax;
   their active/backup effect is modeled separately, while the Clight memory
   refinement remains pending. *)
Theorem game_over_save_reload_source_shape_us :
  calls_ident_s USF._bcopy (fn_body USF.f_save_file_reload) = true /\
  statement_mentions_ident_s USF._files
    (fn_body USF.f_save_file_reload) = true /\
  calls_ident_s ULU._save_file_reload
    (fn_body ULU.f_initiate_delayed_warp) = true.
Proof. vm_compute. repeat split. Qed.

Theorem game_over_save_reload_source_shape_jp :
  calls_ident_s JSF._bcopy (fn_body JSF.f_save_file_reload) = true /\
  statement_mentions_ident_s JSF._files
    (fn_body JSF.f_save_file_reload) = true /\
  calls_ident_s JLU._save_file_reload
    (fn_body JLU.f_initiate_delayed_warp) = true.
Proof. vm_compute. repeat split. Qed.

Definition act_spawn_no_spin_airborne_bits : Z := 6450.

(* Both SSL area-2 entry objects use [bhvAirborneWarp].  The level-script
   initializer facts below identify their positions; this check anchors the
   corresponding spawn type to the action selected by set_mario_initial_action.
   It remains a source-shape fact, not a proof that a run begins at that case. *)
Theorem airborne_entry_action_source_shape_us :
  calls_ident_s ULU._set_mario_action
    (fn_body ULU.f_set_mario_initial_action) = true /\
  statement_mentions_int_s act_spawn_no_spin_airborne_bits
    (fn_body ULU.f_set_mario_initial_action) = true.
Proof. vm_compute. split; reflexivity. Qed.

Theorem airborne_entry_action_source_shape_jp :
  calls_ident_s JLU._set_mario_action
    (fn_body JLU.f_set_mario_initial_action) = true /\
  statement_mentions_int_s act_spawn_no_spin_airborne_bits
    (fn_body JLU.f_set_mario_initial_action) = true.
Proof. vm_compute. split; reflexivity. Qed.

(* The selected entry action is dispatched in mario_actions_cutscene.c, not
   in the airborne-action unit.  Its helper is called with the exact binary32
   value 0.0f on every action update, and that helper writes forward velocity
   before calling perform_air_step.  These are syntax/dataflow anchors only;
   the small-step and collision-surface effects remain refinement obligations. *)
Theorem no_spin_airborne_entry_update_source_shape_us :
  calls_ident_with_float32_arg_s
    UCutscene._launch_mario_until_land 0
    (fn_body UCutscene.f_act_spawn_no_spin_airborne) = true /\
  calls_ident_s UCutscene._mario_set_forward_vel
    (fn_body UCutscene.f_launch_mario_until_land) = true /\
  calls_ident_s UCutscene._perform_air_step
    (fn_body UCutscene.f_launch_mario_until_land) = true.
Proof. vm_compute. repeat split. Qed.

Theorem no_spin_airborne_entry_update_source_shape_jp :
  calls_ident_with_float32_arg_s
    JCutscene._launch_mario_until_land 0
    (fn_body JCutscene.f_act_spawn_no_spin_airborne) = true /\
  calls_ident_s JCutscene._mario_set_forward_vel
    (fn_body JCutscene.f_launch_mario_until_land) = true /\
  calls_ident_s JCutscene._perform_air_step
    (fn_body JCutscene.f_launch_mario_until_land) = true.
Proof. vm_compute. repeat split. Qed.

Theorem hundred_coin_spawn_index_source_shape_us :
  calls_ident_s UI._bhv_spawn_star_no_level_exit
    (fn_body UI.f_interact_coin) = true /\
  statement_mentions_int_s 6 (fn_body UI.f_interact_coin) = true.
Proof. vm_compute. repeat split. Qed.

Theorem hundred_coin_spawn_index_source_shape_jp :
  calls_ident_s JI._bhv_spawn_star_no_level_exit
    (fn_body JI.f_interact_coin) = true /\
  statement_mentions_int_s 6 (fn_body JI.f_interact_coin) = true.
Proof. vm_compute. repeat split. Qed.

Theorem hidden_star_controller_five_spawn_source_shape_us :
  statement_mentions_ident_s UOB._rawData
    (fn_body UOB.f_bhv_hidden_star_loop) = true /\
  statement_mentions_ident_s UOB._asS32
    (fn_body UOB.f_bhv_hidden_star_loop) = true /\
  statement_mentions_int_s 27 (fn_body UOB.f_bhv_hidden_star_loop) = true /\
  statement_mentions_int_s 5 (fn_body UOB.f_bhv_hidden_star_loop) = true /\
  calls_ident_s UOB._spawn_red_coin_cutscene_star
    (fn_body UOB.f_bhv_hidden_star_loop) = true.
Proof. vm_compute. repeat split. Qed.

Theorem hidden_star_controller_five_spawn_source_shape_jp :
  statement_mentions_ident_s JOB._rawData
    (fn_body JOB.f_bhv_hidden_star_loop) = true /\
  statement_mentions_ident_s JOB._asS32
    (fn_body JOB.f_bhv_hidden_star_loop) = true /\
  statement_mentions_int_s 27 (fn_body JOB.f_bhv_hidden_star_loop) = true /\
  statement_mentions_int_s 5 (fn_body JOB.f_bhv_hidden_star_loop) = true /\
  calls_ident_s JOB._spawn_red_coin_cutscene_star
    (fn_body JOB.f_bhv_hidden_star_loop) = true.
Proof. vm_compute. repeat split. Qed.

Theorem hidden_trigger_collision_deactivate_source_shape_us :
  calls_ident_s UOB._obj_check_if_collided_with_object
    (fn_body UOB.f_bhv_hidden_star_trigger_loop) = true /\
  statement_mentions_int_s 27
    (fn_body UOB.f_bhv_hidden_star_trigger_loop) = true /\
  assigns_field_named_s UOB._activeFlags
    (fn_body UOB.f_bhv_hidden_star_trigger_loop) = true.
Proof. vm_compute. repeat split. Qed.

Theorem hidden_trigger_collision_deactivate_source_shape_jp :
  calls_ident_s JOB._obj_check_if_collided_with_object
    (fn_body JOB.f_bhv_hidden_star_trigger_loop) = true /\
  statement_mentions_int_s 27
    (fn_body JOB.f_bhv_hidden_star_trigger_loop) = true /\
  assigns_field_named_s JOB._activeFlags
    (fn_body JOB.f_bhv_hidden_star_trigger_loop) = true.
Proof. vm_compute. repeat split. Qed.

Theorem object_pool_allocation_assignment_source_shape_us :
  assigns_field_named_s USO._activeFlags (fn_body USO.f_allocate_object) = true /\
  assigns_field_named_s USO._respawnInfoType (fn_body USO.f_allocate_object) = true /\
  assigns_field_named_s USO._respawnInfo (fn_body USO.f_allocate_object) = true.
Proof. vm_compute. repeat split. Qed.

Theorem object_pool_allocation_assignment_source_shape_jp :
  assigns_field_named_s JSO._activeFlags (fn_body JSO.f_allocate_object) = true /\
  assigns_field_named_s JSO._respawnInfoType (fn_body JSO.f_allocate_object) = true /\
  assigns_field_named_s JSO._respawnInfo (fn_body JSO.f_allocate_object) = true.
Proof. vm_compute. repeat split. Qed.

Theorem macro_spawn_respawn_field_source_shape_us :
  calls_ident_s UMS._spawn_object_abs_with_rot
    (fn_body UMS.f_spawn_macro_objects) = true /\
  assigns_field_named_s UMS._respawnInfoType
    (fn_body UMS.f_spawn_macro_objects) = true /\
  assigns_field_named_s UMS._respawnInfo
    (fn_body UMS.f_spawn_macro_objects) = true.
Proof. vm_compute. repeat split. Qed.

Theorem macro_spawn_respawn_field_source_shape_jp :
  calls_ident_s JMS._spawn_object_abs_with_rot
    (fn_body JMS.f_spawn_macro_objects) = true /\
  assigns_field_named_s JMS._respawnInfoType
    (fn_body JMS.f_spawn_macro_objects) = true /\
  assigns_field_named_s JMS._respawnInfo
    (fn_body JMS.f_spawn_macro_objects) = true.
Proof. vm_compute. repeat split. Qed.

Theorem update_objects_direct_callee_order_us :
  ident_subsequenceb
    [UOL._clear_dynamic_surfaces;
     UOL._update_terrain_objects;
     UOL._apply_mario_platform_displacement;
     UOL._detect_object_collisions;
     UOL._update_non_terrain_objects;
     UOL._unload_deactivated_objects;
     UOL._update_mario_platform]
    (direct_callees_s (fn_body UOL.f_update_objects)) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem update_objects_direct_callee_order_jp :
  ident_subsequenceb
    [JOL._clear_dynamic_surfaces;
     JOL._update_terrain_objects;
     JOL._apply_mario_platform_displacement;
     JOL._detect_object_collisions;
     JOL._update_non_terrain_objects;
     JOL._unload_deactivated_objects;
     JOL._update_mario_platform]
    (direct_callees_s (fn_body JOL.f_update_objects)) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem player_collision_list_source_shape_us :
  statement_mentions_ident_s UOC._collidedObjs
    (fn_body UOC.f_detect_object_hitbox_overlap) = true /\
  assigns_field_named_s UOC._numCollidedObjs
    (fn_body UOC.f_detect_object_hitbox_overlap) = true.
Proof. vm_compute. repeat split. Qed.

Theorem player_collision_list_source_shape_jp :
  statement_mentions_ident_s JOC._collidedObjs
    (fn_body JOC.f_detect_object_hitbox_overlap) = true /\
  assigns_field_named_s JOC._numCollidedObjs
    (fn_body JOC.f_detect_object_hitbox_overlap) = true.
Proof. vm_compute. repeat split. Qed.

Theorem instant_warp_area_change_call_source_shape_us :
  calls_ident_s ULU._change_area (fn_body ULU.f_check_instant_warp) = true /\
  calls_ident_s UAR._unload_area (fn_body UAR.f_change_area) = true /\
  calls_ident_s UAR._load_area (fn_body UAR.f_change_area) = true.
Proof. vm_compute. repeat split. Qed.

Theorem instant_warp_area_change_call_source_shape_jp :
  calls_ident_s JLU._change_area (fn_body JLU.f_check_instant_warp) = true /\
  calls_ident_s JAR._unload_area (fn_body JAR.f_change_area) = true /\
  calls_ident_s JAR._load_area (fn_body JAR.f_change_area) = true.
Proof. vm_compute. repeat split. Qed.

Theorem spawning_clears_platform_us_but_not_jp :
  calls_ident_s UOL._clear_mario_platform
    (fn_body UOL.f_spawn_objects_from_info) = true /\
  calls_ident_s UOL._clear_mario_platform
    (fn_body JOL.f_spawn_objects_from_info) = false.
Proof. vm_compute. split; reflexivity. Qed.

(* Rechecked against the current pinned US and JP translations.  These facts
   are deliberately syntax-level: they identify the raw-pointer hazard but do
   not prove that any particular stale or reused slot is reachable. *)
Theorem platform_displacement_raw_pointer_source_shape_us :
  statement_mentions_ident_s UPD._gMarioPlatform
    (fn_body UPD.f_apply_mario_platform_displacement) = true /\
  calls_ident_s UPD._apply_platform_displacement
    (fn_body UPD.f_apply_mario_platform_displacement) = true /\
  statement_mentions_ident_s UPD._activeFlags
    (fn_body UPD.f_apply_mario_platform_displacement) = false /\
  statement_mentions_ident_s UPD._behavior
    (fn_body UPD.f_apply_mario_platform_displacement) = false /\
  statement_mentions_ident_s UPD._collisionData
    (fn_body UPD.f_apply_mario_platform_displacement) = false.
Proof. vm_compute. repeat split. Qed.

Theorem platform_displacement_raw_pointer_source_shape_jp :
  statement_mentions_ident_s JPD._gMarioPlatform
    (fn_body JPD.f_apply_mario_platform_displacement) = true /\
  calls_ident_s JPD._apply_platform_displacement
    (fn_body JPD.f_apply_mario_platform_displacement) = true /\
  statement_mentions_ident_s JPD._activeFlags
    (fn_body JPD.f_apply_mario_platform_displacement) = false /\
  statement_mentions_ident_s JPD._behavior
    (fn_body JPD.f_apply_mario_platform_displacement) = false /\
  statement_mentions_ident_s JPD._collisionData
    (fn_body JPD.f_apply_mario_platform_displacement) = false.
Proof. vm_compute. repeat split. Qed.

Theorem platform_recompute_source_shape_us :
  calls_ident_s UPD._find_floor
    (fn_body UPD.f_update_mario_platform) = true /\
  statement_mentions_ident_s UPD._object
    (fn_body UPD.f_update_mario_platform) = true /\
  assigns_global_ident_s UPD._gMarioPlatform
    (fn_body UPD.f_update_mario_platform) = true.
Proof. vm_compute. repeat split. Qed.

Theorem platform_recompute_source_shape_jp :
  calls_ident_s JPD._find_floor
    (fn_body JPD.f_update_mario_platform) = true /\
  statement_mentions_ident_s JPD._object
    (fn_body JPD.f_update_mario_platform) = true /\
  assigns_global_ident_s JPD._gMarioPlatform
    (fn_body JPD.f_update_mario_platform) = true.
Proof. vm_compute. repeat split. Qed.

(** The post-Mario lifecycle window matters for Ink's candidate.  The receipts
    below check the following generated-Clight syntax:

    - the straight-line sequence spine of [update_objects] places the remaining
      non-terrain update before deactivated-object unloading and the final
      platform recomputation;
    - [bhv_pyramid_top_explode] assigns literal zero to [activeFlags];
    - state 2 of [bhv_pyramid_top_loop] contains the explode call, while the
      behavior initializer places the loop callback before the collision
      loader callback;
    - the unload scan reads [activeFlags] and calls [unload_object], which again
      assigns literal zero and calls [deallocate_object] with
      [gFreeObjectList]; and
    - [update_mario_platform] calls [find_floor], loads the [Surface.object]
      field, and never mentions [activeFlags].

    The switch-case and initializer facts are only branch/script syntax.  Even
    the straight-line call spine is not a Clight execution theorem: these facts
    do not prove that state 2 is reached, that the behavior interpreter
    executes both callbacks, that a particular surface survives unloading, or
    that the final query takes its [floor->object] branch. *)
Definition ink_post_copy_lifecycle_source_shape_us_claim : Prop :=
  ident_subsequenceb
    [UOL._update_non_terrain_objects;
     UOL._unload_deactivated_objects;
     UOL._update_mario_platform]
    (straightline_callees_s (fn_body UOL.f_update_objects)) = true /\
  assigns_field_int_constant_s UOB._activeFlags 0
    (fn_body UOB.f_bhv_pyramid_top_explode) = true /\
  switch_case_calls_ident_s 2 UOB._bhv_pyramid_top_explode
    (fn_body UOB.f_bhv_pyramid_top_loop) = true /\
  initializer_addrof_subsequenceb
    [UBD._bhv_pyramid_top_loop; UBD._load_object_collision_model]
    (gvar_init UBD.v_bhvPyramidTop) = true /\
  statement_mentions_ident_s UOL._activeFlags
    (fn_body UOL.f_unload_deactivated_objects_in_list) = true /\
  calls_ident_s UOL._unload_object
    (fn_body UOL.f_unload_deactivated_objects_in_list) = true /\
  assigns_field_int_constant_s USO._activeFlags 0
    (fn_body USO.f_unload_object) = true /\
  calls_ident_with_argument_ident_s
    USO._deallocate_object USO._gFreeObjectList
    (fn_body USO.f_unload_object) = true /\
  assigns_field_named_s USO._next
    (fn_body USO.f_deallocate_object) = true /\
  calls_ident_s UPD._find_floor
    (fn_body UPD.f_update_mario_platform) = true /\
  sets_temp_from_struct_field_s UPD._Surface UPD._object
    (fn_body UPD.f_update_mario_platform) = true /\
  statement_mentions_ident_s UPD._activeFlags
    (fn_body UPD.f_update_mario_platform) = false.

Theorem ink_post_copy_lifecycle_source_shape_us :
  ink_post_copy_lifecycle_source_shape_us_claim.
Proof. vm_compute. repeat split. Qed.

Definition ink_post_copy_lifecycle_source_shape_jp_claim : Prop :=
  ident_subsequenceb
    [JOL._update_non_terrain_objects;
     JOL._unload_deactivated_objects;
     JOL._update_mario_platform]
    (straightline_callees_s (fn_body JOL.f_update_objects)) = true /\
  assigns_field_int_constant_s JOB._activeFlags 0
    (fn_body JOB.f_bhv_pyramid_top_explode) = true /\
  switch_case_calls_ident_s 2 JOB._bhv_pyramid_top_explode
    (fn_body JOB.f_bhv_pyramid_top_loop) = true /\
  initializer_addrof_subsequenceb
    [JBD._bhv_pyramid_top_loop; JBD._load_object_collision_model]
    (gvar_init JBD.v_bhvPyramidTop) = true /\
  statement_mentions_ident_s JOL._activeFlags
    (fn_body JOL.f_unload_deactivated_objects_in_list) = true /\
  calls_ident_s JOL._unload_object
    (fn_body JOL.f_unload_deactivated_objects_in_list) = true /\
  assigns_field_int_constant_s JSO._activeFlags 0
    (fn_body JSO.f_unload_object) = true /\
  calls_ident_with_argument_ident_s
    JSO._deallocate_object JSO._gFreeObjectList
    (fn_body JSO.f_unload_object) = true /\
  assigns_field_named_s JSO._next
    (fn_body JSO.f_deallocate_object) = true /\
  calls_ident_s JPD._find_floor
    (fn_body JPD.f_update_mario_platform) = true /\
  sets_temp_from_struct_field_s JPD._Surface JPD._object
    (fn_body JPD.f_update_mario_platform) = true /\
  statement_mentions_ident_s JPD._activeFlags
    (fn_body JPD.f_update_mario_platform) = false.

Theorem ink_post_copy_lifecycle_source_shape_jp :
  ink_post_copy_lifecycle_source_shape_jp_claim.
Proof. vm_compute. repeat split. Qed.

(* [find_floor] narrows all three binary32 inputs through signed 16-bit
   TerrainData temporaries.  The generated syntax records the source cast; a
   separate compiled-cast refinement is still required for out-of-range C
   inputs. *)
Theorem find_floor_s16_coordinate_cast_source_shape_us :
  sets_temp_from_float_cast_to_s16_s USurface._x USurface._xPos
    (fn_body USurface.f_find_floor) = true /\
  sets_temp_from_float_cast_to_s16_s USurface._y USurface._yPos
    (fn_body USurface.f_find_floor) = true /\
  sets_temp_from_float_cast_to_s16_s USurface._z USurface._zPos
    (fn_body USurface.f_find_floor) = true.
Proof. vm_compute. repeat split. Qed.

Theorem find_floor_s16_coordinate_cast_source_shape_jp :
  sets_temp_from_float_cast_to_s16_s JSurface._x JSurface._xPos
    (fn_body JSurface.f_find_floor) = true /\
  sets_temp_from_float_cast_to_s16_s JSurface._y JSurface._yPos
    (fn_body JSurface.f_find_floor) = true /\
  sets_temp_from_float_cast_to_s16_s JSurface._z JSurface._zPos
    (fn_body JSurface.f_find_floor) = true.
Proof. vm_compute. repeat split. Qed.

(* Platform displacement mutates MarioState first.  The immediately following
   object-collision pass still reads the Mario object, and the player behavior
   copies the state position to that object only later.  These are syntax and
   call-order facts; the corresponding Clight memory-execution theorem remains
   a named refinement obligation. *)
Theorem mario_state_object_phase_split_source_shape_us :
  calls_ident_s UPD._get_mario_pos
    (fn_body UPD.f_apply_platform_displacement) = true /\
  calls_ident_s UPD._set_mario_pos
    (fn_body UPD.f_apply_platform_displacement) = true /\
  assigns_array_slot_s UPD._pos 0 (fn_body UPD.f_set_mario_pos) = true /\
  assigns_array_slot_s UPD._pos 1 (fn_body UPD.f_set_mario_pos) = true /\
  assigns_array_slot_s UPD._pos 2 (fn_body UPD.f_set_mario_pos) = true /\
  statement_mentions_ident_s UPD._gMarioObject
    (fn_body UPD.f_set_mario_pos) = false /\
  statement_mentions_array_slot_s UOC._asF32 6
    (fn_body UOC.f_detect_object_hitbox_overlap) = true /\
  statement_mentions_array_slot_s UOC._asF32 7
    (fn_body UOC.f_detect_object_hitbox_overlap) = true /\
  statement_mentions_array_slot_s UOC._asF32 8
    (fn_body UOC.f_detect_object_hitbox_overlap) = true /\
  ident_subsequenceb
    [UOL._execute_mario_action; UOL._copy_mario_state_to_object]
    (direct_callees_s (fn_body UOL.f_bhv_mario_update)) = true /\
  assigns_array_slot_s UOL._asF32 6
    (fn_body UOL.f_copy_mario_state_to_object) = true /\
  assigns_array_slot_s UOL._asF32 7
    (fn_body UOL.f_copy_mario_state_to_object) = true /\
  assigns_array_slot_s UOL._asF32 8
    (fn_body UOL.f_copy_mario_state_to_object) = true /\
  statement_mentions_array_slot_s UPD._asF32 6
    (fn_body UPD.f_update_mario_platform) = true /\
  statement_mentions_array_slot_s UPD._asF32 7
    (fn_body UPD.f_update_mario_platform) = true /\
  statement_mentions_array_slot_s UPD._asF32 8
    (fn_body UPD.f_update_mario_platform) = true.
Proof. vm_compute. repeat split. Qed.

Theorem mario_state_object_phase_split_source_shape_jp :
  calls_ident_s JPD._get_mario_pos
    (fn_body JPD.f_apply_platform_displacement) = true /\
  calls_ident_s JPD._set_mario_pos
    (fn_body JPD.f_apply_platform_displacement) = true /\
  assigns_array_slot_s JPD._pos 0 (fn_body JPD.f_set_mario_pos) = true /\
  assigns_array_slot_s JPD._pos 1 (fn_body JPD.f_set_mario_pos) = true /\
  assigns_array_slot_s JPD._pos 2 (fn_body JPD.f_set_mario_pos) = true /\
  statement_mentions_ident_s JPD._gMarioObject
    (fn_body JPD.f_set_mario_pos) = false /\
  statement_mentions_array_slot_s JOC._asF32 6
    (fn_body JOC.f_detect_object_hitbox_overlap) = true /\
  statement_mentions_array_slot_s JOC._asF32 7
    (fn_body JOC.f_detect_object_hitbox_overlap) = true /\
  statement_mentions_array_slot_s JOC._asF32 8
    (fn_body JOC.f_detect_object_hitbox_overlap) = true /\
  ident_subsequenceb
    [JOL._execute_mario_action; JOL._copy_mario_state_to_object]
    (direct_callees_s (fn_body JOL.f_bhv_mario_update)) = true /\
  assigns_array_slot_s JOL._asF32 6
    (fn_body JOL.f_copy_mario_state_to_object) = true /\
  assigns_array_slot_s JOL._asF32 7
    (fn_body JOL.f_copy_mario_state_to_object) = true /\
  assigns_array_slot_s JOL._asF32 8
    (fn_body JOL.f_copy_mario_state_to_object) = true /\
  statement_mentions_array_slot_s JPD._asF32 6
    (fn_body JPD.f_update_mario_platform) = true /\
  statement_mentions_array_slot_s JPD._asF32 7
    (fn_body JPD.f_update_mario_platform) = true /\
  statement_mentions_array_slot_s JPD._asF32 8
    (fn_body JPD.f_update_mario_platform) = true.
Proof. vm_compute. repeat split. Qed.

(* The OOB branch in [update_mario_geometry_inputs] is deliberately checked
   as an ordered call trace: two State wall queries, a first floor query, a
   graphical-position copy into State, and a retry.  These are syntactic AST
   receipts.  They do not prove that either floor query returns a particular
   live surface or that the branch is reachable. *)
Definition graphical_floor_fallback_source_shape_us_claim : Prop :=
  contains_guarded_graphics_floor_retry_s
    UMI._floor UMI._marioObj UMI._header UMI._vec3f_copy UMI._find_floor
    UMI._gfx UMI._pos UMI._floorHeight
    (fn_body UMI.f_update_mario_geometry_inputs) = true /\
  ident_subsequenceb
    [UMI._f32_find_wall_collision;
     UMI._f32_find_wall_collision;
     UMI._find_floor;
     UMI._vec3f_copy;
     UMI._find_floor]
    (direct_callees_s (fn_body UMI.f_update_mario_geometry_inputs)) = true /\
  statement_mentions_ident_s UMI._marioObj
    (fn_body UMI.f_update_mario_geometry_inputs) = true /\
  statement_mentions_ident_s UMI._gfx
    (fn_body UMI.f_update_mario_geometry_inputs) = true /\
  statement_mentions_ident_s UMI._pos
    (fn_body UMI.f_update_mario_geometry_inputs) = true.

Theorem graphical_floor_fallback_source_shape_us :
  graphical_floor_fallback_source_shape_us_claim.
Proof.
  unfold graphical_floor_fallback_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition graphical_floor_fallback_source_shape_jp_claim : Prop :=
  contains_guarded_graphics_floor_retry_s
    JMI._floor JMI._marioObj JMI._header JMI._vec3f_copy JMI._find_floor
    JMI._gfx JMI._pos JMI._floorHeight
    (fn_body JMI.f_update_mario_geometry_inputs) = true /\
  ident_subsequenceb
    [JMI._f32_find_wall_collision;
     JMI._f32_find_wall_collision;
     JMI._find_floor;
     JMI._vec3f_copy;
     JMI._find_floor]
    (direct_callees_s (fn_body JMI.f_update_mario_geometry_inputs)) = true /\
  statement_mentions_ident_s JMI._marioObj
    (fn_body JMI.f_update_mario_geometry_inputs) = true /\
  statement_mentions_ident_s JMI._gfx
    (fn_body JMI.f_update_mario_geometry_inputs) = true /\
  statement_mentions_ident_s JMI._pos
    (fn_body JMI.f_update_mario_geometry_inputs) = true.

Theorem graphical_floor_fallback_source_shape_jp :
  graphical_floor_fallback_source_shape_jp_claim.
Proof.
  unfold graphical_floor_fallback_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** The shell interaction itself changes action/ownership state.  In the air
    action, [perform_air_step] occurs lexically before the direct +42 graphical
    Y write.  In the ground action, [perform_ground_step] precedes the call to
    [tilt_body_ground_shell], whose body contains the direct +45 write.
    These receipts pin those call/literal relationships in US and JP.  They
    are syntax anchors, not a proof that both syntax nodes execute on one path,
    that either action is reachable from a clean SSL Area-1 entry, or that
    graphical displacement accumulates across frames. *)
Definition float32_forty_two_bits : Z := 1109917696.
Definition float32_forty_five_bits : Z := 1110704128.

Definition shell_graphics_y_offsets_source_shape_us_claim : Prop :=
  call_precedes_float32_literal_s
    UAir._perform_air_step float32_forty_two_bits
    (fn_body UAir.f_act_riding_shell_air) = true /\
  ident_subsequenceb
    [UMove._perform_ground_step; UMove._tilt_body_ground_shell]
    (direct_callees_s (fn_body UMove.f_act_riding_shell_ground)) = true /\
  statement_mentions_float32_bits_s float32_forty_five_bits
    (fn_body UMove.f_tilt_body_ground_shell) = true.

Theorem shell_graphics_y_offsets_source_shape_us :
  shell_graphics_y_offsets_source_shape_us_claim.
Proof.
  unfold shell_graphics_y_offsets_source_shape_us_claim,
    float32_forty_two_bits, float32_forty_five_bits.
  vm_compute. repeat split.
Qed.

Definition shell_graphics_y_offsets_source_shape_jp_claim : Prop :=
  call_precedes_float32_literal_s
    JAir._perform_air_step float32_forty_two_bits
    (fn_body JAir.f_act_riding_shell_air) = true /\
  ident_subsequenceb
    [JMove._perform_ground_step; JMove._tilt_body_ground_shell]
    (direct_callees_s (fn_body JMove.f_act_riding_shell_ground)) = true /\
  statement_mentions_float32_bits_s float32_forty_five_bits
    (fn_body JMove.f_tilt_body_ground_shell) = true.

Theorem shell_graphics_y_offsets_source_shape_jp :
  shell_graphics_y_offsets_source_shape_jp_claim.
Proof.
  unfold shell_graphics_y_offsets_source_shape_jp_claim,
    float32_forty_two_bits, float32_forty_five_bits.
  vm_compute. repeat split.
Qed.

(** The moving-action dispatcher calls [mario_update_quicksand] before its
    riding-shell-ground case.  The callee tests action-flag bit 16 and contains
    the exact binary32-zero assignment to [quicksandDepth].  This rules out a
    source-level attempt to combine the ground-shell [+45] with a retained
    negative quicksand depth on the same normal dispatch path.  It remains a
    syntax/order receipt: live action selection, memory aliasing, and the
    corresponding end-to-end Clight execution are separate obligations. *)
Definition shell_ground_quicksand_reset_source_shape_us_claim : Prop :=
  statement_mentions_int_s 16
    (fn_body UStep.f_mario_update_quicksand) = true /\
  assigns_field_float32_constant_s UStep._quicksandDepth 0
    (fn_body UStep.f_mario_update_quicksand) = true /\
  ident_subsequenceb
    [UMove._mario_update_quicksand; UMove._act_riding_shell_ground]
    (direct_callees_s (fn_body UMove.f_mario_execute_moving_action)) = true.

Theorem shell_ground_quicksand_reset_source_shape_us :
  shell_ground_quicksand_reset_source_shape_us_claim.
Proof.
  unfold shell_ground_quicksand_reset_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition shell_ground_quicksand_reset_source_shape_jp_claim : Prop :=
  statement_mentions_int_s 16
    (fn_body JStep.f_mario_update_quicksand) = true /\
  assigns_field_float32_constant_s JStep._quicksandDepth 0
    (fn_body JStep.f_mario_update_quicksand) = true /\
  ident_subsequenceb
    [JMove._mario_update_quicksand; JMove._act_riding_shell_ground]
    (direct_callees_s (fn_body JMove.f_mario_execute_moving_action)) = true.

Theorem shell_ground_quicksand_reset_source_shape_jp :
  shell_ground_quicksand_reset_source_shape_jp_claim.
Proof.
  unfold shell_ground_quicksand_reset_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** The airborne dispatcher has a parallel, simpler reset.  Its common-cancel
    helper writes binary32 zero to [quicksandDepth] on the non-cancel path
    before the switch can call [act_riding_shell_air].  Thus the normal
    shell-air [+42] path cannot amplify a negative retained depth in the final
    [sink_mario_in_quicksand] call.  As above, this is a generated-AST
    syntax/order receipt, not yet a linked path-execution theorem. *)
Definition shell_air_quicksand_reset_source_shape_us_claim : Prop :=
  assigns_field_float32_constant_s UAir._quicksandDepth 0
    (fn_body UAir.f_check_common_airborne_cancels) = true /\
  ident_subsequenceb
    [UAir._check_common_airborne_cancels; UAir._act_riding_shell_air]
    (direct_callees_s (fn_body UAir.f_mario_execute_airborne_action)) = true.

Theorem shell_air_quicksand_reset_source_shape_us :
  shell_air_quicksand_reset_source_shape_us_claim.
Proof.
  unfold shell_air_quicksand_reset_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition shell_air_quicksand_reset_source_shape_jp_claim : Prop :=
  assigns_field_float32_constant_s JAir._quicksandDepth 0
    (fn_body JAir.f_check_common_airborne_cancels) = true /\
  ident_subsequenceb
    [JAir._check_common_airborne_cancels; JAir._act_riding_shell_air]
    (direct_callees_s (fn_body JAir.f_mario_execute_airborne_action)) = true.

Theorem shell_air_quicksand_reset_source_shape_jp :
  shell_air_quicksand_reset_source_shape_jp_claim.
Proof.
  unfold shell_air_quicksand_reset_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** The generated interaction table orders the warp handler before the Koopa
    shell handler.  Together with the source loop's break-on-true behavior,
    this means a successful nonfading warp interaction preempts a simultaneous
    shell interaction.  The initializer-order and named-body receipts below
    are kernel checks; indirect-call execution and the break/dataflow link
    remain a Clight refinement obligation. *)
Definition warp_precedes_shell_interaction_source_shape_us_claim : Prop :=
  initializer_addrof_subsequenceb
    [UI._interact_warp; UI._interact_koopa_shell]
    UI.v_sInteractionHandlers.(gvar_init) = true /\
  calls_ident_s UI._set_mario_action
    (fn_body UI.f_interact_warp) = true /\
  statement_mentions_ident_s UI._sInteractionHandlers
    (fn_body UI.f_mario_process_interactions) = true.

Theorem warp_precedes_shell_interaction_source_shape_us :
  warp_precedes_shell_interaction_source_shape_us_claim.
Proof.
  unfold warp_precedes_shell_interaction_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition warp_precedes_shell_interaction_source_shape_jp_claim : Prop :=
  initializer_addrof_subsequenceb
    [JI._interact_warp; JI._interact_koopa_shell]
    JI.v_sInteractionHandlers.(gvar_init) = true /\
  calls_ident_s JI._set_mario_action
    (fn_body JI.f_interact_warp) = true /\
  statement_mentions_ident_s JI._sInteractionHandlers
    (fn_body JI.f_mario_process_interactions) = true.

Theorem warp_precedes_shell_interaction_source_shape_jp :
  warp_precedes_shell_interaction_source_shape_jp_claim.
Proof.
  unfold warp_precedes_shell_interaction_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** The retry is not a harmless optional branch.  If the copied graphical
    position also has no floor, the generated function calls
    [level_trigger_warp(m, WARP_OP_DEATH)] in the false branch of the
    source-identified final floor-pointer test.  [level_trigger_warp] itself is
    a first-writer latch:
    every direct AST assignment to [sDelayedWarpOp] in this body is inside the
    zero-guarded branch, and that branch contains the direct assignment from
    the [warpOp] parameter.  This syntactic fact does not exclude alias or
    callee effects.
    The final conjunct records lexical call order from the generated AST; it
    does not prove that both calls execute on one concrete path.

    These are pinned structural anchors, not yet a small-step proof that a
    concrete retry returns null, that the delayed-warp cell initially contains
    zero, or that the retail scheduler either preserves a fatal request until
    the later object-warp request or destroys that continuation across any
    earlier clear/reset interval.  In the zero-lives case
    [level_trigger_warp] rewrites death to game-over; either value is nonzero
    and would block a later request while still pending. *)
Definition ink_retry_null_death_preemption_source_shape_us_claim : Prop :=
  contains_guarded_floor_null_else_call_s
    UMI._m UMI._floor UMI._level_trigger_warp 18
    (fn_body UMI.f_update_mario_geometry_inputs) = true /\
  is_guarded_first_writer_warp_latch_s
    ULU._sDelayedWarpOp ULU._warpOp
    (fn_body ULU.f_level_trigger_warp) = true /\
  ident_subsequenceb
    [UMI._update_mario_inputs; UMI._mario_process_interactions]
    (direct_callees_s (fn_body UMI.f_execute_mario_action)) = true.

Theorem ink_retry_null_death_preemption_source_shape_us :
  ink_retry_null_death_preemption_source_shape_us_claim.
Proof.
  unfold ink_retry_null_death_preemption_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition ink_retry_null_death_preemption_source_shape_jp_claim : Prop :=
  contains_guarded_floor_null_else_call_s
    JMI._m JMI._floor JMI._level_trigger_warp 18
    (fn_body JMI.f_update_mario_geometry_inputs) = true /\
  is_guarded_first_writer_warp_latch_s
    JLU._sDelayedWarpOp JLU._warpOp
    (fn_body JLU.f_level_trigger_warp) = true /\
  ident_subsequenceb
    [JMI._update_mario_inputs; JMI._mario_process_interactions]
    (direct_callees_s (fn_body JMI.f_execute_mario_action)) = true.

Theorem ink_retry_null_death_preemption_source_shape_jp :
  ink_retry_null_death_preemption_source_shape_jp_claim.
Proof.
  unfold ink_retry_null_death_preemption_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(* Entry initialization has source-level writes that synchronize MarioState,
   raw MarioObject coordinates, and graphical coordinates.  The recognizer
   below checks the relevant calls and raw float slots, but remains
   base/path-insensitive and is not a Clight memory-state equality proof. *)
Definition mario_entry_coordinate_sync_source_shape_us_claim : Prop :=
  ident_subsequenceb
    [UMI._vec3s_to_vec3f; UMI._find_floor;
     UMI._mario_reset_bodystate; UMI._update_mario_info_for_cam;
     UMI._vec3f_copy]
    (direct_callees_s (fn_body UMI.f_init_mario)) = true /\
  assigns_array_slot_s UMI._asF32 6 (fn_body UMI.f_init_mario) = true /\
  assigns_array_slot_s UMI._asF32 7 (fn_body UMI.f_init_mario) = true /\
  assigns_array_slot_s UMI._asF32 8 (fn_body UMI.f_init_mario) = true /\
  statement_mentions_ident_s UMI._gfx (fn_body UMI.f_init_mario) = true /\
  statement_mentions_ident_s UMI._pos (fn_body UMI.f_init_mario) = true.

Theorem mario_entry_coordinate_sync_source_shape_us :
  mario_entry_coordinate_sync_source_shape_us_claim.
Proof.
  unfold mario_entry_coordinate_sync_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition mario_entry_coordinate_sync_source_shape_jp_claim : Prop :=
  ident_subsequenceb
    [JMI._vec3s_to_vec3f; JMI._find_floor;
     JMI._mario_reset_bodystate; JMI._update_mario_info_for_cam;
     JMI._vec3f_copy]
    (direct_callees_s (fn_body JMI.f_init_mario)) = true /\
  assigns_array_slot_s JMI._asF32 6 (fn_body JMI.f_init_mario) = true /\
  assigns_array_slot_s JMI._asF32 7 (fn_body JMI.f_init_mario) = true /\
  assigns_array_slot_s JMI._asF32 8 (fn_body JMI.f_init_mario) = true /\
  statement_mentions_ident_s JMI._gfx (fn_body JMI.f_init_mario) = true /\
  statement_mentions_ident_s JMI._pos (fn_body JMI.f_init_mario) = true.

Theorem mario_entry_coordinate_sync_source_shape_jp :
  mario_entry_coordinate_sync_source_shape_jp_claim.
Proof.
  unfold mario_entry_coordinate_sync_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(* Direct inspection of the pinned C source gives the warp/top phase account:
   geometry is recomputed from displaced MarioState before interaction, a
   normal warp selects ACT_DISAPPEARED, that action snaps State Y to cached
   floor, and State is later copied to Object.  Remaining lists and unload
   separate that copy from the final platform query; the separate
   [ink_post_copy_lifecycle_source_shape_us/jp] receipt checks those anchors.
   The theorem below checks only path- and base-insensitive AST anchors for the
   earlier account; it is not a Clight memory/dataflow execution theorem. *)
Theorem upper_warp_phase_pipeline_source_shape_us :
  ident_subsequenceb
    [UMI._update_mario_inputs;
     UMI._mario_process_interactions;
     UMI._mario_execute_cutscene_action]
    (direct_callees_s (fn_body UMI.f_execute_mario_action)) = true /\
  calls_ident_s UMI._update_mario_geometry_inputs
    (fn_body UMI.f_update_mario_inputs) = true /\
  calls_ident_s UMI._find_floor
    (fn_body UMI.f_update_mario_geometry_inputs) = true /\
  statement_mentions_int_s 4864 (fn_body UI.f_interact_warp) = true /\
  ident_subsequenceb
    [UCutscene._stop_and_set_height_to_floor;
     UCutscene._level_trigger_warp]
    (direct_callees_s (fn_body UCutscene.f_act_disappeared)) = true /\
  assigns_array_slot_s UStep._pos 1
    (fn_body UStep.f_stop_and_set_height_to_floor) = true /\
  statement_mentions_ident_s UStep._floorHeight
    (fn_body UStep.f_stop_and_set_height_to_floor) = true.
Proof. vm_compute. repeat split. Qed.

Theorem upper_warp_phase_pipeline_source_shape_jp :
  ident_subsequenceb
    [JMI._update_mario_inputs;
     JMI._mario_process_interactions;
     JMI._mario_execute_cutscene_action]
    (direct_callees_s (fn_body JMI.f_execute_mario_action)) = true /\
  calls_ident_s JMI._update_mario_geometry_inputs
    (fn_body JMI.f_update_mario_inputs) = true /\
  calls_ident_s JMI._find_floor
    (fn_body JMI.f_update_mario_geometry_inputs) = true /\
  statement_mentions_int_s 4864 (fn_body JI.f_interact_warp) = true /\
  ident_subsequenceb
    [JCutscene._stop_and_set_height_to_floor;
     JCutscene._level_trigger_warp]
    (direct_callees_s (fn_body JCutscene.f_act_disappeared)) = true /\
  assigns_array_slot_s JStep._pos 1
    (fn_body JStep.f_stop_and_set_height_to_floor) = true /\
  statement_mentions_ident_s JStep._floorHeight
    (fn_body JStep.f_stop_and_set_height_to_floor) = true.
Proof. vm_compute. repeat split. Qed.

(* Direct inspection of the pinned C source shows that the object warp is
   delayed: object updates precede each normal-play timer decrement, two
   change-area frames omit object updates, and the next normal frame runs
   [warp_area] before its object update.  The theorem below checks only generic
   direct-callee and literal anchors plus the absence of a direct
   [sDelayedWarpOp] assignment in [initiate_delayed_warp]; it does not exclude
   writes through callees, associate node 0x1E with a particular branch, or
   prove that timing in Clight. *)
Theorem object_warp_delayed_lifetime_source_shape_us :
  ident_subsequenceb
    [ULU._warp_area; ULU._area_update_objects; ULU._initiate_delayed_warp]
    (direct_callees_s (fn_body ULU.f_play_mode_normal)) = true /\
  statement_mentions_int_s 20 (fn_body ULU.f_level_trigger_warp) = true /\
  calls_ident_s ULU._level_set_transition
    (fn_body ULU.f_initiate_delayed_warp) = true /\
  statement_mentions_int_s 2
    (fn_body ULU.f_initiate_delayed_warp) = true /\
  statement_assigns_ident_s ULU._sDelayedWarpOp
    (fn_body ULU.f_initiate_delayed_warp) = false.
Proof. vm_compute. repeat split. Qed.

Theorem object_warp_delayed_lifetime_source_shape_jp :
  ident_subsequenceb
    [JLU._warp_area; JLU._area_update_objects; JLU._initiate_delayed_warp]
    (direct_callees_s (fn_body JLU.f_play_mode_normal)) = true /\
  statement_mentions_int_s 20 (fn_body JLU.f_level_trigger_warp) = true /\
  calls_ident_s JLU._level_set_transition
    (fn_body JLU.f_initiate_delayed_warp) = true /\
  statement_mentions_int_s 2
    (fn_body JLU.f_initiate_delayed_warp) = true /\
  statement_assigns_ident_s JLU._sDelayedWarpOp
    (fn_body JLU.f_initiate_delayed_warp) = false.
Proof. vm_compute. repeat split. Qed.

(** Exhaustive direct-writer and explicit-address-taking census for the
    delayed-warp latch in the generated [level_update.c] translation unit.
    The only direct writers are the two destination initializers, the guarded
    request function, and the two level/save initializers.  No generated
    internal function in this unit contains an explicit address-of expression
    for the latch.  This is not a whole-program alias or memory-safety result. *)
Definition delayed_warp_assignment_sites_us : list ident :=
  [ULU._init_mario_after_warp;
   ULU._warp_credits;
   ULU._level_trigger_warp;
   ULU._init_level;
   ULU._lvl_init_from_save_file].

Definition delayed_warp_assignment_sites_jp : list ident :=
  [JLU._init_mario_after_warp;
   JLU._warp_credits;
   JLU._level_trigger_warp;
   JLU._init_level;
   JLU._lvl_init_from_save_file].

Theorem delayed_warp_assignment_census_exact_us :
  internal_function_assignment_sites ULU._sDelayedWarpOp
    ULU.global_definitions =
  delayed_warp_assignment_sites_us.
Proof. vm_compute. reflexivity. Qed.

Theorem delayed_warp_assignment_census_exact_jp :
  internal_function_assignment_sites JLU._sDelayedWarpOp
    JLU.global_definitions =
  delayed_warp_assignment_sites_jp.
Proof. vm_compute. reflexivity. Qed.

Theorem delayed_warp_explicit_address_sites_empty_us :
  internal_function_address_sites ULU._sDelayedWarpOp
    ULU.global_definitions = [].
Proof. vm_compute. reflexivity. Qed.

Theorem delayed_warp_explicit_address_sites_empty_jp :
  internal_function_address_sites JLU._sDelayedWarpOp
    JLU.global_definitions = [].
Proof. vm_compute. reflexivity. Qed.

(** These receipts check call presence or direct-callee order inside each
    clear-site body, plus separate presence of a direct latch assignment.
    They do not relate the assignment's statement position to those calls.
    The clear-to-reset ordering is a pinned-source audit fact whose linked
    Clight execution/refinement remains open. *)
Definition delayed_warp_clear_site_anchor_source_shape_us_claim : Prop :=
  ident_subsequenceb
    [ULU._init_mario; ULU._set_mario_initial_action; ULU._reset_camera]
    (direct_callees_s (fn_body ULU.f_init_mario_after_warp)) = true /\
  statement_assigns_ident_s ULU._sDelayedWarpOp
    (fn_body ULU.f_init_mario_after_warp) = true /\
  ident_subsequenceb
    [ULU._load_mario_area; ULU._init_mario;
     ULU._set_mario_action; ULU._reset_camera]
    (direct_callees_s (fn_body ULU.f_warp_credits)) = true /\
  statement_assigns_ident_s ULU._sDelayedWarpOp
    (fn_body ULU.f_warp_credits) = true /\
  calls_ident_s ULU._set_play_mode (fn_body ULU.f_init_level) = true /\
  statement_assigns_ident_s ULU._sDelayedWarpOp
    (fn_body ULU.f_init_level) = true /\
  calls_ident_s ULU._init_mario_from_save_file
    (fn_body ULU.f_lvl_init_from_save_file) = true /\
  statement_assigns_ident_s ULU._sDelayedWarpOp
    (fn_body ULU.f_lvl_init_from_save_file) = true.

Theorem delayed_warp_clear_site_anchor_source_shape_us :
  delayed_warp_clear_site_anchor_source_shape_us_claim.
Proof.
  unfold delayed_warp_clear_site_anchor_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition delayed_warp_clear_site_anchor_source_shape_jp_claim : Prop :=
  ident_subsequenceb
    [JLU._init_mario; JLU._set_mario_initial_action; JLU._reset_camera]
    (direct_callees_s (fn_body JLU.f_init_mario_after_warp)) = true /\
  statement_assigns_ident_s JLU._sDelayedWarpOp
    (fn_body JLU.f_init_mario_after_warp) = true /\
  ident_subsequenceb
    [JLU._load_mario_area; JLU._init_mario;
     JLU._set_mario_action; JLU._reset_camera]
    (direct_callees_s (fn_body JLU.f_warp_credits)) = true /\
  statement_assigns_ident_s JLU._sDelayedWarpOp
    (fn_body JLU.f_warp_credits) = true /\
  calls_ident_s JLU._set_play_mode (fn_body JLU.f_init_level) = true /\
  statement_assigns_ident_s JLU._sDelayedWarpOp
    (fn_body JLU.f_init_level) = true /\
  calls_ident_s JLU._init_mario_from_save_file
    (fn_body JLU.f_lvl_init_from_save_file) = true /\
  statement_assigns_ident_s JLU._sDelayedWarpOp
    (fn_body JLU.f_lvl_init_from_save_file) = true.

Theorem delayed_warp_clear_site_anchor_source_shape_jp :
  delayed_warp_clear_site_anchor_source_shape_jp_claim.
Proof.
  unfold delayed_warp_clear_site_anchor_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** Source constants and call order for the relevant fatal-versus-object-warp
    race.  Operation 18 is [WARP_OP_DEATH], operation 20 is
    [WARP_OP_GAME_OVER], operation 4 is [WARP_OP_WARP_OBJECT], and the fatal
    timer is 48. *)
Definition retail_fatal_latch_source_shape_us_claim : Prop :=
  is_guarded_first_writer_warp_latch_s
    ULU._sDelayedWarpOp ULU._warpOp
    (fn_body ULU.f_level_trigger_warp) = true /\
  contains_guarded_floor_null_else_call_s
    UMI._m UMI._floor UMI._level_trigger_warp 18
    (fn_body UMI.f_update_mario_geometry_inputs) = true /\
  statement_mentions_int_s 20 (fn_body ULU.f_level_trigger_warp) = true /\
  statement_mentions_int_s 48 (fn_body ULU.f_level_trigger_warp) = true /\
  statement_mentions_int_s 4 (fn_body UI.f_interact_warp) = true /\
  statement_mentions_int_s 16 (fn_body UI.f_interact_warp) = true /\
  statement_mentions_int_s 2 (fn_body UI.f_interact_warp) = true /\
  ident_subsequenceb
    [ULU._warp_area; ULU._check_instant_warp;
     ULU._area_update_objects; ULU._initiate_painting_warp;
     ULU._initiate_delayed_warp]
    (direct_callees_s (fn_body ULU.f_play_mode_normal)) = true /\
  statement_assigns_ident_s ULU._sDelayedWarpOp
    (fn_body ULU.f_initiate_delayed_warp) = false /\
  calls_ident_s UCutscene._level_trigger_warp
    (fn_body UCutscene.f_act_disappeared) = true.

Theorem retail_fatal_latch_source_shape_us :
  retail_fatal_latch_source_shape_us_claim.
Proof.
  unfold retail_fatal_latch_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition retail_fatal_latch_source_shape_jp_claim : Prop :=
  is_guarded_first_writer_warp_latch_s
    JLU._sDelayedWarpOp JLU._warpOp
    (fn_body JLU.f_level_trigger_warp) = true /\
  contains_guarded_floor_null_else_call_s
    JMI._m JMI._floor JMI._level_trigger_warp 18
    (fn_body JMI.f_update_mario_geometry_inputs) = true /\
  statement_mentions_int_s 20 (fn_body JLU.f_level_trigger_warp) = true /\
  statement_mentions_int_s 48 (fn_body JLU.f_level_trigger_warp) = true /\
  statement_mentions_int_s 4 (fn_body JI.f_interact_warp) = true /\
  statement_mentions_int_s 16 (fn_body JI.f_interact_warp) = true /\
  statement_mentions_int_s 2 (fn_body JI.f_interact_warp) = true /\
  ident_subsequenceb
    [JLU._warp_area; JLU._check_instant_warp;
     JLU._area_update_objects; JLU._initiate_painting_warp;
     JLU._initiate_delayed_warp]
    (direct_callees_s (fn_body JLU.f_play_mode_normal)) = true /\
  statement_assigns_ident_s JLU._sDelayedWarpOp
    (fn_body JLU.f_initiate_delayed_warp) = false /\
  calls_ident_s JCutscene._level_trigger_warp
    (fn_body JCutscene.f_act_disappeared) = true.

Theorem retail_fatal_latch_source_shape_jp :
  retail_fatal_latch_source_shape_jp_claim.
Proof.
  unfold retail_fatal_latch_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** Exact packed level-script records for the Area-1 source warp and pyramid
    top.  The numeric equalities below expose the signed high/low coordinate
    fields and the two behavior-parameter bytes.  A general LevelScript decoder
    and execution refinement remain separate obligations. *)
Definition ssl_area1_upper_warp_object_us : list init_data :=
  [ Init_int32 (Int.repr 605560576);
    Init_int32 (Int.repr (-134216960));
    Init_int32 (Int.repr (-67108864));
    Init_int32 (Int.repr 0);
    Init_int32 (Int.repr 253624320);
    Init_addrof USS._bhvWarp (Ptrofs.repr 0) ].

Definition ssl_area1_upper_warp_object_jp : list init_data :=
  [ Init_int32 (Int.repr 605560576);
    Init_int32 (Int.repr (-134216960));
    Init_int32 (Int.repr (-67108864));
    Init_int32 (Int.repr 0);
    Init_int32 (Int.repr 253624320);
    Init_addrof JSS._bhvWarp (Ptrofs.repr 0) ].

Theorem ssl_area1_upper_warp_object_exact_us :
  firstn 6 (skipn 62 (gvar_init USS.v_level_ssl_entry)) =
    ssl_area1_upper_warp_object_us.
Proof. vm_compute. reflexivity. Qed.

Theorem ssl_area1_upper_warp_object_exact_jp :
  firstn 6 (skipn 62 (gvar_init JSS.v_level_ssl_entry)) =
    ssl_area1_upper_warp_object_jp.
Proof. vm_compute. reflexivity. Qed.

(** Under the source macro encoding, these words are intended to describe
    Area 1 node [0xF1] targeting level 6, area 3, node [0x65].  The theorems
    below check only the initializer slice and packed-field arithmetic.  They
    do not prove command decoding, node selection, or transition execution. *)
Definition ssl_area1_death_warp_record : list init_data :=
  [Init_int32 (Int.repr 638120198);
   Init_int32 (Int.repr 56950784)].

Theorem ssl_area1_death_warp_record_exact_us :
  firstn 2 (skipn 92 (gvar_init USS.v_level_ssl_entry)) =
    ssl_area1_death_warp_record.
Proof. vm_compute. reflexivity. Qed.

Theorem ssl_area1_death_warp_record_exact_jp :
  firstn 2 (skipn 92 (gvar_init JSS.v_level_ssl_entry)) =
    ssl_area1_death_warp_record.
Proof. vm_compute. reflexivity. Qed.

Theorem ssl_area1_death_warp_packed_fields :
  638120198 =
    38 * 16777216 + 8 * 65536 + 241 * 256 + 6 /\
  56950784 =
    3 * 16777216 + 101 * 65536.
Proof. split; reflexivity. Qed.

Definition ssl_area1_pyramid_top_object_us : list init_data :=
  [ Init_int32 (Int.repr 605560634);
    Init_int32 (Int.repr (-134150656));
    Init_int32 (Int.repr (-67043328));
    Init_int32 (Int.repr 0);
    Init_int32 (Int.repr 0);
    Init_addrof USS._bhvPyramidTop (Ptrofs.repr 0);
    Init_int32 (Int.repr 117702656) ].

Definition ssl_area1_pyramid_top_object_jp : list init_data :=
  [ Init_int32 (Int.repr 605560634);
    Init_int32 (Int.repr (-134150656));
    Init_int32 (Int.repr (-67043328));
    Init_int32 (Int.repr 0);
    Init_int32 (Int.repr 0);
    Init_addrof JSS._bhvPyramidTop (Ptrofs.repr 0);
    Init_int32 (Int.repr 117702656) ].

Theorem ssl_area1_pyramid_top_object_exact_us :
  gvar_init USS.v_script_func_local_1 =
    ssl_area1_pyramid_top_object_us.
Proof. vm_compute. reflexivity. Qed.

Theorem ssl_area1_pyramid_top_object_exact_jp :
  gvar_init JSS.v_script_func_local_1 =
    ssl_area1_pyramid_top_object_jp.
Proof. vm_compute. reflexivity. Qed.

Theorem ssl_pu_packed_field_arithmetic :
  -134216960 = -2048 * 65536 + 768 /\
  -67108864 = -1024 * 65536 /\
  253624320 = 15 * 16777216 + 30 * 65536 /\
  -134150656 = -2047 * 65536 + 1536 /\
  -67043328 = -1023 * 65536.
Proof. repeat split; reflexivity. Qed.

Definition ssl_pu_level_script_claim : Prop :=
  firstn 6 (skipn 62 (gvar_init USS.v_level_ssl_entry)) =
    ssl_area1_upper_warp_object_us /\
  firstn 6 (skipn 62 (gvar_init JSS.v_level_ssl_entry)) =
    ssl_area1_upper_warp_object_jp /\
  gvar_init USS.v_script_func_local_1 =
    ssl_area1_pyramid_top_object_us /\
  gvar_init JSS.v_script_func_local_1 =
    ssl_area1_pyramid_top_object_jp /\
  (-134216960 = -2048 * 65536 + 768 /\
   -67108864 = -1024 * 65536 /\
   253624320 = 15 * 16777216 + 30 * 65536 /\
   -134150656 = -2047 * 65536 + 1536 /\
   -67043328 = -1023 * 65536).

Theorem ssl_pu_level_script_checked :
  ssl_pu_level_script_claim.
Proof.
  unfold ssl_pu_level_script_claim.
  split; [exact ssl_area1_upper_warp_object_exact_us |].
  split; [exact ssl_area1_upper_warp_object_exact_jp |].
  split; [exact ssl_area1_pyramid_top_object_exact_us |].
  split; [exact ssl_area1_pyramid_top_object_exact_jp |].
  exact ssl_pu_packed_field_arithmetic.
Qed.

Definition float32_fifty_bits : Z := 1112014848.
Definition float32_seventy_eight_bits : Z := 1117519872.

Theorem pyramid_top_warp_geometry_source_shape_us :
  assigns_field_named_s UBA._hitboxRadius
    (fn_body UBA.f_bhv_warp_loop) = true /\
  assigns_field_named_s UBA._hitboxHeight
    (fn_body UBA.f_bhv_warp_loop) = true /\
  statement_mentions_float32_bits_s float32_fifty_bits
    (fn_body UBA.f_bhv_warp_loop) = true /\
  statement_mentions_float32_bits_s float32_seventy_eight_bits
    (fn_body USurface.f_find_floor_from_list) = true /\
  initializer_list_mentions_addrof UBD._bhv_pyramid_top_loop
    (gvar_init UBD.v_bhvPyramidTop) = true /\
  initializer_list_mentions_addrof UBD._load_object_collision_model
    (gvar_init UBD.v_bhvPyramidTop) = true.
Proof. vm_compute. repeat split. Qed.

Theorem pyramid_top_warp_geometry_source_shape_jp :
  assigns_field_named_s JBA._hitboxRadius
    (fn_body JBA.f_bhv_warp_loop) = true /\
  assigns_field_named_s JBA._hitboxHeight
    (fn_body JBA.f_bhv_warp_loop) = true /\
  statement_mentions_float32_bits_s float32_fifty_bits
    (fn_body JBA.f_bhv_warp_loop) = true /\
  statement_mentions_float32_bits_s float32_seventy_eight_bits
    (fn_body JSurface.f_find_floor_from_list) = true /\
  initializer_list_mentions_addrof JBD._bhv_pyramid_top_loop
    (gvar_init JBD.v_bhvPyramidTop) = true /\
  initializer_list_mentions_addrof JBD._load_object_collision_model
    (gvar_init JBD.v_bhvPyramidTop) = true.
Proof. vm_compute. repeat split. Qed.

(* In the stock top's spinning function, the platform transform writes yaw but
   neither pitch nor roll.  The displacement function reads X/Z platform
   velocity slots but not the Y velocity slot.  Matrix-helper semantics are
   external to this translation, so exact yaw-preserves-Y execution remains a
   refinement lemma rather than being inferred from these occurrence checks. *)
Theorem stock_pyramid_top_yaw_only_source_shape_us :
  assigns_array_slot_s UOB._asS32 36
    (fn_body UOB.f_bhv_pyramid_top_spinning) = true /\
  assigns_array_slot_s UOB._asS32 35
    (fn_body UOB.f_bhv_pyramid_top_spinning) = false /\
  assigns_array_slot_s UOB._asS32 37
    (fn_body UOB.f_bhv_pyramid_top_spinning) = false /\
  statement_mentions_array_slot_s UPD._asF32 9
    (fn_body UPD.f_apply_platform_displacement) = true /\
  statement_mentions_array_slot_s UPD._asF32 10
    (fn_body UPD.f_apply_platform_displacement) = false /\
  statement_mentions_array_slot_s UPD._asF32 11
    (fn_body UPD.f_apply_platform_displacement) = true.
Proof. vm_compute. repeat split. Qed.

Theorem stock_pyramid_top_yaw_only_source_shape_jp :
  assigns_array_slot_s JOB._asS32 36
    (fn_body JOB.f_bhv_pyramid_top_spinning) = true /\
  assigns_array_slot_s JOB._asS32 35
    (fn_body JOB.f_bhv_pyramid_top_spinning) = false /\
  assigns_array_slot_s JOB._asS32 37
    (fn_body JOB.f_bhv_pyramid_top_spinning) = false /\
  statement_mentions_array_slot_s JPD._asF32 9
    (fn_body JPD.f_apply_platform_displacement) = true /\
  statement_mentions_array_slot_s JPD._asF32 10
    (fn_body JPD.f_apply_platform_displacement) = false /\
  statement_mentions_array_slot_s JPD._asF32 11
    (fn_body JPD.f_apply_platform_displacement) = true.
Proof. vm_compute. repeat split. Qed.

(** The spinning/explosion distinction used by the platform cross-check is
    visible in both generated units.  Switch state 1 contains the spinning
    callback and state 2 contains the explosion callback.  In the spinning
    body, preprocessed object-field macros expose:

    - [oTimer] constants 60 and 150;
    - the [oAngleVelYaw] cap 0x1800 (6144);
    - the binary32 literal 5.0f; and
    - assignments to raw [oPosY], [oVelY], and [oAngleVelYaw] slots 7, 10,
      and 36 respectively.

    The explosion body assigns literal zero to [activeFlags] and contains no
    slot-7 or slot-36 assignment.  It does assign Float32 slot 10 on each newly
    spawned fragment, so the deliberately base-insensitive array recognizer
    cannot turn that occurrence into a claim about the top's own [oVelY].

    Every conjunct below is an occurrence/source-shape receipt.  In particular,
    switch labels do not prove reachability, constants do not prove their
    control dependence, assignments do not establish a frame recurrence, and
    nothing here executes the behavior interpreter or bounds the live pose. *)
Definition float32_five_bits : Z := 1084227584.

Definition pyramid_top_spin_explosion_pose_source_shape_us_claim : Prop :=
  switch_case_calls_ident_s 1 UOB._bhv_pyramid_top_spinning
    (fn_body UOB.f_bhv_pyramid_top_loop) = true /\
  switch_case_calls_ident_s 2 UOB._bhv_pyramid_top_explode
    (fn_body UOB.f_bhv_pyramid_top_loop) = true /\
  statement_mentions_int_s 60
    (fn_body UOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_int_s 150
    (fn_body UOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_int_s 6144
    (fn_body UOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_float32_bits_s float32_five_bits
    (fn_body UOB.f_bhv_pyramid_top_spinning) = true /\
  assigns_array_slot_s UOB._asF32 7
    (fn_body UOB.f_bhv_pyramid_top_spinning) = true /\
  assigns_array_slot_s UOB._asF32 10
    (fn_body UOB.f_bhv_pyramid_top_spinning) = true /\
  assigns_array_slot_s UOB._asS32 36
    (fn_body UOB.f_bhv_pyramid_top_spinning) = true /\
  assigns_field_int_constant_s UOB._activeFlags 0
    (fn_body UOB.f_bhv_pyramid_top_explode) = true /\
  assigns_array_slot_s UOB._asF32 7
    (fn_body UOB.f_bhv_pyramid_top_explode) = false /\
  assigns_array_slot_s UOB._asS32 36
    (fn_body UOB.f_bhv_pyramid_top_explode) = false /\
  assigns_array_slot_s UOB._asF32 10
    (fn_body UOB.f_bhv_pyramid_top_explode) = true.

Theorem pyramid_top_spin_explosion_pose_source_shape_us :
  pyramid_top_spin_explosion_pose_source_shape_us_claim.
Proof. vm_compute. repeat split. Qed.

Definition pyramid_top_spin_explosion_pose_source_shape_jp_claim : Prop :=
  switch_case_calls_ident_s 1 JOB._bhv_pyramid_top_spinning
    (fn_body JOB.f_bhv_pyramid_top_loop) = true /\
  switch_case_calls_ident_s 2 JOB._bhv_pyramid_top_explode
    (fn_body JOB.f_bhv_pyramid_top_loop) = true /\
  statement_mentions_int_s 60
    (fn_body JOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_int_s 150
    (fn_body JOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_int_s 6144
    (fn_body JOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_float32_bits_s float32_five_bits
    (fn_body JOB.f_bhv_pyramid_top_spinning) = true /\
  assigns_array_slot_s JOB._asF32 7
    (fn_body JOB.f_bhv_pyramid_top_spinning) = true /\
  assigns_array_slot_s JOB._asF32 10
    (fn_body JOB.f_bhv_pyramid_top_spinning) = true /\
  assigns_array_slot_s JOB._asS32 36
    (fn_body JOB.f_bhv_pyramid_top_spinning) = true /\
  assigns_field_int_constant_s JOB._activeFlags 0
    (fn_body JOB.f_bhv_pyramid_top_explode) = true /\
  assigns_array_slot_s JOB._asF32 7
    (fn_body JOB.f_bhv_pyramid_top_explode) = false /\
  assigns_array_slot_s JOB._asS32 36
    (fn_body JOB.f_bhv_pyramid_top_explode) = false /\
  assigns_array_slot_s JOB._asF32 10
    (fn_body JOB.f_bhv_pyramid_top_explode) = true.

Theorem pyramid_top_spin_explosion_pose_source_shape_jp :
  pyramid_top_spin_explosion_pose_source_shape_jp_claim.
Proof. vm_compute. repeat split. Qed.

Theorem change_area_direct_callee_order_us :
  ident_subsequenceb [UAR._unload_area; UAR._load_area]
    (direct_callees_s (fn_body UAR.f_change_area)) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem change_area_direct_callee_order_jp :
  ident_subsequenceb [JAR._unload_area; JAR._load_area]
    (direct_callees_s (fn_body JAR.f_change_area)) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem area_object_unload_source_shape_us :
  statement_mentions_ident_s UOL._next
    (fn_body UOL.f_unload_objects_from_area) = true /\
  calls_ident_s UOL._unload_object
    (fn_body UOL.f_unload_objects_from_area) = true.
Proof. vm_compute. split; reflexivity. Qed.

Theorem area_object_unload_source_shape_jp :
  statement_mentions_ident_s JOL._next
    (fn_body JOL.f_unload_objects_from_area) = true /\
  calls_ident_s JOL._unload_object
    (fn_body JOL.f_unload_objects_from_area) = true.
Proof. vm_compute. split; reflexivity. Qed.

Theorem unload_object_source_shape_us :
  assigns_field_named_s USO._activeFlags (fn_body USO.f_unload_object) = true /\
  statement_mentions_ident_s USO._prevObj (fn_body USO.f_unload_object) = true /\
  calls_ident_s USO._deallocate_object (fn_body USO.f_unload_object) = true.
Proof. vm_compute. repeat split. Qed.

Theorem unload_object_source_shape_jp :
  assigns_field_named_s JSO._activeFlags (fn_body JSO.f_unload_object) = true /\
  statement_mentions_ident_s JSO._prevObj (fn_body JSO.f_unload_object) = true /\
  calls_ident_s JSO._deallocate_object (fn_body JSO.f_unload_object) = true.
Proof. vm_compute. repeat split. Qed.

Definition float32_two_bits : Z := 1073741824.
Definition float32_four_bits : Z := 1082130432.
Definition float32_ten_bits : Z := 1092616192.
Definition float32_twenty_bits : Z := 1101004800.
Definition float32_twenty_nine_bits : Z := 1105723392.
Definition float32_thirty_bits : Z := 1106247680.
Definition float32_forty_eight_bits : Z := 1111490560.
Definition float32_one_hundred_bits : Z := 1120403456.
Definition float32_one_hundred_twenty_eight_bits : Z := 1124073472.
Definition act_soft_bonk_bits : Z := 16910518.
Definition act_top_of_pole_jump_bits : Z := 50333837.
Definition act_jump_kick_bits : Z := 25168044.
Definition act_dive_bits : Z := 25692298.
Definition act_forward_rollout_bits : Z := 16779430.
Definition act_backward_rollout_bits : Z := 16779437.

(* Locate a generated switch case and check a Float32 literal in that case's
   body.  This deliberately says nothing about whether execution reaches the
   switch or selects the case. *)
Fixpoint switch_case_mentions_float32_bits_s
    (case_label bits : Z) (s : statement) : bool :=
  match s with
  | Ssequence a b | Sloop a b =>
      switch_case_mentions_float32_bits_s case_label bits a ||
      switch_case_mentions_float32_bits_s case_label bits b
  | Sifthenelse _ a b =>
      switch_case_mentions_float32_bits_s case_label bits a ||
      switch_case_mentions_float32_bits_s case_label bits b
  | Sswitch _ cases =>
      switch_case_mentions_float32_bits_ls case_label bits cases
  | Slabel _ body =>
      switch_case_mentions_float32_bits_s case_label bits body
  | _ => false
  end
with switch_case_mentions_float32_bits_ls
    (case_label bits : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons label body rest =>
      (match label with
       | Some found =>
           Z.eqb found case_label &&
           statement_mentions_float32_bits_s bits body
       | None => false
       end) ||
      switch_case_mentions_float32_bits_s case_label bits body ||
      switch_case_mentions_float32_bits_ls case_label bits rest
  end.

(* Check an exact direct call whose second argument is an integer literal.
   This is narrower than separately checking a callee and a constant, which
   could otherwise witness two unrelated syntax nodes. *)
Fixpoint calls_ident_with_second_int_literal_s
    (callee : ident) (literal : Z) (s : statement) : bool :=
  match s with
  | Scall _ (Evar id _) (_ :: Econst_int value _ :: _) =>
      Pos.eqb id callee && Int.eq value (Int.repr literal)
  | Ssequence a b | Sloop a b =>
      calls_ident_with_second_int_literal_s callee literal a ||
      calls_ident_with_second_int_literal_s callee literal b
  | Sifthenelse _ a b =>
      calls_ident_with_second_int_literal_s callee literal a ||
      calls_ident_with_second_int_literal_s callee literal b
  | Sswitch _ cases =>
      calls_ident_with_second_int_literal_ls callee literal cases
  | Slabel _ body =>
      calls_ident_with_second_int_literal_s callee literal body
  | _ => false
  end
with calls_ident_with_second_int_literal_ls
    (callee : ident) (literal : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      calls_ident_with_second_int_literal_s callee literal body ||
      calls_ident_with_second_int_literal_ls callee literal rest
  end.

(* Recognize the exact generated assignment [field = source + literal]. *)
Fixpoint assigns_field_from_temp_plus_int_s
    (field source : ident) (literal : Z) (s : statement) : bool :=
  match s with
  | Sassign (Efield _ found_field _)
      (Ebinop Oadd (Etempvar found_source _) (Econst_int value _) _) =>
      Pos.eqb found_field field &&
      Pos.eqb found_source source &&
      Int.eq value (Int.repr literal)
  | Ssequence a b | Sloop a b =>
      assigns_field_from_temp_plus_int_s field source literal a ||
      assigns_field_from_temp_plus_int_s field source literal b
  | Sifthenelse _ a b =>
      assigns_field_from_temp_plus_int_s field source literal a ||
      assigns_field_from_temp_plus_int_s field source literal b
  | Sswitch _ cases =>
      assigns_field_from_temp_plus_int_ls field source literal cases
  | Slabel _ body =>
      assigns_field_from_temp_plus_int_s field source literal body
  | _ => false
  end
with assigns_field_from_temp_plus_int_ls
    (field source : ident) (literal : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_field_from_temp_plus_int_s field source literal body ||
      assigns_field_from_temp_plus_int_ls field source literal rest
  end.

(* In the generated wall loop, [upperY] is first loaded into a temporary and
   the next statement computes [y > upperY].  Matching the adjacent statements
   keeps the field read tied to the strict comparison instead of merely finding
   the same identifier and operator elsewhere in the function. *)
Definition is_strict_temp_gt_loaded_field
    (y field : ident) (load compare : statement) : bool :=
  match load, compare with
  | Sset upper_temp (Efield _ found_field _),
    Sset _ (Ecast
      (Ebinop Ogt (Etempvar found_y _) (Etempvar compared_upper _) _) _) =>
      Pos.eqb found_field field &&
      Pos.eqb found_y y &&
      Pos.eqb compared_upper upper_temp
  | _, _ => false
  end.

Fixpoint contains_strict_temp_gt_loaded_field_s
    (y field : ident) (s : statement) : bool :=
  match s with
  | Ssequence a b =>
      is_strict_temp_gt_loaded_field y field a b ||
      contains_strict_temp_gt_loaded_field_s y field a ||
      contains_strict_temp_gt_loaded_field_s y field b
  | Sloop a b =>
      contains_strict_temp_gt_loaded_field_s y field a ||
      contains_strict_temp_gt_loaded_field_s y field b
  | Sifthenelse _ a b =>
      contains_strict_temp_gt_loaded_field_s y field a ||
      contains_strict_temp_gt_loaded_field_s y field b
  | Sswitch _ cases =>
      contains_strict_temp_gt_loaded_field_ls y field cases
  | Slabel _ body =>
      contains_strict_temp_gt_loaded_field_s y field body
  | _ => false
  end
with contains_strict_temp_gt_loaded_field_ls
    (y field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_strict_temp_gt_loaded_field_s y field body ||
      contains_strict_temp_gt_loaded_field_ls y field rest
  end.

(* Selected source-shape facts from the archived pole investigation, now
   checked against both current generated versions.  They remain syntactic
   checks and do not make the normalized pole model complete. *)
Definition normalized_pole_source_shape_us_claim : Prop :=
  assigns_through_field_s UBA._hitboxHeight
    (fn_body UBA.f_bhv_pole_init) = true /\
  statement_mentions_float32_bits_s float32_one_hundred_bits
    (fn_body UAuto.f_set_pole_position) = true /\
  statement_mentions_int_s 2 (fn_body UAuto.f_act_holding_pole) = true /\
  statement_mentions_int_s 32768 (fn_body UAuto.f_act_holding_pole) = true /\
  statement_mentions_float32_bits_s float32_two_bits
    (fn_body UAuto.f_act_holding_pole) = true /\
  statement_mentions_int_s act_soft_bonk_bits
    (fn_body UAuto.f_act_holding_pole) = true /\
  statement_mentions_int_s 2 (fn_body UAuto.f_act_top_of_pole) = true /\
  statement_mentions_int_s act_top_of_pole_jump_bits
    (fn_body UAuto.f_act_top_of_pole) = true /\
  statement_mentions_float32_bits_s float32_four_bits
    (fn_body UStep.f_apply_gravity) = true /\
  statement_contains_loop_s (fn_body UStep.f_perform_air_step) = true.

Theorem normalized_pole_source_shape_us :
  normalized_pole_source_shape_us_claim.
Proof. unfold normalized_pole_source_shape_us_claim; vm_compute; repeat split. Qed.

Definition normalized_pole_source_shape_jp_claim : Prop :=
  assigns_through_field_s JBA._hitboxHeight
    (fn_body JBA.f_bhv_pole_init) = true /\
  statement_mentions_float32_bits_s float32_one_hundred_bits
    (fn_body JAuto.f_set_pole_position) = true /\
  statement_mentions_int_s 2 (fn_body JAuto.f_act_holding_pole) = true /\
  statement_mentions_int_s 32768 (fn_body JAuto.f_act_holding_pole) = true /\
  statement_mentions_float32_bits_s float32_two_bits
    (fn_body JAuto.f_act_holding_pole) = true /\
  statement_mentions_int_s act_soft_bonk_bits
    (fn_body JAuto.f_act_holding_pole) = true /\
  statement_mentions_int_s 2 (fn_body JAuto.f_act_top_of_pole) = true /\
  statement_mentions_int_s act_top_of_pole_jump_bits
    (fn_body JAuto.f_act_top_of_pole) = true /\
  statement_mentions_float32_bits_s float32_four_bits
    (fn_body JStep.f_apply_gravity) = true /\
  statement_contains_loop_s (fn_body JStep.f_perform_air_step) = true.

Theorem normalized_pole_source_shape_jp :
  normalized_pole_source_shape_jp_claim.
Proof. unfold normalized_pole_source_shape_jp_claim; vm_compute; repeat split. Qed.

(* Selected source-shape facts from the archived no-parallel-universe work.
   The local alias-gap lemma in RouteEvidence still requires a writer-coverage
   bridge; these facts do not supply that bridge. *)
Definition no_a_movement_source_shape_us_claim : Prop :=
  ident_subsequenceb
    [UMove._begin_braking_action; UMove._set_jump_from_landing]
    (direct_callees_s (fn_body UMove.f_act_walking)) = true /\
  ident_subsequenceb [UMove._apply_slope_decel; UMove._perform_ground_step]
    (direct_callees_s (fn_body UMove.f_act_braking)) = true /\
  statement_mentions_int_s 128 (fn_body UMove.f_act_move_punching) = true /\
  statement_contains_loop_s (fn_body UStep.f_perform_ground_step) = true /\
  statement_contains_loop_s (fn_body UStep.f_perform_air_step) = true /\
  calls_ident_s UStep._find_floor
    (fn_body UStep.f_perform_ground_quarter_step) = true /\
  calls_ident_s UStep._find_floor
    (fn_body UStep.f_perform_air_quarter_step) = true.

Theorem no_a_movement_source_shape_us :
  no_a_movement_source_shape_us_claim.
Proof. unfold no_a_movement_source_shape_us_claim; vm_compute; repeat split. Qed.

Definition no_a_movement_source_shape_jp_claim : Prop :=
  ident_subsequenceb
    [JMove._begin_braking_action; JMove._set_jump_from_landing]
    (direct_callees_s (fn_body JMove.f_act_walking)) = true /\
  ident_subsequenceb [JMove._apply_slope_decel; JMove._perform_ground_step]
    (direct_callees_s (fn_body JMove.f_act_braking)) = true /\
  statement_mentions_int_s 128 (fn_body JMove.f_act_move_punching) = true /\
  statement_contains_loop_s (fn_body JStep.f_perform_ground_step) = true /\
  statement_contains_loop_s (fn_body JStep.f_perform_air_step) = true /\
  calls_ident_s JStep._find_floor
    (fn_body JStep.f_perform_ground_quarter_step) = true /\
  calls_ident_s JStep._find_floor
    (fn_body JStep.f_perform_air_quarter_step) = true.

Theorem no_a_movement_source_shape_jp :
  no_a_movement_source_shape_jp_claim.
Proof. unfold no_a_movement_source_shape_jp_claim; vm_compute; repeat split. Qed.

(* Holding A at the modeled entry is permitted by the theorem's edge-triggered
   input condition.  These generated-AST receipts preserve the corresponding
   punching -> jump-kick source shapes in both versions: both the moving
   act_move_punching handler and the object-action act_punching handler contain
   the A-down mask and jump-kick action constant, their direct set_mario_action
   calls are present, the matching airborne-action switch case contains the
   Float32 20 literal, and act_jump_kick directly calls perform_air_step with
   literal step argument 0.

   These are syntactic checks only.  They prove neither branch/dataflow
   correspondence nor reachability from CleanPyramidEntry.  In particular,
   the exact perform_air_step call is the positive fact recorded here; no
   absence claim about ledge-grab or other semantics is made. *)
Definition held_a_jump_kick_source_shape_us_claim : Prop :=
  statement_mentions_int_s 128 (fn_body UMove.f_act_move_punching) = true /\
  statement_mentions_int_s act_jump_kick_bits
    (fn_body UMove.f_act_move_punching) = true /\
  calls_ident_s UMove._set_mario_action
    (fn_body UMove.f_act_move_punching) = true /\
  statement_mentions_int_s 128
    (fn_body UObjectActions.f_act_punching) = true /\
  statement_mentions_int_s act_jump_kick_bits
    (fn_body UObjectActions.f_act_punching) = true /\
  calls_ident_s UObjectActions._set_mario_action
    (fn_body UObjectActions.f_act_punching) = true /\
  switch_case_mentions_float32_bits_s
    act_jump_kick_bits float32_twenty_bits
    (fn_body UMI.f_set_mario_action_airborne) = true /\
  calls_ident_with_second_int_literal_s UAir._perform_air_step 0
    (fn_body UAir.f_act_jump_kick) = true.

Theorem held_a_jump_kick_source_shape_us :
  held_a_jump_kick_source_shape_us_claim.
Proof.
  unfold held_a_jump_kick_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition held_a_jump_kick_source_shape_jp_claim : Prop :=
  statement_mentions_int_s 128 (fn_body JMove.f_act_move_punching) = true /\
  statement_mentions_int_s act_jump_kick_bits
    (fn_body JMove.f_act_move_punching) = true /\
  calls_ident_s JMove._set_mario_action
    (fn_body JMove.f_act_move_punching) = true /\
  statement_mentions_int_s 128
    (fn_body JObjectActions.f_act_punching) = true /\
  statement_mentions_int_s act_jump_kick_bits
    (fn_body JObjectActions.f_act_punching) = true /\
  calls_ident_s JObjectActions._set_mario_action
    (fn_body JObjectActions.f_act_punching) = true /\
  switch_case_mentions_float32_bits_s
    act_jump_kick_bits float32_twenty_bits
    (fn_body JMI.f_set_mario_action_airborne) = true /\
  calls_ident_with_second_int_literal_s JAir._perform_air_step 0
    (fn_body JAir.f_act_jump_kick) = true.

Theorem held_a_jump_kick_source_shape_jp :
  held_a_jump_kick_source_shape_jp_claim.
Proof.
  unfold held_a_jump_kick_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(* B presses are not excluded by a no-A-edge hypothesis.  The following
   source-shape receipts therefore retain the high-speed ground-dive and
   dive-slide rollout chain in the ordinary-motion inventory.  They check the
   generated constants and direct calls only; they do not prove that the
   constants lie on one feasible dataflow path, that a clean run reaches the
   actions, or that a rollout reaches a target region. *)
Definition b_rollout_chain_source_shape_us_claim : Prop :=
  statement_mentions_int_s 8192
    (fn_body UMove.f_check_ground_dive_or_punch) = true /\
  statement_mentions_float32_bits_s float32_twenty_nine_bits
    (fn_body UMove.f_check_ground_dive_or_punch) = true /\
  statement_mentions_float32_bits_s float32_forty_eight_bits
    (fn_body UMove.f_check_ground_dive_or_punch) = true /\
  statement_mentions_float32_bits_s float32_twenty_bits
    (fn_body UMove.f_check_ground_dive_or_punch) = true /\
  statement_mentions_int_s act_dive_bits
    (fn_body UMove.f_check_ground_dive_or_punch) = true /\
  calls_ident_s UMove._set_mario_action
    (fn_body UMove.f_check_ground_dive_or_punch) = true /\
  statement_mentions_int_s 8192 (fn_body UMove.f_act_dive_slide) = true /\
  statement_mentions_int_s act_forward_rollout_bits
    (fn_body UMove.f_act_dive_slide) = true /\
  statement_mentions_int_s act_backward_rollout_bits
    (fn_body UMove.f_act_dive_slide) = true /\
  calls_ident_s UMove._set_mario_action
    (fn_body UMove.f_act_dive_slide) = true /\
  statement_mentions_float32_bits_s float32_thirty_bits
    (fn_body UAir.f_act_forward_rollout) = true /\
  calls_ident_with_second_int_literal_s UAir._perform_air_step 0
    (fn_body UAir.f_act_forward_rollout) = true /\
  statement_mentions_float32_bits_s float32_thirty_bits
    (fn_body UAir.f_act_backward_rollout) = true /\
  calls_ident_with_second_int_literal_s UAir._perform_air_step 0
    (fn_body UAir.f_act_backward_rollout) = true.

Theorem b_rollout_chain_source_shape_us :
  b_rollout_chain_source_shape_us_claim.
Proof.
  unfold b_rollout_chain_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition b_rollout_chain_source_shape_jp_claim : Prop :=
  statement_mentions_int_s 8192
    (fn_body JMove.f_check_ground_dive_or_punch) = true /\
  statement_mentions_float32_bits_s float32_twenty_nine_bits
    (fn_body JMove.f_check_ground_dive_or_punch) = true /\
  statement_mentions_float32_bits_s float32_forty_eight_bits
    (fn_body JMove.f_check_ground_dive_or_punch) = true /\
  statement_mentions_float32_bits_s float32_twenty_bits
    (fn_body JMove.f_check_ground_dive_or_punch) = true /\
  statement_mentions_int_s act_dive_bits
    (fn_body JMove.f_check_ground_dive_or_punch) = true /\
  calls_ident_s JMove._set_mario_action
    (fn_body JMove.f_check_ground_dive_or_punch) = true /\
  statement_mentions_int_s 8192 (fn_body JMove.f_act_dive_slide) = true /\
  statement_mentions_int_s act_forward_rollout_bits
    (fn_body JMove.f_act_dive_slide) = true /\
  statement_mentions_int_s act_backward_rollout_bits
    (fn_body JMove.f_act_dive_slide) = true /\
  calls_ident_s JMove._set_mario_action
    (fn_body JMove.f_act_dive_slide) = true /\
  statement_mentions_float32_bits_s float32_thirty_bits
    (fn_body JAir.f_act_forward_rollout) = true /\
  calls_ident_with_second_int_literal_s JAir._perform_air_step 0
    (fn_body JAir.f_act_forward_rollout) = true /\
  statement_mentions_float32_bits_s float32_thirty_bits
    (fn_body JAir.f_act_backward_rollout) = true /\
  calls_ident_with_second_int_literal_s JAir._perform_air_step 0
    (fn_body JAir.f_act_backward_rollout) = true.

Theorem b_rollout_chain_source_shape_jp :
  b_rollout_chain_source_shape_jp_claim.
Proof.
  unfold b_rollout_chain_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(* The retail area-entry initializer rewrites Mario's cap flags and resets the
   cap timer.  These checks are path-insensitive syntax receipts: they do not
   choose between the cap-worn and lost-cap branches (both are non-Wing), and
   they do not prove that no later level-script or object action grants a
   special cap. *)
Definition retail_entry_cap_reset_source_shape_us_claim : Prop :=
  calls_ident_s ULU._init_mario
    (fn_body ULU.f_init_mario_after_warp) = true /\
  calls_ident_s UMI._save_file_get_flags (fn_body UMI.f_init_mario) = true /\
  assigns_through_field_s UMI._flags (fn_body UMI.f_init_mario) = true /\
  statement_mentions_int_s 1 (fn_body UMI.f_init_mario) = true /\
  statement_mentions_int_s 16 (fn_body UMI.f_init_mario) = true /\
  assigns_through_field_s UMI._capTimer (fn_body UMI.f_init_mario) = true.

Theorem retail_entry_cap_reset_source_shape_us :
  retail_entry_cap_reset_source_shape_us_claim.
Proof.
  unfold retail_entry_cap_reset_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition retail_entry_cap_reset_source_shape_jp_claim : Prop :=
  calls_ident_s JLU._init_mario
    (fn_body JLU.f_init_mario_after_warp) = true /\
  calls_ident_s JMI._save_file_get_flags (fn_body JMI.f_init_mario) = true /\
  assigns_through_field_s JMI._flags (fn_body JMI.f_init_mario) = true /\
  statement_mentions_int_s 1 (fn_body JMI.f_init_mario) = true /\
  statement_mentions_int_s 16 (fn_body JMI.f_init_mario) = true /\
  assigns_through_field_s JMI._capTimer (fn_body JMI.f_init_mario) = true.

Theorem retail_entry_cap_reset_source_shape_jp :
  retail_entry_cap_reset_source_shape_jp_claim.
Proof.
  unfold retail_entry_cap_reset_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(* Object-field macros are expanded by preprocessing: [oPosY] is rawData
   Float32 slot 7 and [oVelY] is slot 10 in these generated units.  The facts
   below record the elevator loop's writes and its 10.0f/128.0f literals only;
   they do not prove a per-frame displacement bound or platform containment. *)
Definition pyramid_elevator_motion_source_shape_us_claim : Prop :=
  assigns_array_slot_s UOB._asF32 7
    (fn_body UOB.f_bhv_pyramid_elevator_loop) = true /\
  assigns_array_slot_s UOB._asF32 10
    (fn_body UOB.f_bhv_pyramid_elevator_loop) = true /\
  statement_mentions_float32_bits_s float32_ten_bits
    (fn_body UOB.f_bhv_pyramid_elevator_loop) = true /\
  statement_mentions_float32_bits_s float32_one_hundred_twenty_eight_bits
    (fn_body UOB.f_bhv_pyramid_elevator_loop) = true.

Theorem pyramid_elevator_motion_source_shape_us :
  pyramid_elevator_motion_source_shape_us_claim.
Proof.
  unfold pyramid_elevator_motion_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition pyramid_elevator_motion_source_shape_jp_claim : Prop :=
  assigns_array_slot_s JOB._asF32 7
    (fn_body JOB.f_bhv_pyramid_elevator_loop) = true /\
  assigns_array_slot_s JOB._asF32 10
    (fn_body JOB.f_bhv_pyramid_elevator_loop) = true /\
  statement_mentions_float32_bits_s float32_ten_bits
    (fn_body JOB.f_bhv_pyramid_elevator_loop) = true /\
  statement_mentions_float32_bits_s float32_one_hundred_twenty_eight_bits
    (fn_body JOB.f_bhv_pyramid_elevator_loop) = true.

Theorem pyramid_elevator_motion_source_shape_jp :
  pyramid_elevator_motion_source_shape_jp_claim.
Proof.
  unfold pyramid_elevator_motion_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(* The 30.0f lower-wall query offset is checked at the exact direct
   resolve_and_return_wall_collisions call in perform_air_quarter_step.  This
   remains path-insensitive and does not yet connect the query to a particular
   elevator surface or prove the later 256 + 5 - 30 clearance arithmetic. *)
Theorem air_quarter_lower_wall_query_source_shape_us :
  calls_ident_with_float32_arg_s
    UStep._resolve_and_return_wall_collisions float32_thirty_bits
    (fn_body UStep.f_perform_air_quarter_step) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem air_quarter_lower_wall_query_source_shape_jp :
  calls_ident_with_float32_arg_s
    JStep._resolve_and_return_wall_collisions float32_thirty_bits
    (fn_body JStep.f_perform_air_quarter_step) = true.
Proof. vm_compute. reflexivity. Qed.

(* [read_surface_data] pads a triangle's maximum vertex Y by five when it
   initializes [upperY].  The wall-list loop rejects a wall only for the strict
   comparison [y > upperY], so equality is not rejected by this height guard.
   These exact generated-syntax receipts anchor the +5 correction but do not
   prove a collision or a complete elevator-containment invariant. *)
Theorem surface_upper_y_padding_source_shape_us :
  assigns_field_from_temp_plus_int_s
    USurfaceLoad._upperY USurfaceLoad._maxY 5
    (fn_body USurfaceLoad.f_read_surface_data) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem surface_upper_y_padding_source_shape_jp :
  assigns_field_from_temp_plus_int_s
    JSurfaceLoad._upperY JSurfaceLoad._maxY 5
    (fn_body JSurfaceLoad.f_read_surface_data) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem wall_upper_y_strict_rejection_source_shape_us :
  contains_strict_temp_gt_loaded_field_s USurface._y USurface._upperY
    (fn_body USurface.f_find_wall_collisions_from_list) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem wall_upper_y_strict_rejection_source_shape_jp :
  contains_strict_temp_gt_loaded_field_s JSurface._y JSurface._upperY
    (fn_body JSurface.f_find_wall_collisions_from_list) = true.
Proof. vm_compute. reflexivity. Qed.

(* [execute_mario_action] dispatches submerged actions as well as the six
   action groups imported by the original project.  Keep the direct water and
   whirlpool position writers in the generated-program boundary even though a
   later SSL-specific reachability theorem may prove those actions
   unreachable.  This is a syntax receipt, not a callgraph or execution
   refinement theorem. *)
Definition submerged_position_writer_source_shape_us_claim : Prop :=
  calls_ident_s USubmerged._vec3f_copy
    (fn_body USubmerged.f_perform_water_full_step) = true /\
  calls_ident_s USubmerged._vec3f_set
    (fn_body USubmerged.f_perform_water_full_step) = true /\
  assigns_array_slot_s USubmerged._pos 0
    (fn_body USubmerged.f_act_caught_in_whirlpool) = true /\
  assigns_array_slot_s USubmerged._pos 1
    (fn_body USubmerged.f_act_caught_in_whirlpool) = true /\
  assigns_array_slot_s USubmerged._pos 2
    (fn_body USubmerged.f_act_caught_in_whirlpool) = true /\
  assigns_array_slot_s USubmerged._pos 1
    (fn_body USubmerged.f_check_common_submerged_cancels) = true.

Theorem submerged_position_writer_source_shape_us :
  submerged_position_writer_source_shape_us_claim.
Proof.
  unfold submerged_position_writer_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition submerged_position_writer_source_shape_jp_claim : Prop :=
  calls_ident_s JSubmerged._vec3f_copy
    (fn_body JSubmerged.f_perform_water_full_step) = true /\
  calls_ident_s JSubmerged._vec3f_set
    (fn_body JSubmerged.f_perform_water_full_step) = true /\
  assigns_array_slot_s JSubmerged._pos 0
    (fn_body JSubmerged.f_act_caught_in_whirlpool) = true /\
  assigns_array_slot_s JSubmerged._pos 1
    (fn_body JSubmerged.f_act_caught_in_whirlpool) = true /\
  assigns_array_slot_s JSubmerged._pos 2
    (fn_body JSubmerged.f_act_caught_in_whirlpool) = true /\
  assigns_array_slot_s JSubmerged._pos 1
    (fn_body JSubmerged.f_check_common_submerged_cancels) = true.

Theorem submerged_position_writer_source_shape_jp :
  submerged_position_writer_source_shape_jp_claim.
Proof.
  unfold submerged_position_writer_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(* The Eyerok loop facts are likewise source-shape facts only.  The archived
   height kernel's Clight-to-route refinement premise remains unproved. *)
Definition eyerok_lifecycle_source_shape_us_claim : Prop :=
  calls_ident_s UEye._eyerok_hand_check_attacked
    (fn_body UEye.f_eyerok_hand_act_show_eye) = true /\
  ident_subsequenceb
    [UEye._obj_check_attacks; UEye._cur_obj_move_standard]
    (direct_callees_s (fn_body UEye.f_bhv_eyerok_hand_loop)) = true /\
  calls_ident_s UEye._obj_explode_and_spawn_coins
    (fn_body UEye.f_eyerok_hand_act_die) = true.

Theorem eyerok_lifecycle_source_shape_us :
  eyerok_lifecycle_source_shape_us_claim.
Proof. unfold eyerok_lifecycle_source_shape_us_claim; vm_compute; repeat split. Qed.

Definition eyerok_lifecycle_source_shape_jp_claim : Prop :=
  calls_ident_s JEye._eyerok_hand_check_attacked
    (fn_body JEye.f_eyerok_hand_act_show_eye) = true /\
  ident_subsequenceb
    [JEye._obj_check_attacks; JEye._cur_obj_move_standard]
    (direct_callees_s (fn_body JEye.f_bhv_eyerok_hand_loop)) = true /\
  calls_ident_s JEye._obj_explode_and_spawn_coins
    (fn_body JEye.f_eyerok_hand_act_die) = true.

Theorem eyerok_lifecycle_source_shape_jp :
  eyerok_lifecycle_source_shape_jp_claim.
Proof. unfold eyerok_lifecycle_source_shape_jp_claim; vm_compute; repeat split. Qed.

(* Exact consecutive area-2 airborne-warp object records in level_ssl_entry.
   The packed integer words are the preprocessed OBJECT macro representation:
   lower node 0x0A at (0,300,6451), then upper node 0x14 at
   (0,5500,256), both with yaw 180 and bhvAirborneWarp. *)
Definition ssl_area2_entry_objects_us : list init_data :=
  [ Init_int32 (Int.repr 605560576);
    Init_int32 (Int.repr 300);
    Init_int32 (Int.repr 422772736);
    Init_int32 (Int.repr 11796480);
    Init_int32 (Int.repr 655360);
    Init_addrof USS._bhvAirborneWarp (Ptrofs.repr 0);
    Init_int32 (Int.repr 605560576);
    Init_int32 (Int.repr 5500);
    Init_int32 (Int.repr 16777216);
    Init_int32 (Int.repr 11796480);
    Init_int32 (Int.repr 1310720);
    Init_addrof USS._bhvAirborneWarp (Ptrofs.repr 0) ].

Definition ssl_area2_entry_objects_jp : list init_data :=
  [ Init_int32 (Int.repr 605560576);
    Init_int32 (Int.repr 300);
    Init_int32 (Int.repr 422772736);
    Init_int32 (Int.repr 11796480);
    Init_int32 (Int.repr 655360);
    Init_addrof JSS._bhvAirborneWarp (Ptrofs.repr 0);
    Init_int32 (Int.repr 605560576);
    Init_int32 (Int.repr 5500);
    Init_int32 (Int.repr 16777216);
    Init_int32 (Int.repr 11796480);
    Init_int32 (Int.repr 1310720);
    Init_addrof JSS._bhvAirborneWarp (Ptrofs.repr 0) ].

Theorem ssl_area2_entry_objects_exact_us :
  firstn 12 (skipn 110 (gvar_init USS.v_level_ssl_entry)) =
    ssl_area2_entry_objects_us.
Proof. vm_compute. reflexivity. Qed.

Theorem ssl_area2_entry_objects_exact_jp :
  firstn 12 (skipn 110 (gvar_init JSS.v_level_ssl_entry)) =
    ssl_area2_entry_objects_jp.
Proof. vm_compute. reflexivity. Qed.

Definition static_target_objects : list init_data :=
  [ Init_int32 (Int.repr 605568890);
    Init_int32 (Int.repr 32773050);
    Init_int32 (Int.repr (-32768000));
    Init_int32 (Int.repr 0);
    Init_int32 (Int.repr 33554432);
    Init_addrof USS._bhvStar (Ptrofs.repr 0);
    Init_int32 (Int.repr 605568768);
    Init_int32 (Int.repr 58983800);
    Init_int32 (Int.repr 154009600);
    Init_int32 (Int.repr 0);
    Init_int32 (Int.repr 84148224);
    Init_addrof USS._bhvHiddenStar (Ptrofs.repr 0);
    Init_int32 (Int.repr 117702656) ].

Theorem ssl_area2_static_targets_exact_us :
  gvar_init USS.v_script_func_local_5 = static_target_objects.
Proof. vm_compute. reflexivity. Qed.

Theorem ssl_area2_static_targets_exact_jp :
  gvar_init JSS.v_script_func_local_5 =
  [ Init_int32 (Int.repr 605568890);
    Init_int32 (Int.repr 32773050);
    Init_int32 (Int.repr (-32768000));
    Init_int32 (Int.repr 0);
    Init_int32 (Int.repr 33554432);
    Init_addrof JSS._bhvStar (Ptrofs.repr 0);
    Init_int32 (Int.repr 605568768);
    Init_int32 (Int.repr 58983800);
    Init_int32 (Int.repr 154009600);
    Init_int32 (Int.repr 0);
    Init_int32 (Int.repr 84148224);
    Init_addrof JSS._bhvHiddenStar (Ptrofs.repr 0);
    Init_int32 (Int.repr 117702656) ].
Proof. vm_compute. reflexivity. Qed.

Definition expected_hidden_triggers : list (list Z) :=
  [ [45; -260; 2940; -600; 0];
    [45; 260; 1967; -600; 0];
    [45; -1940; 1229; -600; 0];
    [45; -1940; 1229; 2320; 0];
    [45; 260; 3913; -600; 0] ].

Theorem ssl_area2_hidden_triggers_exact_us :
  records_with_tag 45 (gvar_init UAM.v_ssl_seg7_area_2_macro_objs) =
  expected_hidden_triggers.
Proof. vm_compute. reflexivity. Qed.

Theorem ssl_area2_hidden_triggers_exact_jp :
  records_with_tag 45 (gvar_init JAM.v_ssl_seg7_area_2_macro_objs) =
  expected_hidden_triggers.
Proof. vm_compute. reflexivity. Qed.

(** Additional imported-unit closure receipts.

    These facts make previously uncovered retail bodies visible to the proof.
    They remain decidable facts about generated Clight syntax and initializers;
    none by itself proves that a callback executes, that two generated
    functions share a live memory object, or that an imported C pointer/integer
    conversion agrees with the target compiler outside its defined range. *)

Definition bhv_mario_initializer_prefix_us : list init_data :=
  [ Init_int32 (Int.repr 0);
    Init_int32 (Int.repr 268763136);
    Init_int32 (Int.repr 285278464);
    Init_int32 (Int.repr 285409281);
    Init_int32 (Int.repr 587202560);
    Init_int32 (Int.repr 2424992);
    Init_int32 (Int.repr 134217728) ].

Definition bhv_mario_initializer_prefix_jp : list init_data :=
  [ Init_int32 (Int.repr 0);
    Init_int32 (Int.repr 268763136);
    Init_int32 (Int.repr 285278464);
    Init_int32 (Int.repr 285409281);
    Init_int32 (Int.repr 587202560);
    Init_int32 (Int.repr 2424992);
    Init_int32 (Int.repr 134217728) ].

(** The third word is the packed [OR_INT(oFlags, 0x100)] behavior command:
    opcode 0x11, raw-data field 1, payload 0x100.  Its payload has bit zero
    clear.  The arithmetic theorem decodes the pinned word; connecting that
    command to a particular live object's [objFlags] load still requires the
    behavior-interpreter execution refinement. *)
Theorem bhv_mario_o_flags_command_arithmetic :
  285278464 = 17 * 2 ^ 24 + 1 * 2 ^ 16 + 256 /\
  Z.land 256 1 = 0 /\
  Z.testbit 256 0 = false.
Proof. vm_compute. repeat split. Qed.

Definition bhv_mario_flag_and_callbacks_source_shape_us_claim : Prop :=
  firstn 7 (gvar_init UBD.v_bhvMario) =
    bhv_mario_initializer_prefix_us /\
  initializer_addrof_subsequenceb
    [UBD._try_print_debug_mario_level_info;
     UBD._bhv_mario_update;
     UBD._try_do_mario_debug_object_spawn]
    (gvar_init UBD.v_bhvMario) = true /\
  contains_temp_bit_guarded_call_s
    UBS._objFlags 0 UBS._obj_update_gfx_pos_and_angle
    (fn_body UBS.f_cur_obj_update) = true.

Theorem bhv_mario_flag_and_callbacks_source_shape_us :
  bhv_mario_flag_and_callbacks_source_shape_us_claim.
Proof.
  unfold bhv_mario_flag_and_callbacks_source_shape_us_claim,
    bhv_mario_initializer_prefix_us.
  vm_compute. repeat split.
Qed.

Definition bhv_mario_flag_and_callbacks_source_shape_jp_claim : Prop :=
  firstn 7 (gvar_init JBD.v_bhvMario) =
    bhv_mario_initializer_prefix_jp /\
  initializer_addrof_subsequenceb
    [JBD._try_print_debug_mario_level_info;
     JBD._bhv_mario_update;
     JBD._try_do_mario_debug_object_spawn]
    (gvar_init JBD.v_bhvMario) = true /\
  contains_temp_bit_guarded_call_s
    JBS._objFlags 0 JBS._obj_update_gfx_pos_and_angle
    (fn_body JBS.f_cur_obj_update) = true.

Theorem bhv_mario_flag_and_callbacks_source_shape_jp :
  bhv_mario_flag_and_callbacks_source_shape_jp_claim.
Proof.
  unfold bhv_mario_flag_and_callbacks_source_shape_jp_claim,
    bhv_mario_initializer_prefix_jp.
  vm_compute. repeat split.
Qed.

(** [init_mario] writes the entry-local timer/history/depth fields.  Spawn
    type 0x12 selects the exact no-spin-airborne action/argument pair, and
    [set_mario_action] contains the action-state reset and argument store.
    This is the source chain needed by a later live-memory theorem; it is not
    that theorem. *)
Definition mario_entry_field_reset_source_shape_us_claim : Prop :=
  calls_ident_s ULU._init_mario
    (fn_body ULU.f_init_mario_after_warp) = true /\
  calls_ident_s ULU._set_mario_initial_action
    (fn_body ULU.f_init_mario_after_warp) = true /\
  switch_case_calls_ident_with_two_int_literals_s
    18 ULU._set_mario_action 6450 0
    (fn_body ULU.f_set_mario_initial_action) = true /\
  assigns_field_int_constant_s UMI._actionState 0
    (fn_body UMI.f_set_mario_action) = true /\
  assigns_field_int_constant_s UMI._actionTimer 0
    (fn_body UMI.f_set_mario_action) = true /\
  assigns_field_named_s UMI._actionArg
    (fn_body UMI.f_set_mario_action) = true /\
  assigns_field_int_constant_s UMI._actionTimer 0
    (fn_body UMI.f_init_mario) = true /\
  assigns_field_int_constant_s UMI._framesSinceA 255
    (fn_body UMI.f_init_mario) = true /\
  assigns_field_int_constant_s UMI._framesSinceB 255
    (fn_body UMI.f_init_mario) = true /\
  assigns_field_float32_constant_s UMI._forwardVel 0
    (fn_body UMI.f_init_mario) = true /\
  assigns_field_float32_constant_s UMI._quicksandDepth 0
    (fn_body UMI.f_init_mario) = true.

Theorem mario_entry_field_reset_source_shape_us :
  mario_entry_field_reset_source_shape_us_claim.
Proof.
  unfold mario_entry_field_reset_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition mario_entry_field_reset_source_shape_jp_claim : Prop :=
  calls_ident_s JLU._init_mario
    (fn_body JLU.f_init_mario_after_warp) = true /\
  calls_ident_s JLU._set_mario_initial_action
    (fn_body JLU.f_init_mario_after_warp) = true /\
  switch_case_calls_ident_with_two_int_literals_s
    18 JLU._set_mario_action 6450 0
    (fn_body JLU.f_set_mario_initial_action) = true /\
  assigns_field_int_constant_s JMI._actionState 0
    (fn_body JMI.f_set_mario_action) = true /\
  assigns_field_int_constant_s JMI._actionTimer 0
    (fn_body JMI.f_set_mario_action) = true /\
  assigns_field_named_s JMI._actionArg
    (fn_body JMI.f_set_mario_action) = true /\
  assigns_field_int_constant_s JMI._actionTimer 0
    (fn_body JMI.f_init_mario) = true /\
  assigns_field_int_constant_s JMI._framesSinceA 255
    (fn_body JMI.f_init_mario) = true /\
  assigns_field_int_constant_s JMI._framesSinceB 255
    (fn_body JMI.f_init_mario) = true /\
  assigns_field_float32_constant_s JMI._forwardVel 0
    (fn_body JMI.f_init_mario) = true /\
  assigns_field_float32_constant_s JMI._quicksandDepth 0
    (fn_body JMI.f_init_mario) = true.

Theorem mario_entry_field_reset_source_shape_jp :
  mario_entry_field_reset_source_shape_jp_claim.
Proof.
  unfold mario_entry_field_reset_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** The graph-node SpawnInfo initializer copies all three start-position
    components into graphical position and clears [throwMatrix].  The raw
    Mario-object position writes remain covered by
    [mario_entry_coordinate_sync_source_shape_*]. *)
Definition graph_spawninfo_position_source_shape_us_claim : Prop :=
  calls_ident_s UGraph._vec3f_set
    (fn_body UGraph.f_geo_obj_init_spawninfo) = true /\
  assigns_array_slot_s UGraph._pos 0
    (fn_body UGraph.f_geo_obj_init_spawninfo) = true /\
  assigns_array_slot_s UGraph._pos 1
    (fn_body UGraph.f_geo_obj_init_spawninfo) = true /\
  assigns_array_slot_s UGraph._pos 2
    (fn_body UGraph.f_geo_obj_init_spawninfo) = true /\
  assigns_field_null_pointer_s UGraph._throwMatrix
    (fn_body UGraph.f_geo_obj_init_spawninfo) = true.

Theorem graph_spawninfo_position_source_shape_us :
  graph_spawninfo_position_source_shape_us_claim.
Proof.
  unfold graph_spawninfo_position_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition graph_spawninfo_position_source_shape_jp_claim : Prop :=
  calls_ident_s JGraph._vec3f_set
    (fn_body JGraph.f_geo_obj_init_spawninfo) = true /\
  assigns_array_slot_s JGraph._pos 0
    (fn_body JGraph.f_geo_obj_init_spawninfo) = true /\
  assigns_array_slot_s JGraph._pos 1
    (fn_body JGraph.f_geo_obj_init_spawninfo) = true /\
  assigns_array_slot_s JGraph._pos 2
    (fn_body JGraph.f_geo_obj_init_spawninfo) = true /\
  assigns_field_null_pointer_s JGraph._throwMatrix
    (fn_body JGraph.f_geo_obj_init_spawninfo) = true.

Theorem graph_spawninfo_position_source_shape_jp :
  graph_spawninfo_position_source_shape_jp_claim.
Proof.
  unfold graph_spawninfo_position_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** The level-script object command allocates and links a [SpawnInfo], writes
    its position/angle/behavior/model payload, and updates the area's spawn
    head.  In the generated pinned source it stores the behavior-script word
    directly; this body does not itself call [segmented_to_virtual]. *)
Definition level_place_object_source_shape_us_claim : Prop :=
  calls_ident_s ULS._alloc_only_pool_alloc
    (fn_body ULS.f_level_cmd_place_object) = true /\
  calls_ident_s ULS._segmented_to_virtual
    (fn_body ULS.f_level_cmd_place_object) = false /\
  assigns_through_field_s ULS._startPos
    (fn_body ULS.f_level_cmd_place_object) = true /\
  assigns_through_field_s ULS._startAngle
    (fn_body ULS.f_level_cmd_place_object) = true /\
  assigns_through_field_s ULS._behaviorArg
    (fn_body ULS.f_level_cmd_place_object) = true /\
  assigns_through_field_s ULS._behaviorScript
    (fn_body ULS.f_level_cmd_place_object) = true /\
  assigns_through_field_s ULS._model
    (fn_body ULS.f_level_cmd_place_object) = true /\
  assigns_through_field_s ULS._next
    (fn_body ULS.f_level_cmd_place_object) = true /\
  statement_mentions_ident_s ULS._objectSpawnInfos
    (fn_body ULS.f_level_cmd_place_object) = true.

Theorem level_place_object_source_shape_us :
  level_place_object_source_shape_us_claim.
Proof.
  unfold level_place_object_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition level_place_object_source_shape_jp_claim : Prop :=
  calls_ident_s JLS._alloc_only_pool_alloc
    (fn_body JLS.f_level_cmd_place_object) = true /\
  calls_ident_s JLS._segmented_to_virtual
    (fn_body JLS.f_level_cmd_place_object) = false /\
  assigns_through_field_s JLS._startPos
    (fn_body JLS.f_level_cmd_place_object) = true /\
  assigns_through_field_s JLS._startAngle
    (fn_body JLS.f_level_cmd_place_object) = true /\
  assigns_through_field_s JLS._behaviorArg
    (fn_body JLS.f_level_cmd_place_object) = true /\
  assigns_through_field_s JLS._behaviorScript
    (fn_body JLS.f_level_cmd_place_object) = true /\
  assigns_through_field_s JLS._model
    (fn_body JLS.f_level_cmd_place_object) = true /\
  assigns_through_field_s JLS._next
    (fn_body JLS.f_level_cmd_place_object) = true /\
  statement_mentions_ident_s JLS._objectSpawnInfos
    (fn_body JLS.f_level_cmd_place_object) = true.

Theorem level_place_object_source_shape_jp :
  level_place_object_source_shape_jp_claim.
Proof.
  unfold level_place_object_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** The debug callback is a real behavior-script callback in these builds.  It
    reads the page/config/button state and contains relative-spawn calls.
    Clean-entry writer closure must prove the enabling state unreachable or
    disabled; importing it does not justify silently dropping it. *)
Definition mario_debug_spawn_source_shape_us_claim : Prop :=
  statement_mentions_ident_s UDebug._sDebugPage
    (fn_body UDebug.f_try_do_mario_debug_object_spawn) = true /\
  statement_mentions_ident_s UDebug._gDebugInfo
    (fn_body UDebug.f_try_do_mario_debug_object_spawn) = true /\
  statement_mentions_ident_s UDebug._buttonPressed
    (fn_body UDebug.f_try_do_mario_debug_object_spawn) = true /\
  calls_ident_s UDebug._spawn_object_relative
    (fn_body UDebug.f_try_do_mario_debug_object_spawn) = true.

Theorem mario_debug_spawn_source_shape_us :
  mario_debug_spawn_source_shape_us_claim.
Proof.
  unfold mario_debug_spawn_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition mario_debug_spawn_source_shape_jp_claim : Prop :=
  statement_mentions_ident_s JDebug._sDebugPage
    (fn_body JDebug.f_try_do_mario_debug_object_spawn) = true /\
  statement_mentions_ident_s JDebug._gDebugInfo
    (fn_body JDebug.f_try_do_mario_debug_object_spawn) = true /\
  statement_mentions_ident_s JDebug._buttonPressed
    (fn_body JDebug.f_try_do_mario_debug_object_spawn) = true /\
  calls_ident_s JDebug._spawn_object_relative
    (fn_body JDebug.f_try_do_mario_debug_object_spawn) = true.

Theorem mario_debug_spawn_source_shape_jp :
  mario_debug_spawn_source_shape_jp_claim.
Proof.
  unfold mario_debug_spawn_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** The segmented-address helpers are imported rather than replaced by a
    handwritten mathematical function.  These receipts preserve the exact
    masks/shifts/table dependency visible in Clight.  The pointer-to-32-bit
    integer casts are implementation-dependent C and still need a target
    compiled-behavior refinement before executable address claims use them. *)
Definition segmented_address_helpers_source_shape_us_claim : Prop :=
  statement_mentions_ident_s UMemory._sSegmentTable
    (fn_body UMemory.f_segmented_to_virtual) = true /\
  statement_mentions_int_s 24
    (fn_body UMemory.f_segmented_to_virtual) = true /\
  statement_mentions_int_s 16777215
    (fn_body UMemory.f_segmented_to_virtual) = true /\
  statement_mentions_int_s (-2147483648)
    (fn_body UMemory.f_segmented_to_virtual) = true /\
  statement_mentions_ident_s UMemory._sSegmentTable
    (fn_body UMemory.f_virtual_to_segmented) = true /\
  statement_mentions_int_s 24
    (fn_body UMemory.f_virtual_to_segmented) = true /\
  statement_mentions_int_s 536870911
    (fn_body UMemory.f_virtual_to_segmented) = true.

Theorem segmented_address_helpers_source_shape_us :
  segmented_address_helpers_source_shape_us_claim.
Proof.
  unfold segmented_address_helpers_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition segmented_address_helpers_source_shape_jp_claim : Prop :=
  statement_mentions_ident_s JMemory._sSegmentTable
    (fn_body JMemory.f_segmented_to_virtual) = true /\
  statement_mentions_int_s 24
    (fn_body JMemory.f_segmented_to_virtual) = true /\
  statement_mentions_int_s 16777215
    (fn_body JMemory.f_segmented_to_virtual) = true /\
  statement_mentions_int_s (-2147483648)
    (fn_body JMemory.f_segmented_to_virtual) = true /\
  statement_mentions_ident_s JMemory._sSegmentTable
    (fn_body JMemory.f_virtual_to_segmented) = true /\
  statement_mentions_int_s 24
    (fn_body JMemory.f_virtual_to_segmented) = true /\
  statement_mentions_int_s 536870911
    (fn_body JMemory.f_virtual_to_segmented) = true.

Theorem segmented_address_helpers_source_shape_jp :
  segmented_address_helpers_source_shape_jp_claim.
Proof.
  unfold segmented_address_helpers_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** The newly imported Mario renderer contains a position-copying mirror
    callback, but the destination is the distinct [gMirrorMario] global.
    These syntax anchors inventory the callback; a memory/non-alias theorem,
    plus SSL render-context reachability, is still required to exclude it as a
    writer of the live Mario object's graphical position. *)
Definition mario_misc_graphics_writer_inventory_source_shape_us_claim : Prop :=
  statement_mentions_ident_s UMisc._gMirrorMario
    (fn_body UMisc.f_geo_render_mirror_mario) = true /\
  statement_mentions_ident_s UMisc._gMarioStates
    (fn_body UMisc.f_geo_render_mirror_mario) = true /\
  calls_ident_s UMisc._vec3f_copy
    (fn_body UMisc.f_geo_render_mirror_mario) = true /\
  calls_ident_s UMisc._get_pos_from_transform_mtx
    (fn_body UMisc.f_geo_switch_mario_hand_grab_pos) = true.

Theorem mario_misc_graphics_writer_inventory_source_shape_us :
  mario_misc_graphics_writer_inventory_source_shape_us_claim.
Proof.
  unfold mario_misc_graphics_writer_inventory_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition mario_misc_graphics_writer_inventory_source_shape_jp_claim : Prop :=
  statement_mentions_ident_s JMisc._gMirrorMario
    (fn_body JMisc.f_geo_render_mirror_mario) = true /\
  statement_mentions_ident_s JMisc._gMarioStates
    (fn_body JMisc.f_geo_render_mirror_mario) = true /\
  calls_ident_s JMisc._vec3f_copy
    (fn_body JMisc.f_geo_render_mirror_mario) = true /\
  calls_ident_s JMisc._get_pos_from_transform_mtx
    (fn_body JMisc.f_geo_switch_mario_hand_grab_pos) = true.

Theorem mario_misc_graphics_writer_inventory_source_shape_jp :
  mario_misc_graphics_writer_inventory_source_shape_jp_claim.
Proof.
  unfold mario_misc_graphics_writer_inventory_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** Wall resolution writes through caller-supplied coordinate pointers.  The
    audited air quarter-step calls it on a local [nextPos] buffer, later
    mentions MarioState [pos], and never mentions [gfx] in that body.  These
    facts exclude a syntactically direct graphics-only wall writer in the two
    named imported bodies; they do not prove exact call arguments, pointer
    disjointness, every caller, later copies, or actual path execution. *)
Definition wall_position_writer_source_shape_us_claim : Prop :=
  assigns_through_dereferenced_temp_s USurface._xPtr
    (fn_body USurface.f_f32_find_wall_collision) = true /\
  assigns_through_dereferenced_temp_s USurface._yPtr
    (fn_body USurface.f_f32_find_wall_collision) = true /\
  assigns_through_dereferenced_temp_s USurface._zPtr
    (fn_body USurface.f_f32_find_wall_collision) = true /\
  assigns_through_field_s USurface._y
    (fn_body USurface.f_find_wall_collisions_from_list) = false /\
  statement_mentions_ident_s USurface._gfx
    (fn_body USurface.f_f32_find_wall_collision) = false /\
  calls_ident_s UStep._resolve_and_return_wall_collisions
    (fn_body UStep.f_perform_air_quarter_step) = true /\
  statement_mentions_ident_s UStep._pos
    (fn_body UStep.f_perform_air_quarter_step) = true /\
  statement_mentions_ident_s UStep._gfx
    (fn_body UStep.f_perform_air_quarter_step) = false /\
  calls_ident_s UI._f32_find_wall_collision
    (fn_body UI.f_push_mario_out_of_object) = true /\
  statement_mentions_ident_s UI._pos
    (fn_body UI.f_push_mario_out_of_object) = true /\
  statement_mentions_ident_s UI._gfx
    (fn_body UI.f_push_mario_out_of_object) = false.

Theorem wall_position_writer_source_shape_us :
  wall_position_writer_source_shape_us_claim.
Proof.
  unfold wall_position_writer_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition wall_position_writer_source_shape_jp_claim : Prop :=
  assigns_through_dereferenced_temp_s JSurface._xPtr
    (fn_body JSurface.f_f32_find_wall_collision) = true /\
  assigns_through_dereferenced_temp_s JSurface._yPtr
    (fn_body JSurface.f_f32_find_wall_collision) = true /\
  assigns_through_dereferenced_temp_s JSurface._zPtr
    (fn_body JSurface.f_f32_find_wall_collision) = true /\
  assigns_through_field_s JSurface._y
    (fn_body JSurface.f_find_wall_collisions_from_list) = false /\
  statement_mentions_ident_s JSurface._gfx
    (fn_body JSurface.f_f32_find_wall_collision) = false /\
  calls_ident_s JStep._resolve_and_return_wall_collisions
    (fn_body JStep.f_perform_air_quarter_step) = true /\
  statement_mentions_ident_s JStep._pos
    (fn_body JStep.f_perform_air_quarter_step) = true /\
  statement_mentions_ident_s JStep._gfx
    (fn_body JStep.f_perform_air_quarter_step) = false /\
  calls_ident_s JI._f32_find_wall_collision
    (fn_body JI.f_push_mario_out_of_object) = true /\
  statement_mentions_ident_s JI._pos
    (fn_body JI.f_push_mario_out_of_object) = true /\
  statement_mentions_ident_s JI._gfx
    (fn_body JI.f_push_mario_out_of_object) = false.

Theorem wall_position_writer_source_shape_jp :
  wall_position_writer_source_shape_jp_claim.
Proof.
  unfold wall_position_writer_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** Source-syntax receipts for the Goomba-raising investigation.  These
    statements deliberately expose lexical calls, constants, initializers,
    and direct field/slot accesses.  They do not prove that a linked execution
    follows the idealized H/F/R cycle in [GoombaRaising.v]. *)

Definition regular_goomba_property_prefix : list init_data :=
  [Init_float32 (Float32.of_bits (Int.repr 1069547520));
   Init_int32 (Int.repr 1348513921);
   Init_int16 (Int.repr 4000);
   Init_int8 (Int.repr 1)].

Theorem regular_goomba_property_prefix_exact_us :
  firstn 4 (gvar_init UEye.v_sGoombaProperties) =
    regular_goomba_property_prefix.
Proof. vm_compute. reflexivity. Qed.

Theorem regular_goomba_property_prefix_exact_jp :
  firstn 4 (gvar_init JEye.v_sGoombaProperties) =
    regular_goomba_property_prefix.
Proof. vm_compute. reflexivity. Qed.

Definition goomba_state_machine_source_shape_us_claim : Prop :=
  initializer_addrof_subsequenceb
    [UBD._bhv_goomba_init; UBD._bhv_goomba_update]
    (gvar_init UBD.v_bhvGoomba) = true /\
  calls_ident_s UEye._goomba_begin_jump
    (fn_body UEye.f_goomba_act_attacked_mario) = true /\
  switch_case_calls_ident_s 1 UEye._goomba_act_attacked_mario
    (fn_body UEye.f_bhv_goomba_update) = true /\
  switch_case_calls_ident_s 2 UEye._goomba_act_jump
    (fn_body UEye.f_bhv_goomba_update) = true /\
  assigns_array_slot_int_constant_s UEye._asS32 49 2
    (fn_body UEye.f_goomba_begin_jump) = true /\
  statement_mentions_array_slot_s UEye._asU32 25
    (fn_body UEye.f_goomba_act_jump) = true /\
  assigns_array_slot_int_constant_s UEye._asS32 49 0
    (fn_body UEye.f_goomba_act_jump) = true /\
  statement_mentions_float32_bits_s 1112014848
    (fn_body UEye.f_goomba_begin_jump) = true /\
  statement_mentions_float32_bits_s 1077936128
    (fn_body UEye.f_goomba_begin_jump) = true /\
  statement_mentions_float32_bits_s 1090519040
    (fn_body UEye.f_bhv_goomba_init) = true /\
  statement_mentions_float32_bits_s 1077936128
    (fn_body UEye.f_bhv_goomba_init) = true /\
  ident_subsequenceb
    [UEye._obj_update_standard_actions;
     UEye._cur_obj_update_floor_and_walls;
     UEye._goomba_act_walk;
     UEye._goomba_act_attacked_mario;
     UEye._goomba_act_jump;
     UEye._obj_handle_attacks;
     UEye._cur_obj_move_standard]
    (direct_callees_s (fn_body UEye.f_bhv_goomba_update)) = true /\
  statement_mentions_ident_s UOH._activeFlags
    (fn_body UOH.f_cur_obj_move_standard) = true /\
  calls_ident_s UOH._cur_obj_move_y
    (fn_body UOH.f_cur_obj_move_standard) = true /\
  calls_ident_s UBS._dist_between_objects
    (fn_body UBS.f_cur_obj_update) = true /\
  assigns_field_named_s UBS._activeFlags
    (fn_body UBS.f_cur_obj_update) = true.

Theorem goomba_state_machine_source_shape_us :
  goomba_state_machine_source_shape_us_claim.
Proof.
  unfold goomba_state_machine_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition goomba_state_machine_source_shape_jp_claim : Prop :=
  initializer_addrof_subsequenceb
    [JBD._bhv_goomba_init; JBD._bhv_goomba_update]
    (gvar_init JBD.v_bhvGoomba) = true /\
  calls_ident_s JEye._goomba_begin_jump
    (fn_body JEye.f_goomba_act_attacked_mario) = true /\
  switch_case_calls_ident_s 1 JEye._goomba_act_attacked_mario
    (fn_body JEye.f_bhv_goomba_update) = true /\
  switch_case_calls_ident_s 2 JEye._goomba_act_jump
    (fn_body JEye.f_bhv_goomba_update) = true /\
  assigns_array_slot_int_constant_s JEye._asS32 49 2
    (fn_body JEye.f_goomba_begin_jump) = true /\
  statement_mentions_array_slot_s JEye._asU32 25
    (fn_body JEye.f_goomba_act_jump) = true /\
  assigns_array_slot_int_constant_s JEye._asS32 49 0
    (fn_body JEye.f_goomba_act_jump) = true /\
  statement_mentions_float32_bits_s 1112014848
    (fn_body JEye.f_goomba_begin_jump) = true /\
  statement_mentions_float32_bits_s 1077936128
    (fn_body JEye.f_goomba_begin_jump) = true /\
  statement_mentions_float32_bits_s 1090519040
    (fn_body JEye.f_bhv_goomba_init) = true /\
  statement_mentions_float32_bits_s 1077936128
    (fn_body JEye.f_bhv_goomba_init) = true /\
  ident_subsequenceb
    [JEye._obj_update_standard_actions;
     JEye._cur_obj_update_floor_and_walls;
     JEye._goomba_act_walk;
     JEye._goomba_act_attacked_mario;
     JEye._goomba_act_jump;
     JEye._obj_handle_attacks;
     JEye._cur_obj_move_standard]
    (direct_callees_s (fn_body JEye.f_bhv_goomba_update)) = true /\
  statement_mentions_ident_s JOH._activeFlags
    (fn_body JOH.f_cur_obj_move_standard) = true /\
  calls_ident_s JOH._cur_obj_move_y
    (fn_body JOH.f_cur_obj_move_standard) = true /\
  calls_ident_s JBS._dist_between_objects
    (fn_body JBS.f_cur_obj_update) = true /\
  assigns_field_named_s JBS._activeFlags
    (fn_body JBS.f_cur_obj_update) = true.

Theorem goomba_state_machine_source_shape_jp :
  goomba_state_machine_source_shape_jp_claim.
Proof.
  unfold goomba_state_machine_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** Player-object collision reaches the generic list-collision body; the
    caller contains literal 5, and the inspected bodies use full-float position
    raw-data slots with no direct [activeFlags] test.  The current recognizer
    does not couple that literal to the call argument, so identifying list 5 as
    the pushable list remains a pinned-source audit fact.  This is not a linked
    proof of tangibility, list membership, or spare collision capacity. *)
Definition goomba_player_collision_source_shape_us_claim : Prop :=
  calls_ident_s UOC._check_player_object_collision
    (fn_body UOC.f_detect_object_collisions) = true /\
  calls_ident_s UOC._check_collision_in_list
    (fn_body UOC.f_check_player_object_collision) = true /\
  statement_mentions_int_s 5
    (fn_body UOC.f_check_player_object_collision) = true /\
  calls_ident_s UOC._detect_object_hitbox_overlap
    (fn_body UOC.f_check_collision_in_list) = true /\
  statement_mentions_ident_s UOC._activeFlags
    (fn_body UOC.f_check_player_object_collision) = false /\
  statement_mentions_ident_s UOC._activeFlags
    (fn_body UOC.f_check_collision_in_list) = false /\
  statement_mentions_ident_s UOC._activeFlags
    (fn_body UOC.f_detect_object_hitbox_overlap) = false /\
  statement_mentions_array_slot_s UOC._asF32 6
    (fn_body UOC.f_detect_object_hitbox_overlap) = true /\
  statement_mentions_array_slot_s UOC._asF32 7
    (fn_body UOC.f_detect_object_hitbox_overlap) = true /\
  statement_mentions_array_slot_s UOC._asF32 8
    (fn_body UOC.f_detect_object_hitbox_overlap) = true /\
  statement_mentions_ident_s UOC._asS16
    (fn_body UOC.f_detect_object_hitbox_overlap) = false.

Theorem goomba_player_collision_source_shape_us :
  goomba_player_collision_source_shape_us_claim.
Proof.
  unfold goomba_player_collision_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition goomba_player_collision_source_shape_jp_claim : Prop :=
  calls_ident_s JOC._check_player_object_collision
    (fn_body JOC.f_detect_object_collisions) = true /\
  calls_ident_s JOC._check_collision_in_list
    (fn_body JOC.f_check_player_object_collision) = true /\
  statement_mentions_int_s 5
    (fn_body JOC.f_check_player_object_collision) = true /\
  calls_ident_s JOC._detect_object_hitbox_overlap
    (fn_body JOC.f_check_collision_in_list) = true /\
  statement_mentions_ident_s JOC._activeFlags
    (fn_body JOC.f_check_player_object_collision) = false /\
  statement_mentions_ident_s JOC._activeFlags
    (fn_body JOC.f_check_collision_in_list) = false /\
  statement_mentions_ident_s JOC._activeFlags
    (fn_body JOC.f_detect_object_hitbox_overlap) = false /\
  statement_mentions_array_slot_s JOC._asF32 6
    (fn_body JOC.f_detect_object_hitbox_overlap) = true /\
  statement_mentions_array_slot_s JOC._asF32 7
    (fn_body JOC.f_detect_object_hitbox_overlap) = true /\
  statement_mentions_array_slot_s JOC._asF32 8
    (fn_body JOC.f_detect_object_hitbox_overlap) = true /\
  statement_mentions_ident_s JOC._asS16
    (fn_body JOC.f_detect_object_hitbox_overlap) = false.

Theorem goomba_player_collision_source_shape_jp :
  goomba_player_collision_source_shape_jp_claim.
Proof.
  unfold goomba_player_collision_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** Spindel and moving-collision receipts.  Object-object distance and the
    collision-load gate use object raw-data float slots.  Constructed dynamic
    vertices are subsequently narrowed to [TerrainData] by the source; no
    theorem here presents the transformed surface coordinates as full-float. *)
Definition spindel_pu_station_source_shape_us_claim : Prop :=
  initializer_addrof_subsequenceb
    [UBD._bhv_spindel_init; UBD._bhv_spindel_loop;
     UBD._load_object_collision_model]
    (gvar_init UBD.v_bhvSpindel) = true /\
  assigns_array_slot_s UOB._asS32 35
    (fn_body UOB.f_bhv_spindel_loop) = true /\
  statement_mentions_int_s 1024
    (fn_body UOB.f_bhv_spindel_loop) = true /\
  statement_mentions_int_s 20
    (fn_body UOB.f_bhv_spindel_loop) = true /\
  assigns_array_slot_float32_constant_s
    USO._asF32 67 1148846080
    (fn_body USO.f_allocate_object) = true /\
  statement_mentions_array_slot_s USurfaceLoad._asF32 53
    (fn_body USurfaceLoad.f_load_object_collision_model) = true /\
  statement_mentions_array_slot_s USurfaceLoad._asF32 67
    (fn_body USurfaceLoad.f_load_object_collision_model) = true /\
  ident_subsequenceb
    [USurfaceLoad._dist_between_objects;
     USurfaceLoad._transform_object_vertices;
     USurfaceLoad._load_object_surfaces]
    (direct_callees_s
      (fn_body USurfaceLoad.f_load_object_collision_model)) = true /\
  statement_mentions_array_slot_s UOH._asF32 6
    (fn_body UOH.f_dist_between_objects) = true /\
  statement_mentions_array_slot_s UOH._asF32 7
    (fn_body UOH.f_dist_between_objects) = true /\
  statement_mentions_array_slot_s UOH._asF32 8
    (fn_body UOH.f_dist_between_objects) = true /\
  statement_mentions_ident_s UOH._asS16
    (fn_body UOH.f_dist_between_objects) = false /\
  calls_ident_s UOH._sqrtf
    (fn_body UOH.f_dist_between_objects) = true /\
  calls_ident_with_two_int_literals_s
    USurfaceLoad._obj_build_transform_from_pos_and_angle 6 18
    (fn_body USurfaceLoad.f_transform_object_vertices) = true /\
  calls_ident_s USurfaceLoad._obj_apply_scale_to_matrix
    (fn_body USurfaceLoad.f_transform_object_vertices) = true /\
  statement_contains_float32_to_s16_cast_s
    (fn_body USurfaceLoad.f_transform_object_vertices) = true.

Theorem spindel_pu_station_source_shape_us :
  spindel_pu_station_source_shape_us_claim.
Proof.
  unfold spindel_pu_station_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition spindel_pu_station_source_shape_jp_claim : Prop :=
  initializer_addrof_subsequenceb
    [JBD._bhv_spindel_init; JBD._bhv_spindel_loop;
     JBD._load_object_collision_model]
    (gvar_init JBD.v_bhvSpindel) = true /\
  assigns_array_slot_s JOB._asS32 35
    (fn_body JOB.f_bhv_spindel_loop) = true /\
  statement_mentions_int_s 1024
    (fn_body JOB.f_bhv_spindel_loop) = true /\
  statement_mentions_int_s 20
    (fn_body JOB.f_bhv_spindel_loop) = true /\
  assigns_array_slot_float32_constant_s
    JSO._asF32 67 1148846080
    (fn_body JSO.f_allocate_object) = true /\
  statement_mentions_array_slot_s JSurfaceLoad._asF32 53
    (fn_body JSurfaceLoad.f_load_object_collision_model) = true /\
  statement_mentions_array_slot_s JSurfaceLoad._asF32 67
    (fn_body JSurfaceLoad.f_load_object_collision_model) = true /\
  ident_subsequenceb
    [JSurfaceLoad._dist_between_objects;
     JSurfaceLoad._transform_object_vertices;
     JSurfaceLoad._load_object_surfaces]
    (direct_callees_s
      (fn_body JSurfaceLoad.f_load_object_collision_model)) = true /\
  statement_mentions_array_slot_s JOH._asF32 6
    (fn_body JOH.f_dist_between_objects) = true /\
  statement_mentions_array_slot_s JOH._asF32 7
    (fn_body JOH.f_dist_between_objects) = true /\
  statement_mentions_array_slot_s JOH._asF32 8
    (fn_body JOH.f_dist_between_objects) = true /\
  statement_mentions_ident_s JOH._asS16
    (fn_body JOH.f_dist_between_objects) = false /\
  calls_ident_s JOH._sqrtf
    (fn_body JOH.f_dist_between_objects) = true /\
  calls_ident_with_two_int_literals_s
    JSurfaceLoad._obj_build_transform_from_pos_and_angle 6 18
    (fn_body JSurfaceLoad.f_transform_object_vertices) = true /\
  calls_ident_s JSurfaceLoad._obj_apply_scale_to_matrix
    (fn_body JSurfaceLoad.f_transform_object_vertices) = true /\
  statement_contains_float32_to_s16_cast_s
    (fn_body JSurfaceLoad.f_transform_object_vertices) = true.

Theorem spindel_pu_station_source_shape_jp :
  spindel_pu_station_source_shape_jp_claim.
Proof.
  unfold spindel_pu_station_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** ** Turning-Part-2 animation/upwarp audit

    These facts couple the exact [18.0f] comparison to its two animation
    call arguments and record both possible local orderings.  In the ordinary
    non-stopping turning handler, the ground step precedes animation
    selection.  The finish-turning handler deliberately has the opposite
    order.  Neither syntax result claims that an early return is impossible
    or that either call executes in a linked run. *)

Definition turning_part2_selection_source_shape_us_claim : Prop :=
  field_ge_float_branch_calls_s
    UMove._forwardVel 1099956224
    UMove._set_mario_animation 188 189
    (fn_body UMove.f_act_turning_around) = true /\
  ident_subsequenceb
    [UMove._perform_ground_step; UMove._set_mario_animation]
    (direct_callees_s (fn_body UMove.f_act_turning_around)) = true /\
  calls_ident_with_int_literal_s
    UMove._set_mario_animation 189
    (fn_body UMove.f_act_finish_turning_around) = true /\
  ident_subsequenceb
    [UMove._set_mario_animation; UMove._perform_ground_step]
    (direct_callees_s
      (fn_body UMove.f_act_finish_turning_around)) = true /\
  calls_ident_s UMI._update_mario_pos_for_anim
    (fn_body UMove.f_act_turning_around) = false /\
  calls_ident_s UMI._return_mario_anim_y_translation
    (fn_body UMove.f_act_turning_around) = false /\
  calls_ident_s UMI._update_mario_pos_for_anim
    (fn_body UMove.f_act_finish_turning_around) = false /\
  calls_ident_s UMI._return_mario_anim_y_translation
    (fn_body UMove.f_act_finish_turning_around) = false.

Theorem turning_part2_selection_source_shape_us :
  turning_part2_selection_source_shape_us_claim.
Proof.
  unfold turning_part2_selection_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition turning_part2_selection_source_shape_jp_claim : Prop :=
  field_ge_float_branch_calls_s
    JMove._forwardVel 1099956224
    JMove._set_mario_animation 188 189
    (fn_body JMove.f_act_turning_around) = true /\
  ident_subsequenceb
    [JMove._perform_ground_step; JMove._set_mario_animation]
    (direct_callees_s (fn_body JMove.f_act_turning_around)) = true /\
  calls_ident_with_int_literal_s
    JMove._set_mario_animation 189
    (fn_body JMove.f_act_finish_turning_around) = true /\
  ident_subsequenceb
    [JMove._set_mario_animation; JMove._perform_ground_step]
    (direct_callees_s
      (fn_body JMove.f_act_finish_turning_around)) = true /\
  calls_ident_s JMI._update_mario_pos_for_anim
    (fn_body JMove.f_act_turning_around) = false /\
  calls_ident_s JMI._return_mario_anim_y_translation
    (fn_body JMove.f_act_turning_around) = false /\
  calls_ident_s JMI._update_mario_pos_for_anim
    (fn_body JMove.f_act_finish_turning_around) = false /\
  calls_ident_s JMI._return_mario_anim_y_translation
    (fn_body JMove.f_act_finish_turning_around) = false.

Theorem turning_part2_selection_source_shape_jp :
  turning_part2_selection_source_shape_jp_claim.
Proof.
  unfold turning_part2_selection_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** The direct assignment footprint of [set_mario_animation].  Calls are a
    separate memory-effect boundary: in particular, this does not give
    [dma_read] an unconstrained frame rule. *)
Definition set_mario_animation_footprint_source_shape_us_claim : Prop :=
  assigns_field_int_constant_s UMI._unkB0 189
    (fn_body UMI.f_init_mario_from_save_file) = true /\
  direct_callees_s (fn_body UMI.f_set_mario_animation) =
    [UMI._load_patchable_table] /\
  assigns_field_from_field_s UMI._unkB0 UMI._animYTrans
    (fn_body UMI.f_set_mario_animation) = true /\
  assigns_field_named_s UMI._animID
    (fn_body UMI.f_set_mario_animation) = true /\
  assigns_field_named_s UMI._curAnim
    (fn_body UMI.f_set_mario_animation) = true /\
  assigns_field_int_constant_s UMI._animAccel 0
    (fn_body UMI.f_set_mario_animation) = true /\
  assigns_field_named_s UMI._animFrame
    (fn_body UMI.f_set_mario_animation) = true /\
  assigns_field_named_s UMI._values
    (fn_body UMI.f_set_mario_animation) = true /\
  assigns_field_named_s UMI._index
    (fn_body UMI.f_set_mario_animation) = true /\
  assigns_array_slot_s UMI._pos 0
    (fn_body UMI.f_set_mario_animation) = false /\
  assigns_array_slot_s UMI._pos 1
    (fn_body UMI.f_set_mario_animation) = false /\
  assigns_array_slot_s UMI._pos 2
    (fn_body UMI.f_set_mario_animation) = false /\
  statement_mentions_array_slot_s UMI._rawData 6
    (fn_body UMI.f_set_mario_animation) = false /\
  statement_mentions_array_slot_s UMI._rawData 7
    (fn_body UMI.f_set_mario_animation) = false /\
  statement_mentions_array_slot_s UMI._rawData 8
    (fn_body UMI.f_set_mario_animation) = false /\
  assigns_field_named_s UMI._floor
    (fn_body UMI.f_set_mario_animation) = false /\
  calls_ident_s UMI._update_mario_pos_for_anim
    (fn_body UMI.f_set_mario_animation) = false /\
  calls_ident_s UMove._perform_ground_step
    (fn_body UMI.f_set_mario_animation) = false /\
  calls_ident_s UMI._find_floor
    (fn_body UMI.f_set_mario_animation) = false /\
  calls_ident_s UMI._level_trigger_warp
    (fn_body UMI.f_set_mario_animation) = false.

Theorem set_mario_animation_footprint_source_shape_us :
  set_mario_animation_footprint_source_shape_us_claim.
Proof.
  unfold set_mario_animation_footprint_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition set_mario_animation_footprint_source_shape_jp_claim : Prop :=
  assigns_field_int_constant_s JMI._unkB0 189
    (fn_body JMI.f_init_mario_from_save_file) = true /\
  direct_callees_s (fn_body JMI.f_set_mario_animation) =
    [JMI._load_patchable_table] /\
  assigns_field_from_field_s JMI._unkB0 JMI._animYTrans
    (fn_body JMI.f_set_mario_animation) = true /\
  assigns_field_named_s JMI._animID
    (fn_body JMI.f_set_mario_animation) = true /\
  assigns_field_named_s JMI._curAnim
    (fn_body JMI.f_set_mario_animation) = true /\
  assigns_field_int_constant_s JMI._animAccel 0
    (fn_body JMI.f_set_mario_animation) = true /\
  assigns_field_named_s JMI._animFrame
    (fn_body JMI.f_set_mario_animation) = true /\
  assigns_field_named_s JMI._values
    (fn_body JMI.f_set_mario_animation) = true /\
  assigns_field_named_s JMI._index
    (fn_body JMI.f_set_mario_animation) = true /\
  assigns_array_slot_s JMI._pos 0
    (fn_body JMI.f_set_mario_animation) = false /\
  assigns_array_slot_s JMI._pos 1
    (fn_body JMI.f_set_mario_animation) = false /\
  assigns_array_slot_s JMI._pos 2
    (fn_body JMI.f_set_mario_animation) = false /\
  statement_mentions_array_slot_s JMI._rawData 6
    (fn_body JMI.f_set_mario_animation) = false /\
  statement_mentions_array_slot_s JMI._rawData 7
    (fn_body JMI.f_set_mario_animation) = false /\
  statement_mentions_array_slot_s JMI._rawData 8
    (fn_body JMI.f_set_mario_animation) = false /\
  assigns_field_named_s JMI._floor
    (fn_body JMI.f_set_mario_animation) = false /\
  calls_ident_s JMI._update_mario_pos_for_anim
    (fn_body JMI.f_set_mario_animation) = false /\
  calls_ident_s JMove._perform_ground_step
    (fn_body JMI.f_set_mario_animation) = false /\
  calls_ident_s JMI._find_floor
    (fn_body JMI.f_set_mario_animation) = false /\
  calls_ident_s JMI._level_trigger_warp
    (fn_body JMI.f_set_mario_animation) = false.

Theorem set_mario_animation_footprint_source_shape_jp :
  set_mario_animation_footprint_source_shape_jp_claim.
Proof.
  unfold set_mario_animation_footprint_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** The loader's direct footprint and its sole direct callee.  The destination
    is read from [bufTarget]; proving that the 0x4000 animation allocation is
    disjoint from Mario/Object memory is deliberately a separate semantic
    obligation. *)
Definition load_patchable_table_source_shape_us_claim : Prop :=
  direct_callees_s (fn_body UMemory.f_load_patchable_table) =
    [UMemory._dma_read] /\
  statement_mentions_ident_s UMemory._count
    (fn_body UMemory.f_load_patchable_table) = true /\
  statement_mentions_ident_s UMemory._offset
    (fn_body UMemory.f_load_patchable_table) = true /\
  statement_mentions_ident_s UMemory._size
    (fn_body UMemory.f_load_patchable_table) = true /\
  statement_mentions_ident_s UMemory._bufTarget
    (fn_body UMemory.f_load_patchable_table) = true /\
  assigns_field_named_s UMemory._currentAddr
    (fn_body UMemory.f_load_patchable_table) = true /\
  assigns_field_named_s UMemory._bufTarget
    (fn_body UMemory.f_load_patchable_table) = false /\
  assigns_field_named_s UMI._pos
    (fn_body UMemory.f_load_patchable_table) = false /\
  assigns_field_named_s UMI._rawData
    (fn_body UMemory.f_load_patchable_table) = false.

Theorem load_patchable_table_source_shape_us :
  load_patchable_table_source_shape_us_claim.
Proof.
  unfold load_patchable_table_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition load_patchable_table_source_shape_jp_claim : Prop :=
  direct_callees_s (fn_body JMemory.f_load_patchable_table) =
    [JMemory._dma_read] /\
  statement_mentions_ident_s JMemory._count
    (fn_body JMemory.f_load_patchable_table) = true /\
  statement_mentions_ident_s JMemory._offset
    (fn_body JMemory.f_load_patchable_table) = true /\
  statement_mentions_ident_s JMemory._size
    (fn_body JMemory.f_load_patchable_table) = true /\
  statement_mentions_ident_s JMemory._bufTarget
    (fn_body JMemory.f_load_patchable_table) = true /\
  assigns_field_named_s JMemory._currentAddr
    (fn_body JMemory.f_load_patchable_table) = true /\
  assigns_field_named_s JMemory._bufTarget
    (fn_body JMemory.f_load_patchable_table) = false /\
  assigns_field_named_s JMI._pos
    (fn_body JMemory.f_load_patchable_table) = false /\
  assigns_field_named_s JMI._rawData
    (fn_body JMemory.f_load_patchable_table) = false.

Theorem load_patchable_table_source_shape_jp :
  load_patchable_table_source_shape_jp_claim.
Proof.
  unfold load_patchable_table_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** The sole generated [animYTrans] consumer couples it to a renderer-global
    ratio.  The animated-part body then consumes that global while constructing
    matrices.  None of these inspected renderer bodies directly assigns a
    field named [pos] or any raw object-data field. *)
Definition turning_animation_renderer_source_shape_us_claim : Prop :=
  assigns_global_from_field_ratio_s
    URender._gCurrAnimTranslationMultiplier
    URender._animYTrans URender._animYTransDivisor
    (fn_body URender.f_geo_set_animation_globals) = true /\
  statement_mentions_ident_s URender._gCurrAnimTranslationMultiplier
    (fn_body URender.f_geo_process_animated_part) = true /\
  statement_mentions_ident_s URender._gCurrAnimTranslationMultiplier
    (fn_body URender.f_geo_process_shadow) = true /\
  assigns_field_named_s URender._pos
    (fn_body URender.f_geo_set_animation_globals) = false /\
  assigns_field_named_s URender._pos
    (fn_body URender.f_geo_process_animated_part) = false /\
  assigns_field_named_s URender._pos
    (fn_body URender.f_geo_process_shadow) = false /\
  assigns_field_named_s URender._pos
    (fn_body URender.f_geo_process_object) = false /\
  assigns_field_named_s URender._rawData
    (fn_body URender.f_geo_set_animation_globals) = false /\
  assigns_field_named_s URender._rawData
    (fn_body URender.f_geo_process_animated_part) = false /\
  assigns_field_named_s URender._rawData
    (fn_body URender.f_geo_process_shadow) = false /\
  assigns_field_named_s URender._rawData
    (fn_body URender.f_geo_process_object) = false.

Theorem turning_animation_renderer_source_shape_us :
  turning_animation_renderer_source_shape_us_claim.
Proof.
  unfold turning_animation_renderer_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition turning_animation_renderer_source_shape_jp_claim : Prop :=
  assigns_global_from_field_ratio_s
    JRender._gCurrAnimTranslationMultiplier
    JRender._animYTrans JRender._animYTransDivisor
    (fn_body JRender.f_geo_set_animation_globals) = true /\
  statement_mentions_ident_s JRender._gCurrAnimTranslationMultiplier
    (fn_body JRender.f_geo_process_animated_part) = true /\
  statement_mentions_ident_s JRender._gCurrAnimTranslationMultiplier
    (fn_body JRender.f_geo_process_shadow) = true /\
  assigns_field_named_s JRender._pos
    (fn_body JRender.f_geo_set_animation_globals) = false /\
  assigns_field_named_s JRender._pos
    (fn_body JRender.f_geo_process_animated_part) = false /\
  assigns_field_named_s JRender._pos
    (fn_body JRender.f_geo_process_shadow) = false /\
  assigns_field_named_s JRender._pos
    (fn_body JRender.f_geo_process_object) = false /\
  assigns_field_named_s JRender._rawData
    (fn_body JRender.f_geo_set_animation_globals) = false /\
  assigns_field_named_s JRender._rawData
    (fn_body JRender.f_geo_process_animated_part) = false /\
  assigns_field_named_s JRender._rawData
    (fn_body JRender.f_geo_process_shadow) = false /\
  assigns_field_named_s JRender._rawData
    (fn_body JRender.f_geo_process_object) = false.

Theorem turning_animation_renderer_source_shape_jp :
  turning_animation_renderer_source_shape_jp_claim.
Proof.
  unfold turning_animation_renderer_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.

(** Broad animation-to-gameplay noninterference would be false: the Mario geo
    callback writes the held-object-last-position (HOLP) from a render matrix.
    The walking path that can select turning first calls
    [mario_drop_held_object].  These are syntax anchors, not a linked proof
    that the held pointer is null at every later render callback. *)
Definition turning_animation_holp_caveat_source_shape_us_claim : Prop :=
  calls_ident_s UMisc._get_pos_from_transform_mtx
    (fn_body UMisc.f_geo_switch_mario_hand_grab_pos) = true /\
  statement_mentions_ident_s UMisc._heldObjLastPosition
    (fn_body UMisc.f_geo_switch_mario_hand_grab_pos) = true /\
  ident_subsequenceb
    [UMove._mario_drop_held_object;
     UMove._analog_stick_held_back;
     UMove._set_mario_action]
    (direct_callees_s (fn_body UMove.f_act_walking)) = true.

Theorem turning_animation_holp_caveat_source_shape_us :
  turning_animation_holp_caveat_source_shape_us_claim.
Proof.
  unfold turning_animation_holp_caveat_source_shape_us_claim.
  vm_compute. repeat split.
Qed.

Definition turning_animation_holp_caveat_source_shape_jp_claim : Prop :=
  calls_ident_s JMisc._get_pos_from_transform_mtx
    (fn_body JMisc.f_geo_switch_mario_hand_grab_pos) = true /\
  statement_mentions_ident_s JMisc._heldObjLastPosition
    (fn_body JMisc.f_geo_switch_mario_hand_grab_pos) = true /\
  ident_subsequenceb
    [JMove._mario_drop_held_object;
     JMove._analog_stick_held_back;
     JMove._set_mario_action]
    (direct_callees_s (fn_body JMove.f_act_walking)) = true.

Theorem turning_animation_holp_caveat_source_shape_jp :
  turning_animation_holp_caveat_source_shape_jp_claim.
Proof.
  unfold turning_animation_holp_caveat_source_shape_jp_claim.
  vm_compute. repeat split.
Qed.
