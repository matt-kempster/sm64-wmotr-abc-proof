# Hands-free box holding from an unpatched controller history

**Hands-free holding is now reached without supplying Mario or box
positions.** A clean no-A branch acquires the stock eastern jumping box
with a dive and lands on the nearby slippery north slope. The native
`ACT_DIVE_PICKING_UP` slide exit preserves the held pointer while Mario
enters stomach slide. This removes the position-cut assumption from
acquiring this local state. It does not produce the high crawl or the
timer-130 Ink handoff: these tested histories have zero pillars credited,
the top has not started spinning, and the held-box continuation stays low.

The investigation starts at
`48a289c18409d17edc694c00fdb4b7864fcc94c7`. It builds on the
[supplied-position exception controls](ink-box-handsfree.md), using the
same pinned native JP Wafel runtime. The only non-controller initialization
is the accepted pre-entry `gDebugLevelSelect=1` setup in `create_game`.
There are no Mario/actor position or action writes, held/ridden/cache
patches, RNG edits, timer changes, or allocator edits in these new branches.
No Coq theorem or original-ROM replication is claimed by this note.

## Why the eastern box is useful

The stock eastern jumping box is at `(1120,0,6480)` in
`reference-sm64-decomp/levels/ssl/areas/1/macro.inc.c:44`. Its live slot is
47 in this accepted history; the western box remains a separate actor in
slot 49. The eastern box is near a north-facing slope that can be reached
during a dive's remaining travel after pickup. Steering through the box,
rather than stopping at its center, matters.

The source path is the one identified by the earlier local controls.
`act_dive` grabs through the actual interaction and enters
`ACT_DIVE_PICKING_UP` on a held-object landing
(`src/game/mario_actions_airborne.c:724–775`). The latter's
`INPUT_ABOVE_SLIDE` branch changes action without dropping the object
(`src/game/mario_actions_object.c:215–235`). The action setter selects
stomach or butt slide from the requested `ACT_BEGIN_SLIDING`
(`src/game/mario.c:918–924`).

The clean witness's native floor type is 19 (`SURFACE_VERY_SLIPPERY`),
with normal Y=0.9143638015. Its Mario input includes `INPUT_ABOVE_SLIDE`.
The frame log records `ACT_DIVE_PICKING_UP` followed by
`ACT_STOMACH_SLIDE`, with `heldObj` still pointing to box 47 and the box in
`HELD_HELD`. This is the slide exception, not the separate off-floor
branch and not a shell-style ridden object.

## Reproducible clean policy

Replay the first 350 inputs of the accepted recording. From there:

1. Steer at full stick toward `(1120,7100)` until within 60 X/Z units.
2. Steer toward the stock box center `(1120,6480)`.
3. Press B once when within 110 X/Z units and native forward speed is at
   least 29.
4. Continue toward `(1120,5800)` and hold Z on subsequent inputs.

The 29-speed condition ensures this policy reaches the actual fast dive
path before attempting pickup. It does not write the speed. The complete
controller sequence is stored in the receipt and the exported JSONL.

The table distinguishes completed input count from the native global
timer. The first accepted controller row advances the latter by one.

| Branch inputs | Total inputs | Global timer | Observation |
| --- | --- | --- | --- |
| 73 | 423 | 424 | B produces `ACT_DIVE` |
| 74 | 424 | 425 | Actual pickup: held box 47, Mario `Y=74` |
| 85 | 435 | 436 | Dive lands into `ACT_DIVE_PICKING_UP` at `Y=18.709110` |
| 86 | 436 | 437 | Hands-free stomach slide at `(1121.570923,35.307007,5994.399902)` |
| 127 | 477 | 478 | `ACT_STOMACH_SLIDE_STOP`, still holding box 47 |
| 165 | 515 | 516 | IDLE boundary, still holding box 47 |
| 166 | 516 | 517 | IDLE/WALKING processing drops the box; Mario remains at `Y=38` |
| 167 | 517 | 518 | Box 47 inactive |
| 168 | 518 | 519 | Slot 47 has a different behavior |

During the hands-free portion of this continuation, the maximum observed
held height is Y=114.293259. The box is released at
`(1037.259766,38,6231.840820)` in free action 1. Its inactivity one update
later is an observation of this floor-level release, not a universal
box-lifetime bound. Reading the slot's later positions as if it still
contained the jumping box would be incorrect.

The top remains in its unsolved action 0, with zero pillars credited,
throughout the 260-input continuation. Its action-0 `oTimer` is not the
spinning timer 130 used by the successful handoff. This path establishes
clean acquisition, not the required joint height/action/actor/top-phase
state.

## Bounded menu and independent replays

The finite menu uses the same accepted prefix and four southern waypoints:
`(1120,7100)`, `(600,7100)`, `(1600,7100)` and `(1120,7300)`. It combines
them with B-trigger distances 110, 140, 180, 240 and 320, retaining the
forward-speed condition, northward post-B target and 260-update horizon.

All 20 policy rows acquire the box. Nine take the hands-free slide exit.
Because the speed condition sometimes delays several radii to the same
input, these are **13 distinct input histories, including five distinct
hands-free histories**, not 20/9 independent trajectories. There are
5,200 trial updates, no crawling sample, zero pillars credited and no
sample of a spinning top. The policies that land without the exception
do not establish an exclusion of other pickups or histories.

Two selected histories were independently replayed from fresh instances:
the policy above, and waypoint `(600,7100)` with trigger distance 110.
Each replays 610 total controller inputs and matches the initial branch
snapshot plus all 260 subsequent snapshots. The second hands-free exit
occurs at global 435 and `(1332.997070,24.023331,6055.694824)`; its later
release is at floor height 0 and the box again becomes inactive on the
next update. These comparisons concern the recorded native fields, not
every hidden-state byte.

## Commands, records and remaining work

From `SSL-Coq/less-than-one-a-press`, this command exited 0:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_clean_handsfree.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-clean-handsfree-20261112-final.json --receipt build/wafel-pilot/ink-clean-handsfree-final-receipt.json --witness-inputs build/wafel-pilot/ink-clean-handsfree-east-final-inputs.jsonl
```

Output creation is exclusive; choose fresh names when rerunning. The final
compact receipt is also stored as
[`ink-clean-handsfree-receipt.json`](ink-clean-handsfree-receipt.json).
It preserves the exact policy menu, every summary, selected continuous
inputs, action events, actor identities, milestones and fresh-replay
results. The raw report retains all trial snapshots.

The script SHA-256 is
`5382fbd54214958b5547f5e77081bbe5a9c0c29b728720bf5521aea1c577b82f`;
the raw-report SHA-256 is
`aa8ff7b813ae243111d2a038329185fa7f73172fe1b458a418c1b18f450a65f0`.
The first exported full 610-input history has SHA-256
`f1cb547ac44de4044c6f174ce972fac23610a8fa3f2429347e9af4d84e919cb8`,
using UTF-8 compact JSON objects with LF line endings. The earlier pilot
exports contain identical parsed controls with Windows CRLF line endings;
their file hashes differ. Runtime and accepted-capture hashes remain those
of the preceding studies.

Clean hands-free acquisition is now an input-produced component, rather
than a supplied-position fixture. A useful subsequent path must preserve
or release the actor at sufficient height, establish high crawling, and
coordinate the four-pillar/top lifecycle. The tested continuations do not
join those requirements and do not prove that joining them is impossible.
