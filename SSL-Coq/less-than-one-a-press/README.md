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
  proving basic identifier/initializer/type algebra.  The repaired-program
  success certificate and semantic simulation are still open.  A
  composite-table-only repair is insufficient.

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
  recognized builtins/runtime helpers.  Retail use still requires the concrete
  public-name and name-based initial/current `Mem.inject` instances, the US
  whole-expression/internal-step simulation, and writable `EF_external`
Mario/object/controller frame premises.

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

The current clean-JP installer audit found no retail source for that gap.
`CleanJPGraphicsGap.v` defines a clean JP Area-1 audit boundary, proves that
its synchronized Object/Graphics projection starts with zero separation, that
arbitrarily large prefixes already refined to State-only preserve the
separation exactly, and that a trace made from the currently range-certified
writer forms stays below `960`.
`JPGeneratedWriterCensus.v` preserves all 38 unit boundaries and counts the
functions containing direct assignments to the selected coordinate forms:
33 for `pos[1]`, 215 for raw-data slot 7, 180 for raw-data slot 10, and 15
whose assignment LHS mentions `throwMatrix`.  These are receiver-neutral
function counts, not proof that every store targets Mario.  The same census
confirms eight direct `quicksandDepth` writers and six direct automatic-dialog
constructor functions.  `JPQuicksandDepth.v` proves nonnegative depth for a
source-shaped relation that excludes the late long-jump landing writer.  That
writer's ordinary source constructor is under `INPUT_A_PRESSED`; proving that
every real clean no-edge trace refines the safe relation remains open.

`OrdinaryArea1EntryMemory.v` corrects the ordinary outside-desert entry to
node `0x0A`, `bhvSpinAirborneWarp`, and `ACT_SPAWN_SPIN_AIRBORNE`, and defines
a symbol-bound postcondition in which State, raw Object, and Graphics
coordinates are synchronized.  Its source/layout kernel and consequences from
that postcondition are proved.  The live `Smallstep.star` execution, castle
routing, behavior lookup, external-call frames, and complete object-pool/list
ownership remain obligations; JP also preserves, rather than assumes away,
the predecessor `gMarioPlatform` value.

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

This audit also records a conditional countermodel to any naive per-frame
bound: an already-installed `-2.65f` depth retained in the non-reanchoring
automatic-dialog action reaches a zero-base endpoint at least `960.0f` after
363 calls in exact CompCert binary32 arithmetic.  The projected integer model
also records `961.95` from zero.  The live-base arithmetic is now checked for
one relevant candidate: binary32 `768.5f` followed by 381 exact sinks ends at
`1778.1593017578125f`; conversion to the collision integers gives `768` and
`1778`, a gap of exactly `1010`.  Stock signs and NPC-dialog handlers reanchor
Graphics, while star-milestone automatic-dialog call sites mean the action is
not globally absent.  The open question is reachability of the combined
negative-depth, automatic-dialog, unreanchored state, not whether this one
binary32 schedule is large enough.  Linked memory, pointer/non-alias,
complete writer/action provenance, dialog/reanchoring closure, X/Z
preservation, and installation of the negative depth remain open.  A source
review also rejected fire particles as a Mario writer: the callback updates
Mario's `prevObj` flame, not Mario.

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
requires an entrance/entry contract plus
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
edge.  Exact generated elevator-mesh receipts and closed arithmetic put
non-Wing 4-unit-gravity jump kick at most `128` units and a conservatively
supplied rollout on that branch at most `220` units relative to the descending
elevator, below the strict `231`-unit integer-translation wall-rejection
threshold after the dynamic surface's five-unit upper-Y pad.  These bounds
still need Clight action/collision execution, live-surface selection,
intermediate-query, and reachable-action closure.  A retained Wing Cap changes
the rollout result from `220` to `228`: it refutes reuse of the non-Wing
4-unit-gravity bound but remains below the corrected vertical threshold.  The
retail `init_mario` cap reset must nevertheless be connected to the clean-entry
projection rather than silently assumed.  The lower route remains open beyond
the existing normalized soft-bonk subcase.  See
[`docs/notes/ordinary-motion.md`](docs/notes/ordinary-motion.md).

The upper entry also starts at Y `5500`, above the elevator's initial
raw-mesh rim top Y `5222`.  The ascent bounds apply only after a normal landing
in the cage.  Generated source-shape receipts show the no-spin airborne spawn
path repeatedly supplies zero forward velocity before its air step, but no
Clight/collision theorem yet proves that the entry descent is vertical, lands
on the intended live elevator floor, and reaches the prestates assumed by the
ascent kernel.

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

For a software-engineering-oriented explanation of the game state, the two
route gates, the exact proved reductions, and the contribution of each archived
project, see [`human-readable-proof.md`](human-readable-proof.md).  The precise
answer about routes outside the transcript is in
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
- `EntranceCollisionCutEntryContract` requires clean-entry source membership
  and excludes the selected entry snapshot from the target side;
- `FirstValidatedCutCrossingAt` binds the minimal crossing to one actual
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
- a reload crossing is impossible once the linked run preserves the initial
  route context and the entry contract excludes that snapshot; and
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
collision-phase entry into the enumerated target-side support/open-cell
component around the pole hole, not use `marioY > 4020` or an informal floor
number.

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
`TargetClightRefinementObligation`, a matching run/program and projected clean
start, and returns a projected final state with neither target newly collected.
That obligation is the conjunction of whole-run certificate construction and
nonvacuous clean-entry projection coverage.  Neither conjunct, either Layer B
premise, nor a concrete US/JP projection is proved.  Therefore neither
conditional theorem is the ultimate target theorem.

## Source and Clight scope

- Decomp revision: `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
- Versions: `VERSION_US` with `F3DEX_GBI_2` and `F3DEX_GBI_SHARED`;
  `VERSION_JP` with `F3D_OLD`.
- Common flags: `-normalize -nostdinc -fstruct-passing`, project include paths,
  `_FINALROM`, `TARGET_N64`, `NON_MATCHING`, `AVOID_UB`, and `_LANGUAGE_C`.
- Generator: CompCert `clightgen` 3.15.

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

The three status-facing documents remain at `docs/checklist.md`,
`docs/claim.md`, and `docs/goal.md`.  Detailed investigation records and
technique-specific material live under `docs/notes/`; this keeps current
claims separate from supporting research notes.

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
- No concrete `TargetLinkedProgram`, `ClightObservationProjection`, or
  `ClightFrameRefinementCertificate` is provided.  The link record asks for
  `linkorder` witnesses above all 38 units; it does not construct an iterated
  CompCert link.  `ImportedClightRun` is a finite `Smallstep.star` fragment and
  is not yet required to begin at `initial_state` or end at `final_state`.
- `WholeProgramClightRefinementObligation` and
  `CleanEntryProjectionNonvacuityObligation` are both open.  The latter asks
  for actual projected clean US/JP lower/upper starts; it deliberately does
  not assert the false surjectivity claim that every handwritten
  `CleanPyramidEntry` is source-reachable.  Until a concrete
  projection and certificate are proved, projected inputs, events, collision
  observations, and abstract states are uninterpreted functions.
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
  into enumerated target-side supports or binary32 open cells, not “above the
  second pole,” an informal floor number, or a bare Y bound.
- `ArchivedProofIntegrationKernel` is a proved package of current-source facts
  and narrow route lemmas, but it proves neither
  `TargetClightRefinementObligation` nor any Layer B premise.  Building or
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
  official cleaned target.  This is not a completed linked retail execution or
  a `TargetLinkedProgram` refinement.
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
  and relocation-load transport are now proved, but the concrete name-based
  US/JP initialization instance remains open.
- CompCert external-call execution is transported across `symbols_inject` and
  `Mem.inject`, with injected results/memories, growing and separated
  injections, and `loc_unmapped`/`loc_out_of_reach` preservation.  This does not
  supply a frame for writable Mario, object-pool, or controller cells when the
  call is an abstract `EF_external`.  The concrete footprint is now formalized,
  and recognized `EF_builtin`/`EF_runtime` calls preserve it because they leave
  all memory unchanged.  Retail use still needs the global-interface/public-name
  proof, concrete initial and current memory injections, the US
  expression/internal-step simulation, and a frame for every reachable
  `EF_external` effect.  See `docs/notes/retail-clight-refinement.md`.
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
