#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="${1:-${SM64_SOURCE:-../../../reference-sm64-decomp}}"

test -f "$SOURCE_ROOT/src/game/game_init.c"
test -f "$SOURCE_ROOT/src/menu/title_screen.c"

MATCHES="$(grep -RIn --include='*.c' --include='*.h' 'gCurrDemoInput' "$SOURCE_ROOT/src")"
printf '%s\n' "$MATCHES"

WRITES="$(printf '%s\n' "$MATCHES" | grep -E 'gCurrDemoInput[[:space:]]*(=|\+\+|--)|\+\+gCurrDemoInput|--gCurrDemoInput' || true)"
printf '\nDirect syntactic writes:\n%s\n' "$WRITES"

test "$(printf '%s\n' "$WRITES" | grep -c .)" -eq 4

