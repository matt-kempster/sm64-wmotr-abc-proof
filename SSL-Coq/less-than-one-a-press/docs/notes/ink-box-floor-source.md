# Live large-box floors: loading, movement and cloning

14 November 2026. **The floor is a set of copied world-space triangles, not
an attachment that automatically follows the visible box.** A live large
breakable box normally regenerates those triangles each update. An ordinary
non-HOLDABLE fake pickup changes its behavior to a stopped carry script, so
subsequent normal updates stop regenerating them. There are two important
exceptions to saying that cloning immediately removes the floor: already
loaded triangles can survive the remainder of the pickup update, and active
time stop preserves previously loaded triangles across updates. Neither
exception moves those triangles to a new HOLP/drop position.

This is a source audit, separate from the companion finite runtime checks and
Coq statements. It does not establish a controller-reachable box clone or a
high support delivery route. It refines the earlier
[item source review](ink-air-ground-items-source.md) and
[high solid-support experiment](ink-high-solid-support.md), whose frozen-box
test supplied an already-stopped carry state before collision loading.

## Source and version

Proof checkout at start: `97d870c2d208f8adeb5bae88993d84ee4a9f9f6a`.
Decompile checkout HEAD: `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`.
Stock source pin: `9921382a68bb0c865e5e45eb594d9c64db59b1af`, selecting JP.
Eighteen reviewed source/header/asset files were compared byte-for-byte with
that pin after CRLF normalization and match. The inspected `config.h` adds
only an unrelated default-off instrumentation macro relative to that pin;
the JP dialog time-stop condition itself is unchanged. Existing dirty checkout
files were not reset or edited.

## Three different things that must not be conflated

| State | What it contains | What moving raw box XYZ does |
| --- | --- | --- |
| `Object.collisionData` | Pointer to the immutable model-local collision asset | Does not rewrite the asset. The pointer survives the ordinary fake-pickup setter. |
| `Object.transform` and graphics matrices | A cached object transform, graphics scale, and rendering state | A later loader can rebuild the transform, subject to the `throwMatrix` gate below. Drawing a held box is not collision loading. |
| Dynamic `Surface` records and partition lists | Copied world vertices, normal/plane offset, flags and an owner-object pointer | Does not change their already-computed geometry. A later transform/load is required. |

The asset `breakable_box_seg8_collision_08012D70` has eight vertices: X/Z are
±100 and local Y is 0 or 200. Its 12 triangles use `SURFACE_NO_CAM_COLLISION`.
For the unrotated unit-scale box, two triangles are top floors, two are bottom
ceilings and eight are walls. The camera-exclusion surface type does not remove
the floor from Mario's queries. The stock SSL Area 1 macros instantiate two
large no-coin boxes at `(5900,51,4400)` and `(5900,51,2311)`, so their ordinary
unrotated top is Y=251. The small grabbable box at `(5900,50,3440)` uses a different
behavior and has no such collision-mesh loader.

## How the live floor is populated

The large-box script selects `OBJ_LIST_SURFACE`, sets graphics-position update,
loads the collision asset pointer, sets collision distance 500, initializes its
room, then repeatedly calls `bhv_breakable_box_loop` and
`load_object_collision_model`. There is no `DROP_TO_FLOOR`, no HOLDABLE flag and
no ordinary carried/thrown movement handler. The hitbox initializer also adds
the bookkeeping bit `OBJ_FLAG_30`; saying its flags contain literally only
graphics-update would be inaccurate. That bit is not a movement flag.

The loader requires all of these before generating surfaces:

- `TIME_STOP_ACTIVE` is clear.
- Mario's object-distance is strictly less than collision distance 500.
- `ACTIVE_FLAG_IN_DIFFERENT_ROOM` is clear.

If the stored distance still equals 19000, the loader calculates distance
locally; the stored 19000 is not a measurement of actual separation. Loading
does not depend on a generic HOLDABLE test or a fresh copy of the hitbox.

It transforms the model vertices, parses each triangle, computes its normal
and plane offset, allocates a `Surface`, sets `surface->object` to the current
box, marks it dynamic, and inserts a node into every intersected X/Z cell's
floor, ceiling or wall list. Cell classification uses the normal's Y sign.
These are global surface/node pools shared by all dynamic actors, not private
per-box allocations that travel with the object.

`TerrainData` is signed 16-bit. Transformed coordinates are stored through that
type before triangle construction. Therefore raw actor Y and generated floor
Y are separate quantities, especially in VPUs. The previous exact Y=67277
counterpart already failed to reproduce the high landing; a vertical offset
cannot simply be added to the returned floor height. This audit adds no new
global formula for float32 conversion or height bounds.

## What makes a live floor move

`transform_object_vertices` always uses `&gCurrentObject->transform` for the
collision transform. If `header.gfx.throwMatrix == NULL`, it first rebuilds
that transform from raw `oPosX/Y/Z` and **face** pitch/yaw/roll. It then applies
graphics scale to a temporary matrix and transforms every vertex. If
`throwMatrix != NULL`, it skips the rebuild and uses the cached object
transform. It does **not** dereference `throwMatrix` as the collision matrix.

This is a real guard: changing raw XYZ alone does not guarantee a newly moved
floor if the transform is stale. In the ordinary same-area renderer,
`geo_process_object` clears `throwMatrix` after processing the object, including
the case where view culling prevents its model from being drawn. The generic
inactive-object rendering branch also clears it. An omitted rendering pass,
an area mismatch or some other unproved rendering history cannot be silently
assumed to have done so. `cur_obj_update` itself does not clear this pointer.

A native large box has no parent-transform or set-throw-matrix behavior flag,
and no automatic XZ/Y movement flags. Its ordinary loop updates its hitbox,
model and initialization state; an attack can break/deactivate it. None is a
normal transport path. Thus a supplied XYZ edit can demonstrate how a live
mesh reloads, but it does not prove that gameplay can make that edit.

Held-object rendering is different again. `geo_process_held_object` constructs
a graphics-stack matrix from Mario's pose and the hand offset; the Mario geo
callback records the resulting HOLP. This drawing operation does not update
the held box's raw XYZ, its object collision transform or the dynamic surface
records. The later drop/throw action performs raw position writes.

## What an ordinary fake pickup changes

`mario_grab_used_object` copies `usedObj` to `heldObj` if the latter is null and
calls `obj_set_held_state(..., bhvCarrySomething3)`. The setter assigns the
parent. For HOLDABLE objects it changes `oHeldState`; for this non-HOLDABLE
large box it instead replaces `curBhvCommand` with the selected carry script
and resets `bhvStackIndex` to 0. It does not allocate a second box, copy a floor,
clear the collision-asset pointer, or erase the existing surface pool.

Carry 3, carry 4 and carry 5 all consist of BEGIN followed by BREAK. BEGIN does
not move an existing actor to another linked object list. BREAK returns from
the interpreter without advancing its command pointer; the next update stops
at the same command. Generic timer/flag processing still follows, but the
large box has no surviving movement/transform flags that reload its mesh.
In particular, `OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE` copies raw position into
graphics fields; it does not call the surface loader.

Dropping selects carry 4 and writes X/Z from HOLP but **Y from Mario's movement
position**. Throwing selects carry 5 and writes Y from HOLP, with the usual 32
unit facing offset in X/Z. Neither command restores the original native
large-box loop, and the carry scripts contain no return to a saved callback.
The reset behavior-stack index also prevents treating the previous loop's
stack entry as a normal resume path. Changing move-yaw is not enough to rotate
the native large box's face transform.

Ordinary contact with the large box does not itself select it as a pickup:
it has `INTERACT_BREAKABLE`, not GRABBABLE. Its attack interaction sets
`interactObj`, not `usedObj`. An actual fake-pickup target lineage therefore
remains an additional gameplay obligation. A diagnostic that retargets
`usedObj` must disclose that edit even if the following pickup is native.

## What survives, and for how long

| Case | Floor consequence | What this does not establish |
| --- | --- | --- |
| Fake pickup after this frame's surface pass | Already-loaded world triangles remain queryable for the rest of that frame, absent some further mutation/clear | They are not copied to the hand/HOLP coordinates. |
| Next ordinary object update | `clear_dynamic_surfaces` resets dynamic pool counters to their static bases and clears all dynamic list heads; the carry-script box does not reload its surface | Old bytes or an old cached `floor` pointer are not a newly queryable floor. Other live actors may reuse the same pool slots. |
| `TIME_STOP_ACTIVE` at the next clear | The clear is skipped, preserving the existing partition lists and geometry | The collision loader also skips geometry while active, even if the actor is allowed to update. Moving the owner does not move the floor. |
| Time stop ends | The next non-time-stop clear removes the retained dynamic lists; the stopped carry behavior still has no loader | A fresh carried floor does not reappear merely because play resumes. |

The ordinary update ordering is decisive: clear dynamic surfaces; update
spawners and surface actors; apply Mario platform displacement; detect object
contacts; update the remaining lists including Mario; unload deactivated
objects; update Mario's platform reference. A fake pickup executed by Mario
therefore occurs **after** that update's large-box loader. This explains why
"no floor immediately after cloning" is too strong.

The time-stop test uses `TIME_STOP_ACTIVE` (bit 6), not merely ENABLED (bit 1).
The engine commits ACTIVE from ENABLED at the end of `update_objects`, so
enable/disable timing has an update boundary. Mario may continue updating
when the stop does not include him, but platform displacement itself is
disabled during active time stop. Stock JP has an unfixed generic NPC-dialog
helper that can enable time stop before Mario is ready to speak; this is a
broader-game source possibility, not a demonstrated SSL trigger. SSL Buddy
uses a different readiness-first conversation path. Entering a normal ground
slide may also make Mario dialog-interruptible. No usable SSL time-stop,
clone and high-floor history is supplied by this source deduction.

## Why stale pointers and respawning do not by themselves solve transport

Floor queries use the copied triangle vertices, normal and origin offset.
They do not recalculate the floor from `surface->object->oPosY`. That object
pointer identifies ownership/platform behavior; it is not a live coordinate
binding. Moreover, normal platform displacement adds horizontal velocity and
handles rotations; it does not add a platform's raw Y relocation. The large
box's native zero angular velocity therefore does not turn a HOLP position
write into an automatic lift through this path.

The inspected direct assignments to `curBhvCommand` are object creation,
the held-state setter, and the interpreter saving its current command. An
ordinary drop/throw of the stopped large box offers no restart. Reusing an
object slot is a new lifetime: allocation zeros raw object fields, clears
collision data/platform, initializes its matrix, and clears `throwMatrix`;
creation installs the new behavior. Re-entering an area uses the macro's
original coordinates, subject to respawn flags. A reference search finds
large-box behavior selection in its declaration/definition and fixed macro
presets, not a native child-spawn call at a high parent's position.

Those observations narrow ordinary mechanisms. They are not an invariant
covering every possible allocator alias, malformed command pointer, dynamic
pool overflow or cross-area history. The source contains unchecked pool and
vertex-data operations, so a global impossibility theorem needs explicit
memory-validity and reachable-state obligations rather than an assumption
that such cases never happen.

## Precisely narrowed question

The useful high-floor delivery question is not simply "does cloning preserve
any triangle?" It is whether an allowed history can produce the required
high **world-space** mesh and keep or reload it until Mario's air step uses
it. Ordinary carry-script freezing plus a HOLP relocation does not provide
that reload. Same-frame and time-stop retention are real exceptions, but
preserve a floor that already had to be at the useful coordinates.

A meaningful scoped proof can connect the real generated held-state branch,
carry BREAK execution, dynamic clear and floor-query representation. It must
state whether it covers the remainder of the current update, later ordinary
updates, active time stop or an actual reachable clone history. Proving only
that the old partition is cleared is not a proof that every possible future
history lacks a high support. The full delivery and no-new-A route verdicts
remain open; this source audit alone does not change the subjective estimates.

## Pinned source references

- [Large-box script](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/data/behavior_data.c#L1743), [collision asset](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/actors/breakable_box/collision.inc.c#L4), and [native loop](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/behaviors/breakable_box.inc.c#L3).
- [Dynamic clear, transform and loader](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/engine/surface_load.c#L643); [surface allocation and partition insertion](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/engine/surface_load.c#L36); [floor lookup](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/engine/surface_collision.c#L401).
- [Held-state setter](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_helpers.c#L267), [grab/drop/throw](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L288), [carry scripts](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/data/behavior_data.c#L3925), and [behavior interpreter](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/engine/behavior_script.c#L906).
- [Object update ordering and time-stop commit](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_list_processor.c#L626), [selective time-stop updates](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_list_processor.c#L318), and [platform displacement](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/platform_displacement.c#L95).
- [Object and held rendering](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/rendering_graph_node.c#L805), [HOLP callback](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_misc.c#L547), [allocation/creation](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/spawn_object.c#L206), and [SSL macro placements](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/levels/ssl/areas/1/macro.inc.c#L10).
