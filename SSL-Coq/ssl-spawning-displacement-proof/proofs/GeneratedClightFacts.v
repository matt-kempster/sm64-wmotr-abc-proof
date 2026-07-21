From Coq Require Import List PArith.BinPos String ZArith.
From compcert Require Import AST Clight Clightdefs.
From SSLSpawning.Generated Require Import
  jp_area jp_level_update jp_level_script jp_ssl_script
  jp_ssl_area1_macro jp_ssl_area2_macro jp_behavior_data
  jp_object_list_processor jp_platform_displacement jp_spawn_object
  jp_obj_behaviors jp_behavior_actions jp_mario jp_interaction
  jp_object_helpers jp_mario_actions_object jp_mario_actions_cutscene
  jp_mario_actions_submerged.
From SSLSpawning.Proofs Require Import ASTFacts.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope string_scope.
Local Open Scope clight_scope.

Module O := jp_object_list_processor.
Module P := jp_platform_displacement.
Module S := jp_spawn_object.
Module B := jp_obj_behaviors.
Module A := jp_area.
Module L := jp_level_update.
Module LS := jp_level_script.
Module SSL := jp_ssl_script.
Module M1 := jp_ssl_area1_macro.
Module M2 := jp_ssl_area2_macro.
Module BD := jp_behavior_data.
Module BA := jp_behavior_actions.
Module MJ := jp_mario.
Module IX := jp_interaction.
Module OH := jp_object_helpers.
Module MAO := jp_mario_actions_object.
Module MAC := jp_mario_actions_cutscene.
Module MAS := jp_mario_actions_submerged.

Definition id_clear_mario_platform : ident := $"clear_mario_platform".

Theorem generated_spawn_objects_from_info_jp_has_no_clear_call :
  calls_ident_s id_clear_mario_platform
    (fn_body O.f_spawn_objects_from_info) = false.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_platform_displacement_jp_has_no_clear_definition :
  existsb
    (fun definition => Pos.eqb (fst definition) id_clear_mario_platform)
    P.global_definitions = false.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_apply_mario_platform_displacement_reads_gMarioPlatform :
  statement_mentions_ident_s P._gMarioPlatform
    (fn_body P.f_apply_mario_platform_displacement) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_apply_mario_platform_displacement_calls_platform_displacement :
  calls_ident_s P._apply_platform_displacement
    (fn_body P.f_apply_mario_platform_displacement) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_apply_mario_platform_displacement_does_not_check_activeFlags :
  statement_mentions_ident_s P._activeFlags
    (fn_body P.f_apply_mario_platform_displacement) = false.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_apply_mario_platform_displacement_does_not_check_behavior :
  statement_mentions_ident_s P._behavior
    (fn_body P.f_apply_mario_platform_displacement) = false.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_apply_mario_platform_displacement_does_not_check_collisionData :
  statement_mentions_ident_s P._collisionData
    (fn_body P.f_apply_mario_platform_displacement) = false.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_update_mario_platform_calls_find_floor :
  calls_ident_s P._find_floor
    (fn_body P.f_update_mario_platform) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_update_mario_platform_reads_floor_object :
  statement_mentions_ident_s P._object
    (fn_body P.f_update_mario_platform) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_update_mario_platform_writes_gMarioPlatform :
  statement_mentions_ident_s P._gMarioPlatform
    (fn_body P.f_update_mario_platform) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_update_mario_platform_writes_mario_object_platform :
  assigns_field_named_s P._platform
    (fn_body P.f_update_mario_platform) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_apply_platform_displacement_uses_raw_object_slots :
  statement_mentions_ident_s P._rawData
    (fn_body P.f_apply_platform_displacement) = true /\
  statement_mentions_ident_s P._asF32
    (fn_body P.f_apply_platform_displacement) = true /\
  statement_mentions_ident_s P._asS32
    (fn_body P.f_apply_platform_displacement) = true /\
  statement_mentions_int_s 9
    (fn_body P.f_apply_platform_displacement) = true /\
  statement_mentions_int_s 11
    (fn_body P.f_apply_platform_displacement) = true /\
  statement_mentions_int_s 35
    (fn_body P.f_apply_platform_displacement) = true /\
  statement_mentions_int_s 36
    (fn_body P.f_apply_platform_displacement) = true /\
  statement_mentions_int_s 37
    (fn_body P.f_apply_platform_displacement) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_apply_platform_displacement_updates_mario_position :
  calls_ident_s P._set_mario_pos
    (fn_body P.f_apply_platform_displacement) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_update_objects_call_order :
  ident_subsequenceb
    [O._clear_dynamic_surfaces;
     O._update_terrain_objects;
     O._apply_mario_platform_displacement;
     O._detect_object_collisions;
     O._update_non_terrain_objects;
     O._unload_deactivated_objects;
     O._update_mario_platform]
    (direct_callees_s (fn_body O.f_update_objects)) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_update_objects_detects_collisions_before_nonterrain_update :
  ident_subsequenceb
    [O._detect_object_collisions;
     O._update_non_terrain_objects;
     O._update_mario_platform]
    (direct_callees_s (fn_body O.f_update_objects)) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_bhv_mario_update_executes_action_before_copy :
  ident_subsequenceb
    [O._execute_mario_action; O._copy_mario_state_to_object]
    (direct_callees_s (fn_body O.f_bhv_mario_update)) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_execute_mario_action_processes_interactions_before_action_dispatch :
  ident_subsequenceb
    [MJ._update_mario_inputs;
     MJ._mario_process_interactions;
     MJ._mario_execute_stationary_action]
    (direct_callees_s (fn_body MJ.f_execute_mario_action)) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_nonfading_interact_warp_sets_mario_action :
  calls_ident_s IX._set_mario_action
    (fn_body IX.f_interact_warp) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_interact_warp_stores_object_in_interact_and_used :
  assigns_field_from_ident_s IX._interactObj IX._o
    (fn_body IX.f_interact_warp) = true /\
  assigns_field_from_ident_s IX._usedObj IX._o
    (fn_body IX.f_interact_warp) = true.
Proof.
  vm_compute.
  split; reflexivity.
Qed.

Theorem generated_nonfading_interact_warp_uses_disappeared_action :
  statement_mentions_int_s 4864
    (fn_body IX.f_interact_warp) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_warp_handler_index_is_4 :
  ident_index IX._interact_warp
    (initializer_addrofs (gvar_init IX.v_sInteractionHandlers)) = Some 4%nat.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_grabbable_handler_index_is_29 :
  ident_index IX._interact_grabbable
    (initializer_addrofs (gvar_init IX.v_sInteractionHandlers)) = Some 29%nat.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_interaction_dispatch_contains_success_break :
  statement_contains_break_s
    (fn_body IX.f_mario_process_interactions) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_set_mario_action_returns_true :
  returns_int_s 1 (fn_body MJ.f_set_mario_action) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_interaction_dispatch_checks_intangible_action_flag :
  statement_mentions_ident_s IX._action
    (fn_body IX.f_mario_process_interactions) = true /\
  statement_mentions_int_s 12
    (fn_body IX.f_mario_process_interactions) = true.
Proof.
  vm_compute.
  split; reflexivity.
Qed.

Theorem generated_mario_grab_used_object_copies_used_to_held :
  copies_field_via_temp_s IX._heldObj IX._usedObj
    (fn_body IX.f_mario_grab_used_object) = true /\
  calls_ident_s IX._obj_set_held_state
    (fn_body IX.f_mario_grab_used_object) = true.
Proof.
  vm_compute.
  split; reflexivity.
Qed.

Theorem generated_picking_up_action_calls_grab_used_object :
  calls_ident_s MAO._mario_grab_used_object
    (fn_body MAO.f_act_picking_up) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_bowser_pickup_action_calls_grab_used_object :
  calls_ident_s MAO._mario_grab_used_object
    (fn_body MAO.f_act_picking_up_bowser) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Definition id_mario_grab_used_object : ident := $"mario_grab_used_object".

Theorem generated_disappeared_action_does_not_grab_used_object :
  calls_ident_s id_mario_grab_used_object
    (fn_body MAC.f_act_disappeared) = false.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_water_grab_selects_grabbable_before_grab :
  ident_subsequenceb
    [MAS._mario_get_collided_object; MAS._mario_grab_used_object]
    (direct_callees_s (fn_body MAS.f_check_water_grab)) = true /\
  assigns_field_named_s MAS._usedObj
    (fn_body MAS.f_check_water_grab) = true.
Proof.
  vm_compute.
  split; reflexivity.
Qed.

Theorem generated_init_mario_clears_object_pointers :
  assigns_field_zero_s MJ._heldObj (fn_body MJ.f_init_mario) = true /\
  assigns_field_zero_s MJ._riddenObj (fn_body MJ.f_init_mario) = true /\
  assigns_field_zero_s MJ._usedObj (fn_body MJ.f_init_mario) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_warp_area_loads_before_mario_initialization :
  ident_subsequenceb
    [L._unload_mario_area; L._load_area; L._init_mario_after_warp]
    (direct_callees_s (fn_body L.f_warp_area)) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_init_after_warp_loads_mario_then_clears_state :
  ident_subsequenceb
    [L._load_mario_area; L._init_mario; L._set_mario_initial_action]
    (direct_callees_s (fn_body L.f_init_mario_after_warp)) = true /\
  statement_mentions_ident_s L._action
    (fn_body L.f_init_mario_after_warp) = true /\
  statement_mentions_int_s 0
    (fn_body L.f_init_mario_after_warp) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_execute_mario_action_has_action_zero_guard :
  statement_mentions_ident_s MJ._action
    (fn_body MJ.f_execute_mario_action) = true /\
  statement_mentions_int_s 0
    (fn_body MJ.f_execute_mario_action) = true.
Proof.
  vm_compute.
  split; reflexivity.
Qed.

Theorem generated_obj_set_held_state_can_redirect_nonholdable_command :
  assigns_field_named_s OH._curBhvCommand
    (fn_body OH.f_obj_set_held_state) = true /\
  assigns_field_named_s OH._bhvStackIndex
    (fn_body OH.f_obj_set_held_state) = true /\
  statement_mentions_ident_s OH._heldBehavior
    (fn_body OH.f_obj_set_held_state) = true /\
  assigns_field_named_s OH._behavior
    (fn_body OH.f_obj_set_held_state) = false.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_obj_set_held_state_direct_callers_are_held_helpers :
  direct_callers IX.prog IX._obj_set_held_state =
    [IX._mario_grab_used_object;
     IX._mario_drop_held_object;
     IX._mario_throw_held_object] /\
  statement_mentions_ident_s IX._heldObj
    (fn_body IX.f_mario_grab_used_object) = true /\
  statement_mentions_ident_s IX._heldObj
    (fn_body IX.f_mario_drop_held_object) = true /\
  statement_mentions_ident_s IX._heldObj
    (fn_body IX.f_mario_throw_held_object) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_create_object_overwrites_behavior_pointers :
  assigns_field_named_s S._curBhvCommand
    (fn_body S.f_create_object) = true /\
  assigns_field_named_s S._behavior
    (fn_body S.f_create_object) = true.
Proof.
  vm_compute.
  split; reflexivity.
Qed.

Theorem generated_warp_behavior_calls_only_warp_native_of_relevant_targets :
  initializer_list_mentions_addrof BD._bhv_warp_loop
    (gvar_init BD.v_bhvWarp) = true /\
  initializer_list_mentions_addrof BD._bhvCarrySomething3
    (gvar_init BD.v_bhvWarp) = false /\
  initializer_list_mentions_addrof BD._bhvCarrySomething4
    (gvar_init BD.v_bhvWarp) = false.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_warp_native_does_not_redirect_behavior_command :
  assigns_field_named_s BA._curBhvCommand
    (fn_body BA.f_bhv_warp_loop) = false /\
  assigns_field_named_s BA._behavior
    (fn_body BA.f_bhv_warp_loop) = false.
Proof.
  vm_compute.
  split; reflexivity.
Qed.

Record jp_node1e_control_flow_source_certificate : Prop := {
  cert_node1e_warp_stores_interaction_pointers :
    assigns_field_from_ident_s IX._interactObj IX._o
      (fn_body IX.f_interact_warp) = true /\
    assigns_field_from_ident_s IX._usedObj IX._o
      (fn_body IX.f_interact_warp) = true;
  cert_node1e_warp_sets_disappeared :
    calls_ident_s IX._set_mario_action
      (fn_body IX.f_interact_warp) = true /\
    statement_mentions_int_s 4864
      (fn_body IX.f_interact_warp) = true /\
    returns_int_s 1 (fn_body MJ.f_set_mario_action) = true;
  cert_warp_precedes_grabbable :
    ident_index IX._interact_warp
      (initializer_addrofs (gvar_init IX.v_sInteractionHandlers)) = Some 4%nat /\
    ident_index IX._interact_grabbable
      (initializer_addrofs (gvar_init IX.v_sInteractionHandlers)) = Some 29%nat /\
    statement_contains_break_s
      (fn_body IX.f_mario_process_interactions) = true /\
    statement_mentions_ident_s IX._action
      (fn_body IX.f_mario_process_interactions) = true /\
    statement_mentions_int_s 12
      (fn_body IX.f_mario_process_interactions) = true;
  cert_interactions_precede_action_dispatch :
    ident_subsequenceb
      [MJ._update_mario_inputs;
       MJ._mario_process_interactions;
       MJ._mario_execute_stationary_action]
      (direct_callees_s (fn_body MJ.f_execute_mario_action)) = true;
  cert_grab_copies_used_to_held :
    copies_field_via_temp_s IX._heldObj IX._usedObj
      (fn_body IX.f_mario_grab_used_object) = true /\
    calls_ident_s IX._obj_set_held_state
      (fn_body IX.f_mario_grab_used_object) = true;
  cert_pickup_and_disappeared_actions :
    calls_ident_s MAO._mario_grab_used_object
      (fn_body MAO.f_act_picking_up) = true /\
    calls_ident_s MAO._mario_grab_used_object
      (fn_body MAO.f_act_picking_up_bowser) = true /\
    calls_ident_s id_mario_grab_used_object
      (fn_body MAC.f_act_disappeared) = false;
  cert_water_grab_selects_grabbable :
    ident_subsequenceb
      [MAS._mario_get_collided_object; MAS._mario_grab_used_object]
      (direct_callees_s (fn_body MAS.f_check_water_grab)) = true /\
    assigns_field_named_s MAS._usedObj
      (fn_body MAS.f_check_water_grab) = true;
  cert_init_clears_held_ridden_used :
    assigns_field_zero_s MJ._heldObj (fn_body MJ.f_init_mario) = true /\
    assigns_field_zero_s MJ._riddenObj (fn_body MJ.f_init_mario) = true /\
    assigns_field_zero_s MJ._usedObj (fn_body MJ.f_init_mario) = true;
  cert_area_load_then_init :
    ident_subsequenceb
      [L._unload_mario_area; L._load_area; L._init_mario_after_warp]
      (direct_callees_s (fn_body L.f_warp_area)) = true /\
    ident_subsequenceb
      [L._load_mario_area; L._init_mario; L._set_mario_initial_action]
      (direct_callees_s (fn_body L.f_init_mario_after_warp)) = true;
  cert_action_zero_guards_init_and_execution :
    statement_mentions_ident_s L._action
      (fn_body L.f_init_mario_after_warp) = true /\
    statement_mentions_int_s 0
      (fn_body L.f_init_mario_after_warp) = true /\
    statement_mentions_ident_s MJ._action
      (fn_body MJ.f_execute_mario_action) = true /\
    statement_mentions_int_s 0
      (fn_body MJ.f_execute_mario_action) = true;
  cert_nonholdable_redirect_and_allocation_reset :
    assigns_field_named_s OH._curBhvCommand
      (fn_body OH.f_obj_set_held_state) = true /\
    assigns_field_named_s OH._bhvStackIndex
      (fn_body OH.f_obj_set_held_state) = true /\
    assigns_field_named_s OH._behavior
      (fn_body OH.f_obj_set_held_state) = false /\
    direct_callers IX.prog IX._obj_set_held_state =
      [IX._mario_grab_used_object;
       IX._mario_drop_held_object;
       IX._mario_throw_held_object] /\
    assigns_field_named_s S._curBhvCommand
      (fn_body S.f_create_object) = true /\
    assigns_field_named_s S._behavior
      (fn_body S.f_create_object) = true;
  cert_warp_behavior_does_not_self_redirect :
    initializer_list_mentions_addrof BD._bhv_warp_loop
      (gvar_init BD.v_bhvWarp) = true /\
    initializer_list_mentions_addrof BD._bhvCarrySomething3
      (gvar_init BD.v_bhvWarp) = false /\
    initializer_list_mentions_addrof BD._bhvCarrySomething4
      (gvar_init BD.v_bhvWarp) = false /\
    assigns_field_named_s BA._curBhvCommand
      (fn_body BA.f_bhv_warp_loop) = false /\
    assigns_field_named_s BA._behavior
      (fn_body BA.f_bhv_warp_loop) = false
}.

Theorem generated_jp_node1e_control_flow_source_certificate :
  jp_node1e_control_flow_source_certificate.
Proof.
  constructor; vm_compute; repeat split.
Qed.

Theorem generated_unload_object_calls_deallocate_object :
  calls_ident_s S._deallocate_object (fn_body S.f_unload_object) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_unload_object_mentions_gFreeObjectList :
  statement_mentions_ident_s S._gFreeObjectList
    (fn_body S.f_unload_object) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_try_allocate_object_mentions_free_list_next :
  assigns_field_named_s S._next
    (fn_body S.f_try_allocate_object) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_obj_behaviors_contains_spindel_loop :
  existsb
    (fun definition => Pos.eqb (fst definition) B._bhv_spindel_loop)
    B.global_definitions = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_spindel_loop_mentions_velocity_and_pitch_slots :
  statement_mentions_ident_s B._rawData
    (fn_body B.f_bhv_spindel_loop) = true /\
  statement_mentions_ident_s B._asF32
    (fn_body B.f_bhv_spindel_loop) = true /\
  statement_mentions_ident_s B._asS32
    (fn_body B.f_bhv_spindel_loop) = true /\
  statement_mentions_int_s 11
    (fn_body B.f_bhv_spindel_loop) = true /\
  statement_mentions_int_s 35
    (fn_body B.f_bhv_spindel_loop) = true /\
  statement_mentions_int_s 1024
    (fn_body B.f_bhv_spindel_loop) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_spindel_init_sets_first_motion_phase_markers :
  statement_mentions_int_s 27
    (fn_body B.f_bhv_spindel_init) = true /\
  statement_mentions_int_s 28
    (fn_body B.f_bhv_spindel_init) = true /\
  statement_mentions_int_s 0
    (fn_body B.f_bhv_spindel_init) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_spindel_loop_contains_rest_and_active_markers :
  statement_mentions_int_s 32
    (fn_body B.f_bhv_spindel_loop) = true /\
  statement_mentions_int_s 11
    (fn_body B.f_bhv_spindel_loop) = true /\
  statement_mentions_int_s 35
    (fn_body B.f_bhv_spindel_loop) = true /\
  statement_mentions_int_s 20
    (fn_body B.f_bhv_spindel_loop) = true /\
  statement_mentions_int_s 1024
    (fn_body B.f_bhv_spindel_loop) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_pyramid_elevator_loop_has_idle_and_vertical_markers :
  statement_mentions_ident_s B._gMarioObject
    (fn_body B.f_bhv_pyramid_elevator_loop) = true /\
  statement_mentions_ident_s B._platform
    (fn_body B.f_bhv_pyramid_elevator_loop) = true /\
  statement_mentions_int_s 49
    (fn_body B.f_bhv_pyramid_elevator_loop) = true /\
  statement_mentions_int_s 10
    (fn_body B.f_bhv_pyramid_elevator_loop) = true /\
  statement_mentions_int_s 4096
    (fn_body B.f_bhv_pyramid_elevator_loop) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_moving_pyramid_wall_loop_has_vertical_markers :
  statement_mentions_int_s 49
    (fn_body B.f_bhv_ssl_moving_pyramid_wall_loop) = true /\
  statement_mentions_int_s 51
    (fn_body B.f_bhv_ssl_moving_pyramid_wall_loop) = true /\
  statement_mentions_int_s 10
    (fn_body B.f_bhv_ssl_moving_pyramid_wall_loop) = true /\
  statement_mentions_int_s 100
    (fn_body B.f_bhv_ssl_moving_pyramid_wall_loop) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_grindel_thwomp_loop_uses_action_table :
  calls_ident_s BA._cur_obj_call_action_function
    (fn_body BA.f_bhv_grindel_thwomp_loop) = true /\
  initializer_list_mentions_addrof BA._grindel_thwomp_act_raise
    (gvar_init BA.v_sGrindelThwompActions) = true /\
  initializer_list_mentions_addrof BA._grindel_thwomp_act_lower
    (gvar_init BA.v_sGrindelThwompActions) = true /\
  statement_mentions_int_s 10
    (fn_body BA.f_grindel_thwomp_act_lower) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_load_area_calls_spawn_objects_from_info :
  calls_ident_s A._spawn_objects_from_info
    (fn_body A.f_load_area) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_load_mario_area_calls_spawn_objects_from_info :
  calls_ident_s A._spawn_objects_from_info
    (fn_body A.f_load_mario_area) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_level_cmd_init_level_calls_clear_objects :
  calls_ident_s LS._clear_objects
    (fn_body LS.f_level_cmd_init_level) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_play_mode_normal_updates_objects_before_painting_warp :
  ident_subsequenceb
    [L._area_update_objects; L._initiate_painting_warp]
    (direct_callees_s (fn_body L.f_play_mode_normal)) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_initiate_painting_warp_uses_checkpoint_then_warp :
  calls_ident_s L._check_warp_checkpoint
    (fn_body L.f_initiate_painting_warp) = true /\
  calls_ident_s L._initiate_warp
    (fn_body L.f_initiate_painting_warp) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_get_painting_warp_node_reads_floor_type :
  statement_mentions_ident_s L._floor
    (fn_body L.f_get_painting_warp_node) = true /\
  statement_mentions_ident_s L._type
    (fn_body L.f_get_painting_warp_node) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_ssl_area2_macro_object_count_is_50 :
  ((List.length (gvar_init M2.v_ssl_seg7_area_2_macro_objs) - 1) / 5)%nat =
    50%nat.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_ssl_area1_macro_object_count_is_46 :
  ((List.length (gvar_init M1.v_ssl_seg7_area_1_macro_objs) - 1) / 5)%nat =
    46%nat.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_ssl_area2_regular_script_has_spindel_targets :
  initializer_list_mentions_addrof SSL._bhvSpindel
    (gvar_init SSL.v_script_func_local_4) = true /\
  initializer_list_mentions_addrof SSL._bhvPyramidElevator
    (gvar_init SSL.v_script_func_local_4) = true /\
  initializer_list_mentions_addrof SSL._bhvSSLMovingPyramidWall
    (gvar_init SSL.v_script_func_local_4) = true /\
  initializer_list_mentions_addrof SSL._bhvGrindel
    (gvar_init SSL.v_script_func_local_4) = true /\
  initializer_list_mentions_addrof SSL._bhvHorizontalGrindel
    (gvar_init SSL.v_script_func_local_4) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_ssl_area2_regular_script_spindel_precedes_elevator_source_order :
  ident_subsequenceb
    [SSL._bhvSpindel; SSL._bhvSSLMovingPyramidWall; SSL._bhvPyramidElevator]
    (initializer_addrofs (gvar_init SSL.v_script_func_local_4)) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_ssl_area1_regular_script_has_seed_platforms :
  initializer_list_mentions_addrof SSL._bhvPyramidTop
    (gvar_init SSL.v_script_func_local_1) = true /\
  initializer_list_mentions_addrof SSL._bhvToxBox
    (gvar_init SSL.v_script_func_local_2) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_ssl_level_entry_has_area_warps :
  initializer_list_mentions_addrof SSL._bhvWarp
    (gvar_init SSL.v_level_ssl_entry) = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem generated_bhv_spindel_loads_collision_and_loop :
  initializer_list_mentions_addrof BD._ssl_seg7_collision_spindel
    (gvar_init BD.v_bhvSpindel) = true /\
  initializer_list_mentions_addrof BD._bhv_spindel_loop
    (gvar_init BD.v_bhvSpindel) = true /\
  initializer_list_mentions_addrof BD._load_object_collision_model
    (gvar_init BD.v_bhvSpindel) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_bhv_exclamation_box_has_collision_and_loop :
  initializer_list_mentions_addrof BD._exclamation_box_outline_seg8_collision_08025F78
    (gvar_init BD.v_bhvExclamationBox) = true /\
  initializer_list_mentions_addrof BD._bhv_exclamation_box_loop
    (gvar_init BD.v_bhvExclamationBox) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_bhv_carry_something_behaviors_do_not_load_collision :
  initializer_list_mentions_addrof BD._load_object_collision_model
    (gvar_init BD.v_bhvCarrySomething3) = false /\
  initializer_list_mentions_addrof BD._load_object_collision_model
    (gvar_init BD.v_bhvCarrySomething4) = false.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_bhv_pyramid_top_and_tox_box_name_collision_data :
  initializer_list_mentions_addrof BD._ssl_seg7_collision_pyramid_top
    (gvar_init BD.v_bhvPyramidTop) = true /\
  initializer_list_mentions_addrof BD._load_object_collision_model
    (gvar_init BD.v_bhvPyramidTop) = true /\
  initializer_list_mentions_addrof BD._ssl_seg7_collision_tox_box
    (gvar_init BD.v_bhvToxBox) = true /\
  initializer_list_mentions_addrof BD._bhv_tox_box_loop
    (gvar_init BD.v_bhvToxBox) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_bhv_horizontal_grindel_loads_collision_and_update :
  initializer_list_mentions_addrof BD._ssl_seg7_collision_grindel
    (gvar_init BD.v_bhvHorizontalGrindel) = true /\
  initializer_list_mentions_addrof BD._bhv_horizontal_grindel_init
    (gvar_init BD.v_bhvHorizontalGrindel) = true /\
  initializer_list_mentions_addrof BD._bhv_horizontal_grindel_update
    (gvar_init BD.v_bhvHorizontalGrindel) = true /\
  initializer_list_mentions_addrof BD._load_object_collision_model
    (gvar_init BD.v_bhvHorizontalGrindel) = true.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem generated_behavior_globals_are_linked_in_behavior_data :
  program_global_initializer BD.prog BD._bhvSpindel =
    Some (gvar_init BD.v_bhvSpindel) /\
  program_global_initializer BD.prog BD._bhvExclamationBox =
    Some (gvar_init BD.v_bhvExclamationBox) /\
  program_global_initializer BD.prog BD._bhvPyramidTop =
    Some (gvar_init BD.v_bhvPyramidTop) /\
  program_global_initializer BD.prog BD._bhvToxBox =
    Some (gvar_init BD.v_bhvToxBox).
Proof.
  vm_compute.
  repeat split.
Qed.

Record jp_clight_source_certificate : Prop := {
  cert_spawn_no_clear :
    calls_ident_s id_clear_mario_platform
      (fn_body O.f_spawn_objects_from_info) = false;
  cert_apply_reads_platform :
    statement_mentions_ident_s P._gMarioPlatform
      (fn_body P.f_apply_mario_platform_displacement) = true;
  cert_apply_calls_platform_displacement :
    calls_ident_s P._apply_platform_displacement
      (fn_body P.f_apply_mario_platform_displacement) = true;
  cert_apply_no_active_check :
    statement_mentions_ident_s P._activeFlags
      (fn_body P.f_apply_mario_platform_displacement) = false;
  cert_apply_no_behavior_check :
    statement_mentions_ident_s P._behavior
      (fn_body P.f_apply_mario_platform_displacement) = false;
  cert_apply_no_collision_check :
    statement_mentions_ident_s P._collisionData
      (fn_body P.f_apply_mario_platform_displacement) = false;
  cert_update_mario_platform_floor_object :
    statement_mentions_ident_s P._object
      (fn_body P.f_update_mario_platform) = true;
  cert_update_order :
    ident_subsequenceb
      [O._clear_dynamic_surfaces;
       O._update_terrain_objects;
       O._apply_mario_platform_displacement;
       O._detect_object_collisions;
       O._update_non_terrain_objects;
       O._unload_deactivated_objects;
       O._update_mario_platform]
      (direct_callees_s (fn_body O.f_update_objects)) = true;
  cert_unload_deallocates :
    calls_ident_s S._deallocate_object (fn_body S.f_unload_object) = true;
  cert_allocate_pops_next :
    assigns_field_named_s S._next
      (fn_body S.f_try_allocate_object) = true;
  cert_area2_macro_count :
    ((List.length (gvar_init M2.v_ssl_seg7_area_2_macro_objs) - 1) / 5)%nat =
      50%nat;
  cert_area2_script_has_spindel :
    initializer_list_mentions_addrof SSL._bhvSpindel
      (gvar_init SSL.v_script_func_local_4) = true;
  cert_spindel_behavior_loads_collision_and_loop :
    initializer_list_mentions_addrof BD._ssl_seg7_collision_spindel
      (gvar_init BD.v_bhvSpindel) = true /\
    initializer_list_mentions_addrof BD._bhv_spindel_loop
      (gvar_init BD.v_bhvSpindel) = true /\
    initializer_list_mentions_addrof BD._load_object_collision_model
      (gvar_init BD.v_bhvSpindel) = true;
  cert_spindel_loop_raw_slots :
    statement_mentions_ident_s B._rawData
      (fn_body B.f_bhv_spindel_loop) = true /\
    statement_mentions_ident_s B._asF32
      (fn_body B.f_bhv_spindel_loop) = true /\
    statement_mentions_ident_s B._asS32
      (fn_body B.f_bhv_spindel_loop) = true /\
    statement_mentions_int_s 11
      (fn_body B.f_bhv_spindel_loop) = true /\
    statement_mentions_int_s 35
      (fn_body B.f_bhv_spindel_loop) = true /\
    statement_mentions_int_s 1024
      (fn_body B.f_bhv_spindel_loop) = true
}.

Theorem generated_jp_clight_source_certificate :
  jp_clight_source_certificate.
Proof.
  constructor; vm_compute; repeat split.
Qed.
