#!/usr/bin/env bash
set -euo pipefail
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 /path/to/baserom.jp.z64 [actual_Y]}"
actual_y="${2:-768}"
case "$actual_y" in 768|1861) ;; *) printf '%s\n' 'Only the two named checkpoint controls' >&2; exit 2;; esac
test "$(sha256sum "$rom" | cut -d ' ' -f 1)" = 9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317
python3 "$project_dir/instrumentation/jp-ranks13-18/verify.py" "$rom"
mkdir -p "$project_dir/build/concrete-ink-backward"
out="$(mktemp -d "$project_dir/build/concrete-ink-backward/emulator-y$actual_y.XXXXXX")"
mkdir -p "$out/config" "$out/data" "$out/shots"
gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 -DINK_ACTUAL_Y="$actual_y.0f" \
    "$script_dir/probe.c" -ldl -lm -o "$out/probe.so"
printf 'Output: %s\n' "$out"
printf 'bp add 0x802c83f0 0 8\nrun\n' | \
    XDG_CONFIG_HOME="$out/config" XDG_DATA_HOME="$out/data" LIBGL_ALWAYS_SOFTWARE=1 \
    timeout 90 xvfb-run -a "${MUPEN64PLUS:-/usr/games/mupen64plus}" \
        --debug --emumode 0 --nosaveoptions --nospeedlimit \
        --audio dummy --input "$out/probe.so" --gfx mupen64plus-video-rice.so \
        --rsp mupen64plus-rsp-hle.so --cheats 6 --sshotdir "$out/shots" \
        --testshots 540 "$rom" >"$out/raw.log" 2>&1
grep -aoE '(BACKWARD_INK[A-Z_]*|FIRST_APPLY_ENTRY|FIRST_APPLY_RETURN|FIRST_AREA2_POLL),.*' \
    "$out/raw.log" >"$out/receipt.txt"
python3 "$script_dir/check_receipt.py" "$out/receipt.txt" --actual-y "$actual_y" --output "$out/report.json"
