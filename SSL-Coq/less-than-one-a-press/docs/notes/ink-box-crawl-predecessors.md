# From a real jumping-box pickup toward the high crawl

This follow-up starts at `dcfab177898ba6caebc6d30ace35d513ddc32aa3` and
builds on the [earlier crawl predecessor study](ink-crawl-predecessors.md).
It uses the pinned native JP Wafel runtime and authorized gameplay searches.
It adds no Coq theorem or original-ROM replication.

**A real no-A jumping-box bounce can provide more than enough height before
timer 130, from a supplied roof pickup. The tested histories do not convert
that height into the required high crawling state.** A locally supplied
Mario position and box position suffice to make the game perform the
pickup, establish the held-object reference, and run its three-stage
bounce. No action or held-state patch is needed. In a fresh-replayed
witness Mario reaches Y=2883.660889 while holding the box before the
required update. He is airborne in `ACT_CRAZY_BOX_BOUNCE`, far from the
required high pad. The ordinary third landing changes him to stomach slide
and destroys that box; it does not simultaneously produce crawl and a free
push actor.

## Source-supported route and obstruction

`act_hold_walking` checks for a held `bhvJumpingBox` before its ordinary
walking exits and enters `ACT_CRAZY_BOX_BOUNCE` without an A input
(`reference-sm64-decomp/src/game/mario_actions_moving.c:875–878`). In
`src/game/mario_actions_airborne.c:1033–1096`, the bounce stages set vertical
velocity to 45, 60 and 100, with minimum forward speeds 32, 36 and 48.
The action uses ordinary air movement and contains no direct B/Z exit.
Its first two landings advance the stage. Its third landing sets the held
object's `INT_STATUS_STOP_RIDING`, clears `heldObj` and enters
`ACT_STOMACH_SLIDE`.

The box behavior then explodes on that interaction bit
(`src/game/behaviors/jumping_box.inc.c:58–88`). This describes the ordinary
third-landing path, not every possible interruption or clone history.
The actual object is held: the native `heldObj` points to slot 49 and
`riddenObj` remains null in these witnesses.

The landing action matters. `stomach_slide_action` permits the ordinary
B rollout only when `INPUT_ABOVE_SLIDE` is absent; its stop action also
cancels back to sliding on that input (`mario_actions_moving.c:1520–1544`,
`mario_actions_object.c:298–315`). Thus landing on the top's slippery side
is not an automatic transition to crawl. The established-crawl exception
used by the 973-unit handoff does not apply to a newly landed stomach slide.
The earlier study explains the separate crouch/start-crawl slide guards.

## What was supplied and what the controller produced

Each trial restores a complete native state obtained from the existing
2,548-input no-A four-pillar prefix, followed by neutral inputs. It supplies
exactly these positions:

- Mario M=C=D: `(-2559,1280,-1535)`.
- Existing western jumping box, slot 49: `(-2559,1280,-1535+d)`, with
  `d` equal to 70, 95 or 110.

All initial writes, including previous values, are recorded. Mario's
action, velocity, facing, floor cache and platform reference remain those
of the prefix. The box retains its native action, held state, velocity and
hitbox. No held/ridden pointer, RNG, allocator or surface is edited.
Mario's and the box's approach to those supplied positions is not a clean
controller-produced route.

The menu has seven initial stored top timers
`[0,16,32,48,64,80,96]`, three box distances, two B times (zero-based input
0 or 4), and four policies: 168 trials. For the first eight inputs the
stick aims toward `(-2559,-1425)`; afterward it aims toward the top center,
the high pad, or the initial roof corner. After the held box is lost,
Z is held. The fourth policy aims at the center but holds the stick neutral
for the first 16 updates after release before continuing Z and steering.
The horizon is 180 updates, with early exit on leaving Area 1 or losing
the area/camera. No intermediate gameplay write is made.

There are 29,677 trial updates: 156 actual pickups and bounce entries, one
eventual crawl, and no crawling sample at Y at least 1741. Three trials
enter Area 2 at the ordinary elevator arrival `(0,5500,256)`. The only
crawl occurs at Y=1280. These are finite policy results, not an exclusion
of other inputs, roof positions, early prefixes or actor interactions.

## Four continuous witnesses

All four selected histories were independently rebuilt from a fresh game
instance, the accepted prefix and their initial position patches. Each
replayed 180 controller updates with all 180 recorded snapshots matching;
there were no intermediate patches. Snapshot equality concerns the listed
fields, not every hidden native-state field.

| Witness | Initial stored timer / distance / B input / policy | Observed result |
| --- | --- | --- |
| Height before the handoff | 64 / 110 / 0 / center | Y=2883.660889 at stored 124; still holding box 49 in bounce stage 2 |
| Highest Area-1 height | 96 / 70 / 4 / roof corner | Y=3089.280273 after the top has exploded; this later maximum is not a timely payoff |
| Third landing on the top before the handoff | 64 / 110 / 0 / roof corner | Stored 130: stomach slide at `(-1680.155884,1677.968506,-758.733887)`, held pointer cleared and box inactive |
| Eventual crawl after an interrupted bounce | 80 / 110 / 4 / brake after release | Squished at stored 112, idle at 115, starts crawling at 129, established crawl at 136 on the Y=1280 roof |

The first witness is still in bounce stage 2 at stored 130, at
`(-1293.102905,2823.660889,-979.853760)`, with box 49 held. Its later third
landing at stored 150 puts Mario on the top at Y=1709.397949, changes him
to stomach slide and destroys the box. The third witness makes that same
action/lifetime change earlier, at stored 130, but still does not give
either the high-pad coordinates or crawling.

The fourth witness is interrupted in bounce stage 0. It reaches Y=1550
at stored 111; the next update enters `ACT_SQUISHED` and drops Mario to
the static Y=1280 roof. The box becomes inactive by stored 115. Subsequent
Z and stick inputs establish crawling at stored 136, still at Y=1280.
This is an actual controller-produced conversion after a supplied local
pickup, but its height, timing and surviving actor do not satisfy the
973-unit handoff.

Stored timer means the value between updates: stored 130 is before the
update executing behavior timer 130. The script identifies that boundary
by global timer 2680 and checks that slot 61 still contains the spinning
pyramid top. The height-before-handoff metric uses the same global cutoff;
it does not infer timing from a freed or reused slot's later `oTimer`.
All heights and positions are sampled update boundaries. A cached
`floorOwner=61` during flight does not by itself mean Mario stands on the
top; the landing examples additionally have the relevant action transition
and movement at the sampled floor height.

## Reproduction and limits

From `SSL-Coq/less-than-one-a-press`, this command exited 0:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_box_crawl_predecessors.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-box-crawl-predecessors-20261112-checked.json
```

Choose a fresh output name when rerunning; the script refuses to overwrite
an existing raw report. The [receipt](ink-box-crawl-predecessors-receipt.json)
preserves all 168 trial summaries and patch ledgers, selected full input
histories, action transitions, key snapshots and replay results. The raw
report contains all compared witness snapshots. Its SHA-256 is
`7b4396d4314376e3795e90657f0d4a7b658bf99baf8f8ffd8c82a59c9a868675`;
the script SHA-256 is
`6d7ab5a5165eccb41c019e09fe5d5065deb28b7cb79c8e5b446ed24b7fa54c6c`.
Runtime/capture hashes remain those of the preceding study. Preliminary
pilot/report versions are superseded by this checked report; in particular,
the Area-2 spawn height 5500 is excluded from the Area-1 bounce-height metric.

The remaining obligation is not merely obtaining height. It is a continuous
history that produces the appropriate high crawling action, current-update
low-floor cache, location and timing while an eligible free actor survives
beside Mario. This study supplies the initial roof pickup positions and
tests ordinary bounce/landing continuations. It does not cover hands-free
holding, a different object interruption, clones or all controller inputs,
and it does not prove that any of those alternatives works or is impossible.
