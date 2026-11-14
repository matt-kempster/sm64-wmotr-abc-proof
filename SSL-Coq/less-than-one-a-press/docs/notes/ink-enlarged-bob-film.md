# Shell, bloated Bob-omb and Crazy Box: the three-actor film

14 November 2026. Watch the fourth [Ink Handoff Film](https://ink-handoff-films.tra38.chatgpt.site/#enlarged-bob)
or open the [local MP4](../media/ink-enlarged-bob-video/enlarged-bob-handoff.mp4).
It follows the already verified conditional handoff in
[the enlarged Bob report](ink-enlarged-bob-handoff.md) and
[the original-JP comparison](ink-enlarged-bob-handoff-rom.md), committed at
`4aca530130f3c1f6b705c3060d383d8459b6d43b`.

The film matches the earlier videos: on-screen commentary, explanatory
diagrams, slowed original-JP footage and the original instrumental score
*Stored in the Dark*. There is **no spoken narration**. Its 14 chapters last
2:55. M means Movement, C means Collision, and G means Stored Graphics
(`gfx.pos`), **not** the model's drawn position or render matrix.

| Top behavior update | Actor's job | Observed result |
| --- | --- | --- |
| 128, Z | The supplied initialized frozen shell mounts Mario, then Z cancels riding. | The game creates BUTT_SLIDE from supplied FREEFALL at Y=19900. M=C ends at Y=1809.206665; G.Y remains 19900. This is immediate alignment, not a visible fall. |
| 129, neutral | A supplied radius-91 black Bob-omb gives the earlier shove. | Mario ends at (-2117.026855,1839.447266,-1113.008545), still in BUTT_SLIDE, with no platform reference. |
| 130, neutral | The initial lookup saves floor 768; the supplied Crazy Box then shoves. | The stopped ground quarter preserves that cache. M=C=(-2200.001709,768,-1075.003906); G.Y=1839.447266. Gap=1071.447266. |
| 131, neutral | Low collision reaches the real warp; high G supplies the floor retry. | Warp accepted, spinning top captured and retained through observed Area 1 boundaries. |
| Area 2 | The retained top produces the useful spawning displacement. | First checked M=(365.5927734375,5500,-1096.8026123046875). |

The separate original-JP control omits only the final Crazy Box placement.
It still gets a fresh 768 cache and a gap, and the live Bob can still nudge
Mario. But it does not capture the top and reaches ordinary (0,5500,256).
This comparison distinguishes a useful handoff from merely accepting the warp.

The film also explains why size helps this particular Bob placement: the
collision list uses Mario's earlier C, while platform carry has already
shifted M sideways. The enlarged hitbox registers against old C, then the
push acts on shifted M. Ordinary radius 65 misses the exact placement.
This is not a minimum-radius theorem or a general exclusion of smaller actors.

Fresh captures rerun both known original-JP cases without changing their
gameplay setup. Separate closeup images modify only the camera node used for
rendering; each such view is labeled. Their measured gameplay states and
collision outcomes are compared with the unchanged-camera capture. Rendering
and shadow-query differences are retained in the capture record; this is not
whole-execution equivalence. Missing transition observations are not filled
with invented frames. First-arrival coordinates come from the native log;
later displayed images show the continuation, not a claimed first frame.

Reproduction and hashes are in `instrumentation/jp-ink-enlarged-bob-video/`
and `instrumentation/ink-enlarged-bob-film/`. The
[timed commentary](../media/ink-enlarged-bob-video/enlarged-bob-handoff-transcript.md)
and [media receipt](../media/ink-enlarged-bob-video/enlarged-bob-video-receipt.json)
preserve chapter timing, sources, codecs, duration and audio measurements.
The original ROM and emulator binaries are not distributed.

The three local actors are the shell, bloated black Bob-omb and Crazy Box;
there is no Buddy or fourth placed pusher. Shell preparation, high airborne
Mario/shell, a copied native Bob profile, and later Bob/Box placements remain
supplied. The no-A donor history is separate from this receiving history.
No Mario edits follow the initial air cut, and A stays released in the
continuation. The video does not establish joined delivery, high entry or a
continuous no-new-A route. It adds no Coq theorem or height interval. Both
sites remain private, and all45 subjective estimates remain unchanged,
including Rank1 **1–2%** and Ink Rank2 **<1%**.
