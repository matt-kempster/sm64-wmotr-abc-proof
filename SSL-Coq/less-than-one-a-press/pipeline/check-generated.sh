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

EXPECTED_PER_VERSION=37
for version in us jp; do
  generated_count="$(
    find "$PROJECT_ROOT/generated" -maxdepth 1 -type f \
      -name "${version}_*.v" -printf '%f\n' | wc -l
  )"
  if [ "$generated_count" -ne "$EXPECTED_PER_VERSION" ]; then
    echo "expected $EXPECTED_PER_VERSION generated ${version} modules; found $generated_count" >&2
    exit 1
  fi
done

generated_total="$(
  find "$PROJECT_ROOT/generated" -maxdepth 1 -type f -name '*.v' -printf '%f\n' |
    wc -l
)"
if [ "$generated_total" -ne "$((2 * EXPECTED_PER_VERSION))" ]; then
  echo "unexpected generated .v file: expected $((2 * EXPECTED_PER_VERSION)); found $generated_total" >&2
  exit 1
fi

(
  cd "$PROJECT_ROOT"
  sha256sum generated/*.v
) > "$AFTER"

diff -u "$BEFORE" "$AFTER"
echo "generated Clight files reproduce byte-for-byte"
