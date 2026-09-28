# Rank 1: the conditional one-second run

27 September 2026. This is the requested endpoint-first JP attempt for **30
completed retention checks**, representing one nominal gameplay second. The
original generated game-thread loop remains between checks. Only the final
check must retain the designated top at the selected X/Z and floor height;
earlier updates need not already have the installation. Paused or skipped
iterations are not silently counted as completed gameplay updates.

The accepted policy leaves unanswered call effects and state validity
conditional. There is no supplied gap, scene, replay prefix or forward trial.
The calculation uses the repaired source interpreter, symbolic Object
identities, and the original US/JP-generated sources; this limited batch runs
JP only. The earlier no-A history and actual gameplay validation remain open.

The solver receives 120 seconds after formula construction, within an
eight-minute worker limit. Results are not predetermined: SAT means a
conditional candidate, UNSAT means exclusion of the encoded case under its
conditions, and unknown/timeout is inconclusive. No result is relabeled unknown
merely because its call effects or earlier state remain conditional.

Four targeted application checks pass. A synthetic 30-checkpoint counter
returns SAT for its correct stopping value and UNSAT for a value that would
require executing beyond the final checkpoint. Three policy checks distinguish
candidate validation, conditional exclusions and genuine unknown/error cases.
These controls are not SM64 gameplay witnesses or a new Coq result.

Command, from the SSL project:

```text
python -X utf8 instrumentation/rank1-backward-search/endpoint_update.py --updates 30 --versions jp --timeout 480 --solver-seconds 120 --output build/rank1-backward-search/conditional-second-20260927
```

The one-update mode remains available with `--updates 1`; it keeps its earlier
single-iteration boundary. No three- or five-second cost follows from an
incomplete or merely conditional attempt. Rank 1's subjective 1–2% estimate and
all proof/route verdicts remain unchanged unless a separately validated result
justifies changing them.

## Actual result

**Unknown: the solver timed out.** Formula construction finished and solving
started at 297.12 seconds. The attempt ended at 417.82 seconds, after the
120-second solver limit. The 480-second worker limit did not stop it.
The formula represented 3,335 source-function bodies, with 472 unanswered call
sites retained as conditions and no source-function expansion left pending.
Peak process working set was about 1.60 GiB. These are application measurements,
not counts of gameplay histories or checked candidates.

The [compact receipt](../../instrumentation/rank1-backward-search/conditional-second-report.json)
records the implementation and generated-source hashes. Full local output is
in `build/rank1-backward-search/conditional-second-20260927/`.
The result contains zero solved conditional queries, zero certified exhaustive
updates, no candidate trace and no exclusion. This was a real endpoint-first
30-update formula attempt, not a completed one-second classification or a
forward replay. US was not run in this limited batch.

The answer is not forced to be unknown. If this query had returned UNSAT, it
would have been reported as a conditional exclusion of its encoded domain.
Transferring that exclusion to a named gameplay approach would need justified
coverage of that approach. Here the immediate failure is computational:
even accepting the conditions, the solver did not decide the formula in time.
No longer-horizon price can be extrapolated from this timeout.

## Why it timed out

The immediate cause is the configured 120-second solver deadline, not a game
obstruction or a source-construction failure. The interpreter puts symbolic
earlier memory, broad callback alternatives and recursive source relations into
one large query. It has not demonstrated tractable complete-update solving.
The run did not collect a solver profile, so we cannot identify the dominant
bottleneck, assert a particular implementation bug or conclude that a larger
deadline would solve it. This is a limitation of the present search design.
The complete one-update query should be made tractable and measured before
using longer horizons to estimate coverage costs. Narrow solved slices and
synthetic control tests do not establish that milestone.
