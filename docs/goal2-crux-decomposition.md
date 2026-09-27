# GOAL 2: decomposing the crux row `Hseg_action_phi` (design, 2026-09-27)

Design only, nothing built yet. It is based on `HeightFrame.v`, `HeightPhi.v`,
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
