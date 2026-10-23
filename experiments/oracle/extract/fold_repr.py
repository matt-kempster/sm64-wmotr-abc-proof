#!/usr/bin/env python3
"""Fold `Int.repr <Z literal>` in an extracted module into the Z literal it
computes, so ocamlopt sees a structured constant.

Why: since 2026-10-22 the link holds Mario's anim data (mario_anim_data.v, the
36th TU).  Its extraction is one ~290k-element list of `Init_int16 (Int.repr
(Zpos ...))`; every element is a function call, so ocamlopt compiles it as code
(ran > 1 h and 5 GB without finishing).  Int.repr z is z mod 2^32 (Int.wordsize
32, unsigned representation; Integers.Int.repr), so the folded literal is the
same value.  Harness only (TRUST 5.1): nothing in proofs/ depends on extraction.

    python3 fold_repr.py ml/mario_anim_data.ml      (in place; idempotent)
"""
import re
import sys

MOD = 1 << 32


def parse_pos(s, i):
    """parse a positive at s[i:], return (value, end)"""
    if s.startswith('Coq_xH', i):
        return 1, i + 6
    if s[i] == '(':
        v, j = parse_pos(s, skip(s, i + 1))
        j = skip(s, j)
        assert s[j] == ')', s[i:i + 80]
        return v, j + 1
    for c, b in (('Coq_xI', 1), ('Coq_xO', 0)):
        if s.startswith(c, i):
            v, j = parse_pos(s, skip(s, i + 6))
            return 2 * v + b, j
    raise ValueError(s[i:i + 80])


def skip(s, i):
    while s[i] in ' \n\t':
        i += 1
    return i


def parse_z(s, i):
    if s.startswith('Z0', i):
        return 0, i + 2
    if s[i] == '(':
        v, j = parse_z(s, skip(s, i + 1))
        j = skip(s, j)
        assert s[j] == ')'
        return v, j + 1
    for c, sg in (('Zpos', 1), ('Zneg', -1)):
        if s.startswith(c, i):
            v, j = parse_pos(s, skip(s, i + 4))
            return sg * v, j
    raise ValueError(s[i:i + 80])


def pos_lit(n):
    bits = bin(n)[3:]  # below the leading 1
    out = 'Coq_xH'
    for b in bits:
        out = f"(Coq_x{'I' if b == '1' else 'O'} {out})"
    return out


def z_lit(z):
    return 'Z0' if z == 0 else f'(Zpos {pos_lit(z)})'


def main(path):
    s = open(path).read()
    out, i, n = [], 0, 0
    for m in re.finditer(r'\(Int\.repr\s', s):
        if m.start() < i:
            continue
        z, j = parse_z(s, skip(s, m.end()))
        j = skip(s, j)
        assert s[j] == ')'
        out.append(s[i:m.start()])
        out.append(z_lit(z % MOD))
        i, n = j + 1, n + 1
    out.append(s[i:])
    open(path, 'w').write(''.join(out))
    print(f'fold_repr: {n} Int.repr literals folded in {path}')


if __name__ == '__main__':
    main(sys.argv[1])
