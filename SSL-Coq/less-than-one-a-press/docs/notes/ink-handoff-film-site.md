# Ink handoff films: private viewing site and music

13 November 2026. The private [Ink handoff films site](https://ink-handoff-films.tra38.chatgpt.site)
collects two existing visual explanations with newly composed instrumental
tension music. Silent versions remain available. This is a presentation and
publication update; it adds no gameplay run, height search or Coq proof.

| Film | Existing evidence | Scope |
| --- | --- | --- |
| Original Crazy Box crawl explainer, 2:04.733 | Supplied crawl at Y1741 produces M/C Y768 and stored graphics Y1741, a 973-unit gap; the original JP replay accepts the warp, captures the top and reaches the useful interior arrival | High crawler and live box placement are supplied |
| VPU crawling, sliding and walking, 4:06.6 | Three separate supplied Y67277 cases produce a 66509-unit gap and a useful handoff; two X-only controls and one combined X/Y control fail | Walking uses two supplied cuts; the six original-ROM cases do not establish high entry, actor delivery or a continuous allowed route |

The preserved viewing files are:

- Original crawl: [with music](../media/ink-films/crawl-with-music.mp4) and
  [silent original](../media/ink-films/original-crawl-silent.mp4).
- VPU actions: [with music](../media/ink-films/vpu-with-music.mp4) and
  [silent original](../media/ink-vpu-actions/ink-vpu-actions.mp4).
- [Soundtrack receipt](../media/ink-films/soundtrack-receipt.json), recording
  source/output hashes, music seeds, tool versions and measured checks.

The original film is the earlier workspace render
`build/crazy-box-explainer/crazy-box-handoff.mp4`, with its `storyboard.md`,
`render.ps1` and `verify.py`, now preserved under
`instrumentation/ink-film-soundtrack/source-crawl/`. Its gameplay comes from the third chapter of
the original JP recording documented in
[the hands-free video commentary](ink-handsfree-video-commentary.md),
`instrumentation/jp-ink-handsfree-demo/`, and the archived supplied-handoff
trace. The storyboard credits proof revision
`3d9db857bd078f554e269f608dbd896667e71f17`, thirteen setup writes, A-off
inputs and the disclosed pre-entry debug level selection. Its within-update
diagram expands source ordering while the original gameplay image is frozen;
those diagram stages do not add controller opportunities.

The later film, including six original-ROM receipts, is documented in
[the VPU video evidence note](ink-vpu-three-actions-video-evidence.md) and
`instrumentation/jp-ink-vpu-actions-demo/`. Its captions explicitly separate
recorded update endpoints from source/Wafel explanations of operations inside
an update. The floor-query height is local even when the queried high Y aliases;
the horizontal failure controls do not exclude every conceivable PU route.

The older film's legend describes D as where Mario is drawn. Read D as
**stored graphics position**: floor alignment can install a matrix that draws
the model elsewhere. This clarification belongs beside the preserved film;
the soundtrack edition does not revise or replace its video frames.

The music, **Stored in the Dark**, is an original synthetic instrumental
composition created for these films, with separate arrangements and ending
fades. It uses a restrained 84 BPM pulse, soft pads, bass, plucked notes and
light percussion. It is not original SM64 game audio, a replay input, an action cue from
the game, or a licensed third-party song. The deterministic score and mux
scripts live in `instrumentation/ink-film-soundtrack/`; build outputs are in
the workspace's `build/ink-film-soundtrack/`. No ROM or conversation export is
part of the film site.

FFmpeg 6.1.1 copies each original H264 video stream and adds 48 kHz stereo
AAC. The receipt verifies identical elementary video-stream hashes before
and after muxing, unchanged video duration and frame counts, successful
complete decoding, and matching audio duration. Both remain 1600×900 at
30 frames per second. The measured outputs are:

| Music edition | Video duration | Frames | Integrated loudness | True peak |
| --- | ---: | ---: | ---: | ---: |
| Crawl | 124.733333 seconds | 3742 | −19.01 LUFS | −3.03 dBTP |
| VPU actions | 246.6 seconds | 7398 | −19.01 LUFS | −3.68 dBTP |

The composition is deterministic with NumPy 1.26.4 and seeds 20261113
and 20261114. The final file hashes were independently rechecked against
the soundtrack receipt. These are format, signal and provenance checks;
no human listening assessment is claimed. The silent originals, including
the newly archived original crawl film, remain available for comparison.

The site source is the separate workspace repository `ink-handoff-films-site`.
It remains private, as does the existing Pyramid Fine Print site. Publishing
these films does not change the proof assessment: high entry, actor delivery
and their joined timing remain open. All 45 subjective estimates are unchanged,
including Rank 1 **1–2%** and Ink Rank 2 **<1%**; they are not measured
probabilities.
