# Rank 12: Area-2 object-impulse audit

## Result

The homing-Amp shock plus an ordinary wall or moving support does not provide the missing no-A dismount from the second pole.  This conclusion grants the difficult part—an Amp arriving at the pole top—and checks the payoff from the exact seed.  Shock removes all sideways speed.  Contrary to the earlier note, it does not then hover indefinitely: the air step applies gravity after its four collision quarters, so Mario is motionless only on the first shocked frame, falls vertically through the central aperture, and lands on the ordinary floor at Y `3200`.  The nearby static walls are outside the wall-query radius, every stock moving collision owner is outside the pole corridor, and the cached-platform update has already cleared any remembered owner.  A stale, forged, or relocated support is a different route premise, not a surviving ordinary Amp composite.

This closes the specifically proposed “stationary shocked stall plus a wall or moving support” in the finite stock source model.  Rank 12 is not retired universally: a low-tier Goomba would still need a real transport to the pole, and a linked execution could still matter if it falsifies one of the checked stock corridor, owner, or collision premises.

## Why the Amp was the best actor to check

The selected US and JP Area-2 data contain exactly two homing Amps, at `(1621, 3368, -1142)` and `(1621, 3389, 478)`, and one circling Amp at `(3056, 736, -3267)`.  The second homing Amp begins about `1831.74` horizontal units from the second pole, and its chase-plus-give-up distance budget is large enough that distance alone does not disprove a lure.  The proof therefore grants perfect installation instead of hiding behind unproved controller timing, height alignment, wall avoidance, or object-loading claims.

The same roster contains no cannon, shell source, Tweester, Heave-Ho, Chuckya, Fly Guy, or jumping box.  The scripted moving collision owners are three Grindels, Spindel, four pyramid walls, and the elevator.  Ordinary Goombas exist only on lower tiers and remain a separate transport proposal.

## Exact shock chain

1. The Amp has an `INTERACT_SHOCK` hitbox with radius `40` and height `50`.
2. `interact_shock` selects `ACT_SHOCKED` outside water and does not call the object-push routine.
3. A pole action makes the interaction argument zero, selecting the airborne shocked branch.
4. That branch calls `mario_set_forward_vel(m, 0.0f)` before `perform_air_step(m, 1)`.
5. The setter writes forward speed and both horizontal velocity components but leaves vertical velocity alone.
6. `perform_air_step` performs four quarter steps, then calls `apply_gravity`; the ordinary shocked case subtracts `4` per frame down to terminal speed `-75`.

Starting at the exact pole-top sample `(0,4020,1331)` with zero velocity, the first shocked update leaves Y at `4020` and changes vertical speed to `-4`.  After 19 updates the state is Y `3336`, speed `-75`; after 20 it is Y `3261`; on update 21 the last collision quarter crosses the static Y-`3200` platform and lands there.  Horizontal position remains `(0,1331)` throughout.  These values are exact binary32 integers, not rounded decimal estimates.

## Why no stock wall or moving support catches the fall

Both air-quarter wall searches use radius `50`.  From the pole centre, the four inner aperture planes are `101`, `102`, `102`, and `103` units away, so the zero-horizontal fall never queries one.  Their checked vertical band is Y `3712..3942`; Mario passes through it without a horizontal response.

The generated local collision bounds are also checked bilaterally: Grindel X/Z is `-224..224`, Spindel X is `-306..307`, moving-wall Z is `-306..307`, and elevator Z is `-511..512`.  Applying the stock homes and the axis preserved by each behavior gives disjoint world corridors: regular Grindel X `3073..3521`, upper horizontal Grindel X `-1094..-646`, lower horizontal Grindel X `-3586..-3138`, Spindel X `-2764..-2151`, pyramid-wall Z `-2613..-2000`, and elevator Z `-255..768`.  The pole query disc is X `-50..50`, Z `1281..1381`; none intersects it.  The nearest named envelope is the elevator, still at least `513` units beyond the query disc in Z.

Platform carry cannot secretly repair that gap.  The stock scheduler applies remembered-platform displacement before Mario and recomputes the platform afterward.  At the pole top the static floor is Y `3200`, so the `update_mario_platform` less-than-`4` test sees an `820`-unit gap and clears both cached platform pointers.  Every subsequent airborne sample remains more than `4` units above that floor; the eventual landing floor is one of the two checked static triangles, so it has no moving owner to cache.

## Scope and remaining work

The closure is deliberately source-shaped.  It combines generated collision arrays, exact static triangle records, bilateral call-order receipts, the stock scheduler, and the finite owner-corridor model.  A completely linked Clight execution from a real Amp lure would strengthen the result by proving that each runtime object realizes the corresponding decoded home, yaw, owner, and list entry.  If such a run violates a corridor premise, that first wrong position, owner, or surface is a concrete new producer.  Runtime table mutation, stale or forged owners, out-of-bounds writes, ACE, and continuation after undefined behavior remain outside the successful in-bounds CompCert model.

The remaining ordinary Rank-12 idea is therefore not “Amp shock waits for a platform.”  It is either a concrete low-tier Goomba transport with a useful later collision, or a demonstrated failure of the stock runtime-owner projection.  Both are now narrower and independently testable.

## Formal artifact

[`Area2Rank12ObjectImpulse.v`](../../proofs/Area2Rank12ObjectImpulse.v) checks the roster, exact Amp interaction, zero horizontal payoff, gravity/collision call chain, 21-update fall, aperture-wall clearance, four moving-mesh bounds, six world-corridor exclusions, static base floor, scheduler order, and cached-platform clearing.  `area2_rank12_shock_composite_closure_holds` exposes the finite stock closure, while `Area2Rank12ObjectImpulseBoundary` remains available as the weaker direct-impulse result.
