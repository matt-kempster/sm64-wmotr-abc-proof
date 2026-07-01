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
5. If the reused object is Spindel in an active movement state, the displacement
   uses nonzero `oVelZ` and `oAngleVelPitch` from that Spindel object.

The main open route question is outside the pyramid: can area 1 put Mario in an
Area 1 -> Area 2 warp hitbox while `update_mario_platform()` also sees an
object-owned floor from an area-1 source platform?

The candidate source platforms are:

- `bhvPyramidTop`
- `bhvToxBox`
- `bhvExclamationBox`

Current status: the original spawned positions are ruled out by the conservative
fixed-warp model in `proofs/SourcePlatformOverlap.v`.  The model records both
Area 1 -> Area 2 warp hitboxes and bounding boxes that over-approximate the
source platform collision extents.  It proves that the pyramid top, the three
Tox Boxes, and the five area-1 exclamation boxes do not overlap either warp as
spawned.  The same file also proves that a transported or cloned source
platform surface of any of those three kinds could have bounding-box overlap
with the top-entry warp if a real gameplay mechanism can place it there.

`proofs/SourcePlatformTransport.v` now checks the ordinary source-backed
mechanisms considered so far.  It models pyramid-top built-in motion, the three
Tox Box action-table path envelopes, exclamation-box collision-loaded motion,
the fake-object grab/drop route, and the no-drop held-box variant.  These
modeled mechanisms do not leave a standable source-platform surface at either
Area 1 -> Area 2 warp, so they also cannot satisfy the full Spindel depth-60
seed route.

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

The fixed area-1 warps are loaded at level start, so the proof should not assume
that a warp can be transported to an easier platform.  Instead, any positive
route needs an overlap mechanism, clone/transport mechanism, or a carefully
specified Mario-object-position/desync mechanism that makes the same
`gMarioObject` position satisfy both warp interaction and platform-floor
selection.  Any negative result should state the assumptions under which such an
overlap is impossible.  The remaining positive route search is therefore not
"which spawned platform is close enough?", or even "does built-in motion get one
there?", but "can gameplay create a stronger clone/transport/desync than the
modeled source mechanisms, specifically a source-backed post-copy
`gMarioObject->oPos` desync or memory-corruption clone, placing an object-owned
platform surface at one of the fixed warps while also putting that stale slot at
Spindel's depth-60 free-list position?"

The target is still not full star collection.  The target is either:

- a concrete outside-pyramid seed theorem feeding the already-proved inside
  Spindel reuse result; or
- a disproof theorem showing that no such outside seed is possible under the
  modeled ordinary-position, fixed-warp, source-platform assumptions.
