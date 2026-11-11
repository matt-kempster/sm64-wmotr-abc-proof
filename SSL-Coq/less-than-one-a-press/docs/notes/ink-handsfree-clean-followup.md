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

## Getting Mario inside the top is still an open approach problem

The [air-entry conversion follow-up](ink-air-entry-to-crawl.md) tests the
successful supplied airborne entry using only subsequent no-A inputs.
It finds no interior crouch or crawl in6,174 continuations or the bounded
per-frame search. Delayed ground pound extends interior residence to20
frames; the positive crawl control occurs later on roof1280, after the cap
has disappeared. The original behavior130 handoff remains a demonstrated
conditional mechanism with an unproduced high-crawl approach.

The [direct entry tests](ink-crawl-edge-entry.md) now reproduce the upper
face moving over a supplied exterior airborne Mario, with seven completed
updates inside while falling. A supplied supported crawler can also lose
the edge and be caught inside later, after changing to slide/freefall.
None of18,684 tested supported-crawl continuations retains crawling into
deep interior. The remaining open entry is specifically the useful high
crawl and its controller-produced approach. The earlier
[moving-top investigation](ink-crawl-moving-top-entry.md) supplies the
roof/supported-motion geometry context; its remote approaches did not test
the local entry directly.

The supplied handoff begins with Mario's position inside the spinning top.
The replay script gets him there by moving all three position records while
retaining the crawl action supplied one update earlier. Immediately before
the position edit he is near `(-5882.8374,1024,820.6389)`; immediately afterward
he is at `(-1950,1741,-939)`. The western Crazy Box is independently moved
from `(-5200,25.3623,1700)` to `(-1989,1741,-939)`. The native trace records
both sides of this cut. A controller-produced journey into this joint
high-crawl/box state remains missing.

The interior position is part of the geometry. During the timer-130 update,
the underside is at Y1523 and the upper face at Mario's initial X/Z is about
Y1914.34. His feet at Y1741 lie between them. The top floor is above the
floor query's Y1741+78 acceptance limit, so the initial lookup can select
the low pad at Y768. After the horizontal push, the crawl's separate
ceiling lookup starts from its local floor result plus 80 and can find the
underside even though Mario is already above it. These source checks explain
the supplied overlap's continuation. They provide no entry trajectory.

For the exact recorded Crazy Box handoff, actual play would have to join
the following requirements in one history.

1. Complete the four-pillar preparation while preserving an actor for the
   later push. The fourth pillar starts the top sequence. The recorded
   handoff uses the update executing behavior timer130 to create the gap,
   followed immediately by timer131 to select the top. The four-pillar
   prefix itself is controller-produced after accepted debug level select.
2. Arrive with established crawl and the native 100-unit object-contact
   hitbox, at `(-1950,1741,-939)` before the timer130 update. This is above
   the eastern edge of the low pad, five X units inside its boundary at
   X=-1945. The demonstrated replay supplies the action and high positions.
   High-pad controls starting idle, crouching or starting crawl fail to
   create this established high crawl with the tested Z inputs.
3. Have the western Crazy Box alive, free and tangible at
   `(-1989,1741,-939)` when the early collision pass runs. It starts 39
   X units west of Mario at the same Z. The native push moves Mario 68 units
   east, leaving him at X=-1882, 63 units beyond the pad edge, while
   preserving his high movement Y. A just-released box can still be
   intangible at the relevant collision pass.
4. Preserve the update order. The game first remembers the low pad, then
   the box pushes Mario outside it, then the stopped crawl retains that
   remembered floor. Display is refreshed high before movement snaps low
   and collision follows. Input7 then combines low warp contact with the
   high display retry. This continuation and the displaced Area2 arrival
   are observed in the original-JP supplied replay.

The exact coordinates describe a successful reference setup. The evidence
does not establish that every successful variant must use those values.
For example, a separate conditional release test supplies a box drop at
Y1650 before behavior126. With Mario nearby, ordinary box updates put it at
Y1626 by stored130, where its upper contact extent reaches Mario's feet at
1741. The high Mario state is still supplied separately. Releasing at the
correct place and then raising Mario into established crawl in time remains
unjoined. The ordinary drop takes Y from Mario's movement position and X/Z
from the previous rendered hand position, so actual delivery needs a real
release history at the required height and location.

The existing controller evidence supports several individual approaches.

| Component after accepted debug level select | What was achieved | Remaining connection |
| --- | --- | --- |
| Four pillars and upper warp, authenticated JP recording | All four detectors, top explosion, box-assisted roof ascent and ordinary upper-warp entry with zero A inputs | The ascent reaches the roof after the useful spinning phase and consumes the box |
| Western Crazy Box transport | A continuous no-A route reaches roof Y1280 using the three bounces | Third landing destroys the box, and the top has already begun exploding |
| Earlier western-box/Fly-Guy branch | A real Fly Guy contact drops the box alive at Y1259.51 and later raises twirling Mario to Y2099.51 | Only three pillars, release over 1200 horizontal units from the target, box gone before Mario's peak |
| Earlier stationary-top approach | Mario contacts the stationary top near Y1355 after a box-assisted ascent | Only three pillars and the box is already consumed |
| Eastern hands-free dive pickup | Original-JP footage joins pickup, hands-free slide, release and crawl at Y38 | Zero pillars, box dies one update after release, crawl starts 13 updates after release |

There is also a conditional route onto the spinning top. From a supplied
roof position at stored48, Z and stick inputs establish crawl by stored64,
reach top support at stored79 and crawl to about Y1330.63 in the tested
continuations. Support is lost by stored82 in the selected trails. The
initial roof approach remains supplied. A separate supplied-position box
pickup reaches Y2883.66 before130 while Mario is bouncing. These observations
leave the required action, interior position and timing unconnected.

Simply riding the top into place has already had one bounded test. The
calculated prior X/Z that rotates to the target has support near Y1905.12.
Supplying a crawler at that actual support height keeps a high top floor
in the tested updates. Supplying Y1741 instead starts about164 units below
that surface. Thus this candidate predecessor already assumes penetration.
Other histories remain open. There is currently no demonstrated no-A
input sequence that enters the top at the required high crawling state.

This clarification rereads the original trace, capture script, geometry and
the recorded predecessor studies. The read-only producer, box-study and
hands-free-follow-up audits all pass. They check saved evidence and declared
setup edits. The clarification adds no gameplay experiment or proof.

Sources for the geometry, route milestones and setup boundaries are the
[timer130 note](ink-timer130-handoff.md#timer-130-geometry-with-the-rounding-kept),
[crawl predecessors](ink-crawl-predecessors.md),
[box delivery](ink-box-delivery.md),
[conditional box releases](ink-jumping-box-handoff.md#a-lower-earlier-release-can-supply-the-pushing-actor-conditionally),
[original-JP trace](../media/ink-handsfree-native/supplied-handoff-trace.txt),
and [native replay script](../../instrumentation/jp-ink-handsfree-demo/probe.c).

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
