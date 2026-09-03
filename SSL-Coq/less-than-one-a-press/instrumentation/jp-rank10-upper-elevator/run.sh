#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 /path/to/authentic/baserom.jp.z64 [test-frames] [mode]}"
test_frames="${2:-3900}"
mode="${3:-0}"

bash "$project_dir/instrumentation/jp-rank1-live-boundary/verify.sh" "$rom"

if [ -n "${MUPEN64PLUS:-}" ]; then
    emulator="$MUPEN64PLUS"
elif command -v mupen64plus >/dev/null 2>&1; then
    emulator="$(command -v mupen64plus)"
elif [ -x /usr/games/mupen64plus ]; then
    emulator=/usr/games/mupen64plus
else
    printf '%s\n' 'mupen64plus was not found' >&2
    exit 2
fi

mkdir -p "$project_dir/build/instrumentation"
out_dir="$(mktemp -d \
    "$project_dir/build/instrumentation/jp-rank10-upper-elevator.XXXXXX")"
mkdir -p "$out_dir/config" "$out_dir/data" "$out_dir/shots"
plugin="$out_dir/jp-rank10-upper-elevator.so"
raw_log="$out_dir/jp-rank10-upper-elevator.raw.log"
receipt="$out_dir/jp-rank10-upper-elevator.receipt.txt"
summary="$out_dir/jp-rank10-upper-elevator.summary.txt"

gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
    -DRANK10_MODE="$mode" \
    "$script_dir/jp_rank10_upper_elevator_probe.c" -ldl -lm -o "$plugin"

printf 'run\n' |
    XDG_CONFIG_HOME="$out_dir/config" \
    XDG_DATA_HOME="$out_dir/data" \
    LIBGL_ALWAYS_SOFTWARE=1 \
    xvfb-run -a "$emulator" \
        --debug --emumode 0 --nosaveoptions --nospeedlimit \
        --audio dummy --input "$plugin" \
        --gfx mupen64plus-video-rice.so \
        --rsp mupen64plus-rsp-hle.so \
        --cheats 6 --sshotdir "$out_dir/shots" \
        --testshots "$test_frames" "$rom" >"$raw_log" 2>&1

grep -a '^RANK10_' "$raw_log" >"$receipt"
if ! grep -q '^RANK10_AREA2_START,.*candidates=1,' "$receipt" \
    || ! grep -q '^RANK10_RESULT,.*sequentialFailures=0,.*elevatorCandidates=1,' "$receipt"; then
    printf '%s\n' 'Rank-10 live elevator observation failed' >&2
    exit 3
fi

if [ "$mode" = 1 ] && [ "$test_frames" = 3500 ]; then
    grep -E '^RANK10_(AREA2_START|STAGE|FIRST_WALL|RESULT)' \
        "$receipt" >"$summary"
    if ! cmp -s "$script_dir/expected-mode1-summary.txt" "$summary"; then
        diff -u "$script_dir/expected-mode1-summary.txt" "$summary" >&2 || true
        printf '%s\n' 'Rank-10 exact B-only receipt mismatch' >&2
        exit 4
    fi
fi

printf '%s\n' 'Rank-10 live elevator observation passed.'
printf 'Receipt: %s\n' "$receipt"
