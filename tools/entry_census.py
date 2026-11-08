#!/usr/bin/env python3
"""WMotR entry census (GOAL 2 coverage track, 2026-11-07).

Question: which real ways into WMotR (level 31) exist, and which parts of the
state on WMotR's first frame are NOT fixed by the entry code (so that the GOAL 2
start premise has to hold for every value they can carry)?

Two sources, nothing hand-written about SM64 code:

  1. THE WARPS (decomp level scripts and C call sites; the other levels'
     scripts are not clightgen'd, so this part reads vendor/sm64 text):
     every WARP_NODE / PAINTING_WARP_NODE / INSTANT_WARP whose destination is
     LEVEL_WMOTR, every C literal `LEVEL_WMOTR` outside the level table, the
     credits table and the demo list.  For each warp node into WMotR, the
     destination node and the WMotR object that carries it (its behavior
     decides the spawn type).

  2. THE ENTRY CODE (generated/*.v, the clightgen'd AST): the syntactic call
     closure of the entry roots (lvl_set_current_level, init_level and the
     level-command handlers WMotR's script uses).  It lists
       - every MarioState field the closure may write (through gMarioState or
         a `struct MarioState *` parameter, as an lvalue or by address);
         the fields it never writes are CARRIED from the previous level;
       - every global the closure reads by name and never writes (carried
         globals the entry reads);
       - every save_file_* call (the save-file branches).
     A may-write over-approximation: a field written only on another arm of
     a switch is still listed as written, so the carried list is a SUBSET of
     the truly carried fields (sound for "this field is carried").

Usage: python3 tools/entry_census.py [--vendor PATH]
       (default vendor: ../../vendor/sm64 relative to a worktree, or ./vendor/sm64)
"""
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
GEN = os.path.join(ROOT, 'generated')


def find_vendor():
    if '--vendor' in sys.argv:
        return sys.argv[sys.argv.index('--vendor') + 1]
    for cand in [os.path.join(ROOT, 'vendor/sm64'),
                 os.path.join(ROOT, '../../../vendor/sm64')]:
        if os.path.isdir(os.path.join(cand, 'levels')):
            return os.path.abspath(cand)
    return None


# ---------------------------------------------------------------- part 1
WARP_RE = re.compile(r'\b(WARP_NODE|PAINTING_WARP_NODE|INSTANT_WARP)\s*\((.*?)\)\s*,', re.S)


def strip_comments(s):
    return re.sub(r'/\*.*?\*/', '', re.sub(r'//[^\n]*', '', s), flags=re.S)


def part1(vendor):
    out = []
    lv = os.path.join(vendor, 'levels')
    for dp, _, fs in sorted(os.walk(lv)):
        for f in sorted(fs):
            if not (f.endswith('.c') or f.endswith('.inc.c')):
                continue
            p = os.path.join(dp, f)
            s = strip_comments(open(p, errors='replace').read())
            for m in WARP_RE.finditer(s):
                args = [a.strip() for a in m.group(2).split(',')]
                if 'LEVEL_WMOTR' in args:
                    out.append((os.path.relpath(p, vendor), m.group(1), args))
    src_hits = []
    for dp, _, fs in sorted(os.walk(os.path.join(vendor, 'src'))):
        for f in sorted(fs):
            if f.endswith('.c'):
                p = os.path.join(dp, f)
                for i, line in enumerate(open(p, errors='replace'), 1):
                    if 'LEVEL_WMOTR' in line:
                        src_hits.append('%s:%d: %s' % (os.path.relpath(p, vendor), i, line.strip()))
    return out, src_hits


# ---------------------------------------------------------------- part 2
FUN_RE = re.compile(r'^Definition f_(\w+) := \{\|(.*?)^\|\}\.', re.S | re.M)
VAR_RE = re.compile(r'^Definition v_(\w+) := \{\|', re.M)
TOK_RE = re.compile(r'\(|\)|[^\s()]+')


def parse(text):
    """Coq application syntax -> nested lists (atoms are strings)."""
    stack, cur = [], []
    for t in TOK_RE.findall(text):
        if t == '(':
            stack.append(cur)
            cur = []
        elif t == ')':
            done, cur = cur, stack.pop()
            cur.append(done)
        else:
            cur.append(t)
    return cur


def walk(t):
    yield t
    if isinstance(t, list):
        for x in t:
            yield from walk(x)


def head(t):
    return t[0] if isinstance(t, list) and t and isinstance(t[0], str) else None


ENTRY_ROOTS = ['lvl_set_current_level', 'init_level',
               # the handlers of WMotR's script commands (StartTerrain.cmd_types)
               'level_cmd_init_level', 'level_cmd_alloc_level_pool', 'level_cmd_init_mario',
               'level_cmd_begin_area', 'level_cmd_end_area', 'level_cmd_place_object',
               'level_cmd_create_warp_node', 'level_cmd_load_collision',
               'level_cmd_load_macro_objects', 'level_cmd_set_music',
               'level_cmd_set_terrain_type', 'level_cmd_free_level_pool',
               'level_cmd_set_mario_start_pos']


def load_funs():
    funs = {}
    for f in sorted(os.listdir(GEN)):
        if not f.endswith('.v'):
            continue
        s = open(os.path.join(GEN, f)).read()
        for m in FUN_RE.finditer(s):
            body = m.group(2)
            if m.group(1) not in funs:
                funs[m.group(1)] = (f[:-2], body)
    return funs


def fn_part(body, key):
    m = re.search(key + r'\s*:=\s*(.*?)(?:;\s*fn_\w+\s*:=|\Z)', body, re.S)
    return m.group(1) if m else ''


def closure(funs, roots):
    seen, todo = set(), [r for r in roots if r in funs]
    while todo:
        f = todo.pop()
        if f in seen:
            continue
        seen.add(f)
        for g in re.findall(r'Evar _(\w+)', funs[f][1]):
            if g in funs and g not in seen:
                todo.append(g)
    return seen


def mario_fields_written(name, body):
    """MarioState fields this body may write (lvalue, address taken, or an
    array field passed to a call)."""
    params = fn_part(body, 'fn_params')
    mparams = set(re.findall(r'\(_(\w+), \(tptr \(Tstruct _MarioState noattr\)\)\)', params))
    tree = parse(fn_part(body, 'fn_body'))
    gm = set(mparams)              # temps / params holding gMarioState
    for t in walk(tree):           # Sset _t (Evar _gMarioState ..)
        if head(t) == 'Sset' and len(t) >= 3 and isinstance(t[2], list) \
                and head(t[2]) == 'Evar' and t[2][1] == '_gMarioState':
            gm.add(t[1][1:])

    def is_gm_base(e):
        # Ederef (Etempvar _x ..) | Ederef (Evar _gMarioState ..)
        if head(e) != 'Ederef' or not isinstance(e[1], list):
            return False
        b = e[1]
        return (head(b) == 'Etempvar' and b[1][1:] in gm) or \
               (head(b) == 'Evar' and b[1] == '_gMarioState')

    def fields_in(e):
        out = set()
        for x in walk(e):
            if head(x) == 'Efield' and len(x) >= 3 and isinstance(x[1], list) and is_gm_base(x[1]):
                out.add(x[2][1:])
        return out

    written = set()
    for t in walk(tree):
        h = head(t)
        if h == 'Sassign':
            written |= fields_in(t[1])          # the lvalue only
        elif h == 'Eaddrof':
            written |= fields_in(t[1])
        elif h == 'Scall':
            # array fields decay when passed: Efield .. (tarray ..)
            for x in walk(t[3:] if len(t) > 3 else []):
                if head(x) == 'Efield' and len(x) >= 4 and isinstance(x[1], list) \
                        and is_gm_base(x[1]) and isinstance(x[3], list) and head(x[3]) == 'tarray':
                    written.add(x[2][1:])
    return written


def globals_rw(body):
    tree = parse(fn_part(body, 'fn_body'))
    reads, writes = set(), set()

    def base_var(e):
        # the global an lvalue path ends at: Evar, Efield/Ederef/Ebinop over it
        while isinstance(e, list):
            h = head(e)
            if h == 'Evar':
                return e[1][1:]
            if h in ('Efield', 'Ederef', 'Ecast'):
                e = e[1]
            elif h == 'Ebinop':
                e = e[2]
            else:
                return None
        return None
    for t in walk(tree):
        h = head(t)
        if h == 'Sassign':
            g = base_var(t[1])
            if g:
                writes.add(g)
        if h == 'Evar':
            reads.add(t[1][1:])
    return reads, writes


def mario_members():
    s = open(os.path.join(GEN, 'mario.v')).read()
    m = re.search(r'Composite _MarioState Struct\s*\((.*?)\)\s*noattr', s, re.S)
    return re.findall(r'Member_plain _(\w+)', m.group(1))


def main():
    vendor = find_vendor()
    print('# WMotR entry census (tools/entry_census.py)\n')
    if vendor:
        warps, src_hits = part1(vendor)
        print('## 1. warps whose destination is LEVEL_WMOTR (vendor level scripts)')
        for p, kind, args in warps:
            print('  %s: %s(%s)' % (p, kind, ', '.join(args)))
        print('\n## 1b. LEVEL_WMOTR in vendor src/')
        for h in src_hits:
            print('  ' + h)
    else:
        print('## 1. (vendor tree not found: pass --vendor)')
    funs = load_funs()
    cl = closure(funs, ENTRY_ROOTS)
    print('\n## 2. entry closure: %d functions from %d roots' % (len(cl), len(ENTRY_ROOTS)))
    w = {}
    for f in sorted(cl):
        for fld in mario_fields_written(f, funs[f][1]):
            w.setdefault(fld, set()).add(f)
    mem = mario_members()
    print('\n## 2a. MarioState fields the closure may write')
    for fld in mem:
        if fld in w:
            print('  %-26s %s' % (fld, ', '.join(sorted(w[fld]))))
    print('\n## 2b. MarioState fields the closure NEVER writes (carried into WMotR)')
    print('  ' + ', '.join(f for f in mem if f not in w))
    R, W = set(), set()
    for f in cl:
        r, wr = globals_rw(funs[f][1])
        R |= r
        W |= wr
    gv = set()
    for f in os.listdir(GEN):
        if f.endswith('.v'):
            gv |= set(VAR_RE.findall(open(os.path.join(GEN, f)).read()))
    gl = sorted(g for g in R - W if g in gv and not g.startswith('bhv')
                and not g.startswith('__stringlit'))
    print('\n## 2c. globals the closure reads by name and never assigns (%d)' % len(gl))
    print('  ' + ', '.join(gl))
    sv = sorted({g for f in cl for g in re.findall(r'Evar _(save_file_\w+)', funs[f][1])})
    print('\n## 2d. save_file_* functions the closure calls')
    for g in sv:
        users = sorted(f for f in cl if re.search(r'Evar _%s\b' % g, funs[f][1]))
        print('  %-36s from %s' % (g, ', '.join(users)))


if __name__ == '__main__':
    main()
