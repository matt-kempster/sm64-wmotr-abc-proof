"""Boot the matching ROM headlessly and get Mario standing idle in WMotR, then
save a savestate (wmotr_idle.st).  Only the NAVIGATION pokes RAM (file choice,
one level warp through the game's own sWarpDest path). Everything recorded
later from the savestate is unmodified game execution.

    python3 experiments/oracle/nav_to_wmotr.py
"""
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from m64 import Emu, START, A, B

ORACLE = os.path.expanduser("~/sm64-oracle")
ROM = f"{ORACLE}/decomp/build/us/sm64.us.z64"
MAP = f"{ORACLE}/decomp/build/us/sm64.us.map"
OUT = f"{ORACLE}/wmotr_idle.st"

LEVEL_CASTLE_GROUNDS, LEVEL_WMOTR = 16, 31
ACT_IDLE = 0x0C400201
S_SELECTED_FILE_NUM = 0x80197D4C          # static; from disassembly of
MENU_SIG = (0x801768A0, 0x27BDFFE8)       # lvl_update_obj_and_load_file_selected

emu = Emu(ROM, MAP)
S = emu.syms
ms = S["gMarioStates"]
st = {"phase": "boot", "idle": 0}


def stationary(act):
    return act != 0 and (act & 0x1C0) == 0      # ACT_GROUP_STATIONARY


def set_warp(e, pc):
    if not st.pop("want_warp", False):
        return
    w = S["sWarpDest"]
    e.write32(w, (1 << 24) | (LEVEL_WMOTR << 16) | (1 << 8) | 0x0A)  # CHANGE_LEVEL, 31, area 1, node 0x0A
    e.write32(w + 4, 0)
    print("[bp] sWarpDest poked inside the frame", flush=True)


def state_complete(path):
    import gzip
    try:
        with gzip.open(path) as f:
            while f.read(1 << 20):
                pass
        return True
    except (OSError, EOFError):
        return False


def log(e, msg):
    print(f"[f{e.frame:5d}] {msg}", flush=True)


def vi(e):
    lvl = e.read16(S["gCurrLevelNum"])
    act = e.read32(ms + 12)
    mode = e.read16(S["sCurrPlayMode"])
    ph = st["phase"]
    if e.frame % 120 == 0:
        log(e, f"phase={ph} level={lvl} action={act:08x} playmode={mode}")
    if ph == "boot":
        if lvl == LEVEL_CASTLE_GROUNDS:
            # advance the intro dialog only while in a cutscene action (ACT_FLAG_INTANGIBLE);
            # otherwise hands off, so Mario settles into a stationary action
            e.keys = A if (act & 0x1000) and e.frame % 20 in (10, 11) else 0
        else:
            e.keys = (START if e.frame % 20 < 2 else 0) | (A if e.frame % 20 in (10, 11) else 0)
        if e.read32(MENU_SIG[0]) == MENU_SIG[1]:
            b = S_SELECTED_FILE_NUM
            e.write32(b & ~3, (e.read32(b & ~3) & ~(0xFF << (8 * (3 - (b & 3))))) | (1 << (8 * (3 - (b & 3)))))
        if lvl == LEVEL_CASTLE_GROUNDS and stationary(act) and mode == 0:
            st["idle"] += 1
            if st["idle"] > 30:
                log(e, "in castle grounds, idle: warping to WMotR via sWarpDest")
                # play_mode_normal clears sWarpDest at the top of each frame
                # (warp_area), then checks it after initiate_delayed_warp.  So poke
                # it at that function's entry, inside the frame, exactly once.
                st.update(phase="warp", idle=0, want_warp=True)
        else:
            st["idle"] = 0
    elif ph == "warp":
        e.keys = 0
        if lvl == LEVEL_WMOTR and stationary(act) and mode == 0:
            st["idle"] += 1
            if st["idle"] > 60:
                log(e, f"idle in WMotR; saving {OUT}")
                e.save_state(OUT)
                st["phase"] = "done"
        else:
            st["idle"] = 0
    elif ph == "done":
        # the core writes the savestate on a background thread: stop only once
        # the gzip stream is complete, or it is truncated
        if e.frame % 60 == 0 and state_complete(OUT):
            e.stop()
    if e.frame > 40000:
        log(e, "giving up")
        e.stop()


emu.on_vi = vi
# Breakpoints must be registered before running: adding one mid-run invalidates
# the cached interpreter's code blocks under the executing instruction (crash).
emu.add_bp(S["initiate_delayed_warp"], set_warp)
emu.run()
print("saved:", os.path.exists(OUT))
