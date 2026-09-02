# Hypothetical pole-to-long-jump table mutation

## Verdict

If a future retail-machine exploit can install the mutation after Mario has
climbed the second SSL Area-2 pole, the lower pole gate has a strong
conditional zero-A bypass.  The Coq model now proves an exact two-word payload
can select the normal `ACT_LONG_JUMP` setter path and that its conservative
no-analog, clear-collision trajectory enters the authenticated lower
target-air cell on frame 5.  This is not a currently reachable route: the
existing CompCert proof still excludes every first table write in a successful
in-bounds selected execution, while ACE, out-of-bounds writes, and code patches
are outside that model.

## The two table words

The useful post-climb construction changes the pole handler word at
`sInteractionHandlers[22]`, initializer word `45` and byte offset `180`, from
`interact_pole` to the signature-compatible `interact_snufit_bullet`.  It also
changes flattened word `3` of `sForwardKnockbackActions`, the weak entry in the
air/on-pole row, to `ACT_LONG_JUMP` (`0x03000888`).  The formal payload is
bilateral: the same two replacements are checked in the generated US and JP
tables.  Word `3` is only the chosen witness; different health, damage,
direction, or water conditions can select another forward/backward cell and
would require changing that exact cell instead.

The distinction between “calling the long-jump handler” and “entering the
long-jump action” is essential.  The redirected damage path first raises a
non-water horizontal speed below `16` to `16`, returns the mutated action word,
drops any held/ridden object, and calls the normal action setter.  The
long-jump setter supplies vertical speed `30` and multiplies horizontal speed
by `1.5`, producing speed `24`.  Merely redirecting an action-dispatch entry to
`act_long_jump` would skip those initializers and is not covered by the
positive witness.

## Post-climb Float32 witness

The checked start is the normalized pole-top sample `(0,4020,1331)`, not a
universal statement about every live handstand pose or release. A separate
[ordinary-exit audit](rank11-pole-exit-live-audit.md) now records a staged
retail timed-Z release at Y 4070, without any table mutation; it does not
install this payload or prove a clean prefix. The target
ring is at Y `3942`, with the nearest central-aperture edges at X `-101/102`
and Z `1229/1434`.  The executable Coq kernel chooses a southbound heading,
no analog acceleration, no wind, and twenty successful collision quarters.
Each frame applies the authentic positive-speed branch of `approach_f32` with
drag `0.35`, advances four separately rounded quarter steps, and then applies
long-jump gravity `2`.

| Frame | Horizontal distance | Y | Z |
|---:|---:|---:|---:|
| 1 | `23.65` | `4050` | `1307.35` |
| 2 | `46.95` | `4078` | `1284.05` |
| 3 | `69.90` | `4104` | `1261.10` |
| 4 | `92.50` | `4128` | `1238.50` |
| 5 | `114.75` | `4150` | `1216.25` |

The exact fifth-frame binary32 endpoint is `(0,4150,1216.25)`, which is inside
the already authenticated south target-air cell.  All five endpoints are
strictly above the ring plane, and the five modeled controller frames have
zero A edges.  Therefore the arithmetic and static cut no longer block this
hypothetical; the remaining collision premise is whether every corresponding
retail quarter step actually takes the clear branch.

## If the mutation is active before the climb

A static pole-handler replacement is not top-selective.  The interaction
table is indexed by interaction type, not by Mario's height or pole action, so
the replaced `INTERACT_POLE` cell is read on the first eligible pole collision
and `interact_pole` does not run to attach Mario.  If that first redirected
collision occurs in a ground action, `determine_knockback_action` uses terrain
row 0, so the corresponding early payload changes flattened forward word `0`;
if it occurs airborne, it uses row 1 and the post-climb word `3`.  Merely
preinstalling word `3` does not turn a ground-row selection into long jump.

Even granting the stronger result—a completely initialized speed-24,
vertical-speed-30 long jump from the normalized pole-base contact
`(0,3200,1331)`—one clear flight is insufficient.  Coq computes a maximum Y of
`3440` on frames 15 and 16, and every one of the first 31 clear-flight states
misses the target-air cells.  This disproves only the direct normalized
first-contact shot, not every early-mutation route.  The same model proves the
height threshold precisely: a contact starting at Y `3702` reaches
`(0,3942,1013)` on frame 15 and enters the target cell at the apex.  An early
mutation could therefore become useful if another mechanism supplies a
contact at or above `3702`, an intermediate support, or a repeatable recontact
that changes the one-flight bound; none is established.

## Can a mutation leave the first grab alone?

There is a limited yes and an important no.  The knockback word can be changed
before Mario reaches the pole without changing the stock pole-handler word;
the generated US/JP `interact_pole` bodies do not read either knockback table,
so that half of the payload has no direct role in grabbing or climbing.  It is
also inert at the handstand: `mario_execute_automatic_action` dispatches
`act_top_of_pole` directly with a switch, and the generated top-of-pole body
reads none of the three audited tables.  Its stock A branch asks the action
setter for `ACT_TOP_OF_POLE_JUMP`, not `ACT_LONG_JUMP`.

There is therefore no single static mutation confined to the three known
tables that both preserves an ordinary first grab and turns reaching the pole
top into the proved speed-24 long jump.  Replacing pole-handler word `45`
early catches the first eligible pole collision, while changing only a
knockback word preserves that handler but has no consumer at the top.  The Coq
file proves that word `45` cannot simultaneously contain both `interact_pole`
and `interact_snufit_bullet`.  Three broader machine-level options remain:

1. preinstall only the knockback action word, then change the pole-handler word
   after the stock grab or climb;
2. redirect a different interaction belonging to an object encountered only
   near the pole top, if a live consumer can be found; or
3. use ACE to patch code or install a small action-sensitive stub that keeps
   calling `interact_pole` below the top and calls
   `set_mario_action(ACT_LONG_JUMP)` at the handstand.

The third option is not a mutation of the three audited writable tables, and
there is no compiled top-of-pole dispatch table in the checked source: it is a
direct switch.  Patching that switch to call `act_long_jump` is insufficient
because it skips the action setter.  Patching the top action to request
`ACT_LONG_JUMP` would run the setter but does not by itself establish the
speed-24 premise—the stock pole state may supply no horizontal speed—so a
viable patch must also supply the checked forward speed and heading or invoke
the compatible damage/setter path.

## Formal boundary and future replay

[`Area2HypotheticalPoleLongJump.v`](../../proofs/Area2HypotheticalPoleLongJump.v)
proves the US/JP payload encodings, compatible generated source shapes,
minimum-speed multiplication, exact binary32 endpoints, zero-A input trace,
post-climb target entry, normalized early-contact miss, and Y-`3702`
threshold witness.  It additionally checks that a knockback-only preinstall
leaves the stock pole word intact, that `interact_pole` and `act_top_of_pole`
do not read the knockback tables, that the automatic dispatcher reaches the
top action directly, and that the stock top action requests the ordinary pole
jump rather than long jump.  It defines `HypotheticalPoleLongJumpRetailBridge`
but does not inhabit it.  The bridge must eventually come from a retail
MIPS/hardware execution that identifies the table addresses and write
mechanism, performs the edit at an exact time, proves the selected
direction/terrain/strength cell, reaches the genuine setter call, and connects
each of the twenty quarter-step collision results to the clear kernel.  A
complete no-A route must then connect the target-side endpoint to the relevant
star continuation.

The authenticated aperture geometry is in
[`Area2LowerTargetCut.v`](../../proofs/Area2LowerTargetCut.v), and the current
in-bounds mutation disproof and general payload capacity are in
[`WritableActionTableClosure.v`](../../proofs/WritableActionTableClosure.v)
and the later writable-table execution-closure files.
