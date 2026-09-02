#!/usr/bin/env bash
set -euo pipefail

if [[ "${WSL_DISTRO_NAME:-}" != "Ubuntu-24.04" ]]; then
    echo "run explicitly in WSL Ubuntu-24.04" >&2
    exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: run.sh /path/to/authentic/baserom.us.z64 [output-directory]}"
output_dir="${2:-$project_dir/build/instrumentation/eyerok-controller-gates}"
selection_x="${3:-0.0f}"
kite_x="${4:-0.0f}"
kite_z="${5:--1800.0f}"
smash_side_sign="${6:-1}"
smash_angle_mag="${7:-16384}"
smash_target_radius="${8:-180.0f}"
expected_md5="20b854b239203baf6c961b850a4a51a2"
expected_sha256="17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91"

actual_md5="$(md5sum "$rom" | cut -d ' ' -f 1)"
actual_sha256="$(sha256sum "$rom" | cut -d ' ' -f 1)"
if [[ "$actual_md5" != "$expected_md5" || "$actual_sha256" != "$expected_sha256" ]]; then
    echo "refusing ROM with unexpected digest" >&2
    exit 1
fi

mkdir -p "$output_dir/shots"
gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
    -DSELECTION_X="$selection_x" \
    -DKITE_X="$kite_x" \
    -DKITE_Z="$kite_z" \
    -DSMASH_SIDE_SIGN="$smash_side_sign" \
    -DSMASH_ANGLE_MAG="$smash_angle_mag" \
    -DSMASH_TARGET_RADIUS="$smash_target_radius" \
    "$script_dir/eyerok_controller_gate_probe.c" -ldl -lm \
    -o "$output_dir/eyerok_controller_gate_probe.so"

printf 'run\n' | LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a /usr/games/mupen64plus \
    --debug \
    --emumode 0 \
    --nosaveoptions \
    --nospeedlimit \
    --audio dummy \
    --input "$output_dir/eyerok_controller_gate_probe.so" \
    --gfx mupen64plus-video-rice.so \
    --rsp mupen64plus-rsp-hle.so \
    --cheats "1,5-0" \
    --sshotdir "$output_dir/shots" \
    --testshots "1300" \
    "$rom" >"$output_dir/raw.log" 2>&1

grep -E '^(FIXTURE|GATE_BOUNDARY|GATE_PHASE|GATE_VERDICT|VERDICT)' \
    "$output_dir/raw.log" >"$output_dir/summary.txt"
cat "$output_dir/summary.txt"
