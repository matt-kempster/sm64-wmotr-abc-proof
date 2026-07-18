#!/usr/bin/env python3
"""Audit the US SSL pole-transfer source and collision literals."""

from __future__ import annotations

import argparse
import hashlib
import re
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path


POLE = (0, 3200, 1331)
POLE_PARAMETER = 92
FIFTH_SUPPORT = (593, 1010, 807)
FIFTH_SUPPORT_POINTS = {
    (-204, 3200, 1536),
    (205, 3200, 1126),
    (-204, 3200, 1126),
}
SIXTH_FLOOR_Y = 3942
SIXTH_TRIANGLES = {
    (283, 298, 284),
    (284, 298, 285),
    (284, 285, 299),
    (285, 300, 301),
    (285, 301, 299),
    (283, 286, 298),
    (286, 301, 300),
    (286, 283, 301),
}
INNER_RECTANGLE = {
    (-101, 3942, 1229),
    (102, 3942, 1229),
    (102, 3942, 1434),
    (-101, 3942, 1434),
}
OUTER_RECTANGLE = {
    (-1535, 3942, 922),
    (1536, 3942, 922),
    (1536, 3942, 1536),
    (-1535, 3942, 1536),
}


@dataclass(frozen=True)
class Triangle:
    line: int
    surface: str
    indices: tuple[int, int, int]
    points: tuple[tuple[int, int, int], ...]

    @property
    def cross(self) -> tuple[int, int, int]:
        (ax, ay, az), (bx, by, bz), (cx, cy, cz) = self.points
        ux, uy, uz = bx - ax, by - ay, bz - az
        vx, vy, vz = cx - ax, cy - ay, cz - az
        return (
            uy * vz - uz * vy,
            uz * vx - ux * vz,
            ux * vy - uy * vx,
        )

    @property
    def horizontal_up(self) -> bool:
        nx, ny, nz = self.cross
        return nx == 0 and ny > 0 and nz == 0


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def normalized(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def extract_braced(text: str, marker_pattern: str) -> str:
    marker = re.search(marker_pattern, text, flags=re.MULTILINE)
    require(marker is not None, f"source marker not found: {marker_pattern}")
    opening = text.find("{", marker.start())
    require(opening >= 0, f"opening brace not found: {marker_pattern}")
    depth = 0
    for index in range(opening, len(text)):
        if text[index] == "{":
            depth += 1
        elif text[index] == "}":
            depth -= 1
            if depth == 0:
                return text[opening + 1 : index]
    raise SystemExit(f"unclosed source body: {marker_pattern}")


def function_body(text: str, name: str) -> str:
    return extract_braced(text, rf"\b{re.escape(name)}\s*\([^;{{}}]*\)\s*\{{")


def parse_collision(path: Path) -> tuple[list[tuple[int, int, int]], list[Triangle]]:
    vertices: list[tuple[int, int, int]] = []
    triangles: list[Triangle] = []
    surface = "SURFACE_UNKNOWN"
    declared_vertices = None
    group_declared = None
    group_seen = 0
    group_name = ""

    vertex_init_re = re.compile(r"COL_VERTEX_INIT\((0x[0-9A-Fa-f]+|\d+)\)")
    vertex_re = re.compile(r"COL_VERTEX\((-?\d+),\s*(-?\d+),\s*(-?\d+)\)")
    tri_init_re = re.compile(r"COL_TRI_INIT\(([^,]+),\s*(\d+)\)")
    tri_re = re.compile(
        r"COL_TRI(?:_SPECIAL)?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*[^)]*)?\)"
    )

    for line_no, line in enumerate(path.read_text().splitlines(), 1):
        match = vertex_init_re.search(line)
        if match:
            declared_vertices = int(match.group(1), 0)
            continue

        match = vertex_re.search(line)
        if match:
            vertices.append(tuple(map(int, match.groups())))
            continue

        match = tri_init_re.search(line)
        if match:
            if group_declared is not None:
                require(
                    group_seen == group_declared,
                    f"triangle group {group_name} declares {group_declared}, found {group_seen}",
                )
            surface = match.group(1).strip()
            group_name = surface
            group_declared = int(match.group(2))
            group_seen = 0
            continue

        match = tri_re.search(line)
        if match:
            indices = tuple(map(int, match.groups()))
            require(max(indices) < len(vertices), f"triangle index out of range at line {line_no}")
            triangles.append(
                Triangle(
                    line=line_no,
                    surface=surface,
                    indices=indices,
                    points=tuple(vertices[index] for index in indices),
                )
            )
            group_seen += 1
            continue

        if "COL_TRI_STOP()" in line and group_declared is not None:
            require(
                group_seen == group_declared,
                f"triangle group {group_name} declares {group_declared}, found {group_seen}",
            )
            group_declared = None

    require(declared_vertices == 1080, f"unexpected declared vertex count: {declared_vertices}")
    require(len(vertices) == declared_vertices, "collision vertex count does not match declaration")
    require(len(triangles) == 1558, f"unexpected triangle count: {len(triangles)}")
    return vertices, triangles


def edge_value(point: tuple[int, int], first: tuple[int, int, int], second: tuple[int, int, int]) -> int:
    x, z = point
    x1, _y1, z1 = first
    x2, _y2, z2 = second
    return (z1 - z) * (x2 - x1) - (x1 - x) * (z2 - z1)


def point_in_up_triangle(point: tuple[int, int], triangle: Triangle) -> bool:
    values = [
        edge_value(point, triangle.points[index], triangle.points[(index + 1) % 3])
        for index in range(3)
    ]
    return all(value >= 0 for value in values)


def boundary_vertices(triangles: list[Triangle]) -> set[tuple[int, int, int]]:
    edge_counts: dict[frozenset[tuple[int, int, int]], int] = defaultdict(int)
    for triangle in triangles:
        for index in range(3):
            edge = frozenset(
                (triangle.points[index], triangle.points[(index + 1) % 3])
            )
            edge_counts[edge] += 1
    return {
        vertex
        for edge, count in edge_counts.items()
        if count == 1
        for vertex in edge
    }


def check_geometry(root: Path) -> None:
    collision = root / "levels/ssl/areas/2/collision.inc.c"
    _vertices, triangles = parse_collision(collision)

    supports = [
        triangle
        for triangle in triangles
        if triangle.horizontal_up
        and triangle.surface == "SURFACE_DEFAULT"
        and point_in_up_triangle((POLE[0], POLE[2]), triangle)
        and all(point[1] == POLE[1] for point in triangle.points)
    ]
    require(len(supports) == 1, f"expected one pole-base support, found {len(supports)}")
    require(supports[0].indices == FIFTH_SUPPORT, "pole-base support indices changed")
    require(set(supports[0].points) == FIFTH_SUPPORT_POINTS, "pole-base support vertices changed")

    sixth = [
        triangle
        for triangle in triangles
        if triangle.horizontal_up
        and triangle.surface == "SURFACE_CAMERA_FREE_ROAM"
        and all(point[1] == SIXTH_FLOOR_Y for point in triangle.points)
    ]
    require(len(sixth) == 8, f"expected eight sixth-floor triangles, found {len(sixth)}")
    require({triangle.indices for triangle in sixth} == SIXTH_TRIANGLES, "sixth-floor triangles changed")
    require(
        boundary_vertices(sixth) == INNER_RECTANGLE | OUTER_RECTANGLE,
        "sixth-floor inner/outer boundary vertices changed",
    )
    require(
        not any(point_in_up_triangle((POLE[0], POLE[2]), triangle) for triangle in sixth),
        "pole center is no longer inside the sixth-floor opening",
    )

    west = POLE[0] - min(point[0] for point in INNER_RECTANGLE)
    east = max(point[0] for point in INNER_RECTANGLE) - POLE[0]
    z_low = POLE[2] - min(point[2] for point in INNER_RECTANGLE)
    z_high = max(point[2] for point in INNER_RECTANGLE) - POLE[2]
    require((west, east, z_low, z_high) == (101, 102, 102, 103), "hole clearance changed")


def check_sources(root: Path) -> list[tuple[str, str]]:
    paths = {
        "ssl_script": root / "levels/ssl/script.c",
        "behavior_data": root / "data/behavior_data.c",
        "pole_behavior": root / "src/game/behaviors/pole.inc.c",
        "pole_base": root / "src/game/behaviors/pole_base.inc.c",
        "automatic": root / "src/game/mario_actions_automatic.c",
        "interaction": root / "src/game/interaction.c",
        "mario": root / "src/game/mario.c",
        "airborne": root / "src/game/mario_actions_airborne.c",
        "mario_step": root / "src/game/mario_step.c",
        "object_helpers": root / "src/game/object_helpers.c",
        "object_lists": root / "src/game/object_list_processor.c",
        "collision": root / "levels/ssl/areas/2/collision.inc.c",
    }
    texts = {name: path.read_text() for name, path in paths.items()}

    placements = re.findall(
        r"OBJECT\s*\(\s*/\*model\*/\s*MODEL_NONE,\s*/\*pos\*/\s*"
        r"(-?\d+),\s*(-?\d+),\s*(-?\d+),.*?BPARAM2\((\d+)\).*?bhvPoleGrabbing\s*\)",
        texts["ssl_script"],
    )
    parsed_placements = [tuple(map(int, placement)) for placement in placements]
    require(POLE + (POLE_PARAMETER,) in parsed_placements, "upper pole placement changed")

    pole_script = normalized(extract_braced(texts["behavior_data"], r"\bbhvPoleGrabbing\s*\[\s*\]\s*="))
    for fragment in (
        "BEGIN(OBJ_LIST_POLELIKE)",
        "SET_INT(oInteractType, INTERACT_POLE)",
        "CALL_NATIVE(bhv_pole_init)",
        "CALL_NATIVE(bhv_pole_base_loop)",
    ):
        require(fragment in pole_script, f"pole behavior-script fragment changed: {fragment}")
    require(
        re.search(r"SET_HITBOX\([^)]*\b80\b[^)]*\b1500\b[^)]*\)", pole_script) is not None,
        "pole behavior-script hitbox changed",
    )

    pole_init = normalized(function_body(texts["pole_behavior"], "bhv_pole_init"))
    require("(o->oBhvParams >> 16) & 0xFF" in pole_init, "pole parameter extraction changed")
    require("o->hitboxHeight = tenthHitboxHeight * 10" in pole_init, "pole height scaling changed")

    set_position = normalized(function_body(texts["automatic"], "set_pole_position"))
    require("m->usedObj->hitboxHeight - 100.0f" in set_position, "pole-top offset changed")
    require("m->pos[0] = m->usedObj->oPosX" in set_position, "pole X pin changed")
    require("m->pos[2] = m->usedObj->oPosZ" in set_position, "pole Z pin changed")

    holding = normalized(function_body(texts["automatic"], "act_holding_pole"))
    z_branch = holding.find("(m->input & INPUT_Z_PRESSED) || m->health < 0x100")
    a_branch = holding.find("m->input & INPUT_A_PRESSED", max(z_branch, 0))
    require(0 <= z_branch < a_branch, "US holding-pole Z/A branch order changed")
    require("m->forwardVel = -2.0f" in holding, "holding-pole non-A speed changed")
    require("ACT_SOFT_BONK" in holding and "ACT_WALL_KICK_AIR" in holding, "holding-pole exits changed")

    climbing = normalized(function_body(texts["automatic"], "act_climbing_pole"))
    require("INPUT_A_PRESSED" in climbing and "ACT_WALL_KICK_AIR" in climbing, "climbing A exit changed")
    require("poleTop - 0.4f" in holding and "stickY > 50.0f" in holding, "pole-top transition gate changed")

    top = normalized(function_body(texts["automatic"], "act_top_of_pole"))
    require("INPUT_A_PRESSED" in top and "ACT_TOP_OF_POLE_JUMP" in top, "top-of-pole A exit changed")
    require("stickY < -16.0f" in top and "ACT_TOP_OF_POLE_TRANSITION" in top, "top return changed")

    pole_interaction = normalized(function_body(texts["interaction"], "interact_pole"))
    require("m->vel[1] = 0.0f" in pole_interaction, "pole grab no longer clears vertical velocity")
    require("m->forwardVel = 0.0f" in pole_interaction, "pole grab no longer clears forward velocity")

    buttons = normalized(function_body(texts["mario"], "update_mario_button_inputs"))
    require("buttonPressed & A_BUTTON" in buttons and "m->input |= INPUT_A_PRESSED" in buttons, "A-edge mapping changed")

    airborne_setup = normalized(function_body(texts["mario"], "set_mario_action_airborne"))
    require("case ACT_WALL_KICK_AIR: case ACT_TOP_OF_POLE_JUMP:" in airborne_setup, "pole jump action cases changed")
    require("set_mario_y_vel_based_on_fspeed(m, 62.0f, 0.0f)" in airborne_setup, "pole jump Y speed changed")
    require("m->forwardVel < 24.0f" in airborne_setup and "m->forwardVel = 24.0f" in airborne_setup, "pole jump minimum speed changed")

    air_update = normalized(function_body(texts["airborne"], "update_air_without_turn"))
    require("approach_f32(m->forwardVel, 0.0f, 0.35f, 0.35f)" in air_update, "air drag changed")

    air_step = normalized(function_body(texts["mario_step"], "perform_air_step"))
    require("for (i = 0; i < 4; i++)" in air_step, "air quarter-step count changed")
    gravity = normalized(function_body(texts["mario_step"], "apply_gravity"))
    require("m->vel[1] -= 4.0f" in gravity, "ordinary gravity changed")

    pole_base = normalized(function_body(texts["pole_base"], "bhv_pole_base_loop"))
    require("cur_obj_push_mario_away(70.0f)" in pole_base, "pole push radius changed")
    push = normalized(function_body(texts["object_helpers"], "cur_obj_push_mario_away"))
    require("marioDist < radius" in push, "pole push guard changed")
    require("(radius - marioDist) / radius * marioRelX" in push, "pole X push formula changed")
    require("(radius - marioDist) / radius * marioRelZ" in push, "pole Z push formula changed")

    order = normalized(extract_braced(texts["object_lists"], r"\bsObjectListUpdateOrder\s*\[\s*\]\s*="))
    require(order.find("OBJ_LIST_POLELIKE") < order.find("OBJ_LIST_PLAYER"), "pole/player update order changed")

    hashes = []
    for name, path in sorted(paths.items()):
        digest = hashlib.sha256(path.read_bytes().replace(b"\r\n", b"\n")).hexdigest()
        hashes.append((name, digest))
    return hashes


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source_root", type=Path)
    args = parser.parse_args()
    root = args.source_root.resolve()

    check_geometry(root)
    hashes = check_sources(root)

    print("pole_transfer_source_collision_certificate=OK")
    print("mesh vertices=1080 triangles=1558")
    print("pole=(0,3200,1331) parameter=92")
    print("fifth y=3200 surface=SURFACE_DEFAULT support=(593,1010,807)")
    print("sixth y=3942 surface=SURFACE_CAMERA_FREE_ROAM triangles=8")
    print("hole x=[-101,102] z=[1229,1434] size=203x205")
    print("clearance west/east/zlow/zhigh=101/102/102/103 min=101")
    print("rise=742 grip_top_y=4020 margin=78")
    for name, digest in hashes:
        print(f"sha256 {name}={digest}")


if __name__ == "__main__":
    main()
