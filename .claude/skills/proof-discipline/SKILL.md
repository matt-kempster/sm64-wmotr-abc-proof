---
name: proof-discipline
description: Checklist for proof work in this repo. Use before committing Rocq/Coq changes, and before adding a Definition/Lemma/Hypothesis to the spine. Progress means the capstone says more about the REAL SM64 program; a green build, axiom-cleanliness or a new disconnected lemma is not progress. Covers the audit script, the tethering test, phantom-forall rows, and statement fidelity.
---

# Proof discipline

## The one question

> Is the capstone now closer to a **true** statement about the **real** SM64
> program than it was before?

Green builds, axiom-cleanliness and new true lemmas are the floor. They are not the
goal. The failure this skill exists for is a session of clean, `Qed`'d work that is
disconnected from the real theorem: lemmas about placeholders, or a definition that
doesn't mean what its name says. This happened here once: four green, axiom-clean commits,
all in `Unwired/`, and the theorem moved nowhere. See
[*Did you prove what you think you proved?*](https://leanprover-community.github.io/did_you_prove_it.html).

## Where the bottom line is (keep this current)

- **GOAL 1** (no-A ⇒ no-fly): `NoAImpliesNoFly/NoAImpliesNoFlyTwelve.v`,
  `noA_no_spawn_never_flying_linked12`. The step is one real `execute_mario_action` over
  any link of the 14 TUs (the 12 Mario TUs + `surface_collision` + `math_util`, since
  2026-10-17). The open surface is its `Hypothesis` rows (17 as of 2026-10-21, counting
  the structural pins; GOAL 2's `HeightLinked12` section has 23; external-call and boundary rows,
  see `docs/TRUST.md` §4). The collision rows
  (`SurfaceBodies.v`) and the math_util rows (`MathBodies.v`) are lemmas, and so is
  `Hscp_mtxf_real` since 2026-10-21 (`MtxfBody.v`). Because `vec3f_normalize` reloads its
  `dest` after `sqrtf`, the capstone takes the FPU floor `Hsq : sqrtf_spec` (TRUST 3.5) in its place.
  The two animation rows `Hgeo_real` / `Hocp_rai_real` are lemmas since 2026-10-20
  (`GraphNodeBodies.v`; `graph_node.c` is the 19th TU): their real bodies store only through a
  pointer parameter that the gate pins NULL / puts in a caller stack local.
  `Hcp_savefile_real` is a lemma since 2026-10-21 (`SaveFileBody.v`; `save_file.c` and
  `buffers.c` are TUs 20 and 21): every store lands in `gSaveBuffer` / `gSaveFileModified`,
  both stored globals (TRUST 4.1).
  The three arg0-gated object-helper rows `Hcsp_omfd_real` / `Hcsp_scale_real` /
  `Hcsp_osh_real` are lemmas since 2026-10-21 (`ObjHelpersBodies.v`; `object_helpers.c` is
  the 22nd TU): every store goes through the SafeB `obj`, and the two pointer stores hold
  `gCurrentObject`'s (SafeB) value or `segmented_to_virtual(arg1)`.
  Since 2026-10-21 `segmented_to_virtual` / `virtual_to_segmented` are the decomp's
  `NO_SEGMENTED_MEMORY` identity (`memory.c` only, `-DPROOF_MEMORY_C=1` + `proof_n64.h`; TRUST
  2.2 register, tethered). Before, they had NO execution on any pointer. Since 2026-10-22
  `VIRTUAL_TO_PHYSICAL` / `PHYSICAL_TO_VIRTUAL` are that identity too (all game TUs): mixing the
  N64 V2P with the identity s2v had left every anim-sample read out of bounds (a vacuity). FOUND FALSE then:
  `Hcsp_osh_real` for any arg1 (`heldBehavior` lands in `curBhvCommand`, R7). Restated:
  `OutParamSurface.cs_gate` also gates osh's arg1 to `bhv_held_syms`; walkers check it
  (`held_arg_chk`, the bhv symbols listed in xids). Since 2026-10-21 `data/behavior_data.c` is
  linked (30th TU, data only; every `bhv*` declaration completed to the definer's length and
  readonly bit by a 2.4 RULE in `pipeline/clightgen.sh`), so bhv compares and script reads have
  executions. `PoleControl.noA_pole_frames_run` RUNS no-A pole frames through all four
  `mario_actions_automatic.c` compares; `SpawnTypeRun.spawn_type_runs` runs `get_mario_spawn_type`
  (0x12). FOUND: every `act_hold_walking` / `act_hold_idle` frame had NO execution before (its first
  statement is a bhv compare); no row became false. Still stuck: `interaction.c:881,889`
  (warp-pipe collision data, unlinked).
  Spawn pair (`Hcp_spawn_real` / `Hcp_soawr_real`) are lemmas since 2026-10-21
  (`SpawnBodies.v`; `spawn_object.c` is the 31st TU, the whole create/allocate/unload/
  geo_obj_init tree walked). FOUND FALSE: their any-argument forms (`parent` / `behavior` land in
  a SafeB pool object, R7), and `spawn_obj_at_mario_rel_yaw`'s. Restated all-argument gated
  (`call_pres_ext_sg`; engine cs class via `spawn_gate_chk`; `call_pres_ext_sob`); every walker
  checks its real sites (`CensusV2.spawn_args_ok`; `gCurrentObject` joined the cutscene gobj seeds,
  `generate_yellow_sparkles` is a hybrid walk). (`Hsss`, the labeled audio premise for
  `stop_sounds_from_source`, is gone since the 2026-10-23 audio link: its real body is walked.)
  The two any-argument list rows shrank on 2026-10-21 (`ObjExtBodies.v`): the seven linked
  save_file.c / `bhv_spawn_star_no_level_exit` entries leave `obj_ext_open2_ids` and the time-stop
  pair leaves `cut_ext_open2_ids` (`Hpres_cut_ext_open2`); their writes needed six more stored
  globals (TRUST 4.1). `save_file_do_save` is a lemma since 2026-10-21
  (`SaveDoSaveBody.Hpx_sfds`, wired in `cut_ext_open_of2`): six libultra TUs linked (recipe
  `ULTRA_CG`; 29 TUs), walked down to the widened OS / hardware floor 3.5 (`bcopy`,
  `__osSiRawStartDma`, per-queue `osRecvMesg` / `osSendMesg`, and `osSetTimer`, a coarser floor).
  FOUND: the old universal `osRecvMesg` clause was false (`gGameVblankQueue`'s buffer is linked)
  and had no NULL-cell executions; it is now per queue (`q_side`).
  The three area.c entries are lemmas since 2026-10-21 (`ObjExtBodies.Hpx_ovac` / `Hpx_ptr` /
  `Hpx_agwn`): `override_viewport_and_clip` leaves `obj_ext_open2_ids`, `play_transition` leaves
  `cut_ext_open2_ids`, and both capstones take `Hpres_warp_ext_open` (`warp_ext_open_ids`, minus
  `play_transition` / `area_get_warp_node`). No new claim: a non-pointer store into a global
  MWF does not read keeps MWF (`np_store_pres`), so `gWarpTransition` & co. did not have to join
  `stored_globals`. Still-linked any-argument entries: none (the spawn pair left `cut_ext_ids`).
  Counts: GOAL 1 15 (was 17 before the 2026-10-22 sweep, below); HeightFrame 26 incl. its 3 section rows (2026-10-21, spawn: −2 rows, +Hsss).
  2026-10-22 GOAL 1 premise sweep: FOUND FALSE `WL_exempt` (forall e: an env binding `sqrtf` to
  set_mario_action's block refutes it, `WLExempt.wl_exempt_old_refuted`; every capstone that took
  it was VACUOUS). Restated at empty_env + function-typed Evar (`CensusV2.wl_exempt_ok`) and PROVED
  for every link (`wl_exempt_linked12`): GOAL 1 17 -> 16 rows, HeightFrame -1. `CameraBodies.v`:
  `camera_approach_f32_symmetric` / `trigger_cutscene_dialog` left `cut_ext_open2_ids`;
  `sqrtf` (from `Hsq`) and `set_camera_shake_from_hit` left `obj_ext_open2_ids`, `random_float`
  (behavior_script.c, unlinked; the shake's SHAKE_SHOCK arm) joined it. `Hext_action` /
  `Hmwf_ext` are lemmas over `Hext_action_ns` / `Hmwf_ext_ns` (sqrtf excluded, from `Hsq`);
  since 2026-10-23 those are lemmas too, first over `Hext_action_ptfi` / `Hmwf_ext_ptfi`
  (`print_text_fmt_int` alone, `RestSurface.rest_external_cases`), and since the PRINT LINK
  (print.c = 42nd TU, `PrintBodies`) over nothing: the ptfi rows are gone, GOAL 1 15 -> 13,
  HeightFrame 24 -> 22. FOUND FALSE first (any-argument / any-pool body); restated with the
  `T_ptfi` gate (x, y, n not pointers) and `CensusV2.print_safe_syms` in `safe_ptr_syms`.
  `Hcsp_scm_real` DERIVED from `Hscm_body_real` (cs_gate arg0 = wgate T_scm arm; NoA from MWF):
  GOAL 1 16 -> 15, HeightFrame -1 more.
  2026-10-23 EXTERNAL-LIST CLOSURE: `Hpres_obj_ext_open2`, `Hpres_cut_ext_open2`,
  `Hpres_floors_ext_open`, `Hpres_warp_ext_open` are GONE (GOAL 1 13 -> 9, HeightFrame 20 -> 16).
  The warp list was already empty; the 7 cut + 2 obj ingame_menu / audio entries are walked
  (`MenuBodies`; FOUND FALSE: `create_dialog_box_with_var` stores its s32 arg into
  `gDialogVariable`, now a stored global); `engine/behavior_script.c` is TU 43 (`random_float`,
  `MenuBodies.Hpx_rf`) and `game/obj_behaviors.c` TU 44 (`spawn_default_star`, `SpawnStarBody`;
  `bhvStarSpawnCoordinates` joined `spawn_bhv_syms`, `sb_gs` gained `gCurrentObject` + it).
  `Hscm_body_real` PROVED 2026-10-23 (`CameraModeBody.v`, class walker over 60 real bodies in
  camera.c / math_util.c / surface_collision.c + play_sound + sqrtf; the WRITABLE
  `sModeTransitions` indirect call is covered by a per-TU type certificate: only the 14
  transitions have type (Camera*, f32*, f32*)->s32). Needed `sMarioCamState` and the two surface
  partitions in `CensusV2.camera_safe_syms` (SafeB_boot meets it). GOAL 1 13 -> 12,
  HeightFrame 20 -> 19 `Hypothesis` lines (TRUST 4.1).
  2026-10-24 OBJECTS S1 (groundwork for the real `update_objects`): `spawn_sound.c`,
  `debug.c`, `object_collision.c` linked as TUs 47-49 (45/46 and hud.c's 51 from master
  spliced in). `RealFrameLinked.execute_mario_action_step_lp_any`: the frame's `Vptr b 0` argument
  pin is no restriction (param unused, `Generic/UnusedParam`). `BehaviorScripts.all_tus` made
  current; FOUND FALSE: the unconditional grab fact (the debug spawner spawns two grabbable
  objects under its guard). Restated over the closure without that body; the guard is S2's
  `obj_w`. `wmotr_live_natives` pinned (107). `obj_behaviors_2.c` is TU 50 (the live
  `bhv_red_coin_star_marker_init`); only the 2 `mario_misc.c` over-approximations lack a
  linked body. 2.2 picked values in the object TUs: none in the WMotR closure
  (`ub22_sites_not_live`). Counts unchanged (GOAL 1 8, HeightFrame 15 `Hypothesis` lines).
  2026-10-25 OBJECTS S3 groundwork: `WMotRRequiresA/ObjStoreCensus.v` (spine-root, new file)
  pins by vm every store / pointer argument of the 432 bodies a non-Mario slot runs whose
  root is not the running object, a stack local or a parameter (TRUST "Object store
  census"). FOUND: object code writes Mario (`gMarioStates`, via `gMarioState` /
  `gMarioObject`, `set_mario_action` through `set_mario_npc_dialog`), so the S3 kW walker
  needs per-entry contracts. `gcur_not_stored`: "o" is fixed for the update. Next: an
  `ObjKit` class walker (UcKit-style, a kSelf class) consuming this census.
  2026-10-25 `ObjKit.v` / `ObjTable.v` (spine-root): UcKit's walker over 387 object bodies,
  `obj_body_pres` (mem_ok kept by every walked nullary body: 104/107 live natives + the VM
  commands). Open: `Hopen`'s 5 leaves (push_mario_away, 1up_interact, start_object_cutscene,
  cur_obj_update_floor, cur_obj_call_action_function), then cur_obj_update / call_native
  (need the script-pointer row), then the frame (writes only SafeB / fresh / non-MWF
  globals / listed Mario cells). Regenerate ObjTable from the scratch probe (sig inference
  to a fixpoint, then `uchk`), never by hand.
  2026-10-25 `ObjWalk.v` (extended walker: Mario-temp / Mario-array / stored-global store
  arms + a frame conjunct, generic over the table and a Mario cell list) and `ObjFrame.v`
  (spine-root): 390 bodies re-checked by vm; sub-contracts `push_mario_away_contract`
  (pos[0]/pos[2]), `one_up_contract` (numLives), `object_cutscene_contract` (no Mario cell);
  `obj_body_pres2` (Hopen 5 -> 2); `obj_body_frame` (mem_ok + frame; open premises
  `Hfr_open` = load_sequence / npc_dialog frames, `Hopen2` = update_floor /
  call_action_function). Open next: those four leaves' frames (update_floor needs find_floor's
  out cell to hold kS), a kSelf class (own object vs other slots), cur_obj_update /
  call_native (script-pointer row), then wire into S2's obj_w / PhiW.
  2026-10-25 `LsContract.v` (spine via ObjFrame): `ls_contract` / `ls_frame` moved out of
  `Unwired/CapAudio`; `obj_body_frame` takes `ls_contract` (4.1) and `ls_FR` derives
  load_sequence's frame from it (`Hfr_open` -> `Hnpc_fr`, npc_dialog only).
  2026-10-25 ObjWalk S-locals + `XS`: `cur_obj_update_floor` walked (getter's `floor` cell is
  an S-local, getter returns kS); `Hopen2` = call_action_function only.
  2026-10-25 `NpcFrame.v` (spine via ObjFrame): `npc_dialog_frame` walks set_mario_npc_dialog's
  real call tree; `Hnpc_fr` discharged (ObjFrame now asks only `HMCn`: MC holds npc_cells).
  2026-10-25 `RoCensus.v` (spine-root census): which code in the whole link can store into
  the 35 action tables / 533 behavior scripts? None (by field name, and by union cell once
  create_respawner's rawData slot 29 is charged to a per-behavior fact); addresses flow only
  to gCurBhvCommand / curBhvCommand / behavior / bhvStack (+ the respawner cell). The RO class
  is cheap: never-a-store-target + boot equality to the initializer + the slot-29 fact.
  2026-10-25 `ObjSelf.v` (spine via ObjFrame) + ObjFrame sec. 5-6: kSelf = the byte range
  [oc, oc+608) of gObjectPool; `obj_body_self_frame` (no SafeB/MWF premise) for the 200
  self-clean entries (`self_walk_ok`, vm); 46/107 live natives self-clean, the other 61 named
  in `cross_live` (spawn targets, loaded object pointers, call_action_function, interior
  self pointers into vec3f_* helpers). Koopa race / boo_key / respawner not in the closure.
  Open next: an interior-self-pointer kind (KSelfAt d) for vec3f_* / object_step, then
  per-call frames for spawns (the new slot is not the running one).
  2026-10-25 (2) SHELVED after a checker-only probe (scratch, no proofs). The class was: a
  pointer is non-pool, or pool at window offset d with reach R, with field and index shifts
  and a per-parameter reach. It covers 50/107 live natives, a strict superset of kSelf's 46:
  +end_peach, white_puff_exploding, bowser_key_unlock_door and bowser_key_course_exit, all
  via geo_obj_init_animation(&o->header.gfx, ..). The table grows to 213. Of the 57 still
  uncovered: 46 reach create_object (spawn_object -> spawn_object_at_origin; spawns are the
  binding constraint); 4 store across objects (1up_loop via 1up_interact -> numLives,
  end_toad, idle_water_wave, 1up_hidden_in_pole_trigger; clear_particle_flags -> gMarioObject
  is a callee of spawners); 2 are
  call_action_function bodies (exclamation_box, cannon_base; see caf_frame); 2 are
  unlock_door_star (indirect call); the singles are load_object_collision_model,
  normal_cap_init (save_file_set_cap_pos) and a debug print. Worth +4; redo after (3).
  2026-10-25 `ObjAct.v` (spine-root): `caf_frame` = call_action_function's frame for the 3
  live tables under the named premise `RO_tab` (boot: `ro_tab_boot`, real init_mem); 15
  action bodies + 4 helpers walked (`act_walk_ok`); sizes pinned (`act_size`); oAction
  stores constant + in range (`act_stores_census`); respawner not live. ObjWalk: narrow-
  parameter argument rule (`kargs_okx`). OPEN (spine-wide): carry RO_tab across the run --
  the 3 tables are SafeB globals, so FR allows writes; needs a non-SafeB/MWF-style class
  for them (cf. knockback_table_ids, ~20 files) -- then Hopen2 is discharged at the 3 call
  sites.
  OPEN (UB coverage, TRUST 3.2): caf_frame's index has no premise only because an
  out-of-range `tbl[oAction]` is stuck in Clight -- excluded, not proved absent (N64 reads
  adjacent memory). S2: `act_in_range` as an obj_w clause from `act_stores_census` + spawn /
  init. Rule everywhere: never treat "Clight gets stuck" as discharging a premise.
  2026-10-25 (3) `ObjSpawn.v` (spine-root, option B): ObjSelf's walk generalized (section
  GEN, `s_fun_frame3`): the frame is parametric in protected pool cells Pc, and a 4th kind
  KFresh = the running slot or a slot with no Pc byte (FVv); fresh temps come only from
  fresh/self values or calls of fresh-returning functions (`spawn_rft`: spawn_object*,
  spawn_star, spawn_water_droplet, try_to_spawn_object). Pc P = bytes of a slot in P outside
  the link cells [4,20) (graph prev/next/parent/children) and [96,104) (list next/prev),
  offsets pinned by `link_offsets` (vm). `obj_body_spawn_frame`: 244 entries
  (`spawn_walk_ok`, vm), 62/107 live natives (kSelf 46 + 16), 45 uncovered
  (`spawn_uncovered`). Remaining blockers: spawn_object_relative (obj_build_relative_transform
  / obj_translate_local store at a VARIABLE rawData index), physics movers (object_step,
  coin_step, cur_obj_move_standard), the 4 cross-object stores, unlock_door_star,
  load_object_collision_model, call_action_function bodies, debug printers, singles.
  OPEN ROW `Hspawn_fr` (`ObjSpawn.spawn_fr`, per-call, not a TRUST row): every call of
  spawn_object_at_origin changes pool cells only in the running slot, in slots not in P and
  in link cells, keeps gCurrentObject's cell, and returns the running slot or a slot with no
  protected byte. SPEC FOR ITS DISCHARGE (option A, after S2) -- the reachability facts it
  hides, as an obj_w invariant: (a) the chain from gFreeObjectList.next via header.next is
  acyclic, ends at NULL, and every member is inactive (activeFlags = 0), hence not in P;
  (b) when the free list is empty, the unimportant list's head (gObjectLists[UNIMPORTANT]
  .next) and its next carry ACTIVE_FLAG_UNIMPORTANT, hence are not in P; (c) every slot's
  link cells hold a pool-slot pointer or a sentinel (gObjectLists, gFreeObjectList,
  gObjParentGraphNode), and a live slot's graph parent is gObjParentGraphNode; (d) census:
  only object_list_processor / graph-node list code stores link fields, sets activeFlags
  active, or stores the list globals.
  STALE POINTERS ("spiny adoption", `ObjStoreCensus` sec. STALE): Hspawn_fr covers the
  spawn only. A write through a STORED object pointer (parentObj, prevObj, heldObj, usedObj,
  interactObj, riddenObj, oFoo pointer fields, gMarioObject, ...) is NEVER assumed to hit its
  intended object: the walk gives such a pointer KAny, so no body storing through it is in
  spawn_tab. S2's uncovered-natives row must, per write, EITHER prove the target is still
  that object (the holder outlives it / is cleared with it) OR prove the write cannot hit a
  protected slot (pole, cannon, Mario's object). `lakitu_spiny_not_live` (vm): enemy Lakitu
  and Spiny are not live. Object phase: no FOUND. OPEN: Mario-phase writes through usedObj /
  interactObj / riddenObj / heldObj (act_in_cannon writes usedObj->oAction and
  oInteractStatus; mario_stop_riding_object; door / hoot / shell actions) need the same
  either/or in S2.
  2026-10-24 `UpdateCameraBody.update_camera_pres`: the REAL `update_camera(c)` (SafeB c) keeps
  `mem_ok`. 507 bodies (the whole recursive tree: `UcKit` two-mode class walker, `UcTable`
  signatures re-checked by vm), the 336 CameraEvent functions by type certificate. Wired as
  `HeightFrame.update_camera_ok_linked12`, for the level phase's camera call. No new
  premises: hud.c linked as TU 51 (`set_hud_camera_status` walked), `set_mario_npc_dialog`
  proved from its body (`NpcDialogBody`, GOAL 1's `smact_pres`). HeightFrame stays at 19
  `Hypothesis` lines. `camera_safe_syms` +7 camera globals. FOUND:
  `gCutsceneFocus` is a stored global, so it cannot be SafeB (the tree only reads it).
  `uc_census` (vm-pinned): 202 bodies store or pass pointers outside the camera-private class.
  The main ones: `gPlayerCameraState` via `sMarioCamState` (72), `sCutsceneVars` (82),
  `gLakituState`, `gCutsceneTimer`, `gCameraMovementFlags`, `gSecondCameraFocus` objects, the
  surface / RNG / time-stop / dialog / audio globals, plus Mario's action via the npc-dialog
  leaf. That is where a GOAL 2 Phi carry across update_camera can be false.
  2026-10-22: HeightFrame's section has 27 `Hypothesis` lines (28 → 27: `Hcamera` proved away).
  2026-10-23 AUDIO LINK (`audio/external.c`, `sound_init.c`: TUs 40, 41; `AudioBodies`, `SndXc`):
  GOAL 1 `Hypothesis` lines 16 → 15, HeightFrame 26 → 24. Proved: `Hpres_sta_ext`, `Hsss`,
  the audio entries of the obj/cut/warp open lists and of `Hpres_floors_ext` (now
  `Hpres_floors_ext_open` = `spawn_default_star`), `Hext_action_ns` / `Hmwf_ext_ns` (now over
  print_text_fmt_int), GOAL 2's `Haudio` and `BootRun.audio_ret`. New labeled open audio premise
  `Hls` (`load_sequence`, audio/load.c = the audio thread's sequence loader; both capstones).
  GOAL 2: play_sound / set_sound_moving_speed are CLOBBER contracts (regions RSR / RSRC / RSMS,
  2^32 at base 0, in every walk's R0F and in `FfWorld.ff_rl`; NBF = 22). `sSoundRequests`
  joined `stored_globals` (play_sound stores its `pos` pointer there).
  `surface_load.c` linked 2026-10-22 (32nd TU), then `macro_special_objects.c` + WMotR level data
  (TUs 33-34): counts unchanged (no row names their functions).
  2026-10-22: FOUND (oracle difftest) + REPAIRED: `gMarioAnims` was a size-0 block, so every
  `load_patchable_table` compare (`memory.c:575`) had no execution: 523/600 real frames STUCK.
  `mario_anim_data.v` is now linked (36th TU; 2.4 anim-data completion of game_init's decl).
  Counts unchanged; no proof broke. Difftest seeds 2+3: 600/600 MATCH, 0 STUCK (no `ROM_SIZED`).
  `BootRun`'s entry frame now runs that compare on the real block (header copied from the
  linked data). `tools/size0_globals.py` also walks the game thread (class (c), `BOOT_KNOWN`):
  `setup_game_memory` has no execution (`gDemoInputs` NULL compare, ROM-symbol subtraction).
  Open: StartSat's anim table is still the count-0 stand-in; DMA content is not modelled.
- **Refutation sweep 2026-10-22** (`docs/TRUST.md` §7, `MarioModel/Refutations.v`).
  REFUTED + repaired: every run oracle (`BootRun.world`, `TerrainRun.world`,
  `PositiveControl.flat_world`, `PoleControl.pole_world`) answered `sqrtf` at ANY signature.
  CompCert's `ec_well_typed` forbids a single at an int result, so each `world_ok` (and
  `sqrtf_ieee`) was FALSE. VACUOUS until now: the positive control, the pole runs,
  `boot_frames_run`, and `goal2_start_sat`'s `terrain_loaded` / `frame_runs` / `ifs_tether`.
  Control oracles repaired here; BootRun / TerrainRun via `FpuValue` (parallel branch). Lesson: a hypothesis that asserts an external
  BEHAVIOR EXISTS must respect CompCert's `ec_*` axioms, so never quantify it over `sg`.
  SUSPECT (argued, not proved), open:
  - GOAL 2 `Hseg_any`: any-argument `spawn_wind_particles` over phantom `gFreeObjectList`. The
    call is dead in WMotR, so gate it on the wind branch.
  - GOAL 2 `Hauto_rest` at TOP_OF_POLE*: phantom anim buffer, offset up to +8191. FALSE as
    stated. DISCHARGED 2026-10-23: proved from the real animation data (TRUST (p)).
  - RESOLVED 2026-10-23 (print link, FALSE + repaired): `Hext_action_ns` / `Hmwf_ext_ns`: `print_text_fmt_int`'s `gEffectsMemoryPool` was
    unconstrained.
  - On linking audio: `play_sound` stores `pos` (R7), so gate it first. RESOLVED 2026-10-23
    (obj_behaviors.c linked): `spawn_default_star`'s `bhvStarSpawnCoordinates` was not in
    `safe_ptr_syms`; it joined `spawn_bhv_syms` and the body is walked (`SpawnStarBody`).
  SURVIVED: `Hscm_body_real` (its only phantom store writes 0; PROVED 2026-10-23), the structural
  pins, and the restriction-only external specs.
- **GOAL 2** (WMotR needs A): `WMotRRequiresA/HeightFrame.v`,
  `wmotr_noA_height_bound_linked12`. This is a conditional theorem over ONE WMotR
  visit (frames end with `in_wmotr`), under input with A neither pressed nor held
  (`a_used_real`). Φ is concrete
  (`HeightInvariant.v`), `Hphi_y` is proved (YMAX = 2796), the level-data rows are proved (`WMotRLevel.v`), and the crux is the lemma
  `seg_action_phi`, whose move arithmetic is proved (`HeightMoveCatalog.chain_keeps_budget`).
  Its start premise is proved satisfiable (`StartSat.goal2_start_sat`, 2026-10-20, in the audit):
  a memory built from the real boot image of any 23-TU link meets `mem_ok_lp` and `PhiW`. Since
  2026-10-21 that witness carries the REAL entry's height cells (`WMotREntry.v`, read off the
  generated level script / level_update.c: bhvAirborneWarp at y = 2669,
  ACT_SPAWN_NO_SPIN_AIRBORNE, vy = 0, margin 127), so the Φ budget clause is true at entry. The
  rest of Φ at real WMotR entry stays ASSUMED (TRUST 0.4). Since 2026-10-21 `area.c` is linked
  (23rd TU) and `goal2_start_sat` concludes `in_wmotr`: `gCurrLevelNum = 31` on the witness is
  stored by the REAL generated `initiate_warp` + `warp_level` head (`EntryWarp.v`), each store an
  `MWF_real` brick. Still from source: the castle painting node, the level script between them,
  the rest of `warp_level`, and the spawn-type lookup (read off area.v data, and since 2026-10-21 also
  RUN by `SpawnTypeRun`, but on a built object, not the level script's). Since 2026-10-22
  `surface_load.c` is linked (32nd TU). FOUND: both collision partitions were size-0 blocks at
  boot, so at any in-bounds (x, z) `find_floor` / `find_ceil` / `find_wall_collisions` had no
  execution from boot, and so no nonzero-action frame there did either (no row false: walks are
  partial correctness). `goal2_start_sat` now concludes `part_ready` (every list head loads,
  NULL). No capstone row names a surface_load function, so 0 rows discharged.
  2026-10-22, later: FOUND FALSE + repaired `floor_data` (in `PhiW`): `Hit_at` allowed int32
  (x, z), the wrapping edge tests pass far away, and a sloped floor's plane height is huge there,
  so `PhiW` was false on every memory with WMotR's terrain (phantom ∀, hidden by the empty
  witness partition). Now `ffl_hit16` (s16 x, z, proved from find_floor's casts).
  `macro_special_objects.c` and WMotR's level data are TUs 33-34. TRUST 3.6 (main pool = one
  block) was added. `TerrainRun.terrain_runs` RUNS the real `alloc_surface_pools` +
  `load_area_terrain` (1352 surfaces) and proves `floor_data` + decoder agreement on the result
  (`TerrainBound.tri_chk_sound`: per-triangle binary32 bound). "This is the loader's output" is
  conditional only on the FPU value clause `sqrtf_value` (since 2026-10-22, see below). `main_pool_init` has no CompCert execution (ALIGN16 on a pointer).
  2026-10-22, later: the GOAL 2 start witness CARRIES that terrain (`StartTerrain`): the loader
  runs on the `init_mem` image (`InitMemC.init_mem_c`, computable init_mem) in the real order
  (warp stores, pool post-state, alloc_surface_pools, load_area_terrain, init_mario cells);
  footprint / pointer / list checks + `InterpFrame.ex_call_keep` re-prove `MWF_real` (SafeB + pool
  block), neutrality and `Wff` across the load; `goal2_start_sat` concludes `floor_data`,
  `static_agree`, 1352 surfaces and `terrain_loaded` (replaces `part_ready`).
  2026-10-22, later: FOUND FALSE + repaired: the `sqrtf` antecedent `sqrtf_ieee` (and so both
  interpreter `world_ok`s) was refutable from CompCert's `ec_well_typed` (any-signature form,
  `FpuValue.sqrtf_any_sig_false`): `terrain_loaded` / `frame_runs` / `ifs_tether` /
  `boot_frames_run` were vacuous. Now the FPU floor has a user-approved VALUE clause
  (`FpuValue.sqrtf_value`: decomp signature, +-0 / positive normals, `lib/asm/sqrtf.s`), and the
  terrain tether rests only on it. `ingame_menu.c` linked (36th TU): `reset_red_coins_collected`
  runs its real body, `rrc_inert` deleted. Frame / ifs runs: `sqrtf_value` alone (the labeled
  audio premise `BootRun.audio_ret` is gone since the 2026-10-23 audio link). `gCurrCourseNum` = 23 on the witness, tethered
  by RUNNING the real `lvl_set_current_level(0, 31)` (`CourseRun`, unconditional; `course_set`).
  Next: the `memory.c:120,122` ALIGN16 rewrite (TRUST 3.6). FOUND FALSE + repaired
  when linking area.c: any-argument `override_viewport_and_clip` (in `obj_ext_ids`) stores its
  pointer args into `D_8032CE74/78`; those joined `stored_globals`. Linking a TU turns every
  any-argument row naming its functions into a claim about real code: re-audit them.
  Since 2026-10-20 the three frame rows below are LEMMAS of the frame split (since 2026-10-21
  the STAGED `FrameSplit.frame_stage`, which threads the dispatch's floor refresh
  `FfWorld.fresh` / `fresh_at` through the body in order and over the real dispatch loop); the
  assumed rows are the per-call `Hseg_call_na` (`seg_call_rows_naF`, with `pre_of` / `post_of`:
  update_mario_inputs leaves the floor fresh, handle_special_floors / process_interactions keep
  it, each dispatcher returns 0 or leaves fresh_at) / `Hseg_any` (since 2026-10-23 only the calls
  live in WMotR: `play_infinite_stairs_music()`; FOUND (phantom ∀): it used to cover the linked
  `spawn_wind_particles` with any args from any `fworld` memory, false via a phantom
  `gFreeObjectList`; its blocks are proved dead from W's floor type, `FrameSplit.clw` /
  `guard_mem`, TRUST §7; the two store blocks are proved). Since 2026-10-23 `Hseg_any` and
  `Hair_pro` are PROVED (`ProRows`; 24 → 22 hypotheses). Both were FOUND FALSE (phantom ∀) and
  repaired by strengthening the world: `FfWorld.lvl_w` (gCurrLevelNum = WMotR,
  sPlayingInfiniteStairs = 0) in `fworld` / `PhiW`, and `FfWorld.inputs_ok` (waterLevel =
  -11000, no INPUT_SQUISHED) in `fresh` / `fresh_at` (TRUST §7). Lesson: a row's world must pin
  every cell the real body BRANCHES on, not only the cells it writes. What each per-call row
  carries:
  - `Hframe_stays_noA` (ACT_SQUISHED still needs the dynamic-surface geometry fact in the
    find_floor / find_ceil contracts, docs/goal2-value-walk-plan.md §6)
  - `Hframe_keeps_world`: the run carries `PhiW` = Φ ∧ `WMotRWorld.wmotr_world` (surfaces of
    WMotR's types, nothing held or ridden, no quicksand; collided objects of WMotR's kinds,
    with pole and cannon fields from the level lists, no star, and no stomp bit). Without W the other rows are false
    over phantom worlds; grow W, don't drop it
  - `Hframe_is_move_chain`, the value walk. It is false if an unmodelled move fires, so check the
    `Step` constructors against any new y/vel writer. The airborne dispatcher is split per case
    (`AirSplit`), and the **freefall case is proved** (`FfRow.ff_row`: the real `act_freefall`
    walked by `FfRun` keeps fworld and moves the cells by a MoveChain), started from the carried
    `FfWorld.ffw` (in PhiW / fworld). The **air-hit-wall case is proved** too (`AhwRow.ahw_row`,
    walked by `AhwRun`; the A-gated wall kick is pruned), and so are soft bonk and both air
    knockbacks (`KbRow.kb_row`, generic in the walk theorem `KbRun.kfinal`; walks in `KbRun`),
    and ground pound (`GpRun.gp_kfinal`: windup via `FfClass.gpw_ok`, fall via `ff_ok`), and
    dive (`KbDv`, an air_entry), and both rollouts (`RlF` / `RlB` through `RlRun.rl_kfinal`;
    the air-step summary's entry is the caller's cell terms at the call, `AirSum.icE`).
    and butt-slide air at state 0 (`BsW` through `BsRun.bs_kfinal`: S_tick, then the step from
    the ticked cells `FfClass.ent_bs`; the bounce is an S_attach), and slide kick
    (`SkW` through `SkRun.sk_kfinal`: the step from the ticked cells is one move from the
    pre-tick cells, `AirMove.sk_pre`; gravity 2 via `AirMatch.gk_of`). Every no-A case is
    covered, unconditionally (`KbRow.air_case_rows_ff8`, `air_case_fns_in`). Butt-slide air
    and slide kick are proved at ANY state (2026-10-21: the entry floor is the dispatch's
    fresh floor, `kb_row` takes `FfWorld.fresh`; every walk also checks `RetOk.ret_ok`: FALSE
    or y/floorHeight untouched; `kfinal` has no `walk_entry` premise any more). Past slide
    kick's bounce the step is `S_sk_bounced`, which needs vel' = gravity(vel) exactly: the
    step summary checks `AirMatch.vel_exc` at a constant SLIDE_KICK action (`AirSum.cls_core`;
    −75 only with the clamp fact), turned into the equation by `AirMatch.aclass_air_ex`. Do
    not relax `S_sk_bounced` to a ≤ bound: the signed-energy credit makes that false. ffw's floor refresh still holds for
    `fro_st` (air_entry + ground pound + rollouts, and butt-slide air and slide kick at state 0;
    TRUST 0.6); the ff / ahw rows still read it. The let_go_of_ledge -> SOFT_BONK
    stale floor is REPAIRED (2026-10-22, TRUST (l)): `fresh` carries the slack `action = SB ∨
    fh = -11000 ∨ fh <= y + 140`; use `fresh_fro` / `fresh_ret_ns`, and SB's FALSE comes from
    `SbRet0.kb_kret0`. Walk files: one walk each (KbSb/KbBkb/KbFkb/KbDv),
    `WithGe.with_ge` not `match ge12`, `vm_cast_no_check`, never `eassumption` near a walk. Dive and rollouts read `gAudioRandom`; audio/data.c (its only
    definer) is linked as the 18th TU so those paths have executions. Squish: WMotR's dynamic
    surfaces never come within 150 of a floor/ceiling (`tools/goal2_squish_scan.py`, min gap 276),
    so INPUT_SQUISHED can join the carried input mask when the dispatcher is walked.
  - The **automatic dispatcher** (`mario_execute_automatic_action`) is SPLIT (2026-10-21,
    `AutoSplit.aut_seg`, TRUST (i)-(j)). `Hseg_call_na` is now `seg_call_rows_naFA`, which
    excludes both dispatchers. Since 2026-10-23 (`NaSplit`, TRUST 0.8(q)) it is a LEMMA over
    `HeightFrame.Hseg_na_open : na_open_rows`, which has 8 named per-call rows. Seven calls
    are proved: submerged-cam (dead outside group 0xC0), `update_mario_health` (a walk inside
    `ProRows`' hole), the submerged dispatcher (vacuous under `grp_ok`), and (2026-10-24)
    `mario_reset_bodystate` / `update_mario_info_for_cam` and `squish_mario_model` (an
    object-side hole in `ProRows`: Mario's object's gfx.scale, bytes 44..55; `BodyFrame.v3set_frame`
    walks vec3f_set), and `sink_mario_in_quicksand` (`qs_row`: `ffw` now pins Mario's
    `gfx.throwMatrix` to NULL or `sFloorAlignMatrix`, ff_rl region `RFA` -- a phantom-forall
    repair; the gfx.pos[1] store writes Phi's cell back unchanged since quicksandDepth = +0 and
    x - 0 = x on finite floats; `ProRows`' object window is generic `ow`/`wl`). For reset / info_for_cam, `ffw` now pins
    `m->marioBodyState = &gBodyStates[0]`, and gBodyStates is ff_rl region `RBS`; a pin alone
    is not enough, because the walk regions must exclude it. `ProRows`' hole is generic over
    `XIDS`, and `BodyFrame.Q2` allows freed callee frames (vec3*_copy, `v3_frame`). Dispatcher pres
    now carry `FrameSplit.grp_ok`: the action's group equals the case label, proved at the
    real switch. NEXT: shrink `na_open` one call at a time. **hitbox_and_cap PROVED
    2026-10-25** (`NaSplit.hitbox_row`, 7 named rows left): `HitboxFrame.hitbox_frame` (the
    body changes only bm's hole, the 13 cap-music globals `CapAudio.cap_ids`, gBodyStates and
    Mario's object bytes 2..3 / 508..511; load_sequence through `LsContract.ls_frame`) and
    `HoleX.hx_fworld` / `hx_cells` (ProRows' hole generalised: region globals plus any list
    of globals none of which is in `HoleX.safe_ids`, plus the two object windows; the world
    fact extends over the changed globals by `Wff_global`). `HeightFrame.Hls` is now
    `LsContract.ls_contract` (GOAL 1's row + load_sequence's footprint, TRUST 4.1).
    Design B done: `FloorExec.surf_on` carries `Ple genv_next b` (proved from `dyn_list`),
    `FfKeep.fk_surf` and the six walk rows carry it, and `ffw` has six new fields
    (`ff_Spl` surface pointers dynamic, `ff_Spool` Mario's object in gObjectPool, `ff_Sar`
    m->area dynamic or gAreaData, `ff_Dbt` the DMA buffer dynamic, `ff_Sctl` m->controller =
    gControllers, `ff_Cd` collided objects apart from Mario's; `ffw_surf_ok` has the Ple
    conjunct). FOUND: `ff_Co` / `mobj_apart` / `hole_coll` allowed a collided object at Mario's
    own object (phantom; `ff_Cd` excludes it); "ff_D4 over every global" is false (Mario's
    object block IS a global, gObjectPool); "m->area is dynamic" is false in the game
    (&gAreaData[i]; only the start witness allocates it). CoinLink needs Mario's
    hitboxHeight <= 160: `HitboxFrame.hitbox_hh` / `HH_coin` give 100.0f or 160.0f after the
    body. **Carried since 2026-10-26**: `ffw` fields `ff_HH` (hitboxHeight is 100.0f or
    160.0f) and `ff_HD` (hitboxDownOffset is 0.0f), both cells in `ffw_read`, so every row and
    flank that rebuilds `ffw` keeps them (walk rows via `fk_same`, which already listed both
    cells); the hitbox row re-proves `ff_HH` through `ffw_rebuild_hh` (`HoleX`'s `HHX`, from
    `hitbox_hh`); boot: the real spawn_objects_from_info (allocate_object) stores both on the
    witness, checked on m11 by `StartTerrain.bo_chk` (`bo_chk_hh`). `HitboxFrame.ffw_coin` gives
    CoinLink's Lha / Fha / Hmario_height / Lda / Fda / Hmario_down for m->marioObj from any ffw
    memory. Open: the objects phase must keep bytes 508..511 / 520..523 of Mario's object up to
    detect_object_collisions (it writes only collision fields), and composing `ffw_coin` with
    `mario_coin2_no_contact`. update_mario_inputs: `FfWorld.env_w` (in `lvl_w`;
    proved at boot, `StartSat.L_env` / `L_dbg`) pins gEnvironmentRegions = NULL and
    gShowDebugText = FALSE; gCameraMovementFlags needs no pin; the row still needs the
    collision finders, the double-miss NULL floor (carry "find_floor hits under Mario") and
    INPUT_SQUISHED (a labeled sub-row tied to obj_w). The prologue call is in `Hair_pro`. The
    `quicksandDepth = 0` store is proved (the `qsd_*` lemmas). What stays assumed is the
    12 handler calls, `HeightFrame.Hauto_case : aut_case_rows` (27 → 28 hypotheses).
    Shrink it per case as walks land, as `air_case_rest*` did. Its audit on 2026-10-21
    (TRUST (f)-(h)) found and repaired three false claims; the split found a fourth
    (`used_apart` now says usedObj is not in Mario's block). The pole attach now reaches top + `POLE_UP` (160, the handstand anim). The frame
    world now carries `WMotRWorld.used_ok` (usedObj is a low pole or cannon base in the pole /
    cannon actions). `fresh_at` now covers the automatic group.
    Live no-A cases (12):
    - 6 pole: GRAB_POLE_SLOW/FAST, CLIMBING_POLE, TOP_OF_POLE_TRANSITION, TOP_OF_POLE,
      HOLDING_POLE;
    - 5 ledge: LEDGE_GRAB, CLIMB_SLOW_1/2, CLIMB_DOWN, CLIMB_FAST;
    - IN_CANNON.
    Dead: the hang actions, GRABBED, TORNADO_TWIRLING.
    GRAB_POLE_SLOW/FAST are PROVED (2026-10-22, `PoleRow.aut_case_rows_pole`, TRUST (k)).
    `Hauto_case` is now a lemma, and `HeightFrame.Hauto_rest : aut_case_rest_pole` holds the
    other 10 cases. `Hceil` was FALSE as stated (a dangling `pceil`); it is restated and
    PROVED by `CeilHeight.fc_height` and removed. Pole kit: `PoleRun` (usedObj region RU, `pk_ok`), `PoleClass`
    (classifier), `PoleSound`, and `PoleKeep` (`fkp_ok`, `no_reg`, `fkp_frame_except`).
    LEDGE_GRAB / LEDGE_CLIMB_DOWN are PROVED (2026-10-22, `LedgeRow`, TRUST (l));
    HOLDING_POLE is PROVED (2026-10-22, `PoleHold`, TRUST (m); `set_sound_moving_speed` is
    its real body since 2026-10-23, `SndXc`). `Hauto_rest : LedgeRow.aut_case_rest_ledge` holds 7. Ledge kit: `LedgeRun` (xcL,
    `ufL` with kL), `LedgeClass` (ledge_ok / letgo_ok and their soundness).
    camera.c is LINKED (35th TU, 2026-10-22): `gPlayerCameraState` is real storage, and
    gLakituState is a walk region (`FfRun.RLK`, in ffw / ff_rl), so the REAL
    set_camera_shake_from_hit body is walked and `Hcamera` is GONE (proved, not restated).
    The StartSat witness now runs init_mario_from_save_file's stores (tethered to the real
    body, `ifs_tether`) and `goal2_start_sat` concludes `frame_runs`: one real no-A frame
    runs from the witness (before, it had NO frame: statusForCamera / marioBodyState NULL).
    CLIMB_SLOW_1/2 and CLIMB_FAST are PROVED (2026-10-22, TRUST (n)): ffw carries
    statusForCamera = &gPlayerCameraState[0] (region `FfRun.RPC`, a `kvK` known cell), and
    IN_CANNON and CLIMBING_POLE are PROVED (2026-10-22, TRUST (o), `CannonRow`).
    `used_ok`'s cannon clause carries `cannon_pos_ok` (a logged strengthening). Cannon kit:
    `CannonClass` / `CannonRun` / `CannonWalk`. (A statement-prefix probe must end in a
    `Sreturn`: CLIMBING_POLE's old "needs a camera fact" was that probe bug.)
    ALL TWELVE automatic cases are PROVED (2026-10-23, TRUST (p), `PoleCasesT.aut_case_rows_T`):
    `Hauto_rest` is GONE, replaced by `Hdma_anim : OsDmaFloor.pi_dma_anim_spec` (TRUST
    0.8(f), approved, now load-bearing; count unchanged by it; 24 after the audio link; 22 after ProRows). The six pole actions are re-walked
    with the real animation data (`PoleRunT`: set_mario_animation inline, DMA table +
    gMarioAnims read, `RytXc.c_ryt` per frame), one walk file per start variant
    (`PoleStartT.avars`; `PoleSlowT` … `PoleTopT2`), row `PoleRowT.pole_rowT`. The frame
    world carries `AnimWorld.anim_w` (a logged strengthening: every proved row keeps it via
    `AnimKeep.anim_w_keep`, StartSat establishes it; the flank specs and the open
    `Hseg_call_na` / `Hseg_any` now claim it). Old `PoleRow.pole_row` and the walks
    PoleSlow/Fast/Hold/Climb are retired. Walker trap: a clamped polePos folds
    oPosY + 720.0f to a constant, so `PoleClass.tb` has a constant + offset case.
  - (`wmotr_gap` and `wmotr_poles` are now proved from generated level data, `WMotRLevel.v`)
  - the flank spec (TRUST 0.7): objects. The LEVEL PHASE is real code since 2026-10-24:
    `play_mode_normal`'s slices before / after `area_update_objects` (`LevelFlank`), walked
    (`LevelWalk`, footprint `LevelGvars.level_gvars`), carries proved (`LevelKeep.pre_keeps` /
    `post_keeps`); update_camera's mem_ok via `update_camera_ok_linked12`. ONE labeled row:
    `Hcam_phi` (`LevelKeep.cam_phi_row`, the camera statement keeps PhiW / Mario's surface
    cells; a clobber spec cannot, the Camera shares the surface pool's block; writes to cover =
    `UpdateCameraBody.uc_census`). `surf_apart` is PROVED from Φ since 2026-10-26
    (`RenderKeep.surf_apart_ffw`, design B's `ff_Spl`; no step states it). (gCurrentArea's
    target is CARRIED since 2026-10-25, `FfWorld.area_w`, proved at boot). `warp_w` at the
    POST end is PROVED since 2026-10-26 (`LevelWarp.tail_warp_w`: initiate_delayed_warp and
    the play-mode switch walked; `warp_w` gained a fifth clause, the pending op is no
    credits op, which repairs the FOUND false ∀-row; its only writer is level_trigger_warp,
    called only from Mario code, and the reachable calls all sit in `Hseg_na_open`, so
    whoever discharges those rows must show op ∉ {0x17,0x18}; TRUST 0.7 lists who carries
    it per stage). Next:
    discharge `Hcam_phi` from the census (per-write PhiW keep). Since 2026-10-26 the witness
    has a REAL Camera in gAreaData[1].camera (`StartTerrain.cam_chain`: the generated
    alloc_only_pool_init / init_graph_node_camera / create_camera / reset_camera; FOUND:
    alloc_only_pool_resize has no CompCert execution, pointer minus pointer in main_pool_free,
    so the level pool is made at its resized size, TRUST 3.6), and `StartSat.frame_runs` runs
    area_update_objects and then update_camera on it. Hcam_phi gates (TRUST 0.7 detail):
    set_mario_npc_dialog is reached only from the SSL_PYRAMID_EXPLODE / ENTER_BOWSER_ARENA cutscene
    shots (boot tables), so an honest discharge needs a camera-world carry. That carry pins the
    Camera's cutscene and keeps the cutscene tables, and it is tied to what objects can start.
    Left labeled.
    Mario's render call and
    `apply_mario_platform_displacement` (platform_displacement.c, TU 45) are REAL calls whose
    GOAL-1 and Φ carries are proved (`RenderKeep.render_keeps_phiw`, `PlatformKeep`, 2026-10-23);
    their narrow premise `surf_apart` (Mario's surfaces not in a written global's block) is PROVED
    from Φ since 2026-10-26 (`RenderKeep.surf_apart_ffw`); and `plat_still` (the ridden platform is NULL or has zero angle velocity; FOUND: a rotating
    platform moves pos[1], so the old "y unchanged" platform spec was false of the real body).
    Since 2026-10-24 `plat_still` is no longer a step premise: it is TRUE in WMotR (only the !
    boxes and cannon lids own surfaces; `AngleVelCensus` finds no angle-velocity store on them),
    proved at the boot witness (`StartSat.plat11`), and carried as the last clause of the labeled
    objects spec `seg_rest_spec` (2026-10-26: that spec is GONE, see the objects bullet below).
    `frame_step` now also has idle frames (no Mario update:
    pause, transitions, time stop). The cannon seat list is every home seat + 5k, k = 0..69
    (the base rises with Mario inside; the exact-home clause was FALSE), and lid floor ranges
    are widened 15 down (an opening lid sinks). `lvl_w` also carries `FfWorld.warp_w` (no
    pending same-level warp in NORMAL mode, no demo / credits, delayed-warp source node
    F0/F1/F3), which the level-phase spec needed (phantom ∀); the witness now ends with the
    real `sWarpDest.type = NOT_WARPING` store.
    OBJECTS (2026-10-26, `ObjPhase.v` / `ObjWorld.v`): the objects segment is ONE real
    `area_update_objects` call (`ObjPhase.objects_call`), with `execute_mario_action` as the
    hole (`HeightFrame.mario_hole`, filled by Hframe_action + seg_action_phi). Open, labeled
    rows over the real stages: Hobj_blind / Hobj_fresh / Hobj_noref, Hobj_stores /
    Hobj_counter, Hobj_debug, Hobj_surfaces, Hobj_collisions, Hobj_unload, Hobj_mplat;
    Hplat_keep, Hlvl_ow, Hrender_ow. Proved: the walk of update_objects' body, the clock
    calls, objects_keep, the platform call inside. B2 DONE (ObjLoop.v): update_terrain_objects
    and update_non_terrain_objects are PROVED (update_objects_in_list, both per-list loops over
    obj_w's rings, the list heads, sObjectListUpdateOrder -- now an obj_w clause, ORDER) from
    the per-object rows Hobj_step_terrain / Hobj_step_nonterrain (given the hole; the real
    loop body up to cur_obj_update() keeps Pobj and leaves the node in its ring) and Hobj_ctr.
    Next, B3: discharge the per-object rows by stepping cur_obj_update.
    B3a (ObjCensus.v, 2026-10-26): FOUND FALSE the C comment "no unimportant objects spawn":
    5 list-12 allocators in WMotR's closure; the 3 water ones (Bubble, WaterDroplet,
    SmallWaterWave) can move the walked node into list 8, which is UB (the walk reads list
    8's head as an Object), not a hang. So the ring rows must exclude it via no-water
    (FfWorld.env_w), not weaken to "or moved".
    B3a-2: obj_w clause DRY12 (`ow_dry12`, accessor = the record projection): ring-12 slots
    run ObjCensus.live12 scripts (list-12 minus water movers, all DRY); proved at boot by
    ow_chk. Next: carry DRY12 through the step. Gate the spawners of the water movers:
    - object_step's obj_splash: find_water_level = -11000 and object y >= -11050;
    - Mario's water particles (sParticleTypes): env_w;
    - koopa shell: the wing-cap boxes' behParams.
    B3 (i) CMDTAB: obj_w `ow_cmdtab` (BehaviorCmdTable = its initializer; ObjCensus certifies
    it is read only in cur_obj_update, never written, address never taken); proved at boot.
    Next (ii) CMDPOS (BhvVM.v: the script VM's 741 reachable states; obj_w `ow_vm`), then
    (iii) the cur_obj_update stepper.
    B3 (ii) CMDPOS DONE: obj_w `ow_vm` (slot = a reachable BhvVM state; FOUND: script_ok
    allowed opcode >= 56). PERF TRAP: BhvVM.vm_tab must never be reduced by tactics or by
    kernel conversion (it runs the VM). `Local Opaque` it, and state the soundness lemmas
    over an arbitrary list, as in ObjWorld.vm_b_sound_gen. Never `Eval vm_compute` it into a
    Definition: the readback takes 200 s.
    The object world `ObjWorld.obj_w` is in `fb_ok` (no phantom ∀ over object lists) and is
    PROVED at the boot witness, which now runs the real init_graph_node_start + clear_objects
    and Mario's spawn_objects_from_info; one real area_update_objects runs from it
    (`StartSat.objects_runs`). Discharge order: B2 (done) -> B3 -> B4/B5/B6.
    The controller poll is REAL since 2026-10-23
    (`PollFlank.v`, libultra `osContStartReadData.c` linked as TU 46): `seg_input_spec m i m0` is the real
    `osContStartReadData` (or no request) then the real `read_controller_inputs`, walked down to the
    existing OS/SI floor (`si_raw_dma_spec`, `recv_mesg_spec`) and `sqrtf_spec` -- NO new floor row.
    The capstone's no-A premise is now `PollFlank.pif_a_real` on the PIF reply bytes (TRUST 0.1);
    `a_used_real` is a proved conclusion (`poll_ok`). FOUND: `__osPackReadData` puts 0xFFFF in the
    request's button word, so an unplugged port reads "A" -- the premise ignores ports with error
    bits (`rxLen & 0xC0`), as osContGetReadData does. NO labeled premise left in the poll segment (2026-10-26):
    audio_game_loop_tick / select_gfx_pool, which run between the two calls, are real walked code
    in the segment (`MidKeep.mid_keeps`, row `Hmid_keep` discharged as `mid_keep_linked12`; the pool
    pointers + gGfxPools joined `safe_ptr_syms` as `CensusV2.gfx_safe_syms`; GOAL 1's facts by UcKit). The Phi / plat_still / OW carries are
    PROVED (2026-10-26, `PollKeep.srd_keeps` / `rci_keeps`, via `FootWalk` (generic footprint
    walker) and `Generic/PermWalk` (permission-preservation body check)); HeightFrame row
    `Hsrd_keep` (new) and the strengthened `Hpoll_ok` are both discharged on the link. `ctl_w` gained P1 / P3 / demo-NULL / maxctl / controllerData clauses
    (StartSat proves them at the start); `stored_globals` gained gControllerPads, __osContPifRam.
    HeightFrame `Hypothesis` lines 19 -> 21 (unchanged by the plat_still merge): generic-section rows
    `Hsrd_ok` / `Hpoll_ok`, both DISCHARGED in HeightLinked12 (`srd_ok_linked12`,
    `poll_ok_linked12`); the linked section has 11. The poll's `plat_still` carry is proved (PollKeep).

  The coin link is also open.
- `docs/TRUST.md` is the ledger of everything a reader must believe. Read
  `Print Assumptions` (`pipeline/assumptions.sh`) together with the Hypothesis rows:
  holes appear as axioms, but assumptions appear as rows.

## What counts as progress

1. **Eliminate a row.** Prove it for the real program.
2. **Refine a row** into sharper real pieces that can each be discharged, even if the
   count goes up. This counts only if the new rows:
   - are about real program objects (named functions, fields and offsets from
     `generated/`);
   - are strictly more precise than what they replaced;
   - have a credible discharge path;
   - are consumed on the spine.

   Decompose the gap; never collapse it. A row that restates the conclusion is laundering.
3. **Partial work aimed at 1 or 2, on the spine.** Half a closure on the spine beats a
   finished lemma in `Unwired/`.
4. **Finding that a row, number or design claim is false.** This is progress too, and
   often the most valuable kind. Examples: E3's Δ_pot, the VIRTUAL_TO_PHYSICAL UB frames,
   the flank ∀-rows.

`Unwired/` work isn't done until it is promoted: `git mv` it onto the spine and have a
spine file use it. Otherwise say plainly that nothing consumes it yet. CI's firewall
forbids the spine from importing `Unwired/`.

## We don't need `forall`: SM64 is one specific codebase

One program, one call graph, one set of externals. A row that quantifies over every
`le` / `fd` / `ef` / memory can admit states the game never produces. Then a true fact
becomes a false row. It happened repeatedly:

- `forall le m` in a per-`Sassign` check, where a temp was allowed to alias Mario's block
  although the program had just loaded it from `marioObj`;
- the GOAL-2 flank rows, "spec ⇒ MWF m ⇒ MWF m'" over every m' matching loose y/action
  clauses;
- "y ≤ YMAX is preserved by a frame": false, since upward velocity is unconstrained;
- the crux row with a Φ that lacks an action whitelist, which would range over mem_ok
  memories in A-gated actions.

The fix is always the same: reason about the actual execution, or enumerate the actual
finite set. If a row looks true but won't go through, first ask whether it ranges over
states the program never reaches. Also ask whether each premise is satisfiable: an
unsatisfiable oracle premise makes everything above it vacuous (the P1′ lesson).

## PIPELINE, not bespoke

Every fact about SM64 comes from the clightgen'd AST in `generated/`. Pin constants and
offsets there with `vm_compute` (e.g. `mario_pos_offset_concrete`), and never transcribe
them by hand. Numbers the proof depends on (budgets, level data) come from tools that read
the vendor source, such as `tools/goal2_ladder.py` and `tools/goal2_budget.py`, not from
prose. Check prose against code before building on it.

## How to add an `ffw` fact (GOAL 2's frame-world invariant)

`FfWorld.ffw` is `Ple .. /\ (exists d, ffw_facts G bm m d) /\ floor_data G m`. Here
`d : ffw_wit` is a record of witnesses (`fw_bo`, `fw_ab`, ...) and `ffw_facts` is a record of
named Prop fields (`ff_Lo`, `ff_D4`, `ff_LBS`, ...). Consumers never destruct it by position.
`ffw_unpack EX` names everything and keeps `FWF : ffw_facts ..`. Rebuilds go through
`ffw_rebuild` / `ffw_rebuild_off` / `ffw_keep_off`, whose premises are about the read set
(`ffw_read` / `ffw_read_s` / `ffw_surf_ok`), not about the list of conjuncts. To add a fact:

1. Add a field to `ffw_facts`, plus its hypothesis name in `ffw_unpack` (the `fresh`, the
   `pose proof .. as [..]` and the `ffw_simpl_in`). A new witness instead goes in
   `ffw_wit`, in `ffw_simpl`'s projection list, in `ffw_unpack`'s `destruct d` and in
   `ffw_rebuild`'s `mk_ffw_wit`.
2. If the fact is memory-free, `ffw_rebuild`'s closer already handles it (`assumption`).
   If it reads a cell of Mario's state, add the cell to `ffw_bm_cells`. If it reads a cell
   elsewhere, add a disjunct to `ffw_read` and to `ffw_read_split` (and one closer case in
   `ffw_rebuild`). Every keep proof then gets one more "cell unchanged" goal, closed by
   adding one alternative to its closer list.
3. Establish the fact at boot: add one bullet to `StartSat.ffw11`.
4. A new region also goes in `ff_rl` / `ff_rl_of` and `ffw_reg_ids`, and its symbol fact
   goes in the region lemmas' rewrite lists (`ffw_rl_cases` and the next two). The walk
   machinery's own region list (`FfRun.R0F`, each row's `Eff` / `ff_sizes`) is separate.
   That is the walk's region set, not ffw.

Measured 2026-10-24: a dummy `ff_DUMMY : True` field took 3 lines in `FfWorld.v` (the field
and two names in `ffw_unpack`) and 1 bullet in `StartSat.ffw11`, and no other file changed.
The throwMatrix pin (a witness `bfa`, a region, a symbol fact `ff_SFA` and a read of Mario's
object `ff_LTM`) needed the following outside FfWorld/StartSat:
- one closer alternative per keep proof: the rows' `apply CO`, RenderKeep's `LHo`,
  ProRows' `LHz`/`ozp_k`, FrameSplit's extra `ffw_keep` premise;
- the walk-side region plumbing.

There were no destruct or rebuild edits.
`lvl_w` is the same: `lvl_sym` is `exists id, In id lvl_ids /\ ..`, so a new level cell is
an entry in `lvl_ids` plus its `lvl_w` conjunct. `lvl_w_keep_rl` / `lvl_w_unch` re-prove
generically.

## The audit (the floor)

```bash
bash .claude/skills/proof-discipline/discipline_check.sh
```

It runs the build, checks for holes, checks each capstone's axiom footprint, and runs the
firewall/orphan check. It also prints the residual surface. Run it before committing proof
changes. To audit a specific capstone:
`discipline_check.sh SM64.Proofs.<Path>.<Module> <theorem> ...`.
Always build via `pipeline/*.sh`, never bare `coqc`: a bare `coqc` can report a false green.

### Fast iteration and the shared .vo cache (opt-in; the audit uses neither)

- `bash pipeline/build.sh --quick -j2 [X.vo ...]` builds `.vos` files (`coqc -vos`), which
  skips the BODY of every `Qed`/`Admitted` proof. Use it to check that statements and their
  consumers line up after an edit. It proves nothing. Never commit on it alone. Use it
  AFTER a full (or cached) build. A file's `.vos` is then empty and its consumers load the
  `.vo`, so an edited walk file re-checks in seconds (measured: TerrainRun 843 s full vs.
  14 s, BootRun 715 vs. 13, PoleControl 640 vs. 4). From scratch it is no shortcut: the
  whole tree took 65 min at -j2, because these are NOT skipped:
  - `Definition`s and `Defined` terms, and `Eval vm_compute` inside a `Definition`
    (`mario_anim_data` alone takes 9 min);
  - any proof inside a `Section` that has no `Proof using` (coqc -vos cannot skip it; checked
    on a toy). The `*Row.v` files, for example, still cost 5 min each;
  - PositiveControl (25 min, 10.8 GB, cause unknown).

  A `vm_compute` inside `Lemma … Qed` outside a Section IS skipped. `--vok X.vo` then checks
  X's proofs against its deps' `.vos` files.
- `SM64_VO_CACHE=$HOME/.cache/sm64-vo bash pipeline/build.sh -j2 proofs` shares compiled
  outputs between worktrees. When a file's source, coqc flags, toolchain and dependency `.vo`
  bytes all match an earlier successful compile, its `.vo`/`.glob` are copied in
  (`[vo-cache] HIT`) instead of being rebuilt. Two worktrees compiling the same key at the same
  time compile it once (`WAIT`). Use `--no-cache` to bypass it, and
  `bash pipeline/vo_cache_gc.sh [GB]` to trim it (default 10 GB).
- `discipline_check.sh` ignores `SM64_VO_CACHE` unless `DISC_USE_VO_CACHE=1` is set. It never
  reads `.vos` files.

## Before claiming progress, answer

- **What got more real?** Name the placeholder that became a generated-AST object, or the
  row that was discharged or sharpened.
- **New assumption?** Is it a refinement or a laundering? Update `docs/TRUST.md` in the
  same commit.
- **Spine or island?**
- **Statement fidelity:** do `step`, `mem_ok`, `Phi` and `y_le` still mean what their
  names claim?
- **Non-vacuity:** are the rows jointly satisfiable? Does a positive control or real-game
  tether (`experiments/oracle`) exercise them?
