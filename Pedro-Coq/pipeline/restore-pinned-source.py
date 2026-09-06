#!/usr/bin/env python3
"""Restore and verify the exact source pin without deleting the entire cache."""
import io
import os
from pathlib import Path, PurePosixPath
import re
import subprocess
import sys
import tarfile


def main():
    if len(sys.argv) != 3 or not re.fullmatch(r"[0-9a-f]{40}", sys.argv[2]):
        raise SystemExit("usage: restore-pinned-source.py SOURCE_REPOSITORY FULL_COMMIT")
    project = Path(__file__).resolve().parents[1]
    build = (project / "build").resolve()
    target = build / "pinned-sm64"
    target.mkdir(parents=True, exist_ok=True)
    if target.is_symlink() or target.resolve().parent != build:
        raise RuntimeError("pinned source must be a real directory inside Pedro-Coq/build")
    source, revision = sys.argv[1:]
    archive = subprocess.check_output([
        "git", "-c", f"safe.directory={source}", "-c", "core.autocrlf=false",
        "-c", "core.eol=lf", "-C", source, "archive", "--format=tar", revision])
    expected = {}
    with tarfile.open(fileobj=io.BytesIO(archive)) as tree:
        for member in tree:
            name = PurePosixPath(member.name)
            if name.is_absolute() or ".." in name.parts:
                raise RuntimeError("invalid pinned archive path")
            if member.isdir():
                continue
            if not member.isfile():
                raise RuntimeError(f"unsupported pinned archive member: {member.name}")
            expected[member.name] = tree.extractfile(member).read()

    # Unknown headers must not silently influence preprocessing. The one
    # allowed derived header is overwritten and hash-checked by the caller.
    derived = {"levels/level_headers.h"}
    for directory, dirs, files in os.walk(target, followlinks=False):
        for name in dirs + files:
            path = Path(directory) / name
            if path.is_symlink():
                raise RuntimeError(f"unexpected symlink in pinned cache: {path}")
        for name in files:
            relative = (Path(directory) / name).relative_to(target).as_posix()
            if relative not in expected and relative not in derived:
                raise RuntimeError(f"unexpected file in pinned cache: {relative}")

    restored = 0
    for name, contents in expected.items():
        path = target / name
        if not path.is_file() or path.read_bytes() != contents:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(contents)
            restored += 1
        if path.read_bytes() != contents:
            raise RuntimeError(f"pinned source verification failed: {name}")
    print(f"verified {len(expected)} pinned source files; restored {restored}", flush=True)


if __name__ == "__main__":
    main()
