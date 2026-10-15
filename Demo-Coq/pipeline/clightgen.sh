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

CLIGHTGEN_CMD="${CLIGHTGEN:-clightgen}"
if ! command -v "$CLIGHTGEN_CMD" >/dev/null 2>&1; then
  echo "clightgen is not on PATH; source pipeline/env.sh first" >&2
  exit 1
fi

CLIGHTGEN_VERSION="$("$CLIGHTGEN_CMD" -version 2>/dev/null | head -1)"
case "$CLIGHTGEN_VERSION" in
  *"version 3.15"*) ;;
  *)
    echo "expected CompCert clightgen 3.15, got: $CLIGHTGEN_VERSION" >&2
    exit 1
    ;;
esac

mkdir -p "$(dirname "$OUTPUT")"
TMP_V="$(mktemp --suffix=.v)"
FINAL_V="$(mktemp "$(dirname "$OUTPUT")/.clightgen-output.XXXXXX")"
trap 'rm -f "$TMP_V" "$FINAL_V"' EXIT

"$CLIGHTGEN_CMD" -normalize "$@" -o "$TMP_V" "$INPUT"

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
ATOM_PREFIX="$(basename "$OUTPUT" .v)"

{
  echo "(* ======================================================================"
  echo "   GENERATED FILE -- DO NOT EDIT."
  echo "   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af"
  echo "   Game version:    $GAME_VERSION"
  echo "   Source:          $SOURCE_LABEL"
  echo "   Generator:       $CLIGHTGEN_VERSION"
  echo "   Flags:           -normalize $DISPLAY_FLAGS"
  echo "   Link hygiene:    private __stringlit_N atoms prefixed with $ATOM_PREFIX"
  echo "   ====================================================================== *)"
  sed_args=(
    -E
    -e "s|^(Definition ___stringlit_[0-9]+ : ident := \\$\")__stringlit_|\1__${ATOM_PREFIX}_stringlit_|"
    -e 's/\r$//'
    -e 's/[[:space:]]+$//'
  )
  if [ -n "${CLIGHTGEN_SOURCE_ROOT:-}" ] &&
     [ -n "${CLIGHTGEN_PROJECT_ROOT:-}" ]; then
    sed_args+=(
      -e "s|$CLIGHTGEN_SOURCE_ROOT|build/pinned-sm64|g"
      -e "s|$CLIGHTGEN_PROJECT_ROOT|.|g"
    )
  fi
  sed "${sed_args[@]}" "$TMP_V"
} | awk '
  NF {
    while (pending_blank_lines > 0) {
      print ""
      pending_blank_lines--
    }
    print
    next
  }
  { pending_blank_lines++ }
' > "$FINAL_V"

# Reproducibility checks regenerate every unit twice. Preserve timestamps for
# identical ASTs so those checks do not invalidate the complete proof build.
if cmp -s "$FINAL_V" "$OUTPUT"; then
  echo "unchanged $OUTPUT"
else
  mv -- "$FINAL_V" "$OUTPUT"
  echo "wrote $OUTPUT"
fi
