"""Real-game tether for the slide-kick height budget (GOAL 2).

From wmotr_idle.st: hold the stick forward for RUN game frames, press Z (walking ->
ACT_CROUCH_SLIDE, mario_actions_moving.c:807), keep Z held, then press B
(act_crouch_slide :1467, forwardVel >= 10 -> ACT_SLIDE_KICK).  Logs, once per
execute_mario_action return, action / actionState / pos[1] / vel[1] / forwardVel.

    python3 experiments/oracle/slide_kick_probe.py [RUN] [ZWAIT]
"""
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from m64 import Emu, pad, Z, B

ORACLE = os.path.expanduser("~/sm64-oracle")
ROM = f"{ORACLE}/decomp/build/us/sm64.us.z64"
MAP = f"{ORACLE}/decomp/build/us/sm64.us.map"
STATE = f"{ORACLE}/wmotr_idle.st"
RET_SITE = 0x8029CA70   # bhv_mario_update, after jal execute_mario_action
RUN = int(sys.argv[1]) if len(sys.argv) > 1 else 12
ZWAIT = int(sys.argv[2]) if len(sys.argv) > 2 else 2
TOTAL = RUN + ZWAIT + 60

emu = Emu(ROM, MAP)
S = emu.syms
ms = S["gMarioStates"]
st = {"loaded": False, "n": 0, "keys": 0}


def script(n):
    """Controller input for game frame n (n = number of Mario updates so far)."""
    if n < RUN:
        return pad(0, 0, 127)                 # stick forward
    if n == RUN:
        return pad(Z, 0, 127)                 # Z press while running
    if n < RUN + ZWAIT:
        return pad(Z, 0, 127)                 # hold Z
    if n == RUN + ZWAIT:
        return pad(Z | B, 0, 127)             # B press in crouch slide
    return pad(Z, 0, 127)


def on_exit(e, pc):
    n = st["n"]
    act = e.read32(ms + 12)
    ast = e.read16(ms + 24)
    y = e.readf(ms + 64)
    vy = e.readf(ms + 76)
    fv = e.readf(ms + 84)
    print(f"F {n:3d} keys={st['keys']:08x} act={act:08x} st={ast} y={y!r} vy={vy!r} fwd={fv!r}", flush=True)
    st["n"] += 1
    st["keys"] = script(st["n"])
    e.keys = st["keys"]
    if st["n"] > TOTAL:
        e.stop()


def vi(e):
    if not st["loaded"]:
        if e.frame < 60:
            return
        e.load_state(STATE)
        st["loaded"] = True
        st["keys"] = script(0)
        return
    e.keys = st["keys"]
    if e.frame > 20000:
        e.stop()


emu.on_vi = vi
emu.add_bp(RET_SITE, on_exit)
emu.run()
