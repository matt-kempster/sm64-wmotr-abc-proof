#!/usr/bin/env bash
set -euo pipefail

out="${1:?usage: $0 OUTPUT_DIRECTORY [staged|flat|outside|candidate TIMER LOW_X LOW_Y LOW_Z HIGH_X HIGH_Y HIGH_Z]}"
mode="${2:-staged}"
trace="$out/trace.txt"
install_timer=131
if [ "$mode" = candidate ]; then
    install_timer="${3:?specify the candidate top timer}"
fi
setup_timer=$((2549 + install_timer))

grep -aoE '(DEMO_[A-Z0-9_]+|TOP|RESULT),.*' "$out/raw.log" >"$trace"
grep -E '^DEMO_(BEFORE_SETUP|SETUP|FIRST_FLOOR|RETRY_FLOOR|WARP_ACCEPTED|TOP_RETIRED|APPLY_ENTRY|APPLY_RETURN|ARRIVAL|RESULT),' "$trace"
grep -q '^RESULT,.*aPressedFrames=0,aDownFrames=0,controllerAFrames=0$' "$trace"
grep -q '^DEMO_PILLAR,timer=848,.*pillars=1,' "$trace"
grep -q '^DEMO_PILLAR,timer=1065,.*pillars=2,' "$trace"
grep -q '^DEMO_PILLAR,timer=2390,.*pillars=3,' "$trace"
grep -q '^DEMO_PILLAR,timer=2548,.*pillars=4,' "$trace"
grep -q '^TOP,timer=2549,pillars=4,action=1,objectTimer=0,' "$trace"
grep -q "^DEMO_BEFORE_SETUP,timer=$setup_timer,.*pillars=4,.*topTimer=$install_timer,.*platform=00000000,action=0c400201,.*held=00000000,depth=0," "$trace"
if grep -q '^DEMO_ERROR,' "$trace"; then exit 3; fi

case "$mode" in
    staged|outside)
        if [ "$mode" = outside ]; then
            movement_x=9000
            grep -q '^DEMO_FIRST_FLOOR,timer=2680,.*floor=00000000,owner=00000000,.*state=(9000,768,-1024),' "$trace"
            grep -q '^DEMO_RETRY_FLOOR,timer=2680,.*owner=803451f8,.*state=(-2200,1938.86487,-1024),collision=(-2200,768,-1024),' "$trace"
        else
            movement_x=-2200
        fi
        grep -q "^DEMO_SETUP,timer=2680,.*state=($movement_x,768,-1024),collision=(-2200,768,-1024),display=(-2200,1938.86487,-1024)$" "$trace"
        grep -q '^DEMO_RESULT,setup=1,warp=1,retired=1,area2=1$' "$trace"
        grep -q '^DEMO_WARP_ACCEPTED,timer=2681,.*platform=803451f8,action=00001300,used=80345918,warp=80345918,.*owner=803451f8,' "$trace"
        grep -q '^DEMO_TOP_RETIRED,timer=2701,.*top=803451f8,.*topActive=0,platform=803451f8,' "$trace"
        grep -q '^DEMO_APPLY_ENTRY,timer=2703,.*area=2,.*topActive=0,platform=803451f8,.*state=(0,5500,256),' "$trace"
        grep -q '^DEMO_APPLY_RETURN,timer=2703,.*area=2,.*topActive=0,platform=803451f8,.*state=(365.592773,5500,-1096.80261),' "$trace"
        grep -q '^DEMO_AREA2,timer=2728,.*owner=00000000,floorY=4429,state=(337,4429,-1075),' "$trace"
        {
            if [ "$mode" = staged ]; then
                seq 785 890
                seq 1002 1110
                seq 2327 2435
            fi
            seq 2485 2785
        } >"$out/render-frames.txt"
        ;;
    flat)
        grep -q '^DEMO_SETUP,timer=2680,.*state=(-2200,768,-1024),collision=(-2200,768,-1024),display=(-2200,768,-1024)$' "$trace"
        grep -q '^DEMO_WARP_ACCEPTED,timer=2681,.*platform=00000000,action=00001300,used=80345918,warp=80345918,.*floor=00000000,owner=00000000,' "$trace"
        grep -q '^DEMO_TOP_RETIRED,timer=2701,.*top=803451f8,.*topActive=0,platform=00000000,' "$trace"
        grep -q '^DEMO_RESULT,setup=1,warp=1,retired=1,area2=0$' "$trace"
        if grep -Eq '^DEMO_(APPLY_ENTRY|APPLY_RETURN|ARRIVAL),' "$trace"; then exit 3; fi
        printf '2785\n' >"$out/render-frames.txt"
        ;;
    candidate)
        low="$4,$5,$6"
        high="$7,$8,$9"
        grep -q "^DEMO_SETUP,timer=$setup_timer,.*state=($low),collision=($low),display=($high)$" "$trace"
        grep -q "^DEMO_FIRST_FLOOR,timer=$setup_timer,.*floor=00000000,owner=00000000," "$trace"
        grep -q "^DEMO_RETRY_FLOOR,timer=$setup_timer,.*owner=803451f8,.*state=($high),collision=($low)," "$trace"
        grep -q "^DEMO_WARP_ACCEPTED,timer=$((setup_timer + 1)),.*platform=803451f8,action=00001300,used=80345918,warp=80345918,.*owner=803451f8," "$trace"
        grep -q '^DEMO_APPLY_ENTRY,.*area=2,.*state=(0,5500,256),' "$trace"
        grep -q '^DEMO_APPLY_RETURN,.*area=2,' "$trace"
        grep -q '^DEMO_RESULT,setup=1,warp=1,retired=[01],area2=1$' "$trace"
        printf '2785\n' >"$out/render-frames.txt"
        ;;
    *) printf 'unknown capture mode %s\n' "$mode" >&2; exit 2 ;;
esac

diff -u "$out/render-frames.txt" \
    <(sed -n 's/.*Captured screenshot for frame \([0-9][0-9]*\)\..*/\1/p' "$out/raw.log")
expected=$(wc -l <"$out/render-frames.txt")
actual=$(find "$out/shots" -maxdepth 1 -name '*.png' | wc -l)
if [ "$actual" -ne "$expected" ]; then
    printf 'incomplete recording: %s of %s frames\n' "$actual" "$expected" >&2
    exit 3
fi
