# `WMotRRequiresA/` — GOAL 2 (the grand prize): WMotR cannot be done with 0 A presses

**Status: not started.** No Coq here yet — this directory marks the *eventual*
target and what must be proved to reach it. Goal 1 (`../NoAImpliesNoFly/`) lands
first; this goal builds on it.

## The claim

The **Wing Mario over the Rainbow** star cannot be collected without pressing the
A button — a formal A-Button-Challenge (ABC) impossibility result for this one
SM64 star:

> For every run that collects the WMotR star, the input sequence contains at
> least one A press.

## The argument chain (from `docs/ROADMAP.md`)

```
WMotR star collected  (with 0 A presses)                       ← to refute
  └─ requires all 8 red coins → spawns bhvHiddenRedCoinStar    (level fact)
       └─ the high red coins require altitude
            └─ that altitude requires ACT_FLYING (wing-cap flight)
                 └─ entering ACT_FLYING requires an A press     ← GOAL 1 (../NoAImpliesNoFly/)
  ∴ collecting WMotR requires an A press.
```

GOAL 1 supplies the bottom limb (`noA_no_spawn_never_flying`). This goal must
formalize the upper limbs and compose them.

## What belongs here (the work, roughly bottom-up)

- **Altitude ⇒ ACT_FLYING.** A no-A run never enters `ACT_FLYING` (GOAL 1) ⇒ never
  gains wing-cap altitude. Needs a link from "not flying" to a height/position bound.
- **High red coins ⇒ altitude.** The 8th/high red coins sit above the
  reachable-without-flight ceiling (level-geometry fact about the WMotR area).
- **Star ⇒ 8 red coins.** `bhvHiddenRedCoinStar` only spawns once all 8 are
  collected (behavior/level fact).
- **Composition.** Chain the above with GOAL 1 into the capstone
  `wmotr_requires_A` (state it here when GOAL 1 is solid).

Drop proved-but-not-yet-wired pieces into `Unwired/` (mirrors GOAL 1's layout).

See also: `docs/must-press-a-to-fly.md`, `docs/wmotr-argument-shape` (memory),
`docs/ROADMAP.md`.
