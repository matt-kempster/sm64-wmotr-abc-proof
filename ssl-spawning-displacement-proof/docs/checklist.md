# Checklist

- [x] Locate and inspect the existing `ssl-pyramid-item-proof/` structure.
- [x] Verify the JP-only `#ifndef VERSION_JP` guard around
  `clear_mario_platform()` in `spawn_objects_from_info()`.
- [x] Verify `apply_mario_platform_displacement()` reads `gMarioPlatform` and
  calls `apply_platform_displacement(TRUE, platform)` when non-null.
- [x] Verify free-list push/pop order in `deallocate_object()` and
  `try_allocate_object()`.
- [x] Verify `update_objects()` order:
  `clear_dynamic_surfaces`, `update_terrain_objects`,
  `apply_mario_platform_displacement`, collisions, non-terrain objects,
  unload deactivated objects, `update_mario_platform`.
- [x] Count SSL area-2 macro objects from source: 50.
- [x] Record SSL area-2 regular spawn order and Spindel's position after macros.
- [x] Add JP-specific Clight generation targets.
- [x] Add hand-written proof stack for the conditional core theorem.
- [ ] Replace model-level source facts with generated JP Clight `vm_compute`
  facts.
- [ ] Lift the conditional capstone through linked Clight semantics.
- [x] Prove enough allocation/order detail for a concrete SSL route candidate:
  if the stale slot is at depth 60 in the post-unload free list, the 61st
  area-2 allocation is the Spindel allocation.
- [x] Check the outside pyramid top-entry warp against pyramid-top collision:
  the warp is horizontally aligned, but its vertical hitbox `768..818` is below
  the spinning pyramid top's lowest collision Y `1281`, so this seed route is
  impossible as stated.
- [x] Prove the cloned-platform seed route at engine level: a tangible cloned
  exclamation box at the top-entry warp can set `gMarioPlatform`, JP spawning
  preserves the pointer, and the stale slot can feed the area-2 Spindel reuse
  witness.
- [x] Record SSL start-position and area-1 exclamation-box source facts:
  Mario starts at `(653, 38, 6566)` yaw `88`, and the five area-1 exclamation
  boxes are not already at the top-entry warp seed position.
- [x] Check the straightforward fake-object grab/drop cloning route for an
  exclamation box: for a non-holdable box, `obj_set_held_state()` switches the
  executed behavior to `bhvCarrySomething3/4`, which does not load surface
  collision, so this path cannot by itself seed `gMarioPlatform`.
- [x] Check the no-drop fake-object variant at the top-entry warp: if the box is
  already held, `bhvCarrySomething3` does not reload collision after
  `clear_dynamic_surfaces()`; if the pickup would complete while Mario is inside
  the warp, `INTERACT_WARP` is processed before `INTERACT_GRABBABLE` and changes
  Mario to `ACT_DISAPPEARED`, so `act_picking_up()` does not run.
- [x] Generalize the outside seed search from exclamation boxes to all area-1
  source platform kinds: pyramid top, Tox Boxes, and exclamation boxes.
- [x] Model the fixed Area 1 -> Area 2 warps and conservative platform
  bounding boxes for pyramid top, Tox Boxes, and exclamation boxes.
- [x] Prove the conservative fixed-position overlap result: as spawned, none of
  the area-1 source platform bounding boxes overlaps either Area 1 -> Area 2
  warp hitbox.  Because these boxes over-approximate the relevant collision
  extents, this rules out ordinary same-position overlap for the original
  placements.
- [x] Prove the generalized conditional inside theorem: any area-1 source
  platform kind that does set `gMarioPlatform`, and whose stale slot is later
  reused by the area-2 Spindel allocation, feeds the expected Spindel `oVelZ`
  and `oAngleVelPitch` to the first displacement update.
- [x] Prove the generalized transported-geometry witness: if a pyramid top,
  Tox Box, or exclamation box surface could be placed at the top-entry warp,
  its conservative bounding box can overlap that warp hitbox.  This shows the
  remaining problem is source-backed transport/desync, not the inside result.
- [ ] Find or prove a clone/transport/desync mechanism that leaves a standable
  source-platform surface at an Area 1 -> Area 2 warp while placing that slot at
  Spindel's depth-60 allocation position.  This may use pyramid top, Tox Boxes,
  or exclamation boxes; the spawned positions themselves are now ruled out.
- [ ] If no such mechanism exists, reframe the final result as a disproof of
  SSL spawning displacement under the modeled ordinary gameplay assumptions,
  while retaining the conditional inside-pyramid Spindel theorem.
