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
mention it (syntactic `Evar _x`), each use tagged `addr` (the symbol used as
a VALUE: `Eaddrof (Evar _x ..)`, an array-typed `Evar` that decays to its
address, a function designator) or `access` (loaded / stored by name).
Each is classified:

  (a) REACHED  -- mentioned by a function reachable (syntactic callgraph) from
                  the frame / boot roots below, in EITHER form, or its address
                  sits in the initializer of a global that reached code
                  mentions (transitively, through data): it must get storage
                  (linking its definer, or a 2.4 completion in
                  pipeline/clightgen.sh) or it is a finding;
  (c) BOOT     -- only the boot / game-loop roots (BOOT_ROOTS: the game
                  thread, outside every capstone and witness) reach it.  Each
                  must be listed in BOOT_KNOWN with its reason (a new one is a
                  failure, so that a boot-time address that flows into frame
                  data, as gMarioAnims's did, is looked at by hand);
  (b) note     -- none of these.

Why address uses count (widened 2026-10-22): a pointer into a size-0 block
has no weakly valid offset, so CompCert's pointer comparison on it
(`p != NULL`, `p != q`) has NO execution, not only loads and stores.  Found:
gMarioAnims (extern u8 gMarioAnims[], data not linked) was only ever named by
setup_game_memory, which passes its address to setup_dma_table_list; from
there it flows into the anim DMA table and every load_patchable_table compare
`addr != list->currentAddr` (memory.c:575) was stuck (523/600 real frames in
the oracle difftest).  The old sweep missed it twice: setup_game_memory was
not a root, and the address flows through data, not through a name.  Class
(c) now covers the game thread (thread5_game_loop: setup_game_memory and the
per-frame loop).

Exit status 1 iff some (a) global is still size 0, or some (c) global is not
in BOOT_KNOWN (the audit runs this).
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

# the game thread (game_init.c:643): setup_game_memory (the anim / demo DMA
# tables), init_controllers, and the per-frame loop (render, controller poll)
BOOT_ROOTS = ['thread5_game_loop', 'setup_game_memory']

# class (c), each checked by hand (2026-10-22).  None is reached by a frame /
# entry root, and none's address is stored where frame code reads it.
_ROMSYM = ('linker-script ROM symbol (no C storage in the real build either); '
           'setup_game_memory passes it to load_segment / dma_read, the DMA floor. '
           'FOUND: `srcEnd - srcStart` across two blocks has no CompCert execution, '
           'so setup_game_memory has none (main_pool_init has none already, TRUST 3.6)')
_RSP = ('RSP microcode / output symbol (render path): create_gfx_task_structure stores '
        'its address into the graphics task (RSP floor).  FOUND: `rspF3DBootEnd - '
        'rspF3DBootStart` (game_init.c:254) across two blocks has no CompCert execution, '
        'so create_gfx_task_structure has none; outside every capstone and witness')
_MAIN = ('main.c BSS (unlinked definer, = 0); loaded by name on the render / reset path '
         '(draw_reset_bars, end_master_display_list, thread5_game_loop): those have no '
         'execution, outside every capstone and witness')
BOOT_KNOWN = {
    '__osContPifRam': 'libultra osContStartReadData.c BSS (unlinked); osContInit / '
                      '__osPackRequestData access it by name: init_controllers and '
                      'the controller poll have no execution (input is a premise)',
    '_entrySegmentRomEnd': _ROMSYM, '_entrySegmentRomStart': _ROMSYM,
    '_segment2_mio0SegmentRomEnd': _ROMSYM, '_segment2_mio0SegmentRomStart': _ROMSYM,
    'gDemoInputs': 'the demo-input DMA table (build/us/assets/demo_data.c, made from '
                   'baserom-extracted assets/demos/*.bin: not in the vendor tree, so not '
                   'linked).  FOUND: setup_dma_table_list\'s `srcAddr != NULL` on it has no '
                   'execution; its table is read only by title_screen.c (unlinked; never '
                   'during WMotR play)',
    'gFramebuffers': 'framebuffers.c BSS; setup_game_memory stores the addresses into '
                     'gPhysicalFramebuffers (no compare / deref in linked code; the VI floor)',
    'gZBuffer': 'zbuffer.c BSS; address stored only (RDP floor)',
    'gGfxSPTaskOutputBuffer': _RSP, 'rspF3DBootEnd': _RSP, 'rspF3DBootStart': _RSP,
    'rspF3DDataStart': _RSP, 'rspF3DStart': _RSP,
    'gNmiResetBarsTimer': _MAIN, 'gResetTimer': _MAIN, 'gShowProfiler': _MAIN,
    'level_script_entry': 'the level script (unlinked); thread5_game_loop passes its '
                          'address to level_script_execute, unlinked',
}


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
# the symbol used as a value: &x, an array (decays to &x[0]), a function
ADDR_USE_RE = re.compile(r'Eaddrof\s*\(\s*Evar _(\w+)|Evar _(\w+)\s*\(\s*(?:tarray|Tarray|Tfunction)')
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
    addr_uses = {}  # function -> set of names it uses as a value (address)
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
            addr_uses[m.group(1)] = {a or b for a, b in ADDR_USE_RE.findall(m.group(2))}
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
    def closure(roots):
        reached, todo, seen_vars = set(), [r for r in roots if r in funs], set()
        while todo:
            f = todo.pop()
            if f in reached:
                continue
            reached.add(f)
            todo.extend(g for g in succ(funs[f][1], seen_vars) if g not in reached)
        return reached

    # globals whose bytes reached code can see: named by a reached function,
    # then (transitively) every global whose address sits in one's initializer
    # (bhv* scripts excepted, as above)
    def live(reached):
        lv = set()
        todo = [g for f in reached for g in funs[f][1] if g in gvars]
        while todo:
            g = todo.pop()
            if g in lv:
                continue
            lv.add(g)
            if not g.startswith('bhv'):
                todo.extend(a for a in data_addrs.get(g, ()) if a in gvars and a not in lv)
        return lv
    reached = closure(ROOTS)
    live_vars = live(reached)
    boot_reached = closure(ROOTS + BOOT_ROOTS)
    boot_live = live(boot_reached)
    bad = nboot = 0
    rows = []
    for g, decls in sorted(gvars.items()):
        if not all(size0(init) for _, _, init in decls):
            continue
        users = sorted(f for f, (_, ev) in funs.items() if g in ev)
        hot = [f for f in users if f in reached]
        hot_tag = [f + ('[addr]' if g in addr_uses.get(f, ()) else '[access]') for f in hot]
        via = sorted(d for d in data_refs.get(g, ()) if d in live_vars and not d.startswith('bhv'))
        if (hot or via) and g not in ADDRESS_ONLY:
            cls = '(a)'
            bad += 1
        elif not (hot or via) and (
                any(f in boot_reached for f in users)
                or any(d in boot_live and not d.startswith('bhv')
                       for d in data_refs.get(g, ()))):
            cls = '(c)'
            nboot += 1
            hot = [f for f in users if f in boot_reached]
            hot_tag = [f + ('[addr]' if g in addr_uses.get(f, ()) else '[access]') for f in hot]
            via = sorted(d for d in data_refs.get(g, ()) if d in boot_live and not d.startswith('bhv'))
            if g not in BOOT_KNOWN:
                bad += 1
        else:
            cls = '(b)'
        rows.append((cls, g, decls[0][1].replace('\n', ' '), sorted({t for t, _, _ in decls}),
                     hot_tag, via, users, sorted(data_refs.get(g, ()))))
    print(f'linked TUs: {len(tus)}; reached functions: {len(reached)} '
          f'(+ boot: {len(boot_reached)}); size-0 globals: {len(rows)}; '
          f'class (c): {nboot}; failing: {bad}')
    for cls, g, ty, tus_, hot, via, users, drefs in rows:
        if cls == '(c)':
            why = BOOT_KNOWN.get(g, 'NOT IN BOOT_KNOWN: check it by hand')
            print(f'(c) {g} : {ty}  declared in {",".join(tus_)}')
            print(f'      boot users: {", ".join(hot)}' + (f'; via data of {", ".join(via)}' if via else ''))
            print(f'      {why}')
            continue
        print(f'{cls} {g} : {ty}  declared in {",".join(tus_)}')
        if hot:
            print(f'      reached users: {", ".join(hot)}')
        if via:
            print(f'      address in the data of reached globals: {", ".join(via)}')
        if g in ADDRESS_ONLY and hot:
            print(f'      address only: {ADDRESS_ONLY[g]}')
        if show_all and users:
            print(f'      all users: {", ".join(users)}')
        if show_all and drefs:
            print(f'      address in data of: {", ".join(drefs)}')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
