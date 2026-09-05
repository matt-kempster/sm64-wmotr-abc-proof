# Rank 9 — Upper Act-3 star-dance continuation

## Result

**Open, with a concrete ledge-and-landing target instead of only a transcript
description.** An offline test of the complete static pyramid mesh finds a
rear-wall catch onto the Act-3 platform. At one fixed horizontal position and
downward speed, 50 integer starting heights succeed. The following update
lands on the caught platform. Coq separately executes the real operations
that record the caught floor and the caller's decision to retain a ledge
result. Neither result is a controller-reachable upper continuation.

This is Rank **9**, not the Rank-9A proposal to spend the 100-coin star at the
elevator or second pole. Rank 9 assumes an earlier successful upper-gate
crossing and asks how to finish Act 3. It does not supply that crossing.
The work uses ordinary source logic and in-bounds gameplay-glitch arithmetic;
it does not modify game memory or run an emulator.

## Why the rear wall matters

The Act-3 platform has a raised rim along only part of its western edge.
The new candidate uses the wall at X=387, behind that rim at Z=-850. This
allows the lower wall sample to touch the platform while the upper sample
passes above the wall. The ledge routine then looks 60 units through the
wall and finds the flat platform at Y=4815.

All values below are from the checked static diagnostic, starting in the
falling-star action with horizontal speed zero and vertical speed -50.
The starting action, position, speed, and absence of relevant dynamic
surfaces are **granted inputs**, not a recorded game state.

| Point | Position or result |
| --- | --- |
| Before the ordinary geometry-input wall checks | `(340,4700,-850)` |
| After those two checks | `(337,4700,-850)`; first check selects wall 680 |
| Intended first air quarter | `(337,4687.5,-850)` |
| Upper and lower action wall queries | no upper wall; lower wall 680, with no further push |
| Ordinary floor and ceiling | floor 1406 at 4429; ceiling 99 at 5222 |
| Ledge-floor query | `(397,4847.5,-850)` selects floor 1400 at 4815 |
| Successful ledge result | `(397,4815,-850)`, a 127.5-unit rise from the quarter sample |
| Next geometry-input checks | position unchanged; floor 1400 retained |
| Next air quarter | intended Y `4801.7001953125`; lands at 4815 |

Triangle numbers are source-order labels, not live memory addresses.
The wall's exact generated vertices are `(387,4687,-409)`,
`(387,4815,-1125)`, `(387,4687,-1125)`. Floor 1400 is
`(387,4815,-409)`, `(643,4815,-1125)`, `(387,4815,-1125)`.
The destination is strictly inside that floor's horizontal projection.

The diagnostic includes the geometry-input wall checks that occur before
Mario's action, both action wall queries, the ordinary floor, the ceiling
query at **floor height + 80**, the ledge lookup at **quarter Y + 160**,
and the following landing. It preserves source insertion order for walls
and the first-vertex height sorting for floors and ceilings. It does not
replace that sorting with a highest-geometric-floor oracle.

## The finite height window

For fixed initial X/Z=`(340,-850)` and velocity `(0,-50,0)`, the diagnostic
tests all 201 integer initial heights from 4600 through 4800. Exactly
**4678 through 4727**, inclusive, catch the ledge; all 50 then land on the
same platform. Coq checks the same finite interval against the exact
Float32 height inequalities. It is not an exhaustive controller search,
and no claim is made that those are the endpoints for every fractional
height, horizontal position, speed, or live list.

The lower bound comes from putting the upper wall sample above Y=4815.
The upper bound comes from the ledge routine requiring a rise **strictly
greater than 100**, not merely a positive rise. The floor lookup's 78-unit
allowance and the ceiling test also pass. Disabling the ledge flag rejects
the sample, so an ordinary falling ground pound is not interchangeable
with falling after a star pickup.

## A nearby ordinary coin candidate

The stock vertical coin row is at `(290,4479,-940)`. Its second child is
128 units higher, at `(290,4607,-940)`. The generated macro/preset census
identifies this row; the new Coq receipt checks the yellow-coin hitbox and
the actual vertical-offset expression, including its double-to-integer
conversion for child index one.

With standard hitboxes, Mario at `(340,4600,-850)` overlaps that coin.
If the star subsequently samples Mario at this same position, the existing
settled-star arithmetic places it at Y=4845, where Mario at Y=4700 can touch
it. These are **compatible conditional samples**, not a completed
installation. Coin contact does not force the later home-position sample
to occur at the same pose, and there is no proved trajectory from the
coin sample to the falling-star entry.

This candidate avoids needing a transported Goomba coin just to identify a
local resource. It still requires reaching the coin with exactly 99 coins,
preserving its uncollected child, the actual star spawn/home/tangibility
sequence, and arranging the first star contact late enough. A star collected
too early stops the intended movement before the useful ledge window.
The same reward cannot also be spent at an earlier Rank-9A gate.

## What Coq proves

The new [module](../../proofs/Area2Rank9UpperStarDance.v) uses the real US/JP
generated bodies already resolved in the selected programs by
`Area2Rank9AStarSource.v`. Its main execution results are:

- `rank9_fall_enables_the_ledge_check`: the actual falling-star call passes
  air-step argument one, enabling the ledge check.
- `rank9_ledge_commits_same_floor_and_height`: after the position-copy call,
  the actual two load/store pairs take the returned local floor pointer and
  height and record both in MarioState. Their execution preserves the
  action, position, and velocity cells. The writable destinations and
  separate local-height storage are explicit memory premises.
- `rank9_ledge_result_smallsteps`: at the actual post-air-step decision,
  result three skips the landing branch with unchanged memory. It does not
  turn the result into an ordinary hanging action or overwrite the snap.
  The later animation call is **not** covered by this fragment's frame.
- `rank9_wall_and_destination_are_generated`,
  `rank9_fifty_integral_height_samples`, and `rank9_sample_exact_snap`:
  exact generated vertices, a floor-interior destination, the finite
  Float32 height window, and the representative snap arithmetic.
- `rank9_coin_descriptor_and_offset_are_generated` and
  `rank9_nearby_coin_and_star_vertical_window`: the nearby coin's source
  recipe and the conditional contact/settled-height arithmetic above.

`MainTheorem.v` consumes the memory execution and geometry package as
`current_rank9_upper_star_dance_boundary`. This sharpens the transcript's
unresolved ledge stage into exact source program points, memory loads and
stores, wall/floor identities, and test poses. It does **not** construct
`UpperTranscriptAct3ContinuationObligation` or discharge the global
upper-entrance reachability premise.

## What still closes the route

Construct one continuous, zero-new-A continuation from a useful upper-cut
state through the nearby coin, spawned star, stored-speed reactivation,
ground-pound timing, and first star contact. Then realize the diagnostic's
wall/list/floor/ceiling choices in live memory, including any moving geometry,
and connect the position copy, angle calculations, animation, gravity, next
landing, and standing dance. A rollout cannot request a ground pound directly:
the proposed conservation/reactivation must genuinely reach an action that
accepts Z. Adding separate maximum rises is not a substitute for that action
history.

Finally execute a useful departure on the platform and collect Act 3, with
the correct save-bit update. Standing on its flat floor still misses by 75
units; the separate Rank-12B rim-contact sample is another possible final
approach, not a proved continuation from this catch. This tranche does not
change the Act-6 obligations or authenticate an upper-route input movie.

## Reproduction and trust boundary

From the repository root, use the installed proof switch and wrappers:

```sh
SM64_PROOF_SWITCH=sm64-item-proof bash pipeline/build.sh \
  -C SSL-Coq/less-than-one-a-press check-rank9
```

From the SSL project directory:

```sh
node instrumentation/rank9-upper-star-dance/check.js
```

The diagnostic reads pinned decompile revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af` and all 1080 vertices/1558 triangles.
Its software Float32 collision reconstruction is diagnostic evidence, not a
verified translation: in particular `sqrtf` is represented by `Math.sqrt`
followed by Float32 rounding. Actual surface allocation, transformed dynamic
lists, live ownership, and query execution remain outside that receipt.

Validation on 2026-09-05: the new module and integrated `MainTheorem.v`
compiled with Coq 8.16.1 / CompCert 3.15. The no-hole and link-hygiene checks,
all eleven focused/boundary/overall assumption audits, the offline collision
regressions, and atlas paragraph/link checks passed. The mesh's Git blob
hash matches the pinned revision (`2a960a73bf6422241927cf5e6647b7b102d79236`).
WSL interrupted the combined target during its audits, so the audits were
completed individually, with unchanged-command retries after service exits;
this is not a claim that one uninterrupted `check-rank9` invocation passed.
The repository-wide discipline audit still cannot build the legacy root
project because its `sm64-proof` switch is absent; the active SSL validation
uses the installed `sm64-item-proof` switch. No project-local axiom was added.

[Back to Rank 9](../no-a-route-atlas.md#route-rank-9)
