# `WMotRRequiresA/` — GOAL 2: WMotR cannot be done with 0 A presses

**Status: height form on the spine** (`HeightFrame.v`, capstone
`wmotr_noA_height_bound_linked12`). It is a conditional theorem whose open rows are named.

## The claim

> For every run that collects the WMotR (Wing Mario over the Rainbow) red-coin
> star, the input sequence contains at least one A press.

## The argument (strategy v2, `docs/goal2-strategy-v2-2026-07-01.md`)

```
star needs all 8 red coins → coin #2 (y = 3140) must be touched
  └─ touching needs pos[1] ≥ 3140 − 160 (hitbox)
       └─ a no-A run keeps pos[1] ≤ 2744 < 2980          ← HeightFrame.v + HeightInvariant.v
            └─ Mario's own frame preserves GOAL 1's invariant   ← GOAL 1 (frame_ok_linked12)
```

## What `HeightFrame.v` proves

One game frame = controller poll ∘ platform displacement ∘ **one real
`execute_mario_action` over any twelve-TU link** ∘ level phase ∘ objects. The
Mario segment's preservation of GOAL 1's invariant is the proved
`NoAImpliesNoFlyTwelve.frame_ok_linked12`, not an assumption. The composition is proved.

## What is still open

"One real Mario frame preserves Φ" is the lemma `seg_action_phi`. It rests on:

- `Hframe_stays_noA`: the frame keeps the action in `R_noA`. This is GOAL 1's engine at a
  new predicate. `R_noA` is still a parameter; the census is `docs/goal2-rnoa-census.md`.
- `Hframe_is_move_chain`: the real frame's effect on Φ's cells is a chain of `HeightMoveCatalog` moves.
  This is the T3 value walk.
- `wmotr_gap`, `wmotr_poles`: WMotR level data.

Also open:

- The four flank specs (TRUST.md 0.7) are labeled trust, because that code isn't linked.
- The coin/star link at the top of the chain (TRUST.md 0.3).

## Done

- **Φ is concrete** (`HeightInvariant.v`, `height_invariant`). It is the budget y + credit ≤ 2372 + 372,
  over real MarioState cells plus `gfx.pos[1]`, with offsets and action ids pinned against
  the generated AST.
- **`Hphi_y` is proved**, so YMAX = 2744.
- **`HeightMoveCatalog.v`** defines the moves a frame can make (air step, ceiling cut, slide-kick
  signed energy, ground-pound windup, E3 switches, attach, floor refresh, OOB). Its
  `chain_keeps_budget` proves the budget for each one in binary32, using `HeightFloatSteps.v`
  (float32 arithmetic) and `HeightBudgetArith.v` (real arithmetic).

Prototypes still live in `playground/` (T1 PlatformInert, T2 FloatBrick, T3 ValueWalk).
