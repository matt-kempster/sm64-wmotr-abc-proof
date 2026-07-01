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

To prove a full from-start route, the remaining gameplay obligation is a
clone/transport mechanism that leaves the object executing `bhvExclamationBox`
action 2, or otherwise reloads equivalent object-owned surface collision at the
warp, while also arranging the stale slot at depth 60 for Spindel reuse.
