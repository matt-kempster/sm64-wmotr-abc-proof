# Stored graphics caption correction

This is a new renderer derived from the archived `../ink-film-soundtrack/source-crawl/render.ps1`. It preserves that original, the screenshot sequence, four-part explanation of input 6, card durations, 1600×900 layout and existing music. D means **stored graphics coordinates**, not necessarily where Mario's model is drawn. The burned-in captions, repeated legend and diagram labels now state that distinction.

Run from PowerShell in the workspace root:

```powershell
& './reference-sm64-wmotr-abc-proof/SSL-Coq/less-than-one-a-press/instrumentation/ink-crawl-caption-fix/render.ps1'
python './reference-sm64-wmotr-abc-proof/SSL-Coq/less-than-one-a-press/instrumentation/ink-crawl-caption-fix/verify.py' --original-scored './reference-sm64-wmotr-abc-proof/SSL-Coq/less-than-one-a-press/docs/media/ink-films/crawl-before-caption-fix.mp4'
```

The default output folder is workspace `build/ink-crawl-caption-fix`. `render.ps1 -OutputDir <path>` selects another folder; `-PanelsOnly` skips encoding for caption inspection. `verify.py --output <path>` selects that folder. The old scored film is required explicitly and checked against its historical SHA-256 before its AAC is copied. `--original-panels` can point to the original `build/crazy-box-explainer` panel set; `--check-only` verifies the existing mux. FFmpeg/FFprobe are found in the installed Overwolf extension, or selected using `verify.py --ffmpeg <path>`.

Verification checks the frame count, duration, full decode, exact existing AAC track and packet timing, unchanged source PNG hashes and sequence, identical 66 gameplay panel pixel crops, identical concat timing manifest, and measured text bounds. The corrected silent film and scored film share the new H.264 stream. They do **not** share the old film's H.264 stream, because the captions are burned in. The receipt records both old and new hashes.

The handoff's gameplay evidence and open entry/transport obligations are unchanged. This presentation correction runs no new gameplay or Coq proof.
