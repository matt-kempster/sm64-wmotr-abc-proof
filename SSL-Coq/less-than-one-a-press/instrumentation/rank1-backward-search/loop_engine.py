"""Merged backward conditions and finite-execution semantics for Clight loops.

A recursive definition has a decreasing natural-number fuel argument. A loop
predecessor existentially chooses finite fuel; it cannot use a cyclic solution
of an unguarded recursive Boolean equation. This describes terminating runs,
not a claim that arbitrary memory contains a terminating/valid live list.
There is no fixed node cutoff and no replacement of a callee by a free result.
This remains exploratory SMT tooling, not a verified CompCert interpreter.
"""
from dataclasses import replace
import re
from itertools import count

from clight import ROOT, Term, seq, walk
from engine import Path, Unsupported, MEM, word, truth, read, write, z
from benchmark_updates import StrictEngine


def get_vars(expression):
    """Visit a shared formula DAG once, including bodies of quantifiers."""
    pending, seen, result = [expression], set(), []
    while pending:
        node = pending.pop()
        key = node.get_id()
        if key in seen:
            continue
        seen.add(key)
        if z.is_const(node) and node.decl().kind() == z.Z3_OP_UNINTERPRETED:
            result.append(node)
        elif z.is_quantifier(node):
            pending.append(node.body())
        elif z.is_app(node):
            pending.extend(node.children())
    return result


def merge(paths):
    if not paths:
        return [Path(z.BoolVal(False))]
    if len(paths) == 1:
        return paths
    # Preserve the formula, not an exponentially large list of syntax routes.
    return [Path(z.Or(*[p.condition for p in paths]),
                 calls=tuple(dict.fromkeys(c for p in paths for c in p.calls)))]


def derived_loop(statement):
    """Installed CompCert 3.15 Clight.v definitions, including argument order."""
    a=statement.args
    if statement.tag == 'Sdowhile':
        body,condition=a
        return Term('Sloop',(body,Term('Sifthenelse',(condition,Term('Sskip'),Term('Sbreak')))))
    if statement.tag == 'Sfor':
        init,condition,body,increment=a
        guarded=Term('Ssequence',(Term('Sifthenelse',(condition,Term('Sskip'),Term('Sbreak'))),body))
        return Term('Ssequence',(init,Term('Sloop',(guarded,increment))))
    raise Unsupported('Not a derived loop: '+statement.tag)


def initialized_temporaries(function):
    """Conservative source check before eliminating callee-local entry temps.

    It never supplies a value to an actually uninitialized source read. Loops
    are checked from their entry facts (also valid on subsequent iterations).
    The analysis is deliberately conservative at a switch or loop exit.
    """
    def reads(expr, known):
        missing = {n.args[0].tag for _,n in walk(expr) if n.tag == 'Etempvar'} - known
        if missing:
            raise Unsupported(function.name+' reads uninitialized temps: '+str(sorted(missing)))
    def check(st, known, breaks=None, continues=None):
        tag,a = st.tag,st.args
        if tag == 'Ssequence':
            after = check(a[0],known,breaks,continues)
            return None if after is None else check(a[1],after,breaks,continues)
        if tag == 'Sset':
            reads(a[1],known)
            return known | {a[0].tag}
        if tag == 'Scall':
            reads(a[1],known); reads(a[2],known)
            return known | ({a[0].args[0].tag} if a[0].tag == 'Some' else set())
        if tag == 'Sassign':
            reads(a[0],known); reads(a[1],known)
            return known
        if tag == 'Sifthenelse':
            reads(a[0],known)
            left,right = check(a[1],known,breaks,continues),check(a[2],known,breaks,continues)
            return right if left is None else left if right is None else left & right
        if tag == 'Sreturn':
            reads(a[0],known)
            return None
        if tag in ('Sbreak','Scontinue'):
            exits = breaks if tag == 'Sbreak' else continues
            if exits is None:
                raise Unsupported('Definite-assignment check: unmatched '+tag)
            exits.append(known)
            return None
        if tag == 'Sskip':
            return known
        if tag in ('Sdowhile','Sfor'):
            return check(derived_loop(st),known,breaks,continues)
        if tag == 'Swhile':
            guarded=Term('Ssequence',(Term('Sifthenelse',(a[0],Term('Sskip'),Term('Sbreak'))),a[1]))
            return check(Term('Sloop',(guarded,Term('Sskip'))),known,breaks,continues)
        if tag == 'Sloop':
            loop_breaks,loop_continues=[],[]
            after=check(a[0],known,loop_breaks,loop_continues)
            entries=loop_continues+([] if after is None else [after])
            if entries:
                # Both ordinary completion and continue execute increment.
                check(a[1],set.intersection(*entries),loop_breaks,[])
            # Forget new facts at a loop exit. This is conservative; it does
            # not assume a body executes or terminates.
            return known
        if tag == 'Sswitch':
            reads(a[0],known)
            rest = a[1]
            while rest.tag == 'LScons':
                check(rest.args[1],known,[],continues)
                rest = rest.args[2]
            return known
        raise Unsupported('Definite-assignment check: '+tag)
    return check(function.body,set(function.params))


class LoopEngine(StrictEngine):
    serials = count()
    def __init__(self, version, *, auto_calls=False, runtime_audio=False, loop_fuel=None, **kwargs):
        super().__init__(version, **kwargs)
        self.auto_calls = auto_calls
        self.runtime_audio = runtime_audio
        self.loop_fuel = loop_fuel
        self.serial = next(self.serials)
        self.continues = []
        self.loops = []
        self.definitions = []
        self.symbol_sources = None
        self.initialization_checked = set()

    def close_scope(self, paths, child):
        fn = child.function
        if fn.digest not in self.initialization_checked:
            initialized_temporaries(fn)
            self.initialization_checked.add(fn.digest)
        # The generated body never reads these entry values. Recursive loop
        # signatures may still carry unused ones; remove them at function entry
        # instead of accidentally freezing a child temp across its caller loop.
        pairs = []
        for name in fn.temps.keys()-fn.params.keys():
            temp = child.temps[name]
            zero = z.FPVal(0,temp.sort()) if z.is_fp(temp) else z.BitVecVal(0,temp.size())
            pairs.append((temp,zero))
        # result is a meta-variable substituted by each Sreturn, never a
        # Clight temporary available for an entry read. Unused recursive
        # signature arguments can therefore be canonicalized as well.
        result = child.result
        zero = z.FPVal(0,result.sort()) if z.is_fp(result) else z.BitVecVal(0,result.size())
        pairs.append((result,zero))
        return self.substitute(paths,*pairs)

    @staticmethod
    def substitute(paths, *pairs):
        # simplify at every substitution repeatedly traversed growing DAGs.
        return [replace(p, condition=z.substitute(p.condition, *pairs)) for p in paths]

    @staticmethod
    def guard(paths, condition, decision):
        return [replace(p, condition=z.And(condition, p.condition)) for p in paths]

    def wp(self, statement, normal, scope, returned=None, broken=None, path='body'):
        return merge(super().wp(statement, merge(normal), scope,
                               None if returned is None else merge(returned),
                               None if broken is None else merge(broken), path))

    def resolve_call(self, name, scope):
        if self.symbol_sources is None:
            self.symbol_sources = {}
            sources = list((ROOT/'generated').glob(self.version+'_*.v'))
            if self.runtime_audio:
                # Explicit exploratory source linkage, not a claim that the
                # Coq selected_clight_target's external oracle was refined.
                sources += list((ROOT/'generated/runtime').glob(self.version+'_*.v'))
            for source in sorted(sources):
                parent = source.parent.relative_to(ROOT/'generated').as_posix()
                key = (parent+'/' if parent != '.' else '') + source.stem[len(self.version)+1:]
                for symbol in re.findall(r'Definition f_(\w+) :=', source.read_text(encoding='utf-8')):
                    self.symbol_sources.setdefault(symbol, []).append(key)
        matches = self.symbol_sources.get(name, [])
        current = scope.function.unit.path.stem[len(self.version)+1:]
        if current in matches:
            return current
        if len(matches) == 1:
            return matches[0]
        raise Unsupported('Missing/ambiguous original body for '+name+': '+str(matches))

    def eval(self, expr, scope):
        if expr.tag == 'Efield':
            base, field, ty = expr.args
            info = scope.function.unit.bitfield(self.typeof(base),field.tag)
            if info:
                offset, unit, pos, width, signed, attr = info
                storage = read(MEM,self.location(base,scope)+word(offset),unit//8)
                # The explorer's byte memory is big endian (N64). This is not
                # an assertion about a different CompCert target's Archi flag.
                value = z.Extract(unit-pos-1,unit-pos-width,storage)
                return (z.SignExt if signed == 'Signed' else z.ZeroExt)(32-width,value)
        if expr.tag == 'Econst_long':
            return z.BitVecVal(int(expr.args[0].args[0].tag), 64)
        if expr.tag == 'Econst_float':
            return z.fpBVToFP(z.BitVecVal(int(expr.args[0].args[0].args[0].tag),64),z.Float64())
        if expr.tag == 'Ebinop':
            op, le, re, ty = expr.args
            lt, rt = self.typeof(le), self.typeof(re)
            if op.tag in ('Oshl','Oshr'):
                left,right = self.eval(le,scope),self.eval(re,scope)
                width = left.size()
                self.conversion_guards[-1].append(z.ULT(right,z.BitVecVal(width,right.size())))
                if right.size() < width: right=z.ZeroExt(width-right.size(),right)
                if right.size() > width: right=z.Extract(width-1,0,right)
                if op.tag == 'Oshl': return left << right
                return z.LShR(left,right) if lt.tag in ('tuint','tulong') else left >> right
            if (lt.tag in ('tlong','tulong') or rt.tag in ('tlong','tulong')) and lt.tag not in ('tptr','tfloat','tdouble') and rt.tag not in ('tptr','tfloat','tdouble'):
                # C usual arithmetic conversion: unsigned long long wins;
                # signed long long represents every 32-bit unsigned value.
                unsigned='tulong' in (lt.tag,rt.tag)
                common=Term('tulong' if unsigned else 'tlong')
                left=self.cast(self.eval(le,scope),lt,common)
                right=self.cast(self.eval(re,scope),rt,common)
                if op.tag in ('Odiv','Omod'):
                    valid=right!=z.BitVecVal(0,64)
                    if not unsigned:
                        valid=z.And(valid,z.Not(z.And(left==z.BitVecVal(1<<63,64),right==z.BitVecVal(-1,64))))
                    self.conversion_guards[-1].append(valid)
                    if op.tag=='Odiv':return z.UDiv(left,right) if unsigned else left/right
                    return z.URem(left,right) if unsigned else z.SRem(left,right)
                operations={'Oadd':lambda a,b:a+b,'Osub':lambda a,b:a-b,'Omul':lambda a,b:a*b,
                            'Oand':lambda a,b:a&b,'Oor':lambda a,b:a|b,'Oxor':lambda a,b:a^b}
                if op.tag in operations:return operations[op.tag](left,right)
                comparisons={'Oeq':lambda a,b:a==b,'One':lambda a,b:a!=b,
                    'Olt':z.ULT if unsigned else lambda a,b:a<b,
                    'Ole':z.ULE if unsigned else lambda a,b:a<=b,
                    'Ogt':z.UGT if unsigned else lambda a,b:a>b,
                    'Oge':z.UGE if unsigned else lambda a,b:a>=b}
                if op.tag in comparisons:return z.If(comparisons[op.tag](left,right),word(1),word(0))
                raise Unsupported('64-bit arithmetic operation '+op.tag)
            if lt.tag in ('tfloat','tdouble') or rt.tag in ('tfloat','tdouble'):
                dest = Term('tdouble' if 'tdouble' in (lt.tag,rt.tag) else 'tfloat')
                left = self.cast(self.eval(le,scope),lt,dest)
                right = self.cast(self.eval(re,scope),rt,dest)
                arithmetic = {'Oadd':z.fpAdd,'Osub':z.fpSub,'Omul':z.fpMul,'Odiv':z.fpDiv}
                if op.tag in arithmetic:
                    return arithmetic[op.tag](z.RNE(),left,right)
                comparisons = {'Oeq':z.fpEQ,'One':lambda a,b:z.Not(z.fpEQ(a,b)),
                    'Olt':z.fpLT,'Ole':z.fpLEQ,'Ogt':z.fpGT,'Oge':z.fpGEQ}
                if op.tag not in comparisons:
                    raise Unsupported('Floating operation '+op.tag)
                return z.If(comparisons[op.tag](left,right),word(1),word(0))
        if expr.tag == 'Ebinop' and expr.args[0].tag in ('Odiv', 'Omod'):
            op, le, re, ty = expr.args
            if ty.tag in ('tint', 'tuint'):
                left, right = self.eval(le, scope), self.eval(re, scope)
                unsigned = ty.tag == 'tuint'
                valid = right != word(0)
                if not unsigned:
                    valid = z.And(valid, z.Not(z.And(left == word(0x80000000), right == word(-1))))
                self.conversion_guards[-1].append(valid)
                if op.tag == 'Odiv':
                    return z.UDiv(left, right) if unsigned else left / right
                return z.URem(left, right) if unsigned else z.SRem(left, right)
        return super().eval(expr, scope)

    def load(self, address, ty, unit):
        if ty.tag in ('tlong','tulong','tdouble'):
            value = read(MEM,address,8)
            return z.fpBVToFP(value,z.Float64()) if ty.tag == 'tdouble' else value
        return super().load(address,ty,unit)

    def cast(self, value, source, target):
        if source.tag == 'tvolatile': source = source.args[0]
        if target.tag == 'tvolatile': target = target.args[0]
        if target.tag == 'tbool':
            return z.If(truth(value),word(1),word(0))
        if target.tag in ('tfloat','tdouble'):
            sort = z.Float32() if target.tag == 'tfloat' else z.Float64()
            if z.is_fp(value):
                return value if value.sort() == sort else z.fpToFP(z.RNE(),value,sort)
            return (z.fpUnsignedToFP if source.tag in ('tuint','tushort','tuchar','tulong','tbool') else z.fpSignedToFP)(z.RNE(),value,sort)
        if z.is_fp(value) and target.tag in ('tint','tuint','tshort','tushort','tchar','tschar','tuchar','tlong','tulong'):
            width = 64 if target.tag in ('tlong','tulong') else 32
            unsigned = target.tag in ('tuint','tushort','tuchar','tulong')
            lo, hi = (0,2**width) if unsigned else (-2**(width-1),2**(width-1))
            integral = z.fpRoundToIntegral(z.RTZ(),value)
            valid = z.And(z.Not(z.fpIsNaN(value)),z.Not(z.fpIsInf(value)),
                          z.fpGEQ(integral,z.FPVal(lo,value.sort())),
                          z.fpLT(integral,z.FPVal(hi,value.sort())))
            if not self.conversion_guards:
                raise Unsupported('Float conversion outside a guarded statement')
            self.conversion_guards[-1].append(valid)
            self.float_integer_conversions += 1
            converted = (z.fpToUBV if unsigned else z.fpToSBV)(z.RTZ(),value,z.BitVecSort(width))
            if width == 64:
                return converted
            return super().cast(converted,Term('tuint' if unsigned else 'tint'),target)
        if target.tag in ('tlong','tulong') and z.is_bv(value):
            if value.size() == 64:
                return value
            return (z.ZeroExt if source.tag in ('tuint','tushort','tuchar','tbool','tptr') else z.SignExt)(64-value.size(),value)
        if source.tag in ('tlong','tulong') and z.is_bv(value) and target.tag in ('tint','tuint','tshort','tushort','tchar','tschar','tuchar','tptr'):
            return super().cast(z.Extract(31,0,value),Term('tuint' if source.tag == 'tulong' else 'tint'),target)
        return super().cast(value,source,target)

    def traverse(self, statement, normal, scope, returned=None, broken=None, path='body'):
        tag, a = statement.tag, statement.args
        returned = normal if returned is None else returned
        if tag == 'Sswitch':
            value=self.eval(a[0],scope)
            if not z.is_bv(value):
                raise Unsupported('Non-integer switch selector')
            labels=[];rest=a[1]
            while rest.tag=='LScons':
                label,body,rest=rest.args
                labels.append((None if label.tag=='None' else int(label.args[0].tag),body))
            if rest.tag!='LSnil':raise Unsupported('Switch labels')
            cases=[n for n,_ in labels if n is not None]
            default=z.And(*[value!=z.BitVecVal(n,value.size()) for n in cases])
            suffix=normal;result=[]
            # Each fall-through suffix is built once. Break always exits the
            # SWITCH to its original continuation, not to the next case.
            for index in range(len(labels)-1,-1,-1):
                label,body=labels[index]
                suffix=self.wp(body,suffix,scope,returned,normal,path+'.case'+str(label))
                guard=default if label is None else value==z.BitVecVal(label,value.size())
                result+=self.guard(suffix,guard,'switch-case-'+str(label))
            if all(n is not None for n,_ in labels):
                result+=self.guard(normal,default,'switch-no-match')
            return merge(result)
        if tag == 'Sassign' and a[0].tag == 'Efield':
            base, field, ty = a[0].args
            info = scope.function.unit.bitfield(self.typeof(base),field.tag)
            if info:
                offset, unit, pos, width, signed, attr = info
                address = self.location(base,scope)+word(offset)
                old = read(MEM,address,unit//8)
                value = self.cast(self.eval(a[1],scope),self.typeof(a[1]),ty)
                shift = unit-pos-width
                mask = ((1<<width)-1)<<shift
                low = z.Extract(width-1,0,value)
                normalized = z.ZeroExt(unit-width,low) if unit != width else low
                new = (old & z.BitVecVal(~mask,unit)) | (normalized << shift)
                return self.substitute(normal,(MEM,write(MEM,address,new,unit//8)))
        if tag == 'Scontinue':
            if not self.continues or self.continues[-1][0] is not scope:
                raise Unsupported('Continue outside its loop/function')
            return self.continues[-1][1]
        if tag in ('Swhile', 'Sdowhile', 'Sfor', 'Sloop'):
            if tag in ('Sfor','Sdowhile'):
                return self.wp(derived_loop(statement),normal,scope,returned,broken,path+'.derived')
            if tag == 'Sloop':
                return self.loop(None, a[0], a[1], normal, scope, returned, path)
            cond, body = a
            result = self.loop(cond, body, Term('Sskip'), normal, scope, returned, path)
            return result
        if tag == 'Scall' and self.auto_calls and a[1].tag == 'Evar':
            name = a[1].args[0].tag.removeprefix('_')
            if name not in self.INLINE:
                self.INLINE = dict(self.INLINE, **{name:self.resolve_call(name, scope)})
        return super().traverse(statement, normal, scope, returned, broken, path)

    def loop(self, condition, body, increment, normal, scope, returned, path):
        number = len(self.loops)
        label = f'{self.version}.engine.{self.serial}.loop.{scope.name}.{number}'
        # Loop-carried variables include caller continuation values as well as
        # callee temporaries. Parameters are actual SMT expressions, not opaque
        # frame promises. The byte memory is carried on every recursive edge.
        variables = list(scope.temps.values()) + [scope.result, MEM]
        variables.extend(self.loop_context_variables())
        for p in normal + returned:
            variables.extend(get_vars(p.condition))
        unique = {v.get_id():v for v in variables}
        variables = list(unique.values())
        fuel = z.Int(label+'.fuel')
        relation = z.RecFunction(label, z.IntSort(), *[v.sort() for v in variables], z.BoolSort())
        again = [Path(relation(fuel-1, *variables))]
        self.loops.append(dict(function=scope.function.name, statementPath=path,
            relation=label, semantics='exists finite decreasing fuel; no fixed unroll bound'))
        self.continues.append((scope, again))
        try:
            inc = self.wp(increment, again, scope, returned, normal, path+'.increment')
            self.continues[-1] = (scope, inc)
            step = self.wp(body, inc, scope, returned, normal, path+'.iteration')
        finally:
            self.continues.pop()
        guards = []
        self.conversion_guards.append(guards)
        try:
            guard = z.BoolVal(True) if condition is None else truth(self.eval(condition, scope))
        finally:
            self.conversion_guards.pop()
        definition = z.And(*guards,z.If(guard, z.And(fuel > 0, merge(step)[0].condition), merge(normal)[0].condition))
        # Detect hidden free constants: forgetting one would freeze an earlier
        # value across the loop instead of updating it.
        allowed = {v.get_id() for v in variables} | {fuel.get_id()}
        unexpected = [v for v in get_vars(definition) if v.get_id() not in allowed]
        if unexpected:
            raise Unsupported('Loop summary has uncaptured variables: '+str(unexpected))
        z.RecAddDefinition(relation, [fuel]+variables, definition)
        self.definitions.append((relation, [fuel]+variables, definition))
        if self.loop_fuel is not None:
            self.loops[number]['semantics'] = 'explicit finite test bound; no exhaustive coverage claim'
            self.loops[number]['fuel'] = self.loop_fuel
            return [Path(z.And(self.loop_fuel>=0,relation(z.IntVal(self.loop_fuel),*variables)))]
        witness = z.Int(label+'.iterations')
        return [Path(z.Exists(witness, z.And(witness >= 0, relation(witness, *variables))))]

    def loop_context_variables(self):
        return []
