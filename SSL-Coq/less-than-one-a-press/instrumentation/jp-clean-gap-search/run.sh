#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 /path/to/authentic/baserom.jp.z64 [test-frames] [allow-setup-a] [search-mode]}"
test_frames="${2:-2400}"
allow_setup_a="${3:-0}"
search_mode="${4:-0}"

expected_md5="85d61f5525af708c9f1e84dce6dc10e9"
expected_sha256="9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317"
actual_md5="$(md5sum "$rom" | awk '{print $1}')"
actual_sha256="$(sha256sum "$rom" | awk '{print $1}')"
if [ "$actual_md5" != "$expected_md5" ] \
    || [ "$actual_sha256" != "$expected_sha256" ]; then
    printf '%s\n' "refusing non-authentic or non-JP ROM" >&2
    exit 2
fi

if [ -n "${MUPEN64PLUS:-}" ]; then
    emulator="$MUPEN64PLUS"
elif command -v mupen64plus >/dev/null 2>&1; then
    emulator="$(command -v mupen64plus)"
elif [ -x /usr/games/mupen64plus ]; then
    emulator=/usr/games/mupen64plus
else
    printf '%s\n' "mupen64plus was not found" >&2
    exit 2
fi

out_dir="$project_dir/build/instrumentation/jp-clean-gap-search/mode-${search_mode}-a${allow_setup_a}"
mkdir -p "$out_dir/config" "$out_dir/data" "$out_dir/shots"
plugin="$out_dir/jp-clean-gap-search.so"
raw_log="$out_dir/jp-clean-gap-search.raw.log"
trace="$out_dir/jp-clean-gap-search.trace.txt"

gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
    -DALLOW_SETUP_A="$allow_setup_a" \
    -DSEARCH_MODE="$search_mode" \
    "$script_dir/jp_clean_gap_search_probe.c" -ldl -lm -o "$plugin"

printf 'run\n' |
    XDG_CONFIG_HOME="$out_dir/config" \
    XDG_DATA_HOME="$out_dir/data" \
    LIBGL_ALWAYS_SOFTWARE=1 \
    xvfb-run -a "$emulator" \
        --debug --emumode 0 --nosaveoptions --nospeedlimit \
        --audio dummy --input "$plugin" \
        --gfx mupen64plus-video-rice.so \
        --rsp mupen64plus-rsp-hle.so \
        --cheats 6 --sshotdir "$out_dir/shots" --testshots "$test_frames" \
        "$rom" >"$raw_log" 2>&1

grep -E '^(SEARCH|ACTION|MAX_GAP|MIN_GAP|GAP45|GAP960|FIRE_LINK|TOP|FRAME|NONFINITE|B_INPUT|RESULT)' \
    "$raw_log" >"$trace"
grep '^RESULT' "$trace"
if [ "$allow_setup_a" = 0 ]; then
    if ! grep -q '^RESULT,.*aPressedFrames=0,aDownFrames=0,controllerAFrames=0$' \
        "$trace"; then
        printf '%s\n' "zero-A run observed an A input or A-derived input bit" >&2
        exit 3
    fi
fi
if grep -Eq 'DebugMemWrite|W32' "$script_dir/jp_clean_gap_search_probe.c"; then
    printf '%s\n' "probe source contains a game-memory write API" >&2
    exit 3
fi
if grep -q '^GAP960' "$trace"; then
    printf '%s\n' "A >=960 clean controller-only gap was observed."
else
    printf '%s\n' "No >=960 gap was observed in this bounded schedule."
fi
printf 'Trace: %s\n' "$trace"
