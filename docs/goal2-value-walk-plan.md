# GOAL 2: how to discharge `Hframe_is_move_chain` (plan, 2026-09-28)

Status: plan, from a scoping study of GOAL 1's engine, the Move catalog and the
generated air-step code. Nothing here is proved yet except the Φ fix in §1.

## 1. Statement repairs first

- **Φ's velocity ceiling was too loose. FIXED (2026-09-28).** `InRange` allowed
  vel[1] ≤ 128 in every mode. A grounded Φ-state could be rising at 100, since
  stationary landings keep vel[1] (stationary.c, mario_step.c:236). Its walk-off
  (INPUT_OFF_FLOOR → ACT_FREEFALL, vel kept) is in no Move, because the
  freefall launch cap is 43. So `Hframe_is_move_chain` was false over Φ. InRange
  now says vel[1] ≤ 43. The budget proofs still go through, and the real no-A
  data agrees: launches are ≤ 37.5, and frame-end vel[1] reached at most 26 in
  86k frames.
- **The world is unconstrained. OPEN.** `in_wmotr` pins only `gCurrLevelNum`.
  Φ and the rows say nothing about the surfaces Mario stands on, the objects he
  collides with, or quicksand and water. So both open rows are false over
  phantom worlds:
  - a BURNING floor → ACT_LAVA_BOOST (breaks `Hframe_stays_noA`);
  - an object with a bounce top → `bounce_off_object` pos := oPosY + … (breaks the chain);
  - `quicksandDepth` ≠ 0 → `sink_mario_in_quicksand` lowers gfx.pos every frame.

  **Fix:** a world invariant W carried by the run: surfaces are WMotR's own
  (types DEFAULT / HANGABLE / DEATH_PLANE / NOT_SLIPPERY / HARD_NOT_SLIPPERY),
  object-pool shape, interact types, pole and cannon fields, heldObj and
  riddenObj NULL, quicksandDepth 0, no water. W's preservation by `seg_level`
  and `seg_rest` becomes a new trust row (TRUST 0.7), tethered in the real game.

## 2. Why not reuse GOAL 1's engine

- `execute_mario_action_preserves_real_reached_lp` (RealFrameLinked.v:757) is
  generic in `Qv`, but the per-funcall contract is discharged only at
  `Qv := not_tainted` (EngineV2Consumer.v:743).
- The cell is hard-coded in the store checker: `store_window_ok`
  (CensusV2.v:705) excludes bytes 12–16 etc.
- Avoidance works for the action cell because it has one writer family. Φ's
  cells are written in most handlers: actionTimer++, about 70 vel[1] sites and
  52 pos[1] sites. A census over them would just fail.
- The gfx cell lives in the object pool (SafeB). Proving other object-pointer
  stores miss `marioObj+36` needs a pool-alignment invariant GOAL 1 never had.

## 3. Moves are handler summaries, not function lemmas

`perform_air_step` alone does not map to one Move. The slide-kick clause folds
the handler's `++actionTimer` (airborne.c:1586) into `S_air`: `v + 2·tm` is only
invariant jointly. So the unit is one dispatched handler segment, from dispatch
to return. The chain goes through ghost intermediate cells that the matcher
chooses. For example, a rollout from a dive slide is one S_attach from the
ground cell straight to (rollout, v = 30); no state is taken with vel still at
0. Units: update_mario_geometry_inputs (S_refresh / S_oob);
mario_process_interactions (pole, cannon, box hit from below: vel := 0); each
no-A air handler (air step, then switch, landing or ledge); act_ground_pound
state 0 (windup); ground handlers (S_attach); set_mario_action family (switch
or launch).

## 4. Route: a symbolic executor, proved sound once

Generalise `proofs/Interp/ClightInterp.v` (the concrete interpreter; about 660
lines, `ex_sound` proved) to symbolic values:
- Φ cells as exact binary32 terms over the entry cells, so matching to the
  catalog's `air_step_y` etc. is mostly syntactic;
- concrete ints for action, state and timer;
- pointer provenance (bm+off, marioObj, a pool object, a local, a global);
- external calls answered by value contracts (find_floor returns a WMotR floor
  height, etc.);
- path splitting with fuel (the loops are bounded: 4 quarter steps and the
  collided-object list).

A checker maps each path summary to a MoveChain. A few dozen arithmetic side
goals are closed from catalog lemmas. The run also gives `c_action` exactly, so
`Hframe_stays_noA` falls out of the same run, without re-proving GOAL 1's 31
surface files at `Qv := R_noA`.

| step | sessions |
|---|---|
| 0. World invariant W, statements, oracle re-check, TRUST | 2–3 |
| 1. External value contracts (or clightgen `math_util.c`) | 1–2 |
| 2. Symbolic executor + soundness | 5–8 |
| 3. Move matcher + side obligations (InRange: y ≥ −8192 via floor existence) | 2–3 |
| 4. Composition (prologue, the TRUE loop, epilogue) and wiring both rows | 1–2 |
| **total** | **≈ 11–18** |

The hand-proof alternative (per-function inversion like `playground/ValueWalk.v`,
plus re-parameterising GOAL 1's engine) is estimated at 30–45 sessions.
ValueWalk took about a session for one 3-statement slice, and the air-step
cluster alone is about 2,100 lines of generated Clight.

**Risks:** W's preservation is new trust about external pools; soundness
details (16-bit chunks, Vsingle casts, overlapping stores); vm_compute cost over
the 12-TU genv (bool readback only, `ge12` / `CMem`); path explosion in
`mario_process_interactions`; further Φ non-inductivity. So run the executor's
path summaries against the oracle before proving anything.

## 5. Prototype results (experiments/symexec, 2026-09-29; unverified)

A Python symbolic executor over the real generated Clight: all 12 TUs plus
`generated/math_util.v` (the vec3 helpers are generated too). Joins at call
returns and loop heads are what make it tractable.

- **perform_air_step** (freefall, no A, W assumed): 102 outcomes (stepArg 0),
  193 (stepArg symbolic), about 5k forks, 4 s. pos[1] is exactly the binary32
  quarter sum `(((Y + V/4) + V/4) + V/4) + V/4`, or a floor height on landing
  (FH on an OOB landing), or the ledge floor. vel[1] is `V - 4`, `-75`, or
  `-4` (ceiling cut). gfx = pos on every path.
- **apply_gravity**: two results, `V - 4` and `-75`, i.e. `gravity f4 V`.
- **act_freefall**: 421 outcomes, 8 target actions. **act_slide_kick**: 151,
  matching S_air's slide-kick clause (timer + 1, g = 2), the bounce
  (vel = −(V − 2)/2, state 1, timer 0), and the → freefall switch.
- **execute_mario_action**: runs, but hits the 400k-fork cap. It needs
  per-handler summaries or feasibility pruning. With arbitrary collided
  objects it reaches about 40 actions, which is the phantom-world problem seen
  concretely: W needs an object-collision conjunct.

**Statement fixes it forced (done):**
- S_air_cut / S_sk_bounced_cut equated pos as binary32. The remaining quarters
  compute pos + 0.0f, which maps −0.0 to +0.0, so the equality is now over R2.
- W now requires `m->floor ≠ NULL` (apply_vertical_wind dereferences it).

**Still to check:** landings keep vel (`V − 4`, down to −75), and a pedro-spot
landing leaves floorHeight stale while pos = the new floor. S_attach must
accept both; it does not constrain floorh except at ledges, and InRange
allows vel ≥ −75. Water paths need Φ's y ≥ −8192 as a path fact. World
reads the proof needs facts about: surface type/flags/normal,
`area->terrainType` (SNOW, so FEET/HEAD_STUCK_IN_GROUND are real), squishTimer,
hurtCounter, health, peakHeight, interactObj.

## 6. Whole-frame results (experiments/symexec, 2026-09-29; unverified)

**Tractability: yes.** `execute_mario_action` with no A and W assumed
terminates from every starting action group, in 2–86 s and ≤ 336 MB. Starts:
FREEFALL, SLIDE_KICK, GROUND_POUND, DIVE, WALKING, CROUCH_SLIDE, DIVE_SLIDE,
IDLE, HOLDING_POLE, CLIMBING_POLE, TOP_OF_POLE, LEDGE_GRAB, IN_CANNON. Each
run reports 10–1,212 paths; these are upper bounds, since there is no solver.
Four things make it work:
- **Per-function summaries,** keyed on the caller's concrete action, state
  and arg. Validated only on act_freefall: the same 107 Φ shapes with and
  without summaries.
- **Interval pruning** on Y / GY / V from Φ's ranges, including relational
  bounds. This kills every water path.
- **Known-bits joins,** which keep the A bits of `m->input` known-zero.
- **Cycle cuts** at the dispatch TRUE-loop head. WALKING never converges
  (about 680 states). A loop-head state whose key has already occurred is cut,
  which under-approximates the cells outside the key.

**Φ results vs the Move catalog:** all of them map to catalog Moves:
- air / cut / OOB steps, ground-pound windup / hold, attach;
- ground → rollout (attach, then S_air);
- ground → AIR_KB (attach; launch_cap 52 ≥ 43);
- pole grab (Φ = pole oPosY − hitboxDownOffset, clamped by hitboxHeight: the
  wmotr_pole row);
- IN_CANNON (usedObj->oPosY + 350: the wmotr_cannon attach).

The only exception is a SQUISHED ↔ IDLE cycle, which W's geometry removes (below).

**Actions outside R_noA the frame reaches over phantom worlds, and what excludes each:**

| reached | trigger | excluded by |
|---|---|---|
| ACT_SQUISHED | INPUT_SQUISHED: a DYNAMIC floor or ceiling and 0 ≤ ceil − floor ≤ 150 (mario.c:1344) | a geometry fact about WMotR's dynamic surfaces (the ! boxes and cannon lid) that belongs in the find_floor / find_ceil value contracts (plan step 1); no such pair exists (goal2-state: the squish-cancel ratchet is dead) |
| ACT_SHOCKED, SHOCKWAVE_BOUNCE | INPUT_STOMPED from marioObj->oInteractStatus bits 0x13 | **W** (`wmotr_objects`): no stomp bit. The frame zeroes the field (mario.c:1773); no WMotR object sets it (census §3) |
| STAR_DANCE_*, FALL_AFTER_STAR_GRAB, JUMBO_STAR_CUTSCENE | a collided INTERACT_STAR_OR_KEY object | **W**: collided interact types ⊆ WMotR's {0, COIN, CAP, POLE, BREAKABLE, CANNON_BASE, TEXT}. The star exists only after coin #2, which needs y ≥ 2980 (TRUST 0.3) |
| ACT_COUGHING, SUFFOCATION | IN_POISON_GAS | nothing needed: a prototype imprecision (a summary join loses the bit). WMotR has no gas, which is also a find_poison_gas_level contract |
| SHOCKED, BURNING_* | shell / flame probe objects | W's interact-type clause |

**Object memory Φ depends on:** only a collided pole's oPosY,
hitboxDownOffset and hitboxHeight, and a collided cannon base's oPosY. W pins
each to a WMotRLevel list entry. The prototype saw other fields read, but
they reach only path facts or nothing:
- coin: 0x180 value;
- breakable: oPosY, used for the hit-from-below test;
- text: hitboxRadius, oPosX/Z, subtype;
- star: bhvParams, subtype.

**Caveats:**
- no solver, so path counts are upper bounds;
- summaries are validated on one handler only;
- unmodelled externals are havoc or have no memory effect;
- floats are assumed non-NaN;
- one collided object per run.

The Coq executor must replace each of these with a sound rule: a join or
widening instead of a cycle cut, and contracts instead of havoc.

## 7. First Coq slice (2026-09-29; proved, UNWIRED)

The route of §4 now runs end-to-end in Coq on the smallest real function.

- **Executor:** `proofs/Interp/SymExec.v`. It is a path-splitting symbolic executor for
  Clight, proved to cover every big-step run (`sx_sound` / `sx_call_sound`,
  `eval_funcall function_entry2`, no admits).
  - Symbolic values are denoted at the initial memory.
  - Constant operators fold through CompCert's generic injection lemmas.
  - Branch conditions are recorded as path facts.
  - Known-zero bits (`kz`) carry premises like no-A; known initial values (`kv`) carry
    facts like the action.
- **Consumer:** `proofs/WMotRRequiresA/Unwired/GravitySlice.v`, theorem
  `apply_gravity_freefall_noA`. It covers any program that links the twelve TUs, running
  the generated `f_apply_gravity` in ACT_FREEFALL with no A bits.
  - It proves vel[1] becomes `gravity f4 V`, the catalog's S_air formula including the −75
    clamp.
  - It proves no other byte of memory changes.
  - A vm_computed check (~10 s) confirms all 18 paths have that shape. The no-A fact prunes
    the wing branch.

**What it cost / taught:**
- Soundness is proved once, about 1.3k lines. A consumer is small: one checker, one
  shape lemma per path, and a denotation lemma.
- Kernel trap: never let a `Definition` stand between the vm_computed run and
  an abstract genv. Unfolding it makes the kernel evaluate the executor lazily, and `Qed` hangs.
  State the checked `match` inline, and consume it through a lemma over an arbitrary option.

**Still needed before perform_air_step and the full frame:**
- local variables (alloc and free; the frame currently needs `fn_vars = nil`);
- loops and `switch`;
- external calls as contracts;
- pointers loaded from memory (region aliasing);
- summaries at call sites instead of inlining.

## 8. Second-generation executor (2026-10-16; proved, kept, not yet consumed)

`proofs/Interp/SymExec2.v` closes every item of §7's "still needed" list. It is proved to
cover every big-step run (`sx_sound`, `sx_call_sound`). It has no admits and only CompCert's
standard axioms.

- **Locals.** Each `fn_vars` entry is a fresh region. Its block is chosen when
  `Mem.alloc` runs (`salloc_sound`), and `Mem.free_list` drops its cells (`sfree_sound`).
- **Loops** run breadth-first (`sx_loop`): all live states take one iteration together.
  The back edges are joined before the next round, so joins act across paths.
- **Switch** works when the scrutinee is decided.
- **Calls.** Internal calls are inlined, or answered by a consumer contract (`xc`).
  Contract soundness is a section hypothesis, `xc_sound`, stated against `eval_funcall`.
  A consumer that instantiates it must prove it, or list it in `docs/TRUST.md`.
- **World pointers.** Reads go through a pointer term `p` that a path fact `Fworld p n`
  says points at `n` bytes of `m0` outside every consumer region. Such reads read `m0`.
- **Fresh symbols** (`Sfresh`) are denoted by an environment that the proof extends.
- **Joins** (`join2`, `jgroup`, `jgroup_c` at contract-merged call sites) are proved to
  cover both inputs (`join2_sound`, `jgroup_PM`).
- **Premise of the meaning.** The meaning assumes `m0_closed` over a map `gp` of m0's
  *public* blocks: the region blocks are public, and the contents of a public block point
  only at public blocks. It is a hypothesis of the section, so a consumer must discharge it.
  (2026-10-18) It used to say *all* of m0's contents point into m0. That is not provable
  for a real memory, because CompCert's axioms let an external call (`sqrtf`) leave a block
  it allocated with any contents. The public form is exactly `ClosedMem.closed_by gp m0`
  (`closed_flat`, `closed_old`, `closed_load`), and external calls preserve it
  (`ext_call_closed`). **Any Clight call preserves it too** (`ClightClosed.funcall_closed`,
  2026-10-18): from `closed_by g m`, every global mapped, and arguments that are g-values,
  a big-step `eval_funcall function_entry2` ends closed by some g' ⊇ g, and the result
  is a g'-value. Locals are made public at allocation, and builtins and externals go
  through `ext_call_closed`. The only assumptions are CompCert's standard axioms. So a
  real frame keeps closedness, and so does every point inside it, including the entry
  to `perform_air_step`. Left: carrying `closed_by` across the run. The flanks (TRUST
  0.7) are specs, not linked code, so they would have to carry it the way they already
  carry Φ. That is the same theorem, once a flank is linked.

Measured on the real code (`playground/SymExec2Lab.v`, with stand-in contracts):
- apply_gravity: 18 paths; apply_vertical_wind: 9.
- resolve_and_return_wall_collisions: 5.
- perform_air_quarter_step: 112 paths, 16 after the call-site join.

**The full perform_air_step now runs** (22 s, 7328 raw outcomes) after two changes:
- **Skeleton keys.** `key_of` erases fresh numbering (`skel`). Paths whose key cells
  differ only in which fresh name they hold now meet. The old keys kept four quarter
  steps' worth of distinct terms apart and overflowed the stack after about 800 s.
- **Anti-unification joins.** `join2` used to replace every differing slot with a new
  fresh name and keep only facts that were literally equal on both sides. That dropped
  `Fworld (Sfresh 49) ...` for the floor pointer, so `apply_vertical_wind` could not read
  `m->floor` and the run returned None. `au` now joins same-operator terms operand-wise
  and names each differing pair once, through a memo. Facts are joined through the same
  memo (`au_fact`, read-only), so a fact or relation that holds on both paths survives
  (the floor pointer's `Fworld` fact, `pos[1] = floorHeight`). The proof's invariant
  `MINV` gives each memo name the value its pair has on the real side.

The call-site join on the whole step's outcomes gives 225 classes keyed on the lab's
key cells, and 4 keyed on the action cells alone. In those 4, `pos[1]` is either one
fresh name or a sum of two, so the action-only key is too coarse for the value walk.
Next: real contracts in place of the lab's stand-ins (`find_floor`'s value row, the wall
contract), then port the gravity slice to v2.

## 9. math_util in the link (2026-10-17)

`LinkGenv.ge12` follows `LinkedTwelve.tu_rest`, so the executor's genv now includes
`surface_collision` and `math_util`. That changed the stand-in contracts:
- `vec3f_copy` and `vec3s_set` need no contract. The executor inlines their real
  bodies, and `perform_air_step` gives the same counts as with the stand-ins: 7328
  outcomes, 225 after the call-site join, 4 on the action cells.
- `atan2s` keeps its contract (memory unchanged, some result). Inlining returns None
  because `atan2_lookup` reads `gArctanTable` at a symbolic index. The contract itself
  is what `MathBodies.cpure2_funcall_memid` proves, so its `xc_sound` case is a lemma
  away, not trust.
- Stand-ins still to replace with proved contracts: `find_floor`, `vec3f_find_ceil`,
  `find_wall_collisions`, `find_water_level`, `mario_get_terrain_sound_addend`. The
  first four are linked now (`surface_collision`), so their value contracts can be
  proved from the generated bodies. In WMotR the world reads go through the static
  surface partition.

Proved contracts (2026-10-17, later):
- `SymExec2.xc_fresh` is the contract "memory unchanged, an unknown old result".
  `xc_fresh_sound` proves that any call which leaves memory unchanged and returns
  an old value is described by it.
- `MathBodies.atan2s_value_contract` (real body: memory unchanged, returns a `Vint`) and
  `MathBodies.find_water_level_value_contract` (memory unchanged, returns a `Vsingle`)
  are the facts that `xc_sound` needs for these two ids. The lab now uses `xc_fresh`
  for both. The old `c_water` stand-in claimed the constant -11000, a world fact
  nothing proves. With `xc_fresh` the counts are unchanged: 7328 / 225 / 4.
- Still stand-ins: `find_floor`, `vec3f_find_ceil` and `find_wall_collisions`, whose
  results need list facts about the surface partition (the next brick), and
  `mario_get_terrain_sound_addend`. That body is store-free, but it has an `Sswitch`
  that `cpure2_chk` does not cover, and a `u32` return, so "not a pointer" is not a
  type fact.
- `FloorList.ff_value_contract` (Unwired) is the memory-level contract of the real
  `find_floor`. It assumes that the statics and the `*pfloor` cell are in an "avoid" set,
  and that the partition lists are well formed (`wf_list`: NULL-terminated, through
  valid blocks outside that set). Under those assumptions, `*pfloor` ends up holding NULL
  or a surface read from a node of a partition list in the entry memory, and every valid
  block outside the set is unchanged. The proof is a statement-level triple
  (`tri`, `solve_tri`) and runs in under a second; brute-force inversion was killed
  after 15+ minutes. Next: lift it to an executor contract by deriving `wf_list` from a
  world invariant.
- (2026-10-18) `ff_value_contract` is now cell-precise. Every cell of the entry
  memory except `*pfloor` and the three static cells (`ff_cells`:
  `gFindFloorIncludeSurfaceIntangible`, `gNumFindFloorMisses`, `gNumCalls.floor`)
  is unchanged, and no permission of the entry memory changes. `SymExec2.vp_old`
  now records exact permissions of old blocks (it used to record only valid
  pointers), so a contract can show that a cell readable at `m0` stays readable.
  The lab's `find_floor` stand-in was false: it left the three statics unchanged.
  It now writes fresh values to them and returns a fresh height on the NULL path.
  The counts are unchanged: 7328 / 225 / 4.
- (2026-10-18) `FloorExec.c_ff_sound`: the executor's `find_floor` contract is proved
  sound against the generated body. This is the first non-trivial `xc_sound` case.
  The new generic lemmas in `SymExec2` (`MMg_fresh`, `MMg_transfer`, `sstore_in`,
  `sstore_inb`) are reusable for `vec3f_find_ceil` and `find_wall_collisions`.
  Open obligations for wiring it into a proved walk:
  (a) the genv facts for the linked program (`cenv_has`, `ffl_pinned`, `gtab` entries,
      `sfun_lookup find_floor`);
  (b) `Wff` as a frame invariant;
  (c) the remaining contracts: `vec3f_find_ceil`, `find_wall_collisions`,
      `mario_get_terrain_sound_addend`, and `m0_closed`.
- (2026-10-18) Ceiling and terrain-sound contracts proved; (c) shrinks to
  `find_wall_collisions` and `m0_closed`.
  - `CeilExec.c_fc_sound`: the executor's `find_ceil` contract. One static cell
    (`gNumCalls.ceil`) gets a fresh value, and `*pceil` gets NULL or a world surface.
    It reuses `Wff`.
  - The lab no longer has a `vec3f_find_ceil` stand-in. It inlines the real wrapper
    and contracts `find_ceil` with `c_fc`.
  - `TerrainSound.terrain_sound_value_contract`: for any genv, the real
    `mario_get_terrain_sound_addend` leaves memory unchanged and returns a `Vint`.
    It has no stores and no calls, and every write of `ret` is an int shift. This is
    the `xc_fresh` shape, so the lab now uses `xc_fresh`.
  - Counts unchanged: 7328 / 225 / 4.
  - The lab's `c_walls` stand-in is false. It returns `numWalls` (0..4), but the real
    `find_wall_collisions` returns the total collision count. For 0..3 walls the two
    agree; past four walls `numWalls` stays at 4 while the count keeps rising. It
    also skips `gNumCalls.wall`. The proved contract will return `n` for n<4 and a
    fresh int ≥ 4 for n = 4.
- (2026-10-18) The value contract of the real `find_wall_collisions` is proved
  (`WallFind.fwc_contract`, standard axioms only). It chains `WallList.wfl_contract`
  over the dynamic and static partition lists of the queried cell. For some total
  c ≥ 0 it returns c, `numWalls = min(c, 4)`, and every recorded wall is a surface on
  a partition list of the entry memory. Only `x`, `z`, `numWalls`, the wall slots and
  `gNumCalls.wall` change, and no permissions change. Next is the executor contract
  `c_fwc`, which replaces the lab's false `c_walls` stand-in.
- (2026-10-18) **The value walk's contract table is proved sound.**
  - `WallExec.c_fwc_sound`: the executor's `find_wall_collisions` contract. It has
    five outcomes, n = min(count, 4). `x`, `z` and `gNumCalls.wall` get fresh values,
    `numWalls := n`, slots 0..n-1 get fresh world surfaces, and the result is n
    (fresh at n = 4). It replaces the false `c_walls` stand-in.
  - The proof needed two facts the old memory-level contract lacked, both now in
    `fwc_contract`: the wall-slot bytes past the count are unchanged, and the body
    reads `x`/`z` at entry, so they are readable.
  - It also needed a new reusable tool, `sstores_havoc`. A contract can describe the
    callee's result memory from the written cells' values plus "everything else is
    unchanged", without replaying stores on the caller's memory (the executor does
    not track a local's permissions).
  - `AirXc.air_xc_sound`: SymExec2's `xc_sound` holds for the full table `air_xc`
    (floor/ceil/walls contracts; `xc_fresh` for water level, atan2s and terrain sound).
  - `AirXc.air_xc_sound_link`: on any Clight link containing surface_collision,
    math_util and mario (linkorder, lp abstract), every genv hypothesis is
    discharged. What remains is the consumer's `gtab` entries (checked by
    computation) and the world fact's meaning (`Wff` at the frame's entry memory).
  - The lab now runs on exactly `air_xc`. Counts are unchanged: 7328 / 225 / 4.
  - Open for a proved walk of `perform_air_step`: `m0_closed` (now over public blocks:
    `closed_by gp m0`, so what is left is carrying `closed_by` through a frame and across
    the run); `Wff` as a frame
    invariant (carried by the GOAL-2 run invariant); and the consumer, which reads
    the 225 joined outcomes into `MoveChain` facts.
