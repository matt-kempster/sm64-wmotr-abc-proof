#!/usr/bin/env bash
set -euo pipefail
here="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
export WAFEL_PILOT_PROBE="$here/probe.c"
exec bash "$here/../wafel-jp-pilot/capture.sh" "$@"
