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
  Still open camera row `Hscm_body_real`: set_camera_mode calls through the
  WRITABLE table `sModeTransitions` (enumerate link functions of type (Camera*, f32*, f32*)->s32),
  ~48 camera.c functions, no pointer-typed store in the tree; needs `sMarioCamState` in
  `safe_ptr_syms` (TRUST 4.1).
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
  - On linking audio: `play_sound` stores `pos` (R7), so gate it first. On linking
    `obj_behaviors.c`: `spawn_default_star`'s `bhvStarSpawnCoordinates` is not in `safe_ptr_syms`.
  SURVIVED: `Hscm_body_real` (its only phantom store writes 0, which is harmless), the structural
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
  `guard_mem`, TRUST §7; the two store blocks are proved). What each per-call row
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
    excludes both dispatchers. The prologue call is in `Hair_pro`. The
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
    0.8(f), approved, now load-bearing; count unchanged by it; 24 after the audio link). The six pole actions are re-walked
    with the real animation data (`PoleRunT`: set_mario_animation inline, DMA table +
    gMarioAnims read, `RytXc.c_ryt` per frame), one walk file per start variant
    (`PoleStartT.avars`; `PoleSlowT` … `PoleTopT2`), row `PoleRowT.pole_rowT`. The frame
    world carries `AnimWorld.anim_w` (a logged strengthening: every proved row keeps it via
    `AnimKeep.anim_w_keep`, StartSat establishes it; the flank specs and the open
    `Hseg_call_na` / `Hseg_any` now claim it). Old `PoleRow.pole_row` and the walks
    PoleSlow/Fast/Hold/Climb are retired. Walker trap: a clamped polePos folds
    oPosY + 720.0f to a constant, so `PoleClass.tb` has a constant + offset case.
  - (`wmotr_gap` and `wmotr_poles` are now proved from generated level data, `WMotRLevel.v`)
  - the flank specs (TRUST 0.7)

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

## The audit (the floor)

```bash
bash .claude/skills/proof-discipline/discipline_check.sh
```

It runs the build, checks for holes, checks each capstone's axiom footprint, and runs the
firewall/orphan check. It also prints the residual surface. Run it before committing proof
changes. To audit a specific capstone:
`discipline_check.sh SM64.Proofs.<Path>.<Module> <theorem> ...`.
Always build via `pipeline/*.sh`, never bare `coqc`: a bare `coqc` can report a false green.

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
