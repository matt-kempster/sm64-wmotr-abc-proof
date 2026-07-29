# Claim boundary

## Proved

- Reproducible US/JP Clight AST source-shape facts listed in
  `proofs/ClightFacts.v`, over
  31 pinned translation units per version (62 generated modules).  The units
  cover Mario airborne, automatic, cutscene, moving, object, stationary, and
  submerged actions, `mario_step`, `obj_behaviors_2`, `math_util`,
  `surface_collision`, and `surface_load`, plus the route-relevant SSL static
  and dynamic collision arrays.
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
- `InkFallback.v` separates the three coordinate views used by the source:
  object collision reads `MarioObject.oPos`, the first geometry query reads
  `MarioState.pos`, and a null first floor result copies
  `MarioObject.header.gfx.pos` into State for the retry.  It proves conditional
  local and Parallel-Universe coordinate witnesses with the Object at node
  `0x1E`, State at the checked floor-miss diagnostic, and Graphics at a modeled
  pyramid-top query.  The witnesses evaluate a handwritten
  retry/action/sink/copy pipeline; generated Clight syntax/dataflow receipts
  separately establish the null-test and retry shape.  The module also proves
  that State-only ordinary, platform, or PU prefixes preserve Object and
  Graphics and cannot manufacture their split from a synchronized state.  A
  generic top retry whose Graphics Y remains in signed-16 range requires at
  least `385` units of Graphics-minus-Object Y separation, while either exact
  proposed prestate requires at least `973`.
  The source audit uses `45` as the dry route-specific target; `208` is a
  conservative modeled relation pending reachable-writer coverage.
  If the retry also returns no floor, the checked guarded fatal call occurs
  before cached warp interactions and the abstract first-writer latch blocks
  the later upper-warp request.  Zero lives rewrites death to the still-nonzero
  game-over operation.  The linked proof must show the latch starts empty and
  then prove the scheduler-aware disjunction: the fatal value either remains
  occupied through the delayed action call, or any earlier clear belongs to a
  reset/initialization interval that destroys the continuation before another
  Mario update.  Under those premises only a non-null retry can support this
  route.
  These are coordinate and source-shape results, not a proof that the actual
  first query returns `NULL`, the retry selects a loaded top-owned surface, or
  a clean retail run reaches either prestate.  Final surface-owner liveness is
  separately unresolved.
- Finite-width, edge-triggered input definition allows A to be initially held.
- `CleanPyramidEntry` fixes the lower/upper airborne entry snapshot, coherent
  active/backup target bits, the static Act 3 identity/position, and five
  distinct designated macro-trigger identities/positions without assuming
  target-region non-reachability.
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
  slot.  The closed Y `1791` witnesses use the zero-yaw home top and do not
  instantiate that later translated/rotated pose.  Concrete surface identity,
  selected explosion-pose floor height, free-list membership, sink pointer
  provenance, raw-Object preservation, and the exact final owner epoch are
  explicit obligations.  Any JP stale-slot continuation must then
  prove the actual predecessor Clight segment, capture, unload retention, and
  optional fresh slot reuse.  This preserves the possible path rather than
  proving it reachable or harmless.
- `JPSlotLifetime.v` checks the JP load/spawn/allocation/unload/free-list source
  anchors, including the loop/literal/indexed-zero-write shape for an 80-word
  allocation clear, and the 50-record Area-2 macro bound.  It proves the finite
  LIFO depth and Before/At/After allocation-count
  split plus the clean upper-entry live/inactive/reused classification.  These
  are staged source/list theorems, not the missing reachable memory trace.
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
  pointer-to-slot/epoch linkage.  Only then prove later object writers, unload
  preservation, retained surface identity, and the final
  active/inactive-same-epoch owner.  A separate linked fact must show that the
  top itself is scanned/deallocated and establish any claimed free-list
  membership.
  Generated-expression extraction, linked live-memory execution,
  dynamic-surface ownership/list selection, collision-array retention,
  capture/unload timing, and JP delayed node-`0x1E` pointer lifetime also
  remain open.  The exact destination-area allocation/free trace, first-apply
  identification, and payload are open despite the finite LIFO
  classification.  The US state model blocks same-epoch retention after a
  successful spawn clear, whose Clight memory effect is still pending.  An
  authentic-JP boundary fixture with the raw payload moves Mario outside the
  shaft and consumes the upper trigger with no A edge, but has no Act 3
  overlap, does not spawn the Act 6 star, and does not directly inspect save
  RAM.  No controller-only retail predecessor has been established.  Other
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
  counterexample.  The fixture-assisted upper-trigger witness falsifies the
  state-only bypass-exclusion claim, but not the stock game theorem; other
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
