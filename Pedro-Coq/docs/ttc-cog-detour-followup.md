# Detour, natural cog phases, and action-path follow-up

Later work: the [successive-update report](ttc-cog-successive-updates.md)
records the stricter preservation check, 35 further searches, and a US/JP
ordinary off-floor return. That path also fails preservation.

The sustained entry/control objective remains open. The corrected detour now
connects to one executed close-gap landing branch during a ground pound in
both US and JP. It does not connect to a sustained trapped state: Mario is
carried by the cog before that return, has zero horizontal speed at impact,
and already references the selected supporting floor. No preserving-input
RNG comparison is claimed.

These are observations of the separately declared ledge initialization at
pin `9921382a68bb0c865e5e45eb594d9c64db59b1af`, with RANDOM clock mode. The
initialization patch remains
`6daa97f3c5836c157ceba2d926d57481fd2b17713392845b3b3f4374cb56da91`.
Cog phases arise from ordinary gameplay. There are no changes to movement,
collision, cog, particle or RNG functions. Normal level-entry provenance and
linked Clight execution remain separate obligations. Scope is US/JP only.

## Observations added

`run.py --trace-path` records geometry refresh, action changes, landing
cancellation/body, ground steps, the complete Mario action update, and
particle-spawn helper entries/returns. It also records the current cog poses
and Mario's platform reference at these boundaries. Selected floor/ceiling
triangles are captured with their owners, vertices, normals and offsets.
The air trace distinguishes actual position, original intended position,
wall-resolved query, and returned position/reference.

The checker requires paired routine boundaries and matching selected-surface
descriptions, in addition to the existing frame/air/RNG consistency checks.
The expanded observer reproduced all 1002 pre-existing events of the earlier
inner-rim example in frames 0 through 64. Its additional observations directly
show the frame-1 off-floor landing cancellation and the frame-2 landing body.
These instruments remain outside the Coq trusted base.

## Bounded route searches

The 48 completed US searches in
[`detour-search.json`](../instrumentation/ttc-cog-placement/results/detour-search.json)
include:

| Search | Trials | Change after the common detour prefix |
| --- | ---: | --- |
| Rim and inward turn | 18 | Three outer targets, three turn times, with/without a second jump |
| Natural departure phase | 12 | Neutral waits of 4 through 160 frames on the stable ledge |
| Braking | 6 | Release the stick on frames 130 through 135, resume inward steering on 146 |
| Moving tip | 6 | Controller targets at local tip radii 298 through 310 |
| Tip with coasting | 6 | Two tip radii and three steering start times, with a coasting heuristic |

None takes the close-gap landing branch. An additional initial outer-route
trial, `detour_outer_us_01`, also has zero such returns. Observed failures
include grounded blocking, overshoot, ledge grab and falling. This finite
search is not an impossibility result. Moving targets and the coasting
estimate are controller policies, not SM64 collision models or proof lemmas.

## A natural stop occurs after the ceiling disappears

The fixed controller file
[`ledge-rim-return-us.csv`](../instrumentation/ttc-cog-placement/inputs/ledge-rim-return-us.csv)
has SHA-256
`2fd5fe2a11b9fcfd1d2892c2e1d77f16261fc564112082fde3ad6e1d62d67141`.
Its events through frame 114 exactly match the corrected mesh detour's
1855-event prefix. From frame 115 it heads toward the outer rim, turning
inward at frame 136. Replaying the recorded inputs reproduces all original
observations without the steering helper.

| Frame | Observed behavior |
| --- | --- |
| 133 | Walking leaves the floor at `(1462.24194,-2088,-1148.31201)` and selects freefall. |
| 134 | The actual and attempted points select floor -8191 and cog ceiling -1934. The query is outside the lower floor; it is not a close-gap landing. |
| 135 | Four air steps lower Y to -2092 while X/Z remain unchanged. Mario enters soft bonk with backward speed. |
| 136 | The lower cog naturally reaches speed 0 at yaw -18000. The selected ceiling is now distant static geometry. The inward query finds floor -2088 and lands normally, updating X/Z and the floor reference. |
| 137 | Landing cancellation returns false; the landing body runs and moves Mario. No dust is requested in this window. |

The loss of the upper collision agrees with its stock 400-unit loading
distance and the preceding four-unit drop. This is a concrete failure of this
route, not a proof that other phases or positions fail. The complete US/JP
replays match in all 8131 normalized events over 315 input snapshots.

## Ground pound reaches the branch, but fails preservation

The additional fixed input file
[`ledge-rim-ground-pound-us.csv`](../instrumentation/ttc-cog-placement/inputs/ledge-rim-ground-pound-us.csv)
has SHA-256
`7edeeafb8c6152c83550024964eb7baa1fc6be03b31f5fed85d8d7484db2c50f`.
It adds Z on frame 134. The preceding event prefix and the incoming frame-134
Mario snapshot agree with the rim-return replay. US and JP agree over the
complete 215-snapshot run: 5477 normalized events, including one close-gap
return and all recorded action/surface/particle observations.

Ground-pound startup holds position at `(1462.24194,-2088,-1148.31201)`
through frame 139. **There are no air-quarter-step calls during that startup.**
It is not a run of repeated Pedro returns. The cog moves beneath the actual
position, and platform displacement starts changing X/Z on frame 140.

On frame 149, the actual position is
`(1365.77637,-2088,-1120.25647)`. The intended and wall-resolved query is
`(1365.77637,-2100.5,-1120.25647)`. The floor is cog 0 at -2088; the ceiling
is cog 3 at -1934. The 154-unit branch returns landed, keeping X/Z and the
floor reference and resetting Y to -2088. At this point:

- Horizontal speed is zero; no attempted horizontal displacement is rejected.
- The retained floor is already the same supporting cog floor selected by
  the query. This is not the earlier off-floor freefall/landing loop.
- The lower cog is moving at speed 650, yaw -13450, and keeps carrying Mario.
- The action changes to ground-pound land and requests `0x00010010`:
  horizontal-star and mist-circle particles. Particle helper calls are observed.

This establishes a controller-connected execution of that branch with particle
requests. It does **not** establish a trapped Pedro state, fixed cogs, or a
preserving way to control RNG. The full path fails preservation before impact;
therefore the requested comparison of preserving input continuations remains
pending. Visible particles or a single landed return do not discharge it.

## Receipts and reproduction

[`detour-paths.json`](../instrumentation/ttc-cog-placement/results/detour-paths.json)
records complete US/JP trace hashes, comparison counts and selected milestones.
Raw logs, all observations, authenticated routine descriptions, initialization
manifests and reports remain under ignored `build/cog-placement/`.

The US video replay, `rim_pound_video_us`, has the exact same complete trace
hash as `rim_pound_entry_us`. Its 241 captured frames cover render indices
350 through 590. The silent exports are `detour-ground-pound-us.mp4`
(30 fps, 8.033 seconds) and `detour-ground-pound-us-half-speed.mp4`
(15 fps, 16.067 seconds). Both decode fully, and the preview was inspected.
The footer labels the test start and the absence of sustained stasis.
`video-manifest.json` records frame/video hashes and encoding commands.

The observer compiles with warnings treated as errors. The Python helpers
pass syntax checks. The checker rejects a missing action return, missing
selected triangle, altered Pedro returned position and altered RNG observation
in separate copies of the logs; see
[`checker-regression.json`](../instrumentation/ttc-cog-placement/results/checker-regression.json).

With the already prepared ledge builds, replay in Ubuntu-24.04:

```sh
python3 Pedro-Coq/instrumentation/ttc-cog-placement/run.py us NEW_TRIAL \
  --inputs Pedro-Coq/instrumentation/ttc-cog-placement/inputs/ledge-rim-ground-pound-us.csv \
  --trace-path --video-frames 590
python3 Pedro-Coq/instrumentation/ttc-cog-placement/check-trace.py \
  Pedro-Coq/build/cog-placement/NEW_TRIAL
python3 Pedro-Coq/instrumentation/ttc-cog-placement/report-path.py \
  Pedro-Coq/build/cog-placement/NEW_TRIAL --first 133 --last 157
```

Use `jp` and a fresh name for the independent JP replay. The tested
ground-pound window ends at frame 214; later input-file rows have no claim
attached to them. Coq/generated proof files were not changed by this work.

The next witness must preserve the relevant Mario and cog state across actual
successive action updates. In particular, neither ground-pound startup nor
an impact with an existing supporting floor can substitute for the missing
sustained close-gap entry. A different action remains a candidate until its
whole preserving path is checked.
