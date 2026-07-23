# Candidate strategies from the supplied transcript

The transcript is not a formal source.  It was used to choose cases that the
decomp-driven reachability proof must eventually cover:

- upper-entry elevator containment, including the rollout near miss and the
  elevator-before-Mario update order;
- the lower-entry route's pole dismount and alternative amp/goomba ideas;
- the 100-coin star as a possible movement resource, while keeping its index
  separate from target indices 2 and 5;
- area 2/3 toggling near the Eyerok tunnel;
- the JP retained-platform spawning-displacement case at upper entry.

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

The current Rocq route model states this graph argument as a machine-checked
logical contract and proves its cut and bypass lemmas.  The contract is
deliberately labelled as a transcript abstraction.  In particular, the
following facts remain separate obligations:

- every retail execution reaching a target collision region projects to a
  synchronized route trace satisfying the contract;
- there is no additional edge around the elevator or second-pole cuts;
- the transcript's post-gate strategies cover both target interactions under
  actual Float32 collision and object-update semantics;
- a proposed spawning-displacement or above-pole witness is reachable from a
  `CleanPyramidEntry` state in US or JP.

This separation is important: proving a cut theorem from a formal route
contract is a useful reduction, but it is not a proof that the contract is
complete for the game executable.
