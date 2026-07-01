From Coq Require Import List PArith.BinPos String.
From compcert Require Import AST Clight Clightdefs.
From SSLSpawning.Generated Require Import
  jp_object_list_processor jp_platform_displacement jp_spawn_object
  jp_obj_behaviors.
From SSLSpawning.Proofs Require Import ASTFacts.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope string_scope.
Local Open Scope clight_scope.

Module O := jp_object_list_processor.
Module P := jp_platform_displacement.
Module S := jp_spawn_object.
Module B := jp_obj_behaviors.

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
