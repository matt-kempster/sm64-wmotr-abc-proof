#!/usr/bin/env bash
set -euo pipefail
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
rom="$(realpath "${1:?original JP ROM}")"
out="${2:?fresh output directory}"
mode="${3:?1 complete combination, 2 omit Buddy}"
start_y="${4:-21700.0}"
start_x="${5:--1920.0}"
start_z="${6:--1210.0}"
test "$mode" -ge 1 && test "$mode" -le 2
[[ "$start_y" =~ ^[0-9]+[.][0-9]+$ ]]
[[ "$start_x" =~ ^-?[0-9]+[.][0-9]+$ ]]
[[ "$start_z" =~ ^-?[0-9]+[.][0-9]+$ ]]
test "$(sha256sum "$rom" | cut -d ' ' -f 1)" = 9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317
test "$(md5sum "$rom" | cut -d ' ' -f 1)" = 85d61f5525af708c9f1e84dce6dc10e9
mkdir "$out"
out="$(realpath "$out")"
mkdir "$out/config" "$out/data" "$out/shots"
cp "$script_dir/probe.c" "$out/probe-source.c"
cp "$script_dir/../jp-clean-gap-search/jp_clean_gap_search_probe.c" "$out/prefix-source.c"
cp "$script_dir/run.sh" "$out/run-source.sh"
gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 -DDEMO_MODE="$mode" -DSTART_Y="${start_y}f" -DSTART_X="${start_x}f" -DSTART_Z="${start_z}f" "$script_dir/probe.c" -ldl -lm -o "$out/probe.so"
printf 'run\n' | XDG_CONFIG_HOME="$out/config" XDG_DATA_HOME="$out/data" LIBGL_ALWAYS_SOFTWARE=1 \
 xvfb-run -a stdbuf -oL -eL /usr/games/mupen64plus \
 --debug --emumode 0 --nosaveoptions --nospeedlimit --noosd --audio dummy \
 --input "$out/probe.so" --gfx mupen64plus-video-rice.so --rsp mupen64plus-rsp-hle.so \
 --cheats 6 --sshotdir "$out/shots" --testshots 2820 "$rom" >"$out/raw.log" 2>&1
grep -E '^(ENTRY_|RESULT,)' "$out/raw.log" >"$out/trace.txt"
! grep -q '^ENTRY_ERROR' "$out/trace.txt"
python3 "$script_dir/check.py" "$out" "$mode" "$start_y" "$start_x" "$start_z"
