# Source map

Pinned decomp commit: `9921382a68bb0c865e5e45eb594d9c64db59b1af`

All line numbers below refer to that commit.

`object_helpers.c` is presented to `clightgen` through the documented
long-double-suffix translation in `README.md`; no other selected decomp source
is textually rewritten.

| Obligation | Pinned source | Generated units |
|---|---|---|
| Pedro close-gap landing branch | `src/game/mario_step.c:388-443` | `us_mario_step.v`, `jp_mario_step.v` |
| Four-quarter-step propagation | `src/game/mario_step.c:610-650` | `us_mario_step.v`, `jp_mario_step.v` |
| Air action selects landing action | `src/game/mario_actions_airborne.c:371-386` | `us_mario_actions_airborne.v`, `jp_mario_actions_airborne.v` |
| Landing input split and dust gate | `src/game/mario_actions_moving.c:1722-1755` | `us_mario_actions_moving.v`, `jp_mario_actions_moving.v` |
| Analog landing friction | `src/game/mario_actions_moving.c:334-347` | `us_mario_actions_moving.v`, `jp_mario_actions_moving.v` |
| Floor-class deceleration | `src/game/mario_actions_moving.c:393-417` | `us_mario_actions_moving.v`, `jp_mario_actions_moving.v` |
| Mario action result supplies particle flags | `src/game/mario.c:1699-1782` | `us_mario.v`, `jp_mario.v` |
| Dust particle table and dispatch | `src/game/object_list_processor.c:188-217,255-287` | `us_object_list_processor.v`, `jp_object_list_processor.v`; exact accepted-caller big-steps in `proofs/DustSpawnParticleExecution.v` and `proofs/DustSpawnParticleExecutionJP.v` |
| Object-list phase order and dynamic-next traversal | `src/game/object_list_processor.c:172-217,289-307,573-581` | `us_object_list_processor.v`, `jp_object_list_processor.v` |
| Free-list allocation, eviction fallback, and object creation | `src/game/spawn_object.c:79-99,208-253,313-352` | `us_spawn_object.v`, `jp_spawn_object.v` |
| Area load, Mario load, and area-change active-particle clear | `src/game/area.c` | `us_area.v`, `jp_area.v` |
| Macro descriptor spawning | `src/game/macro_special_objects.c` | `us_macro_special_objects.v`, `jp_macro_special_objects.v` |
| TTC level/area object descriptors | `levels/ttc/script.c` | `us_ttc_level_script.v`, `jp_ttc_level_script.v` |
| Shared TTC `JUMP_LINK` targets (proved object-free) | `levels/scripts.c:172-207` | `us_level_scripts.v`, `jp_level_scripts.v` |
| BehaviorScript opcode lengths and relocation shapes | `data/behavior_data.c:59-329` | parser and closure receipts in `proofs/TTCRNGCensus.v`; initializers in `us_behavior_data.v`, `jp_behavior_data.v` |
| LevelScript OBJECT/MARIO/control opcode layouts | `include/level_commands.h` | parser receipts in `proofs/TTCRNGCensus.v`; `us_ttc_level_script.v`, `jp_ttc_level_script.v`, `us_level_scripts.v`, `jp_level_scripts.v` |
| Mist spawner and white-puff scripts | `data/behavior_data.c:2771-2801` | `us_behavior_data.v`, `jp_behavior_data.v` |
| Behavior interpreter, parent-bit clear, and object timer | `src/engine/behavior_script.c:238-367,805-813,905-952` | `us_behavior_script.v`, `jp_behavior_script.v`; linked handler big-step in `proofs/DustParentBitClearExecution.v` |
| White-puff random translation calls | `src/game/behaviors/white_puff.inc.c:3-25` (included by `behavior_actions.c`) | `us_behavior_actions.v`, `jp_behavior_actions.v` |
| Two random draws per XZ translation | `src/game/object_helpers.c` (`obj_translate_xz_random`) | `us_object_helpers.v`, `jp_object_helpers.v` |
| PRNG recurrence | `src/engine/behavior_script.c:31-71` | `us_behavior_script.v`, `jp_behavior_script.v` |
| Retail `sqrtf` terminal leaf | US VA/ROM `0x80323a50`/`0x000dea50`; JP VA/ROM `0x80322b20`/`0x000ddb20` in the authenticated clean images | committed byte receipts and finite call/store recognizers in `proofs/TTCRetailSqrt.v` |
| Retail trig table and Z-X-Y transform | `include/trig_tables.inc.c`, `src/engine/math_util.c:272-297` | `us_math_util.v`, `jp_math_util.v` |
| Dynamic collision vertex transform | `src/engine/surface_load.c:658-696` | `us_surface_load.v`, `jp_surface_load.v` |
| Floor/ceiling lateral tests and plane height | `src/engine/surface_collision.c:226-289,401-465` | `us_surface_collision.v`, `jp_surface_collision.v` |
| Spinner native update | `src/game/behaviors/ttc_spinner.inc.c:9-36` (included by `obj_behaviors_2.c`) | `us_obj_behaviors_2.v`, `jp_obj_behaviors_2.v` |
| TTC pre-spinner RNG-window consumers | TTC behavior includes in `src/game/obj_behaviors_2.c` and the Thwomp actions included by `src/game/behavior_actions.c` | `us_obj_behaviors_2.v`, `jp_obj_behaviors_2.v`, `us_behavior_actions.v`, `jp_behavior_actions.v` |
| Post-PLAYER descriptor natives (Amp, Bob-omb, hidden-red-coin star) | `src/game/obj_behaviors.c` | `us_obj_behaviors.v`, `jp_obj_behaviors.v` |
| Post-PLAYER forward-callgraph support: save data | `src/game/save_file.c` | `us_save_file.v`, `jp_save_file.v` |
| Post-PLAYER forward-callgraph support: sound spawning | `src/game/spawn_sound.c` | `us_spawn_sound.v`, `jp_spawn_sound.v` |
| Post-PLAYER forward-callgraph support: allocation | `src/game/memory.c` | `us_memory.v`, `jp_memory.v` |
| Segmented-address conversion boundary | `src/game/memory.c:78-105` | `us_memory.v`, `jp_memory.v`; exact standard-Clight non-evaluation certificate in `proofs/SegmentedPointerBoundary.v` |
| Post-PLAYER forward-callgraph support: graph nodes | `src/engine/graph_node.c` | `us_graph_node.v`, `jp_graph_node.v` |
| Post-PLAYER forward-callgraph support: audio helpers | `src/audio/external.c` | `us_audio_external.v`, `jp_audio_external.v` |
| Heave-Ho action table and indirect action dispatch | `src/game/behaviors/heave_ho.inc.c:106-115`, `src/game/object_helpers.c:2324-2326` | `us_behavior_actions.v`, `jp_behavior_actions.v`, `us_object_helpers.v`, `jp_object_helpers.v`; exact AST-shape receipt in `proofs/TTCRNGCensus.v` |
| Spinner behavior-to-collision link | `data/behavior_data.c:5547-5555` | `us_behavior_data.v`, `jp_behavior_data.v` |
| Fourteen stock spinner placements | `levels/ttc/areas/1/macro.inc.c:42-55` | `us_ttc_area1_macro.v`, `jp_ttc_area1_macro.v` |
| Spinner collision mesh | `levels/ttc/spinner/collision.inc.c:2-63` | `us_ttc_spinner_collision.v`, `jp_ttc_spinner_collision.v` |
| TTC entry speed selector | `src/game/behaviors/clock_arm.inc.c:6-54` (included by `behavior_actions.c`) | `us_behavior_actions.v`, `jp_behavior_actions.v` |
| Moving-platform displacement | `src/game/platform_displacement.c` | `us_platform_displacement.v`, `jp_platform_displacement.v` |
