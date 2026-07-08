#!/usr/bin/env python3
"""Canonicalize clightgen's anonymous composite names by structural hash.

clightgen names anonymous C structs/unions per translation unit with a
running counter (idents "_317", "_381", ...).  The SAME anonymous type
(e.g. ultra64's OSContStatus) therefore gets DIFFERENT names in different
TUs, which makes structurally identical composites (Controller, Object,
Surface, ...) syntactically unequal -- and CompCert's equality-based
composite linker (check_compat_composite) then refuses to link the TUs.
Found by the linked12 pairwise certificate, 2026-07-08.

Fix: rename each anonymous composite's ident STRING to a canonical name
derived from a structural hash of its definition (with nested anonymous
references resolved recursively).  Identical structures get identical
names in every TU; distinct structures get distinct names (so previously
name-colliding-but-different anonymous types stop being shared at all).
Only the `Definition __NNN : ident := $"_NNN".` line changes -- composite
bodies and function bodies reference the Coq binder, which is untouched,
so the rename is consistent file-wide by construction.

Determinism: the canonical name depends only on the composite's structure,
never on file order or other files -- per-file regeneration stays
byte-reproducible and cross-TU consistent.

Usage: canonicalize_anon.py <generated.v>   (in-place)
"""
import hashlib
import re
import sys

ANON_STR = re.compile(r'^_[0-9]+$')

def main(path):
    with open(path) as f:
        text = f.read()

    # 1. ident definitions:  Definition __317 : ident := $"_317".
    ident_defs = {}   # coq binder -> ident string
    for m in re.finditer(r'Definition\s+(_\S+)\s*:\s*ident\s*:=\s*\$"([^"]+)"\.',
                         text):
        ident_defs[m.group(1)] = m.group(2)

    anon_binders = {b for b, s in ident_defs.items() if ANON_STR.match(s)}
    if not anon_binders:
        return

    # 2. composite bodies:  Composite <binder> <Struct|Union> ... ::
    #    capture from the keyword to the terminating "::" at an attr position.
    comp_bodies = {}  # binder -> body text (su + members + attr)
    comp_iter = list(re.finditer(r'Composite\s+(_\S+)\s+(Struct|Union)\b',
                                 text))
    for i, m in enumerate(comp_iter):
        start = m.end()
        end = comp_iter[i + 1].start() if i + 1 < len(comp_iter) \
            else text.find('nil)', start)
        body = m.group(2) + ' ' + text[start:end]
        comp_bodies[m.group(1)] = re.sub(r'\s+', ' ', body).strip()

    # 3. recursive structural hash (anonymous refs replaced by their hash)
    memo, in_progress = {}, set()

    def canon(binder):
        if binder in memo:
            return memo[binder]
        if binder in in_progress:
            sys.exit(f"canonicalize_anon: cycle through {binder} in {path}")
        in_progress.add(binder)
        body = comp_bodies.get(binder)
        if body is None:
            sys.exit(f"canonicalize_anon: no Composite body for {binder} in {path}")
        def sub(mm):
            b = mm.group(0)
            return canon(b) if b in anon_binders else b
        resolved = re.sub(r'_\S+', sub, body)
        h = '_anon_' + hashlib.sha256(resolved.encode()).hexdigest()[:12]
        in_progress.discard(binder)
        memo[binder] = h
        return h

    # order anonymous binders by first occurrence in the composites region
    # (header-inclusion order -- consistent across TUs sharing the headers);
    # same-structure duplicates within one TU get an occurrence index suffix
    # so composite names stay unique per program.  The linked12 pairwise
    # certificate verifies the cross-TU alignment of these suffixes.
    order = [m.group(1) for m in re.finditer(r'Composite\s+(_\S+)\s+(?:Struct|Union)\b', text)
             if m.group(1) in anon_binders]
    groups = {}
    for b in order:
        groups.setdefault(canon(b), []).append(b)
    renames = {}  # old ident string -> new ident string
    for h, bs in groups.items():
        if len(bs) == 1:
            renames[ident_defs[bs[0]]] = h
        else:
            for k, b in enumerate(bs):
                renames[ident_defs[b]] = f"{h}_{k}"

    vals = list(renames.values())
    if len(set(vals)) != len(vals):
        sys.exit(f"canonicalize_anon: name collision after indexing in {path}")

    # 4. rewrite ONLY the ident-definition strings
    def rw(m):
        binder, s = m.group(1), m.group(2)
        if s in renames and ident_defs.get(binder) == s:
            return m.group(0).replace(f'$"{s}"', f'$"{renames[s]}"')
        return m.group(0)
    text = re.sub(r'Definition\s+(_\S+)\s*:\s*ident\s*:=\s*\$"([^"]+)"\.',
                  rw, text)

    with open(path, 'w') as f:
        f.write(text)
    print(f"canonicalize_anon: {path}: renamed {len(renames)} anonymous composites")

if __name__ == '__main__':
    main(sys.argv[1])
