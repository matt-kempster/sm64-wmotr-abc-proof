#!/usr/bin/env bash
# Memory-capped build wrapper. Sets RLIMIT_AS so a runaway coqc dies gracefully
# (OCaml Out_of_memory -> non-zero exit) instead of taking down WSL via OOM.
# No sudo needed. WSL2 here is capped at 8GB; we cap coqc virtual at ~6.5GB,
# leaving the VM ~1.5GB + 4GB swap of headroom.
#
# Usage: bash pipeline/capbuild.sh [CAP_KB] -- <make target ...>
#    or: bash pipeline/capbuild.sh <make target ...>   (uses default cap)
set -u
DEFAULT_CAP_KB=6815744   # 6.5 GiB
CAP_KB="$DEFAULT_CAP_KB"
if [[ "${1:-}" =~ ^[0-9]+$ ]]; then CAP_KB="$1"; shift; fi
if [[ "${1:-}" == "--" ]]; then shift; fi
cd /home/matt/git/sm64-wmotr-abc-proof
source pipeline/env.sh 2>/dev/null || eval "$(opam env --switch=sm64-proof 2>/dev/null)"
ulimit -v "$CAP_KB"
echo "[capbuild] ulimit -v (KB): $(ulimit -v)   targets: $*"
nice -n 10 make -f CoqMakefile "$@"
rc=$?
echo "[capbuild] make exit: $rc"
exit $rc
