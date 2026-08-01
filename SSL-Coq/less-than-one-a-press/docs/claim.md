# Claim boundary

## Proved

- Reproducible US/JP Clight AST source-shape facts listed in
  `proofs/ClightFacts.v`, over
  38 pinned translation units per version (76 generated modules).  The units
  cover Mario airborne, automatic, cutscene, moving, object, stationary, and
  submerged actions, `mario_step`, `obj_behaviors_2`, `math_util`,
  `surface_collision`, `surface_load`, `behavior_script`, `level_script`,
  `graph_node`, `rendering_graph_node`, `debug`, `memory`, and `mario_misc`,
  plus the route-relevant
  SSL static and dynamic collision arrays.
- `TurningAnimation.v` proves the narrow Turning-Part-2 boundary:
  generated US/JP receipts couple `forwardVel >= 18.0f` to animation IDs
  188/189, record both local ground-step/setter orders, tie `unkB0` to
  `animYTrans`, and check the loader and renderer direct footprints.  CompCert
  binary32 proves `189/189 = 1`; Part 2 has no gameplay-translation flag; and
  the metadata model preserves MarioState, raw Object, and Graphics-anchor
  positions, so it cannot create Ink's three-view split from synchronized
  input.  A formal one-cell alias witness shows why this is not yet a universal
  Clight memory theorem: converter/table mapping, the dedicated animation
  buffer's separation/DMA frame rule, and the linked before/after projection
  remain open.  No retail animation-induced upwarp was found.
- Generated source-shape facts show that the no-spin airborne entry handler
  calls `launch_mario_until_land` with binary32 zero, and that helper calls
  `mario_set_forward_vel` and `perform_air_step`.  These are call/constant
  facts, not an execution or containment theorem.
- `CollisionMeshFacts.v` checks initializer lengths and exact US/JP equality
  for the imported area-2/area-3 and route-relevant dynamic collision arrays.
  It now also checks every word of the 39-word pyramid-top collision stream
  and parses its five vertices and six triangle-index triples.  It does not
  yet construct dynamic surfaces or parse the general area arrays into a
  proved surface graph.
- `PyramidTopPU.v` proves that one full-coordinate sample cannot both overlap
  the handwritten Area-1 upper-warp predicate and satisfy the modeled
  top-height platform predicate.  Under explicit Y-preservation and floor-bound
  premises, the numeric floor query cannot succeed.  It separately proves a
  two-sample coordinate/alias model requiring a 1023-unit Y writer, and a
  general signed-16-range lower bound of 385 upward units between upper-warp
  overlap and an admissible numeric floor query at height 1281 or above.  It
  is not a stale-slot,
  dynamic-surface, Clight, or reachable execution theorem.
- `PyramidTopSurface.v` proves that the generated US/JP `find_floor` bodies
  have the exact signed-short cast prefix, evaluates the concrete CompCert
  casts and partition cells, and connects the parsed generated mesh to the
  selected zero-yaw home face.  It evaluates manually mirrored transform/edge
  formulas, checks a guarded dynamic-floor assignment source shape, and
  confirms the matrix/surface helper bodies are internal.  Authenticated
  US/JP retail disassembly plus Rocq fragment arithmetic verifies the same
  three concrete cast results.  It does not prove generated-expression
  extraction, linked live-memory execution, surface ownership/list order, or
  actual `find_floor` selection.
- `Timer131Surface.v` replaces the zero-yaw home approximation with the exact
  timer-131 pose and transformed signed-16 mesh, using CompCert binary32
  operations.  It proves that the old Graphics sample
  `(-2048,1791,-1024)` is rejected, while strict-interior low-side
  `(-1641,1456,-783)` and midpoint `(-1862,1778,-902)` samples are accepted.
  The midpoint requires at least `960` units of Graphics-minus-Object Y gap for
  any warp-overlapping Object and exactly `1010` at the warp centre.  The
  existing conditional `45` and `208` writer envelopes are arithmetically too
  small, but complete retail writer coverage is not proved.
- Hash-gated original-JP observations distinguish the two accepted points.  The
  low-side capture loses top support before explosion.  Given the injected
  midpoint three-view prestate, retail execution retains the top owner through
  explosion/free and the delayed warp, leaves the slot at free-list depth `47`,
  and applies its stale payload at the true first Area-2 application.  Authentic
  execution breakpoints confirm entry `0x802c83f0` at timer 515 with all Mario
  views at spawn and caller return `0x8029cfc8` with only State displaced.
  `Timer131Surface.v` and `JPLifecycleTrace.v` check the copied bit patterns,
  pointer/depth facts, exact finite LIFO arithmetic, zero-A counters, and trace-
  record consistency.  These theorems validate records and arithmetic; they are
  not linked Clight executions and do not prove a clean installer.
- `JPInstallTimerWindow.v` proves timer `131` unique in the behavior's
  `0..150` range for the observed affine install/freeze/explosion schedule.
  Linking those global offsets and lifecycle classes to concrete Clight memory
  remains an explicit refinement.
- From that injected midpoint boundary, the current zero-A JP continuation
  consumes all five hidden-star triggers, spawns the Act-6 star, overlaps it
  by one vertical unit using a B/Z slide kick, and changes the initially-clear
  Act-6 save byte from `00` to `20`.
- `InkFallback.v` separates the three coordinate views used by the source:
  object collision reads `MarioObject.oPos`, the first geometry query reads
  `MarioState.pos`, and a null first floor result copies
  `MarioObject.header.gfx.pos` into State for the retry.  It proves conditional
  local and Parallel-Universe coordinate witnesses with the Object at node
  `0x1E`, State at the checked floor-miss diagnostic, and Graphics at a modeled
  pyramid-top query.  The witnesses evaluate a handwritten
  retry/action/sink/copy pipeline; generated Clight syntax/dataflow receipts
  separately establish the null-test and retry shape.  The module also proves
  that prefixes already refined to State-only preserve Object and Graphics
  and cannot manufacture their split from a synchronized state.  A
  generic top retry whose Graphics Y remains in signed-16 range requires at
  least `385` units of Graphics-minus-Object Y separation, while either exact
  proposed prestate requires at least `973`.
  The source audit uses `45` as the dry route-specific target; `208` is a
  conservative modeled relation pending reachable-writer coverage.
  If the retry also returns no floor, the checked guarded fatal call occurs
  before cached warp interactions.  `RetailFatalLatch.v` proves, for its
  explicit checked event system, that an accepted fatal request either remains
  pending or a reset/terminal barrier destroys the old disappeared-action
  continuation; no trace in that system accepts the later upper-warp request.
  Generated receipts separately compute the direct-writer and explicit
  address-taking censuses, call-presence/callee-order plus separate
  clear-presence anchors, and a packed death record.  They do not prove
  assignment/call order or destination selection.  The block-or-reset
  invariant is proved for the checked event system, while the linked Clight
  projection remains open.  It must establish initial fatal acceptance,
  concrete event coverage, clear/reset barriers, and latch-memory
  preservation.  Under that refinement only a non-null retry can support this
  route.
  These are coordinate and source-shape results, not a proof that the actual
  first query returns `NULL`, the retry selects a loaded top-owned surface, or
  a clean retail run reaches either prestate.  Final surface-owner liveness is
  separately unresolved as a linked theorem; the injected midpoint runtime
  trace supplies conditional evidence only.
- `GoombaRaising.v` proves a bounded conditional H/F/R kernel rather than a
  pole bypass.  The corrected repeating ready state is airborne action `2`;
  binary32 proves the exact velocity update to `21.0f`, while arbitrary-Y
  position increments need not equal exactly 21 and addition stagnates at Y
  `2^29`.  Conditional integer Spindel-band arithmetic excludes direct use by
  the Area-2 integer-Y `778` singleton; linked binary32 collision/addition
  bounds remain open.  The 31-hit Area-1 bound applies to the
  post-collision H/F/R schedule, not the open pre-collision raw-Object writer
  schedule.  Trace-wide no-A shuttling, both scheduling shapes, same-segment
  PU platform capture, physical singleton transport, and all height handoffs
  are uninhabited obligations.  No retail counterexample follows.
- `Area1FirstNull.v` parses the generated US/JP collision initializers and
  kernel-computes the 574 vertices, 962 triangles, and exact 17-wall/26-floor
  cell inventories.  It computes all four static-wall decision lists and both
  static-floor decision lists as all-rejection, then packages zero-push and
  `Area1FloorNull` records.  The record is not an independently executed
  Clight traversal.  The rejection trace/tally has exact signed-arithmetic and
  decisive binary32 receipts.  The supported
  center, live/dynamic-list Clight execution, casts and memory effects, and
  clean-run reachability remain open.
- `EntryMemory.v` proves the generated US/JP composite sizes and offsets,
  defines a post-entry `Mem.load` postcondition (including velocity and
  controller observations), and proves that postcondition implies the stated
  State/raw Object/Graphics equality, action fields, frames/depth, and null
  throw-matrix projection.  It does not derive the postcondition by executing
  `init_mario_after_warp`; those US/JP refinement propositions remain open.
- A handwritten two-step shell transition reanchors each modeled frame from
  current State, so its Graphics Y gap is `42` in air or `45` on ground and
  does not accumulate under that definition.  Separate generated-AST receipts
  pin source order/literals and the ground- and air-shell quicksand reset
  paths; they do not yet refine that transition.
  The wall and warp conclusions are source/abstract-model facts, not a
  binary32 small-step proof.  Pointer aliasing, complete wall callers, live
  action/flag/writer closure, the route-local Float32 arithmetic and live-range
  obligations and ground
  float-to-integer cast refinement, and the debug-spawn guard remain open.
- Finite-width, edge-triggered input definition allows A to be initially held.
- `CleanPyramidEntry` fixes the lower/upper airborne entry snapshot, coherent
  active/backup target bits, the static Act 3 identity/position, and five
  distinct designated macro-trigger identities/positions without assuming
  target-region non-reachability.  It separately requires the generic
  delayed-warp cell to be empty and records current down, actual previous
  down, and the live pressed value under the source edge formula.
- `SourceExhaustiveness.v` proves a finite seven-source normal SSL inventory:
  only the static pyramid source has index `2`, only Pyramid Puzzle has index
  `5`, and indices `0`, `1`, `3`, `4`, and `6` alias neither target.  Its
  executable writer model proves that coherent reload cannot newly set a
  target and that, absent an explicit anomaly writer, the first target-bit
  transition is the uniquely matching normal star source.
- By constructor inversion in `CertifiedExecution`, a newly collected Act 3
  bit has an active index-2 star carrying the abstract static-origin tag and an
  abstract interaction overlap.
- In `CertifiedExecution`, a newly collected Act 6 bit has an active
  controller-origin-tagged index-5 star, a spawn event, collision-backed
  consumption events for all five abstract trigger labels, and an abstract
  overlap for the event labeled upper.  The step constructors assume the
  underlying facts; they are not derived from Clight here.
- The 100-coin index `6` differs from target indices `2` and `5`.
- `archived_proof_integration_kernel_holds` proves a
  `ArchivedProofIntegrationKernel` whose generated-source fields are rechecked
  against the current pinned US and JP ASTs.  It packages platform identifier,
  call, and version-split shapes; area call/identifier and slot-epoch facts;
  movement/pole/Eyerok source shapes; and a same-CompCert-block memory boundary.
- `RouteEvidence.v` proves only narrow subcases: continuously held A has no
  press edge; an accepted bounded static quarter-step retains a local
  parallel-universe coordinate; the normalized integer soft-bonk model cannot
  clear its modeled pole route; and a store to one CompCert block preserves a
  load from a different block.
- `TranscriptRouteModel.v` proves the route-gate logic extracted from
  the supplied transcript and the task's route-completeness proposal.  In that
  model, no-A target-region access exposes either an elevator escape or an
  above-second-pole observation, and excluding both bypasses makes a target
  route contain an A edge.  Under separately named downstream-completeness
  premises, spawning-displacement escape or above-pole access gives separate
  no-A continuations to the Act 3 region and upper Puzzle trigger, provided
  each continuation also carries the model's abstract execution certificate.
  The above-pole observation is a coarse transcript node, not the final lower
  collision cut.
- The historical strengthened first-target model selects one exact earliest
  target observation, synchronizes its route/event prefix, and proves that it
  is preceded by the entrance-specific A gate or one of nine bypass class tags
  only under `FirstTargetCutClassificationObligation`.  The tags carry no
  state/event evidence, so this remains logical bookkeeping.
- `FirstTargetRefinement.v` defines an evidence-bearing replacement using
  actual before/after Clight states, trace segments, exact indexed certified
  steps, and source-side/target-side crossings of a `CollisionSupportCut`.
  Within the certified semantics it proves that direct zero-offset
  area-2/area-3 warp displacement, invalid target provenance, invalid
  trigger/controller lifecycle, coherent target mutation by save reload, and
  certificate projection mismatch cannot be the bypass.  It also closes only
  the bounded static quarter-step coordinate-alias subcase.
- Under `ClightRouteTraceProjection`, a newly set Act 3 bit implies the Act 3
  route cut and a newly set Act 6 bit implies the upper-trigger route cut.
  `evidence_bearing_route_cut_blocks_new_target_bits` blocks both bits when the
  evidence-bearing classifier and the six open writer-family exclusions are
  supplied.  The implication is proved; those retail-program premises are not.
- `FirstCrossingWriterCoverage.v` proves that the old unrestricted cut data
  can be degenerate, parameterizes the result by a selected
  version/entrance/target cut family, gives each cut an entry contract,
  requires separation at the actual crossing endpoint,
  star-orders the crossing before a matching target-event segment, supplies
  ordered evidence for every earlier index, and proves an exhaustive
  abstract-event/state-field classification for non-target crossing events.
  A changed-position event carries one of five labels (ordinary physics,
  platform, object impulse, collision clip, or reload); unchanged position
  requires a changed floor/platform selection.  It also proves nonspatial
  admin preservation, changed-reload entry restoration, a conditional
  entry-contracted reload exclusion, and a
  local-cast alias exclusion.  The linked crossing construction, six no-A
  motion/domain exclusions, and the separate support-selection exclusion are
  not proved; those exclusions are scoped to clean entries and the selected cut
  family.
- The abstract `gMarioPlatform` model uses a pool slot plus a ghost capture
  epoch.  For a non-null pointer satisfying its slot-well-formedness premise,
  the live-same-epoch,
  inactive-same-epoch, and reused-slot cases are exhaustive; `None` supplies
  the null case.
- The source-backed-prehistory interface for the conditional pyramid-top path
  must preserve three independently sampled coordinates and both floor-query
  outcomes.  A null pre-apply platform is compatible with the first State
  query returning null and the Graphics retry selecting a loaded top-owned
  surface.  After the State/Object copy, later object lists and
  deactivated-object unloading precede the final query.  On an explosion frame
  the source order admits a loaded-surface candidate with an inactive top-owner
  slot.  Exact timer-131 arithmetic now rejects the closed home-pose Y `1791`
  witness and accepts midpoint `(-1862,1778,-902)`.  Given that midpoint's
  injected prestate, the JP runtime observes concrete surface ownership,
  raw-Object copying, explosion/free-list membership, same-slot final capture,
  delayed-warp retention, and first-apply displacement.  Sink pointer
  provenance, clean prestate reachability, exact linked pointer/epoch meaning,
  and the corresponding Clight small-step execution remain explicit
  obligations.  The observation preserves the possible path and validates its
  downstream lifecycle; it does not prove a stock predecessor.
- `JPSlotLifetime.v` checks the JP load/spawn/allocation/unload/free-list source
  anchors, including the loop/literal/indexed-zero-write shape for an 80-word
  allocation clear, and the 50-record Area-2 macro bound.  It proves the finite
  LIFO depth and Before/At/After allocation-count
  split plus the clean upper-entry live/inactive/reused classification.  These
  are staged source/list theorems, not the missing reachable memory trace.
- `JPFirstApply.v` distinguishes the true first destination platform
  application from the first Area-2 controller poll and the following, second
  application.  It proves the conditional finite census `74 + 10 = 84`, or
  `85` with a saved cap, and the exact popped/surviving depth arithmetic.  The
  source audit identifies Spindel as allocation 64/free-list depth 63.  The
  module leaves destination-scoped linked chronology, ordered allocation
  execution, pointer/block lineage, and payload loads as explicit evidence.
- `InkPayloadInstaller.v` makes the clarification formal: a final Area-1 owner
  installer and a first-Area-2 pointer fate/effect are separate data.  The
  checked timer schedule requires top timer 131 on the collision frame,
  spinning timer 150 on frame 19, and explosion timer 0 on frame 20.  The
  composition theorem preserves the original slot while permitting a new
  allocation epoch in the reused-payload case; no constructor is asserted
  reachable from retail Clight.
- `StateFirstInstaller.v` excludes the proposed stock State-first and
  Y-preserving wall-only installers at the finite source-bounded owner/origin
  boundary.  It does not exclude the Graphics retry, a non-stock pointer origin,
  or an execution outside that finite relation; the linked
  `Area1StockPreapplyProjectionSound` bridge remains open.
- `ModelGapAudit.v` proves that the current endpoint-only abstract certificate
  accepts arbitrary motion and synthetic immediate Act 3 collection from
  explicit clean US/JP entries.  This is a model counterexample, not a retail
  trace.

## Not proved

- Whole-program semantic refinement from the imported Clight units to each
  `CertifiedStep` constructor.
- A concrete linked target program, initial/final whole-program run, state and
  input/event/collision projections, frame certificate, or clean-entry
  projection-coverage proof.
- A proof that the abstract origin tags, trigger labels, player/object
  references, slot epochs, or pool/list validity flags denote and preserve the
  corresponding C memory facts.
- A proof that `ArchivedProofIntegrationKernel` implies that refinement or any
  entrance reachability obligation.  It does not.
- A projection from an actual Clight execution to `RouteTrace`, proof of
  `TranscriptRouteGateModel` or
  `FirstTargetCutClassificationObligation`, any global bypass exclusion, or
  either downstream-completeness premise.  The route theorems establish the
  logical cut/classification, not that either contract is complete for a
  target ROM.
- Clight-to-writer coverage for the normal SSL source/save inventory.  Its
  corruption/unmodeled constructor remains explicit until that bridge is
  proved.
- Complete position-writer coverage for the parallel-universe subcase,
  Float32 and collision-phase completeness for the pole subcase, an authentic
  Eyerok height/refinement theorem, or demo/Mario block provenance.
- Reachability classification and displacement bounds for every null, live,
  inactive, or reused JP platform-slot case.
- A clean retail installer for the JP stale-platform payload.  Ink's non-null
  graphical retry is one candidate installer, with the timed top constrained
  to spinning timer 131 on the collision frame, timer 150 on frame 19, and
  explosion timer 0 on frame 20.  State-first selection, physical co-location
  or cloning, post-commit transport, another owner, and frozen carry are not
  collectively excluded.  The current midpoint fixture injects the required
  three-view prestate in Area 1; retail execution then performs the capture,
  lifecycle, and true first Area-2 displacement.  It still does not show how a
  clean controller-only run creates the required `>=960` gap.
  The current clean-JP reduction proves that any phase already refined to
  State-only preserves the Object/Graphics gap and that its range-certified
  writer relation cannot reach `960` from synchronized entry.  Generated-JP
  receipts inventory direct `quicksandDepth` writers in the selected
  Mario/action units and couple the ordinary long-jump constructor to
  `INPUT_A_PRESSED`.  The corresponding source-shaped relation excludes that
  late writer and keeps depth nonnegative.  This is not whole-program closure:
  proving that clean no-edge execution refines that relation, linked writer/action
  provenance, pointer non-aliasing, exact binary32 projection, and stock
  dialog reachability remain open.  An already-negative `-2.650000095f`
  depth would be a genuine escape; 363 unreanchored automatic-dialog sinks
  reach a zero-base binary32 endpoint at least `960`, but live-base
  displacement and a clean zero-A source for that combined state remain open.
- Stock reachability or impossibility of the pyramid-top upper-warp path.
  The Y-preserving stock-yaw arithmetic case is excluded, the exact concrete
  retail cast is verified, and the bounded pre-apply owner theorem excludes
  only pre-existing modeled platform origins.  It does not exclude the
  graphical-fallback bootstrap, which can begin with a null platform and
  capture the top only after a non-null retry.  The five-obligation audit
  changes how the remaining boundary is stated.  The surface, prestate, and
  writer propositions are predicate-sensitive schemas; replace them with
  concrete linked-run relations proving the first-query miss, loaded-top retry,
  clean no-A prestate reachability, and complete writer closure.  The original
  sink proposition was false under repeated-return execution and a concrete
  modular pointer alias.  Its repaired first-return, disjoint-cell
  `InkFallbackSinkMemoryRefinementObligation` remains open.  The current
  `InkFallbackPostCopyLifecycleRefinementObligation` is unsafe or vacuous
  rather than a valid theorem target: replace it with an exact link importing
  `behavior_script.c`, an anchored clean run, a certified memory projection,
  external-call frame conditions, finite transformed-surface data, and
  pointer-to-slot/epoch linkage.  The conditional JP midpoint run observes later
  object writers, unload/free at depth zero, retained surface identity, final
  inactive ownership, delayed-warp survival, 84 destination allocations, and
  the exact first-apply payload at depth 47.  Those runtime observations and
  their Rocq record checks do not repair the semantic interface or prove a clean
  predecessor.  Generated-expression extraction, linked live-memory execution,
  dynamic-surface ownership/list selection, exact pointer/epoch projection, and
  Clight refinement of the now-confirmed authentic instruction-entry/return
  first-apply receipt remain open.  The US state model blocks same-epoch retention after a
  successful spawn clear, whose Clight memory effect is still pending.  An
  authentic-JP midpoint fixture with zero A edges moves Mario outside the shaft
  at the first Area-2 application, consumes all five triggers, spawns and
  overlaps the Act-6 star, and newly sets its bit with no A edge.  It has no
  Act-3 overlap.
  No controller-only retail predecessor has been established.  Other
  open cases include moving/loading the warp onto the top, moving the top to
  the warp, and collision-preserving cloning.
- A complete collision-observation projection, and lower-entrance no-A
  non-overlap over that projection.  The lower cut must use collision-phase
  entry into enumerated target-side supports/open cells, not a height predicate
  above the second pole.
- US upper-entrance containment/non-overlap.
- JP upper-entrance containment with retained-platform spawning displacement.
- The unconditional target-ROM impossibility theorem.
- Either the existence or the impossibility of a stock-reachable
  counterexample.  The fixture-assisted five-trigger/star-spawn witness
  falsifies the state-only bypass-exclusion claim, but not the stock game
  theorem; the installer and final star collection remain open, and other
  finite schedule checks are not exhaustive.

Consequently, `collection_provenance_reduction` is not described as the final
impossibility result.  None of `ssl-spawning-displacement-proof`,
`ssl-pyramid-item-proof`, `ssl-parallel-universe`, `pole-bypass`,
`eyerok-manipulation`, or `demo-warp` closes the whole-program Layer A
refinement or a Layer B obligation.  See
[`notes/archived-proof-evidence.md`](notes/archived-proof-evidence.md) for the detailed
support matrix and [`../human-readable-proof.md`](../human-readable-proof.md)
for the route-gate argument in software-engineering terms.  The alternative
route classification is detailed in
[`notes/route-exhaustiveness.md`](notes/route-exhaustiveness.md).
The exact timed surface and conditional retained-slot trace are documented in
[`notes/timer131-surface.md`](notes/timer131-surface.md) and
[`notes/jp-lifecycle-trace.md`](notes/jp-lifecycle-trace.md).
