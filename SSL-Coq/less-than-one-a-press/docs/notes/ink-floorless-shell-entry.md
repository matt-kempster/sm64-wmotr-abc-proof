# Floorless shell mounting retains the action, but queues death

14 November 2026. **A high shell-riding action can be created at a genuine
floor miss, but this does not rescue the handoff: death is already queued.**
Two tiny actual-world-edge controls reproduce that ordering. A third
history uses only a later Crazy Box placement to push Mario back into valid
terrain; the existing death operation still counts down and clears the
level. No warp fields were reset or rewritten.

This is a local JP Wafel diagnostic, not a controller-reachable setup or a
new original-ROM replay. It is separate from the
[high airborne enemy comparison](ink-high-other-entry.md), whose VPU floor
miss also queues death despite its frozen airborne action.

## Initial grants and inputs

The established prefix contains 2,548 A-off inputs and its existing pre-game
debug level-select grant. The existing shell preparation sets the stock
shell box's action to 4 before top update 128, then runs two neutral
updates. This creates native shell slot 69 through its normal behavior.
That box-opening action is supplied, not reached with controller input.

Before update 130, supply M=C=D=(X,25000,0), where X is exactly 8192 or
-8192; FREEFALL, action state/timer zero, forward speed 20, velocity
(20,-16,0), and yaw 16384. Place the existing shell at (X,24990,0). No
ground-action ID, floor cache, platform pointer, collision list, top state,
health, or pending-warp field is supplied. All later controls are neutral
except the third history's single Z press on update 132. All are A-off,
with no held-A dependency.

The third history repeats X=8192 and, before update 131, places only the
existing Crazy Box's XYZ at (8231,25000,0). No Mario fields are changed after
the initial cut. The box cut is a separate supplied actor position, not a
delivered or cloned-item route.

The exact X boundaries are rejected by `find_floor` independently of Y:
the JP source checks `x <= -LEVEL_BOUNDARY_MAX || x >= LEVEL_BOUNDARY_MAX`,
with boundary 8192. These are actual terrain boundaries, not horizontal-PU
aliases chosen to stand in for them.

## Native result and ordering

Before each first update the pending warp operation, countdown, and source
node are all zero. Both edge controls produce the same result up to the
sign of X:

| Update processed | M/C/D | Floor | Actual action ID | Action handler events | Pending warp / timer / source |
|---|---|---|---|---|---|
| 130 | (±8192,25000,0), all equal | NULL, cache -11000 | RIDING_SHELL_GROUND | None | DEATH 18 / 47 / 0xF1 |
| 131 | unchanged | NULL | RIDING_SHELL_GROUND | None | 18 / 46 / 0xF1 |
| 132 | unchanged | NULL | RIDING_SHELL_GROUND | None | 18 / 45 / 0xF1 |

The real shell interaction fills the riding/used-object links and requests
RIDING_SHELL_GROUND. But `update_mario_geometry_inputs` has already called
`level_trigger_warp(DEATH)` after both floor queries failed. Next,
`execute_mario_action` sees the null floor and returns before its action
dispatch loop. Thus the riding action ID persists without executing either
shell movement or its Z-cancellation handler. This is a positive example
of action-ID retention, not a useful gap-producing update.

The box variant gives a more concrete recovery test:

| Update processed | Movement/collision | Stored graphics | Floor | Executed actions | Pending warp |
|---|---|---|---|---|---|
| 130 | (8192,25000,0) | same | NULL | None; shell contact installs riding action | 18 / 47 / 0xF1 |
| 131 | (8124,25000,0) | (8192,25000,0) | Still NULL from earlier query | None; native box shove changes X | 18 / 46 / 0xF1 |
| 132 | (8124,25000,0) | (8124,24993.900391,0) | Static floor -220.999771 | RIDING_SHELL_GROUND, CROUCH_SLIDE, QUICKSAND_DEATH | 18 / 45 / 0xF1 |

Re-entering terrain really does resume action dispatch. The Z press requests
CROUCH_SLIDE, but the destination is instant quicksand, and the native
moving-action cancellation requests QUICKSAND_DEATH before useful slide
alignment. The earlier death queue is unchanged. This is not a successful
Ink handoff or a low upper-warp contact.

All three histories were continued for 49 updates, through countdown zero
and the transition that clears Mario's object. At the final recorded
boundary, `sCurrPlayMode` is 4, the Mario object is null, and the pending
operation/source remain 18/0xF1. The recorder deliberately stops there; it
does not claim to have replayed a later castle/death destination arrival.
No Area 2 handoff occurred. Fresh reconstruction matched **147 boundaries**.

The stronger statement that a later normal warp request cannot replace an
already-pending death is a **source deduction**, not an extra runtime warp
request in this test: `level_trigger_warp` writes the operation/source/timer
only inside `if (sDelayedWarpOp == WARP_OP_NONE)`. The test demonstrates the
existing queue surviving genuine terrain recovery without clearing it.
It does not establish a universal impossibility theorem for every possible
engine transition or pre-existing pending-warp state.

## Reproduction and revisions

The [script](../../instrumentation/ink-floorless-shell-entry/search.py)
records all initial and later actor writes, controls, M/C/D, floor/cache,
action events, shell state, and pending-warp state. The canonical output is
`build/wafel-pilot/ink-floorless-shell-entry-20261114.json`, copied unchanged
to [the durable receipt](ink-floorless-shell-entry-receipt.json). The script
performs no broad search and no lower-top setup. It imports the existing
shell preparation helper.

Investigation revision: `77ed7515d9ddce96fe00a030a26aae8663b590b0`.
Decompile HEAD: `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, preserving existing
local instrumentation. The receipt hashes the inspected source and helper.
JP runtime SHA256: `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
Prefix SHA256: `9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.
No Coq statement was added by this runtime subtask. Pending-warp source
guards and any formalization are reported separately from these three
conditional native comparisons.
