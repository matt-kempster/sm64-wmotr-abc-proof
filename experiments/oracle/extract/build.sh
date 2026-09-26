#!/usr/bin/env bash
# Compile the extracted interpreter (ml/, from `bash pipeline/build.sh
# oracle-extract`) and link a driver from drv/:  bash build.sh introspect
set -euo pipefail
cd "$(dirname "$0")"
source ../../../pipeline/env.sh >/dev/null
ulimit -s unlimited
ORDER=$(cd ml && ocamlfind ocamldep -sort *.ml)
for f in $ORDER; do
  [ ml/${f%.ml}.cmx -nt ml/$f ] || (cd ml && ocamlfind ocamlopt -w -a -c ${f%.ml}.mli $f)
done
cd drv
ocamlfind ocamlopt -w -a -I ../ml -c util.ml
DRV_DEPS=${DRV_DEPS:-}
for d in $DRV_DEPS; do ocamlfind ocamlopt -w -a -I ../ml -c $d.ml; done
ocamlfind ocamlopt -w -a -I ../ml -c "$1.ml"
ocamlfind ocamlopt -w -a -package zarith,unix -linkpkg -o "$1" \
  $(for f in $ORDER; do echo ../ml/${f%.ml}.cmx; done) util.cmx \
  $(for d in $DRV_DEPS; do echo $d.cmx; done) "$1.cmx"
