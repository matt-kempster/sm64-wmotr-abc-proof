"""Negative controls for the observational checker; no game-state injection."""
import copy
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from check import parse, validate, FINAL


def main():
    data = parse(Path(sys.argv[1]).read_text(encoding='utf-8', errors='replace'))
    validate(data)

    def reject(label, mutate):
        altered = copy.deepcopy(data)
        mutate(altered)
        try:
            validate(altered)
        except (AssertionError, KeyError):
            print('PASS rejects ' + label)
        else:
            raise AssertionError('Accepted ' + label)

    reject('missing query', lambda d:d['R1_SEARCH_QUERY'].pop())
    reject('uncovered floor list', lambda d:d['R1_SEARCH_QUERY'][0].update(staticMembership=0, dynamicMembership=0))
    reject('wrong floor result', lambda d:d['R1_SEARCH_QUERY'][0].update(height=d['R1_SEARCH_QUERY'][0]['height'] ^ 1))
    reject('A input', lambda d:d['WAFEL_PILOT'][0].update(buttons=0x8000))
    reject('observer failure', lambda d:d['R1_SEARCH_RESULT'][0].update(failures=1))
    reject('wrong installed pointer', lambda d:next(s for s in d['R1_SEARCH'] if s['stage']=='final-platform-return').update(platform=61))
    # A measured disagreement must be reported, not rejected by the checker.
    positive = copy.deepcopy(data)
    s = next(s for s in positive['R1_SEARCH'] if s['stage']=='accepted-return')
    s['positions'][7] = 1156733869
    answer = validate(positive)
    assert answer['stageSummary']['accepted-return']['positionSplits'] == 1
    assert answer['stageSummary']['accepted-return']['maxDisplayMinusStateY'] > 1000
    print('PASS reports a synthetic split without treating it as gameplay evidence')


if __name__ == '__main__':
    main()
