SHELL := /usr/bin/env bash
COQMAKEFILE := CoqMakefile

.PHONY: all generate reproducible configure proofs no-admitted assumptions check clean

all: check

generate:
	bash pipeline/generate-clight.sh

reproducible:
	bash pipeline/check-reproducible.sh

configure: $(COQMAKEFILE)

$(COQMAKEFILE): _CoqProject
	bash -c 'source pipeline/env.sh && coq_makefile -f _CoqProject -o $(COQMAKEFILE)'

proofs: configure
	bash -c 'source pipeline/env.sh && $(MAKE) -f $(COQMAKEFILE) -j$${COQ_JOBS:-2}'

no-admitted:
	bash pipeline/check-no-admitted.sh

assumptions: proofs
	bash pipeline/assumptions.sh \
	  Pedro.Proofs.MainTheorem checked_pedro_rng_mechanism_us_jp
	bash pipeline/assumptions.sh \
	  Pedro.Proofs.MainTheorem checked_ttc_spinner_source_reduction_us_jp
	bash pipeline/assumptions.sh \
	  Pedro.Proofs.MainTheorem checked_dust_source_projection_us_jp
	bash pipeline/assumptions.sh \
	  Pedro.Proofs.TTCSpinnerSchedule no_dust_tap_schedule_keeps_this_interval

check:
	$(MAKE) reproducible
	$(MAKE) proofs
	$(MAKE) no-admitted
	$(MAKE) assumptions

clean:
	-$(MAKE) -f $(COQMAKEFILE) clean
	rm -f $(COQMAKEFILE) $(COQMAKEFILE).conf .*.aux
