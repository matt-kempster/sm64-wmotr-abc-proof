"""Full source-interval fixtures and failure controls; no reachability claim."""
import unittest
from clight import ROOT
from trace_engine import TraceEngine,Unsupported,word,z
from trace_update import fixture,enable_mario,execute
from search import HEIGHT,bits
from engine import OBJECT


class TraceUpdateTests(unittest.TestCase):
    def engine(self,version):
        return TraceEngine(version,supplemental=ROOT/'build/rank1-backward-search/supplemental-generated')

    def test_us_jp_complete_active_mario_interval_and_backward_group(self):
        for version in ('us','jp'):
            e=self.engine(version);scene=fixture(e);enable_mario(e,scene)
            goal,cut=execute(e,scene)
            self.assertTrue(z.is_true(e.concrete(goal)))
            pred=e.predecessor(goal)
            self.assertTrue(z.is_true(e.initial_instance(pred)))
            calls={c['function'] for c in e.call_trace}
            self.assertTrue({'read_controller_inputs','level_script_execute','level_cmd_call_loop',
                'lvl_init_or_update','play_mode_normal','area_update_objects','update_objects',
                'cur_obj_update','bhv_cmd_call_native','bhv_mario_update','execute_mario_action',
                'update_mario_geometry_inputs','act_disappeared','find_floor_from_list',
                'update_mario_platform'}<=calls)
            self.assertEqual([f['heightBits'] for f in e.floor_calls],[bits(-11000),HEIGHT,HEIGHT])
            self.assertEqual([f['queryBits'][1] for f in e.floor_calls],[bits(768),HEIGHT,HEIGHT])
            self.assertEqual([f['floor'] for f in e.floor_calls],[0,scene['surface'],scene['surface']])
            self.assertTrue(any(c['callee']=='bhv_mario_update' for c in e.indirect_calls))
            axes=[scene['pads']+2,scene['pads']+3]
            grouped=e.initial_instance(pred,leave=axes)
            x,y=[z.SignExt(24,e.cells[n]) for n in axes]
            square=z.And(x>=word(-7),x<=word(7),y>=word(-7),y<=word(7))
            s=z.Solver();s.set(timeout=15000);s.add(z.Xor(grouped,square))
            self.assertEqual(s.check(),z.unsat)
            # With no raised display, this very same path cannot supply the
            # requested floor/owner result. This is not all-path exclusion.
            self.assertTrue(z.is_true(e.initial_instance(pred)))
            for i in range(4):e.initial_bytes[OBJECT+36+i]=(bits(768)>>(8*(3-i)))&255
            self.assertTrue(z.is_false(e.initial_instance(pred)))

    def test_invalid_live_callback_is_rejected_not_ignored(self):
        e=self.engine('jp');scene=fixture(e);enable_mario(e,scene)
        address=e.initialize_global('_BehaviorCmdTable')
        # Deliberately damaged TEST data, never a game memory edit or route.
        e.seed(address+12*4,0xdeadbeef)
        with self.assertRaisesRegex(Unsupported,'Invalid/mismatched live function pointer'):
            execute(e,scene)

    def test_reached_unimplemented_external_prevents_completion(self):
        e=self.engine('jp');scene=fixture(e);enable_mario(e,scene)
        animation=e.global_address('_gMarioAnimsBuf')
        offset=e.unit('mario').layout('_DmaHandlerList')[2]['_currentAddr']
        e.seed(animation+offset,0)
        with self.assertRaisesRegex(Unsupported,'Unimplemented executed call'):
            execute(e,scene)

    def test_uninitialized_and_freed_memory_is_rejected(self):
        e=self.engine('jp');address=0x20100000
        e.region(address,4,'test local')
        with self.assertRaisesRegex(Unsupported,'Uninitialized memory'):e.bytes_read(address,4)
        e.seed(address,0x12345678)
        self.assertEqual(e.number(e.bytes_read(address,4)),0x12345678)
        e.regions=[]
        with self.assertRaisesRegex(Unsupported,'Invalid byte address'):e.bytes_read(address,4)


if __name__=='__main__':unittest.main()
