#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
base_dir="$(cd -- "$script_dir/../area1-long-jump-crossing" && pwd)"
project_dir="$(cd -- "$script_dir/../.." && pwd)"
decomp_dir="$(cd -- "$project_dir/../../.." && pwd)/reference-sm64-decomp"
output_dir="${1:-$project_dir/build/instrumentation/area1-long-jump-next-frame}"
expected_qsteps_csv="$script_dir/expected-frame-g-qsteps.csv"
expected_final_csv="$script_dir/expected-frame-g-final.csv"

mkdir -p "$output_dir"

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
    local version="$1" trace="$2"
    local expected_version final_row qstep_rows phase
    local csv_version csv_action csv_timer csv_input csv_down csv_pressed
    local csv_raw_x csv_raw_y csv_raw_z csv_gfx_x csv_gfx_y csv_gfx_z
    local csv_depth csv_wall csv_ceil csv_ceil_height csv_floor
    local csv_floor_type csv_floor_flags csv_floor_owner csv_platform
    local csv_lower_count csv_upper_count csv_floor_count csv_ceil_count
    local csv_commit_count csv_a_pressed csv_a_down
    local lower_pc upper_pc floor_pc ceil_pc commit_pc

    expected_version="${version^^}"
    final_row="$(awk -F, -v v="$expected_version" \
        'NR > 1 && $1 == v { print; exit }' "$expected_final_csv")"
    test -n "$final_row"
    IFS=, read -r csv_version csv_action csv_timer csv_input csv_down \
        csv_pressed csv_raw_x csv_raw_y csv_raw_z csv_gfx_x csv_gfx_y \
        csv_gfx_z csv_depth csv_wall csv_ceil csv_ceil_height csv_floor \
        csv_floor_type csv_floor_flags csv_floor_owner csv_platform \
        csv_lower_count csv_upper_count csv_floor_count csv_ceil_count \
        csv_commit_count csv_a_pressed csv_a_down <<<"$final_row"
    test "$csv_version" = "$expected_version"

    case "$version" in
        us)
            lower_pc=80255b28
            upper_pc=80255b3c
            floor_pc=80255b58
            ceil_pc=80255b6c
            commit_pc=80255cdc
            ;;
        jp)
            lower_pc=80255900
            upper_pc=80255914
            floor_pc=80255930
            ceil_pc=80255944
            commit_pc=80255ab4
            ;;
    esac

    grep -q "^LJQC_PRE,version=$expected_version,preTimer=3,.*action=00000479,actionTimer=3,input=0020,buttonDown=0000,buttonPressed=0000,faceYaw=0,floorAngle=0,pos=(5760,0,4856),posBits=(45b40000,00000000,4597c000),vel=(0,0,48),forwardVel=48,.*quicksandDepthBits=00000000,wall=00000000,ceil=00000000,ceilHeight=20000,ceilHeightBits=469c4000,platform=00000000,raw=(5760,0,4856),rawBits=(45b40000,00000000,4597c000),gfx=(5760,0,4856),gfxBits=(45b40000,00000000,4597c000),surface=.*type=0,force=0,flags=00,owner=00000000" \
        "$trace"
    grep -q "^LJQC_POST,version=$expected_version,preTimer=3,.*action=00000479,actionTimer=4,input=0020,buttonDown=0000,buttonPressed=0000,.*posBits=(45b40000,c0fc4011,4599198b),.*quicksandDepthBits=bf000000,wall=00000000,ceil=00000000,ceilHeight=20000,ceilHeightBits=469c4000,platform=00000000,raw=.*rawBits=(45b40000,c0fc4011,4599198b),gfx=.*gfxBits=(45b40000,c0ec4011,4599198b),surface=$csv_floor,type=37,force=0,flags=00,owner=00000000" \
        "$trace"
    grep -q "^LJQC_NEXT,version=$expected_version,preTimer=3,.*action=$csv_action,actionTimer=$csv_timer,input=$csv_input,buttonDown=$csv_down,buttonPressed=$csv_pressed,.*posBits=($csv_raw_x,$csv_raw_y,$csv_raw_z),.*quicksandDepthBits=$csv_depth,wall=$csv_wall,ceil=$csv_ceil,ceilHeight=20000,ceilHeightBits=$csv_ceil_height,platform=$csv_platform,raw=.*rawBits=($csv_raw_x,$csv_raw_y,$csv_raw_z),gfx=.*gfxBits=($csv_gfx_x,$csv_gfx_y,$csv_gfx_z),surface=$csv_floor,type=$csv_floor_type,force=0,flags=$csv_floor_flags,owner=$csv_floor_owner" \
        "$trace"

    for phase in lower-wall-return upper-wall-return floor-return \
                 ceil-return commit; do
        test "$(grep -c "^LJQC_QSTEP,.*phase=$phase" "$trace")" = 8
        test "$(grep -c "^LJQC_QSTEP,.*phase=$phase,frame=1" "$trace")" = 4
        test "$(grep -c "^LJQC_QSTEP,.*phase=$phase,frame=2" "$trace")" = 4
    done

    qstep_rows=0
    while IFS=, read -r q_version q_index q_intended_x q_intended_y \
        q_intended_z q_lower q_upper q_floor_height q_floor q_floor_type \
        q_floor_flags q_floor_owner q_ceil q_ceil_height q_raw_x q_raw_y \
        q_raw_z; do
        test "$q_version" = "$expected_version" || continue
        qstep_rows=$((qstep_rows + 1))

        grep -q "^LJQC_QSTEP,version=$expected_version,preTimer=3,qstep=$q_index,phase=lower-wall-return,frame=2,pc=$lower_pc,.*intendedBits=($q_intended_x,$q_intended_y,$q_intended_z),wall=$q_lower$" \
            "$trace"
        grep -q "^LJQC_QSTEP,version=$expected_version,preTimer=3,qstep=$q_index,phase=upper-wall-return,frame=2,pc=$upper_pc,.*intendedBits=($q_intended_x,$q_intended_y,$q_intended_z),wall=$q_upper$" \
            "$trace"
        grep -q "^LJQC_QSTEP,version=$expected_version,preTimer=3,qstep=$q_index,phase=floor-return,frame=2,pc=$floor_pc,.*intendedBits=($q_intended_x,$q_intended_y,$q_intended_z),height=.*heightBits=$q_floor_height,surface=$q_floor,type=$q_floor_type,force=0,flags=$q_floor_flags,owner=$q_floor_owner" \
            "$trace"
        test "$q_ceil" = 00000000
        grep -q "^LJQC_QSTEP,version=$expected_version,preTimer=3,qstep=$q_index,phase=ceil-return,frame=2,pc=$ceil_pc,.*intendedBits=($q_intended_x,$q_intended_y,$q_intended_z),height=.*heightBits=$q_ceil_height,surface=NULL$" \
            "$trace"
        grep -q "^LJQC_QSTEP,version=$expected_version,preTimer=3,qstep=$q_index,phase=commit,frame=2,pc=$commit_pc,.*intendedBits=($q_intended_x,$q_intended_y,$q_intended_z),raw=.*rawBits=($q_raw_x,$q_raw_y,$q_raw_z),floorHeight=.*floorHeightBits=$q_floor_height,wall=$q_lower,ceil=$q_ceil,ceilHeight=20000,ceilHeightBits=$q_ceil_height,surface=$q_floor,type=$q_floor_type,force=0,flags=$q_floor_flags,owner=$q_floor_owner" \
            "$trace"
    done < <(tail -n +2 "$expected_qsteps_csv")
    test "$qstep_rows" = 4

    grep -q "^LJQC_SUMMARY,version=$expected_version,preTimer=3,armed=1,done=1,aPressedPolls=$csv_a_pressed,aDownPolls=$csv_a_down,qstepBreakpoints=1,qstepLower=$csv_lower_count,qstepUpper=$csv_upper_count,qstepFloor=$csv_floor_count,qstepCeil=$csv_ceil_count,qstepCommit=$csv_commit_count$" \
        "$trace"
}

run_one() {
    local version="$1"
    local version_jp cheat rom expected_md5 expected_sha256
    local run_dir plugin trace

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

    run_dir="$output_dir/$version"
    plugin="$run_dir/area1_long_jump_next_frame_probe.so"
    trace="$run_dir/trace.txt"
    mkdir -p "$run_dir/shots"
    gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
        -DVERSION_JP="$version_jp" -DPRE_ACTION_TIMER=3 \
        -DTRACE_NEXT_FRAME=1 \
        "$base_dir/area1_long_jump_crossing_probe.c" -ldl \
        -o "$plugin"

    printf 'run\n' |
        LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a /usr/games/mupen64plus \
            --debug --emumode 0 --nosaveoptions --nospeedlimit --audio dummy \
            --input "$plugin" \
            --gfx mupen64plus-video-rice.so \
            --rsp mupen64plus-rsp-hle.so \
            --cheats "$cheat" --sshotdir "$run_dir/shots" --testshots 465 \
            "$rom" >"$run_dir/raw.log" 2>&1
    grep '^LJQC_' "$run_dir/raw.log" >"$trace"
    validate_trace "$version" "$trace"
}

run_one us
run_one jp

grep -h '^LJQC_\(PRE\|POST\|NEXT\|SUMMARY\)' "$output_dir"/*/trace.txt \
    >"$output_dir/summary.txt"
grep -h '^LJQC_QSTEP,.*phase=commit,frame=2' "$output_dir"/*/trace.txt \
    >"$output_dir/frame-g-qsteps.txt"
cat "$output_dir/summary.txt"
