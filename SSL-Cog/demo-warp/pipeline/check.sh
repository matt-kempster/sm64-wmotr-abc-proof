#!/usr/bin/env bash
set -euo pipefail

make generated
make proofs

if grep -RInE '\b(Admitted|Axiom|admit|sorry)\b' proofs; then
  echo "proof hole or added axiom found" >&2
  exit 1
fi

bash pipeline/source-census.sh
bash pipeline/assumptions.sh
bash pipeline/assumptions.sh \
  DemoWarp.Proofs.ReachabilityBoundary \
  separated_demo_pointer_cannot_change_mario_y
bash pipeline/assumptions.sh \
  DemoWarp.Proofs.NormalInitialization \
  normal_initialization_forbids_demo_pointer_mario_y_alias
bash pipeline/assumptions.sh \
  DemoWarp.Proofs.GameplayInputBoundary \
  normal_controller_path_preserves_no_alias_boundary
