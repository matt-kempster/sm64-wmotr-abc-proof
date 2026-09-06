#!/usr/bin/env python3
"""Bounded controller-route discovery from the declared ledge initialization.

Every candidate starts a fresh game and replays the same mesh detour prefix.
This is experimental search, not a proof or an exhaustive controller search.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1] / "build/cog-placement"
spec = importlib.util.spec_from_file_location("trace_check", HERE / "check-trace.py")
checker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checker)


def measure(trial):
    result, trace = checker.check(trial)
    frames = sorted({int(f["rel"]) for k, f in trace
                     if k == "CAIR" and f["pedroCandidate"] == "1"})
    runs = []
    for frame in frames:
        if runs and runs[-1][-1] + 1 == frame:
            runs[-1].append(frame)
        else:
            runs.append([frame])
    return {"trial": str(trial), "trace_sha256": result["trace_sha256"],
            "counts": result["counts"], "pedro_frames": frames,
            "longest_consecutive_pedro_frames": max(map(len, runs), default=0)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("name", help="fresh search directory name")
    parser.add_argument("--first", type=int, default=0)
    parser.add_argument("--count", type=int, default=6)
    parser.add_argument("--suite", choices=("rim", "phase", "brake", "tip", "tip_brake",
                                           "turn_fine", "brake_early", "edge_fine"), default="rim")
    args = parser.parse_args()
    candidates = [(x, turn, jump, 0) for turn in (136, 132, 140)
                  for jump in (None, 132) for x in (1370, 1410, 1450)]
    if args.suite == "phase":
        candidates = [(1410, 136, None, delay) for delay in (4, 8, 12, 16, 24, 32, 48, 64, 80, 96, 128, 160)]
    if args.suite == "brake":
        candidates = [(1410, stop, None, 0) for stop in (130,131,132,133,134,135)]
    if args.suite == "turn_fine":
        candidates = [(1410, turn, None, 0) for turn in (129,130,131,133,134,135,137)]
    if args.suite == "brake_early":
        candidates = [(1410, stop, None, 0) for stop in (122,124,126,128,130,132)]
    if args.suite == "edge_fine":
        candidates = [(x, 134, None, 0) for x in range(1376, 1421, 4)]
    if args.suite == "tip":
        candidates = [(-radius, 130, None, 0) for radius in (298,302,304,306,308,310)]
    if args.suite == "tip_brake":
        candidates = [(-radius, start, None, 0) for start in (126,128,130) for radius in (304,306)]
    if not args.name.isidentifier() or args.first < 0 or args.count < 1 \
            or args.first + args.count > len(candidates):
        parser.error("invalid name or candidate range")
    out = ROOT / args.name
    out.mkdir()
    results = []
    for index in range(args.first, args.first + args.count):
        x, turn, jump, delay = candidates[index]
        inputs = out / f"input-{index}.csv"
        waypoints = out / f"waypoints-{index}.csv"
        inputs.write_text(f"{76+delay},{80+delay},0,0,A\n" +
                          (f"{jump+delay},{jump+delay},0,0,A\n" if jump else ""))
        route = [(0,65,1450,-660,75), (66,100,1320,-720,65),
                 (101,114,1300,-965,65), (115,turn-1,x,-1240,80),
                 (146 if args.suite == "brake" else
                  134 if args.suite == "brake_early" else turn,310,1490,-873,80)]
        waypoints.write_text("".join(f"{a+delay},{b+delay},{x},{z},{mag}\n"
                                     for a,b,x,z,mag in route))
        if args.suite in ("tip", "tip_brake"):
            waypoints.write_text("0,65,1450,-660,75\n66,100,1320,-720,65\n"
                                 "101,114,1300,-965,65\n"
                                 f"115,{turn-1},1410,-1240,80\n"
                                 f"{turn},310,{x},0,80,{'cog_brake' if args.suite == 'tip_brake' else 'cog'},0.5\n")
        name = f"{args.name}_{index:02d}_us"
        command = [sys.executable, str(HERE / "run.py"), "us", name,
                   "--inputs", str(inputs), "--waypoints", str(waypoints),
                   "--trace-calls", "--video-frames", str(690 + delay)]
        with (out / f"launch-{index}.log").open("w") as log:
            completed = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT)
        record = {"index": index, "suite": args.suite, "outer_x": x, "turn": turn, "jump": jump,
                  "delay": delay,
                  "command": command, "exit": completed.returncode}
        if completed.returncode == 0:
            record.update(measure(ROOT / name))
        results.append(record)
        (out / "results.json").write_text(json.dumps(results, indent=2) + "\n")
        print(json.dumps({key: record[key] for key in (
            "index", "suite", "outer_x", "turn", "jump", "delay", "exit",
            "pedro_frames", "longest_consecutive_pedro_frames") if key in record}), flush=True)
        if completed.returncode:
            raise SystemExit(completed.returncode)


if __name__ == "__main__":
    main()
