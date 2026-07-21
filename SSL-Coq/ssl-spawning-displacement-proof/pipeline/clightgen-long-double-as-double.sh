#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "usage: $0 <input.c> <output.v> [clightgen arguments...]" >&2
  exit 2
fi

INPUT="$1"
OUTPUT="$2"
shift 2

if ! command -v clightgen >/dev/null 2>&1; then
  echo "clightgen is not on PATH; source pipeline/env.sh first" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"
TMP_C="$(mktemp --suffix=.c)"
TMP_V="$(mktemp --suffix=.v)"
trap 'rm -f "$TMP_C" "$TMP_V"' EXIT

# CompCert 3.15 does not accept C long-double constants. The N64 source uses
# seven of them in object_helpers.c, outside obj_set_held_state(). Translating
# them as double permits Clight generation without changing the audited
# function's preprocessed text or AST.
sed -E 's/([[:digit:]]+\.[[:digit:]]+)([lL])([^[:alnum:]_]|$)/\1\3/g' \
  "$INPUT" > "$TMP_C"

VERSION="$(clightgen -version 2>/dev/null | head -1)"
clightgen -normalize "$@" -o "$TMP_V" "$TMP_C"

{
  echo "(* ======================================================================"
  echo "   GENERATED FILE -- DO NOT EDIT."
  echo "   JP / VERSION_JP Clight artifact for ssl-spawning-displacement-proof."
  echo "   Produced by: pipeline/clightgen-long-double-as-double.sh"
  echo "   From source: $INPUT"
  echo "   clightgen:   $VERSION"
  echo "   Compatibility: C long-double literals translated as double."
  echo "   Flags:       -normalize $*"
  echo "   ====================================================================== *)"
  sed 's/\r$//' "$TMP_V"
} > "$OUTPUT"

echo "wrote $OUTPUT"
