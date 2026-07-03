#!/usr/bin/env bash
set -euo pipefail

make proofs

if grep -RInE '\b(Admitted|Axiom|admit|sorry)\b' proofs; then
  echo "proof hole or project-added axiom found" >&2
  exit 1
fi

bash pipeline/assumptions.sh
