# Working backward from the jumping-box Ink handoff

**No clean no-A handoff has been found, but box acquisition, transport and
an elevated live release now have concrete controller histories.** The
accepted recording carries the western jumping box onto the pyramid roof;
it arrives late and destroys the box on landing. A new uninterrupted
no-A branch releases the box alive by bouncing on a Fire Fly Guy. A separate
local pickup experiment obtains much more than the necessary height before
timer 130, but Mario is bouncing rather than crawling. Actual dive pickups
also bypass automatic bouncing after a supplied position cut. Finally, native
release-state tests show that a box dropped lower and a few updates earlier
can still make the useful push. None joins these pieces into one history.

This investigation starts from `dcfab177898ba6caebc6d30ace35d513ddc32aa3`
on `codex/ssl-pyramid-item-proof`, following the
[973-unit producer search](ink-973-producer-search.md). It uses authorized
gameplay experiments and finite state searches in the pinned JP Wafel
runtime. All references to a clean history below mean controller-only
gameplay after the project's accepted pre-entry level-select setup.
The studies preserve complete native save states when branching; they do
not reconstruct a full history by pasting selected coordinates between
search steps. Explicitly supplied local experiments remain separate.

## What is now controller-produced

The [delivery study](ink-box-delivery.md) replays the entire 2852-input
accepted recording. Earlier fixtures used its first 2548 inputs and then
neutral waiting, so they did not include its later western-box pickup.
The full recording picks up western box 49 after input 2677, with the top at
stored timer 128. At stored 130 Mario is still picking up the box on the
ground, far west of the pyramid. The ordinary three-bounce sequence then
takes him to the roof after input 2776, at Y=1273.0002. That third landing
destroys the box; Mario reaches roof Y=1280 next update. The top had already
begun exploding after input 2700. This is a real no-A roof approach, but
neither a timely delivery nor a surviving free push actor.

In a new clean branch starting after input 2500, Mario approaches the box
from the southwest, picks it up and aims toward the pyramid. On the third
bounce he contacts the stock western Fire Fly Guy. The interaction changes
Mario to twirling and drops the box alive:

| Branch updates completed | Mario / actor observation |
| --- | --- |
| 303 | Third box bounce at `(-3271.9539,1208.8577,-1149.4941)`; box held |
| 304 | Twirling Mario at Y=1339.5149; free box at `(-3223.6802,1259.5149,-1226.9027)`; Fly Guy inactive |
| 321 | Box still alive at Y=647.5149 |
| 322 | Box lands at Y=616.2429 and is deleted |
| 323–324 | Mario peaks at Y=2099.5149; box already gone |

The release happens before the twirl supplies its later altitude. Mario's
Y=2099 peak therefore does not mean that the box was carried or released at
that height. The drop is over 1200 horizontal units west of the required
actor position and roughly 481.5 units below its original Y=1741 setup.
Only three pillars are credited; the top is not spinning. The actual
interaction is with the Fire Fly Guy, not a tornado. These are observed
action/actor changes supported by the source's twirl-bounce/drop path, not
a new internal-call trace (`src/game/interaction.c:1366–1391` in the sibling
decompilation).

A second clean branch, starting after input 2390, consumes the box on the
roof and subsequently contacts the stationary top at
`(-2484.1414,1355.0001,-721.1785)`. It too has only three credited pillars.
Both selected 430-update branches replay from a fresh instance with all 431
recorded snapshots matching. Equality refers to the recorded fields, not
every hidden native byte.

The finite clean screen tries60 policies after the fourth pillar and 50
before it: **110 trials, 34,590 updates**. There are107 pickups; the earliest
after-fourth pickup occurs at stored timer 71, improving on the recording's
128. None of these policies produces crawling. Four23-update controls on
the clean third-bounce segment give identical recorded endpoints with no
buttons, B, Z or B+Z. This is bounded evidence for that segment, not a
claim that no external interaction can interrupt the bounce.

## Height is available locally; the action and surviving actor are not

The [local pickup study](ink-box-crawl-predecessors.md) supplies only
Mario's synchronized roof position and the existing box's position.
Actual B input performs the pickup; no action, held-object pointer,
velocity, floor cache or allocator field is set. Across 168 policies and
29,677 updates,156 trials enter the native box bounce. A fresh-replayed
witness reaches **Y=2883.660889 at stored timer 124**, before the handoff.
At stored 130 it is still holding the box in the airborne bounce action,
at `(-1293.102905,2823.660889,-979.853760)`.

Another local witness third-lands on the top at stored 130 and Y=1677.9685.
It becomes stomach slide and destroys the box. The sole eventual crawl in
the screen follows a squish interruption: Mario is lowered to the static
roof, becomes idle, and finally establishes crawl at stored 136 and Y=1280.
It is too low and late, with the box already inactive. Four selected
180-update histories replay from fresh instances with all 720 recorded
snapshots matching. These initial roof/box positions are supplied, so the
experiment is a local predecessor, not a clean route to them.

The source explains the ordinary coupling. `act_hold_idle` and
`act_hold_walking` check for the jumping box before ordinary B/Z cancels
(`mario_actions_stationary.c:439–442`, `mario_actions_moving.c:875–878`).
They start `ACT_CRAZY_BOX_BOUNCE`, whose three stages launch with vertical
speeds 45,60,100 and minimum forward speeds 32,36,48. The third landing sets
`INT_STATUS_STOP_RIDING`, clears the held pointer, and enters stomach slide;
the box then explodes (`mario_actions_airborne.c:1033–1093`,
`behaviors/jumping_box.inc.c:53–80`). Simply pressing Z in ordinary hold-idle
does not bypass that first jumping-box guard.

Hands-free holding is a distinct source path: `act_dive_picking_up` can
leave for freefall or sliding without dropping the held pointer when it
is more than 100 units above its floor or is above a slippery floor (`mario_actions_object.c:213–226`).
Generic action dispatch does not turn that automatically back into a hold
action. However, ordinary idle and walking drop any held object before
their usual input handling (`mario_actions_stationary.c:21`,
`mario_actions_moving.c:782`). This provides a different release mechanism,
not a proven high crawl with a conveniently parked box.

## The hands-free exception works locally, but the continuation loses height

A [focused hands-free study](ink-box-handsfree.md) exercises the actual
exception. Six ordinary controller inputs first produce a dive. At that
one declared cut, it supplies only Mario's synchronized XYZ near a roof
edge and the box's XYZ, retaining native action, velocity, facing, cache
and object references. The initial Mario heights 1400,1600,1741 are supplied;
this does not derive height from gameplay.

All 18 focused cases perform a real dive pickup and then execute
`DIVE_PICKING_UP` followed by hands-free butt slide with box 49 still held.
They avoid `CRAZY_BOX_BOUNCE` and retain the held box for 70–79 updates.
In a supplied-Y=1741 example, pickup occurs at stored 7, landing enters
`DIVE_PICKING_UP` at 24, and the hands-free slide starts at 25 at Y=1391.0002.
Mario leaves the roof at 45 and loses the held box on quicksand death at 86;
the box is inactive at 87. No case reaches crawl. These runs exercise the
slippery-floor exit; the separate off-floor source exit is not established
by their logs.

Two complete 146-update histories, including the six pre-cut inputs and
140 post-cut updates, replay from fresh instances with all 292 recorded
snapshots matching. Earlier runway probes failed to pick up the box and
therefore did not exercise or refute the exception. The focused result
shows that ordinary three-bounce destruction is avoidable in this local
supplied context. It does not show a clean roof-edge approach, high crawl,
useful release position or successful handoff. These 18 continuations also
do not exhaust possible steering and action transitions after hands-free
pickup.

## A lower, earlier release can supply the pushing actor conditionally

The new `ink_box_release_handoff.py` tests **672 release-state cuts plus
two free-box controls**. It has two explicit contexts: Mario remains at
the distant ordinary prefix position, or his initial position is supplied
on the nearby roof at `(-2559,1280,-1535)`. In each, the release menu uses
seven stored phases `[110,118,122,126,128,129,130]`, eight initial heights
`[1500,1600,1625,1650,1700,1741,1800,1900]`, a drop at
`X/Z=(-1989,-939)`, or five eastward-throw X offsets. Every box setup write
is recorded, including held state, action, tangibility and direction.
This cut is after a hypothetical Mario release; it does not execute or
derive that release from a real held-object history.

The script separately supplies `ACT_CRAWLING` at Mario's ordinary location
before timer 129 and executes one native Z/stick update. This produces the
real **100-unit crawl hitbox**. At timer 130 it supplies only Mario's high
M=C=D position. It does not alter the box again, patch the floor cache,
or set a platform reference. These cuts deliberately test actor survival
and contact while leaving Mario reachability open.

The most informative nearby case supplies a drop at
`(-1989,1650,-939)` before behavior126:

| Stored timer after update | Box Y | Box vertical speed |
| --- | --- | --- |
| 127 | 1650 | 0 |
| 128 | 1646 | −4 |
| 129 | 1638 | −8 |
| 130 | 1626 | −12 |

At the timer 130 collision pass the box's upper extent is exactly
`1626 + 125 − 10 = 1741`, meeting Mario's feet. Inclusive vertical contact
still allows the push. The update produces the exact 973 split, the next
captures the top, and Area2 arrival is outside the elevator. After the push
the box falls to 1610. The same nearby Y=1650 release before 118 falls to 1386
by130 and fails. These are tested timings for this menu, not a universal
four-frame lifetime bound.

The far-prefix counterpart stays at 1650 because `ACTIVE_FLAG_FAR_AWAY`
suppresses its standard movement while other behavior still runs
(`object_helpers.c:1787–1834`). Its later contact after the high-Mario cut
does not prove Mario can travel away and return on time. Far and nearby
successes must not be pooled into a claim about ordinary gravity.

Release height matters for another reason. The helper queries a floor at
boxY+160 and raises the box to a higher returned floor
(`object_helpers.c:1066–1084`). A supplied drop at Y=1741 before 129 is lifted
to Y=1947.234009; at 130 it is too high to contact the crawler. A release cut
at 130 itself remains intangible during that update's collision pass and
only later becomes tangible, lifted to Y=1932.726440. All 96 phase130
release cuts fail. Collision detection precedes Mario/box behavior, so a
new release cannot be treated as an already-free actor for the earlier
pass (`object_list_processor.c:658`, `object_collision.c:113–120`,
`jumping_box.inc.c:64–71`, `object_helpers.c:1087–1114`).

Across the menu,18 release cases and both tangible free controls capture
the top and reach the sampled useful Area2 point
`(365.5927734375,5500,-1096.8026123046875)`. The seven nearby release successes
are stronger actor-motion examples than the eleven far ones, but **none
is a joint controller history**. A real drop would require Mario at the
release Y with the actual previous rendered HOLP X/Z at the chosen actor
position (`interaction.c:295–313`). The experiment supplies those actor
fields independently and later supplies high Mario. It does not connect
Mario at Y=1650 before 126 to the high crawl at 1741 before 130.

## Validation and exact boundary

The successful free-box controls show the original1741 fixture still
works with a native100-unit hitbox. Earlier action-only supplied fixtures
inherited the normal160-unit hitbox for their first collision pass. This
distinction changes some marginal high-box successes, not the original
same-height result. The new preparation also changes crawl velocity; the
earlier finite Coq quarter-query certificate must not be attributed to
these exact new runtime queries. No new floor-query hook or whole-update
Coq execution is claimed.

The two complete release-menu runs have byte-identical JSON, SHA-256
`5221ad76f6c5f448f0679950ed198653715df34fb84eb2926897ebed8e8291ab`.
They contain 4512 actor-predecessor updates per run and 674 conditional
handoff attempts. Native script and raw-report assertions pass. The
[release receipt](ink-box-release-handoff-receipt.json) records all result
rows, complete selected ledgers/trajectories and both raw hashes.
Exact release commands, from `SSL-Coq/less-than-one-a-press`, exit 0:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_box_release_handoff.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-box-release-handoff-final-20261111.json
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_box_release_handoff.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-box-release-handoff-final-replay-20261111.json
```

The [delivery note](ink-box-delivery.md#bounded-policy-screen-and-checks),
[local pickup note](ink-box-crawl-predecessors.md#reproduction-and-limits),
and [hands-free note](ink-box-handsfree.md) give their exact successful
commands and menu definitions. Each refuses
to overwrite existing raw outputs; choose fresh names when reproducing.
All use runtime SHA-256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`
and accepted-capture SHA-256
`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.
Fresh replay comparisons validate recorded boundaries, not every hidden
field. Every gameplay sequence uses no A; all supplied-state cuts remain
listed separately from controller inputs.

The reproducible read-only receipt audit also exits 0:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/verify_ink_box_studies.py
```

It checks script syntax and hashes, runtime/capture provenance, compact
receipt correspondence, trial counts, recorded replay comparisons and
setup-write scopes, with no gameplay rerun. The optional
`--write-release-receipt` mode generates the deterministic compact release
receipt from the two matching raw files; the default only verifies it.

No Coq source, premise, generated target or allocator theorem changes in
this follow-up. The previous selected audit remains historical evidence
for its conditional stop, not a proof of these new histories. No new
original-ROM replication was run. Changed actor lifetimes do not inherit
the older timer 131 allocation counts.

The open obligation is now specific: a controller history must deliver a
free, tangible box to the contact region and put Mario into the high crawl
with the right current-update floor cache before the same timer 130
interaction pass. Clean pickup/transport, a clean elevated release,
locally sufficient timely height, hands-free pickup after a position cut,
and a conditional late lower release
are each established separately. Their composition remains open, as do
unsearched inputs and other histories. All 45 atlas estimates are unchanged,
including Rank1 **1–2%** and Ink Rank2 **<1%**.
