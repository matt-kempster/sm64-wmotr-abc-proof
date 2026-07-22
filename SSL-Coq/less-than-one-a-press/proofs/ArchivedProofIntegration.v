(* Soundly incorporated kernels from the six archived investigations.

   Every field below is reproved in the current namespace.  Generated-source
   fields inspect the current US/JP Clight modules; none imports an archived
   generated file.  Route fields retain their narrow, explicitly handwritten
   hypotheses and therefore do not discharge a Layer B obligation. *)

From Coq Require Import List ZArith.
From compcert Require Import AST Clight Memory Values.
From LessThanOneAPress.Generated Require Import
  us_platform_displacement us_object_list_processor us_spawn_object us_area
  jp_platform_displacement jp_object_list_processor jp_spawn_object jp_area.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightFacts GameTypes InputSemantics ObjectProvenance RouteEvidence.

Import ListNotations.
Local Open Scope Z_scope.

Definition CurrentSpawningDisplacementSourceEvidence : Prop :=
  (statement_mentions_ident_s us_platform_displacement._gMarioPlatform
      (fn_body us_platform_displacement.f_apply_mario_platform_displacement) = true /\
   calls_ident_s us_platform_displacement._apply_platform_displacement
      (fn_body us_platform_displacement.f_apply_mario_platform_displacement) = true /\
   statement_mentions_ident_s us_platform_displacement._activeFlags
      (fn_body us_platform_displacement.f_apply_mario_platform_displacement) = false /\
   statement_mentions_ident_s us_platform_displacement._behavior
      (fn_body us_platform_displacement.f_apply_mario_platform_displacement) = false /\
   statement_mentions_ident_s us_platform_displacement._collisionData
      (fn_body us_platform_displacement.f_apply_mario_platform_displacement) = false) /\
  (statement_mentions_ident_s jp_platform_displacement._gMarioPlatform
      (fn_body jp_platform_displacement.f_apply_mario_platform_displacement) = true /\
   calls_ident_s jp_platform_displacement._apply_platform_displacement
      (fn_body jp_platform_displacement.f_apply_mario_platform_displacement) = true /\
   statement_mentions_ident_s jp_platform_displacement._activeFlags
      (fn_body jp_platform_displacement.f_apply_mario_platform_displacement) = false /\
   statement_mentions_ident_s jp_platform_displacement._behavior
      (fn_body jp_platform_displacement.f_apply_mario_platform_displacement) = false /\
   statement_mentions_ident_s jp_platform_displacement._collisionData
      (fn_body jp_platform_displacement.f_apply_mario_platform_displacement) = false) /\
  (calls_ident_s us_object_list_processor._clear_mario_platform
      (fn_body us_object_list_processor.f_spawn_objects_from_info) = true /\
   calls_ident_s us_object_list_processor._clear_mario_platform
      (fn_body jp_object_list_processor.f_spawn_objects_from_info) = false).

Definition CurrentPyramidLifecycleEvidence : Prop :=
  ident_subsequenceb [us_area._unload_area; us_area._load_area]
    (direct_callees_s (fn_body us_area.f_change_area)) = true /\
  ident_subsequenceb [jp_area._unload_area; jp_area._load_area]
    (direct_callees_s (fn_body jp_area.f_change_area)) = true /\
  (statement_mentions_ident_s us_object_list_processor._next
      (fn_body us_object_list_processor.f_unload_objects_from_area) = true /\
   calls_ident_s us_object_list_processor._unload_object
      (fn_body us_object_list_processor.f_unload_objects_from_area) = true) /\
  (statement_mentions_ident_s jp_object_list_processor._next
      (fn_body jp_object_list_processor.f_unload_objects_from_area) = true /\
   calls_ident_s jp_object_list_processor._unload_object
      (fn_body jp_object_list_processor.f_unload_objects_from_area) = true) /\
  (forall old_object new_object,
    fresh_slot_reuse old_object new_object ->
    ~ object_ref_equal (object_ref old_object) (object_ref new_object)).

Definition CurrentParallelUniverseSubcaseEvidence : Prop :=
  no_a_movement_source_shape_us_claim /\
  no_a_movement_source_shape_jp_claim /\
  (forall frame_count,
    fewer_than_one_a_press (repeat held_a_frame frame_count)) /\
  (forall before after,
    LegacyAcceptedStaticQstep before after ->
    legacy_pu_local_coordinate after).

Definition CurrentNormalizedPoleSubcaseEvidence : Prop :=
  normalized_pole_source_shape_us_claim /\
  normalized_pole_source_shape_jp_claim /\
  (forall frames,
    0 <= frames ->
    ~ LegacySoftPoleClearable frames).

Definition CurrentEyerokInputBoundaryEvidence : Prop :=
  eyerok_lifecycle_source_shape_us_claim /\
  eyerok_lifecycle_source_shape_jp_claim /\
  (forall frame_count,
    fewer_than_one_a_press (repeat held_a_frame frame_count)) /\
  (calls_ident_s us_platform_displacement._find_floor
      (fn_body us_platform_displacement.f_update_mario_platform) = true /\
   statement_mentions_ident_s us_platform_displacement._object
      (fn_body us_platform_displacement.f_update_mario_platform) = true /\
   assigns_global_ident_s us_platform_displacement._gMarioPlatform
      (fn_body us_platform_displacement.f_update_mario_platform) = true) /\
  (calls_ident_s jp_platform_displacement._find_floor
      (fn_body jp_platform_displacement.f_update_mario_platform) = true /\
   statement_mentions_ident_s jp_platform_displacement._object
      (fn_body jp_platform_displacement.f_update_mario_platform) = true /\
   assigns_global_ident_s jp_platform_displacement._gMarioPlatform
      (fn_body jp_platform_displacement.f_update_mario_platform) = true).

Definition CurrentDemoWarpMemoryBoundaryEvidence : Prop :=
  forall (before after : Mem.mem) (write_chunk read_chunk : memory_chunk)
      (write_block read_block : block) (write_offset read_offset : Z)
      (value : val),
    Mem.store write_chunk before write_block write_offset value = Some after ->
    Mem.load read_chunk after read_block read_offset <>
      Mem.load read_chunk before read_block read_offset ->
    write_block = read_block.

Record ArchivedProofIntegrationKernel : Prop := {
  integrated_spawning_displacement :
    CurrentSpawningDisplacementSourceEvidence;
  integrated_pyramid_item_lifecycle : CurrentPyramidLifecycleEvidence;
  integrated_parallel_universe_subcase :
    CurrentParallelUniverseSubcaseEvidence;
  integrated_normalized_pole_subcase : CurrentNormalizedPoleSubcaseEvidence;
  integrated_eyerok_input_boundary : CurrentEyerokInputBoundaryEvidence;
  integrated_demo_warp_memory_boundary :
    CurrentDemoWarpMemoryBoundaryEvidence
}.

Theorem archived_proof_integration_kernel_holds :
  ArchivedProofIntegrationKernel.
Proof.
  constructor.
  - unfold CurrentSpawningDisplacementSourceEvidence.
    split.
    + exact platform_displacement_raw_pointer_source_shape_us.
    + split.
      * exact platform_displacement_raw_pointer_source_shape_jp.
      * exact spawning_clears_platform_us_but_not_jp.
  - unfold CurrentPyramidLifecycleEvidence.
    split; [exact change_area_direct_callee_order_us |].
    split; [exact change_area_direct_callee_order_jp |].
    split; [exact area_object_unload_source_shape_us |].
    split; [exact area_object_unload_source_shape_jp |].
    exact fresh_slot_reuse_is_not_object_identity.
  - unfold CurrentParallelUniverseSubcaseEvidence.
    split; [exact no_a_movement_source_shape_us |].
    split; [exact no_a_movement_source_shape_jp |].
    split; [exact continuously_held_a_has_no_press_edges |].
    exact legacy_bounded_static_qstep_cannot_change_alias_period.
  - unfold CurrentNormalizedPoleSubcaseEvidence.
    split; [exact normalized_pole_source_shape_us |].
    split; [exact normalized_pole_source_shape_jp |].
    exact legacy_normalized_pole_soft_bonk_never_clears.
  - unfold CurrentEyerokInputBoundaryEvidence.
    split; [exact eyerok_lifecycle_source_shape_us |].
    split; [exact eyerok_lifecycle_source_shape_jp |].
    split; [exact continuously_held_a_has_no_press_edges |].
    split.
    + exact platform_recompute_source_shape_us.
    + exact platform_recompute_source_shape_jp.
  - exact changed_load_after_store_requires_same_block.
Qed.

(* This is the integration boundary.  In particular, the kernel contains no
   proof of WholeProgramClightRefinementObligation and no inhabitant of any of
   the three entrance reachability obligations. *)
