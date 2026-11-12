# Parallel universes and the Ink handoff

Investigated 12 November 2026. **A vertical-PU version of the supplied
handoff works, including useful Area-2 displacement. A continuous no-new-A
route to its starting state has not been found.** This is a new conditional
lead, not an impossibility result or a completed route.

## Plain-English answer

The useful feature is not simply a bigger gap. At Y=67,277, a floor query
sees Y=1,741, but Mario's actual position remains high. Already-crawling
Mario can remember the ordinary floor at 768, receive the sideways push,
and have his attempted crawl step blocked. The game saves his high display
position and then snaps his movement and collision positions to 768. This
creates a **66,509-unit display/movement difference** in the tested update.

The top is too far away to load collision while Mario is high. That does
**not** kill this setup: after the snap, the next update loads the top again
before Mario's failed low floor query retries from the high display
position. The retry sees 1,741, selects the top, and the disappeared action
puts Mario on its ordinary local surface. The unedited warp timing then
gives the familiar useful arrival in Area 2.

There is also a concrete conditional way to deliver the actor. A normal
throw using a supplied high HOLP puts a Crazy Box or Bob-omb at the required
high location. In separate joined tests the item waits there, and supplying
only Mario's missing high crawler at timer 130 completes the handoff. No
clone or later actor-position edit is needed in those tests. **The high
HOLP, holding state and high crawler are supplied, not produced by play.**

A horizontal PU alone helps less directly. Mario can start crawling on an
aliased low pad after a position-only PU seed, but this leaves his actual
height at 768 and his actual X/Z far from the warp. The tested high
horizontal-PU copies lose crawl because the nearby top ceiling is absent.
A combined horizontal/vertical PU does create a vertical snap, but it does
not return Mario's X/Z. No tested horizontal variant captures the top.

The most important catch has therefore moved from “does this local VPU
handoff function?” to **“what actual play history puts Mario at that height
while already crawling, and preserves a suitable HOLP until release?”**

## Baseline and scope

The branch is `codex/ssl-pyramid-item-proof`, HEAD
`15462a6d6f9d5b1b6522ea926f1d207e013db835`, a descendant of the requested
`ee8ba92`. The latest commits contain the warp-delay, below-cap, fresh-cache,
push and crawl work. The checkout already had unrelated documentation,
earlier-entry/slide/walking-edge experiments and build files; these were
preserved. No branch reset was performed. The initial investigation was
kept local; the follow-up authorizes committing and pushing the source,
with site deployment still withheld.

The starting handoff and crawl records remain applicable. The newer
[below-cap search](ink-below-cap-phase-search.md),
[warp-delay investigation](ink-warp-delay.md), and existing uncommitted
earlier-entry (`ink-early-air-entry-crawl.md`),
top-slide (`ink-top-slide-to-crawl.md`) and
walking-edge (`ink-walk-edge-crawl.md`) notes were read. These three local
notes remain outside this commit. Their finite negative
results do not exclude this differently supplied VPU state. The earlier
[clean hands-free component](ink-handsfree-clean-followup.md) supplies low
pickup/release/crawl, not VPU entry or a high HOLP.

The decompile checkout is HEAD `36fbf8d`, with local changes. Relevant
geometry, movement, interaction, actor and rendering code was compared to
stock `9921382a68bb0c865e5e45eb594d9c64db59b1af`; the local conditional TAS
staging in level initialization/update is not treated as gameplay. Tests
use the existing authenticated **Wafel 0.8.5 JP DLL**, SHA256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
This session does not add an original-ROM replay of the new VPU setup.

## Source sequence: which coordinate record is used?

Write **M** for movement (`MarioState.pos`), **C** for the collision
object's raw position, and **D** for stored `header.gfx.pos`. D is not
necessarily the model's visible position: crawl alignment installs a
`throwMatrix` that the renderer uses instead of the ordinary translation.

1. The object scheduler clears/rebuilds dynamic surfaces, updates terrain
   objects, applies remembered-platform displacement, detects object
   overlaps, then runs Mario and the later actor lists. Final platform
   selection occurs after those callbacks. See
   [object_list_processor.c:172,647](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_list_processor.c#L647).
2. The top has collision range **20,000**, not the common default range.
   Its script does not request the ordinary distance-cache update. Its
   initialized cache remains the sentinel **19,000** in these tests, so
   `load_object_collision_model` recomputes full three-dimensional distance
   from the top to **C** on each call, without replacing that sentinel.
   The loader also requires no active time stop and no different-room flag.
   See [behavior_data.c:4418](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/data/behavior_data.c#L4418),
   [surface_load.c:754](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/engine/surface_load.c#L754),
   and [object_helpers.c:295](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_helpers.c#L295).
3. Object overlap uses raw object coordinates, a strict horizontal
   radius-sum test, vertical endpoints and tangibility/list-capacity gates.
   Terrain aliasing does not duplicate either the box or the upper warp.
   At warp detection **C**, rather than necessarily M or D, must overlap
   the actual warp. See
   [object_collision.c:24](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_collision.c#L24).
4. Inside Mario's callback, geometry preparation precedes interaction
   consumption and action execution. `find_floor` narrows X, Y and Z to
   signed 16-bit query coordinates. At the finite values here, 67,277
   becomes 1,741; 63,586 becomes −1,950. It returns a local plane height,
   with no 65,536 offset restored. It takes the first eligible surface in
   each partition's ordered list, then chooses the dynamic answer only
   when strictly higher than the static answer. A valid initial floor
   prevents the graphical retry. See
   [surface_collision.c:401,513](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/engine/surface_collision.c#L513)
   and [mario.c:1313](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario.c#L1313).
5. `find_ceil` narrows its inputs too, but Mario's ceiling wrapper is
   queried at **returned floor height +80**, not his high feet. Its
   no-ceiling answer is **20,000**. Walls differ: narrowed X/Z choose a
   partition, but the actual wall-list tests use raw floating X/Y/Z.
   At Y=67,277 the ordinary local wall vertical bounds reject Mario.
   See [surface_collision.c:20,184,306](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/engine/surface_collision.c#L306)
   and `surface_collision.h:13`.
6. The grabbable interaction's fallback push changes M's X/Z only after
   its corrected destination has a non-null floor. It does not replace
   Mario's cached floor. Here geometry first finds the pad at 768; the
   push destination has the static roof at 1280 when queried with aliased
   Y=1741. This is a fresh cache from the same update, not an old retained
   update. See [interaction.c:616,1635](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L616).
7. `ACT_CRAWLING` checks sliding, first person, A, dive/punch, no-analog
   and Z conditions. It does **not** simply reject `INPUT_OFF_FLOOR`.
   With the tested input it reaches the ground quarter. At the post-query
   cut, local floor 1280, ceiling 20000 and next Y 67277 satisfy
   `nextY > floor+100` and `nextY+160 >= ceiling`. The quarter returns 2
   before committing the proposed position or local floor. The loop
   stops, then copies M to D. Crawl alignment writes M.Y directly from
   cached 768; it does not sweep through the intervening space or change
   X/Z. The Mario callback subsequently copies M into C. See
   [mario_step.c:256–350](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_step.c#L256),
   [mario_actions_moving.c:88,1247](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_moving.c#L1247),
   and `object_list_processor.c:224–276`.
8. Next update, C is near the real warp and within top-loading range.
   Detection records warp overlap. Geometry's low query fails and copies
   **all three D coordinates** into M before retrying. Its high Y narrows
   to 1741 and selects the reloaded top. Interaction then accepts the warp
   using the already detected overlap; `act_disappeared` calls
   `stop_and_set_height_to_floor`, replacing the huge Y with the returned
   local surface height and refreshing D. Final C and platform capture
   agree with that top. See [interaction.c:867](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L867),
   [mario_actions_cutscene.c:430](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_cutscene.c#L430),
   and [platform_displacement.c:22](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/platform_displacement.c#L22).

## Concrete supplied VPU witness

The authenticated 2,548-input four-pillar prefix and neutral waiting reach
stored top timer 130. The prefix includes the already documented pre-entry
level-select setup. The diagnostic then supplies synchronized M=C=D
`(-1950,67277,-939)`, `ACT_CRAWLING`, state/timer zero, forward speed 5,
velocity `(4,0,0)`, yaw `0x4000`, and the existing box 49's XYZ
`(-1989,67277,-939)`. Its behavior, velocity, hitbox and allocator history
are retained. No floor/cache, platform, surface, RNG or collision list is
patched; the inherited floor cache before execution is 1024.

One Z-held stick `(0,64)` update, then neutral input, produces:

| Completed boundary | Native observations |
| --- | --- |
| Global 2681, stored top 131 | M=C `(-1882,768,-939)`; D `(-1882,67277,-939)`; crawl; floor 768; no ceiling, ceilingHeight 20000; box 49 contact; **zero** top surfaces |
| Global 2682, stored top 132 | Warp 64 contact/used object; disappeared; M=C=D `(-1882,1818.9613037109375,-939)`; floor owner and platform 61; **six** top surfaces |
| Global 2705, first completed Area 2 sample | `(365.5927734375,5500,-1096.8026123046875)`, outside the elevator rectangle |

The quarter's local floor 1280 and its return 2 are source/Coq conclusions
under explicit query-cut premises, not values exposed by Wafel's frame log.
Native samples record Mario's cache, ceiling, surfaces and outcome. The
new arrival is a completed-update observation, not a new exact first-apply
breakpoint. The producer still starts at 130 and captures at 131; no warp
countdown edit or earlier-phase payoff is asserted. The historical
131-frees/84-allocations counts are not attached to this new actor history.

## Horizontal PUs, speed and crawl establishment

The primary batch has **21 trials / 616 updates**, with one supplied initial
cut per trial and no later edits. It compares ordinary, +65536 X, +65536 Z,
+65536 Y, and combined X/Y shifts, each with/without a correspondingly
shifted box; VPU start-crawl/crouching/freefall controls with/without the
box; a direct high target; and four supplied speeds. Only the ordinary
and vertical-PU box trials give useful arrivals.

The horizontal-only high cases have no top ceiling. At Y 1741, their local
floor lies over 100 below them and the default ceiling 20000 does not block
the quarter; they leave the ground and become freefall. The combined PU/VPU
case snaps Y to 768 but keeps X 63654. It is not at the real warp, and the
top still does not load. The VPU pad without a box snaps but stays over a
valid low floor, suppressing the needed retry. Supplying the target itself
instead gives a fresh cache 1280 and snaps to 1280, not 768.

Two further **position-only** seeds retain the prefix's action, velocity
and cache, followed by 48 Z/stick updates each. At `(63586,768,-939)`, Mario
enters crawl on update 8 and remains on low aliased terrain. At
`(-1950,67277,-939)` no crawl occurs; final Y is 66168. These demonstrate
local action entry after the stated coordinate grant, not travel into a PU.
Start-crawl and crouching explicitly check `INPUT_OFF_FLOOR`, so simply
pressing Z in the high air does not establish the required crawler. In
the Z-pressed high controls, freefall also transitions to ground pound;
the final action alone should not hide that earlier rejection.

Fast backward crawl is not dismissed. `update_walking_speed` adds 1.1 to
nonpositive speed, caps positive speed at 48, and the stopped-crawl branch
caps only positive speed above 10. The supplied −262144 test ends the
producer at **−262142.90625**, whereas +262144 ends at 10. Neither moves
M's X/Z in that high stopped update. A viable fast-PU proposal still needs
an actual incoming speed/action history and accepted quarter destinations;
rejected quarters do not commit a floorless intended point. See
`mario_actions_moving.c:434–474,1274–1290`.

A pre-existing split with C near the real warp need not bring all three
records home first. Likewise, a failed-floor retry can return M from a PU
if D already names a suitable destination. Neither effect constructs that
earlier split. Relocating the warp itself would require a separate actual
pickup/slot/actor history; a terrain copy is not such a relocation.

## HOLP, release behavior and cloning

HOLP is a floating position in persistent `gBodyStates`. Its ordinary
writer is the held-object render callback. Normal same-area, area-changing
and level-changing object warps call `init_mario`: held/used/ridden pointers
and action are reset, but HOLP is not. `mario_reset_bodystate` does not clear
it either. Instant-warp displacement does not write HOLP; stock SSL Area 1
has no instant-warp table. Thus these transition paths can preserve HOLP
while losing the item. This is a source-path fact, not a verified
cross-level high-HOLP controller history or a claim across reboot/reset.

Acquiring an item later can overwrite HOLP as soon as its held-object
render path is traversed. Hands-free holding, render culling or a suitable
interruption must actually prevent that callback; invisibility by itself
is not a proof. The callback requires a held object/shared child and a
rendered node traversal, and uses floating transforms. A normal held
animation is therefore a serious preservation obligation. See
[mario_misc.c:547–578](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_misc.c#L547),
[rendering_graph_node.c:877–907](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/rendering_graph_node.c#L877),
`mario.c:1530,1788–1855`, and `level_update.c:391–415,554–585`.

Drop copies HOLP X/Z but **Mario's current Y**. Throw copies HOLP Y and adds
`32*sin(yaw)`/`32*cos(yaw)` horizontally. Neither resizes the item. The
source has ordinary SSL jumping boxes and Bob-ombs, so cloning is not
needed for these actor types. The clean eastern-box pickup is an existing
no-new-A component, but it does not preserve a chosen high HOLP. The
[clone lineage review](ssl1-clone-lineage-sizing-review.md) remains relevant
if another species is proposed: a real replacement allocation must occupy
the remembered pickup slot; distance culling does not reallocate the
stock enemy, nor does a new occupant inherit arbitrary size/state.

The six release probes explicitly supply holding, a safe pillar pose,
release action/timer, facing and HOLP. One native held update precedes the
release cut. This avoids accidentally treating the Crazy Box's normal
held-idle bounce as a stationary release. They test two actors with a valid
high throw, a drop using the same high HOLP, and an out-of-bounds throw.
Each retains 12 continuation updates. These are execution tests of supplied
release prerequisites, not acquisition or rendered-HOLP preservation tests.

* **Crazy Box:** HOLP `(-2021,67277,-939)`, yaw 0x4000 produces initial
  thrown X −1989. Its callback makes it free/tangible, sets speed 40 and
  vertical speed 20, and immediately applies gravity −4 and movement,
  giving **Y 67293, vertical speed16**. It queries at release Y+160;
  a real local floor answer leaves the high Y intact. At a null-floor
  destination, the helper instead copies Mario's raw object position,
  defeating the remote placement. Subsequent distant standard movement
  is skipped because `ACTIVE_FLAG_FAR_AWAY` is set, so the valid high box
  waits in the tested history. Its native thrown action is 1; on resuming,
  landing/wall/water events can delete it. This is not an immortal item.
* **Bob-omb:** HOLP `(-2011,67277,-939)` gives X −1979, compensating for its
  smaller hitbox. The distant callback's **4000-unit check uses D**, not
  C. It waits with `HELD_THROWN=2`, intangible timer 0 and fuse timer 1;
  the launched behavior and fuse updates are gated off. The ordinary
  collision/interaction path can still push from this tangible pending
  state; it does not require `HELD_FREE`. On the high-display handoff
  update the Bob-omb's callback finally runs, sets launched action/free
  state, speed 25/vertical20, and advances the fuse. This distinction
  explains why one cannot substitute the top loader's distance rule.
* **Drops:** both use Y 1024 in these supplied low release cuts, despite
  HOLP Y 67277. A low drop cannot remotely manufacture the high actor.

Sources: `interaction.c:288–330`, `mario_actions_object.c:233–270`,
[object_helpers.c:1066–1115,1751–1823](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_helpers.c#L1066),
[jumping_box.inc.c:31–74](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/behaviors/jumping_box.inc.c#L31),
[bobomb.inc.c:183–278](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/behaviors/bobomb.inc.c#L183),
[obj_behaviors.c:496](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/obj_behaviors.c#L496),
and `behavior_script.c:905–1003`.

For each valid throw, the experiment starts its held preparation at stored
phase 110, releases at 111, continues 12 updates including release and waits
seven more to 130. At that second explicit cut it supplies **only Mario's**
high crawling state. There is no actor rewrite after the throw. Both
25-update continuations create the desired split, capture at 131 and arrive
outside the elevator. This joins native release/waiting to the conditional
handoff, while keeping the high HOLP/holding and crawler-production gaps
visible. It does not claim that either actor survived arbitrary travel.

## Coq changes and precise limits

New registered module [InkPuVpu.v](../../proofs/InkPuVpu.v) is consumed by
the stopped-floor boundary in
[InkConcreteProducerBoundary.v](../../proofs/InkConcreteProducerBoundary.v),
and therefore by `MainTheorem.current_ink_concrete_producer_boundary`.

| Checked theorem | What it proves; premises retained |
| --- | --- |
| `ipv_actual_y_conversion_executes` | Executes the actual selected US/JP `find_floor` or `find_ceil` Y-conversion statement. Input temporary must contain binary32 67277; it sets query Y 1741 with identical memory and empty trace. It does not execute the floor lists. Mario's actual ceiling wrapper uses floor+80, as noted above. |
| `ipv_vpu_ceiling_stop_executes` | Constructs execution of the actual US/JP post-water ground-quarter tail from local floor 1280, local ceiling 20000 and a valid next-position load containing Y 67277. It returns 2 without changing memory. No prior execution of that tail is assumed. |
| `ipv_vpu_ceiling_stop_preserves_current_memory` | Every execution of that selected tail under those reads preserves all memory, hence any fresh floor 768, action and positions already present at that cut. Their earlier production remains a premise. |
| `ipv_sample_coordinate_casts_checked` | Checks CompCert casts of the four stated finite PU/VPU coordinates. This is not an arbitrary-float/modulo theorem. |
| `ipv_retry_geometry_connection_checked` | Combines the actual 67277→1741 cast with the existing generated-mesh timer 130/131 handoff certificate. Loader execution and correspondence to the live lists remain open. |

This sharpens the real stopped-quarter branch for the VPU candidate; it
does not replace the producer obligation with an assumed route. The
existing general display/alignment/copy results are reused rather than
reproved. Explicit action, no-A history, fresh-cache, push/query, loader,
phase and allocator premises are not discharged by the local tail or by
`Print Assumptions`. No new axiom or `Admitted` is introduced.

## Reproduction, validation and remaining work

From the SSL directory in PowerShell, the final gameplay commands were:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_pu_vpu.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-pu-vpu-final-20261112.json
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_pu_vpu_prerequisites.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-pu-vpu-prerequisites-v1-20261112.json
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_pu_vpu_verify.py docs/notes/ink-pu-vpu-receipt.json --replay build/wafel-pilot/capture.bKv95w/inputs.jsonl
```

All final commands exit 0. The [receipt](ink-pu-vpu-receipt.json) retains
every supplied write, input, M/C/D sample, action, velocity, floor/ceiling,
top-surface count, actor contact, warp and platform sample; it includes
script/runtime/prefix hashes. The release records distinguish edits before
the held-preparation input from those before release, and separately list
the later Mario-only cut. The validator replays both complete batches
fresh with exact JSON-normalized equality and rejects five deliberately
corrupted receipts. There are 616 primary updates, 96 position-only seed
updates, 72 release-continuation updates, six preparation updates, 14 joined
waiting updates and 50 joined handoff updates. Prefix/phase waiting is
additional. These counts are finite scopes, not all possible inputs.

Exploratory drafts corrected a mislabeled start-crouch constant, separated
Bob-omb held preparation from a distance-gated pointer-only state, avoided
the Crazy Box's held-idle bounce, and adjusted Bob-omb placement for its
smaller hitbox. The retained final scripts and exact fresh replay are the
reported evidence; the preliminary reports remain ignored build output.

The toolchain was rechecked: Ubuntu WSL, `sm64-item-proof`, Coq 8.16.1,
CompCert 3.15, unchanged 6815744 KiB memory cap. Commands run through
`wsl.exe -d Ubuntu -- bash -lc` inside the SSL directory:

```sh
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/InkPuVpu.vo
bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 \
  LessThanOneAPress.Proofs.MainTheorem current_ink_concrete_producer_boundary \
  LessThanOneAPress.Proofs.InkPuVpu ipv_pu_vpu_boundary_checked
```

Baseline selected audit `20261112-095628-5yg_mh8v` passes. The targeted new
module and integrated MainTheorem build pass. Final selected audit
`20261112-100741-lgwlgqtb` **passes, exit 0**: 716 sources, zero inventory,
proof-hole, link or integration problems; 550/636 proof modules in the
MainTheorem import closure, 86 standalone-only. Both queried boundaries use
seven existing allowed foundations. See the [audit summary](ink-pu-vpu-audit-summary.txt).
An initial missing
module build invocation and a missing Boolean parameter annotation were
corrected before these successes. No bare `coqc` or whole-program reduction
was used.

The consequential next questions are:

1. Can an action-preserving, no-new-A history create **high established
   crawl**? Starting ordinary crouch/crawl in high air fails the off-floor
   guard; low horizontal-PU crawl is not the missing high state.
2. Can play set HOLP near the required 67k height and preserve it through
   transition, pickup and throw? The local release tests grant those
   conditions; a headless field test does not validate rendered HOLP
   preservation. An original-JP replay would be appropriate once such a
   producer is identified.
3. Can those components be joined to the four-pillar history at 130 with
   the actual item/allocator state intact? The successful conditional
   continuations establish a target, not that joint controller history.

Verdict: **useful new conditional VPU lead; bounded horizontal-PU failures;
no continuous no-new-A Ink route and no all-history exclusion.** The atlas
estimates remain Rank 1 **1–2%**, Ink Rank 2 **<1%**. The local atlas and site
source are updated; commit and push are authorized by the follow-up.
Deployment of these site changes remains withheld.
