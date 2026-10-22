#!/usr/bin/env python3
"""Size-0 globals of the linked program (the vacuity sweep, 2026-10-22).

A C global that every linked TU only DECLARES (`extern T x;`) has
`gvar_init := nil` in each generated .v.  CompCert's linker keeps nil
(link_varinit nil nil = nil), and Genv.init_mem allocates
init_data_list_size nil = 0 bytes for it: a size-0 block.  Every load from or
store to it has NO CompCert execution, so any capstone row about code that
touches it holds vacuously on that code (found: gPlayerCameraState, stored
through on every execute_mario_action frame).

This tool reads the link's TU list from proofs/MarioModel/LinkedTwelve.v
(mario + tu_rest), parses every generated/<tu>.v, and lists each global whose
merged definition has no initializer bytes, with the linked functions that
mention it (load, store or address-of; syntactic `Evar _x`).  Each is
classified:

  (a) REACHED  -- mentioned by a function reachable (syntactic callgraph) from
                  the frame / boot roots below: it must get storage (a 2.4
                  completion in pipeline/clightgen.sh) or it is a finding;
  (b) note     -- not mentioned by any reached function.

Exit status 1 iff some (a) global is still size 0 (the audit runs this).
Usage: python3 tools/size0_globals.py [--all]   (--all: also list (b) users)
"""
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
GEN = os.path.join(ROOT, 'generated')

# the frame and the boot / level-entry path the capstones and witnesses run
ROOTS = ['execute_mario_action', 'init_mario_from_save_file', 'init_mario',
         'set_mario_initial_action', 'initiate_warp', 'warp_level',
         'get_mario_spawn_type', 'alloc_surface_pools', 'load_area_terrain',
         'clear_dynamic_surfaces', 'load_object_collision_model']


# (a)-candidates checked by hand to be ADDRESS-ONLY in every reached user (no
# load / store through them in linked code), with the reason.  Taking the
# address of a size-0 block executes; only the OS floor below would deref it.
ADDRESS_ONLY = {
    '__osThreadTail_fix':
        'osCreateMesgQueue only stores &__osThreadTail_fix.next into the queue '
        '(lib/src/osCreateMesgQueue.c:4-5); the readers (osRecvMesg / '
        'osSendMesg) are the OS floor (TRUST 3.5)',
}


def linked_tus():
    src = open(os.path.join(ROOT, 'proofs/MarioModel/LinkedTwelve.v')).read()
    m = re.search(r'Definition tu_rest : list Clight\.program :=\s*\[(.*?)\]\.', src, re.S)
    return ['mario'] + re.findall(r'(\w+)\.prog', m.group(1))


VAR_RE = re.compile(r'Definition v_(\w+) := \{\|\s*gvar_info := (.*?);\s*'
                    r'gvar_init := (.*?);\s*gvar_readonly := (\w+);', re.S)
FUN_RE = re.compile(r'^Definition f_(\w+) := \{\|(.*?)^\|\}\.', re.S | re.M)
EVAR_RE = re.compile(r'Evar _(\w+)')
ADDR_RE = re.compile(r'Init_addrof _(\w+)')


def size0(init):
    init = init.strip()
    if init == 'nil':
        return True
    sp = re.fullmatch(r'\(Init_space (\d+) :: nil\)', init)
    return bool(sp) and int(sp.group(1)) == 0


def main():
    show_all = '--all' in sys.argv
    tus = linked_tus()
    gvars = {}      # name -> list of (tu, info, init)
    funs = {}       # name -> (tu, set of Evar names)
    data_refs = {}  # name -> set of gvars whose initializer takes its address
    data_addrs = {}  # gvar -> names whose address its initializer holds
    for tu in tus:
        s = open(os.path.join(GEN, tu + '.v')).read()
        for m in VAR_RE.finditer(s):
            gvars.setdefault(m.group(1), []).append((tu, m.group(2), m.group(3)))
            for a in ADDR_RE.findall(m.group(3)):
                data_refs.setdefault(a, set()).add(m.group(1))
                data_addrs.setdefault(m.group(1), set()).add(a)
        for m in FUN_RE.finditer(s):
            funs[m.group(1)] = (tu, set(EVAR_RE.findall(m.group(2))))
    # syntactic callgraph closure from the roots: any Evar naming a function,
    # and any function whose address sits in the initializer of a global a
    # reached function mentions (dispatch tables: sInteractionHandlers, ...).
    # Behavior scripts (bhv*) are not followed: their CALL_NATIVE words are run
    # by the object interpreter, which no root calls.
    def succ(names, seen_vars):
        out = set()
        for g in names:
            if g in funs:
                out.add(g)
            elif g in data_addrs and g not in seen_vars and not g.startswith('bhv'):
                seen_vars.add(g)
                out |= succ(data_addrs[g], seen_vars)
        return out
    reached, todo, seen_vars = set(), [r for r in ROOTS if r in funs], set()
    while todo:
        f = todo.pop()
        if f in reached:
            continue
        reached.add(f)
        todo.extend(g for g in succ(funs[f][1], seen_vars) if g not in reached)
    bad = 0
    rows = []
    for g, decls in sorted(gvars.items()):
        if not all(size0(init) for _, _, init in decls):
            continue
        users = sorted(f for f, (_, ev) in funs.items() if g in ev)
        hot = [f for f in users if f in reached]
        cls = '(a)' if hot and g not in ADDRESS_ONLY else '(b)'
        if cls == '(a)':
            bad += 1
        rows.append((cls, g, decls[0][1].replace('\n', ' '), sorted({t for t, _, _ in decls}),
                     hot, users, sorted(data_refs.get(g, ()))))
    print(f'linked TUs: {len(tus)}; reached functions: {len(reached)}; '
          f'size-0 globals: {len(rows)}; class (a): {bad}')
    for cls, g, ty, tus_, hot, users, drefs in rows:
        print(f'{cls} {g} : {ty}  declared in {",".join(tus_)}')
        if hot:
            print(f'      reached users: {", ".join(hot)}')
        if g in ADDRESS_ONLY and hot:
            print(f'      address only: {ADDRESS_ONLY[g]}')
        if show_all and users:
            print(f'      all users: {", ".join(users)}')
        if show_all and drefs:
            print(f'      address in data of: {", ".join(drefs)}')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
