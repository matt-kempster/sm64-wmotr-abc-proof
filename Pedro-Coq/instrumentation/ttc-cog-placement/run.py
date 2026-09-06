#!/usr/bin/env python3
"""Run a controller-only trial of the separately declared placement build."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
from prepare import PRESETS

HERE = Path(__file__).resolve().parent
PROJECT = HERE.parents[1]
EXPERIMENT = PROJECT / "build/cog-placement"
SYMBOLS = {
    "A_GLOBAL_TIMER": "gGlobalTimer",
    "A_CURR_LEVEL": "gCurrLevelNum",
    "A_CURR_AREA": "gCurrAreaIndex",
    "A_MARIO_STATES": "gMarioStates",
    "A_MARIO_OBJECT": "gMarioObject",
    "A_OBJECT_POOL": "gObjectPool",
    "A_TTC_SPEED_SETTING": "gTTCSpeedSetting",
    "A_RANDOM_U16": "random_u16",
    "A_TIME_STOP_STATE": "gTimeStopState",
    "A_SEGMENT_TABLE": "sSegmentTable",
    "BHV_TTC_COG": "bhvTTCCog",
    "A_CURRENT_OBJECT": "gCurrentObject",
    "PC_AIR_ENTRY": "perform_air_quarter_step",
    "A_MARIO_PLATFORM": "gMarioPlatform",
}
PATH_ROUTINES = {
    "update_mario_geometry_inputs": False,
    "set_mario_action": True,
    "common_landing_cancels": True,
    "common_landing_action": True,
    "perform_ground_step": True,
    "execute_mario_action": True,
    "spawn_particle": False,
}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def fields(line):
    return dict(piece.split("=", 1) for piece in line.split(",")[2:] if "=" in piece)


def observer_records(raw):
    """Keep complete observer records, including a known console log collision."""
    prefixes = ("CINPUT,", "CFRAME,", "CCOG,", "CWALL,", "CAIR,", "CRNG,",
                "CPATH,", "CSURFACE,", "COG_ERROR,")
    records, recovered = [], 0
    for line in raw.splitlines():
        if line.startswith(prefixes):
            records.append(line)
        elif line.startswith("Core: Captured "):
            # This console build redirects stderr internally. A buffered
            # screenshot notice can precede an otherwise intact CINPUT line.
            # Recover only its complete canonical form; never invent fields.
            match = re.search(r"CINPUT,(?:US|JP),rel=\d+,x=-?\d+,y=-?\d+,"
                              r"A=[01],B=[01],Z=[01],R=[01],L=[01]$", line)
            if match:
                records.append(match.group(0))
                recovered += 1
    return records, recovered


def routine_words(elf, name):
    disassembly = subprocess.check_output([
        "mips-linux-gnu-objdump", "-d", f"--disassemble={name}", str(elf)
    ], text=True)
    words = {int(address, 16): int(word, 16) for address, word in re.findall(
        r"^\s*([0-9a-f]+):\s+([0-9a-f]{8})\s", disassembly, re.MULTILINE)}
    if not words:
        raise RuntimeError(f"missing disassembly for {name}")
    return words, disassembly


def code_hash(words):
    value = 2166136261
    for address in sorted(words):
        value = ((value ^ words[address]) * 16777619) & 0xffffffff
    return value


def static_seed_address(words, routine):
    """IDO omits this static symbol; verify its load in the exact test ELF."""
    upper, load = words[routine + 4], words[routine + 8]
    # Stock IDO prologue: lui t6,high; lhu t6,low(t6); li at,22026.
    if upper >> 16 != 0x3c0e or load >> 16 != 0x95ce \
            or words[routine + 12] != 0x2401560a:
        raise RuntimeError("unrecognized RNG seed load; no trial was launched")
    low = load & 0xffff
    address = ((upper & 0xffff) << 16) + (low if low < 0x8000 else low - 0x10000)
    if address & 1 or not 0x80000000 <= address <= 0x807ffffe:
        raise RuntimeError("RNG seed load is not an aligned RDRAM halfword")
    return address


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("version", choices=["us", "jp"])
    parser.add_argument("name", help="new trial name; letters, digits, underscores")
    parser.add_argument("--setup", choices=PRESETS, default="ledge")
    parser.add_argument("--inputs", type=Path, default=HERE / "idle.csv")
    parser.add_argument("--waypoints", type=Path,
                        help="optional controller steering targets; actual inputs are logged")
    parser.add_argument("--video-frames", type=int, default=1000)
    parser.add_argument("--capture-from", type=int,
                        help="save every rendered frame from this index through --video-frames")
    parser.add_argument("--trace-calls", action="store_true",
                        help="observe RNG and air-quarter-step entries/returns")
    parser.add_argument("--trace-path", action="store_true",
                        help="also observe geometry, action, ground-step and particle paths")
    args = parser.parse_args()
    args.trace_calls = args.trace_calls or args.trace_path
    if not args.name.isidentifier() or not 300 <= args.video_frames <= 12000:
        parser.error("invalid trial name or video-frame limit")
    if args.capture_from is not None and not 1 <= args.capture_from <= args.video_frames:
        parser.error("capture-from must be between 1 and the video-frame limit")
    experiment = EXPERIMENT if args.setup == "ledge" else EXPERIMENT / args.setup
    initialization = json.loads((experiment / "initialization.json").read_text())
    source = experiment / "source"
    rom = source / f"build/{args.version}/sm64.{args.version}.z64"
    elf = source / f"build/{args.version}/sm64.{args.version}.elf"
    if sha(rom) == initialization["baseline_rom_sha256"][args.version]:
        raise RuntimeError("the placement ROM has not been built")
    out = experiment / args.name
    out.mkdir()  # A trial always starts with fresh configuration and save data.
    patch = experiment / "initialization.patch"
    if sha(patch) != initialization["patch_sha256"]:
        raise RuntimeError("initialization patch does not match its manifest")
    (out / "initialization.patch").write_bytes(patch.read_bytes())
    (out / "shots").mkdir()
    input_copy = out / "inputs.csv"
    input_copy.write_bytes(args.inputs.resolve().read_bytes())
    waypoint_copy = out / "waypoints.csv" if args.waypoints else None
    if waypoint_copy:
        waypoint_copy.write_bytes(args.waypoints.resolve().read_bytes())
    symbols = {}
    for line in subprocess.check_output(["mips-linux-gnu-nm", "-n", str(elf)], text=True).splitlines():
        parts = line.split()
        if len(parts) == 3 and parts[2] in SYMBOLS.values():
            if parts[2] in symbols:
                raise RuntimeError(f"ambiguous ELF symbol {parts[2]}")
            symbols[parts[2]] = int(parts[0], 16)
    rng_words, rng_disassembly = routine_words(elf, "random_u16")
    seed_address = static_seed_address(rng_words, symbols["random_u16"])
    symbols["gRandomSeed16 (verified static load)"] = seed_address
    (out / "random_u16.disassembly.txt").write_text(rng_disassembly)
    header = f'#define VERSION_NAME "{args.version.upper()}"\n'
    header += "".join(f"#define {macro} 0x{symbols[name]:08x}u\n"
                      for macro, name in SYMBOLS.items())
    header += f"#define A_RANDOM_SEED16 0x{seed_address:08x}u\n"
    air_words, air_disassembly = routine_words(elf, "perform_air_quarter_step")
    (out / "perform_air_quarter_step.disassembly.txt").write_text(air_disassembly)
    air_entry = symbols["perform_air_quarter_step"]
    air_layout = {0: 0x27bdffb0, 0x18: 0x27a40040, 0x60: 0x27a70030,
                  0x64: 0xe7a00028, 0x74: 0x27a60034, 0x78: 0xe7a0002c}
    if any(air_words[air_entry + offset] != value for offset, value in air_layout.items()):
        raise RuntimeError("unrecognized air-quarter-step local layout")
    air_returns = [pc for pc, word in air_words.items() if word == 0x03e00008]
    rng_returns = [pc for pc, word in rng_words.items() if word == 0x03e00008]
    if len(air_returns) != 1 or len(rng_returns) != 1 \
            or air_words[air_returns[0] - 12] != 0x8fbf001c:
        raise RuntimeError("unrecognized routine return layout")
    for name, value in {
        "PC_AIR_EXIT": air_returns[0] - 12,
        "PC_RNG_EXIT": rng_returns[0],
        "AIR_WORD_COUNT": len(air_words), "RNG_WORD_COUNT": len(rng_words),
        "AIR_CODE_HASH": code_hash(air_words), "RNG_CODE_HASH": code_hash(rng_words)
    }.items():
        header += f"#define {name} 0x{value:x}u\n"
    header += "struct path_point { unsigned pc; const char *routine; int leaving, returns_value; };\n"
    header += "static const struct path_point path_points[] = {\n"
    path_checks = []
    for routine, returns_value in PATH_ROUTINES.items():
        words, disassembly = routine_words(elf, routine)
        start = min(words)
        if sorted(words) != list(range(start, max(words) + 4, 4)):
            raise RuntimeError(f"noncontiguous routine: {routine}")
        returns = [pc for pc, word in words.items() if word == 0x03e00008]
        if not returns:
            raise RuntimeError(f"missing return: {routine}")
        # Return observations occur before jr ra. Reject a delay-slot result
        # assignment, which would make the observed v0 premature.
        for pc in returns:
            delay = words[pc + 4]
            if returns_value and delay != 0 and delay >> 16 != 0x27bd:
                raise RuntimeError(f"unrecognized return delay slot: {routine}")
        header += f'{{0x{start:08x}u, "{routine}", 0, 0}},\n'
        for pc in returns:
            header += f'{{0x{pc:08x}u, "{routine}", 1, {int(returns_value)}}},\n'
        path_checks.append((start, len(words), code_hash(words)))
        (out / f"{routine}.disassembly.txt").write_text(disassembly)
    header += "};\nstruct path_code { unsigned start, count, hash; };\n"
    header += "static const struct path_code path_codes[] = {\n"
    header += "".join(f"{{0x{start:08x}u, {count}u, 0x{digest:08x}u}},\n"
                      for start, count, digest in path_checks) + "};\n"
    (out / "addresses.h").write_text(header)
    observer_copy = out / "observer.c"
    observer_copy.write_bytes((HERE / "observer.c").read_bytes())
    subprocess.run(["gcc", "-shared", "-fPIC", "-std=c99", "-Wall", "-Wextra",
        "-Werror", "-O2", "-I", str(out), str(observer_copy), "-ldl", "-lm",
        "-o", str(out / "observer.so")], check=True)
    env = dict(os.environ)
    env.update({"XDG_CONFIG_HOME": str(out / "config"),
                "XDG_DATA_HOME": str(out / "data"),
                "COG_INPUT_FILE": str(input_copy), "LIBGL_ALWAYS_SOFTWARE": "1"})
    env.pop("COG_WAYPOINT_FILE", None)
    env.pop("COG_TRACE_CALLS", None)
    env.pop("COG_TRACE_PATH", None)
    if args.trace_calls:
        env["COG_TRACE_CALLS"] = "1"
    if args.trace_path:
        env["COG_TRACE_PATH"] = "1"
    if waypoint_copy:
        env["COG_WAYPOINT_FILE"] = str(waypoint_copy)
    capture_frames = (list(range(args.capture_from, args.video_frames + 1))
                      if args.capture_from is not None else [args.video_frames])
    command = ["xvfb-run", "-a", "/usr/games/mupen64plus", "--debug", "--emumode", "0",
        "--nosaveoptions", "--nospeedlimit", "--audio", "dummy", "--input",
        str(out / "observer.so"), "--gfx", "mupen64plus-video-rice.so", "--rsp",
        "mupen64plus-rsp-hle.so", "--sshotdir", str(out / "shots"),
        "--testshots", ",".join(map(str, capture_frames))]
    if args.capture_from is not None:
        command.append("--noosd")  # Screenshot notifications must not cover the recording.
    command.append(str(rom))
    manifest = {"initialization": initialization, "version": args.version,
        "rom_sha256": sha(rom), "elf_sha256": sha(elf),
        "inputs_sha256": sha(input_copy), "observer_sha256": sha(observer_copy),
        "waypoints_sha256": sha(waypoint_copy) if waypoint_copy else None,
        "trace_calls": args.trace_calls,
        "trace_path": args.trace_path,
        "runner_sha256": sha(Path(__file__)),
        "captured_render_frames": capture_frames,
        "symbols": symbols, "command": command,
        "boundary": "input polls; state observation precedes the returned input"}
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    # Preserve both subprocess streams. This console can redirect stderr back
    # to stdout internally; observer_records handles intact prefixed CINPUTs.
    with (out / "emulator-stdout.log").open("w") as stdout, \
            (out / "observer-stderr.log").open("w") as stderr:
        result = subprocess.run(command, env=env, input="run\n", text=True,
                                stdout=stdout, stderr=stderr, timeout=180)
    raw = (out / "observer-stderr.log").read_text(errors="replace") + "\n" \
        + (out / "emulator-stdout.log").read_text(errors="replace")
    (out / "raw.log").write_text(raw)
    events, recovered = observer_records(raw)
    (out / "trace.csv").write_text("\n".join(events) + "\n")
    frames = [fields(line) for line in events if line.startswith("CFRAME,")]
    errors = [line for line in events if line.startswith("COG_ERROR,")]
    capture_count = len(list((out / "shots").glob("*.png")))
    if args.capture_from is not None and capture_count != len(capture_frames):
        errors.append("incomplete frame capture")
    summary = {"emulator_exit": result.returncode, "observed_frames": len(frames),
        "controller_lines_recovered_from_screenshot_notices": recovered,
        "first": frames[0] if frames else None, "last": frames[-1] if frames else None,
        "observer_errors": errors[:10],
        "cheats_disabled": "Cheat codes disabled." in raw}
    if args.capture_from is not None:
        summary["screenshots"] = capture_count
    (out / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    print(json.dumps(summary, indent=2))
    if result.returncode or not frames or errors or not summary["cheats_disabled"]:
        raise RuntimeError(f"trial incomplete or invalid; inspect {out / 'raw.log'}")


if __name__ == "__main__":
    main()
