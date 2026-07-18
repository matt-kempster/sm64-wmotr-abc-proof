#!/usr/bin/env python3
"""Check source and mesh literals used by the Grindel BLJ certificate."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

from audit_area2_collision import parse_collision, point_in_triangle_xz


GRINDEL_PLACEMENT = (3297, 0, 95)
GRINDEL_PARAMETER = 28
RELEASE_FLOOR_POINTS = ((3609, 95), (3726, 95), (3842, 95), (3958, 95))
FIRST_FLOOR_NULL_POINT = (4074, 95)
PU_ALIAS_POINT = (-2026, 95)

GRINDEL_TOP_TRIANGLES = {
    ((-224, 450, 224), (224, 450, 224), (224, 450, -224)),
    ((-224, 450, 224), (224, 450, -224), (-224, 450, -224)),
}

OUTER_EDGE_TRIANGLE = (
    (3072, 0, -283),
    (3994, 0, 4096),
    (3994, 0, -283),
)
PU_ALIAS_TRIANGLE = (
    (-2546, -101, -25),
    (-1522, -101, 230),
    (-1522, -101, -25),
)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def check_level_placement(level_script: Path) -> None:
    text = level_script.read_text()
    placement = re.search(
        r"OBJECT\s*\(\s*/\*model\*/\s*MODEL_SSL_GRINDEL,"
        r"\s*/\*pos\*/\s*(-?\d+),\s*(-?\d+),\s*(-?\d+),"
        r".*?BPARAM2\((\d+)\).*?bhvGrindel\s*\)",
        text,
    )
    require(placement is not None, "Area 2 vertical Grindel placement not found")
    values = tuple(map(int, placement.groups()))
    require(values[:3] == GRINDEL_PLACEMENT, f"unexpected Grindel position: {values[:3]}")
    require(values[3] == GRINDEL_PARAMETER, f"unexpected Grindel parameter: {values[3]}")


def check_raise_source(behavior_source: Path) -> None:
    text = behavior_source.read_text()
    require(
        "random_float() * 10.0f + 20.0f" in text,
        "Grindel bottom-idle timing window changed",
    )
    require(
        "o->oTimer > o->oBhvParams2ndByte + 40" in text,
        "Grindel raise timer guard changed",
    )
    require("o->oPosY += 10.0f" in text, "10-unit Grindel rise changed")
    require("o->oPosY += 5.0f" in text, "final 5-unit Grindel rise changed")


def check_movement_source(source_root: Path) -> None:
    platform = (source_root / "src/game/platform_displacement.c").read_text()
    require("x += platform->oVelX" in platform, "platform X displacement changed")
    require("z += platform->oVelZ" in platform, "platform Z displacement changed")
    require("y += platform->oVelY" not in platform, "platform now applies vertical displacement")

    mario = (source_root / "src/game/mario.c").read_text()
    require("while (inLoop)" in mario, "subframe action-transition loop changed")
    require(
        "set_mario_y_vel_based_on_fspeed(m, 30.0f, 0.0f)" in mario,
        "long-jump vertical velocity changed",
    )
    require("m->forwardVel *= 1.5f" in mario, "long-jump multiplier changed")

    airborne = (source_root / "src/game/mario_actions_airborne.c").read_text()
    require(
        "approach_f32(m->forwardVel, 0.0f, 0.35f, 0.35f)" in airborne,
        "air approach term changed",
    )
    require("* 1.5f" in airborne, "full-back air acceleration changed")
    require("m->forwardVel < -16.0f" in airborne, "negative soft cap changed")
    require("m->forwardVel += 2.0f" in airborne, "soft-cap correction changed")

    step = (source_root / "src/game/mario_step.c").read_text()
    require("for (i = 0; i < 4; i++)" in step, "air quarter-step count changed")
    require("m->vel[0] / 4.0f" in step, "air X quarter-step divisor changed")
    require("m->vel[1] / 4.0f" in step, "air Y quarter-step divisor changed")
    require("m->vel[1] -= 4.0f" in step, "ordinary gravity changed")


def check_grindel_collision(collision_source: Path) -> None:
    _vertices, triangles = parse_collision(collision_source)
    top = {triangle.points for triangle in triangles if triangle.normal[1] > 0.99}
    require(
        GRINDEL_TOP_TRIANGLES <= top,
        "expected Grindel top triangles were not found",
    )


def find_triangle(triangles, points):
    return next((triangle for triangle in triangles if triangle.points == points), None)


def check_area_collision(collision_source: Path) -> None:
    vertices, triangles = parse_collision(collision_source)
    xs = [vertex[0] for vertex in vertices]
    require((min(xs), max(xs)) == (-3993, 3994), "Area 2 mesh x envelope changed")

    outer = find_triangle(triangles, OUTER_EDGE_TRIANGLE)
    require(outer is not None, "outer-edge floor triangle not found")
    for point in RELEASE_FLOOR_POINTS:
        require(point_in_triangle_xz(point, outer), f"release qstep {point} left its floor")
    require(
        FIRST_FLOOR_NULL_POINT[0] > max(xs),
        "first floor-null qstep no longer clears the static mesh",
    )

    alias = find_triangle(triangles, PU_ALIAS_TRIANGLE)
    require(alias is not None, "PU-alias floor triangle not found")
    require(point_in_triangle_xz(PU_ALIAS_POINT, alias), "PU alias left its floor")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source_root", type=Path)
    args = parser.parse_args()
    root = args.source_root

    check_level_placement(root / "levels/ssl/script.c")
    check_raise_source(root / "src/game/behaviors/thwomp.inc.c")
    check_movement_source(root)
    check_grindel_collision(root / "levels/ssl/grindel/collision.inc.c")
    check_area_collision(root / "levels/ssl/areas/2/collision.inc.c")

    print("Grindel route source certificate: OK")
    print("  placement=(3297,0,95) parameter=28 rise_frames=69 rise=10")
    print("  bootstrap=16 air updates, catch=qstep 3, grindel recycles=9")
    print("  release_qsteps=3609,3726,3842,3958 floor_null=4074 pu_alias=-2026")


if __name__ == "__main__":
    main()
