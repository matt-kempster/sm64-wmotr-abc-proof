# Stock node 1E: stale aliases and coordinate desync

## Verdict

| Candidate | Can occur in SSL area 1? | Solves stock node 1E? |
| --- | --- | --- |
| Valid stale object-slot alias | Conditionally yes. JP preserves a non-null pointer, and allocation can reuse its still-valid pool slot. | No. The platform query at node 1E overwrites the old pointer with `NULL`. |
| MarioState/Mario-object coordinate desync | Yes, transiently. Platform displacement writes `MarioState.pos` before collision reads the old Mario-object position. | Conditionally the right shape, but no stock setup supplies its required non-null pointer at node 1E. |

The conclusions are about stock, valid object-pool behavior and the audited SSL
area-1 writers. They do not assume that slot contents are cleared on unload.

## Stale slot alias

An unloaded object remains a valid address inside `gObjectPool`. Deallocation
pushes that slot onto the free-list front, and allocation pops the front. In
JP, `spawn_objects_from_info()` does not clear `gMarioPlatform`. Therefore, if
an area-1 allocation reaches a slot named by a preserved pointer, the pointer
can validly alias the new object in that slot. The conditional Coq theorem is:

```text
jp_area1_load_can_conditionally_form_a_valid_stale_slot_alias
```

Allocation changes the object stored in the slot; it does not assign the
global pointer. In particular, it cannot turn `gMarioPlatform == NULL` into a
non-null pointer.

At stock node 1E, the level-script position is `(-2048, 768, -1024)`. The
static area collision includes the floor square with corners
`(-2149, 768, -1125)` and `(-1945, 768, -921)`. Its surfaces have no owning
object. The audited object-owned SSL area-1 surfaces do not overlap either
Area 1 -> Area 2 warp.

Consequently, the end-of-frame `update_mario_platform()` query at node 1E
selects an unowned floor, no admissible object-owned floor, or no floor. Every
such case writes `NULL`. The next frame cannot begin its displacement phase
with the old alias. This is proved by:

```text
stock_node1e_requery_clears_every_stale_slot_alias
stale_slot_alias_does_not_solve_stock_node1e
```

## Coordinate phase split

The engine does contain the exact temporary split suggested by this idea:

1. `apply_platform_displacement()` calls `set_mario_pos()`, which writes
   `MarioState.pos` but not the Mario object's `oPos` fields.
2. `detect_object_hitbox_overlap()` reads object `oPos` slots 6, 7, and 8.
3. Mario's behavior executes, then `copy_mario_state_to_object()` copies the
   state position into those object slots.
4. `update_mario_platform()` queries the copied Mario-object position.

Thus, if Mario's object were at node 1E and a preexisting platform pointer
displaced `MarioState` onto a pyramid-top floor, collision could see the warp
position while platform selection later saw the top position. The proof keeps
this positive conditional fact:

```text
platform_desync_is_conditionally_the_right_shape_for_stock_node1e
```

It is not a stock route. On the preceding synchronized frame, the platform
query uses the same Mario-object position that collision will read next and
clears the pointer at node 1E. With `gMarioPlatform == NULL`, the displacement
phase cannot create the split. Once warp interaction succeeds,
`ACT_DISAPPEARED` preempts normal action movement and only snaps Y to the
current floor; it cannot move Mario from node 1E to the top. The audited
post-copy writer search also found no persistent SSL area-1 writer that
reintroduces such a split.

The combined results are:

```text
stock_node1e_prior_requery_prevents_the_coordinate_desync
coordinate_desync_does_not_solve_stock_node1e
stock_node1e_stale_alias_and_coordinate_desync_capstone
```

The closed-world route theorem now includes both candidates explicitly.
