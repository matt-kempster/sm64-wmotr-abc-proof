# Working backward on the high crawl

This investigation starts from proof commit `db1ba9d` and the
[supplied 973-unit handoff](ink-timer130-crawl-replay.md). The new experiments
use the pinned Wafel 0.8.5 JP DLL. They do not add a Coq theorem or establish
a clean route from the accepted gameplay start.

**A controller can establish crawling on a supplied roof position and then
briefly crawl on the rotating top without A. The tested continuations do
not carry that crawl up to the required Y=1741.** This is progress beyond
supplying `ACT_CRAWLING` directly: the best local witness supplies only
Mario's synchronized movement, collision and display position. The native
action sequence enters crouching, starts crawling, and crosses onto the
top. The initial roof approach and the later high handoff remain open.

Every timer below is the **stored top `oTimer` between updates**, unless
explicitly called an executing behavior timer. For example, the snapshot
with stored timer 79 follows the update executing behavior timer 78. The
established handoff supplies its starting state before behavior timer 130.

## Why starting the crawl is a separate obligation

The top mesh uses `SURFACE_HARD_SLIPPERY`; its side faces have normal Y close
to 0.707 (`reference-sm64-decomp/levels/ssl/pyramid_top/collision.inc.c:5–16`).
Crouching, starting crouching and starting crawling cancel on
`INPUT_ABOVE_SLIDE`, whereas an already-established crawl consults
`should_begin_sliding`. That latter test additionally checks downhill
facing, backward speed at most −1, or a slide level. Relevant sibling-source
locations are `src/game/mario_actions_stationary.c:528–546,693–710,743–760`
and `src/game/mario_actions_moving.c:467–477,1247–1298`.

Contour steering does not eliminate the slope acceleration. In
`mario_actions_moving.c:283–330`, the code selects the sign of
`slopeAccel * steepness` using the relative yaw's half-plane; it does not
multiply by the cosine of that yaw. For the top's approximately 45-degree
slippery faces, the uphill-side subtraction is about 1.91 per update. An
established crawl can therefore be short-lived even if its heading appears
roughly parallel to a contour. This is a source-level explanation, not a
global bound on all possible crawling histories.

Twelve one-update controls directly supplied the high pad
`(-1950,1741,-939)` at stored timers 128, 129 and 130, varying the initial
action among IDLE, CROUCHING, START_CRAWLING and CRAWLING. All nine
non-established-crawl controls ended in ground pound after the off-floor
transition and Z input. All three established-crawl controls retained crawl
and ended with M=C at Y=768 and D at 1741. Their action/speed fields were
supplied; these controls show the distinction, not action reachability.
They did not include a nearby pushing actor and did not produce the full
floorless handoff.

## A position-only local producer

The finite roof sweep used nine stored timers
`[0,8,24,48,64,80,96,112,120]`, 52 X/Z points listed in the implementation,
and two steering targets: the top center `(-2047,-1023)` and high pad
`(-1950,-939)`. Each trial set M=C=D to `(x,1280,z)` and retained the actual
prefix action, cache, platform and speed. It held Z with neutral stick for
eight updates, then held Z while steering toward the chosen target at
stick magnitude 64. The horizon was `132 - initialTimer`, with early exit
after leaving Area 1 or losing the area/camera pointer. There were 936
trials and 64,344 trial updates: 130 trials established crawl, ten had
top-supported crawl, and none had crawling Y at least 1741. These are
finite menu results, not an exclusion of other positions, controls or
histories. An earlier 576-trial coarse sweep found no top crawl; the
expanded boundary-point sweep supersedes that result.

The best grid witness starts at stored timer 48, supplying only
`M=C=D=(-2559,1280,-1535)` and inheriting IDLE. After the eight Z-neutral
updates it steers toward the high pad. It enters crawl at stored timer 64.
Its useful part is:

| Stored timer | Movement position | Floor owner | Forward speed |
| --- | --- | --- | --- |
| 79 | `(-2533.428711,1290.538452,-1506.668945)` | top, slot 61 | 1.589079 |
| 80 | `(-2708.250977,1330.204346,-1238.864868)` | top, slot 61 | 0.743854 |
| 81 | `(-2728.800781,1294.394043,-884.901611)` | top, slot 61 | −0.080274 |
| 82 | `(-2554.107422,1280,-533.643616)` | static roof | 1.019726 |

No action, floor-cache, platform, object, RNG or allocator field is edited
in this witness. Its 84 continuous controller updates were independently
replayed from a fresh game instance, including the recorded no-A prefix,
the one initial position patch, and no intermediate patch. All 41 retained
checkpoints and the final snapshot matched exactly. At stored timer 132 it
is walking on the static roof, not ready for the high handoff.

## Bounded continuation search

A second search begins at that controller-created top-crawl snapshot with
stored timer 79. It restores complete native states, changes only controller
input, and retains only branches ending in CRAWLING. Its menu is Z with
neutral stick or eight world directions at magnitudes 32 and 64, adjusted
for the current camera yaw: 17 inputs per retained state. Width is 16 and
horizon 52 updates. Ranking prefers current top support and height, with
coarse X/Z, facing and speed cells for diversity; width pruning is explicit
in the implementation.

The beam tested 13,889 one-update continuations. It reached a slightly
higher crawl, Y=1330.6318359375, at stored timer 80. Top-supported crawling
candidates existed only at stored timers 80 and 81; both reported trails
had returned to static support by 82. Crawling itself survived to
the horizon at stored timer 131, but the selected trails ended near
`(-2468,1279,-511)` and `(-2466,1280,-511)`. No tested crawling candidate
reached Y=1741. The stop reason was the horizon, not exhaustion of all
inputs. The two reported 83-update complete trails each passed independent
fresh-boot replay with the sole initial roof-position patch and all 52
branch checkpoints matching.

## Why the direct inverse is not an ordinary supported predecessor

Platform displacement adds `oVelX` and `oVelZ`, but not `oVelY`; yaw-only
rotation preserves Mario's Y (`src/game/platform_displacement.c:91–160`).
The top directly changes its X by a 40-unit oscillation and separately
rotates/rises (`src/game/behaviors/pyramid_top.inc.c:32–55`). Consequently,
inverting an ideal rigid translation-plus-rotation is the wrong proposal.

Inverting the actual yaw-only rotation about the current timer-130 center
gives approximate prior X/Z `(-2013.015347,-899.266240)` for the high pad.
The loaded previous mesh's containing top plane at truncated X/Z
`(-2013,-899)` has calculated binary32 height 1905.116455078125. The receipt
records the native loaded normal, offset and integer vertices; this is a
plane calculation, not a newly instrumented `find_floor` return. Supplying
Y=1741 there places Mario about 164 units below that top surface, so it is
not a top-supported predecessor merely because its X/Z inverse is right.

Thirty-two full-update diagnostics tested this X/Z at Y=1741 and at the
calculated support Y, each with eight facing angles and speeds 4 or 20.
They explicitly supplied established crawl and platform slot 61, while
leaving the floor cache untouched. All sixteen Y=1741 trials rotated into
the high pad and ended with static cache Y=768 and D=1741. All sixteen
support-height trials kept a top-owned floor, between 1909.881103515625 and
1925.9119873046875; eight kept crawl and eight slid. None of these supported
proposals produced the required Y=768 cache. This rejects that particular
supported inverse family, not all top-history predecessors.

The loaded native static mesh also contains no floor vertex above 1408
(962 static surfaces, 723 with upward normal). This inventory is not an
all-query proof, a collision-arithmetic bound, or an exclusion of dynamic
platforms, airborne histories or unusual coordinates.

## Reproduction and remaining obligation

From `SSL-Coq/less-than-one-a-press`, both commands exited zero:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_crawl_predecessors.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-crawl-predecessors-20261111-expanded.json
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_crawl_continuation_beam.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-crawl-predecessors-20261111-expanded.json build/wafel-pilot/ink-crawl-continuation-beam-20261111.json
```

The scripts create a new output and deliberately refuse to overwrite an
existing one; choose another output name when rerunning. The
[compact receipt](ink-crawl-predecessors-receipt.json) preserves hashes,
initial patch ledgers, all 936 grid result rows, entry/inverse controls,
the selected continuous witnesses, per-depth beam counts and fresh-replay
results. Raw local reports are represented by their SHA-256 hashes. No new
floor/ceiling query hook was used. The runtime SHA-256 is
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f` and
the input-capture SHA-256 is
`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.

The next missing link is a controller-produced history that reaches a
suitable high established crawl at the required time and position, while
also delivering an eligible pushing actor. Brief early top support and
long-lived low roof crawling each occur in the supplied-roof experiment;
their combination into the high timer-130 handoff does not. The experiments
do not connect the roof seed to the accepted start, and neither the finite
negative results nor the source explanations prove global impossibility.
