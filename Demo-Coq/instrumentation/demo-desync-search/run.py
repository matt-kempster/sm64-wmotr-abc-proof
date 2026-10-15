#!/usr/bin/env python3
"""Read-only retail-ROM demo observations, starting at boot with fresh save data.

Uses an existing authenticated matching ELF only for symbol locations and code
hashes. The running ROM is reference-sm64-decomp/baserom.VERSION.z64. Neither
game-memory writes nor save-state loading nor emulator cheats are used.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import struct
import subprocess

HERE = Path(__file__).resolve().parent
DEMO = HERE.parents[1]
PROOF = DEMO.parent
SOURCE = PROOF.parent / "reference-sm64-decomp"
PIN = "9921382a68bb0c865e5e45eb594d9c64db59b1af"
CACHE = PROOF / "Pedro-Coq/instrumentation/ttc-runtime-snapshot/build/retail-map-9921382"
SYMBOLS = {
    "A_GLOBAL_TIMER": "gGlobalTimer", "A_CURR_LEVEL": "gCurrLevelNum",
    "A_CURRENT_AREA": "gCurrentArea", "A_MARIO_OBJECT": "gMarioObject",
    "A_CURR_DEMO_INPUT": "gCurrDemoInput", "A_DEMO_INDEX": "gDemoInputListID",
    "A_DEMO_INPUTS_BUF": "gDemoInputsBuf", "A_PLAY_MODE": "sCurrPlayMode",
    "PC_RUN_DEMO_INPUTS": "run_demo_inputs", "PC_UPDATE_LEVEL": "update_level",
}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def fnv(values):
    result = 2166136261
    for value in values:
        result = ((result ^ value) * 16777619) & 0xffffffff
    return result


def pinned(path):
    return subprocess.check_output(["git", "-c", f"safe.directory={SOURCE}",
                                    "-C", str(SOURCE), "show", f"{PIN}:{path}"])


def elf_symbols(path):
    """Read standard big-endian ELF32 symbols and their actual section bytes."""
    data = path.read_bytes()
    if data[:6] != b"\x7fELF\x01\x02":
        raise RuntimeError("not big-endian ELF32")
    shoff = struct.unpack_from(">I", data, 32)[0]
    shsize, shcount = struct.unpack_from(">HH", data, 46)
    sections = [struct.unpack_from(">10I", data, shoff+i*shsize) for i in range(shcount)]
    symbols = {}
    for section in sections:
        if section[1] != 2:
            continue
        strings_section = sections[section[6]]
        strings = data[strings_section[4]:strings_section[4]+strings_section[5]]
        for offset in range(section[4], section[4]+section[5], section[9]):
            name, value, size, info, other, index = struct.unpack_from(">IIIBBH", data, offset)
            name = strings[name:strings.find(b"\0", name)].decode()
            content = None
            if index < len(sections) and index != 0:
                target = sections[index]
                start = target[4]+value-target[3]
                content = data[start:start+size]
            if name:
                symbols[name] = {"address": value, "size": size, "data": content}
    return symbols


def mio0(data):
    if data[:4] != b"MIO0":
        raise RuntimeError("expected MIO0 compressed terrain segment")
    size, comp, raw = struct.unpack_from(">III", data, 4)
    out = bytearray()
    flags_pos = 16
    while len(out) < size:
        flags = data[flags_pos]
        flags_pos += 1
        for bit in range(7, -1, -1):
            if len(out) == size:
                break
            if flags & (1 << bit):
                out.append(data[raw])
                raw += 1
            else:
                value = int.from_bytes(data[comp:comp+2], "big")
                comp += 2
                count, distance = (value >> 12)+3, (value & 0xfff)+1
                for _ in range(count):
                    out.append(out[-distance])
    if len(out) != size:
        raise RuntimeError("MIO0 output size differs")
    return bytes(out)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("version", choices=("us", "jp"))
    parser.add_argument("name")
    parser.add_argument("--video-frames", type=int, default=14500)
    parser.add_argument("--timeout-seconds", type=int, default=360)
    parser.add_argument("--start-at", type=int,
                        help="ordinary Start press this many frames after each demo's first update")
    parser.add_argument("--start-frames", type=int, default=1)
    args = parser.parse_args()
    if not args.name.isidentifier() or not 100 <= args.video_frames <= 30000:
        parser.error("invalid trial name or frame limit")
    if args.start_at is not None and not 0 <= args.start_at <= 10000:
        parser.error("start-at must be in [0,10000]")
    if not 1 <= args.start_frames <= 10000 or not 30 <= args.timeout_seconds <= 1800:
        parser.error("invalid controller duration or timeout")
    rom = SOURCE / f"baserom.{args.version}.z64"
    elf = CACHE / f"build/{args.version}/sm64.{args.version}.elf"
    cache_rom = CACHE / f"build/{args.version}/sm64.{args.version}.z64"
    expected_sha1 = pinned(f"sm64.{args.version}.sha1").decode().split()[0]
    raw_rom = rom.read_bytes()
    if hashlib.sha1(raw_rom).hexdigest() != expected_sha1 or sha(rom) != sha(cache_rom):
        raise RuntimeError("retail ROM authentication failed")
    names = set(SYMBOLS.values())
    symbols = {}
    for line in subprocess.check_output(["mips-linux-gnu-nm", "-n", str(elf)], text=True).splitlines():
        fields = line.split()
        if len(fields) == 3 and fields[2] in names:
            if fields[2] in symbols:
                raise RuntimeError("ambiguous symbol: " + fields[2])
            symbols[fields[2]] = int(fields[0], 16)
    if names != set(symbols):
        raise RuntimeError("missing symbols: " + str(names - set(symbols)))
    header = f'#define VERSION_NAME "{args.version.upper()}"\n'
    header += ''.join(f'#define {macro} 0x{symbols[name]:08x}u\n' for macro, name in SYMBOLS.items())
    main_symbols = elf_symbols(elf)
    code_receipts = []
    for routine in ("run_demo_inputs", "update_level"):
        disassembly = subprocess.check_output(["mips-linux-gnu-objdump", "-d", f"--disassemble={routine}", str(elf)], text=True)
        words = [(int(a, 16), int(w, 16)) for a, w in re.findall(r"^\s*([0-9a-f]+):\s+([0-9a-f]{8})\s", disassembly, re.M)]
        if not words or [p for p, _ in words] != list(range(symbols[routine], words[-1][0] + 4, 4)):
            raise RuntimeError("noncontiguous routine: " + routine)
        routine_bytes = b''.join(word.to_bytes(4, "big") for _, word in words)
        rom_offset = main_symbols["_mainSegmentRomStart"]["address"] + words[0][0] - main_symbols["_mainSegmentStart"]["address"]
        if raw_rom[rom_offset:rom_offset+len(routine_bytes)] != routine_bytes:
            raise RuntimeError("observed MIPS routine does not match authenticated retail ROM")
        code_receipts.append({"routine": routine, "start": words[0][0], "count": len(words),
                              "hash": fnv(w for _, w in words), "rom_offset": rom_offset,
                              "sha256": hashlib.sha256(routine_bytes).hexdigest()})
    header += 'struct code { unsigned start, count, hash; };\nstatic const struct code codes[] = {\n'
    header += ''.join(f'{{0x{x["start"]:08x}u,{x["count"]}u,0x{x["hash"]:08x}u}},\n' for x in code_receipts)
    header += '};\n#define CODE_COUNT (sizeof(codes)/sizeof(codes[0]))\n'
    assets = json.loads(pinned("assets.json"))
    table = json.loads(re.sub(r"/\*[\s\S]*?\*/", "", pinned("assets/demo_data.json").decode()))
    stream_receipts = []
    stream_data = {}
    level_rows = re.findall(r"^(STUB_LEVEL|DEFINE_LEVEL)\((.*)\)\s*$", pinned("levels/level_defines.h").decode(), re.M)
    level_folders = {}
    for number, (kind, row) in enumerate(level_rows, 1):
        values = [value.strip() for value in row.split(",")]
        if kind == "DEFINE_LEVEL":
            level_folders[number] = {"enum": values[1], "folder": values[3]}
    for entry in table["table"]:
        if "ifdef" in entry and f"VERSION_{args.version.upper()}" not in entry["ifdef"]:
            continue
        name = entry["demofile"]
        size, offsets = assets[f"assets/demos/{name}.bin"]
        offset = offsets[args.version][0]
        data = raw_rom[offset:offset+size]
        stream_data[name] = data
        stream_receipts.append({"name": name, "size": size, "level": data[0],
                                "level_enum": level_folders[data[0]]["enum"],
                                "level_folder": level_folders[data[0]]["folder"],
                                "hash": fnv(data), "sha256": hashlib.sha256(data).hexdigest()})
    # These derived byte arrays remain in the ignored trial build directory.
    # Reports expose hashes/metadata only; initial stream matching is byte-exact.
    for name, data in stream_data.items():
        header += f'static const unsigned char expected_{name}[] = {{' + ','.join(map(str, data)) + '};\n'
    header += 'struct stream { const char *name; unsigned level, size, hash; const unsigned char *data; };\nstatic const struct stream streams[] = {\n'
    header += ''.join(f'{{"{s["name"]}",{s["level"]}u,{s["size"]}u,0x{s["hash"]:08x}u,expected_{s["name"]}}},\n' for s in stream_receipts)
    header += '};\n#define STREAM_COUNT (sizeof(streams)/sizeof(streams[0]))\n'
    # Independently identify the loaded terrain bytes rather than trusting only
    # gCurrLevelNum. Validate matching ELF bytes against authenticated ROM MIO0.
    terrain_receipts = []
    terrain_prefixes = {}
    for stream in stream_receipts:
        level = stream["level_folder"]
        level_elf = CACHE / f"build/{args.version}/levels/{level}/leveldata.elf"
        local_symbols = elf_symbols(level_elf)
        script = re.sub(r"/\*[\s\S]*?\*/", "", pinned(f"levels/{level}/script.c").decode())
        terrain_names = re.findall(r"\bTERRAIN\(\s*(\w+)\s*\)", script)
        rom_start = main_symbols[f"_{level}_segment_7SegmentRomStart"]["address"]
        rom_end = main_symbols[f"_{level}_segment_7SegmentRomEnd"]["address"]
        segment = mio0(raw_rom[rom_start:rom_end])
        for index, name in enumerate(terrain_names, 1):
            symbol = local_symbols[name]
            if main_symbols[name]["address"] != symbol["address"]:
                raise RuntimeError("main/local ELF terrain symbols differ")
            offset = symbol["address"]-0x07000000
            authenticated = segment[offset:offset+symbol["size"]]
            if authenticated != symbol["data"] or len(authenticated) < 256:
                raise RuntimeError("terrain ELF bytes do not match authenticated ROM")
            prefix = authenticated[:256]
            if prefix in terrain_prefixes.values():
                raise RuntimeError("demo terrain prefixes are not distinct")
            terrain_prefixes[name] = prefix
            terrain_receipts.append({"name": name, "level": stream["level"], "area": index,
                "symbol": symbol["address"], "size": symbol["size"],
                "segment_rom_start": rom_start, "segment_rom_end": rom_end,
                "level_elf_sha256": sha(level_elf), "terrain_sha256": hashlib.sha256(authenticated).hexdigest(),
                "observed_prefix_bytes": 256, "prefix_sha256": hashlib.sha256(prefix).hexdigest()})
    for name, data in terrain_prefixes.items():
        header += f'static const unsigned char terrain_{name}[] = {{' + ','.join(map(str, data)) + '};\n'
    header += 'struct terrain { const char *name; unsigned level, area; const unsigned char *data; };\nstatic const struct terrain terrains[] = {\n'
    header += ''.join(f'{{"{t["name"]}",{t["level"]}u,{t["area"]}u,terrain_{t["name"]}}},\n' for t in terrain_receipts)
    header += '};\n#define TERRAIN_COUNT (sizeof(terrains)/sizeof(terrains[0]))\n#define TERRAIN_PREFIX_SIZE 256u\n'
    out = HERE / "build" / args.name
    out.mkdir(parents=True, exist_ok=False)
    for folder in ("shots", "config", "data"):
        (out / folder).mkdir()
    (out / "addresses.h").write_text(header)
    (out / "observer.c").write_bytes((HERE / "observer.c").read_bytes())
    subprocess.run(["gcc", "-shared", "-fPIC", "-std=c99", "-Wall", "-Wextra", "-Werror", "-O2", "-I", str(out), str(out / "observer.c"), "-ldl", "-o", str(out / "observer.so")], check=True)
    command = ["xvfb-run", "-a", "/usr/games/mupen64plus", "--debug", "--emumode", "0", "--nosaveoptions", "--nospeedlimit", "--audio", "dummy", "--input", str(out / "observer.so"), "--gfx", "mupen64plus-video-rice.so", "--rsp", "mupen64plus-rsp-hle.so", "--sshotdir", str(out / "shots"), "--testshots", str(args.video_frames), str(rom)]
    env = dict(os.environ, XDG_CONFIG_HOME=str(out / "config"), XDG_DATA_HOME=str(out / "data"), LIBGL_ALWAYS_SOFTWARE="1")
    env.pop("DEMO_START_AT", None)
    env.pop("DEMO_START_FRAMES", None)
    if args.start_at is not None:
        env.update(DEMO_START_AT=str(args.start_at), DEMO_START_FRAMES=str(args.start_frames))
    manifest = {"version": args.version, "source_pin": PIN, "rom_sha1": expected_sha1,
                "rom_sha256": sha(rom), "elf_sha256": sha(elf), "observer_sha256": sha(out / "observer.c"),
                "runner_sha256": sha(Path(__file__)), "symbols": symbols, "code_receipts": code_receipts,
                "stream_receipts": stream_receipts, "command": command, "start_at": args.start_at,
                "terrain_receipts": terrain_receipts,
                "start_frames": args.start_frames,
                "initialization": "boot; fresh configuration and save-data directories; no cheats or state injection",
                "scope": "finite emulator experiment, outside Coq; not an all-runs theorem"}
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    try:
        with (out / "raw.log").open("w") as log:
            result = subprocess.run(command, env=env, input="run\n", text=True,
                                    stdout=log, stderr=subprocess.STDOUT, timeout=args.timeout_seconds)
        exitcode = result.returncode
    except subprocess.TimeoutExpired:
        exitcode = "timeout"
    raw = (out / "raw.log").read_text(errors="replace")
    records = []
    for line in raw.splitlines():
        match = re.search(r"D(?:INSTALL|LOAD|GAME|INPUT|ERROR|SUMMARY),(?:US|JP),.*", line)
        if match:
            records.append(match.group(0))
    (out / "trace.csv").write_text("\n".join(records) + "\n")
    loads = [line for line in records if line.startswith("DLOAD,")]
    frames = [line for line in records if line.startswith("DGAME,")]
    errors = [line for line in records if line.startswith("DERROR,")]
    summary = {"emulator_exit": exitcode, "episodes": loads, "gameplay_updates": len(frames),
               "mismatched_gameplay_updates": sum(line.endswith("mismatch=1") for line in frames),
               "observer_errors": errors, "checks": {"cheats_disabled": "Cheat codes disabled." in raw,
               "code_hashes_verified": any(line.startswith("DINSTALL,") for line in records),
               "physical_start_polls": sum(line.startswith("DINPUT,") and line.endswith("button=START") for line in records),
               "physical_title_A_polls": sum(line.startswith("DINPUT,") and line.endswith("button=A") for line in records)},
               "boundary": "run_demo_inputs entry identifies the consumed record; update_level entry observes the real gameplay update receiving that frame's input"}
    (out / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    print(json.dumps(summary, indent=2))
    if exitcode != 0 or errors or summary["mismatched_gameplay_updates"] or not loads or not frames:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
