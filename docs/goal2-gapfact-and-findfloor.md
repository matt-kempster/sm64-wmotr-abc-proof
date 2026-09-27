# GOAL 2: the gap fact over triangle y-ranges, and the find_floor value contract

Script: `tools/goal2_gapfact_check.py`. It reuses the parser and classifier from
`tools/goal2_ladder.py`. Run it with `python3 tools/goal2_gapfact_check.py`.
Paths below are relative to `vendor/sm64/` unless they say otherwise.

## 1. What the ladder tool measures

`goal2_ladder.py` gives each floor triangle a single rung at its **maxY**
(`floor_heights.append(maxy)` in `main`). The plane height at a point is used only
for the spawn floor (`plane_height` at spawn x,z). So the tool's gap fact is
really about the maxY values.

`find_floor` returns the **plane height** at the query (x, z)
(`src/engine/surface_collision.c:455`). Over the closed triangle in the xz-plane,
the exact plane takes every value in [minY, maxY]. The fact the proof needs is
therefore:

> No floor triangle Mario can attach to has [minY, maxY] meeting (H*, H*+622) = (2372, 2994).

### Results (778 floor triangles, 398 of them sloped)

| check | result |
|---|---|
| static floor triangles whose [minY,maxY] meets (2372, 2994) | **0** |
| triangles straddling H* or H*+622 | **0** |
| highest static floor below the band | maxY 2017, flat (tris (4,5,6) etc.): 355 below H* |
| lowest static floor above the band | minY 4468, sloped [4468,4537], tri (373,372,375) etc.: **H*+2096**, 1474 more than the 622 moat |
| wing-cap box tops (flat, oHomeY+52) | 2012, −1028, −2428, 572, **2372 (= H*, macro.inc.c:20)**, 4932 (H*+2560) |
| pole grab windows [base−160, top] | lowest bottom **2994 = H*+622** (script.c:22, base 3154). Next are 3199 (script.c:21) and 3404 (script.c:20) |

The static mesh leaves a gap of about 2450 units (2017 to 4468). The two ends of
the gap fact are both **objects**:

- H* itself is the top of the wing-cap box at macro.inc.c:20 (2320+52). That top is
  flat, so min = max and slope does not matter.
- The moat 622 is set exactly by the grab bottom of the script.c:22 pole
  (3154−160). This is an open-interval boundary with **zero slack**. It depends
  on `MARIO_GRAB_SLACK = 160` being the true reach below the pole base. That
  should be checked against `interact_pole` and the hitbox overlap test (Mario's
  hitbox height 160, the pole's downOffset). If Mario's reach below the base is
  even one unit more than 160, the moat shrinks below 622.

**The smallest margin is therefore 0, at the pole.** For floors (triangles plus
box tops), the smallest margin above the band is 1474 (static, minY 4468) and
1938 (the box top at 4932). No floor, sloped or flat, comes near the band. The
sloped-range refinement changes nothing: every sloped triangle lies entirely
below 2017 or entirely above 4468.

**Other dynamic floors the ladder tool leaves out** (all harmless):

- `macro_box_1up` at macro.inc.c:7, y 4899, top 4951: above the band.
- The two `macro_cannon_closed` lids at macro.inc.c:3-4, y 827 and −2740, with
  flat collision at local y=0 (`actors/cannon_lid/collision.inc.c:7-10`):
  below H*.

These objects should be added to the tool's rung list so it is complete. The
level has no `SURFACE_INTANGIBLE` (grep count 0).

### Binary32 overshoot

The script emulates `read_surface_data` in binary32 (normal, `1.0/mag`, and
`originOffset`, at `src/engine/surface_load.c:322-372`). It then emulates the
height expression at `surface_collision.c:455` at every vertex and every integer
lattice point along every edge that passes the exact point-in-triangle test.
The largest excursion outside [minY, maxY] is **0.000977**, about 2 ulp at
y≈4537 (tri (416,415,671), ny=0.59). The smallest floor normal.y in WMotR is
0.5476, so the division by ny amplifies error by at most about 2x.

A crude analytic bound: the terms are |x·nx|, |z·nz|, |oo| ≤ ~1.6e4, with about 4
roundings at ulp(1.6e4) = 2^-9 ≈ 0.002 each, divided by ny ≥ 0.54. That gives
**< 0.02**. Interior points are convex combinations and have no worse error.
**A proof-safe overshoot allowance is 1 unit.** Against margins of 355 and 1474
it is irrelevant. Against the pole's zero-slack boundary it does not apply,
because poles are not find_floor results.

## 2. The find_floor value contract (US, `src/engine/surface_collision.c`)

`find_floor(xPos, yPos, zPos, &pfloor)` (:513-575) works as follows:

1. It truncates the inputs: `x = (TerrainData) xPos`, and the same for y and z
   (:524-526). `TerrainData` is `Collision` = s16 (`include/types.h:57`), so the
   f32→s16 conversion truncates toward zero. For in-range values, `(s16)y ≤ y`
   when y ≥ 0 and `(s16)y ≤ y+1` when y < 0. **If |xPos|, |zPos|, |yPos| ≥ 32768
   the conversion wraps (PU)**. The contract must either assume that y is in s16
   range or state the result in terms of `(s16)yPos`.
2. If x or z is outside (−8192, 8192), it returns −11000 = FLOOR_LOWER_LIMIT
   (:530-535, `surface_collision.h:9,14`).
3. It picks the cell `((x+8192)/1024) & 15` (:538-539) and scans the **dynamic**
   list and then the **static** list for that cell's floors (:542-548). Each scan
   is `find_floor_from_list` (:401-470). That function walks the `surfaceNode`
   linked list and **returns the first** surface (not the highest) that meets
   all of these:
   - (x, z) lies in the closed xz-triangle, by an exact s32 cross-product test.
     Edges are inclusive, and the test assumes the winding of an upward-facing
     triangle (:419-432).
   - The surface is not `SURFACE_CAMERA_BOUNDARY`, or not `NO_CAM_COLLISION` when
     checking for the camera (:435-443).
   - `ny != 0` (:450).
   - `y - (height + -78) >= 0`, where `height = -(x*nx + nz*z + oo)/ny` is
     evaluated in f32 at the **integer** x, z (:455-461). In other words
     `height ≤ (s16)y + 78` (up to f32 rounding of the subtraction).

   When a surface is found, `*pheight = height`. Otherwise `*pheight` keeps
   −11000.
4. For SURFACE_INTANGIBLE (not present in WMotR) it rescans the static list at
   `(s32)(height−200)` (:555-560).
5. The result is `max(dynamicHeight, staticHeight)` (:567-570).

**Contract (arg-aware).** Let yq = (s16)yPos and let (xq, zq) be the truncated
coordinates. The result h is either −11000, or h = fl32(plane_T(xq, zq)) for some
floor surface T in the loaded static or dynamic floor lists for that cell such that:

- (xq, zq) ∈ closed xz-hull(T);
- h ≤ yq + 78.

Consequently h ∈ [minY_T − ε, maxY_T + ε] with ε ≤ 1 (measured 0.001), and
h ≤ yPos + 79 for any yPos in s16 range (the extra 1 is truncation for
negative y). The contract does **not** say h is the highest such floor
(surface cucking, :463-467). The GOAL-2 attach argument needs only the upper
bound and membership in the floor set, so this does not matter. The floor set
must include the dynamic surfaces: six wing-cap boxes, the 1up box, and two
cannon lids.

## 3. The other find_floor callers

- **Ledge grab**, `src/game/mario_step.c:348-386`, `check_ledge_grab`. It needs
  `vel[1] ≤ 0` (:354). It calls `find_floor(ledgeX, nextPos[1] + 160, ledgeZ)`
  (:371), so h ≤ (s16)(nextY+160) + 78 ≤ nextY + 238 (+1 if the argument is
  negative). It then requires h − nextY > 100 (:373). **The ledge window is
  (nextY+100, nextY+238]**, or 239 with the negative-y truncation. The +239 in
  goal2-phi.md §3.4 is a correct (slightly loose) bound. With y ≤ K+A = 2744 the
  attached floor is ≤ 2983 < 2994: a margin of **11** against the band's open
  top. The bound only needs to stay below the next floor, which is 4468, so the
  real slack is ~1485. The binding band edge 2994 comes from the pole, not from
  a floor. For floors specifically, the attach step only needs ≤ 2983 < 4468.
- **`find_floor_height_relative_polar`**, `src/game/mario.c:674-684`. It queries
  at `pos[1] + 100` at a horizontal offset, so h ≤ y + 178 (+1). It is used for
  floor-slope / step checks (`mario.c:698-699` `find_floor_slope` uses the same
  +100). Its value only feeds angle and slope decisions, not `m->floorHeight`
  or `m->pos[1]`. It gives an attach-free bound of y + 179, well inside +239.
- The landing / air-step `find_floor` calls query at Mario's own y, so their
  window is +78 (+1).

## 4. Bottom line

- The gap fact holds over full triangle y-ranges, with binary32 rounding (≤ 0.001)
  and the dynamic box tops and cannon lids included.
- Floor margins: 355 below H* (static), 0 at H* (the box top *is* H*), and 1474
  above the band.
- The only tight edge is the **pole at script.c:22, whose grab bottom is
  exactly H*+622**. Check the `MARIO_GRAB_SLACK = 160` modelling there (the
  `interact_pole` hitbox overlap) before relying on the moat.
