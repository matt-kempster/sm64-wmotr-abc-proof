# Local build for the SSL Pyramid pole-bypass proof.

CLIGHTGEN := pipeline/clightgen.sh

SM64 ?= $(SM64_SOURCE)
ifeq ($(strip $(SM64)),)
SM64 := $(firstword $(wildcard ../../../../reference-sm64-decomp ../../../vendor/sm64 ../../../reference-sm64-decomp ../../vendor/sm64))
endif
ifeq ($(strip $(SM64)),)
SM64 := ../../../../reference-sm64-decomp
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

COQMAKEFILE := CoqMakefile

GENERATED := \
  generated/pole_model.v \
  generated/ssl_script.v \
  generated/behavior_actions.v \
  generated/mario_actions_automatic.v \
  generated/mario.v \
  generated/interaction.v \
  generated/mario_actions_airborne.v \
  generated/mario_step.v \
  generated/object_list_processor.v \
  generated/pole_transfer_audit.txt

AUDITED_SOURCES := \
  $(SM64)/levels/ssl/script.c \
  $(SM64)/levels/ssl/areas/2/collision.inc.c \
  $(SM64)/data/behavior_data.c \
  $(SM64)/src/game/behaviors/pole.inc.c \
  $(SM64)/src/game/behaviors/pole_base.inc.c \
  $(SM64)/src/game/mario_actions_automatic.c \
  $(SM64)/src/game/interaction.c \
  $(SM64)/src/game/mario.c \
  $(SM64)/src/game/mario_actions_airborne.c \
  $(SM64)/src/game/mario_step.c \
  $(SM64)/src/game/object_helpers.c \
  $(SM64)/src/game/object_list_processor.c

.PHONY: all generated proofs audit check regen clean

all: generated proofs

generated: $(GENERATED)

generated/pole_model.v: inputs/pole_model.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@

generated/ssl_script.v: $(SM64)/levels/ssl/script.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/behavior_actions.v: $(SM64)/src/game/behavior_actions.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/mario_actions_automatic.v: $(SM64)/src/game/mario_actions_automatic.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/mario.v: $(SM64)/src/game/mario.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/interaction.v: $(SM64)/src/game/interaction.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/mario_actions_airborne.v: $(SM64)/src/game/mario_actions_airborne.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/mario_step.v: $(SM64)/src/game/mario_step.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/object_list_processor.v: $(SM64)/src/game/object_list_processor.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/pole_transfer_audit.txt: pipeline/audit_pole_transfer.py $(AUDITED_SOURCES)
	PYTHONDONTWRITEBYTECODE=1 python3 pipeline/audit_pole_transfer.py $(SM64) > $@

audit: generated/pole_transfer_audit.txt
	@cat generated/pole_transfer_audit.txt

$(COQMAKEFILE): _CoqProject
	coq_makefile -f _CoqProject -o $@

proofs: $(COQMAKEFILE)
	$(MAKE) -f $(COQMAKEFILE)

check: generated
	bash pipeline/check.sh

regen:
	rm -f $(GENERATED)
	$(MAKE) generated

clean:
	-$(MAKE) -f $(COQMAKEFILE) clean 2>/dev/null || true
	rm -f $(COQMAKEFILE) $(COQMAKEFILE).conf .*.aux
	rm -f generated/.*.aux proofs/.*.aux
