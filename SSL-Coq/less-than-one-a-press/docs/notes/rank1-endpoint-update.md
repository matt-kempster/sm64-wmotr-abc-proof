# Rank 1: working backward from the retention checkpoint

27 September 2026. **Complete one-update predecessor coverage is still not
established.** This batch repairs and runs the endpoint-first application. It
does not substitute a forward controller trial, supplied scene or known prefix.
No Coq theorem or route verdict changes. Rank 1 keeps its subjective **1–2%**
estimate; this is not a measured probability.

## Accepted policy: search conditionally, validate candidates afterward

The user has accepted unanswered call effects and earlier-state validity as
conditions for candidate generation. We can continue the backward search without
first proving these conditions for every represented state. Each proposed result
must keep its unresolved conditions visible and be validated before it counts
as a gameplay result. This permission does not assert that the conditions are
true, change a missing call into a no-op, or supply a reachable starting pose.

The runner now distinguishes three answers: **SAT is a conditional candidate**;
**UNSAT excludes only the encoded conditional query**; **unknown is inconclusive**.
None closes Ink by itself. The search can finish a conditional query while
certified gameplay coverage remains zero. A timeout still needs a computational
repair; relabeling it does not produce a candidate. The earlier US/JP timeouts
below remain unchanged, and no additional game search accompanies this policy
change.

For a candidate, check the concrete call effects it relies on, its live objects
and earlier state, and the extracted predecessor/input trace. Then test the
joined controller history in the emulator or Wafel, keeping the existing exact
observer for the decisive contact/query/warp checks. A symbolic match is not
automatically a replay-ready input sequence. A supplied-state local test can
validate a conditional segment but cannot establish how ordinary gameplay
reaches that state. Rejecting one candidate does not reject its whole family.

This is the working search policy, not a new conditional Coq theorem, a grant of
the useful gap or a promotion to Already proved. The current computational
obstacle is obtaining a solved predecessor proposal from the large formula.

Validation of this reporting change: all **79 application tests pass**. Three
new synthetic controls check that a conditional match can fail its call-effect
or state-validity check, and that unknown/failed runs never become completed
conditional queries. They are not gameplay trials. The original 76-check run
and its receipt below remain historical; no source formula was rerun merely to
apply a new label.

## What UNSAT would mean

UNSAT means there is no assignment of the encoded earlier state, inputs and
permitted call effects that satisfies the target. It is a logical exclusion
for that formula, not a report that some sampled candidates failed. If the
formula correctly represents a stated set of assumptions, this is a meaningful
conditional impossibility result for the question expressed by that formula.

Transferring that result to gameplay needs a direction-of-coverage check:
every real execution relevant to the claim must be represented in the model.
The model may include extra, impossible states without harming this direction.
If even the larger set contains no success, the real subset contains none.
Conversely, a model that silently omits a legal action, callback or earlier
state could return UNSAT while the game has an omitted solution.

This refines the earlier warning about unanswered calls. We need not know each
call's exact implementation to use a negative result if its modeled effects
are shown to include every relevant real effect. Extra freedom can produce
false candidates, but cannot hide a real success when that inclusion holds.
The current runner leaves many effects open; this fact alone does not establish
that the whole interpreter, memory representation and query cover the game.

The scope also matters. This query targets one original loop iteration and
the particular top-retention endpoint described below. It does not encode all
Ink endpoints. One-update UNSAT could rule out a whole named approach if every
valid immediate predecessor is covered and that approach necessarily passes
through this endpoint; a longer earlier history would not rescue it. Those
connections must be established rather than inferred from the length of the run.

SAT and UNSAT therefore need different follow-up. A candidate needs its actual
state, effects and replay checked. A negative result has no candidate to replay:
check the encoding, assumptions and coverage of the claimed case instead.
Accepting conditions for search does not turn an omitted legal case or a
translation bug into a valid exclusion. The recorded full US/JP attempts returned
**unknown**, not UNSAT. This explanation supplies no new route exclusion.
The reporting checklist now distinguishes these follow-ups; its three policy
controls pass. No new game query or Coq proof was run for this clarification.

## The exact question this runner asks

At the end of the selected Area-1 `update_objects` call, both platform
references must name the designated pyramid-top Object. The reached final
floor query must use X=-2200, Z=-1024 and return height
1938.8648681640625, with bits 1156733869. Mario and the top have symbolic,
distinct identities; the top keeps its pyramid-top behavior identity. We no
longer force the old isolated-test addresses, which need not fit the normal
Object pool. This target is a checkpoint toward Ink, not the whole installation:
warp acceptance, the earlier low contact and the Area-2 payoff are separate.
Reused-slot variants with a different behavior are outside this target.

The earlier cut is the beginning of one original `thread5_game_loop` iteration
in SSL Area 1. Earlier memory and retained thread locals remain symbolic. The
actual generated controller/action/scheduler/floor code is represented between
the cuts, with unanswered call effects still pending; the
runner does not insert a high display, negative depth, action or floor list.
An iteration that ends or continues without the checkpoint fails this query;
it is not silently replaced by a later update. The actual decoded controller
boundary must have no new A edge. Earlier physical controller history and a
connection to the accepted normal start remain separate obligations.

## What was repaired

- Actual pinned US/JP controller decoding, queue initialization, receive/send,
  SI access, clock and profiler C bodies replace several missing-body entries.
  Their hardware and scheduling callees remain explicit where unanswered.
- An atomic Clight external call can no longer pretend it visited an internal
  checkpoint or decrement the update counter. A complete generated call graph
  also identifies internal calls that cannot visit that checkpoint. Neither
  rule supplies a memory-preservation promise.
- All type-compatible linked callback targets remain represented. The tool
  does not assume writable script words or callback tables retain their
  initial contents. This conservative set includes alternatives that have
  not been shown reachable in SSL.
- Recursive local storage, forward jumps, switch fall-through and breaks,
  variadic pending arguments, and mixed-width integer arithmetic are handled.
  The arithmetic conversion was compared with CompCert 3.15's actual `Cop.v`.
- The wanted height constrains the selected retention occurrence; an earlier
  call to the same helper is not required to satisfy the final target.
- Global reservations use generated sizes instead of spending a megabyte per
  tiny variable. Missing external-array extents stay listed as obligations.
  Exact named formulas prevent repeated memory writes from blowing up the
  calculation. Expensive diagnostic export is optional and follows solving.

The application checks include all symbolic button/stick bits for the actual
one-controller successful-read decoder case, and the actual queue initializer's
six fields plus an arbitrary separate byte. Other checks deliberately try to
fake completion through an unanswered call, overwrite a parent's recursive
local, constrain an earlier floor call, or mis-handle switch fall-through.
These are regression and solver checks of the application, not new Coq results
or gameplay witnesses. Synthetic controls are never counted as controller runs.

## The completed attempt, and what did not complete

All **76 application checks pass**. Both versions now finish constructing the
source formula for one original loop iteration and reach the solver. Both
solver calls return **unknown, because their 30-second limit expires**. The
requested complete predecessor calculation is therefore **not finished**.

| Version | Source-body definitions constructed | Unanswered call sites | Total attempt time | Solver result |
| --- | ---: | ---: | ---: | --- |
| JP | 3,335 | 472 | 264.30 seconds | Unknown: timeout |
| US | 3,346 | 473 | 262.34 seconds | Unknown: timeout |

These are counts of application work, not histories, inputs or completed game
updates. The call-site totals include broad callback alternatives not shown
reachable in SSL. A constructed definition can itself contain unanswered calls.
Increasing the solver timeout alone would not discharge those calls or validate
the memory model. There is no certified complete update, rejected gameplay
family or price for an exhaustive longer search in this result.

The [compact receipt](../../instrumentation/rank1-backward-search/endpoint-update-report.json)
records the source and implementation hashes, full call-name counts and exact
result scope. Raw diagnostics are retained in
`build/rank1-backward-search/endpoint-one-20260927-k/`. Earlier attempts exposed
interpreter errors and formula-export bottlenecks; their failures are not
gameplay evidence. The final attempt performs no forward trials.

## Why the remaining calls cannot be answered by one replay

For example, the controller request now follows its real C body into DMA and
queue handling. The exact effect of `__osSiRawStartDma` and a reached
`__osEnqueueAndYield` is still required for the proposed earlier state.
An emulator observation settles its matched arguments, state and occurrence.
It does not settle every state represented by a symbolic call. No unknown call
is given a no-op or whole-memory frame, and no answer is borrowed merely because
the function name matches. The existing emulator adapter remains useful once
a particular candidate has a valid executable starting connection.

Other pending cases include assembly/library calls and variadic runtime
handling. Some are present only because live callback contents remain broad.
Their presence in the conservative source expansion is not evidence that
ordinary SSL gameplay can call them. A justified smaller live-call set would
help; simply assuming that set is intact would not demonstrate coverage.

## What would validate the result beyond conditional candidate search

For a gameplay result, the final query needs a checked solution or exclusion with all relevant call
effects accounted for. Its earlier-state domain also needs a sound connection
to the selected defined, in-bounds model. This byte-memory interpreter still
lacks a complete allocation, provenance, initialized-storage and runtime
correspondence argument. Its fresh stack frames and compact global addresses
repair concrete bugs; they do not supply that larger argument.

A timeout, unanswered effect or merely constructed formula therefore leaves
**zero certified complete predecessor updates**. No three- or five-second
coverage price follows. Finding a satisfiable proposal would still not prove
an allowed gameplay history: its connection to the agreed start is needed.
The complete no-Ink claim and the clean producer question both remain open.

The implementation is [endpoint_update.py](../../instrumentation/rank1-backward-search/endpoint_update.py).
The [README](../../instrumentation/rank1-backward-search/README.md) gives the
source-generation recipe and command. Full diagnostic files remain in ignored
build output. No ROM, conversation export or injected gameplay snapshot is
part of this tranche. The existing Coq audit remains historical evidence for
the unchanged proof modules; it does not validate this interpreter.
