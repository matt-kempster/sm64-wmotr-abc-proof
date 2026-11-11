#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
rom="$(realpath "${1:?usage: $0 /path/to/baserom.jp.z64 OUTPUT_DIRECTORY [staged|flat|outside|candidate TIMER LOW_X LOW_Y LOW_Z HIGH_X HIGH_Y HIGH_Z]}")"
out="${2:?specify a new output directory}"
mode="${3:-staged}"
test "$(sha256sum "$rom" | cut -d ' ' -f 1)" = 9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317
test "$(md5sum "$rom" | cut -d ' ' -f 1)" = 85d61f5525af708c9f1e84dce6dc10e9

# Capture the four pillar windows and keep the final window continuous.
case "$mode" in
    staged)
        position_flags=()
        testshots="$(seq -s, 785 890),$(seq -s, 1002 1110),$(seq -s, 2327 2435),$(seq -s, 2485 2785)"
        ;;
    flat)
        position_flags=(-DDEMO_DISPLAY_Y=768.0f)
        testshots=2785
        ;;
    outside)
        position_flags=(-DDEMO_MOVEMENT_X=9000.0f -DDEMO_OBSERVE_RETRY)
        testshots="$(seq -s, 2485 2785)"
        ;;
    candidate)
        if [ "$#" -ne 10 ] || ! [[ "$4" =~ ^(0|[1-9][0-9]{0,2})$ ]] || [ "$4" -gt 150 ]; then
            printf 'candidate requires TIMER (0..150) and six signed integer coordinates\n' >&2
            exit 2
        fi
        for coordinate in "${@:5}"; do
            if ! [[ "$coordinate" =~ ^(0|-?[1-9][0-9]{0,4})$ ]] \
                || [ "$coordinate" -lt -32768 ] || [ "$coordinate" -gt 32767 ]; then
                printf 'candidate coordinate outside signed-16 range: %s\n' "$coordinate" >&2
                exit 2
            fi
        done
        position_flags=(
            -DDEMO_OBSERVE_RETRY "-DDEMO_INSTALL_TIMER=$4"
            "-DDEMO_LOW_X=$5" "-DDEMO_LOW_Y=$6" "-DDEMO_LOW_Z=$7"
            "-DDEMO_DISPLAY_X=$8" "-DDEMO_DISPLAY_Y=$9" "-DDEMO_DISPLAY_Z=${10}"
        )
        testshots=2785
        ;;
    *) printf 'unknown capture mode %s\n' "$mode" >&2; exit 2 ;;
esac

mkdir "$out"
out="$(realpath "$out")"
mkdir "$out/config" "$out/data" "$out/shots"
gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
    "${position_flags[@]}" "$script_dir/probe.c" -ldl -lm -o "$out/probe.so"

printf 'Capture directory: %s\n' "$out"
printf 'run\n' |
    XDG_CONFIG_HOME="$out/config" XDG_DATA_HOME="$out/data" LIBGL_ALWAYS_SOFTWARE=1 \
    xvfb-run -a stdbuf -oL -eL "${MUPEN64PLUS:-/usr/games/mupen64plus}" \
        --debug --emumode 0 --nosaveoptions --nospeedlimit --noosd \
        --audio dummy --input "$out/probe.so" --gfx mupen64plus-video-rice.so \
        --rsp mupen64plus-rsp-hle.so --cheats 6 --sshotdir "$out/shots" \
        --testshots "$testshots" "$rom" >"$out/raw.log" 2>&1

bash "$script_dir/check.sh" "$out" "$mode" "${@:4}"
