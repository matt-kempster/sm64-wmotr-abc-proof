"""Path-specific backward conditions, selected and replayed through real bodies.

Concrete data selects a control-flow/address path. It is NOT substituted into
the predecessor formula: guards, addresses, arguments and effects are retained
and the trace is substituted BACKWARDS from the target. Other paths remain
unsearched. This is an exploratory, conditional path checker, not a whole-game
reachability certificate or a verified CompCert interpreter.
"""
from dataclasses import dataclass
import re
from clight import Term, items, parse, ROOT, outer_items, walk
from engine import Scope, Unsupported, word, truth, z
from relational_engine import RelationalEngine
from loop_engine import derived_loop, get_vars


class Control(Exception):
    def __init__(self,kind,value=None): self.kind,self.value=kind,value


class Checkpoint(Exception): pass


@dataclass
class Event:
    kind: str
    scope: str
    path: str
    pairs: tuple = ()
    condition: object = None


class TraceEngine(RelationalEngine):
    def __init__(self,version,*,step_limit=100000,**kwargs):
        kwargs.setdefault('program_dispatch',True)
        kwargs.setdefault('runtime_audio',True)
        kwargs.setdefault('supplemental_modules',('main','camera','sound_init'))
        super().__init__(version,**kwargs)
        self.values={}
        self.variables={}
        self.cells={}
        self.regions=[]
        self.events=[]
        self.call_trace=[]
        self.steps=0
        self.step_limit=step_limit
        self.active=[]
        self.initializing=set()
        self.initialized_globals=set()
        self.initial_bytes={}
        self.source_vars={}
        self.checkpoint=None
        self.floor_result=None
        self.floor_calls=[]
        self.indirect_calls=[]
        self.current_path='setup'
        for module in self.image.modules:
            unit=self.unit(module)
            for name,definition in unit.global_definitions().items():
                if definition.tag=='Gvar':
                    self.source_vars.setdefault(name,[]).append((unit,definition.args[0].tag))

    def context(self): return self.active[-1].name if self.active else 'boundary'

    def bind(self,var,value):
        self.variables[var.get_id()]=var
        self.values[var.get_id()]=value

    def concrete(self,expr):
        variables=get_vars(expr)
        missing=[v for v in variables if v.get_id() not in self.values]
        if missing: raise Unsupported('Uninitialized value at '+self.context()+': '+str(missing))
        value=z.simplify(z.substitute(expr,*[(v,self.values[v.get_id()]) for v in variables]))
        if get_vars(value): raise Unsupported('Non-concrete trace selector: '+str(value))
        return value

    def number(self,expr):
        value=self.concrete(expr)
        if not z.is_bv_value(value): raise Unsupported('Expected concrete integer: '+str(value))
        return value.as_long()

    def require(self,condition):
        if not z.is_true(self.concrete(condition)):
            raise Unsupported('Failed execution guard in '+self.context()+' at '+self.current_path+': '+str(condition))
        self.events.append(Event('guard',self.context(),self.current_path,condition=condition))

    def assign(self,pairs):
        values=[self.concrete(rhs) for _,rhs in pairs]
        self.events.append(Event('assign',self.context(),self.current_path,tuple(pairs)))
        for (var,_),value in zip(pairs,values): self.bind(var,value)

    def region(self,address,size,label,*,zero=False):
        if not 0<address<address+size<=2**32: raise Unsupported('Invalid allocation '+label)
        if any(address<b+n and b<address+size for b,n,_ in self.regions):
            raise Unsupported('Overlapping trace allocation '+label)
        self.regions.append((address,size,label))
        if zero:
            for offset in range(size): self.seed(address+offset,0,1)

    def seed(self,address,value,size=4):
        """Fixture/boundary data only; never an instruction of game execution."""
        for i in range(size):
            byte=(value>>(8*(size-i-1)))&255
            var=self.cell(address+i,check=False)
            self.bind(var,z.BitVecVal(byte,8))
            self.initial_bytes[address+i]=byte

    def cell(self,address,check=True):
        if check and not any(b<=address<b+n for b,n,_ in self.regions):
            self.ensure_global_containing(address)
        if check and not any(b<=address<b+n for b,n,_ in self.regions):
            raise Unsupported(f'Invalid byte address {address:#x} in {self.context()}')
        if address not in self.cells:
            self.cells[address]=z.BitVec(f'byte.{address:08x}',8)
        return self.cells[address]

    def bytes_read(self,address,size):
        cells=[self.cell(address+i) for i in range(size)]
        # Reading an allocated but uninitialized local is rejected separately
        # from using zero-initialized static data.
        for v in cells:
            if v.get_id() not in self.values: raise Unsupported('Uninitialized memory '+str(v))
        return cells[0] if size==1 else z.Concat(*cells)

    def store(self,address,value,size):
        n=self.number(address)
        self.require(address==word(n))
        if n%min(size,4): raise Unsupported('Unaligned store '+hex(n))
        if z.is_fp(value): value=z.fpToIEEEBV(value)
        pairs=[(self.cell(n+i),z.Extract(8*(size-i)-1,8*(size-i-1),value)) for i in range(size)]
        self.assign(pairs)

    def load(self,address,ty,unit):
        if ty.tag in ('Tstruct','Tunion','tarray','Tfunction'): return address
        n=self.number(address)
        self.require(address==word(n))
        size,alignment=unit.size(ty)
        if n%alignment: raise Unsupported('Unaligned load '+hex(n))
        value=self.bytes_read(n,size)
        if ty.tag in ('tfloat','tdouble'):
            return z.fpBVToFP(value,z.Float32() if ty.tag=='tfloat' else z.Float64())
        if size<4:
            return (z.ZeroExt if ty.tag in ('tuchar','tushort','tbool') else z.SignExt)(32-8*size,value)
        return value

    def eval(self,expr,scope):
        if expr.tag=='Efield':
            base,field,ty=expr.args
            info=scope.function.unit.bitfield(self.typeof(base),field.tag)
            if info:
                offset,unit,pos,width,signed,attr=info
                addr=self.location(base,scope)+word(offset)
                n=self.number(addr); self.require(addr==word(n))
                storage=self.bytes_read(n,unit//8)
                value=z.Extract(unit-pos-1,unit-pos-width,storage)
                return (z.SignExt if signed=='Signed' else z.ZeroExt)(32-width,value)
        return super().eval(expr,scope)

    def expression(self,expr,scope):
        self.conversion_guards.append([])
        try:
            value=self.eval(expr,scope)
            for guard in self.conversion_guards[-1]: self.require(guard)
            return value
        finally: self.conversion_guards.pop()

    def data_definition(self,name):
        candidates=[]
        for unit,ident in self.source_vars.get(name,[]):
            match=re.search(r'Definition '+re.escape(ident)+r' := \{\|(.*?)\|\}\.',unit.text,re.S)
            if not match: raise Unsupported('Missing variable definition '+ident)
            fields=dict(re.findall(r'(gvar_\w+) :=\s*(.*?)(?:;\s*(?=gvar_\w+ :=)|\Z)',match[1],re.S))
            init=items(parse(fields['gvar_init']))
            if init: candidates.append((unit,parse(fields['gvar_info']),init))
        if not candidates: raise Unsupported('No initialized global definition for '+name)
        if any(str(init)!=str(candidates[0][2]) for _,_,init in candidates[1:]):
            raise Unsupported('Conflicting initialized global definitions for '+name)
        return candidates[0]

    def initialize_global(self,name):
        if name in self.initialized_globals: return self.global_address(name)
        if name in self.initializing: return self.global_address(name)
        unit,ty,init=self.data_definition(name)
        address=self.global_address(name)
        size,_=unit.size(ty)
        self.region(address,size,name)
        self.initializing.add(name)
        cursor=address
        for value in init:
            tag,args=value.tag,value.args
            if tag=='Init_space':
                n=int(args[0].tag)
                for j in range(n): self.seed(cursor+j,0,1)
            elif tag=='Init_addrof':
                ident=args[0].tag
                base=self.function_address(ident[1:]) if ident[1:] in self.image.symbols else self.global_address(ident)
                self.seed(cursor,base+int(args[1].args[0].tag)); n=4
            elif tag in ('Init_int8','Init_int16','Init_int32','Init_int64'):
                n={'Init_int8':1,'Init_int16':2,'Init_int32':4,'Init_int64':8}[tag]
                self.seed(cursor,int(args[0].args[0].tag),n)
            elif tag in ('Init_float32','Init_float64'):
                n=4 if tag=='Init_float32' else 8
                self.seed(cursor,int(args[0].args[0].args[0].tag),n)
            else: raise Unsupported('Global initializer '+str(value))
            cursor+=n
        if cursor!=address+size: raise Unsupported('Global size mismatch '+name)
        self.initializing.remove(name);self.initialized_globals.add(name)
        return address

    def ensure_global_containing(self,address):
        for name,base in list(self.globals.items())+[('_gMarioStates',0x01000000)]:
            if base<=address<base+0x100000 and name not in self.initialized_globals:
                self.initialize_global(name)
                return

    def statement(self,node,scope,path='body'):
        self.steps+=1
        if self.steps>self.step_limit: raise Unsupported('Trace statement limit; incomplete execution')
        self.current_path=path
        tag,a=node.tag,node.args
        if tag=='Sskip': return
        if tag=='Ssequence':
            self.statement(a[0],scope,path+'.0');self.statement(a[1],scope,path+'.1');return
        if tag=='Sset':
            self.assign([(scope.temps[a[0].tag],self.expression(a[1],scope))]);return
        if tag=='Sassign':
            ty=self.typeof(a[0]);size,_=scope.function.unit.size(ty)
            self.conversion_guards.append([])
            try:
                value=self.cast(self.eval(a[1],scope),self.typeof(a[1]),ty)
                addr=self.location(a[0],scope)
                for guard in self.conversion_guards[-1]: self.require(guard)
                self.store(addr,value,size)
            finally:self.conversion_guards.pop()
            return
        if tag=='Sifthenelse':
            condition=truth(self.expression(a[0],scope)); chosen=z.is_true(self.concrete(condition))
            self.require(condition if chosen else z.Not(condition))
            self.statement(a[1] if chosen else a[2],scope,path+('.then' if chosen else '.else'));return
        if tag in ('Sfor','Sdowhile'):
            self.statement(derived_loop(node),scope,path+'.derived');return
        if tag=='Swhile':
            guarded=Term('Ssequence',(Term('Sifthenelse',(a[0],Term('Sskip'),Term('Sbreak'))),a[1]))
            self.statement(Term('Sloop',(guarded,Term('Sskip'))),scope,path+'.while');return
        if tag=='Sloop':
            i=0
            while True:
                try:
                    try:self.statement(a[0],scope,path+f'.iteration{i}')
                    except Control as result:
                        if result.kind!='continue':raise
                    self.statement(a[1],scope,path+f'.increment{i}')
                except Control as result:
                    if result.kind=='break':break
                    raise
                i+=1
            return
        if tag in ('Sbreak','Scontinue'):raise Control(tag[1:].lower())
        if tag=='Sswitch':
            value=self.expression(a[0],scope);concrete=self.number(value)
            rest=a[1]; labels=[]
            while rest.tag=='LScons':
                label,body,rest=rest.args
                labels.append((None if label.tag=='None' else int(label.args[0].tag)%(2**32),body))
            exact=next((i for i,(n,_) in enumerate(labels) if n==concrete),None)
            selected=exact if exact is not None else next((i for i,(n,_) in enumerate(labels) if n is None),len(labels))
            self.require(value==word(concrete) if exact is not None else z.And(*[value!=word(n) for n,_ in labels if n is not None]))
            try:
                for i in range(selected,len(labels)):self.statement(labels[i][1],scope,path+f'.case{i}')
            except Control as result:
                if result.kind!='break':raise
            return
        if tag=='Sreturn':
            if a[0].tag=='None':raise Control('return')
            expr=a[0].args[0]
            self.conversion_guards.append([])
            try:
                value=self.cast(self.eval(expr,scope),self.typeof(expr),scope.function.returns)
                for guard in self.conversion_guards[-1]: self.require(guard)
                self.assign([(scope.result,value)])
            finally:self.conversion_guards.pop()
            raise Control('return',scope.result)
        if tag!='Scall':raise Unsupported('Unsupported trace statement '+tag)
        dest,callee,actual=a
        values=[self.expression(v,scope) for v in items(actual)]
        if callee.tag=='Evar':name=callee.args[0].tag.removeprefix('_')
        else:
            pointer=self.expression(callee,scope);address=self.number(pointer)
            matches=[entry for entry in self.image.compatible(self.typeof(callee),scope.function.unit)
                     if self.function_address(entry.name)==address]
            if len(matches)!=1:raise Unsupported('Invalid/mismatched live function pointer '+hex(address))
            name=matches[0].name;self.require(pointer==word(address))
            self.indirect_calls.append(dict(caller=scope.function.name,callee=name,address=address,path=path))
        if name=='sqrtf':
            expected=parse('(Tfunction (tfloat :: nil) tfloat cc_default)')
            if self.typeof(callee)!=expected or len(values)!=1:raise Unsupported('sqrtf call type')
            x=values[0]
            self.require(z.And(z.Not(z.fpIsNaN(x)),z.Not(z.fpIsInf(x)),z.fpGEQ(x,z.FPVal(0,z.Float32())),z.Or(z.fpIsZero(x),z.fpIsNormal(x))))
            result=z.fpSqrt(z.RNE(),x)
            self.library_domains.append(dict(caller=scope.function.name,external='sqrtf',
                model='Existing explicit instruction binding: nearest-even, usable FPU, no inexact trap; finite nonnegative normal or signed zero.'))
        else:
            entry=self.image.symbols.get(name)
            if entry is None or not entry.internal:raise Unsupported('Unimplemented executed call '+name)
            fn=self.function(entry.unit,entry.body)
            if len(values)!=len(fn.params):raise Unsupported('Call argument count '+name)
            # Also verify direct-call prototypes; matching a name is not enough.
            cty=self.typeof(callee);cty=cty.args[0] if cty.tag=='tptr' else cty
            if self.image.signature_key(cty,scope.function.unit)!=self.image.signature_key(entry.signature,self.unit(entry.unit)):
                raise Unsupported('Call signature mismatch '+name)
            self.conversion_guards.append([])
            try:
                values=[self.cast(v,self.typeof(expr),ty) for v,expr,ty in zip(values,items(actual),fn.params.values())]
                for guard in self.conversion_guards[-1]:self.require(guard)
            finally:self.conversion_guards.pop()
            result=self.call(fn,values)
        if name=='find_floor':
            self.floor_calls.append(dict(caller=scope.function.name,
                queryBits=[self.number(z.fpToIEEEBV(v)) for v in values[:3]],
                heightBits=self.number(z.fpToIEEEBV(result)),
                floor=self.number(self.bytes_read(self.number(values[3]),4))))
        if scope.function.name=='update_mario_platform' and name=='find_floor':
            self.floor_result=(result,values)
        if dest.tag=='Some':
            if result is None:raise Unsupported('Use of undefined return from '+name)
            self.assign([(scope.temps[dest.args[0].tag],result)])
        if self.checkpoint==(scope.function.name,name):raise Checkpoint()

    def call(self,fn,values=(),body=None):
        scope=Scope(self,fn)
        if len(values)!=len(fn.params):raise Unsupported('Argument count '+fn.name)
        for name,ty in fn.locals.items():
            self.region(scope.local_addresses[name],fn.unit.size(ty)[0],scope.name+name)
        self.active.append(scope)
        self.call_trace.append(dict(function=fn.name,scope=scope.name,source=fn.digest,line=fn.line,
                                    file=str(fn.unit.path.relative_to(ROOT)),entryEvent=len(self.events)))
        self.assign([(scope.temps[name],v) for name,v in zip(fn.params,values)])
        result=None
        try:
            self.statement(fn.body if body is None else body,scope)
        except Control as returned:
            if returned.kind!='return':raise Unsupported('Unmatched '+returned.kind+' in '+fn.name)
            result=returned.value
        finally:
            self.active.pop()
            self.regions=[r for r in self.regions if not r[2].startswith(scope.name+'_')]
        return result

    def predecessor(self,goal):
        """Literal reverse substitution of the selected complete source trace."""
        result=goal
        for event in reversed(self.events):
            if event.kind=='guard':result=z.And(event.condition,result)
            elif event.pairs:result=z.substitute(result,*event.pairs)
        return z.simplify(result)

    def initial_instance(self,formula,leave=()):
        remaining=set(leave)
        pairs=[(self.cells[a],z.BitVecVal(v,8)) for a,v in self.initial_bytes.items()
               if a in self.cells and a not in remaining]
        return z.simplify(z.substitute(formula,*pairs))
