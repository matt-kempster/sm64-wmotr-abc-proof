# Below the cap: a 632-unit gap

The [62.8-second video](../media/ink-below-cap-demo.mp4) shows a conditional
gap producer in the original Japanese ROM. The game creates a 632-unit
disagreement from equal supplied Mario positions, but the following retry
selects the ordinary roof, not the spinning top. Mario arrives normally in
the Area-2 elevator. This is not a clean no-A route or a useful installation.

The [poster](../media/ink-below-cap-demo-poster.png) is explicitly a
render-only illustration of the supplied starting coordinates. It shows
Mario and the box between the roof and the cap. Neither the poster nor the
illustration is evidence that gameplay reaches that floating starting pose.

## What the recording supplies

Both fresh emulator runs replay the existing mode-12 no-A four-pillar
controller prefix. They then release the stick until stored top timer 125.
The chapter uses the following setup:

1. Before chapter input 5, at stored top timer 129, write `ACT_CRAWLING` once
   and send Z with stick `(0,64)`. A real update establishes Mario's 100-unit
   hitbox; the harness does not write the hitbox.
2. Before chapter input 6, at stored timer 130, supply equal movement,
   collision and stored display positions `(-2132,1400,-1024)`, and the free
   native Crazy Box 49 position `(-2093,1400,-1024)`. Send Z and `(0,64)` once.
3. Send neutral inputs thereafter, through the warp and elevator landing.

There are 13 supplied 32-bit words: one action word and twelve coordinate
words. No floor cache, hitbox, velocity, depth, held pointer, top state,
pillar counter or RNG is supplied. All three A counters are zero. The
retail-ROM level-select debug cheat 6 is the accepted startup, not gameplay
reaching SSL from a normal save.

This native recording uses the same coordinates and mechanism as the
[below-cap producer study](ink-low-fixture-producers.md), with fewer direct
setup writes. It is **not** a byte-identical recreation of that Wafel seed:
the preparatory update leaves forward speed 1.10000002, yaw 2256, velocity
`(0.236069709,0,1.07437015)`, and box vertical speed 4.4540863. The Wafel
test instead supplies zero velocities and yaw 208. Both produce the exact
632-unit gap and static-roof retry. The video receipt records the native
values rather than silently identifying the two starting states.

The supplied Mario Y = 1400 is 120 above the local static roof at 1280. There is no
standing floor at that height. The assumed 100-high crawling body ends at 1500,
below the loaded cap underside at 1518 before the update and 1523 after terrain
preparation. These collision heights come from the existing source/geometry
analysis, not from measuring pixels. The new recording does not construct a
controller-produced hover, established high crawl or delivered actor.

## What the native trace observes

| Completed chapter input | Movement/collision | Stored display | Floor/platform |
| --- | --- | --- | --- |
| Before 6, supplied cut | `(-2132,1400,-1024)` | equal | inherited floor 1024; null platform |
| 6, after box push and crawl | `(-2200,768,-1024)` | `(-2200,1400,-1024)` | floor 768; null platform |
| 7, accepted warp | `(-2200,1280,-1024)` | equal | static floor 1280; null platform |
| 30, first Area 2 | `(0,5500,256)` | equal | ordinary elevator floor below Mario |
| 48, elevator landing | `(0,4966,256)` | equal | elevator platform |

The 62.8-second edit contains pauses and slow motion made by repeating actual
captured frames. The [timestamped transcript](../media/ink-below-cap-demo-transcript.md)
and [video receipt](../media/ink-below-cap-demo-receipt.json) identify every
source frame and its output interval. The untouched gameplay run is kept
separate from the diagnostic illustration replay.

The end-of-update trace directly establishes the split, action, floor
height/owner, platform and arrival. The detailed query explanation uses the
source and the existing finite snapshot/tail proofs: the low query misses,
the raised retry admits static roof 1280, and the stopped quarter preserves
the previously selected low cache. This video probe does not hook every
individual query return or prove their entire call sequence.

## Why the two views look different

**Stored display coordinates are not always the final model transform.**
At the split, the native trace records stored display
`(-2200,1400,-1024)`, but Mario's floor-alignment `throwMatrix` translates
`(-2200,768,-1024)`. The normal image therefore must not be presented as a
pixel-level depiction of Mario at Y = 1400. The source connection is
`src/game/mario_actions_moving.c:88–92` (`align_with_floor`),
`src/engine/math_util.c:417–475` (the alignment transform), and
`src/game/rendering_graph_node.c:813–826` (matrix selection).

The illustration replay changes only render-time state at camera callback:

- Six Lakitu render camera/focus words provide a side view, without hiding
  the cap or changing collision geometry.
- At input 5's render, Mario and the box graphics positions illustrate the
  next supplied starting coordinates, and both graphics matrices are cleared.
  The physical Mario is still at the previous pillar in this illustration.
- At input 6's render, Mario's graphics matrix alone is cleared so his
  existing stored display position is visible. His physical movement and
  collision coordinates are already low at Y = 768.

The harness restores positions and camera before the next input. Matrix
restoration preserves the **native post-render null value**, matching
`rendering_graph_node.c:854`; restoring the nonnull pre-render matrix would
incorrectly preserve it into the next action. All 146 logged render states,
extra states, matrices, setup writes, initial state and final controller
counters match between the final stock and illustration runs. This is a
comparison of the logged projection, not every byte of emulator memory.
The final files use the `-v2` captures; earlier exploratory captures are not
used in the video or durable receipts.

## Timing and frame mapping

| Video time | Content |
| --- | --- |
|0:00–0:09|Result boundary and native crawl preparation.|
|0:09–0:18|Labeled supplied-coordinate illustration: roof 1280, Mario 1400, body top 1500, cap 1518/1523.|
|0:18–0:21|Two-frame render-only illustration of the westward push.|
|0:21–0:29|Stored display 1400 versus movement/collision 768.|
|0:29–0:36|Untouched gameplay view and explicit render-matrix caveat.|
|0:36–0:44|Static-roof retry and absent spinning-top reference.|
|0:44–0:53.8|Ordinary warp continuation and elevator outcome.|
|0:53.8–1:02.8|The high crawl/hover/actor predecessor remains open.|

Rice screenshots requested in a camera callback save the preceding completed
framebuffer. The checker joins each request timer minus one to a logged
camera state. PNG 5 corresponds to completed input 5, PNG 6 to input 6, PNG 7 to
input 7, and PNG 28 to first-Area-2 input 30. The warp skips two camera callbacks;
PNG 27 is explicitly an unjoined transition frame. Index arithmetic must not
be extended through the warp as though every input had a camera callback.

## Reproduction and checks

From the SSL project directory in Ubuntu-24.04, with fresh output names:

```sh
bash instrumentation/jp-ink-below-cap-demo/run.sh ../../../reference-sm64-decomp/baserom.jp.z64 build/jp-ink-below-cap-stock-20261111-v2 stock
bash instrumentation/jp-ink-below-cap-demo/run.sh ../../../reference-sm64-decomp/baserom.jp.z64 build/jp-ink-below-cap-display-20261111-v2 display
python3 instrumentation/jp-ink-below-cap-demo/render-commentary.py instrumentation/jp-ink-below-cap-demo/video-timeline.json docs/media/ink-below-cap-demo.mp4 --receipt docs/media/ink-below-cap-demo-receipt.json --transcript docs/media/ink-below-cap-demo-transcript.md
ffmpeg -nostdin -hide_banner -loglevel error -ss 12 -i docs/media/ink-below-cap-demo.mp4 -frames:v 1 docs/media/ink-below-cap-demo-poster.png
python3 instrumentation/jp-ink-below-cap-demo/finalize.py --write --stock build/jp-ink-below-cap-stock-20261111-v2 --display build/jp-ink-below-cap-display-20261111-v2
python3 instrumentation/jp-ink-below-cap-demo/finalize.py
```

The capture and rendering commands refuse existing destinations. To reproduce
elsewhere, choose fresh output names and update a copied timeline's source
paths. The final command is a **read-only check of stored evidence**, not a
new gameplay replay. New gameplay was run by the two capture commands above.

Both final captures and their exact-outcome checks passed with exit 0. The
renderer produced 1,884 H264 frames at 30 fps, 960×1008, 62.8 seconds, silent;
file size 3,495,272 bytes. Representative starting-coordinate, stored-display,
native-matrix and elevator frames were visually inspected. No generated game
imagery, fabricated intermediate frames or hidden collision edits are used.

The original JP ROM SHA256 is
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`
(MD5 `85d61f5525af708c9f1e84dce6dc10e9`). The video SHA256 is
`2893a6808b57b0e6a62fedd995f7eca5236dc6d373314cdbb229a6e134575efc`.
Mupen64Plus core/UI 2.5.9 uses the interpreter, Rice 2.5.9 graphics, HLE
RSP 2.5.9 and dummy audio under Ubuntu-24.04. The
[durable provenance](../media/ink-below-cap-native/provenance.json) pins the
native source snapshots, complete raw logs/traces, receipts, selected PNGs,
renderer, timeline, video and poster. Source and text files use LF endings.

This tranche adds a checked original-ROM recording and the rendering caveat.
It adds no new Coq theorem and does not change the clean gameplay verdict.
