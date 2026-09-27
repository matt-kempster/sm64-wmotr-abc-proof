# Rank 1: bounded backward predecessor search

This is the first implementation of the approved backward-search batch. It
starts with desired installation conditions and substitutes backward through
the committed generated US/JP Clight statements. It does not replay an earlier
state forward and call that a backward search. No emulator, ROM, Wafel library,
gameplay-state modification or controller sampling is involved.

**Status:** checked exploratory tooling and local predecessor conditions, not
a new Coq theorem, a connected whole-frame inverse, or a gameplay witness.
The [plain-language report](../../docs/notes/rank1-backward-search.md) explains
what the results settle and what remains open.

## Run

From the active SSL project, with Python 3.10 or later:

```sh
python -m pip install --target build/rank1-backward-search/python-deps \
  -r instrumentation/rank1-backward-search/requirements.txt
python instrumentation/rank1-backward-search/test_search.py
python instrumentation/rank1-backward-search/search.py \
  --output build/rank1-backward-search/receipt
python instrumentation/rank1-backward-search/group_inputs.py \
  --output build/rank1-backward-search/grouping-all-no-new-a
python instrumentation/rank1-backward-search/test_benchmark.py
python instrumentation/rank1-backward-search/benchmark_updates.py \
  --output build/rank1-backward-search/update-benchmark
```

Z3 is isolated under the ignored build directory. The recorded run used
`z3-solver==4.15.4.0` (reported engine version 4.15.4). Existing build output
is not removed. Choose a different output directory to retain separate runs.

The search writes a JSON report, individual SMT queries and a DOT predecessor
graph. [expected-report.json](expected-report.json) retains the checked run,
including hashes of the generated functions, full generated units, interpreter
sources and SMT queries. Text source hashes normalize line endings through
Python's text reader. SMT query hashes identify that run; symbolic naming or
solver revisions need not produce byte-identical queries. Timeouts can vary
between machines. An unknown result is never converted to a contradiction.

## What is implemented

- `clight.py` reads constructor syntax, function declarations and composite
  layouts from `generated/{us,jp}_*.v`. It rejects unsupported syntax.
- `engine.py` computes predecessor formulas by visiting the second statement
  of `Ssequence` before the first. It handles assignments, temporary values,
  branches, switch/break, return, and the selected actual helper bodies.
- `search.py` checks the final owner decision, ordinary raw copy, floor-snap
  helper and selected geometry retry. It also exposes the unexpanded calls in
  the disappearing action and inventories the surrounding generated callers.
- `group_inputs.py` composes the selected real controller cuts with conditional
  expressions, retaining exact input variables and held-button history. It
  checks local groups against the existing backward engine. See the
  [grouping report](../../docs/notes/rank1-input-grouping.md) and
  [saved checks](grouping-report.json). These groups are not interchangeable
  whole-game states; unsupported calls are rejected.
- `benchmark_updates.py` checks the prerequisite for the requested one-, two-
  and four-update benchmark. It expands the real final floor call and rejects
  incomplete effects. Both versions currently stop at its live floor-list
  loop; no full update, later horizon or surviving-gameplay count is reported.
  The [benchmark note](../../docs/notes/rank1-update-benchmark.md) explains the
  distinction between these measured failed attempts and full-frame timings.
  Its seven tests include generated cast boundary and missing-call controls.

The functions interpreted recursively are `absf`, `vec3f_copy`, `vec3s_set`,
`stop_and_set_height_to_floor` and `mario_set_forward_vel`. Other calls have
independent before/after memories and an explicitly unexpanded relation.
Required floor results or normal receivers at returned-memory cuts are target
obligations; the search does not prove that those calls supply them.

The final capture calculation checks the complete binary32 domain for the
actual generated subtraction, absolute-value helper and strict four-unit
comparison. For the selected height, the accepted raw-Y bits are
`1156701102..1156766636`, inclusive. The other copy/snap interval checks are
symbolic equivalence checks, not finite samples of that interval.

## Scope and limits

This is an **unverified interpreter of the real generated syntax**, not a
replacement presented as the real program or a proof of CompCert semantics.
It uses big-endian byte arrays, binary32 round-to-nearest-even arithmetic,
fixed-width integers and generated layouts. Named State, Mario Object, top,
floor, globals and local regions have separated canonical addresses. Normal
Mario receivers are explicit scope conditions; no initial position agreement,
action, timer, depth or floor selection is imposed by that storage setup.

This first engine does not establish general memory validity, allocation/free,
pointer provenance, signed-overflow definedness, arbitrary aliasing or linked
call resolution. Unsupported loops, casts and expressions fail rather than
become no-ops. Solver consistency is not evidence that gameplay reaches a
state; contradiction is scoped to the interpreted slice and storage domain.
Any formal exclusion must still be checked against the existing Coq boundary.

The local predecessors are **not composed through the unresolved calls**.
The DOT graph uses dashed edges at those gaps. The call inventory is source
structure, not a proof of execution order and effects over a whole frame.
The two surviving final-check branches are the two signs in `absf`; their
count is not a count of gameplay routes.

The closed copy, snap and final-check slices do not read controller input.
The intended search includes all allowed inputs; B was only an example. There
is no complete previous-frame operation yet. The horizon comparison covers
[150 or 900 nominal updates before top retention](../../docs/notes/rank1-input-search-size.md).
Earlier action/input transitions, the same latched input across the frame,
previous-button history, live floors, contact, timing and lifetime remain
explicit work. No controller-reached predecessor was joined in this batch,
so there was no candidate for a new Wafel/emulator replay.

## Validation

Seven tests check generated layouts against existing proof offsets, independent
binary32 boundary arithmetic, a damaged-copy negative control, independent
unknown-call memory, guard retention and rejection of unsupported syntax and
loops. The damaged program exists only inside its test; generated files are
never edited. US and JP searches both pass their mandatory local checks.

The existing Coq query-to-owner boundary was re-audited with the project
pipeline; no `.v` file, capstone premise or accepted assumption changed.
