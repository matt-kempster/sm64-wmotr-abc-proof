#!/usr/bin/env python3
"""Condense an ESBMC counterexample log into a readable story.

Prints, per counterexample, the scalar assignments (skipping whole-struct
dumps) with their source location, plus the violated property.
Usage: trace.py <esbmc.log> [--all]   (default: decomp + harness lines only)
"""
import re, sys

log = open(sys.argv[1]).read().splitlines()
state_re = re.compile(r"^State \d+ file (\S+) line (\d+) column \d+ function (\S+)")
assign_re = re.compile(r"^  (\S.*?) = (.*)$")
loc = None
for line in log:
    m = state_re.match(line)
    if m:
        f, ln, fn = m.groups()
        loc = f"{f.split('/')[-1]}:{ln} {fn}"
        continue
    if line.startswith("[Counterexample]") or line.startswith("Counterexample"):
        print("=" * 60); continue
    if line.startswith("Violated property"):
        print("  >>> VIOLATED:", end=" "); loc = "VIOL"; continue
    if loc == "VIOL":
        if line.strip().startswith("file "): continue
        print(line.strip()); loc = None; continue
    a = assign_re.match(line)
    if a and loc:
        name, val = a.groups()
        if val.startswith("{ .unk00") or val.startswith("{ .header"):
            continue  # whole-struct dump
        val = re.sub(r"\s*\([01 ]+\)$", "", val)  # drop bit patterns
        print(f"  {loc:45s} {name} = {val}")
