# G means Stored Graphics in the current films

14 November 2026. The current crawl and VPU films now use **M / C / G**:
Movement, Collision, and Stored Graphics. G means `gfx.pos`, not the drawn
model or its render matrix. This is a notation-only rerender: source
gameplay images, controller history, timing, and the existing tense score
remain unchanged. Historical traces and archived renderers may retain D;
their D values are the same quantity now called G in the films.

The active renderers are `../ink-crawl-caption-fix/render.ps1` and
`../jp-ink-vpu-actions-demo/render_video.ps1`. Their storyboards, timeline
generator and current transcript use G too. The original archived
`../ink-film-soundtrack/source-crawl/` remains historical evidence.

Render them into new output directories using their documented commands.
Run the crawl caption verifier first, then this verifier (from the SSL
project directory), with the old scored films restored from proof commit
`c1b643cab2963f8b7af18fd71a6089b24c847f44` into an explicit input folder:

```powershell
python instrumentation/ink-g-label-update/verify.py `
  --original-directory ../../../build/ink-g-label-sources-20261114 `
  --crawl-directory ../../../build/ink-g-label-crawl-20261114 `
  --vpu-directory ../../../build/ink-g-label-vpu-20261114
```

The old inputs are that commit's `docs/media/ink-films/{crawl,vpu}-with-music.mp4`.
Their hashes are checked. The verifier copies their AAC streams without
re-encoding, checks identical packet timing, complete decode, unchanged
duration/frame count, every 66 crawl and 562 VPU gameplay crop, and the
VPU native-image/input joins. The VPU render itself authenticates all six
source receipts and 544 distinct native images. Renderers reject text
overflow. The receipt is published beside the current films.

No new gameplay, Coq proof, reachability or route assessment is claimed.
