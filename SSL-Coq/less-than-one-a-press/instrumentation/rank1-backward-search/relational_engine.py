"""Share original callee preimages instead of repeatedly inlining continuations.

Every relation receives before/after byte memories and is DEFINED by its actual
generated body. A decreasing call-depth argument excludes circular recursive
justifications. Missing bodies are coverage errors, never uninterpreted frames.
This is an exploratory flat-memory model, not a CompCert refinement theorem.
"""
import re
from clight import Term, items, parse, ROOT
from engine import Scope, Path, MEM, word, z, Unsupported
from loop_engine import LoopEngine, initialized_temporaries
from search import HEIGHT, bits


class RelationalEngine(LoopEngine):
    def __init__(self,version,**kwargs):
        self.sqrtf_binding = kwargs.pop('sqrtf_binding',False)
        self.catalog_native = kwargs.pop('catalog_native',False)
        super().__init__(version,auto_calls=True,**kwargs)
        self.relations = {}
        self.pending = []
        self.current_depth = None
        self.undefined_return = None
        self.relation_receipts = []
        self.indirect_domains = []
        self.library_domains = []
        self.code_addresses = {}
        self.current_record = None
        self.call_edges = {}

    def function_address(self,name):
        if name not in self.code_addresses:
            self.code_addresses[name] = 0x70000000+16*len(self.code_addresses)
        return self.code_addresses[name]

    def location(self,expr,scope):
        if expr.tag == 'Evar' and self.typeof(expr).tag == 'Tfunction':
            return word(self.function_address(expr.args[0].tag.removeprefix('_')))
        return super().location(expr,scope)

    def load(self,address,ty,unit):
        if ty.tag == 'Tfunction':
            return address
        return super().load(address,ty,unit)

    def source_table_targets(self,scope,callee):
        """Recognize the real behavior command table, retaining a live guard.

        The table is writable in Clight. These initial values are NOT assumed
        to persist: non-member live pointers remain a recorded coverage gap.
        """
        if self.catalog_native and scope.function.name == 'bhv_cmd_call_native' and callee.tag == 'Etempvar' and callee.args[0].tag == '_behaviorFunc':
            unit = self.unit('behavior_data')
            names = re.findall(r'Init_int32 \(Int.repr 201326592\) ::\s*Init_addrof _(\w+) \(Ptrofs.repr 0\)',unit.text)
            if not names:
                raise RuntimeError('No source CALL_NATIVE entries found')
            return list(dict.fromkeys(names))
        if scope.function.name != 'cur_obj_update' or callee.tag != 'Etempvar' or callee.args[0].tag != '_bhvCmdProc':
            return None
        text = scope.function.unit.text
        match = re.search(r'Definition v_BehaviorCmdTable := \{\|(.*?)\|\}\.',text,re.S)
        if not match:
            raise RuntimeError('Missing original behavior command table')
        init = re.search(r'gvar_init :=\s*(.*?);',match[1],re.S)
        entries = items(parse(init[1]))
        if len(entries) != 56 or any(n.tag != 'Init_addrof' or str(n.args[1]) != '(Ptrofs.repr 0)' for n in entries):
            raise RuntimeError('Unexpected original behavior command initializer')
        return [n.args[0].tag.removeprefix('_') for n in entries]

    def reference(self,fn):
        key = (str(fn.unit.path),fn.name)
        if self.current_record is not None:
            self.call_edges.setdefault(self.current_record,set()).add(key)
        if key not in self.relations:
            scope = Scope(self,fn)
            depth = z.Int(scope.name+'.call_depth')
            after = z.Array(scope.name+'.output_memory',MEM.domain(),MEM.range())
            out = z.Const(scope.name+'.output_result',scope.result.sort())
            defined = z.Bool(scope.name+'.result_defined')
            params = [scope.temps[p] for p in fn.params]
            arguments = [depth,MEM,*params,after,out,defined]
            relation = z.RecFunction(self.version+'.engine.'+str(self.serial)+'.function.'+scope.name,
                                    *[v.sort() for v in arguments],z.BoolSort())
            record = dict(function=fn,scope=scope,depth=depth,after=after,out=out,defined=defined,
                          arguments=arguments,relation=relation)
            self.relations[key] = record
            self.pending.append(record)
        return self.relations[key]

    def check_local_reentrancy(self):
        """Fail closed before a recursive call can reuse a live local region.

        Shared formulas are safe to reuse for successive ordinary calls in
        this explorer's separated-storage model. Their canonical stack
        addresses are not a model of fresh recursive allocations. Decreasing
        call fuel alone does not fix that aliasing problem.
        """
        for key,record in self.relations.items():
            if not record['function'].locals:
                continue
            pending=list(self.call_edges.get(key,()))
            visited=set()
            while pending:
                callee=pending.pop()
                if callee == key:
                    self.block('recursive-local-storage-not-modelled',record['scope'],
                        'body',record['function'].body,
                        explanation='This call cycle needs fresh local allocations; fixed local addresses cannot stand in for them.')
                if callee not in visited:
                    visited.add(callee)
                    pending.extend(self.call_edges.get(callee,()))

    def loop_context_variables(self):
        return [] if self.current_depth is None else [self.current_depth]

    def traverse(self,statement,normal,scope,returned=None,broken=None,path='body'):
        if statement.tag == 'Sreturn' and statement.args[0].tag == 'None' and self.undefined_return is not None:
            return [Path(self.undefined_return)]
        if statement.tag != 'Scall':
            return super().traverse(statement,normal,scope,returned,broken,path)
        dest,callee,actual = statement.args
        if callee.tag != 'Evar':
            names = self.source_table_targets(scope,callee)
            if names is None:
                self.block('unresolved-indirect-call',scope,path,statement)
            pointer = self.eval(callee,scope)
            cases, guards = [], []
            ftype = self.typeof(callee).args[0]
            for name in names:
                guard = pointer == word(self.function_address(name))
                direct = Term('Scall',(dest,Term('Evar',(Term('_'+name),ftype)),actual))
                pred = self.wp(direct,normal,scope,returned,broken,path+'.target.'+name)[0].condition
                cases.append(z.And(guard,pred)); guards.append(guard)
            self.indirect_domains.append(dict(caller=scope.function.name,path=path,
                sourceTable='BehaviorCmdTable' if scope.function.name == 'cur_obj_update' else 'CALL_NATIVE entries in behavior_data',targets=names,
                unresolved='Prove the live function pointer belongs to these source-initializer targets at this call. Non-members are not ruled out by this exploration.'))
            return [Path(z.Or(*cases))]
        name = callee.args[0].tag.removeprefix('_')
        if name == 'sqrtf' and self.sqrtf_binding:
            expressions = items(actual)
            expected=parse('(Tfunction (tfloat :: nil) tfloat cc_default)')
            if callee.args[-1] != expected or len(expressions)!=1 or self.typeof(expressions[0]).tag != 'tfloat':
                self.block('sqrtf-declaration-mismatch',scope,path,statement)
            argument = self.eval(expressions[0],scope)
            domain = z.And(z.Not(z.fpIsNaN(argument)),z.Not(z.fpIsInf(argument)),
                z.fpGEQ(argument,z.FPVal(0,z.Float32())),
                z.Or(z.fpIsZero(argument),z.fpIsNormal(argument)))
            value = z.fpSqrt(z.RNE(),argument)
            paths = self.substitute(normal,(scope.temps[dest.args[0].tag],value)) if dest.tag=='Some' else normal
            self.library_domains.append(dict(caller=scope.function.name,path=path,
                theorem='SqrtfClightBinding.sb_binding_value_and_frame',
                controls='usable FPU, nearest-even rounding, inexact trapping disabled',
                input='nonnegative finite normal binary32 or signed zero',
                unresolved='Caller input domain and runtime control/binding conditions require discharge. Other inputs are not disproved.'))
            return self.guard(paths,domain,'explicit-sqrtf-binding-domain')
        module = self.INLINE.get(name) or self.resolve_call(name,scope)
        fn = self.function(module,name)
        rec = self.reference(fn)
        exprs = items(actual)
        if len(exprs) != len(fn.params):
            self.block('argument-count',scope,path,statement,callee=name)
        values = [self.cast(self.eval(expr,scope),self.typeof(expr),ty)
                  for expr,ty in zip(exprs,fn.params.values())]
        ident = f'{scope.name}.call.{self.counter}'
        self.counter += 1
        after = z.Array(ident+'.memory',MEM.domain(),MEM.range())
        out = z.Const(ident+'.result',rec['out'].sort())
        defined = z.Bool(ident+'.result_defined')
        pairs = [(MEM,after)]
        if dest.tag == 'Some': pairs.append((scope.temps[dest.args[0].tag],out))
        tail = self.substitute(normal,*pairs)[0].condition
        if dest.tag == 'Some': tail=z.And(defined,tail)
        target = self.target_floor_call and scope.function.name == 'update_mario_platform' and name == 'find_floor'
        if target:
            tail = z.And(tail,z.fpToIEEEBV(out)==word(HEIGHT),
                         z.fpToIEEEBV(values[0])==word(bits(-2200)),
                         z.fpToIEEEBV(values[2])==word(bits(-1024)))
        if self.current_depth is None:
            depth = z.Int(ident+'.depth')
            pred = z.Exists([depth,after,out,defined],z.And(depth>=0,
                rec['relation'](depth,MEM,*values,after,out,defined),tail))
        else:
            pred = z.Exists([after,out,defined],z.And(self.current_depth>0,
                rec['relation'](self.current_depth-1,MEM,*values,after,out,defined),tail))
        self.expanded_calls.append(dict(caller=scope.function.name,callee=name,path=path,method='defined shared source relation'))
        return [Path(pred)]

    def compile_pending(self):
        while self.pending:
            rec = self.pending.pop(0)
            fn,scope = rec['function'],rec['scope']
            goal = z.And(MEM == rec['after'],rec['defined'])
            no_value = z.And(MEM == rec['after'],z.Not(rec['defined']))
            if fn.returns.tag != 'tvoid':
                equality = z.fpToIEEEBV(scope.result)==z.fpToIEEEBV(rec['out']) if z.is_fp(scope.result) else scope.result==rec['out']
                goal = z.And(goal,equality)
            self.current_depth = rec['depth']
            self.current_record = (str(fn.unit.path),fn.name)
            self.undefined_return = no_value
            try:
                # Falling off a non-void body yields Vundef. An ignored return
                # may still complete; a caller consuming a scalar may not.
                normal = [Path(no_value)]
                paths = self.wp(fn.body,normal,scope,[Path(goal)])
                paths = self.close_scope(paths,scope)
            except Unsupported as error:
                self.block('unsupported-function-semantics',scope,'body',fn.body,
                           explanation=str(error))
            finally:
                self.current_depth = None
                self.current_record = None
                self.undefined_return = None
            formula = z.And(rec['depth']>=0,paths[0].condition)
            from loop_engine import get_vars
            allowed = {v.get_id() for v in rec['arguments']}
            unexpected = [v for v in get_vars(formula) if v.get_id() not in allowed]
            if unexpected:
                raise RuntimeError(fn.name+' has uncaptured relation variables: '+str(unexpected))
            z.RecAddDefinition(rec['relation'],rec['arguments'],formula)
            self.definitions.append((rec['relation'],rec['arguments'],formula))
            self.finished_functions.append(fn.name)
            self.relation_receipts.append(dict(function=fn.name,source=fn.digest))
            self.check_local_reentrancy()

    def start(self,function,goal,body=None):
        scope,paths = super().start(function,goal,body)
        self.compile_pending()
        if self.indirect_domains or self.library_domains:
            self.block('explicit-runtime-domains-not-discharged',scope,'body',function.body,
                       indirectDomains=self.indirect_domains,libraryDomains=self.library_domains)
        return scope,paths
