# Top-level pipeline + proof build.
#
#   make            regenerate Clight from inputs, then build all proofs
#   make generated  just (re)generate the Clight .v files
#   make proofs     just build the Rocq proofs (assumes generated/ exists)
#   make regen      force-regenerate generated/ from scratch (CI diffs this)
#   make clean      remove Rocq build artifacts
#
# Requires the toolchain on PATH:  source pipeline/env.sh

COQMAKEFILE := CoqMakefile
CLIGHTGEN   := pipeline/clightgen.sh

GENERATED := generated/toy.v

.PHONY: all generated proofs regen clean

all: generated proofs

generated: $(GENERATED)

generated/toy.v: experiments/toy/toy.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@

$(COQMAKEFILE): _CoqProject
	coq_makefile -f _CoqProject -o $@

proofs: $(COQMAKEFILE) $(GENERATED)
	$(MAKE) -f $(COQMAKEFILE)

regen:
	rm -f $(GENERATED)
	$(MAKE) generated

clean:
	-$(MAKE) -f $(COQMAKEFILE) clean 2>/dev/null || true
	rm -f $(COQMAKEFILE) $(COQMAKEFILE).conf .*.aux
