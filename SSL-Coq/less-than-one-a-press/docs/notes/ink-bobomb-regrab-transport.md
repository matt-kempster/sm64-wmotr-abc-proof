# Clean expired-Bob-omb regrabs and bounded transport

A continuous no-A history can repeatedly recover the real eastern Bob-omb
after its fuse expires and use its enlarged, still-tangible held body to
move Mario. The strongest preserved approach makes twenty regrabs after
the original pickup, eighteen of them in the final steering suffix. It
reaches approximately `(6909.080,-49.756,-738.317)` while holding original
actor 39 at fuse 472. It then enters quicksand. The east teleporter remains
about 4,132.74 X/Z units away; this is clean actor transport, not clean
hands-free teleportation or delivery to the pyramid.

The native held size during this transport is approximately **1.4**, with
hitbox radius **91** and height **158.2**. The later **1.8** size belongs
to the released Bob-omb's terminal explosion growth and must not be used
as the size of the transported held actor. Across the finite study the
largest fuse while actually held is **475**; the largest fuse in any
recorded state is **483**. Neither number is a general lifetime bound.

The experiment is
[`ink_bobomb_regrab_transport.py`](../../instrumentation/wafel-jp-pilot/ink_bobomb_regrab_transport.py),
with a [receipt](ink-bobomb-regrab-transport-receipt.json), a
[938-input continuous witness](../../instrumentation/wafel-jp-pilot/ink-bobomb-regrab-transport-inputs.jsonl),
and a [read-only verifier](../../instrumentation/wafel-jp-pilot/verify_ink_bobomb_regrab_transport.py).

## What is clean and what was searched

The starting helper is `clean_bobomb_idle_seed` in
[`ink_handsfree_teleport.py`](../../instrumentation/wafel-jp-pilot/ink_handsfree_teleport.py).
It replays the accepted first 350 controller inputs, then acquires stock
Bob-omb 39 through 197 actual controller updates. Its final state has
ordinary `IDLE`, Mario's held reference still pointing to 39, fuse 89,
and Mario near `(3895.153,0,6085.180)`. The sole non-controller setup is
the accepted pre-entry level-select flag. There are no gameplay position,
action, timer, held-reference, actor, velocity or RNG writes.

The new study also reconstructs earlier points on that same controller
history, after acquisition updates 115, 130 and 150. Update 115 is the
actual hands-free stomach-slide exit, already holding the Bob-omb at
fuse 7. These earlier starts are replayed from entry and compared to the
helper's recorded snapshots. They are not position cuts or transplanted
states. Whole-state restores only branch from these native histories.

The first family has **200 policy rows, 118 distinct seeded controller
histories, and 21,049 branch updates**. Fifty-six policies start at the
late idle boundary; the other 144 start at the three earlier sliding
boundaries. They vary B-pulse period/phase, aiming at the actor or ahead
of it, stationary versus moving pickup, destination steering, and an
optional controlled B rollout at continuation input 1, 9 or 17. The
earlier family also tests changing the destination after its first regrab.
The horizon is 500 inputs, but every branch ends earlier on loss of the
original live actor. A slot number alone does not count as survival:
behavior and active state are checked on each update.

The late idle boundary exposes a real nearby obstruction. Fly Guy 38
hits Mario during the tested regrab animations. In one trace, Mario
recovers actor 39 at suffix update 6, then at update 17 has
`interactObj=38`, hurt counter 7 and `FORWARD_GROUND_KB`, dropping the
Bob-omb at fuse 106. This predates fuse expiry. It would be wrong to
describe that failure as an expired-fuse transport limit.

Starting earlier makes useful progress. The selected base policy starts
at acquisition update 115, steers toward `(5000,6000)`, and presses B at
suffix update 9. This deliberately drops the Bob-omb and starts forward
rollout; the actor's subsequent pursuit, other native interactions and
Mario's return are all left active. Mario regrabs it at suffix update
132, fuse 139, near `(4588.903,34.028,4510.954)`. He regrabs it again at
suffix update 151, fuse 158, now enlarged to approximately 1.4. This
second boundary follows **616 completed controller inputs** from entry.

The second family begins at exactly that native enlarged regrab. It has
**56 policies, 45 distinct controller suffixes, and 12,164 branch
updates**, with an 800-input horizon. Twenty-four policies try six
waypoint routes with two B periods and two phases. Thirty-two policies
steer the held body away from a desired travel bearing of 20, 25, 30 or
35 degrees east of north, then aim toward the teleporter after passing
X=6500 or 6800. Their per-update facing adjustment is capped at 512,
1024, 2048 or 4096 angle units. While the object is free, Mario aims at
the actual actor to recover it. No policy reaches its full horizon;
the longest retained recovery suffix lasts 325 updates before actor loss.

These update counts exclude setup replays, selected fresh replays and
earlier exploratory runs. The exact finite menus, realized controls,
actor fields, action-entry logs and outcomes are retained. They do not
cover every steering pattern, other acquisition histories or other routes.

## Why the repeated recovery and movement work here

The source explicitly separates an expired fuse from immediate execution
of the explosion:

- `src/game/behaviors/bobomb.inc.c:182–194` places the held actor 100 units
  ahead and 60 units above Mario's object, sets the Mario drop-status bit
  after fuse 150, and selects the explode action. Its held-state branch
  delays execution of the free explosion behavior. The source comment
  identifies repeated regrabbing as possible.
- The drop handler resets the actor to free patrol
  (`bobomb.inc.c:196–205`). The free loop selects explosion again when
  the fuse remains expired (`bobomb.inc.c:105–143`); the explosion grows
  through its early timer values before deletion (`bobomb.inc.c:30–43`).
  This creates a finite recovery window in the observed cycles.
- Normal hold idle and hold walking handle the actual
  `INT_STATUS_MARIO_DROP_OBJECT` flag
  (`mario_actions_stationary.c:438–450`,
  `mario_actions_moving.c:876–884`). The final controller presses B at
  that flag, rather than guessing from the displayed fuse. Pressing B
  a frame too early can choose throwing instead.
- Ordinary pickup runs its animation and stationary ground step
  (`mario_actions_object.c:175–210`). In the successful cycles the
  Bob-omb is already held and tangible while that animation is running.

At the captured enlarged boundary, native hitbox values are radius 91
and height 158.2, consistent with the actor's scale and its original
65-by-113 hitbox (`bobomb.inc.c:3–13`, `object_helpers.c:2120–2137`).
The ordinary grabbable fallback uses push padding −5
(`interaction.c:1636–1666`). With Mario's radius 37, its horizontal
separation is 123, exceeding the held actor's nominal 100-unit forward
placement. Recorded pickup updates move Mario roughly 23 units backward
while his velocity fields can remain zero. The held actor is then placed
relative to the new Mario position. Steering away from the desired
travel direction makes this repeated push useful.

This explanation combines source control flow, an arithmetic separation
calculation and native observations. It is not a Coq theorem about every
collision/update, nor a claim that arbitrary scales or directions remain
stable. The relevant actual hitbox, action, fuse, scale and collision
positions are preserved in the witness snapshots.

## The preserved witness and its exact boundary

The nearest approach uses the 35-degree policy, switches toward the
teleporter after X=6500, and caps turns at 4096 angle units. Its final
suffix has eighteen actual held-reference recoveries, all with expired
fuses. Added to the two recoveries before the 616-input boundary, the
complete history has twenty regrabs after its original dive pickup.

The canonical witness contains **938 inputs**. Its first 616 inputs
produce the enlarged actor natively; the remaining 322 reproduce the
steering attempt and its failure. At completed input 930, Mario still
holds actor 39 at approximately `(6909.080,-49.756,-738.317)`, fuse 472.
At input 931, he enters quicksand death and loses the held reference.
At input 938, the original Bob-omb is inactive. The Wafel after-advance
global timer is one greater than these completed-input counts.

The failure is also visible in floor data. The native floor type changes
from 19 to 45 at the death transition, while quicksand depth begins
increasing. The source collision mesh's moving-quicksand triangle at
`levels/ssl/areas/1/collision.inc.c:1076` uses vertices
`(7168,-255,-1535)`, `(5120,-50,-716)` and `(7578,-50,-716)`, covering the
observed entry near `(6909,-773)` in X/Z. The farther-north triangle at
line 802 is instant quicksand and covers, for example, `(7000,-2000)`.
These are concrete source geometry facts about this approach. They do
not exclude an airborne crossing, a different terrain route or another
actor-assisted crossing.

Every sampled pillar count is zero and the top remains in its untriggered
action. The highest held Mario Y anywhere in the study is approximately
251.33. Thus the source top's increasing action-0 timer is unrelated to
the required spinning timer 130. No tested history delivers a live free
actor next to high crawling Mario.

Repeated regrab uses ordinary `PICKING_UP`/`HOLD_IDLE`, not the original
hands-free slide/idle disagreement. Even successful delivery to the
teleporter would still require checking a new hands-free conversion and
the correct idle/update timing. The study establishes no clean HFT,
orphan creation, upper-floor installation or complete no-A route.

## Checks and reproduction

From `SSL-Coq/less-than-one-a-press`, the final native experiment exits 0:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_bobomb_regrab_transport.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-bobomb-regrab-transport-20261112-final.json --receipt docs/notes/ink-bobomb-regrab-transport-receipt.json
```

Use fresh output names. The ignored raw report includes all branch
inputs/snapshots; the receipt retains every trial summary and complete
selected controller histories with event snapshots. For a selected row,
concatenate `fullControllerPrefix` and `inputs` to obtain the continuous
history. `recovery-nearest` is the canonical 938-input witness.

Five selected fresh replay runs, representing three distinct complete
histories, compare **1,927 continuation snapshots** including their
initial boundaries. Each also replays and compares its acquisition
prefix. These comparisons concern the recorded projection, not every
byte of native memory. The shared advancement helper asserts no A in
every input and no A-pressed/down flag after every update. Validation here
uses the pinned Wafel JP DLL. Original-ROM playback of this 938-input
history remains unchecked.

The standalone read-only audit also exits 0:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/verify_ink_bobomb_regrab_transport.py
```

It verifies current hashes, receipt projection, branch summaries,
duplicate-history accounting, starting controls, finite horizons,
retained no-A data, canonical witness bytes and stored fresh-replay
evidence. It does not run gameplay. An independent second-agent audit
also checked the final hashes/counts and the distinction between held
scale 1.4 and transient free scale 1.8.

The final raw SHA-256 is
`84a9f4c417353a04f4778b2f49c13d51416fae1de69691f3e04b6b7b99fe5073`;
the experiment script SHA-256 is
`c0a6ed97e15276555ead9f36ad1ce76dd51e8ba9f709098c606a3b59ef09e8e2`.
The canonical UTF-8 compact JSONL witness has LF endings and SHA-256
`5fbabbad20efe0353072ac401279b81cc696415dd87621d905755b8dcf3e641b`.
The frozen helper hash is recorded in the receipt. No Coq source or new
proof claim is added by this study.
