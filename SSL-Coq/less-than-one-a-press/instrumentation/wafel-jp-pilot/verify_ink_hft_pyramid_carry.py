"""Read-only receipt verification; no game creation, advance or gameplay edits."""
import ast
import json
import math
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from ink_hft_pyramid_carry import compact, sha, summarize


def tangible_orphan(r):
    actor = r['actors'][0]
    assert actor['slot'] == 39 and actor['behavior'] == 'bhvBobomb'
    assert actor['activeFlags'] and actor['owner'] == r['area'] == 1
    assert actor['oHeldState'] == 1 and actor['oIntangibleTimer'] == 0
    assert r['held'] == -1
    assert math.hypot(actor['xyz'][0]-r['movement'][0], actor['xyz'][2]-r['movement'][2]) <= 200
    assert abs(actor['xyz'][1]-r['movement'][1]) <= 200


def main():
    receipt = json.loads(Path('docs/notes/ink-hft-pyramid-carry-receipt.json').read_text())
    path = Path(receipt['rawReportName']); raw = json.loads(path.read_text())
    script = Path('instrumentation/wafel-jp-pilot/ink_hft_pyramid_carry.py')
    assert receipt == compact(raw, path)
    assert sha(path) == receipt['rawReportSha256'] and sha(script) == raw['scriptSha256']
    assert sha('build/wafel-pilot/sm64_jp.dll') == raw['runtimeSha256']
    assert sha('build/wafel-pilot/capture.bKv95w/inputs.jsonl') == raw['baselineSha256']
    for p, digest in raw['helperSha256'].items(): assert sha(script.with_name(p)) == digest
    for p, digest in raw['sourceSha256'].items(): assert sha(Path('../../../reference-sm64-decomp')/p) == digest
    tree = ast.parse(script.read_text())
    assert not [n for n in ast.walk(tree) if isinstance(n, ast.Call) and isinstance(n.func, ast.Attribute)
                and n.func.attr == 'write' and isinstance(n.func.value, ast.Name) and n.func.value.id in ('g','fresh')]
    allowed = {'gMarioState.pos', 'gMarioObject.oPosX', 'gMarioObject.oPosY', 'gMarioObject.oPosZ',
               'gMarioObject.header.gfx.pos', 'gObjectPool[39].oPosX', 'gObjectPool[39].oPosY', 'gObjectPool[39].oPosZ'}
    for family, seed in raw['seeds'].items():
        setup = seed['setup']
        assert seed['returnTrail']['gameplayEdits'] == []
        if family == 'bloated-east':
            assert {e['path'] for e in setup['firstTeleport']['setupEdits']} == allowed
            assert {e['path'] for e in setup['setupEdits']} == allowed | {'gMarioState.action'}
            assert setup['nativeBloat']['samples'][-1]['actors'][0]['scale'][0] > 1.79
        else:
            assert {e['path'] for e in setup['setupEdits']} == allowed
            assert setup['seed']['gameplayEdits'] == []
    groups = [raw, raw['tornadoFollowup'], raw['entranceRoofCrawl']]
    assert [(len(g['trials']), sum(len(t['inputs']) for t in g['trials'])) for g in groups] == [(32,19031),(18,8100),(5,450)]
    comparisons = 0
    for group in groups:
        for t in group['trials']:
            assert all(not p['buttons'] & 0x8000 for p in t['inputs'])
            assert all(not r['input'] & 0x82 for r in t['samples'])
            assert t['summary'] == summarize(t['samples'], t['inputs'], t['summary']['terminal'])
            assert all(r['pillars'] == 0 and r['topAction'] == 0 for r in t['samples'])
        for replay in group['selectedFreshReplays']:
            assert replay['terminalMatched']
            assert replay['matchedSnapshots'] == len(group['trials'][replay['trialIndex']]['samples'])
            comparisons += replay['matchedSnapshots']
    assert comparisons == 4700
    lift = raw['trials'][0]
    peak = lift['summary']['maximumCarrier']; tangible_orphan(peak)
    assert peak['action'] == 0x108008A4 and peak['movement'][1] == 1597.811279296875
    assert peak['n'] == 372 and lift['summary']['closest']['n'] == 528
    assert any('ACT_TORNADO_TWIRLING' in e['entries'] for e in lift['events'])
    assert lift['summary']['final']['used'] == 65 and lift['summary']['final']['action'] == 0x1300
    assert raw['tornadoFollowup']['summary']['maximumCrawlY'] is None
    roof = raw['entranceRoofCrawl']; assert roof['prefix'] == lift['inputs'][:487]
    assert raw['tornadoFollowup']['prefix'] == lift['inputs'][:250]
    assert roof['summary']['crawlingTrials'] == 4
    for t in roof['trials'][1:]:
        row = t['summary']['maximumCarrierCrawl']; tangible_orphan(row)
        assert row['action'] == 0x04008448 and row['movement'][1] == row['floorY'] == 256
        assert row['n'] == 25 and row['timer'] == 1290
        tangible_orphan(t['samples'][-1])
        assert t['samples'][-1]['action'] == 0x04008448
    print('PASS: hashes/receipt projection/setup ledgers/no-A; 32+18+5 policies, 27581 updates;')
    print('10 recorded fresh replays/4700 snapshots; tangible orphan at high lift and roof crawl;')
    print('distinct peak/closest samples; zero pillars and no spinning-phase claim.')


if __name__ == '__main__': main()
