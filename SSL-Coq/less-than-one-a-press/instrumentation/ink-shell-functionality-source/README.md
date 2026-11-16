# Why a remotely released shell can still be a shell

15 November 2026. **Freezing the initialized above-water shell's native
behavior does not remove the Mario-side mount handler.** A native fake pickup
and release can preserve its shell interaction type, tangible timer and hitbox
while stopping the callback that would otherwise move it. This is useful for
remote placement. It does not make every raw XYZ a useful handoff location or
establish a player history reaching the required held shell/HOLP.

This review starts at proof `4adf8faf311d1d271c57f288f51b06bf357874d1`.
Applicable stock JP source pin is `9921382a68bb0c865e5e45eb594d9c64db59b1af`;
local decompile is `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. The generated
JP AST files listed below are the formal source objects. The fresh runtime
packages have their own exact setup grants and evidence scope.

## A legitimate SSL shell is not normally carried like a box

The native above-water `bhvKoopaShell` is in `OBJ_LIST_LEVEL`. Its behavior
initializer sets `OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE`, not HOLDABLE, not either
automatic XZ/Y movement flag, and not COMPUTE_DIST_TO_MARIO. The first native
`bhv_koopa_shell_loop` calls `obj_set_hitbox` with type524288, radius50,
height50 and tangibility0. An uninitialized allocation instead starts with
interaction type0 and intangible timer−1.

Normal above-water shell contact invokes `interact_koopa_shell`, which mounts
or nudges Mario. It does not provide an ordinary box-style pickup. The
underwater shell is a different behavior and is not the stock SSL supply
being proposed here. Thus “use a legitimate shell and throw it at HOLP”
still needs a way to make Mario hold that shell. The existing pending-pickup
slot-replacement record supplies a conditional native mechanism for that;
it still grants the shell box's contents-spawning action.

Once the ordinary above-water shell is the actual held target,
`obj_set_held_state` takes its non-HOLDABLE branch on pickup, drop and throw.
It changes the command pointer to carry3, carry4 or carry5 and zeros the
behavior stack index. Those three scripts are `BEGIN; BREAK`; releasing
does **not** restore `bhv_koopa_shell_loop`. The behavior identity can remain
`bhvKoopaShell` while its current command is a frozen carry script. This is
not a hypothetical live shell processing a normal HELD_THROWN callback.

Initialization order matters. If fake pickup freezes the shell before its
first native callback, release does not initialize the missing hitbox/type.
The earlier original-JP pending-slot pair already confirms that failure and
the initialized positive. A shell that is allocated into an already-held
vacant slot can temporarily run its native script; its later native release
still takes the non-HOLDABLE carry-script path. Do not confuse these timings.

Source anchors: `data/behavior_data.c:2400,3925`; `object_helpers.c:267`;
`interaction.c:286–330`; `spawn_object.c:239–285`; and
`behaviors/koopa_shell.inc.c:3,66`. Generated objects include
`jp_behavior_data.v_bhvKoopaShell`, `v_bhvCarrySomething3/4/5`,
`jp_behavior_actions.v_sKoopaShellHitbox`, `f_bhv_koopa_shell_loop`,
`jp_object_helpers.f_obj_set_held_state`, and the actual JP grab/drop/throw
bodies in `jp_interaction`.

## Remote release and parking

The actual Mario throw helper sets raw actor XYZ to

`(HOLP.X + 32*sin(yaw), HOLP.Y, HOLP.Z + 32*cos(yaw))`

using native float arithmetic, sets its movement yaw, then clears heldObj.
The native drop helper uses HOLP.X/Z but **Mario's current movement Y**.
Neither helper translates HOLP Y by a VPU or moves the terrain/warp. A desired
resulting XYZ must account for the throw offset and binary32 rounding.

For the initialized non-HOLDABLE shell, the stopped callback applies no
throw velocity, gravity, floor snap or native shell collision correction
after this release. Inherited velocity fields may remain nonzero without
being integrated. Its surviving wrapper flag only updates graphics position
and angle. A parked frozen shell therefore does not need a nearby physical
floor to keep its raw origin at the release point in these histories.

This is a conditional local statement, not an infinite-lifetime theorem:
other engine writes, unload/area transitions, deletion or pool reuse still
need consideration. No claim covers NaN/infinity, all float magnitudes or
every possible interacting actor. In particular, matching a terrain alias
does not satisfy the actor overlap test at a different actual coordinate.

## What it takes to mount and cancel

1. **Collision membership.** Mario and the shell need actual cylinder
   overlap, tangible timer0 and available slots in their four-entry contact
   arrays. `detect_object_hitbox_overlap` compares raw float X/Z and vertical
   intervals; it does not use the signed-short terrain alias. Its horizontal
   comparison is strict, while equality at a vertical endpoint is accepted.
2. **Interaction eligibility.** The shell's INTERACTED bit must be clear
   when the outer interaction pass reaches it, and an earlier interaction
   must not have ended that pass. The native shell remains on its object
   list; executing carry-script BEGIN does not relink it to another list.
3. **Mount condition.** Mario must not already have RIDING_SHELL. The handler
   accepts WALKING/HOLD_WALKING or `INT_HIT_FROM_ABOVE`. The latter ordinarily
   requires downward velocity and Mario movement Y above the shell, with an
   airborne action whose earlier attack classification has not won.
   Descending TWIRLING/GROUND_POUND is classified as an attack first and is
   not an above-contact mount simply because Mario is above the shell.
4. **Native action creation.** The handler sets used/ridden pointers, marks
   the shell interaction, drops any held object, and requests
   RIDING_SHELL_GROUND even if Mario was airborne. It returns true, ending
   that interaction pass. This is the source of the useful ground action;
   a physical shell floor mesh is not needed or loaded.
5. **Z dispatch.** In `act_riding_shell_ground`, fresh A is tested first.
   With A absent, fresh Z calls `mario_stop_riding_object`, raises forward
   speed to24 if below24, and requests CROUCH_SLIDE **before** this handler's
   ground-step call. The moving-action loop can then dispatch the new slide
   in the same update. Its later slope/step code can change the final action,
   so a final BUTT_SLIDE or bonk is not evidence that mounting was skipped.

Fresh Z is an edge, not merely a held button. No-Z mounting is a different
question: the shell handler's own ground step may return LEFT_GROUND or
HIT_WALL before the next update, changing to shell fall or ground knockback.
The default ceiling20000 can trigger the latter for proposed Y+160≥20000.
Successful local mount/Z does not establish the later fresh768 cache, warp
acceptance, top capture/retention or useful Area2 arrival.

The general post-interaction Mario floor guard also matters: a null floor
can return before action dispatch. Shell collision membership alone is not
a proof that the new ground handler or its Z branch will execute.

Source anchors: `object_collision.c:28–146`; `interaction.c:182–244,
1460–1481,1778–1801`; `mario_actions_moving.c:1200–1229`; and
`behavior_script.c:667–684`. These correspond to the same named generated
JP functions in `jp_object_collision`, `jp_interaction`,
`jp_mario_actions_moving` and `jp_behavior_script`.

## Frozen shells are not automatically one-use

A frozen shell's native status-reset callback does not run. An ordinary
mount can therefore leave INTERACTED set, preventing another interaction
while that bit survives. However, `mario_stop_riding_object` **assigns**
STOP_RIDING (`0x00400000`), rather than OR-ing it into the previous status.
That clears INTERACTED (`0x00008000`) and clears riddenObj. A subsequent
eligible contact can mount again without any editor status reset. The older
clone-isolation record already contains such a supplied-pose recontact;
the current distance study separately tests fresh-Z cycles.

For a live shell, the distinction between immediate and delayed cancellation
also matters. Its action0 callback advances to action1 only if it sees
INTERACTED. Immediate mount+Z can replace that bit before the callback.
The native action1 callback follows Mario and deletes on STOP_RIDING, but
that does not imply every same-update mount/Z shell is deleted. Object-update
order and the action entering the callback must be observed.

## Distance is not what freezes this shell

`cur_obj_update` calculates distance only when COMPUTE_DIST_TO_MARIO (`0x40`)
is present. Otherwise its local distance is zero. Its visibility/FAR_AWAY
branch likewise requires that flag, no collisionData, room−1 and absence of
ACTIVE_FROM_AFAR. A normal initialized above-water shell lacks `0x40`.
Consequently moving Mario away does not normally set FAR_AWAY for this shell.
The cached `oDistanceToMario` may remain the allocation default19000 even
when Mario is nearby; it is not a valid current-distance observation here.

The live shell action0 still performs its native floor/wall updates, movement
and sparkles. It has no Bob-omb-style4000-unit callback gate. Its motion is
therefore not parked just by walking away. The generic movement helper would
skip displacement if FAR_AWAY or IN_DIFFERENT_ROOM were independently set,
but the shell's ordinary distance flags do not establish that premise.
FAR_AWAY would not by itself remove the tangible shell from Mario's player
collision scan anyway; that scan uses actual overlap and intangible state.

The initialized clone's useful inactivity instead comes from the **stopped
carry command**, at near and far distances alike. Native actor movement,
floor queries and status resets stop, while object-wrapper timers and graphics
maintenance can continue. Render culling is another distinct matter and does
not by itself establish behavior inactivity or lack of hitbox collision.
The fresh `ink-shell-distance` packet tests these distinctions at runtime.

## Existing Coq results that apply, and what is not proved

No new lemma or axiom is added here. The existing Main-wired generated-Clight
results already cover the relevant narrow cuts:

* `InkBoxFloor.ibf_scripts_checked` checks the actual three carry initializers.
  `ibf_break_executes_without_erasing_memory` and
  `ibf_every_break_preserves_memory` construct/characterize the real BREAK
  call with empty trace, unchanged entire memory and return1.
* `InkBoxFloorFrame.ibff_clone_suffix_preserves_disjoint_cell` preserves a
  loaded cell, even in the same allocation, across the real post-translation
  script/stack stores when its byte interval does not overlap offsets460/464.
  Shell type304, intangible156, radius504 and height508 are outside those
  stores at an ordinary object base. Valid access, pointer representation and
  the theorem's exact nonoverlap premises still apply. This is the suffix,
  not an unproved claim about arbitrary whole-game initialization/scheduling.
* `InkShellBridge.isb_high_quarter_tail_executes` and the real shell result2
  checkpoint cover the ceiling-stop/knockback branch under stated query and
  execution premises. They do not prove a whole high mount or global failure.
* `InkMarioEntryGuards.imeg_null_floor_bypasses_action_dispatch` constructs
  the actual null-floor early return from the generated guard under concrete
  global/load premises; an action ID alone is not enough.

These are consumed by `MainTheorem.current_ink_box_floor_boundary`,
`current_ink_shell_bridge_boundary` and `current_ink_mario_entry_guard_boundary`.
Their existing audit records are credited, not relabeled as a new audit.
CLAUDE and proof-discipline were read; no proof source was changed and no
new proof build was required for this source review. A universal remote-shell
or reachability theorem would still need initialization, live collision,
action-dispatch, scheduling, finite-coordinate and actor-lifetime invariants.
