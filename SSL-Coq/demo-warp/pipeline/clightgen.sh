#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "usage: $0 <input.c> <output.v> [clightgen arguments...]" >&2
  exit 2
fi

INPUT="$1"
OUTPUT="$2"
shift 2

mkdir -p "$(dirname "$OUTPUT")"
TMP="$(mktemp --suffix=.v)"
trap 'rm -f "$TMP"' EXIT

VERSION="$(clightgen -version 2>/dev/null | head -1)"
clightgen -normalize "$@" -o "$TMP" "$INPUT"

{
  echo "(* GENERATED FILE -- DO NOT EDIT."
  echo "   Source: $INPUT"
  echo "   clightgen: $VERSION"
  echo "   Flags: -normalize $* *)"
  sed 's/\r$//' "$TMP"
} > "$OUTPUT"

echo "wrote $OUTPUT"

