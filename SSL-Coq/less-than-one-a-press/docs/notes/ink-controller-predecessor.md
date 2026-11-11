# Working backward from the staged Ink installation

**No controller-only Ink setup was found in this search.** The original
Japanese [staged replay](ink-installation-demo.md) completes the warp and
lands outside the elevator once the useful split is supplied. The new
search uses only controller inputs from the existing level-select entry.
A stays released, and the search supplies no Mario, object, RNG or floor
state.

## The update that a predecessor must enable

1. Collision detection samples Mario's raw Object position near the upper
   warp. Its stock bottom-height ceiling is Y=818.
2. Geometry must select a floor belonging to the top. In the demo, the first
   movement query at Y=768 misses and the retry uses stored display
   Y=1938.8648681640625. In the
   [low-display variant](rank1-low-display-backward.md), movement Y=1861
   reaches the top on the first query while collision and display are still
   at Y=768. Either setup needs a real earlier producer of the split.
3. After the warp accepts, the disappearing action snaps movement to the
   cached floor. The ordinary copy then raises raw collision position. The
   final platform query must find the top within four units and remember it
   through the transition.

The 1170.864868-unit demonstration gap is one working example. The
[signed-range geometry](ink-fallback.md) gives a 385-unit necessary
height separation for the stock Y=1281 floor lower bound and 78-unit query
allowance. The smaller number does not guarantee a top hit or capture.

## Two western Crazy Box searches

The controller prefixes reproduce the accepted Mode 12 replay in the
pinned JP Wafel runtime. Branches restore only checkpoints produced by that
prefix. The second batch branches with three pillars credited so the box
can be used before starting the top.

| Branches | Controller changes | Area-1 samples | Observed outcome |
| --- | --- | ---: | --- |
| 194 | Six pre-pickup branches vary approach, stick strength and pickup distance. Five later checkpoints vary the flight target and B/Z exit. | 39,749 | The closest spinning-top sample is 2,857.42 units from the warp horizontally, at collision Y=106.58. Twenty-eight schedules later show the upper-warp disappearing action. |
| 54 | Three earlier checkpoints vary the detour past the fourth pillar and the box approach. Once grabbed, steer to the fourth pillar before aiming at the warp. | 22,680 | Fifty-three first bounce with three pillars credited. Nine then start the top, all with empty hands at the fourth credit. The best reaches 3,223.05 units from the warp while the top spins. |

The 248 schedules advance 63,420 updates. Across the 62,429 Area-1 samples
the upward maxima for both display-minus-collision and movement-minus-
collision Y are zero. There are 383 samples with some coordinate
disagreement in eight later branches. None has a positive value for either
vertical difference. No stored floor is null, no depth is negative, and the
original top is never the remembered platform in these samples. The
distance and height screen uses the stock warp hitbox; exact floor and
interaction events require the native checks below.

## Original-ROM checks

The existing read-only observer checks collision entry, the actual
first/second geometry queries, accepted warp return and the final platform
query. The full Mode 12 trace extends the earlier observer window back to
the first post-entry frame. Three chosen input files are then replayed
from the same entry without restoring a mid-level state.

| Replay | First queries | Retries | Final queries | Upper warp |
| --- | ---: | ---: | ---: | --- |
| Full Mode 12 | 2,480 | 0 | 2,480 | Accepts at timer 2807; first Area-2 platform phase leaves Mario at `(0,5500,256)`. |
| Closest post-pillar branch, 014 | 211 | 0 | 211 | Outside warp range while the top is spinning; no acceptance in the tested window. |
| Post-pillar warp branch, 116 | 211 | 0 | 211 | Accepts at timer 2840, with all three positions `(-1995,816,-1001.5966796875)`, no active top and no retained platform. No Area-2 entry is observed in the window. |
| Closest box-before-fourth branch, 045 | 421 | 0 | 421 | Starts the top at timer 2873 and does not accept in the tested window. |

All 6,646 observed floor results are static and ownerless. At collision
entry and at the first query, both useful upward differences are zero or
negative in these replays. The 014 and 045 full input sequences agree with
Wafel on every checked field across 2,411 and 2,573 Area-1 snapshots.
In 116 the Mario position and floor fields agree, but the retired top's
recycled slot has one active-flag and 18 timer field mismatches. The table
uses the original-ROM observations for 116.

## Two other ideas

**Clone the pyramid top.** A second top could help if it provides a live
floor where Mario can touch the warp and carries a useful transform into
Area 2. The [clone audit](rank4-warp-top-clone.md) checks 2,353 top-mesh
loads on the stock route, all from the original top. The fragments use
their own behavior, and the recycled top slot clears its collision data
before reuse. A controller setup would need a real second collision owner
or relocation with usable collision and movement. The checked route
contains neither; other object histories remain open.

**Touch the warp while leaving level geometry.** A first floor miss can
help if the retry finds the live top. If both floor queries miss, the
[delayed-warp audit](ink-fallback.md#oob-death-check-and-delayed-warp-priority)
shows the death request is made before the cached upper-warp interaction
can run its disappearing action. In the ordinary stock path, the upper
warp has a fixed Area-2 destination and the death node leads to Castle
Area 3, node 0x65. Once a delayed warp is pending, another request cannot
replace it through the normal setter. This explains why the suggested
floorless frame does not itself retarget the warp onto the top. A real
retry onto the top, or a separately demonstrated change to the destination
or its spawn, would be a different lead.

The controller-produced gap remains open. These finite replays do not
exclude an earlier gap, other pillar orders, or other support histories.
No proof or route estimate changes on this evidence.

## Reproduce

From the SSL project with the baseline available, use the pinned
[Wafel runtime](../../instrumentation/wafel-jp-pilot/README.md).

```powershell
$capture = 'build/wafel-pilot/capture.bKv95w/inputs.jsonl'
$search = 'instrumentation/rank1-reachable-search/west_box_timing.py'
& './build/wafel-pilot/python/python.exe' $search $capture build/west-box-replay
& './build/wafel-pilot/python/python.exe' $search $capture build/box-before-fourth-replay --box-before-fourth
```

Use the [original-ROM runner and checker](../../instrumentation/rank1-reachable-search/README.md)
with `RANK1_SEARCH_FIRST` and `RANK1_SEARCH_END` poll pairs 349/2851
(baseline), 2549/2760 (014), 2641/2852 (116), and 2501/2922 (045).
The [compact receipt](ink-controller-predecessor-receipt.json) includes
capture and input hashes. The ROM, full traces and inputs remain local.
