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
    printf '%s\n' "refusing non-authentic or non-JP ROM:" >&2
    printf '  MD5:    %s\n' "$actual_md5" >&2
    printf '  SHA256: %s\n' "$actual_sha256" >&2
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

for command_name in gcc xvfb-run md5sum sha256sum awk grep; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf 'required command not found: %s\n' "$command_name" >&2
        exit 2
    fi
done

out_dir="$project_dir/build/instrumentation/stale-top-trigger"
mkdir -p "$out_dir"

run_mode() {
    mode="$1"
    stage_at_boundary="$2"
    plugin="$out_dir/probe-$mode.so"
    raw_log="$out_dir/$mode.raw.log"
    trace="$out_dir/$mode.trace.txt"
    shot_dir="$out_dir/$mode-shots"
    config_dir="$out_dir/$mode-config"
    data_dir="$out_dir/$mode-data"

    mkdir -p "$shot_dir" "$config_dir" "$data_dir"
    gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
        -DSTAGE_AT_AREA2_BOUNDARY="$stage_at_boundary" \
        -DTRACE_FRAMES=360 \
        "$script_dir/jp_stale_top_trigger_probe.c" \
        -ldl -lm -o "$plugin"

    printf 'run\n' |
        XDG_CONFIG_HOME="$config_dir" \
        XDG_DATA_HOME="$data_dir" \
        LIBGL_ALWAYS_SOFTWARE=1 \
        xvfb-run -a "$emulator" \
            --debug --emumode 0 --nosaveoptions --nospeedlimit \
            --audio dummy --input "$plugin" \
            --gfx mupen64plus-video-rice.so \
            --rsp mupen64plus-rsp-hle.so \
            --cheats 6 --sshotdir "$shot_dir" --testshots 770 \
            "$rom" >"$raw_log" 2>&1

    grep -E '^(PROBE|WARP_FIXTURE|PRE_TRANSITION_STAGE|OBJECTS|AREA2_|START|TRACE|RESULT)' \
        "$raw_log" >"$trace"
}

run_mode pre-transition-only 0
run_mode area2-boundary 1

pre_trace="$out_dir/pre-transition-only.trace.txt"
boundary_trace="$out_dir/area2-boundary.trace.txt"

grep -q 'AREA2_BEFORE,mode=pre-transition-only.*platform=00000000' \
    "$pre_trace"
grep -q 'RESULT,version=JP,mode=pre-transition-only.*aPressedFrames=0,aDownFrames=0,controllerAFrames=0' \
    "$pre_trace"
grep -q 'RESULT,version=JP,mode=area2-boundary,frames=360,aPressedFrames=0,aDownFrames=0,controllerAFrames=0,act3RegionFrames=0' \
    "$boundary_trace"
grep -q 'triggerEverInactive=1,initialCounter=0,finalCounter=1,maxCounter=1' \
    "$boundary_trace"

printf 'ROM MD5:    %s\n' "$actual_md5"
printf 'ROM SHA256: %s\n' "$actual_sha256"
printf 'Pre-transition result:\n'
grep '^RESULT' "$pre_trace"
printf 'Boundary-fixture result:\n'
grep '^RESULT' "$boundary_trace"
printf 'Traces:\n  %s\n  %s\n' "$pre_trace" "$boundary_trace"
