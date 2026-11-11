# Forward transport from the clean hands-free pickups

The five previously distinct clean eastern-box pickups do not yet deliver
the box to the pyramid. In this bounded search, Mario climbs only to
Y=127.057381 while holding the stock box, slides back onto low ground,
stops and drops it. The closest held sample remains about 7,456.31 X/Z
units from the pyramid center. No pillar is credited, the top never
starts spinning, and no high crawl is produced. These results concern
the specified inputs and pruning rules, not every possible continuation.

This study starts at proof-repository commit
`b53d39e5277919dc35e53a94e767d2d58bfd323e` and builds on the
[clean acquisition](ink-clean-handsfree.md). It does not use any of the
supplied high roof positions. The new script is
[`ink_handsfree_transport.py`](../../instrumentation/wafel-jp-pilot/ink_handsfree_transport.py),
with a [durable receipt](ink-handsfree-transport-receipt.json).

## Starting histories and search scope

The source acquisition trials are indices 0, 5, 6, 15 and 16. Each is
reconstructed from the accepted first 350 controller inputs, followed by
its own recorded acquisition controls through the first actual hands-free
exit. Their starting speeds are approximately 42.13, 37.54, 37.40, 44.06
and 43.68. All five hold eastern stock jumping box 47 in ordinary
`ACT_STOMACH_SLIDE`, at Y between 18.56 and 40.26 near Z=6000. These are
five different native histories, not five changes to one supplied pose.

The sole non-controller initialization remains the accepted pre-entry
`gDebugLevelSelect=1`. No Mario/actor position, velocity, action, held
reference, floor cache, RNG or timer is written. Search branches restore
whole native states reached by recorded inputs. Every advanced controller
input excludes A, and the helper checks Mario's A-pressed/down input bits
after each advance. The final report pins the capture, native DLL,
acquisition report, script and helper hashes.

Nine distant waypoint policies aim directly toward the pyramid or toward
east/west approaches around the intervening terrain. Each has ordinary
full-stick steering and an alternative that would press B only during
normal `FREEFALL`. They allow 700 updates and retain twelve updates after
the first loss of the held live box. The targets include the pyramid
center `(-2048,-1024)`, western approaches through `(-4000,4000)`, and
eastern approaches through `(3200,3000)` or `(5000,3500)`; the exact ordered
menus and 250-unit waypoint radius are in the script and receipt.

The resulting **90 policy rows are only 45 distinct seeded input
histories**, totaling **9,202 updates**. Every route loses the held box
between continuation updates 80 and 102. No route reaches `FREEFALL`, so
the conditional B variants produce identical controls: this batch does
not exercise the proposed airborne re-dive. The distant waypoint plans
end on the starting terrain, before useful pyramid delivery.

Fifteen beams add three objectives for each starting history: progress
toward the pyramid, height, and speed. Their widths are at most 12, 12
and 24 respectively, with four-input blocks and a 360-input horizon.
The fourteen options are pyramid-directed steering, seven directions
relative to current velocity, four cardinal directions, north with B
only in `FREEFALL`, and east with Z released for one input and then held.
All other entries hold Z. Heading is translated using the actual camera
yaw on every update.

The beam retains only states with the original live box 47 still held,
valid Area 1/camera, no queued warp and health at least 0x100. It ranks
distance, height and speed, then keeps coarse 80-unit position/height,
speed, action and yaw cells. These restrictions deliberately leave other
histories unexplored. The raw report records each depth's passing and
retained counts, all evaluated action counts and rejection reasons.

The beams evaluate **66,906 short branches and 263,494 native updates**.
Reconstructing the retained candidates adds another 19,056 advances, for
282,550 beam advances altogether. These numbers count repeated prefixes
and are not counts of distinct complete controller histories. Every beam
runs out of retained candidates at depth 23–31, i.e. after at most
92–124 inputs; none exhausts the nominal 360-input horizon. The explicit
rejections are loss of the original live held box. Width/ranking/cell
pruning discards further candidates before those terminal rejections.

## What fails locally

Across the route histories and every evaluated held beam sample, the
highest Mario Y is **127.05738067626953**. The closest held sample is
`(410.2904052734375,0.533855676651001,6015.41748046875)`, still
7,456.312103244369 units from the pyramid center in X/Z. Every recorded
pillar count is zero and there are no spinning-top samples. Consequently
the unsolved top's action-0 timer must not be read as the desired
spinning timer 130.

All evaluated held beam actions are `STOMACH_SLIDE`,
`STOMACH_SLIDE_STOP` and `IDLE`. None is `FREEFALL`, `DIVE`,
`GROUND_POUND`, a box bounce or crawling. Some rejected updates begin
crawl after losing the box; they do not meet the beam's transport
condition. This is evidence that the selected airborne controls were
never exercised, rather than evidence against their conditional source
behavior.

The native action log explains the observed release. For example, source
trial 15 steered directly toward the pyramid enters
`STOMACH_SLIDE_STOP` at continuation update 48, at
`(665.1959228515625,38,6206.3896484375)`. It remains there with the box
through the stop animation, changes to `IDLE` at update 86, then executes
`IDLE` and `WALKING` at update 87 and drops the box. The box is inactive
one update later. All ninety route rows have this observed one-update
release-to-deletion interval; it is not a general lifetime theorem.

The source is consistent with this trace:

- `src/game/mario_actions_moving.c:159–281` adds acceleration in the
  floor's downhill direction and applies the sliding loss factor. Full
  forward input on a very slippery floor can make that factor one; it
  does not add ordinary walking acceleration uphill. The stop test
  requires a non-slope floor and squared speed below 16.
- `mario_actions_moving.c:1519–1543` sends the normal stomach slide to its
  stop action. B rollout uses `drop_and_set_mario_action`; it cannot be
  treated as a box-preserving ground escape.
- `src/game/mario_actions_object.c:298–312` makes the ordinary stomach
  slide stop finish its animation toward `IDLE`, with separate stomp,
  off-floor and slide exits. The ordinary idle and walking paths drop a
  held object (`mario_actions_stationary.c:21` and
  `mario_actions_moving.c:777–781`).
- Normal `FREEFALL` really does allow B to `DIVE` and Z to
  `GROUND_POUND` without an explicit drop
  (`mario_actions_airborne.c:525–539`). The prerequisite airborne state
  is missing in these tested transports.

These are source-level control-flow facts and finite runtime
observations. This study adds no Coq theorem about the dynamics or the
set of reachable states.

## Reproduction and limits

The final run, from `SSL-Coq/less-than-one-a-press`, exits 0:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_handsfree_transport.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-clean-handsfree-20261112-final.json build/wafel-pilot/ink-handsfree-transport-20261112-final.json --receipt docs/notes/ink-handsfree-transport-receipt.json
```

Use fresh output filenames on reproduction. The ignored raw report
retains every route sample and input, evaluated beam counts, selected
beam trails, action-entry events, and full input prefixes for selected
fresh replays. The compact receipt retains all route summaries, beam
bounds/counters and complete selected input controls with event snapshots.

Twenty-five selected replay runs, comprising 23 distinct full input
histories, start from fresh native instances and match all **802**
continuation snapshots including their initial boundaries. Their
acquisition prefixes also compare against the prior acquisition samples.
These are exact comparisons of the logged fields, not whole-memory
equivalence proofs. No gameplay edits are introduced for those replays.

The separate read-only audit also exits 0:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/verify_ink_handsfree_transport.py
```

It checks current provenance hashes, the exact receipt projection,
route summaries, duplicate input accounting, beam bounds and counters,
retained no-A records and the stored fresh-replay evidence. It does not
run gameplay again. The final raw SHA-256 is
`ac34dcbced4852d44a7e1b398dad819522d13113702da61322b71aa889dba7c4`;
the experiment script SHA-256 is
`d45e09e3c93cb3ff45494f53f2b82cfa92055c2c84061f704937d566f8c61dab`.

The remaining useful question is how to produce a stronger or differently
placed clean pickup, cross the starting terrain while retaining the box,
or reach an airborne transition that changes the transport possibilities.
This search does not rule out different initial pickups, different actor
interactions, routes discarded by the beam, a controlled release and
reacquisition, or other no-A ascent mechanisms. It establishes neither
delivery onto the pyramid nor a high stopping floor, surviving release,
established crawl, four-pillar timing or the timer-130 handoff.
