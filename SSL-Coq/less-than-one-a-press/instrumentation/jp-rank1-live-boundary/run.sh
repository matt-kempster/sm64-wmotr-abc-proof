#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 /path/to/authentic/baserom.jp.z64 [test-frames] [search-mode] [exclusive-end-timer]}"
test_frames="${2:-370}"
search_mode="${3:-2}"
repeat_until="${4:-349}"

if [ "$test_frames" -lt 370 ]; then
    printf '%s\n' 'test-frames must be at least 370' >&2
    exit 2
fi

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
    "$project_dir/build/instrumentation/jp-rank1-live-boundary.XXXXXX")"
mkdir -p "$out_dir/config" "$out_dir/data" "$out_dir/shots"
plugin="$out_dir/jp-rank1-live-boundary.so"
raw_log="$out_dir/jp-rank1-live-boundary.raw.log"
receipt="$out_dir/live-boundary-receipt.txt"

gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
    -DALLOW_SETUP_A=0 -DSEARCH_MODE="$search_mode" \
    -DRANK1_BOUNDARY_AUDIT=1 \
    -DRANK1_BOUNDARY_REPEAT_UNTIL="$repeat_until" \
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
        --testshots "$test_frames" "$rom" >"$raw_log" 2>&1

grep -a '^RANK1_' "$raw_log" >"$receipt"
if [ "$repeat_until" -eq 349 ]; then
    if ! diff -u "$script_dir/expected-live-boundary-receipt.txt" "$receipt"; then
        printf '%s\n' 'exact Rank-1 live-boundary receipt failed' >&2
        exit 3
    fi
else
    expected_frames="$((repeat_until - 348))"
    if grep -q '^RANK1_BOUNDARY_END,.*invariant=0$' "$receipt" \
        || ! grep -q "^RANK1_REPEAT_RESULT,firstTimer=348,exclusiveEndTimer=${repeat_until},framesChecked=${expected_frames},frameFailures=0,invariant=1$" \
            "$receipt"; then
        printf '%s\n' 'repeated Rank-1 live-boundary invariant failed' >&2
        exit 3
    fi
fi
if ! grep -q '^RESULT,.*aPressedFrames=0,aDownFrames=0,controllerAFrames=0$' \
    "$raw_log"; then
    printf '%s\n' 'bounded receipt was not a zero-A execution' >&2
    exit 3
fi

if [ "$search_mode" -eq 12 ] && [ "$repeat_until" -eq 2810 ]; then
    expected_aggregate='RANK1_REPEAT_AGGREGATE,outsideSums=387550:52:5:415:1142:1:2390:0,outsideMaxima=223:2:1:5:5:1:33:0,destinationStoreSum=2290,destinationStoreMaximum=11,findFloorCallSum=149578,findFloorReturnSum=149578,dynamicFindFloorReturnSum=426,findFloorReturnFailureSum=0,findFloorBeforeClearSum=0,endInvalidSurfaceSum=6,pendingCleanupSurfaceSum=6,inactiveOwnerStoreSum=6,inactiveCollisionModelCallSum=1,staticSelectionFrames=2462,dynamicSelectionFrames=0,ownedSelectionFrames=0'
    if ! grep -Fqx "$expected_aggregate" "$receipt" \
        || ! grep -q '^TOP,timer=848,pillars=1,' "$raw_log" \
        || ! grep -q '^TOP,timer=1065,pillars=2,' "$raw_log" \
        || ! grep -q '^TOP,timer=2390,pillars=3,' "$raw_log" \
        || ! grep -q '^TOP,timer=2548,pillars=4,' "$raw_log" \
        || ! grep -q '^TOP,timer=2549,pillars=4,action=1,' "$raw_log" \
        || ! grep -q '^TOP,timer=2700,pillars=4,action=2,' "$raw_log" \
        || ! grep -q '^ACTION,timer=2807,.*usedObj=80343578,' "$raw_log" \
        || ! grep -q '^ACTION,timer=2808,.*usedObj=80345918,' "$raw_log" \
        || ! grep -q '^PREFIX_STAGE,.*timer=2830,area=2,' "$raw_log" \
        || ! grep -q '^RESULT,.*mode12Stage=9,.*mode12PillarsComplete=1,.*bPressedFrames=6,warpDisappeared=1,warpUsedObj=1,platformTop=0,.*aPressedFrames=0,aDownFrames=0,controllerAFrames=0$' \
            "$raw_log"; then
        printf '%s\n' 'exact Rank-1 four-pillar/upper-warp receipt failed' >&2
        exit 3
    fi
fi

printf '%s\n' 'Exact Rank-1 live-boundary receipt passed.'
printf 'Receipt: %s\n' "$receipt"
