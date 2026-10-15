#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
python3 - "$PROJECT_ROOT/generated" <<'PY'
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
for version in ('us', 'jp'):
    files = sorted(root.glob(version + '_*.v'))
    if len(files) != 19:
        raise SystemExit(f'expected 19 {version} units, got {len(files)}')
    for path in files:
        text = path.read_text(encoding='utf-8')
        if f'private __stringlit_N atoms prefixed with {path.stem}' not in text:
            raise SystemExit(f'missing generated literal hygiene header: {path.name}')
        if re.search(r': ident := \$"__stringlit_[0-9]+"\.', text):
            raise SystemExit(f'unprefixed private string literal: {path.name}')
    print(f'{version}: 19 generated units; private string literal prefix checks passed')
print('This check does not certify whole-program linking or public declaration compatibility.')
PY
