"""Actual US/JP callback loads plus deliberately synthetic engine controls."""
from dataclasses import replace
import re
import unittest
from clight import ROOT, Term, items, parse, seq, walk
from engine import MEM, TOP, Scope, read, word, z
from search import bits
from relational_engine import RelationalEngine
from live_dispatch import resolve_live_call
from horizon_engine import HorizonEngine
from benchmark_updates import CoverageBlock


def engine(version, horizon=None):
    options = dict(runtime_audio=True,program_dispatch=True,live_dispatch=True,
                   supplemental=ROOT/'build/rank1-backward-search/supplemental-generated')
    if horizon is None:
        return RelationalEngine(version,**options)
    return HorizonEngine(version,updates=horizon,
                         checkpoint=('test_loop','bhv_pyramid_elevator_loop'),**options)


def native_entry(e):
    unit = e.unit('behavior_data')
    match = re.search(r'Definition v_bhvPyramidElevator := \{\|(.*?)\|\}\.',unit.text,re.S)
    init = items(parse(re.search(r'gvar_init :=\s*(.*?);',match[1],re.S)[1]))
    indices = [i for i,n in enumerate(init) if n.tag == 'Init_addrof'
               and n.args[0].tag == '_bhv_pyramid_elevator_loop']
    assert len(indices) == 1
    i = indices[0]
    assert init[i-1] == parse('(Init_int32 (Int.repr 201326592))')
    assert all(n.tag in ('Init_int32','Init_addrof') for n in init[:i+1])
    pc = e.global_address('_bhvPyramidElevator')+4*(i-1)
    cur = e.global_address('_gCurBhvCommand')
    target = e.function_address('bhv_pyramid_elevator_loop')
    return pc,cur,z.And(read(MEM,word(cur)) == word(pc),
                        read(MEM,word(pc+4)) == word(target))


def elevator_entry(e, y=4500):
    # Test boundary only. It supplies no gameplay reachability or Ink gap.
    unit = e.unit('object_list_processor')
    raw = unit.layout('_Object')[2]['_rawData']
    # Macros resolve these offsets in the generated source. The expression
    # checks below use the same actual callback, not a substitute dynamics model.
    return z.And(read(MEM,word(e.global_address('_gCurrentObject'))) == word(TOP),
                 read(MEM,word(TOP+raw+4*0x31)) == word(2),
                 read(MEM,word(TOP+164)) == word(bits(y)))


class LiveDispatchTests(unittest.TestCase):
    def test_us_jp_live_source_operand_excludes_unrelated_missing_bodies(self):
        for version in ('us','jp'):
            e = engine(version)
            fn = e.function('behavior_script','bhv_cmd_call_native')
            pc,cur,entry = native_entry(e)
            goal = z.And(read(MEM,word(cur)) == word(pc+8),
                         read(MEM,word(TOP+164)) == word(bits(4490)))
            _,paths = e.start(fn,goal,entry_condition=z.And(entry,elevator_entry(e)))
            receipt = e.dispatch_receipts[0]
            self.assertEqual(receipt['selected'],['bhv_pyramid_elevator_loop'])
            self.assertEqual(receipt['missingBodyFamily'],'unsat')
            self.assertIn('audio_init',receipt['excluded'])
            self.assertFalse(e.indirect_domains)
            self.assertIn('bhv_pyramid_elevator_loop',e.finished_functions)
            # Body inclusion is checked here; the older concrete path engine
            # separately validates callback effects. Do not call an unrestricted
            # recursive SMT timeout a failed or successful callback execution.
            # The entry condition is part of the returned predecessor, not an
            # ambient assumption dropped after narrowing the dispatch.
            self.assertEqual(e.solve(z.And(paths[0].condition,z.Not(entry)))[0],'unsat')

    def test_actual_load_keeps_unknown_script_words_open(self):
        e = engine('jp')
        fn = e.function('behavior_script','bhv_cmd_call_native')
        with self.assertRaises(CoverageBlock) as caught:
            e.start(fn,z.BoolVal(True))
        self.assertEqual(caught.exception.detail['reason'],'live-indirect-targets-unresolved')
        receipt = e.dispatch_receipts[0]
        self.assertEqual(receipt['missingBodyFamily'],'sat')
        self.assertFalse(receipt['initializersAssumed'])
        self.assertIn('audio_init',receipt['selected'])
        self.assertIn('memory_at_cut',receipt['pointerLoad'])

    def test_reached_external_is_still_a_blocker(self):
        e = engine('jp')
        fn = e.function('behavior_script','bhv_cmd_call_native')
        cur = e.global_address('_gCurBhvCommand')
        pc = e.global_address('_bhvPyramidElevator')
        entry = z.And(read(MEM,word(cur)) == word(pc),
                      read(MEM,word(pc+4)) == word(e.function_address('audio_init')))
        with self.assertRaises(CoverageBlock) as caught:
            e.start(fn,z.BoolVal(True),entry_condition=entry)
        self.assertEqual(caught.exception.detail['missing'],['audio_init'])

    def test_earlier_store_overrides_the_initial_operand(self):
        e = engine('jp')
        fn = e.function('behavior_script','bhv_cmd_call_native')
        pc,cur,entry = native_entry(e)
        address = e.function_address('audio_init')
        # Deliberately synthetic test instruction, never claimed as stock code
        # or executed against a game. The resolver must read the live word.
        store = parse(f"(Sassign (Ederef (Ecast (Econst_int (Int.repr {pc+4}) tint) (tptr tuint)) tuint) (Econst_int (Int.repr {address}) tuint))")
        body = seq([store,fn.body])
        with self.assertRaises(CoverageBlock) as caught:
            e.start(fn,z.BoolVal(True),body,entry_condition=entry)
        self.assertEqual(caught.exception.detail['missing'],['audio_init'])

    def test_unknown_solver_answer_never_prunes_a_target(self):
        from unittest.mock import patch
        e = engine('jp')
        fn = e.function('behavior_script','bhv_cmd_call_native')
        scope = Scope(e,fn)
        call = next(n for _,n in walk(fn.body) if n.tag == 'Scall')
        with patch.object(z.Solver,'check',return_value=z.unknown):
            targets,receipt = resolve_live_call(e,scope,call,context=z.BoolVal(True),body=fn.body)
        all_targets = e.image.compatible(e.typeof(call.args[1]),fn.unit)
        self.assertEqual({t.name for t in targets},{t.name for t in all_targets})
        self.assertEqual(len(receipt['excluded']),0)

    def test_horizon_counts_calls_and_keeps_previous_iteration_effects(self):
        # Synthetic scheduler ONLY for interpreter regression, using a real
        # generated no-side-effect clock helper. A counter advances by 1 before
        # the observed call and 10 afterwards. The last +10 must NOT execute.
        for count in (1,2,3,30):
            e = HorizonEngine('jp',updates=count,program_dispatch=False,live_dispatch=False,
                checkpoint=('test_loop','get_current_clock'),loop_fuel=count,call_fuel=0)
            fn = e.function('debug','get_current_clock')
            call = parse('(Scall None (Evar _get_current_clock (Tfunction nil tulong cc_default)) nil)')
            def add(n):
                return parse(f'(Sassign (Evar _test_counter tint) (Ebinop Oadd (Evar _test_counter tint) (Econst_int (Int.repr {n}) tint) tint))')
            loop = Term('Swhile',(parse('(Econst_int (Int.repr 1) tint)'),seq([add(1),call,add(10)])))
            harness = replace(fn,name='test_loop',body=loop,temps={},params={},locals={})
            address = e.global_address('_test_counter')
            target = read(MEM,word(address)) == word(11*(count-1)+1)
            entry = read(MEM,word(address)) == word(0)
            _,paths = e.start_horizon(harness,target,loop,entry_condition=entry)
            self.assertEqual(e.solve(paths[0].condition)[0],'sat')
            wrong = HorizonEngine('jp',updates=count,program_dispatch=False,live_dispatch=False,
                checkpoint=('test_loop','get_current_clock'),loop_fuel=count,call_fuel=0)
            _,bad = wrong.start_horizon(harness,read(MEM,word(wrong.global_address('_test_counter'))) == word(11*count),
                                       loop,entry_condition=entry)
            self.assertEqual(wrong.solve(bad[0].condition)[0],'unsat')


if __name__ == '__main__':
    unittest.main()
