# Western Fire Fly Guy: manipulation, landing and native slide entry

14 November 2026. This source follow-up starts at proof revision
`4813e95d33286a30882caf0759dd838c95ee48f2`, branch
`codex/ssl-pyramid-item-proof`, with decompile checkout
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461` and the project's stock source pin
`9921382a68bb0c865e5e45eb594d9c64db59b1af`. The applicable game is original JP.
This note separates source deductions from the companion controller experiments.
It does not supply actor coordinates or claim an original-ROM manipulation replay.

## What the attached manipulation example changes

Manipulation is an actor movement history, not a clone placement. The stock TTM
actor is itself a **Fire Fly Guy**: `levels/ttm/areas/1/macro.inc.c` contains
`macro_fire_fly_guy` at `(2300,-1384,3753)`. The shared model does not distinguish
generic and fire-capable behavior. The attachment review identifies the precise
footage, captions and A-dependent maneuvers separately; this note uses actual
source to explain the transferable mechanics.

SSL Area 1's western fire variant starts at `(-3400,1160,-1120)`. Its unchanged
home coordinates are important but do not define a movement clamp. There are
two different distance rules:

| Rule | Actual distance and threshold | Effect |
| --- | --- | --- |
| Home steering | 3D actor-to-home distance above 2000 | Replace angle-to-Mario with angle-to-home and distance-to-Mario with sentinel 25000. |
| Home steering, actor still near home | 3D Mario-to-home distance above 2000 | Replace distance-to-Mario with sentinel 20000. |
| Ordinary activation | 3D Mario-to-actor distance above the initialized drawing distance, 4000 in SSL and TTM | Set FAR_AWAY after the native callback, causing ordinary movement to be skipped on the following callback. |

The behavior interpreter computes true distance before calling the native behavior
and retains it in a C local. The callback's home substitution can overwrite the
object's distance field without overwriting that saved activation distance. At
the end of the interpreter, the saved distance sets or clears FAR_AWAY. Thus
movement uses the preceding callback's activation decision; one update on either
side of the drawing-distance sphere matters. A camera visibility cut is not the
same condition as this 3D distance test.

While FAR_AWAY, Fly Guy still changes native action, timer, yaw, pitch, roll,
velocity, size and its small Y oscillation. Its ordinary `cur_obj_move_standard`
displacement is skipped. Wall resolution is skipped, although floor state still
updates. Reactivating at a chosen phase can expose a useful velocity/direction
that was prepared while most movement was frozen. This is why the manipulation
demonstration can be relevant without any cloning.

## Why the spiral and its last frames matter

In approach, the actor turns toward the substituted angle and approaches forward
speed10. Facing within0x2000 and either being more than400 above Mario or having
distance below400 permits a lunge or fire choice. The generic actor always lunges;
a fire variant also consults RNG. The lunge's initial pitch still aims at actual
MarioY minus200, even if the horizontal angle was replaced by the home angle.

A descending lunge reduces its downward speed over roughly30 callbacks. Once
vertical speed is nonnegative, the actor spirals: roll changes movement yaw,
face yaw follows, and upward speed approaches20 by0.5 while below actual
MarioY+200. Above that target it approaches0 by0.5. Once speed is zero, the actor
also waits for roll zero before returning to approach. A distant Mario can alter
those phases while the FAR_AWAY flag suppresses normal displacement. Briefly
reactivating the chosen spiral heading is therefore a genuine lateral transport
lead. The next approach phase can turn home again; timing is essential.

None of these rules grants an arbitrary vertical coordinate. The upward target
uses actual Mario Y, upward momentum can overshoot, and the small oscillation is
not skipped. A global height bound would need a reachable bound on Mario's own
height and all intervening actor writers; no such invariant is assumed here.
High-VPU terrain aliasing does not move Mario, actor home or the activation sphere.

At X/Z `(-1950,-939)`, the western actor's home sphere reaches approximately
Y2525.55. This is a geometry fact about a steering region, not a maximum reachable
Fly Guy height or a demonstrated useful interval. The local same-universe target
deserves testing before assuming that 21,778 or a VPU is needed.

## Fly Guy bounce does not immediately give the needed ground slide

A qualifying falling hit above a native Fly Guy first attacks the enemy, snaps
Mario's movement Y to actorY plus its live hitbox height, sets vertical velocity80,
and requests TWIRLING. Native attacks consume the health-zero actor; this is not
an indefinitely reusable stationary platform. The actual constructor substitutes
JUMP if squishTimer is nonzero or quicksandDepth is at least1, so a trace must
record those guards instead of assuming every request becomes TWIRLING.

For an ordinary A-off twirl, the intended angular speed approaches0x1800. During
nonnegative vertical velocity the normal gravity4 branch applies; an unobstructed
80,76,...,4 ascent has840 units of rise above the post-bounce snap. Only after
vertical speed becomes negative does twirl gravity apply. At settled0x1800 yaw
speed its terminal downward speed is12.5. This gives substantial steering time
but is neither an arbitrary altitude source nor a retained display gap. Each
ordinary air step refreshes stored graphics from movement.

The actual action-entry path is constrained:

1. TWIRLING has no B- or Z-cancellation branch. Its normal transition to a ground
   action requires `perform_air_step` to return AIR_STEP_LANDED, selecting
   TWIRL_LAND. Walls reflect its horizontal movement; they do not grant a slide.
2. TWIRL_LAND checks STOMPED and OFF_FLOOR first. OFF_FLOOR requests FREEFALL.
   Otherwise it calls `stationary_ground_step`, which normally puts movement at
   the cached floor and copies that value to stored graphics. It ignores B/Z and
   waits for animation end **and** angular speed zero before setting IDLE.
3. The next genuine supported idle/walking state can enter a slope slide or
   walking-to-crouch-slide via Z. An unsupported IDLE instead takes OFF_FLOOR
   before slide/walk/crouch controls, as the existing connected Coq guard proves.
4. A ground slide must reach the common ground-step/alignment code with the
   useful cache and positions. Merely landing high or reporting a slide action
   at the end of a frame does not establish that producer path.

There is a second direct shortcut to exclude: **a descending twirl does not mount
a shell like ordinary freefall**. The classifier checks TWIRLING's attacking
action first and chooses GROUND_POUND_OR_TWIRL, value1. That nonzero interaction
prevents the later generic falling-hit classification, value64. The shell only
mounts on that exact falling-hit result or WALKING/HOLD_WALKING. Consequently a
descending twirl takes the shell's fallback push instead of selecting
RIDING_SHELL_GROUND, so the old shell/Z constructor cannot simply be appended to
the twirl. For the same reason, descending onto another Fly Guy while still
twirling attacks it rather than renewing the80-speed twirl bounce.

## Burning is a distinct, weaker constructor

A real flame can request BURNING_JUMP without A while Mario is grounded or rising;
an airborne Mario with nonpositive vertical speed gets BURNING_FALL instead.
Invulnerability/cap/water guards apply. BURNING_JUMP initializes vertical31.5
and forward8, giving140 clear dry ascent under gravity4. It does not give the
Fly Guy's80-speed twirl launch.

Both burning air actions need an actual landing to select BURNING_GROUND. That
ground action ignores B and Z, moves under its own speed/slope rules, and changes
to BURNING_FALL on LEFT_GROUND. It lacks the common slide's floor-alignment call.
With no new A, its ordinary way back to WALKING is burnTimer above160, or suitable
water extinguishing. WALKING can then take Z or slope conversion in the native
redispatch loop. Health loss and landing support must survive until that point.
Repeated flame contact during invulnerable burning does not grant free relaunches.

## Concrete experiment priorities

The drawing-sphere technique can be tested with ground travel rather than the
attachment's A-dependent jump, if reachable SSL terrain crosses the relevant
sphere. Log both the true 3D distance and the substituted object distance; the
FAR_AWAY flag alone misses the one-update lag. First reproduce lateral transport
of the actual western actor from its native spawn, then seek a no-A height source
that puts Mario above it for the qualifying falling hit.

Once a bounce is real, steer the slow descent toward a real top/pillar/roof and
record the full TWIRLING → TWIRL_LAND → IDLE/slide sequence. Do not add shell/Z
while still descending in TWIRLING and count its action request as available.
If a ground slide is reached, continue through the existing low-cache producer,
warp, retry, retained-platform and displaced-arrival checks. Holding the Box
fixture fixed can isolate Mario reachability, but remains a separate component
from full actor delivery and the phase join.

## Retail/source-runtime contact bookkeeping must remain visible

The companion original-ROM observer found a possible comparison boundary worth
checking explicitly: subtype128 versus130 differs by DELAY_INVINCIBILITY, bit2.
The source writer is `detect_object_hurtbox_overlap`: for Mario it sets that bit
before the hurtbox-radius check and clears it only when hurtbox overlap succeeds.
`check_collision_in_list` calls that helper after a nonzero hitbox-overlap return.
The original C hitbox function has a missing return on failed horizontal overlap;
the generated source model supplies zero under AVOID_UB. A spurious native return
could therefore explain a distant bit update, but the source alone does not
establish that this is what the retail binary did in the observed frame.

The older [PU report](pyramid-top-pu.md) already records the AVOID_UB boundary and
a target-object return-zero audit. That does not license ignoring a fresh retail
field mismatch. Preserve the raw comparison, separately identify matching
trajectory fields, and observe the native call/return path if the bit's cause
matters. DELAY_INVINCIBILITY can block damage/knockback, so it is not globally
irrelevant. No claim of whole-memory equivalence follows from matching XYZ.

## Coq attempt and remaining obligation

No new compiled theorem is claimed for this study. The baseline selected audit
passed at `build/audit/20261114-091822-fts0ct20` for
`current_ink_backward_execution_boundary` and
`current_ink_buddy_acquisition_boundary` (721 sources, zero inventory, hole or
link problems). The pipeline reconfirmed Coq 8.16.1 and CompCert 3.15 in the
`sm64-item-proof` switch with the established memory limit.

The [unregistered draft](ink-flyguy-entry-guards-draft.v.txt) attempts two actual
generated-Clight execution cuts: descending TWIRLING makes
`determine_interaction` return interaction 1, and interaction 1 with a live
TWIRLING action skips the real shell mount/action-request gate. Its local
velocity-field read helper passed during compilation. The next path proof did
not compile: after reading Mario's velocity at offset 76, its tactic must
establish the generated `vel[1] < 0.0f` branch from the hypothesis
`Float32.cmp Clt y Float32.zero = true`. The classifier return proof and shell
gate proof that follow it were therefore not checked. The
[failed targeted-build output](ink-flyguy-entry-guards-draft-build.log.txt)
preserves the exact stopping point. No axiom or admitted result was added.

The draft is stored as `.v.txt`; its provisional `_CoqProject` registration and
MainTheorem import/export were removed. Even if completed, these two cuts would
still require caller/result binding to form one linked shell interaction and
would not prove the reachability of an earlier Fly Guy contact or exclude every
possible action-changing contact history. The source conclusions above remain
source deductions, separate from a compiled Coq result.

## Source references

All links use the project's stock source pin:
[TTM Fire Fly Guy](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/levels/ttm/areas/1/macro.inc.c#L39),
[SSL actors](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/levels/ssl/areas/1/macro.inc.c#L44),
[default drawing distance](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/spawn_object.c#L273),
[interpreter ordering](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/engine/behavior_script.c#L907),
[home substitution](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/obj_behaviors_2.c#L876),
[Fly Guy native actions](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/behaviors/fly_guy.inc.c#L55),
[partial movement](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_helpers.c#L1787),
[classifier](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L182),
[twirl bounce](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L1368),
[shell mount guard](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L1460),
[twirl action](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_airborne.c#L680),
[twirl landing](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_stationary.c#L1007),
[twirl gravity](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_step.c#L503),
[burning ground](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_moving.c#L1300).
