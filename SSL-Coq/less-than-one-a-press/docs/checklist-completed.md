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

- [x] Close the revised Rank-16 finite timing class.  Formalize the exact
  alternating raw-Object return/reset and productive-departure quotient,
  prove that its return-first form permits at most 45 rises in 91 frames, and
  grant a stronger phase-shifted form a productive first frame to obtain the
  sharp 46-rise bound.  Compute exact binary32 Y `1017` from Y `51`, leaving
  774 units to Y `1791`, and record bilateral generated
  collision/non-terrain, PLAYER/PUSHABLE-list, Mario-copy, and Goomba-update
  source-order anchors without claiming a linked execution.  This closes the
  finite top-window timing class without assuming
  that either raw-Object writer is reachable; longer timing, state-machine
  escapes, PU transport, and handoffs remain separate.

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

- [x] Linked gap-closure step 1 — Close the selected-target audit transport for
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

- [x] Close the two normal stock large-Graphics producer branches at the
  generated-source/finite-geometry boundary.  `InkTimer131ProducerClosure.v`
  decodes every US/JP `behavior_data` word targeting `oGraphYOffset`: all 40
  are `SET_FLOAT`, with maximum `+240`, and none can meet the generic `+632`
  retry requirement.  Mario's own script has no offset command, its flag
  command enables bit 8 rather than bit 0, and allocation clears the raw-data
  words.  The only direct full cross-object Graphics copy is coupled to the
  Chuckya/King-Bob-omb anchor children; their parents are absent from the
  audited Area-1 regular, macro, and special selectors and from direct C
  references.  A checked non-stock `+1160` offset still succeeds at
  warp-center X/Z, so this is not a global memory-corruption disproof: linked
  slot identity, behavior dispatch, spawn closure, alias/OOB/external frames,
  and lifecycle preservation remain open.

- [x] Close the ordinary direct-call Mario-tail subbranch bilaterally.
  `InkTimer131MarioTailClosure.v` corrects the flag-slot receipt from
  `asS32[1]` to the generated consumer's `asU32[1]`, inventories exactly 30
  canonical flag writers and 28 graphical-offset writers, and proves that
  the recursively closed direct-call graph from Mario's three behavior
  callbacks reaches none of them.  A union-view-neutral check reaches the
  same result for any literal raw-data view of slots 1 and 21.  The module
  also checks the spawn/current-object source chain and the `OR_INT` handler,
  and proves that Mario's `OR 0x100` command preserves bit 0.  Indirect and
  external calls, aliases, out-of-bounds stores, forged behavior pointers,
  live list/slot identity, and lifetime preservation remain outside this
  source closure.

- [x] Resolve the stock indirect-callback, typed-external-handoff, byte-alias,
  and ordinary pool-eviction subbranches for the timer-131 Mario-tail producer.
  `InkTimer131IndirectAliasClosure.v` checks that the only two indirect sites
  are the landing callback and interaction-handler table, adds every stock
  target to the direct closure, and still finds no flag or graphical-offset
  writer.  It finds no unresolved direct `Object *` handoff in that closure,
  no unresolved direct or builtin `MarioState *` handoff in the generated
  corpus, and no builtin `Object *` handoff.  CompCert memory lemmas reduce any
  changed dangerous cell to an overlapping store in Mario's pool slot, and
  prove that any in-bounds store in another 608-byte slot preserves it.  The
  exact eviction source obtains list 12's first object and forwards that same
  temporary to `unload_object`, while `bhvMario` begins in list 0; consequently
  eviction/reuse is harmless under the explicit live disjoint-list/slot
  projection.  The resolved graph's exact direct `Object.behavior` writer
  intersection is `[create_object]`, and the whole generated corpus has no
  direct address-of for that field.  Live table contents, list integrity,
  Mario's slot epoch, corrupted constructor arguments, global/interior-pointer
  or OOB writes, untyped outside access, and negative-depth/dialog execution
  remain open rather than silently assumed.

- [x] Close ordinary named dispatch-table and constructor mutation for the
  timer-131 producer.  `InkTimer131CorruptionClosure.v` computes that
  `BehaviorCmdTable` and `sInteractionHandlers` are mentioned only by their
  expected stock dispatchers and have no direct assignment or explicit
  address-taking site in either generated corpus.  The same module couples
  the single stable decoded `SpawnInfo.behaviorScript` value to both
  `create_object` and the new object's behavior field.  Its route capstones
  also prove that the checked clean zero-A/no-forgery kernels cannot produce a
  negative dialog seed, and that an arbitrarily amplified but untransported
  dialog remains outside the fixed warp in X/Z.  Live table/list/slot bytes,
  corrupt spawn records, forged/interior pointers, OOB stores, untyped
  externals, and a separately transported negative-dialog construction remain
  explicit rather than being claimed closed.

- [x] Close initialized stock interaction dispatch as a negative-depth seed.
  `NegativeDepthInteractionClosure.v` checks all 29 distinct handlers in US
  and JP, extracts 23 direct action literals, bounds four local selectors,
  follows the Snufit and Bully dynamic helpers, and checks all 18 knockback
  table entries.  Every resulting action is non-long-jump, and the two
  knockback tables have no named generated writer.  This module left linked
  preservation open; the later private-injection/reached-execution tranche
  closes all three tables in successful selected in-bounds Clight runs.

- [x] Audit writable action-table mutation and its route payoff.
  `WritableActionTableClosure.v` combines the bilateral handler and knockback
  source censuses, proves the three tables contain exactly 320 writable bytes,
  and excludes an ordinary named controller mutation producer: controller
  state only selects bounded reads.  It separately proves that one selected
  four-byte knockback cell can encode any action word, including long jump,
  connects that value to the checked action-setter consumer, and identifies
  the signature-compatible coin and pole handler cells.  Thus the ordinary
  controller-edit idea is closed; at this tranche, a concrete valid alias into
  the table block or a reached outside-call write was the exact in-model
  residual later refined by the next item.  OOB/ACE variants remain outside
  the Clight model.

- [x] Eliminate the free-form valid-alias and abstract-outside-call table
  producers.  `WritableActionTableAliasExternalClosure.v` fixes the older
  direct-assignment census's array-lvalue blind spot with an
  occurrence-sensitive checker.  Combined with the compiled whole-corpus
  mention receipts, it finds exactly the two terminal handler-field reads and
  one terminal read from each knockback table in both US and JP, with no table
  occurrence in a store, return, call/builtin handoff, public export, or
  owning-unit initializer relocation.  Its CompCert memory-injection theorems
  prove that a self-injected address cannot target an omitted table block and
  that any abstract external call with private blocks omitted preserves all
  table bytes, cannot return their pointers, and preserves a self-injection
  plus its symbol interface after the call when the ordinary global/volatile
  blocks are valid.  The next whole-game tranche establishes the linked table
  blocks and their initialization validity; the next tranche constructs the
  private injection there and supplies its live-state carrier.  OOB, ACE, DMA,
  and post-undefined-behavior continuations remain outside this result.

- [x] Extend the writable-table alias census to the whole modeled game and
  establish its cross-level lifetime.  `WritableActionTableWholeGameAliases.v`
  shards and checks every one of the 38 US/JP translation units, proving that
  no global initializer retains any of the three table addresses and no unit
  exports them; the existing occurrence receipt then leaves only four terminal
  reads per version.  It transports the three exact interaction-unit
  definitions into both official linked source programs, proves their blocks
  valid after successful initialization, and checks that the ordinary clear,
  load, unload, area-change, and warp bodies never name the tables.  A full
  431-file audit of the pinned decompilation independently finds the names only
  in `interaction.c`.  Therefore an already-achieved post-boot mutation would
  persist into SSL, but no stored in-bounds source alias supplies the first
  write; at that stage the remaining tranches were to construct and carry the
  private self-injection and classify reached steps, both now discharged
  below.

- [x] Construct the writable-table private injection at selected-program
  initialization and prove its compositional live carrier.
  `WritableActionTablePrivateInitialization.v` derives a filtered identity
  injection from successful `Genv.init_mem`: all non-table named globals map to
  themselves, all three resolved valid table blocks are omitted, public symbols
  remain compatible, and the initialized memory injects into itself because no
  initializer contains a table address.  `WritableActionTablePrivateLive.v`
  carries this invariant through self-injected stores and byte copies,
  allocation, freeing, and CompCert abstract calls; the external theorem now
  returns the actual monotone extension of the incoming injection.  It composes
  the byte frames over finite actual `Clight.step2` executions beginning at the
  exact initialized memory and exposes the first unclassified step.  At this
  stage the residue was the concrete `ActionTablePrivateClightStepCoverage`
  proof for reached states; the following completed item records its
  discharge.  OOB, ACE, DMA, and post-undefined-behavior continuations remain
  outside this result.

- [x] Close the reached-step classifier and finite-run writable-table
  preservation theorem.  `WritableActionTableSyntaxBase.v` and 38 cached
  per-unit receipts prove that every internal body in either selected linked
  source obeys the private-table grammar.  The expression, terminal-read,
  control, and function-entry modules prove the individual semantic cases;
  `WritableActionTableClightStepCoverage.v` exhausts the actual
  `Clight.step2` constructors; and
  `WritableActionTableReachedExecution.v` carries the exact initialized
  injection and byte frame through every finite successful selected US/JP
  execution.  No such execution can mutate a table byte or acquire a table
  pointer through a reached outside call.  The proof does not cover invalid or
  out-of-bounds stores, ACE, DMA, or execution after source undefined
  behavior.

- [x] Close the generated defined-producer search for a negative quicksand
  seed.  `ActionDepthAliasCensus.v` now checks all 38 selected units for
  untyped/interior `MarioState *` and `LandingAction *` derivations,
  whole-structure copies, stored or returned pointers, and initializer-held
  aliases; it finds only the intended zero-offset `gMarioState` base alias and
  no retained landing-descriptor address.  The new
  `NegativeDepthDefinedProducerClosure.v` classifies all 18 direct depth-store
  sites per version, resolves the five temporary forms to positive additions,
  and proves that every checked binary32/source writer trace from clean zero
  stays nonnegative unless the no-A/no-forgery/source classification fails.
  It packages the initialized-interaction, immutable-action-table, alias, and
  CompCert-scope results and defines an exact external-call frame over the
  relevant Mario-state, pointer, and descriptor bytes.  The remaining live
  obligations are the reached-step projection and exact effects for genuine
  `EF_external` calls; OOB, ACE, DMA, and post-undefined-behavior execution are
  outside this result.

- [x] Formalize the conditional lower-pole payoff of a future retail table
  mutation.  `Area2HypotheticalPoleLongJump.v` checks the exact bilateral
  pole-handler and knockback words, follows the compatible damage/setter path
  to horizontal speed `24` and vertical speed `30`, and computes a five-frame
  zero-A binary32 clear trajectory from `(0,4020,1331)` into the authenticated
  lower target-air cell.  The normalized Y-`3200` early shot peaks at `3440`
  and misses, while Y `3702` is a checked success threshold.  It also proves
  the known-table timing split: a preinstalled knockback word leaves the stock
  handler intact but is not read by grab/climb/top code, whereas an early pole-
  handler replacement catches the first contact; the pole-top dispatcher is a
  direct switch with no fourth writable table.  Mutation reachability and the
  live retail collision bridge remain explicitly unproved.

- [x] Couple SSL's Mario command to `bhvMario` and lift the dangerous-cell
  frame across arbitrary finite clean traces.  `InkTimer131LiveIdentityClosure.v`
  checks the exact bilateral `INIT_MARIO(..., &bhvMario)` command and the
  command-to-spawn-record, area-load, and constructor forwarding chain.  Its
  CompCert-memory induction proves that any finite sequence of framed stores,
  bounded stores to distinct object slots, bit-0-clear Mario flag stores, and
  zero graphical-offset stores cannot enable the dangerous tail.  In
  particular, list-12 eviction/reuse remains harmless under the explicit live
  list/slot projection.  This is an event-classification theorem: proving that
  every linked retail store belongs to the relation, and excluding table-byte,
  same-slot, forged/interior, OOB, and external violations, remains open.

- [x] Connect the timer-131 clean-store induction to a real CompCert trace.
  `InkTimer131ClightTraceBridge.v` defines exact entry loads for the two tail
  cells, a bounded live-memory path from the list-0 sentinel to Mario's fixed
  active pool slot, fixed Mario/behavior pointers, and an arbitrary list of
  command/behavior/dispatch loads.  It proves that a reachable Clight `star`
  preserves this full invariant when every reached step is a checked safe
  store or supplies the required byte frame, and therefore cannot install the
  dangerous flag/offset pair.  Recognized builtins and runtime functions close
  automatically; each reached unresolved external must supply a
  callsite-sensitive protected-cell frame or an explicit checked writer
  effect.  Legitimate list rewrites need preserve Mario's membership rather
  than every link byte.  Construction of the selected run's entry execution
  and reachable-step classifier remains open and is not claimed by this
  bridge.

- [x] Prove the official initial-cell and generated list-0 entry receipts.
  `InkTimer131EntryExecutionClosure.v` proves from the concrete official JP
  `Genv.init_mem` that both Timer-131-sensitive words are zero in every valid
  object slot.  A bilateral behavior-data census finds `bhvMario` as the only
  generated script selecting list 0; separate receipts check list clearing,
  area-before-Mario loading, all-80-word allocator clearing, constructor
  behavior forwarding, and list insertion.  The module also reduces the
  concrete list-membership endpoint to a single post-spawn head link and
  proves that any dangerous actual Clight trace has a first invariant-breaking
  step.  These facts do not execute `warp_level` or the spawn prefix, prove
  that every pre-Mario constructor uses a checked behavior, or classify that
  first step; those remain the live obligations.

- [x] Define the real Timer-131 clear/load/spawn execution certificate.
  `InkTimer131RealEntryPrefix.v` starts at the accepted level-select
  `clear_objects` call and joins `load_mario_area`, the distinct Area-object and
  Mario `spawn_objects_from_info` calls, `init_mario`, and the final entry state
  with actual CompCert small-step segments.  Every step must carry a safe-store
  or exact protected-cell effect, so any inhabitant is one continuous
  classified run.  Exact slot-67, `bhvMario`, pointer, list-ring, `oFlags=0x100`,
  and zero-offset loads now directly supply the full live invariant, without an
  ordinary-entry premise or a false pre-allocation slot-preservation premise.
  A reverse bridge constructs the classifier from an actual star plus per-step
  coverage.  The exact 85-function clear/load/init family has no literal
  watched-cell writer and leaves three conservative outside sites: object
  unload's source-sound stop, Mario-area load's continuous-bank stop, and
  surface loading's `sqrtf`.  The broader 150-function family which also
  permits a first object update is likewise writer-free and expands to five
  names at eight sites.  The module compiles; the later authenticated receipt
  resolves one branch while a native Clight inhabitant, indirect dispatch, and
  exact effects for reached outside calls remain optional strengthening.

- [x] Execute the phase checkpoints in authentic original-JP machine code.
  The read-only mode-2 probe records `clear_objects`, `load_mario_area`,
  the Area-object and Mario calls to `spawn_objects_from_info`, and `init_mario`
  in order.  Its following snapshot identifies Mario as slot 67, matches the
  MarioState pointer, observes safe flag/offset words, and checks a one-node
  player-list ring.  The runner now requires every exact line and callsite in
  that sequence.  This is level-select MIPS evidence rather than a CompCert
  trace; ordinary castle entry is not required by the accepted route boundary.

- [x] Classify every watched write in that same authenticated entry execution.
  The probe converts ten virtual endpoint ranges to physical write watchpoints
  and records exactly 19 stores in the final timer-347 epoch.  The receipt shows
  clear resetting pointer/list/free metadata; Mario's allocator making the first
  zero flag and graphical-offset writes; spawn/init installing slot 67,
  `bhvMario`, both Mario pointers and the one-node list; and the first indirect
  behavior pass writing exactly `0x100`.  The runner compares every instruction,
  address, source value, phase, and endpoint against a committed 25-line receipt.
  `jp_timer131_authenticated_machine_writes_decode` replays those stores from
  arbitrary prior watched values to the exact endpoint and proves all protected
  overlaps safe.  This is a complete watched-memory classification for the
  authenticated MIPS run; it remains distinct from an IDO-MIPS-to-Clight
  simulation or concrete Clight `EF_external` semantics.

- [x] Exclude the unreachable pre-entry source-sound callsite.
  A second hash-gated receipt binds execute counters to the exact original-JP
  allocator, its exhaustion-only unload call instruction, `unload_object`,
  `stop_sounds_from_source`, and `stop_sounds_in_continuous_banks` addresses.
  From the accepted clear through the endpoint it records 73 allocator hits,
  zero fallback/unload/source-sound hits, and one continuous-bank hit.  Coq
  decodes the relevant `bnez` and three `jal` targets, proves
  `stop_sounds_from_source` is not reached, and proves that any effect
  obligation for that callsite is vacuous.  `sqrtf` remains not excluded by
  this receipt.

- [x] Adopt the authenticated Timer-131 receipt as the entry theorem.
  `jp_timer131_authenticated_receipt_is_accepted_entry` packages the exact
  checkpoint order, distinct Area-object and Mario spawn callsites, slot-67
  arithmetic, both Mario pointers, active `bhvMario` object, one-node player
  list, `oFlags=0x100`, and zero graphical offset into
  `JPInkTimer131AcceptedEntryTheorem`; it also proves that the accepted safe tail
  cannot already be the dangerous retry tail.  `MainTheorem.v` exports this as
  `current_timer131_accepted_machine_entry_boundary`.  By project policy this
  closes the level-select entry obligation without claiming that IDO MIPS is a
  CompCert execution; a native Clight prefix is optional strengthening, and the
  required route proof now begins with post-entry preservation through timer
  131.

- [x] Construct the exact rank-3 platform payload at the binary32 boundary.
  `Area1NonlocalPlatformMirror.v` uses the generated US/JP sine-table entries
  to show that X/Z velocity `(186,122)` followed by a pitch half-turn about
  `(-1862,34041,-902)` maps synchronized upper-warp-centre State
  `(-2048,768,-1024)` to exactly `(-1862,67314,-902)`, the already checked
  signed-16 timer-131 alias.  It fixes the raw face-angle and angular-velocity
  words which give previous pitch `0` and current pitch `-32768`.  The old
  rotation-only starting point is now explicitly proved outside the upper-warp
  radius, so it is no longer mistaken for the collision Object.

- [x] Rule out the exact rank-3 payload in the audited stock installation
  model.  `Area1NonlocalPlatformInstallationClosure.v` proves that every stock
  scheduler trace reaching an upper-warp collision has a null cached platform,
  so the exact payload cannot run.  It also checks that canonical surface
  callbacks have no direct required pitch-velocity store, fresh allocation is
  zero, checked fragment pitches differ, and the modeled top and fragments do
  not have pivot Y `34041`.  Any successful trace classified by the current
  model must contain one of six explicit projection escapes.  Deriving that
  classification from all linked retail executions remains open, so this is a
  stock-model disproof rather than an unconditional whole-ROM theorem.

- [x] Close the named direct-call pitch-writer and integer-forged-alias
  subcases of rank 3.  `Area1Rank3PayloadWriterClosure.v` checks 28 named
  Object pitch-word writers per US/JP selected program, computes a 93-name
  fixed direct-call set from all canonical Area-1 surface-owner callbacks, and
  finds exactly one intersecting writer: `spawn_triangle_break_particles`.
  Its two stock values are already proved unequal to the required `-32768`.
  The receipt also reports exactly six unresolved declarations on that set.
  `PlatformIntegerAliasClosure.v` proves from CompCert `sem_cast` and
  `Mem.storev` that neither integer constructor can become the `Vptr` required
  by a successful store.  Indirect/forged dispatch, valid aliases, object
  lifetime substitution, live owner/scheduler linkage, and exact effects for
  the six declarations remain open.

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

- [x] Close three scoped installer-lineage supports without treating them as
  the installer proof itself.  First, `DefaultArea1StartBoundary.v` pins the
  selected US/JP program, SSL level, engine area index `1`, current
  `gAreaData[1]` pointer, node-`0x0A` entry memory, coherent no-A history, and
  null `gMarioPlatform`; `DefaultArea1StartChronology.v` requires a nonempty
  active run and, for any supplied preapply projection whose abstract seed is
  required to decode from that same start memory, excludes retained JP-inbound
  lineage.  It does not derive the preapply events from the run.  Second,
  `Area1QueryScheduleClosure.v` checks the exact bilateral
  AST chain from `gMarioObject.rawData.asF32[6..8]` through the three query
  temporaries to `find_floor`.  Third, `Area1SurfaceOwnerSyntax.v` checks the
  ordered bilateral dynamic prefix from `gCurrentObject` to `Surface.object`,
  followed later by the unique direct `add_surface(surface, 1)` call with the
  same syntactic surface-temporary identifier, and static-loader flag `0`.
  `Area1SchedulerSurfaceLifecycleSplit.v` later proves that this local
  temporary has zero intervening explicit assignments.  It does not frame the
  pointed-to surface cell through whole-struct/builtin mutation, aliases, or
  externals.  The parent installer item remains open: live linked execution
  must still eliminate or realize (1) a
  different final-query/current-collision sample, (2) a canonical owner outside
  modeled geometry, (3) a recognized owner with a noncanonical slot or ghost
  epoch, and (4) an unclassified dynamic owner.  These receipts do not prove
  Object preservation, pointed-cell preservation, chronology-to-run projection,
  live list/owner integrity, lifecycle provenance, or alias/external frames.

  The split `PlatformUpdateSourceReceipt.v`,
  `USPlatformUpdateRepairReceipt.v`, `JPPlatformUpdateCleanedReceipt.v`, and
  `SelectedPlatformUpdateBodyResolution.v` chain additionally resolves that
  exact generated `update_mario_platform` body in both selected programs.  It
  removes source/body-selection ambiguity without asserting call reachability
  or preservation from the query to the later collision.

- [x] Make the previously implicit local-Object/nonlocal-State mechanism
  search explicit and conditionally exhaustive at its key abstract boundaries.
  `Area1GapApproachCoverage.v` exposes the first State/Object divergence of a
  supplied trace as State-endpoint, Object-endpoint, or joint with a
  synchronized-prefix certificate; classifies each supplied split-to-split
  survival edge as changing neither endpoint, State only, Object only, or both;
  expands a
  completed-query/current-sample mismatch into seven schedule/projection
  routes; and turns terrain, platform, and collision refinement failures into
  data-bearing alternatives.  It also classifies any supplied accepted
  upper-warp collision-cache observation as faithful same-frame/live-owner
  provenance or a data-bearing cache-provenance escape; linked collision-list
  execution must still construct that observation.  `PlatformExternalGapSemantics.v` proves that a
  defined one-store divergence must target one endpoint and that a harmful
  unresolved external must take an explicit writer/lifecycle refinement;
  `PlatformAliasExternalClosure.v` reduces ordinary official alias origins to
  pre-existing, external-produced, integer-fabricated, or out-of-bounds
  semantic escapes.  `Area1SurfaceEpochLifecycle.v` separates the query-owner
  token from the apply-time payload token, classifies four payload fates, and
  supplies an abstract fresh same-slot epoch countermodel; its independent-
  witness theorem places that reuse and the existing different-sample
  post-copy witness in one conjunction without coupling their samples, owner,
  pointer, memory, or timing.  These are
  conditional coverage and mechanism results, not a clean retail trace.  The
  new `Area1PostCopyTailClassification.v` adds a conditional frame-tail
  classifier after a supplied copy.  Its broad result distinguishes complete
  synchronization preservation from a classified residual, which may be only
  a value-preserving retarget, lifecycle, alias/external, or scheduler tag.
  Its stronger result proves that a faithful successful copy followed by a
  supplied tail ending in a State/Object value split contains an actual
  State-only, Object-only, or joint value-changing edge; value-preserving
  residual tags cannot discharge that conclusion.  It does not project a
  linked retail execution into the supplied trace: `SuppliedFrameTail` only
  chains caller-authored snapshots and origin labels, so it establishes no
  source adjacency or execution semantics.
  `Area1PostPlayerTailSource.v` supplies a concrete bilateral source support
  layer: it checks the exact post-PLAYER update-order suffix
  `[5; 4; 2; 6; 8; 12; -1]`, the action-before-copy and
  update/unload/final-query source orders, and a negative direct State/raw-
  Object XYZ writer census for the fixed scheduler/traversal, unload, and
  final-query bodies.  The census reaches only the final query, not the next
  pre-collision boundary, because `update_objects` calls
  `try_print_debug_mario_object_info` afterward.  The suffix is only post-PLAYER, not the entire post-copy
  tail: a separate checked receipt places `spawn_particle` after the copy in
  `bhv_mario_update`, orders `try_do_mario_debug_object_spawn` later in
  `bhvMario`, and finds `spawn_object_relative` in that debug callback;
  traversal can also expose a later PLAYER node.  No guard, later-node
  existence, or callback execution is proved.  A further bilateral receipt
  couples each `sParticleTypes` initializer list exactly to 18 paired behavior
  definitions whose leading words are all `8 << 16` (list 8), and checks the
  local argument flow from the selected table field through `spawn_particle`
  to `spawn_object_at_origin`; it proves no loop/index execution, enabled
  particle flag, successful allocation, visitation, coordinate write, or clean
  reachability.  The module additionally proves
  the generated source/data path from an Area-1 `bhvBreakableBox` root through
  the triangle-spawn helper to list-12 `bhvBreakBoxTriangle`.  This completes
  the bounded syntax support item, not the runtime closure: intra-PLAYER
  particle/debug spawning and later PLAYER nodes, transitive spawn and
  interpreter execution, same-frame visitation, alias/external effects,
  lifecycle/reuse, abnormal callback control flow, the post-query debug
  callback, and next-frame warp paths remain open.  The
  parent remains open until linked execution identifies the first writer,
  schedule route, live surface/pool epoch, free-list choice, payload bytes,
  geometry, and true binary32 apply.

- [x] Close the ordinary named-source duplicate-PLAYER branch and the hidden
  ordinary live-floor-writer branch for Rank 1.  In both US and JP,
  `Area1Rank1ResidualClosure.v` proves that `bhvMario` is the sole generated
  list-0 behavior, its address occurs in one initializer and no internal body,
  and `spawn_objects_from_info` has only `load_area` and `load_mario_area` as
  direct callers.  The same module enumerates every `Surface *` derivation:
  four function sites contain four identity casts and one allocator pool
  addition; there are no whole-surface copies and no typed pointer handoffs to
  unresolved, builtin, or indirect calls.  It also proves that
  `add_surface_to_cell` is the sole `SurfaceNode.surface` writer and that only
  node allocation, partition clear, and insertion write `next`, with no whole
  node copies or hidden typed outside handoffs.  The capstone and assumption
  audit pass.  Live current-object identity, pre-existing/type-punned aliases,
  independently reachable outside effects, surface/object epochs, and the
  continuous collision/query schedule remain open.

- [x] Audit the six remaining Rank-1 owner/PLAYER possibilities and separate
  closures, real survivors, and linked proof gaps.  The bilateral canonical
  owner closure has no direct `gCurrentObject` writer and exactly one indirect
  dispatch helper; its complete stock Tox Box/exclamation-box targets contain
  no such writer.  The exact behavior and list-link writer/constructor census
  closes ordinary duplicate-PLAYER ingress; every list-root writer copies the
  canonical root, `gMarioObject` has only area-spawn and clear writers, and the
  sound-spawner behavior selects list 12.  The finite stock query is null at
  both relevant samples.  A freed, inactive, unreused cached object is a
  genuine bounded and authenticated-JP survivor.  Conversely, the two surface
  pools come from shared-main-pool interior allocations stored through public
  globals, so a private-block self-injection cannot frame them; linked byte-
  range separation and outside effects remain necessary.  JP `sqrtf` is
  independently store-free.  The new capstone and assumption target are
  `Area1Rank1SixResidualAuditBoundary` and
  `area1_rank1_six_residual_audit_boundary_holds`.

- [x] Replace Rank 1's vague shared-main-pool alias gap with an exact live
  range and failed-frame boundary.  The authenticated JP entry records node
  payload `[0x80182B20,0x801905E0)`, surface payload
  `[0x801905F0,0x801AB530)`, the 16-byte intervening header, live left head
  `0x801AB530`, live right head `0x801C0FF0`, and 88,752 free bytes.  Coq
  reconstructs the allocation arithmetic, proves fitting later left/right
  allocations and safe restores preserve the surface epoch, checks the exact
  eleven `main_pool_alloc` callers plus all pool-head/state and surface-global
  uses, and proves that the first failed successful-store frame contains an
  actual same-block byte overlap.  A separate ROM-hash-gated receipt fixes the
  other five direct JP roots at 163 instructions, 29 stores, and 11 direct
  calls; every direct store is outside the surface hull.  The protected effect
  relation frames valid transitive stack/static/object/audio writes and makes
  a retargeted descriptor an explicit failure.  Finally, a frame/insert/clear
  list trace proves that every selected classified live node projects into the
  finite stock floor model.  Connecting each real allocator/store/descriptor/
  insertion/query step to those relations remains open; this completed item
  proves the reduction, not the continuous-execution membership.  The checked
  boundary is `area1_surface_pool_range_separation_boundary_holds`.

- [x] Instantiate Rank 1's allocator, alias, owner, list, outside-call, and
  final-query relations in one continuous authenticated JP frame.  A read-only
  timer-348-to-349 watch records the sole `alloc_only_pool_init` allocation and
  matching `geo_process_root` free: the allocation header begins exactly at
  the protected surface-pool end, its payload remains disjoint, and four exact
  allocator-global writes restore the original head without a hidden rewind.
  Cached and uncached RAM aliases and boundary-overlapping stores are watched.
  All 238 pool writes and 776 dynamic-partition writes are checked surface
  construction or list updates, with no static-prefix or pool-pointer writes.
  Six live `gCurrentObject` owners pair one-for-one with six inserted moving
  triangles; all object rings and both complete surface partitions remain
  intact with exact node coverage.  Only the independently store-free `sqrtf`
  runs among the narrowed outside roots.  The final platform query selects
  stock static surface index 808 exactly once, with null owner and platform.
  The exact receipt, 2,200-instruction ROM gate, reproducible runner, and Coq
  boundary `area1_rank1_live_boundary_checked_boundary_holds` pass.  This
  closes the named escapes in the baseline frame, not every later upper-warp
  frame or controller history.

- [x] Close two ordinary subcases of the rank-1 JP collision/query-mismatch
  proposal, and record the strongest clean pillar prefix without calling it a
  completed route.  `Area1PostCopyObjectWriterClosure.v` computes, over both
  complete 38-unit generated corpora, that the direct receivers designating
  Mario's raw Object and assigning XYZ occur only in `init_mario`,
  `butterfly_calculate_angle`, and `check_instant_warp`; its broader-origin and
  receiver-normalization receipts find no hidden direct spelling.  Once entry
  initialization and the pre-object-update instant-warp phase are excluded,
  the direct-designated case reduces to the butterfly callback.
  `Area1ButterflyStaticOriginClosure.v` proves that SSL Area 1's macro stream,
  regular level-script initializers, and selected special presets
  `{0, 101, 125}` do not select `bhvButterfly`.  This is a stock-selector
  exclusion, not a complete live behavior-provenance theorem.  The first
  module also proves
  `explicit_cached_y_768_only_stock_query_is_null` and the exact-centre
  corollary: preserving collision X/Z while snapping to cached Y=`768`, then
  completing the State-to-Object copy, cannot yield a non-null finite-stock
  platform query.  The main boundary theorem has only the project's standard
  classical/extensionality assumptions; both cached-floor theorems and the
  butterfly selector theorem are closed under the global context.

  A separate hash-gated original-JP controller run, starting after an
  externally enabled level-select entry, reaches the two eastern pyramid-top
  detectors with zero recorded A input: counter `0 -> 1` at timer `800` and
  `1 -> 2` at timer `1109`.  Equivalence to ordinary castle entry is unproved.
  It reaches neither western detector,
  leaves the top at action `0`, never captures it as Mario's platform, and
  samples no positive State/Object/Graphics gap.  Consequently the rank-1
  route remains open on the remaining two detectors and on alias,
  indirect/forged callback, external, retarget/lifecycle, scheduler,
  live-owner, and displaced-sample branches.
  Two subsequent one-run, 8,000-frame zero-A relay schedules reproduced the
  two-pillar checkpoint and pointer-identified southeast/northeast Tweester
  relays, but reflected from the central pyramid and died before the west
  Tweester or western detectors.  Both left the top at action `0` and observed
  no positive gap; they are bounded schedule rejections, not disproofs.

- [x] Close the modeled successful-handler cached-floor branch and reduce the
  audited moving-skipped-query branch.  `Area1InteractionShortCircuitClosure.v`
  checks the bilateral warp table slot, nonfading accepted path, nonzero
  `ACT_DISAPPEARED` return, and loop break.  With its explicit runtime
  projection premises, later handlers do not run and only cached-floor Y can
  change the selection sample.  `Area1CachedFloorSelectionClosure.v` proves
  any same-sample accepted floor is at most Y=`896` and therefore cannot yield
  a non-null finite-stock final query at preserved upper-warp X/Z.  All three
  focused cached-floor audits are closed under the global context.
  `Area1MovingSkippedQueryClosure.v` checks that the audited moving warp paths
  precede a full same-frame query, that delayed-warp source installs a null
  callback for the two query-free frames, and that their checked bodies contain
  no direct Mario-view/platform syntax; its two focused audits pass.  These
  are source/finite-model results conditional on live dispatch,
  receiver, alias/external, floor-owner, and lifecycle linkage, not a retail
  scheduler exhaustiveness proof.

- [x] Construct and audit a genuine cached-floor collision/query sample split.
  `Area1CachedFloorSplitWitness.v` instantiates the accepted source-shaped
  schedule at collision `(-2048,818,-1024)` and final query
  `(-2048,768,-1024)`, proving the exact Y-only delta `(0,-50,0)`.  For the
  actual Y=`818` query, both generated US and JP cell-`(6,7)` floor inventories
  contain face `(498,500,501)`; the finite source-shaped decision computes
  `Area1StaticFloorWouldHit`, and the face height computes to `768`.  The
  general accepted branch preserves X/Z, while any top-capturing split from
  upper-warp contact needs more than `459` units upward and this conditional
  finite-stock query is null.  The aggregate boundary, Y-only theorem, and
  stock-null theorem are closed under the global context.  This is a real
  finite schedule split with no A-input premise, not zero-A reachability or
  linked Clight execution: live traversal/selection, dispatch, receiver,
  alias/external, owner, copy, and lifecycle refinements remain open.

- [x] Tighten the direct scheduler/surface-owner boundary and prove a
  schedule-coupled collision/query split for every modeled non-null stock
  install.  `Area1SchedulerSurfaceLifecycleSplit.v` checks the generated US/JP
  source unions for recognized direct explicit transition-callback assignment/
  call syntax and direct explicit `Surface.object` field assignments.  It
  counts exactly four direct `level_set_transition` occurrences, classifies
  their null/basic-update arguments, finds only the allocator and dynamic
  loader as explicit field-writer bodies, and proves that the loader's local
  surface temporary reaches `add_surface(..., 1)` without an intervening
  assignment.  In the finite scheduler/owner model, one position schedule's
  accepted upper-warp collision and non-null stock query imply a final-query
  event and distinct collision/query samples.  Adding an arbitrary separately
  supplied payload-fate witness does not alter that result; this proves logical
  independence, not trace coupling or ordering.  A separate closed abstract
  inactive, freed, unreused payload survivor confirms that excluding same-slot
  reuse alone does not close stale-payload use.  Whole-struct/builtin mutation,
  aliases, externals, indirect callback targets, live list/owner identity, and
  linked Clight refinement remain open.

- [x] State the ordinary rank-1 bridge no-go without promoting it to retail
  closure.  `Area1Rank1OrdinaryBridgeNoGo.v` keeps five fields explicit: the
  modeled same-frame scheduler, upper-warp collision contact, cached-floor
  selection refinement, the accepted dispatch/sample/alias/external/final-
  receiver runtime projection, and stock surface-owner/list/final-query
  refinement.  With any separately supplied `CachedApplyPayloadFate`, those
  five fields imply a contradiction with top installation because the ordinary
  cached-floor theorem makes the query null; the fate argument is unused, and
  no coupled chronology is proved.  Its aggregate also preserves the concrete
  Y-only/downward/null split receipt and the schedule-coupled theorem that any
  modeled non-null top query needs a distinct sample.  It neither constructs
  the five fields from retail execution nor claims that the cached-floor
  witness is the only possible linked split.

- [x] Make the rank-1 boundary underdetermination explicit.  The default-start
  residual capstone eliminates retained JP inbound lineage and expands a
  supplied completed-query sample difference into seven named approaches.
  The active-preapply wrapper, however, relates that projection to the active
  run only by version and its initial null seed.  The constructive diagnostic
  in `DefaultArea1Rank1BoundaryUnderdetermination.v` shows that this interface
  accepts a fabricated top-owned different-sample query for any nonvacuous JP
  run.  It is not a gameplay witness; it proves a full negative result cannot
  be soundly obtained from the current wrapper without a linked
  run-to-preapply construction.

- [x] Strengthen the authentic JP ROM receipt for the true first apply: decode
  word 18 of `apply_mario_platform_displacement` as a MIPS `jal`, reconstruct
  its target from the instruction field and caller PC, and prove that target is
  exactly `apply_platform_displacement`. This authenticates the observed call
  edge, not clean reachability or the surrounding retail execution.

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

- [x] Execute the finite binary32 upper-elevator action schedules.
  `UpperElevatorQuarterStepClosure.v` checks 32 held-A jump-kick and 40
  B-rollout rising quarter-step queries and all corresponding binary32
  transitions, then checks conservative 64/84-quarter full-return envelopes;
  their later maxima are `135` and `227.5`, still below the strict `231` wall
  cutoff.  It
  also enumerates the six literal quarter-step return values and checks that
  every direct `init_mario` cap-field assignment is non-Wing with a zero timer.
  The old Wing endpoint argument is corrected: the retained-Wing schedule has
  zero-based queries 44 and 45 at `234` and `232`, the only two samples above
  the cutoff, before samples `230` and `228`.  The companion
  `UpperElevatorWingCapTransitionClosure.v` checks the stock node-`0x1E` to
  node-`0x14` area-change call chain, the non-Wing initializer values, and
  SSL's failure to select any initial special-cap case.  Thus normal Wing
  preservation is closed at the defined-source boundary; universal live
  route/receiver and collision-call projection remain open.

- [x] Execute one clean original-JP B-only upper-elevator trajectory.
  `UpperElevatorLiveTraceReceipt.v` packages the pinned read-only replay: 17
  exact descent samples land on the unique live elevator, all 671 Area-2
  floors have that owner, a B speed-kick dive lands, a second B enters forward
  rollout, and the first rollout update selects the elevator's east inner wall
  and resolves Mario to X `411`.  All 20 rollout endpoints remain inside,
  peak at relative Y `220`, and return to the elevator.  The run has zero A,
  Wing, identity, descent, and floor-owner failures.  This is a finite JP
  receipt, not held-A/US/universal controller-history closure.

- [x] Authenticate the US/JP lower ring triangles `1414..1421`, aperture
  walls `1534..1541`, selected vertex/side/Y receipts, and mesh maximum Y;
  define four conservative closed binary32 target boxes excluding the pole
  shaft.  The historical phrase “above the second pole” is no longer the
  lower cut.

- [x] Prove the normalized legacy soft-bonk subcase remains inside the pole
  aperture, and prove upper/lower conditional first-crossing reductions once
  the concrete construction and all seven writer/support exclusions are
  supplied.  These implications do not inhabit those retail premises.

- [x] Remove the legacy integer soft-bonk lemma from the active lower-cut
  certificate and replace it with a conditional Float32 collision-phase
  theorem: an actual target-event frame selects a crossing of the four
  binary32 lower cells, then the validated writer theorem performs the
  complete seven-way ordinary/platform/object/clip/alias/lifecycle/support
  split. Live same-frame timing and all seven exclusions remain open.

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

## CompCert execution-scope boundary

- [x] Separate defined Clight corruption from machine-only corruption.
  `CompCertRouteScope.v` proves from CompCert's actual memory semantics that a
  successful load/store requires readable/writable access and proves that each
  Clight transition into a call state targets a function registered in the
  global environment.  Its checked route table keeps in-bounds aliases, wrong
  logical slots, stale pool data, scheduler/owner/lifecycle behavior, and
  retargets to known functions in scope; unresolved externals require a
  concrete effect; invalid accesses and function targets have no Clight
  successor.

- [x] Record that Clight exclusion is not a retail disproof.  The official
  CompCert documentation confirms that its source semantics stops at undefined
  behavior while generated machine code can continue, and that supported
  target architectures do not include N64 MIPS.  Therefore OOB, ACE,
  post-undefined-behavior MIPS, DMA, interrupt, and self-modifying-code routes
  are classified as outside the current execution model.  They are deferred
  until a retail machine/hardware semantics exists, not declared impossible in
  SM64.

- [x] Apply the boundary to the route atlas.  Ranks 1–3 now distinguish
  defined aliases/identity/scheduler/owner/lifecycle work from reachable
  external-effect refinement and from deferred OOB/ACE/DMA variants.  The
  generic memory family uses the same three-way close-out language, preventing
  future checklists from treating an unmodelled retail exploit as a completed
  Clight impossibility proof.

- [x] Prove the three Timer-131 pre-entry outside-call footprints directly in
  retail JP MIPS.  The hash-gated certificate authenticates eight complete
  ranges containing 332 instructions, scans exactly 42 stores and eight direct
  calls, keeps every relative branch inside its routine, and excludes plain,
  indirect, and branch-and-link escapes.  `sqrtf` is store-free; both sound
  roots and every transitive helper write only to bounded stack slots, sound
  banks, one fixed music mask, or sequence-player-zero state.  The live
  continuous-bank entry SP is `0x80207128`, so its deepest 128-byte stack
  envelope misses the entire object pool.  The source-sound root remains
  independently unreachable in the accepted prefix.  This closes the three
  pre-entry effects without an IDO-to-Clight bridge, while forged control flow,
  ACE, DMA, interrupts, and post-invalid-access execution remain outside this
  targeted machine fragment.

- [x] Classify the accepted JP endpoint through the selected spinning timer
  131 execution.  Read-only CPU watchpoints cover both Mario pointers, his
  slot/list/active/behavior/tail cells, `bhvMario`, and the dispatch table.
  The conditional lifecycle fixture writes only the distinct slot-61 top
  counter, then authentic gameplay reaches action 1 timer 131 after 144
  updates.  Every one of the 144 watched writes is the exact harmless
  `clear_object_collision` halfword at Mario-slot offset `0x76`; identity,
  hashes, `oFlags=0x100`, and zero graphical offset persist.  Exact counters
  cover all three Mario callbacks, allocation/unload/sound calls, both HUD
  print callees, and the two unreached debug-print callsites.  Coq checks the
  receipt, write hash, fixture disjointness, authentic print JAL targets, and
  safe-tail replay.  This completes the selected conditional timeline, not
  the universal all-controller-history or debugger-semantics refinement.

- [x] Extend the Rank-1 live boundary through a real clean four-pillar and
  upper-warp attempt.  Mode 12 independently reaches all four detectors,
  explodes the pyramid top, uses the west jumping box and a B-only rollout,
  enters the upper warp at timers 2807–2808, and loads Area 2 at timer 2830;
  `aPressedFrames`, `aDownFrames`, and `controllerAFrames` are all zero.  The
  ROM-hash-gated read-only audit passes 2,462 consecutive frames, pairs all
  149,578 `find_floor` calls and returns, validates all 426 dynamic returns,
  and observes an ownerless static final platform in every frame.  The top's
  explosion creates six genuine inactive-owner triangles for one frame, but
  none is returned and the next dynamic clear precedes every query.  Coq
  packages the exact finite result in
  `Area1Rank1UpperWarpTraceReceipt.v`.  Universal coverage of every different
  controller history remains open.

## Rank-4 clean warp/top relocation and clone receipt

- [x] Check the canonical pyramid top and node-`0x1E` upper warp throughout a
  successful clean route.  The ROM-hash-gated original-JP audit reuses the
  zero-A four-pillar schedule and scans all 240 object slots on every frame
  from timer 348 through 2809.  All 2,462 frame censuses pass with maximum one
  top behavior, one top collision owner, and one upper warp.

- [x] Check transient moving-collision installation and canonical writes.
  Both MIPS aliases of the top and warp position/identity cells are watched,
  and each actual `load_object_surfaces` call is inspected.  All 2,353
  top-mesh loads use canonical slot 61 inside the bounded stock envelope; the
  warp has zero position, behavior, or collision writes and zero collision
  loads.

- [x] Classify the dead top slot's later reuse.  Slot 61 is reinitialized at
  timers 2712, 2743, and 2775.  Each allocation clears `collisionData` before
  installing a different behavior, all six identity stores are post-retirement,
  and no replacement loads the top mesh.  The reuse is therefore not a
  collision-preserving clone on this run.

- [x] Freeze and formalize the result.  The exact machine receipt lives under
  `instrumentation/jp-rank4-warp-top/`, while
  `Area1Rank4WarpTopTraceReceipt.v` combines its exact counters with the
  generated-source top/warp uniqueness and collision-writer census and the
  continuous zero-A route receipt.  The result is explicitly trace-scoped;
  universal clean reachability and machine-only OOB/ACE/DMA variants remain
  outside this completed item.

## Rank-5/5A clean intra-frame State-split receipt

- [x] Audit every cached-platform apply, collision boundary, Mario copy, and
  post-copy tail on the successful zero-A four-pillar route.  The read-only
  original-JP trace reaches each phase exactly 2,462 times from timer 348
  through 2809, with no phase-order, Mario slot/list/behavior identity, copy
  receiver, return, or State/Object equality failure.

- [x] Close the post-copy writer window on that route.  From every successful
  `copy_mario_state_to_object` return through the remaining Mario callback,
  later PLAYER work, later lists, unloading, final query, between-frame code,
  and the next pre-apply prefix, there are zero protected State or raw-Object
  coordinate writes and zero identity or behavior/dispatch writes.

- [x] Close the pre-collision cached-platform origin on that route.  All 2,462
  global and matching Object platform writes are checked null clears, every
  apply loads null, and the displacement helper is never called.  State,
  Object, and Graphics do not change or receive a write during apply; no
  protected coordinate receives a write from apply return through collision-
  detection return; and State and Object are equal at each checked collision
  entry and return.  The fail-closed decoder reports zero ambiguous watched
  stores.  Timers 2807--2809 at the upper warp have inactive time stop, null
  platform, and three bitwise-equal coordinate views at apply entry.

- [x] Authenticate, freeze, and formalize the receipt.  The new verifier adds
  228 retail instructions for Mario's copy/callback and platform apply to the
  existing 2,200-instruction gate; the exact runner output is frozen under
  `instrumentation/jp-rank5-state-split/`; and
  `Area1Rank5StateSplitTraceReceipt.v` packages separate Rank-5 and Rank-5A
  trace verdicts with the reusable source classifications.  Universal
  all-history coverage and machine-only OOB/ACE/DMA behavior remain open.
