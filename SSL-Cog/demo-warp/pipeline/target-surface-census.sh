#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="${1:-${SM64_SOURCE:-../../../reference-sm64-decomp}}"

mapfile -t ACTUAL < <(
  grep -RIl --include='*.c' -E 'gCurrDemoInput|gDemoInputsBuf' "$SOURCE_ROOT/src" |
    sed "s#^$SOURCE_ROOT/##" |
    sort
)

EXPECTED=(
  src/game/behaviors/bowser.inc.c
  src/game/camera.c
  src/game/game_init.c
  src/game/level_update.c
  src/game/rumble_init.c
  src/game/save_file.c
  src/menu/title_screen.c
)

if [ "${ACTUAL[*]}" != "${EXPECTED[*]}" ]; then
  printf 'target-naming source surface changed\nexpected:\n%s\nactual:\n%s\n' \
    "${EXPECTED[*]}" "${ACTUAL[*]}" >&2
  exit 1
fi

grep -q 'behaviors/bowser.inc.c' "$SOURCE_ROOT/src/game/behavior_actions.c"
printf 'target-naming source surface: %s\n' "${ACTUAL[*]}"
