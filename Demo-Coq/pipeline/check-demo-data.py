#!/usr/bin/env python3
"""Authenticate ROM demo metadata without copying ROMs or recorded inputs.

This is a finite data check outside Coq, not a DMA/execution refinement.
Source manifests are read from the pin, never from modified working files.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

PIN = "9921382a68bb0c865e5e45eb594d9c64db59b1af"
ROOT = Path(__file__).resolve().parents[1]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=ROOT.parent.parent / "reference-sm64-decomp")
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    source = args.source.resolve()

    def pinned(name: str) -> bytes:
        return subprocess.check_output(
            ["git", "-c", f"safe.directory={source}", "-C", str(source),
             "show", f"{PIN}:{name}"])

    manifest_bytes = pinned("assets.json")
    table_bytes = pinned("assets/demo_data.json")
    assets = json.loads(manifest_bytes)
    table = json.loads(re.sub(r"/\*[\s\S]*?\*/", "", table_bytes.decode()))
    result = {"scope": "authenticated finite ROM data; not an execution theorem",
              "source_revision": PIN,
              "assets_manifest_sha256": hashlib.sha256(manifest_bytes).hexdigest(),
              "demo_table_sha256": hashlib.sha256(table_bytes).hexdigest(),
              "versions": {}}
    for version in ("us", "jp"):
        rom = (source / f"baserom.{version}.z64").read_bytes()
        expected = pinned(f"sm64.{version}.sha1").decode().split()[0]
        digest = hashlib.sha1(rom).hexdigest()
        require(digest == expected, f"wrong {version} ROM SHA-1")
        selected = [entry for entry in table["table"]
                    if "ifdef" not in entry or f"VERSION_{version.upper()}" in entry["ifdef"]]
        receipts = []
        for entry in selected:
            name = entry["demofile"]
            size, locations = assets[f"assets/demos/{name}.bin"]
            offset = locations[version][0]
            data = rom[offset:offset + size]
            require(len(data) == size and size >= 8 and size % 4 == 0,
                    f"invalid {version}/{name} slice")
            terminals = [i for i in range(4, size, 4) if data[i] == 0]
            require(terminals and terminals[0] == size - 4,
                    f"{version}/{name} has unexpected termination")
            dma_size = size + int(entry.get("extraSize", 0))
            require(size <= dma_size <= 0x800, f"{version}/{name} exceeds demo buffer")
            header = int.from_bytes(data[:1], "big", signed=True)
            require(1 <= header <= 38, f"invalid demo header {header}")
            receipts.append({"stream": name, "header_level": header,
                             "data_size": size, "dma_size": dma_size,
                             "terminal_offset": size - 4,
                             "recorded_frames": sum(data[4:size - 4:4]),
                             "sha256": hashlib.sha256(data).hexdigest()})
        levels = [r["header_level"] for r in receipts]
        require(len(set(levels)) == len(levels), f"duplicate {version} demo level header")
        result["versions"][version] = {"rom_sha1": digest, "streams": receipts}
    destination = ROOT / "docs/notes/demo-data.json"
    text = json.dumps(result, indent=2) + "\n"
    if args.write:
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_text(text, encoding="utf-8", newline="\n")
    else:
        require(destination.read_text(encoding="utf-8") == text,
                "demo data receipt differs; inspect before regenerating with --write")
    print("Authenticated US/JP ROMs: 7/6 selected demos, distinct headers, terminal records, buffer bounds OK.")


if __name__ == "__main__":
    main()
