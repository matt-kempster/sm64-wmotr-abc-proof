#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 /path/to/authentic/baserom.jp.z64}"
third_x="${2:-260.0f}"
third_z="${3:--600.0f}"
brake_frames="${4:-20}"
tag="${5:-x${third_x}-z${third_z}-b${brake_frames}}"
test_frames="${6:-2400}"
enable_route_dive="${7:-0}"
enable_ramp_return="${8:-0}"
enable_pickup_route="${9:-0}"
pickup_aim_x="${10:-900.0f}"

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

out_dir="$project_dir/build/instrumentation/jp-full-route/$tag"
mkdir -p "$out_dir/config" "$out_dir/data" "$out_dir/shots"
plugin="$out_dir/jp-full-route.so"
raw_log="$out_dir/jp-full-route.raw.log"
trace="$out_dir/jp-full-route.trace.txt"

gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
    -DTHIRD_AIM_X="$third_x" -DTHIRD_AIM_Z="$third_z" \
    -DTHIRD_BRAKE_FRAMES="$brake_frames" \
    -DENABLE_ROUTE_DIVE="$enable_route_dive" \
    -DENABLE_RAMP_RETURN="$enable_ramp_return" \
    -DENABLE_PICKUP_ROUTE="$enable_pickup_route" \
    -DPICKUP_AIM_X="$pickup_aim_x" \
    "$script_dir/jp_full_route_probe.c" -ldl -lm -o "$plugin"

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

grep -E '^(INSTALL|RETRY|EXPLOSION_FREE|FIRST_APPLY|FIRST_AREA2_POLL|ROUTE_SAVE|ROUTE_COUNTER|ROUTE_ACT6_STAR|ROUTE_RAMP_RETURN|ROUTE_PICKUP_INPUT|ROUTE_PICKUP_HITBOX|ROUTE_PICKUP_RESULT|ROUTE_SPEED_KICK|ROUTE_ROLLOUT|ROUTE_DIVE|ROUTE_TRACE|ROUTE_RESULT|RESULT)' \
    "$raw_log" >"$trace"
grep '^ROUTE_COUNTER' "$trace" || true
grep '^RESULT' "$trace"
printf 'Trace: %s\n' "$trace"
