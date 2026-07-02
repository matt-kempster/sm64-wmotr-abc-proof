#!/usr/bin/env python3
"""
GOAL-2 (WMotR ABC-impossibility) numeric sanity gate  --  task E1.

Parses the WMotR static collision mesh directly from the decomp source
(no hand-transcribed data), classifies every triangle as floor/wall/ceiling
EXACTLY the way the game's surface_load.c does, and computes the "floor
ladder" fixpoint H* from the Mario spawn floor.  Then it checks the GAP FACT
that GOAL-2's whole architecture rests on:

    no WMotR floor height lies in (H*, H* + DELTA]

for DELTA in {316, 366, 400}.  If the gap fact FAILS for some DELTA, that
DELTA's ladder climbs to a new floor and the fixpoint is re-computed; the
script reports the counterexample floor loudly.

Sources (cite file:line):
  - vendor/sm64/levels/wmotr/areas/1/collision.inc.c   (vertex + triangle lists)
  - vendor/sm64/levels/wmotr/areas/1/macro.inc.c        (boxes, coins, objects)
  - vendor/sm64/levels/wmotr/script.c:65                (MARIO_POS spawn)
  - vendor/sm64/actors/exclamation_box_outline/collision.inc.c (box: top face y=+52)
  - vendor/sm64/src/engine/surface_load.c:113-126       (floor iff normal.y > 0.01)
  - vendor/sm64/src/engine/surface_load.c:322-352       (normal from vertex winding)

Floor-classification reproduction (surface_load.c:read_surface_data):
    nx = (y2-y1)*(z3-z2) - (z2-z1)*(y3-y2)
    ny = (z2-z1)*(x3-x2) - (x2-x1)*(z3-z2)
    nz = (x2-x1)*(y3-y2) - (y2-y1)*(x3-x2)
    mag = sqrt(nx^2+ny^2+nz^2)     ; if mag < 0.0001: surface dropped (return NULL)
    normal.y = ny/mag
  add_surface_to_cell (:113): normal.y > 0.01  -> FLOOR
                              normal.y < -0.01 -> CEILING
                              else             -> WALL
"""

import math
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
COLLISION = os.path.join(REPO, "vendor/sm64/levels/wmotr/areas/1/collision.inc.c")

# --- spawn & object data (cited; positions are literal, no scaling) ----------
SPAWN = (-67, 1669, -16)          # script.c:65 MARIO_POS
BOX_TOP_OFFSET = 52               # exclamation_box_outline/collision.inc.c:11-14 (top face y = +52)

# macro.inc.c wing-cap boxes (macro_box_wing_cap): pos = oHomeY; dynamic floor top = y+52
WING_CAP_BOXES = [  # (x, y, z, macro.inc.c line)
    (-400, 1960, -120, 15),
    (-240, -1080, 4520, 16),
    (3600, -2480, 5440, 17),
    (3960,  520,  440, 18),
    (-3200, 4880, -4040, 19),
    (-2760, 2320, -4080, 20),
]

# macro.inc.c red coins (macro_red_coin), in file order
RED_COINS = [  # (x, y, z, macro.inc.c line)
    (-2980, 3990, -4248, 9),
    ( 2735, 3140, -3085, 10),
    (-3640, 4600, -4200, 11),
    ( 4400,  240,   80, 12),
    ( 3440, -2680, 5240, 13),
    ( -600, -1360, 5040, 14),
    (  320, 1725,   40, 22),
    (-2560, 4600, -4800, 23),
]

DELTAS = [316, 366, 400]

# ---------------------------------------------------------------------------
def parse_collision(path):
    """Return (vertices, sections) where sections=[(surftype,[(i,j,k),...]),...]."""
    txt = open(path).read()
    verts = []
    for m in re.finditer(r"COL_VERTEX\(\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*\)", txt):
        verts.append((int(m.group(1)), int(m.group(2)), int(m.group(3))))
    # walk line by line to keep tri sections grouped by their COL_TRI_INIT surftype
    sections = []
    cur_type = None
    cur = []
    for line in txt.splitlines():
        mi = re.search(r"COL_TRI_INIT\(\s*([A-Z_0-9]+)\s*,\s*(\d+)\s*\)", line)
        if mi:
            if cur_type is not None:
                sections.append((cur_type, cur))
            cur_type = mi.group(1)
            cur = []
            continue
        mt = re.search(r"COL_TRI\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)", line)
        if mt and cur_type is not None:
            cur.append((int(mt.group(1)), int(mt.group(2)), int(mt.group(3))))
    if cur_type is not None:
        sections.append((cur_type, cur))
    return verts, sections


def classify(v1, v2, v3):
    """Reproduce surface_load.c read_surface_data + add_surface_to_cell.
    Returns ('floor'|'ceil'|'wall'|'dropped', normal_y, minY, maxY)."""
    x1, y1, z1 = v1
    x2, y2, z2 = v2
    x3, y3, z3 = v3
    nx = (y2 - y1) * (z3 - z2) - (z2 - z1) * (y3 - y2)
    ny = (z2 - z1) * (x3 - x2) - (x2 - x1) * (z3 - z2)
    nz = (x2 - x1) * (y3 - y2) - (y2 - y1) * (x3 - x2)
    mag = math.sqrt(nx * nx + ny * ny + nz * nz)
    if mag < 0.0001:
        return ("dropped", 0.0, min(y1, y2, y3), max(y1, y2, y3))
    nyn = ny / mag
    if nyn > 0.01:
        cls = "floor"
    elif nyn < -0.01:
        cls = "ceil"
    else:
        cls = "wall"
    return (cls, nyn, min(y1, y2, y3), max(y1, y2, y3))


def plane_height(v1, v2, v3, px, pz):
    """Height of the triangle's plane at (px,pz): -(nx*x + nz*z + oo)/ny.
    Returns None if degenerate/vertical."""
    x1, y1, z1 = v1
    x2, y2, z2 = v2
    x3, y3, z3 = v3
    nx = (y2 - y1) * (z3 - z2) - (z2 - z1) * (y3 - y2)
    ny = (z2 - z1) * (x3 - x2) - (x2 - x1) * (z3 - z2)
    nz = (x2 - x1) * (y3 - y2) - (y2 - y1) * (x3 - x2)
    mag = math.sqrt(nx * nx + ny * ny + nz * nz)
    if mag < 0.0001:
        return None
    nx, ny, nz = nx / mag, ny / mag, nz / mag
    if abs(ny) < 1e-9:
        return None
    oo = -(nx * x1 + ny * y1 + nz * z1)
    return -(nx * px + nz * pz + oo) / ny


def point_in_tri_xz(v1, v2, v3, px, pz):
    """find_floor's in-triangle test uses xz cross products (surface_collision.c).
    Reproduce the sign test."""
    x1, z1 = v1[0], v1[2]
    x2, z2 = v2[0], v2[2]
    x3, z3 = v3[0], v3[2]
    d12 = (x1 - px) * (z2 - pz) - (x2 - px) * (z1 - pz)
    d23 = (x2 - px) * (z3 - pz) - (x3 - px) * (z2 - pz)
    d31 = (x3 - px) * (z1 - pz) - (x1 - px) * (z3 - pz)
    # game: if any of these products cross zero the point is outside.
    if d12 * d23 < 0 or d23 * d31 < 0:
        return False
    return True


# ---------------------------------------------------------------------------
def ladder(sorted_heights, start_max, delta):
    """Fixpoint: H starts at start_max, absorb any floor <= H+delta, repeat.
    Returns (Hstar, first_excluded_height_or_None)."""
    H = start_max
    while True:
        cand = [h for h in sorted_heights if h <= H + delta]
        newH = max(cand) if cand else H
        if newH <= H:
            break
        H = newH
    above = [h for h in sorted_heights if h > H]
    first_excl = min(above) if above else None
    return H, first_excl


def main():
    verts, sections = parse_collision(COLLISION)
    print(f"# parsed {len(verts)} vertices, "
          f"{sum(len(t) for _,t in sections)} triangles from {os.path.relpath(COLLISION, REPO)}")
    print("# tri sections:", [(s, len(t)) for s, t in sections])

    floor_heights = []            # maxY of every static floor triangle
    floor_records = []            # (surftype, maxY, minY, normal_y)
    cls_counts = {}
    for surftype, tris in sections:
        for (i, j, k) in tris:
            v1, v2, v3 = verts[i], verts[j], verts[k]
            cls, nyn, miny, maxy = classify(v1, v2, v3)
            cls_counts[cls] = cls_counts.get(cls, 0) + 1
            if cls == "floor":
                floor_heights.append(maxy)
                floor_records.append((surftype, maxy, miny, nyn))

    print("# triangle classification:", cls_counts)

    # --- static floor height summary ---
    static_floor_max = max(floor_heights)
    print(f"\n# static floor triangles: {len(floor_heights)}")
    print(f"# static floor maxY range: {min(floor_heights)} .. {static_floor_max}")

    # box tops (dynamic floors)
    box_tops = [(y + BOX_TOP_OFFSET, ln, (x, y, z)) for (x, y, z, ln) in WING_CAP_BOXES]
    print("\n# wing-cap box tops (dynamic floors, oHomeY+52):")
    for top, ln, pos in sorted(box_tops):
        print(f"#   top y={top:6d}  (box home {pos}, macro.inc.c:{ln})")

    # full floor set = static floor maxY multiset + box tops
    all_floor_heights = sorted(floor_heights + [t for t, _, _ in box_tops])

    # --- spawn floor: find floor triangles containing (spawn.x, spawn.z) ---
    px, pz = SPAWN[0], SPAWN[2]
    spawn_candidates = []
    for surftype, tris in sections:
        for (i, j, k) in tris:
            v1, v2, v3 = verts[i], verts[j], verts[k]
            cls, nyn, miny, maxy = classify(v1, v2, v3)
            if cls != "floor":
                continue
            if point_in_tri_xz(v1, v2, v3, px, pz):
                h = plane_height(v1, v2, v3, px, pz)
                if h is not None:
                    spawn_candidates.append((h, surftype, maxy))
    print(f"\n# floor triangles under spawn xz=({px},{pz}): {len(spawn_candidates)}")
    for h, st, maxy in sorted(spawn_candidates, reverse=True):
        print(f"#   plane_height={h:.2f}  ({st}, triMaxY={maxy})")
    # find_floor returns the highest floor whose height <= spawnY+78 buffer.
    spawnY = SPAWN[1]
    below = [h for (h, _, _) in spawn_candidates if h <= spawnY + 78]
    spawn_floor_h = max(below) if below else (max(h for h, _, _ in spawn_candidates)
                                              if spawn_candidates else spawnY)
    print(f"# spawn_floor_height (highest floor <= spawnY+78={spawnY+78}) = {spawn_floor_h:.2f}")

    # ladder start set: floors whose height <= spawn_floor_height + 100
    start_thresh = spawn_floor_h + 100
    start_set = [h for h in all_floor_heights if h <= start_thresh]
    start_max = max(start_set)
    print(f"\n# ladder start set: floors with height <= spawn_floor+100 = {start_thresh:.2f}")
    print(f"# start_max (H before laddering) = {start_max}")

    # --- run the ladder for each DELTA ---
    max_airborne_extra = 238  # ledge-grab window; box-top margin vs H*+238
    print("\n" + "=" * 72)
    for delta in DELTAS:
        Hstar, first_excl = ladder(all_floor_heights, start_max, delta)
        gap = (first_excl - Hstar) if first_excl is not None else None
        holds = (first_excl is None) or (first_excl - Hstar > delta)
        print(f"\nDELTA = {delta}")
        print(f"  H* (max reachable floor height) = {Hstar}")
        if first_excl is None:
            print("  first excluded floor above H*: NONE (H* is the global max floor)")
            print("  GAP FACT for this DELTA: HOLDS (no floor above H*)")
        else:
            print(f"  first excluded floor above H*  = {first_excl}   (gap = {gap})")
            print(f"  GAP FACT for this DELTA: {'HOLDS' if holds else 'FAILS'}"
                  f"  (need gap > {delta}; gap = {gap})")
        # per-coin margins vs H* + delta and vs H* + 238 (airborne envelope)
        y_max_air = Hstar + delta
        print(f"  Y_MAX(air) = H*+DELTA = {y_max_air}")
        for idx, (x, y, z, ln) in enumerate(RED_COINS, 1):
            margin = y - y_max_air
            tag = "OK(unreachable)" if margin >= 200 else ("<200!" if margin > 0 else "*** BELOW ENVELOPE ***")
            print(f"    coin#{idx} y={y:6d} (macro.inc.c:{ln}) margin vs Y_MAX = {margin:+d}  {tag}")
        # box-top margins vs max airborne y = H*+238
        y_air238 = Hstar + max_airborne_extra
        print(f"  box-top margins vs H*+238={y_air238}:")
        for top, bln, pos in sorted(box_tops):
            m = top - y_air238
            print(f"    box top y={top:6d} (macro.inc.c:{bln}) margin = {m:+d}")

    print("\n" + "=" * 72)
    print("# NOTE: the ladder ignores horizontal feasibility (sound over-approx).")
    print("# A DELTA whose gap-fact FAILS means some floor is within DELTA of the")
    print("# reachable set purely by height -- a counterexample to investigate.")


if __name__ == "__main__":
    main()
