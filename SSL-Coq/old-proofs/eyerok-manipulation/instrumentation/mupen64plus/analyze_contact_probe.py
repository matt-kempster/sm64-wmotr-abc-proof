#!/usr/bin/env python3
"""Validate the four US-ROM Eyerok/Mario contact microtraces."""

from __future__ import annotations

import csv
import math
import pathlib
import re
import sys


EXPECTED_MD5 = "20B854B239203BAF6C961B850A4A51A2"
EXPECTED_CRC = "635A2BFF 8B022326"
MODES = ("stationary", "b_only", "held_a", "held_a_b_edge")
TRACE_COLUMNS = (
    "poll", "timer", "area", "bossAction", "bossTimer", "activeHand",
    "mAction", "mActionTimer", "mX", "mY", "mZ", "mVelY", "mFloor",
    "mFloorObject", "mFloorHeight", "mPlatform", "mInput", "mCeil",
    "mCeilObject", "mCeilHeight", "hand", "side", "action", "actionTimer",
    "posX", "posY", "posZ", "faceYaw", "handTopY", "preQueryMarioY",
    "verticalGap", "within78", "postSnapGap", "insideClosedTopXZ", "sameHandFloor", "sameHandPlatform",
    "contactClass", "velY", "gravity", "moveFlags", "floorHeight",
    "collision", "groundCollision", "moveSkipped",
)


def fail(message: str) -> None:
    raise SystemExit(message)


def parse(path: pathlib.Path, mode: str) -> tuple[str, str, list[dict[str, str]]]:
    text = path.read_text(encoding="utf-8", errors="replace")
    for fragment in (
        f"Core: MD5: {EXPECTED_MD5}",
        f"Core: CRC: {EXPECTED_CRC}",
        f"CONTACT_MODE,{mode}",
        "SETUP boss set WAKE_UP; hands left untouched",
        "SETUP scheduler-only FIGHT",
        "hands untouched",
        "CONTACT acquired hand floor/platform authentically",
    ):
        if fragment not in text:
            fail(f"{mode}: missing required evidence: {fragment}")

    match = re.search(r"CONTACT acquired .*?hand=([0-9a-fA-F]{8})", text)
    if match is None:
        fail(f"{mode}: contact hand not identified")
    hand = match.group(1).lower()

    lines = text.splitlines()
    header_line = next((line for line in lines if line.startswith("CSV,poll,")), None)
    if header_line is None:
        fail(f"{mode}: CSV header absent")
    fields = next(csv.reader([header_line]))
    rows: list[dict[str, str]] = []
    for line in lines:
        if not line.startswith("CSV,") or line == header_line:
            continue
        values = next(csv.reader([line]))
        if len(values) == len(fields):
            row = dict(zip(fields, values))
            if row["hand"].lower() == hand:
                rows.append(row)
    if not rows:
        fail(f"{mode}: no rows for contact hand {hand}")
    return text, hand, rows


def f(row: dict[str, str], key: str) -> float:
    return float(row[key])


def i(row: dict[str, str], key: str, base: int = 10) -> int:
    return int(row[key], base)


def near(actual: float, expected: float, tolerance: float = 0.01) -> bool:
    return abs(actual - expected) <= tolerance


def triangle_contains(point: tuple[float, float], vertices: tuple[tuple[float, float], ...]) -> bool:
    signs: list[float] = []
    px, pz = point
    for (ax, az), (bx, bz) in zip(vertices, vertices[1:] + vertices[:1]):
        signs.append((bz - az) * (px - ax) - (bx - ax) * (pz - az))
    return all(value > 0.01 for value in signs) or all(value < -0.01 for value in signs)


def inside_closed_top(row: dict[str, str]) -> bool:
    angle = i(row, "faceYaw") & 0xFFFF
    radians = angle * (2.0 * math.pi / 65536.0)
    sine, cosine = math.sin(radians), math.cos(radians)
    dx = f(row, "mX") - f(row, "posX")
    dz = f(row, "mZ") - f(row, "posZ")
    local_x = (dx * cosine - dz * sine) / 1.5
    local_z = (dx * sine + dz * cosine) / 1.5
    # Closed mesh top triangles: COL_TRI(1,3,4) and COL_TRI(1,4,5).
    return triangle_contains((local_x, local_z), ((-63.0, -90.0), (-87.0, 147.0), (68.0, 147.0))) or triangle_contains(
        (local_x, local_z), ((-63.0, -90.0), (68.0, 147.0), (68.0, -134.0))
    )


def augment(rows: list[dict[str, str]], hand: str) -> None:
    previous_mario_y: float | None = None
    for row in rows:
        top = f(row, "posY") + 306.0
        mario_y = f(row, "mY")
        query_y = mario_y if previous_mario_y is None else previous_mario_y
        gap = top - query_y
        post_gap = top - mario_y
        inside = inside_closed_top(row)
        same_floor = row["mFloorObject"].lower() == hand
        same_platform = row["mPlatform"].lower() == hand
        if same_floor and same_platform and near(f(row, "mY"), top, 0.6):
            classification = "same_hand_snap"
        elif same_floor:
            classification = "same_hand_query"
        elif near(f(row, "mFloorHeight"), -1534.0) and row["mCeilObject"].lower() == hand:
            classification = "arena_floor_hand_ceiling"
        elif near(f(row, "mFloorHeight"), -1534.0):
            classification = "arena_floor"
        else:
            classification = "other_floor"
        row.update({
            "handTopY": f"{top:.3f}",
            "preQueryMarioY": f"{query_y:.3f}",
            "verticalGap": f"{gap:.3f}",
            "within78": str(gap <= 78.0).lower(),
            "postSnapGap": f"{post_gap:.3f}",
            "insideClosedTopXZ": str(inside).lower(),
            "sameHandFloor": str(same_floor).lower(),
            "sameHandPlatform": str(same_platform).lower(),
            "contactClass": classification,
        })
        previous_mario_y = mario_y


def one(rows: list[dict[str, str]], predicate, message: str) -> dict[str, str]:
    matches = [row for row in rows if predicate(row)]
    if not matches:
        fail(message)
    return matches[0]


def validate_stationary(rows: list[dict[str, str]], hand: str) -> list[str]:
    before = one(
        rows,
        lambda r: i(r, "action") == 11 and i(r, "actionTimer") == 4
        and r["mPlatform"].lower() == hand and near(f(r, "mY"), -1228.0),
        "stationary: Mario was not authenticated on the prelaunch hand top",
    )
    launch = one(
        rows,
        lambda r: near(f(r, "velY"), 85.0),
        "stationary: +85 launch absent",
    )
    if launch["mPlatform"] != "00000000" or not near(f(launch, "mFloorHeight"), -1534.0):
        fail("stationary: Mario did not lose the hand to the arena floor")
    if i(launch, "mAction", 16) != 0x00020339:
        fail("stationary: expected ACT_SQUISHED after the +85 rejection")
    if launch["insideClosedTopXZ"] != "true" or launch["within78"] != "false":
        fail("stationary: expected inside-XZ but 85>78 vertical rejection")
    return [
        f"prelaunch: MarioY={before['mY']} floorH={before['mFloorHeight']} platform={before['mPlatform']}",
        f"+85 frame: gap={launch['verticalGap']} within78={launch['within78']} insideTopXZ={launch['insideClosedTopXZ']}",
        f"classification: {launch['contactClass']}; MarioY={launch['mY']} floorH={launch['mFloorHeight']} platform=null ACT_SQUISHED",
    ]


def validate_b_only(rows: list[dict[str, str]], hand: str) -> list[str]:
    dive = one(
        rows,
        lambda r: i(r, "mAction", 16) == 0x0188088A and near(f(r, "mY"), -1208.0)
        and near(f(r, "mVelY"), 16.0),
        "b_only: retail ACT_DIVE post-entry state absent",
    )
    bits = i(dive, "mInput", 16)
    if not bits & 0x2000 or bits & (0x0002 | 0x0080):
        fail("b_only: expected B_PRESSED with neither A_PRESSED nor A_DOWN")
    launch = one(rows, lambda r: near(f(r, "velY"), 85.0), "b_only: +85 launch absent")
    if launch["mPlatform"].lower() != hand or not near(f(launch, "mFloorHeight"), -1143.0):
        fail("b_only: Mario did not catch the +85 hand")
    for velocity in (85.0, 70.0, 55.0, 40.0, 25.0, 10.0):
        row = one(rows, lambda r, v=velocity: near(f(r, "velY"), v), f"b_only: missing +{velocity:g}")
        if row["mPlatform"].lower() != hand:
            fail(f"b_only: lost hand before or during +{velocity:g}")
        if row["insideClosedTopXZ"] != "true" or row["within78"] != "true":
            fail(f"b_only: +{velocity:g} catch was not ordinary eligible geometry")
    peak = max(f(row, "mY") for row in rows if row["mPlatform"].lower() == hand)
    if not near(peak, -943.0):
        fail(f"b_only: expected full-episode top -943, got {peak}")
    return [
        f"ROM entry: action=ACT_DIVE MarioY={dive['mY']} velY={dive['mVelY']} input=0x{bits:04x} (A always up)",
        f"+85 catch: gap={launch['verticalGap']} within78={launch['within78']} insideTopXZ={launch['insideClosedTopXZ']} class={launch['contactClass']}",
        f"retention: rear-interior start stays attached for +85,+70,+55,+40,+25,+10; maximum MarioY={peak:.0f}",
    ]


def validate_held_a(rows: list[dict[str, str]], hand: str) -> list[str]:
    jump_kick = one(
        rows,
        lambda r: i(r, "mAction", 16) == 0x018008AC and near(f(r, "mY"), -1208.0)
        and near(f(r, "mVelY"), 16.0),
        "held_a: retail ACT_JUMP_KICK post-entry state absent",
    )
    bits = i(jump_kick, "mInput", 16)
    if not bits & 0x0080 or bits & (0x0002 | 0x2000):
        fail("held_a: expected A_DOWN without A_PRESSED or B_PRESSED")
    launch = one(rows, lambda r: near(f(r, "velY"), 85.0), "held_a: +85 launch absent")
    for velocity in (85.0, 70.0, 55.0, 40.0, 25.0, 10.0):
        row = one(rows, lambda r, v=velocity: near(f(r, "velY"), v), f"held_a: missing +{velocity:g}")
        if row["mPlatform"].lower() != hand:
            fail(f"held_a: lost hand during +{velocity:g}")
        if not near(f(row, "mFloorHeight"), f(row, "posY") + 306.0):
            fail(f"held_a: selected floor is not closed hand top during +{velocity:g}")
        if row["insideClosedTopXZ"] != "true" or row["within78"] != "true":
            fail(f"held_a: +{velocity:g} catch was not ordinary eligible geometry")
    peak = max(f(row, "mY") for row in rows if row["mPlatform"].lower() == hand)
    if not near(peak, -943.0):
        fail(f"held_a: expected full-episode top -943, got {peak}")
    return [
        f"ROM entry: action=ACT_JUMP_KICK MarioY={jump_kick['mY']} velY={jump_kick['mVelY']} input=0x{bits:04x}",
        "A evidence: INPUT_A_DOWN is set; INPUT_A_PRESSED is clear (no new edge)",
        f"+85 catch: gap={launch['verticalGap']} within78={launch['within78']} insideTopXZ={launch['insideClosedTopXZ']} class={launch['contactClass']}",
        f"retention: attached for +85,+70,+55,+40,+25,+10; maximum MarioY={peak:.0f}",
    ]


def validate_held_a_b_edge(
    text: str, rows: list[dict[str, str]], hand: str
) -> list[str]:
    marker = "CONTACT held-A+B controller-only predecessor accepted"
    if marker not in text or "noMarioWritesAtRelease=1" not in text:
        fail("held_a_b_edge: authenticated write-free release marker absent")
    jump_kick = one(
        rows,
        lambda r: i(r, "mAction", 16) == 0x018008AC and near(f(r, "mY"), -1208.0)
        and near(f(r, "mVelY"), 16.0),
        "held_a_b_edge: retail IDLE -> PUNCHING -> ACT_JUMP_KICK result absent",
    )
    bits = i(jump_kick, "mInput", 16)
    if not bits & 0x0080 or not bits & 0x2000 or bits & 0x0002:
        fail("held_a_b_edge: expected A_DOWN+B_PRESSED with no A_PRESSED")
    launch = one(
        rows, lambda r: near(f(r, "velY"), 85.0),
        "held_a_b_edge: +85 launch absent",
    )
    for velocity in (85.0, 70.0, 55.0, 40.0, 25.0, 10.0):
        row = one(
            rows, lambda r, v=velocity: near(f(r, "velY"), v),
            f"held_a_b_edge: missing +{velocity:g}",
        )
        if row["mPlatform"].lower() != hand:
            fail(f"held_a_b_edge: lost hand during +{velocity:g}")
        if not near(f(row, "mFloorHeight"), f(row, "posY") + 306.0):
            fail(f"held_a_b_edge: selected floor is not closed hand top during +{velocity:g}")
        if row["insideClosedTopXZ"] != "true" or row["within78"] != "true":
            fail(f"held_a_b_edge: +{velocity:g} catch was not ordinary eligible geometry")
    peak = max(f(row, "mY") for row in rows if row["mPlatform"].lower() == hand)
    if not near(peak, -943.0):
        fail(f"held_a_b_edge: expected full-episode top -943, got {peak}")
    return [
        "accepted boundary: authenticated ACT_IDLE on the real hand; no Mario-state write at release",
        f"retail chain: IDLE -> PUNCHING -> ACT_JUMP_KICK, MarioY={jump_kick['mY']} velY={jump_kick['mVelY']} input=0x{bits:04x}",
        "input evidence: A_DOWN and B_PRESSED are set; A_PRESSED is clear",
        f"+85 catch: gap={launch['verticalGap']} within78={launch['within78']} insideTopXZ={launch['insideClosedTopXZ']} class={launch['contactClass']}",
        f"retention: attached for +85,+70,+55,+40,+25,+10; maximum MarioY={peak:.0f}",
    ]


def main() -> int:
    if len(sys.argv) != 6:
        print(f"usage: {sys.argv[0]} OUTPUT_DIR STATIONARY_LOG B_ONLY_LOG HELD_A_LOG HELD_A_B_EDGE_LOG", file=sys.stderr)
        return 2
    output = pathlib.Path(sys.argv[1])
    output.mkdir(parents=True, exist_ok=True)
    summaries: dict[str, list[str]] = {}
    for mode, argument in zip(MODES, sys.argv[2:]):
        text, hand, rows = parse(pathlib.Path(argument), mode)
        augment(rows, hand)
        if mode == "stationary":
            summaries[mode] = validate_stationary(rows, hand)
        elif mode == "b_only":
            summaries[mode] = validate_b_only(rows, hand)
        elif mode == "held_a":
            summaries[mode] = validate_held_a(rows, hand)
        else:
            summaries[mode] = validate_held_a_b_edge(text, rows, hand)

        witness = [row for row in rows if 0 <= i(row, "actionTimer") <= 13]
        with (output / f"contact_{mode}_trace.csv").open("w", newline="", encoding="utf-8") as handle:
            writer = csv.DictWriter(handle, fieldnames=TRACE_COLUMNS, extrasaction="ignore")
            writer.writeheader()
            writer.writerows(witness)

    lines = [
        "Eyerok/Mario contact probe summary",
        f"ROM MD5: {EXPECTED_MD5}",
        f"ROM CRC: {EXPECTED_CRC}",
        "Scope: source-shaped local setup plus retail hand physics, update order, collision, Mario actions, and controller transitions.",
        "Not scope: a controller-only trace from reset to the staged predecessor pose.",
        "",
    ]
    for mode in MODES:
        lines.append(f"[{mode}]")
        lines.extend(summaries[mode])
        lines.append("")
    lines.extend([
        "First blocker for same-frame action entry:",
        "surface objects (the hand) update before Mario; vertical platform velocity is not applied to Mario;",
        "the +85 top is 7 units beyond find_floor's +78 buffer, the arena floor wins, and the",
        "raised hand underside forms a dynamic ceiling only 89.5/90 units above it, setting INPUT_SQUISHED.",
    ])
    text = "\n".join(lines) + "\n"
    (output / "contact_summary.txt").write_text(text, encoding="utf-8")
    print(text, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
