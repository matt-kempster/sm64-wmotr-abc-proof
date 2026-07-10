SM64 ?= $(SM64_SOURCE)
ifeq ($(strip $(SM64)),)
SM64 := $(firstword $(wildcard ../../../reference-sm64-decomp ../../reference-sm64-decomp ../reference-sm64-decomp))
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
  generated/area.v \
  generated/level_update.v \
  generated/object_list_processor.v \
  generated/spawn_object.v \
  generated/mario.v \
  generated/mario_misc.v \
  generated/interaction.v \
  generated/mario_actions_cutscene.v \
  generated/object_helpers.v \
  generated/behavior_actions.v \
  generated/obj_behaviors.v \
  generated/graph_node.v \
  generated/level_script.v \
  generated/macro_special_objects.v \
  generated/ssl_script.v \
  generated/ssl_area1_macro.v \
  generated/ssl_area2_macro.v \
  generated/audio_external.v

.PHONY: all generated proofs clean

all: generated proofs

generated: $(GENERATED)

generated/area.v: $(SM64)/src/game/area.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/level_update.v: $(SM64)/src/game/level_update.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/object_list_processor.v: $(SM64)/src/game/object_list_processor.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/spawn_object.v: $(SM64)/src/game/spawn_object.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/mario.v: $(SM64)/src/game/mario.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/mario_misc.v: $(SM64)/src/game/mario_misc.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/interaction.v: $(SM64)/src/game/interaction.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/mario_actions_cutscene.v: $(SM64)/src/game/mario_actions_cutscene.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

build/source/object_helpers.c: $(SM64)/src/game/object_helpers.c \
    patches/object_helpers-clightgen.patch pipeline/prepare-sources.sh
	bash pipeline/prepare-sources.sh

generated/object_helpers.v: build/source/object_helpers.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/behavior_actions.v: $(SM64)/src/game/behavior_actions.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/obj_behaviors.v: $(SM64)/src/game/obj_behaviors.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/graph_node.v: $(SM64)/src/engine/graph_node.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/level_script.v: $(SM64)/src/engine/level_script.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/macro_special_objects.v: $(SM64)/src/game/macro_special_objects.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/ssl_script.v: $(SM64)/levels/ssl/script.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/ssl_area1_macro.v: inputs/ssl_area1_macro.c \
    $(SM64)/levels/ssl/areas/1/macro.inc.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/ssl_area2_macro.v: inputs/ssl_area2_macro.c \
    $(SM64)/levels/ssl/areas/2/macro.inc.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/audio_external.v: $(SM64)/src/audio/external.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

CoqMakefile: _CoqProject
	coq_makefile -f _CoqProject -o CoqMakefile

proofs: CoqMakefile
	$(MAKE) -f CoqMakefile

clean:
	-$(MAKE) -f CoqMakefile clean
	rm -f CoqMakefile CoqMakefile.conf .*.aux
