# Rank 9A — Can a Goomba's dropped coin reach the gate?

## Answer

**No clean gate-side coin trajectory has been constructed, and the complete
glitch-assisted route is not disproved.** The final attack and coin flight
now have a stronger, Float32-aware height bound. They cannot by themselves
bridge the gap from the checked low Goomba locations, or even from the
previously audited conditional Spindel raising station. A useful route needs
an additional height-producing event, not just a favorable coin toss or more
paused updates.

“Gameplay” here includes glitches: airborne re-jumps, partial updates,
unusual floor choices, moving supports, retained motion and timing effects
remain legitimate subjects. This work does not construct ACE, out-of-bounds
corruption, arbitrary memory/code changes, or emulator vulnerabilities.

## What the finishing attack can do

The normal Goomba attack row selects knockback or squish. The knockback
setter assigns upward speed **50 for a kick/trip or fast attack**, and **30
for the other knockback case**. It replaces the old velocity rather than
adding to it. The vertical-knockback handler can kill the enemy upon contact
or when its timer reaches 9, so allowing it to reach its unrestricted apex
is already generous. Its dropped yellow coin then receives its own upward
launch of at least 50 and less than 60, rather than inheriting the Goomba's
remaining velocity.

The loot helper chooses a floor height or the Goomba's height; it does not
put the coin at Mario. The bound below separately grants a selected loot
floor up to 78 units above the enemy. Establishing that floor bound in a
specific live query is still necessary, particularly for unusual collision
results. No extra 78 units are silently granted on every later frame.

## The proved vertical branch

The Coq proof uses CompCert binary32 operations, including rounding after
each addition and the downward-speed clamp. It proves an integer upper
envelope for any starting Float32 position below the chosen ceiling, not
just an isolated toss starting at zero. The ordinary launch bound holds for
every finite random result in [0,1], a slightly larger range than the game's
16-bit random return actually supplies.

The branch permits any number of movement updates and pauses. It also
permits repeated support/bounce resets, provided the selected height is no
higher than the episode's starting ceiling and the resulting upward speed
stays within its envelope. Those are explicit projection requirements: a
higher floor or an airborne re-jump must be checked separately. The proof
also keeps the projected Y at or above -32768 and uses the non-water gravity
update. It is not an exhaustive classification of all reached game frames.

For the Goomba, we generously bound the real 50-or-30 launch by **52**, giving
up to **312** units of rise. The exact isolated 50-speed trajectory rises
288; the extra 24 units make the proof's bound more favorable to the route.
The coin is granted speed **60**, giving up to **420** units of rise. If `G`
is the ceiling on the Goomba's position at the finishing attack, this gives:

| Stage | Conservative upper height |
| --- | ---: |
| Goomba after the finishing attack | G + 312 |
| Coin spawn, including the separately granted floor lift | G + 390 |
| Coin during the checked flight/support branch | G + 810 |
| Mario's base at direct coin contact, using the ordinary 64-unit coin height | G + 874 |

The earlier gate calculation needs Mario's height **when the star samples
its home** in [3505,3715]. That is not automatically his height at coin
contact. For a contact already at least as high as 3505, the conservative
bound requires an integer attack-height ceiling of **at least 2631**. A lower
contact could still work if Mario moves high enough before the home sample;
that movement must be demonstrated, not assumed.

## Applying the bound without assuming an installer

| Granted attack-height ceiling | Coin ceiling | Direct-contact Mario ceiling | Extra Mario rise needed to reach a home sample of 3505 |
| --- | ---: | ---: | ---: |
| 640: high stock low-tier floor | 1450 | 1514 | 1991 |
| 1145: audited lower Grindel's maximum top | 1955 | 2019 | 1486 |
| 2517: conditional Spindel station after its last productive raising hit | 3327 | 3391 | 114 |

These are **conditional ceilings, not claims that the attack poses have
been reached**. An attack during an ordinary hop, a later reset of the
Goomba's jump, or another support can change the attack height. In
particular, the existing [Goomba-raising audit](goomba-raising.md) already
contains a conditional airborne raising cycle. Its required movement and
collision timing remain unconstructed; its existence prevents using a
single ordinary 66-unit hop as a universal Goomba-height limit.

The diagnostic checks both real finishing-attack launch values at five
integer heights, all 65,536 random return values at each resulting granted
spawn, and 120 moving coin updates with continued same-floor bouncing.
For the 2517 case, its greatest coin height is **3302.99658203125**, below
the conservative Coq ceiling of 3327. The diagnostic grants the unrestricted
enemy apex and continued coin bounciness, even when the real timer or coin
loop would stop them sooner. It does **not** simulate the pyramid's complete
collision mesh, controller movement, or a reachable random history.

## What still needs a clean execution

The missing installer is now narrower: get the Goomba higher before the
finishing attack; select a higher floor/support after the attack or during
coin flight; obtain a different defined movement update; or move Mario from
the lower coin contact to the required home-sampling height. Every candidate
still needs the right X/Z near the shaft, a reachable attack, the coin's
tangibility and lifetime, the 100-coin count, and the earlier/later single-use
star budget. An airborne re-jump is in scope, not a prohibited technique.

No controller movie, staged enemy placement, or clean-run receipt is claimed
by this tranche. The result closes the named bounded flight branch, not all
normal-gameplay glitches and not Rank 9A as a whole.

## Proof and reproduction

[Area2Rank9ACoinFlight.v](../../proofs/Area2Rank9ACoinFlight.v) checks the generated US/JP movement prefix and
finishing-attack velocity assignments, proves the all-random launch bound,
and inducts over the exact Float32 movement/pause/lower-support projection.
It reuses the existing source-linked launch and position-update work rather
than asserting that a source census is a controller execution. Its boundary
is consumed by `current_rank9a_coin_star_gate_boundary`.

Use the repository build wrapper for `check-rank9a`, and run
`node instrumentation/rank9a-coin-producers/check_flight.js` from the SSL
project. The latter is a read-only arithmetic diagnostic and never edits
game state.

Validated on 2026-09-05 using Coq 8.16.1 / CompCert 3.15. The active
`check-rank9a` target rebuilt the new module and main theorem, passed the
proof-hole and generated-link checks, and completed all twelve focused
assumption audits. The ultimate conditional theorem's assumption audit also
passed; no project-local axiom was added. Both coin diagnostics passed, as
did all 45 atlas anchors, the Rank-9A single-paragraph checks, local links and
whitespace checks. The older root discipline build still targets the missing
`sm64-proof` switch; this is an active SSL verification, not a claim that the
older root project builds.

[Back to Rank 9A](../no-a-route-atlas.md#route-rank-9a)
