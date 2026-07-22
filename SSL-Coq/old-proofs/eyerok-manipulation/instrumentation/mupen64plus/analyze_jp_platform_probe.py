#!/usr/bin/env python3
"""Validate and summarize the original-JP stale-platform fixture."""

from __future__ import annotations

import re
import sys
from pathlib import Path


JP_MD5 = "85D61F5525AF708C9F1E84DCE6DC10E9"
JP_CRC = "4EAA3D0E 74757C24"


def require(text: str, needle: str, label: str) -> None:
    if needle not in text:
        raise SystemExit(f"{label}: missing {needle!r}")


def unique_line(text: str, prefix: str, label: str) -> str:
    lines = [line for line in text.splitlines() if line.startswith(prefix)]
    if len(lines) != 1:
        raise SystemExit(f"{label}: expected one {prefix} line, found {len(lines)}")
    return lines[0]


def frame_lines(text: str, label: str) -> tuple[str, str]:
    lines = [line for line in text.splitlines() if line.startswith("JP_FRAME")]
    if len(lines) != 2:
        raise SystemExit(f"{label}: expected two JP_FRAME lines, found {len(lines)}")
    return lines[0], lines[1]


def main() -> None:
    if len(sys.argv) != 4:
        raise SystemExit(
            "usage: analyze_jp_platform_probe.py OUTPUT_DIR NATURAL_LOG INJECTED_LOG"
        )

    output_dir = Path(sys.argv[1])
    natural_text = Path(sys.argv[2]).read_text(encoding="utf-8", errors="replace")
    injected_text = Path(sys.argv[3]).read_text(encoding="utf-8", errors="replace")

    for label, text in (("natural", natural_text), ("injected", injected_text)):
        require(text, "Core: Goodname: Super Mario 64 (J) [!]", label)
        require(text, f"Core: MD5: {JP_MD5}", label)
        require(text, f"Core: CRC: {JP_CRC}", label)
        require(text, "activated cheat code 6: Have\\Level Select", label)

    natural_stage = unique_line(natural_text, "JP_STAGE", "natural")
    natural_seed = unique_line(natural_text, "JP_SEED", "natural")
    natural_before, natural_after = frame_lines(natural_text, "natural")
    natural_result = unique_line(natural_text, "JP_RESULT", "natural")

    injected_stage = unique_line(injected_text, "JP_STAGE", "injected")
    injected_seed = unique_line(injected_text, "JP_SEED", "injected")
    injected_before, injected_after = frame_lines(injected_text, "injected")
    injected_result = unique_line(injected_text, "JP_RESULT", "injected")

    for label, seed in (("natural", natural_seed), ("injected", injected_seed)):
        require(seed, "area=3", label)
        require(seed, "floorType=29", label)
        require(seed, "floorObject=00000000", label)
        require(seed, "timeStop=00000000", label)

    require(natural_seed, "platform=00000000", "natural")
    require(injected_seed, "platform=80340d18", "injected")
    require(injected_seed, "platformSlot=32,handSlot=32", "injected")
    require(injected_seed, "slotBehavior=800ed5d0", "injected")

    for label, after, result in (
        ("natural", natural_after, natural_result),
        ("injected", injected_after, injected_result),
    ):
        require(after, "area=2", label)
        require(after, "handSlot=32", label)
        require(after, "slotBehavior=800ead50", label)
        require(after, "slotVel=(0.000,0.000,0.000)", label)
        require(after, "slotAngleVel=(0,0,0)", label)
        require(after, "forwardVel=0.000", label)
        require(result, "delta=(0.000,0.000,0.000)", label)

    if not re.search(r"JP_FRAME,inject=1,timer=366,area=2,.*platform=00000000", injected_after):
        raise SystemExit("injected: saved platform was not refreshed after the Area 2 update")

    output_dir.mkdir(parents=True, exist_ok=True)
    trace_lines = [
        natural_stage,
        natural_seed,
        natural_before,
        natural_after,
        natural_result,
        injected_stage,
        injected_seed,
        injected_before,
        injected_after,
        injected_result,
    ]
    (output_dir / "jp_platform_trace.txt").write_text(
        "\n".join(trace_lines) + "\n", encoding="utf-8"
    )

    (output_dir / "jp_platform_summary.txt").write_text(
        "\n".join(
            [
                "Original-JP Eyerok platform-pointer fixture: validated",
                f"ROM MD5: {JP_MD5.lower()}",
                f"ROM CRC1/CRC2: {JP_CRC.lower()}",
                "natural seed: static Area-3 warp floor, null object owner, null gMarioPlatform",
                "injected seed: same static floor plus explicitly written hand-slot address 32",
                "Area-2 slot 32 payload: bhvWaterDroplet (virtual behavior 800ead50)",
                "replacement motion: zero linear X/Z velocity and zero angular velocity",
                "observed displacement: (0,0,0) in both cases",
                "observed forwardVel: 0 before and after",
                "scope: conditional address-retention fixture; not an authentic stale-floor trace",
                "scope: no Eyerok explosion was staged, so this is not a PPD execution",
                "scope: no controller/A-press reachability claim",
            ]
        )
        + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
