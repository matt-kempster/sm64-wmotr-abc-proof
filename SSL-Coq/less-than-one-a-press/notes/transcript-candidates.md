# Candidate strategies from the supplied transcript

The transcript is not a formal source.  It was used to choose cases that the
decomp-driven reachability proof must eventually cover:

- upper-entry elevator containment, including the rollout near miss and the
  elevator-before-Mario update order;
- the lower-entry route's pole dismount and alternative amp/goomba ideas;
- the 100-coin star as a possible movement resource, while keeping its index
  separate from target indices 2 and 5;
- area 2/3 toggling near the Eyerok tunnel;
- the JP retained-platform spawning-displacement case at upper entry; and
- the conditional setup in which Mario uses the upper warp on a spinning
  pyramid-top floor that then unloads, potentially retaining a stale
  `gMarioPlatform` pointer.

None of the transcript's numerical or impossibility claims is imported as a
premise.  Collision dimensions, update order, object lifecycle, version
differences, and save-bit behavior must come from the pinned source, generated
Clight, or a separately checked ROM-level analysis.

## Route-gate claim extracted from the transcript

The transcript's central route argument can be stated without relying on its
probability analogy or on the historical order in which strategies were
found:

1. A clean upper entry starts in the pyramid elevator.  In the ordinary route,
   reaching the shared upper part of area 2 requires an A-triggered elevator
   dismount.
2. A clean lower entry can pass the earlier obstacles without a new A edge in
   the transcript's consolidated route, but the route then reaches the upper
   (second) pole.  In the ordinary route, reaching the floors above that pole
   requires an A-triggered pole dismount.
3. Once the shared upper part is available, the transcript claims that the
   remaining strategies can reach the Act 3 interaction region and the upper
   Pyramid Puzzle trigger without another A edge.
4. Consequently, a genuine no-A elevator escape, including a realizable
   spawning-displacement escape, would remove the upper-route gate.  Likewise,
   any genuine no-A execution reaching a state above the second pole would
   remove the lower-route gate.  Either discovery would refute the respective
   route lower bound and would be candidate evidence for a zero-A collection
   route.

The phrase “above the second pole” is not a valid final geometric cut.  The
pole's top grip is at Y `4020`, while a real target-side support ring is at Y
`3942` and the upper Puzzle trigger is at Y `3913`.  The formal lower route
must instead identify first collision-phase entry into enumerated target-side
support surfaces or open cells around the pole hole.  The transcript node is
retained only as a coarse description of the ordinary route.

The current Rocq route model states this graph argument as a machine-checked
logical contract and proves its cut and bypass lemmas.  The contract is
deliberately labelled as a transcript abstraction.  In particular, the
following facts remain separate obligations:

- every retail execution reaching a target collision region projects to a
  synchronized route trace satisfying the contract;
- there is no additional edge around the elevator or target-side lower cut;
- the transcript's post-gate strategies cover both target interactions under
  actual Float32 collision and object-update semantics;
- a proposed spawning-displacement or target-side lower-cut witness is
  reachable from a `CleanPyramidEntry` state in US or JP.

For JP retained-platform displacement, “reachable” includes proving the
prehistory of the raw pointer.  The current abstract clean model admits an
inactive pyramid-top payload that moves the upper-entry state outside the
shaft with no A edge, but that is a model-only candidate, not a retail trace.
The unresolved stock constructions include moving/loading the upper warp onto
the spinning top, moving the top to the warp, and collision-preserving
cloning.  The warp normally loads on area entry, and cloning may lose
collision, but neither fact proves that every such construction is impossible.
A source-backed predecessor must account for floor ownership, pointer capture,
unload, slot epoch/reuse, and the first area-2 displacement rather than
excluding the candidate by definition.

This separation is important: proving a cut theorem from a formal route
contract is a useful reduction, but it is not a proof that the contract is
complete for the game executable.

## Routes not assumed by the transcript

The strengthened model does not equate “not the ordinary elevator/pole route”
with impossibility.  At the exact first target occurrence it records a finite
entrance-specific class tag for platform displacement, object or
moving-geometry help, warp/area-3 travel, collision clipping/tunneling,
parallel-universe/out-of-bounds movement, target relocation/substitution,
macro/object-lifecycle anomalies, save reload/corruption, or
memory/undefined behavior.  Those historical tags are payload-free.

`FirstTargetRefinement.v` adds the evidence-bearing replacement: actual
before/after Clight states and trace segments, exact indexed certified steps,
a total event-writer inventory, and collision-support cut crossings.  It
proves limited eliminations for the direct zero-offset instant warp, invalid
target provenance, invalid hidden-star lifecycle, coherent save reload, and
projection mismatch.  Ordinary/static motion, platform displacement, moving
objects, clips, general coordinate aliasing, and normal reload/entry
displacement remain open.

`FirstTargetCutClassificationObligation` is the pending statement that this
list covers every first target access in a projected US/JP execution.  The
theorems prove:

- coverage implies “gate A edge or named bypass before the first target”;
- coverage plus absence of every tag implies an A edge; and
- coverage plus no A edge and target access yields a named tag.

The project does not yet construct the evidence-bearing classifier from a
linked US/JP run, prove the historical coverage obligation, or establish
global class exclusion.  No stock-reachable target-region counterexample has
been found.  A boundary-fixture JP stale-top replay does consume the upper
trigger with no A edge, while its pre-transition-only preparation fails; this
settles the current state-only model boundary but not retail reachability.  See
[`../docs/route-exhaustiveness.md`](../docs/route-exhaustiveness.md).
