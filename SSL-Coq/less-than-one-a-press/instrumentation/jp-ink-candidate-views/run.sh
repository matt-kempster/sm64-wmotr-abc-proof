#!/usr/bin/env bash
set -euo pipefail
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
rom="$(realpath "${1:?original JP ROM}")"
out="${2:?fresh output directory}"
mode="${3:-normal}"
case "$mode" in
  normal) flags=() ;;
  cutaway) flags=(-DVIEW_CUTAWAY=1) ;;
  *) printf 'mode must be normal or cutaway\n' >&2; exit 2 ;;
esac
test "$(sha256sum "$rom" | cut -d ' ' -f 1)" = 9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317
mkdir "$out"
out="$(realpath "$out")"
mkdir "$out/config" "$out/data" "$out/shots"
gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 "${flags[@]}" "$script_dir/probe.c" -ldl -lm -o "$out/probe.so"
printf 'run\n' | XDG_CONFIG_HOME="$out/config" XDG_DATA_HOME="$out/data" LIBGL_ALWAYS_SOFTWARE=1 \
    xvfb-run -a stdbuf -oL -eL "${MUPEN64PLUS:-/usr/games/mupen64plus}" \
      --debug --emumode 0 --nosaveoptions --nospeedlimit --noosd --audio dummy \
      --input "$out/probe.so" --gfx mupen64plus-video-rice.so --rsp mupen64plus-rsp-hle.so \
      --cheats 6 --sshotdir "$out/shots" --testshots 2700 "$rom" >"$out/raw.log" 2>&1
grep -E '^CANDIDATE_(RENDER|VIEW)' "$out/raw.log" >"$out/trace.txt"
test "$(grep -c '^CANDIDATE_VIEW,index=' "$out/trace.txt")" = 6
python3 "$script_dir/check.py" "$out"
printf 'Visualization-only original-ROM capture: %s\n' "$out"
