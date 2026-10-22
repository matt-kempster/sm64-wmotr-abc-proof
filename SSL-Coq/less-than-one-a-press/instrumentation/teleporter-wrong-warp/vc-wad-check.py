#!/usr/bin/env python3
"""Verify and extract the user's Wii VC WAD from a ZIP; never executes contents.

Uses only a named ZIP and ignores non-WAD members. ZIP paths are never extracted.
TMD content digests are verified before any plaintext content file is written.
Digest consistency is not a cryptographic signature-chain verification.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import struct
import zipfile

from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

COMMON_KEY = bytes.fromhex("ebe42a225e8593e448d9c5457381aaf7")


def align(size: int, boundary: int = 64) -> int:
    return (size + boundary - 1) & -boundary


def sha(data: bytes) -> dict[str, str]:
    return {"sha1": hashlib.sha1(data).hexdigest(), "sha256": hashlib.sha256(data).hexdigest()}


def decrypt(key: bytes, iv: bytes, data: bytes) -> bytes:
    decrypter = Cipher(algorithms.AES(key), modes.CBC(iv)).decryptor()
    return decrypter.update(data) + decrypter.finalize()


def payload_offset(blob: bytes) -> int:
    sig = struct.unpack_from(">I", blob)[0]
    return {0x10000: 0x240, 0x10001: 0x140, 0x10002: 0x80}[sig]


def dol_sections(blob: bytes) -> list[dict]:
    if len(blob) < 0x100:
        return []
    offsets = struct.unpack_from(">18I", blob, 0)
    addresses = struct.unpack_from(">18I", blob, 0x48)
    sizes = struct.unpack_from(">18I", blob, 0x90)
    rows = []
    for i, (offset, address, size) in enumerate(zip(offsets, addresses, sizes)):
        if not size:
            continue
        if offset < 0x100 or offset + size > len(blob) or not 0x80000000 <= address < 0x94000000:
            return []
        rows.append({"kind": "text" if i < 7 else "data", "index": i,
                     "file_offset": offset, "address": address, "size": size})
    return rows if any(row["kind"] == "text" for row in rows) else []


def roms(blob: bytes) -> list[dict]:
    found = []
    start = 0
    while True:
        offset = blob.find(bytes.fromhex("80371240"), start)
        if offset == -1:
            break
        start = offset + 4
        if offset + 0x40 > len(blob):
            continue
        header = blob[offset:offset + 0x40]
        name = header[0x20:0x34].decode("ascii", errors="replace").strip("\0 ")
        if "SUPERMARIO" not in name.replace(" ", ""):
            continue
        for size in (0x800000, 0x1000000):
            if offset + size <= len(blob):
                image = blob[offset:offset + size]
                found.append({"offset": offset, "length": size, "name": name,
                              "country_byte": header[0x3E], "revision_byte": header[0x3F],
                              **sha(image)})
    return found


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("zip", type=Path)
    parser.add_argument("--output-root", type=Path, required=True)
    parser.add_argument("--receipt", type=Path, required=True)
    args = parser.parse_args()
    archive_bytes = args.zip.read_bytes()
    with zipfile.ZipFile(args.zip) as archive:
        members = [entry for entry in archive.infolist() if entry.filename.lower().endswith(".wad")]
        if len(members) != 1 or members[0].file_size > 128 * 1024 * 1024:
            raise SystemExit("expected exactly one WAD no larger than 128 MiB")
        wad = archive.read(members[0])
        member_name = members[0].filename
    header_size, wad_type, version, cert_size, crl_size, tik_size, tmd_size, data_size, footer_size = \
        struct.unpack_from(">IHH6I", wad)
    if header_size < 0x20 or header_size > 0x1000:
        raise SystemExit("invalid WAD header size")
    cursor = align(header_size)
    sections = {}
    for name, size in (("certificates", cert_size), ("crl", crl_size), ("ticket", tik_size),
                       ("tmd", tmd_size), ("data", data_size), ("footer", footer_size)):
        if cursor + size > len(wad):
            raise SystemExit(f"truncated WAD {name}")
        sections[name] = (cursor, size)
        cursor += align(size)
    ticket_offset, ticket_size = sections["ticket"]
    ticket = wad[ticket_offset:ticket_offset + ticket_size]
    tmd_offset, tmd_size = sections["tmd"]
    tmd = wad[tmd_offset:tmd_offset + tmd_size]
    tp = payload_offset(ticket)
    mp = payload_offset(tmd)
    title_id = ticket[tp + 0x9C:tp + 0xA4]
    if tmd[mp + 0x4C:mp + 0x54] != title_id:
        raise SystemExit("ticket and TMD title IDs disagree")
    declared_common_key_index = ticket[tp + 0xB1]
    # Some repacked/fakesigned WAD tickets carry a noncanonical index byte.
    # Use only the known standard Wii key; every decrypted content must still
    # match its TMD digest. Record the discrepancy instead of authenticating it.
    title_key = decrypt(COMMON_KEY, title_id + bytes(8), ticket[tp + 0x7F:tp + 0x8F])
    count = struct.unpack_from(">H", tmd, mp + 0x9E)[0]
    if count > 1024 or mp + 0xA4 + count * 36 > len(tmd):
        raise SystemExit("invalid TMD content count")
    out_root = args.output_root.resolve()
    title_dir = (out_root / title_id.hex()).resolve()
    title_dir.relative_to(out_root)
    cursor, data_size = sections["data"]
    data_end = cursor + data_size
    contents = []
    plaintexts = []
    for i in range(count):
        content_id, index, kind, size, digest = struct.unpack_from(">IHHQ20s", tmd, mp + 0xA4 + 36 * i)
        encrypted_size = align(size, 16)
        if cursor + encrypted_size > data_end:
            raise SystemExit(f"truncated encrypted content {index}")
        plaintext = decrypt(title_key, index.to_bytes(2, "big") + bytes(14), wad[cursor:cursor + encrypted_size])[:size]
        if hashlib.sha1(plaintext).digest() != digest:
            raise SystemExit(f"TMD SHA1 mismatch for content {index}")
        filename = f"{content_id:08x}.app"
        target = (title_dir / filename).resolve()
        target.relative_to(title_dir)
        row = {"content_id": content_id, "index": index, "type": kind, "size": size,
               "tmd_sha1_verified": True, **sha(plaintext), "path": str(target),
               "dol_sections": dol_sections(plaintext), "embedded_uncompressed_roms": roms(plaintext)}
        contents.append(row)
        plaintexts.append((target, plaintext))
        cursor += align(encrypted_size)
    # All checks pass before writing anything from the archive.
    title_dir.mkdir(parents=True, exist_ok=True)
    for target, plaintext in plaintexts:
        if target.exists() and target.read_bytes() != plaintext:
            raise SystemExit(f"refusing to overwrite different extracted file: {target}")
        target.write_bytes(plaintext)
    # The game ROM is uncompressed inside an authenticated content archive.
    # Write only an exact candidate with the standard N64 header and 8 MiB size.
    for row, (_, plaintext) in zip(contents, plaintexts):
        for candidate in row["embedded_uncompressed_roms"]:
            if candidate["length"] != 0x800000:
                continue
            target = (title_dir / f"rom-content-{row['index']}-offset-{candidate['offset']}.z64").resolve()
            target.relative_to(title_dir)
            image = plaintext[candidate["offset"]:candidate["offset"] + candidate["length"]]
            if target.exists() and target.read_bytes() != image:
                raise SystemExit(f"refusing to overwrite different ROM: {target}")
            target.write_bytes(image)
            candidate["path"] = str(target)
    report = {"schema": "teleporter-vc-wad-content-check-v1", "input_archive_name": args.zip.name,
              "archive_size": len(archive_bytes), "archive_hashes": sha(archive_bytes),
              "wad_member": member_name, "wad_size": len(wad), "wad_hashes": sha(wad),
              "title_id": title_id.hex(), "wad_type": wad_type, "wad_version": version,
              "ticket_declared_common_key_index": declared_common_key_index,
              "decryption_common_key_index_used": 0,
              "ticket_key_index_canonical": declared_common_key_index == 0,
              "signature_chain_checked": False, "all_tmd_content_sha1_verified": True,
              "ticket_hashes": sha(ticket), "tmd_hashes": sha(tmd), "contents": contents}
    args.receipt.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"title_id": report["title_id"], "contents": count,
                      "all_tmd_content_sha1_verified": True,
                      "dol_contents": [row["index"] for row in contents if row["dol_sections"]],
                      "roms": [rom for row in contents for rom in row["embedded_uncompressed_roms"]]}))


if __name__ == "__main__":
    main()
