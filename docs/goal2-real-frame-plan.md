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

- **Platform displacement is provably inert.** WMotR's level script has NO
  moving platforms / carpets / object surfaces (verified: zero matches in
  `levels/wmotr/script.c`; the carpets are Rainbow Ride). `gMarioPlatform`
  is only set non-NULL when a floor has `->object != NULL`; WMotR's terrain
  is entirely static ⇒ `gMarioPlatform ≡ NULL` ⇒
  `apply_mario_platform_displacement` early-returns
  (`platform_displacement.c:174`). `seg_platform`'s spec = "if the
  gMarioPlatform cell is NULL, memory is unchanged on Mario's block", plus
  a carried NULL-invariant. One lemma, no new TU.
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
