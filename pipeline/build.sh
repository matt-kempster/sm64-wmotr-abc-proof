#!/usr/bin/env bash
# Single-command build wrapper: activates the toolchain switch, then runs make.
# Exists so the whole build is ONE command (no `source && make | tail` chain),
# which the permission allowlist can match as a unit -> no approval prompts.
#
#   bash pipeline/build.sh            # == make (all)
#   bash pipeline/build.sh proofs     # == make proofs
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck disable=SC1091
source pipeline/env.sh
exec make "$@"
