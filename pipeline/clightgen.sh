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
#   gPlayerSpawnInfos      0 -> 1      (definer: area.c, struct SpawnInfo[1];
#                                       declared in mario.c, level_update.c;
#                                       found when linking area.c, 2026-10-21)
#   gObjectPool            0 -> 240    (definer: object_list_processor.c,
#                                       struct Object[OBJECT_POOL_CAPACITY];
#                                       declared in spawn_object.c; found when
#                                       linking it, 2026-10-21)
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
    ("gPlayerSpawnInfos", r"\(Tstruct _SpawnInfo noattr\)", 1),
    ("gObjectPool", r"\(Tstruct _Object noattr\)", 240),
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

# Unlinked-definer storage completion (TRUST 2.4, 2026-10-22; the same class
# as the table above).  These globals are DECLARED (complete type, `extern`)
# by linked TUs and DEFINED only in a TU outside the link.  With every
# declaration's init nil, the linked program keeps nil and Genv.init_mem gives
# them a SIZE-0 block, so every load / store through them has no CompCert
# execution (tools/size0_globals.py lists them).  Each real definition is
# zero-initialised (BSS, or an explicit 0 / NULL / 0.0f / FALSE /
# DIALOG_RESPONSE_NONE initializer, all-zero bytes), so the DECL side gets
# the definer's storage as a common definition `Init_space sizeof`: CompCert's
# link_varinit merges equal-size commons, and links one with the real
# definition if that TU ever joins.  Sizes are sizeof of the declared type
# (ppc32 layout); BootRun.completed_sizes re-checks each against the linked
# composite env.  (camera.c's globals -- gPlayerCameraState, gCamera,
# gCameraMovementFlags, gCutsceneFocus -- are not here: camera.c is linked.)
# Defining file:line, in vendor/sm64:
#   gBodyStates            80  src/game/mario_misc.c:73  [2] x 40
#   gCurGraphNodeRoot       4  src/game/rendering_graph_node.c:120  = NULL
#   gCurGraphNodeMasterList 4  src/game/rendering_graph_node.c:121  = NULL
#   gCurGraphNodeCamFrustum 4  src/game/rendering_graph_node.c:122  = NULL
#   gCurGraphNodeCamera     4  src/game/rendering_graph_node.c:123  = NULL
#   gCurGraphNodeObject     4  src/game/rendering_graph_node.c:124  = NULL
#   gAreaUpdateCounter      2  src/game/rendering_graph_node.c:126  = 0
#   gDmaIoMesg             20  src/game/main.c:29
#   gMainReceivedMesg       4  src/game/main.c:30
#   gDmaMesgQueue          24  src/game/main.c:32
#   gSIEventMesgQueue      24  src/game/main.c:33
#   gDebugLevelSelect       1  src/game/main.c:55        = FALSE
#   gShowDebugText          1  src/game/main.c:59        = FALSE
#   gDialogResponse         4  src/game/ingame_menu.c:131 = DIALOG_RESPONSE_NONE (0)
#   gPaintingMarioYEntry    4  src/game/moving_texture.c:118 = 0.0f
#   gObjParentGraphNode    20  src/engine/geo_layout.c:47
#   gGlobalSoundSource     12  src/audio/external.c:344  = { 0.0f, 0.0f, 0.0f }
python3 - "$TMP" <<'PYEOF'
import re, sys
path = sys.argv[1]
s = open(path).read()
BSS = [
    ("gBodyStates", 80),
    ("gCurGraphNodeRoot", 4), ("gCurGraphNodeMasterList", 4),
    ("gCurGraphNodeCamFrustum", 4), ("gCurGraphNodeCamera", 4),
    ("gCurGraphNodeObject", 4), ("gAreaUpdateCounter", 2),
    ("gDmaIoMesg", 20), ("gMainReceivedMesg", 4), ("gDmaMesgQueue", 24),
    ("gSIEventMesgQueue", 24), ("gDebugLevelSelect", 1), ("gShowDebugText", 1),
    ("gDialogResponse", 4), ("gPaintingMarioYEntry", 4),
    ("gObjParentGraphNode", 20), ("gGlobalSoundSource", 12),
]
done = []
for name, n in BSS:
    s2 = re.sub(r'(Definition v_' + name + r' := \{\|\s*gvar_info := [^;]*;\s*gvar_init := )nil;',
                r'\g<1>(Init_space ' + str(n) + r' :: nil);', s)
    if s2 != s:
        s = s2
        done.append(name)
if done:
    open(path, 'w').write(s)
    print(f"unlinked-definer storage: {', '.join(done)} in {path}")
PYEOF

# Behavior-script completion (TRUST 2.4, 2026-10-21; same class as the table
# above, applied by RULE rather than by hand because there are ~170 of them).
# data/behavior_data.c defines every behavior script
#   const BehaviorScript bhvXxx[] = { ... };
# and the game TUs declare them via include/behavior_data.h
#   extern const BehaviorScript bhvXxx[];
# clightgen gives the declaration (tarray tuint 0), readonly true, and the
# definition (tarray tuint N), readonly false (CompCert's elaborator drops the
# const when it completes the array type from the initializer).  CompCert's
# vardef linker needs both fields equal, so the DECL side is completed to the
# definer's (gvar_info, gvar_readonly) -- N read off generated/behavior_data.v,
# i.e. the real script length in the decomp.  init stays nil; the linked
# program takes the definer's vardef (link_varinit), so nothing a run can see
# changes.  Without this behavior_data.c cannot be linked, and every bhv*
# block is size 0: every `o->behavior == segmented_to_virtual(bhvXxx)` compare
# and every script read has no CompCert execution (WMotREntry.cmp_size0_stuck).
BHV_DEF="$(dirname "$0")/../generated/behavior_data.v"
if [ "$TUNAME" != "behavior_data" ] && [ -f "$BHV_DEF" ]; then
python3 - "$TMP" "$BHV_DEF" <<'PYEOF'
import re, sys
path, bhv = sys.argv[1], sys.argv[2]
defs = {}
for m in re.finditer(r'Definition v_(bhv\w+) := \{\|\s*gvar_info := \(tarray tuint (\d+)\);'
                     r'\s*gvar_init := (.*?);\s*gvar_readonly := false;', open(bhv).read(), re.S):
    if m.group(3).strip() != 'nil' and int(m.group(2)) > 0:
        defs[m.group(1)] = int(m.group(2))
s = open(path).read()
done = []
def sub(m):
    n = m.group(2)
    if n not in defs:
        return m.group(0)
    done.append(n)
    return (m.group(1) + '(tarray tuint ' + str(defs[n]) + ')' + m.group(3)
            + 'nil;' + m.group(4) + 'false;')
s2 = re.sub(r'(Definition v_(bhv\w+) := \{\|\s*gvar_info := )\(tarray tuint 0\)'
            r'(;\s*gvar_init := )nil;(\s*gvar_readonly := )true;', sub, s)
if done:
    open(path, 'w').write(s2)
    print(f"behavior-script completion: {len(done)} bhv* decls in {path}")
PYEOF
fi

# Level-data completion (TRUST 2.4, 2026-10-22; the same class as the two
# rules above).  pipeline/tu/wmotr_level_data.c defines WMotR's collision /
# macro arrays (the vendor .inc.c files verbatim, under leveldata.c's
# make_const_nonconst.h, so readonly false); data/behavior_data.c declares the
# two object meshes it loads (`extern const Collision xxx[];`: tarray tshort 0,
# readonly true).  The DECL side is completed to the definer's
# (gvar_info, gvar_readonly), N read off generated/wmotr_level_data.v; init
# stays nil, so the linked program takes the definer's data.  Without this the
# level data cannot join the link (load_area_terrain needs it in memory).
LVL_DEF="$(dirname "$0")/../generated/wmotr_level_data.v"
if [ "$TUNAME" != "wmotr_level_data" ] && [ -f "$LVL_DEF" ]; then
python3 - "$TMP" "$LVL_DEF" <<'PYEOF'
import re, sys
path, lvl = sys.argv[1], sys.argv[2]
defs = {}
for m in re.finditer(r'Definition v_(\w+) := \{\|\s*gvar_info := \(tarray tshort (\d+)\);'
                     r'\s*gvar_init := (.*?);\s*gvar_readonly := false;', open(lvl).read(), re.S):
    if m.group(3).strip() != 'nil' and int(m.group(2)) > 0:
        defs[m.group(1)] = int(m.group(2))
s = open(path).read()
done = []
def sub(m):
    n = m.group(2)
    if n not in defs:
        return m.group(0)
    done.append(n)
    return (m.group(1) + '(tarray tshort ' + str(defs[n]) + ')' + m.group(3)
            + 'nil;' + m.group(4) + 'false;')
s2 = re.sub(r'(Definition v_(\w+) := \{\|\s*gvar_info := )\(tarray tshort 0\)'
            r'(;\s*gvar_init := )nil;(\s*gvar_readonly := )true;', sub, s)
if done:
    open(path, 'w').write(s2)
    print(f"level-data completion: {', '.join(done)} in {path}")
PYEOF
fi

# Anim-data completion (TRUST 2.4, 2026-10-22; the same class as the rules
# above).  The vendor build's assets/mario_anim_data.c (generated by
# tools/mario_anims_converter.py) defines
#   const struct MarioAnimsObj gMarioAnims = { ... };
# and game_init.c declares it `extern u8 gMarioAnims[];` (tarray tuchar 0,
# readonly false).  CompCert's vardef linker needs gvar_info and
# gvar_readonly equal, so the DECL side is completed to the definer's, read
# off generated/mario_anim_data.v (the struct named $"MarioAnimsObj", as the
# declaring TU has no _MarioAnimsObj constant); init stays nil, so the linked program takes
# the definer's data.  Expressions keep their own (tarray tuchar 0) type
# annotation: Clight's Evar ignores the declared type.  Without this the anim
# data cannot be linked and gMarioAnims is a size-0 block: every
# load_patchable_table compare `addr != list->currentAddr` (memory.c:575) on
# a valid anim id has no CompCert execution (oracle difftest, 2026-10-22).
ANIM_DEF="$(dirname "$0")/../generated/mario_anim_data.v"
if [ "$TUNAME" != "mario_anim_data" ] && [ -f "$ANIM_DEF" ]; then
python3 - "$TMP" "$ANIM_DEF" <<'PYEOF'
import re, sys
path, anim = sys.argv[1], sys.argv[2]
defs = {}
for m in re.finditer(r'Definition v_(\w+) := \{\|\s*gvar_info := (\(Tstruct _\w+ noattr\));'
                     r'\s*gvar_init := (.*?);\s*gvar_readonly := (true|false);', open(anim).read(), re.S):
    if m.group(3).strip() != 'nil':
        # the struct's ident constant (_Name) is not defined in the declaring
        # TU; spell it $"Name" (the same ident: ident_of_string)
        info = re.sub(r'Tstruct _(\w+)', r'Tstruct $"\1"', m.group(2))
        defs[m.group(1)] = (info, m.group(4))
s = open(path).read()
done = []
def sub(m):
    n = m.group(2)
    if n not in defs:
        return m.group(0)
    done.append(n)
    return m.group(1) + defs[n][0] + m.group(3) + 'nil;' + m.group(4) + defs[n][1] + ';'
s2 = re.sub(r'(Definition v_(\w+) := \{\|\s*gvar_info := )\(tarray tuchar 0\)'
            r'(;\s*gvar_init := )nil;(\s*gvar_readonly := )false;', sub, s)
if done:
    open(path, 'w').write(s2)
    print(f"anim-data completion: {', '.join(done)} in {path}")
PYEOF
fi

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
