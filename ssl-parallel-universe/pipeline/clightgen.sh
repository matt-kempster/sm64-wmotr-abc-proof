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
TMP="$(mktemp --suffix=.v)"
trap 'rm -f "$TMP"' EXIT

VERSION="$(clightgen -version 2>/dev/null | head -1)"
clightgen -normalize "$@" -o "$TMP" "$INPUT"

{
  echo "(* ======================================================================"
  echo "   GENERATED FILE -- DO NOT EDIT."
  echo "   Produced by: pipeline/clightgen.sh"
  echo "   From source: $INPUT"
  echo "   clightgen:   $VERSION"
  echo "   Flags:       -normalize $*"
  echo "   ====================================================================== *)"
  sed 's/\r$//' "$TMP"
} > "$OUTPUT"

echo "wrote $OUTPUT"
