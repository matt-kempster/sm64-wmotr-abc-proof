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


def c_function_body(text: str, name: str) -> str:
    """Return a named C function's brace-balanced body."""
    match = re.search(rf"\b{re.escape(name)}\s*\([^;{{]*\)\s*\{{", text)
    if match is None:
        fail(f"missing C function: {name}")
    opening = text.find("{", match.start())
    depth = 0
    for index in range(opening, len(text)):
        if text[index] == "{":
            depth += 1
        elif text[index] == "}":
            depth -= 1
            if depth == 0:
                return text[opening + 1 : index]
    fail(f"unterminated C function: {name}")


def named_collision_block(text: str, name: str) -> str:
    match = re.search(
        rf"const\s+Collision\s+{re.escape(name)}\[\]\s*=\s*\{{(.*?)\n\}};",
        text,
        re.DOTALL,
    )
    if match is None:
        fail(f"missing collision array: {name}")
    return match.group(1)


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


def point_strictly_in_triangle_xz(
    point: tuple[Fraction, Fraction], triangle: Triangle
) -> bool:
    px, pz = point
    projected = [(Fraction(x), Fraction(z)) for x, _, z in triangle.points]
    signs: list[Fraction] = []
    for (ax, az), (bx, bz) in zip(projected, projected[1:] + projected[:1]):
        signs.append((bx - ax) * (pz - az) - (bz - az) * (px - ax))
    return all(value > 0 for value in signs) or all(value < 0 for value in signs)


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


def require_selected_floor_height(
    triangles: list[Triangle],
    x: int,
    query_y: int,
    z: int,
    expected_height: int | Fraction,
    label: str,
    expected_surface: str | None = None,
) -> None:
    """Require exact upward-triangle coverage at one modeled floor query.

    Mario's floor query first casts X/Y/Z to TerrainData integers, rejects
    floors more than 78 units above the integer Y, and returns the first
    eligible triangle in the static floor list.  The loader sorts that list by
    first-vertex Y (descending), retaining source insertion order on ties.  The
    route points below are all static Area 2 queries, so checking that exact
    order prevents a rectangle inferred only from disconnected corner vertices
    from silently supporting the proof model.
    """

    candidates = []
    for source_order, triangle in enumerate(triangles):
        if triangle.normal_y <= 0 or not point_in_triangle_xz(
            (Fraction(x), Fraction(z)), triangle
        ):
            continue
        candidates.append(
            (
                triangle.points[0][1],
                source_order,
                floor_height_at(triangle, Fraction(x), Fraction(z)),
                triangle.surface,
                triangle.indices,
            )
        )
    candidates.sort(key=lambda candidate: (-candidate[0], candidate[1]))
    eligible = [
        candidate
        for candidate in candidates
        if candidate[2] - 78 <= query_y
    ]
    if not eligible:
        fail(
            f"{label} has no eligible upward floor at "
            f"({x}, {query_y}, {z}); candidates={candidates}"
        )

    _, _, selected_height, selected_surface, selected_indices = eligible[0]
    if selected_height != expected_height:
        fail(
            f"{label} selected Y={selected_height} from {selected_surface} "
            f"triangle {selected_indices}, expected Y={expected_height}; "
            f"eligible={eligible}"
        )
    if expected_surface is not None and selected_surface != expected_surface:
        fail(
            f"{label} selected {selected_surface} triangle {selected_indices}, "
            f"expected {expected_surface}; eligible={eligible}"
        )


def require_vertices(
    vertices: list[tuple[int, int, int]], expected: list[tuple[int, int, int]], label: str
) -> None:
    missing = [vertex for vertex in expected if vertex not in vertices]
    if missing:
        fail(f"{label} missing vertices: {missing}")


def require_rectangular_wall(
    triangles: list[Triangle],
    corners: set[tuple[int, int, int]],
    label: str,
) -> None:
    matching = [
        triangle
        for triangle in triangles
        if set(triangle.points).issubset(corners)
    ]
    covered = {point for triangle in matching for point in triangle.points}
    if len(matching) != 2 or covered != corners:
        fail(
            f"{label} is not the expected two-triangle wall; "
            f"matches={matching}, covered={covered}"
        )


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
    game_init = pinned(sm64, "src/game/game_init.c")
    object_collision = pinned(sm64, "src/game/object_collision.c")
    object_helpers = pinned(sm64, "src/game/object_helpers.c")
    mario_step = pinned(sm64, "src/game/mario_step.c")
    mario_moving = pinned(sm64, "src/game/mario_actions_moving.c")
    mario_airborne = pinned(sm64, "src/game/mario_actions_airborne.c")
    mario_object = pinned(sm64, "src/game/mario_actions_object.c")
    mario_stationary = pinned(sm64, "src/game/mario_actions_stationary.c")
    surface_collision = pinned(sm64, "src/engine/surface_collision.c")
    surface_load = pinned(sm64, "src/engine/surface_load.c")
    platform = pinned(sm64, "src/game/platform_displacement.c")
    interaction = pinned(sm64, "src/game/interaction.c")
    object_lists = pinned(sm64, "src/game/object_list_processor.c")
    eyerok = pinned(sm64, "src/game/behaviors/eyerok.inc.c")
    attacked_animation = pinned(sm64, "actors/eyerok/anims/anim_0500E99C.inc.c")
    ssl_script = pinned(sm64, "levels/ssl/script.c")
    area2_text = pinned(sm64, "levels/ssl/areas/2/collision.inc.c")
    area3_text = pinned(sm64, "levels/ssl/areas/3/collision.inc.c")
    hand_collision = pinned(sm64, "levels/ssl/eyerok_col/collision.inc.c")
    behavior_data = pinned(sm64, "data/behavior_data.c")
    star_behavior = pinned(sm64, "src/game/behaviors/spawn_star.inc.c")
    sm64_header = pinned(sm64, "include/sm64.h")

    require(level_update, "warp_area(); check_instant_warp();", "normal-frame instant-warp order")
    require(level_update, "if ((floor = gMarioState->floor) != NULL)", "warp floor pointer guard")
    require(level_update, "s32 index = floor->type - SURFACE_INSTANT_WARP_1B;", "warp surface index")
    require(level_update, "gMarioState->pos[1] += warp->displacement[1];", "warp Y displacement")
    require(level_update, "change_area(warp->area);", "instant area change")
    require(area, "unload_area();", "old-area unload")
    require(area, "load_area(index);", "new-area load")
    require(mario, "m->floorHeight = find_floor(m->pos[0], m->pos[1], m->pos[2], &m->floor);", "Mario floor query")
    require(game_init, "controller->buttonPressed = controller->controllerData->button & (controller->controllerData->button ^ controller->buttonDown);", "controller rising-edge buttons")
    require(mario, "if (m->controller->buttonPressed & A_BUTTON)", "Mario A-pressed input")
    require(mario, "if (m->controller->buttonDown & A_BUTTON)", "Mario A-down input")
    require(mario_stationary, "if (m->input & INPUT_A_PRESSED) { return set_jumping_action(m, ACT_BACKFLIP, 0);", "backflip fresh-A gate")
    require(mario_stationary, "if (m->input & INPUT_B_PRESSED) { return set_mario_action(m, ACT_PUNCHING, 0);", "idle B-to-punch entry")
    require(mario_object, "if (m->actionState == 0 && (m->input & INPUT_A_DOWN)) { return set_mario_action(m, ACT_JUMP_KICK, 0);", "stationary punch held-A jump-kick gate")
    require(mario_moving, "if (m->actionState == 0 && (m->input & INPUT_A_DOWN)) { return set_mario_action(m, ACT_JUMP_KICK, 0);", "moving punch held-A jump-kick gate")
    require(mario, "while (inLoop) { switch (gMarioState->action & ACT_GROUP_MASK)", "same-frame Mario action loop")
    require(mario, "case ACT_JUMP_KICK: m->vel[1] = 20.0f;", "jump-kick launch velocity")
    require(mario_airborne, "case ACT_JUMP_KICK:            cancel = act_jump_kick(m);", "jump-kick airborne dispatch")
    require(mario_airborne, "update_air_without_turn(m); switch (perform_air_step(m, 0))", "jump-kick same-frame air step")
    require(mario_moving, "if (m->input & INPUT_A_PRESSED) { return set_jump_from_landing(m); } if (check_ground_dive_or_punch(m)) { return TRUE; }", "walking fresh-A branch before B check")
    require(mario_moving, "if (m->forwardVel >= 29.0f && m->controller->stickMag > 48.0f)", "B-only speed-kick condition")
    require(mario_moving, "m->vel[1] = 20.0f; return set_mario_action(m, ACT_DIVE, 1);", "B-only speed-kick result")
    require(mario_airborne, "case ACT_DIVE:                 cancel = act_dive(m);", "speed-kick dive airborne dispatch")
    require(sm64_header, "#define ACT_DIVE                       0x0188088A // (0x08A | ACT_FLAG_AIR | ACT_FLAG_DIVING | ACT_FLAG_ATTACKING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)", "DIVE flags exclude variable jump gravity")
    require(sm64_header, "#define ACT_JUMP_KICK                  0x018008AC // (0x0AC | ACT_FLAG_AIR | ACT_FLAG_ATTACKING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)", "JUMP_KICK flags exclude variable jump gravity")
    require(mario_airborne, "case AIR_STEP_HIT_WALL: mario_bonk_reflection(m, TRUE);", "dive wall-hit reflection")
    require(mario_airborne, "drop_and_set_mario_action(m, ACT_BACKWARD_AIR_KB, 0);", "dive wall-hit action")
    require(mario, "case ACT_BACKFLIP: m->marioObj->header.gfx.animInfo.animID = -1; m->forwardVel = -16.0f; set_mario_y_vel_based_on_fspeed(m, 62.0f, 0.0f);", "backflip vertical velocity")
    require(mario, "case ACT_TRIPLE_JUMP: set_mario_y_vel_based_on_fspeed(m, 69.0f, 0.0f);", "triple-jump vertical velocity")
    require(mario_moving, "if (m->input & INPUT_A_PRESSED) { return setAPressAction(m, landingAction->aPressedAction, 0);", "landing jump fresh-A gate")
    require(mario_step, "for (i = 0; i < 4; i++)", "four air quarter steps")
    require(mario_step, "intendedPos[1] = m->pos[1] + m->vel[1] / 4.0f;", "air quarter-step Y")
    require(mario_step, "floorHeight = find_floor(nextPos[0], nextPos[1], nextPos[2], &floor);", "quarter-step floor query")
    require(mario_step, "upperWall = resolve_and_return_wall_collisions(nextPos, 150.0f, 50.0f); lowerWall = resolve_and_return_wall_collisions(nextPos, 30.0f, 50.0f); floorHeight = find_floor(nextPos[0], nextPos[1], nextPos[2], &floor);", "wall resolution before quarter-step floor query")
    require(mario_step, "if (nextPos[1] <= floorHeight)", "quarter-step landing comparison")
    require(mario_step, "m->pos[1] = m->floorHeight;", "Mario landing snap")
    require(mario_step, "if (nextPos[1] + 160.0f > ceilHeight) { if (m->vel[1] >= 0.0f) { m->vel[1] = 0.0f;", "upward air-step ceiling response")
    require(mario, "if ((0.0f <= ceilToFloorDist) && (ceilToFloorDist <= 150.0f)) { m->input |= INPUT_SQUISHED;", "dynamic 150-unit squish input")
    require(surface_collision, "TerrainData y = (TerrainData) yPos;", "floor-query Y integer cast")
    require(surface_collision, "if (y - (height + -78.0f) < 0.0f)", "floor-query 78-unit buffer")
    require(surface_collision, "if (y < surf->lowerY || y > surf->upperY)", "wall vertical-range test")
    require(surface_load, "sortDir = 1; // highest to lowest, then insertion order", "floor-list descending sort")
    require(surface_load, "surfacePriority = surface->vertex1[1] * sortDir;", "floor-list first-vertex priority")
    require(surface_load, "if (surfacePriority > priority)", "floor-list stable priority insertion")
    require(surface_load, "surface->lowerY = minY - 5; surface->upperY = maxY + 5;", "wall vertical-range margin")
    require(platform, "x += platform->oVelX;", "platform X displacement")
    require(platform, "z += platform->oVelZ;", "platform Z displacement")
    if compact("y += platform->oVelY") in compact(platform):
        fail("unexpected direct vertical platform displacement")
    require(interaction, "bounce_off_object(m, o, 30.0f);", "ordinary bounce velocity")
    require(interaction, "m->pos[1] = o->oPosY + o->hitboxHeight;", "bounce placement at hitbox top")
    require(interaction, "if (interaction & INT_HIT_FROM_ABOVE)", "automatic top-hit bounce gate")
    require(object_collision, "f32 collisionRadius = a->hitboxRadius + b->hitboxRadius;", "combined object hitbox radius")
    require(object_collision, "if (sp3C > sp1C) { return 0;", "vertical hitbox separation above object")
    require(eyerok, "/* radius:            */ 150,", "Eyerok unscaled hitbox radius")
    require(eyerok, "/* height:            */ 100,", "Eyerok unscaled hitbox height")
    require(eyerok, "spawn_object_relative_with_scale(side, -500 * side, 0, 300, 1.5f", "Eyerok spawn scale")
    require(object_helpers, "obj->header.gfx.scale[1] = scale;", "uniform object Y scale")
    require(object_helpers, "obj->hitboxHeight = obj->header.gfx.scale[1] * hitbox->height;", "scaled object hitbox height")
    require(object_helpers, "obj->hitboxRadius = obj->header.gfx.scale[0] * hitbox->radius;", "scaled object hitbox radius")
    require(object_helpers, "o->oVelY += gravity + buoyancy;", "hand gravity integration")
    require(object_helpers, "o->oPosY += o->oVelY;", "hand vertical position integration")
    require(object_lists, "OBJ_LIST_SURFACE, OBJ_LIST_POLELIKE, OBJ_LIST_PLAYER, OBJ_LIST_PUSHABLE, OBJ_LIST_GENACTOR", "surface-before-player-before-boss order")

    require(ssl_script, "INSTANT_WARP(/*index*/ 3, /*destArea*/ 3, /*displace*/ 0, 0, 0)", "Area 2 return warp")
    require(ssl_script, "INSTANT_WARP(/*index*/ 2, /*destArea*/ 2, /*displace*/ 0, 0, 0)", "Area 3 entry warp")
    require(ssl_script, "OBJECT_WITH_ACTS(/*model*/ MODEL_STAR, /*pos*/ 500, 5050, -500", "Inside Ancient Pyramid star")
    require(behavior_data, "/*Radius*/ 37, /*Height*/ 160", "Mario interaction cylinder")
    require(star_behavior, "/* radius:            */ 80,", "star radius")
    require(star_behavior, "/* height:            */ 50,", "star height")

    # Both contact candidates depend on the surface hand moving before Mario,
    # while the boss scheduler runs only after Mario.  The Mario action loop
    # can consume multiple nonzero action-change returns in that one player
    # update, and perform_air_step applies gravity only after all four qsteps.
    air_step_body = c_function_body(mario_step, "perform_air_step")
    air_step_markers = [
        air_step_body.find("intendedPos[1] = m->pos[1] + m->vel[1] / 4.0f;"),
        air_step_body.find("perform_air_quarter_step(m, intendedPos, stepArg)"),
        air_step_body.find("apply_gravity(m);"),
    ]
    if any(position < 0 for position in air_step_markers) or air_step_markers != sorted(
        air_step_markers
    ):
        fail(f"unexpected qstep/gravity order: {air_step_markers}")
    require(
        c_function_body(mario_airborne, "act_jump_kick"),
        "update_air_without_turn(m); switch (perform_air_step(m, 0))",
        "JUMP_KICK performs same-frame air step",
    )
    require(
        c_function_body(mario_airborne, "act_dive"),
        "update_air_without_turn(m); switch (perform_air_step(m, 0))",
        "DIVE performs same-frame air step",
    )
    bounce_top_body = c_function_body(interaction, "interact_bounce_top")
    require(
        bounce_top_body,
        "if (interaction & INT_HIT_FROM_ABOVE)",
        "bounce-top hit-from-above branch",
    )
    require(
        bounce_top_body,
        "} else { bounce_off_object(m, o, 30.0f); }",
        "ordinary bounce-top response",
    )
    require(
        c_function_body(interaction, "bounce_off_object"),
        "m->pos[1] = o->oPosY + o->hitboxHeight; m->vel[1] = velY;",
        "bounce placement and velocity writes",
    )

    require(
        eyerok,
        "o->oForwardVel = 30.0f * absf(o->parentObj->oEyerokBossUnk108); o->oVelY = 100.0f; o->oMoveFlags = 0;",
        "DOUBLE_POUND upward impulse",
    )
    require(
        eyerok,
        "o->parentObj->oEyerokBossActiveHand = 0; eyerok_hand_pound_ground(); o->oForwardVel = 0.0f; o->oGravity = -15.0f;",
        "DOUBLE_POUND launch gravity setup",
    )
    double_rises: list[int] = []
    double_velocity = 100
    double_gravity = -15
    while double_velocity > 0:
        double_velocity += double_gravity
        if double_velocity > 0:
            double_rises.append(double_velocity)
    if double_rises != [85, 70, 55, 40, 25, 10]:
        fail(f"unexpected normal DOUBLE_POUND rises: {double_rises}")

    mario_launch_velocity = 20
    mario_post_launch_velocity = mario_launch_velocity - 4
    first_launch_gap = double_rises[0] - mario_launch_velocity
    first_launch_qstep_gap = first_launch_gap - mario_post_launch_velocity // 4
    if (
        mario_post_launch_velocity != 16
        or first_launch_gap != 65
        or first_launch_qstep_gap != 61
        or first_launch_qstep_gap > 78
    ):
        fail("unexpected held-A/B-only pre-hop contact arithmetic")

    attacked_body = c_function_body(eyerok, "eyerok_hand_act_attacked")
    require(
        attacked_body,
        "if (cur_obj_init_anim_and_check_if_end(3)) { o->oAction = EYEROK_HAND_ACT_RECOVER; o->collisionData = segmented_to_virtual(ssl_seg7_collision_07028274); }",
        "ATTACKED-to-RECOVER closed mesh swap",
    )
    attacked_animation_match = re.search(
        r"0x([0-9A-Fa-f]+),\s*ANIMINDEX_NUMPARTS\(eyerok_seg5_animindex_0500E798\)",
        attacked_animation,
    )
    if attacked_animation_match is None:
        fail("missing ATTACKED animation length")
    attacked_animation_frames = int(attacked_animation_match.group(1), 16)
    if attacked_animation_frames != 25:
        fail(f"unexpected ATTACKED animation length: {attacked_animation_frames}")

    open_body = c_function_body(eyerok, "eyerok_hand_act_open")
    require(
        open_body,
        "o->oAction = EYEROK_HAND_ACT_SHOW_EYE;",
        "OPEN-to-SHOW_EYE transition",
    )
    require(
        open_body,
        "o->collisionData = segmented_to_virtual(ssl_seg7_collision_070282F8);",
        "OPEN installs open collision mesh",
    )
    show_eye_body = c_function_body(eyerok, "eyerok_hand_act_show_eye")
    if show_eye_body.count("eyerok_hand_check_attacked()") != 1:
        fail("attack response is no longer called exactly once from SHOW_EYE")
    if len(re.findall(r"\beyerok_hand_check_attacked\s*\(\s*\)", eyerok)) != 1:
        fail("attack response is called from an action other than SHOW_EYE")
    if len(re.findall(r"o->oAction\s*=\s*EYEROK_HAND_ACT_DIE\s*;", eyerok)) != 1:
        fail("DIE has an unexpected action-entry writer")
    die_body = c_function_body(eyerok, "eyerok_hand_act_die")
    if "collisionData" in die_body:
        fail("DIE unexpectedly writes a collision mesh")
    require(die_body, "obj_explode_and_spawn_coins(150.0f, 1);", "DIE deletion helper call")
    require(
        c_function_body(object_helpers, "obj_explode_and_spawn_coins"),
        "obj_mark_for_deletion(o);",
        "DIE helper marks hand for deletion",
    )

    hand_scale = Fraction(3, 2)
    mario_hitbox_radius = 37
    hand_hitbox_radius = int(150 * hand_scale)
    combined_hitbox_radius = hand_hitbox_radius + mario_hitbox_radius
    if hand_hitbox_radius != 225 or combined_hitbox_radius != 262:
        fail("unexpected Eyerok/Mario combined hitbox radius")

    closed_vertices, closed_triangles = parse_collision(
        named_collision_block(hand_collision, "ssl_seg7_collision_07028274")
    )
    open_vertices, open_triangles = parse_collision(
        named_collision_block(hand_collision, "ssl_seg7_collision_070282F8")
    )
    closed_upward = [triangle for triangle in closed_triangles if triangle.normal_y > 0]
    closed_downward = [triangle for triangle in closed_triangles if triangle.normal_y < 0]
    open_upward = [triangle for triangle in open_triangles if triangle.normal_y > 0]
    if [triangle.indices for triangle in closed_upward] != [(1, 3, 4), (1, 4, 5)]:
        fail(
            "unexpected closed-hand upward triangles: "
            f"{[triangle.indices for triangle in closed_upward]}"
        )
    closed_local_top = max(
        max(point[1] for point in triangle.points) for triangle in closed_upward
    )
    closed_local_underside = max(
        max(point[1] for point in triangle.points) for triangle in closed_downward
    )
    if closed_local_top != 204 or closed_local_underside != 3:
        fail(
            "unexpected closed-hand top/underside: "
            f"{closed_local_top}/{closed_local_underside}"
        )
    closed_top_offset = closed_local_top * hand_scale
    closed_underside_offset = closed_local_underside * hand_scale
    if closed_top_offset != 306 or closed_underside_offset != Fraction(9, 2):
        fail("unexpected scaled closed-hand top/underside")

    # Collision vertices are transformed by scale 1.5 and cast to TerrainData.
    # Check the exact two top triangles used by floor queries, both at the
    # proof's sub-unit points and after the floor query's X/Z integer casts.
    transformed_closed_vertices = [
        tuple(int(hand_scale * coordinate) for coordinate in vertex)
        for vertex in closed_vertices
    ]
    transformed_closed_top = [
        Triangle(
            triangle.surface,
            triangle.indices,
            tuple(transformed_closed_vertices[index] for index in triangle.indices),
        )
        for triangle in closed_upward
    ]
    b_only_witness_thousandths = [
        (0, -55850),
        (30000, -45150),
        (30000, -5774),
        (30000, 30452),
        (30000, 63780),
        (30000, 94442),
        (30000, 122651),
    ]
    b_only_witnesses = [
        (Fraction(x, 1000), Fraction(z, 1000))
        for x, z in b_only_witness_thousandths
    ]
    for index, point in enumerate(b_only_witnesses):
        if not any(
            point_strictly_in_triangle_xz(point, triangle)
            for triangle in transformed_closed_top
        ):
            fail(f"B-only closed-top witness {index} is not strict interior: {point}")
        cast_point = (Fraction(int(point[0])), Fraction(int(point[1])))
        if not any(
            point_strictly_in_triangle_xz(cast_point, triangle)
            for triangle in transformed_closed_top
        ):
            fail(
                f"B-only closed-top witness {index} integer cast is not strict interior: "
                f"{cast_point}"
            )

    reboard_local_point = (Fraction(0), Fraction(100))
    if not any(
        point_strictly_in_triangle_xz(reboard_local_point, triangle)
        for triangle in closed_upward
    ):
        fail("local (0,100) is not strictly inside the closed-hand top")
    if any(
        point_in_triangle_xz(reboard_local_point, triangle) for triangle in open_upward
    ):
        fail("local (0,100) unexpectedly lies inside the open-hand top")
    open_front_local_z = max(z for _, _, z in open_vertices)
    closed_front_local_z = max(z for _, _, z in closed_vertices)
    open_wall_clearance = (reboard_local_point[1] - open_front_local_z) * hand_scale
    closed_front_margin = (closed_front_local_z - reboard_local_point[1]) * hand_scale
    reboard_world_radius = reboard_local_point[1] * hand_scale
    if (
        open_front_local_z != 51
        or closed_front_local_z != 147
        or open_wall_clearance != Fraction(147, 2)
        or closed_front_margin != Fraction(141, 2)
        or reboard_world_radius >= combined_hitbox_radius
        or open_wall_clearance <= 50
    ):
        fail("unexpected local (0,100) reboarding witness geometry")

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

    y1280_south_wall = {
        (-2201, 1152, -844),
        (-2201, 1280, -844),
        (205, 1152, -844),
        (205, 1280, -844),
    }
    y1280_east_wall = {
        (205, 1152, -844),
        (205, 1280, -844),
        (205, 1152, -537),
        (205, 1280, -537),
    }
    require_rectangular_wall(
        area2_triangles, y1280_south_wall, "Y=1280 south perimeter wall"
    )
    require_rectangular_wall(
        area2_triangles, y1280_east_wall, "Y=1280 east perimeter wall"
    )

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

    # UpperRoute.v enters Area 2 at (192, 4354, -1033) with vertical velocity
    # -10 and horizontal Z velocity 48.  The first air quarter-step therefore
    # casts its fresh floor query to (192, 4351, -1021).  Verify that an actual
    # upward collision triangle covers that point and that Y=4429 is the
    # highest eligible floor, rather than relying on corner vertices alone.
    require_selected_floor_height(
        area2_triangles,
        192,
        4351,
        -1021,
        4429,
        "UpperRoute first Area 2 quarter-step",
    )

    # The north edge at z=-1023 overlaps a default Area 3 floor triangle that
    # precedes the instant-warp triangle in the source floor list.  Put the
    # lower witness one unit inside the quad and require the selected surface
    # itself, not merely a point inside the quad's bounding rectangle.
    require_selected_floor_height(
        area3_triangles,
        0,
        1809,
        -1024,
        Fraction(76318, 199),
        "LowerArea2Entry Area 3 departure floor",
        "SURFACE_INSTANT_WARP_1D",
    )

    # LowerArea2Entry.v starts from the conservative two-hand/Mario ceiling.
    # Sixteen controlled frames place Mario at (0,1281,-832) with vy=-67;
    # the next quarter-step is cast to (0,1264,-829).  Pin the exact selected
    # floor at that point rather than inferring it from a bounding rectangle.
    require_selected_floor_height(
        area2_triangles,
        0,
        1264,
        -829,
        1280,
        "LowerArea2Entry first landing quarter-step",
    )

    # The modeled upper-platform jump reaches its landing query at
    # (480, 4813, -1021).  The Y=4815 floor is only two units above that query,
    # so the source landing comparison snaps Mario to it.
    require_selected_floor_height(
        area2_triangles,
        480,
        4813,
        -1021,
        4815,
        "UpperRoute star-platform landing",
    )

    # UpperRoute then keeps X=480 and moves ten 48-unit ground frames from
    # Z=-1021 to Z=-541, followed by one 41-unit frame to Z=-500.  Check every
    # state used by the recursive ground-path certificate, including both
    # endpoints, against parsed upward floor triangles at Y=4815.
    star_reposition_z = [-1021 + 48 * step for step in range(11)] + [-500]
    for step, z in enumerate(star_reposition_z):
        require_selected_floor_height(
            area2_triangles,
            480,
            4815,
            z,
            4815,
            f"UpperRoute star-platform reposition point {step}",
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
    print("object-update-order: SURFACE -> POLELIKE -> PLAYER -> PUSHABLE -> GENACTOR")
    print("eyerok-order-consequence: hand movement -> Mario action/floor queries -> boss scheduler")
    print("air-step-substeps: 4; fresh floor query each quarter-step")
    print("floor-query-y: TerrainData integer cast; 78-unit buffer")
    print("air-qstep-order: upper/lower wall resolution before floor query")
    print("air-step-gravity-order: four qsteps use entry velY; gravity applies afterward")
    print("platform-displacement: adds hand velX/velZ; no direct velY addition")
    print("held-a-contact-entry: Mario IDLE + fresh B -> PUNCHING; held A-down -> JUMP_KICK")
    print("held-a-contact-action-loop: PUNCHING -> JUMP_KICK -> air step in the same player frame")
    print("held-a-contact-launch: velY=20; same-frame rise=20; post-step velY=16")
    print("b-only-contact-entry: WALKING, fresh B, forwardVel>=29, stickMag>48 -> DIVE(arg=1)")
    print("b-only-contact-launch: velY=20; same-frame DIVE air step; no A condition in speed-kick branch")
    print("double-pound-normal-rises: 85,70,55,40,25,10")
    print("stationary-first-rise-floor-gap: 85 > 78 (closed top rejected)")
    print("pre-hop-first-rise-floor-gap: 85-20-4=61 <= 78 (closed top eligible on first qstep)")
    print("b-only-closed-top-triangles: transformed source triangles (1,3,4) and (1,4,5)")
    print(
        "b-only-closed-top-xz-witness-milli: "
        "(0,-55850),(30000,-45150),(30000,-5774),(30000,30452),"
        "(30000,63780),(30000,94442),(30000,122651)"
    )
    print("b-only-closed-top-xz-witnesses: 7/7 strict interior before and after TerrainData cast")
    print("no-a-speed-kick: B-only velY=20; wall hit enters BACKWARD_AIR_KB")
    print("area2-y1280-south-wall: x=[-2201,205], z=-844, y=[1152,1280]")
    print("area2-y1280-east-wall: x=205, z=[-844,-537], y=[1152,1280]")
    print("upper-route-first-qstep-floor: (192,4351,-1021) -> y=4429")
    print("lower-route-area3-departure: (0,1809,-1024) -> instant-warp 1D")
    print("lower-route-first-qstep-floor: (0,1264,-829) -> y=1280")
    print("area2-star-platform: y=4815, x=[387,643], z=[-1125,-409]")
    print("upper-route-star-landing-floor: (480,4813,-1021) -> y=4815")
    print(
        "upper-route-star-reposition-floor-points: "
        f"{len(star_reposition_z)}, all -> y=4815"
    )
    print("area2-mid-platform: y=1967, x=[131,387], z=[-716,-460]")
    print("inside-ancient-pyramid-star: (500,5050,-500)")
    print("star-interaction-horizontal-radius-sum: 117")
    print("star-interaction-Mario-base-y: [4890,5100]")
    print("area3-upward-floor-vertex-max: 384")
    print("platform-displacement-direct-vertical-add: no")
    print("closed-hand-surface-offsets: underside=4.5, upward-top=306")
    print("dynamic-squish-threshold: ceil-floor in [0,150] sets INPUT_SQUISHED")
    print("upward-ceiling-response: nextY+160>ceiling and velY>=0 sets velY=0")
    print("controller-a-pressed: new-down & (new-down ^ previous-down)")
    print("mario-input-a: buttonPressed -> INPUT_A_PRESSED; buttonDown -> INPUT_A_DOWN")
    print("backflip-launch-gate: INPUT_A_PRESSED")
    print("punch-to-jump-kick-gate: INPUT_A_DOWN (fresh edge not required)")
    print("no-a-b-dive: INPUT_B_PRESSED with speed/stick -> velY=20")
    print("backflip-envelope: velY=62, ordinary rise=512")
    print("triple-jump-envelope: velY=69, ordinary rise=630; landing gate uses INPUT_A_PRESSED")
    print("eyerok-scaled-hitbox-top-offset: 150")
    print("eyerok-hitbox-radius: 150*1.5=225; Mario radius=37; combined horizontal radius=262")
    print("standing-closed/open-top-above-hitbox: 306/507 > 150")
    print("ordinary-attack-bounce: hand-origin+150, velY=30")
    print("automatic-top-hit: INT_HIT_FROM_ABOVE uses ordinary bounce placement/velocity")
    print("attacked-recovery: 25-frame ATTACKED animation, then collision swaps open -> closed")
    print("lethal-die-collision: DIE writes no mesh; inherited open mesh persists until deletion")
    print("lethal-die-deletion: animation-end helper marks hand for deletion")
    print("reboard-xz-witness-local: (0,100) strict inside closed top, outside open top")
    print("reboard-xz-witness-margins: closed-front=70.5; open-wall=73.5>50")
    print("reboard-xz-witness-hitbox: scaled radius=150 < combined hitbox radius=262")
    print("audited-sha256:")
    for path, text in [
        ("src/game/level_update.c", level_update),
        ("src/game/area.c", area),
        ("src/game/mario.c", mario),
        ("src/game/game_init.c", game_init),
        ("src/game/object_collision.c", object_collision),
        ("src/game/object_helpers.c", object_helpers),
        ("src/game/mario_step.c", mario_step),
        ("src/game/mario_actions_moving.c", mario_moving),
        ("src/game/mario_actions_object.c", mario_object),
        ("src/game/mario_actions_stationary.c", mario_stationary),
        ("src/engine/surface_collision.c", surface_collision),
        ("src/engine/surface_load.c", surface_load),
        ("src/game/platform_displacement.c", platform),
        ("src/game/interaction.c", interaction),
        ("src/game/object_list_processor.c", object_lists),
        ("src/game/behaviors/eyerok.inc.c", eyerok),
        ("actors/eyerok/anims/anim_0500E99C.inc.c", attacked_animation),
        ("include/sm64.h", sm64_header),
        ("levels/ssl/script.c", ssl_script),
        ("levels/ssl/areas/2/collision.inc.c", area2_text),
        ("levels/ssl/areas/3/collision.inc.c", area3_text),
        ("levels/ssl/eyerok_col/collision.inc.c", hand_collision),
    ]:
        print(f"  {sha256(text)}  {path}")


if __name__ == "__main__":
    main()
