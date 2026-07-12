#!/usr/bin/env bash
set -euo pipefail

SM64="${SM64_SOURCE:-../../../reference-sm64-decomp}"
PYTHONDONTWRITEBYTECODE=1 python3 pipeline/check_grindel_route.py "$SM64"

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
bash pipeline/assumptions.sh \
  SSLPU.Proofs.BLJGeometry \
  ssl_area2_lower_entry_geometry_input_status
bash pipeline/assumptions.sh \
  SSLPU.Proofs.BLJDynamic \
  ssl_area2_grindel_dynamic_counterexample_certificate
