#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <module> <theorem>" >&2
  exit 2
fi

MODULE="$1"
THEOREM="$2"
AUDIT_DIR="$(mktemp -d)"
TMP="$AUDIT_DIR/AssumptionAudit.v"
trap 'rm -f "$AUDIT_DIR/AssumptionAudit.v" "$AUDIT_DIR/AssumptionAudit.vo" "$AUDIT_DIR/AssumptionAudit.vos" "$AUDIT_DIR/AssumptionAudit.vok" "$AUDIT_DIR/AssumptionAudit.glob" "$AUDIT_DIR/.AssumptionAudit.aux"; rmdir "$AUDIT_DIR"' EXIT

{
  echo "Require Import $MODULE."
  echo "Print Assumptions $THEOREM."
} > "$TMP"

coqc -q -R generated LessThanOneAPress.Generated \
  -R proofs LessThanOneAPress.Proofs "$TMP"
