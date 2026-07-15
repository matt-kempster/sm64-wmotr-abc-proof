# Working claim and exact scope

Last updated: 2026-07-14 (Mario/Area 2 route proof).

## Source and toolchain boundary

- Super Mario 64 North American source (`VERSION_US=1`).
- Canonical revision:
  `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
- Available sibling checkout:
  `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`; audited files must match the
  pin or are extracted directly from it.
- Coq 8.16.1, CompCert 3.15, PPC32 EABI big-endian.

Generated Clight shape facts and source audits pin syntax, constants, call
edges, and collision data. They are not a linked whole-program execution
refinement.

## Definitions

- **Hand height** is the hand object's origin Y. It is not the top of its
  collision and not Mario's Y.
- **Hand surface ceiling** adds the audited 507-unit maximum collision offset
  to a hand-origin ceiling.
- **Modeled Mario peak** adds a 630-unit triple-jump rise to the hand surface
  ceiling. This route model excludes caps and external boosts and is not an
  unrestricted original-game speed theorem.
- **Useful direct tier** means one of the audited Y=1280, 1967, 2940, 4429, or
  4815 floors, or direct star interaction. The route theorem identifies the
  highest admitted audited tier; it does not prove globally minimum star time.
- **Rises unboundedly** means that for every real/integer ceiling, some later
  frame has greater Y. Persistent positive velocity with a rounded, unchanged
  position is a different property.

## Refined vertical result

The old 1196/2003 origin bounds are superseded. They used Area 3's maximum
vertex Y=896, which includes non-floor walls, and rounded every finite impulse
to 300.

The refined relation uses upward-floor maximum 384 and exact finite ascent
maximum 288:

```text
FirstHand origin:        384 + 288 = 672
FirstHand surface:       672 + 507 = 1179
SecondHand origin:      1179 + 288 = 1467
SecondHand surface:     1467 + 507 = 1974
modeled Mario peak:     1974 + 630 = 2604
```

Rocq proves every reachable vertical-relation state stays below the applicable
origin ceiling and no infinite run of that relation is unbounded. Rank/update-
order correspondence and original binary32 observation remain refinement
obligations.

## Verdict on the three requested questions

### 1. Raised hand and Area 3 to Area 2

Proved in the explicit Mario/area relation:

- `HandSurface` cannot trigger the instant warp.
- `Area3Warp1D` changes to Area 2 and preserves Mario X/Y/Z, velocity, and
  airborne/grounded state.
- the matching Area 2 surface does not immediately invoke this entry rule.

The combined abstract relations admit this conditional trace:

```text
hand origin 1467 -> Mario base 1974
20 modeled long-jump frames -> warp at (192,2194,-1033)
zero-displacement Area 2 entry
12 modeled steering/fall frames -> land at (387,1967,-500)
```

This disproves "the formal finite bound is too low for any mid-level route."
It does **not** prove the original game can create the starting hand pose.
Therefore authentic raised-hand reachability remains undecided.

### 2. Are the finite bounds high enough?

For the refined relation and modeled Mario rise:

- Y=1967 is numerically and kinematically admitted by the conditional trace.
- Y=2940 first becomes floor-query eligible at Y=2862, above peak 2604.
- Y=4429 first becomes eligible at 4351.
- Y=4815 first becomes eligible at 4737.
- direct star interaction requires Mario base Y at least 4890.

Thus the bound is high enough for the conditional Y=1967 landing and too low
for every higher audited shortcut tier. `(387,1967,-500)` is proved to minimize
horizontal distance to the star over that platform, at distance 113, but it is
2923 units below the star's vertical interaction band.

### 3. Unqualified original-game indefinite ascent

Already proved: no run of the handwritten integer vertical relation is
unbounded.

Not yet claimed at this commit: the final finite-binary32 theorem and an
original-ROM semantic refinement. The isolated binary32 `+100` operation is
known to stagnate at `2^31`, but that fact must be checked in Rocq and stated
without confusing CompCert's stuck out-of-range cast with original MIPS
behavior.

## C abstraction boundary

`inputs/eyerok_model.c` is an executable interface model. Its public functions
do not enforce the same preconditions as the handwritten relation; an
unrestricted caller can request new impulses from unsafe heights. Its safety
predicate reports the violation. No theorem treats arbitrary calls to that C
API as original gameplay.

## Open authentic obligations

- Link the generated translation units and define a complete original frame.
- Couple boss controller, both hands, list order, dynamic collision, Mario,
  time stop, and floor-pointer lifetime.
- Prove the first/second rank abstraction and the 78-unit floor-query cases.
- Prove or refute reachability of the Y=1467 hand origin at the route's X/Z.
- Prove the exact controller/action trace for any claimed Area 2 landing.
- Add an IDO/MIPS boundary if the claim is about the original ROM rather than
  CompCert Clight source semantics.

No project-added `Admitted`, `Axiom`, `admit`, `sorry`, or equivalent proof
hole may occur in a capstone.
