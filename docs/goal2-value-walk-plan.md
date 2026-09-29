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
