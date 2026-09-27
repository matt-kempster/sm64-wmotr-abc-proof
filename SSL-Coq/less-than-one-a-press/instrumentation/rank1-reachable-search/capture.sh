#!/usr/bin/env bash
set -euo pipefail
script_dir="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
export WAFEL_PILOT_PROBE="$script_dir/probe.c"
# Optional RANK1_SEARCH_FIRST/END select input-poll checkpoints, not top timers.
exec bash "$script_dir/../wafel-jp-pilot/capture.sh" "$@"
