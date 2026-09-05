# Rank 9 static collision and conditional timing diagnostics

**Parked pending an independent no-A elevator escape.** These diagnostics
start outside the elevator and test only a downstream continuation. They
cannot remove the A press used by the ordinary elevator exit, even if every
local check succeeds. Preserve them as supporting evidence for a future
bypass; they are not a controller-reachable escape demonstration.

Run from `SSL-Coq/less-than-one-a-press`:

```sh
node instrumentation/rank9-upper-star-dance/check.js
node instrumentation/rank9-upper-star-dance/timing.js
```

The script only reads the pinned static pyramid mesh. It reconstructs
surface normals, cell membership, source-order wall lists and first-vertex
sorted floor/ceiling lists, then evaluates a particular falling-star catch.
It checks the preceding geometry-input walls, first quarter, and next landing,
including all 50 successful integer entry heights in the tested 201-height
range. Low/high and disabled-ledge controls must fail to catch.

`timing.js` uses the same static queries in one conditional local sequence:
coin collection, the first ground-pound lift, the post-action star-home
sample, all 77 Float32 star movement updates, a frozen camera wait, hitbox
installation, every remaining startup geometry check, first star contact,
ledge catch, and landing. The granted initial state is freefall at
`(340,4578,-850)` with 99 coins and a surviving nearby row coin; Z requests
the first startup in that update. It is **not** a reconstruction of that
arrival or a test of raw controller polling. Exactly one coin handler is
needed to reach 100; subsequent incidental coins do not move this star.

The witness first contacts the star at `(337,4686,-850)` with startup timer
9. All nine later-startup controls miss vertically, even granting every
remaining lift. The controls use X=337 initially and choose an overlapping
child from the same five-coin row; they are separate conditional tests, not
edits of the witness mid-run. All 61 integer initial heights 4560..4620 are
tested; exactly 4570..4619 catch. Camera completion and its protected-state
frame are granted, not simulated. Animation completion, dialog responses
and the later Act-3 pickup are not executed.

This is not an emulator, controller movie, live-memory receipt, or proof of
clean reachability. Dynamic surfaces and other frame effects are not supplied;
`sqrtf` is an unverified host-math approximation followed by Float32 rounding.
No game state, executable, or process is edited or accessed. See the
[proof note](../../docs/notes/rank9-upper-star-dance.md) for the separately
checked Coq fragments and the exact remaining route obligations.
