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
