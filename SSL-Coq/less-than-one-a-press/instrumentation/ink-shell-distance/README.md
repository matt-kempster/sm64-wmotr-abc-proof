# Shell distance and status: freezing is not distance inactivity

**The native above-water shell does not stop updating merely because Mario
is far away.** The initialized shell lacks the distance-computation flag that
the ordinary object wrapper uses to set FAR_AWAY. A shell frozen by native
fake pickup/release instead stays fixed because its carry script ends at
BREAK. That remains useful at remote coordinates, but it is a different
mechanism from distance deactivation.

This is finite JP Wafel evidence plus a stock-source explanation. It does
not establish arbitrary-coordinate gameplay delivery, a continuous no-A
route, or an original-ROM replay of these new distance/status controls.
It adds no Coq theorem. The parent task's remote-release and full-handoff
experiments are separate evidence.

## Source reason and which Mario position matters

`data/behavior_data.c:2400` sets only UPDATE_GFX_POS_AND_ANGLE for
`bhvKoopaShell`, alongside its physics fields and native callback. The
initialized flags in this runtime are0x40000001, without
OBJ_FLAG_COMPUTE_DIST_TO_MARIO0x40. The shell has no collision-data loader.

`src/engine/behavior_script.c:905–1002` computes distance only when that
flag is present. The generic distance then uses `dist_between_objects`
and the Mario object's raw **Collision C**, not Mario movement M or stored
graphics G. Its later FAR_AWAY/render-distance branch also requires the
flag. For the tested shell, neither branch is entered: the stored distance
field remains its allocation default19000, even when Mario is only400 units
away. A raw logged `oDistanceToMario=19000` is therefore not evidence that
Mario is actually19000 units away or that the shell is sleeping.

`bhv_koopa_shell_loop` has no separate Bob-omb-style4000-unit G-distance
gate. Its free action continues floor/wall handling, yaw, movement, sparkles
and status reset. `cur_obj_move_standard` would skip movement if FAR_AWAY
were already supplied by some other history, but ordinary shell distance
does not set that flag. These tests never write FAR_AWAY or any shell flag.
This does not exclude unrelated flag corruption/time stop/area unloading.

For initialized frozen shells, native non-HOLDABLE pickup/release replaces
the behavior command with carry3/4/5. The stopped command does not execute
the shell callback. The general wrapper still increments `oTimer`; no
expiry is inferred from that increasing timer. Visibility or camera-frustum
culling is not itself object deletion or a physics sleep.

The PLAYER/LEVEL collision scan in `src/game/object_collision.c:115–153`
tests tangibility and the actual raw collision cylinders. It does not apply
the shell's drawing distance or FAR_AWAY as an additional distance cutoff.
A far shell is not globally collidable: Mario still has to overlap its
actual hitbox, and the four-object collision-list capacity still applies.

## Finite distance controls

`check.py` reuses the existing genuine shell initialization and conditional
native fake-pickup/drop/throw helper. The original shell-box spawning action,
pickup-target retargeting and earlier Mario preparation remain disclosed
grants from that helper. No shell type, size, tangibility, status, flags,
velocity or behavior-command write is added by this package.

From one initialized live root and one actual native dropped frozen root,
the new test supplies Mario's initial DISAPPEARED pose at each offset:

* X offsets400,1999,2000,2001,3999,4000,4001 and65536.
* Y offset65536.
* Three initial separation controls: M alone, C alone or G alone is displaced
  by65536 in X while the other positions start400 units away.

Each control advances30 neutral updates, with A released. Some Mario
position discrepancies are subsequently reconciled by native Mario updates;
these are initial separation tests, not a claim that the discrepancies persist.
The test records all M/C/G values and actual distances on every boundary.

All24 histories reproduce independently from two fresh roots. Within each
shell mode, all30 samples of the selected shell projection agree exactly
across every distance/separation control: XYZ, velocity, forward speed,
action/timer, yaw, tangibility/status, flags, stored distance and graph flags.

| Shell | First XYZ | After30 updates | Timer / flags |
|---|---|---|---|
|Live initialized|`(5840.11962890625,968,2505.971923828125)`|`(5841.8310546875,614,2591.5087890625)` in every control|Timer2→32, active257, no FAR_AWAY|
|Native dropped frozen|`(5884.9697265625,51,3394.09765625)`|Unchanged in every control|Timer43→73, active257, no FAR_AWAY|

The drawing-distance field is4000, but the live shell continues falling and
moving even when Mario starts65536 units away horizontally or vertically.
There is no tested4000/2000 threshold at which the shell freezes or deletes.
This is supported by the missing-flag source path, not generalized merely
from a finite sample.

Two further controls begin with a **native throw** to supplied high HOLP,
leaving the frozen shell at `(-1950,67267,-939)`. Mario starts either400 X
units away or65536 away in both X and Y. After180 neutral updates the shell
is still at that exact position, tangible and50×50. A supplied subsequent
FREEFALL pose ten units above it, with a fresh Z edge, still causes native
RIDING_SHELL_GROUND followed by CROUCH_SLIDE. This particular high contact
then becomes GROUND_BONK; it is not a useful handoff or a delayed-ground-riding
bridge. The full four-update contacts are recorded.

New distance/contact coverage is720 +360 +8 = **1088 advanced boundaries**,
excluding the separately recorded initialization/pickup/release preparation.
Both complete reconstructions match every archived value.

## Mount cancellation and reuse

`status.py` adds four low contact histories, independently replayed twice.
Both modes use the native dropped-shell location above. The live comparison
has a single explicit initial shell XYZ relocation; frozen release is native.
Mario's above-contact approach and any second return approach are supplied.
No shell status or action is reset by the experiment.

| Mode and Z timing | Result | Supplied return with fresh Z |
|---|---|---|
|Live, Z during mounting update|CROUCH_SLIDE; shell remains free action0/status0 and alive|Mounts and cancels again|
|Live, Z one update after mount|First update is RIDING_SHELL_GROUND, shell action1; next Z deletes shell natively|No original shell remains|
|Frozen, Z during mounting update|CROUCH_SLIDE; shell remains action0/STOP_RIDING0x400000|Mounts and cancels again|
|Frozen, Z one update after mount|First RIDING_SHELL_GROUND leaves status0xC003; next Z assigns STOP_RIDING0x400000|Mounts and cancels again|

The source explains this timing distinction. `mario_stop_riding_object`
(`interaction.c:280`) assigns STOP_RIDING, clearing INTERACTED, then clears
the ridden reference. Same-update Z therefore removes INTERACTED before
the live shell's free action0 callback sees it; that callback stays action0
and resets status. A later Z reaches native action1, whose STOP_RIDING branch
deletes the live actor. Frozen scripts run neither branch, and STOP_RIDING
alone does not block the next ordinary interaction guard. A neutral update
separates the Z presses in the remount controls.

The original live slot is reused by the third sample of the delayed-Z case.
Its active flag alone must not be interpreted as the old shell reviving;
behavior identity is checked before any remount attempt. These15 advanced
boundaries establish local status behavior, not a repeatable player cycle.

## Practical benefit and limits

Distance itself does not park a normal live shell. A properly initialized
carry-script shell can wait without falling or consuming native movement
updates; the tested180-update wait does not damage its mountability. Its
increasing action timer is not the reason it survives. The frozen state
also survives delayed Z in these controls, whereas a normally ridden live
shell is deleted on delayed dismount. Immediate mount-and-Z can preserve
even the live shell under the tested ordering.

Actual placement still must provide an initialized shell at the correct raw
XYZ, and Mario must reach a compatible action/contact geometry with the
right input edge. Waiting does not supply HOLP, move a warp to a PU, guarantee
floor geometry, or establish useful top timing. These finite controls do not
claim stability through area unloading, slot reuse or every other interaction.

## Reproduce and provenance

From `SSL-Coq/less-than-one-a-press`:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-distance/check.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-distance/status.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-distance/archive.py --verify
```

Proof start: `4adf8faf311d1d271c57f288f51b06bf357874d1`.
Stock JP source pin: `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
Local decompile: `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`.
Wafel0.8.5/Python3.9.13, JP DLL SHA256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The archive pins helper/source dependencies, all setup ledgers, controller
inputs, selected states and action events. No ROM/runtime binary is included.
