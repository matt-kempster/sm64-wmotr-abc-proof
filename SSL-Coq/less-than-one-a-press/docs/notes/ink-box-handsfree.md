# A real dive pickup can bypass the automatic box bounce

**The hands-free holding exception occurs in a no-A local continuation.
It still does not produce the high crawling handoff.** Five ordinary
walking inputs and one B input create a real dive from the accepted
four-pillar prefix. At one explicitly supplied position cut, Mario and the
existing jumping box are moved near the roof. The game then performs the
pickup and changes from dive-picking-up to butt slide while keeping the
box held. Eighteen tested variants take that path; none enters the crazy
box bounce or crawling. They slide away and ultimately lose the box during
quicksand death.

The supplied Mario heights include 1741. This is evidence that the action
exception can be exercised without directly writing an action or held
pointer, **not** a controller-produced approach to that height or roof.
The study starts from `dcfab177898ba6caebc6d30ace35d513ddc32aa3`, uses the
pinned native JP Wafel build, and adds neither a Coq theorem nor an
original-ROM replication.

## The relevant source path

`act_dive` calls `mario_check_object_grab` and `mario_grab_used_object`.
Landing while holding an object enters `ACT_DIVE_PICKING_UP`
(`reference-sm64-decomp/src/game/mario_actions_airborne.c:724–775`).
Unlike ordinary picking up, `act_dive_picking_up` changes to freefall on
`INPUT_OFF_FLOOR` or begins sliding on `INPUT_ABOVE_SLIDE` without dropping
the held object (`src/game/mario_actions_object.c:215–235`). These are two
source branches; the new experiments exercise the **slide** branch.

The native frame logs show `ACT_DIVE_PICKING_UP` followed by
`ACT_BUTT_SLIDE`, with `heldObj` still pointing to box 49 and the box's
held state equal to `HELD_HELD`. The action setter chooses the concrete
slide action from `ACT_BEGIN_SLIDING` (`src/game/mario.c:918–924`).
`riddenObj` remains null. This is hands-free holding, not shell-style
riding and not an injected ownership relationship.

Both `act_hold_idle` and `act_hold_walking` have a jumping-box guard before
their ordinary input cancellation logic (`mario_actions_stationary.c:439–455`,
`mario_actions_moving.c:875–878`). Therefore the generic hold-idle Z-drop
rule cannot be used to avoid this box's automatic bounce. Avoiding those
holding actions through the dive-pickup exception is a materially different
path. Ordinary IDLE/WALKING also drop a hands-free held object before
processing their normal movement behavior; retaining the box while
converting into useful crawl remains a separate obligation.

## Controller-produced dive and the position cut

The accepted 2,548-input prefix is replayed and neutral inputs reach the
top's stored timer 0. Mario's native forward speed is 27.50953865. Five
ordinary stick inputs toward +Z, at magnitude 127, produce speeds
27.96978188, 28.41932106, 28.85840607, 29.28728104 and 29.70618057.
The sixth input adds B and naturally enters `ACT_DIVE`, with forward
speed 44.85615540. No gameplay field has been written apart from controller
input up to that point.

At stored timer 6, each focused trial writes exactly eight position fields:
Mario M/C/D become `(-2559,h,-1535)`, and existing box 49 becomes
`(-2559,h+dy,-1535+d)`. Here `h` is 1400, 1600 or 1741; `d` is 70, 110 or
150; and `dy` is 0 or −60. The native dive action, speed, velocity, facing,
held/ridden references, box action/held state, floor cache, platform, RNG
and allocator are retained. The complete before/after patch ledgers are
in the receipt.

Each of these 18 trials then holds Z and steers toward `(-2047,-1023)` at
stick magnitude 64 for 140 updates. No intermediate non-controller write
is made. All 18 perform a real pickup and take the hands-free slide exit.
They keep the box for 70–79 sampled updates, never execute
`ACT_CRAZY_BOX_BOUNCE`, and never enter crawling. These 2,520 post-cut
updates are a finite continuation menu, not an exclusion of other steering,
interruptions, roof approaches or action histories.

Two complete histories, for `h=1400` and `h=1741` with `d=70,dy=0`, were
independently rebuilt from a fresh game instance. Each matched all six
pre-cut and all 140 post-cut snapshots: 292 comparisons in total. This
checks the recorded snapshot fields, not every hidden state field.

## What happens to the height and box

For the supplied `h=1741,d=70,dy=0` witness:

| Stored timer | Action and observation |
| --- | --- |
| 7 | Real dive pickup; box 49 held; Mario at `(-2554.875977,1757,-1490.580566)` |
| 24 | Lands into `ACT_DIVE_PICKING_UP` at Y=1435.999878 |
| 25 | Hands-free `ACT_BUTT_SLIDE` at Y=1391.000244; box still held |
| 45 | Leaves the roof in `ACT_BUTT_SLIDE_AIR`, still holding the box |
| 86 | Enters quicksand death near `(-4149.685059,-241.483582,-322.248077)` and loses the held reference |
| 87 | The box is inactive at the sampled boundary |
| 130 | Mario is still in quicksand death, far from the high handoff |

For `h=1400`, the corresponding slide exit occurs at stored 17 and
Y=1336.000244; quicksand death releases the box at stored 78. These
continuations avoid the three-bounce destruction path but do not preserve
the required position, height, action or useful actor lifetime. Positions
and heights are update-boundary observations. Stored timer 130 means the
boundary before the update executing top behavior timer 130.

## Failed approach screens and coverage

The earlier runway menu tested 288 position-only roof setups: two Mario
seeds, four top phases, two runway directions, three box distances, three
B timings and two Z policies, for 42,966 updates. It produced 32 actual
dives but **no pickup**. The corner runway slid off before the delayed B
input; the inset runway encountered slippery top geometry. These trials
did not execute the hands-free exception and provide no negative result
about that exception.

Two small exploratory controls also failed their prerequisites: 24
north-strip approaches had no dive pickup, and an 18-case position menu
after a slower pillar run-up retained `ACT_MOVE_PUNCHING`, not DIVE.
Their raw-report hashes, exact menus and setup-write ledgers are retained
in the receipt. The successful focused menu above fixes that problem by
first verifying a real controller-produced DIVE. No action patch was used
to repair a failed approach.

## Reproduction and remaining obligation

From `SSL-Coq/less-than-one-a-press`, this command exited 0:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_box_handsfree.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-box-handsfree-20261112-checked.json
```

It reproduces the 288-case runway screen and 18-case focused menu, including
the two fresh replays. Output creation is exclusive; use a fresh output
name when rerunning. The [receipt](ink-box-handsfree-receipt.json) records
the exact setup cuts, inputs, observations and scope. The checked raw-report
SHA-256 is
`96653c1a2d956fb46c3ccdc8ec01a8fc9c39511569a0caf8c8f25dbfb5269ed2`;
the script SHA-256 is
`990d7ea35b2a7efa7b2a9bf6c9086c4036912eb322c156a903b99c027cf9fffa`.
The runtime and input-capture hashes are unchanged from the preceding box
and crawl studies. The imported snapshot helper has its own recorded hash.

The new evidence establishes a useful local alternative to automatic box
bouncing. It does not connect that alternative to an unpatched high
approach, a high established crawl, a release near the required timer,
or the successful 973-unit push. Those connections remain open.
