# Impossibility proof: what is connected, and what is missing

> Consolidated: 2026-09-09. This is a proof-progress ledger, not a new route search.

We have a checked **conditional impossibility argument**, not a completed
impossibility proof for every allowed way of playing. No clean no-A
counterexample has been established either. Much of the existing work proves
useful restrictions on individual mechanisms; the largest unfinished task is
showing that the real game always meets the conditions of those restrictions.

The consolidation now exposes the six remaining movement families separately
in the final Coq argument. Coq checks that the new list is equivalent to the
old combined requirement: nothing was silently removed. **This makes the gaps
trackable; it does not close any of those six families.**

## The argument we are trying to finish

Start at the agreed moment outside the pyramid. Follow one continuous game
history, preserving its actual inputs, objects and collision checks. Work
backward from any newly awarded target star to the necessary contact. Explain
the first time that contact becomes possible: either a new A press occurred,
or one of the remaining movement families supplied another way through. If
every such alternative is excluded in that same history, collection without
a new A press is impossible. The claim applies to either target separately;
we do not require both stars in one run.

## The main unfinished connections

These are stable tracking IDs, not percentages or equally sized tasks.

| ID | What must be established | What we already have | Status |
| --- | --- | --- | --- |
| B0 — Starting boundary | Connect the accepted Area-1 start to the state required by the final argument, or extend that argument to cover a different entry. Keep the same history throughout. | The accepted outside start fixes useful position, input and memory facts. The existing final theorem instead takes a clean **inside-pyramid** entry, with its specified objects and entry snapshot. Those are different conditions. | **Connection open.** An unusual entry must not be discarded merely because it fails the clean-entry conditions. No castle-entry proof is required. |
| E1 — Faithful execution | Account for the actual inputs, movement, object changes and relevant checks, in order, for every allowed history. | A framework for recording real execution, local call proofs, and authenticated finite recordings. | **Whole-history connection open.** Recorded frames and independently constructed call prefixes are not universal coverage. |
| C1 — First useful contact | Connect the actual star award or secret credit to its contact, then explain the first useful contact without assuming the familiar pole or elevator route. | Collection bookkeeping, contact-search and credit-call pieces; the new same-call proof derives contact calculations from actual object readings rather than supplied intermediate values. | **Live connection and exhaustive classification open.** Object identity/position history and the exact distance-helper effect remain; general successful overlap also needs two height readings preserved. |
| W1–W6 — Remaining ways through | Exclude every remaining movement family at that first useful contact, using the local results only where their conditions really hold. | The six separate requirements below, now connected to the conditional final theorem. | **All six family-wide requirements remain open.** Local exclusions within them are real progress, but not family-wide closure. |

B0 deserves particular attention: the agreed boundary is not permission to
assume the eventual pyramid entry is ordinary. A displaced entry is exactly
what several Ink and platform approaches seek. The current final theorem
cannot reject those approaches just by requiring its usual entry snapshot.
Likewise, a statement that begins with a clean entry is not yet the complete
Area-1-start claim.

The 2026-09-10 [contact-memory connection](notes/rank12b-cross-barrier-contact.md#same-call-memory-connection-2026-09-10)
removes the six intermediate-value assumptions from a stronger construction
interface in `MainTheorem.v`. Those values now follow from actual entry
reads, the reached distance-helper call and the later height reads in the
same execution. It also moves the gate-interior exclusion to a complete
contact call. This is a local C1 refinement, **not** a discharge of E1 or any
of W1–W6; importing this interface does not automatically instantiate the
final theorem's execution/classification obligations.

## Eyerok selected-flight connection — 26 September 2026

`EyerokRank15PoundFlight.v` now constructs the real US/JP movement-helper prefix from body entry through velocity, clamp and Y stores. The ten specified rounded flight steps derive their outputs, and disjoint Mario cells are framed. The extracted airborne action leaves memory unchanged while rising and installs `-20` gravity while falling. Under the selected upright closed-hand and integral-seed-through-31 envelope, the ride/reboard payoff is still at least seven units short of the tunnel. This is a local execution construction plus a finite flight certificate and conditional payoff theorem; floor/water work, contact, impact/reset and between-call coverage are still required for the whole cycle. The result is consumed by `current_rank15_memory_faithful_projection_boundary`; none of W1–W6 is closed by it. Details are in the [selected-flight note](notes/rank15-eyerok-controller-ride.md#selected-double-pound-flight-actual-velocity-and-height-updates).

## Results already used by the final argument

These are actual dependencies of the existing collection/first-contact
argument, not just other files imported alongside it. Their verdicts apply
**once the faithful execution account and its conditions are supplied**.

| Existing result | What it rules out in that account | What it does not settle |
| --- | --- | --- |
| Collection and puzzle-credit bookkeeping | The target reward appearing without the required collection event; Puzzle collection without its required spawn and trigger history. | That every real award and credit has been connected to these events and their actual collision records. |
| Ordinary instant-warp displacement | The ordinary Area-2/Area-3 instant warp itself adding a movement displacement. | A changed support or later movement caused by the area transition. |
| Target-object identity | A certified collection or upper-secret credit using an object with the wrong required origin. | Deriving those object identities and their lifetimes from every live run. |
| Ordinary trigger and puzzle-spawn bookkeeping | The checked trigger consumption or puzzle-star spawn violating its recorded bookkeeping rules. | A movement change caused by unloading, reuse or another lifetime transition. This remains W6. |
| Coherent save reload | The checked reload being the first source of a previously absent target reward. | Establishing the same save history and effects in the live execution. |
| Consistency of the execution account | A certified event simultaneously having no matching certified step. | Constructing that faithful account in the first place. |

The small-step/game-event connection matters here. A restriction built into
the recorded game-event rules is not, by itself, a proof that every real
instruction obeys it. E1 is where that connection must be justified.

## Local results to reuse in the six remaining families

An atlas route can belong to more than one family. Ink, for example, can
involve ordinary movement, platform effects, collision timing and object
lifetimes. Closing one family would not automatically close the whole route.

| ID and family | Checked pieces available for reuse | What still prevents family-wide closure |
| --- | --- | --- |
| W1 — Mario's own movement and ordinary terrain | Ordinary-motion bounds; pole-exit and elevator cases; animation, floor-alignment and negative-depth reductions. | Cover every reachable action and launch state, including held-A history, every relevant collision check, and the position actually used. Negative depth still needs its first useful producer traced through one complete history. |
| W2 — Moving or remembered platforms | Stock platform-selection restrictions; the ordinary upper-warp platform-null subcase; signed-coordinate platform results; Eyerok height, support and schedule results. | Establish the real selected floor and platform, their motion and continued lifetime, and that every reached frame satisfies the stock restrictions. A bounded schedule search is not every possible schedule. |
| W3 — Objects and moving geometry pushing Mario | Object-impulse and shocked-stall cases; ground-pound/moving-geometry checks; enemy-placement and hand-motion restrictions. | Cover live contact timing, object placement, combinations and changes of support, rather than a staged pose or one isolated action. |
| W4 — Collision allowing a crossing | Float32 collision-phase restrictions, pole/elevator query checks, and necessary object-contact tests. | Connect every wall, floor and ceiling choice, including intermediate movement and first-frame contact. A visual barrier alone does not exclude collection through it. |
| W5 — Distant positions sharing a collision coordinate | The bounded ordinary static-step alias exclusion, plus the conditional platform-alias payload and stock installation restrictions. | Show every live candidate obeys the bounded or stock conditions, or classify its other defined movement source. The useful arithmetic payload is not proof of a clean installation. |
| W6 — Area changes and object lifetimes changing access | JP slot/first-apply restrictions, spawn/lifetime receipts, changed-support and reload cases, and Rank-1 owner/list restrictions. | Follow every relevant transition, remembered floor, reused object and selected support in the same run. Ordinary bookkeeping is already excluded above; movement during a lifetime transition is not. |

These rows point to the consolidated boundaries in
[`MainTheorem.v`](../proofs/MainTheorem.v), rather than treating each imported
boundary as already used by the final no-star theorem. The narrow static-alias
result is in [`FirstTargetRefinement.v`](../proofs/FirstTargetRefinement.v);
the stock upper-warp platform-null result is in
[`FirstCrossingWriterCoverage.v`](../proofs/FirstCrossingWriterCoverage.v).
Neither currently discharges its whole W2/W5 requirement.

## Stronger results and conditional successes that must stay distinct

**Writable action tables.** The
[selected-program table theorem](../proofs/WritableActionTableReachedExecution.v)
does cover every successful finite execution from its specified initialized
start; its former per-step table-coverage premise has been proved. That is
stronger than a local case. Applying it to the accepted Area-1-start route
still requires matching its program, initialization and history. It neither
closes all movement families nor supplies an arbitrary boundary's missing
initialization facts.

**The current negative-depth work.** The accepted outside memory supplies zero
depth. A real action-call prefix has been constructed from that memory, and
the first graphical flag update is proved not to change Mario's depth. The
connection from the scheduler to that call, later helper effects, action
transitions and controller history remain open. This is **local progress**,
not a whole-history proof that a useful negative depth requires a new A press.
The [shared negative-depth ledger](notes/negative-depth-shared-closure.md)
lists the exact reusable pieces and missing connections.

**Conditional installations and downstream collections.** A checked useful
payload, movement after a supplied Ink setup, or a route starting beyond the
pole/elevator gate establishes a consequence of that setup. It does not prove
that a no-A controller history reaches the setup. Keep these results: they
identify what a counterexample would need to achieve. Do not count them as
impossibility results or as clean counterexamples.

**Model limits.** All verdicts retain the
[execution-scope boundary](compcert-execution-scope.md). Ordinary gameplay and
defined glitches remain in scope. Outside-model memory/code modification,
DMA and execution after undefined behavior are neither investigated here nor
disproved for retail hardware. Program-selection and retail correspondence
requirements remain visible in the [checklist](checklist.md); this
consolidation does not establish a hardware theorem.

## How to record future progress

Use **integrated conditional result**, **local case closed / live connection
missing**, **whole-history family closed**, or **route closed**. A route is
closed only under its stated boundary and model after all its relevant
connections are proved. An accepted observation may settle its recorded facts
without establishing a theorem about all other runs.

For each update, name B0, E1, C1 or W1–W6; name the existing result reused;
state which same-run condition was actually derived; and say what remains.
If only a condition was named or restated, record a clearer specification,
not a removed proof gap. If one run was checked, record that run's coverage,
not all-controller coverage. Do not measure completion by theorem count,
import count, successful compilation, or a percentage of atlas entries.

## Coq wiring and this consolidation

The new [`ImpossibilityResiduals.v`](../proofs/ImpossibilityResiduals.v)
provides `RemainingNoAWriterObligations`, with one field for each W family.
`remaining_no_a_writer_obligations_equivalent` proves it has exactly the same
strength as the previous combined
`NoAOpenRouteWriterClassesUnreachableObligation`. Every field retains the same
run, memory-bearing certificate, route trace and no-new-A input condition.

The new `conditional_consolidated_clight_run_impossibility` in
[`MainTheorem.v`](../proofs/MainTheorem.v) consumes that record through the
existing no-star argument. It reuses the already-integrated exclusions above
and still explicitly requires E1, C1 and a clean pyramid entry. No placeholder
proof or stronger start assumption replaces those requirements.
The regular [proof audit](proof-audit.md) now checks this consolidated entry
point by default, so future changes continue to build and audit the assembly.

**2026-09-09 tranche:** consolidated the final argument's remaining movement
requirements, preserved the old interface, and mapped the reusable local
results and the Area-1/inside-entry distinction. No new controller route was
searched, no family-wide requirement was discharged, and neither target's
overall impossibility claim was completed.

**Verification:** the Coq build, proof-hole and link checks, and assumption
audits of both the equivalence and consolidated final theorem passed. Each
assumption report contains only six already-allowed foundations. All 26
audit-script tests passed, and the ledger's relative links resolve. The local
audit receipt is `build/audit/20260909-185208-7aqvu9f5/`. These are checks of
the consolidation, not evidence that an open gameplay requirement is solved.
