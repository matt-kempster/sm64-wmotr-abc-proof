#!/usr/bin/env python3
"""Generate auditable US demo-stream and linker-order facts.

This bridge is needed because clightgen translation units do not contain ROM
bytes or final linker addresses. It accepts only the canonical US baserom and
checks the pinned source manifests/linker script before emitting compact Coq
receipts. The output is generated and must not be hand-edited.
"""

from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path


US_ROM_SHA1 = "9bef1128717f958171a4afac3ed78ee2bb4e86ce"
EXPECTED_TABLE = ["bitdw", "wf", "ccm", "bbh", "jrb", "hmc", "pss"]
DEMO_BUFFER_SIZE = 0x800


def fail(message: str) -> None:
    raise SystemExit(message)


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def strip_c_comments(text: str) -> str:
    return re.sub(r"/\*[\s\S]*?\*/", "", text)


def enabled_for_us(item: dict[str, object]) -> bool:
    guards = item.get("ifdef")
    return guards is None or "VERSION_US" in guards


def main() -> None:
    if len(sys.argv) != 3:
        fail("usage: generate-reachability-facts.py <sm64-root> <output.v>")

    source_root = Path(sys.argv[1]).resolve()
    output = Path(sys.argv[2])
    rom_path = source_root / "baserom.us.z64"
    require(rom_path.is_file(), f"canonical US baserom not found: {rom_path}")

    rom = rom_path.read_bytes()
    rom_sha1 = hashlib.sha1(rom).hexdigest()
    require(rom_sha1 == US_ROM_SHA1,
            f"unexpected US baserom SHA-1: {rom_sha1}")

    assets = json.loads((source_root / "assets.json").read_text())
    description = json.loads(strip_c_comments(
        (source_root / "assets" / "demo_data.json").read_text()))
    table = [item for item in description["table"] if enabled_for_us(item)]
    names = [item["demofile"] for item in table]
    require(names == EXPECTED_TABLE,
            f"unexpected US demo table order: {names}")

    receipts: list[tuple[str, int, int, int, str]] = []
    for item in table:
        name = item["demofile"]
        asset_name = f"assets/demos/{name}.bin"
        require(asset_name in assets, f"missing asset manifest entry: {asset_name}")
        size, locations = assets[asset_name]
        require("us" in locations and len(locations["us"]) >= 1,
                f"missing US ROM offset for {asset_name}")
        offset = locations["us"][0]
        data = rom[offset:offset + size]
        require(len(data) == size, f"short ROM slice for {name}")
        require(size >= 8 and size % 4 == 0,
                f"invalid DemoInput record size for {name}: {size}")

        record_offsets = range(4, size, 4)
        zero_offsets = [record_offset for record_offset in record_offsets
                        if data[record_offset] == 0]
        require(zero_offsets, f"demo {name} has no zero-timer record")
        first_zero = zero_offsets[0]
        require(first_zero == size - 4,
                f"demo {name} first zero timer is not the final record")
        require(all(data[record_offset] != 0
                    for record_offset in range(4, first_zero, 4)),
                f"demo {name} has an earlier zero timer")

        dma_size = size + int(item.get("extraSize", 0))
        require(size <= dma_size <= DEMO_BUFFER_SIZE,
                f"demo {name} DMA size exceeds 0x800: {dma_size}")
        receipts.append((name, size, dma_size, first_zero,
                         hashlib.sha256(data).hexdigest()))

    segments = strip_c_comments((source_root / "include" / "segments.h").read_text())
    require(re.search(r"^#define\s+SEG_START\s+0x8005C000\s*$",
                      segments, re.MULTILINE) is not None,
            "unexpected SEG_START")
    require(re.search(r"^#define\s+SEG_POOL_START\s+SEG_START\s*$",
                      segments, re.MULTILINE) is not None,
            "unexpected normal SEG_POOL_START")
    require(re.search(r"^#define\s+SEG_POOL_SIZE\s+0x165000\s*$",
                      segments, re.MULTILINE) is not None,
            "unexpected SEG_POOL_SIZE")
    require("#define SEG_POOL_END      (SEG_POOL_START + SEG_POOL_SIZE)" in segments,
            "unexpected SEG_POOL_END")
    require(re.search(r"^#define\s+SEG_BUFFERS\s+SEG_POOL_END\s*$",
                      segments, re.MULTILINE) is not None,
            "unexpected normal SEG_BUFFERS")

    linker = strip_c_comments((source_root / "sm64.ld").read_text())
    ordered_markers = [
        ". = SEG_BUFFERS;",
        "BEGIN_NOLOAD(buffers)",
        "END_NOLOAD(buffers)",
        "BEGIN_SEG(main, )",
        "END_SEG(main)",
        "BEGIN_NOLOAD(main)",
        "BUILD_DIR/src/game/level_update.o(.bss*);",
        "END_NOLOAD(main)",
    ]
    positions = [linker.find(marker) for marker in ordered_markers]
    require(all(position >= 0 for position in positions),
            f"missing linker marker: {list(zip(ordered_markers, positions))}")
    require(positions == sorted(positions),
            "main/linker markers are not in the expected order")

    level_update = (source_root / "src" / "game" / "level_update.c").read_text()
    require(re.search(r"struct\s+MarioState\s+gMarioStates\s*\[\s*1\s*\]\s*;",
                      level_update) is not None,
            "concrete gMarioStates[1] definition not found")
    main_source = (source_root / "src" / "game" / "main.c").read_text()
    require("void *start = (void *) SEG_POOL_START;" in main_source and
            "void *end = (void *) SEG_POOL_END;" in main_source and
            "main_pool_init(start, end);" in main_source,
            "alloc_pool no longer initializes the configured main-pool interval")

    pool_start = 0x8005C000
    pool_size = 0x165000
    pool_end = pool_start + pool_size
    max_pointer_offset = max(receipt[3] for receipt in receipts)

    lines = [
        "(* GENERATED FILE -- DO NOT EDIT.",
        "   Produced by pipeline/generate-reachability-facts.py.",
        f"   Canonical US baserom SHA-1: {rom_sha1}",
        "   Demo SHA-256 receipts:",
    ]
    lines.extend(f"     {name}: {digest}" for name, _, _, _, digest in receipts)
    lines.extend([
        " *)",
        "From Coq Require Import Bool Lia List ZArith.",
        "Import ListNotations.",
        "Local Open Scope Z_scope.",
        "",
        "Record demo_stream_receipt : Type := {",
        "  receipt_data_size : Z;",
        "  receipt_dma_size : Z;",
        "  receipt_terminal_offset : Z;",
        "  receipt_prefix_nonzero : bool",
        "}.",
        "",
        f"Definition us_main_pool_start : Z := {pool_start}.",
        f"Definition us_main_pool_size : Z := {pool_size}.",
        f"Definition us_main_pool_end : Z := {pool_end}.",
        f"Definition us_demo_buffer_size : Z := {DEMO_BUFFER_SIZE}.",
        "",
        "Inductive us_link_region : Type :=",
        "| Us_main_pool_region",
        "| Us_main_noload_region.",
        "",
        "Definition generated_demo_buffer_link_region : us_link_region :=",
        "  Us_main_pool_region.",
        "Definition generated_mario_states_link_region : us_link_region :=",
        "  Us_main_noload_region.",
        "",
        "Theorem generated_demo_and_mario_link_regions_distinct :",
        "  generated_demo_buffer_link_region <>",
        "  generated_mario_states_link_region.",
        "Proof. discriminate. Qed.",
        "",
        "Definition us_demo_stream_receipts : list demo_stream_receipt := [",
    ])
    for receipt_index, (_, size, dma_size, terminal_offset, _) in enumerate(receipts):
        separator = ";" if receipt_index + 1 < len(receipts) else ""
        lines.append(
            "  {| receipt_data_size := %d; receipt_dma_size := %d; "
            "receipt_terminal_offset := %d; receipt_prefix_nonzero := true |}%s"
            % (size, dma_size, terminal_offset, separator))
    lines.extend([
        "].",
        "",
        "Definition demo_stream_receipt_ok (receipt : demo_stream_receipt) : bool :=",
        "  Z.eqb (receipt_terminal_offset receipt + 4) (receipt_data_size receipt) &&",
        "  Z.leb (receipt_data_size receipt) (receipt_dma_size receipt) &&",
        "  Z.leb (receipt_dma_size receipt) us_demo_buffer_size &&",
        "  receipt_prefix_nonzero receipt.",
        "",
        "Definition generated_us_demo_stream_audit : bool :=",
        "  forallb demo_stream_receipt_ok us_demo_stream_receipts.",
        "",
        "Theorem generated_us_demo_stream_audit_holds :",
        "  generated_us_demo_stream_audit = true.",
        "Proof. vm_compute. reflexivity. Qed.",
        "",
        f"Definition max_us_demo_pointer_offset : Z := {max_pointer_offset}.",
        "",
        "Theorem max_us_demo_pointer_stays_in_buffer :",
        "  max_us_demo_pointer_offset + 4 <= us_demo_buffer_size.",
        "Proof. unfold max_us_demo_pointer_offset, us_demo_buffer_size; lia. Qed.",
        "",
        "Definition generated_linker_order_audit : bool := true.",
        "",
        "Theorem generated_linker_order_audit_holds :",
        "  generated_linker_order_audit = true.",
        "Proof. reflexivity. Qed.",
        "",
        "Theorem generated_pool_constants_consistent :",
        "  us_main_pool_start + us_main_pool_size = us_main_pool_end.",
        "Proof. vm_compute. reflexivity. Qed.",
        "",
    ])
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(lines))
    print(f"wrote {output}")


if __name__ == "__main__":
    main()
