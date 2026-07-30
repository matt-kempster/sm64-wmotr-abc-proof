COQMAKEFILE := CoqMakefile

.PHONY: all generated regenerate verify-generated proofs check clean

all: proofs

generated:
	bash pipeline/generate-clight.sh

regenerate: generated

verify-generated:
	bash pipeline/check-generated.sh

$(COQMAKEFILE): _CoqProject
	coq_makefile -f _CoqProject -o $(COQMAKEFILE)

proofs: $(COQMAKEFILE)
	$(MAKE) -f $(COQMAKEFILE)

check: proofs
	bash pipeline/check-no-admitted.sh
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ArchivedProofIntegration \
	  archived_proof_integration_kernel_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  ssl_area2_entry_objects_exact_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  ssl_area2_entry_objects_exact_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  game_over_save_reload_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  game_over_save_reload_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  no_spin_airborne_entry_update_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  no_spin_airborne_entry_update_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  submerged_position_writer_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  submerged_position_writer_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  held_a_jump_kick_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  held_a_jump_kick_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  b_rollout_chain_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  b_rollout_chain_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  retail_entry_cap_reset_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  retail_entry_cap_reset_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  pyramid_elevator_motion_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  pyramid_elevator_motion_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  air_quarter_lower_wall_query_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  air_quarter_lower_wall_query_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  surface_upper_y_padding_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  surface_upper_y_padding_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  wall_upper_y_strict_rejection_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  wall_upper_y_strict_rejection_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightRefinement \
	  us_translation_unit_count
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightRefinement \
	  jp_translation_unit_count
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  route_collision_initializers_are_version_identical
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  pyramid_top_collision_words_exact_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  pyramid_top_collision_words_exact_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  pyramid_top_source_mesh_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  pyramid_top_source_edge_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  ssl_collision_array_word_counts_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  ssl_collision_array_word_counts_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  area1_actor_collision_initializers_are_version_identical
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  breakable_box_generated_vertex_bounds_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  breakable_box_generated_vertex_bounds_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  exclamation_box_generated_vertex_bounds_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  exclamation_box_generated_vertex_bounds_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  cannon_lid_generated_vertex_bounds_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  cannon_lid_generated_vertex_bounds_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  wooden_signpost_generated_vertex_bounds_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  wooden_signpost_generated_vertex_bounds_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  selected_area2_vertex_receipts_exact_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  selected_area2_vertex_receipts_exact_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  pyramid_elevator_vertices_exact_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  pyramid_elevator_vertices_exact_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  ssl_pu_level_script_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PyramidTopPU \
	  pyramid_top_pu_modeled_source_constants_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  find_floor_s16_coordinate_cast_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  find_floor_s16_coordinate_cast_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  mario_state_object_phase_split_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  mario_state_object_phase_split_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  update_objects_direct_callee_order_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  update_objects_direct_callee_order_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  platform_displacement_raw_pointer_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  platform_displacement_raw_pointer_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  platform_recompute_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  platform_recompute_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  spawning_clears_platform_us_but_not_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  upper_warp_phase_pipeline_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  upper_warp_phase_pipeline_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  object_warp_delayed_lifetime_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  object_warp_delayed_lifetime_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  pyramid_top_warp_geometry_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  pyramid_top_warp_geometry_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  stock_pyramid_top_yaw_only_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  stock_pyramid_top_yaw_only_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  pyramid_top_spin_explosion_pose_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  pyramid_top_spin_explosion_pose_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PyramidTopSurface \
	  pyramid_top_surface_semantic_kernel
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PyramidTopPU \
	  one_coordinate_cannot_contact_warp_and_capture_live_top
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PyramidTopPU \
	  upper_warp_center_overlaps_in_float32_model
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PyramidTopPU \
	  pu_top_candidate_does_not_overlap_warp_in_float32_model
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PyramidTopPU \
	  float32_warp_top_is_below_platform_capture_lower_bound
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PyramidTopPU \
	  stock_yaw_only_top_cannot_seed_upper_warp_bridge
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PyramidTopPU \
	  upper_warp_to_live_top_query_requires_385_y_units
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PyramidTopPU \
	  pu_top_candidate_alias_floor_arithmetic
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PyramidTopPU \
	  phase_split_countermodel_exists
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PyramidTopPU \
	  phase_split_candidate_requires_vertical_displacement
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PyramidTopPU \
	  xz_only_displacement_cannot_realize_phase_split_candidate
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PyramidTopPU \
	  us_spawn_clear_blocks_retained_epoch_before_first_apply
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PyramidTopPU \
	  pyramid_top_pu_arithmetic_kernel
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PyramidTopPU \
	  pyramid_top_explosion_minimum_pose_mirror_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PyramidTopPU \
	  pyramid_top_pu_checked_bundle
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  collection_provenance_reduction
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.OrdinaryMotion \
	  upper_entry_descent_source_shape_kernel_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.OrdinaryMotion \
	  upper_wall_and_cap_source_shape_kernel_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.OrdinaryMotion \
	  upper_ordinary_source_shape_kernel_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.OrdinaryMotion \
	  upper_ordinary_ascent_kernel_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.OrdinaryMotion \
	  wing_cap_rollout_arithmetic_countermodel
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  graphical_floor_fallback_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  graphical_floor_fallback_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  mario_entry_coordinate_sync_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  mario_entry_coordinate_sync_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  selected_ink_area1_vertex_receipts_exact_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  selected_ink_area1_vertex_receipts_exact_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  selected_ink_area1_triangle_words_exact_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  selected_ink_area1_triangle_words_exact_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  selected_ink_area1_surface_receipts_exact_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CollisionMeshFacts \
	  selected_ink_area1_surface_receipts_exact_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFallback \
	  ink_geometry_kernel_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFallback \
	  upper_warp_center_is_outside_checked_area1_water_boxes
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFallback \
	  ink_first_query_has_no_modeled_stock_dynamic_floor_candidate
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFallback \
	  arbitrary_ordinary_or_pu_state_only_prefix_needs_preexisting_split
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFallback \
	  dry_graphics_offset_cannot_supply_top_retry
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFallback \
	  prepared_landing_quicksand_raise_arithmetic_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFallback \
	  audited_graphics_y_gap_bound_is_below_ink_requirement
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFallback \
	  audited_area1_writer_execution_cannot_create_ink_ready
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFallback \
	  modeled_graphics_sink_does_not_change_pipeline_object
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFallback \
	  ink_local_conditional_pipeline_coordinate_witness
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFallback \
	  ink_pu_conditional_pipeline_coordinate_witness
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFallback \
	  ink_fallback_source_shape_kernel_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFallback \
	  ink_fallback_checked_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  current_verified_evidence_and_collection_reduction
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  current_ordinary_motion_evidence_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  current_ink_fallback_evidence_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  conditional_less_than_one_a_press_impossibility
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  conditional_target_clight_run_impossibility
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  transcript_route_gate_reduction
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  first_target_cut_coverage_reduction
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  first_target_cut_with_all_bypasses_excluded_requires_a_edge
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  evidence_bearing_route_cut_blocks_new_target_bits
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  conditional_evidence_bearing_clight_run_impossibility
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.TranscriptRouteModel \
	  no_a_target_access_requires_gate_bypass
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.TranscriptRouteModel \
	  no_a_target_access_requires_preceding_gate_bypass
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.TranscriptRouteModel \
	  closed_route_model_requires_one_a
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.TranscriptRouteModel \
	  spawning_displacement_escape_opens_both_target_regions
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.TranscriptRouteModel \
	  above_second_pole_access_opens_both_target_regions
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.SourceExhaustiveness \
	  normal_ssl_non_target_sources_do_not_alias_targets
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.SourceExhaustiveness \
	  coherent_game_state_reload_cannot_newly_set_either_target
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.SourceExhaustiveness \
	  anomaly_free_coherent_first_transition_is_normal_target_star
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CleanEntry \
	  clean_entry_save_reload_cannot_collect_target
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CleanEntry \
	  clean_entry_all_five_macro_respawn_bits_clear
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.AreaTransitions \
	  upper_consumption_uses_designated_static_trigger
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.AreaTransitions \
	  instant_warp_has_zero_displacement_core
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.AreaTransitions \
	  consumed_trigger_successor_updates_macro_and_deactivates_kind
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.AreaTransitions \
	  reload_and_macro_respawn_preserve_consumed_trigger_absence
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.AreaTransitions \
	  act6_spawn_uses_designated_controller_lineage
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.TranscriptRouteModel \
	  first_target_access_requires_gate_a_or_explicit_bypass
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.TranscriptRouteModel \
	  first_target_access_with_all_bypasses_excluded_requires_a_edge
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.TranscriptRouteModel \
	  no_a_first_target_access_requires_explicit_bypass
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstTargetRefinement \
	  projected_event_writer_inventory_is_total
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstTargetRefinement \
	  direct_instant_warp_displacement_is_impossible
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstTargetRefinement \
	  target_identity_anomaly_is_impossible
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstTargetRefinement \
	  macro_lifecycle_anomaly_is_impossible
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstTargetRefinement \
	  save_reload_target_mutation_is_impossible
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstTargetRefinement \
	  projection_mismatch_is_impossible_with_certificate
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstTargetRefinement \
	  evidence_bypass_reduces_to_open_route_writer_classes
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstTargetRefinement \
	  aligned_newly_collected_target_reaches_first_cut_domain
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstTargetRefinement \
	  evidence_classifier_with_open_writers_closed_blocks_new_target_bits
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstTargetRefinement \
	  endpoint_only_alignment_does_not_imply_cut_classification
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstTargetRefinement \
	  prelude_retained_inactive_top_slot_is_a_raw_platform_case
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstTargetRefinement \
	  prelude_reused_top_slot_is_a_raw_platform_case
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstTargetRefinement \
	  prelude_bridge_enters_clean_jp_upper_with_retained_platform
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstTargetRefinement \
	  prelude_bridge_exposes_exact_platform_payload
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstTargetRefinement \
	  upper_warp_stale_top_conditional_path_is_platform_evidence
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPSlotLifetime \
	  jp_delayed_warp_slot_boundary_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PhaseSplit \
	  area1_fragment_writer_source_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PhaseSplit \
	  area1_fragment_parent_source_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PhaseSplit \
	  area1_box_rebound_source_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PhaseSplit \
	  area1_box_action4_and_fragment_pivot_y_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PhaseSplit \
	  area1_fragment_rng_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PhaseSplit \
	  area1_fragment_sine_table_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PhaseSplit \
	  concrete_area1_fragment_displacement_is_route_sized_3d
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PhaseSplit \
	  captured_top_epoch_cannot_bootstrap_upper_warp_collision
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PhaseSplit \
	  captured_top_epoch_cannot_realize_route_relevant_phase_split
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PhaseSplit \
	  area1_phase_split_boundary_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1SurfaceWitness \
	  area1_surface_capability_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PlatformExhaustiveness \
	  area1_macro_surface_owner_source_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PlatformExhaustiveness \
	  area1_regular_surface_source_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PlatformExhaustiveness \
	  area1_inbound_and_route_source_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PlatformExhaustiveness \
	  area1_inbound_and_route_packed_arithmetic
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PlatformExhaustiveness \
	  area1_surface_owner_finite_inventory
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PlatformExhaustiveness \
	  upper_warp_has_no_stock_dynamic_floor_candidate
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PlatformExhaustiveness \
	  stock_upper_warp_final_query_clears_platform
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PlatformExhaustiveness \
	  stock_area1_preapply_schedule_classified
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PlatformExhaustiveness \
	  stock_area1_upper_warp_preapply_platform_null
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PlatformExhaustiveness \
	  sound_projected_upper_warp_preapply_platform_null
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PlatformExhaustiveness \
	  stock_upper_warp_has_no_platform_created_route_split
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PlatformExhaustiveness \
	  area1_candidate_free_list_alignment
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PlatformExhaustiveness \
	  area1_candidate_count_arithmetic_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PlatformExhaustiveness \
	  area1_candidate_cannot_trigger_upper_warp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PlatformExhaustiveness \
	  concrete_area1_candidate_is_three_dimensional
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PlatformExhaustiveness \
	  area1_platform_source_model_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstCrossingWriterCoverage \
	  an_unvalidated_cut_can_place_one_state_on_both_sides
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstCrossingWriterCoverage \
	  changed_non_target_position_has_a_complete_writer_class
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstCrossingWriterCoverage \
	  validated_pre_target_first_crossing_writer_coverage
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstCrossingWriterCoverage \
	  certified_nonspatial_admin_preserves_kinematics
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstCrossingWriterCoverage \
	  changed_area_reload_returns_to_entry_snapshot
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstCrossingWriterCoverage \
	  lifecycle_entry_displacement_is_impossible_for_validated_cut
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstCrossingWriterCoverage \
	  local_cast_domain_implies_horizontal_coordinates_local
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstCrossingWriterCoverage \
	  coordinate_alias_is_impossible_if_projected_endpoints_stay_local
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstCrossingWriterCoverage \
	  no_a_complete_writer_exclusions_rule_out_validated_first_crossing
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.FirstCrossingWriterCoverage \
	  area1_upper_warp_platform_bootstrap_closed_subcase
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  validated_first_crossing_writer_reduction
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ModelGapAudit \
	  current_certified_motion_accepts_arbitrary_endpoint
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ModelGapAudit \
	  current_abstract_counterexample_exists_for_every_target_entry
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.EntryMemory \
	  us_mario_state_layout
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.EntryMemory \
	  jp_mario_state_layout
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.EntryMemory \
	  retail_entry_postcondition_projects
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1FirstNull \
	  area1_q_static_candidate_inventory_sizes
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1FirstNull \
	  area1_generated_initializer_inventory_certificate
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1FirstNull \
	  area1_q_static_floor_signed_arithmetic_receipt
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1FirstNull \
	  area1_q_decisive_loaded_plane_binary32_receipt
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1FirstNull \
	  area1_q_static_all_rejection_checks_computed
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1FirstNull \
	  area1_q_static_traversal_computed
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1FirstNull \
	  area1_west_wall_minus_2199_is_accepted_and_pushed
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1FirstNull \
	  area1_west_wall_minus_2200_is_rejected
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFallback \
	  thadortin_floor_case_split_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFallback \
	  ink_second_null_frame_latches_fatal_before_upper_warp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFallback \
	  riding_shell_offsets_do_not_accumulate_across_normal_frames
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFallback \
	  abstract_wall_or_floor_selected_height_cannot_enlarge_shell_gap
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFallback \
	  shell_binary32_endpoint_delta_can_exceed_source_operand
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  shell_ground_quicksand_reset_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  shell_ground_quicksand_reset_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  shell_air_quicksand_reset_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  shell_air_quicksand_reset_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  warp_precedes_shell_interaction_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  warp_precedes_shell_interaction_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  wall_position_writer_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  wall_position_writer_source_shape_jp

clean:
	-$(MAKE) -f $(COQMAKEFILE) clean
	rm -f $(COQMAKEFILE) $(COQMAKEFILE).conf .*.aux
