# Local build for the SSL Pyramid pole-bypass proof.

COQMAKEFILE := CoqMakefile

.PHONY: all generated proofs clean

all: generated proofs

generated:
	@echo "No generated targets have been added yet."

$(COQMAKEFILE): _CoqProject
	coq_makefile -f _CoqProject -o $@

proofs: $(COQMAKEFILE)
	$(MAKE) -f $(COQMAKEFILE)

clean:
	-$(MAKE) -f $(COQMAKEFILE) clean 2>/dev/null || true
	rm -f $(COQMAKEFILE) $(COQMAKEFILE).conf .*.aux
	rm -f generated/.*.aux proofs/.*.aux
