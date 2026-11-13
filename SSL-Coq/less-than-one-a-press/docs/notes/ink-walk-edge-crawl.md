# Walking toward the edge: no loss of the upper floor found from this setup

The requested sequence was tested from the native walking branch after the
same supplied exterior freefall: walk to the edge, lose the slippery upper
floor, start crawling, then be caught inside by rotation. **No tested path
gets past the floor-loss step.** Every sampled completed state retains the
top-owned floor and platform, with feet on the recorded floor; the native
slippery-floor flag never clears. There is no crouch, crawl startup or crawl.

The closest sampled **walking** point remains **128.758607 units inside
the edge**, at behavior 127. Allowing sliding gets closer, to **64.433955
units inside** at behavior 147. Neither is a walk-off. These are horizontal
distances from Mario's feet to the base boundary of the actual native
collision mesh, calculated for explanation; they are not native state
fields or collision radii.

This is specifically a **failure to produce the proposed walk-off from
this setup**, not a direct negative test of crawling after a successful
walk-off. Input rules triggered by losing the floor never activate here.
The finite searches do not prove that every possible steering history
fails, or that a different exterior start cannot work.

## Supplied setup and native branch points

The accepted debug level-select startup, 2,548 recorded A-off inputs,
four-pillar history and neutral waiting are inherited. Before behavior
112, the sole supplied Mario setup sets equal movement/collision/display
position to (−1975.625,1556.449829,−655.125), freefall with action state and
timer zero, facing 35840, horizontal speed zero and vertical velocity −16.
His feet start 0.699829 units above the unrounded old upper-face triangle.
The [earlier entry](ink-early-air-entry-crawl.md) and
[walking controls](ink-top-slide-to-crawl.md) retain the full supplied ledger.

The floor cache, platform, hitbox, action argument, top, other actors, timers,
pillar count and RNG are not edited. There is no supplied crawl or placement
at the edge. The guarded wrapper permits only the three controller-pad
fields afterward, with A off and native A-held/A-pressed checks every frame.
Complete saves separate alternative trials; every retained witness is also
replayed continuously from the original exterior setup without a later edit.

The fixed prefix uses raw stick (−63,10), buttons 0 at behavior 112, then
neutral through 116. The game lands on the top at 113. Raw stick (0,64),
buttons 0 at 117 produces native walking. One batch starts after this frame;
another follows the prior verified uphill walking inputs through 121 and
starts there. Both prefixes match the earlier receipt exactly.

| Native boundary | Feet Y | Horizontal distance inside edge | Meaning |
| --- | ---: | ---: | --- |
| Walking root after 117 | 1671.056885 | 212.843086 | First native walking branch; first new input executes behavior 118. |
| Separate walking root after 121 | 1618.487793 | 140.215917 | Prior uphill continuation; first new input executes 122. |
| Closest walking witness, after 127 | 1636.178711 | 128.758607 | Still walking on top, floor and platform slot 61, slippery flag set. |
| Closest overall witness, after 147 | 1671.106323 | 64.433955 | Butt slide on top, not walking and not off the edge. |

The last two rows are different histories. The behavior-127 boundary is
before the original handoff at 130. Searches continue through 150, the last
spinning update; after that update the top selects its explosion action and
resets its timer. One update here is one game-logic frame. Recorded action
dispatches inside a frame do not create extra input opportunities.

## Tests that aim at the edge

The new search does not reward staying supported or merely slowing down.
It measures the moving base boundary and favors floor loss, progress toward
the edge while walking, and crouch/crawl if either appears.

| Search | Coverage | Result |
| --- | ---: | --- |
| Walking root 117: steering and Z rules | 2,304 policy labels; 76,032 frames | No sampled support loss or clearing of slippery-floor input. |
| Walking root 121: steering and Z rules | 2,304 labels; 66,816 frames | Same result. |
| Two edge-directed beams | 297,136 one-frame candidate advances | Same result. |
| Denser walking-focused beam from 117 | 504,054 one-frame candidates | Same result; closest walking distance improves to 128.758607. |

Together these are **4,608 policy labels over 142,848 continuation frames**
and **801,190 additional beam candidate advances**. They are not that many
distinct full histories. Many policy labels produce identical inputs because
their edge, floor-loss or cleared-flag triggers are never reached. Beam
counts include repeatedly explored prefixes and alternative one-frame pads.

The policies use 16 headings in each of four systems: fixed world headings,
current nearest-edge normal, predicted rotated edge normal, and predicted
rotated uphill direction. They use raw stick magnitudes 32/64/127 and twelve
Z rules: no Z; Z or neutral-stick Z after floor loss or a cleared slippery
flag; Z near an 8- or 32-unit edge distance; and timed Z at 122/126/130,
including a neutral-stick variation. Once triggered, Z remains held; a
native crouch would receive movement to start crawl.

The first two beams use up to 98 current raw/edge-relative pad choices and
at most 64 retained states, with several objective lanes and diversity
quotas. Some layers retain fewer than 64. The refinement fills all 64 places
when available, uses 64 raw stick headings at three magnitudes plus selected
Z probes (246 pads), and prunes supported sliding states so they cannot
displace the walking candidates. It still evaluates those sliding results
before pruning them. Floor-loss and crouch/crawl states would remain eligible.
No such state is found. Neither beam scheme is exhaustive: finite menus,
heuristic retention and observed-state merging leave other histories open.

## What the code says about an actual walk-off

This paragraph is a **conditional source explanation**, not an observed
post-loss continuation from the new tests. When a walking ground step
accepts a replacement floor more than 100 units below Mario's feet, with
the ceiling check allowing the move, it returns `GROUND_STEP_LEFT_GROUND`.
Walking then sets freefall. In freefall, pressing Z starts ground pound.
Ordinary crouch/crawl startup also rejects the off-floor input flag. Merely
losing a slippery floor therefore does not, by itself, provide a grounded
crawl opportunity; suitable nearby support or another verified transition
would still matter. The current experiment never reaches that decision
with a lost upper floor, so it does not settle every such possibility.

Relevant sibling sources are `mario_step.c:258–295`,
`mario_actions_moving.c:467,775–825`, `mario.c:1340–1365`,
`mario_actions_stationary.c:528,693,743` and
`mario_actions_airborne.c:525`. Source-file hashes are in the receipt.
This code review does not promote the finite result to a formal exclusion.

## Evidence, verification and reproduction

The [combined receipt](ink-walk-edge-crawl-receipt.json) includes both search
reports, all policy outcome summaries, the two native root records,
supplied-write ledger, selected input/state histories and native meshes,
fresh comparisons, hashes and the audit. **Ten distinct representative
histories reproduce across 286 recorded game-frame boundaries.** Shared
prefixes count once per distinct history. An independent point-to-segment
calculation agrees with all 210 retained continuation edge measurements.
Every advance checks one native global-timer increment. The main and refined
reports' source, dependency and runtime hashes match the files used.

Positions, actions, floor/platform references and input flags are native
observations. Edge distances and interior labels are calculations from
native meshes. This is Wafel 0.8.5 JP execution using the same DLL with
SHA-256 `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`,
not a new original-ROM recording or whole-memory equivalence claim.

From `SSL-Coq/less-than-one-a-press`, use unused output names; the scripts
refuse to overwrite existing reports:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_walk_edge_crawl.py build/wafel-pilot/ink-walk-edge-full.json
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_walk_edge_refine.py build/wafel-pilot/ink-walk-edge-refined.json
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/verify_ink_walk_edge.py build/wafel-pilot/ink-walk-edge-full.json build/wafel-pilot/ink-walk-edge-refined.json docs/notes/ink-walk-edge-crawl-receipt.json
```

No box setup, normal-play approach, useful high crawler or new Coq theorem
is established. The existing supplied-state handoff remains valid, and its
clean gameplay reachability remains open. The atlas and private site retain
all 45 estimates and proof verdicts, including Rank 1 **1–2%** and Ink
Rank 2 **<1%**.
