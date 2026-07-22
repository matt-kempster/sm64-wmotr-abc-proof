#!/usr/bin/env python3
"""Validate the US-ROM Eyerok probe and emit a small reviewable witness."""

from __future__ import annotations

import csv
import pathlib
import sys


EXPECTED_MD5 = "20B854B239203BAF6C961B850A4A51A2"
EXPECTED_CRC = "635A2BFF 8B022326"


def parse(raw_path: pathlib.Path) -> tuple[str, list[str], list[dict[str, str]]]:
    text = raw_path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()
    header_line = next(line for line in lines if line.startswith("CSV,poll,"))
    fields = next(csv.reader([header_line]))
    rows: list[dict[str, str]] = []
    for line in lines:
        if not line.startswith("CSV,") or line == header_line:
            continue
        values = next(csv.reader([line]))
        if len(values) == len(fields):
            rows.append(dict(zip(fields, values)))
    return text, lines, rows


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} RAW_LOG OUTPUT_DIRECTORY", file=sys.stderr)
        return 2
    raw_path = pathlib.Path(sys.argv[1])
    output_dir = pathlib.Path(sys.argv[2])
    output_dir.mkdir(parents=True, exist_ok=True)
    text, lines, rows = parse(raw_path)

    required_fragments = [
        f"Core: MD5: {EXPECTED_MD5}",
        f"Core: CRC: {EXPECTED_CRC}",
        "activated cheat code 1:",
        "activated cheat code 5:",
        "VALIDATED initialized hands",
        "homeY=-1534,posY=homeY,velY=0,gravity=0,collision=nonnull",
        "FIXTURE initialized_sleep_to_idle",
        "untouched=posY,velY,gravity,moveFlags,floor,collision,timer,prevAction",
        "VALIDATED ordinary IDLE update",
        "floorHeight0=-1534.000 floorHeight1=-1534.000",
        "FIXTURE scheduler",
        "untouched=all_hand_physics,all_hand_actions",
        "VERDICT double_pound_airborne_gravity_zero_positive_velocity_rows=0",
    ]
    missing = [fragment for fragment in required_fragments if fragment not in text]
    if missing:
        raise SystemExit("missing required probe evidence: " + "; ".join(missing))

    forbidden = [
        row
        for row in rows
        if int(row["action"]) == 11
        and float(row["velY"]) > 0.0
        and abs(float(row["gravity"])) < 0.0001
        and int(row["moveSkipped"]) == 0
    ]
    if forbidden:
        raise SystemExit(f"alternate seed reached in {len(forbidden)} row(s)")

    first_hand = rows[0]["hand"]
    witness = [
        row
        for row in rows
        if row["hand"] == first_hand and 365 <= int(row["timer"]) <= 373
    ]
    actions = [int(row["action"]) for row in witness]
    if not ({1, 10, 11} <= set(actions)):
        raise SystemExit("witness does not contain IDLE, BEGIN_DOUBLE_POUND, and DOUBLE_POUND")

    first_positive = next(
        row
        for row in rows
        if int(row["action"]) == 11 and float(row["velY"]) > 0.0
    )
    first_gravity_install = next(
        row
        for row in rows
        if row["hand"] == first_hand
        and int(row["action"]) == 11
        and float(row["gravity"]) <= -20.0
        and float(row["velY"]) <= 0.0
    )

    columns = [
        "poll",
        "timer",
        "area",
        "bossAction",
        "numHands",
        "activeHand",
        "unk104",
        "unk1AC",
        "mAction",
        "mActionTimer",
        "mY",
        "mVelY",
        "mFloor",
        "mFloorType",
        "mFloorHeight",
        "mPlatform",
        "handIndex",
        "hand",
        "side",
        "action",
        "actionTimer",
        "posY",
        "velY",
        "gravity",
        "moveFlags",
        "floor",
        "floorType",
        "floorHeight",
        "collision",
        "activeFlags",
        "groundCollision",
        "moveSkipped",
    ]
    trace_path = output_dir / "idle_double_trace.csv"
    with trace_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=columns, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(witness)

    fixtures = [
        line
        for line in lines
        if line.startswith(("FIXTURE ", "VALIDATED "))
        or "activated cheat code 1:" in line
        or "activated cheat code 5:" in line
    ]
    summary = [
        "Eyerok IDLE-to-DOUBLE US-ROM probe summary",
        f"ROM MD5: {EXPECTED_MD5}",
        f"ROM CRC: {EXPECTED_CRC}",
        "Scope: authentic ROM execution from an initialized, source-reachable local precondition;",
        "       not a from-reset controller-only gameplay trace.",
        f"Parsed hand rows: {len(rows)}",
        f"Alternate seed rows (DOUBLE_POUND, airborne, gravity 0, velY > 0): {len(forbidden)}",
        (
            "First negative-gravity install: "
            f"timer={first_gravity_install['timer']} action={first_gravity_install['action']} "
            f"velY={first_gravity_install['velY']} gravity={first_gravity_install['gravity']} "
            f"moveFlags={first_gravity_install['moveFlags']}"
        ),
        (
            "First positive launch observation: "
            f"timer={first_positive['timer']} action={first_positive['action']} "
            f"posY={first_positive['posY']} velY={first_positive['velY']} "
            f"gravity={first_positive['gravity']}"
        ),
        "",
        "Fixture and validation transcript:",
        *fixtures,
    ]
    (output_dir / "idle_double_summary.txt").write_text(
        "\n".join(summary) + "\n", encoding="utf-8"
    )
    print("\n".join(summary))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
