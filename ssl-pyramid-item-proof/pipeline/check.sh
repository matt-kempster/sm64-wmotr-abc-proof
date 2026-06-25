#!/usr/bin/env bash
set -euo pipefail

make proofs

if grep -RInE '\b(Admitted|Axiom|admit|sorry)\b' proofs; then
  echo "proof hole or added axiom found" >&2
  exit 1
fi

bash pipeline/source-census.sh
bash pipeline/assumptions.sh
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.Spec \
  cleared_barrier_forbids_continuous_transfer
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.StalePointerModel \
  post_pyramid_warp_shape_has_no_stale_outside_reference
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.StalePointerModel \
  deactivated_raw_slot_reuse_is_not_continuous_transfer
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.RenderHeldObjectFacts \
  geo_switch_mario_hand_grab_pos_direct_objnode_writers
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.RenderHeldObjectFacts \
  geo_switch_mario_hand_grab_pos_refreshes_objnode_from_mario_heldObj
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.LayoutFacts \
  unload_object_direct_store_offsets_miss_active_flags
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_after_prev_split_throw_matrix
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_throw_matrix_layout
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_throw_matrix_lhs_access_mode
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_after_geo_add_child_split_graph_flags_bit2
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_after_graph_flags_bit2_split_graph_flags_bit0
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_graph_flags_clear_bit2_split
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_graph_flags_clear_bit0_split
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_after_graph_flags_bit0_is_deallocate_call
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_body_split
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_graph_node_object_node_layout
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_graph_node_flags_layout
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_graph_flags_lhs_access_mode
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_header_lhs_access_mode
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_node_next_layout
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_node_prev_layout
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_preserves_active_flags_bytes_from_leaf_frames
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_does_not_write_obj_temp
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_body_has_obj_next_store_event
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_body_event_sequence
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_unload_object_tail_preserves_obj_temp
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  pool_slot_field_address
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  pool_slot_header_address
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  pool_slot_node_next_address
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  pool_slot_node_prev_address
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  pool_slot_prev_obj_store_misses_active_flags
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  pool_slot_throw_matrix_store_misses_active_flags
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  pool_slot_throw_matrix_nested_address
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  pool_slot_graph_flags_store_misses_active_flags
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  pool_slot_node_next_store_misses_active_flags
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  pool_slot_node_prev_store_misses_active_flags
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  object_node_field_store_misses_active_flags_from_header_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  object_node_next_store_misses_active_flags_from_header_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  object_node_prev_store_misses_active_flags_from_header_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  pool_slot_graph_flags_nested_address
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  assign_loc_by_value_preserves_active_flags_bytes
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deref_loc_by_copy_pointer
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deref_loc_by_reference_pointer
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deref_loc_by_copy_pointer_any_bitfield
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  eval_deallocate_object_node_base_expr_pointer
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  eval_object_node_temp_deref_pointer_with_lookup
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  eval_object_node_temp_field_lvalue
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  temp_points_to_external_block
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  temp_points_to_pool_slot_header
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  object_node_field_value_shape_from_deref_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  value_points_to_external_or_pool_slot_header
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  temp_lookup_value_pointer_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  sem_cast_object_node_pointer_preserves_value_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  storev_shaped_pointer_preserves_object_node_field_deref_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_object_node_field_read_sets_temp_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_object_node_field_read_sets_temp_shape_from_deref_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  temp_points_to_external_or_pool_slot_header_set_different
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_sset_different_preserves_temp_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_sset_different_preserves_lookup
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  statement_preserves_temp_shape_sset_different
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  statement_preserves_temp_shape_assign
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  statement_preserves_temp_shape_sequence
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_deallocate_object_read_next_sets_t4_shape_from_deref_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_deallocate_object_read_prev_sets_t5_shape_from_deref_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_deallocate_object_read_prev_again_sets_t2_shape_from_deref_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_deallocate_object_read_next_again_sets_t3_shape_from_deref_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_deallocate_object_read_free_next_sets_t1_shape_from_deref_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  eval_deallocate_object_obj_next_lhs_pool_slot
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_deallocate_object_obj_next_assign_preserves_active_flags
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_deallocate_object_next_prev_assign_preserves_active_flags_from_target_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_deallocate_object_next_prev_assign_preserves_pool_link_fields_from_value_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_deallocate_object_prev_next_assign_preserves_active_flags_from_target_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_deallocate_object_free_list_next_assign_preserves_active_flags_from_target_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_unload_prev_obj_assign_preserves_active_flags
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  eval_unload_throw_matrix_lhs_pool_slot
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_unload_throw_matrix_assign_preserves_active_flags
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  eval_unload_graph_flags_lhs_pool_slot
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_unload_graph_flags_assign_preserves_active_flags
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_prev_obj_assign_pool_slot_frame
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_obj_next_assign_pool_slot_frame
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_next_prev_assign_pool_slot_frame_from_target_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_prev_next_assign_pool_slot_frame_from_target_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_free_list_next_assign_pool_slot_frame_from_target_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_first_splice_pool_slot_frame_from_next_deref_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_second_splice_pool_slot_frame_from_prev_deref_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_free_list_insert_pool_slot_frame_from_free_list_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_first_splice_preserves_free_list_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_second_splice_preserves_free_list_shape
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_body_pool_slot_frame_from_shape_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_body_preserves_pool_slot_active_flags_from_shape_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_body_pool_slot_frame_from_remaining_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_body_preserves_pool_slot_active_flags_from_remaining_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_throw_matrix_assign_pool_slot_frame
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_graph_flags_read_bit2_pool_slot_frame
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_graph_flags_read_bit0_pool_slot_frame
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_graph_flags_assign_bit2_pool_slot_frame
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_graph_flags_assign_bit0_pool_slot_frame
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_graph_flags_clear_bit2_pool_slot_frame_from_assign
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_graph_flags_clear_bit0_pool_slot_frame_from_assign
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_named_frames_from_refined_frames
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_pool_slot_frame_from_named_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_pool_slot_frame_from_refined_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_refined_frames_from_remaining_frames
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_pool_slot_frame_from_remaining_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_preserves_pool_slot_active_flags_from_named_frames
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_preserves_pool_slot_active_flags_from_refined_frames
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_preserves_pool_slot_active_flags_from_remaining_frames
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_body_preserves_active_flags_bytes_from_leaf_frames
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  eval_funcall_internal_deallocate_object_preserves_active_flags_from_body_frame
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  eval_funcall_internal_deallocate_object_preserves_pool_slot_active_flags_from_shape_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  function_entry2_deallocate_object_binds_parameter_temps
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  valid_object_slot_zero
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  object_node_pointer_zero_external_or_pool_slot_header
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_resolved_free_list_shape_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_resolved_free_list_deref_shape_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  object_pool_link_fields_well_shaped
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  storev_shaped_pointer_preserves_object_pool_link_fields
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  assign_loc_shaped_pointer_preserves_object_pool_link_fields
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  first_deallocate_splice_shaped_store_preserves_pool_link_fields
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  first_deallocate_splice_shaped_store_preserves_pool_link_fields_holds
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  first_deallocate_splice_preserves_pool_link_fields
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_first_splice_loads_pool_link_shapes
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  first_deallocate_splice_preserves_pool_link_fields_from_shaped_store
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  first_deallocate_splice_preserves_pool_link_fields_from_pool_link_fields
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_resolved_free_list_deref_shapes_from_pool_link_fields
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_resolved_free_list_deref_shapes_from_pool_link_shaped_store
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_resolved_free_list_deref_shapes_from_pool_link_fields_holds
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_resolved_free_list_shape_obligations_from_deref_shapes
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_bound_entry_shape_obligations_from_resolved_free_list_shapes
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_internal_call_shape_obligations_from_bound_entry_shapes
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  eval_unload_object_header_lhs_lvalue_pointer
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_ge_resolves_gFreeObjectList
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_argument_values
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_actual_argument_shape_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_actual_argument_shapes_from_bound_entry_shapes
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_actual_shape_frame_obligation_holds
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_frame_from_actual_shape_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_frame_from_bound_entry_shapes
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_frame_from_resolved_free_list_shapes
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_frame_from_resolved_free_list_deref_shapes
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  pool_slot_statement_preserves_obj_and_active_flags_in_empty_env
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  empty_env_pool_slot_statement_preserves_sequence
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_frame_from_deref_shape_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_pool_link_shape_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_pool_link_fields_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_pool_link_store_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_deref_shape_obligations_from_pool_link_shapes
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_pool_link_shape_obligations_from_field_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_deref_shape_obligations_from_pool_link_field_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_pool_link_shape_obligations_from_store_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_deref_shape_obligations_from_pool_link_store_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_empty_env_pool_slot_frame_from_deref_shape_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_preserves_pool_slot_active_flags_from_empty_env_deref_shape_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_empty_env_pool_link_shape_frame_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_empty_env_pool_slot_frame_from_pool_link_shape_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_preserves_pool_slot_active_flags_from_empty_env_pool_link_shape_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_empty_env_pool_link_store_frame_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_empty_env_pool_link_fields_frame_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_empty_env_pool_link_shape_obligations_from_field_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_empty_env_pool_slot_frame_from_pool_link_field_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_preserves_pool_slot_active_flags_from_empty_env_pool_link_field_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_empty_env_pool_link_shape_obligations_from_store_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_empty_env_pool_slot_frame_from_pool_link_store_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_preserves_pool_slot_active_flags_from_empty_env_pool_link_store_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_function_resolves_in_empty_env
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_ge_resolves_deallocate_object
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  deallocate_object_function_resolves_in_empty_env_holds
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_shape_frame_obligation_holds
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_frame_from_shape_obligations
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_frame_obligation
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_frame_obligation_holds
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_deallocate_object_call_empty_env_frame_from_body_frame
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.TransitionFacts \
  spawn_object_active_flags_writers
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.TransitionFacts \
  cleanup_call_targets_have_no_direct_active_flags_assignment
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  unload_object_tail_preserves_deactivation_from_frame
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_unload_object_deactivates_pool_slot_from_same_obj_frame
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.UnloadObjectSemantics \
  exec_unload_object_deactivates_pool_slot
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.TraversalModel \
  traversal_trace_forbids_transfer
bash pipeline/assumptions.sh \
  SSLPyramid.Proofs.PyramidTransition \
  certified_pyramid_transition_forbids_continuous_item_transfer
