#!/usr/bin/env bash
set -euo pipefail
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
rom="$(realpath "${1:?original JP ROM}")"
out="${2:?fresh output directory}"
case_name="${3:?timely or late}"
test "$case_name" = timely || test "$case_name" = late
test "$(sha256sum "$rom" | cut -d ' ' -f 1)" = 9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317
test "$(md5sum "$rom" | cut -d ' ' -f 1)" = 85d61f5525af708c9f1e84dce6dc10e9
export WAFEL_PILOT_INPUTS="$script_dir/$case_name/controller.inputs"
grant="$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["grantPoll"])' "$script_dir/$case_name/setup.json")"
shots="$(( $(wc -l < "$WAFEL_PILOT_INPUTS") - 2 ))"
mkdir "$out"
out="$(realpath "$out")"
mkdir "$out/config" "$out/data" "$out/shots"
gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 -DALLOW_SETUP_A=0 -DSEARCH_MODE=12 -DRANK1_BOUNDARY_AUDIT=1 -DRANK1_BOUNDARY_REPEAT_UNTIL=349 -DRANK5_STATE_SPLIT_AUDIT=1 -DRANK13_18_COPY_AUDIT=1 -DDELIVERY_GRANT_POLL="$grant" "$script_dir/probe.c" -ldl -lm -o "$out/probe.so"
printf 'run\n' | XDG_CONFIG_HOME="$out/config" XDG_DATA_HOME="$out/data" LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a /usr/games/mupen64plus --debug --emumode 0 --nosaveoptions --nospeedlimit --noosd --audio dummy --input "$out/probe.so" --gfx mupen64plus-video-rice.so --rsp mupen64plus-rsp-hle.so --cheats 6 --sshotdir "$out/shots" --testshots "$shots" "$rom" >"$out/raw.log" 2>&1
python3 "$script_dir/check.py" "$out" "$case_name"
