"""Interpret exploratory solver answers without promoting them to gameplay facts.

The user accepts unanswered call effects and state validity as conditions for
candidate search. This changes the acceptance/reporting policy, not the formula
or the semantics of any missing call. SAT is not yet an executable trace.
"""

SEARCH_POLICY = 'conditional-candidate-generation'


def interpret_solver_result(result):
    result = str(result)
    if result not in ('sat', 'unsat', 'unknown'):
        raise ValueError('Not a solver answer: '+result)
    return dict(
        searchPolicy=SEARCH_POLICY,
        status={'sat': 'conditional-candidate',
                'unsat': 'conditional-model-exclusion',
                'unknown': 'inconclusive'}[result],
        solverResult=result,
        conditionalQueryCompleted=result != 'unknown',
        candidateFound=result == 'sat',
        replayReady=False,
        gameplayValidated=False,
        gameplayExcluded=False,
        completedExhaustiveUpdates=0,
        pendingValidation=([
            'Real call effects match the effects used by the proposed execution.',
            'Proposed earlier memory, live objects and callbacks are valid game state.',
            'A concrete predecessor trace and controller inputs can be extracted.',
            'An allowed controller history reaches the earlier state and replay reaches the target.'
        ] if result == 'sat' else [
            'The encoded entry conditions, endpoint and assumptions match the claimed case.',
            'Every relevant real execution is represented; conservative call effects may suffice.',
            'Any broader route exclusion requires this endpoint to be necessary for that route.'
        ] if result == 'unsat' else [
            'Obtain a solved query before claiming a candidate or an exclusion.'
        ]),
        interpretation={
            'sat': 'Symbolic candidate only; retain its call/state conditions and validate before claiming gameplay.',
            'unsat': 'No solution in this encoded conditional query; no game exclusion without a justified model/coverage connection.',
            'unknown': 'No candidate or exclusion obtained; conditions accepted for search do not resolve a timeout.'
        }[result])


def conditional_exit_code(runs):
    """Zero means every requested query answered, never that gameplay is proved."""
    return 0 if runs and all(
        r.get('conditionalQueryCompleted') is True
        and r.get('status') in ('conditional-candidate', 'conditional-model-exclusion')
        for r in runs.values()) else 2
