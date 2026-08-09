# Source-to-Clight map

All rows are translated twice, once with `VERSION_US` and once with
`VERSION_JP`, from decomp commit
`9921382a68bb0c865e5e45eb594d9c64db59b1af`.  There are 38 translation
units per version and therefore 76 generated Clight modules.

Each row is a whole translation unit: every function/global retained by the
preprocessor is translated, not only the functions named below.  The
"Inspected boundary" column identifies why the unit is imported and which
source shapes are currently queried.  Identifier/constant/assignment/call
checks do not by themselves prove dataflow, control dependence, loop execution,
or a whole-program semantic effect.  The array-slot recognizer is
base-insensitive and direct-callee/literal checks are path-insensitive.

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
| `src/game/interaction.c` | `*_interaction.v` | `interact_star_or_key` field/constant occurrences and direct save call; `interact_coin` spawn call/index constant; `interact_warp` action constant in the PU phase pipeline; `push_mario_out_of_object` wall-call/State-position/no-Graphics receipts; extraction dataflow and exact wall-call arguments are pending |
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
| `src/game/platform_displacement.c` | `*_platform_displacement.v` | `gMarioPlatform`/validation-field identifier occurrences, State position writes, object-position reads for final selection, X/Z-but-not-Y velocity slot reads, direct displacement/floor calls, and global assignment shape; pointer/matrix dataflow is pending |
| `src/engine/math_util.c` | `*_math_util.v` | full `mtxf_rotate_zxy_and_translate` body and `gSineTable` initializer; the linked memory execution that constructs the platform matrix remains pending |
| `src/engine/surface_collision.c` | `*_surface_collision.v` | `find_floor` binary32-to-signed-16 cast shape and 78-unit floor buffer, plus the floor/surface query implementation used by Mario stepping and platform recomputation; ordinary-motion receipts check the wall list's strict `y > upperY` rejection; Ink receipts check the X/Y/Z result-pointer writes, absence of a wall-list Y-field mutation, and absence of direct Graphics references; the concrete CompCert cast result and matching authenticated US/JP retail instruction fragment are checked, while linked execution, pointer disjointness, caller closure, and actual surface-selection refinements remain pending |
| `src/engine/surface_load.c` | `*_surface_load.v` | surface allocation/insertion, object-vertex transformation, object-surface loading, normal construction, and collision-model loading; exact ordinary-motion receipts check `read_surface_data`'s `upperY = maxY + 5`; Goomba/Spindel receipts check full-float distance/collision-distance reads, transform/load calls, float-matrix helpers, and explicit binary32-to-s16 vertex narrowing; live object/surface memory execution, compiled out-of-range cast behavior, and list ownership/order remain pending |
| `src/game/macro_special_objects.c` | `*_macro_special_objects.v` | spawn call and respawn-field assignment occurrences; persistence semantics are pending |
| `levels/ssl/script.c` | `*_ssl_script.v` | raw initializer tuples for lower/upper airborne entry objects, the area-2 static star, hidden controller, and instant-warp declarations; exact packed records for the Area-1 `0x0A`, `0x1E`, `0x1F`, and `0x20` warp objects, all five local warp-node routes, and the stock pyramid top, with checked coordinate/behavior-byte arithmetic |
| `levels/ssl/areas/1/macro.inc.c` via `inputs/ssl_area1_macro.c` | `*_ssl_area1_macro.v` | exact Area-1 wing-cap/exclamation, breakable-box, message-panel, cannon, and shell-box records used by the fragment and finite stock-owner audits; generic top-yaw/dirt-triangle/cartoon-triangle schedule lineage is no longer a Layer-B obligation, while linked-memory projection remains pending |
| `levels/ssl/areas/2/macro.inc.c` via `inputs/ssl_area2_macro.c` | `*_ssl_area2_macro.v` | raw initializer tuples for five Puzzle trigger records/coordinates; the abstract state now assigns exact kinds/references/positions, while their concrete spawn-memory projection remains pending |
| SSL collision arrays via `inputs/ssl_collision.c` | `*_ssl_collision.v` | area 1/2/3 static arrays plus pyramid-top, tox-box, grindel, spindel, moving-wall, elevator, Eyerok, breakable-box, exclamation-box-outline, cannon-lid, and wooden-signpost object collision arrays; checked word counts and US/JP initializer identity; the complete 39-word top initializer is parsed into five vertices and six triangle-index triples; exact local bounds are proved for four Area-1 fixed-owner meshes; all 20 elevator vertices and selected Area-2 pole/ring vertices have exact receipts, but no linked transformed dynamic `Surface`, actual `find_floor` selection, general parsed-surface, or connected-component theorem exists |

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
  retail semantics.  Repaired-program success, the concrete global/public and
  name-based memory instances, whole-expression/internal-step simulation, and
  reachable `EF_external` frames remain open.

`proofs/OrdinaryArea1EntryMemory.v` maps the ordinary Area-1 entry through
`ssl_script`, `level_script`, `level_update`, `mario`, `object_list_processor`,
and `platform_displacement`.  Generated receipts identify node `0x0A`,
`bhvSpinAirborneWarp`, spawn type `0x16`, and action `0x1924`; layout/symbol
facts and an explicit postcondition imply exact State/raw Object/Graphics
synchronization.  The actual entry `Smallstep.star`, castle routing, behavior
lookup, external-call frames, controller predecessor, object-access bounds,
and full pool/list ownership remain open.

`proofs/JPGeneratedWriterCensus.v` concatenates definitions only for a
receiver-neutral syntactic census while preserving the 38-unit boundaries.
It counts assignment-bearing functions, not stores: 33 for `pos[1]`, 215 for
raw-data slot 7, 180 for raw-data slot 10, and 15 whose LHS mentions
`throwMatrix`.  It also isolates eight direct `quicksandDepth` writers and six
direct automatic-dialog constructors.  Receiver identity, aliasing, calls,
actions, flags, reanchoring, and lifecycle still require semantic refinement.

`proofs/JPZeroAReachability.v` defines a zero-edge relation over `Clight.step2`
and the live controller `buttonPressed` cell.  Program, controller address, and
entry are parameters, so it does not establish a clean JP run.  Its global
`<960` composition is conditional on total three-view projection and per-step
writer refinement.
`proofs/JPQuicksandDepth.v` separately closes one live-range arithmetic case:
`768.5f` followed by 381 exact sinks ends at `1778.1593017578125f`, converting
to integer coordinates separated by `1010`.  It does not install the negative
depth/action state or prove 381 unreanchored calls reachable.

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

`proofs/RetailFatalLatch.v` is a handwritten finite scheduler model.  It
imports generated US/JP syntax and packed-data receipts from `ClightFacts.v`,
proves fatal-latch preservation over its explicit event alphabet, and includes
an over-permissive-clear counterexample.  It is not generated Clight and does
not construct a linked small-step execution or memory projection.  The missing
refinement must connect concrete `level_update.c`, Mario behavior dispatch,
clear/reset scheduling, and the `sDelayedWarpOp` memory cell to this model.

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

`proofs/FirstCrossingWriterCoverage.v` corrects two defects in that boundary.
It proves that an unvalidated cut descriptor can put the same state on both
sides, then defines a version/entrance/target-indexed cut family, an
entrance/entry contract, endpoint-local separation, and a minimal pre-target
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
Its upper arithmetic proves non-Wing 4-unit-gravity held-A jump kick and conservatively
supplied rollout stay below the integer-translation wall-rejection threshold
formed from the raw rim, the source-backed `+5` surface pad, and the lower
query offset.  The companion Wing-Cap arithmetic countermodel proves
`220 < 228 < 231`, explaining why `MarioState.flags` and `capTimer` must be
part of the clean-entry projection without claiming a wall-clearance witness.
The module names source execution, cap state, intermediate-query, and
collision-observation linkage obligations rather than presenting raw
initializer and AST receipts as a retail execution theorem.

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
84-pop non-selection and depth-47 facts.  Completeness of the payload access
list against the generated AST, resolving the declaration to the
actual official-link initial/current-memory block, extracting the chronology
and epoch from small steps, and executing first-apply loads remain open.

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
