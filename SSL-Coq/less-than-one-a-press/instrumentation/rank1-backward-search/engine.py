"""Bounded backward substitution over actual generated Clight constructors.

The exploratory interpreter uses byte-addressed, ordinary separated storage.
It is not a proved CompCert interpreter. Unknown calls get independent before
and after memories and an UNEXPANDED relation: never an implicit memory frame.
SAT with such a relation is an unresolved predecessor obligation, not a run.
"""
from dataclasses import dataclass, replace
import sys
from clight import ROOT, Term, Unit, items
sys.path.insert(0, str(ROOT / 'build/rank1-backward-search/python-deps'))
import z3 as z

BV = z.BitVecSort(32)
FP = z.Float32()
MEM = z.Array('memory_at_cut', BV, z.BitVecSort(8))
STATE, OBJECT, TOP, FLOOR = 0x01000000, 0x02000000, 0x02100000, 0x04000000


def word(n): return z.BitVecVal(n % (1 << 32), 32)
def float_bits(n): return z.fpBVToFP(word(n), FP)
def truth(v):
    if z.is_bool(v): return v
    if z.is_fp(v): return z.Not(z.fpEQ(v, z.FPVal(0, v.sort())))
    return v != z.BitVecVal(0, v.size())
def integer_bool(v): return z.If(v, word(1), word(0))
def finite(v): return z.And(z.Not(z.fpIsNaN(v)), z.Not(z.fpIsInf(v)))
def read(memory, address, size=4):
    data = z.Concat(*[z.Select(memory, address+word(i)) for i in range(size)]) if size > 1 else z.Select(memory,address)
    return data
def write(memory, address, value, size=4):
    if z.is_fp(value): value = z.fpToIEEEBV(value)
    result = memory
    for i in range(size):
        result = z.Store(result, address+word(i), z.Extract(8*(size-i)-1, 8*(size-i-1), value))
    return result
def load_float(memory, address): return z.fpBVToFP(read(memory, word(address)), FP)


@dataclass
class Path:
    condition: object
    decisions: tuple = ()
    calls: tuple = ()


class Unsupported(Exception): pass


class Scope:
    def __init__(self, engine, function):
        self.function = function
        self.name = function.name + '.' + str(engine.counter)
        engine.counter += 1
        def sort(ty):
            if ty.tag == 'tfloat': return FP
            if ty.tag == 'tdouble': return z.Float64()
            if ty.tag in ('tlong', 'tulong'): return z.BitVecSort(64)
            return BV
        self.temps = {k:z.Const(self.name+k, sort(t))
                      for k,t in (function.temps | function.params).items()}
        self.local_addresses = {k:engine.allocate_local() for k in function.locals}
        self.result = z.Const(self.name+'.result', sort(function.returns))


class Engine:
    INLINE = {'absf':'object_helpers', 'vec3f_copy':'math_util',
              'vec3s_set':'math_util', 'stop_and_set_height_to_floor':'mario_step',
              'mario_set_forward_vel':'mario'}

    def __init__(self, version, timeout_ms=15000):
        self.version, self.timeout_ms = version, timeout_ms
        self.units, self.globals, self.counter, self.local_counter = {}, {}, 0, 0
        self.calls, self.functions = {}, {}
        self.call_constraints = None

    def unit(self, name):
        if name not in self.units: self.units[name] = Unit(self.version,name)
        return self.units[name]

    def function(self, unit, name):
        fn = self.unit(unit).function(name)
        self.functions[name] = dict(file=str(fn.unit.path.relative_to(ROOT)), line=fn.line,
                                   sha256=fn.digest)
        return fn

    def allocate_local(self):
        self.local_counter += 1
        if self.local_counter >= 0x1000:
            raise Unsupported('Canonical local-storage arena exhausted')
        return 0x20000000 + self.local_counter*0x10000

    def global_address(self, name):
        if name == '_gMarioStates': return STATE
        if name not in self.globals:
            if len(self.globals) >= 0x100:
                raise Unsupported('Canonical global-storage arena exhausted; would overlap locals')
            self.globals[name] = 0x10000000 + len(self.globals)*0x100000
        return self.globals[name]

    def address_var(self, scope, name):
        return word(scope.local_addresses[name] if name in scope.local_addresses else self.global_address(name))

    @staticmethod
    def typeof(expr):
        if not expr.tag.startswith('E') or not expr.args: raise Unsupported(str(expr))
        return expr.args[-1]

    def pointer_element(self, ty):
        if ty.tag in ('tptr','tarray'): return ty.args[0]
        raise Unsupported('Not a pointer: ' + str(ty))

    def location(self, expr, scope):
        a = expr.args
        if expr.tag == 'Evar': return self.address_var(scope,a[0].tag)
        if expr.tag == 'Ederef': return self.eval(a[0],scope)
        if expr.tag == 'Efield':
            ty = self.typeof(a[0])
            return self.location(a[0],scope) + word(scope.function.unit.field_offset(ty,a[1].tag))
        raise Unsupported('Lvalue: ' + str(expr))

    def load(self, address, ty, unit):
        if ty.tag in ('Tstruct','Tunion','tarray'): return address
        size,_ = unit.size(ty)
        if size > 4: raise Unsupported('Wide scalar load')
        value = read(MEM,address,size)
        if ty.tag == 'tfloat': return z.fpBVToFP(value,FP)
        if size < 4:
            return (z.ZeroExt if ty.tag in ('tuchar','tushort','tbool') else z.SignExt)(32-8*size,value)
        return value

    def cast(self, value, source, target):
        if target.tag == 'tfloat':
            if z.is_fp(value): return value
            return (z.fpUnsignedToFP if source.tag in ('tuint','tushort','tuchar') else z.fpSignedToFP)(z.RNE(),value,FP)
        if z.is_fp(value): raise Unsupported('Float-to-int cast needs definedness checks')
        if target.tag == 'tbool': return integer_bool(truth(value))
        if target.tag in ('tshort','tushort','tchar','tschar','tuchar'):
            n = 16 if target.tag in ('tshort','tushort') else 8
            return (z.ZeroExt if target.tag in ('tushort','tuchar') else z.SignExt)(32-n,z.Extract(n-1,0,value))
        if target.tag in ('tint','tuint','tptr'): return value
        raise Unsupported('Cast: ' + str(target))

    def eval(self, expr, scope):
        tag,a = expr.tag,expr.args
        if tag == 'Econst_int': return word(int(a[0].args[0].tag))
        if tag == 'Econst_single': return float_bits(int(a[0].args[0].args[0].tag))
        if tag == 'Etempvar': return scope.temps[a[0].tag]
        if tag in ('Evar','Ederef','Efield'): return self.load(self.location(expr,scope),a[-1],scope.function.unit)
        if tag == 'Eaddrof': return self.location(a[0],scope)
        if tag == 'Ecast': return self.cast(self.eval(a[0],scope),self.typeof(a[0]),a[1])
        if tag == 'Eunop':
            op,value = a[0].tag,self.eval(a[1],scope)
            if op == 'Oneg': return z.fpNeg(value) if z.is_fp(value) else -value
            if op == 'Onotint': return ~value
            if op == 'Onotbool': return integer_bool(z.Not(truth(value)))
            raise Unsupported(op)
        if tag != 'Ebinop': raise Unsupported('Expression: ' + str(expr))
        op,left,right = a[0].tag,self.eval(a[1],scope),self.eval(a[2],scope)
        lt,rt = self.typeof(a[1]),self.typeof(a[2])
        if op in ('Oadd','Osub') and lt.tag in ('tptr','tarray') and rt.tag not in ('tptr','tarray'):
            width,_ = scope.function.unit.size(self.pointer_element(lt))
            return left + right*word(width) if op == 'Oadd' else left-right*word(width)
        floating = z.is_fp(left) or z.is_fp(right)
        if floating:
            left,right = self.cast(left,lt,Term('tfloat')),self.cast(right,rt,Term('tfloat'))
            if op in ('Oadd','Osub','Omul','Odiv'):
                return {'Oadd':z.fpAdd,'Osub':z.fpSub,'Omul':z.fpMul,'Odiv':z.fpDiv}[op](z.RNE(),left,right)
            comparisons={'Oeq':z.fpEQ,'One':lambda x,y:z.Not(z.fpEQ(x,y)),
                         'Olt':z.fpLT,'Ole':z.fpLEQ,'Ogt':z.fpGT,'Oge':z.fpGEQ}
        else:
            if op == 'Oadd': return left+right
            if op == 'Osub': return left-right
            if op == 'Omul': return left*right
            if op == 'Oand': return left & right
            if op == 'Oor': return left | right
            if op == 'Oxor': return left ^ right
            if op == 'Oshl': return left << right
            if op == 'Oshr': return z.LShR(left,right) if lt.tag in ('tuint','tushort','tuchar') else left >> right
            unsigned = lt.tag in ('tuint','tptr','tarray') or rt.tag in ('tuint','tptr','tarray')
            comparisons={'Oeq':lambda x,y:x==y,'One':lambda x,y:x!=y,
                'Olt':z.ULT if unsigned else lambda x,y:x<y,
                'Ole':z.ULE if unsigned else lambda x,y:x<=y,
                'Ogt':z.UGT if unsigned else lambda x,y:x>y,
                'Oge':z.UGE if unsigned else lambda x,y:x>=y}
        if op not in comparisons: raise Unsupported(op)
        return integer_bool(comparisons[op](left,right))

    @staticmethod
    def substitute(paths, *pairs):
        return [replace(p,condition=z.simplify(z.substitute(p.condition,*pairs))) for p in paths]

    @staticmethod
    def guard(paths, condition, decision):
        return [replace(p,condition=z.simplify(z.And(condition,p.condition)),
                        decisions=(decision,)+p.decisions) for p in paths]

    def wp(self, statement, normal, scope, returned=None, broken=None, path='body'):
        """Traverse Ssequence from its SECOND child to its FIRST child."""
        returned = normal if returned is None else returned
        tag,a = statement.tag,statement.args
        if tag == 'Sskip': return normal
        if tag == 'Ssequence':
            suffix=self.wp(a[1],normal,scope,returned,broken,path+'.1')
            return self.wp(a[0],suffix,scope,returned,broken,path+'.0')
        if tag == 'Sset': return self.substitute(normal,(scope.temps[a[0].tag],self.eval(a[1],scope)))
        if tag == 'Sassign':
            ty=self.typeof(a[0]); size,_=scope.function.unit.size(ty)
            value=self.cast(self.eval(a[1],scope),self.typeof(a[1]),ty)
            return self.substitute(normal,(MEM,write(MEM,self.location(a[0],scope),value,size)))
        if tag == 'Sifthenelse':
            cond=truth(self.eval(a[0],scope)); name=scope.function.name+':'+path
            yes=self.wp(a[1],normal,scope,returned,broken,path+'.then')
            no=self.wp(a[2],normal,scope,returned,broken,path+'.else')
            return self.guard(yes,cond,name+' true') + self.guard(no,z.Not(cond),name+' false')
        if tag == 'Sreturn':
            if a[0].tag == 'None': return returned
            return self.substitute(returned,(scope.result,self.cast(self.eval(a[0].args[0],scope),self.typeof(a[0].args[0]),scope.function.returns)))
        if tag == 'Sbreak':
            if broken is None: raise Unsupported('Break outside selected switch')
            return broken
        if tag == 'Sswitch':
            value=self.eval(a[0],scope); labels=[]; rest=a[1]
            while rest.tag == 'LScons':
                label,body,rest=rest.args
                labels.append((None if label.tag=='None' else int(label.args[0].tag),body))
            if rest.tag!='LSnil': raise Unsupported('Switch labels')
            result=[]; cases=[n for n,_ in labels if n is not None]
            from clight import seq
            for i,(n,_) in enumerate(labels):
                pred=z.And(*[value!=word(c) for c in cases]) if n is None else value==word(n)
                paths=self.wp(seq([b for _,b in labels[i:]]),normal,scope,returned,normal,path+'.case'+str(n))
                result+=self.guard(paths,pred,scope.function.name+':'+path+' case '+str(n))
            if not any(n is None for n,_ in labels):
                result+=self.guard(normal,z.And(*[value!=word(c) for c in cases]),scope.function.name+':'+path+' default')
            return result
        if tag != 'Scall': raise Unsupported('Statement: '+tag)
        dest,callee,args=a; name=callee.args[0].tag.removeprefix('_')
        if callee.tag!='Evar': raise Unsupported('Indirect call')
        arguments=[self.eval(e,scope) for e in items(args)]
        ident=scope.name+':'+path+':'+name
        return_type=callee.args[-1].args[1]
        retval=z.Const('return@'+ident,FP if return_type.tag=='tfloat' else BV)
        tail=self.substitute(normal,(scope.temps[dest.args[0].tag],retval)) if dest.tag=='Some' else normal
        if name in self.INLINE:
            child=Scope(self,self.function(self.INLINE[name],name))
            post=self.substitute(tail,(retval,child.result))
            paths=self.wp(child.function.body,post,child,post,None,'body')
            pairs=[(child.temps[p],v) for p,v in zip(child.function.params,arguments)]
            if len(arguments)!=len(pairs): raise Unsupported('Argument count')
            return self.substitute(paths,*pairs)
        after=z.Array('after@'+ident,BV,z.BitVecSort(8))
        relation=z.Function('UNEXPANDED_'+name,MEM.sort(),*[v.sort() for v in arguments],MEM.sort(),retval.sort(),z.BoolSort())
        needed=z.BoolVal(True) if self.call_constraints is None else self.call_constraints(name,ident,arguments,after,retval,scope)
        obligation=relation(MEM,*arguments,after,retval)
        self.calls[ident]=dict(function=name,caller=scope.function.name,path=path,
                              memory='independent before/after; no preservation granted')
        paths=self.substitute(tail,(MEM,after))
        return [replace(p,condition=z.simplify(z.And(p.condition,obligation,needed)),
                        calls=(ident,)+p.calls) for p in paths]

    def start(self, function, goal, body=None):
        scope=Scope(self,function)
        return scope,self.wp(body or function.body,[Path(goal)],scope)

    def solve(self, condition, additions=()):
        solver=z.Solver(); solver.set(timeout=self.timeout_ms)
        solver.add(condition,*additions)
        result=solver.check()
        return str(result), solver.model() if result==z.sat else None, solver.reason_unknown() if result==z.unknown else None

    def entry(self, scope):
        """Named ordinary storage domain; no position/timer/floor outcomes here."""
        constraints=[]
        for name in ('_gMarioObject','_gCurrentObject'):
            constraints.append(read(MEM,word(self.global_address(name)))==word(OBJECT))
        constraints.append(read(MEM,word(STATE+136))==word(OBJECT))
        if '_m' in scope.temps: constraints.append(scope.temps['_m']==word(STATE))
        return constraints
