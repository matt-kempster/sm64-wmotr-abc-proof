#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 /path/to/authentic/baserom.jp.z64}"

expected_md5="85d61f5525af708c9f1e84dce6dc10e9"
expected_sha256="9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317"
actual_md5="$(md5sum "$rom" | awk '{print $1}')"
actual_sha256="$(sha256sum "$rom" | awk '{print $1}')"

if [ "$actual_md5" != "$expected_md5" ] \
    || [ "$actual_sha256" != "$expected_sha256" ]; then
  printf '%s\n' "refusing non-authentic or non-JP ROM" >&2
  exit 2
fi

if [ -n "${MUPEN64PLUS:-}" ]; then
  emulator="$MUPEN64PLUS"
elif command -v mupen64plus >/dev/null 2>&1; then
  emulator="$(command -v mupen64plus)"
elif [ -x /usr/games/mupen64plus ]; then
  emulator=/usr/games/mupen64plus
else
  printf '%s\n' "mupen64plus was not found" >&2
  exit 2
fi

out_dir="$project_dir/build/instrumentation/timer131-state-first/lifecycle"
mkdir -p "$out_dir/config" "$out_dir/data" "$out_dir/shots"
plugin="$out_dir/timer131-state-first-lifecycle.so"
raw_log="$out_dir/timer131-state-first-lifecycle.raw.log"
full_trace="$out_dir/timer131-state-first-lifecycle.full-trace.txt"
trace="$out_dir/timer131-state-first-lifecycle.trace.txt"

gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
    -DROUTE_STICK_X=-127 \
    -DROUTE_STICK_Y=-96 \
    -DINSTALL_TIMER=131 \
    -DROUTE_HOLD_FRAMES=60 \
    -DBOUNDARY_POST_OWNER=0 \
    -DSTATE_X=-1862 \
    -DSTATE_Y=67314 \
    -DSTATE_Z=-902 \
    -DGRAPHICS_X=-1641 \
    -DGRAPHICS_Y=1456 \
    -DGRAPHICS_Z=-783 \
    "$script_dir/../jp-lifecycle/jp_lifecycle_probe.c" \
    -ldl -lm -o "$plugin"

printf 'bp add 0x802c83f0 0 8\nrun\n' |
    XDG_CONFIG_HOME="$out_dir/config" \
    XDG_DATA_HOME="$out_dir/data" \
    LIBGL_ALWAYS_SOFTWARE=1 \
    xvfb-run -a "$emulator" \
        --debug --emumode 0 --nosaveoptions --nospeedlimit \
        --audio dummy --input "$plugin" \
        --gfx mupen64plus-video-rice.so \
        --rsp mupen64plus-rsp-hle.so \
        --cheats 6 --sshotdir "$out_dir/shots" --testshots 880 \
        "$rom" >"$raw_log" 2>&1

# The core and plugin can write one descriptor concurrently.  Normalize from
# the first known record tag, then retain only the lifecycle boundaries that
# the checked fixture claims.
grep -oE '(PROBE|ARM|INSTALL|TRACE_A1|TRACE_A2|EXPLOSION_FREE|BREAKPOINT[^,]*|FIRST_APPLY[^,]*|AREA2_OBJECTS|FIRST_AREA2_POLL|RESULT),.*' \
    "$raw_log" >"$full_trace"
if grep -qE '^(BREAKPOINT_ERROR|BREAKPOINT_UNEXPECTED),' "$full_trace"; then
  printf '%s\n' "unexpected first-apply breakpoint event" >&2
  exit 1
fi
grep -E '^(PROBE|ARM|INSTALL|EXPLOSION_FREE|BREAKPOINT_HIT|FIRST_APPLY_ENTRY|FIRST_APPLY_RETURN|AREA2_OBJECTS|FIRST_AREA2_POLL|RESULT),|^TRACE_A1,timer=(493|513),|^TRACE_A2,timer=(594|595),' \
    "$full_trace" >"$trace"

grep -q '^RESULT,armed=1,boundaryInstalled=1,explosionFree=1,area2=1,aPressedFrames=0,aDownFrames=0,controllerAFrames=0,triggerEverInactive=1,initialCounter=0,finalCounter=1,maxCounter=1' \
    "$trace"
diff -u "$script_dir/expected-lifecycle-trace.txt" "$trace"
printf 'Trace: %s\n' "$trace"
