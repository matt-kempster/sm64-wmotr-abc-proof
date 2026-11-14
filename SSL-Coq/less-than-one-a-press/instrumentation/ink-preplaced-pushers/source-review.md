# Why both pushers can be placed before the shell mount

The exact earlier Bob and Crazy Box positions work when both are supplied
before update128, without a later item-position edit. The native JP Wafel
record in `../ink-preplaced-pushers-controls/results.json.gz`, case
`both-pre128`, reaches the useful displaced Area2 spawn and matches the
staged witness's Mario boundaries. The control package independently repeats
the complete history. This review explains that observed result from source;
it does not establish transport or claim a new original-ROM replay by itself.

Reviewed proof checkout: `0605d842cedb55151e70952d56064553c4970f60`.
Decompile checkout: `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`; applicable
stock JP source pin: `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
Source paths and line anchors below refer to that local decompile.
Existing context: `docs/notes/ink-enlarged-bob-handoff.md` and its original-ROM
report describe the earlier staged placements and their explicit grants.

## The order is essential

`src/game/object_list_processor.c:644–670` rebuilds dynamic surfaces, applies
Mario's existing platform displacement, detects actor collisions, updates
the remaining object lists, and finally records Mario's platform. The
non-terrain update order at172–182 places PLAYER before GENACTOR before
DESTRUCTIVE. Thus Mario acts before Crazy Box49 and Bob39 run their callbacks.
The top's moving collision has already been loaded for that update.

Actor overlap uses the Mario object's raw Collision coordinates C, not
Movement M. Platform displacement can move M before overlap detection
without first moving C. The relevant coordinates differ again after the
slide stores G and aligns M. Each distance helper must therefore be checked
individually: not every phrase "distance to Mario" names the same vector.

## Bob is paused by high Stored Graphics on update128

The key helper is `is_point_within_radius_of_mario`,
`src/game/obj_behaviors.c:496–502`. It tests actual XYZ against
**`gMarioObject->header.gfx.pos`, G**, with strict squared distance less than
4000 squared. It does not use C or M. `bhv_bobomb_loop`,
`src/game/behaviors/bobomb.inc.c:245`, puts the free/held callback and fuse
increment inside that gate.

After the native shell/Z update128, M=C.Y is1809.206665 but G.Y is still19900.
The preplaced Bob atY1809.206665 is therefore far outside the gate. Its native
patrol step, gravity, hitbox refresh and fuse increment do not run on128.
The record directly confirms its XYZ is unchanged, radius91, fuse170,
action0. Its general action timer nevertheless becomes1: the script wrapper
increments that timer outside the Bob callback at
`src/engine/behavior_script.c:943–951`.

The separate `oDistanceToMario` field reads about120 after128 because the
wrapper computes that field with `dist_between_objects`, using C
(`behavior_script.c:915–917`). That small field value does **not** establish
that the Bob's G-based4000 gate ran. Conflating these two checks would give the
wrong conclusion that preplacement necessarily moves or expires Bob early.

Collision129 therefore sees the same radius91 and position as the staged
positive. Mario's native slide subsequently makes G low. Bob's callback now
runs: patrol uses `object_step`, then the already-expired fuse selects the
exploding action. After129 its record is action3/timer0/fuse171/radius91;
after130 radius65/fuse172. Later scaling, explosion and deletion remain live.
No behavior or fuse freeze is added.

The generic Bob physics is still relevant after the gate opens:
`bobomb_act_patrol` sets speed5 before `object_step`; the latter resolves
walls/floors and gravity (`src/game/obj_behaviors.c:417–461`), can snap Y to a
floor, and applies slope/friction effects. It is not legitimate to model
subsequent Bob positions as a permanently fixed contact cylinder. The
successful record includes those actual updates.

## Crazy Box moves differently, but still works

Crazy Box is `bhvJumpingBox`, a GENACTOR with the normal holdable callback
(`data/behavior_data.c:1834–1840`). Its free update sets scale0.5 and its
native hitbox, updates floors/walls, runs ordinary motion, then runs its
action callback (`src/game/behaviors/jumping_box.inc.c:43–49`). Effective
radius is75, height125, and down-offset10. Hitbox scaling comes from
`src/game/object_helpers.c:2120–2136`.

Unlike the Bob's callback, Crazy Box's partial-update mechanism uses active
flags. The saved pre128 box has flags259, including FAR_AWAY bit2. With that
inherited flag, `cur_obj_move_standard` skips actual motion on128
(`object_helpers.c:1787–1824`), although the free behavior and floor/action
updates still run. At the end of the wrapper, the newly computed distance
to low C clears FAR_AWAY (`behavior_script.c:989–999`). That clearing is too
late to enable movement earlier in the same callback.

The actual recorded box history is:

| Boundary | Box XYZ | Vertical speed | Flags | Cached object floor |
|---|---|---:|---:|---:|
| Supplied before128 | (-2102.720703,1839.447266,-1119.561890) |17.426300|259|inherited|
| After128 | Same XYZ |17.426300|257|768|
| After129 / before contact130 | (-2102.720703,1852.873535,-1119.561890) |16.947861|257|768|
| After130 callback | (-2102.720703,1923.485229,-1119.561890) |12.947861|257|1923.485229|

On129 the inherited velocity17.426300 plus gravity−4 gives the13.426270
increase in position, with Float32 rounding. The action callback then sets
the next vertical speed16.947861; position and the final stored velocity
must not be treated as if they were sampled at the same substep. Gravity−4
comes from the behavior's−400 physics parameter divided by100
(`behavior_script.c:785–789`). There is no horizontal movement in these
recorded callbacks: forward velocity and X/Z velocities remain zero.

Contact130 uses the box's **pre-callback** position atY1852.873535. Its later
callback runs after Mario's useful shove/alignment, and snaps the box to its
fresh dynamic floor1923.485229. That later floor snap cannot retroactively
change the already-processed contact. Ordinary floor/gravity/jump updates
were retained, not compensated away with another edit.

## Why the early box does not steal Bob's interaction

Both actors use GRABBABLE. Player overlap scanning visits GENACTOR before
DESTRUCTIVE (`src/game/object_collision.c:126–144`), so a registered Crazy
Box normally precedes Bob in Mario's collision list. `mario_get_collided_object`
returns the first matching type (`src/game/interaction.c:403`), and
`mario_process_interactions:1784–1797` consumes the type once. There is no
automatic second-GRABBABLE fallback even when the first chosen handler does
not move Mario, or the first actor is already marked INTERACTED.

That is a real constraint, but this setup avoids the conflict by geometry:

- At collision128 Mario is still high; the low pushers are vertically away.
  The recorded list contains only shell71.
- At collision129, C.X/Z is(-1960,-1230). The Crazy Box is about180.459899
  horizontal units away, beyond75+37=112, so it is not registered. Bob is
  about120.060493 away, inside91+37=128. The recorded list is `[39]`.
- At collision130, C.X/Z is(-2117.026855,-1113.008545). The box is now only
  about15.735702 away, inside112. Both actors register, `[49,39]`; normal
  GRABBABLE selection chooses Box49, which is exactly the desired final shove.

FAR_AWAY itself is not an actor-overlap exclusion: the player collision loop
tests tangibility and overlap, rather than using that rendering/motion flag
as a substitute (`object_collision.c:113–123`). The successful contact delay
must therefore be explained by the actual positions, not by calling the box
"inactive" or assuming it cannot collide.

The overlap test is strict horizontally and inclusive at vertical contact
endpoints (`object_collision.c:25–55`). For butt slide, Mario's hitbox is
160 high (`mario.c:1648–1652`; the action lacks SHORT_HITBOX). With the
observed C.Y1839.447266, a box of height125/down-offset10 overlaps vertically
when its origin Y lies between approximately1724.447266 and2009.447266,
including endpoints subject to the actual Float32 tests. The real
Y1852.873535 lies comfortably inside that interval. This is a collision
overlap bound, not a working handoff-height interval.

With the same Mario endpoints, the selected box center has about68.46 units
of horizontal margin before it could enter the129 registration circle, and
about96.26 before leaving the130 circle. These triangle-inequality margins
explain why modest box motion need not upset the contact schedule. They do
not prove that every position inside those margins produces the correct
final push, floor retry or spawning displacement.

## What remains conditional, and where variants can first fail

The exact preplaced history needs no XYZ compensation and no later Mario or
item state edits. Initial shell preparation/high HOLP, the copied released91
Bob profile, the high airborne Mario approach and both initial actor
positions are still supplied. Preplacement removes the two later position
cuts from the local witness; it does not deliver these actors by gameplay.

For another predecessor, check failures in this order:

1. High G must still keep the Bob out of its strict4000 gate on128 if the
   unchanged Bob129 contact profile is being relied upon. Low M/C alone
   does not answer this question.
2. The recorded Crazy Box FAR_AWAY state is part of this fixture. A box
   already active near Mario may move on128. Do not silently zero its speed
   or freeze its callback; replay the real state and inspect the later contact.
3. If the box registers on129, its earlier GRABBABLE slot can suppress Bob.
   If it misses130 vertically/horizontally, the desired final shove is absent.
4. Bob must still register against old C while its push is computed from
   platform-shifted M. An ordinary radius65 Bob fails the exact contact
   geometry even though it is close to M.
5. The producer must really save floor768 before the item interaction. A
   shove's local floor validation does not update Mario's cache, and the
   stopped quarter preserves that earlier cache.
6. Finally verify accepted warp, high-G retry, top capture/retention and
   displaced spawn. A fresh768 cache and gap alone are insufficient, as the
   prior no-final-Box original-ROM control already demonstrates.

Those are scoped source conditions and observed finite-state comparisons.
No general impossibility, height interval or complete controller route is
asserted. No new Coq statement is needed to report this positive runtime test.

## Scoped note on the original-ROM box subtype comparison

The original-ROM comparison reports Crazy Box subtype2 where Wafel
records0, with no subtype write in the experiment. Bit2 is
`INT_SUBTYPE_DELAY_INVINCIBILITY` (`src/game/interaction.h:46`), not
GRABS_MARIO(4), KICKABLE(256), or NOT_GRABBABLE(512). The GRABBABLE handler
reads those other bits, not2 (`interaction.c:1636–1666`). With the observed
BUTT_SLIDE action, `able_to_grab_object:387–400` is false and the same
`push_mario_out_of_object(...,-5)` path is reached. The JumpingBox callback
does not read this subtype bit either.

Thus0 versus2 does not change this named contact/behavior path; it remains an
explicit state difference, not full-state equality. The collision helper
`detect_object_hurtbox_overlap` can set/clear that bit
(`object_collision.c:74–90`), but this review has not traced the cause of the
ROM/Wafel discrepancy and does not attribute it to a particular invocation.
