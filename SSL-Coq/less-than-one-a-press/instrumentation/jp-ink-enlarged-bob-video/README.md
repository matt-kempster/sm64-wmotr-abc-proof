# Enlarged Bob handoff: native video capture evidence

This packet captures the already verified original-JP shell → enlarged Bob →
Crazy Box handoff and its **omit-final-Crazy-Box** control. The control retains
the live Bob and its interactions. The positive reaches the useful displaced
spawn; the control reaches the ordinary spawn. No new controller-reachable
route or Coq theorem is claimed by the presentation.

The unchanged-camera runs preserve every original setup write and controller
input. `prepare_capture.py` adds screenshot requests and extends observations
through bridge 65; it does not change gameplay or camera fields. Both reruns
pass the original checker: 25 selected physical boundaries match Wafel per
case, with the 25 known native/Wafel clock differences retained and missing
camera boundaries 25/26 disclosed. All 172 previously observed native state
records per case, every original state write, all floor-query records
(682 positive, 665 control) and all ground-step hooks match exactly against
the prior native replays, without clock normalization.

## Frame mapping

`positive-frame-map.json` and `no-final-box-frame-map.json` contain the state
and hash of every captured PNG. Rice saves the **previous completed
framebuffer**, so `framebufferTimer = requestTimer - 1`. This is a different
mapping from the `native + 2 = Wafel` global-clock difference. PNG number is
not assumed to equal update number across a transition.

Each default run has 64 images, 62 with a joined native camera observation.
The transition image 024 and final automatic test image 063 are unjoined and
must not be labeled as evidence of a specific state. Image000 is before the
high cut; the supplied initial high FREEFALL is a setup diagram, not a
separately rendered native starting frame.

| Native completed bridge | Top update / event | PNG index |
| --- | --- | --- |
| 1 | shell/Z update 128 | 001 |
| 2 | Bob shove update 129 | 002 |
| 3 | producer update 130 | 003 |
| 4 | acceptance update 131 | 004 |
| 23 | last joined pretransition picture | 023 |
| 27 | first Area 2 state | 025 |
| 30 / 35 / 40 / 50 / 60 | later Area 2 continuation | 028 / 033 / 038 / 048 / 058 |

Bridge 24 has native state telemetry but no joined PNG; camera boundaries 25
and 26 are absent. Do not invent pictures across this gap. Initial Area 2
images are dark during the fade. Later pictures may accompany the first
spawn coordinates only if explicitly labeled as later continuation.

M = Movement, C = Collision, G = Stored Graphics (`gfx.pos`). The rendered
model's pose/matrix is distinct from G. Native screenshots alone do not
visualize the M/C/G separation; labeled diagrams and logged coordinates
explain it. The original camera is distant and sometimes obstructed.

## Optional render-only closeup

`prepare_closeup.py` creates a separately named `positive-closeup` capture.
At the authenticated JP `update_graph_node_camera` epilogue `0x80287738`,
it overrides only the resulting GraphNodeCamera position, focus and roll.
Native `Camera` and `LakituState`, Mario, actors, collision data and inputs
are untouched. Every render-field write is logged as `VIDEO_CAMERA_WRITE`.
This view must be labeled **render-camera closeup**, not ordinary player
camera footage. Its separate completed run passes the original checker,
including exact useful spawn and the 25 selected physical boundaries. All
192 native state observations through bridge 65 match the unchanged-camera
capture, along with all original gameplay writes and ground-step records.
The 441 render-field writes are preserved in `positive-closeup-frame-map.json`.

The view changes render/shadow work: total recorded floor queries are 548
instead of 682. Callers `0x802ce8a0` and `0x803814e4` have 67 fewer calls
each; the former is the `create_shadow_below_xyz` direct floor query, checked
against the original-ROM instruction sequence and source. All 365 query
records outside those two caller classes match exactly, including the initial
geometry, pushes, ground quarters, platform queries and failed-floor retry.
Both complete excluded query lists remain in the map; this is not a claim
of identical whole memory or identical rendering. The unchanged-camera
capture remains the primary replay. Closeup images are a labeled explanatory
view of the same selected gameplay states and outcome.

## Reproduce captures

Start commit: `4aca530130f3c1f6b705c3060d383d8459b6d43b`.
Ubuntu-24.04 runs Mupen64Plus 2.5.9 interpreter/debugger and Rice 2.5.9 with
software OpenGL. Original JP ROM SHA-256:
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`.

From the SSL project, use fresh output folders:

```sh
python3 instrumentation/jp-ink-enlarged-bob-video/prepare_capture.py
bash instrumentation/jp-ink-enlarged-bob-video/run.sh \
  ../../../reference-sm64-decomp/baserom.jp.z64 build/bob-film-positive positive
bash instrumentation/jp-ink-enlarged-bob-video/run.sh \
  ../../../reference-sm64-decomp/baserom.jp.z64 build/bob-film-control no-final-box
python3 instrumentation/jp-ink-enlarged-bob-video/map_capture.py build/bob-film-positive positive
python3 instrumentation/jp-ink-enlarged-bob-video/map_capture.py build/bob-film-control no-final-box
```

For the separately labeled view, run `prepare_closeup.py`, then `run.sh` and
`map_capture.py` with case `positive-closeup` and a fresh output directory.
No ROM or emulator binary is distributed. `records/` preserves compressed
raw traces, exact compiled sources, case, checker and receipts with hashes;
`frames/` preserves unchanged native PNGs. On-screen commentary, score, explanatory
graphics and movie rendering are presentation layers built from this evidence.
Verify the preserved captures without an emulator using
`python3 instrumentation/jp-ink-enlarged-bob-video/verify_capture.py --check`.
