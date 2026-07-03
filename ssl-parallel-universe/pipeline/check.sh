#!/usr/bin/env bash
set -euo pipefail

make proofs

if grep -RInE '\b(Admitted|Axiom|admit|sorry)\b' proofs; then
  echo "proof hole or project-added axiom found" >&2
  exit 1
fi

bash pipeline/assumptions.sh
bash pipeline/assumptions.sh \
  SSLPU.Proofs.MovementSourceFacts \
  bounded_certificate_does_not_cover_movement_sources
bash pipeline/assumptions.sh \
  SSLPU.Proofs.BLJRoute \
  ssl_area2_blj_source_counterexample_envelope
