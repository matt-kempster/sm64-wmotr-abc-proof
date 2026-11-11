# Clean hands-free holding, low crawl, and the remaining high handoff

Mario can reach hands-free holding without supplying his position or the
box's position. A continuous no-A controller history now picks up the
eastern jumping box in a dive, slides while retaining it, stops, drops it,
and enters crawl. This happens at low height: the selected release and
crawl are at Y=38, and the box dies before crawling begins. The useful
joint state—high crawl, a surviving free box in pushing range, and the
timer-130 top phase—remains unproduced.

The [commented original-ROM video](../media/ink-handsfree-and-handoff-demo.mp4)
shows that clean component, a separate supplied-position hands-free test,
and a third supplied Ink installation. It demonstrates why the mechanism
is promising and where its setup is still assumed. It cannot establish a
complete clean 0xA SSL Pyramid route: two chapters explicitly edit gameplay
state, and no chapter completes the missing approach. A
[timestamped transcript](ink-handsfree-video-commentary.md) accompanies it.

## What the clean history establishes

The study starts from proof-repository commit
`48a289c18409d17edc694c00fdb4b7864fcc94c7`. It reuses the accepted debug
level-select entry and recorded first 350 controller inputs. After that
entry there are no gameplay-state writes. Mario approaches the stock
eastern box, presses B once at sufficient actual running speed, and
continues onto the slippery slope north of it. The actual dive pickup
lands in `ACT_DIVE_PICKING_UP`; its slide exit changes to an ordinary
`ACT_STOMACH_SLIDE` while preserving the held-object reference.

“Hands-free” describes this action/reference disagreement, not empty
rendered hands. Box 47 remains visibly attached to Mario. It is the eastern
stock actor, distinct from western box 49 used by the supplied high tests.
The clean route has zero pillars credited and no spinning top. Its
unsolved top's action-0 timer is not the handoff's spinning timer 130.

The acquisition menu has 20 policy rows and 5,200 updates. Those rows give
13 distinct controller histories; nine successful rows correspond to five
distinct hands-free histories. Two selected 610-input histories replay
from fresh instances with all 260 branch snapshots plus the initial
boundary matching in each. See the [acquisition note](ink-clean-handsfree.md)
for the exact policy, source paths, fields, hashes and commands.

Continuing one clean hands-free state produces this joined sequence:

| Completed controller inputs | Observed event |
| --- | --- |
| 424 | Actual eastern-box pickup |
| 435 | Dive-picking-up landing |
| 436 | Hands-free stomach slide, box 47 held |
| 515 | Ordinary release at Y=38 |
| 516 | Box inactive |
| 528 | First crawl at Y=38 |

The exported history contains 656 inputs, all without A. In this chosen
continuation, crawling begins 13 updates after release and the box lasts
one update. These counts concern completed controller inputs. Wafel's
after-advance global timer is one greater; the native recording's camera
callback uses a different phase, documented in its receipt.

The release uses the rendered hand position's X/Z and Mario's Y. At the
selected drop, HOLP is approximately `(980.206,100.445,6269.763)` but the
box is placed at `(980.206,38,6269.763)`. Merely raising the rendered hand
does not raise this drop. Ordinary idle processing drops an existing held
object before handling the crouch input. The jumping box's dropped action
then deletes it on a landing/wall/water event. This explains this recorded
failure, not a universal one-update lifetime theorem. Exact source paths
and before/after actor fields are in the
[continuation note](ink-handsfree-continuations.md).

## How far the searches go

Forty clean stopping/release policies run for 8,800 updates. Twenty-two
enter crawl, all at Y=38 at their highest crawling sample. None has a
simultaneously alive, free and tangible box at a sampled crawl state.
The longest observed free-box lifetime is four updates, in a policy that
does not crawl. Different release histories and placements remain open.

The high tests retain the earlier explicit position cut. From 18 actual
hands-free endpoints produced after those cuts, 396 continuation policies
run for 51,480 updates and find no crawl. Three width-at-most-12 beams
test 1,143 one-update branches, also without crawl. Their height, distance,
area and ranking restrictions discard other possibilities; retained
candidates run out at depths 13 or 14. These failures do not exclude a
route that first goes lower, takes a different dive, interacts with another
actor, or uses another top phase. Five selected continuation trails replay
483 snapshots exactly in the logged projection.

The source explains why holding Z is insufficient on the roof. Butt slide
does not directly test B/Z, and its ordinary stopping path requires a
non-sloped floor and sufficiently low speed. The high supplied pickup
already descends substantially before entering hands-free slide. The
tested controls never join that slide to a suitable high stopping floor.

## What the recording shows

The 1 minute 55 second recording uses three separate boots of the
authenticated original JP ROM, a stock camera and zero A inputs. Text is
outside the game image. Pauses and slow motion repeat actual captured
frames; no generated game imagery or new camera positioning is used.

| Video chapter | Setup and observed outcome |
| --- | --- |
| 00:05–00:36: clean controller component | No gameplay edits after the accepted entry. Pickup, hands-free slide, ordinary release and low crawl. The box dies first. |
| 00:36–01:11: supplied high hands-free component | After inputs create a normal dive, twelve coordinate words place Mario M/C/D at `(-2559,1741,-1535)` and box 49 at `(-2559,1741,-1465)`. Actual pickup reaches hands-free butt slide; the continuation slides off and dies in quicksand. |
| 01:11–01:55: separate supplied Ink fixture | Crawl action is supplied at stored 129 and one native update establishes its 100-unit hitbox. At stored 130, twelve coordinate words place M/C/D at `(-1950,1741,-939)` and box 49 at `(-1989,1741,-939)`. The floor cache is not edited. The game produces the 973-unit split, captures the top, and arrives outside the elevator in Area 2. |

In the last chapter, the split is M=C `(-1882,768,-939)` with display
`(-1882,1741,-939)`. The following update selects top floor Y=1818.9613.
First Area 2 arrival is approximately `(365.592773,5500,-1096.80261)`.
The solid top hides Mario at the split from the ordinary camera; those
coordinates come from the instrumentation trace, not the pixels. Later
footage shows Mario on the upper walkway. This is a conditional installation
and elevator bypass, not evidence that the preceding clean history reaches
the supplied state, or that a target star is cleanly earned.

The native checker matches 305 distinct clean snapshots and all 146
supplied hands-free snapshots against the Wafel records in the specified
projection. The handoff checker verifies the supplied setup, split, top
capture and displaced arrival. Native traces, ROM/source/probe hashes and
all frame hashes are retained in the [native provenance](../media/ink-handsfree-native/provenance.json)
and [original-ROM note](ink-handsfree-original-rom.md). Matching selected
fields is not a theorem about whole-memory equivalence.

## Checks and reproduction

The experiment commands and exit-0 outcomes are recorded in the acquisition
and continuation notes. The three original-ROM capture commands and their
frame/input alignment are in the
[capture README](../../instrumentation/jp-ink-handsfree-demo/README.md).
The canonical [656-input controller history](../../instrumentation/jp-ink-handsfree-demo/clean-component-inputs.jsonl)
is committed for replay. Accepted entry, runtime and ROM dependencies remain
explicit; ROM bytes are not distributed.

The independent read-only study audit also exited 0:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/verify_ink_handsfree_followup.py
```

It reconstructs both receipt projections, verifies source/raw hashes and
policy scopes, recomputes the acquisition summaries and retained continuation
trail summaries, checks stored fresh-replay evidence, and matches the
canonical LF video inputs. It checks 70,114 retained button records and
9,173 retained Mario-input records for A. Other continuation outcomes are
audited as recorded trial summaries because the raw report does not retain
every policy snapshot. This read-only audit does not run new gameplay.

From `SSL-Coq/less-than-one-a-press`, the recording is rendered in
Ubuntu-24.04 using:

```sh
python3 instrumentation/jp-ink-handsfree-demo/render-commentary.py \
  instrumentation/jp-ink-handsfree-demo/video-timeline.json \
  build/ink-handsfree-commentary-reviewed.mp4 \
  --receipt build/ink-handsfree-commentary-reviewed-receipt.json \
  --transcript build/ink-handsfree-commentary-reviewed-transcript.md
```

Output names must be fresh. The rendered artifact has 3,461 frames at 30 fps,
960×1008 pixels, duration 115.366667 seconds and no audio. Its
[render receipt](../media/ink-handsfree-and-handoff-demo-receipt.json)
pins the movie, renderer, timeline and every used source frame. Representative
frames from each chapter, including long captions and the obscured split,
were visually inspected for legibility and faithful labeling.

No Coq source changes or new proof claims are made in this follow-up, and
no Coq build is presented as validation of the gameplay searches. The earlier
conditional stopped-quarter proofs retain their explicit hypotheses. The
new observations do not inherit an allocator count from an earlier fixture.

## Remaining obligation

A single controller-produced history must connect a useful box delivery
and high established crawl to the correct current-update floor cache,
eligible push, stopped first quarter, and timer-130/131 handoff. Clean
hands-free acquisition and clean low crawling now remove one local setup
assumption. They do not remove the required high geometry, actor survival,
four-pillar preparation or joint timing assumptions. The full gameplay
question remains open. All 45 atlas estimates remain unchanged, including
Rank 1 **1–2%** and Ink Rank 2 **<1%**.
