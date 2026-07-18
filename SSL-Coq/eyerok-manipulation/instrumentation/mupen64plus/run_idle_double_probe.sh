#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: run_idle_double_probe.sh /path/to/authentic/baserom.us.z64 [output-directory]}"
output_dir="${2:-$project_dir/build/instrumentation/mupen64plus-idle-double}"
expected_md5="20b854b239203baf6c961b850a4a51a2"

actual_md5="$(md5sum "$rom" | cut -d ' ' -f 1)"
if [[ "$actual_md5" != "$expected_md5" ]]; then
    echo "refusing non-authentic US ROM: expected MD5 $expected_md5, got $actual_md5" >&2
    exit 1
fi

mkdir -p "$output_dir/shots"
gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
    "$script_dir/eyerok_idle_double_probe.c" -ldl -lm \
    -o "$output_dir/eyerok_idle_double_probe.so"

printf 'run\n' | LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a /usr/games/mupen64plus \
    --debug \
    --nosaveoptions \
    --nospeedlimit \
    --audio dummy \
    --input "$output_dir/eyerok_idle_double_probe.so" \
    --gfx mupen64plus-video-rice.so \
    --rsp mupen64plus-rsp-hle.so \
    --cheats "1,5-0" \
    --sshotdir "$output_dir/shots" \
    --testshots "450,600" \
    "$rom" >"$output_dir/raw.log" 2>&1

python3 "$script_dir/analyze_idle_double_probe.py" \
    "$output_dir/raw.log" "$output_dir"
