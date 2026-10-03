# What the concrete Ink backward search can try

3 October 2026. This is an inventory of the implemented Python generators,
checked by reading the source and enumerating their proposals. No new gameplay
search, Coq result or route exclusion is claimed. The current tool is a small
library of proposed earlier states with a real-game validator; it is not a
general inverse of every SM64 action.

## The five proposal types

| Proposal | Earlier state it guesses | Current samples |
| --- | --- | --- |
| Installation: vary actual Y before geometry | Idle Mario with the target's low collision record and chosen display, zero depth and zero vertical speed. The real update decides whether the first lookup succeeds or uses the display retry. | Actual Y is the target collision Y, 767, 769, 1201, 1202 or 1861. With collision Y=768, these are six different heights. |
| Installation: high actual position with a low picture | Idle Mario at Y=1861 with collision and display at Y=768, zero depth and zero vertical speed. This tests successful first-query installation without a raised display. | One additional pose in the raised-display menu; it duplicates the Y=1861 pose in the low-display menu. |
| Earlier ordinary ground update | Start in idle at a guessed actual height, with either a synchronized picture or the target picture, and a guessed depth. Let ground movement, its normal copy and later sinking run. | Three heights: target actual Y, 1202 and 1280. Two picture choices and two depth guesses. |
| Earlier freefall update | Supply freefall and a guessed vertical speed. Work actual Y backward through four rounded quarter-step additions, then let the full game execute movement, gravity, collisions and copying. | Vertical speed -75, -16, -4, 0 or +4. Two picture choices and two depth guesses. |
| Earlier automatic message ending | Supply the automatic message-reading action at state 24, just before it finishes, and work the old picture backward through a guessed final sinking adjustment. | Three depth guesses. No real star pickup or opened message constructs this state. |

The names are hypotheses. In particular, a proposal named "pre-action retry"
can actually find a floor on its first lookup; the generator does not force a
failed lookup. The message proposal does not open a message or prove that Mario
can enter its assumed final state. Ground proposals start in idle; there is no
separate inverse for an already-walking action, even though the forward update
may change action after reading the supplied controls.

## Inputs and exact proposal counts

Every Ink proposal is paired with **36 controller samples**: no buttons, B, Z
or B+Z, each with a centered stick or one of eight directions. The nonzero raw
stick components are -127 or +127. A is released in all of these samples.
Other stick magnitudes, buttons and preceding controller-edge histories are
not enumerated.

The raised-display installation menu has **252 proposals**: seven poses
times 36 controls. The low-display menu removes its duplicated pose and has
**216 proposals**: six poses times 36 controls. For each earlier parent,
the raw menu offers **432 ground**, **720 freefall** and **108 message-ending**
proposals, totaling **1,260**. Counts describe generated proposals, not accepted
gameplay steps or exhaustive preimages.

For the current low-display parent, movement Y=1861 and display Y=768 make the
ground/freefall depth guesses 0 and 1093. The message-ending guesses are 0,
36.43333435058594 and 1093. These are supplied test values, not stock depths
derived from a gameplay history. The actual update can clear or clamp them.
A read-only enumeration confirms that all 1,260 declared patch/input pairs for
this parent are distinct.

## What the tool changes, and what it inherits

The adapter permits patches to movement, collision and display coordinates,
vertical speed, depth, action, action state, action argument and action timer.
However, the generators use only a narrow subset of that capacity. **All
earlier proposals inherit the parent's complete collision position and keep
movement X/Z unchanged.** Their display X/Z also remain fixed. Earlier ground
and freefall actions start at state zero; message ending starts at state 24.
Every proposed action timer and argument is zero.

The remaining world, floor lists, other objects, horizontal velocity,
platform pointer, RNG, camera, previous action and earlier controller state
come from the corresponding saved neutral context. The scene was normally
initialized, but its four-pillar completion is supplied. Mario is unmounted in
these contexts. The search does not reverse or independently generate those
surrounding facts.

## What validation buys us

Each trial restores its earliest context, patches once and advances normally
through the proposed suffix. It compares intermediate movement, collision,
display, action and depth. The last comparison also checks action argument,
used warp, floor height, floor owner and captured platform, with movement
checked at disappeared-action entry. There is no intermediate patch or restore.

Matching does not cover every observed field or all memory. Intermediate
velocity, action state/timer, RNG and controller history are not included in
the parent comparison. Grouping uses the same five parent fields and keeps
the first successful input suffix, so omitted states and other suffixes are
not proved equivalent. The default frontier limit is six retained poses; the
current command accepts at most thirty updates. The previous checked run hit
neither the pose nor time/candidate limit, but its pose grouping is still a
search choice rather than a coverage theorem.

The game can execute wall checks, callbacks and action changes while validating
a candidate. That does not mean the generator has an inverse for those
mechanisms. Successful inside-update collision/display matching still needs
the separate exact emulator observer.

## A separate capability from the original pilot

The original freefall pilot has a more targeted falling-state inverse: add four
to the target vertical speed, undo the four rounded height additions, then
try nearby binary32 values. Its default radius offers up to 25 candidates; the
largest allowed radius offers up to 81. It only applies in its selected ordinary descending
freefall range, excluding the apex and terminal-speed boundary. **The Ink
search does not call this mapper.** Its freefall proposals instead use the five
sampled speeds above.

## Evaluation

This is useful for checking a named short predecessor hypothesis and exposing
the exact record that breaks it. It is currently too narrow to exclude every
producer of the Ink gap. It has no inverse move for a horizontal approach,
wall-corrected predecessor, moving-platform ride or floor-alignment history,
Tweester, shell, enemy throw, earlier message/star construction, or late
position writer. Those effects may occur in a forward validation, but their
earlier poses and required objects are not generated.

The highest priority is a concrete producer move that can explain the
movement/collision disagreement, including the support or ordinary writer
that performs it. Increasing the horizon alone cannot add that missing move.
An empty frontier currently means that no candidate survives this finite
menu in the supplied contexts. The existing one-update success and failed
sampled extensions retain their verdicts; all 45 atlas estimates stay unchanged.

## Inspect the implementation

- [Installation and earlier generators](../../instrumentation/concrete-ink-backward/search.py): `target_install_moves`, `install_moves` and `previous_moves`.
- [Original falling-state mapper](../../instrumentation/wafel-jp-pilot/backward_validation.py): `freefall_predecessors`.
- [Compact enumeration receipt](../../instrumentation/concrete-ink-backward/expected-move-inventory.json).
- Local enumeration script and full output remain in ignored `build/concrete-ink-backward/20261003-move-inventory.py` and `20261003-move-inventory.json`.
