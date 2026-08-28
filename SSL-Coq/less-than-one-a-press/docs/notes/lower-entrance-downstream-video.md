# Published lower-entrance downstream video

## Verdict

The supplied video is strong visual evidence that both target stars have usable
downstream routes from the pyramid's lower entrance.  It contains two runs with
the same 95-coin approach and 100-coin-star setup.  One run then collects
Inside the Ancient Pyramid, and the other traverses all five Pyramid Puzzle
regions, visibly spawns that star, and collects it.  In both runs the video's
counter displays exactly one A press.  The recovered full transcript of
pannenkoek2012's route explanation identifies it as the A-triggered jump from
the upper second pole.  The horizontal Grindel sequence is downstream of that
gate; it is not a second, independently A-triggered mount.  No further A press
is displayed between the pole jump and the target-star collection.

This sharply localizes the gameplay problem: authenticate the two post-pole
suffixes and replace, avoid, or enter downstream of that pole jump.  The video
does not by itself prove a controller trace because no `.m64` or input log is
available, the ROM region is unknown, and the counter is part of an edited
visual artifact rather than raw controller evidence.

## Artifact and provenance

The user supplied the file under the title **“SSL Pyramid from Lower Entrance
A Presses (Inside 1xA, Puzzle 1xA)”** and identified its uploader as
[UncommentatedPannen](https://www.youtube.com/@UncommentatedPannen), an account
controlled by pannenkoek2012.  The filename contains YouTube identifier
[`pzjknw-O0rY`](https://www.youtube.com/watch?v=pzjknw-O0rY).  Those title and
account claims are user-supplied provenance; the media container itself does
not carry useful title, uploader, publication-date, input-log, or ROM-version
metadata.

The reviewed local artifact is:

- filename: `YTDown.com_YouTube_SSL-Pyramid-from-Lower-Entrance-A-Presse_Media_pzjknw-O0rY_001_1080p.mp4`;
- SHA-256: `E277A68F488F1D213796534DFF90771F442F8F0475E298490A107D64A991BE1E`;
- duration: approximately `216.898` seconds;
- video: H.264, `1542 x 1080`, 60 frames per second; and
- audio: AAC.

The hash identifies the reviewed download, not an original upload or a ROM.

## Manually reviewed timeline

Times are approximate presentation timestamps from quarter-second and
two-second contact sheets.  They are labels for relocating an event in this
exact file, not frame-perfect controller timestamps.

| Run | Approximate time | Visible event |
|---|---:|---|
| Inside the Ancient Pyramid | `00:04` | Gameplay begins at the lower entrance with 95 coins and 21 stars. |
| Inside the Ancient Pyramid | `00:20–00:22` | Mario performs a visible Amp shock/knockback sequence; the edited video alone does not establish which later trial it prepares. |
| Inside the Ancient Pyramid | `00:35.5` | Mario obtains the 100th coin. |
| Inside the Ancient Pyramid | `00:39.5` | Mario collects the 100-coin star; the visible star count changes from 21 to 22. |
| Inside the Ancient Pyramid | `01:25.75–01:26.5` | The sole displayed `A Press #1` accompanies Mario's jump from the upper second pole into the downstream Grindel sequence. |
| Inside the Ancient Pyramid | `01:46.5` | Mario reaches and collects the Act-3 target; the visible star count changes from 22 to 23. |
| Pyramid Puzzle | `01:54` | The second lower-entrance run begins with 95 coins and 21 stars. |
| Pyramid Puzzle | `02:10–02:12` | Mario repeats the visible Amp shock/knockback sequence; its exact role comes from the transcript rather than the frames alone. |
| Pyramid Puzzle | `02:25.75` | Mario obtains the 100th coin. |
| Pyramid Puzzle | `02:29.75` | Mario collects the 100-coin star; the visible star count changes from 21 to 22. |
| Pyramid Puzzle | `03:16.0–03:16.75` | The sole displayed `A Press #1` again accompanies the upper second-pole jump; the Grindel sequence follows downstream. |
| Pyramid Puzzle | `03:20.25–03:27` | Mario descends through the five puzzle regions; the coin display advances from 100 to 105 and the hidden star visibly spawns. |
| Pyramid Puzzle | `03:32.75` | Mario reaches and collects the Act-6 target; the visible star count changes from 22 to 23. |

The two runs' early events are separated by about 110.25 seconds and appear to
use the same common approach.  The edited footage alone makes the pole jump
and nearby moving-block motion easy to conflate.  The full user-supplied
transcript has now been recovered and audited (SHA-256
`B5418A6B8A40357EBC36F571EEE7A993F59288D906DCDB9FCC478AF543CBE73F`).
It explicitly calls the upper/second-pole dismount the third of five trials
and the only one still requiring A; its later Grindel/elevator misalignment is
the zero-A solution to trial 5.  The exact five-trial mapping is retained in
[`notes/transcript-candidates.md`](../../notes/transcript-candidates.md).
The Grindel's exact behavior, pool slot, surface owner, and state still have
not been authenticated by the video.

## What this establishes

At the visual-gameplay level, the footage supplies one continuous itinerary
for facts that the earlier conditional receipts split apart:

- the Act-3 run joins the lower entrance, the earlier zero-A trial solutions,
  100-coin-star interaction, second-pole jump, post-pole Amp/Grindel/elevator
  continuation, target approach, and target collection;
- the Act-6 run joins the lower entrance, the same setup and pole jump, all five
  visible puzzle events, hidden-star spawn, and target collection; and
- both runs isolate their only displayed A press to the second-pole jump,
  leaving a visibly zero-additional-A suffix after that boundary.

The second point is especially useful.  The existing conditional JP evidence
has one injected run for all five triggers and a different injected run for
the star pickup and bit change.  This video shows that the gameplay pieces can
occur in one route, although it does not provide the memory observations needed
to replace those authenticated receipts.

`proofs/Area2DownstreamContinuations.v` now records the transcript's
thin-pillar/teleporter, 100-coin-star, pole, post-pole Amp, Grindel, and
elevator stages in their corrected order, followed by the five-trigger order.
Its theorem checks that both complete transcriptions cost one marked press and
that each post-pole transcription costs zero.  A companion button-history
theorem checks one A edge followed by 33 held-A samples, release, and 32 A-up
samples; every sample after the first edge is separately proved to contain no
new A press.  These remain finite transcription/button facts, not a complete
retail or Clight execution.

## Conditional JP controller receipt

`instrumentation/jp-lower-one-a-route` installs the corrected gate on an
authentic hash-checked JP ROM.  At global timer 516 it stages the live Mario
object on the live second pole in `ACT_TOP_OF_POLE`, creates one A rising edge,
holds that same press for 34 controller polls in total, and then releases it.
This distinction is essential: releasing immediately invokes the stock
short-jump gravity rule and destroys the useful ascent, whereas held A creates
no additional press edge.  The observed retail-machine transition is:

- timer 516: pole `0x80350418`, Mario `0x80346e78`, position
  `(0,4020,1331)`, action `0x00100345`;
- timer 517: `ACT_TOP_OF_POLE_JUMP` (`0x0300088D`), position approximately
  `(-21.434,4082,1307.712)`, and forward speed `31.65`;
- timer 532: the arc reaches approximately Y `4532`; and
- timer 551: Mario lands at Y `3840` near the downstream Grindel base at
  approximately `(-803.728,3840,456.996)`, with the base receipt logged on the
  following poll at approximately `(-828.599,3840,429.974)`.

The final counters are `aPressedFrames=1`, `aDownFrames=34`,
`controllerAFrames=34`, and `injectedAFrames=34`: exactly one press edge with a
34-poll hold.  The checked-in CSV records every conditional input change from
the pole-top boundary through the first Grindel-base receipt.  A diagnostic
one-frame press followed by immediate release instead landed on the Y=`3942`
ring; it is retained only as evidence of the short-jump-gravity branch, not as
the reconstructed route.  The harness still injects the pole-top state, and
its exploratory attempt to enter the Grindel's one-unit misalignment has not
yet selected the Grindel as Mario's platform.  Consequently this is an exact
conditional pole-to-base input segment, not a complete one-A `.m64` or
star-collection movie.

## What this does not establish

The artifact does not establish any of the following:

- the exact controller state on every frame, including held A or an unmarked
  edge;
- the US, JP, or other ROM version and executable identity;
- an unedited movie or deterministic replay beginning from a named save state;
- moving-object identity, surface ownership, collision phase, or Float32
  state;
- exact trigger-object consumption, hidden-star parent lifecycle, or the SSL
  save-byte change; or
- a CompCert/Clight step sequence or a clean no-A way to replace the marked
  second-pole jump.

The visible star and HUD changes are excellent route-discovery evidence, but
they must not be promoted to memory or controller facts without a separate
receipt.

## What closes the downstream obligations

Preferably obtain the `.m64`, or otherwise reproduce each route on a
hash-identified US or JP ROM while logging every controller frame.  The full
transcript no longer blocks route identification.  Start a suffix certificate
at the first precisely named state after the second-pole jump, prove the held A
produces only the already-counted edge and that every later release/hold state
adds none, identify the homing Amp, Grindel, elevator, and their collision
owners, and carry the exact run through the target overlap and save-bit change.
For Act 6, the same run must additionally identify and consume the five source
triggers in their checked order, retain the hidden-star controller, observe the
spawn, and collect that exact star.  Project those observations into the
existing `CutDownstreamSuffix` and linked-Clight records.

That work would close the downstream portion from a supplied post-pole-jump
boundary.  A complete zero-A route still needs a clean execution that reaches
that boundary without the video's marked press, either by finding a no-A pole
exit or by arriving on target-side support through a different gate mechanism.
Failure to reproduce the displayed suffix would instead identify the first
editing, version, object-state, collision, or controller assumption that the
visual evidence concealed.
