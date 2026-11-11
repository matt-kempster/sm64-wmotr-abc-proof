"""Observe selected legacy high-display captures through first Area 2.

These trials SUPPLY the old position disagreement (displayY2300). They do not
create a below-cap gap. Per-update object/pointer observations are not hooks
at freeing, allocation or the first platform-apply call.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
from ink_below_cap_phase_search import prepare, read, digest
from ink_low_fixture_producers import advance,events
from ink_floorless_warp import position,NEUTRAL
from ink_near_warp import PHASE_PROBES

PHASES=[0,60,100,128,129,130,131]


def names(g):
    root=Path(__file__).resolve().parents[2]
    header=root.parents[2]/'reference-sm64-decomp/include/behavior_data.h'
    result=[]
    for name in re.findall(r'extern const BehaviorScript (\w+)\[\]',header.read_text()):
        try:result.append((g.address(name),name))
        except Exception:pass
    return result


def snap(g,o,bnames):
    r=read(g,o);p='gObjectPool[61].';beh=g.read(p+'behavior')
    name=next((name for ptr,name in bnames if ptr==beh),'unresolved-or-null')
    r.update(globalTimer=g.read('gGlobalTimer'),actionArg=g.read('gMarioState.actionArg'),
             actionState=g.read('gMarioState.actionState'),delayedWarp=g.read('sDelayedWarpOp'),
             warpCountdown=g.read('sDelayedWarpTimer'),
             topSlot=dict(active=g.read(p+'activeFlags'),behavior=name,
                          originalBehavior=beh==g.address('bhvPyramidTop'),
                          action=g.read(p+'oAction'),timer=g.read(p+'oTimer'),
                          pos=[g.read(p+'oPos'+a) for a in 'XYZ'],
                          velocity=[g.read(p+'oVel'+a) for a in 'XYZ'],
                          angularVelocity=[g.read(p+'oAngleVel'+a) for a in ('Pitch','Yaw','Roll')]))
    return r


def case(g,o,state,phase,low,bnames):
    g.load_state(state);high=[low[0],2300.,low[2]];position(g,low,low,high)
    initial=snap(g,o,bnames);samples=[];logs=[]
    for _ in range(32):
        advance(g,NEUTRAL);r=snap(g,o,bnames);samples.append(r);logs.append(events(g))
        if r['area']==2 or r['area']!=1 or r['level']!=8:break
    f=samples[0]
    captured=(f['action']==0x1300 and f['actionArg']==0x40001 and f['used']==64 and
              f['floorOwner']==61 and f['platform']==61)
    arrival=next((r for r in samples if r['area']==2 and r['level']==8),None)
    def first(test):
        return next((dict(update=i+1,sample=r) for i,r in enumerate(samples) if i>0 and test(r)),None)
    outside=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717)
    return dict(phase=phase,low=list(low),suppliedDisplay=high,initial=initial,capturedTop=captured,
                firstFloorOwnerLoss=first(lambda r:r['floorOwner']!=61) if captured else None,
                firstPlatformLoss=first(lambda r:r['platform']!=61) if captured else None,
                firstInactiveSlot=first(lambda r:r['topSlot']['active']==0),
                firstBehaviorReplacement=first(lambda r:not r['topSlot']['originalBehavior']),
                firstArea2=arrival,outsideElevator=outside,samples=samples,events=logs,
                historyDigest=digest([initial,samples,logs]),updates=len(samples),
                initialEdits='Nine position words only; M/C low, D sameXZ at2300',intermediateEdits=0,AInputs=0)


def run(capture):
    g,o,states,_=prepare(capture);bnames=names(g)
    rows=[case(g,o,states[p],p,low,bnames) for p in PHASES for low in PHASE_PROBES]
    fresh,fo,fs,_=prepare(capture);fn=names(fresh);checks=[]
    for p in PHASES:
        i=next((i for i,r in enumerate(rows) if r['phase']==p and r['capturedTop']),None)
        if i is None:continue
        r=rows[i];repeat=case(fresh,fo,fs[p],p,r['low'],fn);assert repeat==r
        checks.append(dict(index=i,phase=p,updates=r['updates'],matched=True))
    summary=dict(trials=len(rows),updates=sum(r['updates'] for r in rows),
                 initialCaptures=sum(r['capturedTop'] for r in rows),
                 capturedOutsideArrivals=sum(r['capturedTop'] and r['outsideElevator'] for r in rows),
                 freshReplayCases=len(checks),freshReplayUpdates=sum(r['updates'] for r in checks))
    return dict(schema=1,scope='Separate supplied-gap legacy capture/lifetime diagnostics; not below-cap gap creation',
                summary=summary,phases=PHASES,lowPoses=PHASE_PROBES,rows=rows,freshChecks=checks,
                observationLimit='After-update snapshots; cannot order same-update freeing, allocation and apply or infer free-list counts',
                sourceSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                captureSha256=hashlib.sha256(capture.read_bytes()).hexdigest())


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('output',type=Path)
    a=p.parse_args();r=run(a.capture)
    with a.output.open('x',encoding='utf8') as f:json.dump(r,f,indent=2);f.write('\n')
    print(json.dumps(r['summary'],indent=2))
    for p in PHASES:
        q=[r for r in r['rows'] if r['phase']==p]
        print(json.dumps(dict(phase=p,captures=sum(t['capturedTop'] for t in q),outside=sum(t['outsideElevator'] for t in q),
                             first=[dict(low=t['low'],ownerLoss=None if t['firstFloorOwnerLoss'] is None else t['firstFloorOwnerLoss']['update'],
                                platformLoss=None if t['firstPlatformLoss'] is None else t['firstPlatformLoss']['update'],
                                behavior=None if t['firstBehaviorReplacement'] is None else t['firstBehaviorReplacement']['sample']['topSlot']['behavior'])
                                for t in q if t['capturedTop']])))


if __name__=='__main__':main()
