#!/usr/bin/env bash
# Type-check ONE .v file (its deps must already be built) WITH timing + hang
# localization, WITHOUT flooding the terminal.
#
#   bash pipeline/check.sh proofs/ActionValue.v
#   CHECK_TIMEOUT=120 bash pipeline/check.sh proofs/ActionValue.v   # custom limit (s)
#
# Why this exists (three traps it removes):
#   1. It sources pipeline/env.sh, so the opam switch is ALWAYS active -- a
#      switch-less `coqc` prints a false RC and "[NOTE] --set-switch"; building
#      off that has caused non-compiling commits. Here it cannot happen.
#   2. It runs `coqc -time` into a LOG file, not the terminal, then prints only
#      a short summary -- so a 1000-line file's per-sentence timing never floods
#      the conversation.
#   3. It runs under `timeout`, so a hang is bounded and LOCALIZED: on timeout
#      the last COMPLETED sentence is printed; the next one is what hung.
#
# Exit code == coqc's RC (0 ok, 124 timeout, else Coq error). Full per-sentence
# timing stays in pipeline/_check_time.log. Deps must already be built
# (run `bash pipeline/build.sh` first, or after editing an upstream file).
set -uo pipefail
cd "$(dirname "$0")/.."
# shellcheck disable=SC1091
source pipeline/env.sh

LOG=pipeline/_check_time.log
LIMIT="${CHECK_TIMEOUT:-600}"

: > "$LOG"
timeout "${LIMIT}" coqc -time -R generated SM64.Generated -R proofs SM64.Proofs "$@" > "$LOG" 2>&1
RC=$?

echo "RC=${RC}  (limit ${LIMIT}s; full timing -> ${LOG})"

if [ "${RC}" -eq 0 ]; then
  echo "OK -- 5 slowest sentences:"
  grep ' secs' "${LOG}" \
    | awk '{for (i=1;i<=NF;i++) if ($i=="secs") print $(i-1) "s\t" $0}' \
    | sort -rn | head -5
elif [ "${RC}" -eq 124 ]; then
  echo "TIMEOUT after ${LIMIT}s -- last sentence COMPLETED before the hang:"
  grep ' secs' "${LOG}" | tail -1
  echo "(the NEXT sentence after that one is what hung -- raise CHECK_TIMEOUT to get further)"
else
  echo "FAILED -- error context:"
  grep -v -e '^Warning' -e 'cannot-open' "${LOG}" | grep -iE -B2 -A4 'error' | head -25
fi

exit "${RC}"
