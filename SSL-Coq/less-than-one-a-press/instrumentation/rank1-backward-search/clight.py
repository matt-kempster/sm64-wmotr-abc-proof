"""Read the committed clightgen terms. Unsupported syntax fails closed.

This is a parser for the emitted constructor notation, not a C reimplementation.
Function bodies and composite layouts are both taken from generated/*.v.
"""
from dataclasses import dataclass
from functools import lru_cache
import hashlib
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


@dataclass(frozen=True)
class Term:
    tag: str
    args: tuple = ()

    def __str__(self):
        return self.tag if not self.args else '(' + self.tag + ' ' + ' '.join(map(str, self.args)) + ')'


class Parser:
    def __init__(self, text):
        # Keep an explicit attribute term. Recognizing an unused volatile
        # bit-field declaration does not authorize evaluating its accesses.
        text = re.sub(r'\{\|\s*attr_volatile\s*:=\s*(true|false);\s*attr_alignas\s*:=\s*None\s*\|\}',
                      r'(Attributes \1 None)', text)
        text = re.sub(r'\{\|\s*cc_vararg\s*:=\s*(.*?);\s*cc_unproto\s*:=\s*(true|false);\s*cc_structret\s*:=\s*(true|false)\s*\|\}',
                      r'(CallingConvention (\1) \2 \3)', text)
        token_pattern = r'"(?:[^"\\]|\\.)*"|::|[(),]|-?\d+|[A-Za-z_][A-Za-z_0-9\'.]*'
        self.tokens = re.findall(token_pattern, text)
        residue = re.sub(token_pattern + r'|\s+', '', text)
        if residue:
            raise ValueError('Unsupported generated syntax: ' + residue[:80])
        self.i = 0

    def atom(self):
        token = self.tokens[self.i]
        self.i += 1
        if token == '(':
            value = self.expr()
            if self.tokens[self.i] != ')':
                raise ValueError('Unclosed generated term')
            self.i += 1
            return value
        if token in (')', ',', '::'):
            raise ValueError('Unexpected token: ' + token)
        return Term(token)

    def application(self):
        values = []
        while self.i < len(self.tokens) and self.tokens[self.i] not in (')', ',', '::'):
            values.append(self.atom())
        if not values:
            raise ValueError('Empty generated term')
        if len(values) > 1:
            if values[0].args:
                raise ValueError('Unsupported higher-order application')
            value = Term(values[0].tag, tuple(values[1:]))
        else:
            value = values[0]
        return value

    def expr(self):
        # Emitted global tables can have thousands of entries. Build their
        # right-associated list spine iteratively instead of using one Python
        # stack frame per entry. Parenthesized application precedence stays
        # identical to the original reader.
        values = [self.application()]
        operators = []
        while self.i < len(self.tokens) and self.tokens[self.i] in ('::', ','):
            operators.append(self.tokens[self.i])
            self.i += 1
            values.append(self.application())
        value = values.pop()
        for op, left in zip(reversed(operators), reversed(values)):
            value = Term('cons' if op == '::' else 'pair', (left, value))
        return value


def parse(text):
    p = Parser(text)
    value = p.expr()
    if p.i != len(p.tokens):
        raise ValueError('Trailing generated syntax')
    return value


def items(term):
    result = []
    while term.tag == 'cons':
        head, term = term.args
        result.append(head)
    if term.tag != 'nil':
        raise ValueError('Expected generated list, got ' + str(term))
    return result


def walk(term, path=()):
    yield path, term
    for i, child in enumerate(term.args):
        yield from walk(child, path + (i,))


def sequence(term):
    if term.tag == 'Ssequence':
        return sequence(term.args[0]) + sequence(term.args[1])
    return [term]


def outer_items(term):
    result = []
    while term.tag == 'Ssequence':
        result.append(term.args[0])
        term = term.args[1]
    return result + [term]


def seq(terms):
    if not terms:
        return Term('Sskip')
    result = terms[-1]
    for term in reversed(terms[:-1]):
        result = Term('Ssequence', (term, result))
    return result


@dataclass
class Function:
    unit: object
    name: str
    body: Term
    params: dict
    locals: dict
    temps: dict
    returns: Term
    line: int
    digest: str


class Unit:
    def __init__(self, version, name, source_path=None):
        directory, _, stem = name.rpartition('/')
        self.path = Path(source_path) if source_path is not None else ROOT / 'generated' / directory / (version + '_' + stem + '.v')
        self.text = self.path.read_text(encoding='utf-8')
        self.digest = hashlib.sha256(self.text.encode()).hexdigest()
        match = re.search(r'Definition composites : list composite_definition :=\s*(.*?)\.\s*Definition', self.text, re.S)
        if not match:
            raise ValueError('Missing generated composite list')
        self.composites = {}
        self.bitfields = {}
        for c in items(parse(match[1])):
            if c.tag != 'Composite' or c.args[3].tag != 'noattr':
                raise ValueError('Unsupported composite attributes')
            self.composites[c.args[0].tag] = (c.args[1].tag, items(c.args[2]))

    @lru_cache(None)
    def global_definitions(self):
        match = re.search(r'Definition global_definitions :.*?:=\s*(.*?)\.\s*Definition public_idents', self.text, re.S)
        if not match:
            raise ValueError('Missing generated global definitions: '+str(self.path))
        return {p.args[0].tag: p.args[1] for p in items(parse(match[1]))}

    @lru_cache(None)
    def function_signature(self, name):
        match = re.search(r'Definition f_' + re.escape(name) + r' := \{\|(.*?)fn_body :=', self.text, re.S)
        if not match:
            raise ValueError('Missing generated function header: '+name)
        fields = dict(re.findall(r'(fn_\w+) :=\s*(.*?)(?:;\s*(?=fn_\w+ :=)|\Z)', match[1], re.S))
        parameters = [p.args[1] for p in items(parse(fields['fn_params']))]
        types = Term('nil')
        for ty in reversed(parameters):
            types = Term('cons', (ty, types))
        return Term('Tfunction', (types, parse(fields['fn_return']), parse(fields['fn_callconv'])))

    @lru_cache(None)
    def function(self, name, defer_body=False):
        match = re.search(r'Definition f_' + re.escape(name) + r' := \{\|(.*?)\|\}\.', self.text, re.S)
        if not match:
            raise ValueError('Missing generated function: ' + name)
        fields = dict(re.findall(r'(fn_\w+) :=\s*(.*?)(?:;\s*(?=fn_\w+ :=)|\Z)', match[1], re.S))
        def bindings(key):
            return {p.args[0].tag:p.args[1] for p in items(parse(fields[key]))}
        return Function(self, name, None if defer_body else parse(fields['fn_body']), bindings('fn_params'),
                        bindings('fn_vars'), bindings('fn_temps'), parse(fields['fn_return']),
                        self.text.count('\n', 0, match.start())+1,
                        hashlib.sha256(match[0].encode()).hexdigest())

    @lru_cache(None)
    def layout(self, tag):
        kind, members = self.composites[tag]
        position, alignment, offsets = 0, 1, {}
        bitfields = {}
        for member in members:
            if member.tag == 'Member_bitfield':
                field, size_tag, signed, attr, width_term, padding = member.args
                unit = {'I8':8, 'IBool':8, 'I16':16, 'I32':32}[size_tag.tag]
                width = int(width_term.tag)
                if width < 0 or width > unit:
                    raise ValueError('Invalid bit-field width')
                if padding.tag != 'true':
                    alignment = max(alignment,unit//8)
                start = 0 if kind == 'Union' else (position//unit)*unit
                if position+width > start+unit and kind == 'Struct':
                    start += unit
                if width > 0 and padding.tag != 'true':
                    bitfields[field.tag] = (start//8,unit,0 if kind == 'Union' or start > position else position-start,width,signed.tag,attr)
                # Ctypes.next_field. Accesses still reject bit-fields below;
                # this supplies the offsets of subsequent ordinary members.
                if kind == 'Union':
                    position = max(position,unit)
                elif width == 0:
                    position = ((position+unit-1)//unit)*unit
                elif position+width <= (position//unit+1)*unit:
                    position += width
                else:
                    position = (position//unit+1)*unit+width
                continue
            field, ty = member.args
            width, align = self.size(ty)
            alignment = max(alignment, align)
            offset = ((position+8*align-1)//(8*align))*align if kind == 'Struct' else 0
            offsets[field.tag] = offset
            position = 8*(offset+width) if kind == 'Struct' else max(position,8*width)
        size = (position+7)//8
        self.bitfields[tag] = bitfields
        return ((size+alignment-1)//alignment)*alignment, alignment, offsets

    def bitfield(self, ty, field):
        if ty.tag not in ('Tstruct','Tunion'):
            return None
        self.layout(ty.args[0].tag)
        return self.bitfields[ty.args[0].tag].get(field)

    def size(self, ty):
        if ty.tag in ('tptr', 'tint', 'tuint', 'tfloat'): return 4, 4
        if ty.tag in ('tshort', 'tushort'): return 2, 2
        if ty.tag in ('tchar', 'tschar', 'tuchar', 'tbool'): return 1, 1
        if ty.tag in ('tdouble', 'tlong', 'tulong'): return 8, 8
        if ty.tag in ('Tstruct', 'Tunion'):
            size, align, _ = self.layout(ty.args[0].tag)
            return size, align
        if ty.tag == 'tarray':
            size, align = self.size(ty.args[0])
            return size * int(ty.args[1].tag), align
        raise ValueError('Unsupported type layout: ' + str(ty))

    def field_offset(self, ty, field):
        if ty.tag not in ('Tstruct', 'Tunion'): raise ValueError(str(ty))
        if any(m.tag == 'Member_bitfield' and m.args[0].tag == field for m in self.composites[ty.args[0].tag][1]):
            raise ValueError('Bit-field access is not implemented: '+field)
        return self.layout(ty.args[0].tag)[2][field]
