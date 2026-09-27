# Rank 1: floor traversal repaired; one complete update is still unfinished

**Follow-up:** the [conditional full-interval path checker](rank1-complete-update-path.md) now completes both US/JP controller-to-retention paths, including live callbacks. It uses a supplied scene and does not close exhaustive predecessor coverage or gameplay reachability. The earlier measurements and limitations below are retained as that earlier result.

27 September 2026. **The floor-list implementation blocker is fixed in the
exploratory application. The requested complete one-update run is not done.**
The extended US/JP attempts now reach the behavior script's native callback.
There is no surviving-sequence count, gameplay witness or route exclusion.
Rank 1 remains at its subjective 1–2% estimate. This is application work, not
a new Coq theorem or a discharged capstone premise.

## What now works

The follow-up [Reverse Scattershot review](rank1-reverse-scattershot.md) explains
why stopping at this partial repair missed the requested milestone, and how
randomized exploration differs from completing the update implementation.
Neither the coverage gap nor the helper timeout establishes infeasibility.

The application interprets the actual generated `find_floor_from_list` loop,
including its next pointers, triangle tests, early rejection and first eligible
return. It also constructs the complete `find_floor` calculation: dynamic and
static scans, their height comparison, and the optional intangible-floor retry.
The original `update_mario_platform` call can now be traversed through those
callees and its final owner stores.

These are definitions of predecessor conditions. Constructing them is separate
from solving them. The unrestricted final-platform query times out after 15
seconds of solver time in **both versions**, returning **unknown**. Its measured
worker duration is about 15.6 seconds. A timeout does not mean no predecessor
exists, and this helper is not one complete controller update.

The regression fixtures do finish and check the real bodies. They cover empty
lists, first-eligible order, rejection paths and the 78-unit allowance; dynamic
versus static selection, including the tie going to static; intangible retry
and its flags/counters/output pointer; and writing or clearing the two platform
pointers after actual floor selection. One subtle case is retained: an
intangible retry can return null while leaving an earlier height in place.
Those fixtures are test data, not claimed live SSL lists or gameplay witnesses.

Loops use an existential, finite, decreasing execution counter. The main
calculation imposes no arbitrary node cutoff. Selected regression cases use
explicit finite bounds on their tiny supplied lists; exhausting a bound does
not invent a null return. A rejecting cyclic list cannot justify a completed
execution by referring to itself forever. Neither feature proves termination
or validity of every live list.

## The requested update run

The target still requires the ordinary Mario Object to be present and both
platform pointers to name the checked top. The real final floor call must
return height 1938.8648681640625 at X=-2200, Z=-1024. That height is an output
to derive, not a free return value. Initial position agreement and intact live
floor lists are not granted.

The first coverage gate remains the original `update_objects` entry through
its final `update_mario_platform` call: 21 of 27 outer statements. It is a
necessary part of an update, not the controller/level scheduler or the effects
between successive retention checks.

| Requested horizon | US | JP |
| --- | --- | --- |
| One complete update | Incomplete: live native callback unresolved | Same blocker |
| Two complete updates | Not run | Not run |
| Four complete updates | Not run | Not run |

The updated failed coverage workers take **3.922 seconds / 62.86 MiB** for US
and **3.848 seconds / 62.41 MiB** for JP. Each visits 1,955 statement nodes,
constructs 17 loop relations and finishes definitions for 61 function bodies.
Some of those definitions refer to callees still awaiting coverage; this is
not 61 independently completed gameplay calls. Branches share one formula
instead of multiplying a list of syntax paths. One formula is not one gameplay
possibility. These measurements are neither full-update throughput nor a
five-second search estimate.

## Where it stops now

The original `cur_obj_update` reads a command from a live behavior script.
Its command table has 56 source entries. The explorer follows those guarded
alternatives, retaining the actual loaded pointer. Command 12,
`bhv_cmd_call_native`, then reads a native function pointer from the script and
calls it. That call is the next unresolved execution connection, in both
generated versions at `behavior_script.v:1820`.

Reading the initial command table does not prove that the live table retains
those entries, nor does a catalog of callback names establish the live script
and its receiver. The explorer records these as coverage obligations. An
optional diagnostic catalog of every source `CALL_NATIVE` entry reaches menu
callbacks outside the current generated-body set. That is overbroad source
exploration, not evidence that SSL reaches a menu callback. Restricting the
catalog to convenient SSL names would require a justified connection to the
live scripts, spawns and receivers; it is not silently done here.

After that connection, the remaining callback effects, actual controller/level
scheduling and intervening update effects still need implementation. Solver
completion is a further issue: even the unrestricted final-platform query
currently returns unknown. The requested stopping criterion has not been met.

## Other application repairs and limits

Merged formulas and shared function relations avoid repeatedly expanding the
same continuation. The application now handles the reached 64-bit clock value,
double-precision expressions, packed fields and defined numeric conversions.
Loop argument order follows the installed CompCert definitions. Initialization
checks include `continue` paths; undefined function results are distinguished
from zero. Recursive calls that would reuse a live local region are rejected.

The broader diagnostic explicitly links the existing generated runtime audio
bodies. Its optional `sqrtf` binding checks the real declaration and restricts
inputs to finite, nonnegative normal binary32 values or signed zero. The
existing local square-root theorem also needs the specified processor settings.
Those live domain/settings and linkage conditions are recorded as unresolved;
they are not discharged by selecting this option. No outside call receives an
assumed identity memory effect.

This remains an unverified interpreter with flat byte memory and separated
canonical storage. It does not implement full CompCert allocation, validity or
pointer provenance. A solver model would still need those checks and a
controller-reached predecessor before it could become a gameplay witness.
There was no game-state injection, new Wafel replay or arbitrary memory edit.

## Checks and reproduction

All **32 application regression tests** pass. They include the earlier local
checks, the repaired real floor bodies and negative controls for unsupported
calls, invalid conversions, loop exhaustion, undefined reads/results and
recursive local-storage reuse. They do not prove the interpreter correct.

Run from the SSL project with the existing isolated Z3 installation:

```sh
python -m unittest discover -s instrumentation/rank1-backward-search -p 'test_*.py' -v
python instrumentation/rank1-backward-search/benchmark_updates.py \
  --output build/rank1-backward-search/update-benchmark
python instrumentation/rank1-backward-search/loop_probe.py \
  --version jp --cut platform --solve \
  --output build/rank1-backward-search/platform-jp.json
```

Use `--version us` for the corresponding platform probe. The
[coverage receipt](../../instrumentation/rank1-backward-search/update-benchmark-report.json)
records source/implementation hashes and the current blocker. The
[floor-probe receipt](../../instrumentation/rank1-backward-search/floor-traversal-report.json)
retains the two complete helper-formula attempts and their unknown answers.
Timing and solver outcomes may vary between runs.

The selected Coq audit passed at
`build/audit/20260927-094020-hh0hdlr1`: 620 registered sources; build, proof-hole,
link and integration checks; seven allowed foundations for each selected main
Rank-1 boundary and final-query-to-owner theorem. The main closure remains
448 of 542 proof modules, with 94 standalone modules. No `.v` file or capstone
premise changed. This audit does not verify the Python application. Nothing
is promoted to Section 01 and no route estimate changes.
