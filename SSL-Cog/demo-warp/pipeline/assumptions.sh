#!/usr/bin/env bash
set -euo pipefail

MODULE="${1:-DemoWarp.Proofs.Counterexample}"
THEOREM="${2:-demo_timer_mario_y_counterexample_capstone}"
TMP="$(mktemp --tmpdir=. assumptionsXXXXXX.v)"
TMP_BASE="$(basename "${TMP%.v}")"
trap 'rm -f "$TMP" "${TMP%.v}.vo" "${TMP%.v}.vos" \
  "${TMP%.v}.vok" "${TMP%.v}.glob" "${TMP%.v}.aux" \
  ".${TMP_BASE}.aux"' EXIT

printf '%s\n' \
  "From ${MODULE%.*} Require Import ${MODULE##*.}." \
  "Print Assumptions $THEOREM." \
  > "$TMP"

coqc -q \
  -R generated DemoWarp.Generated \
  -R proofs DemoWarp.Proofs \
  "$TMP"
