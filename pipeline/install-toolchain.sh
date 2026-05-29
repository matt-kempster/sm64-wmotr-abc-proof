#!/usr/bin/env bash
# One-shot toolchain installer for the sm64-proof opam switch.
#
# Prereqs that need sudo (run once, manually):
#   sudo apt-get install -y libgmp-dev        # gmp.h, needed by zarith -> coq-core
#
# Then: pipeline/install-toolchain.sh
set -euo pipefail

SWITCH="${SM64_PROOF_SWITCH:-sm64-proof}"
export OPAMCOLOR=never OPAMYES=1

if ! command -v gcc >/dev/null || ! echo '#include <gmp.h>' | gcc -E - >/dev/null 2>&1; then
  echo "ERROR: gmp.h not found. First run: sudo apt-get install -y libgmp-dev" >&2
  exit 1
fi

# Create the switch on OCaml 4.14 (coq-compcert requires ocaml < 5) if missing.
if ! opam switch list --short | grep -qx "$SWITCH"; then
  opam switch create "$SWITCH" ocaml-base-compiler.4.14.2 --no-switch
fi

# coq-compcert + coq-flocq live in the coq-released repo; attach it to THIS switch.
opam repo add coq-released https://coq.inria.fr/opam/released --switch "$SWITCH" || true

# Pin a known-good version (resolves to coq 8.19.2, coq-flocq 4.2.2).
opam install coq-compcert.3.15 --switch "$SWITCH"

echo "=== verify ==="
opam exec --switch "$SWITCH" -- sh -c '
  command -v clightgen && clightgen -version | head -1
  command -v coqc      && coqc --version      | head -1
'
echo "Toolchain ready. Activate with: source pipeline/env.sh"
