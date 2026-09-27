"""Finite prefixes ending at the Nth actual retention call in a game loop.

The counter and stop flag are observer state, never SM64 memory. Earlier calls
return through their real callers and execute their tails. Only the last
checkpoint stops the prefix; it unwinds without executing later statements.
This encodes a requested horizon, not a claim that it can be solved.
"""
from clight import Term, items
from engine import MEM, Path, Scope, word, read, z
from loop_engine import get_vars
from relational_engine import RelationalEngine
from search import HEIGHT, bits


class HorizonEngine(RelationalEngine):
    def __init__(self, version, *, updates, checkpoint=None, **kwargs):
        if updates < 1:
            raise ValueError('The horizon must be positive')
        kwargs.setdefault('live_dispatch', True)
        kwargs.setdefault('program_dispatch', True)
        self.call_fuel = kwargs.pop('call_fuel',None)
        super().__init__(version, **kwargs)
        self.updates = updates
        self.checkpoint = checkpoint or ('update_objects', 'update_mario_platform')
        self.remaining = z.Int(f'{version}.engine.{self.serial}.updates_remaining')
        self.stop_post = None
        self.target = None
        self.target_floor_call = False
        self.horizon_receipts = []

    def reference(self, fn):
        record = super().reference(fn)
        if 'after_remaining' not in record:
            scope = record['scope']
            record['after_remaining'] = z.Int(scope.name+'.output_remaining')
            record['stopped'] = z.Bool(scope.name+'.stopped_at_target')
            record['arguments'] += [self.remaining, record['after_remaining'], record['stopped']]
            record['relation'] = z.RecFunction(
                self.version+'.horizon.'+str(self.serial)+'.function.'+scope.name,
                *[v.sort() for v in record['arguments']], z.BoolSort())
        return record

    def loop_context_variables(self):
        return super().loop_context_variables()+[self.remaining]

    def traverse(self, statement, normal, scope, returned=None, broken=None, path='body'):
        if statement.tag != 'Scall' or statement.args[1].tag != 'Evar':
            return super().traverse(statement,normal,scope,returned,broken,path)
        dest, callee, actual = statement.args
        name = callee.args[0].tag.removeprefix('_')
        # The existing explicit sqrt binding changes no observer state.
        if name == 'sqrtf' and self.sqrtf_binding:
            return super().traverse(statement,normal,scope,returned,broken,path)
        module = self.INLINE.get(name) or self.resolve_call(name,scope)
        fn = self.function(module,name)
        rec = self.reference(fn)
        exprs = items(actual)
        if len(exprs) != len(fn.params):
            self.block('argument-count',scope,path,statement,callee=name)
        values = [self.cast(self.eval(expr,scope),self.typeof(expr),ty)
                  for expr,ty in zip(exprs,fn.params.values())]
        ident = f'{scope.name}.horizon_call.{self.counter}'
        self.counter += 1
        after = z.Array(ident+'.memory',MEM.domain(),MEM.range())
        out = z.Const(ident+'.result',rec['out'].sort())
        defined = z.Bool(ident+'.result_defined')
        left = z.Int(ident+'.remaining')
        stopped = z.Bool(ident+'.stopped')
        # This event is AFTER the original callee returns. It does not skip
        # its execution, assume its floor result, or stop earlier iterations.
        if (scope.function.name,name) == self.checkpoint:
            if self.target is None or self.stop_post is None:
                raise RuntimeError('Checkpoint without an active horizon target')
            continuation = z.Or(
                z.And(self.remaining == 1, self.target,
                      z.substitute(self.stop_post,(self.remaining,z.IntVal(0)))),
                z.And(self.remaining > 1,
                      z.substitute(normal[0].condition,(self.remaining,self.remaining-1))))
            normal = [Path(continuation)]
            self.horizon_receipts.append(dict(caller=scope.function.name,callee=name,path=path,
                meaning='Observe a completed real call; stop only when the remaining count is one.'))
        # A no-new-A window is checked at each actual controller call, not supplied
        # as a freely chosen edge flag after action execution.
        if scope.function.name == 'thread5_game_loop' and name == 'read_controller_inputs':
            unit = self.unit('game_init')
            fields = unit.layout('_Controller')[2]
            controller = read(MEM,word(self.global_address('_gPlayer1Controller')))
            mask = read(MEM,controller+word(fields['_buttonPressed']),2)
            normal = self.guard(normal,(mask & z.BitVecVal(0x8000,16)) == z.BitVecVal(0,16),
                                'no-new-A-at-each-controller-boundary')
        normal_pairs = [(MEM,after),(self.remaining,left)]
        if dest.tag == 'Some':
            normal_pairs.append((scope.temps[dest.args[0].tag],out))
        normal_tail = self.substitute(normal,*normal_pairs)[0].condition
        if dest.tag == 'Some':
            normal_tail = z.And(defined,normal_tail)
        # Only the LAST floor query is targeted. Requiring all 30 queries to
        # retain TOP would silently discard possible producers.
        if scope.function.name == 'update_mario_platform' and name == 'find_floor':
            normal_tail = z.And(normal_tail,z.Implies(self.remaining == 1,z.And(
                z.fpToIEEEBV(out) == word(HEIGHT),
                z.fpToIEEEBV(values[0]) == word(bits(-2200)),
                z.fpToIEEEBV(values[2]) == word(bits(-1024)))))
        if self.stop_post is None:
            raise RuntimeError('A horizon call needs a stop continuation')
        stop_tail = z.substitute(self.stop_post,(MEM,after),(self.remaining,left))
        tail = z.Or(z.And(stopped,left == 0,stop_tail),
                    z.And(z.Not(stopped),left > 0,normal_tail))
        relation_args = [MEM,*values,after,out,defined,self.remaining,left,stopped]
        variables = [after,out,defined,left,stopped]
        if self.current_depth is None:
            if self.call_fuel is not None:
                # Explicit regression/search bound, never silently enabled.
                pred = z.Exists(variables,z.And(self.call_fuel >= 0,
                    rec['relation'](z.IntVal(self.call_fuel),*relation_args),tail))
            else:
                depth = z.Int(ident+'.depth')
                pred = z.Exists([depth]+variables,z.And(depth >= 0,
                    rec['relation'](depth,*relation_args),tail))
        else:
            pred = z.Exists(variables,z.And(self.current_depth > 0,
                rec['relation'](self.current_depth-1,*relation_args),tail))
        self.expanded_calls.append(dict(caller=scope.function.name,callee=name,path=path,
                                       method='actual body with checkpoint counter and stop propagation'))
        return [Path(pred)]

    def compile_pending(self):
        while self.pending:
            rec = self.pending.pop(0)
            fn,scope = rec['function'],rec['scope']
            frame = z.And(MEM == rec['after'],self.remaining == rec['after_remaining'])
            goal = z.And(frame,z.Not(rec['stopped']),rec['defined'])
            no_value = z.And(frame,z.Not(rec['stopped']),z.Not(rec['defined']))
            if fn.returns.tag != 'tvoid':
                equality = (z.fpToIEEEBV(scope.result) == z.fpToIEEEBV(rec['out'])
                            if z.is_fp(scope.result) else scope.result == rec['out'])
                goal = z.And(goal,equality)
            saved_stop = self.stop_post
            self.stop_post = z.And(frame,rec['stopped'],self.remaining == 0,z.Not(rec['defined']))
            self.current_depth = rec['depth']
            self.current_record = (str(fn.unit.path),fn.name)
            self.undefined_return = no_value
            try:
                paths = self.wp(fn.body,[Path(no_value)],scope,[Path(goal)])
                paths = self.close_scope(paths,scope)
            finally:
                self.current_depth = None
                self.current_record = None
                self.undefined_return = None
                self.stop_post = saved_stop
            formula = z.And(rec['depth'] >= 0,self.remaining > 0,paths[0].condition)
            allowed = {v.get_id() for v in rec['arguments']}
            unexpected = [v for v in get_vars(formula) if v.get_id() not in allowed]
            if unexpected:
                raise RuntimeError(fn.name+' has uncaptured horizon variables: '+str(unexpected))
            z.RecAddDefinition(rec['relation'],rec['arguments'],formula)
            self.definitions.append((rec['relation'],rec['arguments'],formula))
            self.finished_functions.append(fn.name)
            self.relation_receipts.append(dict(function=fn.name,source=fn.digest))
            self.check_local_reentrancy()

    def start_horizon(self,function,goal,body,*,entry_condition=None):
        self.target = goal
        self.stop_post = z.BoolVal(True)
        scope = Scope(self,function)
        context = z.BoolVal(True) if entry_condition is None else entry_condition
        self.dispatch_entry = (scope,context,body)
        try:
            # Ordinary return/end is NOT completion: the checkpoint must fire.
            paths = self.wp(body,[Path(z.BoolVal(False))],scope,[Path(z.BoolVal(False))])
        finally:
            self.dispatch_entry = None
        self.compile_pending()
        if self.indirect_domains or self.library_domains:
            self.block('explicit-runtime-domains-not-discharged',scope,'body',body,
                       indirectDomains=self.indirect_domains,libraryDomains=self.library_domains)
        paths = self.substitute(paths,(self.remaining,z.IntVal(self.updates)))
        return scope,self.guard(paths,context,'explicit-horizon-entry')
