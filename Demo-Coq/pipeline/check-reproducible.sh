#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FIRST_MANIFEST="$(mktemp)"
SECOND_MANIFEST="$(mktemp)"
trap 'rm -f "$FIRST_MANIFEST" "$SECOND_MANIFEST"' EXIT

manifest() {
  (
    cd "$PROJECT_ROOT/generated"
    set -- ./*.v
    if [ ! -e "$1" ]; then
      echo "no generated Clight files found" >&2
      exit 1
    fi
    sha256sum "$@"
  )
}

bash "$PROJECT_ROOT/pipeline/generate-clight.sh"
manifest > "$FIRST_MANIFEST"
bash "$PROJECT_ROOT/pipeline/generate-clight.sh"
manifest > "$SECOND_MANIFEST"

if ! diff -u "$FIRST_MANIFEST" "$SECOND_MANIFEST"; then
  echo "successive clightgen runs are not byte-for-byte identical" >&2
  exit 1
fi

echo "successive clightgen runs are byte-for-byte identical"
