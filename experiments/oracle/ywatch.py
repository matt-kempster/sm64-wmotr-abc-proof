"""Watch every write to GOAL 2's height cells in the real game, under no-A input.

    python3 experiments/oracle/ywatch.py [N=600] [seed=1] [policy=noA|macro|boxsk|heldA] [spot]

This is a falsifier for HeightFrame's value-walk row `Hframe_is_move_chain` and for
the flank specs (TRUST 0.6, 0.7).  From wmotr_idle.st it plays N game frames of
seeded random input that never presses or holds A (policy heldA holds A down
from the start without a fresh press: the control that shows the held-A premise
matters; policy macro plays scripted no-A sequences instead of noise: long runs,
slide kicks, dive + B rollout, ground pounds, walking off ledges).  Memory write-watches sit on the cells Phi reads:

    MarioState  action @12, actionState/actionTimer @24, pos[1] @64,
                vel[1] @76, floorHeight @112
    marioObj    header.gfx.pos[1] @36

Every CPU store to them is logged with its PC, the function it is in, the
caller (from ra, for leaf helpers like vec3f_copy), whether it happened inside
execute_mario_action, and the old and new value.  Nothing is poked.

Output: ~/sm64-oracle/ywatch/<policy>-<seed>.jsonl, and a summary on stdout
(`--summary FILE...` re-summarizes existing logs).
"""
import bisect
import json
import math
import os
import random
import struct
import sys

sys.path.insert(0, os.path.dirname(__file__))
from m64 import Emu, pad, A, B, Z
import phi_check

ORACLE = os.path.expanduser("~/sm64-oracle")
ROM = f"{ORACLE}/decomp/build/us/sm64.us.z64"
MAP = f"{ORACLE}/decomp/build/us/sm64.us.map"
STATE = f"{ORACLE}/wmotr_idle.st"
RET_SITE = 0x8029CA70   # bhv_mario_update, after jal execute_mario_action
RA = 31

# cell -> (base, offset, kind); kind f = binary32, w = u32, hh = two u16
CELLS = {"action": ("ms", 12, "w"), "state_timer": ("ms", 24, "hh"),
         "posy": ("ms", 64, "f"), "vely": ("ms", 76, "f"),
         "floorh": ("ms", 112, "f"), "gfxy": ("obj", 36, "f")}

# pos[1] / gfx.pos[1] writers that HeightMoveCatalog's Move covers
# (docs/goal2-writers-vs-moves.md "Covered"), by function (or caller, for helpers)
COVERED_Y = {
    "perform_air_quarter_step", "perform_ground_quarter_step", "stationary_ground_step",
    "stop_and_set_height_to_floor", "check_ledge_grab", "act_ground_pound",
    "align_with_floor", "let_go_of_ledge", "f32_find_wall_collision",
    "update_mario_geometry_inputs",     # OOB recovery (S_oob)
    "perform_air_step", "perform_ground_step",
    "set_pole_position",                # pole attach
    "act_in_cannon",                    # cannon entry (wmotr_cannon attach)
    "bhv_mario_update",                 # copies pos into gfx (gfx := pos)
}
HELPERS = {"vec3f_copy", "vec3f_set", "vec3s_to_vec3f", "vec3f_to_object_pos",
           "memcpy", "bcopy"}


def f32(bits):
    return struct.unpack(">f", struct.pack(">I", bits))[0]


class Syms:
    def __init__(self, syms):
        items = sorted((a, n) for n, a in syms.items() if 0x80000400 <= a < 0x80400000)
        self.addrs = [a for a, _ in items]
        self.names = [n for _, n in items]

    def func(self, pc):
        i = bisect.bisect_right(self.addrs, pc) - 1
        return self.names[i] if i >= 0 else "?"


EPISODE = 300   # Mario frames per episode; each starts again from wmotr_idle.st

# Optional start spots (the only poke: Mario's pos, once per episode, before
# any logged frame).  A flag from a teleported episode is a LEAD, to be checked
# for reachability, not a counterexample by itself.
SPOTS = {
    # the highest wing-cap box top (K = 2424), next to the 5 summit poles
    "box2424": (-2760.0, 2424.0, -4080.0),
    # the box top at 2064
    "box2064": (-400.0, 2064.0, -120.0),
    # the same two tops with the wing-cap save flag set: without it the boxes
    # are intangible outlines (exclamation_box_act_1) and nobody stands on them
    "box2424w": (-2760.0, 2430.0, -4080.0),
    "box2064w": (-400.0, 2070.0, -120.0),
}
# WMotRWorld.wmotr_surface_types_value
WMOTR_SURFACE_TYPES = {5, 10, 21, 55, 0}
SAVE_FILE_SIZE, SAVE_FLAGS_OFF, SAVE_FLAG_HAVE_WING_CAP = 0x38, 8, 1 << 1


def record(n_frames, seed, policy, spot=None):
    out_dir = f"{ORACLE}/ywatch"
    os.makedirs(out_dir, exist_ok=True)
    out_path = f"{out_dir}/{policy}-{seed}{'-' + spot if spot else ''}.jsonl"
    out = open(out_path, "w")
    emu = Emu(ROM, MAP)
    S = emu.syms
    sy = Syms(S)
    ms = S["gMarioStates"]
    rng = random.Random(seed)
    st = {"loaded": False, "armed": False, "n": 0, "in_ema": False, "hold": 0,
          "keys": 0, "pending": None, "addr": {}, "shadow": {}, "writes": 0,
          "ep": 0, "ep_n": 0, "watched": False, "reload": False, "level": None}

    def cell_at(acc):
        for name, a in st["addr"].items():
            if a <= acc < a + 4:
                return name
        return None

    def read_cell(e, name):
        a = st["addr"][name]
        w = e.read32(a)
        kind = CELLS[name][2]
        if kind == "f":
            return f32(w)
        if kind == "hh":
            return [w >> 16, w & 0xFFFF]
        return w

    def on_write(e, pc, acc):
        if not st["armed"]:
            return
        name = cell_at(0x80000000 | acc)
        if name is None:
            return
        st["pending"] = (pc, name, e.reg(RA))
        e.stepping = True           # read the value one instruction later

    def on_step(e, pc):
        p, st["pending"] = st["pending"], None
        e.stepping = False
        if p is None:
            return
        wpc, name, ra = p
        new = read_cell(e, name)
        old = st["shadow"].get(name)
        st["shadow"][name] = new
        fn = sy.func(wpc)
        rec = {"ep": st["ep"], "level": e.read16(S["gCurrLevelNum"]), "f": st["n"], "ema": st["in_ema"], "cell": name, "pc": wpc, "fn": fn,
               "caller": sy.func(ra) if fn in HELPERS else None,
               "old": old, "new": new,
               "action": st["shadow"].get("action"), "vely": st["shadow"].get("vely")}
        out.write(json.dumps(rec) + "\n")
        st["writes"] += 1

    def world(e):
        """WMotRWorld.wmotr_world's fields: surface types at wall/ceil/floor
        (None = NULL), heldObj, riddenObj, quicksandDepth."""
        def stype(off):
            p = e.read32(ms + off)
            if p == 0:
                return None
            t = e.read16(p)
            return t - 0x10000 if t >= 0x8000 else t
        return {"wall": stype(96), "ceil": stype(100), "floor": stype(104),
                "held": e.read32(ms + 124), "ridden": e.read32(ms + 132),
                "qsd": f32(e.read32(ms + 192))}

    def on_entry(e, pc):
        st["in_ema"] = True

    def on_exit(e, pc):
        st["in_ema"] = False
        if not st["armed"]:
            return
        out.write(json.dumps({"ep": st["ep"], "f": st["n"], "frame_end": True,
                              "posy": read_cell(e, "posy"), "vely": read_cell(e, "vely"),
                              "action": read_cell(e, "action"),
                              "st_tm": read_cell(e, "state_timer"),
                              "floorh": read_cell(e, "floorh"), "gfxy": read_cell(e, "gfxy"),
                              "world": world(e),
                              "level": e.read16(S["gCurrLevelNum"])}) + "\n")
        st["n"] += 1
        st["ep_n"] += 1
        if st["ep_n"] >= (120 if policy == "boxsk" else EPISODE) or e.read16(S["gCurrLevelNum"]) != st["level"]:
            st["reload"] = True
            st["q"] = []
            st["armed"] = False
        if st["n"] % 100 == 0:
            print(f"[ywatch] {st['n']}/{n_frames} frames, {st['writes']} cell writes", flush=True)

    def macro():
        """One scripted no-A sequence, as a list of per-frame pads."""
        th = rng.uniform(0, 2 * math.pi)
        sx, sy = int(127 * math.cos(th)), int(127 * math.sin(th))
        run = lambda n, b=0: [pad(b, sx, sy)] * n
        kind = rng.choice(["slidekick", "slidekick", "shortsk", "shortsk", "dive", "pound", "run",
                           "crouchB", "turn"])
        if kind == "shortsk":          # a slide kick from a few steps (fits on a box top)
            return run(rng.randint(1, 6)) + run(1, Z) + run(1, Z | B) + run(rng.randint(10, 40), Z)
        if kind == "slidekick":        # walking Z -> crouch slide, B -> slide kick
            return run(rng.randint(8, 45)) + run(rng.randint(1, 3), Z) + run(1, Z | B) + run(rng.randint(10, 40), Z)
        if kind == "dive":             # B at speed -> dive; B in the dive slide -> rollout
            return run(rng.randint(25, 70)) + run(1, B) + run(rng.randint(6, 25)) + run(1, B) + run(rng.randint(10, 30))
        if kind == "pound":            # run (maybe off an edge) with Z pulses: GP if airborne
            return sum((run(rng.randint(3, 9)) + run(1, Z) for _ in range(rng.randint(3, 12))), [])
        if kind == "crouchB":          # crouch, then B
            return [pad(Z)] * rng.randint(2, 10) + [pad(Z | B)] + [pad(Z)] * rng.randint(5, 20)
        if kind == "turn":             # run, then snap the stick back (skid / sideflip-less turn)
            back = [pad(0, -sx, -sy)] * rng.randint(5, 20)
            return run(rng.randint(20, 50)) + back + run(1, B) + [0] * 5
        return run(rng.randint(10, 90))

    def next_keys():
        if policy == "boxsk":          # one slide kick per episode, from rest on the spot
            if not st.get("q"):
                th = rng.uniform(0, 2 * math.pi)
                sx, sy = int(127 * math.cos(th)), int(127 * math.sin(th))
                st["q"] = ([0] * 25 + [pad(0, sx, sy)] * rng.randint(3, 8) + [pad(Z, sx, sy)]
                           + [pad(Z | B, sx, sy)] + [pad(Z, sx, sy)] * rng.randint(5, 40)
                           + [0] * 400)
            return st["q"].pop(0)
        if policy == "macro":
            if not st.get("q"):
                st["q"] = macro()
            return st["q"].pop(0)
        if st["hold"] <= 0:
            st["hold"] = rng.randint(3, 25)
            mag = rng.choice([0, 40, 80, 127, 127])
            x, y = rng.randint(-mag, mag), rng.randint(-mag, mag)
            btn = rng.choices([0, B, Z, B | Z], weights=[5, 3, 3, 1])[0]
            st["keys"] = pad(btn, x, y)
        st["hold"] -= 1
        k = st["keys"] if st["hold"] % 2 == 0 else st["keys"] & ~0xFFFF
        if policy == "heldA":
            k |= A
        return k

    def vi(e):
        if e.frame > 4 * n_frames + 600:
            print("[vi] giving up", flush=True)
            e.stop()
        if not st["loaded"]:
            if e.frame < 60:
                return
            e.load_state(STATE)
            st["loaded"] = True
            st["arm_at"] = e.frame + 2
            return
        if st["reload"]:
            st["reload"] = False
            e.load_state(STATE)
            st["ep"] += 1
            st["ep_n"] = 0
            st["arm_at"] = e.frame + 2
            return
        if not st["armed"] and e.frame >= st["arm_at"]:
            obj = e.read32(ms + 136)
            assert obj == st["addr"]["gfxy"] - 36, (hex(obj), hex(st["addr"]["gfxy"]))
            st["level"] = e.read16(S["gCurrLevelNum"])
            if spot and spot.endswith("w"):
                # gSaveBuffer.files[gCurrSaveFileNum - 1][0].flags |= HAVE_WING_CAP
                fa = (S["gSaveBuffer"] + (e.read16(S["gCurrSaveFileNum"]) - 1) * 2 * SAVE_FILE_SIZE
                      + SAVE_FLAGS_OFF)
                e.write32(fa, e.read32(fa) | SAVE_FLAG_HAVE_WING_CAP)
            if spot:
                for k, v in enumerate(SPOTS[spot]):
                    e.write32(ms + 60 + 4 * k, struct.unpack(">I", struct.pack(">f", v))[0])
            for name in CELLS:
                st["shadow"][name] = read_cell(e, name)
                # the core rebuilds its memory handlers when emulation starts,
                # so write watches must be added while running, not before run()
                if not st["watched"]:
                    e.add_write_watch(st["addr"][name], 4)
            st["watched"] = True
            st["armed"] = True
        if policy in ("macro", "boxsk"):
            # scripted policies step once per Mario frame (the game polls once
            # per 2 VIs), so a one-entry B pulse is never missed
            if st.get("keys_n") != st["n"]:
                st["keys_n"], st["cur"] = st["n"], next_keys()
            e.keys = st["cur"]
        else:
            e.keys = next_keys()
        if st["n"] >= n_frames:
            e.stop()

    # The Mario object's address is fixed by the savestate (learned by --learn).
    obj = learn_mario_obj()
    for name, (base, off, _) in CELLS.items():
        st["addr"][name] = (ms if base == "ms" else obj) + off
    emu.on_vi = vi
    emu.on_write = on_write
    emu.on_step = on_step
    emu.add_bp(S["execute_mario_action"], on_entry)
    emu.add_bp(RET_SITE, on_exit)
    emu.run()
    out.close()
    print(f"[ywatch] wrote {out_path}")
    return out_path


def learn_mario_obj():
    cache = f"{ORACLE}/ywatch/mario_obj.txt"
    if os.path.exists(cache):
        return int(open(cache).read(), 16)
    raise SystemExit(f"run `python3 {__file__} --learn` first (writes {cache})")


def learn():
    emu = Emu(ROM, MAP)
    ms = emu.syms["gMarioStates"]
    st = {"loaded": False}

    def vi(e):
        if not st["loaded"]:
            if e.frame >= 60:
                e.load_state(STATE)
                st["loaded"] = e.frame
            return
        if e.frame >= st["loaded"] + 5:
            obj = e.read32(ms + 136)
            os.makedirs(f"{ORACLE}/ywatch", exist_ok=True)
            open(f"{ORACLE}/ywatch/mario_obj.txt", "w").write(f"{obj:#x}")
            print(f"[learn] marioObj = {obj:#x}")
            e.stop()

    emu.on_vi = vi
    emu.run()


def phi_bad(r):
    """Phi's numeric part (phi_check.py) on a frame-end record; None if the
    record predates the full cell set."""
    if "st_tm" not in r:
        return None
    a, (s, tm) = r["action"], r["st_tm"]
    y, v, fh, gy = r["posy"], r["vely"], r["floorh"], r["gfxy"]
    c = phi_check.credit(a, s, tm, v)
    bad = []
    if y + c > phi_check.K + phi_check.A:
        bad.append(f"budget {phi_check.K + phi_check.A - y - c:.2f}")
    if gy + c > phi_check.K + phi_check.A:
        bad.append(f"gfx budget {phi_check.K + phi_check.A - gy - c:.2f}")
    if not (-75 <= v <= phi_check.VMAX) or y < -8192 or gy < -8192:
        bad.append("range")
    if a == phi_check.SK and not (v + 2 * tm <= 37.5 + tm / 1024 or v <= -73):
        bad.append("sk-timer")
    if a == phi_check.GP and s != 0 and v > 0:
        bad.append("gp-vel")
    if a == phi_check.LEDGE and fh > phi_check.K:
        bad.append("ledge")
    w = r.get("world")
    if w is not None:
        if w["floor"] is None:
            bad.append("world: NULL floor")
        for k in ("wall", "ceil", "floor"):
            if w[k] is not None and w[k] not in WMOTR_SURFACE_TYPES:
                bad.append(f"world: {k} type {w[k]}")
        if w["held"] or w["ridden"] or w["qsd"] != 0.0:
            bad.append(f"world: held/ridden/quicksand {w}")
    return bad, phi_check.K + phi_check.A - y - c


def summarize(paths):
    from collections import Counter
    y_sites, flags, other, ymax = Counter(), [], Counter(), {}
    phi_n, phi_fail, slack_min = 0, [], None
    WMOTR = 31
    n_frames, exits = 0, 0
    for path in paths:
        rows = [json.loads(line) for line in open(path)]
        # a frame that ends outside WMotR is the level exit: not a step of the
        # capstone's run (HeightFrame.in_wmotr), so it is set aside
        gone = {(r["ep"], r["f"]) for r in rows
                if r.get("frame_end") and r.get("level", WMOTR) != WMOTR}
        exits += len(gone)
        for r in rows:
            if (r["ep"], r["f"]) in gone:
                continue
            if r.get("frame_end"):
                n_frames += 1
                ymax[r["action"]] = max(ymax.get(r["action"], -1e9), r["posy"])
                pb = phi_bad(r)
                if pb is not None:
                    phi_n += 1
                    if pb[0]:
                        phi_fail.append((pb[0], r))
                    if slack_min is None or pb[1] < slack_min[0]:
                        slack_min = (pb[1], r)
                continue
            who = r["caller"] or r["fn"]
            changed = r["old"] != r["new"]
            if r["cell"] in ("posy", "gfxy"):
                y_sites[(r["cell"], who, r["ema"], changed)] += 1
                if changed and not r["ema"] and r["cell"] == "posy":
                    flags.append(("pos[1] changed OUTSIDE execute_mario_action (flank spec says no)", r))
                elif changed and who not in COVERED_Y:
                    flags.append(("height write by a writer the Move catalog does not cover", r))
                elif (changed and isinstance(r["old"], float) and isinstance(r["new"], float)
                      and r["new"] > r["old"] and r["cell"] == "posy"
                      and who not in ("perform_air_quarter_step", "act_ground_pound",
                                      "perform_air_step", "check_ledge_grab",
                                      "perform_ground_quarter_step", "perform_ground_step",
                                      "stationary_ground_step", "align_with_floor",
                                      "stop_and_set_height_to_floor",
                                      "update_mario_geometry_inputs", "set_pole_position")):
                    flags.append(("pos[1] RAISED by an unexpected writer", r))
            else:
                other[(r["cell"], who, r["ema"])] += 1
    print("\n== height-cell writers (cell, writer, inside EMA, value changed): count ==")
    for k, v in sorted(y_sites.items(), key=lambda kv: -kv[1]):
        print(f"  {v:6d}  {k}")
    print("\n== other cells (cell, writer, inside EMA): count ==")
    for k, v in sorted(other.items(), key=lambda kv: -kv[1]):
        print(f"  {v:6d}  {k}")
    print(f"\n{n_frames} frames in WMotR; {exits} level-exit frames set aside")
    print("\n== max pos[1] at frame end, by action ==")
    for a, y in sorted(ymax.items(), key=lambda kv: -kv[1])[:15]:
        print(f"  {y:9.2f}  action {a:#010x}")
    print(f"\n== Phi (numeric part) at frame end: {phi_n} checked, {len(phi_fail)} violate ==")
    for bad, r in phi_fail[:10]:
        print(f"  {bad}: {r}")
    if slack_min:
        print(f"  tightest budget slack {slack_min[0]:.2f}: {slack_min[1]}")
    print(f"\n== FLAGS: {len(flags)} ==")
    seen = Counter()
    for why, r in flags:
        key = (why, r["caller"] or r["fn"])
        seen[key] += 1
        if seen[key] <= 3:
            print(f"  {why}: {r}")
    for key, v in seen.items():
        if v > 3:
            print(f"  ... {v} total of {key}")


if __name__ == "__main__":
    if sys.argv[1:2] == ["--learn"]:
        learn()
    elif sys.argv[1:2] == ["--summary"]:
        summarize(sys.argv[2:])
    else:
        n = int(sys.argv[1]) if len(sys.argv) > 1 else 600
        seed = int(sys.argv[2]) if len(sys.argv) > 2 else 1
        policy = sys.argv[3] if len(sys.argv) > 3 else "noA"
        spot = sys.argv[4] if len(sys.argv) > 4 else None
        assert policy in ("noA", "macro", "boxsk", "heldA") and (spot is None or spot in SPOTS)
        summarize([record(n, seed, policy, spot)])
