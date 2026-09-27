"""Resolve indirect calls from the live load and its actual source prefix.

This is an exploratory solver query, not a source-initializer assumption. A
writable script is read from entry memory, including preceding stores. Unknown
solver answers retain the alternative. A missing body matters only if its
address remains possible at the call. No result here supplies a gameplay state.
"""
from clight import seq
from engine import Path, word, z


def linear_prefix(body, call):
    """Find an unconditional prefix; decline to invent a loop/branch history."""
    prefix = []

    def scan(statement):
        if statement is call:
            return True
        if statement.tag == 'Ssequence':
            found = scan(statement.args[0])
            return found if found is not False else scan(statement.args[1])
        # An earlier call may change either the script or its current pointer.
        # A separate actual-body relation is needed, not an assumed frame.
        if statement.tag not in ('Sskip', 'Sset', 'Sassign'):
            return None
        prefix.append(statement)
        return False

    return seq(prefix) if scan(body) is True else None


def resolve_live_call(engine, scope, call, *, context, body, timeout_ms=1000):
    """Return every not-disproved compatible target and a reproducible receipt.

    Context constrains this function's entry, not the callback's post-state.
    The caller must retain it in the resulting predecessor condition. No context
    is imported into another shared callee relation. Without a straight prefix,
    conservatively keep all compatible symbols.
    """
    callee = call.args[1]
    symbols = engine.image.compatible(engine.typeof(callee), scope.function.unit)
    receipt = dict(caller=scope.function.name, compatibleTargets=len(symbols),
                   initializersAssumed=False, excluded=[], unresolved=[],
                   selected=[], solverChecks=0, pointerLoad=None)
    prefix = linear_prefix(body, call)
    if prefix is None:
        receipt.update(method='conservative type domain',
                       reason='No straight call-free prefix at this call; no source table is assumed live.')
        receipt['selected'] = [entry.name for entry in symbols]
        return symbols, receipt

    # Compute the operand's preimage through the REAL generated assignments.
    # Both reads and writes remain in the same byte memory as the main engine.
    probe = z.BitVec(f'{scope.name}.dispatch_probe.{len(engine.dispatch_receipts)}', 32)
    saved = engine.resolving_dispatch
    engine.resolving_dispatch = True
    try:
        formula = engine.wp(prefix, [Path(engine.eval(callee, scope) == probe)], scope)[0].condition
    finally:
        engine.resolving_dispatch = saved
    formula = z.simplify(formula)
    receipt.update(method='actual-prefix live-pointer preimage', pointerLoad=formula.sexpr(),
                   entryContext=context.sexpr())
    solver = z.Solver()
    solver.set(timeout=timeout_ms)
    solver.add(context, formula)
    address_cases = [probe == word(engine.function_address(entry.name)) for entry in symbols]
    compatible = z.Or(*address_cases)
    # One query first decides whether the entire missing-body family is ruled
    # out. It does not compile those declarations or treat them as no-ops.
    missing = [(entry, guard) for entry, guard in zip(symbols, address_cases) if not entry.internal]
    solver.push()
    solver.add(z.Or(*[guard for _, guard in missing]))
    missing_status = solver.check()
    receipt['solverChecks'] += 1
    receipt['missingBodyFamily'] = str(missing_status)
    solver.pop()

    # A timeout retains ALL remaining targets; unknown is never an exclusion.
    solver.add(compatible)
    remaining = {engine.function_address(entry.name): entry for entry in symbols}
    selected = []
    while remaining:
        status = solver.check()
        receipt['solverChecks'] += 1
        if status == z.unsat:
            receipt['excluded'].extend(entry.name for entry in remaining.values())
            break
        if status == z.unknown:
            receipt['unresolved'].extend(entry.name for entry in remaining.values())
            receipt['solverReason'] = solver.reason_unknown()
            selected.extend(remaining.values())
            break
        address = solver.model().eval(probe, model_completion=True).as_long()
        entry = remaining.pop(address)
        selected.append(entry)
        solver.add(probe != word(address))
        # Unconstrained bytes can contain every address. Retain the remaining
        # domain instead of enumerating thousands of identical possible answers.
        if len(selected) >= 8 and remaining:
            receipt['unresolved'].extend(entry.name for entry in remaining.values())
            receipt['solverReason'] = 'Enumeration deferred after eight targets; all remaining alternatives retained.'
            selected.extend(remaining.values())
            break
    selected_names = {entry.name for entry in selected}
    if missing_status == z.unsat:
        for entry, _ in missing:
            selected_names.discard(entry.name)
            if entry.name not in receipt['excluded']:
                receipt['excluded'].append(entry.name)
        receipt['unresolved'] = [name for name in receipt['unresolved'] if name in selected_names]
    selected = [entry for entry in symbols if entry.name in selected_names]
    receipt['selected'] = [entry.name for entry in selected]
    receipt['scope'] = ('Only type-compatible defined calls in the selected linkage. '
                        'Non-function addresses are not valid defined executions. '
                        'Entry conditions, if any, stay explicit in the predecessor.')
    return selected, receipt
