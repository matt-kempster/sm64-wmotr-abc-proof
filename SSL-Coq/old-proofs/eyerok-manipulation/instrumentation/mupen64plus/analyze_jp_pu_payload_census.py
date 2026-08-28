#!/usr/bin/env python3
"""Validate the authenticated JP Area-2 allocation/Spindel PU census."""

from __future__ import annotations

import sys
from pathlib import Path


JP_MD5 = "85D61F5525AF708C9F1E84DCE6DC10E9"
JP_CRC = "4EAA3D0E 74757C24"
SPINDEL = (
    "behavior=800ebe00,behaviorWords=(00090000,11010011,2a000000),"
    "pos=(-2458.000000,2111.254395,-1425.000000),"
    "posBits=(c519a000,4503f412,c4b22000),"
    "vel=(0.000000,0.000000,5.000000),"
    "velBits=(00000000,00000000,40a00000),"
    "face=(256,0,0),angleVel=(256,0,0)"
)


def require(text: str, needle: str, label: str) -> None:
    if needle not in text:
        raise SystemExit(f"{label}: missing {needle!r}")


def unique_line(text: str, prefix: str, label: str) -> str:
    lines = [line for line in text.splitlines() if line.startswith(prefix)]
    if len(lines) != 1:
        raise SystemExit(f"{label}: expected one {prefix!r} line, found {len(lines)}")
    return lines[0]


def allocation_line(text: str, allocation: int, label: str) -> str:
    return unique_line(
        text, f"JP_ALLOCATION_PAYLOAD,allocation={allocation},", label
    )


def validate_rom(text: str, label: str) -> None:
    require(text, "Core: Goodname: Super Mario 64 (J) [!]", label)
    require(text, f"Core: MD5: {JP_MD5}", label)
    require(text, f"Core: CRC: {JP_CRC}", label)
    require(text, "activated cheat code 6: Have\\Level Select", label)
    if "JP_ALLOCATION_CENSUS_ERROR" in text:
        raise SystemExit(f"{label}: allocation census reported an error")
    if "JP_MACRO_SKIP_ERROR" in text:
        raise SystemExit(f"{label}: macro suppression injection reported an error")


def validate_case(
    text: str,
    label: str,
    suppressed: int,
    allocation_count: int,
    spindel_allocation: int,
) -> tuple[str, str]:
    validate_rom(text, label)
    if suppressed:
        injection = unique_line(text, "JP_MACRO_SKIP_INJECTION", label)
        require(injection, f"count={suppressed},address=801201b4", label)
    else:
        injection = "JP_MACRO_SKIP_INJECTION,count=0,address=none,scope=baseline"
        if "JP_MACRO_SKIP_INJECTION" in text:
            raise SystemExit(f"{label}: unexpected macro suppression injection")

    apply_entry = unique_line(text, "JP_FIRST_APPLY_ENTRY", label)
    require(apply_entry, f"allocCalls={allocation_count}", label)

    payloads = [
        line for line in text.splitlines()
        if line.startswith("JP_ALLOCATION_PAYLOAD,")
    ]
    if len(payloads) != allocation_count:
        raise SystemExit(
            f"{label}: expected {allocation_count} payloads, found {len(payloads)}"
        )

    spindel = allocation_line(text, spindel_allocation, label)
    require(spindel, SPINDEL, label)
    return injection, spindel


def main() -> None:
    if len(sys.argv) != 5:
        raise SystemExit(
            "usage: analyze_jp_pu_payload_census.py OUTPUT BASELINE SKIP10 SKIP11"
        )

    output = Path(sys.argv[1])
    baseline = Path(sys.argv[2]).read_text(encoding="utf-8", errors="replace")
    skip10 = Path(sys.argv[3]).read_text(encoding="utf-8", errors="replace")
    skip11 = Path(sys.argv[4]).read_text(encoding="utf-8", errors="replace")

    base_injection, base_spindel = validate_case(
        baseline, "baseline", 0, 83, 64
    )
    skip10_injection, skip10_spindel = validate_case(
        skip10, "skip10", 10, 73, 54
    )
    skip11_injection, skip11_spindel = validate_case(
        skip11, "skip11", 11, 72, 53
    )

    lines = [
        "Original-JP Area-2 PU payload census: validated",
        f"ROM MD5: {JP_MD5.lower()}",
        f"ROM CRC1/CRC2: {JP_CRC.lower()}",
        "",
        base_injection,
        base_spindel,
        skip10_injection,
        skip10_spindel,
        skip11_injection,
        skip11_spindel,
        "",
        "baseline: 83 allocations; Spindel is allocation 64",
        "10 suppressed macro records: 73 allocations; Spindel is allocation 54",
        "11 suppressed macro records: 72 allocations; Spindel is allocation 53",
        "Spindel first-apply payload: Z velocity 5; pitch and pitch velocity 256",
        "scope: the suppression writes are an allocation-identity fixture, not controller reachability",
        "scope: the fixture does not stage hand death or install a stale pointer",
    ]
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
