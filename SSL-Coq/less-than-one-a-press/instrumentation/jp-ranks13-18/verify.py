#!/usr/bin/env python3
"""Authenticate the local retail ROM and the probe's immutable readback ranges."""

import hashlib
import pathlib
import struct
import sys

EXPECTED_ROM_SHA256 = "9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317"
RANGES = (
    ("mario-interaction-copy-text", 0x8024C000, 0x8029C3B4, 0xB0B82BED),
    ("interaction-handlers", 0x8032C9F0, 0x8032CAE8, 0x9C829DF6),
    ("cutscene-dispatch", 0x803355B4, 0x803357A0, 0x998BBC13),
)


def main():
    if len(sys.argv) != 2:
        raise SystemExit("usage: verify.py /path/to/authentic/baserom.jp.z64")
    rom = pathlib.Path(sys.argv[1]).read_bytes()
    if hashlib.sha256(rom).hexdigest() != EXPECTED_ROM_SHA256:
        raise SystemExit("wrong retail ROM SHA-256; no execution performed")
    for name, start, end, expected in RANGES:
        payload = rom[start - 0x80245000:end - 0x80245000]
        if len(payload) != end - start:
            raise SystemExit(f"truncated range: {name}")
        value = 2166136261
        for word, in struct.iter_unpack(">I", payload):
            value = ((value ^ word) * 16777619) & 0xFFFFFFFF
        if value != expected:
            raise SystemExit(f"wrong word-FNV: {name}")
        print(f"AUTH_RANGE,name={name},start={start:08x},end={end:08x},"
              f"bytes={len(payload)},sha256={hashlib.sha256(payload).hexdigest()},"
              f"wordFNV={value:08x}")
    print("Authentic JP ROM and all three immutable ranges verified.")


if __name__ == "__main__":
    main()
