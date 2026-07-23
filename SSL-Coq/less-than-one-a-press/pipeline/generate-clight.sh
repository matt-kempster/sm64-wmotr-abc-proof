#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DECOMP_REVISION="9921382a68bb0c865e5e45eb594d9c64db59b1af"
SOURCE_REPOSITORY="${SM64_SOURCE:-$PROJECT_ROOT/../../../reference-sm64-decomp}"
PINNED_SOURCE="$PROJECT_ROOT/build/pinned-sm64"

if ! git -c "safe.directory=$SOURCE_REPOSITORY" -C "$SOURCE_REPOSITORY" \
    cat-file -e "$DECOMP_REVISION^{commit}" 2>/dev/null; then
  echo "SM64_SOURCE must name a Git repository containing $DECOMP_REVISION" >&2
  exit 1
fi

case "$PINNED_SOURCE" in
  "$PROJECT_ROOT"/build/pinned-sm64) ;;
  *) echo "refusing unexpected build path: $PINNED_SOURCE" >&2; exit 1 ;;
esac

mkdir -p "$PINNED_SOURCE"
find "$PINNED_SOURCE" -mindepth 1 -delete
git -c "safe.directory=$SOURCE_REPOSITORY" -C "$SOURCE_REPOSITORY" \
  archive --format=tar "$DECOMP_REVISION" | tar -xf - -C "$PINNED_SOURCE"

COMMON_FLAGS=(
  -nostdinc
  -fstruct-passing
  "-I$PINNED_SOURCE/include"
  "-I$PINNED_SOURCE/src"
  "-I$PINNED_SOURCE/src/game"
  "-I$PINNED_SOURCE"
  "-I$PINNED_SOURCE/include/libc"
  -D_FINALROM=1
  -DTARGET_N64=1
  -DNON_MATCHING=1
  -DAVOID_UB=1
  -D_LANGUAGE_C=1
)

TRANSLATION_UNITS=(
  "game_init:src/game/game_init.c"
  "mario:src/game/mario.c"
  "mario_actions_airborne:src/game/mario_actions_airborne.c"
  "mario_actions_automatic:src/game/mario_actions_automatic.c"
  "mario_actions_cutscene:src/game/mario_actions_cutscene.c"
  "mario_actions_moving:src/game/mario_actions_moving.c"
  "mario_actions_object:src/game/mario_actions_object.c"
  "mario_actions_stationary:src/game/mario_actions_stationary.c"
  "mario_step:src/game/mario_step.c"
  "interaction:src/game/interaction.c"
  "save_file:src/game/save_file.c"
  "object_collision:src/game/object_collision.c"
  "object_list_processor:src/game/object_list_processor.c"
  "spawn_object:src/game/spawn_object.c"
  "object_helpers:src/game/object_helpers.c"
  "obj_behaviors:src/game/obj_behaviors.c"
  "obj_behaviors_2:src/game/obj_behaviors_2.c"
  "behavior_actions:src/game/behavior_actions.c"
  "behavior_data:data/behavior_data.c"
  "area:src/game/area.c"
  "level_update:src/game/level_update.c"
  "platform_displacement:src/game/platform_displacement.c"
  "surface_collision:src/engine/surface_collision.c"
  "macro_special_objects:src/game/macro_special_objects.c"
  "ssl_script:levels/ssl/script.c"
  "ssl_area2_macro:PROJECT_INPUT"
  "ssl_collision:PROJECT_COLLISION_INPUT"
)

generate_one() {
  local version="$1"
  local stem="$2"
  local source_path="$3"
  local source_label="$source_path"
  local input="$PINNED_SOURCE/$source_path"
  local output="$PROJECT_ROOT/generated/${version}_${stem}.v"
  local version_flags=()

  case "$source_path" in
    PROJECT_INPUT)
      input="$PROJECT_ROOT/inputs/ssl_area2_macro.c"
      source_label="levels/ssl/areas/2/macro.inc.c (project wrapper)"
      ;;
    PROJECT_COLLISION_INPUT)
      input="$PROJECT_ROOT/inputs/ssl_collision.c"
      source_label="levels/ssl collision data (project wrapper)"
      ;;
  esac

  case "$version" in
    us)
      version_flags=(-DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1)
      ;;
    jp)
      version_flags=(-DVERSION_JP=1 -DF3D_OLD=1)
      ;;
    *) echo "unsupported version: $version" >&2; exit 2 ;;
  esac

  if [ "$stem" = "object_helpers" ]; then
    local cleaned="$PROJECT_ROOT/build/object_helpers-${version}.c"
    sed -E 's/([[:digit:]]+\.[[:digit:]]+)([lL])([^[:alnum:]_]|$)/\1\3/g' \
      "$input" > "$cleaned"
    input="$cleaned"
    source_label="$source_label (long-double literals translated as double)"
  fi

  "$PROJECT_ROOT/pipeline/clightgen.sh" \
    "$input" "$source_label" "VERSION_${version^^}" "$output" \
    "${COMMON_FLAGS[@]}" "${version_flags[@]}"
}

export CLIGHTGEN_SOURCE_ROOT="$PINNED_SOURCE"
export CLIGHTGEN_PROJECT_ROOT="$PROJECT_ROOT"

for version in us jp; do
  for unit in "${TRANSLATION_UNITS[@]}"; do
    stem="${unit%%:*}"
    source_path="${unit#*:}"
    generate_one "$version" "$stem" "$source_path"
  done
done

echo "generated ${#TRANSLATION_UNITS[@]} translation units for VERSION_US and VERSION_JP"
