#!/usr/bin/env python3
"""Export checked, ordered observations for an explicit gameplay-frame window."""
import argparse
from collections import defaultdict
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("trace_check", HERE / "check-trace.py")
checker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checker)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("trial", type=Path)
    parser.add_argument("--first", type=int, required=True)
    parser.add_argument("--last", type=int, required=True)
    args = parser.parse_args()
    if args.first < 0 or args.last < args.first:
        parser.error("invalid inclusive frame window")
    result, trace = checker.check(args.trial)
    manifest = json.loads((args.trial / "manifest.json").read_text())
    if not manifest.get("trace_path"):
        parser.error("requires a trace recorded with --trace-path")
    by_frame = defaultdict(list)
    for kind, fields in trace:
        frame = int(fields.get("rel", -1))
        if args.first <= frame <= args.last:
            by_frame[frame].append({"kind": kind, **fields})
    rows = []
    for frame in range(args.first, args.last + 1):
        events = by_frame[frame]
        if sum(event["kind"] == "CINPUT" for event in events) != 1:
            raise ValueError(f"window lacks an initialized-TTC input at frame {frame}")
        geometry = [e for e in events if e["kind"] == "CPATH" and
                    e["routine"] == "update_mario_geometry_inputs" and e["phase"] == "exit"]
        finished = [e for e in events if e["kind"] == "CPATH" and
                    e["routine"] == "execute_mario_action" and e["phase"] == "exit"]
        rows.append({"frame": frame,
                     "pedro_returns": sum(e["kind"] == "CAIR" and e["pedroCandidate"] == "1"
                                          for e in events),
                     "geometry_updates": geometry, "player_returns": finished,
                     "events": events})
    report = {"version": manifest["version"], "trace_sha256": result["trace_sha256"],
              "first": args.first, "last": args.last, "frames": rows,
              "scope": "Ordered observations, including actual/attempted positions, selected "
                       "triangles, action changes, particle requests and RNG calls. "
                       "No claim of normal level entry or preservation beyond this window."}
    path = args.trial / f"path-{args.first}-{args.last}.json"
    path.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({"report": str(path), "frames": len(rows),
                      "pedro_returns": sum(row["pedro_returns"] for row in rows)}))


if __name__ == "__main__":
    main()
