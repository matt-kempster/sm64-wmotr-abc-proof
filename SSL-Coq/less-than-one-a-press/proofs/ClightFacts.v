From Coq Require Import List ZArith.
From compcert Require Import AST Clight Integers.
From LessThanOneAPress.Generated Require Import
  us_game_init us_mario us_mario_actions_airborne us_mario_actions_automatic
  us_mario_actions_cutscene
  us_mario_actions_moving us_mario_actions_object us_mario_actions_stationary
  us_mario_actions_submerged us_mario_step us_interaction us_save_file us_object_collision
  us_object_list_processor us_spawn_object us_object_helpers us_obj_behaviors
  us_obj_behaviors_2 us_behavior_actions us_behavior_data us_area
  us_level_update us_platform_displacement us_surface_collision us_surface_load
  us_macro_special_objects us_ssl_script
  us_ssl_area2_macro us_ssl_collision
  jp_game_init jp_mario jp_mario_actions_airborne jp_mario_actions_automatic
  jp_mario_actions_cutscene
  jp_mario_actions_moving jp_mario_actions_object jp_mario_actions_stationary
  jp_mario_actions_submerged jp_mario_step jp_interaction jp_save_file jp_object_collision
  jp_object_list_processor jp_spawn_object jp_object_helpers jp_obj_behaviors
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
Module USO := us_spawn_object.
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
Module JSO := jp_spawn_object.
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

(* Direct inspection of the pinned C source gives the warp/top phase account:
   geometry is recomputed from displaced MarioState before interaction, a
   normal warp selects ACT_DISAPPEARED, that action snaps State Y to cached
   floor, and state/object copy and final platform query occur later.  The
   theorem below checks only path- and base-insensitive AST anchors for that
   account; it is not a Clight memory/dataflow execution theorem. *)
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
   direct-callee and literal anchors; it does not associate node 0x1E with a
   particular branch or prove that timing in Clight. *)
Theorem object_warp_delayed_lifetime_source_shape_us :
  ident_subsequenceb
    [ULU._warp_area; ULU._area_update_objects; ULU._initiate_delayed_warp]
    (direct_callees_s (fn_body ULU.f_play_mode_normal)) = true /\
  statement_mentions_int_s 20 (fn_body ULU.f_level_trigger_warp) = true /\
  calls_ident_s ULU._level_set_transition
    (fn_body ULU.f_initiate_delayed_warp) = true /\
  statement_mentions_int_s 2
    (fn_body ULU.f_initiate_delayed_warp) = true.
Proof. vm_compute. repeat split. Qed.

Theorem object_warp_delayed_lifetime_source_shape_jp :
  ident_subsequenceb
    [JLU._warp_area; JLU._area_update_objects; JLU._initiate_delayed_warp]
    (direct_callees_s (fn_body JLU.f_play_mode_normal)) = true /\
  statement_mentions_int_s 20 (fn_body JLU.f_level_trigger_warp) = true /\
  calls_ident_s JLU._level_set_transition
    (fn_body JLU.f_initiate_delayed_warp) = true /\
  statement_mentions_int_s 2
    (fn_body JLU.f_initiate_delayed_warp) = true.
Proof. vm_compute. repeat split. Qed.

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
