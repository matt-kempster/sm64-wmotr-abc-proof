#!/usr/bin/env python3
"""Driver: symbolically execute one SM64 function over a symbolic MarioState.

EXPLORATORY / UNVERIFIED.  See README.md.

  python3 experiments/symexec/run.py perform_air_step --arg 0
  python3 experiments/symexec/run.py apply_gravity --action 0x0100088C --input 0
  python3 experiments/symexec/run.py act_freefall --action 0x0100088C --input 0

The Φ cells start as symbols:
  Y  = m->pos[1]     V  = m->vel[1]      FH = m->floorHeight
  GY = m->marioObj->header.gfx.pos[1]
  A  = m->action     ST = m->actionState TM = m->actionTimer
(action / state / timer / input can be made concrete with the flags).
Everything else in the MarioState, the Mario object, other objects, surfaces
and globals is lazily symbolic: a read of an unwritten cell yields a fresh
symbol named by its access path and is logged as a world read.
"""
import argparse
import collections
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import numpy as np

from clight_parse import Id, run_with_big_stack
from symexec import Explorer, State, log_list, log_push
from terms import var, show_val, T, is_concrete, mk

MARIO_T = ('Tstruct', Id('MarioState'), 'noattr')
OBJ_T = ('Tstruct', Id('Object'), 'noattr')
SURF_T = ('Tstruct', Id('Surface'), 'noattr')

PHI = [  # (label, region, offset, chunk)
    ('pos[1]', 'M', 64, 'f32'),
    ('vel[1]', 'M', 76, 'f32'),
    ('action', 'M', 12, 'i32'),
    ('actionState', 'M', 24, 'i16u'),
    ('actionTimer', 'M', 26, 'i16u'),
    ('floorHeight', 'M', 112, 'f32'),
    ('gfx.pos[1]', 'OBJ', 36, 'f32'),
]

ACT_NAMES = {}

DEFAULT_SUMMARIZE = (r'^(act_\w+|mario_execute_\w+_action|common_\w+|perform_\w*step|'
                     r'mario_process_interactions|update_mario_\w+|mario_handle_special_floors|'
                     r'sink_mario_in_quicksand|squish_mario_model|set_submerged_cam_preset_and_spawn_bubbles|'
                     r'mario_update_hitbox_and_cap_model|interact_\w+|check_\w+|set_mario_action\w*|'
                     r'mario_reset_bodystate|drop_and_set_mario_action|hurt_and_set_mario_action)$')
# the Φ InRange of HeightInvariant.v (Y's upper bound PHI_K + PHI_A = 2796 holds when credit >= 0)
PHI_RANGES = {'Y': (-8192.0, 2796.0), 'GY': (-8192.0, 2796.0), 'V': (-75.0, 43.0)}


def load_act_names():
    """ACT_* names from the decomp header (for display only)."""
    import re
    p = os.path.join(os.path.dirname(__file__), '..', '..', 'vendor', 'sm64', 'include', 'sm64.h')
    try:
        for line in open(p):
            m = re.match(r'#define\s+(ACT_[A-Z0-9_]+)\s+0x([0-9A-Fa-f]+)', line)
            if m:
                ACT_NAMES.setdefault(int(m.group(2), 16), m.group(1))
    except OSError:
        pass


# ---------------------------------------------------------------------------
# External contracts (value contracts for code outside the 12-TU frame)
# ---------------------------------------------------------------------------

def _out_ptr(ex, st, p, label, pointee):
    """*p := fresh nullable pointer to a world object of type pointee."""
    name = st.fresh(label)
    rn = 'R:' + name
    ex.region(rn, pointee, name, True, True, 'ext')
    if p[0] == 'P':
        ex.store(st, 'i32', p[1], p[2], ('P', rn, 0))
    return rn


def c_find_floor(ex, st, a, tret):
    rn = _out_ptr(ex, st, a[3], 'floor', SURF_T)
    return ('S', var(st.fresh('floorY'), 'f32'))


def c_find_ceil(ex, st, a, tret):
    _out_ptr(ex, st, a[3], 'ceil', SURF_T)
    return ('S', var(st.fresh('ceilY'), 'f32'))


def c_vec3f_find_ceil(ex, st, a, tret):
    _out_ptr(ex, st, a[2], 'ceil', SURF_T)
    return ('S', var(st.fresh('ceilY'), 'f32'))


def c_f32_find_wall_collision(ex, st, a, tret):
    # f32_find_wall_collision(f32 *x, f32 *y, f32 *z, f32 offsetY, f32 radius): may push x, z
    for p, lab in ((a[0], 'wallX'), (a[2], 'wallZ')):
        if p[0] == 'P':
            ex.store(st, 'f32', p[1], p[2], ('S', var(st.fresh(lab), 'f32')))
    return ('I', var(st.fresh('numWalls'), 'i32'))


def c_find_wall_collisions(ex, st, a, tret):
    # find_wall_collisions(struct WallCollisionData *): pushes x,z, fills walls[]/numWalls
    p = a[0]
    if p[0] == 'P':
        wty = ex.regions[p[1]].ty
        st.warn('find_wall_collisions: WallCollisionData x/z/numWalls/walls havocked')
        ly = ex.layout
        info = ly.comp('WallCollisionData')
        for fname, o, fty, _ in info['fields']:
            if fname in ('x', 'z'):
                ex.store(st, 'f32', p[1], p[2] + o, ('S', var(st.fresh('wall' + fname.upper()), 'f32')))
            elif fname == 'numWalls':
                ex.store(st, 'i16s', p[1], p[2] + o, ('I', var(st.fresh('numWalls'), 'i32')))
            elif fname == 'walls':
                for k in range(fty[2]):
                    _out_ptr(ex, st, ('P', p[1], p[2] + o + 4 * k), 'wall', SURF_T)
    return ('I', var(st.fresh('numWalls'), 'i32'))


def c_find_water_level(ex, st, a, tret):
    if getattr(ex, 'world', None) == 'wmotr':
        return ('S', np.float32(-11000.0))   # W: no water / gas boxes in WMotR
    return ('S', var(st.fresh('waterY'), 'f32'))


def c_set_mario_animation(ex, st, a, tret):
    """set_mario_animation / set_mario_anim_with_accel (mario.c), made opaque:
    the real body does `(u8 *) anim + (uintptr_t) anim->values` over DMA'd
    animation data, which a lazily-symbolic world cannot model.  Contract:
    writes only m->marioObj->header.gfx.animInfo (havocked here) and
    returns the new animFrame."""
    ly = ex.layout
    base = ly.field('Object', 'header')[1] + ly.field('ObjectNode', 'gfx')[1] + \
        ly.field('GraphNodeObject', 'animInfo')[1]
    for fname, o, fty, _ in ly.comp('AnimInfo')['fields']:
        ch = {'tshort': 'i16s', 'tushort': 'i16u', 'tint': 'i32'}.get(fty, 'i32')
        if isinstance(fty, tuple):
            _out_ptr(ex, st, ('P', 'OBJ', base + o), 'anim', fty[1])
        else:
            ex.store(st, ch, 'OBJ', base + o, ('I', var(st.fresh('animInfo.' + fname), 'i32')))
    return ex.fresh_result('animFrame', tret, st)


CONTRACTS = {
    'set_mario_animation': c_set_mario_animation,
    'set_mario_anim_with_accel': c_set_mario_animation,
    'find_floor': c_find_floor,
    'find_ceil': c_find_ceil,
    'vec3f_find_ceil': c_vec3f_find_ceil,
    'f32_find_wall_collision': c_f32_find_wall_collision,
    'find_wall_collisions': c_find_wall_collisions,
    'find_water_level': c_find_water_level,
    'find_poison_gas_level': c_find_water_level,
}


# ---------------------------------------------------------------------------
# Initial state
# ---------------------------------------------------------------------------

def initial_state(ex, args):
    st = State()
    ex.region('M', MARIO_T, 'm', True, False, 'mario')
    ex.region('OBJ', OBJ_T, 'm->marioObj', True, False, 'obj')
    ex.global_alias = {'gMarioStates': 'M'}
    orig = ex.global_region

    def global_region(st_, g):
        if g in ex.global_alias:
            return ex.global_alias[g]
        return orig(st_, g)
    ex.global_region = global_region

    def small(v, name):
        if v is None:
            return ('I', var(name, 'i32'))
        return ('I', v & 0xffffffff)
    ex.store(st, 'f32', 'M', 64, ('S', var('Y', 'f32')))
    ex.store(st, 'f32', 'M', 76, ('S', var('V', 'f32')))
    ex.store(st, 'f32', 'M', 112, ('S', var('FH', 'f32')))
    ex.store(st, 'i32', 'M', 12, small(args.action, 'A'))
    ex.store(st, 'i16u', 'M', 24, small(args.state, 'ST'))
    ex.store(st, 'i16u', 'M', 26, small(args.timer, 'TM'))
    if args.input is not None:
        ex.store(st, 'i16u', 'M', 2, ('I', args.input))
    ex.store(st, 'i32', 'M', 136, ('P', 'OBJ', 0))
    ex.store(st, 'f32', 'OBJ', 36, ('S', var('GY', 'f32')))
    for g, target in (('gMarioState', 'M'), ('gMarioObject', 'OBJ')):
        rn = ex.global_region(st, g)
        ex.store(st, 'i32', rn, 0, ('P', target, 0))
    return st


# World invariant W (docs/goal2-value-walk-plan.md §1), the parts modelled here
# (each is an ASSUMPTION the Coq proof would have to carry as a world fact):
#   every surface Mario can touch has a WMotR surface type;
#   m->floor != NULL;  m->heldObj == m->riddenObj == NULL;  quicksandDepth == 0;
#   gCurrLevelNum == LEVEL_WMOTR (31);  m->area->terrainType == TERRAIN_SNOW (2,
#   levels/wmotr/script.c:61).
WMOTR_SURFACE_TYPES = {0x0000, 0x0005, 0x000A, 0x0015, 0x0037}
WORLD_DOMAINS = {'gCurrLevelNum': {31}, 'm->area->terrainType': {2}}


def install_world(ex, st, world):
    ex.world = world
    if world != 'wmotr':
        return

    def domain_fn(region, name, chunk):
        ty = region.ty
        if name in WORLD_DOMAINS:
            return WORLD_DOMAINS[name]
        if name.endswith('->type') and isinstance(ty, tuple) and ty[0] == 'Tstruct' \
                and str(ty[1]) == 'Surface':
            return WMOTR_SURFACE_TYPES
        return None
    ex.domain_fn = domain_fn
    st.facts['nonnull(m->floor)'] = True
    st.facts['nonnull(m->heldObj)'] = False
    st.facts['nonnull(m->riddenObj)'] = False
    ly = ex.layout
    ex.store(st, 'f32', 'M', ly.field('MarioState', 'quicksandDepth')[1], ('S', np.float32(0)))


# collided-object kinds (docs/goal2-wmotr-behavior-census.md; interaction
# types from proofs/WMotRRequiresA/BehaviorScripts.v closure_itypes_value).
# (interactType, preset rawData fields {word index: value}, note)
O_INTERACT_TYPE, O_INTERACTION_SUBTYPE, O_DAMAGE_OR_COIN = 0x2A, 0x42, 0x3E
OBJ_KINDS = {
    'coin':      (0x10, {O_DAMAGE_OR_COIN: 1}, 'yellow coin (bhvCoinFormation child / 1-up pole spawner coins), value 1'),
    'redcoin':   (0x10, {O_DAMAGE_OR_COIN: 2}, 'bhvRedCoin, value 2'),
    'pole':      (0x40, {}, 'bhvPoleGrabbing'),
    'breakable': (0x200, {}, 'bhvExclamationBox (sExclamationBoxHitbox)'),
    'cap':       (0x20, {}, 'sCapHitbox (box contents)'),
    'star':      (0x1000, {}, 'bhvHiddenRedCoinStar star / sCollectStarHitbox'),
    'cannon':    (0x4000, {}, 'bhvCannon base (opened by the buddy)'),
    'text':      (0x800000, {O_INTERACTION_SUBTYPE: 0x4000}, 'bhvBobombBuddyOpensCannon, INT_SUBTYPE_NPC'),
    'none':      (0, {}, '1-up / sparkles / warp: collided, no interaction type'),
    'shell':     (0x80000, {}, 'sKoopaShellHitbox: over-approximated closure only'),
    'flame':     (0x40000, {}, 'bhvKoopaShellFlame: over-approximated closure only'),
}


def install_collided(ex, st, kind):
    """marioObj->numCollidedObjs = 1, collidedObjs[0] = COLL (an Object of `kind`);
    every other COLL field is lazily symbolic and its reads are tracked."""
    ly = ex.layout
    itype, fields, _ = OBJ_KINDS[kind]
    ex.region('COLL', OBJ_T, 'coll', True, False, 'obj')
    ex.store(st, 'i16s', 'OBJ', ly.field('Object', 'numCollidedObjs')[1], ('I', 1))
    ex.store(st, 'i32', 'OBJ', ly.field('Object', 'collidedObjs')[1], ('P', 'COLL', 0))
    ex.store(st, 'i32', 'OBJ', ly.field('Object', 'collidedObjInteractTypes')[1], ('I', itype))
    raw = ly.field('Object', 'rawData')[1]
    ex.store(st, 'i32', 'COLL', raw + 4 * O_INTERACT_TYPE, ('I', itype))
    for idx, val in fields.items():
        ex.store(st, 'i32', 'COLL', raw + 4 * idx, ('I', val & 0xffffffff))
    ex.track_regions.add('COLL')


def object_field_names():
    """Object byte offset -> o* field names (include/object_fields.h)."""
    import re
    p = os.path.join(os.path.dirname(__file__), '..', '..', 'vendor', 'sm64', 'include', 'object_fields.h')
    out = collections.defaultdict(list)
    try:
        for line in open(p):
            m = re.match(r'#define\s+/\*(0x[0-9A-Fa-f]+)\*/\s+(o[A-Z]\w*)\s+OBJECT_FIELD_', line)
            if m:
                out[int(m.group(1), 0)].append(m.group(2))
    except OSError:
        pass
    return out


def r_noa_set():
    import re
    p = os.path.join(os.path.dirname(__file__), '..', '..', 'proofs', 'WMotRRequiresA', 'NoAActions.v')
    try:
        return {int(x) for x in re.findall(r'^\s+(\d+) \(\*', open(p).read(), re.M)}
    except OSError:
        return set()


def show_action(v):
    if v[0] == 'I' and is_concrete(v[1]):
        return '0x%08X%s' % (v[1], (' ' + ACT_NAMES[v[1]]) if v[1] in ACT_NAMES else '')
    return show_val(v[1]) if v[0] in 'ISFL' else str(v)


def phi_of(ex, st):
    out = collections.OrderedDict()
    for lab, reg, ofs, ch in PHI:
        try:
            v = ex.load(st, ch, None, reg, ofs)
            out[lab] = show_action(v) if lab == 'action' else ex.show_value(v)
        except Exception as e:  # noqa
            out[lab] = '<%s>' % e
    return out


# control cells kept exact by joins (besides Φ): joining them loses e.g. the
# no-A fact carried by m->input and invents A-gated paths
KEY_CELLS = [('input', 'M', 2, 'i16u'), ('flags', 'M', 4, 'i32'), ('waterLevel', 'M', 118, 'i16s')]


EXACT_KEY = {'waterLevel'}   # + 'input' / 'flags' with --exact-input / --exact-flags


def merge_key(ex, st):
    k = tuple(phi_of(ex, st).values())
    extra = []
    for lab, reg, ofs, ch in KEY_CELLS:
        if lab not in EXACT_KEY:
            continue
        cell = st.mem.get(reg, {}).get(ofs)
        extra.append(ex.show_value(cell[1]) if cell else '-')
    # inside a summary, facts on the callee's initial m->input / held-object
    # pointers must survive joins: they are what the call site decides
    kf = tuple(sorted((f, v) for f, v in st.facts.items() if any(p in f for p in KEY_FACT_SUBSTR)))
    return k + tuple(extra) + kf


KEY_FACT_SUBSTR = ('nonnull(m->heldObj)', 'nonnull(m->riddenObj)', 'nonnull(m->usedObj)',
                   'nonnull(m->interactObj)')


def install_summary_skeleton(ex, st, key_input=False):
    """Root cells a summary may assume when the caller still holds them: every
    preset cell of the initial state except Φ / the key cells (pointers
    m->marioObj, gMarioState, m->controller, W's quicksandDepth, the
    collided-object model, ...), and W's nonnull facts on m->floor / heldObj /
    riddenObj while those cells are unwritten."""
    skip = {(reg, ofs) for _, reg, ofs, _ in PHI} | {(reg, ofs) for _, reg, ofs, _ in KEY_CELLS}
    for reg, cells in st.mem.items():
        for ofs, (chunk, v) in cells.items():
            if (reg, ofs) not in skip:
                ex.summary_skeleton.append((reg, ofs, chunk, v))
    for key, pol in st.facts.items():
        path = key[len('nonnull('):-1]
        if key.startswith('nonnull(m->') and '->' not in path[3:]:
            ex.summary_skel_facts.append((key, pol, 'M', ex.layout.field('MarioState', path[3:])[1]))
    ly = ex.layout
    ex.summary_presets = [('M', 12, 'i32'), ('M', 24, 'i16u'),
                          ('M', ly.field('MarioState', 'actionArg')[1], 'i32')]
    if key_input:
        ex.summary_presets.append(('M', 2, 'i16u'))
    else:
        ex.summary_masked.append(('M', 2, 'i16u'))


def report_object_fields(ex, results):
    """Which collided-object fields the frame reads / writes, and whether a
    field's value reaches the Φ result, the return value or a path fact."""
    import re
    names = object_field_names()
    raw = ex.layout.field('Object', 'rawData')[1]
    rd, wr = collections.Counter(), collections.Counter()
    blob_phi, blob_pc = [], []
    for ret, s in results:
        for r in set(log_list(s.reads)):
            if r.startswith('TRACK:'):
                rd[r[6:]] += 1
            elif r.startswith('TRACKW:'):
                wr[r[7:]] += 1
        blob_phi.append(' '.join(phi_of(ex, s).values()) + ' ' + (ex.show_value(ret) if not (
            isinstance(ret, tuple) and ret[0] in ('stuck', 'trunc')) else ''))
        blob_pc.append(' '.join(s.facts.keys()))
    phi_txt, pc_txt = '\n'.join(blob_phi), '\n'.join(blob_pc)
    ly = ex.layout
    presets = ex.summary_skeleton
    preset_paths = set()
    for reg, ofs, chunk, v in presets:
        if reg == 'COLL':
            r = ex.regions['COLL']
            preset_paths.add('%s%s' % (r.path, ex._path(r, ofs, chunk)))
    print('   collided-object (coll) field accesses (%d paths):' % len(results))
    for path in sorted(set(rd) | set(wr)):
        m = re.search(r'rawData\.as\w+\[(\d+)\]', path)
        o = None
        if m:
            o = raw + 4 * int(m.group(1))
        else:
            f = path.split('->', 1)[1].split('.')[0].split('[')[0]
            try:
                o = ly.field('Object', f)[1]
            except Exception:
                o = None
        nm = '/'.join(names.get(o, [])[:3]) if m else ''
        ofs = '+0x%X' % o if o is not None else ''
        esc = re.escape(path)
        in_phi = re.search(esc + r'(?![\w\[.])', phi_txt) is not None
        in_pc = re.search(esc + r'(?![\w\[.])', pc_txt) is not None
        dep = ('preset; ' if path in preset_paths else '') + (
            'in Φ/ret' if in_phi else ('in final path facts' if in_pc else 'no trace in result'))
        print('     %-34s %-8s %-40s R%-5d W%-5d %s' % (path, ofs, nm, rd.get(path, 0), wr.get(path, 0), dep))


def root_of(read):
    """Group a world-read access path by what it reads."""
    for pfx in ('m->marioObj', 'm->', 'floor#', 'ceil#', 'wall#'):
        if read.startswith(pfx):
            return pfx.rstrip('#>-')
    return read.split('.')[0].split('[')[0].split('->')[0]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('function')
    ap.add_argument('--action', type=lambda s: int(s, 0))
    ap.add_argument('--state', type=lambda s: int(s, 0))
    ap.add_argument('--timer', type=lambda s: int(s, 0))
    ap.add_argument('--input', type=lambda s: int(s, 0))
    ap.add_argument('--arg', action='append', default=[],
                    help='extra int args after m (number or "sym")')
    ap.add_argument('--opaque', default='set_mario_animation,set_mario_anim_with_accel',
                    help='comma list of internal functions to treat as external (contracts in CONTRACTS)')
    ap.add_argument('--merge', default='perform_air_quarter_step,resolve_and_return_wall_collisions,'
                    'mario_get_terrain_sound_addend',
                    help='comma list of functions whose outcomes are joined when they agree on '
                         '(return value, Φ cells); "" disables')
    ap.add_argument('--join-loops', action='store_true',
                    help='join states at every loop head / loop exit (same temps and Φ cells)')
    ap.add_argument('--noA', action='store_true',
                    help='m->controller->buttonDown/buttonPressed have the A bit (0x8000) clear')
    ap.add_argument('--no-collisions', action='store_true',
                    help='marioObj->numCollidedObjs = 0 and collidedObjInteractTypes = 0 (no object interactions this frame)')
    ap.add_argument('--world', choices=['any', 'wmotr'], default='any',
                    help='wmotr: assume W (surface types in the WMotR set, m->floor != NULL)')
    ap.add_argument('--collide', choices=sorted(OBJ_KINDS),
                    help='one collided object of this WMotR kind (see OBJ_KINDS)')
    ap.add_argument('--summarize', default=DEFAULT_SUMMARIZE,
                    help='regex of functions run once as summaries and applied at call sites ("" disables)')
    ap.add_argument('--exact-input', action='store_true',
                    help='joins keep m->input exact (default: joined into a symbol whose possibly-set '
                         'bits are tracked, which keeps INPUT_A_PRESSED/A_DOWN known-zero under --noA)')
    ap.add_argument('--exact-flags', action='store_true',
                    help='joins keep m->flags exact (default: joined, possibly-set bits tracked)')
    ap.add_argument('--summary-key-input', action='store_true',
                    help='also specialise summaries on a concrete m->input (default: input stays symbolic '
                         'in the summary and is decided at the call site)')
    ap.add_argument('--no-phi-ranges', action='store_true',
                    help='do not assume Φ InRange (-8192 <= Y, GY <= 2796; -75 <= V <= 43)')
    ap.add_argument('--max-paths', type=int, default=200000, help='cap on the number of forks')
    ap.add_argument('--loop-fuel', type=int, default=64)
    ap.add_argument('--max-depth', type=int, default=40)
    ap.add_argument('--show', type=int, default=12, help='paths to print in full')
    ap.add_argument('--no-pc', action='store_true')
    ap.add_argument('--show-action', type=lambda x: int(x, 0), help='also print 3 paths ending in this action')
    ap.add_argument('--shapes', action='store_true', help='print Φ result shapes (normalised)')
    ap.add_argument('--group', action='store_true', help='group paths by Φ result')
    args = ap.parse_args()
    load_act_names()

    ex = Explorer(max_paths=args.max_paths, loop_fuel=args.loop_fuel, max_depth=args.max_depth,
                  contracts=CONTRACTS, opaque=[s for s in args.opaque.split(',') if s],
                  merge=[s for s in args.merge.split(',') if s],
                  merge_key=merge_key,
                  join_loops=args.join_loops)
    st = initial_state(ex, args)
    install_world(ex, st, args.world)
    if args.no_collisions:
        for fld, ch in (('numCollidedObjs', 'i16s'), ('collidedObjInteractTypes', 'i32')):
            ex.store(st, ch, 'OBJ', ex.layout.field('Object', fld)[1], ('I', 0))
    if args.noA:
        CTRL_T = ('Tstruct', Id('Controller'), 'noattr')
        ex.region('CTRL', CTRL_T, 'm->controller', True, False, 'world')
        ex.store(st, 'i32', 'M', ex.layout.field('MarioState', 'controller')[1], ('P', 'CTRL', 0))
        for fld in ('buttonDown', 'buttonPressed'):
            o = ex.layout.field('Controller', fld)[1]
            ex.store(st, 'i16u', 'CTRL', o,
                     ('I', mk('and', 'i32', var('m->controller->' + fld, 'i32'), 0x7FFF)))
    if args.exact_input:
        EXACT_KEY.add('input')
    if args.exact_flags:
        EXACT_KEY.add('flags')
    if args.collide:
        install_collided(ex, st, args.collide)
    if not args.no_phi_ranges:
        ex.var_range.update(PHI_RANGES)
    if args.summarize:
        import re
        rx = re.compile(args.summarize)
        top = args.function
        ex.summarize = lambda fn: fn != top and rx.match(fn) is not None
        install_summary_skeleton(ex, st, args.summary_key_input)
    f = ex.functions[args.function]
    p0 = f['fn_params'][0][2] if f['fn_params'] else None
    obj_first = isinstance(p0, tuple) and p0[0] == 'tptr' and str(p0[1][1]) == 'Object'
    vargs = [('P', 'OBJ' if obj_first else 'M', 0)]
    for i, (p, a) in enumerate(zip(f['fn_params'][1:], args.arg)):
        if a == 'sym':
            vargs.append(('I', var('arg%d' % (i + 1), 'i32')))
        else:
            vargs.append(('I', int(a, 0) & 0xffffffff))
    for p in f['fn_params'][1 + len(args.arg):]:
        vargs.append(('I', var(str(p[1]), 'i32')))
    st.fname = '<top>'
    results = ex.run(args.function, vargs, st)

    print('== %s  (action=%s input=%s args=%s world=%s)  %d paths' % (
        args.function, hex(args.action) if args.action is not None else 'A(sym)',
        args.input, args.arg or 'sym', args.world, len(results)))
    outcomes = collections.Counter()
    externals = collections.Counter()
    internals = collections.Counter()
    reads = collections.Counter()
    warns = collections.Counter()
    groups = collections.OrderedDict()
    shown_action = [0]
    for i, (ret, s) in enumerate(results):
        if isinstance(ret, tuple) and ret[0] in ('stuck', 'trunc'):
            kind = ret[0] + ': ' + ret[1]
            rets = kind
        else:
            kind = 'return'
            rets = ex.show_value(ret)
        outcomes[kind if kind != 'return' else 'return'] += 1
        calls = log_list(s.calls)
        ext = [c for c in calls if c[0] == 'external']
        for c in ext:
            externals[c[1]] += 1
        for c in calls:
            if c[0] == 'internal':
                internals[c[1]] += 1
        rd = sorted(set(log_list(s.reads)))
        for r in rd:
            reads[r] += 1
        for w in set(log_list(s.warns)):
            warns[w] += 1
        phi = phi_of(ex, s)
        key = (rets,) + tuple(phi.values())
        groups.setdefault(key, []).append(i)
        fa = s.mem.get('M', {}).get(12)
        want = args.show_action is not None and fa is not None and fa[1] == ('I', args.show_action)
        if i < args.show or (want and shown_action[0] < 3):
            if want:
                shown_action[0] += 1
            print('\n-- path %d: %s' % (i, rets))
            if not args.no_pc:
                for c in log_list(s.pc):
                    print('   pc  ', c if len(c) < 200 else c[:200] + '...')
            for k, v in phi.items():
                print('   %-12s = %s' % (k, v))
            print('   facts    :', '; '.join('%s%s' % ('' if v else 'NOT ', k[:120]) for k, v in s.facts.items()))
            print('   externals:', ', '.join('%s(%s)' % (c[1], c[2][:60]) for c in ext) or '-')
            ws = log_list(s.warns)
            if ws:
                print('   warnings :', '; '.join(sorted(set(ws))))
    print('\n== summary: %d paths, %d forks' % (len(results), ex.forks))
    for k, n in outcomes.most_common():
        print('   %5d  %s' % (n, k))
    if ex.truncations:
        print('   truncations:', collections.Counter(ex.truncations).most_common(10))
    print('   distinct Φ results: %d' % len(groups))
    if args.group:
        for key, idx in groups.items():
            print('   [%d, e.g. #%d] ret=%s | %s' % (len(idx), idx[0], key[0], ' | '.join(
                '%s=%s' % (lab, v) for (lab, _, _, _), v in zip(PHI, key[1:]))))
    if args.shapes:
        import re
        norm = lambda x: re.sub(r'mrg\d+', 'mrg', re.sub(r'#(?:s\d+_)?\d+', '#k', x))
        shapes = collections.Counter()
        for key, idx in groups.items():
            ph = dict(zip([p[0] for p in PHI], key[1:]))
            ret = key[0] if not key[0].startswith(('stuck', 'trunc')) else key[0][:40]
            shapes[(ph['action'].split()[-1], norm(ph['pos[1]']), norm(ph['vel[1]']),
                    ph['actionState'] + '/' + ph['actionTimer'],
                    'gfx=pos' if ph['gfx.pos[1]'] == ph['pos[1]'] else 'gfx=' + norm(ph['gfx.pos[1]']),
                    'fh=' + norm(ph['floorHeight']), 'ret=' + ret)] += len(idx)
        print('   Φ shapes (indices #k / mrg ids normalised): %d' % len(shapes))
        for sh, n in sorted(shapes.items()):
            print('     %4d  %s' % (n, ' | '.join(sh)))
    # action-dispatch loop: iterations of `while (inLoop)` (last one exits)
    iters = collections.Counter()
    for ret, s in results:
        n = s.ctr.get('iter@execute_mario_action')
        if n is not None:
            iters[n - 1] += 1
    if iters:
        print('   dispatch-loop handler calls per path:', dict(sorted(iters.items())))
    if ex.cycle_cuts:
        print('   loop-head states cut as repeats of an earlier iteration (abstract cycles):', dict(ex.cycle_cuts))
        print('     by action at the loop head:', ', '.join('%s×%d' % (a.split()[-1], n) for (f, a), n in
                                                          ex.cycle_keys.most_common(12)))
    # actions reached
    noa = r_noa_set()
    acts = collections.Counter()
    for ret, s in results:
        if isinstance(ret, tuple) and ret[0] in ('stuck', 'trunc'):
            continue
        v = ex.load(s, 'i32', None, 'M', 12)
        acts[v[1] if v[0] == 'I' and is_concrete(v[1]) else show_val(v[1])] += 1
    print('   final actions (%d):' % len(acts))
    for a, n in sorted(acts.items(), key=lambda kv: -kv[1]):
        if isinstance(a, int):
            flag = '' if a in noa else '   <-- NOT in R_noA'
            print('     %5d  0x%08X %s%s' % (n, a, ACT_NAMES.get(a, '?'), flag))
        else:
            print('     %5d  %s   <-- symbolic' % (n, a))
    if ex.summary_stats:
        print('   summaries:', dict(ex.summary_stats))
    if 'COLL' in ex.track_regions:
        report_object_fields(ex, results)
    print('   internal functions executed:', ', '.join(sorted(internals)))
    print('   externals (%d): %s' % (len(externals), ', '.join('%s×%d' % kv for kv in sorted(externals.items()))))
    byroot = collections.defaultdict(set)
    for r in reads:
        byroot[root_of(r)].add(r)
    print('   world reads (%d distinct):' % len(reads))
    for root in sorted(byroot):
        items = sorted(byroot[root])
        print('     %-14s %s' % (root, ', '.join(items[:40]) + (' ...(+%d)' % (len(items) - 40) if len(items) > 40 else '')))
    cg = sorted(ex.const_globals_used - {'gMarioState', 'gMarioObject'})
    if cg:
        print('   globals taken as their initialiser (never written in the loaded TUs):', ', '.join(cg))
    if ex.merges:
        print('   joins:', dict(ex.merges))
    if warns:
        print('   warnings:')
        for w, n in warns.most_common(20):
            print('     %5d  %s' % (n, w))


if __name__ == '__main__':
    run_with_big_stack(main)
