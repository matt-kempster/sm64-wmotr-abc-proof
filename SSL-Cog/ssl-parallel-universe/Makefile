# Local build for the SSL Parallel Universe proof.
#
#   make            regenerate Clight, then build proofs
#   make generated  regenerate committed Clight from inputs/
#   make proofs     build Rocq proofs
#   make regen      force-regenerate generated/ from scratch
#   make clean      remove Rocq build artifacts

COQMAKEFILE := CoqMakefile
CLIGHTGEN   := pipeline/clightgen.sh

SM64 ?= $(SM64_SOURCE)
ifeq ($(strip $(SM64)),)
SM64 := $(firstword $(wildcard ../../../reference-sm64-decomp ../../vendor/sm64 ../../reference-sm64-decomp ../vendor/sm64))
endif
ifeq ($(strip $(SM64)),)
SM64 := ../../../reference-sm64-decomp
endif

SM64_CG := -nostdinc -fstruct-passing \
  -I$(SM64)/include \
  -I$(SM64)/build/us \
  -I$(SM64)/build/us/include \
  -I$(SM64)/src \
  -I$(SM64)/src/game \
  -I$(SM64) \
  -I$(SM64)/include/libc \
  -DVERSION_US=1 \
  -DF3DEX_GBI_2=1 \
  -DF3DEX_GBI_SHARED=1 \
  -D_FINALROM=1 \
  -DTARGET_N64=1 \
  -DNON_MATCHING=1 \
  -DAVOID_UB=1 \
  -D_LANGUAGE_C=1

GENERATED := \
  generated/pu_model.v \
  generated/mario_step.v \
  generated/platform_displacement.v \
  generated/mario.v \
  generated/mario_actions_moving.v \
  generated/mario_actions_airborne.v \
  generated/object_list_processor.v \
  generated/grindel_behavior.v

.PHONY: all generated proofs regen clean check

all: generated proofs

generated: $(GENERATED)

generated/pu_model.v: inputs/pu_model.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@

generated/mario_step.v: $(SM64)/src/game/mario_step.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/platform_displacement.v: $(SM64)/src/game/platform_displacement.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/mario.v: $(SM64)/src/game/mario.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/mario_actions_moving.v: $(SM64)/src/game/mario_actions_moving.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/mario_actions_airborne.v: $(SM64)/src/game/mario_actions_airborne.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/object_list_processor.v: $(SM64)/src/game/object_list_processor.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/grindel_behavior.v: inputs/grindel_behavior.c $(SM64)/src/game/behaviors/thwomp.inc.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

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
	rm -f generated/.*.aux proofs/.*.aux
