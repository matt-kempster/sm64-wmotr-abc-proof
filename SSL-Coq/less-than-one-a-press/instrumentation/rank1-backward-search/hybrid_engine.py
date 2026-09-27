"""Deferred external calls with an explicit unresolved frontier.

This is a proposal generator. Opaque call predicates are not axioms asserting
memory preservation and are never accepted as gameplay evidence. An anchored
emulator reply constrains only its mapped observed bytes. The complement is
retained. No SAT/UNSAT verdict from this engine discharges the pending frontier.
"""
from clight import items, Term
from engine import MEM, Scope, Path, Unsupported, word, z
from horizon_engine import HorizonEngine
from emulator_oracle import UnmatchedCall


class HybridHorizonEngine(HorizonEngine):
    RUNTIME_BOUNDARIES={'render_game','audio_game_loop_tick'}
    # Optional lazy abstraction for obtaining a first proposal without first
    # building every pause/menu/camera/audio branch. Every omitted call remains
    # a named obligation with unconstrained effects, including observer state.
    SOURCE_SPINE={'thread5_game_loop','read_controller_inputs','run_demo_inputs',
        'adjust_analog_stick','level_script_execute','level_cmd_call_loop',
        'lvl_init_or_update','update_level','play_mode_normal','area_update_objects',
        'update_objects','update_objects_in_list','update_object','cur_obj_update',
        'bhv_cmd_call_native','bhv_mario_update','execute_mario_action',
        'update_mario_platform','find_floor','find_floor_from_list',
        'copy_mario_state_to_object','update_mario_inputs','update_mario_geometry_inputs',
        'vec3f_copy','absf'}

    def __init__(self, version, *, oracle=None, anchors=None, lazy_calls=False, **kwargs):
        super().__init__(version, **kwargs)
        self.lazy_calls=lazy_calls
        self.oracle = oracle
        self.anchors = anchors or {}
        self.deferred = []
        self.replies = []
        self.call_obligations = []
        self.active_loop_scope = None
        self.progress_callback = None

    def reference(self,fn):
        result=super().reference(fn)
        if self.progress_callback is not None:
            self.progress_callback(fn.name)
        return result

    @staticmethod
    def initialized(scope,name):
        return z.Bool(scope.name+'.initialized.'+name)

    def eval(self,expr,scope):
        if expr.tag=='Etempvar' and expr.args[0].tag not in scope.function.params:
            if not self.conversion_guards:
                raise Unsupported('Temporary read outside a guarded statement')
            self.conversion_guards[-1].append(self.initialized(scope,expr.args[0].tag))
        return super().eval(expr,scope)

    def close_scope(self,paths,scope):
        # Path-sensitive Vundef tracking: switch branches that never initialize
        # a later-read temp are excluded by their false definedness flag. No
        # stock switch value is assumed merely to pass a conservative lint.
        pairs=[]
        for name in scope.function.temps.keys()-scope.function.params.keys():
            value=scope.temps[name]
            zero=z.FPVal(0,value.sort()) if z.is_fp(value) else z.BitVecVal(0,value.size())
            pairs.extend([(value,zero),(self.initialized(scope,name),z.BoolVal(False))])
        value=scope.result
        pairs.append((value,z.FPVal(0,value.sort()) if z.is_fp(value) else z.BitVecVal(0,value.size())))
        return self.substitute(paths,*pairs)

    def loop(self,condition,body,increment,normal,scope,returned,path):
        saved=self.active_loop_scope
        self.active_loop_scope=scope
        try:
            return super().loop(condition,body,increment,normal,scope,returned,path)
        finally:
            self.active_loop_scope=saved

    def loop_context_variables(self):
        variables=super().loop_context_variables()
        scope=self.active_loop_scope
        if scope is not None:
            variables += [self.initialized(scope,name) for name in scope.function.temps.keys()-scope.function.params.keys()]
        return variables

    def external_call(self, statement, normal, scope, path):
        dest,callee,actual = statement.args
        direct = callee.tag == 'Evar'
        name = callee.args[0].tag.removeprefix('_') if direct else '<live-indirect-call>'
        signature = self.typeof(callee)
        if signature.tag == 'tptr':
            signature = signature.args[0]
        params,returns,_ = signature.args
        arguments = items(actual)
        types = items(params)
        if len(arguments) != len(types):
            raise Unsupported('External argument count: '+name)
        values = [self.cast(self.eval(expr,scope),self.typeof(expr),ty)
                  for expr,ty in zip(arguments,types)]
        pointer_guard=z.BoolVal(True)
        if not direct:
            pointer=self.eval(callee,scope)
            alternatives=self.image.compatible(signature,scope.function.unit)
            pointer_guard=z.Or(*[pointer==word(self.function_address(s.name)) for s in alternatives])
            values=[pointer,*values]
        ident=f'{scope.name}.deferred.{self.counter}'
        self.counter+=1
        after=z.Array(ident+'.memory',MEM.domain(),MEM.range())
        result_sort={'tfloat':z.Float32(),'tdouble':z.Float64(),
                     'tlong':z.BitVecSort(64),'tulong':z.BitVecSort(64)}.get(returns.tag,z.BitVecSort(32))
        out=z.Const(ident+'.result',result_sort)
        tail=self.substitute(normal,(MEM,after),*([(scope.temps[dest.args[0].tag],out)] if dest.tag=='Some' else []))[0].condition
        # The observer count is also pending: an unspecified external is not
        # silently assumed to preserve it. Constrain it only in an exact
        # experiment or a separately justified domain, never by its name.
        left=z.Int(ident+'.remaining')
        stopped=z.Bool(ident+'.stopped')
        tail=z.substitute(tail,(self.remaining,left))
        if self.stop_post is not None:
            stopped_target=z.BoolVal(True) if self.target is None else z.substitute(self.target,(MEM,after))
            tail=z.Or(z.And(z.Not(stopped),left>0,tail),
                      z.And(stopped,left==0,stopped_target,
                            z.substitute(self.stop_post,(MEM,after),(self.remaining,left))))
        key=(scope.function.name,path,name)
        anchor=self.anchors.get(key)
        answered=False
        entry=z.BoolVal(True)
        relation=z.Function(ident+'.UNRESOLVED',*[v.sort() for v in [MEM,*values,after,out,self.remaining,left,stopped]],z.BoolSort())(
            MEM,*values,after,out,self.remaining,left,stopped)
        if self.oracle is not None:
            try:
                if self.version != 'jp':
                    raise UnmatchedCall('JP observations cannot answer US calls')
                entry,effect=self.oracle.facts(self,name,anchor,MEM,after,out)
                symbol={'osContStartReadData':'_gSIEventMesgQueue','osContGetReadData':'_gControllerPads'}[name]
                entry=z.And(entry,values[0]==word(self.global_address(symbol)))
                # These observed controller calls did not cross a retention
                # checkpoint. This is a fact only about this anchored case.
                relation=z.And(effect,left==self.remaining,z.Not(stopped))
                answered=True
                self.replies.append(dict(caller=scope.function.name,callee=name,path=path,
                    anchor=anchor.__dict__,scope='Observed mapped bytes only; outside memory remains open.'))
            except UnmatchedCall as exc:
                reason=str(exc)
        else:
            reason='No emulator oracle supplied'
        record=dict(caller=scope.function.name,callee=name,path=path,source=scope.function.digest,
                    request=ident,matchedReplay=answered)
        if not answered:
            record['reason']=reason
            self.deferred.append(record)
        self.call_obligations.append(dict(record,before=MEM,after=after,result=out,
            arguments=values,remaining=left,stopped=stopped,relation=relation))
        # Existentials carry the exact continuation backward across the call;
        # unlike an assumed frame, both memory and observer effects are open.
        return [Path(z.And(pointer_guard,entry,z.Exists([after,out,left,stopped],z.And(relation,tail))))]

    def traverse(self, statement, normal, scope, returned=None, broken=None, path='body'):
        if statement.tag=='Sset':
            name,expr=statement.args
            return self.substitute(normal,(scope.temps[name.tag],self.eval(expr,scope)),
                                   (self.initialized(scope,name.tag),z.BoolVal(True)))
        if statement.tag=='Scall' and statement.args[0].tag=='Some':
            name=statement.args[0].args[0].tag
            normal=self.substitute(normal,(self.initialized(scope,name),z.BoolVal(True)))
        if statement.tag=='Sassign' and self.typeof(statement.args[0]).tag in ('Tstruct','Tunion'):
            lhs,rhs=statement.args
            ty=self.typeof(lhs)
            if self.typeof(rhs)!=ty:
                raise Unsupported('Aggregate assignment changes composite type')
            size,alignment=scope.function.unit.size(ty)
            target,source=self.location(lhs,scope),self.eval(rhs,scope)
            memory=MEM
            for i in range(size):
                memory=z.Store(memory,target+word(i),z.Select(MEM,source+word(i)))
            # CompCert aggregate assignment permits the same address or
            # disjoint ranges. Read all RHS bytes from the pre-store memory.
            target_wide,source_wide=z.ZeroExt(1,target),z.ZeroExt(1,source)
            size_wide=z.BitVecVal(size,33)
            valid=z.And(z.ULE(target_wide+size_wide,z.BitVecVal(2**32,33)),
                z.ULE(source_wide+size_wide,z.BitVecVal(2**32,33)),
                z.URem(target,word(alignment))==0,z.URem(source,word(alignment))==0,
                z.Or(target==source,z.ULE(target_wide+size_wide,source_wide),
                     z.ULE(source_wide+size_wide,target_wide)))
            return self.guard(self.substitute(normal,(MEM,memory)),valid,'defined-aggregate-assignment')
        if statement.tag=='Scall' and statement.args[1].tag!='Evar':
            # Explore actual source bodies under pointer guards. These hints
            # order work; the complement remains an unresolved call, never
            # an assumption that writable scripts retain their initial value.
            hints={'level_script_execute':['level_cmd_call_loop'],
                   'level_cmd_call_loop':['lvl_init_or_update'],
                   'bhv_cmd_call_native':['bhv_mario_update','bhv_pyramid_top_loop',
                                          'load_object_collision_model']}.get(scope.function.name,[])
            if scope.function.name=='cur_obj_update':
                hints=self.source_table_targets(scope,statement.args[1]) or []
            if hints:
                dest,callee,args=statement.args
                pointer=self.eval(callee,scope)
                alternatives=[];guards=[]
                for name in hints:
                    symbol=self.image.symbols.get(name)
                    if symbol is None or not symbol.internal:
                        raise Unsupported('Missing generated dispatch hint '+name)
                    guard=pointer==word(self.function_address(name));guards.append(guard)
                    call=Term('Scall',(dest,Term('Evar',(Term('_'+name),symbol.signature)),args))
                    result=self.traverse(call,normal,scope,returned,broken,path+'.target.'+name)
                    alternatives+=self.guard(result,guard,'live-pointer-'+name)
                unresolved=self.external_call(statement,normal,scope,path+'.unmatched')
                alternatives+=self.guard(unresolved,z.Not(z.Or(*guards)),'unobserved-live-pointer')
                return [Path(z.Or(*[p.condition for p in alternatives]))]
            return self.external_call(statement,normal,scope,path)
        if statement.tag=='Scall' and statement.args[1].tag=='Evar':
            name=statement.args[1].args[0].tag.removeprefix('_')
            entry=self.image.symbols.get(name) if self.image is not None else None
            if name!='sqrtf' and (name in self.RUNTIME_BOUNDARIES
                or (self.lazy_calls and name not in self.SOURCE_SPINE)
                or (entry is not None and not entry.internal)):
                return self.external_call(statement,normal,scope,path)
        return super().traverse(statement,normal,scope,returned,broken,path)

    def start_horizon(self,function,goal,body,*,entry_condition=None):
        # Same actual loop, target and checkpoint handling as HorizonEngine.
        # Deferred calls are reported, rather than treated as implementations.
        self.target=goal
        self.stop_post=z.BoolVal(True)
        scope=Scope(self,function)
        context=z.BoolVal(True) if entry_condition is None else entry_condition
        self.dispatch_entry=(scope,context,body)
        try:
            paths=self.wp(body,[Path(z.BoolVal(False))],scope,[Path(z.BoolVal(False))])
        finally:
            self.dispatch_entry=None
        self.compile_pending()
        paths=self.substitute(paths,(self.remaining,z.IntVal(self.updates)))
        return scope,self.guard(paths,context,'explicit-hybrid-horizon-entry')
