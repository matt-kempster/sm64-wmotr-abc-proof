#!/usr/bin/env bash
# Reproduce the supplemental audio units without changing the gameplay link.
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$PROJECT_ROOT/build"
CHECK_DIR="$(mktemp -d "$PROJECT_ROOT/build/audio-reproduction.XXXXXX")"
(
  cd "$PROJECT_ROOT"
  sha256sum generated/runtime/us_audio_external.v generated/runtime/jp_audio_external.v
) > "$CHECK_DIR/before.sha256"
bash "$PROJECT_ROOT/pipeline/generate-audio-clight.sh"
(
  cd "$PROJECT_ROOT"
  sha256sum generated/runtime/us_audio_external.v generated/runtime/jp_audio_external.v
) > "$CHECK_DIR/after.sha256"
diff -u "$CHECK_DIR/before.sha256" "$CHECK_DIR/after.sha256"
echo "supplemental US/JP audio Clight reproduces byte-for-byte ($CHECK_DIR)"
