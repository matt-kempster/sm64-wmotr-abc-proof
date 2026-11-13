# The trust ledger — what a reader must believe when the proof is done

Every item a reader has to *accept* in order to believe the final theorem is
about the real Super Mario 64. A proof shrinks this list; it can never empty it.
The target ("~no assumptions") is: **only the Foundations layer remains**, plus a
theorem statement short enough to read, with everything else proved or pinned to
recorded evidence.

Each row: what you have to believe, why it's there, how it's tethered to reality today,
and how it shrinks. Keep this file current: add a row the moment a new kind of trust
enters the proof, and never let one enter silently.

Status key: **PROVED** (a theorem, Foundations only) · **TETHERED** (checked
against the real game, not proved) · **ASSUMED** (neither).

---

## 0. The statement itself

*You must read the final theorem and agree it says "WMotR's star can't be collected
without pressing A".*

| # | Item | Status / notes |
|---|---|---|
| 0.1 | The definition of "no A": **A is neither pressed nor held.** GOAL 2's capstone (since 2026-10-23) states it on **the bytes the controller hardware delivered**: every frame, the PIF reply image `__osContPifRam` after `osContStartReadData` shows `A_BUTTON` (0x8000 of the button word) on no live port, a port whose error bits (`rxLen & 0xC0`) are set being ignored as `osContGetReadData` ignores it (`PollFlank.pif_a_real`). The real poll, walked, turns that into `buttonPressed & A_BUTTON` and `buttonDown & A_BUTTON` clear (`AGates.a_used_real`, now a proved conclusion, `PollFlank.poll_ok`; `buttonDown` @16 pinned against the generated `Controller`). GOAL 1's capstone needs only the pressed bit. | Needs a reader check. Holding A counts as using it (ABC's "0.5x" press, `game_init.c:544`). The held bit is load-bearing: with A held and never pressed, `act_punching`/`act_move_punching` enter `ACT_JUMP_KICK` (not in the no-A whitelist) and the wing cap flutters (`mario_step.c:566`). Details: [row 0.1 in detail](#row-01-in-detail). |
| 0.2 | The definition of "flying" (`Flying.v`: `ACT_FLYING`, `ACT_FLYING_TRIPLE_JUMP`; the invariant set also has `ACT_SHOT_FROM_CANNON`) | Constants read from the generated AST. |
| 0.3 | "Collect the star" = the red-coin star spawns and is touched. The GOAL-2 height bound must imply you can't | **Height form stated** (`WMotRRequiresA/HeightFrame.v`, `wmotr_noA_height_bound_linked12`): a no-A run keeps `pos[1] ≤ 2796` (`PHI_YMAX` = K + A, `HeightInvariant.v`; K = H* = 2424, the wing-cap box top 2320 + 2·52 (the box is scaled ×2), with the level facts it needs proved from generated level data in `WMotRLevel.v` (0.8); A = 372 from `tools/goal2_budget.py` plus the binary32 rounding allowance). Details: [row 0.3 in detail](#row-03-in-detail). |
| 0.6 | GOAL 2's height invariant `Phi` and the Mario-frame rows | **Defined** (`HeightInvariant.height_invariant`, design `docs/goal2-phi.md`): `R_noA` action whitelist ∧ `budget_ok` over the cells action, actionState, actionTimer, pos[1], vel[1], floorHeight and `marioObj->gfx.pos[1]` (what OOB recovery restores). Details: [row 0.6 in detail](#row-06-in-detail). |
| 0.8 | GOAL 2's level data: `wmotr_floor` / `wmotr_pole` / `wmotr_cannon` are WMotR's floors, poles and cannon seats | **Defined from generated/, rows proved** (`WMotRLevel.v`). 2026-10-22: `floor_data` (d) and decoder agreement (a) are PROVED on the memory the real `load_area_terrain` builds (`TerrainRun`, 1352 surfaces); since later that day the GOAL 2 start witness carries it (`StartTerrain`: the loader runs on the `init_mem` image in the real boot order, and `goal2_start_sat` concludes `floor_data` + `static_agree`). Details: [row 0.8 in detail](#row-08-in-detail). |
| 0.9 | GOAL 2's pos[1] writer census is complete (`YWriterCensus.v`) | **Machine-checked list, trusted edges.** Coq scans every function body of the 12 generated Mario TUs and proves: 31 direct `pos[1]` stores and 21 write-escapes (16 whole-vector arg-0 passes to `vec3f_copy`/`vec3f_set`/`vec3s_to_vec3f`, 5 `&pos[1]` passes to `f32_find_wall_collision`), 52 in all; `pos`'s address never reaches a temp, memory, a condition or a return, and no struct copy covers it. Details: [row 0.9 in detail](#row-09-in-detail). |
| 0.10 | GOAL 2's object census: what objects can exist in WMotR and their interaction types (`BehaviorScripts.v`) | **Machine-checked over generated code, frontier trusted.** `generated/behavior_data.v` (clightgen of `data/behavior_data.c`) gives every behavior script as data; a fail-closed decoder mirrors the command layouts. Details: [row 0.10 in detail](#row-010-in-detail). |
| 0.7 | GOAL 2's flank segments (`HeightFrame.v`: level/warp phase, non-Mario objects) do what their specs say: y / action loads as the censuses found them, and each carries GOAL 1's `MWF_real` and Φ (since 2026-09-29 Φ here is `PhiW`, so each flank also keeps the WMotR world: object updates reload only WMotR's surfaces and never hand Mario an object to hold or ride; collision detection registers only WMotR-kind objects, with poles at their level positions, cannon bases at home or risen at most 345 while Mario sits in them (2026-10-24), and no star while coin #2 stands (0.3); no object sets a stomp bit on Mario's object). Since 2026-10-24 the objects spec also ends with the platform fact: gMarioPlatform is NULL or an object with zero angle velocity (`PlatformKeep.plat_still`; it is the object phase that sets gMarioPlatform). The linked segments' surface premise (Mario's wall / ceiling / floor surfaces are not in the block of a global the step writes, `RenderKeep.surf_apart`) is **PROVED since 2026-10-26** (`RenderKeep.surf_apart_ffw`: design B's `ff_Spl` puts Mario's surfaces in dynamic blocks past every global, so no step states it any more); **the controller poll has NO labeled premise left (2026-10-26)**: its Φ, `plat_still` and object-world carries are proved (`PollKeep`), and the code between its two calls (`audio_game_loop_tick`, `select_gfx_pool`) is now real walked code in the segment (`MidKeep`), so no adjacency assumption remains | **Objects: ONE real call, labeled rows over its stages** (2026-10-26, `ObjPhase.v`): the objects segment is the generated `area_update_objects` (gAreaUpdateCounter++; `update_objects(0)`) run as one `eval_funcall` (`ObjPhase.objects_call`); Mario's own frame is not a separate segment any more but the hole in it (`execute_mario_action`, reached through `update_non_terrain_objects`, filled by the proved Mario-frame carries `Hframe_action` + `seg_action_phi`). The body of `update_objects` is walked (its 18 calls, its stack array `cycleCounts`); the clock calls are proved; the stages are **named, labeled rows** over the real callees ((the debug stage `Hobj_debug` is PROVED since 2026-11-07, no row left: `reset_debug_objectinfo`, `stub_debug_5` and `try_print_debug_mario_object_info` walked, `DebugKeep.debug_keeps`, under two start-checked pins in `obj_w`'s `ow_debug`, sDebugPage = 0 and gDebugInfoFlags bit 0 clear; `HeightFrame.obj_debug_linked12`) (the collision stage `detect_object_collisions` is PROVED since 2026-11-07, no row left: the real body walked, its seven clears and three list walks, every store a collision cell of a listed slot with the value the code stores, `CollWalk.detect_keeps` on `CollKeep.coll_store_pc`; `HeightFrame.obj_collisions_linked12`) (the unload stage `unload_deactivated_objects` is PROVED since 2026-11-06, no row left: the loops, the real `unload_object`'s whole carry, `UnloadPc.unl_row_proved`, and the respawn OR into a SpawnInfo cell, `UnloadSi.si_row_proved`; `HeightFrame.obj_unload_linked12`) (the frame-block rows `Hobj_blind` / `Hobj_fresh` / `Hobj_noref` are PROVED since 2026-11-07, no row left: `HeightFrame.obj_blind_linked12` (`BlindKeep`), `obj_fresh_linked12`, `ObjPhase.noref_uo`; the block's privacy is RESTATED relative to a closing injection, see the detail); the store row `Hobj_stores` is PROVED since 2026-11-03, `HeightFrame.obj_stores_linked12` from `ObjStores.stores_safe` (every store block of the generated `update_objects` is decided by vm to be a stack store, an int store into a global no invariant reads, or `gObjectLists = gObjectListArray`, the pointer the cell already holds), resting on `HeightFrame.obj_blind_linked12` for the stack stores; the counter rows `Hobj_counter` / `Hobj_ctr` are PROVED since 2026-11-03, `HeightFrame.obj_counter_linked12` / `obj_ctr_linked12` from `ClearKeep.gstore_keep`); the two list walks `update_terrain_objects` / `update_non_terrain_objects` are **PROVED** (B2, `ObjLoop.v`: the real `update_objects_in_list`, both per-list loops over the rings of `obj_w`, the list heads, the order table) from narrower per-object rows `Hobj_step_terrain` / `Hobj_step_nonterrain` (given the Mario hole: the real loop body up to `cur_obj_update()` keeps the invariant and leaves the node in its ring; since 2026-10-26 each is split, `ObjStepSplit`, into `Hobj_step_act_*`, the update keeps Mario's action outside T, GOAL 1's claim, and `Hobj_step_rest_*`, the rest given that) and `Hobj_ctr`; `apply_mario_platform_displacement` inside it keeps its proved carry, and since 2026-11-03 so do `clear_dynamic_surfaces` (`Hobj_surfaces` is PROVED, `HeightFrame.obj_surfaces_linked12` from `ClearKeep.clear_keeps`: the real body, inverted by `ClearRun.cds_run`) and `update_mario_platform` (`Hobj_mplat` is PROVED, `HeightFrame.obj_mplat_linked12` from `MplatKeep.mplat_keeps`: the real body, find_floor's contract, the floor's object read off `ObjWorld.ow_surf_obj`). The invariant through the phase includes the object world `ObjWorld.obj_w` (carried at frame boundaries; PROVED at the boot witness from the real `clear_objects`, the level's placed objects (Step B, 2026-11-02: the real `level_cmd_place_object` per OBJECT command, WMotR's macro objects, the area's spawn infos; 3.6) and Mario's `spawn_objects_from_info`, and one real `area_update_objects` runs there: `StartSat.objects_runs`; since 2026-11-02 the WHOLE `HeightFrame.play_frame_step` runs from it, every segment a real execution, `StartSat.frame_runs`), so the rows do not quantify over object lists the game never builds. **FOUND 2026-11-02 (rows false over unpinned pools) + REPAIRED in part:** `obj_w` did not pin the surface pools; now it does (`ow_spool` / `ow_surf_obj` / `ow_coll`). The surface counter is now bounded through the walk (2026-11-02, `ObjLoop.terrain_keeps_ix`: the terrain step rows carry a surface budget, the clear's row yields the post-clear fact); the node counter's per-step bound is FOUND false over unpinned transforms and stays a frame-boundary check. Details below. **The level phase is real code** (2026-10-24: `play_mode_normal`'s slices around `area_update_objects`, walked, carries proved in `LevelKeep`; `update_camera` keeps mem_ok by the real camera.c; stated: its PhiW carry `cam_phi_row` (TRUE as stated since the cam_w rebuild, 2026-11-02: `cam_w` pins sMarioCamState / sLuigiCamState / gSecondCameraFocus and keeps the Camera apart from the surface pools; FALSE unpinned before), still labeled; the object-world footprint `Hcam_ow_fp` is a LEMMA since step (a) (2026-11-02): its globals' half is PROVED from the real update_camera's footprint (`CamRows.cam_foot_step` on `CamFootInst.update_camera_foot`, which now carries AudioInv on the scoped `ls_frame_ai`), its surface clause (`surf_keep`) is PROVED since 2026-11-03 (`CamRows.cam_surf_keep`, from R3 once `ObjWorld.surf_obj_ok` bounds every list node / surface to its pool's range; FOUND FALSE AS STATED 2026-11-02 over list nodes inside the Camera's bytes, REPAIRED), and the rest is the labeled residual `Hcam_ow_res` (Mario's object-pointer cells only), see the detail; `warp_w` at the slice's end is PROVED from the walked tail, 2026-10-26, `LevelWarp.tail_warp_w`; gCurrentArea's target is carried, `FfWorld.area_w`, 2026-10-25; the Camera it updates is a real one on the witness, and `update_camera` runs there, `StartSat.frame_runs`, 2026-10-26). Three segments are **real calls with proved carries**: Mario's render call (`seg_render_spec`, 2026-10-22; GOAL-1 carry `RenderFlank.render_mem_ok`, Φ carry `RenderKeep.render_keeps_phiw` 2026-10-23), platform displacement (`seg_platform_spec`, 2026-10-23: the real `apply_mario_platform_displacement`, platform_displacement.c linked as TU 45; GOAL-1, held-A and Φ carries `PlatformKeep.plat_mem_ok` / `plat_a_down` / `plat_keeps_phiw`), and **the controller poll** (`seg_input_spec`, 2026-10-23: the real `osContStartReadData` and `read_controller_inputs`, osContStartReadData.c linked as TU 46, walked down to the OS / SI floor (3.5); GOAL-1 carry, A-freedom and the controller cells proved, `PollFlank.srd_ok` / `poll_ok`; the Φ, `plat_still` and object-world carries proved 2026-10-26, `PollKeep.srd_keeps` / `rci_keeps`; the two middle calls `audio_game_loop_tick` / `select_gfx_pool` real and walked, `MidKeep.mid_keeps`, 2026-10-26: **no labeled premise**). Details: [row 0.7 in detail](#row-07-in-detail). |
| 0.4 | The starting states the theorem quantifies over (`mem_ok_lp`: Mario's block valid, his action untainted, `MWF_real`) | **GOAL 1: proved satisfiable by the real boot path** (2026-10-19, `BootMWF.boot_init_ok`, used by `NoAImpliesNoFlyTwelve.noA_never_flying_from_boot`). **GOAL 2: the witness is in WMotR by real code** (2026-10-21: `area.c` linked as the 23rd TU; `gCurrLevelNum = LEVEL_WMOTR` is stored by the generated `initiate_warp` + `warp_level`, `EntryWarp.v`; 2026-10-22: one real no-A frame runs from the witness, `frame_runs`, and its `init_mario_from_save_file` cells are tethered to the real body, `ifs_tether`; 2026-10-26: the witness's area has a real Camera, built by the generated `init_graph_node_camera` / `create_camera` in a level pool and stored in `gAreaData[1].camera` (`StartTerrain.cam_chain`; deviations in [row 3.6 in detail](#row-36-in-detail)), and a full frame runs through it: `area_update_objects`, then `update_camera` on that Camera, `frame_runs`; **2026-11-03: the witness is what THE REAL ENTRY leaves** (`StartTerrain.entry_g`: `sound_init`, `init_mario_from_save_file`, WMotR's level script command by command through the real `LevelScriptJumpTable` handlers, `init_level`, `warp_level`, `init_mario_after_warp`), so Mario's cells, his floor (find_floor's hit, 1669.0), `gCurrentArea`, the Camera and the objects are real code's; the remaining stand-ins S1-S8 are listed once in `StartTerrain`'s header and in [row 3.6 in detail](#row-36-in-detail)). Details: [row 0.4 in detail](#row-04-in-detail). |
| 0.5 | The step relation = what one real frame does | GOAL 1: **only `execute_mario_action`** in the twelve-TU capstone; **since 2026-10-26 also stated over GOAL 2's whole frame** (`NoAImpliesNoFlyFrame.noA_never_flying_frame_linked12`, skeleton: its open rows are GOAL 2's, see the detail). GOAL 2's `frame_step` composes the real `area_update_objects` call (which contains Mario's `execute_mario_action`; its stages are labeled rows, 0.7, since 2026-10-26), the level phase as real `play_mode_normal` slices (2026-10-24; `update_camera`'s PhiW carry a labeled row), and three real linked calls (the controller poll `osContStartReadData` + `read_controller_inputs`; Mario's render call; `apply_mario_platform_displacement`, the latter two and the poll since 2026-10-23). The specified flanks are not linked code. This is the largest scope gap. Details: [row 0.5 in detail](#row-05-in-detail). |

### Row 0.1 in detail

- Needs a reader check. Holding A counts as using it (ABC's "0.5x" press, `game_init.c:544`). The
  held bit is load-bearing: with A held and never pressed, `act_punching`/`act_move_punching` enter
  `ACT_JUMP_KICK` (not in the no-A whitelist) and the wing cap flutters (`mario_step.c:566`).
- **When the run starts at power-on** (long term), "held" follows from "never pressed": `buttonDown`
  is zero-initialized and the poll (`game_init.c:542-545`) sets `buttonPressed = raw & (raw ^
  buttonDown)`, `buttonDown = raw`, so A can only become down on a poll that reports it pressed. The
  premise should then be stated on the raw pad data, since title-screen demos (`run_demo_inputs`)
  inject A.
- **Stated on the raw data since 2026-10-23 (GOAL 2).** The capstone's premise is now
  `PollFlank.pif_a_real` on the frame's input memory: the PIF reply bytes, which the OS floor's
  `__osSiRawStartDma` clause (3.5) lets the SI DMA set to any data. The poll is walked
  (`osRecvMesg`, `osContGetReadData`, `run_demo_inputs` with `gCurrDemoInput = NULL`,
  `adjust_analog_stick`, the player-3 copy), so "neither pressed nor held" is proved from it, and
  in the run `buttonDown` is always the last poll's button word. The demo case is excluded by the
  frame world (`FfWorld.ctl_w`: `gCurrDemoInput = NULL` in WMotR).
- **FOUND 2026-10-23 (a premise that would have been false):** `__osPackReadData` writes the
  read-request template into the PIF image with the button word `0xFFFF` (A set), and on a port
  with no controller the reply leaves it there with the error bits set. A premise "no port's
  button word has A" would be false on real hardware with fewer than four controllers plugged in
  (the capstone vacuous). `pif_a_real` ignores ports whose error bits are set, exactly as
  `osContGetReadData` does (it copies button / stick only when `(rxLen & 0xC0) == 0`).

### Row 0.3 in detail

- **Height form stated** (`WMotRRequiresA/HeightFrame.v`, `wmotr_noA_height_bound_linked12`): a no-A
  run keeps `pos[1] ≤ 2796` (`PHI_YMAX` = K + A, `HeightInvariant.v`; K = H* = 2424, the wing-cap
  box top 2320 + 2·52 (the box is scaled ×2), with the level facts it needs proved from generated
  level data in `WMotRLevel.v` (0.8); A = 372 from `tools/goal2_budget.py` plus the binary32
  rounding allowance). A wrong K or A would make the crux row false, not the capstone unsound.
- **The collision step is machine-checked** (`WMotRRequiresA/CoinLink.v`, `overlap_no_contact` /
  `mario_coin2_no_contact`, over the generated body of `detect_object_hitbox_overlap`): if a's
  hitbox top + 1 ≤ b's bottom (binary32, fields finite and |·| ≤ 8192), every execution returns with
  memory unchanged, so nothing is written to `collidedObjs`/`collidedObjInteractTypes`. For Mario
  (a; always the first argument, from `check_player_object_collision`) and coin #2 (b) this holds
  whenever y ≤ 2796, Mario's hitbox height ≤ 160 and both down offsets are 0. That theorem's own
  assumptions: the body's one call, `sqrtf` (resolved through the global symbol), leaves memory
  unchanged (a 4.1 row); the linked composite env contains `object_collision.c`'s composites
  verbatim (dischargeable by `SymbolicLinking.linkorder_comp_env_extends`); and Clight expression
  evaluation is deterministic (`Generic/ClightDeterm.v`, proved). Still missing: composing it into
  the capstone (Mario's hitbox fields at collision time, coin #2's field values, and "no contact
  registered ⇒ coin not collected ⇒ no star"). That step also silently assumes **coin #2 never
  moves**. The one way Mario code moves another object is dropping or throwing a held object
  (`mario_drop_held_object` sets `heldObj->oPosY = m->pos[1]`, `interaction.c:307`; this is how
  cloning works).
- **Machine-checked so far** (`HeldObjCensus.v`, over all 16 generated code TUs): every `heldObj`
  store is NULL except `mario_grab_used_object`'s, which stores `usedObj`; `&heldObj` is never
  taken; its callers are `act_dive`, `act_dive_slide`, `check_water_grab`, `act_picking_up`,
  `act_picking_up_bowser`; only `interact_grabbable` sets `INPUT_INTERACT_OBJ_GRABBABLE`.
- **Still open:** each caller runs only after a grab check or on a collided `INTERACT_GRABBABLE`
  object (true by reading; the only value occurrences of `ACT_PICKING_UP`/`ACT_PICKING_UP_BOWSER` in
  21 generated TUs, code and data, are in `mario_check_object_grab`:
  `HeldObjCensus.pickup_entry_sites`; still open is a copy of `m->action`/`prevAction` or an
  arithmetic construction carrying those values), and WMotR spawns no grabbable object (**now
  machine-checked over generated code**, `BehaviorScripts.no_grabbable_in_wmotr`, TRUST 0.10;
  since 2026-10-24 modulo the debug spawner's guard, which spawns two grabbable objects).
  Informal argument: `init_mario` clears `heldObj`/`usedObj`, grabs need
  `INPUT_INTERACT_OBJ_GRABBABLE` (set only by `interact_grabbable`), and WMotR spawns no grabbable
  object. So `heldObj` stays NULL and the coin stays at 3140. Also assumed: no object code writes a
  red coin's position, Mario's hitbox is at most 160, the Mario object's y equals `pos[1]` at
  collision time, and the star counter starts at 8 − (red coins loaded).

### Row 0.6 in detail

- **Defined** (`HeightInvariant.height_invariant`, design `docs/goal2-phi.md`): `R_noA` action
  whitelist ∧ `budget_ok` over the cells action, actionState, actionTimer, pos[1], vel[1],
  floorHeight and `marioObj->gfx.pos[1]` (what OOB recovery restores). The cells are ranges (−75 ≤
  vel ≤ 43, y and gfx.y ≥ −11000, floorHeight finite and ≥ −11000 (and, 2026-10-18, `AttachOK`
  accepts a landing at −11000, which a floorless air quarter makes when the frame's find_floor calls
  both missed): until 2026-10-18 the y bound was −8192, the death plane, which the code does not
  give: when both `find_floor` calls in `update_mario_geometry_inputs` miss, floorHeight is −11000
  and an air step compares against it; −11000 is what every non-landing air-step path proves, per a
  symbolic probe of the real `perform_air_step`; the upper bound was 128 until 2026-09-28, which let
  Φ admit a grounded Mario rising at up to 128 whose walk-off no Move covers: `Hframe_is_move_chain`
  was false over Φ. 43 is the freefall launch cap; real no-A launches are ≤ 37.5), the budget y +
  credit ≤ 2424 + 372 at pos and at gfx.pos, and the slide-kick, ground-pound and ledge clauses.
  Offsets and action constants are pinned against the generated AST, and `Hphi_y` is proved.
- **The old crux row `Hseg_action_phi` is now a lemma** (`HeightFrame.seg_action_phi`). The budget
  arithmetic of every move a frame can make (binary32 air step, cut step, slide-kick signed-energy
  step, ground-pound windup, E3 switches, attach, floor refresh, OOB) is proved
  (`HeightMoveCatalog.chain_keeps_budget`).
- **The run carries `PhiW` = Φ ∧ `wmotr_world`** (`WMotRWorld.v`, 2026-09-29): (until 2026-11-08 Mario's wall/ceil were
  NULL or surfaces of WMotR's own types; now unconstrained, see 0.4's entry census) and his floor is never NULL and of those types (computed
  from the generated collision data: DEFAULT, HANGABLE, DEATH_PLANE, NOT_SLIPPERY,
  HARD_NOT_SLIPPERY), nothing held or ridden, quicksandDepth 0. Without it both frame rows were
  false over phantom worlds (a BURNING floor → ACT_LAVA_BOOST; a quicksand depth lowers gfx).
- **Object collisions are in W** (`wmotr_objects`, 2026-09-29, from the whole-frame symbolic walk,
  `docs/goal2-value-walk-plan.md` §6). Mario's object carries no stomp bit (`oInteractStatus &
  0x13`). Otherwise SHOCKED / SHOCKWAVE_BOUNCE, outside R_noA, are reachable. At most 4 objects are
  collided. Each has an interact type in WMotR's set {0, COIN, CAP, POLE, BREAKABLE, CANNON_BASE,
  TEXT}. That set is a **hand census** (`goal2-wmotr-behavior-census.md`), not computed from
  generated data. A collided pole's oPosY / hitboxDownOffset / hitboxHeight and a collided cannon
  base's oPosY are a `WMotRLevel` list entry; those are the only object fields Φ depends on.
- **Excluding the red-coin star is load-bearing:** collecting it reaches STAR_DANCE_* /
  FALL_AFTER_STAR_GRAB, outside R_noA, and its absence rests on 0.3 (the star needs coin #2, which
  needs y ≥ 2980). ACT_SQUISHED is not excluded by W. It needs a DYNAMIC floor or ceiling with ceil
  − floor ≤ 150 at the new position, which is a geometry fact for the find_floor / find_ceil value
  contracts (open, part of `Hframe_stays_noA`).
- **Open rows, split per call (2026-10-20):** the three whole-frame rows `Hframe_keeps_world`,
  `Hframe_stays_noA` and `Hframe_is_move_chain` are now **lemmas** (`HeightFrame`), derived by
  `FrameSplit.frame_stage` from the real `execute_mario_action` body (staged since 2026-10-21,
  below; the unstaged `frame_split` was removed 2026-10-23 with the old `Hseg_any`). `FrameCalls.cl` reads the
  generated body as 17 `f(gMarioState)` calls, 5 other calls (`spawn_wind_particles` ×2,
  `play_sound` ×2, `play_infinite_stairs_music`) and 2 store blocks; the two stores into Mario's
  object (`gfx.node.flags`, `oInteractStatus = 0`) are **proved** to keep W, the cells and GOAL 1's
  `mem_ok`; GOAL 1's per-call `mem_ok` (`frame_call_ok_linked12`) is proved. What is assumed is one
  row shape per call, `Hseg_call_na` (since 2026-10-23 split into named rows (12; 10 since 2026-10-24) of
  `Hseg_na_open`, 0.8(q)) / `Hseg_any` (`FrameSplit.seg_ok`; since 2026-10-23
  `Hseg_any` covers only the calls live in WMotR, i.e. `play_infinite_stairs_music()`: the two
  wind blocks' four calls are proved dead, §7); the airborne dispatcher's
  row is itself proved (`AirSplit.air_seg`) from its two prologue calls and one row per no-A case
  (11 of its 43 cases; the rest are dead under `R_noA`), each handler called with the action cell
  equal to its label (`Hair_pro` / `Hair_case`): the call keeps the frame world (`fworld`: action in
  `R_noA`, W, `anim_apart`, `mobj_apart`, A not held) and moves the cells by a MoveChain. Inside
  these rows: keeping W (tethered: 11,379 write-watch frames); keeping the action in `R_noA`; the
  call's effect on the cells is a chain of those moves, each in range (the T3 value walk; false if
  an unmodelled mechanism fires, listed in the rows' comment). The per-call shape is stronger than
  the old whole-frame rows (each call's own effect must be a chain), which is what lets the value
  walk discharge them one call at a time.
- **Added to W (2026-10-20): `mobj_apart`**: no wall/ceiling/floor surface lives in Mario's object
  block, a collided object is Mario's own or a whole `struct Object` (608 bytes) away, and the
  object does not wrap the address space. In the game surfaces are in `sSurfacePool` and objects are
  distinct `gObjectPool` slots. Without it the frame's own `oInteractStatus` store could overwrite a
  collided pole's fields.
- **The freefall case is proved (2026-10-20, `FfRow.ff_row`), both halves:** the real
  `act_freefall`, with `perform_air_step`, `set_mario_animation` (down to the DMA floor 3.5) and
  `update_air_without_turn` (FPU floor) run by the `FfRun` walk on the link, moves Phi's cells by a
  MoveChain **and keeps the frame world** (every `fworld` conjunct is rebuilt after the call from
  the walk's outcome check `FfKeepCheck.fk_ok`, whose meaning is `FfKeep`, and from
  `ClightClosed.funcall_closed`). Its start state is built from a new carried conjunct of PhiW /
  `fworld`, **`FfWorld.ffw`**: memory is closed by a flat injection that maps every global and
  Mario's state block (`ClosedMem.closed_by`: a pointer stored in a mapped block points at a mapped
  block; every Clight call keeps it, `ClightClosed.funcall_closed`, proved from CompCert's semantics
  and its external-call axioms); `m->marioObj`, `m->animList = &gMarioAnimsBuf` and the list's
  `bufTarget` are pointers, and the object and the buffer are blocks of their own (a `gObjectPool`
  slot; a `main_pool` allocation — the pool's addresses are integers in the C, so the model takes
  each allocation as its own block); the collision partition is well-formed lists of WMotR-typed
  surfaces off those regions (`FloorExec.Wff`), and every floor-list height is a WMotR floor
  (`floor_data`, 0.8(d)); `m->floor` / `m->area` / `m->controller` are world objects off the
  regions, and `m->wall` / `m->ceil`, when pointers, are off them too; every collided object of
  Mario's is in his object's block (in the game all objects are `gObjectPool` slots); `m->input` has
  neither A bit (0x82); and floorHeight is a floor refresh of y (`FloorRefreshOK`: −11000, or a
  WMotR floor ≤ y + 241). ffw is **proved** to survive the frame's two object stores
  (`FrameSplit.obj_store_ffw`); every other call carries it in its row, and the flanks carry it in
  their spec (0.7). The freefall row is gone (`Hff_keeps` removed from HeightFrame); the other ten
  cases keep their AirSplit row (`air_case_rest`).
- **The air-hit-wall case is proved too (2026-10-20, `AhwRow.ahw_row`):** the real
  `act_air_hit_wall`, walked by `AhwRun` (A unpressed prunes the wall kick), either stays (timer +1)
  or switches to BACKWARD_AIR_KB / SOFT_BONK with state and timer 0, keeping Phi's cells otherwise;
  nine cases remain (`AhwRow.air_case_rest2`).
- **The soft-bonk and both air-knockback cases are proved (2026-10-20, `KbRow.kb_row`, generic in
  the case; walks `KbRun.sbcheck12` / `bkbcheck12` / `fkbcheck12`); six cases remain
  (`KbRow.air_case_rest3`).** **Ground pound is proved (2026-10-20, `GpRun.gp_kfinal` through
  `kb_row`, which is now generic in the walk theorem `KbRun.kfinal`); five cases remain
  (`KbRow.air_case_rest4`: dive, both rollouts, butt-slide air, slide kick).** **Dive is proved
  (2026-10-20, `KbDv.dvcheck12` through `kb_kfinal`; dive is now an `air_entry`); four cases remain
  (`KbRow.air_case_rest5`: both rollouts, butt-slide air, slide kick).** **Both rollouts are proved
  (2026-10-20, `RlRun.rl_kfinal` through `kb_row`; walks `RlF.rlfcheck12` / `RlB.rlbcheck12`, both
  states: the launch `S_roll_launch` then the air step from the launched cells, and past the launch
  the air step from the entry cells); two cases remain (`KbRow.air_case_rest6`: butt-slide air,
  slide kick).** **Butt-slide air at state 0 is proved (2026-10-21, `BsRun.bs_kfinal` through
  `kb_row`; walk `BsW.bscheck12`): the handler's `actionTimer++` is `S_tick` to the ticked cells,
  then the FREEFALL gate, or the air-step summary from the ticked cells (`FfClass.ent_bs`) and a
  landing into BUTT_SLIDE, the bounce (`S_attach` to state 1 with vel[1] := −vel[1] / 2, in
  [−21.5, 37.5]), or a wall into BACKWARD_AIR_KB. Butt-slide air past its bounce (state ≠ 0)
  was a new open row (`KbRow.bsa1_row`; proved the same day by the staged split, below).** **Slide kick at state 0 is proved (2026-10-21,
  `SkRun.sk_kfinal` through `kb_row`; walk `SkW.skcheck12`), the last no-A case: no case is left
  over (`KbRow.air_case_fns_in`, computed from the generated switch), so `air_case_rest7` is
  discharged (`KbRow.air_case_rows_ff8`).** The handler ticks actionTimer, then the timer gate
  into FREEFALL (`Sw_freefall`, timer ≥ 30, from the gate's `++actionTimer > 30` fact), or the
  air-step summary from the ticked cells, read as one move from the pre-tick cells
  (`AirMove.sk_pre`, `AirSum.pre_ok`) at slide kick's gravity vel − 2: a landing into
  SLIDE_KICK_SLIDE, the bounce off vel[1] < 0 (`S_attach` to state 1, timer 0, vel[1] := −vel[1]
  / 2 ≥ 0), or a wall into BACKWARD_AIR_KB. Slide kick past its bounce (state ≠ 0) was an open
  row (`KbRow.sk1_row`; proved the same day, below). **The dispatch's floor refresh is threaded through the frame (2026-10-21,
  `FrameSplit.frame_stage`, now the spine's split; `HeightFrame.frame_FS`).** The body is read
  off the generated AST in order (`ema_split`, `body_shape`, computed): flags, reset_bodystate,
  `update_mario_inputs`, `mario_handle_special_floors`, `mario_process_interactions`, the
  floor-NULL return, the real `while (inLoop) switch (action & 0x1C0)` loop, the post-action
  calls. The loop invariant (`J`: inLoop = 0, or the floor is fresh when the action is airborne,
  `FfWorld.fresh_at`) is proved over the loop's big-step semantics. **Butt-slide air at state ≠ 0
  is proved** (`bsa1_row` and `Hbsa1` removed): its walk enters with the dispatch's fresh floor
  (`KbRow.kb_row` takes `FfWorld.fresh`, not ffw's `fro_st` clause), whatever the state.
  **New and strengthened claims in the open rows** (`seg_call_rows_naF`: `pre_of` / `post_of`):
  (a) `update_mario_inputs` leaves the floor fresh (`fresh`: floorHeight is −11000 or a WMotR
  floor ≤ y + 241; it refreshes floorHeight with find_floor at Mario's position, which returns a
  floor at most 78 above y); (b) `mario_handle_special_floors` and `mario_process_interactions`
  keep it (they do not lower y without a refresh: `bounce_off_object` only raises y,
  `push_mario_out_of_object` moves x/z only); (c) each of the six non-airborne dispatchers,
  entered with `fresh_at`, returns 0 or leaves `fresh_at` (a handler that returns TRUE into an
  airborne action has refreshed or not moved the floor); (d) the airborne prologue rows
  (`AirSplit.air_pro_rows`) take and keep `fresh_at`; (e) `sk1_row` is restated: slide kick at
  state ≠ 0, entered fresh, keeps the frame world and returns FALSE or leaves the floor fresh.
  **Proved, not assumed:** the airborne dispatcher's staged row (`AirSplit.air_seg`: a case is
  entered fresh because its label is airborne, `air_case_air`), and every proved case's
  return: FALSE, or y and floorHeight untouched (`RetOk.ret_ok`, checked on each walk's
  outcomes; `RetOk.ret_sound`), so the loop's TRUE path keeps the floor fresh. **Caveat
  (pre-existing, phantom ∀; REPAIRED 2026-10-22, audit (l)):** after `let_go_of_ledge`
  (→ SOFT_BONK, y lowered by ≤ 100 with floorHeight not refreshed) the open rows claimed the
  floor is fresh, which `fresh`'s `fh ≤ y + 241` alone does not give. `FfWorld.fresh` now also
  carries the slack `action = SOFT_BONK ∨ fh = −11000 ∨ fh ≤ y + 140`, which the let-go keeps
  (y drops by ≤ 101 into SOFT_BONK, `LedgeRun.letgo_fresh`), and SOFT_BONK's handler returns
  FALSE (`SbRet0.kb_kret0`, a rewalk of the real act_soft_bonk), so the loop never re-dispatches
  on the stale floor. ffw's own `fro_st` clause is unchanged (still read by the freefall and
  air-hit-wall rows). No assumption added.
  **Automatic-dispatcher audit (2026-10-21; pole paths now execute).** Three statement bugs
  were found in what `Hseg_call_na` claimed for `mario_execute_automatic_action`, and all three
  are repaired. No assumption was added; the row is still open.
  (f) The catalog's pole attach `h ≤ top` was **false**. The real handstand anims
  (`TOP_OF_POLE_TRANSITION` / `TOP_OF_POLE`) raise Mario 174 units: 74 above the top, and up to
  153 with a floor snap. These are tool-read values (`tools/goal2_pole_anim.py`). `AttachOK` now
  allows `h ≤ top + POLE_UP` with `HeightBudgetArith.POLE_UP = 160`, and
  `WMotRLevel.wmotr_poles_proved` re-proves that every WMotR pole is low by that margin or out of
  reach. The anim data is DMA-loaded ROM data that no linked AST reaches; since 2026-10-22 the
  174 is **proved from the generated anim data** (`PoleAnim.handstand_y_bound`,
  `pole_up_covers_handstand`; row 0.8(f)) for frames ≥ −1. Since 2026-10-23 the top-of-pole walks read the real data through the DMA
  buffer (audit (p)) and their y offset, in [−1, 174], is checked against `POLE_UP`.
  (g) **Phantom ∀ on `m->usedObj`:** the frame world did not constrain it. A `HOLDING_POLE`
  memory whose usedObj is a high pole (base ≥ 3154) met every premise, and `set_pole_position`
  would put y above YMAX. The same gap held for `IN_CANNON`'s seat (usedObj y + 350). The frame
  world (`FrameSplit.fworld`, `HeightFrame.PhiW`) now carries `WMotRWorld.used_ok`:
  - in a pole action, usedObj is a low WMotR pole apart from Mario's object, and vel[1] ≤ 0;
  - in `IN_CANNON`, usedObj is a cannon base;
  - elsewhere it says nothing.
  It is proved at the boot witness and across the frame's own stores. Each proved walk keeps it
  because its outcomes avoid those actions (`FfKeepCheck` rejects `used_acts`).
  (h) `fresh_at` gave no floor fact at the entry of an automatic action, yet handlers return
  TRUE into airborne actions (pole Z / low health → SOFT_BONK, `let_go_of_ledge`). The row was
  therefore false over stale floors. `fresh_at` now covers the automatic group (0x140) as well;
  the dispatch is entered with update_mario_inputs' refreshed floor.
  **The automatic dispatcher is split per case (2026-10-21, `AutoSplit`; 27 → 28 hypotheses,
  each strictly narrower).** `Hseg_call_na` is now `AutoSplit.seg_call_rows_naFA`: both
  dispatchers are excluded. The automatic dispatcher's staged row is **proved**
  (`AutoSplit.aut_seg`, `seg_call_rows_naF_of_auto`) from the generated body, using these
  pieces:
  - its prologue `check_common_automatic_cancels`, which joins `Hair_pro` (same claim shape:
    keeps `fresh_at`);
  - the store `m->quicksandDepth = 0.0f`, **proved** to keep GOAL 1's `mem_ok` (MWF's window,
    the new GOAL 1 export `NoAImpliesNoFlyTwelve.mwf_window_linked12`), every `fworld`
    conjunct (incl. `ffw`, re-proved through `FfWorld`'s KEEP2 lemmas), Phi's cells and
    `fresh_at`;
  - GOAL 1's `mem_ok` across each handler (new export `auto_leaves_linked12`);
  - one row per live case, the new `HeightFrame.Hauto_case : AutoSplit.aut_case_rows`. Each
    handler is entered with the action cell equal to its label and the floor fresh (every
    label is in group 0x140, `aut_case_auto`), and returns FALSE or leaves the floor fresh.
  The live cases are computed from the generated switch (`aut_case_list_eq`). There are 12:
  the six pole actions, LEDGE_GRAB, LEDGE_CLIMB_SLOW_1/2, LEDGE_CLIMB_DOWN, LEDGE_CLIMB_FAST
  and IN_CANNON. The other 5 of the 17 cases are dead under `R_noA`. The new hypothesis
  replaces what was a part of `Hseg_call_na`, and the prologue and store are now theorems.
  (i) **Phantom ∀ in `used_ok` (found while proving the store):** `used_apart` allowed
  `usedObj` inside Mario's own state block. With usedObj = bm + 28, the pole's `oPosY` sat
  at bm + 192, which is `quicksandDepth`. Such a memory met `used_ok` before the
  dispatcher's store and failed it after. `WMotRWorld.used_apart` now also says
  `ub <> bm`; in the game usedObj is a `gObjectPool` slot. At the boot witness `used_ok`
  is vacuous (not a pole or cannon action), and the frame's stores keep the new conjunct.
  (j) **POLE_UP cannot be loosened to a generated-code bound.** In the generated
  `find_mario_anim_flags_and_translation`, `translation[1]` is an s16 animation value / 4,
  so the code alone bounds it by 8191. That gives POLE_UP ≈ −100 + 8191 + 78 = 8169. The
  low pole (top −1919) then fails `pole_check`, because −1919 + 8169 > K = 2424. The
  loosest POLE_UP that passes is 4343. Any bound under it needs the handstand animations'
  values (ROM data DMA'd into `gMarioAnimsBuf`; not in `generated/`) and a model of the DMA
  buffer's contents. So the top-of-pole cases still need that data tied to the buffer
  (2026-10-22: the data is clightgen'd and the 174 proved from it; 0.8(f) lists the four missing
  pieces). POLE_UP = 160 stays.
  (k) **GRAB_POLE_SLOW / GRAB_POLE_FAST proved (2026-10-22, `PoleRow.pole_row`,
  `aut_case_rows_pole`).** `Hauto_case` is now a lemma. What stays assumed is
  `HeightFrame.Hauto_rest : PoleRow.aut_case_rest_pole`: the 10 other live cases
  (HOLDING_POLE, CLIMBING_POLE, TOP_OF_POLE_TRANSITION and TOP_OF_POLE need the anim data;
  plus the 5 ledge cases and IN_CANNON). The walks (`PoleSlow`/`PoleFast`) run the real
  handlers with usedObj as its own region (`PoleRun.RU`) in Mario's object block.
  - **`HeightFrame.Hceil` (added here, 27 → 28) was FALSE as stated, and is now PROVED and
    removed (2026-10-22, 28 → 27).** It said: the real `find_ceil` returns 20000 or a height
    not below (int)y − 78, for every call. Counterexample: let `pceil` dangle into the
    `height` block itself, with posX ≥ 8192 and posY = 1000. Then `find_ceil` returns 0.0f.
    The restated fact needs only what the call site has: a valid `pceil` block and a valid
    `gNumCalls`. `CeilHeight.fc_height` proves it against the generated Clight. Its
    consumer `PoleXc.c_fc_height` gets both validities from the walker's state, so
    `c_fc2_sound` has no premise left. `Hauto_rest` is strictly narrower than `Hauto_case`.
  - `WMotRWorld.used_ok` now also carries `pole_pos_ok`: usedObj's slot fits, and
    `oMarioPolePos` is a finite float ≥ −1000. The grabs' outcomes keep it: the walk checks
    `PoleClass.pole_keep` on every POLE_ACTS3 outcome.
  - The walk merges `set_pole_position`'s branches, so facts the merge loses are re-derived
    per outcome by `PoleClass.pole_ok` (sound by `PoleSound.pole_sound`).
  (l) **LEDGE_GRAB / LEDGE_CLIMB_DOWN proved (2026-10-22, `LedgeRow.ledge_row`,
  `aut_case_rest_pole_ledge`).** `Hauto_rest` is now `LedgeRow.aut_case_rest_ledge`: 8 cases
  (the four pole cases needing anim data, LEDGE_CLIMB_SLOW_1 / 2, LEDGE_CLIMB_FAST, IN_CANNON).
  Still 28 hypotheses; the new one is strictly narrower. The walks (`LedgeGrab` / `LedgeDown`)
  run the real handlers with find_floor's height fact (PoleXc.c_ff2), and every outcome passes
  `LedgeClass.ledge_ok` (a RangedMove: the switch into a climb or SOFT_BONK keeps y, the snap
  `stop_and_set_height_to_floor` puts y on floorHeight, the let-go lowers y by ≤ 101 or onto a
  floor behind Mario) and either `RetOk.ret_ok` or `LedgeClass.letgo_ok`.
  - **Statement strengthened (true in the game, no new trust):** `FfWorld.fresh` gains the slack
    clause above. The open rows that produce or keep `fresh` (update_mario_inputs' refresh and
    the other open dispatcher rows) now claim a little more: right after find_floor
    (floorHeight ≤ y + 78, `ff_height_bound`) the slack holds; SOFT_BONK returns FALSE without
    A (`SbRet0`). KbRow takes the SB case's FALSE return as a section premise (`Hsb`), discharged
    by the rewalk `SbRet0Walk.sb0check12`.
  - **FINDING (vacuity, not repaired here): `gPlayerCameraState` is a size-0 block in the
    link.** It is defined in camera.c, which is not linked; mario_misc.v's declaration has
    `gvar_init nil`. `init_mario_from_save_file` sets `m->statusForCamera =
    &gPlayerCameraState[0]`, and `update_mario_info_for_cam` stores through it on every
    `execute_mario_action` frame. A store into a size-0 block has no CompCert execution, so no
    frame from real boot memory executes, and the frame rows' `eval_funcall` premise can never
    hold: the GOAL-2 capstone (and any capstone resting on executed frames) is vacuous for the
    real game until camera.c's storage is linked (or a definer TU added). The same store blocks
    LEDGE_CLIMB_SLOW_1 / 2 and LEDGE_CLIMB_FAST (`update_ledge_climb_camera`) and IN_CANNON's
    state 0. The frame world carries no `statusForCamera` fact, so those cases cannot be walked
    yet. IN_CANNON is reachable in WMotR without A (2 cannons; `interact_cannon_base`).
  - `PoleXc.v` uses `hit16_transfer` (Hit_at is now ffl_hit16, after the terrain merge).
  (m) **HOLDING_POLE proved (2026-10-22, `PoleHold.holdcheck12`, `PoleRow.aut_case_rows_pole`).**
  `Hauto_rest` is now 7 cases: CLIMBING_POLE (reads `m->area->camera->yaw`; the camera is not
  a frame-world fact), TOP_OF_POLE_TRANSITION / TOP_OF_POLE (the anim frame, 0.8(f)(3)),
  LEDGE_CLIMB_SLOW_1 / 2, LEDGE_CLIMB_FAST, IN_CANNON. Still 27 hypotheses.
  - The walk runs the real `act_holding_pole` (62924 outcomes). Its slide
    `oMarioPolePos -= yawVel / 0x100` is bounded by the clamp `yawVel <= 0x1000` the handler
    itself makes, and the path's `!(polePos > top)` test: `PoleFloat.dec_val`,
    `PoleSound.ppt_sound`. So polePos may dip to −1016 inside the frame, and set_pole_position's
    y is in [−3757, −2018]. The classifier's early-switch branch (`PoleClass.ground0`: a POLE_ACTS3
    action, y and gfx unchanged, usedObj kept) covers the CLIMBING / TOP_TRANS / SOFT_BONK
    switches that return before the move.
  - **Audio premise widened (labeled, user-approved 2026-10-22):** `ExtInert.audio_inert` now also
    covers `set_sound_moving_speed` (audio/external.c, not linked). Same shape as `play_sound`:
    it changes no modeled block and returns no pointer. The handler calls it every frame.
    (**Gone 2026-10-23:** audio/external.c is linked; `SndXc.c_ssms_sound` proves the call's
    clobber contract from the real body. See 4.1, "the audio link".)
  - The frame world's controller fact (`Fworld m->controller`, `FfWorld`) is now also seeded
    into the pole walks (the handler reads `stickMag` / `stickY`).
  (n) **LEDGE_CLIMB_SLOW_1 / _2 and LEDGE_CLIMB_FAST proved (2026-10-22,
  `LedgeRow.aut_case_rest_ledge_climb`).** `Hauto_rest` is now `LedgeRow.aut_case_rest_climb`:
  4 cases (CLIMBING_POLE, TOP_OF_POLE_TRANSITION, TOP_OF_POLE, IN_CANNON). Still 28 hypotheses;
  the new one is strictly narrower. No new trust.
  - **statusForCamera is a frame-world fact.** camera.c is linked, so `gPlayerCameraState` is
    real storage. `FfWorld.ffw` gains `m->statusForCamera = &gPlayerCameraState[0]` (offset 148)
    and the block in the region list (`FfRun.RPC`, 36 bytes, in `R0F` / `gtabF` / `ff_rl`;
    the pole regions renumber to RU = 19, RBT = 20). StartSat proves it on the witness (the
    witness already runs init_mario_from_save_file's store, `L_pcs`). Every row keeps it:
    `fk_same` now includes the cell, and `KbRun.kvK` makes it a known cell, so every
    kvK-based walk (soft bonk, knockbacks, ledge, rollouts, butt-slide air, ground pound,
    slide kick, poles) re-checked with it.
  - The walks (`LedgeClimbSlow1` / `Slow2` / `Fast`; act_ledge_climb_slow is walked once per
    label) run the real handlers. `update_ledge_climb_camera` stores into RPC.
    `stop_and_set_height_to_floor`, `climb_up_ledge` (x / z only, then `gfx.pos := pos`) and
    `let_go_of_ledge` set the height. animFrame (17 / 8) is only read, so the anim data is not
    needed. `LedgeClass.ledge_ok` gains the climb_up_ledge shape (y kept, gfx.y := y, vel
    kept: an attach at y from a ground action). `LEDGE_OUT` gains SLOW_2, IDLE and
    check_common_action_exits' no-A exits: WALKING, BEGIN_SLIDING (set_mario_action remaps it
    to BUTT_SLIDE / STOMACH_SLIDE) and FREEFALL. All of these are on `R_noA_list`.
    `LedgeRun.ledge_final` takes any `LEDGE_IN` entry action.
  - Remaining: CLIMBING_POLE's walk returns None even with the area->camera world fact
    supplied by hand (probe, not committed). That fact would also need an ffw conjunct and a
    StartSat witness store (the witness area is a fresh, all-Vundef block). IN_CANNON's
    state 0 stores `usedObj->oInteractStatus`. `used_ok`'s cannon clause gives neither
    usedObj = Mario's object block (the pole clause's `pole_pos_ok`) nor apartness from the
    collided objects, so the usedObj region cannot be placed among the walk's regions without
    strengthening that claim. The interaction rows still assumed carry it.
  (o) **IN_CANNON and CLIMBING_POLE proved (2026-10-22, `CannonRow.aut_case_rest_climb_top`).**
  `Hauto_rest` is now `CannonRow.aut_case_rest_top`: 2 cases (TOP_OF_POLE_TRANSITION,
  TOP_OF_POLE). Still 28 hypotheses; the new one is strictly narrower. No new trust row.
  - **Statement strengthened (true in the game, no new trust):** `WMotRWorld.used_ok`'s
    cannon clause gains `cannon_pos_ok`: usedObj's slot fits, lies in Mario's object's block
    (both are `gObjectPool` slots), and each object Mario collided with is the cannon itself
    or a whole Object away from it. Without it the walk's store `usedObj->oInteractStatus`
    could not be placed among the walk's regions (a phantom usedObj overlapping a collided
    object's fields met the old clause). Every PROVED place that establishes `used_ok` still
    does: `used_ok_keep` gains a premise (Mario's object's four `collidedObjs` cells kept),
    discharged by `FrameSplit.obj_store_used` (the store is at `oInteractStatus`, away from
    them) and `AutoSplit.qsd_used` (the store is in Mario's block); all other rows use
    `used_ok_other` or the pole clause. The assumed rows that enter ACT_IN_CANNON
    (`interact_cannon_base`, inside the open `Hseg_call_na` / `Hseg_any`) now claim this
    too; it holds in the game.
  - IN_CANNON: `CannonRun.cannon_walk` runs the real act_in_cannon once per seat of
    `wmotr_cannon_list` (since 2026-10-24 each home seat + 5k, k = 0..69: the base rises while
    Mario is inside; `CannonWalk.cannoncheck837` / `cannoncheck2730` via `cannon_walk_all`;
    usedObj is region RU with its oPosY a known cell, so the seat folds to a constant). 31 outcomes; the shot needs A and is pruned.
    Each passes `CannonClass.cannon_ok` (still IN_CANNON; y kept, or the seat
    oPosY + 350 = the cannon's base height, an `AttachOK` cannon attach; gfx.y = y; the
    usedObj / cannon cells kept), `PoleKeep.fkp_ok` and `RetOk.ret_ok`.
  - CLIMBING_POLE: `PoleClimb.climbcheck12` runs the real act_climbing_pole with the pole kit
    (11988 outcomes). FINDING: no camera frame fact is needed — the earlier "None" was a
    probe artifact (a prefix with no return); `m->area->camera->yaw` is an opaque load (it
    only turns Mario). `PoleRun.xcP` gains `set_mario_anim_with_accel` (`SmaXc.c_smawa`)
    and `is_anim_past_frame` (`PoleXc.past_frame_value_contract`). `PoleClass.ppt` gains the
    climb `polePos + stickY / 8.0f`, with the path fact `!(stickY < 8.0f)` and the path's
    find_ceil fact at that height + 80: its s16 cast (`ceil_ok`) makes the height finite, so
    a NaN stick is ruled out (`PoleFloat.climb_val`, `PoleSound.climb_sound`).
  (p) **TOP_OF_POLE_TRANSITION and TOP_OF_POLE proved; all twelve automatic cases proved
  (2026-10-23, `PoleCasesT.aut_case_rows_T`).** `Hauto_rest` is removed and its place is taken
  by `HeightFrame.Hdma_anim : OsDmaFloor.pi_dma_anim_spec` (row 0.8(f), APPROVED), so the count
  is unchanged by this row (26 before the audio link, 24 after it). Since the audio link the
  `PoleRunT` walks run play_sound / set_sound_moving_speed as `SndXc` clobbers (regions RSR /
  RSRC / RSMS), with no audio premise. All six pole actions are re-walked (`PoleRunT`) with Mario's real animation data:
  `set_mario_animation` / `_with_accel` walked inline (`load_patchable_table` reads the DMA
  table, `dma_read` copies `gMarioAnims` cells into the buffer by `DmaXc.c_dma`, from
  0.8(f)), and the top-of-pole `set_pole_position(m, return_mario_anim_y_translation(m))`
  walks `return_mario_anim_y_translation` once per animation frame (`RytXc.c_ryt`, y offset in
  [−1, 174]). One walk per start variant (`PoleStartT.avars`): TOP_OF_POLE from handstand
  animation 9 loaded or not; TOP_OF_POLE_TRANSITION from 11 or 12 loaded, or neither;
  HOLDING / CLIMBING from `anim_st`; the grabs from nothing (`PoleSlowT` … `PoleTopT2`). Each
  outcome passes `PoleRun.pk_ok`, leaves the table alone (`no_reg RTAB`) and `AnimEnd`'s
  check (in a pole action after the grab, `anim_st` again). `PoleClass.tb` gains the clamped
  polePos case (the walker folds oPosY + 720.0f to a constant; `PoleFloat.y0_bound_kc`).
  Found on the way: TOP_OF_POLE's stick-down exit (stickY < −16 → TOP_OF_POLE_TRANSITION)
  returns before `set_mario_animation`, so the animation is still the one the walk started
  from (on the first TOP frame, the transition's 11 / 12); the AR [9] walk passes only because
  every AL / AR start carries the start's `anim_st` (`PoleRunT.av_st`, `PoleStartT.avars_LR`),
  which the untouched-cells check then keeps.
  The old `PoleRow.pole_row` and the walks `PoleSlow` / `PoleFast` / `PoleHold` /
  `PoleClimb` are retired (they could not keep the animation world).
  - **Statement strengthened (true in the game, no new trust row):** the frame world
    (`FrameSplit.fworld`, `HeightFrame.PhiW`) carries `AnimWorld.anim_w`: the DMA table
    (count, srcAddr = `gMarioAnims`, the pole animations' entries), `bufTarget`,
    `gMarioAnims` / `gAreaUpdateCounter` storage, and, in a pole action after the grab,
    `anim_st` (no handstand animation loaded, or handstand animation k loaded with its
    cells and animFrame within that animation's range). Every PROVED row keeps it
    (`AnimKeep.anim_w_keep`; the pole rows by `anim_base_keep` and the walk's AnimEnd check)
    and the boot witness establishes it (`StartSat`). The assumed flank specs
    (`seg_*_spec`'s `Phi m -> Phi m'`, notably the render call that advances animFrame,
    which `RenderFlank.render_frame_range` keeps in [−1, loopEnd]) and the open rows
    `Hseg_call_na` / `Hseg_any` now also claim it; it holds in the game.
  (q) **`Hseg_call_na` split per call (2026-10-23, `NaSplit`; 22 → 22 hypotheses, the one
  left strictly narrower).** HeightFrame's hypothesis is now `Hseg_na_open :
  NaSplit.na_open_rows`. That was 12 named per-call rows (8 since 2026-10-24) (the list `NaSplit.na_open`).
  `Hseg_call_na` is a lemma (`NaSplit.naFA_of_open`): it case-splits the 15 calls of
  `execute_mario_action` that it covers, read from the generated body (`ema_calls_eq`).
  The three calls below are **proved** from their generated bodies:
  - `set_submerged_cam_preset_and_spawn_bubbles` (`ssc_row`). Its body is guarded by
    `(m->action & ACT_GROUP_MASK) == ACT_GROUP_SUBMERGED`. No `R_noA` action is in group
    0xC0 (`R_noA_not_sub`), so memory is unchanged.
  - `update_mario_health` (`health_row`). It is walked by `lw_body_frame` and writes only
    health / hurtCounter / healCounter (offsets 174–179), plus the sound request queue through
    the real `play_sound` (`pffs_call`). `ProRows`' footprint hole is widened from {4..8} to
    {4..8, 174..184} (`ProRows.hz`), and `hole_fworld` / `hole_cells` prove that such a change
    keeps every `fworld` conjunct, the cells and `fresh_at`.
  - `mario_execute_submerged_action` (`sub_row`). It is vacuous under the new dispatcher
    gate, described next.
  - **Statement strengthened (true in the game, no new trust row).** A dispatcher row's
    precondition (`FrameSplit.xpre`) now also carries `FrameSplit.grp_ok`: the action cell's
    group (`action & 0x1C0`) equals the dispatcher's switch label (`disp_tab`). This is proved
    at the real `switch (m->action & ACT_GROUP_MASK)` in `FrameSplit.iter_J`, from the
    generated block (`lb_full`) and the action load through `gMarioState` (`act_of_tmp`).
    The proved airborne and automatic rows ignore the new conjunct.
  - **(2026-10-24) `mario_reset_bodystate` (`reset_row`) and `update_mario_info_for_cam`
    (`cam_row`)** are proved from their generated bodies (`lw_body_frame`). This repairs
    their §7 phantom-∀ finding.
    - **The repair needed more than the pin.** `ffw` now carries `m->marioBodyState =
      &gBodyStates[0]` (the load at offset 152, `LBS`). That alone does not stop
      gBodyStates from overlapping a world surface, area or controller. So gBodyStates is
      also an `ff_rl` walk region (`RBS`, size `Ptrofs.modulus`, like the other symbol
      regions; `NBF` becomes 23).
    - Both facts are proved at the boot witness (`StartSat`) and kept by every proved row:
      the ff / kb / ledge / ahw / pole / cannon / auto walks and `AnimKeep`.
    - Every store goes to one of three places, so the rows need no new world fact:
      - Mario's own fields inside `ProRows.hz`;
      - gBodyStates;
      - gPlayerCameraState (`m->statusForCamera`, already pinned).
    - `ProRows`' hole lemmas are now generic over two blocks drawn from `ProRows.XIDS`:
      the two sound-queue globals, gBodyStates and gPlayerCameraState. `nextblock` may
      grow (`Ple`).
    - info_for_cam calls the real `vec3s_copy` / `vec3f_copy`. Each allocates an
      address-taken `dest` frame and frees it. `BodyFrame.v3_frame` walks both bodies:
      outside the dest block they change nothing except that freed frame.
      `BodyFrame.Q2` is the composable relation behind both rows: kept bytes unchanged,
      old permissions kept, new blocks without permissions.
  - **(2026-10-24) `squish_mario_model` (`squish_row`)** is proved from its generated body
    (`lw_body_frame`). Its stores are `m->squishTimer` (inside `ProRows.hz`) and
    `m->marioObj->header.gfx.scale[i]` with i < 3. Its calls are the real
    `vec3f_set(m->marioObj->header.gfx.scale, ...)` (`BodyFrame.v3set_frame` walks math_util's
    body: it writes 12 bytes at its argument and frees its own `dest` frame).
    - Every Object* temp is loaded from `m->marioObj`. `ffw` already pins that cell to Mario's
      object (offset 136, with the 608-byte object in bounds), so every write lands in bytes
      44..55 of that object.
    - `ProRows`' hole lemmas take a third, optional hole `(ob, oz)`: Mario's object's
      `gfx.scale` (`ozp`). The old two-block form is `hole2_*`. No world conjunct, Phi
      cell (`gfx.pos[1]` is at 36) or floor refresh reads those bytes, so the row needs no
      new world fact.
  - **(2026-10-24) `sink_mario_in_quicksand` (`qs_row`)** is proved from its generated body
    (`lw_body_frame`). It needed a new world fact (a phantom-∀ repair, §7):
    - `ffw` now pins Mario's object's `gfx.throwMatrix` (offset 80, `FFW_THROW`) to NULL or a
      pointer into `sFloorAlignMatrix` (mario_actions_moving.c), and that global is ff_rl
      region `RFA` (`NBF` 24) and a member of `ProRows.XIDS`. In the game, `geo_obj_init` /
      `unload_object` set NULL, `align_with_floor` (crawling and the slides, reachable
      without A) sets `&sFloorAlignMatrix[m->unk00]`, and the renderer's
      `geo_process_object` resets it to NULL after drawing; nothing else writes Mario's.
      The pin is proved at boot (`StartSat`: the zero-filled object pool gives NULL) and kept
      by every proved row (the walks check offset 80 via `FfKeepCheck.fk_same`; the hole
      lemmas, `AutoSplit` and `FrameSplit` keep it directly).
    - The throwMatrix store `( *throwMatrix)[3][1] -= quicksandDepth` lands in
      `sFloorAlignMatrix`, a hole block.
    - The other store is `gfx.pos[1] := gfx.pos[1] - quicksandDepth`, which is Phi's gfx cell.
      `wmotr_world` pins `quicksandDepth` to +0 and `budget_ok` makes the cell finite, so
      the store writes the cell's own value back (`NaSplit.f32_sub_zero_r`: x - (+0) = x on
      a finite binary32, by computation on Flocq's `Bminus`).
    - `ProRows`' object-side window is now generic: `ow`, `wl` with 36 <= ow and
      ow + wl <= 56 (squish: 44/12, quicksand: 36/4). `hole_cells` takes either
      40 <= ow or the caller's proof that the gfx cell kept its value.
    - The assumed flank specs (camera, render) now also have to keep this pin. They do in
      the game: the renderer writes Mario's `throwMatrix` back to NULL.
  - **2026-10-25: `mario_update_hitbox_and_cap_model` PROVED** (`NaSplit.hitbox_row`). The body
    walk (`HitboxFrame.hitbox_frame`) changes only Mario's hole, gBodyStates, Mario's object's
    `gfx.node.flags` (bytes 2..3) and `hitboxHeight` (508..511), and the 13 globals of the cap
    music path (`CapAudio.cap_ids`: sound_init / external.c statics and load_sequence's
    `ls_ids`), the last through the labeled footprint `LsContract.ls_frame` (row 4.1). The world is
    kept by `HoleX` (ProRows' hole over a list of globals none of which a world fact reads, plus
    the two windows). For that, `ffw` gained six fields, each what the game does and proved at
    boot (`StartSat.ffw11`): the floor pointer (wall / ceil until 2026-11-08) is a surface-pool block
    (`ff_Spl`; `FloorExec.surf_on` and `FfKeep.fk_surf` now carry it from `Wff`'s `dyn_list`),
    Mario's object is a gObjectPool slot (`ff_Spool`), `m->area` is a dynamic block or
    `gAreaData` (`ff_Sar`), the DMA buffer is dynamic (`ff_Dbt`), `m->controller` is
    `gControllers` (`ff_Sctl`), and each collided object is a slot apart from Mario's
    (`ff_Cd`). FOUND (phantom ∀): `ff_Co`, `FrameSplit.mobj_apart` and `ProRows.hole_coll`
    allowed a collided object AT Mario's own object, whose hitboxHeight this call writes; the
    collision code never records an object colliding with itself (`check_collision_in_list`
    starts after the player object). `ff_Cd` excludes it (`mobj_apart` still allows it; no row
    relies on that case).
  These 7 calls remain open as named rows:
  - `update_mario_inputs`, `mario_handle_special_floors`, `mario_process_interactions`;
  - the stationary, moving, cutscene and object dispatchers.
  The remaining phantom-∀ findings are listed in §7.
  **Slide kick at state ≠ 0 is proved (2026-10-21; `sk1_row` and `HeightFrame.Hsk1` removed,
  28 → 27 hypotheses).** The same walk (`SkW.skcheck12`) now classifies every outcome at any
  state (`FfClass.sk_ok` is `ff_okE` from the ticked cells; it used to accept the state ≠ 0
  path unchecked), `AirMove.sk_pre` drops its state-0 conjunct, and past the bounce the air
  step is the catalog's `S_sk_bounced` (four quarters) or `S_sk_bounced_cut` (a ceiling cut,
  vel ≥ 0 → −2); a landing there is SLIDE_KICK_SLIDE (`S_attach`), a wall BACKWARD_AIR_KB, and
  the timer gate FREEFALL (`Sw_freefall`, whose credit step was already proved for the bounced
  mode). `KbRun.kfinal` and `KbRow.kb_row` lose their `walk_entry` premise
  (`HeightMoveCatalog.walk_entry` is gone): every airborne walk now covers every state, and
  `KbRow.air_case_rows_ff8` is unconditional. **Found on the way:** `S_sk_bounced` pins vel' to
  gravity(vel) exactly (the post-bounce credit is the signed energy, which a lower vel would
  raise), but the air-step classifier only gave fm75 ≤ vel' ≤ gravity(vel): its `vel_ok`
  accepts the constant −75 on any path, and the jump-ascent quarter. Relaxing the catalog
  instead would be false (a phantom vel' = −75 from vel = 30 breaks the budget). So the
  classifier is sharpened: at a constant SLIDE_KICK action, a non-attach outcome's vel must
  pass `AirMatch.vel_exc` (the cut's −2, or `vel_ex`: −75 only on a path with the clamp fact
  `vel − 2 < −75`, or vel − 2 on a path with the no-clamp fact), checked in `AirSum.cls_core`
  inside the step summary; `AirMatch.aclass_air_ex` turns it into vel' = gravity(vel). Every
  walk was re-run with the sharper summary. No assumption added.
  **Found on the way (2026-10-21, slide kick):** (1) the
  catalog's slide-kick timer clauses (`S_air`, `S_air_cut`, `S_sk_bounced`, `S_sk_bounced_cut`)
  said timer' = timer + 1 in Z, which is false at the u16 wrap 65535 → 0 (`budget_ok` bounds
  the slide-kick timer only while vel > −73); they now say (timer + 1) mod 65536, and
  `move_keeps_budget` is re-proved. (2) `S_air`'s slide-kick clause also pinned vel' to exactly
  gravity(vel), more than the air-step classifier establishes (it gives the ≤ bound, as for
  every other air action); only the ≤ bound is used, and the conjunct is dropped. (3) The `AirMatch` recognizers assumed gravity 4;
  they are now parametric in the gravity constant (`gk_of`: 2 at a constant SLIDE_KICK action),
  and a ceiling cut at slide kick needs vel ≥ 0 (`vge0`), as the C does. (4) `AirSum.cls_of`
  now needs a constant action term, and there are no ledge-grab classes at slide kick. (5)
  `AirSum.PMc` asks the catalog move only for the no-attach class, plus `InRange` for every
  class. ffw's floor-refresh clause now also covers slide kick at state 0 (`fro_st` adds
  `sk0`): a stronger carried fact, of the same kind as butt-slide air's, which the open ground
  rows must now give. No assumption added. **Found on the way (2026-10-21):** the bounce is a landing, and a landing
  can leave floorHeight a quarter step stale, so ffw's floor-refresh claim cannot cover butt-slide
  air at state 1. It is now state-aware (`HeightMoveCatalog.fro_st` = fro_entry, or butt-slide air
  at state 0, which is entered by leaving the ground through a ground step that sets floorHeight).
  `pas_entry` admits butt-slide air at state 0 only. This is a stronger carried fact, true of the
  game for the same reasons; state 1 stays a row until the frame threads the refresh.
  **Found on the way (2026-10-20):** the air-step summary (`AirSum.c_pas`) took its
  entry to be m0's cells except the timer, so after a rollout's launch (state := 1, vel[1] := 30
  before the step) no outcome classified and the walk could not pass. The summary's entry is now the
  caller's terms at the call for action, state, timer, pos[1], vel[1] and floorHeight (`AirSum.icE`;
  m0's cells for a caller that changed none), and the `AirMatch` recognizers read the outcome
  against those terms, including the constant-folded forms the walker builds from a constant vel[1]
  (vel − 4, vel / 4 and the clamp, vel > 20 and vel > 0 tests fold, leaving no path fact). Two
  definitions were tightened with it: `AirMatch.above` now needs the outcome's floorHeight cell to
  be loaded (its old fallback term could equal an entry term once entries are arbitrary), and
  `FfClass.step_ok`'s state-bump branch accepts a constant state 1 as well as the `== 1` path fact.
  No assumption added.
- **Found on the way to the rollouts (2026-10-20):** Φ charged a rollout at state 0 the credit of
  its current vel[1], but its handler's first run sets vel[1] := 30 (airborne.c:1354-1356,
  1395-1397) before the air step, and the entry (dive slide / stomach slide) does not set vel[1]. So
  a state-0 rollout that was high up and slow passed Φ, and its launch then broke it. The credit now
  charges `rise_credit 4 (Rmax v 30)` at state 0 (`HeightInvariant.roll_prep`, mode `M_RollPrep`).
  Two real-state findings came with it: dive's jump-sound path reads `gAudioRandom`, which was a
  size-0 extern until audio/data.c was linked (18th TU), so those paths had no execution and the
  walk was vacuous on them (the walk now reads it as world memory: a gtab entry plus an `Fworld`
  start fact, with ffw saying its block is neither Mario's object nor the DMA buffer, proved at
  boot); and dive's object-grab path is cut by the carried input mask, which now also clears
  INPUT_INTERACT_OBJ_GRABBABLE (only interact_grabbable sets it, and WMotR has nothing grabbable).
  The walk covers both states: the windup (`FfClass.gpw_ok`: `S_gp_windup` or `S_gp_hold`) and the
  fall (the air-step summary from a ground-pound fall, then a landing, a wall bonk into
  BACKWARD_AIR_KB with vel[1] ≤ 0, or nothing). ffw's floor-refresh clause now covers ground pound
  too (`HeightMoveCatalog.fro_entry` = air_entry ∨ GROUND_POUND; since 2026-10-21 the clause is
  `fro_st`, which adds butt-slide air and slide kick at state 0). Its windup only raises pos[1]
  (`HeightFloatSteps.windup_add_ge`) and its fall is a non-attaching air step. As before, this is a
  stronger carried fact, true of the game for the same reasons.
- **Found (2026-10-20):** a ground pound in its windup (actionState 0) with actionTimer 65535 wraps
  `m->actionTimer++` to 0, and the windup rises again. No Move covers that, so the ground-pound row
  was false over such phantom cells. `budget_ok` now also says a windup's actionTimer is ≤ 32770.
  The windup ends once actionTimer ≥ loopEnd + 4, and loopEnd is an s16. `S_gp_hold` carries the
  bound (the walk proves it from that loopEnd test), and `launch_cap` gives it to an attach into the
  windup, so `chain_keeps_budget` still holds. To reuse the air-step summary for them, its premise
  "the entry action is ACT_FREEFALL" became `HeightMoveCatalog.air_entry` (freefall, AIR_HIT_WALL,
  SOFT_BONK, BACKWARD / FORWARD_AIR_KB), and ffw's floor-refresh clause now holds in all five (was:
  freefall only). That is a **stronger carried fact**, and so a stronger claim in the open per-call
  rows that carry ffw. It is true of the game because the frame refreshes floorHeight at pos[1]
  before the action runs, these actions are entered from non-attaching air steps, from switches that
  keep pos[1] and floorHeight, or from a pole (which moves pos[1] far less than STEP_UP = 241 below
  the refreshed floor), and no WMotR interaction moves pos[1] while setting one. AttachOK's
  ledge-after-ceiling-bump clause now also admits M_Air (the plain air credit already pays the
  vel/2: `rise_half4`).
- **Found on the way (2026-10-20):** an unconditional "floorHeight is a refresh of y" is not kept by
  `act_freefall` (a landing under a low ceiling can leave floorHeight a quarter step stale), so ffw
  states it only in ACT_FREEFALL, which such a landing always leaves; load-level pointer-closedness
  does not survive a call in any provable way, so ffw now carries injection closedness instead; ffw
  lacked that m->wall / m->ceil / m->controller are off the walk's regions, which keeping W and the
  A reading needs. The two former level-data rows are **proved** (`WMotRLevel.wmotr_gap_proved`: no
  floor height in (2424, 3046); `wmotr_poles_proved`: every pole low or out of reach;
  `wmotr_cannons_proved`: both cannon seats ≤ K; see 0.8).
- **Found 2026-09-28:** entering the cannon (`pos := cannon.y + 350`) is reachable without A (the
  buddy opens it on B) and was in no Move, so `Hframe_is_move_chain` was false as stated. It is now
  the `wmotr_cannon` attach case. `R_noA` is **concrete** since 2026-09-29 (`NoAActions.v`: the
  census's 73-action closure, `docs/goal2-rnoa-census.md`; proved disjoint from GOAL 1's taint set;
  every one of the 36 actions seen in the no-A write-watch frames is in it). The census is a tool
  result, so an edge it missed would make `Hframe_stays_noA` false. Tethered: `budget_ok` holds on
  all 68,423 no-A write-watch frames that carry the full cell set (`ywatch.py`), and on the 620
  recorded states (`experiments/oracle/phi_check.py`) except 4 `ACT_JUMP` states at vel 44. Those
  recordings press A, so they are outside the premise.

### Row 0.8 in detail

- **Defined from generated/, rows proved** (`WMotRLevel.v`). Data: `generated/wmotr_level_data.v`
  (clightgen of `pipeline/tu/wmotr_level_data.c`, which `#include`s the vendor terrain, macro list
  and the two object meshes verbatim; the real build puts them in other TUs),
  `generated/wmotr_script.v` (the real `levels/wmotr/script.c`; `level_wmotr_entry` is shown to load
  these arrays), `generated/macro_special_objects.v` (the real preset → behavior table).
- **Trusted:** (a) the Coq decoders mirror `load_area_terrain`/`load_static_surfaces`,
  `spawn_macro_objects` and the OBJECT command layout (cross-checked: 1352 triangles / 778 floors,
  as `tools/goal2_ladder.py`; the 6 poles; 26 macro objects); (b) the census that of WMotR's
  behaviors only `bhvExclamationBox` (scale 2, `exclamation_box.inc.c:176`) and `bhvCannonClosed`
  load collision, from `behavior_data.c` (not generated), and that those objects stay at their spawn
  height with no x/z tilt, except that an opening cannon lid sinks (FOUND 2026-10-24:
  `cannon_door_act_opening` moves it down 0.5 for 30 frames, then +4 in x a frame until timer 80,
  reloading its collision each frame), so a lid's floor range is widened 15 down
  (`WMotRLevel.obj_drop`; the lids sit far below K, the gap check is unchanged); (c) pole top = base + 10·bparam2 (`pole.inc.c:20-21`); (c') a cannon
  seats Mario at lid y + 10: the cannon base spawns at its lid's home (`cannon_door.inc.c:9-11`,
  un-generated), its script drops it 340 before `SET_HOME` (pinned from `generated/behavior_data.v`,
  `bhvCannon_drop_then_home`), and `act_in_cannon` adds 350; and a cannon has not moved from home
  when Mario enters it. FOUND 2026-10-24: the base does move before firing. With Mario inside,
  `opened_cannon_act_4` (cannon.inc.c:44) adds 5 to oPosY at timers 0..68, and the base stays
  tangible, so it sits in Mario's collided list up to 345 above home. `cannon_obj_ok` (used by
  `used_ok` and `coll_obj_ok`) claimed exactly home and was false during the rise. Now
  `wmotr_cannon_list` is every home seat + 5k, k = 0..69 (140 seats, `cannon_list_length`), all in
  [−2730, 1182] ≤ K (`cannon_list_range`, `wmotr_cannons_proved`); the cannon walk runs at all 140
  (`CannonWalk.cannoncheck837` / `cannoncheck2730`, one genv per home). Mario's y is still the
  home seat in the game (state 0 runs only at home); (d) floor heights `find_floor` returns lie within ±1 of a static floor
  triangle's y-range (binary32 plane evaluation overshoot ≤ 0.001, `tools/goal2_gapfact_check.py`),
  or exactly on an object's flat top. (d) is a claim about the real frame and is part of
  `Hframe_is_move_chain`.
- **Since 2026-10-20 it is load-bearing as `floor_data` inside the carried `FfWorld.ffw` (0.6)**,
  used by the proved freefall MoveChain. Toward discharging it: `FloorHeight.ff_height` proves from
  `find_floor`'s body that the returned height is −11000 or `FloorList.plane_h` of a surface on the
  frame-entry partition lists, at an (x, z) that passed that surface's three edge tests, and
  `FloorExec.c_ff` hands this to the air-step walk as a fact. The surface is on a FLOOR list (slot 0
  of a valid partition cell, `FloorHeight.floor_head`), and when `*pfloor` comes back non-NULL the
  height is such a hit, never the −11000 start value. What would remain is a fact about level data:
  the per-triangle binary32 bound.
- **Found by this step:** the box's ×2 scale. The ladder had used +52, so K was 2372 and is now
  2424.
- **FOUND 2026-10-22 (false premise, repaired): `floor_data` was false at every real WMotR state.**
  - `floor_data` says every `Hit_at` height is a WMotR floor height. `Hit_at` is the set of plane
    heights `find_floor_from_list` can store.
  - It let the query (x, z) be ANY 32-bit int. The three edge tests are int32 and wrap, so for a
    far-away (x, z) they pass about one time in eight.
  - There, a SLOPED floor's plane height is huge (checked: a 2.6e8 height on a ±1000 test triangle).
  - So `floor_data` held only if no floor list holds a sloped surface: never with WMotR's terrain
    loaded. It is in `ffw` ⊂ `PhiW`, the GOAL 2 start premise, so GOAL 2 was vacuous on every real
    WMotR memory (phantom ∀). The empty-partition witness hid it.
  - **Repaired** (`FloorHeight.ffl_hit16`): a hit is at an s16 (x, z). `find_floor` passes its s16
    locals `x = (s16) xPos`, `z = (s16) zPos`, and `ff_height` now proves it (`HH_set_xz`,
    `xz_arg_ok`). At |x|, |z| ≤ 32768 with WMotR's vertices the edge tests cannot overflow, so a
    hit is a point of the closed triangle. No consumer changed: they all read `floor_data`.
- **find_floor never misses in bounds (2026-10-26, PROVED, no trust added):**
  `FfComplete.ff_complete` walks the real `find_floor` body (both bounds tests, the dynamic and
  static list calls, the SURFACE_INTANGIBLE re-search branch, the miss counter, the
  dynamicHeight > height choice, the `*pfloor` stores) and proves `*pfloor` comes back non-NULL
  whenever the s16 casts of xPos / zPos lie in (−8192, 8192), (s16) yPos ≥ −8269, and every static
  FLOOR cell list holds both triangles of WMotR's SURFACE_DEATH_PLANE (y = −8191 spanning
  ±8192, `FfComplete.dp_lists`; the two triangles pass all three edge tests at every in-bounds
  s16 (x, z) by exhaustive check, `dp_pass_A` / `dp_pass_B`, and their plane height −8191 is
  ≤ y + 78, the find_floor_from_list cut). `dp_lists` is now a conjunct of the floor world fact
  `FloorExec.Wff` (accessor `Wff_dp`), kept by every step that keeps `Wff`
  (`FfWorld.Wff_keep` / `Wff_keep2` via `FfComplete.dp_lists_keep`) and PROVED at boot from the
  real loaded terrain (`StartTerrain.dp_chk`, checked on m11 in `wchk`, `dp_chk_sound`;
  `StartSat.wff11`). Not yet consumed: `c_ff` still offers the NULL outcome; dropping it needs the
  position bounds carried in `ffw` (next chunk).
- **FOUND D (2026-10-26, phantom ∀ in an open row, repaired 2026-10-26 by B'', below):** the open
  `update_mario_inputs` row (`NaSplit.na_open`, through `HeightFrame.Hseg_na_open`) claims
  `FfWorld.fresh` afterwards from any frame-world memory. Its `update_mario_geometry_inputs`
  (mario.c:1314-1368) searches the floor under `pos`; on a miss it copies `gfx.pos` into `pos` and
  searches again; on a second miss it leaves `m->floor = NULL` and calls
  `level_trigger_warp(m, WARP_OP_DEATH)`. That path breaks `ff_Wf` (the floor cell must hold a
  WMotR surface), and the frame world does not rule it out: nothing it carries keeps `pos` or
  `gfx.pos` over the death plane, so the row is FALSE as stated. Repair (agreed plan): carry the
  box for `gfx.pos` x/z in Φ and for `pos` x/z in `fresh` (chunk B-xz), tighten y to −8192
  (chunk B-y); with `ff_complete` the second search then always hits and the DEATH call is dead
  code on every frame-world memory. Until then the row stays open, labeled with this finding.
  **Repaired differently 2026-10-26 (B'', the claim is now TRUE):** the frame world no longer
  says the floor is never NULL. `ff_Wf` is now `wfl` (a WMotR surface **or NULL**). `fresh` /
  `fresh_at` now also say the floor cell holds a pointer (`floor_nn`). umi's post (and that of
  the two calls after it) is now `floor_null \/ fresh`. **FOUND:** the real OOB guard in
  `execute_mario_action` (`if (gMarioState->floor == NULL) return 0;`, proved as
  `FrameSplit.fc_null_returns` and used by `hs_fc`) makes a NULL-floor frame dispatch-free.
  Mario is frozen until the DEATH warp, and every dispatch case still sees a fresh floor. The
  NULL-floor reader audit, including one UB-coverage point (`mario.c:427`), is in row 3.2.
- **level_trigger_warp's contract (2026-10-26, PROVED, no trust added, `LtwFrame`):** for the
  two Mario-side ops that reach it in WMotR (DEATH from the double miss above, WARP_FLOOR from
  `check_death_barrier`), proved from the real body and its callees' real bodies
  (play_transition, play_sound, fadeout_music → func_803210D4, area_get_warp_node,
  music_changed_through_warp): the call changes only the five warp statics, the transition /
  sound-queue / music globals (`ltw_ws`) and Mario's `invincTimer` (`ltw_frame`, any op); with
  a warp already pending memory is unchanged, else the op becomes DEATH / WARP_FLOOR / GAME_OVER
  and the source node 0xF1 / 0xF3 (`ltw_cells`); so `FfWorld.warp_w` is kept, including its
  "no credits op" clause (`ltw_warp_w`). Staged for the two open rows that call it
  (`update_mario_inputs`, `mario_handle_special_floors`); not yet consumed.
- **Checked on the real loaded terrain (2026-10-22, `TerrainRun` + `TerrainBound`):** the
  repaired `floor_data` holds on the memory that the generated `load_area_terrain` builds from
  WMotR's collision data (1352 surfaces, conditional only on `world_ok`, see 0.4). Each floor-list
  surface is one of `static_tris`' floors with the same type and nine coordinates, which is (a)
  for this memory. Each passes a per-triangle binary32 check, `tri_chk`, proved sound
  (`tri_chk_sound`):
  - at s16 (x, z) the int32 edge tests cannot wrap, given the triangle's coordinate range;
  - a point passing them is a convex combination of the vertices;
  - the exact plane value there lies between its values at the vertices;
  - the five roundings move it by at most E, which is at most 0.0085 on WMotR.
  So (d) is now PROVED for the static partition of that memory. The worst margin to ±1 is
  0.991. What stays open is that the memory at real WMotR entry is this one (0.4).
- **(f) Mario's animation data (2026-10-22, `PoleAnim.v`).** `generated/mario_anim_data.v` is the
  clightgen of `mario_anim_data.c`, which the vendor's own `tools/mario_anims_converter.py` makes from
  `assets/anims/*.inc.c` (the real build's rule, vendor `Makefile:667`, into the same
  `build/us/assets/` path; our `Makefile` runs it). It is the ROM `assets` segment's `gMarioAnims`
  (`sm64.ld:1334`), the DMA source of `load_patchable_table`. Data only. **Linked since
  2026-10-22** (the 36th TU): as a size-0 extern, every `load_patchable_table` pointer compare had
  no execution (5.1). The game reads it only by DMA from ROM; in the model it is a read-only
  global with the clightgen'd bytes (the approved ROM-content statement: the ROM's `gMarioAnims`
  is this layout, and `osPiStartDma` copies ROM bytes verbatim, formalized as
  `OsDmaFloor.pi_dma_anim_spec`; **LOAD-BEARING since 2026-10-23** as `HeightFrame.Hdma_anim`,
  consumed by the pole walks' `DmaXc.c_dma`, GOAL-2 audit (p)). `PoleAnim.handstand_y_bound` proves from it
  that for the three anims the top-of-pole handlers pass to `set_mario_animation` (9, 11, 12, read off
  the generated bodies: `top_of_pole_anim_ids`), every y-channel sample a frame ≥ −1 selects (entries →
  header → index pair 1 → values, with `retrieve_animation_index`'s clamp, inside the DMA'd range) is
  in [−4, 696]. So `translation[1]` ≤ 174 and `pole_up_covers_handstand` gives −100 + 174 + 79 ≤
  `POLE_UP` = 160. This replaces the tool-read 174 of the GOAL-2 audit (f). The anim data **does**
  move `m->pos[1]`: `set_pole_position(m, return_mario_anim_y_translation(m))`.
  **Trusted:** the decoder mirrors that path (field offsets are checked against CompCert's layout of
  the generated composites, `anim_layout`), and the ROM bytes are the IDO (MIPS, big-endian) layout of
  the same C, which CompCert's (PPC, big-endian) layout matches for this struct. **2026-10-23: the
  top-of-pole cases are PROVED (audit (p))**: (1) is `pi_dma_anim_spec` (approved, above), (2) and
  (3) are carried by the frame world (`AnimWorld.anim_w`: the table, bufTarget, and per pole action
  the loaded animation with animFrame in [−1, loopEnd]), a logged strengthening, not a trust row
  (that it holds at real WMotR entry is part of Φ at entry, 0.4; the StartSat witness has it).
  The history: using it in a top-of-pole walk needed, beyond what is on this ledger: (1) a DMA content spec: 3.5 says the
  DMA'd bytes are "data", not the ROM's bytes, and the ROM is not modelled; (2) the DMA table
  `gMarioAnimsBuf.dmaTable` (count, srcAddr, entries) and `bufTarget` as a frame-world fact: they are
  built by `setup_dma_table_list` at boot, which is not run (the pool hardware row, 4.x boot gap);
  (3) the frame ≥ −1: `animFrame` is advanced by `geo_set_animation_globals`
  (rendering_graph_node.c) through `geo_update_animation_frame` (graph_node.c), so the frame world
  leaves it free (a phantom ∀ over frames < −1 reads other channels: up to 8191). **2026-10-22
  (later): rendering_graph_node.c is linked (TU 35) and the advance is walked.**
  `RenderSet.gsag_frame` / `RenderFlank.render_frame_range` prove from the generated bodies that
  with no acceleration and a header with −1 ≤ loopStart < loopEnd ≤ 32766 the render call keeps
  Mario's animFrame in [−1, loopEnd]; `RenderSet.gsag_footprint` proves it writes only the node's
  animFrame / animTimer / animFrameAccelAssist and the six `gCurrAnim*` globals. The call is now a
  frame segment (`HeightFrame.seg_render_spec`, row 0.7). **Still open:** carrying
  "animFrame ≥ −1" through Mario's own frame (the action step re-sets animInfo through
  `set_mario_animation` / `set_anim_to_frame`, which the frame world does not yet track), so
  TOP_OF_POLE_TRANSITION / TOP_OF_POLE stay in `Hauto_rest`, and the approved DMA-content row for
  (1) was not added (it would not be load-bearing without the walks) -- both done 2026-10-23,
  audit (p); (4) ~~segment 0~~ **repaired 2026-10-22:** the model stored `VIRTUAL_TO_PHYSICAL(p)` = p − 0x80000000 and the identity `segmented_to_virtual` did not add it back, so the sample load was 2^31 bytes out of bounds and every real top-of-pole frame had no CompCert execution. The macro is now the `NO_SEGMENTED_MEMORY` identity (2.2 register), and `AnimRoundTrip.anim_y_runs` runs the real `return_mario_anim_y_translation`. Each of (1)–(3) is a new or changed trust assumption, so none was added. (5) **Finding,
  repaired 2026-10-22:** in the 34-TU link `gAreaUpdateCounter` was only *declared* (every TU had
  it `extern`), so `init_mem` gave it a size-0 block and `geo_update_animation_frame`'s read of it
  failed: that function, and so `find_mario_anim_flags_and_translation`,
  `update_mario_pos_for_anim` and `return_mario_anim_y_translation` (top of pole), had no CompCert
  execution from the boot image. Linking rendering_graph_node.c gives it the real 2-byte storage,
  initialised to 0 (`RenderFlank.linked12_gAreaUpdateCounter`).

### Row 0.9 in detail

- **Machine-checked list, trusted edges.** Coq scans every function body of the 12 generated Mario
  TUs and proves: 31 direct `pos[1]` stores and 21 write-escapes (16 whole-vector arg-0 passes to
  `vec3f_copy`/`vec3f_set`/`vec3s_to_vec3f`, 5 `&pos[1]` passes to `f32_find_wall_collision`), 52 in
  all; `pos`'s address never reaches a temp, memory, a condition or a return, and no struct copy
  covers it.
- **Trusted:** (a) the callee write semantics: the three vector helpers write their arg 0 and
  `f32_find_wall_collision` writes back the same y; `vec3f_find_ceil` and
  `mtxf_align_terrain_triangle` only read the arg they get; (b) nothing reaches `pos` by pointer
  arithmetic on a `MarioState` other than the field access; (c) code outside the 12 TUs that gets a
  `MarioState` pointer (objects, level scripts: rows 0.5/0.7) does not write `pos[1]`. What each
  site writes is `Hframe_is_move_chain` (0.6).

### Row 0.10 in detail

- **Machine-checked over generated code, frontier trusted.** `generated/behavior_data.v` (clightgen
  of `data/behavior_data.c`) gives every behavior script as data; a fail-closed decoder mirrors the
  command layouts. WMotR places 11 behaviors (macro presets + level-script OBJECTs + MARIO). A
  closure follows every symbol their scripts, data tables and C bodies mention, over 21 generated
  TUs (now including `object_helpers`, `obj_behaviors`, `obj_behaviors_2`, `spawn_object`,
  `object_list_processor`), except a behavior whose value only reaches comparisons or lookups (a
  taint analysis whose sink table is proved a fixpoint, `sinks_stable`). Result: the reached
  behaviors are pinned (`reached_bhvs_value`), and **none can carry `INTERACT_GRABBABLE`**
  (`no_grabbable_in_wmotr`): every interaction type set by a script, an `ObjectHitbox` table or a C
  store is a constant without bit 1.
- **Trusted:** (a) the analysis is a computation, not a semantic theorem: its soundness (behavior
  values move only through args, temps, stores and returns; `segmented_to_virtual` is pure) is
  argued, not proved; (b) the frontier (`frontier_value`: audio, camera, dialog, save file, graph
  nodes, RNG, `load_object_collision_model`, `try_do_mario_debug_object_spawn`) neither spawns
  objects nor writes `oInteractType` (the debug spawner is off in retail); (c) the level-phase code
  outside the placed objects' closure (area load, warps, `script_func_global_*`) spawns nothing
  else; (d) behavior scripts' `CALL`/`GOTO` are followed as references, and the script interpreter
  (`behavior_script.c`, not generated) runs them as written.
- **2026-10-22, camera.c linked (35th TU):** `camera.global_definitions` joined `all_tus`, so
  the eight camera entries the frontier used to trust (`set_camera_shake_from_hit`,
  `set_camera_mode`, `cutscene_object`, `cutscene_object_with_dialog`,
  `trigger_cutscene_dialog`, `camera_approach_f32_symmetric`, `gObjCutsceneDone`,
  `gRecentCutscene`) are now ANALYZED from the generated bodies, not trusted. The census result
  is unchanged (no new behavior, no new interaction type), so (b) shrank and nothing else moved.
- **2026-10-24, `all_tus` staleness fixed (OBJECTS S1):** `surface_load`, `save_file`,
  `graph_node`, `ingame_menu`, `audio/external`, `behavior_script` (linked earlier) and
  `spawn_sound`, `debug`, `object_collision` (TUs 47-49) joined. The frontier is now 42
  entries, all unlinked audio / area / input / OS / render code (`frontier_value`).
  **FOUND FALSE: the unconditional grab fact.** (b) trusted the debug spawner. Its body
  (`debug.c:474-487`) spawns `bhvJumpingBox` and `bhvKoopaShellUnderwater` under its guard
  (`sDebugPage == STAGEINFO && gDebugInfo[ENEMYINFO][7] == 1`); both hitboxes are
  type 2 = `INTERACT_GRABBABLE` (`grabbable_in_full_closure`).
  Restated: `no_grabbable_in_wmotr` is over the closure that does not follow that one body
  (`closure_itypes_g`); `debug_spawner_bhvs` pins what it spawns. The guard being false is
  a state fact, still to carry (OBJECTS S2, `obj_w`). New reached behaviors:
  `bhvSoundSpawner`, `bhvJumpingBox`, `bhvKoopaShellUnderwater`, `bhvBlueCoinJumping`.
- **Live natives (2026-10-24):** `wmotr_live_natives` = every `CALL_NATIVE` of a reached
  script (107, pinned). All but two have a body in a linked TU
  (`wmotr_live_natives_unlinked`): the unlock-door-star natives (`mario_misc.c`), census
  over-approximation. `bhv_red_coin_star_marker_init` (live in WMotR,
  `spawn_star.inc.c:145`) got its body when `obj_behaviors_2.c` was linked (TU 50).
- **Object store census (2026-10-25, OBJECTS S3 groundwork, `ObjStoreCensus.v`):** the
  code a non-Mario slot runs (`close2` of `cur_obj_update` and the live natives minus
  `bhv_mario_update`; 432 bodies) is scanned for every store target and pointer call
  argument, each resolved to a root block through the body's temps (union over all
  definitions, least fixed point). Pinned by vm: `obj_census_value` (stores),
  `obj_arg_census_value` (pointer arguments), `obj_store_roots_value`,
  `obj_ptr_store_fns_value` (14 bodies that store through a pointer loaded from memory),
  `gcur_not_stored` (no body stores `gCurrentObject`, so "o" is fixed for the whole update).
  **FOUND: "a slot's script writes only its own object" is false as stated.** Besides the
  allocator / spawn / surface-pool / audio / save / cutscene globals, object code writes
  MARIO: `cur_obj_push_mario_away` (`gMarioStates`), `bhv_1up_interact` and
  `set_mario_npc_dialog` (through `gMarioState`; the latter calls `set_mario_action`),
  `opened_cannon_act_1` (`gMarioShotFromCannon`), and several bodies through
  `gMarioObject`. The kW walker (S3) must therefore carry a per-entry contract, not a
  blanket frame. A census, not a proof: no row or premise moved.
- **Read-only census (2026-10-25, OBJECTS S3 groundwork, `RoCensus.v`):** scopes the RO
  class that open items (c) call_action_function and (e) the script pointer need. Candidates,
  derived mechanically: the 35 action tables (every global passed to
  `cur_obj_call_action_function` in any TU) and the 533 behavior scripts (behavior_data's
  defined variables); none is const (`ro_none_readonly`), and 51 writable globals hold their
  addresses in their initializers (`init_refs_*`: macro / special / warp spawn tables,
  particle and droplet parameters, exclamation-box contents, 41 scripts naming other
  scripts). A flow analysis over EVERY function of the 51 linked TUs, to a fixpoint: a value
  is tracked if it may be a candidate's address (pointer / 32-bit-int types only, through
  temps, add/sub, casts, returns, callee parameters, and loads from every holder a tracked
  value is stored into). Pinned by vm:
  - BY FIELD NAME (`ro_name_census`, `ro_name_holders`, `ro_name_pairs`): no store anywhere
    targets a candidate, not even through a pointer read back from a holder; no address goes
    to an unknown location, an indirect call or a builtin. The addresses reach only
    `gCurBhvCommand`, the object fields `curBhvCommand` / `behavior` / `bhvStack`,
    `rawData.asConstVoidPtr` (create_respawner), and 36 (callee, parameter) pairs, none of
    which stores through its parameter.
  - BY UNION CELL (sound against reading a pointer back through another view of the same
    rawData cell): **ONE cell breaks the cheap invariant.** `create_respawner` stores the
    script into rawData byte 116 (slot 29, `oRespawnerBehaviorToRespawn`), a slot other
    behaviors read as an int; tracked as a cell it floods the run (6366 spurious store
    sites). With that cell charged to a per-behavior slot fact, the union-precise run is
    clean (`ro_union_census`, `ro_union_only_respawner`), and so is a deep run that also
    tracks pointers read through a candidate (`ro_deep_no_store`).
    `respawner_not_in_wmotr_closure`: create_respawner is outside ObjTable's WMotR closure.
  Consequence: the RO invariant is cheap. It needs a per-symbol "never a store target" fact,
  boot equality to the initializer, and one slot-29 fact (or the respawner shown not live).
  A census, not a proof: no row moved, no new trust.
- **ObjKit (2026-10-25, OBJECTS S3, `ObjKit.v` + generated `ObjTable.v`):** UcKit's class
  walker run over the object slot's code: 387 bodies (the VM command functions, 104 of the
  107 live natives, their direct callees across 19 TUs), each re-checked against the
  generated AST by one vm sweep (`ot_walk_ok`). `obj_body_pres`: every walked nullary body
  keeps `ow_facts` (mem_ok). Premises: the FPU floor (3.5) and the audio premise `Hls`
  (4.1) as GOAL 1 carries them; `Hgs` (every linked variable outside `non_safeb_syms` is
  SafeB; met by any `SafeB_wit`-shaped SafeB, `obj_gs_safe_wit`); and `Hopen`, five OPEN
  leaves to discharge, each a named sub-contract: `cur_obj_push_mario_away` (Mario pos[0]/
  pos[2]), `bhv_1up_interact` (numLives via gMarioState), `start_object_cutscene`
  (gCutsceneFocus := the object), `cur_obj_update_floor` (a floor pointer read back out of
  a local out cell, which the class walk sees as kW), `cur_obj_call_action_function`
  (indirect call through a writable action table). Not yet walked: `cur_obj_update`
  (dispatch through the writable `BehaviorCmdTable`) and `bhv_cmd_call_native` (through
  the script pointer): they need S2's script-pointer row. Not wired into a capstone yet,
  so no row moved; no new trust.
- **ObjWalk / ObjFrame (2026-10-25, OBJECTS S3, `ObjWalk.v` + `ObjFrame.v`):** UcKit's
  mutual induction re-proved with a FRAME conjunct and three more store arms (a Mario temp
  `t = gMarioState` pinned to (bm,0) by MWF, `t->fld := v`; `gMarioStates[0].fld[k] := v`;
  a stored global `g := v`, any value), every Mario store checked against MWF's protected
  windows and a listed cell set. `FR m m'`: memory changes only in SafeB blocks, blocks
  allocated during the call, globals outside `mwf_syms`, and Mario cells in MC; `FR_mario`
  turns it into "Mario's block changes only in MC". One vm sweep (`xt_walk_ok`) re-checks
  390 bodies (ObjKit's 387 + the three Mario writers). Named sub-contracts, premises only
  the FPU floor (3.5), `Hgs`, SafeB_syms / spawn_ok: `push_mario_away_contract` (Mario
  changes only at pos[0], pos[2]), `one_up_contract` (only numLives),
  `object_cutscene_contract` (no Mario cell; gCutsceneFocus is a stored global).
  `obj_body_pres2`: ObjKit's mem_ok theorem with `Hopen` cut from five leaves to two
  (cur_obj_update_floor, cur_obj_call_action_function). `obj_body_frame`: every walked
  nullary body keeps mem_ok AND the frame, for any MC containing the listed cells, under
  the labeled audio premise in its footprint form `ls_contract` (4.1, `LsContract.v`; its
  `ls_ids` are non-MWF globals, so `ls_FR` turns it into the frame), `HMCn` (MC holds
  `NpcFrame.npc_cells`: set_mario_npc_dialog's frame is PROVED in `NpcFrame.v`,
  `npc_dialog_frame`, by walking the real bodies of its whole call tree -- set_mario_action
  and its four sub-setters, the pure leaves -- memory changes only in SafeB blocks and
  Mario's flags/action/prevAction/actionArg/actionState/actionTimer/forwardVel/slideVel/vel/
  faceAngle/wallKickTimer/peakHeight/usedObj cells) and the named OPEN premise `Hopen2` (the
  open leaf call_action_function, with frame). S-locals (2026-10-25): a pointer local whose
  cell holds only SafeB pointers (`sl_of`; checked by `SLI`, a new `XS` conjunct "blocks in
  [nl, nb0) gain only SafeB pointers", calls from such a body must restart at a kfree clean
  callee) types `cur_obj_update_floor_height_and_get_floor`'s `floor` out-cell, so the getter
  returns kS and `cur_obj_update_floor` is walked (392 table entries; `updfloor_xspec`
  replaces its PRES leaf too: `Hopen2`/`Hopen2u` are call_action_function only). The
  frame is per-block, not per-object; SafeB covers every object slot. Not wired into a
  capstone, so no row moved; no new trust.
- **kSelf, the own-slot frame (2026-10-25, OBJECTS S3, `ObjSelf.v` + `ObjFrame` sec. 5-6):**
  all object slots share ONE block (gObjectPool), so "own object" is the byte range
  [oc, oc + 608) (608 = sizeof(struct Object), `OSZ_sizeof`, vm) where gCurrentObject holds
  &pool[oc]. `ObjSelf.s_fun_frame` (generic, no SafeB/MWF premise): a self-clean body --
  every store is through a SELF temp (all its definitions are the gCurrentObject load) by
  fields / constant indices inside [0, 608), or NP-rooted (block is neither the pool nor
  gCurrentObject's), every call a direct call of a checked table entry whose arg kinds
  (KSelf / KNp / KAny) hold -- changes the pool only in [oc, oc+608) and never
  gCurrentObject's cell (`SFR`). `ObjFrame.self_tab`: the greatest self-clean subset of
  xotab plus play_sound (walked as a body), 200 entries, re-checked by one vm sweep
  (`self_walk_ok`); leaf sqrtf (FPU floor 3.5, memory identity). `obj_body_self_frame`:
  premises only `Hoc` (the slot fits in ptrofs), the entry pointer `SI`, and the args'
  kinds. Census: 46 of the 107 WMotR live natives are self-clean; the other 61
  (`cross_live`, pinned by name) write OTHER slots or need a stronger class: spawn /
  allocate targets (spawn_object*, try_to_spawn_object, create_object, then stores through
  the new object), loaded object pointers (parentObj, gMarioObject, a hidden 1-up),
  cur_obj_call_action_function, script-indexed fields, and helpers taking interior self
  pointers (vec3f_* on &o->pos: object_step, cur_obj_move_standard, animation init), and
  bhv_mario_update (Mario's own body).
  Koopa: only the koopa_shell_* bodies are in the object closure (no koopa race code), and
  no beta/alpha boo_key or respawner body is (`self_census_names`). Not wired into a
  capstone, so no row moved; no new trust.
- **Protected-slot frame with spawns (2026-10-25, OBJECTS S3, `ObjSpawn.v`, `ObjSelf` sec.
  GEN):** `ObjSelf.s_fun_frame3` generalizes kSelf to protected pool cells Pc and a KFresh
  kind (running slot or a slot with no Pc byte); `obj_body_spawn_frame` covers 244 entries
  (`spawn_walk_ok`, vm), 62/107 live natives. Pc P = the bytes of slots in P outside the
  list / graph link cells (`link_offsets`, vm against the composite env). Premise
  `Hspawn_fr` (spawn_object_at_origin's per-call frame) is a named OPEN proof obligation
  (spec in SKILL), not a trust assumption: nothing consumes this frame yet. A store through a
  STORED object pointer is never assumed to hit its intended object (it is KAny, so such
  bodies are not walked); stale-pointer verdicts in `ObjStoreCensus` (no FOUND). Not wired
  into a capstone, so no row moved; no new trust.
- **call_action_function's frame (2026-10-25, OBJECTS S3, `ObjAct.v`):** sizes pinned by vm
  (`act_size`): of the 35 action tables only 3 are passed from an xotab body
  (sJumpingBoxActions, sOpenedCannonActions, sExclamationBoxActions); their 15 entries are
  none of xotab's bodies; the entries' call closure is 90 functions, 21 outside xotab, no
  indirect call, no nested action call. `act_walk_ok`: the 15 + 4 helpers + the 69
  closure bodies walked by ObjWalk WITHOUT call_action_function as a leaf. ObjWalk gained
  one rule (`kargs_okx`): an argument cast at the call to a short / char / float / long
  parameter is never a pointer (`narrow_cast_nonptr`, proved from CompCert's sem_cast), so
  its class is free -- needed for `(s16) o->oFoo` arguments. `RO_tab ge m` (named premise):
  a pointer loaded from a live table's block is one of its initializer's Init_addrof
  targets; `ro_tab_boot` proves it in the real `Genv.init_mem` of the link (via
  BootMWF.init_mem_load_ptr and the link's initializer = the TU's). `caf_frame`:
  cur_obj_call_action_function(&tbl), tbl live, from UInv + RO_tab, keeps UInv and has
  ObjWalk's frame (FR, XS). UB-COVERAGE POINT (row 3.2): caf_frame has no action-index
  premise because an out-of-bounds table load has no Clight execution -- that EXCLUDES those
  runs, it does not prove they never happen (on the N64 the read returns adjacent memory).
  Open: `act_in_range` (oAction < table length for the 3 live kinds) as an S2 obj_w clause,
  carried from `act_stores_census` (the 14 oAction stores in the 15 bodies are constants
  inside their own table) plus the spawn / init writes, so the progress argument covers it. OPEN: RO_tab is
  not yet carried across the run (the tables are SafeB globals, so the existing frames
  allow writes there; RoCensus finds none) -- the spine-wide step. Respawner not live
  (`respawner_not_live`). Not wired into a capstone; no new trust.

### Row 0.7 in detail

- **FOUND (2026-11-09): `Hobj_cou_nt` / `Hobj_cou_t` were FALSE; pole half
  and cannon half both REPAIRED (no new premise).** Both capstones that take
  them have been VACUOUS since ef77325a (2026-11-08, which wired `Hobj_cou_nt`
  into the capstones). (1) Pole, REPAIRED: a pole's first update breaks
  `kind_ok` between SET_INT(oInteractType, POLE) and bhv_pole_init; INV_k is
  now state-indexed with a pole window (see "FOUND FALSE ... set42_keep"
  below). (2) Cannon, REPAIRED 2026-11-09 by RE-ANCHORING the ghost (see
  "cannon REPAIRED" below). **The vacuity window is NOT known closed.** The
  two known `native_res` counterexamples at the cannon's native are excluded
  since 2026-11-13 by the cannon trajectory pin (below, "native_res phantom
  at bhv_cannon_base_loop", REPAIRED), with no new premise. Still unchecked
  phantom candidates (OPEN, so treat the capstones as possibly vacuous):
  red coin's parent counter++, hidden-star init, cannon lid init, exclamation
  box act 2 / 3, jumping box; the case list is `BhvStep.cn_census` (13
  special natives + 59 residual generic).
- **Objects (2026-10-26): one real call.** `HeightFrame.play_frame_step` is now poll ; PRE ;
  `seg_objects_spec` ; POST ; render walk, and `seg_objects_spec` is `ObjPhase.objects_call`:
  the generated `area_update_objects` as one `eval_funcall`. The old `seg_platform` / action /
  `seg_rest` objects spec is gone. Mario's frame is the hole (`HeightFrame.mario_hole`:
  `execute_mario_action` keeps mem_ok and Φ with A up), filled by `Hframe_action` +
  `seg_action_phi`; the non-terrain rows are stated given the hole. Proved in `ObjPhase`: the walk
  of `update_objects`' body (an env-carrying checker, for `cycleCounts[30]`), the clock calls,
  the counter, and `objects_keep` (P through the call from one `call_keeps` per callee).
  The frame-block rows `Hobj_blind` / `Hobj_fresh` / `Hobj_noref` are **PROVED since
  2026-11-07, no row left in either capstone** (`HeightFrame.obj_blind_linked12` from
  `BlindKeep.blind_pc`; `obj_fresh_linked12`; `ObjPhase.noref_uo`, every update_objects callee
  parameterless, kept through `Generic.ClightClosed.funcall_closed_sep`; the list walks' per-object
  nr rows are gone, `ObjLoop.call_il_nr`). **RESTATEMENT (2026-11-07, no new assumption):**
  privacy of the frame block, `ObjPhase.noref ge b m`, was "no byte of memory, readable or not,
  holds a pointer into b"; it is now "some closing injection g (flat, `closed_by g m`) maps every
  symbol and leaves b unmapped". Reason: CompCert's external-call properties
  (`ec_mem_inject` / `ec_mem_extends`) speak only of readable bytes of mapped blocks, so the
  raw-bytes form cannot be carried across an external call; the closure form can
  (`Generic.ClosedMem.ext_call_closed`). Every use site needs only the weaker fact: stores into b
  are private-block stores (`noref_store_in`); stores elsewhere store ints or symbol pointers, both
  mapped (`noref_store_sym`); a fresh block is unmapped before and after its alloc
  (`noref_fresh`); and Pobjl's facts read only g-mapped blocks (symbols and what is loaded from
  them, closed under loads) and GOAL 1's chase set, which a frame block is outside (`FBl`), so a
  change confined to b keeps them (`Generic.ClosedFrame`, `BlindKeep`). History: (the stack array
  is unobservable; **FOUND 2026-11-07 (phantom forall) + REPAIRED:** `Hobj_noref` was stated over
  `noref b` alone, so `b` could be the next fresh block, which a callee's own frame alloc
  returns, and a callee spilling an address-taken pointer parameter then leaves `Vptr b` in
  another block; `UnloadKeep` even applied it that way, to `unload_deactivated_objects` with
  its own `filler` block. It is now over `ObjPhase.nrv b` (b allocated and unreferenced),
  and `UnloadKeep.unload_outer` carries filler's `nrv` through the walked body, using the row
  only for `unload_deactivated_objects_in_list` (`ObjPhase.nr_callees`); validity through
  any Clight execution is `ObjPhase.exec_valid`) (`Hobj_debug` is PROVED since 2026-11-07:
  `DebugKeep.debug_keeps` walks the real bodies -- reset_debug_objectinfo's int stores into
  debug counters, the two set_print_state_info calls (s16 stores into gDebugPrintState1 / 2),
  update_debug_dpadmask's int stores, all via `ClearKeep.gstore_keep`; stub_debug_5 is empty;
  try_print_debug_mario_object_info stores nothing given the pins. The pins are start-checked
  clauses of `ObjWorld.ow_debug` (by `ow_chk` on the boot witness), kept by `obj_w_unch`:
  sDebugPage = 0 (it boots 0; no generated code stores it by name) and gDebugInfoFlags has bit 0
  (DEBUG_INFO_FLAG_DPRINT) clear (`OW.dflags_ok`; its only generated writer,
  debug_unknown_level_select_check from clear_objects, keeps it: `DebugKeep.dlsc_keeps`).
  The old ow_debug clause (sDebugPage != 3 or gDebugInfo[5][7] != 1) is implied.)
  (`Hobj_stores` PROVED 2026-11-03: `ObjStores.stores_safe`, the
  17 store blocks of `update_objects` classified by vm on the generated body -- cycleCounts[i]
  (the frame block, carried by `HeightFrame.obj_blind_linked12`), int stores into globals no invariant reads
  (`ClearKeep.gstore_keep`), and `gObjectLists = gObjectListArray`, which rewrites the
  pointer obj_w's `ow_gol` pins, so no load changes (`ObjStores.gol_keep`);
  `Hobj_counter` / `Hobj_ctr` PROVED 2026-11-03:
  gAreaUpdateCounter++ and gObjectCounter = c are int stores into globals no invariant reads,
  `ClearKeep.counter_keeps` / `ctr_keeps` via `gstore_keep`, every footprint test by vm),
  (`Hobj_collisions` is PROVED since 2026-11-07: `CollWalk.detect_keeps`, the walk of the
  real `detect_object_collisions`; each store is a collision cell (types, numCollidedObjs,
  collidedObjs[0..3], rawData[5], rawData[66]) of a listed slot, kept by
  `CollKeep.coll_store_pc`; the two objects of a hitbox test are distinct by NoDup of the
  rings, so Mario's partner is another listed object; no new premise beyond sqrtf's memory,
  4.1), (`Hobj_unload` is PROVED since 2026-11-06, both rows it was narrowed
  to included; see the unload note below), (`Hobj_surfaces` is PROVED since 2026-11-03, see
  `clear_dynamic_surfaces` below; `Hobj_terrain` / `Hobj_nonterrain` are
  PROVED since B2, below, from `Hobj_step_terrain` / `Hobj_step_nonterrain` / `Hobj_ctr`;
  `Hobj_mplat` is PROVED since 2026-11-03, see `update_mario_platform` below);
  `Hcam_ow_fp` (narrowed 2026-11-02 from `Hcam_ow`, which is now PROVED from it by
  `PollKeep.obj_w_unch`: the `update_camera` statement, the camera row's step
  `LevelFlank.cam_step`, from a mem_ok state in Φ, leaves the `PollKeep.ow_ids` globals'
  blocks and Mario's five object-pointer cells (136, 120..132) unchanged; a pure footprint,
  except one `obj_w` clause added 2026-11-02 with the surface pins: it also keeps
  `ObjWorld.surf_obj_ok` (`PollKeep.surf_keep`; the main-pool Camera shares its block with the
  surface pools, so "no non-symbol block changes" would be false; the cam_w pins plus
  `CamFootInst.update_camera_foot` were to discharge it with the rest of the row; since step (a), 2026-11-02, the globals' half is PROVED, `CamRows.cam_ow_globals`, and `Hcam_ow_fp` is a lemma over the labeled residual `Hcam_ow_res`; its surf_keep conjunct was FOUND FALSE AS STATED and is REPAIRED and PROVED since 2026-11-03, `CamRows.cam_surf_keep`, see (b') under `Hcam_phi` below); before: it kept the object world between mem_ok states in Φ; the real
  update_camera is walked only for mem_ok, over SafeB, which includes the object pool, so no
  footprint excludes the pool; its gates are machine-checked since 2026-10-26, `CamCutCensus`,
  and what is left is the carry (a) and the footprint walk (b) under `Hcam_phi` below).
  **PROVED 2026-10-26** (was the row `Hlvl_ow`): the level slices
  keep the object world (`HeightLinked12.lvl_ow_linked12`): the PRE slice's footprint is
  `lvl_safe_gvars` (`LevelKeep.pre_eff`), the POST slice is the hud statement, the camera
  statement (`Hcam_ow`) and the painting call + tail with footprint `level_gvars`
  (`LevelKeep.post_split`), and neither list names an `obj_w` global (`PollKeep.fx_obj_w`).
  **PROVED 2026-10-26** (was the row `Hrender_ow`): Mario's render call keeps the object world
  (`HeightLinked12.render_ow_linked12`): by `RenderKeep.render_eff` it changes loads only in
  the six render globals and the bytes [64, 72) of Mario's object, and every `obj_w` clause
  reads the pool only at a slot's fields from offset 96 on and its graph words [4, 16) (`PollKeep.obj_w_slots`).
  **PROVED 2026-10-26** (was the row `Hplat_keep`): the platform call keeps
  `plat_still` and the object world (`HeightLinked12.plat_keep_linked12`, from
  `PlatformKeep.plat_keeps_still` / `plat_loads`: by `plat_step_eff` the call changes loads only
  in D_8032FEC0's block and Mario's pos cells, apart from gMarioPlatform, the pool and every
  `obj_w` block; in particular it writes no gfx field of Mario's object); `surf_apart` follows
  from Φ. The phase invariant is mem_ok ∧ Φ ∧ A up ∧ `plat_still` ∧ `surf_apart` ∧
  `ObjWorld.obj_w`; `obj_w` is part of `fb_ok` and is a new start premise of the capstone,
  PROVED at the boot witness: the witness now runs the real `init_graph_node_start(NULL,
  &gObjParentGraphNode)` and `clear_objects()` (LEVEL_INIT) before the terrain and
  `spawn_objects_from_info(0, &gPlayerSpawnInfos[0])` (load_mario_area) after it, and
  `ow_chk` / `bo_chk` / `objs_ok` are checked on the result (`StartTerrain.wchk`): Mario's
  object is in the object lists, and one real `area_update_objects` runs from the witness
  (`StartSat.objects_runs`, in `goal2_start_sat`). The two `SpawnInfo` cells
  `level_cmd_init_mario` sets (behaviorArg 1, behaviorScript `bhvMario`) were stores until
  2026-11-03; now the real MARIO command handler runs (`StartTerrain.entry_g`, level_script.c is
  linked as TU 53); Mario's object cells the world reads (interact status,
  collided objects, throwMatrix) are checked on the result, no longer derived from the
  zeroed pool.
- **FOUND 2026-11-02 (rows false over unpinned pools) + REPAIRED in part (`ObjWorld` 3b).**
  `obj_w` said nothing about the surface pools. So the object-phase rows that run
  `clear_dynamic_surfaces` / `load_object_collision_model` (`Hobj_surfaces`, the per-object
  step rows) quantified over states where `sSurfacePool` / `sSurfaceNodePool` point into an
  `obj_w` block or a global, and where a dynamic surface's object is any object. Over those
  phantom states the rows' "keeps `obj_w` / Φ" claims are false. `obj_w` (its always-preserved
  core) now carries:
  - `ow_spool`: both pool pointers into one block past every global, at the boot run's
    offsets (`SP_OFF` = 58608, `NP_OFF` = 2592; apart, inside the main pool:
    `spool_layout`), `sSurfacePoolSize` = 2300, and the static counts
    `gNumStaticSurfaces` = 1352, `gNumStaticSurfaceNodes` = 2908;
  - `ow_surf_obj`: every surface on a list of either partition (static and dynamic) lies in
    a block past the globals and has a NULL object or a pool slot whose angle velocity
    (x, y, z) is 0. Since 2026-11-03 the clause covers EVERY word a partition holds (any
    offset a load reads), not only its 1536 cells. **FOUND 2026-11-03:** find_floor's
    contract (`FloorList.FL`) names its list head by an arbitrary partition offset, so the
    cell-only clause could not discharge `Hobj_mplat`. **REPAIRED, no new trust:** the two
    forms agree on every reachable memory (a partition is the definer's 6144 bytes,
    `StartTerrain.part_bound`, and no Clight run grows a block's Max permissions,
    `Generic.MaxPerm`), and the boot check proves the word form from that
    (`StartSat.part_cells_of`, `ObjWorld.part_cells`);
  - `ow_coll`: at most 7 exclamation boxes and 2 closed cannons in the object lists, every
    box at one of its 7 placed positions.
  Checked at the boot witness and after the first real `area_update_objects` and at the
  frame's end (`StartTerrain.frame_w`). The counter bound is NOT in `obj_w`: a fixed bound
  is false mid-phase, since collision objects load their meshes one by one. Its
  frame-boundary form `ObjWorld.ctr_ok` (NS <= gSurfacesAllocated <= NS + 88, NN <=
  gSurfaceNodesAllocated <= NN + 352: 7 boxes x 12 + 2 lids x 2 triangles, each in at most
  2 x 2 cells) is checked at the witness after the objects phase and at the frame's end
  (`StartSat.frame_runs`).
  **REPAIRED 2026-11-02 for the surface counter (`ObjWorld` 3c, `ObjLoop` 7b).** `obj_w`
  gained `ow_ctr` (NS <= gSurfacesAllocated <= NS + 88) and `ow_ter` (the budget clause: a
  slot's per-step dynamic surfaces `sdyn` are read from the script it RUNS -- box 12, lid 2,
  else 0; a slot with a budget is in list 9; lists 9 / 11 run only the box, lid and
  `bhvCoinFormation` scripts; list 9's budgets sum to at most 88; a box / lid slot's
  `collisionData` is NULL or its own mesh; both meshes hold their initializers). The
  objects phase is now staged (`ObjPhase` 3b): `Hobj_surfaces` yields Pobj plus
  `ObjWorld.post_clear` (counter = NS, or a time stop); the window before the terrain call
  keeps it (PROVED: `post_clear_store`); the terrain walk goes from Pobj /\ post_clear to
  Pobj, PROVED by `ObjLoop.terrain_keeps_ix` with the cursor-indexed invariant "counter +
  the budgets of the nodes not yet stepped <= NS + 88, or a time stop" (the ring's ORDER,
  `ObjLoop.ring_i_order`, moves it one node on). The per-object terrain row is now
  `ObjLoop.ter_row` (rest part `ObjStepSplit.ter_rest_row`): it may assume the stepped
  object is under its budget (`vbud`), and claims `ter_post`: lists 11 / 9 only grow at the
  tail by budget-0 objects, every node's budget is unchanged, the counter grows by at most
  the object's budget (0 in a time stop), the time-stop flag is unchanged. Each claim's
  truth / phantom check is written at `ter_row` (backed by `CollisionCensus`).
  **FOUND 2026-11-02 (single-invariant terrain row false):** the old row
  `call_keeps Pobj update_terrain_objects` is false once Pobj bounds the counter: at
  gSurfacesAllocated = NS + 88 with no time stop, a box's step adds 12 more. Hence the
  staging above.
  **FOUND 2026-11-02 (node bound false per step):** a per-step node bound (4 nodes per
  triangle) is false over states whose box / lid transform (`header.gfx.throwMatrix`, the
  lid's scale; pool offsets < 96) is not pinned: a large transform spans more cells. Not
  claimed; the node counter stays a frame-boundary check (`ctr_ok`) and an open item.
  **FOUND 2026-11-02 (wording wrong for time-stop frames):** the justification given for
  `ctr_ok` (here, in the coordinator's plan and in `ObjWorld`'s comment) was "between frames
  `clear_dynamic_surfaces` has reset the counters and each collision object has loaded once".
  The clear resets only when `TIME_STOP_ACTIVE` is clear (`surface_load.c:643`); in a
  time-stop frame the counters carry over. The fact still holds, for a different reason:
  `load_object_collision_model` loads only under the same test, and no terrain-list script
  (the box, the lid, `bhvCoinFormation`) writes `gTimeStopState`, so a time-stop frame loads
  nothing and the counters keep the last frame's values (`CollisionCensus.gates_value`,
  `terrain_value`, `ts_writers_value`: the only writers are `bhvMario` and two star
  spawners, lists 0 and 6, stepped after the terrain walk).
- **The collision census (2026-11-02, `CollisionCensus.v`, vm over the generated code).**
  The counters' writers are `clear_dynamic_surfaces`, `alloc_surface(_node)`,
  `load_area_terrain` and a debug printer. Of the behaviors WMotR can spawn only
  `bhvExclamationBox` and `bhvCannonClosed` reach them, each with one
  `load_object_collision_model` call per step (the box through `exclamation_box_act_2`, the
  lid through its loop's `CALL_NATIVE`). Loading and the reset are gated on
  `TIME_STOP_ACTIVE`. The terrain lists hold only the box, the lid and `bhvCoinFormation`
  scripts; none of them jumps or writes `gTimeStopState`. Object-list surgery is only
  `try_allocate_object` (tail insertion, in the generated store order) and
  `deallocate_object`, called only by `allocate_object`'s pool-full path on the first node
  of list 12. A step writes another object's script only in `create_object` (the new
  object) and `obj_set_held_state` (a held object; reachable from no terrain script), its
  behavior field only in `cur_obj_set_behavior` (self; coin code only) and `create_object`,
  its mesh only in `allocate_object` (new) and `bhv_cmd_load_collision_data` (self). No
  reached code or script spawns a box or a lid. This backs the terrain step rows' counter
  and ring claims (next item; not a trust row itself).
- **B2, the list walks (2026-10-26, `ObjLoop.v`).** `Hobj_terrain` and `Hobj_nonterrain`
  are no longer rows: `ObjLoop.terrain_keeps` (since 2026-11-02 `terrain_keeps_ix`, with
  the surface budget, above) / `nonterrain_keeps` PROVE them on the real
  `update_terrain_objects` (lists 11 and 9) and `update_non_terrain_objects` (the lists in
  `sObjectListUpdateOrder[2..]` until its -1: 10, 0, 5, 4, 2, 6, 8, 12), through the real
  `update_objects_in_list` and both real per-list loops (`update_objects_starting_at`,
  `update_objects_during_time_stop`, whichever the time-stop flag picks). Proved there: the
  list heads (`gObjectLists + i` = `&gObjectListArray[i]`, the node size 104 and `next` @ 96
  read from the composite env), each loop walks a ring of `obj_w` from `head->next` back to
  the head (each node it visits is a slot of that ring), the counts are ints, the order
  table's cells, and the frame block `filler[4]` of `update_non_terrain_objects`. New
  narrower rows: `Hobj_step_terrain` / `Hobj_step_nonterrain` (the real loop body up to the
  cursor advance, `ObjLoop.loop_pre`: `gCurrentObject = obj`, the gfx flag, and
  `cur_obj_update()` (in time stop: the freeze test first), run on a node of a walked ring,
  keeps Pobj and leaves that node in its ring; for the non-terrain lists under the Mario
  hole, and also keeping a non-symbol block's `noref`); `Hobj_ctr` (the store of an int to
  `gObjectCounter` keeps Pobj; PROVED 2026-11-03, `HeightFrame.obj_ctr_linked12`). "Leaves the node in its ring" is a real claim:
  `try_allocate_object` can unload an unimportant object when the pool is full, and the row
  must then show the current node is not that one. `Hobj_fresh` is now stated for any frame
  size (the 4-byte filler as well as the 240-byte `cycleCounts`). `obj_w` gained the clause
  ORDER (`sObjectListUpdateOrder` holds its initializer, checked at the boot witness by
  `ow_chk`), so the walk does not quantify over order tables the game never has.

- **B3a, the census behind "leaves the node in its ring" (2026-10-26, `ObjCensus.v`).**
  FOUND: `spawn_object.c`'s comment "I don't know of any unimportant objects that spawn
  other objects" is FALSE over the WMotR closure. Five list-12 (unimportant) behaviors reach
  `allocate_object` (`unimp_allocators_value`): bhvObjectBubble, bhvWaterDroplet,
  bhvSmallWaterWave, bhvSmallParticle, bhvSparkleSpawn. With the pool full,
  `allocate_object` frees the first node of list 12, which may be the object being updated,
  and the slot goes to the spawned object's list. SmallParticle and SparkleSpawn spawn only
  list-12 objects, so the node returns to list 12. The WATER behaviors spawn into list 8
  (`offlist_value`): Bubble -> BubbleSplash, WaterDroplet -> WaterDropletSplash, and
  SmallWaterWave -> SmallWaterWave398 (over-approximated: a script CALL target). A node
  moved to list 8 is not a clean hang: the walk runs on to list 8's head, calls
  `cur_obj_update` on it as an Object and reads past `gObjectListArray` (Clight-stuck / UB).
  So the ring part of the step rows cannot be weakened to "or it moved". It must be shown
  that this case does not happen; WMotR has no water (`FfWorld.env_w`). Also certified
  (syntactically, within the closure): only `allocate_object` calls `unload_object`, only
  `create_object` calls `allocate_object`, and only `try_allocate_object` /
  `deallocate_object` assign an ObjectNode's `next` / `prev` by field name. No trust moves:
  the census is a vm-checked certificate, and the rows it informs stay rows until B3 steps
  them.
  **DRY12 (2026-10-26, B3a-2): `obj_w` gained the clause `ow_dry12`.** A slot of ring 12
  runs (its command pointer lies in) a script of `ObjCensus.live12`, which holds the 20
  list-12 scripts minus the water movers. Each of them is DRY (`live12_dry`): it reaches no
  `allocate_object`, or spawns only list-12 objects. `ow_chk` checks the clause at the boot
  witness, so it is PROVED there. Before this clause, the per-object rows `Hobj_step_*`
  ("leaves the node in its ring") quantified over states with a water mover at the head of
  a full list 12. That is a phantom state: the row is false on it. With the clause in
  `Pobj`, the rows no longer range over that state, and they must now also CARRY DRY12. That
  means no water mover is spawned, which is gated in WMotR by no water (`FfWorld.env_w`,
  `find_water_level` = -11000), the wing-cap boxes' contents and the object y bound. These
  are the next B3 families.
  **CMDTAB (2026-10-26, B3 i): `obj_w` gained `ow_cmdtab`.** The 56 cells of
  behavior_script.c's static `BehaviorCmdTable`, the table `cur_obj_update` dispatches
  through, hold their initializer, the handlers `ObjCensus.cmd_handlers`. `ow_chk` checks
  this, so it is PROVED at the boot witness. Why nothing changes the cells (a certificate,
  `ObjCensus`): over the whole link, only `cur_obj_update` mentions the table
  (`cmdtab_users_value`); every mention is a read `*(T + i)` (`cmdtab_read_only`); and no
  initializer takes its address (`cmdtab_not_in_inits`). Carrying the clause frame to frame
  is part of the per-object rows, like ORDER.
  **CMDPOS (2026-10-26, B3 ii): `obj_w` gained `ow_vm`.** This is a FOUND and sharpening.
  The old `script_ok` said only that a slot's command pointer lies in a live script's block,
  at any offset. So the opcode byte that `cur_obj_update` uses to index the 56-cell table
  could be anything from 0 to 255, and an out-of-table index would mean a Clight-stuck
  dispatch.
  Now every live slot's `curBhvCommand`, `bhvStackIndex` and `bhvStack` cells must form a
  REACHABLE STATE of the behavior-script VM, `BhvVM.vm_tab`:
  - The table is computed from behavior_data's generated words. It holds 741 states,
    explored from the 94 entry scripts (word 0, plus word 1 after a BEGIN).
  - The excluded symbols are pinned (`entry_excluded`): collision / animation data, and one
    CALL fragment, bhvSmallWaterWave398.
  - The table is fail-closed: every state decodes to an opcode below 56, the command fits,
    every pop finds its frame kind, and the stack depth stays at most 3 of bhvStack's 8 cells.
  - The table is closed under the VM step (`vm_tab_closed`).
  `ow_chk` checks the clause, so it is PROVED at the boot witness. The command lengths and
  jumps are the macro layouts (`BehaviorScripts.cmd_len`). B3 (iii), the stepper, ties each
  one to its handler's generated body. Until then they are only the census's model, and no
  row depends on them.
  **Control layer (2026-11-02, B3 iii, `BhvStep.ctl_step`).** The ten control opcodes
  (CALL, RETURN, GOTO, BEGIN_REPEAT, END_REPEAT, END_REPEAT_CONTINUE, BEGIN_LOOP, END_LOOP,
  BREAK, BREAK_UNUSED) are now PROVED against their generated handlers, run in the linked
  program with the real `cur_obj_bhv_stack_push` / `_pop` and `segmented_to_virtual`.
  From a reachable state whose cells hold it, each handler lands on one of `BhvVM.succs`'s
  successors, returns its code, and writes only `gCurBhvCommand` and the slot's stack
  cells. So for these opcodes the census's macro layouts are no longer only a model.
  No trust moves. The theorem's premise that the script blocks hold their initializers
  (`scr_ok`) is an open obj_w clause (scripts are writable globals in C). The advancing
  commands, DELAY, CALL_NATIVE and the dispatch loop are still open, and no row depends on
  the theorem yet.
  **DELAY and the dispatch loop (2026-11-02, `BhvStep.dloop_ctl`).** DELAY joins the control
  layer (11 opcodes). `cur_obj_update`'s real dispatch loop (`dloop_is_real`) is PROVED to
  end at a reachable VM state whose cells hold it, under an invariant carrying `scr_ok`
  and obj_w's `cmdtab_ok`, given one row per opcode (`cmd_row_op`). The 11 control rows
  are discharged (`ctl_rows`). The other opcodes' rows (advancing commands, DELAY_VAR,
  DEACTIVATE, CALL_NATIVE) are the loop's open premise. Still no spine row depends on it.
  Sharpened (`dloop_used`): the reachable VM executes 39 of the 56 opcodes (`vm_used`,
  vm-checked over `vm_tab`), so the rows of the other 17 hold vacuously (`unused_row`)
  and the open premise is the 28 used non-control rows. `scr_ok` now has a decidable
  check (`scr_b_sound`: each cell of each reachable script against its initializer),
  ready to become an obj_w clause checked at boot; that obj_w/wchk step is held for the
  next StartTerrain rebuild. No trust moves.
  **The VM segment (2026-11-02, `BhvStep.seg`).** The copy-in
  (`gCurBhvCommand = o->curBhvCommand`), the loop and the copy-out are the
  generated code (`seg_is_real`, vm-checked). From a slot whose own cells hold a
  reachable state (`Vo`, the shape of obj_w's `ow_vm`: `vm_ok_Vo` / `Vo_vm_ok`), the
  three end with the slot's cells holding a reachable state and INV kept, given the 28
  used rows. Pfr now includes `o->curBhvCommand`. Still no spine row depends on it.
  DELAY_VAR's row is PROVED (`row_delay_var`; `done_ops` lists the proved rows, and `seg`
  needs only the 27 used rows outside it).
  SET_INT's row is PROVED from `set_keep` (`row_set_int`): the generated handler makes ONE
  store, of the script's value (`s16_of w`) to the script's field (`byte2 w` < 0x50), then
  advances. `set_keep` (INV survives exactly that store, at reachable SET_INT words) is
  pinned, not a phantom: obj_w reads field 42 (the interact type), which SET_INT writes.
  Computed over that finite set (`set42`, vm-checked): the reachable SET_INTs to field 42
  are bhvPoleGrabbing's INTERACT_POLE (64) and bhvCannon's INTERACT_CANNON_BASE (16384),
  both in `wmotr_interact_types`; so at field 42 `set_keep` is exactly kind_ok's pole and
  cannon pins for that slot. SET_FLOAT's row is PROVED likewise from `setf_keep`
  (`row_set_float`; its fields 10, 12, 18-21, 67 are none that obj_w reads). ADD_INT's row
  likewise from `addi_keep` (`row_add_int`: the old value read from the cell, ONE store of
  old + s16_of w; fields 16, 19, 26). OR_INT's likewise from `ori_keep` (`row_or_int`: ONE
  store of old | u16_of w; fields 1 and 3). ADD_FLOAT's likewise from `addf_keep`
  (`row_add_float`: ONE store of old + f32_of w to field 7 = oPosY, which obj_w reads -- the
  premise is pinned to that value). SUM_FLOAT's from `sumf_keep` (`row_sum_float`: two
  float reads at byte3 / byte4, ONE store of their sum at byte2 -- fields 6/7/8 = pos, which
  obj_w reads; pinned). DEACTIVATE's from `deact_keep` (`row_deactivate`: ONE s16 store of 0
  to the CURRENT slot's activeFlags @116, return 1, the command stays; only 32
  particle/spawner scripts hold it, never bhvMario -- so Mario's ACTIVE bit needs obj_w to
  keep Mario's slot inside bhvMario). SET_INTERACT_TYPE's from `sit_keep`
  (`row_set_interact_type`: ONE store of the script's next word to field 42).
  **FOUND (2026-11-03), resolved by computation:** the reachable VM table holds
  bhvKoopaShellFlame's SET_INTERACT_TYPE(INTERACT_FLAME = 0x40000), which is NOT in
  `wmotr_interact_types` (`chk47_ok` states the exception). `BoxCensus` resolves WMotR's 7
  exclamation boxes from their real macro bparams (6 wing-cap, 1 one-up: `boxes_value`,
  `box_ids_value`, mirroring spawn_macro_objects' oBehParams2ndByte), narrows the spawn
  closure's contents-table edge to those ids, and proves the shell and the flame outside it
  (`shell_unreached`, `flame_unreached`; non-vacuity `box_contents_reached`,
  `flame_in_uncut`). `BhvStep.sit_kind` is the KIND fact on that domain. Open (not a
  premise of any lemma, a phantom check to keep honest): (a) nothing rewrites a live box's
  oBehParams2ndByte after spawn -- no script in the narrowed closure writes field 47
  (`script47_value`), and its five C writers (`writers47_value`) write a new child's byte or
  the cannon's own (argued per writer, not proved per target); (b) no level-script OBJECT
  places a box (`box_not_scripted`); (c) the debug spawner stays gated. Using it needs
  obj_w's SCRIPT domain narrowed to `wmotr_closure_b`.
  The RANDOM setters (2026-11-03): SET_INT_RAND_RSHIFT (19), SET_RANDOM_FLOAT (20),
  SET_RANDOM_INT (21) are PROVED from `sir_keep` / `srf_keep` / `sri_keep`. Each calls the
  real random_u16 / random_float; the generic walker (`SpawnBodies.sw_walk`) proves the call
  changes nothing but gRandomSeed16 (`ru16_call`, `rf_call`: `Mem.unchanged_on Psd`), and
  returns a 16-bit u (random_float's value is `rf_of u`, the real formula). Then ONE store of
  the real computed value (`(u >> rshift) + min`, `range * rf_of u + min`,
  `(s32)(range * rf_of u) + min`). Fields: 19:{16} 20:{10,27-29} 21:{27}; 27 is the HSCOUNT
  cell obj_w reads for bhvHiddenRedCoinStar slots, so the premise is pinned to the value.
  New section hypothesis `Hsp : pool <> gRandomSeed16's block`, discharged at
  instantiation from global_addresses_distinct.
  PARENT_BIT_CLEAR (51) is PROVED from `par51_ok` + `pbc_keep`: ONE store of old & ~mask
  into the PARENT's field 22 (oActiveParticleFlags, which obj_w does not read). `par51_ok`
  is POSITIVE (a stuck NULL deref would silently drop a run): at reachable 0x33 words the
  real parentObj load IS a pool slot disjoint from the current slot's script stack.
  Computed (`BhvVM.pbc_states`): the 0x33 states are twelve particle spawners. Checked
  against the C: every spawn path for them is spawn_object_at_origin(parent =
  gCurrentObject) -- spawn_particle (Mario's table), spawn_object in bubba / mips,
  SPAWN_CHILD (bhvWhitePuff1 from bhvMistParticleSpawner) -- and none of the 20 parentObj
  writers targets them. Discharge needs two obj_w clauses: (1) every slot's parentObj is
  NULL or a slot (red_coin.inc.c may store NULL, so "always a slot" is false); (2) a slot
  running a pbc behavior has a slot parent. ANIMATE_TEXTURE (52) is PROVED from `atex_keep` (ONE store old + 1, or no
  store; the timer branch is not analysed). Computed (`BhvVM.atex_states`): its only
  reachable state is bhvKoopaShellFlame's (field 26, rate 2, nonzero), outside
  `wmotr_closure_b`, so the premise is vacuous once SCRIPT is narrowed.
  **FOUND (2026-11-03), fixed:** BhvStep's section hypothesis bounded the current slot's
  offset at `0 <= oc <= 40960`, i.e. only the first 68 of the 240 pool slots (608 bytes
  each) -- undischargeable for any object in a later slot. Widened to `oc <= 145312`
  (slot 239); every lemma re-proved.
  BILLBOARD (33) / DISABLE_RENDERING (53) are PROVED from `bb_keep` / `dr_keep`: ONE s16
  store of flags | 4 / flags & ~1 into the current slot's header.gfx.node.flags (@2), which
  obj_w does not read (ow_gfx reads the node links @4/@8/@12). SET_HITBOX (35) /
  SET_HITBOX_WITH_OFFSET (43) from `hb_keep` / `hbo_keep`: the f32 stores of the script's
  real s16 halves into hitboxRadius / Height / DownOffset (@504/@508/@520), not read by
  obj_w. SET_HOME (45) from `home_keep`: the three real pos -> home copies (fields 6-8 ->
  55-57), home not read by obj_w. SET_OBJ_PHYSICS (48) from `phys_keep`: six f32 stores of
  the script's real s16 halves (field 40 = hi(w1); 23 / 52 / 41 / 58 / 59 = the next halves
  / 100.0f) into the current slot; obj_w reads none (users: bhvJumpingBox, bhvKoopaShell,
  bhvSingleCoinGetsSpawned). LOAD_ANIMATIONS (39) from `la_keep`: ONE pointer store of the
  script's own word 1 (vm: an `Init_addrof`, the anim table) into field byte2 w (38,
  oAnimations; five non-Mario users). LOAD_COLLISION_DATA (42) from `lcd_keep`: ONE pointer
  store of word 1 (through the identity `segmented_to_virtual`, 2.2) into collisionData @536.
  obj_w DOES read @536 (`coll_pin`), and the only users are bhvCannonClosed /
  bhvExclamationBox, the LIDS / BOXS of coll_pin, so the discharge is the vm fact that their
  word 1 is that mesh at offset 0. SCALE (50) from `scale_keep`: the real cur_obj_scale
  (object_helpers, linked) stores (s16)(w) / 100.0f into the current slot's
  header.gfx.scale @44/48/52; obj_w reads only the node links @4/8/12 (users:
  bhvRedCoinStarMarker, bhvRotatingExclamationMark -- not Mario). BEGIN (0) from `begin_ok`,
  POSITIVE: the current slot's behavior @524 is a valid pointer, and bhvHauntedChair /
  bhvMadPiano / bhvMessagePanel are linked, valid and in other blocks. The three real
  cur_obj_has_behavior calls then return 0, and only the cursor moves (Pfr). Its 95 states
  include bhvMario's head: at the start witness Mario is at bhvMario[0], so frame 1 really
  runs his init chain (SET_INT, OR_INT x2, SET_HITBOX 37/160 into @504/508, inside PhiW's
  Mario window). Those keeps are discharged against bhvMario's real VM states (clause sent
  to Hseg: Mario's (cmd, stack) is one of bhvMario's ten vm_tab states), not phantom.
  CALL_NATIVE (12, `row_call_native`): the handler is the generated body (word 1 is the
  native's address). The callee's effect is split, not one premise per native.
  BULK: at a state outside `sp_scripts` (the scripts reachable from the 7 special
  behaviors: pole, cannon, cannon lid, jumping / exclamation box, hidden red-coin star,
  Mario), a callee with a nullary entry in `ObjFrame.self_tab_n` runs under the PRECISE
  frame SFR' (`native_bulk`, from `ObjFrame.obj_body_frame_x` / `ObjSelf.s_fun_frame`
  with XA = `allow_n`, XB = `XBn`). Every block valid at entry is unchanged except the
  running slot's non-XBn bytes, the 6 `allow_n` globals (play_sound's queue, random_u16's
  seed, the find_floor / find_wall counters) and blocks allocated during the call. The
  VM cells are XBn cells, so V survives (`V_sfr`), and INV survives by ONE keep
  (`sfr_keep`). 35 of the 94 natives generic states call are bulk (`cn_census`).
  RESIDUAL (`native_res`): the other 59 generic natives (cross-slot writers: spawn /
  allocate, the 5 obj_set_hitbox interactType writers, red_coin_init's parent) and the
  13 called from special states (Mario's three included).
  VALUE SIDE (`native_vals`, to be named `Hnative_vals` where the rows are wired):
  a bulk native at a generic state stores into old blocks only pointers to blocks
  `PV` names at entry (`nvals`; the instance is a SafeB block). Since 2026-11-07
  `nvals` is BYTE level (`nvB (PV m) m m1`: every changed readable byte of an old block
  is no pointer fragment, or a fragment of a PV pointer; and every old block keeps its
  permissions; readable bytes only since 2026-11-07, see INV_k's row keeps below), a strengthening of this undischarged premise that is still true in
  the game (the natives' pointer stores write whole PV pointers; a call frees only
  the locals it allocated); it matches the handlers' own frame `PfrN` below. When
  `Hnative_vals` is wired, a static scan of the census natives' pointer stores is to be
  vm-checked behind it (coordinator 2026-11-07). It sits beside
  `native_res` among the residuals. TRUE IN THE GAME: bulk natives store ints /
  floats, pool and surface pointers (oFloor into the main-pool block, SafeB by
  StartSat's SB1) and data-symbol pointers. To be DISCHARGED by a value-tracking SFR'
  walk (option A, scheduled with the stale-lid M1/M2 after the step rows are wired).
  **FOUND / REPAIRED (2026-11-07, phantom ∀ in `sfr_keep`).** SFR' says only WHERE a
  bulk native stores, never WHAT. So over every m1 it allows (e.g. a pointer to a
  freed local stored into the slot), `sfr_keep` was FALSE for any INV holding MWF_real
  (R7: the pool is SafeB, and SafeB is load-closed) or PhiW's closedness. REPAIRED:
  `sfr_keep` takes the value premise `nvals m m1`, and the natives' side is the
  separate premise `native_vals` above. This splits an undischarged premise into a
  true one; no capstone row moves.
  **FOUND / REPAIRED (2026-11-07, the handlers' frame had no value side).** `Pfr`
  (everything but gCurBhvCommand and the slot's VM cells) said where the control
  handlers write, not what; the VM cells' new contents were invisible to INV, so the
  exit could not re-establish MWF R7 there (stale stack words included). REPAIRED,
  PROVED (no premise): every handler producer now returns `PfrN m m' :=
  unchanged_on Pfr m m' /\ nvB scr_b m m'` -- each changed byte holds no pointer
  except into a reachable script's block -- by the generic byte lemmas
  (`nvB_store_trans`, `encode_cvok`: a store narrower than a pointer writes no
  fragment) and the `nvc` tactic over the handler's own stores; `Hinv_frame` takes
  `PfrN`. INV_k (ObjInv) carries `nvB scr_b g m` against its ghost
  g, the frame-start memory, so R7 at exit rests on R7 g, which the start theorem
  proves from boot (scripts are SafeB by StartSat's SB1). (Narrowed 2026-11-07 from
  `nvB (scr_b \/ SafeB)`, which the exit could not use: g's closing injection maps
  every symbol, hence every script, but not every SafeB block.)
  **The objects step's EXIT (2026-11-07, ObjExit `inv_exit`): PROVED.** INV_k
  at cur_obj_update's return, the slot at the reached state st' of st0's family
  (ObjFamily.Qfam), gives Pobjl m'. Its premise `HSafeB_scr` (the scripts are SafeB)
  is DISCHARGED at the capstones since 2026-11-07 (`HeightFrame.HSafeB_scr`, from
  `SafeB_syms_ok` (d) and the vm check `ObjStep.scr_bd_b`; see the rest row below). Through `cut
  (nextblock g) m'` (m' without the blocks born after g, a memory construction):
  g -> cut changes only the VM cursor and slot k0's VM cells, so Pc carries (MWF by
  `MWF_real_transfer`, R7 by `closed_nvB`; PhiW by `k_all_wc` with Xs =
  [gCurBhvCommand], the cut closed by g's closing injection, `nvB_closed`; obj_w by
  `obj_w_vm_swap`); cut -> m' adds only blocks born after g, which Pc is blind to
  (NewKeep `new_pc`, BlindKeep's argument for every new block at once). No
  new trust row. The row keeps for natives must keep the ghost / real difference
  inside the slot's VM cells and the cursor (script pointers only).
  **INV_k's row keeps (2026-11-07, ObjRows `rows_k`): moved to the ghost.**
  Each pinned keep of `row_keeps` at INV := INV_k now follows from the SAME keep at the
  ghost, INV := GP (`Pobjl g /\ Vo g st0`: the frame-start memory with slot k at its
  start state), PROVED: a row's store into m is the same store into g (`gr_store`: both
  memories take the same bytes, so `unchanged_on Pfr` and `nvB scr_b` survive); a
  footprint-only change (the RNG call's Psd; SFR') is followed by `fol g m1` (m1 with
  g's bytes at the cursor and slot k's VM cells, g's nextblock); a keep's loads read
  the ghost's value because its cells are off the VM cells (`fld_chk`, vm-checked over
  every reachable word; PARENT_BIT_CLEAR's cell by the parent's slot range, which
  `hd_parent_bit_clear` now exports to `pbc_keep`). 25 keeps move: SET_INT ... BEGIN,
  the three RNG keeps, and `sfr_keep` as `gsfr_keep` (the ghost changes only what SFR'
  allows at g; every changed readable byte holds no pointer but into a script or a
  SafeB block; PV := SafeB). Still at INV_k (`rest_keeps`): `native_vals`,
  `native_res`, the spawn keeps (sc_*, wd_*), `an_keep`, `dtf_ff`, `dtf_keep` (they
  read cells through loaded pointers or run code the ghost does not follow by one
  store / one footprint). No new trust row: premises are restated about Pobjl
  memories, none added. **CHANGE (2026-11-07): `nvB` is READABLE-byte level.** A
  footprint premise (`Mem.unchanged_on`) says nothing of bytes without a permission,
  so under the all-bytes form the ghost could not follow the RNG keeps or SFR'; both
  consumers (`closed_nvB`, ObjExit's `nvB_closed`) read only through a permission,
  so nothing they prove weakens. BhvStep now also takes
  `Hsq` (sqrtf_spec, the FPU floor row already in the ledger) and `Hpool` (the current
  slot lives in gObjectPool). No new trust row; ObjFrame's whole-walk frame (ls_frame)
  is not used. The pinned premises are bundled as `row_keeps`.
  Wiring it in needs the loop's INV to be obj_w minus the current slot's `ow_vm`.
  **The objects step's REST ROW on the non-terrain lists (2026-11-07, `ObjStep`): PROVED
  from a narrower row, WIRED.** `Hobj_step_rest_nonterrain` (both capstones) is now a
  lemma, `HeightFrame.Hobj_step_rest_nonterrain`. It is proved by `ObjStep.rest_sa` /
  `rest_ts`, the real loop bodies of update_objects_starting_at and
  update_objects_during_time_stop, read off the AST by vm:
  - the gCurrentObject store (`UnloadRows.gco_keep`);
  - the gfx-flag stores (`ObjGfl.gfl_pc`: cells [0,4) of a slot, read by no invariant);
  - cur_obj_update through `BhvStep.cou_real` at INV_k (entry `inv_entry`, row keeps
    `rows_k`, exit `inv_exit`).

  The object's ring membership is INV_k's ghost fact X (`in_ring_tr`: the ring links
  96 / 100 and the list heads are off the VM cells, so the ghost's rings are the real
  memory's). The capstones' row is replaced by **`Hobj_cou_nt : mario_hole ->
  ObjStep.cou_keeps nt_ls`**. For every slot k of a non-terrain ring, its start VM state
  st0 (from `obj_w`'s `ow_vm`) and the entry's nextblock, it asks for:
  - the keeps INV_k's dispatch loop reads: `ObjRows.ghost_keeps` (at the ghost) and
    `ObjRows.rest_keeps`;
  - `BhvStep.pre_keep` / `post_keep` at INV_k (the code around the dispatch loop).

  Every premise is about INV_k / Pobjl memories of a real slot. **GOAL 1's statement only
  swapped one row for a narrower one** (NoAImpliesNoFlyFrame: `Hobj_step_rest_nonterrain`
  -> `Hobj_cou_nt`); its claim and proofs are unchanged. **`SafeB_syms_ok` gains (d)**:
  behavior_data's defined globals (`SpawnInit.bhv_data_syms`, the behavior scripts) are
  SafeB. It is read through accessors (`sbs_neg` / `sbs_fam` / `sbs_ptr` / `sbs_bhv`),
  and every witness meets it: no behavior_data global is a `non_safeb_syms` symbol
  (`bhv_not_nonsafe`, vm), so `safeb_wit_sat(_le)`, SB1 / SBw (StartSat, the start-sat
  audit) and `SafeB_boot` prove it. True of the game's SafeB (the chase closure; objects
  point at their scripts). ObjInv .. ObjStep state Pobjl as `ClearKeep.Pobjc` (the same
  conjunction, convertible), so they sit below HeightFrame.

  **The terrain rest row (2026-11-08, `ObjStep`): PROVED from two narrower rows, WIRED.**
  `Hobj_step_rest_terrain` (both capstones) is now a lemma,
  `HeightFrame.Hobj_step_rest_terrain`, proved by `ObjStep.ter_rest_sa` / `ter_rest_ts`.
  The proof is the same walk as the non-terrain one, generalized over the ghost fact
  (`rest_saX` / `rest_tsX`). Here the fact is `XT`: the ring, plus `ter_abd` from the
  step's start memory. `ter_abd` is `ter_post` without the counter: (a) lists 11 / 9 grow
  only at the tail, by budget-0 nodes; (b) the budgets of their nodes are unchanged;
  (d) the time-stop gate is unchanged. It is composable (`ter_abd_tr`) and is carried:
  - across the loop's own stores (`gco_side` / `flg_side`: no O_CMD cell, no gTimeStopState);
  - across cur_obj_update's exit (`xt_cou`). Off slot k, the memory is unchanged off the VM
    cells. At slot k, the budget reads the running script, whose family keeps
    box / lid / coin formation (`ObjFamily.Qfam_id`, `sdyn_Vo`).

  The capstones' row is replaced by two:
  - **`Hobj_cou_t : ObjStep.cou_keeps_t ter_ls`**: the same keeps as `Hobj_cou_nt`
    (ghost_keeps, rest_keeps, pre_keep / post_keep at INV_k), with ghost fact `XT ter_ls m0`
    for every step-start m0. There is no Mario hole (terrain).
  - **`Hobj_ter_ctr : ObjStep.ter_ctr_row`** (both loop bodies): `ter_post`'s counter
    clause (c) alone. One terrain update grows gSurfacesAllocated by at most the object's
    budget (`OW.dyn`: 12 box, 2 lid, 0 coin formation, 0 under a time stop). **This is a
    counter-only claim about the real update**, over the same states as `ter_rest_row`.

  **Census behind `Hobj_ter_ctr` (`TerCtrCensus.ter_ctr_value`, vm, spine-root).** The
  budget is per load, since the meshes are pinned (`mesh_tris_pinned`, `coll_pin`). So
  the row is true iff no update reaches `load_object_collision_model`, or any other
  counter writer, twice. The census checks this over every VM state of the three terrain
  scripts (`vm_tab`). For one update entered at a state, it bounds the loader calls of:
  - the command's handler, or for CALL_NATIVE the native;
  - every nested call: direct calls, and indirect calls through any address-taken
    function of a matching type;
  - the successor states, until a command that always returns BHV_PROC_BREAK
    (`always_brk_value`).

  A loop around a loading call, or another counter writer, counts as unbounded. Result:
  box 1, coin formation 0, lid 1, the same at two depths / fuels. The cannon lid's last
  frame (the loop's CALL_NATIVE load, then the deactivate) is one of its start states,
  so it is counted. **No FOUND.**

  Discharge route for the two rows, logged:
  - (A) prove `ter_ctr_row` from the census, by a walk of the real loader under the
    pinned meshes plus a one-load-per-update induction over the dispatch loop;
  - (C) fold the counter into INV_k (a "loaded" flag per command), once the dispatch
    keeps are discharged. The flag is needed because the collision-load keep is not
    per-command inductive without it.

  GOAL 1's statement only swapped the one row for the two narrower ones
  (NoAImpliesNoFlyFrame); its claim and proofs are unchanged.
  **The ghost keeps, first slice (2026-11-08).** The 25 ghost keeps inside
  `cou_keeps` / `cou_keeps_t` are store-keeps: Pobjl, slot k's VM state and the ghost fact
  must survive one script-pinned store. Before this slice none of them was proved; the
  per-opcode rows (`BhvStep.row_*`) only reduce each row to its keep. Two are now PROVED
  for both ghost facts: BILLBOARD's and DISABLE_RENDERING's s16 store into the slot's
  graph-node flags @2 (`ObjStep.bb_g` / `dr_g`, from `ObjGfl.gfl_pc` and `vo_unch`, the
  ghost fact carried by `xf_st`). The rows now ask only `ObjRows.ghost_keeps_r`, the
  other 23. Next: field-exact obj_w / phiw frames (the `ccl` windows extended to the
  fields the keeps write, which the vm census of reachable (opcode, field) pairs lists),
  then the keeps whose fields neither frame reads.
  **Field-exact frames and six more ghost keeps (2026-11-08).** obj_w's pool frame
  (`ObjWorld.ccl`) and PhiW's (`RenderKeep.ccl_at`) now also exclude fifteen rawData
  windows (`FieldWin.ucl`): the fields the reachable script commands write that no
  clause of either invariant reads. The windows are not a hand list: `FieldWinCensus`
  computes, over the vm table of every reachable script word, the fields the
  byte2-addressed commands write (`vm_written_value`) and the reachable opcodes
  (`vm_ops_value`, including SET_HOME / SET_OBJ_PHYSICS, whose fixed fields come from
  their generated handler bodies); `win_fields_value` is that set minus the six fields
  obj_w reads, and `FieldWin.uwin_census` shows the windows are exactly those fields'
  bytes. Soundness needs no trust: a window over a read field would break the frames'
  own proofs. `ObjFld.fld_pc` proves that a non-pointer store into such a window keeps
  the objects phase's invariant, and `ObjStep` proves SET_FLOAT / ADD_INT / OR_INT /
  ANIMATE_TEXTURE / SET_HOME / SET_OBJ_PHYSICS / PARENT_BIT_CLEAR's keeps at the ghost
  (`win_op`: every reachable word of these writes a window field; PARENT_BIT_CLEAR's
  parent is a whole slot by obj_w's `par_ok`), and SET_INT's except at field 42
  (`set_op`: its fields are 5 -- bytes both frames already exclude -- 42, or a window);
  SET_INT is asked only as `ObjRows.set42_keep` (oInteractType: the pole / cannon pins).
  `ObjRows.ghost_keeps_r` now asks 16 keeps.
  **SCALE proved (2026-11-09).** cur_obj_scale's three f32 stores into
  header.gfx.scale (bytes 44..56) keep the ghost (`ObjStep.scale_g`, over
  `ObjFldLo.fld_pc_lo`): obj_w reads no header byte there, and PhiW reads them
  only for Mario's object. Slot k is not Mario's: Mario's slot runs a bhvMario
  state (`ow_mvm`), the family keeps bhvMario (`Qfam_mario`), and no reachable
  bhvMario word is SCALE (`scl_ops_ok`, vm). `ghost_keeps_r` now asks 15.
  **FOUND FALSE (2026-11-09): `set42_keep`, so `Hobj_cou_nt` / `Hobj_cou_t`
  and both capstones that take them are VACUOUS.** bhvPoleGrabbing's word 2 is
  SET_INT(oInteractType, POLE); words 3-4 SET_HITBOX(80, 1500); word 5 calls
  bhv_pole_init, which sets hitboxHeight from the params
  (`ObjRows.set42_pole_found`, vm on the generated script and level data). On
  a pole's first update its hitboxHeight is 100 (allocate_object), then 1500;
  no WMotR pole is either. So after word 2 obj_w's `kind_ok` (POLE: height =
  top - base) fails at the slot being updated. INV_k's ghost (Pobjl after
  every command) was not an invariant of the real dispatch loop.
  **REPAIRED (2026-11-09), a restatement with no new assumption:**
  - `ObjInv.INVk` is now STATE-INDEXED (`INV st m`: "the VM is about to run
    st"; `BhvStep` takes `INV : vst -> mem -> Prop`, keeps are same-index,
    `Hinv_succ` moves the index along a VM edge, `cou_real` returns the
    exit state with `ext st'`: it follows a BREAK-type command).
  - The POLE WINDOW `ObjInv.Wp` = bhvPoleGrabbing's states 2, 3, 5. Only
    there, and only at slot k, the ghost may differ from a full Pobjl ghost
    at slot k's oInteractType and hitbox radius / height cells (`PPk`; the
    type stays or becomes INTERACT_POLE). Every other slot and every other
    cell keeps the frame-start memory's obj_w.
  - Inside the window, SET_INT and SET_HITBOX are PROVED (`ObjRows.t_set`,
    `t_hb`, through `ObjInv.win_keep`). No other command runs there
    (`ObjInv.W_ops`, vm). `set42_keep` and SET_HITBOX's keep are asked only
    outside the window (`ObjRows.GPn`).
  - The window is left only by word 5's CALL_NATIVE bhv_pole_init. That is
    the existing `native_res` row (special scripts), which now asks the full
    ghost back: hitboxHeight = 10 * bparam2 = top - base by obj_w's new pole
    pins.
  - The loop's exit is never in the window (`ObjInv.ext_nW`, vm), so
    `ObjExit.inv_exit` gets a full ghost (`ObjInv.inv_out`).
  - Words 2-5 run once, before BEGIN_LOOP at word 8. Every later update runs
    words 9-11 (bhv_pole_base_loop) outside the window.
  - **obj_w PINS (`ObjWorld.pin_ok`, field `ow_pin`):**
    - T: an INTERACT_POLE slot runs bhvPoleGrabbing, and an
      INTERACT_CANNON_BASE slot runs bhvCannon.
    - C: a bhvCannon slot not yet CANNON_BASE sits at a level-data cannon
      entry.
    - P: a bhvPoleGrabbing slot sits at a level-data pole entry with
      hitboxDownOffset 0 and oBehParams byte 2 * 10 = top - base.
    - The pins are vm-checked (`ow_chk`) on the boot witness and after the
      real first objects phase (StartTerrain's m11 / m3 / m4). The
      intermediate window states of that first update are NOT separately
      vm-checked.
  **FOUND 2026-11-09, cannon REPAIRED 2026-11-09 (no new premise): bhvCannon's
  `addf_keep`.** Word 6 is ADD_FLOAT(oPosY, -340). `addf_keep` was asked at
  every ghost; at a legal Pobjl ghost with slot k already CANNON_BASE at the
  lid's y - 340 and its VM at the update's start, re-running word 6 leaves
  `cannon_obj_ok`. The real run is fine (posY is the lid's y before word 6),
  but the frozen ghost lost that history. Repair (the pole repair's
  pattern, with the window's end moved to word 6 instead of the exit):
  - `ObjInv.inP`: the cannon prologue (bhvCannon words 0..6). INV_k carries
    `inP s -> inP st0` (the prologue is entered only from itself:
    `P_back`, vm over `vm_tab`), and a third ghost kind: past the prologue
    the ghost may be RE-ANCHORED, slot k at `sL` = bhvCannon@7 with an empty
    stack (`GPL`).
  - `ObjRows.t_addf`: an ADD_FLOAT in the prologue is word 6, field 7, its
    one successor `sL` (`P_addf`, vm). There the ghost is GP with slot k at
    its lid's y (obj_w's pin D at index 0). `anc_keep`, PROVED in
    `ObjAnchor.anchor`: poke slot k's command cell to bhvCannon + 28
    (a Pfr-excluded VM cell; Pobjl by `ObjExit.exit_pc`, the exit's own
    keeper), then the same store of lid - 340 (vm: the float add is exact)
    into the poked ghost's oPosY, Pobjl by `CannonKeep.can_drop_pc`
    (RenderKeep's keep generalised with a re-pinned class `Qy` for a
    collided / used cannon; `ObjVmSwap.obj_w_vm_swap` with a moved oPosY,
    `Hy0`; lid - 340 + 350 and the x / z pairs are in the level lists, no
    lid is a pole base or a box's y: `CannonKeep.lid_chk`, vm).
  - `addf_keep` is now asked outside the prologue only (`GPc`: a premise
    SHRINK). The other ghost keeps are asked at the re-anchored ghost too:
    they are the same premise rows at start state `sL` (`ObjRows.gk_L`;
    the capstone's rows already quantify over every start state).
  - The exit (`ObjInv.inv_out`, `ObjExit.inv_exit`) takes either ghost;
    a cannon exits past its prologue (`ObjInv.ext_can`, vm), so pin D
    reads its offset.
  - `obj_w` / `cannon_obj_ok` / `cannon_xz_ok` needed no restatement for
    this half: the real code's heights are listed (vm, `CannonKeep.lid_chk`).
  **FOUND 2026-11-09, RESTATED 2026-11-09: cannon x-jitter.** `kind_ok`
  pinned a CANNON_BASE slot's oPosX / oPosZ to a level-data entry exactly
  (`cannon_xz_ok`), but `bhv_cannon_base_loop`'s actions 4 and 6
  (cannon.inc.c:45-62) jitter both while Mario is in the cannon, so `obj_w`
  was false in the real game there. Restated (`WMotRWorld.cannon_xz_ok`):
  x, z = an entry's x, z + d, with the SAME d for both and d in
  `cannon_jit` = {0, -1, -2, -3, -5, -7}. Read from the C: act 4 enters
  timer t with offset [0, -1, -2, -1] (t mod 4) and leaves at t = 68 with
  -3; act 6, timers 0..3: -5, -7, -5, -3; acts 5 / 1 / 2 / 3 stay at -3;
  act_0's timer-0 reset returns to 0. Every value is a small integer, so
  binary32 is exact. **This is a statement read from cannon.inc.c, not
  vm-derived**; the boot witness and the first real objects phase (d = 0)
  are checked by the existing ow_chk. Readers: no capstone path reads a
  cannon's x / z (`cannon_xz_seat` has no user; `used_ok` / `coll_obj_ok`
  read only `cannon_obj_ok`'s y). The other users are keeps (ObjWorld pin C,
  CannonKeep.xz1, ObjVmSwap, UnloadOw), and they carry d through.
  **FOUND 2026-11-09, REPAIRED 2026-11-13 (no new premise): native_res
  phantom at bhv_cannon_base_loop.** `obj_w`'s pin now carries
  `ObjWorld.can_traj`: by command-offset class, a cannon is the spawned base
  (word 0), the dropped one (word 7), or on the trajectory `traj_b` (word 8
  on): (oAction, oPrevAction, oTimer, jitter d, rise k) with oPos = oHome +
  (d, 5k, d) and oHome = lid - (0, 340, 0). Both cases below are outside
  `traj_b`. Boot and the first objects phase satisfy it (ow_chk's
  `can_traj_b`, vm). Keeps PROVED: re-anchor at words 6 / 7
  (`ObjAnchor.anchor`, `home8`).
  NOT proved: that `traj_b` is closed under the native, under
  cur_obj_update's timer / action-reset stores and under Mario's
  `oAction = 2` store; that is read from cannon.inc.c and object_list
  processing, and still asked through `native_res`, `pre_keep` /
  `post_keep` and the act rows. The original finding:
  `native_res` is asked at EVERY INV state at a special CALL_NATIVE.
  `obj_w` does not tie a cannon's oPosX / Y / Z to its oAction / oTimer /
  oHome* (act_ok bounds oAction only to [0, 7)). Two cases make it false:
  - From an INV state with the base already 69 rise steps up
    (`cannon_obj_ok` allows home + 5k, k <= 69) and oAction = 4, oTimer = 0,
    act_4 adds 5 more: home + 350 is not in `wmotr_cannon_list`.
  - With x at d = -7 and act 6, timer 0, x goes to d = -9.
  The y half predates the x / z pins (the rise list, 2026-10-24). This is
  false at phantom states only: the real run follows the trajectory above.
  The repair is a cannon trajectory invariant that pins (oAction, oTimer)
  with oPos - oHome and oHome = the lid's spawn position. Its cost:
  - new obj_w read cells: oTimer, oPrevAction, oHome*;
  - keeps for cur_obj_update's timer / action-reset stores (ObjStep), for
    SET_HOME (bhvCannon word 7, `home_keep` at the re-anchored ghost), and
    for Mario's A-gated `usedObj->oAction = 2` (act_in_cannon).
  No new assumption is needed, but it is a multi-file redesign.
  Sweep (2026-11-09, vm over `vm_tab`): among the still-asked
  per-command keeps (SET_INT, ADD_FLOAT, SUM_FLOAT, SET_RANDOM_*, SET_INT_UNUSED,
  DEACTIVATE, PARENT_BIT_CLEAR, SET_HITBOX[_WITH_OFFSET], LOAD_ANIMATIONS,
  LOAD_COLLISION_DATA, BEGIN), the only writes of a field `obj_w` reads
  (pos x/y/z, angle velocities, interact type, oAction, the hidden-star
  counter) in a special script are bhvPoleGrabbing word 2 and bhvCannon
  words 5 / 6 (both repaired); the other pos writes are in non-special
  scripts, whose slots `obj_w` does not pin by position.
  **Native VM-cell scan (2026-11-08, `NativeVmCensus.native_vm_value`, vm, spine-root),
  behind `native_vals` inside the keeps rows.** INV_k's ghost clause `nvB scr` needs the
  cells where the real memory and the ghost differ (slot k's VM cells and gCurBhvCommand)
  to hold only script pointers. The code of every live native (1429 functions, not the
  interpreter) stores into a VM field in three places only: `obj_set_held_state` (a
  script; called only from Mario's code, i.e. `native_res`), `create_object` (the spawned
  script, on the freshly allocated slot; called only by `spawn_object_at_origin`) and
  `allocate_object` (an int). No native stores the cursor, copies a whole Object, passes a
  VM cell's address, or hands an Object pointer to a builtin. **No FOUND**; the INV_k
  clause is not widened.
  `mario_hole` covers only `execute_mario_action`, not the whole `bhv_mario_update`
  native, which stays inside `rest_keeps` (`native_vals` / `native_res`).
  **Row 28 SPAWN_CHILD (2026-11-03): `row_spawn_child`, on the REAL handler.**
  `ObjChild.child_real` walks bhv_cmd_spawn_child -> spawn_object_at_origin ->
  create_object -> allocate_object / try_allocate_object, geo_obj_init and
  obj_copy_pos_and_angle on the linked bodies. The child script and its list are computed
  (`sc_w`: six reachable 0x1C states; children on lists 6 / 8 / 12, never the
  floor-snapping 4 / 5 / 10). The parent is the running slot. Three pinned premises are
  added to `row_keeps`:
  - `sc_pre`: obj_w's rings / free list / ow_part / gfx links / list-array pointer, and
    the running slot is a ring member.
  - `sc_free`: POOL EXHAUSTION, a NAMED residual. The free list is nonempty at a 0x1C
    state. With it empty, create_object returns NULL and the stores through it are stuck.
    No computed bound on live objects yet.
  - `sc_keep`: INV survives the post-state child_real proves.
  No new trust row; the link symbols come from the linked program (`sc_syms`).
  **Row 55 SPAWN_WATER_DROPLET (2026-11-03): `row_spawn_water_droplet`, on the REAL
  handler.** `ObjDroplet.wd_real` walks bhv_cmd_spawn_water_droplet -> spawn_water_droplet
  -> spawn_object (the same create_object chain as row 28) and then the droplet tail,
  covering every params flag branch. The seed callees random_u16 / random_float /
  random_f32_around_zero / find_water_level change only gRandomSeed16. The slot callees
  obj_scale / obj_translate_xz_random / obj_translate_xyz_random write only the new slot.
  Four pinned premises are added to `row_keeps`:
  - `wd_pre`, `wd_free` (POOL EXHAUSTION, NAMED) and `wd_keep`, as for row 28.
  - `wd_dp`: both reachable params (gShallowWaterSplash/WaveDropletParams) hold
    &bhvWaterDroplet at byte 4. The initializer says so (`dparams_init`) and no code
    writes them. It is batched for the StartTerrain recheck, like `ow_anim`.
  NOTE, believed unreachable in WMotR (not used by the proof): the only 0x37 scripts are
  bhvShallowWaterSplash / bhvShallowWaterWave. Their only spawn path is sParticleTypes,
  from Mario's particleFlags bits 8 / 12. Only play_sound_and_spawn_particles sets those
  bits, and only under `terrainSoundAddend == SOUND_TERRAIN_WATER << 16`.
  - WMotR's env regions are NULL (env_w, proved), so find_water_level is -11000.
  - The guard therefore needs floorHeight < -11010, but WMotR static vertex y lies in
    [-8191, 4542].
  - The other way to meet it is an sTerrainSounds entry of 2, and there is none.
  Proving the row on the real code instead makes it hold either way.
  **Row 40 ANIMATE (2026-11-07): `row_animate`, on the REAL handler.** `hd_animate`
  walks bhv_cmd_animate. `ObjAnimate.goia_real` walks geo_obj_init_animation, including
  segmented_to_virtual's real body (the identity, TRUST 2.2). The run does one of two
  things:
  - writes nothing; or
  - writes the CURRENT slot's four animInfo cells: curAnim @60 (set to animations[index],
    where animations is the slot's oAnimations), animFrame @64, animAccel @72 and
    animYTrans @58.
  Every value comes from the run itself. One pinned premise is added to `row_keeps`:
  `an_keep`, which says INV survives those stores (`an_post`). No new trust row.
  **Row 30 DROP_TO_FLOOR (2026-11-07): `row_drop_to_floor`, on the REAL handler; every
  used opcode now has its row.** `hd_drop_to_floor` walks bhv_cmd_drop_to_floor:
  oPosX/Y/Z are read, find_floor_height(x, y + 200, z) runs, oPosY gets the result and
  oMoveFlags |= 2. `ObjFloorH.ffh_foot` walks find_floor_height (a fresh local, freed)
  over `FloorList.ff_value_contract` for find_floor: no cell of the entry memory outside
  find_floor's three statics changes, and no permission changes. That footprint keeps the
  stepper's cells (none of the statics is gCurBhvCommand, gCurrentObject or the pool).
  Two premises are pinned in `row_keeps`:
  - `dtf_ff`: INV gives find_floor's entry facts (`ObjFloorH.ff_ok`: the statics and the
    partition arrays are allocated, and the partition lists are well formed and stay off
    the statics; this is ObjWorld's surface clause);
  - `dtf_keep`: INV survives `dtf_post`, which is the real run plus the two stores.
  With 30 done, `used_done` checks used_ops ⊆ done_ops by vm. `dloop_done` and `seg` lost
  their "rows not yet proved" premise: the dispatch loop needs only `row_keeps`, premises
  about INV. No new trust row.
  **W1 (2026-11-07): `BhvStep.cou_real`, the whole REAL cur_obj_update.** The body is
  checked by vm (`cou_split`) to be COU_PRE ++ [COPYIN; DLOOP; COPYOUT] ++ COU_POST.
  `EnvSwap.exec_swap` is generic Clight: a statement that never names a local runs the same
  in any two environments that agree off it. It moves the segment from the filler[4]
  environment to the empty one (`cou_nofv`, vm). Then `seg` runs in that environment.
  The function's alloc is taken through `Hinv_frame`, and its free through `inv_free`.
  The remaining premises, all about INV (still a section variable, not on a capstone):
  - `row_keeps`;
  - `pre_keep` and `post_keep`, pinned to the real COU_PRE and COU_POST statements, for
    any temps. COU_PRE sets every temp it reads. COU_POST's one inherited temp,
    distanceFromMario, only picks a render-flag branch;
  - `inv_free`: freeing a block allocated after an INV state keeps INV.
  No new trust row.
  **FOUND / REPAIR STARTED (2026-11-07): the field keeps had no script tie.** Each keep
  in `row_keeps` (set_keep, sit_keep, the arithmetic and hitbox keeps, ...) took the state
  `st` from anywhere in `vm_tab`, unrelated to the script slot k actually runs. For
  INV = "Pobjl at slot k" that is FALSE over real states. Example: bhvPoleGrabbing's
  `SET_INT(oInteractType, INTERACT_POLE)` applied to a generic slot breaks `ow_cls` (a POLE
  slot must run an sp_scripts state). Repair: a section predicate `Qs` on states, closed
  under `succs` (`Hqs_cl`). It is threaded through `cmd_row_op`, every keep, `native_res`
  / `sfr_keep`, `dloop*`, `seg` and `cou_real` (start `Qs st`, end `Qs st'`). The concrete
  Qs (slot k's script family, checked on the start witness) comes with INV_k in W2. Until
  then the keeps are still abstract premises about a section INV; none is on a capstone.
  No trust moves.
  **The concrete family (2026-11-07): `ObjFamily.Qfam s0`.** `cls s` is the 7 bits obj_w
  reads off a script: in sp_scripts, in live12, live, in pbc_ids, and whether it is
  BOXS, LIDS or COINF. `Qfam s0 st` means st's script has s0's class and is live.
  `fam_chk_ok` is a vm check over all 95 scripts: from a live script, every `succs`
  edge keeps the class. Six edges cross scripts. The two that change class start in
  cut scripts (bhvSpawnedStar, bhvObjectWaveTrail), which no slot runs. Hence
  `Qfam_closed` (= `Hqs_cl`) and the projections `Qfam_sp/_live12/_pbc/_id`. TRAP: a
  lemma stated on `cls` itself hung at Qed (the kernel unfolded the computed lists), so
  the projections are proved generic over the lists. No trust moves.
  **FOUND / REPAIRED (2026-11-07): `ObjFrame.XBn` lacked numCollidedObjs [118,120).**
  `sfr_keep` said a native on a generic slot changes only non-XBn bytes and keeps obj_w.
  That is false as stated: `ow_ncoll` reads numCollidedObjs, which was outside XBn.
  REPAIRED by adding (118,120) to XBn. Checked against the code: no live WMotR native
  writes it (the collision pass does, outside cur_obj_update), and coin formations zero
  only angle velocity. No trust moves.
  **TIE (2026-11-07): `ObjWorld.ow_tie`, obj_w's 33rd clause, checked on the start
  witness.** It is needed by the generic frame keep: a native running on a generic slot
  may write that slot's non-XBn bytes, so obj_w must not read those bytes by behavior.
  - T1: a listed slot whose behavior is in `tie_bhvs` (JumpingBox, Cannon,
    ExclamationBox, HiddenRedCoinStar) runs an sp_scripts state. These are the
    behaviors whose oAction / star counter / position `act_ok` / `red_ok` / `coll_ok`
    read.
  - T3: in a pole or cannon action (`used_acts`, Mario's action at bm 12), usedObj
    (bm 128) is a slot running an sp_scripts state. `used_ok` reads that slot's posY /
    hitbox.
  - Checked by vm in `ow_chk` (`tie_b`, sound by `tie_b_sound`).
  - Keepers: `PollKeep.obj_w_slots_c` (behavior / VM cells are slot fields) and
    `UnloadOw` (`sp_vm_all` covers the freed slot too).
  - Bm 12 joined the `Kbm` lists, so the labeled camera residual `Hcam_ow_res` now also
    claims the camera keeps Mario's action. Its only camera writer is
    `set_mario_npc_dialog`'s `set_mario_action`, which is outside the live closure over
    cam_w states (`CamCutCensus.uc_wmotr`), the same reason as usedObj.
  - Phantom check: only interact_pole / interact_cannon_base enter those actions, with
    usedObj the POLE / CANNON_BASE object, which `ow_cls` already ties to a special
    state. A spawn sets behavior and script together, and VM steps keep the class.
  - T2 (gMarioPlatform runs a special script) was rejected: FALSE in a real state.
  - Not yet kept by the spawn path; that is part of the generic frame keep.
  **RenderKeep KEEP generalized in place (2026-11-07).** The PhiW keep (`k_all_wc` and
  its parts) now takes TYPE-ONLY objects `Qt` beside the whole-kept far objects `Q`:
  - A collided object may be `Qt`. Only its interactType cell must be kept (`LDt`), and
    that type is neither POLE nor CANNON_BASE (`QtT`), so `coll_obj_ok` reads nothing
    else of it (`coll_keep_t`).
  - `QU` asks usedObj to be `Q` only in a pole / cannon action, the only actions in which
    `used_ok` reads it.
  - Older callers (KEEPQ, CollKeep) take `Qt := fun _ => False`.
  - Purpose: the generic frame keep, where a native on a generic slot (possibly
    Mario's collided object or his usedObj outside those actions) changes the slot's
    non-XBn bytes. No trust moves.
  **`ow_scr` (2026-11-03): `scr_ok` is an obj_w clause.** `ObjWorld.scr_ok` (moved from
  BhvStep, which keeps its names as notations) is obj_w's 21st clause; the boot witness
  checks it by vm inside `ow_chk` (`scr_b_l` over the reachable scripts, at m3 / m4 / m11).
  Every keeper re-proved: `PollKeep.obj_w_slots_s` (and `obj_w_slots` / `obj_w_unch` /
  `obj_w_unch_s`) take "no script block changes" from the footprint (`OW.scr_ok_ext`);
  `fx_obj_w` from the footprint list avoiding the scripts (vm, `avoid_of`); the camera from
  `CamRows.cam_scr_globals` (no script is a cf_FP / cf_XP global or a pin, vm); the
  platform and render calls from their global footprints. Phantom check: nothing in the
  game stores through a script pointer (`RoCensus.ro_deep_no_store`), so the clause holds
  on every reachable memory and adds no unreachable state. The labeled object rows
  (`Hobj_*`) now also claim `scr_ok` after the step: TRUE, the same census. No trust moves.
  **FOUND + REPAIRED (2026-11-03, `ObjWorld` 3e): `Hobj_unload` was FALSE over memories
  obj_w allowed** (phantom ∀; both capstones assumed it). The real
  `unload_deactivated_objects_in_list` frees any listed slot whose ACTIVE bit is clear, ORs
  0xFF00 through a type-1 / type-2 slot's `respawnInfo`, and relinks graph nodes through
  `prev->next`, `next->prev`, `parent->children` (graph_node.c:525-577). obj_w allowed
  (a) Mario's slot with ACTIVE clear (freed: MARIO and PhiW break), (b) a respawnInfo aimed
  anywhere (gMarioStates, a list head), (c) graph links aimed anywhere. Three new obj_w
  clauses, each vm-checked on the real boot memory (m11, `StartTerrain`; the probe read
  Mario = slot 34, activeFlags 257, all 240 nodes in one ring under gObjParentGraphNode):
  **MACT** (`ow_mact`): Mario's slot has ACTIVE and runs bhvMario (curBhvCommand and every
  pushed bhvStack cell in bhvMario's block; TRUTH: the clearers are DEACTIVATE, in no
  bhvMario command, and obj_mark_for_deletion, on no WMotR path to Mario's object);
  **RESP** (`ow_resp`): a listed slot's respawnInfoType is an int, type 1 aims at
  gPlayerSpawnInfos+16 or one of the area's 8 SpawnInfo behaviorArg cells in the main pool,
  type 2 at a WMotR macro entry's params word (TRUTH: written only by allocate_object (NULL),
  spawn_objects_from_info and spawn_macro_objects, the last two at area load);
  **GFX** (`ow_gfx`): all 240 slot nodes (free ones too) have parent &gObjParentGraphNode and
  slot-node prev / next, the parent's children NULL or a slot node (TRUTH: clear_objects
  sets it; the in-play relinkers try_allocate_object / unload_object remove then re-add
  under gObjParentGraphNode, keeping the shape; geo_make_first_child and gMirrorMario's
  links run only at spawn / area load). Keepers: `PollKeep.SKp` now also covers slot words
  [4, 16) (every prover re-checked: mplat's hole [532,536), render's [64,72) are apart), and
  `ow_ids` gains gObjParentGraphNode (every avoid_of / footprint check re-run by vm).
  Grep check: no PhiW / ffw / mobj_apart / anim_apart clause reads Mario's object at [4, 16)
  (the owin carve-out unload will need). **SCRIPT narrowed (FOUND, the objects agent):**
  `live_bhvs` is now `reached_bhvs` minus the 13 behaviors `BoxCensus.wmotr_closure_b` never
  reaches (koopa shell, its flame, the caps etc.; `live_in_closure_b` / `cut_not_closure_b`
  / `flame_not_live`, vm), so a live slot never runs bhvKoopaShellFlame (INTERACT_FLAME,
  outside `wmotr_interact_types`). No trust moves: stronger invariant, boot-checked.
  **FOUND + REPAIRED (2026-11-03, `ObjWorld` 3f): `Hobj_unload` was still FALSE over
  memories obj_w allowed** (phantom ∀): `set_object_respawn_info_bits` ORs 0xFF00 into a
  SpawnInfo behaviorArg cell of the main-pool block P (offsets 2336..2560, `ow_resp`), and
  nothing pinned where m->wall / m->ceil / m->floor point (PhiW's ffw asks only a dynamic
  block off the frame's regions, and P is one). A memory with m->floor = P + 2338 (its s16
  type reads the low half of a behaviorArg, 0, a WMotR type) met every premise, and the OR
  breaks `wmotr_world`'s surface_ok. **MSURF** (`ow_msurf`): each of the three cells is
  NULL, or points into a block other than P, or into P at a surface-pool slot (`in_sp`).
  TRUTH in play: the cells take only find_floor / find_ceil / find_wall_collisions results
  or NULL, and every surface, static ones included, comes from `alloc_surface`'s
  sSurfacePool = P + SP_OFF (the in_sp arm). The other-block arm is the boot witness's:
  `StartTerrain.s_chain` set m->floor to the 48-byte stand-in block bs, not a find_floor
  result (the boot probe read wall = ceil = NULL, floor = bs + 0), so an in_sp-only clause
  failed the vm check at m11; the clause asks "not loose in P", true of both. (2026-11-03:
  the witness now runs the real entry and its floor is find_floor's hit, P + 112592, an in_sp
  slot; the other-block arm is no longer needed by the witness, and tightening the clause to
  in_sp / NULL is open.) Keepers:
  Mario's cells 96 / 100 / 104 join the `Kbm` lists (`PollKeep`, the 5 slot-keep theorems)
  and the camera's labeled residual `Hcam_ow_res` (set_mario_npc_dialog's cutscene arm
  writes none of them). The writers of the cells in play are Mario's own step (the open
  `Hobj_step_act_*` rows, which now also claim the clause after the step: TRUE, the
  allocator above) and nothing else on the spine (the platform code writes Mario's
  position; render, poll and level code do not touch them).
  **PAR (2026-11-03, `ObjWorld` 3g, for the objects agent's PARENT_BIT_CLEAR row 51):**
  `ow_par`: every slot's parentObj (offset 104) is NULL or a slot node, and a listed slot
  running one of the twelve PARENT_BIT_CLEAR scripts (`pbc_ids`, tied by vm to BhvVM's
  opcode-51 filter, `pbc_ids_ok`) has a slot parent. TRUTH: parentObj is written by
  spawn_object (the spawner, a slot), spawn_objects_from_info (the object itself) and the
  macro spawner; the boot probe read every one of the 240 parents NULL or a slot (no
  &gMacroObjectDefaultParent survives to m11); the twelve particle spawners are spawned
  only by Mario's code with parent gMarioObject. Kept by every slot keeper (`SKp` covers
  slot words from 96). No trust moves: stronger invariant, boot-checked.
  **FOUND + REPAIRED (2026-11-03, `FfWorld.cam_si`): the Camera could sit on a SpawnInfo
  cell.** `cam_w`'s R3 kept the Camera apart from the surface pools only, so a Camera
  overlapping one of the 8 SpawnInfo behaviorArg cells of P (`ow_resp` type-1 targets,
  `CAM_SI`) met every premise, and unload's 0xFF00 OR would then change some Camera field.
  In the real game the Camera and the SpawnInfos are separate main-pool allocations. New
  conjunct of `cam_w`: the Camera's 108 bytes are disjoint from every cell in `CAM_SI` of
  the block sSurfacePool points into. Checked by vm at m11 (`StartTerrain.pin_chk`,
  `StartSat.pin11`); kept by `cam_w_unch` (sSurfacePool is a cam global). No trust moves:
  stronger invariant, boot-checked.
  **DP (2026-11-03, `ObjWorld` 3i, for the objects agent's SPAWN_WATER_DROPLET row):**
  `ow_dp`: the two droplet parameter structs hold &bhvWaterDroplet at byte 4. TRUTH: their
  initializers say so and no code writes them. Checked by vm at m11 (`ow_chk`); kept since
  both globals join `ow_ids`. No trust moves.
  **NCOLL (2026-11-03, `ObjWorld` 3j):** `ow_ncoll`: every listed slot's numCollidedObjs is
  in [0, 4]; `ow_mcoll`: Mario's collidedObjs[0..3] are NULL or slots. TRUTH: the writers are
  allocate_object and clear_object_collision (0) and detect_object_hitbox_overlap (++ after
  its two `>= 4` tests; it stores only objects of walked lists). Checked by vm on the boot
  witness (`ow_chk`); kept by every slot keeper (`SKp`, offsets 118..136). Grep: no PhiW
  clause reads an object's oIntangibleTimer (offset 156), which clear_object_collision
  decrements. No trust moves.
  **Unload (2026-11-03): `Hobj_unload` narrowed to two rows.** The real
  `unload_deactivated_objects` (its loop over the order table, `gTimeStopState &= ~1`, the
  frame block filler[4]: `UnloadKeep.unload_outer`) and the real
  `unload_deactivated_objects_in_list` (`UnloadLoop.inlist_ok`) are PROVED over Pobjl
  (`HeightFrame.obj_unload_linked12`, `UnloadRows.inlist_keeps`), with the
  `gCurrentObject = obj` store (a slot pointer; the pool is SafeB) and the respawn OR into
  gPlayerSpawnInfos+16 or a WMotR macro entry (int stores into globals no clause reads, by
  vm). Open: `Hobj_unload_si` (`UnloadRows.si_row`: the respawn OR into a SpawnInfo cell of
  the main pool block keeps the invariant) and `Hobj_unload_obj` (`UnloadRows.unl_row`: the
  real `unload_object` on an inactive slot of a walked ring keeps it). The tool for the
  second: `UnloadSharp.unload_sharp_real`, the real body with the freed slot changed only
  at activeFlags, prevObj, throwMatrix and the node flags (offsets read off the generated
  body by vm), plus the graph / list links and the sound blocks. `RenderKeep`'s keep now
  takes a set Q of far objects (`owinq`), so a step that rewrites every slot's links can use
  it. No trust moves: the two rows are narrower than the one they replace, and every
  premise is Pobjl.
  **Unload, second step (2026-11-03): `Hobj_unload_obj` is PROVED except gMarioPlatform's
  fact** (`UnloadPc.unl_row_proved`). From the real `unload_object`: mem_ok by the SafeB
  world (`SpawnBodies.sr_unload`); PhiW by `RenderKeep.k_all_lvl_wq` (the call writes the
  list heads, the free list, the parent node, the sound blocks, and in the pool only slot
  fields below 136; Mario's slot is active, so it is not the freed one; his collided objects
  and usedObj are slots, `ow_mcoll` / `ow_stale`); lvl_w by `lvl_w_unch_na` (every sound
  block lvl_w reads is an audio block, by vm); obj_w by `UnloadOw.obj_w_unload`; the call's
  permissions by `PermWalk.pk_body` over its whole call tree. plat_still after the call is
  PROVED since 2026-11-06 (the row `Hobj_unload_plat` is gone, see the repair below).
  **FOUND (2026-11-03, phantom forall in plat_still):** `PlatformKeep.plat_still` lets
  gMarioPlatform point anywhere in the pool block. A misaligned pointer's checked cells
  (+276 .. +288) can overlap a slot's list or graph links, which unload_object rewrites, so
  the row is false over such states. In the game gMarioPlatform is NULL or a slot
  (update_mario_platform takes it from a floor's object). **REPAIRED 2026-11-06:**
  `plat_still` now pins the pointer to a slot (`PlatformKeep.plat_al`: offset j*608,
  j < 240), checked at boot (`StartTerrain.plat_still_b`), re-made by update_mario_platform
  from the floor's slot (`MplatKeep`). gMarioPlatform is untouched by unload_object and a
  slot's +276..+288 is outside every byte it writes, so plat_still carries (`UnloadPc`).
  **Unload, last step (2026-11-06): `Hobj_unload_si` is PROVED** (`UnloadSi.si_row_proved`).
  The respawn OR writes an int into a SpawnInfo cell of the main pool block P, below the
  node pool (SI cells < 2640 <= NP_OFF). Every other block is unchanged, and every reader
  of P misses the cell: list nodes and surfaces are pool slots at or past NP_OFF
  (`ObjWorld.surf_obj_ok`), Mario's surfaces are off P or surface slots (`msurf_ok`), the
  Camera is off the SI cells (`cam_si`), and no frame region or anim table is P (each
  holds no partition surface, and P does). mem_ok by `ClearKeep.safe_store_dyn`. No new
  clause and no trust moved: `Hobj_unload` has no row left.
  **Indexed handler arguments (2026-10-26, B3 iii-a, `BhvVM`).** These are vm-checked at
  every reachable state:
  - The field commands index `o->rawData.asU32[0x50]` (`vm_fields_in_rawdata`): every field
    byte is < 0x50. That covers SUM_FLOAT / SUM_INT's three fields and PARENT_BIT_CLEAR.
  - The SET_MODEL / SPAWN_* model ids index `gLoadedGraphNodes` = `D_8033A160[0x100]`
    (`vm_models_in_table`): every id is in [0, 256).
  **FOUND (vacuity): the bob-omb buddy's animation table is not linked.** WMotR places
  `bhvBobombBuddyOpensCannon`. Its script loads `bobomb_seg8_anims_0802396C` into
  oAnimations and runs ANIMATE(0). `geo_obj_init_animation` then loads `animations[0]`. In
  the link that table is only behavior_data's size-0 extern: no TU defines it
  (the census at the time). So a frame in which the buddy updates had no Clight derivation
  in our link, and a frame statement over the real object set was vacuous there. The same
  class of gap was the earlier `gMarioAnims` one. The toad, peach and bowser-key tables are
  the other ANIMATE / LOAD_ANIMATIONS users in the closure, and none of them is placed in
  WMotR. **REPAIRED 2026-10-26** under the link-down policy. The level-data TU links the
  vendor anim `.inc.c` files of all five tables, and the 2.4 level-data rule completes their
  declarations. A systematic census now guards the class:
  - `BhvVM.closure_data_linked`: every global variable in the WMotR closure (anim tables,
    collision meshes, model / geo pointers, dialog, trajectories, hitboxes, as the
    closure's bodies and scripts name them) has a definer in the link with a non-empty
    initializer.
  - `vm_data_args_linked`: every LOAD_ANIMATIONS / LOAD_COLLISION_DATA /
    SPAWN_WATER_DROPLET argument at a reachable VM state is such a symbol.

  Both are fail-closed vm checks over `ObjTable.lprogs`.
  **FOUND (non-vacuity guard too weak): the boot witness holds only Mario.** The witness's
  object world (`StartSat.objects_runs`) comes from `clear_objects` plus Mario's spawn. None
  of the objects WMotR places (the bob-omb buddy, the cannon, the wing-cap boxes, the poles)
  is spawned there. So the one real `area_update_objects` run at the witness exercises Mario
  alone, which is how the unlinked anim table went unnoticed. **REPAIRED 2026-11-02 (Step B,
  3.6):** the witness runs the level script's OBJECT commands through the real
  `level_cmd_place_object`, `load_area_terrain` with WMotR's macro list (the real
  `spawn_macro_objects`: 26 macro objects) and the area's spawn infos through the real
  `spawn_objects_from_info`; Mario lands in slot 34 (`StartTerrain.MARIO_OFF` = 20672). The
  witness's object lists hold the bob-omb buddy, both cannon lids, the seven exclamation boxes,
  the six poles, the red coins and their star, the 1-ups and the coin formations
  (`ow_chk` passes on them), and one whole real frame runs from it (`StartSat.frame_runs`).

- **Level phase (2026-10-24): real code.** `seg_level_pre_spec` / `seg_level_post_spec` are
  `exec_stmt` of the generated `play_mode_normal` body's slices before / after its
  `area_update_objects` call (`LevelFlank.level_pre_call` / `level_post_call`; frame order now
  poll ; PRE ; platform ; action ; objects ; POST ; render walk). Proved (`LevelKeep.pre_keeps` /
  `post_keeps`): mem_ok, the held-A bit (PRE) and PhiW carry. Walked: the demo guard, `warp_area`,
  `check_instant_warp`, `initiate_painting_warp` (no-ops under the pins), the timer,
  `update_hud_values`, `initiate_delayed_warp`, the play-mode switch (`LevelWalk`: writes only the
  `level_gvars` blocks and Mario's numCoins / numLives). Stated (labeled):
  - No pins premise: the warp cells the PRE reads are `FfWorld.warp_w`, part of PhiW's `lvl_w`.
    The instant / painting warps are not pinned: Mario's floor type (`wmotr_world`) rules them
    out (`LevelFlank.floor_safe`; `get_painting_warp_node` walked to NULL).
  - `update_camera(gCurrentArea->camera)` keeps mem_ok: PROVED (`LevelKeep.cam_mem_ok`, by
    `update_camera_ok_linked12`, the real camera.c). Its argument is SafeB because gCurrentArea
    points into gAreaData (`FfWorld.area_w`, carried, proved at boot), a SafeB symbol, so MWF's
    chase step gives the rest.
  - `Hcam_phi` (`LevelKeep.cam_phi_row`): the `update_camera` statement, between mem_ok states,
    keeps PhiW and Mario's wall / ceiling / floor cells. Not a clobber spec: the main-pool Camera
    struct shares its block with the surface pool, and `RenderKeep.k_all` keeps whole blocks. The
    writes it must cover are `UpdateCameraBody.uc_census`'s out-of-class ones: gTimeStopState,
    sCutsceneVars, gCameraMovementFlags, gSecondCameraFocus's object, Mario's action
    (set_mario_npc_dialog), and the audio / dialog / sCameraHUDStatus / gRandomSeed16 /
    find_floor-counter globals.
    Gates, MACHINE-CHECKED since 2026-10-26 (`WMotRRequiresA/CamCutCensus.v`, no FOUND):
    - `uc_wmotr`: update_camera's closure, with sCutsceneEnterBowserArena,
      sCutscenePyramidTopExplode and sCameraTriggers cut off, has 428 functions. It contains no
      `set_mario_npc_dialog`, and its only store through gSecondCameraFocus (an object) is
      init_camera's LEVEL_BOWSER_1 arm, dead in WMotR. Uncut (530 functions) it has both.
      WMotR's trigger entry is NULL (`CamIdxCensus.trig_census`).
    - `cut_census_wmotr`: link-wide, no live code stores 144 or 168 into `Camera.cutscene` /
      `sObjectCutscene`. Every source is a constant, a cutscene cell, or the dance table, whose
      nibbles pick the five dance cutscenes (`dance_tables`). 168 is never stored; 144 is stored
      only by init_camera's three Bowser-level arms (`cut_raw`), dead under `lvl_w`.
    - `tables_read_only`: the cutscene arrays, the trigger, dance and mode tables are only read.
    So no WMotR object, Mario-status or area trigger starts either cutscene, and the tables keep
    their boot contents. **What stays open, narrowed:**
    - (a) CARRY `Camera.cutscene, sObjectCutscene ∉ {144, 168}` across the frame: DONE
      2026-11-01. `FfWorld.lvl_w` has a seventh clause `cam_w`: sObjectCutscene's byte and the
      byte at gCurrentArea->camera + 0x30 are neither 144 nor 168. The Camera is past every
      global and is not the animation buffer's block. It is proved at boot from the witness's
      real Camera (`StartTerrain.cut_chk` inside `cam_frame_ok`, read back by `StartSat.cam11`).
      Every proved keeper carries it. `lvl_w_unch` now asks for the `lw_blk` blocks
      (`lvl_ids`, `cam_ids` = sObjectCutscene / gAreaData, and the Camera) and gMarioAnimsBuf's
      cell 8. The footprint keepers check `lvl_rd_ids` by vm; the Mario rows pass their `CL 8`
      cell. The level phase no longer lists sObjectCutscene among its written globals: its
      only path there, reset_dialog_render_state's `trigger_cutscene_dialog(2)`, stores
      nothing. `LevelWalk.tcd_noop` proves this from the generated body, and the walker
      accepts the constant-argument call (`tcd_skip_ok`). `Hcam_phi` assumes cam_w in PhiW and
      claims it after, and `Hcam_ow_fp` (was `Hcam_ow`) assumes it.
      Both rows were then believed TRUE in the game and only unproved. **They are FALSE as
      stated (unpinned, found 2026-11-02, see (b'))**. The
      objects-phase rows (`Hobj_*`, over Pobjl ⊇ PhiW) also claim cam_w after: true by
      `cut_census_wmotr`, which is link-wide.
    - (b') **FALSE AS STATED: `Hcam_phi` and `Hcam_ow_fp` are unpinned (found 2026-11-02 by the
      R1 walk).** update_camera stores through `sMarioCamState` / `sLuigiCamState` and, on the
      Bowser arm, through `gSecondCameraFocus`. Neither mem_ok nor PhiW says where these point.
      So the rows quantify over states (phantom ∀) where `sMarioCamState` aims at Mario's
      floor / wall cells, a PhiW global or an `ow_ids` block, and the camera breaks the claim
      there. In the game they are `&gPlayerCameraState[0]`, `&gPlayerCameraState[1]` and NULL.
      `WMotRRequiresA/CamPinCensus.v` proves from the generated AST, over all linked TUs, that
      the initializer is the only writer of the three.
      **Fix plan (the deferred rebuild, with R3 and B'' (b)/(c)):**
      - `cam_w` gains the pins: sMarioCamState / sLuigiCamState = `&gPlayerCameraState[0/1]`,
        and gSecondCameraFocus = NULL. They are proved at boot and kept by every phase.
      - Both rows are restated on `CamFootInst.update_camera_foot` (R1, below).
      - **R1 (PROVED 2026-11-02, `WMotRRequiresA/CamFootInst.v`; on the spine since step (a), below).** The
        real `update_camera(c)`, with c the Camera or NULL, run from ANY memory whose five pins
        hold (gCamera, sMarioCamState, sLuigiCamState, gSecondCameraFocus, gMarioState), does
        three things:
        - it changes memory only in the blocks of `cf_FP`'s 115 globals, the Camera's 108
          bytes and the pin cells;
        - it keeps every permission;
        - it keeps the pins.
      - **How R1 is proved.** All 503 bodies of the all-states call tree pass a byte-level
        store-class walk (`CamFootKit` / `CamFootSound`: the classes are listed globals, the
        Camera range, and fresh blocks), with no pruning. The five AVOID_UB vec helpers are
        proved (`shadow_leaf`), and sqrtf comes from 3.5.
      - **R1's leaves.** `load_sequence` used `LsContract.ls_frame` (4.1; since step (a) the scoped `ls_frame_ai`; ls_frame is FALSE
        unscoped, being restated). The two former open leaves (`Hopen`) are PROVED
        (2026-11-02), so R1 has no open premise beyond the pins and the floors (3.5, and
        4.1 via ls_frame):
        - `save_file_do_save` (`CamFootSave.sds_foot`, any argument): its whole tree is walked
          by `FootWalk` (SaveDoSaveBody's recognizers over a listed footprint), down to the
          3.5 floor calls; FootWalk's floor list gained `osSetTimer(&__osEepromTimer)` and
          `bcopy` (both already in 3.5). Permissions via `PermWalk`. It writes only
          `sds_gvars` (save buffer, two dirty flags, EEPROM PIF image / last command, SI
          access and event queues, EEPROM timer, queue and message); those 10 extra globals
          joined `cf_FP` (105 -> 115).
        - `set_mario_npc_dialog` (`CamFootNpc.npc_spec`, any argument): walked under the pins
          with a three-body sub-table. Its `set_mario_action` call passes the LITERAL
          `ACT_READING_NPC_DIALOG`; `sma_prune` proves the real body's run equals the run with
          the switch's moving / airborne / submerged arms emptied (same selected suffix), so
          only the cutscene arm is walked. This is an argument-constant specialization of
          one call site, not a state pruning.
      - **DONE (the rebuild, 2026-11-02): `cam_w` is pinned, both rows TRUE AS STATED, still
        labeled.** `FfWorld.cam_w` now has, besides the cutscene bytes:
        - the pins (`cam_pins`): gCamera aims at the Camera; sMarioCamState / sLuigiCamState
          aim into gPlayerCameraState; gSecondCameraFocus holds no pointer;
        - R3: the Camera's 108 bytes are apart from `sSurfacePool` (2300·48 bytes) and
          `sSurfaceNodePool` (7000·8), the sizes `alloc_surface_pools` allocates;
        - and `lvl_w` has an eighth clause `aud_w` (= `AudioInv`, row 4.1).
        Every proved keeper carries them. They are PROVED at boot on the real-order witness:
        `StartTerrain.pin_chk` (inside `cut_chk`, at m11; vm) and `StartSat.pin11` / `cam11` /
        `aud11`. The same check exports the surface counters (`ObjWorld.ctr_ok`, `ctr11`)
        and gTimeStopState = 0 (`ts11`) at m11. `Hcam_phi` and
        `Hcam_ow_fp` keep their statements; under the new PhiW they range over no state the game
        never produces, so they are TRUE as stated. Each row's comment in `HeightFrame.v`
        carries the phantom check (pins, R3, aud_w) and cites `update_camera_foot` as
        EVIDENCE, not proof: `update_camera_foot` assumes the unscoped `LsContract.ls_frame`
        (4.1, FALSE as stated), so it stays OFF the spine.
      - **STEP (a) DONE (2026-11-02): the walker carries AudioInv; `update_camera_foot` is on
        the spine (via `CamRows`); the object-world globals' half of `Hcam_ow_fp` is PROVED.**
        - `CamFootSound`'s walk now carries an invariant `Inv` (kept by every change outside
          the walk's own store targets) and lets LEAVES change an extra list of globals `XP`.
          `CamFootInst` instantiates `Inv := AudioInv`, `XP := cf_XP` = the five audio
          globals (`LsContract.ls_ids`), which left `cf_FP` (115 -> 110): no walked body stores
          into them (vm, 496 bodies). The seven sequence-player bodies that do
          (fade_to_zero / normal / target / percentage, `func_8031D690`, `play_sequence`,
          `begin_background_music_fade`) are leaves now, walked from their real bodies by
          `AudioWire` (`cai_*`, footprint `cam_aud_ids` within `cf_FP` + `cf_XP`, AudioInv per
          store); `load_sequence` is the scoped `ls_frame_ai` (4.1). `CamFootInst` no longer
          uses the unscoped `LsContract.ls_frame`.
        - `CamRows.cam_foot_step`: the camera STATEMENT (`LevelFlank.cam_step`) from a
          cam_w + AudioInv state changes nothing, or only the `cf_FP` / `cf_XP` globals, the
          Camera's 108 bytes (past every global) and the pin cells, and keeps AudioInv.
          `CamRows.cam_ow_globals`: no `ow_ids` global is among them, so their blocks are
          unchanged. `HeightFrame.Hcam_ow_fp` is now a LEMMA from it and the narrower labeled
          row `Hcam_ow_res` (both capstones take `Hcam_ow_res`).
        - `CamRows.cam_surf_keep` (2026-11-03): the surface clause `ObjWorld.surf_obj_ok` is kept.
          It reads only its globals (`ObjWorld.surf_gids`), the two pools' ranges of their block
          and the listed slots' angle velocities (`ObjWorld.surf_obj_ok_ext`); `cam_fp` carries
          R3 for the Camera it names, so the Camera's 108 bytes miss both ranges.
        - Fix on the way: `cam_w`'s Camera cell was read at the integer `o + 36`, not the
          code's pointer sum `Ptrofs.add o 36` (different cells when o wraps); it is the
          code's address now (`FfWorld.cam_w`, `cam_cb`, boot `StartSat`).
      - **The residual row `Hcam_ow_res`** (labeled, 0.7; Mario's cells only since 2026-11-03):
        - Mario's five object-pointer cells: gMarioStates is a `cf_FP` global only for the
          `set_mario_npc_dialog` leaf (no walked body stores into Mario's block, probe), which
          stores `usedObj` (128). Phantom check: under cam_w the dialog cutscenes are outside
          the live closure (`CamCutCensus.uc_wmotr`). A value fact, not a footprint fact.
        - Mario's action (bm 12, since 2026-11-07, for `ow_tie`'s T3): the leaf's
          `set_mario_action` is its only camera writer, dead under cam_w for the same reason.
        - (was) `surf_keep`: **FOUND FALSE AS STATED (phantom ∀, 2026-11-02); REPAIRED
          2026-11-03.** The Camera may share the main-pool block with the surface lists; R3
          keeps its bytes off the two pools' ranges, but `ObjWorld.surf_obj_ok` let a partition
          list's nodes lie anywhere in a dynamic block, so over Φ states whose nodes sat inside
          the Camera's bytes the camera's own stores broke the walk. Repair: `surf_obj_ok` now
          names the pools' block P (both pool pointers) and bounds every node to
          `[NP_OFF, NP_END)` at stride 8 and every surface to `[SP_OFF, SP_END)` at stride 48
          (`swalk` / `surf_obj_at`); the boot witness checks it by vm (`surf_b` in `ow_chk`, at
          m3, m4 and m11). Phantom check: alloc_surface_node / alloc_surface hand out exactly
          those slots (surface_load.c:41-71), so the bound drops no reachable state. The
          conjunct is PROVED (`CamRows.cam_surf_keep`) and left the row.
      - **`Hcam_phi` stays labeled.** PhiW reads cells INSIDE the camera footprint whose values
        the camera changes in the game: the Camera's own bytes (cam_w's cutscene byte), cf_FP
        globals PhiW reads (sObjectCutscene; gMarioStates via the npc leaf) and non-global
        main-pool data beside the Camera (R3 bounds only the surface pools). Deriving it needs
        value facts about those writes (`cut_census_wmotr`'s) and a Camera-apartness clause
        for every main-pool region PhiW reads. What would discharge it (2026-11-03): carry
        cam_w's `cut_ok` on the cutscene byte and sObjectCutscene as the walker's invariant and
        check each store into them against `cut_census_wmotr` (no live store writes 144 / 168),
        with the walk cut to the live closure `uc_wmotr` (which also drops the
        `set_mario_npc_dialog` leaf); the same pool-range bound in PhiW's other main-pool
        clauses (wmotr_world's surfaces, collision data), then R3 keeps them.
    - (b) a FOOTPRINT walk of update_camera's 428-function WMotR closure. UcKit walks all 507
      bodies for mem_ok, through type certificates, so it cannot prune (a)'s cutscenes. The
      footprint for `Hcam_ow_fp` is the camera, audio, dialog and hud globals of `uc_census`, plus
      the Camera's pool block; none of these is a `PollKeep.ow_ids` block or gMarioStates. For
      `Hcam_phi`, add Camera bytes disjoint from the frame's surface regions.
  - `surf_apart` over `level_gvars`: PROVED from Φ since 2026-10-26 (`RenderKeep.phiw_surf_apart`).
  - `warp_w` at the POST's end: PROVED (2026-10-26, `LevelWarp.tail_warp_w`; no longer in
    `seg_level_post_spec`). The tail writes `sWarpDest` / `sCurrPlayMode` /
    `gCurrCreditsEntry`. Walked from the generated bodies, from `warp_w` at the tail's start:
    - `initiate_delayed_warp` (`LevelWarp.idw_Q`): when it fires, the debug / GAME_OVER /
      CREDITS_END / DEMO_NEXT arms end in `warp_special` (mode CHANGE_LEVEL). The demo arm is
      dead (gCurrDemoInput NULL). The default arm calls `initiate_warp` (sWarpDest only), then
      reads type CHANGE_LEVEL or calls `level_set_transition(2, NULL)`.
    - The play-mode switch then leaves NORMAL mode unless the type is NOT_WARPING.
    - Each callee's footprint comes from the walker at narrower lists (`lvl_safe_gvars`, plus
      one warp cell).
    The earlier FOUND (a ∀-row is false: a credits op sets a credits entry) is repaired by a
    fifth `warp_w` clause: the pending `sDelayedWarpOp` is no credits op (0x17 / 0x18). The
    clause is proved at boot (`StartSat.warp11`: the op is 0). The only C writer of
    `sDelayedWarpOp` in a frame is `level_trigger_warp` (the other stores reset it to NONE on
    level load). All its callers are Mario code; no object behavior calls it. Who carries the
    clause, per stage:
    - level phase: PRE by `LevelKeep.lvl_w_safe` (the cell is not in `lvl_safe_gvars`); POST
      by `LevelWarp.tail_warp_w` (the cell is not in `level_gvars`);
    - proved Mario rows (the airborne / automatic cases, the pole, cannon, ledge and render
      rows): they write no `lvl_ids` cell (`AnimKeep.lvl_w_keep` / `lvl_w_keep_ne` →
      `FfWorld.lvl_w_unch`). The airborne death call (`act_lava_boost`) is not a no-A case
      (`AirSplit.air_case_list`), and no R_noA action is submerged (`NaSplit`);
    - Mario's open rows `HeightFrame.Hseg_na_open` (`NaSplit.na_open_rows`: `seg_okR` ends in
      `fworld`, so it claims the clause). Every remaining call is here: death in
      `update_mario_inputs` (mario.c), the warp floor in `mario_process_interactions`, and the
      stationary / cutscene dispatchers (death, star exit, door, teleport, the credits ops).
      Whoever discharges these rows must show the op is not 0x17 / 0x18;
    - objects phase: the labeled `Hobj_*` rows claim it (Φ ⊇ lvl_w). No object writes the cell;
      Mario's hole there is filled by the Mario rows above.
    It holds in the game: only the ending's Peach / credits actions (mario_actions_cutscene.c
    1935 / 2492 / 2631) start those ops, and none runs in WMotR. `act_disappeared` passes
    `actionArg >> 16`, which is 0 or WARP_OBJECT.
  FOUND: `update_hud_values` also clamps numCoins (bm 168), not only numLives; `sWarpDest` and
  `gCurrCreditsEntry` were missing from `CensusV2.stored_globals` (they receive pointers), so
  R7's ∀ over SafeB blocks quantified over them (fixed).
- **ASSUMED, labeled** (poll, objects). Specs, not proofs: that code is not linked. Since 2026-10-20 Φ here also
  contains `FfWorld.ffw` (0.6), so each flank also keeps memory closed by an injection mapping the
  globals and Mario's state block (a fact of the semantics for any Clight code,
  `ClightClosed.funcall_closed`, so it becomes a lemma when the flank is linked), keeps `m->wall` /
  `m->ceil` / `m->controller` off the walk's regions and Mario's collided objects in his object's
  block, leaves `m->animList` / `bufTarget` / `marioObj` and the collision partition as ffw says
  (object updates reload WMotR's surfaces), keeps m->input's A bits clear, and keeps floorHeight a
  refresh of y (no WMotR flank moves Mario). The censuses behind the load clauses:
  `docs/goal2-frame-boundary-scout.md`, `goal2-wmotr-behavior-census.md`. The carries are stated
  *inside* the specs because as separate ∀-rows over every memory matching the load clauses they
  would be false.
- **Render flank (2026-10-22).** The frame now ends rest ; Mario's render call ; rest, where the
  middle segment `seg_render_spec` is the **real** `geo_set_animation_globals` call on Mario's
  `&marioObj->header.gfx.animInfo` (`RenderFlank.render_call`, on the linked genv;
  rendering_graph_node.c is TU 35) or no call (Mario not drawn). Its GOAL-1 carry is **proved**:
  `RenderFlank.render_mem_ok` (valid bm, the action cell, `MWF_real`) from the walked footprint
  (`RenderSet.gsag_footprint`: the node's three advance cells and the six `gCurrAnim*` globals, every
  stored pointer read from Mario's object or its Animation header, both chase-reachable). **Its Φ
  carry is proved too (2026-10-23):** `RenderKeep.render_keeps_phiw` keeps every PhiW conjunct
  from the same footprint; the animFrame it advances stays in [−1, loopEnd] by `gsag_frame`. Its narrow
  premise `RenderKeep.render_surf_apart` (Mario's floor surface (wall / ceiling dropped 2026-11-08) is not in a
  `gCurrAnim*` global's block) is PROVED since 2026-10-26 from Φ (`ff_Spl`: they are dynamic
  surface-pool blocks, past every global; `RenderKeep.surf_apart_ffw`). The
  `gCurrAnim*` blocks are apart from Mario's object and the animation lists by
  `AnimWorld.rg_apart`, which is proved at boot (`StartSat`). The rest of the render walk (other
  nodes, display lists) is still in the `seg_rest` specs. No GFX external needed a floor:
  none of the unlinked rendering externals (`guPerspective`, `guOrtho`, `guLookAtReflect`,
  `print_text_fmt_int`, `create_shadow_below_xyz`, geo callbacks) is on this path.
- **Poll flank (2026-10-23, `PollFlank.v`; libultra `osContStartReadData.c` linked as TU 46).** The
  frame's input segment is now the real code: `seg_input_spec m i m0` = (`i = m` or the real
  `osContStartReadData(&gSIEventMesgQueue)` from m to i) and the real `read_controller_inputs()`
  from i to m0. Proved, on the link (`HeightLinked12.srd_ok_linked12` / `poll_ok_linked12`,
  discharging the HeightFrame rows `Hsrd_ok` / `Hpoll_ok`): `osContStartReadData` carries GOAL 1's
  facts (`PollFlank.srd_ok`); `read_controller_inputs` from a memory whose PIF reply shows A on no
  live port carries GOAL 1's facts (valid bm, the action cell, `MWF_real`, by
  `MWFReal.mwf_real_bc_frame`), leaves `buttonPressed` and `buttonDown` A-free, and re-establishes
  the controller cells the next poll reads (`FfWorld.ctl_w`) (`PollFlank.poll_ok`). The walk covers
  `osRecvMesg` (OS floor, 3.5), `osContGetReadData` (loop over `__osMaxControllers` <= 4 ports, the
  8-byte reply struct copy, the error-bit test), `run_demo_inputs` (with `gCurrDemoInput` NULL),
  the two-controller loop (`buttonPressed = button & (button ^ buttonDown)`, `buttonDown =
  button`, `adjust_analog_stick` with `sqrtf`, FpuFloor), and the player-3 copy. Its write set:
  `gSIEventMesgQueue`, `gMainReceivedMesg`, `gControllerPads`, and `gControllers` outside the
  `controllerData` words. **No labeled premise left (2026-10-26).** The calls the game runs between them
  (`game_init.c:686-691`) are in the segment as real code (`MidKeep.v`, `MidKeep.mid_call`;
  generic row `Hmid_keep`, discharged as `mid_keep_linked12`): `audio_game_loop_tick` (US:
  `audio_signal_game_loop_tick`, which sets `sGameLoopTicked = 1` and calls a no-op; the EU/SH
  `maybe_tick_game_sound` is not compiled) and `select_gfx_pool` (`gGfxPool`, `gGfxSPTask`,
  `gDisplayListHead`, `gGfxPoolEnd`, and `sSegmentTable[1]` through memory.c's
  `set_segment_base_addr`). Both are walked by FootWalk + PermWalk (footprint, permissions: Φ,
  `plat_still`, the object world) and by UcKit's class walker (GOAL 1's facts). The pool
  pointers `gGfxPool` / `gGfxSPTask` / `gDisplayListHead` / `gGfxPoolEnd` and the pool
  `gGfxPools` joined the SafeB symbols (`CensusV2.gfx_safe_syms` in `safe_ptr_syms`; the objects
  walk already classes every linked variable outside `non_safeb_syms` as SafeB), so MWF's R7
  keeps what they hold SafeB; the witness still builds (`SpawnInit.safeb_wit_sat`, `BootMWF`,
  `StartSat`). `sGameLoopTicked` and `sSegmentTable` receive integers only. The no-A premise
  now reads the PIF image in the memory `read_controller_inputs` starts from. **PROVED 2026-10-26 (`PollKeep.v`,
  discharging the new row `Hsrd_keep` and the strengthened `Hpoll_ok` as `srd_keep_linked12` /
  `poll_ok_linked12`):** the Φ (PhiW), `plat_still` and object-world (`ObjWorld.obj_w`) carries
  across both calls. Each call's footprint is walked: `osContStartReadData` changes memory only in
  the blocks of six globals (`PollKeep.srd_gvars`: gSIEventMesgQueue, the SI access queue and its
  buffer, `__osContPifRam`, `__osContLastCmd`; generic body walker `FootWalk.v`, every callee body
  machine-checked), `read_controller_inputs` only in `PollFlank.rci_gvars` (its walk's
  `poll_ok_foot`); both keep every permission and allocate nothing that survives
  (`Generic/PermWalk.v`: a syntactic body check, no builtins, calls only to listed functions).
  Φ then follows by `LevelKeep.lvl_keeps_core` (no written global is a core / flank global), its
  controller clause `ctl_w` re-established by the real `read_controller_inputs` (`lvl_w_ctl`);
  `plat_still` by `LevelKeep.fx_plat_still` (no object, not gMarioPlatform); the object world by
  `PollKeep.obj_w_unch` (none of its blocks written). No new axiom, no new row. **Strengthened to make it provable:** `FfWorld.ctl_w` (in
  Φ via `lvl_w`) now also pins `gPlayer1Controller = &gControllers[0]`, `gPlayer3Controller =
  &gControllers[2]`, `gCurrDemoInput = NULL`, `__osMaxControllers <= 4` and each
  `gControllers[j].controllerData` to NULL or a pad, all PROVED at the run's start memory
  (`StartSat`); `stored_globals` (`CensusV2`, so `SafeB_syms_ok`) gained `gControllerPads` and
  `__osContPifRam` (non-vacuity: `SpawnInit.safeb_wit_sat` still builds).
- **Platform flank (2026-10-23).** `seg_platform_spec` is now ONE real eval_funcall of
  `apply_mario_platform_displacement` (platform_displacement.c, TU 45; `PlatformKeep.plat_call`).
  `PlatformWalk` walks it from the generated bodies: the outer function either does not call
  (memory unchanged) or calls `apply_platform_displacement(1, gMarioPlatform)`, which stores
  `D_8032FEC0 := 0`, Mario's pos[0] / pos[2] (moved by the platform's velocity) and pos[1]
  written back with the value `get_mario_pos` just read, inside eight freed locals
  (`PlatformEff.plat_eff`). From that alone `PlatformKeep` proves the GOAL-1 carry (`MWF_real`,
  the action cell, bm's validity), that the held-A reading is unchanged, and the Φ carry (the
  generalized `RenderKeep.k_all` with written globals `[D_8032FEC0]`). The step states two
  premises (labeled): `plat_still` — gMarioPlatform is NULL or an object whose angle velocity
  (oAngleVelPitch / Yaw / Roll, rawData.asS32[35..37]) is zero — and `surf_apart` for
  D_8032FEC0 (PROVED from Φ since 2026-10-26, `RenderKeep.phiw_surf_apart`). **FOUND:** the old spec ("y and action loads unchanged; a ridden wing-cap box never
  moves so its displacement is identity") is false of the real body for a rotating platform:
  with a nonzero angle velocity, the rotation block moves Mario about the platform's center and
  changes pos[1]. `plat_still` is that condition made explicit.
- **`plat_still` for WMotR (2026-10-24): TRUE of the game; now carried, no longer a step
  premise.** gMarioPlatform is written only by `update_mario_platform` (the last step of
  `update_objects`: `floor->object` of Mario's floor, or NULL) and `clear_mario_platform`. Of the
  behaviors WMotR can spawn exactly `bhvExclamationBox` (7 boxes) and `bhvCannonClosed` (2 lids)
  own surfaces (`WMotRLevel.collision_of`, `BehaviorScripts`). `AngleVelCensus` (spine) pins over
  the generated code: neither script has a field command on slots 0x23..0x25
  (`scripts_set_no_angle_vel`); their natives are `bhv_exclamation_box_loop` and
  `bhv_cannon_closed_init` / `_loop` / `load_object_collision_model` (`plat_natives`); and it
  lists every rawData store reachable from those natives, `cur_obj_update` and the command
  table, by base. The only constant-slot angle-velocity store is
  `spawn_triangle_break_particles`' (through `triangle`, the object `spawn_object` just
  returned); the variable-slot stores are the script commands' (whose fields are the scripts'
  own) and `allocate_object`'s zeroing loop. So the box and the lid keep the zero angle velocity
  allocation gives them. The one way a STALE pointer could reach a rotating object: a box
  deletes itself only after act 3 (7 frames with no collision loaded), so its surfaces are gone
  first; a lid deactivates (`bhv_cannon_closed_init` at opening timer 80) in a frame its script
  still loads its collision, so gMarioPlatform could hold a freed slot that a later spawn
  (e.g. a triangle particle) reuses. That needs Mario standing on the lid while it opens: it
  opens during the bob-omb buddy's CUTSCENE_PREPARE_CANNON (170 frames, longer than the lid's
  142), while Mario is frozen in the buddy's dialog next to the buddy (3684, -2712, 4660), over
  400 units from the lid's edge (mesh ±112 around (3712, -2740, 5200)). Not machine-checked;
  stated plainly as part of the labeled objects spec. **How it is carried:**
  `seg_rest_spec` (objects, labeled 0.7) now ends with `plat_still`; `seg_input_spec` (poll) keeps it
  (PROVED 2026-10-26, `PollKeep`); the start premise is PROVED at the boot witness (`StartSat.plat11`:
  gMarioPlatform's boot value is `Init_int32 0`, untouched by the entry stores), and
  `goal2_start_sat` concludes it. `HeightFrame.fb_ok` carries it at frame boundaries.
  No new axiom, no new row. `D_8032FEC0` joins the flank
  globals `AnimWorld.flank_gvars` (apart from Mario's object and the animation lists, proved at
  boot). No new axiom; clear_mario_platform is not on this path.
- **`clear_dynamic_surfaces` (2026-11-03): PROVED, the row `Hobj_surfaces` is gone (from both
  capstones: GOAL 2's and GOAL 1's whole-frame `NoAImpliesNoFlyFrame`).** The generated body is
  inverted (`ClearRun.cds_run`, with `clear_spatial_partition`'s 256-cell loop: `csp_run`):
  under TIME_STOP_ACTIVE nothing changes (`post_clear`'s first disjunct, `tsa`); otherwise
  gSurfacesAllocated = gNumStaticSurfaces, gSurfaceNodesAllocated = gNumStaticSurfaceNodes,
  then NULL into each of the 768 heads of gDynamicSurfacePartition (every other byte,
  permission and nextblock unchanged). `ClearKeep.clear_keeps` reads Pobjl and `post_clear` off
  it: obj_w's `ow_spool` pins gNumStaticSurfaces to NS, so `ow_ctr` is re-made with NS and
  `ctrv = NS`; each counter store is into a global no invariant reads (`gstore_core`:
  RenderKeep's `k_all_w` with Xs = [the cell], GOAL 1's `safe_store_pres`, a_down,
  plat_still); a NULL head (`hstore_keep`) leaves each partition list old or empty, and every
  list node and listed surface is a dynamic block (`FloorExec.dyn_list`), so the world fact
  `Wff`, the floor data, the animation table's apartness and obj_w's surface objects are kept
  (`Wff_keep3` / `floor_data_keep3` / `tab_apart_keep3` / `surf_keep_hd`). obj_w is kept by
  the new `PollKeep.obj_w_slots_g` (the clause keep for the counter and the partition given
  separately). PHANTOM CHECK: the theorem assumes only `Pobjl`, carried from the boot. No
  new trust.
- **`update_mario_platform` (2026-11-03): PROVED, the row `Hobj_mplat` is gone.** The generated
  body is inverted (`MplatRun.mplat_run`: two locals; NULL gMarioObject stores nothing;
  otherwise find_floor(x, y, z, &floor), then ONE value, NULL or `floor->object`, into
  gMarioPlatform and gMarioObject->platform). `MplatKeep.mplat_eff` reads off it: GOAL 1's
  mem_ok (find_floor by UcKit's class walk as in the camera walk; the two stores carry NULL or
  a gObjectPool slot, SafeB through Mario's marioObj chase root); every permission kept; every
  load kept outside find_floor's three statics, gMarioPlatform and Mario's slot's field
  [532, 536) (obj_w's `ow_mario`: gMarioObject is Mario's slot); gMarioPlatform's new value is
  NULL or a pool slot with zero angle velocity (find_floor's `FL` + `ow_surf_obj`). So
  `plat_still` is re-made by the real code, PhiW is kept by `RenderKeep.k_all_w` (the window
  `owin` skips [532, 536), which PhiW does not read), and obj_w by `PollKeep.obj_w_slots`
  (`SKp` skips the platform field, which no obj_w clause reads). PHANTOM CHECK: the theorem
  assumes only the object phase's invariant (`Pobjl`), carried from the boot.
- **GOAL 1 and rendering.** GOAL 1's step is `execute_mario_action` alone; rendering writes Mario's
  animInfo cells (object + 64..76) and the `gCurrAnim*` globals, none of which is the action cell,
  the A-input cell or a cell `MWF_real` reads (proved: `render_mem_ok`).

### Row 0.4 in detail

- **FOUND 2026-10-22: size-0 storage made every nonzero-action frame from boot unexecutable.**
  `gPlayerCameraState` (camera.c) and `gBodyStates` (mario_misc.c) were only declared in the
  link, so `Genv.init_mem` gave them size-0 blocks. `init_mario_from_save_file` stores their
  addresses into `m->statusForCamera` / `m->marioBodyState`, and every `execute_mario_action`
  frame with a nonzero action stores through both (`mario_reset_bodystate`,
  `update_mario_info_for_cam`). `update_mario_inputs` also reads `gCameraMovementFlags` (camera.c)
  every frame. So from the real boot image no such frame had a CompCert execution. No row was
  false (the walks are partial correctness), but the from-boot capstones held vacuously past the
  action-0 frames. PoleControl had avoided this by using a fresh block. **Repaired** by linking
  `camera.c` (the 35th TU: it defines the four camera globals) and by the 2.4 storage completion
  for the 17 other globals (row 2.4), all found by the sweep `tools/size0_globals.py`, which the
  audit runs and which fails on any size-0 global that code reached from the frame / boot /
  level-entry roots touches. Also note: `init_mario_from_save_file` sets `action = 0`, and an
  action-0 frame does nothing, so the from-boot capstone's runs are no-op frames until level entry
  (still not run from boot, see below).
- **Non-vacuity guard (2026-10-22): `BootRun.boot_frames_run`** (in the audit). Over every 36-TU
  link it starts from `Genv.init_mem lp` itself (`Interp/InitMemEq.v`: a vm-computable `init_mem`,
  proved equal to CompCert's), not from a built memory. It runs the function the link resolves
  `init_mario_from_save_file` to, and then one frame (the from-boot capstone's exact premise
  shape). From that same memory it then does WMotR's entry. Stand-ins (not run): the main pool
  block (3.6), `gCurrentArea := &gAreaData[1]`, `gMarioObject := &gObjectPool[0]`, the warp
  node's `startPos` (-67, 2669, -16), and Mario's anim DMA list. Since 2026-10-22 (anim data
  linked) its table is the 1680 header bytes of the linked `gMarioAnims` with `srcAddr :=
  &gMarioAnims`, and `currentAddr` is anim 0x56 (the entry action's), so the frame's
  `load_patchable_table` compare runs on the real block (no DMA; `bufTarget` is still a stand-in,
  and the pool allocation / DMA are not run). Real code run: the
  terrain loader on WMotR's collision, `init_mario`, and `set_mario_initial_action(m,
  MARIO_SPAWN_AIRBORNE, 0)`. Then ONE FULL real no-A frame runs in `ACT_SPAWN_NO_SPIN_AIRBORNE`,
  and it leaves `gPlayerCameraState[0].action = 6450`. Conditional only on the FPU value clause
  (`sqrtf_value`, 3.5). (Until 2026-10-23 also on the labeled audio premise `BootRun.audio_ret`;
  since the audio link the frame runs the real `play_sound` / `play_infinite_stairs_music` /
  `set_sound_moving_speed` bodies, 4.1.) `reset_red_coins_collected` runs its real body (`ingame_menu.c` is linked, the 36th TU).
- **FOUND 2026-10-22, REPAIRED the same day: GOAL 2's `StartSat` witness had no frame execution.**
  It was built from `init_mem` without `init_mario_from_save_file`, so `marioBodyState` /
  `statusForCamera` were NULL; `mario_reset_bodystate`'s first store was stuck (checked by running
  it), and `gMarioAnimsBuf.dmaTable` was NULL too. The premise was satisfiable, but no run left the
  witness. Now `goal2_start_sat` also concludes `frame_runs lp bm m`: ONE FULL real no-A
  `execute_mario_action` runs from the witness memory itself (`a_pressed_real` false, ends in
  `ACT_SPAWN_NO_SPIN_AIRBORNE` = 6450), and `ifs_tether lp m_boot bm bc`: the REAL generated
  `init_mario_from_save_file`, run from the boot memory, performs exactly the nine stores the
  witness makes (`spawnInfo`, `statusForCamera`, `marioBodyState`, `controller`, `animList`,
  `numLives` 4, `health` 0x880, `unkB0` 0xBD, `gHudDisplay.wedges` 8) and allocates nothing
  (`StartTerrain.ifs_ok_sound`, by the sound interpreter). Stand-ins the witness still chooses
  (an `∃`, not trust): `gMarioAnimsBuf.dmaTable` points at a fresh 16-byte DMA table with count 0
  (2026-10-22: left as is; the real header now sits in the linked `gMarioAnims`, and BootRun uses it,
  but re-proving `PhiW`'s anim layout over a 209-entry table was not attempted),
  and the 24-byte animation header it reads is zeroed (the real one is loaded by DMA from the ROM;
  out of scope, 3.x); `gAreaData[1].terrainType` = `TERRAIN_SNOW` (2), tethered to WMotR's level
  script by `StartTerrain.wmotr_terrain_type` (the `TERRAIN_TYPE(TERRAIN_SNOW)` command word,
  `script.c:61`, is in the generated `level_wmotr_entry`).
- **2026-11-03: the GOAL 2 witness runs the real entry** (`StartTerrain.entry_g`, see
  [row 3.6 in detail](#row-36-in-detail), Step C). `StartSat.terrain_loaded` now says: the witness
  is, block for block, what `entry_g` leaves (every block below its nextblock reads the same,
  except the anim list, `gCurrCourseNum` and `gControllers`, the stand-in stores S7 / S8), and
  `entry_g` is a real execution (`entry_made`, under `sqrtf_value`). `goal2_start_sat`'s height
  cells are `entry_cells ENTRY_FH`: floorHeight is find_floor's 1669.0, not the boot image's 0.
  Mario's MWF_real rows are re-proved from the cells the entry left (`StartSat.mwf_real_rebuild`,
  `mwf_L`); `old_ok` exempts gMarioStates by name and `frag_ok` bounds its pointers.
- **`gCurrCourseNum` on the GOAL 2 witness (2026-10-22, `CourseRun` + `StartSat.course_set`).** The
  witness was 0 there; it is now 23 (`COURSE_WMOTR`). Real path: each level load runs the menu
  segment's `level_main_menu_entry_2` (`levels/scripts.c:118`), whose first command is
  `CALL(0, lvl_set_current_level)` (`levels/menu/script.c:61`) with the level number. `CourseRun.course_runs`
  RUNS the generated `lvl_set_current_level(0, 31)` from `Genv.init_mem` with no external answered
  (unconditional) and reads `gCurrCourseNum = 23` after it; `goal2_start_sat` concludes
  `course_set`: the witness carries that value. Its other stores (`gSavedCourseNum`,
  `gCurrCourseStarFlags`, ...) are not on the witness; no frame row reads them.
- **Entry census, 2026-11-07** ([wmotr-entry-census.md](wmotr-entry-census.md), `tools/entry_census.py`).
  - **Ways in.** There is one real way into WMotR: castle area 2's warp node 0x0A, i.e. `initiate_warp(31, 1, 0x0A, 0)`. So Mario's spawn cells are the same on every entry.
  - **FOUND: act 0 has no execution.** Entries with `gCurrActNum` = 0 (power-on, no act select yet) are real. On them `level_cmd_place_object`'s `1 << (gCurrActNum - 1)` is UB and has no Clight execution. **Repaired 2026-11-07** by the approved 2.2 rewrite (`level_cmd_place_object` row): act 0 now runs and places the same objects. The witness still enters at act 1 (stand-in S2).
  - **Repaired 2026-11-08: stale wall / ceil.** On a real entry `m->wall` / `m->ceil` are the castle's stale pointers. The start premise (`wmotr_world`'s `wall_ok` / `ceil_ok`) now leaves both cells unconstrained, which covers them: no frame proof read their type, every use was a keep.
  - **FOUND + REPAIRED 2026-11-08: ffw's `ff_Wc0` was false of a real entry.** It put `m->wall` / `m->ceil` off the region blocks, but on entry they are stale castle pointers into the main pool, which TRUST 3.6 models as one block that also holds the anim DMA buffer (a region, `fw_bt`). Repaired by dropping `ff_Wc0` and the wall / ceil parts of `ff_Spl`, `ffw_surf_ok` and `RenderKeep.surf_apart` (now floor only). The full build shows no proof needed them except to keep them. The capstone's start premise is weaker, so it claims more.
  - **Carried scalars covered** (`StartCarry.goal2_start_carried`): the start premise holds with any values in Mario's carried fields and in the act / save-slot / course-star globals.
  - **OPEN: residue and layout.** Free-slot and pool residue (MWF R7) and the anim buffer's block (S7) are not shown to meet the premise on a real entry.
- **GOAL 1: proved satisfiable by the real boot path** (2026-10-19, `BootMWF.boot_init_ok`, used by
  `NoAImpliesNoFlyTwelve.noA_never_flying_from_boot`). The memory `Genv.init_mem lp` of any
  linked-TU (now 17) link, followed by one real call of the generated `init_mario_from_save_file`,
  satisfies `mem_ok_lp` with `SafeB := SafeB_boot` (every block except the `non_safeb_syms` globals;
  it satisfies `HSafeB_syms`). The boot half is a vm-checked pass over every global's initializer in
  all 17 TUs: no pointer to Mario's block, the controllers or a non-SafeB global sits in a
  chase-root or table window, and the `.bss` cells MWF reads are zero. The init half walks every
  statement of the real body; each store is classified against the generated AST (`init_chk`), and
  its one call (`save_file_get_total_star_count`) is the real save_file.c body, proved
  (`ObjExtBodies.Hpx_total_star_count`, 2026-10-21; before, the capstone's own `Hpres_obj_ext_open` row). So
  `mem_ok_lp` is not a phantom ∀: the capstone applies to a state the real init code builds.
- **Still a modelling gap:** the boot image is the 17-TU `init_mem`. Globals defined outside those
  TUs are size-0 externs there. (2026-10-20: `game_init.c` is now linked as the 16th TU, so
  `gControllers` and `gMarioAnimsBuf` have their real storage. Its initializers
  `gPlayer{1,2,3}Controller = &gControllers[i]` made the boot check fail, so those three globals
  joined `non_safeb_syms`.) The code that runs between boot and `init_mario_from_save_file` (`main`,
  `thread5_game_loop`, level script load, `clear_objects`, `init_mario`'s other writers) is not run.
- **Consequence, found 2026-10-20:** `setup_game_memory` is not run, so `gMarioAnimsBuf` is still
  all zeros at boot (`dmaTable = NULL`). The first frame that calls `set_mario_animation` loads
  through that NULL table and **has no execution**. So `noA_never_flying_from_boot` is a
  satisfiability witness for the start premise (its purpose: `mem_ok_lp` is not a phantom ∀). As a
  statement about multi-frame runs from boot it is nearly vacuous: almost every real run stops
  having a model execution at its first animation frame. The general capstone (every `mem_ok_lp`
  state, every run) is unaffected. Closing this means running `setup_game_memory`'s `memory.c` calls
  (`main_pool_alloc`, `dynamic_dma_read`, `setup_dma_table_list`) in the boot path. Those calls
  allocate from the main pool. `alloc_pool` hands `main_pool_init` the integer addresses
  `SEG_POOL_START`/`SEG_POOL_END`, and CompCert has no memory there, so running them needs a stated
  model of the pool region as a block (open decision: a new hardware-level row). (2026-10-20: the
  user approved that hardware row, at low priority; it will be added when the from-boot path takes
  on level loading, which a real from-boot run needs anyway.)
- **Also found 2026-10-22 (the widened size-0 sweep, class (c), game thread only):**
  `setup_game_memory` has no CompCert execution even with the pool row (3.6): its
  `setup_dma_table_list(&gDemoInputsBuf, gDemoInputs, ..)` compares a pointer into the size-0
  `gDemoInputs` with NULL (the demo data is made from baserom-extracted `assets/demos/*.bin`,
  absent from the vendor tree, so it is not linked), and `load_segment` subtracts two
  linker-script ROM symbols (`_entrySegmentRomEnd - _entrySegmentRomStart`, two size-0
  blocks). `create_gfx_task_structure` likewise subtracts `rspF3DBootEnd - rspF3DBootStart`, and
  the render / reset path loads three unlinked `main.c` globals by name. None is reached by a
  frame or level-entry root; each is listed with its reason in `tools/size0_globals.py`
  (`BOOT_KNOWN`). Running `setup_game_memory` from boot would need these first.
- **Also found 2026-10-20:** `gNumCalls`, `gNumFindFloorMisses` and
  `gFindFloorIncludeSurfaceIntangible` (written by `find_floor`) are defined only in
  `object_list_processor.c`, so in the 16-TU boot image they were size-0 externs and a `find_floor`
  call had no execution from boot.
- **Repaired** by linking `object_list_processor.c` as the 17th TU (`LinkedTwelve.tu_rest`); no new
  assumption.
- **GOAL 2:** its start premise is now **proved satisfiable** (2026-10-20,
  `StartSat.goal2_start_sat`, in the discipline audit). For every 17-TU link there is a memory
  meeting the capstone's whole start premise (`HSafeB_syms`, the symbol pins, `mem_ok_lp` with
  `MWF_real`, and `PhiW`: the height invariant, the WMotR world, the anim layout, Mario's object
  apart, closedness, the collision partition, the controller). It is built from the link's real boot
  image `Genv.init_mem lp` by three fresh blocks and eight stores, each `MWF_real` step a proved
  store brick, so `wmotr_noA_height_bound_linked12` is not vacuous.
- **GOAL 2, the witness is now the real entry's height cells** (2026-10-21, `WMotREntry.v`, used by
  `StartSat`). Read off the generated code, not hand-written:
  - `wmotr_script`'s only warp-node-0x0A object is a `bhvAirborneWarp` at (-67, 2669, -16)
    (`entry_warp_object`).
  - `init_mario_after_warp` calls `get_mario_spawn_type`, `init_mario`, `set_mario_initial_action`
    (`after_warp_calls`); case `MARIO_SPAWN_AIRBORNE` (0x12) of the last is
    `set_mario_action(m, ACT_SPAWN_NO_SPIN_AIRBORNE, 0)` (`initial_action_airborne`), and that
    action is in `R_noA`.
  - `init_mario` sets `pos := startPos`, `vel := 0`, `gfx.pos := pos`, `actionTimer := 0`.
  So Mario enters at y = 2669 in an airborne action with vy = 0: rise credit 0, budget margin 127
  below `PHI_YMAX` = 2796 (`entry_budget`, `entry_margin`). `StartSat`'s witness now stores exactly
  these cells (`read_cells bm m (entry_cells 0)`); before, it was `ACT_IDLE` at y = 0. The Φ height
  clause is therefore **true at the real entry values**, not just satisfiable somewhere.
  - One link in that chain is still a table, not a call. Since 2026-10-21 the table is read off the
    generated `area.c`, not the C source: `get_mario_spawn_type`'s body is a loop over
    `sWarpBhvSpawnTable[0..20)` returning `sSpawnTypeFromWarpBhv[i]` (`WMotREntry.spawn_lookup_shape`),
    the only entry naming `bhvAirborneWarp` is i = 7 (`airborne_warp_index`), and
    `sSpawnTypeFromWarpBhv[7] = 0x12` (`spawn_type_at_7`). Since 2026-10-21 the lookup is also
    **executed**: `SpawnTypeRun.spawn_type_runs` runs the real body over every 30-TU link on an
    object whose behavior is `&bhvAirborneWarp` and gets `0x12`. (The object itself is built for the
    run; the level script that spawns it is not run.) Before, it had no CompCert execution:
    - Since 2026-10-21 its first step, `virtual_to_segmented`, is the identity (2.2 register,
      `NO_SEGMENTED_MEMORY`). Before, it computed `addr & 0x1FFFFFFF`, which has no value on a
      pointer.
    - The remaining obstacle was: the `bhv*` scripts in the table were size-0 extern blocks
      (`behavior_data.c` was not linked). CompCert's pointer `==` needs valid pointers on both
      sides, so the first compare was stuck (`WMotREntry.cmp_size0_stuck`).
    - Running it needed `behavior_data.c` linked, with each `bhv*` extern array completed to its
      real length (2.4); done 2026-10-21 (4.1).
- **Repaired 2026-10-21: `area.c` is linked (the 23rd TU, `generated/area.v`), and `in_wmotr` holds
  on the GOAL 2 witness by real code** (`EntryWarp.v`, used by `StartSat.goal2_start_sat`).
  - `gCurrLevelNum`, `gCurrCourseNum`, `gCurrentArea`, `gMarioSpawnInfo`, `gPlayerSpawnInfos` (its
    extern array completed, 2.4) and `gCurrSaveFileNum` now have real storage. Boot value of
    `gCurrLevelNum` is 1 (`EntryWarp.boot_levelnum`, from `area.v`'s initializer).
  - The warp destination is decoded from the generated WMotR level script: its warp node 0x0A goes
    to (LEVEL_WMOTR = 31, area 1, node 0x0A) (`EntryWarp.wmotr_warp_node_0A`).
  - `EntryWarp.initiate_warp_runs`: one real call of the generated `initiate_warp(31, 1, 0x0A, 0)`
    (level_update.c) from the boot image stores `sWarpDest` = {type 1, level 31, area 1, node 0x0A,
    arg 0}. `EntryWarp.warp_level_head_runs`: the first statement of the generated `warp_level`
    loads `sWarpDest.levelNum` and stores it into `gCurrLevelNum`.
  - `StartSat`'s witness memory now starts from that memory (six real-code stores before the three
    allocations), each one an `MWF_real` store brick; `goal2_start_sat` concludes `in_wmotr lp m`,
    and exhibits the boot memory, the `initiate_warp` run and the `warp_level` head run whose
    `gCurrLevelNum` cell the witness carries.
  - **Still read from source, not run:** (a) the castle painting's warp node that leads to WMotR
    (`castle_inside` is not generated; WMotR's own node 0x0A, the level's self-entry, is decoded
    instead); (b) the level script that runs between `initiate_warp` and `warp_level`; (c) the rest of
    `warp_level` (`gCurrCourseNum`, `load_area` → `load_area_terrain`, `init_mario_after_warp`);
    (d) the spawn-type lookup (above).
- **Gap as found 2026-10-21 (before the repair): `area.c` (and the level loader) is not linked.** `gCurrLevelNum`,
  `gCurrCourseNum`, `gCurrentArea`, `gMarioSpawnInfo`, `gPlayerSpawnInfos` and `gCurrSaveFileNum`
  have no storage in any linked TU (size-0 externs in the boot image). Consequences:
  - `HeightFrame.in_wmotr` (a load of `gCurrLevelNum`) is false on every memory real code reaches
    from the boot image. A size-0 block never gains permissions, so no boot-derived run takes a
    `frame_step`; only the flank specs (relations over arbitrary memories) produce one. The GOAL 2
    capstone is still about every start state meeting the premise, but no from-boot run instantiates
    it yet.
  - `set_mario_initial_cap_powerup` and `mario_get_terrain_sound_addend` read `gCurrCourseNum` /
    `gCurrLevelNum`, so they have no execution from the boot image either.
  - `surface_load.c` (`alloc_surface_pools`, `load_area_terrain`) is not run, so the witness's
    collision partition is empty and `m->floor` is a fresh one-surface block, not WMotR's terrain.
  - Seen at the literal entry memory (not proved, for the §5 check): `m->ceil` / `m->wall` are stale
    castle pointers into the reallocated surface pool, and `wmotr_world`'s ceil/wall clauses hold
    there only if that pool slot carries a WMotR surface type (the first frame's
    `update_mario_geometry_inputs` refreshes them before any read). `m->input` is the last castle
    frame's; `ffw`'s input clause needs A neither pressed nor held then. Mario's object is fresh, so
    `numCollidedObjs = 0` and `oInteractStatus = 0` do hold.
  - Fix path: link `area.c` (done, above) and later `surface_load.c` as further TUs. Remaining from
    this list: `gCurrCourseNum` is still 0 on the witness, and the collision partition is still empty
    (`surface_load.c`; its scope: `alloc_surface_pools`, `load_area_terrain`, `load_object_collision_model`,
    the `sSurfacePool` / `gStaticSurfacePartition` storage, and it reads the level's collision data,
    which is the unlinked `levels/wmotr/areas/1/collision.inc.c`, 4.3).
- **`surface_load.c` is linked (2026-10-22, the 32nd TU).** It is the only definer of
  `gStaticSurfacePartition` / `gDynamicSurfacePartition` (and `sSurfacePool`, `sSurfaceNodePool`).
  - **Found:** before, both partitions were size-0 extern blocks in the boot image. `find_floor`,
    `find_ceil` and `find_wall_collisions` read a partition list head right after their
    level-boundary check, so at any in-bounds (x, z) no memory built from the boot image (the GOAL 2
    witness included) gave them an execution. Every frame with a nonzero action runs
    `update_mario_geometry_inputs`, so no such frame at an in-bounds position had an execution from
    boot. No row was false: the proofs are partial-correctness walks over any memory.
  - **Repaired on the witness:** `StartSat.goal2_start_sat` concluded `part_ready` (both
    partitions have the definer's 6144 bytes, every list head loads as NULL). Superseded the same
    day by the loaded witness below.
  - **RUN (2026-10-22, `TerrainRun.terrain_runs`):** with `macro_special_objects.c` (TU 33) and
    WMotR's level data (TU 34) linked, and the main pool as one block (row 3.6), the generated
    `alloc_surface_pools` and then `load_area_terrain(1, wmotr_seg7_collision, NULL, NULL)` run to
    completion in the sound interpreter over every 35-TU link and allocate 1352 surfaces. On the
    resulting memory, `floor_data` holds and every floor-list surface is, field for field, a floor
    triangle of the decoder's `static_tris` (`static_agree`). Both are proved by a checked walk of
    both partitions (`TerrainBound.tri_chk`, below).
  - **What the run rests on** (a hypothesis of the theorem, `world_ok`, not a trust row): the
    interpreter answers `sqrtf` with the IEEE single-precision square root, and
    `reset_red_coins_collected` (`ingame_menu.c`, unlinked) with no memory change. `floor_data` and
    `static_agree` of the memory are unconditional. Only "this memory is what the loader computes"
    needs `world_ok`. Since 2026-10-22 it is split (`TerrainRun.world_ok_of`): `sqrtf`'s memory
    half is the existing FPU floor `sqrtf_spec` (3.5); what 3.5 cannot give (it makes no value claim
    and asserts no behavior exists) is `sqrtf_ieee` (a call returning `Float32.sqrt x` IS a sqrtf
    behavior), and `rrc_inert`. Both stay labeled antecedents of the tether implication in
    `goal2_start_sat` (`terrain_loaded`), not premises of any capstone. `rrc_inert`: the real body
    is `gRedCoinsCollected = 0;` (`ingame_menu.c:2421`); checked on the link, `gRedCoinsCollected`
    is not in the 35-TU program at all (only the external `reset_red_coins_collected`), so the
    write lands outside the modelled memory. Proving it from the body needs `ingame_menu.c`
    (3468 lines) linked; not done. A value floor row for `sqrtf` needs user approval; not added.
  - **What the run rests on (2026-10-22):** only the FPU value clause (`FpuValue.sqrtf_value`, 3.5):
    the interpreter answers `sqrtf` (at its decomp signature, on +-0 / positive normals) with the IEEE
    root. `reset_red_coins_collected` is no longer answered: `ingame_menu.c` is linked (the 36th
    TU), so its real body runs (`gRedCoinsCollected = 0;`, `ingame_menu.c:2421`, into the now-real
    `gRedCoinsCollected`). `floor_data` and `static_agree` of the memory are unconditional. History:
    before, the run rested on `world_ok` (split into `sqrtf_spec`, `sqrtf_ieee`, `rrc_inert`), and
    `sqrtf_ieee` was FALSE (any-signature form, see 3.5 detail), so the tether was vacuous.
  - **Not run:** `main_pool_init`. It has no CompCert execution (3.6 detail), so its post-state is
    constructed. Not run either: macro-object spawning (`macroObjects = NULL`; the boxes and
    cannons stay 0.8(b)). The special object is `special_null_start`, so the spawn path runs only
    over a NULL behavior.
  - **On the witness (2026-10-22, `StartTerrain` + `StartSat`):** the loader now runs on the GOAL 2
    witness itself. `InitMemC.init_mem_c` makes `Genv.init_mem` computable (Leibniz-equal memory,
    permissions included), and one `vm_compute` over every 35-TU link runs, from that boot image:
    `initiate_warp` / `warp_level`'s stores (`EntryWarp`), the main pool block in
    `main_pool_init`'s post-state (3.6), `alloc_surface_pools`, `load_area_terrain`, then
    `init_mario`'s cells. That is the game's order (warp, then the level script's
    `FREE_LEVEL_POOL` / `LOAD_AREA`, then `init_mario`), except that the game runs
    `main_pool_init` once at boot, before the warp; the pool block is disjoint from every cell the
    warp writes, so the order does not change a load. Checks on the result, each with a soundness
    lemma: the old blocks outside 14 loader globals (`f_ids`) keep their bytes (`old_ok`), and
    with `InterpFrame.ex_call_keep` (an interpreter run keeps every old block's permissions) their
    loads; every pointer in those globals or the pool aims at the pool or a SafeB symbol
    (`frag_ok`); every word of both partitions is NULL or a list living in the pool block, every
    surface of a WMotR type (`wff_parts`). From these `MWF_real` (SafeB widened by the pool
    block), `inject_neutral`, `Wff`'s partition clauses, and `floor_data` / `static_agree` are
    proved on the witness; `goal2_start_sat` concludes them plus `terrain_loaded` (the
    partitions and pool equal the loader's output) and 1352 surfaces allocated.
  - No capstone row names a `surface_load.c` function (checked: the open id lists, `exempt_callees`,
    the GOAL 2 per-call rows), so no row became a lemma. Its callers in the link
    (`update_objects` → `clear_dynamic_surfaces`, `load_area` → `load_area_terrain`, the
    `load_object_collision_model` behavior command) are outside the Mario frame (0.7 flanks).
- **Still ASSUMED:** that the memory the real game reaches at WMotR entry satisfies the rest of Φ
  (world, anim layout, partition, controller). Level loading is not modelled, and it must be checked
  on recorded states (§5).

### Row 0.5 in detail

- **GOAL 1 over the whole frame (2026-10-26, skeleton).** `NoAImpliesNoFly/NoAImpliesNoFlyFrame.v`,
  `noA_never_flying_frame_linked12`: on a twelve-TU link, a run of `HeightFrame.frame_step` (the
  real poll, the level slices around ONE real `area_update_objects` call with Mario's
  `execute_mario_action` inside it, the render) from a GOAL-2 start memory (`goal2_start_sat`),
  with the controller hardware's reply showing A on no live port before every frame, is never
  flying at a frame boundary. Proof: GOAL 2's frame proof carries GOAL 1's `mem_ok`
  (`HeightFrame.wmotr_noA_run_ok_linked12`). Its open rows are exactly GOAL 2's capstone rows,
  because the frame-boundary invariant is shared: the level slices' `mem_ok` carries READ PhiW
  (`lvl_w`, Mario's floor type for the warp guards, `area_w`), so GOAL 1 cannot drop PhiW
  today. What GOAL 1 needs from each open row is listed in the file's header. The key one is
  the per-object rows `Hobj_step_*`: no object sets Mario's action into the taint set
  T = {ACT_FLYING, ACT_FLYING_TRIPLE_JUMP, ACT_SHOT_FROM_CANNON}. From the C (read 2026-10-26),
  objects and the camera reach Mario's action only via `set_mario_npc_dialog`
  (ACT_READING_NPC_DIALOG), `mario_set_flag` has no caller, and the cannon shot is set by
  Mario's own `act_in_cannon` behind `INPUT_A_PRESSED` (inside the hole). No falsifier found.
  **Machine-checked (2026-10-26, `WMotRRequiresA/ActWriterCensus.v`):** the closure of
  `area_update_objects` and `update_camera` over the whole link (execute_mario_action cut;
  an indirect call is followed only to address-taken functions of exactly its function type,
  which `FnPtrCensus` shows are the only ones it can reach, see 3.2; 2217 functions)
  has exactly two action events
  (`census_value`): `set_mario_action`'s own store and `set_mario_npc_dialog`'s
  `set_mario_action(.., ACT_READING_NPC_DIALOG, ..)`, not in T. There is no `&action` escape and
  no MarioState copy, and no setter is reached indirectly (`setters_not_indirect`).
  `mario_set_flag` is uncalled and never address-taken, and `act_in_cannon` is outside the
  closure (`cannon_out`). Not covered: a store into the action cell through a pointer of another
  type (the object step's footprint must exclude it) and `set_mario_action`'s semantics on that
  constant; both belong to the narrow semantic row "keeps action ∉ T". **Split 2026-10-26**
  (`ObjStepSplit`): that row is now `Hobj_step_act_terrain` / `Hobj_step_act_nonterrain`
  (`step_act_row`: one object's update ends with Mario's action outside T; on the non-terrain
  lists under the Mario hole), and `Hobj_step_rest_*` (`step_rest_row`; the non-terrain one PROVED
  since 2026-11-07 from `Hobj_cou_nt`, the terrain one since 2026-11-08 from `Hobj_cou_t` +
  `Hobj_ter_ctr`, see `ObjStep`) keep the rest of the
  step rows and may assume it. `step_row_split` reassembles them, so ObjLoop's walk is
  unchanged. GOAL 1's need from the objects' per-object step is exactly the act rows. To
  prove: the census plus the step's footprint (no store into the action cell through another
  type) plus a walk of `set_mario_action` on ACT_READING_NPC_DIALOG.
  Mario's height budget is NOT what GOAL 1 needs, but `Hseg_na_open` carries it jointly with the
  world facts GOAL 1 does need.
- GOAL 1's twelve-TU capstone: **only `execute_mario_action`**. GOAL 2's `frame_step` composes that real call with one
  *specified* flank (0.7, objects), the level phase as real `play_mode_normal` slices
  (2026-10-24, `LevelFlank` / `LevelKeep`), and three real linked calls: the controller
  poll (`osContStartReadData`, `read_controller_inputs`: 2026-10-23, `PollFlank`), Mario's render
  call and `apply_mario_platform_displacement` (2026-10-23, `PlatformKeep`). The specified flanks
  are not linked code. This is the largest scope gap.
- **Level slices bound the run (2026-10-24, coverage).** The real PRE runs only in
  PLAY_MODE_NORMAL, so a frame in another mode is a step only as the idle frame's
  "nothing changes" disjunct. A run therefore ends at a change-level transition (after a warp
  out of WMotR, harmless: the visit is over) and at an unpause (the paused frames' `m' = m0`
  keeps the PAUSED mode; open, `play_mode_paused` is not walked).
- **Idle frames (2026-10-24, coverage).** FOUND: `frame_step` covered only frames that run
  Mario's update, but real frames often do not: paused (`play_mode_paused`), change-level /
  change-area transitions, and time stop when it covers Mario (`TIME_STOP_ACTIVE` also skips
  platform displacement) update Mario zero times. A run through such a frame had no
  step, so the capstone said nothing past it. `frame_step` is now `mario_frame_step \/
  idle_frame_step`: an idle frame is the (real) poll, then either nothing else or the flanks without
  Mario's update (optionally the real platform call, then level phase, objects, render, rest),
  ending in WMotR. The capstone is re-proved over both (`HeightFrame.frame_step_ok`); nothing
  is assumed about idle frames beyond the same labeled flank specs.
- **GOAL 2's run is one WMotR visit:** a frame is a step only if it ends with `gCurrLevelNum =
  LEVEL_WMOTR` (`HeightFrame.in_wmotr`; 31, pinned from the level's own self-warp node,
  `WMotRLevel.level_wmotr_self_warp`). This is forced by the real game: falling off sends Mario to
  the castle grounds, where `init_mario` puts him at y = 4500 (5.4), so "y ≤ 2796 forever" is false
  across a level exit. The coin argument must therefore be per visit: re-entry reloads the red coins
  and the star counter (0.3).


## 1. Foundations (irreducible; every formal proof has these)

| # | Item | Notes |
|---|---|---|
| 1.1 | The Rocq/Coq 8.19.2 kernel is sound | Standard. |
| 1.2 | Axioms: classical logic, functional extensionality, proof irrelevance, Flocq's classical reals | Standard. `discipline_check.sh` enforces that nothing else appears. |
| 1.3 | CompCert 3.15's definitions of C (Clight syntax, big-step semantics, memory model, `Cop` arithmetic, IEEE floats via Flocq) mean what C means | This is a *definition* to trust, not CompCert's compiler-correctness theorem. We never use the compiler. |

## 2. From the ROM to the C we verify

| # | Item | Status / notes |
|---|---|---|
| 2.1 | The decomp C is the game: compiled with IDO 5.3 it reproduces the US ROM byte-for-byte | **Checked** (2026-09-26): `vendor/sm64` @ 9921382 built with `make VERSION=us COMPARE=1` has sha1 `9bef1128…6ce`, which equals the US baserom (`experiments/oracle/README.md`). Covers the *default* preprocessing only; see 2.2. |
| 2.2 | **We verify a different preprocessing of that C.** The ROM is IDO-compiled vendor C. The proof's C adds `-DNON_MATCHING=1 -DAVOID_UB=1` and force-includes `pipeline/proof_n64.h` (every game TU except `shadow.c`; not the six libultra TUs, whose recipe `ULTRA_CG` is the game's own `lib/src` flag set, 2026-10-21) | **Itemized: every site is in the register below.** `tools/ub_sites.py` preprocesses every generated TU both ways (ROM: `-D__sgi`, as IDO predefines it; proof: our flags) with clightgen's own preprocessor, and diffs them. Its output is committed as `docs/ub-sites.txt`. A new site cannot enter silently: regenerate that file and the diff shows it. |
| 2.3 | `clightgen` (CompCert's *unverified* front end: parser, elaborator, `-normalize`) translates that C faithfully | ASSUMED, **TETHERED on sampled paths**. 267 real frames over 15 actions run through the generated Clight and reproduce the game's memory byte for byte (§5.1). 2026-10-22, 35-TU link (collision, `math_util`, `memory.c` now run as Clight): 600 of 600 frames match, with `gMarioAnims` sized in the harness (5.1). This is evidence for the translation of the code those frames exercise, not proof. |
| 2.4 | Our post-processing of the generated `.v` is semantics-preserving: stringlit renaming, anonymous-composite renaming (`canonicalize_anon.py`), completing extern incomplete arrays | ASSUMED. Each is a documented rename or type completion. (2026-10-20: `gDebugInfo` joined the extern-array completion table, `s16 gDebugInfo[][8]` → `[16][8]`, its size in `object_list_processor.c`, the 17th TU; `behavior_actions.v` and `object_helpers.v` regenerated, two-line diffs. 2026-10-21: four more, found linking `save_file.c` and `buffers.c` (TUs 20 and 21): `gDecompressionHeap` 0 → 53248 and `gGfxSPTaskStack` / `gGfxSPTaskYieldBuffer` 0 → 1024 / 3072 (`u8`, sized in `buffers.c`; declared in `memory.c` / `game_init.c`), `gLevelToCourseNumTable` 0 → 38 (`s8[LEVEL_COUNT - 1]`, sized in `save_file.c`; declared in `level_update.c`); 2026-10-23, linking `audio/external.c` / `sound_init.c` (TUs 40, 41): four BSS completions, `gResetTimer` 1 (main.c), `gSoundMode` 1, `gSequencePlayers` 960 and `gSequenceChannelNone` 192 (audio/load.c), each to its definer's size; `game_init.v` regenerated, diff exactly that `gvar_init` line; `memory.v`, `game_init.v`, `level_update.v` regenerated, diffs exactly those four `gvar_info` lines. 2026-10-21, linking `area.c` (the 23rd TU): `gPlayerSpawnInfos` 0 → 1 (`struct SpawnInfo[1]`, sized in `area.c`; declared in `mario.c` / `level_update.c`); `mario.v`, `level_update.v` regenerated, diffs exactly that `gvar_info` line. 2026-10-21, linking `data/behavior_data.c` (the 30th TU): every `bhv*` behavior-script declaration, by RULE rather than by table (433 declarations of ~170 scripts across 16 generated files): `extern const BehaviorScript bhvXxx[]` is `(tarray tuint 0)`, readonly, while the definition is `(tarray tuint N)`, not readonly (CompCert's elaborator drops the `const` when it sizes the array from its initializer). CompCert's vardef linker needs both fields equal, so the declaration takes the definer's `(gvar_info, gvar_readonly)`, with N read off `generated/behavior_data.v`, i.e. the script's real length in the decomp. The readonly bit is new for this class, but it is the same kind of rewrite: init stays nil and the linked program takes the definer's vardef, so a run sees exactly the definition. Its effect is that the scripts are writable blocks: more executions (a store into a script would succeed rather than be stuck), never fewer. Regenerated files diff only in those `gvar_info` / `gvar_readonly` lines. 2026-10-21, linking `spawn_object.c` (the 31st TU): `gObjectPool` 0 → 240 (`struct Object[OBJECT_POOL_CAPACITY]`, sized in `object_list_processor.c`; declared in `spawn_object.c`); `spawn_object.v` regenerated, diff exactly that `gvar_info` line. 2026-10-22, linking WMotR's level data (`pipeline/tu/wmotr_level_data.c`, the 34th TU): a third rule, the same as the `bhv*` rule for `Collision` arrays. `data/behavior_data.c` declares the two object meshes it loads (`extern const Collision xxx[]`: `(tarray tshort 0)`, readonly), and the declaration takes the definer's `(tarray tshort N)`, not readonly, with N read off `generated/wmotr_level_data.v`. Only `behavior_data.v` changed (4 lines: `cannon_lid_seg8_collision_08004950` 24, `exclamation_box_outline_seg8_collision_08025F78` 66). 2026-10-22, the size-0 sweep (`tools/size0_globals.py`, run by the audit): a fourth table gives 17 globals that linked TUs only declare, with their real definition in an unlinked TU, the definer's storage as a common `Init_space sizeof` (each real definition is BSS or an explicit zero, so the bytes are the same; CompCert merges equal-size commons and would merge one with the real definer). The sweep also found four camera.c globals (`gPlayerCameraState`, `gCamera`, `gCameraMovementFlags`, `gCutsceneFocus`); by decision these are not completed here: `camera.c` is linked instead (the 35th TU). Tethers: `gBodyStates` 80 (`mario_misc.c:73`), `gCurGraphNodeRoot/MasterList/CamFrustum/Camera/Object` and `gAreaUpdateCounter` (`rendering_graph_node.c:120-126`), `gDmaIoMesg`, `gMainReceivedMesg`, `gDmaMesgQueue`, `gSIEventMesgQueue`, `gDebugLevelSelect`, `gShowDebugText` (`main.c:29-59`), `gDialogResponse` (`ingame_menu.c:131`), `gPaintingMarioYEntry` (`moving_texture.c:118`), `gObjParentGraphNode` (`geo_layout.c:47`), `gGlobalSoundSource` (`audio/external.c:344`, `{0,0,0}`). Diffs: only those `gvar_init` lines. The warp pipe mesh `warp_pipe_seg3_collision_03009AC8` (264 shorts, `actors/warp_pipe/collision.inc.c`, verbatim) joined the level-data TU and the existing level-data rule completed its two declarations. 2026-10-22, linking Mario's anim data (`mario_anim_data.v`, the 36th TU): a fifth rule, the anim-data completion. `game_init.c` declares `extern u8 gMarioAnims[]` (`(tarray tuchar 0)`, not readonly); the definer is `const struct MarioAnimsObj gMarioAnims`. The declaration takes the definer's `(gvar_info, gvar_readonly)` read off `generated/mario_anim_data.v`, spelled `Tstruct $"MarioAnimsObj"` (the same ident; `game_init.v` has no `_MarioAnimsObj` constant). The readonly bit goes false → true here, the reverse of the `bhv*` rule: the linked program takes the definer's `const` either way, no linked code stores to `gMarioAnims` (it is only a DMA source), and in the real game it is ROM. `game_init.v` diff: those two lines. 2026-10-24, linking `debug.c` (TU 48): `gDebugInfoOverwrite` 0 → 16 (`s16[16][8]`, sized in `object_list_processor.c`), the `gDebugInfo` class; found by the pairwise link check. 2026-10-26, the actor animation tables (FOUND by the BhvVM census, row 0.7): the level-data rule now also covers `extern const struct Animation *const xxx[]`, `(tarray (tptr (Tstruct _Animation noattr)) 0)`, readonly, taking the definer's length and readonly false. `pipeline/tu/wmotr_level_data.c` defines the five tables the WMotR closure loads from the vendor `actors/{bobomb,blue_fish,bowser_key,peach,toad}/anims/{data,table}.inc.c`, verbatim. Diffs: `behavior_data.v`, 10 lines (bobomb 3, blue_fish 2, bowser_key 2, peach 13, toad 8); `behavior_actions.v`, 2 lines (blue_fish). The same full regeneration also refreshed a stale `rendering_graph_node.v`: `gShowDebugText` gets the BSS rule's `Init_space 1`, which that rule has given since 24a8b945 and which `mario.v` / `game_init.v` already carried, so the linked program is unchanged. 2026-11-01, linking WMotR's level script (`levels/wmotr/script.c`, TU 52) and `engine/level_script.c` (TU 53), for the GOAL 2 real-order witness: `gAreaData` 0 → 8 (`struct Area[8]`, sized in `area.c`; declared in `level_script.c`) joined the extern-array table; and the level-data rule now also completes declarations that are readonly FALSE (`script.c` sees the level arrays through `make_const_nonconst.h`, as the definer does): `wmotr_seg7_collision` 0 → 6159 and `wmotr_seg7_macro_objs` 0 → 131 (`tshort`, read off `generated/wmotr_level_data.v`; readonly stays false, the definer's). `wmotr_script.v` diff: exactly those two `gvar_info` lines; `level_script.v` is new.) Could be proved (rename = alpha-equivalence) or regenerated and diffed. |
| 2.6 | `object_helpers.c` is clightgen'd with `-flongdouble` (a `1.0l` literal in a debug function) | Equivalence: IDO's o32 ABI makes `long double` a 64-bit double, as `-flongdouble` does. |
| 2.5 | The target configuration (ppc32 eabi: 32-bit, big-endian) gives the same struct layout, sizes and alignment as IDO/MIPS | Partly TETHERED: offsets cited in proofs (action@12, controller@156, buttonPressed@18) match the decomp's `/*0x..*/` layout comments. Should be checked for every struct in scope, mechanically, against the built ROM's symbol/debug info. |

### 2.2 register: every place the proof's C differs from the ROM's C

The policy (2026-09-26): each difference is either an **equivalence** (same bits as
the ROM, with the argument or check named) or a **nondeterministic
over-approximation** (the model allows every value the machine could produce). A
"we picked a value" row is not allowed. Sites outside the linked TUs (the twelve Mario TUs plus `surface_collision`) do not
affect the GOAL-1 step, but they are listed so they can't enter unnoticed when the
link grows.

| Site (hunks) | ROM C | Proof C | Class | Why it is the same machine behavior |
|---|---|---|---|---|
| `gCosineTable` (122 hunks, all TUs; `math_util.h:24`, `trig_tables.inc.c:259`) | `gCosineTable[i]`, a separate symbol | `(gSineTable + 0x400)[i]` | equivalence (layout) | ROM map: `gCosineTable` = 0x80387000 = `gSineTable` + 0x1000 bytes = +0x400 floats, the same address. In the ROM, indexing across the symbol boundary is out-of-bounds C; the proof's C makes it one object. |
| `VIRTUAL_TO_PHYSICAL` / `PHYSICAL_TO_VIRTUAL` / `VIRTUAL_TO_PHYSICAL2` (`macros.h:62-76`): 12 expressions in 4 linked TUs, `mario.c:69,70,102,103` (anim relocation), `mario_misc.c:95`, `game_init.c:312,373,622-625`, `area.c:372`; no linked `VIRTUAL_TO_PHYSICAL2` | `(uintptr_t)p & 0x1FFFFFFF`; `(uintptr_t)p \| 0x80000000`; `(u8 *)p - 0x80000000U` | the decomp's own `NO_SEGMENTED_MEMORY` bodies (`macros.h:73-75`, verbatim): `(uintptr_t)(p)`; `(uintptr_t)(p)`; `(void *)(p)` (`pipeline/proof_n64.h`). The flag itself stays undefined: it would also change `memory.c`, `macro_special_objects.c:323`, `level_commands.h`, `segment_symbols.h`, which stay as in the ROM | equivalence (address model): the same approved choice as the `segmented_to_virtual` row below | On the N64 the physical address comes back to the same object through `segmented_to_virtual` (segment 0) or `PHYSICAL_TO_VIRTUAL`. With one block per object and the identity `segmented_to_virtual`, both halves must be the identity. **FOUND 2026-10-22 (vacuity):** until then this row was `p - 0x80000000U` (the ROM's bits). The identity `segmented_to_virtual` did not add it back, so every read of a relocated anim pointer was 2^31 bytes out of bounds: no execution for `find_mario_anim_flags_and_translation`, `update_mario_pos_for_anim`, `return_mario_anim_y_translation` (top of pole), `graph_node.c:737-738,752-753,853-854`. Both capstones were silent there. (`PHYSICAL_TO_VIRTUAL` was the ROM's `\|` on a pointer: no execution either; not walked.) **Tether:** `AnimRoundTrip.reloc_eval` (the generated relocation stores targetAnim + offset, same block, in every execution); `AnimRoundTrip.anim_y_runs` (the real `return_mario_anim_y_translation` runs on such an anim over every linked program and returns the y sample / 4). **Cost:** §5.1 compares bytes, and the model holds a pointer where the ROM holds a physical address (`anim->values` / `index`). **Re-run 2026-10-22:** the harness compares such words through the ROM's `segmented_to_virtual` (segment 0 = physical); exactly these two words differ, on every anim-load frame (5.1). |
| `gFramebuffers` (`buffers/framebuffers.h:12`, `AVOID_UB`; `game_init.c:622-625`, and since 2026-11-01 (TU 53) `level_script.c:289`, `level_cmd_load_mario_head`'s `gd_add_to_heap(gFramebuffers[0], 3 * sizeof(gFramebuffers[0]))`: the title-screen Mario head, no WMotR script command; listed 2026-10-22 when `tools/ub_sites.py` gained `game_init` / `area`) | three externs `gFramebuffer0/1/2` | one `gFramebuffers[3][...]`, the three names `#define`d to its rows | equivalence (layout), **not yet checked against the ROM map** | The decomp: `level_script.c` assumes the three are adjacent. Only their addresses are taken (`gPhysicalFramebuffers`); no walked body reads them. |
| `act_air_hit_wall` missing return (`mario_actions_airborne.c:1341`) | falls off the end; the caller gets whatever is in `v0` | `return set_mario_animation(...)` | equivalence (checked against the ROM's assembly) | ROM disassembly: after `jal set_mario_animation` at 0x8026db34 the only instructions before `jr ra` are `b`, `nop`, `lw ra`, `addiu sp`; nothing writes `v0`. `set_mario_animation` sets `v0` with `lh` (0x80250ae8), which is sign-extended, so it equals the C `s16`→`s32` conversion. |
| `GET_HIGH_U16_OF_32` / `GET_LOW_U16_OF_32` (`mario_actions_cutscene.c:459,462`) | `((u16 *)&x)[0]`, `[1]` | `(u16)(x >> 16)`, `(u16)(x & 0xFFFF)` | equivalence (endianness) | The N64 is big-endian, so halfword 0 of a stored u32 is its high 16 bits. |
| `BAD_RETURN` declarations: `CameraEvent` (`camera.h:346`), `mem_pool_free` (`memory.h:78`, and its definition `memory.c:492` since memory.c is linked), `save_file_copy` (`save_file.h:130`), `cur_obj_reverse_animation` / `cur_obj_extend_animation_if_at_end` (`object_helpers.h:143`), `init_bully_collision_data` (`mario_step.h:25`, `.c:74`), `update_water_pitch` (`mario_actions_submerged.c:197`) | declared to return `s32`/`s16`/`u32` but returns nothing (garbage `v0`) | declared `void` | equivalence (typing) | The proof's C type-checks with `void`, so no caller in it reads the value. The ROM callers are the same C, so they don't read the garbage either. |
| `geo_switch_anim_state`, `geo_switch_area` declarations (`object_helpers.h:69`) | 2 parameters | 3 parameters (`void *context`) | equivalence (unused) | Declarations only. These are graph-node callbacks, not called from the linked code. |
| `chuckya_act_0` `sp3C` (`behaviors/chuckya.inc.c:108`) | possibly-uninitialized local | `sp3C = 0` | **picked value: must become any-value** | Stack garbage in the ROM. Outside the GOAL-1 step (an object behavior, not reached from `execute_mario_action`). If it is ever needed: replace with an "any u32" external. |
| Census-only TUs (`obj_behaviors`, `obj_behaviors_2`, `object_helpers`; used by `BehaviorScripts.v`'s static object census, never executed by the proof. 2026-10-21: `object_helpers` is now linked, the 22nd TU; its entries in this row are only the typing equivalences at `object_helpers.c:136,170,957,963`, none of them picked values): uninitialized locals set to 0 (`bowling_ball.inc.c:84,118`, `manta_ray.inc.c:47`, `mips.inc.c:118`, `snowman.inc.c:58`, `camera_lakitu.inc.c:65`), `wiggler.inc.c:154` `oHealth = 4`, `obj_perform_position_op` `u32`→`void` (`obj_behaviors_2.c:127`), and the definitions matching the `object_helpers.h` rows (`object_helpers.c:136,170,957,963`) | as in the ROM | as in the proof | **picked value: must become any-value** (the zero-inits, `oHealth`); equivalence (typing) for the rest | Stack garbage / an unset field in the ROM. The census reads these bodies only for which behaviors they spawn and which interaction types they store; none of these lines does either, so the census result is the same under any value. If this code is ever executed by a proof, replace them with any-value externals. **2026-10-24: all three TUs are now LINKED** (`obj_behaviors` TU 44, `obj_behaviors_2` TU 50), so these are picked values in every run of the linked program. None matters to WMotR: no function holding a site (`bhv_bowling_ball_roll_loop`, `bhv_bowling_ball_initialize_loop`, `manta_ray_move`, `bhv_mips_act_follow_path`, `snowmans_bottom_act_1`, `camera_lakitu_intro_act_show_dialog`, `wiggler_init_segments`, `obj_perform_position_op`) is in the WMotR closure (`BehaviorScripts.ub22_sites_not_live`, vm-checked). |
| `shadow.c:191` missing return | falls off the end | `return waterLevel` | not yet checked | `shadow.c` is not linked. Assembly check needed before it is used. |
| `detect_object_hitbox_overlap` / `detect_object_hurtbox_overlap` fall off the end when the objects miss horizontally (`object_collision.c:61,96`, `//! no return value`) | returns whatever is in the return register | `return 0;` | **any-value by statement**: `overlap_no_contact` leaves the returned value unspecified | Used by `CoinLink.v`, whose conclusion is "returns, memory unchanged" with the value existentially quantified, so it holds for any value the ROM returns. Contact is registered only on the `return 1` path, which the theorem excludes. Whoever consumes the result must also allow any value: in the ROM, a non-zero garbage return makes `check_collision_in_list` call `detect_object_hurtbox_overlap`, whose only store is `b->oInteractionSubtype` (the invincibility-delay bit), and that registers no contact. Since 2026-10-24 `object_collision.c` is LINKED (TU 49), so a run of the linked program takes the `return 0` path: a **picked value** in every execution. Since 2026-11-07 the spine walks `detect_object_collisions` (`CollWalk`), and it treats the return as any-value: `CollWalk.ccl_ok` walks both branches of `check_collision_in_list`'s test, so the hurtbox call is covered whatever the value. |
| `__osThreadTail` (`lib/src/libultra_internal.h:11`; used by the linked libultra TU `osCreateMesgQueue.c:4,5`; found 2026-10-21 by running `tools/ub_sites.py`'s ROM/proof diff on the six libultra TUs, the only hunk) | `extern OSThread *__osThreadTail;` (and four more separate externs); `mq->mtqueue = (OSThread *) &__osThreadTail` | `extern OSThread_ListHead __osThreadTail_fix;` with the five names `#define`d to its fields; `&__osThreadTail_fix.next` | equivalence (layout) | `__osThreadTail_fix.next` is at offset 0, and the asm aliases the symbol (`__osExceptionPreamble.s:21`, `.set __osThreadTail, __osThreadTail_fix`), so the stored address is the same. The walk (`SaveDoSaveBody`) does not depend on the value: the store lands in `gOsSiMessageQueue`, a stored global. |
| `segmented_to_virtual` / `virtual_to_segmented` (`memory.c:78,85`; `pipeline/proof_n64.h`, active only for `memory.c` via `-DPROOF_MEMORY_C=1`; 2026-10-21) | `sSegmentTable[seg] + (addr & 0xFFFFFF)` with a KSEG0 OR, and the inverse | the decomp's own `NO_SEGMENTED_MEMORY` bodies (`memory.c:98-105`): `return (void *) addr;`. The ROM bodies stay in the TU, renamed `rom_*`, and nothing calls them | equivalence (address model), **tethered, not proved** | **Tether:** on the N64 the argument is a segmented address (0x13… for behavior scripts). `sSegmentTable` maps it to the loaded copy of that same data. The model has one block per C object, so the linked object's own address is what the game then compares and dereferences. `virtual_to_segmented(0x13, o->behavior) == bhvXxx` agrees in both models. **Relied on by:** every `segmented_to_virtual(bhvXxx)` / `virtual_to_segmented(0x13, ..)` site in the 2.2 bullet of 4.1 (pole/tree, held-object checks, `object_helpers.c`, `area.c:139`, `interaction.c:881,889` warp-pipe collision), and `obj_set_held_state`'s `curBhvCommand` store, the one site the capstone walks. **Segment 0** (`mario.c:188-189`, `graph_node.c:737-738,752-753,853-854`, Mario's DMA'd animation): on the N64 it undoes `VIRTUAL_TO_PHYSICAL`. Since 2026-10-22 that macro is the `NO_SEGMENTED_MEMORY` identity too (row above), so the pair round-trips in the model and these reads execute (`AnimRoundTrip.anim_y_runs`). Before, they had no execution. `game_init.c:666` and `object_list_processor.c:477` (level scripts) are not walked. |
| `set_segment_base_addr` (`memory.c:69`; `pipeline/proof_n64.h`, memory.c only; 2026-11-02, approved) | `sSegmentTable[seg] = (uintptr_t) addr & 0x1FFFFFFF` | stores the address unmasked, `(uintptr_t) addr`; the ROM body stays in the TU as `rom_set_segment_base_addr` (memory.c's own `load_segment*`, boot / level load, not walked, still call it) | equivalence (address model), same choice as `segmented_to_virtual` | **FOUND 2026-11-02 (vacuity):** the mask on a pointer has no CompCert execution, so `select_gfx_pool` (every frame, `MidKeep.mid_call` in `HeightFrame.frame_step`) had none and the frame capstones held vacuously. The value only reaches gSPSegment display-list words: `SegTableCensus` (vm) shows the table's readers are the setters, `move_segment_table_to_dmem` (gSPSegment for the RSP, called by `init_rcp`) and three never-called, never-address-taken functions (`get_segment_base_addr`, `rom_segmented_to_virtual`, `rom_virtual_to_segmented`), and every setter call discards its result. The shim stores a pointer into the stored global `sSegmentTable`, so UcKit's store rule for a stored global (`kp_stored`, kW) now also accepts a value that is a pointer to a SafeB block (`ObjExtBodies.safe_store_pres`); `MidKeep.mid_keeps` walks it with that rule, no premise added. |
| `level_cmd_place_object`'s `u8 val7 = 1 << (gCurrActNum - 1);` (`level_script.c:436`; `pipeline/tu/level_script.c` + `proof_n64.h` `PROOF_LEVEL_SCRIPT_C`; 2026-11-07, approved) | shift by `gCurrActNum - 1`: by -1 at act 0, UB in C, no CompCert execution | `1 << ((gCurrActNum - 1) & 31)`. The vendor file is #included verbatim; its definition is renamed `rom_level_cmd_place_object` (unreferenced static, so clightgen drops it from the AST) and the jump table names the rewritten copy, which is the vendor body with only this line changed | equivalence (exact bits) | The ROM's `sllv` takes the shift mod 32: act 0 gives 1 << 31, and the u8 store keeps the low byte, 0. `& 31` is that mod, so the two agree on every `gCurrActNum` and differ only at act 0, where the ROM line has no CompCert execution (acts 1..6: shift 0..5, unchanged). At act 0, val7 = 0, so only mask-0x1F commands are placed: in WMotR that is every OBJECT (`StartCarry.object_masks`), the same objects as acts 1..6. **Tether:** `StartCarry.place_object_val7` (the generated body's first statements), `act0_val7` (it evaluates to 0). |
| `mtxf_to_mtx` (`math_util.c:577`) | register/fixed-point implementation | portable C | not yet checked | `math_util` is not in the link (its callers go through the external-call rows, 4.1). Needs an equivalence check before linking. |

## 3. C semantics versus what the N64 actually does

| # | Item | Status / notes |
|---|---|---|
| 3.1 | CompCert's C semantics agrees with IDO-compiled MIPS on the code in scope: evaluation order, integer promotions, float rounding (single vs double), float→int casts | ASSUMED, **TETHERED on sampled paths**. Across 267 completed real frames, 0 differ in memory and 0 diverge in external calls or arguments, including float arguments passed bit-exact to `find_floor`, `atan2s` and others (§5.1). 2026-10-22: those now run as linked Clight; 0 DIFF, 0 DIVERGE over 600 frames (5.1). |
| 3.2 | **Undefined behavior means "no execution" in CompCert.** If a real frame hits UB (uninitialized read, out-of-range float→s16), the model has *no* derivation for it, and a "for all executions" theorem says **nothing** about that frame | **Closed for the one measured site; open in general.** §5.1 measured 33 of 300 real WMotR frames (11%) with no CompCert execution, all from `VIRTUAL_TO_PHYSICAL(ptr)` (`macros.h:64`, `(uintptr_t)ptr & 0x1FFFFFFF`) in `set_mario_animation` / `set_mario_anim_with_accel`. 2026-10-22: the anim *read* path had no execution either (fixed; 2.2 register). **FOUND 2026-10-22 (§5.1, open):** `load_patchable_table`'s pointer compare (`memory.c:575`) has no execution on real states, because `gMarioAnims` is a size-0 block: 523 of 600 real frames STUCK. **FOUND 2026-11-02, REPAIRED:** `select_gfx_pool` had no CompCert execution (`set_segment_base_addr`'s mask on a pointer); the 2.2 `set_segment_base_addr` row. Details: [row 3.2 in detail](#row-32-in-detail). |
| 3.3 | Concurrency: the game thread is the only writer of the state we reason about, and frames don't interleave with other threads' writes (audio, VI/PI interrupts, controller reads via `osContGetReadData`) | ASSUMED. The input buffer is written by the controller path. **Observed** (§5.1 recordings): during a single `execute_mario_action` call, the PI manager thread, DMA into `gMarioAnimsBuf` (Mario's animation data), thread save areas and `gZBuffer` all change. So Mario's *animation buffer* is filled by DMA mid-call. Needs an argument (likely: those threads write only buffers the game thread copies at a fixed point). |
| 3.5 | **The libultra OS / hardware floor** (`OsDmaFloor.os_dma_floor`, a premise of the Twelve and HeightFrame capstones; widened 2026-10-21 from the DMA floor). Seven external calls, each bounding every execution (other argument shapes: no execution, as 3.2; no block allocated or freed, no permission change, in every clause). `osInvalDCache(p, n)`: nothing outside the n bytes at p changes, each of them stays or becomes data (`Byte` memvals), and p + n does not wrap. `osPiStartDma(mb, pri, dir, dev, dst, n, mq)`: nothing outside the n bytes at dst, the 20-byte OSIoMesg and the 24-byte queue changes; the n bytes become data; dst + n does not wrap (on the N64 every DMA buffer is in RDRAM; added 2026-10-20, used by `SmaFoot.sma_foot`). The whole PI transfer is attributed to `osPiStartDma`: between it and the blocking `osRecvMesg` the game thread reads nothing. `osRecvMesg(mq, cell, fl)` (cell NULL or a pointer): **per queue** (`q_side`): for `gDmaMesgQueue` / `gSIEventMesgQueue` nothing outside the queue and the 4-byte cell changes; for `gOsSiMessageQueue` also `osSiMesgBuff`; for `__osEepromTimerQ` also `__osEepromTimerMsg` and `__osEepromTimer`; other queues unconstrained. `osSendMesg(mq, msg, fl)`: the same per-queue bound without the cell. `osSetTimer(t, ...)`: for `t = &__osEepromTimer`, nothing outside its 32 bytes. `__osSiRawStartDma(dir, p)`: nothing outside the 64 bytes at p changes, each stays or becomes data. `bcopy(src, dst, n)`: nothing outside the n bytes at dst changes, and they then hold the n bytes src held. **FPU value clause** (2026-10-22, user-approved, `FpuValue.sqrtf_value`): `sqrtf` at the decomp's signature `float(float)`, on +-0 or a positive normal binary32, can return `Float32.sqrt x` with memory unchanged (the VR4300 `sqrt.s`). | ASSUMED, **the floor: there is no C below it**, except `osSetTimer`, a **coarser floor** (its C, `osSetTimer.c` / `osTimer.c`, walks the OS timer list through libultra's own pointers and is not linked). Below the rest: asm (`bcopy.s`, `__osEnqueueAndYield` and the thread queues: `osRecvMesg` / `osSendMesg` yield the thread), the PI manager thread and SI / PI register writes, and the bytes arriving by hardware DMA. Details: [row 3.5 in detail](#row-35-in-detail). |
| 3.4 | Lag frames and frame pacing don't matter (the theorem is per *game-logic* frame) | ASSUMED, probably easy. |
| 3.6 | **The main pool is one block** (hardware floor, user-approved 2026-10-20, added 2026-10-22). The `SEG_POOL_START..SEG_POOL_END` main-pool region (`main.c` `alloc_pool`) is one ordinary writable block. `main_pool_init` / `main_pool_alloc` / `alloc_only_pool_*` (`memory.c`) address it by pointer arithmetic from its two ends only. | ASSUMED, the floor. Used by: `TerrainRun` (the witness's pool block), `StartTerrain.entry_g` (the level pool the real ALLOC_LEVEL_POOL handler makes in it; FREE_LEVEL_POOL's `main_pool_free` is stand-in S5). Details: [row 3.6 in detail](#row-36-in-detail). |

### Row 3.2 in detail

- **Closed for the one measured site; open in general.** §5.1 measured 33 of 300 real WMotR frames
  (11%) with no CompCert execution, all from `VIRTUAL_TO_PHYSICAL(ptr)` (`macros.h:64`,
  `(uintptr_t)ptr & 0x1FFFFFFF`) in `set_mario_animation` / `set_mario_anim_with_accel`. Worse, the
  spine did not merely miss those frames: its walker had a *dead-mask* arm
  (`dead_mask_chk`/`dead_mask_dead`) that discharged those stores **by contradiction**, using the UB
  itself as a proof step. Fixed by the 2.2 rewrite (`pipeline/proof_n64.h`, pointer subtraction).
  The stores now execute, and the walker proves them with a real arm
  (`chase_arith_store_chk`/`chase_arith_assign_pres`: pointer arithmetic on a chase temp stays in a
  SafeB block). The dead-mask arm is deleted. After the fix: **300/300 MATCH, 0 STUCK**. The general
  hole (a UB site that no recorded frame hits) remains; §5.1's STUCK count is the regression gate,
  and 2.2's register lists every site that differs from the ROM's C.
- **FOUND 2026-10-22:** the subtraction fixed the store but not the read. Next to the identity
  `segmented_to_virtual` (2.2), every later read of the relocated pointer was out of bounds, so
  the frames that *use* a new animation (`update_mario_pos_for_anim`, top of pole) still had no
  execution. §5.1 did not see it: its 300/300 dates from 2026-09-26, when `segmented_to_virtual`
  was outside the link and replayed from the game. `VIRTUAL_TO_PHYSICAL` is now the
  `NO_SEGMENTED_MEMORY` identity (2.2 register).
- **Rule: a stuck Clight run never discharges a premise.** When a lemma needs no premise only
  because the violating case has no Clight execution, the capstone has excluded those runs. It
  has not proved they never occur. Each such site is a UB-coverage point, listed here until a
  carried invariant shows the case cannot happen. Open (2026-10-25):
  `cur_obj_call_action_function` (`ObjAct.caf_frame`) loads `tbl[o->oAction]` with no bounds
  check. On the N64 an out-of-range index reads adjacent memory. The clause exists
  (`ObjWorld.act_ok`, `ow_act`: a slot of the 3 action-table behaviors has 0 <= oAction < its
  table's length). **Census 2026-10-26 (`WMotRRequiresA/ActIdxCensus.v`), no FOUND:** every
  write of oAction in the link, machine-checked. Each behavior's own closure (its reachable
  script natives, BhvVM, under direct calls and its own table) stores only constants in range
  or a helper parameter every call passes in range (`own_stores_ok`, 3 + 6 + 8 stores); the
  generic object step stores none (`gen_census`; allocate_object zeroes it); no reachable
  script state writes field 49 (`script_census`); the only store through another object
  pointer in the WMotR closure is `act_in_cannon`'s `m->usedObj->oAction = 2` (behind
  INPUT_A_PRESSED, in range of the cannon's 7) (`other_stores_value`); computed indices never
  hit 49 and &rawData never escapes. What remains is the CARRY of `ow_act` through the object
  loop rows (objects agent), with the tie "a slot whose behavior is B runs B's script states".
  **REPAIRED (2026-10-26, `WMotRRequiresA/FnPtrCensus.v`):** `ActWriterCensus` follows an
  indirect call only to address-taken functions of exactly the call site's type (a mismatched
  call is C UB: no CompCert execution, but the N64 runs the target). Machine-checked over every
  TU, initializer and body of the link: every function address enters at exactly its own type
  (`init_census`: 507 type-exact initializer slots, BehaviorCmdTable / the oAction tables /
  `sModeTransitions` / the cutscene and camera-trigger structs among them, and 751 CALL_NATIVE
  words of behavior scripts, all `void(void)`; `body_census`: 187 designators in bodies, all
  exact, so every function-pointer field / global store is exact); the only conversion into a
  function-pointer type from another type is `bhv_cmd_call_native`'s script word
  (`reentry_census`); no function pointer is converted to another type (`exit_census`); the
  only pointer punning around function-pointer memory is the render code's graph-node
  downcasts, outside the closure, reaching only `GraphNodeFunc`, a type no call site of the
  closure has, and no union holds a function pointer (`pun_census`); temps and globals are read
  at their declared type (`read_census`, one unrelated exception). What stayed open was
  the narrower point of an out-of-bounds table read at an indirect call, which would read a
  neighbour of another type. `BehaviorCmdTable[cmd >> 24]` is discharged on master by obj_w's
  CMDPOS clause (`ObjWorld.ow_vm`: every live slot's command is a reachable `BhvVM` state,
  opcode < 56, `BhvVM.vm_tab_closed`), proved at boot and carried. **The camera tables
  (census 2026-10-26, `WMotRRequiresA/CamIdxCensus.v`, no FOUND):** a value-source census of
  every store into the index cells. `sModeTransitions` (18 entries, NULL at 0): every stored
  mode is a constant in 1..17 or a mode cell except four pinned leaves: two path-guarded
  (`set_camera_mode`'s `mode != -1`, `set_mode_if_not_set_by_surface`'s `mode != 0`) and
  `create_camera`'s `gc->config.mode`, the level's GEO_CAMERA node, geo DATA outside the link
  (WMotR's is 16). Camera triggers: WMotR's `sCameraTriggers` entry is NULL (no trigger runs);
  every array is NULL-terminated (decomp note: the `LEVEL_COUNT + 1` clamp allows index 40 of
  a 40-entry array, unreachable in WMotR). Cutscenes: within a cutscene the shot index stays in
  bounds (`cut_census`: the 8 CUTSCENE_LOOP setters sit only in non-last shots, last
  durations are 0 / LOOP). **Closed for WMotR (2026-10-26, `WMotRRequiresA/CamCutCensus.v`):**
  the census made path- and level-aware. A guarded constant is dropped when every use that
  carries the parameter on sits under a `p != k` test (`mode_guards`, with a negative control).
  A call in a `gCurrLevelNum` switch case that no LEVEL_WMOTR / default label reaches is dead
  (gCurrLevelNum = 31 is carried, `FfWorld.lvl_w`). A call's result is followed into the
  callee's returns. Mode: only `create_camera`'s leaf is left (`mode_census_guarded`).
  The cutscene-switch carry `c->cutscene = 0 -> sCutsceneShot = 0` is closed:
  - the zeroing functions and everything that can call or name them lie in the shots' closure,
    held only by cutscene arrays (`zero_only_in_shots`);
  - every shot reaching one is a last duration-0 shot, or STOP-paired on every zeroing path
    with only STOP timer stores in its closure (`shots_reset`, `stop_paired`), so play_cutscene
    resets the shot;
  - only `reset_camera` sets CAM_MOVE_INIT_CAMERA (`init_after_reset`);
  - a cutscene starts only from 0 (`starts_from_zero`: `get_cutscene_from_mario_status`
    returns a running cutscene unchanged; the pool start is held only by castle / HMC triggers).
  **One trust line, the GEO_CAMERA mode:** geo layouts are not linked, so the area Camera's mode
  is WMotR's `GEO_CAMERA(16, ...)` (`levels/wmotr/areas/1/geo.inc.c:16`), transcribed as the
  literal 16 the boot witness passes to `init_graph_node_camera` (`StartTerrain.cam_chain`).
  It is in range 1..17. New worklist point (decomp UB, `no_case_values`):
  CUTSCENE_WATER_DEATH (159, from ACT_WATER_DEATH) has no case in play_cutscene's switch, so
  `cutsceneDuration` is read uninitialized. In `tools/ub_sites.py`'s `UB_WORKLIST`.
- **NULL-floor frames (GOAL 2 chunk 2, B'', 2026-10-26).** When Mario is out of bounds,
  `update_mario_inputs` misses twice. It sets `m->floor = NULL` and the DEATH warp, and the OOB guard
  in `execute_mario_action` (`if (gMarioState->floor == NULL) return 0;`, proved as
  `FrameSplit.fc_null_returns`) skips the dispatch. Mario is then frozen until the warp. The frame
  rows now allow this (`FfWorld.ff_Wf`: a world surface **or NULL**; umi's post is
  `floor_null \/ fresh`). Every reader of `gMarioState->floor` that runs in such a frame was audited:
  - **UB-COVERAGE POINT, open:** `mario.c:427`, in `mario_get_floor_class`:
    `m->action == ACT_CRAWLING && m->floor->normal.y > 0.5f`. The type switch above it is NULL-guarded
    (`:399`); this line is not. It is reached from `mario_process_interactions`, which runs before the
    OOB guard: `take_damage_and_knock_back` (`interaction.c:710/729`) or `interact_bully` (`:1266`) calls
    `drop_and_set_mario_action`, which calls `set_mario_action`, then `set_mario_action_moving`
    (`mario.c:896-897`), then `mario_get_floor_class`. It needs Mario still in `ACT_CRAWLING` while out
    of bounds. A crawl step cannot leave bounds by itself, since a NULL floor in a ground step is a
    wall stop with no move. Platform displacement or an object push could still carry him out. On
    that path the Clight run is stuck, so any carry through the interaction phase covers it only
    vacuously. *Note, not proof:* on the console, `m->floor->normal.y` with a NULL floor reads near
    virtual address 0, which is unmapped kuseg. Expect a TLB-miss crash there, not a usable state.
    Listed in `tools/ub_sites.py`'s `UB_WORKLIST`.
  - Guarded:
    - umi's tail: `if (m->floor != NULL)`, `mario.c:1336`.
    - Special floors: `interaction.c:1863`.
    - `push_mario_out_of_object`: uses its own local floor, guarded.
    - `check_instant_warp`: `level_update.c:539`.
    - The painting warp: `level_update.c:659`.
    - `play_infinite_stairs_music`: guarded, and runs after the OOB guard.
    - The dispatch: none runs, because of the OOB guard.
    - The platform step: its own `find_floor`, guarded.
    - The camera: never reads Mario's floor pointer. Its own `find_floor` calls are height-checked
      (`camera.c:6836`), and `cutscene_enter_painting` is unreachable.
    - The objects phase: no behaviour dereferences `gMarioState->floor` or Mario's platform.
    - The shadow: its own queries.
    - The render call: does not read it.
  - Dead code: `debug_print_speed_action_normal` (`mario.c:1237`) runs only when `gShowDebugText` is
    set, which never happens.

### Row 3.5 in detail

- ASSUMED, **the floor: there is no C below it.** `osRecvMesg` yields the thread
  (`__osEnqueueAndYield`, asm); the PI manager thread starts the transfer by writing PI registers;
  the bytes arrive by hardware DMA. The OS thread structs and the queue's message buffer (`main.c`'s
  `gDmaMesgBuf`) are not declared by any linked TU, so they are outside the modeled memory; the spec
  is about the modeled memory only. Writes by other threads while the game thread blocks are 3.3
  (among modeled globals, the audio thread's `gAudioRandom`). Consumer: `LptBody` (the GOAL-1
  `load_patchable_table` row).
- **Consumer since 2026-10-23: the controller poll (`PollFlank`, GOAL 2's `seg_input`). No new
  floor row.** `osContStartReadData`'s two `__osSiRawStartDma` calls (write the request, read
  the reply) use the existing SI clause on the 64-byte `__osContPifRam`: the reply bytes are
  whatever the hardware delivered, as data, and **the no-A premise is a statement about exactly
  those bytes** (`PollFlank.pif_a_real`, 0.1). Its `osRecvMesg` on `gSIEventMesgQueue` (both in
  `osContStartReadData` and in `read_controller_inputs`, cell `&gMainReceivedMesg`) uses the
  existing per-queue clause; `adjust_analog_stick`'s `sqrtf` uses `FpuFloor.sqrtf_spec`. All three
  are restriction-only (each bounds every execution of the call; none quantifies a behavior over
  all signatures).
- **Widened 2026-10-21 for `save_file_do_save`** (consumer `SaveDoSaveBody`, both capstones through
  `cut_ext_open_of2`). The libultra C of the EEPROM write path is now linked (six TUs, 4.1), so the
  floor moved to where that C stops:
  - `bcopy` (`lib/asm/bcopy.s`, asm): stores the n bytes it read at src to dst and nothing else;
    an overlapping copy behaves as memmove. A libultra floor, not a hardware one.
  - `__osSiRawStartDma` (C, but not linkable as an execution: its body is `IO_WRITE`s to the SI
    registers, stores to integer addresses that have no CompCert execution, plus the asm cache
    ops `osWritebackDCache` / `osInvalDCache`): the SI DMA moves the 64-byte PIF RAM image at
    addr (`__osEepPifRam`), so only those bytes change, to data or not at all. The read
    transfer is attributed to the call, as `osPiStartDma`'s is.
  - `osRecvMesg` / `osSendMesg`: their C reads and writes the thread queues
    (`__osThreadTail_fix`, defined in asm, size 0 in the model) and yields
    (`__osEnqueueAndYield`, asm), so they stay below the floor. The bound is per queue (`q_side`)
    and lists the linked memory a wait or send on that queue changes: the queue, the cell, the
    queue's own message buffer when it is linked (`osSiMesgBuff`, `__osEepromTimerMsg`), and for
    `__osEepromTimerQ` the timer that the timer interrupt (`osTimer.c`, unlinked) unlinks while
    the game thread waits.
  - `osSetTimer`: **a coarser floor than the C allows.** `__osInsertTimer` rewrites the active
    timer list through pointers libultra keeps in it, which no invariant here describes, so
    `osSetTimer.c` is not linked. The stated bound (only the 32 bytes of `__osEepromTimer` change
    in linked memory) relies on the list holding no other linked OSTimer: every `osSetTimer`
    caller in the decomp (`osContInit.c`'s stack timer, `osEepromLongRead`, `osEepromLongWrite`)
    blocks on the timer's queue until it fires and is unlinked, so at the call the list holds
    only `__osBaseTimer` (`osTimer.c`, outside the modeled memory).
- **FOUND 2026-10-21 (false claim, repaired):** the old `osRecvMesg` clause was universal
  ("nothing outside the queue and the cell changes", for every queue). That is false for
  `game_init.c`'s `gGameVblankQueue`: its buffer `gGameMesgBuf` is linked memory, and the VI
  handler writes it while the game thread waits. The clause is now per queue, listing each
  queue's linked side buffers, and says nothing about unlisted queues (none of them is called by
  a walked body). The old clause also required the cell to be a pointer, so the EEPROM calls
  (`osRecvMesg(mq, NULL, 1)`) had no execution: a row resting on it would have been vacuous for
  them. The cell may now be NULL.
- **The storage the path touches is linked**, or the path would have no execution (a phantom):
  `osContInit.c` (`__osContLastCmd`, `__osEepromTimer` / `__osEepromTimerQ` /
  `__osEepromTimerMsg`) and `osInitialize.c` (`osClockRate`) are TUs 28 and 29.
- **The FPU floor (load-bearing since 2026-10-20: `HeightFrame` premises `Hsqrtf` / `Hsqrtf_float`,
  consumed by the proved freefall MoveChain `FfRow.ff_moves`):** `FpuFloor.sqrtf_spec`, a call of
  `sqrtf` leaves memory unchanged (on the N64 it is the VR4300 `sqrt.s` instruction; no claim about
  the value), and `ExtInert.sqrtf_float` (added 2026-10-20), its result is not a pointer (the
  instruction writes an FPU register). The act_freefall walk's external contract
  (`ExtInert.ext_fresh_sound`) uses both. The same walk took `play_sound` (and, since
  2026-10-22, `set_sound_moving_speed`, called by `act_holding_pole`) and
  `set_camera_shake_from_hit` as labelled open premises (`ExtInert.audio_inert` / `camera_inert`),
  the GOAL-2 capstone's `Haudio` / `Hcamera`. Both are gone: `Hcamera` 2026-10-22 (camera.c
  linked, the walks run `set_camera_shake_from_hit`'s real body) and `Haudio` 2026-10-23
  (audio/external.c linked, `SndXc` proves both audio calls' clobber contracts from the real
  bodies; see 4.1). sqrtf is the walks' only external left. Used only by the Unwired GOAL-2
  footprint walker (`FpWalk.uawt_fp`: `update_air_without_turn` writes only forwardVel, slideVelX/Z,
  vel[0], vel[2], slideYaw, proved from its generated body and `check_horizontal_wind`'s). It is the
  same fact `CoinLink` assumes about `sqrtf`.
- **The FPU value clause (2026-10-22, user-approved; `FpuValue.sqrtf_value`).** A call of `sqrtf`
  at signature `float(float)` on x = +-0 or a positive normal binary32 (`sqrt_in`) can return
  `Float32.sqrt x` (IEEE-754 correctly rounded) with memory unchanged. Tether: the decomp's `sqrtf`
  is `lib/asm/sqrtf.s` (`jr $ra` / `sqrt.s $f0, $f12`; declared in `include/libc/math.h`).
  `osInitialize.c:80` sets FCSR to `FPCSR_FS | FPCSR_EV`: round to nearest, flush denormal results,
  trap on invalid operation. That is why the domain is restricted: a negative x or a NaN traps, and a
  denormal input is an unimplemented operation on this FPU. The root of a normal is normal, so the
  flush never applies. Infinity is left out. Consumers: `TerrainRun.world_ok_of` and
  `BootRun.world_ok_of` (the interpreter's sqrtf answer), so `terrain_runs`, `boot_frames_run` and
  `StartSat`'s `terrain_loaded` / `frame_runs` / `ifs_tether` rest on it.
- **FOUND FALSE 2026-10-22 (repaired): the old `sqrtf` value antecedent was refutable.** It said
  the IEEE return is a behavior at ANY signature. CompCert's own axiom
  `external_functions_properties` (`ec_well_typed`) makes a `Vsingle` result impossible at an
  int-returning signature, so that statement is false (`FpuValue.sqrtf_any_sig_false`). Both old
  `world_ok`s implied it, so `TerrainRun.terrain_runs`'s tether, `BootRun.boot_frames_run` and
  `StartSat`'s `terrain_loaded` / `frame_runs` / `ifs_tether` held vacuously. Now the clause and both
  interpreter worlds name the signature (and the domain), and the runs check it.
- **On the spine since 2026-10-21 in both capstones:** the GOAL-1 capstone takes it as `Hsq`, in
  place of the old `Hscp_mtxf_real` row (see 4.1), and GOAL 2's `Hsqrtf` fills that slot.

### Row 3.6 in detail

- **What it says.** The real pool is the RDRAM range from `SEG_POOL_START` to `SEG_POOL_END`
  (`include/segments.h`). `main.c` `alloc_pool` passes those two numbers to `main_pool_init`
  (`memory.c`). In CompCert a region is a block, so the proof models the range as one fresh,
  writable block. `main_pool_init` / `main_pool_alloc` / `main_pool_free` /
  `alloc_only_pool_*` only ever form addresses from `sPoolStart` / `sPoolEnd` / the list heads
  plus offsets. So one block holds every address the code computes.
- **Why it is a floor.** Below it there is no C, only the linker script (`sm64.ld`) and RDRAM.
- **FOUND 2026-10-22: `main_pool_init` itself has no CompCert execution.** `ALIGN16(x)` is
  `((x) + 0xF) & ~0xF` on `(uintptr_t) start`, i.e. integer `+` / `&` on a pointer, and Cop's
  integer arithmetic on a `Vptr` is undefined (3.2). So the witness does not run
  `main_pool_init`. It *constructs* that function's post-state directly, on a 16-aligned block
  of size `POOL`: `sPoolStart = b+16`, `sPoolEnd = b+POOL-16`, `sPoolFreeSpace = POOL-32`, the
  two list heads at `b+0` and `b+POOL-16` with NULL `prev` / `next`. That is a witness
  construction (an `∃`), not a trust row, the same way `StartSat` builds its memory.
  `main_pool_alloc` (no `ALIGN16` on a pointer, only on `size`) *does* run, and the terrain run
  executes it (`TerrainRun`).
- **FOUND 2026-10-26: `alloc_only_pool_resize` has no CompCert execution either.** The level
  script makes the level pool with `alloc_only_pool_init(main_pool_available() - sizeof(AllocOnlyPool),
  MEMORY_POOL_LEFT)` and shrinks it at `FREE_LEVEL_POOL` with `alloc_only_pool_resize`, which
  calls `main_pool_realloc` and then `main_pool_free`. `main_pool_free` does
  `sPoolFreeSpace += (uintptr_t) oldListHead - (uintptr_t) sPoolListHeadL`: pointer minus
  pointer, as integers (3.2). The interpreter sticks there. So the witness's level pool
  (`StartTerrain.cam_chain`, which builds the area's Camera) is created by the real
  `alloc_only_pool_init` at its *post-resize* size (`sizeof(GraphNodeCamera) + sizeof(Camera)`).
  Again a witness construction, not a trust row. The camera chain's other deviations from the
  real `LOAD_AREA` geo walk, also witness construction:
  - only the camera node is built, not the area's other geo nodes;
  - the node's `func` is NULL and `create_camera(gc, pool)` is called directly (it is the whole
    `GEO_CONTEXT_CREATE` case of `geo_camera_main`); and
  - `reset_camera` runs before the terrain load and Mario's spawn rather than in
    `init_mario_after_warp`. It reads only the Camera, `gPlayerCameraState[0]` and camera.c
    statics, which those steps do not write.
  The node, `create_camera`, the store `gAreas[1].camera = node->config.camera` and
  `reset_camera` are otherwise the generated code. One full frame then runs from the witness
  through the real `update_camera` on that Camera (`StartSat.frame_runs`).
- **Step B (2026-11-02): the level script's own order.** The witness now runs, in the
  script's order: the game loop's `select_gfx_pool` (real, with the identity
  `set_segment_base_addr`, 2.2); `init_graph_node_start` / `clear_objects`; the camera chain;
  then `StartTerrain.lvl_objs`: a level pool from the real `alloc_only_pool_init`, sized to
  the 8 `SpawnInfo`s the OBJECT commands allocate; `sLevelPool`, `sCurrAreaIndex` = 1 (AREA)
  and `gCurrActNum` = 1 set by stores; and the real `level_cmd_place_object` once per OBJECT
  command, with `sCurrentCmd` at that command (offsets vm-decoded from the generated script,
  `obj_cmds`). Then `alloc_surface_pools`, `load_area_terrain` with WMotR's macro list (the
  real `spawn_macro_objects`), `load_area`'s `spawn_objects_from_info` over the area's spawn
  infos, and Mario's spawn. **Not run** (witness construction, not trust rows): the level
  script dispatcher itself (`level_script_execute`; the OBJECT handler is run, the dispatcher
  is not), the `begin_area` geo stores (the area's geo nodes other than the camera), and
  `alloc_only_pool_resize` (no execution, above). One whole `HeightFrame.play_frame_step`
  then runs from the witness (`StartSat.frame_runs`).
- **Step C (2026-11-03): the real entry replaces the pieces.** `StartTerrain.entry_g` runs, on
  the pool block, `sound_init`, `init_mario_from_save_file` (Mario's action set to ACT_IDLE
  first, S1: the castle warp fires from a nonzero action), `select_gfx_pool`, then WMotR's level
  script command by command through the REAL handlers looked up in the generated
  `LevelScriptJumpTable` (`sCurrentCmd` set to each command; the command types are vm-read off
  the generated script, `cmd_types`): INIT_LEVEL, ALLOC_LEVEL_POOL, MARIO, AREA, the OBJECTs,
  the WARP_NODEs, TERRAIN, MACRO_OBJECTS, SET_BACKGROUND_MUSIC, TERRAIN_TYPE, END_AREA,
  FREE_LEVEL_POOL, MARIO_POS; then the generated `init_level`, `warp_level` (load_area: the
  spawn infos, `load_area_terrain`, the objects) and `init_mario_after_warp` (the real
  `init_mario`, find_floor, `set_mario_initial_action`, `reset_camera`), each a slice of the real
  body. Mario's cells are read off the result by vm (`StartTerrain.bm_cells`, on the entry's
  result and on the witness): his floor is find_floor's hit (pool + 112592, a
  SURFACE_NOT_SLIPPERY static surface), floorHeight 1669.0, `m->area = &gAreaData[1]`,
  interactObj / usedObj the airborne warp's object. Witness construction, not trust rows (the
  stand-ins, listed once in `StartTerrain`'s header): S1 ACT_IDLE before the warp; S2
  `gCurrActNum = 1`; S3 the LOAD_* segment loads, the JUMP_LINKs to the global model scripts
  and AREA's geo layout are not run (only the root and the camera node, as
  `geo_camera_main(GEO_CONTEXT_CREATE)` would build it, then `level_cmd_begin_area`'s stores);
  S4 the dispatcher `level_script_execute` is not run; S5 FREE_LEVEL_POOL's `main_pool_free`
  (pointer difference, above) is three stores, then the real `main_pool_alloc`; S6
  `set_background_music` and `init_level`'s tail; S7 the anim DMA shortcut; S8 main_pool_init's
  post-state, `gCurrCourseNum`, `gControllers[0].controllerData`. The earlier separately-run
  pieces (`cam_chain`, `lvl_objs`, `area_spawn`, Mario's cells as stores, the stand-in floor and
  area blocks) are gone. Every vm boot check passes on the new memory; `AudioInv` holds as
  stated (`AudioBoot`, re-pointed to `StartTerrain.wit_chain`).
- **Tether.** In the real game the pool spans `_framebuffersSegmentNoloadEnd` to `RDRAM_END`, one
  contiguous range. Its exact size does not matter here: the witness only needs room for the
  surface pools and the static surfaces.
- **What would make `main_pool_init` run (not done; a new assumption, needs approval).** The
  decomp has no pointer-free alternative: `memory.c` computes `sPoolStart = (u8 *)
  ALIGN16((uintptr_t) start) + 16` and `sPoolEnd = (u8 *) ALIGN16((uintptr_t) end - 15) - 16`
  in every version (the `VERSION_CN` branch only changes where `start` comes from,
  `&gZBufferEnd`). Under CompCert's 32-bit Cop the `+ 0xF` on a `Vptr` is defined but the
  `& ~0xF` is `Vundef`. The minimal preprocessing rewrite is an `AVOID_UB`-style edit of just
  those two lines (`memory.c:120,122`) for the proof build: `sPoolStart = (u8 *) start + 16;`
  and `sPoolEnd = (u8 *) end - 16;`. A global `#define ALIGN16(val) (val)` would be wrong: the
  other `ALIGN16` uses round integer sizes (`main_pool_alloc`'s `size`, the DMA lengths). The
  rewrite is sound only given that `start` and `end` are 16-aligned (`SEG_POOL_START` /
  `SEG_POOL_END` are, in the linker script). That
  alignment fact would be the new trust; with it, `main_pool_init` would run and the
  constructed post-state would become a proved one.
- **Used by:** `TerrainRun` and `StartTerrain` / `StartSat` (the GOAL 2 witness's pool block).


## 4. Scope: code and data outside what is linked

| # | Item | Status / notes |
|---|---|---|
| 4.1 | Functions outside the 53 linked files (41 game TUs incl. `platform_displacement.c`, `camera.c`, `hud.c` (TU 51), `engine/level_script.c` (TU 53), `ingame_menu.c`, `debug_course.c`, `audio/external.c`, `sound_init.c`, `print.c`, `engine/behavior_script.c`, `obj_behaviors.c`, `spawn_sound.c`, `debug.c`, `object_collision.c`, `obj_behaviors_2.c` + `behavior_data.c` + WMotR's level data + WMotR's level script (TU 52) + 7 libultra TUs incl. `osContStartReadData.c`; the audio thread, rendering) behave as the capstone's rows say (`Hocp_*`, `Hpres_*`, `Hext_*`, …) | **ASSUMED, the ~30 project rows.** Shrinks by linking more files until only truly external things remain. `Hls`'s old footprint half `LsContract.ls_frame` is FALSE as stated (unscoped, 2026-11-02); since the rebuild (2026-11-02) both capstones' `Hls` is the SCOPED `AudioInv.ls_contract_ai` (`ls_frame_ai`: from an AudioInv memory), and nothing uses `ls_frame` on the spine (`CamFootInst`, now on the spine, moved to `ls_frame_ai` in step (a); `ls_frame` remains only in the off-spine `ObjFrame` / `ObjAct`). Details: [row 4.1 in detail](#row-41-in-detail). |
| 4.2 | CompCert's `external_functions_sem` is an abstract Parameter. Anything left external is constrained *only* by our rows | Permanent for whatever stays external. The goal is that nothing game-logic stays external. |
| 4.3 | Level data (WMotR collision triangles, object placements, the red-coin positions) is what the ROM contains | **Collision and macro data in the link (2026-10-22, TU 34).** `pipeline/tu/wmotr_level_data.c` includes the vendor `levels/wmotr/areas/1/collision.inc.c` / `macro.inc.c` verbatim, under `leveldata.c`'s `make_const_nonconst.h`. So the data is the decomp's, but that the decomp's `.inc.c` matches the ROM bytes is the decomp's build check (2.1), not ours. Object placements beyond collision (`script.c`) and the red-coin positions are not yet in. |
| 4.4 | The proof's internal vocabulary (`MWF_real`, `SafeB`, `call_pres_ext_*`) appears in the *statement's* hypotheses | Anti-goal: a reader shouldn't have to understand proof internals to know what's assumed. Rows must eventually be about the game, or be gone. |

### Row 4.1 in detail

- **ASSUMED, the ~30 project rows.** Shrinks by linking more files until only truly external things
  remain.
- **`camera.c` is linked** (2026-10-22, the 35th TU, `generated/camera.v`; by decision: the
  camera is part of the ABC question, HOLP). It defines `gPlayerCameraState`, `gCamera`,
  `gCameraMovementFlags`, `gCutsceneFocus`, which had size-0 blocks before (row 0.4). Every
  camera function the Mario code calls now resolves to its real camera.c body. Rows:
  - `set_camera_mode` reached from mario.c left the negative pin (it would now be false) and is a
    pinned rest case (`RestSurface`, `LO_camera`). It owed `Hscm_body_real`: `body_pres_w` over
    the real `camera.f_set_camera_mode`, gated by `wgate`'s `T_scm` arm (Camera* is a SafeB
    block; `RestSurface.camera_scm_type` checks the body has that signature).
    **PROVED 2026-10-23 (`CameraModeBody.v`), gone from both capstones.** A class walker
    (never-pointer / SafeB / fresh local / writable-without-pointers) runs the real bodies:
    set_camera_mode, the 14 `sModeTransitions` targets and their callees, 60 bodies in
    camera.c, math_util.c and surface_collision.c (`find_floor`, `find_ceil`, their
    `_from_list` walkers, `find_water_level`), plus `play_sound` (`AudioBodies`) and `sqrtf`
    (the FPU floor, 3.5, already a premise). The indirect call through the WRITABLE table
    (camera.c:465) is covered by a per-TU type certificate: across every linked TU only those
    14 functions have type `(Camera*, f32*, f32*) -> s32`, and a Clight indirect call only
    runs a function of the call's type. No new trust. It needed three symbols in
    `CensusV2.camera_safe_syms` (so `SafeB_syms_ok` is stronger; `SafeB_boot` meets it, all
    three are outside `non_safeb_syms`): `sMarioCamState` (`update_boss_fight_camera` stores
    through it) and the two surface partitions (find_floor / find_ceil store the surface they
    found into the caller's local out cell; chased from SafeB partitions it is SafeB).
  - `Hcsp_scm_real` (`call_pres_ext_cs ... set_camera_mode`) is **DERIVED, no longer a row**
    (2026-10-22, `NoAImpliesNoFlyTwelve.Hcsp_scm_real`): the call resolves to the real camera.c
    body (`camera_defmap_scm`, `LO_camera`), `cs_gate`'s `arg0_cond_safe` implies `wgate`'s
    `T_scm` arm (`wgate_scm`), so `Hscm_body_real` gives MWF after the call and NoA follows from
    MWF (`mwf_real_ctl`).
  - **PROVED 2026-10-22 (`CameraBodies.v`)**: the any-argument entries
    `camera_approach_f32_symmetric` (pure), `trigger_cutscene_dialog` (->
    `start_object_cutscene_without_focus`: byte stores into `sObjectCutscene` /
    `sCutsceneDialogResponse`) and `set_camera_shake_from_hit` (s16 / f32 stores into
    `gLakituState` / `sFOVState` through the real `set_camera_{pitch,yaw,roll}_shake` /
    `set_fov_shake`). Each store is a non-pointer store into a global no MWF row reads
    (`ObjExtBodies.ast_ok`), whatever the arguments: no row was false. The shake dispatcher's
    SHAKE_SHOCK arm (reached: `act_shocked`, `act_water_shocked`) calls `random_float`
    (engine/behavior_script.c, NOT linked), so `set_camera_shake_from_hit` left
    `obj_ext_open2_ids` and `random_float` joined it: a narrower claim (a void-argument RNG
    that writes `gRandomSeed16`) in place of the whole dispatcher. **Discharged 2026-10-23:**
    behavior_script.c is linked (TU 43) and `random_float` is walked (`MenuBodies.Hpx_rf`). Also the `sqrtf` entry of `obj_ext_open2_ids` is proved from the FPU floor
    `sqrtf_spec` (3.5) the capstone already takes.
  - The engine rows `Hext_action` / `Hmwf_ext` range over External resolutions; their `T_scm` arm
    no longer applies to anything (set_camera_mode is Internal). Harmless (fewer obligations).
  - **`Hcamera` is GONE (2026-10-22, proved, not restated).** `ExtInert.camera_inert` said the
    external `set_camera_shake_from_hit` changes no block. With camera.c linked it named nothing
    (`csh_ni` was false), and restated over the real body it would be FALSE (the body writes
    `gLakituState`, camera.c:497-507, 4602-4630). Now `gLakituState` is a walk region
    (`FfRun.RLK`, in `R0F` / `gtabF`; `FfWorld.ffw` carries its block and `ff_rl` its pointer;
    `lak_size` bounds its size), so the walks that reach it (act_freefall's fall damage, air_hit_wall,
    the knockbacks) run the REAL `set_camera_shake_from_hit` body (its FALL_DAMAGE / GROUND_POUND paths call `set_camera_pitch_shake` /
    `set_camera_roll_shake`, also real) and the region frame shows they write only `gLakituState`.
    `camera_inert`, `csh_named`, `csh_ni` are deleted; no camera premise is left in the GOAL-2
    capstone (`HeightFrame`), and the rows (`FfRow`, `AhwRow`, `KbRow`, `PoleRow`, `LedgeRow`) and
    `StartSat` provide the new region from the link's symbol table.
- **`update_camera(gCurrentArea->camera)` (camera.c:3011) keeps GOAL 1's facts (2026-10-24,
  `UpdateCameraBody.update_camera_pres`; wired as `HeightFrame.update_camera_ok_linked12`).**
  From any `mem_ok` memory, with a SafeB (or non-pointer) camera argument, the real call returns
  in a `mem_ok` memory. Proved over the generated Clight: 507 walked bodies (camera.c 467,
  audio_external 12, math_util 10, surface_collision 9, ingame_menu 3, behavior_script 2,
  object_helpers 2, save_file 1, hud 1) by `UcKit`'s recursive two-mode class walker. The writable
  tables are covered by type certificates: every linked function of type
  `void (*)(struct Camera *)` is one of the 336 listed (`all_evt_ok`); the 14 transitions as before.
  Five leaves, outside the walk:
  - `sqrtf` (3.5), `play_sound` (AudioBodies), `save_file_do_save` (SaveDoSaveBody, 3.5);
  - `load_sequence`: the existing labeled premise `Hls`;
  - `set_mario_npc_dialog` (mario_actions_cutscene.c:345): PROVED from its body
    (`NpcDialogBody.sp_npc_dialog`). Window store to `actionState`, SafeB `usedObj` store,
    store-free `mario_ready_to_speak`, and GOAL 1's `smact_pres` row for `set_mario_action`.
  `set_hud_camera_status` is walked: hud.c is linked as TU 51 (2.x unchanged: no new UB sites
  or size-0 globals). No new premises: `update_camera_ok_linked12` uses only `Hsqrtf`,
  `Hdma_floor` and `Hls`, all already in the section.
  SafeB claim widened: `CensusV2.camera_safe_syms` gained `gCamera`, `sMarioGeometry`,
  `gLakituState`, `sLuigiCamState`, `gSecondCameraFocus`, `sParTrackPath`,
  `sBBHLibraryParTrackPath` (none in `non_safeb_syms`; `SafeB_boot` contains them).
  FOUND: `gCutsceneFocus` cannot join it; it is a stored global (Mario's end cutscene sets it).
  The tree only reads through it, so it is not needed.
  The vm-pinned store census `uc_census` lists 202 bodies whose stores (or pointer arguments)
  leave the camera-private class. That class is stack locals, the Camera struct and
  `cam_store_ids`, the camera.c globals no other file names. Leaving it: `gPlayerCameraState`
  through `sMarioCamState` (72 bodies) and `sLuigiCamState`; `sCutsceneVars` (82);
  `gLakituState` (22); `gCutsceneTimer` (23); `gCameraMovementFlags` (21); object writes through
  `gSecondCameraFocus` (oBowserCamAct); `gCutsceneFocus`, `gCamera`, `gRecentCutscene`,
  `gObjCutsceneDone`, `gCutsceneObjSpawn`; the surface globals (`gCheckingSurfaceCollisionsForCamera`,
  `gFindFloorIncludeSurfaceIntangible`, `gNumCalls`, `gNumFindFloorMisses`); `gRandomSeed16`;
  `gTimeStopState`; `gGlobalSoundSource`; the dialog globals; the audio state
  (`gSequencePlayers`, the music queue); hud.c's `sCameraHUDStatus`.
  Plus the dirty leaves: the save buffer / EEPROM and Mario's action (`set_mario_npc_dialog`).
  A GOAL 2 invariant carried across update_camera can break at any of these.
- **FOUND FALSE + PROVED (2026-10-22): `WL_exempt`** (every GOAL 1 capstone, and GOAL 2's
  `HeightFrame` section, which copied it). The row said every exempt-whitelist callee evaluates
  to a function whose first parameter is not a MarioState pointer, for ANY environment `e` and
  ANY type: an env binding `sqrtf` to `set_mario_action`'s function block refutes it for every
  link (`WLExempt.wl_exempt_old_refuted`), so the capstones that took it were VACUOUS (phantom
  forall over environments; `LinkedTwelve.v` had flagged the forall but not that it is
  refutable). Its only consumer (`CensusV2.chk_call_marg`) uses it at a censused body, whose env
  is `empty_env`, and at a function-typed Evar. Restated there (`CensusV2.wl_exempt_ok`), it is
  a theorem of the link (`WLExempt.wl_exempt_linked12`: each id resolves to an External or one
  of the eleven lifted real bodies). It is no longer a row of the twelve-TU capstone or of
  `HeightFrame`; the older abstract-`lp` capstones in `NoAImpliesNoFlyLinked.v` keep the
  restated (true) form as a premise.
- **`ingame_menu.c` is linked** (2026-10-22, the 37th TU, `generated/ingame_menu.v`). Reason: the
  terrain loader calls `reset_red_coins_collected`, whose real body writes `gRedCoinsCollected`,
  which had no storage in the link, so the GOAL 2 runs needed a labeled premise for it (`rrc_inert`).
  Now it runs. Its menu strings come from `build/us/include/text_strings.h`, made by the decomp's own
  tool (`tools/textconv` over the preprocessed `charmap.txt`, vendor `Makefile` "Encode in-game text
  strings"; our `Makefile` runs the same recipe, like `mario_anim_data.c`, 0.8(f)). Rows: no capstone
  row or pin changes. The cutscene list rows that name its functions (`create_dialog_box`,
  `create_dialog_box_with_var`, `create_dialog_inverted_box`, `create_dialog_box_with_response`,
  `get_dialog_id`, `set_menu_mode`, `set_cutscene_message`, `reset_cutscene_msg_fade`, in
  `cut_ext_ids` / `obj_ext_ids`) are now claims about real code. Re-audited by reading the bodies
  (`ingame_menu.c:1075-1106, 2156-2164, 2228-2238`): each only loads and stores integers in
  ingame_menu.c globals (SafeB, not Mario's block, not a stored global, no calls), so each row
  (`call_pres_ext`: Mario's block valid and untainted, MWF, NoA kept) is true. They are still assumed
  (a walk would make them lemmas). **CORRECTED 2026-10-23 (the walk, `MenuBodies`):** one of them
  was FALSE as stated: `create_dialog_box_with_var` stores its s32 ARGUMENT `dialogVar` into the s32
  `gDialogVariable` (ingame_menu.c:1089), so a pointer argument lands in a block nothing kept out of
  SafeB (R7). `gDialogVariable` joined `CensusV2.stored_globals`; all eight are lemmas now (below). The 2.4 common for `gDialogResponse` now merges with its real
  definition. New externals it declares (`gu*`, `play_*`, `seq_player_*`, `alloc_display_list` is
  linked) are reached only from its menu / dialog rendering code, which no run or row reaches.
- **THE EXTERNAL-LIST CLOSURE (2026-10-23): `Hpres_obj_ext_open2`, `Hpres_cut_ext_open2`,
  `Hpres_floors_ext_open` and `Hpres_warp_ext_open` are GONE from both capstones** (GOAL 1 13 -> 9
  `Hypothesis` lines, `HeightFrame` 20 -> 16). Each list was "calling fid (any args) keeps the
  carried facts"; every remaining id now has a linked body that is walked:
  - `warp_ext_open_ids` was already EMPTY after the audio link (`warp_ext_open_nil`): the row
    was a vacuous premise.
  - `cut_ext_open2_ids` (7: the four dialog-box constructors, `get_dialog_id`, `set_menu_mode`,
    `set_cutscene_message`) and two of `obj_ext_open2_ids` (`reset_cutscene_msg_fade`,
    audio/external.c's `drop_queued_background_music`): `MenuBodies`, ObjExtBodies' `ast_ok`
    class (non-pointer stores into globals MWF does not read). FOUND FALSE first:
    `create_dialog_box_with_var` (above); `gDialogVariable` joined `stored_globals`.
  - `random_float` (the last obj entry): **`engine/behavior_script.c` is linked (TU 43)**;
    `random_float` -> `random_u16` is a u16 read-modify-write of `gRandomSeed16`
    (`MenuBodies.Hpx_rf`). No row was false.
  - `spawn_default_star` (the floors entry): **`game/obj_behaviors.c` is linked (TU 44)**; its
    body and `spawn_star`'s are walked (`SpawnStarBody`: `spawn_star` in SpawnBodies' SafeB world
    over the proved `spawn_object_abs_with_rot`; `spawn_default_star`'s float arguments reach
    `spawn_star` through a cast to float, so the row holds for ANY arguments). FOUND (the §7
    SUSPECT, confirmed): the spawned script `bhvStarSpawnCoordinates` is stored into the new pool
    object and was not a SafeB symbol, so the row rested on nothing (R7). It joined
    `CensusV2.spawn_bhv_syms` (so `safe_ptr_syms`, the class of every other spawned script;
    `SafeB_boot` contains it). `SpawnBodies.sb_gs` gained `gCurrentObject` (already a
    `safe_ptr_syms` member) and the script.
  Both new TUs pass the pairwise link check; `tools/size0_globals.py`: 44 TUs, 0 failing (no 2.4
  completion needed). No other capstone row names a function they define (checked by grep over
  the spine). `CameraBodies.rf_no_internal` (random_float has no body) became false and is deleted.
- **`spawn_sound.c`, `debug.c`, `object_collision.c` linked** (2026-10-24, TUs 47-49;
  OBJECTS S1). Groundwork for running the real `update_objects`. TUs 45/46 are
  `platform_displacement.c` / libultra `osContStartReadData` (spliced in by the master merge;
  TU 51 reserved for `hud.c`). Recipe `SM64_CGP` (the game TU recipe).
  `tools/ub_sites.py`: no site in the two new
  files (header rows only). `object_collision.c:61,96` keeps its 2.2 row, now a picked value
  in the link. 2.4: `gDebugInfoOverwrite` joined the table (pairwise link check); `gDebugInfo`,
  `gDebugLevelSelect`, bhv decls by existing rules. Pairwise link check passes.
  `tools/size0_globals.py`: 47 TUs, 0 failing. No capstone row names a function they define;
  counts unchanged. No spine walk reaches them yet (S3 does).
- **`obj_behaviors_2.c` linked** (2026-10-24, TU 50; `SM64_CGP`, committed file regenerates
  byte-identical). Reason: `bhv_red_coin_star_marker_init` is a live WMotR native. Its 2.2
  sites (`camera_lakitu.inc.c:65`, `wiggler.inc.c:154`, `obj_behaviors_2.c:127`) are now
  picked values in the link. Like `obj_behaviors.c`'s, none is in the WMotR closure
  (`ub22_sites_not_live`). size0: 48 TUs, 0 failing (50 after the master merge). Counts unchanged.
- **WMotR's level script and `engine/level_script.c` linked** (2026-11-01, TUs 52 / 53; GOAL 2
  real-order witness). `levels/wmotr/script.c` gives the OBJECT commands' words (the six
  poles, the red-coin star, the entry warp) as data; `level_script.c` gives the real
  `level_cmd_place_object`, which the witness runs per OBJECT command to build the area's
  `SpawnInfo` list. Recipe `SM64_CGP` (both). 2.4: `gAreaData` table entry and the
  readonly-false level-data declarations (above). `tools/ub_sites.py level_script`: header rows
  only, plus `level_script.c:289` (the `gFramebuffers` 2.2 row). Pairwise link check passes
  (`LinkedTwelve`, `LptBody` no-internal lemmas). size0: 53 TUs, 0 failing, after a new
  BOOT_KNOWN class: `level_script_execute` ends in `render_game()` (`level_script.c:836`), so
  31 render-path display lists / glyph tables / shadow flags of unlinked definers became
  boot-reached (class (c); none is frame-reached). `RoCensus.init_refs_count` 51 → 54 (the
  three WMotR level scripts' `Init_addrof` words). FOUND while linking: the 61 `void(void)`
  `level_cmd_*` handlers are address-taken (`LevelScriptJumpTable`), so the type-exact
  `ActWriterCensus.clos` let every `void(void)` call site of the objects / camera closure reach the
  whole level loader (2217 → 2423 functions, with spurious `set_mario_action` events). Repaired by
  `ActWriterCensus.dispatch_confined` (vm-checked): the table's only reader is
  `level_script_execute`, no initializer holds its address, `level_script_execute` lets no
  function-pointer value out (no store / argument / return of function-pointer type), and it is
  not in `clos`; so the table is not counted, `clos` is 2217 again and `census_value` unchanged.
  `FnPtrCensus`: init sites 507 → 568 exact (the table) and 751 → 753 erased (two
  `lvl_init_or_update` words, `int(short,int)`, in `level_wmotr_entry`'s CALL / CALL_LOOP
  commands; `init_ok` admits them for the level scripts at that type); three new pun sites
  (`level_cmd_call`, `level_cmd_call_loop`, `level_cmd_begin_area`), all outside `clos`, at
  types no call site of `clos` has; re-entry / exit / read censuses unchanged. No capstone row names a function they define.
- **`execute_mario_action`'s argument is unused** (2026-10-24,
  `RealFrameLinked.execute_mario_action_step_lp_any`, over `Generic/UnusedParam`). The frame
  relation's `Vptr b 0` pin is no restriction: a call with ANY argument (the real
  `&gObjectPool[k]`) is a `step_lp` step, and conversely. No trust moved.
- **`debug_course.c` is linked** (2026-10-22, the 38th TU): its only function is the empty
  `nop_change_course`, which the real `lvl_set_current_level` calls on a course change, so
  `CourseRun` runs that function with no external answered. No row names it.
- **Labeled open AUDIO premise `BootRun.audio_ret` (2026-10-22; GONE 2026-10-23).** It said
  `play_sound`, `play_infinite_stairs_music` and `set_sound_moving_speed` return `Vundef` with
  linked memory unchanged. Since the audio link (below) the boot frames run their real bodies, and
  `BootRun.world` answers no audio external.
- **The audio link (2026-10-23): `audio/external.c` and `game/sound_init.c` are TUs 40 and 41**
  (`generated/audio_external.v`, `generated/sound_init.v`). They are the GAME-THREAD side of audio:
  `play_sound`, `stop_sound(s)`, the music queue, the volume fades and the background-noise / cap /
  shell music wrappers. The audio THREAD (synthesis, the sequence player, the RSP task) stays out of
  scope: no new trust row for it.
  - **GOAL 1, proved from the real bodies (`AudioBodies`):** `Hpres_sta_ext` (now a lemma), `Hsss`
    (`stop_sounds_from_source`'s row, gone: `SpawnBodies` walks the body), the audio entries of
    `Hpres_obj_ext_open2`, `Hpres_cut_ext_open2` and `Hpres_warp_ext_open` (each list filtered by
    `AudioBodies.audio_id`), and `Hpres_floors_ext` (now a lemma over the narrower
    `Hpres_floors_ext_open`: `spawn_default_star` alone). The rest-surface pins: `play_sound`,
    `stop_cap_music`, `fadeout_cap_music` left the exempt whitelist (`RestSurface.lifted_ids`), and
    `play_infinite_stairs_music` left `Hrest_ext_only`; all four are pinned rest cases whose body
    residuals the twelve-TU capstone proves (`Hps_body_real` etc.).
  - **`Hext_action_ns` / `Hmwf_ext_ns` are lemmas.** `RestSurface.rest_external_cases` proves that a
    reached External resolves `sqrtf` (every other rest id is defined by a linked TU), and sqrtf
    is the FPU floor.
  - **THE PRINT LINK (2026-10-23): `Hext_action_ptfi` / `Hmwf_ext_ptfi` are GONE (both
    capstones).** `game/print.c` is the 42nd TU, so `print_text_fmt_int` is a pinned rest case
    (`RestSurface.lifted_ids`) whose gated body residual is PROVED from the real body together
    with `memory.c`'s `mem_pool_alloc` (`PrintBodies.Hptfi_body_proved`, a class walker: every
    store lands in a SafeB pool block or a fresh stack local). FOUND FALSE first: the rows'
    any-argument / any-pool form. `label->x = x` stores the argument into the pool label, so a
    pointer `x` breaks R7, and with the pool globals outside SafeB nothing keeps the free-list chase
    off Mario's block. RESTATED: the call gate `CensusV2.T_ptfi` (x, y, n not pointers; discharged
    at mario.c's three call sites by `wargs_chk`) and `gEffectsMemoryPool`, `sTextLabels`,
    `sTextLabelsCount` joined `safe_ptr_syms` (`CensusV2.print_safe_syms`; `SafeB_boot` already
    contains them, so the boot witness is unchanged). No new trust row; no BSS completion was needed
    (`tools/size0_globals.py`: print.c's size-0 HUD externs are class (b), unreached).
  - **New labeled open AUDIO premise `Hls` (both capstones): `load_sequence`** (audio/load.c, not
    linked: the sequence DMA into the audio heap) keeps the carried facts (`call_pres_ext`). The
    music-starting bodies (`play_infinite_stairs_music`, `stop_cap_music`, the cap/shell music
    wrappers) reach it through `seq_player_play_sequence`. It is narrower than every row it replaces.
    **Read 2026-10-24** (US path: load.c, heap.c, seqplayer.c, playback.c, synthesis.c): every store
    lands in audio state: `gAudioLoadLock`, `gSequencePlayers`, the two loaded pools, `gAudioHeap`
    (pools, notes, banks), or load.c globals with no block in the model. AudioInv
    (`WMotRRequiresA/AudioInv.v`, 2026-11-02) is checked on a model audio state that is all
    zeros, because audio_init and the audio thread are not linked. The real driver's channel /
    layer / note pointers live outside the model, so `ls_frame_ai`'s preservation of AudioInv is
    part of the labeled audio trust, not evidence about the real driver. **Scoping TODO:**
    `disable_all_sequence_players` (linked) passes `&gSequencePlayers[i]` to the unlinked
    `sequence_player_disable`, which is another unlinked audio call to scope the same way if it
    is reachable on the WMotR path. The DMA / message calls are
    3.5. The footprint form (`ls_contract` = `call_pres_ext` + `ls_frame`, the blocks of
    `ls_ids`: `gAudioLoadLock`, `gSequencePlayers`, the two loaded pools, `gAudioHeap`; memory
    may grow, the new blocks freed) is `WMotRRequiresA/LsContract.v`. `ObjFrame`'s whole-walk
    frame takes it, and **since 2026-10-25 GOAL 2's `Hls` is `LsContract.ls_contract`** (its
    first half is the old `Hls`), consumed by NaSplit's hitbox row through the cap-music frames
    of `CapAudio.v` (on the spine). This is the one trust the hitbox row adds (it is what the US
    load.c read above says); discharge path: link load.c / heap.c / seqplayer.c / playback.c
    and walk them.
    **FALSE AS STATED (unscoped, marked 2026-11-02).** `ls_frame` claims the footprint for
    EVERY memory. But load.c's pointer stores (pool cursors, note / layer lists, bank-patch
    pointers) go through pointers read from memory. The read above holds only "given the audio
    driver's own invariants". So in a memory where those pointers aim at, say, Mario's object,
    the real load_sequence writes outside `ls_ids`, and the row is a phantom ∀. Audio may stay a
    labeled open premise, but not a false one.
    **Fix (2026-11-02, landing in stages):**
    - DONE: `AudioInv.AudioInv G m`. Every pointer loaded from an `ls_ids` block points into
      an audio block (`aud_ids` = `ls_ids` + `gSequenceChannelNone`, the disabled-channel
      sentinel). This is the model-level form of the header's "pointer stores stay inside
      those" (pool cursors, player / note / layer / bank pointers). It has a decision
      procedure `aud_chk` (`aud_chk_sound`).
    - DONE: the restatement `AudioInv.ls_frame_ai`: AudioInv m → only the `ls_ids` blocks
      change (Q2) ∧ AudioInv m'.
    - DONE: the boot check (`AudioBoot.audio_inv_boot`, vm). AudioInv holds on `Genv.init_mem`
      and on the start witness (StartTerrain's chain, rebuilt by `AudioBoot.wit11`). A probe
      also found no global in either memory holding a pointer into the audio set.
    - Census (generated AST, all linked TUs):
      - no linked code mentions `gAudioHeap`;
      - the pools appear only in `unused_8031E4F0`;
      - `&gSequencePlayers[p]` lives only in temps and is never stored to memory.
    - DONE: wired through the consumers, from `ls_frame_ai` alone (no use of the false
      `ls_frame`).
      - `AudioWire`: the cap music path's frames carry AudioInv (`afi`: CapAudio's Q2 frame
        plus AudioInv). Every store's root is not an `ls_ids` global, or its value is never a
        pointer, so no pointer enters an audio block (`Mem.load_pointer_store`). It also has
        `ucf_frame_ai`.
      - `HitboxFrame.ucf_hole_ai` / `hitbox_hh_ai`: `hitbox_hh` (its frame and Mario's
        hitboxHeight) from an AudioInv memory, with AudioInv after.
      - `CamFootInst` (step (a), 2026-11-02): the camera's footprint walk carries AudioInv;
        its load_sequence leaf is `ls_frame_ai`, the seven sequence-player bodies are leaves
        walked by AudioWire (`cai_*`, footprint `cam_aud_ids`).
      - Not yet wired: `ObjFrame`'s whole-walk frame (off the spine, its row labeled).
    - DONE (the deferred root rebuild, 2026-11-02): AudioInv is `FfWorld.lvl_w`'s eighth
      clause `aud_w` (`AudioInv.aud_w_eq`), carried by every phase:
      - footprints that avoid `ls_ids` keep it (`LevelKeep.aud_w_fx`, `FfWorld.lvl_w_unch`);
      - the level phase's walks write `gSequencePlayers` (the fades), so `LevelWalk`'s walker
        gained the stored-value check (`AudioWire.ai_store_ok` in `lv_store_ok`) and carries
        AudioInv (`lfun_ai`, `lv_stmt_ai`); every level callee passes it;
      - the hitbox row (NaSplit) takes AudioInv after the hole from `hitbox_hh_ai`
        (`HoleX.hx_lvl` keeps the non-audio part of lvl_w).
      The spine's `Hls` is now `AudioInv.ls_contract_ai` (`call_pres_ext` + `ls_frame_ai`).

    Consumers on the spine: CapAudio / AudioWire / NaSplit (the hitbox row) and, since step (a)
    (row 0.7), CamFootInst / CamRows (the camera's footprint), all from `ls_frame_ai`; the
    unscoped `ls_frame` is used by no spine file.
  - **GOAL 2 (`SndXc`):** `play_sound` and `set_sound_moving_speed` store at an index read from
    memory, so the walks cannot run them store by store. Each call is a CLOBBER contract over the
    regions of the globals it writes (`FfRun.RSR` / `RSRC` / `RSMS`: `sSoundRequests`,
    `sSoundRequestCount`, `sSoundMovingSpeed`, each 2^32 bytes at base 0), proved from the
    generated body: `AudioBodies.fp_body` walks it (every store lands in a named global's block),
    and the footprint gives `SmaXc.sstores_havoc_cl`'s frame premise. The three blocks are walk
    regions in every walk and members of `FfWorld.ff_rl` (the frame world proves the world objects
    are off them; `StartSat` on the witness). `ExtInert.audio_inert` (`Haudio`) is deleted.
  - **Stored globals.** `play_sound(soundBits, pos)` stores its POINTER argument `pos` into
    `sSoundRequests[n].position` (external.c:818); only the audio thread reads it back.
    `sSoundRequests` joined `CensusV2.stored_globals` (the `D_8032CE74` / `D_8032CE78` precedent:
    a model claim on the existing class, so SafeB avoids its block), rather than gating each call
    site.
  - **Extern completions (2.4):** `gResetTimer` 1 (main.c), `gSoundMode` 1, `gSequencePlayers` 960,
    `gSequenceChannelNone` 192 (audio/load.c). `tools/size0_globals.py`: 0 failing.
- **`audio/data.c` is linked** (2026-10-20, the 18th TU, `generated/audio_data.v`): it is the only
  definer of `gAudioRandom`, which `play_mario_jump_sound` reads (mario.c:254). Before, it was a
  size-0 extern in the boot image, so every path of dive and the rollouts that plays a jump sound
  had no execution, and a theorem about those handlers would have said nothing about them (a
  phantom-path finding, fixed before those walks were written). Its value is still whatever the
  audio thread left (3.3); the walks read it as unknown.
- **Collision is linked** (2026-10-17, `LinkedTwelve.tu_rest`): `find_floor`, `find_ceil`,
  `f32_find_wall_collision`, `find_wall_collisions`, `find_water_level` and `find_poison_gas_level`
  run their real generated bodies, and their rows are now lemmas (`SurfaceBodies.v`; the GOAL-1
  capstone went from 36 to 31 hypotheses, `vec3f_find_ceil` included via `RestSurface.vfc_walk`).
- **`math_util` is linked** (2026-10-17, the 14th TU). 11 TUs declared `extern f32 gSineTable[]`
  (`tarray tfloat 0`) against `math_util`'s 5120 entries, so `pipeline/clightgen.sh`'s extern-array
  completion table gained a `gSineTable 0 -> 5120` entry (an instance of 2.4, like `gMarioStates`).
  `Linked12Sat`'s certificate checks the 14-TU chain. The four engine-whitelisted ids `math_util`
  defines (`vec3f_set`, `vec3f_copy`, `vec3s_copy`, `atan2s`) now resolve to their real bodies,
  pinned by `LO_math`, and each is a proved rest case (`MathBodies.v`).
- **Four math_util rows are now lemmas** (`MathBodies.Hdg_*_proved`): `Hdg_v3f_real`,
  `Hdg_v3fset_real`, `Hdg_v3scopy_real` and `Hdg_v3s_real` are proved from the real `vec3f_copy` /
  `vec3f_set` / `vec3s_copy` / `vec3s_set` bodies. Each gate case (SafeB, 12-byte-safe Mario window,
  stack local) makes the destination store-safe. The destination is also always a block that was
  valid at the call: it cannot be the body's own fresh `_dest` shadow, because the first element
  store would clobber the saved pointer and the next reload-and-dereference would fail
  (`vec_*_out_valid`). The GOAL-1 capstone goes from 31 to 27 hypotheses.
- **The pure math rows are lemmas too** (`MathBodies.MathPure`): the real `approach_f32` /
  `approach_s32` bodies have no locals and no stores, and `atan2s` stores nothing either (its one
  callee `atan2_lookup` is pinned and store-free), so a call leaves memory identical.
  `Hpres_mov_ext` (its list is just `approach_f32`), `Hcpx_approach_f32_real` and
  `Hcpx_approach_real` are lemmas. `Hpres_obj_ext` is a lemma over the narrower row
  `Hpres_obj_ext_open` (`obj_ext_ids` minus `atan2s` / `approach_s32`). The capstone goes from 27 to
  24 hypotheses.
- **The spline pair is proved too.** `anim_spline_init` stores only the three `math_util` spline
  statics (`gSplineKeyframe`, `gSplineKeyframeFraction`, `gSplineState`), which are now in
  `CensusV2.stored_globals`. They are static data symbols, disjoint from `bm`/`bc`/SafeB by the same
  proved `glob_blk` argument as the other stored globals. So its `obj_ext_ids` entry is a lemma
  (`MathBodies.Hcpx_asi_proved`). `Hdg_spoll_real` is a lemma (`MathBodies.Hdg_spoll_proved`):
  `anim_spline_poll` is walked by a small out-pointer walker (`ow_walk`). It stores `result[0..2]`
  (the `dg` gate's 12 store-safe bytes) and the spline statics, and it calls `vec3f_copy(result,
  ..)` (the real body, same gate) and `spline_get_weights(weights, ..)` (its real body, walked; it
  stores only into the caller's fresh local `weights`). The capstone goes from 24 to 23 hypotheses.
  `Hscp_mtxf_real` (`mtxf_align_terrain_triangle`) was the last math_util row.
- **It is a lemma since 2026-10-21** (`MtxfBody.Hscp_mtxf_proved`), proved from the real body: it
  stores floats only through its never-reassigned arg0 (the gate's SafeB matrix) and into its own
  stack arrays, and every callee is a real body with a stack-local destination (`find_floor` with
  `&sp74`; `vec3f_set`, `find_vector_perpendicular_to_plane`, `vec3f_normalize`, `vec3f_cross`).
  `vec3f_normalize` reloads its saved `dest` after the external `sqrtf`, so the proof rests on the
  FPU floor `sqrtf_spec` (3.5): a model row is swapped for a hardware floor already on the ledger.
- **Found false (2026-10-17):** `Hpres_obj_ext` and `Hpres_mov_ext` are ungated `call_pres_ext` rows
  (any arguments), and their id lists include math_util writers: `vec3f_copy`, `vec3f_set`,
  `vec3s_set`, `vec3s_copy`, `anim_spline_poll` and `mtxf_align_terrain_triangle`. Each of these
  writes through a pointer argument, so with that argument pointing at Mario's action cell or the
  controller the row is false of the real code. Linking math_util would make the capstone's
  hypothesis set unsatisfiable. Those entries must be restated as per-call-site gated rows (the
  `sc`/`w1`/`wl` forms that already exist) before math_util is linked.
- **Also false (found the same day):** `Hwolcp_v3f_real` (`call_pres_ext_wol vec3f_copy`). Its gate
  accepts any pointer argument that is a 4-byte-safe Mario window cell. `store_window_ok 8 4` holds
  (`particleFlags`), but `vec3f_copy` writes 12 bytes from there, covering the action cell at 12.
  The real call sites it serves all have a stack-local destination (`act_walking`'s `startPos`,
  `perform_air_step`'s `nextPos`), so it can be restated as a local-destination row.
- **Restated (2026-10-17):** the writer entries are gone from `obj_ext_ids` / `mov_ext_ids` and
  `Hwolcp_v3f_real` is deleted. In their place are five destination-gated `call_pres_ext_dg` rows
  (`Hdg_v3f_real`, `Hdg_v3s_real`, `Hdg_v3fset_real`, `Hdg_v3scopy_real`, `Hdg_spoll_real`). Each
  says: if arg0 is a SafeB object block, a 12-store-safe Mario window, or a caller stack local, the
  call preserves the carried facts. There is also one sc-gated `Hscp_mtxf_real` (arg0 SafeB; the
  64-byte matrix write rules out the window case). The walkers check the gate at every real call
  site against the generated AST: dst chase temps (`chase_root_sound_proved`), census locals,
  `&sFloorAlignMatrix[..]` (`awf_mtx_gate`). The old `sc`/`w1`/`wl` writer rows are now lemmas
  derived from `dg`.
- **Also found false and restated:** `Hscp_geo_real`. `geo_update_animation_frame(obj, accelAssist)`
  writes only through `accelAssist` (`graph_node.c:797,834`), and the `sc` row left that argument
  free. It is now `Hgeo_real : call_pres_ext_geo`, which pins `accelAssist = NULL`, the shape of the
  one real site (`mario.c:187`), checked at that site. Net: the GOAL-1 capstone goes from 31 to 29
  hypotheses (9 writer rows out; 5 `dg` + `mtxf` + `geo` in), and each restated row is now true of
  the real bodies as far as we know.
- **Also found false and restated (2026-10-17):** `cut_ext_ids` contained `obj_scale` and
  `obj_mark_for_deletion` as ungated `call_pres_ext` rows, and both write through their object
  argument (`object_helpers.c:705,1135`). They are out of `cut_ext_ids`. In their place are two
  arg0-gated `call_pres_ext_cs` rows (`Hcsp_omfd_real`, `Hcsp_scale_real`): if arg0 is a pointer, it
  points into a SafeB block. Every real site (`intro_cutscene_lower_pipe`, `end_peach_cutscene_*`)
  passes a chase temp loaded from a cutscene object global (`sIntroWarpPipeObj` / `sEnd*Obj`, SafeB
  via `Hglob_obj_root`). The seeded walkers check this against the generated AST. Net: the GOAL-1
  capstone goes from 29 to 31 hypotheses (the `cut_ext` row stays; two true `cs` rows are added).
- **Also found false and restated (2026-10-18):** `load_patchable_table` was an ungated
  `obj_ext_ids` entry, but its body (`memory.c:567`) stores `list->currentAddr` and DMAs into
  `list->bufTarget`, both through arg0. With arg0 at Mario's action cell the row is false, so
  linking `memory.c` (needed to see Mario's cells survive `set_mario_animation` in GOAL 2) would
  make the capstone's hypotheses unsatisfiable. It is out of `obj_ext_ids` and in `objw_ids`. In its
  place is one arg0-gated row, `Hcsp_lpt_real : call_pres_ext_cs`. Both real sites
  (`set_mario_animation`, `set_mario_anim_with_accel`) pass the chase temp `m->animList`, and the
  leaf walkers check this against the generated AST. The capstone goes from 31 to 32 hypotheses. The
  row is true of the real body as far as we know.
- **`memory.c` is linked** (2026-10-18, the 15th TU; `LinkedTwelve.tu_rest`, `linked12_LO_memory`,
  and Linked12Sat's certificate checks the chain). `load_patchable_table` and `dma_read` run their
  real bodies. The only externals under `set_mario_animation` are now the libultra DMA calls
  `osInvalDCache` / `osPiStartDma` / `osRecvMesg`.
- **`Hcsp_lpt_real` is now a lemma** (2026-10-18, `LptBody.Hcsp_lpt_linked12`), proved from the real
  `load_patchable_table` and `dma_read` bodies (a chase walk: every pointer the bodies hold is
  loaded through the SafeB list, so R7 keeps it SafeB; the one store, `list->currentAddr = addr`,
  stores such a pointer into the list; `dma_read`'s loop is walked). It now rests on the hardware/OS
  floor 3.5 instead of being a row. The three DMA globals joined `CensusV2.stored_globals`, so the
  proved `glob_blk` keeps their blocks off `bm`/`bc`/SafeB.
- **Found false (2026-10-19): `HSafeB_sym_iff`, the SafeB symbol row of both capstones.** It said
  SafeB meets the linked symbol table in exactly `{sFloorAlignMatrix}`. `init_mario_from_save_file`
  (`mario.c:1874–1879`) stores `&gMarioAnimsBuf`, `&gBodyStates[0]` and `&gPlayerCameraState[0]`
  (linked BSS symbols, not runtime pool blocks) into chase-root cells, so `MWF_real` R6 forced them
  into SafeB, and R7 forces every symbol the object graph points at (`o->behavior`, collision data).
  So `MWF_real` was false of every real gameplay memory and both capstones were vacuous for the real
  game.
- **Restated** as `HSafeB_syms : SpawnInit.SafeB_syms_ok`: SafeB avoids `non_safeb_syms` (Mario's
  block, the controllers, `gMarioState`, the timer, the handler/knockback tables, the stored
  globals) and contains `sFloorAlignMatrix`. It is one-directional, so it is weaker and the
  capstones are stronger. The real SafeB is the pointer closure of the chase roots, and the row says
  that closure never reaches those blocks (`docs/p5-safeb-design.md`).
- **Also found (2026-10-19): the animation list as a SafeB chase root.** Putting `gMarioAnimsBuf` in
  SafeB (the first repair) would let the GOAL-1 SafeB chase stores, which are offset-free, reach the
  list's `dmaTable` / `currentAddr` / `bufTarget` cells, and nothing kept the DMA buffer
  `list->bufTarget` off Mario's object, so GOAL 2's `Hframe_*` rows were false (a DMA into
  `marioObj` would rewrite `gfx.pos[1]`).
- **Repaired:** `m->animList` is no longer a chase root. `MWF_real` gained R11–R14: `animList`, if a
  pointer, is `&gMarioAnimsBuf` (offset 0); every pointer loaded from the list block is SafeB; the
  DMA buffer is not the block of `m->marioObj`; the list block is valid and apart from `bm`, `bc`
  and SafeB. `gMarioAnimsBuf` joined `non_safeb_syms`. Root-cell stores now exclude `m->marioObj`
  (no frame body writes it). `Hcsp_lpt_real` is gone. In its place `set_mario_animation` and
  `set_mario_anim_with_accel` are **proved** from their real bodies (`LptBody.sma_row_linked12` /
  `smawa_row_linked12`), with `load_patchable_table` walked under the pinned list down to the DMA
  floor 3.5. The Twelve and HeightFrame capstones' assumed surfaces are unchanged: the two rows are
  lemmas there (the intermediate `NoAImpliesNoFlyLinked` section takes them as two hypotheses in
  place of the one lpt row).
- **Found false (2026-10-19): `Hglob_obj_root`** (all three capstones). It said a pointer loaded
  from one of the five cutscene object globals (`sIntroWarpPipeObj`, `sEndPeachObj`,
  `sEndRightToadObj`, `sEndLeftToadObj`, `sEndJumboStarObj`) is SafeB, in every MWF memory. Those
  globals were in `stored_globals`, and MWF does not constrain a stored global's contents. So a
  memory with `sIntroWarpPipeObj = &gMarioStates` is MWF, and the row fails there. This was checked
  in Coq: at the boot image with `SafeB_boot`, the row implies `False`. The capstones were therefore
  vacuous, including the new from-boot theorem.
- **Repaired:** the five globals are SafeB blocks (`SpawnInit.SafeB_syms_ok` (c),
  `CensusV2.gobj_syms`). MWF's load-closure row R7 is now the invariant, and the old row is a lemma
  (`CutsceneLeafSurface.HGlobObjRoot`). Their only writers are `g = spawn_object_abs_with_rot(..)`
  (`intro_cutscene_peach_lakitu_scene`, `end_peach_cutscene_mario_landing` / `_spawn_peach`,
  `act_end_waving_cutscene`). These are walked by two new arms: the spawn call puts its result in a
  chase temp, and the store of a chase temp into a SafeB global is a `chase_ptr` store. The spawn
  result is SafeB by a new sr-form row `Hcp_soawr_real : call_pres_ext_sr
  spawn_object_abs_with_rot`, the same model class as the existing `Hcp_spawn_real` for
  `spawn_object`. Its plain entry left `cut_ext_ids` (`Hpres_cut_ext_open`). Net: the hypothesis
  count is unchanged (one false memory row out, one external-contract row in), and the replacement
  is true of the real code as far as we know: spawned objects come from `gObjectPool`.
- **Found false (2026-10-20): `obj_set_held_state` in `obj_ext_ids`** (all three capstones). That
  entry said the call preserves Mario's cells for any argument, but its body
  (`object_helpers.c:267`) stores `obj->parentObj = o` and `obj->oHeldState` through arg0. With arg0
  at Mario's cells the row is false, so the hypotheses were unsatisfiable on such memories.
- **Repaired:** it left `obj_ext_ids` (and is in `objw_ids`). In its place is one arg0-gated row,
  `Hcsp_osh_real : call_pres_ext_cs` (same class as `Hcsp_omfd_real`). All three real sites
  (`mario_grab_used_object`, `mario_drop_held_object`, `mario_throw_held_object`) pass a chase temp
  loaded from `m->heldObj`, checked against the generated AST by the leaf walkers. The stored value
  is `gCurrentObject`, so `gCurrentObject` is now a SafeB block too (`CensusV2.safe_ptr_syms`; no
  linked code stores it, and `BootMWF` re-proves the boot state with it). Net: one more hypothesis
  (a true `cs` row), and the any-argument list loses one entry.
- **`game_init.c` (16th TU) and `object_list_processor.c` (17th TU) are linked** (2026-10-20), so
  `gControllers`, `gMarioAnimsBuf`, `gObjectPool`, `gDebugInfo` and `find_floor`'s counters have
  their real storage. No capstone row changed; `LinkedTwelve.linked12_ext_pin` and
  `LptBody.os_resolve` gained the two cases (neither TU defines a pinned external).
- **Premise sweep (2026-10-20):** `segmented_to_virtual` and `virtual_to_segmented` were still
  entries of the any-argument object-external row although `memory.c` (linked since 2026-10-18)
  defines them. Their real bodies have no locals, stores or calls, so their entries are now lemmas
  (`MathBodies.Hcpx_s2v_proved` / `_v2s_proved`); both capstones' row is the narrower
  `Hpres_obj_ext_open2` (`NoAImpliesNoFlyTwelve.obj_ext_open2_ids`).
- **Found false (2026-10-20): `set_camera_mode` as an any-argument row** (all three capstones, two
  places). `set_camera_mode(c, mode, frames)` stores `c->mode` (and, through the mode-transition
  callbacks, more of `*c`) via arg0 (`camera.c:2854`), yet it sat in `obj_ext_ids` (the leaf
  walkers' `Hcpx_scm` rows) and in `CensusV2.exempt_callees`, whose external rows `Hext_action` /
  `Hmwf_ext` held for any arguments. With arg0 at Mario's cells those rows are false, so the
  hypotheses were unsatisfiable on such memories.
- **Repaired:** it left `obj_ext_ids` (and is in `objw_ids`); in its place is one arg0-gated row
  `Hcsp_scm_real : call_pres_ext_cs` (camera stays a labeled deferred premise). Every real site
  (`update_mario_sound_and_camera`, `set_water_plunge_action`, `transition_submerged_to_walking`,
  `set_submerged_cam_preset_and_spawn_bubbles`, `act_water_jump`, `act_hold_water_jump`,
  `act_first_person`, `act_teleport_fade_in`, `act_credits_cutscene`, `reset_mario_pitch`; also
  `act_flying`, `act_flying_triple_jump`, `act_shot_from_cannon`, which are not walked yet) passes
  `m->area->camera`; to check that against the generated AST, `m->area` is now a chase root
  (`CensusV2.chase_root_fields`, offset 144; `StartSat` shows the init store `m->area =
  gCurrentArea` keeps MWF), and the walkers table the `->area` / `->camera` load temps as chase
  temps. The engine's external rows `Hext_action` / `Hmwf_ext` now take the census's per-call
  argument gate (`wgate`, with a new `T_scm` arm: arg0 SafeB), so they too are true of the real code
  as far as we know. Net: one more hypothesis (a true `cs` row); the any-argument list loses one
  entry and the engine external rows are narrower.
- **Premise sweep (2026-10-20): the bully rows are lemmas.** `init_bully_collision_data` and
  `transfer_bully_speed` are `mario_step.c` bodies, in the link since GOAL 1, yet both capstones
  took them as rows (`Hcpx_ibcd_real`, `Hcpx_tbs_real`). Their real bodies have no locals and no
  calls, and every store goes through a pointer parameter that the rows' gates put in a caller stack
  block, so both are proved (`BullyBodies.Hcpx_ibcd_proved` / `_tbs_proved`, a frozen-pointer-temps
  walk over the generated AST). Two fewer hypotheses on each capstone.
- **Premise sweep (2026-10-20): `engine/graph_node.c` is linked (the 19th TU,
  `generated/graph_node.v`), and the two animation rows are lemmas.**
  `retrieve_animation_index(frame, attributes)` stores only `*attributes += 2`, through its last
  parameter, which the `oc` gate puts in a caller stack block. `geo_update_animation_frame(obj,
  accelAssist)` stores only `*accelAssist`, each store under `accelAssist != NULL`, and the `geo`
  gate pins `accelAssist = NULL`, so neither store can run. Both bodies have no locals and no calls,
  and both are proved by the frozen-pointer-temps walk (`GraphNodeBodies.Hgeo_proved` /
  `Hocp_rai_proved`). `Hgeo_real` and `Hocp_rai_real` are lemmas in `NoAImpliesNoFlyTwelve`, and
  `HeightFrame` no longer takes them. `Linked12Sat`'s certificate checks the 19-TU chain. Two fewer
  hypotheses on each capstone.
- **Premise sweep (2026-10-21): `game/save_file.c` and `buffers/buffers.c` are linked (TUs 20 and
  21), and `Hcp_savefile_real` is a lemma** (`SaveFileBody.Hcp_savefile_proved`). `buffers.c` holds
  the real storage of `gSaveBuffer` (without it the buffer is a size-0 block and every save-file
  store a phantom path). Linking needed four extern-array completions (2.4). The real
  `save_file_set_cap_pos` stores `capLevel` / `capArea` through `saveFile =
  &gSaveBuffer.files[gCurrSaveFileNum - 1][0]`, which is an address chain from the global (no load),
  so a pointer into `gSaveBuffer`'s block whatever the file number. It then calls the real
  `vec3s_set(saveFile->capPos, ..)` (the shadow-dest walk, `MtxfBody.sw_body_frame_T`, at `s16`)
  and the real `save_file_set_flags`, which stores that file's `flags` and `gSaveFileModified`.
  New model claim, on the existing stored-globals class: `gSaveBuffer` and `gSaveFileModified`
  joined `CensusV2.stored_globals`, so (via `SpawnInit.non_safeb_syms`) SafeB avoids both blocks:
  nothing in the object graph points into the save buffer or at the modified flag. MWF says
  nothing about a stored global's contents, so any store there keeps it (`mwf_real_glob`). One
  fewer hypothesis on each capstone.
- **Premise sweep (2026-10-21): `game/object_helpers.c` is linked (the 22nd TU,
  `generated/object_helpers.v`, already generated for the census), and the three arg0-gated
  object-helper rows are lemmas.** `Hcsp_omfd_real`, `Hcsp_scale_real` and `Hcsp_osh_real`
  (`call_pres_ext_cs`) are proved from the real bodies (`ObjHelpersBodies.Hcsp_*_proved`, a walk
  over the generated AST that also tracks which temps hold SafeB-if-pointer values). Every store of
  `obj_mark_for_deletion` (`activeFlags`), `obj_scale` (`header.gfx.scale[0..2]`) and
  `obj_set_held_state` goes through the never-reassigned `obj`, which the `cs` gate puts in a SafeB
  block. `obj_set_held_state`'s two pointer-typed stores keep MWF's load closure (R7):
  `parentObj` gets the value loaded from `gCurrentObject`, a SafeB block (`SafeB_syms_ok` (c)), so
  R7 makes it SafeB; `curBhvCommand` gets `segmented_to_virtual`'s result, which its real
  `memory.c` body computes as an integer OR, so it is never a pointer (`s2v_ret_nonptr`), and that
  body stores nothing. No row was found false; no new premise. (Superseded 2026-10-21 by the
  `NO_SEGMENTED_MEMORY` bullet below: `s2v_ret_nonptr` was an artifact of the shift having no
  pointer semantics, and the osh row was then found false.) `Linked12Sat`, `InitMemSat`,
  `BootMWF` and `StartSat`'s per-TU certificates cover the 22-TU chain, and
  `LinkedTwelve.linked12_ext_pin` / `LptBody.os_resolve` gained the case (object_helpers defines no
  pinned external). Three fewer hypotheses on each capstone.
- **Premise sweep (2026-10-21, GOAL 2's any-argument rows): which entries now have linked bodies.**
  Of the any-argument lists HeightFrame takes, `sta_ext_ids`, `floors_ext_ids` and `warp_ext_ids`
  are still all unlinked externals. Entries that are now LINKED (so a row about them is a claim
  about real code, provable or refutable, not an external contract):
  - `obj_ext_open2_ids`: `bhv_spawn_star_no_level_exit`, `save_file_get_flags`,
    `save_file_get_star_flags`, `save_file_get_total_star_count`, `save_file_collect_star_or_key`,
    `save_file_set_flags`, `save_file_clear_flags` (all proved since, see the next bullet).
  - `cut_ext_open_ids`: `enable_time_stop` / `disable_time_stop` (proved since), `save_file_do_save`,
    and `spawn_object`.
  - **Found false, repaired 2026-10-21 (see the spawn bullet below).** Was: likely false (open):
    `spawn_object` as an any-argument entry of `Hpres_cut_ext_open` (and
    the sr row `Hcp_spawn_real`). Its real body (`object_helpers.c`) stores the `parent` argument
    into the new object, so "preserves MWF for any argument" fails when `parent` is a non-SafeB
    pointer. The fix is an arg-gated row like `Hcsp_osh_real`; being reworked separately with the
    `spawn_object` / `segmented_to_virtual` work.
  - Status after `NO_SEGMENTED_MEMORY` (2026-10-21): still open, and now more clearly false. The
    first step, `segmented_to_virtual(behavior)`, returns its argument, so for a behavior pointer
    into a block with data, `create_object` runs (it is external while `spawn_object.c` is not
    linked) and the `parent` store follows. Proving a `parent`-gated row needs `spawn_object.c`
    linked and walked: `create_object`, `allocate_object` (free list, and `unload_object` when it
    is empty) and `geo_obj_init`. The branch commit c68a1eb5 proved these rows only vacuously,
    from `s2v_ptr_noexec`, which is no longer true. A real call also still has no execution: each
    one passes `&bhvXxx`, a size-0 block, and `create_object` first reads `bhvScript[0]`. Showing
    non-vacuity therefore also needs `behavior_data.c` linked (see the bullet below).
- **`surface_load.c` is linked (2026-10-22, the 32nd TU)**: the storage of both collision
  partitions and the surface pools, and the real level / object collision loaders. Before, the
  partitions were size-0 blocks at boot, so no boot-derived memory gave `find_floor` an execution
  at an in-bounds position.
  No extern completion was needed. No row named its functions. Details in row 0.4.
- **`spawn_object.c` is linked (2026-10-21, the 31st TU) and the spawn pair is proved from its
  real bodies (`SpawnBodies.v`).** `spawn_object` / `spawn_object_abs_with_rot` (object_helpers.c)
  are walked through `spawn_object_at_origin`, `create_object`, `allocate_object`,
  `try_allocate_object`, `unload_object`, `deallocate_object`, `snap_object_to_floor`
  (spawn_object.c), `geo_obj_init` / `geo_add_child` / `geo_remove_child` (graph_node.c), the
  object_helpers copy/set helpers, `find_unimportant_object`, math_util's `mtxf_identity` /
  `vec3f_set` / `vec3f_copy` / `vec3s_copy`, and `find_floor`. `allocate_object`'s pool-exhausted
  `while (TRUE) {}` has no terminating execution. The c68a1eb5 proofs (vacuous via
  `s2v_ptr_noexec`) were not reused.
  - **Found false: the any-argument rows `Hcp_spawn_real` / `Hcp_soawr_real`** (and `spawn_object`
    / `spawn_object_abs_with_rot` as `cut_ext_ids` entries, and `spawn_obj_at_mario_rel_yaw`'s
    any-argument row inside `CutsceneLeafSurface`, which forwards `behavior`). The real body stores
    `parent` into `obj->parentObj` and `behavior` into `obj->behavior` / `curBhvCommand` of a SafeB
    pool object. With `parent` = Mario's own block, the pointer lands in a SafeB block and MWF's
    load closure R7 fails, so "preserves MWF for any argument" is false.
  - **Restated, all-argument gated** (`WindSurface.call_pres_ext_sg`; the engine's cs class
    `OutParamSurface.cs_gate` for `CensusV2.spawn_fids`; `ActWriterSurface.call_pres_ext_sob` for
    the in-TU helper, arg0 = Mario): every argument is SafeB-if-pointer or one of the
    `CensusV2.spawn_bhv_syms` behavior scripts (SafeB symbols). Every walker checks every real
    call site (`CensusV2.spawn_args_ok`: a chase temp, a sub-32-bit value, a literal, or a named
    script listed in the walk's xids so no local shadows it). The sites: Wind (`gCurrentObject`
    parent: a SafeB symbol + R7), `mario_blow_off_cap` and `spawn_obj_at_mario_rel_yaw`
    (`m->marioObj`, MWF's chase root, `mwf_real_chase_safe`), interaction's star/key spawn,
    `bhv_spawn_star_no_level_exit`, and the cutscene sites (`act_unlocking_star_door`,
    `general_star_dance_handler`: `m->marioObj`; the intro / end-peach / end-waving sites and
    `generate_yellow_sparkles`: `gCurrentObject`, which joined `CutsceneLeafSurface.gobj_ids` as a
    glob-obj seed; `generate_yellow_sparkles` became a hybrid walk). `spawn_obj_at_mario_rel_yaw`
    moved from ids to xids in `act_unlocking_key_door` / `act_exit_land_save_dialog`. Both spawn
    entries left `cut_ext_ids`.
  - **New SafeB symbols** (`SpawnInit.SafeB_syms_ok` (c), `CensusV2.safe_ptr_syms`):
    `gCurrentObject`, the spawn_object.c / graph_node.c / object_helpers.c globals the tree
    dereferences (`gFreeObjectList`, `gObjectLists`, `gObjParentGraphNode`, `gLoadedGraphNodes`,
    `gVec3fZero`, `gVec3sZero`: `spawn_safe_syms`) and the twelve `bhv*` scripts the walked sites
    pass (`spawn_bhv_syms`). `SpawnInit.gobj_not_nonsafe` re-checks that none is a
    `non_safeb_syms` global.
  - **New labeled open audio premise `Hsss : SpawnBodies.sss_inert`** (both capstones; audio is
    deferred): `stop_sounds_from_source` (audio/external.c, not linked; called by
    `unload_object`) changes no valid block and returns no pointer. Same shape as
    `ExtInert.audio_inert`. (**Gone 2026-10-23:** audio/external.c is linked and the real body is
    walked; see "the audio link" above.)
  - **Non-vacuity.** The gate is met by every real call site (each walker's `vm_compute` acceptance
    re-checks them against the generated code). Since `behavior_data.c` is linked (30th TU), the
    scripts the sites pass are real-length blocks, so `create_object`'s `bhvScript[0]` read has an
    execution.
  - **Net:** GOAL 1 18 → 17 hypotheses (two spawn rows out, `Hsss` in); HeightFrame 27 → 26.
- **`segmented_to_virtual` / `virtual_to_segmented` are the decomp's `NO_SEGMENTED_MEMORY`
  identity (2026-10-21; 2.2 register).** Before, they had no CompCert execution on any pointer:
  shifts and masks have no meaning on a `Vptr`. So every row and walk that passed through them held
  vacuously on real pointers.
  - **Found FALSE and repaired: `Hcsp_osh_real` (`obj_set_held_state`, the `cs` row).** It stores
    `segmented_to_virtual(heldBehavior)` into `obj->curBhvCommand`. Under the identity that value
    is `heldBehavior` itself, so an arbitrary pointer there breaks MWF's load closure (R7).
  - Restated: `OutParamSurface.cs_gate` = the arg0 gate plus, for `obj_set_held_state` only,
    "arg1 is `bhvCarrySomething3`, `4` or `5`" (`CensusV2.bhv_held_syms`). Every linked call site
    passes one of these (`interaction.c` `mario_grab_used_object`, `mario_drop_held_object`,
    `mario_throw_held_object`).
  - The walkers check it syntactically (`ActWriterSurface.held_arg_chk`): arg1 is `Evar g` with `g`
    one of those symbols, listed in the walk's xids. As variables, not functions, their call rows
    hold vacuously (`call_pres_ext_gvar`).
  - The three symbols joined `CensusV2.safe_ptr_syms`, so they are SafeB blocks. R7 held trivially
    for them while they were size-0 extern blocks. Since `behavior_data.c` is linked (below) they hold
    their real script words: integers and addresses of behavior functions and other symbols, none in
    `non_safeb_syms` (checked at boot by `BootMWF.boot_gvar_ok`'s certificate).
  - `ObjHelpersBodies` is re-proved honestly (`s2v_ret_arg`: the result is the argument).
  - Net: no new hypothesis. One capstone row is narrower, and now true as far as we know.
  - **No execution until 2026-10-21 (closed by linking `behavior_data.c`, next bullet).** Every
    `== segmented_to_virtual(bhvXxx)` compare and every read through a `bhv*` script was stuck,
    because those blocks were size-0 extern arrays and CompCert's pointer `==` needs valid pointers
    (`WMotREntry.cmp_size0_stuck`). Sites:
    - pole / tree: `mario_actions_automatic.c:31,45,144,164`;
    - held-object checks: `interaction.c:138,297,318,423,1637`, `mario_actions_moving.c:876`,
      `mario_actions_submerged.c:853`, `mario_actions_stationary.c:440`, `mario.c:1690`;
    - `object_helpers.c` compares (`107,1088,1469,1477`) and every spawn;
    - `area.c:139` (`get_mario_spawn_type`).
  - Making these run needed `behavior_data.c` linked, with every `bhv*` extern array completed to
    its real length (2.4). Done, see the next bullet.
- **`data/behavior_data.c` is linked (2026-10-21, the 30th TU, `LinkedTwelve.tu_rest`'s last
  entry).** Scope first: completion rows alone cannot help. A declaration's block size is its
  initializer's size, and a declaration's initializer is nil, so a `bhv*` block has bytes only if
  the definer is in the link. The definer is a data-only TU (687 globals, no functions), so linking
  it costs little: `Linked12Sat`, `InitMemSat`, `BootMWF` and `StartSat`'s certificates went
  through unchanged, and the pairwise link probe is 2.4 s. The only link obstruction was the 183
  `bhv*` declaration / definition pairs, closed by the 2.4 rule. proof_n64.h changes nothing in
  `behavior_data.c` (only the header line differs); it now takes `SM64_CGP` like every game TU.
  - **Now executes** (each compare is between two blocks with their real sizes):
    - the pole / tree compares, `mario_actions_automatic.c:31,45,144,164`. Witness:
      `PoleControl.noA_pole_frames_run` RUNS three real `execute_mario_action` frames over every
      30-TU link, A not pressed, Mario holding WMotR's low pole (the level script's
      `bhvPoleGrabbing` object, `oPosY` -2739, height 820): stick down (lines 164 and 45, stays on
      the pole, yaw velocity 128), Z (line 31, soft bonk), stick up at the top (line 144, reaches
      `ACT_TOP_OF_POLE` in the frame). Same method and world as `PositiveControl` (plus a silent
      `set_sound_moving_speed`).
    - `area.c:139`: `SpawnTypeRun.spawn_type_runs` RUNS the real `get_mario_spawn_type` on an
      object whose behavior is `&bhvAirborneWarp`: seven false pointer compares, then the eighth
      true, returning `0x12` (MARIO_SPAWN_AIRBORNE), with no external call (0.4).
    - the held-object checks (`interaction.c:297,318`, `mario_actions_moving.c:876`,
      `mario_actions_stationary.c:440`, `mario_actions_submerged.c:853`), the `virtual_to_segmented`
      script compares (`interaction.c:138,423,1637`), and the `object_helpers.c` compares.
  - **Found (vacuity, now closed): every `act_hold_walking` and `act_hold_idle` frame had NO
    execution.** Their first statement is the `heldObj->behavior == bhvJumpingBox` compare
    (`mario_actions_moving.c:876`, `mario_actions_stationary.c:440`), so before this link GOAL 1's
    capstone said nothing about Mario walking or standing while holding an object; likewise the
    pole frames with the stick pushed or Z pressed, and the underwater pick-up's last state. GOAL 1's
    rows are path-insensitive store-frame walks over every statement, so no proof leaned on the
    stuck compares, and re-reading the rows found none that becomes false: the newly live paths
    call only functions those walks already cover. GOAL 2's world (`wmotr_world`: nothing held) never
    reaches the hold actions; its pole frames go through the assumed per-call row of the automatic
    dispatcher (`Hseg_call_na`), which was vacuous on these sub-paths and is now a real claim (still
    assumed; the pole moves are `pole_obj_ok`-bounded `set_pole_position` writes).
  - **`interaction.c:881,889` now execute (2026-10-22).** They compare `o->collisionData` with
    `warp_pipe_seg3_collision_03009AC8`, which had a size-0 block (no linked TU defined it). WMotR's
    level data (TU 34, `generated/wmotr_level_data.v`) defines the mesh (264 shorts) and the 2.4 RULE
    completes interaction.c's declaration to that length, so both operands are in-bounds pointers of
    real blocks and the compare has an execution. Re-audit: the newly live path (`play_sound`, then
    `mario_stop_riding_object` and the warp action) calls only functions the GOAL 1 walks already
    cover (they are path-insensitive store walks over every statement), so no row became false.
    Spawns: `create_object` was in `spawn_object.c`, then unlinked (linked since 2026-10-21; the
    spawn rows are lemmas, see the spawn bullet above).
  - **Segment-0 animation caveat: REPAIRED 2026-10-22 (it was a vacuity, not only a caveat).**
    - `set_mario_animation` stored `VIRTUAL_TO_PHYSICAL(anim)` = `p - 0x80000000`.
    - `mario.c:188-189` and `graph_node.c:853-854` pass the stored `index` / `values` to
      `segmented_to_virtual`, whose identity returned the shifted pointer: the loads were out of
      bounds, so every frame that reads the anim sample (`update_mario_pos_for_anim`, top of
      pole) had no execution and the capstones said nothing about it.
    - Now `VIRTUAL_TO_PHYSICAL` is the `NO_SEGMENTED_MEMORY` identity as well (2.2 register), the
      pair round-trips, and `AnimRoundTrip.anim_y_runs` runs the real read path.
  - Spine sweep for proofs that relied on the old no-execution:
    - `ObjHelpersBodies` (`s2v_ret_nonptr`): re-proved, see above.
    - `WMotREntry.and_ptr_stuck`: replaced by `cmp_size0_stuck`, with the comment updated.
    - `MathBodies.Hcpx_s2v_proved` / `_v2s_proved` still hold: both bodies are pure.
    - `MovingLeafSurface`'s `Hv2sp` reasons from the argument's provenance, so the identity keeps it.
    - The other leaf walkers only use the rows' write-freeness, which the identity keeps.
- **`game/area.c` is linked** (2026-10-21, the 23rd TU, `generated/area.v`; reason in 0.4). Rows
  that became claims about its real bodies:
  - **Found FALSE and repaired:** `override_viewport_and_clip` is an any-argument entry of
    `Hpres_obj_ext` (`ObjectLeafSurface.obj_ext_ids`, used by `CutsceneLeafSurface.Hcpx_ovac` for
    the credits cutscene). Its real body stores its two pointer arguments into the globals
    `D_8032CE74` / `D_8032CE78`. With those blocks SafeB (`SafeB_boot`), a call with
    `a = &gMarioStates[0]` puts a pointer to Mario's block in a SafeB block, breaking `MWF_real`'s
    load closure (R7): the row was false about the real code. Repair, on the existing stored-globals
    class: `D_8032CE74` / `D_8032CE78` joined `CensusV2.stored_globals`, so SafeB avoids their
    blocks and `mwf_real_glob` keeps MWF over any store into them. The body's third store
    (`gFBSetColor`, an integer) is a non-pointer store. The row is now true, and a lemma since
    2026-10-21 (next bullet but one).
  - `play_transition` (in `warp_ext_ids` and the cutscene `ep_xids`): stores only integers, into
    `gWarpTransition`'s fields, and through the linked `set_warp_transition_rgb` into
    `gWarpTransRed/Green/Blue` and `gWarpTransFBSetColor`, so every
    store is a non-pointer store; true, and a lemma since 2026-10-21 (below).
  - `area_get_warp_node` (`warp_ext_ids`): stores nothing; true, and a lemma since 2026-10-21 (below).
- **Premise sweep (2026-10-21): the three area.c entries are lemmas** (`ObjExtBodies.Hpx_ovac`,
  `Hpx_ptr`, `Hpx_agwn`, walked over the generated `area.v` bodies). `override_viewport_and_clip`
  leaves `obj_ext_open2_ids`; `play_transition` leaves `cut_ext_open2_ids` and `warp_ext_ids`;
  `area_get_warp_node` leaves `warp_ext_ids`. Both capstones now take `Hpres_warp_ext_open`
  (`NoAImpliesNoFlyTwelve.warp_ext_open_ids`, 2 fewer ids) in place of `Hpres_warp_ext`, which is a
  lemma (`warp_ext_of_open`). Hypothesis counts are unchanged (the rows are lists; they shrank).
  - `area_get_warp_node(id)` only loads (`gCurrentArea->warpNodes`, then a `next`-chain loop) and
    returns; its body has no store and no call.
  - `play_transition` and its one callee, the real `set_warp_transition_rgb`, store into
    `gWarpTransition`'s fields and `gWarpTransRed/Green/Blue` / `gWarpTransFBSetColor`.
    `override_viewport_and_clip` stores `gFBSetColor` and the stored globals `D_8032CE74/78`.
  - **No new claim.** `gWarpTransition`, `gWarpTrans*` and `gFBSetColor` did NOT join
    `stored_globals`. Every store into them is provably a non-pointer: the lvalue type is `u8` /
    `s16`, or the right side is a bitwise `|` (`ObjExtBodies.ast_ok`, checked against the generated
    AST). A non-pointer store into any global that `MWF_real` does not read (not Mario's block, the
    controllers, `gMarioState`, the timer, the handler table, the animation list or the knockback
    tables; `ObjExtBodies.mwf_syms`) keeps `MWF_real` whether or not the block is SafeB, because
    R7 (SafeB is load-closed) only constrains pointer values (`ObjExtBodies.np_store_pres`, from
    `MWF_real_transfer`). Positive control: without the non-pointer clause the recognizer rejects
    the real `override_viewport_and_clip` body (`chk_ovac_needs_np`).
  - Not swept here (owned by the concurrent spawn work): `spawn_object` (cut_ext, likely false as
    an any-argument entry, above) and `spawn_object_abs_with_rot`, whose body is linked too
    (`object_helpers.c`) but which is the sr row `Hcp_soawr_real`, not an any-argument entry.
    After this sweep, the any-argument lists' linked entries are exactly those two spawn entries
    and `save_file_do_save`. (2026-10-21: both spawn entries found false and repaired, see the
    spawn bullet above; `save_file_do_save` is a lemma.)

- **Premise sweep (2026-10-21): nine linked any-argument entries are lemmas** (`ObjExtBodies.v`).
  Walked over the generated bodies: the save_file.c readers `save_file_get_flags`,
  `save_file_get_star_flags`, `save_file_get_total_star_count` (through the real
  `save_file_get_course_star_count`), the flag writers `save_file_set_flags` /
  `save_file_clear_flags`, `save_file_collect_star_or_key` (through the real `get_flags`,
  `get_max_coin_score`, `get_course_coin_score`, `touch_coin_score_age` -> `get/set_coin_score_age`,
  `set_flags`, `get_star_flags`, `set_star_flags`), object_helpers.c's `enable_time_stop` /
  `disable_time_stop`, and `bhv_spawn_star_no_level_exit`. Every save/time-stop store is an address
  chain from a global (no load), so it lands in that global's block for any argument and any
  `gCurrSaveFileNum` / `gCurrCourseNum`. `bhv_spawn_star_no_level_exit` stores two integers through
  `spawn_object(gCurrentObject, ..)`'s result (SafeB by the existing sr row `Hcp_spawn_real`, which
  it now consumes instead of being a separate row) and calls the real `obj_set_angle` (integer
  stores through its SafeB arg0). The rows are `NoAImpliesNoFlyTwelve.obj_ext_open_of2` /
  `cut_ext_open_of2`; both capstones now take the narrower `Hpres_obj_ext_open2` (7 fewer ids) and
  `Hpres_cut_ext_open2` (`cut_ext_open2_ids`, 2 fewer ids). Hypothesis counts are unchanged (the
  rows are lists; they shrank).
- **Finding (same sweep):** the "for any argument" claims are true of these bodies only because
  every global they write is a stored global, and six were not: `gLastCompletedCourseNum`,
  `gLastCompletedStarNum`, `sUnusedGotGlobalCoinHiScore`, `gGotFileCoinHiScore` (written by
  `collect_star_or_key`), `gMainMenuDataModified` (by `touch_coin_score_age`) and `gTimeStopState`
  (by the time-stop pair; it has storage, `object_list_processor.c` is linked). The old rows
  silently assumed a store there keeps MWF, i.e. that those blocks are not Mario's, the controller's
  or a SafeB block. They joined `CensusV2.stored_globals`: new model claim on the existing class
  (via `SpawnInit.non_safeb_syms`, `HSafeB_syms` now also says nothing in the object graph points
  at them; they are plain integer data, and `BootMWF` / `StartSat` re-prove the boot state with
  them). No row was false.
- **PROVED 2026-10-21: `save_file_do_save`** (was the last linked entry of `cut_ext_open2_ids`; now
  `SaveDoSaveBody.Hpx_sfds`, discharged in `NoAImpliesNoFlyTwelve.cut_ext_open_of2` for both
  capstones). Its call tree is walked from the generated bodies: `save_file.c`'s
  `save_file_do_save`, `add_save_block_signature`, `calc_checksum`, `save_main_menu_data`,
  `write_eeprom_data`, and six new libultra TUs (recipe `ULTRA_CG`, see 2.2):
  `osEepromLongWrite.c`, `osEepromWrite.c` (`osEepromWrite`, `__osEepStatus`,
  `__osPackEepWriteData`), `__osSiCreateAccessQueue.c` (`__osSiCreateAccessQueue`,
  `__osSiGetAccess`, `__osSiRelAccess`), `osCreateMesgQueue.c`, and the storage TUs `osContInit.c` /
  `osInitialize.c` (`LinkedTwelve.tu_rest` indices 22 to 27; `Linked12Sat`, `InitMemSat`, `BootMWF`
  re-checked for 29 TUs). It stops at the floor 3.5 (widened): `bcopy`, `__osSiRawStartDma`,
  `osRecvMesg` / `osSendMesg`, `osSetTimer` (coarser). The argument: every byte the tree writes is
  in a block that `MWF_real` and `action_sat` never read (not Mario's, not the controller's, not
  SafeB, not a watched symbol), whatever the value: stored globals, fresh stack locals
  (`eepromformat`, `sdata`, `requestformat`, `sp1c`), or pointers derived from those, tracked by a
  checked value class through temps and parameters (the queue arguments also carry their
  `q_side` queue). For any argument: `fileIndex` only offsets the `gSaveBuffer` pointer.
  New stored globals (`CensusV2.stored_globals`, same class as the rest: plain data nothing in the
  object graph points at): `gSIEventMesgQueue` (main.c, extern), `gOsSiMessageQueue`,
  `osSiMesgBuff`, `gOsSiAccessQueueCreated`, `__osEepromTimer`, `__osEepromTimerQ`,
  `__osEepromTimerMsg`, `__osContLastCmd`, `__osEepPifRam`. No row was false; the floor's recv
  clause was (3.5). GOAL 1's from-boot lemma `boot_init_mem_ok` still takes the proved
  `Hpx_total_star_count` for its one call.
- **Reachability (checked 2026-10-21): the row cannot be gated away in GOAL 1.** The walked call
  sites are `handle_save_menu` (from `act_exit_land_save_dialog`) and
  `general_star_dance_handler` (from `act_star_dance` / `act_star_dance_water`); the
  `save_file_erase` / `save_file_copy` callers are never called by linked code. Both live paths
  are reachable without A:
  - a no-exit star, then the save dialog, which confirms on B (`ingame_menu.c:2030`), then YES;
  - an exiting star, then the course-complete menu, which accepts START or Z, then save.
  GOAL 1's invariant has no action gate, so it must cover them. In GOAL 2 none of these actions
  is in `R_noA`, but HeightFrame takes the row through GOAL 1's any-action engine
  (`frame_call_ok_linked12`). Gating it there means running that engine at `Qv := R_noA` (the
  open "action arm" in HeightFrame.v).


## 5. Tethers: evidence the model is the game (NOT proof)

These don't make the theorem stronger. They check that its assumptions describe the
real game, and they find false rows (four were found historically, all "provable but
false about the game").

| # | Tether | What it checks | Status |
|---|---|---|---|
| 5.1 | **Recorded-RAM differential testing.** Headless emulator (Mupen64Plus in WSL) running the matching ROM, RDRAM dumped each frame, translated into CompCert memory, one frame run by the proved-sound interpreter (`proofs/Interp/`), compared to the emulator's next frame | 2.2–2.5, 3.1, **3.2** (a stuck run on a real frame = the UB hole is live), 4.1 (do the real externals satisfy our rows on real states?), 0.4 (do real WMotR states satisfy the starting conditions?) | **Working, re-run 2026-10-22** (35-TU link). FINDING: 523/600 real frames STUCK on the size-0 `gMarioAnims` (3.2). **REPAIRED** the same day (anim data linked, 36 TUs): seeds 2 and 3 600/600 MATCH, 0 STUCK. Details: [row 5.1 in detail](#row-51-in-detail). |
| 5.2 | Positive control: with A pressed, the model can fly (`PositiveControl.A_pressed_frame_reaches_flying`) | The theorem isn't true for a trivial reason: the step relation is non-empty and flying is reachable | **PROVED**, over a hand-built (non-real) memory and an oracle for the functions outside the link (`flat_world`: silent audio, IEEE `sqrtf`). Details: [row 5.2 in detail](#row-52-in-detail). |
| 5.4 | **Height-cell write watch** (`experiments/oracle/ywatch.py`): memory write-watchpoints on every cell Φ reads (action, actionState/Timer, pos[1], vel[1], floorHeight, gfx.pos[1]) over whole real frames, under input that never presses or holds A. Each store is logged with its PC, function, caller, and whether it ran inside `execute_mario_action` | 0.6 (`Hframe_is_move_chain`: does a writer outside the Move catalog fire?), 0.7 (do the flanks leave pos[1] alone?), 0.5 | **Working, 2026-09-28.** About 18,000 WMotR frames (random B/Z/stick from the spawn cloud, and from the K = 2424 wing-cap box top by a pos poke): inside WMotR, every value-changing height write came from a catalogued writer, and no pos[1] write outside `execute_mario_action` changed it. 2026-10-22: 2000 more no-A frames (seed 61): 0 flags, Φ held at every frame end. Details: [row 5.4 in detail](#row-54-in-detail). |
| 5.3 | ESBMC model checking on the vendor C (`experiments/esbmc/`) | Candidate GOAL-2 invariants against the real C before Coq effort | A scout. Trusts ESBMC plus stub contracts; nothing in `proofs/` rests on it. |

### Row 5.1 in detail

- **Working** (`experiments/oracle/`, README has the method). 2026-09-26 (12-TU link, seed 2):
  267 MATCH and 33 STUCK (the 3.2 UB), then **300 MATCH** after the `VIRTUAL_TO_PHYSICAL` rewrite.
- **Re-run 2026-10-22** on the 35-TU link. Seeds 2 and 3 re-recorded (the boundary changed:
  only `sqrtf`, audio and the libultra DMA calls are still replayed). Harness changes:
  - regenerated `boundary.txt`; statics of all linked `.o`; game-thread calls only;
  - **normalization** (the 2.2 address model): a real segmented / physical / ROM-symbol word
    equals a model pointer iff the ROM's `segmented_to_virtual` maps it to the same object;
    used for entry pointers, call arguments and the final compare; every use is counted;
  - not compared: thread stacks (the game thread's machine stack) and `OSThread` save areas.
- **FINDING (vacuity; REPAIRED 2026-10-22, below):** 238 + 285 of 600 frames STUCK, all at
  `if (addr != list->currentAddr)` in `load_patchable_table` (`memory.c:575`). `table->srcAddr`
  is `gMarioAnims` (`game_init.c:629`), a **size-0 block** in the link (declared, never defined).
  CompCert compares pointers only if both are weakly valid; no offset of a size-0 block is. So
  every `set_mario_animation` / `set_mario_anim_with_accel` call with a valid id has no
  execution, not only anim loads. `tools/size0_globals.py` missed it: its only user,
  `setup_game_memory`, was not a root, and the address then flows through data.
- **Repair (2026-10-22):** `mario_anim_data.v` is linked (the 36th TU; `game_init`'s declaration
  completed to the definer's type, 2.4). No proof broke. The sweep now also walks the game
  thread (`thread5_game_loop`, `setup_game_memory`) as class (c), each entry checked by hand, and
  tags address uses. Re-run WITHOUT `ROM_SIZED`, seed 2: **300/300 MATCH, 0 STUCK**, 0 DIFF,
  0 DIVERGE; seed 3 likewise 300/300 MATCH, 0 STUCK. The 33 (41) anim-load frames write `anim->values` / `anim->index` under the phys
  normalization, as before. `boundary.txt` changed only in `gMarioAnims`'s size (0 -> 580632).
  Harness: the extracted anim module's `Int.repr` literals are folded to constants
  (`extract/fold_repr.py`; ocamlopt did not finish on it in an hour).
- With `ROM_SIZED=1` (the harness gives `gMarioAnims` its ROM extent; not the model): seed 2
  **300/300 MATCH**, seed 3 **300/300 MATCH**. The only normalized words the frames write
  are `anim->values` / `anim->index` on the anim-load frames (33 in seed 2, 41 in seed 3), as predicted (2.2).
  0 DIFF, 0 DIVERGE in every run.
- External calls are *replayed* from the game, so this checks the linked C, not the 4.1 rows.
  Trusts: the emulator on sampled frames; the harness (map, `.mdebug` statics, type-directed
  pointer rebuilding, the normalization); OCaml extraction of the interpreter. A mistake there
  shows up as a false STUCK/DIFF, or as a false MATCH only if it errs identically in the model
  and the comparison.

### Row 5.2 in detail

- **PROVED**, over a hand-built (non-real) memory and an oracle for the functions outside the link
  (`flat_world`: silent audio, IEEE `sqrtf`). `load_patchable_table` is no longer in the oracle
  (2026-10-18, memory.c linked): its real body runs over an empty DMA table (`count = 0`) and
  returns FALSE without DMA. Collision and `math_util` are *not* in the oracle any more: the real
  `surface_collision` bodies run over a static partition holding one flat triangle under Mario, and
  the real `math_util` bodies run (vec3*, `approach_*`, `atan2s` over the real `gArctanTable`).
  Should be redone from a *recorded* WMotR state (5.1).
- **FOUND 2026-10-22: it was VACUOUS until the refutation sweep.** `flat_world` answered `sqrtf`
  at every signature, so its soundness hypothesis was false (`Refutations.old_flat_world_ok_refuted`).
  Repaired: the oracle answers only at the real `(float) -> float` signature.

### Row 5.4 in detail

- **Working, 2026-09-28.** About 18,000 WMotR frames (random B/Z/stick from the spawn cloud, and
  from the K = 2424 wing-cap box top by a pos poke): inside WMotR, every value-changing height write
  came from a catalogued writer, and no pos[1] write outside `execute_mario_action` changed it. Max
  y 2530 (a ground-pound windup off the box). The only flags were the level exit (falling off →
  castle grounds, y := 4500), which led to the per-visit scoping in 0.5.
- **Extended 2026-09-28:** scripted no-A sequences (runs, slide kicks, dive + B rollout, ground
  pounds, ledge grabs) and Φ's numeric part checked at every frame end. That is about 68,000 more
  WMotR frames, including about 36,000 from the **solid** K = 2424 and 2064 box tops (wing-cap save
  flag set; without it the boxes are intangible and the earlier box runs never stood on one). Φ held
  on every frame and there were no uncovered writers. Slack was 0 standing at K. A slide kick from
  the box top peaked at 2466 = K + 42, as the catalog says, and the highest y was 2540 (ground-pound
  windup).
- **Objects, 2026-09-29:** W's object clause is checked at every `execute_mario_action` entry
  (`objs_bad`). Over 9,000 frames (new `pole` and `buddy` spots, and box2424w), there were 2,122
  collisions: pole 2,037 (the low pole, oPosY −2739, height 820, exactly its list entry), TEXT 58,
  COIN 23, 0 ×3, BREAKABLE 1. There were 0 violations and 0 Φ failures. A collided cannon base is
  not exercised here.
- **Limits:** starts are poked (pos, and the save flag), not reached; poles above the moat and the
  hangable ceiling are not exercised; the cannon was found by a separate probe (`cannon_probe.py`),
  not by this watch.


## 6. Tools we use but do not trust

Their outputs are re-checked by the Coq kernel, so they add nothing to the ledger.
Listing them makes that explicit.

- `proofs/Interp/`: the interpreter (`ClightInterp`, soundness proved against
  ClightBigstep), `CMem` (proved equal to `Mem.*`), `LinkGenv` (proved equal to
  `globalenv lp`). Runs happen inside `vm_compute`, so the kernel re-checks them.
- The `vm_compute` checker itself **is** trusted (part of 1.1; the kernel's VM).
- `discipline_check.sh`, `check_unwired.py`, `tools/clight_pretty.py`: hygiene and display only.


## 7. Refutation sweep 2026-10-22

Every remaining row of both capstones, and every hypothesis of the run witnesses, was attacked:
false outright, false on the real link / witness, phantom forall, or jointly unsatisfiable.
REFUTED = Coq proof (`proofs/MarioModel/Refutations.v`). SUSPECT = a concrete argument,
not a proof. SURVIVED = what was tried.

**R1 (REFUTED, REPAIRED): every run oracle was unsatisfiable.** `BootRun.world`,
`TerrainRun.world`, `PositiveControl.flat_world` and `PoleControl.pole_world` answered `sqrtf`
with a `Vsingle` at ANY signature. CompCert's axiom `ec_well_typed` forbids that at an int
result, so each `world_ok` (and `TerrainRun.sqrtf_ieee`) was false for every genv. VACUOUS
until now: the positive control (5.2), `PoleControl`'s no-A pole runs, `boot_frames_run`,
`TerrainRun`'s loader tether, and `goal2_start_sat`'s `terrain_loaded` / `frame_runs` /
`ifs_tether`. No capstone took it as a premise, and the audit's axiom check cannot see a false
antecedent. Repair: `PositiveControl` / `PoleControl` here (answer `sqrtf` only at an `Xsingle`
result, the real declaration in every TU; no new trust); `BootRun` / `TerrainRun` /
`sqrtf_ieee` on the parallel branch (`FpuValue.sqrtf_value`, TRUST 3.5's value clause).

| Row (GOAL 1, and GOAL 2's copy) | Verdict | Evidence |
|---|---|---|
| `H12` | SURVIVED | one concrete `link_chain`; inhabited (`Linked12Sat`) |
| `HSafeB_syms` | SURVIVED | met by `SafeB_boot` (`BootMWF.SafeB_boot_syms_ok`), jointly with the boot memory |
| `Hbm_sym` `Hbc_sym` `Hoc0` | SURVIVED | symbol pins (`spawn_symbols_resolve`), no forall |
| `Hsq` (`sqrtf_spec`) | SURVIVED | a restriction: the empty relation meets every `ec_` axiom |
| `Hscm_body_real` | SURVIVED; **PROVED 2026-10-23** (`CameraModeBody`, row 4.1) | phantom memory tried: `sModeTransitions` is writable, so any `(Camera*, f32*, f32*) -> s32` body is reachable. The one store through an unconstrained pointer is `update_boss_fight_camera`'s `sMarioCamState->cameraEvent = 0`. Aimed at Mario's block (offset wrap), it zeroes a 16-bit half. No tainted action has a zero half. Every MWF clause is conditional or zero-safe |
| `Hdma_floor` | SURVIVED | restrictions; every named function is External in all 35 TUs |
| `Hsss`, `Hpres_sta_ext` | SURVIVED | the C bodies write `audio/external.c` statics only; `stop_sound` compares `pos`, never stores it |
| `Hpres_obj_ext_open2`, `Hpres_cut_ext_open2`, `Hpres_warp_ext_open` | **GONE 2026-10-23 (proved; one entry FALSE first)**: every entry walked from its linked body (4.1, list closure); `create_dialog_box_with_var` stored a possible pointer into `gDialogVariable` (now a stored global). Earlier: SURVIVED in the model; SUSPECT on link | `play_sound` stores `pos` into `sSoundRequests[].position`. Once `external.c` is linked, an any-argument `pos` = `&gMarioStates` breaks R7 under `SafeB_boot` (as `spawn_object` did). Gate `pos` before linking audio. The dialog / music / RNG entries have scalar args and own statics |
| `Hpres_floors_ext` | **SUSPECT CONFIRMED + REPAIRED 2026-10-23**: obj_behaviors.c linked, `bhvStarSpawnCoordinates` joined `spawn_bhv_syms`, `spawn_default_star` walked (`SpawnStarBody`); the row is gone. Earlier: SUSPECT on link | `spawn_default_star` (`obj_behaviors.c`, generated, unlinked) spawns with `bhvStarSpawnCoordinates` (`spawn_star.inc.c:115`), which is not in `safe_ptr_syms`. For an admissible SafeB without that block, the real body breaks R7 |
| `Hext_action_ns`, `Hmwf_ext_ns` (then `Hext_action_ptfi`, `Hmwf_ext_ptfi`) | **FALSE as stated (against the linked body), REPAIRED 2026-10-23** | `print_text_fmt_int` takes its label from `mem_pool_alloc(gEffectsMemoryPool)` and stores `x`, `y` into it. The External rows were not refutable in Coq (CompCert's `external_functions_sem` is opaque), but the real body (print.c, now linked) falsifies their any-argument / any-pool claim: a pointer `x` breaks R7, and an unconstrained pool chase can reach the action cell. Repaired: gate `T_ptfi` + print globals SafeB; the body is proved (`PrintBodies`), the rows are gone. Reached only under `gShowDebugText` |
| run oracles `world_ok` x4, `sqrtf_ieee` | **REFUTED, REPAIRED** | R1 |
| `rrc_inert` | SURVIVED | `Vundef` has every result type |
| GOAL 2 `Hsqrtf`, `Hsqrtf_float`, `Haudio` | SURVIVED | restrictions; consistent with the repaired oracles |
| GOAL 2 `Hseg_any` | SUSPECT (phantom forall) | it asks the linked `spawn_wind_particles` at ANY args from ANY `fworld` memory. `fworld` says nothing of `gFreeObjectList`, and every object lives in `gObjectPool`'s one block. A free list heading into Mario's object or the `usedObj` pole re-initializes it (`geo_obj_init` zeroes `gfx.pos`; behavior becomes `bhvWind`). In WMotR the call is dead (no `SURFACE_HORIZONTAL_WIND`). Repair: gate the obligation on the wind branch, which `wmotr_world` refutes. Needs a path-sensitive `FrameCalls.cl` |
| GOAL 2 `Hauto_rest` | SUSPECT at TOP_OF_POLE(_TRANSITION); **DISCHARGED 2026-10-23** (proved with the real animation data, (p)) | `set_pole_position` adds the anim Y translation read through `animList->bufTarget`. `fworld` / `ffw` carry no fact about the buffer's contents, and with `currentAddr` matching no DMA runs. A phantom buffer gives up to +8191, far past top + `POLE_UP`, unless a ceiling clamps it. So this row is FALSE as stated, not just unproved (0.8(f)). CLIMBING_POLE / IN_CANNON were read too: a phantom `stickY` is clamped at `poleTop` or makes the f32 to s32 cast undefined (no execution), and the cannon seat is `usedObj`'s, which `used_ok` fixes |
| GOAL 2 `Hseg_call_na` | not refuted; **split 2026-10-23** (0.8(q)): now the lemma `NaSplit.naFA_of_open` over `Hseg_na_open` (7 named rows since 2026-10-25) | real bodies over `fworld` memories. No counterexample was built: that needs a modified StartSat witness. Since 2026-10-23 its posts carry `lvl_w` / `inputs_ok` (below) |
| GOAL 2 `Hseg_na_open`: `mario_reset_bodystate`, `update_mario_info_for_cam` | **REPAIRED and proved 2026-10-24** (0.8(q)) | `ffw` now pins `m->marioBodyState = &gBodyStates[0]` and makes gBodyStates an `ff_rl` region (`RBS`). The pin alone was not enough: without the region, gBodyStates could alias a world surface. Both facts are proved at boot (`StartSat`) and kept by every proved row. `NaSplit.reset_row` / `cam_row` walk the real bodies |
| GOAL 2 `Hseg_na_open`: `mario_update_hitbox_and_cap_model` | **PROVED 2026-10-25** (`NaSplit.hitbox_row`) | walked from the real body (`HitboxFrame`), the cap music path framed (`CapAudio`, load_sequence by the labeled `ls_frame`), the world kept by `HoleX`. FOUND on the way (phantom ∀): a collided object could be Mario's own object (`ff_Cd` repairs it in `ffw`) |
| GOAL 2 `Hseg_na_open`: `update_mario_inputs` | SUSPECT (phantom forall); **the globals part REPAIRED 2026-10-26** (the row itself is still open) | its post `inputs_ok` (waterLevel = -11000) comes from `find_water_level`, which reads `gEnvironmentRegions`; `fworld` did not pin that table (or `gShowDebugText`, which it also reads). Repaired: `FfWorld.env_w` (in `lvl_w`, so in `fworld` and PhiW, kept by every row and flank through `lvl_ids`) says gEnvironmentRegions is NULL and gShowDebugText is FALSE, PROVED at boot (`StartSat.L_env` / `L_dbg`): the real `load_area_terrain` stores NULL over the .bss zero (WMotR's collision has no TERRAIN_LOAD_ENVIRONMENT block), gShowDebugText is main.c's FALSE and no linked code stores either (only surface_load.c stores gEnvironmentRegions). `gCameraMovementFlags` needs no pin: update_mario_inputs either sets INPUT_FIRST_PERSON or clears the flag, neither touching `inputs_ok`. Still open for the row: the double-miss NULL floor (`ff_Wf`; FOUND below) and INPUT_SQUISHED (dynamic surfaces) |
| GOAL 2 `Hseg_na_open`: `sink_mario_in_quicksand` | **REPAIRED and proved 2026-10-24** (0.8(q)) | FOUND (phantom ∀): the row stored through Mario's object's `gfx.throwMatrix`, which `fworld` did not pin, so it ranged over memories whose throwMatrix pointed into Mario's state or a surface. `ffw` now pins it to NULL or `sFloorAlignMatrix` (ff_rl region `RFA`), proved at boot and kept by every row; `NaSplit.qs_row` walks the body (the gfx.pos[1] store writes Phi's cell back unchanged) |
| GOAL 2 `Hseg_na_open`: `mario_handle_special_floors` | open | WMotR has floor type 10 (death plane), so the body reaches `check_death_barrier` → `level_trigger_warp`. Not walked |
| GOAL 2 `Hseg_na_open`: `squish_mario_model` | **proved 2026-10-24** (0.8(q)) | not a phantom ∀: `ffw` already pinned `m->marioObj`. Its footprint is `squishTimer` (in `ProRows`' hole) plus bytes 44..55 of Mario's object (`gfx.scale`, directly and via the real `vec3f_set`). `ProRows`' hole lemmas now take that object-side hole; `NaSplit.squish_row` walks the body |
| GOAL 2 `Hair_pro` | **FOUND FALSE (phantom forall), REPAIRED + PROVED 2026-10-23** | below: `fresh_at` did not pin `waterLevel` / `INPUT_SQUISHED` |
| GOAL 2 `Hseg_any` (narrowed) | **FOUND FALSE (phantom forall), REPAIRED + PROVED 2026-10-23** | below: `fworld` did not pin `sPlayingInfiniteStairs` / `gCurrLevelNum` |

R1's proofs: `Refutations.old_{boot,terrain,flat,pole}_world_ok_refuted`,
`old_sqrtf_ieee_refuted`. The repaired control oracles answer `None` at the bad signature
(`flat_world_repaired`, `pole_world_repaired`).

**Repair of the `Hseg_any` SUSPECT (2026-10-23, branch segany):**

- **FOUND (phantom ∀) + REPAIRED 2026-10-23: `HeightFrame.Hseg_any`.** The row asked every
  non-`gMarioState` call of `execute_mario_action` to keep the frame world from ANY `fworld`
  memory with ANY arguments — including the LINKED `spawn_wind_particles` (×2). Its real body
  calls `spawn_object` three times, which pops the head of `gFreeObjectList` and re-initialises
  that slot, copying Mario's position into it. `fworld` says nothing about `gFreeObjectList`, and
  every object is a slot of `gObjectPool`'s single block, so a memory in a pole action whose
  free-list head is `usedObj` (the low pole) meets every premise, and one call rewrites the pole's
  `oPosY`: `used_ok` (part of `fworld`) fails. The row was FALSE as stated (concrete argument; not
  replayed in Coq — building a full `mem_ok_lp` witness memory with a phantom free list is not
  cheap). In the game the call is dead in WMotR: both call sites sit under
  `if (m->floor->type == SURFACE_HORIZONTAL_WIND (44) / SURFACE_VERTICAL_WIND (56))`, and W's
  floor clause says `m->floor` is a surface whose type is one of WMotR's collision types,
  computed from the generated terrain (`[5; 10; 21; 55; 0]`). Repair (no new trust):
  `FrameSplit.clw` is the call collector with that branch condition read — a block
  `t1 = gMarioState; t2 = t1->floor; t3 = t2->type; if (t3 == n) …` with `n` not a WMotR surface
  type contributes no obligation; `FrameSplit.guard_mem` proves such a block leaves memory
  unchanged under W; `Hseg_any` now ranges over `ema_live` only, whose one non-`gMarioState`
  call is `play_infinite_stairs_music()` (unlinked, no arguments; `ema_live_anys`, computed).
  The other two calls in the old list (`play_sound` ×2) were inside the same dead blocks. No
  other object-allocating call is in the list. HeightFrame's hypothesis count is unchanged (the
  row is narrowed, not split).

**`Hseg_any` and `Hair_pro` PROVED (2026-10-23, `ProRows`; HeightFrame 24 → 22 hypotheses, no
new trust).** Both rows were false as stated and are repaired by strengthening the carried
world, then proved against the generated Clight on the link:

- **FOUND (phantom ∀): `Hseg_any`** (only `play_infinite_stairs_music()` since the narrowing
  above). The row asked the call to keep `fworld` from ANY `fworld` memory. The real body
  (`sound_init.c`, linked) computes `shouldPlay` (castle-only) and, when
  `sPlayingInfiniteStairs ^ shouldPlay`, stores the flag and calls the sequence player. `fworld`
  said nothing about `sPlayingInfiniteStairs` or `gCurrLevelNum`, so a memory with the flag at 1
  made the call write memory outside the row's frame -- FALSE as stated (concrete argument).
  Repair: `FfWorld.lvl_w` (gCurrLevelNum = LEVEL_WMOTR, sPlayingInfiniteStairs = 0) joins
  `FrameSplit.fworld` and `HeightFrame.PhiW`; every proved row keeps it
  (`AnimKeep.lvl_w_keep` / `lvl_w_keep_ne`: the two globals' blocks are apart from every
  written region); StartSat establishes it on the witness (gCurrLevelNum from the real entry
  code, `L_lvl`; the flag from the boot image's `Init_int8 0`, `StartSat.L_spis`). Under
  `lvl_w` the real body only reads memory (`ProRows.pism_mem`): `seg_any_rows_proved`.
- **FOUND (phantom ∀): `Hair_pro`** (the prologue calls `check_common_airborne_cancels`,
  `play_far_fall_sound`, `check_common_automatic_cancels`). Both cancels test
  `m->pos[1] < m->waterLevel - 100` (-> ACT_WATER_PLUNGE, not in `R_noA`) and the airborne one
  `m->input & INPUT_SQUISHED` (-> ACT_SQUISHED). `fresh_at` did not pin `waterLevel` or the
  input word, so a memory with the water above Mario met every premise and left `R_noA` --
  FALSE as stated. Repair: `FfWorld.inputs_ok` (waterLevel = -11000, the WMotR value
  update_mario_inputs leaves -- no water box; INPUT_SQUISHED clear) joins `fresh` / `fresh_at`;
  update_mario_inputs' row (inside the open `Hseg_call_na`) now claims it, the proved rows keep it
  (`inputs_ok_keep`). Proofs (`ProRows`): the plunge test is false since `pos[1] >= -11000`
  (budget's `InRange`); the squish bit is clear; the vertical-wind test is false since the floor
  type is a WMotR type (`wmotr_surface_types`); then `quicksandDepth = 0` (AutoSplit's QSD
  lemmas). `play_far_fall_sound` is walked by `lw_body_frame`: it writes only `m->flags`
  (offset 4, outside every `fworld` / cell field) and, through the real `play_sound`
  (`SndXc.ps_walk`), only `sSoundRequests` / `sSoundRequestCount`; `ProRows.hole_fworld` proves
  such a change keeps every `fworld` conjunct, the cells and `fresh_at`.
- The open rows' posts are strengthened accordingly (`Hseg_call_na` now also claims `lvl_w`
  in `fworld` and `inputs_ok` in `fresh` / `fresh_at`); both hold in the game.

**Scoping sweep 2026-10-24 (branch plat_still).** Each item makes the capstone cover more real
runs or claim only true things:

- **FOUND (false clause): cannon bases rise.** `cannon_obj_ok` pinned a collided / used cannon
  base at home (seat − 350). In ACT_IN_CANNON (reachable without A) `opened_cannon_act_4`
  raises it 5 a frame for 69 frames while it stays tangible, so `used_ok` and `wmotr_objects`
  (in Φ) were false during the rise. Repaired: the seat list is every home seat + 5k
  (0.8 (c')); the walk is re-run at all 140 seats. No new trust.
- **FOUND (over-claim): cannon lids move.** Row 0.8 (b) said the surface-owning objects stay at
  their spawn height; an opening lid sinks 15 and slides. `obj_floor_ranges` widens the lids'
  ranges 15 down. No new trust.
- **FOUND (coverage): frames without Mario's update had no step.** Paused, transition,
  time-stop frames: `idle_frame_step` (0.5). The capstone covers runs through them.
- **FOUND (phantom ∀): the level phase from any frame-world memory.** `seg_level_spec`
  (action cell unchanged, Φ kept) was claimed from every PhiW memory, but the real
  `play_mode_normal` rewrites Mario's action and y when `sWarpDest.type` is not NOT_WARPING
  (`warp_area` → `init_mario_after_warp`, level_update.c:463-473, 389-390), when a demo or the
  credits run (`gCurrDemoInput` / `gCurrCreditsEntry`), and `initiate_delayed_warp` has no
  execution when `sSourceWarpNodeId` names a node the area lacks. Repaired: `FfWorld.warp_w`
  joins `lvl_w` (so `fworld` and PhiW): in PLAY_MODE_NORMAL `sWarpDest.type` = NOT_WARPING;
  `gCurrDemoInput` = `gCurrCreditsEntry` = NULL; a pending delayed warp has source node 0xF0 /
  0xF1 / 0xF3; and (2026-10-26) the pending op is no credits op, so the POST tail re-establishes
  `warp_w` from the real code (`LevelWarp.tail_warp_w`). PROVED at the boot witness: the witness chain now ends with the real
  `sWarpDest.type = WARP_TYPE_NOT_WARPING` of `init_mario_after_warp` (:397, `StartSat.Z18`;
  before, the witness had the CHANGE_LEVEL left by `initiate_warp`, a state the game is never in
  at a WMotR frame boundary); the demo / credits pointers and `sDelayedWarpOp` keep their boot
  zeros (`L_cdi`, `L_cce`, `L_dwo`). KEPT by every proved row (`AnimKeep.lvl_w_keep` /
  `lvl_w_keep_ne`, generalized to `FfWorld.lvl_sym`: the six blocks are apart from every
  written region); the labeled flanks (poll, level phase, objects) and the open
  `Hseg_na_open` rows now claim it (it holds in the game: every warp WMotR can start leaves the
  level, and `play_mode_normal` leaves NORMAL in the same call). The instant and painting warps
  are already dead under the carried floor-type clause.
- **RESOLVED: `PlatformKeep.plat_still`.** TRUE of the game (0.7 details, `AngleVelCensus`);
  proved at the boot witness, carried by the labeled objects spec, no longer a step premise.
- **Repaired (merge break, no trust change): the `combo21` merge did not build.** The
  `gBodyStates` pin added to `ffw` (`bbs` / `SBS` / `LBS`) was missing from the ffw destructs and
  rebuilds in `RenderKeep` and `PlatformKeep`, which were written against the older `ffw`. These
  now carry the pin (render and platform keep it: `FFW_BODY` = 152 lies outside their writes).
