# Landing at 113: braking does not produce crawl in the tested continuations

The [walking-edge follow-up](ink-walk-edge-crawl.md) separately tries to
leave the slippery floor before pressing Z. Its directed tests still do
not produce a walk-off from the same exterior setup, so they do not directly
exercise crawling after successful upper-floor loss.

The proposed sequence was tested from the exact earlier exterior setup:
land on the top at behavior 113, stop sliding, start crawling, then let
rotation catch Mario inside. **No tested continuation reaches a slide-stop
action, crouching, crawl startup or crawl.** This remains true through
behavior 150, the last spinning update, not just at the original handoff's
behavior 130. There is therefore no crawler for rotation to catch in these
tests. This is a finite negative result, not an all-input impossibility proof.

The useful diagnostic is that Mario can slow below the ordinary stopping
threshold and still slide. In one fresh continuation, his own stored slide
speed reaches **1.108227 at behavior 124**, below the threshold of 4, while
he remains in stomach slide on the top. This speed does not include the
distance the rotating platform carries him. The top's steep, slippery floor
blocks the ordinary stop; insufficient braking is not the only obstacle.

## Exactly what was supplied

The experiment reuses the [earlier-entry receipt](ink-early-air-entry-crawl-receipt.json),
specifically `controls.selected.topRecapture`. The accepted pre-game debug
level select, 2,548 A-off recorded inputs, four-pillar history and neutral
waiting are inherited. This does not establish an ordinary-play approach
to the exterior starting pose or a three-pillar route.

Immediately before behavior 112, the single supplied Mario setup is:

| Field | Supplied value |
| --- | --- |
| Movement, collision and display position | All equal to (−1975.625, 1556.449829, −655.125) |
| Action | Freefall, action state and timer zero |
| Facing | 35840 angle units |
| Forward and horizontal speed | Zero |
| Vertical velocity | −16 |

His feet are **0.699829 units above the unrounded plane of the actual old
collision triangle**. The start is exterior; crawl is never supplied.
The supplied-write ledger is preserved in both receipts. Floor cache,
platform reference, action argument, hitbox, top motion, box, pillar count,
RNG and other unlisted fields are inherited, not edited.

After that setup, the wrapper permits only the three controller-pad fields.
Every input has A off, and native held/pressed A flags are checked after
each advance. Complete state restores separate alternatives; no individual
history receives another state edit. Landing at 113 and sliding afterward
are produced by the game, not supplied as new starting actions.

## The two exact branch points

The fixed behavior-112 input is buttons 0, raw stick (−63,10). Behavior 113
uses a neutral pad. Native results exactly match the previous receipt.

| Behavior just executed | Shared native result |
| --- | --- |
| 112 | Freefall entry; feet Y1540.449829. |
| 113 | Freefall landing on the top at Y1586.846191; top-owned floor and platform both identify object slot 61. |
| 114–116, if neutral | Landing continues while the top carries Mario. |
| 117, if neutral | Stomach slide, stored forward speed −5.427465. |

One batch branches immediately after 113, allowing the landing's remaining
inputs to change. A second preserves the neutral sequence through 117 and
branches from the actual stomach slide. Thus the test does not rely solely
on inputs that prevent the slide from starting.

Each advance is one game-logic frame. "Behavior 124" means that behavior
has executed; its completed timer is 125. The boundary before the original
handoff at 130 is the completed behavior-129 state. At behavior 150 the top
changes to its explosion action and its timer resets; it must not be
misread as another early spinning phase.

## Braking and a walking alternative

These are separate input histories, not one combined route.

| Continuation | Recorded result |
| --- | --- |
| Branch after landing 113; steer toward fixed world yaw 16384 at raw magnitude 64 | Stomach slide begins at 115. Speed falls to +1.108227 at 124 but the action remains stomach slide. Still sliding at 129, 130 and 150. |
| Preserve neutral slide through 117; steer toward world yaw 40960 at magnitude 64 | Speed reaches −1.368653 at 127 without stopping. Still sliding at 129, 130 and 150. |
| Neutral at 114–116, raw stick (0,64) at 117 | Native walking at 117, rather than the neutral stomach-slide result. |
| From that walking branch, press Z with neutral stick at 118 | Within that same frame: walking → decelerating → crouch-slide → butt slide. No stable crouch and no crawl. |
| From that walking branch, steer toward the next rotated uphill direction and press Z at 118 | Walking → crouch-slide → butt slide within 118. |
| Keep that uphill walking through 121; first press Z at 122 | Walking is retained for five completed frames, 117–121. At 122, walking → crouch-slide → butt slide within one frame. |

All three focused walking continuations stay in butt slide afterward through
150. "Crouch-slide" is a sliding action, not established crouching or crawl.
The intermediate action names in a row are native action-dispatch observations
inside one frame; they are not additional frames or input opportunities.
The selected histories preserve native collision meshes, positions, floor
and platform records, actions, button edges and animation state.

## Why the normal transition fails on this floor

The recorded upper faces have hard-slippery surface type 53 and upward
normal near 0.707–0.708, roughly a 45-degree incline. The code and native
results agree on the following local obstacles:

- `update_sliding` stops only if speed is below its threshold **and**
  `mario_floor_is_slope` is false. These faces still count as slopes when
  Mario slows below 4.
- Stomach slide's B rollout requires the slippery-floor input flag to be
  clear. It remains set in the low-speed witnesses; the tested B timings
  produce no rollout.
- Walking can briefly be maintained uphill. But Z selects crouch-slide,
  whose first check redirects to butt slide on this slippery floor.
- Ordinary crouch and crawl startup also reject that slippery-floor flag.

Relevant sibling decomp sources are `mario_actions_moving.c:275,807,1452,1520`,
`mario.c:606`, `mario_actions_stationary.c:693,743`, and
`mario_actions_object.c:298`. Their working-file hashes accompany the main
receipt. These are source explanations of the observed mechanism, not a
new formal theorem or a proof that every possible contact change fails.

## Finite coverage and checks

| Branch point | Policy labels | Subsequent frame advances | Additional beam candidates |
| --- | ---: | ---: | ---: |
| After native landing 113 | 876 | 32,412 | 230,500 |
| After neutral stomach slide 117 | 876 | 28,908 | 204,900 |
| Total | 1,752 | 61,320 | 435,400 |

Policies combine 16 fixed world headings, uphill and predicted next-uphill,
opposite-slide braking and its rotated version, four center-relative
headings, and neutral; raw magnitudes 16/32/64; and twelve button/timing
variants using no buttons, Z, B and B+Z. They respond with crouch/crawl inputs
if an ordinary stopped action appears. Labels need not represent different
actual input histories.

Each beam tests 100 raw pad choices per retained state: neutral and eight
directions at three magnitudes, crossed with none/Z/B/B+Z. It retains at
most 64 branches per frame, with observed-state merging and heuristic
ranking. It does not deliberately discard support loss or below-cap states.
Nevertheless, no sampled completed state loses top support, and neither
beam observes a slide-stop, crouch, crawl startup, crawl or rollout. Repeated
prefixes, pruning, omitted buttons and the finite stick menu prevent any
exhaustiveness claim. The three focused walking controls are additional
histories, not included in the table's counts.

The main run freshly rebuilds and compares **eight distinct representative
histories across 188 game-frame boundaries**. The walking controls add
**three fresh 39-frame histories, 117 boundaries**. Shared prefixes count
once per distinct history, not as independent physical discoveries. Each
branch point matches the earlier receipt exactly; every native advance
checks a one-frame global-timer increment. The receipt audit checks hashes,
counts and recorded fresh projections and recognizes the prior positive
roof-crawl control as crawl, while correctly rejecting it as interior crawl.
No whole-memory equivalence or new original-ROM recording is asserted.

The [main receipt](ink-top-slide-to-crawl-receipt.json) includes the batch
summaries, supplied ledger, inputs, selected native states and meshes,
fresh comparisons, source hashes and verification summary. The
[walking-control receipt](ink-top-slide-controls-receipt.json) retains the
three explicit continuations. The native runtime is the same Wafel 0.8.5 JP
DLL, SHA-256 `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.

From `SSL-Coq/less-than-one-a-press`, use fresh output paths; scripts refuse
to overwrite existing results. The walking controls read the main raw file
at the path shown below.

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_top_slide_to_crawl.py build/wafel-pilot/ink-top-slide-to-crawl-full.json
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/verify_ink_top_slide.py build/wafel-pilot/ink-top-slide-to-crawl-full.json docs/notes/ink-top-slide-to-crawl-receipt.json
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_top_slide_controls.py docs/notes/ink-top-slide-controls-receipt.json
```

This test adds no box setup, normal-play approach, useful high-crawl producer
or Coq theorem. The supplied-state Crazy Box handoff remains valid, while
this proposed way to supply its crawler is unsuccessful in the tested
histories. Other starts, contact changes and input histories remain open.
The atlas and private site retain all 45 estimates and proof verdicts,
including Rank 1 **1–2%** and Ink Rank 2 **<1%**.
