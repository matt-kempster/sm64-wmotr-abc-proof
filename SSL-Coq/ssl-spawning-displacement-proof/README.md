# SSL spawning displacement proof

This project targets the Japanese (`VERSION_JP`) Super Mario 64 behavior behind
spawning displacement.  It is intentionally separate from
`SSL-Cog/ssl-pyramid-item-proof/`, whose generated Clight artifacts target the US
configuration.

The goal is not to prove a full star route.  The first capstone is the engine
mechanism:

- JP area spawning preserves `gMarioPlatform`.
- `apply_mario_platform_displacement()` uses the current pointer value when it
  is non-null.
- Object deallocation pushes a slot to the front of `gFreeObjectList`, and
  later allocation pops from the front.
- Therefore a JP stale `gMarioPlatform` pointer can survive an area transition
  and then name either stale object memory or a newly allocated object in the
  same slot.
- For SSL, the first pass records the outside seed platforms, the area-2 macro
  count, the regular spawn order, and the Spindel fields that make it the most
  interesting target.

The current route question has shifted toward the outside-pyramid seed.  The
inside-pyramid theorem is conditional and useful: if a stale area-1 platform
slot survives the transition and is reused by area-2 Spindel, the first
displacement update reads Spindel's fields.  The unresolved part is whether SSL
area 1 can actually set `gMarioPlatform` while entering an Area 1 -> Area 2
warp.

That seed requires the same ordinary Mario/object position to satisfy both
conditions:

- overlap one of the fixed Area 1 -> Area 2 warp hitboxes;
- be within 4 units of an object-owned floor from a source platform.

The initial route notes focused on `bhvPyramidTop`, `bhvToxBox`, and
`bhvExclamationBox`.  A later source audit widened the fixed area-1
object-owned surface set to include the large no-coin `bhvBreakableBox` macros
`bhvMessagePanel` wooden signposts, and the `bhvCannonClosed` cannon lid as
well.  These objects, and the warps, are all loaded from the level script or
macro data at area start, so a proof must either find a real overlap, prove a
source-backed clone/transport/desync mechanism, or rule the route out under
explicitly modeled ordinary-position assumptions.

`proofs/SourcePlatformOverlap.v` now proves the first generalized outside
result.  It models both fixed Area 1 -> Area 2 warp hitboxes and conservative
bounding boxes for the audited source-surface kinds.  The theorem
`original_area1_seed_platforms_do_not_overlap_area1_to_area2_warps` shows that
the pyramid top, all three Tox Boxes, all five area-1 exclamation boxes, the two
large breakable boxes, the three wooden signposts, and the closed cannon lid do
not overlap either warp as spawned.  Since these boxes over-approximate the
relevant collision extents, the ordinary fixed-position seed is ruled out at
this level of modeling.

It also proves
`transported_source_platform_kind_bbox_can_overlap_top_entry_warp`: for any
audited source-surface kind, if gameplay could actually transport or clone that
source platform surface to the top-entry warp height and position, the coarse
platform/warp geometry would no longer block the seed.  This is a geometry
witness only, not yet a source-backed transport route.

The same file also keeps the positive side conditional and generalized.  The
theorem `any_area1_source_platform_seed_feeds_spindel_if_reused` says that if
any area-1 source platform kind does set `gMarioPlatform` and that stale slot is
later reused by the area-2 Spindel allocation, the first displacement update
observes Spindel's first active values, `oVelZ = 5` and
`oAngleVelPitch = 256` (`0x100`).  Thus the
remaining hard problem is outside the pyramid: find or rule out a real
clone/transport/desync mechanism that creates the required platform/warp
overlap while arranging the depth-60 slot reuse.

`proofs/SourcePlatformTransport.v` records the next obstruction layer.  It
models the ordinary source-backed mechanisms considered so far:

- pyramid-top built-in motion;
- all three Tox Box action-table path envelopes;
- fixed large breakable-box envelopes;
- fixed wooden-signpost X/Z envelopes, with broad Y because the behavior drops
  them to floor;
- cannon-lid opening motion;
- exclamation-box collision-loaded motion;
- fake-object grab/drop of a non-holdable exclamation box;
- the no-drop held-box variant at the warp proper.

The theorem `modeled_source_platform_transport_mechanisms_do_not_seed_warp`
proves that none of those modeled mechanisms leaves a standable source-platform
surface at either Area 1 -> Area 2 warp.  The theorem
`no_modeled_transport_spindel_depth_route` then lifts that obstruction to the
full route shape: these modeled mechanisms cannot satisfy the seed surface plus
Spindel depth-60 reuse obligation.  This is not a global theorem against every
possible memory-corruption or Mario/object-position desync; it is a
source-backed narrowing of where a positive route would have to come from.

`proofs/DesyncMechanismSearch.v` records the next source audit.  A useful
Mario/object-position route would need a write to `gMarioObject->oPos` after
`bhv_mario_update()` copies `MarioState.pos` into the Mario object and before
`update_mario_platform()` reads the object position.  The direct write census in
`pipeline/source-census.sh` finds only the butterfly helper as a global
`gMarioObject->oPos` writer outside the normal state-sync paths.  That helper
adds temporary offsets only for `obj_turn_toward_object()` and subtracts them
before returning, and SSL area 1 has no butterfly or triplet-butterfly source.

The same audit checks the source-platform clone side.  Pyramid top spawns only
pillar touch detectors and dirt fragments; Tox Boxes and wooden signposts do
not spawn objects; exclamation boxes spawn a fixed contents table of caps,
shell, coins, 1-ups, and stars; large breakable boxes only break into loot; and
the cannon lid spawns `bhvCannon`, which is not a surface platform.  The theorem
`no_source_backed_memory_corruption_clone_candidate_found_in_audit` captures
that bounded result.  This is intentionally not a global theorem against
arbitrary memory corruption; it says the source-backed candidates found in this
decomp pass do not provide the missing warp/platform overlap.

`proofs/MarioSpeedWarp.v` closes the ordinary-speed loophole.  The generated JP
Clight order facts show that object collision detection runs before non-terrain
object updates, `bhv_mario_update()` executes Mario's action before copying
MarioState position back to `gMarioObject`, and `execute_mario_action()`
processes interactions before action movement dispatch.  Therefore ordinary
horizontal speed cannot replace overlap: if Mario runs from a distant source
platform into the warp, the warp collision was sampled too early and
`update_mario_platform()` recomputes at the warp-side position; if Mario starts
inside the non-fading warp and tries to run back onto a platform, the warp
interaction changes Mario to `ACT_DISAPPEARED` before normal action movement.
The theorem is `ordinary_mario_speed_cannot_replace_platform_warp_overlap`.

`proofs/ClosedWorldDisproof.v` combines those obstruction layers.  Its theorem
`no_closed_world_ssl_spawning_displacement_route_to_spindel` says that no route
in the explicit closed world can both seed `gMarioPlatform` at an Area 1 ->
Area 2 warp and satisfy the Spindel depth-60 reuse obligation.  The closed world
is the union of original spawned surfaces, modeled source-platform transport,
ordinary Mario speed, and the investigated desync/clone mechanisms.  The
conditional inside-pyramid Spindel theorem remains available for any future
mechanism outside that set.

`proofs/CastleCheckpoint.v` handles the separate castle-painting checkpoint
idea.  The source confirms that an active SSL checkpoint can redirect the castle
SSL painting entry to SSL area 2, so this is a real full-level entry path rather
than the outside-pyramid Area 1 -> Area 2 transition.  However, painting entry
is gated by `gMarioState->floor` having a painting-warp surface type, while
`update_mario_platform()` can set `gMarioPlatform` only from a floor whose
`floor->object` is non-null.  Under the ordinary synchronized floor model, the
same floor cannot be both the static castle painting-warp floor and one of the
audited object-owned castle surfaces.  The theorem
`castle_checkpoint_painting_route_cannot_seed_spawning_displacement` therefore
rules out the castle checkpoint route for the audited ordinary mechanisms.  A
positive route would need a stronger floor/position desync or a new object-owned
painting-warp surface, neither of which is present in the current source-backed
model.

## Source configuration

The generated Clight files are JP-specific and live under `generated/jp_*.v`.
They must be regenerated with `VERSION_JP=1` and `F3D_OLD=1`; do not substitute
the US generated files from `SSL-Cog/ssl-pyramid-item-proof/`.

The Makefile searches for the SM64 decompilation source in the same locations
as the sibling proof project.  Override it with:

```sh
make SM64=/path/to/sm64 generated
```

The JP Clight flags used by the Makefile are:

```text
-normalize -nostdinc -fstruct-passing
-I$(SM64)/include
-I$(SM64)/build/jp
-I$(SM64)/build/jp/include
-I$(SM64)/src
-I$(SM64)/src/game
-I$(SM64)
-I$(SM64)/include/libc
-DVERSION_JP=1
-DF3D_OLD=1
-D_FINALROM=1
-DTARGET_N64=1
-DNON_MATCHING=1
-DAVOID_UB=1
-D_LANGUAGE_C=1
```

## Included C modules

The JP generation targets cover:

- `src/game/platform_displacement.c`
- `src/game/object_list_processor.c`
- `src/game/spawn_object.c`
- `src/game/area.c`
- `src/game/level_update.c`
- `src/game/mario.c`
- `src/game/interaction.c`
- `src/game/object_helpers.c`
- `src/game/mario_actions_object.c`
- `src/game/mario_actions_cutscene.c`
- `src/game/mario_actions_submerged.c`
- `src/game/mario_step.c`
- `src/engine/surface_load.c`
- `src/game/macro_special_objects.c`
- `src/game/behavior_actions.c`
- `src/game/obj_behaviors.c`
- `data/behavior_data.c`
- `src/engine/level_script.c`
- `levels/ssl/script.c`
- wrapper inputs for `levels/ssl/areas/1/macro.inc.c`,
  `levels/ssl/areas/2/macro.inc.c`, and `include/macro_presets.inc.c`

## Build

Use the same opam switch as the existing proof:

```sh
source pipeline/env.sh
make generated
make proofs
bash pipeline/check.sh
```

## Current proof shape

The hand-written files under `proofs/` mirror the sibling project's style:
small AST walkers, a compact specification/model layer, and named theorems for
each source fact.  The current capstone is conditional rather than a full route
theorem: if the old platform slot is reused by SSL Spindel, the modeled first
object update is Spindel's active divisor-4 movement state, so platform
displacement observes `oVelZ = 5` and `oAngleVelPitch = 0x100` before
`update_mario_platform()` recomputes the pointer.  A separate rest-state theorem
shows that resting Spindel would contribute no useful Spindel Z/pitch
displacement.

`proofs/TargetPlatformEffects.v` also records the Mario-centered target facts.
The top-entry Area 2 destination spawns Mario at `(0, 5500, 256)`, about 906
horizontal units from the Act 3 star at `(500, 5050, -500)`.  Applying the first
Spindel stale displacement gives approximately `(0, 5458, 344)`, about 981
horizontal units from the star.  Thus the first Spindel effect is real, but it
does not move Mario closer to "Inside the Ancient Pyramid."

That top-entry spawn is airborne above the pyramid elevator, not on a pyramid
floor.  The elevator is at `(0, 4966, 256)`, its modeled top surface is at
world `y = 5222`, and the top-entry Mario spawn shares its X/Z while sitting
`278` units above that top surface.

The generated-Clight grounding is now explicit.  `proofs/GeneratedClightFacts.v`
exports `generated_jp_clight_source_certificate`, a `vm_compute` certificate
over the JP `generated/jp_*.v` modules for the central source facts: JP spawn
does not call `clear_mario_platform()`, platform displacement reads
`gMarioPlatform` and does not check active flags/behavior/collision data, the
`update_objects()` call order puts displacement before `update_mario_platform`,
free-list deallocation/allocation functions contain the expected source hooks,
the SSL area-2 macro count is 50, the area-2 script contains the Spindel target,
and the generated behavior data links Spindel collision, loop, and collision
loader commands.

`proofs/ClightCapstone.v` is the linked source-certificate bridge.  The theorem
`generated_jp_clight_conditional_spindel_capstone` supplies the generated JP
Clight certificate to the conditional Spindel theorem, and
`generated_jp_clight_concrete_spindel_depth_capstone` does the same for the
depth-60/61st-allocation version.  This is intentionally a Clight AST/source
certificate bridge into the existing model, not a full CompCert small-step
execution proof of a gameplay route.

## Pyramid top entry warp

`proofs/PyramidTopWarp.v` records the source constants for the outside pyramid
top-entry warp and pyramid-top collision.  The warp is horizontally aligned with
the pyramid top, but its hitbox is only the vertical interval `768..818`.  The
pyramid-top collision's lowest world Y is `1281` at home and only rises while
spinning, so the checked theorem
`cannot_enter_top_entry_warp_while_standing_on_spinning_pyramid_top` shows this
particular warp cannot be entered while `update_mario_platform()` is selecting
the spinning pyramid-top surface.

## Cloned platform entry route

`proofs/ClonedPlatformWarp.v` proves the engine route that bypasses that height
mismatch.  A cloned tangible exclamation box placed at the top-entry warp can
load object-owned collision there; its scaled top surface can sit at world
Y `768`, inside the warp's `768..818` hitbox.  In that state,
`update_mario_platform()` selects the cloned box slot, JP area spawning
preserves the pointer, and the existing SSL allocation-depth theorem can feed
that stale slot to the area-2 Spindel allocation.

The capstone theorem is
`cloned_platform_route_can_feed_spindel_displacement`.  It is a concrete engine
witness for the cloned-platform seed route.

`proofs/SSLStartCloneRoute.v` records the current source-backed status of the
stronger from-start route.  SSL starts Mario at `(653, 38, 6566)` with yaw `88`.
Area 1 has five exclamation-box macro sources:

- wing-cap box at `(6900, 350, -5400)`
- wing-cap box at `(-3000, 500, 800)`
- koopa-shell box at `(5840, 940, 2500)`
- wing-cap box at `(5860, 940, 4180)`
- running-1up box at `(-1200, 500, 800)`

None of those boxes spawns at the top-entry warp seed position
`(-2048, 664, -1024)`, so an actual route must produce or transport a standable
box there.

The straightforward fake-object grab/drop route does not currently prove that.
For non-holdable objects, `obj_set_held_state()` replaces the executed behavior
command stream with `bhvCarrySomething3` when grabbed and `bhvCarrySomething4`
when dropped.  Those carry scripts are default-list `BREAK` scripts and do not
call `load_object_collision_model()`.  The checked theorem
`fake_object_grab_drop_exclamation_box_cannot_seed_platform` captures the
persistent grab/drop obstruction.

The no-drop idea has a narrower, frame-order obstruction at the top-entry warp.
If the fake exclamation box is already held at the start of the frame, it is
already executing `bhvCarrySomething3`, so its collision does not reload after
`clear_dynamic_surfaces()`.  If Mario is instead positioned at the warp proper
on the frame when the fake-object pickup would complete, `INTERACT_WARP` is
processed before `INTERACT_GRABBABLE`; the non-fading warp sets
`ACT_DISAPPEARED`, so Mario runs the cutscene action group rather than
`act_picking_up()`.  The checked theorem
`no_drop_fake_box_at_warp_proper_cannot_seed_platform` records this obstruction.

To prove a full from-start route, the remaining gameplay obligation is now
generalized beyond exclamation boxes: find a clone/transport/desync mechanism
for any source platform kind that leaves object-owned platform collision at an
Area 1 -> Area 2 warp, while also arranging the stale slot at depth 60 for
Spindel reuse.  If that cannot be done under ordinary gameplay assumptions, the
project should pivot to a disproof of SSL spawning displacement outside the
pyramid, while keeping the conditional inside-pyramid Spindel result as the
expected consequence of any hypothetical outside seed.

`proofs/SourcePlatformOverlap.v` extends that route search to pyramid top, Tox
Boxes, exclamation boxes, large breakable boxes, wooden signposts, and the
cannon lid together.  It proves that none of their original spawned positions
has even bounding-box overlap with either Area 1 -> Area 2 warp, while
preserving the conditional Spindel theorem for any future source-backed seed.

`proofs/SourcePlatformTransport.v` further rules out the modeled ordinary
transport candidates: pyramid-top motion, Tox Box path motion, collision-loaded
exclamation-box motion, large breakable-box fixed position, wooden-signpost
fixed X/Z position, fake-object grab/drop, and no-drop held-box behavior.
`proofs/MarioSpeedWarp.v` adds that ordinary Mario speed cannot bridge the
distance either: collision is sampled before action movement, and the platform
pointer is recomputed after action movement.  The closed-world theorem now
packages these negatives; any remaining positive route would need a stronger,
source-backed clone/transport or Mario/object-position desync mechanism than
the ones modeled here.

After that theorem was introduced, one outside-closed-world source-platform
candidate was found: the closed cannon lid.  It has now been folded into the
model and ruled out.  Its collision is a flat lid at the far cannon macro, its
opening motion only drops slightly and slides in X before deactivation, and the
spawned cannon is `OBJ_LIST_LEVEL`, not `OBJ_LIST_SURFACE`.

`proofs/DesyncMechanismSearch.v` investigates the stronger leads currently
under discussion:

- Astral Projection Glitch-style desync.
- SSL Tweester/tornado transportation by rapid home oscillation.
- post-copy `gMarioObject->oPos` writers found by source census.
- source-platform spawned clone/corruption candidates.

The useful desync shape would have to affect `gMarioObject->oPos` after
`copy_mario_state_to_object()`, because object hitbox collision and
`update_mario_platform()` both use the Mario object position.  A visible model
desync through `header.gfx.pos` alone is not enough.  The known
Chuckya-based APG setup is not present in SSL area 1, so this lead does not
currently provide a source-backed route.

Tweester transportation is also not enough in the current model.  Tweesters are
`OBJ_LIST_POLELIKE` tornado interaction objects, not source platform surfaces;
they hide when more than 3000 units from Mario; and `INTERACT_WARP` is processed
before `INTERACT_TORNADO`, so a successful warp collision prevents a same-frame
tornado move from setting up `gMarioPlatform`.  The checked theorem is
`investigated_desync_mechanisms_do_not_currently_seed_overlap`.

The post-copy `gMarioObject->oPos` census leaves only
`butterfly_calculate_angle()` as a direct global Mario-object position writer.
That code temporarily offsets `gMarioObject->oPos`, calls
`obj_turn_toward_object()`, then restores the position before returning; SSL
area 1 also has no butterfly or triplet-butterfly source.  The clone/corruption
audit checks the source platform behaviors themselves: pyramid top only spawns
pillar detectors and fragments, Tox Boxes and signposts spawn nothing,
exclamation boxes spawn their fixed contents table, and large breakable boxes
only break into loot; the cannon lid only spawns the non-surface cannon.

`proofs/ClosedWorldDisproof.v` is the current route-level conclusion:
`no_closed_world_ssl_spawning_displacement_route_to_spindel` refutes the
Spindel-depth route under the closed-world assumption that the seed must arise
from one of the enumerated spawned-position, modeled-transport, ordinary-speed,
or investigated desync/clone mechanisms.

## Node 1E held-object route

`proofs/Node1EWarpControlFlow.v` closes the separate proposal of relocating the
Area 1 node-1E warp through Mario's held-object system.  Touching 1E really does
set `interactObj` and `usedObj` to the warp object, but it also sets
`ACT_DISAPPEARED` before Mario action dispatch.  The pickup action therefore
cannot copy that transient pointer to `heldObj`, and a simultaneous grabbable
collision is later in the interaction table and is skipped after the successful
warp handler.

The proof also grants the strongest stale-held-slot premise.  Even if area
loading makes an old held pointer alias the newly allocated node-1E slot,
normal `init_mario()` clears it before a controllable update.  Setting Mario's
action to zero skips that clear only by also skipping destination Mario
initialization and action execution.  Finally, `obj_set_held_state()` can
mechanically redirect a non-holdable 1E object's current command, but every
direct stock caller is one of Mario's grab, drop, or throw helpers and already
operates on `heldObj`; this is a consequence of the missing alias, not an
independent route.  The same warp preemption applies to the special Bowser
pickup action, which also calls the common grab helper only when dispatched.

The source bridge is
`generated_jp_node1e_control_flow_source_certificate`, proved by `vm_compute`
over the generated JP interaction, Mario, object-helper, object-action,
cutscene-action, submerged-action, spawn, level-update, behavior-data, and
behavior-action modules.  The capstone is
`generated_jp_clight_node1e_control_flow_capstone`.  Full details and scope are
in `docs/node1e-held-object-disproof.md`.

`proofs/MovedWarpPortal.v` separately answers what would happen if the missing
`heldObj == 1E` premise were granted.  Grabbing alone does not change 1E's live
coordinates.  Dropping writes X/Z from Mario's held-object-last-position and Y
from Mario's position, while preserving the warp node parameter, interaction
type, hitbox, and permanent behavior.  Thus a drop can mechanically relocate
the live entrance for its first contact, even though stock control flow cannot
produce the required held pointer.

Warp contact sets `usedObj`, `interactObj`, and `ACT_DISAPPEARED`; it does not
write `gMarioPlatform`.  However, if Mario contacts the relocated entrance
while standing on an object-owned moving-platform floor, the normal
end-of-frame `update_mario_platform()` call sets `gMarioPlatform` to that floor
owner.  Re-selecting the same floor preserves the seed through any number of
modeled disappearance frames, and JP spawning preserves it across the area
load.  The source-side disappearance keeps Mario's X/Z at the live entrance,
while routing uses 1E's node parameter and destination Mario initializes at SSL
area-2 node 14, `(0, 5500, 256)`.  Moving 1E therefore moves the entrance, not
the destination.  The conditional capstone is
`generated_jp_clight_moved_node1e_platform_seed_capstone`.

## Pyramid-top slot persistence

`proofs/PyramidTopSlotPersistence.v` explains the observed Area 1 pool slots
Klepto 55, pyramid top 60, and node-1E warp 63.  Pool-slot numbers are runtime
allocation-history facts; object-list numbers are traversal categories.  JP
behavior data places those objects in lists 4, 9, and 6 respectively.

The area unload scans lists 0 through 12 and every deallocation pushes to the
free-list front.  Consequently a pyramid top freed normally in the list-9 bulk
pass would be *ahead* of the list-6 warp, not behind it.  The snapshot pattern
is instead explained by synchronizing pyramid-top deactivation with the last
normal object-update frame before the area-change pause.  The top is freed,
its collision loaded earlier in that same terrain pass can still be selected
by `update_mario_platform()`, and then the pause prevents another platform
recomputation.  The later bulk unload pushes the remaining Area 1 slots ahead
of slot 60.

The formal free-list layout proves that if the bulk sequence contains Klepto
55 before warp 63, destination allocation reaches the three slots in the order
63, 55, 60.  Thus 63 can be overwritten while 55 and 60 remain free.  Unload
does not clear object `rawData`; allocation does.  An unreused slot 60 therefore
retains the top's fully accelerated `oAngleVelYaw = 0x1800`, and the first JP
Area 2 displacement reads it despite `activeFlags == 0`.  The generated-Clight
capstone is `generated_jp_clight_observed_pyramid_top_slot_capstone`; detailed
scope and timing assumptions are in
`docs/pyramid-top-slot-persistence.md`.

Generating `jp_object_helpers.v` translates seven CompCert-unsupported C
`long double` constants as `double`; all are outside the audited
`obj_set_held_state()` function.  The compatibility step is isolated in
`pipeline/clightgen-long-double-as-double.sh` and leaves the source tree
unchanged.
