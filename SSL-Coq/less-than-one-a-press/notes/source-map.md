# Source-to-Clight map

All rows are translated twice, once with `VERSION_US` and once with
`VERSION_JP`, from decomp commit
`9921382a68bb0c865e5e45eb594d9c64db59b1af`.  There are 25 translation
units per version and therefore 50 generated Clight modules.

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
| `src/game/mario_actions_moving.c` | `*_mario_actions_moving.v` | walking, braking, slope deceleration, ground-step and move-punching source shapes used by the parallel-universe completeness audit |
| `src/game/mario_actions_object.c` | `*_mario_actions_object.v` | object-interaction action handlers imported for Layer B action/writer coverage; no complete execution refinement yet |
| `src/game/mario_actions_stationary.c` | `*_mario_actions_stationary.v` | stationary action handlers imported for Layer B action/writer coverage; no complete execution refinement yet |
| `src/game/mario_step.c` | `*_mario_step.v` | ground and air quarter-step loops, `find_floor` calls, and gravity source shape |
| `src/game/interaction.c` | `*_interaction.v` | `interact_star_or_key` field/constant occurrences and direct save call; `interact_coin` spawn call/index constant; extraction dataflow is pending |
| `src/game/save_file.c` | `*_save_file.v` | direct call from `save_file_collect_star_or_key` to `save_file_set_star_flags`; the bit-update expression is not yet checked |
| `src/game/object_collision.c` | `*_object_collision.v` | `detect_object_hitbox_overlap` collision-list field occurrence/assignment; execution and the handwritten collision projection are pending |
| `src/game/object_list_processor.c` | `*_object_list_processor.v` | direct-callee order in `update_objects`, platform-clear call split, and unload-body identifier/call occurrences; loop/state effects are pending |
| `src/game/spawn_object.c` | `*_spawn_object.v` | allocation/unload assignment and call occurrences relevant to activation, respawn fields, and reuse; memory effects are pending |
| `src/game/object_helpers.c` | `*_object_helpers.v` | default/no-exit star spawn helpers and target behavior parameters |
| `src/game/obj_behaviors.c` | `*_obj_behaviors.v` | hidden controller/trigger constant, field, assignment and direct-call shapes; no checked five-count control dependence |
| `src/game/obj_behaviors_2.c` | `*_obj_behaviors_2.v` | Eyerok hand attack check, movement/update order, death, and coin-spawn source shapes |
| `src/game/behavior_actions.c` | `*_behavior_actions.v` | `bhv_pole_init` hitbox-field assignment shape used by the normalized-pole source audit |
| `data/behavior_data.c` | `*_behavior_data.v` | star, hidden-controller and hidden-trigger behavior bindings |
| `src/game/area.c` | `*_area.v` | direct `unload_area`/`load_area` call order in `change_area`; lifecycle execution is pending |
| `src/game/level_update.c` | `*_level_update.v` | direct `change_area` call occurrence in `check_instant_warp` |
| `src/game/platform_displacement.c` | `*_platform_displacement.v` | `gMarioPlatform`/validation-field identifier occurrences, direct displacement/floor calls, and global assignment shape; pointer dataflow is pending |
| `src/engine/surface_collision.c` | `*_surface_collision.v` | floor and surface query implementation used by Mario stepping and platform recomputation; imported for future semantic refinement |
| `src/game/macro_special_objects.c` | `*_macro_special_objects.v` | spawn call and respawn-field assignment occurrences; persistence semantics are pending |
| `levels/ssl/script.c` | `*_ssl_script.v` | raw initializer tuples for the area-2 static star, hidden controller, and instant-warp declarations |
| `levels/ssl/areas/2/macro.inc.c` via `inputs/ssl_area2_macro.c` | `*_ssl_area2_macro.v` | raw initializer tuples for five Puzzle trigger records/coordinates; connection to abstract trigger labels is pending |

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

## Transcript route-model boundary

`proofs/TranscriptRouteModel.v` is handwritten.  It formalizes a chronological
route-observation contract extracted from the supplied transcript and the
task's stronger post-gate proposal.  It is not generated Clight and is not
presented as one.  `TranscriptRouteGateModel`, the elevator/second-pole closure
properties, and both downstream-completeness definitions remain obligations.
No theorem currently projects Mario actions, exact collision surfaces, or gate
ordering from a Clight run into `RouteTrace`.

The generated `ssl_script` units use the normal preprocessing configuration.
The source's experimental `SSL_SPAWNING_DISPLACEMENT_TAS_HACK` branch is not
enabled and supplies no target-version reachability evidence.
