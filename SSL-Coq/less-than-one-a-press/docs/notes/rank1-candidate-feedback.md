# Rank 1: a candidate can now get an emulator answer

27 September 2026. **The candidate → emulator → source-query feedback loop
works for a search branch with a known controller prefix.** This does not
complete the exhaustive one-second backward search, resolve arbitrary earlier
memories, prove Ink impossible, or add a Coq theorem.

## Did these runs start at Ink?

**No. The emulator started earlier and ran forward.** Only the final generated
caller was worked backward from the desired top-retention condition. The thirty
preceding updates were executed forward from one fixed, controller-reached
prefix. The solver did not reconstruct their predecessor states. Calling this
"finishing the connection" was too broad: the completed piece is a concrete
candidate validator, not the requested thirty-update backward search.

The agreed endpoint remains the final Area-1 check retaining the checked top.
That is a necessary checkpoint for this selected installation, not a complete
Ink installation by itself. The target used here does not establish warp
acceptance, pointer survival or the first useful Area-2 apply. No run began at
an already installed Ink state.

## What changed

Previously, a solver proposal could ask for a useful floor result, but the
emulator adapter only knew how to answer calls from an already named recording.
There was no working loop from a new input proposal to its actual call result.

The new branch gives the emulator a complete controller history. The earlier
inputs come from the accepted normal start and a checked no-A replay. The solver
chooses the next thirty input samples. The emulator runs that history from the
start; no position, action, floor, gap or saved gameplay state is injected. This
produces a concrete call occurrence without trying to manufacture a full save
state from a few symbolic coordinates.

The target is still worked backward through the actual generated JP
`update_mario_platform` and `absf` bodies. The query exposes the required
coordinates, returned floor height, floor pointer and owner at the real
`find_floor` call. Those are requirements of the proposal, not values supplied
to the game. The entire earlier interval executes in the emulator. It is not
claimed to have been inverted symbolically.

The returned observation is matched against the full input history, the
recorded prefix, the call and return addresses, stack and output-cell identity,
Mario's receiver, the live floor-list membership and the actual completed
retention check. The source calculation must permit the measured result and
exclude a different result for those observed call values. Only the needed
fields are imported; no whole-memory frame is assumed.

The search then adds these observed values to **the same target query**, guarded
by that exact input history and search context. If that makes the candidate
unsatisfiable, the next solver call chooses a different input history. A
timeout, missing checkpoint, wrong receiver or failed observation check leaves
the candidate pending. None of those failures is evidence against a route.

## What the first tests establish

The [compact receipt](../../instrumentation/rank1-backward-search/candidate-feedback-report.json)
records the completed thirty-update candidates and their final observed call
values. Their endpoint is update 30, at top timer 131. An earlier update is not
required to retain the top, so the search does not reject a candidate merely
because an intermediate update lacks Ink.

Three distinct input histories completed the final batch. All three target
queries became unsatisfiable after their own replies were consumed. Ninety
reached floor calls passed the generated-suffix checks. The solver chose neutral
sticks with different buttons; all three ended at
`(-5541.40283203125, -0.0, 2007.1839599609375)`, with an ownerless zero-height
floor and both platform pointers null. These are three software-integration
cases with the same observed endpoint, not three distinct promising approaches
to the pyramid. One identical earlier capture was revalidated from its raw
log; two new captures took about 172 and 150 seconds, including the long prefix.

The first neutral-input candidate asked for the checked top at
`(-2200, 1938.8648681640625, -1024)`, allowing the caller's real four-unit
retention tolerance. The emulator instead reached an ownerless floor at height
zero, with raw Mario Y also zero. Feeding that call back made this candidate's
target query unsatisfiable. The next candidate was then generated and tested.
This is an actual feedback result, not rejection of a deliberately damaged
test reply.

The initial exploratory batch also generated Start presses. Those runs did not
produce one retention check for each of the thirty input polls, so they stayed
pending. The final batch prioritizes no Start presses; Start remains in the
input domain and paused histories are not declared impossible.

The application suite passed all 58 tests. The new controls include a synthetic
positive case, wrong-history and wrong-call refusals, rejection of an incorrect
observed return, preservation of untested alternatives, and keeping pending
cases separate from learned rejections. The positive control is a software
test, not gameplay evidence. No Coq source or formal proof boundary changed.

## What an unresolved call means now

It means the search still lacks justified effects for that call in that state.
Sometimes the body is known but has not been expanded. Sometimes a live pointer
chooses the callback and receiving object. Sometimes the call belongs to the
runtime. The game itself is not stuck at these calls.

Use the actual generated source for small relevant bodies, determine the live
receiver for callbacks, and let the emulator answer concrete reached cases
when expanding the whole body is impractical. Each answer needs the matching
state/history and enough effects for the following claim. A function name or
matching Mario coordinates alone is insufficient. Unknown calls do not become
no-ops, and a missing answer does not reject a trajectory.

## What this does not finish

This is a **controller-grounded branch** of the backward target query. The
previous arbitrary-memory 30-update formula still has its unresolved frontier;
the new driver has not automatically discharged its 64 call sites. A proposed
earlier state without a matching controller history still has no emulator
answer. Other prefixes, starting conditions and timings remain open.

The new input domain allows all named non-A button bits and signed eight-bit
stick samples at each suffix poll. Only the candidates listed in the receipt
have been tested. The current runtime adapter checks one Area-1 retention
checkpoint per poll; other schedules remain pending. No input groups are
generalized from a failed sample. The run ends at its explicit candidate budget,
not at exhaustion of the domain.

This connection makes candidate validation automatic, but does not solve the
combinatorial problem. Before runtime feedback, the omitted interval gives the
solver little guidance about which inputs will actually produce the requested
call values. Each learned result currently applies to one exact history.
Exhaustive three- or five-second prices still cannot be inferred. Recorded
emulator timings also include replaying the long shared prefix from startup.

A retained checked top would establish only this checkpoint. Warp acceptance,
pointer lifetime and the first Area-2 apply still need their existing checks
before calling anything a successful Ink installation. No case moves to
Already proved, and all 45 subjective atlas estimates remain unchanged.

## What exhaustive one-second coverage would require

These are completion criteria, not newly completed work. Keep the requested
endpoint above and count thirty completed gameplay updates before it. A fixed
earlier replay gives a much narrower question: every allowed continuation of
that replay. It cannot stand in for every allowed predecessor of the endpoint.
For the broader question, earlier states must remain represented, with an
explicit domain containing the allowed histories. The accepted normal start
does not need to be reconstructed. A surviving candidate still needs a valid
connection to it; an exclusion can instead cover a justified larger state set.

1. **Represent the endpoint and one complete predecessor step.** Keep every
   state that can reach the selected target under some allowed controller
   input. Do not fill unknown earlier bytes with one convenient supplied scene.
   Include the actual action, scheduler, callback, floor-list and runtime
   effects needed by surviving branches. Calls may use their generated bodies,
   justified summaries or sound conservative effects. A concrete emulator
   reply establishes one reached case, not all symbolic cases. It is unnecessary
   to expand an irrelevant call if a checked conservative calculation already
   excludes the whole branch.
2. **Join thirty steps with consistent state and input history.** The memory
   after one update must be the memory before the next. Carry button edges,
   timers, objects, RNG and other relevant state. Apply the selected no-A rule
   explicitly; A always released is narrower than a justified already-held-A
   boundary under the no-new-A rule. Handle pause and multiple controller polls
   according to the declared horizon. Thirty polls are not automatically thirty
   completed updates; the present adapter leaves mismatches pending.
3. **Eliminate sets safely enough to make the calculation practical.** Keep
   symbolic input ranges and prove any state merging or branch exclusion.
   Equal XYZ, nine stick regions, or one failed representative do not establish
   equivalent futures. The present feedback loop excludes one exact history
   at a time and gives little guidance before replay. At thirty input samples,
   its raw non-A encoding envelope contains `(2^29)^30 = 2^870` sequences;
   this is an envelope, not a count of physically distinct gameplay choices.
   Raising the candidate budget is not a practical exhaustive strategy.
4. **Account for the entire domain before claiming exclusion.** Retain a
   checkable coverage record: every relevant alternative must be included in a
   completed calculation or excluded with justification. Timeouts, unanswered
   calls and pending schedules cannot disappear from that record. A validated
   witness can establish possibility before exhaustion; no witness after a
   budget-limited run cannot establish impossibility. Solver results also need
   their translation and runtime boundaries stated; this exploratory Python
   engine is not a Coq-verified implementation of CompCert.

The next implementation milestone should be a complete predecessor calculation
for **one** update from the selected endpoint set, including all alternatives
in its stated domain, followed by measurements at two and four updates. Only
then can its growth inform a thirty-update estimate. This is a recommendation,
not a claim that the thirty-update calculation will be tractable. No new search
or proof was performed for this clarification.

## Reproduction

Use the existing Python/Z3 environment, authenticated JP ROM and Ubuntu-24.04
emulator. From the SSL project directory:

```text
python instrumentation/rank1-backward-search/search_updates.py --runtime-feedback --prefix build/wafel-pilot/capture.m3J9sy/inputs.jsonl --rom ../../../reference-sm64-decomp/baserom.jp.z64 --updates 30 --candidate-budget 3 --output build/rank1-backward-search/new-candidate-feedback
```

The output directory must be new. Each candidate saves its proposed inputs,
required call values, controller schedule, raw-capture path, validated reply,
and the target formula after feedback. Optional `--replay-cache PREVIOUS_RUN`
reuses only an identical complete controller schedule, and rechecks its raw
recording rather than trusting a previous summary verdict. Exit status 2 means
the exhaustive search is unfinished even when the feedback loop works.

The source pin remains `9921382a68bb0c865e5e45eb594d9c64db59b1af`. Only the
authenticated JP runtime is connected here; its replies cannot answer US calls.
Raw logs, controllers and solver models stay in ignored build output. No ROM,
private conversation export or fabricated gameplay state is published.
