"""Compact symbolic addresses from actual generated global declarations.

No initializer bytes or read-only/persistence facts are assumed here. The
addresses are explorer names, not retail addresses. Incomplete external arrays
retain an explicit unknown-extent obligation; their reservation is not a
memory-validity proof.
"""
import re
from clight import parse, Term
from engine import STATE, Unsupported


class GlobalStorage:
    def __init__(self, units):
        self.layouts = {}
        self.addresses = {}
        self.reservations = {}
        self.next_address = 0x10000000
        self.unknown_extents = set()
        for unit in units:
            headers = {name:parse(ty) for name,ty in re.findall(
                r'Definition (v_\w+) := \{\|\s*gvar_info :=\s*(.*?);\s*gvar_init',unit.text,re.S)}
            for name,definition in unit.global_definitions().items():
                if definition.tag != 'Gvar':continue
                ty=storage_type(headers[definition.args[0].tag])
                try:size,align=unit.size(ty)
                except KeyError:size,align=0,16  # incomplete external composite
                old=self.layouts.get(name,(0,1))
                self.layouts[name]=(max(old[0],size),max(old[1],align))

    def address(self, name):
        if name == '_gMarioStates':return STATE
        if name in self.addresses:return self.addresses[name]
        if name not in self.layouts:
            raise Unsupported('Global absent from selected generated linkage: '+name)
        size,align=self.layouts[name]
        if size == 0:
            self.unknown_extents.add(name)
            size=0x100000
        align=max(align,16)
        base=(self.next_address+align-1)//align*align
        # Keep the old local arena, code and fresh-call stack separate.
        if base+size>0x20000000:
            raise Unsupported('Compact global reservation exceeds its arena')
        self.addresses[name]=base
        self.reservations[name]=(base,size,align)
        self.next_address=base+size
        return base

    def receipt(self):
        return dict(allocated=len(self.addresses),reservedBytes=self.next_address-0x10000000,
                    unknownExtents=sorted(self.unknown_extents),
                    interpretation='Symbolic address packing only; no initializer, runtime frame or provenance proof.')


def storage_type(ty):
    # Volatility affects reads/writes, not sizeof. This helper is used only
    # for reservation size; it never changes an executed expression's type.
    if ty.tag=='tvolatile':return storage_type(ty.args[0])
    return Term(ty.tag,tuple(storage_type(a) for a in ty.args))
