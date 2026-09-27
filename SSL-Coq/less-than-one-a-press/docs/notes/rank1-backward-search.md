# Rank 1: the first backward search

27 September 2026. The approved first batch is implemented and has run on both
generated US and JP code. It starts with the wanted outcome and works backward
through selected installation-frame statements. This is checked exploratory
tooling, not a new Coq theorem or a clean gameplay witness. Rank 1 remains open
at its unchanged subjective **1–2%** estimate.

## What the search found

The target is remembering the checked top at height
`1938.8648681640625` (binary32 bits `1156733869`), with the final query at
X=-2200, Z=-1024. We did not fix every byte of the supplied Ink snapshot.
Warp acceptance, this later owner selection, and the first Area-2 displacement
remain separate checkpoints.

| Work backward from | Required earlier condition | Still open |
| --- | --- | --- |
| Both final platform references name the checked top | Saved raw Object Y is from `1934.864990234375` to `1942.86474609375`, inclusive, for this returned height | The actual floor call returns that height, floor and owner, with the required receiver still available |
| The ordinary State-to-Object copy ends with raw Y in that band | Incoming MarioState Y is in the same band | Other callbacks between the copy and final query |
| The floor-snap helper ends with movement and display Y in the band | Its incoming cached floor height is in the band | Its containing action, later calls and the source of that cached floor |
| The selected retry queries `(-2200,1938.8648681640625,-1024)` after the first query at `(-2200,768,-1024)` | At the display copy, the first floor result is null and the displayed vector is already the high target | Both wall calls, real floor results and their effects, and the earlier display producer |

**The snap points at the cached floor.** Both old movement and display can be
768 in a locally consistent predecessor if the cached floor height is already
high. An old high display cannot make this helper end high when the cached
floor height is 768. The helper overwrites that display. This tells us which
earlier value to explain; it does not establish a reachable high-floor setup.

The exact four-unit band comes from the actual generated comparison and `absf`
body. The search checked its equivalence over all binary32 inputs, including
rejection outside the band, rather than merely testing the endpoints. Raw
Y=768 fails. The copy and snap also have symbolic interval and exact-height
equivalence checks within the named normal storage domain.

## Where it stops

**These rows are not yet one connected frame.** The graph leaves dashed links
across the action tail, intervening object callbacks, geometry and interaction
calls. It does not assume they preserve the relevant values. Floor calls have
separate before-and-after memories; their desired outputs remain obligations.
The retry's two preceding wall calls are also unexpanded. A solver can therefore
allow low display before those calls and high display after them: that means
the call effects are unresolved, not that we found a legal display writer.

The full disappearing action calls animation code and, on one branch, triggers
the level warp. Those effects remain open. One branch timed out in each version
and remains unknown; two other branches are consistent only with unresolved
calls. The final-check enumeration contains 25 syntactic combinations, of which
23 contradict the target and two retain unresolved floor-call conditions. The
two survivors are the signs of the absolute-value calculation, not two gameplay
routes. These counts do not retire 23 mechanisms.

The tool is not yet a reverse-play viewer. The closed copy, snap and final-check
statements do not read controller buttons. The user's intended search includes
all allowed inputs; B was only an example. Extending it to the requested
[30 seconds before top retention](rank1-input-search-size.md) still needs the
actual action/input transitions and the missing connections between these cuts.
Earlier physical controller history is not granted. No candidate reached the
stage of a join to a controller-played prefix, so this batch did not run new
Wafel trials.

## What was checked

The [implementation](../../instrumentation/rank1-backward-search/README.md)
parses the committed generated bodies and layouts. It performs backward
substitution using byte memory and binary32 arithmetic. It is an exploratory
interpreter with explicit normal separated-storage conditions, not a formally
verified CompCert interpreter. General pointer validity, allocation, aliasing,
undefined-behavior checks and linked call resolution are outside this first
implementation. Unsupported constructs fail; unexpanded calls get no assumed
memory-preservation rule. A solver result alone is not promoted to Section 01.

The [recorded receipt](../../instrumentation/rank1-backward-search/expected-report.json)
includes source and query hashes, branch decisions and exact unresolved calls.
Seven tests passed, including a deliberate wrong copy destination that breaks
the expected predecessor result. Both US and JP pass the required search checks.

The unchanged Coq boundary also passed the existing pipeline audit
`20260927-064920-s4mqqy7k`: 620 registered sources, build, proof-hole and link
checks, and the two selected assumption checks below. Each uses seven allowed
foundations; 448 of 542 proof modules are in the main import closure, with 94
standalone modules. This passing audit does not verify the Python interpreter
or discharge a new capstone condition.

- `MainTheorem.current_rank1_six_residual_audit_boundary`
- `Rank1PlatformInstallation.r1o_final_query_connects_raw_position_to_owner`

The existing [query-to-owner proof](rank1-final-platform-query.md),
`InkRetryQuery.v`, `InkRetryCompletion.v`, `InkFloorResetExecution.v`,
`InkFloorResetCopy.v` and `InkRawCopyHeight.v` remain the formal boundaries to
reuse. Their unproved caller and gameplay conditions have not been erased.

## The next bounded connection

Follow the high cached floor value into the floor snap during the accepted-warp
action: start with the actual geometry result, carry it through the reached
interaction and animation calls, and account for the later action-tail and raw
copy. Expand a reached call or use a proved effect at its exact boundary; never
fill the gap with a blanket preservation rule. Keep live floor selection,
low earlier contact and useful top timing explicit. This is the next connection
suggested by the backward conditions, not a new assumption or a promise of a
complete no-A route result.
