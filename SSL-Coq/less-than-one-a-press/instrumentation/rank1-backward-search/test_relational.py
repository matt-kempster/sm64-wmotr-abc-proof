"""Source-sharing and explicit-runtime regression tests, not gameplay evidence."""
from dataclasses import replace
import unittest

from clight import Term, parse, walk
from engine import MEM, Scope, Path, word, read, z
from loop_engine import LoopEngine
from relational_engine import RelationalEngine
from benchmark_updates import CoverageBlock, inventory


class RelationalTests(unittest.TestCase):
    def test_shared_clock_helper_defines_actual_64_bit_return_and_memory(self):
        for version in ('us','jp'):
            e=RelationalEngine(version)
            fn=e.function('debug','get_current_clock')
            r=e.reference(fn); e.compile_pending()
            after=z.Array('clock_after_'+version,MEM.domain(),MEM.range())
            value=z.BitVec('clock_result_'+version,64)
            defined=z.Bool('clock_defined_'+version)
            relation=r['relation'](z.IntVal(0),MEM,after,value,defined)
            status,_,reason=e.solve(z.And(relation,z.Or(after!=MEM,value!=z.BitVecVal(0,64),z.Not(defined))))
            self.assertEqual(status,'unsat',reason)
            self.assertEqual(e.solve(relation)[0],'sat')

    def test_shared_absf_matches_original_ieee_result(self):
        for version in ('us','jp'):
            e=RelationalEngine(version)
            fn=e.function('object_helpers','absf'); r=e.reference(fn); e.compile_pending()
            x=z.FP('abs_argument_'+version,z.Float32())
            y=z.FP('abs_result_'+version,z.Float32())
            after=z.Array('abs_after_'+version,MEM.domain(),MEM.range())
            defined=z.Bool('abs_defined_'+version)
            rel=r['relation'](z.IntVal(0),MEM,x,after,y,defined)
            expected=z.If(z.fpLT(x,z.FPVal(0,z.Float32())),z.fpNeg(x),x)
            bad=z.Or(after!=MEM,z.Not(defined),z.fpToIEEEBV(y)!=z.fpToIEEEBV(expected))
            self.assertEqual(e.solve(z.And(rel,z.Not(z.fpIsNaN(x)),bad))[0],'unsat')

    def test_undefined_fallthrough_is_not_an_invented_zero_return(self):
        e=RelationalEngine('jp')
        fn=e.function('debug','get_current_clock')
        # Test-only variant. Never written to generated/ or called stock code.
        variant=replace(fn,name='test_no_return',body=Term('Sskip'),digest='test-no-return')
        r=e.reference(variant); e.compile_pending()
        args=[z.IntVal(0),MEM,MEM,z.BitVecVal(0,64)]
        self.assertEqual(e.solve(r['relation'](*args,z.BoolVal(True)))[0],'unsat')
        self.assertEqual(e.solve(r['relation'](*args,z.BoolVal(False)))[0],'sat')

    def test_real_source_dispatch_table_remains_a_live_domain_obligation(self):
        e=RelationalEngine('jp'); fn=e.function('behavior_script','cur_obj_update'); s=Scope(e,fn)
        node=next(n for _,n in walk(fn.body) if n.tag=='Scall' and n.args[1].tag=='Etempvar')
        names=e.source_table_targets(s,node.args[1])
        self.assertEqual(len(names),56)
        self.assertEqual(names[12],'bhv_cmd_call_native')
        paths=e.wp(node,[Path(z.BoolVal(True))],s)
        self.assertEqual(len(paths),1)
        self.assertEqual(len(e.indirect_domains),1)
        self.assertEqual(len(e.pending),56)
        self.assertFalse(e.calls)

    def test_sqrt_binding_domain_is_explicit_and_rejects_subnormals(self):
        from search import bits
        e=RelationalEngine('jp',sqrtf_binding=True)
        fn=e.function('object_helpers','dist_between_objects'); s=Scope(e,fn)
        call=next(n for _,n in walk(fn.body) if n.tag=='Scall' and n.args[1].tag=='Evar' and n.args[1].args[0].tag=='_sqrtf')
        original=call.args[2].args[0]
        for raw,supported in [(bits(0),True),(bits(-0.0),True),(bits(4),True),(1,False),(bits(-1),False),(0x7f800000,False),(0x7fc00000,False)]:
            expr=Term('Econst_single',(Term('Float32.of_bits',(Term('Int.repr',(Term(str(raw)),)),)),Term('tfloat')))
            variant=Term('Scall',(call.args[0],call.args[1],Term('cons',(expr,Term('nil')))))
            pred=e.wp(variant,[Path(z.BoolVal(True))],s)[0].condition
            self.assertEqual(e.solve(pred)[0],'sat' if supported else 'unsat')
        self.assertEqual(len(e.library_domains),7)

    def test_packed_fields_layout_and_reads_match_n64_source_profile(self):
        for version in ('us','jp'):
            e=LoopEngine(version,runtime_audio=True)
            fn=e.function('runtime/audio_external','begin_background_music_fade'); s=Scope(e,fn)
            expr=next(n for _,n in walk(fn.body) if n.tag=='Efield' and n.args[1].tag=='_enabled')
            e.conversion_guards.append([])
            value=e.eval(expr,s)
            e.conversion_guards.pop()
            from engine import write
            address=e.global_address('_gSequencePlayers')
            for byte,want in ((0,0),(0x80,1),(0x7f,0),(0xff,1)):
                memory=write(MEM,word(address),word(byte),1)
                result=z.simplify(z.substitute(value,(MEM,memory)))
                self.assertEqual(result.as_long(),want)
            self.assertEqual(fn.unit.layout('_SequencePlayer')[2]['_seqVariation'],1)

    def test_inventory_counts_the_original_while_loop(self):
        e=LoopEngine('jp'); fn=e.function('surface_collision','find_floor_from_list')
        self.assertEqual(inventory(fn,fn.body)['loops'],1)

    def test_recursive_local_region_reuse_is_rejected(self):
        e=RelationalEngine('jp')
        fn=e.function('surface_collision','find_floor')
        record=e.reference(fn)
        key=(str(fn.unit.path),fn.name)
        self.assertTrue(fn.locals)
        # Test-only call-graph mutation, not a claim that stock find_floor is
        # recursive. A finite call-depth bound must not mask frame aliasing.
        e.call_edges[key]={key}
        with self.assertRaises(CoverageBlock) as caught:
            e.check_local_reentrancy()
        self.assertEqual(caught.exception.detail['reason'],'recursive-local-storage-not-modelled')


if __name__=='__main__': unittest.main()
