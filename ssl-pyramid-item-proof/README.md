# SSL Pyramid item-transfer proof

This project aims to prove, against mechanically generated CompCert Clight,
that an object originating in Shifting Sand Land area 1 cannot remain the same
live object across the area-change warp into the Pyramid (area 2). If the claim
is false, the project will instead contain a concrete counterexample.

This directory is intended to live inside the WMotR proof repository as
`ssl-pyramid-item-proof/`. To reproduce the generated Clight, provide a separate
checkout of the SM64 decompilation source pinned at commit
`9921382a68bb0c865e5e45eb594d9c64db59b1af`. By default, the scripts look for
that checkout at `../../reference-sm64-decomp`, as a sibling of the containing
proof repository. Set `SM64_SOURCE=/path/to/sm64` for shell scripts or
`SM64=/path/to/sm64` for `make` if your checkout uses a different layout.

## Intended route

Pinned US SM64 decompilation source -> CompCert `clightgen` -> generated Clight
ASTs -> Rocq lemmas over CompCert's execution semantics -> an auditable
area-transition theorem.

Generated Clight files are never hand-edited.

## Current status

The isolated toolchain is operational:

- OCaml 4.14.2
- Coq 8.16.1
- CompCert/clightgen 3.15, rebuilt for 32-bit big-endian `ppc-eabi`

Seventeen transition-, object-, audio-, render-, and SSL-specific translation units are currently
generated and compile. Rocq checks now pin:

- both area-1 Pyramid warp destinations;
- the grabbable/ridden area-1 object census;
- the direct `activeAreaIndex` writer census in the ingested TUs;
- the unload/load call order;
- the generated-Clight post-warp pointer spine: `init_mario` clears
  `heldObj`, `riddenObj`, and `usedObj`, and `init_mario_after_warp` later
  rebinds `interactObj`/`usedObj` from `spawnNode->object`, the destination
  spawn object;
- N64 object-pool and Mario-state field layouts;
- the allocation-epoch definition of object identity;
- memory lemmas showing a deactivation trace rules out continuous transfer;
- a stale-pointer provenance model showing that post-warp Mario references of
  the shape above contain no preserved outside allocation epoch, even if an
  area-2 object later reuses the same raw pool slot;
- the render-side held-object graph refresh in `mario_misc.c`:
  `geo_switch_mario_hand_grab_pos` is the only direct writer of
  `GraphNodeHeldObject.objNode` in that TU, and its generated Clight clears
  the field before refreshing it from `MarioState.heldObj`;
- the real generated `unload_object` body writes zero to the addressed
  object's `activeFlags`, including normalization from a `gObjectPool` pointer
  to the corresponding 608-byte pool slot;
- a CompCert `Mem.unchanged_on` frame lemma showing that any execution of the
  `unload_object` cleanup tail that leaves the two activeFlags bytes unchanged
  preserves the deactivation result, plus layout facts that the tail's direct
  object-field stores (`prevObj`, `throwMatrix`, graph-node `flags`) are below
  the `activeFlags` bytes;
- a compositional frame bridge for the generated cleanup tail: `Sskip`/`Sset`
  leaves are discharged automatically and `Ssequence` frames are composed with
  `Mem.unchanged_on_trans`, so the remaining tail proof is reduced to the four
  cleanup calls;
- a correctly scoped same-object variant of the unload theorem: it is enough
  to prove the cleanup tail leaves unchanged the activeFlags bytes of the
  object currently stored in `_obj`, rather than every activeFlags-shaped byte
  range in memory;
- the generated cleanup tail never writes the `_obj` temporary, and by-value
  Clight assignments preserve the watched activeFlags bytes whenever their
  concrete store range is disjoint from those bytes;
- the concrete generated `obj->prevObj = NULL` cleanup statement preserves the
  same slot's activeFlags bytes: its 4-byte store at `slot*608+108` is
  disjoint from `slot*608+116..117`;
- the next generated cleanup statement is pinned as
  `obj->header.gfx.throwMatrix = NULL`, with the nested generated offsets
  `header +0`, `gfx +0`, and `throwMatrix +80` normalized to the concrete pool
  address `slot*608+80`, and with the generated lvalue classified as a 32-bit
  by-value pointer store. Its same-slot activeFlags frame obligation is now
  discharged semantically;
- the two generated graph-node `flags` cleanup stores after `geo_add_child`
  are pinned as separate generated sub-statements; their shared
  `obj->header.gfx.node.flags` lvalue has offsets `header +0`, `gfx +0`,
  `node +0`, and `flags +2`, normalizing to `slot*608+2`, and is classified
  as a signed 16-bit by-value store;
- the graph-node `flags` read-temp halves (`_t'2 = flags` and `_t'1 = flags`)
  are semantically discharged: they do not write `_obj` and do not change
  memory. The two actual `flags` assignments are also discharged as same-slot
  frame obligations: their signed 16-bit stores at `slot*608+2` cannot overlap
  the same slot's activeFlags bytes at `slot*608+116..117`;
- the final generated cleanup call is pinned exactly as
  `deallocate_object(&gFreeObjectList, &obj->header)`, with `obj->header`
  classified as a by-copy aggregate and normalized to `slot*608+0`;
- a semantic generated-tail theorem showing that executing
  `unload_object_tail` preserves the `_obj` temporary value, so the same-object
  frame obligation can be carried through the concrete cleanup sequence;
- a named same-object pool-slot frame bridge for the cleanup tail: once the
  refined remaining named leaves are proved to preserve `_obj` and the
  relevant activeFlags bytes, the whole generated tail has that frame property.
  The `prevObj = NULL`, `throwMatrix = NULL`, and both graph-flags assignments
  are already discharged semantically, reducing the current remaining checklist
  to `stop_sounds_from_source`, `geo_remove_child`, `geo_add_child`, and
  `deallocate_object`;
- a CompCert internal-call bridge for `deallocate_object`: if the generated
  body has the activeFlags frame property, then calling the internal
  `f_deallocate_object` preserves that property through `function_entry2` and
  the empty local-variable free list. The empty-environment global lookup is
  now proved to resolve `deallocate_object` to the generated internal
  `f_deallocate_object`, and the actual empty-env generated `Scall` is proved
  to preserve `_obj` and the watched activeFlags bytes whenever the generated
  `deallocate_object` body has that frame property. The remaining
  deallocation work is the body/list-pointer separation argument, without
  relying on an over-strong arbitrary-environment shadowing claim;
- the first concrete deallocation-body store has been discharged for the
  object currently being unloaded: `deallocate_object`'s generated
  `obj->next = t'1` assignment writes the `ObjectNode.next` field at
  `slot*608+96`, which is disjoint from the same object's activeFlags bytes at
  `slot*608+116..117`. The whole generated `deallocate_object` body is now
  compositionally reduced to three exact remaining store obligations: the
  writes through `obj->next`, `obj->prev`, and `freeList`. All three are now
  discharged conditional on a precise target-shape fact: the store target temp
  points either outside the object-pool block or to the header of a valid pool
  slot. The generated `Sset` field reads now also have a mechanized bridge:
  if the dereferenced `ObjectNode.next`/`prev` field is known to yield only
  external pointers or valid pool-slot headers, then the exact generated temps
  (`_t'4`, `_t'5`, `_t'2`, `_t'3`, and `_t'1`) inherit that shape. The remaining
  deallocation work is to prove those dereference/target-shape facts from
  object-list/global free-list invariants. The first splice sequence
  (`_t'4 = obj->next; _t'5 = obj->prev; _t'4->prev = _t'5`) is now proved as
  an activeFlags frame under the `obj->next` dereference-shape hypothesis; the
  second splice sequence
  (`_t'2 = obj->prev; _t'3 = obj->next; _t'2->next = _t'3`) is likewise proved
  under the `obj->prev` dereference-shape hypothesis; and the final free-list
  insertion sequence
  (`_t'1 = freeList->next; obj->next = _t'1; freeList->next = obj`) is proved
  as an activeFlags frame from the shape of the `freeList` temp itself. These
  segment facts are now composed into a body-level generated-Clight bridge:
  `deallocate_object` preserves the watched activeFlags bytes if the list proof
  supplies the entry `obj->next` dereference shape, the entry `freeList` temp
  shape, and the `obj->prev` dereference shape at the actual post-first-splice
  memory state;
- the complete generated `spawn_object` direct-writer census for
  `activeFlags`: exactly `unload_object`, `allocate_object`, `create_object`,
  and `mark_obj_for_deletion` write that field directly;
- generated-code cleanup-call facts: `audio_external` has no direct
  `activeFlags` writer, `stop_sounds_from_source` does not write through its
  `pos` parameter, and `deallocate_object`, `geo_remove_child`, and
  `geo_add_child` have no direct `activeFlags` assignment;
- pool-slot pointer-arithmetic lemmas for the direct cleanup stores:
  `slot*608+108` (`prevObj`), `slot*608+80` (`throwMatrix`), and `slot*608+2`
  (graph-node `flags`) are normalized CompCert addresses and their store byte
  ranges are disjoint from `slot*608+116..117` (`activeFlags`). The same
  arithmetic is now pinned for `ObjectNode.next`/`prev` at `slot*608+96` and
  `slot*608+100`;
- a 13-list traversal invariant showing that a duplicate-free object-list
  snapshot covering all live slots selects every live area-1 slot and that a
  matching deactivation trace forbids continuous transfer;
- a symbolic CompCert-linking interface that resolves `warp_area`,
  `unload_mario_area`, `unload_area`, `unload_objects_from_area`,
  `unload_object`, its audio and graph-node helpers, and `init_mario` to their
  genuine internal Clight bodies in any linked program containing the seven
  core TUs.

The reproducibility check also audits the full pinned source tree and fails if
the seven named `activeAreaIndex` assignments change or a new assignment
appears.

`PyramidTransition.v` now provides the capstone theorem over an explicit
certificate: an SSL area-1-to-area-2 warp predicate, a well-formed 13-list
snapshot, and the corresponding deactivation trace imply that no outside
allocation epoch remains continuously live across the barrier.

This is not yet the final impossibility theorem. The main open bridge is to
prove the remaining `Mem.unchanged_on` frame property for `unload_object`'s
cleanup tail leaves (the three external cleanup calls plus the
`deallocate_object` list-shape obligations described above), then lift the
result through the `unload_objects_from_area` traversal and the linked Clight
execution of `warp_area`/`unload_area`. The currently mechanized stale-pointer
result covers Mario's `interactObj`/`heldObj`/`usedObj`/`riddenObj` provenance
through the warp spine and the render-side `GraphNodeHeldObject.objNode`
refresh path.

## Build

Use a Unix-like shell with `opam`, Coq, and CompCert available. The helper
script below activates the opam switch named by `SM64_ITEM_SWITCH` (default:
`sm64-item-proof`). The SM64 decompilation source is auto-detected in the
default layout described above; set `SM64_SOURCE=/path/to/sm64` for the shell
scripts or `SM64=/path/to/sm64` for `make` if your checkout uses a different
layout.

```sh
export PATH="$HOME/.local/bin:$PATH"
source pipeline/env.sh
make generated
bash pipeline/check.sh
```

The working statement and residual proof obligations are tracked in
`docs/claim.md`.
