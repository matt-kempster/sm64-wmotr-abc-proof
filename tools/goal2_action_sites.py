#!/usr/bin/env python3
"""GOAL 2 R_noA census: every write of MarioState.action in the twelve linked TUs.

    python3 tools/goal2_action_sites.py            # summary + sets to stdout
    python3 tools/goal2_action_sites.py --sites    # full site table (TSV)
    python3 tools/goal2_action_sites.py --json F   # everything, machine-readable

Two independent extractions, cross-checked per function:

1. CLIGHT (authoritative for WHAT is written): generated/<tu>.v, the committed
   clightgen output.  A "site" is a call to an action-setter with a constant
   action argument (Econst_int, decimal), or a direct Sassign to
   <MarioState>.action.  Setters are computed as a fixpoint: set_mario_action
   is the base (it stores its `action` param, mario.c:1007); any function that
   passes one of its own params into a setter's action slot is itself a setter
   for that param (drop_and_set_mario_action, set_jumping_action,
   common_air_action_step's landAction, check_common_landing_cancels, ...).
   Non-constant, non-param action arguments are reported as COMPUTED.

2. C (for WHERE and UNDER WHAT GUARD): vendor/sm64/src/game/<tu>.c, run
   through `gcc -E` with the pipeline's clightgen flags (pipeline/clightgen.sh,
   VERSION_US) and parsed with pycparser.  The same fixpoint, but each site
   and each call edge also records its enclosing guard literals (if/else
   polarity, &&/||/?: short-circuit, switch case, loop).  Line numbers are the
   real .c lines.

Guard classes (per site / per call edge; polarity-aware):
  A_PRESSED  the guard REQUIRES m->input & INPUT_A_PRESSED (0x2), or
             controller->buttonPressed & A_BUTTON (0x8000)
  A_DOWN     the guard REQUIRES m->input & INPUT_A_DOWN (0x80), or
             controller->buttonDown & A_BUTTON
  (a site inside `if (!(m->input & INPUT_A_DOWN))` is NOT A-gated.)
Other feature tags (water, floor type, held object, ...) are decoded for the
reader and consumed by the WMotR filter below (ABSENT_*), whose entries each
cite the E1 inventory / behavior census.

Reachability: an action X "runs" the functions reachable (C call graph, plus
address-taken function refs, e.g. interaction.c's sInteractionHandlers table)
from its group dispatcher's prelude and its switch-case handler.  Frame-global
code (execute_mario_action's non-dispatch calls, level_update.c, behavior
code) is context-free.  A call edge or site is DROPPED if its guard requires A
(mode noA: A_PRESSED and A_DOWN; mode noApress: A_PRESSED only) or requires a
WMotR-absent feature.  Guards on m->action / actionState are ignored
(over-approximation: R_reach may be larger than the truth, never smaller,
modulo the stated filters).
"""
import argparse
import collections
import json
import os
import re
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'vendor/sm64/src/game')
TUS = ['mario', 'mario_actions_stationary', 'mario_actions_moving', 'mario_actions_airborne',
       'mario_actions_submerged', 'mario_actions_cutscene', 'mario_actions_automatic',
       'mario_actions_object', 'interaction', 'behavior_actions', 'level_update', 'mario_step']
CFLAGS = ['-nostdinc', '-Ivendor/sm64/include', '-Ivendor/sm64/build/us',
          '-Ivendor/sm64/build/us/include', '-Ivendor/sm64/src', '-Ivendor/sm64',
          '-Ivendor/sm64/include/libc', '-DVERSION_US=1', '-DF3DEX_GBI_2=1',
          '-DF3DEX_GBI_SHARED=1', '-D_FINALROM=1', '-DTARGET_N64=1', '-DNON_MATCHING=1',
          '-DAVOID_UB=1', '-D_LANGUAGE_C=1', '-D__attribute__(x)=', '-D__asm__(x)=',
          '-include', 'pipeline/proof_n64.h']

# ---------------------------------------------------------------- constants

def load_defines(path, prefix):
    out = {}
    for line in open(os.path.join(ROOT, path)):
        m = re.match(r'#define\s+(%s\w+)\s+(0x[0-9A-Fa-f]+|\d+)\b' % prefix, line)
        if m:
            out[m.group(1)] = int(m.group(2), 0)
    return out

ACTS = load_defines('vendor/sm64/include/sm64.h', 'ACT_')
ACTS = {k: v for k, v in ACTS.items() if not k.startswith(('ACT_FLAG', 'ACT_GROUP', 'ACT_ID_MASK'))}
ACT_NAME = {}
for k, v in ACTS.items():
    ACT_NAME.setdefault(v, k)
INPUTS = load_defines('vendor/sm64/include/sm64.h', 'INPUT_')
SURF = load_defines('vendor/sm64/include/surface_terrains.h', 'SURFACE_')
SURF_NAME = {}
for k, v in SURF.items():
    SURF_NAME.setdefault(v, k)
BUTTONS = {0x8000: 'A_BUTTON', 0x4000: 'B_BUTTON', 0x2000: 'Z_TRIG', 0x1000: 'START_BUTTON'}
ACT_FLAG_AIR = 0x800
A_PRESS_BIT, A_DOWN_BIT = INPUTS['INPUT_A_PRESSED'], INPUTS['INPUT_A_DOWN']


def aname(v):
    return ACT_NAME.get(v, '0x%08X?' % v)

# ------------------------------------------------------------ Clight side
TOK = re.compile(r'\{\||\|\}|\(|\)|"[^"]*"|[^\s(){}]+')


def _group(toks, i):
    out = []
    i += 1
    while toks[i] != ')':
        if toks[i] == '(':
            sub, i = _group(toks, i)
            out.append(sub)
        else:
            out.append(toks[i])
            i += 1
    return out, i + 1


def clight_functions(tu):
    txt = open(os.path.join(ROOT, 'generated', tu + '.v')).read()
    for m in re.finditer(r'^Definition f_(\w+) := \{\|(.*?)^\|\}\.', txt, re.S | re.M):
        toks = TOK.findall(m.group(2))

        def grab(key):
            k = toks.index(key)
            return _group(toks, k + 2)[0] if toks[k + 2] == '(' else toks[k + 2]
        params = grab('fn_params')
        pn = [x[0].rstrip(',')[1:] for x in (params if isinstance(params, list) else [])
              if isinstance(x, list) and x and isinstance(x[0], str)]
        yield m.group(1), pn, grab('fn_body')


def _args(g):
    args, cur = [], []
    for x in g:
        if x == '::':
            args.append(cur)
            cur = []
        else:
            cur.append(x)
    return [a[0] if len(a) == 1 else a for a in args if a and a != ['nil']]


def _ival(x):
    while isinstance(x, list):
        x = x[0]
    return int(x) & 0xFFFFFFFF


def _walk(g, f):
    if isinstance(g, list):
        f(g)
        for x in g:
            _walk(x, f)


def _is_action_lhs(e):
    return (isinstance(e, list) and len(e) >= 4 and e[0] == 'Efield' and e[2] == '_action'
            and isinstance(e[1], list) and e[1][0] == 'Ederef'
            and e[1][2] == ['Tstruct', '_MarioState', 'noattr'])


def clight_sites():
    """-> (sites, computed, setters). sites: list of (tu, fn, target_int, via)."""
    fns = {}
    for tu in TUS:
        for name, ps, body in clight_functions(tu):
            fns[(tu, name)] = (ps, body)
    setters = {'set_mario_action': {1}}

    def resolve(expr, ps, body, depth=0):
        """-> list of (kind, val): const int / param index / computed expr.
        Temps are followed through every Sset to them (union)."""
        e = expr
        while isinstance(e, list) and e[0] == 'Ecast':
            e = e[1]
        if isinstance(e, list) and e[0] == 'Econst_int':
            return [('const', _ival(e[1][1]))]
        if isinstance(e, list) and e[0] == 'Etempvar' and depth < 8:
            v = e[1][1:]
            out = [('param', ps.index(v))] if v in ps else []
            rhss = []
            _walk(body, lambda g: rhss.append(g[2]) if g[0] == 'Sset' and g[1] == e[1] else None)
            for r in rhss:
                out += resolve(r, ps, body, depth + 1)
            return out or [('computed', expr)]
        return [('computed', expr)]

    changed = True
    while changed:
        changed = False
        for (tu, fn), (ps, body) in fns.items():
            calls = []
            _walk(body, lambda g: calls.append(g) if g[0] == 'Scall' else None)
            for c in calls:
                callee = c[2][1][1:] if c[2][0] == 'Evar' else None
                if callee in setters:
                    args = _args(c[3])
                    for i in setters[callee]:
                        for kind, val in resolve(args[i], ps, body):
                            if kind == 'param' and val not in setters.setdefault(fn, set()):
                                setters[fn].add(val)
                                changed = True
    sites, computed = [], []
    for (tu, fn), (ps, body) in fns.items():
        calls, stores = [], []
        _walk(body, lambda g: calls.append(g) if g[0] == 'Scall' else None)
        _walk(body, lambda g: stores.append(g) if g[0] == 'Sassign' and _is_action_lhs(g[1]) else None)
        for c in calls:
            callee = c[2][1][1:] if c[2][0] == 'Evar' else None
            if callee in setters:
                args = _args(c[3])
                for i in setters[callee]:
                    for kind, val in resolve(args[i], ps, body):
                        if kind == 'const':
                            sites.append((tu, fn, val, callee))
                        elif kind == 'computed':
                            computed.append((tu, fn, callee, str(val)[:120]))
        for s in stores:
            for kind, val in resolve(s[2], ps, body):
                if kind == 'const':
                    sites.append((tu, fn, val, '=store'))
                elif kind == 'computed':
                    computed.append((tu, fn, '=store', str(val)[:120]))
    return sites, computed, setters

# ------------------------------------------------------------------ C side


def preprocess(tu, tmpdir):
    out = os.path.join(tmpdir, tu + '.i')
    subprocess.run(['gcc', '-E'] + CFLAGS + [os.path.join('vendor/sm64/src/game', tu + '.c'),
                    '-o', out], cwd=ROOT, check=True)
    return out


def c_ast(tu, tmpdir):
    import pycparser
    return pycparser.CParser().parse(open(preprocess(tu, tmpdir)).read(), tu + '.i')


def _const(n):
    from pycparser import c_ast as A
    while isinstance(n, A.Cast):
        n = n.expr
    if isinstance(n, A.Constant) and n.type in ('int', 'unsigned int', 'long int'):
        return int(n.value.rstrip('uUlL'), 0)
    if isinstance(n, A.UnaryOp) and n.op == '-':
        v = _const(n.expr)
        return None if v is None else -v
    if isinstance(n, A.BinaryOp) and n.op in ('|', '<<', '&'):
        a, b = _const(n.left), _const(n.right)
        if a is None or b is None:
            return None
        return a | b if n.op == '|' else (a << b if n.op == '<<' else a & b)
    return None


# Per-function local aliases (`s32 floorType = m->floor->type;`, `f32 waterSurface =
# m->waterLevel - 100;`): a local assigned exactly once.  Guards are evaluated with
# the alias map of the function they were collected in (CUR[0]).
FN_ALIAS = {}     # fn -> {local: expr}
NODE_FN = {}      # id(guard node) -> fn
CUR = [None]


def _alias(name):
    return FN_ALIAS.get(CUR[0], {}).get(name)


def _field(n):
    from pycparser import c_ast as A
    while isinstance(n, A.Cast):
        n = n.expr
    if isinstance(n, A.StructRef):
        return n.field.name
    if isinstance(n, A.ID):
        a = _alias(n.name)
        if isinstance(a, A.StructRef):
            return a.field.name
        return n.name
    return None


def render(n):
    """C text with constants decoded by the field they are compared with."""
    from pycparser import c_ast as A
    from pycparser.c_generator import CGenerator
    g = CGenerator()

    def r(n):
        if isinstance(n, A.BinaryOp):
            f = _field(n.left) or _field(n.right)
            c = _const(n.right) if _const(n.right) is not None else _const(n.left)
            other = n.left if _const(n.right) is not None else n.right
            fo = _field(other)
            if c is not None and fo is not None:
                if n.op == '&' and fo == 'input':
                    names = [k for k, v in INPUTS.items() if v & c]
                    return '%s & %s' % (g.visit(other), '|'.join(names))
                if n.op == '&' and fo in ('buttonPressed', 'buttonDown'):
                    return '%s & %s' % (g.visit(other), BUTTONS.get(c, hex(c)))
                if n.op in ('==', '!=') and fo in ('action', 'prevAction', 'endAction') and c in ACT_NAME:
                    return '%s %s %s' % (g.visit(other), n.op, ACT_NAME[c])
                if n.op in ('==', '!=') and fo == 'type' and c in SURF_NAME:
                    return '%s %s %s' % (g.visit(other), n.op, SURF_NAME[c])
                if n.op == '&' and fo in ('action', 'prevAction'):
                    return '%s & 0x%X' % (g.visit(other), c)
            return '(%s %s %s)' % (r(n.left), n.op, r(n.right))
        if isinstance(n, A.UnaryOp) and n.op == '!':
            return '!(%s)' % r(n.expr)
        return g.visit(n)
    return r(n)


def requires(n, pol, pred):
    """Does guard expr n, taken with polarity pol, REQUIRE atom pred?"""
    from pycparser import c_ast as A
    while isinstance(n, A.Cast):
        n = n.expr
    if isinstance(n, A.UnaryOp) and n.op == '!':
        return requires(n.expr, not pol, pred)
    if isinstance(n, A.BinaryOp) and n.op == '&&':
        return (requires(n.left, pol, pred) or requires(n.right, pol, pred)) if pol else \
            (requires(n.left, pol, pred) and requires(n.right, pol, pred))
    if isinstance(n, A.BinaryOp) and n.op == '||':
        return (requires(n.left, pol, pred) and requires(n.right, pol, pred)) if pol else \
            (requires(n.left, pol, pred) or requires(n.right, pol, pred))
    if isinstance(n, A.BinaryOp) and n.op in ('!=', '==') and _const(n.right) == 0:
        return requires(n.left, pol if n.op == '!=' else not pol, pred)
    return pol and pred(n)


def bit_atom(field, mask):
    def p(n):
        from pycparser import c_ast as A
        if isinstance(n, A.BinaryOp) and n.op == '&':
            for x, y in ((n.left, n.right), (n.right, n.left)):
                c = _const(y)
                if c is not None and _field(x) == field and c and (c & ~mask) == 0:
                    return True
        return False
    return p


def any_atom(*ps):
    return lambda n: any(p(n) for p in ps)


ATOM_A_PRESSED = any_atom(bit_atom('input', A_PRESS_BIT), bit_atom('buttonPressed', 0x8000))
ATOM_A_DOWN = any_atom(bit_atom('input', A_DOWN_BIT), bit_atom('buttonDown', 0x8000))


def eq_atom(field, values):
    def p(n):
        from pycparser import c_ast as A
        if isinstance(n, A.BinaryOp) and n.op == '==':
            for x, y in ((n.left, n.right), (n.right, n.left)):
                if _field(x) == field and _const(y) in values:
                    return True
        return False
    return p


def cmp_atom(field, ops):
    """`<field-expr> OP ...` or `... OP' <field-expr>` (OP' the mirror of OP)."""
    mirror = {'<': '>', '<=': '>=', '>': '<', '>=': '<='}

    def mentions(n, d=0):
        from pycparser import c_ast as A
        while isinstance(n, A.Cast):
            n = n.expr
        if _field(n) == field:
            return True
        if isinstance(n, A.ID) and _alias(n.name) is not None and d < 3:
            return mentions(_alias(n.name), d + 1)
        return isinstance(n, A.BinaryOp) and n.op in '+-' and (mentions(n.left, d) or mentions(n.right, d))

    def p(n):
        from pycparser import c_ast as A
        if isinstance(n, A.BinaryOp) and n.op in mirror:
            return (n.op in ops and mentions(n.left)) or (mirror[n.op] in ops and mentions(n.right))
        return False
    return p


def nonnull_atom(field):
    def p(n):
        from pycparser import c_ast as A
        if isinstance(n, A.BinaryOp) and n.op == '!=' and _field(n.left) == field:
            return True
        return _field(n) == field and not isinstance(n, A.BinaryOp)
    return p


# ---- WMotR absence filter.  Each entry: (tag, atom, citation).  A site/edge
# whose guard REQUIRES the atom is dropped from R_wmotr / R_reach.
def _surf(*names):
    return eq_atom('type', {SURF[n] for n in names})


ABSENT = [
    ('LEVEL(water)', any_atom(bit_atom('input', INPUTS['INPUT_IN_WATER']),
                              cmp_atom('waterLevel', ('>', '>='))),
     'E1 §6: no water volumes; collision.inc.c has no COL_WATER_BOX (only COL_SPECIAL_INIT '
     '@2057), so gEnvironmentRegions is NULL and find_water_level (surface_collision.c:591) '
     'returns FLOOR_LOWER_LIMIT -11000; Mario never has y < -11100 with a floor'),
    ('LEVEL(poison gas)', bit_atom('input', INPUTS['INPUT_IN_POISON_GAS']),
     'E1 §1: no gas'),
    ('OBJ(grabbable)', bit_atom('input', INPUTS['INPUT_INTERACT_OBJ_GRABBABLE']),
     'behavior census: no grabbable object in WMotR'),
    ('OBJ(stomped)', bit_atom('input', INPUTS['INPUT_STOMPED']),
     'behavior census: nothing sets INT_STATUS_MARIO_STOMPED (no Whomp/Thwomp-like stomper)'),
    ('OBJ(squished)', bit_atom('input', INPUTS['INPUT_SQUISHED']),
     'E3 1b / prior squish census: no reachable <=150 dynamic gap'),
    ('LEVEL(lava/burning floor)', _surf('SURFACE_BURNING'), 'E1 §1: no SURFACE_BURNING'),
    ('LEVEL(quicksand)', _surf('SURFACE_SHALLOW_QUICKSAND', 'SURFACE_DEEP_QUICKSAND',
                               'SURFACE_INSTANT_QUICKSAND', 'SURFACE_DEEP_MOVING_QUICKSAND',
                               'SURFACE_SHALLOW_MOVING_QUICKSAND', 'SURFACE_QUICKSAND',
                               'SURFACE_MOVING_QUICKSAND', 'SURFACE_INSTANT_MOVING_QUICKSAND'),
     'E1 §1: no quicksand surfaces'),
    ('LEVEL(quicksand depth)', cmp_atom('quicksandDepth', ('>', '>=')),
     'quicksandDepth grows only on quicksand floors (mario_step.c:100-140, moving.c:1752) '
     'or in quicksand death (cutscene.c:741); WMotR has none (E1 §1)'),
    ('LEVEL(wind)', _surf('SURFACE_VERTICAL_WIND', 'SURFACE_HORIZONTAL_WIND'),
     'E1 §1,§6: no wind surfaces'),
    ('LEVEL(hangable)', _surf('SURFACE_HANGABLE'), 'E3 §1b/§4f: hangable ceilings at 1536 < spawn'),
    ('OBJ(held)', nonnull_atom('heldObj'), 'no grabbable object -> heldObj stays NULL'),
    ('OBJ(ridden)', nonnull_atom('riddenObj'), 'no Koopa shell in WMotR'),
    ('CAP(metal/vanish)', any_atom(bit_atom('flags', 0x4), bit_atom('flags', 0x2)),
     'E1 §6 / behavior census §1b: the only cap boxes in WMotR are wing-cap boxes '
     '(macro.inc.c:15-20); no metal/vanish cap object (MARIO_METAL_CAP 0x4, VANISH 0x2). '
     'The WING cap is NOT filtered: it may be obtainable (see census doc)'),
]


class Fn:
    def __init__(self, tu, name, params, node):
        self.tu, self.name, self.params, self.node = tu, name, params, node
        self.calls = []    # (callee, args, guards, line)   direct calls
        self.fnargs = []   # (callee, argidx, fname, guards, line)  function passed as an argument
        self.addr = []     # (fname, guards, line)  other address-taken function refs
        self.globrefs = []  # (global var name, guards, line)
        self.indirect = []  # (param index, guards, line)  calls through a function-pointer param
        self.stores = []   # (rhs, guards, line)  direct <MarioState>.action stores
        self.assigns = collections.defaultdict(list)  # local/param name -> [(rhs, guards)]
        self.returns = []  # (expr, guards)


class Globals:
    def __init__(self):
        self.structs = {}  # struct name -> [field names]
        self.inits = {}    # global var name -> (struct name or None, InitList node)


def collect_c(tmpdir):
    from pycparser import c_ast as A
    fns, G = {}, Globals()
    for tu in TUS:
        ast = c_ast(tu, tmpdir)
        for ext in ast.ext:
            if isinstance(ext, A.Decl):
                t = ext.type
                if isinstance(t, A.Struct) and t.decls:
                    G.structs[t.name] = [d.name for d in t.decls]
                if isinstance(ext.init, A.InitList) and ext.coord.file.endswith('/%s.c' % tu):
                    sname = None
                    tt = t
                    while isinstance(tt, (A.ArrayDecl, A.TypeDecl)):
                        tt = tt.type
                    if isinstance(tt, A.Struct):
                        sname = tt.name
                    G.inits[ext.name] = (sname, ext.init)
            if not isinstance(ext, A.FuncDef) or not ext.coord.file.endswith('/%s.c' % tu):
                continue
            name = ext.decl.name
            fd = ext.decl.type
            ps = [getattr(p, 'name', None) for p in fd.args.params] if fd.args else []
            assert name not in fns, ('duplicate function name', name)
            fns[name] = Fn(tu, name, ps, ext)
    names = set(fns)

    for f in fns.values():
        def expr(n, gs):
            if n is None:
                return
            if isinstance(n, A.BinaryOp) and n.op in ('&&', '||'):
                expr(n.left, gs)
                expr(n.right, gs + [(n.left, n.op == '&&')])
                return
            if isinstance(n, A.TernaryOp):
                expr(n.cond, gs)
                expr(n.iftrue, gs + [(n.cond, True)])
                expr(n.iffalse, gs + [(n.cond, False)])
                return
            if isinstance(n, A.FuncCall):
                nm = n.name.name if isinstance(n.name, A.ID) else None
                args = n.args.exprs if n.args else []
                if nm in f.params and nm not in names:
                    f.indirect.append((f.params.index(nm), gs, n.coord.line))
                elif nm is None:
                    expr(n.name, gs)   # e.g. sInteractionHandlers[i].handler(...)
                else:
                    f.calls.append((nm, args, gs, n.coord.line))
                for i, a in enumerate(args):
                    if isinstance(a, A.ID) and a.name in names:
                        f.fnargs.append((nm, i, a.name, gs, n.coord.line))
                    else:
                        expr(a, gs)
                return
            if isinstance(n, A.Assignment) and n.op == '=' and isinstance(n.lvalue, A.StructRef) \
                    and n.lvalue.field.name == 'action' and _field(n.lvalue.name) not in (
                        'marioBodyState', 'statusForCamera'):
                f.stores.append((n.rvalue, gs, n.coord.line))
            if isinstance(n, A.Assignment) and n.op == '=' and isinstance(n.lvalue, A.ID):
                f.assigns[n.lvalue.name].append((n.rvalue, gs))
            if isinstance(n, A.ID):
                if n.name in names:
                    f.addr.append((n.name, gs, n.coord.line))
                elif n.name in G.inits:
                    f.globrefs.append((n.name, gs, n.coord.line))
                return
            for _, c in n.children():
                expr(c, gs)

        def stmt(n, gs, sw=None):
            if n is None:
                return
            if isinstance(n, A.If):
                expr(n.cond, gs)
                stmt(n.iftrue, gs + [(n.cond, True)], sw)
                stmt(n.iffalse, gs + [(n.cond, False)], sw)
            elif isinstance(n, (A.While, A.DoWhile)):
                expr(n.cond, gs)
                stmt(n.stmt, gs + [(n.cond, True)], sw)
            elif isinstance(n, A.For):
                for x in (n.init, n.cond, n.next):
                    if isinstance(x, A.DeclList):
                        stmt(x, gs, sw)
                    else:
                        expr(x, gs)
                stmt(n.stmt, gs + ([(n.cond, True)] if n.cond else []), sw)
            elif isinstance(n, A.Switch):
                expr(n.cond, gs)
                stmt(n.stmt, gs, n.cond)
            elif isinstance(n, A.Compound) and sw is not None and any(
                    isinstance(x, (A.Case, A.Default)) for x in (n.block_items or [])):
                # switch body: a statement's guard is the OR of every case label
                # reachable by fall-through since the last break/return.
                active = []    # label exprs; None = default

                def run(items):
                    for x in items:
                        if isinstance(x, (A.Case, A.Default)):
                            active.append(x.expr if isinstance(x, A.Case) else None)
                            run(x.stmts or [])
                            continue
                        if None in active or not active:
                            g2 = gs
                        else:
                            ors = [A.BinaryOp('==', sw, e) for e in active]
                            c = ors[0]
                            for o in ors[1:]:
                                c = A.BinaryOp('||', c, o)
                            g2 = gs + [(c, True)]
                        stmt(x, g2, None)
                        if isinstance(x, (A.Break, A.Return, A.Goto)):
                            active.clear()
                run(n.block_items or [])
            elif isinstance(n, A.Compound):
                for x in (n.block_items or []):
                    stmt(x, gs, sw)
            elif isinstance(n, (A.Case, A.Default)):
                c = gs + ([(A.BinaryOp('==', sw, n.expr), True)] if isinstance(n, A.Case) and sw else [])
                for s2 in n.stmts or []:
                    stmt(s2, c, sw)
            elif isinstance(n, A.Label):
                stmt(n.stmt, gs, sw)
            elif isinstance(n, A.Decl):
                if n.init is not None:
                    f.assigns[n.name].append((n.init, gs))
                expr(n.init, gs)
            elif isinstance(n, A.DeclList):
                for d in n.decls:
                    if d.init is not None:
                        f.assigns[d.name].append((d.init, gs))
                    expr(d.init, gs)
            elif isinstance(n, A.Return):
                if n.expr is not None:
                    f.returns.append((n.expr, gs))
                expr(n.expr, gs)
            else:
                expr(n, gs)
        stmt(f.node.body, [])
        for lst in ([c[2] for c in f.calls] + [c[3] for c in f.fnargs] + [c[1] for c in f.addr]
                    + [c[1] for c in f.globrefs] + [c[1] for c in f.indirect] + [c[1] for c in f.stores]
                    + [g for rs in f.assigns.values() for _, g in rs] + [g for _, g in f.returns]):
            for n, _ in lst:
                NODE_FN[id(n)] = f.name

    # unambiguous local aliases (`s32 floorType = m->floor->type;`), used by guard atoms
    FN_ALIAS.clear()
    for f in fns.values():
        FN_ALIAS[f.name] = {v: rs[0][0] for v, rs in f.assigns.items()
                            if v not in f.params and len(rs) == 1}
    return fns, G


def _flatten(init):
    from pycparser import c_ast as A
    if isinstance(init, A.InitList):
        for x in init.exprs:
            yield from _flatten(x)
    else:
        yield init


def c_resolve(f, e, gs, fns, G, depth=0):
    """-> list of (kind, value, extra_guards).  kind: const / param / pfield / computed.
    Locals are followed through every assignment (union; extra guards = the
    ASSIGNMENT's guards); calls to linked functions through their returns;
    global array lookups to every element of the array's initializer;
    `p->fld` of a param p to ('pfield', (idx, fld))."""
    from pycparser import c_ast as A
    while isinstance(e, A.Cast):
        e = e.expr
    c = _const(e)
    if c is not None:
        return [('const', c & 0xFFFFFFFF, [])]
    if depth >= 8:
        return [('computed', render(e), [])]
    if isinstance(e, A.TernaryOp):
        return [(k, v, [(e.cond, True)] + g) for k, v, g in c_resolve(f, e.iftrue, gs, fns, G, depth + 1)] + \
               [(k, v, [(e.cond, False)] + g) for k, v, g in c_resolve(f, e.iffalse, gs, fns, G, depth + 1)]
    if isinstance(e, A.ID) and (e.name in f.params or f.assigns.get(e.name)):
        out = [('param', f.params.index(e.name), [])] if e.name in f.params else []
        for rhs, ag in f.assigns.get(e.name, []):
            for k, v, g in c_resolve(f, rhs, ag, fns, G, depth + 1):
                if not (k == 'computed' and e.name in f.params):
                    out.append((k, v, ag + g))
        return out or [('computed', render(e), [])]
    if isinstance(e, A.StructRef) and e.type == '->' and isinstance(e.name, A.ID) and e.name.name in f.params:
        return [('pfield', (f.params.index(e.name.name), e.field.name), [])]
    if isinstance(e, A.FuncCall) and isinstance(e.name, A.ID) and e.name.name in fns:
        g_ = fns[e.name.name]
        out = []
        for rexpr, rg in g_.returns:
            for k, v, g in c_resolve(g_, rexpr, rg, fns, G, depth + 1):
                if k == 'const':
                    out.append((k, v, []))     # callee-internal guards dropped (other frame)
                else:
                    return [('computed', render(e), [])]
        return out or [('computed', render(e), [])]
    if isinstance(e, A.ArrayRef):
        base = e
        while isinstance(base, A.ArrayRef):
            base = base.name
        if isinstance(base, A.ID) and base.name in G.inits:
            vals = [_const(x) for x in _flatten(G.inits[base.name][1])]
            if vals and all(v is not None for v in vals):
                return [('const', v & 0xFFFFFFFF, []) for v in vals]
    return [('computed', render(e), [])]


def _struct_field_value(G, arg, fld):
    """`&gName` + field -> the constant in gName's initializer, else None."""
    from pycparser import c_ast as A
    if isinstance(arg, A.UnaryOp) and arg.op == '&' and isinstance(arg.expr, A.ID) \
            and arg.expr.name in G.inits:
        sname, init = G.inits[arg.expr.name]
        fields = G.structs.get(sname)
        if fields and fld in fields:
            v = _const(init.exprs[fields.index(fld)])
            return None if v is None else (v & 0xFFFFFFFF, arg.expr.name)
    return None


def c_sites(fns, G):
    """Fixpoint over forwarding setters.  -> sites, computed, setters.
    setters: fn -> {key: [internal guard lists]}, key = param index or (param index, field)."""
    setters = {'set_mario_action': {1: [[]]}}
    changed = True

    def add(fn, key, guards):
        d = setters.setdefault(fn, {})
        new = key not in d
        d.setdefault(key, [])
        if len(d[key]) < 64 and all(k != guards for k in d[key]):
            d[key].append(guards)
            return True
        return new
    while changed:
        changed = False
        for f in fns.values():
            if f.name == 'set_mario_action':
                continue
            for callee, args, gs, line in f.calls:
                for key, inner in list(setters.get(callee, {}).items()):
                    i = key if isinstance(key, int) else key[0]
                    if i >= len(args):
                        continue
                    if isinstance(key, tuple):
                        continue   # struct-field forwarding resolved at the caller below
                    for kind, val, eg in c_resolve(f, args[i], gs, fns, G):
                        if kind in ('param', 'pfield'):
                            for ig in inner:
                                changed |= add(f.name, val, gs + eg + ig)
    sites, computed = [], []
    for f in fns.values():
        for callee, args, gs, line in f.calls:
            if f.name == 'set_mario_action':
                continue
            for key, inner in setters.get(callee, {}).items():
                i = key if isinstance(key, int) else key[0]
                if i >= len(args):
                    continue
                if isinstance(key, tuple):
                    sv = _struct_field_value(G, args[i], key[1])
                    if sv is None:
                        computed.append(dict(fn=f.name, tu=f.tu, line=line, via=callee,
                                             expr='%s->%s' % (render(args[i]), key[1])))
                    else:
                        for ig in inner:
                            sites.append(dict(fn=f.name, tu=f.tu, line=line, target=sv[0],
                                              via='%s[%s.%s]' % (callee, sv[1], key[1]),
                                              guards=gs, inner=ig))
                    continue
                for kind, val, eg in c_resolve(f, args[i], gs, fns, G):
                    if kind == 'const':
                        for ig in inner:
                            sites.append(dict(fn=f.name, tu=f.tu, line=line, target=val,
                                              via=callee, guards=gs + eg, inner=ig))
                    elif kind == 'computed':
                        computed.append(dict(fn=f.name, tu=f.tu, line=line, via=callee, expr=val))
        for rhs, gs, line in f.stores:
            for kind, val, eg in c_resolve(f, rhs, gs, fns, G):
                if kind == 'const':
                    sites.append(dict(fn=f.name, tu=f.tu, line=line, target=val, via='=store',
                                      guards=gs + eg, inner=[]))
                elif not (f.name == 'set_mario_action' and kind == 'param'):
                    computed.append(dict(fn=f.name, tu=f.tu, line=line, via='=store', expr=str(val)))
        # indirect calls through a function-pointer param with an action argument
        for pi, igs, line in f.indirect:
            computed.append(dict(fn=f.name, tu=f.tu, line=line, via='(*%s)' % f.params[pi],
                                 expr='indirect call; A-gated=%s' % gate(igs, ATOM_A_PRESSED)))
    return sites, computed, setters


def gate(guards, pred):
    for n, pol in guards:
        CUR[0] = NODE_FN.get(id(n))
        if requires(n, pol, pred):
            return True
    return False


def classify(guards):
    tags = []
    if gate(guards, ATOM_A_PRESSED):
        tags.append('A_PRESSED')
    if gate(guards, ATOM_A_DOWN):
        tags.append('A_DOWN')
    for tag, atom, _ in ABSENT:
        if gate(guards, atom):
            tags.append(tag)
    for nm, bit in (('B', INPUTS['INPUT_B_PRESSED']), ('Z', INPUTS['INPUT_Z_PRESSED']),
                    ('Zdown', INPUTS['INPUT_Z_DOWN']), ('analog', INPUTS['INPUT_NONZERO_ANALOG'])):
        if gate(guards, bit_atom('input', bit)):
            tags.append(nm)
    return tags


def dropped(tags, mode, wmotr):
    if 'A_PRESSED' in tags:
        return True
    if mode == 'noA' and 'A_DOWN' in tags:
        return True
    if wmotr and any(t.split('(')[0] in ('LEVEL', 'OBJ', 'CAP') for t in tags):
        return True
    return False

# ------------------------------------------------------------ call graph





def _interact_values():
    out = {}
    for line in open(os.path.join(ROOT, 'vendor/sm64/src/game/interaction.h')):
        m = re.match(r'#define\s+(INTERACT_\w+)\s+/\*.*\*/\s+\(1 <<\s*(\d+)\)', line)
        if m:
            out[1 << int(m.group(2))] = m.group(1)
    return out


INTERACT_NAME = _interact_values()

# Interaction types an object in WMotR can present (behavior census §1, E1 §6):
WMOTR_INTERACT = {
    'INTERACT_POLE': 'bhvPoleGrabbing x6, behavior_data.c SET_INT(oInteractType, INTERACT_POLE); script.c:19-24',
    'INTERACT_COIN': 'bhvYellowCoin/bhvRedCoin hitboxes (coin.inc.c:4, red_coin.inc.c:12)',
    'INTERACT_BREAKABLE': 'bhvExclamationBox (exclamation_box.inc.c:4), wing-cap boxes macro.inc.c:15-20',
    'INTERACT_CAP': 'bhvWingCap spawned by a broken wing-cap box (cap.inc.c:4)',
    'INTERACT_TEXT': 'bhvBobombBuddyOpensCannon SET_INTERACT_TYPE(INTERACT_TEXT); macro.inc.c:5',
    'INTERACT_CANNON_BASE': 'bhvCannon (spawned once the buddy opens a cannon), SET_INT(oInteractType, INTERACT_CANNON_BASE)',
    'INTERACT_STAR_OR_KEY': 'red-coin star (spawn_star.inc.c:4) -- only after 8/8 red coins, the goal event',
}


def interaction_table(G):
    """sInteractionHandlers -> [(INTERACT_X, handler fn)], parsed from the C initializer."""
    from pycparser import c_ast as A
    out = []
    for row in G.inits['sInteractionHandlers'][1].exprs:
        t, h = row.exprs
        out.append((INTERACT_NAME.get(_const(t), hex(_const(t) or 0)), h.name))
    return out


def callgraph(fns, G, mode, wmotr=True, itable=None):
    """fn -> {callee: tags}, dropping edges whose guard is dropped under mode.
    Function-pointer arguments become edges at the callee's indirect call (with
    the callee's guard).  sInteractionHandlers is expanded with OBJ tags."""
    g = collections.defaultdict(dict)

    def edge(a, b, tags):
        if b in fns and not dropped(tags, mode, wmotr):
            g[a][b] = tags
    for f in fns.values():
        g[f.name]
        for callee, args, gs, line in f.calls:
            edge(f.name, callee, classify(gs))
        for callee, i, fname, gs, line in f.fnargs:
            cf = fns.get(callee)
            uses = [igs for pi, igs, _ in cf.indirect if pi == i] if cf else None
            if uses:
                for igs in uses:
                    edge(f.name, fname, classify(gs + igs))
            else:
                edge(f.name, fname, classify(gs))    # unknown use: conservative
        for fname, gs, line in f.addr:
            edge(f.name, fname, classify(gs))
        for gname, gs, line in f.globrefs:
            if gname == 'sInteractionHandlers':
                for itype, h in itable:
                    if wmotr and itype not in WMOTR_INTERACT:
                        continue
                    edge(f.name, h, classify(gs) + ['IT(%s)' % itype])
            else:
                for x in _flatten(G.inits[gname][1]):
                    if hasattr(x, 'name') and isinstance(x.name, str) and x.name in fns:
                        edge(f.name, x.name, classify(gs))
    return g


def reach(g, roots):
    seen, st = set(), list(roots)
    while st:
        x = st.pop()
        if x in seen or x not in g:
            continue
        seen.add(x)
        st.extend(g[x])
    return seen


def dispatch(fns):
    """action value -> (group dispatcher, handler fn); dispatcher -> prelude callees."""
    from pycparser import c_ast as A
    table, prelude = {}, {}
    for f in fns.values():
        if not (re.match(r'mario_execute_\w+_action$', f.name) or f.name == 'execute_mario_action'):
            continue
        pre = set()
        for callee, args, gs, line in f.calls:
            sw = [n for n, pol in gs if isinstance(n, A.BinaryOp) and n.op in ('==', '||')]

            def labels(n):
                if n.op == '||':
                    return labels(n.left) + labels(n.right)
                return [_const(n.right)] if _field(n.left) == 'action' else []
            sw = [l for n in sw for l in labels(n)]
            if sw and f.name != 'execute_mario_action':
                for v in sw:
                    table.setdefault(v, (f.name, callee))
            elif not callee.startswith('mario_execute_'):
                pre.add(callee)
        prelude[f.name] = pre
    return table, prelude

# ------------------------------------------------------------ adjudication

# Edges the guard decoder cannot see through.  Each: (function, target) -> reason.
# Applied ONLY to R_reach (the WMotR closure); R_ctx/R_wmotr keep them.
MANUAL_CUTS = {
    ('common_air_action_step', 'ACT_START_HANGING'):
        'AIR_STEP_GRABBED_CEILING needs stepArg & AIR_STEP_CHECK_HANG (mario_step.c:451); the only '
        'callers passing it are act_jump (airborne.c:457) and act_hold_jump (:476), both A-only',
    ('set_mario_initial_action', '*'):
        'level_update.c:307-362: runs on warp arrival.  WMotR\'s only arrival node is WARP_NODE_0A '
        '-> bhvAirborneWarp (script.c:51-52) -> MARIO_SPAWN_AIRBORNE (area.c:64,72) -> '
        'ACT_SPAWN_NO_SPIN_AIRBORNE (:324); every other spawn type is another level\'s entry',
    ('init_level', '*'):
        'level_update.c:1182-1188: demo / intro / fresh-file paths; entering WMotR is a warp '
        '(sWarpDest.type != WARP_TYPE_NOT_WARPING -> init_mario_after_warp)',
    ('warp_credits', '*'): 'level_update.c:516: ending credits only',
    ('initiate_painting_warp', '*'):
        'level_update.c:679: needs gCurrentArea->paintingWarpNodes; WMotR has no paintings',
    ('interact_star_or_key', '*'):
        'the red-coin star exists only after 8/8 red coins, i.e. after GOAL 2 has already been '
        'lost (E1 §4); kept OUT of R_reach deliberately, listed separately',
}

MANUAL_CUTS[('lava_boost_on_wall', '*')] = (
    'every caller is `case AIR_STEP_HIT_LAVA_WALL` (checked by this tool), which perform_air_step '
    'returns only for m->wall->type == SURFACE_BURNING (mario_step.c:490-491); WMotR has no '
    'SURFACE_BURNING (E1 §1)')

# set_mario_action rewrites its argument before storing it (mario.c:980-995):
# set_mario_action_moving (mario.c:917-931) and set_mario_action_airborne (mario.c:766-769).
# Checked mechanically in main() against the C assignments to `action` in those two functions.
REMAP = {
    'ACT_BEGIN_SLIDING': ['ACT_BUTT_SLIDE', 'ACT_STOMACH_SLIDE'],
    'ACT_HOLD_BEGIN_SLIDING': ['ACT_HOLD_BUTT_SLIDE', 'ACT_HOLD_STOMACH_SLIDE'],
    'ACT_DOUBLE_JUMP': ['ACT_DOUBLE_JUMP', 'ACT_JUMP'],     # squishTimer != 0 || quicksandDepth >= 1
    'ACT_TWIRLING': ['ACT_TWIRLING', 'ACT_JUMP'],
}

# Functions called from OUTSIDE the twelve TUs by WMotR objects (behavior census §2).
EXTERNAL_ROOTS = {
    'set_mario_npc_dialog': 'bhvBobombBuddyOpensCannon: bobomb.inc.c:377 (obj_behaviors.c, unlinked)',
}
ENTRY = 'ACT_SPAWN_NO_SPIN_AIRBORNE'


def closure(sites, fns, G, mode, itable):
    g = callgraph(fns, G, mode, wmotr=True, itable=itable)
    table, prelude = dispatch(fns)
    by_fn = collections.defaultdict(list)
    for s in sites:
        by_fn[s['fn']].append(s)

    def cut(s):
        for key in ((s['fn'], aname(s['target'])), (s['fn'], '*')):
            if key in MANUAL_CUTS:
                return MANUAL_CUTS[key]
        return None

    def edges_from(fnset):
        out = []
        for fn in fnset:
            for s in by_fn.get(fn, []):
                if dropped(s['tags'], mode, wmotr=True) or cut(s):
                    continue
                for t in REMAP.get(aname(s['target']), [aname(s['target'])]):
                    out.append(dict(s, target=ACTS[t], via=s['via'] + ('' if t == aname(s['target'])
                                                                      else ' (remapped from %s)' % aname(s['target']))))
        return out

    glob_fns = reach(g, prelude['execute_mario_action'] | set(EXTERNAL_ROOTS))
    entry = ACTS[ENTRY]
    R, why, frontier = {entry}, {entry: 'entry: level_update.c:324 (MARIO_SPAWN_AIRBORNE)'}, [entry]
    for s in edges_from(glob_fns):
        if s['target'] not in R:
            R.add(s['target'])
            why[s['target']] = 'frame-global %s %s:%d via %s [%s]' % (
                s['fn'], s['tu'], s['line'], s['via'], ','.join(s['tags']) or 'free')
            frontier.append(s['target'])
    runs = {}
    while frontier:
        x = frontier.pop()
        if x not in table:
            why[x] = why.get(x, '') + '  (NO HANDLER in dispatch)'
            continue
        disp, h = table[x]
        fnset = reach(g, prelude.get(disp, set()) | {h})
        runs[x] = fnset
        for s in edges_from(fnset):
            if s['target'] not in R:
                R.add(s['target'])
                why[s['target']] = '%s -> %s %s:%d via %s [%s]' % (
                    aname(x), s['fn'], s['tu'], s['line'], s['via'], ','.join(s['tags']) or 'free')
                frontier.append(s['target'])
    return R, why, glob_fns, table, prelude, runs

# ------------------------------------------------------------------- main


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--sites', action='store_true', help='print the full site table (TSV)')
    ap.add_argument('--json', help='write everything as JSON')
    a = ap.parse_args()

    csites, ccomp, csetters = clight_sites()
    with tempfile.TemporaryDirectory() as td:
        fns, G = collect_c(td)
    sites, computed, setters = c_sites(fns, G)
    itable = interaction_table(G)

    # cross-check: per function, the SET of constant targets must agree.
    cl, cc = collections.defaultdict(set), collections.defaultdict(set)
    for tu, fn, v, via in csites:
        cl[fn].add(v)
    for s in sites:
        cc[s['fn']].add(s['target'])
    mism = [(fn, sorted(map(aname, cl[fn] - cc[fn])), sorted(map(aname, cc[fn] - cl[fn])))
            for fn in sorted(set(cl) | set(cc)) if cl[fn] != cc[fn]]

    # REMAP check: the constants assigned to `action` inside set_mario_action_{moving,airborne}
    got = sorted(aname(_const(r)) for fn in ('set_mario_action_moving', 'set_mario_action_airborne')
                 for r, _ in fns[fn].assigns.get('action', []) if _const(r) is not None)
    want = sorted(t for k, v in REMAP.items() for t in v if t != k)
    remap_ok = set(got) == set(want)
    # lava wall check: every call to lava_boost_on_wall sits under `== AIR_STEP_HIT_LAVA_WALL`
    lava = [(f.name, line, any(isinstance(n, type(gs[0][0])) and getattr(n, 'op', '') == '=='
                               and _const(n.right) == 6 for n, pol in gs if pol) if gs else False)
            for f in fns.values() for c, args, gs, line in f.calls if c == 'lava_boost_on_wall']
    lava_ok = all(x[2] for x in lava)
    # Clight check of the LandingAction tables the C side resolved through struct fields
    land_ok = []
    txt = open(os.path.join(ROOT, 'generated/mario_actions_moving.v')).read()
    for gname, (sname, init) in G.inits.items():
        if sname == 'LandingAction':
            m = re.search(r'Definition v_%s := \{\|.*?gvar_init := \((.*?)nil\);' % gname, txt, re.S)
            cl_vals = [int(x) & 0xFFFFFFFF for x in re.findall(r'Init_int\d+ \(Int\.repr \(?(-?\d+)', m.group(1))]
            c_vals = [(_const(x) or 0) & 0xFFFFFFFF for x in init.exprs]
            land_ok.append((gname, cl_vals == c_vals))

    for s in sites:
        s['tags'] = classify(s['guards'] + s['inner'])
        if s['fn'].startswith('interact_'):
            it = [t for t, h in itable if h == s['fn']]
            s['tags'].append('IT(%s)' % '|'.join(it or [s['fn']]))

    r_ctx = {s['target'] for s in sites if not dropped(s['tags'], 'noA', wmotr=False)}
    r_wm = set()
    for s in sites:
        if dropped(s['tags'], 'noA', wmotr=True):
            continue
        obj = [t for t in s['tags'] if t.startswith('IT(')]
        if obj and not any(x in WMOTR_INTERACT for t in obj for x in t[3:-1].split('|')):
            continue
        r_wm.add(s['target'])
    R, why, glob_fns, table, prelude, runs = closure(sites, fns, G, 'noA', itable)
    R2, why2, *_ = closure(sites, fns, G, 'noApress', itable)

    print('Clight const sites: %d   C const sites (guard paths): %d   distinct targets: %d' % (
        len(csites), len(sites), len({s['target'] for s in sites})))
    print('setters (fixpoint):', ', '.join('%s%s' % (k, sorted(map(str, v))) for k, v in sorted(setters.items())))
    ccomp_fns = {c[1] for c in ccomp} | {'act_%s_land' % x for x in ()}
    # Clight leaves `landingAction->f` (common_landing_cancels) and knockback helpers computed;
    # the C side resolves them.  Soundness of the cross-check: nothing may be Clight-only, and
    # every C-only extra must sit in a function whose Clight call passes a struct pointer to
    # common_landing_cancels or has a Clight-computed action argument.
    landing_callers = {s['fn'] for s in sites if s['via'].startswith('common_landing_cancels[')}
    bad = [m for m in mism if m[1] or not (m[0] in ccomp_fns or m[0] in landing_callers)]
    print('cross-check (per function const-target sets, C vs Clight): %d differ, all C-side '
          'resolutions of Clight-computed args: %s' % (len(mism), not bad))
    for m in mism:
        print('   ', m)
    print('REMAP matches set_mario_action_{moving,airborne} assignments: %s %s' % (remap_ok, got))
    print('every lava_boost_on_wall call is under case AIR_STEP_HIT_LAVA_WALL (6): %s (%d calls)' % (lava_ok, len(lava)))
    print('LandingAction tables, C initializer == Clight gvar_init: %s' % land_ok)
    print('computed targets (C side, after resolution):')
    for c in computed:
        print('    %s.c:%d %s via %s: %s' % (c['tu'], c['line'], c['fn'], c['via'], c['expr']))
    print('computed targets (Clight side, unresolved): %d' % len(ccomp))
    print('interaction table: %s' % ', '.join('%s->%s' % (t[9:], h) for t, h in itable))
    for nm, S in (('R_ctx', r_ctx), ('R_wmotr', r_wm), ('R_reach', R)):
        air = [v for v in S if v & ACT_FLAG_AIR]
        print('\n%s: %d actions (%d with ACT_FLAG_AIR)' % (nm, len(S), len(air)))
        for v in sorted(S, key=aname):
            print('    %-34s 0x%08X %s %s' % (aname(v), v, 'AIR' if v & ACT_FLAG_AIR else '   ',
                                            why.get(v, '') if nm == 'R_reach' else ''))
    print('\nR_ctx - R_reach, AIR only: %s' % ', '.join(sorted(aname(v) for v in r_ctx - R if v & ACT_FLAG_AIR)))
    print('R_reach if A_DOWN were allowed (mode noApress) adds: %s' % (
        ', '.join('%s [%s]' % (aname(v), why2[v]) for v in sorted(R2 - R, key=aname)) or 'nothing'))
    if a.sites:
        print('\n#SITES\tfile:line\tfunction\tvia\ttarget\thex\ttags\tguards')
        for s in sorted(sites, key=lambda s: (s['tu'], s['line'], aname(s['target']))):
            gtxt = ' && '.join(('' if pol else '!') + '(' + render(n) + ')' for n, pol in s['guards'] + s['inner'])
            print('%s.c:%d\t%s\t%s\t%s\t0x%08X\t%s\t%s' % (s['tu'], s['line'], s['fn'], s['via'],
                                                         aname(s['target']), s['target'],
                                                         ','.join(s['tags']) or 'free', gtxt))
    if a.json:
        out = dict(mismatches=mism, computed=computed, interaction_table=itable,
                   R_ctx=sorted(map(aname, r_ctx)), R_wmotr=sorted(map(aname, r_wm)),
                   R_reach=sorted(map(aname, R)), why={aname(k): v for k, v in why.items()},
                   R_reach_noApress_extra=sorted(map(aname, R2 - R)),
                   runs={aname(k): sorted(v) for k, v in runs.items()},
                   frame_global_fns=sorted(glob_fns),
                   sites=[dict(file='%s.c:%d' % (s['tu'], s['line']), fn=s['fn'], via=s['via'],
                               target=aname(s['target']), hex='0x%08X' % s['target'], tags=s['tags'],
                               guards=[('' if pol else '!') + render(n) for n, pol in s['guards'] + s['inner']])
                          for s in sites])
        json.dump(out, open(a.json, 'w'), indent=1)


if __name__ == '__main__':
    main()
