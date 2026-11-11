# Coq and the remaining timer-130 gameplay connection

Neither a clean no-A route to the timer-130 handoff nor its impossibility is
established. The successful supplied-state installation shows why simply
comparing Mario's height with the warp height cannot exclude the route.
What remains is a continuous history that produces the high crawler, the
item and their timing together. The new proof work below concerns actual
generated US/JP code at named points in that history; it does not turn the
earlier bounded searches into an exhaustive gameplay theorem.

This follow-up starts at proof commit
`2811914c93272b2d9d5b3b351ab016cae6abd057`. It uses source and existing records,
with no new gameplay experiments. The existing
[timer-130 geometry and quarter-tail analysis](ink-timer130-handoff.md) and
[forward item/teleport investigation](ink-handsfree-forward-and-teleport.md)
remain the empirical and geometric context.

Source anchors: the drop and throw distinction is at
`reference-sm64-decomp/src/game/interaction.c:295–332`; the later floor clamp
and dropped-object callback are at `src/game/object_helpers.c:1067–1113`
in that same source checkout. The Coq modules below use the existing pinned
generated US/JP functions and selected global environments.
They prove claims in that selected Clight semantics; this follow-up does
not add a source-to-retail-ROM refinement theorem.

## Why the existing impossibility theorem does not answer this yet

`MainTheorem.conditional_consolidated_clight_run_impossibility` explicitly
requires a faithful whole-run refinement, a first-useful-contact
classification, and `RemainingNoAWriterObligations`. That record still
requires coverage of Mario movement, platforms, object pushes, clipping,
distant-coordinate effects and lifecycle changes. Its `CleanPyramidEntry`
premise also describes the inside-pyramid entry, not the accepted outside
start from which we are trying to produce Ink. Assuming that entry is
ordinary would discard the unusual arrival we are investigating.

These are explicit theorem premises, not hidden Coq axioms. A clean
`Print Assumptions` result therefore does not discharge them. The relevant
statements are in [MainTheorem.v:1835](../../proofs/MainTheorem.v#L1835),
[ClightRefinement.v:233](../../proofs/ClightRefinement.v#L233),
[ImpossibilityResiduals.v:29](../../proofs/ImpossibilityResiduals.v#L29) and
[CleanEntry.v:34](../../proofs/CleanEntry.v#L34). The broader
[progress ledger](../impossibility-proof-progress.md) records the same gap.

A positive gameplay theorem would need one permitted continuous execution
from the accepted Area-1 state, with its input history and actual object
identities, reaching the useful handoff and continuation. An impossibility
theorem would need an invariant or complete classification covering every
permitted such execution. Neither is supplied by the existing high-state
fixture, by an unsuccessful finite search, or by a new local call theorem.

## How the local proofs can guide a route search

The item and Mario do not have to solve the same problem at the same time.
For example, native release could position an actor earlier; Mario could
later arrive in crawl. But the proof must keep that actor alive and in the
right place through the intervening updates. The hands-free teleport orphan
is another case: it can be tangible and push without becoming free. A theorem
about ordinary drops must not silently exclude that alternative.

The drop/throw distinction is especially important. The actual
`mario_drop_held_object` writes X/Z from the remembered hand position but Y
from Mario's movement position. The separate `mario_throw_held_object` uses
the remembered hand Y. Thus a high hand position does not by itself make a
high **drop**. This is not a statement about every release or about the
actor's later behavior: the dropped-object callback can clamp it to a floor
or apply the out-of-bounds fallback, and object-specific movement and
explosion rules run afterward.

For the crawler, the useful collision is a **stopped first quarter**. The
timer-130 candidate has proposed Y=1741, a local floor result of 1280 and a
ceiling result of 1523, while Mario's remembered floor can still be 768.
The local answer and the remembered cache are separate. The existing tail
proof checks the ceiling stop before the candidate position or floor is
committed. Extending that proof backward is useful because it checks that
earlier guards do not secretly replace the cache or send execution down a
different path. It still does not create the initial high crawling state.

At these exactly representable heights, the tested comparisons are
1741 > 1280 + 100 and 1741 + 160 >= 1523. The quarter-step code retains
these 100/160 constants while crawling; they are distinct from the
crawler's object-contact hitbox. See `src/game/mario_step.c:258–335`.

## Actual item-drop placement

[InkItemDropPlacement.v](../../proofs/InkItemDropPlacement.v) follows the
non-null branch of the actual generated `mario_drop_held_object`.
`idp_actual_drop_call_exposes_placement` extracts the reached placement point
from a completed real function call with a non-null incoming held pointer.
The earlier music/held-state helper
calls remain part of the actual prefix; the theorem does not assume that
they preserved the incoming Mario height or held pointer.

At that placement point, `idp_drop_tail_places_at_movement_y` requires the
real `_m` argument, a held pointer at a standard in-range object-slot offset, distinct
MarioState and Object-pool blocks, a readable movement Y, and completion of
the actual placement tail. It proves all three final facts:

* The actor's Y equals that movement Y.
* Mario's movement Y is unchanged through the placement tail.
* Mario's held pointer is null.

The bounded slot condition describes storage layout; it does not identify
that block with the selected global pool or establish the actor's live
behavior, type or remaining fuse. The normal pool case is covered when
those additional gameplay facts hold.

X/Z and yaw stores are included in the proof and shown not to overwrite the
relevant Y/pointer cells. `idp_drop_cannot_substitute_a_different_holp_height`
therefore excludes a different desired actor height at this endpoint,
without assuming any bound on the remembered hand height. For example, a
low Mario movement record and a high hand record alone cannot produce a high
drop through this code.

The proof is not solely an implication about a hypothetically completed
assignment: `idp_y_placement_exists` constructs the actual Y-stage execution
from the readable Mario/held-pointer cells and a writable actor-Y cell. This
construction covers the Y stage. The whole placement-tail theorem still
requires its completed execution, and the whole-call theorem requires the
completed real drop call. Neither constructs a reachable gameplay drop.

The full-call statement deliberately reads the material height and held
pointer at the reached post-helper point. It does not silently equate those
values with function-entry memory. The later dropped-object callback, floor
clamp, out-of-bounds fallback, actor lifetime, throwing and HFT-orphan behavior
remain outside this result. In particular it is not a general upper bound on
an actor's height in the next update.

## Earlier crawl-quarter execution

[InkCrawlQuarterPrefix.v](../../proofs/InkCrawlQuarterPrefix.v) starts
immediately after the quarter's query prefix, before the real wall-pointer
assignment. The earlier theorem began later, after the missing-floor and
water handling. `icqp_post_query_973_executes` constructs the additional
generated statements and then the existing stopped tail.

Its material conditions are explicit: the selected US/JP environment; the
Mario and intended-position pointers; proposed Y=1741; local returned floor
height 1280 and ceiling height 1523; a non-null weakly valid floor pointer in
the query-output local; a readable action with the riding-shell bit clear;
a null-or-pointer wall value; and writable wall storage. The query-output
and intended-position blocks are separate from MarioState, as in the normal
local-storage arrangement. They describe the current query-return memory;
they do not prove where the remembered cache came from or that it was
established during this update.

The only memory change in this constructed section is the actual wall
pointer store at MarioState bytes 96–99. Other non-overlapping loads are
preserved. In particular, the action, movement coordinates, remembered floor
pointer at offset 104 and remembered floor height at offset 112 survive.
The queried local floor is not installed into MarioState on this branch.
An incoming remembered Y=768 is therefore compatible with this section's
stopped result; it is not assumed to equal the local query's 1280.

`icqp_crawling_preserves_768_cache` specializes that result to the actual
generated crawling action, movement Y=1741 and remembered height 768. The
action value and its clear riding-shell bit are checked against the US/JP
moving-action dispatch, rather than chosen as an unrelated numeric tag.

`icqp_queries_to_caller_break_and_frame` then connects the real quarter
callee to the real caller's result assignment and break gate. It does not
assume that an independent caller temporary happens to contain result 2.
Instead it requires actual function entry, execution of the five generated
query-prefix statements, the resulting query-cut conditions, the wall store
and successful local-variable cleanup. From those it constructs the quarter
returning 2 and the caller reaching `Out_break` with the same trace. The
caller must have its actual intended-position array and Mario pointer, and
must resolve the global quarter function without local shadowing. This
starts after the caller's intended-coordinate setup; it does not construct
that earlier setup or the enclosing whole ground-step loop.

The five prefix statements contain the lower and upper wall-resolution
calls, the floor call, the ceiling wrapper and the water query. In
particular, earlier wall resolution may change the intended vector; the
theorem's Y and floor/ceiling conditions describe their actual outputs.

The stronger return-frame result additionally requires MarioState to be an
already-valid block before function entry. The actual fresh local allocations
then cannot free it. All its non-wall loads are preserved from the query
return through the callee's local-variable cleanup to the caller. Thus the
position/action/cache preservation is not stranded inside the callee. This
cleanup concerns C local variables, not the spinning top's later object-slot
freeing. The actual query prefix and its effects before the cut remain
unframed and explicit.

This is conditional local possibility: the code section has an execution
with the desired stop and cache preservation under its stated conditions.
It does not derive the live wall/floor/ceiling/water query results, the
already-established high crawl, the pushing actor or the spinning timer.
The theorem has no timer field premise or conclusion: its numeric cut is
the one associated with the timer-130 records, not a proof that gameplay at
timer 130 produces those numbers.

## Remaining gameplay obligations

1. Reach a suitable high Mario state through permitted inputs, then establish
   crawl at the required point. The existing clean low crawls and conditional
   Y=256 orphan crawl do not supply Y=1741. The action must also reach its
   ground-step call: `act_crawling` first checks sliding, first-person input,
   A, dive/punch, `INPUT_UNKNOWN_5` and held Z
   (`src/game/mario_actions_moving.c:1247–1278`). Absence of an A press alone
   does not establish all those other guards.
2. Deliver a real actor and either release it with enough useful lifetime or
   retain a tangible orphan. Use the actual drop/throw/behavior distinction;
   a held pointer, actor-held flag and tangible free actor are different states.
3. Establish the usable remembered Y=768 floor and pointer during this
   update's initial geometry preparation. Then perform the eligible push
   while preserving that cache and the required action. The later quarter
   queries must produce their separate local floor 1280 and ceiling 1523.
   This requires the floor pointer's geometry, not merely a word containing
   768; an earlier update's floor cannot be silently reused.
4. Connect the actual query calls, stopped quarter, display refresh, floor
   alignment and copies in one memory history. Locally compatible conditions
   are not automatically produced together.
5. Prepare the pillars and make upper-warp contact at a useful spinning phase.
   Follow the remembered top through explosion, freeing, allocation and first
   Area-2 apply in that same history. The old timer-131 counts are not a
   universal allocator theorem for a differently timed item route.

The local claims are input-independent. They neither require A nor construct
a no-A controller sequence. The project's `fewer_than_one_a_press` means no
new A edge in a coherent input history; its existing policy can allow A held
at entry. The earlier clean component recordings use the stricter released-A
controls. No change to either scope is made here.

## Integration and theorem index

Both new modules are registered in `_CoqProject`. Their checked boundaries
are explicit conjuncts of `InkStoppedFloorProducerCheckedBoundary`, consumed
by `MainTheorem.current_ink_stopped_floor_producer_boundary` and the broader
concrete-producer boundary. This is logical consumption of the local
results, not a proof that their executions compose into one game update.
No remaining whole-run writer requirement is discharged.

Exact source entry points are
[item Y-stage construction, line 161](../../proofs/InkItemDropPlacement.v#L161),
[completed placement, line 370](../../proofs/InkItemDropPlacement.v#L370),
[actual-call extraction, line 471](../../proofs/InkItemDropPlacement.v#L471),
[height exclusion, line 528](../../proofs/InkItemDropPlacement.v#L528),
[post-query construction, line 161](../../proofs/InkCrawlQuarterPrefix.v#L161),
[crawl-cache preservation, line 333](../../proofs/InkCrawlQuarterPrefix.v#L333),
[caller break and frame, line 502](../../proofs/InkCrawlQuarterPrefix.v#L502)
and [MainTheorem consumption, line 1606](../../proofs/MainTheorem.v#L1606).

| Claim | Statement / proof |
| --- | --- |
| Constructive item Y stage | `InkItemDropYStageExists` / `idp_y_placement_exists` |
| Actual completed drop placement | `InkItemDropPlacementTail` / `idp_drop_tail_places_at_movement_y` |
| Extract placement from the actual non-null call | `InkItemDropActualCallBoundary` / `idp_actual_drop_call_exposes_placement` |
| Exclude a different desired drop height | `InkItemDropDifferentHeightExcluded` / `idp_drop_cannot_substitute_a_different_holp_height` |
| Construct the earlier stopped-quarter section | `InkCrawl973PostQueryExecution` / `icqp_query_cut_executes` |
| Preserve crawling state and the 768 cache | `InkCrawl973RememberedCachePreservation` / `icqp_crawling_preserves_768_cache` |
| Actual quarter return, caller break and return-memory frame | `InkCrawl973QueriesToCallerBreakAndFrame` / `icqp_queries_to_caller_break_and_frame` |

## Checks and outcomes

The environment was rechecked: Ubuntu WSL, `sm64-item-proof`, Coq 8.16.1 and
CompCert 3.15. All builds use the repository pipeline with its unchanged
6,815,744-KB virtual-memory cap. No generated program is reduced wholesale,
and no new axiom, `Admitted` or proof hole is introduced.

Before editing, the selected audit of
`MainTheorem.current_ink_backward_execution_boundary` and
`MainTheorem.current_ink_stopped_floor_producer_boundary` passed in
`build/audit/20261111-134120-six0bxqz`: 706 source files, build exit 0,
9/7 allowed foundations respectively, and 540 of 626 proof modules in the
MainTheorem import closure with 86 retained standalone modules.

The targeted commands, run from the Windows workspace, are:

```powershell
wsl.exe -d Ubuntu -- bash -lc "cd '/mnt/c/Users/tariq/OneDrive/Documents/sm64 - the item-grab proof/reference-sm64-wmotr-abc-proof/SSL-Coq/less-than-one-a-press' && bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/InkCrawlQuarterPrefix.vo"
wsl.exe -d Ubuntu -- bash -lc "cd '/mnt/c/Users/tariq/OneDrive/Documents/sm64 - the item-grab proof/reference-sm64-wmotr-abc-proof/SSL-Coq/less-than-one-a-press' && bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/InkItemDropPlacement.vo"
```

Both targeted builds completed with exit 0.

The integrated selected audit command is:

```powershell
wsl.exe -d Ubuntu -- bash -lc "cd '/mnt/c/Users/tariq/OneDrive/Documents/sm64 - the item-grab proof/reference-sm64-wmotr-abc-proof/SSL-Coq/less-than-one-a-press' && bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 LessThanOneAPress.Proofs.MainTheorem current_ink_stopped_floor_producer_boundary LessThanOneAPress.Proofs.InkItemDropPlacement ink_item_drop_placement_checked LessThanOneAPress.Proofs.InkCrawlQuarterPrefix icqp_crawl_quarter_prefix_checked"
```

**Result: PASS, exit 0**, in
`build/audit/20261111-141612-ipvkl1w8`. The inventory contains 708 source
files with no problems. The main/dependency build, proof-hole scan and
generated-link checks pass. All three requested assumption queries pass
with seven allowed existing foundations each. Integration reports 542 of
628 proof modules in MainTheorem's import closure, 86 retained standalone
modules and zero problems. This was a selected dependency build, not a
full rebuild or assumption audit of every standalone theorem.

The seven reported foundations are `Axioms.proof_irr`,
`ClassicalDedekindReals.sig_forall_dec`,
`ClassicalDedekindReals.sig_not_dec`, `Classical_Prop.classic`,
`Events.external_functions_sem`, `Events.inline_assembly_sem` and
`FunctionalExtensionality.functional_extensionality_dep`. There is no new
project axiom. These reports do not erase the explicit execution, storage,
query and reachability premises explained above.

The SSL atlas and private Pyramid Fine Print site retain the open gameplay
verdict, all 45 estimates and their four single-paragraph summaries. Rank 1
remains subjectively **1–2%** and Ink Rank 2 **<1%**. No new original-ROM
run, successful no-A route, complete item-lifetime proof or all-history
exclusion is claimed.
