#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$(realpath "$0")")"
rom="$(realpath "${1:?original JP cartridge image}")"
recipe="$(realpath "${2:?Wafel case JSON}")"
out="${3:?fresh directory for emulator output}"
test "$(sha256sum "$rom" | cut -d ' ' -f 1)" = 9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317
mkdir "$out"
out="$(realpath "$out")"
mkdir "$out/config" "$out/data" "$out/shots"
python3 "$here/probe.py" "$recipe" "$out/probe.c"
gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 -I"$here" "$out/probe.c" -ldl -lm -o "$out/probe.so"
# Same interpreter, prefix, graphics backend and stop point as the parent replay.
printf 'run\n' | XDG_CONFIG_HOME="$out/config" XDG_DATA_HOME="$out/data" LIBGL_ALWAYS_SOFTWARE=1 \
  xvfb-run -a stdbuf -oL -eL /usr/games/mupen64plus \
  --debug --emumode 0 --nosaveoptions --nospeedlimit --noosd --audio dummy \
  --input "$out/probe.so" --gfx mupen64plus-video-rice.so --rsp mupen64plus-rsp-hle.so \
  --cheats 6 --sshotdir "$out/shots" --testshots 2820 "$rom" >"$out/raw.log" 2>&1
python3 "$here/check.py" "$recipe" "$out/raw.log"
