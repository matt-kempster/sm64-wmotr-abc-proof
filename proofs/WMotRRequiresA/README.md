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
       └─ a no-A run keeps pos[1] ≤ YMAX = H* + Δ_pot < 2980   ← HeightFrame.v
            └─ Mario's own frame preserves GOAL 1's invariant   ← GOAL 1 (frame_ok_linked12)
```

## What `HeightFrame.v` proves

One game frame = controller poll ∘ platform displacement ∘ **one real
`execute_mario_action` over any twelve-TU link** ∘ level phase ∘ objects. The
Mario segment's preservation of GOAL 1's invariant is the proved
`NoAImpliesNoFlyTwelve.frame_ok_linked12`, not an assumption. The composition is proved.

## What is still open

- `Phi`: the height invariant. It is a **parameter** until T3 defines it (strategy v2's Φ over
  Pot = y + ballistic(vel[1]) + windup).
- `Hseg_action_phi` (the crux, T3): one real Mario frame preserves Φ.
- `Hphi_y`: Φ ⇒ y ≤ YMAX. This is immediate once Φ is defined.
- The four flank specs (TRUST.md 0.7) are labeled trust: that code isn't linked.
- The value of YMAX and the coin/star link at the top of the chain (TRUST.md 0.3).

Prototypes still live in `playground/` (T1 PlatformInert, T2 FloatBrick, T3 ValueWalk).
