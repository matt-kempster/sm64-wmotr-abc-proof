# GOAL 2: decomposing the crux row `Hseg_action_phi` (2026-09-27)

**Status: built.** `Hseg_action_phi` is now the lemma `HeightFrame.seg_action_phi`, from
`Hact_whitelist`, `Hframe_move`, `wmotr_gap` and `wmotr_poles`. The moves are the `Step`
constructors in `proofs/WMotRRequiresA/HeightMove.v`, and `Phi_of_moves` proves them.
The design below is kept for reference. §"As built" at the end lists what changed on the
way.

Original design notes follow. It is based on `HeightFrame.v`, `HeightPhi.v`,
`Unwired/HeightBallistic.v`, `Unwired/HeightMoves.v`, `goal2-phi.md` and GOAL 1's
`RealFrameLinked.execute_mario_action_preserves_real_reached_lp`, which is
parametric in the action predicate `Qv`.

## Shape

```
Hseg_action_phi  (one real execute_mario_action keeps Phi)
  <=  Hact_whitelist  : GOAL 1's engine at Qv := R_noA             (real program)
   +  Hframe_move     : the real frame moves Mario's Phi cells by  (real program;
                        a FrameMove (below)                         the value walk)
   +  Phi_of_move     : PhiC c -> FrameMove c c' -> PhiC c'         (PURE, provable)
   +  Hff_value       : find_floor returns -11000 or a WMotR floor  (boundary until P1')
                        plane height <= (s16)y + 78
   +  wmotr_gap       : no floor height in (K, K + 622)             (level data)
```

- **Cells**: `action`@12, `actionState`@24, `actionTimer`@26, `pos[1]`@64,
  `vel[1]`@76, `floorHeight`@112 (all pinned in `HeightPhi.v`).
- **`PhiC c`** is `Phi_wmotr`'s existential body, stated over those cells.
- **`FrameMove`**: a floor refresh (`update_mario_inputs` → find_floor), then the
  reflexive-transitive closure of `HMove`. It is a closure because a handler returning
  TRUE re-runs the loop within one frame (air step → LANDED → ground step).

## `HMove` constructors

| move | what it does | proved by |
|---|---|---|
| ballistic | k ≤ 4 quarter steps of `y += v/4` (a ceiling or wall can stop early), then gravity g(action) and the −75 clamp | `ballistic_frame` (Unwired/HeightBallistic.v) |
| attach | y := floorHeight, a find_floor return ≤ y + 239 (landing / ledge) | `gap_fact_step` + `wmotr_gap` |
| launch | ground → air action, vel := a table constant, same y | `launch_budget` (Unwired/HeightMoves.v) |
| bounce | SK / BSA landing, vel := −vel/2, y := the floor | `sk_bounce_budget`, `bsa_bounce_budget` |
| switch | action edge from E3's table: y unchanged, vel unchanged or ≤ 0 | `sk1_to_freefall`, `freefall_to_gp` |
| GP windup | y += 20 − 2·timer, timer + 1 | `gp_windup_frame` |
| ground | y := a find_floor return, or y lowered | `landing_budget` |
| lower | y decreases, the other cells unchanged | trivial |

`HMove` is only as complete as the census of writers to Mario's pos[1], vel[1],
state, timer and floorHeight. Each constructor must be store-scouted against the
generated AST (`docs/goal2-writers-vs-moves.md`).

## Reusing GOAL 1

- **(i) The action whitelist.** Instantiate `execute_mario_action_preserves_real_reached_lp`
  at `Qv := R_noA`. Every non-Qv premise is reused verbatim. The new obligation is
  the writer arm: every no-A writer site writes a value in R_noA
  (`docs/goal2-rnoa-census.md`).
- **(ii) Cells unchanged unless written.** Generalise the avoidance walks from
  `action_cell` to `phi_cells`, the offsets above.
- **Genuinely new:** the value arms at the writer sites (`playground/ValueWalk.v`,
  scaled up). These are the paqs y commit, `apply_gravity`, the floorHeight commits
  at landing and ledge, and the windup add.

## Side clauses Phi still needs (`ballistic_frame`'s premises)

- `|vel[1]| ≤ 128` (census: `docs/goal2-vel-y-bounds.md`).
- A lower bound on y while rising, or a `ballistic_frame` variant that doesn't need
  one: relax it to |y| ≤ 16000, plus a descending variant with no lower bound.

## First increment (one session)

1. Promote `HeightBallistic.v` and `HeightMoves.v` to the spine.
2. Define `Cells`, `PhiC`, `HMove` with the proved constructors plus
   `HM_other : OtherEdge c c' -> HMove c c'`, and `FrameMove`.
3. Prove `Phi_of_move` by rt-closure induction: the per-constructor lemmas above,
   with `Hother_edge` for `HM_other`.
4. Restate `HeightFrame.v`: replace `Hseg_action_phi` with `Hact_whitelist`,
   `Hframe_move`, `Hother_edge`, `Hff_value` and `wmotr_gap`, and derive
   `seg_action_phi` as a Lemma.

## As built (2026-09-27)

- **Cells gained `gfx.pos[1]`** (`marioObj` @ 136, `header.gfx.pos` @ 32 in `Object`).
  OOB recovery copies it into pos (`mario.c:1328`), so Φ also bounds the budget at gfx
  y. Every air step, ground step and `set_pole_position` re-syncs it.
- **Moves** (`Step`):
  - `S_air`: 4 quarters, then gravity; v' may end *below* gravity (the jump-ascent `/= 4`).
  - `S_air_cut`: a ceiling stops the step at k ≤ 4 quarters, or a GP state-1 fall.
  - `S_sk1` and `S_sk1_cut`: the post-bounce slide kick over signed energy.
  - `S_gp_windup` and `S_gp_hold`.
  - `S_switch`: E3's edges. Plain-air targets get v' ≤ v; freefall is entered from
    freefall, butt-slide-air or a slide kick past 30 ticks; freefall → GP.
  - `S_attach`: anchored at a grounded y, a WMotR floor within 239, the ledge floor, or a
    pole, with per-kind launch caps.
  - `S_refresh` and `S_oob`.
- **Constants changed**, each forced by a move:
  - `sk1_credit` + 1/4 while v > −1: the SK ceiling bonk. The bounce apex is now 371.707.
  - `windup_left` + EPS per windup frame left (the binary32 add), and `GP_RESERVE` 110 → 111.
  - The slide-kick clause is `v + 2·tm ≤ 37.5 + tm/1024 ∨ v ≤ −73`, for both states,
    because of binary32 rounding and the −75 clamp.
  - A new ground-pound clause: state ≠ 0 ⇒ v ≤ 0.
- **Ranges** (`Range`: finiteness, −75 ≤ v ≤ 128, y and gfx y ≥ −8192) are premises of
  each move. Hframe_move must show the real frame lands in range
  (`docs/goal2-vel-y-bounds.md`).
- **Not modelled** (Hframe_move is false if these fire): hanging (A-gated), water, wind,
  shells, grab and throw objects, the cannon. All are absent or A-gated in WMotR (E1/E3,
  `docs/goal2-writers-vs-moves.md`).
- **Next:** discharge `Hact_whitelist` with GOAL 1's engine at `Qv := R_noA`, and make
  `R_noA` concrete from the census. Then start the `Hframe_move` value walk at
  `perform_air_step`. Make `WFloor` and `WPole` concrete from WMotR's collision and
  object data.
