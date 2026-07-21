SM64 ?= $(SM64_SOURCE)
ifeq ($(strip $(SM64)),)
SM64 := $(firstword $(wildcard ../../../reference-sm64-decomp ../../vendor/sm64 ../../reference-sm64-decomp ../reference-sm64-decomp ../vendor/sm64 vendor/sm64))
endif
ifeq ($(strip $(SM64)),)
SM64 := ../../../reference-sm64-decomp
endif

JP_CG := -nostdinc -fstruct-passing \
  -I$(SM64)/include \
  -I$(SM64)/build/jp \
  -I$(SM64)/build/jp/include \
  -I$(SM64)/src \
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

GENERATED := \
  generated/jp_platform_displacement.v \
  generated/jp_object_list_processor.v \
  generated/jp_spawn_object.v \
  generated/jp_area.v \
  generated/jp_level_update.v \
  generated/jp_mario.v \
  generated/jp_interaction.v \
  generated/jp_object_helpers.v \
  generated/jp_mario_actions_object.v \
  generated/jp_mario_actions_cutscene.v \
  generated/jp_mario_actions_submerged.v \
  generated/jp_mario_step.v \
  generated/jp_surface_load.v \
  generated/jp_macro_special_objects.v \
  generated/jp_behavior_actions.v \
  generated/jp_obj_behaviors.v \
  generated/jp_behavior_data.v \
  generated/jp_level_script.v \
  generated/jp_ssl_script.v \
  generated/jp_ssl_area1_macro.v \
  generated/jp_ssl_area2_macro.v \
  generated/jp_macro_presets.v

.PHONY: all generated proofs check regen clean source-census

all: generated proofs

generated: $(GENERATED)

generated/jp_platform_displacement.v: $(SM64)/src/game/platform_displacement.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)

generated/jp_object_list_processor.v: $(SM64)/src/game/object_list_processor.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)

generated/jp_spawn_object.v: $(SM64)/src/game/spawn_object.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)

generated/jp_area.v: $(SM64)/src/game/area.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)

generated/jp_level_update.v: $(SM64)/src/game/level_update.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)

generated/jp_mario.v: $(SM64)/src/game/mario.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)

generated/jp_interaction.v: $(SM64)/src/game/interaction.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)

generated/jp_object_helpers.v: $(SM64)/src/game/object_helpers.c \
    pipeline/clightgen-long-double-as-double.sh pipeline/normalize-generated.sh
	bash pipeline/clightgen-long-double-as-double.sh $< $@ $(JP_CG)
	bash pipeline/normalize-generated.sh $@

generated/jp_mario_actions_object.v: $(SM64)/src/game/mario_actions_object.c \
    pipeline/clightgen.sh pipeline/normalize-generated.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)
	bash pipeline/normalize-generated.sh $@

generated/jp_mario_actions_cutscene.v: $(SM64)/src/game/mario_actions_cutscene.c \
    pipeline/clightgen.sh pipeline/normalize-generated.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)
	bash pipeline/normalize-generated.sh $@

generated/jp_mario_actions_submerged.v: $(SM64)/src/game/mario_actions_submerged.c \
    pipeline/clightgen.sh pipeline/normalize-generated.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)
	bash pipeline/normalize-generated.sh $@

generated/jp_mario_step.v: $(SM64)/src/game/mario_step.c \
    pipeline/clightgen.sh pipeline/normalize-generated.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)
	bash pipeline/normalize-generated.sh $@

generated/jp_surface_load.v: $(SM64)/src/engine/surface_load.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)

generated/jp_macro_special_objects.v: $(SM64)/src/game/macro_special_objects.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)

generated/jp_behavior_actions.v: $(SM64)/src/game/behavior_actions.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)

generated/jp_obj_behaviors.v: $(SM64)/src/game/obj_behaviors.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)

generated/jp_behavior_data.v: $(SM64)/data/behavior_data.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)

generated/jp_level_script.v: $(SM64)/src/engine/level_script.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)

generated/jp_ssl_script.v: $(SM64)/levels/ssl/script.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)

generated/jp_ssl_area1_macro.v: inputs/ssl_area1_macro.c \
    $(SM64)/levels/ssl/areas/1/macro.inc.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)

generated/jp_ssl_area2_macro.v: inputs/ssl_area2_macro.c \
    $(SM64)/levels/ssl/areas/2/macro.inc.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)

generated/jp_macro_presets.v: inputs/macro_presets.c \
    $(SM64)/include/macro_presets.inc.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(JP_CG)

CoqMakefile: _CoqProject
	coq_makefile -f _CoqProject -o CoqMakefile

proofs: CoqMakefile
	$(MAKE) -f CoqMakefile

source-census:
	bash pipeline/source-census.sh "$(SM64)"

check:
	bash pipeline/check.sh "$(SM64)"

regen:
	rm -f $(GENERATED)
	$(MAKE) generated

clean:
	-$(MAKE) -f CoqMakefile clean
	rm -f CoqMakefile CoqMakefile.conf .*.aux
