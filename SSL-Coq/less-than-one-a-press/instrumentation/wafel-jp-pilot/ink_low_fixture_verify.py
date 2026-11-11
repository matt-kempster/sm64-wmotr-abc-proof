"""Recheck recorded producer facts and reject altered receipt bookkeeping.

This validates saved observations and provenance, not game semantics. The
producer scripts separately replay selected complete native histories.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
from ink_low_fixture_producers import recipes, clear_box


def check(main,roof):
    here=Path(__file__).resolve().parent
    assert main['scriptSha256']==hashlib.sha256((here/'ink_low_fixture_producers.py').read_bytes()).hexdigest()
    for name,value in roof['sourceHashes'].items():
        assert value==hashlib.sha256((here/name).read_bytes()).hexdigest()
    assert main['captureSha256']==roof['captureSha256']
    assert [r['recipe'] for r in main['matrix']]==list(recipes())
    allowed={'gMarioState.pos','gMarioObject.header.gfx.pos',
             'gMarioObject.oPosX','gMarioObject.oPosY','gMarioObject.oPosZ',
             'gMarioState.action','gMarioState.actionState','gMarioState.actionTimer',
             'gMarioState.forwardVel','gMarioState.vel','gMarioState.faceAngle',
             'gMarioObject.hitboxHeight','gMarioState.quicksandDepth'}
    allowed|={'gObjectPool[%d].%s'%(i,f) for i in (39,49) for f in
              ('oPosX','oPosY','oPosZ','oForwardVel','oVelX','oVelY','oVelZ')}
    for r in main['matrix']:
        a=r['initial'];after=r['after'];n=r['next']
        assert a['movement']==a['collision']==a['display']
        assert all(e['path'] in allowed for e in r['edits'])
        assert r['intermediateEdits']==0
        assert r['gap']==after['display'][1]-after['movement'][1]
        assert r['createdPositiveGap']==(r['gap']>0)
        clear=clear_box(a['movement'],a['hitbox'],r['capBefore'])
        clear &= all(clear_box(e['pos'],a['hitbox'],r['capPrepared']) for e in
                     r['firstUpdateEvents'] if e['type']=='FLT_EXECUTE_ACTION')
        clear &= clear_box(after['movement'],after['hitbox'],r['capPrepared'])
        assert r['initialAndProducerBodyClear']==clear
        assert r['capturedTop']==(n['platform']==61 and n['floorOwner']==61 and n['used']==64)
    s=main['summary'];rows=main['matrix'];clean=main['clean']
    assert s['matrixTrials']==len(rows)==75
    assert s['matrixUpdates']==sum(r['updates'] for r in rows)
    assert s['outsideCapPositiveGaps']==sum(r['initialAndProducerBodyClear'] and r['gap']>0 for r in rows)
    assert s['outsideCapUsefulCaptures']==sum(r['initialAndProducerBodyClear'] and r['capturedTop'] for r in rows)
    assert len(clean)==396 and len({(r['phase'],r['policy']) for r in clean})==396
    assert s['cleanUpdates']==sum(r['updates'] for r in clean)
    assert all(r['initialEdits']==r['intermediateEdits']==r['AInputs']==0 for r in clean)
    assert s['maxCleanDisplayGap']==max(r['maxPositiveDisplayGap'] for r in clean)
    assert s['cleanTopCaptures']==sum(r['capturedTop'] for r in clean)
    keys=[(c['kind'],c['index']) for c in main['freshChecks']]
    assert len(keys)==len(set(keys))==s['freshReplayChecks']
    assert all(c['matched'] for c in main['freshChecks'])
    assert s['freshReplayUpdates']==sum(c['updates'] for c in main['freshChecks'])
    specific=[r for r in rows if r['recipe']==dict(phase=130,target='original-west',actor='box',
              height=1400,action='ACT_CRAWLING',depth=0.,policy=0)]
    assert len(specific)==1;r=specific[0]
    assert r['after']['movement']==r['after']['collision']==[-2200.,768.,-1024.]
    assert r['after']['display']==[-2200.,1400.,-1024.] and r['initialAndProducerBodyClear']
    assert r['next']['floorY']==1280 and r['next']['platform']==-1
    assert all(r['after']['depth']==0 and r['gap']==632 for r in rows if r['recipe']['depth'])
    rs=roof['summary'];rr=roof['rows']
    assert len(rr)==352 and len({(tuple(r['seed']),r['policy']) for r in rr})==352
    assert rs['updates']==sum(r['updates'] for r in rr)
    assert rs['maxPositiveDisplayGap']==max(r['maxPositiveDisplayGap'] for r in rr)
    assert rs['crawlingTrials']==sum(r['maxCrawlY'] is not None for r in rr)
    assert rs['maxCrawlY']==max(r['maxCrawlY'] for r in rr if r['maxCrawlY'] is not None)
    assert all(r['intermediateEdits']==r['AInputs']==0 for r in rr)
    return True


def mutation_checks(main,roof):
    changes=[lambda m,r:m['matrix'][0]['initial']['display'].__setitem__(1,999.),
             lambda m,r:m['matrix'][0]['edits'].append(dict(path='gMarioState.floorHeight',before=1024.,after=768.)),
             lambda m,r:m['matrix'][0].__setitem__('gap',100.),
             lambda m,r:m['matrix'][0].__setitem__('initialAndProducerBodyClear',not m['matrix'][0]['initialAndProducerBodyClear']),
             lambda m,r:m['matrix'][0].__setitem__('capturedTop',not m['matrix'][0]['capturedTop']),
             lambda m,r:m['freshChecks'].append(copy.deepcopy(m['freshChecks'][0])),
             lambda m,r:m['clean'][0].__setitem__('AInputs',1),
             lambda m,r:r['rows'][0].__setitem__('maxPositiveDisplayGap',900.)]
    for change in changes:
        m,r=copy.deepcopy(main),copy.deepcopy(roof);change(m,r)
        try:check(m,r)
        except AssertionError:continue
        raise AssertionError('An altered receipt was accepted')
    return len(changes)


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('producer',type=Path);p.add_argument('roof',type=Path);a=p.parse_args()
    m=json.loads(a.producer.read_text());r=json.loads(a.roof.read_text())
    check(m,r);n=mutation_checks(m,r)
    print(json.dumps(dict(status='passed',producerTrials=len(m['matrix']),
                         controllerSuffixes=len(m['clean']),roofTrials=len(r['rows']),
                         mutationRejections=n)))


if __name__=='__main__':main()
