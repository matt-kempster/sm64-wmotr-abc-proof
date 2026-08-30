#!/usr/bin/env bash
set -euo pipefail

if [[ "${WSL_DISTRO_NAME:-}" != "Ubuntu-24.04" ]]; then
    echo "run this probe explicitly in WSL Ubuntu-24.04 (WSL_DISTRO_NAME=${WSL_DISTRO_NAME:-unset})" >&2
    exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: run_contact_probe.sh /path/to/authentic/baserom.us.z64 [output-directory]}"
output_dir="${2:-$project_dir/build/instrumentation/mupen64plus-contact}"
expected_md5="20b854b239203baf6c961b850a4a51a2"
expected_sha256="17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91"

actual_md5="$(md5sum "$rom" | cut -d ' ' -f 1)"
actual_sha256="$(sha256sum "$rom" | cut -d ' ' -f 1)"
if [[ "$actual_md5" != "$expected_md5" || "$actual_sha256" != "$expected_sha256" ]]; then
    echo "refusing ROM with unexpected digest" >&2
    echo "expected MD5    $expected_md5" >&2
    echo "actual   MD5    $actual_md5" >&2
    echo "expected SHA256 $expected_sha256" >&2
    echo "actual   SHA256 $actual_sha256" >&2
    exit 1
fi

mkdir -p "$output_dir"
modes=(stationary b_only held_a held_a_b_edge)
for index in 0 1 2 3; do
    mode="${modes[$index]}"
    mode_dir="$output_dir/$mode"
    mkdir -p "$mode_dir/shots"
    gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
        -DCONTACT_MODE="$index" \
        "$script_dir/eyerok_contact_probe.c" -ldl -lm \
        -o "$mode_dir/eyerok_contact_probe.so"

    printf 'run\n' | LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a /usr/games/mupen64plus \
        --debug \
        --emumode 0 \
        --nosaveoptions \
        --nospeedlimit \
        --audio dummy \
        --input "$mode_dir/eyerok_contact_probe.so" \
        --gfx mupen64plus-video-rice.so \
        --rsp mupen64plus-rsp-hle.so \
        --cheats 1 \
        --sshotdir "$mode_dir/shots" \
        --testshots 480 \
        "$rom" >"$mode_dir/raw.log" 2>&1
done

python3 "$script_dir/analyze_contact_probe.py" \
    "$output_dir/results" \
    "$output_dir/stationary/raw.log" \
    "$output_dir/b_only/raw.log" \
    "$output_dir/held_a/raw.log" \
    "$output_dir/held_a_b_edge/raw.log"
