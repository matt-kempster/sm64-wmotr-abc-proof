# Claim

In JP SM64, a stale `gMarioPlatform` pointer can survive the outside-to-inside
SSL pyramid area transition.  If the old object slot is reused by an area-2
object before the first object update, then
`apply_mario_platform_displacement()` uses the fields currently stored at that
slot.  It does not first validate that the object is active, loaded, a platform,
owned by Mario's current floor, or the same object Mario stood on previously.

For SSL, Spindel is the most interesting target because active Spindel movement
sets both `oVelZ` and `oAngleVelPitch`; the elevator and moving walls are mostly
vertical displacement targets.

The outside pyramid top remains a valid object-owned seed platform in general,
but not via the top-entry warp while standing on it.  The top-entry warp's
hitbox is horizontally centered near the pyramid top, yet vertically spans only
`768..818`; the spinning pyramid-top collision starts at world Y `1281` and
rises from there.

A cloned or transported surface object removes this vertical mismatch.  In
particular, a tangible exclamation box is an `OBJ_LIST_SURFACE` object, loads
collision, and its action loads that collision model.  If such a cloned box is
placed at the top-entry warp with its scaled top surface at world Y `768`, then
Mario can both overlap the warp and stand on object-owned collision, causing
`update_mario_platform()` to set `gMarioPlatform` to the cloned box slot before
the JP area transition.

The stronger claim from the SSL start is not proved by the usual fake-object
grab/drop cloning path.  SSL area 1 does contain five exclamation-box macro
sources, but none is already at the top-entry warp seed position
`(-2048, 664, -1024)`.  More importantly, when a non-holdable exclamation box is
grabbed/dropped through `obj_set_held_state()`, the executed command stream is
changed to `bhvCarrySomething3`/`bhvCarrySomething4`; those scripts do not reload
the exclamation-box collision model.  The proof records this as
`fake_object_grab_drop_exclamation_box_cannot_seed_platform`.

The no-drop variant also fails at the warp proper under the current source
model.  If Mario is already holding the fake box at the start of the frame, the
box is already executing `bhvCarrySomething3`, so it does not reload collision
after dynamic surfaces are cleared.  If the pickup would complete while Mario is
inside the top-entry warp, the warp interaction is handled before grabbable
interaction and changes Mario to `ACT_DISAPPEARED`; `act_picking_up()` therefore
does not run on that frame.  This is recorded as
`no_drop_fake_box_at_warp_proper_cannot_seed_platform`.

Thus the checked status is: a standable cloned or transported source platform
at the warp is sufficient for the stale-slot Spindel route, but the from-start
route still needs a source-backed clone/transport/desync mechanism that
preserves or restores object-owned surface collision.

The latest source-backed audit did not find that missing mechanism.  Direct
global `gMarioObject->oPos` writes outside the normal MarioState-to-object sync
paths occur only in the butterfly helper, which uses balanced temporary offsets
and is not sourced in SSL.  Pyramid top spawns only pillar detectors and dirt
fragments, Tox Boxes spawn no objects, and exclamation boxes spawn their fixed
contents table rather than a standable source-platform clone.  This narrows the
remaining opening to a new mechanism outside the audited source candidates, or
to a closed-world disproof under explicit ordinary-gameplay assumptions.

The source-platform set itself has been widened from the first notes.  SSL area
1 also has two large no-coin `bhvBreakableBox` surfaces and three
`bhvMessagePanel` wooden signpost surfaces.  A later pass found one more missed
surface candidate, the `bhvCannonClosed` cannon lid.  Their fixed/built-in
positions are also ruled out for both Area 1 -> Area 2 warps, and the cannon lid
only spawns a non-surface cannon when opened.  The current route-level theorem
is therefore `no_closed_world_ssl_spawning_displacement_route_to_spindel`: under
the explicit closed world of original spawned surfaces, modeled source-platform
transport, and investigated desync/clone leads, SSL cannot both seed
`gMarioPlatform` at the warp and place that stale slot at Spindel's depth-60
allocation position.  No remaining source-backed positive route candidate is
currently known from the source audit.
