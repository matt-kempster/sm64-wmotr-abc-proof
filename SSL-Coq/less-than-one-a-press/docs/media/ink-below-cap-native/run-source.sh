#!/usr/bin/env bash
set -euo pipefail
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
rom="$(realpath "${1:?original JP ROM}")"
out="${2:?fresh output directory}"
view="${3:-stock}"
test "$view" = stock || test "$view" = side || test "$view" = display
test "$(sha256sum "$rom" | cut -d ' ' -f 1)" = 9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317
test "$(md5sum "$rom" | cut -d ' ' -f 1)" = 85d61f5525af708c9f1e84dce6dc10e9
mkdir "$out"
out="$(realpath "$out")"
mkdir "$out/config" "$out/data" "$out/shots"
cp "$script_dir/probe.c" "$out/probe-source.c"
cp "$script_dir/../jp-clean-gap-search/jp_clean_gap_search_probe.c" "$out/prefix-source.c"
cp "$script_dir/run.sh" "$out/run-source.sh"
camera=0
display=0
if test "$view" != stock; then camera=1; fi
if test "$view" = display; then display=1; fi
gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 -DDEMO_SIDE="$camera" -DDEMO_DISPLAY="$display" "$script_dir/probe.c" -ldl -lm -o "$out/probe.so"
cmp "$script_dir/probe.c" "$out/probe-source.c"
cmp "$script_dir/../jp-clean-gap-search/jp_clean_gap_search_probe.c" "$out/prefix-source.c"
printf 'run\n' | XDG_CONFIG_HOME="$out/config" XDG_DATA_HOME="$out/data" LIBGL_ALWAYS_SOFTWARE=1 \
    xvfb-run -a stdbuf -oL -eL "${MUPEN64PLUS:-/usr/games/mupen64plus}" \
      --debug --emumode 0 --nosaveoptions --nospeedlimit --noosd --audio dummy \
      --input "$out/probe.so" --gfx mupen64plus-video-rice.so --rsp mupen64plus-rsp-hle.so \
      --cheats 6 --sshotdir "$out/shots" --testshots 2820 "$rom" >"$out/raw.log" 2>&1
grep '^HANDS_' "$out/raw.log" >"$out/trace.txt"
! grep -q '^HANDS_ERROR' "$out/trace.txt"
python3 "$script_dir/check.py" "$out" "$view"
