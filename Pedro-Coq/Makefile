SHELL := /usr/bin/env bash
COQMAKEFILE := CoqMakefile

.PHONY: all generate reproducible configure proofs no-admitted runtime-receipt rng-source-coverage assumptions check clean

all: check

generate:
	bash pipeline/generate-clight.sh

reproducible:
	bash pipeline/check-reproducible.sh

configure: $(COQMAKEFILE)

$(COQMAKEFILE): _CoqProject
	bash -c 'source pipeline/env.sh && coq_makefile -f _CoqProject -o $(COQMAKEFILE)'

proofs: configure
	bash -c 'source pipeline/env.sh && $(MAKE) -f $(COQMAKEFILE) -j$${COQ_JOBS:-1}'

no-admitted:
	bash pipeline/check-no-admitted.sh

runtime-receipt:
	python3 pipeline/check-ttc-runtime-snapshot.py

rng-source-coverage:
	python3 pipeline/check-rng-source-coverage.py

assumptions: proofs
	bash pipeline/assumptions.sh \
	  Pedro.Proofs.MainTheorem checked_ttc_cog_rng_source_frontier_us_jp
	bash pipeline/assumptions.sh \
	  Pedro.Proofs.MainTheorem checked_ttc_cog_dust_action_frontier_us_jp
	bash pipeline/assumptions.sh \
	  Pedro.Proofs.MainTheorem checked_ttc_cog_local_mechanism_us_jp
	bash pipeline/assumptions.sh \
	  Pedro.Proofs.MainTheorem checked_ttc_cog_source_geometry_us_jp
	bash pipeline/assumptions.sh \
	  Pedro.Proofs.MainTheorem checked_pedro_rng_mechanism_us_jp
	bash pipeline/assumptions.sh \
	  Pedro.Proofs.MainTheorem checked_ttc_spinner_source_reduction_us_jp
	bash pipeline/assumptions.sh \
	  Pedro.Proofs.MainTheorem checked_dust_source_projection_us_jp
	bash pipeline/assumptions.sh \
	  Pedro.Proofs.MainTheorem checked_dust_frontier_reductions_us_jp
	bash pipeline/assumptions.sh \
	  Pedro.Proofs.MainTheorem checked_dust_linked_runtime_census_frontier_us_jp
	bash pipeline/assumptions.sh \
	  Pedro.Proofs.MainTheorem checked_static_terminal_frontier_us_jp
	bash pipeline/assumptions.sh \
	  Pedro.Proofs.MainTheorem checked_spawn_particle_caller_and_segmented_boundary_us_jp
	bash pipeline/assumptions.sh \
	  Pedro.Proofs.TTCSpinnerSchedule widened_interval_admits_one_negative_motion
	bash pipeline/assumptions.sh \
	  Pedro.Proofs.TTCSpinnerSchedule no_dust_tap_schedule_keeps_this_interval

check:
	$(MAKE) reproducible
	$(MAKE) runtime-receipt
	$(MAKE) rng-source-coverage
	$(MAKE) proofs
	$(MAKE) no-admitted
	$(MAKE) assumptions

clean:
	-$(MAKE) -f $(COQMAKEFILE) clean
	rm -f $(COQMAKEFILE) $(COQMAKEFILE).conf .*.aux
