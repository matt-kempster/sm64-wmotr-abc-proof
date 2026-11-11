# Clean jumping-box acquisition, transport and release

**The box can be acquired and transported through no-A gameplay. A new clean
branch also releases it alive above the pyramid's western slope. Neither
history delivers a free box beside a high crawler at top timer 130.** The
accepted recording already takes the western box up to the roof, but its
third bounce destroys the box on landing, after the top has exploded. A
different controller branch interrupts the third bounce on the western
Fire Fly Guy: Mario rises to Y=2099.5149, while the dropped box starts at
Y=1259.5149 and falls to its destruction. This branch has only three pillars
activated. It supplies a real elevated release mechanism, not the desired
joint actor/Mario/timing state.

These are native JP Wafel observations and source explanations. There is
no new Coq theorem or original-ROM replication. All trials start from the
accepted controller recording. The only non-controller initialization is
the established pre-entry `gDebugLevelSelect=1` write in `create_game`.
No Mario pose/action, actor XYZ/action, `heldObj`, floor, RNG, timer or
allocator field is supplied. Complete save states support branching;
selected continuations are independently replayed from a fresh instance.

## What was already present in the accepted recording

The full recording has 2852 input rows; the old handoff fixtures replay
only its first 2548 and then wait neutrally. That distinction matters.
The early held box is eastern slot 47, first held after input 375 and
released after input 491. Western slot 49 is still free after input 2548.
Continuing the **actual** recording acquires western slot 49 later.

The table uses completed controller-input counts, with the native
between-update global timer shown separately. The first state of a bounce
argument can precede execution of that stage's launch by one update.

| After input | Native global timer | State |
| --- | --- | --- |
| 2548 | 2549 | Fourth pillar credited; Mario `(-5885.2397,1024,711.0192)`; western box free |
| 2549 | 2550 | Top action 1, stored top timer 0 |
| 2677 | 2678 | Actual B pickup has reached `ACT_PICKING_UP`; held slot 49 at `(-5272.7041,0,1778.5056)`; stored top timer 128 |
| 2679 | 2680 | Stored top timer 130; still picking up at that low western position |
| 2688 | 2689 | `ACT_HOLD_IDLE`, holding box 49 |
| 2689 | 2690 | First bounce, argument 0, Mario Y=45; stored top timer 140 |
| 2700 | 2701 | Top action 2 begins; Mario Y=276, still on first bounce |
| 2713 | 2714 | First recorded argument-1 state, Mario Y=-71.2760 |
| 2743 | 2744 | First recorded argument-2 state, Mario Y=51.7338 |
| 2776 | 2777 | Third landing near roof at `(-2566.1421,1273.0002,-585.2068)`; Mario becomes stomach slide; box 49 inactive |
| 2777 | 2778 | Mario reaches Y=1280; slot 49 has a different behavior |

The capture's B input initiates the normal pickup; no held pointer is
supplied. The earlier [mode-12 record](../../instrumentation/jp-clean-gap-search/README.md#mode-12-clean-four-pillar-and-upper-warp-route)
already describes this roof ascent and later ordinary upper-warp entry.
The new trace identifies the box's ownership and destruction along it.
Reading slot 49 after reuse as if it remained the jumping box would give
a false delivery claim. Likewise, old slot-61 top fields become meaningless
after the top's deletion/reuse; the script checks behavior identity.

## Why ordinary carrying cannot simply stop and drop the box

Both `act_hold_idle` and `act_hold_walking` test for `bhvJumpingBox`
before their ordinary B/Z handling, and immediately enter
`ACT_CRAZY_BOX_BOUNCE`. Its three arguments install vertical speeds
45, 60 and 100 and minimum forward speeds 32, 36 and 48. Its own body
does not test B or Z. Each landing advances the argument until the third,
which sets the box's `INT_STATUS_STOP_RIDING`, clears `heldObj`, and puts
Mario into stomach slide. The jumping-box callback explodes the actor on
that status bit. Air steering uses `update_air_without_turn`; aiming a
new destination after pickup does not instantly redirect the launch.

These are source facts in the sibling decompilation:
`src/game/mario_actions_stationary.c:439–442`,
`src/game/mario_actions_moving.c:875–878`,
`src/game/mario_actions_airborne.c:1033–1093`, and
`src/game/behaviors/jumping_box.inc.c:53–80`.
The source hashes read for this investigation are in the receipt.

A bounded native control starts at a controller-reached argument-2
checkpoint in the new Fly Guy branch. Four 23-update continuations use
the same sticks and respectively no buttons, Z, B, or B+Z held throughout.
All four match the recorded Mario/actor endpoint fields at branch update
303 and still hold the box in the third bounce. This is an observed
button-insensitivity control for that segment, not a proof about every
possible intervening object interaction.

The dive-pickup exception remains separate. Its off-floor/sliding exits
can keep the held pointer while choosing a non-holding action
(`mario_actions_object.c:213–226`). None of these 110 policies sampled
that exception. The receipt's `handsFreeSamples` counts held-box states
outside the explicitly listed normal pickup/dive/hold-idle/bounce actions;
it is a finite screen, not a general held-pointer invariant.

## New uninterrupted Fire Fly Guy release

Start after input 2500 of the accepted route, with three pillars credited.
Use full-stick camera-relative steering to `(-5500,2300)`, switch to the
box center `(-5200,1700)` when within 60 X/Z units of the waypoint, and
press B on every tenth branch update while within 200 units of the box
until pickup. Thereafter steer toward `(-2048,-1024)`. This finite policy
produces the following milestones, without a gameplay edit:

| Branch updates completed | Observation |
| --- | --- |
| 172 | Actual pickup of western box 49 |
| 220 / 246 / 277 | First recorded argument-0 / argument-1 / argument-2 bounce states |
| 303 | Mario `(-3271.9539,1208.8577,-1149.4941)`, third bounce, box held; Fire Fly Guy 45 at `(-3400,1169.5149,-1120)`, live height 90 |
| 304 | Mario becomes `ACT_TWIRLING` at Y=1339.5149; Fly Guy 45 inactive; box free and tangible at `(-3223.6802,1259.5149,-1226.9027)` |
| 321 | Box still alive, Y=647.5149 |
| 322 | Box lands at Y=616.2429 and becomes inactive |
| 323–324 | Mario reaches Y=2099.5149; box already inactive |

The source's twirl-bounce branch calls `bounce_off_object(...,80)` and
`drop_and_set_mario_action(..., ACT_TWIRLING)`
(`interaction.c:1366–1391`). The western Fire Fly Guy is the stock macro
at `(-3400,1160,-1120)` (`levels/ssl/areas/1/macro.inc.c:42`). Its
observed disappearance, the twirling transition and the release height
match that source path. These are after-update observations; the study
does not claim a new internal-call breakpoint trace.

The box's drop update produces free state, action 1, tangibility 0,
and zero forward/vertical speed. Its X/Z then remain fixed in this
continuation as it falls. Native jumping-box action 1 deletes on landing,
wall collision or water flags (`jumping_box.inc.c:31–36,68–71`). The
18-update release-to-deletion interval here is a trajectory measurement,
not a universal box lifetime. It is not a free actor at the target
`(-1989,1741,-939)`: it is over 1200 X/Z units west of that point and about
481.5 units below it. Mario is twirling, not crawling, and the fourth
pillar is still uncredited throughout this branch.

## A clean approach to the stationary top, with the box consumed

A second branch starts after input 2390, uses waypoint `(-5500,2000)`
with the same pickup rule, and then steers toward the pyramid center.
It acquires the box after 256 branch updates and enters bounce arguments
0/1/2 at 268/292/322. At update 354 it lands at
`(-2567.9431,1272.0002,-569.0621)` and the box is deleted. Mario's later
stomach slide contacts the still-stationary top: at update 361 his floor
owner and platform are slot 61, at
`(-2484.1414,1355.0001,-721.1785)`.

This removes an arbitrary-position assumption from **this approach to the
stationary top**. It does not produce the earlier study's seeded roof
state while the top spins, high crawling, or a surviving free box. Only
three pillars are credited. A player cannot be credited with the fourth
pillar merely by waiting on the top.

Both selected 430-update histories were independently replayed from a
fresh accepted boot and their prefixes, matching all 431 retained
snapshots each. These comparisons cover the recorded Mario/actor fields,
not a byte-for-byte comparison of every hidden state field.

## Bounded policy screen and checks

| Family | Exact finite menu | Updates | Result |
| --- | --- | --- | --- |
| After fourth pillar | Prefix 2548; five initial B timings (none,0,8,16,24), four pickup radii (80,120,180,240), three post-pickup targets | 60 trials, 13800 updates | 57 pickups; earliest after 72 updates, stored top timer 71; all 60 see timer 130, no crawl; 12 later low releases |
| Before fourth pillar | Prefixes 2390,2420,2460,2500,2520; five south/west waypoints; then target either pyramid or the fourth detector until credited | 50 trials, 20790 updates | 50 pickups; one elevated free release described above; ten encounter spinning timer 130; no crawl |

The after-fourth acceleration improves the pickup timing relative to the
recorded route's 129 updates. It does not solve the handoff: for example,
the earliest-pickup family is still holding its box at roughly
`(-4616,276,2114)` at stored timer 130. Its approach launches away from the
desired route; air steering does not simply turn Mario around. These
menus do not exhaust acquisition timings, pickup orientations, detector
orders, enemy interactions, hands-free pickup histories or controls.

The final reproducible run completed with exit 0 from
`SSL-Coq/less-than-one-a-press` in PowerShell:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_box_delivery.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-box-delivery-20261111-final.json --receipt docs/notes/ink-box-delivery-final-receipt.json
```

The final receipt was renamed to
[`ink-box-delivery-receipt.json`](ink-box-delivery-receipt.json). Output
creation is exclusive: use fresh names when reproducing. The receipt
records the raw report hash, current script/source hashes, pinned native
DLL and capture hashes, complete selected input histories, sampled
milestones, all 110 policy summaries and button-control endpoints.
The script validates every sampled accepted-prefix field, asserts no A
on every update, and checks the two fresh replays and four button controls.

A read-only reconstruction of the compact receipt from the final raw file
also passes. The shared verification command exited 0 without rerunning
gameplay:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/verify_ink_box_studies.py
```

No new gameplay writes or Coq assumptions were introduced.
The remaining joint obligation is a continuous no-A history that produces
an established high crawl, a separate eligible free actor in contact range,
and the needed top phase before interaction processing. The new release
and stationary-top approach satisfy useful local parts at different
locations and times; they do not establish that joined history or rule it
out.
