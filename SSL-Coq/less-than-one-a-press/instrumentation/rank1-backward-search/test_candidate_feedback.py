"""Synthetic controls for history-scoped feedback; these are not gameplay."""
import copy
import unittest
from candidate_feedback import CandidateLoop, FinalCallPreimage, bits, HEIGHT, FLOOR, TOP, z


class FeedbackTests(unittest.TestCase):
    def evidence(self, loop, rows):
        return dict(loop.identity(rows), callPath=loop.cut.occurrences[0], captureSHA256='synthetic-test-only')

    def test_real_source_rejection_and_refinement_do_not_exclude_other_input(self):
        c = CandidateLoop(1, allowed=[[0,0,0], [0x4000,0,0]])
        status, proposal = c.propose([[0,0,0]])
        self.assertEqual(status, 'sat')
        values = [bits(-2200), bits(768), bits(-1024), HEIGHT, FLOOR, TOP]
        answer = c.consume(proposal['inputs'], values, 0, self.evidence(c, proposal['inputs']))
        self.assertEqual(answer['afterFeedback'], 'unsat')
        # Re-solving the same query moves to the untested B alternative.
        status, next_proposal = c.propose()
        self.assertEqual(status, 'sat')
        self.assertEqual(next_proposal['inputs'], [[0x4000,0,0]])

    def test_synthetic_positive_control_survives_source_and_feedback(self):
        c = CandidateLoop(1)
        _, proposal = c.propose([[0,0,0]])
        values = [bits(-2200), HEIGHT, bits(-1024), HEIGHT, FLOOR, TOP]
        answer = c.consume(proposal['inputs'], values, TOP, self.evidence(c, proposal['inputs']))
        self.assertEqual(answer['status'], 'checkpoint-witness')
        self.assertEqual(answer['afterFeedback'], 'sat')

    def test_observed_output_cannot_disagree_with_generated_suffix(self):
        c = FinalCallPreimage()
        with self.assertRaises(ValueError):
            c.validate_return([bits(-2200), bits(768), bits(-1024), HEIGHT, FLOOR, TOP], TOP)

    def test_wrong_history_context_or_call_cannot_supply_feedback(self):
        c = CandidateLoop(1)
        rows = [[0,0,0]]
        values = [bits(-2200), bits(768), bits(-1024), HEIGHT, FLOOR, TOP]
        for field in ('controllerSHA256', 'contextSHA256', 'callPath'):
            evidence = self.evidence(c, rows); evidence[field] = 'wrong'
            with self.subTest(field=field), self.assertRaises(ValueError):
                c.consume(rows, values, 0, evidence)
        self.assertFalse(c.refinements)

    def test_pending_is_scheduling_only_and_not_a_learned_rejection(self):
        c = CandidateLoop(1, allowed=[[0,0,0]])
        c.pending.append([[0,0,0]])
        self.assertEqual(c.propose()[0], 'unsat')
        # Underlying query still has the candidate; no runtime answer existed.
        self.assertEqual(c.solver.check(), z.sat)
        self.assertFalse(c.refinements)

    def test_no_A_and_no_unused_bits_in_every_proposal(self):
        c = CandidateLoop(30)
        for buttons in (0x8000, 0x0080, 0x0040):
            c.solver.push(); c.solver.add(c.inputs[10][0] == buttons)
            self.assertEqual(c.solver.check(), z.unsat)
            c.solver.pop()

    def test_wrong_query_height_does_not_get_accepted_by_owner_only(self):
        c = CandidateLoop(1)
        rows = [[0,0,0]]
        # A different owned platform height can pass the source's retention
        # decision, but it is not this checked-height target.
        values = [bits(-2200), bits(1280), bits(-1024), bits(1280), FLOOR, TOP]
        answer = c.consume(rows, values, TOP, self.evidence(c, rows))
        self.assertEqual(answer['status'], 'rejected-exact-history')


if __name__ == '__main__':
    unittest.main()
