# Ink installation: lower floors, object pushes and earlier top phases

This review starts at `ee8ba92b509179699b15860538c69f66b7eb674a` on
`codex/ssl-pyramid-item-proof`. It uses existing source and saved records only.
No new gameplay experiment or state search was run. The user subsequently
authorized pushing these changes and publishing the matching owner-private
site update. That authorization does not change the evidence scope.

## Answer for the manual

A lower floor helps Mario touch the warp, but does not by itself install Ink.
The useful distinction is between **where this update obtains a floor** and
**where Mario is after interactions**. A successful low first query also
prevents the raised-display retry. The proposed stopped crawl therefore needs
a current-update low cache, a later horizontal displacement, a stopped ground
quarter that does not replace that cache, and survival of the resulting gap
until the next warp check. None of the saved fixtures constructs this history.

There is a concrete refinement of the proposed 923-unit setup. The nearby
static floor is at **768**, not 818. At X/Z `(-1950,-939)` the finite static
geometry query from Y=1741 finds that pad; at the target `(-1882,-939)`, the
same high query finds the Y=1280 roof, while the low Y=818 query finds nothing.
A 68-unit eastward push can therefore separate those two static query
locations. If the cache stayed at 768, a stopped crawl's snap from 1741 would
make a **973-unit** vertical gap and leave collision at a warp-compatible
height. This is a source-supported candidate, not a recorded fixture, a
completed action proof, or a controller-produced route.

Earlier top phases can reduce the height needed for initial top capture.
The existing phase sweep nevertheless finds ordinary elevator arrival for
every saved non-131 continuation. That result is finite: it uses six low
poses, display Y=2300 and neutral continuations, and does not optimize earlier
phases or locate every loss of the platform reference. Initial capture,
retained useful payload, and clean production of the gap are three separate
questions. The no-A gameplay route remains open.

## Contact and the lower floor

The upper warp is centered at `(-2048,768,-1024)`, with radius 150 and height
50. With stock Mario radius 37, zero down offsets and the **live** normal
height 160, overlap requires horizontal distance strictly less than 187 and
collision Y in **[608,818]**. With the live short height 100, the vertical
interval is **[668,818]**. Vertical equality is accepted. These are overlap
conditions, not a complete interaction theorem: list capacity, tangibility,
interaction status, action and warp availability also matter. In particular,
the action tail updates Mario's hitbox after the earlier object-collision
pass, so an action name alone does not establish that earlier live height.

Source anchors: `reference-sm64-decomp/src/game/object_collision.c:25–56`,
`data/behavior_data.c:3511`, `src/game/mario.c:1648–1652`,
`levels/ssl/script.c:98`, `src/game/behaviors/warp.inc.c:14–23`.
The selected generated counterparts include `generated/jp_object_collision.v:363`,
`generated/jp_mario.v:8947` and `generated/jp_behavior_actions.v:19227`.

The authored pad is a Y=768 square, X in `[-2149,-1945]` and Z in
`[-1125,-921]`, split into faces `(498,500,501)` and `(498,501,502)`.
The Original position `(-2200,768,-1024)` is 51 units west of its edge but
only 152 horizontally from the warp center. Its first static floor query
misses. The 923-unit target is 63 units east of the pad and about 186.497
units horizontally from the warp center. The pad and both target positions
must not be conflated. Standing on the pad can allow contact while a
non-null first floor suppresses Original's display retry. Y=818 is a contact
ceiling, not the pad height or a required standing height. A recorded ordinary
entry at Y=768 is consistent with these rules.

The floor routine truncates query coordinates to signed 16-bit integers,
tests triangle edges, and rejects a floor more than the 78-unit buffer above
query Y. It checks the live dynamic and static lists, with intangible-floor
handling and their final height comparison; merely finding an eligible
source triangle does not prove the live returned floor. See
[Area1FirstNull](../../proofs/Area1FirstNull.v),
[vertical geometry](../../proofs/InkVerticalRetryGeometry.v), and
[live-list selection](../../proofs/InkVerticalLiveSelection.v).

## One producer update, then a later installation update

1. **Geometry preparation** resolves two wall queries and writes the current
   first floor result into `m->floor` and `m->floorHeight`. On a miss it copies
   display into movement and queries again, overwriting the cache again. Two
   misses queue death and prevent ordinary action dispatch. An old cache from
   the previous update cannot simply survive this prefix.
2. **Interactions** run after that preparation and before the action loop.
   Object collision has already prepared contacts from raw collision records.
   A producer must avoid accepting the upper warp here: acceptance replaces
   crawling with the disappeared action before the proposed crawl snap.
3. **An eligible object push** is a real intervening X/Z writer. Its
   destination floor query uses movement's high Y and a local output pointer.
   A non-null destination floor permits the two X/Z stores; they do not
   install that local floor into Mario's remembered cache. A null destination
   floor prevents those stores. The push does not supply the missing altitude.
4. **Established crawling** must survive its cancellation checks. Geometry
   sets `INPUT_OFF_FLOOR` when movement exceeds cached floor plus 100.
   Crouching and start-crawling respond with freefall. Existing crawling does
   not have that direct test, but needs Z held, movement input and no earlier
   sliding, first-person, A, punch/dive or other cancellation. Merely reaching
   high altitude in flight is not an established crawl.
5. **The first ground quarter must stop before replacing the cache.** A null
   floor or the applicable ceiling block can produce the stopped result.
   The quarter's wall corrections affect its local intended vector; a stopped
   quarter does not commit that vector. A successful accepted floor quarter
   instead installs movement and floor height together. A left-ground result
   switches to freefall and skips crawling's alignment.
6. **Refresh, return, alignment:** the ground helper refreshes display from
   high movement. On the actual stopped return, the crawling caller passes
   the speed guard and falls through to alignment. Its first store snaps
   movement Y to the remembered floor height, leaving display high at that
   cut. The existing theorem proves this conditional path and its exact gap;
   it does not produce the incoming high-movement/low-cache state.
7. **Finish and survive:** the matrix helper, animation/sound/action tail,
   zero sink assumption for the exact proposed pose, collision copy, final
   support check and next geometry preparation must compose. The ordinary
   raw copy can put collision at the snapped low movement while preserving
   display. The **next** update must cache warp contact, miss at low movement,
   retry from high display and select the live top. A gap made during crawling
   cannot help the warp interaction that already ran in that update.

Selected source anchors: `generated/jp_mario.v:6924,9226`,
`generated/jp_interaction.v:3940`, `generated/jp_mario_actions_moving.v:8046`,
`generated/jp_mario_actions_stationary.v:3460,4545`. Readable equivalents:
`src/game/mario.c:1314–1370,1699–1754`, `interaction.c:616–647`,
`mario_step.c:258–346`, `mario_actions_moving.c:88–95,1247–1299` and
`mario_actions_stationary.c:528–555,743–765` in the decomp sibling.
The [stopped-crawl note](ink-stopped-floor-producer.md) records exactly which
execution cuts are proved and which matrix/action effects remain uncomposed.

## The Composer suggestion: what a nearby floor and actor could supply

The new source inventory covers the entire square X `[-1982,-1782]`,
Z `[-1039,-839]`, within 100 per axis of the target. Exactly seven authored
upward-floor faces have bounding boxes intersecting it: two Y=768 pad faces
and five Y=1280 roof faces. Their exact source planes exclude Y=818.
This rules out the suggested **nearby authored static Y=818 plane in this
square**, not all live dynamic surfaces or all possible pushes.

The Y=768 alternative is more specific:

| Cut | Candidate requirement |
| --- | --- |
| Current geometry query | Movement `(-1950,1741,-939)`; static query selects pad at 768; live dynamic competition still needs checking. |
| Object interaction | Preserve established crawling and cache768; push movement 68 east to `(-1882,1741,-939)`. |
| First crawl quarter | Stop before installing its own floor. Neither the push's floor success nor the geometry certificate proves this stop. |
| Refresh then snap | Display1741; movement768; nominal gap973. |
| Next installation | Low first miss, high top retry, appropriate warp timing and retained platform payload. |

A **Koopa shell** is a concrete source-level actor class worth naming.
`interact_koopa_shell` mounts it only for a hit from above or walking/hold
walking; its other branch calls `push_mario_out_of_object(m,o,2)` and returns
false without replacing the action. With stock radius50 and Mario radius37,
its nominal final radial distance is89. A shell center at
`(-1971,1741,-939)` would geometrically move the candidate from radius21 to89,
giving the desired +68 X before wall correction. This placement is **not
recorded or proved reachable**; neither this arithmetic nor the new commit
theorem proves the trigonometric/wall prefix reaches that endpoint.
Eighty-nine is the final center distance, not a universal maximum displacement.

Sources: `generated/jp_interaction.v:8644`, readable
`src/game/interaction.c:1460–1483`, `behaviors/koopa_shell.inc.c:3–13`.
The stock shell box is at `(5840,940,2500)` (`levels/ssl/areas/1/macro.inc.c:29`),
not at the proposed high contact. Grabbable-object fallback pushes are another
source class, but no saved high Bob-omb/Crazy Box contact supplies this handoff.
The open actor obligation is an actual overlapping, eligible contact at the
right update without an action change or premature warp. The open player
obligation is a clean, already-crawling high pose with the freshly returned
low cache. Changing 818 to768 also changes the gap and continuation; it does
not inherit the saved 923-unit success.

There is also an authored sloping-floor point at `(-1073,818,-939)` on face
`(227,264,232)`, with vertices `(-767,512,-2303)`, `(-1535,1280,-511)`,
`(-767,512,256)`. Its ideal plane gives Y=818, but it is 809 horizontal units
from the target. This is a source calculation, not a live Float32 query or a
nearby actor handoff (`levels/ssl/areas/1/collision.inc.c:1442`).

Timing needs its own connection. A producer at timer131 normally hands its
gap to the following update, not back to the already-finished interaction.
Reproducing the known timer131 installation would ordinarily require the
producer on the preceding update, with that update's actual transformed
surfaces. No saved high query at the timer130 candidate supplies this fact.

The new `infg_timer131_high_query_pair_checked` certificate does resolve the
**timer131 source-mesh** comparison: at Y=1741, none of the checked top's four
floor faces accepts X/Z `(-1950,-939)`, while face `(1,4,3)` accepts the high
target `(-1882,-939)`. Together with the static samples, this establishes
compatibility of those two floor queries for that certified mesh. It does
not transfer the geometry to timer130, execute live lists or other dynamic
actors, or establish a stopped quarter or the subsequent useful payoff.

## Earlier phases: exact saved test and its limits

The phase screen uses top action 1 and timers 0–149. Its six supplied low poses
are `(-2200,768,-1024)`, `(-2048,689,-1024)`, `(-1882,818,-939)`,
`(-2208,818,-1104)`, `(-1936,818,-1144)` and `(-2152,818,-872)`.
It first requires accepted upper-warp contact plus null floor/death warp with
all positions low. It restores the state, raises only display to Y=2300 at
the same X/Z, and requires disappeared action, argument `0x40001`, top-owned
floor and top platform. It then runs at most 28 neutral updates. The success
screen is Area2 arrival outside inclusive XZ rectangle
`[-460,461] × [-204,717]`, not star collection.

Read-only aggregation of the saved JSON gives **895 initial captures**:
six at each timer except 131, where the loop breaks after its first outside
arrival. All 894 non-131 rows reach `(0,5500,256)`. Only 131 passes this screen,
so `passingProbeTimers` and `gridTimers` are both `[131]`. The later fine
position/height work is therefore **only at 131**. Its threshold code tries
the three integer heights around `ceil(floorY-78)`; it does not optimize all
earlier phases. Code: `instrumentation/wafel-jp-pilot/ink_near_warp.py:17–86,104–118,166–214`.
Receipt: `ink-near-warp-receipt.json:16115–16120`.

The exact vertical fixture has M=C `(-1882,818,-939)`, D
`(-1882,1741,-939)`, and returned top floor1818.9613037109375; one integer
display unit lower fails its initial capture. The mixed fixture has M=C
`(-1887,818,-929)`, D `(-1645,1465,-796)`, and floor1542.98291015625:
647 up, about276.14 sideways and703.4642848 in three dimensions. These are
supplied Wafel fixtures. The authentic JP recording validates the larger
Original installation and elevator bypass, not a clean producer or an
authentic-ROM replay of both smaller fixtures.

**Source calculation, not observed query:** at spinning timer0, the authored
origin is `(-2047,1536,-1023)`, with yaw0 and zero sine offsets. The base
vertices are at1281 and apex1792; originY1536 is not either the support height
or a universal floor height. At the target X/Z, the ideal positive-X face
has height `1792 - 511*165/512 = 1627.322265625`. The ideal 78-buffer threshold
is1549.322265625, suggesting integer display1550 and gap732 above818.
This calculation has not been connected to a timer0 binary32 live query.
It supports investigating a smaller initial gap, not claiming earlier payoff.
The source anchors are `reference-sm64-decomp/levels/ssl/script.c:20`,
`src/game/behaviors/pyramid_top.inc.c:32–49` and
`levels/ssl/pyramid_top/collision.inc.c:5–16` in that decomp sibling;
the generated spin body begins at `generated/jp_obj_behaviors.v:38803`.
Compare the checked timer131 stored base1528/apex2039 in
[timer131-surface.md](timer131-surface.md).

The phase receipt logs arrival, not intermediate owners, platform values or
free-list transitions. It cannot identify where each earlier phase loses the
reference or useful displacement. A separate timer131 side-face fixture
does show loss: D `(-1641,1456,-783)` initially captures, then at global498 /
top138 it has static floor1280 and null platform; its true first Area2 apply
does not move spawn. That diagnosis applies to that fixture, not to every
phase row (`timer131-surface.md:187–196`, `jp-lifecycle-trace.md:238–249`).

## Timing, freeing and first Area2 apply

The successful timer131 lifecycle installs at global492, captures at493,
explodes/frees the top at513, retains the pointer through change-area514/515,
and consumes its inactive payload at the **true first Area2 apply at515**.
Movement changes from `(0,5500,256)` to approximately
`(365.592773,5500,-1096.802612)` while raw collision/display still equal spawn;
they synchronize later. The first Area2 controller poll at516 is already
too late to inject at the first apply.

In that receipt, the early-freed top is slot61 at free-list depth0 with length109.
Bulk teardown pushes 131 slots; destination allocates 84; the retained slot is
then at depth47 with length156. These are **fixture counts**. The generic
LIFO theorem in `JPSlotLifetime.v:312–351` does not establish them for every
phase or history. Macro respawn suppression changes destination allocations;
a saved cap changes the documented fresh84 to85 (`jp-first-apply.md:197–208`).

This detailed lifecycle receipt uses an older supplied fixture, including a
pillar-counter write. The later four-pillar recording reaches the spin through
controller inputs and supplies only nine position values at global2680/top131;
its first Area2 apply is at2703. These are different recorded global clocks
and interventions. The newer recording demonstrates the zero-A pillar prefix
and larger-gap payoff, but does not automatically certify the older trace's
allocation counts for its own history.

The spinning action switches to explosion at timer150; explosion is a
separate action update, spawning 30 fragments plus mist and deactivating the
top. Collision loads after the behavior callback, and deactivated-object
unloading precedes the final platform query. The accepted object warp has a
20-tick delay. An earlier acceptance can therefore change whether the top
explodes before area teardown and how its slot is buried; a later acceptance
can permit another surface clear/support query after freeing. These are
source-based conditional explanations, not measured loss diagnoses for the
phase screen. An earlier useful payoff still needs its actual owner lifetime,
allocation order, payload bytes and first-apply execution.

Sources: [JP lifecycle trace](jp-lifecycle-trace.md):117–189;
[first apply](jp-first-apply.md):35–70,197–208;
`JPLifecycleTrace.v:36–94`; `generated/jp_obj_behaviors.v:39254–39285`;
decomp `pyramid_top.inc.c:51–87` and `level_update.c:808–813`.

## Checked code and remaining proof boundary

The companion modules are `InkNearbyFloorGeometry.v` and
`InkObjectPushHandoff.v`. The geometry certificate reuses the generated
US/JP collision initializers and existing parser/classifier, signed edge
tests and binary32 plane evaluator. Its plane exclusion is explicitly a
source-geometry result; its finite query checks do not execute live lists.
The push result starts at the actual generated post-query commit cut and
proves preservation there, not harmlessness of the whole wall/query prefix.
Both modules are registered in `_CoqProject`, consumed as propositions and
proved components by `InkConcreteProducerBoundary`, and exported through
`MainTheorem.current_ink_stopped_floor_producer_boundary` and the existing
backward boundary. This is actual use of the bounded results, not just an
unused import.

| Theorem | Statement and material premises |
| --- | --- |
| `infg_nearby_source_inventory_checked` | Exactly seven source-classified floor faces have bounding boxes intersecting the stated square; their nondegenerate planes are horizontal at768 or1280. Closed finite generated-data computation. |
| `infg_no_818_on_nearby_source_floor_plane` | For a face in the generated stream passing that same floor/box predicate, with its actual source vertices, the integer plane expression at Y=818 is nonzero for every integer X/Z. This is ideal source-plane arithmetic, not a live Float32 query theorem. |
| `infg_target_and_nearby_pad_queries_checked` | The four explicit static query samples and the two loaded-plane bit patterns are exactly as listed. Reuses source classification, signed edge tests and binary32 evaluator. Live loading/list selection and dynamic competitors are not proved. |
| `infg_source_mesh_versions_agree` | The complete parsed static vertex/triangle streams agree in the generated US and JP initializers. |
| `infg_timer131_high_query_pair_checked` | The certified timer131 top has no eligible floor at the high pad query and has the named face at the high target. Only this transform and these samples. |
| `iph_commit_has_only_the_two_position_stores` | Given actual execution of the generated US/JP commit and `_m = mb+0`, there are exactly the X and Z stores at60 and68 with matching resulting loads. Execution supplies the local values and successful memory stores; the theorem does not construct such an execution. |
| `iph_commit_preserves_height_cache_action_and_object` | Under the same execution and `mb <> ob`, Y64, floor pointer104, floorHeight112, action12 and every load from Object block`ob` are preserved. It does not prove the wall/query prefix preserves them. |
| `iph_null_destination_commits_nothing` | If the actual local-floor environment binding and its memory load contain null at the post-query cut, an execution of the generated gate leaves all memory unchanged, with empty trace and normal outcome. It does not derive the preceding floor query. |

Neither new module assumes or proves an allocator count. Neither proves an
actor placement, previous action history, new-A absence over a run, or a
completed warp. The existing stopped-crawl theorem still needs its actual
reached ground-refresh/caller/return/storage cuts and remembered height;
nonzero source floor geometry does not supply those executions.

The advancement is a more concrete remaining handoff: a real action-preserving
XZ store cut plus a specific nearby lower query point, with a bounded
obstruction to the exact818 static-floor suggestion. The conditional
stopped-crawl result remains conditional. No supplied-state premise, actor
history, cache provenance, action-tail effect, timing or allocator condition
has been silently discharged. There is no clean no-A route and no all-history
exclusion. Atlas estimates remain unchanged: Rank1 **1–2%**, Ink Rank2 **<1%**,
both subjective judgments.

## Validation commands and outcomes

Ubuntu WSL reports `sm64-item-proof`, Coq 8.16.1 and CompCert 3.15. The active
SSL wrappers retain their default 6.5 GiB limit (`6815744` KiB). The active
`docs/proof-audit.md` selects this SSL audit in place of the legacy repository
root audit. No bare `coqc`, generated-program-wide reduction, emulator run or
state search was used.

Commands below run from
`/mnt/c/Users/tariq/OneDrive/Documents/sm64 - the item-grab proof/reference-sm64-wmotr-abc-proof/SSL-Coq/less-than-one-a-press`
via `wsl.exe -d Ubuntu -- bash -lc`.

```sh
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/InkObjectPushHandoff.vo
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/InkNearbyFloorGeometry.vo

bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 \
  LessThanOneAPress.Proofs.MainTheorem current_ink_backward_execution_boundary \
  LessThanOneAPress.Proofs.InkRetryQuery irq_retry_connects_display_to_real_floor_call \
  LessThanOneAPress.Proofs.InkVerticalRetryGeometry ivr_vertical_retry_geometry_checked \
  LessThanOneAPress.Proofs.MainTheorem current_ink_stopped_floor_producer_boundary \
  LessThanOneAPress.Proofs.InkObjectPushHandoff iph_object_push_handoff_checked \
  LessThanOneAPress.Proofs.InkNearbyFloorGeometry infg_nearby_floor_geometry_checked
```

Both final targeted builds exit 0. The unchanged baseline audit with the first
three module/theorem pairs also exits0, receipt
`build/audit/20261111-085550-0or3gtzr`: 702 registered sources, 536/622 proof
modules in the main import closure, 86 standalone; foundations 9/7/4.
During development, `CHECK_TIMEOUT=180 bash pipeline/check.sh proofs/InkNearbyFloorGeometry.v`
localized an expensive implicit reduction and checked the repaired source
geometry proof; its final targeted build also checks the subsequent timer131
query pair. Initial proof-script errors were corrected before these successes.

Final integrated audit receipt: `build/audit/20261111-091836-uixf14re`.
**PASS, exit 0.** All 704 source files pass inventory; the selected build,
proof-hole scan, generated link hygiene and integration pass. The main
import closure contains 538/624 proof modules, with 86 registered standalone
modules and zero integration problems. The six assumption checks use,
in command order, 9/7/4/7/7/4 allowed Coq/CompCert foundations; no project
axioms or admitted proofs were introduced. This is the selected
MainTheorem/requested-dependencies audit, not `--full-build` of every
standalone module. Standard foundational axioms and explicit theorem
premises are different: the clean foundation report does not discharge the
player/actor/cache/lifetime conditions described above.

Read-only reaggregation of `ink-near-warp-receipt.json` independently confirms
895 rows, timer range 0–149, 894 non-131 rows all at stock spawn, and both
recorded timer lists `[131]`. No gameplay code was invoked for this check.
