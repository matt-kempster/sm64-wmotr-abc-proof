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

out_dir="$project_dir/build/instrumentation/timer131-state-first"
mkdir -p "$out_dir/config" "$out_dir/data" "$out_dir/shots"
plugin="$out_dir/timer131-state-first.so"
raw_log="$out_dir/timer131-state-first.raw.log"
trace="$out_dir/timer131-state-first.trace.txt"

gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
    -DSTATE_FIRST_MODE=1 \
    "$script_dir/../timer131-installer/timer131_installer_probe.c" \
    -ldl -lm -o "$plugin"

printf 'run\n' |
    XDG_CONFIG_HOME="$out_dir/config" \
    XDG_DATA_HOME="$out_dir/data" \
    LIBGL_ALWAYS_SOFTWARE=1 \
    xvfb-run -a "$emulator" \
        --debug --emumode 0 --nosaveoptions --nospeedlimit \
        --audio dummy --input "$plugin" \
        --gfx mupen64plus-video-rice.so \
        --rsp mupen64plus-rsp-hle.so \
        --cheats 6 --sshotdir "$out_dir/shots" --testshots 680 \
        "$rom" >"$raw_log" 2>&1

grep -E '^(PROBE|ARM|INSTALL|NEXT|RESULT)' "$raw_log" >"$trace"
grep '^INSTALL' "$trace"
grep '^NEXT' "$trace"
grep -q '^RESULT,armed=1,installed=1,next=1,retryCopied=0,stateCoordinatesPreserved=1,retryOwnerTop=1,warpAction=1,usedObjWarp=1,platformTop=1,aPressedFrames=0,aDownFrames=0,controllerAFrames=0$' "$trace"
diff -u "$script_dir/expected-trace.txt" "$trace"
printf 'Trace: %s\n' "$trace"
