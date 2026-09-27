"""Recheck real candidate receipts, feedback, and damaged-observation controls.

Raw captures stay local. The compact output contains experimental results and
provenance, never an all-history or Coq verdict.
"""
import argparse
import copy
import json
from pathlib import Path
import tempfile
from candidate_feedback import (CandidateLoop, digest, load_receipt, read_baseline,
                                save, number, z)


def audit(run, baseline_path, output):
    report = json.loads((run/'report.json').read_text(encoding='utf-8'))
    context = report['context']
    baseline = read_baseline(baseline_path)
    assert context['baselineSHA256'] == digest(baseline_path.read_bytes())
    first, n = context['firstPoll'], context['updates']
    prefix = [[r['poll'], r['buttons'], *r['stick']] for r in baseline[:first-1]]
    loop = CandidateLoop(n, prefix=prefix, context=context)
    cases = []
    first_data = None
    for item in report['candidates']:
        folder = run/f"candidate-{item['iteration']:03d}"
        proposal = json.loads((folder/'proposal.json').read_text(encoding='utf-8'))
        rows = proposal['inputs']; schedule = loop.history(rows)
        if item['status'] == 'pending-runtime-validation':
            loop.pending.append(rows)
            continue
        log = Path(item['replayLog'])
        reply = load_receipt(log, schedule, baseline, first, n)
        assert reply['captureSHA256'] == item['evidence']['captureSHA256']
        assert loop.identity(rows) == {k:item['evidence'][k] for k in loop.identity(rows)}
        loop.solver.push(); loop.solver.add(loop.key(rows))
        assert loop.solver.check() == z.sat, 'Candidate was already excluded before its own feedback'
        loop.solver.pop()
        for event in reply['occurrences']:
            loop.cut.validate_return(event['values'], event['output'])
        last = reply['occurrences'][-1]
        result = loop.consume(rows, last['values'], last['output'], item['evidence'])
        assert result['status'] == item['status'] and result['afterFeedback'] == item['afterFeedback']
        # Also verify that the persisted refined formula really has the
        # reported answer, not merely that the JSON summary says UNSAT.
        check = z.Solver(); check.set(timeout=15000)
        check.from_file(str(folder/'refined.smt2'))
        assert str(check.check()) == result['afterFeedback']
        cases.append(dict(candidate=item['iteration'], status=result['status'],
            controllerSHA256=reply['controllerSHA256'], captureSHA256=reply['captureSHA256'],
            validatedUpdates=n, matchedFloorCalls=len(reply['occurrences']),
            finalUpdate=n, finalPoll=last['poll'], topTimer=last['topTimer'],
            query=[number(v) for v in last['queryBits']], floorHeight=number(last['heightBits']),
            ownerSlot=last['ownerSlot'], platformSlot=last['platformSlot'],
            targetAfterFeedback=result['afterFeedback'],
            emulatorSeconds=item['emulatorSeconds'],
            cacheRevalidated=item.get('exactHistoryCacheRevalidated', False),
            proposedSHA256=digest((folder/'proposed.smt2').read_bytes()),
            refinedSHA256=digest((folder/'refined.smt2').read_bytes())))
        if first_data is None:
            first_data = log, schedule
    if not first_data:
        raise ValueError('No completed real candidate to audit')
    log, schedule = first_data
    controls = []
    with tempfile.TemporaryDirectory() as temp:
        for field in ('entrySP', 'returnSP', 'outputAddress', 'entryObject', 'returnObject', 'stateObject'):
            lines = log.read_text(encoding='utf-8', errors='replace').splitlines()
            for i, line in enumerate(lines):
                if not line.startswith('R1_SEARCH_QUERY,'):
                    continue
                event = json.loads(line.split(',', 1)[1])
                if event['returnPC'] == 0x802c7f88:
                    event[field] += 4
                    lines[i] = 'R1_SEARCH_QUERY,'+json.dumps(event)
                    break
            damaged = Path(temp)/'damaged.log'
            damaged.write_text('\n'.join(lines)+'\n', encoding='utf-8')
            try:
                load_receipt(damaged, schedule, baseline, first, n)
            except (ValueError, AssertionError):
                controls.append(field)
            else:
                raise AssertionError('Damaged observation was accepted: '+field)
        wrong_schedule = copy.deepcopy(schedule)
        wrong_schedule[first-1][1] ^= 0x4000
        wrong_baseline = copy.deepcopy(baseline)
        wrong_baseline[0]['timer'] += 1
        for name, history, base in (('controller-history', wrong_schedule, baseline),
                                    ('prefix-observation', schedule, wrong_baseline)):
            try:
                load_receipt(log, history, base, first, n)
            except (ValueError, AssertionError):
                controls.append(name)
            else:
                raise AssertionError('Wrong replay identity was accepted: '+name)
    result = dict(status='Real candidate feedback rechecked; exhaustive search remains open.',
        context=context, candidates=cases, rejectedExactHistories=sum(c['status']=='rejected-exact-history' for c in cases),
        matchedFloorCallReplies=sum(c['matchedFloorCalls'] for c in cases),
        pendingCandidates=len(loop.pending), damagedObservationControlsRejected=controls,
        completedExhaustiveUpdates=0, globalExclusion=False, wholeInkInstallationWitness=False,
        generatedSource=loop.cut.engine.functions, implementationHashes=report['implementationHashes'],
        observerSHA256=report['observerSHA256'], applicationTests=58,
        limits=['The earlier controller prefix is fixed; other prefixes remain open.',
            'Only these exact histories were tested. No failed sample excludes an input group.',
            'The arbitrary-memory horizon and its unanchored call sites remain unresolved.',
            'The checkpoint is necessary for this proposal; it is not the complete Ink installation.',
            'Python/SMT/runtime validation is experimental evidence, not a new Coq theorem.'])
    save(output, result)
    print(json.dumps({k:result[k] for k in ('rejectedExactHistories','matchedFloorCallReplies',
                                          'pendingCandidates','damagedObservationControlsRejected')}, indent=2))


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('run', type=Path)
    p.add_argument('--baseline', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    audit(a.run, a.baseline, a.output)
