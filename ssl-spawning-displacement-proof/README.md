# SSL spawning displacement proof

This project targets the Japanese (`VERSION_JP`) Super Mario 64 behavior behind
spawning displacement.  It is intentionally separate from
`ssl-pyramid-item-proof/`, whose generated Clight artifacts target the US
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

The relevant source platform kinds are `bhvPyramidTop`, `bhvToxBox`, and
`bhvExclamationBox`.  These objects, and the warps, are all loaded from the level
script or macro data at area start, so a proof must either find a real overlap,
prove a source-backed clone/transport/desync mechanism, or rule the route out
under explicitly modeled ordinary-position assumptions.

`proofs/SourcePlatformOverlap.v` now proves the first generalized outside
result.  It models both fixed Area 1 -> Area 2 warp hitboxes and conservative
bounding boxes for all three source platform kinds.  The theorem
`original_area1_seed_platforms_do_not_overlap_area1_to_area2_warps` shows that
the pyramid top, all three Tox Boxes, and all five area-1 exclamation boxes do
not overlap either warp as spawned.  Since these boxes over-approximate the
relevant collision extents, the ordinary fixed-position seed is ruled out at
this level of modeling.

It also proves
`transported_source_platform_kind_bbox_can_overlap_top_entry_warp`: for any of
the three source platform kinds, if gameplay could actually transport or clone
that source platform surface to the top-entry warp height and position, the
coarse platform/warp geometry would no longer block the seed.  This is a
geometry witness only, not yet a source-backed transport route.

The same file also keeps the positive side conditional and generalized.  The
theorem `any_area1_source_platform_seed_feeds_spindel_if_reused` says that if
any area-1 source platform kind does set `gMarioPlatform` and that stale slot is
later reused by the area-2 Spindel allocation, the first displacement update
observes Spindel's active `oVelZ = 20` and `oAngleVelPitch = 1024`.  Thus the
remaining hard problem is outside the pyramid: find or rule out a real
clone/transport/desync mechanism that creates the required platform/warp
overlap while arranging the depth-60 slot reuse.

`proofs/SourcePlatformTransport.v` records the next obstruction layer.  It
models the ordinary source-backed mechanisms considered so far:

- pyramid-top built-in motion;
- all three Tox Box action-table path envelopes;
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
pillar touch detectors and dirt fragments; Tox Boxes do not spawn objects; and
exclamation boxes spawn a fixed contents table of caps, shell, coins, 1-ups,
and stars rather than another standable source-platform object.  The theorem
`no_source_backed_memory_corruption_clone_candidate_found_in_audit` captures
that bounded result.  This is intentionally not a global theorem against
arbitrary memory corruption; it says the source-backed candidates found in this
decomp pass do not provide the missing warp/platform overlap.

## Source configuration

The generated Clight files are JP-specific and live under `generated/jp_*.v`.
They must be regenerated with `VERSION_JP=1` and `F3D_OLD=1`; do not substitute
the US generated files from `ssl-pyramid-item-proof/`.

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
theorem: if the old platform slot is reused by the SSL Spindel and Spindel is in
an active movement state, the first object update applies displacement from
Spindel fields before `update_mario_platform()` recomputes the pointer.

The generated-Clight grounding is kept in the build pipeline and source census.
Future work should replace the remaining model-level source certificates with
`vm_compute` facts over the generated JP modules, following the pattern in
`ssl-pyramid-item-proof/proofs/*Facts.v`.

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
Boxes, and exclamation boxes together.  It proves that none of their original
spawned positions has even bounding-box overlap with either Area 1 -> Area 2
warp, while preserving the conditional Spindel theorem for any future
source-backed seed.

`proofs/SourcePlatformTransport.v` further rules out the modeled ordinary
transport candidates: pyramid-top motion, Tox Box path motion, collision-loaded
exclamation-box motion, fake-object grab/drop, and no-drop held-box behavior.
The remaining open route would need a stronger, source-backed clone/transport
or Mario/object-position desync mechanism than the ones modeled here.

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
pillar detectors and fragments, Tox Boxes spawn nothing, and exclamation boxes
spawn their fixed contents table, not another standable source platform.
