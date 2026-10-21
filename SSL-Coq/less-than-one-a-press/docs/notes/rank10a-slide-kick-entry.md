# Rank 10A: can a slide kick unlock ground pound?

The ordinary slide kick and its first bounce fail in the checked elevator
episode. This closes a more specific idea than “Mario is airborne, so press
Z.” It does not close every way of entering ground pound inside the cage.

## The catch in the action code

Normally Mario jumps with A, then starts a ground pound with Z. Walking off
a ledge into ordinary freefall also allows Z, without a new A press. The
elevator problem is reaching that eligible action before escaping the cage.
Being airborne in a slide kick does not by itself allow the same Z command.

A slide kick does have a way to become ordinary freefall. After incrementing
its timer, the game requires both a timer greater than 30 and Mario more than
500 units above his selected floor. Waiting alone is not enough. Once ordinary
freefall is available, its Z check requests ground pound, provided the earlier
B check does not take priority. That last observation comes from the existing
generated-source entry census; the new work concerns getting to freefall.

This is a different test from the more-than-100-unit floor gap that can turn
grounded motion into freefall. It also uses the selected floor, not necessarily
the elevator's base. Losing the base would therefore change the question.

## Include the bounce

The selected source gives slide kick an upward speed of 12 and gravity of 2
units per update. On its first falling landing, it reverses and halves the
downward speed, marks the bounce used, and resets the timer. Gravity has
already run in the air-step helper when that bounce reads the speed.

The new certificate starts Mario and the selected base at Y=4000, moves the
base down 10 units before each Mario update, and checks the four movement
quarters and landing test with Float32 arithmetic. It supplies clear headroom
and continued selection of that base. It does not simulate horizontal wall
responses, other actors, or the whole action dispatcher.

| Episode | Landing update within this flight | Bounce speed afterward | Largest gap at the timeout check |
|---|---:|---:|---:|
| Initial slide kick | 23 | 17 | 142 |
| Its one bounce | 28 | No second bounce | 206 |

Both flights land before their timer can exceed 30, and their gaps stay far
below 500. The second landing selects the slide-kick slide action. The
certificate stops there; later ground movement still needs its own support
accounting. Starting another ordinary episode does not by itself prove that
every intervening controller history has these same conditions.

## A hard fall would be different

The same source permits a bounce speed of 37.5 if the first landing reads
downward speed -75. In a separate conditional vertical calculation, that
bounce over a base descending 10 units per update produces a 565-unit gap
at the start of update 31. Both timeout tests then succeed. This calculation
starts the bounce at Y=2000 with clear headroom; it does not construct the
fall that supplies it.

So we cannot replace the open entry problem with “slide kicks can never
help.” The useful backward question is whether Mario can get that harder
fall, lose or change support, or receive another action change while still
confined. The ordinary short flight supplies none of those conditions.

## Exactly what is checked

[Area2SlideKickEntry.v](../../proofs/Area2SlideKickEntry.v) extracts the real
US/JP timeout decision and resolves the actual slide-kick function. It
executes the timer read, increment, narrowing, store and height checks from
Mario's memory. The timer write preserves his action and position. A failed
height test then executes the skip with unchanged memory for any timer value.
A passed test calls the real action setter with freefall and argument 2; the theorem
retains the setter's actual call and memory effects and proves the enclosing
return is one when that call completes.

[Area2SlideKickEnvelope.v](../../proofs/Area2SlideKickEnvelope.v) checks the
source's launch, gravity and bounce expressions, the 51-update ordinary
vertical episode, and the separate hard-bounce candidate. It connects every
ordinary certificate sample to the real timeout decision. Neither module
assumes a predicate saying that all elevator histories are covered. The
vertical certificate checks arithmetic; the Clight execution theorem covers
the timeout gate. It does not execute all the movement helper calls.

Live floor selection, action scheduling, creation of a hard fall, and the
full freefall-to-ground-pound continuation
are separate obligations. Successful ground-pound entry would still leave
the sideways escape problem. Rank 10A remains open.

## Work backward through the launch

A downward speed from an earlier action cannot simply become the hard
slide-kick fall. The ordinary airborne initializer overwrites vertical
speed with 12. It also applies the forward-speed minimum and updates the
peak-height and flag fields. Those writes do not move Mario or change his
selected floor, floor height or horizontal velocity components.

The new [initializer proof](../../proofs/Area2SlideKickInitializer.v) follows
the complete generated US/JP airborne-initializer call, including parameter
binding, the initial tests, the chosen switch case, its remaining stores
and the return. It starts from unsquished, zero-depth memory with readable
position, flags and forward speed, and four specified writable cells. It
does not assume an incoming vertical speed, a harmless callback, or the
desired returned state. A separate execution proof covers the real outer
action setter's remaining code: its writes stay in the control fields and
preserve the launch speed, position and support data.

The launch value agrees exactly with the vertical certificate's speed of
12. It differs from both the supplied downward speed of -75 and the rebound
speed of 37.5. This removes inherited speed as that setup; it does not remove
the possibility of accelerating downward later. The call and caller-suffix
results do not yet derive a whole controller-reachable transition from
crouch sliding through every subsequent frame. The useful next predecessor
is still a concrete event after launch that lets Mario fall much farther,
changes the selected support, or changes his action while he is confined.

## Post-bounce execution bridge (2026-10-21)

The [upstream-transfer check](rank10a-post-bounce-transfer.md) strengthens
this boundary with actual generated execution after the bounce. The new
proof constructs the complete US/JP slide-kick gravity call for any action
state, deriving the exact binary32 subtraction and clamp and preserving
all disjoint memory loads. For a certified post-bounce sample with matching
input memory, its velocity result is exactly the existing vertical model's
next velocity. A separate proof executes the real handler suffix after an
`AIR_STEP_NONE` result and a nonzero action state: it returns zero without
changing memory.

These are local execution pieces. Composing them through the real movement
quarters, wind and display updates still requires one consistent live-memory
history. The finite samples have not become a complete flight proof, and
upstream's WMotR floor and height-budget premises are not assumed for SSL.
A controller-reachable hard-fall setup and useful sideways departure remain
open; the Rank 10A estimate is unchanged.

## Validation

The 2026-09-13 SSL pipeline audit in
`build/audit/20260913-195349-lzrrm0j0` passed compilation, proof-hole checks,
link checks, integration and all four selected assumption audits. Each
selected theorem used seven allowed foundations. The entry boundary is
consumed by `current_rank10a_ground_pound_moving_geometry_boundary` in Main.
These checks do not discharge the live-support or controller-history gaps.

The complete launch call and remaining-setter proof passed the later selected
audit `build/audit/20260913-211426-5ukri3ea`, also on 2026-09-13. It checked
562 registered source files, compilation, proof holes, generated link hygiene
and integration. Main's 10A boundary, the complete initializer call, the
remaining-setter preservation theorem and their combined launch boundary
each used seven allowed foundations. Main now consumes that launch boundary
as well. The new call proof does not close the later-flight or whole-route
obligations.

[Back to Rank 10A](../no-a-route-atlas.md#route-rank-10a)
