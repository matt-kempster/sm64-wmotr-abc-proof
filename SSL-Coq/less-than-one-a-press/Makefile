COQMAKEFILE := CoqMakefile
COQBIN ?=
COQMAKEFILE_CMD ?= $(COQBIN)coq_makefile

.PHONY: all generated regenerate verify-generated proofs check clean

all: proofs

generated:
	bash pipeline/generate-clight.sh

regenerate: generated

verify-generated:
	bash pipeline/check-generated.sh

$(COQMAKEFILE): _CoqProject
	$(COQMAKEFILE_CMD) -f _CoqProject -o $(COQMAKEFILE)

proofs: $(COQMAKEFILE)
	$(MAKE) -f $(COQMAKEFILE)

check: proofs
	bash pipeline/check-no-admitted.sh
	bash pipeline/check-link-hygiene.sh
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.LinkedClightPrograms \
	  generated_whole_program_link_is_blocked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.LinkedClightPrograms \
	  us_compcert_clight_link_list_has_no_result
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.LinkedClightPrograms \
	  jp_compcert_clight_link_list_has_no_result
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NormalizedClightPrograms \
	  us_normalized_make_program_success_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NormalizedClightPrograms \
	  jp_normalized_make_program_success_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.USViewportRepairedProgramCertificate \
	  us_viewport_repaired_program_success_flag_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.SelectedClightTarget \
	  selected_clight_target_builds_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.SelectedClightTarget \
	  original_units_header_normalization_structural_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.SelectedClightTarget \
	  jp_selected_target_syntax_audit_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPOfficialInitialMemory \
	  jp_official_cleaned_initial_memory_exists
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPThread5EntryResolution \
	  jp_thread5_game_loop_resolves_exact_body
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPWarpLevelEntryResolution \
	  jp_warp_level_resolves_exact_body
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPSelectedRuntimeTaskStart \
	  jp_selected_runtime_task_start_exists
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPSelectedRuntimeTaskStart \
	  jp_selected_target_source_refinement_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.GlobalInterfaceStructural \
	  generic_checked_cleaned_definition_exactness_capstone
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ConcreteDefinitionSelection \
	  us_cleaned_definition_selection_exact_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ConcreteDefinitionSelection \
	  jp_cleaned_definition_selection_exact_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.USArea1ObjectListNthReceipt \
	  us_object_list_processor_gObjectListArray_nth_error_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.USArea1LevelUpdateNthReceipt \
	  us_level_update_gMarioState_nth_error_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.USArea1PlatformNthReceipt \
	  us_platform_displacement_gMarioPlatform_nth_error_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.USArea1SpinBehaviorNthReceipt \
	  us_ssl_script_bhvSpinAirborneWarp_nth_error_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.RetailExternalFrameReachability \
	  legacy_external_call_frame_implies_reachable_frame
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.DialogDepthFiniteInventory \
	  dialog_depth_finite_inventory_obligation_closed
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightProjectionChronology \
	  observed_selected_target_refinement_supplies_selected_refinement
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPCoordinateLvalueReceiverPartition \
	  jp_coordinate_lvalue_receiver_partition_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPSourceSymbolTransport \
	  jp_source_definition_has_official_symbol
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPArea1SymbolPlatformReceipt \
	  jp_official_area1_platform_pointer_symbol_exists
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPArea1EntrySymbolResolution \
	  jp_official_area1_entry_symbol_structure_closed
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPSelectedTargetAudit \
	  jp_selected_target_core_symbols_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPSelectedTargetAudit \
	  jp_selected_target_audit_transport_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPSelectedTargetAudit \
	  jp_selected_target_refinement_from_target_clight
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.USWarpLevelEntryResolution \
	  us_warp_level_resolves_exact_body
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.USRepairedSyntaxAudit \
	  us_selected_target_syntax_audit_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.USSelectedTargetAudit \
	  us_selected_target_core_symbols_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.USSelectedTargetAudit \
	  us_selected_target_audit_transport_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1EntryZeroAPrefix \
	  jp_ordinary_area1_prefix_fixes_zero_a_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1EntryZeroAPrefix \
	  jp_official_cleaned_ordinary_area1_prefix_fixes_zero_a_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1EntryZeroAPrefix \
	  us_viewport_repaired_ordinary_area1_prefix_fixes_zero_a_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.DefaultArea1StartBoundary \
	  default_area1_start_fixes_clean_zero_a_baseline
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.DefaultArea1StartChronology \
	  default_area1_active_run_decodes_null_chronology_seed
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.DefaultArea1StartChronology \
	  default_area1_active_preapply_has_no_jp_inbound_final_lineage
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.DefaultArea1StartChronology \
	  default_area1_start_refinement_is_nonvacuous
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NormalizedClightPrograms \
	  us_residual_function_signature_mismatch_count_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NormalizedClightPrograms \
	  jp_residual_function_signature_mismatch_count_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CleanedClightPrograms \
	  us_normalized_cleaned_units_official_link_structural
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CleanedClightPrograms \
	  jp_normalized_cleaned_units_official_link_structural
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CompositeOfficialLinkBridge \
	  us_structural_link_precedes_composite_environment_bridge
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CompositeOfficialLinkBridge \
	  jp_structural_link_precedes_composite_environment_bridge
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CompositeOfficialLinkBridge \
	  us_official_cleaned_viewport_wrapper_has_wrong_size
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.USClightLinkRefinementCertificates \
	  us_exact_residual_composite_mismatches_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPClightLinkRefinementCertificates \
	  jp_named_residuals_have_equal_checked_storage_layouts
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.USClightLinkRefinementCertificates \
	  us_core_declaration_composite_audit_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPClightLinkRefinementCertificates \
	  jp_core_declaration_composite_audit_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.USClightLinkRefinementCertificates \
	  us_all_viewport_538_alpha_renaming_layout_constructed
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.USViewportReferenceCertificates \
	  us_affected_viewport_globals_audit_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  us_official_source_definition_provenance
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  jp_official_source_definition_provenance
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  us_official_internal_body_evar_resolves
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  jp_official_internal_body_evar_resolves
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  us_official_init_addrof_identifier_resolves
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  jp_official_init_addrof_identifier_resolves
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  us_normalized_external_constructor_partition
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  jp_normalized_external_constructor_partition
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  us_official_external_has_supported_constructor
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  jp_official_external_has_supported_constructor
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  us_reachable_official_external_callstate_is_classified
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  jp_reachable_official_external_callstate_is_classified
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  us_official_target_has_no_direct_sbuiltin
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  jp_official_target_has_no_direct_sbuiltin
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  named_global_evar_lvalue_execution_bridge
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  external_call_executes_across_global_interface
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  clight_external_callstate_step_injects
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  clight_sbuiltin_step_injects_after_argument_evaluation
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightLinkExecution \
	  clight_sbuiltin_step_obeys_explicit_frame
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.USWholeASTTagRepair \
	  map_fst_repair_us_selected_global_definitions
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightGlobalMemoryRefinement \
	  us_concrete_strong_definition_membership_agreement
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightGlobalMemoryRefinement \
	  matched_program_initial_memory_is_relocation_aware
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.RetailExternalFrames \
	  recognized_builtin_preserves_us_retail_state
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.RetailExternalFrames \
	  official_direct_sbuiltin_frame_boundary_closed
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightEndToEndRefinement \
	  deref_loc_inject_same_type
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightEndToEndRefinement \
	  checklist_current_injection_preserves_pointer_validity
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightEndToEndRefinement \
	  checklist_current_injection_transports_pointer_read
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightEndToEndRefinement \
	  checklist_current_injection_transports_pointer_write
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightEndToEndRefinement \
	  clight_lockstep_initial_to_final_execution
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.OrdinaryArea1EntryMemory \
	  ordinary_area1_entry_source_kernel_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.OrdinaryArea1EntryMemory \
	  ordinary_entry_contract_permits_held_a
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.OrdinaryArea1EntryMemory \
	  distinct_valid_object_slot_ptrofs_do_not_alias
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.OrdinaryArea1EntryMemory \
	  distinct_valid_object_slot_vptrs_do_not_alias
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.OrdinaryArea1EntryMemory \
	  ordinary_area1_entry_checked_boundary_holds
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
	  LessThanOneAPress.Proofs.Area1NonlocalCastSemantics \
	  area1_nonlocal_cast_checked_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1NonlocalCastSemantics \
	  compcert_horizontal_terrain_cast_case_total
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1InvalidCastArithmetic \
	  representative_failed_casts_trap_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1InvalidCastArithmetic \
	  signed_word_boundary_casts_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1NonlocalYCastArithmetic \
	  timer131_nonlocal_y_vector_cast_components_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1NonlocalYCastArithmetic \
	  timer131_nonlocal_vector_cast_semantics_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1NonlocalEndpointBoundary \
	  area1_nonlocal_endpoint_checked_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1NonlocalEndpointBoundary \
	  nonlocal_y_state_first_numeric_capability_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1StateFirstWallExclusion \
	  area1_state_first_wall_exclusion_checked_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1StateFirstRetailTrace \
	  jp_area1_state_first_retail_trace_record_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1StateFirstRetailTrace \
	  jp_area1_state_first_lifecycle_record_checked
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
	  LessThanOneAPress.Proofs.Area2ElevatorCut \
	  upper_elevator_checked_geometry_and_ascent_kernel
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area2ElevatorCut \
	  upper_elevator_no_a_target_access_is_closed_under_relative_obligations
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area2LowerTargetCut \
	  area2_lower_target_cut_checked_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area2LowerTargetCut \
	  lower_float32_collision_phase_target_event_is_closed_under_complete_case_split
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area2LowerTargetCut \
	  lower_target_no_a_target_access_is_closed_under_adapter_obligations
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area2DownstreamContinuations \
	  area2_downstream_checked_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area2DownstreamContinuations \
	  transcript_act3_stage_orders_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area2DownstreamReceipts \
	  conditional_jp_downstream_receipt_checked
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
	  LessThanOneAPress.Proofs.InkPayloadInstaller \
	  exact_installer_timer_schedule_is_consistent
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkPayloadInstaller \
	  area1_installer_and_first_area2_effect_compose
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Timer131Surface \
	  timer131_robust_interior_retry_is_accepted
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Timer131Surface \
	  timer131_surface_checked_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Timer131Surface \
	  timer131_warp_retry_requires_at_least_632_graphics_y_gap
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Timer131Surface \
	  timer131_bounded_writer_cannot_install_retry
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Timer131Surface \
	  timer131_jp_probe_observation_record_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Timer131Surface \
	  timer131_midface_retry_is_accepted
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Timer131Surface \
	  timer131_midface_retry_requires_at_least_960_graphics_y_gap
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Timer131Surface \
	  timer131_jp_midface_capture_observation_record_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.GoombaRaising \
	  goomba_velocity_after_gravity_binary32_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.GoombaRaising \
	  goomba_position_delta_need_not_be_exact_21
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.GoombaRaising \
	  pyramid_top_y51_after_31_float32_rises_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.GoombaRaising \
	  pyramid_top_y51_after_83_float32_rises_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.GoombaRaising \
	  first_productive_cycle_enters_repeating_ready_state
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.GoombaRaising \
	  finite_goomba_productive_cycles
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.GoombaRaising \
	  goomba_raising_bounded_kernel
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  goomba_state_machine_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  goomba_state_machine_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  goomba_player_collision_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  goomba_player_collision_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  spindel_pu_station_source_shape_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  spindel_pu_station_source_shape_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  delayed_warp_assignment_census_exact_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  delayed_warp_assignment_census_exact_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  delayed_warp_explicit_address_sites_empty_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ClightFacts \
	  delayed_warp_explicit_address_sites_empty_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.RetailFatalLatch \
	  retail_fatal_persists_or_reset_destroys_disappeared
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.RetailFatalLatch \
	  retail_fatal_latch_checked_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkFirstNullRetryNecessity \
	  ink_first_null_retry_necessity_checked_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  current_verified_evidence_and_collection_reduction
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  current_jp_first_apply_finite_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  current_ink_payload_installer_timer_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  current_ordinary_motion_evidence_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  current_goomba_raising_bounded_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  current_goomba_raising_source_event_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  current_ink_fallback_evidence_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  current_retail_fatal_latch_boundary
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
	  LessThanOneAPress.Proofs.JPFirstApply \
	  jp_pre_true_first_apply_count_exact
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPFirstApply \
	  jp_spindel_conditional_ordinal_bundle
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPFirstApply \
	  pool_slot_60_and_free_list_depth_60_are_not_equivalent
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPFirstApply \
	  first_poll_fixture_boundary_is_after_first_apply_before_second
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPLifecycleTrace \
	  jp_lifecycle_clight_shape_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPLifecycleTrace \
	  jp_state_only_setter_clight_shape_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPLifecycleTrace \
	  jp_retail_apply_disassembly_receipt_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPLifecycleTrace \
	  jp_retail_apply_word18_decodes_platform_displacement_call
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPLifecycleTrace \
	  jp_top_survives_true_first_apply_allocations_at_depth_47
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPLifecycleTrace \
	  authenticated_jp_lifecycle_boundary_trace_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPLifecycleTrace \
	  observed_true_first_apply_creates_state_object_graphics_phase_split
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPLifecycleTrace \
	  observed_boundary_closes_lifecycle_and_upper_trigger_continuation
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPLifecycleTrace \
	  authenticated_jp_full_route_observation_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPLifecycleTrace \
	  conditional_jp_full_route_reaches_spawn_but_not_collection
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.StateFirstInstaller \
	  jp_observed_act6_pickup_overlaps_binary32_model
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.StateFirstInstaller \
	  jp_observed_receipt_is_new_act6_collection
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.StateFirstInstaller \
	  jp_observed_act6_pickup_projection_has_no_a_edge
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.StateFirstInstaller \
	  conditional_jp_zero_a_act6_collection_continuation
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
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.TurningAnimation \
	  turning_animation_source_kernel_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.TurningAnimation \
	  turning_part2_metadata_step_preserves_gameplay_coordinates
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.TurningAnimation \
	  turning_part2_metadata_cannot_create_ink_split
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.TurningAnimation \
	  over_permissive_animation_dma_alias_counterexample
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CleanJPGraphicsGap \
	  clean_jp_graphics_gap_source_shape_kernel_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CleanJPGraphicsGap \
	  jp_timer131_midface_requires_writer_coverage_escape
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.CleanJPGraphicsGap \
	  clean_jp_area1_projected_certified_trace_cannot_install_midface
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPQuicksandDepth \
	  jp_quicksand_direct_writer_inventory_moving
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPQuicksandDepth \
	  jp_quicksand_direct_writer_inventory_interaction
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPQuicksandDepth \
	  jp_long_jump_a_edge_source_shape
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPQuicksandDepth \
	  jp_long_jump_selected_unit_call_inventory
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPQuicksandDepth \
	  jp_dialog_depth_and_sink_source_shape
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPQuicksandDepth \
	  jp_negative_common_landing_after_dispatch_is_timer_five
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPQuicksandDepth \
	  jp_source_shaped_safe_depth_trace_from_zero_is_nonnegative
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPQuicksandDepth \
	  jp_nonnegative_depth_dialog_cannot_increase_gap
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPQuicksandDepth \
	  jp_negative_depth_dialog_zero_base_endpoint_binary32_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPQuicksandDepth \
	  jp_warp_range_live_base_381_sinks_binary32_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPQuicksandDepth \
	  jp_warp_range_live_base_integer_gap_meets_timer131_requirement
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_generated_quicksand_depth_direct_writer_census
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_generated_pos_y_direct_assignment_partition
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_generated_gfx_pos_y_direct_assignment_counts
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_generated_gfx_y_writer_residual_split_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_receiver_generic_gfx_y_four_role_split_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_obj_set_gfx_pos_from_pos_same_receiver_y_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_obj_update_gfx_pos_and_angle_identity_reachability_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_mario_direct_callbacks_do_not_write_tail_flag_or_offset_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_generated_rawdata_asf32_7_direct_assignment_counts
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_generated_rawdata_asf32_10_direct_assignment_counts
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_generated_throw_matrix_assignment_partition
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_generated_long_jump_constructor_call_census
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_generated_long_jump_literal_expression_census
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_generated_automatic_dialog_constructor_call_census
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_generated_automatic_dialog_constructor_classification
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_automatic_dialog_reanchor_source_shape_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_generated_mario_object_global_assignment_census
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_generated_active_area_index_direct_writer_census
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPGeneratedWriterCensus \
	  jp_mario_area_lifetime_source_shape_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPActionProvenanceCensus \
	  jp_generated_action_provenance_syntax_kernel_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPBinary32DepthWrites \
	  jp_binary32_safe_writer_outcome_preserves_nonnegative
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPBinary32DepthWrites \
	  jp_binary32_safe_writer_trace_from_clean_zero_is_not_clight_negative
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPLongJumpLandingDepth \
	  jp_timer_four_split_depth_binary32_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPLongJumpLandingDepth \
	  jp_timer_five_split_depth_binary32_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPLongJumpLandingDepth \
	  jplld_240_times_four_is_960
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.AutomaticDialogReanchoring \
	  automatic_dialog_is_cutscene_group_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.AutomaticDialogReanchoring \
	  us_automatic_dialog_no_recognized_direct_reanchor_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.AutomaticDialogReanchoring \
	  jp_automatic_dialog_no_recognized_direct_reanchor_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.AutomaticDialogReanchoring \
	  modeled_reanchor_then_stall_with_same_depth_has_double_gap
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.AutomaticDialogReanchoring \
	  open_automatic_dialog_can_stall_for_any_finite_frame_count
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ActionDepthAliasCensus \
	  us_jp_sensitive_scalar_address_taking_census_is_empty
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ActionDepthAliasCensus \
	  us_jp_two_indirect_mario_state_calls_have_exact_source_shapes
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ActionDepthAliasCensus \
	  us_jp_long_jump_landing_descriptor_source_boundary
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandCrossing \
	  a1ljq_crossing_data_exact_us
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandCrossing \
	  a1ljq_crossing_data_exact_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandCrossing \
	  a1ljq_pre_sample_projection_classified
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandCrossing \
	  a1ljq_post_sample_projection_classified
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandCrossing \
	  a1ljq_vertical_drop_is_below_100
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandRetailTrace \
	  a1ljqrt_receipt_has_exactly_four_quarters
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandRetailTrace \
	  a1ljqrt_every_selected_floor_is_static_shallow
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandRetailTrace \
	  a1ljqrt_every_wall_and_ceiling_query_is_clear
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandRetailTrace \
	  a1ljqrt_exact_committed_position_words
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandRetailTrace \
	  a1ljqrt_prepared_trace_does_not_end_at_exact_4900
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandRetailTrace \
	  a1ljqrt_both_timer_summaries_are_well_formed
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandRetailTrace \
	  a1ljqrt_timer_and_depth_summaries_are_exact
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandRetailTrace \
	  a1ljqrt_us_jp_timer3_timer4_run_matrix_is_exact
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandNextFrameTrace \
	  a1ljqg_receipt_has_exactly_four_quarters
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandNextFrameTrace \
	  a1ljqg_every_selected_floor_is_static_shallow
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandNextFrameTrace \
	  a1ljqg_every_wall_and_ceiling_query_is_clear
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandNextFrameTrace \
	  a1ljqg_exact_committed_position_words
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandNextFrameTrace \
	  a1ljqg_us_and_jp_run_receipts_are_exact_and_well_formed
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandNextFrameTrace \
	  a1ljqg_prepared_star_first_hitbox_is_home_minus_five
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandNextFrameTrace \
	  a1ljqg_prepared_raw_vertical_margin_exceeds_96
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1LongJumpQuicksandNextFrameTrace \
	  a1ljqg_prepared_graphics_top_is_below_star_first_hitbox
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.LongJumpProvenanceBoundary \
	  us_jp_landing_descriptor_frames_source_receipt
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.LongJumpProvenanceBoundary \
	  us_jp_long_jump_descriptor_payload_source_receipt
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.LongJumpProvenanceBoundary \
	  bilateral_long_jump_source_chain_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.LongJumpProvenanceBoundary \
	  clean_us_jp_entry_trace_cannot_reach_long_jump_cycle
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ZeroAQuicksandEntryBoundary \
	  clean_pyramid_entry_action_excludes_long_jump_cycle
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ZeroAQuicksandEntryBoundary \
	  retail_pyramid_entry_memory_excludes_prepared_fixture
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ZeroAQuicksandEntryBoundary \
	  ordinary_area1_entry_memory_excludes_prepared_fixture
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ZeroAQuicksandEntryBoundary \
	  stock_landing_negative_from_nonnegative_requires_long_jump
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ZeroAQuicksandEntryBoundary \
	  generated_descriptor_frames_match_stock_landing_kinds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ZeroAQuicksandEntryBoundary \
	  zero_a_ordinary_long_jump_source_boundary_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ZeroAQuicksandEntryBoundary \
	  zero_a_ordinary_source_kernels_exclude_prepared_negative_state
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NegativeDepthForgeryBoundary \
	  all_landing_descriptors_have_no_direct_generated_assignment
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NegativeDepthForgeryBoundary \
	  landing_descriptor_address_sites_are_exact
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NegativeDepthForgeryBoundary \
	  non_long_negative_body_requires_descriptor_frame_corruption
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NegativeDepthForgeryBoundary \
	  interaction_handler_table_initializer_is_exact_bilateral
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NegativeDepthForgeryBoundary \
	  indirect_mario_state_calls_are_guarded_landing_or_interaction_table
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NegativeDepthForgeryBoundary \
	  held_node_indexed_transform_writer_is_present_bilateral
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NegativeDepthForgeryBoundary \
	  changed_action_cell_requires_same_block_and_byte_overlap
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NoExitStarDialogBridge \
	  no_exit_star_bridge_source_shape_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NoExitStarDialogBridge \
	  no_exit_star_hitbox_initializer_exact_us_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NoExitStarDialogBridge \
	  no_exit_star_behavior_initializer_exact_us_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NoExitStarDialogBridge \
	  object_list_update_order_exact_us_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NoExitStarDialogBridge \
	  star_dialog_milestones_exact_us_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NoExitStarDialogBridge \
	  freshly_spawned_star_first_eligible_after_gap_frame
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NoExitStarDialogBridge \
	  fresh_star_late_landing_followup_binary32_split_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NoExitStarDialogBridge \
	  fresh_star_prepared_vertical_orbit_settles_five_below_home
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NoExitStarDialogBridge \
	  fresh_star_prepared_home_and_first_hitbox_y_binary32_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NoExitStarDialogBridge \
	  prepared_settled_star_same_height_mario_does_not_overlap
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.DialogDepthMemoryFrame \
	  dialog_depth_control_layout_exact_us_jp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.DialogDepthMemoryFrame \
	  dialog_depth_spine_direct_nonwriter_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.DialogDepthMemoryFrame \
	  finite_dialog_depth_framed_stores_preserve_exact_word
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.DialogDepthMemoryFrame \
	  us_area1_object_pool_store_preserves_dialog_depth_load
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.DialogDepthMemoryFrame \
	  jp_area1_object_pool_store_preserves_dialog_depth_load
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NegativeDepthTimer131Bridge \
	  negative_depth_boundary_is_outside_fixed_upper_warp
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NegativeDepthTimer131Bridge \
	  fixed_upper_warp_contact_requires_boundary_x_transport
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NegativeDepthTimer131Bridge \
	  vertical_dialog_amplification_does_not_supply_warp_xz
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NegativeDepthTimer131Bridge \
	  split_negative_depths_become_positive_one_point_six
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.NegativeDepthTimer131Bridge \
	  post_dialog_idle_walk_source_shape_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1EntryDepthClosure \
	  ordinary_area1_entry_memory_synchronizes_all_coordinates
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1EntryDepthClosure \
	  stock_area1_static_door_source_excluded
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1EntryDepthClosure \
	  us_stock_ssl_area1_macro_decoder_is_total
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1EntryDepthClosure \
	  jp_stock_ssl_area1_macro_decoder_is_total
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1EntryDepthClosure \
	  stock_area1_direct_source_omits_pyramid_top_children
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPDestinationChronologyCertificate \
	  jp_authenticated_top_is_not_a_destination_allocation
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPDestinationChronologyCertificate \
	  jp_cleaned_object_pool_declarations_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPDestinationChronologyCertificate \
	  jp_cleaned_object_pool_definition_count_is_one
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPDestinationChronologyCertificate \
	  jp_authenticated_top_pointer_is_pool_block_plus_37088
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPLinkedObjectPoolInitialMemory \
	  jp_linked_object_pool_initial_memory_obligation_closed
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InstallerCoverage \
	  installer_coverage_checked_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.StockWarpTopMotion \
	  stock_upper_warp_direct_writer_source_boundary_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.StockWarpTopMotion \
	  stock_top_direct_motion_source_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.StockWarpTopMotion \
	  stock_top_nonspinning_direct_position_source_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.StockWarpTopMotion \
	  stock_top_sine_table_source_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.StockWarpTopMotion \
	  modeled_stock_top_all_spinning_timers_bounded_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PlatformPointerProvenance \
	  official_platform_pointer_syntax_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.StockProjectionExhaustiveness \
	  stock_projection_abstract_checked_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PrecollisionWriterClosure \
	  area1_precollision_writer_source_boundary_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PolePushSchedule \
	  area1_pole_push_list_order_source_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PolePushSchedule \
	  preplayer_pole_push_cannot_survive_completed_player_copy
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PolePushLinkage \
	  area1_static_data_excludes_cylinder_push_families
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PolePushLinkage \
	  area1_stock_pole_tree_push_is_preplayer_and_copy_resynchronized
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1InstallerTemporalClosure \
	  area1_installer_temporal_checked_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.StateFirstPlatformChronology \
	  projected_state_first_platform_installer_is_exhaustively_classified
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.StateFirstPlatformChronology \
	  stock_closed_projection_rules_out_state_first_platform_apply
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.StateFirstPlatformChronology \
	  null_seed_chronology_cannot_produce_jp_inbound
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1GapApproachCoverage \
	  area1_gap_approach_coverage_checked_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1GapApproachCoverage \
	  trace_ending_in_gap_has_state_object_or_joint_first_creator
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1GapApproachCoverage \
	  gap_preserving_trace_has_first_creator_and_classified_suffix
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1GapApproachCoverage \
	  precollision_split_expands_to_data_bearing_stage_approach
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1GapApproachCoverage \
	  area1_warp_interaction_cache_coverage_checked_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PostCopyTailClassification \
	  area1_postcopy_tail_classification_checked_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PostCopyTailClassification \
	  successful_copy_final_split_requires_value_changing_tail_edge
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PostPlayerTailSource \
	  area1_post_player_tail_source_audit_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PostPlayerTailSource \
	  area1_breakable_triangle_spawn_path_source_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PostPlayerTailSource \
	  mario_post_copy_intra_player_residual_source_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PostPlayerTailSource \
	  mario_particle_behaviors_are_list8_source_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PostCopyObjectWriterClosure \
	  area1_postcopy_direct_designated_object_writer_checked_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PostCopyObjectWriterClosure \
	  explicit_cached_y_768_only_stock_query_is_null
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PostCopyObjectWriterClosure \
	  exact_center_cached_floor_only_stock_query_is_null
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PostCopyAliasCallbackClosure \
	  area1_postcopy_alias_callback_source_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1PostCopyAliasCallbackClosure \
	  valid_changed_mario_raw_load_requires_same_slot
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1InteractionShortCircuitClosure \
	  area1_interaction_short_circuit_source_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1InteractionShortCircuitClosure \
	  accepted_nonfading_warp_only_cached_floor_y_can_change_sample
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1InteractionShortCircuitClosure \
	  accepted_nonfading_warp_cached_y_768_stock_query_is_null
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1CachedFloorSelectionClosure \
	  area1_cached_floor_selection_finite_model_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1CachedFloorSelectionClosure \
	  warp_horizontal_low_y_stock_query_is_null
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1CachedFloorSelectionClosure \
	  accepted_nonfading_warp_cached_floor_selection_stock_query_is_null
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1CachedFloorSplitWitness \
	  area1_cached_floor_split_witness_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1CachedFloorSplitWitness \
	  accepted_nonfading_warp_difference_is_y_only
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1CachedFloorSplitWitness \
	  cached_floor_split_stock_platform_query_is_null
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1ButterflyStaticOriginClosure \
	  butterfly_area1_selector_exclusion_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.LinkedPlatformLineageSyntax \
	  linked_platform_lineage_syntax_checked_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.LinkedPlatformLineageSyntax \
	  four_null_seed_linked_lineage_closures_rule_out_installer
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PlatformAliasExternalClosure \
	  official_platform_alias_origins_reduce_to_semantic_escapes
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PlatformExternalGapSemantics \
	  reachable_unresolved_external_changed_load_is_refined
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PlatformExternalGapSemantics \
	  defined_store_creating_object_state_gap_targets_one_endpoint
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.PlatformExternalGapSemantics \
	  reachable_unresolved_external_created_object_state_gap_is_refined
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPLinkedPlatformGlobal \
	  jp_generated_platform_ast_boundary_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPLinkedPlatformGlobal \
	  jp_surface_owner_to_platform_fragment_executes
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPLinkedPlatformGlobal \
	  jp_successful_platform_store_is_true_apply_loaded_owner_under_frame
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1QueryScheduleClosure \
	  area1_final_query_overwrite_source_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.SelectedPlatformUpdateBodyResolution \
	  selected_platform_update_body_query_receipt_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1QueryScheduleClosure \
	  area1_query_schedule_checked_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1MovingSkippedQueryClosure \
	  area1_moving_skipped_query_checked_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1MovingSkippedQueryClosure \
	  linked_boundary_reduces_moving_skip_to_preservation
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1SchedulerSurfaceLifecycleSplit \
	  area1_scheduler_surface_lifecycle_split_checked_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1SchedulerSurfaceLifecycleSplit \
	  area1_callback_surface_direct_source_union_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1SchedulerSurfaceLifecycleSplit \
	  modeled_stock_install_split_is_independent_of_supplied_lifecycle_fate
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1Rank1OrdinaryBridgeNoGo \
	  area1_rank1_ordinary_bridge_no_go_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1Rank1OrdinaryBridgeNoGo \
	  ordinary_top_install_no_go_is_independent_of_supplied_lifecycle_fate
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.DefaultArea1Rank1ResidualCapstone \
	  default_area1_rank1_residual_checked_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.DefaultArea1Rank1ResidualCapstone \
	  default_area1_active_preapply_requires_completed_query_residual
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.DefaultArea1Rank1ResidualCapstone \
	  default_area1_completed_query_difference_expands_to_seven_approaches
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.DefaultArea1Rank1BoundaryUnderdetermination \
	  rank1_boundary_fabricated_preapply_inhabits_canonical_residual
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.DefaultArea1Rank1BoundaryUnderdetermination \
	  default_area1_active_jp_boundary_accepts_fabricated_rank1_installer
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.DefaultArea1Rank1BoundaryUnderdetermination \
	  jp_default_boundary_alone_cannot_exclude_rank1_top_installer
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1SurfaceOwnerSyntax \
	  area1_surface_owner_source_boundary_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1SurfaceEpochLifecycle \
	  area1_surface_epoch_lifecycle_boundary_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1SurfaceEpochLifecycle \
	  inactive_same_epoch_nonzero_payload_opens_state_object_split
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1SurfaceEpochLifecycle \
	  independent_different_sample_and_fresh_reuse_witnesses_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1WarpTopCloneCensus \
	  ordinary_object_copy_does_not_copy_identity_or_collision
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1WarpTopCloneCensus \
	  us_top_static_reference_census
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1WarpTopCloneCensus \
	  jp_top_static_reference_census
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1WarpTopCloneCensus \
	  us_warp_static_reference_census
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1WarpTopCloneCensus \
	  jp_warp_static_reference_census
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1WarpTopCloneCensus \
	  us_object_collision_data_writer_census
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1WarpTopCloneCensus \
	  jp_object_collision_data_writer_census
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1WarpTopCloneCensus \
	  allocate_object_collision_reset_source_shape
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.Area1WarpTopCloneCensus \
	  behavior_spawn_commands_do_not_copy_collision_data
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPZeroAReachability \
	  zero_a_edge_clight_reachable_is_clight_star
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPZeroAReachability \
	  jp_zero_a_edge_projection_stays_below_960
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.JPZeroAReachability \
	  jp_zero_a_edge_projection_cannot_install_timer131_midface
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkTimer131ProducerClosure \
	  ink_timer131_producer_checked_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkTimer131ProducerClosure \
	  stock_behavior_offset_cannot_install_timer131_top_retry
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkTimer131ProducerClosure \
	  anchor_parent_static_area1_exclusion_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkTimer131ProducerClosure \
	  nonstock_1160_offset_builds_accepted_timer131_retry
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkTimer131MarioTailClosure \
	  ink_timer131_mario_tail_checked_boundary_holds
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkTimer131MarioTailClosure \
	  ink_mario_callback_direct_closure_has_no_tail_writer
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkTimer131MarioTailClosure \
	  ink_mario_current_object_source_identity_checked
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.InkTimer131MarioTailClosure \
	  zero_graph_offset_cannot_install_timer131_top_retry
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  turning_part2_animation_metadata_boundary_excludes_ink_split

clean:
	-$(MAKE) -f $(COQMAKEFILE) clean
	rm -f $(COQMAKEFILE) $(COQMAKEFILE).conf .*.aux
