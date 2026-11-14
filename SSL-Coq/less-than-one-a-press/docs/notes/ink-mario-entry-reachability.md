# Can gameplay supply Mario's Ink handoff state?

14 November 2026. **A usable no-new-A Mario-side entry remains open.** The
existing supplied-state handoff is reproducible on the original Japanese
ROM, but producing a high ground action is only part of the problem. Its
next update must refresh the low pad floor, then cross the pad edge without
losing the alignment path. A large gap over the pad still takes the ordinary
warp. Actor delivery and joining its timing to Mario remain separate open
questions; neither is assumed solved here.

This investigation began at proof commit
`921e4d1954d79f3b4deb6958c88419a8f4bd5a28`. Fetching
`fork/codex/ssl-pyramid-item-proof` found no newer pushed work. Existing local
changes to `CLAUDE.md`, the platform-reset makefiles and ignored build output
were preserved. The earlier entry, top-slide and walking-edge studies were
already preserved at `5858649`; the later slide/height investigation and six
original-ROM video cases were read before choosing new searches.

The relevant decompile checkout is
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, with existing local changes.
Each new experiment pins its applicable source and runtime hashes. Wafel
uses the existing 0.8.5 JP DLL, SHA256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
Original-ROM controls use JP SHA256
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`,
Mupen64Plus2.5.9 interpreter/Rice2.5.9/HLE-RSP2.5.9 in Ubuntu-24.04.
The accepted four-pillar prefix retains its disclosed pre-game debug
level-select startup. New suffixes have A released, without a held-A
dependency; supplied state writes remain distinct from controller input.

## What the action names do and do not establish

These are actual source paths, not a substitute physics model. M denotes
`MarioState.pos`, C the object's collision position and D `header.gfx.pos`.
D is not the rendering matrix or a claim about where the model is drawn.

| Situation | Applicable code and consequence |
| --- | --- |
| Ordinary crouching or crawl startup more than100 above a found floor | `act_crouching`, `act_start_crouching` and `act_start_crawling` reject `INPUT_OFF_FLOOR` before their ground step. Pressing Z in arbitrary freefall instead selects ground pound. |
| Already established crawl, physically high above a nonnull floor | `act_crawling` has no direct OFF_FLOOR rejection. Its sliding, first-person, A, attack, idle-input and Z-release guards still apply. Reaching the ground step is a separate question from retaining the action ID. |
| Walking with Z | Earlier walking cancellation/sliding guards take priority; otherwise Z selects crouch-slide without first rejecting OFF_FLOOR. Crouch-slide redirects to butt-slide on the slippery-floor flag. Native slide-velocity preparation matters; editing only walking's action ID and forward speed is not equivalent. |
| Landing-dependent remote sliding | `common_landing_cancels` checks steepness and sliding before OFF_FLOOR. This requires an actual landing-action predecessor. Arbitrary freefall does not directly call it. |
| Actual supported ledge departure | A ground quarter that accepts a new floor more than100 below the feet, with the ceiling allowing departure, returns LEFT_GROUND. Crawl selects freefall; the shared slide helper selects its air action. Those branches skip floor alignment. |
| Failed quarter after the earlier cache was refreshed | A stopped quarter can preserve that cache. The ground-step graphics copy occurs before the caller's alignment. The common slide's wall/bonk branch still aligns even if it changes action first. This is why a box shove is not equivalent to ordinary ledge departure. |
| First floor query misses | Geometry retries at stored graphics. This can still find a nonnull floor; a first miss is not an action-dispatch stop. |
| Floor is still NULL after interactions | `execute_mario_action` returns before action dispatch. Its action ID can remain unchanged while none of the ground-step/alignment code executes. The new generated-code execution proof covers this exact gate, not every earlier floor-loss history. |
| Shell hit from above, then Z | Interaction processing can put airborne Mario in riding-shell-ground; action dispatch then enters crouch-slide in the same update. But successful mounting terminates the interaction loop before the later grabbable handler. |

The common slides are butt, stomach, crouch and their applicable holding
variants; dive-slide has extra grab/stop guards. Slide-kick-slide has a
separate handler without this alignment call. Airborne slide-looking actions
must not be counted as executing the grounded helper. The previous
[slide-source note](ink-slide-source-proof.md) records those distinctions.

Source anchors: `mario.c:1314–1370,1699–1738`;
`mario_actions_stationary.c:528–562,693–713,743–766`;
`mario_actions_moving.c:775–825,1203–1230,1247–1301,1359–1585,1758–1790`;
`mario_step.c:258–346`; `interaction.c:84–115,1455–1485,1780–1797`.

## Work backward from the useful update

The exact original control remains M=C=D `(-1950,1741,-939)` with box
`(-1989,1741,-939)` before top behavior130. Its initial cache is inherited
as1024; the game refreshes it to768. The actor then pushes M toX−1882. The
stopped quarter retains768, D records1741, and alignment places M/C at768.
Behavior131 accepts the real low warp and the high retry selects the top.
The final useful Area2 arrival is `(365.5927734375,5500,-1096.8026123046875)`.

The useful local requirements are narrower than “Mario must be crawling at
1741,” but stronger than “a high ground action exists”:

1. At the producer's geometry-preparation stage, actual X/Z and queried Y
   must select the low pad rather than the top, with other cancellation
   conditions permitting the intended action path.
2. After that cache refresh, a real displacement must cross into suitable
   floorless X/Z for the next low query. An actor must overlap at its actual
   coordinates, and its handler must actually run. Collision-list membership
   alone is insufficient.
3. A crawl/common-slide call must reach ground stepping and the alignment
   branch. Its quarter must preserve the low cache; an accepted LEFT_GROUND
   result, early slide stop or another action dispatch defeats this path.
4. The resulting low C must overlap the real warp, while retained D must
   qualify for the next top query. Top loading, accepted warp, platform
   capture/retention and useful Area2 timing must all follow in the same
   history.

These are a source-guided search interface, not a newly proved universal
sufficient-condition theorem. Live calls, binary32 values and continuation
are checked in each retained experiment. The initial cache cannot simply be
borrowed from the preceding frame: native geometry refresh overwrites it.

The [height map](ink-height-map.md) supplies useful targets: default integer
crawl1741–1803, butt-slide1741–1801, both21778–32767, and a changed push that
works at1740. They are specified-fixture windows, not exhaustive bounds on
all positions. The new supported-top work varies X/Z and height together;
it does not restrict predecessors to the exact1741 pose. The high second
window and positive VPUs still require an actual high Mario and actor.
Aliasing a floor query does not move either actor or warp.

## A specific airborne shortcut tested through Area2

The new [shell/box experiment](ink-airborne-shell-entry.md) asks whether a
shell can create the ground action and the usual Crazy Box can then supply
the shove. Eight Wafel supplied-freefall trials and two butt-slide controls
atY1741/Y67277 reproduce across310 boundaries from two fresh game instances.

| New original-JP replay atY1741 | Producer M/C | Stored D | Next warp and arrival |
| --- | --- | --- | --- |
| Exact supplied crawl control | `(-1882,768,-939)` | `(-1882,1741,-939)` | Top captured/retained; useful displaced Area2 |
| Supplied freefall + shell + Z | `(-1950,768,-939)` | `(-1950,1741,-939)` | Static pad, no top capture; `(0,5500,256)` |
| Same freefall + shell + Z + Crazy Box | Same as shell alone | Same as shell alone | Same ordinary arrival |

All three original-ROM checks pass, with159 retained end-update observations
in total. The shell controls genuinely execute riding-shell-ground and
crouch-slide in Wafel's within-update action events; the JP wrapper observes
the resulting native endpoints. The interaction-order explanation is source
evidence, not a newly installed original-ROM interaction-return hook.

The first exact failure of the combined shortcut is **no horizontal shove**.
The successful shell handler returns nonzero, ending the interaction loop
before the Crazy Box handler. The next low query still finds the pad, so the
high stored coordinates are not used for top selection. Delaying Z one
update instead produces backward ground knockback in the Wafel controls;
the later shove occurs, but that handler has no slide alignment. Box without
shell pushes correctly, but freefall+Z gives ground pound. This rejects the
named combination, not all multi-frame shell histories or all actor types.

Every original-ROM write and input is retained under
[`instrumentation/jp-ink-mario-entry/`](../../instrumentation/jp-ink-mario-entry/README.md).
In shell modes, shell-box slot32 action4 is supplied at128, then native
updates spawn the shell. At130 Mario's pose/freefall/velocity/facing and the
shell XYZ are supplied; the combined mode also supplies box XYZ. No floor,
platform, top phase, RNG or collision surface is edited. A-off suffixes alone
do not make those setup writes controller-reachable.

## A closer predecessor: land, slide, shove, then make the gap

The new [supported-slide preparation](ink-supported-slide-preparation.md)
removes the supplied ground action. It starts before behavior128 with only
an exterior FREEFALL seed: M=C=D `(-1930,1837.8726806640625,-880)`, yaw0,
forward speed20 and velocity `(0,-16,20)`. All subsequent controller input
is neutral, with A released. The initial airborne pose remains supplied;
this is not a route from an ordinary game start.

| Update | Native result | First relevant condition |
| --- | --- | --- |
| 128 | Lands at `(-1930,1839.883544921875,-875.0875244140625)`, FREEFALL_LAND, platform61 | A real floor and native landing establish the predecessor. |
| Before129 | Actor-only cut places box49 at `(-1857.8465576171875,1839.883544921875,-940.83349609375)` | No Mario writes after the initial airborne seed. This late box placement is supplied. |
| 129 | Native landing cancellation enters BUTT_SLIDE; M reaches `(-1946.9049072265625,1874.9208984375,-1000.1429443359375)` | The cached floor still belongs to the top, but the end-update platform query returns NULL. |
| 130 | M=C Y768, D Y1874.9208984375, gap1106.9208984375 | The game creates the fresh low cache and executes the slide alignment. |
| 131 | Real low warp accepted, static pad floor selected | **First failed handoff condition:** the low query still finds the pad. It never needs the high graphics retry; no top/platform is captured. |

An independent original-JP ROM run reproduces this fragment, including the
native landing and slide action IDs, cached top owner, cleared platform,
fresh low cache, gap and ordinary Area2 arrival `(0,5500,256)`. Its53
retained end-update observations and all22 writes are archived as mode4 in
the JP instrumentation folder. The19 initial Mario writes and3 later box
position writes are disclosed individually. Internal landing-cancel control
flow is supported by source and Wafel events; no new JP internal hook is
claimed. There is no held-A dependency; all later controller input is neutral.

### Can the box be placed before Mario lands?

**Yes for this verified fragment, with a lower placement.** Before128, place
box49 at `(-1857.8465576171875,1716.883544921875,-940.83349609375)`, at the same
cut as the exterior airborne Mario seed. The box keeps its existing native
behavior, velocity and collision state. There are no later Mario or actor
writes. Its Y becomes1725.337646484375 after128, avoiding the early shove,
then1729.791748046875 after129 when its overlap provides the required push.
Mario's landing, slide, gap and ordinary warp match the late-placement case.

This version also passes an independent original-JP replay (mode5), with
all22 writes before128 and53 subsequent observations. The Wafel refinement
tests97 early-placement candidates, with six gap/ordinary-warp successes and
zero top captures; nine selected histories reproduce264 boundaries across
fresh boots. The six working initial box Y values are1716.883544921875
through1721.883544921875 in increments of1, not an asserted continuous interval.
Putting the box early at the former Y1839.883544921875 fails because it pushes
Mario before landing.

This removes the **late actor placement** requirement for the fragment.
It does not yet demonstrate a HOLP throw. A throw must supply the appropriate
actual position, behavior/held state, velocity and arrival time; writing XYZ
onto an already moving native box does not establish those conditions for a
thrown box. High HOLP, holding and an allowed delivery history remain separate
obligations, as in the existing [item-delivery study](ink-pu-vpu.md).

This is closer than the independently screened supplied-ground-action
states. Those four finite menus contain265,958 candidates/797,874 updates
and no immediate top capture. A further432-case vertical contact refinement
also finds none. They vary direct real-top slide seeds, first pushes and
different actor types; they are neither controller routes nor a global
negative result. The [runtime note](ink-mario-entry-runtime.md) preserves
recipes, coverage, retained continuations and independent fresh reconstruction.

The native-landing study separately screens2736 initial airborne seeds,
of which2077 reach an eligible native ground action; its first fixed-target
menu gives no low-pad gap. The six-case position refinement finds the
fragment above. Its retained histories reproduce186 boundaries from fresh
boots, in addition to the coarse retained control's33. The97 earlier-box
recipes are the later, separate actor-timing refinement described above.

One refinement gives an additional warning about the exact target: a tiny
second shove leaves low producer X=-1934.584, outside the raw pad edge, but
the following geometry update resolves walls **before** its floor lookup.
Low Mario moves back to X=-1995 and finds the pad anyway. The required
floorless position must survive that wall resolution; crossing the raw pad
boundary alone does not establish the retry condition.

## What the new Coq code settles

[`InkMarioEntryGuards.v`](../../proofs/InkMarioEntryGuards.v) uses the actual
generated JP/US Clight bodies. `imeg_null_floor_bypasses_action_dispatch`
constructs the real return from a post-interaction NULL floor; the paired
`imeg_null_floor_forces_return_before_dispatch` forces every completed
execution of that suffix to return0 with unchanged memory. The preparation
composition retains actual reset/input/special-floor/interaction executions.
Its explicit premise is NULL **after** those effects, not an earlier failed
query or an assumed reachable history.

The LEFT_GROUND certificate checks the actual crawl/common-slide switch and
extracts the executed air-action request before its break. It skips the
caller's direct floor-alignment branch, without assuming arbitrary callees
preserve memory or proving an unexamined final action field. Thus a proposed
producer must show a stopped/non-left-ground result or another mechanism.
Neither statement excludes distant nonnull floors, late actor pushes,
later recovery, other handlers, or all no-A routes. The
[proof note](ink-mario-entry-proof.md) gives exact theorem premises and audit.

The targeted module build and selected pipeline audit
`20261114-001616-kb9nz9q4` pass under Coq8.16.1/CompCert3.15, with the
unchanged6.5GiB memory limit. The four selected assumption checks report
9/7/4/7 allowed existing foundations; the new boundary uses7. Inventory,
proof-hole, link and integration checks pass:718 sources,552/638 proof
modules in MainTheorem's import closure,86 standalone-only,zero problems.
This is a selected build, not an all-module full build; no new axioms or
Admitted declarations were added. The five original-ROM replays retain265
end-update observations and checked setup/input/source receipts.

## Separate verdicts and the next experiment

| Obligation | Current verdict |
| --- | --- |
| Mario reaches a usable handoff state | Open. Native landing can now supply the slide and later large gap in the same fragment, with no high ground-action write. The initial airborne approach is still supplied, and the resulting X/Z fails the retry condition. |
| A usable actor is delivered there | Open. Earlier box placement works without later edits, but that placement and its inherited moving state are supplied; a HOLP throw has not been connected. |
| Both join at the right phase and yield useful Area2 displacement | Open. All new landing fragments reach the ordinary warp. The useful supplied crawl control still works. |

The closest verified predecessor is now mode5: exterior freefall, native
landing, native slide, early moving box, fresh low cache and large gap, all
with neutral input after one initial setup cut. Its first missing handoff
condition is the low floor query still succeeding on the pad at X/Z near
`(-1946.904907,-1000.142944)`. The most useful next experiment is a small,
phase-aware perturbation of this **native landing plus earlier box** history,
targeting a position that stays floorless through the next wall resolution,
after the low-cache refresh while retaining stopped-quarter alignment.
Promising cases must continue through capture
and Area2, not stop at a larger gap. In parallel, a true earlier HOLP release
must be tested for the actor's resulting velocity/behavior and timely
overlap, instead of replacing it with an XYZ placement. Neither the already
negative supplied-ground-action grids nor the old fixed timer113 search
exhausts these joined histories.

## Relation to earlier investigations

The later [collision-only actor follow-up](ink-collision-clone-runtime.md)
does not repair the missing handoff. A supplied carry-script override freezes
the Crazy Box's XYZ while leaving its hitbox and grabbable interaction live.
The low fixed box misses the later contact; raising it interferes with the
landing. A 1,030-recipe four-update Wafel screen finds no intended phase131
top capture, including horizontal timing variants. The six retained frozen
controls remain in Area1 through33 updates without the large gap or capture.
This is finite diagnostic evidence, not a gameplay-created clone or universal
exclusion. The [source note](ink-collision-clone-source.md) distinguishes the
ordinary HOLDABLE Crazy Box path from inert non-holdable carry scripts.

The requested third film was cancelled before any new files, render or
publication were created. The user correctly identified that an ordinary
warp without spawning displacement is not the desired result. The fragment's
limited value is native action-entry evidence after a supplied airborne seed;
it must not be presented as a working Ink installation or useful route.

The old behavior112 exterior-freefall seed already lands on the top at113,
slides at117, and has extensive slide-to-crawl and walking-edge searches.
Those searches are credited in [the earlier slide study](ink-top-slide-to-crawl.md)
and [walking-edge study](ink-walk-edge-crawl.md), not rerun as new evidence.
Earlier direct moving-top entry also reaches deep interior while airborne,
but the action conversion and low cache remain missing. The broader
supported-crawl edge tests contain18,684 continuations, with no retained
deep crawler; they do not prove all support or actor histories impossible.

The present findings do not change the route assessment or any of the45
subjective estimates: Rank1 remains **1–2%**, Ink Rank2 **<1%**. Those are
judgments, not measured probabilities. Mario entry, actor delivery and their
joined phase remain distinct obligations.
