#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

python3 - "$PROJECT_ROOT/generated" <<'PY'
from __future__ import annotations

import pathlib
import re
import sys
from collections import defaultdict

generated = pathlib.Path(sys.argv[1])
expected_mismatch_counts = {"us": 402, "jp": 401}

ident_re = re.compile(
    r'Definition\s+(_[A-Za-z0-9_]+)\s+: ident := \$"([^"]+)"\.'
)
global_entry_re = re.compile(
    r'\(\s*(_[A-Za-z0-9_]+)\s*,\s*(Gfun|Gvar)(?:\s+(v_[A-Za-z0-9_]+))?'
)
literal_re = re.compile(
    r'^Definition\s+(___stringlit_([0-9]+))\s+: ident := \$"([^"]+)"\.$',
    re.MULTILINE,
)

for version in ("us", "jp"):
    files = sorted(generated.glob(f"{version}_*.v"))
    if len(files) != 38:
        raise SystemExit(
            f"expected 38 generated {version} units; found {len(files)}"
        )

    definitions: dict[str, list[tuple[str, bool]]] = defaultdict(list)
    variable_types: dict[str, list[str]] = defaultdict(list)
    literal_count = 0

    for path in files:
        text = path.read_text(encoding="utf-8")
        stem = path.stem
        header = (
            "Link hygiene:    private __stringlit_N atoms prefixed with " + stem
        )
        if header not in text:
            raise SystemExit(f"missing link-hygiene header in {path.name}")

        names = dict(ident_re.findall(text))
        global_match = re.search(
            r'Definition global_definitions[\s\S]*?Definition public_idents', text
        )
        public_match = re.search(
            r'Definition public_idents[\s\S]*?Definition prog', text
        )
        if global_match is None or public_match is None:
            raise SystemExit(f"cannot parse generated program lists in {path.name}")
        globals_text = global_match.group(0)
        public_coq_names = set(re.findall(r'_[A-Za-z0-9_]+', public_match.group(0)))

        for coq_name, number, atom in literal_re.findall(text):
            expected_atom = f"__{stem}_stringlit_{number}"
            if atom != expected_atom:
                raise SystemExit(
                    f"unexpected private literal atom in {path.name}: "
                    f"{coq_name} maps to {atom}, expected {expected_atom}"
                )
            if coq_name in public_coq_names:
                raise SystemExit(
                    f"private literal {coq_name} appears in public_idents of {path.name}"
                )
            literal_count += 1

        if re.search(r': ident := \$"__stringlit_[0-9]+"\.', text):
            raise SystemExit(f"unprefixed private literal remains in {path.name}")

        for coq_name, kind, variable_name in global_entry_re.findall(globals_text):
            atom = names.get(coq_name)
            if atom is None:
                raise SystemExit(f"cannot resolve {coq_name} in {path.name}")
            definitions[atom].append((path.name, coq_name in public_coq_names))
            if kind != "Gvar":
                continue
            block_match = re.search(
                rf'Definition {re.escape(variable_name)} := '
                r'\{\|[\s\S]*?\|\}\.',
                text,
            )
            if block_match is None:
                raise SystemExit(
                    f"cannot parse {variable_name} referenced by {path.name}"
                )
            type_match = re.search(
                r'gvar_info := ([\s\S]*?);\s*gvar_init', block_match.group(0)
            )
            if type_match is None:
                raise SystemExit(f"cannot parse type of {variable_name} in {path.name}")
            variable_types[atom].append(" ".join(type_match.group(1).split()))

    private_collisions = {
        atom: entries
        for atom, entries in definitions.items()
        if len(entries) > 1 and any(not public for _, public in entries)
    }
    if private_collisions:
        atom, entries = next(iter(private_collisions.items()))
        raise SystemExit(f"duplicate non-public atom {atom}: {entries}")

    mismatches = {
        atom: types
        for atom, types in variable_types.items()
        if len(types) > 1 and len(set(types)) > 1
    }
    expected = expected_mismatch_counts[version]
    if len(mismatches) != expected:
        raise SystemExit(
            f"expected {expected} public variable type-mismatch groups for {version}; "
            f"found {len(mismatches)}"
        )

    print(
        f"{version}: 38 units, {literal_count} private literal atoms uniquely "
        f"prefixed, 0 private collisions, {len(mismatches)} documented "
        "public variable type-mismatch groups"
    )
PY

for version in us jp; do
  manifest="$PROJECT_ROOT/docs/notes/linked-symbol-coverage-${version}.txt"
  diff -u "$manifest" \
    <(python3 "$PROJECT_ROOT/pipeline/link-coverage-manifest.py" \
      "$PROJECT_ROOT/generated" "$version")
done

echo "linked external-constructor and extern/tentative-variable manifests reproduce"
