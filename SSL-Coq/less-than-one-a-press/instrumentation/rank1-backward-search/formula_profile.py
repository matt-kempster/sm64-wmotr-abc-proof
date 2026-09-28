"""Exact local rewriting with recursive applications kept opaque.

No source path, controller value, callback or call effect is sampled/removed.
Temporarily rename recursive declarations to ordinary uninterpreted functions,
simplify, then restore them. This prevents simplification from unfolding the
whole recursive program. Rewrites hold even for arbitrary function meanings.
"""
from collections import Counter
import time
from engine import z


def inspect_dag(expression, limit=None):
    pending, seen, recursive, counts = [expression], set(), {}, Counter()
    while pending:
        node = pending.pop()
        if node.get_id() in seen:
            continue
        seen.add(node.get_id())
        if limit is not None and len(seen)>limit:
            return len(seen), recursive, dict(counts, truncated=1)
        if z.is_quantifier(node):
            counts['quantifiers'] += 1
            pending.append(node.body())
        elif z.is_app(node):
            decl = node.decl()
            if decl.kind() == z.Z3_OP_RECURSIVE:
                recursive[decl.get_id()] = decl
                counts['recursiveApplications'] += 1
            if decl.kind() in (z.Z3_OP_SELECT, z.Z3_OP_STORE):
                counts['arrayOperations'] += 1
            pending.extend(node.children())
    return len(seen), recursive, dict(counts)


class ExactLocalSimplifier:
    def __init__(self):
        self.shadows = {}
        self.totals = Counter()
        self.slowest = []

    def rewrite(self, expression, label='formula'):
        began = time.perf_counter()
        before, declarations, counts = inspect_dag(expression, limit=1000)
        if counts.get('truncated'):
            self.totals.update(skippedLarge=1)
            return expression
        forward, reverse = [], []
        for key, decl in declarations.items():
            if key not in self.shadows:
                self.shadows[key] = z.FreshFunction(
                    *[decl.domain(i) for i in range(decl.arity())], decl.range())
            shadow = self.shadows[key]
            arguments = [z.Var(i, decl.domain(i)) for i in range(decl.arity())]
            forward.append((decl, shadow(*arguments)))
            reverse.append((shadow, decl(*arguments)))
        opaque = z.substitute_funs(expression, *forward) if forward else expression
        try:
            simplified = z.simplify(opaque, max_steps=5000)
        except z.Z3Exception as exc:
            if 'max. steps exceeded' not in str(exc):
                raise
            self.totals.update(skippedStepLimit=1)
            return expression
        result = z.substitute_funs(simplified, *reverse) if reverse else simplified
        after, _, _ = inspect_dag(result)
        elapsed = time.perf_counter() - began
        self.totals.update(calls=1, nodesBefore=before, nodesAfter=after,
                           seconds=elapsed, **counts)
        self.slowest.append(dict(label=label, seconds=elapsed,
                                 nodesBefore=before, nodesAfter=after))
        self.slowest.sort(key=lambda item: item['seconds'], reverse=True)
        del self.slowest[10:]
        return result

    def receipt(self):
        return dict(totals=dict(self.totals), slowest=self.slowest,
                    scope='Summed local DAG visits; not globally unique nodes or gameplay histories.',
                    bounds='Skip expressions over 1000 nodes; on 5000 simplifier steps, retain original expression. No execution-depth bound.',
                    method='Recursive declarations shadowed, equivalent local rewrites, declarations restored.')
