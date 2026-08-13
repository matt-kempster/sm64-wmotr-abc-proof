# Retail Clight refinement status

This note records the current boundary between the source-owned cleaned Clight
programs and a semantics-preserving US/JP retail model. It does not claim that
the gameplay theorem, or even the complete cleaned-to-retail simulation, is
finished.

## Scoped gameplay start

The scoped gameplay start is **SSL Area 1 (the exterior)**.  The formal
`DefaultArea1StartBoundary` fixes the default exterior node-`0x0A` memory.  It
is an assumed initial state, not a proof of the OS/castle prefix.  Task-start
and `warp_level` receipts remain source/refinement evidence and inputs to a
separate upstream investigation.

## What is now formalized

`USWholeASTTagRepair.v` defines a recursive US viewport-tag rewrite over every
Clight type position in expressions, statements, labeled statements, function
parameters, locals, temporaries, bodies, external declarations, global-variable
types, continuations, and all three Clight state constructors. Global identifiers,
initializer data, calling conventions, and control-flow constructors are not
changed. The fresh-tag and local layout certificates remain the source of the
layout facts. `USViewportRepairedProgramCertificate.v` now checks that the
whole-AST repaired program actually builds; the transform therefore has no
fallback ambiguity. This is still not an alpha-renaming or internal-step
simulation proof.

`SelectedClightTarget.v` pins every observation projection to one exact program:
the repaired US program or the official cleaned JP link, and checks that the
chosen construction succeeded. This replaces the former projection gate based
on `TargetLinkedProgram`. That older record requires one target composite
environment to be above every incompatible original-unit binding under
CompCert `linkorder`, so it cannot serve as the target selector for these 38
generated units. The replacement separates checked structure from open
semantics. `OriginalUnitsHeaderNormalizationStructuralObligation` is inhabited
by the source-owned cleaning certificate and proves ownership, verbatim strong
definitions, identifier/composite coverage, normalized-header use, and the
successful official whole link. It deliberately does not execute standalone
units, whose unresolved cross-unit functions have arbitrary `EF_external`
semantics. `WholeLinkedSourceToSelectedTargetRefinementObligation` then starts
from the whole official cleaned source and requires concrete
`ClightLockstepComponents` anchored at matching source/target runtime-task
starts. `SelectedRuntimeTaskStart` fixes initialized `thread5_game_loop`, one
null pointer argument, `Kstop`, and a real first Clight step, avoiding the
missing-`_main` and false-relation vacuity. Official-JP initialized memory is
now constructed; its exact task body resolves, the null-argument call state
takes a real first step, and identity lockstep closes the JP
source-to-selected boundary.  These task-start facts do not anchor the scoped
gameplay run; repaired-US initialization and viewport-repair lockstep remain
open.
`JPSelectedTargetAudit.v` now performs the fresh selected-program syntax audit
and checks the five core state-global symbols for projections fixed to the
official cleaned JP program. Its capstone packages those facts with the JP
source identity and reduces `SelectedTargetClightRefinementObligation` to the
still-open generic `TargetClightRefinementObligation`. This reduction does not
construct the observer, chronology, boundary-to-entry prefixes, or selected-to-retail
semantics. `USSelectedTargetAudit.v` independently closes
`SelectedTargetAuditTransportObligation` for projections fixed to `VersionUS`
and `us_viewport_repaired_program`. Its fresh audit runs against the actual
successful repaired program and checks no direct `Sbuiltin`, supported external
constructors, resolution of internal-body `Evar` names and initializer
`Init_addrof` names, plus `find_symbol` existence for the five core identifiers.
Those symbol witnesses say nothing about memory shape, contents, or block
correspondence. The repaired-US initialization and source-to-selected
viewport-repair execution lockstep, boundary-start chronology,
and selected-to-retail semantics remain open.

`ClightGlobalMemoryRefinement.v` proves concrete US and JP membership agreement
for every strong source definition retained by the selector: internal function
bodies and definitive initialized globals occur verbatim in the corresponding
official cleaned link. Weak external declarations and tentative variables are
not falsely required to be literally equal. The file also proves:

- ordered global-definition equality implies pointwise `prog_defmap` equality;
- an actual CompCert `match_program_gen` witness gives identical initialized
  memories, with `Genv.initmem_inject` covering every initializer store,
  including `Init_addrof` relocations;
- any current `Mem.inject` transports a concrete loaded initializer or later
  pointer value to the mapped target block.

`GlobalInterfaceStructural.v` proves a generic selector-exactness capstone. If
the source internal and definitive identifiers are unique and the checked
selection predicates hold, every definition emitted by
`clean_translation_units` is exactly the normalized definition-map entry for
its identifier. The theorem is intentionally abstract in the unit list. The
concrete US/JP hypotheses, full global-definition-map equality, public-name
agreement, and initialized/current-memory instances are not proved.

`JPSourceSymbolTransport.v` closes a smaller concrete boundary: one explicit
definition receipt in any JP source unit, together with the already-checked
source-union coverage and official cleaned link, yields existence of the
identically named symbol in the official JP program. Twelve focused receipts
then use that theorem, except for the platform receipt's aggregate public-name
and cleaned-link transport. `JPArea1EntrySymbolResolution.v` aggregates their
existence facts into an `Area1EntryAddresses` witness at slots `0`/`1` and the
official-JP `JPArea1EntrySymbolBindings` record for all twelve required symbols.
Its structural capstone proves
slot validity, pairwise distinction of Mario-state/controller/object-pool
storage, and separation of every pointer cell from core storage. It does not
prove allocation/layout sizes, initializer values, live memory contents,
routing, reachability, or execution, and it does not establish the full
global/public-map agreement.

The exact US and JP normalized-to-official definition/public-name/initial-memory
records consequently remain named obligations. The official cleaned links
reorder and select declarations, so the simple ordered-program lemma cannot be
applied without concrete structural instantiation and a separate name-based
initialization proof.

`ClightEndToEndRefinement.v` supplies the reusable state-simulation spine:

- injected local and temporary environments;
- a recursive continuation relation, including saved `Kcall` frames;
- a relation for `State`, `Callstate`, and `Returnstate`;
- injection-growth closure;
- mapped pointer loads, stores, and validity;
- injected `deref_loc` for value, reference, copy, and bitfield accesses;
- CompCert injection lemmas for unary operations, binary operations, and casts;
- a four-field lockstep component record and proofs that it yields a Clight
  forward simulation and transports initial-to-final executions.

This composes a completed simulation; it does not manufacture the missing
US/JP expression induction or internal-step proof.

`RetailExternalFrames.v` names the concrete writable state footprint for each
version: `gMarioStates`, `gObjectPool`, `gMarioObject`, `gControllers`, and
`gPlayer1Controller`. Recognized `EF_builtin` and `EF_runtime` calls preserve
the entire memory and therefore this footprint. Its declaration-wide
`EF_external` record is now retained only as a legacy sufficient condition. A
whole-pool frame is an overstrong proof target: omitted retail helpers can
legitimately allocate and write object slots, so those effects must not be
framed away.

`RetailExternalFrameReachability.v` supplies the sound replacement. A protected
cell policy may depend on the external constructor, actual arguments, and
pre-memory, and every reachable unresolved external effect must be either
framed for those cells or carried into an explicit writer/lifecycle refinement.
The file proves that a legacy declaration-wide frame implies the reachable
form and that pointwise reachable frames supply the callsite-sensitive
inventory. It also defines a streaming direct-callee audit for the seven
dialog/depth bodies. Six translation-unit-local receipt modules, two
per-version aggregate modules, and `DialogDepthFiniteInventory.v` now prove
`dialog_depth_finite_inventory_obligation_closed`: the selected unresolved
direct-callee set is exactly the expected ten names and has length ten for
both US and JP. This is direct-call syntax only. Path-sensitive reachable call
sequences, transitive reachability, argument provenance, and concrete external frame-or-writer
classification are not claimed.

`ClightProjectionChronology.v` repairs a separate projection-interface gap.
Because `ImportedClightRun` contains only a proof-erased `Smallstep.star`, its
input, event, and collision lists cannot be computed from that proof. The new
data-bearing frame chunks retain concrete endpoints and traces, projected
states, one input/event pair, collision observations, and a local
`CertifiedStep`. One fixed `ClightFrameObservationInterface` must serve every
run in scope. Each observed gameplay or administrative frame contains a real
nonempty `Smallstep.plus`; silent no-poll chunks may stutter and emit no input
or event. Its input-soundness field requires previous/current
`buttonDown` and computed `buttonPressed` loads at the observer's pinned
controller and player-one binding. Gameplay frames additionally bind
`MarioState.controller` at the exact consumer call; administrative frames are
poll-only and carry an independently refined event without claiming Mario
consumed the sample. A concrete proof must still construct that observer and
classify each live gameplay or administrative frame.
Checked composition proves that an exact connected chronology yields
`ClightFrameRefinementCertificate`; supplied nonempty prefixes from a
`SelectedRuntimeTaskStart` to both entrances yield clean-entry nonvacuity; and
those facts compose with the selected-target source/audit refinement. No
observer, concrete gameplay/admin classification, chronology, projection,
or lower/upper prefix from the declared SSL Area 1 (the exterior) boundary has yet
been constructed.  The older task-entry composition theorem remains available
but is not a core scope requirement.

`Area1EntryZeroAPrefix.v` gives a conditional upstream bridge. A supplied
ordinary Area-1 memory postcondition and no-A input sample yield the live
controller predicate and a reflexive zero-A suffix. If a caller additionally
supplies castle routing to `warp_level`, resolution of the `warp_level` symbol
to the expected internal body, the `warp_level` execution, all entry symbol
bindings, and the final postcondition in one program, the theorem composes the
traces and pins the controller block at the real return state. It does not
prove those premises. `JPWarpLevelEntryResolution.v` separately closes the
exact symbol/body premise for the official cleaned JP program, and the
compiled JP-specialized corollary in `Area1EntryZeroAPrefix.v` consumes it. The
twelve official-JP structural bindings are separately constructed by
`JPArea1EntrySymbolResolution.v`. The split US source/normalization/repair
receipts culminating in `USWarpLevelEntryResolution.v` close the exact lookup
for the selected viewport-repaired US program. Live memory, both live prefixes,
routing, body execution, the entry postcondition, and the remaining US entry
bindings remain open only for the separate castle-to-boundary investigation;
the core run assumes the boundary.

## Still required for end-to-end retail refinement

1. Retain the checked original-unit structural header-normalization/link
   certificate and the checked reflexive JP
   `WholeLinkedSourceToSelectedTargetRefinementObligation`; inhabit the
   corresponding repaired-US execution lockstep at a concrete runtime-task
   start. Retain both checked selected-program syntax/five-core-symbol audits;
   neither one supplies source/refinement execution, initialization, or memory
   correspondence.
2. Instantiate the generic selector theorem for concrete US/JP units, then
   prove exact global-definition-map and public-name agreement plus name-based
   initialized-memory injection, including allocation order and relocation
   pointer contents.
3. Maintain the current-memory injection through every internal allocation,
   free, store, and external step.
4. Classify each reachable `EF_external` call using the callsite-sensitive
   frame-or-writer interface. The exact ten-name direct-callee inventory is
   checked; prove path-sensitive reachable call sequences, transitive
   reachability, argument provenance, and each concrete effect, refining legitimate object writes rather than
   imposing the legacy whole-pool frame.
5. Define the concrete state/input/event/collision projection and one fixed
   observer, instantiate its pinned controller/pointer/function bindings,
   prove gameplay versus administrative frame classification, and construct
   an exact chronology for every selected-boundary run in scope.
6. Project `DefaultArea1StartBoundary` into the concrete observer and execute
   nonempty post-boundary prefixes from SSL Area 1 (the exterior) to both clean
   pyramid entrances.  Do not include OS/castle construction in this core item.
7. Retain the checked JP source-to-selected identity component, instantiate the
   repaired-US source-to-selected component, and prove the separate
   selected-to-retail/compiled-behavior transport from final Clight memories to
   the project's retail game-state projection.

Until all seven items are discharged, the project has a sound compositional
refinement framework, not an end-to-end cleaned-execution-to-retail theorem.
