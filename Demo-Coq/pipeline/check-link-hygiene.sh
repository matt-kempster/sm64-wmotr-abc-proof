#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
python3 - "$PROJECT_ROOT" <<'PY'
from pathlib import Path
import importlib.util
import sys

project = Path(sys.argv[1])
root = project / 'generated'
spec = importlib.util.spec_from_file_location('private_scope', project / 'pipeline/scope-private-globals.py')
scope = importlib.util.module_from_spec(spec)
spec.loader.exec_module(scope)
for version in ('us', 'jp'):
    files = sorted(root.glob(version + '_*.v'))
    if len(files) != 20:
        raise SystemExit(f'expected 20 {version} units, got {len(files)}')
    occurrences = {}
    count = 0
    for path in files:
        aliases, globals_, public, private = scope.check(path)
        count += len(private)
        for name in globals_:
            occurrences.setdefault(aliases[name], []).append((path.name, name in private))
    for atom, uses in occurrences.items():
        if len(uses) > 1 and any(private for _, private in uses):
            raise SystemExit(f'private global collision: {atom}: {uses}')
    print(f'{version}: 20 generated units; {count} private global atoms scoped; no private global collisions')
print('This check does not certify whole-program linking or public declaration compatibility.')
PY
