"""Inventory of the C that the proof's preprocessing changes relative to the ROM build.

The ROM is built by IDO (which predefines __sgi) from vendor/sm64 WITHOUT
-DNON_MATCHING -DAVOID_UB; the proof's C adds those flags (plus whatever proof
shim headers pipeline/ adds).  This preprocesses every clightgen'd TU both
ways with clightgen's own preprocessor, diffs the token streams, and maps each
changed hunk back to its source file:line.  Every hunk is a site that needs a
TRUST.md 2.2 row.

    python3 tools/ub_sites.py [TU ...]      (run inside `source pipeline/env.sh`)
"""
import difflib
import os
import re
import subprocess
import sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SM64 = "vendor/sm64"
COMMON = ["-nostdinc", f"-I{SM64}/include", f"-I{SM64}/build/us", f"-I{SM64}/build/us/include",
          f"-I{SM64}/src", f"-I{SM64}", f"-I{SM64}/include/libc",
          "-DVERSION_US=1", "-DF3DEX_GBI_2=1", "-DF3DEX_GBI_SHARED=1", "-D_FINALROM=1",
          "-DTARGET_N64=1", "-D_LANGUAGE_C=1"]
PROOF = ["-DNON_MATCHING=1", "-DAVOID_UB=1"]
SHIM = ["-include", "pipeline/proof_n64.h"]
NO_SHIM = {"shadow", "behavior_data"}   # mirrors the Makefile (SM64_CG vs SM64_CGP)
ROM = ["-D__sgi=1"]   # IDO predefines __sgi (macros.h: matching build, GLOBAL_ASM live)
TUS = ("mario mario_actions_airborne mario_actions_moving mario_actions_stationary "
       "mario_actions_submerged mario_actions_cutscene mario_actions_automatic "
       "mario_actions_object interaction behavior_actions level_update mario_step "
       "mario_misc math_util surface_collision shadow object_helpers obj_behaviors "
       "obj_behaviors_2 spawn_object object_list_processor behavior_data").split()   # every generated SM64 TU


def src_of(tu):
    for d in ("src/game", "src/engine", "data"):
        p = f"{SM64}/{d}/{tu}.c"
        if os.path.exists(os.path.join(ROOT, p)):
            return p
    raise FileNotFoundError(tu)


def preprocess(src, flags):
    """[(file, line, text)] for every non-blank output line."""
    out = subprocess.run(["clightgen", "-E", *COMMON, *flags, src], cwd=ROOT,
                         capture_output=True, text=True, check=True).stdout
    res, f, ln = [], "?", 0
    for line in out.split("\n"):
        m = re.match(r'# (\d+) "([^"]+)"', line)
        if m:
            ln, f = int(m.group(1)), m.group(2)
            continue
        if line.strip():
            res.append((f, ln, " ".join(line.split())))
        ln += 1
    return res


def sites(tu, proof_extra=()):
    src = src_of(tu)
    rom = preprocess(src, ROM)
    prf = preprocess(src, PROOF + ([] if tu in NO_SHIM else SHIM) + list(proof_extra))
    sm = difflib.SequenceMatcher(a=[t for _, _, t in rom], b=[t for _, _, t in prf], autojunk=False)
    out = []
    for op, i1, i2, j1, j2 in sm.get_opcodes():
        if op == "equal":
            continue
        loc = prf[j1] if j1 < j2 else rom[i1]
        out.append((loc[0], loc[1], [t for _, _, t in rom[i1:i2]], [t for _, _, t in prf[j1:j2]]))
    return out


# Known mechanical classes of hunk: (name, rom->proof text rewrite that explains it)
CLASSES = [
    ("cosine-alias", lambda t: t.replace("gCosineTable", "(gSineTable + 0x400)")),
    ("v2p-subtraction (proof_n64.h)", lambda t: re.sub(
        r"\(\(uintptr_t\)\((.*?)\) & 0x1FFFFFFF\)",
        r"((uintptr_t)((unsigned char *)(\1) - 0x80000000U))", t)),
]


def classify(rom, prf):
    for name, f in CLASSES:
        if [f(x) for x in rom] == prf:
            return name
    return None


def main():
    tus = [a for a in sys.argv[1:] if not a.startswith("-")] or TUS
    by_site = defaultdict(set)
    detail = {}
    for tu in tus:
        for f, ln, rom, prf in sites(tu):
            key = (f, ln)
            by_site[key].add(tu)
            detail[key] = (rom, prf)
    counts = defaultdict(int)
    for (f, ln), t in sorted(by_site.items()):
        rom, prf = detail[(f, ln)]
        c = classify(rom, prf)
        counts[c or "unclassified"] += 1
        if c and "-v" not in sys.argv:
            continue
        print(f"== {f}:{ln}   [{len(t)} TU: {', '.join(sorted(t))}]")
        for x in rom[:6]:
            print(f"   ROM   {x[:150]}")
        for x in prf[:6]:
            print(f"   PROOF {x[:150]}")
    print(f"\n{len(by_site)} changed sites: " + ", ".join(f"{k} {v}" for k, v in sorted(counts.items())))


if __name__ == "__main__":
    main()
