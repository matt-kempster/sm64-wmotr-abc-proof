#!/usr/bin/env python3
"""Decode CompCert `$"name"` positives printed by vm_compute back to names.
Usage: decode_ident.py < coq_output   (replaces every N%positive by its name)"""
import re
import sys

A = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"


def dec(p):
    s = ""
    while p > 1:
        c = p & 63
        p >>= 6
        if c == 63:
            v = 0
            for i in range(8):
                v |= (p & 1) << i
                p >>= 1
            s += chr(v)
        else:
            s += A[c]
    return s


txt = sys.stdin.read()
print(re.sub(r"(\d+)%positive", lambda m: dec(int(m.group(1))), txt))
