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
    line="$(grep -nE "$pattern" "$file" | head -1 | cut -d: -f1 || true)"
    if [ -z "$line" ]; then
      echo "missing ordered pattern in ${file#$SOURCE_ROOT/}: $pattern" >&2
      exit 1
    fi
    if [ "$line" -le "$previous" ]; then
      echo "order changed in ${file#$SOURCE_ROOT/}: $pattern" >&2
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
require_pattern "$spindel" 'o->oVelZ = 20 / sp18;'
require_pattern "$spindel" 'o->oAngleVelPitch = 1024 / sp18;'
require_pattern "$spindel" 'o->oVelZ = -20 / sp18;'
require_pattern "$spindel" 'o->oAngleVelPitch = -1024 / sp18;'
require_pattern "$pyramid_top" 'o->oAngleVelYaw \+= 0x100;'
require_pattern "$pyramid_top" 'o->oAngleVelYaw = 0x1800;'

echo "JP spawning displacement source census matches expected source facts."
