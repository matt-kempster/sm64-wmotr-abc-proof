# Stock projection and Ink's clean gap installer

## Verdict

Ink's timer-131 construction is **not proved reachable from a clean retail
entry**, but it is also **not eliminated**.  This tranche makes the remaining
problem substantially narrower and corrects one unsound shortcut in the old
stock projection.

The important correction is that a cached `gMarioPlatform` value and Mario's
current collision position need not come from the same sample.  The old
`StockArea1PreapplyPlatform` relation attached both facts to one position.
That is safe only after linked execution proves an actual last writer,
retention, and sample equality.  `StockProjectionExhaustiveness.v` provides a
weaker but honest separation witness: its handwritten stock-candidate relation
is inhabited at one sample, upper-warp contact holds at an independent sample,
and the old same-position relation rejects the latter.  The witness models no
store, retention interval, temporal ordering, physical movement, or gameplay
trace.  It demonstrates only that sample equality must be derived rather than
assumed.

## What the timer-131 Ink installer needs

The conditional fixture uses three independently timed views of Mario:

1. the raw Mario Object must overlap the Area-1 upper warp;
2. the first geometry query made with MarioState must reject its floor;
3. the retry using `header.gfx.pos` must select a pyramid-top-owned surface.

For the corrected timer-131 midpoint, the third view must be at least `960`
units above the highest warp-overlapping Object Y, and the fixture's
warp-centre sample has an exact gap of `1010`.  The older local/PU home-pose
sample in `InkFallback.v` needs at least `973`.  These are two different
samples, not conflicting bounds.

After the retry, the selected top pointer must survive the top's
deactivation/free, the JP delayed area transition, and destination loading;
the corresponding slot payload must then be consumed by the first relevant
Area-2 platform application.  Those later steps are conditionally observed,
but the clean Area-1 installer for the initial three-view split is missing.

## Newly proved source and formal boundaries

### Platform-pointer writers

`PlatformPointerProvenance.v` computes over all 38 generated units for each
version and proves:

- JP has one direct `gMarioPlatform` writer:
  `update_mario_platform`;
- US has that writer plus `clear_mario_platform`;
- the update is directly called only from `update_objects`;
- the US clear is directly called only from `spawn_objects_from_info`;
- no generated internal body explicitly takes the address of
  `gMarioPlatform`;
- no generated initializer contains a relocation to the global cell;
- every non-null assignment in `update_mario_platform` uses the temporary
  loaded from `Surface.object`; every other assignment there is null; and
- the US clear writes only null.

Existing official-link definition provenance is packaged with these finite
inventories and source value-flow shapes.  This closes the generated direct
Clight syntax census; it does not yet establish a reachable-store theorem for
the official links.  A reachable store might still use a fabricated or
pre-existing alias, and an unresolved external might still modify the global
block.

### Owner, identity, and epoch cases

`StockProjectionExhaustiveness.v` proves a logical split that is exhaustive
only for an already supplied `Area1DynamicOwnerObservation`, classifier result,
and canonical-reference map:

| Case | Meaning |
| --- | --- |
| Canonical modeled candidate | Recognized kind, caller-supplied canonical reference, and the handwritten floor-candidate predicate |
| Canonical identity outside candidate relation | Same supplied reference, but outside the envelope/tolerance predicate; the cause is not established |
| Known kind, noncanonical identity | A different-slot recognized identity, or the same slot with a different ghost epoch |
| Unclassified | The supplied classifier returned no modeled kind |

The same file partitions a caller-supplied upper-warp record into fixed-center
canonical, changed-center canonical, noncanonical stock-behavior, or
unclassified cases.  A noncanonical reference is proved to be either a
different slot or the same slot with a different ghost epoch.  It does not
prove that an epoch is later, that a slot was reused, or that a different-slot
identity is a clone.

For the module's two-sample stock-candidate record, a candidate query/inbound
sample and an upper-warp collision sample must be unequal.  The record does
not prove an actual write, absence of intervening writes, pointer retention,
or a skipped frame.  Constructing the observation from every reachable live
surface-list owner, proving classifier/canonical-map soundness, and attaching
the two samples to a retail trace all remain open.

### Scheduling

`Area1QueryScheduleClosure.v` computes intraprocedural generated-AST call and
guard receipts for functions participating in this source order:

```text
apply cached platform
  -> object collision detection
  -> Mario interaction/action processing
  -> State-to-Object copy
  -> object unloading
  -> final update_mario_platform call
```

It also checks the `ACT_DISAPPEARED` constructor and the
`stop_and_set_height_to_floor` call shape.  In the finite schedule model:

- a frame where interaction selects the upper-warp `ACT_DISAPPEARED` action
  has a later final-platform-query call;
- a modeled query-free schedule cannot select that action;
- a functional mirror of the two null-callback transition steps preserves the
  previously computed pointer and all three coordinate views; and
- under the schedule record's State-or-Graphics and continuation premises, a
  final-query/collision-position difference fits post-wall State, the Graphics
  retry, the cached-floor Y snap, or an unclassified post-copy discrepancy.
  The last case does not prove that a writer caused the discrepancy.

The schedule model is not yet a linked small-step theorem.  In particular,
the proof still must establish the live branches, Mario-object non-nullness,
and memory frame conditions.

There are two interaction/action-selection branches.  If the Graphics retry finds a
floor, `ACT_DISAPPEARED` can dispatch and perform its cached-floor Y snap.  If
that retry is also null, geometry input first requests death/game-over;
cached interactions may still select `ACT_DISAPPEARED`, but action dispatch
then returns on the null floor.  That second shape still reaches the final
platform query and therefore matters to pointer chronology.  It is not a
successful Area-2 route: the separately checked `RetailFatalLatch.v` event
model proves that an accepted fatal request either persists or a reset
destroys the old disappeared continuation.  Its linked latch-memory
refinement remains open.

### Relocation and collision-preserving clones

`Area1WarpTopCloneCensus.v` proves for US and JP:

- the top collision symbol occurs in exactly one initializer,
  `bhvPyramidTop`;
- the `bhvPyramidTop` pointer occurs only in SSL Area 1's level script;
- `bhvWarp` occurs only in the warp classification table and SSL level
  script;
- no imported internal C body directly embeds any of those three symbols;
- all 21 direct `Object.collisionData` writer bodies are enumerated;
- the top's callbacks spawn pillar detectors and fragments, not another top;
- those children do not contain the top collision mesh or collision-loader
  callback;
- every direct allocator assignment to `collisionData` is null; and
- ordinary pose-copy helpers do not copy behavior identity or collision data.

This rules out directly using the ordinary pose-copy helper as a
"clone the top with its collision" primitive.  It does not prove every
successful allocation executes the reset, and it does not rule out replaying
the stock level spawn, passing the top
behavior through generic runtime arguments, corrupting a behavior/collision
pointer, or using one of the 21 generic writers on an unexpected receiver.

The trace-scoped execution half is now complete for the authenticated clean
zero-A upper-warp route.  `Area1Rank4WarpTopTraceReceipt.v` scans all 240
object slots on 2,462 consecutive frames and watches actual collision loads:
there is one canonical top, one fixed collision-free upper warp, 2,353
canonical top-mesh loads, no clone or resurrection, and no warp position,
identity, or collision write.  The top slot is reused three times only after
retirement, and allocation clears its collision pointer before each new
behavior.  This closes the listed mechanism on that run, not for every input
history.

## Exactly what remains

The clean retail installer is reduced to the following linked-semantic work:

1. **Close the platform-global memory frame.**  Prove that the global cell's
   block is not reachable through internal pointer values, that CompCert
   pointer arithmetic cannot cross into it in a defined execution, and that
   every reachable unresolved external preserves it.  Then the direct writer
   census becomes a small-step last-writer theorem.
2. **Execute the action-selection frame.**  Prove that a Mario object whose
   interaction selects the upper-warp action remains non-null through
   unloading, reaches the final
   `update_mario_platform` call, and takes exactly the modeled branches.  This
   includes linking the player-list callback to `bhv_mario_update`, fixing the
   State sample after both wall-collision calls, and proving the final
   `find_floor` call avoids the null-Mario early return.
3. **Explain or eliminate post-copy discrepancies.**  Between
   `copy_mario_state_to_object` and the final query, prove that later object
   callbacks cannot write Mario's State/raw/Graphics coordinates through an
   alias.  Cover the post-handler interaction tail, remaining object callbacks,
   particles, unload code, outer scheduler, and unresolved externals.  If one
   can write them, carry the exact step as a concrete installer candidate.
4. **Project the live dynamic-surface lists.**  Tie every selected
   `Surface.object` pointer to a live object-pool slot and allocation epoch,
   with block/offset bounds and alignment.  Prove the surface was inserted in
   the current terrain phase by the real collision loader, the owner is active
   and belongs to Area 1, and the behavior/collision-data classifier and
   canonical map are sound and injective.  Include inactive/deallocated
   same-reference and same-slot/different-epoch cases rather than silently
   dropping them.
5. **Generalize relocation and clone provenance.**  The complete clean
   upper-warp receipt now proves the desired identity, allocator-reset, pose,
   and collision-owner result for one successful controller history.  Lift
   those exact checks to every reachable in-bounds history: clean Area-1 spawn
   and behavior execution must create only the canonical warp/top instances,
   every successful allocation must execute its null collision-data reset,
   area unload/reload must not leave two relevant live instances, and every
   reachable one of the 21 collision-data writers must install its own stock
   mesh or be unreachable in SSL.
6. **Close the three-view writer invariant.**  Execute ordinary clean entry
   to obtain State/raw/Graphics equality, then refine every reachable
   coordinate writer, action transition, quicksand-depth update, dialog
   reanchor, alias, and external effect to a binary32 bound strictly below
   `960`--or find the first writer that violates it.

Steps 2 and 3 are the best next target.  The source shape strongly suggests
that an upper-warp action selection cannot use a query-free transition frame
to install a newly useful pointer: the query call occurs later in the modeled
selection frame, while subsequent null-callback frames only abstractly preserve
its result.  If linked execution confirms the model, a non-null final query,
and no post-copy discrepancy, then every candidate reduces to the
pre-selection three-view split or to a relocated/substitute/unclassified owner.

## Counterexample status

No clean US or JP retail counterexample was found in this tranche.  The
distinct-sample theorem is only an abstract separation witness, not a
counterexample to the game claim or a modeled carry.  The injected timer-131 JP continuation remains a
valid conditional counterexample boundary: once its gap and pointer payload
are injected, the existing trace can reach and newly collect Act 6 without an
A edge.  Clean installation of that boundary remains unproved.
