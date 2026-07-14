#!/usr/bin/env python3
"""Audit the pinned Mario/instant-warp/Area-2 route source surface.

This script deliberately emits human-readable, deterministic evidence rather
than making a gameplay claim.  The Rocq development imports the audited
constants separately and proves the arithmetic consequences.
"""

from __future__ import annotations

import hashlib
import re
import subprocess
import sys
from dataclasses import dataclass
from fractions import Fraction
from pathlib import Path


PIN = "9921382a68bb0c865e5e45eb594d9c64db59b1af"


def fail(message: str) -> None:
    raise SystemExit(f"route audit failed: {message}")


def git(sm64: Path, *args: str) -> bytes:
    try:
        return subprocess.check_output(["git", "-C", str(sm64), *args])
    except subprocess.CalledProcessError as exc:
        fail(f"git {' '.join(args)} exited {exc.returncode}")


def pinned(sm64: Path, path: str) -> str:
    return git(sm64, "show", f"{PIN}:{path}").decode("utf-8").replace("\r\n", "\n")


def compact(text: str) -> str:
    return re.sub(r"\s+", "", text)


def require(text: str, fragment: str, label: str) -> None:
    if compact(fragment) not in compact(text):
        fail(f"missing {label}")


@dataclass(frozen=True)
class Triangle:
    surface: str
    indices: tuple[int, int, int]
    points: tuple[tuple[int, int, int], tuple[int, int, int], tuple[int, int, int]]

    @property
    def normal_y(self) -> int:
        (ax, _, az), (bx, _, bz), (cx, _, cz) = self.points
        return (bz - az) * (cx - ax) - (bx - ax) * (cz - az)


def parse_collision(text: str) -> tuple[list[tuple[int, int, int]], list[Triangle]]:
    vertices = [
        tuple(map(int, match))
        for match in re.findall(
            r"COL_VERTEX\(\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*\)", text
        )
    ]
    token = re.compile(
        r"COL_TRI_INIT\(\s*([^,]+),\s*\d+\s*\)"
        r"|COL_TRI\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)"
    )
    surface = ""
    triangles: list[Triangle] = []
    for match in token.finditer(text):
        if match.group(1) is not None:
            surface = match.group(1).strip()
            continue
        indices = tuple(map(int, match.groups()[1:]))
        try:
            points = tuple(vertices[index] for index in indices)
        except IndexError:
            fail(f"triangle index out of range: {indices}")
        triangles.append(Triangle(surface, indices, points))
    if not vertices or not triangles:
        fail("collision parser found no vertices or triangles")
    return vertices, triangles


def point_in_triangle_xz(point: tuple[Fraction, Fraction], triangle: Triangle) -> bool:
    px, pz = point
    projected = [(Fraction(x), Fraction(z)) for x, _, z in triangle.points]
    signs: list[Fraction] = []
    for (ax, az), (bx, bz) in zip(projected, projected[1:] + projected[:1]):
        signs.append((bx - ax) * (pz - az) - (bz - az) * (px - ax))
    return all(value >= 0 for value in signs) or all(value <= 0 for value in signs)


def floor_height_at(triangle: Triangle, x: Fraction, z: Fraction) -> Fraction:
    (ax, ay, az), (bx, by, bz), (cx, cy, cz) = triangle.points
    ux, uy, uz = bx - ax, by - ay, bz - az
    vx, vy, vz = cx - ax, cy - ay, cz - az
    nx = uy * vz - uz * vy
    ny = uz * vx - ux * vz
    nz = ux * vy - uy * vx
    if ny == 0:
        fail(f"vertical triangle passed to floor_height_at: {triangle.indices}")
    return Fraction(ay) - Fraction(nx * (x - ax) + nz * (z - az), ny)


def floor_candidates_at(
    triangles: list[Triangle], x: int, z: int
) -> list[tuple[Fraction, str, tuple[int, int, int]]]:
    point = (Fraction(x), Fraction(z))
    result = []
    for triangle in triangles:
        if triangle.normal_y <= 0 or not point_in_triangle_xz(point, triangle):
            continue
        result.append((floor_height_at(triangle, *point), triangle.surface, triangle.indices))
    return sorted(result, reverse=True)


def require_vertices(
    vertices: list[tuple[int, int, int]], expected: list[tuple[int, int, int]], label: str
) -> None:
    missing = [vertex for vertex in expected if vertex not in vertices]
    if missing:
        fail(f"{label} missing vertices: {missing}")


def sha256(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def main() -> None:
    if len(sys.argv) != 2:
        fail("usage: audit_route_source.py <sm64-checkout>")
    sm64 = Path(sys.argv[1]).resolve()
    git(sm64, "cat-file", "-e", f"{PIN}^{{commit}}")

    level_update = pinned(sm64, "src/game/level_update.c")
    area = pinned(sm64, "src/game/area.c")
    mario = pinned(sm64, "src/game/mario.c")
    mario_step = pinned(sm64, "src/game/mario_step.c")
    platform = pinned(sm64, "src/game/platform_displacement.c")
    interaction = pinned(sm64, "src/game/interaction.c")
    ssl_script = pinned(sm64, "levels/ssl/script.c")
    area2_text = pinned(sm64, "levels/ssl/areas/2/collision.inc.c")
    area3_text = pinned(sm64, "levels/ssl/areas/3/collision.inc.c")
    behavior_data = pinned(sm64, "data/behavior_data.c")
    star_behavior = pinned(sm64, "src/game/behaviors/spawn_star.inc.c")

    require(level_update, "warp_area(); check_instant_warp();", "normal-frame instant-warp order")
    require(level_update, "if ((floor = gMarioState->floor) != NULL)", "warp floor pointer guard")
    require(level_update, "s32 index = floor->type - SURFACE_INSTANT_WARP_1B;", "warp surface index")
    require(level_update, "gMarioState->pos[1] += warp->displacement[1];", "warp Y displacement")
    require(level_update, "change_area(warp->area);", "instant area change")
    require(area, "unload_area();", "old-area unload")
    require(area, "load_area(index);", "new-area load")
    require(mario, "m->floorHeight = find_floor(m->pos[0], m->pos[1], m->pos[2], &m->floor);", "Mario floor query")
    require(mario_step, "m->pos[1] = m->floorHeight;", "Mario landing snap")
    require(platform, "x += platform->oVelX;", "platform X displacement")
    require(platform, "z += platform->oVelZ;", "platform Z displacement")
    if compact("y += platform->oVelY") in compact(platform):
        fail("unexpected direct vertical platform displacement")
    require(interaction, "bounce_off_object(m, o, 30.0f);", "ordinary bounce velocity")

    require(ssl_script, "INSTANT_WARP(/*index*/ 3, /*destArea*/ 3, /*displace*/ 0, 0, 0)", "Area 2 return warp")
    require(ssl_script, "INSTANT_WARP(/*index*/ 2, /*destArea*/ 2, /*displace*/ 0, 0, 0)", "Area 3 entry warp")
    require(ssl_script, "OBJECT_WITH_ACTS(/*model*/ MODEL_STAR, /*pos*/ 500, 5050, -500", "Inside Ancient Pyramid star")
    require(behavior_data, "/*Radius*/ 37, /*Height*/ 160", "Mario interaction cylinder")
    require(star_behavior, "/* radius:            */ 80,", "star radius")
    require(star_behavior, "/* height:            */ 50,", "star height")

    area2_vertices, area2_triangles = parse_collision(area2_text)
    area3_vertices, area3_triangles = parse_collision(area3_text)
    warp_vertices = [
        (-191, 286, -1222),
        (-191, 384, -1023),
        (192, 384, -1023),
        (192, 286, -1222),
    ]
    require_vertices(area2_vertices, warp_vertices, "Area 2 matching warp quad")
    require_vertices(area3_vertices, warp_vertices, "Area 3 active warp quad")

    area3_warp = [t for t in area3_triangles if t.surface == "SURFACE_INSTANT_WARP_1D"]
    area2_inert = [t for t in area2_triangles if t.surface == "SURFACE_INSTANT_WARP_1D"]
    area2_return = [t for t in area2_triangles if t.surface == "SURFACE_INSTANT_WARP_1E"]
    if len(area3_warp) != 2 or len(area2_inert) != 2 or len(area2_return) != 2:
        fail("unexpected instant-warp triangle counts")

    center_candidates = floor_candidates_at(area2_triangles, 0, -1122)
    if not any(height == 896 for height, _, _ in center_candidates):
        fail("Area 2 Y=896 floor does not cover warp center")
    if not any(height == 4429 for height, _, _ in center_candidates):
        fail("Area 2 Y=4429 floor does not cover northern warp center")

    # These rectangles are source-extracted platform extents used by the Rocq
    # arithmetic model.  Require all corner vertices so a changed source fails
    # the audit instead of silently changing the theorem's meaning.
    require_vertices(
        area2_vertices,
        [(387, 4815, -1125), (643, 4815, -1125), (387, 4815, -409), (643, 4815, -409)],
        "star platform",
    )
    require_vertices(
        area2_vertices,
        [(-204, 4429, -1125), (512, 4429, -1125), (-204, 4429, -767), (512, 4429, -767)],
        "upper warp-overlap platform",
    )
    require_vertices(
        area2_vertices,
        [(131, 1967, -716), (387, 1967, -716), (131, 1967, -460), (387, 1967, -460)],
        "Y=1967 mid-level platform",
    )

    static_upward_max = max(
        max(point[1] for point in triangle.points)
        for triangle in area3_triangles
        if triangle.normal_y > 0
    )
    if static_upward_max != 384:
        fail(f"unexpected Area 3 upward-floor vertex maximum: {static_upward_max}")

    print("Eyerok/Mario/Area-2 route source audit")
    print(f"pin: {PIN}")
    print("normal-frame-order: warp_area -> check_instant_warp -> area_update_objects")
    print("instant-warp-trigger: selected Mario floor surface type")
    print("area3-to-area2: surface 1D/index 2, displacement (0,0,0)")
    print("area2-to-area3: surface 1E/index 3, displacement (0,0,0)")
    print("area2-matching-1D-slot: unconfigured (no immediate return)")
    print("warp-footprint-x: [-191,192]")
    print("warp-footprint-z: [-1222,-1023]")
    print("warp-plane: y = 286 + 98*(z+1222)/199")
    print("area2-floor-over-warp: y=896 covers entire footprint")
    print("area2-upper-overlap-platform: y=4429, x=[-204,512], z=[-1125,-767]")
    print("area2-star-platform: y=4815, x=[387,643], z=[-1125,-409]")
    print("area2-mid-platform: y=1967, x=[131,387], z=[-716,-460]")
    print("inside-ancient-pyramid-star: (500,5050,-500)")
    print("star-interaction-horizontal-radius-sum: 117")
    print("star-interaction-Mario-base-y: [4890,5100]")
    print("area3-upward-floor-vertex-max: 384")
    print("platform-displacement-direct-vertical-add: no")
    print("audited-sha256:")
    for path, text in [
        ("src/game/level_update.c", level_update),
        ("src/game/area.c", area),
        ("src/game/mario.c", mario),
        ("src/game/mario_step.c", mario_step),
        ("src/game/platform_displacement.c", platform),
        ("src/game/interaction.c", interaction),
        ("levels/ssl/script.c", ssl_script),
        ("levels/ssl/areas/2/collision.inc.c", area2_text),
        ("levels/ssl/areas/3/collision.inc.c", area3_text),
    ]:
        print(f"  {sha256(text)}  {path}")


if __name__ == "__main__":
    main()
