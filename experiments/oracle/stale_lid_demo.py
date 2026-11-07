"""Hacked demo of the stale-lid platform displacement in real WMotR (US decomp build).

Hacks (memory pokes only; all game code runs unmodified):
  H0  put Mario on the WMotR cannon lid (pos poke, once)
  H1  set the cannon-unlocked save bit directly (skips the buddy dialog/cutscene freeze)
  H3  when the lid has been freed and gMarioPlatform still names its slot, imitate a
      bhvBreakBoxTriangle reusing that slot: zero rawData (as allocate_object does), put it at
      a box position + 100 y, and give it the triangle's pitch spin 0x80*50 = 6400.
Logs Mario per game frame as CSV to stdout lines starting with 'F,'.

Result (2026-11-07): with OFFX=-108 the real game leaves gMarioPlatform naming the freed lid
slot (no hack on that step). H3 then moves Mario in one frame: PIVOT=3600,-2380,5440 (the
wing-cap box 260 units away) -> +207 y, -172 z; PIVOT=3960,620,440 -> -2125 y, -2812 z.
In the unhacked game the buddy's cannon cutscene keeps Mario frozen while the lid opens
(labeled camera premise Hcam_cannon_cutscene).

    OFFX=-108 PIVOT=3600,-2380,5440 python3 experiments/oracle/stale_lid_demo.py
"""
import os, struct, sys
sys.path.insert(0, os.path.dirname(__file__))
from m64 import Emu

ORACLE = os.path.expanduser("~/sm64-oracle")
ROM = f"{ORACLE}/decomp/build/us/sm64.us.z64"
MAP = f"{ORACLE}/decomp/build/us/sm64.us.map"
STATE = f"{ORACLE}/wmotr_idle.st"
RET_SITE = 0x8029CA70          # bhv_mario_update, after jal execute_mario_action
LID = (3712.0, -2740.0, 5200.0)
PIVOT = tuple(float(v) for v in os.environ.get("PIVOT", "3960,620,440").split(","))
OFFX = float(os.environ.get("OFFX", "-130"))
SPIN = int(os.environ.get("SPIN", str(0x80 * 50)))
OBJ_SIZE, NOBJ = 0x260, 240
SAVESTATE_OUT = os.environ.get("SAVE_AT")   # optional: save a state just before the hack

emu = Emu(ROM, MAP)
S = emu.syms
ms = S["gMarioStates"]
st = {"loaded": False, "n": 0, "lid": None, "on_lid": 0, "unlocked": False,
      "hacked_at": None, "freed_at": None}


def fbits(v): return struct.unpack(">I", struct.pack(">f", v))[0]
def write8(e, a, v):
    w = a & ~3; sh = (3 - (a & 3)) * 8
    e.write32(w, (e.read32(w) & ~(0xFF << sh)) | ((v & 0xFF) << sh))
def read8(e, a): return e.read(a, 1)[0]
def s16(v): v &= 0xFFFF; return v - 0x10000 if v & 0x8000 else v


def find_lid(e):
    best = None
    for i in range(NOBJ):
        o = S["gObjectPool"] + i * OBJ_SIZE
        if s16(e.read16(o + 0x74)) & 1 == 0:
            continue
        x, y, z = e.readf(o + 0xA0), e.readf(o + 0xA4), e.readf(o + 0xA8)
        d = abs(x - LID[0]) + abs(y - LID[1]) + abs(z - LID[2])
        if d < 50 and (best is None or d < best[0]):
            best = (d, o)
    return best and best[1]


def cannon_bit_addr(e):
    f = e.read16(S["gCurrSaveFileNum"]); c = s16(e.read16(S["gCurrCourseNum"]))
    return S["gSaveBuffer"] + (f - 1) * 2 * 0x38 + 12 + c


def on_mario(e, pc):
    n = st["n"]; st["n"] += 1
    if n == 0:
        lid = find_lid(e)
        st["lid"] = lid
        print(f"# lid slot {lid and hex(lid)} beh={lid and hex(e.read32(lid + 0x20C))} "
              f"course={s16(e.read16(S['gCurrCourseNum']))} file={e.read16(S['gCurrSaveFileNum'])}", flush=True)
        if lid is None:
            e.stop(); return
        top = e.readf(lid + 0xA4)
        for k, v in enumerate((e.readf(lid + 0xA0), top + 150.0, e.readf(lid + 0xA8))):
            e.write32(ms + 60 + 4 * k, fbits(v))                        # H0
    lid = st["lid"]
    plat = e.read32(S["gMarioPlatform"])
    if plat == lid and s16(e.read16(lid + 0x74)) & 1:
        st["on_lid"] += 1
    if st["on_lid"] >= 15 and not st["unlocked"]:
        a = cannon_bit_addr(e); write8(e, a, read8(e, a) | 0x80)       # H1
        st["unlocked"] = True
        print(f"# F{n}: cannon bit set at {a:#x}", flush=True)
    if (s16(e.read16(lid + 0x74)) & 1 and e.read32(lid + 0x14C) == 2
            and 74 <= e.read32(lid + 0x154) <= 79):                       # H2: back onto the lid
        e.write32(ms + 60, fbits(e.readf(lid + 0xA0) + OFFX))
        e.write32(ms + 64, e.read32(lid + 0xA4))
        e.write32(ms + 68, e.read32(lid + 0xA8))
        for k in range(3):
            e.write32(ms + 72 + 4 * k, 0)                                 # vel = 0
    x, y, z = (e.readf(ms + 60 + 4 * k) for k in range(3))
    act = e.read32(ms + 12)
    print(f"F,{n},{x:.2f},{y:.2f},{z:.2f},{act:08x},{plat:08x},"
          f"{s16(e.read16(lid + 0x74))},{e.read32(lid + 0x14C)},{e.read32(lid + 0x154)}", flush=True)
    if st["hacked_at"] is not None and n > st["hacked_at"] + 90:
        e.stop()
    if n > 600:
        e.stop()


def on_apply(e, pc):
    lid = st["lid"]
    if lid is None or st["hacked_at"] is not None:
        return
    if 160 <= st["n"] <= 170:
        mo = e.read32(S["gMarioObject"]); fl = e.read32(ms + 0x68)
        print(f"# apply n={st['n']} plat={e.read32(S['gMarioPlatform']):08x} objy={e.readf(mo + 0xA4):.2f} "
              f"floorH={e.readf(ms + 0x70):.2f} floor={fl:08x} floorobj={(e.read32(fl + 0x2C) if fl else 0):08x}", flush=True)
    if e.read32(S["gMarioPlatform"]) == lid and s16(e.read16(lid + 0x74)) & 1 == 0:
        if SAVESTATE_OUT:
            pass
        for w in range(0x50):                                            # H3: allocate_object zeroes rawData
            e.write32(lid + 0x88 + 4 * w, 0)
        for k, v in enumerate(PIVOT):
            e.write32(lid + 0xA0 + 4 * k, fbits(v))
        e.write32(lid + 0x114, SPIN)                                     # oAngleVelPitch
        st["hacked_at"] = st["n"]
        mx, my, mz = (e.readf(ms + 60 + 4 * k) for k in range(3))
        print(f"# HACK at game frame {st['n']}: stale slot {lid:#x} -> pivot {PIVOT}, "
              f"pitch spin {SPIN}; Mario before = ({mx:.1f}, {my:.1f}, {mz:.1f})", flush=True)


def vi(e):
    if not st["loaded"]:
        if e.frame < 60:
            return
        e.load_state(STATE); st["loaded"] = True
        return
    if e.frame > 20000:
        e.stop()


emu.on_vi = vi
emu.add_bp(RET_SITE, on_mario)
emu.add_bp(S["apply_mario_platform_displacement"], on_apply)
emu.run()
