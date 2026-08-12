# JP generated writer census

This note records what the generated-AST census proves and, just as
importantly, what it does not prove.  The checked theorems are in
`proofs/JPGeneratedWriterCensus.v`.

## Translation-set correction

`pipeline/generate-clight.sh` emits 38 translation units for each version.
The older `ClightRefinement.v` inventory contained only 37: it omitted
`src/game/rendering_graph_node.c` even though the corresponding generated
file existed and other proof files inspected it.  The US and JP inventory
lists now include that unit and their checked counts are 38.

The 38 programs are still separate Clight translation units.  Concatenating
their definition lists is sound for a syntactic census, but it is not a C
linker and does not construct the retail executable's Clight program.

## Coordinate-lvalue census

The census now preserves the 38-unit boundary and inventories every internal
function containing at least one assignment to each selected lvalue.  The
numbers below are function counts, not dynamic executions or individual store
counts.  Units whose four counts are all zero are omitted from this compact
view.

| generated JP unit | `pos[1]` | `rawData.asF32[7]` | `rawData.asF32[10]` | assignment LHS mentions `throwMatrix` |
|---|---:|---:|---:|---:|
| `jp_mario` | 4 | 1 | 0 | 0 |
| `jp_mario_actions_airborne` | 3 | 0 | 0 | 0 |
| `jp_mario_actions_automatic` | 6 | 0 | 0 | 0 |
| `jp_mario_actions_cutscene` | 2 | 5 | 0 | 0 |
| `jp_mario_actions_moving` | 2 | 0 | 0 | 1 |
| `jp_mario_actions_stationary` | 1 | 0 | 0 | 0 |
| `jp_mario_actions_submerged` | 4 | 0 | 0 | 0 |
| `jp_mario_step` | 3 | 0 | 0 | 0 |
| `jp_interaction` | 1 | 3 | 0 | 0 |
| `jp_object_list_processor` | 0 | 2 | 1 | 0 |
| `jp_behavior_script` | 1 | 1 | 0 | 0 |
| `jp_graph_node` | 1 | 0 | 0 | 3 |
| `jp_rendering_graph_node` | 0 | 0 | 0 | 2 |
| `jp_spawn_object` | 1 | 1 | 0 | 2 |
| `jp_object_helpers` | 2 | 28 | 13 | 3 |
| `jp_mario_misc` | 0 | 3 | 0 | 0 |
| `jp_obj_behaviors` | 0 | 51 | 45 | 1 |
| `jp_obj_behaviors_2` | 0 | 35 | 43 | 0 |
| `jp_behavior_actions` | 0 | 83 | 78 | 2 |
| `jp_level_update` | 1 | 1 | 0 | 0 |
| `jp_platform_displacement` | 1 | 1 | 0 | 0 |
| `jp_surface_load` | 0 | 0 | 0 | 1 |
| **total** | **33** | **215** | **180** | **15** |

The exact named 38-entry partitions for `pos[1]` and `throwMatrix` are checked
by `jp_generated_pos_y_direct_assignment_partition` and
`jp_generated_throw_matrix_assignment_partition`.  The much larger raw-data
sets remain mechanically available as the exact identifier lists returned by
`jp_generated_nested_array_slot_assignment_partition`; the checked count
vectors preserve every unit boundary.  The nested recognizer requires the
generated lvalue shape `receiver.rawData.asF32[index]`, so these are not merely
same-name `asF32` arrays.

`JPCoordinateLvalueReceiverPartition.v` now bounds the source-type ambiguity
for these exact shapes across all 38 units: every `pos[1]` receiver belongs to
the allowed set `MarioState`, `GraphNodeObject`, or `PlayerCameraState`;
raw-data slots 7/10 require receiver `Object`; and `throwMatrix` requires
receiver `GraphNodeObject`.  It does not count the three `pos[1]` classes
separately.  These remain generated type annotations and function-site totals.
They are not a Mario-writer theorem until live block identity, pointer
provenance, reachability, non-aliasing, and external-call frame conditions are
proved.

## Exact JP quicksand-depth census

Across every internal function body in all 38 generated JP units, direct
assignments to a field named `quicksandDepth` occur only in:

1. `init_mario`;
2. `check_common_airborne_cancels`;
3. `mario_execute_automatic_action`;
4. `act_quicksand_death`;
5. `common_landing_action`;
6. `quicksand_jump_land_action`;
7. `mario_execute_submerged_action`; and
8. `mario_update_quicksand`.

`jp_generated_quicksand_depth_direct_writer_census` computes this list from
the generated `prog_defs`; it is not a hand-entered assertion about C text.

This closes the earlier selected-unit ambiguity.  It does not yet exclude a
write through an aliased pointer, an invalid/out-of-bounds store, an external
function, or a body outside the generated translation set.

## Long-jump action census

The exact `set_jumping_action(m, ACT_LONG_JUMP, 0)` call occurs only in
`act_crouch_slide`.  There is no direct generated
`set_mario_action(m, ACT_LONG_JUMP, 0)` call.  The expressions that contain
the `ACT_LONG_JUMP` integer are confined to:

- `update_air_with_turn`;
- `update_air_without_turn`;
- `act_crouch_slide`; and
- `apply_gravity`.

The generated action dispatch occurrences are switch labels, which this
expression census intentionally does not count.  The current list therefore
records only expression occurrences, not all control-flow labels carrying the
same numeric action value.

The only internal body whose expressions contain `ACT_LONG_JUMP_LAND` is
`act_long_jump`, which passes it to `common_air_action_step`.  There is no
direct `set_mario_action(m, ACT_LONG_JUMP_LAND, 0)` call.

These facts substantially narrow the no-A action proof, but do not complete
it.  A semantic proof must show that clean reachable `action` memory starts
with a valid entry action and can change only through the inventoried action
transition mechanisms.  It must also prove pointer validity/non-aliasing and
frame conditions for external calls.  Without those facts, literal census is
not whole-program action provenance.

## Automatic-dialog constructors and reanchoring

The complete direct-call census for
`set_mario_action(m, ACT_READING_AUTOMATIC_DIALOG, ...)` contains six
functions:

- `handle_save_menu`;
- `general_star_dance_handler`;
- `act_unlocking_star_door`;
- `act_warp_door_spawn`;
- `interact_warp_door`; and
- `interact_door`.

`jp_generated_automatic_dialog_constructor_classification` checks an exact
4+2 partition.  The first four are cutscene-path constructors: their enclosing
same-frame path contains a preceding or following Graphics reanchor through
`stop_and_set_height_to_floor`, `update_mario_pos_for_anim`, or `vec3f_copy`.
The last two are door-interaction constructors and require provenance for a
live warp-door or ordinary-door object.

The generated AST also checks the following source ordering:

- `act_exit_land_save_dialog` calls `stationary_ground_step` before
  `handle_save_menu`, and `handle_save_menu` does not directly write
  `m->pos[1]`;
- land star dance calls `general_star_dance_handler` before
  `stop_and_set_height_to_floor`;
- water star dance copies `m->pos` to Mario Graphics before calling
  `general_star_dance_handler`, and that helper does not directly write
  `m->pos[1]`;
- star-door unlocking executes its action change before
  `update_mario_pos_for_anim` and `stop_and_set_height_to_floor`; and
- warp-door spawn executes its action change before
  `stop_and_set_height_to_floor`.

These are source-shape receipts, not path-sensitive Clight executions.  They
separate the retail closure into three small obligations:

1. prove stock clean SSL Area 1 cannot instantiate or interact with a warp
   door or star door capable of the two interaction-origin constructors;
2. prove the four cutscene-origin paths execute their synchronization with a
   valid, non-aliased Mario pointer; and
3. prove `quicksandDepth` is nonnegative at every later sink frame that has no
   new Graphics reanchor.

Equivalently, the two immediate residuals are (1) clean Area-1 door-spawn and
door-object provenance, and (2) the `sink_mario_in_quicksand` call that still
runs in the same frame after a reanchor.  The formal
`JPArea1AutomaticDialogResidualObligation` states both over explicit state
predicates.  It does **not** assume negative depth is absent: the needed
nonnegative bound must follow from clean zero-A action/depth provenance.

The third obligation is still decisive.  Reanchoring does not reset
`quicksandDepth`, and `execute_mario_action` calls
`sink_mario_in_quicksand` after action dispatch.  A negative value therefore
creates a small gap on the first reanchored frame and can accumulate on later
non-reanchoring automatic-dialog frames.

## Mario pointer and slot-lifetime census

There are exactly two direct assignments to the `gMarioObject` global in the
38 generated JP units:

- `spawn_objects_from_info` installs the object whose `SpawnInfo.behaviorArg`
  has bit zero set; and
- `clear_objects` sets the global to null during a whole-object-system reset.

No generated internal function explicitly takes the address of the
`gMarioObject` global cell.  This rules out an unnoticed direct reassignment
inside the generated set, but not corruption or an external/aliased store.

The generated lifecycle chain also records a useful distinction:

- `level_cmd_init_mario` gives Mario's `SpawnInfo.activeAreaIndex` the value
  `-1`;
- ordinary level-object SpawnInfos use their actual area index;
- `geo_obj_init_spawninfo` copies that field to the allocated object; and
- `unload_objects_from_area` selects objects whose active-area value equals
  the area being unloaded.

The arithmetic fact `-1` differs from SSL areas 1, 2, and 3 is proved.  The
remaining retail step is a live-memory invariant that Mario retains this
value and identity.  The generated census finds all direct writers of a
field named `activeAreaIndex`: the two level-script initializers,
`geo_obj_init_spawninfo`, the three macro-object default-parent writers, and
`spawn_object_at_origin`.  A pointer proof must show the latter four target
fresh/non-Mario objects.  Once that is established, normal area unloading
cannot deallocate and reuse Mario's slot; whole-level `clear_objects` remains
a separate lifecycle boundary requiring re-entry initialization.

## Retail boundary

The generated census is stronger than a grep of selected action files, but it
is not yet the requested linked-retail invariant.  Completion still requires:

- an actual linked US and JP Clight program or a proved per-unit linking
  construction;
- ordinary-entry memory refinement for Mario State/Object/Graphics, action,
  depth, flags, and object identity;
- reachable action, spawn, behavior-change, and object-slot lifecycle
  invariants;
- pairwise non-aliasing of Mario State, Mario Object raw coordinates, Mario
  Graphics coordinates, and `quicksandDepth`;
- external-call frame conditions for every call crossed by the invariant;
- a semantic proof that zero-A traces refine the safe depth relation; and
- binary32 gap arithmetic over the actual live Graphics base/range.

Accordingly, this census does not prove that the `>= 960` Graphics/Object gap
is unreachable and does not prove the ultimate two-star theorem.
