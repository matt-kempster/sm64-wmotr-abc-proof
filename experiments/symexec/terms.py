"""Symbolic terms and concrete arithmetic for the Clight symbolic executor.

EXPLORATORY / UNVERIFIED.

Concrete values:
  i32 / i64 : Python int, normalised to [0, 2^w)
  f32       : numpy.float32  (every op rounds to binary32)
  f64       : Python float
Symbolic values are `T` objects (immutable, compared by their printed key).
`mk(op, kind, *args)` builds a term, folding when every argument is concrete.
"""
import struct
import numpy as np

np.seterr(all='ignore')

M32 = (1 << 32) - 1
M64 = (1 << 64) - 1


class T:
    __slots__ = ('op', 'args', 'kind', '_k')

    def __init__(self, op, args, kind):
        self.op = op
        self.args = tuple(args)
        self.kind = kind
        self._k = None

    def key(self):
        if self._k is None:
            self._k = show(self)
        return self._k

    def __eq__(self, other):
        return isinstance(other, T) and self.key() == other.key()

    def __hash__(self):
        return hash(self.key())

    def __repr__(self):
        return self.key()

    __str__ = __repr__


def var(name, kind):
    return T('var', (name,), kind)


def is_concrete(x):
    return not isinstance(x, T)


def f32(x):
    return np.float32(x)


def f32_of_bits(b):
    return np.frombuffer(struct.pack('>I', b & M32), dtype='>f4')[0].astype(np.float32)


def bits_of_f32(x):
    return struct.unpack('>I', struct.pack('>f', float(x)))[0]


def f64_of_bits(b):
    return struct.unpack('>d', struct.pack('>Q', b & M64))[0]


def bits_of_f64(x):
    return struct.unpack('>Q', struct.pack('>d', x))[0]


def signed(x, w=32):
    x &= (1 << w) - 1
    return x - (1 << w) if x >> (w - 1) else x


def fmt_float(x):
    x = float(x)
    if x == int(x) and abs(x) < 1e15:
        return str(int(x)) + ('.0' if False else '')
    r = repr(x)
    return r


# ---------------------------------------------------------------------------
# Concrete semantics
# ---------------------------------------------------------------------------

class Undef(Exception):
    pass


def _idiv(a, b):
    q = abs(a) // abs(b)
    return q if (a >= 0) == (b >= 0) else -q


def conc_int(op, w, a, b=None):
    m = (1 << w) - 1
    if op == 'add':
        return (a + b) & m
    if op == 'sub':
        return (a - b) & m
    if op == 'mul':
        return (a * b) & m
    if op in ('divs', 'mods'):
        sa, sb = signed(a, w), signed(b, w)
        if sb == 0 or (sa == -(1 << (w - 1)) and sb == -1):
            raise Undef('division overflow')
        q = _idiv(sa, sb)
        return (q if op == 'divs' else sa - q * sb) & m
    if op in ('divu', 'modu'):
        if b == 0:
            raise Undef('division by zero')
        return (a // b if op == 'divu' else a % b) & m
    if op == 'and':
        return a & b
    if op == 'or':
        return a | b
    if op == 'xor':
        return a ^ b
    if op in ('shl', 'shrs', 'shru'):
        if not (0 <= b < w):
            raise Undef('shift amount')
        if op == 'shl':
            return (a << b) & m
        if op == 'shru':
            return a >> b
        return (signed(a, w) >> b) & m
    if op == 'neg':
        return (-a) & m
    if op == 'not':
        return (~a) & m
    if op == 'notbool':
        return int(a == 0)
    cmp = {'eq': lambda x, y: x == y, 'ne': lambda x, y: x != y}
    if op in cmp:
        return int(cmp[op](a, b))
    if op[-1] == 's' and op[:2] in ('lt', 'le', 'gt', 'ge'):
        a, b = signed(a, w), signed(b, w)
    c = op[:2]
    if c == 'lt':
        return int(a < b)
    if c == 'le':
        return int(a <= b)
    if c == 'gt':
        return int(a > b)
    if c == 'ge':
        return int(a >= b)
    raise ValueError(op)


def conc_float(op, kind, a, b=None):
    cv = np.float32 if kind == 'f32' else float
    if op == 'fadd':
        return cv(a + b)
    if op == 'fsub':
        return cv(a - b)
    if op == 'fmul':
        return cv(a * b)
    if op == 'fdiv':
        if kind == 'f64':
            if b == 0:
                if a == 0 or a != a:
                    return float('nan')
                return float('inf') if (a > 0) == (np.copysign(1, b) > 0) else float('-inf')
            return a / b
        return np.float32(a) / np.float32(b)
    if op == 'fneg':
        return cv(-a)
    if op == 'fabs':
        return cv(abs(a))
    if op == 'feq':
        return int(a == b)
    if op == 'fne':
        return int(a != b)
    if op == 'flt':
        return int(a < b)
    if op == 'fle':
        return int(a <= b)
    if op == 'fgt':
        return int(a > b)
    if op == 'fge':
        return int(a >= b)
    raise ValueError(op)


def _f2i(x, lo, hi):
    x = float(x)
    if x != x:
        raise Undef('float->int NaN')
    t = int(x)  # truncation toward zero
    if t < lo or t > hi:
        raise Undef('float->int out of range')
    return t


def conc_conv(op, a):
    if op == 'sext8':
        return signed(a, 8) & M32
    if op == 'zext8':
        return a & 0xff
    if op == 'sext16':
        return signed(a, 16) & M32
    if op == 'zext16':
        return a & 0xffff
    if op == 's2f':
        return np.float32(signed(a))
    if op == 'u2f':
        return np.float32(a)
    if op == 's2d':
        return float(signed(a))
    if op == 'u2d':
        return float(a)
    if op in ('f2s', 'd2s'):
        return _f2i(a, -2**31, 2**31 - 1) & M32
    if op in ('f2u', 'd2u'):
        return _f2i(a, 0, 2**32 - 1)
    if op == 'f2d':
        return float(a)
    if op == 'd2f':
        return np.float32(a)
    if op == 'f2bits':
        return bits_of_f32(a)
    if op == 'bits2f':
        return f32_of_bits(a)
    if op == 'i2l_s':
        return signed(a) & M64
    if op == 'i2l_u':
        return a
    if op == 'l2i':
        return a & M32
    if op == 'l2d_s':
        return float(signed(a, 64))
    if op == 'l2f_s':
        return np.float32(signed(a, 64))
    if op == 'd2l_s':
        return _f2i(a, -2**63, 2**63 - 1) & M64
    raise ValueError(op)


INT_BIN = {'add', 'sub', 'mul', 'divs', 'divu', 'mods', 'modu', 'and', 'or', 'xor',
           'shl', 'shrs', 'shru', 'eq', 'ne', 'lts', 'ltu', 'les', 'leu', 'gts', 'gtu',
           'ges', 'geu'}
INT_CMP = {'eq', 'ne', 'lts', 'ltu', 'les', 'leu', 'gts', 'gtu', 'ges', 'geu'}
FLT_BIN = {'fadd', 'fsub', 'fmul', 'fdiv', 'feq', 'fne', 'flt', 'fle', 'fgt', 'fge'}
FLT_CMP = {'feq', 'fne', 'flt', 'fle', 'fgt', 'fge'}
CONV_KIND = {'sext8': 'i32', 'zext8': 'i32', 'sext16': 'i32', 'zext16': 'i32',
             's2f': 'f32', 'u2f': 'f32', 's2d': 'f64', 'u2d': 'f64',
             'f2s': 'i32', 'f2u': 'i32', 'd2s': 'i32', 'd2u': 'i32',
             'f2d': 'f64', 'd2f': 'f32', 'f2bits': 'i32', 'bits2f': 'f32',
             'i2l_s': 'i64', 'i2l_u': 'i64', 'l2i': 'i32', 'l2d_s': 'f64', 'l2f_s': 'f32',
             'd2l_s': 'i64'}


def mk(op, kind, *args):
    """Build `op(args)` of result kind `kind`, folding concrete arguments.

    For binary int ops `kind` is the operand width kind ('i32'/'i64'); the
    result kind of a comparison is always 'i32'."""
    if all(is_concrete(a) for a in args):
        if op in INT_BIN or op in ('neg', 'not', 'notbool'):
            return conc_int(op, 64 if kind == 'i64' else 32, *args)
        if op in FLT_BIN or op in ('fneg', 'fabs'):
            return conc_float(op, kind, *args)
        return conc_conv(op, *args)
    rkind = kind
    if op in INT_CMP or op in FLT_CMP or op == 'notbool':
        rkind = 'i32'
    elif op in CONV_KIND:
        rkind = CONV_KIND[op]
    # light algebraic simplifications (exact in the modular / IEEE semantics)
    if op in ('add', 'or', 'xor', 'sub') and len(args) == 2 and is_concrete(args[1]) and args[1] == 0:
        return args[0]
    if op == 'add' and is_concrete(args[0]) and args[0] == 0:
        return args[1]
    if op == 'mul' and is_concrete(args[1]) and args[1] == 1:
        return args[0]
    if op == 'and' and is_concrete(args[1]) and args[1] == 0:
        return 0
    if op == 'and' and is_concrete(args[1]) and isinstance(args[0], T) and args[0].op == 'and' \
            and is_concrete(args[0].args[1]):
        return mk('and', kind, args[0].args[0], args[0].args[1] & args[1])
    if op == 'and' and is_concrete(args[0]) and not is_concrete(args[1]):
        return mk('and', kind, args[1], args[0])
    if op in ('sext16', 'zext16', 'sext8', 'zext8') and isinstance(args[0], T) and args[0].op == op:
        return args[0]
    if op == 'notbool' and isinstance(args[0], T) and args[0].op in INT_CMP | FLT_CMP:
        pass
    return T(op, args, rkind)


# ---------------------------------------------------------------------------
# Printing
# ---------------------------------------------------------------------------

SYM = {'add': '+', 'sub': '-', 'mul': '*', 'divs': '/', 'divu': '/u', 'mods': '%',
       'modu': '%u', 'and': '&', 'or': '|', 'xor': '^', 'shl': '<<', 'shrs': '>>',
       'shru': '>>u', 'eq': '==', 'ne': '!=', 'lts': '<', 'ltu': '<u', 'les': '<=',
       'leu': '<=u', 'gts': '>', 'gtu': '>u', 'ges': '>=', 'geu': '>=u',
       'fadd': '+', 'fsub': '-', 'fmul': '*', 'fdiv': '/', 'feq': '==', 'fne': '!=',
       'flt': '<', 'fle': '<=', 'fgt': '>', 'fge': '>='}
CONV_SHOW = {'s2f': '(f32)', 'u2f': '(f32u)', 's2d': '(f64)', 'u2d': '(f64u)',
             'f2s': '(s32)', 'f2u': '(u32)', 'd2s': '(s32)', 'd2u': '(u32)',
             'f2d': '(f64)', 'd2f': '(f32)', 'sext16': '(s16)', 'zext16': '(u16)',
             'sext8': '(s8)', 'zext8': '(u8)', 'l2i': '(i32)', 'i2l_s': '(i64)',
             'i2l_u': '(u64)', 'l2d_s': '(f64)', 'l2f_s': '(f32)', 'd2l_s': '(i64)'}


def show_val(x, kind=None):
    if isinstance(x, T):
        return x.key()
    if isinstance(x, (np.floating, float)):
        s = fmt_float(x)
        return s + ('d' if isinstance(x, float) and not isinstance(x, np.floating) else '')
    if isinstance(x, int):
        if x > 0xffff and x < (1 << 32):
            sx = signed(x)
            if -65536 < sx < 0:
                return str(sx)
            return hex(x)
        return str(x)
    return str(x)


def show(t):
    op, a = t.op, t.args
    if op == 'var':
        return a[0]
    if op == 'load':
        return '%s[%s]' % (a[0], show_val(a[1]))
    if op in SYM and len(a) == 2:
        s = SYM[op]
        if t.kind == 'f64' and op in ('fadd', 'fsub', 'fmul', 'fdiv'):
            s = s + 'd'
        return '(%s %s %s)' % (show_val(a[0]), s, show_val(a[1]))
    if op in CONV_SHOW:
        return CONV_SHOW[op] + show_val(a[0])
    if op in ('neg', 'fneg'):
        return '-' + show_val(a[0])
    if op == 'not':
        return '~' + show_val(a[0])
    if op == 'notbool':
        return '!' + show_val(a[0])
    return '%s(%s)' % (op, ', '.join(show_val(x) for x in a))


# ---------------------------------------------------------------------------
# Canonical literals for path-condition facts
# ---------------------------------------------------------------------------

_FLIP_INT = {'ges': ('lts', False), 'geu': ('ltu', False), 'gts': ('lts', True),
             'gtu': ('ltu', True), 'les': ('lts', True), 'leu': ('ltu', True)}
# les(a,b) = !lts(b,a)


def canon(t):
    """Return (atom, polarity): truth(t) == (atom != 0) == polarity."""
    pol = True
    while True:
        if isinstance(t, T) and t.op == 'notbool':
            t = t.args[0]
            pol = not pol
            continue
        if isinstance(t, T) and t.op in ('ne', 'fne'):
            a, b = t.args
            if t.op == 'ne' and is_concrete(b) and b == 0:
                t = a
                continue
            t = T('eq' if t.op == 'ne' else 'feq', (a, b), 'i32')
            pol = not pol
            continue
        if isinstance(t, T) and t.op in _FLIP_INT:
            a, b = t.args
            base, swap = _FLIP_INT[t.op]
            if t.op in ('ges', 'geu'):
                t = T(base, (a, b), 'i32')
                pol = not pol
            elif t.op in ('gts', 'gtu'):
                t = T(base, (b, a), 'i32')
            else:  # le: !(b < a)
                t = T(base, (b, a), 'i32')
                pol = not pol
            continue
        if isinstance(t, T) and t.op == 'fgt':
            t = T('flt', (t.args[1], t.args[0]), 'i32')
            continue
        if isinstance(t, T) and t.op == 'fge':
            t = T('fle', (t.args[1], t.args[0]), 'i32')
            continue
        if isinstance(t, T) and t.op == 'eq' and is_concrete(t.args[1]) and t.args[1] == 0 \
                and isinstance(t.args[0], T) and t.args[0].kind == 'i32':
            t = t.args[0]
            pol = not pol
            continue
        if isinstance(t, T) and t.op == 'eq' and is_concrete(t.args[0]) and not is_concrete(t.args[1]):
            t = T('eq', (t.args[1], t.args[0]), 'i32')
            continue
        return t, pol
