#!/usr/bin/env bash
set -euo pipefail

SM64="${1:-${SM64_SOURCE:-../../../reference-sm64-decomp}}"
PIN="9921382a68bb0c865e5e45eb594d9c64db59b1af"
OUT="build/source"

mkdir -p "$OUT"

extract() {
  local source_path="$1"
  local output_name="$2"
  git -C "$SM64" show "$PIN:$source_path" > "$OUT/$output_name"
  sed -i 's/\r$//' "$OUT/$output_name"
}

extract src/game/obj_behaviors_2.c obj_behaviors_2.c
extract src/game/object_helpers.c object_helpers.c
extract src/engine/behavior_script.c behavior_script.c
extract src/game/object_list_processor.c object_list_processor.c
extract src/game/spawn_object.c spawn_object.c
extract src/engine/surface_collision.c surface_collision.c
extract levels/ssl/script.c ssl_script.c
extract src/game/area.c area.c
extract src/game/level_update.c level_update.c
extract src/game/game_init.c game_init.c
extract src/game/mario.c mario.c
extract src/game/mario_step.c mario_step.c
extract src/game/mario_actions_airborne.c mario_actions_airborne.c
extract src/game/mario_actions_moving.c mario_actions_moving.c
extract src/game/mario_actions_object.c mario_actions_object.c
extract src/game/mario_actions_stationary.c mario_actions_stationary.c
extract src/game/platform_displacement.c platform_displacement.c
extract src/game/interaction.c interaction.c

patch --silent --forward \
  "$OUT/object_helpers.c" \
  patches/object_helpers-clightgen.patch

echo "prepared pinned sources in $OUT"
