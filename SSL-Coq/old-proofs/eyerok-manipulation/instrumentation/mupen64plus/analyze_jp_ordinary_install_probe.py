#!/usr/bin/env python3
"""Validate the original-JP ordinary-scale Eyerok installation probe."""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path


JP_MD5 = "85D61F5525AF708C9F1E84DCE6DC10E9"
JP_CRC = "4EAA3D0E 74757C24"
CLOSED_COLLISION = "80120754"
OPEN_COLLISION = "801207d8"
WARP_NEAR_Z = -1222.0
HAND_HORIZONTAL_OFFSET = 459.0
HOME_Y = -1534.0
CLOSED_TOP_OFFSET = 306.0
OPEN_TOP_OFFSET = 507.0
LOW_PEDRO_FLOOR_MIN = -569.0


FRAME_RE = re.compile(
    r"^INSTALL_FRAME,case=(?P<case>[^,]+),side=(?P<side>-?\d+),"
    r"poll=(?P<poll>\d+),timer=(?P<timer>\d+),phase=(?P<phase>\d+),"
    r"boss=(?P<boss>[0-9a-f]+),bossAction=(?P<boss_action>-?\d+),"
    r"numHands=(?P<num_hands>-?\d+),activeHand=(?P<active_hand>-?\d+),"
    r"hand=(?P<hand>[0-9a-f]+),handAction=(?P<action>-?\d+),"
    r"handTimer=(?P<action_timer>-?\d+),"
    r"pos=\((?P<x>-?[0-9.]+),(?P<y>-?[0-9.]+),(?P<z>-?[0-9.]+)\),"
    r"vel=\((?P<vel>[^)]*)\),forwardVel=(?P<forward>-?[0-9.]+),"
    r"moveYaw=(?P<move_yaw>-?\d+),faceYaw=(?P<face_yaw>-?\d+),"
    r"angleToMario=(?P<angle_to_mario>-?\d+),gravity=(?P<gravity>-?[0-9.]+),"
    r"moveFlags=(?P<move_flags>[0-9a-f]+),floor=(?P<floor>[0-9a-f]+),"
    r"floorType=(?P<floor_type>-?\d+),floorObject=(?P<floor_object>[0-9a-f]+),"
    r"floorHeight=(?P<floor_height>-?[0-9.]+),collision=(?P<collision>[0-9a-f]+),"
    r"mario=\((?P<mario>[^)]*)\)$"
)


@dataclass(frozen=True)
class Frame:
    timer: int
    action: int
    x: float
    y: float
    z: float
    collision: str


def fail(label: str, message: str) -> None:
    raise SystemExit(f"{label}: {message}")


def require(text: str, needle: str, label: str) -> None:
    if needle not in text:
        fail(label, f"missing {needle!r}")


def close(actual: float, expected: float, tolerance: float = 0.001) -> bool:
    return abs(actual - expected) <= tolerance


def read_case(path: Path, expected_case: str, expected_side: int) -> list[Frame]:
    label = path.parent.name
    text = path.read_text(encoding="utf-8", errors="replace")
    require(text, "Core: Goodname: Super Mario 64 (J) [!]", label)
    require(text, f"Core: MD5: {JP_MD5}", label)
    require(text, f"Core: CRC: {JP_CRC}", label)
    require(text, "activated cheat code 6: Have\\Level Select", label)
    require(text, f"INSTALL_WAKE_FIXTURE,case={expected_case},side={expected_side}", label)
    require(text, f"INSTALL_FIXTURE,case={expected_case},side={expected_side}", label)

    frames: list[Frame] = []
    for line in text.splitlines():
        match = FRAME_RE.match(line)
        if match is None:
            continue
        if match["case"] != expected_case or int(match["side"]) != expected_side:
            fail(label, "mixed case or side in frame stream")
        frames.append(
            Frame(
                timer=int(match["timer"]),
                action=int(match["action"]),
                x=float(match["x"]),
                y=float(match["y"]),
                z=float(match["z"]),
                collision=match["collision"],
            )
        )
    if len(frames) != 316:
        fail(label, f"expected 316 frames, found {len(frames)}")
    if frames[0].timer != 446 or frames[-1].timer != 761:
        fail(label, "unexpected timer interval")
    return frames


def action_frames(frames: list[Frame], action: int) -> list[Frame]:
    selected = [frame for frame in frames if frame.action == action]
    if not selected:
        raise SystemExit(f"missing action {action}")
    return selected


def lethal_open_top() -> tuple[float, int]:
    """Exact source-shaped 50/-4 arc before the strict ground snap."""
    velocity = 50
    relative_y = 0
    peak = 0
    integrations = 0
    while True:
        integrations += 1
        velocity -= 4
        candidate = relative_y + velocity
        if candidate < 0:
            break
        relative_y = candidate
        peak = max(peak, relative_y)
    if peak != 288 or integrations != 25:
        raise SystemExit("lethal gravity calculation changed")
    return HOME_Y + peak + OPEN_TOP_OFFSET, integrations


def main() -> None:
    if len(sys.argv) != 6:
        raise SystemExit(
            "usage: analyze_jp_ordinary_install_probe.py OUTPUT "
            "RIGHT_FIST LEFT_FIST RIGHT_SHOW LEFT_SHOW"
        )

    output = Path(sys.argv[1])
    cases = {
        "right_fist_push": read_case(Path(sys.argv[2]), "fist_push", 1),
        "left_fist_push": read_case(Path(sys.argv[3]), "fist_push", -1),
        "right_one_hand_show_eye": read_case(
            Path(sys.argv[4]), "one_hand_show_eye", 1
        ),
        "left_one_hand_show_eye": read_case(
            Path(sys.argv[5]), "one_hand_show_eye", -1
        ),
    }

    fist_summaries: list[str] = []
    for label in ("right_fist_push", "left_fist_push"):
        push = action_frames(cases[label], 8)
        sweep = action_frames(cases[label], 9)
        forward = push + sweep
        if any(not close(frame.y, HOME_Y) for frame in forward):
            fail(label, "fist push/sweep left home Y")
        if any(frame.collision != CLOSED_COLLISION for frame in forward):
            fail(label, "fist push/sweep did not retain closed collision")
        max_pivot_z = max(frame.z for frame in forward)
        max_collision_z = max_pivot_z + HAND_HORIZONTAL_OFFSET
        if not max_collision_z < WARP_NEAR_Z:
            fail(label, "coarse fist collision reaches the warp")
        fist_summaries.append(
            f"{label}: action 8 timers {push[0].timer}..{push[-1].timer}, "
            f"action 9 timers {sweep[0].timer}..{sweep[-1].timer}, "
            f"max pivot Z={max_pivot_z:.6f}, coarse max collision Z="
            f"{max_collision_z:.6f} < warp Z={WARP_NEAR_Z:.0f}"
        )

    show_summaries: list[str] = []
    for label in ("right_one_hand_show_eye", "left_one_hand_show_eye"):
        show = action_frames(cases[label], 3)
        close_action = action_frames(cases[label], 4)
        if any(not close(frame.y, HOME_Y) for frame in show + close_action):
            fail(label, "SHOW_EYE/CLOSE left home Y")
        if any(frame.collision != OPEN_COLLISION for frame in show):
            fail(label, "SHOW_EYE did not retain open collision")
        max_pivot_z = max(frame.z for frame in show)
        if not max_pivot_z > -1023.0:
            fail(label, "one-hand SHOW_EYE did not cross the warp Z interval")
        show_summaries.append(
            f"{label}: action 3 timers {show[0].timer}..{show[-1].timer}, "
            f"max pivot Z={max_pivot_z:.6f}, pivot Y={HOME_Y:.0f}, "
            f"open top Y={HOME_Y + OPEN_TOP_OFFSET:.0f}"
        )

    target_frames = action_frames(cases["right_one_hand_show_eye"], 6)
    target_peak_y = max(frame.y for frame in target_frames)
    target_max_z = max(frame.z for frame in target_frames)
    if not close(target_peak_y, -1234.0):
        fail("right_one_hand_show_eye", "unexpected TARGET_MARIO peak Y")
    if not target_max_z + HAND_HORIZONTAL_OFFSET < WARP_NEAR_Z:
        fail("right_one_hand_show_eye", "TARGET_MARIO envelope reaches warp")

    lethal_top, lethal_integrations = lethal_open_top()
    closed_top = HOME_Y + CLOSED_TOP_OFFSET
    open_top = HOME_Y + OPEN_TOP_OFFSET
    target_closed_top = target_peak_y + CLOSED_TOP_OFFSET
    if not max(closed_top, open_top, target_closed_top, lethal_top) < LOW_PEDRO_FLOOR_MIN:
        fail("joint verdict", "a checked stock top enters the low Pedro band")

    lines = [
        "Original-JP ordinary Eyerok Pedro installation probe: validated",
        f"ROM MD5: {JP_MD5.lower()}",
        f"ROM CRC1/CRC2: {JP_CRC.lower()}",
        "start boundary: level select",
        "fixtures: boss wake only; conditional FIST_PUSH source transition; natural one-hand OPEN->SHOW_EYE scheduler",
        *fist_summaries,
        *show_summaries,
        f"closed forward top: {closed_top:.0f}; open forward top: {open_top:.0f}",
        f"conditional lethal open arc: {lethal_integrations} integrations to ground, peak top Y={lethal_top:.0f}",
        f"later TARGET_MARIO sample: peak pivot Y={target_peak_y:.0f}, closed top Y={target_closed_top:.0f}, coarse max collision Z={target_max_z + HAND_HORIZONTAL_OFFSET:.6f}",
        "Pedro floors required at the central warp: [-569,-411] or [608,766]",
        f"closest checked vertically eligible forward top: {lethal_top:.0f}, still {LOW_PEDRO_FLOOR_MIN - lethal_top:.0f} below the low band",
        "retail branch verdict: FIST_PUSH/SWEEP is edge-stopped before the warp; one-hand SHOW_EYE crosses X/Z but remains vertically too low",
        "scope: the action and scheduler fixtures are disclosed conditional probes, not a controller-reachability claim",
        "scope: the stock-action exhaustion, sibling exclusion, post-Mario writer frame, and no-reuse payload are supplied by the pinned-source audit and Coq certificate",
    ]
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
