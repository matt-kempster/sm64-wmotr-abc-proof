#!/usr/bin/env python3
"""Check internal consistency of observations, not formal gameplay reachability."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import struct


def f32(value):
    return struct.unpack(">f", struct.pack(">f", float(value)))[0]


def rng(seed):
    if seed == 22026:
        seed = 0
    first = ((seed & 255) << 8) ^ seed
    seed = ((first & 255) << 8) + ((first & 65280) >> 8)
    first = ((first & 255) << 1) ^ seed
    second = (first >> 1) ^ 65408
    return (second ^ 33152) if first & 1 else (0 if second == 43605 else second ^ 8180)


def events(trial):
    result = []
    for line in (trial / "trace.csv").read_text().splitlines():
        parts = line.split(",")
        if parts[0] == "COG_ERROR":
            raise ValueError(line)
        result.append((parts[0], dict(field.split("=", 1) for field in parts[2:])))
    return result


def normalized(trial, trace):
    manifest = json.loads((trial / "manifest.json").read_text())
    pool = manifest["symbols"]["gObjectPool"]
    result = []
    for kind, fields in trace:
        fields = dict(fields)
        for key in ("floor", "ceil", "surface", "oldFloor", "newFloor", "caller", "behavior"):
            fields.pop(key, None)
        for key in ("object", "floorOwner", "ceilOwner", "owner"):
            if key in fields:
                address = int(fields[key], 16)
                fields[key] = (address - pool) // 0x260 if address else -1
        result.append((kind, fields))
    return result


def check(trial):
    manifest = json.loads((trial / "manifest.json").read_text())
    summary = json.loads((trial / "summary.json").read_text())
    if not manifest.get("trace_calls") or not summary["cheats_disabled"] \
            or summary["emulator_exit"] or summary["observer_errors"]:
        raise ValueError("requires a completed observation-only call trace")
    trace = events(trial)
    expected = None
    counts = Counter()
    pedro = []
    input_frames, mario_frames = [], []
    for kind, fields in trace:
        counts[kind] += 1
        if kind == "CINPUT":
            input_frames.append(int(fields["rel"]))
        if kind == "CFRAME":
            mario_frames.append(int(fields["rel"]))
            observed = int(fields["seed"])
            if expected is not None and observed != expected:
                raise ValueError(f"unexplained seed change at frame {fields['rel']}")
            expected = observed
        elif kind == "CRNG":
            before, after = int(fields["before"]), int(fields["after"])
            if before != expected or rng(before) != after or after != int(fields["result"]):
                raise ValueError(f"RNG chain mismatch at call {fields['seq']}")
            if int(fields["seq"]) != counts[kind] - 1:
                raise ValueError("nonconsecutive RNG call indices")
            expected = after
        elif kind == "CAIR":
            if int(fields["seq"]) != counts[kind] - 1:
                raise ValueError("nonconsecutive air-quarter-step indices")
            candidate = int(fields["floor"], 16) != 0 \
                and f32(fields["qy"]) <= f32(fields["floorHeight"]) \
                and f32(f32(fields["ceilHeight"]) - f32(fields["floorHeight"])) <= 160
            if candidate != bool(int(fields["pedroCandidate"])):
                raise ValueError("inconsistent Pedro branch classification")
            if candidate:
                if fields["result"] != "1" or fields["oldX"] != fields["newX"] \
                        or fields["oldZ"] != fields["newZ"] \
                        or fields["oldFloor"] != fields["newFloor"] \
                        or fields["newY"] != fields["floorHeight"]:
                    raise ValueError("Pedro candidate lacks the expected branch effects")
                pedro.append(fields)
    if not mario_frames or mario_frames != list(range(len(mario_frames))) \
            or input_frames != mario_frames:
        raise ValueError("requires one controller record and Mario snapshot for every TTC frame")
    result = {"version": manifest["version"], "counts": dict(counts),
              "pedro_branch_count": len(pedro), "pedro_branches": pedro,
              "trace_sha256": hashlib.sha256((trial / "trace.csv").read_bytes()).hexdigest(),
              "scope": "observed call/seed consistency; no normal-entry or indefinite-stasis proof"}
    (trial / "consistency.json").write_text(json.dumps(result, indent=2) + "\n")
    return result, trace


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("trial", type=Path)
    parser.add_argument("--compare", type=Path)
    args = parser.parse_args()
    result, trace = check(args.trial)
    if args.compare:
        other, other_trace = check(args.compare)
        if normalized(args.trial, trace) != normalized(args.compare, other_trace):
            raise ValueError("observed logical fields differ across the compared trials")
        result["comparison"] = "observed logical fields agree (raw addresses excluded)"
        result["compared_trace_sha256"] = other["trace_sha256"]
    result.pop("pedro_branches")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
