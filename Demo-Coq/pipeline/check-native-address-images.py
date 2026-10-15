#!/usr/bin/env python3
"""Authenticate small US/JP native-address code/data fixtures, without emulation.

Only explicitly requested receipt/Coq paths are written. Existing script-image
parsers and the MIO0 decoder are reused. Full assets and
recorded inputs are never exported. This is not an ISA or runtime-activation proof.
"""
from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import struct
import subprocess
import sys

sys.dont_write_bytecode = True
PIN = "9921382a68bb0c865e5e45eb594d9c64db59b1af"
ROM_SHA256 = {
    "us": "17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91",
    "jp": "9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317",
}
ROUTINES = (("segmented_to_virtual", "main", 22),
            ("process_geo_layout", "engine", 58),
            ("load_area_terrain", "engine", 123))
GLOBAL_NAMES = ("sSegmentTable", "gGeoLayoutCommand", "GeoLayoutJumpTable")


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def source_digest(path):
    """Git core.autocrlf must not alter the meaning of source hash receipts."""
    return digest(path.read_text(encoding="utf-8").encode("utf-8"))


def project_root():
    for root in Path(__file__).resolve().parents:
        if (root / "_CoqProject").is_file() and (root / "generated").is_dir():
            return root
    raise ValueError("cannot locate Demo-Coq")


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def pinned(source, path):
    return subprocess.check_output(["git", "-c", f"safe.directory={source}",
                                    "-C", str(source), "show", f"{PIN}:{path}"])


def segment_bytes(symbols, rom, segment, address, size):
    start = symbols[f"_{segment}SegmentStart"]["address"]
    rom_start = symbols[f"_{segment}SegmentRomStart"]["address"]
    rom_end = symbols[f"_{segment}SegmentRomEnd"]["address"]
    relative = address - start
    offset = rom_start + relative
    require(relative >= 0 and size > 0 and offset + size <= rom_end,
            f"range outside {segment} segment")
    data = rom[offset:offset + size]
    require(len(data) == size, "truncated ROM range")
    return offset, data


def disassemble(elf, name, words, entry):
    output = subprocess.check_output(["mips-linux-gnu-objdump", "-d",
                                      "--disassemble=" + name, str(elf)], text=True)
    rows = []
    for pc, word, assembly in re.findall(
            r"^\s*([0-9a-f]+):\s+([0-9a-f]{8})\s+([^\n]+)$", output, re.M):
        rows.append((int(pc, 16), int(word, 16), assembly.strip()))
    require([row[:2] for row in rows] ==
            [(entry + 4 * i, word) for i, word in enumerate(words)],
            f"disassembly differs from complete authenticated {name} words")
    return "\n".join(f"{pc:08x}: {word:08x}  {assembly}" for pc, word, assembly in rows)


def scene_rows(root, auth, scene, runner, version, symbols, elf, rom, receipt):
    rows = []
    units = receipt["versions"][version]["units"]
    for owner, level in scene.LEVELS:
        unit = level + "_level_script"
        authenticated = auth.check_unit(version, unit, level, "level_" + level + "_entry",
                                        symbols, elf, rom)
        unit_receipt = next(row for row in units if row["unit"] == unit)
        metadata = json.loads(json.dumps(authenticated))
        for initializer in metadata["initializers"].values():
            initializer.pop("words")
        require(metadata == unit_receipt, f"script receipt changed: {version}/{level}")
        generated = root / f"generated/{version}_{unit}.v"
        operands = scene.area_operands(scene.entry_words(generated.read_text(), level), level)
        local_elf = auth.CACHE / f"build/{version}/levels/{level}/leveldata.elf"
        local_symbols = auth.elf_symbols(local_elf)
        compressed_start = symbols[f"_{level}_segment_7SegmentRomStart"]["address"]
        compressed_end = symbols[f"_{level}_segment_7SegmentRomEnd"]["address"]
        decompressed = runner.mio0(rom[compressed_start:compressed_end])
        for area in operands:
            row = {"owner": owner, "level": level, "area": area["index"],
                   "entry_symbol": "level_" + level + "_entry",
                   "area_command_byte_offset": area["area_offset"],
                   "terrain_command_byte_offset": area["terrain_offset"]}
            for kind in ("geometry", "terrain"):
                _, atom, displacement = area[kind]
                name = atom.removeprefix("_")
                symbol = symbols[name]
                require(authenticated["relocations"][atom] == symbol["address"],
                        "actual script relocation/symbol mismatch")
                address, size = symbol["address"], symbol["size"]
                require(displacement == 0, "selected asset relocation is not zero")
                if kind == "geometry":
                    offset, data = segment_bytes(symbols, rom, level, address, size)
                    require(data == symbol["data"], "geometry ELF/ROM bytes differ")
                    extra = {"rom_offset": offset, "first_opcode_u8": data[0]}
                else:
                    local = local_symbols[name]
                    require(local["address"] == address and local["size"] == size,
                            "main/local terrain symbol differs")
                    require(address >> 24 == 7 and size >= 2, "bad terrain range")
                    relative = address - 0x07000000
                    data = decompressed[relative:relative + size]
                    require(len(data) == size and data == local["data"],
                            "terrain ELF/decompressed canonical ROM bytes differ")
                    extra = {"compressed_segment_rom_start": compressed_start,
                             "compressed_segment_rom_end": compressed_end,
                             "decompressed_segment_offset": relative,
                             "first_halfword_u16_be": int.from_bytes(data[:2], "big"),
                             "local_elf_sha256": digest(local_elf.read_bytes())}
                row[kind] = {"symbol": name, "native_operand": address,
                             "size": size, "asset_sha256": digest(data), **extra}
            rows.append(row)
    require(len(rows) == 9, "expected nine source-owned areas")
    return rows


def fixture(root):
    auth_path = root / "pipeline/check-script-images.py"
    scene_path = root / "pipeline/check-scene-source-images.py"
    runner_path = root / "instrumentation/demo-desync-search/run.py"
    auth = module("native_fixture_script_images", auth_path)
    scene = module("native_fixture_scene_images", scene_path)
    runner = module("native_fixture_demo_runner", runner_path)
    require(auth.PIN == scene.PIN == runner.PIN == PIN, "helper source pin differs")
    receipt = json.loads((root / "docs/notes/script-images.json").read_text())
    require(receipt["source_revision"] == PIN, "wrong source receipt revision")
    result = {
        "scope": "authenticated finite native code and first asset values; no ISA execution, source refinement or runtime activation proof",
        "source_revision": PIN,
        "source_hash_normalization": "UTF-8 source text with universal newlines normalized to LF",
        "checker_sha256": source_digest(Path(__file__)),
        "helper_sha256": {path.name: source_digest(path)
                          for path in (auth_path, scene_path, runner_path)},
        "pinned_c_source_sha256": {path: digest(pinned(auth.SOURCE, path)) for path in
                                   ("src/game/memory.c", "src/engine/geo_layout.c",
                                    "src/engine/surface_load.c")},
        "objdump_version": subprocess.check_output(["mips-linux-gnu-objdump", "--version"],
                                                    text=True).splitlines()[0],
        "versions": {},
    }
    listings = {}
    for version in ("us", "jp"):
        elf = auth.CACHE / f"build/{version}/sm64.{version}.elf"
        rom_path = auth.SOURCE / f"baserom.{version}.z64"
        rom = rom_path.read_bytes()
        expected_sha1 = pinned(auth.SOURCE, f"sm64.{version}.sha1").decode().split()[0]
        require(hashlib.sha1(rom).hexdigest() == expected_sha1 and
                digest(rom) == ROM_SHA256[version], "canonical retail ROM hash differs")
        require(rom == (auth.CACHE / f"build/{version}/sm64.{version}.z64").read_bytes(),
                "matching ELF build ROM differs from canonical retail ROM")
        symbols = auth.elf_symbols(elf)
        version_row = {"rom_sha1": expected_sha1, "rom_sha256": digest(rom),
                       "elf_sha256": digest(elf.read_bytes()), "routines": {},
                       "globals": {}, "first_geometry_read": {
                           "call_segmented_pc": 0x8037e100, "opcode_lbu_pc": 0x8037e150,
                           "opcode_lbu_word": 0x916c0000, "dispatch_lw_pc": 0x8037e15c,
                           "dispatch_jalr_pc": 0x8037e160, "dispatch_jalr_word": 0x0320f809,
                           "base_gpr": 11, "destination_gpr": 12, "immediate": 0},
                       "first_terrain_read": {
                           "stack_data_save_pc": 0x803833c4,
                           "stack_data_save_word": 0xafa5002c,
                           "clear_static_surfaces_call_pc": 0x803833f0,
                           "clear_static_surfaces_call_word": 0x0c0e0974,
                           "stack_data_pointer_lw_pc": 0x803833f8,
                           "stack_data_pointer_lw_word": 0x8fae002c,
                           "terrain_lh_pc": 0x803833fc, "terrain_lh_word": 0x85cf0000,
                           "base_gpr": 14, "destination_gpr": 15, "immediate": 0}}
        for name, segment, word_count in ROUTINES:
            symbol = symbols[name]
            address, size = symbol["address"], symbol["size"]
            require(size == 4 * word_count and address % 4 == 0, "routine size/alignment changed")
            offset, data = segment_bytes(symbols, rom, segment, address, size)
            require(data == symbol["data"], f"retail code differs from ELF: {version}/{name}")
            words = list(struct.unpack(f">{word_count}I", data))
            version_row["routines"][name] = {"segment": segment, "entry": address,
                                              "rom_offset": offset, "size": size,
                                              "sha256": digest(data), "words": words}
            listings[f"{version}-{name}.disassembly.txt"] = disassemble(elf, name, words, address) + "\n"
        process = version_row["routines"]["process_geo_layout"]
        require(process["entry"] == 0x8037e0b4, "caller address changed")
        for pc_name, word_name in (("opcode_lbu_pc", "opcode_lbu_word"),
                                   ("dispatch_jalr_pc", "dispatch_jalr_word")):
            site = version_row["first_geometry_read"]
            require(process["words"][(site[pc_name] - process["entry"]) // 4] == site[word_name],
                    "actual first-load/dispatch instruction differs")
        terrain = version_row["routines"]["load_area_terrain"]
        require(terrain["entry"] == 0x803833b8, "terrain routine address changed")
        for stem in ("stack_data_save", "clear_static_surfaces_call",
                     "stack_data_pointer_lw", "terrain_lh"):
            site = version_row["first_terrain_read"]
            require(terrain["words"][(site[stem + "_pc"] - terrain["entry"]) // 4]
                    == site[stem + "_word"], "actual terrain setup/load instruction differs")
        for site, stem, opcode in ((version_row["first_geometry_read"], "opcode_lbu", 0x24),
                                   (version_row["first_terrain_read"], "terrain_lh", 0x21)):
            word = site[stem + "_word"]
            require((word >> 26, (word >> 21) & 31, (word >> 16) & 31, word & 65535)
                    == (opcode, site["base_gpr"], site["destination_gpr"], site["immediate"]),
                    "load instruction field decode differs")
        for name in GLOBAL_NAMES:
            symbol = symbols[name]
            version_row["globals"][name] = {"address": symbol["address"], "size": symbol["size"]}
        table = symbols["GeoLayoutJumpTable"]
        table_offset, table_data = segment_bytes(symbols, rom, "engine", table["address"], table["size"])
        require(table_data == table["data"] and table["size"] == 132, "dispatch table differs")
        version_row["globals"]["GeoLayoutJumpTable"].update(
            rom_offset=table_offset, sha256=digest(table_data),
            words=list(struct.unpack(">33I", table_data)))
        version_row["selected_scenes"] = scene_rows(root, auth, scene, runner, version,
                                                   symbols, elf, rom, receipt)
        result["versions"][version] = version_row
    return result, listings


def emit_coq(result):
    lines = [
        "(** Mechanically generated native-address scalar fixtures.",
        "    Full US/JP retail routine/asset authentication happens externally.",
        "    This file asserts no native execution, runtime activation, or",
        "    Clight/native refinement. Do not edit the finite transcription. *)",
        "From Coq Require Import Bool List ZArith.",
        "From compcert Require Import AST.",
        "Import ListNotations.",
        "Local Open Scope Z_scope.",
        "",
    ]
    for label, key, prefix, chunk in (("geometry", "first_geometry_read", "opcode_lbu", "Mint8unsigned"),
                                      ("terrain", "first_terrain_read", "terrain_lh", "Mint16signed")):
        site = result["versions"]["us"][key]
        require(site == result["versions"]["jp"][key], "version load-site metadata differs")
        values = {"pc": site[prefix + "_pc"], "word": site[prefix + "_word"],
                  "base_gpr": site["base_gpr"], "destination_gpr": site["destination_gpr"],
                  "displacement": site["immediate"]}
        for field, value in values.items():
            lines.append(f"Definition demo_native_{label}_load_{field} : Z := {value}.")
        lines.append(f"Definition demo_native_{label}_load_chunk : memory_chunk := {chunk}.")
        lines.append("")
    lines.extend([
        "Record demo_native_scene_first_values : Type := DemoNativeSceneFirstValues {",
        " demo_native_scene_owner : Z;",
        " demo_native_scene_index : Z;",
        " demo_native_scene_geo_operand : Z;",
        " demo_native_scene_geo_first_byte : Z;",
        " demo_native_scene_terrain_operand : Z;",
        " demo_native_scene_terrain_first_halfword : Z",
        "}.",
        "",
    ])
    for version in ("us", "jp"):
        rows = result["versions"][version]["selected_scenes"]
        lines.append(f"Definition demo_native_scene_first_values_{version} : list demo_native_scene_first_values :=")
        values = []
        for row in rows:
            geo, terrain = row["geometry"], row["terrain"]
            values.append("DemoNativeSceneFirstValues " + " ".join(str(v) for v in
                          (row["owner"], row["area"], geo["native_operand"], geo["first_opcode_u8"],
                           terrain["native_operand"], terrain["first_halfword_u16_be"])))
        lines.append(" [" + ";\n  ".join(values) + "].")
        lines.append("")
    lines.extend([
        "Definition demo_native_scene_first_values_version (us : bool) : list demo_native_scene_first_values :=",
        " if us then demo_native_scene_first_values_us else demo_native_scene_first_values_jp.",
        "Fixpoint demo_native_scene_first_values_lookup (owner index : Z)",
        " (rows : list demo_native_scene_first_values) : option demo_native_scene_first_values :=",
        " match rows with",
        " | [] => None",
        " | row :: rest =>",
        "   if (demo_native_scene_owner row =? owner) && (demo_native_scene_index row =? index)",
        "   then Some row else demo_native_scene_first_values_lookup owner index rest",
        " end.",
        "Definition demo_native_scene_first_values_for (us : bool) (owner index : Z)",
        " : option demo_native_scene_first_values :=",
        " demo_native_scene_first_values_lookup owner index (demo_native_scene_first_values_version us).",
        "",
        "Definition demo_native_load_encoding (word opcode base target displacement : Z) : bool :=",
        " (Z.shiftr word 26 =? opcode) && (Z.land (Z.shiftr word 21) 31 =? base) &&",
        " (Z.land (Z.shiftr word 16) 31 =? target) && (Z.land word 65535 =? displacement).",
        "",
        "Definition demo_native_first_scalar_fixture_claim : Prop :=",
        " demo_native_geometry_load_chunk = Mint8unsigned /\\",
        " demo_native_terrain_load_chunk = Mint16signed /\\",
        " demo_native_load_encoding demo_native_geometry_load_word 36",
        "   demo_native_geometry_load_base_gpr demo_native_geometry_load_destination_gpr",
        "   demo_native_geometry_load_displacement = true /\\",
        " demo_native_load_encoding demo_native_terrain_load_word 33",
        "   demo_native_terrain_load_base_gpr demo_native_terrain_load_destination_gpr",
        "   demo_native_terrain_load_displacement = true /\\",
        " (forall us, length (demo_native_scene_first_values_version us) = 9%nat) /\\",
        " (forall us, Forall (fun row => demo_native_scene_geo_first_byte row = 8 /\\",
        "   demo_native_scene_terrain_first_halfword row = 64)",
        "   (demo_native_scene_first_values_version us)).",
        "Theorem generated_demo_native_first_scalar_fixture_checked : demo_native_first_scalar_fixture_claim.",
        "Proof. split; [reflexivity|]. split; [reflexivity|].",
        " split; [reflexivity|]. split; [reflexivity|].",
        " split; intros []; vm_compute; repeat constructor. Qed.",
    ])
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    coq_action = parser.add_mutually_exclusive_group()
    coq_action.add_argument("--write-coq", type=Path)
    coq_action.add_argument("--check-coq", type=Path)
    receipt_action = parser.add_mutually_exclusive_group()
    receipt_action.add_argument("--write-receipt", type=Path)
    receipt_action.add_argument("--check-receipt", type=Path)
    args = parser.parse_args()
    if not any(vars(args).values()):
        parser.error("select --write-coq/--check-coq or --write-receipt/--check-receipt")
    result, listings = fixture(project_root())
    receipt = json.dumps(result, indent=2) + "\n"
    if args.write_receipt:
        args.write_receipt.write_text(receipt, encoding="utf-8", newline="\n")
    if args.check_receipt:
        require(args.check_receipt.read_text(encoding="utf-8") == receipt, "native receipt differs")
    coq = emit_coq(result)
    if args.write_coq:
        args.write_coq.write_text(coq, encoding="utf-8", newline="\n")
    if args.check_coq:
        require(args.check_coq.read_text(encoding="utf-8") == coq, "Coq native fixture differs")
    print("Native fixture: US/JP 22-word helper, 58-word geometry/123-word terrain callers,33-entry dispatch,")
    print("and all nine geometry opcode bytes/terrain halfwords authenticated per version.")
    print("No ISA execution, source/native refinement, or runtime activation is asserted.")


if __name__ == "__main__":
    main()
