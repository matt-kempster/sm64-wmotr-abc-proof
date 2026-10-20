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
       └─ a no-A run keeps pos[1] ≤ 2796 < 2980          ← HeightFrame.v + HeightInvariant.v
            └─ Mario's own frame preserves GOAL 1's invariant   ← GOAL 1 (frame_ok_linked12)
```

## What `HeightFrame.v` proves

One game frame = controller poll ∘ platform displacement ∘ **one real
`execute_mario_action` over any twelve-TU link** ∘ level phase ∘ objects. The
Mario segment's preservation of GOAL 1's invariant is the proved
`NoAImpliesNoFlyTwelve.frame_ok_linked12`, not an assumption. The composition is proved.

## What is still open

"One real Mario frame preserves Φ" is the lemma `seg_action_phi`. It rests on:

- `Hseg_call` / `Hseg_any`: one row per call in `execute_mario_action`'s real body
  (`FrameSplit.v`; the call list is computed from the generated AST by `FrameCalls.cl`).
  Each says the call keeps the frame world (action in `R_noA`, W, the anim and
  Mario-object layout facts, A not held) and moves Φ's cells by a `HeightMoveCatalog`
  chain. The body's two stores to Mario's object are proved, and the old whole-frame
  rows `Hframe_stays_noA` / `Hframe_keeps_world` / `Hframe_is_move_chain` are lemmas
  derived from these (`FrameSplit.frame_split`). The airborne dispatcher's row is proved too
  (`AirSplit.air_seg`): it splits into its two prologue calls and one row per no-A
  case, with the action cell equal to the case label (`Hair_pro` / `Hair_case`). The value walk discharges them call
  by call; the airborne dispatcher's freefall case is `Unwired/FfRun.ff_move`.
- `wmotr_gap`, `wmotr_poles`: WMotR level data, **proved** in `WMotRLevel.v` (`wmotr_gap_proved`, `wmotr_poles_proved`).

Also open:

- The four flank specs (TRUST.md 0.7) are labeled trust, because that code isn't linked.
- The coin/star link at the top of the chain (TRUST.md 0.3).

## Done

- **Φ is concrete** (`HeightInvariant.v`, `height_invariant`). It is the budget y + credit ≤ 2424 + 372,
  over real MarioState cells plus `gfx.pos[1]`, with offsets and action ids pinned against
  the generated AST.
- **`Hphi_y` is proved**, so YMAX = 2796.
- **Level data is generated and the rows are proved** (`WMotRLevel.v`): `wmotr_floor` and `wmotr_pole` are
  decoded from clightgen'd terrain, macro objects and level script; the gap fact and the pole row are
  `vm_compute` checks. It found that exclamation boxes are scaled ×2 (K 2372 → 2424).
- **`HeightMoveCatalog.v`** defines the moves a frame can make (air step, ceiling cut, slide-kick
  signed energy, ground-pound windup, E3 switches, attach, floor refresh, OOB). Its
  `chain_keeps_budget` proves the budget for each one in binary32, using `HeightFloatSteps.v`
  (float32 arithmetic) and `HeightBudgetArith.v` (real arithmetic).

Prototypes still live in `playground/` (T1 PlatformInert, T2 FloatBrick, T3 ValueWalk).
