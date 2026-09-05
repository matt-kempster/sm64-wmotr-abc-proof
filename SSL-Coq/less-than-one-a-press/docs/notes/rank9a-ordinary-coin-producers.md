# Rank 9A — Ordinary coins that could install the gate-side star

## Result

Follow-up: the [Goomba defeat/coin flight audit](rank9a-goomba-coin-flight.md)
now bounds all ordinary random launches with CompCert Float32 rounding,
arbitrary pauses and checked lower-support resets. The bounded flight branch
is too low even from the conditional Spindel raising station. A clean higher
installation or another gameplay-glitch height gain remains open.

**A defeated regular Goomba is the concrete mobile producer to investigate;
no clean gate-side installation has been found.** The other ordinary Area-2
coin layouts do not solve the placement problem: the 15 individual yellows,
23 possible formation children and three switched blue coins all start away
from the shaft. This is 41 coin **actors**, not 41 coin-value units. The fixed
layouts are checked more thoroughly now, but a complete live-memory
preservation proof for their positions is still separate. Collecting a remote
coin and moving Mario before the star samples its home is not excluded by
this position census either; it needs its own real movement/scheduling trace.

The tempting helper that creates a coin at Mario's position really exists.
It belongs to the small Whomp's on-ground interaction; it is not an ability
Mario can invoke while holding any pole. There is no stock Whomp in the
pyramid roster. The two Area-2 exclamation boxes contain walking 1-ups, not
coins. Eyerok's hand hitbox initializes zero loot coins, despite its death
helper having “spawn coins” in the name.

## Producers, in investigation order

| Producer | What the stock code offers | Placement verdict |
| --- | --- | --- |
| Regular Goomba defeat | Six individual Goombas and one three-Goomba spawner; one yellow loot coin per ordinary defeat, with a randomized upward toss | Actual mobile candidate; install the enemy/drop high enough, or find a useful ordinary support/collision schedule for the coin |
| Four coin formations | Two five-coin horizontal rows, an eight-coin ring, and a five-coin vertical row | None of the stock children is near the shaft; respawning uncollected children uses the same parent/recipe, not Mario's position |
| Blue switch | Three blue coins become visible and collectible at their existing positions | Visibility/tangibility changes do not supply a commanded relocation |
| Two exclamation boxes | Preset parameter 7 selects a walking 1-up | Not coin producers under the stock preset/contents tables |
| Whomp's “coin at Mario” helper | Stepping onto the grounded small Whomp can release a coin at Mario | Real elsewhere, but no stock Area-2 Whomp; a different area/lifetime history would need its own clean installation |
| Eyerok hand death | Explosion helper called with the hand's current loot count | The stock initialized count is zero; its name alone is not evidence of a mobile coin supply |

The Area-2 level-script roster and collision specials were also inspected in
the pinned decompile: the scripted objects are poles, Grindels, Spindel,
moving walls, elevator, sound loops, warps and star objects/controllers. The
four collision specials are an unused start record and three geometry
objects. They add no ordinary coin emitter. This source review is not an
exhaustive transitive live-call/lifetime theorem.

## Fixed formation locations

The generated preset table is decoded, including the yaw bits in each macro
record. A separate read-only diagnostic expands the stock recipes using the
generated sine table. US and JP give the same result:

| Formation | Children | Horizontal positions |
| --- | ---: | --- |
| Flying row at `(-2,1774,2794)` | 5 | X = -322, -162, -2, 158, 318; Z = 2794 |
| Flying ring at `(2694,850,-2889)` | 8 | X within [2394,2994], Z within [-3189,-2589] |
| Ground row at `(-210,4521,-994)` | 5 | X = -530, -370, -210, -50, 110; Z = -994 |
| Vertical row at `(290,4479,-940)` | 5 | X = 290, Z = -940; Y = 4479, 4607, 4735, 4863, 4991 |
| Switched blue coins | 3 | X = 0, Z = 2381; initial Y = 0, 100, 200 |

The ground row's listed parent Y is **not** its final selected floor height.
Its initialization can replace Y with the floor height; the horizontal
separation does not depend on that replacement. Some formation children may
already have been collected and therefore not respawn.

Coq proves that all four formation parents stay outside the test rectangle
`[-302,302] × [1029,1634]` even after **any offset of up to 640 units in each
horizontal direction**. The actual diagnostic offsets are smaller. The Coq
theorem deliberately exposes that offset assumption: executing the relative
transform and preserving the live parent/child positions are not silently
assumed proved. The direct X/Z-store census for the fixed-coin native bodies
also does not frame their callees or aliases automatically.

## The surviving Goomba coin

The regular Goomba hitbox initializes one loot coin, and its normal attack
row selects knockback or squish rather than the huge-Goomba blue-coin
handler. Punches and kicks therefore give a concrete ordinary way to trigger
this producer; getting the attack and enemy to the desired pose without A
remains a controller-history obligation.

The death helper requests yellow loot with base vertical speed 20 and zero
horizontal spawn jitter. The coin starts at its producer's X/Z; the helper
chooses its Y from a floor query or the producer's Y if the producer is more
than 100 units above that floor. It is **not** copied to Mario's position.
The loot counter is decremented, so the redundant second loot call in the
death helper is not evidence of an unlimited coin supply.

The moving-coin initializer sets vertical speed to `random*10 + 30 + base`,
forward speed to another `random*10`, and yaw from a third random call. For
the ordinary base of 20, the largest random return produces vertical speed
`59.999847412109375`; the smallest produces 50. The forward-speed range is
0 through `9.999847412109375`. These are separate random draws, not freely
selectable independent controller parameters.

The initializer makes the coin intangible. Its loop resolves walls/floors,
moves with normal coin physics, and makes it tangible when its resulting
vertical speed is negative. The behavior identity is changed to
`bhvYellowCoin`, **but the command script continues calling the moving
spawned-coin loop**. The identity rename does not turn this drop into a fixed
coin. Ground contact can bounce it, then ordinary on-ground handling removes
bounciness; the normal lifetime also expires after a wait/blink sequence.

The Float32 diagnostic exhausts all 65,536 random return values for an
**isolated toss starting at Y=0**. Its maximum rise is
`419.99786376953125`, and its first negative vertical speed occurs on movement
update 13–15. This is neither a controller sweep nor a global live height
bound: a different absolute Y changes rounding, and a live floor snap,
support, room/far-away partial update, bounce or scheduler delay changes the
trajectory. The existing Rank-11 Goomba movement envelope cannot simply be
reused as a theorem about the released coin.

## What Coq proves, and what it does not

[Area2Rank9ACoinProducers.v](../../proofs/Area2Rank9ACoinProducers.v) checks
the actual generated macro/preset records, fixed-loop direct-store census,
Whomp callsite, regular Goomba attack/loot data, box contents, Eyerok loot
initialization, yellow-loot wrapper and complete spawned-coin script bytes.
It reuses the checked nine-Goomba roster and proves the conservative
formation-separation implication. The callsite census exhausts the generated
behavior-actions translation unit; other units/indirect calls are not
silently included.

[Area2Rank9ACoinLaunch.v](../../proofs/Area2Rank9ACoinLaunch.v) resolves the
real coin initializer in both selected program environments. Its main
execution theorem begins immediately after the first random call: it reloads
`gCurrentObject`, reads that same coin's base velocity from raw index 34,
and writes the exact Float32 expression to its vertical-velocity cell at
raw index 10. Every disjoint memory read is preserved by this connected
fragment. At an object base it writes byte 176, not X/Y/Z bytes 160/164/168.
The random return, current-object identity, valid memory and prior spawn are
explicit entry conditions, not invented consequences of the theorem.

The active `current_rank9a_coin_star_gate_boundary` consumes both new
boundaries. Neither the Coq proofs nor the diagnostic derives a completed
zero-A route, a global coin-height ceiling, or a frame for an unexamined
outside call. No memory-modification method is developed.

## Next decisive test

Find an attack pose or subsequent support/movement event outside the new
bounded flight branch, or show that every reachable game update fits that
branch. Pausing alone does not add height; airborne Goomba re-jumps and higher
selected floors are still in scope. Then follow the same coin through its
first tangible contact and the 100-coin threshold to the star's home sample.
That sample must be in [3505,3715] for the checked ledge location; it is not
automatically the coin's spawn height or Mario's contact height. Preserve the
earlier climb and the single-use star budget. No clean installation or full
glitch-exhaustive impossibility result has been obtained.

## Verification

Validated on 2026-09-05 with Coq 8.16.1 / CompCert 3.15: both new modules and
the updated main theorem compiled under the bounded checker. `check-rank9a`
passed the proof-hole scan, generated-link hygiene check and all nine focused
assumption audits. The ultimate conditional theorem's assumption audit also
passed; no project-local axiom was added. The US/JP diagnostic, all 65,536
isolated launch cases, atlas anchors/paragraphs and local note links passed.

Run the active Coq target `check-rank9a` through the repository build wrapper,
and run `node instrumentation/rank9a-coin-producers/check_producers.js` from
the SSL project. The diagnostic uses only generated data and writes no game
or repository state. The older root discipline build still targets the
uninstalled `sm64-proof` switch; the active SSL checks use `sm64-item-proof`.

[Back to Rank 9A](../no-a-route-atlas.md#route-rank-9a)
