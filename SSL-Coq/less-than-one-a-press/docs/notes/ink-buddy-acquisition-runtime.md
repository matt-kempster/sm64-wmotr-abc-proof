# Controller-produced Buddy reference, then ordinary donor pickup

14 November 2026. **The conversation target is reachable without pressing A;
the next real pickup replaces it with the Crazy Box. This history does not
grab or clone the pink Bob-omb and does not deliver an actor to Ink.**

The useful advance is that the pink Bob-omb reference is now obtained through
actual controller inputs. The earlier conditional Buddy movement experiment
supplied `usedObj`; this experiment supplies no such pointer. Talking to the
real Buddy naturally writes `usedObj = Buddy`. Leaving that reference behind
and subsequently grabbing a real item fails at a precise point: selection
changes `usedObj` to the item before the generic pickup reads it.

## Reproducible history and grants

The history begins at the project's existing debug level-select startup in
JP, with A released throughout. The source prefix has 2852 inputs and SHA-256
`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.
The successful branch reuses its first 2339 inputs, approaches Buddy and
completes dialogue in 329 further updates, then reaches the western native
Crazy Box and picks it up in 801 updates. Two neutral observation inputs make
the complete preserved schedule 3471 inputs.

The only supplied gameplay-adjacent setting is `gDebugLevelSelect=1` before
entry, equivalent to the established original-ROM `--cheats 6` bootstrap.
All subsequent writes are controller pads. There are no supplied position,
velocity, action, pickup/interaction/held pointers, actor placement, object
identity, object-pool reuse, health, RNG or phase edits. No held-A assumption
is used. This does not construct the castle-to-SSL prefix from a clean save.

The Buddy is the stock Area 1 actor in slot15 at `(-5990,0,-3871)`, running
`bhvBobombBuddyOpensCannon`. The western Crazy Box is slot49, initially at
`(-5200,-0,1700)`. Both exist in the actual SSL Area 1 macro-object list.

## Exact predecessor and first failed condition

The table uses **completed controller inputs**, not a renderer frame. The
native recorder observes the state before poll `n+1` after completing input
`n`; Wafel's recorded global timer is also `n+1` at that boundary.

| Completed input | Mario action and movement XYZ | `usedObj` / `interactObj` / `heldObj` | Meaning |
| --- | --- | --- | --- |
|2339|WALKING; `(-5389.69287109375,150.73472595214844,-3545.692138671875)`|Tweester55 / Tweester55 / null|Unmodified native approach prefix.|
|2359|WAITING_FOR_DIALOG; `(-5903.70654296875,0,-3777.8203125)`|Buddy15 / Buddy15 / null|B while walking into talk range successfully starts native dialogue.|
|2668|IDLE; same XYZ|Buddy15 / Buddy15 / null|Cannon dialogue is complete. The desired stale dialogue reference is real, but Buddy is not held.|
|3465|MOVE_PUNCHING; `(-5106.23388671875,-0,1754.337890625)`|Buddy15 / box49 / null|Native contact supplies the grabbable box interaction; the old dialogue reference still exists.|
|3466|MOVE_PUNCHING; `(-5106.92919921875,-0,1750.39892578125)`|Buddy15 / box49 / null|The old reference persists another update while punching.|
|3467|PICKING_UP; `(-5107.45068359375,-0,1747.44482421875)`|box49 / box49 / null|**First failed acquisition condition:** native selection overwrites `usedObj`; the pending pickup targets the box.|
|3469|PICKING_UP; `(-5104.796875,-0,1748.840087890625)`|box49 / box49 / box49|The delayed pickup grabs the real Crazy Box.|

The return route passes western targets `(-7700,-4500)`, `(-7700,1000)`,
`(-5500,1600)`, then the box. A target is only a steering goal: the second
waypoint was not reached within its 400-update budget, and its recorded end
position is `(-6751.955078125,0,-557.2921142578125)` in stomach slide. Continuing
the recorded inputs nevertheless reaches the box. This is ordinary native
walking, sliding and occasional freefall, not a teleport between waypoints.

Buddy remains active in the same slot, with the same native behavior and
exact spawn XYZ, throughout all 3123 recorded observations, including the
more than 5000-unit departure toward the box. This single departure tests
that going out of rendering range does not itself recycle this Buddy slot;
it is not a proof about every possible actor lifetime.

## Other finite controls

Five independent Wafel histories were freshly replayed, matching 1755 exact
suffix observations. The first approach policy stopped before pressing B,
entered braking/punching instead of accepted dialogue, then was hit by fire
and died. That failed policy is preserved, not used to claim talking is
impossible. The corrected policy presses B during the walking contact.

A separate native prefix of 2675 inputs followed by two neutral updates grabs
the western Crazy Box. Attempting to transport it by steering toward
`(-7400,1000)` instead enters the box's native three-bounce action. The 123
input continuation ends in stomach slide at
`(-4554.224609375,-140.10997009277344,443.6163635253906)`, with the box released.
It never reaches Buddy. This is why that attempt cannot be reported as an
ordinary carried-box delivery. No additional blind transport branches are
counted as acquisition evidence.

## Evidence and limits

The experiment uses proof checkout
`49807c387f90e29856e2ae34a656f9394137ec19`, source checkout
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461` (stock pin
`9921382a68bb0c865e5e45eb594d9c64db59b1af`), Wafel0.8.5 and Python3.9.13.
The authenticated JP DLL SHA-256 is
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The complete successful history independently replays with exact matches for
3123 before-poll observations. The guard rejects every noncontroller write
after startup, and rejects both held and newly pressed A.

**Original Japanese ROM replay passed.** Mupen64Plus2.5.9 in interpreter mode,
Rice2.5.9, HLE RSP and dummy audio reproduced all 3471 controller inputs. The
3123 native observations exactly match Wafel's M/C/D, floor, top, action,
input, references and Buddy/box state fields, with zero mismatches. Wafel's
global timer is one greater at the matched before-poll boundary. The ROM
SHA-256 is `9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`
and MD5 `85d61f5525af708c9f1e84dce6dc10e9`; the established recorder checked
the authentic JP instruction ranges before running. The read-only wrapper
imports no game-memory write API. This is a field comparison, not complete
memory equivalence.

The original run is `build/wafel-pilot/capture.2DrCJ9`; its compressed log,
receipt and source provenance are preserved in
[`native-record`](../../instrumentation/ink-buddy-acquisition/native-record/receipt.json).
The actual input schedule and scripts are in
[`instrumentation/ink-buddy-acquisition`](../../instrumentation/ink-buddy-acquisition/README.md).
The [source audit](ink-buddy-acquisition-source.md) explains why the native
selector overwrites the dialogue reference and identifies the remaining
slot-lifetime/rebinding obligation for a genuine fake-object route.

Separate verdicts: native Buddy dialogue/reference **reached**; Buddy
pickup/clone **not reached**; Buddy delivery to the Ink setup **not reached**;
useful spawning displacement from this history **not reached**. This result
narrows a concrete acquisition branch without changing the open clean-route
assessment. No full no-A impossibility claim follows from the finite trace.
