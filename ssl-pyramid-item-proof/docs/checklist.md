# SSL Pyramid item proof checklist

Last updated: 2026-06-30

Tiny vibe check: this is the readable TODO map for the SSL Pyramid item/stale
pointer proof. The Coq files are the machine truth; this file is the Discord
goblin map so future-us can tell what is scary, what is done, and what gets
worked next without spelunking through a thousand-line diary.

Rule for Codex rounds: if proof work changes what is done, scary, or newly
suspicious, update this file in the same round.

## Current verdict

No practical cloning counterexample is known right now.

What we do have is subtler:

- normal outside object identity is being pushed toward an impossibility proof;
- a technical stale-pointer load-window counterexample exists in the model;
- that technical stale pointer is not currently shown to be gameplay-useful,
  because the audited load/reinit path does not observe Mario's stale object
  roots before `init_mario` / `init_mario_after_warp` clears or rebinds them;
- the stronger scary branch still depends on proving real same-slot reuse from
  the generated unload/load order.

Goblin translation: yes, a stale address can haunt the hallway during load.
No, we have not caught it stealing a Pyramid goomba.

## What counts as an item?

The formal target is gameplay-relevant `gObjectPool` identity, not merely an
interaction enum or ordinary Mario state.

Done receipts:

- `Spec.v` defines `outside_pyramid_item_identity` /
  `outside_pyramid_object_pool_item_identity` style predicates.
- Cork boxes, bob-ombs, jumping boxes, and shells are in the main danger zone.
- Wing Caps / caps stay in scope only when they could preserve object identity;
  current cap proof says durable cap pickup is ordinary Mario state, not object
  identity transfer.
- The final theorem wording is intentionally narrower than "no stale pointer
  ever exists": it is about no outside object identity entering the Pyramid in
  a gameplay-usable way.

## Active next bite

Same-slot reuse is the hot path. Finish lowering the stronger technical
counterexample receipt from generated-AST/order facts into concrete linked
executions.

- [ ] Invert generated `deallocate_object` far enough to show the final
  `freeList->next = obj` store puts the watched slot at the head of
  `gFreeObjectList`.
- [ ] Invert the first generated destination
  `create_object -> allocate_object -> try_allocate_object` path far enough to
  show it reads/pops that same free-list head, or count how many newer freed
  slots sit above the watched slot.
- [ ] Finish generated `allocate_object` activeFlags normalization.
  Done now: exact generated `Sassign` inversion exposes the
  lvalue/rhs/cast/`assign_loc` package, and the RHS is proven to store
  `Vint 257`. Still missing: normalize the lvalue to the watched pool slot's
  exact `activeFlags` address.
- [ ] Finish generated `geo_obj_init_spawninfo` active-area normalization.
  Done now: exact generated active-area `Sset _t'6 = spawn->activeAreaIndex`
  plus `Sassign graphNode->activeAreaIndex = _t'6` inversion exposes the
  generated assignment effect. Still missing: prove the spawn value is area 2
  at this point and normalize the graphNode lvalue to the watched pool slot's
  exact `activeAreaIndex` address.
- [ ] Derive `generated_unload_execution_trace` from the real
  `f_unload_objects_from_area` 13-list loop. The certificate adapter and
  index-based suffix split are done; the remaining beast is proving the loop
  really reads the circular lists and calls `unload_object` exactly for
  `unload_targets area snapshot`.

In Discord goblin terms: the map now has tire tracks for the two final stores.
Next we need the dashcam footage showing the generated code drove there.

## Open tasks by category

### Build / repo hygiene

- [ ] Make the build/rebuild story reproducible for a human on a normal setup,
  not just this one WSL box.
- [ ] Keep generated Clight files unedited.
- [ ] Produce the reproducible certificate that the relevant generated symbols
  resolve to the expected internal functions.
- [ ] Audit the currently trusted external/helper boundaries.
- [ ] Keep `Print Assumptions` output boring: no sneaky `Admitted`, `Axiom`, or
  "trust me bro" theorem entering the capstone.
- [ ] Only open a PR if the user explicitly says yes.

### `unload_object` cleanup tail

- [ ] Compose the store-level graph/audio alias-frame facts through the full
  linked helper executions, so helper calls discharge their cleanup-tail frame
  obligations instead of sitting as caller-side assumptions.
- [ ] Prove `unload_object_tail_empty_env_preserves_valid_pool_slot_active_flags`
  from the tighter field-only / pool-link invariant route.
  Caveat: the current field-only lemma preserves the slot being unloaded; the
  valid trace also needs every other valid slot's deactivated status to survive
  the cleanup tail.
- [ ] Lift the target-vs-watched direct-store arithmetic into execution wrappers
  for `prevObj = NULL`, `throwMatrix = NULL`, and graph-flag clears, then
  compose those wrappers through the non-call chunks of the tail.

### `deallocate_object` / free-list surgery

- [ ] Derive `object_pool_list_link_invariant` from the actual generated
  object-list/free-list traversal state.
- [ ] Finish the real free-list reuse receipt:
  watched outside slot deallocated -> slot pushed onto `gFreeObjectList` ->
  destination allocation pops it, or proves the allocation count reaches it.
- [ ] If the watched slot is too deep in the free list to be reached before
  `init_mario`, mark the stronger same-slot counterexample branch blocked for
  that route instead of pretending.

### Traversal / outside-area unload

- [ ] Derive the object-list snapshot from the actual generated
  `f_unload_objects_from_area` traversal.
- [ ] Prove the generated `activeAreaIndex == areaIndex` branch produces
  exactly `unload_targets area snapshot`.
- [ ] Package the generated loop calls as `generated_unload_execution_trace`.
- [ ] Connect the generated traversal/unload execution to the capstone
  certificate without feeding it a pre-chewed snapshot/target list.

### Graph unlink / graph roots

- [ ] Parked grind: close `_graphNode` temp preservation for
  `geo_remove_child`, then continue into the parent->children branch.
- [ ] Prove the generated parent-child branch's exact store/null behavior plus
  the needed frame/no-incoming facts.
- [ ] Derive graph/render-held root elimination from the real graph
  unlink/load invariants, or turn a surviving graph/render-held edge into the
  existing counterexample candidate.

### Non-Mario roots and weird channels

- [ ] If normal-cap loss/retrieval becomes relevant, prove separately that
  `mario_blow_off_cap` creates a fresh normal-cap object from Mario/save state,
  not the original outside Wing Cap box/cap identity.
- [ ] Finish linked-execution receipts for object-owned roots:
  `parentObj`, `prevObj`, `platform`, `collidedObjs`, and `rawData.asObject`.
- [ ] Only reopen externally implemented Mario-platform helpers if a generated
  path actually calls `apply_mario_platform_displacement` or
  `update_mario_platform` before cleanup/rebind.
- [ ] If an `action == 0` Pyramid entry appears, treat it as
  external/state-injection shaped unless a normal generated path is found.

### Final theorem / counterexample exit ramp

- [ ] Replace the conditional capstone with one derived from generated Clight
  execution of the real SSL transition path.
- [ ] If the theorem is false, document the counterexample cleanly:
  setup, object, surviving root, slot reuse, and whether it is practical
  cloning or only technical stale-window weirdness.
- [ ] If stale slot reuse can clone an in-Pyramid goomba/object, stop proving
  impossibility and write the counterexample first.

## Done receipts worth remembering

This is not every finished checkbox; it is the useful index of "where did we
prove the scary thing?"

### Outside-object census

- `OutsideObjectChannels.v` mechanizes the finite outside-Pyramid channel list:
  small breakable box, two bob-ombs, two jumping/cork boxes, shell box, and
  three Wing Cap boxes.
- Shell is classified first because `riddenObj` was the spicy path.
- Direct grabbables go through the held/used/interact style route, not the
  shell-riding route.

### Held/ridden/used stale-window facts

- `StalePointerModel.v` names the technical stale-window counterexample shape.
- `StaleWindowObservation.v` connects that shape to the no-observation audit:
  generated load/reinit code does not read Mario's stale object roots before
  cleanup in the audited path.
- `TransitionFacts.v` refutes the folklore claim that normal warp touch drops
  held objects before transition. It stops shell riding, but plain held object
  cleanup is later.
- `normal_interact_warp_clears_ridden_before_warp_completion` shows the ridden
  shell path is cleared before warp completion.

### `action == 0`

- `ACT_UNINITIALIZED` is action zero.
- The cleanup/rebind path in `init_mario_after_warp` is guarded by
  `action != 0`, so action zero is theoretically scary.
- Normal gameplay interaction/warp entry is action-nonzero guarded, and the
  script/init/debug/demo sweep did not find a normal route combining action
  zero with stale held/ridden/used roots.

### `unload_object` and free-list frame facts

- Generated `unload_object` has a valid-slot-scoped deactivation bridge.
- Direct cleanup stores are proven to miss watched `activeFlags` bytes.
- `object_pool_list_link_invariant` now implies
  `object_pool_link_fields_well_shaped`.
- The boring-but-important remaining work is deriving those invariants from the
  real generated traversal/list state, not assuming them.

### Graph-link work

- Type-aware graph-link audit exists for `GraphNode.parent`, `children`,
  `prev`, and `next`.
- Reachable outside graph node from generated traversal roots is formally a
  counterexample candidate.
- `geo_remove_child` / `geo_add_child` graph-level contracts exist.
- Several raw CompCert store bridges for sibling splices are done.
- The rest is mostly grindy generated-body bookkeeping unless a survivor edge
  appears.

### Same-slot Pyramid allocation receipt

- `same_slot_pyramid_allocation_store_trace` is in generated execution order:
  `allocate_object` writes `activeFlags = 257`, then
  `geo_obj_init_spawninfo` writes `activeAreaIndex = 2`.
- `TransitionFacts.v` pins the generated order spine:
  deallocate pushes to free list, allocation pops free list, create/spawn calls
  occur in the expected order, and `geo_obj_init_spawninfo` copies active area.
- Destination Pyramid allocation lower bound is 70 before post-warp Mario
  cleanup: 4 direct area-2 objects, 14 local-script objects, 2 local-script
  objects, and 50 macro objects.
- `UnloadObjectSemantics.v` proves normalized `assign_loc` facts become exact
  raw `Mem.store` facts for activeFlags and activeArea.
- `StaleWindowObservation.v` packages those normalized stores into
  `same_slot_pyramid_allocation_store_trace_from_linked_assign_locs`.
- New lower-level inversion progress:
  `exec_allocate_object_active_flags_assign_exposes_sassign_effect` exposes the
  generated activeFlags assignment package, and
  `exec_allocate_object_active_flags_assign_exposes_value_effect` proves the
  generated RHS/cast side is exactly `Vint 257`.
  `exec_geo_obj_init_spawninfo_active_area_copy_exposes_effect` exposes the
  generated active-area copy as the real `Sset` plus `Sassign` pair.
- The remaining missing receipt is now specifically lvalue/source
  normalization: turn those generated assignment-effect packages into the
  exact watched-slot `assign_loc`s consumed by the raw `Mem.store` bridge.

## Things that are probably proof grind, not counterexample smell

- The remaining `geo_remove_child` `_graphNode` / parent-child unlink paperwork.
- The activeFlags/activeArea store bridge after lvalue/expression normalization.
- The all-valid-slot cleanup-tail frame once helper calls are linked properly.

Still keep the tripwire: if any outside object pointer or outside graph edge
survives into a pre-cleanup observer, promote it to counterexample candidate
immediately.
