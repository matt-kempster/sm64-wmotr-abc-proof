"""Clight types: classification, sizes, alignment, struct layout, chunks.

EXPLORATORY / UNVERIFIED.  Mirrors CompCert 3.15 Ctypes for the ppc32 EABI
target the generated files were produced for (Info.arch = powerpc,
bitsize 32, big_endian).  Pointers are 4 bytes; long long / double align 8.
"""

INT_TYPES = {
    # name: (size_bytes, signed)
    'tschar': (1, True), 'tuchar': (1, False), 'tchar': (1, True),
    'tshort': (2, True), 'tushort': (2, False),
    'tint': (4, True), 'tuint': (4, False),
    'tbool': (1, False),
}
LONG_TYPES = {'tlong': True, 'tulong': False}


def tkind(t):
    """Coarse classification: int / long / single / float / ptr / struct / union / void / fun."""
    if isinstance(t, str):
        if t in INT_TYPES:
            return 'int'
        if t in LONG_TYPES:
            return 'long'
        if t == 'tfloat':
            return 'single'
        if t == 'tdouble':
            return 'float'
        if t == 'tvoid':
            return 'void'
        raise ValueError('unknown type %r' % (t,))
    h = t[0]
    if h in ('tptr', 'tarray'):
        return 'ptr'
    if h == 'Tfunction':
        return 'fun'
    if h == 'Tstruct':
        return 'struct'
    if h == 'Tunion':
        return 'union'
    if h in ('tattr', 'Tint', 'Tfloat', 'Tlong', 'Tpointer'):
        raise ValueError('unhandled explicit type form %r' % (t,))
    raise ValueError('unknown type %r' % (t,))


def int_info(t):
    """(size, signed) for an int type."""
    return INT_TYPES[t]


def is_bool(t):
    return t == 'tbool'


def pointee(t):
    """Element type of a pointer or array."""
    return t[1]


class Layout:
    """Sizes / alignments / field offsets over a composite environment."""

    def __init__(self, composites):
        self.composites = composites     # name -> (su, members)
        self._cache = {}

    def sizeof(self, t):
        k = tkind(t)
        if k == 'int':
            return INT_TYPES[t][0]
        if k == 'long':
            return 8
        if k == 'single':
            return 4
        if k == 'float':
            return 8
        if k == 'void':
            return 1
        if k == 'fun':
            return 1
        if t[0] == 'tptr':
            return 4
        if t[0] == 'tarray':
            return self.sizeof(t[1]) * max(0, t[2])
        return self.comp(t[1])['size']

    def alignof(self, t):
        k = tkind(t)
        if k == 'int':
            return INT_TYPES[t][0]
        if k in ('long', 'float'):
            return 8
        if k == 'single':
            return 4
        if k in ('void', 'fun'):
            return 1
        if t[0] == 'tptr':
            return 4
        if t[0] == 'tarray':
            return self.alignof(t[1])
        return self.comp(t[1])['align']

    def comp(self, name):
        name = str(name)
        if name in self._cache:
            return self._cache[name]
        su, members = self.composites[name]
        fields = []   # (fname, offset, type, bitfield-info or None)
        if su == 'Struct':
            pos_bits = 0
            align = 1
            for m in members:
                if m[0] == 'plain':
                    _, fname, ty = m
                    a = self.alignof(ty)
                    align = max(align, a)
                    pos_bytes = (pos_bits + 7) // 8
                    pos_bytes = (pos_bytes + a - 1) // a * a
                    fields.append((str(fname), pos_bytes, ty, None))
                    pos_bits = (pos_bytes + self.sizeof(ty)) * 8
                else:
                    # CompCert layout_field for bitfields: the field lives in
                    # a naturally-aligned storage unit of its declared size.
                    _, fname, sz, sg, width, _pad = m
                    unit = {'I8': 1, 'I16': 2, 'I32': 4, 'IBool': 1}[sz]
                    ubits = unit * 8
                    if width == 0:
                        pos_bits = (pos_bits + ubits - 1) // ubits * ubits
                        continue
                    align = max(align, unit)
                    start_unit = pos_bits // ubits
                    if (pos_bits % ubits) + width > ubits:
                        start_unit += 1
                        pos_bits = start_unit * ubits
                    ofs = start_unit * unit
                    bit_in_unit = pos_bits - start_unit * ubits
                    fields.append((str(fname), ofs, sz, ('bf', sg, bit_in_unit, width, unit)))
                    pos_bits += width
            size = (pos_bits + 7) // 8
            size = (size + align - 1) // align * align
        else:
            align = 1
            size = 0
            for m in members:
                _, fname, ty = m[:3]
                if m[0] != 'plain':
                    raise ValueError('bitfield in union')
                align = max(align, self.alignof(ty))
                size = max(size, self.sizeof(ty))
                fields.append((str(fname), 0, ty, None))
            size = (size + align - 1) // align * align
        info = {'su': su, 'size': size, 'align': align, 'fields': fields,
                'byname': {f[0]: f for f in fields}}
        self._cache[name] = info
        return info

    def field(self, comp_name, fname):
        return self.comp(comp_name)['byname'][str(fname)]

    def path_of(self, t, ofs, chunk=None):
        """Human-readable access path for byte offset `ofs` inside type t."""
        out = ''
        while True:
            k = tkind(t)
            if k in ('struct', 'union'):
                info = self.comp(t[1])
                cand = [f for f in info['fields']
                        if f[3] is None and f[1] <= ofs < f[1] + self.sizeof(f[2])]
                if not cand:
                    return out + '+%d' % ofs
                if info['su'] == 'Union' and chunk is not None:
                    pick = [f for f in cand if chunk_of(_leaf(f[2])) == chunk]
                    f = pick[0] if pick else cand[0]
                else:
                    f = cand[0]
                out += '.' + f[0]
                ofs -= f[1]
                t = f[2]
            elif k == 'ptr' and t[0] == 'tarray':
                es = self.sizeof(t[1])
                if es == 0:
                    return out + '+%d' % ofs
                out += '[%d]' % (ofs // es)
                ofs = ofs % es
                t = t[1]
            else:
                if ofs:
                    out += '+%d' % ofs
                return out

    def type_at(self, t, ofs):
        """Scalar type at byte offset ofs inside t (first union member), or None."""
        while True:
            k = tkind(t)
            if k in ('struct', 'union'):
                info = self.comp(t[1])
                cand = [f for f in info['fields']
                        if f[3] is None and f[1] <= ofs < f[1] + self.sizeof(f[2])]
                if not cand:
                    return None
                f = cand[0]
                ofs -= f[1]
                t = f[2]
            elif t[0] == 'tarray' if isinstance(t, tuple) else False:
                es = self.sizeof(t[1])
                ofs = ofs % es
                t = t[1]
            else:
                return t if ofs == 0 else None


def _leaf(t):
    while isinstance(t, tuple) and t[0] == 'tarray':
        t = t[1]
    return t


def chunk_of(t):
    """Memory chunk for By_value access of type t, or None (by reference/copy)."""
    if isinstance(t, str):
        if t in INT_TYPES:
            size, signed = INT_TYPES[t]
            if t == 'tbool':
                return 'i8u'
            return {1: 'i8', 2: 'i16', 4: 'i32'}[size] + ('' if size == 4 else ('s' if signed else 'u'))
        if t in LONG_TYPES:
            return 'i64'
        if t == 'tfloat':
            return 'f32'
        if t == 'tdouble':
            return 'f64'
        return None
    if t[0] == 'tptr':
        return 'i32'
    return None


CHUNK_SIZE = {'i8s': 1, 'i8u': 1, 'i16s': 2, 'i16u': 2, 'i32': 4, 'i64': 8, 'f32': 4, 'f64': 8}
