# Forward box transport and the hands-free teleport alternative

The clean jumping-box pickup has not yet produced a useful pyramid delivery.
The new forward searches stop near the starting dunes, before any pillar
activation. Hands-free teleport provides a different, useful Bob-omb
mechanism: Mario can lose his held-object pointer while the original actor
remains internally held, then recover and release that actor. The first
teleporter approach is still supplied in the local demonstrations. Clean
inputs now repeatedly regrab and transport the original Bob-omb, while a
separate conditional orphan trail reaches crawl on the low entrance roof.
Neither family currently supplies the complete high-crawl/timer-130 handoff.

This investigation starts at `b53d39e5277919dc35e53a94e767d2d58bfd323e`.
It uses the existing hash-gated native JP Wafel runtime and accepted debug
level-select entry. Clean branches write controller inputs only after that
entry. Local teleporter experiments list their additional state cuts. No new
Coq theorem, original-ROM replication, universal actor-lifetime bound or
all-history exclusion is claimed here.

## What the forward box search tests

The [transport study](ink-handsfree-transport.md) reconstructs all five
previously distinct clean hands-free endpoints. Ninety distant waypoint
policy rows represent 45 distinct seeded input histories and 9,202 updates.
Fifteen beams evaluate 66,906 short branches and 263,494 updates; recreating
retained candidates adds 19,056 more advances. These figures count repeated
prefixes and are not numbers of independent complete routes.

The highest observed held position is Y=127.057381. The closest held sample
remains 7,456.31 X/Z units from the pyramid center. All tested held states
remain in stomach slide, its stop animation or idle. No tested branch reaches
the airborne prerequisite for the proposed B re-dive or Z ground-pound
continuation. Twenty-five selected fresh-instance runs, representing 23
different full histories, match 802 continuation snapshots.

The local problem is loss of momentum on the starting terrain. Sliding
accelerates downhill. Forward stick can reduce sliding friction on a very
slippery surface but does not add ordinary uphill walking acceleration. Once
Mario slows on a non-sloped patch, the stop animation leads to idle; ordinary
idle processing releases the box. The tested floor-level releases delete the
box on the next update. Grounded stomach-slide B rollout explicitly drops the
object too. A normal airborne freefall would permit a box-preserving B dive
or Z ground pound, but these searches never reach that state.

An [additional acquisition study](ink-handsfree-acquisition-routes.md) tests
66 policies, 49 distinct histories and 19,471 branch updates. Its 24 eastern
approaches all pick up the box; eight take the hands-free exit. The 42 western
approaches produce 21 pickups, all landing on flat type-0 floor at Y=0 and
then entering `HOLD_IDLE → CRAZY_BOX_BOUNCE`. No western hands-free exit is
found. Three selected fresh histories replay their initial boundaries and
200, 348 and 302 subsequent snapshots.

There is also a concrete preparation constraint. In the accepted recording,
Mario picks up eastern box 47 after input 375; its third bounce destroys it
after input 491, and slot 47 is reused after input 492. Full-pool scans at the
later three-pillar checkpoints contain only western box 49. Thus the clean
eastern hands-free pickup cannot simply be attached to that already-existing
three-pillar history. Preserving the eastern actor requires changing the
earlier pillar route, or obtaining a useful western pickup. Two simple
experiments omitting early B inputs preserve eastern 47 but reach no pillars;
they are exploratory observations, not successful alternative preparations.

These are bounded searches. Other pickup headings, intervening interactions,
release/regrab histories and paths removed by beam ranking remain open.

## What hands-free teleport means here

The user supplied pannenkoek2012's
[SM64 — Hands Free Teleport Glitch](https://www.youtube.com/watch?v=qqmYYIQRSuI).
The relevant distinction is actor recovery, not preservation of Mario's
pointer across the warp. The attached 647.720635-second video was inspected
through sampled native frames and its explanatory captions, including the
Bob-omb segment around 2:20–2:45 and the bloated example around 4:40–6:00.
The local file has SHA-256
`eb81b8da579e69c68bee761963e217da8cfe79332451de59324b0c5a1d29c7bb`.
The reference video is not redistributed with this report. It illustrates
the glitch, not a controller-certified no-A SSL approach or the selected JP
runtime boundary.

Mario's held-object pointer and an actor's own held state are separate:

| Boundary | Mario's `heldObj` | Original Bob-omb's `oHeldState` |
| --- | --- | --- |
| Hands-free slide/idle before teleport | Points to the Bob-omb | `HELD_HELD` |
| Native same-area teleport initialization | Cleared | Can remain `HELD_HELD` |
| Reactivation after returning near the actor | Still null | Still `HELD_HELD`; actor follows Mario |
| Actual regrab | Restored to the same actor | `HELD_HELD` |
| Actual release | Null | Dropped, then free under its native callback |

The source supports this distinction. Fading warp interaction accepts
ordinary idle, panting, standing-against-wall or crouching, and runs before
Mario's action body (`src/game/interaction.c:855–871`). That can intercept an
idle-with-held-pointer boundary before idle's ordinary drop. Normal teleport
initialization calls `init_mario`, which clears `heldObj` even for same-area
teleports (`src/game/mario.c:1817`; see the existing
[same-area audit](teleporter-wrong-warp.md#reset-and-displacement-order)).
Clearing that pointer is not itself a release of the actor.

The Bob-omb behavior's 4,000-unit distance check gates its held-position
refresh and fuse updates (`src/game/behaviors/bobomb.inc.c:238–280`). The SSL
Area 1 fading pads are at `(6930,0,-4871)` and `(-5943,0,-4903)`
(`levels/ssl/script.c:104–110`), far enough apart that a Bob-omb can remain at
the source until Mario comes back within its update range. Once active, the
held loop places it 60 units up and 100 units forward relative to Mario.

Unlike the jumping box's held callback, the Bob-omb held callback does not
make it intangible. It hides the model while retaining collision; fuse smoke
can still appear. The jumping box calls
`cur_obj_unrender_set_action_and_anim`, which also makes it intangible.
Therefore an invisible Bob-omb can be regrabbed while an orphaned jumping
box is not interchangeable with it. Object collision and the grabbable push
fallback do not require `HELD_FREE`. A tangible orphaned Bob-omb is also a
candidate pushing actor before regrab/release, subject to its actual relative
position and the current movement/collision cache.

The pending explosion needs separate accounting. The held Bob-omb loop can
set the explosion action and request a Mario drop after its fuse exceeds
150, yet the explosion body is not executed while the actor remains held.
Once actually released, that deferred explosion can resume. “Recoverable”
does not imply an arbitrary lifetime after release, nor a free reset of its
fuse. The native regrab/release observations below retain that distinction.

## Regrab, release and the bloated push

The [local teleport study](ink-handsfree-teleport.md) first obtains original
Bob-omb 39 with a continuous no-A history. The accepted 350-input prefix plus
197 new inputs reaches ordinary idle with the Bob-omb still held, at
approximately `(3895.1531,0,6085.1802)`, fuse 89. This is a clean acquisition
component, not a clean teleporter arrival.

For the next experiment the script translates all three Mario positions and
the actor's XYZ to the east pad: twelve scalar coordinate writes. It retains
action, fuse, scale, held states and the rest of the state. Native teleporting
clears Mario's pointer; a controller-only departure and reverse teleport
reactivate the same tangible actor. B then restores that actor's held pointer
on update 6. Its expired fuse causes a real release on update 18 and deletion
on update 25. In the selected Z continuation Mario starts crouching on 18,
is crouching on 23, and starts crawl on 24; he has not established crawl when
the Bob-omb disappears. That is a timing failure for this particular release
and input sequence, not a universal ban on using Bob-ombs.

A second B at release-sequence updates 18, 19 or 20 catches the bloating actor
at scale 1.4, 1.6 or 1.8. The largest caught actor has radius 117. However,
ordinary `PICKING_UP` is not a hands-free action eligible for the teleporter.
The separate bloated-orphan diagnostic therefore explicitly supplies another
twelve coordinate writes **and ordinary idle**. Native teleport/return then
produces a tangible, internally held orphan with Mario's pointer null. Four
neutral updates each push Mario backward about 49.00009 units, despite zero
velocity and zero forward speed. The source's separation target is
`117 + 37 - 5 = 149`, versus the held actor's 100-unit forward offset. This
explains the video's apparent backward momentum as repeated collision
correction. It does not prove indefinite movement or uphill reachability.

Consequently there are two useful Bob-omb possibilities: recover and release
the actor, as the user proposed, or retain the tangible orphan as a pushing
actor. The latter does not need `HELD_FREE`. Neither possibility by itself
provides the required high Mario state, fresh floor cache or top timing.

## Clean repeated regrabs keep the Bob-omb alive

The [clean transport study](ink-bobomb-regrab-transport.md) starts from the
controller-produced Bob-omb acquisition, without either teleport setup.
Two hundred policies (118 distinct seeded input histories) evaluate 21,049
updates. Fifty-six recovery policies (45 distinct suffix histories) add
12,164 updates. They vary release/regrab controls, steering, waypoints and
bounded turn rates; they do not cover every route across the level.

Repeated B regrabs can keep the expired original Bob-omb alive. The selected
direct trail makes 17 regrabs, while the nearest recovery suffix makes 18
further regrabs after its native bloated-capture prefix. For that complete
history, this is **twenty regrabs after the original pickup**, including the
two regrabs before the recovery suffix. The full
[938-input witness](../../instrumentation/wafel-jp-pilot/ink-bobomb-regrab-transport-inputs.jsonl)
is retained. Across the tested
held samples, the fuse reaches 475 and scale reaches approximately 1.4,
giving radius 91. The full 1.8 scale seen during the final free explosion
must not be described as sustained clean carrying. Ordinary pickup and
holding actions recur; the source's pending drop and short explosion
sequence leave narrow opportunities to catch the actor again.

The nearest held sample reaches approximately `(6909.080,-49.756,-738.317)`,
still 4,132.7362 X/Z units from the eastern teleporter, in `PICKING_UP`.
The tested eastern paths fail in the quicksand strip before reaching the pad.
The highest held Y anywhere in the screen is
251.329544, with zero pillars touched and no spinning top. Five fresh runs
representing three distinct full histories match 1,927 snapshots. This is
positive clean transport evidence, not a successful teleport approach.

Even delivery onto a pad would leave an action obligation: `PICKING_UP` and
ordinary holding are not the idle/panting/wall/crouch states accepted by the
fading warp. A fresh hands-free conversion at the correct place and update
must be demonstrated, rather than inferred from survival or distance.

## The orphan reaches a low roof and established crawl

The [conditional transport study](ink-hft-pyramid-carry.md) continues both
normal teleport setups and the stronger bloated setup using only no-A
controls. Its 32 route policies, 18 tornado timing/steering policies and five
roof-settling policies evaluate 27,581 suffix updates, excluding preparation
and fresh replays. These are finite menus, not exhaustive path planning.

The useful positive trail starts with the normal western orphan. Mario walks
around the southern side, enters a tornado and reaches Y=1597.811279 while
twirling. That height occurs at X/Z approximately `(-3624.321,3473.751)`,
far south of the top; it is not high crawling at the target. He lands on the
pyramid's **entrance roof at Y=256**. Holding Z to settle, then using a small
stick, establishes actual crawling 25 updates after the landing. All four
tested cardinal crawl suffixes retain the live, tangible orphan through
their 90-update horizons. The neutral-stick control stays crouched.

The original Bob-omb remains nearby, internally held and tangible, while
Mario's held pointer is null. This matters for the tornado: its ordinary
stop-riding-and-holding call has no Mario held pointer through which to drop
the orphan. The actor therefore survives this lift, even though ordinary
holding can be disrupted. The selected crawl cache is Y=256, with no floor
owner or platform reference; no Y=768 cache has been established. Zero
pillars are touched and the top has not started spinning.

The original walking continuation instead reaches the ordinary lower
entrance. Its closest approach, 1114.1015 horizontal units from the pyramid
center, occurs at Y=0. Combining that distance with the separate tornado
height would invent a high near-top state that the trail never visits.
Ten selected fresh replays match 4,700 logged snapshots, including the
selected roof-crawl outcomes and their conditional preparation.

## What still needs to join

For the box, a successful route must improve the clean pickup/transport or
use a different native interaction, preserve the actor through pillar
preparation, and reach a high stop with enough release life to establish
crawl. These bounded low-terrain failures do not prove that impossible.

For the Bob-omb, the first missing connection is a clean teleporter arrival
with one of the eligible hands-free actions. Ordinary regrabbing and carrying
do not automatically supply idle-with-held-pointer at a pad. The bloated
version additionally needs a clean conversion to that eligible action.
After HFT, the orphan's extra freedom permits a real tornado-and-crawl
component, but only on the low entrance roof so far. A route must still gain
the required height, prepare the pillars, establish the fresh low floor
cache, arrange the pushing actor and contact the upper warp at useful timing
in one continuous history.

The earlier supplied timer-130/131 installation remains a separate witness.
This study does not inherit its explosion/allocation schedule for a newly
timed Bob-omb history. Repeated releases, explosions and spawns can change
slot use. Any future joined producer must be replayed through top capture,
top lifetime, area transition and the first Area-2 apply; it is not enough
to recognize a high picture or a live actor near the pyramid.

No Coq definitions or proofs changed in this follow-up. These runtime
receipts do not discharge the existing generated-code hypotheses. The
complete clean 0xA SSL Pyramid route remains open; all 45 atlas estimates
and their four single-paragraph summaries remain unchanged, including
Rank 1 **1–2%** and Ink Rank 2 **<1%**.

## Checks and reproducible boundaries

The five linked study notes give their exact native commands, finite bounds,
input provenance, source/runtime hashes and fresh-instance comparisons.
The checks were run from `SSL-Coq/less-than-one-a-press` using the existing
`./build/wafel-pilot/python/python.exe`. The following read-only audits pass;
they verify saved receipts and replay assertions rather than advancing games:

```powershell
./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/verify_ink_handsfree_transport.py
./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/verify_ink_handsfree_acquisition_routes.py
./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/verify_ink_bobomb_regrab_transport.py
./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/verify_ink_hft_pyramid_carry.py
```

The HFT script instead contains its fresh-instance checks in `--study`.
Both its accepted-capture run and a full run using the committed
`instrumentation/jp-ink-handsfree-demo/clean-component-inputs.jsonl` pass and
agree except for the input-file hash metadata. Its receipt distinguishes the
script/runtime/input hashes recorded at execution from the imported-helper
hashes audited afterward; it does not invent a fully transitive at-run
fingerprint. Syntax checks also pass. No bare `coqc` or new Coq build is
used because this follow-up changes no proof module or theorem boundary.
