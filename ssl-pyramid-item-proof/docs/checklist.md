# SSL Pyramid item proof checklist

Last updated: 2026-06-26

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
- [ ] Confirm whether extra ROM-derived assets are needed for the remaining
  generated files. If yes: ask for the ROM instead of pretending.
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
- [ ] Decide, with proof/doc evidence, whether each channel is:
  - direct object transfer risk,
  - stale-pointer / cloning risk,
  - only ordinary state like coins/timers/music/camera,
  - or irrelevant to item identity.
- [ ] Specifically track the shell/ridden-object channel. Shells are the spicy
  one; do not hand-wave them.

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
- [ ] Compose those store-level graph/audio alias-frame facts through the full
  linked helper executions, so the three helper calls discharge their cleanup
  tail frame obligations instead of sitting as caller-side assumptions.
- [ ] Replace the global-tail-frame valid step with the tighter field-only /
  pool-link invariant route, so the trace bridge no longer leans on the older
  broad frame assumption.
- [ ] Connect the cleanup-tail theorem into the traversal/deactivation trace,
  not just as a standalone local lemma.

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
- [ ] Prove `object_pool_link_fields_well_shaped` from the real
  object-list/free-list invariant, not from optimism and coffee.
- [ ] Track whether any stale pointer can survive the free-list splice and later
  alias a newly allocated in-Pyramid object.

## 5. Traversal / area unload bridge

This is the "the engine actually unloads every outside object it should" layer.

- [x] Define the object-list snapshot model.
- [x] Prove that, if the deactivation trace covers the outside-area snapshot,
  continuous item transfer is forbidden.
- [ ] Derive the snapshot from the actual generated object-list traversal.
- [ ] Prove every live outside-Pyramid slot appears in the unload target list.
- [ ] Prove every listed outside slot gets an actual `unload_object` execution
  that deactivates that slot.
- [ ] Connect the generated cleanup execution to the abstract
  `valid_deactivation_trace`.

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
- [ ] Finish the non-Mario reference audit: behavior parent/child links, graph
  links, render-held-object links, and any object-owned references.
- [ ] Prove or refute whether an outside grab can leave a stale object pointer
  live across the Pyramid load.
- [ ] If stale slot reuse can clone an in-Pyramid goomba/object, stop proving
  impossibility and write the counterexample cleanly.

## 7. Caps, shells, and other "is this an item?" gremlins

- [x] Treat Wing Caps/cap objects as in scope when they affect object identity
  or state transfer.
- [x] Record that cap timer/state is a distinct state-transfer channel, not
  automatically the same as object transfer.
- [ ] Decide whether cap pickup state can reconstruct an outside object identity
  or only transfers ordinary Mario state.
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

The next proof-shaped bite is now the integration seam: make the helper/free-list
frame facts come from real linked execution, then plug them into traversal:

- prove `object_pool_link_fields_well_shaped` from the real object-pool/list
  invariant;
- compose the store-level graph/audio alias-frame facts through the full linked
  helper executions; and
- connect the generated traversal/unload execution to the new
  `valid_deactivation_trace` certificate path, not just the abstract snapshot
  model.

Translation: we are trying to make the free-list surgery boring enough that the
stale-pointer question has nowhere dark left to hide.

Channel-side next bite: classify the nine mechanized
`outside_pyramid_object_channels`, with the shell/ridden-object path first,
because that is still the spicy one.
