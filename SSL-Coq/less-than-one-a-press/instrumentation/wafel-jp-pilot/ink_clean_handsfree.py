"""Controller-only acquisition of hands-free holding from stock eastern box47.

The sole non-controller initialization is create_game's accepted pre-entry
level-select flag. All branches replay the accepted first350 input rows and
use only B/Z/stick afterward. No positions, actions, actor fields, held/cache
references, RNG or timer are supplied. This is not a complete Ink route.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import sys

sys.path.insert(0,str(Path(__file__).resolve().parent))
from replay import create_game,Observer,load_capture
from ink_box_delivery import accepted_prefix,advance,steer
from ink_floorless_warp import observe

PREFIX=350
SLOT=47
WAYPOINTS=[(1120,7100),(600,7100),(1600,7100),(1120,7300)]
RADII=[110,140,180,240,320]


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def snapshot(g,o,n):
    r=observe(g,o);q='gObjectPool[47].'
    top=g.read('gObjectPool[61].behavior')==g.address('bhvPyramidTop')
    r.update(n=n,held=o.slot(g.read('gMarioState.heldObj')),
             ridden=o.slot(g.read('gMarioState.riddenObj')),
             forward=g.read('gMarioState.forwardVel'),velocity=g.read('gMarioState.vel'),
             faceAngle=g.read('gMarioState.faceAngle'),input=g.read('gMarioState.input'),
             floorNormal=g.read('gMarioState.floor?.normal'),floorType=g.read('gMarioState.floor?.type'),
             boxBehavior=g.read(q+'behavior')==g.address('bhvJumpingBox'),
             boxPosition=[g.read(q+'oPos'+a)for a in 'XYZ'],boxHeld=g.read(q+'oHeldState'),
             boxActive=g.read(q+'activeFlags'),boxAction=g.read(q+'oAction'),
             boxIntangible=g.read(q+'oIntangibleTimer'),
             topBehavior=top,topActive=g.read('gObjectPool[61].activeFlags'),
             topAction=g.read('gObjectPool[61].oAction')if top else None,
             topTimer=g.read('gObjectPool[61].oTimer')if top else None,
             pillars=g.read('gObjectPool[61].oPyramidTopPillarsTouched')if top else None)
    return r


def summarize(t):
    rows=t['samples'];held=[r for r in rows if r['held']==SLOT]
    first=next((r for r in rows if r['held']==SLOT),None)
    released=next((r for r in rows if first is not None and r['n']>first['n'] and r['held']!=SLOT
                   and r['boxBehavior'] and r['boxActive'] and r['boxHeld']==0),None)
    deleted=next((r for r in rows if first is not None and r['n']>first['n']
                  and(not r['boxBehavior']or not r['boxActive'])),None)
    hf=t['firstHandsfreeExit']
    hfheld=[r for r in rows if hf is not None and r['n']>=hf['sample']['n'] and r['held']==SLOT]
    return dict(policy=t['policy'],updates=len(t['inputs']),pressedB=t['pressedB'],
                inputSha256=hashlib.sha256(json.dumps(t['inputs'],separators=(',',':')).encode()).hexdigest(),
                pickup=first,firstHandsfreeExit=hf,freeRelease=released,firstDeletion=deleted,
                heldUpdates=len(held),maximumHeldY=max((r['movement'][1]for r in held),default=None),
                maximumHandsfreeHeldY=max((r['movement'][1]for r in hfheld),default=None),
                crawlUpdates=sum(r['action']==0x04008448 for r in rows),
                maximumPillars=max((r['pillars']for r in rows if r['pillars']is not None),default=None),
                spinningTopSamples=sum(r['topBehavior']and r['topAction']==1 for r in rows),
                final=rows[-1])


def run(capture):
    rows=load_capture(capture);g=create_game();o=Observer(g);accepted_prefix(g,o,rows,PREFIX)
    initial=snapshot(g,o,0);state=g.save_state();names=g.mario_action_names();trials=[]
    target_actions={g.constant('ACT_STOMACH_SLIDE'),g.constant('ACT_BUTT_SLIDE'),g.constant('ACT_FREEFALL')}
    for waypoint in WAYPOINTS:
        for radius in RADII:
            g.load_state(state);assert snapshot(g,o,0)==initial
            waypoint_done=False;pressed=False;inputs=[];samples=[];events=[];handsfree=None;prior=None
            for k in range(260):
                p=g.read('gMarioState.pos');waypoint_done|=math.hypot(p[0]-waypoint[0],p[2]-waypoint[1])<60
                target=waypoint if not waypoint_done else ((1120,5800)if pressed else(1120,6480))
                distance=math.hypot(p[0]-1120,p[2]-6480)
                press=waypoint_done and not pressed and distance<radius and g.read('gMarioState.forwardVel')>=29
                if press:pressed=True
                pad=steer(g,target,0x4000 if press else 0x2000 if pressed else 0)
                inputs.append(pad);advance(g,pad);r=snapshot(g,o,k+1);samples.append(r)
                actions=[names.get(e['action'],hex(e['action']))for e in g.frame_log()if e['type']=='FLT_EXECUTE_ACTION']
                key=(r['action'],r['held'],r['boxBehavior'],r['boxActive'])
                if key!=prior:events.append(dict(n=k+1,actionEntries=actions,sample=r));prior=key
                if handsfree is None and 'ACT_DIVE_PICKING_UP'in actions and r['held']==SLOT and r['action']in target_actions:
                    handsfree=dict(actionEntries=actions,sample=r)
                if r['area']!=1 or g.read('gMarioState.area.camera').is_null():break
            trials.append(dict(policy=dict(waypoint=waypoint,triggerRadius=radius),inputs=inputs,samples=samples,
                               events=events,firstHandsfreeExit=handsfree,pressedB=pressed))
    selected=[]
    for waypoint,radius in [((1120,7100),110),((600,7100),110)]:
        t=next(t for t in trials if t['policy']==dict(waypoint=waypoint,triggerRadius=radius))
        fresh=create_game();fo=Observer(fresh);accepted_prefix(fresh,fo,rows,PREFIX)
        assert snapshot(fresh,fo,0)==initial
        for n,(pad,expected)in enumerate(zip(t['inputs'],t['samples'])):
            advance(fresh,pad);assert snapshot(fresh,fo,n+1)==expected
        full=[dict(buttons=r['buttons'],stick=r['stick'])for r in rows[:PREFIX]]+t['inputs']
        selected.append(dict(policy=t['policy'],summary=summarize(t),inputs=t['inputs'],
                             fullInputCount=len(full),fullInputSha256=hashlib.sha256(''.join(json.dumps(p,separators=(',',':'))+'\n'for p in full).encode()).hexdigest(),
                             fullInputHashEncoding='UTF-8 compact JSON objects, one per line, LF line endings',
                             fullInputs=full,events=t['events'],samples=t['samples'],
                             freshReplay=dict(passed=True,prefixInputCount=PREFIX,branchInputCount=len(t['inputs']),
                                              comparedBranchSnapshots=len(t['samples']),comparedInitialSnapshot=True,
                                              gameplaySetupWrites=[])))
    summaries=[summarize(t)for t in trials]
    return dict(schema=1,scope=__doc__,baselineSha256=sha(capture),runtimeSha256=sha('build/wafel-pilot/sm64_jp.dll'),
                scriptSha256=sha(__file__),prefixInputCount=PREFIX,prefixAFrames=sum(bool(r['buttons']&0x8000)for r in rows[:PREFIX]),
                initial=initial,gameplaySetupWrites=[],preEntrySetup='create_game sets gDebugLevelSelect=1 before level entry',
                policies=dict(waypoints=WAYPOINTS,triggerRadii=RADII,horizon=260),trials=trials,selected=selected,
                summary=dict(policies=len(trials),uniqueInputHistories=len(set(t['inputSha256']for t in summaries)),
                             updates=sum(len(t['inputs'])for t in trials),pickupPolicies=sum(t['pickup']is not None for t in summaries),
                             handsfreePolicies=sum(t['firstHandsfreeExit']is not None for t in summaries),
                             uniqueHandsfreeHistories=len(set(t['inputSha256']for t in summaries if t['firstHandsfreeExit']is not None)),
                             crawlUpdates=sum(t['crawlUpdates']for t in summaries),
                             maximumPillars=max(t['maximumPillars']for t in summaries),
                             spinningTopSamples=sum(t['spinningTopSamples']for t in summaries)))


def compact(raw,raw_path):
    r={k:v for k,v in raw.items()if k not in ['trials','selected']}
    r['rawReportName']=str(raw_path).replace('\\','/');r['rawReportSha256']=sha(raw_path)
    r['trials']=[summarize(t)for t in raw['trials']]
    r['selected']=[]
    for t in raw['selected']:
        v={k:x for k,x in t.items()if k!='samples'}
        chosen={r['timer']:r for r in [t['samples'][0],t['samples'][-1]]}
        for key in ['pickup','freeRelease','firstDeletion']:
            row=t['summary'][key]
            if row is not None:
                n=row['n'];chosen.update((s['timer'],s)for s in t['samples'][max(0,n-2):n+1])
        h=t['summary']['firstHandsfreeExit']['sample']['n'];chosen.update((s['timer'],s)for s in t['samples'][h-2:h+1])
        v['selectedSamples']=[chosen[k]for k in sorted(chosen)];r['selected'].append(v)
    return r


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('output',type=Path)
    p.add_argument('--receipt',type=Path,required=True);p.add_argument('--witness-inputs',type=Path)
    a=p.parse_args();r=run(a.capture)
    with a.output.open('x',encoding='utf-8')as f:json.dump(r,f,indent=2,allow_nan=False);f.write('\n')
    with a.receipt.open('x',encoding='utf-8')as f:json.dump(compact(r,a.output),f,indent=2,allow_nan=False);f.write('\n')
    if a.witness_inputs:
        with a.witness_inputs.open('x',encoding='utf-8',newline='\n')as f:
            for pad in r['selected'][0]['fullInputs']:f.write(json.dumps(pad,separators=(',',':'))+'\n')
    print(json.dumps(r['summary'],indent=2))


if __name__=='__main__':main()
