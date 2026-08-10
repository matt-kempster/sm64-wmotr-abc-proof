# Verification checklist

This open-action board is organized by decision value rather than research
chronology. Every checkbox below is an outstanding obligation. Checked work is
preserved in the [completed-task archive](checklist-completed.md), where each
entry remains no stronger than its stated caveats.

Priority means:

- **High:** on the direct path to proving or refuting a clean installer and the ultimate theorem.
- **Medium:** closes an important alternative or semantic edge case but is not the current critical path.
- **Low:** useful speculative or legacy work to revisit after the main linked proof closes.

## High priority

These obligations currently block the clean-retail result.

### Linked retail program and memory simulation

- [ ] Complete the remaining work in the seven-step linked gap-closure tranche.
  Completed substeps are preserved under
  [Linked-program and gap-closure foundations](checklist-completed.md#linked-program-and-gap-closure-foundations).

- [ ] Linked gap-closure step 1 — Prove repaired-program success and the resulting whole-expression and
  internal-step alpha-renaming simulation.  Also prove the concrete
  normalized/original-to-official public-name relation, name-based
  initial/current-state `Mem.inject`, writable-byte frames for every reachable
  `EF_external` effect, and instantiate the initial/final whole-program
  execution refinement.

- [ ] Linked gap-closure step 2 — Execute the live entry `Smallstep.star`, castle routing, behavior
  lookup, controller history, external frames, and pool/list ownership.

- [ ] Linked gap-closure step 3 — Connect its entry state and controller address to the ordinary-entry
  execution in the normalized-and-refined or future linked program.

- [ ] Linked gap-closure step 4 — Prove reachable action, spawn, flag, depth, and slot-lifecycle
  invariants, including automatic-dialog exclusion or reanchoring.

- [ ] Linked gap-closure step 5 — Prove receiver/call/action coverage for every reachable coordinate
  write; these counts are receiver-neutral and not dynamic store counts.

- [ ] Linked gap-closure step 6 — Instantiate those generic results for every reachable object access;
  prove source pointer validity, bounds, harmful-alias absence, and concrete
  writable-memory frame conditions for every reachable unresolved
  `EF_external` effect.  The generic CompCert read-only property is not such
  a frame.

- [ ] Linked gap-closure step 7 — Supply the theorem's total-projection and per-step-refinement premises;
  without them the composition does not exclude a retail installer.

- [ ] Prove that an official cleaned target is a retail-refined
  `TargetLinkedProgram`.  The syntactic link-order part now has kernel-checked
  US/JP structural inhabitants, while `LinkedClightPrograms.v` separately
  proves that the uncleaned 38-unit lists fail (first AST failure:
  `ssl_script`, index 34; first composite failure: `area`, index 27).  The US
  composite counterexample and the remaining global/memory/small-step
  simulation premises prevent treating the cleaned links as retail semantics.

- [ ] Define concrete state, input, event, and complete collision-observation
  projections for actual initial-to-final Clight runs.

- [ ] Prove both `WholeProgramClightRefinementObligation` and
  `CleanEntryProjectionNonvacuityObligation` for that projection.

- [ ] Derive constructor origin, collision, spawn, trigger, lifecycle, and
  preservation premises from Clight instead of assuming them in steps.

- [ ] Prove Clight-to-writer coverage for the finite normal-star/save
  inventory, excluding the explicit corruption/unmodeled writer for clean
  target executions.

### Installer lineage and JP destination chronology

- [ ] Derive the injected local-Object/nonlocal-State split from clean zero-A
  linked execution, or eliminate every escape from the stock pre-apply
  provenance relation.  Ordinary and action-phase PU movement are scheduled
  too late and are copied to raw Object; pre-collision platform displacement is
  the identified stock exception, and its pointer is null at the upper-warp
  sample inside the finite stock model.  A temporal extension now proves this
  remains true across arbitrary active-frame movement and exact frozen carries,
  and classifies any projected non-null survivor into five explicit lineage
  escapes.  Linked writer/non-alias/external-frame, terrain-dispatch, live-owner,
  and lifecycle projection remain open.

- [ ] Prove which JP raw-platform cases are reachable and bound every reachable
  spawning displacement.  Execute the imported matrix/surface helpers over live
  Clight memory, extract the mirrored expressions from generated Clight, and
  prove actual surface ownership/list selection.  Prove
  `Area1StockPreapplyProjectionSound`, connecting every relevant linked Area-1
  memory state to the finite owner/pre-apply relation, while keeping that
  theorem scoped to pre-existing platform origins rather than treating it as a
  graphical-fallback exclusion.  Extract the exact JP destination-area
  allocation/free trace, identify the first destination-area apply, and tie its
  concrete pointer/payload to the abstract slot/epoch.  Prove or refute
  JP delayed-warp pointer retention/recapture, the US spawn-clear Clight effect,
  and whether the remaining warp-to-top, top-to-warp, and
  collision-preserving-clone possibilities project into the bounded relation or
  are unreachable.  This is currently the highest-priority counterexample
  tranche because the fixture already validates the destination displacement
  and continuation once a suitable payload is installed.  Completed supporting
  results are preserved under
  [JP stale-platform lineage and destination continuation](checklist-completed.md#jp-stale-platform-lineage-and-destination-continuation).

- [ ] Construct the linked destination-scoped Clight chronology/allocation
  certificate, including pointer block/offset, allocation epoch, memory
  zeroing or preservation, first terrain updates, and proof that the observed
  early-free depth and payload are consumed by the true first apply in linked
  Clight semantics.

- [ ] Extract the 131 pushes and 84 pops from the linked small-step run;
  resolve the checked `_gObjectPool` declaration to the official linked
  initial/current-memory symbol block and writable range; bind the pointer
  and ghost epoch; prove terrain/update frame conditions; and execute the
  true first apply's payload loads and binary32 displacement.

- [ ] Prove installer coverage.  Ink's non-null graphical retry is one
  candidate; State-first selection, physical co-location or cloning,
  post-commit transport, another dynamic owner, and a skipped-query frozen
  carry must each be proved unreachable or carried into the same trace.

- [ ] Prove the linked stock-provenance projection is exhaustive.  Analyze
  relocated warp/top or collision-preserving clones, post-commit movement
  away from the warp sample, non-stock owners, and skipped queries outside
  the stock provenance relation.  Derive Ink's initial three-view gap from
  clean retail execution or prove it unreachable.

- [ ] Prove the platform-global non-alias/external frame invariant; execute
  the upper-warp action-selection frame through the non-null final query;
  explain or eliminate post-copy Mario-coordinate discrepancies; project live dynamic
  surface nodes to slot/epoch/behavior/collision provenance; and refine
  every clean coordinate writer to the strict binary32 gap bound.  Also
  instantiate the temporal scheduler and pointer-lineage projections;
  prove the terrain-dispatch and collision XYZ frames plus the real
  platform-phase refinement; and eliminate or realize each of the five
  remaining lineage cases. The official direct named writer/caller/address
  syntax closure and the local JP store/load Clight steps are complete; the
  linked reachability and preservation work in this item is not. See
  [`notes/linked-platform-lineage.md`](notes/linked-platform-lineage.md).

### Live collision and nonlocal samples

- [ ] Refine the target cast-prefix model to the compiled US/JP execution,
  prove Invalid-enable preservation and handler non-resumption, refine the
  horizontal-boundary split to the generated branch, classify accepted cells
  with and without an actual floor, and either derive the three-dimensional
  local-Object/nonlocal-State split from a clean run or prove it unreachable.

- [ ] Execute/refine the wall and floor traversals in live Clight memory and
  include dynamic lists, casts and memory effects, then prove or refute clean
  reachability of the first-`NULL` sample.

### Clean-entry writer, action, and gap closure

- [ ] Prove complete current-program writer coverage before using the
  parallel-universe alias-gap subcase globally.

- [ ] Prove or refute the five narrow Ink obligations:
  the surface, prestate, and writer forms are now proved predicate-sensitive
  schemas rather than closed retail statements.  The older home-pose schema
  requires at least a `973`-unit Graphics-minus-Object Y gap but is rejected at
  timer 131.  The corrected capture-preserving midpoint requires at least
  `960`, or exactly `1010` at the warp centre.  Complete audited
  writer-execution coverage from an audited entry conditionally refutes it.
  Retail writer and linked live-list coverage remain open.  The authentic JP
  probe observes a top-owned midpoint retry after injection, but does not prove
  its clean predecessor or a Clight traversal.  The original sink
  statement was refuted by repeated-return and 32-bit pointer-wrap
  counterexamples; its current record uses a first-return relation and
  disjoint modular four-byte cells, but the repaired
  `InkFallbackSinkMemoryRefinementObligation` remains unproved.  The current
  `InkFallbackPostCopyLifecycleRefinementObligation` is not a valid proof
  target: arbitrary projection/linking, an unconstructed exact link/indirect
  callback despite importing `behavior_script.c`, external
  frame effects, missing pointer-to-slot/epoch linkage, and non-finite float
  samples make it unsafe or vacuous.  Replace that interface before proving
  later object writers, unload preservation,
  transformed surface/height, concrete surface identity, and final
  active/inactive-same-epoch identity.  Separately prove that the top is
  scanned/deallocated and any claimed free-list membership.  The retry-null
  fatal call and first-writer shape are source-checked.
  `RetailFatalLatch.v` proves the fatal-pending-or-continuation-destroyed
  invariant and rejects the upper request for its explicit event system.  Add
  the missing linked proof that the concrete accepted-fatal state and every
  subsequent scheduler interval project to that event system, including the
  clear-to-reset barriers and latch-memory frame condition; zero lives may
  store game-over rather than death.  Under that refinement only a non-null
  graphical retry survives.  A null
  pre-apply platform still excludes only a pre-existing platform origin and
  must not be used to discard graphical rescue.  Treat this graphical gap as
  one possible **installer** for the JP stale-platform payload, not as a rival
  final route.  The source timer alignment for that composition is now narrow:
  the collision frame must see spinning-top timer `131`, frame `19` must run
  spinning timer `150`, and frame `20` must run explosion timer `0`.  The exact
  timer-131 transformed surface now rejects the old home-pose Y=`1791` witness
  and accepts the corrected midpoint.  Its clean installation and linked
  selection remain open.
  Completed supporting results are preserved under
  [Ink, quicksand, and clean-entry reductions](checklist-completed.md#ink-quicksand-and-clean-entry-reductions).

- [ ] Refine every clean linked US/JP retail step to those source kernels and
  exclude action/timer or input forgery through pointer aliasing, OOB stores,
  mutable landing descriptors, indirect callback/interaction retargeting,
  and unresolved external effects.  No concrete forged writer is known.

- [ ] Execute ordinary clean entry to establish exact Mario raw/Graphics
  memory equality, prove whole-program writer and action provenance with
  non-aliasing, refine the safe-depth relation to all live binary32 writes,
  and prove stock Area-1 automatic-dialog/reanchoring closure.  Until then
  the `>=960` installer is reduced, not eliminated.

- [ ] Extract the complete generated spawn graph, prove every live stock
  behavior has transitive source provenance, and show neither door behavior
  is reachable in that graph; also close clone/corruption/alias paths.

- [ ] Derive that source-shaped split from linked Clight expression and
  control execution, derive the remaining binary32 relation and finite/
  no-overflow premises from every reachable linked writer, prove
  quicksand-jump store/clamp non-interleaving, and exclude forged timer
  `4/5`, mutable-descriptor, aliased, out-of-bounds, and external stores.

- [ ] Execute the ordinary-entry postcondition in linked Clight, close
  external frames and non-aliasing, prove complete live writer/action
  provenance and binary32 sign preservation, and refine each cutscene
  reanchor plus its following sink.

### Route cuts, exhaustiveness, and capstone

- [ ] Project chronological Mario/action/surface observations from Clight and
  prove the transcript route contract complete for both entrances.

- [ ] Construct `EvidenceBearingFirstTargetCutClassification` from that
  projection and the parsed collision mesh; close every remaining writer class
  or record a reachable constructor as a counterexample.  Only then derive
  `FirstTargetCutClassificationObligation`.

- [ ] Discharge `FirstValidatedCrossingConstructionObligation` for strictly
  pre-target crossings, instantiate a concrete source/mesh-backed cut family,
  add ordered sub-frame control points for same-frame target crossings, and
  prove the six no-A movement/domain predicates plus
  `NoASupportSelectionFirstCrossing`.  Same-position floor/platform changes
  must not be discarded as nonspatial lifecycle events.

- [ ] Define the elevator cut and the lower target-side support/open-cell cut
  over exact collision surfaces, prove both no-A gate closures, and validate
  separate downstream continuations to the Act 3 region and all five Act 6
  triggers.  Do not use “above the second pole” as the lower geometric cut.

- [ ] Construct the live US/JP moving/static `Surface` projections and exact
  source components; cover same-frame collision phases; discharge all seven
  no-A writer/support classes for both cuts; and inhabit the separate US/JP
  downstream suffixes, including linked realizations of both transcript
  Act-3 itineraries.  The attempted JP direct-steering schedule did not use
  the Grindel/elevator misalignments, fell to Y=-101, and is not an exclusion.

- [ ] Prove `LowerEntranceReachabilityObligation`.

- [ ] Prove `UpperUSReachabilityObligation`.

- [ ] Prove `UpperJPReachabilityObligation`.

- [ ] Remove the conditional premises and prove the ultimate result.

## Medium priority

These obligations materially strengthen the proof but are not the shortest route to deciding the installer.

### Fatal-latch refinement

- [ ] Prove the linked US/JP accepted-fatal initialization, concrete event
  coverage, clear/reset barriers, and latch-memory frame condition that refine
  a retail execution into `RetailFatalLatch.v`.  The block-or-reset invariant
  is proved for the event system, not for linked Clight memory.

### Ordinary-motion safe envelope

- [ ] Instantiate the ordinary safe envelope for each clean US/JP entrance
  from linked Clight action execution and live collision surfaces.  Prove
  controller-memory alignment, cap initialization/preservation, reachable
  action closure, the upper no-spin entry descent and intended-floor landing,
  every intermediate floor/wall/ceiling query, and collision observation
  alignment.  The current jump-kick/rollout arithmetic and normalized Z
  soft-bonk subcase do not discharge this item.  For the Ink branch, replace
  the predicate-sensitive `Area1InkWriterCoverageObligation` schema with a
  concrete linked-run writer-coverage relation deriving the route-specific dry
  Graphics-minus-Object bound of at most `45` or the conservative modeled
  relation bound of at most `208` for every reachable writer.

### Negative-quicksand/star installer branch

- [ ] Prove or refute a fresh 100-coin star with compatible *relative*
  Mario/star transport at the first eligible collision, a different spawn
  placement, or an older already-tangible no-exit star.  The post-timer-4
  fresh-star timing retains exact `-2.65f`, but the checked finite
  successor pairing is vertically separated by more than 96 units under
  the modeled hitbox fields; refine the live collision and carry any
  surviving candidate through star dance and the milestone dialog in
  linked memory.

## Low priority

These are plausible supporting or alternative avenues. None currently has the
concrete clean-retail predecessor needed to outrank the linked installer proof.

### Turning-Part-2 animation hypothesis

- [ ] Connect converter-produced animation entry 189 and its payload size to
  linked US/JP memory; prove the `0x4000` animation buffer is disjoint from
  MarioState/Object/Graphics coordinates and give `dma_read` the required
  frame rule.

- [ ] Refine the Turning-Part-2 metadata model to actual linked Clight steps
  and classify any same-frame coordinate change through the real
  ground-step/platform/OOB writer path.

### Goomba raising and PU transport

- [ ] Construct a linked clean no-A `FullFloatHFRShuttleObligation`,
  `PreCollisionRawObjectReturnRaisingObligation`,
  `SpindelSameSegmentPUCaptureObligation`,
  `GoombaParallelUniverseTransportObligation`, and
  `RaisedGoombaToSpindelHandoffObligation`; then prove every later
  collision-preserving height handoff and continuation to the second-pole cut.
  Every execution trace must satisfy no A edge at all intermediate frames.
  Do not infer these witnesses from the vertical arithmetic alone.

### Shell and wall interactions

- [ ] Refine shell/wall behavior to binary32 Clight memory, prove pointer
  non-aliasing and all relevant callers, disable the debug-spawn path, and
  close every reachable Graphics/action/flag writer.

### Archived-kernel integration

- [ ] Connect any archive-derived kernel component needed on the capstone spine
  through a checked execution/refinement theorem; the current kernel by itself
  discharges no Layer A or Layer B residual.

### Legacy pole subcase

- [ ] Replace the legacy integer pole subcase with current Float32,
  collision-phase reasoning plus a complete lower-route case split.

## Already completed

The detailed record of checked results—including every qualification on what
each result does and does not prove—is preserved in the
[completed-task archive](checklist-completed.md).

- [Generation, source inventory, and entry facts](checklist-completed.md#generation-source-inventory-and-entry-facts)
  — pinned sources, generated units, entry facts, and imported
  collision/render data.
- [Proof architecture, archive evidence, and route contract](checklist-completed.md#proof-architecture-archive-evidence-and-route-contract)
  — layer boundaries, archived evidence, and theorem-contract scaffolding.
- [PU, collision arithmetic, State-first, and fatal-latch evidence](checklist-completed.md#pu-collision-arithmetic-state-first-and-fatal-latch-evidence)
  — numeric models and scoped collision/action evidence.
- [Alternative mechanics, static collision, and entry memory](checklist-completed.md#alternative-mechanics-static-collision-and-entry-memory)
  — eliminated or bounded mechanics plus concrete entry-memory facts.
- [Cut architecture, allocation groundwork, and documentation](checklist-completed.md#cut-architecture-allocation-groundwork-and-documentation)
  — route cuts, allocation certificates, and proof-ledger work.
- [Linked-program and gap-closure foundations](checklist-completed.md#linked-program-and-gap-closure-foundations)
  — official-link structure, tag repair, symbol facts, and partial semantic
  bridges.
- [Ink, quicksand, and clean-entry reductions](checklist-completed.md#ink-quicksand-and-clean-entry-reductions)
  — reductions and conditional exclusions for the graphical-gap installer.
- [JP stale-platform lineage and destination continuation](checklist-completed.md#jp-stale-platform-lineage-and-destination-continuation)
  — retained-pointer models, destination fixtures, and conditional
  continuation results.
- [Route cuts and downstream geometry](checklist-completed.md#route-cuts-and-downstream-geometry)
  — Area-2 cut geometry and post-gate route algorithms.
