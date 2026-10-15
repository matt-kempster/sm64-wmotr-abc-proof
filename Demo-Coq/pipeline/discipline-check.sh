#!/usr/bin/env bash
# Demo adaptation of the legacy proof-discipline audit. See docs/proof-audit.md.
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${1:-}" == --help || "${1:-}" == -h ]]; then
  exec python3 pipeline/discipline_audit.py --help
fi
source pipeline/env.sh
proof_memory_cap="${SM64_PROOF_VCAP_KB:-6815744}"
if [ "$proof_memory_cap" != 0 ]; then ulimit -S -v "$proof_memory_cap"; fi
exec python3 pipeline/discipline_audit.py "$@"
