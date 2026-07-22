#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -gt 0 ]; then
  SOURCE_ROOT="$1"
elif [ -n "${SM64_SOURCE:-}" ]; then
  SOURCE_ROOT="$SM64_SOURCE"
else
  SOURCE_ROOT=""
  for candidate in ../../../../reference-sm64-decomp ../../../reference-sm64-decomp ../../reference-sm64-decomp; do
    if [ -d "$candidate/src" ]; then
      SOURCE_ROOT="$candidate"
      break
    fi
  done
  SOURCE_ROOT="${SOURCE_ROOT:-../../../../reference-sm64-decomp}"
fi

if [ ! -d "$SOURCE_ROOT/src" ]; then
  echo "SM64 source tree not found at $SOURCE_ROOT" >&2
  exit 1
fi

ACTUAL="$(mktemp)"
EXPECTED="$(mktemp)"
trap 'rm -f "$ACTUAL" "$EXPECTED"' EXIT

LC_ALL=C grep -RInE \
  'activeAreaIndex[[:space:]]*=' \
  "$SOURCE_ROOT/src" \
  --include='*.c' --include='*.h' |
  grep -vE 'activeAreaIndex[[:space:]]*==' |
  sed "s#^$SOURCE_ROOT/##" |
  sed 's/\r$//' |
  LC_ALL=C sort > "$ACTUAL"

cat > "$EXPECTED" <<'EOF'
src/engine/graph_node.c:721:    graphNode->activeAreaIndex = spawn->activeAreaIndex;
src/engine/level_script.c:425:    gMarioSpawnInfo->activeAreaIndex = -1;
src/engine/level_script.c:453:        spawnInfo->activeAreaIndex = sCurrAreaIndex;
src/game/macro_special_objects.c:112:    gMacroObjectDefaultParent.header.gfx.activeAreaIndex = areaIndex;
src/game/macro_special_objects.c:184:    gMacroObjectDefaultParent.header.gfx.activeAreaIndex = areaIndex;
src/game/macro_special_objects.c:254:    gMacroObjectDefaultParent.header.gfx.activeAreaIndex = areaIndex;
src/game/object_helpers.c:535:    obj->header.gfx.activeAreaIndex = parent->header.gfx.areaIndex;
EOF

if ! diff -u "$EXPECTED" "$ACTUAL"; then
  echo "activeAreaIndex source census changed; regenerate and audit the proof inputs" >&2
  exit 1
fi

echo "activeAreaIndex source census matches the pinned seven assignments."
