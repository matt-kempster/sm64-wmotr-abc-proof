"""Deterministic harness tests ONLY: these do not run SM64 or an emulator."""
from copy import deepcopy
import json
import unittest

from backward_validation import (FREEFALL, Candidate, Checkpoint, Input,
                                 RestoreFailure, Validator, bits, f32,
                                 freefall_predecessors, number, search_two_edges)
from backward_wafel import WafelBackend, invalid_height_control


class DeterministicBackend:
    """Independent tiny transition oracle, not an SM64 implementation."""
    def __init__(self):
        self.state = dict(frame=0, timer=100, y=512.0, vy=-12.0,
                          area=1, action=FREEFALL, hidden_kick=False, pad=[0, 0, 0])
        self.events = []
        self.fail_patch = self.fail_advance = self.fail_restore = False
        self.bad_tick = False

    def frame(self):
        return self.state['frame']

    def save_state(self):
        return deepcopy(self.state)

    def load_state(self, state):
        if self.fail_restore:
            raise RuntimeError('restore fault')
        self.state = deepcopy(state)
        self.events.append(('restore', self.frame()))

    def observe(self):
        return dict(y=bits(self.state['y']), vy=bits(self.state['vy']),
                    timer=self.state['timer'], area=self.state['area'],
                    action=self.state['action'], pad=list(self.state['pad']))

    def patch(self, patch):
        self.events.append(('patch', self.frame()))
        self.state['y'] = number(patch['y'])
        if self.fail_patch:
            raise RuntimeError('partial patch fault')
        self.state['vy'] = number(patch['vy'])

    def advance(self, control):
        self.events.append(('advance', self.frame()))
        self.state['pad'] = [control.buttons, control.x, control.y]
        for _ in range(4):
            self.state['y'] = f32(self.state['y'] + f32(self.state['vy'] / 4))
        if self.state['frame'] == 1 and self.state['hidden_kick']:
            self.state['y'] = f32(self.state['y'] + 1)
        self.state['vy'] = max(-75.0, f32(self.state['vy'] - 4))
        if self.fail_advance:
            raise RuntimeError('partial advance fault')
        self.state['frame'] += 1
        self.state['timer'] += 0 if self.bad_tick else 1


def trace():
    backend = DeterministicBackend()
    validator = Validator(backend)
    contexts = []
    for _ in range(2):
        contexts.append(validator.capture())
        backend.advance(Input())
    return backend, validator, contexts, validator.capture()


class ValidationTests(unittest.TestCase):
    def test_target_derived_inverse_accepts_one_edge(self):
        backend, validator, contexts, target = trace()
        caller = backend.save_state()
        proposal = freefall_predecessors(target.observation, radius=0)[0]
        self.assertEqual(proposal.patch, dict(y=bits(500.0), vy=bits(-16.0)))
        result = validator.replay(contexts[1], proposal, [target])
        self.assertEqual(result['status'], 'accepted-projection')
        self.assertEqual(backend.state, caller)

    def test_binary32_neighbor_recovers_noninteger_inverse(self):
        backend = DeterministicBackend()
        backend.state.update(y=-1372.1866455078125, vy=-63.566646575927734)
        validator = Validator(backend)
        context = validator.capture()
        backend.advance(Input())
        target = validator.capture()
        central = validator.replay(context, freefall_predecessors(target.observation, 0)[0], [target])
        self.assertEqual(central['status'], 'rejected')
        accepted = [candidate.name for candidate in freefall_predecessors(target.observation, 2)
                    if validator.replay(context, candidate, [target])['status'] == 'accepted-projection']
        self.assertIn('freefall-ulp-v-1-y+0', accepted)

    def test_wrong_one_bit_candidate_is_rejected_and_restored(self):
        backend, validator, contexts, target = trace()
        caller = backend.save_state()
        patch = dict(freefall_predecessors(target.observation, 0)[0].patch)
        patch['y'] += 1
        result = validator.replay(contexts[1], Candidate('deliberate-invalid', patch), [target])
        self.assertEqual(result['status'], 'rejected')
        self.assertIn('y', result['samples'][0]['differences'])
        self.assertEqual(backend.state, caller)

    def test_runtime_control_records_mismatch_and_restores_caller(self):
        backend, validator, contexts, target = trace()
        caller = backend.save_state()
        result = invalid_height_control(validator, contexts[1], target)
        self.assertEqual(result['status'], 'rejected')
        self.assertEqual(result['samples'][0]['differences']['y']['actual'], bits(548.0))
        self.assertEqual(backend.state, caller)
        json.dumps(result)

    def test_runtime_control_does_not_count_backend_fault_as_rejection(self):
        backend, validator, contexts, target = trace()
        caller = backend.save_state()
        backend.fail_advance = True
        with self.assertRaisesRegex(ValueError, 'did not produce a concrete rejection'):
            invalid_height_control(validator, contexts[1], target)
        self.assertEqual(backend.state, caller)

    def test_exact_projection_requires_same_keys_even_for_null_values(self):
        backend, validator, contexts, target = trace()
        target.observation['unavailable'] = None
        result = validator.replay(contexts[1], freefall_predecessors(target.observation, 0)[0], [target])
        self.assertEqual(result['status'], 'rejected')
        difference = result['samples'][0]['differences']['unavailable']
        self.assertTrue(difference['expectedPresent'])
        self.assertFalse(difference['actualPresent'])

    def test_two_edges_replay_continuously_with_one_patch(self):
        backend, validator, contexts, target = trace()
        caller = backend.save_state()
        report = search_two_edges(validator, contexts, target, radius=0)
        self.assertEqual(report['status'], 'two-edge-projection-chain')
        ledger = report['chain']['ledger']
        self.assertEqual([r['op'] for r in ledger],
                         ['restore-full-context', 'patch', 'input-and-advance', 'input-and-advance'])
        self.assertEqual([r['frame'] for r in ledger], [0, 0, 0, 1])
        self.assertEqual(backend.state, caller)
        json.dumps(report)  # No opaque state handles in the public evidence.

    def test_mapper_does_not_copy_trace_predecessor_fields(self):
        backend, validator, contexts, target = trace()
        # Deliberately WRONG old mapped fields. Complement is unchanged.
        for context in contexts:
            context.state.update(y=9000.0, vy=111.0)
            context.observation.update(y=bits(9000.0), vy=bits(111.0))
        report = search_two_edges(validator, contexts, target, radius=0)
        self.assertEqual(report['status'], 'two-edge-projection-chain')
        patch = report['chain']['ledger'][1]
        self.assertEqual(patch['before']['y'], bits(9000.0))
        self.assertEqual(patch['after']['y'], bits(512.0))
        self.assertEqual(patch['after']['vy'], bits(-12.0))

    def test_individually_valid_edges_do_not_silently_splice_hidden_context(self):
        backend, validator, contexts, target = trace()
        # A different hidden N-1 context has the SAME projection. It changes N.
        contexts[1].state['hidden_kick'] = True
        validator.restore(contexts[1])
        backend.advance(Input())
        kicked_target = validator.capture()
        at0 = Candidate('fixture-first', {k: contexts[0].observation[k] for k in ('y', 'vy')})
        at1 = Candidate('fixture-last', {k: contexts[1].observation[k] for k in ('y', 'vy')})
        self.assertEqual(validator.replay(contexts[0], at0, [contexts[1]])['status'], 'accepted-projection')
        self.assertEqual(validator.replay(contexts[1], at1, [kicked_target])['status'], 'accepted-projection')
        result = validator.replay(contexts[0], at0, [contexts[1], kicked_target], [Input(), Input()])
        self.assertEqual(result['status'], 'rejected')
        self.assertEqual(result['samples'][0]['differences'], {})
        self.assertIn('y', result['samples'][1]['differences'])
        self.assertEqual(sum(r['op'] == 'patch' for r in result['ledger']), 1)

    def test_partial_write_and_advance_exceptions_restore_full_caller(self):
        for fault in ('fail_patch', 'fail_advance'):
            with self.subTest(fault=fault):
                backend, validator, contexts, target = trace()
                backend.state['hidden_kick'] = True
                caller = backend.save_state()
                setattr(backend, fault, True)
                result = validator.replay(contexts[1], freefall_predecessors(target.observation, 0)[0], [target])
                self.assertEqual(result['status'], 'error')
                self.assertEqual(backend.state, caller)

    def test_restore_failure_poisoning_stops_reuse(self):
        backend, validator, contexts, target = trace()
        backend.fail_restore = True
        with self.assertRaises(RestoreFailure):
            validator.replay(contexts[1], freefall_predecessors(target.observation, 0)[0], [target])
        self.assertTrue(validator.poisoned)
        backend.fail_restore = False
        with self.assertRaises(RestoreFailure):
            validator.capture()

    def test_wrong_frame_or_timer_is_not_an_accepted_edge(self):
        backend, validator, contexts, target = trace()
        proposal = freefall_predecessors(target.observation, 0)[0]
        wrong = Checkpoint(target.frame+1, target.observation, target.state)
        with self.assertRaises(ValueError):
            validator.replay(contexts[1], proposal, [wrong])
        backend.bad_tick = True
        result = validator.replay(contexts[1], proposal, [target])
        self.assertEqual(result['status'], 'error')

    def test_mapping_scope_and_validation(self):
        _, _, _, target = trace()
        for change in (dict(action=0), dict(area=2), dict(vy=bits(-75)), dict(y=bits(float('inf')))):
            self.assertEqual(freefall_predecessors(dict(target.observation, **change)), [])
        with self.assertRaises(ValueError):
            Candidate('incomplete', dict(y=bits(5)))
        with self.assertRaises(ValueError):
            Input(x=128)
        with self.assertRaises(ValueError):
            freefall_predecessors(target.observation, 100)


class WafelAPIContractTests(unittest.TestCase):
    def test_observer_uses_explicit_supported_read_paths(self):
        reads = {'gCurrLevelNum': 8, 'gMarioState.vel[0]': 0.0,
                 'gMarioState.vel[1]': -12.0, 'gMarioState.vel[2]': 0.0,
                 'gMarioState.forwardVel': 0.0, 'gMarioState.flags': 0,
                 'gMarioState.actionArg': 0, 'gRandomSeed16': 123,
                 'gControllers[0].buttonDown': 0, 'gControllers[0].buttonPressed': 0,
                 'gControllerPads[0].button': 0, 'gControllerPads[0].stick_x': 0,
                 'gControllerPads[0].stick_y': 0}
        class GameStub:
            def read(self, path): return reads[path]  # Unknown data paths fail.
        class ObserverStub:
            def snapshot(self):
                return dict(positions=[bits(1.0), bits(512.0), bits(3.0)] * 3,
                            timer=100, area=1, action=FREEFALL)
        observation = WafelBackend(GameStub(), ObserverStub()).observe()
        self.assertEqual(observation['y'], bits(512.0))
        self.assertEqual(observation['vy'], bits(-12.0))
        self.assertEqual(observation['rng'], 123)
        self.assertNotIn('positions', observation)
        json.dumps(observation)

    def test_adapter_uses_verified_api_and_exact_input_patch_paths(self):
        # A call-recording stub tests wiring, not the actual Wafel runtime.
        class GameStub:
            def __init__(self): self.calls = []
            def frame(self): return 7
            def save_state(self): return 'opaque-handle'
            def load_state(self, state): self.calls.append(('load_state', state))
            def write(self, path, value): self.calls.append(('write', path, value))
            def advance(self): self.calls.append(('advance',))
        game = GameStub()
        backend = WafelBackend(game, None)
        self.assertEqual(backend.frame(), 7)
        backend.load_state(backend.save_state())
        backend.patch(dict(y=bits(512), vy=bits(-12)))
        backend.advance(Input(buttons=0, x=-127, y=42))
        self.assertEqual(game.calls, [('load_state', 'opaque-handle'),
            ('write', 'gMarioState.pos[1]', 512.0), ('write', 'gMarioState.vel[1]', -12.0),
            ('write', 'gControllerPads[0].button', 0), ('write', 'gControllerPads[0].stick_x', -127),
            ('write', 'gControllerPads[0].stick_y', 42), ('advance',)])


if __name__ == '__main__':
    unittest.main()
