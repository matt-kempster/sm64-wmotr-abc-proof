#!/usr/bin/env bash
set -euo pipefail
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
rom="$(realpath "${1:?original JP ROM}")"
out="${2:?fresh output directory}"
test "$(sha256sum "$rom" | cut -d ' ' -f 1)" = 9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317
test "$(md5sum "$rom" | cut -d ' ' -f 1)" = 85d61f5525af708c9f1e84dce6dc10e9
mkdir "$out"
out="$(realpath "$out")"
mkdir "$out/config" "$out/data" "$out/shots"
gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 -DDEMO_HANDOFF=1 "$script_dir/probe.c" -ldl -lm -o "$out/probe.so"
printf 'run\n' | XDG_CONFIG_HOME="$out/config" XDG_DATA_HOME="$out/data" LIBGL_ALWAYS_SOFTWARE=1 \
    xvfb-run -a stdbuf -oL -eL "${MUPEN64PLUS:-/usr/games/mupen64plus}" \
      --debug --emumode 0 --nosaveoptions --nospeedlimit --noosd --audio dummy \
      --input "$out/probe.so" --gfx mupen64plus-video-rice.so --rsp mupen64plus-rsp-hle.so \
      --cheats 6 --sshotdir "$out/shots" --testshots 2820 "$rom" >"$out/raw.log" 2>&1
grep '^HANDS_' "$out/raw.log" >"$out/trace.txt"
test "$(grep -c '^HANDS_WRITE,' "$out/trace.txt")" = 13
! grep -q '^HANDS_ERROR' "$out/trace.txt"
python3 "$script_dir/check-handoff.py" "$out"
printf 'Original JP separately supplied 973-unit handoff: %s\n' "$out"
