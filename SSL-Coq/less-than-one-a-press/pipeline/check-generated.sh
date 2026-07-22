#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$PROJECT_ROOT/build"
BEFORE="$PROJECT_ROOT/build/generated-before.sha256"
AFTER="$PROJECT_ROOT/build/generated-after.sha256"

(
  cd "$PROJECT_ROOT"
  sha256sum generated/*.v
) > "$BEFORE"

bash "$PROJECT_ROOT/pipeline/generate-clight.sh"

(
  cd "$PROJECT_ROOT"
  sha256sum generated/*.v
) > "$AFTER"

diff -u "$BEFORE" "$AFTER"
echo "generated Clight files reproduce byte-for-byte"

