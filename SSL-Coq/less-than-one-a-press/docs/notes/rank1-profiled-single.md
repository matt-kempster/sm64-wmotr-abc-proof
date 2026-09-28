# Rank 1: profiled one-update query

27 September 2026. This batch requests one JP gameplay-model query, with
`--updates 1`, the same top-retention endpoint and symbolic earlier-state
domain as the repaired endpoint-first runner. No supplied scene, selected
controller samples, new callback restriction or finite loop cutoff is added.
Unanswered call effects and state validity retain the accepted conditional
status. Construction failed before that solver query could run, as recorded
below. The model remains exploratory, not a verified Clight refinement.

## Repair

Before naming a continuation, simplify its local Boolean, arithmetic, array
and quantified expressions. Temporarily rename recursive declarations to
ordinary uninterpreted functions, apply equivalence-preserving rewrites, then
restore the original declarations. This prevents the simplifier from unfolding
the recursive program and does not replace calls with harmless effects.
All compatible callback alternatives remain represented.

The runner now records local formula sizes and simplification time, source-body
construction timings, solver time and the solver's own statistics. Local size
totals count repeated DAG visits; they are not globally unique formula sizes or
gameplay-history counts. Eight targeted application controls pass, including
equivalence checks with recursive calls under a binder and with arrays,
bit-vectors and a floating-point branch. These are application checks, not new
gameplay proofs.

Command from the SSL project:

```text
python -X utf8 instrumentation/rank1-backward-search/endpoint_update.py --updates 1 --versions jp --timeout 900 --solver-seconds 120 --output build/rank1-backward-search/profiled-single-20260927
```

The initial construction attempt hit its 900-second worker cap while building
`play_cutscene`: its last snapshot had 2,636 completed source bodies, 585 queued
bodies and 77,682 visited statements. It never reached the solver, and the
whole-interpreter Python profile did not finish. This was a failed preprocessing
attempt, not a solver answer.

The repaired pass bounds local rewriting: expressions above 1,000 nodes are
kept unchanged; hitting 5,000 simplifier steps also keeps the original formula.
These are preprocessing budgets, not execution or input bounds. It uses cheap
source-body and rewrite timers instead of whole-interpreter tracing. The two
fallback controls verify that the original expression is retained exactly.
The corrected command uses the same flags with output directory
`build/rank1-backward-search/profiled-single-bounded-20260927`.

The worker cap is 900 seconds; the solver receives up to 120 seconds. No second
gameplay-model solver query or thirty-update rerun is part of this batch.
Only a solved query establishes tractability for this selected case and
configuration; a smaller formula or faster construction alone does not.

## Result: the requested solver query was not reached

Both preprocessing attempts hit their 900-second worker caps. The corrected
pass last reported 3,173 completed source bodies and 87,792 visited statements,
while constructing `cutscene_unlock_key_door_approach_mario`. Neither attempt
created a solver-stage record: **zero gameplay-model solver queries ran**.
There is no SAT, UNSAT or solver-unknown answer from this batch.

Completed rewrites alone consumed 256.15 seconds. Their summed local node visits
fell from 1,163,546 to 881,024 (about 24%); 38 expressions exceeded the size
budget and 25 hit the rewrite-step budget. The fallback costs are not included
in that completed-rewrite time. Smaller local expressions did not make the
whole calculation tractable: construction regressed relative to the earlier
runner that finished building its formula. The progress snapshots locate a
long construction interval in `play_cutscene`, but do not identify the exact
inner operation responsible. No full construction or solver profile finished.

The experiment is retained behind `--simplify-continuations`, disabled by
default. This flag was added after the attempts; supply it when reproducing
the rewritten mode. The corrected pass's exact earlier runner is preserved
locally as `endpoint_update.as-run.py` beside its output and checked against
its recorded hash. No further gameplay query was launched after this change.
The final eight targeted application tests pass. This is a failed optimization
experiment with partial profiling evidence, not a proof or a successful search.

See the [tracked receipt](../../instrumentation/rank1-backward-search/profiled-single-report.json).
Rank 1 remains open at its subjective 1–2%; all route verdicts remain unchanged.
