# Three-actor Ink film

Visual commentary in the same style as the earlier Ink films: actual
original-JP replay images at left, explanatory diagrams at right, measured
M / C / G values, two caption lines and an evidence footer. There is no
spoken commentary. The original procedural instrumental *Stored in the Dark*
is reused with a new ending fade, about -19 LUFS and true-peak headroom.

The 14 chapters last 175 seconds at 1600x900, 30 fps. The film explains the
already established conditional shell → bloated Bob → Crazy Box handoff;
it does not establish delivery or a complete controller route. The negative
comparison omits only the final Box placement and reaches ordinary spawning.

`storyboard.json` is the caption/timing source. `facts.json` and
`extract_facts.py --verify` independently check the relevant original-JP
record values. `render.ps1` checks source image hashes and text bounds,
refuses unjoined frame mappings, and records every image/chapter join.
`finish.py` adds music, preserves the H264 elementary stream, and checks full
decode, frame count, duration, dimensions, codecs, loudness and true peak.
`verify.py` validates the durable final artifacts and their source hashes.

The preserved native images and maps are in the sibling
`jp-ink-enlarged-bob-video/` package. Positive panels use its separately
labeled render-camera closeup. These change the camera node used to draw the
scene, not Mario's coordinates or inputs. The unchanged-camera positive and
negative are also preserved. The closeup's shadow-query changes are recorded
there; no claim of identical whole execution is made. Camera sample24 has
no matched image; samples25/26 are unavailable across transition. The film
uses no unjoined images. Some early Area2 images are black; later continuation
images are shown while first-arrival coordinates remain explicitly log-derived.

From the SSL project directory in PowerShell, choose a fresh output:

```powershell
& instrumentation/ink-enlarged-bob-film/render.ps1 -Output build/bob-film-new
```

Then in Ubuntu-24.04, from the same directory:

```sh
python3 instrumentation/ink-enlarged-bob-film/finish.py \
  --workspace '/mnt/c/Users/tariq/OneDrive/Documents/sm64 - the item-grab proof' \
  --render build/bob-film-new
```

The renderer uses the same local Windows FFmpeg as prior films. The music
step uses ffmpeg/ffprobe and verifies the original VPU score master under
the workspace's `build/ink-film-soundtrack/`. Recreate that master using
`../ink-film-soundtrack/compose.py` and its pinned dependency instructions
if needed. No download, voice service or global environment modification is
needed. Video review consists of selected rendered panels and objective
decode/format/audio measurements; no human listening review is claimed.
