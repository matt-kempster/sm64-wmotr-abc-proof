#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -gt 0 ] && [ -n "${1:-}" ]; then
  SOURCE_ROOT="$1"
elif [ -n "${SM64_SOURCE:-}" ]; then
  SOURCE_ROOT="$SM64_SOURCE"
else
  SOURCE_ROOT=""
  for candidate in ../reference-sm64-decomp ../../reference-sm64-decomp ../vendor/sm64 vendor/sm64; do
    if [ -d "$candidate/src" ]; then
      SOURCE_ROOT="$candidate"
      break
    fi
  done
  SOURCE_ROOT="${SOURCE_ROOT:-../reference-sm64-decomp}"
fi

if [ ! -d "$SOURCE_ROOT/src" ]; then
  echo "SM64 source tree not found at $SOURCE_ROOT" >&2
  exit 1
fi

object_list_processor="$SOURCE_ROOT/src/game/object_list_processor.c"
platform_displacement="$SOURCE_ROOT/src/game/platform_displacement.c"
update_source="$SOURCE_ROOT/src/game/object_list_processor.c"
ssl_script="$SOURCE_ROOT/levels/ssl/script.c"
ssl_area1_macro="$SOURCE_ROOT/levels/ssl/areas/1/macro.inc.c"
ssl_area2_macro="$SOURCE_ROOT/levels/ssl/areas/2/macro.inc.c"
spindel="$SOURCE_ROOT/src/game/behaviors/spindel.inc.c"
pyramid_top="$SOURCE_ROOT/src/game/behaviors/pyramid_top.inc.c"
behavior_data="$SOURCE_ROOT/data/behavior_data.c"
exclamation_box="$SOURCE_ROOT/src/game/behaviors/exclamation_box.inc.c"
surface_load="$SOURCE_ROOT/src/engine/surface_load.c"
exclamation_box_collision="$SOURCE_ROOT/actors/exclamation_box_outline/collision.inc.c"
interaction="$SOURCE_ROOT/src/game/interaction.c"
object_helpers="$SOURCE_ROOT/src/game/object_helpers.c"
mario="$SOURCE_ROOT/src/game/mario.c"
mario_actions_cutscene="$SOURCE_ROOT/src/game/mario_actions_cutscene.c"

require_pattern() {
  local file="$1"
  local pattern="$2"
  if ! grep -Eq "$pattern" "$file"; then
    echo "missing expected pattern in ${file#$SOURCE_ROOT/}: $pattern" >&2
    exit 1
  fi
}

require_order() {
  local file="$1"
  shift
  local previous=0
  local pattern line
  for pattern in "$@"; do
    line="$(grep -nE "$pattern" "$file" | cut -d: -f1 | awk -v previous="$previous" '$1 > previous { print; exit }' || true)"
    if [ -z "$line" ]; then
      echo "missing ordered pattern in ${file#$SOURCE_ROOT/}: $pattern" >&2
      exit 1
    fi
    previous="$line"
  done
}

require_order "$object_list_processor" \
  '^[[:space:]]*//! \(Spawning Displacement\)' \
  '^[[:space:]]*#ifndef VERSION_JP' \
  '^[[:space:]]*clear_mario_platform\(\);' \
  '^[[:space:]]*#endif'

require_order "$platform_displacement" \
  '^void apply_mario_platform_displacement\(void\)' \
  'struct Object \*platform = gMarioPlatform;' \
  'platform != NULL' \
  'apply_platform_displacement\(TRUE, platform\);' \
  '^#ifndef VERSION_JP' \
  '^void clear_mario_platform\(void\)'

require_order "$update_source" \
  'clear_dynamic_surfaces\(\);' \
  'update_terrain_objects\(\);' \
  'apply_mario_platform_displacement\(\);' \
  'detect_object_collisions\(\);' \
  'update_non_terrain_objects\(\);' \
  'unload_deactivated_objects\(\);' \
  'update_mario_platform\(\);'

area1_count="$(grep -Ec '^[[:space:]]*MACRO_OBJECT(_WITH_BHV_PARAM)?[[:space:]]*\(' "$ssl_area1_macro")"
area2_count="$(grep -Ec '^[[:space:]]*MACRO_OBJECT(_WITH_BHV_PARAM)?[[:space:]]*\(' "$ssl_area2_macro")"

if [ "$area1_count" != "46" ]; then
  echo "SSL area 1 macro object count changed: $area1_count" >&2
  exit 1
fi

if [ "$area2_count" != "50" ]; then
  echo "SSL area 2 macro object count changed: $area2_count" >&2
  exit 1
fi

require_pattern "$ssl_script" 'MODEL_SSL_PYRAMID_TOP.*-2047, 1536, -1023.*bhvPyramidTop'
require_pattern "$ssl_script" 'MODEL_SSL_TOX_BOX.*-1284,[[:space:]]*0, -5895.*TOX_BOX_BP_MOVEMENT_PATTERN_1.*bhvToxBox'
require_pattern "$ssl_script" 'MODEL_SSL_TOX_BOX.*1283,[[:space:]]*0, -4865.*TOX_BOX_BP_MOVEMENT_PATTERN_2.*bhvToxBox'
require_pattern "$ssl_script" 'MODEL_SSL_TOX_BOX.*4873,[[:space:]]*0, -3335.*TOX_BOX_BP_MOVEMENT_PATTERN_3.*bhvToxBox'
require_pattern "$ssl_script" 'MODEL_SSL_SPINDEL.*-2458, 2109, -1430.*bhvSpindel'
require_pattern "$ssl_script" 'MODEL_SSL_PYRAMID_ELEVATOR.*0, 4966,[[:space:]]*256.*bhvPyramidElevator'
require_pattern "$ssl_script" 'MARIO_POS\(/\*area\*/ 1, /\*yaw\*/ 88, /\*pos\*/ 653, 38, 6566\)'
require_pattern "$ssl_script" 'MODEL_NONE.*-2048,[[:space:]]*768, -1024.*BPARAM1\(15\).*WARP_NODE_1E.*bhvWarp'
require_pattern "$ssl_area1_macro" 'macro_box_wing_cap.*6900,[[:space:]]*350, -5400'
require_pattern "$ssl_area1_macro" 'macro_box_wing_cap.*-3000,[[:space:]]*500,[[:space:]]*800'
require_pattern "$ssl_area1_macro" 'macro_box_koopa_shell.*5840,[[:space:]]*940,[[:space:]]*2500'
require_pattern "$ssl_area1_macro" 'macro_box_wing_cap.*5860,[[:space:]]*940,[[:space:]]*4180'
require_pattern "$ssl_area1_macro" 'macro_box_1up_running_away.*-1200,[[:space:]]*500,[[:space:]]*800'
require_pattern "$spindel" 'o->oVelZ = 20 / sp18;'
require_pattern "$spindel" 'o->oAngleVelPitch = 1024 / sp18;'
require_pattern "$spindel" 'o->oVelZ = -20 / sp18;'
require_pattern "$spindel" 'o->oAngleVelPitch = -1024 / sp18;'
require_pattern "$pyramid_top" 'o->oAngleVelYaw \+= 0x100;'
require_pattern "$pyramid_top" 'o->oAngleVelYaw = 0x1800;'
require_order "$behavior_data" \
  '^const BehaviorScript bhvExclamationBox\[\]' \
  'BEGIN\(OBJ_LIST_SURFACE\)' \
  'LOAD_COLLISION_DATA\(exclamation_box_outline_seg8_collision_08025F78\)' \
  'SET_FLOAT\(oCollisionDistance, 300\)' \
  'CALL_NATIVE\(bhv_exclamation_box_loop\)'
require_order "$behavior_data" \
  '^const BehaviorScript bhvWarp\[\]' \
  'BEGIN\(OBJ_LIST_LEVEL\)' \
  'SET_INT\(oInteractType, INTERACT_WARP\)' \
  'CALL_NATIVE\(bhv_warp_loop\)'
require_order "$behavior_data" \
  '^const BehaviorScript bhvCarrySomething3\[\]' \
  'BEGIN\(OBJ_LIST_DEFAULT\)' \
  'BREAK\(\)'
require_order "$behavior_data" \
  '^const BehaviorScript bhvCarrySomething4\[\]' \
  'BEGIN\(OBJ_LIST_DEFAULT\)' \
  'BREAK\(\)'
require_order "$exclamation_box" \
  '^void exclamation_box_act_2\(void\)' \
  'cur_obj_become_tangible\(\);' \
  'load_object_collision_model\(\);'
require_order "$surface_load" \
  '^void load_object_surfaces\(TerrainData \*\*data, TerrainData \*vertexData\)' \
  'surface->object = gCurrentObject;'
require_order "$object_helpers" \
  '^void obj_set_held_state\(struct Object \*obj, const BehaviorScript \*heldBehavior\)' \
  'if \(obj->oFlags & OBJ_FLAG_HOLDABLE\)' \
  'obj->curBhvCommand = segmented_to_virtual\(heldBehavior\);'
require_order "$interaction" \
  '^void mario_grab_used_object\(struct MarioState \*m\)' \
  'obj_set_held_state\(m->heldObj, bhvCarrySomething3\);'
require_order "$interaction" \
  '^void mario_drop_held_object\(struct MarioState \*m\)' \
  'obj_set_held_state\(m->heldObj, bhvCarrySomething4\);'
require_order "$interaction" \
  '^static struct InteractionHandler sInteractionHandlers\[\]' \
  'INTERACT_WARP' \
  'INTERACT_GRABBABLE'
require_order "$interaction" \
  '^u32 interact_warp\(struct MarioState \*m, UNUSED u32 interactType, struct Object \*o\)' \
  'm->usedObj = o;' \
  'set_mario_action\(m, ACT_DISAPPEARED, \(WARP_OP_WARP_OBJECT << 16\) \+ 2\);'
require_order "$mario" \
  '^s32 execute_mario_action\(UNUSED struct Object \*o\)' \
  'mario_process_interactions\(gMarioState\);' \
  'switch \(gMarioState->action & ACT_GROUP_MASK\)'
require_order "$mario_actions_cutscene" \
  '^s32 act_disappeared\(struct MarioState \*m\)' \
  'level_trigger_warp\(m, m->actionArg >> 16\);'
require_pattern "$exclamation_box_collision" 'COL_VERTEX\(-26, 52, -26\)'
require_pattern "$exclamation_box_collision" 'COL_VERTEX\(26, 52, 26\)'

echo "JP spawning displacement source census matches expected source facts."
