#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="${1:-${SM64_SOURCE:-../../../../reference-sm64-decomp}}"

test -f "$SOURCE_ROOT/src/game/game_init.c"
test -f "$SOURCE_ROOT/src/menu/title_screen.c"

MATCHES="$(grep -RIn --include='*.c' --include='*.h' 'gCurrDemoInput' "$SOURCE_ROOT/src")"
printf '%s\n' "$MATCHES"

POINTER_WRITES="$(printf '%s\n' "$MATCHES" |
  grep -P 'gCurrDemoInput\s*=(?!=)|gCurrDemoInput\s*\+\+' || true)"
POINTEE_WRITES="$(printf '%s\n' "$MATCHES" |
  grep -P '(--|\+\+)gCurrDemoInput->|gCurrDemoInput->[^;]*(--|\+\+|(?<!=)=(?!=))' || true)"

printf '\nDirect pointer writes/initialization:\n%s\n' "$POINTER_WRITES"
printf '\nDirect pointee writes:\n%s\n' "$POINTEE_WRITES"

test "$(printf '%s\n' "$POINTER_WRITES" | grep -c .)" -eq 4
test "$(printf '%s\n' "$POINTEE_WRITES" | grep -c .)" -eq 1
