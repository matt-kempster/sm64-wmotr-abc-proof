SM64 ?= $(SM64_SOURCE)
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
  generated/game_init.v \
  generated/title_screen.v \
  generated/mario.v \
  generated/main.v \
  generated/memory.v \
  generated/level_update.v \
  generated/camera.v \
  generated/behavior_actions.v \
  generated/rumble_init.v \
  generated/save_file.v \
  generated/reachability_facts.v

.PHONY: all generated proofs check clean

all: generated proofs

generated: $(GENERATED)

generated/game_init.v: $(SM64)/src/game/game_init.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/title_screen.v: $(SM64)/src/menu/title_screen.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/mario.v: $(SM64)/src/game/mario.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/main.v: $(SM64)/src/game/main.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/memory.v: $(SM64)/src/game/memory.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/level_update.v: $(SM64)/src/game/level_update.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/camera.v: $(SM64)/src/game/camera.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/behavior_actions.v: $(SM64)/src/game/behavior_actions.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/rumble_init.v: $(SM64)/src/game/rumble_init.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/save_file.v: $(SM64)/src/game/save_file.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/reachability_facts.v: pipeline/generate-reachability-facts.py
	python3 pipeline/generate-reachability-facts.py $(SM64) $@

CoqMakefile: _CoqProject
	coq_makefile -f _CoqProject -o CoqMakefile

proofs: CoqMakefile
	$(MAKE) -f CoqMakefile

check:
	bash pipeline/check.sh

clean:
	-test ! -f CoqMakefile || $(MAKE) -f CoqMakefile clean
	rm -f CoqMakefile CoqMakefile.conf .*.aux
