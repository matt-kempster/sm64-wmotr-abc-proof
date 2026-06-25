# Working claim and scope

## Game version

- Super Mario 64, North American release (`VERSION_US=1`)
- n64decomp/sm64 commit `9921382a68bb0c865e5e45eb594d9c64db59b1af`
- CompCert 3.15, rebuilt for `ppc-eabi` so pointers are 32-bit and memory is
  big-endian
- decompilation flags follow the reference route: `NON_MATCHING=1`,
  `AVOID_UB=1`, `TARGET_N64=1`, and F3DEX2

## Boundary being studied

SSL area 1 contains two relevant entrances:

- warp node `0x14`: area 1 -> area 2, destination node `0x0A`
- warp node `0x1E`: area 1 -> area 2, destination node `0x14`

Area 2 is the Pyramid interior. Both are `WARP_TYPE_CHANGE_AREA` transitions.

## Candidate formal statement

The phrase "the same item crosses the boundary" must not be reduced to raw
pointer equality. SM64 object slots are recycled, so an area-2 object may later
occupy the same `gObjectPool` address as an unloaded area-1 object.

The intended safety statement is therefore based on continuous object
liveness:

1. immediately before the area-change operation, an outside item is a live
   `gObjectPool` slot originating in SSL area 1;
2. `unload_mario_area` first unloads the Mario spawn epoch
   (`activeAreaIndex = -1`), then for ordinary SSL area 1 calls `unload_area`;
3. `unload_area` passes every area-1 slot through `unload_object` before area-2
   objects are spawned;
4. `init_mario` clears `gMarioState->heldObj`, `riddenObj`, and `usedObj`;
5. `init_mario_after_warp` then overwrites `interactObj` and `usedObj` with
   the destination spawn object, so the old area-1 interaction pointer is not
   the post-warp value;
6. a slot reused afterward is a new allocation epoch, not the transported
   outside object.

The end theorem should state this over the concrete linked Clight program and
its execution trace, not over a hand-written transition function.

## Obligations still to discharge

- Discharge the remaining `unload_object` cleanup-tail frame obligation: after
  the generated body clears `activeFlags`, prove the remaining calls to
  `stop_sounds_from_source`, `geo_remove_child`, `geo_add_child`, and
  `deallocate_object` leave the two activeFlags bytes of the same object
  pointer in `_obj` unchanged. The `prevObj = NULL`, `throwMatrix = NULL`, and
  graph-node `flags` direct stores are already discharged semantically.
- Pin the exact call chain from either SSL entrance through
  `level_trigger_warp`, `initiate_delayed_warp`, `warp_area`,
  `unload_mario_area`, `unload_objects_from_area`, `load_area`, and
  `init_mario_after_warp`.
- Prove that every reachable carryable object originating outside the Pyramid
  has `header.gfx.activeAreaIndex = 1` at the unloading point.
- Prove that no reachable store can change that field to evade area unloading.
- Prove that every matching live slot is deactivated and put on the free list
  before area-2 spawning.
- Model allocation epochs or an equivalent event-history predicate so slot
  reuse is not mistaken for object transport.
- Finish checking non-carry mechanisms (caps, behavior-specific parent/child
  references, and any non-MarioState stale references) and state explicitly
  which notion of "item" the theorem covers.

## Mechanized unload-object result

`proofs/UnloadObjectSemantics.v` now proves against the generated
`spawn_object.v` AST that:

- the first statement of `f_unload_object` is the concrete
  `obj->activeFlags = 0` assignment;
- any big-step execution of that statement stores a signed 16-bit zero at the
  generated `Object.activeFlags` field offset;
- for every valid pool index `0 <= slot < 240`, the CompCert pointer
  arithmetic normalizes to `slot * 608 + 116`;
- consequently, execution of the complete generated function deactivates the
  specified pool slot once the precise cleanup-tail preservation obligation
  above is supplied.
- the cleanup-tail preservation obligation has been sharpened to a CompCert
  frame condition: if the tail execution satisfies `Mem.unchanged_on` for the
  two activeFlags bytes, then the deactivation load is preserved.
- the generated direct-event sequence of `unload_object` is pinned:
  `activeFlags = 0`, `prevObj = NULL`, `throwMatrix = NULL`, calls to
  `stop_sounds_from_source`, `geo_remove_child`, `geo_add_child`, two
  graph-node `flags` writes, then `deallocate_object`.
- `proofs/LayoutFacts.v` pins the relevant direct-write offsets:
  `prevObj` at 108, `throwMatrix` at 80, graph-node `flags` at 2, while
  `activeFlags` is at 116. These direct stores are therefore below the
  activeFlags bytes; the call-frame proof remains.
- `proofs/UnloadObjectSemantics.v` now also factors the concrete
  `obj->header.gfx.throwMatrix = NULL` statement out of the generated cleanup
  tail itself: `unload_object_after_prev_split_throw_matrix` identifies the
  next generated statement after `prevObj = NULL`, and
  `unload_object_throw_matrix_layout` pins the generated `GraphNodeObject`
  field offset at 80 in the same translation-unit composite environment.
  `unload_throw_matrix_lhs_access_mode` also proves that this generated lvalue
  is a 32-bit by-value pointer store under the configured CompCert target.
- The two generated graph-node `flags` cleanup stores are now factored too:
  after `geo_add_child`, the tail splits into
  `unload_graph_flags_clear_bit2`, then `unload_graph_flags_clear_bit0`, then
  the remaining `deallocate_object` call. The shared
  `obj->header.gfx.node.flags` lvalue has generated layout facts for
  `GraphNodeObject.node` at offset 0 and `GraphNode.flags` at offset 2, and
  `unload_graph_flags_lhs_access_mode` proves it is a signed 16-bit by-value
  store.
- Each generated graph-node `flags` cleanup is further split into a read-temp
  statement and an assignment statement. The read-temp halves
  (`Sset _t'2 ...` and `Sset _t'1 ...`) are semantically discharged by
  `unload_graph_flags_read_bit2_pool_slot_frame` and
  `unload_graph_flags_read_bit0_pool_slot_frame`: they do not write `_obj` and
  do not change memory. The assignment halves are now discharged too:
  `exec_unload_graph_flags_assign_preserves_active_flags`,
  `unload_graph_flags_assign_bit2_pool_slot_frame`, and
  `unload_graph_flags_assign_bit0_pool_slot_frame` prove that the signed
  16-bit stores at `slot*608+2` preserve the same slot's activeFlags bytes at
  `slot*608+116..117`.
- `unload_object_after_graph_flags_bit0_is_deallocate_call` pins the final
  generated cleanup call exactly as
  `deallocate_object(&gFreeObjectList, &obj->header)`. The second argument's
  generated lvalue `obj->header` is classified as a by-copy aggregate, and
  `pool_slot_header_address` normalizes its pool address to `slot*608+0`.
- `statement_leaf_frame_obligations` decomposes the generated tail
  structurally. `Sset`/`Sskip` leaves are discharged by reflexive
  `Mem.unchanged_on`; `Ssequence` uses `Mem.unchanged_on_trans`. After
  discharging the direct cleanup stores, the remaining leaf obligations are
  exactly the four calls to `stop_sounds_from_source`, `geo_remove_child`,
  `geo_add_child`, and `deallocate_object`.
- `exec_unload_object_deactivates_pool_slot_from_same_obj_frame` is the
  correctly scoped bridge for the real call: if the tail leaves unchanged the
  activeFlags bytes of the object pointer stored in `_obj`, then the complete
  generated `unload_object` body deactivates that pool slot. This avoids the
  over-strong requirement that the tail frame every activeFlags-shaped byte
  range in arbitrary memory.
- `unload_object_tail_does_not_write_obj_temp` pins a key generated-code fact:
  the cleanup tail does not overwrite the `_obj` temporary. This is the
  syntactic fact needed to compose same-object frame obligations through the
  tail.
- `exec_unload_object_tail_preserves_obj_temp` proves the corresponding
  semantic fact for the concrete generated tail: any big-step execution of
  `unload_object_tail` preserves the `_obj` temporary value.
- `proofs/TransitionFacts.v` now pins the complete direct activeFlags writer
  census inside `spawn_object`: the writers are exactly `unload_object`,
  `allocate_object`, `create_object`, and `mark_obj_for_deletion`. This keeps
  the proof honest about the allocation/deletion helpers while still isolating
  the cleanup calls used by `unload_object`.
- `cleanup_call_targets_have_no_direct_active_flags_assignment` bundles the
  current generated-code facts for the cleanup calls after deactivation:
  `audio_external` has no direct `activeFlags` writer,
  `stop_sounds_from_source` does not write through its `pos` parameter, and
  `deallocate_object`, `geo_remove_child`, and `geo_add_child` have no direct
  `activeFlags` assignment in their generated bodies.
- `assign_loc_by_value_preserves_active_flags_bytes` is the direct-store
  building block: a CompCert by-value assignment preserves the watched
  activeFlags bytes when its concrete store range is disjoint from them, using
  `Mem.store_unchanged_on`.
- `deref_loc_by_copy_pointer` and
  `deref_loc_by_copy_pointer_any_bitfield` are small generic Clight facts
  needed for nested struct lvalues: dereferencing a `By_copy` aggregate lvalue
  yields the same address as a pointer value, and the generalized form also
  proves that such aggregate dereferences use `Full` rather than a bitfield.
  This is the intended way to keep nested lvalue proofs from exploding on
  generated AST terms.
- `exec_unload_prev_obj_assign_preserves_active_flags` instantiates that
  direct-store frame theorem for the concrete generated `obj->prevObj = NULL`
  statement. For a valid object-pool slot, the 4-byte store at
  `slot*608+108` is proved disjoint from the same slot's activeFlags bytes at
  `slot*608+116..117`.
- `exec_unload_throw_matrix_assign_preserves_active_flags` and
  `unload_throw_matrix_assign_pool_slot_frame` do the same for the concrete
  generated `obj->header.gfx.throwMatrix = NULL` statement. Its 4-byte store
  at `slot*608+80` is proved disjoint from the same activeFlags bytes.
- `pool_slot_statement_preserves_obj_and_active_flags` is the same-object
  pool-slot frame predicate now used for the generated cleanup tail. It records
  both required facts for composition: `_obj` still names the same pool slot,
  and that slot's activeFlags bytes are unchanged.
- `unload_object_tail_pool_slot_frame_from_named_obligations` proves the whole
  named cleanup tail preserves `_obj` and the pool-slot activeFlags bytes if
  the seven named leaves do: `throwMatrix = NULL`,
  `stop_sounds_from_source`, `geo_remove_child`, `geo_add_child`, the two
  graph-node `flags` updates, and the final `deallocate_object` call. The
  `prevObj = NULL` leaf is supplied by the already semantic
  `unload_prev_obj_assign_pool_slot_frame`.
- `unload_object_tail_pool_slot_frame_from_refined_obligations` uses the
  discharged read-temp halves to replace the two graph-node `flags` update
  obligations with just the two actual graph-node `flags` assignment
  obligations.
- `unload_object_tail_refined_frames_from_remaining_frames` then discharges
  the `throwMatrix = NULL` and two actual graph-node `flags` assignment
  obligations, reducing the remaining same-object tail checklist to four
  leaves: `stop_sounds_from_source`, `geo_remove_child`, `geo_add_child`, and
  `deallocate_object`.
- `deallocate_object_body_preserves_active_flags_bytes_from_leaf_frames` and
  `eval_funcall_internal_deallocate_object_preserves_active_flags_from_body_frame`
  discharge the CompCert internal-call plumbing for `deallocate_object`: if the
  generated body has the activeFlags frame property, then an internal call to
  `f_deallocate_object` preserves that property through `function_entry2` and
  the empty local-variable free list. The remaining deallocation work is the
  body's list-pointer separation/frame argument, not the mechanics of Clight
  calls.
- `unload_object_ge_resolves_deallocate_object` and
  `deallocate_object_function_resolves_in_empty_env_holds` prove the global
  lookup side of the generated `Scall`: in the actual empty local-variable
  environment used by `f_unload_object`, the `deallocate_object` name resolves
  to the internal generated `f_deallocate_object` body.
- `unload_deallocate_object_call_empty_env_frame_obligation_holds` and
  `unload_deallocate_object_call_empty_env_frame_from_body_frame` close the
  corresponding caller-side frame bridge for the actual generated call:
  `Scall None deallocate_object(&gFreeObjectList, &obj->header)` preserves the
  `_obj` temporary and the watched activeFlags bytes whenever the generated
  `deallocate_object` body has that frame property. This avoids the
  over-strong arbitrary-environment claim where a local variable could shadow
  the global function name.
- `unload_deallocate_object_call_argument_shape_obligations`,
  `unload_deallocate_object_call_empty_env_shape_frame_obligation_holds`, and
  `unload_deallocate_object_call_empty_env_frame_from_shape_obligations` add
  the tighter caller-side bridge needed by the list-shape proof: the generated
  `Scall` preserves `_obj` and the watched activeFlags bytes when the actual
  evaluated argument list for `deallocate_object(&gFreeObjectList,
  &obj->header)` leads to a `function_entry2` state satisfying the
  shape-scoped deallocation-body obligations.
- `deallocate_object_body_has_obj_next_store_event`,
  `eval_deallocate_object_obj_next_lhs_pool_slot`,
  `exec_deallocate_object_obj_next_assign_preserves_active_flags`, and
  `deallocate_object_obj_next_assign_pool_slot_frame` discharge the generated
  `deallocate_object` store `obj->next = t'1` for the object being unloaded:
  `ObjectNode.next` is at offset `96`, so this 4-byte pointer store at
  `slot*608+96..99` cannot overlap the same object's activeFlags bytes at
  `slot*608+116..117`.
- `deallocate_object_body_split`, `deallocate_object_body_event_sequence`,
  `deallocate_object_body_pool_slot_frame_from_remaining_obligations`, and
  `deallocate_object_body_preserves_pool_slot_active_flags_from_remaining_obligations`
  reduce the whole generated `deallocate_object` body to exactly three
  remaining store-frame obligations: `next->prev = obj->prev`
  (`deallocate_object_next_prev_assign`), `prev->next = obj->next`
  (`deallocate_object_prev_next_assign`), and `freeList->next = obj`
  (`deallocate_object_free_list_next_assign`). The `Sset` reads and the
  same-object `obj->next = t'1` store are no longer part of the remaining
  checklist.
- `object_node_field_store_misses_active_flags_from_header_shape`,
  `object_node_next_store_misses_active_flags_from_header_shape`,
  `object_node_prev_store_misses_active_flags_from_header_shape`,
  `deallocate_object_next_prev_assign_pool_slot_frame_from_target_shape`, and
  `deallocate_object_prev_next_assign_pool_slot_frame_from_target_shape`, and
  `deallocate_object_free_list_next_assign_pool_slot_frame_from_target_shape`
  discharge the three remaining deallocation stores once the relevant target
  temporary (`_t'4` for `next->prev`, `_t'2` for `prev->next`, and
  `_freeList` for `freeList->next`) is known to point either outside the
  object-pool block or to the header of some valid object-pool slot. This is
  the exact list/global free-list shape invariant the later object-list proof
  must supply.
- `object_node_field_value_shape_from_deref_shape`,
  `exec_object_node_field_read_sets_temp_shape_from_deref_shape`, and the five
  specialized `exec_deallocate_object_read_*_shape_from_deref_shape` lemmas
  connect that invariant to the generated reads: under a field-dereference
  shape hypothesis for `ObjectNode.next`/`prev`, the temps loaded by
  `deallocate_object` (`_t'4`, `_t'5`, `_t'2`, `_t'3`, and `_t'1`) are proved
  to inherit the same external-or-pool-slot-header shape.
- `temp_points_to_external_or_pool_slot_header_set_different`,
  `exec_sset_different_preserves_temp_shape`,
  `exec_sset_different_preserves_lookup`, and
  `deallocate_object_first_splice_pool_slot_frame_from_next_deref_shape` now
  compose the first generated splice
  `_t'4 = obj->next; _t'5 = obj->prev; _t'4->prev = _t'5`: the `_t'4` shape
  loaded from `obj->next` survives the intervening `_t'5` read, and the splice
  preserves the watched slot's activeFlags bytes.
- `deallocate_object_second_splice_pool_slot_frame_from_prev_deref_shape`
  applies the same composition to the second generated splice
  `_t'2 = obj->prev; _t'3 = obj->next; _t'2->next = _t'3`, preserving the
  watched activeFlags bytes under the corresponding `obj->prev`
  dereference-shape hypothesis.
- `deallocate_object_free_list_insert_pool_slot_frame_from_free_list_shape`
  composes the final generated free-list insertion
  `_t'1 = freeList->next; obj->next = _t'1; freeList->next = obj`. For the
  activeFlags frame, the value read from `freeList->next` may be arbitrary; the
  only target-shape requirement is that `freeList` itself points outside the
  object pool or to a valid pool-slot header.
- `statement_preserves_temp_shape_sset_different`,
  `statement_preserves_temp_shape_assign`,
  `statement_preserves_temp_shape_sequence`,
  `deallocate_object_first_splice_preserves_free_list_shape`, and
  `deallocate_object_second_splice_preserves_free_list_shape` prove that the
  generated first and second splice sequences do not clobber the `_freeList`
  temporary's header-or-external shape.
- `deallocate_object_body_shape_obligations` and
  `deallocate_object_body_pool_slot_frame_from_shape_obligations` now compose
  the whole generated `deallocate_object` body from the three segment facts.
  The remaining list-shape proof must supply exactly: the entry-time
  `obj->next` dereference shape, the entry-time `_freeList` temp shape, and the
  `obj->prev` dereference shape at the actual memory state after the first
  generated splice has executed.
- `deallocate_object_body_preserves_pool_slot_active_flags_from_shape_obligations`
  projects that body bridge to the activeFlags-only frame property, and
  `eval_funcall_internal_deallocate_object_preserves_pool_slot_active_flags_from_shape_obligations`
  carries it across CompCert's internal-function call boundary. The call-level
  theorem deliberately states the shape obligations over the real
  `function_entry2` environment/temporaries/memory produced for the call,
  avoiding an over-strong global body-frame assumption. The generated-`Scall`
  wrapper then packages this as a caller-side frame theorem over the exact
  `deallocate_object(&gFreeObjectList, &obj->header)` argument evaluation.
- `function_entry2_deallocate_object_binds_parameter_temps` proves the
  concrete generated `f_deallocate_object` parameter binding: under CompCert's
  parameter-as-temporaries semantics, the two call arguments become exactly the
  `_freeList` and `_obj` temps, and because the generated function has no local
  variables, entry memory is the call memory.
- `eval_unload_object_header_lhs_lvalue_pointer`,
  `unload_object_ge_resolves_gFreeObjectList`, and
  `unload_deallocate_object_call_argument_values` pin the caller-side generated
  argument evaluation itself: for the actual deallocation argument types,
  `&gFreeObjectList` evaluates to the global free-list symbol and
  `&obj->header` evaluates to the current object-pool slot header pointer.
- `deallocate_object_internal_call_shape_obligations_from_bound_entry_shapes`
  packages that binding fact for later list-shape work: it is enough to prove
  the deallocation body shape obligations for entry temp environments whose
  `_freeList` and `_obj` values are the actual call arguments.
- `deallocate_object_resolved_free_list_shape_obligations` and
  `deallocate_object_bound_entry_shape_obligations_from_resolved_free_list_shapes`
  further reduce that target for the actual global free-list argument. The list
  proof now needs to show that the resolved `gFreeObjectList` pointer is either
  external to the watched object-pool block or a valid pool-slot header, plus
  the entry `obj->next` dereference shape and the post-first-splice
  `obj->prev` dereference shape.
- `valid_object_slot_zero`,
  `object_node_pointer_zero_external_or_pool_slot_header`,
  `deallocate_object_resolved_free_list_deref_shape_obligations`, and
  `deallocate_object_resolved_free_list_shape_obligations_from_deref_shapes`
  discharge the free-list pointer-shape part of that checklist for the concrete
  zero-offset `&gFreeObjectList` pointer. With the current shape predicate, a
  zero-offset pointer is acceptable either because it is in an external block
  or, in the same-block fallback case, because offset zero is valid pool slot
  0's header.
- `unload_deallocate_object_call_actual_argument_shapes_from_bound_entry_shapes`,
  `unload_deallocate_object_call_empty_env_frame_from_actual_shape_obligations`,
  and `unload_deallocate_object_call_empty_env_frame_from_bound_entry_shapes`
  connect the exact generated `Scall` to that reduced target. The remaining
  list proof can now supply a bound-entry shape fact for the resolved
  `gFreeObjectList` block and the current object-pool slot header, rather than
  reasoning again about CompCert argument evaluation or `function_entry2`.
- `unload_deallocate_object_call_empty_env_frame_from_resolved_free_list_shapes`
  composes those two reductions, so the caller-side generated `Scall` can use
  the resolved-free-list checklist directly.
- `unload_deallocate_object_call_empty_env_frame_from_resolved_free_list_deref_shapes`
  is the current narrowest generated-call bridge: the caller-side `Scall` now
  only needs the entry `obj->next` dereference shape and the post-first-splice
  `obj->prev` dereference shape.
- `object_pool_link_fields_well_shaped`,
  `first_deallocate_splice_preserves_pool_link_fields`, and
  `deallocate_object_resolved_free_list_deref_shapes_from_pool_link_fields`
  restate that narrow checklist in object-list-invariant language: if every
  valid pool slot's `next`/`prev` link fields dereference only to external
  blocks or valid pool-slot headers, and the first generated deallocation
  splice preserves that link-shape invariant, then the exact resolved-free-list
  dereference-shape obligations follow. The remaining work is now to prove
  those invariant facts from the real object-list/free-list structure, not to
  rediscover the CompCert call plumbing.
- `first_deallocate_splice_shaped_store_preserves_pool_link_fields`,
  `deallocate_object_first_splice_loads_pool_link_shapes`,
  `first_deallocate_splice_preserves_pool_link_fields_from_shaped_store`, and
  `deallocate_object_resolved_free_list_deref_shapes_from_pool_link_shaped_store`
  split that first-splice preservation seam once more. The generated first
  splice now mechanically loads a shaped `_t'4 = obj->next` target and shaped
  `_t'5 = obj->prev` value from `object_pool_link_fields_well_shaped`; the
  remaining preservation obligation is the memory-level fact that performing
  the shaped `next->prev = obj->prev` store preserves the pool-link-shape
  invariant.
- `value_points_to_external_or_pool_slot_header`,
  `temp_lookup_value_pointer_shape`,
  `sem_cast_object_node_pointer_preserves_value_shape`,
  `storev_shaped_pointer_preserves_object_node_field_deref_shape`,
  `storev_shaped_pointer_preserves_object_pool_link_fields`, and
  `assign_loc_shaped_pointer_preserves_object_pool_link_fields` discharge the
  generic memory part of that preservation story. The key CompCert split is:
  after a shaped pointer store, any later object-node field load either reads
  the newly stored shaped pointer (`Mem.load_pointer_store`) or is an
  unaffected old load (`Mem.load_store_other`).
- `exec_deallocate_object_next_prev_assign_preserves_pool_link_fields_from_value_shape`,
  `first_deallocate_splice_shaped_store_preserves_pool_link_fields_holds`,
  `first_deallocate_splice_preserves_pool_link_fields_from_pool_link_fields`,
  and
  `deallocate_object_resolved_free_list_deref_shapes_from_pool_link_fields_holds`
  close the generated-code bridge for the actual first splice. The proof now
  decomposes the generated sequence, uses the second read to obtain the shaped
  `_t'5 = obj->prev` value, and applies the generic shaped-store lemma to the
  real `next->prev = obj->prev` assignment. At this level, the remaining input
  is just `object_pool_link_fields_well_shaped`.
- `empty_env_pool_slot_statement_preserves_obj_and_active_flags`,
  `empty_env_pool_slot_statement_preserves_sequence`,
  `unload_deallocate_object_call_empty_env_frame_from_deref_shape_obligations`,
  `unload_object_tail_empty_env_pool_slot_frame_from_deref_shape_obligations`,
  and
  `unload_object_tail_preserves_pool_slot_active_flags_from_empty_env_deref_shape_obligations`
  thread that narrow deallocate-call bridge through the generated cleanup tail
  in the empty-env case used by these no-local-variable generated functions.
  This is still conditional on supplying the actual dereference-shape
  invariant, but the final `deallocate_object` leaf is no longer represented
  as an opaque generic frame in this empty-env path.
- `unload_deallocate_object_call_empty_env_pool_link_shape_obligations`,
  `unload_deallocate_object_call_empty_env_deref_shape_obligations_from_pool_link_shapes`,
  `unload_object_tail_empty_env_pool_link_shape_frame_obligations`,
  `unload_object_tail_empty_env_pool_slot_frame_from_pool_link_shape_obligations`,
  and
  `unload_object_tail_preserves_pool_slot_active_flags_from_empty_env_pool_link_shape_obligations`
  lift the empty-env tail bridge one rung lower again: the deallocate leaf can
  now be supplied by the pool-link-shape invariant plus first-splice
  preservation, instead of directly assuming the two dereference-shape facts.
- `unload_deallocate_object_call_empty_env_pool_link_store_obligations`,
  `unload_deallocate_object_call_empty_env_pool_link_shape_obligations_from_store_obligations`,
  `unload_deallocate_object_call_empty_env_deref_shape_obligations_from_pool_link_store_obligations`,
  `unload_object_tail_empty_env_pool_link_store_frame_obligations`,
  `unload_object_tail_empty_env_pool_link_shape_obligations_from_store_obligations`,
  `unload_object_tail_empty_env_pool_slot_frame_from_pool_link_store_obligations`,
  and
  `unload_object_tail_preserves_pool_slot_active_flags_from_empty_env_pool_link_store_obligations`
  expose that smaller shaped-store seam all the way up at the cleanup-tail
  frame boundary. Future traversal work can therefore supply pool-link
  well-shapedness plus shaped-store preservation directly.
- `unload_deallocate_object_call_empty_env_pool_link_fields_obligations`,
  `unload_deallocate_object_call_empty_env_pool_link_shape_obligations_from_field_obligations`,
  `unload_deallocate_object_call_empty_env_deref_shape_obligations_from_pool_link_field_obligations`,
  `unload_object_tail_empty_env_pool_link_fields_frame_obligations`,
  `unload_object_tail_empty_env_pool_link_shape_obligations_from_field_obligations`,
  `unload_object_tail_empty_env_pool_slot_frame_from_pool_link_field_obligations`,
  and
  `unload_object_tail_preserves_pool_slot_active_flags_from_empty_env_pool_link_field_obligations`
  remove that extra shaped-store assumption from the exposed empty-env seam.
  The cleanup-tail bridge can now be driven by the helper-call frame facts plus
  the pool-link field invariant alone.
- `unload_object_tail_preserves_pool_slot_active_flags_from_named_frames`
  projects that bridge into the activeFlags-only property needed by the
  deactivation proof.
- `pool_slot_field_address` normalizes CompCert pointer arithmetic for any
  field offset inside a valid 608-byte object-pool slot. The specialized
  direct-store lemmas prove that `prevObj` (`slot*608+108`, 4 bytes),
  `throwMatrix` (`slot*608+80`, 4 bytes), and graph-node `flags`
  (`slot*608+2`, 2 bytes) do not overlap the same slot's activeFlags bytes
  (`slot*608+116..117`). `ObjectNode.next` and `ObjectNode.prev` are now also
  pinned at offsets `96` and `100`, respectively, for the deallocation-body
  list-pointer proof.
- `pool_slot_throw_matrix_nested_address` normalizes the exact nested Clight
  address shape produced by `obj->header.gfx.throwMatrix`: adding `header`
  offset 0, `gfx` offset 0, and `throwMatrix` offset 80 reduces to the
  concrete pool byte address `slot*608+80`.
- `pool_slot_graph_flags_nested_address` does the same for
  `obj->header.gfx.node.flags`: adding `header` offset 0, `gfx` offset 0,
  `node` offset 0, and `flags` offset 2 reduces to `slot*608+2`.
- `pool_slot_header_address` covers the final deallocation argument
  `&obj->header`, normalizing the object header address to `slot*608+0`.

This is a semantic Clight execution lemma, not merely an AST census. The tail
obligation remains explicit rather than being hidden behind an axiom, but it is
now a standard memory-frame obligation over a two-byte watched region. All
direct cleanup stores (`prevObj = NULL`, `throwMatrix = NULL`, and the two
graph-node `flags` stores) are closed. The final deallocation call is also
pinned to its exact generated arguments; its empty-environment function lookup
and caller-side `Scall` frame bridge are closed, and its internal-call mechanics
are reduced to the generated body frame property. Inside that body, the
`obj->next = t'1` store is closed for the same object slot, and the generated
body is compositionally reduced to three named store obligations. The
`next->prev`, `prev->next`, and `freeList->next` obligations are each closed
once the object-list/global proof supplies the header-or-external shape of their
target temps. The whole tail is now reduced to a
refined same-object frame checklist: `stop_sounds_from_source`,
`geo_remove_child`, `geo_add_child`, and `deallocate_object`. The cleanup call
targets are separated from the known allocation/deletion activeFlags writers by
generated-code census facts; semantic alias/frame arguments for the calls are
still required.

## Mechanized traversal invariant

`proofs/TraversalModel.v` factors the two nested loops in
`unload_objects_from_area` into the representation obligations the Clight proof
must establish. A well-formed snapshot has exactly 13 object lists, no slot
appears twice, every live pool slot appears in the flattened lists, and each
snapshot area tag agrees with the concrete `activeAreaIndex` byte in memory.
Rocq proves that filtering this snapshot for area 1:

- has no duplicate targets;
- contains every `outside_live_slot`; and
- forbids continuous item transfer whenever the Clight execution supplies the
  corresponding deactivation trace.

The remaining traversal bridge is therefore concrete: derive that snapshot
and trace from the circular-list execution of the generated
`f_unload_objects_from_area`.

## Stale-pointer / cloning edge

The cloning-motivated edge case is now part of the proof scope. The important
distinction is:

- raw pointer/slot reuse: an area-2 object, such as an in-pyramid goomba, may
  be allocated in the same `gObjectPool` slot formerly occupied by an unloaded
  area-1 item;
- outside allocation-epoch preservation: a Mario/object reference still carries
  the old area-1 item identity and then acts on the newly allocated slot.

The first situation is possible in SM64's allocator and must not be confused
with item transport. The second is the dangerous stale-pointer cloning channel.

Current generated-Clight facts close the main MarioState version of that
channel for the pyramid warp spine:

- `mario.f_init_mario` directly clears `heldObj`, `riddenObj`, and `usedObj`;
- `level_update.f_init_mario_after_warp` has the ordered event subsequence
  `load_mario_area`, `init_mario`, `set_mario_initial_action`,
  assignment to `interactObj`, assignment to `usedObj`;
- a stronger generated-Clight event theorem pins the source of those final
  assignments: after `init_mario`, the wrapper reads `spawnNode->object` into
  generated temporaries and assigns those temporaries to `interactObj` and
  `usedObj`;
- `level_update` has no direct `heldObj` or `riddenObj` writer.

`proofs/StalePointerModel.v` formalizes the provenance statement: if after the
warp `interactObj` and `usedObj` are destination-spawn references while
`heldObj` and `riddenObj` are null, then Mario's four object-reference fields
contain no stale outside allocation epoch. It also proves that deactivating a
slot at the unload barrier means later raw slot reuse is not a continuous item
transfer.

The render-side held-object graph path has now been brought into the same
clightgen/Rocq route. `src/game/mario_misc.c` generates
`generated/mario_misc.v`, and `proofs/RenderHeldObjectFacts.v` proves that
`geo_switch_mario_hand_grab_pos` is the only direct writer of
`GraphNodeHeldObject.objNode` in that TU. It also pins the generated event
sequence in the function body: clear `objNode` to null, read
`marioState->heldObj`, and, in the non-null branch, assign that held-object
temporary back to `objNode`. Consequently, once the warp spine has cleared
`MarioState.heldObj`, this render graph path is not an independent persistent
outside-item pointer.

So far, I do not have a counterexample: the obvious stale-pointer-to-goomba
scenario would require an outside item reference to survive the warp, and the
current generated-Clight facts show the relevant MarioState references are
cleared or rebound before pyramid control resumes; the render-side held-object
graph pointer is refreshed from the cleared `heldObj` field rather than kept
independently. This remains weaker than a complete whole-engine clone
impossibility proof until the remaining non-Mario/render reference channels are
either ingested or ruled unreachable.

## Linking boundary

Per-translation-unit Clight marks cross-file calls as external. The proof must
not grant those calls arbitrary behavior merely because they are external in
one generated file. `proofs/SymbolicLinking.v` uses CompCert's linking
metatheory, keeping the linked program opaque, to show that the core symbols
resolve to their actual internal bodies whenever the linked program contains
the `level_update`, `area`, `object_list_processor`, `spawn_object`,
`graph_node`, `mario`, and `audio/external` programs. In particular,
`stop_sounds_from_source` is no longer left as an unconstrained external call;
its real C body is generated and the whole audio TU has no direct
`activeFlags` writer.

Still required is a reproducible certificate that these seven generated
programs successfully form the chosen linked program and the semantic
alias/separation proof that their graph-list and audio-bank writes cannot
overlap an object's `activeFlags` bytes.

## Current capstone

`proofs/PyramidTransition.v` defines `pyramid_transition_certificate`. It
bundles:

- the concrete SSL destination fields and current outside-area field;
- the well-formed 13-list snapshot; and
- the area-1 deactivation trace.

The theorem
`certified_pyramid_transition_forbids_continuous_item_transfer` is fully proved
and has no project-added axioms. The project is not finished merely because
this conditional capstone exists: the remaining central theorem must construct
that certificate from a big-step execution of the symbolically linked Clight
transition spine.

## Known edge case: fake-object slot reuse

`act_picking_up` contains a documented stale-pointer glitch: the `usedObj`
slot can unload during the pickup animation, allowing Mario to pick up a vacant
or newly loaded slot. That kind of edge can be cloning-relevant in general.
For the SSL pyramid transition, however, the currently audited warp spine
clears/rebinds the MarioState object-reference fields before area-2 play
resumes. Thus the known pickup stale slot is not yet a counterexample to the
pyramid-entry claim; a counterexample would need a surviving reference outside
the four MarioState fields above, or a path that bypasses the `init_mario` /
`init_mario_after_warp` cleanup sequence.

## Outside object-channel census

The mechanically generated SSL area-1 macro table contains the ordinary
hold/ride transport candidates:

- two `bhvBobomb` objects;
- two `bhvJumpingBox` objects;
- one `bhvBreakableBoxSmall` object;
- one `bhvExclamationBox` configured to spawn a Koopa shell.

The first three behaviors are the area-1 `INTERACT_GRABBABLE` candidates. The
shell is a separate `riddenObj` channel.

Area 1 also contains three exclamation boxes configured for Wing Caps, plus
coins and 1-Ups. The generated census now pins the three Wing Cap boxes too.
`init_mario` resets `capTimer` and restores only the normal-cap state during an
area warp, so a picked-up Wing Cap is a distinct state-transfer channel that
must be ruled out separately; it is not represented by `heldObj`. Coins and
1-Ups are consumed into counters rather than transported as continuous object
allocations, and the final theorem must say explicitly whether such persistent
counter effects are outside the word “item.”

The proof also has to cover dynamically spawned descendants and glitch-created
stale-slot references; this finite list is the hold/ride root set, not the whole
area-1 object set.

The current Rocq census also pins every *direct, named-field* assignment to
`activeAreaIndex` in the generated spawning/area/object TUs. It is intentionally
not yet a semantic non-write theorem: stores through aliases, external calls,
and omitted translation units remain obligations until the provenance/frame
argument closes them.

## ROM requirement

A ROM is not needed for source-level reconnaissance or for proof work against
already generated Clight. A legally obtained US ROM with SHA-1
`9bef1128717f958171a4afac3ed78ee2bb4e86ce` may later be needed to:

- extract build-generated assets/headers required by additional translation
  units;
- independently rebuild and byte-compare the pinned decompilation;
- corroborate the formal boundary predicate in an emulator.

## Clight input patch

CompCert 3.15 rejects C `long double` constants. The pinned
`object_helpers.c` has seven such literals in functions unrelated to the
area-transfer core. The generation pipeline copies the source and applies
`patches/object_helpers-clightgen.patch`, changing only the `L` suffixes to
ordinary `double` constants. The upstream checkout remains untouched.

This is an explicit C-to-Clight seam. Its intended justification is that the
N64 toolchain represents these values at 64-bit double precision; before the
final theorem, either that ABI fact must be cited and audited or the patched
functions must be proved unreachable from the theorem's execution slice.
