#!/usr/bin/env python3
"""Bind the source windows to the user's digest-verified JP/EU VC executables.

Checks an entire supplied executable's SHA1/SHA256 and reads its DOL section
map, then records exact instruction words at the identified regional addresses.
Only windows reported byte-identical are asserted equal to the pinned NA source.
Any relocation differences remain explicit; no whole-emulator equivalence claim.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import struct

IMAGES = {
    "japan": ("000100014e41414a", "00000001.app", 0,
              "0e59d95268ecdf213807f7126d7c7a24875cfb1b",
              "691beac0386ba835cc1b07c2bba02d039a34566f39dadd0dc11d81ef3efed5b8"),
    "europe": ("000100014e414150", "00000008.app", 0x10,
               "4d65a6aabcc9d902df6a84ad53e3c7619a85b4fb",
               "23c04451fec6845c3551596725847049ec750076e004b76c318638779f51ae00"),
}
EXPECTED_GPR_MAP = [10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
                    0x110, 0x111, 0x112, 0x113, 0x114, 0x115, 0x116, 0x117,
                    27, 28, 29, 30, 0x11C, 31, 0x11E, 0x11F]


def read_dol(blob: bytes) -> list[tuple[int, int, int]]:
    offsets = struct.unpack_from(">18I", blob)
    addresses = struct.unpack_from(">18I", blob, 0x48)
    sizes = struct.unpack_from(">18I", blob, 0x90)
    return [(offset, address, size) for offset, address, size in zip(offsets, addresses, sizes) if size]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("images", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    here = Path(__file__).resolve().parent
    source = json.loads((here / "vc-na-source-evidence.json").read_text())
    coq_path = here.parents[1] / "proofs" / "TeleporterVcFailedLoad.v"
    coq_text = coq_path.read_text(encoding="utf-8")
    map_match = re.search(r"Definition\s+vc_wrapper_register_map\s*:\s*list Z\s*:=\s*\[([^\]]*)\]\s*\.", coq_text)
    if map_match is None:
        raise SystemExit("missing Coq vc_wrapper_register_map")
    coq_gpr_map = [int(word.strip()) for word in map_match[1].split(";") if word.strip()]
    if coq_gpr_map != EXPECTED_GPR_MAP:
        raise SystemExit("Coq wrapper register map differs from authenticated expected map")
    coq_windows = {}
    for name, start, end in (("vc_read8_words", 0x8000C560, 0x8000C5A0),
                             ("vc_lbu_words", 0x80039FF4, 0x8003A054),
                             ("vc_interpreter_pc_words", 0x8003664C, 0x80036660),
                             ("vc_read8_return_words", 0x8000C58C, 0x8000C5A0)):
        match = re.search(r"Definition\s+" + re.escape(name) + r"\s*:\s*list Z\s*:=\s*\[([^\]]*)\]\s*\.", coq_text)
        if match is None:
            raise SystemExit(f"missing Coq literal definition: {name}")
        words = [int(word.strip()) for word in match[1].split(";") if word.strip()]
        if len(words) * 4 != end - start:
            raise SystemExit(f"wrong Coq literal window length: {name}")
        coq_windows[name] = (start, end, words)
    report = {"schema": "teleporter-vc-supplied-image-windows-v1",
              "source_commit": source["commit"], "signature_chain_verified": False,
              "scope": "Exact supplied emulator hashes, DOL mappings, and instruction windows; no global execution theorem",
              "regions": {}}
    for region, (title, filename, shift, expected_sha1, expected_sha256) in IMAGES.items():
        wad_receipt = json.loads((here / f"vc-{region}-wad.json").read_text())
        content = next(row for row in wad_receipt["contents"] if row["index"] == 1)
        blob = (args.images / title / filename).read_bytes()
        sha1 = hashlib.sha1(blob).hexdigest()
        sha256 = hashlib.sha256(blob).hexdigest()
        if sha1 != expected_sha1 or (expected_sha256 and sha256 != expected_sha256):
            raise SystemExit(f"unexpected {region} emulator hash")
        if not content["tmd_sha1_verified"] or sha1 != content["sha1"] or sha256 != content["sha256"]:
            raise SystemExit(f"{region} executable differs from WAD content receipt")
        sections = read_dol(blob)

        def offset_for_pc(pc: int) -> int:
            for offset, address, size in sections:
                if address <= pc < address + size:
                    return offset + pc - address
            raise SystemExit(f"unmapped PC {pc:#x}")

        def word_at(pc: int) -> int:
            return struct.unpack_from(">I", blob, offset_for_pc(pc))[0]

        def lis_addi_address(lis_pc: int, addi_pc: int, register: int) -> int:
            high = word_at(lis_pc + shift)
            low = word_at(addi_pc + shift)
            if high >> 26 != 15 or (high >> 21) & 31 != register or (high >> 16) & 31:
                raise SystemExit("unexpected table LUI encoding")
            if low >> 26 != 14 or (low >> 21) & 31 != register or (low >> 16) & 31 != register:
                raise SystemExit("unexpected table ADDI encoding")
            signed_low = (low & 65535) - (65536 if low & 32768 else 0)
            return (((high & 65535) << 16) + signed_low) & 0xFFFFFFFF

        gpr_map_address = lis_addi_address(0x8003C58C, 0x8003C59C, 4)
        gpr_map = [word_at(gpr_map_address + 4 * i) for i in range(32)]
        if gpr_map != EXPECTED_GPR_MAP:
            raise SystemExit(f"{region} guest-register map mismatch")
        if gpr_map != coq_gpr_map:
            raise SystemExit(f"{region} Coq wrapper register map mismatch")
        system_table_address = lis_addi_address(0x8000A25C, 0x8000A26C, 31)
        default_record_address = system_table_address + 7 * 48
        default_record = [word_at(default_record_address + 4 * i) for i in range(12)]
        if default_record[0] != 0 or default_record[2:6] != [1, 0, 0, 0xFFFFFFFF]:
            raise SystemExit(f"{region} default-device range mismatch")

        fragments = []
        for fragment in source["fragments"]:
            start = fragment["start"] + shift
            rows = []
            for src in fragment["instructions"]:
                pc = src["pc"] + shift
                offset = offset_for_pc(pc)
                word = struct.unpack_from(">I", blob, offset)[0]
                rows.append({"pc": pc, "file_offset": offset, "word": word,
                             "source_pc": src["pc"], "source_word": src["word"],
                             "byte_identical_to_source": word == src["word"]})
            fragments.append({"name": fragment["name"], "start": start,
                              "end_exclusive": fragment["end_exclusive"] + shift,
                              "byte_identical_to_source": all(row["byte_identical_to_source"] for row in rows),
                              "instructions": rows})
        for name in ("system_default_read8", "system_default_read16", "system_default_read32",
                     "cpu_set_device_get", "interpreter_lbu", "interpreter_jal",
                     "jit_specializer_address_guard", "jit_specializer_interpreter_fallback",
                     "jit_lbu_ram_specializer_call"):
            if not next(row for row in fragments if row["name"] == name)["byte_identical_to_source"]:
                raise SystemExit(f"{region} {name} differs from pinned source")
        # The PC+4 and nPC-store instructions themselves are exact in each image.
        for source_pc, expected_word in ((0x80036650, 0x38750004), (0x8003665C, 0x907A0020)):
            if struct.unpack_from(">I", blob, offset_for_pc(source_pc + shift))[0] != expected_word:
                raise SystemExit(f"{region} PC-advance instruction mismatch")
        checked_coq = []
        for name, (start, end, words) in coq_windows.items():
            actual_words = [struct.unpack_from(">I", blob, offset_for_pc(pc + shift))[0]
                            for pc in range(start, end, 4)]
            if actual_words != words:
                raise SystemExit(f"{region} Coq instruction literal mismatch: {name}")
            checked_coq.append({"definition": name, "start": start + shift,
                                "end_exclusive": end + shift, "word_count": len(words)})
        checked_coq.append({"definition": "vc_wrapper_register_map", "start": gpr_map_address,
                            "end_exclusive": gpr_map_address + 128, "word_count": 32})
        report["regions"][region] = {"title_id": title, "emulator_content_id": content["content_id"],
                                     "emulator_content_index": 1, "sha1": sha1, "sha256": sha256,
                                     "all_tmd_contents_verified": wad_receipt["all_tmd_content_sha1_verified"],
                                     "text_address_shift_from_na": shift,
                                     "instruction_count": sum(len(row["instructions"]) for row in fragments),
                                     "checked_coq_definitions": checked_coq,
                                     "guest_register_map": {"address": gpr_map_address, "words": gpr_map,
                                                            "argument_spill_slots": [0x6C, 0x74, 0x7C, 0x84],
                                                            "argument_host_registers": [15, 16, 17, 18]},
                                     "default_device_table": {"table_address": system_table_address,
                                                              "record_address": default_record_address,
                                                              "record_words": default_record},
                                     "fragments": fragments}
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({region: {"sha1": rows["sha1"], "instruction_count": rows["instruction_count"],
                              "identical_fragments": [f["name"] for f in rows["fragments"] if f["byte_identical_to_source"]]}
                      for region, rows in report["regions"].items()}))


if __name__ == "__main__":
    main()
