# GOAL-2: widening to the real game frame — the plan (Fable, 2026-07-09)

*Replaces nothing on disk: the only prior "plan" file was the June reorg
(executed 06-01). This is the frame-widening plan, built on two verified
scouts: `goal2-frame-boundary-scout.md` (the per-frame call chain + the
frame-root decision) and `goal2-posy-writer-census.md` (all 40 writers of
Mario's y, classified). Both were store-scouted against the generated AST;
the load-bearing claims (no WMotR platforms; the displacement early-return)
were independently re-verified.*

## 0. The one architectural decision (and what it rejects)

**The real frame is modeled as a COMPOSITION OF SEGMENTS, not a wider
`eval_funcall`.** The true per-frame chain is:

```
update_objects:                                (object_list_processor.c — UNLINKED)
   apply_mario_platform_displacement           (platform_displacement.c — UNLINKED; writes m->pos)
   → behavior VM → bhv_mario_update
        → execute_mario_action                 (mario.prog — GOAL-1's walked frame)
   → update_mario_platform                     (UNLINKED; writes gMarioPlatform only)
(level phase: check_instant_warp etc.          (level_update — LINKED; TELEPORT writers)
```

Widening the single symbolic execution to `update_objects` would require
clightgen'ing + linking ≥4 new TUs including the whole object-behavior VM —
a large pipeline/link/walk campaign (and the memory-heavy class of work).
**REJECTED.** Instead:

```
frame_step m m' :=
  exists m1 m2 m3,
    seg_platform m  m1   (* SPEC: inert in WMotR — see T1 *)
 /\ seg_action   m1 m2   (* = GOAL-1's execute_mario_action_step_lp, AS-IS *)
 /\ seg_level    m2 m3   (* SPEC: the warp/level phase — TELEPORT census *)
 /\ seg_rest     m3 m'   (* SPEC: the non-Mario object/gfx phase boundary *)
```

- `seg_action` is untouched GOAL-1 machinery — every walked body, the MWF
  invariant, the no-fly result all reuse verbatim.
- The flanking segments get **named specifications** (the same honest
  labeled-trust pattern as the external-call model), each backed by a
  WMotR-grounded discharge or an explicit boundary row.
- **GOAL-1 transfer is trivial by construction**: the flanking segments'
  specs include "does not write the action cell," so the no-fly invariant
  crosses the composition. GOAL-1's capstone is never edited; if we later
  want it restated over `frame_step`, that is a strict-improvement follow-up.

## 1. Why the flanking segments are cheap in WMotR (scout facts)

- **Platform displacement is provably Y-INERT (corrected by T1, 2c4b80c).**
  The first draft claimed `gMarioPlatform ≡ NULL`; that is FALSE — the six
  wing-cap exclamation boxes are DYNAMIC object floors, three reachable
  no-A (tops −1028/−2428/572 below spawn), and standing on one fires the
  non-NULL writer. The honest invariant is **NULL-or-box**, and BOTH arms
  are y-inert: NULL ⇒ the `:174` early-return (memory no-op); box ⇒ the
  displacement's y-write (`platform_displacement.c:83`) passes the current
  y through IDENTITY unless the platform has angular velocity
  (`oAngleVel*`, `:107-142`), which the box behavior never writes
  (Fable-verified at source). So `seg_platform`'s spec is the widened
  `seg_platform_yact_inert` — "the y cell and the action cell load
  unchanged" — proved-consumable glue in `playground/PlatformInert.v`,
  with four NAMED boundary premises (init-NULL, the early-return spec,
  the box-arm y-identity, floor→object only-for-boxes) whose full
  discharge would need clightgen'ing platform_displacement.c (deferred;
  the boundary is honest and small). T0's skeleton must swap its
  `gplat_null` rows for this widened spec (sandbox retool, queued).
- **The TELEPORT writers are enumerable**: `init_mario` (spawn — one-time,
  the run's antecedent) and `check_instant_warp` (level_update, LINKED —
  WMotR's instant-warp table is censusable from the level data; expected
  empty or bounded).
- **The one pre-action writer inside mario.prog**: the OOB-recovery
  `vec3f_copy(m->pos, gfx.pos)` (mario.c:1328, guarded by `floor == NULL`)
  — self-referential (gfx.pos was copied FROM pos), handled by a carried
  "gfx.pos[1] = last committed y" invariant or the simpler bound
  "gfx.pos[1] ≤ YMAX carried alongside".

## 2. The y-invariant work, by writer class (census §5-§9)

All 40 pos[1] writers fall into classes; each class gets ONE treatment:

| class | members (representative) | treatment |
|---|---|---|
| BALLISTIC | `perform_air_quarter_step` (3 sites), ground pound | **the real work**: extend the existing paqs walk to track the WRITTEN VALUE (`y' = y + vel/4`), bounded by the Flocq brick (T2) + the vel census |
| ATTACH | landing snaps, ledge/pole grabs (floor-height writes) | the ladder argument: value = a floor height ≤ H\* (needs the `find_floor` VALUE contract — initially a spec'd boundary row, discharged when P1' links surface_collision) |
| MONOTONE-SAFE | quicksand sink, water bobs, `f32_find_wall_collision` (y-identity) | writes ≤ current y — trivial for an upper bound |
| TELEPORT | `init_mario`, `check_instant_warp` | census the targets against WMotR's data (spawn = antecedent; instant warps expected none) |
| EXOGENOUS | `apply_platform_displacement` (UNLINKED) | inert in WMotR (T1) — never needs walking |

## 3. Tracks (parallel-friendly; every one sandbox-first)

- **T0 — the composition skeleton** *(playground/, then Unwired)*: define
  `frame_step` as above; state the GOAL-1-transfer lemma and the
  one-frame y-lemma skeleton (`y_le YMAX m → frame_step m m' → side
  conditions → y_le YMAX m'`). Admits allowed in playground only.
- **T1 — platform inertness** *(small, delegable)*: the gMarioPlatform-NULL
  invariant + the seg_platform no-op lemma, grounded in the WMotR surface
  census (E1's static-surface inventory).
- **T2 — the Flocq interval brick** *(independent, delegable)*: E4 from the
  strategy — `B2R(add x y) ≤ bx+by` under no-overflow; recipe already
  pinned (Bplus_correct + round_le, feasibility-probed 07-02). Target: the
  paqs `pos[1] += vel[1]/4` step and the gravity `vel[1] -= 4` step.
- **T3 — the BALLISTIC value walk** *(the crux, Fable-designed)*: a
  value-tracking variant of the paqs walk — GOAL-1's walks prove stores
  *avoid* a cell; this one must prove the store's VALUE satisfies the
  interval. New engine idea, prototype in playground before any engine
  generalization. **This is GOAL-2's analogue of the action-value engine
  and the main research object.**
- **T4 — ATTACH/TELEPORT specs**: the find_floor value-contract row
  (boundary until P1'), the instant-warp census, the OOB-gfx invariant.
- **Promotion**: playground → `WMotRRequiresA/Unwired/` (admit-free) →
  the GOAL-2 spine skeleton (strategy E7) once T0-T3 compose.

## 4. Standing constraints (non-negotiable, from hard experience)

- **No OOM class**: per-body walks only; never compute/link whole programs;
  vm certs peak-bounded; `-time` on first compiles of anything vm-heavy;
  serial builds; the 6GB ulimit guardrail stays.
- **Store-scout law**: no classification trusted until verified per-Sassign
  against the generated AST (this plan's scouts already caught my carpet
  error and 3 earlier design misclassifications).
- **No phantom statements OR premises**: every fact arg-aware and gated;
  every oracle premise satisfiable (the P1' lesson).
- **GOAL-1 untouchable**: nothing in this plan edits the GOAL-1 spine;
  the sandbox firewall (playground/ + Unwired/) is the boundary, and the
  six-theorem audit must stay green after every promotion.

---

## §5 T3 design brief: the interval-environment value walk (Fable, post-T2)

T0/T1/T2 are landed (playground/: CompositionFrame.v, PlatformInert.v,
FloatBrick.v — all compiling, zero admits, standard axioms). What remains
open in the one-frame y-theorem is `Hseg_action_y`: the action segment
keeps y ≤ YMAX. The mechanism, designed against T2's delivered shapes:

**The new engine idea — track VALUES, not just avoidance.** GOAL-1's walks
thread a taint/avoidance invariant through `exec_stmt` induction ("no store
hits (bm,12)"). T3 threads an **interval environment**: a partial map from
temps to real-valued upper bounds (`ienv : ident -> option R`), with the
invariant "if `le!t = Some (Vsingle v)` and `ienv t = Some B` then
`B2R v ≤ B` (and finite)". Walk arms:
- `Sset t (load of pos[1]/vel[1])` → bind `t` to the carried Y/V bound
  (from the y_le/vel_le entry facts).
- `Sset t (arith)` → the T2 bricks: `f32_add_le_bound`,
  `f32_quarter_exact`/`f32_quarter_step_y_bound` (div-by-4.0f), `f32_sub4_*`
  (gravity), the −75 clamp only raises → bound preserved.
- `Sassign (pos[1]) (Etempvar t)` with `ienv t = Some B ≤ YMAX` → the
  commit is bounded. This is the BALLISTIC arm.
- Landing/ceiling branches commit a FLOOR HEIGHT instead → the ATTACH arm:
  consume the `find_floor` value-contract row (boundary until linked) +
  the ladder fact (every WMotR floor ≤ H*).
- Calls: the quarter-step helpers get value-aware call rows (the paqs walk
  already exists for avoidance; the value variant re-walks the SAME body
  with the richer invariant — the avoidance walk is the template, the
  interval env is the addition).

**Prototype scope (first increment, playground/ValueWalk.v):** ONE
quarter-step's ballistic branch — from `intendedPos[1] = pos[1]+vel[1]/4`
(mario_step.c:620, the generated `f_perform_air_step` ~L4529) through the
AIR_STEP_NONE commit — proving the committed y ≤ Y + V/4 via
`f32_quarter_step_y_bound`. Straight-line + one branch; no loop yet. The
loop (4 quarter-steps) then composes the bound 4× (Y + V with the gravity
step interleaved — the per-frame budget from the strategy doc). Only after
the prototype threads do we generalize an engine arm (the P1' lesson:
never generalize before one concrete instance is green).

**Vacuity guards baked in:** the ienv rows are arg/entry-gated (never
∀vargs); every side condition (`generic_format`, the bpow-100 cushion) is
discharged at concrete game values; the ATTACH row is a named boundary
with the ladder census behind it.
