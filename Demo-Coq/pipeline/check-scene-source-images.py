#!/usr/bin/env python3
"""Check native AREA/TERRAIN fixtures against the authenticated script receipt.

The existing check-script-images.py must authenticate script-images.json first.
This helper checks its generated hashes, real command operands and placements;
it does not prove runtime activation, segmented conversion, or native execution.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re

PIN = "9921382a68bb0c865e5e45eb594d9c64db59b1af"
LEVELS = ((4, "bbh"), (5, "ccm"), (7, "hmc"), (12, "jrb"),
          (24, "wf"), (27, "pss"), (30, "bowser_1"))
BEGIN = "(* BEGIN CHECKED SCENE NATIVE FIXTURE *)"
END = "(* END CHECKED SCENE NATIVE FIXTURE *)"
TOKEN = re.compile(r"Init_int32 \(Int\.repr \(?(-?\d+)\)?\)|"
                   r"Init_addrof ([A-Za-z_0-9]+) \(Ptrofs\.repr (-?\d+)\)")


def project_root() -> Path:
    here = Path(__file__).resolve()
    for parent in here.parents:
        if (parent / "_CoqProject").is_file() and (parent / "generated").is_dir():
            return parent
    raise ValueError("could not locate Demo-Coq project")


def entry_words(source: str, level: str) -> list[tuple]:
    match = re.search(rf"Definition v_level_{level}_entry :=.*?gvar_init := (.*?)gvar_readonly",
                      source, re.S)
    if not match:
        raise ValueError(f"missing actual level_{level}_entry initializer")
    initializer = match.group(1)
    residue = TOKEN.sub("", initializer)
    if re.sub(r"\bnil\b|\s|::|[();]", "", residue):
        raise ValueError(f"unrecognized initializer datum in level_{level}_entry")
    return [("word", int(m[1]) & 0xffffffff) if m[1] is not None
            else ("relocation", m[2], int(m[3])) for m in TOKEN.finditer(initializer)]


def area_operands(words: list[tuple], level: str) -> list[dict]:
    result, active = [], None
    position = 0
    while position < len(words):
        datum = words[position]
        if datum[0] != "word":
            raise ValueError(f"relocation at command boundary in {level}")
        header = datum[1]
        opcode, length = header >> 24, (header >> 16) & 255
        if not (opcode <= 60 and length >= 4 and length % 4 == 0):
            raise ValueError(f"invalid command header in {level} at {4 * position}")
        count = length // 4
        if position + count > len(words):
            raise ValueError(f"truncated command in {level}")
        command = words[position:position + count]
        if opcode == 31:
            if active is not None or count != 2 or header & 255 or command[1][0] != "relocation":
                raise ValueError(f"malformed/nested AREA in {level}")
            active = {"index": (header >> 8) & 255, "area_offset": 4 * position,
                      "geometry": command[1]}
        elif opcode == 46:
            if active is None or "terrain" in active or header != 0x2e080000 or command[1][0] != "relocation":
                raise ValueError(f"malformed/mis-scoped TERRAIN in {level}")
            active.update(terrain=command[1], terrain_offset=4 * position)
        elif opcode == 32:
            if active is None or "terrain" not in active or header != 0x20040000:
                raise ValueError(f"malformed/mis-scoped END_AREA in {level}")
            result.append(active)
            active = None
        position += count
    if active is not None:
        raise ValueError(f"unterminated AREA in {level}")
    return result


def checked_fixture(root: Path) -> str:
    receipt = json.loads((root / "docs/notes/script-images.json").read_text(encoding="utf-8"))
    if receipt["source_revision"] != PIN:
        raise ValueError("script receipt has wrong pinned source revision")
    versions = {}
    for version in ("us", "jp"):
        placements, native_pairs = [], []
        units = receipt["versions"][version]["units"]
        for owner, level in LEVELS:
            unit = f"{level}_level_script"
            candidates = [item for item in units if item["unit"] == unit]
            if len(candidates) != 1:
                raise ValueError(f"missing/ambiguous {version} {unit} receipt")
            entry = candidates[0]
            path = root / "generated" / f"{version}_{unit}.v"
            data = path.read_bytes()
            if hashlib.sha256(data).hexdigest() != entry["generated_sha256"]:
                raise ValueError(f"generated source hash differs from receipt: {path.name}")
            words = entry_words(data.decode("utf-8"), level)
            initializer = entry["initializers"].get(f"level_{level}_entry")
            if initializer is None or initializer["size"] != 4 * len(words):
                raise ValueError(f"receipt entry size mismatch: {version} {level}")
            rows = area_operands(words, level)
            expected_indices = [1, 2] if level in ("ccm", "jrb") else [1]
            if [row["index"] for row in rows] != expected_indices:
                raise ValueError(f"selected entry area scope changed: {version} {level}")
            for row in rows:
                pair = []
                for kind in ("geometry", "terrain"):
                    _, symbol, offset = row[kind]
                    if symbol not in entry["relocations"]:
                        raise ValueError(f"missing actual {kind} operand placement: {version} {symbol}")
                    address = entry["relocations"][symbol]
                    if not 0 <= address < 2**32:
                        raise ValueError(f"placement outside native word: {symbol}")
                    placements.append((f"{version}_{unit}.{symbol}", address))
                    pair.append((address + offset) & 0xffffffff)
                native_pairs.append(tuple(pair))
        if len(native_pairs) != 9:
            raise ValueError("expected all nine selected areas")
        versions[version] = placements, native_pairs
    lines = [BEGIN,
             "(** Mechanically checked against docs/notes/script-images.json and",
             "    each actual generated AREA/TERRAIN operand. ROM/ELF authentication",
             "    precedes this check externally; no native execution is asserted. *)"]
    for version in ("us", "jp"):
        placements, _ = versions[version]
        lines.append(f"Definition scene_{version}_native_relocations : list (ident * int) :=")
        lines.append(" [" + ";\n  ".join(f"({symbol},Int.repr {address})" for symbol, address in placements) + "].")
    lines.extend([
        "Definition scene_source_native_operand (us : bool) (descriptor : scene_source_area) (is_geometry : bool) : option int :=",
        " demo_numeric_initializer_word",
        "   (if us then scene_us_native_relocations else scene_jp_native_relocations)",
        "   (if is_geometry then Init_addrof (scene_source_geo_symbol descriptor)",
        "      (scene_source_geo_relocation descriptor)",
        "    else Init_addrof (scene_source_terrain_symbol descriptor)",
        "      (scene_source_terrain_relocation descriptor))."])
    for version in ("us", "jp"):
        _, pairs = versions[version]
        lines.append(f"Definition scene_{version}_expected_native_operands : list (option int * option int) :=")
        lines.append(" [" + ";\n  ".join(f"(Some (Int.repr {geo}),Some (Int.repr {terrain}))"
                                       for geo, terrain in pairs) + "].")
    lines.extend([
        "Definition scene_source_native_operand_claim_us_jp : Prop :=",
        " map (fun descriptor => (scene_source_native_operand true descriptor true,",
        "   scene_source_native_operand true descriptor false)) scene_expected_source_areas =",
        "   scene_us_expected_native_operands /\\",
        " map (fun descriptor => (scene_source_native_operand false descriptor true,",
        "   scene_source_native_operand false descriptor false)) scene_expected_source_areas =",
        "   scene_jp_expected_native_operands.",
        "Theorem generated_scene_source_native_operands_us_jp : scene_source_native_operand_claim_us_jp.",
        "Proof. vm_compute. split; reflexivity. Qed.", END])
    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--write-coq", type=Path)
    group.add_argument("--check-coq", type=Path)
    args = parser.parse_args()
    fixture = checked_fixture(project_root())
    path = args.write_coq or args.check_coq
    text = path.read_text(encoding="utf-8")
    if BEGIN in text:
        start, past = text.index(BEGIN), text.index(END) + len(END)
        old = text[start:past].replace("\r\n", "\n") + "\n"
        replacement = text[:start] + fixture + text[past:].lstrip("\r\n")
    else:
        old = None
        replacement = text.rstrip() + "\n\n" + fixture
    if args.check_coq:
        if old != fixture:
            raise ValueError("native fixture differs from authenticated operand receipt")
        print("scene native operands: generated hashes, command operands and all 18 US/JP pairs checked")
    else:
        path.write_text(replacement, encoding="utf-8", newline="\n")
        print(f"wrote checked native fixture: {path}")


if __name__ == "__main__":
    main()
