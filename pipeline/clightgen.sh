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

# Extern-incomplete-array completion (documented table, TRUST 2.4): C's
# `extern struct MarioState gMarioStates[];` yields Tarray..0 while the
# definer (level_update.c) has Tarray..1 -- CompCert's equality-based
# vardef linker refuses.  Complete the DECL side to the definer's type
# (exactly what a system linker's symbol resolution does; init stays nil,
# link_varinit takes the definer's).  Found by the linked12 certificate.
#   gMarioStates  0 -> 1     (definer: level_update.c, NUM_MARIOS = 1)
#   gSineTable    0 -> 5120  (definer: math_util.c via trig_tables.inc.c,
#                             0x1000 + 0x400 f32 entries; found when
#                             linking math_util, 2026-10-17)
#   gDebugInfo    0 -> 16    (definer: object_list_processor.c, s16[16][8];
#                             found when linking it, 2026-10-20)
#   gDecompressionHeap     0 -> 53248  (definer: buffers.c, u8[0xD000];
#                                       declared in memory.c)
#   gGfxSPTaskStack        0 -> 1024   (definer: buffers.c; declared in game_init.c)
#   gGfxSPTaskYieldBuffer  0 -> 3072   (definer: buffers.c; declared in game_init.c)
#   gLevelToCourseNumTable 0 -> 38     (definer: save_file.c, s8[LEVEL_COUNT - 1];
#                                       declared in level_update.c)
#                             all four found when linking buffers.c and
#                             save_file.c, 2026-10-21
python3 - "$TMP" <<'PYEOF'
import re, sys
path = sys.argv[1]
s = open(path).read()
TABLE = [
    ("gMarioStates", r"\(Tstruct _MarioState noattr\)", 1),
    ("gSineTable", r"tfloat", 5120),
    ("gDebugInfo", r"\(tarray tshort 8\)", 16),
    ("gDecompressionHeap", r"tuchar", 53248),
    ("gGfxSPTaskStack", r"tuchar", 1024),
    ("gGfxSPTaskYieldBuffer", r"tuchar", 3072),
    ("gLevelToCourseNumTable", r"tschar", 38),
]
for name, elt, n in TABLE:
    s2 = re.sub(
        r'(Definition v_' + name + r' := \{\|\s*gvar_info := \(tarray ' + elt + r') 0\)',
        r'\g<1> ' + str(n) + ')', s)
    if s2 != s:
        s = s2
        open(path, 'w').write(s)
        print(f"extern-array completion: {name} 0 -> {n} in {path}")
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
