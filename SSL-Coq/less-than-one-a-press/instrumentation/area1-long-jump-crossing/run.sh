#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd -- "$script_dir/../.." && pwd)"
decomp_dir="$(cd -- "$project_dir/../../.." && pwd)/reference-sm64-decomp"
output_dir="${1:-$project_dir/build/instrumentation/area1-long-jump-crossing}"
expected_final_csv="$script_dir/expected-final.csv"
expected_qsteps_csv="$script_dir/expected-qsteps.csv"

mkdir -p "$output_dir"

# The proof project's pinned source and the clean matching-build revision have
# identical contents for every source unit used by this receipt.
git -C "$decomp_dir" diff --quiet \
    9921382a68bb0c865e5e45eb594d9c64db59b1af \
    36fbf8d693a9fc2bdec0c77402f8e96d07d2f461 -- \
    src/game/mario.c \
    src/game/mario_step.c \
    src/game/mario_actions_moving.c \
    src/game/object_list_processor.c \
    src/game/object_collision.c \
    src/engine/surface_collision.c \
    src/engine/math_util.c \
    src/engine/surface_load.c \
    levels/ssl/areas/1/collision.inc.c

validate_trace() {
    local version="$1" pre_timer="$2" trace="$3"
    local expected_version phase final_row qstep_rows
    local csv_version csv_pre csv_post csv_raw_x csv_raw_y csv_raw_z
    local csv_depth csv_floor csv_floor_type csv_floor_flags csv_floor_owner
    local csv_platform csv_lower csv_upper csv_floor_count csv_ceil
    local csv_commit csv_a_pressed csv_a_down csv_pre_input
    local csv_pre_down csv_pre_pressed

    expected_version="${version^^}"
    final_row="$(awk -F, -v v="$expected_version" -v t="$pre_timer" \
        'NR > 1 && $1 == v && $2 == t { print; exit }' \
        "$expected_final_csv")"
    test -n "$final_row"
    IFS=, read -r csv_version csv_pre csv_post csv_raw_x csv_raw_y \
        csv_raw_z csv_depth csv_floor csv_floor_type csv_floor_flags \
        csv_floor_owner csv_platform csv_lower csv_upper csv_floor_count \
        csv_ceil csv_commit csv_a_pressed csv_a_down csv_pre_input \
        csv_pre_down csv_pre_pressed <<<"$final_row"
    test "$csv_version" = "$expected_version"
    test "$csv_pre" = "$pre_timer"

    grep -q "^LJQC_PRE,version=$expected_version,preTimer=$pre_timer,.*action=00000479,actionTimer=$pre_timer,input=$csv_pre_input,buttonDown=$csv_pre_down,buttonPressed=$csv_pre_pressed,faceYaw=0,floorAngle=0,pos=(5760,0,4856),posBits=(45b40000,00000000,4597c000),vel=(0,0,48),forwardVel=48,.*quicksandDepthBits=00000000,wall=00000000,ceil=00000000,ceilHeight=20000,ceilHeightBits=469c4000,platform=00000000,raw=(5760,0,4856),rawBits=(45b40000,00000000,4597c000),gfx=(5760,0,4856),gfxBits=(45b40000,00000000,4597c000),surface=.*type=0,force=0,flags=00,owner=00000000" \
        "$trace"

    for phase in lower-wall-return upper-wall-return floor-return \
                 ceil-return commit; do
        test "$(grep -c "^LJQC_QSTEP,.*phase=$phase" "$trace")" = 4
    done
    test "$(grep -c '^LJQC_QSTEP,.*phase=lower-wall-return.*wall=00000000$' \
        "$trace")" = 4
    test "$(grep -c '^LJQC_QSTEP,.*phase=upper-wall-return.*wall=00000000$' \
        "$trace")" = 4
    test "$(grep -c '^LJQC_QSTEP,.*phase=floor-return.*type=37,force=0,flags=00,owner=00000000' \
        "$trace")" = 4
    test "$(grep -c '^LJQC_QSTEP,.*phase=ceil-return.*heightBits=469c4000,surface=NULL$' \
        "$trace")" = 4
    test "$(grep -c '^LJQC_QSTEP,.*phase=commit.*wall=00000000,ceil=00000000,ceilHeight=20000,ceilHeightBits=469c4000,.*type=37,force=0,flags=00,owner=00000000' \
        "$trace")" = 4

    qstep_rows=0
    while IFS=, read -r q_version q_pre q_index q_intended_x \
        q_intended_y q_intended_z q_lower q_upper q_floor_height \
        q_floor_type q_floor_flags q_floor_owner q_ceil q_ceil_height \
        q_raw_x q_raw_y q_raw_z; do
        test "$q_version" = "$expected_version" || continue
        test "$q_pre" = "$pre_timer" || continue
        qstep_rows=$((qstep_rows + 1))

        grep -q "^LJQC_QSTEP,version=$expected_version,preTimer=$pre_timer,qstep=$q_index,phase=lower-wall-return,.*intendedBits=($q_intended_x,$q_intended_y,$q_intended_z),wall=$q_lower$" \
            "$trace"
        grep -q "^LJQC_QSTEP,version=$expected_version,preTimer=$pre_timer,qstep=$q_index,phase=upper-wall-return,.*intendedBits=($q_intended_x,$q_intended_y,$q_intended_z),wall=$q_upper$" \
            "$trace"
        grep -q "^LJQC_QSTEP,version=$expected_version,preTimer=$pre_timer,qstep=$q_index,phase=floor-return,.*intendedBits=($q_intended_x,$q_intended_y,$q_intended_z),height=.*heightBits=$q_floor_height,surface=$csv_floor,type=$q_floor_type,force=0,flags=$q_floor_flags,owner=$q_floor_owner" \
            "$trace"
        test "$q_ceil" = 00000000
        grep -q "^LJQC_QSTEP,version=$expected_version,preTimer=$pre_timer,qstep=$q_index,phase=ceil-return,.*intendedBits=($q_intended_x,$q_intended_y,$q_intended_z),height=.*heightBits=$q_ceil_height,surface=NULL$" \
            "$trace"
        grep -q "^LJQC_QSTEP,version=$expected_version,preTimer=$pre_timer,qstep=$q_index,phase=commit,.*intendedBits=($q_intended_x,$q_intended_y,$q_intended_z),raw=.*rawBits=($q_raw_x,$q_raw_y,$q_raw_z),floorHeight=.*floorHeightBits=$q_floor_height,wall=$q_lower,ceil=$q_ceil,ceilHeight=20000,ceilHeightBits=$q_ceil_height,surface=$csv_floor,type=$q_floor_type,force=0,flags=$q_floor_flags,owner=$q_floor_owner" \
            "$trace"
    done < <(tail -n +2 "$expected_qsteps_csv")
    test "$qstep_rows" = 4

    grep -q "^LJQC_POST,version=$expected_version,preTimer=$pre_timer,.*action=00000479,actionTimer=$csv_post,input=$csv_pre_input,buttonDown=$csv_pre_down,buttonPressed=$csv_pre_pressed,.*posBits=($csv_raw_x,$csv_raw_y,$csv_raw_z).*quicksandDepthBits=$csv_depth,.*platform=$csv_platform,.*surface=$csv_floor,type=$csv_floor_type,force=0,flags=$csv_floor_flags,owner=$csv_floor_owner" \
        "$trace"
    grep -q "^LJQC_SUMMARY,version=$expected_version,preTimer=$pre_timer,armed=1,done=1,aPressedPolls=$csv_a_pressed,aDownPolls=$csv_a_down,qstepBreakpoints=1,qstepLower=$csv_lower,qstepUpper=$csv_upper,qstepFloor=$csv_floor_count,qstepCeil=$csv_ceil,qstepCommit=$csv_commit$" \
        "$trace"
}

run_one() {
    local version="$1" pre_timer="$2"
    local version_jp cheat rom expected_md5 expected_sha256
    local run_dir plugin

    case "$version" in
        us)
            version_jp=0
            cheat=1
            rom="$decomp_dir/baserom.us.z64"
            expected_md5="20b854b239203baf6c961b850a4a51a2"
            expected_sha256="17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91"
            ;;
        jp)
            version_jp=1
            cheat=6
            rom="$decomp_dir/baserom.jp.z64"
            expected_md5="85d61f5525af708c9f1e84dce6dc10e9"
            expected_sha256="9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317"
            ;;
        *)
            echo "unknown version: $version" >&2
            exit 2
            ;;
    esac

    test "$(md5sum "$rom" | cut -d ' ' -f 1)" = "$expected_md5"
    test "$(sha256sum "$rom" | cut -d ' ' -f 1)" = "$expected_sha256"

    run_dir="$output_dir/${version}-timer${pre_timer}"
    plugin="$run_dir/area1_long_jump_crossing_probe.so"
    mkdir -p "$run_dir/shots"
    gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
        -DVERSION_JP="$version_jp" -DPRE_ACTION_TIMER="$pre_timer" \
        "$script_dir/area1_long_jump_crossing_probe.c" -ldl \
        -o "$plugin"

    printf 'run\n' |
        LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a /usr/games/mupen64plus \
            --debug --emumode 0 --nosaveoptions --nospeedlimit --audio dummy \
            --input "$plugin" \
            --gfx mupen64plus-video-rice.so \
            --rsp mupen64plus-rsp-hle.so \
            --cheats "$cheat" --sshotdir "$run_dir/shots" --testshots 460 \
            "$rom" >"$run_dir/raw.log" 2>&1
    grep '^LJQC_' "$run_dir/raw.log" >"$run_dir/trace.txt"
    validate_trace "$version" "$pre_timer" "$run_dir/trace.txt"
}

run_one us 3
run_one us 4
run_one jp 3
run_one jp 4

grep -h '^LJQC_\(PRE\|POST\|SUMMARY\)' "$output_dir"/*/trace.txt \
    >"$output_dir/summary.txt"
grep -h '^LJQC_QSTEP,.*phase=commit' "$output_dir"/*/trace.txt \
    >"$output_dir/qstep-summary.txt"
cat "$output_dir/summary.txt"
