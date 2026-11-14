# A collision-only clone in the native-landing setup

14 November 2026. **Stopping an actor's native behavior does not necessarily
stop its collision from pushing Mario. But an ordinary Crazy Box does not
become an inert collider merely because Mario grabs or throws it.** The
requested collision-only substitution must be labeled separately from a
gameplay-created clone. Its useful outcome is top capture and displacement,
not another large gap followed by the ordinary warp.

This is a source review at proof base
`a1df2746333da67c3d4034eba71ad092fbd4103b`. The inspected decompile checkout
is `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. The seven source files below
have no committed diff from stock revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af`; existing local instrumentation
and build output were preserved. The conclusions use the applicable JP code.
No new Coq statement, global clone classification, or controller route is
claimed by this note.

## Which kind of clone is being discussed?

The source comment in `act_picking_up` describes a pickup animation outliving
its remembered object's unloading, allowing a vacant or newly occupied pool
slot to be grabbed. That identifies a real mechanism; it does not provide
the allocation and pickup history for a requested replacement actor.

`obj_set_held_state` always changes the parent. Its next operation depends
on the actual object's `OBJ_FLAG_HOLDABLE`:

| Existing object | Grab/drop/throw operation | Consequence |
| --- | --- | --- |
| HOLDABLE flag set | Set `oHeldState` to HELD_HELD, HELD_DROPPED or HELD_THROWN | Its native behavior remains selected and can respond to that state. |
| HOLDABLE flag clear | Change `curBhvCommand` to the selected `bhvCarrySomething3/4/5` and clear `bhvStackIndex` | The carry script reaches BREAK instead of running the species callback. |

`bhvJumpingBox` sets HOLDABLE before its ordinary loop. The Crazy Box's held
callback follows Mario, a thrown update calls
`cur_obj_get_thrown_or_placed(40.0f,20.0f,1)`, and a dropped update returns it
to its native free/action-1 behavior. A fake pickup of an initialized
HOLDABLE Crazy Box still takes that HOLDABLE branch. It does not by itself
install the inert carry script.

Conversely, redirecting an initialized Crazy Box directly to a carry script
is a useful **supplied collision-only diagnostic**, but supplies a behavior
state that this ordinary holdable path does not create. Clearing its
HOLDABLE flag would be an additional unproved edit, not a hidden way to
claim a legitimate clone history. The earlier
[clone-lineage review](ssl1-clone-lineage-sizing-review.md) also explains why
a pre-initialization recycled slot does not grant initialized dimensions,
tangibility and interaction type for free.

## A stopped native callback can still push Mario

All six carry scripts contain BEGIN followed by BREAK. Executing that BEGIN
does not move the existing object to another linked list. BREAK also does
not deactivate the object: its current command stays at BREAK on subsequent
updates.

The rest of `cur_obj_update` still runs: timers, selected object-flag effects,
distance/visibility handling and graphics updates are not universally frozen.
An actor with automatic velocity flags can still move after its callback has
stopped. Crazy Box's normal flags are HOLDABLE, COMPUTE_DIST_TO_MARIO and
UPDATE_GFX_POS_AND_ANGLE. They contain neither MOVE_XZ_USING_FVEL nor
MOVE_Y_WITH_TERMINAL_VEL, so this particular carry-script diagnostic has no
automatic velocity integration. Its old velocity may remain stored without
changing its XYZ.

Collision registration is a separate engine pass. A retained active object
in a list checked against Mario, with `oIntangibleTimer == 0`, can retain its
live hitbox and INTERACT_GRABBABLE type. Mario's later `interact_grabbable`
handler can call `push_mario_out_of_object` even though the actor itself has
no native behavior callback. The ordinary grab and subtype guards, earlier
interaction priority, collision capacity and INT_STATUS_INTERACTED check
still apply. Plain grabbable pushing does not itself set INTERACTED; stopping
the callback nevertheless removes the box's usual per-frame status clear,
which matters if another event sets it.

The initialized box in the selected setup has radius75, height125 and down
offset10. With Mario's radius37, horizontal registration requires distance
strictly below112; the grabbable shove uses padding−5 and targets distance107.
The shove also resolves walls and requires a nonnull proposed floor before
committing X/Z. It does not update Mario's stored floor cache. Thus a
collision-only actor can in principle supply the same kind of late cached-floor
push; that capability does not prove the desired actor position or final retry.

## Why merely freezing the earlier box changes this setup

The verified moving-box fragment used box Y1716.883544921875 before behavior
128. Its native callback subsequently raised it to1725.337646484375, making
it overlap for the next update's shove. A stationary collider would not
receive that rise.

There is a source-derived obstruction to repairing this exact timing by
changing only the stationary box's Y while leaving the unperturbed landing
and X/Z fixed. Mario's raw collision bottom is1837.8726806640625 at128 and
1839.883544921875 at129. The box's upper boundary is its Y plus115. Both
horizontal distances at the old box X/Z are within the collision radius.
To miss the first contact below Mario requires the box top below the first
bottom; to make the second contact requires it at or above the higher second
bottom. A fixed top cannot satisfy both. These thresholds are separated by
about2.01 units, not a borderline float equality.

This statement assumes the original, unperturbed landing: an early collision
can change Mario's path, and a different X/Z can change which horizontal
contact occurs. It is not a global exclusion of stationary actors or clone
histories. The runtime substitution must therefore record both altered
landings and later capture, rather than declaring every gap a success.

The separate [finite Wafel substitution test](ink-collision-clone-runtime.md)
checks this carry-script diagnostic. Its1030 recipes comprise six native
controls and1024 frozen cases, including a horizontal-contact refinement.
No case captures the top. The fixed low box misses the required129 contact;
the higher fixed box contacts too early and changes the128 landing. Only
two native controls make the old gap, both followed by the ordinary warp.
Twelve retained histories independently reproduce384 boundaries. These are
finite supplied-state Wafel results, not a new original-ROM clone replay or
a proof excluding every possible clone placement.

## Source anchors and remaining obligation

Relevant source locations at the stated stock pin:

- `src/game/mario_actions_object.c:174–189`: remembered-slot pickup comment.
- `src/game/object_helpers.c:267–286`: held-state branch and script redirect.
- `data/behavior_data.c:1834–1841,3915–3943`: Crazy Box flags and carry scripts.
- `src/game/behaviors/jumping_box.inc.c:3–82`: live hitbox, native movement,
  held/thrown/dropped branches, interaction-status reset.
- `src/engine/behavior_script.c:206–208,667–684,906–1008`: BREAK, BEGIN and
  post-script flag processing.
- `src/game/object_collision.c:25–63,101–145`: independent overlap registration.
- `src/game/interaction.c:288–332,387–401,616–650,1636–1667,1780–1797`:
  release placement, grabbing guards, shove and interaction dispatch.

Throwing copies HOLP Y and offsets HOLP X/Z horizontally by32; dropping uses
Mario's movement Y. Neither generic placement routine alone guarantees an
inert actor. A complete positive answer still needs a legitimate initialized
clone or actor, its placement and collision eligibility, a no-new-A Mario
approach, and a joined continuation that actually captures the top and
reaches useful Area2 displacement. The ordinary-warp predecessor does not
meet that final requirement.
