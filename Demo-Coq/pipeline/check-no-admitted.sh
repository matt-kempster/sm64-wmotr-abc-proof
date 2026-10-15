#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if grep -RInE --include='*.v' \
    '\b(Admitted|admit|Abort|Axiom|Conjecture|Parameter|sorry|give_up)\b' \
    "$PROJECT_ROOT/proofs" "$PROJECT_ROOT/generated"; then
  echo "forbidden proof hole or unconstrained declaration found" >&2
  exit 1
fi

echo "no forbidden proof holes or unconstrained declarations found"
