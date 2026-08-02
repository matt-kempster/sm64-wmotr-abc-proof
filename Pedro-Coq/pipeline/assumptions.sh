#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <logical-module> <theorem>" >&2
  exit 2
fi

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODULE="$1"
THEOREM="$2"
TMP_V="$(mktemp --tmpdir PedroAssumptionsXXXXXX.v)"
TMP_VO="${TMP_V%.v}.vo"
trap 'rm -f "$TMP_V" "$TMP_VO" "${TMP_V%.v}.glob" "${TMP_V%.v}.vos" "${TMP_V%.v}.vok" "$(dirname "$TMP_V")/.$(basename "${TMP_V%.v}").aux"' EXIT

# shellcheck disable=SC1091
source "$PROJECT_ROOT/pipeline/env.sh" >/dev/null

printf 'From %s Require Import %s.\nPrint Assumptions %s.\n' \
  "${MODULE%.*}" "${MODULE##*.}" "$THEOREM" > "$TMP_V"

coqc -Q "$PROJECT_ROOT/generated" Pedro.Generated \
     -Q "$PROJECT_ROOT/proofs" Pedro.Proofs "$TMP_V"
