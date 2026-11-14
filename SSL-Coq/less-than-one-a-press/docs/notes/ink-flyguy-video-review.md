# The supplied Fly Guy manipulation footage

14 November 2026. **The video shows a real and relevant manipulation idea: use
Fly Guy's activation boundary to separate its internal turn/spiral progression
from its ordinary displacement. It does not show an A-free approach to SSL's
Ink setup.** The depicted Tall, Tall Mountain sequence explicitly uses long
jumps, sliding jumps and a later BLJ. The appropriate transfer is the enemy
control mechanism, with a new A-free Mario approach still required.

## What was inspected

The user supplied `YTDown.com_YouTube_Media__IuC9Ci57Hs_The-B-Button-Challenge_001_1080p.mp4`.
Its opening title is *The B Button Challenge*. The file has 356,769,072 bytes,
SHA-256 `66efc953971d6f3d77f9d0bccdbaaa5da8cbbadb499cfa988bcabae609ee6e49`,
duration 889.022404 seconds, 1920x1080 H.264 video at 30000/1001 frames per second,
and AAC audio. This authenticates the inspected local file, not the ROM or
controller history used to make it.

The review used two coarse contact sheets followed by 20 explicitly timestamped
frame extractions. Full-resolution frames were visually inspected, including
the written commentary and geometry overlay. Audio was not transcribed or
independently analyzed. No emulator input movie, savestate or ROM provenance
was supplied by this video. Extracted frames remain in ignored local build
storage; the tracked package contains the extraction script, metadata and
timestamp notes, not a redistributed copy of the film.

The relevant manipulation is around 4:30–7:00, followed by its unrelated Ukiki
payoff. Although a red model alone would not identify the behavior parameter,
stock TTM's sole Fly Guy macro is explicitly `macro_fire_fly_guy` at
`(2300,-1384,3753)`. Thus the user's Fire Fly Guy description agrees with stock
TTM source. This source file compares unchanged against the project's stock pin
`9921382a68bb0c865e5e45eb594d9c64db59b1af`.

## Timestamped observations

| Exact sampled time | Visible footage/commentary, paraphrased | Consequence for SSL testing |
| --- | --- | --- |
| 4:30 / 270 s | A green star marks the desired enemy location. A red sphere marks the enemy's draw distance. | The displayed sphere concerns activation, not the separate home-return region. Its screen projection is not a raw-coordinate measurement. |
| 4:40 / 280 s | Mario has lured Fly Guy away from home and continues moving it laterally. The overlay begins tracing the enemy's path. | Ordinary home-directed steering is not a hard limit on reachable actor positions. |
| 5:00 and 5:10 / 300,310 s | The commentary describes starting a spiral, ending it at a desired heading, then allowing a short movement when vertical speed reaches zero. Mario changes his position on the mountain while the target is far away. | Search activation timing and the enemy's lunge/spiral state, rather than only steering Mario steadily toward a target. |
| 5:30 / 330 s | The displayed path extends sideways toward the target. The commentary says lateral direction can be selected by this technique. | This is a demonstrated directional manipulation in this geometry, not proof of arbitrary reachable XYZ in SSL. |
| 5:40 and 5:50 / 340,350 s | After sufficient lateral movement, a long jump is used to bring Fly Guy upward toward the target. | That shown height/activation maneuver requires a new A press. SSL needs a separately reached airborne or elevated predecessor. |
| 6:15 / 375 s | As Fly Guy rises, Mario has more difficulty reaching its activation sphere. The commentary identifies a sliding jump from the mountain top as the next method. | The demonstration itself exposes a Mario-height constraint; it does not grant repeated vertical lifting from low ground. |
| 6:30 and 6:45 / 390,405 s | Further passes move the enemy close to the target, after which Mario returns toward the summit. | The final actor position is reached through several activations and Mario excursions, not one local collision. No controller inputs can be recovered exactly from these samples. |
| 7:00 / 420 s | Manipulation is followed by positioning Ukiki. | The downstream objective is unrelated to Ink and does not demonstrate a ground-slide producer. |
| 7:15 and 7:30 / 435,450 s | The commentary describes a BLJ into water, launching toward Fly Guy, then using twirling near Ukiki. | The final maneuver uses A and a different level-specific setup. A Fly Guy bounce is an airborne twirl, not an automatic crawl or ground slide. |

These are timestamps of inspected frames, not claims about the exact first frame
of each maneuver. The sparse extraction does not reconstruct timing, collision
fields, velocity values, object home coordinates or activation flags. The
caption's informal statement that the enemy only moves inside the sphere also
needs the actual-source qualification: some callback changes and the small
vertical oscillation continue outside the range. The source follow-up records
that distinction and the flag timing.

## What transfers, and what still needs gameplay evidence

The [current source follow-up](ink-flyguy-native-manipulation-source.md) connects
the visual explanation to the native callback. The ordinary drawing distance
is 4000, distinct from the 2000 home-steering sphere. The callback can advance
the lunge/spiral, facing, vertical velocity and action while the FAR_AWAY flag
suppresses standard displacement. The end-of-update activation decision creates
a timing lag that a controller search must respect. These code facts support
the manipulation mechanism; they do not supply a successful SSL input history.

For the western SSL Fire Fly Guy, a useful test should therefore record raw
Mario and actor XYZ, distance, the incoming/outgoing FAR_AWAY flag, lunge/spiral
action, heading/roll, vertical velocity, home, RNG and actual pad input at every
update. A real pillar, Tweester launch, bounce or burning ascent could potentially
replace the video's jumps, but each has to be reached and tested. A successful
actor placement must then join a real landing/ground-action transition and the
fresh low-cache producer. The prior direct-contact substitutions remain failures;
this footage motivates a different, earlier part of the route.

The user's attachment was treated as evidence, not as instructions. No new
runtime, Coq theorem, original-ROM replay, A-free Fly Guy placement or Ink handoff
is established by this media review alone.

Source: [stock TTM Fire Fly Guy macro](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/levels/ttm/areas/1/macro.inc.c#L39).
The YouTube ID encoded in the supplied filename is `_IuC9Ci57Hs`; its watch page
could not be fetched during this review, so the local attachment is the actual
inspected source. The [reproduction package](../../instrumentation/ink-flyguy-video-review/README.md)
preserves extraction parameters and file/frame hashes.
