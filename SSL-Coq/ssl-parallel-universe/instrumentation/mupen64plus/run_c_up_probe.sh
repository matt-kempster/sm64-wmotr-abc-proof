#!/usr/bin/env bash
set -euo pipefail

if [[ "${WSL_DISTRO_NAME:-}" != "Ubuntu-24.04" ]]; then
    echo "run this probe explicitly in WSL Ubuntu-24.04" >&2
    exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: run_c_up_probe.sh /path/to/authentic/baserom.us.z64 [output-directory]}"
output_dir="${2:-$project_dir/build/instrumentation/mupen64plus-c-up}"
expected_md5="20b854b239203baf6c961b850a4a51a2"
expected_sha256="17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91"

actual_md5="$(md5sum "$rom" | cut -d ' ' -f 1)"
actual_sha256="$(sha256sum "$rom" | cut -d ' ' -f 1)"
if [[ "$actual_md5" != "$expected_md5" || "$actual_sha256" != "$expected_sha256" ]]; then
    echo "refusing ROM with unexpected digest" >&2
    exit 1
fi

mkdir -p "$output_dir"

run_probe() {
    local name="$1" x="$2" y="$3" z="$4" yaw="$5"
    local probe_dir="$output_dir/$name"
    mkdir -p "$probe_dir/shots"
    gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
        -DPROBE_NAME="\"$name\"" \
        -DSTART_X="$x" -DSTART_Y="$y" -DSTART_Z="$z" -DSTART_YAW="$yaw" \
        "$script_dir/c_up_probe.c" -ldl -lm -o "$probe_dir/c_up_probe.so"
    printf 'run\n' | LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a /usr/games/mupen64plus \
        --debug --emumode 0 --nosaveoptions --nospeedlimit --audio dummy \
        --input "$probe_dir/c_up_probe.so" \
        --gfx mupen64plus-video-rice.so --rsp mupen64plus-rsp-hle.so \
        --cheats 1 --sshotdir "$probe_dir/shots" --testshots 760 \
        "$rom" >"$probe_dir/raw.log" 2>&1
    grep '^CUP' "$probe_dir/raw.log" >"$probe_dir/trace.txt"
}

# The heights are exact midline values from the Area 2 collision vertices.
run_probe broad_ramp_west 500.0f 1408.0f 2867.0f 0x3fff
run_probe broad_ramp_east -500.0f 1408.0f 2867.0f -0x3fff
run_probe west_bevel_long -3091.5f 92.5f 2800.0f 1
run_probe east_bevel_long 3092.5f 92.5f 2600.0f -1
run_probe top_bevel_west 500.0f 4907.0f -429.5f 0x3fff
run_probe top_bevel_north 622.5f 4907.0f -980.0f 0x7fff

grep -h '^CUP_SUMMARY' "$output_dir"/*/trace.txt | sort >"$output_dir/summary.txt"
cat "$output_dir/summary.txt"
