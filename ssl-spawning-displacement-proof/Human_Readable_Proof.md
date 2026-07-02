# Human-Readable Proof

This document summarizes what the Rocq/Coq project proves about JP SSL
spawning displacement, and the assumptions under which the final route-level
claim is closed.

## Scope

The proof targets Japanese SM64 (`VERSION_JP`) and uses JP-specific CompCert
Clight modules generated under `generated/jp_*.v`.  It does not use the sibling
US Clight artifacts.

The proof has two parts:

1. A positive, conditional engine theorem: if a stale `gMarioPlatform` slot is
   reused by SSL area-2 Spindel, then the first displacement update uses
   Spindel's fields.
2. A closed-world negative route theorem: under the modeled ordinary gameplay
   mechanisms, SSL area 1 cannot create the required platform/warp seed and
   Spindel-depth slot reuse route.

## Source Facts Certified From JP Clight

`generated_jp_clight_source_certificate` proves the central source facts by
`vm_compute` over the generated JP Clight modules:

- JP `spawn_objects_from_info()` does not call `clear_mario_platform()`.
- `apply_mario_platform_displacement()` reads `gMarioPlatform`, calls
  `apply_platform_displacement()`, and does not check `activeFlags`,
  `behavior`, or `collisionData`.
- `update_mario_platform()` uses `find_floor()` and the selected
  `floor->object` to set `gMarioPlatform`.
- `update_objects()` runs platform displacement before `update_mario_platform()`.
- Object unload/allocation contain the expected free-list push/pop source hooks.
- SSL area 2 has 50 macro objects, and the regular area-2 script contains
  Spindel after the macro-spawn phase.
- Spindel behavior data names its collision, loop, and collision-loader command.

## Positive Engine Result

The proof establishes:

- `jp_spawn_preserves_gMarioPlatform`: JP spawning preserves the old platform
  pointer.
- `apply_mario_platform_displacement_uses_stale_pointer`: if the pointer is
  non-null, displacement uses the object fields currently at that address.
- `unload_then_allocate_reuses_same_slot`: unload followed by allocation reuses
  the same object slot in the one-step LIFO case.
- `ssl_spindel_exact_reuse_from_area_unload_depth`: if the stale slot is at the
  correct depth, SSL area-2 Spindel is the allocation that reuses it.
- `generated_jp_clight_concrete_spindel_depth_capstone`: with the generated JP
  Clight certificate, if the stale slot is reused by active Spindel, the first
  displacement update reads Spindel `oVelZ` and `oAngleVelPitch` before
  `update_mario_platform()` recomputes the pointer.

Thus the inside-pyramid mechanism is proved conditionally: a valid outside seed
plus the depth-60 stale slot setup would produce the expected Spindel
displacement effect.

## Outside-Pyramid Route Search

The proof then checks known ways to obtain the outside seed.  A seed requires
Mario to be in an Area 1 -> Area 2 object warp while `update_mario_platform()`
selects an object-owned floor.

The following are ruled out:

- Standing on the spinning pyramid top while entering the top pyramid warp:
  the warp is at Y `768..818`, while pyramid-top collision starts at Y `1281`.
- Original spawned source platforms overlapping either Area 1 -> Area 2 warp:
  pyramid top, Tox Boxes, exclamation boxes, large breakable boxes, wooden
  signposts, and the closed cannon lid do not overlap the warps in the
  conservative bounding-box model.
- Built-in source-platform motion: pyramid-top motion, Tox Box paths,
  exclamation-box collision-loaded motion, fixed breakable boxes, signposts,
  and cannon-lid motion do not put standable source collision at the warps.
- Fake-object grab/drop of a non-holdable exclamation box: the held/dropped
  behavior stream becomes `bhvCarrySomething3/4`, which does not reload the
  exclamation-box surface collision.
- No-drop held-box at the warp: an already-held box is not loading collision,
  and a pickup attempted inside the warp is preempted by warp interaction.
- Ordinary Mario speed: collision with the warp is sampled before normal action
  movement, and `update_mario_platform()` recomputes after action movement, so
  speed alone cannot split the seed and warp positions across frame phases.
- Known APG-style visible desync: visible model position is not enough because
  warp/platform checks use `gMarioObject->oPos`; the known Chuckya APG source is
  absent in SSL area 1.
- SSL Tweester/tornado transportation: Tweesters are not source-platform
  surfaces, have a 3000-unit hide limit, and warp interaction is processed
  before tornado interaction.
- Audited post-copy `gMarioObject->oPos` writers: the only source-backed
  candidate found is the butterfly helper, which restores the offset and has no
  SSL area-1 source.
- Audited source-platform spawned clones: no checked source platform behavior
  spawns a standable source-platform clone; the cannon lid spawns a non-surface
  cannon.
- Castle painting checkpoint route: the checkpoint can redirect the painting to
  SSL area 2, but ordinary painting entry requires a static painting-warp floor,
  while `gMarioPlatform` seeding requires an object-owned floor.

The route-level theorem is
`no_closed_world_ssl_spawning_displacement_route_to_spindel`: within the
enumerated closed world, no route both seeds `gMarioPlatform` at an Area 1 ->
Area 2 warp and places that stale slot at Spindel's depth-60 allocation
position.

## Assumptions

The proof is explicit about these assumptions:

- The generated JP Clight modules faithfully represent the JP source files with
  the documented `VERSION_JP` build flags.
- The Clight bridge is an AST/source-certificate bridge into the model, not a
  full CompCert small-step execution proof of gameplay.
- The free-list depth theorem assumes the modeled unload/allocation order and no
  unmodeled intervening allocation that changes the required depth.
- The positive Spindel capstone assumes Spindel is in an active movement state,
  not its rest state.
- The fixed-position and transport refutations use conservative bounding boxes
  and explicitly modeled movement envelopes.
- The closed-world disproof covers the enumerated source-backed mechanisms:
  original placements, modeled built-in transport, ordinary Mario speed,
  APG/tornado leads, audited post-copy writers, audited spawned clones, and the
  castle checkpoint idea.
- Arbitrary memory corruption, a new post-copy Mario/object-position desync, or
  a new source-backed clone/transport mechanism outside the audit is not ruled
  out by the closed-world theorem.

## Final Conclusion

The JP engine mechanism is real and formally proved conditionally: if a stale
platform slot reaches active SSL Spindel, Spindel's displacement fields are used
on the first update.  What is refuted is the known SSL route to create that
condition under ordinary, source-backed gameplay mechanisms.  Any future
positive route must supply a new mechanism outside the closed world above.
