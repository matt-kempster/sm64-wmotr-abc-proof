#!/usr/bin/env bash
set -euo pipefail

SWITCH="${SM64_ITEM_SWITCH:-sm64-item-proof}"
export OPAMYES=1 OPAMCOLOR=never

if ! command -v opam >/dev/null 2>&1; then
  echo "opam is not on PATH" >&2
  exit 1
fi

if ! opam switch list --short | grep -qx "$SWITCH"; then
  opam switch create "$SWITCH" ocaml-base-compiler.4.14.2 --no-switch
fi

opam repo add coq-released https://coq.inria.fr/opam/released \
  --switch "$SWITCH" || true
opam install coq-compcert.3.15 --switch "$SWITCH"

PREFIX="$(opam var --switch "$SWITCH" prefix)"
SRC="$PREFIX/.opam-switch/sources/coq-compcert.3.15"

opam exec --switch "$SWITCH" -- bash -c "
  set -euo pipefail
  cd '$SRC'
  ./configure ppc-eabi -clightgen -use-external-Flocq \
    -use-external-MenhirLib \
    -prefix '$PREFIX' \
    -coqdevdir '$PREFIX/lib/coq/user-contrib/compcert'
  sed -i \
    's/^HAS_RUNTIME_LIB=true/HAS_RUNTIME_LIB=false/;
     s/^INSTALL_COQDEV=false/INSTALL_COQDEV=true/' \
    Makefile.config
  sed -i \
    's|^[[:space:]]*\$(MAKE) -C runtime install|\t@echo skip-runtime-install|' \
    Makefile
  make clean >/dev/null 2>&1 || true
  make depend
  make -j4 proof
  make clightgen
  make ccomp
  make compcert.config
  rm -rf '$PREFIX/lib/coq/user-contrib/compcert'
  make install
"

opam exec --switch "$SWITCH" -- bash -c '
  clightgen -version | head -1
  coqc --version | head -1
  printf "%s\n" \
    "From compcert Require Import Archi." \
    "Goal Archi.ptr64 = false /\ Archi.big_endian = true." \
    "Proof. vm_compute. split; reflexivity. Qed." \
    > /tmp/sm64_item_archi_check.v
  coqc /tmp/sm64_item_archi_check.v
  echo "ARCHI OK: 32-bit pointers, big-endian"
'
