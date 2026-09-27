"""Negative controls for predecessor computation; synthetic cases are not runs."""
from dataclasses import replace
import struct
import sys
import unittest
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from clight import Term, Unit, parse, walk
from engine import Engine, Scope, Path as Branch, MEM, STATE, OBJECT, read, word, z, Unsupported
from search import HEIGHT,LOWER,UPPER,number


class BackwardTests(unittest.TestCase):
    def test_generated_layouts_match_existing_proof_offsets(self):
        for version in ('us','jp'):
            unit=Unit(version,'platform_displacement')
            self.assertEqual(unit.layout('_Object')[0],608)
            self.assertEqual(unit.layout('_Object')[2]['_rawData'],136)
            self.assertEqual(unit.layout('_Object')[2]['_platform'],532)
            self.assertEqual(unit.layout('_MarioState')[2]['_pos'],60)
            self.assertEqual(unit.layout('_MarioState')[2]['_floorHeight'],112)
            self.assertEqual(unit.layout('_Surface')[2]['_object'],44)

    def test_strict_float32_band_edges_independently(self):
        def f32(x): return struct.unpack('>f',struct.pack('>f',x))[0]
        for bits,want in [(LOWER-1,False),(LOWER,True),(HEIGHT,True),(UPPER,True),(UPPER+1,False)]:
            self.assertEqual(abs(f32(number(bits)-number(HEIGHT)))<4,want)

    def test_generated_copy_mutation_changes_predecessor(self):
        e=Engine('jp');fn=e.function('object_list_processor','copy_mario_state_to_object')
        count=0
        def change(node):
            nonlocal count
            if node.tag=='Sassign' and '_asF32' in str(node.args[0]) and '(Int.repr 6)' in str(node.args[0]) and '(Int.repr 1)' in str(node.args[0]):
                count+=1
                def wrong_index(n):
                    if n==Term('Int.repr',(Term('1'),)): return Term('Int.repr',(Term('2'),))
                    return Term(n.tag,tuple(wrong_index(a) for a in n.args))
                return Term('Sassign',(wrong_index(node.args[0]),node.args[1]))
            return Term(node.tag,tuple(change(a) for a in node.args))
        changed=change(fn.body);self.assertEqual(count,1)
        goal=read(MEM,word(OBJECT+164))==word(HEIGHT)
        scope,paths=e.start(fn,goal,changed)
        old_claim=read(MEM,word(STATE+64))==word(HEIGHT)
        # A checker hardcoded to the documented copy fact would miss this.
        self.assertEqual(e.solve(z.Xor(z.Or(*[p.condition for p in paths]),old_claim),e.entry(scope))[0],'sat')

    def test_unknown_call_never_gets_identity_frame(self):
        e=Engine('jp');fn=e.function('mario_step','stop_and_set_height_to_floor')
        opaque=parse('(Scall None (Evar _unreviewed_callback (Tfunction nil tvoid cc_default)) nil)')
        scope,paths=e.start(fn,read(MEM,word(OBJECT+36))==word(HEIGHT),opaque)
        self.assertEqual(len(paths[0].calls),1)
        self.assertEqual(e.solve(paths[0].condition,[read(MEM,word(OBJECT+36))==word(0)])[0],'sat')
        self.assertIn('UNEXPANDED_unreviewed_callback',paths[0].condition.sexpr())

    def test_unsupported_loop_fails_instead_of_becoming_skip(self):
        e=Engine('jp');fn=e.function('mario_step','stop_and_set_height_to_floor')
        with self.assertRaises(Unsupported): e.start(fn,z.BoolVal(True),parse('(Sloop Sskip Sskip)'))

    def test_parser_rejects_unconsumed_syntax(self):
        with self.assertRaises(ValueError): parse('(Sskip) unsupported!')

    def test_guard_is_not_silently_dropped(self):
        e=Engine('jp');fn=e.function('object_list_processor','copy_mario_state_to_object')
        synthetic=parse('(Sifthenelse (Econst_int (Int.repr 0) tint) (Sassign (Evar _gMarioPlatform (tptr tvoid)) (Ecast (Econst_int (Int.repr 4) tint) (tptr tvoid))) (Sassign (Evar _gMarioPlatform (tptr tvoid)) (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))')
        goal=read(MEM,word(e.global_address('_gMarioPlatform')))==word(4)
        _,paths=e.start(fn,goal,synthetic)
        self.assertEqual(e.solve(z.Or(*[p.condition for p in paths]))[0],'unsat')


if __name__=='__main__': unittest.main()
