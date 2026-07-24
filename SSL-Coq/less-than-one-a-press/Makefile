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
	  pyramid_top_pu_checked_bundle
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  collection_provenance_reduction
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.MainTheorem \
	  current_verified_evidence_and_collection_reduction
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
	  LessThanOneAPress.Proofs.ModelGapAudit \
	  current_certified_motion_accepts_arbitrary_endpoint
	bash pipeline/assumptions.sh \
	  LessThanOneAPress.Proofs.ModelGapAudit \
	  current_abstract_counterexample_exists_for_every_target_entry

clean:
	-$(MAKE) -f $(COQMAKEFILE) clean
	rm -f $(COQMAKEFILE) $(COQMAKEFILE).conf .*.aux
