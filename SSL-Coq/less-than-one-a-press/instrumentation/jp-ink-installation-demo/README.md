# Coordinate-staged Ink Installation on original JP

This wrapper runs the existing `jp-clean-gap-search` mode 12 controller
schedule through all four pillar detectors. It releases the stick after
the fourth detector, so Mario idles while the game animates the top.
It waits until the top reaches timer 131, then stages Mario's actual and
collision positions at `(-2200, 768, -1024)` and displayed position at
`(-2200, 1938.8648681640625, -1024)`. These are nine position writes in a
single controller poll. At the staging boundary Mario's remembered platform
and held object are already null, his action is idle, and depth is zero.

The probe observes the upper warp's accepted `usedObj`, the top-owned floor
and remembered platform, and the top becoming inactive while still
remembered. It breaks at the first Area-2 platform displacement routine
(`0x802c83f0`) and its actual return address to record the position change.
After arrival, it gives 60 updates of ordinary stick input `(-127,-96)`.
The video verifies the result of the supplied gap. Creating the gap with
controller inputs remains open.

Run in Ubuntu-24.04 from the workspace root, with a new output directory.

```sh
bash reference-sm64-wmotr-abc-proof/SSL-Coq/less-than-one-a-press/instrumentation/jp-ink-installation-demo/run.sh \
  reference-sm64-decomp/baserom.jp.z64 build/ink-installation-demo staged
```

The runner authenticates the ROM and uses the repository's existing
Mupen64Plus interpreter setup. It checks all four pillar credits, zero-A
input, accepted warp, retired top, Area-2 displacement and walkway landing.
`trace.txt` contains the extracted checkpoints and `raw.log` preserves the
emulator's screenshot events. `render-frames.txt` maps each PNG's zero-based
sequence number to its emulator frame. The four inclusive frame intervals
are `785–890`, `1002–1110`, `2327–2435`, and `2485–2785`.

For the matched comparison, use a fresh output directory and `flat` in
place of `staged`. The wrapper writes the same three positions with display
Y set to `768`. The warp object is still accepted at timer 2681, but the
floor and remembered platform are null. The flat run stays in Area 1 through
render frame 2785. This distinguishes contact with the warp object from
the completed transition and sideways movement.

Run `bash check.sh OUTPUT_DIRECTORY MODE` from this directory to recheck
either capture's raw log and screenshot inventory without replaying the ROM.

With FFmpeg and DejaVu Sans installed, encode the checked staged frames from
the workspace root:

```sh
demo=reference-sm64-wmotr-abc-proof/SSL-Coq/less-than-one-a-press/instrumentation/jp-ink-installation-demo
capture=build/ink-installation-demo
python3 "$demo/render-video.py" "$capture/shots" "$demo/video-timeline.json" \
  "$capture/ink-installation-demo.mp4"
```

The timeline keeps all four capture windows and slows the warp and descent
by repeating original frames. Captions sit outside the game image. The
24.03-second output contains 721 frames and uses the dummy audio plugin's
silent capture.

## Outside-movement recording

Run the same controller prefix with the `outside` option. It changes
only the supplied movement X to 9000 and adds read-only floor-return
breakpoints. The checker requires a null first floor and a retry owned
by the top, both at game timer 2680. The replay still reaches all four
pillars with controller input before the one-time coordinate edit.

```sh
demo=reference-sm64-wmotr-abc-proof/SSL-Coq/less-than-one-a-press/instrumentation/jp-ink-installation-demo
capture=build/ink-outside-replay
bash "$demo/run.sh" reference-sm64-decomp/baserom.jp.z64 "$capture" outside
python3 "$demo/render-video.py" "$capture/shots" "$demo/outside-video-timeline.json" \
  "$capture/ink-outside-retry.mp4" --title 'Ink Installation  |  Outside the collision grid'
```

This option captures render frames 2485 through 2785. The video uses all
301 consecutive originals, holds one frame for six seconds while the
three edited coordinates are shown, and slows the warp and descent.

## Verify a nearby candidate on the original JP ROM

The `candidate` option uses a specified top timer from 0 through 150
and two signed-16-range integer XYZ tuples. The low tuple sets both
movement and collision. The high tuple sets display. The test checks
all four pillar credits and the zero-A counters. It records the first
floor miss, retry onto the original top, accepted warp, and first real
Area-2 platform apply. Read `DEMO_APPLY_ENTRY` and `DEMO_APPLY_RETURN`
to measure any displacement. The checker requires an observed Area-2
entry but allows a different displacement from the recording.

```sh
demo=reference-sm64-wmotr-abc-proof/SSL-Coq/less-than-one-a-press/instrumentation/jp-ink-installation-demo
bash "$demo/run.sh" reference-sm64-decomp/baserom.jp.z64 build/ink-candidate-replay \
  candidate TIMER LOW_X LOW_Y LOW_Z HIGH_X HIGH_Y HIGH_Z
```

The output directory must be fresh. The runner leaves its raw log and
trace available if any of the candidate checks fails.
