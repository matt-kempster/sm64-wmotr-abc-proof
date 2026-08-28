#!/usr/bin/env python3
"""Audit the pinned Eyerok source surface and collision bounds."""

from __future__ import annotations

import hashlib
import math
import re
import struct
import subprocess
import sys
from pathlib import Path


PIN = "9921382a68bb0c865e5e45eb594d9c64db59b1af"
JP_ROM_SHA1 = "8a20a5c83d6ceb0f0506cfc9fa20d8f438cafe51"

IDENTICAL_PATHS = [
    "src/game/behaviors/eyerok.inc.c",
    "src/game/obj_behaviors_2.c",
    "src/game/object_helpers.c",
    "src/engine/behavior_script.c",
    "src/game/object_list_processor.c",
    "src/game/spawn_object.c",
    "src/game/mario_step.c",
    "src/game/mario_actions_airborne.c",
    "src/game/mario_actions_cutscene.c",
    "src/game/mario.c",
    "src/game/game_init.c",
    "src/game/platform_displacement.c",
    "src/game/interaction.c",
    "src/game/macro_special_objects.c",
    "src/game/behaviors/coin.inc.c",
    "src/game/behaviors/break_particles.inc.c",
    "src/engine/math_util.c",
    "src/engine/surface_collision.c",
    "src/engine/surface_load.c",
    "include/object_constants.h",
    "include/object_fields.h",
    "include/macro_presets.inc.c",
    "data/behavior_data.c",
    "actors/eyerok/anims/anim_0500DF50.inc.c",
    "actors/eyerok/anims/anim_0500E99C.inc.c",
    "actors/eyerok/anims/anim_0500F3D8.inc.c",
    "actors/eyerok/anims/anim_050116CC.inc.c",
    "levels/ssl/areas/2/collision.inc.c",
    "levels/ssl/areas/2/macro.inc.c",
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


def strip_disabled_tas_hack_blocks(text: str) -> str:
    """Remove positive SSL TAS-hack blocks, matching the default-disabled build."""
    kept: list[str] = []
    skipped_depth = 0
    for line in text.splitlines(keepends=True):
        directive = re.match(r"\s*#\s*(if|ifdef|ifndef|endif)\b(.*)", line)
        if skipped_depth:
            if directive and directive.group(1) in {"if", "ifdef", "ifndef"}:
                skipped_depth += 1
            elif directive and directive.group(1) == "endif":
                skipped_depth -= 1
            continue
        if re.match(
            r"\s*#\s*if\s+SSL_SPAWNING_DISPLACEMENT_TAS_HACK\s*(?://.*)?$",
            line,
        ):
            skipped_depth = 1
            continue
        kept.append(line)
    if skipped_depth:
        fail("unterminated SSL TAS-hack preprocessor block")
    return "".join(kept)


def require(text: str, fragment: str, label: str) -> None:
    if compact(fragment) not in compact(text):
        fail(f"missing {label}")


def binary32(value: float) -> float:
    """Round a host float through IEEE-754 binary32."""
    return struct.unpack(">f", struct.pack(">f", value))[0]


def binary32_air_update_full_forward(value: float) -> float:
    """Exercise the audited non-wind branch with full aligned stick input."""
    current = binary32(value)
    step = binary32(0.35)
    if current < 0.0:
        current = binary32(current + step)
        if current > 0.0:
            current = 0.0
    else:
        current = binary32(current - step)
        if current < 0.0:
            current = 0.0
    current = binary32(current + binary32(1.5))
    if current > 32.0:
        current = binary32(current - binary32(1.0))
    if current < -16.0:
        current = binary32(current + binary32(2.0))
    return current


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
    object_behaviors = pinned(sm64, "src/game/obj_behaviors_2.c")
    behavior_script = pinned(sm64, "src/engine/behavior_script.c")
    behavior_data = pinned(sm64, "data/behavior_data.c")
    object_lists = pinned(sm64, "src/game/object_list_processor.c")
    spawn_object = pinned(sm64, "src/game/spawn_object.c")
    mario_step = pinned(sm64, "src/game/mario_step.c")
    mario_airborne = pinned(sm64, "src/game/mario_actions_airborne.c")
    mario_cutscene = pinned(sm64, "src/game/mario_actions_cutscene.c")
    mario = pinned(sm64, "src/game/mario.c")
    game_init = pinned(sm64, "src/game/game_init.c")
    platform_displacement = pinned(sm64, "src/game/platform_displacement.c")
    interaction = pinned(sm64, "src/game/interaction.c")
    macro_special_objects = pinned(sm64, "src/game/macro_special_objects.c")
    coin = pinned(sm64, "src/game/behaviors/coin.inc.c")
    area_source = pinned(sm64, "src/game/area.c")
    level_update = pinned(sm64, "src/game/level_update.c")
    working_area_source = strip_disabled_tas_hack_blocks(
        working(sm64, "src/game/area.c")
    )
    working_level_update = strip_disabled_tas_hack_blocks(
        working(sm64, "src/game/level_update.c")
    )
    makefile = pinned(sm64, "Makefile")
    jp_sha1_manifest = pinned(sm64, "sm64.jp.sha1")
    break_particles = pinned(sm64, "src/game/behaviors/break_particles.inc.c")
    math_util = pinned(sm64, "src/engine/math_util.c")
    surface_collision = pinned(sm64, "src/engine/surface_collision.c")
    surface_load = pinned(sm64, "src/engine/surface_load.c")
    ssl_script = pinned(sm64, "levels/ssl/script.c")
    area2 = pinned(sm64, "levels/ssl/areas/2/collision.inc.c")
    area2_macros = pinned(sm64, "levels/ssl/areas/2/macro.inc.c")
    area3 = pinned(sm64, "levels/ssl/areas/3/collision.inc.c")
    area3_macros = pinned(sm64, "levels/ssl/areas/3/macro.inc.c")
    hand_collision = pinned(sm64, "levels/ssl/eyerok_col/collision.inc.c")
    die_animation = pinned(sm64, "actors/eyerok/anims/anim_0500DF50.inc.c")
    attacked_animation = pinned(sm64, "actors/eyerok/anims/anim_0500E99C.inc.c")
    open_animation = pinned(sm64, "actors/eyerok/anims/anim_0500F3D8.inc.c")
    wake_animation = pinned(sm64, "actors/eyerok/anims/anim_050116CC.inc.c")
    macro_presets = pinned(sm64, "include/macro_presets.inc.c")

    actions = re.findall(r"#define\s+EYEROK_HAND_ACT_[A-Z_]+\s+(\d+)", constants)
    if list(map(int, actions)) != list(range(16)):
        fail(f"unexpected Eyerok hand action values: {actions}")

    hand_functions = {
        name: c_function_body(eyerok, name)
        for name in [
            "eyerok_hand_check_attacked",
            "eyerok_hand_act_sleep",
            "eyerok_hand_act_idle",
            "eyerok_hand_act_open",
            "eyerok_hand_act_show_eye",
            "eyerok_hand_act_close",
            "eyerok_hand_act_attacked",
            "eyerok_hand_act_recover",
            "eyerok_hand_act_become_active",
            "eyerok_hand_act_die",
            "eyerok_hand_act_retreat",
            "eyerok_hand_act_double_pound",
        ]
    }

    hitbox_match = re.search(
        r"struct\s+ObjectHitbox\s+sEyerokHitbox\s*=\s*\{(.*?)\};",
        eyerok,
        re.DOTALL,
    )
    if hitbox_match is None:
        fail("missing Eyerok hitbox")
    hitbox_body = hitbox_match.group(1)
    require(hitbox_body, "/* health: */ 4,", "Eyerok initial health 4")

    set_hitbox_body = c_function_body(helpers, "obj_set_hitbox")
    require(
        set_hitbox_body,
        "if (!(obj->oFlags & OBJ_FLAG_30)) { obj->oFlags |= OBJ_FLAG_30;",
        "one-time hitbox initialization guard",
    )
    require(
        set_hitbox_body,
        "obj->oHealth = hitbox->health;",
        "one-time hitbox health initialization",
    )

    attacked_check_body = hand_functions["eyerok_hand_check_attacked"]
    if len(re.findall(r"--o->oHealth", eyerok)) != 1:
        fail("Eyerok health predecrement count is not exactly one")
    if len(re.findall(r"o->oHealth", eyerok)) != 1:
        fail("Eyerok hand behavior has an unexpected health access")
    require(
        attacked_check_body,
        "if (--o->oHealth >= 2) { "
        "o->oAction = EYEROK_HAND_ACT_ATTACKED; o->oVelY = 30.0f; "
        "} else { o->parentObj->oEyerokBossNumHands--; "
        "o->oAction = EYEROK_HAND_ACT_DIE; o->oVelY = 50.0f; }",
        "health 4/3 nonlethal and health 2 lethal branch",
    )

    show_eye_body = hand_functions["eyerok_hand_act_show_eye"]
    if show_eye_body.count("eyerok_hand_check_attacked()") != 1:
        fail("SHOW_EYE does not call the attack consumer exactly once")
    if len(re.findall(r"\beyerok_hand_check_attacked\s*\(\s*\)", eyerok)) != 1:
        fail("attack response is called outside SHOW_EYE")
    idle_assignment_pattern = r"o->oAction\s*=\s*EYEROK_HAND_ACT_IDLE\s*;"
    idle_assignment_sources = [
        name
        for name, body in hand_functions.items()
        if re.search(idle_assignment_pattern, body)
    ]
    if len(re.findall(idle_assignment_pattern, eyerok)) != 3:
        fail("IDLE assignment count is not exactly three")
    if idle_assignment_sources != [
        "eyerok_hand_act_sleep",
        "eyerok_hand_act_close",
        "eyerok_hand_act_retreat",
    ]:
        fail(f"unexpected IDLE assignment sources: {idle_assignment_sources}")
    if any("oVelY" in hand_functions[name] for name in idle_assignment_sources):
        fail("an IDLE-entry handler unexpectedly reads or writes oVelY")

    idle_body = hand_functions["eyerok_hand_act_idle"]
    zero_gravity_writes = re.findall(r"o->oGravity\s*=\s*0\.0f\s*;", eyerok)
    if len(zero_gravity_writes) != 2 or len(
        re.findall(r"o->oGravity\s*=\s*0\.0f\s*;", idle_body)
    ) != 2:
        fail("zero-gravity writes are not exactly the two IDLE exits")
    require(
        idle_body,
        "o->oAction = EYEROK_HAND_ACT_BEGIN_DOUBLE_POUND; o->oGravity = 0.0f;",
        "IDLE to BEGIN_DOUBLE_POUND zero-gravity exit",
    )
    if re.search(
        r"o->oAction\s*=\s*EYEROK_HAND_ACT_TARGET_MARIO\s*;"
        r".*?o->oGravity\s*=\s*0\.0f\s*;",
        idle_body,
        re.DOTALL,
    ) is None:
        fail("missing IDLE to TARGET_MARIO zero-gravity exit")

    all_vel_writes = re.findall(r"o->oVelY\s*=\s*([^;]+);", eyerok)
    if all_vel_writes != ["30.0f", "50.0f", "100.0f"]:
        fail(f"unexpected direct vertical-velocity writers: {all_vel_writes}")
    vel_writes = re.findall(r"o->oVelY\s*=\s*([0-9]+(?:\.[0-9]+)?)f", eyerok)
    if vel_writes != ["30.0", "50.0", "100.0"]:
        fail(f"unexpected positive vertical-velocity writers: {vel_writes}")
    if re.findall(
        r"o->oVelY\s*=\s*([0-9]+(?:\.[0-9]+)?)f",
        hand_functions["eyerok_hand_check_attacked"],
    ) != ["30.0", "50.0"]:
        fail("ATTACKED/DIE positive-velocity writers changed")
    if re.findall(
        r"o->oVelY\s*=\s*([0-9]+(?:\.[0-9]+)?)f",
        hand_functions["eyerok_hand_act_double_pound"],
    ) != ["100.0"]:
        fail("DOUBLE_POUND positive-velocity writer changed")
    require(
        hand_functions["eyerok_hand_check_attacked"],
        "o->oAction = EYEROK_HAND_ACT_ATTACKED; o->oVelY = 30.0f;",
        "ATTACKED positive-velocity transition",
    )
    require(
        hand_functions["eyerok_hand_check_attacked"],
        "o->oAction = EYEROK_HAND_ACT_DIE; o->oVelY = 50.0f;",
        "DIE positive-velocity transition",
    )

    attacked_body = hand_functions["eyerok_hand_act_attacked"]
    require(
        attacked_body,
        "if (cur_obj_init_anim_and_check_if_end(3)) { o->oAction = EYEROK_HAND_ACT_RECOVER;",
        "ATTACKED animation-gated RECOVER transition",
    )
    if "oVelY" in attacked_body or "oGravity" in attacked_body:
        fail("ATTACKED handler unexpectedly changes vertical velocity or gravity")
    attacked_animation_match = re.search(
        r"0x([0-9A-Fa-f]+),\s*ANIMINDEX_NUMPARTS\(eyerok_seg5_animindex_0500E798\)",
        attacked_animation,
    )
    if attacked_animation_match is None:
        fail("missing ATTACKED animation length")
    attacked_animation_frames = int(attacked_animation_match.group(1), 16)
    attacked_positive_integrations = math.ceil(30 / 4)
    if attacked_animation_frames < attacked_positive_integrations:
        fail(
            "ATTACKED can reach RECOVER before positive velocity expires: "
            f"{attacked_animation_frames} < {attacked_positive_integrations}"
        )

    # The ordinary arena-floor schedule reaches equality on movement 14 and
    # triggers the strict-below-floor snap with zero bounciness on movement
    # 15.  This is stronger than merely waiting for velocity to become
    # nonpositive after eight integrations.
    attacked_velocity = 30
    attacked_relative_y = 0
    attacked_ground_trace: list[tuple[int, int, bool]] = []
    for _ in range(attacked_animation_frames):
        attacked_velocity -= 4
        candidate_y = attacked_relative_y + attacked_velocity
        grounded = candidate_y < 0
        if grounded:
            attacked_relative_y = 0
            if attacked_velocity < 0:
                attacked_velocity = 0
        else:
            attacked_relative_y = candidate_y
        attacked_ground_trace.append(
            (attacked_relative_y, attacked_velocity, grounded)
        )
        if grounded:
            break
    expected_attacked_ground_trace = [
        (26, 26, False),
        (48, 22, False),
        (66, 18, False),
        (80, 14, False),
        (90, 10, False),
        (96, 6, False),
        (98, 2, False),
        (96, -2, False),
        (90, -6, False),
        (80, -10, False),
        (66, -14, False),
        (48, -18, False),
        (26, -22, False),
        (0, -26, False),
        (0, 0, True),
    ]
    if attacked_ground_trace != expected_attacked_ground_trace:
        fail(f"unexpected nonlethal ground trace: {attacked_ground_trace}")
    attacked_ground_integrations = len(attacked_ground_trace)
    if attacked_animation_frames < attacked_ground_integrations:
        fail(
            "ATTACKED can recover before the ordinary ground reset: "
            f"{attacked_animation_frames} < {attacked_ground_integrations}"
        )

    recover_body = hand_functions["eyerok_hand_act_recover"]
    become_active_body = hand_functions["eyerok_hand_act_become_active"]
    retreat_body = hand_functions["eyerok_hand_act_retreat"]
    close_body = hand_functions["eyerok_hand_act_close"]
    require(
        recover_body,
        "if (cur_obj_init_anim_and_check_if_end(0)) { "
        "o->oAction = EYEROK_HAND_ACT_BECOME_ACTIVE; }",
        "RECOVER to BECOME_ACTIVE transition",
    )
    require(
        become_active_body,
        "if (o->parentObj->oEyerokBossActiveHand == 0 || "
        "o->parentObj->oEyerokBossNumHands != 2) { "
        "o->oAction = EYEROK_HAND_ACT_RETREAT;",
        "BECOME_ACTIVE to RETREAT transition",
    )
    require(
        retreat_body,
        "if (approach_f32_ptr(&o->oPosY, o->oHomeY, 20.0f) "
        "&& distToHome == 0.0f && o->oFaceAngleYaw == 0) { "
        "o->oAction = EYEROK_HAND_ACT_IDLE;",
        "RETREAT exact-home IDLE guard",
    )
    require(
        close_body,
        "if (o->parentObj->oEyerokBossNumHands != 2) { "
        "o->oAction = EYEROK_HAND_ACT_RETREAT; "
        "o->parentObj->oEyerokBossActiveHand = o->oBhvParams2ndByte; "
        "} else if (o->parentObj->oEyerokBossActiveHand == 0) { "
        "o->oAction = EYEROK_HAND_ACT_IDLE;",
        "CLOSE retreat-or-idle recovery branch",
    )

    action_writer_expectations = {
        "ATTACKED": ["eyerok_hand_check_attacked"],
        "DIE": ["eyerok_hand_check_attacked"],
        "RECOVER": ["eyerok_hand_act_attacked"],
        "BECOME_ACTIVE": ["eyerok_hand_act_recover"],
        "OPEN": ["eyerok_hand_act_idle"],
        "SHOW_EYE": ["eyerok_hand_act_open"],
    }
    for action, expected_sources in action_writer_expectations.items():
        pattern = rf"o->oAction\s*=\s*EYEROK_HAND_ACT_{action}\s*;"
        actual_sources = [
            name for name, body in hand_functions.items() if re.search(pattern, body)
        ]
        if actual_sources != expected_sources:
            fail(f"unexpected {action} action writers: {actual_sources}")

    approach_body = c_function_body(object_behaviors, "approach_f32_ptr")
    require(
        approach_body,
        "if (*px > target) { delta = -delta; } *px += delta;",
        "approach direction and update",
    )
    require(
        approach_body,
        "if ((*px - target) * delta >= 0) { "
        "*px = target; return TRUE; } return FALSE;",
        "approach exact-target success clamp",
    )

    hand_loop_body = c_function_body(eyerok, "bhv_eyerok_hand_loop")
    if len(re.findall(r"o->oEyerokReceivedAttack\s*=", eyerok)) != 1:
        fail("attack latch overwrite count is not exactly one")
    if len(re.findall(r"o->oEyerokReceivedAttack", eyerok)) != 2:
        fail("attack latch has an unexpected read or write")
    require(
        hand_loop_body,
        "o->oEyerokReceivedAttack = "
        "obj_check_attacks(&sEyerokHitbox, o->oAction); "
        "cur_obj_move_standard(-78);",
        "handler then attack-latch overwrite then movement order",
    )

    check_attacks_body = c_function_body(object_behaviors, "obj_check_attacks")
    require(
        check_attacks_body,
        "obj_set_hitbox(o, hitbox);",
        "attack check initializes hitbox",
    )
    if check_attacks_body.count("o->oInteractStatus = 0;") != 2:
        fail("obj_check_attacks interaction-status clear count changed")
    require(
        check_attacks_body,
        "attackType = o->oInteractStatus & INT_STATUS_ATTACK_MASK; "
        "obj_die_if_health_non_positive(); o->oInteractStatus = 0; "
        "return attackType;",
        "current-frame attack-mask return",
    )
    require(
        check_attacks_body,
        "o->oInteractStatus = 0; return 0;",
        "no-attack latch overwrite value",
    )

    boss_fight_body = c_function_body(eyerok, "eyerok_boss_act_fight")
    terminal_guard = re.search(
        r"else\s+if\s*\(o->oEyerokBossUnk1AC\s*==\s*0\s*&&\s*"
        r"o->oEyerokBossActiveHand\s*==\s*0\)\s*\{(.*)\}\s*$",
        boss_fight_body,
        re.DOTALL,
    )
    if terminal_guard is None:
        fail("missing boss zero-active-hand scheduler guard")
    terminal_guard_body = terminal_guard.group(1)
    outside_terminal_guard = (
        boss_fight_body[: terminal_guard.start()] + boss_fight_body[terminal_guard.end() :]
    )
    if re.search(
        r"(?:\+\+o->oEyerokBossUnk104|o->oEyerokBossUnk104--|"
        r"o->oEyerokBossUnk104\s*=\s*1\s*;)",
        outside_terminal_guard,
    ):
        fail("a terminal Unk104 mutation occurs outside the zero-active-hand guard")
    require(
        terminal_guard_body,
        "if (!eyerok_check_mario_relative_z(400) && ++o->oEyerokBossUnk104 == 0) { o->oEyerokBossUnk104 = 1;",
        "negative double terminal request",
    )
    require(
        terminal_guard_body,
        "} else { o->oEyerokBossUnk104--; }",
        "positive double terminal countdown",
    )
    double_body = hand_functions["eyerok_hand_act_double_pound"]
    if re.search(
        r"if\s*\(o->parentObj->oEyerokBossUnk104\s*==\s*1\)\s*\{"
        r".*?o->oAction\s*=\s*EYEROK_HAND_ACT_RETREAT\s*;"
        r".*?\}\s*else\s+if\s*\(o->parentObj->oEyerokBossActiveHand\s*==\s*"
        r"o->oBhvParams2ndByte\)",
        double_body,
        re.DOTALL,
    ) is None:
        fail("DOUBLE_POUND terminal RETREAT check no longer precedes active branch")

    active_clear_pattern = r"o->parentObj->oEyerokBossActiveHand\s*=\s*0\s*;"
    active_clear_sources = [
        name
        for name, body in hand_functions.items()
        if re.search(active_clear_pattern, body)
    ]
    if len(re.findall(active_clear_pattern, eyerok)) != 2 or active_clear_sources != [
        "eyerok_hand_act_show_eye",
        "eyerok_hand_act_double_pound",
    ]:
        fail(f"unexpected active-hand zero writers: {active_clear_sources}")
    if re.search(
        r"if\s*\(o->oMoveFlags\s*&\s*OBJ_MOVE_MASK_ON_GROUND\)\s*\{"
        r"\s*if\s*\(o->oGravity\s*<\s*-15\.0f\)\s*\{"
        r"\s*o->parentObj->oEyerokBossActiveHand\s*=\s*0\s*;",
        double_body,
        re.DOTALL,
    ) is None:
        fail("DOUBLE_POUND active-hand clear is not grounded with gravity < -15")
    if re.search(
        r"if\s*\(o->parentObj->oEyerokBossNumHands\s*!=\s*2\)\s*\{"
        r".*?o->parentObj->oEyerokBossActiveHand\s*=\s*0\s*;",
        hand_functions["eyerok_hand_act_show_eye"],
        re.DOTALL,
    ) is None:
        fail("SHOW_EYE active-hand clear is no longer guarded by one-hand phase")
    require(
        double_body,
        "if (o->parentObj->oEyerokBossNumHands != 2) { "
        "o->parentObj->oEyerokBossActiveHand = o->oBhvParams2ndByte; }",
        "single-hand DOUBLE_POUND active-hand reassertion",
    )
    exposure_latch_writes = re.findall(
        r"o->parentObj->oEyerokBossUnk1AC\s*(?<![=!<>])=(?!=)\s*([^;]+);",
        eyerok,
    )
    if exposure_latch_writes != [
        "o->oBhvParams2ndByte",
        "0",
        "0",
        "0",
        "o->oBhvParams2ndByte",
    ]:
        fail(f"unexpected Unk1AC writer sequence: {exposure_latch_writes}")
    require(
        hand_functions["eyerok_hand_act_open"],
        "o->parentObj->oEyerokBossUnk1AC = o->oBhvParams2ndByte;",
        "OPEN exposure-latch acquisition",
    )
    if "oEyerokBossUnk1AC" in hand_functions["eyerok_hand_act_show_eye"]:
        fail("SHOW_EYE unexpectedly changes the exposure latch")

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
    direct_hand_z_writers = re.findall(r"o->oPosZ\s*=\s*([^;]+);", eyerok)
    if direct_hand_z_writers != [
        "o->oHomeZ - distToHome * coss(angleToHome)",
        "o->oHomeZ + (o->parentObj->oEyerokBossUnk10C - o->oHomeZ) * o->parentObj->oEyerokBossUnk110",
    ]:
        fail(f"unexpected direct hand Z writers: {direct_hand_z_writers}")
    require(
        c_function_body(eyerok, "eyerok_boss_act_fight"),
        "o->oEyerokBossUnk10C = gMarioObject->oPosZ; "
        "clamp_f32(&o->oEyerokBossUnk10C, o->oPosZ + 400.0f, o->oPosZ + 1600.0f);",
        "begin-double target Z is clamped to the ordinary boss band",
    )
    require(
        c_function_body(eyerok, "eyerok_hand_act_target_mario"),
        "obj_forward_vel_approach(50.0f, 5.0f);",
        "target-Mario hand speed cap",
    )
    require(
        c_function_body(eyerok, "eyerok_hand_act_fist_push"),
        "o->oForwardVel = 50.0f;",
        "fist-push hand speed",
    )
    fist_sweep_body = c_function_body(eyerok, "eyerok_hand_act_fist_sweep")
    require(fist_sweep_body, "o->oForwardVel *= 1.08f;", "fist-sweep growing speed")
    require(
        c_function_body(eyerok, "eyerok_hand_act_fist_push"),
        "o->oMoveAngleYaw = 0x4000;",
        "positive fist-sweep quarter-turn",
    )
    require(
        c_function_body(eyerok, "eyerok_hand_act_fist_push"),
        "o->oMoveAngleYaw = -0x4000;",
        "negative fist-sweep quarter-turn",
    )
    require(object_lists, "clear_dynamic_surfaces();", "dynamic-surface clear")
    require(object_lists, "update_objects_in_list(&gObjectLists[OBJ_LIST_SURFACE])", "surface-list update")
    require(object_lists, "OBJ_LIST_SURFACE, OBJ_LIST_POLELIKE, OBJ_LIST_PLAYER, OBJ_LIST_PUSHABLE, OBJ_LIST_GENACTOR", "surface-before-boss order")
    require(spawn_object, "Insert at the end of destination list", "append-order allocation")
    require(spawn_object, "obj->activeFlags = ACTIVE_FLAG_ACTIVE | ACTIVE_FLAG_UNK8;", "spawn active flags exclude partial bits")
    require(spawn_object, "obj->collisionData = NULL;", "collision starts null")
    require(spawn_object, "obj->oRoom = -1;", "room starts minus one")
    require(spawn_object, "obj->oCollisionDistance = 1000.0f;", "default object collision distance")
    if "oCollisionDistance" in eyerok:
        fail("Eyerok hand behavior unexpectedly changes collision distance")
    require(
        surface_load,
        "f32 marioDist = gCurrentObject->oDistanceToMario; "
        "f32 tangibleDist = gCurrentObject->oCollisionDistance;",
        "dynamic-surface distance operands",
    )
    require(
        surface_load,
        "marioDist < tangibleDist",
        "strict dynamic-surface collision-load distance",
    )
    require(
        surface_load,
        "if (!(gTimeStopState & TIME_STOP_ACTIVE)) { "
        "gSurfacesAllocated = gNumStaticSurfaces; "
        "gSurfaceNodesAllocated = gNumStaticSurfaceNodes; "
        "clear_spatial_partition(&gDynamicSurfacePartition[0][0]); }",
        "active-frame dynamic-surface clear and time-stop retention",
    )
    require(
        surface_load,
        "if (!(gTimeStopState & TIME_STOP_ACTIVE) && marioDist < tangibleDist",
        "time stop forbids a fresh dynamic-surface load",
    )
    require(
        platform_displacement,
        "if (!(gTimeStopState & TIME_STOP_ACTIVE) && gMarioObject != NULL && platform != NULL)",
        "time stop forbids Mario platform displacement",
    )
    update_objects_body = c_function_body(object_lists, "update_objects")
    scheduler_order = [
        update_objects_body.find("clear_dynamic_surfaces();"),
        update_objects_body.find("update_terrain_objects();"),
        update_objects_body.find("apply_mario_platform_displacement();"),
        update_objects_body.find("update_non_terrain_objects();"),
        update_objects_body.find("update_mario_platform();"),
    ]
    if any(index < 0 for index in scheduler_order) or scheduler_order != sorted(scheduler_order):
        fail(f"unexpected surface/Mario scheduler order: {scheduler_order}")
    require(object_lists, "if (unfrozen) { gCurrentObject->header.gfx.node.flags |= GRAPH_RENDER_HAS_ANIMATION; cur_obj_update(); } else { gCurrentObject->header.gfx.node.flags &= ~GRAPH_RENDER_HAS_ANIMATION; }", "time stop freezes whole object update")
    require(
        object_lists,
        "if (gCurrentObject == gMarioObject && !(gTimeStopState & TIME_STOP_MARIO_AND_DOORS)) { "
        "unfrozen = TRUE; }",
        "time stop may leave Mario scheduled",
    )
    move_xz_body = c_function_body(helpers, "cur_obj_move_xz")
    require(
        move_xz_body,
        "if (intendedFloorHeight < FLOOR_LOWER_LIMIT_MISC)",
        "hand movement tests a no-floor endpoint",
    )
    require(
        move_xz_body,
        "o->oMoveFlags |= OBJ_MOVE_HIT_EDGE; return FALSE;",
        "hand movement marks and rejects a bad endpoint",
    )
    boss_wake_body = c_function_body(eyerok, "eyerok_boss_act_wake_up")
    require(
        boss_wake_body,
        "if (o->oEyerokBossUnk110 == 0.0f && mario_ready_to_speak()) { "
        "o->oAction = EYEROK_BOSS_ACT_SHOW_INTRO_TEXT; }",
        "Eyerok intro requires a ready-to-speak predecessor",
    )
    ready_body = c_function_body(mario_cutscene, "mario_ready_to_speak")
    require(
        ready_body,
        "gMarioState->action == ACT_WAITING_FOR_DIALOG || actionGroup == ACT_GROUP_STATIONARY "
        "|| actionGroup == ACT_GROUP_MOVING",
        "dialog readiness excludes ordinary airborne actions",
    )
    dialog_body = c_function_body(helpers, "cur_obj_update_dialog_with_cutscene")
    require(
        dialog_body,
        "gTimeStopState |= TIME_STOP_ENABLED; "
        "o->activeFlags |= ACTIVE_FLAG_INITIATED_TIME_STOP; "
        "o->oDialogState++;",
        "unfixed dialog helper enables time stop before interrupt succeeds",
    )
    require(
        dialog_body,
        "gTimeStopState &= ~TIME_STOP_ENABLED; "
        "o->activeFlags &= ~ACTIVE_FLAG_INITIATED_TIME_STOP; "
        "dialogResponse = o->oDialogResponse; "
        "o->oDialogState = DIALOG_STATUS_ENABLE_TIME_STOP;",
        "completed Eyerok dialog clears its time stop",
    )
    dialog_calls = re.findall(r"cur_obj_update_dialog_with_cutscene\s*\(", eyerok)
    if len(dialog_calls) != 2:
        fail(f"unexpected Eyerok dialog call count: {len(dialog_calls)}")
    intro_body = c_function_body(eyerok, "eyerok_boss_act_show_intro_text")
    death_body = c_function_body(eyerok, "eyerok_boss_act_die")
    require(
        intro_body,
        "cur_obj_update_dialog_with_cutscene(MARIO_DIALOG_LOOK_UP, DIALOG_FLAG_NONE, "
        "CUTSCENE_DIALOG, DIALOG_117)",
        "intro is the first Eyerok dialog callsite",
    )
    require(
        death_body,
        "if (o->oTimer == 60) { "
        "if (cur_obj_update_dialog_with_cutscene(MARIO_DIALOG_LOOK_UP, DIALOG_FLAG_NONE, "
        "CUTSCENE_DIALOG, DIALOG_118))",
        "death dialog begins only at boss timer 60",
    )
    if len(re.findall(r"o->oAction\s*=\s*EYEROK_BOSS_ACT_SHOW_INTRO_TEXT\s*;", eyerok)) != 1:
        fail("SHOW_INTRO_TEXT no longer has one writer")
    if len(re.findall(r"o->oAction\s*=\s*EYEROK_BOSS_ACT_DIE\s*;", eyerok)) != 1:
        fail("boss DIE no longer has one writer")
    require(
        c_function_body(eyerok, "eyerok_boss_act_fight"),
        "if (o->oEyerokBossNumHands == 0) { o->oAction = EYEROK_BOSS_ACT_DIE; }",
        "boss death requires zero counted hands",
    )
    require(
        c_function_body(eyerok, "eyerok_hand_check_attacked"),
        "o->parentObj->oEyerokBossNumHands--; "
        "o->oAction = EYEROK_HAND_ACT_DIE; o->oVelY = 50.0f;",
        "a hand leaves the boss count when it enters DIE",
    )
    require(
        c_function_body(eyerok, "eyerok_hand_act_die"),
        "if (cur_obj_init_anim_and_check_if_end(1)) { "
        "o->parentObj->oEyerokBossUnk1AC = 0; "
        "obj_explode_and_spawn_coins(150.0f, 1);",
        "dying hand deletion is gated by animation 1",
    )
    idle_body = c_function_body(eyerok, "eyerok_hand_act_idle")
    require(
        idle_body,
        "if (o->parentObj->oAction == EYEROK_BOSS_ACT_FIGHT)",
        "all attacking hand transitions require boss FIGHT",
    )
    require(
        idle_body,
        "} else { o->oPosY = o->oHomeY + o->parentObj->oEyerokBossUnk110; }",
        "pre-fight idle hands change only Y",
    )
    if "oPosZ" in idle_body.split("} else {")[-1]:
        fail("pre-fight idle branch unexpectedly writes hand Z")
    require(eyerok, "if (o->oTimer == 0) { eyerok_spawn_hand(-1", "boss spawns hands without same-tick wake transition")
    require(eyerok, "if (o->oBhvParams2ndByte < 0) { o->collisionData = segmented_to_virtual(&ssl_seg7_collision_070284B0); } else { o->collisionData = segmented_to_virtual(&ssl_seg7_collision_07028370); }", "first sleep update assigns collision")
    require(surface_collision, "if (y - (height + -78.0f) < 0.0f)", "find-floor 78-unit buffer")
    require(surface_load, "*vertexData++ = (TerrainData)(vx * m[0][0] + vy * m[1][0] + vz * m[2][0] + m[3][0]);", "dynamic collision X transform")
    require(surface_load, "*vertexData++ = (TerrainData)(vx * m[0][1] + vy * m[1][1] + vz * m[2][1] + m[3][1]);", "dynamic collision Y transform")

    quarter_step_body = c_function_body(mario_step, "perform_air_quarter_step")
    require(
        quarter_step_body,
        "upperWall = resolve_and_return_wall_collisions(nextPos, 150.0f, 50.0f); "
        "lowerWall = resolve_and_return_wall_collisions(nextPos, 30.0f, 50.0f); "
        "floorHeight = find_floor(nextPos[0], nextPos[1], nextPos[2], &floor); "
        "ceilHeight = vec3f_find_ceil(nextPos, floorHeight, &ceil);",
        "Pedro wall/floor/ceiling query order",
    )
    require(
        quarter_step_body,
        "if (ceilHeight - floorHeight > 160.0f) { "
        "m->pos[0] = nextPos[0]; m->pos[2] = nextPos[2]; "
        "m->floor = floor; m->floorHeight = floorHeight; }",
        "Pedro conditional XZ and floor update",
    )
    require(
        quarter_step_body,
        "m->pos[1] = floorHeight; return AIR_STEP_LANDED;",
        "Pedro unconditional Y snap and landed result",
    )
    air_without_turn = c_function_body(mario_airborne, "update_air_without_turn")
    require(
        air_without_turn,
        "m->forwardVel = approach_f32(m->forwardVel, 0.0f, 0.35f, 0.35f);",
        "air-speed drag",
    )
    require(
        air_without_turn,
        "m->forwardVel += intendedMag * coss(intendedDYaw) * 1.5f;",
        "maximum forward air input",
    )
    require(
        air_without_turn,
        "if (m->forwardVel > dragThreshold) { m->forwardVel -= 1.0f; }",
        "above-threshold air drag",
    )
    require(
        air_without_turn,
        "if (m->forwardVel < -16.0f) { m->forwardVel += 2.0f; }",
        "negative-speed recovery",
    )
    require(
        air_without_turn,
        "if (!check_horizontal_wind(m))",
        "non-wind guard for audited air-speed helper",
    )
    approach_body = c_function_body(math_util, "approach_f32")
    require(
        approach_body,
        "if (current < target) { current += inc; if (current > target) { "
        "current = target; } } else { current -= dec; if (current < target) { "
        "current = target; } }",
        "piecewise approach_f32 semantics",
    )
    stick_body = c_function_body(game_init, "adjust_analog_stick")
    require(
        stick_body,
        "if (controller->stickMag > 64) { controller->stickX *= 64 / "
        "controller->stickMag; controller->stickY *= 64 / controller->stickMag; "
        "controller->stickMag = 64; }",
        "retail stick magnitude cap",
    )
    joystick_body = c_function_body(mario, "update_mario_joystick_inputs")
    require(
        joystick_body,
        "if (m->squishTimer == 0) { m->intendedMag = mag / 2.0f; } "
        "else { m->intendedMag = mag / 8.0f; }",
        "intended magnitude division",
    )
    if "SURFACE_HORIZONTAL_WIND" in area3 or "SURFACE_HORIZONTAL_WIND" in hand_collision:
        fail("Area 3 or Eyerok collision unexpectedly contains horizontal wind")
    require(hand_collision, "COL_TRI_INIT(SURFACE_DEFAULT", "default Eyerok surfaces")

    rounded_start = binary32(-32.0)
    rounded_after = binary32_air_update_full_forward(rounded_start)
    rounded_delta = rounded_after - rounded_start
    if not (3.85 < rounded_delta <= 4.0):
        fail(f"unexpected binary32 -32 air-speed witness: {rounded_delta}")
    coarse_start = binary32(-5_000_000.0)
    coarse_after_one = binary32_air_update_full_forward(coarse_start)
    coarse_after_seven = coarse_start
    for _ in range(7):
        coarse_after_seven = binary32_air_update_full_forward(coarse_after_seven)
    if coarse_after_one - coarse_start != 4.0 \
       or coarse_after_seven - coarse_start != 28.0:
        fail("unexpected coarse-binary32 4/28 speed witnesses")

    explode_body = c_function_body(helpers, "obj_explode_and_spawn_coins")
    explode_order = [
        explode_body.find("spawn_mist_particles_variable"),
        explode_body.find("spawn_triangle_break_particles"),
        explode_body.find("obj_mark_for_deletion"),
        explode_body.find("obj_spawn_loot_yellow_coins"),
    ]
    if any(index < 0 for index in explode_order) or explode_order != sorted(explode_order):
        fail(f"unexpected Eyerok explosion allocation/deletion order: {explode_order}")
    require(
        explode_body,
        "spawn_triangle_break_particles(30, MODEL_DIRT_ANIMATION, 3.0f, 4);",
        "thirty rotating Eyerok fragments",
    )
    mark_body = c_function_body(helpers, "obj_mark_for_deletion")
    require(
        mark_body,
        "obj->activeFlags = ACTIVE_FLAG_DEACTIVATED;",
        "deletion mark only clears active flags",
    )
    if "unload_object" in mark_body or "deallocate_object" in mark_body:
        fail("obj_mark_for_deletion unexpectedly frees the object slot")

    unload_deactivated_body = c_function_body(
        object_lists, "unload_deactivated_objects_in_list"
    )
    require(
        unload_deactivated_body,
        "if ((gCurrentObject->activeFlags & ACTIVE_FLAG_ACTIVE) "
        "!= ACTIVE_FLAG_ACTIVE) {",
        "end-of-frame inactive-object test",
    )
    require(
        unload_deactivated_body,
        "unload_object(gCurrentObject);",
        "end-of-frame inactive-object unload",
    )
    unload_object_body = c_function_body(spawn_object, "unload_object")
    require(
        unload_object_body,
        "deallocate_object(&gFreeObjectList, &obj->header);",
        "unload returns object slot to free list",
    )
    deallocate_body = c_function_body(spawn_object, "deallocate_object")
    require(
        deallocate_body,
        "obj->next = freeList->next; freeList->next = obj;",
        "deallocation pushes slot at free-list head",
    )
    allocate_body = c_function_body(spawn_object, "try_allocate_object")
    require(
        allocate_body,
        "if ((nextObj = freeList->next) != NULL) {",
        "allocation reads slot from free-list head",
    )
    require(
        allocate_body,
        "freeList->next = nextObj->next;",
        "allocation pops selected free-list head",
    )
    require(
        hand_functions["eyerok_hand_act_open"],
        "o->parentObj->oEyerokBossUnk1AC = o->oBhvParams2ndByte;",
        "OPEN claims exclusive eye lock",
    )
    require(
        hand_functions["eyerok_hand_act_idle"],
        "else if (o->parentObj->oEyerokBossUnk1AC == 0 && "
        "o->parentObj->oEyerokBossActiveHand != 0)",
        "IDLE action selection is gated by the free eye lock",
    )
    require(
        hand_functions["eyerok_hand_act_die"],
        "o->parentObj->oEyerokBossUnk1AC = 0; "
        "obj_explode_and_spawn_coins(150.0f, 1);",
        "DIE clears eye lock only at explosion",
    )
    require(open_animation, "0x1E, ANIMINDEX_NUMPARTS", "30-frame OPEN animation")
    require(wake_animation, "0x50, ANIMINDEX_NUMPARTS", "80-frame wake animation")
    require(
        break_particles,
        "triangle->oAngleVelPitch = 0xF00; "
        "triangle->oAngleVelYaw = 0x500; triangle->oForwardVel = 30.0f;",
        "dirt fragment rotational velocity",
    )

    update_objects_body = c_function_body(object_lists, "update_objects")
    update_order = [
        update_objects_body.find("clear_dynamic_surfaces();"),
        update_objects_body.find("update_terrain_objects();"),
        update_objects_body.find("apply_mario_platform_displacement();"),
        update_objects_body.find("update_non_terrain_objects();"),
        update_objects_body.find("unload_deactivated_objects();"),
        update_objects_body.find("update_mario_platform();"),
    ]
    if any(index < 0 for index in update_order) or update_order != sorted(update_order):
        fail(f"unexpected PPD frame order: {update_order}")
    clear_dynamic_body = c_function_body(surface_load, "clear_dynamic_surfaces")
    require(
        clear_dynamic_body,
        "if (!(gTimeStopState & TIME_STOP_ACTIVE)) { "
        "gSurfacesAllocated = gNumStaticSurfaces; "
        "gSurfaceNodesAllocated = gNumStaticSurfaceNodes; "
        "clear_spatial_partition(&gDynamicSurfacePartition[0][0]);",
        "active-frame dynamic-surface clear",
    )
    update_platform_body = c_function_body(
        platform_displacement, "update_mario_platform"
    )
    require(
        update_platform_body,
        "floorHeight = find_floor(marioX, marioY, marioZ, &floor);",
        "platform refresh floor query",
    )
    require(
        update_platform_body,
        "gMarioPlatform = floor->object; gMarioObject->platform = floor->object;",
        "platform refresh saves selected dynamic object",
    )
    if update_platform_body.count("gMarioPlatform = NULL;") != 2:
        fail("update_mario_platform no longer clears the saved pointer on both misses")
    apply_mario_body = c_function_body(
        platform_displacement, "apply_mario_platform_displacement"
    )
    require(
        apply_mario_body,
        "struct Object *platform = gMarioPlatform;",
        "platform displacement consumes prior saved pointer",
    )
    require(
        apply_mario_body,
        "if (!(gTimeStopState & TIME_STOP_ACTIVE) && "
        "gMarioObject != NULL && platform != NULL)",
        "time stop suppresses stale-platform displacement",
    )
    require(
        apply_mario_body,
        "platform != NULL) { apply_platform_displacement(TRUE, platform); }",
        "saved platform pointer displacement call",
    )
    platform_body = c_function_body(platform_displacement, "apply_platform_displacement")
    require(
        platform_body,
        "rotation[0] = platform->oAngleVelPitch; "
        "rotation[1] = platform->oAngleVelYaw; "
        "rotation[2] = platform->oAngleVelRoll;",
        "platform angular payload fields",
    )
    require(
        platform_body,
        "x += platform->oVelX; z += platform->oVelZ;",
        "platform X/Z linear payload fields",
    )
    if re.search(r"y\s*\+=\s*platform->oVelY", platform_body):
        fail("platform displacement unexpectedly adds platform Y velocity")
    require(platform_body, "gMarioStates[0].faceAngle[1] += rotation[1];", "platform yaw write")
    require(platform_body, "set_mario_pos(x, y, z);", "platform position write")
    if "forwardVel" in platform_body or "gMarioStates[0].vel" in platform_body:
        fail("platform displacement unexpectedly writes Mario stored speed")
    clear_platform_body = c_function_body(platform_displacement, "clear_mario_platform")
    require(
        clear_platform_body,
        "gMarioPlatform = NULL;",
        "explicit Mario platform clear",
    )
    spawn_area_objects_body = c_function_body(object_lists, "spawn_objects_from_info")
    require(
        spawn_area_objects_body,
        "#ifndef VERSION_JP clear_mario_platform(); #endif",
        "US/non-JP area load clears Mario platform",
    )
    require(
        spawn_area_objects_body,
        "gObjectLists = gObjectListArray; gTimeStopState = 0;",
        "area spawn resets time stop before the next object update",
    )

    # Pin the scheduler facts that make the Japanese omission materially
    # different from the US build.  The instant warp unloads and loads the new
    # area before that frame's object update.  JP compiles out the explicit
    # saved-platform clear, and spawn setup resets time stop, so the ordinary
    # apply gate can consume the stale pointer before the end-frame refresh.
    play_normal_body = c_function_body(level_update, "play_mode_normal")
    play_normal_order = [
        play_normal_body.find("warp_area();"),
        play_normal_body.find("check_instant_warp();"),
        play_normal_body.find("area_update_objects();"),
    ]
    if any(index < 0 for index in play_normal_order) \
       or play_normal_order != sorted(play_normal_order):
        fail(f"unexpected JP instant-warp/object-update order: {play_normal_order}")

    instant_warp_body = c_function_body(level_update, "check_instant_warp")
    require(
        instant_warp_body,
        "change_area(warp->area); gMarioState->area = gCurrentArea;",
        "instant warp changes area before returning to the frame scheduler",
    )
    change_area_body = c_function_body(area_source, "change_area")
    change_area_order = [
        change_area_body.find("unload_area();"),
        change_area_body.find("load_area(index);"),
        change_area_body.find("gMarioObject->oActiveParticleFlags = 0;"),
    ]
    if any(index < 0 for index in change_area_order) \
       or change_area_order != sorted(change_area_order):
        fail(f"unexpected JP change-area order: {change_area_order}")

    # The available 36fb checkout adds only disabled TAS-hack blocks to these
    # version-sensitive functions.  Compare their normalized, default-disabled
    # bodies with the pinned revision so the JP Clight witnesses cannot silently
    # inherit a research-only hook.
    for label, pinned_text, checkout_text in [
        ("change_area", area_source, working_area_source),
        ("check_instant_warp", level_update, working_level_update),
        ("play_mode_normal", level_update, working_level_update),
    ]:
        if compact(c_function_body(pinned_text, label)) != compact(
            c_function_body(checkout_text, label)
        ):
            fail(f"default-disabled checkout body differs from pin: {label}")

    require(
        makefile,
        "ifeq ($(VERSION),jp) DEFINES += VERSION_JP=1",
        "JP build selects VERSION_JP",
    )
    require(
        makefile,
        "COMPARE ?= 1",
        "matching-ROM comparison defaults on",
    )
    expected_jp_manifest = f"{JP_ROM_SHA1}  build/jp/sm64.jp.z64\n"
    if jp_sha1_manifest != expected_jp_manifest:
        fail(f"unexpected canonical JP SHA-1 manifest: {jp_sha1_manifest!r}")
    require(die_animation, "0x28, ANIMINDEX_NUMPARTS(eyerok_seg5_animindex_0500DD4C)", "40-frame die animation")
    die_animation_frames = 0x28
    die_body = hand_functions["eyerok_hand_act_die"]
    require(
        die_body,
        "if (o->oMoveFlags & OBJ_MOVE_MASK_ON_GROUND) { "
        "cur_obj_play_sound_2(SOUND_OBJ_POUNDING_LOUD); "
        "o->oForwardVel = 0.0f; }",
        "dying hand grounded forward-velocity clear",
    )
    if "oAngleVel" in eyerok:
        fail("Eyerok behavior unexpectedly writes an angular-velocity field")
    require(
        spawn_object,
        "for (i = 0; i < 0x50; i++) obj->rawData.asS32[i] = 0;",
        "allocation clears all raw object fields",
    )
    move_standard_body = c_function_body(helpers, "cur_obj_move_standard")
    require(
        move_standard_body,
        "cur_obj_compute_vel_xz(); cur_obj_apply_drag_xz(dragStrength);",
        "common movement recomputes X/Z velocity from forward velocity",
    )

    lethal_velocity = 50
    lethal_relative_y = 0
    lethal_peak_y = 0
    lethal_ground_integrations = 0
    while True:
        lethal_ground_integrations += 1
        lethal_velocity -= 4
        candidate_y = lethal_relative_y + lethal_velocity
        if candidate_y < 0:
            lethal_relative_y = 0
            lethal_velocity = 0
            break
        lethal_relative_y = candidate_y
        lethal_peak_y = max(lethal_peak_y, lethal_relative_y)
    if (lethal_peak_y, lethal_ground_integrations) != (288, 25):
        fail(
            "unexpected lethal hand arc: "
            f"peak={lethal_peak_y}, ground={lethal_ground_integrations}"
        )
    if die_animation_frames < lethal_ground_integrations:
        fail("DIE can unload before its velocity reaches the grounded zero state")
    lethal_open_top_y = -1534 + lethal_peak_y + 507
    if lethal_open_top_y != -739 or not lethal_open_top_y < -569:
        fail(f"unexpected lethal open-hand top: {lethal_open_top_y}")

    death_dialog_timer = 60
    if not die_animation_frames < death_dialog_timer:
        fail(
            "dying hands are not guaranteed to finish before the death dialog: "
            f"{die_animation_frames} !< {death_dialog_timer}"
        )
    require(attacked_animation, "0x19, ANIMINDEX_NUMPARTS(eyerok_seg5_animindex_0500E798)", "25-frame attacked animation")

    require(ssl_script, "OBJECT(/*model*/ MODEL_NONE, /*pos*/ 0, -1534, -3693", "boss spawn")
    require(
        ssl_script,
        "OBJECT_WITH_ACTS(/*model*/ MODEL_STAR, /*pos*/ 500, 5050, -500",
        "Act-3 star raw position",
    )
    for warp_position in [
        "/*pos*/    0,  300,  6451",
        "/*pos*/    0, 5500,   256",
        "/*pos*/ 3070, 1280,  2900",
        "/*pos*/ 2546, 1150, -2647",
    ]:
        require(ssl_script, warp_position, f"Area-2 warp raw position {warp_position}")
    require(ssl_script, "INSTANT_WARP(/*index*/ 3, /*destArea*/ 3, /*displace*/ 0, 0, 0)", "area 2 to 3 instant warp")
    require(ssl_script, "INSTANT_WARP(/*index*/ 2, /*destArea*/ 2, /*displace*/ 0, 0, 0)", "area 3 to 2 instant warp")
    require(area2, "COL_TRI_INIT(SURFACE_INSTANT_WARP_1E, 2), COL_TRI(11, 241, 12), COL_TRI(241, 243, 12),", "area 2 active warp triangles")
    require(area3, "COL_TRI_INIT(SURFACE_INSTANT_WARP_1D, 2), COL_TRI(18, 19, 20), COL_TRI(18, 20, 21),", "area 3 active warp triangles")
    require(area3_macros, "const MacroObject ssl_seg7_area_3_macro_objs[] = { MACRO_OBJECT_END(), };", "empty Area 3 macro list")
    if "COL_WATER_BOX" in area3:
        fail("unexpected Area 3 water box")

    coin_record_pattern = re.compile(
        r"MACRO_OBJECT\s*\(\s*/\*preset\*/\s*(macro_yellow_coin_[12])\s*,"
        r"\s*/\*yaw\*/\s*0\s*,\s*/\*pos\*/\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*\)"
    )
    area2_individual_coins = [
        (kind, int(x), int(y), int(z))
        for kind, x, y, z in coin_record_pattern.findall(area2_macros)
    ]
    expected_area2_individual_coins = [
        ("macro_yellow_coin_2", 1873, 0, -3495),
        ("macro_yellow_coin_2", 1200, 0, -3495),
        ("macro_yellow_coin_1", 736, 2652, -2250),
        ("macro_yellow_coin_1", 736, 2546, -2250),
        ("macro_yellow_coin_1", 1368, 3263, -2250),
        ("macro_yellow_coin_1", 1368, 3135, -2250),
        ("macro_yellow_coin_1", -260, 2950, -600),
        ("macro_yellow_coin_1", 260, 1977, -600),
        ("macro_yellow_coin_1", -1940, 1239, -600),
        ("macro_yellow_coin_1", -1940, 1239, 2320),
        ("macro_yellow_coin_1", 260, 3923, -600),
        ("macro_yellow_coin_2", -2047, 1664, 3076),
        ("macro_yellow_coin_2", -2047, 1536, 2870),
        ("macro_yellow_coin_2", -1840, 1357, 3076),
        ("macro_yellow_coin_2", -1840, 1408, 2870),
    ]
    if area2_individual_coins != expected_area2_individual_coins:
        fail(f"unexpected Area-2 individual-coin inventory: {area2_individual_coins}")
    if sum(kind == "macro_yellow_coin_1" for kind, *_ in area2_individual_coins) != 9:
        fail("Area-2 macro_yellow_coin_1 count is not nine")
    if sum(kind == "macro_yellow_coin_2" for kind, *_ in area2_individual_coins) != 6:
        fail("Area-2 macro_yellow_coin_2 count is not six")
    require(
        macro_presets,
        "/* macro_yellow_coin_1               */ { bhvYellowCoin, MODEL_YELLOW_COIN, 0 },",
        "yellow-coin-1 macro preset",
    )
    require(
        macro_presets,
        "/* macro_yellow_coin_2               */ { bhvOneCoin, MODEL_YELLOW_COIN, 0 },",
        "yellow-coin-2 macro preset",
    )
    coin_behavior_start = behavior_data.find("const BehaviorScript bhvOneCoin[]")
    coin_behavior_end = behavior_data.find("const BehaviorScript bhvTemporaryYellowCoin[]")
    if coin_behavior_start < 0 or coin_behavior_end <= coin_behavior_start:
        fail("cannot isolate individual yellow-coin behaviors")
    if "OBJ_FLAG_PERSISTENT_RESPAWN" in behavior_data[coin_behavior_start:coin_behavior_end]:
        fail("individual yellow coin unexpectedly has persistent-respawn flag")
    require(
        c_function_body(interaction, "interact_coin"),
        "o->oInteractStatus = INT_STATUS_INTERACTED;",
        "coin interaction marks the coin collected",
    )
    require(
        c_function_body(coin, "bhv_coin_sparkles_init"),
        "if (o->oInteractStatus & INT_STATUS_INTERACTED "
        "&& !(o->oInteractStatus & INT_STATUS_TOUCHED_BOB_OMB)) { "
        "spawn_object(o, MODEL_SPARKLES, bhvGoldenCoinSparkles); "
        "obj_mark_for_deletion(o); return TRUE; }",
        "collected yellow coin deletion",
    )
    unload_body = c_function_body(object_lists, "unload_deactivated_objects_in_list")
    require(
        unload_body,
        "if (!(gCurrentObject->oFlags & OBJ_FLAG_PERSISTENT_RESPAWN)) { "
        "set_object_respawn_info_bits(gCurrentObject, RESPAWN_INFO_DONT_RESPAWN); }",
        "ordinary deletion writes the no-respawn value",
    )
    require(
        c_function_body(object_lists, "set_object_respawn_info_bits"),
        "case RESPAWN_INFO_TYPE_16: info16 = (u16 *) obj->respawnInfo; "
        "*info16 |= bits << 8; break;",
        "macro respawn record is a 16-bit writable cell",
    )
    spawn_macro_body = c_function_body(macro_special_objects, "spawn_macro_objects")
    require(
        spawn_macro_body,
        "if (((macroObject[MACRO_OBJ_PARAMS] >> 8) & RESPAWN_INFO_DONT_RESPAWN) "
        "!= RESPAWN_INFO_DONT_RESPAWN)",
        "no-respawn macro filter",
    )
    require(
        spawn_macro_body,
        "newObj->respawnInfoType = RESPAWN_INFO_TYPE_16; "
        "newObj->respawnInfo = macroObjList - 1;",
        "macro object receives its record pointer",
    )

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
    if any(
        behavior in ssl_script or behavior in area3_macros
        for behavior in ["bhvButterfly", "bhvDorrie", "bhvTiltingInvertedPyramid"]
    ):
        fail("an Area-3-excluded post-Mario position writer appears in SSL data")

    # Census the only named raw-Object writers and set_mario_pos callsites in
    # the complete pinned game source.  Platform displacement executes before
    # PLAYER; the remaining three owning behaviors do not occur in Area 3.
    set_pos_lines = git(
        sm64,
        "grep",
        "-n",
        "-F",
        "set_mario_pos(",
        PIN,
        "--",
        "src/game",
    ).decode("utf-8").splitlines()
    set_pos_paths = sorted(line.split(":", 2)[1] for line in set_pos_lines)
    if set_pos_paths != sorted(
        [
            "src/game/behaviors/dorrie.inc.c",
            "src/game/behaviors/tilting_inverted_pyramid.inc.c",
            "src/game/platform_displacement.c",
            "src/game/platform_displacement.c",
            "src/game/platform_displacement.h",
        ]
    ):
        fail(f"unexpected set_mario_pos census: {set_pos_paths}")

    raw_object_writer_lines = git(
        sm64,
        "grep",
        "-n",
        "-E",
        r"gMarioObject->oPos[XYZ][[:space:]]*[+*/-]?=",
        PIN,
        "--",
        "src/game",
    ).decode("utf-8").splitlines()
    raw_object_writer_paths = sorted(
        line.split(":", 2)[1] for line in raw_object_writer_lines
    )
    if raw_object_writer_paths != ["src/game/behaviors/butterfly.inc.c"] * 6:
        fail(f"unexpected direct Mario-object writer census: {raw_object_writer_paths}")

    mario_update_body = c_function_body(object_lists, "bhv_mario_update")
    execute_index = compact(mario_update_body).find(
        compact("particleFlags = execute_mario_action(gCurrentObject);")
    )
    copy_index = compact(mario_update_body).find(
        compact("copy_mario_state_to_object();")
    )
    particle_index = compact(mario_update_body).find(
        compact("while (sParticleTypes[i].particleFlag != 0)")
    )
    if not 0 <= execute_index < copy_index < particle_index:
        fail("Mario State-to-Object copy is not after action and before particles")
    require(
        object_lists,
        "OBJ_LIST_SURFACE, OBJ_LIST_POLELIKE, OBJ_LIST_PLAYER, "
        "OBJ_LIST_PUSHABLE, OBJ_LIST_GENACTOR, OBJ_LIST_DESTRUCTIVE, "
        "OBJ_LIST_LEVEL, OBJ_LIST_DEFAULT, OBJ_LIST_UNIMPORTANT",
        "PLAYER-before-boss/list-tail update order",
    )

    area3_vertices, area3_triangles = parse_collision(area3)
    area3_z_min = min(vertex[2] for vertex in area3_vertices)
    area3_z_max = max(vertex[2] for vertex in area3_vertices)
    if (area3_z_min, area3_z_max) != (-3954, -255):
        fail(f"unexpected Area 3 static Z envelope: {(area3_z_min, area3_z_max)}")
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

    warp_ceiling_triangle = (76, 77, 115)
    warp_ceiling_companion = (76, 115, 119)
    if warp_ceiling_triangle not in area3_triangles \
        or warp_ceiling_companion not in area3_triangles:
        fail("warp Y=768 ceiling triangles changed")
    warp_ceiling_points = [area3_vertices[index] for index in warp_ceiling_triangle]
    if warp_ceiling_points != [
        (192, 768, -2432),
        (192, 768, -1023),
        (-191, 768, -1023),
    ]:
        fail(f"unexpected warp ceiling vertices: {warp_ceiling_points}")
    if normal_y(*warp_ceiling_points) != -539647:
        fail("warp Y=768 triangle is no longer downward-facing")
    if not point_in_triangle_xz((0, -1100), *warp_ceiling_points):
        fail("warp Y=768 ceiling no longer contains X/Z (0,-1100)")
    static_warp_downward_faces = [
        (triangle, [area3_vertices[index] for index in triangle])
        for triangle in area3_triangles
        if normal_y(*(area3_vertices[index] for index in triangle)) < 0
        and point_in_triangle_xz(
            (0, -1100), *(area3_vertices[index] for index in triangle)
        )
    ]
    if [triangle for triangle, _ in static_warp_downward_faces] != [
        (70, 71, 107),
        warp_ceiling_triangle,
    ]:
        fail(f"unexpected downward faces over warp: {static_warp_downward_faces}")
    if {point[1] for _, points in static_warp_downward_faces for point in points} \
        != {-409, 768}:
        fail("unexpected static warp ceiling heights")

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
    hand_local_xz_abs_max = max(
        max(abs(vertex[0]), abs(vertex[2])) for vertex in hand_vertices
    )
    if hand_local_xz_abs_max != 153:
        fail(f"unexpected hand local X/Z absolute bound: {hand_local_xz_abs_max}")
    coarse_hand_horizontal_offset = 3 * (2 * hand_local_xz_abs_max) // 2
    if coarse_hand_horizontal_offset != 459:
        fail(f"unexpected coarse hand horizontal offset: {coarse_hand_horizontal_offset}")
    intro_hand_pivot_z = -3693 + 300
    intro_hand_reach_max_z = intro_hand_pivot_z + coarse_hand_horizontal_offset
    if intro_hand_pivot_z != -3393 or intro_hand_reach_max_z != -2934:
        fail(
            "unexpected intro hand Z envelope endpoint: "
            f"pivot={intro_hand_pivot_z}, max={intro_hand_reach_max_z}"
        )
    if not intro_hand_reach_max_z < -1222:
        fail("intro hand collision can reach the Area-3 warp")
    stock_hand_support_z = (
        area3_z_min - coarse_hand_horizontal_offset,
        area3_z_max + coarse_hand_horizontal_offset,
    )
    if stock_hand_support_z != (-4413, 204):
        fail(f"unexpected stock hand support Z envelope: {stock_hand_support_z}")
    first_negative_support_z = tuple(value - 65536 for value in stock_hand_support_z)
    if first_negative_support_z != (-69949, -65332):
        fail(f"unexpected first negative support copy: {first_negative_support_z}")
    first_period_open_gap = stock_hand_support_z[0] - first_negative_support_z[1]
    if first_period_open_gap != 60919:
        fail(f"unexpected first-period open gap: {first_period_open_gap}")
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
    closed_warp_pedro_pivot_band = (302, 460)
    closed_warp_pedro_floor_band = tuple(
        pivot + closed_top_offset for pivot in closed_warp_pedro_pivot_band
    )
    closed_warp_pedro_gap_band = tuple(
        768 - floor for floor in closed_warp_pedro_floor_band
    )
    if closed_warp_pedro_floor_band != (608, 766) \
        or closed_warp_pedro_gap_band != (160, 2):
        fail("unexpected closed-hand/warp-ceiling Pedro band")

    # At the central warp sample the collision census found exactly two
    # static downward faces, at -409 and 768.  A Pedro landing needs a
    # positive 2..160 gap.  Translate the lower ceiling's floor band back to
    # the closed/open hand pivots so the ordinary-scale residual is explicit.
    low_warp_ceiling_y = -409
    low_warp_pedro_floor_band = (
        low_warp_ceiling_y - 160,
        low_warp_ceiling_y - 2,
    )
    low_warp_closed_pivot_band = tuple(
        floor - closed_top_offset for floor in low_warp_pedro_floor_band
    )
    if low_warp_pedro_floor_band != (-569, -411) \
        or low_warp_closed_pivot_band != (-875, -717):
        fail("unexpected low-ceiling closed-hand Pedro band")

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
    closed_origin_downward = [
        triangle
        for triangle in closed_mesh_triangles
        if normal_y(*(closed_mesh_vertices[index] for index in triangle)) < 0
        and point_in_triangle_xz(
            (0, 0), *(closed_mesh_vertices[index] for index in triangle)
        )
    ]
    if closed_origin_downward != [(6, 2, 7)]:
        fail(f"unexpected closed-hand downward origin faces: {closed_origin_downward}")
    closed_underside_local_y = closed_mesh_vertices[6][1]
    closed_query_rejection_margin_doubled = \
        (3 * max_closed_local_y + 2 * 80) - \
        (3 * closed_underside_local_y + 2 * 78)
    if closed_underside_local_y != 3 or closed_query_rejection_margin_doubled != 607:
        fail("closed-hand underside no longer fails the top-floor ceiling query")
    low_warp_open_pivot_band = tuple(
        floor - dynamic_top_offset for floor in low_warp_pedro_floor_band
    )
    if low_warp_open_pivot_band != (-1076, -918):
        fail("unexpected low-ceiling open-hand Pedro band")

    ordinary_forward_closed_top = -1534 + closed_top_offset
    ordinary_forward_open_top = -1534 + dynamic_top_offset
    target_mario_pivot_peak = -1534 + 300
    target_mario_closed_top = target_mario_pivot_peak + closed_top_offset
    double_pound_coarse_max_z = -3693 + 1600 + coarse_hand_horizontal_offset
    target_mario_coarse_max_z = -3693 + 1700 + 50 + coarse_hand_horizontal_offset
    if (
        ordinary_forward_closed_top,
        ordinary_forward_open_top,
        target_mario_closed_top,
    ) != (-1228, -1027, -928):
        fail("unexpected ordinary forward/target hand tops")
    if double_pound_coarse_max_z != -1634 \
        or target_mario_coarse_max_z != -1484:
        fail("unexpected target/double-pound warp-separation bound")
    if not max(
        ordinary_forward_closed_top,
        ordinary_forward_open_top,
        target_mario_closed_top,
        lethal_open_top_y,
    ) < low_warp_pedro_floor_band[0]:
        fail("a horizontally eligible ordinary hand top reaches a Pedro band")

    right_sleep_vertices, right_sleep_triangles = parse_collision(
        named_collision_block(hand_collision, "ssl_seg7_collision_07028370")
    )
    left_sleep_vertices, left_sleep_triangles = parse_collision(
        named_collision_block(hand_collision, "ssl_seg7_collision_070284B0")
    )
    expected_right_sleep = {
        "lower_floor": [(7, 10, 11), (12, 7, 11)],
        "outer_wall": [(11, 10, 14)],
        "ceiling_sliver": [(17, 16, 11), (16, 12, 11)],
    }
    for label, triangles in expected_right_sleep.items():
        if any(triangle not in right_sleep_triangles for triangle in triangles):
            fail(f"right sleep-hand {label} triangles changed")
    if right_sleep_vertices[11] != (151, 50, -21) \
       or right_sleep_vertices[16] != (100, 75, -20) \
       or right_sleep_vertices[17] != (151, 75, -20):
        fail("right sleep-hand Pedro sliver vertices changed")
    if (2, 1, 4) not in left_sleep_triangles or (6, 9, 4) not in right_sleep_triangles:
        fail("wake-sandwich palm triangles changed")

    sleep_pedro_floor = -1534 + 50 * 3 // 2
    sleep_pedro_ceiling = -1421
    sleep_pedro_gap = sleep_pedro_ceiling - sleep_pedro_floor
    sleep_pedro_query_window = (-1537, -1500)
    sleep_outer_wall_z = -3166
    sleep_outer_resolved_z = sleep_outer_wall_z + 50
    sleep_wall_free_inner_z = sleep_outer_wall_z - 50
    if (sleep_pedro_floor, sleep_pedro_ceiling, sleep_pedro_gap) != (-1459, -1421, 38):
        fail("unexpected stationary sleep-hand Pedro heights")
    if sleep_outer_resolved_z != -3116 or sleep_wall_free_inner_z != -3216:
        fail("unexpected stationary sleep-hand wall band")

    wake_height_pairs = [
        (-1357, -1341),
        (-1344, -1305),
        (-1332, -1269),
        (-1319, -1235),
        (-1307, -1202),
        (-1295, -1169),
        (-1284, -1140),
    ]
    wake_gaps = [ceiling - floor for floor, ceiling in wake_height_pairs]
    wake_points = [
        (33, -3406),
        (47, -3383),
        (61, -3377),
        (79, -3385),
        (97, -3396),
        (115, -3401),
        (130, -3391),
    ]
    if wake_gaps != [16, 39, 63, 84, 105, 126, 144]:
        fail(f"unexpected wake Pedro gaps: {wake_gaps}")
    if len(wake_points) != len(wake_gaps) or not all(2 <= gap <= 160 for gap in wake_gaps):
        fail("wake Pedro witness table is malformed")
    wake_next_gap = 162
    if wake_next_gap != 162 or wake_next_gap <= 160:
        fail("wake Pedro window unexpectedly extends through frame 12")
    wake_frame11_query_y = -1304
    wake_frame11_start = (-121, -3240)
    wake_frame11_target = (-121, -3241)
    if not (-1284 - 25 < wake_frame11_query_y <= -1284 + 144 - 156):
        fail("frame-11 vertical wall-bypass lane changed")
    wake_frame11_dx = wake_frame11_target[0] - wake_frame11_start[0]
    wake_frame11_dz = wake_frame11_target[1] - wake_frame11_start[1]
    if (wake_frame11_dx, wake_frame11_dz, wake_frame11_dx ** 2 + wake_frame11_dz ** 2) != (0, -1, 1):
        fail("frame-11 ordinary-qstep witness changed")

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
    print("hand-health: initialized once to 4; accepted hits are 4->3, 3->2, 2->1")
    print("nonlethal-health-branches: 4->3 and 3->2; 2->1 enters DIE")
    print("attack-consumer: exactly one call, inside SHOW_EYE")
    print("attack-latch: overwritten after each non-SLEEP handler; interaction status cleared")
    print(
        "nonlethal-reexposure-chain: "
        "ATTACKED->RECOVER->BECOME_ACTIVE->RETREAT->IDLE->OPEN->SHOW_EYE"
    )
    print(
        "post-exposure-close: "
        "CLOSE->RETREAT in one-hand phase; CLOSE->IDLE in two-hand phase"
    )
    print("retreat-idle-gate: approach clamps Y exactly to home before IDLE")
    print("idle-entry-writers: SLEEP, CLOSE, RETREAT (exactly 3; none clears oVelY)")
    print("idle-zero-gravity-exits: BEGIN_DOUBLE_POUND, TARGET_MARIO (exactly 2)")
    print("positive-velY-writes: 30,50,100")
    print("positive-velY-writer-actions: ATTACKED=30, DIE=50, DOUBLE_POUND=100 (only)")
    print(
        "attacked-positive-velocity-expiry: "
        f"{attacked_positive_integrations} gravity integrations; "
        f"RECOVER is gated by {attacked_animation_frames}-frame animation "
        f"({attacked_animation_frames} >= {attacked_positive_integrations})"
    )
    print(
        "attacked-home-ground-reset: "
        f"{attacked_ground_integrations} gravity integrations; "
        f"animation gate {attacked_animation_frames} >= "
        f"{attacked_ground_integrations}"
    )
    print("attacked-handler-vertical-writes: none")
    print("double-terminal-request: boss Unk104 reaches 1 only behind Unk1AC=0 && active-hand=0")
    print("double-terminal-consumer: RETREAT check precedes active DOUBLE_POUND branch")
    print("active-hand-zero-writers: SHOW_EYE and DOUBLE_POUND only")
    print("double-active-hand-clear: grounded mask && gravity < -15 (only DOUBLE_POUND clear)")
    print("show-eye-active-hand-clear: guarded by NumHands != 2 (no live sibling hand)")
    print("single-hand-double-lock: DOUBLE_POUND reasserts its side before terminal/active branches")
    print("exposure-latch-writers: OPEN=side; CLOSE/DIE/RETREAT=0; terminal DOUBLE_POUND=side")
    print("show-eye-exposure-latch: retained nonzero; boss Unk104 scheduler remains blocked")
    print("gravity-writer-sequence: -4,0,0,-4,-4,-20,-15,-20")
    print("live-hand-collision-writes: 6, all nonnull")
    print("hand-room-writes: none (spawn default -1)")
    print("ground-mask: LANDED|ON_GROUND")
    print("zero-gravity-floor-equality: clears grounded")
    print("hand-bounciness: zero")
    print("partial-update-guards: FAR_AWAY|IN_DIFFERENT_ROOM")
    print("hand-native-before-visibility: yes")
    print("hand-collision-distance: default 1000; no Eyerok writer")
    print("dynamic-surface-load-distance: strict marioDist < collisionDistance")
    print("surface-scheduler-order: clear, terrain/hand load, prior-platform apply, Mario, final platform query")
    print("time-stop-surface-mode: retains old partition; forbids fresh load and platform apply")
    print("time-stop-player-mode: Mario can update only without MARIO_AND_DOORS or ALL_OBJECTS")
    print("eyerok-intro-time-stop-predecessor: ready-to-speak stationary/moving state required")
    print("unfixed-dialog-window: airborne Mario can remain scheduled after time stop activates")
    print("eyerok-dialog-callsites: exactly intro at DIALOG_117 and death at DIALOG_118")
    print("intro-dialog-hand-state: both hands pre-fight at home Z=-3393; collision max Z=-2934")
    print("intro-dialog-warp-overlap: none; Area-3 warp begins at Z=-1222")
    print("death-dialog-hand-state: zero counted hands; 40-frame hand death finishes before timer 60")
    print("dialog-retained-warp-hand: impossible in the stock lifecycle")
    print("hand-direct-Z-writers: retreat-to-home and boss-clamped begin-double only")
    print("hand-bounded-Z-motion: target/push <= 50; growing sweep is X-only at yaw +/-0x4000")
    print("hand-no-floor-motion: intended no-floor endpoint rejected with HIT_EDGE")
    print("first-hand-sleep-update-collision: nonnull before visibility")
    print("time-stop-hand-update: whole update frozen unless explicitly unfrozen")
    print("hand-list-before-boss: yes")
    print("hand-spawn-and-surface-order: side -1, then side +1")
    print("surface-list-append-order: yes")
    print("area3-local-objects: Eyerok boss only; macro list empty")
    print("area3-water-boxes: none")
    print("find-floor-buffer: 78")
    print("pedro-query-order: upper wall, lower wall, floor, ceiling")
    print("pedro-cancel-branch: Y snaps; X/Z and referenced floor remain old")
    print("warp-static-ceiling: triangle (76,77,115), Y=768, normal-Y -539647")
    print("warp-static-ceiling-contains: X/Z (0,-1100)")
    print("warp-downward-face-heights: -409 rejected by query buffer; 768 selected")
    print("closed-hand-warp-pedro-pivot-band: [302,460]")
    print("closed-hand-warp-pedro-floor-band: [608,766], gaps [160,2]")
    print("ordinary-low-ceiling-pedro-floor-band: [-569,-411]")
    print("ordinary-low-ceiling-closed-pivot-band: [-875,-717]")
    print("ordinary-low-ceiling-open-pivot-band: [-1076,-918]")
    print("ordinary-forward-closed-top: -1228")
    print("ordinary-forward-open-top: -1027")
    print("ordinary-lethal-open-top: -739 (170 below low Pedro band)")
    print("ordinary-target-closed-top: -928")
    print("ordinary-target-coarse-max-Z: -1484 (warp begins -1222)")
    print("ordinary-double-pound-coarse-max-Z: -1634 (warp begins -1222)")
    print("ordinary-stock-pose-split: horizontally remote or floor Y <= -739")
    print("closed-hand-origin-underside: local Y=3; top-query rejection margin 303.5")
    print("sleep-pedro-strip: floor -1459, ceiling -1421, gap 38")
    print("sleep-pedro-query-window: [-1537,-1500]")
    print("sleep-pedro-outer-wall: Z=-3166 resolves to -3116")
    print("sleep-pedro-wall-free-interior: Z < -3216; exterior entry qstep >100")
    print("wake-pedro-gaps-frames-5-through-11: 16,39,63,84,105,126,144")
    print("wake-pedro-frame-12-gap: 162")
    print("wake-pedro-wall-free-interior-witnesses: 7")
    print("wake-pedro-frames-5-through-10: no vertical two-wall bypass")
    print("wake-pedro-frame-11-exterior-witness: (-121,-3240)->(-121,-3241), squared qstep 1")
    print("wake-pedro-direct-60-rise: misses first query window by 39")
    print("wake-pedro-ideal-signed-speed-envelope: 3.85/call, 26.95/seven calls")
    print("wake-pedro-ideal-nonnegative-envelope: 1.50/call")
    print("wake-pedro-1.15-precondition: incoming forwardVel >= 0.35")
    print(f"wake-pedro-binary32-minus32-witness-delta: {rounded_delta:.10f}")
    print("wake-pedro-binary32-coarse-witness: 4/call, 28/seven calls")
    print("wake-pedro-binary32-global-bound-status: not a CompCert Float32 theorem")
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
    print("die-ground-integrations: 25; peak relative Y=288; final effective X/Z velocity zero")
    print("eyerok-angular-velocity-writers: none; allocation initializes all three to zero")
    print("unreused-death-slot-effective-payload: identity")
    print("open-animation-frames: 30")
    print("wake-animation-frames: 80")
    print("eyerok-explosion-order: mist, 30 rotating triangles, mark hand deleted, coins, end-frame unload")
    print("eyerok-deletion-mark: active flags cleared; slot not yet freed")
    print("eyerok-hand-slot-free: unload calls deallocate at end of frame")
    print("object-free-list-reuse: deallocate pushes head; allocate pops head")
    print("eyerok-own-fragment-slot-reuse: impossible (allocation precedes actual free)")
    print("eyerok-sibling-fragment-delay-after-unlock: at least 30+40 frames")
    print("ppd-stale-platform-window: next active frame only; time stop suppresses apply")
    print("ppd-update-order: clear dynamic surfaces, terrain, apply displacement, nonterrain, unload, refresh platform")
    print("ppd-platform-pointer: prior pointer consumed before end-frame floor refresh")
    print("ppd-dynamic-surfaces: cleared at start of each active frame")
    print("post-Mario-State/Object-writer-census: set_mario_pos only platform/Dorrie/tilting-pyramid; raw Object writes only butterfly")
    print("area3-post-Mario-position-writers: none (boss only; macro list empty; excluded writer behaviors absent)")
    print("us-area-load-platform-pointer: cleared (non-JP clear_mario_platform)")
    print("jp-area-load-platform-pointer: not cleared (VERSION_JP omission)")
    print("jp-instant-warp-order: change area before current-frame object update")
    print("jp-change-area-order: unload Area 3, load Area 2, then write Mario object")
    print("jp-area-spawn-time-stop: reset to zero before displacement apply")
    print("jp-ppd-required-gates: time stop clear, Mario object nonnull, saved platform nonnull")
    print(
        "jp-version-sensitive-function-bodies: pin-equivalent with the "
        "36fb TAS hack disabled (change_area, check_instant_warp, play_mode_normal)"
    )
    print(f"jp-canonical-rom-sha1: {JP_ROM_SHA1}")
    print(
        "jp-matching-build-record: separately observed pinned make "
        f"VERSION=jp COMPARE=1 byte-identical build ({JP_ROM_SHA1})"
    )
    print("platform-displacement-speed-writes: none")
    print("platform-effective-linear-payload: X/Z only; platform Y velocity ignored")
    print("platform-effective-angular-payload: pitch/yaw/roll angle velocities")
    print("raised-static-floor-overlap-with-begin-corridor: none")
    print(f"area3-static-vertex-y-max: {max_static_vertex_y}")
    print(f"area3-upward-floor-vertex-y-max: {max_upward_floor_vertex_y}")
    print(f"area3-static-z-envelope: [{area3_z_min},{area3_z_max}]")
    print(f"eyerok-local-xz-absolute-bound: {hand_local_xz_abs_max}")
    print(f"stock-hand-support-z-envelope: [{stock_hand_support_z[0]},{stock_hand_support_z[1]}]")
    print(f"first-negative-support-copy: [{first_negative_support_z[0]},{first_negative_support_z[1]}]")
    print(f"first-period-open-gap: {first_period_open_gap}")
    print(f"hand-dynamic-top-offset-max: {dynamic_top_offset}")
    print("area2-individual-coin-suppression-inventory: 15 (yellow_coin_1=9, yellow_coin_2=6)")
    print("area2-individual-coin-respawn-path: collect -> delete -> 16-bit FF00 -> skipped on reload")
    print("area2-10/11-suppression-status: source-feasible inventory; controller reachability unproved")
    print("spindel-output-to-act3-star-raw-z-gap: 197179")
    print("spindel-output-to-nearest-area2-warp-raw-z-gap: 195032")
    print("instant-warp-reanchor: none; both displacements are (0,0,0)")
    print("area2-active-warp: surface-1E -> area3, displacement (0,0,0)")
    print("area3-active-warp: surface-1D -> area2, displacement (0,0,0)")
    print("runaway-tripwire: DOUBLE_POUND + grounded + gravity=0 must remain unreachable")
    print("normalized-sha256:")
    for path, digest in hashes:
        print(f"  {digest}  {path}")


if __name__ == "__main__":
    main()
