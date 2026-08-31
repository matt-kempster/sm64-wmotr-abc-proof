#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
us_rom="${1:?usage: run-probe.sh /path/to/baserom.us.z64 /path/to/baserom.jp.z64 [output-directory]}"
jp_rom="${2:?usage: run-probe.sh /path/to/baserom.us.z64 /path/to/baserom.jp.z64 [output-directory]}"
output_dir="${3:-$script_dir/build}"

check_rom() {
    local rom="$1" expected_md5="$2" expected_sha256="$3"
    test "$(md5sum "$rom" | cut -d ' ' -f 1)" = "$expected_md5"
    test "$(sha256sum "$rom" | cut -d ' ' -f 1)" = "$expected_sha256"
}

check_rom "$us_rom" \
    20b854b239203baf6c961b850a4a51a2 \
    17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91
check_rom "$jp_rom" \
    85d61f5525af708c9f1e84dce6dc10e9 \
    9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317

mkdir -p "$output_dir/us/shots" "$output_dir/jp/shots"

write_sqrtf_receipt() {
    local label="$1" rom="$2" sha256="$3" virtual_address="$4"
    local rom_offset="$5" lower bytes
    lower="$(printf '%s' "$label" | tr '[:upper:]' '[:lower:]')"
    bytes="$(od -An -v -tx1 -j "$((16#$rom_offset))" -N 16 "$rom" |
        tr -d '[:space:]')"
    printf 'SQRTF,%s,sha256=%s,va=%s,rom=%s,bytes=%s\n' \
        "$label" "$sha256" "$virtual_address" "$rom_offset" "$bytes" \
        >"$output_dir/$lower.sqrtf"
}

write_sqrtf_receipt US "$us_rom" \
    17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91 \
    80323a50 000dea50
write_sqrtf_receipt JP "$jp_rom" \
    9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317 \
    80322b20 000ddb20

run_version() {
    local label="$1" rom="$2" cheat="$3" timer="$4" level="$5"
    local area="$6" mario_state="$7" mario_object="$8" pool="$9"
    shift 9
    local object_lists="$1" free_list="$2" time_stop="$3" ttc_speed="$4"
    local current_object="$5" random_seed="$6" random_entry="$7"
    local random_return="$8"
    local lower
    lower="$(printf '%s' "$label" | tr '[:upper:]' '[:lower:]')"

    gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
        -DVERSION_NAME="\"$label\"" \
        -DA_GLOBAL_TIMER="$timer" -DA_CURR_LEVEL="$level" \
        -DA_CURR_AREA="$area" -DA_MARIO_STATES="$mario_state" \
        -DA_MARIO_OBJECT="$mario_object" -DA_OBJECT_POOL="$pool" \
        -DA_OBJECT_LISTS="$object_lists" \
        -DA_FREE_OBJECT_LIST="$free_list" \
        -DA_TIME_STOP_STATE="$time_stop" \
        -DA_TTC_SPEED_SETTING="$ttc_speed" \
        -DA_CURRENT_OBJECT="$current_object" \
        -DA_RANDOM_SEED16="$random_seed" \
        -DPC_RANDOM_U16_ENTRY="$random_entry" \
        -DPC_RANDOM_U16_RETURN="$random_return" \
        "$script_dir/ttc_runtime_probe.c" -ldl \
        -o "$output_dir/$lower/probe.so"

    printf 'run\n' | LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a mupen64plus \
        --debug --emumode 0 --nosaveoptions --nospeedlimit --audio dummy \
        --input "$output_dir/$lower/probe.so" \
        --gfx mupen64plus-video-rice.so --rsp mupen64plus-rsp-hle.so \
        --cheats "$cheat" --sshotdir "$output_dir/$lower/shots" \
        --testshots 900 "$rom" >"$output_dir/$lower/raw.log" 2>&1

    grep -E '^(TTC_SNAPSHOT|TTC_OBJECT)' \
        "$output_dir/$lower/raw.log" >"$output_dir/$lower.snapshot"
    test "$(grep -c '^TTC_SNAPSHOT' "$output_dir/$lower.snapshot")" = 1
    test "$(grep -c '^TTC_OBJECT' "$output_dir/$lower.snapshot")" = 240
    test "$(grep -c '^TTC_RNG_ARMED' "$output_dir/$lower/raw.log")" = 1
    if grep -q '^TTC_RNG_ERROR' "$output_dir/$lower/raw.log"; then
        grep '^TTC_RNG_ERROR' "$output_dir/$lower/raw.log" >&2
        return 1
    fi

    local snapshot_timer
    snapshot_timer="$(sed -n \
        's/^TTC_SNAPSHOT,[^,]*,timer=\([0-9][0-9]*\),.*/\1/p' \
        "$output_dir/$lower.snapshot")"
    awk -F, -v frame="$snapshot_timer" '
        /^TTC_RNG,/ {
            timer = -1
            for (i = 1; i <= NF; ++i) {
                if ($i ~ /^timer=/) {
                    split($i, pair, "=")
                    timer = pair[2] + 0
                }
            }
            if (timer == frame) print $0 ",frame=F"
            if (timer == frame + 1) print $0 ",frame=F+1"
        }
    ' "$output_dir/$lower/raw.log" >"$output_dir/$lower.rng"
}

# The configured cheat IDs enable the retail binary's dormant level-select
# screen.  Consequently these are debug-origin discovery replays, not stock
# controller-only reachability witnesses.
run_version US "$us_rom" 1 \
    0x8032d5d4 0x8032ddf8 0x8033baca 0x8033b170 \
    0x80361158 0x8033d488 0x803610e8 0x803610f0 0x80360e88 \
    0x80361258 0x80361160 0x8038eee0 0x80383bb0 0x80383cac
run_version JP "$jp_rom" 6 \
    0x8032c694 0x8032ce98 0x8033a75a 0x80339e00 \
    0x8035fde8 0x8033c118 0x8035fd78 0x8035fd80 0x8035fb18 \
    0x8035fee8 0x8035fdf0 0x8038eee0 0x80383bb0 0x80383cac

diff -u "$script_dir/results/us.snapshot" "$output_dir/us.snapshot"
diff -u "$script_dir/results/jp.snapshot" "$output_dir/jp.snapshot"
diff -u "$script_dir/results/us.rng" "$output_dir/us.rng"
diff -u "$script_dir/results/jp.rng" "$output_dir/jp.rng"
diff -u "$script_dir/results/us.sqrtf" "$output_dir/us.sqrtf"
diff -u "$script_dir/results/jp.sqrtf" "$output_dir/jp.sqrtf"
