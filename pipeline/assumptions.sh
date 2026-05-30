#!/usr/bin/env bash
# Print the axiom dependencies of one or more lemmas (the de-Bruijn trust check:
# "Closed under the global context" = no axioms). ONE command so the allowlist can
# match `bash pipeline/assumptions.sh *` as a unit -> no approval prompt.
#
#   bash pipeline/assumptions.sh SM64.Proofs.ActionWriters new_batch_has_no_action_field_writers [more lemmas...]
#
# First arg is the module's logical path (e.g. SM64.Proofs.ActionWriters); the
# rest are lemma names within it.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck disable=SC1091
source pipeline/env.sh

if [ $# -lt 2 ]; then
  echo "usage: $0 <Module.Logical.Path> <lemma> [lemma...]" >&2
  exit 2
fi

MODULE="$1"; shift
# coqc derives a module name from the basename, so it must be a valid Coq ident
# (letters/digits/underscore, no dots). Use a fixed dot-free name in a temp dir.
TMPDIR="$(mktemp -d)"
TMP="$TMPDIR/AssumptionsProbe.v"
trap 'rm -rf "$TMPDIR"' EXIT

{
  echo "From ${MODULE%.*} Require Import ${MODULE##*.}."
  for lemma in "$@"; do
    echo "Print Assumptions ${MODULE##*.}.${lemma}."
  done
} > "$TMP"

coqc -R generated SM64.Generated -R proofs SM64.Proofs "$TMP"
