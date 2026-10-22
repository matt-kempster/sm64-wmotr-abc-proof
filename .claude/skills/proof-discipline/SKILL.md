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
  `generate_yellow_sparkles` is a hybrid walk). New labeled open audio premise
  `Hsss : SpawnBodies.sss_inert` (`stop_sounds_from_source`, via `unload_object`; TRUST 4.1).
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
  Counts: GOAL 1 17; HeightFrame 26 incl. its 3 section rows (2026-10-21, spawn: −2 rows, +Hsss).
  `surface_load.c` linked 2026-10-22 (32nd TU), then `macro_special_objects.c` + WMotR level data
  (TUs 33-34): counts unchanged (no row names their functions).
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
  (`TerrainBound.tri_chk_sound`: per-triangle binary32 bound). This is conditional only on
  `world_ok` (sqrtf = IEEE sqrt, `reset_red_coins_collected` inert) for "this is the loader's
  output". `main_pool_init` has no CompCert execution (ALIGN16 on a pointer).
  Next: move that memory into `StartSat`'s `init_mem` witness (keep `MWF_real` across the load);
  `gCurrCourseNum`; ask about an FPU-floor row for `sqrtf`'s value. FOUND FALSE + repaired
  when linking area.c: any-argument `override_viewport_and_clip` (in `obj_ext_ids`) stores its
  pointer args into `D_8032CE74/78`; those joined `stored_globals`. Linking a TU turns every
  any-argument row naming its functions into a claim about real code: re-audit them.
  Since 2026-10-20 the three frame rows below are LEMMAS of the frame split (since 2026-10-21
  the STAGED `FrameSplit.frame_stage`, which threads the dispatch's floor refresh
  `FfWorld.fresh` / `fresh_at` through the body in order and over the real dispatch loop); the
  assumed rows are the per-call `Hseg_call_na` (`seg_call_rows_naF`, with `pre_of` / `post_of`:
  update_mario_inputs leaves the floor fresh, handle_special_floors / process_interactions keep
  it, each dispatcher returns 0 or leaves fresh_at) / `Hseg_any` (one per call in the real
  `execute_mario_action` body; the two store blocks are proved). What each per-call row
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
    TRUST 0.6); the ff / ahw rows still read it. Phantom-∀ caveat (pre-existing): the
    open rows claim FRO after let_go_of_ledge -> SOFT_BONK, true in the game (find_floor's +78
    bound, y drops <= 100) but not derivable from fworld. Walk files: one walk each (KbSb/KbBkb/KbFkb/KbDv),
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
    PROVED by `CeilHeight.fc_height` and removed (28 → 27). Pole kit: `PoleRun` (usedObj
    region RU, `pk_ok`), `PoleClass` (classifier), `PoleSound`, and `PoleKeep` (`fkp_ok`,
    `no_reg`, `fkp_frame_except`). Ready contracts: `SmaXc.c_smawa` (set_mario_anim_with_accel)
    and `PoleXc.past_frame_value_contract` (is_anim_past_frame).
    Blockers for the remaining pole cases:
    - HOLDING_POLE calls `set_sound_moving_speed`, an unlinked audio external that
      `Haudio` does not cover. It needs a new premise, so it waits for the user.
    - CLIMBING_POLE reads `m->area->camera->yaw`. ffw has no camera fact, and the StartSat
      witness area is a fresh, all-Vundef block. The fix is to carry a `wblk` camera fact in
      ffw (extend the witness; preserve it in each row), then walk the case with `c_smawa`
      and `is_anim_past_frame`.
    - TOP_OF_POLE*: need the DMA row (approved), gMarioAnims linked (it is a size-0 extern),
      and animFrame ≥ −1.
    Next: the ledge cases and IN_CANNON.
    The FELL_OFF → FREEFALL path sets y := base and does not refresh floorHeight. `fresh`
    carries only fh <= y_entry + 241, while y_entry may be up to about base + 16, so it is
    not enough. That path needs a carried pole fact (y = oPosY + polePos, within float
    slack) together with find_floor's +78 bound.
    The top-of-pole cases need the handstand anim data linked: a generated-code bound alone
    (s16 / 4 ≤ 8191) fails `pole_check`, and the loosest POLE_UP that passes is 4343
    (TRUST (j)). Since 2026-10-22 the data is clightgen'd (`generated/mario_anim_data.v`, data
    only) and `PoleAnim.pole_up_covers_handstand` proves the 174 / POLE_UP = 160 from it
    (`kept`, not load-bearing). Still missing for a walk (TRUST 0.8(f), each a NEW trust item):
    a DMA content spec (ROM bytes), the boot-built dmaTable as a frame-world fact, animFrame
    ≥ −1 (rendering unlinked). (Segment 0 was the fourth: every real top-of-pole frame had NO
    execution, V2P subtracting 2^31 that the identity segmented_to_virtual never added back.
    REPAIRED 2026-10-22: the whole NO_SEGMENTED_MEMORY macro family, `AnimRoundTrip.anim_y_runs`.)
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
