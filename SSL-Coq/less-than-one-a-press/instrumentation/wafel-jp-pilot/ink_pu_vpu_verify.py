"""Validate bounded PU/VPU receipts and optionally replay them afresh.

This verifies logged observations and declared cuts, not a no-A producer.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from ink_pu_vpu import run as handoff_run, digest
from ink_pu_vpu_prerequisites import run as prerequisite_run


def check(r):
    h,p=r['handoff'],r['prerequisites']
    assert h['baselineSha256']==p['baselineSha256']== '9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72'
    assert h['runtimeSha256']==p['runtimeSha256']==digest('build/wafel-pilot/sm64_jp.dll')
    assert len(h['trials'])==21 and len(p['crawlTrials'])==2 and len(p['releaseTrials'])==6
    trials={t['recipe']['name']:t for t in h['trials']}
    assert {n for n,t in trials.items() if t['usefulArrival']}=={'ordinary-box','vpu-box'}
    for t in h['trials']:
        assert t['initial']['movement']==t['initial']['collision']==t['initial']['display']
        assert t['initial']['floorY']==1024
        assert len(t['samples'])==len(t['events'])==len(t['controls'])
        for edit in t['edits']:
            assert edit['path'] in {'gMarioState.'+f for f in ('pos','action','actionState','actionTimer','forwardVel','vel','faceAngle')} | {'gMarioObject.oPos'+a for a in 'XYZ'} | {'gMarioObject.header.gfx.pos'} | {'gObjectPool[49].oPos'+a for a in 'XYZ'}
        for pad,row in zip(t['controls'],t['samples']):
            assert not pad['buttons']&0x8000 and not row['input']&0x82
    v=trials['vpu-box'];a,b=v['samples'][:2]
    assert a['movement']==a['collision']==[-1882,768,-939]
    assert a['display']==[-1882,67277,-939] and a['floorY']==768 and a['action']==0x04008448
    assert a['topSurfaceCount']==0 and a['ceilingY']==20000 and not a['ceilingPresent']
    assert a['collisionSlots']==[49]
    assert b['topSurfaceCount']==6 and b['used']==b['collisionSlots'][0]==64
    assert b['floorOwner']==b['platform']==61 and b['floorY']==1818.9613037109375
    assert v['samples'][-1]['movement']==[365.5927734375,5500,-1096.8026123046875]
    assert all(not t['topCapture'] for n,t in trials.items()if n not in ('ordinary-box','vpu-box'))
    assert trials['vpu-speed--262144']['samples'][0]['forwardVelocity']==-262142.90625
    assert trials['vpu-speed-262144']['samples'][0]['forwardVelocity']==10
    horizontal,vertical=p['crawlTrials']
    assert next(i+1 for i,s in enumerate(horizontal['samples'])if s['action']==0x04008448)==8
    assert all(s['action']!=0x04008448 for s in vertical['samples'])
    for t in p['releaseTrials']:
        assert t['heldPreparationResult']['actor']['oHeldState']==1
        assert t['initial']['mario']==[-5883,1024,764]
        for pad in t['controls']:assert not pad['buttons']&0x8000
        if t['kind']=='drop-valid':assert t['samples'][0]['actor']['oPosY']==1024
        if t['kind']=='throw-valid':
            j=t['joinedSuppliedCrawler'];assert len(j['waiting'])==7
            assert j['samples'][0]['movement']==[-1882,768,-939]
            assert j['samples'][0]['display']==[-1882,67277,-939]
            assert j['samples'][0]['collisionSlots']==[t['slot']]
            assert j['samples'][1]['platform']==61
            assert j['samples'][-1]['area']==2
            assert j['samples'][-1]['movement']==[365.5927734375,5500,-1096.8026123046875]
            assert all(not e['path'].startswith('gObjectPool') for e in j['marioOnlyEdits'])
            for pad,row in zip(j['controls'],j['samples']):
                assert not pad['buttons']&0x8000 and not row['input']&0x82
    return True


def main():
    a=argparse.ArgumentParser(description=__doc__);a.add_argument('receipt',type=Path)
    a.add_argument('--replay',type=Path);args=a.parse_args()
    r=json.loads(args.receipt.read_text());check(r)
    mutations=[]
    for key in ('topSurfaceCount','floorY','action'):
        q=copy.deepcopy(r);q['handoff']['trials'][2]['samples'][0][key]=-1;mutations.append(q)
    q=copy.deepcopy(r);q['handoff']['trials'][2]['controls'][0]['buttons']|=0x8000;mutations.append(q)
    q=copy.deepcopy(r);q['prerequisites']['releaseTrials'][0]['joinedSuppliedCrawler']['marioOnlyEdits'][0]['path']='gObjectPool[49].oPosY';mutations.append(q)
    for q in mutations:
        try:check(q)
        except AssertionError:pass
        else:raise AssertionError('corrupted evidence accepted')
    if args.replay:
        assert json.loads(json.dumps(handoff_run(args.replay)))==r['handoff']
        assert json.loads(json.dumps(prerequisite_run(args.replay)))==r['prerequisites']
    print(json.dumps(dict(valid=True,handoffTrials=21,positionOnlyCrawlTrials=2,
                         releaseTrials=6,joinedSuppliedCrawlers=2,
                         rejectedCorruptions=len(mutations),freshReplay=bool(args.replay))))


if __name__=='__main__':main()
