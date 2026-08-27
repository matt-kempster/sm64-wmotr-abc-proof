# Source-to-Clight map

All rows are translated twice, once with `VERSION_US` and once with
`VERSION_JP`, from decomp commit
`9921382a68bb0c865e5e45eb594d9c64db59b1af`.  There are 38 translation
units per version and therefore 76 generated Clight modules.

The scoped gameplay start is **SSL Area 1 (the exterior)**.  Source and proof
identifiers use `Area1` consistently.

Each row is a whole translation unit: every function/global retained by the
preprocessor is translated, not only the functions named below.  The
"Inspected boundary" column identifies why the unit is imported and which
source shapes are currently queried.  Identifier/constant/assignment/call
checks do not by themselves prove dataflow, control dependence, loop execution,
or a whole-program semantic effect.  The array-slot recognizer is
base-insensitive and direct-callee/literal checks are path-insensitive.
The separate [CompCert execution-scope boundary](../docs/compcert-execution-scope.md)
defines which corruption mechanisms can occur in the current Clight run; it is
not a source-census result.

| Source | Generated stems | Inspected boundary |
| --- | --- | --- |
| `src/game/game_init.c` | `*_game_init.v` | `read_controller_inputs`; assignment operator shape for `buttonPressed` only, not operand/dataflow identity |
| `src/game/mario.c` | `*_mario.v` | `update_mario_button_inputs`; pressed/down field and input-bit constant occurrences; `execute_mario_action`, `update_mario_inputs`, and `update_mario_geometry_inputs` call order for the three-view PU/Ink audit; generated syntax receipts for the guarded floor-null Graphics-to-State copy/retry and exact guarded retry-null death call, plus entry-coordinate synchronization; jump-kick `20.0f` action-initializer receipt and `init_mario` cap reset source shape for the ordinary-motion boundary |
| `src/game/mario_actions_airborne.c` | `*_mario_actions_airborne.v` | jump-kick and forward/backward rollout `perform_air_step(..., 0)` receipts, rollout `30.0f` receipts, the riding-shell-air `42.0f` occurrence receipt, the common-cancel quicksand-depth zero and dispatcher-order receipt, and the broader airborne writer inventory; no branch/dataflow or complete execution refinement yet |
| `src/game/mario_actions_automatic.c` | `*_mario_actions_automatic.v` | pole positioning, holding-pole and top-of-pole source shapes used by the normalized-pole subcase |
| `src/game/mario_actions_cutscene.c` | `*_mario_actions_cutscene.v` | `act_spawn_no_spin_airborne` and `launch_mario_until_land`; checked call/Float32-argument shapes anchor the zero-forward-speed entry update before `perform_air_step`; `act_disappeared` floor-snap/warp call order for the node-`0x1E` audit |
| `src/game/mario_actions_moving.c` | `*_mario_actions_moving.v` | walking, braking, slope deceleration, and ground-step shapes; moving-punching held-A jump-kick shape; high-speed B dive and dive-slide B rollout constants/calls; riding-shell-ground `45.0f` occurrence and dispatcher-order receipts; all checks remain path-insensitive |
| `src/game/mario_actions_object.c` | `*_mario_actions_object.v` | stationary punching's held-A jump-kick constants/call plus other object-interaction action handlers; no complete execution refinement yet |
| `src/game/mario_actions_stationary.c` | `*_mario_actions_stationary.v` | stationary action handlers imported for Layer B action/writer coverage; no complete execution refinement yet |
| `src/game/mario_actions_submerged.c` | `*_mario_actions_submerged.v` | submerged dispatcher coverage; generated-AST receipts check the water full-step helper calls, all three direct whirlpool position slots, and the common water-level clamp.  The Ink writer audit conservatively allows water pitch at most `60` plus a persisted s16-only bob below `148` to compose across the floor-hit branch, represented by the modeled integer bound `208`.  This closes the missing translation-unit hole, not SSL reachability or callgraph completeness |
| `src/game/mario_step.c` | `*_mario_step.v` | ground and air quarter-step loops, `find_floor` calls, gravity source shape, `stop_and_set_height_to_floor` State-Y assignment from cached `floorHeight`, and the riding-shell quicksand-depth zero assignment receipt |
| `src/game/interaction.c` | `*_interaction.v` | `interact_star_or_key` field/constant occurrences and direct save call; `interact_coin` spawn call/index constant; `interact_warp` action constant in the PU phase pipeline; `push_mario_out_of_object` wall-call/State-position/no-Graphics receipts; bilateral exact initializer, bounded-index, and action-flow receipts for `sInteractionHandlers` and both 3-by-3 knockback tables; an occurrence-sensitive whole-corpus refinement admits only four terminal reads per version and rejects stores, address handoffs, public export, and owning-unit relocations; CompCert's private self-injection frames every abstract outside call and excludes a returned table pointer, with live start-to-trace invariant construction still pending; extraction dataflow and exact wall-call arguments are pending |
| `src/game/save_file.c` | `*_save_file.v` | direct call from `save_file_collect_star_or_key` to `save_file_set_star_flags`; `save_file_reload` backup-copy/file source shape; the bit-update and copy memory effects are not yet proved |
| `src/game/object_collision.c` | `*_object_collision.v` | `detect_object_hitbox_overlap` collision-list field occurrence/assignment and full object-position slot reads; Goomba receipts reach the generic list/hitbox bodies, find literal 5 in the caller, and find no direct FAR guard in those bodies.  Coupling 5 to the pushable-list call remains a pinned-source audit fact; tangibility, capacity, list membership, execution, and the handwritten collision projection are pending |
| `src/game/object_list_processor.c` | `*_object_list_processor.v` | full direct-callee order from dynamic-surface rebuild through final platform query, State-to-object copy slots, platform-clear call split, and unload-body identifier/call occurrences; loop/state effects are pending |
| `src/engine/behavior_script.c` | `*_behavior_script.v` | `cur_obj_update`, behavior-command dispatch, direct distance call and FAR-field writes used by the Goomba audit, and a generated receipt for the bit-0-guarded call to `obj_update_gfx_pos_and_angle`.  This closes the previously absent scheduler body; branch control, the callee's exact dataflow, live Mario flag, and indirect native-call path still require memory/control refinement |
| `src/engine/level_script.c` | `*_level_script.v` | the interpreter that consumes packed level commands and reaches object/warp/area loaders.  Its body closes an entry/spawn control-flow hole, but the indirect command table, segmented addresses, external native calls, and live memory effects remain to be refined |
| `src/engine/graph_node.c` | `*_graph_node.v` | `geo_obj_init_spawninfo` and graph-node initialization, including the entry-time Graphics/throw-matrix initialization path.  Function-body coverage does not yet prove Mario-object allocation or non-aliasing |
| `src/game/rendering_graph_node.c` | `*_rendering_graph_node.v` | the sole `animYTrans` consumer in `geo_set_animation_globals`, its exact numerator/divisor-to-renderer-global ratio, and the animated-part/shadow/object render bodies.  Direct-assignment receipts exclude `pos` and raw Object-data writes in those inspected bodies.  Matrix-stack/display-list construction is rendering state; external-call frame rules, converter-produced animation data, and linked memory non-aliasing remain separate |
| `src/game/spawn_object.c` | `*_spawn_object.v` | allocation/unload assignment and call occurrences relevant to activation, respawn fields, and reuse; generic allocation writes exact binary32 `1000.0f` to collision-distance raw slot 67.  Live Spindel allocation and absence of a later overwrite are not coupled by the receipt; memory effects are pending |
| `src/game/object_helpers.c` | `*_object_helpers.v` | default/no-exit star spawn helpers and target behavior parameters; Goomba/Spindel receipts check full-float X/Y/Z distance and FAR-aware movement-body anchors, without proving the branch executes |
| `src/game/debug.c` | `*_debug.v` | the retail-resident debug object-spawn callback called by `bhvMario`.  The generated receipt finds the page/config/button identifiers and a `spawn_object_relative` call; the exact guard/count interpretation is a separate manual source audit.  A clean live-entry projection must prove the debug-spawn guard false |
| `src/game/memory.c` | `*_memory.v` | segmented-address and pool helpers used by level/behavior loading.  Pointer-to-integer conversions are implementation-dependent; the generated Clight body is retained as an audit input and is not silently treated as a proof of N64 compiled behavior |
| `src/game/mario_misc.c` | `*_mario_misc.v` | Mario model/cap/hitbox update callees reached after action dispatch.  Manual source audit finds no direct live-Mario header-Graphics position writer.  The generated receipt only inventories `gMirrorMario`, `gMarioStates`, `vec3f_copy`, and `get_pos_from_transform_mtx` anchors; destination non-aliasing and render-context reachability remain open |
| `src/game/obj_behaviors.c` | `*_obj_behaviors.v` | hidden controller/trigger constant, field, assignment and direct-call shapes; pyramid-top spinning yaw-versus-pitch/roll write shape; Spindel pitch-slot and `1024` numerator receipts; no checked five-count control dependence or linked Spindel phase execution |
| `src/game/obj_behaviors_2.c` | `*_obj_behaviors_2.v` | Eyerok hand attack check, movement/update order, death, and coin-spawn source shapes; regular-Goomba property prefix, attacked-action callback, action-2 write, movement-flag access, and lexical update-order receipts |
| `src/game/behavior_actions.c` | `*_behavior_actions.v` | `bhv_pole_init` hitbox-field assignment shape used by the normalized-pole source audit; Area-1 Tox Box angle-slot writes and breakable/exclamation fragment allocation, PRNG, face-angle, and angular-velocity source shapes |
| `data/behavior_data.c` | `*_behavior_data.v` | star, hidden-controller and hidden-trigger behavior bindings; pyramid-top loop/collision-loader initializer references; Goomba init/update and Spindel init/loop/collision-loader callback subsequences |
| `src/game/area.c` | `*_area.v` | direct `unload_area`/`load_area` call order in `change_area`; lifecycle execution is pending |
| `src/game/level_update.c` | `*_level_update.v` | direct `change_area` occurrence in `check_instant_warp`, game-over reload call, airborne entry-action constant/call source shape, guarded direct-assignment first-writer shape for `sDelayedWarpOp`, normal-update/delayed-object-warp ordering, absence of a direct latch assignment in `initiate_delayed_warp`, and the area-entry `init_mario`/initial-cap call shapes needed to exclude retained Wing Cap |
| `src/game/platform_displacement.c` | `*_platform_displacement.v` | `gMarioPlatform`/validation-field identifier occurrences, State position writes, and an exact bilateral query-time chain from `gMarioObject.rawData.asF32[6..8]` through X/Y/Z temporaries to `find_floor`; the official-cleaned-slice direct writer/address/caller bounds are checked, while JP separately has local `Surface.object`-store/apply-load Clight steps; live query-to-collision preservation, alias/external frames, slot/epoch provenance, and preservation between fragments remain pending |
| `src/engine/math_util.c` | `*_math_util.v` | full `mtxf_rotate_zxy_and_translate` body and `gSineTable` initializer; the linked memory execution that constructs the platform matrix remains pending |
| `src/engine/surface_collision.c` | `*_surface_collision.v` | `find_floor` binary32-to-signed-16 cast shape and 78-unit floor buffer, plus the floor/surface query implementation used by Mario stepping and platform recomputation; ordinary-motion receipts check the wall list's strict `y > upperY` rejection; Ink receipts check the X/Y/Z result-pointer writes, absence of a wall-list Y-field mutation, and absence of direct Graphics references; the concrete CompCert cast result and matching authenticated US/JP retail instruction fragment are checked; a classified live-list trace now projects selected nodes into the finite stock query, while linked trace membership and actual selection remain pending |
| `src/engine/surface_load.c` | `*_surface_load.v` | surface allocation/insertion, object-vertex transformation, object-surface loading, normal construction, and collision-model loading; an exact bilateral receipt orders `gCurrentObject -> Surface.object`, followed later by `add_surface(surface, 1)` with the same syntactic surface-temporary identifier, and checks that static loaders instead use flag `0`; the direct-source-union follow-up proves zero intervening assignments to that local temporary; exact live byte ranges, allocator heads, same-block failed-frame reduction, and direct JP outside-root frames are now checked, while live call execution, transitive descriptor validity, canonical owner identity, list integrity/order, and slot epoch remain pending |
| `src/game/macro_special_objects.c` | `*_macro_special_objects.v` | spawn call and respawn-field assignment occurrences; persistence semantics are pending |
| `levels/ssl/script.c` | `*_ssl_script.v` | raw initializer tuples for lower/upper airborne entry objects, the area-2 static star, hidden controller, and instant-warp declarations; exact packed records for the Area-1 `0x0A`, `0x1E`, `0x1F`, and `0x20` warp objects, all five local warp-node routes, and the stock pyramid top, with checked coordinate/behavior-byte arithmetic |
| `levels/ssl/areas/1/macro.inc.c` via `inputs/ssl_area1_macro.c` | `*_ssl_area1_macro.v` | exact Area-1 wing-cap/exclamation, breakable-box, message-panel, cannon, and shell-box records used by the fragment and finite stock-owner audits; generic top-yaw/dirt-triangle/cartoon-triangle schedule lineage is no longer a Layer-B obligation, while linked-memory projection remains pending |
| `levels/ssl/areas/2/macro.inc.c` via `inputs/ssl_area2_macro.c` | `*_ssl_area2_macro.v` | raw initializer tuples for five Puzzle trigger records/coordinates; the abstract state now assigns exact kinds/references/positions, while their concrete spawn-memory projection remains pending |
| SSL collision arrays via `inputs/ssl_collision.c` | `*_ssl_collision.v` | area 1/2/3 static arrays plus pyramid-top, tox-box, grindel, spindel, moving-wall, elevator, Eyerok, breakable-box, exclamation-box-outline, cannon-lid, and wooden-signpost object collision arrays; checked word counts and US/JP initializer identity; the complete 39-word top initializer is parsed into five vertices and six triangle-index triples; exact local bounds are proved for four Area-1 fixed-owner meshes; all 20 elevator vertices and selected Area-2 pole/ring vertices have exact receipts, but no linked transformed dynamic `Surface`, actual `find_floor` selection, general parsed-surface, or connected-component theorem exists |

### Target-code cast evidence outside the Clight translation set

`include/PR/R4300.h`, `lib/src/osInitialize.c`, and
`lib/src/osCreateThread.c`, and `lib/asm/__osExceptionPreamble.s` are not
presented as generated Clight units in this project.  They supply the named
`FPCSR_FS`, `FPCSR_EV`, and
`FPCSR_FS | FPCSR_EV` initialization evidence.  Transparent US/JP ROM-word
receipts record the corresponding initialization prefix, while the separate
retail cast receipt records `find_floor`'s
`trunc.w.s; mfc1; sh; ...; lh` sequence.  The assembly routes `EXC_FPE` to a
fault path that stops the thread rather than resuming at `mfc1`.

The Rocq boundary is split deliberately:

- `proofs/Area1NonlocalCastSemantics.v` defines the total CompCert cast cases,
  the post-narrowing horizontal boundary split, the small target-prefix model,
  the initialization-word receipts, and the remaining target refinement and
  handler-continuation schemas;
- `proofs/Area1InvalidCastArithmetic.v` checks word-conversion failure for
  quiet NaN, both infinities, `+2^31`, and the first binary32 value below
  `-2^31`, plus successful signed-16 aliases at both adjacent finite word
  endpoints;
- `proofs/Area1NonlocalYCastArithmetic.v` checks all three components of
  `(-1862,67314,-902) -> (-1862,1778,-902)`, the concrete CompCert
  float-to-signed-short value semantics, and the modeled target-prefix
  arithmetic;
- `proofs/Area1NonlocalEndpointBoundary.v` relates that finite alias to the
  accepted timer-131 midpoint and packages a conditional State-first numeric
  capability;
- `proofs/Area1NonlocalPlatformMirror.v` constructs an exact binary32 payload
  whose X/Z velocity and pitch half-turn map the synchronized upper-warp centre
  to the full nonlocal State vector, with generated US/JP sine-table receipts;
- `proofs/Area1NonlocalPlatformInstallationClosure.v` proves the exact payload
  unavailable in the finite stock scheduler/owner model, checks the canonical
  pitch/pivot exclusions, and classifies every modeled successful installation
  into one of six explicit projection escapes;
- `proofs/Area1Rank3PayloadWriterClosure.v` computes the bilateral 38-unit
  pitch-word writer inventory and the fixed 93-identifier direct-call set of
  the canonical Area-1 owners, proves their sole intersection is the checked
  debris writer, and lists the six declarations still lacking selected-program
  bodies;
- `proofs/PlatformIntegerAliasClosure.v` proves from CompCert's value-cast and
  variable-addressed-store definitions that integer values cannot fabricate a
  successful defined store address;
- `proofs/Area1StateFirstWallExclusion.v` checks the bilateral wall-guard
  source shape and proves the two high-Y wall samples cannot reach X/Z push
  code in a source-shaped list traversal; and
- `proofs/Area1StateFirstRetailTrace.v` checks transparent copies of the
  injected JP one-frame and downstream-lifecycle observations.  Its ROM/log
  and linked-execution predicates are deliberately uninhabited.

These word receipts and the prefix relation are not a ROM parser or imported
VR4300 small-step semantics.  Whole-execution compiled-prefix refinement,
preservation of Invalid enable, imported handler non-resumption, a clean
three-dimensional writer, and linked dynamic-list/warp/snap/copy/lifecycle
execution remain open.  The hash-gated runners under
`instrumentation/timer131-state-first/` conditionally observe the first State
selection and the later timer-513 free, true first Area-2 apply, and
upper-trigger consumption.  Both fixtures inject the split and arm the top;
neither supplies a clean writer.

## Whole-program, entry, and writer-closure boundary

`proofs/LinkedClightPrograms.v` enumerates exactly the 38 generated units for
each version and executes CompCert 3.15's unmodified link operations.  Both
versions fail: the first right-associated AST join is `ssl_script` at index 34
and the first composite-definition join is `area` at index 27.  The associated
audit finds 402 US and 401 JP duplicate public variables with unequal generated
types.  `proofs/NormalizedClightPrograms.v` can build deterministic semantic
slices by selecting one generated definition per atom, but those slices are
not official CompCert links.  `proofs/CleanedClightPrograms.v` separately
constructs source-owned cleaned units and proves both
`NormalizedCleanedUnitsOfficialLinkStructuralObligation` inhabitants: the
unmodified linker returns actual US and JP cleaned targets.  Declaration ABI
and storage audits, actual-target global-reference resolution, external
  constructor coverage, and CompCert memory-injection transport are also proved.
  `USWholeASTTagRepair.v` defines the recursive tag rewrite;
  `ClightGlobalMemoryRefinement.v`, `RetailExternalFrames.v`, and
  `ClightEndToEndRefinement.v` prove the strong-definition, generic
  initialization, concrete-footprint, environment/continuation/state, pointer,
  scalar-operation, and lockstep composition layers.  They do not establish
  retail semantics.  `USViewportRepairedProgramCertificate.v` checks that the
  repaired whole-AST US program builds, and `SelectedClightTarget.v` selects it
  together with the official cleaned JP link.  This replaces the impossible
  common-`linkorder` `TargetLinkedProgram` selection gate.  The checked
  `OriginalUnitsHeaderNormalizationStructuralObligation` now records exactly
  what source-owned cleaning proves: definition ownership, verbatim strong
  definitions, identifier/composite coverage, normalized-header use, and a
  successful official whole link.  It makes no standalone-unit execution
  claim.  `WholeLinkedSourceToSelectedTargetRefinementObligation` starts from
  that whole link and is the task-anchored lockstep boundary to the selected
  target; its initialized null-argument `thread5_game_loop` starts must each
  take a first Clight step.  Official-JP initialized memory now exists, its
  exact task body resolves, the first step executes, and identity lockstep
  closes this JP boundary.  The OS handoff is outside the scoped gameplay run;
  US initialization and viewport-repair lockstep remain open.
  `GlobalInterfaceStructural.v` proves
  generic cleaned-selector exactness under explicit hypotheses; its concrete
  US/JP global/public-map instances and the name-based memory relations remain
  open.  `JPSelectedTargetAudit.v` closes the narrower audit for projections
  fixed to `VersionJP` and `jp_official_cleaned_slice`: exact selected-program
  identity, the selected syntax audit, and symbol existence for the five
  `jp_retail_state_global_identifiers`.  Its capstone packages that audit with
  the JP source identity and reduces `SelectedTargetClightRefinementObligation`
  to the generic `TargetClightRefinementObligation`; the concrete observer,
  chronology, boundary-to-entry prefixes, and selected-to-retail semantics remain open.
  The repaired-US audit is independently closed by the focused definition-name,
  definition-list syntax, repair-preimage, `Evar`, and `Init_addrof` transport
  modules, the two split five-core-symbol receipt modules, and
  `USSelectedTargetAudit.v`.  Under exact `VersionUS` and repaired-program
  hypotheses, the capstone packages no direct `Sbuiltin`, supported external
  constructors, repaired-program `Evar`/`Init_addrof` name resolution, and
  `find_symbol` existence for the five core identifiers.  It does not prove
  initialization, memory shape/content/block correspondence, source-to-selected
  viewport-repair execution lockstep, boundary-start routing/prefix/chronology,
  or selected-to-retail semantics.
  Concretely, `NormalizedDefinitionNameTransport.v` and
  `DefinitionListSyntaxTransport.v` provide generic list/name transport;
  `USViewportRepairDefinitionPreimage.v`,
  `USViewportRepairedDefinitionPreimage.v`,
  `USViewportRepairDefinitionListSyntax.v`, and
  `USViewportRepairSyntaxPreservation.v` connect that transport to the repair;
  the `NormalizedRepairedSymbolTransport.v`,
  `SourceUnitRepairedSymbol.v`, `USRepairedSymbolTransport.v`,
  `RepairedEvarResolutionTransport.v`, and
  `RepairedInitAddrofResolutionTransport.v` layer carries names and symbols;
  the `USRepaired*Audit.v` modules specialize the four syntax checks; and the
  `USSelectedCore*NthReceipt.v`, `USSelectedCore*Receipt.v`, and
  `USSelectedTargetAudit.v` modules close the five-symbol and capstone checks.
  `JPSourceSymbolTransport.v` separately proves one-definition
  transport from an explicit JP source-unit receipt to existence of the same
  official-link symbol.  Twelve focused receipts use that transport, except
  that the platform receipt instead uses aggregate public-name coverage and
  cleaned-link transport.  `JPArea1EntrySymbolResolution.v` aggregates them
  into all twelve official-JP ordinary-entry bindings at slots `0`/`1`, slot
  validity, core-storage separation, and pointer-cell/core-storage separation.
  It supplies no live memory contents, allocation/layout sizes, initializer
  values, or execution.

`proofs/RetailExternalFrameReachability.v` replaces the old whole-pool
declaration-wide external-frame target with a reachable, callsite-sensitive
frame-or-writer interface.  The generic reduction is proved.  The candidate
set has now been checked through six local receipts, two per-version
aggregations, and `DialogDepthFiniteInventory.v`: the selected unresolved
direct callees of the seven dialog/depth bodies are exactly the expected ten
names for US and JP.  Path-sensitive reachable call sequences, argument
provenance, transitive reachability, and concrete effect classifications remain
open.  Legitimate object allocation must enter writer/lifecycle refinement
rather than be hidden by a pool frame.

`proofs/ClightProjectionChronology.v` defines data-bearing frame chunks under
one fixed observer and proves that an exact connected chronology yields the
whole-run projection certificate.  Observed gameplay/administrative frames
contain a nonempty `Smallstep.plus`; silent no-poll chunks may stutter.  The
interface requires previous/current `buttonDown` and computed `buttonPressed`
loads at its pinned controller/pointer bindings and exact poll/consumer bodies;
concrete work must instantiate the observer and classify each frame.  Supplied
nonempty `thread5_game_loop` task-entry prefixes yield clean-entry nonvacuity.
That generic bridge remains source/refinement evidence.  The scoped gameplay
root is instead `DefaultArea1StartBoundary` in SSL Area 1 (the exterior).  The
observer, concrete controller refinement, projection
functions, post-boundary chronologies/prefixes, whole-expression/internal-step
simulation, and selected-to-retail relation remain open.

`proofs/OrdinaryArea1EntryMemory.v` maps SSL Area 1 (the exterior) through
`ssl_script`, `level_script`, `level_update`, `mario`, `object_list_processor`,
and `platform_displacement`.  Generated receipts identify node `0x0A`,
`bhvSpinAirborneWarp`, spawn type `0x16`, and action `0x1924`; layout/symbol
facts and an explicit postcondition imply exact State/raw Object/Graphics
synchronization.  `proofs/DefaultArea1StartBoundary.v` packages that exact
memory, coherent no-A input history, and null `gMarioPlatform` as an assumed
  selected-program start.  `proofs/DefaultArea1StartChronology.v` then requires
  a nonempty active selected-program run and decodes the platform seed from that
  same start memory.  A supplied pre-apply projection whose seed is required to
  equal that decoder cannot finish as retained-JP-inbound lineage.  Deriving the
  projection's events, collision sample, owner, and endpoint from the run remains
  open, as do external frames, object-access bounds, boundary projection, and
  full pool/list ownership.  Castle routing is separate optional upstream work.

`proofs/Area1EntryZeroAPrefix.v` proves the conditional bridge from a supplied
entry postcondition and no-A input sample to the live controller predicate and
reflexive zero-A suffix.  With separately supplied castle and `warp_level`
symbol/body resolution and execution prefixes, all symbol bindings, and the
final postcondition, it composes the traces at the real return state.  It does
not construct those premises.  `proofs/JPWarpLevelEntryResolution.v`
  separately resolves the exact symbol/body for the official cleaned JP
  program, and the JP-specialized corollary in `Area1EntryZeroAPrefix.v`
  consumes that resolution.  The focused `USWarpLevel*Receipt.v` chain and
  `USWarpLevelEntryResolution.v` resolve the exact `_warp_level` internal body
  in the selected viewport-repaired US program.  `JPArea1EntrySymbolResolution.v`
  separately supplies the twelve official-JP structural bindings and limited
  block-separation facts.  Live routing/execution and the entry postcondition
  remain open for the separate castle-prefix investigation; the core proof
  assumes `DefaultArea1StartBoundary`.  Its observer projection, post-boundary
  prefixes, and remaining US entry bindings remain open.

`proofs/JPGeneratedWriterCensus.v` concatenates definitions only for a
receiver-neutral syntactic census while preserving the 38-unit boundaries.
It counts assignment-bearing functions, not stores: 33 for `pos[1]`, 215 for
raw-data slot 7, 180 for raw-data slot 10, and 15 whose LHS mentions
`throwMatrix`.  It also isolates eight direct `quicksandDepth` writers and six
direct automatic-dialog constructors.  Receiver identity, aliasing, calls,
actions, flags, reanchoring, and lifecycle still require semantic refinement.

`proofs/JPCoordinateLvalueReceiverPartition.v` rechecks the four coordinate
shapes per unit against generated Clight receiver annotations.  It verifies
that `pos[1]` belongs to the allowed set `MarioState`, `GraphNodeObject`, or
`PlayerCameraState`, raw slots
7/10 into `Object`, and `throwMatrix` into `GraphNodeObject`.  The receipt is
static typing, not live pointer identity, alias freedom, or reachability.

`proofs/ClightInitialMemoryFacts.v`, the twelve
`proofs/JPInitializerReceipt*.v` files, and
`proofs/JPOfficialInitialMemory.v` prove that the official cleaned JP link has
an initialized CompCert memory.  `proofs/JPThread5EntryResolution.v` resolves
the exact task body, and `proofs/JPSelectedRuntimeTaskStart.v` constructs its
null-argument first step and the JP identity source-to-selected witness.
`proofs/JPWarpLevelEntryResolution.v` separately resolves the exact
`warp_level` symbol/body in the same official JP environment.  The split
`proofs/USWarpLevel*Receipt.v` modules and
`proofs/USWarpLevelEntryResolution.v` close the corresponding exact lookup in
the selected viewport-repaired US program.  The OS handoff, castle routing,
and `warp_level` execution are optional upstream reachability work, not the
core gameplay prefix.  Projection of `DefaultArea1StartBoundary`,
selected-to-retail transport, repaired-US task/refinement witnesses, and the
remaining US entry bindings remain open.  The
twelve official-JP entry symbols, slots `0`/`1`, and limited global-block
separation are now closed structurally by the focused symbol receipts and
`JPArea1EntrySymbolResolution.v`.  The game-init receipt additionally resolves
  the exact `_gPlayer1Controller` source definition into the official link;
  `proofs/JPSelectedTargetAudit.v` uses it with four existing receipts to close
  the selected-JP syntax/five-core-symbol audit and reduce the full selected-JP
  boundary to the generic target refinement obligation, without claiming memory
  contents, observer/chronology, entry prefixes, or selected-to-retail execution.
  The parallel repaired-US chain culminates in
  `proofs/USSelectedTargetAudit.v` and closes only the actual repaired-program
  syntax/name and five-core-`find_symbol` audit.  Repaired-US initialization,
  source/refinement execution lockstep, memory block correspondence,
  boundary-start chronology, and selected-to-retail transport remain open.

`proofs/JPZeroAReachability.v` defines a zero-edge relation over `Clight.step2`
and the live controller `buttonPressed` cell.  Program, controller address, and
entry are parameters, so it does not establish a clean JP run.  Its global
`<960` composition is conditional on total three-view projection and per-step
writer refinement.
`proofs/JPQuicksandDepth.v` separately closes one live-range arithmetic case:
`768.5f` followed by 381 exact sinks ends at `1778.1593017578125f`, converting
to integer coordinates separated by `1010`.  It does not install the negative
depth/action state or prove 381 unreanchored calls reachable.

`proofs/JPLongJumpLandingDepth.v` isolates the newly discovered two-floor
sample.  Its minimal CompCert binary32 model checks exact `-0.5f` and `-4.0f`
single-frame results when the updater sees ordinary floor but the later landing
writer sees quicksand.  The source chronology is not re-imported into this
lightweight module: executing the generated Clight updater, four ground
quarters, new-floor guard, and write is a named refinement obligation.

`proofs/AutomaticDialogReanchoring.v` checks both generated versions of the
cutscene/automatic/submerged/interaction source boundary.  It classifies
`ACT_READING_AUTOMATIC_DIALOG` as a cutscene action with no direct depth reset
or State-to-Graphics copy, checks constructor/reanchor shapes and outer
sink/raw-copy order, and proves a finite stalled-dialog gap model.  Linked
branch execution, live pointer identity, external frames, floor validity, and
stock constructor reachability remain open.

`proofs/ActionDepthAliasCensus.v` is a bilateral syntax census for direct
action/depth writes, explicit sensitive-field address-taking, indirect
Mario-state calls, reset shapes, and the writable long-jump descriptor.  It is
not semantic non-alias or corruption closure.

`proofs/Area1LongJumpQuicksandCrossing.v` ties exact generated Area-1 collision
vertices/groups/triangles to a transparent rational XZ/plane calculation.  It
proves the 44-unit sample separation and sub-100-unit drop, while leaving real
surface-list selection and all four binary32 ground quarters explicit.
`proofs/Area1LongJumpQuicksandRetailTrace.v` records the separately
authenticated US/JP four-quarter observation: exact endpoint bits, four query
and commit counts, null walls/ceilings, and static type-37 owner-null floors.
It is a transparent finite certificate of external observations, not an
emulator oracle or a linked-Clight execution theorem.
`proofs/Area1LongJumpQuicksandNextFrameTrace.v` records the uninjected
immediate successor of the prepared pre-timer-3 fixture.  It checks four more
static owner-null type-37 commits, null wall/ceiling/platform results, exact
raw/Graphics/depth words and zero-A fields for US and JP.  Its raw-word
arithmetic proves that, for the separately supplied prepared-star words and
modeled 160/50 hitbox fields, Mario's raw top remains more than 96 units below
first-hitbox Y and even Graphics top remains below it.  It does not connect
the supplied star words or hitbox fields to a live linked object, overlap
execution, clean entry, or CompCert execution.

`proofs/LongJumpProvenanceBoundary.v` checks all nine US/JP landing
descriptors, the A-guarded constructor/callback, both dispatches, and the
airborne landing edge.  Its source transition kernel proves no-edge/no-forgery
exclusion from stock entry actions.  Whole-program linked step classification
and its seven explicit forgery exclusions remain open.

`proofs/ZeroAQuicksandEntryBoundary.v` proves separate consequences for the
kernel and entry boundaries; it does not execute a link between them.  The
abstract pyramid contract fixes `0x1932`, while separate concrete memory
postconditions assume/fix pyramid timer/depth zero and ordinary Area-1
`0x1924`/timer-zero/depth-zero.  It proves only
the authentic six-frame long-jump descriptor can produce a negative landing
write from nonnegative depth, then performs a bilateral census over all 38
generated units.  The sole ordinary long-jump constructor is A-edge guarded,
the sole landing producer is the long-jump body, and direct action writers
embed neither target.  Linked retail step classification and exclusion of
alias/OOB/external/descriptor/callback forgery remain explicit.

`proofs/NegativeDepthForgeryBoundary.v` audits those source-visible forgery
surfaces.  All nine writable descriptors and the writable interaction table
have no direct generated assignment; descriptor address sites are
wrapper-local; timer-only forgery cannot make a stock non-long landing reach a
negative late body; and the two indirect MarioState call sites are classified.
Its CompCert memory theorem requires any changed action load to arise from a
same-block byte-overlapping store.  Compiled flat-layout OOB behavior, live
pointer/global integrity, indexed render state, and external frames remain
open.

`proofs/NegativeDepthInteractionClosure.v` discharges the initialized stock
interaction-action branch.  Bilaterally it checks all 29 distinct handlers,
extracts the exact 23 direct action literals, bounds four local selectors,
follows Snufit's 3-by-3 knockback lookup and Bully's literal-result helper, and
proves every resulting action differs from both long-jump targets.  The 18
knockback entries are checked against the generated initializers, and their two
writable tables have no named generated writer.  Its linked residual keeps
table mutation, call retargeting, pointer/argument forgery, and unframed outside
effects explicit.

`proofs/WritableActionTableClosure.v` separates the table producer question
from the payload question.  Together with the existing whole-corpus handler
census exported at the capstone, it checks that the handler and two knockback
tables occupy exactly 320 writable bytes, that ordinary named source only
performs bounded reads, and that no controller-selected named assignment or
separate explicit address-taking site can rewrite them.  It also proves that
one hypothetical four-byte knockback edit can contain any action word,
including long jump,
connects the selected word to an action-setter consumer, and checks compatible
coin/pole handler-pointer payloads.  A concrete valid in-bounds alias or a
reached outside call whose footprint overlaps the private table block was the
exact linked-source residual; OOB/ACE/DMA behavior is outside this result.

`proofs/WritableActionTableAliasExternalClosure.v` replaces that residual with
an occurrence-sensitive source and CompCert-semantics result.  Reusing the
compiled whole-corpus mention census, it checks the only table-name bodies and
finds exactly two terminal handler reads plus one terminal read from each
knockback table; none is a store, return, or call handoff.  It also checks the
three names are private and absent from owning-unit initializer relocations.
Its generic memory-injection theorems prove that a self-injected store address
cannot target an omitted table block and that every CompCert abstract outside
call preserves such a block, cannot return its pointer, and preserves the
private injection and symbol interface after the call under the ordinary
global/volatile validity fact.

`proofs/WritableActionTableWholeGameAliases.v` closes the stored-alias scope
that an SSL-only start record cannot express.  Its sharded receipts inspect all
38 modeled translation units in each version and prove that no global
initializer retains a table address and no unit exports one; combined with the
occurrence census, this excludes persistent stores, returns, call handoffs, and
nonterminal address values anywhere in the modeled game.  The exact three
interaction-unit definitions resolve to valid blocks in both official linked
source programs.  The clear/load/unload/change/warp bodies do not name those
blocks, so a hypothetical post-boot mutation would survive an ordinary level
transition into SSL, but the audit supplies no first producer.  Constructing
and carrying the resulting private self-injection through the accepted live
execution was the remaining semantic bridge, now discharged by the modules
below.

`proofs/WritableActionTablePrivateInitialization.v` and
`proofs/WritableActionTablePrivateLive.v` construct the filtered identity
injection from successful selected-program initialization and carry it through
the primitive CompCert memory effects and finite executions.  The table blocks
are omitted while every ordinary named global remains self-mapped, so stores,
copies, allocation/free, and abstract outside calls preserve all table bytes
and cannot return a table pointer when their live values are self-injected.

`proofs/WritableActionTableSyntaxBase.v`, the 38 modules under
`proofs/WritableActionTableSyntaxReceipts/`, and
`proofs/WritableActionTableSyntaxCoverage.v` prove that every internal body in
both official selected linked sources obeys the required syntax grammar.
`proofs/WritableActionTableExpressionCoverage.v`,
`proofs/WritableActionTableTerminalReads.v`,
`proofs/WritableActionTableReachedControl.v`, and
`proofs/WritableActionTableFunctionEntry.v` establish the expression,
four-read, control-provenance, and function-entry cases.
`proofs/WritableActionTableClightStepCoverage.v` exhausts every reached
`Clight.step2` constructor, and
`proofs/WritableActionTableReachedExecution.v` composes that classifier from
the exact initialized task start through every finite successful selected
US/JP execution.  This closes table mutation for defined in-bounds runs;
OOB/ACE/DMA and post-undefined-behavior execution remain outside CompCert.

`proofs/NoExitStarDialogBridge.v` checks the no-exit-star hitbox/behavior,
object-list order, star-dance/dialog call footprints, and milestone table.  Its
finite model proves the fresh-star no-hitbox gap frame, the exact binary32
split between a surviving post-timer-4 `-2.65f` continuation and a positive
post-timer-5 continuation, the finite five-below-home vertical orbit and its
prepared binary32 endpoint, the resulting overlap interval, and boundary/warp
separation.  Live linked lifecycle execution, older-star
provenance, placement geometry, B-only menu
refinement, and alias/external frames remain open.

`proofs/NegativeDepthTimer131Bridge.v` combines the finite dialog gap with a
separate horizontal model: untransported stalls retain the audited raw X/Z,
far outside the fixed upper warp.  It checks the ordinary idle/walking source
shape and exact binary32 `1.6f` sanitizer outcome.  Active-dialog platform
transport, warp relocation/substitution, collision aliasing, and other raw
writers are named linked obligations rather than assumed away.

`proofs/DialogDepthMemoryFrame.v` proves exact US/JP field offsets and actual
CompCert store/load framing: finite stores to the Mario action/control prefix
or a separate block preserve the binary32 depth word.  Conditional
US/JP Area-1 symbol-binding theorems instantiate the separate-block result for
object-pool writes when those binding records are inhabited, and seven
generated star-dance/dialog bodies are direct nonwriters.  It is not
a branch-execution theorem; live pointers, preprocessing, aliases/OOB stores,
and unresolved external calls remain open.

## Pyramid-top PU and graphical-fallback boundary

`proofs/PyramidTopPU.v` bundles exact packed US/JP LevelScript records and the
parsed top mesh alongside a handwritten integer arithmetic kernel; its three
binary32 comparison lemmas are checked separately.  The bundle deliberately
does not connect them by an execution refinement.  It
proves a same-sample contradiction and a conditional Y-preserving stock-yaw
exclusion, plus a two-sample coordinate/alias model with a manually mirrored
triangle-edge arithmetic witness linked to the parsed generated mesh.
`proofs/PyramidTopSurface.v` now imports the
previously missing rotation and dynamic-surface helper bodies, proves the
concrete CompCert short-cast result, links the chosen zero-yaw home vertices to
the parsed generated mesh, and evaluates manually mirrored finite-width
cell/edge/transform arithmetic.  Authenticated US/JP retail disassembly plus
Rocq fragment arithmetic verifies the same three concrete cast results.
The dynamic recognizer finds a guarded assignment source shape only; it does
not prove exclusivity or full floor/height update semantics.  The kernel does
not claim a stale slot, live surface selection, or Clight step; extracting the
full edge/transform expressions from Clight and executing them over memory
remain open.  `sqrtf` remains external.  Generated files use `AVOID_UB=1` for the missing
hitbox return; the direct JP target audit and identical US/JP preprocessed-unit
hash are documented evidence, not a Rocq target-code refinement.  Gameplay
reachability and pointer retention/recapture through the delayed node-`0x1E`
warp also remain open.  See
[`../docs/notes/ink-fallback.md`](../docs/notes/ink-fallback.md),
[`../docs/notes/pyramid-top-pu.md`](../docs/notes/pyramid-top-pu.md) and
[`../docs/notes/pyramid-top-surface-refinement.md`](../docs/notes/pyramid-top-surface-refinement.md);
the target-code receipt is
[`../docs/notes/retail-find-floor-cast.md`](../docs/notes/retail-find-floor-cast.md).

`proofs/InkFallback.v` refines the scheduling boundary to three independent
views: collision Object, first-query State, and fallback Graphics.  It proves
conditional local and PU coordinate witnesses by evaluating a handwritten
floor-retry/action/sink/copy pipeline, checks nearby generated Area-1 mesh
arithmetic, and proves that arbitrary State-only ordinary/platform/PU prefixes
preserve Object and Graphics.  Separately, generated-AST receipts recognize
the exact null test, Graphics-to-State copy dataflow, retry, and result store.
They also recognize the guarded retry-null death request, the
`sDelayedWarpOp` first-writer latch, and geometry-before-interaction order in
US and JP.

The stricter `gfx.pos[1]` recognizer now isolates the exact generated lvalue
used by direct Graphics-Y assignments.  Its checked JP partition contains
eleven assignment-bearing bodies rather than the broader 33-body `pos[1]`
inventory.  A checked decomposition separates seven Mario initialization or
action paths from four receiver-generic helpers.  The four-helper remainder is
still receiver-neutral: live Mario receiver identity and its call paths remain
separate obligations, while the seven-path side still includes negative
quicksand and therefore is not labeled safe.

The receiver-generic remainder is further proved to be four distinct
single-role bodies: behavior-offset update, allocation sentinel initialization,
same-object raw-to-Graphics reanchor, and cross-object anchor copy.  This does
not prove their runtime effects on Mario, but separates the remaining
flag/offset, lifecycle, receiver-identity, and actor-reachability obligations.
The `obj_set_gfx_pos_from_pos` body is now closed locally: an exact adjacent
load/store receipt proves that its raw-Y load and Graphics-Y destination use
the same formal receiver.  It therefore reanchors the gap and cannot create
Ink's required separation, regardless of whether the call is reachable.
For `obj_update_gfx_pos_and_angle`, an exact call-dataflow receipt proves that
`cur_obj_update` loads `gCurrentObject` and passes that same temporary as the
writer's sole receiver under object-flag bit zero.  The stock Mario behavior
also names its update callback.  This establishes source-level identity and a
candidate path, but not interpreter execution, live `gCurrentObject =
gMarioObject`, or the flag/offset invariant.
The direct callback follow-up checks `bhv_mario_update`, the Mario debug-print
callback, and the debug-spawn callback: none directly assigns the raw `oFlags`
word or `oGraphYOffset` float slot.  The initializer payload's bit zero is also
clear.  The remaining provenance is consequently indirect/interpreter,
alias/external, or lifecycle based rather than a direct store in those bodies.

`proofs/InkTimer131MarioTailClosure.v` replaces that three-body spot check
with a bilateral whole-source boundary.  It corrects the flag lvalue from the
signed view to the generated guard's `asU32[1]`, inventories the 30 direct
flag and 28 direct `asF32[21]` writers, and recursively closes the ordinary
direct-call graph rooted at all three `bhvMario` callbacks.  The intersection
is empty, including a second scan that ignores which literal raw-data union
view names slots 1 and 21.  Separate receipts tie Mario creation to the
`gMarioObject` install, list traversal to `gCurrentObject`, and opcode 17 to
the dynamic `OR_INT` store; `or_256_preserves_flag_bit_zero` proves the stock
command cannot enable the tail guard.  This does not yet supply the linked
list/slot induction or frame indirect, external, alias, OOB, forged-script,
and reuse effects.

`proofs/InkTimer131IndirectAliasClosure.v` continues that boundary through the
two stock indirect calls.  It checks all landing callback arguments and the
complete interaction-handler initializer, expands the bilateral direct-call
closures through those targets, and still finds no literal flag/offset writer.
No unresolved direct callee in the resulting closure receives an `Object *`;
the generated corpus also has no unresolved direct or builtin `MarioState *`
handoff and no builtin `Object *` handoff.  The memory layer proves that a
defined changed load must overlap the exact four-byte Mario cell, and that any
in-bounds store to a distinct 608-byte pool slot preserves both cells.  Finally,
the exact source couples list 12's first object through the allocation fallback
to `unload_object`, while the full `bhvMario` initializer begins in list 0.
The resolved graph's direct `Object.behavior` writer intersection is exactly
`[create_object]`, while a whole-corpus address census for that field is empty;
the ordinary mutation helpers and area-load writer therefore do not provide a
hidden callback path.
Turning that into retail impossibility still requires live list-partition,
pointer/slot-epoch, and table integrity; forged/global/interior pointers, OOB
stores, and untyped outside effects remain explicit escapes.

`proofs/InkTimer131CorruptionClosure.v` checks the next source boundary.  The
command and interaction tables have only their expected dispatcher mention,
no direct named assignment, and no explicit address-taking site in either
whole generated corpus.  The Mario area-spawn path forwards one stable
decoded behavior value to both construction and the object's behavior field.
It incorporates the initialized interaction closure; stock handler dispatch,
local action selectors, and both dynamic knockback helpers therefore cannot
install the long-jump prehistory.  Its negative-dialog capstones rule out a
negative seed in the checked clean zero-A/no-forgery kernels and rule out
reaching the fixed warp by vertical dialog amplification without a separate
X/Z transport.  It deliberately does not frame changed writable tables,
forged/interior pointers, OOB stores, or untyped outside effects.

`proofs/InkTimer131LiveIdentityClosure.v` pins the source chain one step
earlier.  The exact three-word SSL `INIT_MARIO` command carries `&bhvMario`;
the normalized command handler writes its command-derived value to the Mario
SpawnInfo, `load_mario_area` forwards that same record, and the constructor
uses one stable decoded behavior value for creation and the object field.  Its
memory theorem then closes arbitrary finite compositions of framed stores,
in-bounds distinct-slot stores, safe flag stores, and zero-offset stores.  This
turns a successful corruption-style producer into a demand for one concrete
unclassified event, but does not yet refine every linked retail store to the
clean relation or exclude mutation of writable command/dispatch memory.

`proofs/InkTimer131ClightTraceBridge.v` replaces the old prose-only live
residual with an execution-indexed boundary.  Exact CompCert loads establish
the two safe tail cells; a bounded inductive path through list-head/object
`next` fields represents Mario's list-0 membership; the global/State Mario
pointers, active word, behavior pointer, and a caller-selected list of
command/behavior/dispatch loads form the remaining invariant.  A reachable
Clight `star` preserves that invariant and excludes the dangerous tail when
every reachable step is classified as a safe store or exact byte frame.
Recognized builtins/runtime calls instantiate the frame automatically, while
normal list insertion/removal is now allowed under a semantic preservation of
Mario's list-0 membership.  A reached unresolved external must either frame
the exact protected bytes at that callsite or supply an explicit linked writer
effect.  `proofs/InkTimer131EntryExecutionClosure.v` proves both watched words
zero in every valid slot of the official JP initial memory, computes
`bhvMario` as the only generated list-0 behavior, checks the clear/load/spawn
source chain, reduces direct list membership to one head-link load, and
extracts the first invariant-breaking step from any dangerous actual trace.
`proofs/InkTimer131RealEntryPrefix.v` gives that missing run a precise cross-
phase shape at the accepted level-select boundary.  It starts at the selected
`clear_objects` call, distinguishes the nested Area-object and direct Mario
`spawn_objects_from_info` calls after `load_mario_area`, and continues through
`init_mario` and the first object/behavior update to the final entry state using
actual `Clight.step2` segments whose every step carries an
`InkTimer131CellEffect`.  The exact
slot-67, `bhvMario`, pointer, active, one-node ring, `oFlags=0x100`, zero-offset,
and protected-load endpoint derives the full live invariant without an
ordinary-entry premise.  The module also translates the recorded machine
constants, proves the slot arithmetic, supplies the missing star-to-classified-
reach direction, and checks that the exact 85-function clear/load/init family
intersects neither literal watched-cell writer inventory.  Its conservative
outside boundary is three exact caller/callee sites: `unload_object`'s sound-
source stop, `load_mario_area`'s continuous-bank sound stop, and
`read_surface_data`'s `sqrtf`.  A broader 150-function family which also permits
a first object update remains writer-free and expands to five names at eight
sites.  The authenticated dynamic refinement records 73 successful allocator
entries, zero allocator-fallback, unload, and source-sound hits, and one
continuous-bank hit before the endpoint.  Its checked original-JP instruction
words prove the static `unload_object -> stop_sounds_from_source` edge is not
executed and therefore needs no effect specification; `sqrtf` remains not
excluded by this receipt.  `proofs/InkTimer131RetailMipsCode.v` and
`proofs/InkTimer131RetailMipsFrames.v` then close those effects directly at the
retail boundary.  Their hash-gated eight-range manifest covers 332 instructions,
42 stores, eight direct calls, all relative branches, and both fade helpers;
it excludes indirect/linking escapes, proves `sqrtf` store-free, and reduces
every sound store to a bounded stack, sound-bank data, one music mask, or
sequence-player-zero data.  The live continuous-bank entry SP `0x80207128`
makes even its deepest stack save disjoint from the whole object pool.  No
Clight inhabitant is constructed: an IDO-MIPS-to-Clight relation or an
independently reconstructed Clight start state remains optional strengthening,
while ACE, DMA, forged control flow, and post-invalid-access execution remain
outside this targeted machine fragment.
The read-only JP mode-2 instrumentation now supplies a separate authentic MIPS
write receipt, not just five call entries.  Physical watchpoints cover ten
identity/tail ranges and record exactly 19 stores: allocator zeros, slot/list/
behavior/pointer installation, and the first behavior's exact safe `0x100`
write.  The runner compares the complete 25-line receipt, and Coq replays it
from arbitrary watched prestate to the recorded slot-67 endpoint while proving
every protected overlap safe.  This frames the actual MIPS effects of
intervening indirect and outside code.  The project now packages its checkpoint,
spawn, identity, list, and safe-tail facts as
`JPInkTimer131AcceptedEntryTheorem` and uses that as the Timer-131 entry
boundary.  It does not refine IDO instructions to the optional CompCert
certificate; required work instead begins at this endpoint and classifies later
steps through timer 131.  Ordinary castle entry is outside the accepted
level-select boundary.

`proofs/InkTimer131PostEntryMachineTrace.v` checks two authenticated
endpoint-forward receipts.  The neutral receipt has 131 action-0 updates; the
route-specific lifecycle receipt has one explicitly disjoint slot-61 pillar-
counter fixture followed by 144 authentic updates to spinning action 1 timer
131.  Both preserve the exact slot-67 watched state.  In the spinning receipt,
all 144 protected-range events are the same `clear_object_collision` halfword
at offset `0x76`, disjoint from `activeFlags` at `0x74`; the command and
dispatch hashes remain fixed; all three Mario callbacks execute 144 times;
and the exact allocator/unload/sound/print counters are checked.  The two JP
debug-print JAL words are decoded and their specific callsites have zero hits,
although ordinary HUD rendering reaches the same print callees.  Coq checks
the write hash, fixture address and slot disjointness, identity replay, and
safe-tail conclusion.  This closes those selected machine timelines, while a
clean replacement for the fixture, universal controller/lifecycle coverage,
and a formal debugger-watchpoint-to-machine-step connection remain explicit.

`proofs/InkTimer131ProducerClosure.v` closes the two normal large-writer
source branches.  An opcode-neutral scan of every US/JP `behavior_data`
initializer finds exactly 40 commands whose target field is
`oGraphYOffset`; every one is `bhv_cmd_set_float`, and the largest payload is
`+240`.  The route's generic timer-131 top retry needs at least `+632`, so no
stock behavior payload can install it even if the behavior tail executes on
Mario.  The module separately checks that fresh allocation clears the raw
words, Mario's script contains no offset command and ORs bit 8 rather than bit
0, and the object traversal assigns `gCurrentObject` from its visited node
before `cur_obj_update`.  For the cross-object alternative, its exact call
chain is `bhvChuckya`/`bhvKingBobomb` -> anchor child -> common anchor ->
`obj_set_gfx_pos_at_obj_pos(gMarioObject,gCurrentObject)`; neither parent is
selected by the audited stock Area-1 regular, macro, or special sources, and
no generated C body directly mentions either parent.  Finally, a non-stock
`+1160` offset at warp-center X/Z is checked to return an accepted timer-131
face observation.  This proves that geometry is not the blocker and leaves a
precise live-memory boundary: current/Mario slot identity, interpreter/table
integrity, dynamic spawn closure, aliases, OOB/external writes, and slot
lifetime.

`proofs/RetailFatalLatch.v` is a handwritten finite scheduler model.  It
imports generated US/JP syntax and packed-data receipts from `ClightFacts.v`,
proves fatal-latch preservation over its explicit event alphabet, and includes
an over-permissive-clear counterexample.  It is not generated Clight and does
not construct a linked small-step execution or memory projection.  The missing
refinement must connect concrete `level_update.c`, Mario behavior dispatch,
clear/reset scheduling, and the `sDelayedWarpOp` memory cell to this model.

`proofs/InkFirstNullRetryNecessity.v` joins the computed static first-NULL
receipt to that fatal-latch model.  Under explicit live projection premises, a
route whose State query is NULL cannot survive a second NULL and later accept
the upper warp; the only viable abstract outcome is a non-NULL Graphics retry.
It does not prove live collision-list traversal or the trace projection.

`proofs/GoombaRaising.v` is a separate handwritten bounded transition and
binary32-arithmetic model.  It distinguishes a selected no-fresh-walk-jump
grounded priming branch from the repeating airborne action-2 H/F/R cycle,
proves exact
velocity `25.0f + (-4.0f) = 21.0f`, computes selected integer-aligned
low-height position runs, exhibits binary32 stagnation at `2^29`, and proves
the conditional Spindel-band and schedule-specific pyramid-top-window bounds.
It does not claim exact-21 position growth for arbitrary binary32 Y.  The US/JP
receipts listed above are logically separate source-shape evidence.  No theorem
links them to the model or inhabits either trace-wide no-A raw-Object schedule,
same-segment PU capture, singleton transport, or height-handoff obligations.

`proofs/TurningAnimation.v` checks Marbler's Turning-Part-2 hypothesis.  The
US/JP generated receipts couple the `forwardVel >= 18.0f` comparison to
animation IDs 188/189, record both local ground-step/setter orderings, tie
`unkB0` to `animYTrans`, inspect the animation-loader footprint, and execute
the renderer's exact field-ratio recognizer.  Its CompCert binary32 kernel
proves `189/189 = 1`, and its three-view metadata model preserves MarioState,
raw Object, and Graphics-anchor coordinates.  The project also records the
HOLP render callback so it does not overgeneralize to “all animations are
gameplay-inert.”  A one-cell DMA-alias counterexample refutes unconditional
memory noninterference in an over-permissive model.  Converter/table mapping,
the retail animation-buffer separation/frame rule, and the linked Clight
before/after projection remain explicit obligations.  The detailed boundary
is in
[`../docs/notes/turning-animation-upwarp.md`](../docs/notes/turning-animation-upwarp.md).

Generated initializer receipts locate the selected lower support faces in the
`SURFACE_WALL_MISC` group, the selected upper face in the `SURFACE_HARD` group,
and all three Area-1 water boxes.  Further generated receipts check that later
non-terrain updates and deactivated-object unloading precede the final
platform query, that the top explosion writes literal zero to `activeFlags`,
that the explode switch case and loop-before-collision-loader initializer
links exist, that unloading calls free-list deallocation, and that final
platform selection reads typed `Surface.object` without inspecting owner
active flags.  The spin/explosion-pose receipts also locate timers `60`/`150`,
yaw cap `0x1800`, vertical speed `5.0f`, and the relevant pose slots.  A
handwritten minimum-pose recurrence starts at home Y and yields the
conservative center-Y target `1871` by timer `150`; it neither executes the
timer-59 smooth-rise state nor proves the needed binary32 lower bound for the
generated Clight.  Therefore the two closed zero-yaw home-pose floor-Y `1791`
witnesses do not discharge the translated/rotated explosion branch.

The projected quicksand sink does not change the State-to-Object copy.  Its
original concrete statement was false: an unrestricted segment could continue
past one return, and aggregate linear slices missed a checked 32-bit
pointer-wrap alias.  The repaired obligation stops at the first matching
return, uses the individual modular four-byte cells, and remains unproved.
The post-copy lifecycle record is not presently a valid proof target despite
its ordered control points.  `behavior_script.c` is now imported, but the
record still permits arbitrary linking/projection and does not construct the
exact link that resolves `cur_obj_update` to that body.  It also needs
external-call frame conditions, a certified memory projection,
pointer-to-pool-slot/epoch linkage, and finite transformed-surface samples.

A retry with Graphics Y in signed-16 range that can select a top floor at Y at
least `1281` requires
Graphics-minus-Object Y separation of at least `385`.  The source audit
identifies `45` as the dry route-specific offset target; `208` is a deliberately
conservative modeled writer relation, not a source-derived global bound.  The
two exact proposed prestates require at least `973`.  The surface, prestate, and
writer obligations are proved predicate-sensitive schemas; each must be
replaced by a concrete linked-run relation.  Complete audited writer-execution
coverage from an audited entry conditionally refutes the exact prestate, but
deriving that coverage from retail US/JP execution is open.  The repaired sink
memory obligation remains open, and the lifecycle interface must be replaced
before any post-copy owner claim.  Concrete free-list membership remains
separate and unproved.

`proofs/Area1PhaseSplit.v` checks the Area-1 fragment writers, macro parents,
rebound source shape, exact PRNG/table values, and one route-sized binary32
three-coordinate displacement.  `proofs/Area1SurfaceWitness.v` proves the
corresponding signed-short query, parsed top-face edge tests, binary32
normal/plane height, 78-unit buffer test, and a competing static-face
candidate.  These modules do not execute the linked helpers over live Clight
memory or prove object-pool lineage, surface ownership/list order, or actual
`find_floor` selection.

`proofs/Area1PlatformExhaustiveness.v` adds a finite stock owner and pre-apply
origin boundary.  Generated Area-1 script/macro records and the four new mesh
bounds support a fifteen-owner inventory.  The theorem
`stock_area1_upper_warp_preapply_platform_null` proves that completed-query, US
spawn-clear, retained-inbound-pointer, and frozen-carry origins are all null
when Mario's old collision object overlaps node `0x1E`.  `[top, box]` is only
one allocator example; source-audited top-yaw, dirt-triangle, and
cartoon-triangle schedules may vary by depth, mist count, zero-angular
allocations, and FIFO eviction without surviving that pre-apply owner
exclusion.  This result excludes pre-existing platform origins only.  It does
not exclude a null first query followed by a Graphics retry and post-snap top
capture.  The open pre-apply boundary is
`Area1StockPreapplyProjectionSound`: no linked Clight memory theorem yet proves
that every relevant retail pre-apply state projects into this finite relation.

## JP first-apply and payload-installer boundary

`proofs/JPSlotLifetime.v` checks generated JP load/spawn/unload/allocation
source shapes, the US/JP platform-clear split, 608-byte object layout in the
generated allocation unit, the 50-record Area-2 macro input, and generic LIFO
list arithmetic.  Its concrete-pointer, linked-layout, current-slot, payload,
and ghost-epoch evidence records remain uninhabited refinement targets.

`proofs/JPFirstApply.v` separates the true first Area-2 platform application
from the first Area-2 controller poll and the following application.  It proves
the conditional finite fresh-load arithmetic: 74 loader allocations plus ten
elevator marker balls gives 84, or 85 with a saved cap; zero-based depths 0–83
or 0–84 are popped respectively.  The source audit places Spindel at allocation
64/free-list depth 63.  The module deliberately leaves a destination-scoped
linked-Clight chronology and ordered allocation census as explicit evidence;
the constants are not presented as execution of the generated program.

`proofs/InkPayloadInstaller.v` formalizes the independent Layer-1 installer
taxonomy and Layer-2 pointer-fate taxonomy.  Its exact finite timer theorem
checks the conditional `F0:131`, `F19:150`, `F20:explode 0` alignment, and its
composition theorem keeps the captured Area-1 allocation owner distinct from a
same-slot replacement payload owner.  The module carries observations and
epochs as data, but does not construct any installer from Clight or assert that
the finite taxonomy exhausts linked retail execution; those refinements remain
named obligations.

The detailed source and fixture audit is
[`docs/notes/jp-first-apply.md`](../docs/notes/jp-first-apply.md).  It treats
Ink's Graphics retry as one possible Area-1 payload installer and separately
classifies the retained JP pointer's destination fate.  No installer is proved
retail reachable, and the successful fixture writes after the true first apply.

## CompCert execution-model boundary

`proofs/CompCertRouteScope.v` uses CompCert's actual `Mem.load`, `Mem.store`,
`Mem.valid_access`, `Clight.step2`, and `Genv.find_funct_ptr` relations.  It
proves that every successful load/store supplies readable/writable access and
that every Clight transition into a call state names a registered function.
Its checked mechanism and ranks 1–3 tables classify defined in-bounds aliases,
logical slot mistakes, stale pool data, scheduler/owner/lifecycle effects, and
known-function retargets as current Clight work; reachable unresolved
externals as requiring an exact effect; invalid access/function targets as
stuck; and ACE, raw post-UB execution, DMA, interrupts, and self-modifying code
as requiring a machine model.  This is a semantic scope theorem, not proof
that the retail MIPS ROM cannot continue after source undefined behavior.

## Archive-derived integration boundary

`proofs/ArchivedProofIntegration.v` rechecks selected source claims suggested
by the six archived projects against the modules above.  Its proved
`ArchivedProofIntegrationKernel` covers:

- platform identifier/call shapes, the US/JP platform-clear direct-call split,
  area direct-callee order, unload-body identifier/call occurrences, and fresh
  allocation-epoch identity;
- current movement, normalized-pole, and Eyerok source shapes;
- narrow held-A, bounded static-quarter-step, normalized integer pole, and
  same-CompCert-block memory lemmas from `proofs/RouteEvidence.v`.

No archived generated module is imported.  The abstract platform model stores
an intended object-pool slot plus a ghost capture epoch used only for
provenance; no C-memory projection or capture-history theorem is proved.
Together, `GameTypes.v` and `UpperEntrance.v` distinguish null, live at the
captured epoch, inactive at that epoch, and reused-slot cases.  This is a case
split, not a proof that every case is reachable or geometrically safe.

The AST certificates remain intentionally syntactic.
`proofs/ClightRefinement.v` records the separate, currently open linked-program,
state/input/event/collision-observation projection, execution-refinement, and
clean-entry coverage obligations.  Layer B non-overlap over the projected
collision observations also remains open.  None of the six archived projects
closes either class of obligation.
See the
[`archived-proof evidence map`](../docs/notes/archived-proof-evidence.md) for the
project-by-project support and non-support boundary.

## Finite source-inventory boundary

`proofs/SourceExhaustiveness.v` is an executable handwritten inventory, not a
generated Clight module.  It proves the seven normal SSL source/index mappings,
the five distinct trigger kinds, coherent active/backup reload preservation,
and the first-target writer classification.  Its general classifier retains
an explicit corruption/unmodeled writer, and its stronger normal-star theorem
requires every writer in the prefix to be one of the modeled normal
interaction/reload cases.  A future Clight theorem must show that every
relevant concrete writer projects into this finite inventory.

## Transcript route-model boundary

`proofs/TranscriptRouteModel.v` is handwritten.  It formalizes a chronological
route-observation contract extracted from the supplied transcript and the
task's stronger post-gate proposal.  It is not generated Clight and is not
presented as one.  `TranscriptRouteGateModel`, the elevator/second-pole closure
properties, `FirstTargetCutClassificationObligation`, and both
downstream-completeness definitions remain obligations.  The first-target
contract enumerates nine bypass class tags for each entrance; this makes the
case vocabulary finite, but the tags carry no state/event evidence and do not
prove that they exhaust a ROM execution.
`proofs/FirstTargetRefinement.v` replaces those tags at the semantic boundary
with indexed before/after Clight states, trace decomposition, projected frame
states, concrete collision-support cuts, and a total abstract event-writer
inventory.  It proves several administrative/anomaly classes impossible and
reduces the remaining work to ordinary/static movement, platform displacement,
object impulses, clips, general coordinate aliasing, and normal reload/entry
movement.  It also proves that endpoint/event alignment alone cannot imply the
old classifier.  No theorem yet constructs this evidence from every target
Clight run or validates a cut against the extracted collision arrays.

`proofs/Area2ElevatorCut.v` and `proofs/Area2LowerTargetCut.v` now perform the
initializer-facing part of that validation.  They extract exact US/JP
triangle/vertex receipts for the elevator candidate and the lower Y=3942
ring/aperture candidate.  The upper moving-relative wall-bounds predicate is
kept separate from the generic absolute-sweep adapter; the lower airborne
portion is four conservative closed binary32 boxes over projected MarioState
position.  Neither is a linked connected-component or collision-hitbox proof.
Both modules expose conditional seven-writer first-crossing reductions and
separate same-frame collision-phase residuals.

`proofs/Area2DownstreamGeometry.v` checks initializer-derived support records
under Act 3 and all five trigger coordinates.
`proofs/Area2DownstreamReceipts.v` keeps the conditional JP observations
separate from `proofs/Area2DownstreamContinuations.v`, whose version-indexed
suffix schema begins at a caller-supplied cut boundary; an optional clean
prefix is a separate composition record.  Abstract paired inputs/events remain
handwritten until one linked projection certifies both lists.  Conditional JP
emulator receipts do not instantiate these suffixes.  The continuation module
also records the transcript's ordered upper 100-coin-star/star-dance and lower
homing-amp/Grindel/elevator-misalignment Act-3 stage lists and names separate upper/lower
suffix obligations.  Stage-to-Clight refinement is still absent.

`proofs/FirstCrossingWriterCoverage.v` corrects two defects in that boundary.
It proves that an unvalidated cut descriptor can put the same state on both
sides, then defines a version/entrance/target-indexed cut family, run-local
initial source/non-target facts, endpoint-local separation, and a minimal pre-target
Clight crossing.  For a crossing projected as a non-target event,
`validated_pre_target_first_crossing_writer_coverage` proves an exhaustive
abstract-event/state-field split: a changed position carries the ordinary
physics, platform displacement, object impulse, collision clip, or area
reload label; an unchanged position must instead change the selected floor or
platform.  Concrete C-writer-to-event-label completeness remains part of the
open projection.
Coordinate alias/out-of-bounds is classified as the cast domain of a physics
endpoint, not as an independent store.  The module also proves nonspatial
administrative-event preservation, the preservation-or-entry form of reload,
a conditional validated-cut reload exclusion, and a local-domain alias
exclusion.  Constructing contracted, chronologically ordered crossings from
linked control points,
proving the family matches the extracted collision mesh and target sample,
closing the six clean-entry motion/domain predicates, and closing the
additional support-selection predicate remain open.

`proofs/OrdinaryMotion.v` isolates the first motion class.  Its admission-free
generic theorem composes caller-supplied finite-cell preservation and
target-exclusion obligations; it does not prove those obligations for retail.
Its upper arithmetic proves non-Wing held-A jump kick and supplied rollout stay
below the integer-translation wall-rejection threshold formed from the raw rim,
the source-backed `+5` surface pad, and the lower query offset.
`proofs/UpperElevatorQuarterStepClosure.v` refines that endpoint model: its
scaled recurrence is checked against every binary32 transition, giving 32
held-A queries with maximum `134` and 40 B-rollout queries with maximum
`224.5`, both below `231`.  It computes the generated quarter-step return codes
as `0,1,2,3,4,6` and checks all direct `init_mario` assignments to the
flags/timer as non-Wing/zero.  `proofs/UpperElevatorWingCapTransitionClosure.v`
then checks the packed Area-1 node-`0x1E` route to Area 2 node `0x14`, the
same-area warp/reinitialization call order, and the initial-cap helper's exact
case labels.  SSL course 8 has cap-course index `-12`, so the reset Wing bit
cannot be restored: ordinary preservation through this transition is excluded
at the defined-source boundary.  A hypothetical post-reset Wing grant has
exactly two above-cutoff samples, `234` and `232`, followed by `230` and `228`;
the module also checks wall-wall-floor-ceiling-water query order and rollout
call order.  No module yet constructs the linked live route/receiver bridge,
descent, elevator selection, surface results, action transitions, or collision
observations.

`proofs/InkFallback.v` supplies a separate writer invariant relevant to the
same class.  State-only ordinary, platform, and PU-sized writes preserve the
collision Object and fallback Graphics views, while any execution covered by
the modeled writer relation preserves a Graphics-minus-Object Y gap at most
`208` and therefore cannot meet the required `385`-unit gap.  The
route-specific dry source audit target is `45`, with a conditional arithmetic
theorem once that premise is derived.  Either exact proposed prestate needs
`973`.  The old writer obligation is only a predicate-sensitive schema;
complete linked Clight writer/action/spawn closure still requires a concrete
replacement relation.  None of these arithmetic results is presented as
global ordinary-motion reachability.  For an accepted fatal request, the
handwritten event system proves the persistent-fatal or
continuation-destroying-reset invariant and rejects the later upper request.
The linked proof of accepted fatal initialization, concrete event projection,
clear/reset barriers, and latch-memory preservation remains open.

`proofs/Area1FirstNull.v` reads the generated US/JP Area-1 collision
initializers, computes the 574 vertices and 962 triangle records, reconstructs
the source-ordered 17-wall/26-floor static cell lists, and runs a pure
source-shaped evaluator for `q = (-2200,768,-1024)`.  The kernel computes all
four static-wall and both static-floor decision lists as all-rejection, then
packages zero-push and `Area1FloorNull`/`-11000.0f` records.  It also derives
the `12/8/5/1` rejection trace, signed-32 bounds, and exact binary32 receipts
for the decisive axis-aligned faces.  The packaged result is not an
independently executed traversal, and the evaluator is not yet a small-step
execution of the
generated allocator/collision functions: live node construction, dynamic
lists, casts, pointers, and clean reachability remain explicit refinements.
`proofs/Area1CachedFloorSplitWitness.v` reuses the same generated parser at the
actual collision query `(-2048,818,-1024)`: the US and JP source-computed
cell-`(6,7)` inventories both contain face `(498,500,501)`, whose finite edge
and height decision is `Area1StaticFloorWouldHit` and whose decoded horizontal
height is `768`.  This is a candidate/list receipt, not execution or proof that
live `find_floor` selects that face.

`proofs/FirstTargetRefinement.v` deliberately preserves the conditional JP
upper-warp/spinning-pyramid-top route.  Its evidence records how the warp and
an object-owned top surface could coincide at Area-1 source node `0x1E`,
platform capture, unload retention, inactive-versus-reused slot epochs, and a
later platform-displacement cut crossing after arrival at Area-2 node `0x14`.
The Area-1 capture/unload history is a separate Clight prelude whose final
Clight state must equal the clean Area-2 run's start; it is not fabricated as
an event after clean entry.  The three named coincidence
families are moving/loading the warp onto the top, moving the top to the warp,
and a collision-preserving clone.  These are evidence constructors, not
reachability results.  No source-backed predecessor or global impossibility
proof for those families has been supplied.

The generated `ssl_script` units use the normal preprocessing configuration.
The source's experimental `SSL_SPAWNING_DISPLACEMENT_TAS_HACK` branch is not
enabled and supplies no target-version reachability evidence.

## Ink installer closure tranche

`proofs/Area1EntryDepthClosure.v` derives exact three-axis
State/Object/Graphics synchronization, the spin-airborne action, and binary32
positive-zero quicksand depth from the existing ordinary-entry memory
postcondition.  It decodes all 46 US and JP Area-1 macro records against the
complete 366-entry preset tables and excludes `bhvDoor` and `bhvDoorWarp` from
both the macro stream and Area-1 script, with exact stream, terminator, and
lower/upper index receipts.  It also proves the direct-source premise omits
normal top-spawned children, defines transitive spawn-closure provenance, and
proves the generic forbidden-behavior lemma.  Executing linked entry, extracting
the full spawn graph, and proving both door behaviors unreachable remain open.

`proofs/JPActionProvenanceCensus.v` checks all 38 generated JP units and finds
exactly eight bodies with a direct field named `_action` assignment.  None of
those bodies embeds the long-jump literal; the existing call census and
source-shape proof continue to identify the A-edge-guarded `act_crouch_slide`
call as the sole direct ordinary long-jump constructor.  This is a
receiver-neutral syntax result, not an alias, indirect-flow, or reachability
theorem.

`proofs/JPBinary32DepthWrites.v` proves finite nonnegative preservation for a
handwritten sink-visible exact CompCert/Flocq binary32 candidate relation.  It
imports no generated writer AST.  From entry
`+0.0f`, its finite/non-overflowing reset, clamp, retail increment/cap,
ordinary landing timer `1..3`, paired quicksand-jump, death, and preserve steps
cannot make Clight's `depth < 0.0f` comparison true.  Linked expression/store
simulation, retail upper bounds, timer provenance, alias/external frames, and
non-interleaving of the quicksand-jump raw store and clamp remain open.

`proofs/JPDestinationChronologyCertificate.v` ties the stale-top destination
arithmetic to the official cleaned JP composite layout.  It checks 608-byte
objects, watched slot offset 37088, twelve in-slot payload-witness ranges, and
exactly one retained cleaned `_gObjectPool` declaration as a
writable/nonvolatile 145920-byte
global, the block-relative watched pointer, and the conditional 131-push/
84-pop non-selection and depth-47 facts.  The supporting nine-module chain is
`proofs/LinkedGlobalInitialMemory.v`,
`proofs/JPObjectPoolCleanedUnitDefmapReceipt.v`,
`proofs/JPObjectPoolLinkorderShape.v`,
`proofs/JPObjectPoolOfficialLinkorderReceipt.v`,
`proofs/CheckedLinkedDefinitionShape.v`,
`proofs/JPObjectPoolOfficialShapeReceipt.v`,
`proofs/JPObjectPoolOfficialDefmapReceipt.v`,
`proofs/JPObjectPoolCleanedUnitReceipt.v`, and
`proofs/JPLinkedObjectPoolInitialMemory.v`.  It transports the exact generated
variable through the successful official cleaned link, resolves its exact
definition-map and global-environment entry, and proves static initial-memory
`Cur Writable` permission for `[37088,37696)`.  Completeness of the payload
access list against the generated AST, byte/payload contents, current-memory
preservation, runtime pointer/epoch binding, extracting the allocation
chronology from small steps, first-apply execution, and retail refinement remain
open.

`proofs/InstallerCoverage.v` proves contradictions for five source-bounded
abstract installer-attempt records and
carries Ink's timer-131 retry into one explicitly conditional trace.  It does
not prove the missing linked stock-provenance projection or clean reachability
of the initial Graphics/Object gap.

`proofs/StockWarpTopMotion.v` checks the exact US/JP stock warp and pyramid-top
scripts and native bodies.  The upper warp has no direct X/Y/Z access or write;
the finite binary32 top mirror covers timers 0 through 150, stays in X
`[-2087,-2007]` and Y `[1536,1879)` with fixed Z `-1023`, and agrees with the
timer-131 surface fixture.  The live Clight-to-mirror and memory-frame
refinement is open, so this narrows rather than excludes stock self-motion;
aliased/external relocation, clones, and identity/epoch changes also remain.

## Stock-projection exhaustiveness tranche

`proofs/PlatformPointerProvenance.v` computes the direct
`gMarioPlatform` writer/caller/address/initializer census over all 38 US and
JP generated units.  The only direct non-null source shape is
`update_mario_platform` loading `Surface.object`; US additionally has a
null-only spawn clear.  Official source-definition provenance and absence of
initializer relocations are packaged, while aliased stores, external frames,
and live value-flow execution remain open.

`proofs/StockProjectionExhaustiveness.v` separates an abstract stock
write-candidate sample from the current collision sample.  Its pure case split
is exhaustive only over a caller-supplied observation/classifier/canonical
map, and distinguishes the modeled candidate relation, canonical identity
outside it, different-slot identity, same-slot different ghost epoch, and
unclassified owner.  A checked separation witness shows the old same-position
relation is insufficient; it proves no store, retention, movement, gameplay
trace, or linked surface-list projection.

`proofs/Area1PrecollisionWriterClosure.v` checks the bilateral generated
pre-collision order and direct-writer footprint.  For the 29 listed stock
Area-1 surface-family bodies per version, it finds no recognized direct Mario
XYZ writer or direct `set_mario_pos` call.  The receipts identify the intended
State-only platform shape.  Its semantic classification is conditional on
`Area1TerrainDispatchXYZFrameObligation`,
`Area1PlatformMarioPhaseClightRefinementObligation`, and
`Area1CollisionXYZFrameObligation`; stock list membership, true branch
execution, transitive helper/action-table closure, receiver and fresh-child
non-aliasing, and external-call frames remain open.

`proofs/Area1PolePushSchedule.v` checks that `cur_obj_push_mario_away` writes
MarioState X/Z but not raw-Object XYZ, that `bhvTree` and `bhvPoleGrabbing`
belong to POLELIKE list 10 before Mario's PLAYER list 0, and that Mario's
callback contains the later State-to-Object copy.  Its bounded value theorem
shows that a completed, correctly targeted copy resynchronizes any such X/Z
push; it does not execute the behavior lists or exclude a skipped, redirected,
or later write.

`proofs/Area1PolePushLinkage.v` ties the exterior palm special preset to
`bhvTree` and checks that a manually derived set of cylinder-push behavior
families is absent from the bounded Area-1 regular and macro initializer data.
It documents, but does not prove by interpreting the packed LevelScript, the
source attribution of the explicit grabbing poles to a later area subscript.
It also does not prove the cylinder caller census, callback-to-behavior
mapping, or closed-world linked reachability.

`proofs/Area1InstallerTemporalClosure.v` models scheduler boundaries rather
than identifying an old query sample with the current collision Object.  It
proves the upper-warp/null invariant across arbitrary active-frame movement,
exact frozen carries, US clear, and JP inbound retention, and rules out a
non-null platform installer inside that temporal stock model.  Its linked
entry/step projection is named but not inhabited.

`proofs/StateFirstPlatformChronology.v` gives an executable last-effective
pointer lineage.  A projected non-null upper-warp apply is exhaustively split
into different query/current samples, canonical identity outside modeled
geometry, noncanonical slot/ghost epoch, unclassified owner, or retained JP
inbound transport.  Linked `gMarioPlatform` framing, live `Surface.object`
slot/epoch classification, skipped-store exclusion, and true pre-apply load
equality remain open.

`proofs/Area1GapApproachCoverage.v` prevents that completed-query lineage
split from being mistaken for a whole-execution mechanism census.  For any
supplied State/Object trace it exposes a first State-endpoint, Object-endpoint,
or joint divergence with an explicit synchronized-prefix certificate.  It
expands a supplied different query/current sample into seven explicit
scheduling/projection routes, retaining the source/projection sample
equalities in each concrete schedule case.  It separately classifies each
split-to-split edge as changing neither endpoint, State only, Object only, or
both, and constructs a fully classified sustained suffix from explicit
trace-local evidence that every post-creator edge preserves the split.  It
also classifies a final pre-collision split through prior state, terrain
writer, platform-refinement escape/effective apply, or collision writer.  The
trace and writer relations remain parameters until linked Clight execution
inhabits them.  Its separate
collision-cache layer classifies any supplied accepted upper-warp observation
as faithful same-frame live provenance or an explicit missed-clear,
receiver/list, stale/wrong/dead-owner, alias/external/corruption, writer, or
overlap-phase escape; it likewise does not derive that observation from the
linked collision pass.

`proofs/Area1PostCopyTailClassification.v` models the supplied frame tail from
a State-to-Object copy observation to the next pre-collision sample.  Its broad
capstone classifies full synchronization preservation versus projected-
coordinate changes, skipped/misdirected copy, endpoint retarget, lifecycle change,
alias/external effects, and scheduler/unclassified residuals.  A broad
classified residual need not change either projected coordinate value.  The
stronger `successful_copy_final_split_requires_value_changing_tail_edge`
theorem assumes a faithful successful copy and a final State/Object split,
skips edges proved to preserve both values, and extracts an actual State-only,
Object-only, or joint value-changing edge.  Both the snapshots and residual
origins remain supplied abstract evidence; no linked SSL Area 1 execution is
constructed.  `SuppliedFrameTail` merely chains caller-authored snapshots and
origin labels; it proves neither generated-source adjacency nor retail
execution semantics.

`proofs/Area1PostPlayerTailSource.v` supplies the corresponding bounded
generated-source receipts.  The bilateral update-order arrays have exact
post-PLAYER suffix `[5; 4; 2; 6; 8; 12; -1]`, but that suffix begins only once
the PLAYER traversal finishes and is not the complete post-copy tail.  The
checked intra-PLAYER receipt orders `spawn_particle` after the copy in
`bhv_mario_update`, then orders `try_do_mario_debug_object_spawn` later in
`bhvMario`; that callback contains a `spawn_object_relative` call, and list
traversal may advance to another PLAYER node.  It proves neither an enabled
guard nor another node's existence.  The two `sParticleTypes` initializer
identifier lists are exactly coupled to 18 paired behavior definitions, each
starting with `8 << 16` (list 8), and exact local syntax forwards the selected
field through `spawn_particle` to `spawn_object_at_origin`.  This proves no
loop/index execution, enabled flag, allocation, visitation, callback execution,
coordinate write, or clean reachability.  The
updater then orders the nonterrain
pass before unload and the final platform query.  The fixed scheduler/
traversal, unload, and final-query bodies have no recognized direct State-
position or receiver-neutral raw-Object XYZ store; dispatched callbacks are
outside that census.  The census also ends at the final query rather than the
complete next-pre-collision boundary: `update_objects` subsequently calls
`try_print_debug_mario_object_info`.  Static roots are not a transitive callback census: the
checked Area-1 `bhvBreakableBox` path reaches
`obj_explode_and_spawn_coins` and then the triangle helper, which requests
list-12 `bhvBreakBoxTriangle`, and the
traversal/allocator receipts expose list mutation as a same-frame possibility.
The module does not prove successful allocation or visitation.  Intra-PLAYER
particle/debug spawning and later PLAYER nodes, transitive spawn/interpreter
closure, receiver and alias identity, external effects, unload/pool reuse,
callback control flow, the post-query debug callback, and the next frame's
warp/instant-warp prefix remain explicit linked-execution residuals.

`proofs/Area1PlayerListTailClosure.v` closes the two immediate-child parts of
that intra-PLAYER residual.  It ties the particle table's 18 exact behavior
operands to list 8 and the debug callback's three exact spawn operands to list
indices `[6;4;4]`; `MainTheorem.v` combines this with the existing
behavior-data census that makes `bhvMario` the sole list-0 script.  Therefore
no ordinary Mario post-copy particle or debug child can create a later PLAYER
node.  A purported later node may still pre-exist or come from another callback, pointer
forwarding, a valid alias/specified external effect, or a list/slot lifecycle
violation; linked execution still has to exclude or exhibit those cases.

`proofs/Area1Rank1ResidualClosure.v` closes the ordinary named-source portion
of the later-PLAYER residual and audits the separate live-floor-owner data
structure.  It proves one `bhvMario` initializer occurrence, no internal-body
mention, the exact two callers of `spawn_objects_from_info`, and the existing
sole-list-0 result.  For floor lineage it combines the exact two
`Surface.object` writers with a whole-union alias-form census: no whole
`Surface` or `SurfaceNode` copies, no unresolved direct/builtin/indirect typed
pointer handoffs, four exact `Surface *` derivation sites containing only
identity casts and the allocator pool addition, and one analogous node-pool
addition.  `SurfaceNode.surface` is written only by `add_surface_to_cell`, and
`next` only by allocation, partition clearing, and insertion.  This is not a
live Clight trace: wrong `gCurrentObject`, previously escaped or type-punned
aliases, independently reachable outside effects, and stale surface/object
epochs remain semantic obligations.

`proofs/Area1Rank1SixResidualAudit.v` separates those six semantic obligations
by outcome.  Across the canonical owners' fixed 93-function direct closure,
none of the three whole-program `gCurrentObject` writers is reachable and the
only indirect call is `cur_obj_call_action_function`; the exact Tox Box and
exclamation-box target arrays contain no current-object writer and have no
ordinary internal store.  The behavior/list census fixes the four direct
`Object.behavior` writers, the three `next`/`prev` writers, and the sole
constructor chain through `create_object`; all four list-root writers copy
`gObjectListArray`, and the only two `gMarioObject` writers are area spawn and
clear.  The sound-spawner behavior selects list 12, not PLAYER.  The stock
upper-warp and low-Y queries are null.  The file also proves the important negative boundary:
both surface pointers are public, both arise from `main_pool_alloc`, and a
public pointer cell holding a pool address forces that pointee block to be
mapped by a CompCert self-injection.  Surface storage therefore needs
subrange separation against generic main-pool aliases and exact external
effects; it cannot reuse the private-action-table omission argument.  Of the
six unresolved names, authenticated JP `sqrtf` is independently store-free.
Finally, the inactive/unreused cached-object survivor is checked both in the
bounded model and against the authenticated JP first-apply receipt.  It is a
real downstream carrier, not the missing initial floor installer.

`proofs/Area1PostCopyObjectWriterClosure.v` closes two narrower branches of
that post-copy/sample-mismatch search.  Its 38-unit US and JP partitions prove
that direct receivers designating Mario's raw Object and assigning XYZ occur
only in `init_mario`, `butterfly_calculate_angle`, and `check_instant_warp`;
broader-origin and receiver-normalization receipts find no additional direct
spelling.  Phase exclusion reduces the post-copy direct-designated case to the
butterfly callback.  `proofs/Area1ButterflyStaticOriginClosure.v` then proves
that SSL Area 1's macro stream, regular level-script initializers, and selected
special presets `{0, 101, 125}` do not select `bhvButterfly`.  This is not a
complete transitive/live provenance result.  The Object-writer module also
proves that preserving collision X/Z while snapping to explicit cached
Y=`768`, then completing the State-to-Object copy, leaves the sample inside
the upper warp and forces a null finite-stock platform query.  Alias receivers,
indirect/forged callbacks, external stores, retarget/lifecycle effects,
abnormal control, and displaced live floor selection remain open.

`proofs/Area1InteractionShortCircuitClosure.v` checks the exact bilateral
accepted nonfading warp path through table index `4`, the nonzero
`ACT_DISAPPEARED` return, and the interaction-loop break.  Its runtime theorem
is conditional on supplied live dispatch, receiver, alias/external-frame, and
completed-copy/query facts.  Within those premises, later handlers cannot run
and only cached-floor Y can change the selection sample.
`proofs/Area1CachedFloorSelectionClosure.v` closes that finite-model branch for
all same-sample accepted floors: upper-warp contact bounds the cached floor by
Y=`896`, and preserved warp X/Z at that height cannot select any modeled stock
owner.  Live binary32 floor-return refinement and dynamic-owner/list projection
remain explicit premises.

`proofs/Area1CachedFloorSplitWitness.v` instantiates the source-shaped
interaction schedule with collision Object `(-2048,818,-1024)`, cached-floor
State/copy/final-query `(-2048,768,-1024)`, and exact delta `(0,-50,0)`.  Its
general theorem proves the accepted cached-floor branch preserves X/Z; a
separate bound requires more than `459` upward units for top capture, while the
concrete split moves downward and its conditional stock query is null.  The
construction contains no A-input premise.  Zero-A reachability of Y=`818`,
live list traversal and face selection, indirect dispatch/return/break,
receiver and copy identity, alias/external frames, owner projection, and
lifecycle linkage are still not derived from selected-program execution.

`proofs/Area1SchedulerSurfaceLifecycleSplit.v` composes that schedule boundary
with generated-source-union checks of recognized direct explicit syntax over
the US and JP units.  For `sTransitionUpdate`, it enumerates the explicit
global-assignment sites, direct `level_set_transition` caller bodies, exactly
four direct call occurrences, and the four audited callback-argument shapes;
it also finds no recognized direct address-taking or initializer relocation.
For `Surface.object`, it finds only `alloc_surface` and
`load_object_surfaces` as explicit field-assignment bodies, checks null
initialization, checks that the unique recognized direct non-null write copies
`gCurrentObject`, and proves that the same local surface temporary reaches
`add_surface(..., 1)` with zero intervening temporary sets.  These are direct
syntax facts only: whole-struct/builtin surface mutation, pre-existing aliases
of the pointed-to surface, external stores, and the runtime target of an
indirect callback are not framed.

At the finite semantic layer, the same module couples the collision and final-
query positions through one `UpperWarpSelectionPositionSchedule`: a supplied
accepted scheduler event plus a non-null stock-owner result gives the final-
query event and unequal schedule samples.  Adding an arbitrary separately
supplied `CachedApplyPayloadFate` does not change the proof; this is logical
independence, not lifecycle/query trace coupling or ordering.  Its separate
inactive/freed/unreused payload witness shows why excluding fresh same-slot
reuse does not close stale-payload use.  Live scheduler execution, query/list
traversal, owner identity, alias/external framing, and lifecycle-to-memory
coupling remain open.

`proofs/Area1MovingSkippedQueryClosure.v` checks that, in the audited generated
normal/basic/object-warp source shapes, coordinate-moving area and instant-warp
paths precede a full same-frame platform query; delayed-warp source installs a
null callback for the two query-free frames, whose checked bodies have no
direct Mario-view/platform syntax.  The
result is not whole-scheduler linked exhaustiveness; callback targets,
external/non-alias frames, play-mode reachability, and null-object lifecycle
remain open.

`instrumentation/jp-clean-gap-search/` now also records the authentic original-
JP controller evidence for this rank-1 search after an externally enabled
level-select entry; ordinary-entry equivalence is unproved.  Mode 7 reaches
the two eastern detectors with zero A.  Modes 9 and 10 each reproduce that
checkpoint and
pointer-identified southeast/northeast Tweester relays, then reflect from the
central pyramid and die before the west Tweester or western detectors.  Both
8,000-frame runs leave the top unstarted and observe no positive sampled gap;
they reject only those bounded schedules.  Mode 12 now independently completes
all four pillars and the upper warp on authenticated JP with zero A, then
loads Area 2.  The paired `jp-rank1-live-boundary` run audits all 2,462 frames,
149,578 floor returns, and the top's one-frame pending-clear lifecycle; it
finds no useful split or cached top on that successful schedule.

`proofs/DefaultArea1Rank1ResidualCapstone.v` uses the declared null seed to
remove retained JP inbound lineage and expands a supplied completed-query
sample difference into seven approaches.  The companion
`proofs/DefaultArea1Rank1BoundaryUnderdetermination.v` constructively proves
the current active-preapply wrapper cannot support a sound rank-1
impossibility theorem: it relates the projection to the run only through
version and the initial null seed, so a fabricated top-query projection is
admissible for any nonvacuous JP run.  This diagnoses the missing linked
run-to-preapply construction; it is not a retail counterexample.

`proofs/Area1Rank1OrdinaryBridgeNoGo.v` is the source-level integration
capstone, not a linked-retail closure.  Its `Type`-valued bridge keeps five
premises inspectable: same-frame modeled scheduling, upper-warp contact,
selected cached-floor refinement, the existing accepted
dispatch/selection-sample/alias/external/final-receiver projection, and the
stock surface-owner/list/final-query refinement.  Given all five, every
top install contradicts the ordinary cached-floor null-query theorem,
independently of an arbitrary separately supplied cached-payload fate; the fate
argument is unused and no chronology is coupled.  The aggregate also retains
the concrete `(0,-50,0)` downward/null witness and the schedule-coupled
distinct-sample theorem for every modeled non-null top query.  No theorem
constructs those five bridge fields from a clean linked run or claims
uniqueness of all retail splits.

`proofs/Area1PostCopyAliasCallbackClosure.v` checks the direct post-copy
alias/callback boundary.  It gives an exact bilateral nine-function census of
raw-XYZ direct-store formal receivers and their receiver ABI, proves the
whole-corpus one-hop designated `gMarioObject`/`marioObj` call census empty,
and checks the particle and debug-spawn child-copy wrapper chains.  A CompCert
memory frame shows that a store through a distinct valid object slot preserves
Mario's raw coordinate, so any changed load must use Mario's slot.  The result
does not establish current-node identity, allocation freshness, transitive
wrapper closure, indirect/external framing, or lifecycle/retarget separation.

`proofs/LinkedPlatformLineageSyntax.v` lifts the earlier source-union census to
the constructed official cleaned US and JP definition lists. It closes the
visible direct named-writer and address-taking syntax upper bounds and bounds
every retained internal direct updater caller to the name `update_objects`.
  Its original five-field closure record remains a sufficient conditional
  interface only.  When a supplied pre-apply projection uses the scoped
  null-start seed, the chronology removes retained JP-inbound lineage and exposes
  a four-field interface.  The run-to-projection bridge and all four live fields
  remain uninhabited from clean linked execution.

`proofs/JPLinkedPlatformGlobal.v` extracts the exact generated JP
`Surface.object -> temporary -> gMarioPlatform` statement and the apply
function's leading global load. Real `Clight.step2` lemmas execute the
individual local store and load statements under explicit premises and an
abstract global environment. The starting fragment, concrete official-
globalenv/symbol/block resolution,
`Surface.object` evaluation, and
intervening cell preservation are premises; declaration storage details,
`find_floor` branch reachability, owner classification, pointer block/offset,
allocation epoch, and whole-fragment execution remain open; complete
sequence/skip trace composition is also pending.

`proofs/Area1QueryScheduleClosure.v` computes intraprocedural generated
call/guard receipts and proves a separate finite schedule model from
cached-platform application through interaction, State-to-Object copy, unload,
and the final platform query.  An upper-warp action-selection frame has a
later query in that model.  The retry-null branch can select
`ACT_DISAPPEARED` after requesting death but is not a successful warp under
the separate fatal-latch boundary.  Its exact US/JP AST receipt additionally
ties `gMarioObject.rawData.asF32[6..8]` to the three temporaries passed to
`find_floor`.  Linked branch execution, preservation of that Object sample to
collision, alias/external frames, and provenance of any post-copy discrepancy
remain open.

The focused `proofs/PlatformUpdateSourceReceipt.v`,
`proofs/USPlatformUpdateRepairReceipt.v`,
`proofs/JPPlatformUpdateCleanedReceipt.v`, and
`proofs/SelectedPlatformUpdateBodyResolution.v` chain transports that exact
body through the selected US repair and JP official-cleaned link.  It pins the
query AST receipt to both selected `update_mario_platform` bodies, but proves
no call reachability or query-to-collision memory frame.

`proofs/Area1SurfaceOwnerSyntax.v` checks the exact bilateral loader order from
`gCurrentObject` to `Surface.object`, followed later by an
`add_surface(surface, 1)` call with the same syntactic surface-temporary
identifier.  Each dynamic loader has exactly one direct `add_surface` call and
all such calls use flag `1`; each static loader likewise has exactly one direct
call and uses flag `0`.  The direct-source-union follow-up in
`Area1SchedulerSurfaceLifecycleSplit.v` proves that the local surface temporary
has no intervening reassignment before that call.  It does not prove call-site
reachability, preserve the pointed-to `Surface.object` cell through aliases or
externals, or establish live owner identity, surface-list integrity, and
object-pool slot/epoch provenance.

`proofs/Area1SurfacePoolRangeSeparation.v` supplies the next semantic layer.
It reconstructs the two left allocations from generated `SurfaceNode` and
`Surface` sizes, imports a read-only JP receipt for their four endpoints and
live main-pool heads, and proves an inductive no-rewind epoch invariant.  An
exact whole-generated-program census lists all eleven `main_pool_alloc`
callers, all main-pool state writers, and every mention/address use of the two
surface-pool globals.  CompCert `Mem.store`/`storebytes` frame lemmas reduce a
failed protected-byte frame to an actual same-block overlap, rather than mere
possession of a type-punned pointer.  The companion retail receipt
authenticates five direct outside roots (163 instructions, 29 stores, 11
calls); prior certificates cover `sqrtf` and sound stopping.  A live
frame/insert/clear list trace carries owner provenance into the finite stock
query.  Real Clight-step membership, safe allocator restore/free behavior,
transitive camera/object/audio descriptor validity, and the final live query
selection still require the continuous execution bridge.

`proofs/Area1Rank1LiveBoundaryReceipt.v` supplies the first concrete execution
of that bridge.  The hash-gated read-only JP audit spans one complete
`update_objects` frame at timers 348–349 and watches both KSEG0/KSEG1 aliases
of the node pool, surface pool, spatial partitions, allocator globals, and
pool-pointer cells.  Its exact receipt records the adjacent graphics-pool
allocation/free and all four head/free-space stores; 238 safe protected-pool
writes; 776 safe dynamic-partition writes; six owner stores paired with six
insertions; intact, complete object/static/dynamic lists; and the final stock
static surface-808 query.  Only the already-certified store-free `sqrtf` is
reached among the narrowed outside roots.  The Coq module checks the exact
counts, allocation separation/head sequence, list/owner verdicts, selected
surface payload, and stock projection.  This is a concrete baseline-frame
theorem; an upper-warp trace or universal linked invariant remains necessary.

`proofs/Area1Rank1UpperWarpTraceReceipt.v` supplies the requested finite
upper-warp extension.  Search mode 12 independently executes four pillar
touches, top explosion, a west jumping-box ascent, B-only rollout, upper-warp
use, and the Area-2 load on authenticated original JP with zero A input.  The
read-only boundary audit covers 2,462 consecutive frames and all 149,578
`find_floor` entry/return pairs, including 426 dynamic returns whose installed
owners are checked live and linked at return time.  Mario's final platform is
ownerless/static in every frame.  The top explosion's six inactive-owner
surfaces are recorded as pending clear: no query returns them, and the next
clear precedes all queries.  The Coq module checks the exact route, aggregate,
lifecycle, and no-useful-split receipt.  This is trace-scoped; a universal
linked invariant over other controller histories remains necessary for a
route-wide impossibility claim.

`proofs/Area1SurfaceEpochLifecycle.v` separates the allocation that supplied a
query surface from the payload resident at the cached raw address when it is
later applied.  It exhaustively classifies live same-epoch, inactive/freed
same-epoch, fresh same-slot epoch, and invalid/aliased payload fates.  Its
executable epoch-4-to-5 reuse witness creates an abstract State/Object split
and proves that clearing dynamic surfaces does not clear the cached pointer.
This is a conditional countermodel, not linked reachability; the exact
deactivate/load/unload/query/clear/reuse/apply trace, free-list choice, payload
bytes, and geometry remain open.

`proofs/PlatformExternalGapSemantics.v` and
`proofs/PlatformAliasExternalClosure.v` reduce a defined one-store divergence
to an Object or State endpoint, force a harmful unresolved external into its
explicit writer/lifecycle refinement, and exclude ordinary official
address-taking/initializer alias origins.  Reachable pointer provenance and
callsite-specific external frames remain open.

`proofs/Area1WarpTopCloneCensus.v` enumerates the static top/warp references
and all 21 direct `Object.collisionData` writer bodies, proves every direct
allocator assignment to that field is null, checks top-child source shapes,
and shows ordinary pose-copy helpers do not copy behavior or collision
identity.  Successful allocator execution, runtime behavior arguments,
replayed spawning, receiver reachability, generic coordinate writes, and exact
slot/epoch/list ownership remain open.

`proofs/Area2HypotheticalPoleLongJump.v` is the conditional future-machine
receipt for the lower Area-2 pole.  It checks the exact US/JP two-word
pole-handler/knockback payload, the stock damage-to-long-jump setter constants,
and a five-frame binary32 clear trajectory into the authenticated lower target
air.  Its early-install split records that a knockback-only edit leaves the
stock grab handler intact but has no grab/climb/handstand consumer, while a
static pole-handler replacement changes the first contact too; generated
automatic actions dispatch the top action directly and read none of the three
writable tables.  The retail write/timing/setter/collision witness remains the
uninhabited `HypotheticalPoleLongJumpRetailBridge`.  The readable account is
`docs/notes/hypothetical-pole-long-jump-mutation.md`.
