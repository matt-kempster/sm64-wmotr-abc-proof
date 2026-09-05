# Rank 10A: ground-pound startup and moving geometry

## Result

**Open, but no longer an untested height idea.** A granted ground-pound
startup over a steadily descending elevator has a real height window:
Mario can end 260 units above its floor, exceeding the checked 231-unit
lower-wall-query cutoff. This is not a clean entry, sideways crossing or
star collection. Startup stops sideways speed, and the earlier wall/floor
queries still run. The simplest entry proposal also fails: following a floor
that descends ten units cannot create the more-than-100-unit gap that turns
grounded motion into freefall.

This work concerns ordinary gameplay, including glitches. It uses source
inspection, Coq and offline arithmetic. There were no game-state edits and
no new emulator run or controller-input route in this tranche.

## Source and proof

The [Coq module](../../proofs/Area2Rank10AGroundPound.v) resolves five real
bodies in both selected programs: ground pound, freefall, the speed setter,
the geometry-input update and the elevator. Its startup-prefix receipt
couples the actual timer calculation, headroom comparison, Mario Y store,
downward-speed assignment and zero-speed call. It executes the actual
post-headroom Y-store fragment in selected Clight memory and proves that
this store preserves Mario's X and Z cells. This is a local execution,
not a complete frame or a proof that the entry is reachable.

The ten attempted lifts are `20,18,16,14,12,10,8,6,4,2`. Each requires the
rounded `Y + lift + 160` to be strictly below the queried ceiling. Coq permits
every pass/fail pattern and bounds actual binary32 height by the integer
entry ceiling plus 110, including finite fractional starting heights in the
documented ordinary-coordinate range. It does not assume translation-invariant
rounding. Restarting the action or adding a support displacement, collision
correction or other position effect requires a new accounting; those steps
are not part of this non-wrapping, startup-only recurrence.

The 110-unit gain is exact for the integer-aligned timing test below. For a
fractional entry the theorem uses its integer upper bound: it does not claim
an exact 110-unit gain from every fractional starting value. The diagnostic
includes the rounding control `4095.999755859375 -> 4206`, whose gain is very
slightly larger than 110 but still obeys the proved ceiling-plus-110 bound.

## The elevator-relative window

The normal animation descriptor has `loopEnd = 11`. The action advances to
falling when its incremented timer reaches `loopEnd + 4`: fifteen startup
updates, not just the ten that raise Mario. The flying-entry descriptor has
`loopEnd = 16`, giving twenty updates, but ordinary freefall requests argument
zero and cannot select that longer variant simply by waiting. The
[offline checker](../../instrumentation/rank10a-ground-pound/check.js) verifies
both pinned asset descriptors. Their **live loading and persistence are not
proved by the Clight theorem**; the finite timing scenario supplies the
normal duration.

Grant both positions at Y=4966 immediately before the first modeled terrain
update, ten units of elevator descent before every Mario update, full
headroom and no other position effect. The exact Float32 results are:

| Point in this granted scenario | Mario's rise | Elevator descent | Relative height |
|---|---:|---:|---:|
| After startup update 10 | 110 | 100 | 210 |
| After update 12 | 110 | 120 | 230 |
| After update 13 | 110 | 130 | 240 |
| After update 15 | 110 | 150 | 260 |
| First falling update, quarters 1–4 | decreasing | 160 | 257.5, 245, 232.5, 220 |

The last row grants continuation through the four air-step quarters; real
collisions may stop them earlier. Both absolute-world and relative Float32
calculations are checked. The table does not authenticate a ground-pound
state at Y=4966: that entry is deliberately being granted for the test.
The cutoff measures a wall query, not a sufficient rim landing or star
collection condition.

## Why height alone is insufficient

Startup sets vertical speed to -50 and calls the normal speed setter with
zero. The source multiplication receipt and finite-Float32 theorem show that
negative sine/cosine values yield signed zero, not hidden sideways speed.
The startup branch has no ordinary air step, action setter or B/Z cancel.
The falling branch also omits ordinary stick-controlled air steering. Its
air-step argument is zero, disabling the optional ledge-grab and ceiling-hang
checks.

Skipping that action-level air step is **not collision immunity**. The earlier
geometry-input update still performs two wall queries and then a floor query
before its first branch. Moving geometry may matter through those queries,
the platform update, an interaction or resumed falling collisions. The
Y-store's X/Z frame does not cover those other operations or the startup's
sound/animation/copy calls. A falling ground pound can also change to backward
air knockback after a wall hit. That collision-dependent departure remains
to be tested; it is not a B/Z cancel and is not silently excluded.

## Entry restrictions

The generated airborne-source census has twelve direct requesters: jump,
double jump, triple jump, backflip, freefall, held-object jump, held-object
freefall, side flip, wall kick, flying, flying triple jump and special triple
jump. The automatic-action census adds start-hanging, hanging and moving on
a hanging ceiling. These are callsite facts, not proof of useful no-A entry.

Forward/backward rollout, jump-kick, dive and the initial upper-entry fall
have no direct ground-pound request. Finishing a rollout animation changes
its substate, not its action to ordinary freefall. Neither Z at the rollout
apex nor adding 110 to the rollout maximum constructs a composite. Ordinary
freefall accepts Z, with B taking priority if both inputs are present.

For every one-unit height bin in the ordinary range, Coq proves the actual
Float32 `Y > (Y + (-10)) + 100` test false, including fractional Y. If the
real query keeps returning the intact elevator base and grounded movement
reanchors every frame, descent alone cannot produce `OFF_FLOOR`. Different
floors, skipped reanchors, outside pushes and already-airborne predecessors
are different cases, not excluded gameplay glitches. The start/stop jolts
and transformed-surface rounding still need their own live projection if
used in an entry.

## Remaining useful searches

1. Find a controller-reachable eligible predecessor at the actual gate.
   Identify the first genuine freefall or other cancellable action instead
   of supplying a ground-pound state.
2. Pair startup with one real sideways effect: a moving wall, a selected
   rotating/translating support, an interaction, or a precise falling-wall
   response. Fix its order relative to the pre-action queries.
3. Follow every query, interruption, landing and star suffix in one run.
   A hanging version must establish the hangable ceiling and an allowed
   held-A history, not a fresh A edge.

Other Area-2 movers remain separate: the vertically cycling Grindel, rolling
Spindel, horizontal Grindels and moving walls do not obey the elevator's
pure-vertical, same-floor model. Their displacement, support choice and
contact timing need checking. A stationary support gives no descent bonus,
and a frozen elevator cannot be credited with movement on skipped updates.

Rank 10A therefore remains **low promise**. There is a genuine conditional
height window, but no clean eligible entry plus useful departure. Search
for those missing operations rather than repeating the height arithmetic.

## Reproduction

Run `node instrumentation/rank10a-ground-pound/check.js` from the active SSL
project. It checks both descriptors, all 1,024 normal-startup headroom masks,
absolute-world falling samples, signed-zero controls and 128,004 numeric
floor-following samples. These diagnostics supplement the Coq induction and
selected-source/store proofs. `check-rank10a` rebuilds the imported capstone
and audits its focused theorem assumptions.

Validation passed: the bounded module compile, integrated SSL build, no-hole
and link-hygiene checks, all twelve focused/capstone assumption audits, and
the offline diagnostic. The atlas retains all 45 navigation anchors and
single-paragraph Rank 10A sections. The repository-wide discipline script
still reports its pre-existing missing `sm64-proof` switch; these successful
checks use the active SSL `sm64-item-proof` toolchain, not that broken setting.

Primary source is pinned SM64 revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af`:
`src/game/mario_actions_airborne.c`, `mario_actions_automatic.c`,
`mario_actions_cutscene.c`, `mario.c`, `mario_step.c`,
`behaviors/pyramid_elevator.inc.c`, and
`assets/anims/anim_3C_3D.inc.c` / `anim_3B.inc.c`.
The generated action counterparts are `generated/us_*` and `generated/jp_*`.

[Back to Rank 10A](../no-a-route-atlas.md#route-rank-10a)
