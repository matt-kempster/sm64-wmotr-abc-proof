#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$PROJECT_ROOT/pipeline/env.sh" >/dev/null
if [ "$#" -eq 0 ]; then set -- Demo.Proofs.MainTheorem; fi
coqchk -silent -Q "$PROJECT_ROOT/generated" Demo.Generated \
  -Q "$PROJECT_ROOT/proofs" Demo.Proofs "$@"
