#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DECOMP_REVISION="9921382a68bb0c865e5e45eb594d9c64db59b1af"
SOURCE_REPOSITORY="${SM64_SOURCE:-$PROJECT_ROOT/../../reference-sm64-decomp}"
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
# Check the complete pinned file inventory and contents on every pass. Avoid
# repeatedly deleting the whole OneDrive-backed cache between generation runs.
python3 "$PROJECT_ROOT/pipeline/restore-pinned-source.py" \
  "$SOURCE_REPOSITORY" "$DECOMP_REVISION"

# levels/scripts.c includes this Makefile-derived header by its basename.
# Reproduce the upstream rule inside the pinned tree so no ambient build
# directory can influence Clight generation.
cc -E -P -x c -I "$PINNED_SOURCE" \
  "$PINNED_SOURCE/levels/level_headers.h.in" |
  sed -E '/^[[:space:]]*$/d; s|(.+)|#include "\1"|' \
  > "$PINNED_SOURCE/levels/level_headers.h"

LEVEL_HEADERS_SHA256="fdfe0de8afdb3c751251a6ecbe10ef5b109b3b6711a9b430a32a88641a5d958c"
if [ "$(wc -l < "$PINNED_SOURCE/levels/level_headers.h")" -ne 31 ]; then
  echo "derived levels/level_headers.h has an unexpected line count" >&2
  exit 1
fi
if ! printf '%s  %s\n' "$LEVEL_HEADERS_SHA256" \
    "$PINNED_SOURCE/levels/level_headers.h" | sha256sum -c --status; then
  echo "derived levels/level_headers.h does not match the pinned digest" >&2
  exit 1
fi

# Flags are intentionally ordered and recorded verbatim in every generated
# header. They match the N64-oriented pipeline used by the neighboring proof.
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
  "title_screen:src/menu/title_screen.c"
  "game_init:src/game/game_init.c"
  "level_update:src/game/level_update.c"
  "level_script:src/engine/level_script.c"
  "geo_layout:src/engine/geo_layout.c"
  "surface_load:src/engine/surface_load.c"
  "level_scripts:levels/scripts.c"
  "intro_level_script:levels/intro/script.c"
  "menu_level_script:levels/menu/script.c"
  "star_select:src/menu/star_select.c"
  "memory:src/game/memory.c"
  "area:src/game/area.c"
  "camera:src/game/camera.c"
  "ingame_menu:src/game/ingame_menu.c"
  "bitdw_level_script:levels/bitdw/script.c"
  "bowser_1_level_script:levels/bowser_1/script.c"
  "wf_level_script:levels/wf/script.c"
  "ccm_level_script:levels/ccm/script.c"
  "bbh_level_script:levels/bbh/script.c"
  "jrb_level_script:levels/jrb/script.c"
  "hmc_level_script:levels/hmc/script.c"
  "pss_level_script:levels/pss/script.c"
)

generate_one() {
  local version="$1"
  local stem="$2"
  local source_path="$3"
  local source_label="$source_path"
  local input="$PINNED_SOURCE/$source_path"
  local output="$PROJECT_ROOT/generated/${version}_${stem}.v"
  local version_flags=()
  local unit_flags=()

  case "$version" in
    us)
      version_flags=(-DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1)
      ;;
    jp)
      version_flags=(-DVERSION_JP=1 -DF3D_OLD=1)
      ;;
    *) echo "unsupported version: $version" >&2; exit 2 ;;
  esac

  case "$source_path" in
    levels/scripts.c)
      unit_flags=("-I$PINNED_SOURCE/levels")
      ;;
    src/menu/star_select.c|src/game/ingame_menu.c)
      # Reproduce upstream's text_strings.h/text_menu_strings.h rules using
      # the pinned textconv implementation, never an ambient generated header.
      local text_include="$PROJECT_ROOT/build/text-$version"
      mkdir -p "$text_include"
      cc -O2 -I "$PINNED_SOURCE/tools" \
        "$PINNED_SOURCE/tools/textconv.c" "$PINNED_SOURCE/tools/utf8.c" \
        "$PINNED_SOURCE/tools/hashtable.c" -o "$text_include/textconv"
      cc -E -P -x c "-DVERSION_${version^^}=1" "$PINNED_SOURCE/charmap.txt" \
        > "$text_include/charmap.txt"
      "$text_include/textconv" "$PINNED_SOURCE/charmap_menu.txt" \
        "$PINNED_SOURCE/include/text_menu_strings.h.in" \
        "$text_include/text_menu_strings.h"
      "$text_include/textconv" "$text_include/charmap.txt" \
        "$PINNED_SOURCE/include/text_strings.h.in" "$text_include/text_strings.h"
      unit_flags=("-I$text_include")
      ;;
  esac

  bash "$PROJECT_ROOT/pipeline/clightgen.sh" \
    "$input" "$source_label" "VERSION_${version^^}" "$output" \
    "${COMMON_FLAGS[@]}" "${unit_flags[@]}" "${version_flags[@]}"
}

export CLIGHTGEN_SOURCE_ROOT="$PINNED_SOURCE"
export CLIGHTGEN_PROJECT_ROOT="$PROJECT_ROOT"

# shellcheck disable=SC1091
source "$PROJECT_ROOT/pipeline/env.sh"

for version in us jp; do
  for unit in "${TRANSLATION_UNITS[@]}"; do
    stem="${unit%%:*}"
    source_path="${unit#*:}"
    generate_one "$version" "$stem" "$source_path"
  done
done

echo "generated ${#TRANSLATION_UNITS[@]} translation units for VERSION_US and VERSION_JP"
