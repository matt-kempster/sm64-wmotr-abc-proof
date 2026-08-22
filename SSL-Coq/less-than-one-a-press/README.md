# Less than one A press in the SSL pyramid

This is the current Rocq/Coq and CompCert Clight project for the following
target:

> Starting from a clean entry into Shifting Sand Land pyramid area 2, neither
> "Inside the Ancient Pyramid" nor "Pyramid Puzzle" can be newly collected in
> an execution with fewer than one A-button press.

The project is intentionally blunt about status: **the ultimate theorem has
not been proved**.  The collection/provenance reduction is proved for the
project's certified event semantics, and syntax-level facts are proved about
the generated Clight ASTs.  A finite writer model now classifies the first
target-bit transition as the matching normal star, an incoherent backup reload,
or an explicit corruption/unmodeled writer.  The target-bit-facing route
theorem now proves that, under route/event alignment, a newly set Act 3 bit
reaches the Act 3 cut and a newly set Act 6 bit reaches the upper-trigger cut.
It blocks both bits only when supplied an evidence-bearing first-cut
classification and unreachability proofs for the six surviving writer
families.  Those older premises are not yet derived from a retail run and,
because their cut descriptor is unrestricted, are not the final sound
first-crossing interface.  The
historical payload-free `FirstTargetCutClassificationObligation` is also
unproved.

### Linked gameplay start boundary

Core gameplay starts at **SSL Area 1 (the exterior)**, at node `0x0A` and
spawn `(653,1038,6566)`, from the assumed
`DefaultArea1StartBoundary`, with exact ordinary-entry memory, coherent no-A
controller history, and `gMarioPlatform = NULL` in both versions.  This does
not prove that an OS/castle prefix reaches the boundary; the optional
castle-to-SSL Area 1 route and possible castle glitches are tracked separately.

Once a supplied pre-apply projection uses the null seed decoded from this
run-start memory, the chronology cannot finish in the retained-JP-inbound case;
the abstract residual interface then has four cases.  Deriving that projection
from the linked run, plus writer/non-alias/external-frame, terrain-dispatch,
live-owner, and lifecycle projections, remains open, so the installer-lineage
item is not complete.

The project generates 38 Clight translation units for each target version.
CompCert 3.15's unmodified `link_list` is proved to fail on both original
complete lists: the first right-associated AST-program failure is the
`ssl_script` join at index 34, and the first composite-definition failure is
the `area` join at index 27.  A deterministic audit finds 402 US and 401 JP
duplicate public variables with unequal generated types.
`NormalizedClightPrograms.v` constructs executable US/JP semantic candidates
by selecting definitions and composites deterministically; those values are
not themselves official CompCert links.  `CleanedClightPrograms.v` separately
constructs source-owned cleaned unit lists, and the kernel-checked theorems
`us_normalized_cleaned_units_official_link_structural` and
`jp_normalized_cleaned_units_official_link_structural` prove that CompCert
3.15's unmodified `link_list` returns the two official cleaned targets.  These
inhabit the US and JP `NormalizedCleanedUnitsOfficialLinkStructuralObligation`
propositions.  This closes only the syntactic program-construction boundary:
original-to-cleaned execution simulation and target-ROM refinement remain
separate, unproved obligations.

The declaration and layout audit now proves that every generated function
declaration has the selected definition's CompCert call ABI, every variable
declaration except `gDisplayListHead` satisfies the exact-or-incomplete-array
rule, and the `gDisplayListHead` pointer declarations have equal checked
storage behavior.  The named residual composite layouts agree.  The one
material US blocker is the anonymous `__538` atom, which aliases a
16-byte/alignment-2 viewport structure in the affected `area` and cutscene
source uses with an 8-byte/alignment-4 graphics-command structure in
`game_init`.  The actual US official target inherits the latter definition, so
its `__540` viewport wrapper is 8 bytes while the source viewport
  wrapper/storage is 16 bytes.  Local fresh-tag layout construction is proved,
  and `USWholeASTTagRepair.v` now defines the recursive rewrite across Clight
  expressions, statements, functions, globals, continuations, and states while
  proving basic identifier/initializer/type algebra.
  `USViewportRepairedProgramCertificate.v` checks that the resulting whole-AST
  program builds.  `SelectedClightTarget.v` therefore selects that exact US
  program and the official cleaned JP link as the two projection targets.  The
  original-unit `TargetLinkedProgram` gate is no longer used: incompatible
  composite bindings make its common-`linkorder` demand impossible.  The
  source boundary now has two deliberately different parts.
  `OriginalUnitsHeaderNormalizationStructuralObligation` is already inhabited
  by the checked source-owned cleaning/link certificate; it makes only the
  structural ownership, verbatim-definition, identifier/composite-coverage,
  normalized-header, and successful-link claims.  Execution starts from that
  whole official cleaned link, never from a standalone translation unit whose
  cross-unit declarations have arbitrary `EF_external` behavior.
  `WholeLinkedSourceToSelectedTargetRefinementObligation` requires a standard
  `ClightLockstepComponents` witness anchored at matching initialized
  `thread5_game_loop` starts.  `SelectedRuntimeTaskStart` pins the null pointer
  argument, `Kstop`, and an actual first Clight step.  JP now has that concrete
  start and an identity source-to-selected lockstep because both sides are the
  official cleaned JP link.  For US this remains the semantic viewport-repair
  obligation; selected-to-retail execution is separate.  The independent
  `USSelectedTargetAudit.v` capstone is now checked for projections fixed to
  `VersionUS` and that exact repaired program.  It packages a fresh actual-target
  syntax audit (no direct `Sbuiltin`, supported external constructors, and name
  resolution for internal-body `Evar` and initializer `Init_addrof` occurrences)
  with `find_symbol` existence for the five US core identifiers.  Symbol existence
  is not memory shape, contents, or block correspondence, and the audit proves no
  source-to-selected execution lockstep.  A composite-table-only repair is
  insufficient.

`ClightLinkExecution.v` specializes exact-definition provenance through the
cleaned units to both actual official targets.  It proves that every nonlocal
internal-body `Evar` and every initializer `Init_addrof` occurrence resolves to
a linked symbol, every retained or reachable global `External` has constructor
`EF_external`, `EF_builtin`, or `EF_runtime`, and neither actual official target
contains a direct `Sbuiltin`.  The normalized/source manifests preserve the
exact external inventories: US `133 EF_external / 75 EF_builtin / 19
EF_runtime` (227 total) and JP `132 / 75 / 19` (226 total).

The file also transports CompCert external calls under explicit
`symbols_inject`, `Mem.inject`, and injected-argument hypotheses.  Its conclusions
include injected result values and memories, injection growth/separation, and
the standard `loc_unmapped`/`loc_out_of_reach` memory guarantees; separate
theorems lift external `Callstate` steps and direct `Sbuiltin` steps after
  argument-evaluation injection.  The new refinement files additionally prove
  strong-definition membership for the concrete US/JP links, generic
  relocation-aware initialization, environment/continuation/state injection,
  pointer load/store/dereference compatibility, scalar-operation injection, and
  lockstep-to-end-to-end composition.  They identify the concrete
  Mario/object/controller footprint and prove full-memory preservation for
  recognized builtins/runtime helpers.  A generic selector theorem now proves
  exact cleaned-definition selection under explicit uniqueness/coverage
  checks, but its concrete US/JP global-map and public-name instances remain
  open.  A separate JP theorem transports one explicit source-definition
  receipt to existence of the identically named official-link symbol.  Twelve
  focused receipts and `JPArea1EntrySymbolResolution.v` now aggregate that
  method into the official-JP `JPArea1EntrySymbolBindings` record for all
  twelve required symbols, with Mario/entry-warp slots `0`/`1`, valid-slot
  arithmetic, pairwise-distinct core storage blocks, and every pointer cell
  separate from core storage.  This is
  structural symbol/block evidence, not live memory contents, allocation or
  layout sizes, initializer values, routing, reachability, or execution.  The
  unresolved-external interface is now callsite-sensitive: each
  reachable effect must frame only its protected cells or enter explicit
  writer/lifecycle refinement.  Nine local/aggregate receipt modules now prove
  the exact US and JP ten-name selected unresolved direct-callee sets for the
  seven dialog/depth bodies.  This closes the finite direct-call inventory, not
  path-sensitive reachable call sequences, transitive reachability, argument
  provenance, or concrete external effects.  The old declaration-wide frame over the complete object
  pool is overstrong because legitimate omitted helpers allocate and write
  object slots.

  The repaired-program audit is intentionally separate from those execution and
  memory layers.  `USViewportRepairDefinitionPreimage.v`,
  `USViewportRepairDefinitionListSyntax.v`, and the focused repaired-program
  syntax/name-transport receipts feed `USRepairedSyntaxAudit.v`; the split
  game-init/object-list receipts establish only existence of the five core
  symbols; and `USSelectedTargetAudit.v` closes
  `SelectedTargetAuditTransportObligation` under exact US version/program
  hypotheses.  Repaired-US initialization, source/refinement and viewport-repair
  execution lockstep, boundary-start chronology, and
  selected-to-retail semantics remain open.

`ClightProjectionChronology.v` adds data-bearing frame chunks under one fixed
observation interface and proves that an exact connected chronology yields the
old whole-run refinement certificate.  Every observed gameplay or
administrative frame executes a nonempty `Smallstep.plus`; silent no-poll
chunks may stutter and emit no input or event.  Every observed input must match
concrete memory loads of previous/current `buttonDown` and computed
`buttonPressed` through the pinned controller and player-one pointer.  Gameplay
frames additionally bind Mario's controller at the exact consumer boundary;
the administrative branch instead carries an independently refined event and
does not claim Mario consumed the sample.  Supplied
nonempty prefixes from the concrete `thread5_game_loop` task boundary likewise
yield clean-entry nonvacuity.  That older composition bridge remains useful to
the separate upstream route.  In the scoped proof, no concrete observer,
projection, chronology, or lower/upper prefix from
`DefaultArea1StartBoundary` has been constructed.

The ordinary Area-1 boundary now has a checked conditional prefix bridge: a
supplied entry postcondition plus no-A sample establishes the live controller
predicate and reflexive zero-A suffix, and supplied castle/`warp_level`
prefixes compose at the real return state after explicit `warp_level` symbol
and internal-body resolution.  `JPWarpLevelEntryResolution.v` now supplies that
exact symbol/body resolution for the official cleaned JP program, while the
split US receipt chain culminating in `USWarpLevelEntryResolution.v` supplies
the exact `_warp_level` symbol/internal-body resolution for the selected
viewport-repaired US program.  The official-JP corollary in
`Area1EntryZeroAPrefix.v` discharges that lookup
premise.  `JPArea1EntrySymbolResolution.v` separately supplies the complete
twelve-symbol official-JP structural binding and its limited separation facts.
Castle routing and live `warp_level` execution remain open only for the
separate upstream reachability investigation.  The core proof assumes the
entry memory/postcondition through `DefaultArea1StartBoundary`; its concrete
observer projection and the remaining US entry-symbol bindings remain open.

The strongest current counterexample candidate is the JP timer-131 stale-top
route.  Exact CompCert binary32 arithmetic rejects the old home-pose Graphics
sample, accepts midpoint `(-1862,1778,-902)`, and proves that midpoint needs a
Graphics/Object Y gap of at least `960` (`1010` at the warp centre).  Given a
debugger-injected three-view Area-1 prestate, the authenticated JP runtime
retains the top's slot through explosion/free and the delayed warp, applies its
payload at the true first Area-2 platform application, and follows a zero-A
controller route through all five Puzzle triggers to Act-6 star spawn.  A
six-B/two-Z continuation closes the former 11-unit gap: the authentic JP trace
overlaps the star by one vertical unit and changes its initially-clear save bit
from `00` to `20`, with no A edge.  This remains conditional on the injected
timer-131 boundary; no clean retail installer has been found.  The Rocq files
prove arithmetic and check finite observation records;
they do not turn the injected emulator trace into a linked Clight execution.

The Area-1 nonlocal-endpoint audit now distinguishes finite signed-32 values
that wrap through `find_floor`'s signed-16 temporary from conversions that fail
before that store.  Rocq checks the full finite vector
`(-1862,67314,-902) -> (-1862,1778,-902)` and proves that the narrowed query is
the accepted timer-131 midpoint.  A hash-gated original-JP fixture now
executes the conditional State-first frame: the candidate State X/Z survive,
`MarioState.floor` has top owner and height `0x44defe16`, and the distinct
Graphics retry point is not copied.  Under the audited source order this is
evidence for first-query success, not direct branch instrumentation.  The
cached warp selects `ACT_DISAPPEARED`, the snap and
copy synchronize State/Object/Graphics, and the final query captures the top.
All A counters are zero.  Rocq additionally checks exact `Cop.sem_cast` values,
the source-shaped high-Y wall rejection, and a transparent trace receipt.
This does not supply a clean predecessor: the fixture injects the split and
arms the top, linked Clight execution remains open, and no clean writer or
route is proved.  A second hash-gated run follows the same State-first fixture
through the top's timer-513 free, the retained depth-47 pointer at the authentic
first Area-2 apply, and upper-trigger consumption at timer 595; the associated
transparent Rocq record again certifies copied data, not execution.  Quiet
NaN, both infinities, `+2^31`,
and the first binary32 value below `-2^31` fail CompCert's word conversion.
US/JP initialization receipts, the stock fault-handler source, and a small
target-prefix model show a terminal trap before a terrain coordinate is
produced.  The adjacent finite signed-word endpoints are checked separately:
`2147483520 -> -128` and `-2147483648 -> 0` after signed-16 narrowing.
Applying the failed-cast exclusion to every retail execution still depends on
`RetailInvalidCastExecutionRefinementObligation` and
`RetailInvalidEnablePreservationObligation`, with handler continuation recorded
by `RetailInvalidTrapContinuationExclusionSchema`; finite signed-16 aliases
remain a real primitive.

`Area1NonlocalPlatformMirror.v` now supplies an exact engine-level payload for
that primitive from the actual synchronized upper-warp centre.  A platform at
`(-1862,34041,-902)` first adds X/Z velocity `(186,122)` to State
`(-2048,768,-1024)`, then changes pitch from `0` to `180` degrees, producing
exactly `(-1862,67314,-902)`.  This corrects the earlier rotation-only receipt,
whose starting X/Z were already separated from the collision Object.
`Area1NonlocalPlatformInstallationClosure.v` then proves that the complete
payload cannot be applied at an upper-warp collision in the audited stock
scheduler/owner model: the cached platform is null before the payload can be
read.  A classified successful installation must therefore expose a named
alias/external, owner, post-query-writer, moving-skip, unchecked-entry, or
unclassified-scheduler escape.  Linking and eliminating those escape classes
for every retail execution remains open, so this is a stock-model disproof,
not an unconditional whole-ROM impossibility theorem.

The current clean-JP installer audit found no retail source for that gap.
`CleanJPGraphicsGap.v` defines a clean JP Area-1 audit boundary, proves that
its synchronized Object/Graphics projection starts with zero separation, that
arbitrarily large prefixes already refined to State-only preserve the
separation exactly, and that a trace made from the currently range-certified
writer forms stays below `960`.
`JPGeneratedWriterCensus.v` preserves all 38 unit boundaries and counts the
functions containing direct assignments to the selected coordinate forms:
33 for `pos[1]`, 215 for raw-data slot 7, 180 for raw-data slot 10, and 15
whose assignment LHS mentions `throwMatrix`.  The checked companion
`JPCoordinateLvalueReceiverPartition.v` refines those shapes across all 38
units: `pos[1]` has receiver type `MarioState`, `GraphNodeObject`, or
`PlayerCameraState`; raw slots 7/10 have `Object`; and `throwMatrix` has
`GraphNodeObject`.  These are static type annotations and function counts, not
proof that every live store targets Mario.  The same census
confirms eight direct `quicksandDepth` writers and six direct automatic-dialog
constructor functions.  `JPQuicksandDepth.v` proves nonnegative depth for a
source-shaped relation that excludes the late long-jump landing writer.  The
newer audit shows why that exclusion is essential: the updater can sample
ordinary floor before `perform_ground_step`, then the landing formula can
sample quicksand after the step.  The exact source-shaped binary32 results are
`-0.5f` at timer 4 and `-4.0f` at timer 5.

The official cleaned JP program now also has a constructive initialized-memory
witness.  Twelve per-unit alignment receipts are aggregated structurally,
  exact source provenance transfers them to the official link, and every
  `Init_addrof` relocation resolves before CompCert's `Genv.init_mem_exists` is
  applied.  `JPThread5EntryResolution.v` and
  `JPSelectedRuntimeTaskStart.v` resolve the exact generated task body, execute
  its null-argument `function_entry2` step, and close the JP
  source-to-selected identity lockstep.  The OS runtime handoff remains outside
  the scoped gameplay proof.  `JPWarpLevelEntryResolution.v` additionally resolves
  the exact `warp_level` symbol/body in the official cleaned JP environment;
  it proves neither castle routing nor execution of that body.  The split
  `USWarpLevel*Receipt.v` chain and `USWarpLevelEntryResolution.v` establish the
  corresponding exact lookup in the selected viewport-repaired US program,
  with the same routing/execution limitation.
`LongJumpProvenanceBoundary.v` checks all nine US/JP landing-descriptor frame
counts, the complete ordinary long-jump source chain, and the writable
six-frame long-jump payload.  Its source transition kernel proves that first
reaching either long-jump action requires an A-edge event or one of seven
explicit forged-state causes.  Refining every clean linked retail step to that
kernel and excluding descriptor/callback corruption, aliasing, out-of-bounds
stores, external mutation, and unclassified writers remain open.

`OrdinaryArea1EntryMemory.v` corrects the ordinary outside-desert entry to
node `0x0A`, `bhvSpinAirborneWarp`, and `ACT_SPAWN_SPIN_AIRBORNE`, and defines
a symbol-bound postcondition in which State, raw Object, and Graphics
coordinates are synchronized.  Its source/layout kernel and consequences from
that postcondition are proved.  The live `Smallstep.star` execution, castle
routing, behavior lookup, external-call frames, and complete object-pool/list
ownership remain obligations; JP also preserves, rather than assumes away,
the predecessor `gMarioPlatform` value.

`Area1EntryDepthClosure.v` derives the full three-axis State/raw/Graphics
equality, spin-airborne action, and binary32 positive-zero depth from that
postcondition.  It also decodes all 46 Area-1 macro entries in each version
against the full 366-entry preset table and proves that neither those entries
nor the Area-1 script selects `bhvDoor` or `bhvDoorWarp`; the exact stream
shape, `30` terminator, and lower/upper preset bounds are checked.  Its
direct-source conditional is deliberately too strong for retail, because the
generated pyramid-top callbacks mention normal child behaviors absent from
the direct lists.  A generic transitive spawn-closure lemma is proved, but the
actual spawn graph, door non-reachability, linked entry execution, and alias
closure remain open.  `JPActionProvenanceCensus.v` adds an exact
38-unit receiver-neutral census of the eight direct `_action` assignment
bodies.  None embeds `ACT_LONG_JUMP`; the only direct ordinary constructor is
still the A-edge-guarded `act_crouch_slide` call.  Indirect value flow and
typed non-aliasing are not proved.  See
[`docs/notes/area1-entry-depth-closure.md`](docs/notes/area1-entry-depth-closure.md).

`JPBinary32DepthWrites.v` proves the corresponding candidate arithmetic
invariant with CompCert/Flocq binary32 rather than unbounded integers.  Its
handwritten sink-visible safe-writer trace starts at exact `+0.0f` and covers
resets, clamps, retail increments/caps, non-long-jump landing timers 1--3,
paired quicksand-jump
subtraction/clamp, and death increments.  Under explicit finite/no-overflow
premises, the exact Clight comparison `depth < 0.0f` remains false.  Mapping
every linked writer to this relation and excluding forged timer 4/5 remain
open.

`JPDestinationChronologyCertificate.v` checks the finite destination side of
the stale-top trace against the official cleaned JP linked layout:
`sizeof(struct Object) = 608`, slot 61 has pool-relative offset `37088`, and
the twelve listed platform-payload witness ranges stay within that slot;
extracting the complete generated access set remains open.  The cleaned census
also proves there is exactly one retained JP `_gObjectPool` definition and
checks it as a writable, nonvolatile 145,920-byte global.  The focused
object-pool chain now transports the exact generated variable through the
official cleaned link, resolves its concrete `find_symbol`/`find_var_info`
block, and proves `Cur Writable` permission in the constructive initial memory
for the whole slot-61 interval `[37088,37696)`.  The watched pointer is the
resolved block plus `37088`.  Given the observed
duplicate-free 131-push/84-pop LIFO chronology, none of the destination
allocations selects the top and it remains at depth 47; allocator writes
confined to selected slots preserve its payload.  The initial-memory theorem
does not establish byte or payload contents, preserve them into current memory,
bind a runtime-loaded pointer or allocation epoch, extract those pushes/pops,
execute the true first apply, or refine the result to retail semantics.
See
[`docs/notes/destination-chronology-certificate.md`](docs/notes/destination-chronology-certificate.md).

`InstallerCoverage.v` proves contradictions for five source-bounded abstract
attempt records: stock State-first selection, fixed stock-top co-location, all
fixed non-top stock
owners, position-preserving post-commit selection, and frozen carry already
inside the stock pre-apply provenance relation.  It carries Ink's timer-131
retry into the existing conditional trace, but it does not prove a clean
installer.  Relocation or cloning, post-commit movement to another query,
non-stock owners, and skipped queries outside the bounded provenance relation
remain open.  See
[`docs/notes/installer-coverage.md`](docs/notes/installer-coverage.md).

`StockWarpTopMotion.v` additionally proves that the generated US/JP stock-warp
native body contains no direct X/Y/Z access or write.  Separately, the stock
top's finite binary32 timer `0..150` mirror stays in
X `[-2087,-2007]`, Y `[1536,1879)`, and fixed Z `-1023`, with timer 131
matching the surface fixture.  The missing live Clight-to-mirror and memory
frame proof means this narrows, but does not exclude, stock self-motion.
Aliased/external writers, changed object identity, relocation by other code,
and cloning also remain open.  See
[`docs/notes/stock-warp-top-motion.md`](docs/notes/stock-warp-top-motion.md).

The stock-projection follow-up corrects the remaining case boundary instead
of claiming that boundary exhaustive.  `StockProjectionExhaustiveness.v`
represents a modeled write-candidate sample separately from the current
collision sample.  For a supplied abstract stock-candidate record at the upper
warp, it proves only that those samples are unequal.  A separation witness
shows why the older same-position relation cannot be assumed complete; it does
not model a store, retention interval, physical movement, or gameplay trace.
The case split is exhaustive only over the supplied abstract observation and
classifier: modeled candidate, canonical identity outside that candidate
relation, different-slot recognized identity, same-slot different ghost
epoch, or unclassified owner.  Constructing these records from every live
retail surface-list state remains open.

The temporal follow-up now removes the old same-position shortcut from the
stock scheduler argument.  `Area1InstallerTemporalClosure.v` allows an active
frame to move the collision Object but requires its final query to rebind the
platform pointer at that new sample; frozen/query-skipping frames preserve both
the sample and pointer; US spawn clears it; and JP retention begins at a
checked inbound node.  No finite trace made from those shapes can arrive at
the fixed upper warp with a non-null pre-apply pointer.
`StateFirstPlatformChronology.v` classifies any projected non-null survivor as
a different query/current sample, out-of-model canonical geometry,
noncanonical slot/epoch identity, an unclassified owner, or retained-inbound
transport.  `Area1PrecollisionWriterClosure.v` separately checks the bilateral
pre-collision source boundary and defines the abstract State-only platform
phase.  Its split classification additionally assumes linked refinements for
the terrain frame, the real platform branch, and the collision frame; under
those premises a synchronized State/Object split requires an effective
State-only platform apply, while that apply cannot create Ink's
Object/Graphics gap.  These are admission-free source/abstract results, not a
linked clean-run projection.  `Area1GapApproachCoverage.v` now fills the
previously missing conditional mechanism census: it exposes the first
State/Object divergence with a synchronized-prefix certificate, expands a
different query/current sample into seven schedule/projection routes while
retaining the source/projection sample equalities, and makes
terrain/platform/collision refinement failures explicit.  It separately
classifies every supplied split-to-split survival edge as changing neither
endpoint, State only, Object only, or both; its sustained-suffix theorem
requires explicit trace-local evidence that every post-creator edge preserves
the split.  The four completed-query lineage fields are therefore no longer
presented as globally exhaustive.  See
[`docs/notes/installer-temporal-closure.md`](docs/notes/installer-temporal-closure.md).

The highest-ranked concrete route has now been narrowed further without being
declared solved.  A hash-gated original-JP controller run, starting after an
externally enabled level-select entry, reaches the two eastern pyramid-top
detectors with no A input: the counter changes `0 -> 1` at timer `800` and
`1 -> 2` at timer `1109`.  Equivalence to ordinary castle entry is unproved.
It does not reach the western
detectors, start the top, capture a platform, use the warp, or create a sampled
positive coordinate-view gap.  On the proof side,
`Area1PostCopyObjectWriterClosure.v` computes the complete bilateral
direct-designated Mario raw-Object XYZ writer census and reduces the ordinary
post-copy case to the butterfly callback after initialization/instant-warp
phase exclusions.  `Area1ButterflyStaticOriginClosure.v` excludes that
callback from the stock Area-1 macro, regular level-script, and selected
special-preset families.  The former module also proves that an explicit
cached-floor snap to Y=`768` with preserved collision X/Z cannot turn the
completed-copy finite-stock platform query non-null, including at the exact
upper-warp centre.  Alias receivers, indirect/forged callbacks, externals,
retarget/lifecycle effects, displaced live floor samples, and the other
sample-divergence branches remain open.

Two later one-run, 8,000-frame zero-A relay schedules reproduced the same
two-pillar checkpoint and pointer-identified southeast/northeast Tweester
relays.  Both reflected from the central pyramid and died before the west
Tweester or either western detector; neither started the top or sampled a
positive gap.  They reject only those bounded controller schedules.

Three additional rank-1 reductions are now checked.  The bilateral accepted
nonfading-warp source path returns a nonzero `ACT_DISAPPEARED` result and
short-circuits later interaction handlers; under explicit live dispatch,
receiver, alias/external-frame, and copy/query premises, only cached-floor Y
can change the sample.  `Area1CachedFloorSelectionClosure.v` proves every
same-sample accepted cached floor is at most Y=`896`, which cannot select any
finite modeled stock Area-1 owner at preserved upper-warp X/Z.
`Area1MovingSkippedQueryClosure.v` finds no moving query skip in the audited
normal/basic/object-warp source shapes: moving warp paths precede a full
same-frame query, while delayed-warp source installs a null callback for the
two query-free frames, whose checked bodies have no direct Mario-view/platform
syntax.  These remain conditional on linked execution and memory framing.

`Area1CachedFloorSplitWitness.v` now proves that this schedule case can really
split the samples inside the source-shaped finite model.  Collision reads
`(-2048,818,-1024)`; `ACT_DISAPPEARED` snaps to cached floor Y=`768`; the
completed copy and final query read `(-2048,768,-1024)`, for exact delta
`(0,-50,0)`.  The generated US and JP cell-`(6,7)` inventories at the actual
Y=`818` query both contain face `(498,500,501)`; its finite floor decision is
`WouldHit` and its horizontal height is `768`.  No A-input premise is needed
to construct the schedule.  That does not prove clean reachability or linked
surface traversal/selection, dispatch, receiver, alias/external, owner, copy,
or lifecycle facts.  The general branch preserves X/Z, this witness moves
downward, top capture needs more than `459` upward units, and the conditional
finite-stock final query is null.  It is therefore a real but non-useful split,
not the missing top installer.

`Area1SchedulerSurfaceLifecycleSplit.v` tightens the surrounding scheduler,
owner, and lifetime boundary.  Across the generated US/JP source unions, it
checks the recognized direct explicit transition-callback assignment/call
syntax, including exactly four direct `level_set_transition` occurrences, and
the direct explicit `Surface.object` field assignments.  The only recognized
direct non-null owner write copies `gCurrentObject`, and the same local surface
temporary reaches dynamic list insertion without being reassigned.  In the
finite scheduler/owner model, any accepted warp frame whose final stock query
installs a non-null owner contains that final query and must query a position
distinct from the collision position.  That conclusion is logically
independent of an arbitrary separately supplied lifecycle-fate witness; it
does not couple or order the two.  A separate inactive, freed, unreused payload
survivor shows that excluding slot reuse alone still leaves a downstream stale-
payload mechanism.  The census does not cover whole-struct or builtin surface
mutation, alias/external stores, indirect-callback resolution, live list/owner
proof, or linked Clight execution.

`Area1Rank1OrdinaryBridgeNoGo.v` packages the resulting conditional ordinary
no-go.  Its five explicit bridge fields require the modeled same-frame
scheduler, upper-warp collision contact, cached-floor selection refinement,
the accepted runtime dispatch/sample/alias/external/final-receiver projection,
and the stock surface-owner/list/final-query refinement.  Under all five, no
separately supplied cached-payload fate changes the contradiction: the ordinary
selected-floor theorem already makes that query null.  The fate argument is
unused; no coupled lifecycle chronology is proved.  This does **not** prove
those bridges for retail execution or close rank 1.  It says that a useful
installer must violate at least one named bridge premise, while the only
constructed ordinary split remains Y-only, downward, and null.

`Area1PostCopyAliasCallbackClosure.v` narrows the post-copy alias/callback
escape.  Its bilateral generated-source census finds exactly nine direct
raw-XYZ formal-receiver helpers and no one-hop call that passes the designated
Mario object to one of them.  It also checks the two relevant child-copy
chains: particle/debug allocation results are the copy destination and the
current/Mario object is the source.  A CompCert memory lemma then proves that
a write through a distinct valid object slot preserves Mario's raw coordinate;
a changed load therefore requires the same slot.  This does not yet prove
current-node identity, allocator freshness, transitive wrapper closure, or
indirect/external/lifecycle non-aliasing.

`DefaultArea1Rank1ResidualCapstone.v` eliminates retained inbound lineage from
the declared null seed and expands a supplied completed-query sample mismatch
to seven named approaches.  `DefaultArea1Rank1BoundaryUnderdetermination.v`
then proves why this is not a complete negative result: the current active-
preapply wrapper ties the projection to its run only through version and the
initial null seed, so it accepts a fabricated top-query projection unrelated
to later run steps.  The diagnostic is not a retail counterexample.  It makes
a linked run-to-preapply chronology/sample/owner construction the decisive
missing interface for any sound closure of the highest-ranked route.
Accordingly, the immediate research priority is a linked *useful* split or a
closure of the remaining alias, callback, scheduler, surface-owner, and
lifecycle escapes.  Routing the remaining pyramid pillars is downstream of
that result rather than the current blocker.

The linked-lineage follow-up now carries the direct syntax census into the
constructed official cleaned US and JP `prog_defs`. Every visible direct
`gMarioPlatform` assignment and address-taking site is accounted for, and any
retained internal direct updater caller must be named `update_objects`. On JP,
the exact dataflow fragments in the generated updater/apply source bodies are
checked. Exact selected-target body resolution pins the bilateral raw-Object
query receipt to the actual selected `update_mario_platform` bodies. CompCert
small steps execute the individual `Surface.object`
temporary, `gMarioPlatform` store, and apply-load statements under explicit
premises in an abstract global environment. This rules out an
overlooked direct named internal writer; it does not rule out an aliased store
or external effect. The floor-query branch, live owner and
slot/epoch identity, intervening
cell frame, and query/current-sample relation remain open.  For any supplied
pre-apply projection whose seed is the null value decoded from the SSL Area 1
run-start memory, the chronology excludes retained JP inbound lineage and
leaves a four-case abstract residual interface.  Constructing the projection's
events from the linked run remains open. See
[`docs/notes/linked-platform-lineage.md`](docs/notes/linked-platform-lineage.md).

The query-owner and apply-time payload are now modeled separately in
`Area1SurfaceEpochLifecycle.v`.  Clearing a dynamic-surface list does not clear
the cached raw pointer, and its payload must be live same epoch,
inactive/freed same epoch, fresh same-slot epoch, or invalid/aliased.  A closed
abstract epoch-4-to-5 reuse witness moves State while leaving Object local;
it does not prove a retail free-list trace or query geometry.  The most useful
counterexample lead is the active-frame query/current mismatch followed by the
authenticated JP inactive-old-top fate: collision first caches the local warp,
the later State/Graphics selection and raw-Object copy move the final query to
the top, and JP retains the top address until destination apply.  The observed
top remains inactive and unreused at free-list depth 47, so fresh same-slot
reuse is an abstract fallback rather than the leading retail fate.  The two
independent different-sample/reuse witnesses do not establish compatibility in
one execution.  `Area1PolePushSchedule.v` and `Area1PolePushLinkage.v` also
conditionally remove one tempting normal source: static Area-1 data ties the
exterior palm to `bhvTree`; its X/Z-only push runs in POLELIKE before Mario's
PLAYER update, and a completed, correctly targeted State-to-Object copy
resynchronizes it.  Linked behavior-list execution and copy identity remain
open.  A late-writer route therefore needs a genuinely post-player writer or
a skipped/misdirected copy.  `Area1PostCopyTailClassification.v` makes that
remaining abstract boundary explicit.  For a supplied copy observation and
frame tail, it classifies synchronization preservation versus projected-
coordinate changes, copy failure, endpoint retarget, lifecycle change, alias/external
effects, and scheduler/unclassified residuals.  This broad classified-residual
result is not itself a data-bearing claim: some residual tags preserve both
projected coordinate values.  The stronger theorem assumes a faithful copy and
a final State/Object value split, skips those value-preserving edges, and
extracts an actual State-only, Object-only, or joint value-changing edge.  The
tail and origin labels are still supplied abstractly rather than projected
from linked retail execution.  In particular, `SuppliedFrameTail` only chains
caller-authored snapshots and origin labels; it proves neither adjacency of
generated statements nor retail execution semantics.
`Area1PostPlayerTailSource.v` now adds the
concrete bilateral source boundary around that classifier.  It pins the exact
post-PLAYER list suffix to `[5; 4; 2; 6; 8; 12; -1]`.  That suffix is not the
whole post-copy tail: inside `bhv_mario_update`, the copy precedes a
`spawn_particle` loop; the `bhvMario` script then names
`try_do_mario_debug_object_spawn`, whose body calls `spawn_object_relative`;
and traversal may continue to later PLAYER nodes.  The generated receipts do
not say that either guarded spawn runs or that another PLAYER node exists.
The bilateral `sParticleTypes` initializer identifiers are now coupled exactly
to 18 paired behavior definitions, each with leading word `8 << 16` (list 8),
and the local AST couples the selected table `behavior` field to
`spawn_particle` argument 3 and its formal to `spawn_object_at_origin`
argument 4.  This is a concrete post-copy source candidate family, but proves
no loop/index execution, enabled particle flag, allocation, visitation,
callback execution, coordinate write, or clean reachability.
After this intra-PLAYER residual, the updater orders unload and the final
platform query.  The fixed scheduler, traversal, unload, and final-query
bodies have no recognized direct State-position or raw-Object XYZ store, but
that negative census deliberately excludes behavior callbacks and reaches
only through the final query, not the full next-pre-collision boundary:
`update_objects` calls `try_print_debug_mario_object_info` afterward.  The module
also exposes why the static root inventory is not callback-complete: an SSL
Area-1 `bhvBreakableBox` root can reach
`obj_explode_and_spawn_coins`, then `spawn_triangle_break_particles`, which requests list-12
`bhvBreakBoxTriangle`, after PLAYER in the update order.  These are generated
syntax/data receipts, not proof that the child is allocated and visited in the
same frame.  Intra-PLAYER particle/debug spawning and later PLAYER nodes,
transitive spawn/interpreter closure, receiver and alias identity, external
calls, unload/pool-reuse effects, abnormal callback control flow, and
the post-query debug callback plus warp/instant-warp processing at the next
pre-collision frame remain explicit residuals.  Alias and
external alternatives are reduced separately by
`PlatformExternalGapSemantics.v` and `PlatformAliasExternalClosure.v`.  See
[`docs/notes/local-object-nonlocal-state-gap-matrix.md`](docs/notes/local-object-nonlocal-state-gap-matrix.md)
for the complete mechanism-by-mechanism proof and counterexample priorities.

`PlatformPointerProvenance.v` computes the complete US/JP direct
`gMarioPlatform` syntax census: JP has only `update_mario_platform`; US also
has the null-only spawn clear.  There is no internal address-taking or static
initializer relocation to that global, and the only source-shaped non-null
update value comes from `Surface.object`.  `Area1QueryScheduleClosure.v`
computes intraprocedural generated-AST call/guard receipts and proves a
separate finite schedule model.  In that model, an interaction that selects
the upper-warp `ACT_DISAPPEARED` action has a later final-query call.  Its
conditional position split uses the post-wall State sample, the Graphics
retry, the cached-floor Y snap, or an unclassified post-copy discrepancy.  On
the retry-still-null branch, the interaction can select
`ACT_DISAPPEARED`, but the earlier death request remains the fatal-latch case;
this branch is useful for pointer chronology, not a successful Area-2 warp.
`Area1WarpTopCloneCensus.v` enumerates the static top/warp references
and all 21 direct collision-data writer bodies.  The allocator contains only
null direct assignments to that field, and ordinary pose-copy helpers do not
copy behavior or collision identity; successful-return execution is open.
The linked non-alias/external frames, live branches, post-copy discrepancy cause,
surface-list slot/epoch projection, runtime spawn provenance, and the clean
binary32 `<960` writer invariant remain open.  See
[`docs/notes/stock-projection-exhaustiveness.md`](docs/notes/stock-projection-exhaustiveness.md).

`JPZeroAReachability.v` defines a zero-edge relation over real `Clight.step2`
states while checking bit 15 of the live controller `buttonPressed` field in
every observed memory; A may remain held in `buttonDown`.  Despite its
identifier, the relation is parameterized by an arbitrary program, controller
address, and entry state and does not itself establish `CleanJPArea1GapAuditState`
or ordinary JP reachability.  Its induction shows that an entry below the
current bound remains below `960` only under an explicit live-memory projection
contract and per-step `JPZeroAGapStepRefinementObligation` premise.  Those are the
unresolved writer, action, alias, and external-call closure, so this is a
conditional composition theorem rather than a retail exclusion.

This audit records a conditional countermodel to any naive per-frame bound.
The earlier prepared `-2.650000095f` depth reaches the required range after
363 or 381 unreanchored sinks, depending on the selected base.  The stronger
split-floor candidate is exact binary32 `-4.0f`; the proved integer scheduling
model needs 240 such four-unit sinks for a 960-unit rise.  The corresponding
240-step binary32 recurrence from a live base remains an explicit obligation.
`AutomaticDialogReanchoring.v` checks for both US and JP that
`ACT_READING_AUTOMATIC_DIALOG` is dispatched as a cutscene action and that its
handler contains no recognized direct depth write or State-to-Graphics copy.
Its finite model can remain at the open-dialog state for any requested number
of frames when supplied the same surviving depth.  Proving that the live
constructor and helpers preserve that depth remains open.

`ZeroAQuicksandEntryBoundary.v` resolves the prerequisite inside a finite
source-shaped transition kernel.  A legal `CleanPyramidEntry` starts with
action `0x1932`; the separate concrete pyramid-entry memory postcondition
assumes/fixes timer, state, and argument zero and depth `+0.0f`.  The ordinary
Area-1 entry memory postcondition separately fixes action `0x1924`, timer zero,
and depth `+0.0f`.  Only the authentic six-frame long-jump landing descriptor can run a
timer-4/5 landing body that changes a nonnegative depth to a negative one.
Across all 38 generated US and JP units, the only ordinary long-jump
constructor is the `act_crouch_slide` branch guarded by `INPUT_A_PRESSED`, and
the only long-jump-landing producer is `act_long_jump`; direct action writers
embed neither target value.  The source transition/depth kernels therefore
exclude the prepared negative state on no-edge, no-forgery traces.  What is
not yet proved is that every clean linked retail step belongs to those kernels
and executes the Controller-to-Mario input refinement, or that alias/OOB/
external writes, callback retargeting, and mutation of the writable landing
descriptor are unreachable.  No concrete forged writer is known.

`NegativeDepthForgeryBoundary.v` then audits the remaining source-visible
forge surfaces.  All nine landing descriptors and `sInteractionHandlers` are
writable globals but have no direct generated assignment.  Each descriptor's
address is formed only by its matching landing wrapper, and a timer forge
alone cannot bypass a stock four-frame descriptor's early return: a non-long
landing needs frame-count corruption as well.  The only indirect MarioState
calls are the input-bit-2-guarded landing callback and the interaction table.
Finally, a CompCert byte-frame theorem shows that changing the action cell
requires a same-block store whose byte range overlaps it.  Compiled N64 flat
layout, live pointer provenance, writable-global integrity, indexed render
state, and external frames remain open.

Stock SSL Area 1 has an exact static-mesh candidate beginning at
`(5760,0,4856)`.  The four real quarters have now been executed in
authenticated US and JP retail runs from injected pre-timer-3/pre-timer-4
fixtures that enter timer-4/timer-5 bodies:
all wall and ceiling pointers are null, every selected floor is static
shallow-moving quicksand with no object owner, and the exact final bits are
Z `0x4599198b` (`4899.19287`) and Y `0xc0fc4011` (`-7.88282061`).  This
corrects the old exact endpoint `4900`; it does not prove the injected
long-jump state clean-reachable or refine the trace to linked Clight memory.
The matching symbol maps came from clean revision `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`;
the movement, collision, and SSL mesh sources used by this trace are
Git-identical there and at the formal project's pinned
`9921382a68bb0c865e5e45eb594d9c64db59b1af` revision.

The prepared pre-timer-3 fixture was also continued for one genuine successor
frame with no second memory injection.  Both retail versions execute four
more normal ground commits on static owner-null type-37 floors; all wall and
ceiling results and `gMarioPlatform` stay null, and no A edge is observed.
The successor ends at raw Y `0xc199271e` (`-19.1441002`), Z `0x459aaf5f`
(`4949.92139`), Graphics Y `0xc183f3eb` (`-16.4941006`), and depth
`0xc029999a` (`-2.6500001`).  This authenticates the proposed timer-5
follow-up for the prepared fixture, but it still does not establish clean
reachability or a CompCert execution refinement.

`NoExitStarDialogBridge.v` narrows the following-star schedule with generated
source-shape receipts and a finite lifecycle/arithmetic model.  In that model,
a fresh 100-coin star clears time stop one frame before its hitbox becomes
eligible, so Mario receives an intervening update.  The modeled update splits
the two fixtures: post timer 4 reaches the next landing writer and ends at exact
`-2.65f`, while post timer 5 exits at timer 6 and the same action loop reaches
stationary processing, ending positive at `1.85f`.
The finite prepared orbit starts from the `spawnY+250` home and settles five
units below it, at `spawnY+245`; the resulting overlap interval is
`[spawnY+85, spawnY+295]`, excluding same-height Mario.  Linked binary32/12k
motion refinement and any compatible Mario height transport remain open; so
does an older pre-positioned tangible star.  For the supplied prepared-star
words, `Area1LongJumpQuicksandNextFrameTrace.v` proves that the successor
frame's modeled raw Mario top is more than 96 units below the first-hitbox Y
and that even its Graphics top is below it.  Thus the fresh timing branch
survives, while this finite 160/50-hitbox arithmetic pairing is vertically
separated.  The star words and hitbox fields are not yet connected to a live
linked-Clight object lifecycle or execution of the overlap routine.

`DialogDepthMemoryFrame.v` closes one narrower part of the later conditional
handoff: generated US/JP layouts put `quicksandDepth` at offset 192, and actual
CompCert `Mem.store`/`Mem.load` lemmas prove that finite stores to the earlier
action/control cells—or to the distinct Area-1 object-pool block—preserve the
exact depth word.  Seven generated star-dance/dialog spine bodies are direct
nonwriters.  Small-step branch refinement, pointer/alias validity, preprocessing
calls, and unresolved external frames still prevent a linked end-to-end
preservation theorem.

`NegativeDepthTimer131Bridge.v` proves in its finite untransported-dialog model
that amplification alone retains the supplied raw X/Z.  Its squared-distance theorem uses the idealized
`(5760,4900)` boundary sample and obtains `96058640` against a hitbox threshold
of `34969`; the stronger X-only exclusion also applies to the successor
frame's X=`5760` when no intervening X writer is introduced.  Generated
source-shape checks and an exact arithmetic mirror identify the stationary
post-dialog quicksand update and positive `1.6f` outcome; they do not prove the
linked branch executes.  The remaining handoff is active-dialog platform or
other raw-object transport, warp relocation/substitution, collision aliasing,
or an unclassified writer.  Linked branch/pointer/external frames and
installation into the timer-131 trace remain open.  See
[`docs/notes/negative-quicksand-unreanchored-dialog.md`](docs/notes/negative-quicksand-unreanchored-dialog.md).
A source review also rejected fire particles as a Mario writer: the callback
updates Mario's `prevObj` flame, not Mario.

The project-local hash-gated JP search is read-only after its externally
enabled level-select bootstrap.  Its bounded zero-A schedules observed no
positive gap (maximum `0`) and no A-derived input bit; this is test evidence,
not exhaustive reachability and not proof that the bootstrap state is an
ordinary castle-entered state.  See
[`docs/notes/clean-jp-graphics-gap-source-audit.md`](docs/notes/clean-jp-graphics-gap-source-audit.md)
and [`instrumentation/jp-clean-gap-search/`](instrumentation/jp-clean-gap-search/).

`TurningAnimation.v` addresses the reported Turning-Part-2 upwarps.  The
number `0xBD` is used in two unrelated domains: animation ID 189 and the
default `animYTrans` numerator 189.  The pinned Part-2 animation divisor is
also 189, so CompCert binary32 proves that the renderer multiplier is exactly
`1.0f`; it is not a 189-unit Y write.  Generated US/JP receipts check the
`forwardVel >= 18.0f` branch with IDs 188/189, both local
ground-step/animation orderings, `unkB0 -> animYTrans`, the
`load_patchable_table` direct footprint, and the sole renderer consumer now
imported from `rendering_graph_node.c`.  The proved metadata model preserves
MarioState, raw Object, and Graphics-anchor coordinates and cannot create
Ink's split from synchronized input.  A checked alias counterexample shows
why an unconditional DMA frame rule would be unsound.  Converter/table
mapping, animation-buffer separation, `dma_read` refinement, and a linked
Clight before/after projection remain open.  The real `perform_ground_step`
and surface-selection path remains part of ordinary motion; no retail
animation-induced upwarp was found.  See
[`docs/notes/turning-animation-upwarp.md`](docs/notes/turning-animation-upwarp.md).

`FirstTargetRefinement.v` now defines a stronger evidence-bearing interface:
each classified frame carries actual before/after Clight states, a CompCert
trace segment, projected states, an exact indexed `CertifiedStep`, and a
crossing of a concrete `CollisionSupportCut`.  It proves several limited
eliminations inside the certified semantics, but no concrete linked run
constructs that classifier and the remaining movement classes are not closed.
`FirstCrossingWriterCoverage.v` now repairs the classification boundary.  It
proves that an arbitrary `CollisionSupportCut` can be degenerate, introduces
a `TargetCollisionCutFamily` parameter for the construction and exclusions,
requires source and non-target membership for the actual projected initial
state plus
endpoint-local side separation, identifies an actual minimal pre-target
Clight crossing, and proves its abstract event-label coverage.  A changed
Mario position is
classified by the projected abstract event as ordinary physics, platform
displacement, object impulse,
collision clip, or area reload.  If XYZ is unchanged, the selected floor or
raw platform must have changed instead.  Coordinate alias/out-of-bounds is
treated as a domain class of the physics endpoint, not a separate store.  The
result exposes an additional support-selection obligation that the historical
six classes missed.  Construction of contracted, ordered crossings and all no-A
movement/domain/support exclusions remain open for linked US/JP runs.  The
exclusions now range only over clean entries and the selected cut family.

`OrdinaryMotion.v` now treats the first of those writer families separately.
The proved theorem `ordinary_safe_envelope_execution_excludes_target` shows
that caller-supplied finite-cell preservation and target-exclusion
obligations compose over an ordinary-motion execution; it does not discharge
those obligations for retail.  The closed capstone
`current_ordinary_motion_evidence_boundary` packages the checked source,
mesh, non-Wing arithmetic, and Wing-Cap countermodel boundary.  The current
abstract `MotionPhysicsFrame` accepts an arbitrary endpoint, so its label
alone cannot exclude a crossing.  The generated US/JP ASTs also expose a
concrete reason that "no A edge" must not be read as "no ascent": when A was
already held, punching can select `ACT_JUMP_KICK` after B without a new A
  edge.  `UpperElevatorQuarterStepClosure.v` now replaces the frame-end
  estimates with every binary32 collision sample: 32 held-A jump-kick queries
  peak at `134`, and 40 B-rollout queries peak at `224.5`, both below the strict
  `231` wall-rejection cutoff after the dynamic surface's five-unit upper-Y
  pad.  It also checks each arithmetic transition and enumerates the six
  literal quarter-step results.  `UpperElevatorWingCapTransitionClosure.v`
  now checks the stock Area-1 node-`0x1E` to Area-2 node-`0x14` call chain:
  the same-level area warp reinitializes Mario, writes only non-Wing flags and
  a zero cap timer, and SSL course 8 selects none of the three initial
  special-cap cases.  Carrying Wing through that stock transition is therefore
  impossible in the defined source execution, pending the ordinary linked-run
  receiver/route connection.  A hypothetical Wing installed after reset has
  only two above-cutoff queries, `234` and `232`, before returning to `230` and
  `228`; that is a wall-selection opportunity, not a crossing witness.  The
  descent, live elevator/surface selection, and action/collision execution
  remain open.  The lower route remains open beyond
the existing normalized soft-bonk subcase.  See
[`docs/notes/ordinary-motion.md`](docs/notes/ordinary-motion.md).

The upper entry also starts at Y `5500`, above the elevator's initial
raw-mesh rim top Y `5222`.  The ascent bounds apply only after a normal landing
in the cage.  Generated source-shape receipts show the no-spin airborne spawn
path repeatedly supplies zero forward velocity before its air step, but no
Clight/collision theorem yet proves that the entry descent is vertical, lands
on the intended live elevator floor, and reaches the prestates assumed by the
ascent kernel.

The Area-2 cut tranche now replaces the lower phrase "above the second pole"
with an initializer-backed inventory: ring triangles `1414..1421`, aperture-
plane candidates `1534..1541`, and four conservative closed binary32 boxes over
the ring footprint while excluding the central shaft.  The formal target side
uses the ring records and boxes; the plane candidates constrain the pending
wall/separator proof.  It also inventories the exact
upper elevator base/wall/rim and fixed chamber/surrounding-floor triangles.
Because the elevator moves, its moving-relative source candidate is kept
separate from the coarse absolute-sweep `CollisionSupportCut` adapter; the
adapter is not described as the exact moving component.

Both entrances now have admission-free conditional first-crossing reductions
over seven writer/support classes, but neither retail no-A gate closure is
proved.  Live surface decoding/selection, a concrete source component, every
writer exclusion, and same-frame collision-phase crossings remain open.
Version-indexed downstream suffix records separately require Act-3 access,
all five trigger regions, and Act-6 collection from a supplied boundary.  The
existing injected JP observations check all five trigger overlaps and a
separate Act-6 pickup, but do not inhabit a cut-starting suffix.  A direct
standing sample on the checked Act-3 support misses vertically by 75 units.
The transcript nevertheless supplies two post-gate Act-3 itineraries: an upper
100-coin-star/vertical-speed/star-dance route and a lower homing-amp ledge clip
followed by the Grindel/elevator-misalignment route.  Rocq records their ordered candidate
stages and names separate upper/lower suffix obligations, but does not yet
refine those stages to linked execution.  The transient direct-steering
experiment did not attempt the transcript's misalignment route and therefore
does not exclude it.  See
[`area2-elevator-cut.md`](docs/notes/area2-elevator-cut.md),
[`area2-lower-target-cut.md`](docs/notes/area2-lower-target-cut.md), and
[`area2-downstream-continuations.md`](docs/notes/area2-downstream-continuations.md).

`GoombaRaising.v` now formalizes the useful part of the attached
Goomba-raising proposal.  In the selected no-fresh-walk-jump branch, a grounded
priming sequence precedes the repeatable airborne jump action `2` state.
Other initial walk-action jump branches remain possible.  The
conditional H/F/R model has the idealized integer recurrence `y + 21*n`.
CompCert binary32 proves the velocity update `25 + (-4) = 21`, and concrete
integer-aligned Y `51` runs for 31 and 83 rises are exact; arbitrary stored Y
need not gain exactly 21.  Rocq exhibits a binary32 fixed point: at Y `2^29`,
adding `21.0f` leaves the stored value unchanged; it does not prove that the
selected Y `51` orbit reaches that point.  The
conditional integer hitbox abstraction limits a Spindel collision station to
Goomba Y `[1961,2496]` plus an idealized final hit to `2517`, so the Area-2
singleton at integer Y `778` cannot use it directly.  Linked binary32
collision/addition bounds remain open.  A 91-frame Area-1 pyramid-top
window permits at most 31 productive hits for the post-collision H/F/R
schedule; 83 are needed arithmetically to reach Y `1791` from Y `51`.
An alternate pre-collision raw-Object writer schedule remains open.

Generated US/JP receipts separately check Goomba callback/action/movement
syntax, generic collision bodies without a direct FAR guard, Spindel callback
and pitch syntax, the generic allocation write of `1000.0f`, full-float object
distance, and signed-16 narrowing of transformed dynamic vertices.  They do
not couple every constant to its live branch and are not a semantic link to
the H/F/R model.  Trace-wide no-A shuttling, both raw-Object scheduling
shapes, same-segment local-load/PU capture, physical singleton transport,
collision capacity/liveness, and every later height handoff remain unproved.
No clean retail counterexample was found.

A separate, current-source-rechecked
`ArchivedProofIntegrationKernel` incorporates narrow lessons from all six
archived investigations without importing their old ASTs.  The whole-program
Clight-to-event/collision projection and every lower/upper collision-observation
non-overlap obligation remain open.  None of the six archived projects closes
either gap.

The newest bounded result imports the actual `math_util.c` and
`surface_load.c` Clight bodies.  `PyramidTopSurface.v` checks the concrete
CompCert short casts for the phase-split sample, its dynamic-partition cells,
links the parsed selected face to manually translated zero-yaw home vertices,
and evaluates hand-mirrored binary32 transform and signed-edge formulas.
Its `find_floor` checker finds a guarded `floor := dynamicFloor` assignment
source shape; it does not establish exclusivity or the complete height update.
`PyramidTopPU.v` uses that checked kernel beside the existing same-sample and
Y-preserving arithmetic exclusions and the two-sample coordinate model.  The
linked memory execution, live dynamic-surface ownership/list selection,
gameplay reachability, and JP delayed-warp pointer lifetime remain open.
Authenticated US/JP retail disassembly and
`concrete_retail_cast_fragment_arithmetic` verify the exact
`trunc.w.s; mfc1; sh; lh` arithmetic for all three candidate inputs, including
`63488.0f -> -2048`; arbitrary unrelated out-of-range conversions are outside
that result.  The US spawn source
contains a direct platform clear,
and a state-level lemma excludes retaining the same epoch after a successful
clear; the Clight memory-effect refinement is still pending.

`InkFallback.v` checks the guarded US/JP graphical floor-null retry and
entry-coordinate synchronization source shapes.  It proves a nearby Area-1
mesh arithmetic kernel at State `(-2200,768,-1024)` and conditional local and
PU three-view pipeline-coordinate witnesses.  Their collision Object is at
`(-2048,768,-1024)`; Graphics is either `(-2048,1791,-1024)` or
`(63488,1791,-1024)`.  These theorems show that update order permits the
primitive if the first query returns `NULL` and the retry selects a loaded
top-owned surface.
The generated recognizer checks the null/copy/retry syntax and dataflow, but
the handwritten pipeline witnesses do not execute it in Clight.  They do not
prove either live-list result, a reachable clean prestate, or the post-copy
object/surface-owner lifecycle.
`Area1FirstNull.v` parses the actual generated US/JP Area-1 collision words
and kernel-computes 574 vertices, 962 triangle records, and the exact
17-wall/26-floor inventories for cell `(5,7)`.  Its pure source-shaped
evaluator computes all four wall and both floor decision lists as
all-rejection, then packages zero-push and
`Area1FloorNull`/`-11000.0f` records.  Its computed rejection trace derives
the `12+8+5+1` tally.  It also checks signed-intermediate bounds and exact
CompCert-binary32 results for the decisive axis-aligned planes and roof
buffer.  The theorem `area1_q_static_all_rejection_checks_computed` exposes
all four wall and both floor all-rejection computations directly.  The
reported zero/`NULL` result is still a record assembled after those pure
checks, not an independently executed Clight traversal.  Live Clight
allocation/list execution, input-cast refinement,
dynamic-list completeness, memory writes, and clean reachability remain
explicit obligations.  The supported center-floor result remains part of the
separate audit rather than this new static evaluator theorem.
`RetailFatalLatch.v` now proves the fatal-pending-or-continuation-destroyed
invariant for an explicit source-audited event system and proves that no trace
in that system accepts the later upper object-warp request.  Generated US/JP
receipts separately compute the direct `sDelayedWarpOp` writers in
`level_update.c`, explicit address-taking sites, call-presence/callee-order
plus separate clear-presence anchors, and the packed Area-1 death record.
They do not prove assignment/call order or destination selection.  Zero lives
is represented by the same nonzero fatal class as ordinary death.

This is a checked source/event boundary, not a linked Clight exclusion.  The
remaining obligation is a linked Clight/memory refinement from concrete
execution to the event system, including accepted fatal initialization,
clear/reset barriers, and exclusion of unmodeled memory writes.  The
both-`NULL` `find_floor` outcomes and their reachability also remain unproved.
Subject to that refinement, the surviving Ink schedule specifically requires
a non-null graphical retry.
The new `InkTimer131ProducerClosure.v` result narrows the producer side without
assuming that refinement.  Across both generated behavior-data corpora, all
40 command words targeting `oGraphYOffset` are fixed `SET_FLOAT` values at
most `+240`; no stock value can meet the generic `+632` timer-131 requirement.
Mario's own behavior has no offset command, allocation clears the raw words,
and its normal flag command enables bit 8 rather than the tail's bit 0.  The
other unbounded direct writer is now coupled exactly to the Chuckya/King
Bob-omb anchor family, whose parents are absent from the audited stock SSL
Area-1 selectors and direct C references.  Conversely, a deliberately
non-stock `+1160` offset at warp-center X/Z produces an accepted timer-131
face observation.  Thus the normal stock-script/anchor producer stories are
closed at the source/finite-geometry boundary, while linked Mario-slot
identity, forged or indirect commands, dynamic spawn provenance, alias/OOB or
external writes, and slot lifetime remain capable of reopening them.
`InkTimer131MarioTailClosure.v` further closes the ordinary direct-call tail
subcase.  It corrects the flag-slot audit to the unsigned view used by the
consumer, inventories the 30 direct flag and 28 direct offset writers in both
generated corpora, recursively closes the direct-call graph rooted at Mario's
three callbacks, and proves that the graph reaches no writer through any
literal raw-data union view.  The checked spawn/list source chain narrows
`gCurrentObject = gMarioObject` to a live execution and lifetime obligation,
while the exact interpreter receipt plus bit arithmetic proves that Mario's
stock `OR 0x100` command cannot enable bit 0.  Indirect/external execution,
aliases, out-of-bounds writes, forged behavior, and slot reuse remain open.
`InkTimer131IndirectAliasClosure.v` resolves the two stock indirect families
(landing callbacks and the interaction table), expands the closure through
every stock target, and again finds no dangerous writer.  It additionally
finds no direct unresolved `Object *` handoff in that closure, no direct or
builtin unresolved `MarioState *` handoff in the generated corpus, and no
builtin `Object *` handoff.  Its CompCert memory boundary proves that a changed
flag/offset cell requires an overlapping store in Mario's pool slot; an
in-bounds store in any distinct 608-byte slot preserves both cells.  The pool
fallback is source-coupled from list 12's first object to `unload_object`,
whereas `bhvMario` declares list 0, so ordinary eviction/reuse is harmless
under the explicit live list-partition and distinct-slot projection.  The only
direct behavior-field writer in the resolved graph is `create_object`, and no
generated body takes that field's address.  The remaining Ink-tail escapes are
now live table/list corruption, Mario slot or epoch failure, a corrupted
constructor argument, global/interior-pointer or OOB access, and untyped
outside effects—not an unidentified stock callback or mutation helper.
`InkTimer131CorruptionClosure.v` further checks that each mutable dispatch
table is mentioned only by its expected dispatcher and has no direct named
assignment or explicit address-taking site anywhere in the generated US/JP
corpus.  It also couples the Mario spawn path's one stable
`segmented_to_virtual(behaviorScript)` value to both `create_object` and the
new object's behavior field.  Finally, a clean zero-A/no-forgery source trace
cannot supply a negative quicksand seed, while granting one and any finite
untransported dialog stall still leaves raw X/Z outside the upper warp.  The
remaining Ink cases are therefore genuinely live-memory cases: corrupted
list/slot/table/spawn-record identity, forged or interior pointers,
overlapping OOB stores, untyped external effects, or a negative seed composed
with a separate raw-X/Z transport.
`InkTimer131LiveIdentityClosure.v` closes the missing source link at the front
of that chain: the exact bilateral SSL `INIT_MARIO` command carries
`&bhvMario`, and the generated command, area-load, and constructor bodies
forward that one value into Mario's object.  It also proves an arbitrary-length
CompCert-memory result rather than another one-step frame: any finite sequence
of unrelated framed stores, bounded distinct-object-slot stores, safe stock
flag writes, and zero graphical-offset writes preserves the two safe Mario
cells and cannot enable the graphical tail.  A clean retail disproof must now
show that every executed store refines to those cases; any in-model
counterexample must exhibit the first same-slot overlap, identity/table
mutation, valid alias, or specified external effect that does not.  Invalid
and out-of-bounds executions are outside the present Clight run.
`InkTimer131ClightTraceBridge.v` supplies the next semantic layer.  It models
Mario's list-0 membership as a bounded path through the actual list/object
`next` fields, fixes both Mario pointers, active state, behavior pointer, and
selected command/dispatch loads, and proves that this invariant survives an
actual reachable CompCert `star` whose steps satisfy the checked store or
protected-byte cases.  Known builtins/runtime calls satisfy the frame without
an alias assumption.  The bridge now distinguishes five fixed identity loads
from mutable object-list links: ordinary insertion/removal may rewrite links
as long as Mario remains reachable from list 0.  Each unresolved external is
handled at its reached callsite, where it must either preserve the exact
protected cells or expose an explicitly refined writer effect.
`InkTimer131EntryExecutionClosure.v` then proves that both watched words are
zero in every valid slot of the official JP initial memory, checks the
allocator/load/spawn source chain, and finds `bhvMario` as the sole generated
list-0 behavior.  It also turns a direct post-spawn list-head load into the
live membership predicate and extracts the first invariant-breaking step from
any dangerous actual trace.  `InkTimer131RealEntryPrefix.v` makes the requested
execution shape precise at the accepted level-select boundary: it begins at
`clear_objects`, distinguishes the Area-object and Mario calls to
`spawn_objects_from_info`, continues through `init_mario`, and includes the
first object/behavior update needed to obtain `oFlags=0x100`.  Its certificate
joins those internal call states with one continuous sequence of real CompCert
steps and attaches a watched-cell effect to every step.  Exact final loads for
slot 67, the `bhvMario` symbol and pointer, both Mario pointers, active state,
all four one-node ring links, `oFlags=0x100`, and zero graphical offset imply the
full live invariant; no ordinary-entry or pre-allocation slot-safety premise is
used.  The pre-update 85-function family has three conservative outside sites;
the 150-function first-update family has five names at eight sites.

A read-only, hash-gated original-JP mode-2 run now supplies an exact continuous
machine write receipt in addition to the call checkpoints.  Physical
watchpoints cover every endpoint identity and protected range.  The accepted
epoch has exactly 19 stores: Mario's allocator performs the first safe zero
writes, the constructor/spawn/init path installs slot 67, `bhvMario`, both Mario
pointers and the one-node list, and the first indirect behavior pass writes
exactly `0x100`; no instruction writes a nonzero graphical offset or a flag with
bit 0 set.  The runner compares all 19 lines against a committed receipt, while
Coq replays them from arbitrary prior watched values to the exact endpoint and
checks every protected overlap as safe.  This closes endpoint derivation and
watched-effect classification for that authenticated retail execution,
including whatever machine code ran inside indirect or outside calls.
`jp_timer131_authenticated_receipt_is_accepted_entry` now packages the receipt,
checkpoint order, distinct spawn callsites, complete slot/list/behavior identity,
and safe tail as `JPInkTimer131AcceptedEntryTheorem`; `MainTheorem.v` exports that
result as the project's accepted Timer-131 entry boundary.  The receipt is still
not an IDO-MIPS-to-Clight simulation.  Constructing the optional native CompCert
prefix would require such a relation (or a reconstructed Clight start state) and
concrete meanings for the three abstract pre-entry `EF_external` calls, but none
of that is now required to accept this entry.  Required route work begins at the
recorded safe endpoint and classifies later execution through timer 131.
Ordinary castle entry is not required because level select is the accepted start.
The abstract case split now also captures that a successful retry performs
only the first of the two `ACT_DISAPPEARED` ticks.  A second floor-supported
Mario update is required before the upper object warp can be requested.  If
the following update instead has both floor queries return `NULL`, the fatal
first writer wins when the latch is empty at that call boundary.
Arbitrary prefixes already refined to State-only preserve Object and Graphics
and therefore cannot create the needed split from synchronized input.  A
generic retry whose Graphics Y is in signed-16 range needs at least
385 upward units; either exact
local/PU prestate proposed here needs at least `973`.  Complete audited writer
coverage from an audited entry conditionally refutes that prestate, but retail
coverage remains open.  The theorem excludes the dry
ordinary `<=45` visual-offset subcase once that premise is derived from a
reachable execution.  The source-shape kernel also checks that remaining
non-terrain updates and deactivated-object unloading precede the final platform
query.  Its checked syntax admits an explosion-frame candidate in which the
top loop is followed by its collision loader and the slot is later unloaded;
it does not prove the linked behavior-script execution, free-list membership,
or that the same concrete surface is selected afterward.  The two closed
coordinate witnesses use the zero-yaw home top and floor Y `1791`; they do not
instantiate that later translated/rotated explosion pose.
For shell-specific Graphics writers, a handwritten two-step integer transition
threads the first result through a State-only interframe write and explicitly
reanchors the second frame from current State.  Under that model definition,
`+42` in air and `+45` on ground are re-established rather than accumulated.
Generated-AST receipts separately pin step-before-add ordering, the two
literals, and the ground- and air-shell quicksand reset paths.  They do not
yet refine the handwritten transition.  The
audited wall loop changes collision-record X/Z while retaining its Y input;
the inspected shell and interaction callers do not directly pass Graphics,
and direct pinned-source inspection says successful cached warp contact
selects `ACT_DISAPPEARED` before action dispatch.  The generated receipts do
not yet prove the indirect call, handler success, break, or dispatch dataflow.  A
wall can still enable the floor-miss schedule.  These facts do not yet prove
binary32 end-to-end behavior, pointer non-aliasing, every wall caller, or
complete reachable action/writer closure.
The handwritten three-view model now proves separately that a State-only
writer has zero Graphics-Y delta and that an arbitrary wall/floor-selected
State height followed by its shell reanchor leaves at most the one `45`-unit
modeled gap.  This captures why a wall may raise absolute State/Graphics
height without amplifying the next-frame Graphics-minus-Object gap; retail
Clight refinement remains open.
Rocq also checks that unrestricted binary32 endpoint differences can exceed
the `42.0f`/`45.0f` source operands by about `0.000061` at a binade crossing;
those witnesses provide no global bound.  The route-local work is split into
the `608..818` exact-arithmetic obligation and a live-range refinement
obligation.
The ground helper's pre-add float-to-integer casts likewise require a
reachable speed/yaw bound or direct compiled-behavior treatment.

`EntryMemory.v` proves the exact generated US/JP 32-bit field layouts and a
projection from a concrete `Mem.load` postcondition: conditional on those
assumed post-entry loads,
MarioState, raw Object, and Graphics positions are equal; the entry action is
`ACT_SPAWN_NO_SPIN_AIRBORNE`; its state/timer/argument, velocities, forward
velocity, and quicksand depth are zero; `framesSinceA/B` are 255; and the
throw-matrix pointer is null.  The end-to-end US/JP
`init_mario_after_warp` execution propositions remain explicitly unproved.
The clean controller boundary now records the already-live pressed value and
relates it to actual current/previous down samples; it no longer assumes the
two samples equal.

The five-obligation audit found specification defects rather than a retail
counterexample.  The surface, prestate, and writer statements are
predicate-sensitive schemas, not closed retail propositions.  The original
sink statement was false under a repeated-return trace and under a concrete
32-bit pointer-wrap alias; its current record is repaired to use a first-return
relation and disjoint modular cells, and remains unproved.  The current
lifecycle statement is not a sound proof target: `project_state` and the link
are underconstrained.  `behavior_script.c` is now translated, but the exact
link and indirect Mario callback are not proved; relevant external calls lack
frame specifications, pointer-to-slot/epoch linkage is missing, and
equal arbitrary binary32 samples do not imply the platform-tolerance branch.
The imported retail debug callback contains an object-spawn path; proving its
page/config/input guard false in every clean run is part of the open
writer/action/spawn closure.
That interface must be replaced before post-copy raw Object preservation,
transformed-surface selection, or a final owner epoch can be claimed.

`Area1PhaseSplit.v` checks source-backed nonzero-pitch triangle-fragment
payloads and one exact CompCert-binary32 X/Y/Z displacement.  The selected
sample rises from Y `768` to approximately `1878.668`, exceeding the proved
signed-range 385-unit necessary bound.  `Area1SurfaceWitness.v` checks its
short query and
candidate face arithmetic without asserting live surface ownership or actual
`find_floor` selection.

`Area1PlatformExhaustiveness.v` now answers the route-relevant Area-1 question
at a stronger, source-bounded boundary.  `[top, box]` is not a unique
free-list schedule: the source audit identifies three stock pre-apply angular
payload classes—pyramid-top yaw, dirt triangles, and cartoon triangles—with
parametric depth, mist-count, zero-allocation, and FIFO-eviction variants.  The
finite model enumerates fifteen stock Area-1 dynamic-floor owners and shows
that a completed preceding-frame final query at node `0x1E` has no modeled
non-null owner.  It
then covers the bounded completed-query, US spawn-clear,
retained-inbound-pointer, and frozen-carry origins and proves
`stock_area1_upper_warp_preapply_platform_null`.  Therefore zero stock
pre-existing platform-origin schedules survive in this model, independently
of the fragment's exact controller/free-list lineage.  This does not exclude
the graphical fallback: a null pre-apply pointer can be followed by a failed
first query, a top-side graphical retry, and a new final top capture.  Exact
generated LevelScript
receipts show that clean, non-credits Area-1 warp entries use nodes `0x0A`,
`0x1F`, or `0x20`, while `0x1E` is source-only and routes to Area 2 node
`0x14`.

This is not yet a linked retail-program theorem.
`Area1StockPreapplyProjectionSound` remains an explicit premise: live Clight
memory must be shown to project every relevant owner, query, and platform
origin into the finite model.  Dynamic-surface construction, list order, and
actual `find_floor` selection also remain open, as do constructions outside
the bounded owner relation and the later JP destination-area lifetime.

`JPSlotLifetime.v` checks allocation, unload, free-list, and delayed-warp
source anchors, proves that the packed Area-2 macro list has 50 records, and
proves the corresponding finite LIFO and clean-slot case splits.
`JPFirstApply.v` now separates the true first destination application from the
later input-poll fixture boundary and checks the conditional fresh-load counts:
84 allocations without a saved cap, 85 with one.  The source audit places
Spindel at allocation 64/free-list depth 63.  These arithmetic and chronology
theorems now agree with the conditional midpoint runtime observation: the top
is freed at depth zero, teardown pushes 131 slots, 84 destination allocations
leave it at depth 47, and the retained payload changes Mario at the true first
Area-2 application.  `JPLifecycleTrace.v` checks that finite arithmetic and the
copied observation record.  It does not extract an ordered linked-Clight
allocation/free trace or prove pointer/epoch lineage from a clean run.  The
retail instruction receipt is now confirmed separately: JP entry `0x802c83f0`
at timer 515 sees all three Mario views at spawn and the stale pointer at depth
47; caller return `0x8029cfc8` sees only State displaced.  Refining that call in
linked Clight remains open.

For a family-by-family, globally ranked account of every active and retired
route idea, see the readable
[`docs/no-a-route-atlas.md`](docs/no-a-route-atlas.md).  For a
software-engineering-oriented explanation of the game state, the two route
gates, the exact proved reductions, and the contribution of each archived
project, see [`human-readable-proof.md`](human-readable-proof.md).  The precise
formal boundary for routes outside the transcript is in
[`docs/notes/route-exhaustiveness.md`](docs/notes/route-exhaustiveness.md), and the focused
PU/top source audit is
[`docs/notes/pyramid-top-pu.md`](docs/notes/pyramid-top-pu.md).  The narrower checked
surface and JP slot boundaries are documented in
[`docs/notes/pyramid-top-surface-refinement.md`](docs/notes/pyramid-top-surface-refinement.md)
and [`docs/notes/jp-slot-lifetime.md`](docs/notes/jp-slot-lifetime.md).  The authenticated
retail instruction receipt is
[`docs/notes/retail-find-floor-cast.md`](docs/notes/retail-find-floor-cast.md).
The corrected first-apply chronology, exact fresh allocation table, and
installer split are in
[`docs/notes/jp-first-apply.md`](docs/notes/jp-first-apply.md).
The exact timer-131 surface and the conditional lifecycle trace are
[`docs/notes/timer131-surface.md`](docs/notes/timer131-surface.md) and
[`docs/notes/jp-lifecycle-trace.md`](docs/notes/jp-lifecycle-trace.md).
The focused ordinary-motion proof boundary is
[`docs/notes/ordinary-motion.md`](docs/notes/ordinary-motion.md).
The three-view graphical fallback result is
[`docs/notes/ink-fallback.md`](docs/notes/ink-fallback.md).
The corrected Goomba/PU/Spindel investigation is
[`docs/notes/goomba-raising.md`](docs/notes/goomba-raising.md).
The finite-alias, failed-cast, and State-first boundary is
[`docs/notes/area1-nonlocal-endpoints.md`](docs/notes/area1-nonlocal-endpoints.md).

## Exact target and input definition

The pinned source names the edge field `Controller.buttonPressed` and the held
field `Controller.buttonDown`.  `read_controller_inputs` computes:

```c
buttonPressed = current & (current ^ previousButtonDown);
buttonDown = current;
```

Thus "fewer than one A press" is `fewer_than_one_a_press inputs`, defined as
`Forall frame_has_no_a_press inputs`, where bit 15 of the finite-width
`Int.and current (Int.xor current previous)` value is false on every modeled
frame.  A may be held at entry: `held_a_at_entry_is_permitted` proves that
`previous = current = A_BUTTON` has no edge while `A_BUTTON_DOWN` is true.

The behavior-parameter star indices are zero based.  The pinned source and
generated initializers establish:

- Act 3, "Inside the Ancient Pyramid": index `2`;
- Act 6, "Pyramid Puzzle": index `5`;
- the 100-coin star: index `6`, hence it aliases neither target.

"Newly collected" is the finite-width predicate:

```coq
Definition newly_collected initial_flags final_flags index : Prop :=
  Int.testbit initial_flags index = false /\
  Int.testbit final_flags index = true.
```

## Clean entry

`CleanPyramidEntry` constrains the supported version (`VERSION_US` or
`VERSION_JP`), SSL level and course, valid act, area 2, selected lower or upper
entrance, both active target bits initially clear, coherent active/backup
target bits, all five Puzzle triggers unconsumed, no pre-existing Act 3 or Act
6 substitute star, the designated static Act 3 star and hidden-star controller,
five distinct designated macro-trigger objects, target/trigger provenance,
per-trigger macro-respawn state equal to the consumed-trigger history, abstract
object-pool/list well-formedness flags, no pending star interaction or delayed
exit, coherent controller history, and version-specific Mario platform state.

The entry snapshot now distinguishes the two source objects exactly: lower
warp node `0x0A` at `(0, 300, 6451)` and upper warp node `0x14` at
`(0, 5500, 256)`, both facing 180 degrees and entering with the finite-width
`ACT_SPAWN_NO_SPIN_AIRBORNE` action (`0x1932`), zero Float32 velocity, and zero
Float32 forward velocity.  Current kinematics must equal that snapshot at the
chosen model boundary.  The designated Act 3 object is fixed at
`(500, 5050, -500)` with the source star hitbox.  The hidden-star controller is
fixed at `(900, 1400, 2350)`; an Act 6 star has that controller as parent and
that point as its home position, while its current position may change during
the spawn animation.  Each trigger carries its exact macro identity, Float32
position, trigger hitbox, and clear object/macro respawn state; in particular
the upper trigger is `(260, 3913, -600)`.  The concrete floor reference and its
projection from surface memory remain abstract.

It does not assert that Mario cannot reach either collision region.  The
abstract state represents `gMarioPlatform` by an intended object-pool slot plus
a ghost capture epoch used to distinguish allocation identities; no Clight
memory projection to that representation has yet been proved.  A null pointer
is `None`; a non-null pointer satisfying `raw_platform_slot_well_formed` is
exhaustively classified as live at the ghost epoch, inactive at that epoch, or
reused at a different epoch.  The ghost epoch is not yet proved to equal the
epoch at which the C pointer was captured.  US clean entries require `None`.
JP entries permit all four cases, so the separate JP upper obligation must
handle elevator containment and spawning displacement for each case.  The AST
checks establish a direct `clear_mario_platform` call in the US spawn body and
its absence from the JP body; an execution-level clearing/retention theorem is
pending.  The abstract clean-state predicate by itself does not prove that a
JP non-null pointer has a stock predecessor.  The concrete Clight nonvacuity
obligation consequently asks for actual projected clean runs rather than
claiming that every handwritten clean state is source-reachable.

This distinction matters for a model-only JP candidate: an inactive,
unreused pyramid-top slot with yaw delta `0x1800` can displace the abstract
upper-entry Mario state from `(0, 5500, 256)` to approximately
`(365.593, 5500, -1096.803)` with no A edge.  The payload and displacement
formula are source-shaped.  An older authentic-JP fixture installed the raw
payload at the first Area-2 input poll and therefore exercised the second
application.  The stronger current fixture injects the timer-131 three-view
  prestate in Area 1.  Retail execution then captures the live top, frees it at
  explosion, retains its slot through the delayed warp, and applies the stale
  payload at the true first destination application.  With no A held or pressed,
  the current route consumes all five hidden triggers and spawns the Act-6 star.
  A refined B/Z continuation overlaps that star by one vertical unit and changes
  the authentic JP save byte from `00` to `20`, while every A counter remains
  zero.  This is a conditional target-bit trace, not a stock-game
  counterexample: the timer-131 three-view prestate is injected and has no
  clean retail installer.  There is no Act-3 overlap.  The same payload prepared only while
an unrelated numerical slot 60 object remains in Area 1 is cleared by depth-7
reuse as macro object #5 and produces no displacement.  That test does not
reproduce a top freed before bulk unload and its 30 fragments.  No clean stock
installer for the three-view prestate has been established.

The conditional source path uses Area-1 warp node `0x1E` and arrives at Area-2
node `0x14`.  In the arithmetic model, one synchronized sample cannot satisfy
both warp contact and top-height platform proximity: the parsed source mesh has
a minimum vertex world Y of `1281`, the modeled platform predicate requires
Mario Y above `1277`, and the warp ends at Y `818`.  Under an explicit
Y-preservation premise, a stock-yaw transform also cannot make the numeric
floor query accept that height.  Deriving the floor bound and Y preservation
from Clight execution remains open.

The source order permits three independently sampled coordinates.  Object
collision can read the old Mario Object at the warp; geometry can first query
State `(-2200,768,-1024)`; if that query returns `NULL`, the source copies
Graphics into State and retries.  The older local
`(-2048,1791,-1024)` and PU `(63488,1791,-1024)` samples are useful abstract
three-view witnesses, but the exact raised/rotated timer-131 top rejects the
home point.  The corrected strict-interior midpoint is
`(-1862,1778,-902)`.  A non-null retry lets the cached warp select and execute
`ACT_DISAPPEARED` usefully in that frame.  In the retry-null case an accepted fatal request wins the
handwritten event-system latch when it is empty at that call.  The event
invariant proves that fatal then persists or a reset destroys the old
continuation.  Linked retail refinement remains open: it must establish fatal
acceptance, concrete event coverage, clear/reset barriers, and the latch-memory
frame condition.  The action
snaps to the retry floor before the
unconditional quicksand sink and state/object copy.  Remaining object lists
then update, deactivated objects unload, and only then does the final platform
query run.  `InkFallback.v` evaluates the handwritten pipeline's coordinate
arithmetic and proves that its projected Graphics-position sink cannot change
the copied Object coordinate.  The source can also write `gfx.throwMatrix`,
  and the source order admits an explosion-frame unload after the top's
  collision-loader callback but before final capture.  `Timer131Surface.v`
  computes the translated/rotated midpoint surface, and the injected JP run
  observes the first-query miss, loaded-top retry, and later retention.  The
  project does not prove that a clean run reaches that prestate or execute the
  branch in linked Clight.  The original sink interface was false and its
repaired first-return form is open; the post-copy lifecycle interface is
invalid and must be replaced.  Prestate reachability in Clight remains open.

Ink's graphics gap is therefore one possible **payload installer** inside the
JP stale-platform route, not a separate final route.  A timed version must see
the spinning top at timer `131` on the warp-collision frame, run spinning timer
`150` on frame 19, and run explosion timer `0` on frame 20.  The timer-131 top
is raised and rotated: exact binary32 arithmetic rejects the old home-pose
Graphics Y=`1791` witness, accepts the midpoint, and proves that the midpoint
needs at least `960` units of Graphics/Object Y separation (`1010` at the warp
centre).  `JPInstallTimerWindow.v` proves timer 131 unique for the observed
affine schedule, not for an independently derived linked execution.  Other installers remain possible in the
classification: a State-first top query, physical warp/top co-location or
collision-preserving cloning, post-commit transport, capture of another
dynamic owner, or a skipped-query frozen carry.  None is proved reachable or
collectively exhaustive for linked retail execution.  `InkPayloadInstaller.v`
formalizes the two independent finite taxonomies, the timer arithmetic, and the
conditional owner/slot composition while leaving the linked-Clight installer
coverage obligations open.

The older two-sample countermodel still checks a 1023-unit State Y change,
exact CompCert casts, dynamic-partition cells, generated triangle indices, the
manual zero-yaw home vertices linked to that parsed face, all three
hand-mirrored edge tests, and numeric floor-query admissibility.  Importing
`math_util.c` and `surface_load.c` closes the missing function-body coverage,
but no theorem yet executes those bodies over linked live object/surface memory,
proves list ownership/order, or proves the actual Clight `find_floor` traversal.
The conditional midpoint probe observes a top-owned selection in the authentic
JP runtime; its Rocq record is evidence, not a semantic refinement theorem.
The exact casts are independently confirmed by the byte-identical retail
US/JP `trunc.w.s; mfc1; sh; lh` sequence.  The three-view theorem sharpens the
necessary writer boundary: signed-range Graphics must be at least 385 units
above the warp-overlapping Object.  Prefixes already refined to State-only
cannot manufacture their split from synchronized input.

The Area-1 source contains a real candidate primitive: breakable-box and
exclamation-box triangle fragments write nonzero pitch angular velocity, and
one exact-binary32 payload changes MarioState in all three dimensions by
amounts whose Y component exceeds the signed-range 385-unit necessary bound.
For the
breakable-box path, an object count above 210
suppresses the preceding mist allocation, making the first triangle allocation
a concrete source-backed slot-reuse candidate.  The concrete transform uses a
different, middle-wing-cap-box pivot at `(-3000,640,800)`; those subcases are
not claimed as one reachable trace.

Nor is `[top, box]` a unique allocator route.  The generic source audit
classifies pyramid-top yaw, dirt-triangle pitch/yaw, and cartoon-triangle pitch
as the three stock pre-apply angular payload classes.  Free-list depth,
`20`/`10`/`0` mist branches, zero-angular allocations, and FIFO eviction create
many schedules within those classes.  `Area1PlatformExhaustiveness.v` makes
their controller lineage irrelevant only to the bounded **pre-existing
platform-origin** classification: all fifteen owners in the finite model are
geometrically excluded there, so every modeled stock pre-apply platform origin
is null at warp overlap.

That result does not exclude post-collision graphical rescue, which can begin
with a null pointer and capture the top after the retry.  Reachable
writer/action closure, first-query `NULL`, loaded top-owned retry selection,
and the repaired sink-memory refinement remain Layer-B obligations.  The
conditional midpoint probe observes those query outcomes and the later
post-copy object/surface lifecycle after debugger installation, but the old
lifecycle statement must still be replaced before it can be a valid linked
obligation.  The linked-Clight projection is open.  JP pointer retention through
the delayed warp is now observed at that injected boundary, while proving that
moving/loading the
warp onto the top, moving the top to the warp, collision-preserving cloning,
graphical rescue, and direct post-query pointer/object writers either fall
inside a proved relation or are unreachable.
The checked 50-record macro count, fresh conditional 84/85 allocation census,
and LIFO recurrence match the observed early-free depth zero, depth 47 at first
apply, and exact consumed payload.  They do not prove the linked allocation
trace or pointer/epoch lineage.  The authentic instruction-entry/return
first-apply receipt is confirmed; its linked Clight refinement remains pending.
The US state model blocks retaining the same epoch after a successful
spawn clear, whose Clight memory effect remains pending.  The proof must not
rule these cases out by strengthening clean entry to assume a null or harmless
pointer.

## Proof architecture and exact proved theorem

The current Layer A staging has four parts:

1. `ClightFacts.v` proves decidable source-shape facts over the generated US
   and JP Clight ASTs: identifier, constant, assignment-shape, direct-call, and
   direct-callee-order observations.  It now checks syntax anchors for the
   signed-16 floor casts, MarioState/MarioObject fields, warp/floor-snap
   pipeline, delayed warp, and stock-top yaw writes.  The field-slot recognizer
   is base-insensitive and the literal/order checks are path-insensitive; the
   actual update pipeline is established here by direct pinned-source
   inspection, not by these AST theorems.  They do not prove operand dataflow,
   branch control dependence, loop execution, or memory effects.
   `PyramidTopSurface.v` additionally checks the exact generated cast prefix,
   CompCert cast values, matrix/surface helper availability, the parsed-face
   link to manually translated zero-yaw home vertices, hand-mirrored transform
   and face-edge arithmetic, and the existence of a guarded dynamic-floor
   assignment source shape.  The last check is not an exclusivity or full
   update theorem.  These results still stop before linked memory execution or
   actual surface selection.
2. `SourceExhaustiveness.v` provides an executable finite inventory of the
   seven normal SSL star sources and the target-save writers.  It proves that
   the normal non-target sources at indices `0`, `1`, `3`, `4`, and `6` cannot
   alias indices `2` or `5`, that a coherent backup reload cannot newly set
   either target, and that an anomaly-free first target-bit transition comes
   from the uniquely matching normal target source.  Completeness of this
   inventory for Clight executions remains an explicit refinement obligation.
3. `AreaTransitions.v` names abstract certified frame events for object
   spawn/deactivation, pool-slot reuse, macro respawn, unload/reload, area 2/3
   instant warp, collision refresh, save reload, Mario motion, and collection.
   Ordinary administrative events can no longer silently change Mario's
   kinematics; motion has explicit endpoint snapshots, the modeled area-2/3
   instant warp preserves the kinematic core, and save reload copies the
   coherent backup flags.  Trigger consumption marks the corresponding macro
   state consumed and leaves no active trigger of that kind; reload and macro
   respawn preserve that absence in the abstract semantics.  Full C effects
   are still not encoded for every lifecycle label.
4. `StarCollection.v` and `HiddenStar.v` prove collection and provenance
   reduction by inversion over those constructors.  The constructors already
   require the relevant origin, overlap, target-bit, trigger, and successor
   well-formedness facts; deriving those facts from Clight remains open.

`ArchivedProofIntegration.v` proves the separately audited theorem:

```coq
Theorem archived_proof_integration_kernel_holds :
  ArchivedProofIntegrationKernel.
```

Every generated-source field in this kernel is reproved against this
project's pinned US and JP Clight modules.  No archived Rocq namespace or
generated file is imported.  The six archive-derived components have the
following deliberately limited force:

- `ssl-spawning-displacement-proof` contributes current AST occurrence/call
  facts around `gMarioPlatform` and the US/JP platform-clear-call split, not a
  pointer dataflow theorem, containment, or reachability;
- `ssl-pyramid-item-proof` contributes current unload/load ordering,
  `_next`/`unload_object` source occurrences, and allocation-epoch identity
  facts, not loop execution or a Clight execution-to-event refinement;
- `ssl-parallel-universe` contributes current movement-source shape checks,
  the held-A edge fact, and a bounded static-quarter-step alias lemma, not a
  complete inventory of position writers;
- `pole-bypass` contributes current pole/action/gravity source-shape checks
  and a mathematical-integer normalized soft-bonk bound, not complete
  Float32 collision-phase coverage;
- `eyerok-manipulation` contributes current Eyerok lifecycle and platform
  recomputation source-shape facts, not its archived height-model refinement;
- `demo-warp` contributes the revision-neutral CompCert fact that a store can
  change a load only in the same memory block, not a proof of demo/Mario block
  provenance or reachable aliasing.

`RouteEvidence.v` contains only the narrow held-A, parallel-universe,
normalized-pole, and demo-memory lemmas named above.  Its `legacy_` relations
are regression certificates with explicit hypotheses, not simulations of the
linked game.  `MainTheorem.v` imports the integration module so it is on the
project build path.  The theorem
`current_verified_evidence_and_collection_reduction` combines the kernel and
event reduction as a conjunction; it deliberately proves no semantic bridge
between them and does not use the kernel as a substitute for refinement or
reachability.  See
[`docs/notes/archived-proof-evidence.md`](docs/notes/archived-proof-evidence.md) for the
project-by-project evidence boundary.

`TranscriptRouteModel.v` separately formalizes the route argument extracted
from the supplied transcript and the task's stronger post-gate completeness
proposal.  Its target nodes are the Act 3 interaction region and the upper
hidden-star trigger, not save-bit updates.  It selects the exact first target
observation, constructs the route/event prefix through it, and proves:

```coq
Theorem first_target_access_requires_gate_a_or_explicit_bypass :
  forall initial trace,
    FirstTargetCutClassificationObligation initial trace ->
    reaches_any_target_region trace ->
    exists region target_frame target_observation,
      first_target_observation_at
        trace region target_frame target_observation /\
      ((state_entrance initial = UpperEntrance /\
        (gate_a_press_precedes_exact_target trace ElevatorJumpOutGate
           region target_frame target_observation \/
         exists witness,
           upper_bypass_precedes_exact_target trace witness
             region target_frame target_observation)) \/
       (state_entrance initial = LowerEntrance /\
        (gate_a_press_precedes_exact_target trace SecondPoleJumpOffGate
           region target_frame target_observation \/
         exists witness,
           lower_bypass_precedes_exact_target trace witness
             region target_frame target_observation))).
```

The bypass values are finite entrance-specific class tags naming:
platform displacement; object pushes or moving geometry; warp/area 3;
collision clips or tunneling; parallel-universe/out-of-bounds movement; target
relocation or substitution; macro/object-lifecycle anomalies; save reload or
corruption; and memory or undefined behavior.

`first_target_access_with_all_bypasses_excluded_requires_a_edge` proves that
the same coverage premise plus absence of all tags entails an A edge.
`no_a_first_target_access_requires_explicit_bypass` proves that a no-A trace
reaching its first target must contain a tag before that target.  Tags are not
executable witnesses.  These theorems answer the route question only as
logical bookkeeping: the broad
`FirstTargetCutClassificationObligation` already assumes gate-or-tag coverage
and is not yet derived from the collision mesh or Clight.

`FirstTargetRefinement.v` makes the intended replacement precise.
`ClightFrameEvidence` binds a classification to the actual before/after
Clight states, a prefix/segment/suffix trace decomposition, projected
before/after game states, and the exact indexed certified step.
`MotionCrossesCollisionCutEvidence` uses finite static support references,
dynamic object references, and binary32 open cells to witness a source-side to
target-side crossing.  The event writer inventory is total and includes an
ordinary Mario/static-geometry class that the historical nine tags omitted.
The proved reductions eliminate, within the certified event semantics:

- direct displacement by the zero-offset area-2/area-3 instant warp;
- target identity/provenance anomalies at certified collection steps;
- invalid hidden-star macro/controller lifecycle steps;
- coherent save reload as a new target-bit writer; and
- projection mismatch once an indexed frame certificate exists.

The bounded static quarter-step lemma closes only one coordinate-alias
subcase.  Ordinary Mario/static-support motion, platform displacement, object
or moving geometry, clips/tunneling, general coordinate aliasing, and normal
reload/entry motion remain open.  Thus
`EvidenceBearingFirstTargetCutClassification` is a specification to construct,
not a completed US/JP classification.  The proved target-bit bridge goes in
the sound direction: aligned newly collected bits imply the corresponding
target-region cut; it does not claim that reaching a region collects a star.
`evidence_classifier_with_open_writers_closed_blocks_new_target_bits` then
blocks both target bits under the evidence-bearing classifier and
`OpenRouteWriterClassesUnreachable`.  It does not prove the older
`FirstTargetCutClassificationObligation`.

`FirstCrossingWriterCoverage.v` supplies the corrected next layer:

- `an_unvalidated_cut_can_place_one_state_on_both_sides` is a checked
  counterexample to treating every cut descriptor as a separator;
- `FirstValidatedCutCrossingAt` records source and non-target membership for
  its actual projected initial state and binds the minimal crossing to one actual
  `ClightFrameEvidence` segment, star-orders it before a matching target-event
  segment, supplies ordered evidence for every earlier index, and requires
  source/target separation at its actual endpoint, without pretending
  arbitrary `GameState` field combinations are collision-coherent;
- `validated_pre_target_first_crossing_writer_coverage` proves that a
  changed-position non-target event is classified by one of five abstract
  position-writer labels, while an unchanged-position crossing changes its
  floor/platform selection;
- nonspatial admin events preserve Mario kinematics, and a changed
  `EventAreaReload` returns to the modeled entry snapshot;
- the older universal `EntranceCollisionCutEntryContract` remains only a
  conditional reload helper; actual retail construction must instead prove
  the restored snapshot's target exclusion in the projected run; and
- local successful X/Y/Z cast-domain membership excludes the existing
  coordinate-alias witness.

`no_a_complete_writer_exclusions_rule_out_validated_first_crossing` composes
six explicitly named motion/domain exclusions plus the newly exposed
support-selection exclusion for a clean entry and selected target-cut family.
It
is a proved implication; none of those predicates, nor
`FirstValidatedCrossingConstructionObligation`, is discharged for the retail
programs.  Crossings inside the same frame as the target collision still
require ordered sub-frame control points.

`PyramidTopSurface.v` and `PyramidTopPU.v` supply separate admission-free
surface/arithmetic kernels.  They prove the same-sample vertical contradiction
and conditional Y-preserving stock-yaw exclusion, then prove a concrete
two-sample coordinate model at `(-2048,768,-1024)` and
`(63488,1791,-1024)`.  The checked bundle includes exact packed US/JP
LevelScript and mesh data, generated helper bodies, concrete CompCert casts,
partition cells, the selected face's parsed-to-manual zero-yaw home-vertex
link, hand-mirrored transform/edge arithmetic, and a guarded dynamic-floor
assignment source shape.  Authenticated retail US/JP disassembly plus Rocq
fragment arithmetic closes the exact three candidate conversions, but does
not establish a general retail compiler refinement.  Linked memory execution,
dynamic-surface ownership/list order, and actual `find_floor` selection remain
open.  The bundle is not a stale-slot or reachable ROM execution, and its
generic three-dimensional-writer question is not globally resolved by the
source-bounded owner boundary described next.  `InkFallback.v` adds the missing
Graphics sample and proves that a prefix already refined to State-only
preserves both Object and Graphics.  A writer execution whose positive
Graphics/Object Y gap stays at most the conservative bound `208` cannot meet
the required gap above `384`; proving that every retail writer belongs to that audited relation is
still open.  The linked-memory projection and JP delayed-warp lifetime remain
named obligations.

`Area1PhaseSplit.v` then refines the three-dimensional-writer question without
claiming a stock trace.  `area1_fragment_writer_source_checked` checks the
triangle-fragment angular payload fields,
`concrete_area1_fragment_displacement_is_route_sized_3d` evaluates one concrete
CompCert binary32 transform.  `Area1SurfaceWitness.v` proves its short query is
`(-2350,1878,-714)`, the mirrored transformed-top face has edge values
`[207669,313344,2763]` and height `1483.603515625`, and a checked static face
has edge values `[2460,77749,76821]` and height `1280`.  These are candidate
arithmetic, not a live-list selection theorem.  The theorems
`captured_top_epoch_cannot_bootstrap_upper_warp_collision` and
`captured_top_epoch_cannot_realize_route_relevant_phase_split` exclude the
ordinary captured-top epoch as the node-`0x1E` bootstrap in the finite phase
model.

`Area1PlatformExhaustiveness.v` broadens that result from one epoch pattern to
a finite source-bounded stock owner relation.  It proves a fifteen-constructor
inventory, generated-source records supporting the fixed and regular surface
owners, horizontal exclusion for every modeled non-top owner, the top's
vertical exclusion, and `stock_area1_upper_warp_preapply_platform_null` for all
four bounded pre-apply origin classes.  The concrete fragment remains proof that a genuine
three-dimensional payload exists, but its object-count, RNG, and free-list
controller lineage is no longer a Layer-B obligation for the bounded pre-apply
origin theorem: even a reachable stock
schedule cannot retain a non-null **pre-apply** owner at the required collision
sample in this model.  This says nothing about a graphical retry followed by a
new final capture.  A linked small-step proof must still establish
`Area1StockPreapplyProjectionSound`, including live surface ownership/list
selection and the platform/collision memory loads, and separately discharge
the Ink fallback's writer and two-query obligations.

`JPSlotLifetime.v` proves a source-and-finite-list boundary for that lifetime
question: the checked JP bodies have the expected load-before-spawn,
unload/deallocate, free-list push/pop, allocation-clear, and first-update
anchors; the Area-2 macro stream contains 50 records; and, if the watched slot
is freed before the modeled bulk release, the generic LIFO recurrence places
it at exactly that bulk prefix's depth.  The exact reachable allocation trace
is still open, and `JPCleanUpperPlatformApplyMemoryRefinementObligation`
requires the concrete payload loads given a proved-first clean JP upper
Area-2 platform-apply control point.
Before/At/After allocation-count cases remain explicit.  Identifying that state
as the first destination-area apply is itself part of the pending refinement.

The older, coarser transcript contract also proves:

```coq
Theorem no_a_target_access_requires_gate_bypass :
  forall initial trace,
    TranscriptRouteGateModel initial trace ->
    fewer_than_one_a_press (route_inputs trace) ->
    reaches_any_target_region trace ->
    (state_entrance initial = UpperEntrance /\
       elevator_escape_observed trace) \/
    (state_entrance initial = LowerEntrance /\
       above_second_pole_observed trace).
```

The stronger
`no_a_target_access_requires_preceding_gate_bypass` theorem retains concrete
frame indices and proves that the selected bypass occurrence precedes the
selected target occurrence.  The capstone-facing corollary above drops those
indices after preserving the existence of the bypass.

It also proves that excluding both bypass observations on a supplied trace
forces an A edge in that route model.  Under explicit `UpperDownstreamCompleteness` or
`LowerDownstreamCompleteness` premises, a spawning-displacement escape or a
no-A state above the second pole yields separate no-A continuations to the two
target regions.  Those premises avoid claiming both stars are collected in one
course visit.

The `above_second_pole_observed` predicate is retained only as a historical
transcript node.  It is not the final lower collision cut: the pole grip top is
at Y `4020`, while the target-side support ring is at Y `3942` and the upper
Puzzle trigger is at Y `3913`.  A correct lower proof must classify first
collision-phase entry into the enumerated target-side support and
`AxisAlignedOpenCell` component around the pole hole (the historical type's
current predicate uses closed bounds), not use `marioY > 4020` or an informal
floor number.

Each route frame pairs its input with that frame's ordered observations.
`RealizedRouteTrace` additionally requires an abstract `CertifiedExecution`
with the same frame count and backs target observations by same-index Act 3
collection or upper-trigger-consumption events.  This rules out a bare appended
target label, but remains an abstract event certificate rather than a Clight
execution refinement.

`TranscriptRouteGateModel`, global US/JP bypass closure, both
downstream-completeness premises, `FirstTargetCutClassificationObligation`,
and the projection from Clight frames to synchronized route observations are
**not proved**.  Thus these are checked logical cut/classification lemmas, not
a proof that either contract exhausts target-ROM behavior.  An authentic no-A
elevator escape, target-side lower-cut crossing, or other bypass constructor
would refute the respective closure claim; it would become a zero-A
target-route capability only after downstream continuations are validated.

The fully proved result is an abstract event-reduction theorem:

```coq
Definition CollectionProvenanceReductionClaim : Prop :=
  forall initial events final,
    CleanPyramidEntry initial ->
    CertifiedExecution initial events final ->
    (newly_collected
       (state_save_flags initial) (state_save_flags final) act3_index ->
      exists star phase,
        In (EventCollectAct3 star phase) events /\
        active_star_or_key act3_index star /\
        object_origin star = StaticAct3PyramidStar /\
        act3_star_interaction_region phase star) /\
    (newly_collected
       (state_save_flags initial) (state_save_flags final) act6_index ->
      (exists star phase,
        In (EventCollectAct6 star phase) events /\
        active_star_or_key act6_index star /\
        object_origin star = PyramidHiddenStarController /\
        overlaps_object phase star) /\
      (exists spawned_star,
        In (EventSpawnAct6 spawned_star) events) /\
      all_five_trigger_consumption_events events /\
      (exists trigger_object phase,
        In (EventConsumeTrigger TriggerUpper trigger_object phase) events /\
        upper_hidden_trigger_overlap phase trigger_object)).

Theorem collection_provenance_reduction :
  CollectionProvenanceReductionClaim.
```

Within `CertifiedExecution`, it proves:

- a new Act 3 bit requires collection of an active index-2 star-or-key object
  carrying the handwritten static-Act-3 origin tag, designated allocation
  identity, exact static position, and an abstract registered interaction
  overlap;
- a new Act 6 bit requires an active index-5 star-or-key object with hidden
  controller origin tag;
- the trace contains an Act 6 spawn and a collision-backed consumption event
  for each of the five abstract trigger labels;
- the trigger event labeled `TriggerUpper` uses the designated trigger
  allocation, macro-origin/kind, and exact upper-trigger position, and has an
  abstract registered player/object overlap in its collision phase.

The handwritten collision predicate uses CompCert `Float32` subtraction,
multiplication, addition, square root and comparison over projected positions,
radii, and vertical hitbox bounds.  It also requires collision-list capacity,
target reference/epoch equality, equality with a designated abstract player
reference, area, instant-warp state, and update-phase flags.  No theorem yet
projects these fields from the generated Clight state.  The abstract upper
trigger is now connected to one designated reference and the exact macro
position, but proving that reference is the concrete spawned macro object is
part of the missing projection.

Layer B is split into `LowerEntranceReachabilityObligation`,
`UpperUSReachabilityObligation`, and `UpperJPReachabilityObligation`.  They
range over the explicit `project_collision_observations` stream of an imported
Clight run, rather than merely over collection event labels.  The refinement
certificate requires target collection and trigger-consumption events to occur
in that observation stream.  A concrete, complete collision projection is
still pending.  Given those propositions, the project proves the following
exact conditional statement:

```coq
Theorem conditional_less_than_one_a_press_impossibility :
  forall projection,
  LowerEntranceReachabilityObligation projection ->
  UpperEntranceReachabilityObligation projection ->
  forall run initial
      (certificate : ClightFrameRefinementCertificate
        projection run initial),
    CleanPyramidEntry initial ->
    fewer_than_one_a_press (project_inputs projection run) ->
    ~ newly_collected
        (state_save_flags initial)
        (state_save_flags
          (refined_final_state projection run initial certificate))
        act3_index /\
    ~ newly_collected
        (state_save_flags initial)
        (state_save_flags
          (refined_final_state projection run initial certificate))
        act6_index.
```

The newer target-bit-to-route capstone exposes its three independent residuals
directly:

```coq
Theorem conditional_evidence_bearing_clight_run_impossibility :
  forall projection,
    WholeProgramClightRefinementObligation projection ->
    EvidenceBearingRouteClassificationRefinementObligation projection ->
    NoAOpenRouteWriterClassesUnreachableObligation projection ->
    forall run initial,
      RunUsesProjection projection run ->
      project_state projection (run_start run) = Some initial ->
      RunEndsAtSelectedFrameBoundary projection run ->
      CleanPyramidEntry initial ->
      fewer_than_one_a_press (project_inputs projection run) ->
      exists final,
        project_state projection (run_final run) = Some final /\
        ~ newly_collected
            (state_save_flags initial) (state_save_flags final) act3_index /\
        ~ newly_collected
            (state_save_flags initial) (state_save_flags final) act6_index.
```

The first premise contains the whole-program Layer A certificate.  The second
must construct the evidence-bearing first-cut classification.  The third must
exclude all six remaining writer/geometry families under no A edge.  The
theorem is fully proved as an implication; none of those three premises is
currently discharged for the retail programs.

`conditional_target_clight_run_impossibility` additionally consumes
`ObservedSelectedTargetClightRefinementObligation`, a matching run/program and
projected clean start, and returns a projected final state with neither target
newly collected.  That selected-target obligation pins the repaired US or
official cleaned JP program and separately requires the checked original-unit
structural link certificate, an anchored whole-linked-source-to-selected
lockstep, selected-program syntax/symbol audits, controller-authenticated
whole-run chronology, and clean-entry projection coverage.  Runs are scoped to
the next exact `read_controller_inputs` call boundary, independently of the
projection domain.  For projections fixed to the official cleaned JP target,
`JPSelectedTargetAudit.v` now discharges exact program identity, the syntax
audit, and symbol existence for all five `jp_retail_state_global_identifiers`.
Its `jp_selected_target_refinement_from_target_clight` capstone reduces the
official-JP `SelectedTargetClightRefinementObligation` to the still-open generic
`TargetClightRefinementObligation`; it does not construct the observer,
chronology, boundary-to-entry prefixes, or selected-to-retail semantics.  For projections
fixed to `VersionUS` and `us_viewport_repaired_program`,
`USSelectedTargetAudit.v` now closes the separate
`SelectedTargetAuditTransportObligation`: the actual repaired program has no
direct `Sbuiltin`, uses only the supported external constructors, resolves
internal-body `Evar` and initializer `Init_addrof` names, and has a
`find_symbol` witness for each of the five core identifiers.  This supplies no
initialization or memory shape/content/block correspondence, source-to-selected
viewport-repair execution lockstep, boundary-start route/prefix/chronology,
or selected-to-retail semantics.  None of the open semantic witnesses, either
Layer B premise, or a concrete US/JP projection is proved.  Therefore neither
conditional theorem is the ultimate target theorem.

## Source and Clight scope

- Decomp revision: `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
- Versions: `VERSION_US` with `F3DEX_GBI_2` and `F3DEX_GBI_SHARED`;
  `VERSION_JP` with `F3D_OLD`.
- Common flags: `-normalize -nostdinc -fstruct-passing`, project include paths,
  `_FINALROM`, `TARGET_N64`, `NON_MATCHING`, `AVOID_UB`, and `_LANGUAGE_C`.
- Generator: CompCert `clightgen` 3.15.

The current route witnesses are defined Clight `step2` runs.  Successful
out-of-bounds loads/stores, invalid-pointer calls, arbitrary code execution,
post-undefined-behavior MIPS continuations, DMA, and interrupts cannot appear
in such a run.  This is not a retail impossibility result: upstream CompCert
does not target the N64's MIPS CPU, and real machine code may continue after a
source operation becomes undefined.  Defined in-bounds aliases, wrong logical
object slots, stale pool bytes, and retargeting to another registered function
remain in scope; reachable unresolved externals need a concrete effect or
frame.  See the checked boundary and route triage in
[`docs/compcert-execution-scope.md`](docs/compcert-execution-scope.md).

Thirty-eight translation units are generated for each version, for 76 Clight
modules total: `game_init.c`, `mario.c`, the seven
`mario_actions_{airborne,automatic,cutscene,moving,object,stationary,submerged}.c`
units,
`mario_step.c`, `interaction.c`, `save_file.c`, `object_collision.c`,
`object_list_processor.c`, `behavior_script.c`, `level_script.c`,
`graph_node.c`, `spawn_object.c`, `object_helpers.c`, `debug.c`, `memory.c`,
`mario_misc.c`,
`obj_behaviors.c`, `obj_behaviors_2.c`, `behavior_actions.c`,
`behavior_data.c`, `area.c`, `level_update.c`,
`platform_displacement.c`, `math_util.c`, `surface_collision.c`,
`surface_load.c`,
`macro_special_objects.c`, `levels/ssl/script.c`, project wrappers for
`levels/ssl/areas/1/macro.inc.c` and `levels/ssl/areas/2/macro.inc.c`, plus
`inputs/ssl_collision.c`, a project
wrapper importing the area-1/area-2/area-3 collision arrays and the
route-relevant pyramid-top, tox-box, grindel, spindel, moving-wall, elevator,
Eyerok, breakable-box, exclamation-box-outline, cannon-lid, and
wooden-signpost arrays.  The last four meshes are new inputs to the stock
Area-1 owner-envelope proof.  This expands the imported surface for movement,
entry action dispatch, Mario quarter steps, Eyerok behavior, and
static/dynamic collision analysis.  `clightgen` translates every function and
global definition retained by preprocessing in each whole translation unit;
the proofs inspect only the named functions and shapes listed in the exact
source/function map in
[`notes/source-map.md`](notes/source-map.md).
`CollisionMeshFacts.v` checks all 39 words of the pyramid-top stream and its
five vertex Y values.  It also proves exact generated local X/Y/Z bounds for
the breakable-box, exclamation-box-outline, cannon-lid, and wooden-signpost
meshes in both versions.  The larger area arrays are not yet parsed into a
surface graph.

The status-facing documents are `docs/checklist.md`, `docs/claim.md`,
`docs/goal.md`, the execution-model boundary
`docs/compcert-execution-scope.md`, and the reader-oriented
`docs/no-a-route-atlas.md`.  Detailed
investigation records and technique-specific material live under `docs/notes/`;
this keeps current claims separate from supporting research notes.

## Build and regeneration

With Rocq 8.16.1 and CompCert 3.15 available:

```sh
make check
```

This builds all committed generated modules and proofs, rejects proof-hole and
unconstrained-declaration keywords in Rocq source, and prints assumptions for
the named integration, reduction, route, and conditional theorems.

Regenerate from a Git checkout containing the pinned commit:

```sh
SM64_SOURCE=/path/to/sm64 make regenerate
SM64_SOURCE=/path/to/sm64 make verify-generated
```

The pipeline exports the pinned commit with `git archive`, so uncommitted files
in the source checkout are not translated.  `verify-generated` requires
exactly 38 modules per version, rejects extra generated `.v` files, hashes the
committed output, regenerates all 76 modules, and requires byte-for-byte
identity.

The command executed per unit is structurally:

```sh
clightgen -normalize -nostdinc -fstruct-passing \
  -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src \
  -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 \
  -Ibuild/pinned-sm64/include/libc \
  -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 \
  -DAVOID_UB=1 -D_LANGUAGE_C=1 VERSION_FLAGS input.c -o output.v
```

## Known limitations and semantic cautions

- `CompCertRouteScope.v` proves the current semantic boundary: every successful
  CompCert load/store requires valid access and every Clight call target is a
  registered function.  The checked route table keeps defined aliases,
  scheduler/owner/lifecycle effects, and known-function retargets active;
  unresolved external calls require a specification; and invalid access, ACE,
  raw post-undefined-behavior execution, DMA, interrupts, and self-modifying
  code are deferred until a retail machine model exists.  Their absence from a
  Clight run must never be reported as proof that the retail ROM cannot perform
  them.  CompCert's supported target architectures do not include N64 MIPS, so
  the selected-Clight-to-retail bridge remains independent of compiler
  correctness.

- `CertifiedExecution` is a contract-style event abstraction.  Collection
  constructors assume the desired origin, collision, save-bit, spawn, and
  trigger facts.  Motion, instant-warp kinematics, target-save reload, route
  context, and static trigger identity now have explicit effects, but other
  lifecycle labels still do not encode their full C effects.  The reduction
  theorem is constructor inversion, not a completed Clight-derived Layer A
  proof.
- Object origins, allocation epochs, the designated player/static-star
  references, hidden-controller parent references, trigger labels,
  macro-respawn bits, entry snapshots, and pool/list validity flags are
  handwritten ghost data.  Their concrete memory interpretation and
  preservation must be supplied by the missing refinement; none is an oracle
  conclusion about ROM reachability.
- Exact selected programs are now provided: the checked whole-AST repaired US
  program and official cleaned JP link.  The former `TargetLinkedProgram`
  requirement over all original units is retained only as a legacy audit
  interface and is not a valid selection gate for their incompatible
  composite bindings.  Original-unit cleaning/header normalization is now a
  checked structural certificate, while execution starts from the whole
  official cleaned source and requires lockstep anchored at matching
  `SelectedRuntimeTaskStart` states.  The JP identity lockstep witness is now
  provided, and the official-JP program/syntax/five-core-symbol selected-target
  audit is checked, reducing the JP selected-target boundary to the generic
  target refinement obligation.  The repaired-US selected-target audit is also
  checked conditionally on `VersionUS` and the exact repaired program, but the
  repaired-US initialization and source-to-selected execution lockstep, a
  concrete `ClightObservationProjection`, and a
  `ClightFrameRefinementCertificate` remain open.  `ImportedClightRun` is a
  finite `Smallstep.star` fragment and is not by itself tied to the selected
  runtime-task boundary or a final state.
- `WholeProgramClightRefinementObligation` and
  `CleanEntryProjectionNonvacuityObligation` are both open.  The latter asks
  for actual projected clean US/JP lower/upper starts; it deliberately does
  not assert the false surjectivity claim that every handwritten
  `CleanPyramidEntry` is source-reachable.  Until a concrete
  projection and certificate are proved, projected inputs, events, collision
  observations, and abstract states are uninterpreted functions.  The checked
  chronology bridge only shows how one fixed observer, concrete authenticated
  gameplay/administrative frames plus silent no-poll chunks, and actual
  nonempty prefixes would discharge these obligations.  Scoped prefixes start
  at `DefaultArea1StartBoundary`; task-entry prefixes belong to the optional
  upstream reachability extension.  The
  interface pins the real controller/pointer cells and exact poll/consumer
  bodies; constructing the observer and classifying the live runs remain open.
- All three Layer B reachability propositions are open.  They are phrased over
  projected Float32 collision observations rather than an informal floor
  number, but completeness of that observation stream is itself part of the
  missing concrete refinement.
- Ordinary motion has not been globally excluded.  The checked jump-kick and
  rollout arithmetic is a non-Wing upper-elevator subkernel, not an action
  inventory or collision-execution theorem.  `GameState` does not yet project
  Mario's flags or cap timer; a Wing-Cap arithmetic countermodel demonstrates
  that the normal `220` bound is not cap-independent, although its `228`
  result remains below the corrected `231` vertical threshold.  Retail cap
  initialization and preservation must still be linked explicitly.
  The lower Z soft-bonk result remains a normalized subcase rather than a
  complete second-pole or static-geometry proof.
  The newer Area-2 cut files authenticate candidate surface inventories and
  prove conditional writer-case reductions only.  Their source components,
  moving-relative/absolute-adapter refinement, collision-phase timing, US/JP
  downstream suffixes, and every clean retail no-A exclusion remain open.
  The Ink audit proves that prefixes already refined to State-only cannot
  create an Object/Graphics split.  Its source audit motivates a dry positive
  Graphics Y target of at most `45`; the conservative generic modeled relation
  uses `208` because a water-pitch term of at most `60` and bob below `148` can
  compose across a water-floor-hit branch.
  `Area1InkWriterCoverageObligation` is a predicate-sensitive schema, not an
  ordinary retail obligation.  It must be replaced by a concrete linked-run
  writer-coverage relation before these bounds become an action-closure
  theorem.  The repaired
  `InkFallbackSinkMemoryRefinementObligation` must justify the real quicksand
  writer to both `header.gfx.pos[1]` and `throwMatrix[3][1]` from a first
  return with disjoint modular cells.  Its predecessor was refuted.
  `InkFallbackPostCopyLifecycleRefinementObligation` must not be used in its
  current form: the projection/link/run interface is unsafe or vacuous and
  importing `behavior_script.c` alone does not resolve the indirect scheduler
  path.  A replacement must use an exact link and clean anchored run, certify the concrete-memory
  projection and pointer/epoch relation, constrain external effects, and
  derive the translated/rotated sample from live Clight memory.  The conditional
  midpoint trace observes free-list membership and the later lifecycle after an
  injected seam, but does not make the unsafe interface valid or prove a clean
  linked-memory execution.
- The transcript route model has no Clight projection or collision-surface
  completeness theorem.  `FirstTargetCutClassificationObligation` makes the
  missing exhaustiveness result explicit and its tag sums make the intended
  historical case vocabulary finite.  Those tags have no state semantics.
  `FirstTargetRefinement.v` defines evidence-bearing replacements, but no
  concrete projection constructs them and the surviving writer classes are
  not excluded.  In particular, the lower cut is first collision-phase entry
  into enumerated target-side supports or closed-bounds binary32
  `AxisAlignedOpenCell` boxes, not “above the second pole,” an informal floor
  number, or a bare Y bound.
- `ArchivedProofIntegrationKernel` is a proved package of current-source facts
  and narrow route lemmas, but it proves neither
  the advertised `ObservedSelectedTargetClightRefinementObligation` nor any Layer B
  premise.  Building or
  auditing the six archives does not transfer their old capstones into the
  current theorem.
- The JP `gMarioPlatform` analysis currently classifies null, live,
  inactive, and reused slots with a ghost capture epoch.  It does not yet prove
  that the abstract slot/epoch was projected from the C pointer, which cases
  are reachable, or the displacement produced by every reachable payload.  In
  particular, the model admits the stale pyramid-top payload described above.
  The Y-preserving stock-yaw arithmetic bootstrap is excluded.  The actual
  matrix and surface-loader bodies are imported; the parsed face is linked to
  manual zero-yaw home vertices, and the exact timer-131 binary32 transform and
  face/cell arithmetic are evaluated.  The old home point is rejected and the
  midpoint's `960`/`1010` gap is proved.  The exact three-input retail cast is verified
  by authenticated US/JP disassembly plus Rocq instruction-fragment
  arithmetic.  The injected JP trace observes live-surface ownership and the
  midpoint retry, but linked memory execution and the actual Clight `find_floor`
  traversal remain open.  `JPSlotLifetime.v` checks the allocation source
  shapes, 50 macro records, and finite LIFO case split; `JPLifecycleTrace.v`
  checks the observed depth/payload record without extracting a clean linked
  allocation/free trace.
  `Area1PhaseSplit.v` checks a real nonzero-pitch triangle-fragment payload and
  exact X/Y/Z displacement with a route-sized Y rise.
  `Area1PlatformExhaustiveness.v` then proves that all stock pre-apply
  platform-origin cases in its finite fifteen-owner model are null when the old
  object overlaps node `0x1E`; `[top, box]` is not treated as the unique
  pre-apply schedule, and generic controller/free-list lineage is no longer
  needed for that finite origin theorem.  A null pre-apply result does not
  exclude Ink's graphical fallback and later top capture.  The linked Clight
  memory projection into the owner model remains open.  Proving source-backed
  prehistory must still cover the fallback's collision Object, first-query
  State, pre-fallback Graphics, first `NULL`, loaded-top retry, sink pointer
  provenance under the repaired first-return interface, a replacement
  post-copy object/owner lifecycle interface, final capture,
  JP delayed-warp retention/recapture, the US clear effect, and warp-to-top,
  top-to-warp, collision-preserving clone, or post-query-writer constructions;
  setting the JP pointer to `None` or assuming every retained displacement is
  safe would not be a valid repair.
- The finite normal-SSL inventory proves unique abstract sources for indices
  `2` and `5` and non-aliasing of `0`, `1`, `3`, `4`, and `6`.  The raw
  initializer/constant checks support the target constants, but no proved
  Clight decoder/coverage result yet connects every relevant
  behavior-parameter bit pattern and spawn path to that inventory or to
  `object_star_index`.
- `AVOID_UB` supplies a zero return for the source's missing-return paths in
  collision helpers.  A manual object-code audit directly found the
  failed-radius return-zero path in JP; US is inferred from an identical
  preprocessed translation-unit hash and the same compiler pipeline, not a
  separately committed US disassembly receipt.  This audit is documented but
  is not yet a Rocq target-code refinement theorem; other
  implementation-dependent or undefined paths still require explicit
  treatment if they become relevant.
- Seven long-double literals in `object_helpers.c` are translated as double so
  `clightgen` can process the unit.  The target collection functions do not use
  those literals, but a formal call-graph irrelevance/refinement proof is still
  pending.
- CompCert 3.15's unmodified `link_list` has now been executed at the
  AST-program and composite-definition layers for all 38 selected units per
  version, and kernel-checked failure certificates are proved for US and JP.
  The first AST failure is the `ssl_script`/SSL-data join; the broader audit
  records 402 US and 401 JP duplicate public variables with unequal generated
  types (principally incomplete extern arrays versus complete definitions).
  Source-owned cleaned US and JP unit lists now have kernel-checked structural
  inhabitants proving that unmodified `link_list` returns the corresponding
  official cleaned target.  Target selection uses the official cleaned JP link
  and the separately checked repaired US program; it does not claim that the
  impossible common-`linkorder` relation over original units holds.  The JP
  source-to-selected identity instance is now checked at a concrete task start;
  its selected-target program/syntax/five-core-symbol audit is also checked.
  This reduces the official-JP selected-target boundary to the generic target
  refinement obligation without proving observer/chronology/prefix or retail
  semantics.  The repaired-US actual-program syntax/five-core-symbol-existence
  audit is now checked; repaired-US initialization/source-to-selected execution
  lockstep, memory shape/content/block correspondence, and both selected-to-retail
  refinements remain open.
  Exact unresolved function-constructor and variable atoms, and the required
  original-to-cleaned refinement, are documented in
  `docs/notes/linked-clight-construction.md`.
- The normalized candidates contain 227 US and 226 JP global `External`
  definitions, but those totals are not all `EF_external`: the exact partitions
  are US `133/75/19` and JP `132/75/19` for
  `EF_external`/`EF_builtin`/`EF_runtime`.  Generated manifests and Rocq checks
  agree on those counts.  Direct `Sbuiltin` external calls are not global
  definitions and are covered by a separate step-inversion theorem.
- Exact-definition provenance now specializes candidate/source-union audits to
  both actual official targets.  Every nonlocal internal-body `Evar` and
  initializer `Init_addrof` occurrence resolves, retained/reachable global
  externals have one of the three supported constructors, and exhaustive body
  recursion proves no direct `Sbuiltin` in either target.  This establishes
  reference and constructor coverage.  Generic relocation-aware initialization
  and relocation-load transport are now proved.  The concrete name-based
  source-to-official initial-memory injection remains open for both versions;
  separately, the official cleaned JP target now has a constructive
  `Genv.init_mem` witness.
- CompCert external-call execution is transported across `symbols_inject` and
  `Mem.inject`, with injected results/memories, growing and separated
  injections, and `loc_unmapped`/`loc_out_of_reach` preservation.  This does not
  supply a frame for writable Mario, object-pool, or controller cells when the
  call is an abstract `EF_external`.  The concrete footprint is now formalized,
  and recognized `EF_builtin`/`EF_runtime` calls preserve it because they leave
  all memory unchanged.  The replacement unresolved-external boundary permits
  a callsite-sensitive protected-cell frame or an explicit writer/lifecycle
  effect.  Its generic reduction and the exact ten-name US/JP dialog/depth
  selected unresolved direct-callee inventory are proved.  Path-sensitive
  reachable call sequences, argument provenance, transitive reachability, and concrete classifications
  are open.  Retail use also still needs the concrete global-
  interface/public-name proof, initial/current memory injections, and the
  expression/internal-step simulations.  See
  `docs/notes/retail-clight-refinement.md`.
- `Print Assumptions` reports the assumptions of named results, and
  `pipeline/assumptions.sh` rejects dependencies declared in this project's
  own logical namespace.  It deliberately permits CompCert's standard
  classical real-number and dependent functional-extensionality foundations
  for the float model.  The project declares no new logical axioms.
- `ModelGapAudit.v` proves that the current endpoint-only certificate still
  accepts arbitrary Mario-motion endpoints and can pair a clean US or JP
  entry with a synthetic immediate Act 3 overlap/collection event.  Separately,
  `endpoint_only_alignment_does_not_imply_cut_classification` shows that
  endpoint/event alignment cannot derive the first-cut classification.  These
  are abstraction counterexamples, not actual ROM traces.  The
  evidence-bearing frame interface states the needed repair, but its
  construction from a linked Clight run remains open.
- A second audit found that an active target bit could be clear while the
  backup slot already held it; the real game-over reload path could then set
  the active bit without a star event in the older abstraction.  Clean entry
  now requires active/backup target coherence, `EventSaveFileReload` explicitly
  copies the backup, and the finite writer theorem classifies incoherent reload
  and corruption rather than hiding them.  This was also an abstraction
  loophole, not a demonstrated clean ROM state.
- No stock-reachable US or JP ROM counterexample has been established.  The
  fixture-assisted JP midpoint run reaches and consumes all five hidden
  triggers, spawns and overlaps the Act-6 star, and records the authentic JP
  save byte changing from `00` to `20` with zero A edges.  It has no Act-3
  overlap.  The missing fact is a stock-reachable predecessor for the injected
  timer-131 three-view setup, so this is a conditional target-bit trace rather
  than a retail counterexample.  Other finite schedules found no target
  witness; neither result is an exhaustive controller-only reachability proof.

The supplied A-press transcript was used only to identify candidate routes and
version-sensitive behavior.  The pinned source and formal definitions control
the claims.
