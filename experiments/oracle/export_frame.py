"""Turn one recorded frame into plain files for the OCaml replay driver.

    python3 export_frame.py ~/sm64-oracle/rec/1/f0005.pkl.zlib OUTDIR

OUTDIR/entry.bin   4 MB RDRAM at execute_mario_action entry (N64 byte order)
OUTDIR/exit.bin    4 MB RDRAM at its return
OUTDIR/calls.txt   the external-call log:
                     C name ra sp a0 a1 a2 a3 f12 f14 s0..s7 v0 v1 f0 ndiff npost
                     D addr hexbytes          (ndiff lines: bytes the call changed)
                     P addr hexbytes          (npost lines: 64 bytes behind a pointer arg, at return)
OUTDIR/addrs.txt   where the twelve-TU link's globals live in the real RAM:
                     A name address sizehint  (sizehint: map distance to next symbol)
OUTDIR/frame.txt   F a0 keys frame
"""
import os
import pickle
import re
import struct
import sys
import zlib

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mdebug_statics import all_statics

DECOMP = os.path.expanduser("~/sm64-oracle/decomp")
MAP = f"{DECOMP}/build/us/sm64.us.map"
TUS = ("mario mario_actions_airborne mario_actions_moving mario_actions_stationary "
       "mario_actions_submerged mario_actions_cutscene mario_actions_automatic "
       "mario_actions_object interaction behavior_actions level_update mario_step").split()


def full_map(path=MAP):
    """{symbol: raw address} including segmented (0x0S......) symbols."""
    syms = {}
    pat = re.compile(r"^\s+0x([0-9a-fA-F]{8,16})\s+([A-Za-z_][A-Za-z0-9_]*)\s*$")
    for line in open(path):
        m = pat.match(line)
        if m:
            syms.setdefault(m.group(2), int(m.group(1), 16) & 0xFFFFFFFF)
    return syms


# ROM symbols that are labels INSIDE another object under our preprocessing: with
# AVOID_UB, math_util.h defines gCosineTable as (gSineTable + 0x400), so the model
# indexes gSineTable across it (TRUST.md 2.2).
INNER_LABELS = {"gCosineTable"}


def resolve_addresses(entry, names):
    """{name: (KSEG0 address, size hint)} for every link global we can place.
    The size hint (used only for `extern T x[]` of unknown size) is the distance
    to the next ROM symbol (skipping INNER_LABELS), capped at the section end."""
    raw = full_map()
    seg_table = raw["sSegmentTable"] - 0x80000000

    def kseg0(a):
        if 0x80000000 <= a < 0x80400000:
            return a
        seg = a >> 24
        if 0 < seg < 32 and (a & 0xFF000000) != 0x80000000:
            base, = struct.unpack_from(">I", entry, seg_table + 4 * seg)
            if base:
                return 0x80000000 | (base + (a & 0xFFFFFF))
        return None

    placed = {}
    for n, a in raw.items():
        k = kseg0(a)
        if k is not None:
            placed[n] = k
    statics = all_statics([f"build/us/src/game/{t}.o" for t in TUS])
    bare = {}
    for k, (a, _sec, _o) in statics.items():
        bare.setdefault(k.split(".")[-1], []).append(a)
    for n, al in bare.items():
        if len(al) == 1 and n not in placed:
            placed[n] = al[0]
    order = sorted({a for n, a in placed.items() if n not in INNER_LABELS})
    nxt = {a: b for a, b in zip(order, order[1:])}
    secs = sorted((b, b + sz) for b, sz in section_extents().values())

    def sec_end(a):
        ends = [e for b, e in secs if b <= a < e]
        return min(ends) if ends else a

    return {n: (a, min(nxt.get(a, 1 << 40), sec_end(a)) - a)
            for n, a in placed.items() if n in names}


def section_extents(mapfile=MAP):
    """{(object, section): (base, size)} for every placed input section."""
    out = {}
    pat = re.compile(r"^ (\.\w+)\s+0x([0-9a-f]+)\s+0x([0-9a-f]+)\s+(\S+\.o)$")
    for line in open(mapfile):
        m = pat.match(line.rstrip("\n"))
        if m:
            a, sz = int(m.group(2), 16) & 0xFFFFFFFF, int(m.group(3), 16)
            if 0x80000000 <= a < 0x80400000 and sz:
                out[(m.group(4), m.group(1))] = (a, sz)
    return out


def main(src, out):
    os.makedirs(out, exist_ok=True)
    r = pickle.loads(zlib.decompress(open(src, "rb").read()))
    entry = r["entry"]
    exit_ = bytearray(entry)
    for a, b in r["exit_diff"]:
        o = a - 0x80000000
        exit_[o:o + len(b)] = b
    open(f"{out}/entry.bin", "wb").write(entry)
    open(f"{out}/exit.bin", "wb").write(bytes(exit_))
    with open(f"{out}/calls.txt", "w") as f:
        for c in r["calls"]:
            regs = [c["ra"], c["sp"], *c["a"], c["f12"], c["f14"], *c["stack"], c["v0"], c["v1"], c["f0"]]
            post = c.get("post", {})
            f.write(f"C {c['name']} " + " ".join(str(x) for x in regs) + f" {len(c['diff'])} {len(post)}\n")
            for a, b in c["diff"]:
                f.write(f"D {a} {b.hex()}\n")
            for a, b in post.items():
                f.write(f"P {a} {b.hex()}\n")
    names = set()
    for line in open(f"{HERE}/extract/boundary.txt"):
        names.add(line.split()[1])
    with open(f"{out}/addrs.txt", "w") as f:
        for n, (a, sz) in sorted(resolve_addresses(entry, names).items()):
            f.write(f"A {n} {a} {sz}\n")
    with open(f"{out}/frame.txt", "w") as f:
        f.write(f"F {r['a0']} {r['keys']} {r['frame']}\n")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
