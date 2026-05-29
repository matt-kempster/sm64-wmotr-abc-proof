#!/usr/bin/env bash
# Reusable pipeline step: run CompCert clightgen on a C translation unit and emit a
# Clight AST as a Rocq .v file into generated/, stamped with a DO-NOT-EDIT header.
#
# Determinism: the header is fixed text, so re-running this on the same input + same
# clightgen version yields a byte-identical file. That is what makes the committed
# generated/*.v auditable ("regenerate and diff").
#
# Usage:
#   pipeline/clightgen.sh <input.c> <output.v> [extra clightgen args...]
#
# Example (M0):
#   pipeline/clightgen.sh experiments/toy/toy.c generated/toy.v
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "usage: $0 <input.c> <output.v> [extra clightgen args...]" >&2
  exit 2
fi

INPUT="$1"; OUTPUT="$2"; shift 2

if ! command -v clightgen >/dev/null 2>&1; then
  echo "clightgen not on PATH. Run: source pipeline/env.sh" >&2
  exit 1
fi

CGVERSION="$(clightgen -version 2>/dev/null | head -1 || echo 'unknown')"
TMP="$(mktemp --suffix=.v)"
trap 'rm -f "$TMP"' EXIT

# -normalize: put memory accesses in normalized form, recommended for program proof.
clightgen -normalize "$@" -o "$TMP" "$INPUT"

{
  echo "(* ======================================================================"
  echo "   GENERATED FILE -- DO NOT EDIT."
  echo "   Produced by: pipeline/clightgen.sh"
  echo "   From source: $INPUT"
  echo "   clightgen:   $CGVERSION"
  echo "   Flags:       -normalize $*"
  echo "   Regenerate:  make regen   (output must be byte-identical)"
  echo "   ====================================================================== *)"
  cat "$TMP"
} > "$OUTPUT"

echo "wrote $OUTPUT (from $INPUT, $CGVERSION)"
