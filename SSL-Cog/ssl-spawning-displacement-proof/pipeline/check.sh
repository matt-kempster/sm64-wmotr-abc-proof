#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="${1:-${SM64_SOURCE:-}}"

make proofs

if grep -RInE '\b(Admitted|Axiom|admit|sorry)\b' proofs; then
  echo "proof hole or added axiom found" >&2
  exit 1
fi

bash pipeline/source-census.sh "$SOURCE_ROOT"
