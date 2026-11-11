# The 973-unit candidate: timer 130 and the first crawl quarter

The later [producer search](ink-973-producer-search.md) establishes local
no-A crawl entry from a supplied roof position and removes unnecessary
shell/velocity setup, but still leaves the high crawl and actor delivery
unproduced. It does not change the conditional Coq results below.

This follow-up starts from `fc5a2c0db663d7f5ec81b3efde4782485d7062a5`, a
descendant of `ee8ba92`, on `codex/ssl-pyramid-item-proof`. It extends the
[installation-handoff review](ink-installation-handoff.md). The user initially
requested source and saved records only, then authorized new gameplay
experiments and state searches. The source certificates below remain distinct
from the newly supplied runtime fixture and illustrative ROM screenshots.

## Answer for the manual

The first crawl quarter **can stop without replacing the Y=768 cache**. The
useful obstacle is the underside of the moving top. At timer 130, the top's
sloping upper face is too high for a floor query from Y=1741, but its flat
underside is at Y=1523. After the proposed push, the local floor query selects
the static roof at Y=1280. The ceiling query starts at that returned floor
height plus 80, or 1360; it does not start at Mario's 1741. It can therefore
return the underside even though Mario is already above it. The high-gap
branch then returns the stopped result before writing either the new floor
or the proposed quarter position into MarioState.

This is precisely the distinction the candidate needs: the local floor
answer 1280 and Mario's remembered floor 768 are different records. A first
stopped quarter ends the ground-step loop. The display refresh uses the still
high movement position, then crawling's alignment snaps movement to the
remembered 768. The resulting vertical separation is 1741−768=973.

The finite geometry and actual generated-code tail are checked separately.
They do not yet form a whole-update Coq execution proof. A new supplied-state
Wafel replay also realizes the handoff and subsequent useful warp; it supplies
the already-high crawling state and shell placement. It does not show how to
produce those prerequisites with controller inputs from the accepted start.

## Timer 130 geometry, with the rounding kept

The existing spin recurrence executes the 71 updates numbered 60 through 130.
The source-derived pose has yaw `0x9400`, angular velocity 6144, center
`(-2047,1778.071044921875,-1023)`. The origin is not a floor height.
The matrix calculation uses binary32 operations and the actual signed-16
vertex casts. Its resulting stored vertices are:

```text
0 (-1837,1523,-1715)   1 (-2257,1523,-330)
2 (-2739,1523,-1233)   3 (-2047,2034,-1023)
4 (-1355,1523,-813)
```

The sine-table samples are certified against both generated US and JP
initializers. The normal/plane calculation then uses these stored vertices,
not an ideal unrounded pyramid or its object origin.

| Query point | Eligible static floor | Timer 130 top floor | Top face (1,4,3) height |
| --- | --- | --- | --- |
| `(-1950,1741,-939)` | pad 768, face (498,500,501) | none |1914.344482421875|
| `(-1882,1741,-939)` | roof 1280, face (261,263,264) | none |1882.29443359375|
| `(-1881,1741,-939)` | roof 1280, same face | none |1881.8231201171875|

All three points lie horizontally within the named top face, but its height
exceeds the query's 78-unit acceptance buffer: 1741+78=1819. The same three
points are under underside face (0,4,1), whose loaded plane has height 1523.
The high candidate therefore lies between the top's underside and upper
surface, not standing on its upper face. An ordinary rendered view may hide
Mario inside the top; the screenshots must be read with that geometry in mind.
The signed-32 ceiling edge tests all pass. Its source surface type 53 is not
the camera-boundary/no-camera type.

At the initial pad location, the ceiling query from floor 768 starts at 848.
With ceiling 1523, the cached ceiling/floor separation is 755, greater than the
150-unit squish threshold. This removes that particular numerical squish
obstruction under the stated query results; it does not prove every action
guard or exclude another live ceiling. At the pushed location and the +1X
sample, the ceiling query starts at 1280+80=1360 and also accepts the 1523
underside.

These are finite source-mesh query certificates. Live matrix freshness,
surface loading, list traversal and competing objects are not supplied by
the certificates. The runtime fixture below tests one actual configuration.
The next-phase certificate also checks that the target's low 768 query misses
both the static floor and the timer 131 top, whereas display 1741 accepts the
timer 131 top. Thus the preceding update's fresh low cache and the following
update's low miss are geometrically compatible.

The new replay observes that timer 131 top floor at 1818.9613037109375:
just below 1741+78=1819. The top's origin rises by 5 between phases 130 and 131,
but its rotation and horizontal translation lower the face at this particular
X/Z from the certified timer 130 height 1882.29443359375. Origin height alone
would miss this change. The stored display can therefore become a successful
retry point one update after the high movement query rejected the top.

Sources: [timer 130 pose and transform](../../proofs/InkTimer130Geometry.v#L44),
[floor and ceiling certificates](../../proofs/InkTimer130Geometry.v#L99),
[low-query and next-phase checks](../../proofs/InkTimer130Geometry.v#L157);
`InkNearbyFloorGeometry.v`; `Timer131Surface.v`;
decomp `src/game/behaviors/pyramid_top.inc.c:32–64`;
`src/engine/surface_collision.c:226–351`.

## Why the first quarter preserves the cache

The relevant order is geometry preparation → object interactions → moving
action dispatch → crawl quarter → ground display refresh → crawl alignment
→ later collision copy. A cached 768 from an earlier update is insufficient:
geometry preparation overwrites it before the interaction. The replay starts
with a different inherited cache and observes the game replace it with 768.

The source computes the first intended horizontal step from the current
cached floor's normal and the velocity after `update_walking_speed`. With
normalY=1 and post-speed velocity (4,0), the example quarter is
`(-1881,1741,-939)`. The Y coordinate is copied from movement, not from the
cached floor height. This velocity is a stated sample, not a proved
controller-reachable speed or a requirement that every successful trial has
exactly this velocity.

After wall corrections, the quarter obtains its own local floor, ceiling and
water results. At the selected post-water cut, local floor 1280 and ceiling 1523
give:

```text
1741 > 1280 + 100     true: use the high-gap branch
1741 + 160 >= 1523    true: return GROUND_STEP_HIT_WALL_STOP_QSTEPS (2)
```

That selected tail has no memory writes. In particular, if the current
MarioState cache is 768 there, it remains 768; local 1280 is never installed.
The actual generated loop gate breaks on result 2, so quarters 2–4 do not run.
The actual generated ceiling wrapper calls `find_ceil` at floorHeight+80.
Querying instead at movementY+80 would give 1821 and reject the underside;
that tempting objection uses the wrong argument.

The existing stopped-crawl proofs connect reached ground refresh, return,
result 2 handling and the first alignment snap. The new theorem does not
frame away the preceding wall, floor, ceiling or water calls, establish the
high crawling state, or complete the whole matrix/action/copy continuation.
Those remain Coq composition obligations even when one runtime fixture
observes the complete sequence.

Sources: decomp `src/game/mario_step.c:258–346`,
`src/game/mario.c:547–549,1314–1370`,
`src/game/mario_actions_moving.c:88–94,1247–1301,1953–1987`;
[selected tail execution](../../proofs/InkCrawlQuarterHandoff.v#L106),
[memory preservation](../../proofs/InkCrawlQuarterHandoff.v#L152),
[ceiling-query and quarter source](../../proofs/InkCrawlQuarterHandoff.v#L223),
[loop break](../../proofs/InkCrawlQuarterHandoff.v#L313);
`InkStoppedCrawlAlignment.v`. The exact high-gap stop is at
`src/game/mario_step.c:287–289`, the loop break at lines 327–335, and the
floorHeight+80 wrapper at `src/game/mario.c:547–549`.

## New supplied-state replay

The [replay note](ink-timer130-crawl-replay.md),
[receipt](ink-timer130-crawl-receipt.json) and
[script](../../instrumentation/wafel-jp-pilot/ink_timer130_crawl.py) record six
bounded trials in the pinned Wafel 0.8.5 JP library. This new shell setup has
not been replayed on the original ROM; the screenshots below are separate
visualizations. The inherited controller prefix has the existing original-JP
comparison, with its documented global-timer offset.

After the four-pillar prefix, the script sets the stock shell box's action
to 4 at top timer 128. The ordinary behavior spawns and initializes a real shell
in slot 126 over two updates. Each restored trial then supplies synchronized
high Mario positions, established crawling, action state/timer 0, forward
speed 5, velocity (4,0,0) and yaw 0x4000. The four shell trials additionally
supply shell position `(-1971,1741,-939)` and zero its velocities. They give
one Z-held cardinal-stick update, then at most 28 neutral updates. No A is
pressed. All these writes, with previous values, are in the receipt. No
floor/cache, surface, platform, collision-list, RNG or allocator pointer is
patched. The inherited floor height is 1024, not 768.

All four shell trials succeed. For the first trial, Z plus stick (0,64):

| Wafel boundary | Observed result |
| --- | --- |
| Before update, global 2680 / stored top timer 130 | M=C=D `(-1950,1741,-939)`, cache 1024 |
| Action-entry event during that update | Crawling at `(-1882,1741,-939)` after the shell push |
| Ground movement events | One `FLT_BEGIN_MOVEMENT_STEP` event, type 2/step 1; no wall-push event |
| After update, global 2681 / stored timer 131 | M=C `(-1882,768,-939)`, D `(-1882,1741,-939)`, floor 768, crawling |
| Next update, global 2682 / stored timer 132 | Disappeared; warp slot 64 used; top slot 61 owns both floor and platform; floor 1818.9613037109375 |
| First sampled inactive top, global 2702 | Top inactive, still remembered as platform |
| First sampled Area 2, global 2705 | `(365.5927734375,5500,-1096.8026123046875)`, outside the elevator rectangle |

Here “timer 130 update” names the update starting at stored timer 130; the
completed update stores 131. These Wafel globals must not be substituted for
the original emulator's poll labels. Area 2 is an after-update sample, not a
new call-level first-apply breakpoint. The new shell changes allocation
history; no 131-frees/84-allocations claim is attached to this run.

This uses timer 130 to **produce the split**, followed by the familiar timer
131 installation. It is not an earlier-phase warp payoff and does not revise
the scope of the old phase-screening receipt. It does show that this supplied
handoff can meet the known useful acceptance phase with its changed actor
history, rather than merely assuming that the timing will fit.

The first trial's observed final velocity is
`(3.9231410026550293,0,-0.7803612947463989)`, not the illustrative (4,0,0).
Using it in the first-quarter expression gives the calculated binary32
position `(-1881.0191650390625,1741,-939.195068359375)`, whose integer query
is `(-1881,1741,-939)`. This matches the finite geometry sample. The other
stick directions also work but can use integer Z=−938. The calculation is
not a hooked observation of the intended-position local. Wafel's log also
does not expose the local floor/ceiling answers or quarter return code;
local 1280/1523 and return 2 come from the independent source argument and its
explicit Coq hypotheses. The observed stored ceiling 1523 is a MarioState
field from geometry preparation. The pinned event decoder does not establish
the C hook's insertion point; the single movement-event count alone is not
a proof that precisely one quarter ran. The actual source loop-break theorem
provides that conclusion conditionally on first-quarter result 2.

Both controls restore the same released-shell state, but leave the shell
far away. Supplying the high pad alone gives M/C 768 and D 1741 at X=−1950:
the next low query still finds the pad, no top capture occurs, and Area 2
arrival is ordinary `(0,5500,256)`. Supplying the high target directly gives
a fresh cache 1280 and snaps to 1280; no top capture or Area 2 entry occurs
within 28 updates. These controls distinguish the necessary ordering:
obtain the low cache at the pad, then push outside its footprint within the
same update. Neither control is an all-input exclusion.

The supplied-state handoff has therefore been realized, including an
ordinary shell interaction and action continuation. The remaining clean
producer must create the high crawl and deliver the shell with the right
timing without these edits.

## Original-ROM views

The [candidate-view gallery and reproduction note](ink-timer130-candidate-views.md)
show the high pad, pushed high point and low target against the timer 130/131
top. These are native original-JP ROM renderings with supplied graphics
positions and camera, not a second execution of the Wafel shell handoff.
Normal views retain the solid top; explicitly labeled cutaways hide its
render node so Mario is visible. The low camera is placed inside the pyramid
to reveal the target beside the shaft. The warp object has no visible model:
its center is `(-2048,768,-1024)`, making the low target 166 units away in X,
85 in Z and at the same Y. Its horizontal distance is about 186.497, just
inside the stock combined radius 187. The high target is 973 units above it.

The first capture attempt revealed a one-frame screenshot delay. The final
capture holds each pose for three render callbacks before requesting its
image; the current and previous completed images therefore have the same
pose and camera. The gallery records image hashes, exact render edits and
phase mapping. No screenshot is used to prove a physical floor query,
collision, crawl action or controller-produced state.

## Checked Coq claims and their premises

| Theorem | Result and scope |
| --- | --- |
| [i130_geometry_checked](../../proofs/InkTimer130Geometry.v#L225) | Source-derived pose, exact generated trig samples, binary32 transform/signed-16 vertices, the three static/top floor samples, underside edge/plane/buffer checks and low 768→high 1741 next-phase query geometry. No live loader, actor, timing or allocator execution premise is discharged. |
| [icqh_973_ceiling_stop_executes](../../proofs/InkCrawlQuarterHandoff.v#L106) | Constructs an execution of the actual selected US/JP post-water tail from the actual local bindings floor 1280/ceiling 1523, a valid nextPos pointer and a load of nextY 1741. Returns 2, empty trace and identical memory. No execution premise for this tail, but reaching it with those locals and the required cache remains a premise. |
| [icqh_973_ceiling_stop_preserves_current_memory](../../proofs/InkCrawlQuarterHandoff.v#L152) | Every execution of that tail with the same bindings/load returns 2 with identical memory. Any action, floor pointer, cached 768 or position load present at that cut is preserved. |
| [icqh_selected_ceiling_query_source](../../proofs/InkCrawlQuarterHandoff.v#L223) | Identifies the selected generated ceiling-wrapper call and its floorHeight+80 argument. |
| [icqh_one_unit_expression_evaluates](../../proofs/InkCrawlQuarterHandoff.v#L288) | Evaluates the actual horizontal source expression to −1881 from loaded position −1882, normal 1 and velocity 4. Those local values are explicit hypotheses. |
| [icqh_recorded_quarter_calculation_checked](../../proofs/InkCrawlQuarterHandoff.v#L359) | Evaluates the supplied receipt velocity words in the binary32 quarter expression and checks signed-16 casts to X=−1881/Z=−939. This checks the calculation; it does not turn the calculated local vector into a runtime observation. |
| [icqh_result_two_executes_break](../../proofs/InkCrawlQuarterHandoff.v#L313) | Constructs the actual generated result 2 loop-break gate execution, with no memory change. |

Both new modules are registered in `_CoqProject`. Their proved propositions
are consumed in `InkConcreteProducerBoundary` and exported through
`MainTheorem.current_ink_stopped_floor_producer_boundary` and the existing
backward boundary. No new project axiom or admitted proof is introduced.
The refinement is a concrete, source-supported stopping mechanism on the
existing boundary, not a replacement of the open producer by its conclusion.

## Checks and remaining obligations

The runtime command, executed from the SSL project in PowerShell, was:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_timer130_crawl.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-timer130-crawl-20261111.json
```

Exit 0: all four shell trials and both controls passed their assertions. The
compact receipt was independently reconstructed from the raw report and
matched exactly; this check did not rerun gameplay. The receipt includes
script, raw-report, baseline and pinned-runtime hashes. The full raw report
remains in ignored build output.

The active pipeline uses Ubuntu's `sm64-item-proof`,
Coq 8.16.1 and CompCert 3.15, with the established 6815744 KiB memory cap.
The following commands run inside the SSL project through
`wsl.exe -d Ubuntu -- bash -lc`:

```sh
bash pipeline/build.sh audit-build \
  AUDIT_VO_TARGETS='proofs/InkTimer130Geometry.vo proofs/InkCrawlQuarterHandoff.vo'

bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 \
  LessThanOneAPress.Proofs.MainTheorem current_ink_backward_execution_boundary \
  LessThanOneAPress.Proofs.InkRetryQuery irq_retry_connects_display_to_real_floor_call \
  LessThanOneAPress.Proofs.InkVerticalRetryGeometry ivr_vertical_retry_geometry_checked \
  LessThanOneAPress.Proofs.MainTheorem current_ink_stopped_floor_producer_boundary \
  LessThanOneAPress.Proofs.InkTimer130Geometry i130_geometry_checked \
  LessThanOneAPress.Proofs.InkCrawlQuarterHandoff icqh_crawl_quarter_handoff_checked
```

The final targeted build exited 0, as did both new modules' separate
`pipeline/assumptions.sh` queries. The baseline selected audit
`build/audit/20261111-093933-cgoh0el8` also passed before the additions.
Final integrated audit `build/audit/20261111-101337-jsfng940` **passed, exit0**.
The [saved summary](ink-timer130-audit-summary.txt) records706 registered
sources,540/626 proof modules in the main import closure,86 standalone
modules and zero inventory/integration problems. Build, proof-hole scan,
generated link hygiene and all six assumption checks pass. Foundation
counts in command order are9/7/4/7/4/7, all from the allowed Coq/CompCert
libraries; no project axiom or admitted proof appears. This is the selected
MainTheorem/dependency audit, not a full build of every standalone module.
Explicit theorem premises remain distinct from foundational assumptions.

The earlier integrated invocation `20261111-095933-np6qk3q4` was interrupted
after its build and first two assumption checks passed; it has no final
verdict. The fresh completed audit above is the reported result. Its command
was unchanged, with console and exit status also retained under ignored
`build/ink-timer130-final-*` files.
Early proof-script/type/import errors and an expensive direct Float32
equality were corrected before the final targeted success. Bit equality
avoids the large floating-point proof-term expansion. No bare `coqc` or
whole-generated-program reduction was used.

The outstanding gameplay producer must supply the high established crawl,
the usable shell's position and state, the contact and input timing, and the
appropriate fresh cache without direct state edits. The formal composition
must connect actual live geometry and every intervening call to the stopped
tail and later display/alignment/copy. A complete lifecycle proof must retain
actual explosion/freeing/allocation/first-apply facts for the chosen history;
the old timer 131 allocation counts are not generalized to the new shell
fixture. No all-history exclusion or clean no-A route follows. The atlas's
subjective estimates remain Rank 1 **1–2%**, Ink Rank 2 **<1%**.
