# Rank 1: search for predecessors of Ink

Proposed 27 September 2026. **Awaiting the user's confirmation before coding or
running the backward search.** This records a method and a proposed first scope;
it adds no gameplay witness, exclusion or Coq theorem. Rank 1 stays open at its
unchanged subjective 1–2% estimate.

## What “backward” means here

The user's proposal is to start at a working Ink endpoint and ask which earlier
states, followed by a chosen controller input, could produce it. Choosing B
would mean: “Find the states from which this frame's B input reaches the target.”
Repeat that question for the surviving predecessors until one connects to a
state reached by an allowed controller history. This is backward reachability,
not another batch launched from an earlier known checkpoint.

There usually is not one previous state to display. Copies overwrite old
positions, collision corrections can merge different approaches, clamps discard
information, and floating-point operations round. A chosen input may therefore
have no predecessor, one, or many. Reversing velocity or subtracting the apparent
movement does not reconstruct the game. The search needs sets of possibilities
and constraints on them, rather than one guessed trajectory.

## The code we would need

The installed Wafel 0.8.5 interface provides forward advance, saved states and
restoration. Its Game interface has no predecessor-enumeration operation.
Restoring an already recorded frame can rewind that recording; it cannot find
an unrecorded past for an arbitrary target. The existing controller adapter can
validate forward continuations, but it is not the proposed backward engine.

New code would derive predecessor conditions from the pinned C and actual
generated US/JP Clight, carrying the effects and branch guards of the relevant
calls. A constraint solver could help with fixed-width integers and binary32
arithmetic; that does not automatically translate or verify a complete game
update. Keep unsupported calls, solver timeouts and unresolved conditions open.
Any abstraction used to rule out a branch must include every legal predecessor
in its stated scope. An invented state restriction is not an impossibility proof.

The important state includes all three position records, actions and timers,
velocity, depth, previous controller buttons, relevant RNG, live floors and
owners, and the top's timing and lifetime. Only omit something after establishing
that it cannot affect the selected transition. Different instruction checkpoints
within one frame use the same latched input; they are not extra chances to press
a button. Preserve the no-new-A rule, including the previous-button history.

## A first batch worth authorizing

Start with the useful installation conditions of the known JP mechanism, not
every irrelevant byte of the supplied snapshot and not just a large numerical
gap. Keep separate the chosen accepted-warp checkpoint and the later final floor
query that must remember the useful top. The first Area-2 displacement is the
payoff that the retained owner must actually supply.

Work backward through the installation frame: the final floor/owner decision,
the copies and action execution before it, and the pre-action first lookup and
retry. The existing query/copy proofs are boundaries to reuse, not replacements
for their unresolved conditions. In the selected retry branch, ask which
predecessors can supply the floorless low actual position and surviving raised
display after both wall corrections. Do not assume those positions agree or
assume that the lists select the top.

The initial deliverable should be a predecessor table or graph for that bounded
segment: actual code branch, required earlier conditions, excluded branches with
their reason, and unresolved branches with their exact missing condition. It
need not immediately be an interactive reverse-play viewer. Extend to earlier
frames only after this segment is faithful and useful; do not silently expand
the first batch into a universal inverse emulator.

## What would count as a result

A locally consistent predecessor is a candidate, not proof that gameplay can
reach it. A clean witness needs a controller-produced prefix reaching that same
state in every suffix-relevant respect, followed by the reconstructed inputs.
Check the complete joined replay forward, including exact warp acceptance,
final floor/owner selection and first Area-2 application. Use Wafel and the
existing emulator observer for this validation. Neither an injected pose nor a
match on X/Y/Z alone establishes the join.

A branch can be retired when its real predecessor conditions are contradictory.
An empty, exhaustively justified predecessor set excludes its named transition
or bounded interval. It does not exclude longer or different histories without
a separate coverage or invariant argument. A failed finite search or unknown
solver result stays unresolved. Translate any claimed formal exclusion into a
checked connection to the existing Coq boundary; solver output alone is not a
new Coq theorem.

Sources: installed `build/wafel-pilot/python/wafel/__init__.pyi` (Game operations),
[the forward adapter](../../instrumentation/wafel-jp-pilot/replay.py),
[the actual final-query proof report](rank1-final-platform-query.md),
[the finite search we are replacing as the next strategy](rank1-reachable-search.md),
[Z3 fixed-width arithmetic](https://microsoft.github.io/z3guide/docs/theories/Bitvectors/),
and [the SMT-LIB binary floating-point theory](https://smt-lib.org/theories-FloatingPoint.shtml).
