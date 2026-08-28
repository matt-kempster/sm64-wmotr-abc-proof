#!/usr/bin/env python3
"""Validate the ordinary-scale effective payload suffix in a JP census log."""

from __future__ import annotations

import re
import sys
from collections import defaultdict
from pathlib import Path


JP_MD5 = "85D61F5525AF708C9F1E84DCE6DC10E9"
JP_CRC = "4EAA3D0E 74757C24"
BEHAVIOR_NAMES = {
    "800e8c2c": "bhvOneCoin",
    "800ec1fc": "bhvHiddenStar",
    "800ec13c": "bhvStar",
    "800ebfa4": "bhvSandSoundLoop",
    "800ebe60": "bhvPyramidElevator",
    "800ebe30": "bhvSSLMovingPyramidWall",
    "800ebe00": "bhvSpindel",
    "800ed55c": "bhvHorizontalGrindel",
    "800e8e78": "bhvGrindel",
    "800e8464": "bhvPoleGrabbing",
    "800e8a7c": "bhvFadingWarp",
    "800eb264": "bhvAirborneWarp",
    "800ebe98": "bhvPyramidElevatorTrajectoryMarkerBall",
}
PAYLOAD_RE = re.compile(
    r"^JP_ALLOCATION_PAYLOAD,allocation=(?P<allocation>\d+),"
    r"slot=(?P<slot>\d+),address=(?P<address>[0-9a-f]+),active=(?P<active>\d+),"
    r"behavior=(?P<behavior>[0-9a-f]+),behaviorWords=\((?P<words>[^)]*)\),"
    r"pos=\((?P<pos>[^)]*)\),posBits=\((?P<pos_bits>[^)]*)\),"
    r"vel=\((?P<vel>[^)]*)\),velBits=\((?P<vel_bits>[^)]*)\),"
    r"face=\((?P<face>[^)]*)\),angleVel=\((?P<angle_vel>[^)]*)\)$"
)


def require(text: str, needle: str, label: str) -> None:
    if needle not in text:
        raise SystemExit(f"{label}: missing {needle!r}")


def triples(text: str, cast):
    values = tuple(cast(value) for value in text.split(","))
    if len(values) != 3:
        raise SystemExit(f"expected triple, got {text!r}")
    return values


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: analyze_jp_ordinary_payload_census.py OUTPUT RAW_LOG")

    output = Path(sys.argv[1])
    raw = Path(sys.argv[2]).read_text(encoding="utf-8", errors="replace")
    require(raw, "Core: Goodname: Super Mario 64 (J) [!]", "ROM identity")
    require(raw, f"Core: MD5: {JP_MD5}", "ROM identity")
    require(raw, f"Core: CRC: {JP_CRC}", "ROM identity")
    require(raw, "activated cheat code 6: Have\\Level Select", "start boundary")
    require(raw, "JP_FIRST_APPLY_ENTRY,side=1", "first apply")
    require(raw, "allocCalls=83", "baseline allocation count")
    if "JP_ALLOCATION_CENSUS_ERROR" in raw or "JP_MACRO_SKIP_ERROR" in raw:
        raise SystemExit("probe reported an allocation-census error")

    payloads = {}
    for line in raw.splitlines():
        match = PAYLOAD_RE.match(line)
        if match is None:
            continue
        record = match.groupdict()
        allocation = int(record["allocation"])
        if allocation in payloads:
            raise SystemExit(f"duplicate allocation {allocation}")
        record["vel_tuple"] = triples(record["vel"], float)
        record["angle_tuple"] = triples(record["angle_vel"], int)
        payloads[allocation] = record

    if sorted(payloads) != list(range(1, 84)):
        raise SystemExit(
            f"expected allocations 1..83, got {min(payloads, default=0)}.."
            f"{max(payloads, default=0)} ({len(payloads)} records)"
        )

    suffix = list(range(53, 84))
    nonidentity = []
    by_behavior = defaultdict(list)
    for allocation in suffix:
        record = payloads[allocation]
        vx, _vy, vz = record["vel_tuple"]
        pitch, yaw, roll = record["angle_tuple"]
        # apply_platform_displacement adds only X/Z linear velocity.  It uses
        # all three angular velocities when at least one is nonzero.
        if vx != 0.0 or vz != 0.0 or (pitch, yaw, roll) != (0, 0, 0):
            nonidentity.append(allocation)
        by_behavior[record["behavior"]].append(allocation)

    if nonidentity != [64]:
        raise SystemExit(f"unexpected effective nonidentity suffix: {nonidentity}")

    spindel = payloads[64]
    if spindel["behavior"] != "800ebe00":
        raise SystemExit("allocation 64 is not bhvSpindel")
    if spindel["words"] != "00090000,11010011,2a000000":
        raise SystemExit("Spindel behavior words changed")
    if spindel["pos_bits"] != "c519a000,4503f412,c4b22000":
        raise SystemExit("Spindel position bits changed")
    if spindel["vel_bits"] != "00000000,00000000,40a00000":
        raise SystemExit("Spindel velocity bits changed")
    if spindel["face"] != "256,0,0" or spindel["angle_vel"] != "256,0,0":
        raise SystemExit("Spindel pitch fields changed")

    vertical_only = [
        allocation
        for allocation in suffix
        if payloads[allocation]["vel_tuple"][1] != 0.0
        and allocation not in nonidentity
    ]
    if vertical_only != [60, 61, 62, 63]:
        raise SystemExit(f"unexpected vertical-only payloads: {vertical_only}")

    behavior_groups = []
    for behavior, allocations in by_behavior.items():
        if len(allocations) == 1:
            allocation_text = str(allocations[0])
        else:
            allocation_text = f"{allocations[0]}-{allocations[-1]}"
        if behavior not in BEHAVIOR_NAMES:
            raise SystemExit(f"unidentified behavior address {behavior}")
        behavior_groups.append(
            f"  {allocation_text}: {BEHAVIOR_NAMES[behavior]} ({behavior})"
        )

    lines = [
        "Original-JP ordinary stale-hand payload suffix: validated",
        f"ROM MD5: {JP_MD5.lower()}",
        f"ROM CRC1/CRC2: {JP_CRC.lower()}",
        "start boundary: level select",
        "baseline Area-2 allocations at first apply: 83",
        "death-order stale destinations: allocation 53 or 54",
        "suppression-only candidate suffix: baseline allocations 53..83, or no reuse",
        "effective nonidentity candidates: allocation 64 only (bhvSpindel)",
        "vertical-only object velocities ignored by platform apply: allocations 60..63",
        "Spindel effective fields: vel=(0,0,5), face=(256,0,0), angleVel=(256,0,0)",
        "all other suffix entries: velX=velZ=0 and angleVel=(0,0,0)",
        "behavior-address groups:",
        *behavior_groups,
        "scope: this is an authenticated baseline suffix and deletion-only over-approximation",
        "scope: it does not prove a controller-reached suppression set or cached-floor/hand mismatch",
        "scope: a no-reuse freed-slot payload and state-changing suppression require separate proofs",
    ]
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
