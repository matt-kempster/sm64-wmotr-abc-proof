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

clean:
	-$(MAKE) -f $(COQMAKEFILE) clean
	rm -f $(COQMAKEFILE) $(COQMAKEFILE).conf .*.aux
