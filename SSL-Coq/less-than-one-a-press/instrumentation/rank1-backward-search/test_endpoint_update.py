"""Coverage controls. Synthetic harnesses are never gameplay witnesses."""
from dataclasses import replace
import unittest
from clight import ROOT, Term, parse, walk, is_variadic, seq
from engine import MEM, Path, Scope, read, word, z
from hybrid_engine import HybridHorizonEngine
from horizon_engine import HorizonEngine
from checkpoint_graph import CheckpointGraph
from endpoint_update import EndpointEngine, syntactically_false, archive_definitions
from loop_engine import LoopEngine, get_vars
from global_storage import GlobalStorage, storage_type


class EndpointTests(unittest.TestCase):
    def test_window_stops_at_thirtieth_check_and_keeps_earlier_effects(self):
        # Synthetic counter harness, not thirty SM64 gameplay updates.
        for expected,answer in ((320,'sat'),(330,'unsat')):
            e=HybridHorizonEngine('jp',updates=30,program_dispatch=False,live_dispatch=False,
                fresh_call_frames=True,checkpoint=('test_window','get_current_clock'),
                loop_fuel=30,call_fuel=0)
            fn=e.function('debug','get_current_clock')
            call=parse('(Scall None (Evar _get_current_clock (Tfunction nil tulong cc_default)) nil)')
            def add(n):
                return parse(f'(Sassign (Evar _window_counter tint) (Ebinop Oadd (Evar _window_counter tint) (Econst_int (Int.repr {n}) tint) tint))')
            loop=Term('Swhile',(parse('(Econst_int (Int.repr 1) tint)'),seq([add(1),call,add(10)])))
            harness=replace(fn,name='test_window',body=loop,temps={},params={},locals={})
            address=e.global_address('_window_counter')
            _,paths=EndpointEngine.start_window(e,harness,loop,
                read(MEM,word(address))==word(expected),read(MEM,word(address))==word(0))
            self.assertEqual(e.solve(paths[0].condition)[0],answer)

    def test_definition_archive_keeps_exact_named_bodies(self):
        import hashlib,json,tempfile
        from pathlib import Path as FilePath
        from types import SimpleNamespace
        n=z.Int('archive.n');f=z.RecFunction('archive.fn',z.IntSort(),z.BoolSort())
        body=z.If(n<=0,z.BoolVal(True),f(n-1))
        z.RecAddDefinition(f,[n],body)
        with tempfile.TemporaryDirectory() as directory:
            path=FilePath(directory)/'definitions.jsonl'
            digest=archive_definitions(SimpleNamespace(definitions=[(f,[n],body)]),path,f(n))
            self.assertEqual(digest,hashlib.sha256(path.read_bytes()).hexdigest())
            records=[json.loads(line) for line in path.read_text().splitlines()]
            self.assertEqual(records[1]['body'],body.sexpr())
            self.assertEqual(records[2]['body'],f(n).sexpr())

    def test_compact_globals_cover_more_than_the_old_arena_without_overlap(self):
        from types import SimpleNamespace
        names=['_small_'+str(n) for n in range(2000)]
        unit=SimpleNamespace(
            text='\n'.join('Definition v'+n+' := {| gvar_info := tint; gvar_init := nil; |}.' for n in names),
            global_definitions=lambda:{n:Term('Gvar',(Term('v'+n),)) for n in names},
            size=lambda ty:(4,4))
        storage=GlobalStorage([unit])
        addresses=[storage.address(n) for n in names]
        self.assertEqual(len(set(addresses)),2000)
        self.assertTrue(all(b>=a+4 for a,b in zip(addresses,addresses[1:])))
        self.assertLess(storage.next_address,0x10010000)
        self.assertFalse(storage.unknown_extents)
        self.assertEqual(storage_type(parse('(tvolatile tint)')),Term('tint'))

    def test_real_object_pool_extent_and_symbolic_endpoint_identities(self):
        from clight import Unit
        units=[Unit('jp','object_list_processor'),Unit('jp','platform_displacement'),Unit('jp','behavior_data')]
        storage=GlobalStorage(units)
        self.assertEqual(storage.layouts['_gObjectPool'][0],240*608)
        e=HybridHorizonEngine('jp',updates=1,program_dispatch=False)
        e.global_address=storage.address
        e.target_mario=z.BitVec('endpoint.test.mario',32)
        e.target_top=z.BitVec('endpoint.test.top',32)
        goal=EndpointEngine.retention_target(e)
        pool=storage.address('_gObjectPool')
        s=z.Solver();s.add(goal,e.target_mario==word(pool),e.target_top==word(pool+7*608))
        self.assertEqual(s.check(),z.sat)
        s.add(e.target_top==e.target_mario);self.assertEqual(s.check(),z.unsat)

    def test_mixed_long_arithmetic_uses_c_width_and_signedness(self):
        e=LoopEngine('jp');scope=Scope(e,e.function('debug','get_current_clock'))
        def value(text):
            e.conversion_guards.append([])
            try:return e.eval(parse(text),scope),list(e.conversion_guards[-1])
            finally:e.conversion_guards.pop()
        unsigned32='(Econst_int (Int.repr 4294967295) tuint)'
        minus1='(Econst_long (Int64.repr (-1)) tlong)'
        one='(Econst_long (Int64.repr 1) tulong)'
        result,guards=value('(Ebinop Oadd '+unsigned32+' '+minus1+' tlong)')
        self.assertEqual(z.simplify(result).as_long(),4294967294)
        result,guards=value('(Ebinop Olt '+minus1+' '+one+' tint)')
        self.assertEqual(z.simplify(result).as_long(),0)
        result,guards=value('(Ebinop Omul (Econst_int (Int.repr 1000000) tint) '+one+' tulong)')
        self.assertEqual(z.simplify(result).as_long(),1000000)
        result,guards=value('(Ebinop Odiv (Econst_long (Int64.repr 9223372036854775808) tlong) '+minus1+' tlong)')
        self.assertTrue(z.is_false(z.simplify(z.And(*guards))))

    def test_target_height_does_not_constrain_an_earlier_noncheckpoint_call(self):
        e=HorizonEngine('jp',updates=1,program_dispatch=False,live_dispatch=False,
                        target_specific_query=True)
        owner=e.function('platform_displacement','update_mario_platform')
        floor=e.function('surface_collision','find_floor')
        # Test double checks only the observer's scope, never a game floor.
        fake=replace(floor,temps={},locals={},body=parse('''(Sreturn
            (Some (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)))'''))
        original=e.function
        e.function=lambda module,name: fake if name=='find_floor' else original(module,name)
        e.INLINE=dict(e.INLINE,find_floor='surface_collision')
        scope=Scope(e,owner)
        call=next(n for _,n in walk(owner.body) if n.tag=='Scall' and n.args[1].tag=='Evar'
                  and n.args[1].args[0].tag=='_find_floor')
        e.stop_post=z.BoolVal(False)
        pre=e.wp(call,[Path(z.BoolVal(True))],scope)[0].condition
        e.compile_pending()
        s=z.Solver();s.set(timeout=10000);s.add(pre,e.remaining==1,z.Not(e.target_floor_call))
        self.assertEqual(s.check(),z.sat)
        s=z.Solver();s.set(timeout=10000);s.add(pre,e.remaining==1,e.target_floor_call)
        self.assertEqual(s.check(),z.unsat)

    def test_shared_continuation_retains_every_free_value_and_memory_write(self):
        e=HybridHorizonEngine('jp',updates=1,program_dispatch=False)
        e.shared_continuations=[]
        fn=e.function('debug','get_current_clock');scope=Scope(e,fn)
        value=z.BitVec('continuation.value',32)
        condition=z.And(read(MEM,word(1234))==value,e.remaining==1)
        shared=EndpointEngine.share_continuation(e,[Path(condition)],scope,'test')[0].condition
        self.assertEqual({v.get_id() for v in get_vars(shared)},
                         {v.get_id() for v in get_vars(condition)})
        s=z.Solver();s.add(shared!=condition);self.assertEqual(s.check(),z.unsat)
        from engine import write
        changed=write(MEM,word(1234),word(7),4)
        actual=z.substitute(shared,(MEM,changed))
        s=z.Solver();s.add(actual!=z.And(value==word(7),e.remaining==1))
        self.assertEqual(s.check(),z.unsat)

    def test_false_pruning_never_unfolds_a_recursive_predicate(self):
        n=z.Int('false_test.n')
        rec=z.RecFunction('false_test.rec',z.IntSort(),z.BoolSort())
        z.RecAddDefinition(rec,[n],z.If(n<=0,z.BoolVal(False),rec(n-1)))
        self.assertFalse(syntactically_false(rec(1000000)))
        self.assertTrue(syntactically_false(z.And(rec(1000000),z.BoolVal(False))))

    def test_variadic_detection_reads_the_emitted_calling_convention(self):
        self.assertFalse(is_variadic(parse('(Tfunction nil tint cc_default)')))
        self.assertFalse(is_variadic(parse('(Tfunction nil tint (CallingConvention None false false))')))
        self.assertTrue(is_variadic(parse('(Tfunction nil tint (CallingConvention (Some 0) false false))')))

    def test_switch_fallthrough_break_and_default_are_exact(self):
        e=LoopEngine('jp')
        base=e.function('debug','get_current_clock')
        body=parse('''(Ssequence (Sset _answer (Econst_int (Int.repr 5) tint))
          (Ssequence (Sswitch (Etempvar _choice tint)
            (LScons (Some 0)
              (Sset _answer (Ebinop Oadd (Etempvar _answer tint) (Econst_int (Int.repr 2) tint) tint))
            (LScons (Some 1)
              (Ssequence (Sset _answer (Ebinop Oadd (Etempvar _answer tint) (Econst_int (Int.repr 3) tint) tint)) Sbreak)
            (LScons None (Sset _answer (Econst_int (Int.repr 99) tint)) LSnil))))
            (Sreturn (Some (Etempvar _answer tint)))))''')
        fn=replace(base,name='test_switch',params={'_choice':Term('tint')},
                   temps={'_answer':Term('tint')},locals={},returns=Term('tint'),body=body)
        scope=Scope(e,fn);out=z.BitVec('switch.out',32)
        pre=e.close_scope(e.wp(body,[Path(scope.result==out)],scope),scope)[0].condition
        choice=scope.temps['_choice']
        expected=z.If(choice==word(0),word(10),z.If(choice==word(1),word(8),word(99)))
        s=z.Solver();s.add(pre!=(out==expected));self.assertEqual(s.check(),z.unsat)

    def test_unanswered_atomic_call_cannot_finish_or_advance_the_horizon(self):
        for version in ('us','jp'):
            e=HybridHorizonEngine(version,updates=1,program_dispatch=False)
            fn=e.function('game_init','thread5_game_loop');scope=Scope(e,fn)
            call=next(n for _,n in walk(fn.body) if n.tag=='Scall'
                      and n.args[1].tag=='Evar' and n.args[1].args[0].tag=='_osContStartReadData')
            e.stop_post=z.BoolVal(True);e.target=z.BoolVal(True)
            pre=e.external_call(call,[Path(z.BoolVal(False))],scope,'no-real-checkpoint')[0].condition
            s=z.Solver();s.add(pre,e.remaining==1)
            self.assertEqual(s.check(),z.unsat)
            e.stop_post=z.BoolVal(False)
            pre=e.external_call(call,[Path(e.remaining==0)],scope,'no-counter-change')[0].condition
            s=z.Solver();s.add(pre,e.remaining==1)
            self.assertEqual(s.check(),z.unsat)
            self.assertTrue(e.deferred[-1]['atomicExternal'])

    def test_sqrt_without_a_binding_keeps_the_call_pending(self):
        e=HybridHorizonEngine('jp',updates=1,program_dispatch=True,sqrtf_binding=False)
        fn=e.function('object_helpers','dist_between_objects');scope=Scope(e,fn)
        call=next(n for _,n in walk(fn.body) if n.tag=='Scall' and n.args[1].tag=='Evar'
                  and n.args[1].args[0].tag=='_sqrtf')
        e.stop_post=z.BoolVal(False)
        # No operand domain is silently discarded as it was by the optional
        # domain-limited binding. The output and memory remain unanswered.
        pre=e.wp(call,[Path(z.BoolVal(True))],scope)[0].condition
        s=z.Solver();s.add(pre,e.remaining==1)
        # The actual argument temporary must have been set on this path.
        for name in fn.temps:s.add(e.initialized(scope,name))
        self.assertEqual(s.check(),z.sat)
        self.assertEqual(e.deferred[-1]['callee'],'sqrtf')
        self.assertFalse(e.library_domains)

    def test_graph_keeps_all_indirect_targets_and_does_not_frame_memory(self):
        e=HybridHorizonEngine('jp',updates=1,program_dispatch=True,runtime_audio=True,
            supplemental=ROOT/'build/rank1-backward-search/supplemental-generated')
        graph=CheckpointGraph(e,e.checkpoint);e.checkpoint_graph=graph
        self.assertEqual(graph.seeds,{'update_objects'})
        self.assertIn('area_update_objects',graph.reaches)
        self.assertNotIn('osContGetReadData',graph.reaches)
        fn=e.function('behavior_script','bhv_cmd_call_native');scope=Scope(e,fn)
        call=next(n for _,n in walk(fn.body) if n.tag=='Scall')
        self.assertEqual(set(graph.targets(call,fn.unit)),
                         {s.name for s in e.image.compatible(e.typeof(call.args[1]),fn.unit)})
        # A deferred known no-checkpoint body cannot finish a target, but its
        # unknown memory effects are not turned into a blanket frame.
        caller=e.function('game_init','thread5_game_loop');scope=Scope(e,caller)
        direct=parse('(Scall None (Evar _get_current_clock (Tfunction nil tulong cc_default)) nil)')
        e.stop_post=z.BoolVal(False)
        pre=e.external_call(direct,[Path(read(MEM,word(0x123456))==word(7))],scope,'unknown-memory')[0].condition
        s=z.Solver();s.add(pre,e.remaining==1,read(MEM,word(0x123456))==word(9))
        self.assertEqual(s.check(),z.sat)
        self.assertFalse(e.deferred[-1]['mayCrossCheckpoint'])

    def test_recursive_local_frames_have_distinct_live_addresses(self):
        e=HorizonEngine('jp',updates=1,program_dispatch=False,live_dispatch=False,
                        fresh_call_frames=True)
        base=e.function('debug','get_current_clock')
        fn=replace(base,name='test_recursive_frame',locals={'_local':Term('tint')})
        rec=e.reference(fn);scope=rec['scope']
        self.assertEqual(scope.frame_bytes,16)
        parent=scope.local_addresses['_local']
        child=z.substitute(parent,(scope.frame_base,scope.frame_base+word(scope.frame_bytes)))
        s=z.Solver();s.add(e.frame_domain(scope),parent==child)
        self.assertEqual(s.check(),z.unsat)
        # Near the arena boundary an overflowing allocation is refused.
        s=z.Solver();s.add(e.frame_domain(scope),scope.frame_base==word(0xfffffff0))
        self.assertEqual(s.check(),z.unsat)
        self.assertIn(scope.frame_base.get_id(),[v.get_id() for v in rec['arguments']])

    def test_original_controller_decoder_has_a_generated_body(self):
        for version in ('us','jp'):
            e=HybridHorizonEngine(version,updates=1,program_dispatch=True,
                supplemental=ROOT/'build/rank1-backward-search/supplemental-generated')
            for name in ('osContGetReadData','osContStartReadData','osRecvMesg'):
                self.assertTrue(e.image.symbols[name].internal)
            fn=e.function(e.image.symbols['osContGetReadData'].unit,'osContGetReadData')
            rec=e.reference(fn);e.stop_post=z.BoolVal(False);e.compile_pending()
            self.assertFalse(e.deferred)
            self.assertEqual([r['function'] for r in e.relation_receipts],['osContGetReadData'])
            self.assertTrue(e.loops)

    def test_original_message_queue_initializer_writes_only_its_queue(self):
        for version in ('us','jp'):
            e=HybridHorizonEngine(version,updates=1,program_dispatch=False,
                supplemental=ROOT/'build/rank1-backward-search/supplemental-generated')
            fn=e.function('supplemental/os_create_message_queue','osCreateMesgQueue')
            scope=Scope(e,fn);queue=0x04000000
            size,_,fields=fn.unit.layout('_OSMesgQueue_s')
            tail=e.global_address('___osThreadTail_fix')
            tail+=fn.unit.layout('_OSThread_ListHead_s')[2]['_next']
            expected={'_mtqueue':word(tail),'_fullqueue':word(tail),'_validCount':word(0),
                      '_first':word(0),'_msgCount':scope.temps['_count'],'_msg':scope.temps['_msgBuf']}
            other=z.BitVec('queue.other.'+version,32);saved=z.BitVec('queue.saved.'+version,8)
            entry=z.And(scope.temps['_mq']==word(queue),
                        z.Or(z.ULT(other,word(queue)),z.UGE(other,word(queue+size))),
                        z.Select(MEM,other)==saved)
            goal=z.And(*[read(MEM,word(queue+fields[name]))==value for name,value in expected.items()],
                       z.Select(MEM,other)==saved)
            pre=e.close_scope(e.wp(fn.body,[Path(goal)],scope),scope)[0].condition
            s=z.Solver();s.set(timeout=10000);s.add(entry,z.Not(pre))
            self.assertEqual(s.check(),z.unsat)

    def test_recursive_execution_keeps_the_parents_local_value(self):
        e=HorizonEngine('jp',updates=1,program_dispatch=False,live_dispatch=False,
                        fresh_call_frames=True)
        base=e.function('debug','get_current_clock')
        body=parse('''(Ssequence
            (Sassign (Evar _slot tint) (Etempvar _n tint))
            (Ssequence
              (Sifthenelse (Ebinop Ogt (Etempvar _n tint) (Econst_int (Int.repr 0) tint) tint)
                (Scall None (Evar _test_rec (Tfunction (tint :: nil) tint cc_default))
                  ((Ebinop Osub (Etempvar _n tint) (Econst_int (Int.repr 1) tint) tint) :: nil)) Sskip)
              (Sreturn (Some (Evar _slot tint)))))''')
        fn=replace(base,name='test_rec',params={'_n':Term('tint')},temps={},
                   locals={'_slot':Term('tint')},returns=Term('tint'),body=body)
        original=e.function
        e.function=lambda module,name: fn if name=='test_rec' else original(module,name)
        e.INLINE=dict(e.INLINE,test_rec='test')
        rec=e.reference(fn);e.stop_post=z.BoolVal(False);e.compile_pending()
        after=z.Array('recursive.after',MEM.domain(),MEM.range());out=z.BitVec('recursive.out',32)
        relation=rec['relation'](z.IntVal(2),MEM,word(2),after,out,z.BoolVal(True),
                                z.IntVal(1),z.IntVal(1),z.BoolVal(False),word(0x80000000))
        s=z.Solver();s.set(timeout=10000);s.add(relation)
        self.assertEqual(s.check(),z.sat)
        s.add(out!=word(2));self.assertEqual(s.check(),z.unsat)

    def test_forward_goto_skips_intervening_writes(self):
        e=HybridHorizonEngine('jp',updates=1,program_dispatch=False)
        base=e.function('debug','get_current_clock')
        body=parse('''(Ssequence (Sset _answer (Econst_int (Int.repr 7) tint))
          (Ssequence (Sgoto _done)
            (Ssequence (Sset _answer (Econst_int (Int.repr 99) tint))
              (Slabel _done (Sreturn (Some (Etempvar _answer tint)))))))''')
        fn=replace(base,name='test_forward_goto',params={},temps={'_answer':Term('tint')},
                   locals={},returns=Term('tint'),body=body)
        for value,expected in ((7,z.sat),(99,z.unsat)):
            scope=Scope(e,fn)
            pre=e.close_scope(e.wp(body,[Path(scope.result==word(value))],scope),scope)[0].condition
            s=z.Solver();s.add(pre);self.assertEqual(s.check(),expected)

    def test_controller_decoder_copies_all_symbolic_button_and_stick_bits(self):
        for version in ('us','jp'):
            e=HybridHorizonEngine(version,updates=1,program_dispatch=False,loop_fuel=2,
                supplemental=ROOT/'build/rank1-backward-search/supplemental-generated')
            fn=e.function('supplemental/os_controller_read','osContGetReadData');scope=Scope(e,fn)
            pif=e.global_address('___osContPifRam');count=e.global_address('___osMaxControllers')
            pad=0x04000000
            button=z.BitVec('decode.button.'+version,16)
            x,y=z.BitVecs('decode.x.'+version+' decode.y.'+version,8)
            entry=z.And(scope.temps['_pad']==word(pad),read(MEM,word(count),1)==z.BitVecVal(1,8),
                        read(MEM,word(pif+2),1)==z.BitVecVal(4,8),
                        read(MEM,word(pif+4),2)==button,
                        read(MEM,word(pif+6),1)==x,read(MEM,word(pif+7),1)==y)
            goal=z.And(read(MEM,word(pad),2)==button,read(MEM,word(pad+2),1)==x,
                       read(MEM,word(pad+3),1)==y,read(MEM,word(pad+4),1)==z.BitVecVal(0,8))
            pre=e.close_scope(e.wp(fn.body,[Path(goal)],scope),scope)[0].condition
            s=z.Solver();s.set(timeout=10000);s.add(entry,z.Not(pre))
            self.assertEqual(s.check(),z.unsat)


if __name__=='__main__':unittest.main()
