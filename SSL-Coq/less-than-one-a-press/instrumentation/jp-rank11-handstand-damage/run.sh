#!/usr/bin/env bash
set -euo pipefail
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 /path/to/authentic/baserom.jp.z64 [0=handstand|1=holding|2=return] [frames]}"
mode="${2:-0}"
frames="${3:-1000}"
case "$mode" in 0|1|2) ;; *) printf 'Expected mode 0, 1 or 2\n' >&2; exit 2 ;; esac
case "$frames" in ''|*[!0-9]*) printf 'Expected a positive frame count\n' >&2; exit 2 ;; esac
test "$frames" -gt 0
test "$(md5sum "$rom" | awk '{print $1}')" = 85d61f5525af708c9f1e84dce6dc10e9
test "$(sha256sum "$rom" | awk '{print $1}')" = 9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317
emulator="${MUPEN64PLUS:-/usr/games/mupen64plus}"
test -x "$emulator"
out_dir="$project_dir/build/instrumentation/jp-rank11-handstand-damage/mode-$mode"
mkdir -p "$out_dir/config" "$out_dir/data" "$out_dir/shots"
plugin="$out_dir/jp-rank11-handstand-damage.so"
gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
    -DENABLE_PICKUP_ROUTE=0 -DHANDSTAND_DAMAGE_MODE="$mode" \
    "$script_dir/jp_rank11_handstand_damage_probe.c" -ldl -lm -o "$plugin"
printf 'run\n' |
    XDG_CONFIG_HOME="$out_dir/config" XDG_DATA_HOME="$out_dir/data" \
    LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a "$emulator" \
        --debug --emumode 0 --nosaveoptions --nospeedlimit \
        --audio dummy --input "$plugin" --gfx mupen64plus-video-rice.so \
        --rsp mupen64plus-rsp-hle.so --cheats 6 \
        --sshotdir "$out_dir/shots" --testshots "$frames" \
        "$rom" >"$out_dir/raw.log" 2>&1
grep -E '^(H11_|R11_FIXTURE_WRITE|R11_STAGE)' "$out_dir/raw.log" >"$out_dir/trace.txt"
grep -E '^H11_(BEFORE_GOOMBA|PLACED|FIRST_KNOCKBACK|TARGET|RESULT)' "$out_dir/trace.txt"
grep -q '^H11_RESULT.*placed=1,extraWrites=3.*sawKnockback=1.*aPressedFrames=0,aDownFrames=0,controllerAFrames=0' "$out_dir/trace.txt"
python3 "$script_dir/validate.py" "$out_dir/trace.txt"
printf 'Trace: %s\n' "$out_dir/trace.txt"
