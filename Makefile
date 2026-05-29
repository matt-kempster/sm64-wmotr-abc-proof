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

# Canonical clightgen recipe for an SM64 (US, F3DEX2) translation unit. These
# mirror the real build's TARGET_CFLAGS + DEF_INC_CFLAGS (vendor/sm64/Makefile):
#   -nostdinc + include/libc   = the repo's own libc, not the host's
#   -fstruct-passing           = CompCert opt-in for struct-by-value parameters
#   the -D set                 = VERSION_US / F3DEX2 grucode / N64 target / build mode
# Determinism: same input + same flags + same clightgen => byte-identical output.
SM64    := vendor/sm64
SM64_CG := -nostdinc -fstruct-passing \
  -I$(SM64)/include -I$(SM64)/build/us -I$(SM64)/build/us/include -I$(SM64)/src -I$(SM64) -I$(SM64)/include/libc \
  -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1 -D_FINALROM=1 -DTARGET_N64=1 \
  -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1

GENERATED := generated/toy.v generated/shadow.v \
  generated/mario.v generated/mario_actions_airborne.v \
  generated/mario_actions_moving.v generated/level_update.v \
  generated/behavior_actions.v

.PHONY: all generated proofs regen clean

all: generated proofs

generated: $(GENERATED)

generated/toy.v: experiments/toy/toy.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@

generated/shadow.v: $(SM64)/src/game/shadow.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

# The Mario-action + level TUs that contain every set_mario_action(.., ACT_FLYING..)
# site (the "must press A to fly" enumeration, R1). One recipe per TU; same flags.
generated/mario.v: $(SM64)/src/game/mario.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/mario_actions_airborne.v: $(SM64)/src/game/mario_actions_airborne.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/mario_actions_moving.v: $(SM64)/src/game/mario_actions_moving.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/level_update.v: $(SM64)/src/game/level_update.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

# The whole behavior C layer: behavior_actions.c #includes all ~111 behaviors/*.inc.c,
# so this one TU is every behavior's native code. Used to mechanize "no behavior is a
# flying-setter" (closes leak #3 for the action field, w.r.t. this TU).
generated/behavior_actions.v: $(SM64)/src/game/behavior_actions.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

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
