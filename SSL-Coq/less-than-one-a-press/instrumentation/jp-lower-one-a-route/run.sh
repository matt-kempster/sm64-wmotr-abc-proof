#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 /path/to/authentic/baserom.jp.z64 [frames]}"
test_frames="${2:-2200}"

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

out_dir="$project_dir/build/instrumentation/jp-lower-one-a-route"
mkdir -p "$out_dir/config" "$out_dir/data" "$out_dir/shots"
plugin="$out_dir/jp-lower-one-a-route.so"
raw_log="$out_dir/jp-lower-one-a-route.raw.log"
trace="$out_dir/jp-lower-one-a-route.trace.txt"
inputs="$out_dir/controller-input-changes.csv"

gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
    -DENABLE_PICKUP_ROUTE=0 \
    "$script_dir/jp_lower_one_a_route_probe.c" -ldl -lm -o "$plugin"

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

grep -E '^(LOWER_|ROUTE_COUNTER|ROUTE_ACT6_STAR|ROUTE_SAVE|ROUTE_RESULT|RESULT)' \
    "$raw_log" >"$trace"
printf '%s\n' 'timer,area2_poll,A,B,Z,stick_x,stick_y,action,x,y,z' >"$inputs"
grep '^LOWER_INPUT,' "$raw_log" | sed 's/^LOWER_INPUT,//' >>"$inputs"

grep '^LOWER_ONE_A_STAGE' "$trace"
grep '^LOWER_POLE_JUMP' "$trace"
grep '^LOWER_GRINDEL_BASE' "$trace"
grep '^LOWER_ONE_A_RESULT.*aPressedFrames=1,aDownFrames=34,controllerAFrames=34' \
    "$trace"
printf 'Input changes: %s\n' "$inputs"
printf 'Trace: %s\n' "$trace"
