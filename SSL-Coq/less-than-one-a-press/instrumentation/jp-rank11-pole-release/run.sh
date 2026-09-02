#!/usr/bin/env bash
set -euo pipefail
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 /path/to/authentic/baserom.jp.z64 [0=timed|1=holding] [frames]}"
mode="${2:-0}"
frames="${3:-1000}"
case "$mode" in 0|1) ;; *) printf 'Expected release mode 0 or 1\n' >&2; exit 2 ;; esac
expected_md5=85d61f5525af708c9f1e84dce6dc10e9
expected_sha256=9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317
test "$(md5sum "$rom" | awk '{print $1}')" = "$expected_md5"
test "$(sha256sum "$rom" | awk '{print $1}')" = "$expected_sha256"
emulator="${MUPEN64PLUS:-/usr/games/mupen64plus}"
test -x "$emulator"
out_dir="$project_dir/build/instrumentation/jp-rank11-pole-release/mode-$mode"
mkdir -p "$out_dir/config" "$out_dir/data" "$out_dir/shots"
plugin="$out_dir/jp-rank11-pole-release.so"
gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
    -DENABLE_PICKUP_ROUTE=0 -DRANK11_RELEASE_MODE="$mode" \
    "$script_dir/jp_rank11_pole_release_probe.c" -ldl -lm -o "$plugin"
printf 'run\n' |
    XDG_CONFIG_HOME="$out_dir/config" XDG_DATA_HOME="$out_dir/data" \
    LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a "$emulator" \
        --debug --emumode 0 --nosaveoptions --nospeedlimit \
        --audio dummy --input "$plugin" --gfx mupen64plus-video-rice.so \
        --rsp mupen64plus-rsp-hle.so --cheats 6 \
        --sshotdir "$out_dir/shots" --testshots "$frames" \
        "$rom" >"$out_dir/raw.log" 2>&1
grep '^R11_' "$out_dir/raw.log" >"$out_dir/trace.txt"
grep '^R11_\(STAGE\|Z_REQUEST\|FIRST_BONK\|RESULT\)' "$out_dir/trace.txt"
grep -q '^R11_RESULT.*staged=1.*releaseSent=1,sawBonk=1.*aPressedFrames=0,aDownFrames=0,controllerAFrames=0' "$out_dir/trace.txt"
printf 'Trace: %s\n' "$out_dir/trace.txt"
