# Visual commentary renderer

The 4:06.6 silent film uses the earlier crawl video's visual language: 1600×900 dark navy, original JP ROM at left, explanatory diagram at right, colored movement/collision/stored-graphics markers, two large commentary lines, and a small evidence footer. It has 36 story segments and 7,398 frames at 30 fps. The source consists of six independent supplied-state tests; it is not a continuous controller route between chapters.

`build_timeline.py` writes `timeline.json` from the six dated native receipts. It does not manufacture or modify game images. `render_video.ps1` checks each receipt hash, every used PNG hash and every image-to-input join before composing frames. It rejects unjoined screenshots. The output receipt includes each source PNG's hash, associated native state, input number and video-frame mapping. Static diagrams summarize JP source and Wafel within-update observations; the new emulator logs directly measure end-update states.

The floor retry, top loading, source branch explanation and retained-pointer result have different evidence scopes. The cards state those differences. The input 27 retention card deliberately holds the mapped input 26 framebuffer while displaying explicitly labeled input 27 telemetry. The unjoined transition screenshot 027 is omitted. The first Area 2 image, 028/input 30, is black during the fade. Later consecutive frames and image 085/input 87 visibly show the upper interior walkway; the arrival diagram describes the separately logged first Area 2 position.

No AI-generated game image, camera write, fake transition, image interpolation, or synthesized voice is used. Native captures are scaled with nearest-neighbor sampling. Paused panels explain the process; moving portions repeat native frames for quarter-speed or half-speed playback. D means **stored graphics position**, not necessarily where the floor-alignment render matrix draws Mario. Coordinate arrows are store changes or comparisons, not paths travelled through space.

## Regenerate

First reproduce or restore the six native captures described in [README.md](README.md), with their `shots` folders and verified receipts under `build/jp-ink-vpu-actions-{crawl,slide,walk,x-slide,x-walk,xy-slide}-20261113`. These screenshots are local generated output; the ROM is never embedded in the movie or publication assets.

From `SSL-Coq/less-than-one-a-press`, use Windows PowerShell 7 with System.Drawing and Segoe UI installed, Python 3, and FFmpeg with libx264:

```powershell
python instrumentation/jp-ink-vpu-actions-demo/build_timeline.py
$videoFfmpeg = 'C:/Users/tariq/AppData/Local/Overwolf/Extensions/ncfplpkmiejjaklknfnkgcpapnhkggmlcppckhcb/315.0.15/obs/bin/64bit/ffmpeg.exe'
& instrumentation/jp-ink-vpu-actions-demo/render_video.ps1 `
  -Manifest instrumentation/jp-ink-vpu-actions-demo/timeline.json `
  -Output ../../../build/ink-vpu-actions-video-repeat `
  -Ffmpeg $videoFfmpeg
```

Replace the FFmpeg path with an available installation when appropriate. The output folder must not already exist. `-PanelsOnly` creates all review panels, the poster, contact sheet, transcript, VTT and receipt without encoding. The original film was rendered with FFmpeg 7.0.2, libx264, CRF 18, `fast` preset, yuv420p and MP4 faststart. Font, graphics-library and encoder versions can change composed-media hashes; input hashes still authenticate which native frames were used.

The completed output is `build/ink-vpu-actions-video` at the workspace root:

- `ink-vpu-actions.mp4`: the silent film.
- `ink-vpu-actions-poster.png`: the crawl split panel.
- `ink-vpu-actions-transcript.md`: timestamped commentary and evidence footers.
- `ink-vpu-actions-commentary.vtt`: subtitle timing for the two large commentary lines.
- `ink-vpu-actions-video-receipt.json`: exact source hashes and frame mapping.
- `contact-sheet.png`: one thumbnail per story segment, in order.
- `panel-*.png` and `frames.txt`: composed native-image panels and FFmpeg concat input.

The renderer measures every text item and fails on width or canvas overflow. It also performs a full decode of the MP4 after encoding. Inspect the contact sheet and representative full-size cards when changing wording or layout. The final timeline was independently audited against all six native receipts; all selected screenshots have known input joins. No proof compilation is needed for this media-only renderer.
