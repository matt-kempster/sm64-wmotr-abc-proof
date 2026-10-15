#!/usr/bin/env python3
"""Mechanical Demo proof audit, not a proof of the remaining game obligations.

Entry point: bash pipeline/discipline-check.sh (activates the opam switch).
The module dependency graph comes from coqdep's fresh .CoqMakefile.d, not a
regular-expression approximation of Coq Require commands. Import reachability
does not establish that a particular lemma is used, nor discharge hypotheses.
"""
from __future__ import annotations

import argparse
import json
import math
import os
from pathlib import Path
import re
import shlex
import signal
import subprocess
import sys
import tempfile
import time

NAMESPACE = "Demo.Proofs."
IDENT = r"[A-Za-z_][A-Za-z0-9_']*"
QUALIFIED = rf"{IDENT}(?:\.{IDENT})*"
MODULE_NAME = r"[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*"
MAIN = NAMESPACE + "MainTheorem"
DEFAULT_THEOREMS = [
    (MAIN, "checked_demo_source_boundary_us_jp"),
]
ALLOWED_AXIOMS = frozenset({
    "Classical_Prop.classic",
    "FunctionalExtensionality.functional_extensionality_dep",
    "Axioms.proof_irr",
    "ClassicalDedekindReals.sig_not_dec",
    "ClassicalDedekindReals.sig_forall_dec",
    "Events.external_functions_sem",
    "Events.external_functions_properties",
    "Events.inline_assembly_sem",
    "Events.inline_assembly_properties",
})


def module_path(module: str) -> str:
    if not module.startswith(NAMESPACE) or not re.fullmatch(MODULE_NAME, module):
        raise ValueError(f"expected an active Demo proof module, got {module!r}")
    return "proofs/" + module[len(NAMESPACE):].replace(".", "/") + ".v"


def parse_pairs(arguments: list[str]) -> list[tuple[str, str]]:
    if not arguments:
        return list(DEFAULT_THEOREMS)
    if len(arguments) % 2:
        raise ValueError("theorem arguments must be MODULE THEOREM pairs")
    pairs = list(zip(arguments[::2], arguments[1::2]))
    for module, theorem in pairs:
        module_path(module)
        if not re.fullmatch(IDENT, theorem):
            raise ValueError(f"invalid theorem identifier: {theorem!r}")
    if len(set(pairs)) != len(pairs):
        raise ValueError("duplicate theorem pair")
    return pairs


def validate_assumptions(output: str) -> list[str]:
    """Reject missing/malformed output, even if a compiler returned status zero."""
    lines = output.splitlines()
    if any(re.search(r"\b(?:Error|Anomaly|Fatal error):", line) for line in lines):
        raise ValueError("compiler error in assumption output")
    headers = [i for i, line in enumerate(lines)
               if line.strip() in ("Axioms:", "Closed under the global context")]
    if len(headers) != 1:
        raise ValueError("expected exactly one complete Coq assumption report")
    start = headers[0]
    if lines[start].strip() == "Closed under the global context":
        if any(line.strip() for line in lines[start + 1:]):
            raise ValueError("unexpected text after the closed-context report")
        return []
    names = []
    for line in lines[start + 1:]:
        if not line.strip() or line[0].isspace():
            continue  # indented lines continue the preceding axiom's type
        match = re.fullmatch(rf"({QUALIFIED})(?:\s*:.*)?", line)
        if not match:
            raise ValueError(f"unrecognized assumption output: {line!r}")
        names.append(match.group(1))
    if not names or len(names) != len(set(names)):
        raise ValueError("empty or duplicate axiom declarations")
    unexpected = set(names) - ALLOWED_AXIOMS
    if unexpected:
        raise ValueError("non-standard axioms: " + ", ".join(sorted(unexpected)))
    return sorted(names)


def run_command(root: Path, command: list[str], log: Path, timeout: float) -> int:
    """Retain all output; a timeout terminates the entire build process group."""
    with log.open("w", encoding="utf-8") as stream:
        stream.write("$ " + shlex.join(command) + "\n")
        stream.flush()
        try:
            process = subprocess.Popen(command, cwd=root, stdout=stream,
                                       stderr=subprocess.STDOUT, start_new_session=True)
        except OSError as error:
            stream.write(f"Cannot start command: {error}\n")
            return 127
        try:
            return process.wait(timeout=timeout)
        except (subprocess.TimeoutExpired, KeyboardInterrupt) as error:
            try:
                os.killpg(process.pid, signal.SIGTERM)
            except ProcessLookupError:
                pass
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                pass
            # A child may outlive the group leader, so do not rely on wait()
            # alone to conclude that the entire build has stopped.
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            process.wait()
            if isinstance(error, KeyboardInterrupt):
                raise
            stream.write(f"\nTIMEOUT after {timeout:g}s; build process group terminated.\n")
            return 124


def source_inventory(root: Path) -> tuple[list[str], list[str]]:
    listed = [token for token in shlex.split((root / "_CoqProject").read_text(), comments=True)
              if token.endswith(".v")]
    actual = sorted(path.relative_to(root).as_posix()
                    for folder in ("proofs", "generated")
                    for path in (root / folder).rglob("*.v"))
    problems = []
    if not actual or not any(name.startswith("proofs/") for name in actual):
        problems.append("no proof sources found")
    if len(listed) != len(set(listed)):
        problems.append("duplicate .v entry in _CoqProject")
    for name in sorted(set(actual) - set(listed)):
        problems.append(f"unlisted source (including untracked files): {name}")
    for name in sorted(set(listed) - set(actual)):
        problems.append(f"missing or outside-project source: {name}")
    return actual, problems


def dependency_graph(text: str, sources: list[str]) -> dict[str, set[str]]:
    proofs = {name for name in sources if name.startswith("proofs/")}
    graph: dict[str, set[str]] = {}
    for line in text.replace("\\\n", " ").splitlines():
        if ":" not in line:
            continue
        left, right = line.split(":", 1)
        targets = [name for name in shlex.split(left) if name.endswith(".vo")]
        if not targets:
            continue
        for target in targets:
            source = target[:-1]  # .vo -> .v
            if source not in proofs:
                continue
            tokens = shlex.split(right)
            if source not in tokens or source in graph:
                raise ValueError(f"malformed/duplicate dependency rule for {source}")
            dependencies = {name[:-1] for name in tokens if name.endswith(".vo")
                            and name.startswith("proofs/")}
            if not dependencies <= proofs:
                raise ValueError(f"unknown proof dependency in {source}")
            graph[source] = dependencies
    if set(graph) != proofs:
        raise ValueError("missing coqdep proof rules: " + ", ".join(sorted(proofs - graph.keys())))
    return graph


def makefile_audit_roots(text: str) -> set[str]:
    roots = set()
    for line in text.replace("\\\n", " ").splitlines():
        if not line.startswith("\t"):
            continue
        tokens = shlex.split(line, comments=True)
        if tokens[:2] != ["bash", "pipeline/assumptions.sh"]:
            continue
        if len(tokens) != 4:
            raise ValueError("malformed Makefile assumption recipe: " + line.strip())
        parse_pairs(tokens[2:])
        roots.add(module_path(tokens[2]))
    return roots


def closure(graph: dict[str, set[str]], roots: set[str]) -> set[str]:
    reached, pending = set(), list(roots)
    while pending:
        name = pending.pop()
        if name not in reached:
            reached.add(name)
            pending.extend(graph[name])
    return reached


def unwired_boundary(name: str) -> str | None:
    parts = name.split("/")
    indices = [i for i, part in enumerate(parts) if part == "Unwired"]
    return "/".join(parts[:indices[-1] + 1]) + "/" if indices else None


def check_structure(root: Path, sources: list[str], pairs: list[tuple[str, str]]) -> dict:
    graph = dependency_graph((root / ".CoqMakefile.d").read_text(), sources)
    kept = json.loads((root / "pipeline/discipline-kept.json").read_text())
    if not isinstance(kept, dict):
        raise ValueError("standalone registry must map modules to explicit reasons")
    if any(not isinstance(reason, str) or not reason.strip() for reason in kept.values()):
        raise ValueError("each registered standalone proof needs a reason")
    standalone = makefile_audit_roots((root / "Makefile").read_text())
    standalone |= {module_path(module) for module in kept}
    standalone |= {module_path(module) for module, _ in pairs}
    roots = standalone | {module_path(MAIN)}
    if not roots <= graph.keys():
        raise ValueError("unknown audit roots: " + ", ".join(sorted(roots - graph.keys())))
    main_reached = closure(graph, {module_path(MAIN)})
    all_reached = closure(graph, roots)
    problems = []
    for source, targets in graph.items():
        for target in sorted(targets):
            boundary = unwired_boundary(target)
            if boundary and not source.startswith(boundary):
                problems.append(f"Unwired boundary crossed: {source} imports {target}")
    orphans = sorted(name for name in graph if name not in all_reached and not unwired_boundary(name))
    problems.extend("unregistered standalone/orphan proof: " + name for name in orphans)
    return {
        "proof_modules": len(graph), "main_import_closure": sorted(main_reached),
        "standalone_only": sorted(all_reached - main_reached),
        "registered_reasons": kept,
        "staged_unwired": sorted(name for name in graph if unwired_boundary(name)),
        "problems": problems,
    }


def write_interface_inventory(root: Path, sources: list[str], destination: Path) -> None:
    """Informational source index, deliberately not a list of unproved claims."""
    lines = ["SOURCE INTERFACE INVENTORY (heuristic, not a proof-status verdict)",
             "Includes already-proved interfaces. Inspect the named definitions and theorem premises.",
             "Print Assumptions does not list a theorem's explicit hypotheses.",
             "Main theorem entry points are recorded in report.json.\n"]
    for name in sources:
        if not name.startswith("proofs/"):
            continue
        text = (root / name).read_text(encoding="utf-8")
        for match in re.finditer(r"(?m)^(?:Definition|Record|Class|Inductive)\s+(\w+)\b", text):
            tail = re.split(r"\.(?=\s|$)", text[match.end():], maxsplit=1)[0]
            if re.search(r":\s*Prop\b", tail):
                line = text.count("\n", 0, match.start()) + 1
                lines.append(f"{name}:{line}: {match.group(1)}")
    destination.write_text("\n".join(lines) + "\n", encoding="utf-8")


def audit(root: Path, pairs: list[tuple[str, str]], full_build: bool,
          build_timeout: float, assumption_timeout: float) -> tuple[int, Path]:
    output_root = root / "build/audit"
    output_root.mkdir(parents=True, exist_ok=True)
    output = Path(tempfile.mkdtemp(prefix=time.strftime("%Y%m%d-%H%M%S-"), dir=output_root))
    report = {"toolchain": os.environ.get("SM64_PROOF_SWITCH", "sm64-item-proof"),
              "scope": "all _CoqProject modules" if full_build else "MainTheorem and requested module dependencies",
              "theorems": pairs, "checks": []}

    def record(name: str, status: str, detail: str, **extra) -> None:
        report["checks"].append(dict(name=name, status=status, detail=detail, **extra))
        print(f"{status}: {name}: {detail}", flush=True)

    print(f"Demo proof audit. Logs: {output.relative_to(root)}", flush=True)
    sources, inventory_problems = source_inventory(root)
    for module, _ in pairs:
        if module_path(module) not in sources:
            inventory_problems.append("requested module not in source inventory: " + module)
    record("source inventory", "FAIL" if inventory_problems else "PASS",
           f"{len(sources)} source files; {len(inventory_problems)} inventory problems",
           problems=inventory_problems)
    targets = sorted({module_path(MAIN)[:-1] + "vo"} |
                     {module_path(module)[:-1] + "vo" for module, _ in pairs})
    build = ["bash", "pipeline/build.sh"] + (
        ["proofs"] if full_build else ["audit-build", "AUDIT_VO_TARGETS=" + " ".join(targets)])
    print("Running build (" + report["scope"] + ")...", flush=True)
    build_rc = run_command(root, build, output / "build.log", build_timeout)
    record("build", "PASS" if build_rc == 0 else "FAIL", f"exit {build_rc}; see build.log")
    for name, script in [("proof holes", "check-no-admitted.sh"), ("link hygiene", "check-link-hygiene.sh")]:
        rc = run_command(root, ["bash", "pipeline/" + script], output / (name.replace(" ", "-") + ".log"), 120)
        record(name, "PASS" if rc == 0 else "FAIL", f"exit {rc}; includes untracked source files")
    if build_rc or inventory_problems:
        record("assumptions", "SKIP", "build/inventory failed; do not audit potentially stale compiled objects")
        record("integration", "SKIP", "build/inventory failed; do not trust a stale dependency graph")
    else:
        for index, (module, theorem) in enumerate(pairs, start=1):
            print(f"Checking assumptions {index}/{len(pairs)}: {module}.{theorem}...", flush=True)
            log = output / f"assumptions-{index}.log"
            rc = run_command(root, ["bash", "pipeline/assumptions.sh", module, theorem], log, assumption_timeout)
            name = f"assumptions {module}.{theorem}"
            if rc:
                record(name, "FAIL", f"exit {rc}; see {log.name}")
                continue
            try:
                names = validate_assumptions(log.read_text(encoding="utf-8"))
                record(name, "PASS", f"{len(names)} allowed foundations; see {log.name}", axioms=names)
            except ValueError as error:
                record(name, "FAIL", f"{error}; see {log.name}")
        try:
            structure = check_structure(root, sources, pairs)
            report["integration"] = structure
            record("integration", "FAIL" if structure["problems"] else "PASS",
                   f"{len(structure['main_import_closure'])}/{structure['proof_modules']} modules in MainTheorem's import closure; "
                   f"{len(structure['standalone_only'])} standalone-only; {len(structure['problems'])} problems",
                   problems=structure["problems"])
        except (ValueError, OSError) as error:
            record("integration", "FAIL", str(error))
    write_interface_inventory(root, sources, output / "interfaces.txt")
    passed = all(check["status"] == "PASS" for check in report["checks"])
    report["passed"] = passed
    report["caution"] = "Mechanical hygiene only. Explicit hypotheses, live reachability, and statement fidelity require review."
    (output / "report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    summary = "\n".join(f"{check['status']}: {check['name']}: {check['detail']}" for check in report["checks"])
    verdict = "PASS (mechanical checks only; not a completed game proof)" if passed else "FAIL (see logs and report.json)"
    (output / "summary.txt").write_text(summary + "\nVERDICT: " + verdict + "\n" + report["caution"] + "\n", encoding="utf-8")
    print("VERDICT: " + verdict + "\n" + report["caution"], flush=True)
    print("Source interface index: " + str((output / "interfaces.txt").relative_to(root)), flush=True)
    return (0 if passed else 1), output


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--full-build", action="store_true", help="build every registered generated/proof module")
    parser.add_argument("--build-timeout", type=float, default=600, help="build time limit in seconds (default 600)")
    parser.add_argument("--assumption-timeout", type=float, default=180, help="per-theorem time limit (default 180)")
    parser.add_argument("theorems", nargs="*", metavar="MODULE THEOREM", help="optional pairs, replacing the three default capstones")
    args = parser.parse_args()
    if any(not math.isfinite(value) or value <= 0
           for value in (args.build_timeout, args.assumption_timeout)):
        parser.error("timeouts must be finite and positive")
    try:
        pairs = parse_pairs(args.theorems)
    except ValueError as error:
        parser.error(str(error))
    root = Path(__file__).resolve().parent.parent
    try:
        return audit(root, pairs, args.full_build, args.build_timeout, args.assumption_timeout)[0]
    except (OSError, ValueError) as error:
        print(f"FAIL: audit could not complete: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
