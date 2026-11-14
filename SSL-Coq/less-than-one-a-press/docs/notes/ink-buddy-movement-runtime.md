# Pink Bob-omb Buddy: native contact and conditional relocation

The ordinary SSL cannon Buddy stayed at its spawn in these finite tests.
However, once a **supplied fake-pickup reference** lets Mario's real pickup
handler acquire it, real Z-drop and B-throw code reposition the actual
Buddy without any direct writes to its coordinates. The native Buddy
callback then keeps running at the new location. A claim that this actor
can never move is therefore too broad; whether an allowed gameplay
history can establish that fake-pickup reference remains a separate
obligation. These tests do not produce an Ink handoff or a delivery route.

This note reports the JP **Wafel** experiments only. The
[source analysis](ink-buddy-movement-source.md),
[proof scope](ink-buddy-movement-proof.md),
[original-ROM replay](../../instrumentation/jp-ink-buddy-movement/README.md)
and [combined verdict](ink-buddy-movement.md) are separate records. The
original-ROM replay has its own timings and coordinates; the measurements
below must not be relabeled as original-ROM values.

## Exact version and evidence

Run date: 2026-11-14. Proof checkout base:
`9229f9e2466782a142b595fda6d5cc64ee4c1016`. Decompile base:
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. The working decompile's
`interaction.c` and `object_helpers.c` appeared dirty from line endings,
with no textual `git diff`; hashes of all six consulted source files are
preserved. Runtime: existing Wafel 0.8.5 JP DLL, Python 3.9.13. DLL SHA-256:
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
Original capture SHA-256:
`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.

[Script and reproduction instructions](../../instrumentation/ink-buddy-movement/README.md),
[compact receipt](ink-buddy-movement-runtime-receipt.json), and
[complete compressed trace](../../instrumentation/ink-buddy-movement/runtime-traces.json.gz)
preserve the fixtures, inputs and observations. The original input capture
is also retained compressed alongside the script. Two independently
created runtimes matched at all **3,323 checked boundaries**. This count
includes the common untouched prefix once, not twice; it is a finite
comparison, not an all-histories theorem. Restoring the preserved gzip
input capture and running the script again produced byte-identical full
JSON; artifact, source-script and decompressed-trace hashes also passed.

## Untouched spawn and ordinary contacts

The inherited A-off four-pillar prefix uses the established pre-game
`gDebugLevelSelect = 1` grant. It has no gameplay Buddy, Mario-pose or RNG
writes. Stock Buddy slot 15 first appears at the end of input poll 348.
All **2,201 live end boundaries through poll 2548** have raw object
XYZ `(-5990, 0, -3871)`, idle action 0, forward velocity 0 and vertical
velocity 0. Its native callback is active; its object timer advances.

Further controls start after neutral inputs reach top slot 61, action 1,
timer 125 (global timer 2675). All restore the same native state first:

| Control | Supplied setup and inputs | Checked result |
|---|---|---|
| Walk into Buddy | Mario M/C/stored gfx placed 160 units from Buddy, eight compass directions, IDLE and zero velocity; 32 updates of stick magnitude 64 toward Buddy | Mario collision registered at 29 boundaries per direction; Buddy position unchanged |
| Approach with B | Same eight cuts; B every sixth update, 32 updates | Mario collision registered at 27 boundaries per direction; Buddy position unchanged |
| Bob-omb nearby | Move only native Bob-omb slot 39 to radius 80 around Buddy, four directions; 48 neutral updates | Buddy position unchanged; no Buddy collision-list registration with that actor |
| Crazy Box nearby | Move only native Crazy Box slot 49 to radius 80, four directions; 48 neutral updates | Buddy position unchanged; no Buddy collision-list registration with that actor |

The last eight histories are **nearby placement controls**, not demonstrated
two-body collisions. This agrees with the source's object-list filtering;
their failure alone would not close every object-mediated route. None of
these controls edits Buddy, its flags, hitbox, velocity or behavior.

## Conditional pickup: the exact missing premise

The ordinary native small box remains in slot 23 at `(5900, 51, 3440)`.
At the timer-125 root, supply Mario M/C/stored gfx at `(5900, 51, 3380)`,
IDLE, action state/timer zero, forward velocity zero, velocity `(0,0,0)`
and face angles `(0,0,0)`. These eleven field writes are listed with
before/after values in the receipt. The first input is B with neutral
stick; subsequent pickup inputs are neutral. A is never pressed or held.
No object, floor cache, ceiling, HOLP or RNG is supplied.

| Update after cut | Global timer | Native observation |
|---|---:|---|
| 1 | 2676 | PUNCHING; Mario `(5900,51,3358)` |
| 4 | 2679 | PICKING_UP, `usedObj = box23`, `heldObj = NULL`; Mario `(5900,51,3373)` |
| Boundary after 4 | 2679 | **Only extra grant:** replace `gMarioState.usedObj` with the pointer to Buddy15 |
| 6 | 2681 | Real pickup code installs Buddy15 in `heldObj`, sets Buddy held state 1 and parent Mario67 |
| 17 | 2692 | HOLD_IDLE; Mario `(5900,51,3348)` |

The native small-box control omits the extra reference grant and acquires
box23 instead. Thus the B/animation sequence really reaches pickup code;
the special Buddy acquisition depends exactly on the retargeted reference.
It does not demonstrate slot reuse, object respawn, a cloning allocation
history, or a natural way to grab this NPC. The script's guard prohibits
every write to Buddy's fields, including setup writes.

Merely holding this actor does **not** move its raw collision coordinates
to Mario. Buddy stays at `(-5990,0,-3871)` during pickup and for all 64
subsequent neutral HOLD_IDLE updates. Its native callback ignores held
state and continues executing. This experiment says nothing about the
visible held-object rendering.

## Native release relocates the actual NPC

Each release starts from the same update-17 HOLD_IDLE state. It uses one
frame of the stated button, then neutral input for a total of 64 updates.
There are **no additional state writes**, including no HOLP write.

| Input | First actual Buddy relocation | Result through release update 64 |
|---|---|---|
| Neutral | None | Raw Buddy stays at original spawn, held state 1 |
| Z | Update 1 / global 2693: `(5884.970703125, 51, 3394.09765625)` | Same XYZ throughout; held state 3, zero forward/vertical speed |
| B | Update 7 / global 2699: `(5888.64013671875, 160.45941162109375, 3362.26953125)` | Lands, bounces, then settles at `(5888.64013671875, 51, 3362.26953125)` from update 24 onward; held state 2 |

The throw's previous native HOLP is
`(5888.64013671875, 162.95941162109375, 3330.26953125)`. Throw code adds
32 along yaw zero to Z; the Buddy callback then applies gravity, giving
the recorded Y 2.5 units lower at that update's end. Forward velocity
stays zero. First floor contact is update 15 at Y 51 with rebound
vertical speed +11.25; it is not a monotone fall. This is the generic
object physics, rather than a species-specific thrown-object launch.

At both final release boundaries, Buddy still has its native
`bhvBobombBuddyOpensCannon` identity, TEXT interaction type, NPC subtype,
radius 100, height 60, intangible timer 0 and active flags 259. Neither
carry-script start nor carry-script BREAK is installed. Its home remains
the original spawn; its position-copy fields follow the new position.
It does not snap home in these 64 updates. Mario/Buddy collision is
registered at the new location. These observations support a relocated,
still-collidable NPC under the supplied pickup premise; they do not
establish delivery at the high Ink setup or prove indefinite persistence.

## What remains open

The first missing condition is a gameplay history that makes native pickup
code target this HOLDABLE NPC, with no supplied `usedObj` edit. The tests
do not replace that with an assumed clone. Likewise, an arbitrary high
HOLP, useful release coordinates, and timing for the actual Ink producer
have not been constructed here. The next meaningful experiment is to
test a concrete fake-pickup/slot-reuse predecessor with an exact allocation
trace, then use the already demonstrated native release sequence. Repeating
ordinary player pushing cannot substitute for that missing reference.
