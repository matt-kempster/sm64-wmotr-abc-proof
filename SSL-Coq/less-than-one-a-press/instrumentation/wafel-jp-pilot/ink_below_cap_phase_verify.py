"""Validate bounded phase-search receipts; --raw rechecks every saved row.

Compact-only checks cover geometry, controls, selected replays and lifecycle
snapshots. They cannot reconstruct the aggregate 51,200-row counts without
the hash-pinned local raw report. This is not a gameplay or Coq proof checker.
"""
import argparse
import copy
import hashlib
import json
import math
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
from ink_below_cap_phase_search import recipe_stream,footprint_checks,top_floor,digest
from ink_low_fixture_producers import clear_box
from ink_crawl_predecessors import f32


def check(compact,life,raw=None):
    here=Path(__file__).resolve().parent
    assert compact['sourceSha256']==hashlib.sha256((here/'ink_below_cap_phase_search.py').read_bytes()).hexdigest()
    assert life['sourceSha256']==hashlib.sha256((here/'ink_below_cap_capture_lifetime.py').read_bytes()).hexdigest()
    assert compact['captureSha256']==life['captureSha256']
    geo=compact['geometry'];assert len(geo)==152
    for i,g in enumerate(geo):
        assert g['index']==i and len(g['faces'])==6
        vs=[v for s in g['faces'] for v in s['vertices']]
        assert g['bottom']==min(v[1] for v in vs)
        assert g['capBox']==dict(min=[min(v[k] for v in vs) for k in range(3)],
                                 max=[max(v[k] for v in vs) for k in range(3)])
    motion=dict(maxTwoUpdateDrop=max(geo[i]['bottom']-geo[i+2]['bottom'] for i in range(150)),
                maximumOneUpdateDrop=max(geo[i]['bottom']-geo[i+1]['bottom'] for i in range(151)),
                minTwoUpdateFloorMinusBodyBuffer=min(geo[i+2]['bottom']-(min(geo[i]['bottom'],geo[i+1]['bottom'])-100+78) for i in range(150)))
    assert motion==compact['motion'] and compact['footprint']==footprint_checks(geo)
    allowed={'gMarioState.pos','gMarioObject.header.gfx.pos','gMarioObject.oPosX','gMarioObject.oPosY','gMarioObject.oPosZ',
             'gMarioState.action','gMarioState.actionState','gMarioState.actionTimer','gMarioState.forwardVel','gMarioState.vel',
             'gMarioState.faceAngle','gMarioObject.hitboxHeight'}
    allowed|={'gObjectPool[%d].%s'%(i,f) for i in (39,49) for f in
              ('oPosX','oPosY','oPosZ','oForwardVel','oVelX','oVelY','oVelZ')}
    witnesses=compact['controls']+[r['result'] for r in compact['retained']]
    for r in witnesses:
        initial=r['initial'];assert initial['movement']==initial['collision']==initial['display']
        assert all(e['path'] in allowed for e in r['writes'])
        assert r['gap']==r['after']['display'][1]-r['after']['movement'][1]
        clear=clear_box(initial['movement'],100.,r['capBefore'])
        clear &= all(clear_box(e['pos'],100.,r['capPrepared']) for e in r['firstEvents'] if e['type']=='FLT_EXECUTE_ACTION')
        clear &= clear_box(r['after']['movement'],r['after']['hitbox'],r['capPrepared'])
        assert r['bodyClear']==clear and r['historyDigest']==digest([r['samples'],r['events']])
    p,n=compact['controls']
    assert p['name']=='inside-973-positive' and p['gap']==973 and p['capturedTop'] and p['outsideElevator']
    assert p['next']['action']==0x1300 and not p['bodyClear']
    assert n['name']=='below-632-roof' and n['gap']==632 and n['bodyClear'] and n['next']['floor']==1280
    assert len(compact['freshChecks'])==compact['summary']['freshReplayCases']
    assert all(r['matched'] for r in compact['freshChecks'])
    assert sum(r['updates'] for r in compact['freshChecks'])==compact['summary']['freshReplayUpdates']
    assert len({(r['kind'],r.get('index',r.get('name'))) for r in compact['freshChecks']})==len(compact['freshChecks'])
    assert len(life['rows'])==42
    for r in life['rows']:
        samples=r['samples'];f=samples[0]
        strict=(f['action']==0x1300 and f['actionArg']==0x40001 and f['used']==64 and f['floorOwner']==61 and f['platform']==61)
        assert r['capturedTop']==strict and r['updates']==len(samples)
        assert r['historyDigest']==digest([r['initial'],samples,r['events']])
        assert r['intermediateEdits']==r['AInputs']==0
        for field,test in [('firstFloorOwnerLoss',lambda q:q['floorOwner']!=61),
                           ('firstPlatformLoss',lambda q:q['platform']!=61),
                           ('firstInactiveSlot',lambda q:q['topSlot']['active']==0),
                           ('firstBehaviorReplacement',lambda q:not q['topSlot']['originalBehavior'])]:
            got=next((dict(update=i+1,sample=q) for i,q in enumerate(samples) if i>0 and test(q)),None)
            assert r[field]==got
    assert life['summary']['initialCaptures']==sum(r['capturedTop'] for r in life['rows'])
    assert life['summary']['capturedOutsideArrivals']==sum(r['capturedTop'] and r['outsideElevator'] for r in life['rows'])
    if raw is not None:
        assert compact['rowsDigest']==digest(raw['rows'])
        rows=raw['rows'];assert [r['recipe'] for r in rows]==list(recipe_stream(geo))
        assert len(rows)==compact['summary']['trials']==51200
        assert raw['summary']==compact['summary'] and raw['phaseCounts']==compact['phaseCounts']
        assert sum(r['updates'] for r in rows)==compact['summary']['updates']
        for r in rows:
            a=r['after'];n=r['next'];p=r['recipe']['phase']
            assert r['gap']==a['display'][1]-a['movement'][1]
            assert r['capturedTop']==(n['used']==64 and n['floorOwner']==61 and n['platform']==61)
            assert r['topPlaneHeight']==top_floor(geo[p+2],a['display'][0],a['display'][2])
            h=r['topPlaneHeight']
            assert r['retryHeightShortfall']==(None if h is None else f32(h-78.)-int(a['display'][1]))
            near=math.hypot(a['movement'][0]+2048,a['movement'][2]+1024)<187
            assert r['nearWarp']==near
            assert r['relevantLowSplit']==(r['bodyClear'] and r['gap']>0 and a['movement'][1]<=818
                                           and near and a['movement']==a['collision'])
            assert r['validUseful']==(r['bodyClear'] and r['capturedTop'] and r['outsideElevator'])
            assert r['recipe']['height']+100<min(geo[p]['bottom'],geo[p+1]['bottom'])
        aggregate=dict(trials=len(rows),updates=sum(r['updates'] for r in rows),
            bodyClear=sum(r['bodyClear'] for r in rows),bodyScreenRejected=sum(not r['bodyClear'] for r in rows),
            positiveGaps=sum(r['gap']>0 for r in rows),relevantLowSplits=sum(r['relevantLowSplit'] for r in rows),
            rawTopCaptures=sum(r['capturedTop'] for r in rows),
            validTopCaptures=sum(r['bodyClear'] and r['capturedTop'] for r in rows),
            validUseful=sum(r['validUseful'] for r in rows),
            maxRelevantGap=max((r['gap'] for r in rows if r['relevantLowSplit']),default=None),
            minimumRetryShortfall=min((r['retryHeightShortfall'] for r in rows if r['relevantLowSplit']
                                      and r['retryHeightShortfall'] is not None),default=None),
            freshReplayCases=len(compact['freshChecks']),freshReplayUpdates=sum(r['updates'] for r in compact['freshChecks']))
        assert aggregate==compact['summary']
        for p in range(150):
            rs=[r for r in rows if r['recipe']['phase']==p]
            assert compact['phaseCounts'][str(p)]==dict(trials=len(rs),bodyClear=sum(r['bodyClear'] for r in rs),
                positiveGaps=sum(r['gap']>0 for r in rs),relevantLowSplits=sum(r['relevantLowSplit'] for r in rs),
                rawCaptures=sum(r['capturedTop'] for r in rs),useful=sum(r['validUseful'] for r in rs),maxGap=max(r['gap'] for r in rs))
    return True


def mutations(c,l):
    changes=[lambda c,l:c['geometry'][3].__setitem__('bottom',0),
             lambda c,l:c['motion'].__setitem__('maxTwoUpdateDrop',100),
             lambda c,l:c['controls'][1]['initial']['display'].__setitem__(1,1741.),
             lambda c,l:c['controls'][1]['writes'].append(dict(path='gMarioState.floorHeight',before=1024,after=768)),
             lambda c,l:c['controls'][1].__setitem__('bodyClear',False),
             lambda c,l:c['freshChecks'].append(copy.deepcopy(c['freshChecks'][0])),
             lambda c,l:l['rows'][0]['samples'][0].__setitem__('actionArg',0),
             lambda c,l:l['rows'][0].__setitem__('firstPlatformLoss',None)]
    for change in changes:
        cc,ll=copy.deepcopy(c),copy.deepcopy(l);change(cc,ll)
        try:check(cc,ll)
        except AssertionError:continue
        raise AssertionError('Altered receipt accepted')
    return len(changes)


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('receipt',type=Path);p.add_argument('lifetime',type=Path)
    p.add_argument('--raw',type=Path);a=p.parse_args();c=json.loads(a.receipt.read_text());l=json.loads(a.lifetime.read_text())
    raw=None
    if a.raw:
        assert hashlib.sha256(a.raw.read_bytes()).hexdigest()==c['rawSha256'];raw=json.loads(a.raw.read_text())
    check(c,l,raw);n=mutations(c,l)
    print(json.dumps(dict(status='passed',aggregateRowsRechecked=0 if raw is None else len(raw['rows']),
                         geometryMeshes=len(c['geometry']),lifetimeTrials=len(l['rows']),mutationRejections=n)))


if __name__=='__main__':main()
