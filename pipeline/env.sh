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
echo "Activated opam switch '$SM64_PROOF_SWITCH'."
command -v clightgen >/dev/null && echo "  clightgen: $(command -v clightgen)"
command -v coqc      >/dev/null && echo "  coqc:      $(coqc --version | head -1)"
