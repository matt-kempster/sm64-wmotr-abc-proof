# Successive-update check — 2026-09-06

**No sustained cog Pedro entry has been established.** The additional US/JP
replay reaches an ordinary off-floor close-gap return, but the complete path
still fails preservation. This is experimental evidence from the declared
ledge initialization, not a new Coq theorem or normal level-entry witness.

The source pin, RANDOM clock mode, and initialization patch are unchanged
from the [detour follow-up](ttc-cog-detour-followup.md). Subsequent gameplay
uses ordinary controller inputs and the existing read-only observer.
No Coq or generated Clight files changed in this follow-up.

## What the new check requires

[`check-preservation.py`](../instrumentation/ttc-cog-placement/check-preservation.py)
first runs the existing complete trace-consistency check. Its narrow
ordinary-air witness class requires at least two successive complete Mario
action updates with:

- The same Mario X/Y/Z at bracketing input snapshots and every observed
  internal action/air boundary, with no platform reference.
- An actual-position floor more than 100 units beneath Mario and the
  off-floor input flag after geometry refresh.
- A nonzero intended horizontal displacement and a nonzero wall-resolved
  horizontal query on every air call. Each call must take the close-gap
  landing branch, retain the old floor reference and position, and select
  the lower cog floor and upper cog ceiling.
- Fixed positions/yaws of both relevant cogs, with zero observed speeds
  throughout the action updates and matching bracketing poses.

Ground-pound startup has no qualifying air calls. Ground-pound actions and
impacts on an existing supporting floor are expressly excluded from this
witness class. Other actions require a separate complete preservation check;
their exclusion here is not an impossibility result.

The interval starts at the complete action update after that frame's surface
update. A target velocity selected on its last update is recorded, rather than
treated as a guarantee for a further update. The optional
`--allow-upper-rotation` check is labeled as a weaker diagnostic and writes
`preservation-lower-only.json`; it does not establish that both cogs stay fixed.
Neither mode has a positive gameplay witness yet. In particular, the
acceptance path has not been validated on a successful gameplay trace.
These tools remain outside the Coq trusted base.

## Additional bounded searches

All 35 completed US route experiments pass the existing frame, air-return
and ordered-RNG consistency checks. Four trials have one close-gap return
each; none has close-gap returns on consecutive updates.

| Variation | Trials | Controller change |
| --- | ---: | --- |
| Fine inward-turn timing | 7 | Turn at 129, 130, 131, 133, 134, 135 or 137 |
| Earlier braking | 6 | Release at 122 through 132 in steps of two; resume inward at 134 |
| Fine outer target | 12 | X=1376 through 1420 in steps of four; turn inward at 134 |
| Neighboring-cog descent | 8 | Climb the grabbed ledge, then use two staging points and four descent targets |
| Individual route checks | 2 | A tighter inner-edge target and an initial neighboring-cog descent |

The neighboring-cog route does climb the ledge, but its tested continuations
remain supported or return to supporting geometry. The inner-edge route is
also supported. These finite failures do not settle the existence question.

[`successive-updates.json`](../instrumentation/ttc-cog-placement/results/successive-updates.json)
contains every trial's exact controller intervals and waypoint rows, input
and trace hashes, counts, and close-gap frames. The three fine-search suites
are reproducible with `sweep-detour.py --suite turn_fine|brake_early|edge_fine`.
For the remaining rows, write the receipt's controller/waypoint arrays to
the corresponding CSVs and supply them to `run.py` with a fresh trial name
and the recorded render-frame limit.

## Checked ordinary-air replay

[`ledge-rim-turn-133-us.csv`](../instrumentation/ttc-cog-placement/inputs/ledge-rim-turn-133-us.csv)
has SHA-256
`5adc251f5b64dca13277f678c9c01c77cfb688af1cab20619babdfc4fb220ae8`.
The fixed-input US and JP runs agree in all 4296 normalized events over
frames 0 through 164: 823 RNG calls, 140 air returns, 916 action boundaries,
and 750 selected-surface descriptions, alongside the input/cog/wall records.
The fixed US run reproduces the steering trial's observations through 164
and the previously checked detour's complete prefix through 114. Input-file
rows beyond 164 were not independently replayed in this comparison.

| Update | Complete-path observation |
| --- | --- |
| 136 | Lower cog naturally has speed zero at yaw -18000. The upper collision is absent at the attempted landing, and Mario lands normally with changed X/Z. |
| 137 | Lower cog rotates to -17950 and carries Mario. Geometry selects a supporting floor; the landing body runs. |
| 138 | Lower cog rotates to -17850 at speed 100 and displaces Mario again. Geometry now selects floor -8191. Landing cancellation selects freefall, which takes one close-gap return. |
| 139 | Lower cog rotates to -17700 at speed 150. Geometry finds the supporting floor at -2088 again. The landing body runs; there is no air-quarter-step call. |
| 140 | The cog carries Mario to a different position. |

On 138 the retained actual position is
`(1455.68127,-2088,-1144.99951)`. Both the intended and wall-resolved query
are `(1455.13,-2088,-1143.95032)`. The selected floor is -2088 and ceiling
-1934, giving a 154-unit gap; the retained floor height is -8191. The return
preserves Mario's position and floor reference within that call. Horizontal
speed is approximately -2.366. The upper cog also rotates, at speed 900.

Thus this return is an off-floor rejection of actual attempted horizontal
motion. **It still does not supply successive preserving updates:** Mario
moved before it, both cogs rotate, and the following update has supporting
geometry. No particle requests occur in the inspected updates 136–140.
There is no comparison of preserving input choices or RNG-control claim.

## Validation and reproduction

Eight complete recorded action traces, including the previous ground-pound
US/JP runs and the transient inner-rim run, were rejected as sustained
witnesses in both the strict and weaker diagnostic modes. The receipt records
their rejection reasons. Python syntax checks pass. The existing observer
compiled with warnings treated as errors for the new US/JP replays.

With the prepared placement builds, run in Ubuntu-24.04:

```sh
python3 Pedro-Coq/instrumentation/ttc-cog-placement/run.py us NEW_TRIAL \
  --inputs Pedro-Coq/instrumentation/ttc-cog-placement/inputs/ledge-rim-turn-133-us.csv \
  --trace-path --video-frames 540
python3 Pedro-Coq/instrumentation/ttc-cog-placement/check-preservation.py \
  Pedro-Coq/build/cog-placement/NEW_TRIAL
```

Use `jp` and another fresh name for the independent version. The expected
result for this replay is an empty `witnesses` list. Normal entry, sustained
preservation, preserving RNG control, and the linked Clight execution
obligations remain open.
