# Source-to-Clight map

All rows are translated twice, once with `VERSION_US` and once with
`VERSION_JP`, from decomp commit
`9921382a68bb0c865e5e45eb594d9c64db59b1af`.  There are 25 translation
units per version and therefore 50 generated Clight modules.

| Source | Generated stems | Relevant coverage |
| --- | --- | --- |
| `src/game/game_init.c` | `*_game_init.v` | `read_controller_inputs`; `buttonPressed` edge formula and `buttonDown` history |
| `src/game/mario.c` | `*_mario.v` | `update_mario_button_inputs`; distinct pressed/down Mario input bits |
| `src/game/mario_actions_airborne.c` | `*_mario_actions_airborne.v` | airborne action handlers and movement writers imported for Layer B callgraph and writer coverage; no complete execution refinement yet |
| `src/game/mario_actions_automatic.c` | `*_mario_actions_automatic.v` | pole positioning, holding-pole and top-of-pole source shapes used by the normalized-pole subcase |
| `src/game/mario_actions_moving.c` | `*_mario_actions_moving.v` | walking, braking, slope deceleration, ground-step and move-punching source shapes used by the parallel-universe completeness audit |
| `src/game/mario_actions_object.c` | `*_mario_actions_object.v` | object-interaction action handlers imported for Layer B action/writer coverage; no complete execution refinement yet |
| `src/game/mario_actions_stationary.c` | `*_mario_actions_stationary.v` | stationary action handlers imported for Layer B action/writer coverage; no complete execution refinement yet |
| `src/game/mario_step.c` | `*_mario_step.v` | ground and air quarter-step loops, `find_floor` calls, and gravity source shape |
| `src/game/interaction.c` | `*_interaction.v` | `interact_star_or_key`; behavior-parameter index extraction and save call; coin interaction |
| `src/game/save_file.c` | `*_save_file.v` | `save_file_collect_star_or_key`, `save_file_set_star_flags`; finite save-bit write |
| `src/game/object_collision.c` | `*_object_collision.v` | hitbox overlap, collision-list registration/capacity, player/object collision phase |
| `src/game/object_list_processor.c` | `*_object_list_processor.v` | platform displacement, collision detection, behavior updates, deactivation unload, object spawning order |
| `src/game/spawn_object.c` | `*_spawn_object.v` | allocation, activation, identity initialization, deletion and pool-slot reuse fields |
| `src/game/object_helpers.c` | `*_object_helpers.v` | default/no-exit star spawn helpers and target behavior parameters |
| `src/game/obj_behaviors.c` | `*_obj_behaviors.v` | object collision-list query and shared behavior helpers |
| `src/game/obj_behaviors_2.c` | `*_obj_behaviors_2.v` | Eyerok hand attack check, movement/update order, death, and coin-spawn source shapes |
| `src/game/behavior_actions.c` | `*_behavior_actions.v` | hidden-star controller/trigger init and loop, count-to-five spawn, trigger deactivation |
| `data/behavior_data.c` | `*_behavior_data.v` | star, hidden-controller and hidden-trigger behavior bindings |
| `src/game/area.c` | `*_area.v` | area load, unload and `change_area` object lifecycle |
| `src/game/level_update.c` | `*_level_update.v` | area 2/3 instant-warp check and area change |
| `src/game/platform_displacement.c` | `*_platform_displacement.v` | raw `gMarioPlatform` displacement, platform clearing/recomputation, and US/JP spawn-state difference |
| `src/engine/surface_collision.c` | `*_surface_collision.v` | floor and surface query implementation used by Mario stepping and platform recomputation; imported for future semantic refinement |
| `src/game/macro_special_objects.c` | `*_macro_special_objects.v` | macro-object spawning and respawn-state persistence |
| `levels/ssl/script.c` | `*_ssl_script.v` | area 2 static Act 3 star, hidden controller and instant-warp declarations |
| `levels/ssl/areas/2/macro.inc.c` via `inputs/ssl_area2_macro.c` | `*_ssl_area2_macro.v` | exact five Pyramid Puzzle trigger records and coordinates |

## Archive-derived integration boundary

`proofs/ArchivedProofIntegration.v` rechecks selected source claims suggested
by the six archived projects against the modules above.  Its proved
`ArchivedProofIntegrationKernel` covers:

- raw platform-pointer use, the US/JP platform-clear split, unload/load order,
  object-list traversal, and fresh allocation-epoch identity;
- current movement, normalized-pole, and Eyerok source shapes;
- narrow held-A, bounded static-quarter-step, normalized integer pole, and
  same-CompCert-block memory lemmas from `proofs/RouteEvidence.v`.

No archived generated module is imported.  The raw platform model stores the
actual object-pool slot plus a ghost capture epoch used only for provenance.
Together, `GameTypes.v` and `UpperEntrance.v` distinguish null, live at the
captured epoch, inactive at that epoch, and reused-slot cases.  This is a case
split, not a proof that every case is reachable or geometrically safe.

The AST certificates remain intentionally syntactic.
`proofs/ClightRefinement.v` records the separate, currently open whole-program
execution refinement, and the Layer B collision-region obligations remain
open.  None of the six archived projects closes either class of obligation.
See the
[`archived-proof evidence map`](../docs/archived-proof-evidence.md) for the
project-by-project support and non-support boundary.
