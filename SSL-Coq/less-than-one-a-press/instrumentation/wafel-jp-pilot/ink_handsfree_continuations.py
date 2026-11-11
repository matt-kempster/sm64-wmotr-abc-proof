"""Finite input continuations from actual hands-free jumping-box pickups.

The eastern-box family is controller-only after the accepted level-select
initialization. The roof family retains exactly the earlier study's one
Mario/box XYZ cut. No action, held reference, velocity or cache is patched.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import sys

sys.path.insert(0,str(Path(__file__).resolve().parent))
from replay import create_game,Observer,load_capture
from ink_box_delivery import accepted_prefix
from ink_box_handsfree import prepare_dive,focused_setup,advance,snap as old_roof_snapshot
from ink_clean_handsfree import snapshot as clean_snapshot
from ink_timer130_crawl import snapshot

CRAWL=0x04008448
STOP_NAMES={'ACT_BUTT_SLIDE_STOP','ACT_STOMACH_SLIDE_STOP','ACT_IDLE',
 'ACT_START_CROUCHING','ACT_STOP_CROUCHING','ACT_CROUCH_SLIDE','ACT_DECELERATING','ACT_BRAKING'}
CRAWL_NAMES={'ACT_CROUCHING','ACT_START_CRAWLING','ACT_CRAWLING'}


def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def record(g,o,slot,n):
    r=snapshot(g,o);q='gObjectPool[%d].'%slot
    r.update(n=n,held=o.slot(g.read('gMarioState.heldObj')),
        holp=g.read('gMarioState.marioBodyState.heldObjLastPosition'),
        floorNormal=g.read('gMarioState.floor?.normal'),
        topIsPyramid=g.read('gObjectPool[61].behavior')==g.address('bhvPyramidTop'),
        pillars=g.read('gObjectPool[61].oPyramidTopPillarsTouched'),
        actor=dict(slot=slot,isJumpingBox=g.read(q+'behavior')==g.address('bhvJumpingBox'),
            **{f:g.read(q+f)for f in ('oPosX','oPosY','oPosZ','oHeldState','oAction',
             'oIntangibleTimer','oFloorHeight','oVelY','oForwardVel','oMoveFlags','activeFlags')}))
    return r


def direction(g,target,magnitude,buttons):
    x,_,z=g.read('gMarioState.pos')
    angle=math.atan2(target[0]-x,target[1]-z)-g.read('gMarioState.area.camera.yaw')*math.tau/65536
    return dict(buttons=buttons,stick=[round(magnitude*math.sin(angle)),round(-magnitude*math.cos(angle))])


def policies(clean):
    targets=([(1120,6500),(500,6500),(1500,6500),(1120,5800),(2000,5000),(1120,5500)]if clean else
             [(-2559,-1535),(-2500,-1450),(-2000,-1535),(-2000,-1024),(-1950,-939),(-1500,-1024)])
    return [dict(mode='target',target=t,magnitude=m,periodicB=b)for t in targets
             for m in (32,64,127)for b in ((False,True)if clean else(False,))]+[
        dict(mode=mode,target=None,magnitude=127,periodicB=b)for mode in ('brake','neutral')for b in(False,True)]


def control(g,r,policy,k,clean,names):
    name=names.get(r['action'],'')
    buttons=0x2000|(0x4000 if policy['periodicB']and k%12==0 else 0)
    stops=STOP_NAMES if clean else STOP_NAMES-{'ACT_STOMACH_SLIDE_STOP'}
    if name in stops:return dict(buttons=buttons,stick=[0,0])
    if name in CRAWL_NAMES:return direction(g,(1120,6500)if clean else(-1950,-939),32,buttons)
    if policy['mode']=='neutral':return dict(buttons=buttons,stick=[0,0])
    if policy['mode']=='brake':
        x,_,z=r['movement'];vx,_,vz=r['velocity']
        return direction(g,(x-100*vx,z-100*vz),127,buttons)
    return direction(g,policy['target'],policy['magnitude'],buttons)


def alive(r):return r['actor']['isJumpingBox']and bool(r['actor']['activeFlags'])


def summary(trial):
    rows=trial['samples'];slot=rows[0]['actor']['slot']
    drop=next((i for i,r in enumerate(rows)if r['held']!=slot),None)
    deleted=next((r for r in rows if not alive(r)),None)
    crawls=[r for r in rows if r['action']==CRAWL]
    free_crawls=[r for r in crawls if alive(r)and r['actor']['oHeldState']==0 and r['actor']['oIntangibleTimer']==0]
    release=None if drop is None else dict(before=rows[max(0,drop-1)],after=rows[drop])
    return dict(kind=trial['kind'],seedIndex=trial['seedIndex'],policy=trial['policy'],
        updates=len(trial['inputs']),inputSha256=hashlib.sha256(json.dumps(trial['inputs'],separators=(',',':')).encode()).hexdigest(),
        firstCrawl=None if not crawls else crawls[0],maxCrawlY=max((r['movement'][1]for r in crawls),default=None),
        freeActorCrawlSamples=len(free_crawls),release=release,firstDeletion=deleted,
        freeLifetimeUpdates=None if drop is None or deleted is None else deleted['n']-rows[drop]['n'],
        maxY=max(r['movement'][1]for r in rows),maxYAfterStart=max(r['movement'][1]for r in rows[1:]),
        phase130=next((r for r in rows if r['topIsPyramid']and r['topAction']==1 and r['topTimer']==130),None),
        final=rows[-1])


def reconstruct(capture,roof,clean,kind,index,roof_cache=None):
    if kind=='clean':
        g=create_game();o=Observer(g);accepted_prefix(g,o,load_capture(capture),350)
        source=clean['selected'][0];count=source['summary']['firstHandsfreeExit']['sample']['n']
        for n,(pad,expected)in enumerate(zip(source['inputs'][:count],source['samples'][:count])):
            advance(g,pad);assert clean_snapshot(g,o,n+1)==expected
        return g,o,dict(kind=kind,seedIndex=index,slot=47,initialEdits=[],
            acceptedPrefixInputs=350,acquisitionInputs=source['inputs'][:count],
            fullControllerPrefix=source['fullInputs'][:350+count])
    if roof_cache is None:
        g,o,runup=prepare_dive(capture)
    else:
        g,o,runup,base=roof_cache;g.load_state(base)
    source=roof['focusedDive']['trials'][index]
    edits=focused_setup(g,source['height'],source['boxDistance'],source['boxYOffset'])
    assert edits==source['initialEdits']
    count=source['firstHandsfreeExit']['update']
    for pad,expected in zip(source['controls'][:count],source['samples'][:count]):
        advance(g,pad);assert old_roof_snapshot(g,o)==expected
    return g,o,dict(kind=kind,seedIndex=index,slot=49,initialEdits=edits,
        runup=runup,afterCutAcquisitionInputs=source['controls'][:count],
        sourceParameters={k:source[k]for k in ('height','boxDistance','boxYOffset')})


def rollout(g,o,seed,state,policy):
    g.load_state(state);slot=seed['slot'];clean=seed['kind']=='clean';names=g.mario_action_names()
    inputs=[];samples=[]
    for k in range(220 if clean else 130):
        r=record(g,o,slot,k);samples.append(r)
        if r['area']!=1 or g.read('gMarioState.area.camera').is_null():break
        pad=control(g,r,policy,k,clean,names);inputs.append(pad);advance(g,pad)
    samples.append(record(g,o,slot,len(inputs)))
    return dict(kind=seed['kind'],seedIndex=seed['seedIndex'],policy=policy,inputs=inputs,samples=samples)


def beam(g,o,seed,state):
    g.load_state(state);start=record(g,o,49,0)
    frontier=[dict(state=state,inputs=[],samples=[start])];last=frontier[0]
    tested=0;stats=[];crawls=0
    for depth in range(1,111):
        candidates=[]
        for parent in frontier:
            g.load_state(parent['state']);camera=g.read('gMarioState.area.camera.yaw')*math.tau/65536
            menu=[dict(buttons=0x2000,stick=[0,0])]+[
                dict(buttons=0x2000,stick=[round(127*math.sin(yaw*math.tau/65536-camera)),
                                         round(-127*math.cos(yaw*math.tau/65536-camera))])for yaw in range(0,65536,8192)]
            for pad in menu:
                g.load_state(parent['state']);advance(g,pad);r=record(g,o,49,depth);tested+=1
                if(r['area']!=1 or r['movement'][1]<1150 or
                   math.hypot(r['movement'][0]+2048,r['movement'][2]+1024)>1100 or
                   g.read('gMarioState.area.camera').is_null()):continue
                candidates.append(dict(state=g.save_state(),inputs=parent['inputs']+[pad],samples=parent['samples']+[r]))
                crawls+=r['action']==CRAWL
        candidates.sort(key=lambda c:(c['samples'][-1]['action']==CRAWL,
            c['samples'][-1]['movement'][1]-0.2*abs(c['samples'][-1]['forwardVelocity'])
              -0.15*abs(c['samples'][-1]['movement'][2]+1535)),reverse=True)
        frontier=[];cells=set()
        for candidate in candidates:
            r=candidate['samples'][-1]
            cell=(r['action'],round(r['movement'][0]/15),round(r['movement'][2]/15),
                  round(r['forwardVelocity']/3),r['faceAngle'][1]//2048)
            if cell not in cells:frontier.append(candidate);cells.add(cell)
            if len(frontier)==12:break
        stats.append(dict(depth=depth,passing=len(candidates),retained=len(frontier),
                          highestY=max((c['samples'][-1]['movement'][1]for c in candidates),default=None)))
        if not frontier:break
        last=frontier[0]
    return dict(seedIndex=seed['seedIndex'],width=12,horizon=110,menuSize=9,
        pruning='Reject Y<1150, distance from pyramid center>1100, invalid area/camera; rank by crawl then Y minus speed/north-roof-distance penalties; coarse cell diversity',
        testedContinuations=tested,crawlCandidates=crawls,depths=stats,
        finalTrail=dict(kind='roof',seedIndex=seed['seedIndex'],policy=dict(mode='beam'),
                        inputs=last['inputs'],samples=last['samples']))


def run(capture,roof_path,clean_path):
    roof=json.loads(roof_path.read_text());clean=json.loads(clean_path.read_text())
    seeds=[];trials=[];beams=[];selected_candidates=[]
    roof_g,roof_o,roof_runup=prepare_dive(capture)
    roof_cache=(roof_g,roof_o,roof_runup,roof_g.save_state())
    for kind,index in [('roof',i)for i in range(18)]+[('clean',0)]:
        g,o,seed=reconstruct(capture,roof,clean,kind,index,roof_cache);state=g.save_state();seed['start']=record(g,o,seed['slot'],0);seeds.append(seed)
        local_trials=[]
        for policy in policies(kind=='clean'):
            t=rollout(g,o,seed,state,policy);local_trials.append(t)
            trials.append({**{k:t[k]for k in ('kind','seedIndex','policy','inputs')},'summary':summary(t)})
        if kind=='clean':
            earliest=min((t for t in local_trials if summary(t)['firstCrawl']is not None),
                         key=lambda t:summary(t)['firstCrawl']['timer'])
            longest=max(local_trials,key=lambda t:summary(t)['freeLifetimeUpdates']or -1)
            selected_candidates += [('clean-earliest-crawl',earliest),('clean-longest-free-actor',longest)]
        elif index in (0,6,12):
            result=beam(g,o,seed,state);beams.append(result)
            selected_candidates.append(('roof-beam-'+str(index),result['finalTrail']))
    selected=[]
    for label,t in selected_candidates:
        fresh,o,seed=reconstruct(capture,roof,clean,t['kind'],t['seedIndex'])
        for n,(pad,expected)in enumerate(zip(t['inputs'],t['samples'])):
            assert record(fresh,o,seed['slot'],n)==expected
            advance(fresh,pad)
        assert record(fresh,o,seed['slot'],len(t['inputs']))==t['samples'][-1]
        selected.append(dict(label=label,seed=seed,**t,summary=summary(t),
            freshReplay=dict(passed=True,comparedContinuationSnapshots=len(t['samples']),
                continuationInputs=len(t['inputs']),intermediateGameplayEdits=0)))
    return dict(schema=1,scope=__doc__,baselineSha256=sha(capture),runtimeSha256=sha('build/wafel-pilot/sm64_jp.dll'),
        scriptSha256=sha(__file__),sourceReports=[dict(path=str(p).replace('\\','/'),sha256=sha(p))for p in (roof_path,clean_path)],
        helperSha256={n:sha(Path(__file__).with_name(n))for n in ('ink_box_handsfree.py','ink_clean_handsfree.py','ink_box_delivery.py','ink_timer130_crawl.py')},
        seeds=seeds,trials=trials,beams=beams,selected=selected,
        summary=dict(roofPolicies=396,roofUpdates=sum(t['summary']['updates']for t in trials if t['kind']=='roof'),
            roofCrawlPolicies=sum(t['summary']['firstCrawl']is not None for t in trials if t['kind']=='roof'),
            cleanPolicies=40,cleanUpdates=sum(t['summary']['updates']for t in trials if t['kind']=='clean'),
            cleanCrawlPolicies=sum(t['summary']['firstCrawl']is not None for t in trials if t['kind']=='clean'),
            maximumCrawlY=max((t['summary']['maxCrawlY']for t in trials if t['summary']['maxCrawlY']is not None),default=None),
            freeActorCrawlSamples=sum(t['summary']['freeActorCrawlSamples']for t in trials),
            beamContinuations=sum(b['testedContinuations']for b in beams),beamCrawlCandidates=sum(b['crawlCandidates']for b in beams)))


def compact(raw,path):
    columns=['kind','seedIndex','policy','updates','inputSha256','maximumY','maximumCrawlY',
             'firstCrawlTimer','releaseTimer','releaseMarioXYZ','releaseActorXYZ',
             'firstDeletionTimer','freeLifetimeUpdates','freeActorCrawlSamples','phase130MarioXYZ','finalMarioXYZ']
    rows=[]
    for t in raw['trials']:
        s=t['summary'];drop=None if s['release']is None else s['release']['after']
        rows.append([s['kind'],s['seedIndex'],s['policy'],s['updates'],s['inputSha256'],s['maxY'],s['maxCrawlY'],
            None if s['firstCrawl']is None else s['firstCrawl']['timer'],None if drop is None else drop['timer'],
            None if drop is None else drop['movement'],None if drop is None else [drop['actor']['oPos'+a]for a in 'XYZ'],
            None if s['firstDeletion']is None else s['firstDeletion']['timer'],s['freeLifetimeUpdates'],s['freeActorCrawlSamples'],
            None if s['phase130']is None else s['phase130']['movement'],s['final']['movement']])
    selected=[]
    for witness in raw['selected']:
        samples=witness['samples'];indices={0,len(samples)-1};prior=None
        for i,r in enumerate(samples):
            key=(r['action'],r['held'],r['actor']['isJumpingBox'],r['actor']['activeFlags'])
            if key!=prior:indices.update((max(0,i-1),i))
            prior=key
        selected.append({**{k:v for k,v in witness.items()if k!='samples'},
                         'selectedSnapshots':[samples[i]for i in sorted(indices)],'allSnapshotCount':len(samples)})
    return {**{k:v for k,v in raw.items()if k not in ('trials','beams','selected')},
        'rawReportName':str(path).replace('\\','/'),'rawReportSha256':sha(path),
        'trialColumns':columns,'trialRows':rows,'selected':selected,
        'beams':[{k:v for k,v in b.items()if k!='finalTrail'}for b in raw['beams']]}


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('roof_source',type=Path)
    p.add_argument('clean_source',type=Path);p.add_argument('output',type=Path);p.add_argument('--receipt',type=Path,required=True);a=p.parse_args()
    raw=run(a.capture,a.roof_source,a.clean_source)
    with a.output.open('x',encoding='utf-8')as f:json.dump(raw,f,indent=2,allow_nan=False);f.write('\n')
    with a.receipt.open('x',encoding='utf-8')as f:json.dump(compact(raw,a.output),f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(raw['summary'],indent=2))
