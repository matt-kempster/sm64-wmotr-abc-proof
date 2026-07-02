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
- `ssl_spindel_first_update_is_active_motion`: the relevant first Spindel
  update is modeled as active movement, with `oVelZ = 5` and
  `oAngleVelPitch = 256` (`0x100`), not the rest state.
- `ssl_spindel_rest_state_has_no_useful_displacement`: if Spindel were in its
  rest branch, the useful fields for this proof, `oVelZ` and
  `oAngleVelPitch`, would be zero.

Thus the inside-pyramid mechanism is proved conditionally: a valid outside seed
plus the depth-60 stale slot setup would produce the expected Spindel
displacement effect.

## Inside-Pyramid Target Effects

The Act 3 "Inside the Ancient Pyramid" star is at `(500, 5050, -500)` in
`levels/ssl/script.c`.  The Mario spawn and target-platform facts are recorded
in `TargetPlatformEffects.v`.

- Spindel starts in active movement on its first update after spawn.  Its first
  useful fields are `oVelZ = 5` and `oAngleVelPitch = 0x100`.
- For the top-entry destination node, Mario spawns at `(0, 5500, 256)`, about
  906 horizontal units and 1012 three-dimensional units from the star.  Applying
  Spindel's first stale displacement gives approximately `(0, 5458, 344)`,
  about 981 horizontal units and 1062 three-dimensional units from the star.
  So the first Spindel displacement moves Mario slightly farther from the star,
  not closer.
- For the lower-entry destination node, Mario spawns at `(0, 300, 6451)`, about
  6969 horizontal units and 8434 three-dimensional units from the star.
  Spindel's first stale displacement leaves him roughly 6927 horizontal units
  away and 8510 three-dimensional units away, still nowhere near the star.
- If Spindel is in its rest branch, spawning displacement still blindly reads
  the pointer, but the modeled useful Spindel fields are zero.  In that state it
  contributes no useful Z velocity or pitch rotation.
- The pyramid elevator is the closest scripted moving target to the star:
  its X/Z matches the top-entry Mario spawn, but on the relevant first update it
  is idle.  Even if the stale platform pointer causes its idle action to
  transition, that same tick does not write useful displacement fields.  Its
  later constant motion is vertical only, and `apply_platform_displacement()`
  does not use `oVelY`.
- Moving pyramid walls are vertical-only targets.  For Mario, this means the
  first displacement update leaves the spawn position unchanged in the simplified
  velocity-component model.
- The upper horizontal Grindel is the next closest moving platform, about 1498
  horizontal units from the star as an object, but Mario remains at the warp
  spawn on the first update because the first horizontal-Grindel update has no
  useful displacement fields.  A later jump can produce horizontal velocity, but
  the stale platform pointer is recomputed after the first displacement update
  unless Mario is actually standing on that object.
- The regular Grindel moves vertically in the checked behavior model, so it does
  not move Mario toward the star through spawning displacement.

These facts support a stronger practical reading: even granting the conditional
engine mechanism, the known SSL area-2 targets do not presently give a clear
theoretical route to collect "Inside the Ancient Pyramid."  Spindel is the only
first-update target with useful Z/pitch fields, and its first displacement moves
top-entry Mario farther from the star; the near-star elevator is not a useful
spawning-displacement target.

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
- The first-update Spindel state is modeled from the source as active movement,
  with a separate rest-state theorem showing that rest would contribute no
  useful Spindel Z/pitch displacement.
- The target-effect model tracks the displacement fields used by
  `apply_platform_displacement()`, not a full floating-point proof of the final
  matrix-rotated Mario position.
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
