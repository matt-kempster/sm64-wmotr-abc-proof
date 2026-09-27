"""Adversarial checks for the call bridge, independent of an emulator run."""
import json
from pathlib import Path as FilePath
import tempfile
import unittest
from dataclasses import replace

from clight import walk, parse, Term
from engine import MEM, Scope, Path, read, word, z
from emulator_oracle import EmulatorOracle, ReplayAnchor, UnmatchedCall
from hybrid_engine import HybridHorizonEngine


class OracleTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.e=HybridHorizonEngine('jp',updates=30,program_dispatch=False)
        cls.fn=cls.e.function('game_init','thread5_game_loop')
        cls.call=next(node for _,node in walk(cls.fn.body) if node.tag=='Scall'
            and node.args[1].tag=='Evar' and node.args[1].args[0].tag=='_osContStartReadData')

    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory()
        before=dict(kind='entry',name='osContStartReadData',id=1,pc=0x80322b30,
            poll=2651,timer=2650,area=1,sp=0x80338000,ra=0x80248b84,
            args=[0x80339c08,0,0,0],v0=999,
            regions=[dict(name='gControllerPads',address=0x80339c88,bytes='00'*24)])
        after=dict(before,kind='return',pc=before['ra'],v0=0,
            regions=[dict(name='gControllerPads',address=0x80339c88,bytes='01'+'00'*23)])
        self.log=FilePath(self.tmp.name)/'raw.log'
        self.log.write_text('\n'.join('R1_HANDOFF,'+json.dumps(row) for row in (before,after))+
            '\nR1_HANDOFF_RESULT,'+json.dumps(dict(failures=0,pending=0,returns=1))+'\n')
        self.oracle=EmulatorOracle(self.log)
        self.anchor=ReplayAnchor(self.oracle.digest,1)

    def tearDown(self):
        self.tmp.cleanup()

    def test_wrong_context_never_matches(self):
        for anchor in (None,ReplayAnchor('wrong',1),ReplayAnchor(self.oracle.digest,2),
                       ReplayAnchor(self.oracle.digest,1,'us')):
            with self.subTest(anchor=anchor),self.assertRaises(UnmatchedCall):
                self.oracle.answer('osContStartReadData',anchor)
        with self.assertRaises(UnmatchedCall):
            self.oracle.answer('osContGetReadData',self.anchor)

    def test_mapped_effect_rejects_wrong_result_without_framing_other_memory(self):
        after=z.Array('test.after',MEM.domain(),MEM.range())
        result=z.BitVec('test.result',32)
        entry,effect=self.oracle.facts(self.e,'osContStartReadData',self.anchor,MEM,after,result)
        s=z.Solver();s.add(entry,effect,result!=0)
        self.assertEqual(s.check(),z.unsat)
        s=z.Solver();s.add(entry,effect,read(MEM,word(0x12345))!=read(after,word(0x12345)))
        self.assertEqual(s.check(),z.sat)

    def test_actual_generated_call_resumes_backward(self):
        e=self.e;scope=Scope(e,self.fn)
        e.oracle=self.oracle;e.anchors={(self.fn.name,'test', 'osContStartReadData'):self.anchor}
        address=e.global_address('_gControllerPads')
        e.stop_post=z.BoolVal(False)
        for expected,status in ((1,z.sat),(2,z.unsat)):
            paths=e.external_call(self.call,[Path(read(MEM,word(address),1)==z.BitVecVal(expected,8))],scope,'test')
            s=z.Solver();s.add(e.remaining==30,paths[0].condition)
            self.assertEqual(s.check(),status)
        self.assertTrue(e.replies)

    def test_unanchored_complement_is_pending(self):
        e=self.e;scope=Scope(e,self.fn)
        e.oracle=self.oracle;e.anchors={};e.stop_post=z.BoolVal(False)
        address=e.global_address('_gControllerPads')
        paths=e.external_call(self.call,[Path(read(MEM,word(address),1)==z.BitVecVal(254,8))],scope,'unknown')
        s=z.Solver();s.add(paths[0].condition)
        self.assertEqual(s.check(),z.sat)
        self.assertFalse(e.deferred[-1]['matchedReplay'])

    def test_pending_call_cannot_invent_an_impossible_target(self):
        e=self.e;scope=Scope(e,self.fn)
        e.oracle=self.oracle;e.anchors={};e.stop_post=z.BoolVal(True);e.target=z.BoolVal(False)
        paths=e.external_call(self.call,[Path(z.BoolVal(False))],scope,'false-target')
        solver=z.Solver();solver.add(paths[0].condition)
        self.assertEqual(solver.check(),z.unsat)
        e.target=None

    def test_unpaired_return_is_rejected(self):
        # Directly corrupt the returned SP, without relying on serialization spacing.
        rows=self.log.read_text().splitlines()
        event=json.loads(rows[1].split(',',1)[1]);event['sp']+=4
        rows[1]='R1_HANDOFF,'+json.dumps(event)
        self.log.write_text('\n'.join(rows))
        with self.assertRaises(ValueError):EmulatorOracle(self.log)

    def test_path_sensitive_initialization_rejects_only_the_undefined_branch(self):
        e=HybridHorizonEngine('jp',updates=1,program_dispatch=False)
        original=e.function('debug','get_current_clock')
        # Deliberately synthetic interpreter regression, not a game program.
        body=parse('''(Ssequence
            (Sifthenelse (Etempvar _input tint)
              (Sset _answer (Econst_int (Int.repr 7) tint)) Sskip)
            (Sreturn (Some (Etempvar _answer tint))))''')
        fn=replace(original,name='test_defined_branch',body=body,returns=Term('tint'),
                   params={'_input':Term('tint')},temps={'_answer':Term('tint')},locals={})
        scope=Scope(e,fn)
        pre=e.close_scope(e.wp(body,[Path(scope.result==word(7))],scope),scope)[0].condition
        for value,expected in ((0,z.unsat),(1,z.sat)):
            solver=z.Solver();solver.add(pre,scope.temps['_input']==word(value))
            self.assertEqual(solver.check(),expected)

    def test_aggregate_copy_preserves_bytes_and_rejects_partial_overlap(self):
        e=HybridHorizonEngine('jp',updates=1,program_dispatch=False)
        original=e.function('rendering_graph_node','geo_process_root')
        actual=next(n for _,n in walk(original.body) if n.tag=='Sassign'
                    and e.typeof(n.args[0]).tag=='Tunion')
        ty=e.typeof(actual.args[0]);size,_=original.unit.size(ty)
        self.assertGreater(size,4)
        body=Term('Sassign',(Term('Evar',(Term('_testDest'),ty)),Term('Evar',(Term('_testSource'),ty))))
        fn=replace(original,name='test_copy',body=body,params={},temps={},locals={})
        source=e.global_address('_testSource');target=e.global_address('_testDest')
        for address,expected in ((target,z.unsat),(source,z.unsat),(source+4,z.sat)):
            e.globals['_testDest']=address
            scope=Scope(e,fn)
            goal=z.And(*[read(MEM,word(address+i),1)==read(MEM,word(source+i),1) for i in range(size)])
            pre=e.wp(body,[Path(goal)],scope)[0].condition
            solver=z.Solver();solver.add(z.Not(pre))
            self.assertEqual(solver.check(),expected)
        e.globals['_testDest']=2**32-size
        e.globals['_testSource']=2**32-size-4
        scope=Scope(e,fn)
        pre=e.wp(body,[Path(z.BoolVal(True))],scope)[0].condition
        solver=z.Solver();solver.add(pre)
        self.assertEqual(solver.check(),z.unsat)

    def test_initialized_flag_is_carried_through_a_loop(self):
        e=HybridHorizonEngine('jp',updates=1,program_dispatch=False,loop_fuel=2)
        original=e.function('debug','get_current_clock')
        body=parse('''(Ssequence
            (Swhile (Etempvar _input tint)
              (Ssequence (Sset _answer (Econst_int (Int.repr 7) tint))
                         (Sset _input (Econst_int (Int.repr 0) tint))))
            (Sreturn (Some (Etempvar _answer tint))))''')
        fn=replace(original,name='test_loop_defined',body=body,returns=Term('tint'),
                   params={'_input':Term('tint')},temps={'_answer':Term('tint')},locals={})
        scope=Scope(e,fn)
        pre=e.close_scope(e.wp(body,[Path(scope.result==word(7))],scope),scope)[0].condition
        for value,expected in ((0,z.unsat),(1,z.sat)):
            solver=z.Solver();solver.set(timeout=3000)
            solver.add(pre,scope.temps['_input']==word(value))
            self.assertEqual(solver.check(),expected)


if __name__=='__main__':unittest.main()
