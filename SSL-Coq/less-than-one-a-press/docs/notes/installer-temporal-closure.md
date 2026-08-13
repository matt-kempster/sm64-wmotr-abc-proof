# Area-1 installer temporal closure

## Verdict

The installer-coverage checklist item is more useful than extracting the
destination `131` pushes and `84` pops. The destination chronology begins
after a platform pointer and displacement payload already exist. It can prove
that the payload survives and is consumed, but it cannot explain how clean
Area-1 play installed it.

The most promising current subproblem is therefore the linked stock-provenance
projection for the true pre-collision apply. The new proofs make substantial
progress on its scheduling half, but do not yet inhabit the linked projection.

## What is now proved

`Area1PrecollisionWriterClosure.v` checks the generated US and JP source shape
before object-collision sampling:

1. terrain objects update;
2. cached platform displacement runs;
3. object collision is detected; and
4. Mario's action/physics update and raw-Object synchronization occur later.

For the 29 listed stock Area-1 surface-family native/action bodies in each
version--pyramid top, Tox boxes, breakable boxes, exclamation boxes, and the
cannon lid--the generated-AST census finds no recognized direct Mario
State/Graphics XYZ store and no direct `set_mario_pos` call. Separate source
receipts find a scheduler call with literal `isMario = 1`, a helper call to
`set_mario_pos`, and the expected State/raw-Object lvalue occurrences. They do
not prove call uniqueness, branch ownership, joint execution, or pointer
identity.

The semantic split theorem therefore has three explicit linked premises: the
terrain prefix must frame all three Mario coordinate views, the real platform
interval must refine to the abstract `PlatformMarioPhase`, and collision
processing must frame those views. Under those premises:

- a synchronized local-Object/nonlocal-State split requires an effective
  platform application; and
- the abstract platform phase cannot create Ink's Object/Graphics gap. That
  gap must already exist before the pre-collision prefix or a frame/refinement
  premise must fail.

`Area1InstallerTemporalClosure.v` then separates the previous query sample
from the current collision sample. It proves, over an arbitrary finite trace:

- an active frame may move the Object, but its final query recomputes the
  platform pointer at the new Object sample;
- a frozen/query-skipping frame preserves both the Object sample and pointer;
- the US spawn path clears the pointer; and
- a JP retained pointer begins at one of the checked inbound positions.

No composition of those stock scheduler shapes can reach the fixed upper-warp
collision sample with a non-null pre-apply pointer. This is stronger than the
old same-position model because movement between active frames and arbitrarily
many exact frozen carries are allowed.

`StateFirstPlatformChronology.v` supplies the complementary positive
classification.  The general-entry split has five cases.  The scoped start is
**SSL Area 1 (the exterior)**, and `DefaultArea1StartBoundary` explicitly seeds
`gMarioPlatform` with null.  `DefaultArea1StartChronology.v` decodes this seed
from the same active Clight run-start memory and requires a nonempty run.  A
supplied pre-apply projection whose seed equals that decoder cannot finish as
retained JP inbound lineage, so its abstract residual interface has four cases.
Deriving the projection's events, collision sample, owner, and endpoint from
the run remains open.  If a projected true pre-
collision upper-warp apply nevertheless loads a non-null pointer, its last
effective lineage is one of:

1. a canonical stock final query at a different source/current sample;
2. a canonical identity outside the modeled stock geometry;
3. a recognized behavior kind with a noncanonical slot or ghost epoch;
4. an unclassified dynamic owner.

`default_area1_active_preapply_has_no_jp_inbound_final_lineage` covers any
finite modeled query, clear, and skip sequence in a supplied pre-apply record
whose seed is tied to the active run-start memory.  Deriving that record from
the run remains open.  It also does not prove that a castle route reaches the
declared null boundary.

## What this says about the conditional State-first candidate

The injected State-first candidate proves that the engine outcome is useful;
it does not prove its predecessor. The new temporal results show that an
ordinary stock cached-platform history is not enough to produce that
predecessor. A real installer must now exhibit at least one concrete escape:

- an aliased or external store to `gMarioPlatform`;
- live final-query ownership outside the canonical stock projection, including
  relocation, cloning, slot reuse, or corrupt identity;
- an Object-coordinate write after the final query;
- a supposedly skipped frame which nevertheless moves the collision Object;
- an unclassified scheduler/terrain-dispatch transition.

This is not yet a proof that none of those escapes is reachable.

## Exact remaining linked work

The next proof must instantiate `UpperWarpPrecollisionApplyProjection`, the
strengthened temporal projection, and all three pre-collision refinement
obligations from real linked small steps beginning at the declared SSL Area 1
(the exterior) boundary. In particular it must:

1. resolve and frame the `gMarioPlatform`, MarioState, Mario Object, and
   Graphics memory regions;
2. execute `update_mario_platform` far enough to connect a non-null store to
   the returned live `Surface.object` pointer;
3. project the declared start and every linked boundary-step endpoint to a
   concrete temporal snapshot rather than allowing an always-`None` projector;
4. project that surface pointer to its pool slot, allocation epoch, behavior,
   collision data, transformed surface, and query position;
5. prove every skipped path performs no effective platform store and no Object
   movement;
6. prove the value loaded by the true pre-collision apply is exactly the last
   chronology result; and
7. close platform-branch execution, collision framing, transitive
   helper/action-table, fresh-child, alias, and external-call frames for the
   terrain-object prefix.

If these facts hold, the platform-based State-first installer is eliminated
within the declared start scope.
If one fails, the failing step supplies a concrete installer class to trace
rather than an opaque residual predicate.

## Formal status

The new theorems are admission-free. They prove source receipts, abstract
transition invariants, and an exhaustive classification over supplied
projection records. They do not prove that every clean US or JP retail state
inhabits those records, and they do not complete the ultimate star
impossibility theorem.
