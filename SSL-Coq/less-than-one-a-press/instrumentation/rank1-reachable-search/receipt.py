"""Join the finite search to four full emulator replays without granting states."""
import argparse
import hashlib
import json
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from check import parse, validate

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'instrumentation/wafel-jp-pilot'))
from replay import compare, load_capture


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--approach', type=Path, required=True)
    p.add_argument('--box', type=Path, required=True)
    for name in ('baseline', 'direct', 'north', 'arrival'):
        p.add_argument('--'+name, type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    args = p.parse_args()
    result = dict(scope='Finite controller variations and exact JP replays; not an all-history exclusion.',
                  batches={}, replays={})
    for name in ('approach', 'box'):
        folder = getattr(args, name)
        report = json.loads((folder/'results.json').read_text())
        cases = report['results']
        assert report['manifest']['scriptSha256'] == sha(Path(__file__).with_name('search.py'))
        for case in cases:
            assert case['inputSha256'] == sha(folder/(case['config']['id']+'.inputs'))
        result['batches'][name] = dict(trials=len(cases), updates=sum(c['updates'] for c in cases),
            area1Samples=sum(c['area1Samples'] for c in cases),
            positiveGapTrials=sum(c['maxDisplayMinusStateY'] > 0 for c in cases),
            minDepth=min(c['minDepth'] for c in cases),
            floorNullTrials=sum(bool(c['floorNullSamples']) for c in cases),
            topPlatformTrials=sum(bool(c['originalTopPlatformSamples']) for c in cases),
            disappearedTrials=sum(bool(c['disappearedSamples']) for c in cases),
            nearestWhileOriginalTopActive=min(c['nearestWhileTopActive']['distance'] for c in cases),
            manifestSha256=sha(folder/'manifest.json'),
            inputHashes={c['config']['id']:c['inputSha256'] for c in cases})
    mapping = {'direct':(args.approach,'2549-direct-none'),
               'north':(args.approach,'2549-north-none'),
               'arrival':(args.box,'2549-box-original-90-135')}
    for name in ('baseline', 'direct', 'north', 'arrival'):
        capture = getattr(args, name)
        log = capture/'raw.log'
        exact = validate(parse(log.read_text(encoding='utf-8', errors='replace')))
        rows = load_capture(capture/'inputs.jsonl')
        comparison_file = args.output.parent/(name+'-comparison.json')
        assert compare(rows, comparison_file), name+' Wafel/emulator mismatch'
        linked = 0
        if name in mapping:
            folder, case = mapping[name]
            schedule = [[int(x) for x in line.split()] for line in (folder/(case+'.inputs')).read_text().splitlines()]
            assert schedule == [[r['poll'],r['buttons'],*r['stick']] for r in rows]
            samples = json.loads((folder/(case+'.samples.json')).read_text())
            for s in samples:
                observed = rows[s['afterPoll']]
                assert observed['poll'] == s['afterPoll']+1
                assert s['timer'] == observed['timer']+1
                assert all(s.get(k) == v for k, v in observed.items()
                           if k not in ('poll','timer','buttons','stick'))
                linked += 1
        exact['restoredOutputsMatched'] = linked
        exact['comparison'] = json.loads(comparison_file.read_text())
        exact['rawLogSha256'] = sha(log)
        exact['inputsSha256'] = sha(capture/'inputs.jsonl')
        result['replays'][name] = exact
    args.output.write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
    print('PASS: finite search schedules, full replays, restored outputs and exact query/warp checkpoints')


if __name__ == '__main__':
    main()
