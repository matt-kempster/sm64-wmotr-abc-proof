#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 /path/to/authentic/baserom.jp.z64 install-timer}"
install_timer="${2:?usage: $0 /path/to/authentic/baserom.jp.z64 install-timer}"

expected_md5="85d61f5525af708c9f1e84dce6dc10e9"
expected_sha256="9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317"
actual_md5="$(md5sum "$rom" | awk '{print $1}')"
actual_sha256="$(sha256sum "$rom" | awk '{print $1}')"
if [ "$actual_md5" != "$expected_md5" ] \
    || [ "$actual_sha256" != "$expected_sha256" ]; then
    printf '%s\n' "refusing non-authentic or non-JP ROM" >&2
    exit 2
fi

case "$install_timer" in
    ''|*[!0-9]*) printf 'invalid install timer: %s\n' "$install_timer" >&2; exit 2 ;;
esac
if [ "$install_timer" -gt 150 ]; then
    printf 'invalid install timer: %s\n' "$install_timer" >&2
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

out_dir="$project_dir/build/instrumentation/jp-install-timer-sweep/t-$install_timer"
mkdir -p "$out_dir/config" "$out_dir/data" "$out_dir/shots"
plugin="$out_dir/jp-install-timer-sweep.so"
raw_log="$out_dir/jp-install-timer-sweep.raw.log"
trace="$out_dir/jp-install-timer-sweep.trace.txt"

gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
    -DINSTALL_TIMER="$install_timer" \
    "$script_dir/jp_install_timer_sweep_probe.c" -ldl -lm -o "$plugin"

# This sweep is intentionally poll-boundary instrumentation.  It does not
# install an execution breakpoint; the authentic first-apply entry/return
# trace is owned by instrumentation/jp-lifecycle/.
printf 'run\n' |
    XDG_CONFIG_HOME="$out_dir/config" \
    XDG_DATA_HOME="$out_dir/data" \
    LIBGL_ALWAYS_SOFTWARE=1 \
    xvfb-run -a "$emulator" \
        --debug --emumode 0 --nosaveoptions --nospeedlimit \
        --audio dummy --input "$plugin" \
        --gfx mupen64plus-video-rice.so \
        --rsp mupen64plus-rsp-hle.so \
        --cheats 6 --sshotdir "$out_dir/shots" --testshots 620 \
        "$rom" >"$raw_log" 2>&1

grep -E '^(TIMER_RETRY|TRACE_A1|EXPLOSION_FREE|FIRST_APPLY|FIRST_AREA2_POLL|RESULT)' \
    "$raw_log" >"$trace"
grep '^TIMER_RETRY' "$trace"
grep '^FIRST_AREA2_POLL' "$trace"
grep '^RESULT' "$trace"
printf 'Trace: %s\n' "$trace"
