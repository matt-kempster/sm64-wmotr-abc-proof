#!/usr/bin/env bash
set -euo pipefail

MODULE="${1:-DemoWarp.Proofs.Counterexample}"
THEOREM="${2:-demo_timer_mario_y_counterexample_capstone}"

printf 'Require Import %s.\nPrint Assumptions %s.%s.\n' \
  "$MODULE" "$MODULE" "$THEOREM" | coqtop -quiet

