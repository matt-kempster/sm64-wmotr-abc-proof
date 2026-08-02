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
| Dust particle table and dispatch | `src/game/object_list_processor.c:188-217,255-287` | `us_object_list_processor.v`, `jp_object_list_processor.v` |
| Mist spawner and white-puff scripts | `data/behavior_data.c:2771-2801` | `us_behavior_data.v`, `jp_behavior_data.v` |
| White-puff random translation calls | `src/game/behaviors/white_puff.inc.c:3-25` (included by `behavior_actions.c`) | `us_behavior_actions.v`, `jp_behavior_actions.v` |
| Two random draws per XZ translation | `src/game/object_helpers.c` (`obj_translate_xz_random`) | `us_object_helpers.v`, `jp_object_helpers.v` |
| PRNG recurrence | `src/engine/behavior_script.c:31-71` | `us_behavior_script.v`, `jp_behavior_script.v` |
| Retail trig table and Z-X-Y transform | `include/trig_tables.inc.c`, `src/engine/math_util.c:272-297` | `us_math_util.v`, `jp_math_util.v` |
| Dynamic collision vertex transform | `src/engine/surface_load.c:658-696` | `us_surface_load.v`, `jp_surface_load.v` |
| Floor/ceiling lateral tests and plane height | `src/engine/surface_collision.c:226-289,401-465` | `us_surface_collision.v`, `jp_surface_collision.v` |
| Spinner native update | `src/game/behaviors/ttc_spinner.inc.c:9-36` (included by `obj_behaviors_2.c`) | `us_obj_behaviors_2.v`, `jp_obj_behaviors_2.v` |
| Spinner behavior-to-collision link | `data/behavior_data.c:5547-5555` | `us_behavior_data.v`, `jp_behavior_data.v` |
| Fourteen stock spinner placements | `levels/ttc/areas/1/macro.inc.c:42-55` | `us_ttc_area1_macro.v`, `jp_ttc_area1_macro.v` |
| Spinner collision mesh | `levels/ttc/spinner/collision.inc.c:2-63` | `us_ttc_spinner_collision.v`, `jp_ttc_spinner_collision.v` |
| TTC entry speed selector | `src/game/behaviors/clock_arm.inc.c:6-54` (included by `behavior_actions.c`) | `us_behavior_actions.v`, `jp_behavior_actions.v` |
| Moving-platform displacement | `src/game/platform_displacement.c` | `us_platform_displacement.v`, `jp_platform_displacement.v` |
