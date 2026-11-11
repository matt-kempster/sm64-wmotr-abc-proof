"""Bounded position-only roof-runway probes of the dive-pickup exception.

The initial Mario M/C/D and box49 XYZ are supplied; actions, velocities,
held references and caches are untouched. Subsequent writes are controller
inputs only. A real dive pickup, not an injected held state, must establish
the exceptional hands-free action. This is a local component search.
"""
import argparse
from collections import Counter
import hashlib
from itertools import product
import json
from pathlib import Path
import sys

sys.path.insert(0,str(Path(__file__).resolve().parent))
from ink_box_crawl_predecessors import snap
from ink_crawl_predecessors import advance,pose,steer,write
from ink_floorless_warp import NEUTRAL,reach_after_pillars

PHASES=[0,24,48,80]
SEEDS=[[-2559,1280,-1535],[-2509,1280,-1485]]


def setup(g,axis,distance,seed):
    edits=[];pose(g,seed,edits);box=list(seed);box[axis]+=distance
    for a,v in zip('XYZ',box):write(g,'gObjectPool[49].oPos'+a,v,edits)
    return edits


def run(capture):
    g,o=reach_after_pillars(capture);states={};contexts={}
    for _ in range(95):
        t=g.read('gObjectPool[61].oTimer')
        if g.read('gObjectPool[61].oAction')==1 and t in PHASES:
            states[t]=g.save_state();contexts[t]=snap(g,o)
        advance(g,NEUTRAL)
    assert set(states)==set(PHASES)
    names=g.mario_action_names();const=lambda name:g.constant('ACT_'+name)
    dive_pick=const('DIVE_PICKING_UP');crawl=const('CRAWLING')
    handsfree_actions={const(x)for x in ['FREEFALL','BEGIN_SLIDING','BUTT_SLIDE','STOMACH_SLIDE','FREEFALL_LAND','BUTT_SLIDE_AIR']}
    trials=[];selected={}
    for phase,seed in product(PHASES,SEEDS):
        for axis in [0,2]:
            for distance in [500,750,950]:
                for btime in [20,32,44]:
                    for zmode in ['after-B','after-pickup15']:
                        g.load_state(states[phase]);assert snap(g,o)==contexts[phase]
                        edits=setup(g,axis,distance,seed);counts=Counter()
                        controls=[];samples=[];events=[];first_held=None;first_handsfree=None
                        dive_pick_entries=0;has_dive=False;max_crawl=None;max_held_y=None
                        prior_key=None;phase130=None
                        for k in range(150):
                            before=snap(g,o)
                            if before['timer']==contexts[0]['timer']+130:phase130=before
                            if first_held is None and before['held']==49:first_held=k
                            target=[seed[0],seed[2]];target[0 if axis==0 else 1]+=1500
                            if first_held is not None:target=[-1950,-939]
                            pad=steer(g,target,127 if first_held is None else 64)
                            pad['buttons']=0x4000 if k==btime else 0
                            if ((zmode=='after-B' and k>btime) or
                                    (zmode=='after-pickup15' and first_held is not None and k>=first_held+15)):
                                pad['buttons']|=0x2000
                            controls.append(pad);advance(g,pad);r=snap(g,o);samples.append(r)
                            acts=[e['action']for e in g.frame_log()if e['type']=='FLT_EXECUTE_ACTION']
                            dive_pick_entries+=dive_pick in acts
                            has_dive|=const('DIVE')in acts
                            if (first_handsfree is None and dive_pick in acts and r['held']==49
                                    and r['action']in handsfree_actions):
                                first_handsfree=dict(update=k+1,actionEntries=[names.get(a,hex(a))for a in acts],before=before,after=r)
                            if r['action']==crawl:max_crawl=r['movement'][1]if max_crawl is None else max(max_crawl,r['movement'][1])
                            if r['held']==49:max_held_y=r['movement'][1]if max_held_y is None else max(max_held_y,r['movement'][1])
                            counts[names.get(r['action'],hex(r['action']))]+=1
                            key=(r['action'],r['actionArg'],r['held'],r['boxActive'])
                            if key!=prior_key:
                                events.append(dict(update=k+1,actionName=names.get(r['action']),actionEntries=[names.get(a,hex(a))for a in acts],sample=r));prior_key=key
                            if r['area']!=1 or g.read('gMarioState.area').is_null()or g.read('gMarioState.area.camera').is_null():break
                        row=dict(phase=phase,seed=seed,axis=axis,boxDistance=distance,bPressFrame=btime,zMode=zmode,
                                 updates=len(controls),initialEdits=edits,hasDive=has_dive,
                                 firstHeldAfterUpdates=first_held,divePickingUpExecutionUpdates=dive_pick_entries,
                                 firstHandsfreeExit=first_handsfree,maxHeldY=max_held_y,maxCrawlY=max_crawl,
                                 actionCounts=dict(counts),phase130=phase130,final=samples[-1],events=events)
                        trials.append(row);w=dict(summary=row,controls=controls,samples=samples)
                        ranks={'handsfree-exit':(-1 if first_handsfree is None else first_handsfree['after']['movement'][1]),
                               'crawl-after-pickup':(-1 if first_held is None or max_crawl is None else max_crawl),
                               'dive-pickup':dive_pick_entries}
                        for label,rank in ranks.items():
                            if label not in selected or rank>selected[label]['rank']:selected[label]=dict(rank=rank,witness=w)
    witnesses=[]
    for label,entry in selected.items():
        if entry['rank']<0 or (label=='dive-pickup'and entry['rank']==0):continue
        w=entry['witness'];r=w['summary'];fresh,obs=reach_after_pillars(capture)
        while not(fresh.read('gObjectPool[61].oAction')==1 and fresh.read('gObjectPool[61].oTimer')==r['phase']):advance(fresh,NEUTRAL)
        assert snap(fresh,obs)==contexts[r['phase']]
        edits=setup(fresh,r['axis'],r['boxDistance'],r['seed']);assert edits==r['initialEdits']
        for pad,expected in zip(w['controls'],w['samples']):advance(fresh,pad);assert snap(fresh,obs)==expected
        witnesses.append(dict(label=label,**w,freshBootValidation=dict(passed=True,continuousUpdates=len(w['controls']),comparedSnapshots=len(w['samples']),initialEdits=edits,intermediateEdits=0)))
    focused=focused_dive_controls(capture)
    return dict(schema=1,scope=__doc__,baselineSha256=hashlib.sha256(capture.read_bytes()).hexdigest(),
                runtimeSha256=hashlib.sha256(Path('build/wafel-pilot/sm64_jp.dll').read_bytes()).hexdigest(),
                scriptSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                snapshotHelperSha256=hashlib.sha256(Path(__file__).with_name('ink_box_crawl_predecessors.py').read_bytes()).hexdigest(),
                contexts=contexts,seeds=SEEDS,trials=trials,witnesses=witnesses,focusedDive=focused,
                summary=dict(trials=len(trials),updates=sum(t['updates']for t in trials),
                             diveTrials=sum(t['hasDive']for t in trials),pickupTrials=sum(t['firstHeldAfterUpdates']is not None for t in trials),
                             divePickingUpTrials=sum(t['divePickingUpExecutionUpdates']>0 for t in trials),
                             handsfreeExitTrials=sum(t['firstHandsfreeExit']is not None for t in trials),
                             crawlAfterPickupTrials=sum(t['firstHeldAfterUpdates']is not None and t['maxCrawlY']is not None for t in trials),
                             highCrawlTrials=sum(t['maxCrawlY']is not None and t['maxCrawlY']>=1741 for t in trials)))


def prepare_dive(capture):
    g,o=reach_after_pillars(capture)
    while not(g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==0):advance(g,NEUTRAL)
    start=snap(g,o);target=[start['movement'][0],start['movement'][2]+1500]
    controls=[];samples=[]
    for k in range(6):
        pad=steer(g,target,127);pad['buttons']=0x4000 if k==5 else 0
        controls.append(pad);advance(g,pad);samples.append(snap(g,o))
    assert g.read('gMarioState.action')==g.constant('ACT_DIVE')
    assert o.slot(g.read('gMarioState.heldObj'))==-1
    return g,o,dict(start=start,controls=controls,samples=samples,nonControllerEdits=[])


def focused_setup(g,height,distance,box_y_offset):
    edits=[];pose(g,[-2559,height,-1535],edits)
    for axis,value in zip('XYZ',[-2559,height+box_y_offset,-1535+distance]):write(g,'gObjectPool[49].oPos'+axis,value,edits)
    return edits


def focused_dive_controls(capture):
    g,o,runup=prepare_dive(capture);state=g.save_state();names=g.mario_action_names();trials=[]
    for height,distance,offset in product([1400,1600,1741],[70,110,150],[0,-60]):
        g.load_state(state);assert snap(g,o)==runup['samples'][-1]
        edits=focused_setup(g,height,distance,offset);controls=[];samples=[];entries=[]
        first_handsfree=None;events=[];last=None
        for k in range(140):
            pad=steer(g,[-2047,-1023],64);pad['buttons']=0x2000
            controls.append(pad);advance(g,pad);r=snap(g,o);samples.append(r)
            acts=[names.get(e['action'])for e in g.frame_log()if e['type']=='FLT_EXECUTE_ACTION'];entries.append(acts)
            if first_handsfree is None and 'ACT_DIVE_PICKING_UP'in acts and r['held']==49 and r['action']==g.constant('ACT_BUTT_SLIDE'):
                first_handsfree=dict(update=k+1,sample=r,actionEntries=acts)
            key=(r['action'],r['held'],r['boxActive'])
            if key!=last:events.append(dict(update=k+1,actionName=names.get(r['action']),sample=r,actionEntries=acts));last=key
            if r['area']!=1 or g.read('gMarioState.area.camera').is_null():break
        assert first_handsfree is not None
        assert not any('ACT_CRAZY_BOX_BOUNCE'in row for row in entries)
        trials.append(dict(height=height,boxDistance=distance,boxYOffset=offset,
                           initialEdits=edits,controls=controls,samples=samples,events=events,
                           firstHandsfreeExit=first_handsfree,
                           heldUpdates=sum(r['held']==49 for r in samples),
                           crawlUpdates=sum(r['action']==g.constant('ACT_CRAWLING')for r in samples),
                           final=samples[-1],phase130=next((r for r in samples if r['timer']==runup['start']['timer']+130),None)))
    validations=[]
    for height in [1400,1741]:
        trial=next(t for t in trials if t['height']==height and t['boxDistance']==70 and t['boxYOffset']==0)
        fresh,obs,fresh_runup=prepare_dive(capture);assert fresh_runup==runup
        edits=focused_setup(fresh,height,70,0);assert edits==trial['initialEdits']
        for pad,expected in zip(trial['controls'],trial['samples']):advance(fresh,pad);assert snap(fresh,obs)==expected
        validations.append(dict(height=height,boxDistance=70,boxYOffset=0,passed=True,
                                preCutControllerUpdates=6,postCutControllerUpdates=len(trial['controls']),
                                comparedSnapshots=6+len(trial['samples']),setupEdits=edits,postCutNonControllerEdits=0))
    return dict(runup=runup,trials=trials,freshBootValidations=validations,
                scope='Controller-produced DIVE, followed by one supplied high-position/box-position cut; no action or held-pointer writes',
                summary=dict(trials=len(trials),postCutUpdates=sum(len(t['controls'])for t in trials),
                             handsfreeExits=len(trials),crawlUpdates=sum(t['crawlUpdates']for t in trials),
                             crazyBoxBounceUpdates=0,minimumHeldUpdates=min(t['heldUpdates']for t in trials),
                             maximumHeldUpdates=max(t['heldUpdates']for t in trials)))


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('output',type=Path);a=p.parse_args();r=run(a.capture)
    with a.output.open('x',encoding='utf-8')as f:json.dump(r,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(dict(runway=r['summary'],focusedDive=r['focusedDive']['summary']),indent=2))


if __name__=='__main__':main()
