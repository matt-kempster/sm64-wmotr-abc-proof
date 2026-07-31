#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 ROM [stick-x stick-y timer frames mode state-x state-y state-z graphics-x graphics-y graphics-z]}"
route_x="${2:--127}"
route_y="${3:--96}"
install_timer="${4:-131}"
route_frames="${5:-60}"
boundary_mode="${6:-three-view}"
state_x="${7:--2200}"
state_y="${8:-768}"
state_z="${9:--1024}"
graphics_x="${10:--1862}"
graphics_y="${11:-1778}"
graphics_z="${12:--902}"

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

case "$route_x" in
    -127|-96|-64|-32|0|32|64|96|127) ;;
    *) printf 'unsupported route X axis: %s\n' "$route_x" >&2; exit 2 ;;
esac
case "$route_y" in
    -127|-96|-64|-32|0|32|64|96|127) ;;
    *) printf 'unsupported route Y axis: %s\n' "$route_y" >&2; exit 2 ;;
esac

case "$install_timer" in
    ''|*[!0-9]*)
        printf 'unsupported install timer: %s\n' "$install_timer" >&2
        exit 2
        ;;
esac
if [ "$install_timer" -gt 150 ]; then
    printf 'unsupported install timer: %s\n' "$install_timer" >&2
    exit 2
fi
case "$route_frames" in
    ''|*[!0-9]*)
        printf 'unsupported route frame count: %s\n' "$route_frames" >&2
        exit 2
        ;;
esac
if [ "$route_frames" -gt 600 ]; then
    printf 'unsupported route frame count: %s\n' "$route_frames" >&2
    exit 2
fi
case "$boundary_mode" in
    three-view) boundary_post_owner=0 ;;
    post-owner) boundary_post_owner=1 ;;
    *) printf 'unsupported boundary mode: %s\n' "$boundary_mode" >&2; exit 2 ;;
esac

for coordinate in \
    "$state_x" "$state_y" "$state_z" \
    "$graphics_x" "$graphics_y" "$graphics_z"; do
    if ! [[ "$coordinate" =~ ^-?[0-9]+$ ]]; then
        printf 'unsupported integer coordinate: %s\n' "$coordinate" >&2
        exit 2
    fi
    if [ "$coordinate" -lt -32768 ] || [ "$coordinate" -gt 32767 ]; then
        printf 'coordinate outside signed-16 range: %s\n' "$coordinate" >&2
        exit 2
    fi
done

out_dir="$project_dir/build/instrumentation/jp-lifecycle/$boundary_mode-t-$install_timer-x-$route_x-y-$route_y-f-$route_frames-g-$graphics_x-$graphics_y-$graphics_z"
mkdir -p "$out_dir/config" "$out_dir/data" "$out_dir/shots"
plugin="$out_dir/jp-lifecycle.so"
raw_log="$out_dir/jp-lifecycle.raw.log"
trace="$out_dir/jp-lifecycle.trace.txt"

gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
    -DROUTE_STICK_X="$route_x" \
    -DROUTE_STICK_Y="$route_y" \
    -DINSTALL_TIMER="$install_timer" \
    -DROUTE_HOLD_FRAMES="$route_frames" \
    -DBOUNDARY_POST_OWNER="$boundary_post_owner" \
    -DSTATE_X="$state_x" \
    -DSTATE_Y="$state_y" \
    -DSTATE_Z="$state_z" \
    -DGRAPHICS_X="$graphics_x" \
    -DGRAPHICS_Y="$graphics_y" \
    -DGRAPHICS_Z="$graphics_z" \
    "$script_dir/jp_lifecycle_probe.c" -ldl -lm -o "$plugin"

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

# Mupen's core and plugin write the same descriptor concurrently.  A core
# diagnostic can therefore prefix a plugin record on rare runs (for example,
# `CorINSTALL,...`).  Extract from the first record tag rather than requiring
# the tag to begin the physical line.
grep -oE '(PROBE|ARM|INSTALL|TRACE_A1|TRACE_A2|EXPLOSION_FREE|BREAKPOINT[^,]*|FIRST_APPLY[^,]*|AREA2_OBJECTS|FIRST_AREA2_POLL|RESULT),.*' \
    "$raw_log" >"$trace"

grep '^INSTALL' "$trace"
grep '^EXPLOSION_FREE' "$trace"
grep '^FIRST_APPLY_ENTRY' "$trace"
grep '^FIRST_APPLY_RETURN' "$trace"
grep '^FIRST_AREA2_POLL' "$trace"
grep '^RESULT' "$trace"
if [ "$route_x" = -127 ] && [ "$route_y" = -96 ] \
    && [ "$install_timer" = 131 ] && [ "$route_frames" = 60 ] \
    && [ "$boundary_mode" = three-view ] \
    && [ "$state_x" = -2200 ] && [ "$state_y" = 768 ] \
    && [ "$state_z" = -1024 ] \
    && [ "$graphics_x" = -1862 ] && [ "$graphics_y" = 1778 ] \
    && [ "$graphics_z" = -902 ]; then
    grep -q '^BREAKPOINT_HIT,kind=true-first-apply-entry,pc=802c83f0,returnPC=8029cfc8,area=2,platform=803451f8,slot=61$' "$trace"
    grep -q '^BREAKPOINT_HIT,kind=true-first-apply-return,pc=8029cfc8,area=2,platform=803451f8,slot=61$' "$trace"
    grep -q '^TRACE_A1,timer=493,.*platform=803451f8,timeStopState=00000000,marioAction=00001300,actionArg=00040001,usedObj=80345918,.*floorOwner=803451f8,.*marioBits=(c4e8c000,44defe16,c4618000),objectBits=(c4e8c000,44defe16,c4618000),graphicsBits=(c4e8c000,44defe16,c4618000),.*freeDepth=-1' "$trace"
    grep -q '^EXPLOSION_FREE,timer=513,.*slot=61,active=0,.*platform=803451f8,.*marioBits=(c4fa6882,44f09f67,c445cbb7),objectBits=(c4fa6882,44f09f67,c445cbb7),graphicsBits=(c4fa6882,44f09f67,c445cbb7),.*freeDepth=0,freeLength=109' "$trace"
    grep -q '^FIRST_APPLY_ENTRY,timer=515,area=2,.*slot=61,active=0,.*platform=803451f8,timeStopState=00000000,.*marioBits=(00000000,45abe000,43800000),objectBits=(00000000,45abe000,43800000),graphicsBits=(00000000,45abe000,43800000),.*freeDepth=47,freeLength=156' "$trace"
    grep -q '^FIRST_APPLY_RETURN,timer=515,area=2,.*slot=61,active=0,.*platform=803451f8,timeStopState=00000000,.*marioBits=(43b6cbe0,45abe000,c48919af),objectBits=(00000000,45abe000,43800000),graphicsBits=(00000000,45abe000,43800000),.*freeDepth=47,freeLength=156' "$trace"
    grep -q '^FIRST_AREA2_POLL,timer=516,area=2,.*platform=00000000,.*marioBits=(43b6cbe0,45abe000,c48919af),objectBits=(43b6cbe0,45abe000,c48919af),graphicsBits=(43b6cbe0,45abe000,c48919af),.*counter=0,freeDepth=47,freeLength=156' "$trace"
    grep -q '^TRACE_A2,timer=594,.*marioBits=(43c335e4,457a9000,c414712a),objectBits=(43c335e4,457a9000,c414712a),.*triggerActive=257,counter=0' "$trace"
    grep -q '^TRACE_A2,timer=595,.*marioBits=(43c3ef84,4576d000,c41334be),objectBits=(43c3ef84,4576d000,c41334be),.*triggerActive=0,counter=1' "$trace"
    grep -q '^RESULT,armed=1,boundaryInstalled=1,explosionFree=1,area2=1,aPressedFrames=0,aDownFrames=0,controllerAFrames=0,triggerEverInactive=1,initialCounter=0,finalCounter=1,maxCounter=1,breakpointArmed=1,firstApplyEntry=1,firstApplyReturn=1$' "$trace"
fi
printf 'Trace: %s\n' "$trace"
