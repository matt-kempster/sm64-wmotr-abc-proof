#!/usr/bin/env python3
"""Proof metrics dashboard: repo + git history -> docs/proof-metrics.html.

Run from the repo root:  python3 tools/proof_metrics.py
The page is fully regenerated on every run; never edit it by hand.
Stdlib only.  Typical runtime: a few seconds.

Metrics (all approximate; see the captions on the page):
  1. C function definitions per vendor/sm64/src directory vs functions linked
     (Definition f_* in generated/<tu>.v for mario + LinkedTwelve.tu_rest).
  2. Functions reachable from execute_mario_action in the linked Clight call
     graph (direct calls plus function addresses reached through data tables),
     split internal (body in the link) / external (no body: needs a premise).
  3. `Hypothesis` rows in the two capstones over time.
  4. TUs in the LinkedTwelve link over time.
  5. The finish-line estimate (docs/finish-line.html SNAPSHOTS) over time.
  6. Lines of proofs/**/*.v over time, spine vs Unwired/.
"""

import datetime as dt
import html
import os
import re
import subprocess
import sys
import time

ROOT = os.getcwd()
SRC = os.path.join(ROOT, "vendor", "sm64", "src")
GEN = os.path.join(ROOT, "generated")
OUT = os.path.join(ROOT, "docs", "proof-metrics.html")
LINKED = "proofs/MarioModel/LinkedTwelve.v"
CAP1 = "proofs/NoAImpliesNoFly/NoAImpliesNoFlyTwelve.v"
CAP2 = "proofs/WMotRRequiresA/HeightFrame.v"
FINISH = "docs/finish-line.html"
ENTRY = "execute_mario_action"
SIZE_SAMPLES = 30


# --------------------------------------------------------------------------- git

def git(*args):
    return subprocess.run(["git", *args], cwd=ROOT, capture_output=True,
                          text=True, check=True).stdout


def cat_batch(specs):
    """Read many objects (`rev:path` or blob sha) in one git cat-file call.
    Returns {spec: text or None}."""
    if not specs:
        return {}
    specs = list(dict.fromkeys(specs))
    data = "\n".join(specs).encode() + b"\n"
    out = subprocess.run(["git", "cat-file", "--batch"], cwd=ROOT, input=data,
                         capture_output=True, check=True).stdout
    res, pos = {}, 0
    for spec in specs:
        nl = out.index(b"\n", pos)
        header = out[pos:nl].decode()
        pos = nl + 1
        if header.endswith(" missing") or header.endswith(" ambiguous"):
            res[spec] = None
            continue
        size = int(header.split()[2])
        res[spec] = out[pos:pos + size].decode("utf-8", "replace")
        pos += size + 1
    return res


def file_history(path):
    """[(sha, short, iso date, path at that commit)] oldest first, following renames."""
    out = git("log", "--follow", "--name-only", "--format=@@%H\t%h\t%aI", "--", path)
    rows, cur = [], None
    for line in out.splitlines():
        if line.startswith("@@"):
            cur = line[2:].split("\t")
        elif line.strip() and cur:
            rows.append((cur[0], cur[1], cur[2], line.strip()))
            cur = None
    rows.reverse()
    return rows


def parse_date(s):
    return dt.datetime.fromisoformat(s.replace("Z", "+00:00")).astimezone(dt.timezone.utc).replace(tzinfo=None)


# ------------------------------------------------------------- 1. C functions

def strip_c(text):
    """Remove comments and string/char literals; keep preprocessor lines
    verbatim (they are resolved by select_branches)."""
    out, i, n = [], 0, len(text)
    at_line_start = True
    while i < n:
        c = text[i]
        if at_line_start:
            j = i
            while j < n and text[j] in " \t":
                j += 1
            if j < n and text[j] == "#":
                while True:     # copy directive incl. backslash continuations
                    k = text.find("\n", j)
                    if k == -1:
                        k = n
                    if k < n and text[k - 1] == "\\":
                        j = k + 1
                        continue
                    break
                out.append(text[i:k].replace("\\\n", " "))
                i = k
                continue
        at_line_start = False
        if c == "/" and i + 1 < n and text[i + 1] == "/":
            k = text.find("\n", i)
            i = n if k == -1 else k
            continue
        if c == "/" and i + 1 < n and text[i + 1] == "*":
            k = text.find("*/", i + 2)
            seg = text[i:(n if k == -1 else k + 2)]
            out.append(" " + "\n" * seg.count("\n"))
            i = n if k == -1 else k + 2
            continue
        if c in "\"'":
            j = i + 1
            while j < n and text[j] != c and text[j] != "\n":
                j += 2 if text[j] == "\\" else 1
            out.append(c + c)
            i = j + 1
            continue
        if c == "\n":
            at_line_start = True
        out.append(c)
        i += 1
    return select_branches("".join(out))


def select_branches(text):
    """Keep one branch of each #if chain (the first, or #else of `#if 0`),
    so #ifdef VERSION_* twins do not unbalance braces; drop directives."""
    keep, stack = [], []        # stack of [parent_live, taking, taken_any]
    live = True
    for ln in text.split("\n"):
        st = ln.lstrip()
        if st.startswith("#"):
            d = st[1:].strip()
            kw = re.match(r"[a-z]*", d).group(0)
            if kw in ("if", "ifdef", "ifndef"):
                zero = kw == "if" and re.match(r"if\s+0\b", d) is not None
                take = live and not zero
                stack.append([live, take, take])
                live = take
            elif kw in ("elif", "else") and stack:
                fr = stack[-1]
                take = fr[0] and not fr[2]
                fr[1], fr[2] = take, fr[2] or take
                live = take
            elif kw == "endif" and stack:
                live = stack.pop()[0]
            keep.append("")
            continue
        keep.append(ln if live else "")
    return "\n".join(keep)


IDENT_END = re.compile(r"([A-Za-z_][A-Za-z0-9_]*)\s*$")


def c_function_names(text):
    """Names of function definitions at file scope (brace-depth tokenizer).
    A top-level `{` whose preceding header ends in `)` and has no `=` is a
    function body; its name is the identifier before the matching `(`."""
    s = strip_c(text)
    names, depth, start, i, n = [], 0, 0, 0, len(s)
    while i < n:
        c = s[i]
        if depth == 0 and c == ";":
            start = i + 1
        elif c == "{":
            if depth == 0:
                header = s[start:i].strip()
                if header.endswith(")") and "=" not in header:
                    # find '(' matching the final ')'
                    d, j = 0, len(header) - 1
                    while j >= 0:
                        if header[j] == ")":
                            d += 1
                        elif header[j] == "(":
                            d -= 1
                            if d == 0:
                                break
                        j -= 1
                    m = IDENT_END.search(header[:max(j, 0)])
                    if m and m.group(1) not in ("if", "while", "for", "switch", "return", "sizeof"):
                        names.append(m.group(1))
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                start = i + 1
        i += 1
    return names


def src_dir_of(rel):
    """vendor/sm64/src-relative path -> reporting directory."""
    parts = rel.split("/")
    if parts[0] == "game" and len(parts) > 1 and parts[1] == "behaviors":
        return "game/behaviors"
    return parts[0]


def scan_c_sources():
    per_dir = {}          # dir -> set of (file, name)
    where = {}            # name -> list of (dir, rel path)
    for dp, _, fs in os.walk(SRC):
        for f in fs:
            if not f.endswith(".c"):
                continue
            p = os.path.join(dp, f)
            rel = os.path.relpath(p, SRC).replace(os.sep, "/")
            d = src_dir_of(rel)
            with open(p, encoding="utf-8", errors="replace") as fh:
                names = set(c_function_names(fh.read()))   # dedupe #ifdef twins
            per_dir.setdefault(d, set()).update((rel, nm) for nm in names)
            for nm in names:
                where.setdefault(nm, []).append((d, rel))
    return per_dir, where


def regex_line_count():
    """The simple per-line regex from the task, for comparison."""
    rx = re.compile(r"^[A-Za-z_][A-Za-z0-9_ \*]*\([^;]*\)\s*\{?\s*$")
    total = 0
    for dp, _, fs in os.walk(SRC):
        for f in fs:
            if f.endswith(".c"):
                with open(os.path.join(dp, f), encoding="utf-8", errors="replace") as fh:
                    total += sum(1 for ln in fh if rx.match(ln))
    return total


# ------------------------------------------------------------ linked TU set

def tu_rest_of(text):
    m = re.search(r"Definition\s+tu_rest\s*:\s*list\s+Clight\.program\s*:=\s*\[(.*?)\]\s*\.", text, re.S)
    if not m:
        return None
    body = re.sub(r"\(\*.*?\*\)", "", m.group(1), flags=re.S)
    return re.findall(r"([A-Za-z_][A-Za-z0-9_]*)\.prog", body)


def makefile_sources():
    """generated/<tu>.v -> source path (relative to vendor/sm64 or repo)."""
    res = {}
    with open(os.path.join(ROOT, "Makefile")) as fh:
        for ln in fh:
            m = re.match(r"^generated/([A-Za-z0-9_]+)\.v:\s*(\S+)", ln)
            if m:
                res[m.group(1)] = m.group(2).replace("$(SM64)/", "")
    return res


# ------------------------------------------------------- 2. Clight call graph

DEF_RX = re.compile(r"^Definition ([A-Za-z0-9_']+) :=", re.M)
EVAR_RX = re.compile(r"Evar (_[A-Za-z0-9_]+)")
EVAR_FN_RX = re.compile(r"Evar (_[A-Za-z0-9_]+)\s*\(Tfunction")
ADDROF_RX = re.compile(r"Init_addrof (_[A-Za-z0-9_]+)")
EXT_RX = re.compile(r"\((_[A-Za-z0-9_]+),\s*Gfun\s*\(External")


def parse_tu(path):
    with open(path, encoding="utf-8", errors="replace") as fh:
        text = fh.read()
    fns, vars_, fnnames = {}, {}, set(EVAR_FN_RX.findall(text)) | set(EXT_RX.findall(text))
    ms = list(DEF_RX.finditer(text))
    for k, m in enumerate(ms):
        name = m.group(1)
        end = ms[k + 1].start() if k + 1 < len(ms) else len(text)
        body = text[m.end():end]
        if name.startswith("f_"):
            fns["_" + name[2:]] = set(EVAR_RX.findall(body))
        elif name.startswith("v_"):
            refs = set(ADDROF_RX.findall(body))
            if refs:
                vars_["_" + name[2:]] = refs
    return fns, vars_, fnnames


def reachability(tus):
    fns, vars_, fnnames, per_tu = {}, {}, set(), {}
    for tu in tus:
        f, v, names = parse_tu(os.path.join(GEN, tu + ".v"))
        per_tu[tu] = sorted(f)
        for k, refs in f.items():
            fns.setdefault(k, set()).update(refs)
        for k, refs in v.items():
            vars_.setdefault(k, set()).update(refs)
        fnnames |= names
    fnnames |= set(fns)
    start = "_" + ENTRY
    seen, stack, callers = {start}, [start], {}
    while stack:
        u = stack.pop()
        succ = fns.get(u) or vars_.get(u) or ()
        for w in succ:
            if w not in fnnames and w not in vars_:
                continue        # plain data / string literal / unknown
            if w in fnnames and u in fns:
                callers.setdefault(w, set()).add(u)
            elif w in fnnames and u in vars_:
                callers.setdefault(w, set()).add(u)     # reached through a table
            if w not in seen:
                seen.add(w)
                stack.append(w)
    reach_fns = {x for x in seen if x in fnnames}
    internal = sorted(x for x in reach_fns if x in fns)
    external = sorted(x for x in reach_fns if x not in fns)
    return per_tu, internal, external, callers, fns, vars_


# ---------------------------------------------------------------- 3/4 series

def hyp_count(text, section=None):
    if text is None:
        return None
    flag = False
    if section:
        i = text.find(section)
        if i >= 0:
            text, flag = text[i:], True
    return sum(1 for ln in text.splitlines() if re.match(r"^\s*Hypothesis ", ln)), flag


def series_premises(path, section=None):
    hist = file_history(path)
    blobs = cat_batch([f"{h}:{p}" for h, _, _, p in hist])
    pts = []
    for h, short, d, p in hist:
        r = hyp_count(blobs.get(f"{h}:{p}"), section)
        if r is not None:
            pts.append((parse_date(d), r[0], short, r[1]))
    return pts


def series_tus():
    hist = file_history(LINKED)
    blobs = cat_batch([f"{h}:{p}" for h, _, _, p in hist])
    pts = []
    for h, short, d, p in hist:
        t = blobs.get(f"{h}:{p}")
        rest = tu_rest_of(t) if t else None
        if rest is not None:
            pts.append((parse_date(d), len(rest) + 1, short))
    return pts


# ----------------------------------------------------------------- 5 finish

def finish_snapshots():
    with open(os.path.join(ROOT, FINISH), encoding="utf-8") as fh:
        text = fh.read()
    m = re.search(r"const SNAPSHOTS\s*=\s*\[(.*?)\n\];", text, re.S)
    snaps = []
    if not m:
        return snaps
    for obj in re.finditer(r"\{(.*?)\}\s*,?\s*$", m.group(1), re.M):
        o = obj.group(1)

        def fld(k, num=True):
            mm = re.search(k + (r':\s*(-?[0-9.]+)' if num else r':\s*"((?:[^"\\]|\\.)*)"'), o)
            return (float(mm.group(1)) if num else mm.group(1)) if mm else None
        date, pct = fld("date", False), fld("pct")
        if date is None or pct is None:
            continue
        snaps.append({"date": dt.datetime.fromisoformat(date), "pct": pct,
                      "lo": fld("lo"), "hi": fld("hi"), "commit": fld("commit", False),
                      "note": fld("note", False) or ""})
    # same-day snapshots: spread them across the day so the line is readable
    byday = {}
    for s in snaps:
        byday.setdefault(s["date"], []).append(s)
    for d, group in byday.items():
        for k, s in enumerate(group):
            s["x"] = d + dt.timedelta(hours=24 * (k + 0.5) / len(group))
    return snaps


# ------------------------------------------------------------------- 6 size

def count_lines(text):
    return text.count("\n") + (1 if text and not text.endswith("\n") else 0)


def series_size():
    revs = git("rev-list", "--first-parent", "--reverse", "--format=%H\t%h\t%aI", "HEAD").splitlines()
    rows = [ln.split("\t") for ln in revs if not ln.startswith("commit ")]
    if not rows:
        return []
    n = len(rows)
    idx = sorted({round(k * (n - 1) / (SIZE_SAMPLES - 1)) for k in range(SIZE_SAMPLES)}) if n > 1 else [0]
    samples = [rows[i] for i in idx]
    trees, blobs = {}, set()
    for h, short, d in samples:
        entries = []
        for ln in git("ls-tree", "-r", h, "--", "proofs").splitlines():
            meta, path = ln.split("\t", 1)
            _, typ, sha = meta.split()
            if typ == "blob" and path.endswith(".v"):
                entries.append((path, sha))
                blobs.add(sha)
        trees[h] = entries
    texts = cat_batch(sorted(blobs))
    lines = {sha: count_lines(t or "") for sha, t in texts.items()}
    pts = []
    for h, short, d in samples:
        spine = sum(lines[s] for p, s in trees[h] if "/Unwired/" not in p)
        unw = sum(lines[s] for p, s in trees[h] if "/Unwired/" in p)
        pts.append((parse_date(d), spine, unw, short))
    return pts


def worktree_size():
    spine = unw = 0
    for dp, _, fs in os.walk(os.path.join(ROOT, "proofs")):
        for f in fs:
            if f.endswith(".v"):
                p = os.path.join(dp, f)
                with open(p, encoding="utf-8", errors="replace") as fh:
                    k = count_lines(fh.read())
                if "/Unwired/" in p.replace(os.sep, "/"):
                    unw += k
                else:
                    spine += k
    return spine, unw


# ------------------------------------------------------------------ SVG kit

W, H = 720, 300
ML, MR, MT, MB = 52, 92, 18, 34
esc = html.escape


def nice_ticks(lo, hi, want=5):
    if hi <= lo:
        hi = lo + 1
    raw = (hi - lo) / want
    mag = 10 ** int(f"{raw:e}".split("e")[1])
    step = next(m * mag for m in (1, 2, 2.5, 5, 10) if m * mag >= raw)
    t0 = (lo // step) * step
    ticks, t = [], t0
    while t <= hi + 1e-9:
        if t >= lo - 1e-9:
            ticks.append(t)
        t += step
    return ticks, step


def fmt_num(v):
    if abs(v) >= 10000:
        return f"{v/1000:.0f}k"
    if abs(v) >= 1000:
        return f"{v/1000:.1f}k".replace(".0k", "k")
    return f"{v:g}"


def line_chart(series, title, y_label="", y_min=None, band=None, step=False):
    """series: [{name, color(css var), pts:[(datetime, y, tip)], hollow_last}]
    band: [(datetime, lo, hi)] drawn behind the first series."""
    xs = [p[0] for s in series for p in s["pts"]] + ([b[0] for b in band] if band else [])
    ys = [p[1] for s in series for p in s["pts"]] + ([v for b in band for v in b[1:]] if band else [])
    if not xs:
        return "<p class='empty'>No data.</p>"
    x0, x1 = min(xs), max(xs)
    if x1 == x0:
        x1 = x0 + dt.timedelta(days=1)
    lo = 0 if y_min is None else y_min
    lo = min(lo, min(ys))
    hi = max(ys) * 1.08 if max(ys) > 0 else 1
    ticks, _ = nice_ticks(lo, hi)
    lo, hi = ticks[0], max(ticks[-1], hi)
    pw, ph = W - ML - MR, H - MT - MB

    def X(t):
        return ML + pw * (t - x0).total_seconds() / (x1 - x0).total_seconds()

    def Y(v):
        return MT + ph * (1 - (v - lo) / (hi - lo))
    o = [f'<svg viewBox="0 0 {W} {H}" role="img" aria-label="{esc(title)}" class="chart">']
    for t in ticks:
        o.append(f'<line x1="{ML}" x2="{W-MR}" y1="{Y(t):.1f}" y2="{Y(t):.1f}" class="grid"/>'
                 f'<text x="{ML-8}" y="{Y(t)+4:.1f}" class="tick" text-anchor="end">{fmt_num(t)}</text>')
    # month ticks
    span = (x1 - x0).days
    d = dt.datetime(x0.year, x0.month, 1)
    stepm = 1 if span < 200 else 2
    while d <= x1:
        if d >= x0:
            o.append(f'<line x1="{X(d):.1f}" x2="{X(d):.1f}" y1="{H-MB}" y2="{H-MB+4}" class="axis"/>'
                     f'<text x="{X(d):.1f}" y="{H-MB+18}" class="tick" text-anchor="middle">{d.strftime("%b")}</text>')
        m = d.month - 1 + stepm
        d = dt.datetime(d.year + m // 12, m % 12 + 1, 1)
    o.append(f'<line x1="{ML}" x2="{W-MR}" y1="{H-MB}" y2="{H-MB}" class="axis"/>')
    if y_label:
        o.append(f'<text x="{ML}" y="{MT-6}" class="tick">{esc(y_label)}</text>')
    if band:
        top = [(X(t), Y(h)) for t, _, h in band]
        bot = [(X(t), Y(l)) for t, l, _ in reversed(band)]
        pts = " ".join(f"{a:.1f},{b:.1f}" for a, b in top + bot)
        o.append(f'<polygon points="{pts}" class="band" style="fill:{series[0]["color"]}"/>')
    labels = []
    for s in series:
        P = s["pts"]
        if not P:
            continue
        path = []
        for k, (t, v, _) in enumerate(P):
            if k == 0:
                path.append(f"M{X(t):.1f},{Y(v):.1f}")
            elif step:
                path.append(f"H{X(t):.1f}V{Y(v):.1f}")
            else:
                path.append(f"L{X(t):.1f},{Y(v):.1f}")
        o.append(f'<path d="{"".join(path)}" class="line" style="stroke:{s["color"]}"/>')
        many = len(P) > 60
        for k, (t, v, tip) in enumerate(P):
            hollow = s.get("hollow_last") and k == len(P) - 1
            r = 2.5 if many and not hollow else 4
            cls = "pt hollow" if hollow else "pt"
            o.append(f'<g><circle cx="{X(t):.1f}" cy="{Y(v):.1f}" r="10" class="hit"/>'
                     f'<circle cx="{X(t):.1f}" cy="{Y(v):.1f}" r="{r}" class="{cls}" style="--c:{s["color"]}"/>'
                     f'<title>{esc(tip)}</title></g>')
        t, v, _ = P[-1]
        labels.append([Y(v), X(t), f'{s["name"]} {fmt_num(v)}'])
    # direct end labels, nudged apart
    labels.sort()
    for k in range(1, len(labels)):
        if labels[k][0] - labels[k - 1][0] < 14:
            labels[k][0] = labels[k - 1][0] + 14
    for yv, xv, txt in labels:
        o.append(f'<text x="{xv+8:.1f}" y="{yv+4:.1f}" class="endlab">{esc(txt)}</text>')
    o.append("</svg>")
    if len(series) > 1:
        o.append('<div class="legend">' + "".join(
            f'<span><i style="background:{s["color"]}"></i>{esc(s["name"])}</span>' for s in series) + "</div>")
    return "".join(o)


def bar_chart(rows):
    """rows: [(label, linked, total)] horizontal bars, track = total."""
    bh, gap, lw, rw = 22, 12, 120, 150
    w = 720
    h = len(rows) * (bh + gap) + 8
    mx = max(t for _, _, t in rows) or 1
    pw = w - lw - rw
    o = [f'<svg viewBox="0 0 {w} {h}" role="img" aria-label="linked vs total functions per directory" class="chart">']
    for k, (lab, ln, tot) in enumerate(rows):
        y = 4 + k * (bh + gap)
        tw = pw * tot / mx
        lwid = pw * min(ln, tot) / mx
        pct = 100 * ln / tot if tot else 0
        o.append(f'<g><text x="{lw-10}" y="{y+bh/2+4}" class="tick" text-anchor="end">{esc(lab)}</text>'
                 f'<rect x="{lw}" y="{y}" width="{tw:.1f}" height="{bh}" rx="4" class="track"/>'
                 + (f'<rect x="{lw}" y="{y}" width="{max(lwid, 0):.1f}" height="{bh}" rx="4" class="bar"/>' if ln else "")
                 + f'<text x="{lw+tw+8:.1f}" y="{y+bh/2+4}" class="endlab">{ln} / {tot} ({pct:.0f}%)</text>'
                 f'<title>{esc(lab)}: {ln} of {tot} C functions linked ({pct:.1f}%)</title></g>')
    o.append("</svg>")
    o.append('<div class="legend"><span><i class="lg-bar"></i>linked (body in the Clight link)</span>'
             '<span><i class="lg-track"></i>all C function definitions</span></div>')
    return "".join(o)


# --------------------------------------------------------------------- main

def main():
    t_start = time.time()
    now = dt.datetime.now(dt.timezone.utc).replace(microsecond=0)
    head = git("rev-parse", "--short", "HEAD").strip()
    head_subj = git("log", "-1", "--format=%s").strip()
    dirty = bool(git("status", "--porcelain", "--", "proofs", "generated", "Makefile").strip())

    # 1. coverage
    per_dir, where = scan_c_sources()
    with open(os.path.join(ROOT, LINKED)) as fh:
        rest = tu_rest_of(fh.read()) or []
    tus = ["mario"] + rest
    mk = makefile_sources()
    per_tu, internal, external, callers, fns, vars_ = reachability(tus)
    linked_dir = {}
    unmapped = 0
    for tu in tus:
        src = mk.get(tu, "")
        tu_dir = src_dir_of(src[len("src/"):]) if src.startswith("src/") else None
        for nm in per_tu[tu]:
            cands = where.get(nm[1:], [])
            ds = {d for d, _ in cands}
            if tu_dir in ds or (not ds and tu_dir):
                d = tu_dir
            elif ds:
                d = sorted(ds)[0]
            else:
                d, unmapped = "(other)", unmapped + 1
            linked_dir[d] = linked_dir.get(d, 0) + 1
    order = ["game", "game/behaviors", "engine", "audio", "menu", "goddard"]
    order += sorted(d for d in per_dir if d not in order)
    cov_rows = [(d, linked_dir.get(d, 0), len(per_dir.get(d, ()))) for d in order
                if per_dir.get(d) or linked_dir.get(d)]
    tot_c = sum(t for _, _, t in cov_rows)
    tot_l = sum(len(v) for v in per_tu.values())
    regex_total = regex_line_count()

    # 2. reachability externals table
    def defined_in(nm):
        c = where.get(nm[1:])
        return ", ".join(sorted({r for _, r in c})) if c else ("compiler builtin" if "builtin" in nm or "compcert" in nm else "not in src/ (libultra / asm / data)")
    ext_rows = []
    for nm in external:
        cs = sorted(callers.get(nm, ()))
        ext_rows.append((nm[1:], len(cs), ", ".join(c[1:] for c in cs[:4]) + (" …" if len(cs) > 4 else ""), defined_in(nm)))
    ext_rows.sort(key=lambda r: (-r[1], r[0]))

    # 3. premises
    p1 = series_premises(CAP1)
    p2 = series_premises(CAP2, "Section HeightLinked12")
    with open(os.path.join(ROOT, CAP1)) as fh:
        cur1 = hyp_count(fh.read())[0]
    with open(os.path.join(ROOT, CAP2)) as fh:
        cur2, cur2_sec = hyp_count(fh.read(), "Section HeightLinked12")

    # 4. TUs
    tu_pts = series_tus()
    # 5. finish line
    snaps = finish_snapshots()
    # 6. size
    size_pts = series_size()
    wt_spine, wt_unw = worktree_size()

    # ------------------------------------------------------------- charts
    def pts3(pts, unit):
        return [(d, v, f"{d:%Y-%m-%d} {c}: {v} {unit}") for d, v, c, *_ in pts]

    s1 = pts3(p1, "Hypothesis rows")
    s2 = [(d, v, f"{d:%Y-%m-%d} {c}: {v} Hypothesis rows" + ("" if sec else " (whole file; no HeightLinked12 section yet)"))
          for d, v, c, sec in p2]
    wt_label = f"{now:%Y-%m-%d} working tree"
    if dirty:
        s1.append((now.replace(tzinfo=None), cur1, f"{wt_label}: {cur1} Hypothesis rows (uncommitted)"))
        s2.append((now.replace(tzinfo=None), cur2, f"{wt_label}: {cur2} Hypothesis rows (uncommitted)"))
    chart_prem = line_chart([
        {"name": "GOAL 1", "color": "var(--s1)", "pts": s1, "hollow_last": dirty},
        {"name": "GOAL 2", "color": "var(--s2)", "pts": s2, "hollow_last": dirty}],
        "capstone premises over time", "Hypothesis rows", step=True)

    st = pts3(tu_pts, "TUs (mario + tu_rest)")
    if dirty:
        st.append((now.replace(tzinfo=None), len(tus), f"{wt_label}: {len(tus)} TUs (uncommitted)"))
    chart_tu = line_chart([{"name": "TUs", "color": "var(--s1)", "pts": st, "hollow_last": dirty}],
                          "linked translation units over time", "TUs in the link", step=True)

    fp = [(s["x"], s["pct"], f'{s["date"]:%Y-%m-%d} {s["commit"] or ""}: {s["pct"]:g}% (range {s["lo"]:g}–{s["hi"]:g}%). {s["note"][:160]}{"…" if len(s["note"]) > 160 else ""}') for s in snaps]
    band = [(s["x"], s["lo"], s["hi"]) for s in snaps if s["lo"] is not None and s["hi"] is not None]
    chart_fin = line_chart([{"name": "estimate", "color": "var(--s1)", "pts": fp}],
                           "finish-line estimate", "% of the way", band=band)

    sp = [(d, a, f"{d:%Y-%m-%d} {c}: {a:,} spine lines") for d, a, b, c in size_pts]
    su = [(d, b, f"{d:%Y-%m-%d} {c}: {b:,} Unwired lines") for d, a, b, c in size_pts]
    if dirty:
        sp.append((now.replace(tzinfo=None), wt_spine, f"{wt_label}: {wt_spine:,} spine lines (uncommitted)"))
        su.append((now.replace(tzinfo=None), wt_unw, f"{wt_label}: {wt_unw:,} Unwired lines (uncommitted)"))
    chart_size = line_chart([
        {"name": "spine", "color": "var(--s1)", "pts": sp, "hollow_last": dirty},
        {"name": "Unwired", "color": "var(--s2)", "pts": su, "hollow_last": dirty}],
        "proof lines over time", "lines of .v")

    chart_cov = bar_chart(cov_rows + [("overall", tot_l, tot_c)])

    fin_now = snaps[-1] if snaps else None
    tiles = [
        (f"{100*tot_l/tot_c:.1f}%", f"C functions linked ({tot_l:,} / {tot_c:,})"),
        (f"{len(internal)} / {len(external)}", "frame-reachable functions: internal / external"),
        (f"{cur1}", "Hypothesis rows, GOAL 1 capstone"),
        (f"{cur2}", "Hypothesis rows, GOAL 2 HeightLinked12"),
        (f"{fin_now['pct']:g}%" if fin_now else "–",
         f"finish-line estimate ({fin_now['lo']:g}–{fin_now['hi']:g}%)" if fin_now else "finish-line estimate"),
    ]

    cov_table = "".join(f"<tr><td>{esc(d)}</td><td class='n'>{l}</td><td class='n'>{t}</td><td class='n'>{(100*l/t if t else 0):.1f}%</td></tr>"
                        for d, l, t in cov_rows)
    cov_table += f"<tr class='tot'><td>overall</td><td class='n'>{tot_l}</td><td class='n'>{tot_c}</td><td class='n'>{100*tot_l/tot_c:.1f}%</td></tr>"
    tu_table = "".join(f"<tr><td>{esc(tu)}</td><td>{esc(mk.get(tu, '?'))}</td><td class='n'>{len(per_tu[tu])}</td></tr>" for tu in tus)
    ext_table = "".join(f"<tr><td><code>{esc(n)}</code></td><td class='n'>{k}</td><td>{esc(c)}</td><td>{esc(w)}</td></tr>"
                        for n, k, c, w in ext_rows)

    def tiles_html():
        return "".join(f'<div class="tile"><div class="big">{esc(v)}</div><div class="lab">{esc(l)}</div></div>' for v, l in tiles)

    page = f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Proof Metrics</title>
<meta name="description" content="Generated by tools/proof_metrics.py; do not edit by hand.">
<style>
:root {{
  color-scheme: light;
  --bg: #f7f7f5; --card: #fcfcfb; --ink: #0b0b0b; --ink2: #52514e; --muted: #8a8984;
  --line: #e4e3df; --grid: #ecebe7; --track: #e9e8e3;
  --s1: #2a78d6; --s2: #eb6834;
}}
@media (prefers-color-scheme: dark) {{
  :root:not([data-theme="light"]) {{
    color-scheme: dark;
    --bg: #121211; --card: #1a1a19; --ink: #f0efec; --ink2: #c3c2b7; --muted: #8f8e86;
    --line: #2e2e2c; --grid: #262624; --track: #2b2b29;
    --s1: #3987e5; --s2: #d95926;
  }}
}}
:root[data-theme="dark"] {{
  color-scheme: dark;
  --bg: #121211; --card: #1a1a19; --ink: #f0efec; --ink2: #c3c2b7; --muted: #8f8e86;
  --line: #2e2e2c; --grid: #262624; --track: #2b2b29;
  --s1: #3987e5; --s2: #d95926;
}}
* {{ box-sizing: border-box; }}
html, body {{ margin: 0; background: var(--bg); color: var(--ink); }}
body {{ font: 15px/1.5 system-ui, -apple-system, "Segoe UI", sans-serif; padding: 24px 16px 48px; overflow-x: hidden; }}
main {{ max-width: 960px; margin: 0 auto; }}
header h1 {{ font-size: 24px; margin: 0 0 4px; font-weight: 650; letter-spacing: -0.01em; }}
header p {{ margin: 0; color: var(--ink2); font-size: 13px; }}
code {{ font: 12.5px ui-monospace, SFMono-Regular, Menlo, monospace; }}
.tiles {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 12px; margin: 20px 0 8px; }}
.tile {{ background: var(--card); border: 1px solid var(--line); border-radius: 10px; padding: 14px 16px; }}
.tile .big {{ font-size: 26px; font-weight: 650; font-variant-numeric: tabular-nums; }}
.tile .lab {{ color: var(--ink2); font-size: 13px; }}
.card {{ background: var(--card); border: 1px solid var(--line); border-radius: 10px; padding: 18px 18px 14px; margin-top: 16px; min-width: 0; }}
.card h2 {{ font-size: 16px; margin: 0 0 2px; font-weight: 620; }}
.card .cap {{ color: var(--ink2); font-size: 13px; margin: 0 0 12px; }}
svg.chart {{ width: 100%; height: auto; display: block; overflow: visible; }}
svg .grid {{ stroke: var(--grid); stroke-width: 1; }}
svg .axis {{ stroke: var(--muted); stroke-width: 1; }}
svg .tick {{ fill: var(--muted); font-size: 12px; }}
svg .endlab {{ fill: var(--ink2); font-size: 12px; font-variant-numeric: tabular-nums; }}
svg .line {{ fill: none; stroke-width: 2; stroke-linejoin: round; }}
svg .band {{ opacity: 0.16; }}
svg .pt {{ fill: var(--c); stroke: var(--card); stroke-width: 2; }}
svg .pt.hollow {{ fill: var(--card); stroke: var(--c); }}
svg .hit {{ fill: transparent; }}
svg g:hover .pt {{ stroke: var(--ink); }}
svg .track {{ fill: var(--track); }}
svg .bar {{ fill: var(--s1); }}
svg g:hover .bar {{ opacity: .85; }}
.legend {{ display: flex; gap: 16px; flex-wrap: wrap; color: var(--ink2); font-size: 12.5px; margin-top: 8px; }}
.legend i {{ display: inline-block; width: 12px; height: 12px; border-radius: 3px; margin-right: 6px; vertical-align: -1px; }}
.legend i.lg-bar {{ background: var(--s1); }} .legend i.lg-track {{ background: var(--track); }}
.tw {{ overflow-x: auto; margin-top: 10px; }}
table {{ border-collapse: collapse; width: 100%; font-size: 13px; }}
th, td {{ text-align: left; padding: 5px 10px 5px 0; border-bottom: 1px solid var(--line); vertical-align: top; }}
th {{ color: var(--ink2); font-weight: 600; }}
td.n, th.n {{ text-align: right; font-variant-numeric: tabular-nums; }}
tr.tot td {{ font-weight: 650; }}
details summary {{ cursor: pointer; color: var(--ink2); font-size: 13px; margin-top: 8px; }}
footer {{ color: var(--muted); font-size: 12px; margin-top: 24px; }}
</style>
</head>
<body>
<main>
<header>
  <h1>Proof Metrics</h1>
  <p>Generated {now:%Y-%m-%d %H:%M} UTC · HEAD <code>{esc(head)}</code> {esc(head_subj)}{" · <strong>working tree has uncommitted proof changes</strong> (current numbers and hollow end points read the working tree)" if dirty else ""}</p>
</header>

<section class="tiles">{tiles_html()}</section>

<section class="card">
  <h2>Function coverage by source directory</h2>
  <p class="cap">C function definitions in <code>vendor/sm64/src</code> versus functions with a Clight body in the {len(tus)}-TU link (mario + <code>LinkedTwelve.tu_rest</code>). Linked is not proved-about: a linked body is only available to the proof, and C totals come from a brace-depth scan of raw source, so <code>#if</code> variants and disabled code are approximate.</p>
  {chart_cov}
  <details><summary>Table and per-TU counts</summary>
  <div class="tw"><table><tr><th>directory</th><th class="n">linked</th><th class="n">total</th><th class="n">%</th></tr>{cov_table}</table></div>
  <div class="tw"><table><tr><th>TU</th><th>source</th><th class="n">functions</th></tr>{tu_table}</table></div>
  </details>
</section>

<section class="card">
  <h2>Frame-reachable functions</h2>
  <p class="cap">Functions reachable from <code>{ENTRY}</code> in the linked Clight call graph: {len(internal)} have a body in the link and {len(external)} are called but have no body, which is where a capstone needs premises. It over-approximates: every function-typed <code>Evar</code> counts as a call and every function address in a reachable data table (such as <code>sInteractionHandlers</code>) counts as reachable, whatever the game state.</p>
  <div class="tw"><table><tr><th>external function</th><th class="n">callers</th><th>reachable callers (first 4)</th><th>defined in</th></tr>{ext_table}</table></div>
</section>

<section class="card">
  <h2>Capstone premises over time</h2>
  <p class="cap"><code>Hypothesis</code> lines in <code>{CAP1}</code> (GOAL 1) and in <code>{CAP2}</code> from <code>Section HeightLinked12</code> on (GOAL 2), per commit touching each file. A line count, not a weight: one row can be broad or narrow, and rows split or merge as statements sharpen.</p>
  {chart_prem}
</section>

<section class="card">
  <h2>Linked translation units over time</h2>
  <p class="cap">TUs in the link (mario plus the length of <code>tu_rest</code>), per commit touching <code>{LINKED}</code>. More TUs means more real code under the capstone, but a TU can be linked while most of its functions are never reasoned about.</p>
  {chart_tu}
</section>

<section class="card">
  <h2>Finish-line estimate</h2>
  <p class="cap">The hand-set estimate and its low–high band from the <code>SNAPSHOTS</code> list in <code>{FINISH}</code>. A judgement, not a measurement; same-day snapshots are spread across the day so each is visible.</p>
  {chart_fin}
</section>

<section class="card">
  <h2>Proof size over time</h2>
  <p class="cap">Lines of <code>proofs/**/*.v</code> at {len(size_pts)} commits spaced evenly along first-parent history, split into the spine and files under an <code>Unwired/</code> directory. Size is effort, not progress: rewrites and deletions can be the better change.</p>
  {chart_size}
</section>

<footer>Generated by <code>tools/proof_metrics.py</code> in {time.time()-t_start:.1f} s. Do not edit this page; rerun the script.</footer>
</main>
</body>
</html>
"""
    with open(OUT, "w", encoding="utf-8") as fh:
        fh.write(page)

    # ------------------------------------------------------------ stdout
    print(f"Proof metrics @ {head}{' (dirty)' if dirty else ''} -> {os.path.relpath(OUT, ROOT)} ({len(page)/1024:.0f} KB, {time.time()-t_start:.1f} s)")
    print(f"  C functions: {tot_c} (brace scan; simple line regex finds {regex_total}); linked {tot_l} ({100*tot_l/tot_c:.1f}%) over {len(tus)} TUs")
    for d, l, t in cov_rows:
        print(f"    {d:<16} {l:>5} / {t:<5}")
    if unmapped:
        print(f"    ({unmapped} linked functions not found in src/)")
    print(f"  mario.c: {len(per_tu['mario'])} linked fns")
    print(f"  reachable from {ENTRY}: {len(internal)} internal, {len(external)} external")
    print(f"  Hypothesis rows: GOAL 1 {cur1}, GOAL 2 {cur2}{'' if cur2_sec else ' (whole file)'}")
    print(f"  premise history: {len(p1)} / {len(p2)} commits; TU history: {len(tu_pts)} commits")
    if fin_now:
        print(f"  finish line: {fin_now['pct']:g}% ({fin_now['lo']:g}-{fin_now['hi']:g}) over {len(snaps)} snapshots")
    if size_pts:
        print(f"  proof lines: spine {wt_spine:,}, Unwired {wt_unw:,} (working tree); {len(size_pts)} history samples")


if __name__ == "__main__":
    sys.exit(main())
