#!/usr/bin/env bash
# Generate additional ORIGINAL translation units for the exploratory interpreter.
# Does not replace the committed gameplay program, edit C, or delete build output.
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$PROJECT_ROOT/pipeline/env.sh"
ulimit -S -v "${SM64_PROOF_VCAP_KB:-6815744}"
REVISION=9921382a68bb0c865e5e45eb594d9c64db59b1af
SOURCE_REPOSITORY="${SM64_SOURCE:-$PROJECT_ROOT/../../../reference-sm64-decomp}"
OUTPUT="$PROJECT_ROOT/build/rank1-backward-search/supplemental-generated"
mkdir -p "$OUTPUT"
TASK_SOURCE="$(mktemp -d "$PROJECT_ROOT/build/rank1-backward-search/source.XXXXXX")"
git -c "safe.directory=$SOURCE_REPOSITORY" -C "$SOURCE_REPOSITORY" archive --format=tar "$REVISION" |
  tar -xf - -C "$TASK_SOURCE"
export CLIGHTGEN_SOURCE_ROOT="$TASK_SOURCE"
export CLIGHTGEN_PROJECT_ROOT="$PROJECT_ROOT"
COMMON=( -nostdinc -fstruct-passing
  "-I$(opam var lib --switch "$PROOF_SWITCH")/compcert/include"
  "-I$TASK_SOURCE/include" "-I$TASK_SOURCE/src" "-I$TASK_SOURCE/src/game"
  "-I$TASK_SOURCE" "-I$TASK_SOURCE/include/libc"
  -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 )
for item in "$@"; do
  stem="${item%%=*}"
  input="${item#*=}"
  [[ "$stem" =~ ^[a-zA-Z0-9_]+$ && "$input" =~ ^src/[a-zA-Z0-9_./]+\.c$ && "$input" != *..* ]] || {
    echo 'Expected safe name=src/path.c arguments' >&2; exit 2;
  }
  # Match the game's own PNG -> u8 include build rule. These are existing
  # extracted assets, never blank stand-ins; they stay in ignored build output.
  while IFS= read -r texture; do
    [[ "$texture" == textures/* && "$texture" != *..* ]] || exit 2
    png="$SOURCE_REPOSITORY/$texture.png"
    test -f "$png" || { echo "Missing original asset $png" >&2; exit 1; }
    mkdir -p "$TASK_SOURCE/$(dirname "$texture")"
    "$SOURCE_REPOSITORY/tools/sm64tools/n64graphics" -s u8 \
      -i "$TASK_SOURCE/$texture.inc.c" -g "$png" -f "${texture##*.}"
  done < <(sed -n 's/^#include "\(textures\/.*\)\.inc\.c".*/\1/p' "$TASK_SOURCE/$input")
  for version in us jp; do
    if [ "$version" = us ]; then
      FLAGS=(-DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1)
    else
      FLAGS=(-DVERSION_JP=1 -DF3D_OLD=1)
    fi
    if grep -q '^#include "text_strings.h"' "$TASK_SOURCE/$input"; then
      cpp -P -x c -Wno-trigraphs "${FLAGS[@]}" "$TASK_SOURCE/charmap.txt" \
        -o "$TASK_SOURCE/charmap-$version.txt"
      "$SOURCE_REPOSITORY/tools/textconv" "$TASK_SOURCE/charmap-$version.txt" \
        "$TASK_SOURCE/include/text_strings.h.in" "$TASK_SOURCE/include/text_strings.h"
      "$SOURCE_REPOSITORY/tools/textconv" "$TASK_SOURCE/charmap_menu.txt" \
        "$TASK_SOURCE/include/text_menu_strings.h.in" "$TASK_SOURCE/include/text_menu_strings.h"
    fi
    bash "$PROJECT_ROOT/pipeline/clightgen.sh" "$TASK_SOURCE/$input" "$input" \
      "VERSION_${version^^}" "$OUTPUT/${version}_${stem}.v" \
      "${COMMON[@]}" "${FLAGS[@]}"
  done
done
printf 'Original supplemental Clight saved in %s\n' "$OUTPUT"
