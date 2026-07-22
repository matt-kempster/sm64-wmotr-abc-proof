#!/usr/bin/env bash
set -euo pipefail

SM64="${SM64_SOURCE:-../../../../reference-sm64-decomp}"
AUDIT_TMP="$(mktemp --tmpdir=. pole-auditXXXXXX.txt)"
trap 'rm -f "$AUDIT_TMP"' EXIT

PYTHONDONTWRITEBYTECODE=1 python3 pipeline/audit_pole_transfer.py \
  "$SM64" > "$AUDIT_TMP"
diff -u generated/pole_transfer_audit.txt "$AUDIT_TMP"

make proofs

if grep -RInE '\b(Admitted|Axiom|admit|sorry)\b' proofs; then
  echo "proof hole or project-added axiom found" >&2
  exit 1
fi

bash pipeline/assumptions.sh \
  SSLPoleBypass.Proofs.PoleBypass \
  pole_route_minimum_a_certificate
bash pipeline/assumptions.sh \
  SSLPoleBypass.Proofs.PoleRoute \
  closed_world_pole_route_minimum_a_is_one
bash pipeline/assumptions.sh \
  SSLPoleBypass.Proofs.GlobalBoundary \
  global_lower_bound_from_bypass_model_complete

echo "SSL pole-bypass checks: OK"
