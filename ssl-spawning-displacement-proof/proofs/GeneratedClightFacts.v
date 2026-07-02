From Coq Require Import List PArith.BinPos String ZArith.
From compcert Require Import AST Clight Clightdefs.
From SSLSpawning.Generated Require Import
  jp_area jp_level_update jp_level_script jp_ssl_script
  jp_ssl_area1_macro jp_ssl_area2_macro jp_behavior_data
  jp_object_list_processor jp_platform_displacement jp_spawn_object
  jp_obj_behaviors jp_mario jp_interaction.
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
Module MJ := jp_mario.
Module IX := jp_interaction.

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
