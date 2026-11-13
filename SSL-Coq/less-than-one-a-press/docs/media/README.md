# Proof project videos

The private [Ink handoff films site](https://ink-handoff-films.tra38.chatgpt.site)
collects the original Crazy Box crawl explainer and the VPU actions film with
new instrumental scores, plus their silent versions. The scored videos preserve
the original pictures and captions; the music is newly composed presentation
audio, not game audio. See the [film-site record](../notes/ink-handoff-film-site.md)
for files, provenance and validation. These remain supplied-state demonstrations,
with no new route or proof claim.

[VPU crawling, sliding and walking](ink-vpu-actions/ink-vpu-actions.mp4)
is a 4:06.6 captioned explanation with six fresh original-Japanese-ROM
recordings: three vertical supplied-state handoffs and three horizontal
failure comparisons. Original gameplay appears beside position diagrams.
The walking chapter separates its two supplied cuts, and no complete
controller-reachable route is claimed. The [evidence note](../notes/ink-vpu-three-actions-video-evidence.md)
and [rendering instructions](../../instrumentation/jp-ink-vpu-actions-demo/VIDEO-README.md)
preserve setup, trace, frame-mapping and regeneration details.

`ink-arrival-conditional.mp4` is the half-speed highlight from the
[conditional Ink arrival test](../notes/ink-area2-arrival-video.md).
It contains actual emulator-rendered frames with explanatory caption margins.
The supplied test setup is not a clean controller-play witness.

Reproduce it with `instrumentation/jp-lifecycle/run.sh` in recording mode,
then `instrumentation/jp-lifecycle/render-video.sh`. The full recordings,
screenshots and raw logs remain in the ignored build directory. ROMs are not
included.

`western-goomba-path-replay.mp4` reconstructs the exact 901-update
[western-Goomba diagnostic](../../instrumentation/western-goomba-rng/README.md)
from its matching US/JP position traces and generated collision mesh. It is
not emulator footage. The three-second pause at update 847 shows the outside
waypoint; the trace does not reach the rim. Other stock actors appear only as
context markers. The linked diagnostic documents reproduction and checks.

`western-goomba-home-range.png` and `western-goomba-home-range.mp4` overlay
the original replay with the source's 1,000-unit home threshold and the
direct bearing to the rim. The circle is a height slice of a three-dimensional
steering test, not a hard movement limit.

`western-goomba-direct-rim.mp4` reconstructs a new source diagnostic aimed
at the original rim target. It reaches the entry wall and turns away, without
reaching the rim. Its positions are recorded native outputs, not emulator
footage or a proved shortest gameplay route.

`goomba-elevator-map.png` shows all nine potential stock actors and the six
new isolated RNG-choice replays. `goomba-elevator-height.png` compares their
starting floor heights with the second pole and the source elevator clock.
The [comparison note](../notes/goomba-elevator-timing.md) states the bounds,
activation condition, pit arrivals and remaining gameplay obligations.
