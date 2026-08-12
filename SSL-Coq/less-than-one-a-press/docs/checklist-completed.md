# Completed-task archive

[Return to the open action board](checklist.md).

Completed work is grouped by subject. Each item retains its original scope warning; conditional models and runtime fixtures are not promoted to linked retail proofs.

## Generation, source inventory, and entry facts

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

## Proof architecture, archive evidence, and route contract

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

## PU, collision arithmetic, State-first, and fatal-latch evidence

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

- [x] Separate successful finite terrain casts from failed word conversions.
  Check CompCert conversion failure for quiet NaN, both infinities, `+2^31`,
  and the first binary32 value below `-2^31`; check the US/JP
  `FPCSR_FS | FPCSR_EV` initialization-word receipts; check the stock
  fault-handler's stop rather than resume path; and prove in the small
  target-prefix model that a trap precedes any terrain coordinate.  Also check
  the adjacent successful word endpoints narrowing to `-128` and `0`, and the
  total post-narrowing horizontal X/Z eligible-versus-boundary-rejected split.
  Retail execution remains conditional on
  `RetailInvalidCastExecutionRefinementObligation` and
  `RetailInvalidEnablePreservationObligation`, plus the handler fact named by
  `RetailInvalidTrapContinuationExclusionSchema`.

- [x] Check the full finite signed-16 alias vector
  `(-1862,67314,-902) -> (-1862,1778,-902)` and prove that its narrowed query
  equals the accepted timer-131 midpoint.  Package the resulting State-first
  numeric capability without claiming a clean writer or target reachability.

- [x] Check the three concrete CompCert float-to-signed-short values and the
  modeled target `trunc.w.s; mfc1; sh; lh` prefix arithmetic.  Check that the
  two wall-query heights are exactly `67374` and `67344`, both above every
  signed-16 `Surface.upperY`, and prove a source-shaped wall-list traversal
  cannot reach an X/Z push.  Linked statement/list-memory execution remains
  open.

- [x] Execute the injected State-first candidate in a hash-gated original-JP
  run.  Record the post-frame discriminator: candidate State X/Z survive, the
  distinct Graphics X/Z are not copied, and `MarioState.floor` has the
  timer-131 top owner and height word `0x44defe16`.  This supports first-query
  success under the audited source order but does not directly instrument the
  branch.  Also record cached upper-warp action selection, snap/copy synchronization,
  and final top capture with zero A counts.  Continue the exact fixture through
  timer-513 free, the retained depth-47 slot at the true first Area-2 apply,
  and upper-trigger counter `0 -> 1`.  Check transparent Rocq copies of both
  focused traces without treating those data records as execution proofs.

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
  arbitrary prefixes already refined to State-only, the dry `45`-unit
  conditional exclusion, and the modeled `208`-unit writer-relation exclusion.
  Treat the witnesses as handwritten pipeline evaluations and the generated
  null/copy/retry/death-latch matches as separate source-shape receipts.  Keep
  the first-query `NULL` result, loaded top-owned retry selection, retail
  writer coverage, clean prestate reachability, repaired sink-memory
  refinement, replacement post-copy lifecycle interface, linked latch/event
  refinement, and delayed-warp continuation open.

- [x] Compute the exact timer-131 pyramid-top pose and transformed mesh with
  CompCert binary32 operations.  Reject the old home-pose Graphics point
  `(-2048,1791,-1024)`; accept strict-interior low-side
  `(-1641,1456,-783)` and midpoint `(-1862,1778,-902)` points; and prove the
  midpoint requires a Graphics/Object Y gap of at least `960`, exactly `1010`
  at the warp centre.  This is value-level surface arithmetic, not linked live-
  list selection or clean reachability.

- [x] Record the hash-gated conditional JP timer-131 runs: the low-side capture
  loses top support before explosion, while the midpoint capture retains the
  top-owned floor through explosion/free and the delayed warp, survives at
  free-list depth `47`, and supplies the first Area-2 displacement.  Check the
  copied bit patterns, owners, depths, zero-A counters, and finite trace
  consistency in Rocq without presenting the observation record as a Clight
  small-step theorem.

- [x] Compute the exact generated `level_update.c` direct-writer and explicit
  address-taking census for `sDelayedWarpOp`; check call-presence/callee-order
  plus separate clear-presence and packed death-record anchors; and prove the
  finite fatal-pending-or-old-continuation-destroyed invariant for the explicit
  event system.  The receipts do not prove assignment/call order or
  destination selection.

## Alternative mechanics, static collision, and entry memory

- [x] Formalize the corrected bounded Goomba-raising primitive: one-time
  priming, repeating airborne action-2 H/F/R cycle, exact binary32
  velocity `25 + (-4) = 21`, idealized integer-cycle formula, concrete
  low-height binary32 runs, `2^29` stagnation witness, conditional Spindel
  collision band, and schedule-specific finite Area-1 top-window bound.
  Compute matching US/JP callback/action/collision/load source-shape receipts.

- [x] Parse the generated US/JP Area-1 static initializers in Rocq and compute
  the exact 17-wall/26-floor cell inventories.  Compute all four static-wall
  and both static-floor decision lists as all-rejection, then package
  zero-push and `Area1FloorNull`/`-11000.0f` records in the pure evaluator.
  This is not an independently executed Clight traversal.  Derive the
  `12+8+5+1` rejection trace/tally with decisive signed-arithmetic and
  binary32 receipts.

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

## Cut architecture, allocation groundwork, and documentation

- [x] Prove that aligned newly set Act 3 and Act 6 bits reach the matching
  target-region route cuts, and prove
  `evidence_bearing_route_cut_blocks_new_target_bits` under the explicit
  evidence-bearing classifier and six writer-family exclusions.

- [x] Replace the unused first-writer inventory boundary with
  `TargetCollisionCutFamily` and a run-local `FirstValidatedCutCrossingAt`;
  prove that an unvalidated cut may overlap
  itself and that every run-locally initialized, endpoint-separated, pre-target,
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
  count split.  The injected midpoint run now supplies exact before/after
  first-Area-2-apply memory observations, a concrete early-freed-top depth, and
  an authentic retail instruction-entry/return receipt.  Keep the linked
  allocation/pointer/epoch trace and clean predecessor as named obligations.

- [x] Record the authentic-JP boundary-fixture constructors: the older
  destination-slot payload and the stronger timer-131 midpoint Area-1 prestate.
  In the latter run, retail execution performs top capture, explosion/free,
  delayed-warp retention, first-apply platform displacement, all five hidden-
  trigger consumptions, Act-6 star spawn, one-unit target overlap, and an
  initially-clear `00` to `20` Act-6 save-bit transition with zero A edges.
  This closes the conditional downstream continuation, not clean stock
  reachability of its injected timer-131 boundary.

- [x] Document the alternative-route coverage boundary in
  [`notes/route-exhaustiveness.md`](notes/route-exhaustiveness.md).

- [x] Add a software-engineer-oriented
  [`human-readable-proof.md`](../human-readable-proof.md).

- [x] No-hole source scan and assumption reports are part of `make check`.

## Linked-program and gap-closure foundations

- [x] Linked gap-closure step 1 — Run CompCert's unmodified linker over all 38 US and 38 JP units and
  prove the exact failure boundary: AST index 34 (`ssl_script`) and
  composite index 27 (`area`) for both versions, with 402 US and 401 JP
  duplicate-public-variable type mismatches.  Deterministic normalized
  semantic slices are constructed, but they are not official links.

- [x] Linked gap-closure step 1 — Prove equal function call ABIs, exact-or-incomplete-array compatibility
  except for the storage-equivalent `gDisplayListHead` pointer views, named
  residual layout compatibility, and the exact incompatible US `__538`
  viewport/Gfx-tag collision.  Construct its local fresh-tag layout repair.

- [x] Linked gap-closure step 1 — Construct source-owned cleaned US/JP unit lists and inhabit both
  `NormalizedCleanedUnitsOfficialLinkStructuralObligation` propositions:
  CompCert 3.15's unmodified `link_list` returns the two official cleaned
  targets.  This is a syntactic result, not retail semantics.

- [x] Linked gap-closure step 1 — Prove exact-definition provenance from both actual official targets to
  cleaned/source units.  Check every official-target nonlocal internal-body
  `Evar` and initializer `Init_addrof` occurrence and prove that it resolves
  to a linked symbol.  Prove the bounded execution bridge for one unshadowed
  global `Evar`: under explicit `NamedSymbolCoverage`, matching source/target
  nonlocality, and current `Mem.inject`, construct both `eval_lvalue`
  derivations and the injected name-mapped global pointers.  This is not a
  whole-expression or internal-step simulation.

- [x] Linked gap-closure step 1 — Partition normalized global externals exactly: US `133 EF_external`,
  `75 EF_builtin`, `19 EF_runtime`; JP `132`, `75`, `19`.  Prove global
  external-`Callstate` provenance, classify every actual-target retained and
  reachable external constructor, and prove by exhaustive body recursion
  that both actual official targets contain no direct `Sbuiltin`.

- [x] Linked gap-closure step 1 — Prove CompCert external-call transport under explicit
  `symbols_inject`, `Mem.inject`, and injected-argument hypotheses, including result/memory injection,
  injection growth/separation, `loc_unmapped`/`loc_out_of_reach` guarantees,
  external-`Callstate` lifting, and generic direct-`Sbuiltin` lifting after
  argument-evaluation injection.

- [x] Linked gap-closure step 1 — Define the recursive US `__538` rewrite across types, expressions,
  statements, functions, globals, continuations, and Clight states, with
  identifier/initializer/type algebra.  The official target still selects
  the 8-byte Gfx `__538` and an 8-byte `__540` wrapper, while affected
  viewport sources use 16-byte storage.

- [x] Linked gap-closure step 1 — Prove concrete strong-definition membership, generic relocation-aware
  initialization and relocation-load transport, injected local/temp/
  continuation/state relations, pointer and scalar-operation transport, and
  lockstep-to-initial/final execution composition.  Define the concrete
  Mario/object/controller writable footprints and prove recognized
  builtin/runtime calls preserve them.

- [x] Linked gap-closure step 1 — Check that the concrete whole-AST US
  viewport repair builds successfully, and select exact executable targets:
  that repaired US program and the official cleaned JP link.  Replace the
  impossible original-unit `TargetLinkedProgram` projection gate with this
  selected-target gate while retaining a separate
  `SelectedTargetSourceRefinementObligation`.  This proves construction and
  provenance only, not source-to-selected lockstep or retail semantics.

- [x] Linked gap-closure step 1 — Replace the invalid closed semantics for
  standalone translation units with two honest boundaries.  The inhabited
  `OriginalUnitsHeaderNormalizationStructuralObligation` records source-owned
  cleaning, verbatim strong definitions, identifier/composite coverage,
  normalized-header use, and successful whole linking without interpreting
  cross-unit `EF_external` declarations.  The open
  `WholeLinkedSourceToSelectedTargetRefinementObligation` requires standard
  `ClightLockstepComponents` from that whole link to the selected target,
  anchored at matching initialized null-argument `thread5_game_loop` starts,
  `Kstop`, and an actual first Clight step.  The JP task start and reflexive
  source-to-selected instance are now constructed; repaired-US task
  start/lockstep and all selected-to-retail execution remain open.

- [x] Linked gap-closure step 1 — Prove a generic structural selector
  capstone: under the checked uniqueness/selection hypotheses, every
  definition emitted by `clean_translation_units` is exactly the normalized
  map entry at its identifier.  Concrete US/JP instantiation, complete
  global-definition-map agreement, public-name agreement, and initial-memory
  refinement remain open.

- [x] Linked gap-closure step 1 — Transport one explicit definition receipt
  from any source unit through source-union coverage and a successful cleaned
  link to existence of the identically named linked symbol, then specialize
  the result to the official cleaned JP program.  This is generic one-name
  symbol transport; by itself it does not construct the twelve ordinary-entry
  symbol bindings or prove global/public-map agreement.  The focused JP
  aggregate below now constructs the former separately.

- [x] Linked gap-closure step 2 — Extract ordinary Area-1 node `0x0A`, spin-airborne action, layout,
  symbol, distinct-slot, and synchronized-postcondition facts.

- [x] Linked gap-closure steps 2/3 — Prove that a supplied ordinary Area-1
  memory postcondition plus a no-A input sample yields the live controller
  no-A predicate and a reflexive zero-A suffix.  Given caller-supplied castle
  routing, explicit `warp_level` symbol and internal-body resolution,
  `warp_level` execution, all entry symbol bindings, and the final postcondition,
  compose the two prefixes and pin the controller block at the real return
  state.  The generic theorem constructs none of those premises.  Exact
  symbol/body resolution is separately checked for the official cleaned JP
  program; focused split receipts now establish the corresponding exact lookup
  in the selected viewport-repaired US program.  The twelve-symbol JP
  structural binding is also separately checked below.  Live routing/execution,
  memory contents, the postcondition, and the remaining US bindings remain
  open.

- [x] Linked gap-closure step 3 — Define a parameterized zero-edge relation over actual `Clight.step2`
  states using the live controller `buttonPressed` A bit, without requiring
  A-up.  This relation does not itself establish a clean JP entry.

- [x] Linked gap-closure step 4 — Inventory all 38 JP units for direct coordinate/depth/action/dialog
  writer shapes and state the safe-depth and lifecycle residuals.

- [x] Linked gap-closure step 5 — Classify the selected direct assignment-bearing functions: 33
  `pos[1]`, 215 raw-data-slot-7, 180 raw-data-slot-10, and 15
  `throwMatrix`-LHS functions.

- [x] Linked gap-closure step 6 — Prove named-global storage separation and distinct in-range
  608-byte object-slot non-alias arithmetic at entry.

- [x] Linked gap-closure step 6 — Close the direct-`Sbuiltin` branch: exhaustive official-body recursion
  proves that both US and JP inventories are empty, packaged by
  `official_direct_sbuiltin_frame_boundary_closed`.

- [x] Linked gap-closure step 6 — Prove current-`Mem.inject` transport of an already-valid mapped pointer
  to the translated target offset.

- [x] Linked gap-closure step 6 — Prove current-`Mem.inject` transport of mapped pointer reads and their
  loaded values.

- [x] Linked gap-closure step 6 — Prove current-`Mem.inject` transport of mapped pointer writes and the
  resulting memories.

- [x] Linked gap-closure step 6 — Define the reachable, callsite-sensitive
  unresolved-external boundary: protected cells may depend on the external,
  actual arguments, and pre-memory, and every reachable effect is either
  framed there or carried by an explicit writer/lifecycle refinement.  Prove
  that the legacy declaration-wide frame implies this reachable form and that
  pointwise reachable frames supply the inventory.  This interface theorem
  alone supplies no direct-callee computation, transitive call-graph closure,
  or concrete external frame.  The
  old whole-object-pool declaration-wide frame is an overstrong proof target
  because legitimate omitted helpers can allocate and write object slots.

- [x] Linked gap-closure step 6 — Compute and kernel-check the exact selected
  unresolved direct-callee set of the seven dialog/depth bodies for both US and
  JP.  Translation-unit-local receipts, per-version aggregate inventories, and
  `dialog_depth_finite_inventory_obligation_closed` prove that each set is the
  expected ten names and has length ten.  This is direct-call syntax only;
  path-sensitive reachable call sequences, transitive reachability, argument
  provenance, and every concrete
  external frame-or-writer effect remain open.

- [x] Linked gap-closure step 7 — Compose an assumed entry bound and per-step gap refinement into a
  global `<960` theorem over the parameterized zero-edge relation.

- [x] Linked gap-closure step 7 — Define data-bearing Clight chronologies
  under one fixed observation interface and an exact, projection-independent
  `read_controller_inputs` run boundary.  Authenticate the post-poll clean-entry
  input separately, then require exactly one completed poll per observed
  successor frame.  Gameplay frames follow the exact selected
  `update_mario_button_inputs` body through its matching return and bind
  `MarioState.controller` to `gControllers[0]`; paused/change-area
  administrative frames use a separate poll-only branch with an independently
  refined event.  Both branches preserve the sampled controller values to the
  endpoint, bind `gPlayer1Controller` to `gControllers[0]`, carry a real
  nonempty Clight execution and local `CertifiedStep`, and keep input/event
  cardinality exact.  Prove that a
  supplied chronology yields `ClightFrameRefinementCertificate` and that
  supplied task-entry prefixes yield clean-entry nonvacuity.  No concrete
  observer, projection, chronology, or lower/upper prefix is constructed.

- [x] Linked gap-closure step 5 — Refine the four JP coordinate-lvalue census
  shapes by generated Clight receiver annotation across all 38 units.
  `jp_coordinate_lvalue_receiver_partition_checked` proves that `pos[1]`
  receivers belong to the allowed set `MarioState`, `GraphNodeObject`, or
  `PlayerCameraState`; raw slots 7/10 require `Object`; and `throwMatrix`
  requires `GraphNodeObject`, while retaining the exact 33/215/180/15 function
  totals.  This is static typed-AST coverage; live block identity, pointer
  provenance, reachability, bounds, non-aliasing, external frames, and dynamic
  store coverage remain open.

- [x] Linked gap-closure steps 1/2 — Construct initialized memory for the
  official cleaned JP link.  Twelve resource-bounded unit receipts prove every
  retained initializer is naturally aligned; structural source provenance
  transfers alignment to the official link; and the checked `Init_addrof`
  inventory resolves every relocation symbol.  CompCert's constructive
  initializer theorem then yields
  `jp_official_cleaned_initial_memory_exists`.

- [x] Linked gap-closure steps 1/2 — Resolve the exact generated
  `thread5_game_loop` body in the official cleaned JP global environment,
  construct its initialized null-argument `Kstop` call state, prove the genuine
  `function_entry2` first step, and use identity lockstep to inhabit the JP
  source-to-selected refinement.  The OS runtime handoff, castle/Area-1 prefix,
  selected-to-retail relation, and corresponding repaired-US witnesses remain
  open.

- [x] Linked gap-closure steps 2/3 — Resolve the exact generated `warp_level`
  symbol/body in the official cleaned JP global environment.  This closes only
  the JP resolution premise, and the compiled
  `jp_official_cleaned_ordinary_area1_prefix_fixes_zero_a_boundary` corollary
  instantiates the conditional bridge without a caller-supplied lookup.  Castle
  routing, execution of the body, the entry postcondition, live memory, and
  the remaining US entry bindings remain open.  The corresponding exact US
  `_warp_level` symbol/internal-body lookup is separately checked by
  `USWarpLevelEntryResolution.v` after the split source/normalization/repair
  receipt chain.

- [x] Linked gap-closure steps 2/3 — Construct an `Area1EntryAddresses` witness
  for the official cleaned JP global environment with Mario/entry-warp slots
  `0`/`1` and a `JPArea1EntrySymbolBindings` record for all twelve required
  symbols.  Twelve focused source
  receipts plus `JPArea1EntrySymbolResolution.v` prove
  `jp_official_area1_entry_symbol_structure_closed`: both slots are valid, the
  Mario-state/controller/object-pool storage blocks are pairwise distinct, and
  every pointer cell is separate from those three core storage blocks.  The
  platform receipt uses aggregate public-name coverage and cleaned-link
  transport.  This proves no live memory contents, allocation/layout sizes,
  initializer values, routing, reachability, `warp_level` execution, entry
  postcondition, or execution prefix.

- [x] Linked gap-closure step 1 — Close the selected-target audit transport for
  projections fixed to `VersionJP` and `jp_official_cleaned_slice`.
  `JPArea1SymbolGameInitReceipt.v` now also transports the exact
  `_gPlayer1Controller` definition to an official-link symbol.  In
  `JPSelectedTargetAudit.v`, `jp_selected_target_core_symbols_checked` proves
  symbol existence for all
  five `jp_retail_state_global_identifiers`, and
  `jp_selected_target_audit_transport_checked` packages that result with the
  exact selected-program identity and complete selected-program syntax audit.
  `jp_selected_target_refinement_from_target_clight` then reduces the official
  JP `SelectedTargetClightRefinementObligation` to the generic
  `TargetClightRefinementObligation`.  It does not prove the remaining
  projection/observer/chronology, entry-prefix, selected-to-retail, OS handoff,
  Area-1 route, or live-memory obligations.  The corresponding repaired-US audit
  is closed separately below, without any of those semantic consequences.

- [x] Linked gap-closure step 1 â€” Close the selected-target audit transport for
  projections fixed to `VersionUS` and `us_viewport_repaired_program`.
  `USSelectedTargetAudit.v` proves `us_selected_target_audit_transport_checked`
  from those exact version/program hypotheses.  Its syntax half audits the
  actual successful repaired program for no direct `Sbuiltin`, supported
  external constructors, internal-body `Evar` name resolution, and initializer
  `Init_addrof` name resolution.  Split game-init/object-list receipts prove only
  `find_symbol` existence for the five core identifiers.  This does not prove
  repaired-US initialization, memory shape/content/block correspondence,
  source-to-selected viewport-repair execution lockstep, runtime handoff,
  routing/prefix/chronology, or selected-to-retail semantics.

- [x] Linked gap-closure step 1 — Instantiate the generic checked
  cleaned-definition selector for the concrete US unit list and normalized
  semantic slice.  Every definition emitted by the US cleaner is therefore
  exactly the definition selected by the normalized map.  This is selection
  exactness only; complete ordered global/public maps, memory injection, and
  execution refinement remain open.

- [x] Linked gap-closure step 1 — Instantiate the same checked
  cleaned-definition selector for the concrete JP unit list and normalized
  semantic slice, with the same exact scope and remaining map/memory/execution
  caveats.

- [x] Linked gap-closure steps 2/3 — Resolve the exact generated US
  `_warp_level` symbol/internal body in the selected viewport-repaired program.
  The split source, source-union, normalized, viewport, repair-identity, and
  repair receipts feed `USWarpLevelEntryResolution.v`.  This proves exact
  global-environment lookup only: routing, reachability, execution, the entry
  postcondition, and live memory stay open.

- [x] Linked gap-closure steps 2/3 — Check eight focused fixed-position source
  membership receipts for the selected-US globals not already covered by the
  five-core audit: object-list storage/free-list/pointer, Mario-state pointer,
  platform pointer, warp destination, delayed-warp operation, and spin-warp
  behavior.  These kernel-checked generated-list facts remove source lookup
  from the residual, but do not yet transport the eight names through the
  repaired program or construct `USArea1EntrySymbolBindings`; live contents,
  layout, routing, reachability, and execution remain open.

- [x] Linked gap-closure step 3 — Add the selected viewport-repaired US
  ordinary-entry zero-A boundary bridge.  A supplied US entry postcondition
  now yields the exact controller no-A-edge memory predicate and a reflexive
  `ZeroAEdgeClightReachable` suffix; supplied route and `warp_level` execution
  traces compose to that boundary.  This does not construct the address
  bindings, either trace, controller history, live postcondition, or any
  selected-to-retail refinement.

## Ink, quicksand, and clean-entry reductions

- [x] Prove that arbitrary prefixes already refined to State-only preserve
  the collision Object/Graphics Y gap exactly and therefore cannot create
  the timer-131 midpoint sample from synchronized entry.

- [x] Compute the direct `quicksandDepth` writer inventory over the selected
  generated JP Mario/action/interaction units.

- [x] Prove nonnegative depth for the source-shaped writer relation that
  excludes the late long-jump writer, starting at zero, and couple the
  generated `act_crouch_slide`
  `INPUT_A_PRESSED` guard to the exact `ACT_LONG_JUMP` constructor call.

- [x] Record the exact countermodel to a naive per-frame bound: prepared
  long-jump landing depth is `-2.650000095f`, and 363 unreanchored
  automatic-dialog sink calls reach a zero-base endpoint at least `960` in
  CompCert binary32.

- [x] Correct the floor-sampling boundary.  The updater reads the pre-step
  floor, while `common_landing_action` tests the post-`perform_ground_step`
  floor.  The source-shaped binary32 model gives `-0.5f` at timer 4 and
  `-4.0f` at timer 5 for an ordinary-to-quicksand crossing.  The integer
  schedule proves `240 * 4 = 960`; the 240-step live binary32 recurrence and
  generated-Clight expression/control refinement remain open.

- [x] Prove from bilateral generated AST that
  `ACT_READING_AUTOMATIC_DIALOG` is in the cutscene dispatcher, has no
  recognized direct depth write or State-to-Graphics copy, and is not
  protected by the
  automatic dispatcher's depth reset.  Prove in the finite schedule that an
  open dialog supplied the same depth may stall for any finite frame count.
  Live constructor/helper preservation of the depth cell remains open.

- [x] Identify a stock Area-1 static-mesh candidate across 44 Z units from
  default-floor projected triangle to a shallow-moving-quicksand projected
  triangle, with exact rational drop `300/37 < 100`.  This is a geometric
  candidate, not actual surface-list selection or execution of the four
  binary32 ground quarters.  A separate read-only wall/ceiling scan is not
  formalized by this checked item.

- [x] Execute all four real ground quarters in authenticated US and JP retail
  runs from injected pre-timer-3 and pre-timer-4 fixtures that enter timer-4
  and timer-5 bodies.  Each run performs four
  lower-wall, upper-wall, floor, ceiling, and normal-commit operations;
  walls/ceilings are null and every selected floor is static type 37 with no
  owner.  Correct the old exact endpoint `Z=4900` to binary32 bits
  `0x4599198b` (`4899.19287`) and final Y bits `0xc0fc4011`
  (`-7.88282061`).  The transparent Rocq receipt records this conditional
  observation; clean fixture reachability and linked-Clight trace refinement
  remain open.

- [x] Continue the prepared pre-timer-3 fixture through its immediate real
  successor frame without another injection.  In both US and JP, execute
  four more normal ground commits on static owner-null type-37 floors with
  null walls, ceilings, and `gMarioPlatform`, zero A-edge observations, raw
  endpoint Y/Z `0xc199271e`/`0x459aaf5f`, Graphics Y `0xc183f3eb`, and
  depth `0xc029999a` (`-2.6500001`).  This is a prepared retail receipt, not
  clean reachability or a linked-Clight simulation.

- [x] Check all nine US/JP landing-descriptor frame counts and the complete
  ordinary long-jump source chain.  Prove in the source transition kernel
  that first reaching `ACT_LONG_JUMP` or `ACT_LONG_JUMP_LAND` requires an A
  edge or one of seven explicit forged-state causes.  Whole-program linked
  step classification and exclusion of those causes remain open.

- [x] Prove the separate boundary consequences that prevent the prepared
  state: abstract `CleanPyramidEntry` fixes action `0x1932`; conditional on
  the separately stated concrete pyramid-entry memory postcondition, timer
  and depth are zero.  The ordinary Area-1 entry-memory postcondition fixes
  action `0x1924`, timer zero, and depth `+0.0f`.  Executing either memory
  postcondition from linked clean entry remains open.
  Prove that only the authentic six-frame long-jump descriptor admits a
  timer-4/5 body capable of changing nonnegative depth to negative.

- [x] Census both complete 38-unit generated programs: the sole ordinary
  `ACT_LONG_JUMP` constructor is the `INPUT_A_PRESSED` branch of
  `act_crouch_slide`; the sole `ACT_LONG_JUMP_LAND` producer is
  `act_long_jump`; direct action-field writers embed neither target.  Compose
  this with the source transition/depth kernels to exclude the prepared
  negative state for no-edge/no-forgery traces.

- [x] Audit the bounded forgery surfaces: all nine writable landing
  descriptors and the writable interaction table have no direct generated
  assignment; each descriptor address occurs only in its matching wrapper;
  timer forgery alone cannot make a stock four-frame landing run timer 4/5;
  the indirect landing callback remains input-bit-2 guarded; and any
  CompCert action-cell change requires a same-block byte-overlapping store.
  Compiled flat-memory OOB behavior, live pointer provenance, writable-global
  integrity, indexed render state, and external frames remain open.

- [x] Check the US/JP no-exit-star hitbox, behavior, object-list order, and
  dialog milestones.  Prove in the finite lifecycle model that a fresh
  100-coin star has a no-hitbox clear frame and cannot first become eligible
  until after an intervening Mario update.  Prove the exact arithmetic split:
  post timer 4 re-enters timer 5 and ends at negative `-2.65f`, while post
  timer 5 exits at timer 6 and reaches stationary processing, ending positive
  at `1.85f`.  Prove the finite prepared star orbit settles five below home,
  at `spawnY+245`, with overlap interval `spawnY+85` through `spawnY+295`
  and same-height exclusion.  For the supplied prepared-star and successor
  frame words, prove in the finite 160/50-hitbox arithmetic model that raw
  Mario top remains more than 96 units below the first-hitbox Y and Graphics
  top is also below it.  Live hitbox-field and overlap-routine refinement,
  linked binary32/12k
  lifecycle refinement, a different compatible vertical transport, and an older
  pre-positioned tangible star remain open.

- [x] Prove with CompCert memory semantics that any finite chain of framed
  stores to the Mario action/control prefix or the distinct Area-1 object
  pool preserves the exact `quicksandDepth` word; check seven bilateral
  star-dance/dialog spine bodies are direct nonwriters.  Linked statement
  execution, preprocessing, pointer/alias validity, and external frames
  remain open.

- [x] Prove that untransported dialog stalls retain raw X/Z at the audited
  boundary, whose exact squared distance from the fixed upper warp is
  `96058640 > 34969`.  Check the ordinary idle/walking source shape and exact
  binary32 reset of both negative candidates to `1.6f` for the checked
  stationary updater.  Active-dialog
  platform transport, warp relocation/substitution, collision aliasing, and
  other raw-coordinate writers remain open.

- [x] Check a nonzero live-range arithmetic instance: starting at binary32
  `768.5f`, 381 exact sinks end at `1778.1593017578125f`; conversion yields
  collision integers `768` and `1778`, an exact `1010` gap.  Clean
  installation, negative-depth/action reachability, X/Z preservation, and
  381 unreanchored live calls remain open.

- [x] Reject the apparent fire-particle Mario writer: the render callback
  writes the `prevObj` flame's raw/Graphics position, not Mario's.

- [x] Add hash-gated, read-only-after-bootstrap JP zero-A search schedules
  and record that their maximum observed positive Graphics/Object gap is
  zero.  This is bounded evidence; the externally enabled level-select
  bootstrap and finite schedule are not a clean-entry or exhaustive proof.

- [x] From the existing ordinary-entry memory postcondition, prove exact
  State/Object-raw/Object-Graphics equality for X, Y, and Z, the
  spin-airborne entry action, and live binary32 `quicksandDepth = +0.0f`.
  This is a postcondition consequence; executing clean linked `warp_level`
  to obtain that postcondition remains open.

- [x] Decode all 46 US and JP SSL Area-1 macro entries against the complete
  366-entry generated preset tables.  Check the exact `231 = 46*5+1`
  stream shape, final `30` terminator, nonnegative decoded indices, and
  upper bounds.  Prove that neither those macro entries nor the Area-1
  level-script initializers select `bhvDoor` or `bhvDoorWarp`.

- [x] Prove the direct-static-source conditional door exclusion, then prove
  that its premise is too strong for retail: generated pyramid-top
  callbacks mention ordinary pillar-detector and fragment children absent
  from the direct macro/script relation.  Define the usable transitive
  spawn-closure provenance relation and generic forbidden-behavior lemma.

- [x] Compute the receiver-neutral direct `_action` assignment census over
  all 38 generated JP units: eight bodies, with no direct action-writer body
  also embedding `ACT_LONG_JUMP`.  Recheck that the sole direct ordinary
  long-jump constructor is `act_crouch_slide` under `INPUT_A_PRESSED`.
  Typed receiver, indirect-flow, reachability, and non-alias proofs remain.

- [x] Replace the hundredths-only depth invariant with a handwritten exact
  CompCert/Flocq binary32 candidate relation for sink-visible resets,
  minimum clamps,
  `.25f`/`.5f` increments, `10f`/`25f`/`60f` caps, ordinary landing timers
  `1..3`, paired quicksand-jump subtraction/clamp, death `+5f`, and
  preservation.  From entry `+0.0f`, every such finite/non-overflowing
  trace makes Clight's `depth < 0.0f` comparison false.  This module imports
  no generated writer AST, and both landing timers 4 and 5 are excluded.

- [x] Prove exact CompCert binary32 arithmetic for the newly isolated split
  candidate: an ordinary pre-step sample and quicksand post-step sample
  gives `-0.5f` at timer 4 or `-4.0f` at timer 5.  Also prove the integer
  magnitude fact `240 * 4 = 960`; the 240-step binary32 recurrence remains
  a named obligation.

- [x] Execute the identified Area-1 boundary through all four real ground
  quarter-steps in authenticated US/JP retail fixtures and record the
  corrected endpoint/query trace.  This is conditional instrumentation,
  not a clean-reachable or linked-Clight execution proof.

## JP stale-platform lineage and destination continuation

- [x] Correct the control point: `warp_area` and the true first Area-2
  platform application occur before the first controller poll that observes
  Area 2.  The older poll-boundary fixture therefore drives the second
  application, while the midpoint Area-1 fixture observes the true first
  destination displacement.

- [x] Extract the source-backed fresh-destination census under its explicit
  respawn/capacity premises: `74` loader allocations, no first-pass coin
  children, ten elevator marker balls, hence `84` allocations without a
  saved cap and `85` with one.  Spindel is allocation `64`, or zero-based
  free-list depth `63`; numerical pool slot `60` is not depth `60`.

- [x] Identify the old pre-transition fixture's numerical slot `60` as
  free-list depth `7`, reused by Area-2 macro `#5`.  Its cleared true-first-
  apply payload and later Goomba fields do not refute an early-freed top with
  a different depth.

- [x] Prove the exact timer-131 raised/rotated face arithmetic: reject the old
  home point, distinguish the accepted-but-transient low-side point from the
  capture-preserving midpoint, and prove the midpoint `960`/`1010` gap bounds.

- [x] In the hash-gated injected-boundary JP run, observe the top freed at
  depth zero, 131 teardown pushes, 84 destination allocations, depth 47 at
  first apply, and exact binary32 displacement to
  `(365.5927734375,5500,-1096.8026123046875)`.  Prove the corresponding finite
  LIFO arithmetic and observation-record consistency in Rocq.

- [x] Confirm the true first application at authentic JP instruction
  boundaries: entry `0x802c83f0` at timer 515 has slot 61 inactive at depth 47
  and State/Object/Graphics `(0,5500,256)`; caller return `0x8029cfc8` has the
  displaced State bits while Object/Graphics remain at spawn.  This is retail
  runtime evidence, not linked Clight refinement.

- [x] Prove timer `131` unique in `0..150` for the observed affine
  install/freeze/explosion schedule.  Keep projection of those affine offsets
  from linked execution open.

- [x] Continue the conditional zero-A route through all five hidden-star
  trigger transitions, Act-6 star spawn, exact one-unit target overlap, and
  a newly set Act-6 bit (`00 -> 20`) using B/Z/stick only.

- [x] Against the official cleaned JP linked composite environment, prove
  `sizeof(struct Object) = 608`, slot 61's pool-relative offset is `37088`,
  and the twelve listed platform-payload witness ranges lie within that
  object.  Complete generated-AST extraction of the access set remains open.

- [x] Prove there is exactly one retained cleaned JP `_gObjectPool`
  definition and check it as a writable, nonvolatile `Init_space 145920`
  global after the weak
  incomplete-array declaration is removed, and fix the watched CompCert
  pointer as the selected pool block plus offset `37088`.

- [x] Transport the exact generated JP `v_gObjectPool` through the successful
  official cleaned link, recover its exact definition-map and
  `find_symbol`/`find_var_info` entry, combine it with the constructive JP
  initial memory, and prove `Cur Writable` permission for slot 61's complete
  half-open interval `[37088,37696)`.  This is static initial-memory permission;
  bytes and payload contents, current-memory preservation, the runtime-loaded
  pointer and allocation epoch, allocation/free-list chronology, linked
  execution, and retail refinement remain open.

- [x] Under the observed exact 131-push, 84-pop `NoDup` LIFO chronology,
  prove that no destination allocation selects the watched slot, that it
  survives at depth 47, and that writes confined to allocated slots
  preserve its payload.

- [x] Exclude source-bounded stock State-first selection, fixed-placement
  stock-top co-location, all fourteen fixed non-top stock owners,
  position-preserving post-commit selection, and frozen carry with recursive
  stock pre-apply provenance.

- [x] Validate the nonlocal State-first *outcome* independently of that
  installer exclusion: the injected JP vector
  `(-1862,67314,-902) -> (-1862,1778,-902)` has post-frame evidence
  consistent with first-query live-top selection, and completes the cached
  warp/snap/copy/capture frame,
  and continues through the retained first Area-2 apply to the upper
  trigger.  This proves conditional capability, not a clean pointer/writer
  origin.

- [x] Carry Ink's exact timer-131 State rejection, Graphics retry
  acceptance, retained top-pointer observations, depth-47 first-apply
  observation, and zero-A counts into one explicitly conditional boundary.

- [x] Check both stock upper-warp behavior scripts and native callbacks:
  the warp has no direct X/Y/Z access, write, or native callee.  Check the
  stock pyramid-top behavior and finite binary32 timer `0..150` mirror:
  X stays in `[-2087,-2007]`, Y in `[1536,1879)`, and Z remains `-1023`,
  with timer 131 matching the surface fixture.  Because the live
  Clight-to-mirror and memory-frame refinements remain open, this narrows
  rather than excludes stock self-motion; aliased writes, changed identity,
  relocation, and cloning by other code also remain open.

- [x] Compute the complete US/JP direct `gMarioPlatform` writer, caller,
  address-taking, and initializer-relocation census.  JP has only
  `update_mario_platform`; US additionally has the null-only spawn clear.
  Every source-shaped non-null update store comes from `Surface.object`.
  Existing official-link definition provenance is packaged with the
  census; live control-flow/value-flow, aliased stores, and external stores
  remain semantic obligations before this becomes a reachable-store result.

- [x] Replace the single-sample frozen-carry argument with a temporal stock
  scheduler invariant.  An active frame may move the Object but its final
  query rebinds the pointer at the new sample; a frozen/query-skipping frame
  preserves both the Object sample and pointer; US spawn clears the pointer;
  and JP retention begins at a checked inbound node.  Prove by induction
  that no finite composition of those shapes reaches the fixed upper warp
  with a non-null pre-apply pointer.  Linked projection of every retail
  boundary step to one of these shapes remains open.

- [x] Give the complementary executable pointer-lineage classification.
  US clear plus any number of skips remains null, while JP skips preserve
  but do not manufacture inbound lineage.  Any projected non-null
  upper-warp apply is now classified as a different query/current sample,
  canonical identity outside modeled geometry, noncanonical slot/ghost
  epoch, unclassified owner, or retained inbound transport.  Instantiating
  `UpperWarpPrecollisionApplyProjection` from linked memory remains open.

- [x] Lift the direct `gMarioPlatform` syntax census to the constructed
  official cleaned US and JP slices. Check the visible direct named-writer
  upper bound, the `update_objects` upper bound for retained internal direct
  callers, and absence of direct address-taking. Aliased stores,
  unresolved external effects, indirect effects, and retail execution remain
  open.

- [x] Extract the local JP platform-global dataflow fragments and execute the
  exact four-step `Surface.object -> temporary -> gMarioPlatform` fragment,
  including sequence entry, field capture, skip transition, pointer store,
  and the immediately resulting pointer load. Check the apply function's
  leading global load and prove the corresponding abstract-globalenv
  `Clight.step2` lemma. Reaching the store
  branch, connecting the source fragment to the official body, evaluating a
  live floor owner, specializing to the concrete official global environment
  and symbol blocks, framing the
  cell until the later apply, and executing the guard/displacement tail remain
  open.

- [x] Check the bilateral pre-collision generated-source boundary.  The
  fixed scheduler/collision bodies and 29 listed stock Area-1 surface-family
  bodies per version have no recognized direct Mario XYZ writer or direct
  `set_mario_pos` call; the source receipts identify the platform branch's
  intended State-only XYZ shape.  Assuming separate linked refinements for
  the terrain frame, true platform phase, and collision frame, a
  synchronized State/Object split requires an effective platform apply,
  and that abstract phase cannot create Ink's Object/Graphics gap.
  Stock-list/helper, receiver/non-alias, fresh-child, branch execution, and
  external-call closure remain open.

- [x] Replace the implicit same-position assumption with a two-position
  abstract-sample analysis.  For a caller-supplied observation/classifier,
  split a modeled candidate, canonical identity outside that model,
  different-slot recognized identity, same-slot different ghost epoch,
  and unclassified owner.  Prove that a modeled stock candidate and
  upper-warp sample are unequal, and give an abstract separation witness
  showing the old same-position relation is insufficient.  This proves no
  store, carry, movement, or gameplay trace.

- [x] Compute intraprocedural generated-AST call/guard receipts and prove a
  separate finite schedule model: an interaction/action-selection frame
  has a later final-query call in that model; its query-free transition
  shapes cannot select the action and only abstractly preserve the prior
  result.  A differing final sample fits post-wall State, Graphics retry,
  cached-floor Y snap, or an unclassified post-copy discrepancy.  Linked
  execution-to-model refinement and memory frames remain open.  The
  retry-still-null interaction shape is retained for pointer
  chronology, but the earlier fatal request prevents treating it as a
  successful Area-2 warp under the separately checked latch model.

- [x] Census top/warp static references and all 21 direct
  `Object.collisionData` writer bodies.  Check that the allocator's direct
  assignments to that field are all null, top-created child source does
  not contain the top mesh, and ordinary pose-copy helpers do not copy
  behavior/collision identity.  Successful allocation execution, runtime
  behavior arguments, and receiver reachability remain open.

- [x] Package the observed zero-A continuation that overlaps and collects the
  spawned Act-6 star: `conditional_jp_zero_a_act6_collection_continuation`
  combines the binary32 overlap, initially-clear-to-set Act-6 save-bit
  receipt, and 828-frame no-A-edge projection.  This is conditional on the
  injected timer-131 boundary and does not replace the clean-installer
  obligation.

## Route cuts and downstream geometry

- [x] Authenticate the US/JP upper elevator base, inner-wall, rim,
  surrounding-floor, and chamber-wall triangle inventory, plus the complete
  elevator vertex/bounds receipts.  Separate the moving-relative candidate
  from the conservative absolute-sweep adapter.

- [x] Authenticate the US/JP lower ring triangles `1414..1421`, aperture
  walls `1534..1541`, selected vertex/side/Y receipts, and mesh maximum Y;
  define four conservative closed binary32 target boxes excluding the pole
  shaft.  The historical phrase “above the second pole” is no longer the
  lower cut.

- [x] Prove the normalized legacy soft-bonk subcase remains inside the pole
  aperture, and prove upper/lower conditional first-crossing reductions once
  the concrete construction and all seven writer/support exclusions are
  supplied.  These implications do not inhabit those retail premises.

- [x] Define version-indexed downstream suffix certificates separately from
  optional clean no-A prefixes; require distinct Act-3, all-five-trigger, and
  Act-6-collection suffixes for each concrete cut.

- [x] Check initializer-derived static support receipts beneath Act 3 and all
  five triggers, prove the standing Act-3 sample misses vertically by 75,
  and retain the conditional JP five-trigger/spawn and separate Act-6 pickup
  receipts without treating them as one cut-starting execution.

- [x] Transcribe the two post-gate Act-3 algorithms as ordered Rocq stage
  lists: the upper 100-coin-star/vertical-speed/star-dance route and the lower
  homing-amp ledge clip followed by the Grindel/elevator-misalignment route.
  This checks the itinerary vocabulary,
  not its Clight execution.
