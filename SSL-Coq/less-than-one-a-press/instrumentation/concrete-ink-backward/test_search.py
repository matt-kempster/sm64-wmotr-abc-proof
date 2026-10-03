import copy
import unittest
from check_receipt import check, word
from search import CONTROLS, DIALOG, DISAPPEARED, END_FIELDS, Input, Move, Saved, install_moves, previous_moves, replay


def target():
    return dict(movement=[word(-2200), word(768), word(-1024)],
                collision=[word(-2200), word(768), word(-1024)],
                display=[word(-2200), 1156733869, word(-1024)], action=0x0C400201, depth=0)


def receipt(y, display_y=1938.8648681640625):
    high = [word(-2200), 1156733869, word(-1024)]
    low = [word(-2200), word(768), word(-1024)]
    movement = high if y == 768 else [word(-2200), word(1861), word(-1024)]
    display = [word(-2200), word(display_y), word(-1024)]
    def record(stage):
        return ('BACKWARD_INK,stage=%s,timer=492,area=1,action=00001300,arg=00040002,'
                'used=80345880,upper=80345880,top=803451f8,floor=8019ba80,owner=803451f8,'
                'platform=00000000,positions=%s' %
                (stage, ':'.join('%08x' % n for n in movement + low + display)))
    return '\n'.join([record('setup'), record('accepted-return'), record('disappeared-entry'),
                       'FIRST_APPLY_ENTRY,area=2,platform=803451f8,marioBits=(00000000,45abe000,43800000)',
                       'FIRST_APPLY_RETURN,area=2,platform=803451f8,marioBits=(43b6cbe0,45abe000,c48919af)'])


class Tests(unittest.TestCase):
    def test_target_derived_first_move(self):
        a = target(); b = copy.deepcopy(a); b['collision'][1] = word(780)
        self.assertEqual(next(install_moves(a)).patch['movement'][1], word(768))
        self.assertEqual(next(install_moves(b)).patch['movement'][1], word(780))
    def test_inverse_menu_has_no_a(self):
        self.assertEqual(len(CONTROLS), 36)
        self.assertTrue(all(not c.buttons & 0x8000 for c in CONTROLS))
    def test_final_dialog_sink_is_target_derived(self):
        moves = [m for m in previous_moves(target()) if m.patch['action'] == DIALOG]
        self.assertEqual(len(moves), 108)
        self.assertEqual(moves[-1].patch['display'][1], word(768))
    def test_exact_return_and_alternate_return(self):
        for y in (768, 1861):
            self.assertEqual(check(receipt(y), y)['status'], 'checked-conditional-installation')
    def test_low_display_is_kept_for_successful_first_lookup(self):
        moves = [m for m in install_moves(target()) if m.name=='successful-query-state-only-y-1861']
        self.assertEqual(len(moves), 36)
        self.assertEqual(moves[0].patch['display'], moves[0].patch['collision'])
        self.assertEqual(moves[0].patch['movement'][1], word(1861))
    def test_low_display_exact_receipt(self):
        result = check(receipt(1861,768),1861,768)
        self.assertEqual(result['displayWords'], result['collisionWords'])
    def test_wrong_return_position_rejected(self):
        with self.assertRaises(ValueError):
            check(receipt(768).replace('44f25bad', '44f25bae'), 768)
    def test_action_already_executed_rejected(self):
        with self.assertRaises(ValueError):
            check(receipt(768).replace('arg=00040002', 'arg=00040001'), 768)
    def test_missing_retained_apply_rejected(self):
        with self.assertRaises(ValueError):
            check(receipt(768).replace('platform=803451f8', 'platform=00000000'), 768)
    def test_shifted_checkpoint_rejected(self):
        text = receipt(768).replace('stage=disappeared-entry,timer=492',
                                   'stage=disappeared-entry,timer=493')
        with self.assertRaises(ValueError):
            check(text, 768)

    def test_continuous_validator_patches_only_once(self):
        backend = ScriptedBackend()
        context = backend.capture()
        middle = Saved(1, backend.steps[0], None)
        end = Saved(2, backend.steps[1], None)
        control = Input()
        result, earlier = replay(backend, context, Move('test-only', {}, control, 'fixture'),
                                 [middle, end], [control, control], end.observation['movement'])
        self.assertEqual(result['status'], 'accepted-projection')
        self.assertEqual([r['op'] for r in result['ledger']],
                         ['restore-context', 'patch', 'advance', 'advance'])
        self.assertEqual(backend.operations, ['restore', 'patch', 'advance', 'advance', 'restore'])
        self.assertEqual(backend.frame(), 0)

    def test_invalid_intermediate_is_not_spliced(self):
        backend = ScriptedBackend(); context = backend.capture()
        wrong = copy.deepcopy(backend.steps[0]); wrong['movement'][1] ^= 1
        result, earlier = replay(backend, context, Move('test-only', {}, Input(), 'fixture'),
                                 [Saved(1, wrong, None), Saved(2, backend.steps[1], None)],
                                 [Input(), Input()])
        self.assertEqual(result['status'], 'rejected')
        self.assertIsNone(earlier)
        self.assertEqual(backend.operations, ['restore', 'patch', 'advance', 'restore'])


class ScriptedBackend:
    """Bookkeeping test fixture; contains no game simulation or game evidence."""
    def __init__(self):
        base = target()
        base.update(actionArg=0, usedSlot=64, floorHeight=1156733869, floorOwner=61,
                    platform=61, timer=100)
        self.state = base
        self.steps = [dict(copy.deepcopy(base), timer=101),
                      dict(copy.deepcopy(base), timer=102, action=DISAPPEARED)]
        self.index = 0; self.operations = []; self.game = self
    def frame(self):
        return self.index
    def observe(self):
        return copy.deepcopy(self.state)
    def capture(self):
        return Saved(self.index, self.observe(), (self.index, self.observe()))
    def restore(self, saved):
        self.operations.append('restore'); self.index, state = saved.state
        self.state = copy.deepcopy(state)
    def patch(self, patch):
        self.operations.append('patch'); self.state.update(patch)
    def advance(self, control):
        self.operations.append('advance'); self.state = copy.deepcopy(self.steps[self.index]); self.index += 1
    def frame_log(self):
        from search import number
        return [dict(type='FLT_EXECUTE_ACTION', action=DISAPPEARED,
                     pos=[number(w) for w in self.state['movement']])]


if __name__ == '__main__':
    unittest.main()
