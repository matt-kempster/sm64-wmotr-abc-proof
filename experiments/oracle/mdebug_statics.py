"""Addresses of `static` symbols in the matching ROM.

IDO drops statics from the ELF symbol tables, but every .o keeps them in its
ECOFF `.mdebug` section (local SYMRs: name, storage class, offset within the
section).  The linker map gives each object's section bases, so

    address = base(object, section) + symr.value

    python3 mdebug_statics.py [obj.o ...]  ->  prints "name address section obj"

Function-local statics are reported as `func.name`.
"""
import os
import re
import struct
import sys

DECOMP = os.path.expanduser("~/sm64-oracle/decomp")
MAP = f"{DECOMP}/build/us/sm64.us.map"

ST_STATIC, ST_PROC, ST_STATICPROC, ST_BLOCK, ST_END, ST_FILE = 2, 6, 14, 7, 8, 11
SC = {1: ".text", 2: ".data", 3: ".bss", 13: ".sdata", 14: ".sbss", 15: ".rodata"}


def section_bases(mapfile=MAP):
    """{(object path suffix, section): address} from the GNU ld map."""
    bases = {}
    pat = re.compile(r"^ (\.\w+)\s+0x([0-9a-f]+)\s+0x([0-9a-f]+)\s+(\S+\.o)$")
    for line in open(mapfile):
        m = pat.match(line.rstrip("\n"))
        if m:
            sec, addr, size, obj = m.groups()
            a = int(addr, 16) & 0xFFFFFFFF
            if a and int(size, 16):
                bases[(obj, sec)] = a
    return bases


def elf_section(data, name):
    e_shoff, = struct.unpack_from(">I", data, 0x20)
    e_shentsize, e_shnum, e_shstrndx = struct.unpack_from(">HHH", data, 0x2E)
    shs = [struct.unpack_from(">IIIIIIIIII", data, e_shoff + i * e_shentsize) for i in range(e_shnum)]
    stroff = shs[e_shstrndx][4]
    for sh in shs:
        n = data[stroff + sh[0]:data.index(b"\0", stroff + sh[0])].decode()
        if n == name:
            return sh[4], sh[5]
    raise KeyError(name)


def local_symbols(path):
    """[(name, st, sc, value)] for the local symbols of a single-file IDO .o."""
    data = open(path, "rb").read()
    off, _ = elf_section(data, ".mdebug")
    h = struct.unpack_from(">hh" + "I" * 23, data, off)
    assert h[0] == 0x7009, "not an ECOFF symbolic header"
    (isymMax, cbSymOffset) = h[9], h[10]
    cbSsOffset, ifdMax, cbFdOffset = h[16], h[19], h[20]
    out = []
    for f in range(ifdMax):
        # FDR: adr, rss, issBase, cbSs, isymBase, csym, ...
        adr, rss, issBase, cbSs, isymBase, csym = struct.unpack_from(">IiiiiI", data, cbFdOffset + f * 72)
        for k in range(isymBase, isymBase + csym):
            iss, value, bits = struct.unpack_from(">iII", data, cbSymOffset + 12 * k)
            st, sc = bits >> 26, (bits >> 21) & 0x1F
            s = cbSsOffset + issBase + iss
            name = data[s:data.index(b"\0", s)].decode(errors="replace")
            out.append((name, st, sc, value))
    return out


def statics(obj_rel, bases):
    """{name: (address, section)} for static data in one object."""
    path = f"{DECOMP}/{obj_rel}"
    res, proc = {}, None
    depth = 0
    for name, st, sc, value in local_symbols(path):
        if st in (ST_PROC, ST_STATICPROC):
            proc, depth = name, 0
        elif st == ST_BLOCK:
            depth += 1
        elif st == ST_END:
            if depth == 0:
                proc = None if name == proc else proc
            else:
                depth -= 1
        elif st == ST_STATIC and sc in SC and sc != 1:
            sec = SC[sc]
            base = bases.get((obj_rel, sec))
            if base is None:
                continue
            key = f"{proc}.{name}" if proc else name
            res[key] = (base + value, sec)
    return res


def all_statics(objs):
    bases = section_bases()
    out = {}
    for o in objs:
        for k, v in statics(o, bases).items():
            out.setdefault(k, (v[0], v[1], o))
    return out


if __name__ == "__main__":
    objs = sys.argv[1:] or ["build/us/src/game/mario_actions_submerged.o"]
    for k, (a, sec, o) in sorted(all_statics(objs).items(), key=lambda kv: kv[1][0]):
        print(f"{k} {a:08x} {sec} {o}")
