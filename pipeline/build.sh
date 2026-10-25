#!/usr/bin/env bash
# Single-command build wrapper: activates the toolchain switch, then runs make.
# Exists so the whole build is ONE command (no `source && make | tail` chain),
# which the permission allowlist can match as a unit -> no approval prompts.
#
#   bash pipeline/build.sh            # == make (all)
#   bash pipeline/build.sh proofs     # == make proofs
#
# Opt-in speedups (the plain forms above are unchanged; the audit and CI use them):
#
#   bash pipeline/build.sh --quick [-jN] [targets]
#       FAST ITERATION: coqc -vos -> .vos files (statements; Qed/Admitted bodies
#       are SKIPPED, not checked).  No targets / `proofs` = every file
#       (CoqMakefile `vos`); `X.vo` or `X.v` targets become `X.vos`.  Checks that
#       statements and consumers line up.  Proves NOTHING: never commit on it.
#   bash pipeline/build.sh --vok [-jN] [targets]
#       check the Qed bodies of the named files against their deps' .vos
#       (`X.vo`/`X.v` -> `X.vok`; no targets = CoqMakefile `vok`, i.e. all).
#   SM64_VO_CACHE=$HOME/.cache/sm64-vo bash pipeline/build.sh [-jN] [targets]
#       SHARED .vo CACHE across worktrees (pipeline/coqc_cache.py): a file whose
#       source, coqc argv, toolchain and dependency .vo bytes all match an earlier
#       successful compile gets that compile's outputs copied in instead of being
#       recompiled.  Add --no-cache (or SM64_VO_CACHE=off) to bypass it.
#       Size management: bash pipeline/vo_cache_gc.sh [GB].
set -euo pipefail
cd "$(dirname "$0")/.."
source pipeline/memcap.sh "$PWD/pipeline/build.sh" "$@"
# shellcheck disable=SC1091
source pipeline/env.sh

mode=full; nocache=0; plain=1
for a in "$@"; do
  case "$a" in
    --quick) mode=quick; plain=0 ;;
    --vok) mode=vok; plain=0 ;;
    --no-cache) nocache=1; plain=0 ;;
  esac
done
cache="${SM64_VO_CACHE:-}"
case "$cache" in off|OFF|0|no) cache="" ;; esac
[ "$nocache" -eq 1 ] && cache=""

# The default path: exactly `make "$@"`, as before.
if [ "$plain" -eq 1 ] && [ -z "$cache" ]; then
  exec make "$@"
fi
if [ -z "$cache" ]; then unset SM64_VO_CACHE; fi

# split the remaining args into make flags and targets
flags=(); targets=(); prev=""
for a in "$@"; do
  case "$a" in --quick|--vok|--no-cache) continue ;; esac
  if [ "$prev" = val ]; then flags+=("$a"); prev=""; continue; fi
  if [ "$prev" = j ]; then
    prev=""
    if [[ "$a" =~ ^[0-9]+$ ]]; then flags+=("$a"); continue; fi
  fi
  case "$a" in
    -f|-C|-o|-W|-I) flags+=("$a"); prev=val ;;
    -j) flags+=("$a"); prev=j ;;
    -*|*=*) flags+=("$a") ;;
    *) targets+=("$a") ;;
  esac
done

if [ "$mode" = quick ] || [ "$mode" = vok ]; then
  ext=vos; [ "$mode" = vok ] && ext=vok
  # drop any -f/-C pair the caller passed: the .vos/.vok rules live in CoqMakefile
  mflags=(); skip=0
  for f in ${flags[@]+"${flags[@]}"}; do
    if [ "$skip" -eq 1 ]; then skip=0; continue; fi
    case "$f" in -f|-C) skip=1 ;; *) mflags+=("$f") ;; esac
  done
  mtargets=()
  for t in ${targets[@]+"${targets[@]}"}; do
    case "$t" in
      proofs|all) mtargets+=("$ext") ;;
      *.vo|*.vos|*.vok) mtargets+=("${t%.*}.$ext") ;;
      *.v) mtargets+=("${t%.v}.$ext") ;;
      *) mtargets+=("$t") ;;
    esac
  done
  [ "${#mtargets[@]}" -eq 0 ] && mtargets=("$ext")
  make CoqMakefile >/dev/null
  echo "[build.sh] --$mode: make -f CoqMakefile ${mflags[*]:-} ${mtargets[*]}"
  [ "$mode" = quick ] && echo "[build.sh] NOTE: .vos skips Qed bodies -- this checks statements only, not proofs."
  exec make -f CoqMakefile ${mflags[@]+"${mflags[@]}"} "${mtargets[@]}"
fi

# full build through the shared .vo cache
if [ -n "$cache" ]; then
  export SM64_VO_CACHE="$cache"
  SM64_VO_CACHE_TOOLCHAIN="$(python3 -B -c 'import sys,shutil; sys.path.insert(0,"pipeline"); import coqc_cache as c; print(c.toolchain_fp(shutil.which("coqc")))')"
  export SM64_VO_CACHE_TOOLCHAIN
  echo "[build.sh] .vo cache: $SM64_VO_CACHE (bypass: --no-cache)"
  exec make COQC="$PWD/pipeline/coqc_cache.py" ${flags[@]+"${flags[@]}"} ${targets[@]+"${targets[@]}"}
fi
exec make ${flags[@]+"${flags[@]}"} ${targets[@]+"${targets[@]}"}
