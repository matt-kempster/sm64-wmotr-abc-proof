# Rank 12: Area-2 object-impulse audit

## Result

The homing Amp does not provide the missing no-A dismount from the second pole.  This remains true even if a future controller search succeeds in luring an Amp all the way to Mario at the pole top.  Grabbing the pole has already set Mario's forward speed to zero, the Amp's interaction has no push operation, and the shocked action again sets Mario's forward speed and both horizontal velocity components to zero before running the air-collision step.  In plain language, the shock can knock Mario out of the pole action, but it supplies none of the sideways motion needed to reach the surrounding ring.  Because pole acquisition also set vertical velocity to zero and the shocked branch does not itself apply gravity, the exact seed may stall over the aperture rather than fall; that makes timing/support composites worth testing, but it does not create a crossing by itself.

This is meaningful progress rather than a complete retirement of Rank 12.  A shock could still alter timing or collision state, and an independently useful wall response, support switch, platform carry, or already-crossing trajectory could compose with it.  Those are now the exact survivors; “the Amp pushes Mario across” is not one of them.

## Why the Amp was the best actor to check

The selected US and JP Area-2 data contain exactly two homing Amps, at `(1621, 3368, -1142)` and `(1621, 3389, 478)`, and one circling Amp at `(3056, 736, -3267)`.  The second homing Amp begins only about `1831.74` horizontal units from the second pole at `(0, 3200, 1331)`, and its behavior does not simply stop at the nominal `1500`-unit leash: after giving up, it can continue at speed `15` for 151 favorable updates before resetting.  The proof deliberately grants the resulting distance budget rather than assuming installation is impossible.  Exact vertical alignment, wall avoidance, object loading, and controller timing for that lure are not claimed.

The same roster audit substantially narrows the alternatives.  Area 2 has no cannon, shell source, Tweester, Heave-Ho, Chuckya, Fly Guy, or jumping-box preset, and its scripted actors are exactly the two poles, three Grindels, Spindel, four moving pyramid walls, the elevator, sound loops, and stars.  Ordinary Goombas are present, but their recorded starts are on the low tiers rather than at the pole-top ring; transporting one to the pole remains a separate transitive-object proposal, not a stock actor already waiting there.

## Exact shock chain

The checked source chain is the same in US and JP:

1. The Amp installs an `INTERACT_SHOCK` hitbox with radius `40` and height `50`.
2. `interact_shock` records the interaction and selects `ACT_SHOCKED` outside water.  It never calls the routine that physically pushes Mario out of an object.
3. Because a pole action has the on-pole flag, the shocked action takes its airborne branch.
4. That branch calls `mario_set_forward_vel(m, 0.0f)` before `perform_air_step(m, 1)`.
5. The setter writes `forwardVel`, `slideVelX`, `slideVelZ`, `vel[0]`, and `vel[2]`; it does not overwrite `vel[1]`.

The last detail explains both the exclusion and the residual.  The velocity setter does not itself overwrite the vertical component, but it erases direct horizontal travel.  At the pole-top seed the inherited vertical component is also zero, so the no-gravity shocked branch may become a stationary stall unless a collision or support changes the situation.  The checked target ring begins 101 units horizontally from the pole centre.  The formal arithmetic therefore grants any number of shocked frames and still computes zero direct horizontal displacement.  A useful result would have to be credited to collision or support geometry, not to an Amp impulse.

## What remains worth testing

The next Rank-12 test should be a named composite, with a frame-by-frame owner and collision receipt: place the Amp at the pole, trigger shock at a specified animation/collision phase, and show a particular wall resolution, moving-floor selection, or ledge response that puts Mario on the ring.  If no such response exists, the Amp branch is fully closed.  The scripted moving owners should then be treated geometrically: prove their complete transformed collision corridors never enter the lower aperture separator, or exhibit the first owner and frame that does.  A low-tier Goomba proposal likewise needs an actual transport to the pole before its small knockback can be relevant.

This note does not claim a universal route disproof.  Runtime table mutation, forged actors, out-of-bounds writes, ACE, and execution after undefined behavior remain outside the successful in-bounds CompCert model.  Within the selected stock roster, however, the broad Rank-12 search has been reduced from many hypothetical actors to exact collision/support composites involving actors that really exist.

## Formal artifact

[`Area2Rank12ObjectImpulse.v`](../../proofs/Area2Rank12ObjectImpulse.v) checks the bilateral Area-2 Amp records, the absence of the named large-motion macro presets, the complete scripted roster, the exact Amp hitbox, the no-push shock handler, the pole-speed reset, the shocked-action call order, and the horizontal fields written by `mario_set_forward_vel`.  Its public boundary deliberately grants the nearest Amp's distance budget and proves only that Amp shock cannot supply the direct 101-unit pole-to-ring displacement.  `MainTheorem.v` exposes that boundary without promoting it to a linked controller-reachability theorem.
