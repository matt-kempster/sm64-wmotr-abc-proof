"""Coverage-gate tests; boundary cases are not gameplay witnesses."""
import unittest

from clight import Term, parse, outer_items, walk
from engine import MEM, STATE, OBJECT, word, read, z
from search import HEIGHT, bits
from benchmark_updates import StrictEngine, CoverageBlock, retention_prefix


class UpdateBenchmarkTests(unittest.TestCase):
    def test_real_copy_still_completes_without_open_calls(self):
        for version in ('us','jp'):
            engine = StrictEngine(version)
            fn = engine.function('object_list_processor','copy_mario_state_to_object')
            scope, paths = engine.start(fn, read(MEM,word(OBJECT+164))==word(HEIGHT))
            pred = z.Or(*[p.condition for p in paths])
            self.assertEqual(engine.solve(z.Xor(pred,read(MEM,word(STATE+64))==word(HEIGHT)),engine.entry(scope))[0],'unsat')
            self.assertFalse(engine.calls)

    def test_no_opaque_call_can_count_as_completion(self):
        engine=StrictEngine('jp')
        fn=engine.function('platform_displacement','update_mario_platform')
        engine.INLINE={}  # Test-only negative control, not a gameplay variant.
        with self.assertRaises(CoverageBlock) as caught:
            engine.start(fn,z.BoolVal(True))
        self.assertEqual(caught.exception.detail['reason'],'unexpanded-call')

    def test_real_retention_call_is_last_in_cut(self):
        for version in ('us','jp'):
            engine=StrictEngine(version)
            fn=engine.function('object_list_processor','update_objects')
            body, cut=retention_prefix(fn)
            original=outer_items(fn.body)
            self.assertEqual(outer_items(body),original[:cut['included']])
            self.assertEqual(outer_items(body)[-1].args[1].args[0].tag,'_update_mario_platform')
            self.assertGreater(cut['excludedAfterTarget'],0)

    def test_real_floor_loop_is_a_blocker_not_zero_iterations(self):
        engine=StrictEngine('jp')
        fn=engine.function('surface_collision','find_floor_from_list')
        with self.assertRaises(CoverageBlock) as caught:
            engine.start(fn,z.BoolVal(True))
        self.assertEqual(caught.exception.detail['reason'],'unimplemented-live-loop')
        self.assertEqual(caught.exception.detail['function'],'find_floor_from_list')

    def test_generated_single_to_short_cast_boundaries(self):
        # Use the actual first X cast, varying its argument. Compare constant
        # results to independent Python truncation/narrowing at the boundaries.
        cases=[(0,True),(-0.75,True),(1938.8648681640625,True),(-2200.9,True),
               (32768,True),(65536,True),(-2147483648,True),(2147483520,True),
               (2147483648,False),(-2147483904,False),
               (float('inf'),False),(-float('inf'),False),(float('nan'),False)]
        import struct, math
        for version in ('us','jp'):
            for value,valid in cases:
                engine=StrictEngine(version)
                fn=engine.function('surface_collision','find_floor')
                statement=next(n for _,n in walk(fn.body) if n.tag=='Sset' and n.args[0].tag=='_x')
                scope, paths=engine.start(fn,z.BoolVal(True),statement)
                fp=z.fpBVToFP(word(bits(value)),z.Float32())
                pred=z.substitute(z.Or(*[p.condition for p in paths]),(scope.temps['_xPos'],fp))
                self.assertEqual(engine.solve(pred)[0],'sat' if valid else 'unsat',(version,value))
                if valid:
                    single=struct.unpack('>f',struct.pack('>f',value))[0]
                    expected=((math.trunc(single)+32768)%65536)-32768
                    # Backward-substitute a specific output condition through
                    # the same real cast, using its actual scope's temporary.
                    from engine import Path as Branch
                    alternatives=engine.wp(statement,[Branch(scope.temps['_x']!=word(expected))],scope)
                    wrong=z.substitute(z.Or(*[p.condition for p in alternatives]),(scope.temps['_xPos'],fp))
                    self.assertEqual(engine.solve(wrong)[0],'unsat',(version,value,expected))

    def test_invalid_conversion_in_call_argument_is_not_allowed(self):
        # Exercise guard placement at Scall, the first failing benchmark site.
        engine=StrictEngine('jp')
        fn=engine.function('mario_step','stop_and_set_height_to_floor')
        call=parse('(Scall None (Evar _vec3s_set (Tfunction ((tptr tshort) :: tshort :: tshort :: tshort :: nil) tvoid cc_default)) ((Ecast (Econst_int (Int.repr 0) tint) (tptr tshort)) :: (Ecast (Econst_single (Float32.of_bits (Int.repr 2139095040))) tshort) :: (Econst_int (Int.repr 0) tint) :: (Econst_int (Int.repr 0) tint) :: nil))')
        # Econst_single includes its explicit generated type argument.
        def typed(node):
            if node.tag=='Econst_single': return Term(node.tag,node.args+(Term('tfloat'),))
            return Term(node.tag,tuple(typed(a) for a in node.args))
        _,paths=engine.start(fn,z.BoolVal(True),typed(call))
        self.assertEqual(engine.solve(z.Or(*[p.condition for p in paths]))[0],'unsat')

    def test_unreached_invalid_conversion_does_not_restrict_other_branch(self):
        engine=StrictEngine('jp')
        fn=engine.function('surface_collision','find_floor')
        branch=parse('(Sifthenelse (Econst_int (Int.repr 0) tint) (Sset _x (Ecast (Econst_single (Float32.of_bits (Int.repr 2139095040)) tfloat) tshort)) Sskip)')
        _,paths=engine.start(fn,z.BoolVal(True),branch)
        self.assertEqual(engine.solve(z.Or(*[p.condition for p in paths]))[0],'sat')


if __name__=='__main__': unittest.main()
