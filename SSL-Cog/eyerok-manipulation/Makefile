# Local build for the Eyerok manipulation proof.

CLIGHTGEN := bash pipeline/clightgen.sh

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
  -I$(SM64)/src/engine \
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

PREPARED := \
  build/source/obj_behaviors_2.c \
  build/source/object_helpers.c \
  build/source/behavior_script.c \
  build/source/object_list_processor.c \
  build/source/spawn_object.c \
  build/source/surface_collision.c \
  build/source/ssl_script.c

GENERATED := \
  generated/obj_behaviors_2.v \
  generated/object_helpers.v \
  generated/behavior_script.v \
  generated/object_list_processor.v \
  generated/spawn_object.v \
  generated/surface_collision.v \
  generated/ssl_script.v \
  generated/source_audit.txt

AUDITED_SOURCES := \
  $(SM64)/src/game/behaviors/eyerok.inc.c \
  $(SM64)/src/game/obj_behaviors_2.c \
  $(SM64)/src/game/object_helpers.c \
  $(SM64)/src/engine/behavior_script.c \
  $(SM64)/src/game/object_list_processor.c \
  $(SM64)/src/game/spawn_object.c \
  $(SM64)/src/engine/surface_collision.c \
  $(SM64)/include/object_constants.h \
  $(SM64)/include/object_fields.h \
  $(SM64)/data/behavior_data.c \
  $(SM64)/levels/ssl/script.c \
  $(SM64)/levels/ssl/areas/2/collision.inc.c \
  $(SM64)/levels/ssl/areas/3/collision.inc.c \
  $(SM64)/levels/ssl/eyerok_col/collision.inc.c

COQMAKEFILE := CoqMakefile

.PHONY: all generated proofs audit check regen clean

all: generated proofs

generated: $(GENERATED)

$(PREPARED) &: pipeline/prepare-sources.sh patches/object_helpers-clightgen.patch
	bash pipeline/prepare-sources.sh $(SM64)

generated/obj_behaviors_2.v: build/source/obj_behaviors_2.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/object_helpers.v: build/source/object_helpers.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/behavior_script.v: build/source/behavior_script.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/object_list_processor.v: build/source/object_list_processor.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/spawn_object.v: build/source/spawn_object.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/surface_collision.v: build/source/surface_collision.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/ssl_script.v: build/source/ssl_script.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/source_audit.txt: pipeline/audit_eyerok_source.py $(AUDITED_SOURCES)
	PYTHONDONTWRITEBYTECODE=1 python3 pipeline/audit_eyerok_source.py $(SM64) > $@

audit: generated/source_audit.txt
	@cat generated/source_audit.txt

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
	rm -rf build
