#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 /path/to/authentic/baserom.jp.z64}"

bash "$script_dir/verify.sh" "$rom"

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
    "$project_dir/build/instrumentation/jp-rank5-state-split.XXXXXX")"
mkdir -p "$out_dir/config" "$out_dir/data" "$out_dir/shots"
plugin="$out_dir/jp-rank5-state-split.so"
raw_log="$out_dir/jp-rank5-state-split.raw.log"
receipt="$out_dir/state-split-receipt.txt"

gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
    -DALLOW_SETUP_A=0 -DSEARCH_MODE=12 \
    -DRANK1_BOUNDARY_AUDIT=1 -DRANK1_BOUNDARY_REPEAT_UNTIL=349 \
    -DRANK5_STATE_SPLIT_AUDIT=1 \
    "$project_dir/instrumentation/jp-clean-gap-search/jp_clean_gap_search_probe.c" \
    -ldl -lm -o "$plugin"

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
        --testshots 2850 "$rom" >"$raw_log" 2>&1

grep -a '^RANK5_' "$raw_log" >"$receipt"
if grep -q '^RANK5_STATE_SPLIT_ERROR,' "$receipt" \
    || ! grep -q '^RANK5_STATE_SPLIT_RESULT,.*invariant=1$' "$receipt" \
    || ! grep -q '^TOP,timer=848,pillars=1,' "$raw_log" \
    || ! grep -q '^TOP,timer=1065,pillars=2,' "$raw_log" \
    || ! grep -q '^TOP,timer=2390,pillars=3,' "$raw_log" \
    || ! grep -q '^TOP,timer=2548,pillars=4,' "$raw_log" \
    || ! grep -q '^ACTION,timer=2807,.*usedObj=80343578,' "$raw_log" \
    || ! grep -q '^ACTION,timer=2808,.*usedObj=80345918,' "$raw_log" \
    || ! grep -q '^RESULT,.*mode12PillarsComplete=1,.*warpDisappeared=1,warpUsedObj=1,platformTop=0,.*aPressedFrames=0,aDownFrames=0,controllerAFrames=0$' \
        "$raw_log"; then
    printf '%s\n' 'Rank-5/5A state-split invariant or route receipt failed' >&2
    printf 'Raw log: %s\n' "$raw_log" >&2
    printf 'Receipt: %s\n' "$receipt" >&2
    exit 3
fi

if [ -f "$script_dir/expected-state-split-receipt.txt" ]; then
    if ! diff -u "$script_dir/expected-state-split-receipt.txt" \
        "$receipt"; then
        printf '%s\n' 'exact Rank-5/5A state-split receipt failed' >&2
        exit 3
    fi
fi

printf '%s\n' 'Exact Rank-5/5A state-split receipt passed.'
printf 'Receipt: %s\n' "$receipt"
