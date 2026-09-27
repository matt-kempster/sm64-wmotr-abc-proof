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
       └─ a no-A run keeps pos[1] ≤ 2744 < 2980          ← HeightFrame.v + HeightPhi.v
            └─ Mario's own frame preserves GOAL 1's invariant   ← GOAL 1 (frame_ok_linked12)
```

## What `HeightFrame.v` proves

One game frame = controller poll ∘ platform displacement ∘ **one real
`execute_mario_action` over any twelve-TU link** ∘ level phase ∘ objects. The
Mario segment's preservation of GOAL 1's invariant is the proved
`NoAImpliesNoFlyTwelve.frame_ok_linked12`, not an assumption. The composition is proved.

## What is still open

- `Hseg_action_phi` (the crux, T3): one real Mario frame preserves Φ
  (obligations: `docs/goal2-phi.md` §3).
- `R_noA`: the no-A action whitelist inside Φ, still a parameter.
- The four flank specs (TRUST.md 0.7) are labeled trust: that code isn't linked.
- The coin/star link at the top of the chain (TRUST.md 0.3).

Done: Φ is concrete (`HeightPhi.v`, `Phi_wmotr`: budget y + credit ≤ 2372 + 372 over
real MarioState fields, offsets and action ids pinned against the generated AST), and
`Hphi_y` is proved, so the bound is YMAX = 2744.

Staged (`Unwired/HeightBallistic.v`, not yet consumed): `ballistic_frame`, one real
no-collision air frame in binary32 does not raise y + bal(v). It is the ballistic arm of
the crux, and the reason Φ carries the rounding allowance EPS.

Prototypes still live in `playground/` (T1 PlatformInert, T2 FloatBrick, T3 ValueWalk).
