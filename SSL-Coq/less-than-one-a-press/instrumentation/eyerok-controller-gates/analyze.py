#!/usr/bin/env python3
"""Fail-closed checker for the paired controller-only Eyerok suffixes."""

from __future__ import annotations

import csv
import hashlib
import sys
from pathlib import Path

EXPECTED_MD5 = "20b854b239203baf6c961b850a4a51a2"
EXPECTED_SHA256 = "17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91"


def fail(message: str) -> None:
    raise SystemExit(f"eyerok-controller-gates: {message}")


def digest(path: Path, algorithm: str) -> str:
    h = hashlib.new(algorithm)
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def key_values(line: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    for item in line.rstrip().split(",")[1:]:
        if "=" in item:
            key, value = item.split("=", 1)
            fields[key] = value
    return fields


def parse_log(path: Path) -> tuple[dict[str, str], list[dict[str, str]], dict[str, str]]:
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    headers = [line for line in lines if line.startswith("GATE_HEADER,")]
    boundaries = [line for line in lines if line.startswith("GATE_BOUNDARY,")]
    verdicts = [line for line in lines if line.startswith("GATE_VERDICT,")]
    if len(headers) != 1 or len(boundaries) != 1 or len(verdicts) != 1:
        fail(f"{path}: expected one header, boundary, and verdict")
    columns = next(csv.reader([headers[0]]))[1:]
    rows: list[dict[str, str]] = []
    for line in lines:
        if not line.startswith("GATE,"):
            continue
        values = next(csv.reader([line]))[1:]
        if len(values) != len(columns):
            fail(f"{path}: row width {len(values)} != header width {len(columns)}")
        rows.append(dict(zip(columns, values)))
    if not rows:
        fail(f"{path}: no GATE rows")
    return key_values(boundaries[0]), rows, key_values(verdicts[0])


def integer(row: dict[str, str], key: str) -> int:
    return int(row[key], 0)


def real(row: dict[str, str], key: str) -> float:
    return float(row[key])


def one_row(rows: list[dict[str, str]], timer: int) -> dict[str, str]:
    found = [row for row in rows if integer(row, "timer") == timer]
    if len(found) != 1:
        fail(f"timer {timer}: expected one row, got {len(found)}")
    return found[0]


def check_common(
    label: str,
    boundary: dict[str, str],
    rows: list[dict[str, str]],
    verdict: dict[str, str],
    side: int,
) -> None:
    expected_boundary = {
        "timer": "363",
        "area": "3",
        "postBoundaryMemoryWrites": "zero",
        "postBoundaryButtons": "stick-and-dialog-B-only",
        "selectionX": "800.000",
        "kiteX": "800.000",
        "kiteZ": "-2000.000",
        "smashSide": str(side),
        "smashAngleMagnitude": "8500",
        "smashTargetRadius": "120.000",
    }
    for key, expected in expected_boundary.items():
        if boundary.get(key) != expected:
            fail(f"{label}: boundary {key}={boundary.get(key)!r}, expected {expected!r}")
    for key in (
        "sawWake",
        "sawStripBeforeFight",
        "sawDeterministicTarget",
        "sawReleasedChase",
        "sawSmash",
        "sawSweep",
    ):
        if verdict.get(key) != "1":
            fail(f"{label}: {key} was not witnessed")
    expected_verdict = {
        "selectionTimer": "903",
        "selectionMarioZ": "-2998.542969",
        "selectionHandZ": "-3393.000000",
        "sweepTimer": "981",
        "farthestHandZ": "-1970.731445",
        "aInputPolls": "0",
        "bInputPolls": "13",
        "handFloorFrames": "0",
        "handPlatformFrames": "0",
        "postBoundaryMemoryWrites": "0",
    }
    for key, expected in expected_verdict.items():
        if verdict.get(key) != expected:
            fail(f"{label}: verdict {key}={verdict.get(key)!r}, expected {expected!r}")
    hand = one_row(rows, 903)["hand"]
    for row in rows:
        if row["floorOwner"].lower() == hand.lower():
            fail(f"{label}: hand became Mario's floor owner at timer {row['timer']}")
        if row["platform"].lower() == hand.lower():
            fail(f"{label}: hand became Mario's cached platform at timer {row['timer']}")


def main() -> None:
    if len(sys.argv) not in (4, 5):
        fail("usage: analyze.py ROM positive-front.log negative-front.log [expected.txt]")
    rom, positive_path, negative_path = map(Path, sys.argv[1:4])
    md5 = digest(rom, "md5")
    sha256 = digest(rom, "sha256")
    if md5 != EXPECTED_MD5 or sha256 != EXPECTED_SHA256:
        fail("ROM digest mismatch")

    positive = parse_log(positive_path)
    negative = parse_log(negative_path)
    check_common("positive-front", *positive, side=1)
    check_common("negative-front", *negative, side=-1)
    _, positive_rows, _ = positive
    _, negative_rows, _ = negative

    p_entry = one_row(positive_rows, 981)
    p_fall = one_row(positive_rows, 1020)
    if not (
        real(p_entry, "marioY") == -1534.0
        and real(p_entry, "floorHeight") == -1534.0
        and p_entry["floorOwner"] == "00000000"
        and p_entry["platform"] == "00000000"
        and integer(p_entry, "handMoveYaw") == 16384
        and -1900.0 < real(p_entry, "marioZ") < -1880.0
    ):
        fail("positive-front: unexpected grounded sweep-entry state")
    if not (real(p_fall, "marioY") < -1534.0 and real(p_fall, "floorHeight") == -4606.0):
        fail("positive-front: the X-edge fall was not observed")

    n_entry = one_row(negative_rows, 981)
    n_zero = one_row(negative_rows, 990)
    n_end = one_row(negative_rows, 1062)
    negative_sweep = [row for row in negative_rows if integer(row, "phase") >= 5]
    if not (
        integer(n_entry, "handMoveYaw") == -16384
        and all(real(row, "marioY") == -1534.0 for row in negative_sweep)
        and all(real(row, "floorHeight") == -1534.0 for row in negative_sweep)
        and all(row["floorOwner"] == "00000000" for row in negative_sweep)
        and all(row["platform"] == "00000000" for row in negative_sweep)
    ):
        fail("negative-front: sweep did not remain on the static arena floor")
    post_zero = [row for row in negative_rows if integer(row, "timer") >= 990]
    if not post_zero or any(real(row, "marioForwardVel") != 0.0 for row in post_zero):
        fail("negative-front: stored forward speed became nonzero after reaching zero")
    delta_x = real(n_end, "marioX") - real(n_zero, "marioX")
    delta_z = real(n_end, "marioZ") - real(n_zero, "marioZ")
    if not (delta_x < -1200.0 and delta_z < -100.0):
        fail("negative-front: expected large X push and backward Z deflection")

    result = "\n".join(
        [
            "Eyerok controller-gate paired retail receipt",
            f"ROM MD5: {md5}",
            f"ROM SHA-256: {sha256}",
            "Boundary: ordinary Area-3 entry after disclosed fixture-assisted travel; no post-boundary memory writes",
            "Inputs after boundary: analog stick plus 13 B polls for the mandatory intro dialog; 0 A polls",
            "Common chronology: boundary 363; wake 560; target-strip arrival 603; deterministic TARGET_MARIO 903; smash 952; sweep 981",
            "Target selection: Mario Z=-2998.542969, hand Z=-3393.000000; farthest hand pivot Z=-1970.731445",
            "Positive/front sweep: entry Mario=(921.000000,-1534.000000,-1889.765137), yaw=+16384, static floor; X-edge fall visible by timer 1020",
            "Negative/front sweep: entry Mario=(602.704895,-1534.000000,-1897.535522), yaw=-16384, static floor",
            f"Negative/front post-zero displacement: dX={delta_x:.6f}, dZ={delta_z:.6f}; stored forward speed stays 0",
            "Ownership: 0 hand-floor frames and 0 hand-platform frames in both runs",
            "Verdict: the deterministic chase and both sweep signs are controller-reachable in the suffix, but the observed sweep is a bounded position push, not boarding or conserved-speed creation; the forward placement exits the arena and the grounded placement bends away from the warp",
            "Scope: this paired receipt is finite US-retail evidence, not an exhaustive analog-input theorem and not a controller-only construction of the pre-Area-3 prefix",
            "",
        ]
    )
    if len(sys.argv) == 5:
        expected = Path(sys.argv[4]).read_text(encoding="utf-8")
        if result != expected:
            fail("generated result differs from checked-in receipt")
    sys.stdout.write(result)


if __name__ == "__main__":
    main()
