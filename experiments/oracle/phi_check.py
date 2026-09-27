#!/usr/bin/env python3
"""Evaluate GOAL 2's height invariant on recorded real frames (tether 5.1).

    python3 experiments/oracle/phi_check.py [seed ...]

For every recorded execute_mario_action call, this reads gMarioStates[0] from
the real RAM at entry and at return, and evaluates the numeric part of
Phi_wmotr (proofs/WMotRRequiresA/HeightPhi.v):
  - the budget y + credit <= K + A
  - vel[1] >= -75
  - the post-bounce slide-kick timer clause
  - the ledge clause
The action whitelist R_noA is still a parameter, so this only lists the
actions it sees. Phi holding here is a necessary condition, not a proof.
Offsets are the ones pinned in HeightPhi.v.
"""
import os
import pickle
import re
import struct
import sys
import zlib

ORACLE = os.path.expanduser("~/sm64-oracle")
MAP = f"{ORACLE}/decomp/build/us/sm64.us.map"

K, A = 2372.0, 372.0
EPS = 1 / 64
FREEFALL, BSA, SK, GP = 0x0100088C, 0x0300088E, 0x018008AA, 0x008008A9
LEDGE = 0x0800034B


def gmario_addr():
    pat = re.compile(r"^\s+0x([0-9a-fA-F]{8,16})\s+gMarioStates\s*$")
    for line in open(MAP):
        m = pat.match(line)
        if m:
            return int(m.group(1), 16) & 0xFFFFFFFF
    raise SystemExit("gMarioStates not in map")


def energy(g, v):
    return (v + g / 2) ** 2 / (2 * g)


def bal(g, v):
    return 0.0 if v <= 0 else energy(g, v) + EPS * (v / g + 1)


def credit(a, st, tm, v):
    if a in (FREEFALL, BSA):
        return bal(4, v) + 110
    if a == SK:
        return bal(2, v) + 110 if st == 0 else energy(2, v) + EPS * max(0.0, (v + 75) / 2 + 1)
    if a == GP:
        return (10 - tm) * (11 - tm) if (st == 0 and tm < 10) else 0.0
    if a & 0x800:
        return bal(4, v)
    return A


def phi(ram, base):
    o = base - 0x80000000
    a, = struct.unpack(">I", ram[o + 12:o + 16])
    st, tm = struct.unpack(">HH", ram[o + 24:o + 28])
    y, = struct.unpack(">f", ram[o + 64:o + 68])
    v, = struct.unpack(">f", ram[o + 76:o + 80])
    fh, = struct.unpack(">f", ram[o + 112:o + 116])
    slack = K + A - (y + credit(a, st, tm, v))
    bad = []
    if slack < 0:
        bad.append(f"budget {slack:.1f}")
    if v < -75:
        bad.append(f"vel {v}")
    if a == SK and st != 0 and v + 2 * tm > 37.5:
        bad.append("sk-timer")
    if a == LEDGE and fh > K:
        bad.append("ledge")
    return a, y, v, slack, bad


def main(seeds):
    base = gmario_addr()
    n = fails = 0
    actions = {}
    min_slack = None
    for seed in seeds:
        d = f"{ORACLE}/rec/{seed}"
        for fn in sorted(os.listdir(d)):
            r = pickle.loads(zlib.decompress(open(f"{d}/{fn}", "rb").read()))
            entry = r["entry"]
            exit_ = bytearray(entry)
            for addr, b in r["exit_diff"]:
                o = addr - 0x80000000
                exit_[o:o + len(b)] = b
            for tag, ram in (("entry", entry), ("exit", exit_)):
                a, y, v, slack, bad = phi(ram, base)
                n += 1
                actions[a] = actions.get(a, 0) + 1
                if min_slack is None or slack < min_slack[0]:
                    min_slack = (slack, seed, fn, tag, hex(a), y, v)
                if bad:
                    fails += 1
                    print(f"FAIL {seed}/{fn} {tag}: action {a:#010x} y={y} v={v} {bad}")
    print(f"{n} states checked, {fails} violate Phi (R_noA excluded)")
    print(f"tightest budget slack: {min_slack}")
    print("actions seen:", " ".join(f"{a:#010x}x{c}" for a, c in sorted(actions.items())))


if __name__ == "__main__":
    main(sys.argv[1:] or ["1", "2"])
