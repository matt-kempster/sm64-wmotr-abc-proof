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

GENERATED := generated/game_init.v generated/title_screen.v

.PHONY: all generated proofs check clean

all: generated proofs

generated: $(GENERATED)

generated/game_init.v: $(SM64)/src/game/game_init.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

generated/title_screen.v: $(SM64)/src/menu/title_screen.c pipeline/clightgen.sh
	bash pipeline/clightgen.sh $< $@ $(SM64_CG)

CoqMakefile: _CoqProject
	coq_makefile -f _CoqProject -o CoqMakefile

proofs: CoqMakefile
	$(MAKE) -f CoqMakefile

check:
	bash pipeline/check.sh

clean:
	-test ! -f CoqMakefile || $(MAKE) -f CoqMakefile clean
	rm -f CoqMakefile CoqMakefile.conf .*.aux

