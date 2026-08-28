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
    if len(sys.argv) != 5:
        raise SystemExit(
            "usage: analyze_jp_platform_probe.py OUTPUT_DIR NATURAL_LOG RIGHT_LOG LEFT_LOG"
        )

    output_dir = Path(sys.argv[1])
    natural_text = Path(sys.argv[2]).read_text(encoding="utf-8", errors="replace")
    right_text = Path(sys.argv[3]).read_text(encoding="utf-8", errors="replace")
    left_text = Path(sys.argv[4]).read_text(encoding="utf-8", errors="replace")

    cases = (("natural", natural_text), ("right", right_text), ("left", left_text))
    for label, text in cases:
        require(text, "Core: Goodname: Super Mario 64 (J) [!]", label)
        require(text, f"Core: MD5: {JP_MD5}", label)
        require(text, f"Core: CRC: {JP_CRC}", label)
        require(text, "activated cheat code 6: Have\\Level Select", label)

    natural_stage = unique_line(natural_text, "JP_STAGE", "natural")
    natural_seed = unique_line(natural_text, "JP_SEED", "natural")
    natural_before, natural_after = frame_lines(natural_text, "natural")
    natural_result = unique_line(natural_text, "JP_RESULT", "natural")

    right_stage = unique_line(right_text, "JP_STAGE", "right")
    right_seed = unique_line(right_text, "JP_SEED", "right")
    right_before, right_after = frame_lines(right_text, "right")
    right_result = unique_line(right_text, "JP_RESULT", "right")
    left_stage = unique_line(left_text, "JP_STAGE", "left")
    left_seed = unique_line(left_text, "JP_SEED", "left")
    left_before, left_after = frame_lines(left_text, "left")
    left_result = unique_line(left_text, "JP_RESULT", "left")

    for label, seed in (("natural", natural_seed), ("right", right_seed), ("left", left_seed)):
        require(seed, "area=3", label)
        require(seed, "floorType=29", label)
        require(seed, "floorObject=00000000", label)
        require(seed, "timeStop=00000000", label)

    require(natural_seed, "platform=00000000", "natural")
    require(right_seed, "side=1", "right")
    require(right_seed, "platform=80340d18", "right")
    require(right_seed, "platformSlot=32,handSlot=32", "right")
    require(right_seed, "slotBehavior=800ed5d0", "right")
    require(left_seed, "side=-1", "left")
    require(left_seed, "platform=80346e78", "left")
    require(left_seed, "platformSlot=73,handSlot=73", "left")
    require(left_seed, "slotBehavior=800ed5d0", "left")

    for label, after, result in (
        ("natural", natural_after, natural_result),
        ("right", right_after, right_result),
        ("left", left_after, left_result),
    ):
        require(after, "area=2", label)
        require(after, "slotBehavior=800ead50", label)
        require(after, "slotVel=(0.000,0.000,0.000)", label)
        require(after, "slotAngleVel=(0,0,0)", label)
        require(after, "forwardVel=0.000", label)
        require(result, "delta=(0.000,0.000,0.000)", label)

    require(right_after, "handSlot=32", "right")
    require(left_after, "handSlot=73", "left")
    for label, text, address, slot, reuse in (
        ("right", right_text, "80340d18", 32, 1),
        ("left", left_text, "80346e78", 73, 2),
    ):
        unload = unique_line(text, "JP_HAND_UNLOAD_ENTRY", label)
        reused = unique_line(text, "JP_HAND_REUSED", label)
        apply_entry = unique_line(text, "JP_FIRST_APPLY_ENTRY", label)
        apply_return = unique_line(text, "JP_FIRST_APPLY_RETURN", label)
        require(unload, f"hand={address},slot={slot}", label)
        require(reused, f"allocCalls={reuse},reuseAllocation={reuse}", label)
        require(reused, "behavior=800ead50", label)
        require(reused, "behaviorWords=(00080000,11010001,0a000000)", label)
        require(apply_entry, f"allocCalls=83,reuseAllocation={reuse}", label)
        require(apply_entry, f"platform={address},timeStop=00000000", label)
        require(apply_entry, "marioObject=80341db8", label)
        require(apply_entry, "behavior=800ead50", label)
        require(apply_entry, "behaviorWords=(00080000,11010001,0a000000)", label)
        require(apply_entry, "vel=(0.000000,0.000000,0.000000)", label)
        require(apply_entry, "angleVel=(0,0,0)", label)
        require(apply_return, "mario=(0.000000,346.080444,-1100.000000)", label)

    if not re.search(r"JP_FRAME,inject=1,side=1,timer=366,area=2,.*platform=00000000", right_after):
        raise SystemExit("right: saved platform was not refreshed after the Area 2 update")
    if not re.search(r"JP_FRAME,inject=1,side=-1,timer=366,area=2,.*platform=00000000", left_after):
        raise SystemExit("left: saved platform was not refreshed after the Area 2 update")

    output_dir.mkdir(parents=True, exist_ok=True)
    trace_lines = [
        natural_stage,
        natural_seed,
        natural_before,
        natural_after,
        natural_result,
        right_stage,
        right_seed,
        unique_line(right_text, "JP_HAND_UNLOAD_ENTRY", "right"),
        unique_line(right_text, "JP_HAND_REUSED", "right"),
        unique_line(right_text, "JP_FIRST_APPLY_ENTRY", "right"),
        unique_line(right_text, "JP_FIRST_APPLY_RETURN", "right"),
        right_before,
        right_after,
        right_result,
        left_stage,
        left_seed,
        unique_line(left_text, "JP_HAND_UNLOAD_ENTRY", "left"),
        unique_line(left_text, "JP_HAND_REUSED", "left"),
        unique_line(left_text, "JP_FIRST_APPLY_ENTRY", "left"),
        unique_line(left_text, "JP_FIRST_APPLY_RETURN", "left"),
        left_before,
        left_after,
        left_result,
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
                "injected seeds: same static floor plus explicitly written right-slot 32 or left-slot 73 address",
                "unload/reuse order: right hand becomes Area-2 allocation 1; left hand becomes allocation 2",
                "first Area-2 apply: 83 allocations complete, time stop clear, Mario object present",
                "both Area-2 payloads: bhvStaticObject (virtual behavior 800ead50; words 00080000,11010001,0a000000)",
                "both payloads: zero linear X/Z velocity and zero angular velocity",
                "observed displacement: (0,0,0) in natural, right-address, and left-address cases",
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
