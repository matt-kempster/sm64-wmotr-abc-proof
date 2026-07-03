#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
  coqtop -quiet <<'COQ'
From SSLPU.Proofs Require Import ParallelUniverse.
Print Assumptions ssl_area2_no_parallel_universe.
COQ
  exit 0
fi

MODULE="$1"
THEOREM="$2"

coqtop -quiet <<COQ
From ${MODULE%.*} Require Import ${MODULE##*.}.
Print Assumptions ${THEOREM}.
COQ
