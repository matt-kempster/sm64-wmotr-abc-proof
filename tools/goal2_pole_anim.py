#!/usr/bin/env python3
"""
GOAL-2 pole reach (2026-10-21): how far above a pole's hitbox top can
set_pole_position put Mario?

set_pole_position (mario_actions_automatic.c:58-111) clamps
marioObj->oMarioPolePos to poleTop = hitboxHeight - 100 (:66-71), sets
    pos[1] = usedObj->oPosY + oMarioPolePos + offsetY            (:75)
lowers it under a ceiling (:80-84), and, when find_floor at the new spot is
above it, snaps it UP to that floor (:86-88).  act_holding_pole /
act_climbing_pole / act_grab_pole_* pass offsetY = 0; act_top_of_pole and
act_top_of_pole_transition pass return_mario_anim_y_translation(m)
(:278, :295), the current frame's y translation (s16 value / 4.0f,
mario.c:195) of MARIO_ANIM_START_HANDSTAND / RETURN_FROM_HANDSTAND /
HANDSTAND_IDLE (anims 0x0B, 0x0C, 0x09).

This reads those three animations from vendor/sm64/assets/anims and prints
the largest y translation, then the reach above the hitbox top
(oPosY + hitboxHeight):  -100 + max_y + 79, where 79 is find_floor's hit
bound above the truncated search y (FloorHeight / FloorList.hok: h <= y + 78
on the s16-truncated y, so < pos + 79).  HeightBudgetArith.POLE_UP must be
at least that.

FINDING (2026-10-21): max_y = 174 (HANDSTAND_IDLE holds 174 every frame), so
Mario's handstand puts him 74 ABOVE the pole's hitbox top.  The move catalog's
pole attach used to allow only h <= top, so every top-of-pole frame broke
HeightFrame's open rows (Hframe_is_move_chain) in the REAL game.
"""
import os
import re

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
# vendor/sm64 is a submodule; SM64_VENDOR overrides it (e.g. from a worktree)
ANIMS = os.path.join(os.environ.get("SM64_VENDOR", os.path.join(ROOT, "vendor", "sm64")),
                     "assets", "anims")

# (file, animation symbol, MARIO_ANIM_* name)
HANDSTAND = [
    ("anim_09.inc.c", "anim_09", "MARIO_ANIM_HANDSTAND_IDLE"),
    ("anim_0B_0C.inc.c", "anim_0B", "MARIO_ANIM_START_HANDSTAND"),
    ("anim_0B_0C.inc.c", "anim_0C", "MARIO_ANIM_RETURN_FROM_HANDSTAND"),
]

FIND_FLOOR_HIT = 79      # find_floor's height <= trunc(y) + 78 < y + 79
POLE_TOP_DROP = 100      # poleTop = hitboxHeight - 100


def array(src, name):
    m = re.search(r"%s\[\] = \{(.*?)\};" % re.escape(name), src, re.S)
    return [int(x, 16) for x in re.findall(r"0x[0-9A-Fa-f]+", m.group(1))]


def y_translations(fname, sym):
    src = open(os.path.join(ANIMS, fname)).read()
    st = re.search(r"struct Animation %s\[\] = \{(.*?)\};" % re.escape(sym), src, re.S).group(1)
    fields = [x.strip() for x in st.split(",")]
    values_name, index_name = fields[6], fields[7]
    index = array(src, index_name)
    values = [v - 65536 if v >= 32768 else v for v in array(src, values_name)]
    # index entries are (count, start) pairs; pair 1 is the y translation
    count, start = index[2], index[3]
    return [v / 4.0 for v in values[start:start + count]]


def main():
    best = None
    for fname, sym, name in HANDSTAND:
        ys = y_translations(fname, sym)
        print("%-34s %-8s frames %3d  y translation %.2f .. %.2f" % (name, sym, len(ys), min(ys), max(ys)))
        best = max(ys) if best is None else max(best, max(ys))
    reach = -POLE_TOP_DROP + best + FIND_FLOOR_HIT
    print("max handstand y translation: %.2f" % best)
    print("above the hitbox top: handstand %.2f, with a floor snap %.2f" % (best - POLE_TOP_DROP, reach))
    print("POLE_UP must be >= %.2f" % reach)


if __name__ == "__main__":
    main()
