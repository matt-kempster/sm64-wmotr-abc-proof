#!/usr/bin/env python3
"""Extract pinned public SM64 NA VC assembly evidence; does not certify a binary.

This intentionally does not assume that a North American emulator is the one
used by PAL/Shindou, or turn instruction recognition into execution semantics.
The input is the public nim-ka/vc64-decomp Git checkout, not a console image.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

PIN = "e28658f6e520c01c6fca8c0aebe24902d9f82505"
UPSTREAM = "https://github.com/nim-ka/vc64-decomp"
LINE = re.compile(r"^/\* ([0-9A-F]{8}) ([0-9A-F]{8})  ((?:[0-9A-F]{2} ){3}[0-9A-F]{2}) \*/\s*(.*)$")
FRAGMENTS = [
    ("system_default_read8", "code_80007020/func_8000C560.s", 0x8000C560, 0x8000C5A0),
    ("system_default_read16", "code_80007020/func_8000C5A0.s", 0x8000C5A0, 0x8000C5E0),
    ("system_default_read32", "code_80007020/func_8000C5E0.s", 0x8000C5E0, 0x8000C620),
    ("system_register_read_callbacks", "code_8000CB6C/func_8000D0C0.s", 0x8000D2F0, 0x8000D320),
    ("cpu_set_device_get", "code_80033914/func_8003D750.s", 0x8003D750, 0x8003D768),
    ("cpu_get_xpc", "code_80033914/func_8003DEA4.s", 0x8003DEA4, 0x8003DF58),
    ("interpreter_pc_before_dispatch", "code_80033914/func_800365CC.s", 0x8003664C, 0x800366A0),
    ("interpreter_lbu", "code_80033914/func_800365CC.s", 0x80039FF4, 0x8003A054),
    ("interpreter_jal", "code_80033914/func_800365CC.s", 0x800374E4, 0x80037510),
    ("interpreter_tail", "code_80033914/func_800365CC.s", 0x8003A894, 0x8003A8F0),
    ("jit_specializer_address_guard", "code_80033914/func_8003ACB0.s", 0x8003AD58, 0x8003AD78),
    ("jit_specializer_interpreter_fallback", "code_80033914/func_8003ACB0.s", 0x8003B810, 0x8003B84C),
    ("jit_interpreter_link_initialization", "code_80033914/func_8003C774.s", 0x8003C7A4, 0x8003C7B8),
    ("jit_specializer_link_initialization", "code_80033914/func_8003C774.s", 0x8003C834, 0x8003C848),
    ("jit_lbu_ram_specializer_call", "code_8000CB6C/func_80010760.s", 0x8002AC1C, 0x8002AC60),
    ("interpreter_delay_marker_mode", "code_80033914/func_800365CC.s", 0x80036600, 0x8003662C),
    ("cpu_update_interrupt_and_pc_gate", "code_80033914/func_80033914.s", 0x80033BC4, 0x80033C40),
    ("wrapper_argument_spill_codegen", "code_80033914/func_8003C540.s", 0x8003C5BC, 0x8003C5F0),
    ("wrapper_call_and_return_codegen", "code_80033914/func_8003C540.s", 0x8003C5F0, 0x8003C644),
    ("wrapper_argument_reload_codegen", "code_80033914/func_8003C540.s", 0x8003C6F4, 0x8003C738),
    ("jit_delay_marker_before_ram_call", "code_8000CB6C/func_80010760.s", 0x8002AB44, 0x8002ABB4),
    ("jit_delay_marker_after_ram_call", "code_8000CB6C/func_80010760.s", 0x8002AC94, 0x8002AD0C),
    ("jit_jal_compiles_delay_first", "code_8000CB6C/func_80010760.s", 0x8001BA78, 0x8001BABC),
    ("wrapper_gpr_map_setup", "code_80033914/func_8003C540.s", 0x8003C584, 0x8003C5BC),
    ("system_device_table_setup", "code_80007020/func_8000A244.s", 0x8000A258, 0x8000A274),
    ("cpu_default_page_table_install", "code_80033914/func_8003D2D8.s", 0x8003D2EC, 0x8003D3EC),
]


def git(root: Path, *args: str) -> bytes:
    return subprocess.check_output(["git", "-C", str(root), *args])


def branch_target(pc: int, word: int) -> int:
    assert word >> 26 == 16
    displacement = word & 0xFFFC
    if displacement & 0x8000:
        displacement -= 0x10000
    return displacement if word & 2 else (pc + displacement) & 0xFFFFFFFF


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    source = args.source.resolve()
    actual_commit = git(source, "rev-parse", "HEAD").decode().strip()
    if actual_commit != PIN:
        raise SystemExit(f"wrong source revision: {actual_commit}; expected {PIN}")
    # Compare file bytes with Git's pinned blobs, not just the editable HEAD name.
    files: dict[str, dict] = {}
    fragments = []
    all_words = {}
    for name, suffix, start, end in FRAGMENTS:
        relative = f"asm/src/{suffix}"
        blob = git(source, "show", f"{PIN}:{relative}")
        # Git for Windows may check text out as CRLF. Only normalize line endings.
        contents = (source / relative).read_bytes().replace(b"\r\n", b"\n")
        if contents != blob.replace(b"\r\n", b"\n"):
            raise SystemExit(f"source differs from pinned blob: {relative}")
        files[relative] = {
            "git_blob": git(source, "rev-parse", f"{PIN}:{relative}").decode().strip(),
            "sha256_lf": hashlib.sha256(contents).hexdigest(),
            "url": f"{UPSTREAM}/blob/{PIN}/{relative}",
        }
        instructions = []
        for lineno, text in enumerate(contents.decode().splitlines(), 1):
            match = LINE.match(text)
            if match and start <= int(match[1], 16) < end:
                pc = int(match[1], 16)
                word = int(match[3].replace(" ", ""), 16)
                all_words[pc] = word
                instructions.append({"pc": pc, "word": word, "line": lineno, "assembly": match[4]})
        if [row["pc"] for row in instructions] != list(range(start, end, 4)):
            raise SystemExit(f"missing/noncontiguous source instructions in {name}")
        fragments.append({"name": name, "path": relative, "start": start, "end_exclusive": end,
                          "instructions": instructions})

    # Relevant exact decoded finite checks, no runtime claim.
    assert all_words[0x8003A038] == 0x2C030000  # cmpwi r3,0
    assert all_words[0x8003A03C] == 0x41820858  # beq interpreter tail
    assert branch_target(0x8003A03C, all_words[0x8003A03C]) == 0x8003A894
    assert all_words[0x8003A04C] == 0x9083004C  # guest rt low-word writeback
    assert all_words[0x80036650] == 0x38750004  # game PC + 4
    assert all_words[0x8003665C] == 0x907A0020  # CPU nPC before dispatch
    assert all_words[0x8000C578] == 0x98050000  # zero output temporary
    assert all_words[0x8000C590] == 0x38600000  # false return
    assert branch_target(0x8003AD6C, all_words[0x8003AD6C]) == 0x8003B810
    assert all_words[0x8003B834] == 0x80180B48  # interpreter-link source
    assert all_words[0x8003C7AC] == 0x389F0B48  # interpreter-link destination

    receipt = {
        "schema": "teleporter-vc-na-source-evidence-v1",
        "source_url": UPSTREAM,
        "commit": PIN,
        "declared_target": "SM64 North American Wii Virtual Console 00000001.app",
        "upstream_expected_app_sha1": "e0c57e067725c662fd603eb1ff8d777421e69b03",
        "binary_authenticated": False,
        "pal_shindou_equivalence_established": False,
        "scope": "Pinned public disassembly text and decoded finite instruction facts only",
        "instruction_count": sum(len(row["instructions"]) for row in fragments),
        "files": files,
        "fragments": fragments,
    }
    encoded = json.dumps(receipt, indent=2) + "\n"
    if args.output:
        args.output.write_text(encoded, encoding="utf-8")
        print(json.dumps({"output": str(args.output), "instruction_count": receipt["instruction_count"],
                          "commit": PIN, "binary_authenticated": False}))
    else:
        print(encoded, end="")


if __name__ == "__main__":
    main()
