# Two- and three-item Ink combinations in SSL Area 1

14 November 2026. **Two or three stock SSL actors can genuinely combine to
produce a useful Ink handoff.** This note establishes placements where every
actor matters, conditional on Mario already having the high ground slide.
Its separate high airborne-start menu does not find a usable joined handoff;
shell/Z can construct the slide, but the needed later push is blocked.
The broader investigation now has a stronger native airborne-to-slide
predecessor and original-JP validation; see the
[current combined verdict](ink-item-combination-verdict.md) and
[native predecessor study](ink-item-native-slide-combinations.md). The
single-update failures here do not exclude that longer successful history.

The most relevant cloned-Goomba result is precise: a frozen initialized
Goomba still supplies the Goomba interaction. It snaps Mario's Y upward and
sets upward velocity. A following shell and Crazy Box can then push Mario
sideways, but the positive vertical velocity prevents shell mounting. Mario
remains in an airborne action, so this chain does not execute the required
ground-slide alignment. A position change alone is not a useful handoff.

The durable [combined receipt](ink-item-combinations-receipt.json) contains
all finite screens, exact setup writes, native event traces, actor snapshots,
positive/removal continuations, independently replayed histories and hashes.

## Scope, versions and grants

Proof checkout: `08b72af44fbb54aaef3ed7f8be399868ba75db98`, branch
`codex/ssl-pyramid-item-proof`. Decompile base:
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. The receipt hashes the actual
local source/helper files. Existing unrelated changes were preserved.
Execution uses the authenticated Wafel 0.8.5 JP runtime and Python 3.9.13.
This note's tests are **native JP Wafel experiments**, not additional
original-ROM replays or new Coq claims. The separate original-ROM result is
identified in the linked current verdict.

The existing capture replays the established A-off four-pillar prefix,
including its disclosed debug level selection. A shell-box action 4 write
before top behavior 128 produces a real shell through two native updates.
The new experiments start immediately before behavior 130. Every selected
actor was already a stock initialized Area 1 actor; the shell is slot 126 in
this particular prefix. No interaction type, radius, height, tangibility,
interaction status, floor/cache, platform, top phase or collision list is
manufactured.

Primary starts supply M=C=D=`(-1950,H,-939)`, with H = 25000 or 67277, an
airborne action, forward/Cartesian velocity and face yaw 16384. Most use
FREEFALL, speed 20 and vertical velocity -16; the concentrated alternatives
use rising FREEFALL (+16) or supplied DIVE at speed 64. These remain supplied
airborne states, not a controller history reaching that position/action.
No action timer, animation progress or slide velocity is supplied in the
primary menu. Neutral or Z is used on the first update and neutral afterward;
A is always unheld and unpressed. Actor XYZ is supplied in that same initial
cut. Afterward only controller pads can be written.

The separate ground controls additionally supply CRAWLING or BUTT_SLIDE,
their action state/timer and slide-velocity fields. These grants are plainly
marked `supplied-ground-control`; they cannot establish Mario-side entry.
Their purpose is to test complete handoffs and actor contribution.

Conditional `carry_clone` variants supply the real non-HOLDABLE helper's
parent, behavior-command and stack-index effects to initialized actors.
Their original behavior identity and collision fields remain intact. This
does **not** supply a fake-pickup/release/duplication lineage or demonstrate
delivery. Frozen enemies retain INTERACTED after first contact; no test
resets that status between updates. The shared
[clone-control study](ink-item-clone-controls.md) records those limitations.
Buddy, Crazy Box and Bob-ombs remain native HOLDABLE actors in this menu;
they are not mislabeled as valid frozen carry clones.

## Actors actually available in the tested SSL prefix

Radii/heights below are the live initialized values, including native scale.
They are not substituted generic species dimensions.

| Actor | Slots used | Interaction / radius / height | Availability and handling |
|---|---:|---|---|
| Koopa shell |126|KOOPA_SHELL /50 /50|Stock shell-box contents; native release supplied; native and conditional frozen variants |
| Crazy Box |49|GRABBABLE /75 /125|Stock SSL1; native callback retained |
| Goombas |6,7|BOUNCE_TOP /108 /75|Stock SSL1; native and conditional collision-only variants |
| Fly Guy |38|BOUNCE_TOP with twirl-bounce subtype /105 /90|Stock SSL1; native and conditional frozen variants |
| Klepto |54|HIT_FROM_BELOW /160 /250|Stock SSL1; native and conditional frozen variants |
| Large breakable box |13|BREAKABLE /150 /200|Stock SSL1; native and conditional frozen variants |
| Small box |23|GRABBABLE /60 /100|Stock SSL1; native callback retained |
| Bob-ombs |39,40|GRABBABLE /65 /113|Stock SSL1; native callbacks retained |
| Cannon-opening Bob-omb Buddy |15|TEXT, NPC subtype /100 /60|Stock SSL1; native callback retained, no talking input |

The Buddy is a real SSL Area 1 NPC, not a foreign-object invention. Its
passive interaction pushes with target distance 100 + 37 - 10 = 127 and continues.
Shell nonmount push targets 50 + 37 + 2 = 89; Crazy Box targets 75 + 37 - 5 = 107.
All three types are distinct, so shell, grabbable and NPC pushes can run in
that source order when no earlier handler terminates processing.

There is only one initialized Crazy Box in this prefix. Same-type controls
therefore use two actual Goombas, Crazy Box plus Bob-omb, and two actual
Bob-ombs plus Crazy Box; no second box instance or behavior is invented.
Tweesters are stock SSL actors, but the three current prefix instances have
zero radius/height, so this menu does not pretend they are initialized
full-sized tornado hitboxes. Pokey parts and flame/explosion actors are not
live initialized instances here. They are untested by this menu, not declared
absent from the level in every history. The igloo barrier remains a
source-only continuing-push possibility from another level; no stock SSL1
igloo barrier was supplied or type-edited into the runtime.

## Finite coverage and full continuations

| Batch | Coverage | Result |
|---|---|---|
| High airborne starts |1280 recipes; 19 stock pair/triple families; eight directional/vertical placement profiles; native/frozen variants; neutral/Z plus rising/DIVE alternatives; four updates per recipe |200 recipes execute a high crawl/slide-family action, but zero capture the top for the warp |
| Baseline ground controls |10 separately tagged recipes at 25000/67277 |Eight capture and complete useful Area 2 arrival; two Buddy-overpush controls fail |
| Selected full histories, baseline removals and same-type comparisons |58 complete histories, up to 40 updates or first Area 2 entry |1930 independently matching boundaries |
| Targeted necessity geometry |210 pair recipes and 168 derived triples; 439 four-update actor-removal screens |Three selected geometries complete useful arrival with every removal failing that continuation |
| Matched height continuations |Those three geometries and all removals at 25000, 67277, 90536 |30 complete histories / 840 independently matching boundaries |
| Floor-NULL primer controls |Eight world-boundary recipes |32 independently matching updates; action constructor works but pending death blocks a useful route |

Counts are recipes, not a proof of exhaustive or distinct physical states.
Some placement profiles coincide for families without the relevant enemy.
The targeted triple proposal uses a failed shell/box endpoint and computes
a collision-compatible Buddy position aimed toward the known useful retry
region; it is not a blind product of every object coordinate. All selected
positive and removal histories start from independently booted copies of the
same prefix. Removing an actor omits its placement/freeze, leaving it in its
original native world state; the remaining actor positions/modes and Mario
fields stay identical. Necessity below means necessity for this recorded
placement and neutral continuation, not every possible later controller input.

## What the cloned Goomba, shell and box actually do

Use H = 25000, initial FREEFALL with velocity `(20,-16,0)`, neutral input,
Goomba 6 at `(-1950,24990,-939)` in the conditional carry state, shell 126 at
`(-1989,24990,-939)`, and box 49 at `(-1989,25000,-939)`. Native subset replays
from the identical saved prefix expose each contribution at the first action
dispatch, **after interactions and before the movement step**:

| Actors placed | First-action M | Vertical velocity / action |
|---|---|---|
|None|`(-1950,25000,-939)`|-16 /FREEFALL |
|Goomba|`(-1950,25065,-939)`|+30 /FREEFALL |
|Goomba + shell|`(-1900,25065,-939)`|+30 /FREEFALL |
|Goomba + shell + box|`(-1882,25065,-939)`|+30 /FREEFALL |

The Goomba's interaction snaps M.Y to its top, 25065. This is an immediate
position write, separate from its +30 velocity write. The shell now cannot
take its descending HIT_FROM_ABOVE mounting branch; its nonmounting branch
pushes X to -1900 and continues. The box then pushes X to -1882. All three
actors really register (`[126,49,6]` in native collision-list order), although
the type-handler order is Goomba, shell, box. The source table, not slot or
collision-list order, determines that different-type processing order.

The following high air step hits the default ceiling test, suppresses the
upward movement and ends with vertical velocity -4 after gravity. M=C=D
remain `(-1882,25065,-939)`; the fresh floor cache is 768. There is no
ground-slide alignment, low collision or real warp contact. With H = 67277,
the identical contributions produce Y=67342 and the same failure. Pressing Z
after the bounce selects an airborne ground-pound, not the required ground
slide. Fly Guy twirl-bounce instead changes the action and terminates before
the later push handlers. These are action-order failures, not a claim that
the actors failed to collide or move Mario.

Conversely, a supplied BUTT_SLIDE at speed 64 can attack the Goomba without
the airborne bounce, then let shell and box push and complete the handoff.
Removal tests show that Goomba and shell are individually unnecessary in
that original same-center fixture: box alone already works. That positive
three-actor overlap is therefore not counted as a new necessary combination.

## Three geometries where every actor matters

All three start immediately before top behavior 130 with **supplied**
M=C=D=`(-1950,25000,-939)`, BUTT_SLIDE, speed 20, Cartesian/slide velocity
`(20,0,0)`, yaw 16384, action state/timer 0, and neutral input throughout.
The following actor XYZ are the only additional placements:

| Combination | Exact supplied actor positions |
|---|---|
|Shell + Crazy Box|Shell `(-1989,24990,-939)`; box `(-1960,25000,-889)` |
|Buddy + Crazy Box|Buddy `(-1989,25000,-978)`; box `(-1960,25000,-909)` |
|Shell + Crazy Box + Buddy|Shell `(-1989,24990,-978)`; box `(-1960,25000,-989)`; Buddy `(-1946.03173828125,25000,-839.323486328125)` |

Each actor's interaction occurs before the slide's first movement step.
The native handler sequence for the triple is shell push, grabbable push,
then NPC push, despite its registered order `[126,15,49]`. All actors remain
native in these three necessary geometries; no frozen Buddy is used.

| Combination | Producer M=C, D has same X/Z and Y=25000 | Next-update retry floor, owner/platform |
|---|---|---|
|Shell + box|`(-1877.7059326171875,768,-957.3862915039062)`|1823.0281982421875, top 61 / 61 |
|Buddy + box|`(-1876.0908203125,768,-1036.142333984375)`|1859.3201904296875, top 61 / 61 |
|All three|`(-1881.9140625,768,-948.9498291015625)`|1822.3154296875, top 61 / 61 |

The producer cache is the real static floor 768, the default ceiling is 20000,
and zero top surfaces are loaded. The first action is BUTT_SLIDE at the high
post-push position; native stopped stepping saves that high D and alignment
moves M/C to 768. The action ends GROUND_BONK. This is a 24232-unit stored-
graphics/movement gap, not a statement about where the rendered model appears.

On the next update, six top surfaces load. Raw low collision overlaps the
real upper warp at `(-2048,768,-1024)` with radius 150 / height 50. The low floor
query misses, the high stored-graphics retry selects the listed top floor,
the warp is accepted (DISAPPEARED, used object 64), and M=C=D move to that
actual returned floor height. Both floor owner and platform are 61. The
platform remains 61 through all remaining Area 1 observations, including three
with the top inactive. The first Area 2 state is native update 25 from the cut:
**`(365.5927734375,5500,-1096.8026123046875)`**, outside the ordinary lower
arrival footprint. This is the required useful spawning displacement.

Each removal was continued independently. These are the first failed links:

| Original | Actor removed | Outcome under the same remaining placements/inputs |
|---|---|---|
|Shell + box|Shell|Producer X/Z `(-1938.96435546875,-993.911865234375)`; warp accepted with static floor 768, no top/platform; ordinary arrival |
|Shell + box|Box|Producer X/Z `(-1900,-939)`; warp accepted with static floor 768, no top/platform; ordinary arrival |
|Buddy + box|Buddy|Producer X/Z `(-1926.12451171875,-1010.49609375)`; ordinary warp, no top capture |
|Buddy + box|Box|Producer X/Z `(-1899.1973876953125,-888.1974487304688)` misses real warp contact; high retry alone gives no platform; no Area 2 within 40 updates |
|All three|Shell|Producer X/Z `(-1926.62646484375,-964.8322143554688)`; ordinary warp, no top capture |
|All three|Box|Producer X/Z `(-1913.4754638671875,-962.0797119140625)`; ordinary warp, no top capture |
|All three|Buddy|Producer X/Z `(-1915.4420166015625,-891.718994140625)` misses real warp contact; no Area 2 within 40 updates |

These successes show genuine joint geometric contribution. They do not show
that the supplied high BUTT_SLIDE or actors were reached by allowed gameplay.

## Why the same placements fail at 67277 but work at 90536

Only actual Mario/actor Y coordinates were shifted for the matched controls;
X/Z, action, speed, timing and inputs remained identical.

| Actual starting Y | Queried signed16 Y for high D | Producer gap | Complete result for all three geometries |
|---:|---:|---:|---|
|25000|25000|24232|Useful handoff; every actor removal fails that continuation |
|67277|1741|66509|Warp accepted, but retry selects static floor 1280, no platform; ordinary Area 2 `(0,5500,256)` |
|90536 = 25000 + 65536|25000|89768|Useful handoff again; every removal still fails |

The new retry X/Z select top heights 1823.0282, 1859.3202 and 1822.3154.
At aliased Y=1741 the floor acceptance tolerance reaches only 1741+78=1819,
so all three top candidates are too high. The source's signed-coordinate
conversion and floor-height test explain the observed change
(`surface_collision.c:459,513`). The old default box witness at 67277 uses a
different retry X/Z and remains valid. Successful query aliasing here does
not prove a general periodic handoff for every VPU offset: raw actor contact,
top loading, timing, precision and every other native step were actually
rerun for these particular controls.

## Same-type and collision-capacity checks

The source allows at most four entries in each object's collision list.
Mario's entries refer to the other objects, not to Mario himself. Within
that list the interaction loop handles at most one actor for each interaction
type. Extra same-type bodies are not automatically extra bounces or pushes.

With cloned Goombas 6 and 7 together, both register, but only 6 gets status 49155
(INTERACTED plus attack-from-above); 7 stays 0. Each alone bounces Mario to
Y=25065. Together they still supply one bounce. Adding box 49 gives registered
`[49,6,7]`, one Goomba bounce and one box push.

The opposing-center GRABBABLE controls make this visible without relying on
native callbacks preserving status: Bob-omb 39 alone gives first-action
X=-1892; Bob-omb 40 alone gives -2008; box 49 alone gives -2018. With both bombs,
registered order is `[39,40]` and the result is -1892. With all three it is
`[49,39,40]` and the result is -2018: the box's first-listed same-type handler
is selected. Different actor-list classes affect registration order, so it
must be observed rather than inferred from numeric slot order. Full records
preserve these exact first-action events and native status changes.

## Separate floor-NULL primer control

Eight matched controls at raw X = ±8192/±8180, Z=-939, H = 25000/67277 preserve the
different floor-NULL action-constructor lead. At X=-8192, initial FREEFALL
plus the supplied shell natively selects RIDING_SHELL_GROUND, but the final
floor-NULL guard skips action dispatch. An actor-only box cut next pushes M
to X=-8180 while the cached floor stays NULL, retaining the riding action.
On the third update a real floor query plus Z reaches BUTT_SLIDE and aligns
M.Y to 743.5404663085938. No ground action or subsequent Mario position was
written. The corresponding inside-boundary control starts ordinary ground
knockback instead.

This constructor is unusable for the intended handoff as tested. The initial
floor miss already queued pending death operation 18 before interactions,
with countdown 47 at the first sampled boundary. It remains 18 / countdown 45
when the slide finally executes. The later ordinary object-warp trigger
cannot replace that live pending operation, and the tested boundary is more
than 6000 units from the real pad. The source study also covers the nearby
static-roof region. This is credited as an actual conditional constructor
with an exact death/transport obstruction, not a useful route or a local
near-warp floor hole. The receipt includes all eight controls and 32 matching
fresh replay boundaries; the stronger current native predecessor uses a
different sequence and does not rely on this primer.

## Interpretation and remaining work

The high one-pass airborne menu separates two requirements cleanly. Some
shell cases natively execute the needed ground-slide action, but mounting
terminates interactions before the later box/NPC push. The cloned-Goomba
chain admits the pushes by preventing mounting, leaving the action airborne.
Neither observation is a universal exclusion of longer histories. The
separate native predecessor now supplies the missing action through an
earlier update and combines later Buddy/box contacts; its original-JP result
is the current main positive, with its remaining initial-air and delivery
grants stated in the combined verdict.

The new necessary pair/triple geometries establish that actor count can
matter causally, rather than merely decorating a box-alone success. Their
remaining obligations are Mario-state entry, actual actor delivery and
joining the actors at the stated phase. The collision-only Goomba is a
conditional initialized carry state here, not an established legitimate
clone/release history. No new Coq theorem, global height bound, all-item
classification or measured counterexample probability is claimed by this
finite runtime study.
