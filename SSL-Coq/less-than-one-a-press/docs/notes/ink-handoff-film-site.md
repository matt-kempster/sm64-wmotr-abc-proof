# Ink handoff films: private viewing site and music

13 November 2026. The private [Ink handoff films site](https://ink-handoff-films.tra38.chatgpt.site)
collects two visual explanations with newly composed instrumental tension
music. The current first film corrects its graphics-position captions; both
the corrected silent edition and historical silent original remain available.
This is a presentation and publication update; it adds no gameplay run,
height search or Coq proof.

| Film | Existing evidence | Scope |
| --- | --- | --- |
| Original Crazy Box crawl explainer, 2:04.733 | Supplied crawl at Y1741 produces M/C Y768 and stored graphics Y1741, a 973-unit gap; the original JP replay accepts the warp, captures the top and reaches the useful interior arrival | High crawler and live box placement are supplied |
| VPU crawling, sliding and walking, 4:06.6 | Three separate supplied Y67277 cases produce a 66509-unit gap and a useful handoff; two X-only controls and one combined X/Y control fail | Walking uses two supplied cuts; the six original-ROM cases do not establish high entry, actor delivery or a continuous allowed route |

The preserved viewing files are:

- Original crawl: [corrected with music](../media/ink-films/crawl-with-music.mp4),
  [corrected silent](../media/ink-films/crawl-caption-corrected.mp4), and
  [historical silent original](../media/ink-films/original-crawl-silent.mp4).
  The [initial scored edition](../media/ink-films/crawl-before-caption-fix.mp4)
  is archived as the exact AAC source for reproducing the correction.
- VPU actions: [with music](../media/ink-films/vpu-with-music.mp4) and
  [silent original](../media/ink-vpu-actions/ink-vpu-actions.mp4).
- [Initial soundtrack receipt](../media/ink-films/soundtrack-receipt.json),
  recording the first scored editions' source/output hashes, music seeds,
  tool versions and measured checks. Its crawl video hashes are historical.
- [Caption-correction receipt](../media/ink-films/caption-correction-receipt.json),
  recording the current crawl edition, its retained gameplay selection and
  timing, and its copied AAC soundtrack.

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

The historical film's legend describes D as where Mario is drawn. The current
crawl film corrects that wording in the film itself: D and its Y1741 label mean
**stored graphics position**, not the drawn model's height. Floor alignment
can install a matrix that draws the model elsewhere. The corrected render
uses the same underlying gameplay images, card durations and 3742 frames
over 124.733333 seconds; the visual stream has been rendered again and is
not the historical H264 stream. Its source is
`instrumentation/ink-crawl-caption-fix/`. The existing AAC music stream is
copied exactly into this corrected edition. The second film and its music
are unchanged, and the historical silent crawl remains preserved separately.

The music, **Stored in the Dark**, is an original synthetic instrumental
composition created for these films, with separate arrangements and ending
fades. It uses a restrained 84 BPM pulse, soft pads, bass, plucked notes and
light percussion. It is not original SM64 game audio, a replay input, an action cue from
the game, or a licensed third-party song. The deterministic score and mux
scripts live in `instrumentation/ink-film-soundtrack/`; build outputs are in
the workspace's `build/ink-film-soundtrack/`. No ROM or conversation export is
part of the film site.

The initial soundtrack production used FFmpeg 6.1.1 to copy each original
H264 video stream and add 48 kHz stereo AAC. Its receipt verifies identical
elementary video-stream hashes before and after that initial muxing,
unchanged video duration and frame counts, successful complete decoding,
and matching audio duration. Those video hashes still describe the current
VPU music edition; the caption-correction receipt supersedes them for the
current crawl video. Both films remain 1600×900 at 30 frames per second.
The initially measured soundtrack editions were:

| Music edition | Video duration | Frames | Integrated loudness | True peak |
| --- | ---: | ---: | ---: | ---: |
| Crawl | 124.733333 seconds | 3742 | −19.01 LUFS | −3.03 dBTP |
| VPU actions | 246.6 seconds | 7398 | −19.01 LUFS | −3.68 dBTP |

The composition is deterministic with NumPy 1.26.4 and seeds 20261113
and 20261114. The initial scored-file hashes were independently rechecked
against the soundtrack receipt; they are historical for the crawl edition
now that its captions have changed. The current crawl preserves the same
AAC stream, so its music has not been recomposed or re-encoded. These are
format, signal and provenance checks; no human listening assessment is
claimed. The silent originals remain available for comparison.

The site source is the separate workspace repository `ink-handoff-films-site`.
It remains private, as does the existing Pyramid Fine Print site. Publishing
these films does not change the proof assessment: high entry, actor delivery
and their joined timing remain open. All 45 subjective estimates are unchanged,
including Rank 1 **1–2%** and Ink Rank 2 **<1%**; they are not measured
probabilities.
