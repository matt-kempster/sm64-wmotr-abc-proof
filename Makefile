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
# Proof-only C rewrites (pipeline/proof_n64.h; TRUST.md 2.2; inventory: tools/ub_sites.py).
# Not applied to shadow.c: it includes PR/gbi.h BEFORE macros.h, so pulling macros.h in
# early would change its Gfx composite (gbi.h:1743 reads platform_info.h); it has no site.
SM64_CGP := $(SM64_CG) -include pipeline/proof_n64.h
# Canonical clightgen recipe for a libultra C file (vendor/sm64/lib/src/*.c).
# The real build compiles lib/src with the game's TARGET_CFLAGS +
# DEF_INC_CFLAGS (only OPT_FLAGS / MIPSISET differ, vendor/sm64/Makefile:745),
# so the flag set is SM64_CG; proof_n64.h is NOT applied (its rewrites are
# game-code UB sites, TRUST 2.2; no libultra file is on its list).
ULTRA_CG := $(SM64_CG)
ULTRA   := $(SM64)/lib/src
# The libultra C under save_file_do_save (2026-10-21, TRUST 3.5 / 4.1):
# the EEPROM write path, the SI access queue, osCreateMesgQueue, and the two
# TUs that hold the storage it touches (osContInit.c: __osContLastCmd and the
# EEPROM timer / queue / message buffer; osInitialize.c: osClockRate).
ULTRA_GENERATED := generated/libultra_osEepromLongWrite.v generated/libultra_osEepromWrite.v \
  generated/libultra_osSiCreateAccessQueue.v generated/libultra_osCreateMesgQueue.v \
  generated/libultra_osContInit.v generated/libultra_osInitialize.v

GENERATED := generated/toy.v generated/shadow.v \
  generated/mario.v generated/mario_actions_airborne.v \
  generated/mario_actions_moving.v generated/level_update.v \
  generated/behavior_actions.v generated/mario_actions_automatic.v \
  generated/interaction.v \
  generated/mario_actions_submerged.v generated/mario_actions_stationary.v \
  generated/mario_actions_cutscene.v generated/mario_actions_object.v \
  generated/mario_step.v generated/mario_misc.v \
  generated/math_util.v generated/surface_collision.v generated/memory.v generated/game_init.v \
  generated/wmotr_level_data.v generated/wmotr_script.v \
  generated/macro_special_objects.v generated/behavior_data.v \
  generated/object_helpers.v generated/obj_behaviors.v generated/obj_behaviors_2.v \
  generated/spawn_object.v generated/object_list_processor.v generated/audio_data.v generated/graph_node.v generated/buffers.v generated/save_file.v generated/object_collision.v \
  generated/area.v generated/surface_load.v generated/mario_anim_data.v generated/camera.v generated/ingame_menu.v generated/debug_course.v \
  $(ULTRA_GENERATED)

.PHONY: all generated proofs regen clean oracle-extract

all: generated proofs

generated: $(GENERATED)

generated/toy.v: experiments/toy/toy.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@

generated/shadow.v: $(SM64)/src/game/shadow.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

# The Mario-action + level TUs that contain every set_mario_action(.., ACT_FLYING..)
# site (the "must press A to fly" enumeration, R1). One recipe per TU; same flags.
generated/mario.v: $(SM64)/src/game/mario.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

generated/mario_actions_airborne.v: $(SM64)/src/game/mario_actions_airborne.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

generated/mario_actions_moving.v: $(SM64)/src/game/mario_actions_moving.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

generated/level_update.v: $(SM64)/src/game/level_update.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

# The whole behavior C layer: behavior_actions.c #includes all ~111 behaviors/*.inc.c,
# so this one TU is every behavior's native code. Used to mechanize "no behavior is a
# flying-setter" (closes leak #3 for the action field, w.r.t. this TU).
generated/behavior_actions.v: $(SM64)/src/game/behavior_actions.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

# The remaining TUs that contain a direct write to MarioState.action (the choke-point
# enumeration): mario_actions_automatic.c and interaction.c.
generated/mario_actions_automatic.v: $(SM64)/src/game/mario_actions_automatic.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

generated/interaction.v: $(SM64)/src/game/interaction.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

# Whole-program MarioState.action writer enumeration (leak #3, action field): the
# remaining Mario-action / Mario-step TUs. We scan every one for direct writers of
# MarioState.action and prove none writes a flying constant (docs/whole-program-action-writers.md).
generated/mario_actions_submerged.v: $(SM64)/src/game/mario_actions_submerged.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

generated/mario_actions_stationary.v: $(SM64)/src/game/mario_actions_stationary.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

generated/mario_actions_cutscene.v: $(SM64)/src/game/mario_actions_cutscene.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

generated/mario_actions_object.v: $(SM64)/src/game/mario_actions_object.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

generated/mario_step.v: $(SM64)/src/game/mario_step.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

generated/mario_misc.v: $(SM64)/src/game/mario_misc.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

# The C1 boundary shrink (director-roadmap-2026-07-01 P1): the two engine TUs
# whose bodies stand behind ~16 assumed call_pres_ext_* rows on the capstone
# (vec3f_*/approach_*/atan2s in math_util.c; find_floor/find_ceil/
# find_wall_collisions/find_water_level in surface_collision.c). clightgen'ing
# them makes those functions Internal in lp, so the gated specs become WALKED
# lemmas instead of trust rows.
# memory.c (2026-10-18): load_patchable_table / dma_read run their real
# bodies, so the only externals under set_mario_animation are the libultra
# DMA calls (osInvalDCache / osPiStartDma / osRecvMesg).
# PROOF_MEMORY_C (2026-10-21, TRUST 2.2): proof_n64.h swaps in the decomp's
# NO_SEGMENTED_MEMORY bodies of segmented_to_virtual / virtual_to_segmented
# (identity) for this TU only.
generated/memory.v: $(SM64)/src/game/memory.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP) -DPROOF_MEMORY_C=1

# game_init.c (2026-10-20): the real definitions of gMarioAnimsBuf and
# gControllers (storage in the boot image) and setup_game_memory, which
# fills the animation list (main_pool_alloc + setup_dma_table_list).
generated/game_init.v: $(SM64)/src/game/game_init.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

generated/math_util.v: $(SM64)/src/engine/math_util.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

generated/surface_collision.v: $(SM64)/src/engine/surface_collision.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

# GOAL-2 level data (TRUST.md 0.8): WMotR's terrain, macro objects and the
# collision meshes of its two collision-bearing objects (a verbatim-#include
# wrapper, pipeline/tu/), its level script (the pole OBJECTs), and the real
# macro-preset table (preset id -> behavior).  Data only; no body is walked.
generated/wmotr_level_data.v: pipeline/tu/wmotr_level_data.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/wmotr_script.v: $(SM64)/levels/wmotr/script.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

generated/macro_special_objects.v: $(SM64)/src/game/macro_special_objects.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

$(COQMAKEFILE): _CoqProject
	coq_makefile -f _CoqProject -o $@

# Build the Rocq proofs against the COMMITTED generated/*.v (the documented
# "assumes generated/ exists" contract). Deliberately does NOT depend on
# $(GENERATED): regenerating needs the vendor/sm64 submodule + clightgen, which
# CI (and reviewers building the committed artifacts) should not require. Run
# `make` (all) or `make generated`/`make regen` when you actually want to
# regenerate from the pinned submodule.
proofs: $(COQMAKEFILE)
	$(MAKE) -f $(COQMAKEFILE)

# OCaml extraction of the interpreter + twelve-TU link for the recorded-RAM
# differential tester (experiments/oracle, TRUST.md 5.1). Not part of `all`.
oracle-extract: proofs
	mkdir -p experiments/oracle/extract/ml
	coqc -R generated SM64.Generated -R proofs SM64.Proofs experiments/oracle/extract/Extract.v

regen:
	rm -f $(GENERATED)
	$(MAKE) generated

clean:
	-$(MAKE) -f $(COQMAKEFILE) clean 2>/dev/null || true
	rm -f $(COQMAKEFILE) $(COQMAKEFILE).conf .*.aux

# Every behavior script (data/behavior_data.c) as data: the object census of
# GOAL 2 (which behaviors WMotR spawns, their interaction types, which load
# collision) is decoded from it (WMotRRequiresA/BehaviorScripts.v).
# Linked since 2026-10-21 (the 30th TU): the real storage of every bhv* script,
# so `o->behavior == segmented_to_virtual(bhvXxx)` compares and script reads
# have CompCert executions.  proof_n64.h changes nothing in it (only the
# header line differs); it takes SM64_CGP like every game TU.
generated/behavior_data.v: $(SM64)/data/behavior_data.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

# The behavior-script completion in pipeline/clightgen.sh (TRUST 2.4) reads the
# script lengths off generated/behavior_data.v, so every other TU depends on it.
$(filter-out generated/behavior_data.v generated/wmotr_level_data.v generated/toy.v $(ULTRA_GENERATED),$(GENERATED)): generated/behavior_data.v
# The level-data completion reads the mesh lengths off generated/wmotr_level_data.v
# (it holds no bhv* reference, so it is generated first).
$(filter-out generated/wmotr_level_data.v generated/toy.v $(ULTRA_GENERATED),$(GENERATED)): generated/wmotr_level_data.v

# The object layer around the behaviors (GOAL 2 object census: what WMotR's
# objects can spawn, BehaviorScripts.v).  object_helpers.c has a `1.0l`
# literal in a debug function; -flongdouble maps long double to double, as
# IDO's o32 ABI does (TRUST.md 2).  Linked as the 20th TU since 2026-10-21
# (the real obj_mark_for_deletion / obj_scale / obj_set_held_state bodies).
generated/object_helpers.v: $(SM64)/src/game/object_helpers.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ -flongdouble $(SM64_CGP)

generated/obj_behaviors.v: $(SM64)/src/game/obj_behaviors.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

generated/obj_behaviors_2.v: $(SM64)/src/game/obj_behaviors_2.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

generated/spawn_object.v: $(SM64)/src/game/spawn_object.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

generated/object_list_processor.v: $(SM64)/src/game/object_list_processor.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

# audio/data.c (2026-10-20): the real definition of gAudioRandom, which
# play_mario_jump_sound reads (mario.c:254); without it the boot image gives it
# no storage and dive / rollout have no execution that plays a jump sound.
generated/audio_data.v: $(SM64)/src/audio/data.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

# engine/graph_node.c (2026-10-21): the real bodies of
# geo_update_animation_frame and retrieve_animation_index, which GOAL 1's
# capstone took as rows (Hgeo_real, Hocp_rai_real).
generated/graph_node.v: $(SM64)/src/engine/graph_node.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

# game/save_file.c + buffers/buffers.c (2026-10-21): the real body of
# save_file_set_cap_pos (GOAL 1's Hcp_savefile_real row) and the real storage of
# gSaveBuffer, which save_file.c only declares extern (a size-0 block without
# buffers.c, so every save-file store would have no execution).
generated/save_file.v: $(SM64)/src/game/save_file.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

generated/buffers.v: $(SM64)/src/buffers/buffers.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

# Object-object collision (detect_object_hitbox_overlap): the rule that decides
# whether Mario touches a coin (GOAL 2 coin link, CoinLink.v).
generated/object_collision.v: $(SM64)/src/game/object_collision.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

# game/area.c (2026-10-21): the real storage of gCurrLevelNum, gCurrCourseNum,
# gCurrentArea, gMarioSpawnInfo, gPlayerSpawnInfos, gCurrSaveFileNum (size-0
# externs without it, so no run from boot could read or write them) and the
# real get_mario_spawn_type / sWarpBhvSpawnTable lookup.
generated/area.v: $(SM64)/src/game/area.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

# engine/surface_load.c (2026-10-22): the real storage of
# gStaticSurfacePartition / gDynamicSurfacePartition / sSurfacePool /
# sSurfaceNodePool (size-0 externs without it: the boot image gave the
# partitions no bytes, so no find_floor from boot had an execution) and the
# real level / object collision loaders (alloc_surface_pools,
# load_area_terrain, clear_dynamic_surfaces, load_object_collision_model).
# game/camera.c (2026-10-22): the camera is part of the ABC argument (HOLP), and
# it holds the real storage of gPlayerCameraState, which init_mario_from_save_file
# points m->statusForCamera at and every nonzero-action frame stores through
# (a size-0 block without it: no such frame from boot had an execution).
# game/ingame_menu.c (2026-10-22): the real body of reset_red_coins_collected
# (load_area_terrain calls it) and the storage of gRedCoinsCollected; also the
# dialog / menu-mode functions the cutscene actions call.
# Its menu strings come from BUILD_DIR/include/text_strings.h, which the
# decomp's own build makes with its own tool (vendor Makefile, "Encode in-game
# text strings"): tools/textconv over the preprocessed charmap.txt
# (text_strings.h.in) and charmap_menu.txt (text_menu_strings.h.in).  Same
# recipe, US flags.
TEXT_H := $(SM64)/build/us/include/text_strings.h
$(TEXT_H): $(SM64)/include/text_strings.h.in $(SM64)/include/text_menu_strings.h.in $(SM64)/charmap.txt $(SM64)/charmap_menu.txt
	$(MAKE) -C $(SM64)/tools textconv
	mkdir -p $(SM64)/build/us/include
	cpp -P -Wno-trigraphs -D_LANGUAGE_ASSEMBLY -DVERSION_US=1 -DBUILD_DIR=build/us -o $(SM64)/build/us/charmap.txt $(SM64)/charmap.txt
	cd $(SM64) && tools/textconv charmap_menu.txt include/text_menu_strings.h.in build/us/include/text_menu_strings.h
	cd $(SM64) && tools/textconv build/us/charmap.txt include/text_strings.h.in build/us/include/text_strings.h

# game/debug_course.c (2026-10-22): nop_change_course, which the real
# lvl_set_current_level calls on every course change (CourseRun runs it).
generated/debug_course.v: $(SM64)/src/game/debug_course.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

generated/ingame_menu.v: $(SM64)/src/game/ingame_menu.c pipeline/clightgen.sh pipeline/proof_n64.h $(TEXT_H)
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

generated/camera.v: $(SM64)/src/game/camera.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

generated/surface_load.v: $(SM64)/src/engine/surface_load.c pipeline/clightgen.sh pipeline/proof_n64.h
	$(CLIGHTGEN) $< $@ $(SM64_CGP)

# Mario's animation data (2026-10-22; TRUST 0.8(f)).  The real build makes
# BUILD_DIR/assets/mario_anim_data.c from assets/anims/*.inc.c with the
# vendor's own tools/mario_anims_converter.py (vendor/sm64/Makefile:667) and
# links its .data into the ROM's `assets` segment (sm64.ld:1334), the source
# of the DMA table gMarioAnims.  We run that same converter, into the same
# path, and clightgen its output.  Data only: not linked into the program
# (the game reaches it only by DMA from ROM); PoleAnim.v reads it.
ANIM_C := $(SM64)/build/us/assets/mario_anim_data.c
$(ANIM_C): $(wildcard $(SM64)/assets/anims/*.inc.c)
	mkdir -p $(dir $@)
	cd $(SM64) && python3 tools/mario_anims_converter.py > build/us/assets/mario_anim_data.c

generated/mario_anim_data.v: $(ANIM_C) pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(SM64_CG)

# libultra (2026-10-21): see ULTRA_CG above.
generated/libultra_osEepromLongWrite.v: $(ULTRA)/osEepromLongWrite.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(ULTRA_CG)

generated/libultra_osEepromWrite.v: $(ULTRA)/osEepromWrite.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(ULTRA_CG)

generated/libultra_osSiCreateAccessQueue.v: $(ULTRA)/__osSiCreateAccessQueue.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(ULTRA_CG)

generated/libultra_osCreateMesgQueue.v: $(ULTRA)/osCreateMesgQueue.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(ULTRA_CG)

generated/libultra_osContInit.v: $(ULTRA)/osContInit.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(ULTRA_CG)

generated/libultra_osInitialize.v: $(ULTRA)/osInitialize.c pipeline/clightgen.sh
	$(CLIGHTGEN) $< $@ $(ULTRA_CG)
