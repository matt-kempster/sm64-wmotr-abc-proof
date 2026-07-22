# Pyramid-top slot persistence across the SSL area transition

## Result

The supplied snapshots are consistent with the stock JP allocator, but not for
the reason that `OBJ_LIST_SURFACE` has lower priority.  If the pyramid top were
freed by the ordinary bulk area unload, list ordering would put it *nearer* the
front of the free list than the node-1E warp, and it would be allocated first.

The source-supported explanation is a synchronized early free:

1. The pyramid top deactivates on the final normal object-update frame before
   the area-change pause.
2. That frame frees the top's slot but still reloads the top collision and lets
   `update_mario_platform()` select its floor owner.
3. The two area-change pause frames perform no object update, so the pointer is
   not recomputed.
4. The later bulk area unload pushes every remaining Area 1 slot in front of
   the already-free top slot.
5. Area 2 allocations can consequently overwrite a shallower slot such as 63
   while not yet reaching the pyramid-top slot 60.

This explains how `gMarioPlatform` can still equal slot 60 even though slot 60
is inactive and remains on the free list.

## Pool slots, object lists, and the free list

These are three different notions:

- A **pool slot** is a fixed address in the 240-entry `gObjectPool`.  The
  observed numbers 55, 60, and 63 are runtime allocation-history facts.
- An **object list** controls update and bulk-unload traversal.  Generated JP
  behavior data gives Klepto list 4 (`OBJ_LIST_GENACTOR`), `bhvWarp` list 6
  (`OBJ_LIST_LEVEL`), and pyramid top list 9 (`OBJ_LIST_SURFACE`).
- `gFreeObjectList` is a singly linked allocation stack.  Deallocation pushes
  at its front; allocation pops its front.

`unload_objects_from_area()` scans list indices 0 through 12 in ascending
order.  Because each unload pushes to the front, the resulting free-list order
is the reverse of the unload order.  For objects freed in that one bulk pass:

```text
unload order:    Klepto/list 4 -> warp/list 6 -> pyramid top/list 9
free-list order: pyramid top  -> warp        -> Klepto
```

Therefore list 9 alone cannot explain slot 60 surviving after slot 63 is
overwritten.  The pyramid top has to be freed before the bulk pass, or a custom
build has to rearrange the free list.

## The synchronized final frame

The relevant stock source order is:

```text
update terrain/surface objects
  pyramid-top explode branch spawns 30 fragments and sets activeFlags = 0
  the next behavior command calls load_object_collision_model
apply_mario_platform_displacement
unload_deactivated_objects
  slot 60 is pushed to the free-list front
update_mario_platform
  the still-loaded floor has object owner slot 60
initiate_delayed_warp
  begin the two-frame area-change pause
```

The non-fading object warp uses a 20-frame delayed warp.  The setup must align
the pyramid-top explosion/deactivation with the last normal frame of that
delay.  If the top disappears earlier, a later normal frame clears dynamic
surfaces and recomputes `gMarioPlatform`; if it survives until the bulk unload,
its list-9 slot is too shallow.  The useful case is the boundary frame between
those two outcomes.

On the following normal frame, `warp_area()` runs before the destination object
update.  It unloads the remaining Area 1 objects and loads Area 2.  If the bulk
unload order has the observed form

```text
prefix -> Klepto/55 -> middle -> node-1E warp/63 -> suffix
```

then the free list is

```text
reverse(suffix) -> warp/63 -> reverse(middle) -> Klepto/55
-> reverse(prefix) -> pyramid top/60 -> older free slots
```

Thus the exact allocation order among the three observed slots is 63, then 55,
then 60.  A destination allocation count can reach 63 while leaving both 55
and 60 untouched.  The 30 pyramid fragments created by the top's explosion are
among the later bulk-unloaded objects and help bury the early-freed slot.

## Why the old top still displaces Mario

`unload_object()` changes activity/linkage and graphics fields, but does not
write the object's `rawData`.  The position, X/Z velocity, and angular-velocity
words therefore remain until `allocate_object()` reuses that slot; allocation
then zeroes the 80-entry raw-data array.

For a fully accelerated spinning top at explosion, the relevant retained
fields are:

```text
oVelX = 0
oVelZ = 0
oAngleVelPitch = 0
oAngleVelYaw = 0x1800
oAngleVelRoll = 0
```

The old position and face-angle words remain as well.  `oVelY = 5` is retained
but is not read by platform displacement.  The useful effect is the nonzero yaw
rotation about the stale pyramid-top origin.  JP spawning does not clear
`gMarioPlatform`, and the first Area 2 displacement call checks neither
`activeFlags` nor free-list membership before reading those words.

## Formal statements

`proofs/PyramidTopSlotPersistence.v` proves, without axioms or admissions:

- `push_front_reverses_area_unload_groups`
- `bulk_unloaded_surface_would_precede_level_warp`
- `observed_transition_free_list_layout`
- `observed_slot_exact_reuse_indices`
- `observed_reuse_order_is_warp_then_klepto_then_pyramid_top`
- `warp_slot_can_be_reused_while_klepto_and_top_slots_remain_free`
- `final_normal_frame_can_reselect_already_freed_top_slot`
- `later_bulk_unload_buries_top_without_changing_the_pointer_or_fields`
- `unload_preserves_all_platform_displacement_fields`
- `unreached_watched_slot_keeps_stale_fields`
- `unreused_pyramid_top_slot_drives_first_area2_displacement`
- `generated_jp_clight_observed_pyramid_top_slot_capstone`

The generated JP Clight certificate checks the list IDs, ascending 0..12 area
scan, absence of raw-data clearing during unload/deallocation, raw-data reset
during allocation, pyramid-top explosion/collision commands, object-update
order, and absence of object updates during the area-change pause.

## Assumptions and limits

- The slot numbers 55, 60, and 63 come from the supplied runtime snapshots;
  source code does not assign those fixed slots to those behaviors.
- The concrete ordering theorem assumes a valid duplicate-free free list and
  the stated bulk-order decomposition.  It does not infer the complete runtime
  object census from the images.
- The early-free result assumes the explosion is synchronized to the final
  normal frame and that Mario is within four units of the top-owned floor when
  `update_mario_platform()` runs.
- Moving node 1E to the pyramid top is a test modification, not a demonstrated
  stock-game route.
- The source tree also contains a compile-time-disabled TAS helper that can
  explicitly move a stale slot to a requested free-list depth.  The JP Clight
  modules used here are generated without that flag; this proof concerns the
  ordinary push-front/pop-front allocator.
- The Clight bridge is an executable AST certificate plus a functional model,
  not a complete CompCert small-step proof of every frame.
