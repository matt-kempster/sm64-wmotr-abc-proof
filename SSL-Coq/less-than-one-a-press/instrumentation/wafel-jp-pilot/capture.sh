#!/usr/bin/env bash
set -euo pipefail
script_dir="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: capture.sh /path/to/authentic/baserom.jp.z64 [controller.inputs]}"
shots=2850
if [[ -n "${2:-}" ]]; then
    export WAFEL_PILOT_INPUTS="$(realpath "$2")"
    # The pinned emulator's testshots N produces N+2 controller polls.
    shots="$(( $(wc -l < "$WAFEL_PILOT_INPUTS") - 2 ))"
else
    unset WAFEL_PILOT_INPUTS
fi
python3 "$project_dir/instrumentation/jp-ranks13-18/verify.py" "$rom"
bash "$project_dir/instrumentation/jp-rank5-state-split/verify.sh" "$rom"
out="$(mktemp -d "$project_dir/build/wafel-pilot/capture.XXXXXX")"
mkdir -p "$out/config" "$out/data" "$out/shots"
gcc -shared -fPIC -std=c99 -Wall -Wextra -Werror -O2 \
    -DALLOW_SETUP_A=0 -DSEARCH_MODE=12 \
    -DRANK1_BOUNDARY_AUDIT=1 -DRANK1_BOUNDARY_REPEAT_UNTIL=349 \
    -DRANK5_STATE_SPLIT_AUDIT=1 -DRANK13_18_COPY_AUDIT=1 \
    "${WAFEL_PILOT_PROBE:-$script_dir/capture.c}" -ldl -lm -o "$out/probe.so"
printf 'Output: %s\n' "$out"
printf 'run\n' | XDG_CONFIG_HOME="$out/config" XDG_DATA_HOME="$out/data" \
    LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a "${MUPEN64PLUS:-/usr/games/mupen64plus}" \
        --debug --emumode 0 --nosaveoptions --nospeedlimit \
        --audio dummy --input "$out/probe.so" --gfx mupen64plus-video-rice.so \
        --rsp mupen64plus-rsp-hle.so --cheats 6 --sshotdir "$out/shots" \
        --testshots "$shots" "$rom" >"$out/raw.log" 2>&1
grep -a '^WARP_ACCEPT_' "$out/raw.log" >"$out/receipt.txt"
grep -a '^RANK5_' "$out/raw.log" >"$out/rank5.txt"
grep -a '^RANK13_' "$out/raw.log" >"$out/rank13.txt"
if [[ -z "${WAFEL_PILOT_INPUTS:-}" ]]; then
    diff --strip-trailing-cr -u "$project_dir/instrumentation/jp-rank5-state-split/expected-state-split-receipt.txt" "$out/rank5.txt"
    diff --strip-trailing-cr -u "$project_dir/instrumentation/jp-ranks13-18/expected-copy-interaction-receipt.txt" "$out/rank13.txt"
    python3 "$project_dir/instrumentation/jp-warp-acceptance/check.py" "$out/receipt.txt" "$out/raw.log"
    diff --strip-trailing-cr -u "$project_dir/instrumentation/jp-warp-acceptance/expected-receipt.txt" "$out/receipt.txt"
fi
grep -a '^WAFEL_PILOT,' "$out/raw.log" | cut -d, -f2- >"$out/inputs.jsonl"
if [[ -n "${WAFEL_PILOT_INPUTS:-}" ]]; then
    python3 - "$WAFEL_PILOT_INPUTS" "$out/inputs.jsonl" <<'PY'
import json, pathlib, sys
expected = [[int(v) for v in line.split()] for line in pathlib.Path(sys.argv[1]).read_text().splitlines()]
rows = [json.loads(line) for line in pathlib.Path(sys.argv[2]).read_text().splitlines()]
assert expected == [[r['poll'], r['buttons'], *r['stick']] for r in rows]
print('Controller schedule reproduced exactly. Run replay.py for field comparison; no baseline-warp verdict is claimed for this branch.')
PY
fi
printf 'Inputs: %s\n' "$out/inputs.jsonl"
