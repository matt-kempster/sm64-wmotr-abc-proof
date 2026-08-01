#!/usr/bin/env python3
"""Emit the exact generated-symbol coverage boundary for one game version."""

from __future__ import annotations

import argparse
import pathlib
import re
import sys
from collections import defaultdict
from typing import TextIO


IDENT_RE = re.compile(
    r'Definition\s+(_[A-Za-z0-9_]+)\s+: ident := \$"([^"]+)"\.'
)
GLOBAL_ENTRY_RE = re.compile(
    r'\(\s*(_[A-Za-z0-9_]+)\s*,\s*(Gfun|Gvar)(?:\s+(v_[A-Za-z0-9_]+))?'
)


def classify(generated: pathlib.Path, version: str) -> dict[str, list[str] | int]:
    files = sorted(generated.glob(f"{version}_*.v"))
    if len(files) != 38:
        raise SystemExit(f"expected 38 {version} units; found {len(files)}")

    function_classes: dict[str, set[str]] = defaultdict(set)
    variable_classes: dict[str, set[str]] = defaultdict(set)

    for path in files:
        text = path.read_text(encoding="utf-8")
        names = dict(IDENT_RE.findall(text))
        global_match = re.search(
            r'Definition global_definitions[\s\S]*?Definition public_idents', text
        )
        if global_match is None:
            raise SystemExit(f"cannot parse global_definitions in {path.name}")
        globals_text = global_match.group(0)

        for entry in GLOBAL_ENTRY_RE.finditer(globals_text):
            coq_name, kind, variable_name = entry.groups()
            atom = names.get(coq_name)
            if atom is None:
                raise SystemExit(f"cannot resolve {coq_name} in {path.name}")
            if kind == "Gfun":
                suffix = globals_text[entry.start() : entry.start() + 300]
                function_match = re.match(
                    r'\(\s*_[A-Za-z0-9_]+\s*,\s*Gfun\((Internal|External)',
                    suffix,
                )
                if function_match is None:
                    raise SystemExit(f"cannot classify function {coq_name} in {path.name}")
                if function_match.group(1) == "Internal":
                    function_classes[atom].add("internal")
                    continue
                external_match = re.match(
                    r'\(\s*_[A-Za-z0-9_]+\s*,\s*Gfun\(External\s*'
                    r'\(EF_(external|builtin|runtime)\b',
                    suffix,
                )
                if external_match is None:
                    raise SystemExit(
                        f"unsupported External constructor for {coq_name} "
                        f"in {path.name}"
                    )
                function_classes[atom].add(f"ef_{external_match.group(1)}")
                continue

            block_match = re.search(
                rf'Definition {re.escape(variable_name)} := '
                r'\{\|[\s\S]*?\|\}\.',
                text,
            )
            if block_match is None:
                raise SystemExit(f"cannot parse {variable_name} in {path.name}")
            block = block_match.group(0)
            if re.search(r'gvar_init := nil\s*;', block):
                variable_classes[atom].add("extern")
            elif re.search(r'gvar_init :=\s*\(?Init_space[\s\S]*?:: nil\)?\s*;', block):
                variable_classes[atom].add("tentative")
            else:
                variable_classes[atom].add("definitive")

    mixed = set(function_classes).intersection(variable_classes)
    if mixed:
        raise SystemExit(f"atoms used as both functions and variables: {sorted(mixed)!r}")

    internal = sorted(
        atom for atom, classes in function_classes.items() if "internal" in classes
    )
    unresolved_constructors: dict[str, str] = {}
    for atom, classes in function_classes.items():
        if "internal" in classes:
            continue
        constructors = classes.intersection(
            {"ef_external", "ef_builtin", "ef_runtime"}
        )
        if len(constructors) != 1:
            raise SystemExit(
                f"unresolved function {atom!r} has ambiguous constructors: "
                f"{sorted(constructors)!r}"
            )
        unresolved_constructors[atom] = next(iter(constructors))
    ef_external = sorted(
        atom for atom, kind in unresolved_constructors.items()
        if kind == "ef_external"
    )
    ef_builtin = sorted(
        atom for atom, kind in unresolved_constructors.items()
        if kind == "ef_builtin"
    )
    ef_runtime = sorted(
        atom for atom, kind in unresolved_constructors.items()
        if kind == "ef_runtime"
    )
    definitive = sorted(
        atom for atom, classes in variable_classes.items() if "definitive" in classes
    )
    tentative = sorted(
        atom
        for atom, classes in variable_classes.items()
        if "definitive" not in classes and "tentative" in classes
    )
    extern_variables = sorted(
        atom
        for atom, classes in variable_classes.items()
        if "definitive" not in classes and "tentative" not in classes
    )

    return {
        "units": len(files),
        "internal": internal,
        "ef_external": ef_external,
        "ef_builtin": ef_builtin,
        "ef_runtime": ef_runtime,
        "definitive": definitive,
        "tentative": tentative,
        "extern_variables": extern_variables,
    }


def emit(
    version: str, result: dict[str, list[str] | int], stream: TextIO = sys.stdout
) -> None:
    sections = (
        ("ef_external_functions", result["ef_external"]),
        ("ef_builtin_functions", result["ef_builtin"]),
        ("ef_runtime_functions", result["ef_runtime"]),
        ("extern_variables", result["extern_variables"]),
        ("tentative_variables", result["tentative"]),
        ("resolved_internal_functions", result["internal"]),
        ("resolved_definitive_variables", result["definitive"]),
    )
    print("# GENERATED BY pipeline/link-coverage-manifest.py; DO NOT EDIT", file=stream)
    print(f"version={version}", file=stream)
    print(f"translation_units={result['units']}", file=stream)
    for name, values in sections:
        assert isinstance(values, list)
        print(f"{name}={len(values)}", file=stream)
    for name, values in sections:
        assert isinstance(values, list)
        print(f"\n[{name}]", file=stream)
        for atom in values:
            print(atom, file=stream)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("generated", type=pathlib.Path)
    parser.add_argument("version", choices=("us", "jp"))
    parser.add_argument("--output", type=pathlib.Path)
    args = parser.parse_args()
    result = classify(args.generated, args.version)
    if args.output is None:
        emit(args.version, result)
        return
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", encoding="utf-8", newline="\n") as stream:
        emit(args.version, result, stream)


if __name__ == "__main__":
    main()
