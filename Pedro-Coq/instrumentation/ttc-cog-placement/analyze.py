#!/usr/bin/env python3
"""Inspect trial observations; this is discovery tooling, not a proof checker."""
import argparse
import csv
from pathlib import Path
import sys


def rows(path, kind):
    return [dict(field.split("=", 1) for field in line.split(",")[2:])
            for line in path.read_text().splitlines() if line.startswith(kind + ",")]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("trial", type=Path)
    parser.add_argument("--step", type=int, default=10)
    parser.add_argument("--first", type=int, default=0)
    parser.add_argument("--last", type=int, default=12000)
    parser.add_argument("--replay", type=Path, help="export recorded controller inputs")
    args = parser.parse_args()
    if args.step < 1:
        parser.error("step must be positive")
    trace = args.trial / "trace.csv"
    frames = rows(trace, "CFRAME")
    columns = ["rel", "x", "y", "z", "speed", "vy", "yaw", "action",
               "floorOwner", "floorType", "floorHeight", "ceilHeight", "particles", "seed"]
    writer = csv.DictWriter(sys.stdout, fieldnames=columns, extrasaction="ignore")
    writer.writeheader()
    for frame in frames:
        rel = int(frame["rel"])
        if args.first <= rel <= args.last and (rel - args.first) % args.step == 0:
            writer.writerow(frame)
    if args.replay:
        inputs = rows(trace, "CINPUT")
        intervals = []
        for row in inputs:
            rel = int(row["rel"])
            value = (int(row["x"]), int(row["y"]),
                     "".join(button for button in "ABZRL" if row[button] == "1") or "-")
            if intervals and intervals[-1][1] + 1 == rel and intervals[-1][2:] == value:
                intervals[-1] = (intervals[-1][0], rel, *value)
            else:
                intervals.append((rel, rel, *value))
        with args.replay.open("x", newline="") as output:
            csv.writer(output).writerows(intervals)


if __name__ == "__main__":
    main()
