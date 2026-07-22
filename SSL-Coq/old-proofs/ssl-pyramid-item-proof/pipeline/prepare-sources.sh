#!/usr/bin/env bash
set -euo pipefail

if [ -n "${SM64_SOURCE:-}" ]; then
  SM64="$SM64_SOURCE"
else
  SM64=""
  for candidate in ../../../../reference-sm64-decomp ../../../reference-sm64-decomp ../../reference-sm64-decomp; do
    if [ -d "$candidate/src" ]; then
      SM64="$candidate"
      break
    fi
  done
  SM64="${SM64:-../../../../reference-sm64-decomp}"
fi
OUT="build/source"

mkdir -p "$OUT"
cp "$SM64/src/game/object_helpers.c" "$OUT/object_helpers.c"
sed -i 's/\r$//' "$OUT/object_helpers.c"
patch --silent --forward \
  "$OUT/object_helpers.c" \
  patches/object_helpers-clightgen.patch

echo "prepared $OUT/object_helpers.c"
