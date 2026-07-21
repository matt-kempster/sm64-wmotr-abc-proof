#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -gt 0 ] && [ -n "${1:-}" ]; then
  SOURCE_ROOT="$1"
elif [ -n "${SM64_SOURCE:-}" ]; then
  SOURCE_ROOT="$SM64_SOURCE"
else
  SOURCE_ROOT=""
  for candidate in ../../../reference-sm64-decomp ../../vendor/sm64 ../../reference-sm64-decomp ../reference-sm64-decomp ../vendor/sm64 vendor/sm64; do
    if [ -d "$candidate/src" ]; then
      SOURCE_ROOT="$candidate"
      break
    fi
  done
  SOURCE_ROOT="${SOURCE_ROOT:-../../../reference-sm64-decomp}"
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
macro_presets="$SOURCE_ROOT/include/macro_presets.inc.c"
spindel="$SOURCE_ROOT/src/game/behaviors/spindel.inc.c"
pyramid_top="$SOURCE_ROOT/src/game/behaviors/pyramid_top.inc.c"
tox_box="$SOURCE_ROOT/src/game/behaviors/tox_box.inc.c"
tweester="$SOURCE_ROOT/src/game/behaviors/tweester.inc.c"
butterfly="$SOURCE_ROOT/src/game/behaviors/butterfly.inc.c"
triplet_butterfly="$SOURCE_ROOT/src/game/behaviors/triplet_butterfly.inc.c"
breakable_box="$SOURCE_ROOT/src/game/behaviors/breakable_box.inc.c"
cannon_door="$SOURCE_ROOT/src/game/behaviors/cannon_door.inc.c"
behavior_data="$SOURCE_ROOT/data/behavior_data.c"
exclamation_box="$SOURCE_ROOT/src/game/behaviors/exclamation_box.inc.c"
surface_load="$SOURCE_ROOT/src/engine/surface_load.c"
surface_collision="$SOURCE_ROOT/src/engine/surface_collision.c"
exclamation_box_collision="$SOURCE_ROOT/actors/exclamation_box_outline/collision.inc.c"
pyramid_top_collision="$SOURCE_ROOT/levels/ssl/pyramid_top/collision.inc.c"
tox_box_collision="$SOURCE_ROOT/levels/ssl/tox_box/collision.inc.c"
breakable_box_collision="$SOURCE_ROOT/actors/breakable_box/collision.inc.c"
message_panel_collision="$SOURCE_ROOT/actors/wooden_signpost/collision.inc.c"
cannon_lid_collision="$SOURCE_ROOT/actors/cannon_lid/collision.inc.c"
interaction="$SOURCE_ROOT/src/game/interaction.c"
object_collision="$SOURCE_ROOT/src/game/object_collision.c"
object_helpers="$SOURCE_ROOT/src/game/object_helpers.c"
mario="$SOURCE_ROOT/src/game/mario.c"
mario_actions_automatic="$SOURCE_ROOT/src/game/mario_actions_automatic.c"
mario_actions_cutscene="$SOURCE_ROOT/src/game/mario_actions_cutscene.c"
mario_step="$SOURCE_ROOT/src/game/mario_step.c"
warp_behavior="$SOURCE_ROOT/src/game/behaviors/warp.inc.c"

require_pattern() {
  local file="$1"
  local pattern="$2"
  if ! grep -Eq "$pattern" "$file"; then
    echo "missing expected pattern in ${file#$SOURCE_ROOT/}: $pattern" >&2
    exit 1
  fi
}

require_absent() {
  local file="$1"
  local pattern="$2"
  if grep -Eq "$pattern" "$file"; then
    echo "unexpected pattern in ${file#$SOURCE_ROOT/}: $pattern" >&2
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

stock_source_stream() {
  local file
  while IFS= read -r -d '' file; do
    awk '
      /^[[:space:]]*#if[[:space:]]+SSL_SPAWNING_DISPLACEMENT_TAS_HACK[[:space:]]*$/ {
        skip = 1
        depth = 1
        next
      }
      skip && /^[[:space:]]*#if(n?def)?([[:space:]]|$)/ {
        depth++
        next
      }
      skip && /^[[:space:]]*#endif([[:space:]]|$)/ {
        depth--
        if (depth == 0) {
          skip = 0
        }
        next
      }
      !skip { print }
    ' "$file"
  done < <(find "$SOURCE_ROOT/src" "$SOURCE_ROOT/include" \
    -type f \( -name '*.c' -o -name '*.h' \) -print0)
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
require_pattern "$ssl_script" 'MODEL_TWEESTER.*-3600,[[:space:]]*-200,[[:space:]]*2940.*BPARAM2\(0x12\).*bhvTweester'
require_pattern "$ssl_script" 'MODEL_TWEESTER.*1017,[[:space:]]*-200,[[:space:]]*3832.*BPARAM2\(0x19\).*bhvTweester'
require_pattern "$ssl_script" 'MODEL_TWEESTER.*3066,[[:space:]]*-200,[[:space:]]*400.*BPARAM2\(0x19\).*bhvTweester'
require_absent "$ssl_script" 'bhvChuckya'
require_absent "$ssl_area1_macro" 'macro_chuckya'
require_absent "$ssl_area2_macro" 'macro_chuckya'
require_absent "$ssl_script" 'bhvButterfly|bhvTripletButterfly|MODEL_BUTTERFLY'
require_absent "$ssl_area1_macro" 'bhvButterfly|bhvTripletButterfly|MODEL_BUTTERFLY|butterfly'
require_absent "$ssl_area2_macro" 'bhvButterfly|bhvTripletButterfly|MODEL_BUTTERFLY|butterfly'
require_pattern "$ssl_script" 'MODEL_SSL_SPINDEL.*-2458, 2109, -1430.*bhvSpindel'
require_pattern "$ssl_script" 'MODEL_SSL_PYRAMID_ELEVATOR.*0, 4966,[[:space:]]*256.*bhvPyramidElevator'
require_pattern "$ssl_script" 'MARIO_POS\(/\*area\*/ 1, /\*yaw\*/ 88, /\*pos\*/ 653, 38, 6566\)'
require_pattern "$ssl_script" 'MODEL_NONE.*-2048,[[:space:]]*0,[[:space:]]*56.*BPARAM2\(WARP_NODE_14\).*bhvWarp'
require_pattern "$ssl_script" 'MODEL_NONE.*-2048,[[:space:]]*768, -1024.*BPARAM1\(15\).*WARP_NODE_1E.*bhvWarp'
require_pattern "$ssl_script" 'WARP_NODE.*WARP_NODE_14.*LEVEL_SSL.*2.*WARP_NODE_0A'
require_pattern "$ssl_script" 'WARP_NODE.*WARP_NODE_1E.*LEVEL_SSL.*2.*WARP_NODE_14'
require_pattern "$ssl_area1_macro" 'macro_box_wing_cap.*6900,[[:space:]]*350, -5400'
require_pattern "$ssl_area1_macro" 'macro_box_wing_cap.*-3000,[[:space:]]*500,[[:space:]]*800'
require_pattern "$ssl_area1_macro" 'macro_box_koopa_shell.*5840,[[:space:]]*940,[[:space:]]*2500'
require_pattern "$ssl_area1_macro" 'macro_box_wing_cap.*5860,[[:space:]]*940,[[:space:]]*4180'
require_pattern "$ssl_area1_macro" 'macro_box_1up_running_away.*-1200,[[:space:]]*500,[[:space:]]*800'
require_pattern "$ssl_area1_macro" 'macro_breakable_box_no_coins.*5900,[[:space:]]*51,[[:space:]]*4400'
require_pattern "$ssl_area1_macro" 'macro_breakable_box_no_coins.*5900,[[:space:]]*51,[[:space:]]*2311'
require_pattern "$ssl_area1_macro" 'macro_wooden_signpost.*5702,[[:space:]]*614,[[:space:]]*2974'
require_pattern "$ssl_area1_macro" 'macro_wooden_signpost.*-3260,[[:space:]]*256,[[:space:]]*800'
require_pattern "$ssl_area1_macro" 'macro_wooden_signpost.*5130,[[:space:]]*26,[[:space:]]*-370'
require_pattern "$ssl_area1_macro" 'macro_cannon_closed.*6863,[[:space:]]*0,[[:space:]]*-6860'
require_pattern "$macro_presets" 'macro_breakable_box_no_coins.*bhvBreakableBox.*MODEL_BREAKABLE_BOX'
require_pattern "$macro_presets" 'macro_wooden_signpost.*bhvMessagePanel.*MODEL_WOODEN_SIGNPOST'
require_pattern "$macro_presets" 'macro_cannon_closed.*bhvCannonClosed.*MODEL_DL_CANNON_LID'
require_pattern "$spindel" 'o->oVelZ = 20 / sp18;'
require_pattern "$spindel" 'o->oAngleVelPitch = 1024 / sp18;'
require_pattern "$spindel" 'o->oVelZ = -20 / sp18;'
require_pattern "$spindel" 'o->oAngleVelPitch = -1024 / sp18;'
require_pattern "$tox_box" 's8 sToxBoxActionTable1\[\] = \{'
require_pattern "$tox_box" 'FORWARD, FORWARD, RIGHT, RIGHT, BACKWARD, BACKWARD, RIGHT, RIGHT, BACKWARD, IDLE,'
require_pattern "$tox_box" 's8 sToxBoxActionTable2\[\] = \{'
require_pattern "$tox_box" 'FORWARD, FORWARD, LEFT, LEFT, LEFT, IDLE,'
require_pattern "$tox_box" 's8 sToxBoxActionTable3\[\] = \{'
require_pattern "$tox_box" 'FORWARD, FORWARD, FORWARD, FORWARD, FORWARD, IDLE,'
require_order "$tox_box" \
  '^void tox_box_move\(f32 forwardVel, f32 upVel, s16 deltaPitch, s16 deltaRoll\)' \
  'o->oPosY = 99.41124 \* sins\(\(f32\)\(o->oTimer \+ 1\) / 8 \* 0x8000\) \+ o->oHomeY \+ 3.0f;' \
  'cur_obj_set_pos_via_transform\(\);' \
  'if \(o->oTimer == 7\)' \
  'o->oAction = cur_obj_progress_action_table\(\);'
require_order "$tox_box" \
  '^void tox_box_act_roll_land\(void\)' \
  'o->oPosY = o->oHomeY \+ 3.0f;' \
  'if \(o->oTimer == 20\)' \
  'o->oAction = cur_obj_progress_action_table\(\);'
require_pattern "$pyramid_top" 'o->oAngleVelYaw \+= 0x100;'
require_pattern "$pyramid_top" 'o->oAngleVelYaw = 0x1800;'
require_pattern "$pyramid_top" 'o->oPosX = o->oHomeX \+ sins\(o->oTimer \* 0x4000\) \* 40.0f;'
require_pattern "$pyramid_top" 'o->oPosY = o->oHomeY \+ absf_2\(sins\(o->oTimer \* 0x2000\) \* 10.0f\);'
require_pattern "$pyramid_top" 'o->oPosY \+= o->oVelY;'
require_pattern "$pyramid_top" 'spawn_object\(o, MODEL_DIRT_ANIMATION, bhvPyramidTopFragment\);'
require_pattern "$pyramid_top" 'spawn_object_abs_with_rot\(o, 0, MODEL_NONE, bhvPyramidPillarTouchDetector'
require_absent "$pyramid_top" 'bhvToxBox|bhvExclamationBox'
require_absent "$tox_box" 'spawn_object'
require_order "$object_helpers" \
  '^s32 cur_obj_progress_action_table\(void\)' \
  'actionTable\[nextActionIndex\] != TOX_BOX_ACT_TABLE_END' \
  'o->oToxBoxActionStep\+\+;' \
  'nextAction = actionTable\[0\];' \
  'o->oToxBoxActionStep = 0;'
require_order "$object_helpers" \
  '^void cur_obj_set_pos_via_transform\(void\)' \
  'obj_build_transform_from_pos_and_angle\(o, O_PARENT_RELATIVE_POS_INDEX, O_MOVE_ANGLE_INDEX\);' \
  'obj_build_vel_from_transform\(o\);' \
  'o->oPosX \+= o->oVelX;' \
  'o->oPosY \+= o->oVelY;' \
  'o->oPosZ \+= o->oVelZ;'
require_order "$behavior_data" \
  '^const BehaviorScript bhvToxBox\[\]' \
  'BEGIN\(OBJ_LIST_SURFACE\)' \
  'LOAD_COLLISION_DATA\(ssl_seg7_collision_tox_box\)' \
  'ADD_FLOAT\(oPosY, 256\)' \
  'CALL_NATIVE\(bhv_tox_box_loop\)'
require_order "$behavior_data" \
  '^const BehaviorScript bhvPyramidTop\[\]' \
  'BEGIN\(OBJ_LIST_SURFACE\)' \
  'LOAD_COLLISION_DATA\(ssl_seg7_collision_pyramid_top\)' \
  'SET_FLOAT\(oCollisionDistance, 20000\)' \
  'CALL_NATIVE\(bhv_pyramid_top_loop\)' \
  'CALL_NATIVE\(load_object_collision_model\)'
require_order "$behavior_data" \
  '^const BehaviorScript bhvPyramidTopFragment\[\]' \
  'BEGIN\(OBJ_LIST_DEFAULT\)' \
  'CALL_NATIVE\(bhv_pyramid_top_fragment_init\)' \
  'CALL_NATIVE\(bhv_pyramid_top_fragment_loop\)'
require_order "$behavior_data" \
  '^const BehaviorScript bhvPyramidPillarTouchDetector\[\]' \
  'BEGIN\(OBJ_LIST_LEVEL\)' \
  'SET_HITBOX\(/\*Radius\*/ 50, /\*Height\*/ 50\)' \
  'CALL_NATIVE\(bhv_pyramid_pillar_touch_detector_loop\)'
require_order "$behavior_data" \
  '^const BehaviorScript bhvTweester\[\]' \
  'BEGIN\(OBJ_LIST_POLELIKE\)' \
  'SET_OBJ_PHYSICS' \
  'DROP_TO_FLOOR\(\)' \
  'SET_HOME\(\)' \
  'CALL_NATIVE\(bhv_tweester_loop\)'
require_order "$behavior_data" \
  '^const BehaviorScript bhvExclamationBox\[\]' \
  'BEGIN\(OBJ_LIST_SURFACE\)' \
  'LOAD_COLLISION_DATA\(exclamation_box_outline_seg8_collision_08025F78\)' \
  'SET_FLOAT\(oCollisionDistance, 300\)' \
  'CALL_NATIVE\(bhv_exclamation_box_loop\)'
require_order "$behavior_data" \
  '^const BehaviorScript bhvBreakableBox\[\]' \
  'BEGIN\(OBJ_LIST_SURFACE\)' \
  'LOAD_COLLISION_DATA\(breakable_box_seg8_collision_08012D70\)' \
  'SET_FLOAT\(oCollisionDistance, 500\)' \
  'CALL_NATIVE\(bhv_breakable_box_loop\)' \
  'CALL_NATIVE\(load_object_collision_model\)'
require_order "$behavior_data" \
  '^const BehaviorScript bhvMessagePanel\[\]' \
  'BEGIN\(OBJ_LIST_SURFACE\)' \
  'LOAD_COLLISION_DATA\(wooden_signpost_seg3_collision_0302DD80\)' \
  'DROP_TO_FLOOR\(\)' \
  'CALL_NATIVE\(load_object_collision_model\)'
require_order "$behavior_data" \
  '^const BehaviorScript bhvCannonClosed\[\]' \
  'BEGIN\(OBJ_LIST_SURFACE\)' \
  'LOAD_COLLISION_DATA\(cannon_lid_seg8_collision_08004950\)' \
  'CALL_NATIVE\(bhv_cannon_closed_init\)' \
  'CALL_NATIVE\(bhv_cannon_closed_loop\)' \
  'CALL_NATIVE\(load_object_collision_model\)'
require_order "$behavior_data" \
  '^const BehaviorScript bhvCannon\[\]' \
  'BEGIN\(OBJ_LIST_LEVEL\)' \
  'SPAWN_CHILD\(/\*Model\*/ MODEL_CANNON_BARREL, /\*Behavior\*/ bhvCannonBarrel\)' \
  'SET_INT\(oInteractType, INTERACT_CANNON_BASE\)'
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
  'o->oPosY = o->oHomeY;' \
  'o->oAction = 3;' \
  'load_object_collision_model\(\);'
require_order "$exclamation_box" \
  '^void exclamation_box_act_3\(void\)' \
  'cur_obj_move_using_fvel_and_gravity\(\);'
require_order "$breakable_box" \
  '^void bhv_breakable_box_loop\(void\)' \
  'obj_set_hitbox\(o, &sBreakableBoxHitbox\);' \
  'cur_obj_set_model\(MODEL_BREAKABLE_BOX_SMALL\);' \
  'breakable_box_init\(\);' \
  'cur_obj_was_attacked_or_ground_pounded\(\)'
require_absent "$breakable_box" 'o->oPos[XYZ][[:space:]]*[-+]?='
require_order "$cannon_door" \
  '^void bhv_cannon_closed_init\(void\)' \
  'spawn_object\(o, MODEL_CANNON_BASE, bhvCannon\);' \
  'cannon->oPosX = o->oHomeX;' \
  'cannon->oPosY = o->oHomeY;' \
  'cannon->oPosZ = o->oHomeZ;' \
  'o->activeFlags = ACTIVE_FLAG_DEACTIVATED;'
require_order "$cannon_door" \
  '^void cannon_door_act_opening\(void\)' \
  'o->oVelY = -0.5f;' \
  'o->oPosY \+= o->oVelY;' \
  'o->oVelX = 4.0f;' \
  'o->oPosX \+= o->oVelX;'
require_order "$exclamation_box" \
  '^struct ExclamationBoxContents sExclamationBoxContents\[\]' \
  'bhvWingCap' \
  'bhvMetalCap' \
  'bhvVanishCap' \
  'bhvKoopaShell' \
  'bhvSingleCoinGetsSpawned' \
  'bhvThreeCoinsSpawn' \
  'bhvTenCoinsSpawn' \
  'bhv1UpWalking' \
  'bhvSpawnedStar' \
  'bhv1UpRunningAway' \
  'NULL'
require_absent "$exclamation_box" 'bhvPyramidTop'
require_absent "$exclamation_box" 'bhvToxBox'
require_absent "$exclamation_box" 'bhvExclamationBox'
require_order "$tox_box" \
  '^void bhv_tox_box_loop\(void\)' \
  'load_object_collision_model\(\);'
require_order "$tweester" \
  '^void tweester_act_chase\(void\)' \
  'f32 activationRadius = o->oBhvParams2ndByte \* 100;' \
  'cur_obj_lateral_dist_from_mario_to_home\(\) < activationRadius' \
  'o->oForwardVel = 20.0f;' \
  'if \(o->oDistanceToMario > 3000.0f\)' \
  'o->oAction = TWEESTER_ACT_HIDE;' \
  'cur_obj_move_standard\(60\);'
require_order "$tweester" \
  '^void bhv_tweester_loop\(void\)' \
  'obj_set_hitbox\(o, &sTweesterHitbox\);' \
  'cur_obj_call_action_function\(sTweesterActions\);' \
  'o->oInteractStatus = 0;'
require_order "$butterfly" \
  '^void butterfly_calculate_angle\(void\)' \
  'gMarioObject->oPosX \+=' \
  'gMarioObject->oPosZ \+=' \
  'obj_turn_toward_object\(o, gMarioObject, 16, 0x300\);' \
  'gMarioObject->oPosX -=' \
  'gMarioObject->oPosZ -=' \
  'gMarioObject->oPosY \+=' \
  'obj_turn_toward_object\(o, gMarioObject, 15, 0x500\);' \
  'gMarioObject->oPosY -='
require_order "$behavior_data" \
  '^const BehaviorScript bhvButterfly\[\]' \
  'BEGIN\(OBJ_LIST_DEFAULT\)' \
  'CALL_NATIVE\(bhv_butterfly_loop\)'
require_order "$behavior_data" \
  '^const BehaviorScript bhvTripletButterfly\[\]' \
  'BEGIN\(OBJ_LIST_GENACTOR\)' \
  'CALL_NATIVE\(bhv_triplet_butterfly_update\)'
require_order "$triplet_butterfly" \
  '^static struct TripletButterflyActivationData sTripletButterflyActivationData\[\]' \
  'MODEL_BOWLING_BALL, NULL' \
  'MODEL_1UP,[[:space:]]*bhv1UpWalking'
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
  'INTERACT_TORNADO' \
  'INTERACT_GRABBABLE'
require_order "$interaction" \
  '^u32 interact_warp\(struct MarioState \*m, UNUSED u32 interactType, struct Object \*o\)' \
  'm->usedObj = o;' \
  'set_mario_action\(m, ACT_DISAPPEARED, \(WARP_OP_WARP_OBJECT << 16\) \+ 2\);'
require_order "$interaction" \
  '^u32 interact_tornado\(struct MarioState \*m, UNUSED u32 interactType, struct Object \*o\)' \
  'm->usedObj = o;' \
  'marioObj->oMarioTornadoYawVel = 0x400;' \
  'marioObj->oMarioTornadoPosY = m->pos\[1\] - o->oPosY;' \
  'set_mario_action\(m, ACT_TORNADO_TWIRLING, m->action == ACT_TWIRLING\);'
require_order "$interaction" \
  '^void mario_process_interactions\(struct MarioState \*m\)' \
  'mario_get_collided_object\(m, interactType\);' \
  'if \(sInteractionHandlers\[i\]\.handler\(m, interactType, object\)\)' \
  'break;'
require_order "$mario" \
  '^s32 execute_mario_action\(UNUSED struct Object \*o\)' \
  'mario_process_interactions\(gMarioState\);' \
  'switch \(gMarioState->action & ACT_GROUP_MASK\)'
require_order "$mario_actions_automatic" \
  '^s32 act_tornado_twirling\(struct MarioState \*m\)' \
  'struct Object \*usedObj = m->usedObj;' \
  'nextPos\[0\] = usedObj->oPosX' \
  'vec3f_copy\(m->pos, nextPos\);' \
  'vec3f_copy\(m->marioObj->header.gfx.pos, m->pos\);'
require_order "$object_list_processor" \
  '^s8 sObjectListUpdateOrder\[\]' \
  'OBJ_LIST_SURFACE' \
  'OBJ_LIST_PLAYER'
require_order "$object_list_processor" \
  '^void bhv_mario_update\(void\)' \
  'execute_mario_action\(gCurrentObject\);' \
  'copy_mario_state_to_object\(\);'
require_order "$object_list_processor" \
  '^void copy_mario_state_to_object\(void\)' \
  'gCurrentObject->oPosX = gMarioStates\[i\]\.pos\[0\];' \
  'gCurrentObject->oPosY = gMarioStates\[i\]\.pos\[1\];' \
  'gCurrentObject->oPosZ = gMarioStates\[i\]\.pos\[2\];'
require_order "$object_collision" \
  '^s32 detect_object_hitbox_overlap\(struct Object \*a, struct Object \*b\)' \
  'f32 dx = a->oPosX - b->oPosX;' \
  'f32 dz = a->oPosZ - b->oPosZ;' \
  'a->collidedObjInteractTypes \|= b->oInteractType;'
require_order "$platform_displacement" \
  '^void update_mario_platform\(void\)' \
  'marioX = gMarioObject->oPosX;' \
  'marioY = gMarioObject->oPosY;' \
  'marioZ = gMarioObject->oPosZ;' \
  'floorHeight = find_floor\(marioX, marioY, marioZ, &floor\);'
direct_mario_object_pos_writes="$(
  stock_source_stream |
    grep -E 'gMarioObject->oPos[XYZ][[:space:]]*[-+]?=' |
    awk 'END { print NR }'
)"
if [ "$direct_mario_object_pos_writes" != "6" ]; then
  echo "direct gMarioObject->oPos write count changed: $direct_mario_object_pos_writes" >&2
  exit 1
fi

state_sync_mario_object_pos_writes="$(
  grep -RInE 'gMarioState->marioObj->oPos[XYZ][[:space:]]*[-+]?=' \
    "$SOURCE_ROOT/src" "$SOURCE_ROOT/include" | awk 'END { print NR }'
)"
if [ "$state_sync_mario_object_pos_writes" != "6" ]; then
  echo "MarioState-to-marioObj oPos sync write count changed: $state_sync_mario_object_pos_writes" >&2
  exit 1
fi
require_order "$mario_actions_cutscene" \
  '^s32 act_disappeared\(struct MarioState \*m\)' \
  'stop_and_set_height_to_floor\(m\);' \
  'level_trigger_warp\(m, m->actionArg >> 16\);'
require_order "$mario_step" \
  '^void stop_and_set_height_to_floor\(struct MarioState \*m\)' \
  'mario_set_forward_vel\(m, 0\.0f\);' \
  'm->vel\[1\] = 0\.0f;' \
  'm->pos\[1\] = m->floorHeight;'
require_pattern "$surface_collision" 'y - \(height \+ -78\.0f\) < 0\.0f'
require_order "$warp_behavior" \
  '^void bhv_warp_loop\(void\)' \
  'o->hitboxRadius = 50\.0f;' \
  'o->hitboxRadius = 10000\.0f;' \
  'o->hitboxRadius = bhvParams1stByte \* 10\.0;' \
  'o->hitboxHeight = 50\.0f;'
gmario_platform_assignments="$(
  grep -RhoE 'gMarioPlatform[[:space:]]*=' \
    "$SOURCE_ROOT/src" "$SOURCE_ROOT/include" | awk 'END { print NR }'
)"
if [ "$gmario_platform_assignments" != "5" ]; then
  echo "gMarioPlatform assignment count changed: $gmario_platform_assignments" >&2
  exit 1
fi
require_pattern "$exclamation_box_collision" 'COL_VERTEX\(-26, 52, -26\)'
require_pattern "$exclamation_box_collision" 'COL_VERTEX\(26, 52, 26\)'
require_pattern "$pyramid_top_collision" 'COL_VERTEX\(-511, -255, 512\)'
require_pattern "$pyramid_top_collision" 'COL_VERTEX\(512, -255, -511\)'
require_pattern "$pyramid_top_collision" 'COL_VERTEX\(0, 256, 0\)'
require_pattern "$tox_box_collision" 'COL_VERTEX\(-255, 256, 256\)'
require_pattern "$tox_box_collision" 'COL_VERTEX\(256, 256, -255\)'
require_pattern "$tox_box_collision" 'COL_VERTEX\(256, -255, -255\)'
require_pattern "$breakable_box_collision" 'COL_VERTEX\(-100, 0, -100\)'
require_pattern "$breakable_box_collision" 'COL_VERTEX\(100, 200, 100\)'
require_pattern "$message_panel_collision" 'COL_VERTEX\(-44, -9, -12\)'
require_pattern "$message_panel_collision" 'COL_VERTEX\(45, 126, 20\)'
require_pattern "$cannon_lid_collision" 'COL_VERTEX\(112, 0, -111\)'
require_pattern "$cannon_lid_collision" 'COL_VERTEX\(-111, 0, 112\)'

echo "JP spawning displacement source census matches expected source facts."
