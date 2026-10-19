#!/usr/bin/env python3
"""Authenticate finite Shindou instruction windows used by TeleporterShindouReset.

This verifies bytes and elementary instruction fields. It does not execute SM64,
model the Virtual Console failed-load behavior, prove a reachable wrong warp, or
establish that a stock teleporter ID survives object-slot reuse before latching.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import struct
from pathlib import Path

ROM_SHA1 = "3f319ae697533a255a1003d09202379d78d5a2e0"
ROM_SHA256 = "f8807b5e28f1b1a31c5d3675d23ece73f949ccb553dcbb07972666a1e76adfa2"
ROM_TO_VA = 0x80248000
# Complete routines where named as such; the delayed-warp entry is a suffix.
RANGES = {
    "sh_clear_platform_words": (0x802B1950, 0x802B195C, "complete clear_mario_platform"),
    "sh_apply_platform_words": (0x802B1900, 0x802B1950, "complete apply_mario_platform_displacement"),
    "sh_spawn_objects_words": (0x8028ECF0, 0x8028EE9C, "complete spawn_objects_from_info"),
    "sh_load_mario_area_words": (0x80273BBC, 0x80273C28, "complete load_mario_area"),
    "sh_init_mario_words": (0x80255A48, 0x80255D84, "complete init_mario"),
    "sh_init_after_warp_words": (0x8024D25C, 0x8024D630, "complete init_mario_after_warp"),
    "sh_area_get_warp_node_words": (0x80273898, 0x802738D8, "complete area_get_warp_node"),
    "sh_delayed_warp_suffix_words": (0x8024E3FC, 0x8024E42C, "default delayed-warp suffix through initiate_warp call and delay slot"),
}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rom", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    rom = args.rom.read_bytes()
    if len(rom) != 8 * 1024 * 1024:
        raise SystemExit("refusing ROM with unexpected length")
    if hashlib.sha1(rom).hexdigest() != ROM_SHA1 or hashlib.sha256(rom).hexdigest() != ROM_SHA256:
        raise SystemExit("refusing non-authentic or non-Shindou ROM")
    if struct.unpack_from(">I", rom, 8)[0] != 0x80249000:
        raise SystemExit("unexpected Shindou ROM entry point")
    project = Path(__file__).resolve().parents[2]
    coq_file = project / "proofs" / "TeleporterShindouReset.v"
    coq_text = coq_file.read_text(encoding="utf-8")
    checked = []
    for name, (start, end, scope) in RANGES.items():
        match = re.search(r"Definition\s+" + re.escape(name) + r"\s*:\s*list Z\s*:=\s*\[([^\]]*)\]\s*\.", coq_text)
        if match is None:
            raise SystemExit(f"missing Coq literal manifest: {name}")
        words = [int(word.strip()) for word in match.group(1).split(";") if word.strip()]
        actual = rom[start - ROM_TO_VA:end - ROM_TO_VA]
        expected = b"".join(struct.pack(">I", word) for word in words)
        if len(actual) != end - start or actual != expected:
            raise SystemExit(f"Coq literal words differ from authenticated ROM: {name}")
        checked.append({
            "coq_definition": name, "scope": scope,
            "start_pc": f"0x{start:08X}", "end_pc_exclusive": f"0x{end:08X}",
            "rom_offset": f"0x{start - ROM_TO_VA:X}",
            "word_count": len(words), "sha256": hashlib.sha256(actual).hexdigest(),
        })
    report = {
        "verdict": "authenticated finite Shindou instruction certificate; global VC gameplay claim open",
        "rom_sha1": ROM_SHA1, "rom_sha256": ROM_SHA256,
        "rom_entry_point": "0x80249000", "rom_offset_to_va": "0x80248000",
        "coq_module": "LessThanOneAPress.Proofs.TeleporterShindouReset",
        "total_checked_words": sum(row["word_count"] for row in checked),
        "ranges": checked,
        "remaining_boundary": [
            "No execution or authentication of a Wii Virtual Console emulator image.",
            "No formal failed-load/no-register-write transition is established.",
            "No complete MIPS execution or end-to-end destination-load theorem is established.",
            "A latched source ID is not proved equal to the original teleporter ID after pre-latch area change and slot reuse.",
            "PAL ROM is unavailable locally and is outside this certificate.",
        ],
    }
    encoded = json.dumps(report, indent=2) + "\n"
    if args.output:
        args.output.write_text(encoded, encoding="utf-8")
    else:
        print(encoded, end="")


if __name__ == "__main__":
    main()
