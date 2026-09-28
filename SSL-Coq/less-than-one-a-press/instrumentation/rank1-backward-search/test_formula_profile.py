"""Application equivalence controls; no gameplay coverage claim."""
import unittest
from engine import z
from formula_profile import ExactLocalSimplifier, inspect_dag


class FormulaProfileTests(unittest.TestCase):
    def test_large_expression_keeps_original_coverage(self):
        before=z.Or(*[z.Bool('profile.large.'+str(i)) for i in range(1001)])
        simplifier=ExactLocalSimplifier()
        self.assertTrue(simplifier.rewrite(before).eq(before))
        self.assertEqual(simplifier.totals['skippedLarge'],1)

    def test_rewrite_budget_keeps_original_coverage(self):
        from unittest.mock import patch
        before=z.And(z.Bool('profile.keep'),z.BoolVal(True))
        with patch('formula_profile.z.simplify',side_effect=z.Z3Exception('max. steps exceeded')):
            self.assertTrue(ExactLocalSimplifier().rewrite(before).eq(before))

    def equivalent(self, before, after):
        solver=z.Solver(); solver.set(timeout=3000)
        solver.add(before != after)
        self.assertEqual(solver.check(),z.unsat)

    def test_recursive_calls_stay_opaque_under_binders(self):
        x=z.Int('profile.x')
        f=z.RecFunction('profile.f',z.IntSort(),z.BoolSort())
        z.RecAddDefinition(f,[x],z.If(x<=0,z.BoolVal(True),f(x-1)))
        before=z.Exists([x],z.And(z.BoolVal(True),f(x),f(x)))
        after=ExactLocalSimplifier().rewrite(before)
        self.assertIn(f.get_id(),inspect_dag(after)[1])
        self.equivalent(before,after)

    def test_arrays_bits_and_float_branch_are_preserved(self):
        a=z.Array('profile.a',z.BitVecSort(32),z.BitVecSort(8))
        p=z.BitVec('profile.p',32); v=z.BitVec('profile.v',8)
        f=z.FP('profile.float',z.Float32())
        before=z.And(z.Select(z.Store(a,p,v),p)==v,
                     z.Or(z.fpIsNaN(f),z.fpLT(f,z.FPVal(0,z.Float32()))))
        simplifier=ExactLocalSimplifier();after=simplifier.rewrite(before)
        self.equivalent(before,after)
        self.assertLess(simplifier.totals['nodesAfter'],simplifier.totals['nodesBefore'])


if __name__=='__main__':unittest.main()
