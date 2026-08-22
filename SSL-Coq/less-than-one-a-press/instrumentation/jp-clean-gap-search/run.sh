#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 /path/to/authentic/baserom.jp.z64 [test-frames] [allow-setup-a] [search-mode]}"
test_frames="${2:-2400}"
allow_setup_a="${3:-0}"
search_mode="${4:-0}"

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

out_dir="$project_dir/build/instrumentation/jp-clean-gap-search/mode-${search_mode}-a${allow_setup_a}"
mkdir -p "$out_dir/config" "$out_dir/data" "$out_dir/shots"
plugin="$out_dir/jp-clean-gap-search.so"
raw_log="$out_dir/jp-clean-gap-search.raw.log"
trace="$out_dir/jp-clean-gap-search.trace.txt"
prefix_write_receipt="$out_dir/prefix-write-receipt.txt"
prefix_call_reach_receipt="$out_dir/prefix-call-reach-receipt.txt"
post_entry_receipt="$out_dir/post-entry-timer131-receipt.txt"

gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
    -DALLOW_SETUP_A="$allow_setup_a" \
    -DSEARCH_MODE="$search_mode" \
    "$script_dir/jp_clean_gap_search_probe.c" -ldl -lm -o "$plugin"

printf 'run\n' |
    XDG_CONFIG_HOME="$out_dir/config" \
    XDG_DATA_HOME="$out_dir/data" \
    LIBGL_ALWAYS_SOFTWARE=1 \
    xvfb-run -a "$emulator" \
        --debug --emumode 0 --nosaveoptions --nospeedlimit \
        --audio dummy --input "$plugin" \
        --gfx mupen64plus-video-rice.so \
        --rsp mupen64plus-rsp-hle.so \
        --cheats 6 --sshotdir "$out_dir/shots" --testshots "$test_frames" \
        "$rom" >"$raw_log" 2>&1

grep -aE '^(SEARCH|PREFIX_BREAKPOINT_ARM|PREFIX_STAGE|PREFIX_CELL_WRITE|PREFIX_CALL_REACH|ENTRY_IDENTITY|POST_ENTRY_TRACE_START|POST_ENTRY_WATCH_WRITE|POST_ENTRY_TRACE_END|ACTION|MAX_GAP|MIN_GAP|GAP45|GAP960|FIRE_LINK|TOP|FRAME|NONFINITE|B_INPUT|MODE9_STAGE|RESULT)' \
    "$raw_log" >"$trace"
grep -E '^(PREFIX_STAGE,.*timer=347,|PREFIX_CELL_WRITE,epoch=8,|ENTRY_IDENTITY,)' \
    "$trace" >"$prefix_write_receipt"
if ! diff -u "$script_dir/expected-prefix-write-receipt.txt" \
    "$prefix_write_receipt"; then
    printf '%s\n' "exact protected-cell write receipt failed" >&2
    exit 3
fi
grep -E '^(PREFIX_BREAKPOINT_ARM,|PREFIX_CALL_REACH,)' "$trace" \
    >"$prefix_call_reach_receipt"
if ! diff -u "$script_dir/expected-prefix-call-reach-receipt.txt" \
    "$prefix_call_reach_receipt"; then
    printf '%s\n' "exact pre-entry call reachability receipt failed" >&2
    exit 3
fi
grep '^RESULT' "$trace"
if ! awk '
    BEGIN { stage = 0 }
    stage == 0 && $0 == "PREFIX_STAGE,stage=clear_objects,sequence=1,pc=8029ca60,returnPC=8037ee68,a0=8038bd88,a1=0000000a,timer=347,area=1,marioObject=00000000,stateMarioObject=00000000" { stage = 1; next }
    stage == 1 && $0 == "PREFIX_STAGE,stage=load_mario_area,sequence=2,pc=8027aa0c,returnPC=8024b9a8,a0=00000000,a1=00000008,timer=347,area=1,marioObject=00000000,stateMarioObject=00000000" { stage = 2; next }
    stage == 2 && $0 == "PREFIX_STAGE,stage=spawn_objects_from_info,sequence=3,pc=8029c830,returnPC=8027a964,a0=00000000,a1=80182238,timer=347,area=1,marioObject=00000000,stateMarioObject=00000000" { stage = 3; next }
    stage == 3 && $0 == "PREFIX_STAGE,stage=spawn_objects_from_info,sequence=3,pc=8029c830,returnPC=8027aa70,a0=00000000,a1=8033a140,timer=347,area=1,marioObject=00000000,stateMarioObject=00000000" { stage = 4; next }
    stage == 4 && $0 == "PREFIX_STAGE,stage=init_mario,sequence=4,pc=802548bc,returnPC=8024b9b0,a0=80346052,a1=8033a146,timer=347,area=1,marioObject=80346038,stateMarioObject=00000000" { stage = 5; next }
    stage == 5 && $0 == "ENTRY_IDENTITY,timer=348,marioObject=80346038,slot=67,stateMarioObject=80346038,activeFlags=0101,behavior=800eb1c0,oFlags=00000100,oGraphYOffsetBits=00000000,next=8033b870,prev=8033b870,sentinelNext=80346038,sentinelPrev=80346038,stateMatches=1,tailSafe=1,listRing=1,prefixStage=4" { stage = 6; next }
    END { exit stage == 6 ? 0 : 1 }
' "$trace"; then
    printf '%s\n' "exact level-select clear/load/area-spawn/Mario-spawn/init/identity receipt failed" >&2
    exit 3
fi
if [ "$allow_setup_a" = 0 ]; then
    if ! grep -q '^RESULT,.*aPressedFrames=0,aDownFrames=0,controllerAFrames=0$' \
        "$trace"; then
        printf '%s\n' "zero-A run observed an A input or A-derived input bit" >&2
        exit 3
    fi
fi
if [ "$allow_setup_a" = 0 ] && [ "$search_mode" = 2 ] \
    && [ "$test_frames" -ge 600 ]; then
    grep -aE '^POST_ENTRY_TRACE_(START|END),' "$raw_log" \
        >"$post_entry_receipt"
    if ! diff -u "$script_dir/expected-post-entry-timer131-receipt.txt" \
        "$post_entry_receipt"; then
        printf '%s\n' "post-entry timer-131 endpoint receipt failed" >&2
        exit 3
    fi
    if ! awk '
        BEGIN { ordinal = 1 }
        /^POST_ENTRY_WATCH_WRITE,/ {
            expected = sprintf("POST_ENTRY_WATCH_WRITE,ordinal=%d,globalTimer=%d,pc=802c88c4,instruction=a7000076,op=29,mnemonic=sh,args=$zero,118($t8),target=803460ae,accessedPhysical=003460ac,cell=slot67.activeFlags,gprSource=00000000,classification=disjoint-slot67-padding-halfword,safe=1", ordinal, ordinal + 347)
            if ($0 != expected) exit 1
            ordinal++
        }
        END { exit ordinal == 132 ? 0 : 1 }
    ' "$raw_log"; then
        printf '%s\n' "post-entry per-write classification failed" >&2
        exit 3
    fi
fi
if grep -Eq 'DebugMemWrite|W32' "$script_dir/jp_clean_gap_search_probe.c"; then
    printf '%s\n' "probe source contains a game-memory write API" >&2
    exit 3
fi
if grep -q '^GAP960' "$trace"; then
    printf '%s\n' "A >=960 clean controller-only gap was observed."
else
    printf '%s\n' "No >=960 gap was observed in this bounded schedule."
fi
printf 'Trace: %s\n' "$trace"
