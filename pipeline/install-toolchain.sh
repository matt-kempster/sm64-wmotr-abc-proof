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
# NOTE: this installs CompCert configured for the HOST arch (x86_64 -> 64-bit,
# little-endian). We then REBUILD it for ppc-eabi below, because SM64 targets the
# N64 (32-bit, big-endian): pointer size and endianness change struct field
# offsets, and the proofs depend on the faithful (ppc32) layout.
opam install coq-compcert.3.15 --switch "$SWITCH"

# --- Rebuild CompCert (Coq libs + clightgen) for ppc-eabi (N64-faithful) -------
# ppc-eabi is 32-bit (ptr64=false) and big-endian -- the closest CompCert backend
# to the N64's MIPS o32 ABI (CompCert has no MIPS backend). The runtime C library
# is skipped (it needs a ppc cross-assembler we don't have, and we never run ccomp).
PREFIX="$(opam var --switch "$SWITCH" prefix)"
SRC="$PREFIX/.opam-switch/sources/coq-compcert.3.15"
echo "=== reconfiguring CompCert for ppc-eabi in $SRC ==="
opam exec --switch "$SWITCH" -- bash -c "
  set -euo pipefail
  cd '$SRC'
  ./configure ppc-eabi -clightgen -use-external-Flocq -use-external-MenhirLib \
    -prefix '$PREFIX' -coqdevdir '$PREFIX/lib/coq/user-contrib/compcert'
  # don't build/install the C runtime lib (no cross-asm); do install the Coq dev
  sed -i 's/^HAS_RUNTIME_LIB=true/HAS_RUNTIME_LIB=false/; s/^INSTALL_COQDEV=false/INSTALL_COQDEV=true/' Makefile.config
  sed -i 's|\t\$(MAKE) -C runtime install|\t@echo skip-runtime-install|' Makefile
  make clean >/dev/null 2>&1 || true
  make depend
  make -j\"\$(nproc)\" proof clightgen ccomp
  make compcert.config
  rm -rf '$PREFIX/lib/coq/user-contrib/compcert'
  make install
"

echo "=== verify (expect powerpc, ptr64=false, big_endian=true) ==="
opam exec --switch "$SWITCH" -- sh -c '
  command -v clightgen && clightgen -version | head -1
  command -v coqc      && coqc --version      | head -1
'
opam exec --switch "$SWITCH" -- bash -c '
  printf "From compcert Require Import Archi.\nGoal Archi.ptr64 = false /\\ Archi.big_endian = true.\nProof. vm_compute. split; reflexivity. Qed.\n" > /tmp/_archi_check.v
  coqc /tmp/_archi_check.v && echo "ARCHI OK: ppc32 big-endian (N64-faithful)"
'
echo "Toolchain ready. Activate with: source pipeline/env.sh"
