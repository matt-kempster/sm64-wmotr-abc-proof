SHELL := /usr/bin/env bash
COQMAKEFILE := CoqMakefile

.PHONY: all generate reproducible configure proofs audit-build no-admitted demo-data assumptions coqchk check check-discipline clean

all: check

generate:
	bash pipeline/generate-clight.sh

reproducible:
	bash pipeline/check-reproducible.sh

configure: $(COQMAKEFILE)

$(COQMAKEFILE): _CoqProject
	coq_makefile -f _CoqProject -o $(COQMAKEFILE)

proofs: configure
	$(MAKE) -f $(COQMAKEFILE) -j$${COQ_JOBS:-1}

AUDIT_VO_TARGETS ?= proofs/MainTheorem.vo
audit-build: configure
	$(MAKE) -f $(COQMAKEFILE) -j$${COQ_JOBS:-1} $(AUDIT_VO_TARGETS)

no-admitted:
	bash pipeline/check-no-admitted.sh

demo-data:
	python3 pipeline/check-demo-data.py

assumptions: proofs
	bash pipeline/assumptions.sh Demo.Proofs.MainTheorem checked_demo_source_boundary_us_jp

coqchk: proofs
	bash pipeline/coqchk.sh Demo.Proofs.MainTheorem

check-discipline:
	bash pipeline/discipline-check.sh

check:
	$(MAKE) reproducible
	$(MAKE) demo-data
	$(MAKE) proofs
	$(MAKE) no-admitted
	$(MAKE) assumptions
	$(MAKE) coqchk
	$(MAKE) check-discipline

clean:
	-$(MAKE) -f $(COQMAKEFILE) clean
	rm -f $(COQMAKEFILE) $(COQMAKEFILE).conf .CoqMakefile.d .*.aux
