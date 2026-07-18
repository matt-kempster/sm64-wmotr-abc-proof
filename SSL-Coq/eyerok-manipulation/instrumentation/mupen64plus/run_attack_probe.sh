#!/usr/bin/env bash
set -euo pipefail

if [[ "${WSL_DISTRO_NAME:-}" != "Ubuntu-24.04" ]]; then
    echo "run this probe explicitly in WSL Ubuntu-24.04 (WSL_DISTRO_NAME=${WSL_DISTRO_NAME:-unset})" >&2
    exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: run_attack_probe.sh /path/to/authentic/baserom.us.z64 [output-directory]}"
output_dir="${2:-$project_dir/build/instrumentation/mupen64plus-attack}"
expected_md5="20b854b239203baf6c961b850a4a51a2"
expected_sha256="17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91"
expected_header_crc="635a2bff8b022326"

actual_md5="$(md5sum "$rom" | cut -d ' ' -f 1)"
actual_sha256="$(sha256sum "$rom" | cut -d ' ' -f 1)"
actual_header_crc="$(od -An -tx1 -N8 -j16 "$rom" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')"
if [[ "$actual_md5" != "$expected_md5" \
   || "$actual_sha256" != "$expected_sha256" \
   || "$actual_header_crc" != "$expected_header_crc" ]]; then
    echo "refusing ROM with unexpected digest" >&2
    echo "expected MD5    $expected_md5" >&2
    echo "actual   MD5    $actual_md5" >&2
    echo "expected SHA256 $expected_sha256" >&2
    echo "actual   SHA256 $actual_sha256" >&2
    echo "expected CRC    635A2BFF 8B022326" >&2
    echo "actual   CRC    ${actual_header_crc:0:8} ${actual_header_crc:8:8}" >&2
    exit 1
fi

mkdir -p "$output_dir"

run_case() {
    local relative_dir="$1"
    local index="$2"
    local steer_label="$3"
    local steer_x="$4"
    local steer_y="$5"
    local frames="$6"
    local switch_relative_poll="${7:-0}"
    local steer_after_x="${8:-$steer_x}"
    local steer_after_y="${9:-$steer_y}"
    local scenario_dir="$output_dir/$relative_dir"

    mkdir -p "$scenario_dir/shots"
    gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
        -DATTACK_SCENARIO="$index" \
        -DSTEER_LABEL="\"$steer_label\"" \
        -DSTEER_X="$steer_x" \
        -DSTEER_Y="$steer_y" \
        -DSTEER_SWITCH_RELATIVE_POLL="$switch_relative_poll" \
        -DSTEER_AFTER_X="$steer_after_x" \
        -DSTEER_AFTER_Y="$steer_after_y" \
        "$script_dir/eyerok_attack_probe.c" -ldl -lm \
        -o "$scenario_dir/eyerok_attack_probe.so"

    printf 'run\n' | LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a /usr/games/mupen64plus \
        --debug \
        --emumode 0 \
        --nosaveoptions \
        --nospeedlimit \
        --audio dummy \
        --input "$scenario_dir/eyerok_attack_probe.so" \
        --gfx mupen64plus-video-rice.so \
        --rsp mupen64plus-rsp-hle.so \
        --cheats 1 \
        --sshotdir "$scenario_dir/shots" \
        --testshots "$frames" \
        "$rom" >"$scenario_dir/raw.log" 2>&1
}

scenarios=(
    nonlethal_long_jump5
    lethal_long_jump5
    nonlethal_slide_kick5
    lethal_slide_kick5
)
for index in 0 1 2 3; do
    run_case "${scenarios[$index]}" "$index" none 0 0 560
done

# Solve X/Z without claiming a landing: inward Y through relative poll 31,
# then reverse from poll 32.  This keeps the hand selected as floor through
# DIE timer 39 so the analyzer can isolate deletion as the vertical blocker.
run_case "lethal_steering_sweep/brake32" 1 brake32 0 127 530 32 0 -127

# The eight full-stick cardinal/diagonal cases are deliberately bounded. They
# begin only after the first open-wall step; no case supplies A or B.
sweep_specs=(
    x_plus:127:0
    x_minus:-127:0
    y_plus:0:127
    y_minus:0:-127
    xy_plus_plus:90:90
    xy_plus_minus:90:-90
    xy_minus_plus:-90:90
    xy_minus_minus:-90:-90
)
for spec in "${sweep_specs[@]}"; do
    IFS=: read -r label steer_x steer_y <<< "$spec"
    run_case "lethal_steering_sweep/$label" 1 "$label" "$steer_x" "$steer_y" 530
done

python3 "$script_dir/analyze_attack_probe.py" \
    "$output_dir/results" \
    "$output_dir/nonlethal_long_jump5/raw.log" \
    "$output_dir/lethal_long_jump5/raw.log" \
    "$output_dir/nonlethal_slide_kick5/raw.log" \
    "$output_dir/lethal_slide_kick5/raw.log" \
    "$output_dir/lethal_steering_sweep/x_plus/raw.log" \
    "$output_dir/lethal_steering_sweep/x_minus/raw.log" \
    "$output_dir/lethal_steering_sweep/y_plus/raw.log" \
    "$output_dir/lethal_steering_sweep/y_minus/raw.log" \
    "$output_dir/lethal_steering_sweep/xy_plus_plus/raw.log" \
    "$output_dir/lethal_steering_sweep/xy_plus_minus/raw.log" \
    "$output_dir/lethal_steering_sweep/xy_minus_plus/raw.log" \
    "$output_dir/lethal_steering_sweep/xy_minus_minus/raw.log" \
    "$output_dir/lethal_steering_sweep/brake32/raw.log"
