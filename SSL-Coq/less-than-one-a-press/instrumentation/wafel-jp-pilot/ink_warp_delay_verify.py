"""Check stored warp-delay evidence; --raw checks all controller rows."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from ink_warp_delay_search import digest, policies, is_capture, outside, BUTTON_BITS, STICKS


def check(r, raw=None):
    assert r['sourceSha256']==hashlib.sha256(Path(__file__).with_name('ink_warp_delay_search.py').read_bytes()).hexdigest()
    assert len(r['recipes'])==60 and r['policies']==list(policies())
    for i,q in enumerate(r['recipes']):
        assert q['index']==i and q['verticalGap']==q['display'][1]-q['low'][1]
        assert any(p['height']==q['display'][1] and p['captures'] for p in q['thresholdProbes'])
        assert any(p['height']==q['display'][1]-1 and not p['captures'] for p in q['thresholdProbes'])
        assert all(p['captures']==is_capture(p['observed']) for p in q['thresholdProbes'])
    for q in r['retained']+r['counterfactuals']:
        assert q['historyDigest']==digest([q['initial'],q['samples'],q['pads'],q['events'],q['edits']])
        assert q['timingDigest']==digest(q['projection']) and q['updates']==len(q['samples'])
        assert q['captured']==is_capture(q['samples'][0])
        assert all(not p['buttons']&0x8000 for p in q['pads'])
        assert all(not(s['buttonsDown']|s['buttonsPressed'])&0x8000 for s in q['samples'])
        assert q['outsideElevator']==outside(q['arrival'])
        assert q['suffixGameEdits']==len(q['edits'])
        if q['extraDelay']:
            assert q['edits']==[dict(afterUpdate=2,path='sDelayedWarpTimer',before=19,after=19+q['extraDelay'])]
        else: assert not q['edits']
    e=r['exhaustive'];assert e['buttonBits']==BUTTON_BITS and e['sticks']==STICKS and e['buttonMasks']==8192
    assert [q['afterCaptureUpdate'] for q in e['checkpoints']]==[1,12]
    assert all(q['counts']==dict(trials=73728,matches=73728) and not q['differences'] for q in e['checkpoints'])
    assert r['summary']['exhaustiveTrials']==r['summary']['exhaustiveMatches']==147456
    assert r['summary']['counterfactualTrials']==len(r['counterfactuals'])==102
    assert r['summary']['counterfactualUseful']==sum(q['outsideElevator'] for q in r['counterfactuals'])==36
    assert r['summary']['counterfactualUpdates']==sum(q['updates'] for q in r['counterfactuals'])
    assert r['summary']['freshCases']==len(r['fresh'])==24 and all(q['matched'] for q in r['fresh'])
    assert r['summary']['freshUpdates']==sum(q['updates'] for q in r['fresh'])==593
    p=r['pauseControl'];assert p['historyDigest']==digest([p['pads'],p['samples']])
    assert all(q['playMode']==2 and q['topSlot']['timer']==129 for q in p['samples'][:32])
    if raw is not None:
        rows=raw['rows'];assert digest(rows)==r['rowsDigest'] and raw['summary']==r['summary']
        assert len(rows)==r['summary']['trials']==5940
        assert [(q['recipeIndex'],q['policy']) for q in rows]==[(i,p) for i in range(60) for p in r['policies']]
        baseline={i:next(q['timingDigest'] for q in rows if q['recipeIndex']==i) for i in range(60)}
        for q in rows:
            assert q['extraDelay']==q['suffixGameEdits']==q['AInputs']==0
            assert q['timingMatchesNeutral']==(q['timingDigest']==baseline[q['recipeIndex']])
            assert q['outsideElevator']==outside(q['arrival'])
        expected=dict(updates=sum(q['updates'] for q in rows),initialCaptures=sum(q['captured'] for q in rows),
            pausedTrials=sum(q['pauseUpdates']>0 for q in rows),neutralTimingMatches=sum(q['timingMatchesNeutral'] for q in rows),
            earlierUseful=sum(q['phase']<131 and q['outsideElevator'] for q in rows),
            phase131Useful=sum(q['phase']==131 and q['outsideElevator'] for q in rows))
        assert all(r['summary'][k]==v for k,v in expected.items())


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('receipt',type=Path);p.add_argument('--raw',type=Path)
    a=p.parse_args();r=json.loads(a.receipt.read_text());raw=None
    if a.raw:
        assert hashlib.sha256(a.raw.read_bytes()).hexdigest()==r['rawSha256'];raw=json.loads(a.raw.read_text())
    check(r,raw)
    changes=[lambda q:q['recipes'][0].__setitem__('verticalGap',0),
             lambda q:q['counterfactuals'][0]['edits'][0].__setitem__('path','gMarioState.action'),
             lambda q:q['counterfactuals'][0].__setitem__('suffixGameEdits',0),
             lambda q:q['exhaustive']['checkpoints'][0]['counts'].__setitem__('matches',73727),
             lambda q:q['pauseControl']['samples'][1]['topSlot'].__setitem__('timer',130),
             lambda q:q['summary'].__setitem__('freshUpdates',594)]
    for change in changes:
        q=copy.deepcopy(r);change(q)
        try:check(q)
        except AssertionError:continue
        raise AssertionError('Mutation was not rejected')
    print(json.dumps(dict(status='PASS',controllerRows=0 if raw is None else len(raw['rows']),
        counterfactuals=len(r['counterfactuals']),exhaustiveTrials=147456,mutationRejections=len(changes))))


if __name__=='__main__':main()
