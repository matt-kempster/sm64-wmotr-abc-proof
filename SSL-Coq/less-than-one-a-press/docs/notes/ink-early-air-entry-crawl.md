# Earlier airborne entry: inside before 130, but no interior crawl found

Earlier entry can put Mario inside the spinning top before behavior 130.
The tested controller continuations still do not turn that into crawling
inside it. A fresh witness stays inside continuously from behaviors 114
through 129, but is in ground pound at the start of 130. A separate control
reaches crawling at behavior 126, on the static roof below the top. These
are different histories; neither supplies the high crawler required by the
existing Crazy Box handoff.

This is a finite native-JP experiment, not a global impossibility result.
The original supplied-state handoff remains demonstrated. No box placement
or new route search is part of this test.

The [focused landing-113 follow-up](ink-top-slide-to-crawl.md) now tests
braking after this native landing and after the neutral slide at 117.
No tested continuation reaches crawl through the last spinning behavior
150. Even below the ordinary stopping speed, the steep floor prevents the
normal stop. A native walking alternative also changes to butt slide when
Z is pressed; it does not supply the missing crawler.

## What was supplied

Each experiment replays the accepted pre-game debug level select and the
same 2,548 recorded no-A inputs that credit all four pillars. Neutral inputs
then let the actual top reach the chosen behavior time. This reuses the
four-pillar object history; it does not demonstrate Mario's approach to the
top or supply a three-pillar route.

At that point, one exterior setup supplies:

- Mario's movement, collision-object and display positions, all equal;
- freefall, with action state and action timer zero;
- his facing direction, forward speed and velocity (vertical speed −16).

Every supplied point is checked outside the top's interior before the first
input, with strictly positive feet clearance above the plane through the
actual old native collision vertices, without rounding X/Z. There is no
supplied crouch or crawl. The original floor cache,
platform reference, action argument, hitbox and other unlisted state are
inherited, not edited. The first native update refreshes the floor normally.
The top, box, other actors, collision meshes, timers, pillar count and RNG
receive no experiment writes.

After this one setup, a guarded wrapper permits only the three controller
pad fields. Every input keeps A off; every recorded update checks native
A-held/A-pressed input flags and controller fields. Complete native state
loads separate alternative trials; they are not mid-trial state edits.
The receipt retains supplied-write ledgers and fresh representative traces.

## Timing and what counts as inside

One update is one native game-logic frame. A row labeled behavior 129 has
executed that behavior and ends with the top timer stored as 130. Thus
"at the start of 130" means the completed boundary after behavior 129,
before behavior 130 moves the top or runs Mario's action. The native global
timer is checked to increase by exactly one per advance.

The interior test uses Mario's **feet/movement point**, the recorded native
collision mesh, and the actual upper-face floor-query rounding. His feet
must be above the underside and below an upper face at his X/Z. A **deep**
entry also exceeds the floor query's 78-unit allowance. This distinguishes
the handoff's relevant interior from body overlap, a shallow floor-query
overlap, or crawling underneath the object.

Action-entry observations occur within a frame; completed states occur
after it. They do not provide separate input opportunities. For example,
freefall and squished can both execute during behavior 100.

## A continuous earlier entry that reaches the correct time

The selected deep witness supplies exterior freefall immediately before
behavior 114 at `(-2261,1694.549072265625,-1047.5)`, facing 15363, forward
speed zero and vertical speed −16. Its feet start one unit above the
recorded old upper-face query height. The first input is the same kind of
no-button, face-relative stick input used by the original airborne test.
Subsequent inputs steer inward with magnitude 32; Z starts at behavior 118.
The exact integer pads are in the receipt.

| Behavior just executed | Native result |
| --- | --- |
| 114 | Freefall inside: feet Y1678.549; upper face Y1776.549; underside Y1443. The game remembers roof Y1280. |
| 115–117 | Remains inside while falling. No action or position is re-supplied. |
| 118 | Z starts ground pound at Y1606.549; it does not start crouching. |
| 129 | Still continuously inside and in ground pound: feet Y1606.549, underside Y1518, upper face Y1774.095. This is the boundary immediately before 130. |

Movement, collision and display positions agree at all 16 completed
boundaries of this witness. At the final boundary the remembered floor is
1280 and there is no platform reference. It supplies neither the original
handoff's established crawl nor its remembered low-pad floor of 768, and it
does not create the original movement/display gap. The top has not yet
performed behavior 130; its later Y1523 underside must not be substituted
for the Y1518 mesh in this row.

An earlier completed entry at behavior 112 is also verified. In the selected
neutral continuation, the rotating face catches Mario at behavior 113 and
installs its floor/platform. He enters stomach slide at 117 rather than
crouch or crawl. This tests an actual native landing; the experiment did
not assume that airborne entry precluded subsequent contact with the top.

## Why simply starting earlier does not settle the action problem

The old exterior seed menu has within-frame deep entries as early as
behavior 66, but none ends a frame deeply inside before 112. The retained
controls at 68, 100 and 111 show the squish mechanism: the game finds a
static floor and the top's underside as a dynamic ceiling. When their
separation is at most 150 units, it sets the squished input. The airborne
action cancels into squished, whose normal handler snaps Mario to the floor.
This happens inside the same frame, not after another controller input.

At behavior 100, for example, the initial exterior feet are Y1377.040.
The moving face passes over them, but the recorded floor is 1280 and ceiling
1373: a 93-unit separation. Both freefall and squished appear in that frame's
action log; its completed feet position is Y1280, below the cap's underside.

An A-off control then waits for ordinary idle, holds Z to crouch and adds
stick to crawl. It reaches crouch startup at 113, crouching at 118, crawl
startup at 119, and the crawl action at 126. It actually executes crawl at
127 with the native 100-unit hitbox. Its feet remain on roof 1280, below the
Y1508 underside at that time. A second control starts at 111 and reaches
crawl at 127, executing it at 128, also below the top. These controls verify
that the detector and input schedules can produce crawl before 130; they
do not count as interior-crawl successes.

The source explains the different obstacles. Freefall maps Z to ground
pound. Crouch and crawl startup reject being too far above the remembered
floor and reject a slippery slope. The top's upper faces are hard-slippery.
The 112 landing witness subsequently slides. These source connections and
native observations explain the tested outcomes; they are not a theorem
excluding every possible collision or input history.

## Finite coverage

The primary survey proposes 187,200 starts and tests **186,288 strictly
exterior starts**, covering
every behavior time 0–129, four faces, five along-edge fractions, face
insets 8/128/256, heights 1/80 above the upper face, four relative facings,
forward speeds 0/32/64 and vertical speed −16. It rejects 912 proposed starts
that already overlap the actual triangle. It records 3,336 deep action-entry
observations and **507 completed deep entries**, all airborne,
at behaviors 112–129. It retains every completed deep entry regardless of
the resulting action; no grounded candidate is discarded by an air-action
filter in the final run.

All 507 entries receive the same 42-policy menu: native-idle settling then
Z and movement, Z after grounding, delayed held/pulsed Z, B then Z, B then
grounded Z, and B+Z then Z. Directions include inward/outward and, for the
settling/landing policies, both tangents. Delays are 0/3/6 and magnitudes
32/64 as recorded. Trials continue through the boundary before 130 even
after an exit, so later re-entry is not pruned.

This gives **21,294 policy labels and 187,908 subsequent frame advances**,
with no crouch, crawl startup or crawl. Policy labels are not necessarily
distinct input sequences. The 24 starts at behavior 129 have no remaining
continuation frame, accounting for 1,008 zero-length labels; 20,286 policy
runs have at least one subsequent input. There are 3,410 labels ending
inside at the start of 130, 3,154 ending deeply inside, and 13,276 with a
top landing at some point. None ends as an interior crawler. Those counts
overlap and must not be added as distinct histories.

A separate higher-face survey proposes 201,600 starts and tests **199,308
strictly exterior starts** over
behaviors 60–129 using insets 320/352/384/416/448/480, to check nearer the
apex and low pad. It rejects 2,292 initial triangle overlaps and finds no
deep action-entry or completed deep first-frame
entry in that menu. It therefore has no accepted roots for a continuation
batch. Combined, the two final surveys test 385,596 strictly exterior starts.

The first restricted pilot continued only one selected entry per
phase/face/speed. A later audit found that a nominal one-unit clearance over
the rounded floor query could lie fractionally inside an unrounded triangle.
The final reruns exclude all 3,204 such proposals before that proposal's setup
or game advance, removing 24 previously accepted entries. The selected explanatory
examples have positive actual clearances and reproduce unchanged. The final
counts above supersede both pilots; their counts are not added. Full reports remain in
`build/wafel-pilot/`; their exact hashes are retained in the receipt.

These are finite menus of first-frame entries from supplied freefall.
Different exterior poses, vertical velocities, multi-frame entry approaches,
button timings and adaptive input sequences remain untested. The work does
not establish a normal-play approach, a complete no-A route, or a global
exclusion of high crawl.

## Verification and reproduction

The [receipt](ink-early-air-entry-crawl-receipt.json) contains the menus,
all accepted entry recipes, summary counts, supplied-write ledgers,
representative inputs/states/native meshes, and source/runtime/raw hashes.
Eight distinct representative histories freshly replay, matching 197
recorded game-frame boundaries in the declared projection. Repeated
category names referring to the same history are counted once. This is
not whole-memory equivalence or a new original-ROM emulator recording.

The pinned Wafel 0.8.5 JP DLL has SHA-256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The three scripts are in `instrumentation/wafel-jp-pilot/`:
`ink_early_air_entry_crawl.py`, `ink_early_air_apex.py` and
`ink_early_air_controls.py`. They use the existing replay and observation
helpers and refuse to overwrite their output files. From this proof
directory, with fresh output names:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_early_air_entry_crawl.py build/wafel-pilot/ink-early-air-entry-exterior.json
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_early_air_apex.py build/wafel-pilot/ink-early-air-apex-exterior.json
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_early_air_controls.py build/wafel-pilot/ink-early-air-controls-exterior.json
```

The controls consume the inclusive batch at the shown path. Move an existing
output aside before reproducing under that fixed name. The optional apex
`--survey` argument continues a saved apex survey if it contains accepted
entries; this run has none.

Relevant sibling-source connections are `mario.c:1344` (dynamic
floor/ceiling squish test), `mario_actions_airborne.c:2051` (squish cancel),
`mario_actions_cutscene.c:1484` and its final `stop_and_set_height_to_floor`
call (squish action), `mario_actions_airborne.c:525,918` (freefall buttons
and ground pound), and `mario_actions_stationary.c:528,693,743`
(crouch/crawl startup). The receipt pins these source files. No Coq source,
capstone assumption or theorem is changed.

The SSL atlas and private-site report retain the same verdict: earlier
interior residence is demonstrated from supplied exterior freefall;
interior crawl before the handoff remains unresolved. All 45 subjective
estimates remain unchanged, including Rank 1 **1–2%** and Ink Rank 2 **<1%**.
