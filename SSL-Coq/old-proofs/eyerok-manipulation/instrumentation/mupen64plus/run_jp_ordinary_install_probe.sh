#!/usr/bin/env bash
set -euo pipefail

if [[ "${WSL_DISTRO_NAME:-}" != "Ubuntu-24.04" ]]; then
    echo "run this probe explicitly in WSL Ubuntu-24.04" >&2
    exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: run_jp_ordinary_install_probe.sh /path/to/baserom.jp.z64 [output-directory]}"
output_dir="${2:-$project_dir/build/instrumentation/mupen64plus-jp-ordinary-install}"
expected_md5="85d61f5525af708c9f1e84dce6dc10e9"
expected_sha256="9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317"
expected_header_crc="4eaa3d0e74757c24"

actual_md5="$(md5sum "$rom" | cut -d ' ' -f 1)"
actual_sha256="$(sha256sum "$rom" | cut -d ' ' -f 1)"
actual_header_crc="$(od -An -tx1 -N8 -j16 "$rom" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')"
if [[ "$actual_md5" != "$expected_md5" \
   || "$actual_sha256" != "$expected_sha256" \
   || "$actual_header_crc" != "$expected_header_crc" ]]; then
    echo "refusing ROM with unexpected original-JP digest" >&2
    exit 1
fi

run_case() {
    local label="$1"
    local install_case="$2"
    local side="$3"
    local case_dir="$output_dir/$label"
    mkdir -p "$case_dir/shots"
    gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
        -DINSTALL_CASE="$install_case" -DHAND_SIDE="$side" \
        "$script_dir/eyerok_jp_ordinary_install_probe.c" -ldl \
        -o "$case_dir/eyerok_jp_ordinary_install_probe.so"
    printf 'run\n' | \
        LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a /usr/games/mupen64plus \
        --debug --emumode 0 --nosaveoptions --nospeedlimit --audio dummy \
        --input "$case_dir/eyerok_jp_ordinary_install_probe.so" \
        --gfx mupen64plus-video-rice.so --rsp mupen64plus-rsp-hle.so \
        --cheats 6 --sshotdir "$case_dir/shots" --testshots 760 \
        "$rom" >"$case_dir/raw.log" 2>&1
}

mkdir -p "$output_dir"
run_case right_fist_push 1 1
run_case left_fist_push 1 -1
run_case right_one_hand_show_eye 2 1
run_case left_one_hand_show_eye 2 -1

python3 "$script_dir/analyze_jp_ordinary_install_probe.py" \
    "$output_dir/results.txt" \
    "$output_dir/right_fist_push/raw.log" \
    "$output_dir/left_fist_push/raw.log" \
    "$output_dir/right_one_hand_show_eye/raw.log" \
    "$output_dir/left_one_hand_show_eye/raw.log"
