"""Controller-domain and held-edge regressions; fake backend is bookkeeping only."""
import itertools
import unittest
from collections import Counter
from controller_inputs import A_BUTTON, InputSpace, button_masks, encoded_sticks
from search import CONTROLS, Input, Move, Saved, accepted_target, previous_moves, replay, target_install_moves
from test_search import ScriptedBackend


class InputTests(unittest.TestCase):
    def test_every_encoded_pair_and_bz_combination_is_generated_once(self):
        per_button = {b: set() for b in (0, 0x4000, 0x2000, 0x6000)}
        counts = Counter()
        for c in InputSpace('encoded'):
            per_button[c.buttons].add((c.x, c.y))
            counts[c.buttons] += 1
        expected = {(x, y) for x in range(-128, 128) for y in range(-128, 128)}
        self.assertEqual(len(expected), 65536)
        self.assertEqual(counts, Counter({b:65536 for b in per_button}))
        for pairs in per_button.values():
            self.assertEqual(pairs, expected)

    def test_all_thirteen_declared_non_a_bits_without_reserved_bits(self):
        masks = list(button_masks('all-non-a'))
        self.assertEqual(len(masks), 8192)
        self.assertEqual(len(set(masks)), 8192)
        self.assertEqual(max(masks), 0x7f3f)
        self.assertTrue(all(not b & 0x80c0 for b in masks))
        counts = Counter(c.buttons for c in InputSpace('sampled', 'all-non-a'))
        self.assertEqual(set(counts), set(masks))
        self.assertTrue(all(n == 9 for n in counts.values()))

    def test_large_domain_is_lazy_and_retains_legacy_representatives(self):
        space = InputSpace('encoded', 'all-non-a')
        self.assertEqual(space.count, 536870912)
        first = list(itertools.islice(space, 40))
        self.assertEqual(first[:36], list(CONTROLS))
        self.assertEqual(first[36], Input(0, -128, -128))

    def test_wide_mode_reaches_every_installation_pose_before_next_input(self):
        space = InputSpace('encoded')
        moves = list(itertools.islice(target_install_moves(accepted_target('low-display'),
                                                           'low-display', space), 12))
        self.assertEqual({m.patch['movement'][1] for m in moves[:6]},
                         {m.patch['movement'][1] for m in moves[6:]})
        self.assertTrue(all(m.control == Input() for m in moves[:6]))
        self.assertTrue(all(m.control == Input(0,-127,0) for m in moves[6:]))
        custom = Input(0,13,-27)
        self.assertEqual(len(list(previous_moves(accepted_target('low-display'), (custom,)))),35)
        self.assertTrue(all(m.control == custom for m in previous_moves(accepted_target('low-display'),(custom,))))

    def test_held_mode_keeps_a_down_in_every_generated_control(self):
        held = list(InputSpace(a_mode='held'))
        self.assertEqual(len(held),36)
        self.assertEqual([Input(c.buttons & ~A_BUTTON,c.x,c.y) for c in held],list(CONTROLS))

    def held_backend(self, pressed=False, earlier_down=True):
        b = ScriptedBackend()
        b.state.update(buttonDown=A_BUTTON if earlier_down else 0, buttonPressed=0)
        for step in b.steps:
            step.update(buttonDown=A_BUTTON,buttonPressed=A_BUTTON if pressed else 0)
        return b

    def validate_held(self, backend):
        context = backend.capture()
        control = Input(A_BUTTON)
        return replay(backend,context,Move('held-test',{},control,'test-only'),
                      [Saved(1,backend.steps[0],None),Saved(2,backend.steps[1],None)],
                      [control,control],held_a=True)

    def test_held_validation_accepts_continuous_hold_and_rejects_new_edge(self):
        good,_ = self.validate_held(self.held_backend())
        self.assertEqual(good['status'],'accepted-projection')
        bad,_ = self.validate_held(self.held_backend(pressed=True))
        self.assertEqual(bad['status'],'rejected-a-history')
        self.assertIn('newly pressed',bad['reason'])

    def test_held_validation_rejects_unexplained_initial_a_down(self):
        result,_ = self.validate_held(self.held_backend(earlier_down=False))
        self.assertEqual(result['status'],'rejected-a-history')
        self.assertEqual(result['reason'],'A was not already down')


if __name__ == '__main__':
    unittest.main()
