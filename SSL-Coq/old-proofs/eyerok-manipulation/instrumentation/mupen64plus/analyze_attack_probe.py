#!/usr/bin/env python3
"""Validate authenticated-US-ROM Eyerok attack/reboarding microtraces."""

from __future__ import annotations

import csv
import math
import pathlib
import re
import sys


EXPECTED_MD5 = "20B854B239203BAF6C961B850A4A51A2"
EXPECTED_CRC = "635A2BFF 8B022326"
SCENARIOS = (
    "nonlethal_long_jump5",
    "lethal_long_jump5",
    "nonlethal_slide_kick5",
    "lethal_slide_kick5",
)
SWEEP = (
    ("x_plus", 127, 0, 0, 127, 0),
    ("x_minus", -127, 0, 0, -127, 0),
    ("y_plus", 0, 127, 0, 0, 127),
    ("y_minus", 0, -127, 0, 0, -127),
    ("xy_plus_plus", 90, 90, 0, 90, 90),
    ("xy_plus_minus", 90, -90, 0, 90, -90),
    ("xy_minus_plus", -90, 90, 0, -90, 90),
    ("xy_minus_minus", -90, -90, 0, -90, -90),
    ("brake32", 0, 127, 32, 0, -127),
)
ACT_LONG_JUMP = 0x03000888
ACT_SLIDE_KICK = 0x018008AA
ACT_BACKWARD_AIR_KB = 0x010208B0
ACT_LEDGE_GRAB = 0x0800034B
TRACE_COLUMNS = (
    "scenario", "event", "poll", "timer", "mAction", "mActionTimer",
    "mX", "mY", "mZ", "mVelY", "mForwardVel", "mWall",
    "mFloorObject", "mFloorHeight", "mPlatform", "mInput",
    "mSquishTimer", "mQuicksandDepth", "hand",
    "action", "actionTimer", "health", "received", "interactStatus",
    "posX", "posY", "posZ", "faceYaw", "velY", "gravity", "moveFlags",
    "collision", "activeFlags", "groundCollision", "mesh", "handTopY",
    "postFrameMarioAboveHandTop", "handTopAtOrBelowPostFrameMario",
    "preQueryFloorMinusMario", "preQueryFloorWithin78AboveMario",
    "localXWorld", "localZWorld",
    "localXMesh", "localZMesh", "insideOpenTopXZ", "sameHandFloor",
    "sameHandPlatform",
)
SWEEP_COLUMNS = (
    "steerLabel", "stickX", "stickY", "switchRelativePoll",
    "afterStickX", "afterStickY", "event", "targetPresent",
    "candidateGap", "poll", "timer",
    "mAction", "mY", "mVelY", "mFloorObject", "mFloorHeight", "mPlatform",
    "handAction", "handActionTimer", "handVelY", "handGravity",
    "groundCollision", "handTopY", "postFrameMarioAboveHandTop",
    "preQueryFloorMinusMario", "localXWorld", "localZWorld", "localXMesh",
    "localZMesh", "insideOpenTopXZ", "sameHandFloor", "sameHandPlatform",
)


def fail(message: str) -> None:
    raise SystemExit(message)


def f(row: dict[str, str], key: str) -> float:
    return float(row[key])


def i(row: dict[str, str], key: str, base: int = 10) -> int:
    return int(row[key], base)


def near(actual: float, expected: float, tolerance: float = 0.01) -> bool:
    return abs(actual - expected) <= tolerance


def one(rows: list[dict[str, str]], predicate, message: str) -> dict[str, str]:
    for row in rows:
        if predicate(row):
            return row
    fail(message)
    raise AssertionError("unreachable")


def parse(
    path: pathlib.Path,
    scenario: str,
    steering: tuple[str, int, int, int, int, int] = ("none", 0, 0, 0, 0, 0),
) -> tuple[str, str, list[dict[str, str]], list[dict[str, str]]]:
    text = path.read_text(encoding="utf-8", errors="replace")
    steer_label, steer_x, steer_y, switch_poll, after_x, after_y = steering
    required = [
        f"Core: MD5: {EXPECTED_MD5}",
        f"Core: CRC: {EXPECTED_CRC}",
        f"ATTACK_SCENARIO,{scenario}",
        f"STEERING,{steer_label},{steer_x},{steer_y},after_first_wall_frame",
        "SETUP boss WAKE_UP; hand state untouched",
        "SETUP FIGHT scheduler target=",
        "no target hand action/physics/collision writes",
        f"ATTACK_POSE scenario={scenario}",
        "A=up B=up",
        "squishTimer=0 quicksandDepth=0.000",
    ]
    if switch_poll > 0:
        required.append(
            f"STEERING_SWITCH,{switch_poll},{after_x},{after_y},relative_to_pose_poll"
        )
    for fragment in required:
        if fragment not in text:
            fail(f"{scenario}: missing required evidence: {fragment}")
    if "FALLBACK_LATCH" in text.upper():
        fail(f"{scenario}: fallback injection is forbidden")
    if scenario in ("lethal_long_jump5", "lethal_slide_kick5"):
        if "FIXTURE target health=2 (two prior hits only)" not in text:
            fail(f"{scenario}: disclosed health fixture missing")
    elif "FIXTURE target health=2" in text:
        fail(f"{scenario}: unexpected lethal-health fixture")

    match = re.search(r"ATTACK_POSE .*?hand=([0-9a-fA-F]{8})", text)
    if match is None:
        fail(f"{scenario}: target hand not identified")
    hand = match.group(1).lower()

    lines = text.splitlines()
    header_line = next((line for line in lines if line.startswith("CSV,poll,")), None)
    if header_line is None:
        fail(f"{scenario}: CSV header absent")
    fields = next(csv.reader([header_line]))
    all_rows: list[dict[str, str]] = []
    for line in lines:
        if not line.startswith("CSV,") or line == header_line:
            continue
        values = next(csv.reader([line]))
        if len(values) != len(fields):
            fail(f"{scenario}: malformed CSV row")
        row = dict(zip(fields, values))
        if row["scenario"] != scenario:
            fail(f"{scenario}: row labeled {row['scenario']}")
        all_rows.append(row)
    target_rows = [row for row in all_rows if row["hand"].lower() == hand]
    if not target_rows:
        fail(f"{scenario}: no rows for target hand {hand}")
    return text, hand, target_rows, all_rows


def triangle_contains(
    point: tuple[float, float], vertices: tuple[tuple[float, float], ...]
) -> bool:
    px, pz = point
    signs: list[float] = []
    for (ax, az), (bx, bz) in zip(vertices, vertices[1:] + vertices[:1]):
        signs.append((bz - az) * (px - ax) - (bx - ax) * (pz - az))
    tolerance = 0.001
    return all(value >= -tolerance for value in signs) or all(
        value <= tolerance for value in signs
    )


def inside_open_top(local_x: float, local_z: float) -> bool:
    # Open mesh top: COL_TRI(1,3,4) and COL_TRI(1,4,2).
    return triangle_contains(
        (local_x, local_z), ((-102.0, 51.0), (153.0, 51.0), (102.0, -51.0))
    ) or triangle_contains(
        (local_x, local_z), ((-102.0, 51.0), (102.0, -51.0), (-102.0, -51.0))
    )


def augment(rows: list[dict[str, str]], hand: str, open_collision: str) -> None:
    previous: dict[str, str] | None = None
    for row in rows:
        angle = i(row, "faceYaw") & 0xFFFF
        radians = angle * (2.0 * math.pi / 65536.0)
        sine, cosine = math.sin(radians), math.cos(radians)
        dx = f(row, "mX") - f(row, "posX")
        dz = f(row, "mZ") - f(row, "posZ")
        local_x_world = dx * cosine - dz * sine
        local_z_world = dx * sine + dz * cosine
        local_x_mesh = local_x_world / 1.5
        local_z_mesh = local_z_world / 1.5
        if row["collision"].lower() == open_collision:
            mesh = "open"
            top = f(row, "posY") + 507.0
        else:
            mesh = "closed_or_other"
            top = f(row, "posY") + 306.0
        post_frame_above = f(row, "mY") - top
        pre_query_gap: float | None = None
        if previous is not None and i(row, "poll") == i(previous, "poll") + 1:
            # Surface objects update before Mario.  At the current completed
            # frame, current handTopY minus the prior completed Mario Y is the
            # observable pre-player-update gap for this frame. Mario's first
            # quarter-step may reduce it before find_floor; ROM floor/platform
            # ownership remains the decisive observation.
            pre_query_gap = top - f(previous, "mY")
        row.update(
            {
                "mesh": mesh,
                "handTopY": f"{top:.3f}",
                "postFrameMarioAboveHandTop": f"{post_frame_above:.3f}",
                "handTopAtOrBelowPostFrameMario": str(post_frame_above >= 0.0).lower(),
                "preQueryFloorMinusMario": (
                    "" if pre_query_gap is None else f"{pre_query_gap:.3f}"
                ),
                "preQueryFloorWithin78AboveMario": (
                    "" if pre_query_gap is None
                    else str(0.0 <= pre_query_gap <= 78.0).lower()
                ),
                "localXWorld": f"{local_x_world:.3f}",
                "localZWorld": f"{local_z_world:.3f}",
                "localXMesh": f"{local_x_mesh:.3f}",
                "localZMesh": f"{local_z_mesh:.3f}",
                "insideOpenTopXZ": str(inside_open_top(local_x_mesh, local_z_mesh)).lower(),
                "sameHandFloor": str(row["mFloorObject"].lower() == hand).lower(),
                "sameHandPlatform": str(row["mPlatform"].lower() == hand).lower(),
            }
        )
        previous = row


def validate_common(
    scenario: str,
    hand: str,
    rows: list[dict[str, str]],
    mario_action: int,
    action_timer: int,
    received_value: int,
    response_action: int,
    response_health: int,
    response_velocity: float,
) -> tuple[dict[str, str], dict[str, str], dict[str, str], dict[str, str], str]:
    pose = one(
        rows,
        lambda r: i(r, "mAction", 16) == mario_action
        and i(r, "mActionTimer") == action_timer
        and near(f(r, "mVelY"), -2.0)
        and near(f(r, "mForwardVel"), 5.0),
        f"{scenario}: local Mario pose absent",
    )
    if not near(f(pose, "mY"), f(pose, "posY") + 100.0):
        fail(f"{scenario}: pose Y is not hand-origin +100")
    if not near(f(pose, "localZWorld"), 100.0, 0.1):
        fail(f"{scenario}: pose is not hand-local Z +100")
    if i(pose, "mSquishTimer") != 0 or not near(f(pose, "mQuicksandDepth"), 0.0):
        fail(f"{scenario}: Mario squish/quicksand fixture was not cleared")

    interact = one(
        rows,
        lambda r: i(r, "poll") > i(pose, "poll")
        and i(r, "interactStatus", 16) != 0,
        f"{scenario}: retail interaction status absent",
    )
    latch = one(
        rows,
        lambda r: i(r, "poll") > i(interact, "poll")
        and i(r, "received") == received_value
        and i(r, "action") == 3,
        f"{scenario}: retail obj_check_attacks latch absent",
    )
    response = one(
        rows,
        lambda r: i(r, "poll") > i(latch, "poll")
        and i(r, "action") == response_action,
        f"{scenario}: retail Eyerok response action absent",
    )
    if i(response, "health") != response_health:
        fail(f"{scenario}: health decrement mismatch")
    if not near(f(response, "velY"), response_velocity):
        fail(f"{scenario}: first post-response velocity mismatch")
    if not near(f(response, "gravity"), -4.0):
        fail(f"{scenario}: retail response gravity -4 absent")
    if i(response, "groundCollision") != 0:
        fail(f"{scenario}: response unexpectedly starts grounded")

    open_collision = pose["collision"].lower()
    if interact["collision"].lower() != open_collision or response["collision"].lower() != open_collision:
        fail(f"{scenario}: SHOW_EYE/open-mesh continuity absent")

    for row in rows:
        if i(pose, "poll") <= i(row, "poll") <= i(response, "poll"):
            input_bits = i(row, "mInput", 16)
            if input_bits & (0x0080 | 0x0002 | 0x2000):
                fail(f"{scenario}: measured interval contains A or B input")
            if i(row, "mSquishTimer") != 0:
                fail(f"{scenario}: inherited squish timer contaminates attack interval")

    return pose, interact, latch, response, open_collision


def validate_nonlethal_long_jump(
    hand: str, rows: list[dict[str, str]]
) -> tuple[list[tuple[str, dict[str, str]]], list[str]]:
    scenario = "nonlethal_long_jump5"
    pose, interact, latch, response, open_collision = validate_common(
        scenario, hand, rows, ACT_LONG_JUMP, 0, 3, 12, 3, 26.0
    )
    if i(interact, "interactStatus", 16) != 0x0000C003:
        fail(f"{scenario}: expected hit-from-above status 0x0000c003")
    if i(interact, "mAction", 16) != ACT_LONG_JUMP or interact["mWall"] == "00000000":
        fail(f"{scenario}: low-speed wall contact did not retain ACT_LONG_JUMP")
    if not near(f(interact, "mForwardVel"), 0.0):
        fail(f"{scenario}: wall did not zero the low forward speed")

    open_reboard = one(
        rows,
        lambda r: r["collision"].lower() == open_collision
        and r["mFloorObject"].lower() == hand
        and r["mPlatform"].lower() == hand
        and i(r, "mAction", 16) == ACT_LEDGE_GRAB
        and near(f(r, "mY"), f(r, "posY") + 507.0, 0.6),
        f"{scenario}: open-top floor/platform reboard absent",
    )
    if open_reboard["insideOpenTopXZ"] != "true":
        fail(f"{scenario}: open reboard is not inside ordinary top triangles")
    if (
        not near(f(open_reboard, "posY"), -1534.0, 0.6)
        or i(open_reboard, "groundCollision") != 0
        or not near(f(open_reboard, "velY"), -26.0, 0.6)
    ):
        fail(f"{scenario}: expected home-height pre-grounding reboard state absent")
    grounded_after_reboard = one(
        rows,
        lambda r: i(r, "poll") == i(open_reboard, "poll") + 1
        and i(r, "action") == 12
        and i(r, "groundCollision") == 1
        and near(f(r, "posY"), -1534.0, 0.6)
        and near(f(r, "velY"), 0.0, 0.6)
        and r["mFloorObject"].lower() == hand
        and r["mPlatform"].lower() == hand,
        f"{scenario}: next-frame grounding after open reboard absent",
    )

    mesh_swap = one(
        rows,
        lambda r: i(r, "poll") > i(open_reboard, "poll")
        and i(r, "action") == 13
        and r["collision"].lower() != open_collision,
        f"{scenario}: retail ATTACKED->RECOVER mesh swap absent",
    )
    if not near(f(mesh_swap, "mFloorHeight"), f(mesh_swap, "posY") + 306.0, 0.6):
        fail(f"{scenario}: recovery floor is not the closed top")
    if mesh_swap["mPlatform"].lower() == hand:
        fail(f"{scenario}: expected temporary platform loss at the 201-unit mesh swap")
    closed_collision = mesh_swap["collision"].lower()
    if closed_collision == "00000000" or closed_collision == open_collision:
        fail(f"{scenario}: recovery did not install a distinct closed mesh")

    closed_reboard = one(
        rows,
        lambda r: i(r, "poll") > i(mesh_swap, "poll")
        and r["collision"].lower() == closed_collision
        and r["mFloorObject"].lower() == hand
        and r["mPlatform"].lower() == hand
        and near(f(r, "mY"), f(r, "posY") + 306.0, 0.6),
        f"{scenario}: closed-top reacquisition absent",
    )
    lifted_rows = [
        r for r in rows
        if i(r, "poll") > i(closed_reboard, "poll")
        and i(r, "action") == 7
        and r["collision"].lower() == closed_collision
        and r["mFloorObject"].lower() == hand
        and r["mPlatform"].lower() == hand
        and near(f(r, "mY"), f(r, "posY") + 306.0, 0.6)
    ]
    if not lifted_rows:
        fail(f"{scenario}: closed-top TARGET_MARIO floor/platform carry absent")
    lifted = max(lifted_rows, key=lambda r: f(r, "mY"))
    if not near(f(lifted, "mY"), -928.0, 0.6):
        fail(f"{scenario}: expected later retail TARGET lift to -928")

    events = [
        ("fixture_pose", pose),
        ("retail_interaction_and_low_speed_wall", interact),
        ("retail_attack_latch", latch),
        ("retail_nonlethal_response", response),
        ("open_top_ledge_reboard", open_reboard),
        ("next_frame_hand_grounded", grounded_after_reboard),
        ("recovery_closed_mesh_swap", mesh_swap),
        ("closed_top_reacquired", closed_reboard),
        ("later_same_hand_lift_peak", lifted),
    ]
    summary = [
        "Retail hit/latch/response: c003 -> received=3 -> ATTACKED, health 4->3, post-move hand vY=26, gravity=-4.",
        f"Open reboard: poll {open_reboard['poll']}, hand at home height but still airborne (vY=-26, ground flag 0), Mario/floor Y={open_reboard['mY']}, ordinary open triangles=true, floor+platform=target, ACT_LEDGE_GRAB; the hand grounds on poll {grounded_after_reboard['poll']}.",
        f"Recovery: 201-unit open-to-closed swap temporarily loses platform; closed top is reacquired at poll {closed_reboard['poll']}.",
        f"Later retail TARGET motion carries the same selected hand to Mario Y={lifted['mY']}.",
    ]
    return events, summary


def validate_lethal_long_jump(
    hand: str, rows: list[dict[str, str]], all_rows: list[dict[str, str]]
) -> tuple[list[tuple[str, dict[str, str]]], list[str]]:
    scenario = "lethal_long_jump5"
    pose, interact, latch, response, open_collision = validate_common(
        scenario, hand, rows, ACT_LONG_JUMP, 0, 3, 15, 1, 46.0
    )
    if i(interact, "mAction", 16) != ACT_LONG_JUMP or interact["mWall"] == "00000000":
        fail(f"{scenario}: low-speed wall contact did not retain ACT_LONG_JUMP")
    if not near(f(interact, "mForwardVel"), 0.0):
        fail(f"{scenario}: wall did not zero the low forward speed")

    pre_bounce: dict[str, str] | None = None
    post_bounce: dict[str, str] | None = None
    for previous, current in zip(rows, rows[1:]):
        if (
            i(previous, "poll") > i(response, "poll")
            and i(previous, "mAction", 16) == ACT_LONG_JUMP
            and i(current, "mAction", 16) == ACT_LONG_JUMP
            and f(previous, "mVelY") < 0.0
            and f(current, "mVelY") > 20.0
            and i(current, "action") == 15
        ):
            pre_bounce, post_bounce = previous, current
            break
    if pre_bounce is None or post_bounce is None:
        fail(f"{scenario}: second retail hit-from-above bounce absent")

    gap_63 = one(
        rows,
        lambda r: i(r, "poll") > i(post_bounce, "poll")
        and i(r, "action") == 15
        and i(r, "actionTimer") == 20
        and r["collision"].lower() == open_collision
        and r["preQueryFloorMinusMario"] != ""
        and near(f(r, "preQueryFloorMinusMario"), 63.0, 0.1),
        f"{scenario}: pre-player-update 63-unit candidate absent",
    )
    gap_7 = one(
        rows,
        lambda r: i(r, "poll") > i(gap_63, "poll")
        and i(r, "action") == 15
        and i(r, "actionTimer") == 21
        and r["collision"].lower() == open_collision
        and r["preQueryFloorMinusMario"] != ""
        and near(f(r, "preQueryFloorMinusMario"), 7.0, 0.1),
        f"{scenario}: pre-player-update 7-unit candidate absent",
    )
    for candidate, expected in ((gap_63, 63.0), (gap_7, 7.0)):
        if candidate["collision"].lower() != open_collision:
            fail(f"{scenario}: {expected:g}-unit candidate does not use open mesh")
        if candidate["preQueryFloorWithin78AboveMario"] != "true":
            fail(f"{scenario}: {expected:g}-unit candidate is not inside +78 buffer")
        if candidate["insideOpenTopXZ"] != "false":
            fail(f"{scenario}: {expected:g}-unit candidate unexpectedly inside open top")
        if candidate["sameHandFloor"] != "false" or candidate["sameHandPlatform"] != "false":
            fail(f"{scenario}: {expected:g}-unit candidate selected target")

    final_live = rows[-1]
    if i(final_live, "action") != 15 or i(final_live, "actionTimer") != 39:
        fail(f"{scenario}: final live DIE frame is not timer 39")
    if final_live["collision"].lower() != open_collision:
        fail(f"{scenario}: lethal hand did not retain the open mesh")
    if final_live["insideOpenTopXZ"] != "false":
        fail(f"{scenario}: expected open-top X/Z exclusion")
    if final_live["mFloorObject"].lower() == hand or final_live["mPlatform"].lower() == hand:
        fail(f"{scenario}: lethal trace unexpectedly reboarded")
    if not near(f(final_live, "postFrameMarioAboveHandTop"), 43.0, 0.6):
        fail(f"{scenario}: expected final post-frame Mario-above-top value 43")
    if not near(f(final_live, "localZWorld"), 127.0, 0.6):
        fail(f"{scenario}: expected wall-resolved local Z +127")
    if not any(i(row, "poll") > i(final_live, "poll") for row in all_rows):
        fail(f"{scenario}: trace ends before post-deletion observation")
    if any(
        row["hand"].lower() == hand and i(row, "poll") > i(final_live, "poll")
        for row in all_rows
    ):
        fail(f"{scenario}: lethal target remains live after timer 39")

    events = [
        ("fixture_pose", pose),
        ("retail_interaction_and_low_speed_wall", interact),
        ("retail_attack_latch", latch),
        ("retail_lethal_response", response),
        ("before_second_hit_from_above", pre_bounce),
        ("after_second_hit_from_above", post_bounce),
        ("pre_query_gap_63_xz_blocked", gap_63),
        ("pre_query_gap_7_xz_blocked", gap_7),
        ("final_live_before_deletion", final_live),
    ]
    summary = [
        "Retail hit/latch/response: c003 -> received=3 -> DIE, health 2->1, post-move hand vY=46, gravity=-4.",
        f"Second retail bounce: poll {pre_bounce['poll']} vY={pre_bounce['mVelY']} -> poll {post_bounce['poll']} vY={post_bounce['mVelY']}; ACT_LONG_JUMP remains active.",
        f"Real update-order candidates: conservative pre-player-update hand-top gaps are {gap_63['preQueryFloorMinusMario']} and {gap_7['preQueryFloorMinusMario']} (both within +78), but both are outside the open top in X/Z and select neither target floor nor platform.",
        f"Final live timer-39 frame: post-frame Mario is {final_live['postFrameMarioAboveHandTop']} above the hand top; local Z={final_live['localZWorld']} world units, inside open top=false, floor/platform not target.",
        "The target is absent on later logged frames: deletion wins before this X/Z-blocked trace can reboard.",
    ]
    return events, summary


def validate_slide_kick(
    scenario: str,
    hand: str,
    rows: list[dict[str, str]],
    response_action: int,
    response_health: int,
    response_velocity: float,
) -> tuple[list[tuple[str, dict[str, str]]], list[str]]:
    pose, interact, latch, response, _ = validate_common(
        scenario, hand, rows, ACT_SLIDE_KICK, 7, 5,
        response_action, response_health, response_velocity,
    )
    if i(interact, "interactStatus", 16) != 0x0000C005:
        fail(f"{scenario}: expected slide-kick status 0x0000c005")
    if i(interact, "mAction", 16) != ACT_BACKWARD_AIR_KB:
        fail(f"{scenario}: first wall did not force ACT_BACKWARD_AIR_KB")
    if interact["mWall"] == "00000000":
        fail(f"{scenario}: wall pointer absent on action exit")
    if not near(f(interact, "mVelY"), -4.0) or not near(f(interact, "mForwardVel"), 4.65, 0.01):
        fail(f"{scenario}: first-wall post-state mismatch")
    if any(
        i(row, "poll") > i(pose, "poll") and i(row, "mAction", 16) == ACT_SLIDE_KICK
        for row in rows
    ):
        fail(f"{scenario}: ACT_SLIDE_KICK incorrectly survived the wall")
    if any(
        row["mFloorObject"].lower() == hand or row["mPlatform"].lower() == hand
        for row in rows
        if i(row, "poll") >= i(pose, "poll")
    ):
        fail(f"{scenario}: slide-kick trace unexpectedly reboarded")
    arena_landing = one(
        rows,
        lambda r: i(r, "poll") > i(response, "poll")
        and near(f(r, "mY"), -1534.0, 0.6)
        and near(f(r, "mFloorHeight"), -1534.0, 0.6),
        f"{scenario}: arena landing absent",
    )

    events = [
        ("fixture_pose", pose),
        ("first_wall_exit_and_retail_interaction", interact),
        ("retail_attack_latch_and_bounce", latch),
        ("retail_lethal_response" if response_action == 15 else "retail_nonlethal_response", response),
        ("arena_landing_no_reboard", arena_landing),
    ]
    response_name = "DIE" if response_action == 15 else "ATTACKED"
    health_before = response_health + 1
    summary = [
        "The open front wall is the first blocker: first post-pose frame changes ACT_SLIDE_KICK to ACT_BACKWARD_AIR_KB and gravity becomes -4.",
        f"Retail interaction still succeeds: c005 -> received=5 -> {response_name}, health {health_before}->{response_health}, post-move hand vY={response_velocity:g}, gravity=-4.",
        "No later row selects the target as Mario floor or platform.",
        "Source boundary: B from ACT_CROUCH_SLIDE enters slide kick without A, but entry writes vY=12 and clamps forward speed to at least 32; ordinary flight does not produce this injected speed-5 state.",
    ]
    return events, summary


def validate_lethal_steering_sweep(
    paths: list[pathlib.Path],
) -> tuple[list[dict[str, str]], list[str]]:
    output_rows: list[dict[str, str]] = []

    for path, schedule in zip(paths, SWEEP):
        label, stick_x, stick_y, switch_poll, after_x, after_y = schedule
        scenario = "lethal_long_jump5"
        _, hand, rows, all_rows = parse(path, scenario, schedule)
        pose = one(
            rows,
            lambda r: i(r, "mAction", 16) == ACT_LONG_JUMP
            and near(f(r, "mForwardVel"), 5.0),
            f"steering {label}: pose row absent",
        )
        open_collision = pose["collision"].lower()
        augment(rows, hand, open_collision)
        pose, interact, _, response, _ = validate_common(
            scenario, hand, rows, ACT_LONG_JUMP, 0, 3, 15, 1, 46.0
        )
        if interact["mWall"] == "00000000" or not near(f(interact, "mForwardVel"), 0.0):
            fail(f"steering {label}: first wall did not zero speed 5")
        if i(interact, "mAction", 16) != ACT_LONG_JUMP:
            fail(f"steering {label}: first wall did not preserve ACT_LONG_JUMP")

        selected_floors = [
            row for row in rows
            if i(row, "poll") >= i(pose, "poll")
            and row["sameHandFloor"] == "true"
        ]
        selected_platforms = [
            row for row in rows
            if i(row, "poll") >= i(pose, "poll")
            and row["sameHandPlatform"] == "true"
        ]
        if selected_platforms:
            fail(f"steering {label}: bounded trace landed on the target platform")
        for row in rows:
            if i(row, "poll") >= i(pose, "poll"):
                input_bits = i(row, "mInput", 16)
                if input_bits & (0x0080 | 0x0002 | 0x2000):
                    fail(f"steering {label}: bounded interval contains A or B input")

        def emit(event: str, row: dict[str, str], candidate_gap: str = "") -> None:
            output_rows.append(
                {
                    "steerLabel": label,
                    "stickX": str(stick_x),
                    "stickY": str(stick_y),
                    "switchRelativePoll": str(switch_poll),
                    "afterStickX": str(after_x),
                    "afterStickY": str(after_y),
                    "event": event,
                    "targetPresent": "true",
                    "candidateGap": candidate_gap,
                    "poll": row["poll"],
                    "timer": row["timer"],
                    "mAction": row["mAction"],
                    "mY": row["mY"],
                    "mVelY": row["mVelY"],
                    "mFloorObject": row["mFloorObject"],
                    "mFloorHeight": row["mFloorHeight"],
                    "mPlatform": row["mPlatform"],
                    "handAction": row["action"],
                    "handActionTimer": row["actionTimer"],
                    "handVelY": row["velY"],
                    "handGravity": row["gravity"],
                    "groundCollision": row["groundCollision"],
                    "handTopY": row["handTopY"],
                    "postFrameMarioAboveHandTop": row["postFrameMarioAboveHandTop"],
                    "preQueryFloorMinusMario": row["preQueryFloorMinusMario"],
                    "localXWorld": row["localXWorld"],
                    "localZWorld": row["localZWorld"],
                    "localXMesh": row["localXMesh"],
                    "localZMesh": row["localZMesh"],
                    "insideOpenTopXZ": row["insideOpenTopXZ"],
                    "sameHandFloor": row["sameHandFloor"],
                    "sameHandPlatform": row["sameHandPlatform"],
                }
            )

        if label in ("y_plus", "brake32"):
            for expected, expected_timer in ((63.0, 20), (7.0, 21)):
                candidate = one(
                    rows,
                    lambda r, expected=expected, expected_timer=expected_timer:
                    i(r, "poll") > i(response, "poll")
                    and i(r, "action") == 15
                    and i(r, "actionTimer") == expected_timer
                    and r["collision"].lower() == open_collision
                    and r["preQueryFloorMinusMario"] != ""
                    and near(f(r, "preQueryFloorMinusMario"), expected, 0.1),
                    f"steering {label}: {expected:g}-unit pre-player-update candidate absent",
                )
                if candidate["preQueryFloorWithin78AboveMario"] != "true":
                    fail(f"steering {label}: {expected:g}-unit gap outside +78 buffer")
                if candidate["insideOpenTopXZ"] != "false":
                    fail(f"steering {label}: {expected:g}-unit gap is inside open top")
                if candidate["sameHandFloor"] != "false" or candidate["sameHandPlatform"] != "false":
                    fail(f"steering {label}: {expected:g}-unit candidate selected target")
                emit("early_height_candidate_xz_outside", candidate, f"{expected:g}")

        if label == "y_plus":
            if not selected_floors:
                fail("steering y_plus: expected later target-floor selection absent")
            first_floor = selected_floors[0]
            last_floor = selected_floors[-1]
            if i(first_floor, "actionTimer") != 27 or i(first_floor, "groundCollision") != 1:
                fail("steering y_plus: first target-floor selection is not grounded DIE timer 27")
            if not near(f(first_floor, "velY"), 0.0) or first_floor["insideOpenTopXZ"] != "true":
                fail("steering y_plus: first target-floor selection geometry/hand velocity mismatch")
            if i(last_floor, "actionTimer") != 36:
                fail("steering y_plus: expected target floor through DIE timer 36")
            if not near(f(first_floor, "mY"), -876.0, 0.1) or not near(f(first_floor, "mVelY"), 2.0, 0.1):
                fail("steering y_plus: first target-floor Mario vertical state mismatch")
            if not near(f(first_floor, "localZWorld"), 76.252, 0.01):
                fail("steering y_plus: first target-floor X/Z entry mismatch")
            if not near(f(last_floor, "mY"), -930.0, 0.1) or not near(f(last_floor, "mVelY"), -16.0, 0.1):
                fail("steering y_plus: last target-floor Mario vertical state mismatch")
            if not near(f(last_floor, "localZWorld"), -71.792, 0.01):
                fail("steering y_plus: last target-floor X/Z state mismatch")
            floor_exit = one(
                rows,
                lambda r: i(r, "poll") == i(last_floor, "poll") + 1,
                "steering y_plus: post-floor-exit row absent",
            )
            if floor_exit["sameHandFloor"] != "false" or not near(f(floor_exit, "localZWorld"), -93.991, 0.01):
                fail("steering y_plus: expected far-edge floor loss absent")
            emit("later_target_floor_selected_hand_already_grounded", first_floor)
            emit("last_target_floor_selected_no_landing", last_floor)
            emit("far_edge_floor_lost_before_landing", floor_exit)
        elif label == "brake32":
            if not selected_floors:
                fail("steering brake32: expected target-floor interval absent")
            first_floor = selected_floors[0]
            last_floor = selected_floors[-1]
            if i(first_floor, "actionTimer") != 27 or i(last_floor, "actionTimer") != 39:
                fail("steering brake32: target floor must persist from DIE timer 27 through 39")
            if not near(f(first_floor, "mY"), -876.0, 0.1) or not near(f(first_floor, "mVelY"), 2.0, 0.1):
                fail("steering brake32: first target-floor vertical state mismatch")
            if not near(f(first_floor, "localZWorld"), 76.252, 0.01):
                fail("steering brake32: first target-floor X/Z state mismatch")
            timer_36 = one(
                selected_floors,
                lambda r: i(r, "actionTimer") == 36,
                "steering brake32: DIE timer-36 floor row absent",
            )
            if not near(f(timer_36, "mY"), -930.0, 0.1) or not near(f(timer_36, "mVelY"), -16.0, 0.1):
                fail("steering brake32: timer-36 Mario vertical state mismatch")
            if not near(f(timer_36, "localZWorld"), 12.206, 0.01):
                fail("steering brake32: timer-36 X/Z state mismatch")
            if last_floor["sameHandPlatform"] != "false" or not near(f(last_floor, "localZWorld"), 20.156, 0.01):
                fail("steering brake32: timer-39 floor-without-platform state mismatch")
            emit("later_target_floor_selected_hand_already_grounded", first_floor)
            emit("braked_inside_floor_selected_no_landing", timer_36)
            emit("last_live_floor_selected_platform_null", last_floor)
        elif selected_floors:
            fail(f"steering {label}: unexpected later target-floor selection")

        final_live = rows[-1]
        if i(final_live, "action") != 15 or i(final_live, "actionTimer") != 39:
            fail(f"steering {label}: final live target is not DIE timer 39")
        if final_live["sameHandPlatform"] != "false":
            fail(f"steering {label}: final live frame unexpectedly landed")
        if label in ("y_plus", "brake32"):
            expected_floor = "true" if label == "brake32" else "false"
            if final_live["sameHandFloor"] != expected_floor:
                fail(f"steering {label}: final target-floor state mismatch")
            if final_live["sameHandFloor"] != "false":
                if label != "brake32":
                    fail("steering y_plus: target floor should be lost by timer 39")
            if not near(f(final_live, "mY"), -984.0, 0.1) or not near(f(final_live, "mVelY"), -22.0, 0.1):
                fail(f"steering {label}: final Mario vertical state mismatch")
            if not near(f(final_live, "postFrameMarioAboveHandTop"), 43.0, 0.1):
                fail(f"steering {label}: expected final 43-above-top state absent")
        if not any(i(row, "poll") > i(final_live, "poll") for row in all_rows):
            fail(f"steering {label}: no post-deletion observation")
        if any(
            row["hand"].lower() == hand and i(row, "poll") > i(final_live, "poll")
            for row in all_rows
        ):
            fail(f"steering {label}: target remains after DIE timer 39")
        emit("final_live_before_deletion_no_landing", final_live)

        if label == "brake32":
            post_delete = one(
                all_rows,
                lambda r: i(r, "poll") == i(final_live, "poll") + 1,
                "steering brake32: first post-deletion Mario row absent",
            )
            first_crossing = one(
                all_rows,
                lambda r: i(r, "poll") == i(final_live, "poll") + 2,
                "steering brake32: first post-deletion top-crossing row absent",
            )
            if not near(f(post_delete, "mY"), -1006.0, 0.1) or not near(f(post_delete, "mVelY"), -24.0, 0.1):
                fail("steering brake32: first post-deletion vertical state mismatch")
            if post_delete["mFloorObject"].lower() != hand or post_delete["mPlatform"].lower() == hand:
                fail("steering brake32: expected one-frame stale floor pointer/platform-null state absent")
            if not near(f(first_crossing, "mY"), -1030.0, 0.1) or not near(f(first_crossing, "mVelY"), -26.0, 0.1):
                fail("steering brake32: first top-crossing vertical state mismatch")
            if first_crossing["mFloorObject"].lower() == hand or first_crossing["mPlatform"].lower() == hand:
                fail("steering brake32: deleted hand still selected at first top crossing")

            last_top = f(final_live, "handTopY")
            hand_x = f(final_live, "posX")
            hand_z = f(final_live, "posZ")
            angle = i(final_live, "faceYaw") & 0xFFFF
            radians = angle * (2.0 * math.pi / 65536.0)
            sine, cosine = math.sin(radians), math.cos(radians)
            for event, row in (
                ("target_deleted_mario_still_21_above_top", post_delete),
                ("first_top_crossing_after_target_deleted", first_crossing),
            ):
                dx = f(row, "mX") - hand_x
                dz = f(row, "mZ") - hand_z
                local_x_world = dx * cosine - dz * sine
                local_z_world = dx * sine + dz * cosine
                local_x_mesh = local_x_world / 1.5
                local_z_mesh = local_z_world / 1.5
                output_rows.append(
                    {
                        "steerLabel": label,
                        "stickX": str(stick_x),
                        "stickY": str(stick_y),
                        "switchRelativePoll": str(switch_poll),
                        "afterStickX": str(after_x),
                        "afterStickY": str(after_y),
                        "event": event,
                        "targetPresent": "false",
                        "candidateGap": "",
                        "poll": row["poll"],
                        "timer": row["timer"],
                        "mAction": row["mAction"],
                        "mY": row["mY"],
                        "mVelY": row["mVelY"],
                        "mFloorObject": row["mFloorObject"],
                        "mFloorHeight": row["mFloorHeight"],
                        "mPlatform": row["mPlatform"],
                        "handAction": "",
                        "handActionTimer": "",
                        "handVelY": "",
                        "handGravity": "",
                        "groundCollision": "",
                        "handTopY": f"{last_top:.3f}",
                        "postFrameMarioAboveHandTop": f"{f(row, 'mY') - last_top:.3f}",
                        "preQueryFloorMinusMario": "",
                        "localXWorld": f"{local_x_world:.3f}",
                        "localZWorld": f"{local_z_world:.3f}",
                        "localXMesh": f"{local_x_mesh:.3f}",
                        "localZMesh": f"{local_z_mesh:.3f}",
                        "insideOpenTopXZ": str(inside_open_top(local_x_mesh, local_z_mesh)).lower(),
                        "sameHandFloor": str(row["mFloorObject"].lower() == hand).lower(),
                        "sameHandPlatform": str(row["mPlatform"].lower() == hand).lower(),
                    }
                )

    y_plus_first = one(
        output_rows,
        lambda row: row["steerLabel"] == "y_plus"
        and row["event"] == "later_target_floor_selected_hand_already_grounded",
        "steering summary: y_plus target-floor row absent",
    )
    y_plus_final = one(
        output_rows,
        lambda row: row["steerLabel"] == "y_plus"
        and row["event"] == "final_live_before_deletion_no_landing",
        "steering summary: y_plus final-live row absent",
    )
    brake_final = one(
        output_rows,
        lambda row: row["steerLabel"] == "brake32"
        and row["event"] == "last_live_floor_selected_platform_null",
        "steering summary: brake32 final-live row absent",
    )
    brake_deleted = one(
        output_rows,
        lambda row: row["steerLabel"] == "brake32"
        and row["event"] == "target_deleted_mario_still_21_above_top",
        "steering summary: brake32 post-deletion row absent",
    )
    brake_crossing = one(
        output_rows,
        lambda row: row["steerLabel"] == "brake32"
        and row["event"] == "first_top_crossing_after_target_deleted",
        "steering summary: brake32 top-crossing row absent",
    )
    summary = [
        "Eight full-stick cardinal/diagonal cases plus one inward-then-reverse braking schedule start only after the first retail wall frame; A and B stay released.",
        "No sampled direction ever sets gMarioPlatform to the target hand. Analog direction can change whether Mario gets the second hit-from-above bounce, so the +63/+7 sequence is asserted for the no-stick base, continuous inward-y, and brake32 traces, not all eight directions.",
        f"Continuous stick (0,+127) later enters X/Z and first selects the target as floor at poll {y_plus_first['poll']}, DIE timer {y_plus_first['handActionTimer']}; Mario Y={y_plus_first['mY']}, vY={y_plus_first['mVelY']}, floor Y={y_plus_first['mFloorHeight']}. The hand is already grounded with vY={y_plus_first['handVelY']}.",
        f"That y_plus trace passes out the far side after DIE timer 36, remains airborne at timer 39 (Y={y_plus_final['mY']}, vY={y_plus_final['mVelY']}, 43 above top), and the target is absent on the next observed frame. Projected Y is -1006 then -1030, so the first top crossing would occur only after deletion.",
        f"Brake32 holds (0,+127) for relative polls [1,32), then (0,-127). It solves X/Z: at DIE timer 39 the target is still Mario's selected floor at local Z={brake_final['localZWorld']}, but platform remains null and Mario is 43 above the top. On poll {brake_deleted['poll']} the target is gone while Mario Y={brake_deleted['mY']} (21 above); poll {brake_crossing['poll']} is the first top crossing at Y={brake_crossing['mY']}, with no target floor/platform.",
        "This is a bounded direction/schedule sweep, not a proof over all analog sequences.",
    ]
    return output_rows, summary


def main() -> int:
    if len(sys.argv) != 15:
        print(
            f"usage: {sys.argv[0]} OUTPUT_DIR FOUR_BASE_LOGS NINE_STEERING_LOGS",
            file=sys.stderr,
        )
        return 2

    output = pathlib.Path(sys.argv[1])
    output.mkdir(parents=True, exist_ok=True)
    all_events: list[dict[str, str]] = []
    summaries: dict[str, list[str]] = {}

    for scenario, argument in zip(SCENARIOS, sys.argv[2:6]):
        _, hand, rows, every_row = parse(pathlib.Path(argument), scenario)
        pose = one(
            rows,
            lambda r: i(r, "mAction", 16)
            in (ACT_LONG_JUMP, ACT_SLIDE_KICK),
            f"{scenario}: pose row absent",
        )
        open_collision = pose["collision"].lower()
        augment(rows, hand, open_collision)
        if scenario == "nonlethal_long_jump5":
            events, summary = validate_nonlethal_long_jump(hand, rows)
        elif scenario == "lethal_long_jump5":
            events, summary = validate_lethal_long_jump(hand, rows, every_row)
        elif scenario == "nonlethal_slide_kick5":
            events, summary = validate_slide_kick(
                scenario, hand, rows, 12, 3, 26.0
            )
        else:
            events, summary = validate_slide_kick(
                scenario, hand, rows, 15, 1, 46.0
            )
        summaries[scenario] = summary
        for event, row in events:
            witness = dict(row)
            witness["event"] = event
            all_events.append(witness)

    sweep_rows, sweep_summary = validate_lethal_steering_sweep(
        [pathlib.Path(argument) for argument in sys.argv[6:]]
    )

    trace_path = output / "attack_reboard_trace.csv"
    with trace_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=TRACE_COLUMNS, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(all_events)

    sweep_path = output / "lethal_steering_sweep.csv"
    with sweep_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=SWEEP_COLUMNS)
        writer.writeheader()
        writer.writerows(sweep_rows)

    lines = [
        "Eyerok attack/reboarding probe summary",
        f"ROM MD5: {EXPECTED_MD5}",
        "ROM SHA-256: 17CE077343C6133F8C9F2D6D6D9A4AB62C8CD2AA57C40AEA1F490B4C8BB21D91",
        f"ROM CRC: {EXPECTED_CRC}",
        "Emulator: Ubuntu-24.04 Mupen64Plus 2.5.9, debugger pure interpreter.",
        "Scope: fixture-assisted local Mario states followed by retail interaction, Eyerok actions, physics, collision, floor/platform selection, and deletion.",
        "Not scope: controller-only/from-reset reachability of the Mario pose; ordinary long-jump entry requires a prior fresh-A edge, but this fixture injects the action; the speed-5 slide-kick fixture is not an ordinary entry state.",
        "Hand writes: none in nonlethal modes; lethal writes health=2 only to represent two prior hits.",
        "Fallback attack-latch or post-hit action/velocity/gravity writes: none.",
        "",
    ]
    for scenario in SCENARIOS:
        lines.append(f"[{scenario}]")
        lines.extend(f"- {entry}" for entry in summaries[scenario])
        lines.append("")
    lines.append("[lethal_steering_sweep]")
    lines.extend(f"- {entry}" for entry in sweep_summary)
    lines.append("")
    lines.extend(
        [
            "Verdict:",
            "- The local nonlethal low-speed long jump is an open-top ledge/floor/platform counterexample to the former universal reboard exclusion; it does not contradict the -4-gravity arithmetic certificate.",
            "- The local lethal low-speed long jump has conservative pre-player-update +63 and +7 height-buffer opportunities, but the open front wall leaves Mario outside the top in X/Z at those times.",
            "- Continuous inward stick later makes the grounded hand Mario's selected floor, but never his platform: Mario crosses the far edge before reaching the top, remains airborne through DIE timer 39, and the hand is deleted.",
            "- The brake32 schedule keeps X/Z valid and the target selected as floor through timer 39, but Mario is still 43 above it with platform null; deletion occurs while he is 21 above, one frame before the first top crossing.",
            "- Both nonlethal and lethal slide-kick fixtures receive their retail hand responses, but the first open-mesh wall hit unconditionally exits Mario to backward air knockback and neither trace reboards.",
            "- Slide kick is no-A enterable in source, but the injected descending speed-5 state is not an ordinary no-A entry state.",
            "- Authentic controller reachability, useful Area-3 warp departure, and a zero/0.5-A route remain open.",
        ]
    )
    (output / "attack_reboard_summary.txt").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(
        f"validated {len(all_events)} base witness rows and "
        f"{len(sweep_rows)} steering/deletion witness rows"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
