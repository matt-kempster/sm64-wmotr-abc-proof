"""Function lookup from the emitted global definitions, including externals.

This is an executable index of a selected linkage, not a proof that arbitrary
gameplay retains a particular behavior script. Indirect calls test the live
pointer against every compatible symbol in that linkage. External declarations
remain present: absence of a body cannot silently shrink the pointer domain.
"""
from dataclasses import dataclass
import re
from clight import ROOT, Term


@dataclass(frozen=True)
class FunctionSymbol:
    name: str
    unit: str
    signature: Term
    internal: bool
    body: str | None = None
    external: Term | None = None


class ProgramImage:
    def __init__(self, engine, modules=None):
        self.engine = engine
        if modules is None:
            paths = list((ROOT/'generated').glob(engine.version+'_*.v'))
            if engine.runtime_audio:
                paths += list((ROOT/'generated/runtime').glob(engine.version+'_*.v'))
            modules = []
            for path in sorted(paths):
                relative = path.relative_to(ROOT/'generated')
                parent = relative.parent.as_posix()
                modules.append(('' if parent=='.' else parent+'/') + path.stem[len(engine.version)+1:])
            modules.extend(sorted(getattr(engine, 'source_paths', {})))
        self.modules = tuple(modules)
        self.symbols = {}
        self.declarations = {}
        for module in self.modules:
            unit = engine.unit(module)
            for identifier, definition in unit.global_definitions().items():
                if definition.tag != 'Gfun':
                    continue
                fundef = definition.args[0]
                name = identifier.removeprefix('_')
                if fundef.tag == 'Internal':
                    body = fundef.args[0].tag.removeprefix('f_')
                    entry = FunctionSymbol(name, module, unit.function_signature(body), True, body)
                elif fundef.tag == 'External':
                    ef, args, result, cc = fundef.args
                    entry = FunctionSymbol(name, module, Term('Tfunction', (args, result, cc)), False, external=ef)
                else:
                    raise ValueError('Unsupported emitted fundef: '+str(fundef))
                self.declarations.setdefault(name, []).append(entry)
                old = self.symbols.get(name)
                if old is not None:
                    if self.signature_key(old.signature, engine.unit(old.unit)) != self.signature_key(entry.signature, unit):
                        raise ValueError('Conflicting generated signatures for '+name+': '+old.unit+' / '+module)
                    if old.internal and entry.internal and (old.unit, old.body) != (entry.unit, entry.body):
                        raise ValueError('Duplicate generated internal symbol: '+name)
                if old is None or entry.internal:
                    self.symbols[name] = entry
        # Addresses are a stable, injective encoding in the explorer. This does
        # not equate them with ROM addresses or establish CompCert provenance.
        self.addresses = {name: 0x70000000 + 16*i for i,name in enumerate(sorted(self.symbols))}

    @staticmethod
    def signature_key(term, unit):
        # clightgen assigns different fresh names to the same anonymous C
        # header composite in different translation units. Compare the full
        # member structure for those tags, never just size or pointer ABI.
        # Named composites retain their names. This is an explorer linkage
        # check, not a discharge of the existing Coq signature-view residuals.
        if term.tag in ('Tstruct', 'Tunion') and re.fullmatch(r'__\d+', term.args[0].tag):
            kind, members = unit.composites[term.args[0].tag]
            return (term.tag, kind, tuple(ProgramImage.signature_key(m, unit) for m in members), str(term.args[1]))
        return (term.tag, tuple(ProgramImage.signature_key(a, unit) for a in term.args))

    def compatible(self, signature, unit=None):
        if signature.tag == 'tptr':
            signature = signature.args[0]
        if signature.tag != 'Tfunction':
            raise ValueError('Indirect call has no function type: '+str(signature))
        if unit is None:
            return [entry for entry in self.symbols.values() if entry.signature == signature]
        key = self.signature_key(signature, unit)
        return [entry for entry in self.symbols.values()
                if self.signature_key(entry.signature, self.engine.unit(entry.unit)) == key]

    def address(self, name):
        if name not in self.addresses:
            raise ValueError('No function symbol in selected linkage: '+name)
        return self.addresses[name]
