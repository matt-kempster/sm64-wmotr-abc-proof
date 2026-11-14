# Live large-box landing → slide → useful Ink: visual commentary

This 2:56.033 film explains the **already recorded** original-JP conditional
positive in `../jp-ink-high-solid-support/`. It adds no gameplay experiment or
Coq theorem. Initial high FREEFALL, a live high large box, shell availability
and the later shell-position cut are supplied. B creates DIVE, the air step
reports LANDED and selects DIVE_SLIDE, and the next nonmounting shell shove
produces the useful Ink split and displaced Area 2 arrival. All A inputs are
off. The 27 writes and remaining gameplay-delivery question stay explicit.

The film uses **M = Movement, C = Collision, G = Stored Graphics**. G means
`gfx.pos`, not the rendered model pose or matrix. Historical source records
retain their original `display`/D field names; this is a presentation mapping.
On-screen commentary, original-JP stills and slowed sequences accompany
explanatory diagrams. The original instrumental score is *Stored in the Dark*;
there is no spoken narration or downloaded music.

## Files and image provenance

- `storyboard.json`: 18 chapter scripts and exact durations/selections.
- `render.ps1`: 1600×900, 30-fps renderer with measured text bounds.
- `frame-map.json`: the 54 original capture records and image SHA-256 values.
- `frames/`: 42 selected original native images, unchanged.
- `prepare.py`: rebuilds the map/storyboard from the original local capture.
- `add_music.py`: trims/fades the existing original VPU score master, measures
  loudness, adds AAC while preserving the silent H264 stream, and decodes all.
- `video-receipt.json`: selected-source/renderer/script hashes, exact chapter
  timing, 54 panel joins, format and audio measurements, review limits.

The capture is `build/jp-high-solid-support-20261114-a`, using the existing
unmodified Japanese ROM (SHA-256
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`).
Rice's screenshot request saves the previous completed framebuffer. The map
joins `requestTimer - 1` to the camera telemetry; it never assumes that PNG
index equals update number across transitions. Three captures are unjoined
and excluded from the film. Camera states 28/29 are absent; the paused image
used while discussing step27 is expressly identified as step26. Native
step30's first Area2 image is dark, so its logged coordinates appear beside
it; later pictures are explicitly later continuation images.

The selected ROM comparison keeps all45 interaction-subtype differences
(1035/1080 compared components match), and does not claim whole-state equality.
The frozen-box failure is a separate Wafel control. Its card explicitly labels
the left image as a paused successful JP replay, not footage of that failure.
Triangle loading/source explanations are not mislabeled as camera-hook traces.

## Reproduce the presentation

From `SSL-Coq/less-than-one-a-press`, in PowerShell, choose a fresh output:

```powershell
& instrumentation/jp-ink-high-solid-video/render.ps1 -Output build/live-box-film-new
```

The preserved frames and map suffice to render; rerunning `prepare.py` is only
needed to regenerate the selection from the local original capture. The
renderer locates the existing Windows FFmpeg under Overwolf, following the
earlier film tooling. It aborts on missing images, hash changes or text overflow.

In Ubuntu-24.04 WSL, in the same project directory:

```sh
python3 instrumentation/jp-ink-high-solid-video/add_music.py \
  --workspace '/mnt/c/Users/tariq/OneDrive/Documents/sm64 - the item-grab proof' \
  --render build/live-box-film-new
```

The audio script requires the existing
`build/ink-film-soundtrack/vpu-score.wav` and its original composition receipt
at the workspace root. It verifies that master hash before editing. Recreate
that master with `../ink-film-soundtrack/compose.py` and its documented pinned
NumPy dependency if needed. The ending receives a seven-second fade; the
result is normalized to roughly −19 LUFS with true-peak headroom. No global
proof or emulator environment is changed.

Final public-facing artifacts are under `docs/media/ink-high-solid-video/`:
video, poster, timed Markdown commentary, WebVTT commentary and receipt.
Panel contact sheet and individual annotated panels remain ignored local
build products. Raw selected native images are preserved above for exact
reproduction. The source ROM and emulator binaries are never distributed.
