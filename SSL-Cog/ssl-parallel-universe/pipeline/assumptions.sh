#!/usr/bin/env bash
set -euo pipefail

TMP="$(mktemp --tmpdir=. assumptionsXXXXXX.v)"
TMP_BASE="$(basename "${TMP%.v}")"
trap 'rm -f "$TMP" "${TMP%.v}.vo" "${TMP%.v}.vos" "${TMP%.v}.vok" "${TMP%.v}.glob" "${TMP%.v}.aux" ".${TMP_BASE}.aux"' EXIT

if [ "$#" -eq 0 ]; then
  cat > "$TMP" <<'COQ'
From SSLPU.Proofs Require Import ParallelUniverse.
Print Assumptions ssl_area2_no_parallel_universe.
COQ
  coqc -q -R generated SSLPU.Generated -R proofs SSLPU.Proofs "$TMP"
  exit 0
fi

MODULE="$1"
THEOREM="$2"

cat > "$TMP" <<COQ
From ${MODULE%.*} Require Import ${MODULE##*.}.
Print Assumptions ${THEOREM}.
COQ
coqc -q -R generated SSLPU.Generated -R proofs SSLPU.Proofs "$TMP"
