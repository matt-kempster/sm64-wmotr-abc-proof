#!/usr/bin/env bash
# Source this (`source pipeline/env.sh`) to put the dedicated sm64-proof opam switch
# (Rocq + CompCert + clightgen) on your PATH for the current shell.
#
# It does NOT change your global/default switch; it only affects this shell.
SM64_PROOF_SWITCH="${SM64_PROOF_SWITCH:-sm64-proof}"

if ! opam switch list --short 2>/dev/null | grep -qx "$SM64_PROOF_SWITCH"; then
  echo "opam switch '$SM64_PROOF_SWITCH' not found. Create it with:" >&2
  echo "  opam repo add coq-released https://coq.inria.fr/opam/released" >&2
  echo "  opam switch create $SM64_PROOF_SWITCH ocaml-base-compiler.5.2.0 --no-switch" >&2
  echo "  opam install coq-compcert" >&2
  return 1 2>/dev/null || exit 1
fi

eval "$(opam env --switch "$SM64_PROOF_SWITCH" --set-switch)"

# generated/mario_anim_data.v is one ~210k-element initializer list; coqc
# overflows the default stack on it, and on Print Assumptions over terms that
# mention it ("Error: Stack overflow").  Raise the system stack and OCaml 5's
# stack limit (in words) for every pipeline driver (all source this file).
ulimit -S -s unlimited 2>/dev/null || ulimit -S -s "$(ulimit -H -s)" 2>/dev/null || true
export OCAMLRUNPARAM="${OCAMLRUNPARAM:-l=1000000000}"
echo "Activated opam switch '$SM64_PROOF_SWITCH'."
command -v clightgen >/dev/null && echo "  clightgen: $(command -v clightgen)"
command -v coqc      >/dev/null && echo "  coqc:      $(coqc --version | head -1)"

# --- WSL OOM guardrail (no sudo required) -----------------------------------
# This dev box is WSL2 capped at memory=48GB (was 8GB until 2026-10-16) (see /mnt/c/Users/<you>/.wslconfig).
# Some heavy coqc proof terms (notably AutomaticLeafSurface.v) can balloon past
# 7GB RSS, which leaves WSL no headroom and takes the whole VM down via memory
# pressure -- observed twice.  A SOFT RLIMIT_AS (address-space) cap makes a
# runaway coqc hit its OWN allocation failure first (OCaml `Out_of_memory`,
# non-zero exit) instead of the kernel OOM-killer / WSL crash.  It is a *soft*
# limit (hard stays unlimited) so a deliberate one-off can override it with:
#     ulimit -S -v unlimited
# Tune via SM64_PROOF_VCAP_KB (KiB); set =0 to disable.  Default 24 GiB leaves
# WSL plenty of headroom (was 6.5 GiB on the old 8GB box).
# NOTE: this is intentionally BELOW the current AutomaticLeafSurface.v peak --
# that proof must be split so its peak fits under the cap (work in progress).
SM64_PROOF_VCAP_KB="${SM64_PROOF_VCAP_KB:-25165824}"
if [ "$SM64_PROOF_VCAP_KB" != "0" ]; then
  ulimit -S -v "$SM64_PROOF_VCAP_KB" 2>/dev/null \
    && echo "  vcap:      ulimit -S -v ${SM64_PROOF_VCAP_KB} KiB (disable: SM64_PROOF_VCAP_KB=0)"
fi
