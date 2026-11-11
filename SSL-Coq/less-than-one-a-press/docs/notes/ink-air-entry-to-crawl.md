# Can the airborne entry become crawl before Mario falls out?

The fixed successful airborne entry has not produced interior crawling in
the tested no-A continuations. The policy batch tests 6,174 continuations,
covering 129,654 subsequent game frames, without reaching crouch, crawl
startup, established crawl or a landing on the top. Delaying Z keeps Mario
inside for 20 frames, but in ground pound and then backward air knockback.
This is a bounded result for this exact supplied start, not a proof that
every high-crawl entry is impossible.

## Updates are game frames; the exact handoff timing is already missed

In these native-runtime experiments, one call to `Game.advance()` advances
one game-logic frame. The bundled Wafel API describes it as “Advance a
single frame.” This experiment also checks that the native global game
timer increases by exactly one on each call. “Seven updates inside” meant
seven successive game frames, not seven operations within one frame.

Within a single frame, however, the top moves, Mario's floor is looked up,
his action runs, and his positions are updated in order. A diagram that
separates these operations does not provide another controller-input
opportunity between them. Gameplay frames also must not be confused with
video duplicates, display refreshes or emulator screenshot indices.

The selected entry executes behavior 130 in frame 1 and ends in freefall,
with stored top timer131. The original recorded handoff needs established
crawl during behavior 130: its chapter input6 makes the split, and input7
performs the following capture. Converting to crawl after this entry cannot
retroactively supply the already-passed behavior 130 split. An earlier entry
or a separately validated later handoff would be needed to join these
mechanisms. Neither connection is established by this experiment. The
original supplied-state handoff remains demonstrated, including in the
original-JP recording; this test does not make that handoff impossible.

## Exact starting boundary and supplied edits

Every trial reconstructs the same previously verified exterior start before
behavior 130: movement/object/display position
`(-2261.5,1774.9970703125,-1048)`, freefall action, zero forward speed,
vertical velocity −16, facing 15363 and the declared action state/timer.
These Mario fields are supplied, as in the prior entry test. The accepted
four-pillar controller prefix, its pre-entry debug level select, and the
native top/actor history are retained.

The first entry input is fixed to the earlier successful witness. The game
then creates the interior state; its fields are checked against that
recorded witness before branching. The experiment does not re-supply an
action or position after entry. The shared branch point is:

| Field after entry frame 1 | Recorded value |
| --- | --- |
| Movement = collision = display | `(-2261.5,1758.9970703125,-1048)` |
| Action | Freefall |
| Forward / vertical velocity | 0 / −20 |
| Remembered floor | Static roof 1280 |
| Platform | None |
| Upper-face floor-query height / underside | 1857.18701171875 / 1523 |
| Stored top timer | 131, after executing behavior 130 |

Only controller-pad fields can be written after the one declared exterior
setup. A is absent from every pad and from the native A-pressed/A-held
flags checked after each frame. Floor/cache/platform, surfaces, hitboxes,
actors, timers and RNG receive no experiment writes. Complete-state loads
start alternative branches; they are not edits within a trial.

## What the controls do

Frame 1 below is the successful entry, so the first new input is frame 2.

| Continuation | Native result |
| --- | --- |
| Let Mario fall, then try Z after landing | Interior through frame 7; below the underside at frame 8; roof landing at frame 13. No interior crouch or crawl. |
| Press B at frame 2, then hold Z | The action log executes freefall then dive within frame 2; its completed action is backward air knockback. No top landing or interior crawl. |
| Wait three more frames, press Z at frame 5 | Interior through frame 20. Frames5–19 run the ground-pound startup; frame 20 is backward air knockback. Feet go below the cap in frame 21. |

In the longest retained interior continuation, Mario falls to
Y1686.9970703125 by frame 4, then remains at that height during ground-pound
startup. At frame 19 / behavior 148 the startup finishes. Frame 20 /
behavior 149 moves his feet to Y1636.9970703125 and changes to backward air
knockback; the underside is1618, so he is still inside. Frame 21 /
behavior 150 lowers him to Y1582.9970703125, below underside 1623. The
remembered floor stays1280 and the platform remains null throughout this
selected continuation. Extra time inside does not become a grounded state.

The source explains the action obstacle. `act_freefall` maps a fresh B
press to dive and a fresh Z press to ground pound. `act_ground_pound` has
no ordinary B/Z exit into crouching during its startup. Crouching and
starting crawl check `INPUT_OFF_FLOOR` and return to freefall if the feet
are over 100 units above the remembered floor. They also cancel on
`INPUT_ABOVE_SLIDE`; the top's approximately 45-degree faces are
`SURFACE_HARD_SLIPPERY`. An already-established crawl uses a different
sliding check. Thus preserving an existing crawl and starting one after
airborne entry are materially different obligations.

This is an explanation from the actual source and observed action history,
not a universal reachability theorem. It does not assume that every unusual
collision or action history has been covered.

A positive control follows the same supplied entry without further edits,
lets Mario fall out and settle on roof 1280, then uses neutral-Z crouching
followed by Z plus stick. It reaches crouch startup in frame 30, crouching
in frame 35, crawl startup in frame 36 and the crawl action in frame 43.
Frame 44 actually executes crawl and moves him along roof 1280 with a
100-unit hitbox. The cap has already deactivated in frame 22. This verifies
that the action transition can be detected and produced by controller
inputs after landing; it does not produce the required interior crawl.

## Finite menus and checks

The policy batch varies sixteen fixed headings plus inward, outward, both
tangents and uphill steering; stick magnitudes 16/32/64; immediate versus
three initial grounded frames of braking; and these button schedules:
Z only after grounding, delayed held Z, one-frame Z pulses, delayed B then
Z, simultaneous B+Z then Z, B then Z only after grounding, and repeated B
pulses followed by Z. Delays range from 0 through 7 subsequent frames, except
the state-dependent landing policy. Each trial follows21 further frames,
through the top's deactivation. A recorded floor owned by the top alone
would not count as landing; the landing diagnostic requires its platform
reference and a non-air action.

The separate bounded per-frame search uses100 raw pad choices: neutral or
eight stick directions at each of 16/32/64, combined with none/Z/B/B+Z. It
retains at most 96 branches using action progress and action/timer/button
diversity. Its key records native controller held/pressed buttons, not the
temporary pad buffer, which the runtime clears after consuming input.
The key is still only an observed-state projection, not a proof of full
state equivalence. Branches below the underside are discarded because
they have already failed the requested before-falling-out condition.
Finite inputs, ranking, projection merging and pruning remain limitations.

This search expands 171,900 candidate one-frame continuations. It observes
no crouch/start-crawl/crawl or top-landing witness, and its retained
frontier is empty at depth20 (frame 21 including entry), when the remaining
branches have fallen below the underside. The corrected final run records
native held/pressed button state so that a held B button is not merged
merely because the temporary pad buffer was cleared. Earlier pilot output
is retained locally but is superseded by this final receipt.

The [receipt](ink-air-entry-to-crawl-receipt.json) contains final search
counts, supplied-write ledger, selected per-frame inputs and native
observations, source/runtime hashes and fresh replay comparisons. The full
policy output remains under `build/wafel-pilot/ink-air-to-crawl-final.json`.
Four distinct representative histories replay freshly across 110 recorded
frame comparisons, counting their common entry once in each history. They
cover ordinary falling, the longest interior stall, an immediate dive,
and the successful late roof-crawl control.
These are pinned native JP runtime tests, not new original-ROM emulator
recordings or whole-memory equivalence checks. No new Coq proof or global
exclusion is claimed.

The new scripts are `instrumentation/wafel-jp-pilot/ink_air_entry_to_crawl.py`
and `ink_air_crawl_examples.py`. The first consumes the retained successful
entry witness in `build/wafel-pilot/ink-top-entry-witnesses-v2.json`; the
second consumes the final policy file. Both refuse to overwrite their
chosen output file. Run them with the bundled Wafel Python.

Relevant sibling-source connections are `mario_actions_airborne.c:525`
(freefall buttons), `:918` (ground-pound startup),
`mario_actions_stationary.c:528,693,743` (crouching/crawl startup), and
`mario.c:1353` (off-floor input). The top's slippery surface type is in
`levels/ssl/pyramid_top/collision.inc.c:10`. The local Wafel frame API
documentation is `build/wafel-pilot/python/wafel/__init__.pyi:85`.

## Why the handoff proposal existed

The supplied-state replay tested a downstream question: given high crawl
and a nearby usable box, can ordinary game processing produce the gap,
capture the top and reach the Area2 displacement? It can. That made it a
conditional mechanism relevant to examining the proof's remaining
reachability assumptions. It did not establish that a player could create
the high crawler in the first place.

The entry requirement was bypassed by the demonstration's supplied action
and position. It was never removed by the separate clean low-crawl chapter,
pillar route, box transport or conditional Coq results. There was a way to
test this prerequisite; it should have been prioritized before treating
the handoff as an actionable approach. The correct status is a demonstrated
conditional handoff with unresolved starting-state reachability, not a
usable route merely awaiting box placement.

The SSL atlas and private-site report retain that verdict. All 45
subjective estimates remain unchanged, including Rank 1 **1–2%** and Ink
Rank 2 **<1%**.
