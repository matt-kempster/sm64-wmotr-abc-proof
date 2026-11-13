#!/usr/bin/env python3
"""Reading aid (NOT a proof input): for each native name on argv[2:], find its C
body under argv[1] (vendor/sm64/src) and list the cross-slot looking operations
it performs directly (spawns, deletions, parent / Mario / global stores, calls).
Usage: native_scan.py <src dir> name..."""
import os
import re
import sys

src = sys.argv[1]
names = sys.argv[2:]
texts = {}
for d, _, fs in os.walk(src):
    for f in fs:
        if f.endswith(".c"):
            p = os.path.join(d, f)
            texts[p] = open(p, errors="replace").read()


def body(name):
    pat = re.compile(r"^[A-Za-z_][\w \*]*\b" + re.escape(name) + r"\s*\([^;{]*\)\s*\{", re.M)
    for p, t in texts.items():
        m = pat.search(t)
        if m:
            i = m.end()
            depth = 1
            while depth and i < len(t):
                depth += {"{": 1, "}": -1}.get(t[i], 0)
                i += 1
            return p, t[m.end():i]
    return None, ""


for n in names:
    p, b = body(n)
    if not p:
        print(n, ": NOT FOUND")
        continue
    calls = sorted(set(re.findall(r"\b([a-z_][a-z0-9_]*)\s*\(", b)) - {"if", "for", "while", "switch", "return", "sizeof"})
    stores = sorted(set(re.findall(r"((?:o->parentObj|gMarioObject|gMarioState|gMarioStates|[a-zA-Z_]\w*)->\w+(?:\[[^\]]*\])?)\s*(?:[-+|&^]?=(?!=)|\+\+|--)", b)))
    globs = sorted(set(re.findall(r"\b((?:g|s)[A-Z]\w*)\s*(?:[-+|&^]?=(?!=)|\+\+|--)", b)))
    print("%s [%s] %d lines\n  calls: %s\n  stores: %s\n  globals: %s" % (
        n, os.path.relpath(p, src), b.count("\n"), " ".join(calls), " ".join(stores), " ".join(globs)))
