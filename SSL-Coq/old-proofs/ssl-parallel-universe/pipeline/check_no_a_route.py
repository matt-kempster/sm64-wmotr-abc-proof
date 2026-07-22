#!/usr/bin/env python3
"""Audit the source and Area 2 mesh facts used by the no-new-A proof.

This is intentionally a literal certificate checker, not a replacement SM64
physics engine.  Rocq proves the arithmetic consequence of the checked
constants; this script makes changes to the source or collision data fail the
proof pipeline instead of silently invalidating those constants.
"""

from __future__ import annotations

import argparse
import math
import re
from collections import Counter
from pathlib import Path

from audit_area2_collision import Triangle, parse_collision


SIGNED_COORD_PERIOD = 65536
FIRST_PU = 32768
ENTRY_SPEED_BOUND = 32
NO_A_SPEED_BOUND = 1024
GROUND_QSTEPS = 4
SLIPPERY_PATH_BUDGET = 16384
ENERGY_COEFFICIENT = 16
DYNAMIC_HORIZONTAL_STEP_BOUND = 64


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def function_body(text: str, name: str) -> str:
    match = re.search(rf"\b{name}\s*\([^;]*?\)\s*\{{", text, re.S)
    require(match is not None, f"function {name} not found")
    start = match.start()
    brace = text.find("{", match.start())
    depth = 0
    for index in range(brace, len(text)):
        if text[index] == "{":
            depth += 1
        elif text[index] == "}":
            depth -= 1
            if depth == 0:
                return text[start : index + 1]
    raise SystemExit(f"unterminated function {name}")


def initializer_body(text: str, name: str) -> str:
    match = re.search(rf"\b{name}\s*\[\]\s*=\s*\{{", text)
    require(match is not None, f"initializer {name} not found")
    end = text.find("};", match.end())
    require(end >= 0, f"unterminated initializer {name}")
    return text[match.start() : end + 2]


def ordered(body: str, *needles: str) -> bool:
    cursor = 0
    for needle in needles:
        cursor = body.find(needle, cursor)
        if cursor < 0:
            return False
        cursor += len(needle)
    return True


def check_warp_and_input_source(root: Path) -> None:
    level_update = (root / "src/game/level_update.c").read_text()
    mario = (root / "src/game/mario.c").read_text()

    after_warp = function_body(level_update, "init_mario_after_warp")
    require(
        ordered(after_warp, "load_mario_area();", "init_mario();", "set_mario_initial_action"),
        "area warp no longer initializes Mario before selecting the spawn action",
    )

    init = function_body(mario, "init_mario")
    require("gMarioState->forwardVel = 0.0f;" in init, "area entry no longer resets forwardVel")
    require("vec3f_set(gMarioState->vel, 0, 0, 0);" in init, "area entry no longer clears velocity")
    require("gMarioState->riddenObj = NULL;" in init, "area entry no longer clears ridden object")
    require("gMarioState->capTimer = 0;" in init, "area entry no longer clears cap timer")

    update_inputs = function_body(mario, "update_mario_inputs")
    require(
        ordered(
            update_inputs,
            "m->input = 0;",
            "update_mario_button_inputs(m);",
            "update_mario_joystick_inputs(m);",
            "update_mario_geometry_inputs(m);",
        ),
        "per-frame input materialization order changed",
    )

    buttons = function_body(mario, "update_mario_button_inputs")
    require(
        "m->controller->buttonPressed & A_BUTTON" in buttons
        and "m->input |= INPUT_A_PRESSED" in buttons,
        "A press no longer comes from the controller edge field",
    )
    require(
        "m->controller->buttonDown & A_BUTTON" in buttons
        and "m->input |= INPUT_A_DOWN" in buttons,
        "held A no longer comes from the controller down field",
    )


def check_action_source(root: Path) -> Counter[str]:
    mario = (root / "src/game/mario.c").read_text()
    moving = (root / "src/game/mario_actions_moving.c").read_text()
    airborne = (root / "src/game/mario_actions_airborne.c").read_text()
    object_actions = (root / "src/game/mario_actions_object.c").read_text()
    step = (root / "src/game/mario_step.c").read_text()

    walking = function_body(moving, "act_walking")
    require(
        ordered(
            walking,
            "INPUT_FIRST_PERSON",
            "begin_braking_action(m)",
            "INPUT_A_PRESSED",
            "set_jump_from_landing(m)",
        ),
        "walking no longer checks C-up braking before the A-press jump path",
    )

    begin_braking = function_body(moving, "begin_braking_action")
    require("m->forwardVel >= 16.0f" in begin_braking, "braking speed gate changed")
    require("m->floor->normal.y >= 0.17364818f" in begin_braking, "braking slope gate changed")

    braking = function_body(moving, "act_braking")
    require(
        ordered(braking, "apply_slope_decel(m, 2.0f)", "perform_ground_step(m)"),
        "braking no longer updates slope speed before the ground step",
    )
    require("slide_bonk(m, ACT_BACKWARD_GROUND_KB, ACT_BRAKING_STOP)" in braking, "braking wall exit changed")

    slope_decel = function_body(moving, "apply_slope_decel")
    require("decel = decelCoef * 0.2f" in slope_decel, "very-slippery braking decel changed")
    require(
        ordered(slope_decel, "approach_f32", "apply_slope_accel(m)"),
        "braking deceleration/slope-acceleration order changed",
    )

    slope_accel = function_body(moving, "apply_slope_accel")
    require("slopeAccel = 5.3f" in slope_accel, "very-slippery slope acceleration changed")
    require("m->vel[1] = 0.0f" in slope_accel, "slope acceleration now supplies vertical velocity")
    require("m->faceAngle[1] =" not in slope_accel, "slope acceleration now turns braking yaw")

    sliding = function_body(moving, "update_sliding_angle")
    require("m->forwardVel > 100.0f" in sliding, "ordinary slide cap threshold changed")
    require("* 100.0f / m->forwardVel" in sliding, "ordinary slide vector cap changed")

    move_punch = function_body(moving, "act_move_punching")
    object_punch = function_body(object_actions, "act_punching")
    for name, body in (("moving punch", move_punch), ("object punch", object_punch)):
        require(
            "INPUT_A_DOWN" in body and "ACT_JUMP_KICK" in body,
            f"held-A {name} jump-kick branch changed",
        )

    airborne_set = function_body(mario, "set_mario_action_airborne")
    jump_kick_case = airborne_set.split("case ACT_JUMP_KICK:", 1)
    require(len(jump_kick_case) == 2, "jump-kick initialization case missing")
    jump_kick_case = jump_kick_case[1].split("break;", 1)[0]
    require("m->vel[1] = 20.0f" in jump_kick_case, "held-A jump-kick vertical impulse changed")
    require("forwardVel" not in jump_kick_case, "jump kick now changes horizontal speed")

    long_jump_land = function_body(moving, "act_long_jump_land")
    require("INPUT_Z_DOWN" in long_jump_land, "long-jump recycle Z gate changed")
    require("~INPUT_A_PRESSED" in long_jump_land, "long-jump recycle A gate changed")
    common_land = function_body(moving, "common_landing_cancels")
    require("INPUT_A_PRESSED" in common_land, "landing rejump no longer requires a fresh A press")

    ground_qstep = function_body(step, "perform_ground_quarter_step")
    require(
        ordered(ground_qstep, "if (floor == NULL)", "return GROUND_STEP_HIT_WALL_STOP_QSTEPS;"),
        "ground floor-null stop changed",
    )
    air_qstep = function_body(step, "perform_air_quarter_step")
    floor_null = air_qstep.split("if (floor == NULL)", 1)
    require(len(floor_null) == 2, "air floor-null branch missing")
    floor_null = floor_null[1].split("if ((m->action", 1)[0]
    require("m->pos[0]" not in floor_null and "m->pos[2]" not in floor_null, "air floor-null now advances X/Z")
    air_step = function_body(step, "perform_air_step")
    require("for (i = 0; i < 4; i++)" in air_step, "air quarter-step count changed")

    expected_a_down = {
        "mario.c": 1,
        "mario_actions_airborne.c": 2,
        "mario_actions_automatic.c": 4,
        "mario_actions_cutscene.c": 2,
        "mario_actions_moving.c": 1,
        "mario_actions_object.c": 1,
        "mario_actions_submerged.c": 5,
        "mario_step.c": 2,
    }
    found = Counter()
    for path in (root / "src/game").rglob("*.c"):
        count = path.read_text().count("INPUT_A_DOWN")
        if count:
            found[path.name] += count
    require(dict(found) == expected_a_down, f"INPUT_A_DOWN source census changed: {dict(found)}")

    return found


def check_area_contents(root: Path) -> None:
    script = (root / "levels/ssl/script.c").read_text()
    macro = (root / "levels/ssl/areas/2/macro.inc.c").read_text()
    area_objects = initializer_body(script, "script_func_local_4") + macro

    forbidden = (
        "KOOPA_SHELL",
        "KoopaShell",
        "bhvHoot",
        "bhvTweester",
        "bhvCannon",
        "macro_cannon",
        "macro_chuckya",
        "macro_heave_ho",
    )
    for token in forbidden:
        require(token not in area_objects, f"Area 2 acquired excluded speed source {token}")

    area_match = re.search(r"AREA\(/\*index\*/\s*2,.*?END_AREA\(\)", script, re.S)
    require(area_match is not None, "SSL Area 2 script missing")
    area_2 = area_match.group(0)
    require("TERRAIN_TYPE(/*terrainType*/ TERRAIN_STONE)" in area_2, "Area 2 terrain class changed")

    horizontal = (root / "src/game/behaviors/horizontal_grindel.inc.c").read_text()
    spindel = (root / "src/game/behaviors/spindel.inc.c").read_text()
    thwomp = (root / "src/game/behaviors/thwomp.inc.c").read_text()
    wall = (root / "src/game/behaviors/pyramid_wall.inc.c").read_text()
    elevator = (root / "src/game/behaviors/pyramid_elevator.inc.c").read_text()
    require("o->oForwardVel = 11.0f" in horizontal, "horizontal Grindel speed changed")
    require("o->oVelZ = 20 / sp18" in spindel, "Spindel positive speed changed")
    require("o->oVelZ = -20 / sp18" in spindel, "Spindel negative speed changed")
    require("o->oPosY += 10.0f" in thwomp, "vertical Grindel rise changed")
    require("o->oVelY = -5.12f" in wall and "o->oVelY = 5.12f" in wall, "moving-wall vertical speed changed")
    require("o->oPosY" in elevator and "o->oPosX" not in elevator and "o->oPosZ" not in elevator, "elevator gained horizontal motion")


def connected_components(triangles: list[Triangle]) -> list[list[Triangle]]:
    remaining = set(range(len(triangles)))
    components: list[list[Triangle]] = []
    while remaining:
        queue = [remaining.pop()]
        component: list[Triangle] = []
        while queue:
            index = queue.pop()
            triangle = triangles[index]
            component.append(triangle)
            vertices = set(triangle.indices)
            neighbors = [
                other
                for other in remaining
                if vertices.intersection(triangles[other].indices)
            ]
            for other in neighbors:
                remaining.remove(other)
                queue.append(other)
        components.append(component)
    return components


def component_bbox(component: list[Triangle]) -> tuple[int, int, int, int, int, int]:
    points = [point for triangle in component for point in triangle.points]
    xs = [point[0] for point in points]
    ys = [point[1] for point in points]
    zs = [point[2] for point in points]
    return min(xs), max(xs), min(ys), max(ys), min(zs), max(zs)


def check_collision(root: Path) -> tuple[list[tuple[int, int, int, int, int, int, int]], int]:
    collision_path = root / "levels/ssl/areas/2/collision.inc.c"
    vertices, triangles = parse_collision(collision_path)
    slippery = [triangle for triangle in triangles if triangle.surface == "SURFACE_VERY_SLIPPERY"]
    require(len(slippery) == 32, f"expected 32 very-slippery triangles, found {len(slippery)}")
    require(
        not any(
            triangle.surface
            in {
                "SURFACE_SLIPPERY",
                "SURFACE_HARD_SLIPPERY",
                "SURFACE_HARD_VERY_SLIPPERY",
                "SURFACE_NO_CAM_COL_SLIPPERY",
            }
            for triangle in triangles
        ),
        "Area 2 acquired another slippery-class surface",
    )
    require(
        not any("WIND" in triangle.surface for triangle in triangles),
        "Area 2 acquired a wind surface",
    )

    bottom = [triangle for triangle in slippery if triangle.bbox[3] <= 113]
    broad = [triangle for triangle in slippery if triangle.bbox[2] >= 1280 and triangle.bbox[3] <= 1536]
    top = [triangle for triangle in slippery if triangle.bbox[2] >= 4800]
    require((len(bottom), len(broad), len(top)) == (24, 2, 6), "slippery family counts changed")
    require(all(triangle.normal[1] >= 0.7 for triangle in slippery), "slippery floor normal fell below 0.7")

    components = connected_components(slippery)
    specs = sorted(
        ((len(component), *component_bbox(component)) for component in components),
        key=lambda spec: spec[1:],
    )
    expected_specs = [
        (2, -3112, -3071, 72, 113, -4095, -3378),
        (8, -3112, -3071, 72, 113, -3173, 2970),
        (4, -2969, -854, 72, 113, 2662, 3113),
        (2, -818, 819, 72, 113, 2586, 2627),
        (2, -818, 819, 1280, 1536, 2560, 3174),
        (6, 387, 643, 4887, 4927, -1125, -409),
        (4, 855, 2970, 72, 113, 2662, 3113),
        (2, 3072, 3113, 72, 113, -3173, -220),
        (2, 3072, 3113, 72, 113, 411, 2714),
    ]
    require(specs == expected_specs, f"slippery component geometry changed: {specs}")
    require(sum(len(component) for component in components) == 32, "slippery component partition is incomplete")
    max_twice_manhattan = max(
        2 * ((max_x - min_x) + (max_z - min_z))
        for _count, min_x, max_x, _min_y, _max_y, min_z, max_z in specs
    )
    require(
        max_twice_manhattan <= SLIPPERY_PATH_BUDGET,
        f"slippery component path budget exceeded: {max_twice_manhattan}",
    )

    xs = [vertex[0] for vertex in vertices]
    zs = [vertex[2] for vertex in vertices]
    require((min(xs), max(xs)) == (-3993, 3994), "Area 2 X mesh envelope changed")
    require((min(zs), max(zs)) == (-4148, 6758), "Area 2 Z mesh envelope changed")

    local_min = min(min(xs), min(zs))
    local_max = max(max(xs), max(zs))
    alias_gap = SIGNED_COORD_PERIOD - (local_max - local_min)
    require((local_min, local_max, alias_gap) == (-4148, 6758, 54630), "uniform alias gap changed")

    collision_source = (root / "src/engine/surface_collision.c").read_text()
    find_floor = function_body(collision_source, "find_floor")
    require(
        ordered(
            find_floor,
            "TerrainData x = (TerrainData) xPos;",
            "TerrainData z = (TerrainData) zPos;",
            "gStaticSurfacePartition",
        ),
        "find_floor signed-coordinate alias path changed",
    )

    require(ENTRY_SPEED_BOUND * ENTRY_SPEED_BOUND + ENERGY_COEFFICIENT * SLIPPERY_PATH_BUDGET < NO_A_SPEED_BOUND * NO_A_SPEED_BOUND, "C-up energy bound no longer closes")
    require(NO_A_SPEED_BOUND // GROUND_QSTEPS < alias_gap, "no-A quarter step reaches the first alias")
    require(DYNAMIC_HORIZONTAL_STEP_BOUND < alias_gap, "dynamic platform step reaches the first alias")
    require(local_max < FIRST_PU and -local_min < FIRST_PU, "local mesh already reaches a PU")

    return specs, alias_gap


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source_root", type=Path)
    args = parser.parse_args()
    root = args.source_root

    check_warp_and_input_source(root)
    a_down_census = check_action_source(root)
    check_area_contents(root)
    specs, alias_gap = check_collision(root)

    print("No-new-A source/mesh certificate: OK")
    print("  area_entry_speed=0 input_policies=A-up|A-held a_pressed=0")
    print("  slippery_triangles=32 families=24+2+6 components=" + str(len(specs)))
    print(
        f"  c_up_entry_bound={ENTRY_SPEED_BOUND} path_budget={SLIPPERY_PATH_BUDGET} "
        f"speed_bound={NO_A_SPEED_BOUND}"
    )
    print(
        f"  local_window=[-4148,6758] alias_gap={alias_gap} "
        f"qstep_bound={NO_A_SPEED_BOUND // GROUND_QSTEPS}"
    )
    print(
        "  a_down_occurrences="
        + str(sum(a_down_census.values()))
        + " dynamic_horizontal_step_bound="
        + str(DYNAMIC_HORIZONTAL_STEP_BOUND)
    )
    for spec in specs:
        print("  slippery_component=" + ",".join(map(str, spec)))


if __name__ == "__main__":
    main()
