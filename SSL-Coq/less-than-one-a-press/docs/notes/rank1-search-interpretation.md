# What the backward search can settle about Ink

27 September 2026. The user has deferred the requested one-update search
while reviewing its purpose. This explanation adds no search, theorem,
exclusion or route estimate. The [original search remains unfinished](rank1-complete-update-path.md).

## What we already know

**Ink works from a supplied setup in JP.** The
[original-game recording](ink-vertical-installation.md) starts with actual
and raw collision position `(-2200,768,-1024)` and display position
`(-2200,1938.8648681640625,-1024)`. It supplies these positions and the pillar
setup, with zero quicksand depth. It does not supply the floor result, owner,
disappeared action or warp outcome. The first query misses, the retry finds
the top, the warp is accepted, the top survives as the remembered platform,
and its first Area-2 application moves Mario outside the elevator. The
recording reaches one puzzle secret, not either target star. No A is used
after the supplied boundary; the preceding controller history is unproved.
The JP payoff does not transfer automatically to US, whose entry code clears
the incoming platform reference.

**The 1,170.8648681640625-unit gap belongs to that example.** It is not a
proved minimum for every possible Ink installation. Excluding only that
height pair, X/Z or timer would leave other possible targets open.

**The separation does not need to last forever.** Collision uses the low
raw position, the retry lifts actual Mario to the old display position, and
a later ordinary copy raises raw Object position before final platform
selection. Actual and display agreeing after the retry is compatible with
Ink. All three records need not differ; later agreement does not itself undo
the remembered platform.

**Several links are Coq-proved, with explicit execution and storage
conditions.** `InkRetryCompletion.v` and `InkRetryQuery.v` connect the actual
US/JP display copy to the real second query without granting its result.
`InkVerticalLiveSelection.v` separately checks the recorded ordered floor
lists and selection; it is a finite snapshot certificate, not all live
lists. `Rank1FinalPlatformQuery.v` and `Rank1PlatformInstallation.v` connect
the final raw-coordinate reads, real floor call and returned owner's two
stores. For an owned floor, the rounded height difference must be less than
four. Raw Y=768 fails for this checked top. The floor-query allowance of 78
units is not this retention test, and a query is not a landing. The final
owner-selection branch does not require an active owner.

The [exploratory backward calculation](rank1-backward-search.md) checks the
exact binary32 retention band for this returned top height:
`1934.864990234375` through `1942.86474609375`, inclusive. This full-band
solver check is distinct from the Coq body/guard connection. The newer
supplied-scene application test follows a full US/JP controller-to-retention
path, but supplies more state than the original JP experiment, including
the disappeared action, stopped top and finite scene. These are different
receipts and should not be conflated.

**Some named producers are insufficient at their proved checkpoints.** The
ordinary ground display copy and normal Tweester continuation leave zero
movement/display height gap at their completed copies. The stopping helper
sets movement and display Y to its incoming cached floor height; a high old
display cannot override a low cached floor there. Earlier retries and later
writers remain separate. The full platform phase preserves display and raw
collision coordinates even when actual Mario moves. Therefore “movement
while display survives is impossible” is the wrong claim. The
[gap comparison](ink-gap-backward.md) keeps source checks and finite bounds
separate from execution proofs.

**A legal producer is still missing.** From the accepted initialized start,
an allowed history must combine low contact, first floor loss, useful
display, appropriate action and top timing. General live selection, object
lifetime and the first Area-2 application remain unproved for other
histories. A supplied setup does not establish the complete two-star route.

## What an unsuccessful search would mean

| Outcome | What it establishes |
| --- | --- |
| Timeout, `unknown`, unsupported call or unexplored branch | The search is unfinished. No exclusion of the unexamined cases. |
| No witness among sampled predecessors or inputs | Only the checked samples failed. The same applies to unsuccessful Reverse Scattershot trials. |
| Every predecessor/input in a declared bounded domain is covered, with no target reached | A bounded exclusion after validating the encoding. Earlier gaps, different scenes or target variants remain outside it unless included. |
| A necessary predecessor contradicts a proved property of every history in a named gameplay family | That whole family is excluded, even if it has arbitrarily many input sequences or lasts longer than the search window. |

The interpreter is exploratory, not Coq-verified. Even a completed
unsatisfiability result needs a sound connection to real execution and its
domain before becoming a formal impossibility claim. A practical route is
to extract the decisive obstruction and prove it against the generated code.

A locally valid predecessor may already contain the unexplained gap. It
needs a controller replay from the accepted start or a separate reachability
argument before it is a gameplay counterexample. The known successful
supplied scene means that a predecessor domain including it cannot correctly
be empty for its supported retention target. The exclusion must explain why
allowed gameplay cannot reach the surviving conditions.

One update can still support a global result: if its starting domain is
proved to contain every reachable pre-update state and no allowed input can
enter the target from it, that target cannot first be reached in any update.
It must also be absent initially. Establishing that covering, preserved
state property is the invariant work. Simply assuming synchronized positions
or removing useful gaps from the starting domain would not establish it.

## Use backward requirements to exclude whole approaches

The following are proposed proof uses, not newly completed results:

| Required condition | A family could be excluded by proving… | Remaining connection |
| --- | --- | --- |
| Useful raised display at the retry | Every member reaches a proved refreshing copy first, and cannot recreate sufficient separation before the retry. | Derive the last writer and the effects throughout that interval. |
| A high stopping-floor snap | Every reached cached floor height is outside the needed band, with no later writer repairing it. | Derive the actual floor and subsequent effects; do not assume a low cached height. |
| Low contact followed by a high final raw query | The family's timing and writers cannot supply both samples in that order. | Do not assume the two samples agree; their disagreement is the proposed mechanism. |
| A first miss followed by useful top selection | Every allowed query in this retry family either finds a first floor or fails to select the useful top later. | Derive corrected coordinates, live lists and timing; inactivity alone does not exclude the owner. |
| Support remembered through the warp | Every member clears or replaces the reference before its useful Area-2 application, with no helpful later recapture. | Follow the actual owner, lifetime and apply. An earlier clear alone is insufficient. |

Existing local proofs provide starting points for these interval-wide
claims. To close one named approach, cover its actual domain. To close every
Ink installation, prove that the families and target variants exhaust all
allowed alternatives. A list of familiar mechanisms is not that coverage
proof. This can be a shorter route to an exclusion than enumerating every
controller sequence, but it remains work to perform.

## What one update can tell us about cost

At 30 nominal updates per second, three seconds is 90 updates and five is
150, ending at top retention. A complete search can measure its own time,
peak memory, surviving predecessor groups and unresolved obligations. One
depth cannot establish the cost of 90 or 150: groups can merge, split or
encounter more complicated code. Multiplying a selected-path time by the
number of updates is not an exhaustive-search estimate. Additional shallow
depths would be needed to measure growth before making a credible projection.

Reverse Scattershot can prioritize which valid predecessors to extend when
the surviving set grows too quickly. It cannot repair missing semantics,
make an unreachable supplied state reachable, or prove impossibility from
an empty sample. Backward-derived obstructions can guide either a randomized
witness hunt or direct family proofs. No new one-update run or randomized
search is launched by this review.
