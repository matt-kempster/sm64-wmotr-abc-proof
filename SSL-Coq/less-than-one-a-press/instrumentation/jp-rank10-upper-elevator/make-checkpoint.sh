#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 /path/to/authentic/baserom.jp.z64 [state-path]}"
state="${2:-$project_dir/build/instrumentation/rank10-area1-disappeared.st}"

mkdir -p "$(dirname -- "$state")"
RANK10_USE_DEBUG=0 RANK10_NO_DEBUG=1 RANK10_EMUMODE=2 \
RANK10_SAVE_STATE="$state" \
    bash "$script_dir/run.sh" "$rom" 2850 0
test -s "$state"
printf 'Rank-10 checkpoint: %s\n' "$state"
