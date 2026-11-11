"""Read-only audit of the alternative hands-free acquisition receipt.

No game is created or advanced. Run from the less-than-one-a-press directory.
"""
import ast
import hashlib
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ink_handsfree_acquisition_routes import compact, sha, sha_controls, summarize


def main():
    receipt_path = Path('docs/notes/ink-handsfree-acquisition-routes-receipt.json')
    receipt = json.loads(receipt_path.read_text())
    raw_path = Path(receipt['rawPath'])
    raw = json.loads(raw_path.read_text())
    script = Path('instrumentation/wafel-jp-pilot/ink_handsfree_acquisition_routes.py')
    tree = ast.parse(script.read_text())
    assert not [n for n in ast.walk(tree) if isinstance(n, ast.Call)
                and isinstance(n.func, ast.Attribute) and n.func.attr == 'write'
                and isinstance(n.func.value, ast.Name) and n.func.value.id in ('g', 'fresh')]
    assert sha(script) == raw['scriptSha256']
    assert sha(raw_path) == receipt['rawSha256']
    assert receipt == compact(raw, raw_path)
    assert raw['gameplaySetupWrites'] == [] and raw['baselineAFrames'] == 0
    assert sha('build/wafel-pilot/sm64_jp.dll') == raw['runtimeSha256']
    assert sha('build/wafel-pilot/capture.bKv95w/inputs.jsonl') == raw['baselineSha256']
    for name, digest in raw['helperSha256'].items():
        assert sha(script.with_name(name)) == digest
    for name, digest in raw['sourceSha256'].items():
        assert sha(Path('../../../reference-sm64-decomp') / name) == digest
    summaries = [summarize(t) for t in raw['trials']]
    assert len(summaries) == 66
    assert sum(s['updates'] for s in summaries) == 19471
    assert len(set((s['policy']['prefix'], s['inputSha256']) for s in summaries)) == 49
    assert sum(s['pickup'] is not None for s in summaries) == 45
    assert sum(s['handsfreeExit'] is not None for s in summaries) == 8
    assert all(s['crawlUpdates'] == 0 and s['spinningSamples'] == 0 for s in summaries)
    west_pickups = 0
    for t in raw['trials']:
        assert len(t['inputs']) == len(t['samples'])
        assert all(not p['buttons'] & 0x8000 for p in t['inputs'])
        assert all(not s['input'] & 0x82 for s in t['samples'])
        if t['policy']['slot'] == 49:
            assert t['handsfreeExit'] is None
            if summarize(t)['pickup'] is not None:
                landings = [e['sample'] for e in t['events']
                            if 'ACT_DIVE_PICKING_UP' in e['actionEntries']]
                assert len(landings) == 1
                landing = landings[0]
                assert landing['movement'][1] == 0 and landing['floorType'] == 0
                assert landing['floorNormal']['y'] == 1
                assert any(e['actionEntries'] == ['ACT_HOLD_IDLE', 'ACT_CRAZY_BOX_BOUNCE']
                           for e in t['events'])
                west_pickups += 1
        elif t['handsfreeExit']:
            assert t['handsfreeExit']['actionEntries'] == ['ACT_DIVE_PICKING_UP', 'ACT_STOMACH_SLIDE']
    assert west_pickups == 21
    for selected, count in zip(raw['selected'], (200, 348, 302)):
        replay = selected['freshReplay']
        assert replay['passed'] and replay['comparedInitial']
        assert replay['comparedBranchSnapshots'] == count
        assert replay['gameplaySetupWrites'] == []
        assert len(selected['fullInputs']) == selected['fullInputCount']
        assert sha_controls(selected['fullInputs']) == selected['fullInputSha256']
        assert all(not p['buttons'] & 0x8000 for p in selected['fullInputs'])
        trial = next(t for t in raw['trials'] if t['policy'] == selected['summary']['policy'])
        assert selected['summary'] == summarize(trial)
        assert selected['inputs'] == trial['inputs']
    history = raw['acceptedHistoryAudit']
    deletion = history['firstEasternBoxInactive']
    assert (deletion['before']['n'], deletion['after']['n']) == (490, 491)
    assert deletion['before']['action'] == 0x8AE and deletion['before']['actionArg'] == 2
    assert deletion['before']['held'] == 47 and deletion['after']['held'] == -1
    assert deletion['after']['boxBehavior'] and deletion['after']['boxActive'] == 0
    reuse = history['firstEasternSlotReuse']
    assert reuse['after']['n'] == 492 and not reuse['after']['boxBehavior']
    assert len(history['levelAreaLivesChangesFrom350']) == 1
    assert [(s['inputCount'], [b['slot'] for b in s['boxes']])
            for s in history['fullPoolScans']] == [
                (350, [47, 49]), (1000, [49]), (1500, [49]),
                (2000, [49]), (2390, [49]), (2500, [49])]
    assert all(s['poolSlotsScanned'] == 240 for s in history['fullPoolScans'])
    print('PASS: hashes, compact receipt, 66 policies/19471 updates/49 histories,')
    print('45 pickups/8 hands-free exits, 21 flat west landings, no A/setup writes,')
    print('three stored fresh replay assertions, and accepted box47 deletion/pool scans.')


if __name__ == '__main__':
    main()
