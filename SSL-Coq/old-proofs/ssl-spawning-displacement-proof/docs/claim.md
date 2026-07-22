# Claim

In JP SM64, a stale `gMarioPlatform` pointer can survive the outside-to-inside
SSL pyramid area transition.  If the old object slot is reused by an area-2
object before the first object update, then
`apply_mario_platform_displacement()` uses the fields currently stored at that
slot.  It does not first validate that the object is active, loaded, a platform,
owned by Mario's current floor, or the same object Mario stood on previously.

For SSL, Spindel is the most interesting first-update target because its first
active movement tick sets `oVelZ = 5` and `oAngleVelPitch = 0x100`.  If it were
in its rest branch, those useful fields would be zero.  The near-star elevator
and the moving pyramid walls are vertical-displacement targets, and the JP
platform displacement helper does not use `oVelY`.

For the top-entry Area 2 destination, Mario spawns at `(0, 5500, 256)`, about
906 horizontal units from the "Inside the Ancient Pyramid" star at
`(500, 5050, -500)`.  The first Spindel stale displacement moves that Mario
position to approximately `(0, 5458, 344)`, about 981 horizontal units from the
star, so the first Spindel effect does not move Mario closer to the star.

The target-platform analysis is now closed for the first stale update inside
SSL Area 2.  All audited area-2 surface/platform targets either provide no
useful displacement fields on that first tick or, for Spindel, provide only the
bounded first active displacement above.  Formally,
`ssl_area2_all_first_update_platform_displacements_stay_in_elevator_shaft`
proves that every modeled first-update result remains inside the top-entry
elevator shaft footprint, and
`ssl_area2_all_first_update_platform_displacements_do_not_reach_cage_top`
proves that none reaches the high cage/rim top.  Thus even a visible spawning
displacement effect in SSL Area 2 does not, in this model, eject Mario from the
elevator shaft or put him on the cage bars.

The central source facts are now checked against generated JP Clight modules.
`generated_jp_clight_source_certificate` packages the JP no-clear spawn fact,
the blind platform-displacement pointer use, update order, free-list hooks, SSL
macro/script facts, and Spindel behavior-data facts.  The linked bridge theorem
`generated_jp_clight_concrete_spindel_depth_capstone` states the conditional
Spindel-depth result using that certificate.  The bridge is deliberately at the
Clight AST/source-certificate level rather than a full small-step gameplay
execution proof.

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
only spawns a non-surface cannon when opened.

Ordinary Mario speed is also ruled out as a way to split the seed and warp
positions across frame phases.  Object collision detection samples the Mario
object before normal Mario action movement; Mario processes warp interactions
before that movement dispatch; and `update_mario_platform()` recomputes the
pointer after MarioState is copied back to the Mario object.  So running from a
source platform into a warp is too late for that frame's collision and gets
recomputed at the warp-side position, while starting in the warp changes Mario
to `ACT_DISAPPEARED` before normal movement can run.  This is formalized as
`ordinary_mario_speed_cannot_replace_platform_warp_overlap`.

Platform selection does not require Mario's action to say that he is
standing.  A fresh pyramid-top pointer requires only that
`gMarioObject->oPos` be within four units of a floor triangle owned by that
top.  At stock node 1E, warp contact and the disappeared floor snap remain too
low for either floor query to return the top.  Because the live-Mario platform
update runs before the delayed transition, it also clears or replaces an old
top pointer.  The focused theorem is
`stock_warp_update_cannot_preserve_or_create_top_pointer`.

A valid stale-slot alias does not change that conclusion.  JP preservation and
front-list reuse can conditionally make an old pointer name a newly allocated
SSL area-1 object, but allocation only changes slot contents.  Node 1E is on a
static, unowned floor, so the preceding `update_mario_platform()` query writes
`NULL`; allocation cannot recreate a pointer from that null global.  This is
`stale_slot_alias_does_not_solve_stock_node1e`.

There is a genuine temporary MarioState/Mario-object split in the update
order.  Platform displacement writes `MarioState.pos`, collision reads the old
Mario-object coordinates, and the later state-to-object copy makes platform
selection read the displaced coordinates.  This is conditionally the right
shape for collision at node 1E and selection at the top.  It still needs a
non-null platform pointer at the start of the warp frame, exactly what the
preceding static-floor query removes.  Warp interaction then selects
`ACT_DISAPPEARED`, so ordinary movement cannot create the split afterward.
The result is `coordinate_desync_does_not_solve_stock_node1e` under the audited
stock writer/lifecycle assumptions.

The current route-level theorem is therefore
`no_closed_world_ssl_spawning_displacement_route_to_spindel`: under the explicit
closed world of original spawned surfaces, modeled source-platform transport,
ordinary Mario speed, investigated desync/clone leads, and the explicit
stock-node stale-alias/coordinate-split candidates, SSL cannot both seed
`gMarioPlatform` at the warp and place that stale slot at Spindel's depth-60
allocation position.  No remaining source-backed positive route candidate is
currently known from the source audit.

The castle SSL painting checkpoint idea is also ruled out under ordinary floor
selection.  The checkpoint can redirect the castle SSL painting entry to SSL
area 2, but the entry still depends on `gMarioState->floor` being a
painting-warp surface.  A platform seed depends on the selected floor having an
owning object.  In the synchronized case, those are the same floor test: the
static castle painting floor has no object owner, and the audited castle
object-owned surfaces are not painting-warp floors.  This is formalized as
`castle_checkpoint_painting_route_cannot_seed_spawning_displacement`.  Any
positive castle checkpoint route would therefore need a genuine post-floor
desync or a new object-owned painting-warp surface outside the audited source
model.

The separate proposal to move the Area 1 node-1E warp through Mario's held
object system is now ruled out under stock control flow.  Warp contact does set
`usedObj` and `interactObj` to 1E, but changes Mario to `ACT_DISAPPEARED` before
the pickup action can call `mario_grab_used_object()`.  Handler ordering also
prevents a same-frame grabbable interaction from rescuing that pointer.  Normal
area loading clears any stale held-slot alias before control, while action zero
leaves Mario uninitialized and unable to execute a drop.

`obj_set_held_state()` can redirect 1E's current behavior command only if
`heldObj == 1E` is already true; it preserves the permanent warp behavior and
does not independently create the missing pointer.  This is formalized by
`generated_jp_clight_node1e_control_flow_capstone`.  The result does not rule
out stale `gMarioPlatform` equality or arbitrary writes outside the enumerated
stock writer set.

The downstream counterfactual is positive.  If `heldObj == 1E` is granted,
grabbing alone leaves the warp hitbox at its prior coordinates, but dropping
the non-holdable object writes new live coordinates while preserving its warp
node parameter, interaction type, hitbox, and permanent behavior.  Contact at
that relocated entrance sets `ACT_DISAPPEARED` but does not itself write
`gMarioPlatform`.  If Mario is standing on an object-owned moving-platform
floor, the normal end-of-frame floor update sets that pointer and repeated
floor selection preserves it through disappearance and the JP load.  Routing
still ends at SSL area-2 node 14 `(0, 5500, 256)`.  This conditional result is
`generated_jp_clight_moved_node1e_platform_seed_capstone`; it does not overturn
the proof that stock control flow cannot obtain the initial held pointer.

The observed hacked pyramid-top test has a second positive engine explanation
that does not require area-2 slot reuse.  Given the supplied runtime identities
Klepto 55, pyramid top 60, and node-1E warp 63, a synchronized pyramid-top
deactivation on the final normal frame can free slot 60 and then reselect its
same-frame collision as `gMarioPlatform`.  The later bulk unload buries 60; its
push-front reversal reaches the three observed slots in the order 63, 55, 60.
If destination allocation reaches 63 but not 60, slot 60 retains the top's
`oAngleVelYaw = 0x1800` and stale origin, which the first JP displacement reads
despite the slot being inactive and free.  This conditional snapshot theorem
is `generated_jp_clight_observed_pyramid_top_slot_capstone`.  It explains the
test result but does not make the relocated warp reachable in stock gameplay.
