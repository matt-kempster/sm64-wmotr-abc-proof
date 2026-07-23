From Coq Require Import List ZArith.
From compcert Require Import AST Clight Integers.
From LessThanOneAPress.Generated Require Import
  us_game_init us_mario us_mario_actions_airborne us_mario_actions_automatic
  us_mario_actions_moving us_mario_actions_object us_mario_actions_stationary
  us_mario_step us_interaction us_save_file us_object_collision
  us_object_list_processor us_spawn_object us_object_helpers us_obj_behaviors
  us_obj_behaviors_2 us_behavior_actions us_behavior_data us_area
  us_level_update us_platform_displacement us_surface_collision
  us_macro_special_objects us_ssl_script
  us_ssl_area2_macro
  jp_game_init jp_mario jp_mario_actions_airborne jp_mario_actions_automatic
  jp_mario_actions_moving jp_mario_actions_object jp_mario_actions_stationary
  jp_mario_step jp_interaction jp_save_file jp_object_collision
  jp_object_list_processor jp_spawn_object jp_object_helpers jp_obj_behaviors
  jp_obj_behaviors_2 jp_behavior_actions jp_behavior_data jp_area
  jp_level_update jp_platform_displacement jp_surface_collision
  jp_macro_special_objects jp_ssl_script
  jp_ssl_area2_macro.
From LessThanOneAPress.Proofs Require Import ASTFacts.

Import ListNotations.
Local Open Scope Z_scope.

Module UGI := us_game_init.
Module UMI := us_mario.
Module UAir := us_mario_actions_airborne.
Module UAuto := us_mario_actions_automatic.
Module UMove := us_mario_actions_moving.
Module UObjectActions := us_mario_actions_object.
Module UStationary := us_mario_actions_stationary.
Module UStep := us_mario_step.
Module UI := us_interaction.
Module USF := us_save_file.
Module UOC := us_object_collision.
Module UOL := us_object_list_processor.
Module USO := us_spawn_object.
Module UOB := us_obj_behaviors.
Module UEye := us_obj_behaviors_2.
Module UBA := us_behavior_actions.
Module UAR := us_area.
Module ULU := us_level_update.
Module UPD := us_platform_displacement.
Module UMS := us_macro_special_objects.
Module USS := us_ssl_script.
Module UAM := us_ssl_area2_macro.

Module JGI := jp_game_init.
Module JMI := jp_mario.
Module JAir := jp_mario_actions_airborne.
Module JAuto := jp_mario_actions_automatic.
Module JMove := jp_mario_actions_moving.
Module JObjectActions := jp_mario_actions_object.
Module JStationary := jp_mario_actions_stationary.
Module JStep := jp_mario_step.
Module JI := jp_interaction.
Module JSF := jp_save_file.
Module JOC := jp_object_collision.
Module JOL := jp_object_list_processor.
Module JSO := jp_spawn_object.
Module JOB := jp_obj_behaviors.
Module JEye := jp_obj_behaviors_2.
Module JBA := jp_behavior_actions.
Module JAR := jp_area.
Module JLU := jp_level_update.
Module JPD := jp_platform_displacement.
Module JMS := jp_macro_special_objects.
Module JSS := jp_ssl_script.
Module JAM := jp_ssl_area2_macro.

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
    [UOL._apply_mario_platform_displacement;
     UOL._detect_object_collisions;
     UOL._update_non_terrain_objects;
     UOL._unload_deactivated_objects;
     UOL._update_mario_platform]
    (direct_callees_s (fn_body UOL.f_update_objects)) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem update_objects_direct_callee_order_jp :
  ident_subsequenceb
    [JOL._apply_mario_platform_displacement;
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
Definition float32_one_hundred_bits : Z := 1120403456.
Definition act_soft_bonk_bits : Z := 16910518.
Definition act_top_of_pole_jump_bits : Z := 50333837.

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
