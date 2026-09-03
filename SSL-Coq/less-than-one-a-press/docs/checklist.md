# Verification checklist

This open-action board is organized by decision value rather than research
chronology. Every checkbox below is an outstanding obligation. Checked work is
preserved in the [completed-task archive](checklist-completed.md), where each
entry remains no stronger than its stated caveats.

For a plain-language, family-by-family explanation of every active and retired
route idea, including its current evidence, close-out condition, and overall
counterexample-search rank, see the [no-A route atlas](no-a-route-atlas.md).
Apply the [CompCert execution-scope boundary](compcert-execution-scope.md)
before adding a corruption obligation: defined aliases and known-function
retargets stay on this board, reachable unresolved externals first need exact
effects, and out-of-bounds/ACE/post-UB/DMA cases are deferred until a retail
machine model exists rather than treated as unfinished Clight proofs.

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
  The repaired-US selected-target audit is one newly completed substep; the
  parent remains open because post-boundary execution, memory, chronology, and
  retail-semantic obligations below are not discharged.  The core gameplay
  proof now starts at the explicit `DefaultArea1StartBoundary` in **SSL Area 1
  (the exterior)**.  Reaching that boundary from the OS or castle is a separate
  low-priority investigation.

- [ ] Linked gap-closure step 1 — Complete
  `WholeLinkedSourceToSelectedTargetRefinementObligation` bilaterally: retain
  the checked official-JP source-to-selected identity instance and
  both checked selected-target program/syntax/five-core-symbol audits, then prove
  the remaining task-anchored whole-program lockstep from the official cleaned
  US source to the repaired US target.  The repaired-US audit is conditional on
  `VersionUS` and the exact successful repaired program; its five core checks
  are `find_symbol` existence only.  The original-unit
  cleaning/header-normalization bridge is already closed structurally and no
  longer treats standalone cross-unit `EF_external` calls as closed-program
  semantics.  The generic definition-selection result now has checked
  concrete US and JP instances for every emitted cleaned definition.  Still
  prove the complete concrete global-definition and public-name maps,
  name-based initial/current-state `Mem.inject`, and the initial/final
  whole-program execution refinement.  Neither program construction nor the
  static audits supply repaired-US initialization, memory shape/content/block
  correspondence, source-to-selected viewport-repair execution lockstep, or
  either selected-to-retail semantics.  The checked `thread5_game_loop` start
  remains program/source-refinement evidence; it is no longer the gameplay
  reachability root for the scoped theorem.

- [ ] Linked gap-closure step 2 — Bind linked gameplay to the declared default
  start in SSL Area 1 (the exterior).
  `DefaultArea1StartBoundary` fixes the selected US/JP
  program, node-`0x0A` spin-airborne coordinates `(653,1038,6566)`, the
  symbol-bound ordinary-entry memory postcondition, coherent previous/current
  controller masks with no A edge, and an explicitly null `gMarioPlatform`.
  This is a scope assumption, not a theorem that the castle route reaches the
  boundary.  In particular JP normally retains the predecessor platform
  pointer, so JP nullness is stated explicitly rather than inferred from the
  cold-start initializer.  The remaining core subchecks are to connect this
  boundary memory to the selected-program observer and prove post-boundary
  callsite-sensitive external effects, allocation sizes, and pool/list
  ownership.  Do not spend core-proof compute on the OS handoff, castle route,
  or `warp_level` prefix.

  The official cleaned JP environment has a constructed `Area1EntryAddresses`
  witness with Mario/entry-warp slots `0`/`1` and a complete twelve-symbol
  binding record.  Its valid-slot arithmetic, pairwise separation of
  Mario-state/controller/object-pool storage, and separation of every pointer
  cell from those core storage blocks are checked.  This is structural
  global-environment evidence only: it does not construct a boundary witness
  or prove its reachability.  Allocation/layout interpretation, pool/list
  ownership, the selected-US aggregate binding, and the boundary-to-observer
  projection remain open.  Eight focused selected-US source membership
  receipts are checked, removing generated-list lookup from the remaining US
  blockers.

- [ ] Linked gap-closure step 3 — Connect the declared boundary memory and
  controller address to the fixed observer in the selected and semantically
  refined program.  Both selected-program zero-edge boundary bridges are
  checked; in the scoped proof their route/entry-prefix premises are replaced
  by `DefaultArea1StartBoundary` and its coherent controller-history theorem.
  Exact `warp_level` symbol/body resolution is checked for both the
  official cleaned JP program and the selected viewport-repaired US program,
  but is retained only as source/program evidence for the separate upstream
  reachability investigation.
  The JP twelve-symbol entry-address bundle and its limited structural
  separation are checked; eight remaining selected-US source membership
  receipts are also checked.  Their repaired-program transport and aggregate
  binding, the concrete boundary projection, allocation interpretation, and
  post-boundary execution remain open.

- [ ] Linked gap-closure step 4 — Close the reachable gameplay invariants:

  - action and spawn coverage;
  - flag and depth evolution, including automatic-dialog exclusion or
    reanchoring; and
  - object-slot allocation, reuse, and lifetime chronology.

- [ ] Linked gap-closure step 5 — Close coordinate-writer coverage:

  - connect each reachable call/action case to that partition; and
  - prove live pointer-store coverage for every reachable coordinate write.

  The four retained JP census shapes now have a checked 38-unit source-type
  partition: `pos[1]` belongs to `MarioState`, `GraphNodeObject`, or
  `PlayerCameraState`; raw slots 7/10 belong to `Object`; and `throwMatrix`
  belongs to `GraphNodeObject`.  These remain static AST annotations, not live
  block identity, reachability, alias freedom, or dynamic store counts.

- [ ] Linked gap-closure step 6 — Instantiate those generic results for every
  reachable object access; prove source pointer validity, bounds, harmful-alias
  absence, and classify every reachable unresolved `EF_external` effect as
  either a callsite-sensitive protected-cell frame or a concrete
  writer/lifecycle refinement.  The explicit finite ten-name dialog/depth
  direct-callee set is now checked.  Remaining subchecks are:

  - prove path-sensitive reachable call sequences;
  - close transitive call-graph reachability;
  - prove callsite argument provenance; and
  - inhabit each concrete external frame-or-writer classification.

  The old declaration-wide frame over
  the entire object pool is overstrong: legitimate external object allocation
  must be refined as a writer, not falsely framed away.

- [ ] Linked gap-closure step 7 — Construct the concrete data-bearing frame
  chronology for every projected run ending at the next exact selected
  `read_controller_inputs` boundary.  Each returned chronology must itself
  authenticate its start from `DefaultArea1StartBoundary`.  Prove its projected
  input/event/collision lists exact through one fixed controller-memory observer
  for both lower and upper continuations.  The
  checked interface authenticates the boundary input plus every gameplay or
  administrative poll, follows gameplay input through the exact Mario button
  consumer, and composes those witnesses into the whole-run certificate; it
  does not itself construct the observer, projection, or chronology.  No
  task-entry-to-SSL Area 1 prefix is part of the scoped core obligation.

- [ ] Prove `SelectedTargetSourceRefinementObligation` for the exact checked
  targets and then connect the selected Clight semantics to retail execution.
  The old `TargetLinkedProgram` demand over all original units is not the
  selection gate: incompatible original composite bindings make that common
  `linkorder` requirement impossible.  Target selection now uses the repaired
  US program and official cleaned JP program.  The checked original-unit
  structural link certificate, anchored JP identity lockstep, and JP
  selected-target program/syntax/five-core-symbol audit are complete.  The JP
  capstone reduces its selected-target refinement boundary to the still-open
  generic target refinement obligation; it does not inhabit the concrete
  observer, chronology, boundary projection, or selected-to-retail semantics.
  The repaired-US selected-target audit is also checked conditionally on the
  exact US version/program; it proves fresh syntax/name-resolution facts and
  five core-symbol existence witnesses only.  Repaired-US initialization,
  whole-linked-source viewport-repair execution lockstep, memory
  shape/content/block correspondence, and both selected-to-retail semantics
  remain explicit and open.

- [ ] Define concrete state, input, event, and complete collision-observation
  projections for actual initial-to-final selected-program Clight runs, and
  construct their exact data-bearing frame chronologies.  The fixed observer
  must instantiate the checked exact symbol/pointer binding, preserve
  `buttonDown`/`buttonPressed` from each completed poll to its reported
  endpoint, classify gameplay versus administrative polls, and prove the
  projected boundary/event/collision facts.

- [ ] Prove the post-`DefaultArea1StartBoundary` form of
  `WholeProgramClightRefinementObligation`, and replace or instantiate
  `CleanEntryProjectionNonvacuityObligation` so it requires a run from the
  declared boundary rather than an OS/task/castle prefix.  This remains a
  conditional theorem: do not claim the boundary itself is reachable.

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
  sample inside the finite stock model.  The exact platform capability is now
  complete rather than merely vertical: X/Z velocity `(186,122)` followed by
  the proved pitch half-turn maps synchronized State
  `(-2048,768,-1024)` directly to `(-1862,67314,-902)`.  The earlier
  rotation-only input `(-1862,768,-902)` is proved outside the warp radius and
  already assumed a horizontal split.  `Area1NonlocalPlatformInstallationClosure.v`
  rules out applying the complete payload in every audited stock trace and
  proves that a successful classified trace exposes one of the six named
  projection escapes.  `Area1Rank3PayloadWriterClosure.v` checks all 28 named
  pitch-word writers in each selected program and proves that the closed
  93-function direct-call set of every canonical Area-1 owner reaches only the
  debris writer, whose stock values are not the required half-turn;
  `PlatformIntegerAliasClosure.v` also excludes integer-cast addresses from
  successful CompCert stores.  The remaining direct-set outside declarations
  are exactly the two sound wrappers, two audio operations, camera shake, and
  `sqrtf`; indirect/forged dispatch, valid pre-existing or outside-produced
  pointers, and lifetime substitution remain open.  The proof does not yet
  derive the overall classification from every linked retail frame.  A
  temporal extension now proves the null result
  remains true across arbitrary active-frame movement and exact frozen carries,
  and originally classified any projected non-null survivor into five explicit
  lineage escapes.  The declared null `DefaultArea1StartBoundary` plus the
  same-run memory decoder and finite chronology theorem in
  `DefaultArea1StartChronology.v` show that a supplied preapply projection whose
  seed equals that decoder cannot end in retained JP inbound lineage, reducing
  that abstract residual interface to four.  Its active-run record requires a real
  nonempty `Smallstep.plus`, while its preapply wrapper separately requires the
  abstract seed to decode from that run-start memory; deriving the rest of that
  preapply projection from the run is still open.  Exact bilateral source
  receipts now also pin the
  final query's `gMarioObject.rawData.asF32[6..8]` loads to the three
  `find_floor` arguments and pin the dynamic loader to an ordered
  `gCurrentObject -> Surface.object` prefix followed later by
  `add_surface(surface, 1)` with the same syntactic surface-temporary identifier
  (with static loaders using flag `0`).  The direct-source-union follow-up now
  proves that this local temporary has no intervening explicit assignment; it
  does not frame the pointed-to cell through whole-struct/builtin mutation,
  aliases, or externals.  The checkbox remains open: preserving that Object
  sample to the collision phase and deriving linked writer/non-alias/external-
  frame, pointed-surface-cell, terrain-dispatch, chronology-to-run, live-owner,
  and slot/epoch lifecycle facts from the post-boundary execution are not yet
  proved.  The search space is no longer represented by the four completed-query
  lineage fields alone.  `Area1GapApproachCoverage.v` now proves that a supplied
  trace ending in a gap exposes a first State-endpoint, Object-endpoint, or
  joint divergence together with a synchronized-prefix certificate; expands a
  different query/current sample into pre-geometry State,
  Graphics retry, cached-floor snap, post-copy discrepancy, interaction-writer,
  moving-skipped-frame, or unclassified-projection cases; and makes terrain,
  platform-refinement, and collision-stage failures data-bearing alternatives.
  It also classifies each supplied split-to-split survival step as changing
  neither endpoint, State only, Object only, or both, and packages a sustained
  suffix only from explicit trace-local split-preservation evidence.
  The same module separately classifies a supplied accepted upper-warp
  collision-cache observation as faithful current-frame/live-owner overlap or
  a missed-clear, wrong-receiver/list, stale/wrong-owner, alias, external,
  corruption, or unclassified escape; deriving that observation from linked
  retail collision-list execution remains open.
  An authentic original-JP controller-only run now gives a zero-A prefix,
  after an externally enabled level-select entry, through the two eastern
  pyramid-top detectors: the counter changes `0 -> 1` at timer `800` and
  `1 -> 2` at timer `1109`, with every recorded A counter zero.  Ordinary-
  entry equivalence remains unproved.  It reaches neither western detector,
  leaves the top unstarted, and
  samples no positive State/Object/Graphics gap, so it does not close this
  item.  Two later one-run, 8,000-frame zero-A relay schedules reproduced that
  checkpoint and pointer-identified southeast/northeast Tweester relays, then
  reflected from the central pyramid and died before the west Tweester or
  western detectors; neither started the top or sampled a positive gap.  They
  reject only those bounded schedules.  Mode 12 now closes the route gap: an
  independent authenticated JP schedule touches all four detectors, explodes
  the top, uses a west jumping box and B-only rollout, and enters the upper
  warp with all A counters zero.  The companion continuous audit checks every
  frame from timer 348 through 2809, pairs all 149,578 floor-call entries and
  returns, validates 426 dynamic-floor results, and finds only ownerless
  static final platforms.  The top's six post-deactivation surfaces are real
  for one frame but no query returns them, and the next clear precedes every
  query.  Thus pillar reachability is no longer downstream work; this exact
  successful schedule has no useful split.  `Area1PostCopyObjectWriterClosure.v`
  closes two scoped sample-mismatch
  subbranches: the bilateral direct-designated raw-Mario-Object XYZ census is
  exactly `init_mario`, `butterfly_calculate_angle`, and
  `check_instant_warp`; and, under preserved collision X/Z, exact cached
  Y=`768`, a completed copy, and the finite stock-query relation, the
  cached-floor-only final query is null.  `Area1ButterflyStaticOriginClosure.v`
  further proves that stock Area-1 macro, regular level-script, and selected
  special-preset families do not select the remaining butterfly callback.
  These results do not cover `gCurrentObject`/other aliases, indirect or
  forged callbacks, external stores, retarget/lifecycle effects, abnormal
  control, complete live butterfly provenance, or a displaced live floor
  sample; nor do they couple the two-pillar prefix to top capture.
  `Area1InteractionShortCircuitClosure.v` now pins the bilateral warp-handler
  table slot and the successful nonfading return/break path.  Under explicit
  live-dispatch, receiver, alias/external-frame, and completed-copy premises,
  later handlers cannot run and only cached-floor Y may change the sample.
  `Area1CachedFloorSelectionClosure.v` then generalizes the old exact-Y=`768`
  result: every same-sample floor admitted from upper-warp contact is at most
  Y=`896`, which cannot select any finite modeled stock owner at preserved
  warp X/Z.  Live binary32 `find_floor` refinement and owner/list projection
  remain open.
  `Area1CachedFloorSplitWitness.v` now constructs the concrete source-shaped
  cached-floor schedule rather than assuming the samples equal: collision is
  `(-2048,818,-1024)`, the completed-copy final query is
  `(-2048,768,-1024)`, and the difference is exactly `(0,-50,0)`.  The actual
  Y=`818` query's generated US and JP cell-`(6,7)` inventories both contain
  face `(498,500,501)`; its source-shaped decision is `WouldHit` and its
  horizontal height is `768`.  No A-input premise occurs in the construction,
  but exact zero-A reachability, live traversal/selection, dispatch, receiver,
  alias/external, owner, and lifecycle linkage remain open.  The accepted
  branch preserves X/Z, moves downward, needs more than `459` upward units to
  capture the top, and has a null finite-stock query.  Therefore the immediate
  close-out is to link a *useful* split or eliminate the remaining escapes;
  routing the remaining pillars is downstream and should not be prioritized
  until such an installer survives.
  `Area1SchedulerSurfaceLifecycleSplit.v` now proves two stronger conditional
  reductions around that target.  Its generated-source-union census checks the
  recognized direct explicit transition-callback assignment/call syntax,
  including exactly four direct `level_set_transition` occurrences, and direct
  explicit `Surface.object` field assignments.  The only recognized direct
  non-null owner write copies `gCurrentObject`, and the same surface temporary
  reaches dynamic insertion without reassignment.  In the finite
  scheduler/owner model, every accepted warp frame with a non-null stock query
  contains the final query and requires a query sample distinct from the
  collision sample.  Adding an arbitrary separately supplied lifecycle-fate
  witness does not change that conclusion; it does not prove coupling or trace
  order.  A separate inactive, freed, unreused payload survivor shows that no-
  reuse alone does not close stale-payload use.  These are recognized direct-
  syntax and finite-model results, not whole-struct/builtin mutation coverage,
  alias/external framing, indirect callback resolution, live list/owner
  refinement, or linked execution.
  `Area1Rank1OrdinaryBridgeNoGo.v` packages five explicit premises: same-frame
  scheduler, upper-warp contact, cached-floor selection, accepted
  dispatch/sample/alias/external/final-receiver projection, and stock
  surface-owner/list/final-query refinement.  With all five, the contradiction
  is independent of an arbitrary separately supplied lifecycle fate because
  that argument is unused.  No coupled chronology is proved.  This conditional
  ordinary bridge no-go is not a retail closure and does not establish that the
  known Y-only/downward/null witness is the only retail split.  Mode 12 now
  proves the western pillars and upper warp reachable with zero A, but its
  continuous audit supplies no useful split.  The open work is to derive a
  universal linked invariant or carry the first concrete failure from a
  materially different history as the useful split/installer.
  `Area1PostCopyAliasCallbackClosure.v` closes the direct one-hop designated-
  Mario subcase: the bilateral corpus has nine direct raw-XYZ formal-receiver
  helpers, no one-hop designated-Mario call into them, and the audited
  particle/debug child-copy chains use the fresh child as destination and the
  current/Mario object as source.  Its memory frame proves that a distinct
  valid object slot cannot change Mario's raw load.  Current-node identity,
  allocator freshness, transitive wrappers, indirect/external calls, and
  lifecycle/retarget aliasing remain open.
  `Area1MovingSkippedQueryClosure.v` separately finds no concrete moving
  skipped-query witness in the audited generated normal/basic/object-warp
  shapes: coordinate-moving warp paths precede a full same-frame query, while
  the delayed-warp source installs a null callback for the two query-free
  frames, whose checked bodies have no direct Mario-view/platform syntax.
  Callback-target, external/non-alias, play-mode, and null-object lifecycle
  linkage remain open.
  Finally, `DefaultArea1Rank1ResidualCapstone.v` reduces a supplied default-
  start active preapply to completed-query lineage and expands a supplied
  sample difference into seven named approaches.  The current wrapper still
  does not derive chronology events, samples, or owner identity from its
  `ImportedClightRun`.  `DefaultArea1Rank1BoundaryUnderdetermination.v`
  constructively demonstrates that weakness by admitting a fabricated
  top-query record for any nonvacuous active JP run.  This is a boundary
  diagnostic, not a retail counterexample; a linked run-to-preapply
  construction is now the decisive missing proof interface.
  `PlatformExternalGapSemantics.v` reduces a defined first divergent store to
  one endpoint and forces any harmful unresolved external into its explicit
  writer/lifecycle branch.  `Area1SurfaceEpochLifecycle.v` separately classifies
  apply-time payload fate as live same epoch, inactive/freed same epoch, fresh
  same-slot epoch, or invalid/aliased, and supplies an abstract epoch-4-to-5
  reuse countermodel where State moves while Object remains local.  This is not
  a clean-retail witness.  The leading source-and-trace-supported product is a
  different final-query/current-collision sample with the authenticated JP
  inactive-old-top fate; the observed top remains unreused through the true
  first destination apply.  Fresh same-slot reuse remains a speculative
  abstract fallback, and the independent witnesses do not prove a coupled
  execution.  `Area1PolePushSchedule.v` and `Area1PolePushLinkage.v`
  conditionally reject the concrete stock exterior-palm late-writer idea:
  static Area-1 data ties that palm to `bhvTree`, whose X/Z-only push is in
  POLELIKE before the PLAYER update; a completed, correctly targeted
  State-to-Object copy resynchronizes it.  A survivor must instead expose a
  post-player writer, a skipped/misdirected copy, or another listed escape.
  `Area1PostCopyTailClassification.v` now states that next boundary without
  claiming a linked construction.  Its broad theorem classifies a supplied
  copy-to-precollision tail as synchronization-preserving or as a classified
  residual: a projected-coordinate change, copy failure, endpoint retarget, lifecycle
  change, alias/external effect, or scheduler/unclassified effect.  Such a
  residual is not necessarily data-bearing.  Under a faithful successful copy
  and an actual final State/Object value split, its stronger theorem skips
  every edge that preserves both projected values and extracts a State-only,
  Object-only, or joint value-changing edge.  Linked execution must still
  supply the tail snapshots and their origins, so the parent item remains
  open.  Its `SuppliedFrameTail` is only a caller-authored chain of snapshots
  and origin labels; it proves neither generated-source adjacency nor retail
  execution semantics.  `Area1PostPlayerTailSource.v` narrows that supplied tail against the
  bilateral generated source: the exact numeric suffix after PLAYER is
  `[5; 4; 2; 6; 8; 12; -1]`, but this begins only after the PLAYER traversal
  finishes and is not the whole post-copy tail.  Within `bhv_mario_update`, the
  State-to-Object copy precedes `spawn_particle`; `bhvMario` then names
  `try_do_mario_debug_object_spawn`, whose body calls `spawn_object_relative`;
  and traversal can advance to a later PLAYER node if one exists.
  `Area1PlayerListTailClosure.v` now closes both immediate-child versions of
  the residual: every non-null particle behavior selects list 8, the debug
  callback's exact three behavior operands select lists `[6;4;4]`, and the
  MainTheorem boundary combines this with the existing proof that `bhvMario`
  is the only generated behavior-data script selecting list 0.
  Thus neither immediate child family can add a second PLAYER node.  A node
  that already exists or is created by another callback, pointer forwarding,
  a valid alias or specified outside effect, or list/slot lifecycle failure
  remains; the receipts do not prove the live traversal, guards, allocation
  outcomes, or absence of those other producers.
  `Area1Rank1ResidualClosure.v` now closes the ordinary named-source part of
  that remainder: `bhvMario` occurs in exactly one initializer and no internal
  body, is the only generated list-0 behavior, and the object-info spawning
  routine has only the two area-loading callers.  It also audits the separate
  live-floor-owner residual.  The only owner writes are allocator null and
  `gCurrentObject`; the only floor-list node writers are allocation, clear,
  and insertion; no whole `Surface`/`SurfaceNode` copy or typed handoff to an
  unresolved, builtin, or indirect call exists; and the six non-plain
  pointer operations are identity casts or the two pool-index additions.
  Thus the remaining cases are semantic: runtime pointer forwarding or
  mutation, a wrong live current object, a pre-existing/type-punned alias, an
  outside effect with independent private-block reach, or stale surface/object
  lifetime.  The later live-boundary receipt now executes and closes those
  cases in one baseline frame.  `Area1Rank1UpperWarpTraceReceipt.v` now carries
  the same checks through the complete successful upper-warp attempt; only a
  universal all-history invariant remains open.
  `Area1Rank1SixResidualAudit.v` now resolves that list asymmetrically instead
  of treating all six cases as equally open.  It closes ordinary direct and
  stock-indirect current-object replacement, ordinary PLAYER construction and
  relinking, and alternate modeled stock-floor selection at the upper-warp
  and checked low-Y samples.  It confirms that the inactive/unreused cached
  JP object is a real later carrier.  It also proves that surface storage is
  not private: two `main_pool_alloc` calls return shared-pool subranges through
  public globals, so the private-block external-call proof cannot apply.
  Authenticated JP `sqrtf` is store-free.
  `Area1SurfacePoolRangeSeparation.v` now resolves the vague shared-block
  remainder.  The read-only accepted-entry receipt fixes the two payloads,
  their intervening header, and `left=surfaceEnd=0x801AB530`,
  `right=0x801C0FF0`, with 88,752 bytes free.  Coq reconstructs those ranges,
  proves a live epoch invariant for fitting left/right allocations and safe
  restores, checks all eleven allocator callers and every pool-head/global
  writer/use, and reduces a failed store frame to an actual same-block byte
  overlap.  The five remaining direct JP roots are hash-authenticated over
  163 instructions, 29 stores, and 11 calls; all direct writes miss the pools.
  A classified frame/insert/clear list trace also projects any selected live
  node into the finite stock query.  The new exact timer-348-to-349 JP receipt
  instantiates every relation in one uninterrupted frame: its sole temporary
  allocation begins after the protected pool and restores the head exactly;
  238 protected writes and 776 dynamic-partition writes are safe; cached and
  uncached aliases plus boundary overlaps are watched; all six moving-floor
  owners and every object/surface list remain valid; only store-free `sqrtf`
  is reached; and the real final query selects stock static surface 808 with
  null owner.  The upper-warp extension now passes for 2,462 consecutive
  frames, with zero failed writes, returns, lists, owners, outside
  destinations, or clear ordering checks.  The still-open work is the
  equivalent linked invariant for all materially different reachable
  histories.  Its first failure would be a concrete rewind, overlap,
  retargeted descriptor, returned stale owner, unexpected selected floor, or
  useful positive split.
  Object updating is later followed by unload and
  the final platform query.  A direct-lvalue census finds no State-position or
  raw-Object XYZ assignment in the fixed scheduler/traversal, unload, or
  final-query bodies, but does not census dispatched callbacks and stops at the
  query rather than the next pre-collision boundary: `update_objects` calls
  `try_print_debug_mario_object_info` afterward.  The module
  also identifies a concrete non-root callback
  lead rather than assuming static-root completeness: an Area-1
  `bhvBreakableBox` reaches `obj_explode_and_spawn_coins`, then
  `spawn_triangle_break_particles`, whose requested
  `bhvBreakBoxTriangle` behavior is in list 12 and therefore later than PLAYER
  in the array.  These receipts do not prove successful allocation, same-frame
  visitation, or callback execution.  Closing the remaining pre-existing,
  runtime pointer-forwarded/mutated or lifecycle-created PLAYER-node cases,
  transitive spawn and behavior-
  interpreter dispatch, receiver/non-alias and external-call frames,
  unload/pool-reuse lifecycle, abnormal returns, the post-query debug callback,
  and next-frame warp/instant-warp effects remains part of the universal linked-
  execution item.  The later Rank-5/5A receipt closes these intervals on the
  chosen zero-A four-pillar route, not on every reachable history.
  Linked behavior-list execution and copy identity, coupling, exact payload
  bytes, geometry, and binary32 apply execution remain open.  The complete
  approach inventory and proof/disproof priorities are recorded in
  [`notes/local-object-nonlocal-state-gap-matrix.md`](notes/local-object-nonlocal-state-gap-matrix.md).

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
  are unreachable.  The new Rank-4 receipt closes physical relocation and
  collision-preserving cloning for the authenticated clean zero-A upper-warp
  execution: all 2,353 top-mesh loads use the one canonical top, the one upper
  warp never moves or gains collision, and all three later top-slot reuses
  clear collision before changing behavior.  Universal in-bounds reachability,
  defined aliases, and exact outside effects remain.  This is currently the
  highest-priority counterexample
  tranche because the fixture already validates the destination displacement
  and continuation once a suitable payload is installed; its authentic JP ROM
  receipt now also decodes the observed word-18 `jal` to the exact platform-
  displacement helper.  Completed supporting
  results are preserved under
  [JP stale-platform lineage and destination continuation](checklist-completed.md#jp-stale-platform-lineage-and-destination-continuation).

- [ ] Construct the linked destination-scoped Clight chronology/allocation
  certificate, including pointer block/offset, allocation epoch, memory
  zeroing or preservation, first terrain updates, and proof that the observed
  early-free depth and payload are consumed by the true first apply in linked
  Clight semantics.

- [ ] Extract the 131 pushes and 84 pops from the linked small-step run;
  carry the now-resolved official `_gObjectPool` block and initial
  `[37088,37696)` writable range into the relevant current memory; establish
  the required byte/payload contents and preservation; bind the runtime-loaded
  pointer and ghost epoch; prove terrain/update frame conditions; and execute
  the true first apply's payload loads and binary32 displacement.

- [ ] Prove installer coverage.  Ink's non-null graphical retry is one
  candidate; State-first selection, physical co-location or cloning,
  post-commit transport, another dynamic owner, and a skipped-query frozen
  carry must each be proved unreachable or carried into the same trace.
  Physical co-location/cloning is now absent from one complete clean
  four-pillar/upper-warp trace and has an exact object/collision write watch;
  its remaining obligation is universalization, not another replay of the
  same schedule.

- [ ] Finish the live producer decision for Ink's timer-131 retry.  The new
  `InkTimer131ProducerClosure.v` source/geometry boundary rules out both normal
  large-writer stories: every one of the 40 US/JP behavior commands targeting
  `oGraphYOffset` is `SET_FLOAT` with value at most `+240`, versus the generic
  `+632` minimum, and the only full cross-object Graphics copy is the
  Chuckya/King-Bob-omb anchor chain whose parents are absent from the audited
  stock Area-1 selectors and direct C references.  It also checks allocation
  zeroing, Mario's no-offset/bit-8-only behavior, traversal assignment of
  `gCurrentObject` before `cur_obj_update`, and a non-stock `+1160`
  warp-center retry witness.  `InkTimer131MarioTailClosure.v` now corrects the
  flag check to the unsigned union view, enumerates all 30 direct flag and 28
  direct offset writers bilaterally, follows the closed ordinary direct-call
  graph from all three Mario callbacks, and finds no writer even through an
  alternate literal union view.  It also checks the spawn-to-`gMarioObject`
  and traversal-to-`gCurrentObject` source chain and proves that OR-ing
  `0x100` preserves bit 0.  `InkTimer131IndirectAliasClosure.v` now resolves
  both stock indirect-call families, recomputes the enlarged closed callback
  graph, and finds no flag/offset writer.  No unresolved direct call in that
  graph receives an `Object *`, and no unresolved direct call or builtin in
  the generated corpus receives a `MarioState *`; any successful CompCert
  store changing the dangerous cells must overlap bytes `[140,144)` or
  `[220,224)` in Mario's object slot.  Pool exhaustion is also narrowed:
  `find_unimportant_object` returns list 12 and its result is forwarded
  unchanged to `unload_object`, while `bhvMario` declares list 0; under a live
  disjoint list/slot projection, eviction and reuse of that other slot preserve
  both cells.  The only direct `Object.behavior` writer in the resolved graph
  is `create_object`, and no generated body takes that field's address, so a
  later stock mutation helper is not a surviving forged-behavior source.  What
  remains is semantic rather than geometric: prove the live
  list partition, Mario pointer/slot epoch, and dispatch-table integrity, and
  exclude or realize a corrupted constructor argument, a valid global/interior
  pointer, or a defined alias; give any reachable external an exact effect.
  Out-of-bounds and raw machine continuations are outside this Clight item.
  `InkTimer131CorruptionClosure.v` now removes ordinary named table and
  constructor mutation: the two tables are used only by their expected
  dispatchers and have no direct named writer/address site, while the spawn
  path forwards one stable decoded behavior pointer into creation and the
  object.  `NegativeDepthInteractionClosure.v` now checks all 29 initialized
  interaction handlers in both versions, their 23 direct action literals,
  four local selectors, both dynamic helpers, and all 18 knockback-table
  entries; none installs either long-jump action, and the knockback tables have
  no named generated writer.  `WritableActionTableClosure.v` now proves that
  the three tables occupy 320 writable bytes but have no ordinary named
  controller mutation producer; a one-word knockback change could encode any
  action.  `WritableActionTableAliasExternalClosure.v` now checks every actual
  occurrence as one of four terminal reads per version and proves that neither
  a self-injected store nor a CompCert abstract outside call can be the first
  private-block producer.  `WritableActionTableWholeGameAliases.v` adds the
  missing whole-game history: every modeled initializer/export is clean, the
  linked blocks exist and are initially valid, and ordinary level transitions
  do not name them.  The private injection is now constructed at selected
  initialization and its finite-run carrier is proved; the table branch is
  reduced to classifying the reached live steps, and only the first failed
  classification could reopen a concrete alias.  The negative-quicksand/
  dialog branch therefore still needs a different negative seed if that bridge
  succeeds, and only then raw-X/Z transport to the upper warp.  What remains is live
  list/slot/table/spawn-record preservation plus
  valid forged/interior pointers, defined overlapping writes, concretely
  specified externals, or one coupled negative-seed/transport witness.
  Invalid/OOB variants are deferred to the machine-semantics extension.
  `InkTimer131LiveIdentityClosure.v` now closes the spawn-record source gap more
  tightly: the exact SSL `INIT_MARIO` command contains `&bhvMario`, and the
  command, area-load, and constructor receipts forward one stable value into
  Mario's object.  It also lifts the byte proof from one store to an arbitrary
  finite trace: framed stores, properly bounded distinct-slot stores, safe
  Mario flag writes, and zero graphical-offset writes preserve the safe cells,
  so ordinary list-12 eviction/reuse cannot accumulate a producer.  The open
  step is now to refine every live linked write to that trace or exhibit the
  first same-slot, defined-alias, specified-external, table-byte, or identity
  violation.  An OOB violation would not be a Clight execution witness.
  `InkTimer131ClightTraceBridge.v` now connects that induction to an actual
  reachable CompCert `star`: it represents list-0 membership as a bounded path
  of live `next` pointers, fixes both Mario pointers, the active word, behavior
  pointer, and caller-supplied command/dispatch loads, and preserves all of
  them across classified execution steps.  Recognized builtins/runtime calls
  are automatically memory-silent; each true unresolved external must supply
  the exact protected-byte frame.  The entry values are now supplied by the
  accepted authenticated machine receipt; the remaining work is concrete:
  prove `InkTimer131ReachableStepCoverage` for every reachable post-entry
  internal store, indirect dispatch, and unresolved call through timer 131, or
  return the first step that violates it.
  `InkTimer131EntryExecutionClosure.v` now proves the first entry component in
  official JP initial memory: both watched words are zero in every valid pool
  slot.  It also checks that `bhvMario` is the sole generated list-0 behavior,
  that area loading precedes the Mario spawn, and that the allocator/list and
  behavior-forwarding source chain has the expected shape.  A direct
  post-spawn `list0.next = Mario` load is sufficient for the bounded membership
  predicate.  The trace bridge was corrected so legitimate list-link rewrites
  need only preserve Mario's membership, and unresolved externals now use a
  callsite-sensitive frame-or-writer interface.  A hash-gated, read-only
  original-JP run now executes the actual level-select clear/load/two-spawn/init/
  first-update prefix and observes slot 67, matching State/Mario pointers,
  `bhvMario`, safe tail cells, and the one-node player-list ring.  Physical
  watchpoints produce an exact 19-store receipt for all endpoint identity and
  protected ranges; the harness rejects any missing, extra, reordered, or
  changed watched store.
  `InkTimer131RealEntryPrefix.v` now starts at the accepted level-select
  `clear_objects` boundary, represents the separate Area-object and Mario
  `spawn_objects_from_info` calls, and transcribes the hashed machine receipt
  into checked call-stage and endpoint arithmetic.  Its endpoint record no
  longer assumes an ordinary entry or preserves a not-yet-live slot from
  program initialization: exact CompCert loads for slot 67, the `bhvMario`
  symbol and pointer, both Mario pointers, active state, all four one-node ring
  links, `oFlags=0x100`, and zero graphical offset directly derive the complete
  live invariant.  The machine receipt corrects the phase boundary: allocation
  first zeros both protected words and the first indirect `bhvMario` pass later
  writes `oFlags=0x100`.  Coq replays all 19 stores from arbitrary prior watched
  values to the exact endpoint and proves every protected overlap safe.  A new
  star-to-certificate theorem shows that one actual
  small-step run plus reachable-step coverage constructs the per-step
  certificate.  The exact clear/load/init direct family closes at 85 functions,
  intersects neither literal tail-writer inventory, and leaves exactly three
  conservative outside sites: object unload's source-sound stop, Mario-area
  load's continuous-bank stop, and surface loading's `sqrtf`.  A broader
  150-function family which also permits the first object update remains writer-
  free and expands the boundary to five names at eight sites.  Recognized
  builtins/runtimes are already memory-silent.  An exact dynamic receipt now
  removes one conservative edge: 73 allocator entries occur, but the allocator
  fallback, `unload_object`, and `stop_sounds_from_source` have zero hits, so
  that source-sound site needs no effect specification.  The continuous-bank
  sound call is reached once at stack pointer `0x80207128`; `sqrtf` is not
  excluded by this receipt.  A separate all-path retail-MIPS certificate now
  authenticates all 332 instructions in those roots and their sound helpers,
  finds exactly 42 stores and eight direct calls, excludes indirect/linking
  escapes, proves `sqrtf` store-free, and proves every possible sound-tree
  store misses the entire object pool (including the live stack envelope).
  Thus all three pre-entry outside-call effects are closed without a Clight
  interpretation.  The project now accepts the authenticated receipt as
  `JPInkTimer131AcceptedEntryTheorem`, so the missing
  IDO-MIPS-to-Clight prefix and reconstructed Clight start are optional
  strengthening, not tasks needed to close this route.  Starting at its safe
  endpoint, `InkTimer131PostEntryMachineTrace.v` and two exact JP receipts now
  classify the selected later timelines.  The neutral receipt covers 131
  ordinary updates.  The route-specific receipt separates one slot-61 pillar-
  counter fixture, then reaches the real spinning action timer 131 after 144
  authentic updates: all 144 watched writes are the harmless slot-67 `+0x76`
  collision reset, all three Mario callbacks execute 144 times, Mario's slot,
  list, behavior, command/dispatch hashes, `oFlags=0x100`, and zero offset
  persist, and no unsafe watched write occurs.  This harder interval includes
  93 allocations, 71 unloads, 71 source-sound calls, 864 `print_text` calls,
  and 432 formatted-print calls; the authenticated sound frame and watched
  receipt cover their protected effects, while both debug-specific print
  callsites have zero hits.  What remains is universal rather than a missing
  event in this run: replace the disjoint fixture with the clean pillar path,
  and prove every controller/lifecycle history refines to the same protected
  frame (or prove `InkTimer131ReachableStepCoverage`), plus connect debugger
  watchpoint completeness to machine steps.  Ordinary castle entry is not part
  of this route boundary.

- [ ] Prove the linked stock-provenance projection is exhaustive.  Analyze
  relocated warp/top or collision-preserving clones, post-commit movement
  away from the warp sample, non-stock owners, and skipped queries outside
  the stock provenance relation.  The trace-scoped relocation/clone case is
  now checked continuously through a real upper warp, including transient
  collision loads and retired-slot reuse; prove its invariant for every
  reachable clean history or identify the first different receiver/write.
  Derive Ink's initial three-view gap from
  clean retail execution or prove it unreachable.

- [ ] Prove the platform-global non-alias/external frame invariant; execute
  the upper-warp action-selection frame through the non-null final query;
  project live dynamic
  surface nodes to slot/epoch/behavior/collision provenance; and refine
  every clean coordinate writer to the strict binary32 gap bound.  Also
  instantiate the temporal scheduler and pointer-lineage projections;
  prove the terrain-dispatch and collision XYZ frames plus the real
  platform-phase refinement for every materially different reachable history;
  and eliminate or realize each of the four remaining null-seed lineage cases.
  The successful zero-A four-pillar history is no longer an open instance:
  its 2,462-frame write watch finds no post-copy coordinate/identity event,
  every cached-platform apply loads null, and every collision checkpoint is
  State/raw-Object synchronized at entry and return.  Graphics is unchanged
  during apply, and all three views are equal at the three upper-warp apply
  entries.  A remaining Rank-5/5A counterexample must therefore identify
  the first different-history write, receiver/lifetime failure, or non-null
  owner/payload. The official direct named writer/caller/address
  syntax closure, local JP store/load steps, and exact four-step
  `Surface.object -> temporary -> gMarioPlatform` fragment are complete; the
  linked reachability and preservation work in this item is not. See
  [`notes/linked-platform-lineage.md`](notes/linked-platform-lineage.md) and
  [`notes/rank5-state-split-trace.md`](notes/rank5-state-split-trace.md).

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
  exclude action/timer or input forgery through defined pointer aliases,
  mutable landing descriptors, indirect callback/interaction retargeting, and
  reachable externals with specified effects.  No concrete valid forged writer
  is known; OOB stores are outside this Clight close-out.

- [ ] Starting from `DefaultArea1StartBoundary` and its exact Mario
  raw/Graphics memory equality, prove whole-program writer and action provenance with
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
  `4/5`, mutable-descriptor and defined aliased stores, plus specified external
  effects.  Out-of-bounds producers require a later machine-level model.

- [ ] Project the declared ordinary-entry postcondition into linked Clight,
  close post-boundary external frames and non-aliasing, prove complete live writer/action
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

- [ ] If a future retail-machine/ACE model reopens writable-table mutation,
  inhabit `HypotheticalPoleLongJumpRetailBridge`: place the pole-handler edit
  after the ordinary grab (or supply a separate top-only consumer), derive the
  selected knockback cell and initialized speed-24 long jump, and connect all
  twenty live collision quarters to the checked five-frame clear kernel.  A
  static knockback-only preinstall preserves the grab but is not read at the
  handstand; a static pole-handler replacement prevents the stock first grab.

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
  controller-memory alignment, the stock cap-reset-to-live-receiver link,
  reachable action closure, the upper no-spin entry descent and intended-floor
  landing, every intermediate floor/wall/ceiling query, and collision
  observation alignment.  `UpperElevatorQuarterStepClosure.v` now checks the 32 held-A
  jump-kick and 40 B-rollout rising binary32 quarter-steps and conservative
  64/84-quarter full-return envelopes, whose later maxima are `135` and
  `227.5`, still below the strict `231` cutoff, and enumerates the six literal
  quarter-step return codes.  `UpperElevatorWingCapTransitionClosure.v` now
  proves that the stock Area-1-to-2 source path reinitializes Mario and that
  SSL cannot immediately restore Wing; a hypothetical post-reset Wing state
  has only two above-cutoff queries, `234` and `232`, before falling below at
  `230`.  Still link the decoded route and reset writes to the same live Mario
  receiver, and classify any post-reset cap writer.  The new authenticated JP
  receipt executes one zero-A descent, identifies the live elevator as every
  selected floor owner, lands a B speed-kick dive, observes the rollout hit
  that elevator's east wall at X `411`, and returns to its floor with no Wing;
  held-A, US, alternate launch histories, and every internal query program
  point remain open.  The finite calculations and normalized Z soft-bonk
  subcase are not yet a universal collision-phase theorem.
  For the Ink branch, replace
  the predicate-sensitive `Area1InkWriterCoverageObligation` schema with a
  concrete linked-run writer-coverage relation deriving the route-specific dry
  Graphics-minus-Object bound of at most `45` or the conservative modeled
  relation bound of at most `208` for every reachable writer.

### Negative-quicksand/star installer branch

- [x] Discharge `ActionTablePrivateClightStepCoverage` for the reached states
  of the selected linked execution.  The 38 sharded whole-source syntax
  receipts cover every linked internal body, the four legitimate terminal
  reads are proved to return stock non-table values, function entry preserves
  the private injection, and the exhaustive `Clight.step2` dispatcher covers
  assignments, copies, calls, returns, allocation, freeing, continuations, and
  outside effects.  `WritableActionTableReachedExecution.v` composes these
  facts from the accepted initialized task start through every finite
  successful selected US/JP run, preserving every table byte.  This closes
  in-bounds writable-table mutation in the current CompCert model; OOB, ACE,
  DMA, and post-undefined-behavior execution remain outside it.

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

### Castle-to-SSL Area 1 exploration

- [ ] Separately construct or search for a clean zero-A prefix from the retail
  OS/`thread5_game_loop` and castle painting path to the declared default SSL
  Area 1 boundary (the exterior), at node `0x0A`.  This optional investigation
  includes castle
  routing/glitch discovery, `warp_level` execution, behavior lookup, entry
  allocation, controller predecessor recovery, and—especially for JP—proof
  that the retained predecessor `gMarioPlatform` is null on arrival.  It may
  strengthen the theorem later, but it is not on the core linked-program or
  installer-lineage compute path.

### Turning-Part-2 animation hypothesis

- [ ] Connect converter-produced animation entry 189 and its payload size to
  linked US/JP memory; prove the `0x4000` animation buffer is disjoint from
  MarioState/Object/Graphics coordinates and give `dma_read` the required
  frame rule.

- [ ] Refine the Turning-Part-2 metadata model to actual linked Clight steps
  and classify any same-frame coordinate change through the real
  ground-step/platform or other defined writer path; defer a genuinely
  out-of-bounds machine overwrite until the retail execution model exists.

### Goomba raising and PU transport

- [ ] Construct a linked clean no-A `FullFloatHFRShuttleObligation`,
  `SpindelSameSegmentPUCaptureObligation`,
  `GoombaParallelUniverseTransportObligation`, and
  `RaisedGoombaToSpindelHandoffObligation`; then prove every later
  collision-preserving height handoff and continuation to the second-pole cut.
  Every execution trace must satisfy no A edge at all intermediate frames.
  The separate `PreCollisionRawObjectReturnRaisingObligation` remains useful
  for identifying a concrete writer, but its two-frame repetition is now
  proved too slow for the accepted 91-frame top window even when a productive
  first frame is granted.  A route using it must first establish a longer
  independent interval or a state-machine escape.  Do not infer any remaining
  witness from vertical arithmetic alone.

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
  collision-phase reasoning plus a complete lower-route case split.  The
  current conditional replacement now connects actual target-event frame
  evidence to the binary32 lower cut and the exhaustive seven-way
  writer/support split; live same-frame timing and all seven semantic
  exclusions remain open.

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
