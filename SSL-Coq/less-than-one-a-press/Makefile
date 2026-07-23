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

clean:
	-$(MAKE) -f $(COQMAKEFILE) clean
	rm -f $(COQMAKEFILE) $(COQMAKEFILE).conf .*.aux
