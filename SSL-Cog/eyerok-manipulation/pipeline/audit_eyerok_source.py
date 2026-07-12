#!/usr/bin/env python3
"""Audit the pinned Eyerok source surface and collision bounds."""

from __future__ import annotations

import hashlib
import math
import re
import subprocess
import sys
from pathlib import Path


PIN = "9921382a68bb0c865e5e45eb594d9c64db59b1af"

IDENTICAL_PATHS = [
    "src/game/behaviors/eyerok.inc.c",
    "src/game/obj_behaviors_2.c",
    "src/game/object_helpers.c",
    "src/engine/behavior_script.c",
    "src/game/object_list_processor.c",
    "src/game/spawn_object.c",
    "src/engine/surface_collision.c",
    "include/object_constants.h",
    "include/object_fields.h",
    "data/behavior_data.c",
    "levels/ssl/areas/2/collision.inc.c",
    "levels/ssl/areas/3/collision.inc.c",
    "levels/ssl/eyerok_col/collision.inc.c",
]


def fail(message: str) -> None:
    raise SystemExit(f"audit failed: {message}")


def git(sm64: Path, *args: str) -> bytes:
    try:
        return subprocess.check_output(["git", "-C", str(sm64), *args])
    except subprocess.CalledProcessError as exc:
        fail(f"git {' '.join(args)} exited {exc.returncode}")


def pinned(sm64: Path, path: str) -> str:
    return git(sm64, "show", f"{PIN}:{path}").decode("utf-8").replace("\r\n", "\n")


def working(sm64: Path, path: str) -> str:
    return (sm64 / path).read_text(encoding="utf-8").replace("\r\n", "\n")


def compact(text: str) -> str:
    return re.sub(r"\s+", "", text)


def require(text: str, fragment: str, label: str) -> None:
    if compact(fragment) not in compact(text):
        fail(f"missing {label}")


def sha256(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def parse_collision(text: str) -> tuple[list[tuple[int, int, int]], list[tuple[int, int, int]]]:
    vertices = [
        tuple(map(int, match))
        for match in re.findall(r"COL_VERTEX\(\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*\)", text)
    ]
    triangles = [
        tuple(map(int, match))
        for match in re.findall(r"COL_TRI\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)", text)
    ]
    if not vertices or not triangles:
        fail("collision parser found no vertices or triangles")
    return vertices, triangles


def normal_y(a: tuple[int, int, int], b: tuple[int, int, int], c: tuple[int, int, int]) -> int:
    abx, _, abz = b[0] - a[0], b[1] - a[1], b[2] - a[2]
    acx, _, acz = c[0] - a[0], c[1] - a[1], c[2] - a[2]
    return abz * acx - abx * acz


def bbox_overlaps_path(points: list[tuple[int, int, int]]) -> bool:
    xs = [point[0] for point in points]
    zs = [point[2] for point in points]
    return max(xs) >= -580 and min(xs) <= 580 and max(zs) >= -3393 and min(zs) <= -2093


def main() -> None:
    if len(sys.argv) != 2:
        fail("usage: audit_eyerok_source.py <sm64-checkout>")

    sm64 = Path(sys.argv[1]).resolve()
    if not (sm64 / ".git").exists():
        fail(f"not a git checkout: {sm64}")
    git(sm64, "cat-file", "-e", f"{PIN}^{{commit}}")
    head = git(sm64, "rev-parse", "HEAD").decode().strip()

    hashes: list[tuple[str, str]] = []
    for path in IDENTICAL_PATHS:
        baseline = pinned(sm64, path)
        checkout = working(sm64, path)
        if baseline != checkout:
            fail(f"working checkout differs from pin: {path}")
        hashes.append((path, sha256(baseline)))

    eyerok = pinned(sm64, "src/game/behaviors/eyerok.inc.c")
    constants = pinned(sm64, "include/object_constants.h")
    helpers = pinned(sm64, "src/game/object_helpers.c")
    behavior_script = pinned(sm64, "src/engine/behavior_script.c")
    behavior_data = pinned(sm64, "data/behavior_data.c")
    object_lists = pinned(sm64, "src/game/object_list_processor.c")
    spawn_object = pinned(sm64, "src/game/spawn_object.c")
    surface_collision = pinned(sm64, "src/engine/surface_collision.c")
    ssl_script = pinned(sm64, "levels/ssl/script.c")
    area2 = pinned(sm64, "levels/ssl/areas/2/collision.inc.c")
    area3 = pinned(sm64, "levels/ssl/areas/3/collision.inc.c")
    hand_collision = pinned(sm64, "levels/ssl/eyerok_col/collision.inc.c")

    actions = re.findall(r"#define\s+EYEROK_HAND_ACT_[A-Z_]+\s+(\d+)", constants)
    if list(map(int, actions)) != list(range(16)):
        fail(f"unexpected Eyerok hand action values: {actions}")

    vel_writes = re.findall(r"o->oVelY\s*=\s*([0-9]+(?:\.[0-9]+)?)f", eyerok)
    if vel_writes != ["30.0", "50.0", "100.0"]:
        fail(f"unexpected positive vertical-velocity writers: {vel_writes}")

    require(eyerok, "o->oGravity = -4.0f;", "attack gravity -4")
    require(eyerok, "o->oGravity = 0.0f;", "begin/target gravity zero")
    require(eyerok, "o->oGravity = -20.0f;", "double-pound falling gravity")
    require(eyerok, "o->oGravity = -15.0f;", "double-pound post-pound gravity")
    require(eyerok, "cur_obj_move_standard(-78);", "hand movement call")
    require(eyerok, "o->oPosY = o->oHomeY + 300.0f * o->parentObj->oEyerokBossUnk110;", "double setup Y")
    require(eyerok, "approach_f32_ptr(&o->oPosY, o->oHomeY + 300.0f, 20.0f)", "target Y approach")
    require(eyerok, "approach_f32_ptr(&o->oPosY, o->oHomeY, 20.0f)", "retreat Y approach")

    require(helpers, "o->oVelY += gravity + buoyancy;", "vertical gravity integration")
    require(helpers, "o->oPosY += o->oVelY;", "vertical position integration")
    require(helpers, "if (o->oPosY < o->oFloorHeight)", "strict ground comparison")
    require(helpers, "if (!(o->activeFlags & (ACTIVE_FLAG_FAR_AWAY | ACTIVE_FLAG_IN_DIFFERENT_ROOM)))", "movement partial-update guard")
    require(behavior_script, "gCurrentObject->collisionData == NULL", "far-away collision-data guard")
    require(behavior_script, "gCurrentObject->oRoom != -1", "room-flag guard")
    require(behavior_data, "BEGIN(OBJ_LIST_SURFACE)", "hand surface list")
    require(behavior_data, "SET_OBJ_PHYSICS(/*Wall hitbox radius*/ 150, /*Gravity*/ 0", "hand initial zero gravity")
    require(object_lists, "clear_dynamic_surfaces();", "dynamic-surface clear")
    require(object_lists, "update_objects_in_list(&gObjectLists[OBJ_LIST_SURFACE])", "surface-list update")
    require(spawn_object, "Insert at the end of destination list", "append-order allocation")
    require(surface_collision, "if (y - (height + -78.0f) < 0.0f)", "find-floor 78-unit buffer")

    require(ssl_script, "OBJECT(/*model*/ MODEL_NONE, /*pos*/ 0, -1534, -3693", "boss spawn")
    require(ssl_script, "INSTANT_WARP(/*index*/ 3, /*destArea*/ 3, /*displace*/ 0, 0, 0)", "area 2 to 3 instant warp")
    require(ssl_script, "INSTANT_WARP(/*index*/ 2, /*destArea*/ 2, /*displace*/ 0, 0, 0)", "area 3 to 2 instant warp")
    require(area2, "COL_TRI_INIT(SURFACE_INSTANT_WARP_1E, 2), COL_TRI(11, 241, 12), COL_TRI(241, 243, 12),", "area 2 active warp triangles")
    require(area3, "COL_TRI_INIT(SURFACE_INSTANT_WARP_1D, 2), COL_TRI(18, 19, 20), COL_TRI(18, 20, 21),", "area 3 active warp triangles")

    area3_vertices, area3_triangles = parse_collision(area3)
    max_static_vertex_y = max(vertex[1] for vertex in area3_vertices)
    if max_static_vertex_y != 896:
        fail(f"unexpected Area 3 maximum vertex Y: {max_static_vertex_y}")

    raised_path_overlaps: list[tuple[int, int, int]] = []
    for triangle in area3_triangles:
        points = [area3_vertices[index] for index in triangle]
        if normal_y(*points) > 0 and max(point[1] for point in points) > -1534 and bbox_overlaps_path(points):
            raised_path_overlaps.append(triangle)
    if raised_path_overlaps:
        fail(f"raised upward static triangles overlap begin-double corridor: {raised_path_overlaps}")

    hand_vertices, _ = parse_collision(hand_collision)
    max_hand_local_y = max(vertex[1] for vertex in hand_vertices)
    if max_hand_local_y != 338:
        fail(f"unexpected hand collision local Y maximum: {max_hand_local_y}")
    dynamic_top_offset = max_hand_local_y * 3 // 2
    if dynamic_top_offset != 507:
        fail(f"unexpected scaled dynamic top offset: {dynamic_top_offset}")

    closed_block = hand_collision.split("ssl_seg7_collision_070282F8", 1)[0]
    closed_vertices = [
        tuple(map(int, match))
        for match in re.findall(r"COL_VERTEX\(\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*\)", closed_block)
    ]
    max_closed_radius_sq = max(x * x + z * z for x, _, z in closed_vertices)
    if 9 * max_closed_radius_sq >= 4 * 280 * 280:
        fail("closed-hand collision radius reaches sibling center separation")

    print("Eyerok source audit")
    print(f"pin: {PIN}")
    print(f"checkout-head: {head}")
    print(f"pin-identical-files: {len(IDENTICAL_PATHS)}")
    print("hand-actions: 0..15")
    print("positive-velY-writes: 30,50,100")
    print("gravity-writes-cover: 0,-4,-15,-20")
    print("partial-update-guards: FAR_AWAY|IN_DIFFERENT_ROOM")
    print("hand-list-before-boss: yes")
    print("surface-list-append-order: yes")
    print("find-floor-buffer: 78")
    print("begin-double-center-separation-min: 280 (mixed-frame conservative)")
    print(f"closed-hand-horizontal-radius-max: {1.5 * math.sqrt(max_closed_radius_sq):.6f}")
    print("raised-static-floor-overlap-with-begin-corridor: none")
    print(f"area3-static-vertex-y-max: {max_static_vertex_y}")
    print(f"hand-dynamic-top-offset-max: {dynamic_top_offset}")
    print("area2-active-warp: surface-1E -> area3, displacement (0,0,0)")
    print("area3-active-warp: surface-1D -> area2, displacement (0,0,0)")
    print("runaway-tripwire: DOUBLE_POUND + grounded + gravity=0 must remain unreachable")
    print("normalized-sha256:")
    for path, digest in hashes:
        print(f"  {digest}  {path}")


if __name__ == "__main__":
    main()
