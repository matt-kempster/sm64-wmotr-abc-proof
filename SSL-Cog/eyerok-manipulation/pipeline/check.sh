#!/usr/bin/env bash
set -euo pipefail

SM64="${SM64_SOURCE:-../../../reference-sm64-decomp}"
AUDIT_TMP="$(mktemp --tmpdir=. eyerok-auditXXXXXX.txt)"
trap 'rm -f "$AUDIT_TMP"' EXIT

PYTHONDONTWRITEBYTECODE=1 python3 pipeline/audit_eyerok_source.py \
  "$SM64" > "$AUDIT_TMP"
diff -u generated/source_audit.txt "$AUDIT_TMP"

make proofs

if grep -RInE '\b(Admitted|Axiom|admit|sorry)\b' proofs; then
  echo "proof hole or project-added axiom found" >&2
  exit 1
fi

echo "Eyerok source-ingestion checks: OK"
