"""A path-splitting symbolic executor for CompCert Clight (as parsed by clight_parse).

EXPLORATORY / UNVERIFIED.  Nothing here is proved; it is a prototype used to
learn the shape of the GOAL-2 per-handler summaries before building a
Coq-verified executor.  Known unsoundnesses are listed in README.md and are
reported per path as warnings where they fire.

Values (tuples):
  ('I', x)          32-bit int     x: int in [0,2^32) or T(kind i32)
  ('L', x)          64-bit int
  ('S', x)          binary32       x: numpy.float32 or T(kind f32)
  ('F', x)          binary64       x: float or T(kind f64)
  ('P', reg, ofs)   pointer        reg: region name, ofs: int or T(i32)
  ('U', why)        undefined
NULL is ('I', 0), as in CompCert on a 32-bit target.

Memory: region name -> {byte offset: (chunk, value)}.  Regions are described
in Explorer.regions (type, access-path prefix, lazily-symbolic or not,
nullable or not).  A read of an unwritten cell of a lazily-symbolic region
returns a fresh variable named by its access path and is logged as a
"world read".
"""
import collections

import numpy as np

from clight_parse import Id, Program, load_tu
from clight_types import (Layout, tkind, INT_TYPES, LONG_TYPES, chunk_of, CHUNK_SIZE)
from terms import (T, var, mk, is_concrete, canon, Undef, f32_of_bits, f64_of_bits,
                   bits_of_f32, signed, show_val, M32, M64, INT_CMP as INT_CMP_OPS,
                   FLT_CMP as FLT_CMP_OPS)

TINT = 'tint'
import os
DEBUG = int(os.environ.get('SYMEXEC_DEBUG', '0'))


class Stuck(Exception):
    pass


class Trunc(Exception):
    pass


# ---------------------------------------------------------------------------
# Persistent log (cons list): O(1) clone on fork
# ---------------------------------------------------------------------------

def log_push(log, item):
    return (item, log)


def log_list(log):
    out = []
    while log is not None:
        out.append(log[0])
        log = log[1]
    out.reverse()
    return out


class Region:
    __slots__ = ('name', 'ty', 'path', 'lazy', 'nullable', 'kind')

    def __init__(self, name, ty, path, lazy, nullable, kind):
        self.name = name
        self.ty = ty          # C type of the object (struct/array/scalar) or None
        self.path = path      # printable prefix for cells, e.g. 'm->floor'
        self.lazy = lazy      # unwritten cells are fresh symbols (world data)
        self.nullable = nullable
        self.kind = kind      # 'mario' | 'obj' | 'global' | 'local' | 'world' | 'ext' | 'fun'


class State:
    """One execution path."""
    __slots__ = ('mem', 'owned', 'temps', 'locals', 'facts', 'pc', 'calls', 'reads',
                 'warns', 'ctr', 'depth', 'fname', 'steps', 'subst', 'bounds', 'ns')

    def __init__(self):
        self.mem = {}
        self.owned = set()
        self.temps = {}
        self.locals = {}
        self.facts = {}
        self.pc = None
        self.calls = None
        self.reads = None
        self.warns = None
        self.ctr = {}
        self.depth = 0
        self.fname = None
        self.steps = 0
        self.subst = {}
        self.bounds = {}      # term key -> (lo, hi) learned from path facts
        self.ns = ''          # fresh-name namespace ('' main run, 'sN_' summary N)

    def clone(self):
        s = State.__new__(State)
        s.mem = dict(self.mem)
        s.owned = set()
        self.owned = set()
        s.temps = dict(self.temps)
        s.locals = self.locals
        s.facts = dict(self.facts)
        s.pc = self.pc
        s.calls = self.calls
        s.reads = self.reads
        s.warns = self.warns
        s.ctr = dict(self.ctr)
        s.depth = self.depth
        s.fname = self.fname
        s.steps = self.steps
        s.subst = dict(self.subst)
        s.bounds = dict(self.bounds)
        s.ns = self.ns
        return s

    def region_w(self, reg):
        d = self.mem.get(reg)
        if reg not in self.owned:
            d = dict(d) if d is not None else {}
            self.mem[reg] = d
            self.owned.add(reg)
        return d

    def fresh(self, base):
        n = self.ctr.get(base, 0) + 1
        self.ctr[base] = n
        return '%s#%s%d' % (base, self.ns, n)

    def warn(self, msg):
        self.warns = log_push(self.warns, msg)


N = ('normal',)
BRK = ('break',)
CNT = ('continue',)


def typeof(e):
    return e[-1]


def _ival(v):
    if v[0] == 'I':
        return v[1]
    raise Stuck('expected int, got %r' % (v,))


class Explorer:
    def __init__(self, program=None, helper_tus=(('math_util', ('vec3f_copy', 'vec3f_set',
                 'vec3s_to_vec3f', 'vec3f_to_vec3s', 'vec3s_copy', 'vec3s_set', 'vec3f_add',
                 'vec3s_add', 'vec3f_sum', 'vec3s_sum', 'vec3s_sub')),),
                 max_depth=40, loop_fuel=64, max_paths=200000, max_steps=200000,
                 contracts=None, const_globals_from_init=True, opaque=(), merge=(),
                 merge_key=None, join_loops=False):
        self.prog = program or Program()
        self.functions = dict(self.prog.functions)
        self.helpers = []
        for tuname, names in helper_tus:
            tu = load_tu(tuname)
            for n in names:
                if n in tu.functions and n not in self.functions:
                    self.functions[n] = tu.functions[n]
                    self.helpers.append('%s.%s' % (tuname, n))
        comps = dict(self.prog.composites)
        self.layout = Layout(comps)
        self.max_depth = max_depth
        self.loop_fuel = loop_fuel
        self.max_paths = max_paths
        self.max_steps = max_steps
        self.contracts = contracts or {}
        self.opaque = set(opaque)
        self.merge_funcs = set(merge)
        self.join_loops = join_loops
        self.mrg_ctr = 0
        self.domains = {}               # var name -> allowed concrete values (world invariant)
        self.domain_fn = None           # fn(region, name, chunk) -> set | None
        self.merge_key = merge_key      # fn(explorer, state) -> hashable projection kept exact
        self.merges = collections.Counter()
        self.regions = {}
        self.forks = 0
        self.truncations = []
        self.written_globals = self._scan_written_globals() if const_globals_from_init else None
        self.const_globals_used = set()
        # --- interval reasoning
        self.var_range = {}             # var name -> (lo, hi) assumed (e.g. Φ's InRange)
        self.atoms = {}                 # fact key -> atom term (for summary substitution)
        # --- per-function summaries
        self.var_origin = {}            # lazily created world var -> (region, ofs, chunk, ty)
        self.region_origin = {}         # lazily created world region -> (region, ofs, ptr ty)
        self.path_region = {}           # region access path -> region name
        self.summarize = None           # fn(fname) -> bool
        self.summary_cache = {}
        self.summary_active = set()
        self.summary_stats = collections.Counter()
        self.summary_inlined = collections.Counter()
        self.summary_skeleton = []      # [(reg, ofs, chunk, value)] root cells (pointers, W)
        self.summary_skel_facts = []    # [(fact key, polarity, reg, ofs of the pointer cell)]
        self.summary_presets = []       # [(reg, ofs, chunk)] copied into the key when concrete
        self.summary_masked = []        # [(reg, ofs, chunk)] keyed by the caller's possibly-set bits
        self.summary_ctr = 0
        self.track_regions = set()      # regions whose every access is logged (TRACK:/TRACKW:)
        self.summary_pc = bool(os.environ.get('SYMEXEC_SUMMARY_PC'))
        self.join_vals = {}             # join var name -> joined int value terms
        self._mb_memo = {}
        self.cut_cycles = True
        self.cycle_cuts = collections.Counter()
        self.cycle_keys = collections.Counter()
        self.bits = {}                  # join var name -> mask of bits that may be 1

    # ------------------------------------------------------------------ regions
    def region(self, name, ty, path, lazy, nullable, kind):
        r = self.regions.get(name)
        if r is None:
            r = Region(name, ty, path, lazy, nullable, kind)
            self.regions[name] = r
            self.path_region.setdefault(path, name)
        return r

    def global_region(self, st, gname):
        name = 'G:' + gname
        if name in self.regions:
            return name
        gv = self.prog.gvars.get(gname)
        if gv is None:
            # declared but not defined here, or unknown: world data
            self.region(name, None, gname, True, False, 'global')
            return name
        ty = gv['gvar_info']
        init = gv.get('gvar_init') or []
        readonly = gv.get('gvar_readonly') == 'true'
        const = bool(init) and not all(i[0] == 'Init_space' for i in init if isinstance(i, tuple)) and (
            readonly or (self.written_globals is not None and gname not in self.written_globals))
        if const:
            self.region(name, ty, gname, False, False, 'global')
            self.const_globals_used.add(gname)
            self._init_global(name, init)
        else:
            self.region(name, ty, gname, True, False, 'global')
        return name

    def _init_global(self, name, init):
        cells = {}
        ofs = 0
        for it in init:
            h = it[0]
            if h == 'Init_int8':
                cells[ofs] = ('i8u', ('I', it[1][1] & 0xff)); ofs += 1
            elif h == 'Init_int16':
                cells[ofs] = ('i16u', ('I', it[1][1] & 0xffff)); ofs += 2
            elif h == 'Init_int32':
                cells[ofs] = ('i32', ('I', it[1][1] & M32)); ofs += 4
            elif h == 'Init_int64':
                cells[ofs] = ('i64', ('L', it[1][1] & M64)); ofs += 8
            elif h == 'Init_float32':
                cells[ofs] = ('f32', ('S', f32_of_bits(it[1][1][1]))); ofs += 4
            elif h == 'Init_float64':
                cells[ofs] = ('f64', ('F', f64_of_bits(it[1][1][1]))); ofs += 8
            elif h == 'Init_space':
                n = it[1]
                for k in range(n):
                    cells[ofs + k] = ('i8u', ('I', 0))
                ofs += n
            elif h == 'Init_addrof':
                target = str(it[1])
                o = it[2][1]
                if target in self.functions or target in self.prog.externals:
                    cells[ofs] = ('i32', ('P', 'fun:' + target, 0))
                else:
                    cells[ofs] = ('i32', ('P', ('G:' + target, target), o))
                ofs += 4
            else:
                raise ValueError('init %r' % (it,))
        self._pending_init = getattr(self, '_pending_init', {})
        self._pending_init[name] = cells

    def ensure_region_mem(self, st, reg):
        if reg not in st.mem:
            pi = getattr(self, '_pending_init', {})
            if reg in pi:
                cells = {}
                for o, (c, v) in pi[reg].items():
                    if v[0] == 'P' and isinstance(v[1], tuple):
                        v = ('P', self.global_region(st, v[1][1]), v[2])
                    cells[o] = (c, v)
                st.mem[reg] = cells

    def _scan_written_globals(self):
        """Globals that may be modified (or whose address escapes) anywhere in the
        loaded functions.  Conservative: over-approximates 'written'."""
        written = set()

        def ex(e, ctx, via_path):
            if not isinstance(e, tuple):
                return
            h = e[0]
            if h == 'Evar':
                ty = e[2]
                if isinstance(ty, tuple) and ty[0] == 'Tfunction':
                    return
                if ctx == 'write':
                    written.add(str(e[1]))
                elif not via_path and isinstance(ty, tuple) and ty[0] in ('tarray', 'Tstruct', 'Tunion'):
                    written.add(str(e[1]))   # decays to a pointer that escapes
            elif h == 'Eaddrof':
                ex(e[1], 'write', True)
            elif h in ('Ederef', 'Efield'):
                ex(e[1], ctx, True)
            elif h == 'Ebinop':
                ex(e[2], ctx, via_path)
                ex(e[3], ctx, via_path)
            elif h in ('Eunop',):
                ex(e[2], ctx, via_path)
            elif h == 'Ecast':
                ex(e[1], ctx, via_path)

        def st(s):
            if not isinstance(s, tuple):
                return
            h = s[0]
            if h == 'Ssequence':
                st(s[1]); st(s[2])
            elif h == 'Sassign':
                ex(s[1], 'write', False)
                ex(s[2], 'read', False)
            elif h == 'Sset':
                ex(s[2], 'read', False)
            elif h == 'Scall':
                for a in s[3]:
                    ex(a, 'write', False)
            elif h == 'Sifthenelse':
                ex(s[1], 'read', False); st(s[2]); st(s[3])
            elif h == 'Sloop':
                st(s[1]); st(s[2])
            elif h == 'Swhile':
                ex(s[1], 'read', False); st(s[2])
            elif h == 'Sreturn':
                if isinstance(s[1], tuple) and s[1][0] == 'Some':
                    ex(s[1][1], 'read', False)
            elif h == 'Sswitch':
                ex(s[1], 'read', False)
                ls = s[2]
                while isinstance(ls, tuple) and ls[0] == 'LScons':
                    st(ls[2])
                    ls = ls[3]
        for f in self.functions.values():
            st(f['fn_body'])
        return written

    # ------------------------------------------------------------------ memory
    def load(self, st, chunk, ty, reg, ofs):
        if reg is None:
            raise Stuck('load through NULL')
        r = self.regions[reg]
        self._check_nonnull(st, reg)
        if r.kind == 'fun':
            raise Stuck('load from function pointer')
        self.ensure_region_mem(st, reg)
        size = CHUNK_SIZE[chunk]
        if not is_concrete(ofs):
            # symbolic index.  World tables: an uninterpreted load term.
            # Pointer arrays held in locals (e.g. collisionData.walls[n-1]):
            # a fresh nullable pointer standing for "one of the elements".
            if r.lazy:
                st.reads = log_push(st.reads, '%s[?]:%s' % (r.path, chunk))
            if ty is not None and tkind(ty) == 'ptr' and chunk == 'i32':
                if not r.lazy:
                    st.warn('symbolic-index pointer read of %s approximated by a fresh pointer' % r.path)
                name = st.fresh('%s[?]' % r.path)
                return self._wrap(chunk, None, ty, st, name)
            k = self._kind(chunk)
            t = T('load', (r.path, ofs, chunk), k)
            return self._wrap(chunk, t, ty, st, None)
        ofs = signed(ofs) if ofs >= 1 << 31 else ofs
        if reg in self.track_regions:
            st.reads = log_push(st.reads, 'TRACK:%s%s' % (r.path, self._path(r, ofs, chunk)))
        cells = st.mem.get(reg, {})
        hit = cells.get(ofs)
        if hit is not None and CHUNK_SIZE[hit[0]] == size:
            hv = hit[1]
            if r.lazy and ty is not None and tkind(ty) == 'ptr' and chunk == 'i32' and hv[0] == 'I' \
                    and isinstance(hv[1], T) and hv[1].op == 'var' \
                    and hv[1].args[0] == '%s%s' % (r.path, self._path(r, ofs, 'i32')):
                # a lazily created world cell first read through an int view of a
                # union (e.g. rawData.asU32) and now as a pointer: it is a pointer
                v = self._wrap(chunk, hv[1], ty, st, hv[1].args[0])
                self.region_origin.setdefault(v[1], (reg, ofs, ty))
                st.region_w(reg)[ofs] = (chunk, v)
                return v
            return self._convert(chunk, hit[0], hv, st)
        # overlapping cells?
        overl = [(o, c, v) for o, (c, v) in cells.items() if o < ofs + size and ofs < o + CHUNK_SIZE[c]]
        if overl:
            b = self._bytes(ofs, size, overl)
            if b is not None:
                return self._from_bytes(chunk, b)
            if not r.lazy:
                st.warn('mixed-size symbolic read %s+%d' % (r.path, ofs))
            else:
                st.warn('mixed-size symbolic read %s+%d (fresh)' % (r.path, ofs))
            name = st.fresh('%s%s' % (r.path, self._path(r, ofs, chunk)))
            return self._wrap(chunk, var(name, self._kind(chunk)), ty, st, name)
        if not r.lazy:
            if r.kind == 'local':
                return ('U', 'uninitialised local %s+%d' % (r.path, ofs))
            if r.kind == 'global':
                # const global beyond its initialiser (should not happen)
                return ('U', 'outside init %s+%d' % (r.path, ofs))
        # fresh world value, named by access path
        name = '%s%s' % (r.path, self._path(r, ofs, chunk))
        st.reads = log_push(st.reads, name)
        if self.domain_fn is not None and name not in self.domains:
            d = self.domain_fn(r, name, chunk)
            if d is not None:
                self.domains[name] = frozenset(d)
        v = self._wrap(chunk, var(name, self._kind(chunk)), ty, st, name)
        if v[0] == 'P':
            self.region_origin.setdefault(v[1], (reg, ofs, ty))
        else:
            self.var_origin.setdefault(name, (reg, ofs, chunk, ty))
        dom = self.domains.get(name)
        if dom is not None and len(dom) == 1 and v[0] == 'I':
            v = ('I', next(iter(dom)))     # world invariant pins the value
        st.region_w(reg)[ofs] = (chunk, v)
        return self._convert(chunk, chunk, v, st)

    def _path(self, r, ofs, chunk):
        if r.ty is None:
            return '+%d' % ofs if ofs else ''
        p = self.layout.path_of(r.ty, ofs, chunk)
        if r.path.endswith(']') or r.kind in ('global',):
            return p
        return p.replace('.', '->', 1) if p.startswith('.') else p

    @staticmethod
    def _kind(chunk):
        return {'f32': 'f32', 'f64': 'f64', 'i64': 'i64'}.get(chunk, 'i32')

    def _wrap(self, chunk, t, ty, st, name):
        """Package a fresh symbol as a value of static type ty."""
        if ty is not None and tkind(ty) == 'ptr' and chunk == 'i32':
            pty = ty[1]
            rname = 'R:' + name
            if rname not in self.regions:
                self.region(rname, pty if tkind(pty) in ('struct', 'union') or True else None,
                            name, True, True, 'world')
            return ('P', rname, 0)
        if chunk == 'f32':
            return ('S', t)
        if chunk == 'f64':
            return ('F', t)
        if chunk == 'i64':
            return ('L', t)
        # small ints: the symbol denotes the (extended) loaded value
        return ('I', t)

    def _convert(self, chunk, schunk, v, st):
        """Value of a load with `chunk` from a cell stored with `schunk` (same size)."""
        if v[0] == 'U':
            return v
        if chunk in ('i8s', 'i8u', 'i16s', 'i16u'):
            if v[0] != 'I':
                raise Stuck('small load of non-int')
            op = {'i8s': 'sext8', 'i8u': 'zext8', 'i16s': 'sext16', 'i16u': 'zext16'}[chunk]
            x = v[1]
            if isinstance(x, T) and x.op == 'var' and schunk == chunk:
                return v
            return ('I', mk(op, 'i32', x))
        if chunk == 'i32':
            if v[0] in ('I', 'P'):
                return v
            if v[0] == 'S':
                return ('I', mk('f2bits', 'i32', v[1]))
        if chunk == 'f32':
            if v[0] == 'S':
                return v
            if v[0] == 'I':
                return ('S', mk('bits2f', 'f32', v[1]))
        if chunk == 'f64' and v[0] == 'F':
            return v
        if chunk == 'i64' and v[0] == 'L':
            return v
        raise Stuck('load %s of %s value %r' % (chunk, schunk, v))

    def _bytes(self, ofs, size, overl):
        """Big-endian bytes [ofs, ofs+size) from concrete overlapping cells, or None."""
        out = [None] * size
        for o, c, v in overl:
            n = CHUNK_SIZE[c]
            if v[0] == 'I' and is_concrete(v[1]):
                bits = v[1] & ((1 << (8 * n)) - 1)
            elif v[0] == 'S' and is_concrete(v[1]):
                bits = bits_of_f32(v[1])
            else:
                return None
            for k in range(n):
                pos = o + k - ofs
                if 0 <= pos < size:
                    out[pos] = (bits >> (8 * (n - 1 - k))) & 0xff
        if any(b is None for b in out):
            return None
        return out

    def _from_bytes(self, chunk, b):
        x = 0
        for byte in b:
            x = (x << 8) | byte
        if chunk == 'f32':
            return ('S', f32_of_bits(x))
        if chunk == 'f64':
            return ('F', f64_of_bits(x))
        if chunk == 'i64':
            return ('L', x)
        return self._convert(chunk, chunk, ('I', x), None)

    def store(self, st, chunk, reg, ofs, v):
        if reg is None:
            raise Stuck('store through NULL')
        r = self.regions[reg]
        self._check_nonnull(st, reg)
        self.ensure_region_mem(st, reg)
        if not is_concrete(ofs):
            st.warn('IGNORED store at symbolic offset %s[%s]' % (r.path, show_val(ofs)))
            return
        ofs = signed(ofs) if ofs >= 1 << 31 else ofs
        if reg in self.track_regions:
            st.reads = log_push(st.reads, 'TRACKW:%s%s' % (r.path, self._path(r, ofs, chunk)))
        size = CHUNK_SIZE[chunk]
        cells = st.region_w(reg)
        for o in [o for o, (c, _) in cells.items() if o < ofs + size and ofs < o + CHUNK_SIZE[c]]:
            c, old = cells[o]
            if o == ofs and CHUNK_SIZE[c] == size:
                continue
            # partial overlap: split concrete cells into bytes, else drop
            del cells[o]
            if old[0] == 'I' and is_concrete(old[1]) and c.startswith('i'):
                n = CHUNK_SIZE[c]
                for k in range(n):
                    if not (ofs <= o + k < ofs + size):
                        cells[o + k] = ('i8u', ('I', (old[1] >> (8 * (n - 1 - k))) & 0xff))
            elif not (ofs <= o and o + CHUNK_SIZE[c] <= ofs + size):
                st.warn('partial overwrite of symbolic cell %s+%d' % (r.path, o))
        if chunk in ('i8s', 'i8u', 'i16s', 'i16u') and v[0] == 'I':
            pass  # stored as-is; loads re-extend
        cells[ofs] = (chunk, v)

    def _check_nonnull(self, st, reg):
        r = self.regions[reg]
        if r.nullable:
            key = 'nonnull(%s)' % r.path
            f = st.facts.get(key)
            if f is False:
                raise Stuck('dereference of NULL %s' % r.path)
            if f is None:
                st.facts[key] = True   # a NULL deref would be stuck: keep the live path

    # ------------------------------------------------------------------ casts
    def bool_term(self, st, v, ty):
        """Truth of v (C scalar) as a concrete bool or an i32 term (nonzero = true)."""
        k = v[0]
        if k == 'I':
            x = v[1]
            return (x != 0) if is_concrete(x) else x
        if k == 'L':
            x = v[1]
            return (x != 0) if is_concrete(x) else mk('ne', 'i64', x, 0)
        if k == 'S':
            x = v[1]
            return mk('fne', 'f32', x, np.float32(0)) if not is_concrete(x) else bool(x != 0)
        if k == 'F':
            x = v[1]
            return mk('fne', 'f64', x, 0.0) if not is_concrete(x) else bool(x != 0)
        if k == 'P':
            r = self.regions[v[1]]
            if not r.nullable:
                return True
            key = 'nonnull(%s)' % r.path
            f = st.facts.get(key)
            if f is not None:
                return f
            return var(key, 'i32')
        raise Stuck('bool of %r' % (v,))

    def cast(self, v, tf, tt, st):
        kf, kt = tkind(tf), tkind(tt)
        if v[0] == 'U':
            return v
        if kt == 'void':
            return v
        if kt in ('struct', 'union'):
            return v
        if tt == 'tbool':
            b = self.bool_term(st, v, tf)
            if isinstance(b, bool):
                return ('I', int(b))
            return ('I', mk('ne', 'i32', b, 0) if b.op not in ('eq', 'ne', 'lts', 'ltu', 'feq', 'fne', 'flt', 'fle', 'fgt', 'fge') else b)
        if kt == 'int' or kt == 'ptr':
            size, sg = INT_TYPES[tt] if kt == 'int' else (4, False)
            if v[0] == 'P':
                if size != 4:
                    raise Stuck('narrowing cast of pointer')
                return v
            if v[0] == 'I':
                x = v[1]
            elif v[0] == 'L':
                x = mk('l2i', 'i64', v[1])
            elif v[0] == 'S':
                x = self._conv(('f2s' if (sg or size < 4) else 'f2u'), v[1])
            elif v[0] == 'F':
                x = self._conv(('d2s' if (sg or size < 4) else 'd2u'), v[1])
            else:
                raise Stuck('cast %r' % (v,))
            if size == 1:
                x = mk('sext8' if sg else 'zext8', 'i32', x)
            elif size == 2:
                x = mk('sext16' if sg else 'zext16', 'i32', x)
            return ('I', x)
        if kt == 'long':
            sg = LONG_TYPES[tt]
            if v[0] == 'L':
                return v
            if v[0] == 'I':
                s = INT_TYPES.get(tf, (4, False))[1] if kf == 'int' else False
                return ('L', mk('i2l_s' if s else 'i2l_u', 'i32', v[1]))
            if v[0] == 'F':
                return ('L', self._conv('d2l_s', v[1]))
            raise Stuck('cast to long of %r' % (v,))
        if kt == 'single':
            if v[0] == 'S':
                return v
            if v[0] == 'F':
                return ('S', mk('d2f', 'f64', v[1]))
            if v[0] == 'I':
                s = INT_TYPES.get(tf, (4, True))[1] if kf == 'int' else True
                return ('S', mk('s2f' if s else 'u2f', 'i32', v[1]))
            if v[0] == 'L':
                return ('S', mk('l2f_s', 'i64', v[1]))
        if kt == 'float':
            if v[0] == 'F':
                return v
            if v[0] == 'S':
                return ('F', mk('f2d', 'f32', v[1]))
            if v[0] == 'I':
                s = INT_TYPES.get(tf, (4, True))[1] if kf == 'int' else True
                return ('F', mk('s2d' if s else 'u2d', 'i32', v[1]))
            if v[0] == 'L':
                return ('F', mk('l2d_s', 'i64', v[1]))
        raise Stuck('unsupported cast %r -> %r of %r' % (tf, tt, v))

    def _conv(self, op, x):
        try:
            return mk(op, 'x', x)
        except Undef as e:
            raise Stuck(str(e))

    # ------------------------------------------------------------------ operators
    def binarith_type(self, t1, t2):
        k1, k2 = tkind(t1), tkind(t2)
        if 'float' in (k1, k2):
            return 'tdouble'
        if 'single' in (k1, k2):
            return 'tfloat'
        if 'long' in (k1, k2):
            if 'tulong' in (t1, t2):
                return 'tulong'
            return 'tlong'
        if 'tuint' in (t1, t2):
            return 'tuint'
        return 'tint'

    def binop(self, st, op, v1, t1, v2, t2):
        k1, k2 = tkind(t1), tkind(t2)
        try:
            return self._binop(st, op, v1, t1, v2, t2, k1, k2)
        except Undef as e:
            raise Stuck(str(e))

    def _binop(self, st, op, v1, t1, v2, t2, k1, k2):
        if v1[0] == 'U' or v2[0] == 'U':
            raise Stuck('operation on undefined value (%s)' % (v1[1] if v1[0] == 'U' else v2[1]))
        cmp_ops = {'Oeq': 'eq', 'One': 'ne', 'Olt': 'lt', 'Ogt': 'gt', 'Ole': 'le', 'Oge': 'ge'}
        # pointer arithmetic
        if op == 'Oadd' and k1 == 'ptr' and k2 in ('int', 'long'):
            return self._ptr_add(v1, t1, v2, t2, 1)
        if op == 'Oadd' and k2 == 'ptr' and k1 in ('int', 'long'):
            return self._ptr_add(v2, t2, v1, t1, 1)
        if op == 'Osub' and k1 == 'ptr' and k2 in ('int', 'long'):
            return self._ptr_add(v1, t1, v2, t2, -1)
        if op == 'Osub' and k1 == 'ptr' and k2 == 'ptr':
            if v1[0] == 'P' and v2[0] == 'P' and v1[1] == v2[1]:
                sz = self.layout.sizeof(t1[1])
                d = mk('sub', 'i32', v1[2], v2[2])
                return ('I', mk('divs', 'i32', d, sz) if sz != 1 else d)
            raise Stuck('pointer difference across regions')
        if op in cmp_ops and (k1 == 'ptr' or k2 == 'ptr' or v1[0] == 'P' or v2[0] == 'P'):
            return self._ptr_cmp(st, cmp_ops[op], v1, v2)
        if op in ('Oshl', 'Oshr'):
            # classify_shift: result type is the promoted left operand type
            if k1 == 'long':
                a = v1[1]
                b = self.cast(v2, t2, 'tuint', st)[1]
                if op == 'Oshl':
                    return ('L', mk('shl', 'i64', a, b))
                return ('L', mk('shru' if t1 == 'tulong' else 'shrs', 'i64', a, b))
            lt = 'tuint' if t1 == 'tuint' else 'tint'
            a = self.cast(v1, t1, lt, st)[1]
            b = self.cast(v2, t2, 'tuint' if t2 in ('tuint', 'tulong') else 'tint', st)[1]
            if op == 'Oshl':
                return ('I', mk('shl', 'i32', a, b))
            return ('I', mk('shru' if lt == 'tuint' else 'shrs', 'i32', a, b))
        ct = self.binarith_type(t1, t2)
        a = self.cast(v1, t1, ct, st)
        b = self.cast(v2, t2, ct, st)
        ck = tkind(ct)
        if ck == 'int' and (a[0] == 'P' or b[0] == 'P'):
            # ptr32: Val.add/Val.sub on a pointer and an int stay pointers
            if op == 'Oadd' and a[0] == 'P' and b[0] == 'I':
                return ('P', a[1], self._mask(mk('add', 'i32', a[2], b[1])))
            if op == 'Oadd' and b[0] == 'P' and a[0] == 'I':
                return ('P', b[1], self._mask(mk('add', 'i32', b[2], a[1])))
            if op == 'Osub' and a[0] == 'P' and b[0] == 'I':
                return ('P', a[1], self._mask(mk('sub', 'i32', a[2], b[1])))
            if op == 'Osub' and a[0] == 'P' and b[0] == 'P' and a[1] == b[1]:
                return ('I', mk('sub', 'i32', a[2], b[2]))
            if op in cmp_ops:
                return self._ptr_cmp(st, cmp_ops[op], a, b)
            raise Stuck('integer op %s on a pointer value' % op)
        if ck in ('int', 'long'):
            w = 'i64' if ck == 'long' else 'i32'
            uns = ct in ('tuint', 'tulong')
            base = {'Oadd': 'add', 'Osub': 'sub', 'Omul': 'mul', 'Oand': 'and', 'Oor': 'or',
                    'Oxor': 'xor'}.get(op)
            tag = 'I' if w == 'i32' else 'L'
            if base:
                return (tag, mk(base, w, a[1], b[1]))
            if op == 'Odiv':
                return (tag, mk('divu' if uns else 'divs', w, a[1], b[1]))
            if op == 'Omod':
                return (tag, mk('modu' if uns else 'mods', w, a[1], b[1]))
            if op in cmp_ops:
                c = cmp_ops[op]
                if c not in ('eq', 'ne'):
                    c += 'u' if uns else 's'
                return ('I', mk(c, w, a[1], b[1]))
        else:
            kind = 'f32' if ck == 'single' else 'f64'
            base = {'Oadd': 'fadd', 'Osub': 'fsub', 'Omul': 'fmul', 'Odiv': 'fdiv'}.get(op)
            tag = 'S' if kind == 'f32' else 'F'
            if base:
                return (tag, mk(base, kind, a[1], b[1]))
            if op in cmp_ops:
                return ('I', mk('f' + cmp_ops[op], kind, a[1], b[1]))
        raise Stuck('unsupported binop %s on %s,%s' % (op, t1, t2))

    @staticmethod
    def _mask(x):
        return x & M32 if is_concrete(x) else x

    def _ptr_add(self, p, tp, n, tn, sign):
        if p[0] == 'I' and is_concrete(p[1]) and p[1] == 0:
            raise Stuck('arithmetic on NULL')
        if p[0] != 'P':
            raise Stuck('pointer arithmetic on non-pointer %r' % (p,))
        if n[0] not in ('I', 'L'):
            raise Stuck('pointer arithmetic with non-integer offset %r' % (n,))
        if n[0] == 'L':
            nv = mk('l2i', 'i64', n[1])
        else:
            nv = n[1]
        sz = self.layout.sizeof(tp[1])
        d = mk('mul', 'i32', nv, sz)
        if sign < 0:
            d = mk('neg', 'i32', d)
        ofs = mk('add', 'i32', p[2], d)
        if is_concrete(ofs):
            ofs &= M32
        return ('P', p[1], ofs)

    def _ptr_cmp(self, st, c, v1, v2):
        def isnull(v):
            return v[0] == 'I' and is_concrete(v[1]) and v[1] == 0
        if v1[0] == 'P' and v2[0] == 'P':
            if v1[1] == v2[1]:
                cc = c if c in ('eq', 'ne') else c + 'u'
                return ('I', mk(cc, 'i32', v1[2], v2[2]))
            r1, r2 = self.regions[v1[1]], self.regions[v2[1]]
            if c not in ('eq', 'ne'):
                raise Stuck('ordered comparison across regions')
            # two distinct regions: equal only if both are unknown world pointers
            if r1.kind in ('world', 'ext') and r2.kind in ('world', 'ext') or \
               (r1.kind in ('world', 'ext') and r2.kind in ('obj', 'global')) or \
               (r2.kind in ('world', 'ext') and r1.kind in ('obj', 'global')):
                t = var('alias(%s,%s)' % tuple(sorted([r1.path, r2.path])), 'i32')
                return ('I', t if c == 'eq' else mk('eq', 'i32', t, 0))
            return ('I', int(c == 'ne'))
        if (v1[0] == 'P' and isnull(v2)) or (v2[0] == 'P' and isnull(v1)):
            p = v1 if v1[0] == 'P' else v2
            if c not in ('eq', 'ne'):
                raise Stuck('ordered comparison with NULL')
            nn = self.bool_term(st, p, None)   # truth = non-null
            if isinstance(nn, bool):
                return ('I', int(nn if c == 'ne' else not nn))
            return ('I', nn if c == 'ne' else mk('eq', 'i32', nn, 0))
        if v1[0] == 'I' and v2[0] == 'I':
            cc = c if c in ('eq', 'ne') else c + 'u'
            return ('I', mk(cc, 'i32', v1[1], v2[1]))
        raise Stuck('pointer comparison %r %s %r' % (v1, c, v2))

    def unop(self, st, op, v, t):
        if v[0] == 'U':
            raise Stuck('unop on undefined (%s)' % v[1])
        k = tkind(t)
        if op == 'Onotbool':
            b = self.bool_term(st, v, t)
            if isinstance(b, bool):
                return ('I', int(not b))
            return ('I', mk('notbool', 'i32', b))
        if op == 'Oneg':
            if k == 'int':
                ct = 'tuint' if t == 'tuint' else 'tint'
                return ('I', mk('neg', 'i32', self.cast(v, t, ct, st)[1]))
            if k == 'single':
                return ('S', mk('fneg', 'f32', v[1]))
            if k == 'float':
                return ('F', mk('fneg', 'f64', v[1]))
            if k == 'long':
                return ('L', mk('neg', 'i64', v[1]))
        if op == 'Onotint':
            if k == 'int':
                ct = 'tuint' if t == 'tuint' else 'tint'
                return ('I', mk('not', 'i32', self.cast(v, t, ct, st)[1]))
        if op == 'Oabsfloat':
            fv = self.cast(v, t, 'tdouble', st)
            return ('F', mk('fabs', 'f64', fv[1]))
        raise Stuck('unsupported unop %s on %s' % (op, t))

    # ------------------------------------------------------------------ expressions
    def eval(self, e, st):
        h = e[0]
        if h == 'Econst_int':
            return ('I', e[1][1] & M32)
        if h == 'Econst_single':
            return ('S', f32_of_bits(e[1][1][1]))
        if h == 'Econst_float':
            return ('F', f64_of_bits(e[1][1][1]))
        if h == 'Econst_long':
            return ('L', e[1][1] & M64)
        if h == 'Etempvar':
            v = st.temps.get(e[1])
            if v is None:
                return ('U', 'unset temp %s' % e[1])
            return v
        if h == 'Eaddrof':
            reg, ofs = self.lvalue(e[1], st)
            return ('P', reg, ofs)
        if h == 'Eunop':
            return self.unop(st, e[1], self.eval(e[2], st), typeof(e[2]))
        if h == 'Ebinop':
            return self.binop(st, e[1], self.eval(e[2], st), typeof(e[2]),
                              self.eval(e[3], st), typeof(e[3]))
        if h == 'Ecast':
            return self.cast(self.eval(e[1], st), typeof(e[1]), e[2], st)
        if h in ('Esizeof', 'Ealignof'):
            f = self.layout.sizeof if h == 'Esizeof' else self.layout.alignof
            return ('I', f(e[1]))
        if h in ('Evar', 'Ederef', 'Efield'):
            ty = typeof(e)
            reg, ofs = self.lvalue(e, st)
            k = tkind(ty)
            if k in ('ptr',) and ty[0] == 'tarray' or k in ('struct', 'union', 'fun'):
                return ('P', reg, ofs)
            chunk = chunk_of(ty)
            return self.load(st, chunk, ty, reg, ofs)
        raise Stuck('unsupported expression %s' % h)

    def lvalue(self, e, st):
        h = e[0]
        if h == 'Evar':
            name = e[1]
            if name in st.locals:
                return st.locals[name], 0
            ty = e[2]
            if isinstance(ty, tuple) and ty[0] == 'Tfunction':
                rn = 'fun:' + name
                self.region(rn, None, name, False, False, 'fun')
                return rn, 0
            return self.global_region(st, str(name)), 0
        if h == 'Ederef':
            v = self.eval(e[1], st)
            if v[0] == 'P':
                return v[1], v[2]
            if v[0] == 'I' and is_concrete(v[1]) and v[1] == 0:
                raise Stuck('dereference of NULL')
            raise Stuck('dereference of non-pointer %r' % (v,))
        if h == 'Efield':
            reg, ofs = self.lvalue(e[1], st)
            sty = typeof(e[1])
            f = self.layout.field(sty[1], e[2])
            if f[3] is not None:
                raise Stuck('bitfield access unsupported')
            return reg, mk('add', 'i32', ofs, f[1]) if not is_concrete(ofs) else (ofs + f[1]) & M32
        raise Stuck('not an lvalue: %s' % h)

    # ------------------------------------------------------------------ decisions
    def decide(self, st, b, label):
        """Split on truth of b (bool or i32 term).  Returns [(bool, state)]."""
        if isinstance(b, bool):
            return [(b, st)]
        if is_concrete(b):
            return [(b != 0, st)]
        atom, pol = canon(b)
        if is_concrete(atom):
            return [((atom != 0) == pol, st)]
        key = atom.key()
        if key.startswith('nonnull('):
            key = key  # same key space as _check_nonnull
        f = st.facts.get(key)
        if f is not None:
            return [(f == pol, st)]
        r = self.range_decide(st, atom)
        if r is not None:
            return [(r == pol, st)]
        self.forks += 1
        if self.forks > self.max_paths:
            raise Trunc('path cap %d reached' % self.max_paths)
        st2 = st.clone()
        out = []
        for val, s in ((True, st), (False, st2)):
            fact = (val == pol)   # truth of atom on this branch
            s.facts[key] = fact
            self.atoms.setdefault(key, atom)
            self.learn(s, atom, fact)
            s.pc = log_push(s.pc, ('' if val else '!') + (label or '') + '[' + b.key() + ']' if label else (('' if val else 'NOT ') + b.key()))
            if fact and atom.op == 'eq' and isinstance(atom.args[0], T) and atom.args[0].op == 'var' \
                    and is_concrete(atom.args[1]):
                self.substitute(s, atom.args[0], atom.args[1])
            out.append((val, s))
        return out

    def range_decide(self, st, atom):
        """Decide an atom without forking: `var == c` from a world-invariant
        domain of var; comparisons from intervals (Φ ranges, small-int chunk
        ranges, domains, bounds learned on this path).  Floats are assumed
        non-NaN here."""
        if atom.op == 'eq' and isinstance(atom.args[0], T) and atom.args[0].op == 'var' \
                and is_concrete(atom.args[1]):
            dom = self.domains.get(atom.args[0].args[0])
            if dom is not None:
                c = atom.args[1]
                if c not in dom:
                    return False
                if dom == {c}:
                    return True
        op = atom.op
        if op in ('flt', 'fle', 'feq', 'lts', 'ltu', 'eq'):
            x, y = atom.args
            if op in ('lts', 'ltu', 'eq') and any(isinstance(z, T) and z.kind == 'i64' for z in (x, y)):
                return None
            ix = self.interval(st, x)
            if ix is None:
                return None
            iy = self.interval(st, y)
            if iy is None:
                return None
            if op == 'ltu' and (ix[0] < 0 or iy[0] < 0):
                return None
            if op in ('flt', 'lts', 'ltu'):
                if ix[1] < iy[0]:
                    return True
                if ix[0] >= iy[1]:
                    return False
            elif op == 'fle':
                if ix[1] <= iy[0]:
                    return True
                if ix[0] > iy[1]:
                    return False
            else:
                if ix[1] < iy[0] or iy[1] < ix[0]:
                    return False
                if op == 'eq' and ix[0] == ix[1] == iy[0] == iy[1]:
                    return True
            return None
        if op == 'eq' and is_concrete(atom.args[1]) and isinstance(atom.args[1], int) \
                and atom.args[1] & ~self.maybe_bits(atom.args[0]) & M32:
            return False
        if atom.kind == 'i32' and op not in ('feq', 'fne', 'flt', 'fle', 'fgt', 'fge'):
            if op not in INT_CMP_OPS and self.maybe_bits(atom) == 0:
                return False
            ix = self.interval(st, atom)
            if ix is not None:
                if ix[0] > 0 or ix[1] < 0:
                    return True
                if ix[0] == ix[1] == 0:
                    return False
        return None

    # ------------------------------------------------------------------ intervals
    _SMALL = {'sext8': (-128, 127), 'zext8': (0, 255), 'sext16': (-32768, 32767), 'zext16': (0, 65535)}
    _CHUNK_RANGE = {'i8s': (-128, 127), 'i8u': (0, 255), 'i16s': (-32768, 32767), 'i16u': (0, 65535)}

    def interval(self, st, t, memo=None):
        """A sound-ish enclosing interval of term t (None = unknown).  i32
        terms are read as signed; floats are widened by one part in 2^21 per op."""
        if not isinstance(t, T):
            if isinstance(t, bool):
                return (int(t), int(t))
            if isinstance(t, int):
                return (signed(t), signed(t))
            x = float(t)
            if x != x:
                return None
            return (x, x)
        if t.kind == 'i64':
            return None
        if memo is None:
            memo = {}
        k = t.key()
        if k in memo:
            return memo[k]
        memo[k] = None
        r = self._interval(st, t, memo)
        if r is not None and (r[0] != r[0] or r[1] != r[1]):
            r = None
        b = st.bounds.get(k) if st is not None else None
        if b is not None:
            r = b if r is None else (max(r[0], b[0]), min(r[1], b[1]))
        memo[k] = r
        return r

    @staticmethod
    def _meet(a, b):
        if a is None:
            return b
        if b is None:
            return a
        return (max(a[0], b[0]), min(a[1], b[1]))

    @staticmethod
    def _widen(r):
        if r is None:
            return None
        e0 = abs(r[0]) * 2.0 ** -21 + 1e-30
        e1 = abs(r[1]) * 2.0 ** -21 + 1e-30
        return (r[0] - e0, r[1] + e1)

    def _interval(self, st, t, memo):
        op, a = t.op, t.args
        iv = lambda x: self.interval(st, x, memo)
        if op == 'var':
            name = a[0]
            r = self.var_range.get(name)
            o = self.var_origin.get(name)
            if o is not None and o[2] in self._CHUNK_RANGE:
                r = self._meet(r, self._CHUNK_RANGE[o[2]])
            dom = self.domains.get(name)
            if dom:
                vals = [signed(x) if isinstance(x, int) else float(x) for x in dom]
                r = self._meet(r, (min(vals), max(vals)))
            return r
        if op in self._SMALL:
            base = self._SMALL[op]
            x = iv(a[0])
            if x is not None and base[0] <= x[0] and x[1] <= base[1]:
                return x
            return base
        if op in ('s2f', 's2d', 'f2d', 'd2f'):
            return self._widen(iv(a[0]))
        if op in ('u2f', 'u2d'):
            x = iv(a[0])
            return self._widen(x) if x is not None and x[0] >= 0 else None
        if op in ('f2s', 'd2s'):
            x = iv(a[0])
            if x is None or not (-2.0 ** 31 < x[0] and x[1] < 2.0 ** 31):
                return None
            import math
            return (math.trunc(x[0]), math.trunc(x[1]))
        if op in ('add', 'fadd', 'sub', 'fsub', 'mul', 'fmul'):
            x, y = iv(a[0]), iv(a[1])
            if x is None or y is None:
                return None
            if op in ('add', 'fadd'):
                r = (x[0] + y[0], x[1] + y[1])
            elif op in ('sub', 'fsub'):
                r = (x[0] - y[1], x[1] - y[0])
            else:
                ps = [x[0] * y[0], x[0] * y[1], x[1] * y[0], x[1] * y[1]]
                r = (min(ps), max(ps))
            if op[0] == 'f':
                return self._widen(r)
            if r[0] < -2 ** 31 or r[1] > 2 ** 31 - 1:
                return None
            return r
        if op in ('fdiv', 'divs'):
            x, y = iv(a[0]), iv(a[1])
            if x is None or y is None or y[0] <= 0 <= y[1]:
                return None
            ps = [x[0] / y[0], x[0] / y[1], x[1] / y[0], x[1] / y[1]]
            r = (min(ps), max(ps))
            if op == 'divs':
                import math
                if not (math.isfinite(r[0]) and math.isfinite(r[1])):
                    return None
                return (math.trunc(r[0]), math.trunc(r[1]))
            return self._widen(r)
        if op in ('neg', 'fneg'):
            x = iv(a[0])
            return None if x is None else (-x[1], -x[0])
        if op == 'fabs':
            x = iv(a[0])
            if x is None:
                return None
            if x[0] >= 0:
                return x
            if x[1] <= 0:
                return (-x[1], -x[0])
            return (0.0, max(-x[0], x[1]))
        if op == 'and' and is_concrete(a[1]) and a[1] < 2 ** 31:
            return (0, a[1])
        if op in ('eq', 'ne', 'lts', 'ltu', 'les', 'leu', 'gts', 'gtu', 'ges', 'geu', 'notbool',
                  'feq', 'fne', 'flt', 'fle', 'fgt', 'fge'):
            return (0, 1)
        return None

    def maybe_bits(self, t):
        """Bits of an i32 term that may be 1 (known-zero-bits analysis)."""
        if not isinstance(t, T):
            return t & M32 if isinstance(t, int) else M32
        if t.kind != 'i32':
            return M32
        k = t.key()
        hit = self._mb_memo.get(k)
        if hit is None:
            hit = self._maybe_bits(t)
            self._mb_memo[k] = hit
        return hit

    def _maybe_bits(self, t):
        op, a = t.op, t.args
        if op == 'var':
            name = a[0]
            b = self.bits.get(name)
            if b is not None:
                return b
            dom = self.domains.get(name)
            if dom and all(isinstance(x, int) for x in dom):
                m = 0
                for x in dom:
                    m |= x
                return m & M32
            o = self.var_origin.get(name)
            if o is not None and o[2] in ('i16u', 'i8u'):
                return 0xFFFF if o[2] == 'i16u' else 0xFF
            return M32
        if op == 'zext16':
            return self.maybe_bits(a[0]) & 0xFFFF
        if op == 'zext8':
            return self.maybe_bits(a[0]) & 0xFF
        if op in ('or', 'xor'):
            return self.maybe_bits(a[0]) | self.maybe_bits(a[1])
        if op == 'and':
            return self.maybe_bits(a[0]) & self.maybe_bits(a[1])
        if op == 'shl' and is_concrete(a[1]) and a[1] < 32:
            return (self.maybe_bits(a[0]) << a[1]) & M32
        if op == 'shru' and is_concrete(a[1]) and a[1] < 32:
            return self.maybe_bits(a[0]) >> a[1]
        if op in INT_CMP_OPS or op in FLT_CMP_OPS or op == 'notbool':
            return 1
        return M32

    def learn(self, st, atom, truth):
        """Record interval bounds implied by `atom == truth` (comparisons with a constant)."""
        op = atom.op
        if op not in ('flt', 'fle', 'lts', 'eq', 'feq'):
            return
        x, y = atom.args
        if op in ('lts', 'eq') and any(isinstance(z, T) and z.kind == 'i64' for z in (x, y)):
            return

        def val(c):
            return signed(c) if isinstance(c, int) else float(c)

        def bound(t, lo, hi):
            k = t.key()
            old = st.bounds.get(k)
            st.bounds[k] = (lo, hi) if old is None else (max(old[0], lo), min(old[1], hi))
        inf = float('inf')
        one = 1 if op == 'lts' else 0
        if op in ('eq', 'feq'):
            if truth:
                if isinstance(x, T) and is_concrete(y):
                    bound(x, val(y), val(y))
                elif isinstance(y, T) and is_concrete(x):
                    bound(y, val(x), val(x))
            return
        strict_true = op in ('flt', 'lts')
        if isinstance(x, T) and is_concrete(y):
            c = val(y)
            if truth:        # x < c  (or x <= c)
                bound(x, -inf, c - one if strict_true else c)
            else:            # x >= c (or x > c)
                bound(x, c + (0 if strict_true else (1 if op == 'lts' else 0)), inf)
        elif isinstance(y, T) and is_concrete(x):
            c = val(x)
            if truth:        # c < y
                bound(y, c + one if strict_true else c, inf)
            else:            # y <= c
                bound(y, -inf, c)
        elif isinstance(x, T) and isinstance(y, T):
            # relational: transfer the other side's interval (non-strict)
            ix, iy = self.interval(st, x), self.interval(st, y)
            if truth:        # x < y (x <= y)
                if iy is not None:
                    bound(x, -inf, iy[1])
                if ix is not None:
                    bound(y, ix[0], inf)
            else:            # x >= y (x > y)
                if iy is not None:
                    bound(x, iy[0], inf)
                if ix is not None:
                    bound(y, -inf, ix[1])

    def substitute(self, st, v, c):
        """After learning var v == c, replace plain occurrences of v by c."""
        st.subst[v.key()] = c
        for k, val in list(st.temps.items()):
            if val[0] == 'I' and isinstance(val[1], T) and val[1] == v:
                st.temps[k] = ('I', c)
        for reg, cells in list(st.mem.items()):
            hits = [o for o, (ch, val) in cells.items()
                    if val[0] == 'I' and isinstance(val[1], T) and val[1] == v]
            if hits:
                w = st.region_w(reg)
                for o in hits:
                    w[o] = (w[o][0], ('I', c))

    # ------------------------------------------------------------------ statements
    def exec(self, s, st):
        """Execute statement s in state st.  Returns [(outcome, state)]."""
        if isinstance(s, str):
            if s == 'Sskip':
                return [(N, st)]
            if s == 'Sbreak':
                return [(BRK, st)]
            if s == 'Scontinue':
                return [(CNT, st)]
            raise Stuck('unknown statement %s' % s)
        h = s[0]
        st.steps += 1
        if st.steps > self.max_steps:
            return [(('trunc', 'step fuel'), st)]
        try:
            if h == 'Ssequence':
                out = []
                for o, s1 in self.exec(s[1], st):
                    if o is N:
                        out.extend(self.exec(s[2], s1))
                    else:
                        out.append((o, s1))
                return out
            if h == 'Sset':
                st.temps[s[1]] = self.eval(s[2], st)
                return [(N, st)]
            if h == 'Sassign':
                return self.exec_assign(s, st)
            if h == 'Scall':
                return self.exec_call(s, st)
            if h == 'Sifthenelse':
                b = self.bool_term(st, self.eval(s[1], st), typeof(s[1]))
                out = []
                for val, s1 in self.decide(st, b, None):
                    out.extend(self.exec(s[2] if val else s[3], s1))
                return out
            if h == 'Sloop':
                return self.exec_loop(s[1], s[2], st)
            if h == 'Swhile':
                body = ('Ssequence', ('Sifthenelse', s[1], 'Sskip', 'Sbreak'), s[2])
                return self.exec_loop(body, 'Sskip', st)
            if h == 'Sreturn':
                if s[1] == 'None':
                    return [(('return', None), st)]
                e = s[1][1]
                return [(('return', (self.eval(e, st), typeof(e))), st)]
            if h == 'Sswitch':
                return self.exec_switch(s, st)
            raise Stuck('unsupported statement %s' % h)
        except Stuck as e:
            return [(('stuck', '%s: %s' % (st.fname, e)), st)]
        except Trunc as e:
            self.truncations.append(str(e))
            return [(('trunc', str(e)), st)]

    def exec_assign(self, s, st):
        lhs, rhs = s[1], s[2]
        reg, ofs = self.lvalue(lhs, st)
        v = self.eval(rhs, st)
        tl = typeof(lhs)
        k = tkind(tl)
        if k in ('struct', 'union'):
            if v[0] != 'P':
                raise Stuck('struct copy from non-pointer')
            self.copy_block(st, reg, ofs, v[1], v[2], self.layout.sizeof(tl), tl)
            return [(N, st)]
        v = self.cast(v, typeof(rhs), tl, st)
        if v[0] == 'U':
            st.warn('store of undefined value (%s)' % v[1])
        self.store(st, chunk_of(tl), reg, ofs, v)
        return [(N, st)]

    def copy_block(self, st, dreg, dofs, sreg, sofs, size, ty):
        if not (is_concrete(dofs) and is_concrete(sofs)):
            raise Stuck('block copy at symbolic offset')
        # copy scalar leaves by walking the type
        for o, lt in self._leaves(ty, 0):
            ch = chunk_of(lt)
            self.store(st, ch, dreg, dofs + o, self.load(st, ch, lt, sreg, sofs + o))

    def _leaves(self, ty, base):
        k = tkind(ty)
        if k in ('struct', 'union'):
            info = self.layout.comp(ty[1])
            fields = info['fields'] if info['su'] == 'Struct' else info['fields'][:1]
            for f in fields:
                if f[3] is not None:
                    raise Stuck('bitfield copy')
                yield from self._leaves(f[2], base + f[1])
        elif isinstance(ty, tuple) and ty[0] == 'tarray':
            es = self.layout.sizeof(ty[1])
            for i in range(ty[2]):
                yield from self._leaves(ty[1], base + i * es)
        else:
            yield base, ty

    def exec_loop(self, s1, s2, st):
        """Sloop s1 s2, iteration by iteration (breadth-first).  With
        join_loops, the states reaching the loop head (and the normal exits)
        are joined when they agree on merge_key and on every temp."""
        out = []
        cur = [st]
        k = 0
        seen = set()
        while cur:
            if k > self.loop_fuel:
                self.truncations.append('loop fuel in %s' % cur[0].fname)
                out.extend((('trunc', 'loop fuel'), c) for c in cur)
                break
            nxt = []
            for c in cur:
                c.ctr['iter@' + str(c.fname)] = max(c.ctr.get('iter@' + str(c.fname), 0), k + 1)
                for o, a in self.exec(s1, c):
                    if o is N or o is CNT:
                        for o2, b in self.exec(s2, a):
                            if o2 is N:
                                nxt.append(b)
                            elif o2 is BRK:
                                out.append((N, b))
                            elif o2 is CNT:
                                out.append((('stuck', 'continue in loop step'), b))
                            else:
                                out.append((o2, b))
                    elif o is BRK:
                        out.append((N, a))
                    else:
                        out.append((o, a))
            if self.join_loops and len(nxt) > 1:
                n0 = len(nxt)
                nxt = self.join_states('loop@%s#%d' % (st.fname, k + 1), nxt)
            if self.join_loops and self.cut_cycles and nxt:
                # a loop-head state whose key (temps + Φ + key cells) was already
                # seen at an earlier iteration only repeats explored behaviour
                # (up to the cells outside the key): cut it and count it
                keep = []
                for c in nxt:
                    lk = self.loop_key(c)
                    if lk in seen:
                        self.cycle_cuts[st.fname] += 1
                        if self.merge_key is not None:
                            self.cycle_keys[(st.fname, lk[-1][2] if len(lk[-1]) > 2 else '')] += 1
                    else:
                        seen.add(lk)
                        keep.append(c)
                nxt = keep
                if DEBUG:
                    import sys
                    sys.stderr.write('loop %s iter %d: %d -> %d states\n' % (st.fname, k + 1, n0, len(nxt)))
                    if DEBUG > 1:
                        for x in nxt[:6]:
                            sys.stderr.write('   temps=%s key=%s\n' % (
                                {str(t): self.show_value(v) for t, v in x.temps.items() if v[0] != 'U'},
                                self.merge_key(self, x) if self.merge_key else None))
            cur = nxt
            k += 1
        if self.join_loops:
            normal = [b for o, b in out if o is N]
            if len(normal) > 1:
                out = [(o, b) for o, b in out if o is not N] + \
                      [(N, b) for b in self.join_states('loop-exit@%s' % st.fname, normal)]
        return out

    def loop_key(self, s1):
        # clightgen's t'N temps are single-use (always set before read), so
        # they are dead at a loop head and are not part of the key
        key = (tuple(sorted((str(t), self._vkey(v)) for t, v in s1.temps.items()
                            if not str(t).startswith("t'"))),)
        if self.merge_key is not None:
            key += (self.merge_key(self, s1),)
        return key

    def join_states(self, label, states):
        groups = collections.OrderedDict()
        for s1 in states:
            groups.setdefault(self.loop_key(s1), []).append(s1)
        res = []
        for items in groups.values():
            if len(items) == 1:
                res.append(items[0])
            else:
                self.merges[label] += len(items) - 1
                res.append(self._join(label, [(None, x) for x in items])[1])
        return res

    def exec_switch(self, s, st):
        v = self.eval(s[1], st)
        ty = typeof(s[1])
        if v[0] not in ('I', 'L'):
            raise Stuck('switch on %r' % (v,))
        cases = []
        ls = s[2]
        while isinstance(ls, tuple) and ls[0] == 'LScons':
            lab = ls[1]
            n = None if lab == 'None' else lab[1]
            cases.append((n, ls[2]))
            ls = ls[3]
        x = v[1]

        def norm(n):
            return n & (M64 if v[0] == 'L' else M32)

        def run_from(i, st1):
            out = []
            states = [(N, st1)]
            for _, body in cases[i:]:
                nxt = []
                for o, s2 in states:
                    if o is N:
                        nxt.extend(self.exec(body, s2))
                    else:
                        nxt.append((o, s2))
                states = nxt
            for o, s2 in states:
                out.append(((N if o is BRK else o), s2))
            return out

        def index_for(n):
            for i, (lab, _) in enumerate(cases):
                if lab is not None and norm(lab) == n:
                    return i
            for i, (lab, _) in enumerate(cases):
                if lab is None:
                    return i
            return None

        if is_concrete(x):
            i = index_for(x)
            return [(N, st)] if i is None else run_from(i, st)
        # symbolic scrutinee: known from facts?
        labels = [norm(l) for l, _ in cases if l is not None]
        for n in labels:
            atom, pol = canon(mk('eq', 'i32', x, n))
            if st.facts.get(atom.key()) == pol:
                return run_from(index_for(n), st)
        dom = self.domains.get(x.args[0]) if isinstance(x, T) and x.op == 'var' else None
        if dom is not None:
            labels = [n for n in labels if n in dom]
        out = []
        rest = st
        for n in labels:
            atom, pol = canon(mk('eq', 'i32', x, n))
            if rest.facts.get(atom.key()) == (not pol):
                continue
            self.forks += 1
            if self.forks > self.max_paths:
                raise Trunc('path cap %d reached' % self.max_paths)
            hit = rest.clone()
            hit.facts[atom.key()] = pol
            self.atoms.setdefault(atom.key(), atom)
            self.learn(hit, atom, pol)
            hit.pc = log_push(hit.pc, 'switch %s == %s' % (show_val(x), show_val(n)))
            if isinstance(x, T) and x.op == 'var':
                self.substitute(hit, x, n)
            out.extend(run_from(index_for(n), hit))
            rest.facts[atom.key()] = not pol
            self.atoms.setdefault(atom.key(), atom)
        if dom is not None and dom <= set(labels):
            return out
        rest.pc = log_push(rest.pc, 'switch %s default' % show_val(x))
        i = index_for(None)
        if i is None or cases[i][0] is not None:
            out.append((N, rest))
        else:
            out.extend(run_from(i, rest))
        return out

    # ------------------------------------------------------------------ calls
    def exec_call(self, s, st):
        optid, fe, args = s[1], s[2], s[3]
        fty = typeof(fe)
        if fty[0] == 'tptr':
            fty = fty[1]
        targs = fty[1]
        fv = self.eval(fe, st)
        vargs = []
        for i, a in enumerate(args):
            v = self.eval(a, st)
            if i < len(targs):
                v = self.cast(v, typeof(a), targs[i], st)
            vargs.append(v)
        if fv[0] != 'P' or not fv[1].startswith('fun:'):
            raise Stuck('indirect call through %r' % (fv,))
        fname = fv[1][4:]
        results = self.call(fname, vargs, targs, fty[2], st)
        out = []
        for ret, s1 in results:
            if isinstance(ret, tuple) and ret[0] in ('stuck', 'trunc'):
                out.append((ret, s1))
                continue
            if optid != 'None':
                s1.temps[optid[1]] = ret if ret is not None else ('U', 'void result')
            out.append((N, s1))
        return out

    def call(self, fname, vargs, targs, tret, st):
        """Returns [(retval | ('stuck',msg) | ('trunc',msg), state)]."""
        f = self.functions.get(fname)
        if f is not None and fname not in self.opaque and st.depth < self.max_depth \
                and self.summarize is not None and self.summarize(fname):
            out = self.summarized_call(fname, vargs, targs, tret, st)
            if out is not None:
                if ('*' in self.merge_funcs or fname in self.merge_funcs) and len(out) > 1:
                    out = self.merge_results(fname, out)
                return out
        if f is None or fname in self.opaque or st.depth >= self.max_depth:
            if f is not None and fname not in self.opaque:
                self.truncations.append('depth cap at %s' % fname)
                st.warn('depth cap: %s treated as external' % fname)
            return [(self.external(fname, vargs, targs, tret, st), st)]
        st.calls = log_push(st.calls, ('internal', fname))
        saved_temps, saved_locals, saved_fname = st.temps, st.locals, st.fname
        temps = {}
        for (pid_ty, v) in zip(f['fn_params'], vargs):
            _, pid, pty = pid_ty
            temps[pid] = v
        for t in f['fn_temps']:
            temps.setdefault(t[1], ('U', 'uninit temp'))
        locs = {}
        for vd in f['fn_vars']:
            _, vid, vty = vd
            rn = st.fresh('L:%s.%s' % (fname, vid))
            self.region(rn, vty, '%s.%s' % (fname, vid), False, False, 'local')
            locs[vid] = rn
        st.temps, st.locals, st.fname = temps, locs, fname
        st.depth += 1
        res = self.exec(f['fn_body'], st)
        out = []
        for o, s1 in res:
            s1.depth -= 1
            s1.temps, s1.locals, s1.fname = dict(saved_temps), saved_locals, saved_fname
            for rn in locs.values():
                s1.mem.pop(rn, None)
                s1.owned.discard(rn)
            if o[0] == 'return':
                if o[1] is None:
                    out.append((None, s1))
                else:
                    v, ty = o[1]
                    try:
                        out.append((self.cast(v, ty, f['fn_return'], s1), s1))
                    except Stuck as e:
                        out.append((('stuck', str(e)), s1))
            elif o is N:
                out.append((None if f['fn_return'] == 'tvoid' else ('U', 'fell off end'), s1))
            elif o[0] in ('stuck', 'trunc'):
                out.append((o, s1))
            else:
                out.append((('stuck', 'break/continue out of function'), s1))
        if ('*' in self.merge_funcs or fname in self.merge_funcs) and len(out) > 1:
            out = self.merge_results(fname, out)
        return out

    # ------------------------------------------------------------------ summaries
    #
    # A summary of `f(args)` is the outcome set of one symbolic run of f from a
    # fresh state in which the MarioState / objects / world are lazily symbolic
    # (named by access path, exactly like the caller's lazily-read cells), plus
    # the root "skeleton" cells (m->marioObj, gMarioState, W presets, ...) that
    # agree with the caller, plus the caller's concrete values of a few key cells
    # (action, actionState, actionArg, input).  Applying a summary at a call
    # site substitutes, per outcome:
    #   path-named var  -> the caller's current value of that cell,
    #   lazy region     -> the caller's pointer stored in the originating cell,
    #   fresh '#'/mrg names -> fresh caller names,
    # then checks the outcome's path facts against the caller (facts + intervals;
    # infeasible outcomes are dropped), stores the outcome's written cells, and
    # returns the substituted return value.

    _TOKEN = __import__('re').compile(r'^(.*#(?:s\d+_)?\d+|mrg\d+)(.*)$')

    def _renamable(self, name):
        return self._TOKEN.match(name) is not None

    def _summary_key(self, fname, vargs, st):
        ak = []
        for v in vargs:
            if v[0] == 'P':
                r = self.regions[v[1]]
                if not is_concrete(v[2]) or r.kind in ('local', 'ext') or self._renamable(r.path):
                    return None
                if v[1] in self.region_origin:
                    return None
            elif v[0] in ('I', 'L', 'S', 'F'):
                if not is_concrete(v[1]):
                    return None
            else:
                return None
            ak.append(self._vkey(v))
        skel = []
        for i, (reg, ofs, chunk, val) in enumerate(self.summary_skeleton):
            cell = st.mem.get(reg, {}).get(ofs)
            if cell is not None and cell[0] == chunk and self._vkey(cell[1]) == self._vkey(val):
                skel.append(i)
        sfacts = []
        for i, (key, pol, reg, ofs) in enumerate(self.summary_skel_facts):
            cell = st.mem.get(reg, {}).get(ofs)
            if st.facts.get(key) == pol and (cell is None or (cell[1][0] == 'P' and self.regions[cell[1][1]].path == key[8:-1])):
                sfacts.append(i)
        pre = []
        for (reg, ofs, chunk) in self.summary_presets:
            cell = st.mem.get(reg, {}).get(ofs)
            if cell is not None and cell[0] == chunk and cell[1][0] == 'I' and is_concrete(cell[1][1]):
                pre.append((reg, ofs, chunk, cell[1][1]))
        for (reg, ofs, chunk) in self.summary_masked:
            cell = st.mem.get(reg, {}).get(ofs)
            m = M32
            if cell is not None and cell[1][0] == 'I':
                m = self.maybe_bits(cell[1][1])
            elif cell is None:
                continue
            m &= {'i16u': 0xFFFF, 'i8u': 0xFF}.get(chunk, M32)
            pre.append((reg, ofs, chunk, ('mask', m)))
        return (fname, tuple(ak), tuple(skel), tuple(sfacts), tuple(pre))

    def summarized_call(self, fname, vargs, targs, tret, st):
        key = self._summary_key(fname, vargs, st)
        if key is None or key in self.summary_active:
            self.summary_stats['inlined (not summarizable here)'] += 1
            self.summary_inlined[fname] += 1
            return None
        ent = self.summary_cache.get(key)
        if ent is None:
            self.summary_ctr += 1
            s0 = State()
            s0.ns = 's%d_' % self.summary_ctr
            s0.depth = st.depth
            s0.fname = st.fname
            init = {}
            for i in key[2]:
                reg, ofs, chunk, val = self.summary_skeleton[i]
                s0.region_w(reg)[ofs] = (chunk, val)
                init[(reg, ofs)] = self._vkey(val)
            for i in key[3]:
                k, pol, _, _ = self.summary_skel_facts[i]
                s0.facts[k] = pol
            for reg, ofs, chunk, c in key[4]:
                if isinstance(c, tuple):        # a masked symbol: the caller's value, bits known
                    r = self.regions[reg]
                    name = '%s%s&0x%x' % (r.path, self._path(r, ofs, chunk), c[1])
                    self.bits[name] = c[1]
                    self.var_origin[name] = (reg, ofs, chunk, None)
                    v = ('I', var(name, 'i32'))
                else:
                    v = ('I', c)
                s0.region_w(reg)[ofs] = (chunk, v)
                init[(reg, ofs)] = self._vkey(v)
            self.summary_active.add(key)
            f0 = self.forks
            try:
                res = self.call(fname, vargs, targs, tret, s0)
            finally:
                self.summary_active.discard(key)
            for _, fs in res:          # slim the cached outcome states
                if not self.summary_pc:
                    fs.pc = None
                fs.temps = {}
                fs.subst = {}
                fs.owned = set()
                fs.reads = tuple(sorted(set(log_list(fs.reads))))
                # keep only what application needs: written cells + fresh regions
                keep = {}
                for reg, cells in fs.mem.items():
                    r = self.regions[reg]
                    if r.kind == 'local' or not r.lazy:
                        continue
                    if reg.startswith('R:') and self._renamable(reg[2:]):
                        keep[reg] = cells
                        continue
                    w = {o: c for o, c in cells.items()
                         if not self._is_initial({'init': init}, reg, o, c[0], c[1])}
                    if w:
                        keep[reg] = w
                fs.mem = keep
            ent = {'res': res, 'init': init, 'facts': {self.summary_skel_facts[i][0] for i in key[3]},
                   'forks': self.forks - f0, 'id': self.summary_ctr}
            self.summary_cache[key] = ent
            self.summary_stats['summaries computed'] += 1
            self.summary_stats['summary outcomes'] += len(res)
            if DEBUG:
                import sys
                sys.stderr.write('summary %s %s: %d outcomes, %d forks\n' % (
                    fname, [p[3] if not isinstance(p[3], tuple) else hex(p[3][1]) for p in key[4]], len(res), ent['forks']))
                sys.stderr.flush()
        else:
            self.summary_stats['summary reuses'] += 1
        out = []
        for ret, fs in ent['res']:
            r = self._apply_outcome(fname, ent, ret, fs, st)
            if r is not None:
                out.append(r)
            else:
                self.summary_stats['outcomes pruned at call site'] += 1
        self.summary_stats['outcomes applied'] += len(out)
        return out

    class _Ctx:
        __slots__ = ('st', 'fs', 'ren', 'mt', 'mr', 'pending')

    def _rename(self, ctx, name):
        m = self._TOKEN.match(name)
        if m is None:
            return name
        tok, rest = m.group(1), m.group(2)
        new = ctx.ren.get(tok)
        if new is None:
            if tok.startswith('mrg') and '#' not in tok:
                self.mrg_ctr += 1
                new = 'mrg%d' % self.mrg_ctr
            else:
                new = ctx.st.fresh(tok[:tok.rindex('#')])
            ctx.ren[tok] = new
        nn = new + rest
        if not rest and name in self.join_vals and nn not in self.join_vals:
            # re-derive the joined values' domain / known bits in caller terms
            self.join_vals[nn] = []
            vals = [self._map_term(ctx, t) for t in self.join_vals[name]]
            if not any(isinstance(x, tuple) for x in vals):
                self.join_vals[nn] = vals
                if all(is_concrete(x) for x in vals):
                    self.domains[nn] = frozenset(x & M32 for x in vals)
                else:
                    mb = 0
                    for x in vals:
                        mb |= self.maybe_bits(x)
                    mb &= self.bits.get(name, M32)
                    if mb != M32:
                        self.bits[nn] = mb
            return nn
        if name in self.domains and nn not in self.domains:
            self.domains[nn] = self.domains[name]
        if name in self.bits and nn not in self.bits:
            self.bits[nn] = self.bits[name]
        return nn

    def _map_region(self, ctx, rname):
        hit = ctx.mr.get(rname)
        if hit is not None:
            return hit
        r = self.regions[rname]
        if rname.startswith('R:') and self._renamable(rname[2:]):
            nn = self._rename(ctx, rname[2:])
            new = 'R:' + nn
            self.region(new, r.ty, nn, r.lazy, r.nullable, r.kind)
            ctx.pending.append((rname, new))
            res = ('P', new, 0)
        elif rname in self.region_origin:
            preg, pofs, pty = self.region_origin[rname]
            base = self._map_region(ctx, preg)
            if base[0] != 'P' or not is_concrete(base[2]):
                raise Stuck('summary: region %s has no caller base' % r.path)
            v = self.load(ctx.st, 'i32', pty, base[1], (base[2] + pofs) & M32)
            if v[0] == 'P':
                res = v
            elif v[0] == 'I' and is_concrete(v[1]) and v[1] == 0:
                res = ('I', 0)
            else:
                raise Stuck('summary: pointer cell of %s is not a pointer in the caller' % r.path)
        else:
            res = ('P', rname, 0)
        ctx.mr[rname] = res
        return res

    def _map_var(self, ctx, name, kind):
        """Caller meaning of a summary var: a term/concrete, or a ('P',..) pointer."""
        if name.startswith('nonnull('):
            reg = self.path_region.get(name[8:-1])
            if reg is None:
                return var(name, kind)
            p = self._map_region(ctx, reg)
            if p[0] != 'P':
                return 0
            b = self.bool_term(ctx.st, p, None)
            return int(b) if isinstance(b, bool) else b
        if self._renamable(name):
            return var(self._rename(ctx, name), kind)
        o = self.var_origin.get(name)
        if o is not None:
            reg, ofs, chunk, ty = o
            base = self._map_region(ctx, reg)
            if base[0] != 'P' or not is_concrete(base[2]):
                raise Stuck('summary: cell %s has no caller base' % name)
            v = self.load(ctx.st, chunk, ty, base[1], (base[2] + ofs) & M32)
            if v[0] == 'P':
                return v
            if v[0] == 'U':
                raise Stuck('summary: undefined caller cell %s' % name)
            return v[1]
        if self._renamable(name):
            return var(self._rename(ctx, name), kind)
        return var(name, kind)

    def _map_term(self, ctx, t):
        if not isinstance(t, T):
            return t
        k = t.key()
        hit = ctx.mt.get(k)
        if hit is not None:
            return hit
        op = t.op
        if op == 'var':
            res = self._map_var(ctx, t.args[0], t.kind)
        elif op == 'load':
            path, ofs, chunk = t.args
            o2 = self._map_term(ctx, ofs)
            reg = self.path_region.get(path)
            res = T('load', (path, o2, chunk), t.kind)
            if reg is not None:
                base = self._map_region(ctx, reg)
                if base[0] == 'P':
                    res = T('load', (self.regions[base[1]].path, mk('add', 'i32', base[2], o2), chunk), t.kind)
        else:
            args = [self._map_term(ctx, a) for a in t.args]
            if any(isinstance(a, tuple) for a in args):
                raise Stuck('summary: pointer inside arithmetic after substitution')
            if op in INT_CMP_OPS or op == 'notbool':
                kind = next((a.kind for a in t.args if isinstance(a, T)), 'i32')
            elif op in FLT_CMP_OPS:
                kind = next((a.kind for a in t.args if isinstance(a, T)), 'f32')
            else:
                kind = t.kind
            res = mk(op, kind, *args)
        ctx.mt[k] = res
        return res

    def _map_val(self, ctx, v):
        if v is None or v[0] == 'U':
            return v
        if v[0] == 'P':
            base = self._map_region(ctx, v[1])
            off = self._map_term(ctx, v[2])
            if isinstance(off, tuple):
                raise Stuck('summary: pointer offset is a pointer')
            if base[0] == 'P':
                o = (base[2] + off) & M32 if is_concrete(base[2]) and is_concrete(off) else mk('add', 'i32', base[2], off)
                return ('P', base[1], o)
            return ('I', off)
        x = self._map_term(ctx, v[1])
        if isinstance(x, tuple):
            if v[0] == 'I':
                return x
            raise Stuck('summary: non-int view of a pointer')
        return (v[0], x)

    def _is_initial(self, ent, reg, ofs, chunk, v):
        iv = ent['init'].get((reg, ofs))
        if iv is not None:
            return self._vkey(v) == iv
        r = self.regions[reg]
        name = '%s%s' % (r.path, self._path(r, ofs, chunk))
        if v[0] == 'P':
            return v[1] == 'R:' + name and is_concrete(v[2]) and v[2] == 0
        x = v[1] if v[0] != 'U' else None
        if isinstance(x, T) and x.op == 'var' and x.args[0] == name:
            return True
        dom = self.domains.get(name)
        if dom is not None and len(dom) == 1 and v[0] == 'I' and is_concrete(x) and x == next(iter(dom)):
            return True
        return False

    def _apply_outcome(self, fname, ent, ret, fs, st):
        ctx = Explorer._Ctx()
        cst = st.clone()
        ctx.st, ctx.fs, ctx.ren, ctx.mt, ctx.mr, ctx.pending = cst, fs, {}, {}, {}, []
        try:
            # 1. path facts of the outcome, checked against the caller
            for key, pol in fs.facts.items():
                if key in ent['facts']:
                    continue
                atom = self.atoms.get(key)
                if atom is None:
                    if key.startswith('nonnull('):
                        atom = var(key, 'i32')
                    else:
                        continue
                a2 = self._map_term(ctx, atom)
                if isinstance(a2, tuple):
                    a2 = self.bool_term(cst, a2, None)
                    if not isinstance(a2, bool):
                        a2 = a2
                if isinstance(a2, bool) or is_concrete(a2):
                    if (a2 != 0) != pol:
                        return None
                    continue
                at, p2 = canon(a2)
                if is_concrete(at):
                    if ((at != 0) == p2) != pol:
                        return None
                    continue
                val = (pol == p2)
                k2 = at.key()
                have = cst.facts.get(k2)
                if have is not None:
                    if have != val:
                        return None
                    continue
                rd = self.range_decide(cst, at)
                if rd is not None:
                    if rd != val:
                        return None
                    continue
                cst.facts[k2] = val
                self.atoms.setdefault(k2, at)
                self.learn(cst, at, val)
            # 2. written cells (values relative to the call-entry state)
            writes = []
            if not (isinstance(ret, tuple) and ret[0] in ('stuck', 'trunc')):
                for reg, cells in fs.mem.items():
                    r = self.regions[reg]
                    if r.kind == 'local' or not r.lazy:
                        continue
                    if reg.startswith('R:') and self._renamable(reg[2:]):
                        continue
                    for ofs, (chunk, v) in cells.items():
                        if self._is_initial(ent, reg, ofs, chunk, v):
                            continue
                        base = self._map_region(ctx, reg)
                        if base[0] != 'P' or not is_concrete(base[2]):
                            return None     # the summary wrote through what is NULL here
                        writes.append((base[1], (base[2] + ofs) & M32, chunk, self._map_val(ctx, v)))
                ret2 = self._map_val(ctx, ret) if ret is not None else None
            else:
                ret2 = ret
            # world reads, in caller terms (logs caller reads of e.g. collided-object fields)
            for name in fs.reads:
                if name in self.var_origin:
                    try:
                        self._map_var(ctx, name, 'i32')
                    except Stuck:
                        pass
                elif '#' not in name:
                    cst.reads = log_push(cst.reads, name)
            # fresh regions reached from the outcome: copy their cells
            copies = []
            done = set()
            while ctx.pending:
                old, new = ctx.pending.pop()
                if old in done:
                    continue
                done.add(old)
                for ofs, (chunk, v) in fs.mem.get(old, {}).items():
                    copies.append((new, ofs, chunk, self._map_val(ctx, v)))
                okey = 'nonnull(%s)' % self.regions[old].path
                if okey in fs.facts:
                    cst.facts['nonnull(%s)' % self.regions[new].path] = fs.facts[okey]
            for reg, ofs, chunk, v in writes:
                self.store(cst, chunk, reg, ofs, v)
            for reg, ofs, chunk, v in copies:
                cst.region_w(reg)[ofs] = (chunk, v)
        except Stuck as e:
            self.summary_stats['outcomes unmappable'] += 1
            cst.warn('summary %s: outcome not mappable (%s)' % (fname, e))
            return (('stuck', 'summary %s: %s' % (fname, e)), cst)
        # 3. logs
        cst.calls = log_push(cst.calls, ('internal', fname))
        for c in log_list(fs.calls):
            cst.calls = log_push(cst.calls, c)
        for w in log_list(fs.warns):
            cst.warns = log_push(cst.warns, w)
        cst.pc = log_push(cst.pc, 'summary %s#%d {' % (fname, ent['id']))
        if self.summary_pc:
            for c in log_list(fs.pc):
                cst.pc = log_push(cst.pc, '  ' + c)
            cst.pc = log_push(cst.pc, '} %s' % fname)
        for c, n in fs.ctr.items():
            if c.startswith('iter@') and n > cst.ctr.get(c, 0):
                cst.ctr[c] = n
        return (ret2, cst)

    # ------------------------------------------------------------------ merging
    def _vkey(self, v):
        if v is None:
            return 'void'
        if v[0] == 'P':
            return ('P', v[1], show_val(v[2]))
        return (v[0], show_val(v[1])) if v[0] != 'U' else ('U',)

    def _abs_ret(self, st, v):
        if isinstance(v, tuple) and v[0] == 'P':
            nn = self.bool_term(st, v, None)
            return 'ptr' if nn is True else ('ptr?' if not isinstance(nn, bool) else 'NULL')
        if isinstance(v, tuple) and v[0] in ('stuck', 'trunc'):
            return v
        return self._vkey(v)

    def merge_results(self, fname, out):
        """Join outcomes of one call that agree on (return value, merge_key).

        Cells on which the joined states disagree become fresh symbols
        ('mrg#n'); path facts are intersected.  An over-approximation used
        to fight path explosion; precision loss is reported via the pc."""
        groups = collections.OrderedDict()
        for ret, s1 in out:
            k = (self._abs_ret(s1, ret),)
            if self.merge_key is not None and not (isinstance(ret, tuple) and ret[0] in ('stuck', 'trunc')):
                k = k + (self.merge_key(self, s1),)
            groups.setdefault(k, []).append((ret, s1))
        res = []
        for k, items in groups.items():
            if len(items) == 1 or (isinstance(items[0][0], tuple) and items[0][0][0] in ('stuck', 'trunc')):
                res.extend(items)
                continue
            self.merges[fname] += len(items) - 1
            res.append(self._join(fname, items))
        return res

    def _join(self, fname, items):
        states = [s for _, s in items]
        base = states[0].clone()
        for s in states[1:]:
            for c, n in s.ctr.items():
                if n > base.ctr.get(c, 0):
                    base.ctr[c] = n
        # memory
        regs = set()
        for s in states:
            regs.update(s.mem.keys())
        for reg in regs:
            for s in states:
                self.ensure_region_mem(s, reg)
            self.ensure_region_mem(base, reg)
        for reg in regs:
            r = self.regions[reg]
            offs = set()
            for s in states:
                offs.update(s.mem.get(reg, {}).keys())
            for o in sorted(offs):
                vals = []
                for s in states:
                    cell = s.mem.get(reg, {}).get(o)
                    if cell is None and r.lazy:
                        like = next((x.mem[reg][o] for x in states if o in x.mem.get(reg, {})), None)
                        cell = self._initial_cell(s, reg, o, like)
                    vals.append(cell)
                if all(v is not None for v in vals) and len({(v[0], self._vkey(v[1])) for v in vals}) == 1:
                    if base.mem.get(reg, {}).get(o) != vals[0]:
                        base.region_w(reg)[o] = vals[0]
                    continue
                chunk = next(v[0] for v in vals if v is not None)
                if any(v is None or v[0] != chunk for v in vals):
                    if reg in base.mem and o in base.mem[reg]:
                        del base.region_w(reg)[o]
                    base.warn('join %s: dropped cell %s+%d' % (fname, r.path, o))
                    continue
                self.mrg_ctr += 1
                name = 'mrg%d' % self.mrg_ctr     # globally unique
                v0 = vals[0][1]
                dom = set()
                for v in vals:
                    x = v[1][1] if v[1][0] == 'I' else None
                    if x is not None and is_concrete(x):
                        dom.add(x)
                    elif isinstance(x, T) and x.op == 'var' and x.args[0] in self.domains:
                        dom |= self.domains[x.args[0]]
                    else:
                        dom = None
                        break
                if dom is not None:
                    self.domains[name] = frozenset(dom)
                elif chunk not in ('f32', 'f64', 'i64') and all(v[1][0] == 'I' for v in vals):
                    uniq = {}
                    for v in vals:
                        uniq.setdefault(show_val(v[1][1]), v[1][1])
                    if len(uniq) <= 64:
                        self.join_vals[name] = list(uniq.values())
                    mb = 0
                    for v in vals:
                        mb |= self.maybe_bits(v[1][1])
                    if chunk in ('i16u',):
                        mb &= 0xFFFF
                    if mb != M32:
                        self.bits[name] = mb
                if v0[0] == 'P' or any(v[1][0] == 'P' for v in vals):
                    rn = 'R:' + name
                    ty = self.layout.type_at(r.ty, o) if r.ty is not None else None
                    self.region(rn, ty[1] if isinstance(ty, tuple) and ty[0] == 'tptr' else None,
                                name, True, True, 'world')
                    nv = ('P', rn, 0)
                else:
                    nv = self._wrap(chunk, var(name, self._kind(chunk)), None, base, name)
                base.region_w(reg)[o] = (chunk, nv)
                base.pc = log_push(base.pc, '%s := join{%s}' % (name, ' | '.join(
                    sorted({self.show_value(v[1]) for v in vals}))[:300]))
        # temps (the caller's frame is identical, but be safe)
        for t in list(base.temps):
            if len({self._vkey(s.temps.get(t)) for s in states}) != 1:
                base.temps[t] = ('U', 'joined temp')
        # facts: keep the agreed ones
        base.facts = {k: v for k, v in base.facts.items() if all(s.facts.get(k) == v for s in states)}
        base.subst = {k: v for k, v in base.subst.items() if all(s.subst.get(k) == v for s in states)}
        bnd = {}
        for k, b in base.bounds.items():
            bs = [s.bounds.get(k) for s in states]
            if all(x is not None for x in bs):
                bnd[k] = (min(x[0] for x in bs), max(x[1] for x in bs))
        base.bounds = bnd
        # pc: common prefix + note
        pcs = [log_list(s.pc) for s in states]
        n = 0
        while all(len(p) > n for p in pcs) and all(p[n] == pcs[0][n] for p in pcs):
            n += 1
        common_after = [c for c in pcs[0][n:] if all(c in p for p in pcs[1:])]
        pc = None
        for c in pcs[0][:n] + common_after:
            pc = log_push(pc, c)
        pc = log_push(pc, 'JOIN %s: %d paths' % (fname, len(states)))
        mrg_notes = [c for c in log_list(base.pc)[len(pcs[0]):]]
        for c in mrg_notes:
            pc = log_push(pc, c)
        base.pc = pc
        # logs: union of reads / warnings; calls of the first
        seen = set(log_list(base.reads))
        for s in states[1:]:
            for r in log_list(s.reads):
                if r not in seen:
                    seen.add(r)
                    base.reads = log_push(base.reads, r)
            have = set(log_list(base.warns))
            for w in log_list(s.warns):
                if w not in have:
                    have.add(w)
                    base.warns = log_push(base.warns, w)
        ret = items[0][0]
        rets = {self._vkey(r) for r, _ in items}
        if len(rets) > 1:
            ret = self.fresh_result('mrg_ret', 'tint', base) if ret[0] == 'I' else ret
        return ret, base

    def _initial_cell(self, st, reg, o, like):
        """The initial (lazily symbolic) content of a cell, without logging."""
        if like is None:
            return None
        chunk = like[0]
        r = self.regions[reg]
        ty = self.layout.type_at(r.ty, o) if r.ty is not None else None
        name = '%s%s' % (r.path, self._path(r, o, chunk))
        return (chunk, self._wrap(chunk, var(name, self._kind(chunk)), ty, st, name))

    def external(self, fname, vargs, targs, tret, st):
        shown = ', '.join(self.show_value(v) for v in vargs)
        st.calls = log_push(st.calls, ('external', fname, shown))
        c = self.contracts.get(fname)
        if c is not None:
            return c(self, st, vargs, tret)
        if any(v[0] == 'P' and self.regions[v[1]].kind in ('mario', 'obj', 'local') for v in vargs):
            st.warn('UNMODELLED external %s with pointer args (assumed no memory effect)' % fname)
        return self.fresh_result(fname, tret, st)

    def fresh_result(self, fname, tret, st, label=None):
        if tret == 'tvoid':
            return None
        name = st.fresh(label or fname)
        k = tkind(tret)
        if k == 'ptr':
            rn = 'R:' + name
            self.region(rn, tret[1], name, True, True, 'ext')
            return ('P', rn, 0)
        if k == 'single':
            return ('S', var(name, 'f32'))
        if k == 'float':
            return ('F', var(name, 'f64'))
        if k == 'long':
            return ('L', var(name, 'i64'))
        size, sg = INT_TYPES[tret]
        t = var(name, 'i32')
        if size < 4:
            t = mk(('sext' if sg else 'zext') + str(8 * size), 'i32', t)
        return ('I', t)

    def show_value(self, v):
        if v is None:
            return 'void'
        if v[0] == 'P':
            r = self.regions[v[1]]
            return '&%s%s' % (r.path, '' if (is_concrete(v[2]) and v[2] == 0) else
                              (self._path(r, v[2], None) if is_concrete(v[2]) else '+' + show_val(v[2])))
        if v[0] == 'U':
            return 'undef'
        return show_val(v[1])

    # ------------------------------------------------------------------ top level
    def run(self, fname, vargs, st):
        f = self.functions[fname]
        targs = [p[2] for p in f['fn_params']]
        self.forks = 0
        return self.call(fname, vargs, targs, f['fn_return'], st)
