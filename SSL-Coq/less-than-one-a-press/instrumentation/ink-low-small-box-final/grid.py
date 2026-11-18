"""Check simpler drop coordinates around the useful fractional placement."""
import argparse
import json
import runpy
from pathlib import Path

HERE = Path(__file__).resolve().parent
experiment = runpy.run_path(str(HERE / 'test.py'))


def check():
    g, observer, start, _, _ = experiment['c'].root()
    ref = json.loads((experiment['OLD'] / 'positive.json').read_bytes())
    grids = {
        'integer': (list(range(-2111, -2100)), list(range(-1111, -1101))),
        'quarter': ([-2111 + i / 4 for i in range(13)], [-1107 + i / 4 for i in range(9)]),
    }
    rows = {}
    for name, (xs, zs) in grids.items():
        captures = []
        for x in xs:
            for z in zs:
                point = [x, 1920, z]
                case = experiment['trial'](g, observer, start, ref, point, stop=6)
                if case['captureStep'] is not None:
                    case = experiment['trial'](g, observer, start, ref, point)
                    assert case['useful'] and case['retained']
                    captures.append(experiment['describe'](case))
        rows[name] = dict(xs=xs, zs=zs, count=len(xs) * len(zs), captures=captures)
    return rows


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--verify', action='store_true')
    args = parser.parse_args()
    rows = check()
    assert check() == rows
    assert not rows['integer']['captures']
    assert [r['drop'] for r in rows['quarter']['captures']] == [
        [-2109.75, 1920, -1106.25], [-2108.5, 1920, -1106.75]]
    experiment['persist'](HERE / 'grid.json', rows, args.verify)
    print('PASS 110 integer and 117 quarter-grid drops through update 131, two fresh roots; '
          'two quarter-grid hits rerun through useful Area 2 entry')
