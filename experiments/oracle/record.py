"""Record real frames of `execute_mario_action` in WMotR.

From wmotr_idle.st, play N frames of scripted, varied input (stick, A, B, Z).  For
every call of execute_mario_action, capture all of RDRAM at function entry and
the bytes that changed by the time it returns (breakpoint on the return site in
bhv_mario_update).  Nothing is poked: this is unmodified game execution.

    python3 experiments/oracle/record.py [N=300] [seed=1]

Output: ~/sm64-oracle/rec/<seed>/fNNNN.pkl.zlib, each a dict
    {frame, keys, a0, entry: bytes(4MB), exit_diff: [(addr, bytes)]}
"""
import os
import pickle
import random
import sys
import zlib

import numpy as np

sys.path.insert(0, os.path.dirname(__file__))
from m64 import Emu, pad, A, B, Z

ORACLE = os.path.expanduser("~/sm64-oracle")
ROM = f"{ORACLE}/decomp/build/us/sm64.us.z64"
MAP = f"{ORACLE}/decomp/build/us/sm64.us.map"
STATE = f"{ORACLE}/wmotr_idle.st"
N = int(sys.argv[1]) if len(sys.argv) > 1 else 300
SEED = int(sys.argv[2]) if len(sys.argv) > 2 else 1
OUT = f"{ORACLE}/rec/{SEED}"
RET_SITE = 0x8029CA70   # bhv_mario_update: jal execute_mario_action at 0x8029CA68 (+8)

os.makedirs(OUT, exist_ok=True)
emu = Emu(ROM, MAP)
S = emu.syms
rng = random.Random(SEED)
st = {"loaded": False, "cur": None, "n": 0, "hold": 0, "keys": 0}


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
    st["cur"] = {"frame": e.frame, "keys": st["keys"], "a0": e.reg(4), "entry": e.dump()}


def on_exit(e, pc):
    cur = st.pop("cur", None)
    st["cur"] = None
    if cur is None:
        return
    after = e.dump()
    cur["exit_diff"] = diff(cur["entry"], after)
    with open(f"{OUT}/f{st['n']:04d}.pkl.zlib", "wb") as f:
        f.write(zlib.compress(pickle.dumps(cur), 1))
    st["n"] += 1
    if st["n"] % 50 == 0:
        print(f"[rec] {st['n']}/{N} frames, last diff {len(cur['exit_diff'])} ranges", flush=True)


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
    if e.frame % 300 == 0:
        print(f"[vi] frame {e.frame} level {e.read16(S['gCurrLevelNum'])} recorded {st['n']}", flush=True)
    if e.frame > 20 * N + 600:
        print("[vi] giving up", flush=True)
        e.stop()
    if not st["loaded"]:
        if e.frame < 60:   # let the core finish booting before loading
            return
        print("[vi] load_state rc", e.load_state(STATE), flush=True)
        st["loaded"] = True
        return
    e.keys = next_keys()
    if st["n"] >= N:
        e.stop()


emu.on_vi = vi
emu.add_bp(S["execute_mario_action"], on_entry)
emu.add_bp(RET_SITE, on_exit)
emu.run()
print(f"recorded {st['n']} frames into {OUT}")
