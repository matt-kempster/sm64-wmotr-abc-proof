# JP Rank-1 live-boundary receipt

This read-only receipt follows one uninterrupted original-JP frame from
`update_objects` entry at global timer 348 through the next entry at timer
349.  It starts only after the accepted level-select entry receipt has fixed
Mario, the object pool, and the two surface-pool ranges.  It never patches
RAM, controller state, code, or collision data.

The watch covers both shared-main-pool allocations, both spatial partitions,
the allocator heads, and the two surface-pool pointer cells.  Every store into
the surface allocations must execute in the authenticated surface loader,
stay within one correctly aligned dynamic record, and leave the static
prefixes untouched.  Every dynamic list-head update must contain either null
or a node from the current dynamic suffix.  At frame end the probe traverses
all static and dynamic lists, checks ordering, uniqueness and complete node
coverage, and rechecks every recorded owner in the same intact object-list
ring with the same behavior and live slot.  Both cached and uncached MIPS
aliases of every protected range are watched, effective addresses are
normalized to the same physical RAM, and a store that merely overlaps a
range boundary is rejected rather than silently treated as an outside write.

The frame performs one genuine main-pool allocation and free.  The allocation
starts with its header exactly at `0x801AB530`, the exclusive end of the
surface payload, moves the left head upward to `0x801C0FE0`, and the later
`geo_process_root` free restores it to `0x801AB530`.  All four allocator-global
writes pass the half-open range check, and no store overlaps either surface
allocation.  This is stronger than merely observing that the heads happen to
match at the two endpoints.

Six moving triangles are installed.  Each exact `0x80383904`
`gCurrentObject -> Surface.object` store is paired with one later dynamic
`add_surface` call, and all six owners remain live, in the same list, with the
same behavior through the final scan.  The 24 dynamic nodes are exactly the
new suffix `4346..4369`, each is reachable once from the dynamic partition,
and all 4,346 static nodes remain reachable once from the untouched static
partition.

The final platform query is also part of this frame.  At
`(653.0, 38.0, 6566.0)` it selects static surface-pool index 808,
`0x80199D70`, exactly once from the queried static floor list.  Its owner and
`gMarioPlatform` are both null.  Its type and vertices are the stock
`SURFACE_HARD` triangle `(214,225,223)` in
`levels/ssl/areas/1/collision.inc.c`: `(294,38,6182)`,
`(294,38,6874)`, `(986,38,6874)`.  The selected record has normal `(0,1,0)`
and origin offset `-38.0`.

Of the narrowed outside roots, only the already-certified two-instruction,
store-free `sqrtf` runs in this frame, 162 times.  The camera-shake and sound
roots are not reached.  Their independent retail-machine frames remain in
[`../jp-rank1-outside-frames/`](../jp-rank1-outside-frames/) and
[`../jp-mips-external-frames/`](../jp-mips-external-frames/) for a run that
does reach them.

Run the complete check with:

```sh
bash run.sh /path/to/baserom.jp.z64
```

`verify.sh` first authenticates the original-JP ROM and 2,200 exact retail
instructions spanning the allocator, graphics-pool caller/free, object frame,
surface loader, `find_floor`, and final platform query.  `run.sh` then compiles
the probe, performs the bounded zero-A run, and requires an exact match with
`expected-live-boundary-receipt.txt`.

This closes the listed allocator-overlap, owner-copy, stale-node, and selected
floor alternatives for the concrete baseline frame.  The next section gives
the completed extension through one real upper-warp run; neither finite
receipt is by itself a universal induction over every controller history.

## Continuous four-pillar upper-warp run

The target extension is now available as search mode 12:

```sh
bash run.sh /path/to/baserom.jp.z64 3500 12 2810
```

This is an independently constructed original-JP route, informed by the
user-supplied 2013 pannenkoek2012 video but not dependent on its unknown region
or unavailable `.m64` input.  It touches the four pillar detectors at global
timers 848, 1065, 2390, and 2548; starts the top at 2549; picks up the west
jumping box at 2671; lets the top explode at 2700; lands near the top at 2776;
performs a B-only stomach-slide rollout at 2782; and enters the upper warp at
2807–2808.  Area 2 loads at 2830.  The result requires
`mode12PillarsComplete=1`, `warpDisappeared=1`, `warpUsedObj=1`, and all three
A counters equal to zero.

The continuous receipt covers timers 348 through 2809 inclusive: 2,462
consecutive frames.  It pairs all 149,578 `find_floor` calls with return-side
checks, including 426 dynamic-floor returns, and rejects any returned dynamic
surface whose installed owner is inactive, unlinked, changed, or in the wrong
object list.  Every return passes, every frame's dynamic clear precedes its
first query, and Mario's final platform result is ownerless and static in all
2,462 frames.

One real lifecycle wrinkle appears at timer 2700.  The pyramid top deactivates
itself and its behavior script then loads six collision triangles before the
end-of-frame unloader removes the object.  The refined invariant records six
inactive owner stores and six pending-clear surfaces rather than pretending
the owner remains live.  All 99 floor calls in that frame return no dynamic
surface, timer 2701 clears the suffix before any query, and that frame also
returns no dynamic surface.  The interval is therefore real but inert on this
execution.  `Area1Rank1UpperWarpTraceReceipt.v` packages the finite route,
query, and pending-clear facts.

The run closes the named Rank-1 escapes for this successful schedule.  It
does not quantify over every possible input history, establish an
IDO-MIPS-to-Clight simulation, or decide out-of-bounds/ACE/DMA behavior.
