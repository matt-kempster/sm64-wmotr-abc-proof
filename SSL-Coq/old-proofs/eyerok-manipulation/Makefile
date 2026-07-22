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

# The Japanese translation units intentionally use the JP generated headers
# and VERSION_JP.  In particular, this compiles out clear_mario_platform from
# spawn_objects_from_info so that the version difference is visible in Clight.
SM64_CG_JP := -nostdinc -fstruct-passing \
  -I$(SM64)/include \
  -I$(SM64)/build/jp \
  -I$(SM64)/build/jp/include \
  -I$(SM64)/src \
  -I$(SM64)/src/engine \
  -I$(SM64)/src/game \
  -I$(SM64) \
  -I$(SM64)/include/libc \
  -DVERSION_JP=1 \
  -DF3D_OLD=1 \
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
  build/source/ssl_script.c \
  build/source/area.c \
  build/source/level_update.c \
  build/source/game_init.c \
  build/source/mario.c \
  build/source/mario_step.c \
  build/source/mario_actions_airborne.c \
  build/source/mario_actions_moving.c \
  build/source/mario_actions_object.c \
  build/source/mario_actions_stationary.c \
  build/source/platform_displacement.c \
  build/source/interaction.c

GENERATED := \
  generated/eyerok_model.v \
  generated/obj_behaviors_2.v \
  generated/object_helpers.v \
  generated/behavior_script.v \
  generated/object_list_processor.v \
  generated/object_list_processor_jp.v \
  generated/spawn_object.v \
  generated/surface_collision.v \
  generated/ssl_script.v \
  generated/area.v \
  generated/area_jp.v \
  generated/level_update.v \
  generated/level_update_jp.v \
  generated/game_init.v \
  generated/mario.v \
  generated/mario_step.v \
  generated/mario_actions_airborne.v \
  generated/mario_actions_moving.v \
  generated/mario_actions_object.v \
  generated/mario_actions_stationary.v \
  generated/platform_displacement.v \
  generated/platform_displacement_jp.v \
  generated/interaction.v \
  generated/source_audit.txt \
  generated/route_audit.txt

AUDITED_SOURCES := \
  $(SM64)/Makefile \
  $(SM64)/sm64.jp.sha1 \
  $(SM64)/src/game/behaviors/eyerok.inc.c \
  $(SM64)/src/game/obj_behaviors_2.c \
  $(SM64)/src/game/object_helpers.c \
  $(SM64)/src/engine/behavior_script.c \
  $(SM64)/src/game/object_list_processor.c \
  $(SM64)/src/game/spawn_object.c \
  $(SM64)/src/engine/surface_collision.c \
  $(SM64)/src/engine/surface_load.c \
  $(SM64)/actors/eyerok/anims/anim_0500DF50.inc.c \
  $(SM64)/actors/eyerok/anims/anim_0500E99C.inc.c \
  $(SM64)/actors/eyerok/anims/anim_0500F3D8.inc.c \
  $(SM64)/actors/eyerok/anims/anim_050116CC.inc.c \
  $(SM64)/src/game/area.c \
  $(SM64)/src/game/level_update.c \
  $(SM64)/src/game/mario.c \
  $(SM64)/src/game/game_init.c \
  $(SM64)/src/game/object_collision.c \
  $(SM64)/src/game/mario_step.c \
  $(SM64)/src/game/mario_actions_airborne.c \
  $(SM64)/src/game/mario_actions_moving.c \
  $(SM64)/src/game/mario_actions_object.c \
  $(SM64)/src/game/mario_actions_stationary.c \
  $(SM64)/src/game/platform_displacement.c \
  $(SM64)/src/game/behaviors/break_particles.inc.c \
  $(SM64)/src/engine/math_util.c \
  $(SM64)/src/game/interaction.c \
  $(SM64)/src/game/behaviors/spawn_star.inc.c \
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

generated/object_list_processor_jp.v: build/source/object_list_processor.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG_JP)

generated/spawn_object.v: build/source/spawn_object.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/surface_collision.v: build/source/surface_collision.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/ssl_script.v: build/source/ssl_script.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/area.v: build/source/area.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/area_jp.v: build/source/area.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG_JP)

generated/level_update.v: build/source/level_update.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/level_update_jp.v: build/source/level_update.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG_JP)

generated/game_init.v: build/source/game_init.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/mario.v: build/source/mario.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/mario_step.v: build/source/mario_step.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/mario_actions_airborne.v: build/source/mario_actions_airborne.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/mario_actions_moving.v: build/source/mario_actions_moving.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/mario_actions_object.v: build/source/mario_actions_object.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/mario_actions_stationary.v: build/source/mario_actions_stationary.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/platform_displacement.v: build/source/platform_displacement.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/platform_displacement_jp.v: build/source/platform_displacement.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG_JP)

generated/interaction.v: build/source/interaction.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/source_audit.txt: pipeline/audit_eyerok_source.py $(AUDITED_SOURCES)
	PYTHONDONTWRITEBYTECODE=1 python3 pipeline/audit_eyerok_source.py $(SM64) > $@

generated/route_audit.txt: pipeline/audit_route_source.py $(AUDITED_SOURCES)
	PYTHONDONTWRITEBYTECODE=1 python3 pipeline/audit_route_source.py $(SM64) > $@

generated/eyerok_model.v: inputs/eyerok_model.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@

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
