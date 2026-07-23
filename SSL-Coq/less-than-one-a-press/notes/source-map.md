# Source-to-Clight map

All rows are translated twice, once with `VERSION_US` and once with
`VERSION_JP`, from decomp commit
`9921382a68bb0c865e5e45eb594d9c64db59b1af`.  There are 27 translation
units per version and therefore 54 generated Clight modules.

Each row is a whole translation unit: every function/global retained by the
preprocessor is translated, not only the functions named below.  The
"Inspected boundary" column identifies why the unit is imported and which
source shapes are currently queried.  Identifier/constant/assignment/call
checks do not by themselves prove dataflow, control dependence, loop execution,
or a whole-program semantic effect.

| Source | Generated stems | Inspected boundary |
| --- | --- | --- |
| `src/game/game_init.c` | `*_game_init.v` | `read_controller_inputs`; assignment operator shape for `buttonPressed` only, not operand/dataflow identity |
| `src/game/mario.c` | `*_mario.v` | `update_mario_button_inputs`; pressed/down field and input-bit constant occurrences |
| `src/game/mario_actions_airborne.c` | `*_mario_actions_airborne.v` | airborne action handlers and movement writers imported for Layer B callgraph and writer coverage; no complete execution refinement yet |
| `src/game/mario_actions_automatic.c` | `*_mario_actions_automatic.v` | pole positioning, holding-pole and top-of-pole source shapes used by the normalized-pole subcase |
| `src/game/mario_actions_cutscene.c` | `*_mario_actions_cutscene.v` | `act_spawn_no_spin_airborne` and `launch_mario_until_land`; checked call/Float32-argument shapes anchor the zero-forward-speed entry update before `perform_air_step` |
| `src/game/mario_actions_moving.c` | `*_mario_actions_moving.v` | walking, braking, slope deceleration, ground-step and move-punching source shapes used by the parallel-universe completeness audit |
| `src/game/mario_actions_object.c` | `*_mario_actions_object.v` | object-interaction action handlers imported for Layer B action/writer coverage; no complete execution refinement yet |
| `src/game/mario_actions_stationary.c` | `*_mario_actions_stationary.v` | stationary action handlers imported for Layer B action/writer coverage; no complete execution refinement yet |
| `src/game/mario_step.c` | `*_mario_step.v` | ground and air quarter-step loops, `find_floor` calls, and gravity source shape |
| `src/game/interaction.c` | `*_interaction.v` | `interact_star_or_key` field/constant occurrences and direct save call; `interact_coin` spawn call/index constant; extraction dataflow is pending |
| `src/game/save_file.c` | `*_save_file.v` | direct call from `save_file_collect_star_or_key` to `save_file_set_star_flags`; `save_file_reload` backup-copy/file source shape; the bit-update and copy memory effects are not yet proved |
| `src/game/object_collision.c` | `*_object_collision.v` | `detect_object_hitbox_overlap` collision-list field occurrence/assignment; execution and the handwritten collision projection are pending |
| `src/game/object_list_processor.c` | `*_object_list_processor.v` | direct-callee order in `update_objects`, platform-clear call split, and unload-body identifier/call occurrences; loop/state effects are pending |
| `src/game/spawn_object.c` | `*_spawn_object.v` | allocation/unload assignment and call occurrences relevant to activation, respawn fields, and reuse; memory effects are pending |
| `src/game/object_helpers.c` | `*_object_helpers.v` | default/no-exit star spawn helpers and target behavior parameters |
| `src/game/obj_behaviors.c` | `*_obj_behaviors.v` | hidden controller/trigger constant, field, assignment and direct-call shapes; no checked five-count control dependence |
| `src/game/obj_behaviors_2.c` | `*_obj_behaviors_2.v` | Eyerok hand attack check, movement/update order, death, and coin-spawn source shapes |
| `src/game/behavior_actions.c` | `*_behavior_actions.v` | `bhv_pole_init` hitbox-field assignment shape used by the normalized-pole source audit |
| `data/behavior_data.c` | `*_behavior_data.v` | star, hidden-controller and hidden-trigger behavior bindings |
| `src/game/area.c` | `*_area.v` | direct `unload_area`/`load_area` call order in `change_area`; lifecycle execution is pending |
| `src/game/level_update.c` | `*_level_update.v` | direct `change_area` occurrence in `check_instant_warp`, game-over reload call, and airborne entry-action constant/call source shape |
| `src/game/platform_displacement.c` | `*_platform_displacement.v` | `gMarioPlatform`/validation-field identifier occurrences, direct displacement/floor calls, and global assignment shape; pointer dataflow is pending |
| `src/engine/surface_collision.c` | `*_surface_collision.v` | floor and surface query implementation used by Mario stepping and platform recomputation; imported for future semantic refinement |
| `src/game/macro_special_objects.c` | `*_macro_special_objects.v` | spawn call and respawn-field assignment occurrences; persistence semantics are pending |
| `levels/ssl/script.c` | `*_ssl_script.v` | raw initializer tuples for lower/upper airborne entry objects, the area-2 static star, hidden controller, and instant-warp declarations |
| `levels/ssl/areas/2/macro.inc.c` via `inputs/ssl_area2_macro.c` | `*_ssl_area2_macro.v` | raw initializer tuples for five Puzzle trigger records/coordinates; the abstract state now assigns exact kinds/references/positions, while their concrete spawn-memory projection remains pending |
| SSL collision arrays via `inputs/ssl_collision.c` | `*_ssl_collision.v` | area 1/2/3 static arrays plus pyramid-top, tox-box, grindel, spindel, moving-wall, elevator, and Eyerok object collision arrays; checked word counts and US/JP initializer identity, but no parsed-surface or connected-component theorem |

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
[`archived-proof evidence map`](../docs/archived-proof-evidence.md) for the
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

The same module deliberately preserves the conditional JP
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
