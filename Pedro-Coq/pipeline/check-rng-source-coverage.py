#!/usr/bin/env python3
"""Authenticate the source-token/include coverage behind RNGSourceCatalogue.

This is a provenance gate, not a Coq proof of preprocessing, linkage, aliasing,
or gameplay reachability. It deliberately scans inactive source regions too.
The generated US/JP ASTs and their call inventories are checked separately.
"""
import argparse
import hashlib
import io
import json
import os
from pathlib import Path, PurePosixPath
import posixpath
import re
import subprocess
import tarfile

PROJECT = Path(__file__).resolve().parents[1]
PRIMITIVES = {"random_u16", "random_float", "random_sign", "gRandomSeed16"}
TOKEN = re.compile(r'/\*.*?\*/|//[^\n]*|"(?:\\.|[^"\\])*"|'
                   r"'(?:\\.|[^'\\])*'|[A-Za-z_][A-Za-z_0-9]*", re.S)
INCLUDE = re.compile(r'^\s*#\s*include\s*[<"]([^>"\n]+)[>"]', re.M)


def identifiers(data):
    # C translation phase 2 precedes comments and token recognition.
    source = re.sub(r'\\\r?\n', '', data.decode('utf-8', errors='strict'))
    return {m.group() for m in TOKEN.finditer(source)
            if re.fullmatch(r'[A-Za-z_][A-Za-z_0-9]*', m.group())}


def coverage(source_repository):
    generator = (PROJECT / 'pipeline/generate-clight.sh').read_text()
    revision = re.search(r'^DECOMP_REVISION="([0-9a-f]{40})"$', generator, re.M).group(1)
    units = dict(re.findall(r'^  "(\w+):([^"\n]+)"$', generator, re.M))
    archive = subprocess.check_output([
        'git', '-c', f'safe.directory={source_repository}', '-c', 'core.autocrlf=false',
        '-c', 'core.eol=lf', '-C', str(source_repository), 'archive', '--format=tar', revision])
    files = {}
    with tarfile.open(fileobj=io.BytesIO(archive)) as tree:
        for member in tree:
            name = PurePosixPath(member.name)
            if name.is_absolute() or '..' in name.parts:
                raise ValueError('invalid archive member')
            if member.isfile():
                files[member.name] = tree.extractfile(member).read()

    includes = ['include', 'src', 'src/game', '', 'include/libc', 'levels']

    def closure(root):
        pending, seen = [root], set()
        while pending:
            path = pending.pop()
            if path in seen:
                continue
            if path not in files:
                raise ValueError(f'unknown translation unit {path}')
            seen.add(path)
            text = files[path].decode('utf-8')
            for name in INCLUDE.findall(text):
                candidates = [posixpath.normpath(posixpath.join(parent, name))
                              for parent in [posixpath.dirname(path)] + includes]
                found = next((p for p in candidates if p in files), None)
                if found is not None:
                    pending.append(found)
        return seen

    closures = {stem: closure(path) for stem, path in units.items()
                if not path.startswith('PROJECT_')}
    bearing = []
    for name, data in sorted(files.items()):
        suffix = PurePosixPath(name).suffix.lower()
        if suffix not in {'.c', '.h', '.s'}:
            continue
        names = identifiers(data) & PRIMITIVES
        if not names:
            continue
        if suffix == '.s':
            raise ValueError(f'assembly reference requires separate analysis: {name}')
        roots = sorted(stem for stem, paths in closures.items() if name in paths)
        if not roots:
            raise ValueError(f'RNG-bearing source is outside generated include coverage: {name}')
        if 'gRandomSeed16' in names and name != 'src/engine/behavior_script.c':
            raise ValueError(f'additional seed reference: {name}')
        bearing.append({'path': name, 'sha256': hashlib.sha256(data).hexdigest(),
                        'identifiers': sorted(names), 'including_units': roots})

    if not bearing:
        raise ValueError('empty RNG source inventory')
    generated = {}
    for version in ['us', 'jp']:
        for stem in units:
            path = PROJECT / 'generated' / f'{version}_{stem}.v'
            data = path.read_bytes()
            # Headers are provenance assertions; reproducible regeneration is
            # the independent test that authenticates the generated contents.
            if f'Decomp revision: {revision}'.encode() not in data[:1800]:
                raise ValueError(f'wrong source pin in {path.name}')
            if f'Game version:    VERSION_{version.upper()}'.encode() not in data[:1800]:
                raise ValueError(f'wrong version in {path.name}')
            generated[path.name] = hashlib.sha256(data).hexdigest()
    return {'schema': 1, 'source_revision': revision,
            'scope': 'gameplay 16-bit RNG; conservative source-token and literal-include coverage',
            'versions': ['VERSION_US', 'VERSION_JP'],
            'translation_units': units,
            'primitive_bearing_sources': bearing, 'generated_sha256': generated,
            'limits': ['Not a proof of the C preprocessor or a fully linked program.',
                       'Literal include closure includes inactive version branches.',
                       'Runtime indirect targets, memory aliases, allocation and preserving controller paths remain semantic obligations.',
                       'Audio randomness is a separate generator; this census concerns the seed read by TTC cogs.']}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true', help='write the reviewable authenticated receipt')
    args = parser.parse_args()
    source = Path(os.environ.get('SM64_SOURCE', PROJECT.parent.parent / 'reference-sm64-decomp'))
    result = coverage(source)
    target = PROJECT / 'inputs/rng-source-coverage.json'
    if args.write:
        target.write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8', newline='\n')
    elif json.loads(target.read_text(encoding='utf-8')) != result:
        raise SystemExit('RNG source coverage receipt differs; review the source/generation change')
    print(f"checked {len(result['primitive_bearing_sources'])} RNG-bearing pinned C/header files "
          f"and {len(result['generated_sha256'])} generated US/JP units")


if __name__ == '__main__':
    main()
