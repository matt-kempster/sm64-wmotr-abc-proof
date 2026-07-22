#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 4 ]; then
  echo "usage: $0 <input.c> <source-label> <version> <output.v> [flags...]" >&2
  exit 2
fi

INPUT="$1"
SOURCE_LABEL="$2"
GAME_VERSION="$3"
OUTPUT="$4"
shift 4

if ! command -v clightgen >/dev/null 2>&1; then
  echo "clightgen is not on PATH; source pipeline/env.sh first" >&2
  exit 1
fi

CLIGHTGEN_VERSION="$(clightgen -version 2>/dev/null | head -1)"
case "$CLIGHTGEN_VERSION" in
  *"version 3.15"*) ;;
  *)
    echo "expected CompCert clightgen 3.15, got: $CLIGHTGEN_VERSION" >&2
    exit 1
    ;;
esac

mkdir -p "$(dirname "$OUTPUT")"
TMP_V="$(mktemp --suffix=.v)"
trap 'rm -f "$TMP_V"' EXIT

clightgen -normalize "$@" -o "$TMP_V" "$INPUT"

DISPLAY_ARGS=()
for flag in "$@"; do
  if [ -n "${CLIGHTGEN_SOURCE_ROOT:-}" ]; then
    case "$flag" in
      -I"$CLIGHTGEN_SOURCE_ROOT"*)
        flag="-Ibuild/pinned-sm64${flag#-I"$CLIGHTGEN_SOURCE_ROOT"}"
        ;;
    esac
  fi
  DISPLAY_ARGS+=("$flag")
done
DISPLAY_FLAGS="${DISPLAY_ARGS[*]}"

{
  echo "(* ======================================================================"
  echo "   GENERATED FILE -- DO NOT EDIT."
  echo "   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af"
  echo "   Game version:    $GAME_VERSION"
  echo "   Source:          $SOURCE_LABEL"
  echo "   Generator:       $CLIGHTGEN_VERSION"
  echo "   Flags:           -normalize $DISPLAY_FLAGS"
  echo "   ====================================================================== *)"
  if [ -n "${CLIGHTGEN_SOURCE_ROOT:-}" ] &&
     [ -n "${CLIGHTGEN_PROJECT_ROOT:-}" ]; then
    sed -e "s|$CLIGHTGEN_SOURCE_ROOT|build/pinned-sm64|g" \
        -e "s|$CLIGHTGEN_PROJECT_ROOT|.|g" \
        -e 's/\r$//' "$TMP_V"
  else
    sed 's/\r$//' "$TMP_V"
  fi
} > "$OUTPUT"

echo "wrote $OUTPUT"
