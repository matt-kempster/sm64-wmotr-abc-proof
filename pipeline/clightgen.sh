#!/usr/bin/env bash
# Reusable pipeline step: run CompCert clightgen on a C translation unit and emit a
# Clight AST as a Rocq .v file into generated/, stamped with a DO-NOT-EDIT header.
#
# Determinism: the header is fixed text, so re-running this on the same input + same
# clightgen version yields a byte-identical file. That is what makes the committed
# generated/*.v auditable ("regenerate and diff").
#
# Usage:
#   pipeline/clightgen.sh <input.c> <output.v> [extra clightgen args...]
#
# Example (M0):
#   pipeline/clightgen.sh experiments/toy/toy.c generated/toy.v
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "usage: $0 <input.c> <output.v> [extra clightgen args...]" >&2
  exit 2
fi

INPUT="$1"; OUTPUT="$2"; shift 2

if ! command -v clightgen >/dev/null 2>&1; then
  echo "clightgen not on PATH. Run: source pipeline/env.sh" >&2
  exit 1
fi

CGVERSION="$(clightgen -version 2>/dev/null | head -1 || echo 'unknown')"
TMP="$(mktemp --suffix=.v)"
trap 'rm -f "$TMP"' EXIT

# -normalize: put memory accesses in normalized form, recommended for program proof.
clightgen -normalize "$@" -o "$TMP" "$INPUT"

# Stringlit disambiguation: clightgen names compiler-generated string-literal
# constants __stringlit_N, numbered PER TU -- so any two TUs containing string
# literals define colliding non-public Gvars, and CompCert's link_prog refuses
# to link them (the public gate).  Prefix them with the TU name.  This is a
# deterministic, purely mechanical rename of TU-local (static) symbols; it
# changes no semantics and no public symbol.  (Found by the linked12
# inhabitation probe, 2026-07-08: the ONLY link obstruction across the twelve
# TUs was exactly these ids.)
TUNAME="$(basename "$OUTPUT" .v)"
sed -i "s/\\\$\"__stringlit_/\\\$\"__stringlit_${TUNAME}_/g" "$TMP"

# Anonymous-composite canonicalization: clightgen numbers anonymous C
# structs/unions per TU, making structurally identical shared composites
# (Controller/Object/Surface, via ultra64's typedef'd anonymous structs)
# syntactically unequal across TUs -- CompCert's equality-based composite
# linker then refuses the link.  Rename them to structural-hash names
# (identical structure => identical name in every TU).  Deterministic,
# content-only, per-file.  See pipeline/canonicalize_anon.py.
python3 "$(dirname "$0")/canonicalize_anon.py" "$TMP"

# Extern-incomplete-array completion (documented one-entry table): C's
# `extern struct MarioState gMarioStates[];` yields Tarray..0 while the
# definer (level_update.c) has Tarray..1 -- CompCert's equality-based
# vardef linker refuses.  Complete the DECL side to the definer's type
# (exactly what a system linker's symbol resolution does; init stays nil,
# link_varinit takes the definer's).  Found by the linked12 certificate.
python3 - "$TMP" <<'PYEOF'
import re, sys
path = sys.argv[1]
s = open(path).read()
s2 = re.sub(
    r'(Definition v_gMarioStates := \{\|\s*gvar_info := \(tarray \(Tstruct _MarioState noattr\)) 0\)',
    r'\1 1)', s)
if s2 != s:
    open(path, 'w').write(s2)
    print(f"extern-array completion: gMarioStates 0 -> 1 in {path}")
PYEOF

{
  echo "(* ======================================================================"
  echo "   GENERATED FILE -- DO NOT EDIT."
  echo "   Produced by: pipeline/clightgen.sh"
  echo "   From source: $INPUT"
  echo "   clightgen:   $CGVERSION"
  echo "   Flags:       -normalize $* (+ __stringlit_ -> __stringlit_${TUNAME}_)"
  echo "   Regenerate:  make regen   (output must be byte-identical)"
  echo "   ====================================================================== *)"
  cat "$TMP"
} > "$OUTPUT"

echo "wrote $OUTPUT (from $INPUT, $CGVERSION)"
