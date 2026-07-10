# Goal

Prove, or refute under explicit ordinary-gameplay assumptions, the JP spawning
displacement route for Super Mario 64 SSL.

The core engine theorem remains:

1. `VERSION_JP` area spawning does not clear `gMarioPlatform`.
2. `apply_mario_platform_displacement()` trusts the non-null pointer currently
   stored in `gMarioPlatform`.
3. Object free-list reuse can make a deallocated platform slot become the slot
   of a later SSL area-2 object.
4. On the first object update after the transition, platform displacement runs
   before `update_mario_platform()` recomputes the pointer.
5. If the reused object is Spindel on its first active movement tick, the
   displacement uses `oVelZ = 5` and `oAngleVelPitch = 0x100` from that Spindel
   object.  If Spindel is in its rest branch, the useful Spindel fields are
   zero.
6. Even if the stale slot is reused by any audited SSL area-2
   surface/platform object on the first stale update, Mario does not leave the
   top-entry elevator shaft and does not reach the high cage/rim top.  Spindel
   is the only first-load target with useful fields, and its effect is too
   small to escape the shaft.

The core engine/source facts are now backed by generated JP Clight certificates.
`proofs/GeneratedClightFacts.v` proves `vm_compute` facts over the generated
`jp_*.v` modules and packages them as
`generated_jp_clight_source_certificate`.  `proofs/ClightCapstone.v` then proves
`generated_jp_clight_conditional_spindel_capstone` and
`generated_jp_clight_concrete_spindel_depth_capstone`, lifting the conditional
Spindel result through that generated source certificate.  This is a Clight
AST/source-certificate bridge, not a full CompCert small-step execution proof.

`proofs/TargetPlatformEffects.v` now also closes the inside-pyramid target
question for the first stale update.  It enumerates the audited area-2
surface/platform targets: macro exclamation boxes, pyramid elevator, moving
pyramid walls, Spindel, regular Grindel, and horizontal Grindels.  The theorem
`ssl_area2_first_update_platform_displacement_classification` records which
targets have useful first-tick displacement fields, and the only useful
first-load target is Spindel.  The theorems
`ssl_area2_all_first_update_platform_displacements_stay_in_elevator_shaft` and
`ssl_area2_all_first_update_platform_displacements_do_not_reach_cage_top` prove
that all modeled first-tick outcomes remain inside the elevator shaft and do
not put Mario on the cage/rim bars.  The table and source explanation are in
`docs/area2-platform-displacement.md`.

The main open route question is outside the pyramid: can area 1 put Mario in an
Area 1 -> Area 2 warp hitbox while `update_mario_platform()` also sees an
object-owned floor from an area-1 source platform?

The candidate source platforms are:

- `bhvPyramidTop`
- `bhvToxBox`
- `bhvExclamationBox`
- `bhvBreakableBox` for the two large no-coin boxes
- `bhvMessagePanel` for the three wooden signposts
- `bhvCannonClosed` for the cannon lid

Current status: the original spawned positions are ruled out by the conservative
fixed-warp model in `proofs/SourcePlatformOverlap.v`.  The model records both
Area 1 -> Area 2 warp hitboxes and bounding boxes that over-approximate the
source platform collision extents.  It proves that the pyramid top, the three
Tox Boxes, the five area-1 exclamation boxes, the two large breakable boxes, and
the three wooden signposts, and the closed cannon lid do not overlap either warp
as spawned.  The same file also proves that a transported or cloned source
platform surface of any audited kind could have bounding-box overlap with the
top-entry warp if a real gameplay mechanism can place it there.

`proofs/SourcePlatformTransport.v` now checks the ordinary source-backed
mechanisms considered so far.  It models pyramid-top built-in motion, the three
Tox Box action-table path envelopes, fixed large breakable-box positions,
wooden-signpost fixed X/Z positions, exclamation-box collision-loaded motion,
cannon-lid opening motion, the fake-object grab/drop route, and the no-drop
held-box variant.  These modeled mechanisms do not leave a standable
source-platform surface at either Area 1 -> Area 2 warp, so they also cannot
satisfy the full Spindel depth-60 seed route.

`proofs/DesyncMechanismSearch.v` checks the two stronger leads currently under
discussion.  Astral Projection Glitch has the right general flavor only if it
can create a post-copy `gMarioObject->oPos` desync: visible-model desync alone
does not affect the seed checks, because object hitbox collision and
`update_mario_platform()` use `gMarioObject->oPos`, not `header.gfx.pos`.  The
known Chuckya-based APG setup is not available in SSL area 1.  SSL tornado
transportation is also not enough as modeled: Tweesters are not platform
surfaces, they hide when more than 3000 units from Mario, and warp interaction
is processed before tornado interaction, preventing a same-frame
warp-then-tornado-move seed.

The same file now extends the audit to the remaining source-backed post-copy
`gMarioObject->oPos` and clone/corruption opening.  The source census shows
that direct global `gMarioObject->oPos` writes outside the normal
MarioState-to-object sync paths occur only in `butterfly_calculate_angle()`;
that helper uses balanced temporary offsets around `obj_turn_toward_object()`
and restores the Mario object position before returning.  SSL area 1 has no
butterfly or triplet-butterfly source.  On the clone side, the audited source
platform behaviors do not spawn a standable source-platform clone: pyramid top
spawns pillar touch detectors and dirt fragments, Tox Boxes spawn no objects,
exclamation boxes spawn only their fixed contents table, large breakable boxes
only break into loot, wooden signposts spawn no objects, and the cannon lid
spawns a non-surface cannon.

`proofs/ClosedWorldDisproof.v` is now the route-level disproof under explicit
ordinary-gameplay assumptions.  The closed world consists of original spawned
surface overlap, modeled source-platform transport, ordinary Mario-speed
timing, and the investigated desync/clone leads.  `proofs/MarioSpeedWarp.v`
rules out the ordinary-speed loophole: object-warp collision is sampled before
Mario action movement, interactions are processed before action movement
dispatch, and `update_mario_platform()` recomputes the pointer after the action
copy.  Running from a source platform to a warp is therefore too late for that
frame's object collision and clears/recomputes the platform pointer before a
later warp; starting in the warp preempts normal movement with
`ACT_DISAPPEARED`.  The theorem
`no_closed_world_ssl_spawning_displacement_route_to_spindel` proves that no
mechanism in that closed world can both seed `gMarioPlatform` at an Area 1 ->
Area 2 warp and satisfy the Spindel depth-60 allocation obligation.

The castle SSL painting checkpoint route is now modeled separately in
`proofs/CastleCheckpoint.v`.  If Mario dies after entering SSL area 2 through a
checkpoint-setting warp, the checkpoint machinery can redirect the castle SSL
painting entry to SSL area 2.  That makes the destination plausible, but not
the seed: painting entry uses `gMarioState->floor` and requires that floor to
have a painting-warp surface type, while `update_mario_platform()` sets
`gMarioPlatform` only when the selected floor is object-owned.  Under ordinary
synchronized floor selection, standing on an audited castle object surface
prevents the floor from being a painting-warp floor, and the static painting
floor itself has no owning object.  The theorem
`castle_checkpoint_painting_route_cannot_seed_spawning_displacement` rules out
this castle checkpoint route unless a future mechanism supplies a real
floor/position desync or an object-owned painting-warp surface.

The fixed area-1 warps are loaded at level start, so the proof should not assume
that a warp can be transported to an easier platform.  Instead, any positive
route needs an overlap mechanism, clone/transport mechanism, or a carefully
specified Mario-object-position/desync mechanism that makes the same
`gMarioObject` position satisfy both warp interaction and platform-floor
selection.  Any negative result should state the assumptions under which such an
overlap is impossible.  The remaining positive route search is therefore not
"which spawned platform is close enough?", or even "does built-in motion get one
there?", and the direct post-copy writer/source-platform spawned-clone space is
now audited with no candidate found.  A positive route would need a new
mechanism outside the closed world, such as a stronger closed-loop
Mario/object-position desync or a concrete memory-corruption primitive that is
specified precisely enough to add to the model, while still placing an
object-owned platform surface at one of the fixed warps and putting that stale
slot at Spindel's depth-60 free-list position.

The latest pass searched for routes outside the first closed-world enumeration.
The only missed source-backed candidate found was `bhvCannonClosed`; it is now
inside the model and ruled out.  No remaining source-backed positive route
candidate is currently known from the decomp source audit.  The later castle
checkpoint pass did not find a positive route either; it shifts any remaining
castle-based possibility to the same kind of outside-model desync/memory
corruption opening.

The target is still not full star collection.  The target is either:

- a future concrete outside-pyramid seed theorem feeding the already-proved
  inside Spindel reuse result; or
- the current disproof theorem showing that no such outside seed is possible
  under the modeled ordinary-position, fixed-warp, source-platform assumptions.
