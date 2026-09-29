"""Real-game probe (GOAL 2): can Mario enter the WMotR cannon without A?

act_in_cannon state 0 sets pos[1] := cannon.y + 350 (mario_actions_automatic.c).
Only the FIRE branch reads INPUT_A_PRESSED.  Entering is interact_cannon_base
(interaction.c:1066), with no input gate, once the cannon is open.  The cannon is
opened by the bob-omb buddy (macro.inc.c:5), and NPC talk takes B
(interaction.c READ_MASK, US = B | A); B also advances the dialog (ingame_menu.c).

From wmotr_idle.st, with ONE poke (Mario's pos and yaw, next to the buddy; a lead,
not a route):
  talk:  pulse B until the dialog opens, pulse B until it closes, wait for the
         cannon-opening cutscene to end;
  walk:  steer the stick (camera-relative, learned from intendedYaw) toward the
         cannon base at (3712, -2740, 5200) until the action becomes ACT_IN_CANNON.
Input never presses or holds A.  Logs one line per execute_mario_action return.

    python3 experiments/oracle/cannon_probe.py
"""
import math
import os
import struct
import sys

sys.path.insert(0, os.path.dirname(__file__))
from m64 import Emu, pad, B

ORACLE = os.path.expanduser("~/sm64-oracle")
ROM = f"{ORACLE}/decomp/build/us/sm64.us.z64"
MAP = f"{ORACLE}/decomp/build/us/sm64.us.map"
STATE = f"{ORACLE}/wmotr_idle.st"
RET_SITE = 0x8029CA70   # bhv_mario_update, after jal execute_mario_action

BUDDY = (3684.0, -2712.0, 4660.0)
CANNON = (3712.0, -2740.0, 5200.0)
START = (3684.0, -2600.0, 4800.0)   # 140 units +z of the buddy, above his floor
ACT_WAITING_FOR_DIALOG = 0x0000130A
ACT_READING_NPC_DIALOG = 0x20001306
ACT_IN_CANNON = 0x00001371
LIMIT = 3000

emu = Emu(ROM, MAP)
S = emu.syms
ms = S["gMarioStates"]
st = {"loaded": False, "n": 0, "keys": 0, "phase": "settle", "t": 0,
      "seen_dialog": False, "quiet": 0, "stick": (0, 0), "cam": None, "cannon_n": None}


def fbits(v):
    return struct.unpack(">I", struct.pack(">f", v))[0]


def s16(v):
    v &= 0xFFFF
    return v - 0x10000 if v >= 0x8000 else v


def yaw_of(dx, dz):
    """SM64 yaw of a direction: 0 = +z, 0x4000 = +x."""
    return int(round(math.atan2(dx, dz) * 0x8000 / math.pi)) & 0xFFFF


def steer(e, target):
    """Stick that makes intendedYaw point at target, using the camera yaw
    learned from last frame's (stick, intendedYaw)."""
    x, z = e.readf(ms + 60), e.readf(ms + 68)
    want = yaw_of(target[0] - x, target[2] - z)
    sx, sy = st["stick"]
    if sx or sy:
        # intendedYaw = atan2s(-stickY, stickX) + camYaw = yaw_of(stickX, -stickY) + camYaw
        st["cam"] = (e.read16(ms + 36) - yaw_of(sx, -sy)) & 0xFFFF
    cam = st["cam"] if st["cam"] is not None else 0
    th = (want - cam) * math.pi / 0x8000
    sx, sy = int(round(80 * math.sin(th))), int(round(-80 * math.cos(th)))
    st["stick"] = (sx, sy)
    return sx, sy


def script(e):
    act = e.read32(ms + 12)
    ph, st["t"] = st["phase"], st["t"] + 1
    if ph == "settle":
        if st["t"] >= 20:
            st["phase"], st["t"] = "talk", 0
        return 0
    if ph == "talk":
        if act in (ACT_WAITING_FOR_DIALOG, ACT_READING_NPC_DIALOG):
            st["seen_dialog"], st["quiet"] = True, 0
        elif st["seen_dialog"]:
            st["quiet"] += 1
            if st["quiet"] >= 60:
                st["phase"], st["t"] = "walk", 0
                return 0
        # a one-frame B pulse every 10 frames
        in_dialog = act in (ACT_WAITING_FOR_DIALOG, ACT_READING_NPC_DIALOG)
        pulse = in_dialog or not st["seen_dialog"]     # no B after the dialog closes
        return pad(B) if pulse and st["t"] % 10 == 0 else 0
    if ph == "walk":
        if act == ACT_IN_CANNON:
            st["phase"] = "in"
            st["stick"] = (0, 0)
            return 0
        sx, sy = steer(e, CANNON)
        return pad(0, sx, sy)
    return 0


def on_exit(e, pc):
    n = st["n"]
    act = e.read32(ms + 12)
    if n == 0:
        for k, v in enumerate(START):
            e.write32(ms + 60 + 4 * k, fbits(v))
        e.write16(ms + 46, 0x8000)          # faceAngle[1]: face -z, toward the buddy
    y, vy = e.readf(ms + 64), e.readf(ms + 76)
    x, z = e.readf(ms + 60), e.readf(ms + 68)
    lvl = e.read16(S["gCurrLevelNum"])
    print(f"F {n:4d} {st['phase']:6s} keys={st['keys']:08x} lvl={lvl} act={act:08x} "
          f"st={e.read16(ms + 24)} x={x:.1f} y={y:.2f} z={z:.1f} vy={vy:.2f}", flush=True)
    if act == ACT_IN_CANNON and st["cannon_n"] is None:
        st["cannon_n"] = n
        print(f"IN_CANNON at F {n}: y={y!r} (cannon.y + 350 = {CANNON[1] + 350})", flush=True)
    st["n"] += 1
    st["keys"] = script(e)
    e.keys = st["keys"]
    if st["n"] > LIMIT or lvl != 31 or (st["cannon_n"] is not None and n > st["cannon_n"] + 30):
        e.stop()


def vi(e):
    if not st["loaded"]:
        if e.frame < 60:
            return
        e.load_state(STATE)
        st["loaded"] = True
        return
    e.keys = st["keys"]
    if e.frame > 40000:
        e.stop()


emu.on_vi = vi
emu.add_bp(RET_SITE, on_exit)
emu.run()
