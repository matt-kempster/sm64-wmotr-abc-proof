#!/usr/bin/env python3
"""Prepare the explicitly authorized near-cog initialization experiment.

Only the isolated build copy is changed. The emitted patch is the complete
initialization change; movement, collisions, cogs, particles and RNG retain
their pinned source. This is a discovery setup, not a normal-entry witness.
"""
import argparse
import difflib
import hashlib
import io
import json
from pathlib import Path
import shutil
import subprocess
import tarfile

PROJECT = Path(__file__).resolve().parents[2]
PIN = "9921382a68bb0c865e5e45eb594d9c64db59b1af"
CACHE = PROJECT / "instrumentation/ttc-runtime-snapshot/build/retail-map-9921382"
SOURCE = PROJECT.parent.parent / "reference-sm64-decomp"
OUT = PROJECT / "build/cog-placement"
PRESETS = {
    "ledge": {"position": [1742, -2088, -125], "yaw_degrees": 188},
    "cog_back": {"position": [1428, -2088, -1084], "yaw_degrees": 7},
    "edge": {"position": [1456, -2088, -1178], "yaw_degrees": 341},
    "rim": {"position": [1456, -2088, -1139], "yaw_degrees": 341},
    "inner_rim": {"position": [1313, -2088, -1098], "yaw_degrees": 90},
}
EXPECTED = {
    "us": "17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91",
    "jp": "9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317",
}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def git(*args):
    return subprocess.check_output([
        "git", "-c", f"safe.directory={SOURCE}",
        "-c", "core.autocrlf=false", "-c", "core.eol=lf",
        "-C", str(SOURCE), *args
    ])


def replace_once(text, old, new):
    if text.count(old) != 1:
        raise RuntimeError(f"expected one pinned initialization site: {old!r}")
    return text.replace(old, new)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--setup", choices=PRESETS, default="ledge")
    args = parser.parse_args()
    preset = PRESETS[args.setup]
    out = OUT if args.setup == "ledge" else OUT / args.setup
    dest = out / "source"
    if not dest.resolve().is_relative_to((PROJECT / "build").resolve()):
        raise RuntimeError("experiment destination must be inside Pedro-Coq/build")
    for version, digest in EXPECTED.items():
        rom = CACHE / f"build/{version}/sm64.{version}.z64"
        if sha(rom.read_bytes()) != digest:
            raise RuntimeError(f"{version} matching-build cache is not authenticated")
    out.mkdir(parents=True, exist_ok=True)
    copied = out / "cache-copy-complete"
    if not dest.exists():
        print("Copying authenticated matching-build cache", flush=True)
        shutil.copytree(CACHE, dest)
        copied.write_text("complete\n")
    elif not copied.exists() and not (out / "initialization.json").exists():
        # An interrupted initial copy can be resumed without deleting anything.
        shutil.copytree(CACHE, dest, dirs_exist_ok=True)
        copied.write_text("complete\n")

    print("Restoring all tracked source from the pinned commit", flush=True)
    archive = git("archive", "--format=tar", PIN)
    with tarfile.open(fileobj=io.BytesIO(archive)) as tree:
        for member in tree:
            target = dest / member.name
            if member.isfile() and target.is_file() \
                    and target.read_bytes() == tree.extractfile(member).read():
                continue
            tree.extract(member, dest, filter="data")

    changes = {}
    path = "levels/menu/script.c"
    old = git("show", f"{PIN}:{path}").decode()
    new = replace_once(old, "SET_REG(/*value*/ LEVEL_CASTLE_GROUNDS)",
                       "SET_REG(/*value*/ LEVEL_TTC)")
    changes[path] = (old, new)

    path = "levels/ttc/script.c"
    old = git("show", f"{PIN}:{path}").decode()
    x, y, z = preset["position"]
    yaw = preset["yaw_degrees"]
    new = replace_once(old,
        "MARIO_POS(/*area*/ 1, /*yaw*/ 316, /*pos*/ 1417, -4822, -548)",
        f"MARIO_POS(/*area*/ 1, /*yaw*/ {yaw}, /*pos*/ {x}, {y}, {z})")
    changes[path] = (old, new)

    path = "src/game/level_update.c"
    old = git("show", f"{PIN}:{path}").decode()
    new = replace_once(old, '#include "object_list_processor.h"',
        '#include "object_list_processor.h"\n#include "object_constants.h"')
    new = replace_once(new, "s32 init_level(void) {\n    s32 val4 = FALSE;",
        "s32 init_level(void) {\n    s32 val4 = FALSE;\n\n"
        "    /* Declared placement experiment: initialize the chosen clock mode. */\n"
        "    if (gCurrLevelNum == LEVEL_TTC) {\n"
        "        gTTCSpeedSetting = TTC_SPEED_RANDOM;\n    }")
    new = replace_once(new,
        "if (save_file_exists(gCurrSaveFileNum - 1)) {",
        "if (gCurrLevelNum == LEVEL_TTC || save_file_exists(gCurrSaveFileNum - 1)) {")
    changes[path] = (old, new)

    patch = []
    for path, (old, new) in changes.items():
        (dest / path).write_text(new, newline="\n")
        patch.extend(difflib.unified_diff(old.splitlines(True), new.splitlines(True),
                     fromfile=f"pinned/{path}", tofile=f"placement/{path}"))
    (out / "initialization.patch").write_text("".join(patch), newline="\n")

    # Audit every tracked source file, not just selected gameplay functions.
    # The only differences from the source archive must be the three above.
    changed = []
    with tarfile.open(fileobj=io.BytesIO(archive)) as tree:
        for member in tree:
            if member.isfile():
                original = tree.extractfile(member).read()
                if (dest / member.name).read_bytes() != original:
                    changed.append(member.name)
    if set(changed) != set(changes):
        raise RuntimeError(f"unexpected source differences: {changed}")
    manifest = {
        "purpose": "user-authorized near-cog placement discovery; not stock entry",
        "source_pin": PIN, "versions": ["VERSION_US", "VERSION_JP"],
        "setup": args.setup, "level": "TTC", "mode": "RANDOM", **preset,
        "initial_action": "ordinary idle initialization",
        "changed_source_files": changed,
        "patch_sha256": sha((out / "initialization.patch").read_bytes()),
        "baseline_rom_sha256": EXPECTED,
        "runtime_control": "controller input only; observer has no guest writes",
    }
    (out / "initialization.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(json.dumps(manifest, indent=2), flush=True)


if __name__ == "__main__":
    main()
