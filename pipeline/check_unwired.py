#!/usr/bin/env python3
"""Enforce the 'unused => unwired' invariant on proofs/.

Two checks over the proof-only `Require` graph + the directory layout:

  1. FIREWALL.  No file *outside* an `Unwired/` subtree may `Require` a file
     *inside* it (using the innermost `Unwired/` boundary, so nesting works).
     => the instant an Unwired file is actually used, it must be promoted out.

  2. NO ORPHANS.  Every `.v` *not* under any `Unwired/` must be reachable (via
     Require edges) from a file marked as a root, or be marked itself. Markers
     are header comments:
         (* spine-root: <why> *)   a capstone we build toward
         (* kept: <why> *)         a standalone result kept on purpose (demo,
                                   reusable lemma) that is intentionally not
                                   load-bearing and not staged in Unwired/
     => a genuinely unused new lemma left in a spine dir is flagged; move it to
        an Unwired/ dir or justify it with a marker.

Exit status 0 if clean, 1 if any violation. Pure stdlib; reads only proofs/*.v.
Run from the repo root:  python3 pipeline/check_unwired.py
"""
import glob
import os
import re
import sys

PROOFS = "proofs"
MARKER_RE = re.compile(r"\(\*\s*@?(spine-root|kept)\b\s*:", re.I)
REQUIRE_RE = re.compile(r"From\s+SM64\.Proofs\s+Require(?:\s+Import)?\s+(.*?)\.", re.S)


def innermost_unwired(path):
    """Deepest '.../Unwired/' prefix on path, else None.

    a/Unwired/b/Unwired/c.v -> 'a/Unwired/b/Unwired/'
    """
    parts = path.split("/")
    idxs = [i for i, p in enumerate(parts) if p == "Unwired"]
    return "/".join(parts[: idxs[-1] + 1]) + "/" if idxs else None


def main():
    files = sorted(glob.glob(f"{PROOFS}/**/*.v", recursive=True))
    if not files:
        print("check_unwired: no proof files found (run from repo root)", file=sys.stderr)
        return 1

    loc, text, marker = {}, {}, {}
    dup = []
    for f in files:
        b = os.path.basename(f)[:-2]
        if b in loc:
            dup.append((b, loc[b], f))
        loc[b] = f
        t = open(f, encoding="utf-8").read()
        text[b] = t
        m = MARKER_RE.search(t)
        marker[b] = m.group(1).lower() if m else None
    if dup:
        for b, a, c in dup:
            print(f"check_unwired: duplicate basename {b}: {a} and {c}", file=sys.stderr)
        return 1  # basename resolution (and these checks) require unique names

    # proof-only Require edges A -> B
    edges = []
    for b in loc:
        for m in REQUIRE_RE.finditer(text[b]):
            for tok in m.group(1).split():
                if tok not in ("Import", "Export") and tok in loc:
                    edges.append((b, tok))

    fw, orphans = [], []

    # 1. FIREWALL
    for a, b in edges:
        u = innermost_unwired(loc[b])
        if u and not loc[a].startswith(u):
            fw.append((a, b, u))

    # 2. NO ORPHANS (only files NOT under any Unwired/)
    adj = {}
    for a, b in edges:
        adj.setdefault(a, []).append(b)
    roots = [b for b in loc if marker[b]]
    reach, stack = set(), list(roots)
    while stack:
        x = stack.pop()
        if x in reach:
            continue
        reach.add(x)
        stack += adj.get(x, [])
    for b in sorted(loc):
        if innermost_unwired(loc[b]):
            continue  # staged in Unwired/, exempt
        if b not in reach:
            orphans.append(b)

    ok = not fw and not orphans
    if fw:
        print("FIREWALL violations (spine file imports into an Unwired/ subtree):")
        for a, b, u in fw:
            print(f"  {loc[a]}")
            print(f"      imports {b}, which lives under {u}")
            print(f"      => promote {b} out of {u} (git mv up into the spine).")
    if orphans:
        print("ORPHAN violations (outside Unwired/, not reachable from a root, unmarked):")
        for b in orphans:
            print(f"  {loc[b]}")
            print(f"      => wire it in, move it under an Unwired/ dir,")
            print(f"         or add a header marker:  (* kept: <why> *)")
    if ok:
        nU = sum(1 for b in loc if not innermost_unwired(loc[b]))
        print(
            f"check_unwired OK: {len(loc)} files; firewall clean; "
            f"{nU} non-Unwired files all reachable from {len(roots)} marked roots."
        )
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
