"""Record real frames of `execute_mario_action` in WMotR, with an external-call log.

From wmotr_idle.st, play N frames of seeded random input (stick, A, B, Z).  For
every call of execute_mario_action, store:

  entry      all of RDRAM at function entry
  exit_diff  the bytes changed by the time it returns (return site in bhv_mario_update)
  calls      every call the frame makes to a function OUTSIDE the twelve-TU link
             (extract/boundary.txt), outermost only: its argument registers, stack
             args, return registers, the bytes it changed, and the 64 bytes behind
             each pointer argument at return

The call log is what the model's `extcall` oracle replays: the model runs the
linked C itself, and the real game supplies what the unlinked functions did.
Nothing is poked; this is unmodified game execution.  The frame is single-stepped
(the core allows only 128 breakpoints, the link has ~280 externals).

    python3 experiments/oracle/record.py [N=100] [seed=1]

Output: ~/sm64-oracle/rec/<seed>/fNNNN.pkl.zlib
"""
import os
import pickle
import random
import sys
import zlib

import numpy as np

sys.path.insert(0, os.path.dirname(__file__))
from m64 import Emu, pad, A, B, Z

HERE = os.path.dirname(os.path.abspath(__file__))
ORACLE = os.path.expanduser("~/sm64-oracle")
ROM = f"{ORACLE}/decomp/build/us/sm64.us.z64"
MAP = f"{ORACLE}/decomp/build/us/sm64.us.map"
STATE = f"{ORACLE}/wmotr_idle.st"
N = int(sys.argv[1]) if len(sys.argv) > 1 else 100
SEED = int(sys.argv[2]) if len(sys.argv) > 2 else 1
OUT = f"{ORACLE}/rec/{SEED}"
RET_SITE = 0x8029CA70   # bhv_mario_update: jal execute_mario_action at 0x8029CA68 (+8)
SP, RA = 29, 31

os.makedirs(OUT, exist_ok=True)
emu = Emu(ROM, MAP)
S = emu.syms
EXT = {}
for line in open(f"{HERE}/extract/boundary.txt"):
    f = line.split()
    if f[0] == "extfun" and f[1] in S:
        EXT[S[f[1]]] = f[1]
rng = random.Random(SEED)
st = {"loaded": False, "cur": None, "call": None, "n": 0, "hold": 0, "keys": 0}


def diff(a, b, gap=16):
    """Changed byte ranges of b vs a, merging runs closer than `gap`."""
    idx = np.flatnonzero(np.frombuffer(a, np.uint8) != np.frombuffer(b, np.uint8))
    out = []
    if len(idx) == 0:
        return out
    breaks = np.flatnonzero(np.diff(idx) > gap)
    starts = np.concatenate(([idx[0]], idx[breaks + 1]))
    ends = np.concatenate((idx[breaks], [idx[-1]]))
    for s0, e0 in zip(starts.tolist(), ends.tolist()):
        out.append((0x80000000 + s0, b[s0:e0 + 1]))
    return out


def on_entry(e, pc):
    if not st["loaded"] or st["n"] >= N:
        return
    st["cur"] = {"frame": e.frame, "keys": st["keys"], "a0": e.reg(4), "entry": e.dump(),
                 "calls": []}
    st["call"] = None
    e.stepping = True


def on_step(e, pc):
    c = st["call"]
    if c is None:
        name = EXT.get(pc)
        if name is not None:
            sp = e.reg(SP)
            st["call"] = {
                "name": name, "ra": e.reg(RA), "sp": sp,
                "a": [e.reg(i) for i in (4, 5, 6, 7)],
                "f12": e.fpr_bits(12), "f14": e.fpr_bits(14),
                "stack": [e.read32(sp + 16 + 4 * k) for k in range(8)],
                "_before": e.dump(),
            }
    elif pc == c["ra"] and e.reg(SP) == c["sp"]:
        before = c.pop("_before")
        c["v0"], c["v1"], c["f0"] = e.reg(2), e.reg(3), e.fpr_bits(0)
        c["diff"] = diff(before, e.dump())
        # real bytes behind every pointer-looking argument at return: out-params
        # (e.g. find_floor's &floor) whose value did not change are not in the diff
        c["post"] = {v: e.read(v, 64) for v in c["a"] + c["stack"]
                     if 0x80000400 <= v < 0x80400000 - 64}
        st["cur"]["calls"].append(c)
        st["call"] = None


def on_exit(e, pc):
    e.stepping = False
    cur, st["cur"] = st["cur"], None
    if cur is None:
        return
    cur["exit_diff"] = diff(cur["entry"], e.dump())
    with open(f"{OUT}/f{st['n']:04d}.pkl.zlib", "wb") as f:
        f.write(zlib.compress(pickle.dumps(cur), 1))
    st["n"] += 1
    if st["n"] % 10 == 0:
        print(f"[rec] {st['n']}/{N} frames, {len(cur['calls'])} external calls in the last", flush=True)


def next_keys():
    """Hold a random input for a few frames: stick in a random direction, and
    sometimes A (jumps: the thing the theorem is about), B, or Z."""
    if st["hold"] <= 0:
        st["hold"] = rng.randint(3, 20)
        mag = rng.choice([0, 0, 40, 80, 80])
        x, y = rng.randint(-mag, mag), rng.randint(-mag, mag)
        btn = rng.choices([0, A, B, Z, A | B], weights=[5, 3, 1, 1, 1])[0]
        st["keys"] = pad(btn, x, y)
    st["hold"] -= 1
    # release buttons every other frame so they register as fresh presses
    return st["keys"] if st["hold"] % 2 == 0 else st["keys"] & ~0xFFFF


def vi(e):
    if e.frame > 20 * N + 600:
        print("[vi] giving up", flush=True)
        e.stop()
    if not st["loaded"]:
        if e.frame < 60:   # let the core finish booting before loading
            return
        e.load_state(STATE)
        st["loaded"] = True
        return
    e.keys = next_keys()
    if st["n"] >= N:
        e.stop()


emu.on_vi = vi
emu.on_step = on_step
emu.add_bp(S["execute_mario_action"], on_entry)
emu.add_bp(RET_SITE, on_exit)
emu.run()
print(f"recorded {st['n']} frames into {OUT}")
