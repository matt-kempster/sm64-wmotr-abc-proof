# Alternative clean hands-free acquisition routes

The extra approaches did not produce a stronger carrier for the timer-130
handoff. They did confirm an important staging constraint: the accepted
three-pillar history has already destroyed the eastern jumping box. Its later
stock jumping box is the western one, whose tested dive pickups land on flat
ground and enter ordinary box bouncing. A clean eastern hands-free pickup and
a clean three-pillar checkpoint cannot simply be combined.

This is a native finite experiment and source review at
`b53d39e5277919dc35e53a94e767d2d58bfd323e`, not a Coq theorem or an exclusion of
other controller histories. It builds on [the first clean hands-free
acquisition](ink-clean-handsfree.md). The actor remains a jumping box only
while its behavior and active flags confirm that identity; later occupants of
the same object slot do not count as that box.

## New approach screen

The [script](../../instrumentation/wafel-jp-pilot/ink_handsfree_acquisition_routes.py)
and [receipt](ink-handsfree-acquisition-routes-receipt.json) use the pinned JP
native runtime and accepted input capture. The sole non-controller setup is
the existing pre-entry level-select flag. Each branch restores a complete
state produced by an accepted prefix and then supplies only stick, B and Z.
No gameplay positions, actions, timers, held references, floor caches or RNG
are patched. The advance helper checks both controller A and Mario's native A
input bits at every update.

| Family | Policies | Unique histories | Updates | Actual pickups | Hands-free exits |
| --- | ---: | ---: | ---: | ---: | ---: |
| Eastern diagonal approaches, prefix 350 | 24 | 24 | 5,009 | 24 | 8 |
| Direct western approaches, prefixes 2390/2500 | 24 | 10 | 6,602 | 9 | 0 |
| Staged western approaches, prefix 2500 | 18 | 15 | 7,860 | 12 | 0 |
| Total | 66 | 49 | 19,471 | 45 | 8 |

Eastern approaches use six new diagonal run-ups, each with either zero or 24
neutral updates before departure, and either a through-line destination or
steering toward the pyramid after B. Western approaches vary approach side
and dive trigger radius; the staged family first reaches `(-5500,2300)` to
avoid several unsafe direct paths. The exact lists and per-update controls
are recorded. The fixed horizon is 420 eastern, 500 direct-western or 650
staged-western updates, with an earlier stop 120 updates after the hands-free
exit or a pickup that does not become hands-free. Area/level departure also
ends a branch. The 21 western policies without a pickup do not exercise the
pickup exit; the 21 actual western pickups do.

All eight new eastern exits execute
`DIVE_PICKING_UP → STOMACH_SLIDE`. None executes the off-floor exit to
`FREEFALL`. The highest sampled hands-free held position is
Y=`113.34671783447266`, lower than the previous study's observed best
Y=`125.98966979980469`. The selected new witness approaches through
`(915,7044)` and continues toward `(1667,4976)`. After 350 accepted inputs and 80
branch inputs, global timer 431, it holds box 47 while stomach sliding at
`(1282.304931640625,34.79755783081055,6022.416015625)`, forward speed
`42.18490982055664`. It has zero touched pillars and the top is in action 0.
Its action 0 object timer 83 is **not** spinning phase 83.

All 21 actual western pickups enter `DIVE_PICKING_UP` on a sampled floor with
type 0, normal Y=1 and Mario Y=0. They subsequently execute
`HOLD_IDLE → CRAZY_BOX_BOUNCE`; none preserves the box through a hands-free
exit. Representative landing positions are `(-5212.86,0,1306.15)` and
`(-4791.80,0,1639.62)`. This is the observed obstruction in these approaches:
the dive does not reach the slippery/off-floor pickup exception. It is not a
proof that every western approach must land on flat ground.

No branch contains crawling or a spinning-top sample. Three independently
created games replay the selected eastern, direct-western and staged-western
histories. Every initial snapshot and respectively 200, 348 and 302 branch
snapshots match exactly. These checks cover the recorded snapshot fields and
do not assert bytewise equality of every hidden runtime field.

## Why the eastern actor cannot be reused after the accepted three pillars

The same run audits the accepted history, without changing its controls:

* After 375 inputs, global 376, Mario holds eastern box 47.
* After 490 inputs, global 491, Mario still holds 47 in `CRAZY_BOX_BOUNCE`,
  action argument 2, at Y=337.4878.
* After 491 inputs, global 492, Mario enters `STOMACH_SLIDE` at Y=286.0224 and
  releases the reference. The box still has its jumping-box behavior but is
  inactive.
* After 492 inputs, global 493, slot 47 has a different behavior.

The level, area and life count do not change between input 350 and 2500. This
is ordinary third-bounce destruction in that accepted history, not a death
or level reload. The relevant source sets `INT_STATUS_STOP_RIDING` on the
third landing, clears `heldObj`, and the jumping-box callback explodes the
actor: sibling decomp `src/game/mario_actions_airborne.c:1070–1078` and
`src/game/behaviors/jumping_box.inc.c:74–77`.

Full scans of all 240 object slots find jumping boxes 47 and 49 at input 350,
and only 49 at inputs 1000, 1500, 2000, 2390 and 2500. In particular, returning to
the eastern spawn point after the accepted three-pillar checkpoints does not
restore that actor. Preserving eastern 47 while preparing pillars requires a
different continuous history, or western 49 must supply the later box.

Two exploratory control changes removed B from the accepted history over
inputs 351–600 or 351–2500. Both preserved eastern 47 through input 2500 but
reached zero pillars. Eight exploratory return routes from prefix 2500 are
excluded from the acquisition screen because the eastern actor was absent
at their initial boundary; they are unexercised acquisition attempts. These
explorations are not fresh-replay-certified witnesses. Their raw controls
remain in ignored `build/wafel-pilot/ink-east-preserve-600-probe.json`,
`ink-east-preserve-2500-probe.json` and
`ink-three-pillar-east-return-probe.json`.

## Source constraints on changing action while holding hands-free

These are source facts about the named handlers; reachability of their
preconditions remains a separate question.

* `mario_actions_object.c:213–235`: the off-floor and above-slide exits from
  `DIVE_PICKING_UP` set a new action without first dropping the held object.
  A flat landing instead finishes the animation into `HOLD_IDLE`.
* `mario_actions_stationary.c:439–455` and
  `mario_actions_moving.c:875–878`: a jumping box in ordinary `HOLD_IDLE` or
  `HOLD_WALKING` takes the special crazy-bounce guard first. Generic held-idle
  Z cancellation does not bypass it.
* `mario_actions_moving.c:1520–1544`: stomach-slide B rollout requires
  `INPUT_ABOVE_SLIDE` to be clear and explicitly drops the object. This does
  not provide a way to roll out while retaining the hands-free box.
* `mario_actions_object.c:298–315`: `STOMACH_SLIDE_STOP` can preserve holding
  through off-floor or above-slide exits, but its ordinary animation ends in
  `IDLE`. Common idle cancellation and walking drop held objects.
* `mario_actions_airborne.c:525–550`: if a hands-free carrier actually reaches
  `FREEFALL`, B selects `DIVE` without an explicit drop in that handler. This
  is a possible continuation condition, not a state produced by this screen.
* `interaction.c:1086–1109`: tornado interaction calls
  `mario_stop_riding_and_holding`; it cannot be assumed to lift a hands-free
  carrier without disturbing the box reference.

The missing joint state is still a controller-produced high crawling Mario,
a live nearby box, the required remembered floor and a compatible spinning
phase. None of the new observations supplies that conjunction, a useful
earlier payoff, or a complete no-A Ink route.

## Checks

From the SSL project directory, the final native run was:

```powershell
./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_handsfree_acquisition_routes.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-handsfree-acquisition-routes-20261112-v3.json --receipt build/wafel-pilot/ink-handsfree-acquisition-routes-20261112-v3-receipt.json
```

It exited0 and reported the 66-policy totals above; the compact receipt was
copied to the committed notes path. Earlier 48-policy and pre-history-audit
66-policy reports are superseded, not counted as additional distinct search
scope. The raw final report is ignored build output; the tracked receipt
retains its hash, source/runtime/helper hashes, policy summaries, complete
controls for the three selected replays, and the accepted-history audit.

Read-only verification, without gameplay calls:

```powershell
./build/wafel-pilot/python/python.exe -m py_compile instrumentation/wafel-jp-pilot/ink_handsfree_acquisition_routes.py instrumentation/wafel-jp-pilot/verify_ink_handsfree_acquisition_routes.py
./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/verify_ink_handsfree_acquisition_routes.py
```

Both exited0. The verifier checks exact receipt projection, hashes, counts,
no-A control/native samples, the absence of direct gameplay writes in the
study, stored fresh-replay assertions, western flat landings and the accepted
eastern-box deletion/pool scans. It checks the recorded replay assertions;
it does not rerun those games. No Coq file was changed and no Coq result is
claimed by this study.
