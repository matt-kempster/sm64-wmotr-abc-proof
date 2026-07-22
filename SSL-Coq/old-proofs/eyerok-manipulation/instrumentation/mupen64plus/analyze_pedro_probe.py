#!/usr/bin/env python3
"""Extract and validate two US-ROM sleep-Pedro collision fixtures."""

from __future__ import annotations

import csv
import io
import sys
from pathlib import Path


HEADER = [
    "timer", "label", "speed", "area", "boss", "bossAction", "mAction",
    "mX", "mY", "mZ", "mVelX", "mVelY", "mVelZ", "mForwardVel",
    "floor", "floorObject", "floorHeight", "ceil", "ceilObject",
    "ceilHeight", "platform", "handAction", "handTimer", "handX", "handY",
    "handZ", "collision", "cancelledXZ", "pedroY",
]


def fail(message: str) -> None:
    raise SystemExit(f"Pedro probe analysis failed: {message}")


def rows(path: Path) -> list[dict[str, str]]:
    text = path.read_text(encoding="utf-8", errors="replace")
    payload = "\n".join(line[4:] for line in text.splitlines() if line.startswith("CSV,"))
    parsed = list(csv.DictReader(io.StringIO(payload), fieldnames=HEADER))
    if not parsed:
        fail(f"no CSV rows in {path}")
    return parsed


def f(row: dict[str, str], name: str) -> float:
    return float(row[name])


def i(row: dict[str, str], name: str) -> int:
    return int(row[name], 16) if name in {"floorObject", "ceilObject"} else int(row[name])


def main() -> None:
    if len(sys.argv) != 4:
        fail("usage: analyze_pedro_probe.py OUTPUT_DIR ordinary.log tunnel.log")
    output = Path(sys.argv[1])
    ordinary = rows(Path(sys.argv[2]))
    tunnel = rows(Path(sys.argv[3]))
    output.mkdir(parents=True, exist_ok=True)

    ordinary_witnesses = [row for row in ordinary if row["cancelledXZ"] == "1" and row["pedroY"] == "1"]
    tunnel_witnesses = [row for row in tunnel if row["cancelledXZ"] == "1" and row["pedroY"] == "1"]
    if ordinary_witnesses:
        fail("ordinary 48-speed fixture unexpectedly crossed the wall band")
    if not tunnel_witnesses:
        fail("424-speed wall-tunnel fixture did not reach the Pedro landing")

    witness = tunnel_witnesses[0]
    if i(witness, "bossAction") != 0 or i(witness, "handAction") != 0:
        fail("witness did not keep boss and hand in SLEEP")
    if abs(f(witness, "mY") - (-1459.0)) > 0.01:
        fail("witness did not land at the transformed lower-thumb height")
    if abs(f(witness, "floorHeight") - (-1534.0)) > 0.01:
        fail("Pedro branch unexpectedly updated the stored arena floor height")
    if i(witness, "floorObject") != 0:
        fail("Pedro branch unexpectedly replaced the stored static floor")

    selected = ordinary[:8] + tunnel[:8]
    with (output / "pedro_entry_trace.csv").open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=HEADER)
        writer.writeheader()
        writer.writerows(selected)

    (output / "pedro_entry_summary.txt").write_text(
        "\n".join([
            "rom: authenticated US Super Mario 64",
            "rom-md5: 20b854b239203baf6c961b850a4a51a2",
            "rom-sha256: 17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91",
            "rom-header-crc: 635a2bff8b022326",
            "ordinary-speed: 48",
            "ordinary-pedro-witnesses: 0",
            "wall-tunnel-speed: 424",
            f"wall-tunnel-witness-timer: {witness['timer']}",
            f"witness-position: ({witness['mX']}, {witness['mY']}, {witness['mZ']})",
            f"witness-forward-speed: {witness['mForwardVel']}",
            f"witness-stored-floor-height: {witness['floorHeight']}",
            f"witness-floor-object: {witness['floorObject']}",
            "witness-boss-action: SLEEP",
            "witness-hand-action: SLEEP",
            "result: the outer radius-50 wall blocks ordinary speed 48; preloaded speed 424 crosses the >100-unit rejection band and reaches the Pedro branch",
            "scope: state-injected collision-semantic fixtures, not controller-only speed-424 reachability, an A-press classification, or a sustained speed-grinding trace",
            "",
        ]),
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
