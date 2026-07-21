# Checklist

- [x] Locate and inspect the existing `SSL-Cog/ssl-pyramid-item-proof/` structure.
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
- [x] Replace the core model-level source facts with generated JP Clight
  `vm_compute` facts.  `proofs/GeneratedClightFacts.v` now exports
  `generated_jp_clight_source_certificate`, which checks the JP spawn/no-clear
  fact, platform-displacement trust facts, update order, free-list source
  hooks, area macro counts, SSL script behavior entries, and Spindel behavior
  data against the generated `jp_*.v` modules.
- [x] Lift the conditional capstone through the generated JP Clight certificate.
  `proofs/ClightCapstone.v` proves
  `generated_jp_clight_conditional_spindel_capstone` and
  `generated_jp_clight_concrete_spindel_depth_capstone`.  This is a linked
  Clight/source-certificate bridge into the existing model theorem, not a full
  CompCert small-step execution proof.
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
- [x] Generalize the outside seed search from exclamation boxes to the audited
  area-1 source-surface kinds: pyramid top, Tox Boxes, exclamation boxes, large
  breakable boxes, wooden signposts, and the closed cannon lid.
- [x] Model the fixed Area 1 -> Area 2 warps and conservative platform
  bounding boxes for pyramid top, Tox Boxes, exclamation boxes, large breakable
  boxes, wooden signposts, and the closed cannon lid.
- [x] Prove the conservative fixed-position overlap result: as spawned, none of
  the area-1 source platform bounding boxes overlaps either Area 1 -> Area 2
  warp hitbox.  Because these boxes over-approximate the relevant collision
  extents, this rules out ordinary same-position overlap for the original
  placements.
- [x] Prove the generalized conditional inside theorem: any area-1 source
  platform kind that does set `gMarioPlatform`, and whose stale slot is later
  reused by the area-2 Spindel allocation, feeds the expected Spindel `oVelZ`
  and `oAngleVelPitch` to the first displacement update.
- [x] Prove the generalized transported-geometry witness: if any audited
  source-surface kind could be placed at the top-entry warp, its conservative
  bounding box can overlap that warp hitbox.  This shows the remaining problem
  is source-backed transport/desync, not the inside result.
- [x] Check the source platform built-in motion routes.  The pyramid top only
  oscillates slightly in X and then rises/spins; Tox Boxes follow bounded
  table-driven paths; exclamation boxes load collision only while at their
  source position; large breakable boxes are fixed; wooden signposts are fixed
  in X/Z after `DROP_TO_FLOOR`; the cannon lid only drops slightly and slides in
  X before deactivating.  The theorem
  `modeled_source_platform_transport_mechanisms_do_not_seed_warp` proves these
  modeled routes do not leave a standable source-platform surface at either
  Area 1 -> Area 2 warp.
- [x] Prove that the modeled transport/clone routes cannot satisfy the full
  Spindel-depth seed obligation.  The theorem
  `no_modeled_transport_spindel_depth_route` rules out the current modeled
  mechanisms before the free-list depth condition can matter.
- [x] Check the ordinary Mario-speed loophole.  Generated JP Clight order facts
  show object collision detection occurs before non-terrain/Mario action
  updates, `execute_mario_action()` processes interactions before normal action
  movement dispatch, and `bhv_mario_update()` copies MarioState back to
  `gMarioObject` before `update_mario_platform()`.  The theorem
  `ordinary_mario_speed_cannot_replace_platform_warp_overlap` rules out using
  speed alone to stand on a distant source platform and still trigger an
  Area 1 -> Area 2 object warp with the stale platform pointer intact.
- [x] Check whether standing state is required and whether a stale top pointer
  can survive touching stock node 1E.  Only `gMarioObject->oPos` proximity to
  an owned floor matters, not Mario's action.  However, `ACT_DISAPPEARED`
  snaps the stock-warp contact position to a floor far below the top, and the
  same normal update clears or replaces any prior top pointer.  The focused
  theorem is `stock_warp_update_cannot_preserve_or_create_top_pointer`.
- [x] Investigate Astral Projection Glitch as a Mario/object-position desync
  lead.  The proof records that visible-model desync alone is ignored by the
  seed checks: object hitbox collision and `update_mario_platform()` use
  `gMarioObject->oPos`, while the visible model uses `header.gfx.pos`.
  A useful route would need a post-copy `gMarioObject->oPos` desync.  The known
  Chuckya-based APG setup is unavailable in SSL because SSL area 1 has no
  Chuckya source.
- [x] Investigate SSL tornado transportation / rapid home oscillation.  The
  proof records that Tweesters are `OBJ_LIST_POLELIKE` interaction objects, not
  source platform surfaces, and that they hide once farther than 3000 units from
  Mario.  It also records that `INTERACT_WARP` is processed before
  `INTERACT_TORNADO`, so a warp collision preempts a same-frame tornado move.
- [x] Prove the checked desync-search obstruction:
  `investigated_desync_mechanisms_do_not_currently_seed_overlap`.
- [x] Audit the remaining source-backed post-copy `gMarioObject->oPos` and
  clone/corruption opening.  The direct write census finds only the butterfly
  temporary-offset helper outside normal state-sync writes; it restores
  `gMarioObject->oPos` before returning and SSL has no butterfly source.
  Pyramid top spawns only detector/fragment children, Tox Boxes spawn no
  objects, exclamation boxes spawn only their fixed contents table, large
  breakable boxes only break into loot, wooden signposts spawn no objects, and
  the cannon lid spawns a non-surface cannon.  The theorem
  `investigated_desync_mechanisms_do_not_currently_seed_overlap` now includes
  these audited candidate families.
- [x] Resolve the clone/transport/desync route search for a standable
  source-platform surface at an Area 1 -> Area 2 warp while placing that slot at
  Spindel's depth-60 allocation position.  This may use pyramid top, Tox Boxes,
  exclamation boxes, large breakable boxes, wooden signposts, or the cannon
  lid.  No positive mechanism was found in the source-backed set considered
  here.  The spawned positions, modeled built-in/fake-object transport routes,
  ordinary Mario-speed timing, APG/tornado leads, direct post-copy writer
  candidate, and source-platform spawned-clone audit are all ruled out in their
  modeled forms.  The project has moved to a closed-world disproof under
  explicit assumptions:
  `no_closed_world_ssl_spawning_displacement_route_to_spindel`.  Any remaining
  positive route must be outside the enumerated closed world.
- [x] Search outside the first closed-world enumeration for missed
  source-backed positive routes.  Found one missed source-platform candidate,
  `bhvCannonClosed`; folded it into the model and ruled it out.  No remaining
  source-backed positive route candidate was found in this pass.
- [x] Check the castle SSL painting checkpoint route.  An active SSL checkpoint
  can redirect the castle SSL painting to SSL area 2, but painting entry uses
  `gMarioState->floor` and requires a painting-warp surface type.  Ordinary
  `gMarioPlatform` seeding requires the selected floor to be object-owned, and
  the audited castle object surfaces are not painting-warp floors.  The theorem
  `castle_checkpoint_painting_route_cannot_seed_spawning_displacement` rules
  out this route under the synchronized ordinary-floor model.
- [x] Prove the inside-pyramid displacement bound for every audited SSL area-2
  surface/platform target on the first stale update.  The theorem
  `ssl_area2_all_first_update_platform_displacements_stay_in_elevator_shaft`
  shows that all modeled first-update outcomes remain inside the top-entry
  elevator shaft footprint, and
  `ssl_area2_all_first_update_platform_displacements_do_not_reach_cage_top`
  shows that none reaches the high cage/rim top.  The companion writeup is
  `docs/area2-platform-displacement.md`.
- [x] If no such mechanism exists, reframe the final result as a disproof of
  SSL spawning displacement under the modeled ordinary gameplay assumptions,
  while retaining the conditional inside-pyramid Spindel theorem.
- [x] Close the proposed node-1E held-object/behavior-command relocation route
  by static JP Clight analysis.  The proof establishes the transient
  `usedObj`/`interactObj` aliases, warp-before-action and warp-before-grabbable
  barriers, normal area-load pointer clear, unusable action-zero exception,
  held-pointer dependency of `obj_set_held_state()`, and non-self-redirecting
  warp behavior.  The capstone is
  `generated_jp_clight_node1e_control_flow_capstone`; no observation build or
  input search is needed for this route family.
- [x] Prove the counterfactual mechanics after granting `heldObj == 1E`.
  Grabbing alone leaves the live hitbox at its old position; dropping relocates
  its coordinates while preserving the first-contact warp fields.  Warp code
  does not write `gMarioPlatform`, but an object-owned moving floor selected by
  the later `update_mario_platform()` call does.  The seed survives arbitrary
  modeled disappearance frames and JP area loading, while destination Mario
  still appears at area-2 node 14 `(0, 5500, 256)`.  The capstone is
  `generated_jp_clight_moved_node1e_platform_seed_capstone`.
- [x] Explain the observed Klepto-55, pyramid-top-60, and node-1E-warp-63
  slot pattern.  The proof distinguishes fixed pool addresses from object-list
  traversal, proves that an ordinary list-9 bulk unload would put the top ahead
  of the list-6 warp, and proves the synchronized early-free alternative.  If
  the top deactivates on the final normal frame, same-frame collision can
  reselect its already-free slot; the subsequent bulk unload buries it.  Under
  the observed bulk ordering, allocation reaches slots 63, 55, and 60 in that
  order.  Unreused slot 60 retains the top's `oAngleVelYaw = 0x1800`, which JP
  displacement reads without an active check.  See
  `generated_jp_clight_observed_pyramid_top_slot_capstone` and
  `docs/pyramid-top-slot-persistence.md`.
