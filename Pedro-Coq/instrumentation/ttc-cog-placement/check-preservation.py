#!/usr/bin/env python3
"""Find finite, successive close-gap action updates in an observed trace.

This is a deliberately narrow discovery check, outside the Coq trusted base.
Other actions require their own complete preserving-path check. A positive
result neither proves normal entry nor an indefinitely repeatable strategy.
"""
import argparse
from collections import defaultdict
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("trace_check", HERE / "check-trace.py")
checker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checker)


def position(fields, prefix=""):
    keys = (prefix + axis.upper() if prefix else axis for axis in "xyz")
    return tuple(checker.f32(fields[key]) for key in keys)


def inspect(trial, minimum=2, require_upper_fixed=True):
    if minimum < 2:
        raise ValueError("a successive-update witness requires at least two updates")
    consistency, trace = checker.check(trial)
    manifest = json.loads((trial / "manifest.json").read_text())
    if not manifest.get("trace_path"):
        raise ValueError("complete action-path observations are required")
    frames = defaultdict(list)
    snapshots = {}
    pool = manifest["symbols"]["gObjectPool"]
    lower = f"{pool + 29 * 0x260:08x}"
    upper = f"{pool + 32 * 0x260:08x}"
    for kind, fields in trace:
        rel = int(fields["rel"])
        frames[rel].append((kind, fields))
        if kind == "CFRAME":
            snapshots[rel] = fields
    candidates, accepted = [], []
    for rel, events in sorted(frames.items()):
        air = [f for k, f in events if k == "CAIR"]
        if not any(f["pedroCandidate"] == "1" for f in air):
            continue
        reasons = []
        path = [f for k, f in events if k == "CPATH"]
        action = [f for f in path if f["routine"] == "execute_mario_action"]
        geometry = [f for f in path if f["routine"] == "update_mario_geometry_inputs"
                    and f["phase"] == "exit"]
        if len(action) != 2 or [f["phase"] for f in action] != ["enter", "exit"]:
            reasons.append("missing complete Mario action update")
        else:
            first = events.index(("CPATH", action[0]))
            last = events.index(("CPATH", action[1]))
            if any(not first < index < last for index, (kind, _) in enumerate(events)
                   if kind == "CAIR"):
                reasons.append("air call lies outside the complete Mario action update")
        if len(geometry) != 1:
            reasons.append("missing unique geometry refresh")
        anchor = position(air[0], "old")
        if rel not in snapshots or rel + 1 not in snapshots:
            reasons.append("missing bracketing input-poll snapshots")
        elif any(position(snapshots[f]) != anchor for f in (rel, rel + 1)):
            reasons.append("Mario moves between bracketing snapshots")
        if any(position(f) != anchor for f in path) or any(
                position(f, "old") != anchor or position(f, "new") != anchor for f in air):
            reasons.append("Mario moves at an observed internal boundary")
        if any(f["platform"] != "00000000" for f in path):
            reasons.append("Mario has a platform reference")
        # Each actual air call must reject a nonzero, inward horizontal query
        # while the retained floor is more than 100 units beneath Mario.
        # A zero-speed impact on an already supporting floor cannot pass.
        if any(f["pedroCandidate"] != "1" or not int(f["input"], 16) & 4
               or checker.f32(f["oldFloorHeight"]) + 100 >= anchor[1]
               or (checker.f32(f["ix"]), checker.f32(f["iz"])) == (anchor[0], anchor[2])
               or (checker.f32(f["qx"]), checker.f32(f["qz"])) == (anchor[0], anchor[2])
               or f["floorOwner"] != lower or f["ceilOwner"] != upper for f in air):
            reasons.append("air path is not an off-floor close-gap rejection of horizontal motion")
        if any(not int(f["input"], 16) & 4
               or checker.f32(f["floorHeight"]) + 100 >= anchor[1] for f in geometry):
            reasons.append("actual position has a supporting floor after geometry refresh")
        # Positions alone do not identify ground-pound startup as a Pedro loop.
        # Every accepted update above must execute an air call; explicitly keep
        # both ground-pound actions out of this ordinary-air witness class.
        if any(f["action"] in ("008008a9", "0080023c") for f in path + air):
            reasons.append("ground-pound path needs separate preservation analysis")
        lower_poses = {(f.get("lowerYaw"), f.get("lowerSpeed")) for f in path}
        if len(lower_poses) != 1 or any(yaw is None or float(speed) != 0
                                      for yaw, speed in lower_poses):
            reasons.append("lower cog is not at one zero-speed pose")
        upper_poses = {(f.get("upperYaw"), f.get("upperSpeed")) for f in path}
        if require_upper_fixed and (len(upper_poses) != 1 or any(
                yaw is None or float(speed) != 0 for yaw, speed in upper_poses)):
            reasons.append("upper cog is not at one zero-speed pose")
        cogs = [f for k, f in events if k == "CCOG" and f["slot"] == "29"]
        next_cogs = [f for k, f in frames.get(rel + 1, [])
                     if k == "CCOG" and f["slot"] == "29"]
        if len(cogs) != 1 or len(next_cogs) != 1 or len(lower_poses) != 1:
            reasons.append("missing bracketing lower-cog pose")
        else:
            yaw, speed = next(iter(lower_poses))
            # The interval starts after this frame's surface update. Its
            # incoming speed may have approached zero without rotating. A new
            # target may be chosen on the final update; that is recorded and
            # provides no guarantee for an additional update beyond the run.
            if any(f["yaw"] != yaw for f in cogs + next_cogs) \
                    or next_cogs[0]["speed"] != speed \
                    or position(cogs[0]) != position(next_cogs[0]):
                reasons.append("lower-cog pose changes across update boundaries")
        if require_upper_fixed:
            upper_snapshots = [f for k, f in events + frames.get(rel + 1, [])
                               if k == "CCOG" and f["slot"] == "32"]
            if len(upper_snapshots) != 2 or len(upper_poses) != 1:
                reasons.append("missing bracketing upper-cog pose")
            elif any(f["yaw"] != next(iter(upper_poses))[0] for f in upper_snapshots) \
                    or position(upper_snapshots[0]) != position(upper_snapshots[1]):
                reasons.append("upper-cog pose changes across update boundaries")
        record = {"frame": rel, "position": anchor,
                  "air_sequences": [int(f["seq"]) for f in air],
                  "rejected_because": reasons}
        candidates.append(record)
        if not reasons:
            record["lower_pose"] = list(next(iter(lower_poses)))
            record["upper_poses"] = sorted(upper_poses)
            record["targets"] = sorted({(f["lowerTarget"], f["upperTarget"]) for f in path})
            accepted.append(record)
    runs = []
    for frame in accepted:
        if runs and runs[-1][-1]["frame"] + 1 == frame["frame"] \
                and runs[-1][-1]["position"] == frame["position"] \
                and runs[-1][-1]["lower_pose"] == frame["lower_pose"] \
                and (not require_upper_fixed
                     or runs[-1][-1]["upper_poses"] == frame["upper_poses"]):
            runs[-1].append(frame)
        else:
            runs.append([frame])
    result = {
        "trace_sha256": consistency["trace_sha256"], "version": manifest["version"],
        "minimum_successive_updates": minimum,
        "require_upper_fixed": require_upper_fixed,
        "longest_checked_run": max(map(len, runs), default=0),
        "witnesses": [run for run in runs if len(run) >= minimum],
        "candidate_updates": candidates,
        "scope": "finite observed off-floor air path, fixed lower cog, and selected upper ceiling; "
                 + ("both cog poses must be fixed; " if require_upper_fixed else
                    "weaker diagnostic: upper yaw may change; ")
                 + "target changes are recorded and may end the next update's preservation; "
                 "not normal entry, formal execution, indefinite preservation, or RNG control",
    }
    name = "preservation.json" if require_upper_fixed else "preservation-lower-only.json"
    (trial / name).write_text(json.dumps(result, indent=2) + "\n")
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("trial", type=Path)
    parser.add_argument("--minimum", type=int, default=2)
    parser.add_argument("--allow-upper-rotation", action="store_true",
                        help="weaker diagnostic; does not certify both cog poses stay fixed")
    args = parser.parse_args()
    result = inspect(args.trial, args.minimum, not args.allow_upper_rotation)
    print(json.dumps({k: v for k, v in result.items() if k != "candidate_updates"}, indent=2))


if __name__ == "__main__":
    main()
