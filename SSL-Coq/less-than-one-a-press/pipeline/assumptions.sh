#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <module> <theorem>" >&2
  exit 2
fi

MODULE="$1"
THEOREM="$2"
COQC_CMD="${COQBIN:-}coqc"
AUDIT_DIR="$(mktemp -d)"
TMP="$AUDIT_DIR/AssumptionAudit.v"
OUTPUT="$AUDIT_DIR/AssumptionAudit.out"
trap 'rm -f "$AUDIT_DIR/AssumptionAudit.v" "$AUDIT_DIR/AssumptionAudit.vo" "$AUDIT_DIR/AssumptionAudit.vos" "$AUDIT_DIR/AssumptionAudit.vok" "$AUDIT_DIR/AssumptionAudit.glob" "$AUDIT_DIR/.AssumptionAudit.aux" "$AUDIT_DIR/AssumptionAudit.out"; rmdir "$AUDIT_DIR"' EXIT

{
  echo "Require Import $MODULE."
  echo "Print Assumptions $THEOREM."
} > "$TMP"

if ! "$COQC_CMD" -q -R generated LessThanOneAPress.Generated \
    -R proofs LessThanOneAPress.Proofs "$TMP" >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  exit 1
fi

cat "$OUTPUT"

# CompCert and Coq legitimately expose foundational semantics/classical
# assumptions.  Reject any dependency declared in this project's own logical
# namespace; the separate source scan rejects local Axiom/Parameter syntax.
if grep -Eq '^[[:space:]]*LessThanOneAPress\.' "$OUTPUT"; then
  echo "project-local theorem assumption found" >&2
  exit 1
fi
