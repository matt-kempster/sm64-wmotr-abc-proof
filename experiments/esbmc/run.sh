#!/usr/bin/env bash
# Run an ESBMC harness against the unmodified decomp, with the same -I/-D set
# the clightgen pipeline uses (Makefile SM64 flags), 32-bit big-endian like the N64.
# Usage: experiments/esbmc/run.sh <harness.c> <decomp .c files...> [-- extra esbmc args]
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SM64="$ROOT/vendor/sm64"
ESBMC="${ESBMC:-$HOME/tools/esbmc/release/bin/esbmc}"
FILES=(); EXTRA=()
seen_dd=0
for a in "$@"; do
  if [ "$a" = "--" ]; then seen_dd=1; continue; fi
  if [ $seen_dd = 1 ]; then EXTRA+=("$a"); else FILES+=("$a"); fi
done
exec "$ESBMC" "${FILES[@]}" \
  -I"$SM64/include" -I"$SM64/build/us" -I"$SM64/build/us/include" -I"$SM64/src" -I"$SM64" -I"$SM64/include/libc" \
  -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1 -D_FINALROM=1 -DTARGET_N64=1 \
  -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 \
  --32 --big-endian --unwind 5 --no-unwinding-assertions \
  --no-pointer-check --no-bounds-check --no-div-by-zero-check --no-align-check \
  "${EXTRA[@]}"
