# Cloned-item controls: does an inert enemy create a ground action?

14 November 2026. **The supplied initialized cloned-Goomba state does not
give Mario crawling, walking, or a productive ground slide.** Contact from
above keeps him in FREEFALL with an upward bounce; side contact selects
FORWARD_AIR_KB. Freezing the native callback also leaves INTERACTED set after
the first contact, so this Goomba does not provide repeated bounces in the
retained state. This concerns Mario's **action**, not just his Y coordinate.

The same first-contact equivalence holds in the selected Fly Guy, Klepto,
Crazy Box and shell comparisons. Of these controls only the shell reaches
a ground action, BACKWARD_GROUND_KB in the no-Z menu, which is the previously
studied unproductive knockback branch. No control reaches common ground
slide/crawl alignment or captures the top. Pair/triple interaction ordering
is investigated separately; these single controls do not exclude every
combination.

## Existing records and what a clone grant means

This work credits the earlier [enemy inventory](ssl1-clone-enemy-inventory.md),
[allocation/size-lineage review](ssl1-clone-lineage-sizing-review.md),
[bounce-flight proof discussion](ink-bounce-flight-clones.md), and
[collision-only Crazy Box source](ink-collision-clone-source.md) and
[runtime](ink-collision-clone-runtime.md) studies. Their limitations remain:
an entry enemy and an absent pickup whitelist do not construct a fake
pickup, initialized replacement slot, or delivered actor.

The real `obj_set_held_state` first changes the object's parent. For an
object without `OBJ_FLAG_HOLDABLE`, it then changes `curBhvCommand` to the
selected carry script and sets `bhvStackIndex=0`. Carry scripts contain
BEGIN followed by BREAK. They do not change the original behavior identity
or move the existing object into a new linked list. BREAK suppresses the
native callback, without deactivating the object.

For a HOLDABLE object, the same helper instead updates `oHeldState`. An
ordinary Crazy Box, Bob-omb, small box, or Bob-omb Buddy therefore does not
acquire an inert carry script merely from a normal grab/drop/throw. The
Crazy Box `forced_frozen` control below explicitly supplies that extra
interpreter state; it is not advertised as a legitimate Crazy Box clone.

For non-HOLDABLE Goomba/Fly Guy/Klepto/shell controls, the setup supplies the
three fields consistent with the generic carry-state effect, plus actor
XYZ. This is an **initialized carry-state diagnostic**. It neither runs a
fake pickup nor demonstrates the necessary allocation and release history.
The actor already has its actual initialized type, dimensions and tangible
state; these are read, not written. No arbitrary actor species, radius,
height, script-generated hitbox, or status reset is granted.

## Stock SSL status and inherited fields

| Actor in this native prefix | Live interaction / dimensions R,H,down | HOLDABLE? | Clone-lineage limitation |
|---|---|---|---|
| Regular Goomba slots 6–8 | BOUNCE_TOP / 108,75,0 | No | SSL Area 1 has individual entry Goombas, no selected triplet spawner or demonstrated later Goomba allocation into the donor slot |
| Fly Guy slots 38,44,45 | BOUNCE_TOP with TWIRL_BOUNCE / 105,90,0 | No | These entry actors spawn flames, not replacement Fly Guys |
| Klepto slot 54 | HIT_FROM_BELOW / 160,250,0 | No | Creates rewards/cap, not a replacement Klepto |
| Crazy Box slot 49 | GRABBABLE / 75,125,10 | Yes | Direct carry-script freezing is a forced diagnostic |
| Native shell slot 126 | KOOPA_SHELL / 50,50,0 | No | Shell created by the supplied stock shell-box callback; capture/delivery still not reached |
| Bob-ombs slots 39,40 | GRABBABLE, kickable / 65,113,0 | Yes | Ordinary pickup and respawner are real sources, but not inert carry-script conversion |
| Small box slot 23 | GRABBABLE / 60,100,8 | Yes | Ordinary pickup/respawner; same HOLDABLE distinction |
| Bob-omb Buddy slot 15 | TEXT / 100,60,0 | Yes | Its text handler remains text; HOLDABLE does not turn it into ordinary GRABBABLE |
| Tweesters slots 55–57 | TORNADO, **R=H=0 in this prefix** | No | Freezing these fields does not grant the full-sized native tornado hitbox |
| Pokey parts, flames, explosions | Not live in this selected fixture | Varies | Their stock child allocations require a separate native preparation, not a fabricated interaction-type write |

The older inventory's ordinary size table is not substituted for these live
reads. Pokey parts are genuine in-area replacement candidates; Goomba/Fly
Guy/Klepto fake-pickup lineages remain unconstructed. Distance culling does
not reallocate their entry slots, and allocation resets inherited size and
interaction fields instead of preserving a donor's dimensions. No new
lineage claim is made here.

The common object-update tail still runs after BREAK: timers, selected
flags, distance/visibility and graphics work continue. Objects with automatic
movement flags could therefore still move. All five tested species' sampled
flags lack automatic X/Z and Y integration, and all sixteen frozen-control
actors retained exactly their supplied XYZ for all eight updates. Their
timers and visibility flags can still change. This observed position
stability is not a theorem about every possible cloned object.

## Inputs, setup edits and finite menu

The existing JP prefix has 2,548 A-off inputs plus its disclosed pre-game
debug level-select grant. A shared helper supplies the stock shell box's
action 4 before top update 128 and executes two neutral updates, creating the
shell used in the fixture. This is a supplied preparation, not a
controller-reached box break. All trials restore that same before-130 state.

The sole Mario cut supplies M=C=D=(-1950,Y,-939), FREEFALL, zero action
state/timer, speed 20, velocity (20,-16,0), and yaw 16384. Y is 25000 or 67277.
Actor placement is:

- above-contact control: actor(-1950,Y−10,-939);
- side-contact control: actor(-1989,Y+5,-939);
- Crazy Box push control: actor(-1989,Y,-939).

The three bounce enemies each receive top and side controls in native and
carry-state modes at both heights:24 histories. Crazy Box native/forced
frozen pushing and shell native/carry-state contact add 8, for **32 histories**.
The shell control does not press Z; it isolates first native interaction
behavior rather than repeating the separate shell-cancellation search.

Native cases write only initial Mario fields and actor XYZ. Carry-state
cases additionally supply parentObj=Mario, curBhvCommand=the real
bhvCarrySomething5, and bhvStackIndex=0. No type, subtype, status, scale,
hitbox, tangibility, health, floor, ceiling, platform, velocity, object list,
RNG, or allocator field is changed for the actor. Every later input is
neutral and A-off; there is no held-A dependency and no later gameplay
write. Exact ledgers are preserved in every trial.

## What the native handler actually does

Native and frozen versions have the same first-contact effects in this
menu. These are action/field observations, not inference from a drawn pose.

| Actor/contact | Position/velocity entering first action handler | Action outcome | Productive ground movement? |
|---|---|---|---|
| Goomba from above | M.Y=Y+65; vY=30 | FREEFALL, then air stepping | No |
| Fly Guy from above | M.Y=Y+80; vY=80 | TWIRLING | No; TWIRLING is airborne |
| Klepto from above | M.Y=Y+240; vY=30 | FREEFALL | No |
| Side of any of those three | M.Y=Y; incoming vY=-16 | FORWARD_AIR_KB | No |
| Crazy Box push | M.X=-1882; M.Y=Y | FREEFALL executes, then SOFT_BONK | No |
| Shell from above, no Z | M remains(-1950,Y,-939); RIDING_SHELL_GROUND executes | BACKWARD_GROUND_KB after the stopped step/bonk | Ground action, but not the needed crawl/walk/slide helper |

At these heights the ceiling sentinel interrupts the attempted enemy-bounce
ascent: after the first air step, vY is−4 and stored graphics follows the
new movement position. The first Goomba endpoints have M=C=D.Y=25065 or 67342,
not a low-warp/high-graphics split. Side contacts end at Y−16. The shell
control has the known transient graphics offset 45 with high collision;
that is not useful upper-warp overlap or the large alignment gap.

## A frozen Goomba is not a reusable bounce engine

`clear_object_collision` clears overlap lists/type masks and decrements
positive intangible timers. It does **not** reset each actor's
`oInteractStatus`. The ordinary native callback normally handles and clears
that status; a carry-script actor has lost that callback. Mario's dispatch
checks `INT_STATUS_INTERACTED` before invoking the handler again.

At Y=25000, the exact Goomba contrast is:

| Update processed | Native Goomba: M.Y / actor status / tangible? | Carry-state Goomba: M.Y / actor status / tangible? |
|---|---|---|
| 130 | 25065 / 0 / yes | 25065 / 0xC003 / yes |
| 131 | 25065 / 0xC003 / no | 25061 / 0xC003 / yes |
| 132 | 25061 / 0xC003 / no | 25053 / 0xC003 / yes |

The frozen Goomba remains in Mario's collision list on all three updates,
but only the first contact bounces him. Its 0xC003 status includes
INTERACTED. The native control clears the first status and can bounce again
before its normal death handling makes it intangible. Frozen side-hit
controls retain 0xA000, also including INTERACTED; Mario's normal knockback
invulnerability is an additional later-contact restriction there. Fly Guy
and Klepto carry controls likewise retain these status values throughout
the eight-update continuation.

This limitation is specific to an actual status bit, not a blanket rule
that every inert collider becomes unusable after contact. Plain Crazy Box
pushing leaves status 0 in both native and forced-frozen controls. The frozen
shell's no-Z bonk leaves 0x400000 (STOP_RIDING), which is not INTERACTED and
must not be treated as that same dispatch prohibition. No status was cleared
to manufacture a repeatable enemy bounce. A history that legitimately
changes the status again would need its own concrete writer and timing.

## Validation, scope and combination interface

All 32 eight-update histories were recreated from a second fresh runtime
and the original prefix: **256 matching boundaries**, including actor
fields and frame events. No trial captured the top or reached Area 2.
The results concern supplied initial airborne/actor states, not an
original-ROM replay or a joined allowed controller route. No new Coq proof
was added by this control subtask. Earlier bounce-height and air-copy proofs
retain their stated numeric/execution conditions; their main-universe
numeric ranges must not silently be extended to the positive-VPU controls.

The shared [fixture API](../../instrumentation/ink-item-clone-controls/fixtures.py)
returns the native phase-130 state, an exact live inventory, and preparation
ledger. It rejects `carry_clone` for HOLDABLE actors and offers the separately
named `forced_frozen` diagnostic. The pair/triple search can therefore use
real inherited actor types and sizes without conflating them with a clone
delivery proof. This report does not claim those combinations have been
exhausted or alter the project's route estimate.

The canonical run is `build/wafel-pilot/ink-item-clone-controls-20261114.json`,
copied unchanged to [the durable receipt](ink-item-clone-controls-receipt.json).
The [search script](../../instrumentation/ink-item-clone-controls/search.py)
and receipt preserve all 32 recipes, every setup write, the complete live
inventory, source/helper hashes, inputs, and all observations.

Investigation revision: `08b72af44fbb54aaef3ed7f8be399868ba75db98`.
Decompile HEAD: `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, with existing local
instrumentation preserved. Native source is the JP path, matching the prior
stock-source review where indicated; exact inspected-file hashes are saved.
JP runtime SHA256: `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
Prefix SHA256: `9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.
