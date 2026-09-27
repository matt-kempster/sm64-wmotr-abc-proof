#!/usr/bin/env python3
"""
GOAL-2 gap-fact re-check over each floor triangle's FULL y-range.

find_floor returns the PLANE height of a floor triangle at the (s16-truncated)
query (x, z) -- surface_collision.c:455 -- not the triangle's maxY.  Over the
closed xz-triangle the exact plane height ranges over [minY, maxY], so the gap
fact must be stated over ranges:

    no attachable floor triangle has [minY, maxY] meeting (H*, H* + MOAT)

This script reuses goal2_ladder.py's parser/classifier (same data, same
surface_load.c classification), then:
  1. lists every floor triangle whose range meets (H*, H*+MOAT) or straddles H*;
  2. reports the smallest margin (minY - H* for triangles wholly above H*);
  3. checks wing-cap box tops (flat, y+52) and pole grab windows;
  4. emulates the game's binary32 plane evaluation
     (surface_load.c:322-372 normal/originOffset, surface_collision.c:455)
     at every vertex and at integer points along every edge, and reports the
     largest overshoot of the returned height outside [minY, maxY].
"""
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import goal2_ladder as L  # noqa: E402

HSTAR = 2372
MOAT = 622
F = np.float32


def game_surface(v1, v2, v3):
    """binary32 emulation of read_surface_data (surface_load.c:322-372).
    nx/ny/nz are f32 locals; the vertex differences are s32 (exact), the
    products are int arithmetic promoted to f32 on assignment."""
    x1, y1, z1 = v1
    x2, y2, z2 = v2
    x3, y3, z3 = v3
    nx = F((y2 - y1) * (z3 - z2) - (z2 - z1) * (y3 - y2))
    ny = F((z2 - z1) * (x3 - x2) - (x2 - x1) * (z3 - z2))
    nz = F((x2 - x1) * (y3 - y2) - (y2 - y1) * (x3 - x2))
    mag = F(np.sqrt(F(F(F(nx * nx) + F(ny * ny)) + F(nz * nz)), dtype=F))
    if mag < 0.0001:
        return None
    inv = F(1.0 / float(mag))
    nx, ny, nz = F(nx * inv), F(ny * inv), F(nz * inv)
    oo = F(-F(F(F(nx * F(x1)) + F(ny * F(y1))) + F(nz * F(z1))))
    return nx, ny, nz, oo


def game_height(s, x, z):
    nx, ny, nz, oo = s
    return float(F(-F(F(F(F(x) * nx) + F(nz * F(z))) + oo) / ny))


def edge_points(a, b, n=400):
    (xa, _, za), (xb, _, zb) = a, b
    pts = set()
    for i in range(n + 1):
        x = round(xa + (xb - xa) * i / n)
        z = round(za + (zb - za) * i / n)
        pts.add((x, z))
    return pts


def in_tri_game(v1, v2, v3, x, z):
    """surface_collision.c:419-432, exact s32 test (edges inclusive)."""
    x1, z1, x2, z2, x3, z3 = v1[0], v1[2], v2[0], v2[2], v3[0], v3[2]
    if (z1 - z) * (x2 - x1) - (x1 - x) * (z2 - z1) < 0:
        return False
    if (z2 - z) * (x3 - x2) - (x2 - x) * (z3 - z2) < 0:
        return False
    if (z3 - z) * (x1 - x3) - (x3 - x) * (z1 - z3) < 0:
        return False
    return True


def main():
    verts, sections = L.parse_collision(L.COLLISION)
    floors = []
    for st, tris in sections:
        for (i, j, k) in tris:
            v = (verts[i], verts[j], verts[k])
            cls, nyn, mn, mx = L.classify(*v)
            if cls == "floor":
                floors.append((st, (i, j, k), v, mn, mx, nyn))
    print(f"# floor triangles: {len(floors)}; H* = {HSTAR}, moat = {MOAT}, "
          f"forbidden open band ({HSTAR}, {HSTAR + MOAT})")

    lo, hi = HSTAR, HSTAR + MOAT
    sloped = [f for f in floors if f[3] != f[4]]
    print(f"# sloped floor triangles (minY != maxY): {len(sloped)}")

    bad = [f for f in floors if f[4] > lo and f[3] < hi]
    print(f"\n## floors whose [minY,maxY] meets ({lo},{hi}): {len(bad)}")
    for st, idx, v, mn, mx, nyn in bad:
        print(f"   {st} tri{idx} y-range [{mn},{mx}] ny={nyn:.3f} verts={v}")

    straddle = [f for f in floors if f[3] <= lo < f[4] or f[3] < hi <= f[4]]
    print(f"## floors straddling H* or H*+moat: {len(straddle)}")
    for st, idx, v, mn, mx, nyn in straddle:
        print(f"   {st} tri{idx} [{mn},{mx}]")

    below = [f for f in floors if f[4] <= lo]
    above = [f for f in floors if f[3] >= hi]
    top_below = max(f[4] for f in below)
    bot_above = min(f[3] for f in above) if above else None
    print(f"\n## highest floor maxY <= H*: {top_below} (H* - that = {lo - top_below})")
    near = sorted(below, key=lambda f: -f[4])[:5]
    for st, idx, v, mn, mx, nyn in near:
        print(f"   {st} tri{idx} [{mn},{mx}] ny={nyn:.3f}")
    if above:
        m = bot_above - lo
        print(f"## lowest floor minY above band: {bot_above}  (minY - H* = {m}, "
              f"slack over moat = {m - MOAT})")
        for st, idx, v, mn, mx, nyn in sorted(above, key=lambda f: f[3])[:5]:
            print(f"   {st} tri{idx} [{mn},{mx}] ny={nyn:.3f}")

    print("\n## wing-cap box tops (flat, oHomeY+52):")
    for (x, y, z, ln) in L.WING_CAP_BOXES:
        t = y + L.BOX_TOP_OFFSET
        tag = "IN BAND!" if lo < t < hi else ("<=H*" if t <= lo else f"above, minus H* = {t - lo}")
        print(f"   macro.inc.c:{ln} top {t}: {tag}")

    print("\n## pole grab windows [base-160, top] (as goal2_ladder.py):")
    for (x, by, z, bp2, ln) in L.POLES:
        top = by + bp2 * 10
        gb = by - L.MARIO_GRAB_SLACK
        print(f"   script.c:{ln} window [{gb},{top}]  grab-bottom - H* = {gb - lo}"
              f"  vs YMAX=2744: {gb - 2744:+d}")

    # --- binary32 overshoot ---
    worst = (0.0, None)
    for st, idx, v, mn, mx, nyn in floors:
        s = game_surface(*v)
        if s is None:
            continue
        pts = set()
        for a, b in ((v[0], v[1]), (v[1], v[2]), (v[2], v[0])):
            pts |= edge_points(a, b)
        for (x, z) in pts:
            if not in_tri_game(*v, x, z):
                continue
            h = game_height(s, x, z)
            over = max(h - mx, mn - h, 0.0)
            if over > worst[0]:
                worst = (over, (st, idx, mn, mx, nyn, x, z, h))
    print(f"\n## binary32 plane-eval overshoot outside [minY,maxY] "
          f"(vertices + integer edge points): max {worst[0]:.6f}")
    if worst[1]:
        print(f"   at {worst[1]}")
    minny = min(f[5] for f in floors)
    print(f"## smallest floor normal.y = {minny:.4f}")


if __name__ == "__main__":
    main()
