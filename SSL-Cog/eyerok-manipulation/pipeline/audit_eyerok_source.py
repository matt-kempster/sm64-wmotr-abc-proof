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
    "src/engine/surface_load.c",
    "include/object_constants.h",
    "include/object_fields.h",
    "data/behavior_data.c",
    "actors/eyerok/anims/anim_0500DF50.inc.c",
    "actors/eyerok/anims/anim_0500E99C.inc.c",
    "levels/ssl/areas/2/collision.inc.c",
    "levels/ssl/areas/3/collision.inc.c",
    "levels/ssl/areas/3/macro.inc.c",
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


def named_collision_block(text: str, name: str) -> str:
    match = re.search(
        rf"const\s+Collision\s+{re.escape(name)}\[\]\s*=\s*\{{(.*?)\n\}};",
        text,
        re.DOTALL,
    )
    if match is None:
        fail(f"missing collision array: {name}")
    return match.group(1)


def upward_triangle_top(
    vertices: list[tuple[int, int, int]], triangles: list[tuple[int, int, int]]
) -> int:
    upward = [
        triangle
        for triangle in triangles
        if normal_y(*(vertices[index] for index in triangle)) > 0
    ]
    if not upward:
        fail("collision array has no upward triangle")
    return max(max(vertices[index][1] for index in triangle) for triangle in upward)


def normal_y(a: tuple[int, int, int], b: tuple[int, int, int], c: tuple[int, int, int]) -> int:
    abx, _, abz = b[0] - a[0], b[1] - a[1], b[2] - a[2]
    acx, _, acz = c[0] - a[0], c[1] - a[1], c[2] - a[2]
    return abz * acx - abx * acz


def point_in_triangle_xz(
    point: tuple[int, int],
    a: tuple[int, int, int],
    b: tuple[int, int, int],
    c: tuple[int, int, int],
) -> bool:
    px, pz = point
    projected = [(a[0], a[2]), (b[0], b[2]), (c[0], c[2])]
    signs = []
    for (ax, az), (bx, bz) in zip(projected, projected[1:] + projected[:1]):
        signs.append((bx - ax) * (pz - az) - (bz - az) * (px - ax))
    return all(value >= 0 for value in signs) or all(value <= 0 for value in signs)


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
    surface_load = pinned(sm64, "src/engine/surface_load.c")
    ssl_script = pinned(sm64, "levels/ssl/script.c")
    area2 = pinned(sm64, "levels/ssl/areas/2/collision.inc.c")
    area3 = pinned(sm64, "levels/ssl/areas/3/collision.inc.c")
    area3_macros = pinned(sm64, "levels/ssl/areas/3/macro.inc.c")
    hand_collision = pinned(sm64, "levels/ssl/eyerok_col/collision.inc.c")
    die_animation = pinned(sm64, "actors/eyerok/anims/anim_0500DF50.inc.c")
    attacked_animation = pinned(sm64, "actors/eyerok/anims/anim_0500E99C.inc.c")

    actions = re.findall(r"#define\s+EYEROK_HAND_ACT_[A-Z_]+\s+(\d+)", constants)
    if list(map(int, actions)) != list(range(16)):
        fail(f"unexpected Eyerok hand action values: {actions}")

    vel_writes = re.findall(r"o->oVelY\s*=\s*([0-9]+(?:\.[0-9]+)?)f", eyerok)
    if vel_writes != ["30.0", "50.0", "100.0"]:
        fail(f"unexpected positive vertical-velocity writers: {vel_writes}")

    gravity_writes = re.findall(r"o->oGravity\s*=\s*(-?[0-9]+(?:\.[0-9]+)?)f", eyerok)
    if gravity_writes != ["-4.0", "0.0", "0.0", "-4.0", "-4.0", "-20.0", "-15.0", "-20.0"]:
        fail(f"unexpected gravity writer sequence: {gravity_writes}")

    collision_writes = re.findall(r"o->collisionData\s*=\s*([^;]+);", eyerok)
    if len(collision_writes) != 6 or any("segmented_to_virtual" not in value for value in collision_writes):
        fail(f"unexpected live-hand collision writers: {collision_writes}")
    if re.search(r"o->collisionData\s*=\s*(?:NULL|0)\s*;", eyerok):
        fail("hand behavior clears collisionData")
    if "oRoom" in eyerok:
        fail("hand behavior unexpectedly writes oRoom")
    if "activeFlags" in eyerok:
        fail("hand behavior unexpectedly writes active flags")

    behavior_execution_pos = behavior_script.find("// Execute the behavior script.")
    visibility_pos = behavior_script.find("// Handle visibility of object")
    if behavior_execution_pos < 0 or visibility_pos < 0 or behavior_execution_pos >= visibility_pos:
        fail("behavior native no longer executes before visibility postprocessing")

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
    require(helpers, "o->oMoveFlags &= ~OBJ_MOVE_LANDED;", "equality clears landed")
    require(helpers, "clear_move_flag(&o->oMoveFlags, OBJ_MOVE_ON_GROUND)", "equality clears on-ground")
    require(helpers, "o->oPosY = o->oFloorHeight;", "ground collision position snap")
    require(helpers, "if (o->oVelY < 0.0f) { o->oVelY *= bounciness; }", "ground collision bounciness response")
    require(helpers, "if (!(o->activeFlags & (ACTIVE_FLAG_FAR_AWAY | ACTIVE_FLAG_IN_DIFFERENT_ROOM)))", "movement partial-update guard")
    require(constants, "#define OBJ_MOVE_MASK_ON_GROUND (OBJ_MOVE_LANDED | OBJ_MOVE_ON_GROUND)", "ground mask definition")
    require(behavior_script, "gCurrentObject->collisionData == NULL", "far-away collision-data guard")
    require(behavior_script, "gCurrentObject->oRoom != -1", "room-flag guard")
    require(behavior_script, "// Execute the behavior script. gCurBhvCommand = gCurrentObject->curBhvCommand;", "behavior execution before postprocessing")
    require(behavior_script, "// Handle visibility of object if (gCurrentObject->oRoom != -1)", "visibility postprocessing")
    require(behavior_data, "BEGIN(OBJ_LIST_SURFACE)", "hand surface list")
    require(behavior_data, "const BehaviorScript bhvEyerokHand[] = { BEGIN(OBJ_LIST_SURFACE)", "Eyerok hand surface behavior")
    require(behavior_data, "BEGIN_LOOP(), CALL_NATIVE(bhv_eyerok_hand_loop), END_LOOP()", "Eyerok native loop command")
    require(behavior_data, "const BehaviorScript bhvEyerokBoss[] = { BEGIN(OBJ_LIST_GENACTOR)", "Eyerok boss genactor behavior")
    require(behavior_data, "SET_OBJ_PHYSICS(/*Wall hitbox radius*/ 150, /*Gravity*/ 0, /*Bounciness*/ 0", "hand zero gravity and bounciness")
    require(eyerok, "eyerok_spawn_hand(-1, MODEL_EYEROK_LEFT_HAND, bhvEyerokHand); eyerok_spawn_hand(1, MODEL_EYEROK_RIGHT_HAND, bhvEyerokHand);", "hand spawn order")
    require(eyerok, "spawn_object_relative_with_scale(side, -500 * side, 0, 300, 1.5f", "hand home X offsets")
    require(eyerok, "400.0f * o->parentObj->oEyerokBossUnk108 - 180.0f * o->oBhvParams2ndByte", "begin-double target X constants")
    require(eyerok, "o->oPosX = o->oHomeX + (sp4 - o->oHomeX) * o->parentObj->oEyerokBossUnk110;", "begin-double X interpolation")
    require(object_lists, "clear_dynamic_surfaces();", "dynamic-surface clear")
    require(object_lists, "update_objects_in_list(&gObjectLists[OBJ_LIST_SURFACE])", "surface-list update")
    require(object_lists, "OBJ_LIST_SURFACE, OBJ_LIST_POLELIKE, OBJ_LIST_PLAYER, OBJ_LIST_PUSHABLE, OBJ_LIST_GENACTOR", "surface-before-boss order")
    require(spawn_object, "Insert at the end of destination list", "append-order allocation")
    require(spawn_object, "obj->activeFlags = ACTIVE_FLAG_ACTIVE | ACTIVE_FLAG_UNK8;", "spawn active flags exclude partial bits")
    require(spawn_object, "obj->collisionData = NULL;", "collision starts null")
    require(spawn_object, "obj->oRoom = -1;", "room starts minus one")
    require(object_lists, "if (unfrozen) { gCurrentObject->header.gfx.node.flags |= GRAPH_RENDER_HAS_ANIMATION; cur_obj_update(); } else { gCurrentObject->header.gfx.node.flags &= ~GRAPH_RENDER_HAS_ANIMATION; }", "time stop freezes whole object update")
    require(eyerok, "if (o->oTimer == 0) { eyerok_spawn_hand(-1", "boss spawns hands without same-tick wake transition")
    require(eyerok, "if (o->oBhvParams2ndByte < 0) { o->collisionData = segmented_to_virtual(&ssl_seg7_collision_070284B0); } else { o->collisionData = segmented_to_virtual(&ssl_seg7_collision_07028370); }", "first sleep update assigns collision")
    require(surface_collision, "if (y - (height + -78.0f) < 0.0f)", "find-floor 78-unit buffer")
    require(surface_load, "*vertexData++ = (TerrainData)(vx * m[0][0] + vy * m[1][0] + vz * m[2][0] + m[3][0]);", "dynamic collision X transform")
    require(surface_load, "*vertexData++ = (TerrainData)(vx * m[0][1] + vy * m[1][1] + vz * m[2][1] + m[3][1]);", "dynamic collision Y transform")
    require(die_animation, "0x28, ANIMINDEX_NUMPARTS(eyerok_seg5_animindex_0500DD4C)", "40-frame die animation")
    require(attacked_animation, "0x19, ANIMINDEX_NUMPARTS(eyerok_seg5_animindex_0500E798)", "25-frame attacked animation")

    require(ssl_script, "OBJECT(/*model*/ MODEL_NONE, /*pos*/ 0, -1534, -3693", "boss spawn")
    require(ssl_script, "INSTANT_WARP(/*index*/ 3, /*destArea*/ 3, /*displace*/ 0, 0, 0)", "area 2 to 3 instant warp")
    require(ssl_script, "INSTANT_WARP(/*index*/ 2, /*destArea*/ 2, /*displace*/ 0, 0, 0)", "area 3 to 2 instant warp")
    require(area2, "COL_TRI_INIT(SURFACE_INSTANT_WARP_1E, 2), COL_TRI(11, 241, 12), COL_TRI(241, 243, 12),", "area 2 active warp triangles")
    require(area3, "COL_TRI_INIT(SURFACE_INSTANT_WARP_1D, 2), COL_TRI(18, 19, 20), COL_TRI(18, 20, 21),", "area 3 active warp triangles")
    require(area3_macros, "const MacroObject ssl_seg7_area_3_macro_objs[] = { MACRO_OBJECT_END(), };", "empty Area 3 macro list")
    if "COL_WATER_BOX" in area3:
        fail("unexpected Area 3 water box")

    local6 = re.search(
        r"static\s+const\s+LevelScript\s+script_func_local_6\[\]\s*=\s*\{(.*?)\};",
        ssl_script,
        re.DOTALL,
    )
    if local6 is None:
        fail("missing Area 3 local object script")
    local6_objects = re.findall(r"\bOBJECT(?:_WITH_ACTS)?\s*\(", local6.group(1))
    if len(local6_objects) != 1 or "bhvEyerokBoss" not in local6.group(1):
        fail("Area 3 local object script is not exactly the Eyerok boss")

    area3_vertices, area3_triangles = parse_collision(area3)
    max_static_vertex_y = max(vertex[1] for vertex in area3_vertices)
    if max_static_vertex_y != 896:
        fail(f"unexpected Area 3 maximum vertex Y: {max_static_vertex_y}")
    max_upward_floor_vertex_y = max(
        max(area3_vertices[index][1] for index in triangle)
        for triangle in area3_triangles
        if normal_y(*(area3_vertices[index] for index in triangle)) > 0
    )
    if max_upward_floor_vertex_y != 384:
        fail(
            "unexpected Area 3 upward-floor vertex Y: "
            f"{max_upward_floor_vertex_y}"
        )

    upward_area3: list[tuple[tuple[int, int, int], list[tuple[int, int, int]]]] = []
    for triangle in area3_triangles:
        points = [area3_vertices[index] for index in triangle]
        if normal_y(*points) > 0:
            upward_area3.append((triangle, points))

    arena_upward = [
        (triangle, points)
        for triangle, points in upward_area3
        if max(point[1] for point in points) <= -1150
    ]
    tunnel_upward = [
        (triangle, points)
        for triangle, points in upward_area3
        if min(point[1] for point in points) >= -562
    ]
    unclassified_upward = [
        (triangle, points)
        for triangle, points in upward_area3
        if (triangle, points) not in arena_upward
        and (triangle, points) not in tunnel_upward
    ]
    if unclassified_upward:
        fail(f"upward Area 3 triangles cross the arena/tunnel gap: {unclassified_upward}")
    max_arena_upward_y = max(
        max(point[1] for point in points) for _, points in arena_upward
    )
    min_tunnel_upward_y = min(
        min(point[1] for point in points) for _, points in tunnel_upward
    )
    if max_arena_upward_y != -1150:
        fail(f"unexpected arena upward-floor maximum: {max_arena_upward_y}")
    if min_tunnel_upward_y != -562:
        fail(f"unexpected tunnel upward-floor minimum: {min_tunnel_upward_y}")
    arena_peak_triangles = sorted(
        triangle
        for triangle, points in arena_upward
        if max(point[1] for point in points) == -1150
    )
    if arena_peak_triangles != [(52, 100, 99), (52, 101, 100)]:
        fail(f"unexpected arena peak triangles: {arena_peak_triangles}")
    tunnel_entry_triangles = sorted(
        triangle
        for triangle, points in tunnel_upward
        if min(point[1] for point in points) == -562
    )
    if tunnel_entry_triangles != [(11, 14, 15), (11, 15, 12)]:
        fail(f"unexpected tunnel entry triangles: {tunnel_entry_triangles}")

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
    # Both positive-double targets are evaluated at the same interpolation
    # value.  Their 1000-unit home separation shrinks by at most 640, so the
    # reusable launch begins 360 units behind, not at the old mixed-frame 280.
    positive_double_setup_min_separation = 1000 - 640
    if positive_double_setup_min_separation != 360:
        fail(
            "unexpected positive-double setup separation: "
            f"{positive_double_setup_min_separation}"
        )
    max_closed_local_y = max(y for _, y, _ in closed_vertices)
    if max_closed_local_y != 204:
        fail(f"unexpected closed-hand local Y maximum: {max_closed_local_y}")
    closed_top_offset = max_closed_local_y * 3 // 2

    open_vertices, open_triangles = parse_collision(
        named_collision_block(hand_collision, "ssl_seg7_collision_070282F8")
    )
    closed_mesh_vertices, closed_mesh_triangles = parse_collision(
        named_collision_block(hand_collision, "ssl_seg7_collision_07028274")
    )
    open_upward_top = upward_triangle_top(open_vertices, open_triangles)
    closed_upward_top = upward_triangle_top(closed_mesh_vertices, closed_mesh_triangles)
    if open_upward_top != 338:
        fail(f"unexpected open-hand upward top: {open_upward_top}")
    if closed_upward_top != 204:
        fail(f"unexpected closed-hand upward top: {closed_upward_top}")
    if (1, 3, 4) not in closed_mesh_triangles or (1, 4, 5) not in closed_mesh_triangles:
        fail("closed-hand top triangles changed")
    if (1, 3, 4) not in open_triangles or (1, 4, 2) not in open_triangles:
        fail("open-hand top triangles changed")

    # Audit the no-wall relative query trace for the only dangerous reusable
    # sibling approach.  The later-updated hand starts 360 units behind.  Its
    # first launch uses gravity -15; once velocity is nonpositive, the action
    # installs gravity -20 before movement.  At relative Z=0 the closed top's
    # scaled/cast footprint excludes X=-120 but includes X=-90.
    closed_scaled_vertices = [
        tuple(math.trunc(1.5 * coordinate) for coordinate in vertex)
        for vertex in closed_mesh_vertices
    ]
    closed_top_triangles = [(1, 3, 4), (1, 4, 5)]

    def on_closed_top(x: int, z: int) -> bool:
        return any(
            point_in_triangle_xz(
                (x, z), *(closed_scaled_vertices[index] for index in triangle)
            )
            for triangle in closed_top_triangles
        )

    double_trace = [(-360, 0)]
    relative_x = -360
    relative_y = 0
    velocity_y = 100
    gravity = -15
    while relative_y >= 0:
        if velocity_y <= 0:
            gravity = -20
        velocity_y += gravity
        relative_x += 30
        relative_y += velocity_y
        double_trace.append((relative_x, relative_y))

    expected_trace_prefix = [
        (-360, 0),
        (-330, 85),
        (-300, 155),
        (-270, 210),
        (-240, 250),
        (-210, 275),
        (-180, 285),
        (-150, 280),
        (-120, 255),
        (-90, 210),
    ]
    if double_trace[: len(expected_trace_prefix)] != expected_trace_prefix:
        fail(f"unexpected positive-double relative trace: {double_trace}")

    closed_query_y_min = closed_top_offset - 78
    vertically_eligible = [point for point in double_trace if point[1] >= closed_query_y_min]
    horizontally_inside = [point for point in double_trace if on_closed_top(point[0], 0)]
    if not vertically_eligible or vertically_eligible[-1] != (-120, 255):
        fail(f"unexpected last vertically eligible double query: {vertically_eligible}")
    if not horizontally_inside or horizontally_inside[0] != (-90, 210):
        fail(f"unexpected first horizontally inside double query: {horizontally_inside}")
    if any(y >= closed_query_y_min and on_closed_top(x, 0) for x, y in double_trace):
        fail("positive-double trace can select the sibling closed top")
    if closed_query_y_min - 210 != 18:
        fail("unexpected first-inside vertical shortfall")

    first_hand_finite_peak = max_arena_upward_y + 288
    first_hand_tunnel_query_min = min_tunnel_upward_y - 78
    if first_hand_finite_peak != -862 or first_hand_tunnel_query_min != -640:
        fail("unexpected first-hand barrier arithmetic")
    if first_hand_finite_peak >= first_hand_tunnel_query_min:
        fail("finite arena ascent reaches tunnel floor eligibility")
    first_hand_open_surface_peak = first_hand_finite_peak + dynamic_top_offset
    if first_hand_open_surface_peak != -355:
        fail(f"unexpected first-hand open-surface peak: {first_hand_open_surface_peak}")

    # The second-updated hand may see the first hand's current dynamic
    # collision.  Even granting the first hand's highest possible open top at
    # every X/Z, that support is below the already-audited static Area 3
    # upward-floor maximum.  Thus dynamic support cannot raise the second
    # hand's support ceiling above 384.
    second_hand_support_ceiling = max(
        max_upward_floor_vertex_y, first_hand_open_surface_peak
    )
    second_hand_finite_peak = second_hand_support_ceiling + 288
    second_hand_open_surface_peak = second_hand_finite_peak + dynamic_top_offset
    second_hand_modeled_mario_peak = second_hand_open_surface_peak + 630
    if second_hand_support_ceiling != 384:
        fail(f"unexpected second-hand support ceiling: {second_hand_support_ceiling}")
    if second_hand_finite_peak != 672:
        fail(f"unexpected second-hand finite origin peak: {second_hand_finite_peak}")
    if second_hand_open_surface_peak != 1179:
        fail(f"unexpected second-hand open-surface peak: {second_hand_open_surface_peak}")
    if second_hand_modeled_mario_peak != 1809:
        fail(f"unexpected second-hand modeled Mario peak: {second_hand_modeled_mario_peak}")

    print("Eyerok source audit")
    print(f"pin: {PIN}")
    print(f"checkout-head: {head}")
    print(f"pin-identical-files: {len(IDENTICAL_PATHS)}")
    print("hand-actions: 0..15")
    print("positive-velY-writes: 30,50,100")
    print("gravity-writer-sequence: -4,0,0,-4,-4,-20,-15,-20")
    print("live-hand-collision-writes: 6, all nonnull")
    print("hand-room-writes: none (spawn default -1)")
    print("ground-mask: LANDED|ON_GROUND")
    print("zero-gravity-floor-equality: clears grounded")
    print("hand-bounciness: zero")
    print("partial-update-guards: FAR_AWAY|IN_DIFFERENT_ROOM")
    print("hand-native-before-visibility: yes")
    print("first-hand-sleep-update-collision: nonnull before visibility")
    print("time-stop-hand-update: whole update frozen unless explicitly unfrozen")
    print("hand-list-before-boss: yes")
    print("hand-spawn-and-surface-order: side -1, then side +1")
    print("surface-list-append-order: yes")
    print("area3-local-objects: Eyerok boss only; macro list empty")
    print("area3-water-boxes: none")
    print("find-floor-buffer: 78")
    print(f"area3-arena-upward-floor-max: {max_arena_upward_y}")
    print(f"area3-tunnel-upward-floor-min: {min_tunnel_upward_y}")
    print("area3-upward-floor-gap: (-1150,-562), no triangles")
    print(f"first-hand-finite-origin-peak: {first_hand_finite_peak}")
    print(f"first-hand-tunnel-query-min: {first_hand_tunnel_query_min}")
    print(f"first-hand-open-surface-peak: {first_hand_open_surface_peak}")
    print(f"second-hand-support-ceiling: {second_hand_support_ceiling}")
    print(f"second-hand-finite-origin-peak: {second_hand_finite_peak}")
    print(f"second-hand-open-surface-peak: {second_hand_open_surface_peak}")
    print(f"second-hand-modeled-mario-peak: {second_hand_modeled_mario_peak}")
    print("positive-double-setup-min-separation: 360")
    print("positive-double-last-vertical-query: relative (-120,255), outside closed top")
    print("positive-double-first-horizontal-query: relative (-90,210), 18 below threshold")
    print("positive-double-sibling-floor-selection: none in audited no-wall trace")
    print(f"closed-hand-horizontal-radius-max: {1.5 * math.sqrt(max_closed_radius_sq):.6f}")
    print(f"closed-hand-top-offset: {closed_top_offset}")
    print("closed-hand-upward-local-top: 204 (scaled 306)")
    print("open-hand-upward-local-top: 338 (scaled 507)")
    print("attacked-animation-frames: 25")
    print("die-animation-frames: 40")
    print("raised-static-floor-overlap-with-begin-corridor: none")
    print(f"area3-static-vertex-y-max: {max_static_vertex_y}")
    print(f"area3-upward-floor-vertex-y-max: {max_upward_floor_vertex_y}")
    print(f"hand-dynamic-top-offset-max: {dynamic_top_offset}")
    print("area2-active-warp: surface-1E -> area3, displacement (0,0,0)")
    print("area3-active-warp: surface-1D -> area2, displacement (0,0,0)")
    print("runaway-tripwire: DOUBLE_POUND + grounded + gravity=0 must remain unreachable")
    print("normalized-sha256:")
    for path, digest in hashes:
        print(f"  {digest}  {path}")


if __name__ == "__main__":
    main()
