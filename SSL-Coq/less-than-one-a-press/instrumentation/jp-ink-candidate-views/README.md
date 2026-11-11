# Original-ROM candidate views (visualization only)

This camera helper renders the exact coordinates discussed in the 973-unit
candidate. It authenticates the original JP ROM and reuses the established
mode-12 four-pillar controller prefix, then releases the stick. It changes
**render positions and camera state**, not Mario's movement/collision state,
action, cached floor, or a controller-produced trajectory. These images must
not be used as experimental evidence for the stopped-crawl handoff.

The six requested images, in order (`super_mario_64-000.png` through
`super_mario_64-005.png` in the final `*-held` captures), are:

| Index | Mario render position | Top behavior phase |
| --- | --- | --- |
| 0 | (-1950,1741,-939), high above the low pad | 130 |
| 1 | (-1950,1741,-939), high above the low pad | 131 |
| 2 | (-1882,1741,-939), after the proposed horizontal push | 130 |
| 3 | (-1882,1741,-939), after the proposed horizontal push | 131 |
| 4 | (-1882,768,-939), low warp-contact position | 130 |
| 5 | (-1882,768,-939), low warp-contact position | 131 |

The helper captures the top's native render transform immediately after
behavior phases130 and131 (the object timer has already incremented to131
and132). It reuses these two snapshots for the later positions. Normal mode
preserves the top's rendered geometry and opacity. A high Mario can be occluded because
the supplied position lies inside the top's rendered solid. The warp object
itself is invisible; the hole and surrounding masonry provide the reference.

At `update_graph_node_camera` entry the helper supplies the Mario graphics
coordinates, top render snapshot, and camera. It clears the two graphics
`throwMatrix` pointers for that render so the stated position/angle fields
determine the transforms. It restores every edited graphics word and the six
Lakitu render-position/focus words before the next controller poll. It does
not clear collision geometry or move the physical top. The camera is at
(-500,2450,-1000), looking at(-2048,1350,-1024).

The addresses come from the existing authenticated retail-JP symbol record:
`build/rank1-backward-search/retail-jp-symbols.txt`: camera callback802876d0,
Lakitu8033b328. The field offsets are from `include/types.h` and
`src/game/camera.h` in the decompilation. The helper logs the unmodified
movement position alongside the substituted graphics position, and requests
one native emulator screenshot for each index.

Run in Ubuntu-24.04 from the workspace root with a new output directory:

```sh
bash reference-sm64-wmotr-abc-proof/SSL-Coq/less-than-one-a-press/instrumentation/jp-ink-candidate-views/run.sh \
  reference-sm64-decomp/baserom.jp.z64 build/ink-candidate-views-20261111-held
```

An optional third argument `cutaway` hides **only the top render node**,
while leaving physical collision geometry unchanged. In that diagnostic mode
the high camera is(-1450,2150,-800), looking at(-1950,1650,-939); the low camera
is inside the pyramid at(-1700,1000,-1100), looking at(-1940,850,-939). Cutaways
must be labeled as edited visibility, not normal gameplay views.

The first exploratory `*-a` captures exposed a one-frame Rice screenshot
latency: a request in a render callback saves the preceding completed frame.
The final helper therefore holds each of the six scenes for three render
callbacks and requests a screenshot only on the third. Both the current and
preceding completed frames then have the same stated pose, phase, and camera.
Do not use the exploratory filenames as the final index mapping.

`raw.log` contains the native screenshot events and visualization records.
`trace.txt` extracts all18 held-render records plus the six requests. The final frame2700
screenshot is only the runner's stop marker and is not a candidate view.
