#!/usr/bin/env bash
# Compile a single Rocq .v file against the project's logical-path map, activating
# the toolchain switch first. ONE command (no `cd`, no `&&`/`;` chain) so the
# permission allowlist can match `bash pipeline/check.sh *` as a unit -> no prompt.
#
#   bash pipeline/check.sh proofs/ActionWriters.v
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck disable=SC1091
source pipeline/env.sh
exec coqc -R generated SM64.Generated -R proofs SM64.Proofs "$@"
