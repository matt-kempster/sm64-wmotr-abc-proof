# SSL Pyramid item proof checklist

Last updated: 2026-06-30

Tiny vibe check: this is the human-readable TODO list for the "can we smuggle
stuff into SSL Pyramid?" proof. The Coq files are the machine's truth. This
file is the Discord-friendly map of the remaining grind so future-us does not
have to reconstruct the whole cave system from vibes and `rg`.

Rule for Codex rounds: whenever proof work changes what is done / still scary /
newly suspicious, update this file in the same round.

## 0. What are we even calling an "item"?

- [x] Say that "item" means gameplay-relevant `gObjectPool` identity, not just
  one interaction enum.
- [x] Put cork boxes, shells, and other portable / rideable / holdable objects
  in the main target zone.
- [x] Keep hats/caps and special objects in scope when they can preserve object
  identity, stale refs, or cloning power.
- [ ] Turn the prose item definition into a precise Coq predicate.
- [ ] Make the final theorem say exactly which item classes are covered, so no
  one can hide a shell behind wording fog.

## 1. Game facts and source setup

- [x] Keep the SSL proof in its own `ssl-pyramid-item-proof/` space so WMotR
  work stays clean.
- [x] Use the CompCert `clightgen` route like the WMotR proof.
- [x] Document the pinned SM64 source / generated-Clight route.
- [x] Confirm whether extra ROM-derived assets are needed for the remaining
  generated files. Current answer: not for the generated-file work presently
  on the checklist. The 17 Clight TUs we are proving against are checked in,
  the proof pipeline uses those directly, and probe-regenerating representative
  scary inputs (`area.c`, `levels/ssl/script.c`, `src/audio/external.c`, and
  the giant `behavior_actions.c`) works from the pinned source checkout even
  though this machine does not currently have `reference-sm64-decomp/build/us`.
  So no ROM request right now. If we later add a TU or reproduction step that
  actually needs ROM-extracted build assets/headers, full ROM byte-compare, or
  emulator corroboration, stop and ask for a legally obtained US ROM instead
  of doing the proof-goblin "probably fine" shuffle.
- [ ] Make the build/rebuild story reproducible for a human on a normal setup,
  not just this one WSL box.

## 2. The outside-object census

This is the "what toys are actually outside the pyramid?" layer.

- [x] Record that SSL area 1 has a Koopa shell source via exclamation box.
- [x] Record the Wing Cap boxes / cap-state channel as a separate thing from
  "same object identity crosses the wall."
- [x] Mechanize the finite list of outside-Pyramid object channels.
  `OutsideObjectChannels.v` now gives us nine named cases instead of a
  hand-wavy pile: small breakable box, two bob-ombs, two jumping boxes, the
  shell box, and three Wing Cap boxes. It also extracts the exact relevant
  macro entries from the generated SSL area-1 macro table.
- [x] Decide, with proof/doc evidence, whether each channel is:
  - direct object transfer risk,
  - stale-pointer / cloning risk,
  - only ordinary state like coins/timers/music/camera,
  - or irrelevant to item identity.
  `outside_pyramid_channel_classifications_shell_first` now says the shell box
  is both a direct-object and stale/cloning risk through `riddenObj`; the five
  grabbable objects are direct/stale risks through held/used/interact-style
  references; and the three Wing Cap boxes are cap-state-only channels, not
  object-identity channels.
- [x] Specifically track the shell/ridden-object channel. Shells are the spicy
  one; do not hand-wave them. The shell case is first in the classification
  table and has generated evidence for `bhvKoopaShell`, `INTERACT_KOOPA_SHELL`,
  `interact_koopa_shell` writing `riddenObj`, and `init_mario` clearing
  `riddenObj`.

## 3. `unload_object` cleanup proof

This is the big current Coq grind: after `unload_object` clears
`activeFlags`, prove the rest of cleanup does not secretly reactivate or corrupt
the same pool slot's deactivation fact.

- [x] Split the generated `unload_object` body into named cleanup chunks.
- [x] Prove direct stores like `prevObj = NULL`, `throwMatrix = NULL`, and graph
  flag bit clears miss the watched `activeFlags` bytes.
- [x] Prove the `_obj` temp survives the cleanup tail.
- [x] Reduce the tail frame checklist to four remaining calls:
  `stop_sounds_from_source`, `geo_remove_child`, `geo_add_child`, and
  `deallocate_object`.
- [x] Add the empty-env tail bridge that uses the resolved-free-list
  deref-shape path for the final `deallocate_object` call.
- [x] Lift that empty-env tail bridge one rung lower: the final
  `deallocate_object` leaf now needs object-pool link-shape facts plus
  first-splice preservation, instead of raw deref-shape facts.
- [x] Close the first-splice preservation side quest, so this empty-env tail
  bridge now only needs the pool-link field invariant at the deallocate leaf.
- [x] Connect the field-only empty-env cleanup-tail bridge back to the actual
  generated `fn_body f_unload_object`, proving the current slot is deactivated
  after that body under those obligations.
- [x] Add a valid-slot-scoped `valid_deactivation_step` bridge for generated
  `unload_object` via the global tail frame. Not every integer is a real object
  slot; the proof now says the quiet part out loud.
- [x] Plug this pool-link-shape tail bridge into the actual traversal path, so
  the deactivation certificate no longer uses the older generic call frame.
- [x] Audit / prove the three non-deallocate helper calls cannot touch the
  watched pool slot in the bad way.
- [x] Turn the helper-call audit into the store-level semantic alias/frame
  proof: graph node link writes and audio-bank/global writes must be shown
  disjoint from the watched pool slot's `activeFlags` bytes.
- [x] Name the valid-slot all-slot cleanup-tail seam:
  `unload_object_tail_empty_env_preserves_valid_pool_slot_active_flags`, then
  prove generated `fn_body f_unload_object` gives a `valid_deactivation_step`
  from it. This is the "not just the target slot, every already-dead valid
  slot stays dead" bridge.
- [x] Prove the target-slot vs watched-slot byte-range arithmetic for the
  direct cleanup stores (`prevObj`, `throwMatrix`, graph `flags`). Translation:
  if cleanup writes a non-`activeFlags` field in slot A, it misses
  `activeFlags` for any valid slot B, not just A.
- [ ] Compose those store-level graph/audio alias-frame facts through the full
  linked helper executions, so the three helper calls discharge their cleanup
  tail frame obligations instead of sitting as caller-side assumptions.
- [ ] Prove the new all-valid-slot tail seam from the tighter field-only /
  pool-link invariant route. Important caveat: the current field-only lemma
  only preserves the slot being unloaded; the valid trace also needs every
  other valid slot's deactivated status to survive the cleanup tail.
- [ ] Lift the new target-vs-watched direct-store arithmetic into execution
  wrappers for `prevObj = NULL`, `throwMatrix = NULL`, and the graph-flag
  clears, then compose those wrappers through the non-call chunks of the tail.

## 4. `deallocate_object` / free-list surgery

This is where stale-pointer cloning can get sneaky, because object slots are
being unlinked and recycled.

- [x] Split generated `deallocate_object` into the two list-splice stores and
  free-list insertion.
- [x] Prove the easy same-object/free-list stores do not hit the watched
  `activeFlags`.
- [x] Reduce the hard stores to pointer-shape obligations for `next`, `prev`,
  and `gFreeObjectList`.
- [x] Prove the resolved `gFreeObjectList` zero-offset pointer shape bridge.
- [x] Prove the generated `Scall` to `deallocate_object(&gFreeObjectList,
  &obj->header)` has the expected argument shape.
- [x] Reduce the deallocate-call frame to
  `deallocate_object_resolved_free_list_deref_shape_obligations`.
- [x] Thread that deref-shape bridge through the generated cleanup tail in the
  empty-env case, which is the actual no-local-vars shape of these generated
  bodies.
- [x] Define `object_pool_link_fields_well_shaped` and
  `first_deallocate_splice_preserves_pool_link_fields`, then prove they imply
  the exact resolved-free-list deref-shape obligations.
- [x] Prove the generated first splice loads shaped `next`/`prev` temps from
  `object_pool_link_fields_well_shaped`.
- [x] Reduce `first_deallocate_splice_preserves_pool_link_fields` to the
  smaller shaped-store obligation: the generated `next->prev = obj->prev`
  store has a shaped target and shaped value.
- [x] Prove the generic CompCert memory fact that storing a shaped object-node
  pointer preserves all pool-link deref-shape facts. Tiny linker-goblin
  defeated; the remaining thing is specializing it to the generated splice.
- [x] Specialize that generic shaped-store preservation lemma to the generated
  `next->prev = obj->prev` assignment and close the first-splice preservation
  seam for real. Bowser's list surgery has one fewer shadow to hide in.
- [x] Add `object_pool_list_link_invariant` as the real object-list/free-list
  link-field interface, and prove it implies
  `object_pool_link_fields_well_shaped`.
- [ ] Derive `object_pool_list_link_invariant` from the actual generated
  object-list/free-list traversal state, not from optimism and coffee.
- [ ] Track whether any stale pointer can survive the free-list splice and later
  alias a newly allocated in-Pyramid object. Partial progress: the model now
  has a checked mid-transition witness that a held outside allocation epoch can
  still be in `heldObj` after destination `load_area`; if that slot is active
  again after load, the stale reference aliases it. Still missing: derive the
  actual slot reuse/free-list story rather than assuming post-load activity.
  This is not yet a cloning counterexample because the generated spine then
  runs `init_mario` / `init_mario_after_warp` before normal Pyramid play
  resumes.

## 5. Traversal / area unload bridge

This is the "the engine actually unloads every outside object it should" layer.

- [x] Define the object-list snapshot model.
- [x] Prove that, if the deactivation trace covers the outside-area snapshot,
  continuous item transfer is forbidden.
- [ ] Derive the snapshot from the actual generated object-list traversal.
  Progress: the generated body spine is now pinned by
  `unload_objects_from_area_traversal_spine`, and
  `generated_object_list_traversal_certificate` is the formal bridge the real
  loop inversion has to construct. Still unchecked because we have not yet
  inverted the circular `gObjectLists` loop execution itself. Translation: the
  receipt has a named slot now, but the engine still has to hand it to us.
- [x] Prove every live outside-Pyramid slot appears in the unload target list.
  `generated_object_list_traversal_lists_all_outside_live_slots` connects the
  generated traversal certificate's snapshot to the existing
  `outside_live_slots_are_unload_targets` coverage theorem.
- [x] Prove every listed outside slot gets an actual `unload_object` execution
  that deactivates that slot.
  `generated_unload_execution_trace_executes_member` extracts the concrete
  generated `f_unload_object` execution witness for any listed slot, and
  `generated_object_list_traversal_executes_and_deactivates_listed_slot` adds
  final deactivation via the valid-slot tail-frame assumption.
- [x] Connect a list of generated `unload_object` executions to the abstract
  `valid_deactivation_trace` via `generated_unload_execution_trace`, then plug
  that into the outside-clearing / transfer-forbidding traversal lemmas.
- [ ] Derive `generated_unload_execution_trace` from the actual generated
  `unload_objects_from_area` loop, instead of handing it a pre-chewed target
  list. Progress: trace membership now means an actual generated unload body
  execution, so the remaining seam is only producing the trace from the loop,
  not proving what each trace member does.

## 6. Stale-pointer / cloning investigation

This is the whole reason we are being fussy. If a stale outside ref can grab an
inside goomba after slot reuse, that is not "no item transfer"; that is a
counterexample-shaped goblin.

- [x] Put stale-pointer cloning in the formal goal scope.
- [x] Model the difference between:
  - same live object crossing the boundary,
  - dead outside pointer surviving,
  - stale pointer aliasing a new in-Pyramid allocation.
- [x] Check the main MarioState held/ridden/used/interacted style channels far
  enough to know the obvious stale goomba story is not already a counterexample.
- [x] Record the known `act_picking_up` fake-object / stale-slot weirdness.
- [x] Finish the non-Mario reference audit: behavior parent/child links, graph
  links, render-held-object links, and any object-owned references.
  `proofs/NonMarioReferenceFacts.v` is the goblin ledger here: Object-owned
  refs are now mechanically split into scalar `Object*` fields
  (`parentObj`, `prevObj`, `platform`), the `collidedObjs` array, and
  `rawData.asObject`; graph tree/list links and render-held `objNode` writers
  are also pinned. This is the finite writer/root audit, not yet the full
  semantic "can one survive the Pyramid warp?" proof.
- [x] Prove or refute whether an outside grab can leave a stale object pointer
  live across the Pyramid load.
  Refuted the "cannot" version for the mid-transition `load_area` boundary:
  `outside_held_grab_can_leave_stale_reference_across_pyramid_load` gives the
  held-object stale-reference witness, and
  `held_grab_stale_reference_would_alias_reused_slot_after_load` says slot
  reuse during load would make that stale ref alias a live slot. The cleanup
  theorem still says the post-`init_mario_after_warp` Mario refs are boring.
- [x] Audit whether that mid-transition stale Mario ref is read before cleanup
  by the obvious suspects. `pyramid_load_window_stale_refs_not_observed_before_cleanup`
  checks that `load_area`, `load_mario_area`, the generated
  `object_list_processor` module, and the pre-`init_mario` prefix of
  `init_mario_after_warp` do not mention `heldObj`, `usedObj`, `riddenObj`, or
  `interactObj`. Current mood: spooky window, but not caught doing cloning
  crime there.
- [x] Connect the no-observation audit to the stale-window model. The new
  `proofs/StaleWindowObservation.v` corollaries say the stale held-object
  window, and even the conditional reused-slot alias window, are unobserved by
  the audited generated load/reinit path before cleanup.
- [x] Check whether normal object update can act on the temporarily aliased
  Pyramid object before `init_mario` clears/rebinds Mario's roots.
  `load_area_direct_call_order`, `load_area_does_not_call_update_objects`, and
  `load_mario_area_does_not_call_update_objects` pin the generated gap: the
  loader may spawn destination objects, load warp nodes, and run graph global
  callbacks, but it does not run the ordinary `update_objects` gameplay loop.
  Translation: you can maybe arrange which new slot the stale pointer aliases,
  but the audited code path still does not let Mario poke it through
  `heldObj`/`usedObj`/`riddenObj`/`interactObj` before the cleanup broom arrives.
- [x] Identify the scary `gMarioState->action == 0` cleanup-skip seam.
  Source names this value `ACT_UNINITIALIZED`, and the generated proof has
  `act_uninitialized_is_zero`. More importantly,
  `init_mario_after_warp_cleanup_is_guarded_by_action_nonzero` records that the
  `load_mario_area` / `init_mario` / rebind sequence sits under the generated
  `action != 0` branch. So yes, if `action == 0` at this exact point, the broom
  can be skipped. That is not a normal controllable action; it is the
  pre-initialized Mario state.
- [x] Check what `action == 0` does to normal Mario interactions.
  `init_mario_from_save_file_sets_action_uninitialized` records the obvious
  source of action 0, while `init_mario_assigns_nonzero_initial_action_shape`
  records that normal init assigns a real initial action instead of zero.
  `execute_mario_action_processes_interactions_only_when_action_nonzero` says
  the generated Mario executor only reaches input/interactions when action is
  nonzero, and `star_collection_handler_sets_action_but_is_interaction_downstream`
  pins star collection as downstream of that interaction path. Translation:
  action 0 is not "Mario can freely act while stale"; it is "Mario basically
  does not run his normal action/interact machine."
- [x] Prove the global warp-entry invariant for the SSL Pyramid change-area
  path: every normal gameplay route that can set up `warp_area` while Mario is
  holding/using/riding something has `gMarioState->action <> ACT_UNINITIALIZED`.
  `normal_gameplay_ssl_warp_entry_action_nonzero_syntactic_certificate` is the
  bridge. It says the normal gameplay warp sources are under
  `execute_mario_action`'s nonzero-action branch:
  `update_mario_inputs`, `mario_handle_special_floors`,
  `mario_process_interactions`, and the later cutscene-action executor are all
  behind the `action` guard. The interaction handler table contains
  `interact_warp` / `interact_warp_door`; those handlers set Mario actions and
  do not directly call `level_trigger_warp`. The delayed-warp trigger then
  shows up in generated cutscene action code (`act_disappeared`) and in the
  special-floor helpers (`check_death_barrier` /
  `mario_handle_special_floors`). Finally, generated `level_update` has
  `warp_area` and its demo `level_trigger_warp` calls only in
  `play_mode_normal`, while the audited script/area modules do not directly
  call either `warp_area` or `level_trigger_warp`.

  Translation: if Mario is doing normal gameplay and can still have a
  held/used/ridden/interact-style stale outside root, the path that schedules
  the Pyramid warp is not action 0. If someone finds an `action == 0` Pyramid
  entry with a stale outside root, it is not this normal interaction/floor warp
  route; it is a new script/init/external counterexample candidate and should
  get its own wanted poster.
- [x] Start chasing non-Mario roots through the same window:
  `pyramid_load_window_object_owned_roots_not_mentioned_before_cleanup` covers
  `platform` and `rawData.asObject`, while
  `pyramid_load_window_graph_specific_roots_not_mentioned_before_cleanup`
  covers `GraphNodeObject.sharedChild` and `GraphNodeHeldObject.objNode`.
  The generic graph `parent`/`children`/`prev`/`next` names needed the typed
  pass below because raw `next`/`prev` also means object-list links and a bunch
  of other totally-not-graph stuff.
- [x] Detour into counterexample-hunting before more graph-unlink paperwork.
  New `proofs/StaleWindowObservation.v` root ledger
  `high_risk_outside_pointer_roots` puts the scary roots in one place:
  Mario `interactObj`/`heldObj`/`usedObj`/`riddenObj`, object-owned
  `parentObj`/`prevObj`/`platform`/`collidedObjs`/`rawData.asObject`,
  `GraphNodeObject.sharedChild`, render-held `GraphNodeHeldObject.objNode`,
  and generic graph tree/sibling links. The new
  `persistent_outside_pointer_from_high_risk_root_is_counterexample_candidate`
  theorem says the quiet part formally: if any of those roots still points at
  an outside allocation epoch, that is not "probably fine"; it is a
  counterexample candidate and jumps the queue.
- [x] Beef up the Pyramid load-window audit for object-owned roots.
  `pyramid_load_window_full_object_owned_roots_not_mentioned_before_cleanup`
  now covers `parentObj`, `prevObj`, `platform`, `collidedObjs`, and
  `rawData.asObject` across `load_area`, `load_mario_area`, the generated
  `object_list_processor` module, and the pre-`init_mario` prefix of
  `init_mario_after_warp`. Also pinned
  `pyramid_load_window_mario_platform_externals_not_called_before_cleanup`,
  because `clear_mario_platform`, `apply_mario_platform_displacement`, and
  `update_mario_platform` are spicy names and deserve their own bouncer.
- [x] Revisit shell/ridden/held/used channels in that same certificate.
  `shell_and_grabbable_stale_channel_load_window_audit_holds` packages the
  shell-first classification, ridden-shell generated evidence, direct
  grabbable cleanup evidence, and the Mario stale-root no-observation audit.
  Translation: the shell/held/used/ridden paths are still the right scary
  channels, but this bite did not find a use site before the cleanup broom.
- [x] Prove/triage high-risk root persistence past `init_mario_after_warp` for
  the normal SSL Pyramid change-area path.
  `normal_ssl_pyramid_change_area_high_risk_root_certificate_holds` now ties
  the normal nonzero-action warp-entry guard, `warp_area -> load_area ->
  init_mario_after_warp` ordering, `init_mario` cleanup facts, and the
  high-risk load-window audit into one certificate. The Mario-owned roots are
  closed for the post-init state: `interactObj` / `usedObj` are rebinding to
  the destination spawn object, while `heldObj` / `riddenObj` are boring null
  roots. The theorem
  `normal_path_high_risk_roots_do_not_persist_or_are_candidates` keeps the
  non-Mario roots honest: `parentObj`, `prevObj`, `platform`,
  `collidedObjs`, `rawData.asObject`, render-held links, and graph links are
  not magically cleared by Mario init; if any of those survives with an
  outside allocation epoch, it immediately instantiates
  `persistent_outside_pointer_counterexample_candidate`.
  Discord goblin translation: Mario's pockets get swept. The weird object and
  graph pockets are still on the corkboard, but any survivor now gets a formal
  little criminal nametag instead of being handwaved.
- [x] Build a type-aware graph-link audit for
  `GraphNode.parent`/`children`/`prev`/`next`. New theorem
  `pyramid_load_window_typed_graph_node_link_audit` ignores fake scares like
  `ObjectNode.next`, but it also caught the real goblin: direct `load_area`
  has no typed graph-link field access, yet it calls `load_obj_warp_nodes` and
  `geo_call_global_function_nodes`. The former reads typed graph links exactly
  as `children`, `next`, `children`; the latter lives in the generated
  `graph_node` TU, whose typed graph-link mentioners are now a finite list
  (`init_scene_graph_node_links`, `geo_add_child`, `geo_remove_child`,
  `geo_make_first_child`, the two `geo_call_global_function_nodes*` helpers,
  and `geo_find_root`). Translation: field-name collision defeated; semantic
  graph traversal is still a real dragon.
- [x] Prove the semantic fork for those graph traversals:
  `proofs/GraphTraversalModel.v` now says the generated roots are boring if
  the object-parent child list root and current-area root are
  current/destination nodes and `children`/`next` links preserve that property.
  If that closure fails, the same file gives a formal
  `graph_link_counterexample_candidate`: a reachable graph node from one of
  those generated roots that is not current/destination. Translation: either
  prove the graph tree is clean after unload/load, or we have the exact shape
  of the spooky survivor to chase. No mushy middle.
- [x] Pin the generated unload/load graph-relink skeleton and bridge it to the
  traversal invariant. `generated_unload_load_graph_relink_audit_holds` now
  checks the actual call order: `unload_object` does
  `geo_remove_child -> geo_add_child -> deallocate_object`,
  `try_allocate_object` does `geo_remove_child -> geo_add_child`,
  retry allocation can unload an unimportant object then try allocation again,
  and `load_area` calls `spawn_objects_from_info` before
  `load_obj_warp_nodes` / `geo_call_global_function_nodes`. The new theorem
  `unload_load_relink_effects_confine_generated_traversal` says that if those
  relinks have the expected reachability effect -- after relinking, every node
  reachable from the generated roots was either already reachable before or is
  newly current/destination -- then the later graph traversals are confined.
  Translation: the route through real generated functions is now named; the
  remaining monster is the semantic postcondition of the relink helpers.
- [x] Prove the graph-level semantic relink postconditions for
  `geo_remove_child` and `geo_add_child`.
  `geo_remove_child_semantic_execution_satisfies_reachability_after_remove`
  says a generated-shape remove execution that only keeps old edges or skips
  over the removed node really removes that node from the generated roots'
  `children`/`next` reachability. `geo_add_child_semantic_execution_satisfies_reachability_after_add_current`
  says a generated-shape add execution only preserves old reachability or
  lands on a node already classified current/destination. The composed theorem
  `generated_relink_semantic_executions_confine_traversal` plugs both helper
  contracts into the traversal confinement path. Translation: the graph goblin
  now has to beat a named semantic contract, not just wave at spooky sibling
  links.
- [x] Lower the graph relink contracts one step toward raw CompCert memory.
  `GraphTraversalModel.v` now pins the generated `GraphNode` field offsets
  for `prev`, `next`, `parent`, and `children`, defines concrete
  `Mem.loadv` / `Mem.storev` helpers for those fields, and records the exact
  remove/add store traces we care about. Theorems
  `geo_remove_child_graph_effect_from_memory_effect` and
  `geo_add_child_graph_effect_from_memory_effect` turn those concrete
  load/store/frame facts into the abstract graph effects, and
  `generated_relink_memory_effects_confine_traversal` plugs them into the
  traversal proof. Special goblin accounted for:
  `generated_unload_parking_memory_effect_confines_traversal` models the
  `unload_object` move that parks the removed node under
  `gObjParentGraphNode`; that is safe only once the node is classified
  dead/parked-not-transportable.
- [x] Invert the real generated helper `exec_stmt` runs down to named
  byte-effect obligations.
  `exec_geo_remove_child_body_inverts_spine` and the `geo_add_child` spine
  lemmas split the generated Clight bodies into the actual parent/prev/next
  reads, sibling rewires, parent-children branch, and return pieces. The new
  `geo_remove_child_memory_effect_from_exec_stmt` /
  `geo_add_child_memory_effect_from_then_branch_exec_stmt` bridge says:
  if that real generated execution also gives us the precise load/store/frame
  facts, then we get the memory-effect records already accepted by the graph
  traversal proof. Translation: the helper body shape is no longer handwavy;
  the next gremlin is proving the individual assignments really make the
  promised bytes move and leave the other graph-link bytes alone.
- [x] Lower the generated graph-link assignments one more rung.
  `GraphTraversalModel.v` now names the actual generated assignment shapes:
  the two `geo_remove_child` sibling splices, the `firstChild`
  null-vs-next branch, `geo_add_child`'s parent store, and both empty/nonempty
  child-list insertion branches. It also proves the ppc32 pointer-store bridge
  `assign_loc_graph_node_field_store_ptr` /
  `assign_loc_graph_node_field_store_null`, plus generic `Sassign` inversion
  lemmas such as `exec_graph_node_field_ptr_assignment_effect` and the
  indirect-pointer variants. Translation: `Sassign` now coughs up the real
  `eval_lvalue` / `eval_expr` / cast / `assign_loc` package, and exact
  field-address `assign_loc`s become our `Mem.storev` records. The bit still
  not dead is normalizing each generated lvalue/temp chain to "this is
  precisely `prev->next`, `next->prev`, `parent->children`, etc." and then
  threading the non-overlap frame facts through the sequence.
- [x] Prove the first one-splice assignment/store/frame bridge.
  The theorem
  `geo_remove_child_prev_next_assignment_effect_store_and_frames` now covers
  the final assignment in the first `geo_remove_child` splice: if the generated
  assignment effect runs with `_t'6` holding `graphNode->prev` and `_t'7`
  holding `graphNode->next`, then the assignment is exactly the concrete
  `previous->next = next` `GraphNode.next` store. It also proves byte-disjoint
  `children` and `next` graph-link loads are framed across that store. Tiny
  but important caveat: this bridge still assumes the temps already contain
  the two sibling pointers; the read bridge below is what now starts feeding it.
- [x] Package the two preceding generated `Sset` reads without eating the
  whole generated AST cave.
  `GraphTraversalModel.v` now has a cheap `Sset` inversion layer:
  `exec_generated_sset_effect_from_exec_stmt`,
  `graph_node_temp_field_read_normalizes`,
  `exec_graph_node_temp_field_read_sets_temp_ptr`, and
  `geo_remove_child_prev_then_next_reads_set_temps_from_normalization`.
  Translation: if we prove the generated expression `graphNode->prev`
  normalizes to the concrete `previous` pointer, then the generated
  `_t'6 = graphNode->prev` read really puts `previous` in `_t'6`; same deal
  for `_t'7 = graphNode->next`. The second read is also proved not to clobber
  `_t'6`, and both reads leave memory alone. This is real CompCert `Sset`
  plumbing, just with the scary expression-normalization fact split out.
- [x] Prove the actual `graph_node_temp_field_read_normalizes` obligations for
  `_prev` and `_next` from concrete `GraphNode` field loads.
  Landed without asking Coq to swallow the whole generated graph-node buffet:
  `graph_node_temp_field_read_normalizes_from_load_ptr` reuses the existing
  `eval_graph_node_temp_field_lvalue` normalizer, then compares the real
  `deref_loc` load with `graph_node_field_load_ptr`. The two spicy
  specializations are now
  `graph_node_prev_read_normalizes_from_load_ptr` and
  `graph_node_next_read_normalizes_from_load_ptr`. Even better,
  `geo_remove_child_prev_then_next_reads_set_temps_from_loads` now starts from
  concrete `graphNode->prev` / `graphNode->next` memory facts and proves the
  generated `_t'6` / `_t'7` reads fill the temps, preserve `_t'6` across the
  second read, leave memory alone, and finish normally.
- [x] Compose the first `geo_remove_child` splice all the way through the
  concrete store/frame theorem.
  `geo_remove_child_prev_next_read_assign_store_and_frames_from_loads` now
  chains the two concrete sibling reads into the generated assignment effect,
  then calls `geo_remove_child_prev_next_assignment_effect_store_and_frames`.
  `geo_remove_child_prev_next_splice_store_and_frames_from_loads` lifts that
  to the actual generated `geo_remove_child_prev_next_splice` statement. In
  Discord goblin terms: the first splice is now one tidy creature:
  `_t'6 = graphNode->prev`, `_t'7 = graphNode->next`, then
  `previous->next = next`, with the disjoint `children` / `next` frame facts
  packed in the bag.
- [x] Clone the sibling-splice bridge for `next->prev = previous`.
  The mirror side is now mechanized too:
  `geo_remove_child_next_prev_assignment_effect_store_and_frames`,
  `geo_remove_child_next_then_prev_reads_set_temps_from_loads`,
  `geo_remove_child_next_prev_read_assign_store_and_frames_from_loads`, and
  `geo_remove_child_next_prev_splice_store_and_frames_from_loads`. Translation:
  the generated `_t'4 = graphNode->next`, `_t'5 = graphNode->prev`, and
  `next->prev = previous` sequence now produces the concrete
  `GraphNode.prev` store, while preserving byte-disjoint `children` / `next`
  traversal loads across that store.
- [x] Compose the sibling splices into the two-store
  `geo_remove_child_compcert_store_trace` prefix.
  `geo_remove_child_compcert_store_trace` has been moved up next to the concrete
  store lemmas, and
  `geo_remove_child_sibling_splices_store_trace_prefix_from_loads` now packages
  the two generated sibling splices into the first two concrete stores:
  `previous->next = next`, then `next->prev = previous`. The theorem also
  threads the first store far enough to justify the second splice rereading the
  removed node's `prev`/`next`: `removed.next` is handled either by the
  singleton/self case (`removed = previous`) or a disjoint `next` frame, and
  `removed.prev` uses the disjoint `prev` frame. Small caveat, kept explicit
  rather than handwaved: the theorem still takes the post-first-splice
  `_graphNode` temp lookup as a seam, because proving the first splice preserves
  that temp cleanly is a separate tiny execution-shape proof.
- [ ] Park the remaining graph-unlink paperwork: `_graphNode` temp preservation
  and the `parent->children` branch.
  This is expected proof grind, not a promising counterexample vein. The
  `_graphNode` seam should be syntactic: the first sibling splice writes temps
  and memory, but not `_graphNode`. The parent-child branch still has real cases
  (`parent->children = next` versus null for singleton), so it eventually needs
  to be mechanized, but it is ordinary unlink bookkeeping. When this gets picked
  back up: prove `geo_remove_child_prev_next_splice` preserves `_graphNode`,
  feed that into
  `geo_remove_child_sibling_splices_store_trace_prefix_from_loads`, then prove
  the generated parent-child branch's exact store/null behavior plus the needed
  frame/no-incoming facts.
- [ ] If stale slot reuse can clone an in-Pyramid goomba/object, stop proving
  impossibility and write the counterexample cleanly.

## 7. Caps, shells, and other "is this an item?" gremlins

- [x] Treat Wing Caps/cap objects as in scope when they affect object identity
  or state transfer.
- [x] Record that cap timer/state is a distinct state-transfer channel, not
  automatically the same as object transfer.
- [x] Decide whether cap pickup state can reconstruct an outside object identity
  or only transfers ordinary Mario state.
  `proofs/CapPickupStateFacts.v` is the new cap goblin ledger. It proves
  `interact_cap` does read the cap object's behavior and does set
  `m->interactObj = o` during successful pickup, so there is a transient
  pointer. But the durable cap-pickup channel is ordinary Mario state:
  `m->flags`, `m->capTimer`, action/music/sound, plus the cap object's own
  interact-status word. The generated pickup body does not write `heldObj`,
  `usedObj`, `riddenObj`, or `marioObj`, and it does not call `spawn_object`.
  The post-pickup cap timer updater also does not spawn or write Mario
  object-reference roots. Finally, the audited Pyramid load window does not
  mention `interactObj` before `init_mario_after_warp` reaches the
  cleanup/rebind path. Translation: cap pickup can leave a spooky temporary
  `interactObj`, but the cap timer/flag state cannot reconstruct the outside
  cap object identity.
- [ ] If normal-cap loss/retrieval becomes relevant, prove separately that
  `mario_blow_off_cap` creates a fresh normal-cap object from Mario/save state,
  not the original outside Wing Cap box/cap identity.
- [ ] Finish the shell ride/ridden-object proof path.
- [ ] Check cork boxes and other grabbables against the same held-object/stale
  reference logic.

## 8. Linking / generated-file boundary

- [x] Keep generated Clight files unedited.
- [x] Document the Clight input patch seam.
- [ ] Produce the reproducible certificate that the relevant generated symbols
  resolve to the expected internal functions.
- [ ] Audit the currently trusted external/helper boundaries.
- [ ] Keep `Print Assumptions` output boring: no sneaky `Admitted`, `Axiom`, or
  "trust me bro" theorem entering the capstone.

## 9. Final theorem / counterexample exit ramp

- [x] Have a conditional capstone:
  `certified_pyramid_transition_forbids_continuous_item_transfer`.
- [ ] Replace the conditional certificate with one derived from generated
  Clight execution of the real SSL transition path.
- [ ] State the final theorem in game words and Coq words:
  "no outside-Pyramid object identity enters the Pyramid," with the stale-slot
  interpretation nailed down.
- [ ] If the theorem is false, document the counterexample instead:
  setup, object, pointer/root that survives, slot reuse, and why it clones or
  transfers gameplay identity.
- [ ] Run the full proof pipeline.
- [ ] Push the final proof state to the fork.
- [ ] Only open a PR if the user explicitly says yes.

## Current next bite

The next proof-shaped bite is the newly exposed all-slot tail-frame seam:

- prove `unload_object_tail_empty_env_preserves_valid_pool_slot_active_flags`
  from the pool-link/linked-helper route, not from the older broad global tail
  frame;
- lift `pool_slot_*_store_misses_watched_active_flags` into the direct
  generated cleanup executions;
- derive `object_pool_list_link_invariant` from the actual object-pool/list
  state; and
- derive `generated_unload_execution_trace` from the real
  `unload_objects_from_area` traversal loop, now specifically by constructing
  `generated_object_list_traversal_certificate` from the generated 13-list
  loop.

Translation: the proof now knows that clearing one object is not enough; all
other already-dead valid slots have to stay boring too. Very rude of memory,
but fair.

Traversal-side next bite: invert the generated `f_unload_objects_from_area`
loop enough to build `generated_object_list_traversal_certificate`:

- read the 13 circular `gObjectLists` chains into `snapshot_lists`;
- prove the active/live slots in memory are exactly covered by that snapshot;
- show the generated `activeAreaIndex == areaIndex` branch produces exactly
  `unload_targets area snapshot`; and
- package the recursive calls as `generated_unload_execution_trace`.

In Discord goblin terms: we proved that everyone on the bouncer's list gets
thrown out. Now prove the bouncer's list really came from the engine's
`gObjectLists` clipboard.

Channel-side next bite: chase the non-Mario survivors now that the normal Mario
root broom is pinned:

- derive the object-owned roots (`parentObj`, `prevObj`, `platform`,
  `collidedObjs`, `rawData.asObject`) from the real unload/list cleanup, or
  instantiate `persistent_outside_pointer_counterexample_candidate` with the
  surviving field;
- derive the render-held and graph roots from the real graph unlink/load
  invariants, or turn the surviving graph/render-held edge into the existing
  counterexample candidate;
- chase the externally implemented Mario-platform helpers only after proving
  they can actually run before the cleanup/rebind path; right now the generated
  load window does not call them;
- if an `action == 0` Pyramid entry still looks possible, treat it as a
  non-normal script/init/external route first; the normal gameplay
  interaction/floor route is now pinned behind the nonzero-action guard;
- keep the graph-root fork as-is: reachable outside graph root means candidate,
  otherwise go back to the boring unlink proof.

Discord goblin translation: the sniff test found no immediate cloning stink in
the load window, but it installed a tripwire. If a stale outside pointer
survives in any of those roots, the little criminal gets a name tag.
