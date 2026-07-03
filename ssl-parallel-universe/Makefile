# Local build for the SSL Parallel Universe proof.
#
#   make            regenerate Clight, then build proofs
#   make generated  regenerate committed Clight from inputs/
#   make proofs     build Rocq proofs
#   make regen      force-regenerate generated/ from scratch
#   make clean      remove Rocq build artifacts

COQMAKEFILE := CoqMakefile
CLIGHTGEN   := pipeline/clightgen.sh

GENERATED :=

.PHONY: all generated proofs regen clean check

all: generated proofs

generated: $(GENERATED)

$(COQMAKEFILE): _CoqProject
	coq_makefile -f _CoqProject -o $@

proofs: $(COQMAKEFILE)
	$(MAKE) -f $(COQMAKEFILE)

regen:
	rm -f $(GENERATED)
	$(MAKE) generated

check:
	bash pipeline/check.sh

clean:
	-$(MAKE) -f $(COQMAKEFILE) clean 2>/dev/null || true
	rm -f $(COQMAKEFILE) $(COQMAKEFILE).conf .*.aux
