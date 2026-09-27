"""Check exact JP checkpoints, real query returns and final platform decisions.

This validates finite observations; it never treats an empty search as coverage.
The Wafel/emulator field comparison is a separate required check.
"""
import argparse
import collections
import hashlib
import json
import math
import struct
from pathlib import Path

QUERY1, QUERY2, FINAL = 0x802538a0, 0x802538e4, 0x802c7f88


def f32(word):
    return struct.unpack('>f', struct.pack('>I', word))[0]


def round32(value):
    return struct.unpack('>f', struct.pack('>f', value))[0]


def parse(text):
    result = collections.defaultdict(list)
    for line in text.splitlines():
        if line.startswith(('R1_SEARCH,', 'R1_SEARCH_QUERY,', 'R1_SEARCH_WRITE,', 'R1_SEARCH_RESULT,', 'WAFEL_PILOT,')):
            kind, payload = line.split(',', 1)
            result[kind].append(json.loads(payload))
    return result


def validate(data):
    assert len(data['R1_SEARCH_RESULT']) == 1
    receipt = data['R1_SEARCH_RESULT'][0]
    assert receipt['armed'] == 1 and receipt['failures'] == 0
    samples, queries = data['R1_SEARCH'], data['R1_SEARCH_QUERY']
    inputs = data['WAFEL_PILOT']
    assert inputs and [r['poll'] for r in inputs] == list(range(1, len(inputs)+1))
    assert all(not r['buttons'] & 0x8000 for r in inputs)
    assert receipt['samples'] == len(samples) and receipt['positionWrites'] == len(data['R1_SEARCH_WRITE'])
    stages = collections.Counter(s['stage'] for s in samples)
    assert receipt['queries'] == stages['geometry-query1-return'] + stages['geometry-query2-return'] > 0
    assert receipt['retries'] == stages['geometry-query2-return']
    assert receipt['finalQueries'] == stages['final-query-return'] == stages['final-platform-return'] > 0
    assert receipt['accepted'] == stages['accepted-return']
    assert receipt['firstArea2Apply'] == stages['first-area2-apply-entry']
    assert receipt['firstArea2ApplyComplete'] == stages['first-area2-apply-return']
    assert len(queries) == receipt['queries'] + receipt['finalQueries']
    assert receipt['misses'] == sum(q['floor'] == 0 for q in queries if q['returnPC'] != FINAL)
    by_poll = collections.defaultdict(dict)
    for s in samples:
        assert receipt['firstPoll'] <= s['poll'] < receipt['endPollExclusive']
        assert s['stage'] not in by_poll[s['poll']], 'Missing distinction between multiple calls in one poll'
        by_poll[s['poll']][s['stage']] = s
        assert len(s['positions']) == 9 and all(math.isfinite(f32(v)) for v in s['positions'])
    for q in queries:
        stage = {QUERY1:'geometry-query1-return', QUERY2:'geometry-query2-return', FINAL:'final-query-return'}[q['returnPC']]
        s = by_poll[q['poll']][stage]
        assert q['timer'] == s['timer'] and q['floor'] == s['floor'] and q['height'] == s['height']
        assert math.isfinite(f32(q['height']))
        expected_arguments = s['positions'][3:6] if q['returnPC'] == FINAL else s['positions'][:3]
        assert q['arguments'] == expected_arguments
        assert all(math.isfinite(f32(v)) and -32768 <= f32(v) < 32768 for v in q['arguments'])
        assert q['staticMembership'] >= 0 and q['dynamicMembership'] >= 0
        assert (q['staticMembership'] > 0) + (q['dynamicMembership'] > 0) == int(q['floor'] != 0)
        if q['returnPC'] == QUERY2:
            assert by_poll[q['poll']]['geometry-query1-return']['floor'] == 0
        if q['returnPC'] == FINAL:
            tail = by_poll[q['poll']]['final-platform-return']
            difference = abs(round32(f32(q['arguments'][1]) - f32(q['height'])))
            expected = s['owner'] if q['floor'] and s['owner'] >= 0 and difference < 4 else -1
            assert tail['platform'] == tail['objectPlatform'] == expected
            assert tail['floor'] == q['floor'] and tail['height'] == q['height']
    for poll, frame in by_poll.items():
        if 'geometry-query1-return' in frame:
            for required in ('collision-entry', 'geometry-complete', 'interactions-entry',
                             'ordinary-copy-return', 'final-query-return', 'final-platform-return'):
                assert required in frame, (poll, required)
            order = [s['stage'] for s in samples if s['poll'] == poll]
            required = ['collision-entry', 'geometry-query1-return', 'geometry-complete',
                        'interactions-entry', 'ordinary-copy-return', 'final-query-return', 'final-platform-return']
            assert [order.index(x) for x in required] == sorted(order.index(x) for x in required)
        if 'accepted-return' in frame:
            assert frame['accepted-return']['action'] == 0x1300
            assert 'upper-handler-entry' in frame and 'final-platform-return' in frame
    overview = {}
    for stage in ('collision-entry', 'geometry-query1-return', 'geometry-query2-return',
                  'accepted-return', 'ordinary-copy-return', 'final-query-return'):
        ss = [s for s in samples if s['stage'] == stage]
        if ss:
            overview[stage] = dict(count=len(ss), nullFloors=sum(s['floor'] == 0 for s in ss),
                ownedFloorResults=sum(s['owner'] >= 0 for s in ss),
                maxDisplayMinusStateY=max(f32(s['positions'][7])-f32(s['positions'][1]) for s in ss),
                minDisplayMinusStateY=min(f32(s['positions'][7])-f32(s['positions'][1]) for s in ss),
                positionSplits=sum(s['positions'][:3] != s['positions'][3:6]
                                  or s['positions'][:3] != s['positions'][6:] for s in ss))
    return dict(passed=True, inputPolls=len(inputs), controllerAFrames=0, receipt=receipt,
                stageSummary=overview,
                queryLists=dict(staticResults=sum(q['staticMembership'] > 0 for q in queries),
                                dynamicResults=sum(q['dynamicMembership'] > 0 for q in queries)),
                accepted=[s for s in samples if s['stage'] == 'accepted-return'],
                firstArea2Apply=[s for s in samples if s['stage'].startswith('first-area2-apply-')],
                scope='Finite authentic-JP observations; no all-history theorem and no supplied gameplay state.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('log', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = validate(parse(args.log.read_text(encoding='utf-8', errors='replace')))
    result['logSha256'] = hashlib.sha256(args.log.read_bytes()).hexdigest()
    args.output.write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
