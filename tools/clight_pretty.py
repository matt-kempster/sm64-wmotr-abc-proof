#!/usr/bin/env python3
"""Make Coq-printed Clight terms readable.

    coqc ... | python3 tools/clight_pretty.py

- decodes clightgen idents (`12345%positive`, CompCert's ident_of_string
  encoding: 6 bits per char, low bits first) back to their C names;
- collapses the noise records ({| attr_volatile := false; ... |},
  {| Int.intval := 1; Int.intrange := ... |}) to short forms.
"""
import re
import sys

ALPHA = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"


def decode(n: int):
    out = []
    while n > 1:
        c = n & 63
        n >>= 6
        if c == 63:  # escaped 8-bit char, MSB first
            if n < 256:
                return None
            bits = n & 255
            n >>= 8
            out.append(chr(int(f"{bits:08b}"[::-1], 2)))
        else:
            out.append(ALPHA[c])
    return "".join(out) if n == 1 and out else None


def pos(m):
    s = decode(int(m.group(1)))
    return s if s else m.group(0)


def main():
    t = sys.stdin.read()
    t = re.sub(r"\{\|\s*attr_volatile := false;\s*attr_alignas := None\s*\|\}", "noattr", t)
    t = re.sub(r"\{\|\s*Int\.intval := (-?\d+);\s*Int\.intrange := [^|]*\|\}", r"\1", t)
    t = re.sub(r"(\d+)%positive", pos, t)
    t = re.sub(r"[ \t]*\n[ \t]*", " ", t) if "--oneline" in sys.argv else t
    sys.stdout.write(t)


if __name__ == "__main__":
    main()
