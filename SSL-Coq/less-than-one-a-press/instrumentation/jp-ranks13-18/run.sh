#!/usr/bin/env bash
set -euo pipefail
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 /path/to/authentic/baserom.jp.z64}"
python3 "$script_dir/verify.py" "$rom"

emulator="${MUPEN64PLUS:-/usr/games/mupen64plus}"
if [ ! -x "$emulator" ]; then
    printf '%s\n' 'mupen64plus was not found; set MUPEN64PLUS' >&2
    exit 2
fi
mkdir -p "$project_dir/build/instrumentation"
out_dir="$(mktemp -d "$project_dir/build/instrumentation/jp-ranks13-18.XXXXXX")"
mkdir -p "$out_dir/config" "$out_dir/data" "$out_dir/shots"
plugin="$out_dir/jp-ranks13-18.so"
raw_log="$out_dir/jp-ranks13-18.raw.log"
receipt="$out_dir/copy-interaction-receipt.txt"

gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
    -DALLOW_SETUP_A=0 -DSEARCH_MODE=12 \
    -DRANK1_BOUNDARY_AUDIT=1 -DRANK1_BOUNDARY_REPEAT_UNTIL=349 \
    -DRANK5_STATE_SPLIT_AUDIT=1 -DRANK13_18_COPY_AUDIT=1 \
    "$project_dir/instrumentation/jp-clean-gap-search/jp_clean_gap_search_probe.c" \
    -ldl -lm -o "$plugin"

printf 'Raw log: %s\n' "$raw_log"
printf 'run\n' |
    XDG_CONFIG_HOME="$out_dir/config" XDG_DATA_HOME="$out_dir/data" \
    LIBGL_ALWAYS_SOFTWARE=1 \
    xvfb-run -a "$emulator" --debug --emumode 0 --nosaveoptions --nospeedlimit \
        --audio dummy --input "$plugin" --gfx mupen64plus-video-rice.so \
        --rsp mupen64plus-rsp-hle.so --cheats 6 --sshotdir "$out_dir/shots" \
        --testshots 2850 "$rom" >"$raw_log" 2>&1

grep -a '^RANK13_' "$raw_log" >"$receipt"
grep -a '^RANK5_' "$raw_log" >"$out_dir/rank5-regression.txt"
diff --strip-trailing-cr -u \
    "$project_dir/instrumentation/jp-rank5-state-split/expected-state-split-receipt.txt" \
    "$out_dir/rank5-regression.txt"
if ! grep -q '^RANK13_RESULT,.*invariant=1$' "$receipt" \
    || ! grep -q '^RESULT,.*mode12PillarsComplete=1,.*warpDisappeared=1,warpUsedObj=1,platformTop=0,.*aPressedFrames=0,aDownFrames=0,controllerAFrames=0$' "$raw_log"; then
    printf 'Rank-13/18 invariant or route failed; inspect %s\n' "$receipt" >&2
    exit 3
fi
if [ -f "$script_dir/expected-copy-interaction-receipt.txt" ]; then
    diff --strip-trailing-cr -u "$script_dir/expected-copy-interaction-receipt.txt" "$receipt"
fi
python3 "$script_dir/verify_receipt.py" "$receipt" \
    "$project_dir/proofs/Area1Ranks13To18TraceReceipt.v"
printf 'Exact Rank-13/18 copy/interaction receipt passed: %s\n' "$receipt"
