"""Parser for the clightgen-generated Coq files under generated/*.v.

EXPLORATORY / UNVERIFIED.  Reads the Coq text of a clightgen output file and
turns the `Definition`s into plain Python data:

  * ident table     `Definition _foo : ident := $"foo".`   -> {'_foo': 'foo'}
  * composites      `Composite _X Struct (Member_plain _f ty :: ...) noattr`
  * global vars     `Definition v_foo := {| gvar_info := ...; gvar_init := ... |}`
  * functions       `Definition f_foo := {| fn_return := ...; fn_body := ... |}`
  * global_definitions (to learn which names are External)

Terms are represented as:
  application     -> tuple (head:str, arg1, arg2, ...)
  Coq list        -> Python list   (`a :: b :: nil`)
  Coq pair        -> ('pair', a, b)
  record {| |}    -> dict
  ident constant  -> Id('foo')     (a str subclass: the C-level name)
  numbers         -> int
  other atoms     -> str           (e.g. 'tint', 'noattr', 'Oadd', 'None')

A per-TU pickle cache lives in experiments/symexec/.cache/.
"""
import os
import pickle
import re
import sys
import threading

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
GEN = os.path.join(REPO, 'generated')
CACHE = os.path.join(HERE, '.cache')
CACHE_VERSION = 3


class Id(str):
    """A resolved Clight identifier (C-level name)."""
    __slots__ = ()

    def __repr__(self):
        return 'Id(%s)' % str.__repr__(self)

    def __reduce__(self):
        return (Id, (str(self),))


# --------------------------------------------------------------------------
# Tokenizer
# --------------------------------------------------------------------------

_TOK = re.compile(r'''
    (?P<ws>\s+)
  | (?P<lrec>\{\|)
  | (?P<rrec>\|\})
  | (?P<cons>::)
  | (?P<assign>:=)
  | (?P<dstr>\$"[^"]*")
  | (?P<str>"[^"]*")
  | (?P<scope>%[A-Za-z_]+)
  | (?P<num>-?[0-9]+)
  | (?P<ident>[A-Za-z_][A-Za-z0-9_'.]*)
  | (?P<punct>[(),;:.|*])
''', re.X)


def _strip_comments(text):
    out = []
    i = 0
    depth = 0
    n = len(text)
    start = 0
    while i < n:
        if text.startswith('(*', i):
            if depth == 0:
                out.append(text[start:i])
            depth += 1
            i += 2
        elif depth and text.startswith('*)', i):
            depth -= 1
            i += 2
            if depth == 0:
                start = i
        elif depth == 0 and text[i] == '"':
            j = text.index('"', i + 1)
            i = j + 1
        else:
            i += 1
    if depth == 0:
        out.append(text[start:])
    return ''.join(out)


def tokenize(text):
    toks = []
    pos = 0
    n = len(text)
    m = _TOK.match
    while pos < n:
        mo = m(text, pos)
        if mo is None:
            raise SyntaxError('bad char %r at %d: %r' % (text[pos], pos, text[pos:pos + 40]))
        kind = mo.lastgroup
        val = mo.group(kind)
        pos = mo.end()
        if kind == 'ws':
            continue
        if kind == 'ident':
            # an identifier cannot end with '.': that is the sentence end
            trail = 0
            while val.endswith('.'):
                val = val[:-1]
                trail += 1
            toks.append(('ident', val))
            for _ in range(trail):
                toks.append(('punct', '.'))
            continue
        toks.append((kind, val))
    return toks


# --------------------------------------------------------------------------
# Term parser
# --------------------------------------------------------------------------

class _Parser:
    STOP = {')', ',', ';', '.', '|}', '::', ':=', ':'}

    def __init__(self, toks):
        self.t = toks
        self.i = 0

    def peek(self):
        return self.t[self.i] if self.i < len(self.t) else ('eof', None)

    def next(self):
        tok = self.t[self.i]
        self.i += 1
        return tok

    def expect(self, val):
        k, v = self.next()
        if v != val:
            raise SyntaxError('expected %r got %r at tok %d' % (val, v, self.i))

    def term(self):
        head = self.app()
        k, v = self.peek()
        if v == '::':
            # right-assoc list; iterate to avoid deep recursion
            items = [head]
            while self.peek()[1] == '::':
                self.next()
                items.append(self.app())
            tail = items.pop()
            if tail == 'nil':
                tail = []
            if not isinstance(tail, list):
                raise SyntaxError('list not ending in nil at tok %d' % self.i)
            return items + tail
        return head

    def app(self):
        items = [self.atom()]
        while True:
            k, v = self.peek()
            if k == 'eof' or (k in ('punct', 'cons', 'assign', 'rrec') and v in self.STOP) or v in self.STOP:
                break
            if k == 'scope':
                self.next()
                continue
            items.append(self.atom())
        if len(items) == 1:
            return items[0]
        return tuple(items)

    def atom(self):
        k, v = self.next()
        if k == 'punct' and v == '(':
            first = self.term()
            if self.peek()[1] == ',':
                parts = [first]
                while self.peek()[1] == ',':
                    self.next()
                    parts.append(self.term())
                self.expect(')')
                r = parts[-1]
                for p in reversed(parts[:-1]):
                    r = ('pair', p, r)
                return r
            self.expect(')')
            return first
        if k == 'lrec':
            d = {}
            while True:
                fk, fv = self.next()
                self.expect(':=')
                d[fv] = self.term()
                k2, v2 = self.next()
                if v2 == '|}':
                    break
                if v2 != ';':
                    raise SyntaxError('record: got %r' % v2)
            return d
        if k == 'num':
            return int(v)
        if k == 'dstr':
            return ('$', v[2:-1])
        if k == 'str':
            return ('str', v[1:-1])
        if k == 'punct' and v == '*':
            return '*'
        if k == 'ident':
            if v == 'nil':
                return 'nil'
            return v
        raise SyntaxError('unexpected token %r %r at %d' % (k, v, self.i))


def _resolve(t, idmap):
    """Replace ident constants by Id(name), 'nil' by []."""
    stack = []

    def go(x):
        if isinstance(x, str):
            if x in idmap:
                return Id(idmap[x])
            if x == 'nil':
                return []
            return x
        if isinstance(x, tuple):
            return tuple(go(a) for a in x)
        if isinstance(x, list):
            return [go(a) for a in x]
        if isinstance(x, dict):
            return {k: go(a) for k, a in x.items()}
        return x
    return go(t)


def parse_definitions(text):
    """Yield (name, term) for each top-level `Definition`."""
    toks = tokenize(_strip_comments(text))
    p = _Parser(toks)
    n = len(toks)
    while p.i < n:
        k, v = p.next()
        if k == 'ident' and v == 'Definition':
            name = p.next()[1]
            if p.peek()[1] == ':':
                p.next()
                p.term()  # the type, ignored
            p.expect(':=')
            body = p.term()
            p.expect('.')
            yield name, body
        # everything else (From/Import/Module/End/...) is skipped token by token


# --------------------------------------------------------------------------
# TU loading
# --------------------------------------------------------------------------

class TU:
    def __init__(self, name):
        self.name = name
        self.idents = {}        # '_foo' -> 'foo'
        self.composites = {}    # 'MarioState' -> ('Struct'|'Union', [(kind, fname, ty, ...)])
        self.gvars = {}         # 'foo' -> dict(gvar_info, gvar_init, ...)
        self.functions = {}     # 'foo' -> dict(fn_return, fn_params, ...)
        self.externals = {}     # 'foo' -> term of the External
        self.internal_names = set()


def _load_tu_uncached(name):
    path = os.path.join(GEN, name + '.v')
    with open(path) as f:
        text = f.read()
    tu = TU(name)
    defs = list(parse_definitions(text))
    for dname, body in defs:
        if isinstance(body, tuple) and body[0] == '$':
            tu.idents[dname] = body[1]
        elif isinstance(body, int) and dname.startswith('_'):
            # numeric idents (temps): the C name is the Coq name minus '_'
            tu.idents[dname] = dname[1:]
    idmap = tu.idents
    for dname, body in defs:
        if dname.startswith('f_') and isinstance(body, dict):
            tu.functions[dname[2:]] = _resolve(body, idmap)
        elif dname.startswith('v_') and isinstance(body, dict):
            tu.gvars[dname[2:]] = _resolve(body, idmap)
        elif dname == 'composites':
            for c in _resolve(body, idmap):
                # ('Composite', Id, 'Struct', [members], 'noattr')
                _, cname, su, members, _attr = c
                mems = []
                for mm in members:
                    if mm[0] == 'Member_plain':
                        mems.append(('plain', mm[1], mm[2]))
                    elif mm[0] == 'Member_bitfield':
                        # Member_bitfield id sz sg attr width padding
                        mems.append(('bitfield', mm[1], mm[2], mm[3], mm[5], mm[6]))
                    else:
                        raise ValueError(mm)
                tu.composites[str(cname)] = (su, mems)
        elif dname == 'global_definitions':
            for pr in _resolve(body, idmap):
                _, gid, gdef = pr
                if isinstance(gdef, tuple) and gdef[0] == 'Gfun':
                    fd = gdef[1]
                    if isinstance(fd, tuple) and fd[0] == 'External':
                        tu.externals[str(gid)] = fd
                    else:
                        tu.internal_names.add(str(gid))
    return tu


def load_tu(name, use_cache=True):
    src = os.path.join(GEN, name + '.v')
    cpath = os.path.join(CACHE, '%s.v%d.pickle' % (name, CACHE_VERSION))
    if use_cache and os.path.exists(cpath) and os.path.getmtime(cpath) >= os.path.getmtime(src):
        with open(cpath, 'rb') as f:
            return pickle.load(f)
    tu = _load_tu_uncached(name)
    os.makedirs(CACHE, exist_ok=True)
    with open(cpath, 'wb') as f:
        pickle.dump(tu, f, protocol=pickle.HIGHEST_PROTOCOL)
    return tu


FRAME_TUS = [
    'mario', 'mario_step',
    'mario_actions_stationary', 'mario_actions_moving', 'mario_actions_airborne',
    'mario_actions_submerged', 'mario_actions_cutscene', 'mario_actions_automatic',
    'mario_actions_object', 'interaction', 'behavior_actions', 'level_update',
]


def run_with_big_stack(fn, *args):
    """Run fn in a thread with a large stack (deeply nested Clight terms)."""
    sys.setrecursionlimit(1000000)
    threading.stack_size(512 * 1024 * 1024)
    box = {}

    def target():
        try:
            box['r'] = fn(*args)
        except BaseException as e:  # re-raised in caller
            import traceback
            box['tb'] = traceback.format_exc()
            box['e'] = e
    th = threading.Thread(target=target)
    th.start()
    th.join()
    if 'e' in box:
        sys.stderr.write(box['tb'])
        raise box['e']
    return box.get('r')


class Program:
    """The union of several TUs: functions, globals, composites."""

    def __init__(self, tus=FRAME_TUS):
        self.tus = [load_tu(t) for t in tus]
        self.functions = {}
        self.fun_tu = {}
        self.gvars = {}
        self.composites = {}
        self.externals = {}
        for tu in self.tus:
            for k, v in tu.functions.items():
                if k in self.functions:
                    # static helpers with the same name in two TUs: keep first,
                    # remember the clash
                    self.fun_tu.setdefault(k + '@clash', []).append(tu.name)
                    continue
                self.functions[k] = v
                self.fun_tu[k] = tu.name
            for k, v in tu.gvars.items():
                # prefer a definition that has an initializer
                if k not in self.gvars or (not self.gvars[k].get('gvar_init') and v.get('gvar_init')):
                    self.gvars[k] = v
            for k, v in tu.composites.items():
                self.composites.setdefault(k, v)
            for k, v in tu.externals.items():
                self.externals.setdefault(k, v)
        for k in list(self.externals):
            if k in self.functions:
                del self.externals[k]


def _cli():
    import time
    names = sys.argv[1:] or FRAME_TUS

    def main():
        for n in names:
            t0 = time.time()
            tu = load_tu(n, use_cache=False)
            print('%-28s %5d fns %5d gvars %4d composites %5d externals  %.1fs' % (
                n, len(tu.functions), len(tu.gvars), len(tu.composites),
                len(tu.externals), time.time() - t0))
    run_with_big_stack(main)


if __name__ == '__main__':
    # re-import so pickled classes live in module `clight_parse`, not `__main__`
    sys.path.insert(0, HERE)
    import clight_parse
    clight_parse._cli()
