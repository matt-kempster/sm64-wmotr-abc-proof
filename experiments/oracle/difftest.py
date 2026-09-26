"""Differential test: replay every recorded frame through the model, tally outcomes.

    python3 difftest.py SEED            (frames from ~/sm64-oracle/rec/SEED, see record.py)

Per frame, one of:
  MATCH     the model ran to completion, made the same external calls with the same
            arguments, and its final memory equals the real RAM (placed globals and
            typed heap objects)
  DIFF      ran to completion, memory differs
  DIVERGE   the model's external-call sequence/arguments departed from the real one
  STUCK     the model has no execution (CompCert UB, or an interpreter limitation)
"""
import collections
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import export_frame

REPLAY = f"{HERE}/extract/drv/replay"
SEED = sys.argv[1] if len(sys.argv) > 1 else "1"
REC = os.path.expanduser(f"~/sm64-oracle/rec/{SEED}")


def classify(out, rc):
    if "DONE" in out:
        return ("MATCH" if rc == 0 else "DIFF"), ""
    m = re.search(r"STUCK: (.*) at: (.*)\n  stack: (.*)\n  oracle: (.*)", out)
    if not m:
        return "CRASH", out[-300:]
    why, at, stack, oracle = m.groups()
    if oracle != "-":
        return "DIVERGE", oracle
    return "STUCK", f"{stack.split(' <- ')[-1]}: {why} at {at}"


def main():
    frames = sorted(f for f in os.listdir(REC) if f.endswith(".pkl.zlib"))
    tally, reasons, stats = collections.Counter(), collections.defaultdict(list), []
    with tempfile.TemporaryDirectory(dir=os.path.expanduser("~/sm64-oracle")) as tmp:
        for f in frames:
            export_frame.main(f"{REC}/{f}", tmp)
            p = subprocess.run(["bash", "-c", f"ulimit -s unlimited; exec {REPLAY} {tmp}"],
                               capture_output=True, text=True)
            kind, why = classify(p.stdout + p.stderr, p.returncode)
            tally[kind] += 1
            reasons[(kind, why)].append(f.split(".")[0])
            m = re.search(r"changed (\d+) of them; (\d+) of those were computed by the model", p.stdout)
            if m:
                stats.append((int(m.group(1)), int(m.group(2))))
            print(f"{f.split('.')[0]} {kind} {why}", flush=True)
    print(f"\n== {len(frames)} frames: " + ", ".join(f"{k} {v}" for k, v in tally.most_common()))
    if stats:
        ch = sum(a for a, _ in stats) / len(stats)
        mc = sum(b for _, b in stats) / len(stats)
        print(f"   completed frames changed {ch:.1f} bytes of placed globals on average, "
              f"{mc:.1f} of them computed by the model")
    for (kind, why), fs in sorted(reasons.items(), key=lambda kv: -len(kv[1])):
        if kind != "MATCH":
            print(f"   {len(fs):4d} x {kind}: {why}   (e.g. {fs[0]})")


if __name__ == "__main__":
    main()
