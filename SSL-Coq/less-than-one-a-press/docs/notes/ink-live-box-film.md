# Live solid-box film and the M / C / G convention

14 November 2026. The third [Ink Handoff Film](https://ink-handoff-films.tra38.chatgpt.site/#live-box)
explains the previously verified conditional live-large-box landing, shell
shove and useful Area 2 arrival. The original crawl and VPU films have also
been re-rendered to use **G = Stored Graphics** throughout their current
captions, diagrams, legends and commentary. M remains movement; C remains
the raw collision position. G refers to `gfx.pos`, not the model's drawn
position or its render matrix. Historical telemetry fields named D retain
their original bytes; the new presentation maps that field to G.

Watch the [live-box film](../media/ink-high-solid-video/live-box-handoff.mp4)
or read its [timed visual commentary](../media/ink-high-solid-video/live-box-handoff-transcript.md).
It uses annotated original-JP images, diagrams, held frames, slowed sequences
and instrumental music, in the same on-screen-commentary style as the earlier
two films. There is no spoken narration. High-camera images often show sky:
the diagrams explain measured coordinates rather than pretending that the
visible Mario model occupies the stored graphics position.

The selected replay and its limits were already recorded in
[the live-solid study](ink-high-solid-support.md) and
[the original-JP check](ink-high-solid-support-rom.md), committed as
`c1b643cab2963f8b7af18fd71a6089b24c847f44`. This video adds no new gameplay
experiment, height search or Coq theorem.

| Stage | What the film shows |
| --- | --- |
| Supplied start | FREEFALL at (-1950,25001,-939), eastward speed32, live large box at (-1849,24800,-939); the box top is25000. Shell availability is supplied. |
| First update, B | The native air step reports LANDED and selects DIVE_SLIDE. Final M=C=G=(-1950,25000,-939), outside the box, while the fresh static floor cache remains768. The default ceiling sentinel20000 rejects the candidate X/Z/cache replacement. |
| Final supplied edit | Only shell XYZ is set to (-1971,25000,-939). There are no later Mario edits, no support removal and no supplied ground action. |
| Producer update | The shell shoves without mounting. M=C=(-1882,768,-939), G=(-1882,25000,-939): gap24232. The slide reaches alignment and ends in GROUND_BONK. |
| Acceptance/capture | Low collision contacts the real warp. The stored-graphics retry selects spinning top61 and installs the platform reference. |
| Useful arrival | Update26 from the high cut reaches (365.5927734375,5500,-1096.8026123046875), differing from ordinary spawn (0,5500,256). |

The large box remains live and fixed. Its mesh is still present during the
producer and unloads on the next update as Mario is now low. The film does
not show the box breaking, standing on the high box at the completed landing
boundary, or an invented controller opportunity inside an update.

The original-JP run has27 disclosed state writes, with A released throughout
the recorded prefix and suffix. It has24 comparable boundaries:1035 of1080
compared components match Wafel, and45 interaction-subtype differences remain.
Two transition camera observations are absent. The film explicitly labels
those gaps, its source-derived explanations, and the separate Wafel frozen-box
control. Original-ROM negative controls were not added for this film.

The reproduction package is `instrumentation/jp-ink-high-solid-video/`.
Its frame map, source-image hashes, storyboard, renderer and video receipt
preserve the distinction between native observations and explanatory panels.
The two earlier films' G-label update is recorded separately under
`instrumentation/ink-g-label-update/`; their game-image selection, timing and
existing instrumental audio are retained. Historical D editions remain
archived for provenance, rather than being presented as the current films.

High Mario, a live high solid surface and the correctly timed pusher are still
supplied. The tested frozen clone does not supply a reloaded high floor mesh;
this is not a general clone impossibility theorem. Mario entry, actor delivery
and their phase join remain unresolved. Both viewing sites remain private.
All45 subjective route estimates remain unchanged, including Rank1 **1–2%**
and Ink Rank2 **<1%**.
