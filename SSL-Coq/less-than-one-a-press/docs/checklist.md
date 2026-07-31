# Verification checklist

- [x] Exact decomp commit pinned.
- [x] US and JP macros generated separately.
- [x] Generate 38 translation units per version (76 Clight modules), including
  all seven Mario action units (with `mario_actions_cutscene` and the direct
  writers in `mario_actions_submerged`), movement code,
  `mario_step`, `obj_behaviors_2`, `math_util`, `surface_collision`,
  `surface_load`, wrappers for the Area-1 and Area-2 macro streams, and a
  wrapper for the route-relevant SSL static and dynamic collision arrays.
  The boundary also imports `behavior_script`, `level_script`, `graph_node`,
  `rendering_graph_node`, `debug`, `memory`, and `mario_misc` for entry,
  render-footprint, and writer-closure work.
- [x] Check generated no-spin-airborne entry call shape, collision initializer
  lengths, and exact US/JP equality for the imported route-relevant collision
  arrays.
- [x] Import `rendering_graph_node.c` for US and JP and check the exact
  `animYTrans / animYTransDivisor` renderer-global assignment.
- [x] Prove the Turning-Part-2 source/arithmetic/model boundary: exact
  `18.0f` selector with IDs 188/189, both local ground-step orders,
  `unkB0 -> animYTrans`, binary32 `189/189 = 1`, no physical translation
  flags, and three-view coordinate preservation.
- [x] Exhibit the over-permissive animation-DMA alias counterexample rather
  than assuming a universal external-call frame rule.
- [ ] Connect converter-produced animation entry 189 and its payload size to
  linked US/JP memory; prove the `0x4000` animation buffer is disjoint from
  MarioState/Object/Graphics coordinates and give `dma_read` the required
  frame rule.
- [ ] Refine the Turning-Part-2 metadata model to actual linked Clight steps
  and classify any same-frame coordinate change through the real
  ground-step/platform/OOB writer path.
- [x] Input edge and held state distinguished.
- [x] Act 3, Act 6, and 100-coin indices checked from source.
- [x] Static Act 3 object and five hidden triggers checked from initializers.
- [x] Strengthen clean entry with exact lower/upper warp snapshot, coherent
  active/backup target bits, exact static Act 3 position, and five distinct
  designated trigger identities/positions.
- [x] Prove the finite normal SSL star-index inventory, coherent-reload
  exclusion, and anomaly-free first-target writer classification in the
  executable source-inventory kernel.
- [x] Event vocabulary names spawn, deletion, reuse, macro respawn,
  unload/reload, save reload, explicit Mario motion, instant warp, and
  collision timing.
- [x] Constructor-inversion collection/provenance reduction builds without
  proof holes; full lifecycle effects and its Clight refinement remain open.
- [x] Recheck the six archive-derived evidence components against the current
  project where they make source claims, and prove
  `archived_proof_integration_kernel_holds` without importing archived ASTs.
- [x] Keep the held-A, parallel-universe, normalized-pole, and demo-memory
  `RouteEvidence` lemmas narrow and explicitly separate from authentic route
  completeness.
- [x] Model `gMarioPlatform` abstractly as a pool slot plus ghost capture epoch
  and prove the null/live/inactive/reused case split under explicit slot
  well-formedness; its C-memory projection remains open.
- [x] Document what each archived project supports and does not support in
  [`notes/archived-proof-evidence.md`](notes/archived-proof-evidence.md).
- [x] Encode the transcript's elevator/second-pole route contract and prove its
  gate, bypass-refutation, and conditional downstream-access lemmas without
  presenting the graph as a target-ROM refinement.
- [x] Select the exact first target observation/event prefix and prove
  entrance-specific “A gate or one of nine named bypass class tags” lemmas
  under the broad `FirstTargetCutClassificationObligation`; the tags are not
  yet state/event evidence.
- [x] Define `ClightFrameEvidence`, a total certified-event writer inventory,
  evidence-bearing bypass classes, and `CollisionSupportCut` crossing
  witnesses.  Prove the limited certified-semantics exclusions for direct
  zero-offset instant warp, invalid target provenance, invalid hidden-star
  lifecycle, coherent save reload, and projection mismatch.
- [x] Demonstrate that endpoint/event alignment alone cannot imply first-cut
  classification, and record the abstract arbitrary-motion/immediate-target
  counterexample for explicit clean US/JP entries.
- [x] Preserve the conditional JP upper-warp/pyramid-top stale-pointer path in
  a source-backed predecessor/unload/reuse evidence interface rather than
  assuming a null or harmless retained pointer.
- [x] Recheck syntax anchors for the PU floor cast, State/Object fields, warp
  action/floor-snap pipeline, final platform query, and delayed warp against
  both generated Clight versions; document that direct source inspection, not
  those path/base-insensitive AST checks, supplies the update-order account.
- [x] Check the exact 39-word pyramid-top collision initializer, parse its five
  vertices and six triangles, and prove the modeled same-sample contradiction
  plus conditional Y-preserving stock-yaw exclusion.  Also record the
  admission-free two-sample coordinate/alias model, which requires a
  three-dimensional writer, and prove the 385-unit upward lower bound for an
  upper-warp overlap followed by a height-at-least-1281 numeric floor query
  whose post-copy Y remains in signed-16 range.  These results
  prove neither dynamic-surface selection nor reachability.
- [x] Import the complete `math_util.c` and `surface_load.c` Clight bodies and
  check the concrete CompCert signed-short sample and partition cells.  Link the
  selected zero-yaw home face to the parsed generated mesh, evaluate manually
  mirrored transform/edge formulas, and check a guarded dynamic-floor
  assignment shape.  Authenticated US/JP retail disassembly plus Rocq fragment
  arithmetic verifies the same concrete casts.  Keep generated-expression
  extraction, linked live-surface memory, list order, and actual `find_floor`
  selection open.
- [x] Import the Area-1 macro stream, check the fragment-producing generated
  source paths and exact parent records, and exhibit a CompCert-binary32
  fragment payload that changes X/Y/Z while raising Y by about 1110.67 units.
  Check its signed-short query, parsed top/static face edges, exact binary32
  candidate heights, and 78-unit floor buffer.  Treat this as a payload and
  geometry capability counterexample, not a reachable stale-pointer trace or
  live-list selection proof.
- [x] Prove at the phase boundary that a platform pointer captured from the
  stock top cannot bootstrap node-`0x1E` collision on the next frame when the
  collision pass preserves the prior copied MarioObject sample.
- [x] Import the breakable-box, exclamation-box-outline, cannon-lid, and
  wooden-signpost collision meshes and prove their exact generated local bounds
  for US and JP.  Enumerate the fifteen modeled stock Area-1 dynamic-floor
  owners and prove every source-bounded completed-query, US spawn-clear,
  retained-inbound-pointer, or frozen-carry platform origin null at node `0x1E`.
  Record that `[top, box]` is not a unique schedule: the generic source audit
  has top-yaw, dirt-triangle, and cartoon-triangle angular classes with
  depth/mist/zero-allocation/FIFO variants.  Generic controller/free-list
  lineage is no longer needed to classify those bounded pre-apply platform
  origins.  The null result does not discharge a later graphical-fallback
  bootstrap.
- [x] Check the US/JP graphical floor-fallback and entry-coordinate-sync source
  shapes.  Prove conditional local and PU three-view coordinate witnesses, the
  signed-range generic `385`-unit and exact-candidate `973`-unit minimum
  Graphics-minus-Object Y separations, preservation of Object and Graphics by
  arbitrary State-only ordinary/platform/PU prefixes, the dry `45`-unit
  conditional exclusion, and the modeled `208`-unit writer-relation exclusion.
  Treat the witnesses as handwritten pipeline evaluations and the generated
  null/copy/retry/death-latch matches as separate source-shape receipts.  Keep
  the first-query `NULL` result, loaded top-owned retry selection, retail
  writer coverage, clean prestate reachability, repaired sink-memory
  refinement, replacement post-copy lifecycle interface, linked latch/event
  refinement, and delayed-warp continuation open.
- [x] Compute the exact generated `level_update.c` direct-writer and explicit
  address-taking census for `sDelayedWarpOp`; check call-presence/callee-order
  plus separate clear-presence and packed death-record anchors; and prove the
  finite fatal-pending-or-old-continuation-destroyed invariant for the explicit
  event system.  The receipts do not prove assignment/call order or
  destination selection.
- [ ] Prove the linked US/JP accepted-fatal initialization, concrete event
  coverage, clear/reset barriers, and latch-memory frame condition that refine
  a retail execution into `RetailFatalLatch.v`.  The block-or-reset invariant
  is proved for the event system, not for linked Clight memory.
- [x] Formalize the corrected bounded Goomba-raising primitive: one-time
  priming, repeating airborne action-2 H/F/R cycle, exact binary32
  velocity `25 + (-4) = 21`, idealized integer-cycle formula, concrete
  low-height binary32 runs, `2^29` stagnation witness, conditional Spindel
  collision band, and schedule-specific finite Area-1 top-window bound.
  Compute matching US/JP callback/action/collision/load source-shape receipts.
- [ ] Construct a linked clean no-A `FullFloatHFRShuttleObligation`,
  `PreCollisionRawObjectReturnRaisingObligation`,
  `SpindelSameSegmentPUCaptureObligation`,
  `GoombaParallelUniverseTransportObligation`, and
  `RaisedGoombaToSpindelHandoffObligation`; then prove every later
  collision-preserving height handoff and continuation to the second-pole cut.
  Every execution trace must satisfy no A edge at all intermediate frames.
  Do not infer these witnesses from the vertical arithmetic alone.
- [x] Parse the generated US/JP Area-1 static initializers in Rocq and compute
  the exact 17-wall/26-floor cell inventories.  Compute all four static-wall
  and both static-floor decision lists as all-rejection, then package
  zero-push and `Area1FloorNull`/`-11000.0f` records in the pure evaluator.
  This is not an independently executed Clight traversal.  Derive the
  `12+8+5+1` rejection trace/tally with decisive signed-arithmetic and
  binary32 receipts.
- [ ] Execute/refine the wall and floor traversals in live Clight memory and
  include dynamic lists, casts and memory effects, then prove or refute clean
  reachability of the first-`NULL` sample.
- [x] Prove generated US/JP entry layout certificates, define a concrete
  `Mem.load` postcondition including position/action/velocity/depth/controller
  observations, and prove its State/Object/action/depth/frames/throw-matrix
  projection in `EntryMemory.v`.  Keep execution of `init_mario_after_warp`
  and projection of the controller loads into the first modeled frame as
  named pending refinements.
- [x] Correct the controller boundary so clean entry records the already-live
  pressed value computed from actual current/previous down samples, and
  separately records an empty generic delayed-warp latch.
- [x] Check source-order/literal receipts and prove that the handwritten
  two-step shell transition reanchors the second frame and therefore does not
  accumulate its `+42`/`+45` gap under that definition; also pin the ground-
  and air-shell quicksand reset paths.
- [ ] Refine shell/wall behavior to binary32 Clight memory, prove pointer
  non-aliasing and all relevant callers, disable the debug-spawn path, and
  close every reachable Graphics/action/flag writer.
- [x] Prove that aligned newly set Act 3 and Act 6 bits reach the matching
  target-region route cuts, and prove
  `evidence_bearing_route_cut_blocks_new_target_bits` under the explicit
  evidence-bearing classifier and six writer-family exclusions.
- [x] Replace the unused first-writer inventory boundary with
  `TargetCollisionCutFamily`, `EntranceCollisionCutEntryContract`, and
  `FirstValidatedCutCrossingAt`; prove that an unvalidated cut may overlap
  itself and that every contracted, endpoint-separated, pre-target,
  non-target crossing is a position write by ordinary physics, platform
  displacement, object impulse, collision clip, or area reload, or else a
  same-position floor/platform support-selection change.  Scope all no-A
  exclusions to clean entries and the selected cut family.  Prove nonspatial
  admin preservation, changed-reload entry restoration, conditional reload
  exclusion, and the local-cast alias exclusion without claiming the linked
  construction or no-A geometry predicates.
- [x] Isolate ordinary motion in `OrdinaryMotion.v`: prove generic composition
  from explicit finite-cell preservation/target-exclusion obligations, exact
  US/JP elevator and selected lower-mesh initializer receipts, held-A
  jump-kick and B-rollout source shapes, and the non-Wing 4-unit-gravity
  `128 < 231` and `220 < 231` integer-translation upper-elevator arithmetic after the dynamic
  surface `+5` upper-Y pad.  Record the Wing-Cap `220 < 228 < 231` arithmetic
  countermodel and cap-state projection requirement without claiming retail
  action/collision reachability.
- [x] Check JP allocation/unload/free-list source anchors, prove the 50-record
  Area-2 macro bound, finite LIFO recurrence, and Before/At/After allocation
  count split.  Keep the exact first-Area-2-apply memory trace and payload as a
  named obligation.
- [x] Record the authentic-JP boundary-fixture constructor: the exact stale
  top raw transform payload, a zero-A input schedule, platform displacement out
  of the shaft, upper-trigger consumption with no Act 3 overlap or Act 6 star
  spawn, and the failed pre-transition-only preparation.  Save RAM was not
  directly read.  This closes the state-only bypass-unreachability alternative,
  not stock reachability or the newly-set-bit theorem.
- [x] Document the alternative-route coverage boundary in
  [`notes/route-exhaustiveness.md`](notes/route-exhaustiveness.md).
- [x] Add a software-engineer-oriented
  [`human-readable-proof.md`](../human-readable-proof.md).
- [x] No-hole source scan and assumption reports are part of `make check`.
- [ ] Construct an iterated link of the imported translation units and prove
  the `TargetLinkedProgram` link-order certificate.
- [ ] Define concrete state, input, event, and complete collision-observation
  projections for actual initial-to-final Clight runs.
- [ ] Prove both `WholeProgramClightRefinementObligation` and
  `CleanEntryProjectionNonvacuityObligation` for that projection.
- [ ] Derive constructor origin, collision, spawn, trigger, lifecycle, and
  preservation premises from Clight instead of assuming them in steps.
- [ ] Prove Clight-to-writer coverage for the finite normal-star/save
  inventory, excluding the explicit corruption/unmodeled writer for clean
  target executions.
- [ ] Connect any archive-derived kernel component needed on the capstone spine
  through a checked execution/refinement theorem; the current kernel by itself
  discharges no Layer A or Layer B residual.
- [ ] Prove complete current-program writer coverage before using the
  parallel-universe alias-gap subcase globally.
- [ ] Replace the legacy integer pole subcase with current Float32,
  collision-phase reasoning plus a complete lower-route case split.
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
- [ ] Prove or refute the five narrow Ink obligations:
  the surface, prestate, and writer forms are now proved predicate-sensitive
  schemas rather than closed retail statements.  The exact prestate requires
  at least a `973`-unit Graphics-minus-Object Y gap, and complete audited
  writer-execution coverage from an audited entry conditionally refutes it.
  Retail writer and live-list coverage remain open.  The original sink
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
  must not be used to discard graphical rescue.
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
  are unreachable.
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
- [ ] Prove `LowerEntranceReachabilityObligation`.
- [ ] Prove `UpperUSReachabilityObligation`.
- [ ] Prove `UpperJPReachabilityObligation`.
- [ ] Remove the conditional premises and prove the ultimate result.
