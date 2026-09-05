#!/usr/bin/env bash
# Check one active SSL proof with timing, the correct namespace and a bounded
# memory/time budget.  Dependencies must already have been built.
set -euo pipefail
cd "$(dirname "$0")/.."
source pipeline/env.sh
limit="${CHECK_TIMEOUT:-120}"
cap="${SM64_PROOF_VCAP_KB:-6815744}"
if [ "$cap" != 0 ]; then ulimit -S -v "$cap"; fi
mkdir -p build/check
log="build/check/$(basename "${1:?usage: check.sh proofs/File.v}" .v).log"
set +e
timeout "$limit" coqc -time -R generated LessThanOneAPress.Generated \
  -R proofs LessThanOneAPress.Proofs "$@" >"$log" 2>&1
result=$?
set -e
printf 'Result: %s; time limit: %ss; timing log: %s\n' "$result" "$limit" "$log"
tail -n 12 "$log"
exit "$result"
