#!/usr/bin/env bash
set -euo pipefail

if [[ "${WSL_DISTRO_NAME:-}" != "Ubuntu-24.04" ]]; then
    echo "run this probe explicitly in WSL Ubuntu-24.04 (WSL_DISTRO_NAME=${WSL_DISTRO_NAME:-unset})" >&2
    exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: run_pedro_probe.sh /path/to/authentic/baserom.us.z64 [output-directory]}"
output_dir="${2:-$project_dir/build/instrumentation/mupen64plus-pedro}"
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
    exit 1
fi

run_case() {
    local label="$1"
    local speed="$2"
    local case_dir="$output_dir/$label"
    mkdir -p "$case_dir/shots"
    gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
        -DPEDRO_LABEL="\"$label\"" -DPEDRO_SPEED="$speed" \
        "$script_dir/eyerok_pedro_probe.c" -ldl -lm \
        -o "$case_dir/eyerok_pedro_probe.so"
    printf 'run\n' | LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a /usr/games/mupen64plus \
        --debug --emumode 0 --nosaveoptions --nospeedlimit --audio dummy \
        --input "$case_dir/eyerok_pedro_probe.so" \
        --gfx mupen64plus-video-rice.so --rsp mupen64plus-rsp-hle.so \
        --cheats 1 --sshotdir "$case_dir/shots" --testshots 390 \
        "$rom" >"$case_dir/raw.log" 2>&1
}

mkdir -p "$output_dir"
run_case ordinary48 48
run_case tunnel424 424
python3 "$script_dir/analyze_pedro_probe.py" "$output_dir/results" \
    "$output_dir/ordinary48/raw.log" "$output_dir/tunnel424/raw.log"
