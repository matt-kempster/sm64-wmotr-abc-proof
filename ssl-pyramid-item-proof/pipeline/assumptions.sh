#!/usr/bin/env bash
set -euo pipefail

MODULE="${1:-SSLPyramid.Proofs.TransitionFacts}"
THEOREM="${2:-transition_structural_spine}"
TMP="$(mktemp /tmp/assumptions_XXXXXX.v)"
trap 'rm -f "$TMP"' EXIT

printf '%s\n' \
  "From ${MODULE%.*} Require Import ${MODULE##*.}." \
  "Print Assumptions $THEOREM." \
  > "$TMP"

coqc \
  -R generated SSLPyramid.Generated \
  -R proofs SSLPyramid.Proofs \
  "$TMP"
