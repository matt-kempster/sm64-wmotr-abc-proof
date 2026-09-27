# Rank 1: the one-update benchmark stops before a complete update

27 September 2026. **The requested one-, two- and four-update timing curve is
not available.** A strict attempt on the actual US and JP code fails its first
coverage gate, inside the final floor query. This identifies missing execution
support in the prototype; it does not show that a complete backward solver is
computationally infeasible. No gameplay sequence was excluded. Rank 1 remains
at its subjective 1–2% estimate.

## What was attempted

The target is the ordinary Mario Object being present with both saved platform
pointers naming the checked top. The real final floor call must return height
1938.8648681640625 at X=-2200, Z=-1024. That return value is a desired output to
work backward through, not a granted floor result. No live list, selected floor
or initial position agreement is assumed.

The first gate uses the original `update_objects` statements from function
entry through its original `update_mario_platform` call: 21 of 27 outer
statements. The six statements after the retention checkpoint are outside this
cut. This is a necessary portion of one controller update, **not a full frame**.
Even completing it would still require the real controller/level scheduling
and effects between successive retention checkpoints.

The checker substitutes backward and expands the actual generated bodies for
`update_mario_platform`, `absf`, `find_floor` and `find_floor_from_list`.
Unexpanded calls are rejected instead of receiving free return values or
memory-preservation rules. There is no Wafel state injection, sampled input
schedule or fabricated earlier save in this attempt.

## What the measurement says

| Requested horizon | US | JP |
| --- | --- | --- |
| One complete update | Not completed: real floor-list loop unsupported | Same blocker |
| Two complete updates | Not run; first gate failed | Not run; first gate failed |
| Four complete updates | Not run; first gate failed | Not run; first gate failed |

The failed prerequisite worker took **0.325 seconds for US** and **0.347 seconds
for JP**, with peak working sets of **48.69 MiB** and **48.68 MiB**. Within those
processes, setup plus the attempted calculation took 0.137 and 0.143 seconds.
These are single local measurements, including no successful full update.
They are not a frame-throughput result or a prediction for 150 updates.

Each attempt visited 163 statement nodes before stopping, with at most 96
partial syntactic paths present. Those are not surviving gameplay choices:
the predecessor formula never completed and the benchmark made no SAT query.
The receipt records surviving possibilities as **unknown**, not zero. No
multiframe timing curve is inferred from these numbers.

## The exact blocker

Both versions stop at the original `Swhile` in `find_floor_from_list`, whose
definition starts at line 2655 in their generated surface-collision unit:

```text
update_objects
  -> update_mario_platform
     -> find_floor
        -> find_floor_from_list
           -> while surfaceNode != NULL
```

The floor query calls this helper for the live dynamic list and the live static
list, and may call it again for an intangible-floor retry. Backward traversal
encounters that optional retry first; this does not establish that the retry
occurs in SSL. The ordinary two scans use the same unimplemented loop.
The loop follows actual next pointers, checks triangles and returns the first
eligible surface in that list. The nine stick regions do not eliminate this
ordered floor-selection work.

No fixed scan length is silently substituted. A complete implementation must
interpret the traversal with justified bounds/termination coverage, or apply
a checked summary at the same memory boundary. A chosen node limit would
produce another bounded conditional result unless its remaining cases were
accounted for. Floor geometry, list order, pointers and call effects must stay
connected. Other object-update and controller/scheduler effects would still
need coverage afterward; finishing this loop alone would not finish the frame.

## The implementation improvement and its checks

The initial attempt first found an unsupported float-to-integer argument in
`find_floor`. The new strict checker now supports the reached binary32-to-signed
32-bit conversion and subsequent signed-16 narrowing. It attaches the finite,
representable-range condition to the actual statement, uses truncation toward
zero, and rejects NaN, infinity and out-of-range arguments. This follows the
installed CompCert `Cop.sem_cast`/`cast_single_int` and `Float32.to_int` shape;
it remains an exploratory implementation, not a proved interpreter.

Seven tests pass: actual ordinary-copy compatibility, rejection of opaque
calls, extraction of the exact retention cut, rejection of the actual floor
loop, 13 conversion boundary cases for each version, invalid call-argument
rejection, and preservation of an unaffected branch when an invalid conversion
is not executed. Original generated code and the earlier interpreter/grouping
files are unchanged.

Run from the SSL project using the existing isolated Z3 installation:

```sh
python instrumentation/rank1-backward-search/test_benchmark.py
python instrumentation/rank1-backward-search/benchmark_updates.py \
  --output build/rank1-backward-search/update-benchmark
```

The [saved receipt](../../instrumentation/rank1-backward-search/update-benchmark-report.json)
records original function hashes, implementation/test hashes, the blocker,
measurements and the explicitly unrun horizons. Time and memory will vary.

The selected Coq discipline audit also passed at
`build/audit/20260927-082645-6_vrz7ih`: 620 registered sources; build, proof-hole,
link and integration checks; seven allowed foundations for each of the main
Rank-1 boundary and final-query-to-owner theorem. There are still 448 of 542
proof modules in the main closure, and 94 standalone modules. No `.v` file or
capstone premise changed. This audit does not verify the Python code. Nothing
is promoted to Section 01 and no route estimate changes.
