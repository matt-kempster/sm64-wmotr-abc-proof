"""Synthetic reporting controls, not SM64 executions or new game results."""
import unittest
from engine import z
from candidate_policy import interpret_solver_result, conditional_exit_code


class CandidatePolicyTests(unittest.TestCase):
    def test_a_conditional_call_candidate_can_fail_its_real_effect_check(self):
        before, after = z.BitVecs('policy.before policy.after', 8)
        effect = z.Function('policy.unanswered', z.BitVecSort(8), z.BitVecSort(8), z.BoolSort())
        solver = z.Solver()
        solver.add(before == 0, after == 7, effect(before, after))
        candidate = interpret_solver_result(solver.check())
        self.assertTrue(candidate['candidateFound'])
        self.assertFalse(candidate['gameplayValidated'])
        self.assertFalse(candidate['replayReady'])
        # An observed/test-double call that preserves this byte refutes this
        # proposal. The earlier SAT answer never established real call effects.
        solver.add(after == before)
        checked = interpret_solver_result(solver.check())
        self.assertFalse(checked['candidateFound'])
        self.assertFalse(checked['gameplayExcluded'])
        self.assertTrue(any('conservative call effects' in item for item in checked['pendingValidation']))
        self.assertFalse(any('replay' in item for item in checked['pendingValidation']))
        self.assertEqual(conditional_exit_code({'jp': checked}), 0)

    def test_a_symbolic_state_candidate_can_fail_its_validity_check(self):
        slot = z.Int('policy.slot')
        solver = z.Solver()
        solver.add(slot == 999)
        candidate = interpret_solver_result(solver.check())
        self.assertTrue(candidate['candidateFound'])
        self.assertEqual(candidate['completedExhaustiveUpdates'], 0)
        # Synthetic domain control, not a proof of actual Object allocation.
        solver.add(slot >= 0, slot < 240)
        rejected = interpret_solver_result(solver.check())
        self.assertEqual(rejected['status'], 'conditional-model-exclusion')
        self.assertFalse(rejected['gameplayExcluded'])

    def test_unknown_or_failed_runs_never_count_as_completed_conditional_queries(self):
        unknown = interpret_solver_result('unknown')
        self.assertFalse(unknown['candidateFound'])
        self.assertFalse(unknown['conditionalQueryCompleted'])
        self.assertTrue(all('Obtain a solved query' in item for item in unknown['pendingValidation']))
        self.assertEqual(conditional_exit_code({'jp': unknown}), 2)
        known = interpret_solver_result('sat')
        self.assertEqual(conditional_exit_code({'jp': known, 'us': unknown}), 2)
        failed = dict(known, status='worker-timeout')
        self.assertEqual(conditional_exit_code({'jp': failed}), 2)
        self.assertEqual(conditional_exit_code({}), 2)


if __name__ == '__main__':
    unittest.main()
