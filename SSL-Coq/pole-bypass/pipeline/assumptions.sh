#!/usr/bin/env bash
set -euo pipefail

MODULE="${1:-SSLPoleBypass.Proofs.PoleBypass}"
THEOREM="${2:-pole_route_minimum_a_certificate}"

TMP="$(mktemp --tmpdir=. assumptionsXXXXXX.v)"
TMP_BASE="$(basename "${TMP%.v}")"
trap 'rm -f "$TMP" "${TMP%.v}.vo" "${TMP%.v}.vos" "${TMP%.v}.vok" "${TMP%.v}.glob" "${TMP%.v}.aux" ".${TMP_BASE}.aux"' EXIT

cat > "$TMP" <<COQ
From ${MODULE%.*} Require Import ${MODULE##*.}.
Print Assumptions ${THEOREM}.
COQ

coqc -q -R generated SSLPoleBypass.Generated \
  -R proofs SSLPoleBypass.Proofs "$TMP"
