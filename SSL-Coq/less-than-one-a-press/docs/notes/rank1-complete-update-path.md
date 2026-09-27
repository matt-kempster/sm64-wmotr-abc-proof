# Rank 1: a supplied-scene update completes; the backward search remains open

27 September 2026. **The application now completes a controller-to-retention
path in both US and JP, including the live native callback.** It reverses all
the effects on that path and checks its predecessor condition. This is an
application milestone on a supplied scene, not a newly reachable Ink setup,
an exhaustive collection of predecessors, or a new Coq theorem. Reverse
Scattershot has not been started. Rank 1 stays at its subjective 1–2%.

## Did the requested one-update search finish?

**No. One chosen update ran end to end, but the requested backward search
did not finish.** Calling this just a “complete one-update run” blurred two
different milestones. The successful test starts with the useful gap and
support already supplied; it does not discover how to obtain them.

When the broader solver attempts did not finish, the implementation switched
to following a supplied scene and reversing that selected execution path.
That checks a conditional predecessor and exercises the repaired application.
It is a narrower fallback, not completion of the original search over
possible predecessors. The unresolved solver attempts are unknown results,
not evidence that the other possibilities fail. No new search or proof was
performed for this status clarification.

## What completes

The start is immediately after the hardware has supplied the controller pad
sample. The original controller code then runs the demo check, button-edge
calculation, stick adjustment and port copy. The original game-thread loop
places the level-script call next. The checker verifies that adjacency and
uses the stock SSL script's `CALL_LOOP(1, lvl_init_or_update)` entry.

The real level interpreter calls the real level update, which calls the real
area and object updates. The latter performs terrain updates, platform
displacement, object collision, non-terrain updates, unloading and finally
`update_mario_platform`. The selected run ends immediately after that final
call, at the requested retention checkpoint. Hardware input acquisition,
rendering after this checkpoint and the next update are outside this interval.

Mario actually runs. The checker follows the live behavior-command pointer,
then the live native pointer to `bhv_mario_update`, including Mario's input,
geometry, interaction and action code and the final State-to-Object copy.
No executed unknown callback gets a free result or an assumed memory frame.
The three actual floor calls produce:

| Call | Query (X, Y, Z) | Result |
| --- | --- | --- |
| First geometry query | (-2200, 768, -1024) | Null floor |
| Retry after the display copy | (-2200, 1938.8648681640625, -1024) | Checked top face |
| Final platform query | (-2200, 1938.8648681640625, -1024) | Same checked face and TOP owner |

Both platform pointers end at TOP. The retained height is computed by the
actual floor code, with bits 1156733869; it is not a granted callee result.

## What was supplied

The scene already has the raised display, low movement and raw Object
positions, and `ACT_DISAPPEARED` with the warp-object countdown. It contains
normal circular lists with Mario and the top, the checked timer-131 triangle
and plane, a valid animation cache, and ordinary controller storage. Time
stop is active: Mario runs, while the top and its existing surface remain
stopped. The scene is deliberately small; it is not asserted to contain every
stock SSL actor or floor.

These are explicit test data used to choose a path. **We did not make the gap,
obtain the disappeared action, establish a newly accepted warp, or prove that
this stopped support and live list occur together in gameplay.** In
particular, the test cannot turn its supplied high display into evidence of
a reachable producer. No emulator memory or running game was modified.

## What the backward calculation adds

The interpreter records each real guard, address calculation, argument,
assignment and return. It then substitutes those effects in reverse order
from the retention target. The resulting condition still has 457 predecessor
byte variables; it is not just the selected final state's coordinates.
The supplied entry valuation makes the whole condition true.

We also leave both raw stick bytes symbolic while fixing the other supplied
entry bytes. The solver checks that this complete path's condition is exactly
the 15-by-15 neutral square, from -7 through 7 on each axis. Thus **225 encoded
stick samples share this whole path** with the supplied neutral buttons and
previous mask. This count is neither 225 gameplay routes nor coverage of the
other stick/button paths. The real edge calculation supplies no new A press;
an earlier no-A history for the scene remains unproved.

The direct unrestricted solver attempt on the earlier path formula returned
unknown after 30 seconds. A known satisfying entry valuation is a checked
conditional example, not a completed classification of all other entries.
The earlier broad recursive-formula attempt also remained unfinished. The
path checker therefore does not claim that unsupported alternatives vanished
or that the exhaustive one-update search is closed.

## Implementation and checks

Both versions visit 3,924 statement nodes, record 3,068 effects and guards,
and make 152 calls across 90 distinct original function bodies. A whole worker
takes roughly 12 seconds here, including parsing, scene preparation, execution,
reverse substitution and the stick-group check. The receipt keeps exact run
times and peak memory. These are measurements of this selected path, not a
general update rate or a five-second search estimate.

The repairs include parsing large generated symbol lists and calling
conventions, typed live function lookup, source-sized pointer arithmetic and
fresh local storage for the trace. The checker rejects invalid addresses,
unaligned accesses, uninitialized reads, freed local reads, unsupported
executed calls and invalid conversions. Selected supplemental `main`,
`camera` and `sound_init` units are generated from the pinned C by the project
pipeline; they are not hand-written replacements or additions to the Coq
capstone. Source and implementation hashes are retained.

This remains an unverified explorer with canonical flat addresses. Its
storage checks do not prove CompCert pointer provenance or a simulation of
the retail machine. The two reached `sqrtf` calls use the explicitly named
instruction binding and its finite nonnegative input and processor-setting
conditions. Other external calls are rejected when reached.

All 36 application tests pass, including the full US/JP path and its input
group, a missing-display negative control, a damaged callback, a reached
unimplemented external call and invalid memory. The missing-display control
rejects this path; it is not an all-action or all-history impossibility proof.
The selected unchanged Coq boundary passed the audit at
`build/audit/20260927-123816-0elnpc35`: 620 sources, seven allowed foundations
for each of the two selected boundaries. No `.v` file or capstone premise
changed; the audit does not verify this interpreter.

## Reproduce

From the SSL project, first generate the three additional original units in
the existing WSL/opam environment:

```sh
bash pipeline/generate-search-clight.sh main=src/game/main.c \
  camera=src/game/camera.c sound_init=src/game/sound_init.c
```

Then use the project's isolated Z3 Python environment:

```sh
python instrumentation/rank1-backward-search/trace_update.py --version jp \
  --mario --output build/rank1-backward-search/complete-paths/jp.json
python instrumentation/rank1-backward-search/trace_update.py --version us \
  --mario --output build/rank1-backward-search/complete-paths/us.json
python -m unittest discover -s instrumentation/rank1-backward-search -p 'test_*.py' -v
```

The [saved receipt](../../instrumentation/rank1-backward-search/complete-update-path-report.json)
keeps both completed conditional paths. Full SMT conditions remain in ignored
build output. Wider path coverage, earlier gameplay reachability, the next
retention-to-retention interval and first Area-2 payoff remain separate work.
Nothing moves to Section 01, no route estimate changes, and no randomized
reverse search has been authorized or run by this batch.
