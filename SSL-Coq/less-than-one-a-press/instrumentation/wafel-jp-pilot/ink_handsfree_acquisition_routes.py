"""Finite alternative controller-only stock-box acquisition routes.

The accepted pre-entry level-select setup is the only non-controller write.
These branches change approach direction, dive timing and native actor phase;
they do not supply gameplay positions, actions, timers or held references.
Full native states are restored only at accepted-prefix branch boundaries.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from replay import create_game, Observer, load_capture
from ink_box_delivery import accepted_prefix, advance, steer
from ink_clean_handsfree import snapshot as east_snapshot


def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def snap(g, o, slot, n):
    r = east_snapshot(g, o, n)
    q = 'gObjectPool[%d].' % slot
    r.update(boxSlot=slot, boxBehavior=g.read(q+'behavior') == g.address('bhvJumpingBox'),
             boxPosition=[g.read(q+'oPos'+a) for a in 'XYZ'], boxHeld=g.read(q+'oHeldState'),
             boxActive=g.read(q+'activeFlags'), boxAction=g.read(q+'oAction'),
             boxIntangible=g.read(q+'oIntangibleTimer'),
             actionTimer=g.read('gMarioState.actionTimer'),
             actionState=g.read('gMarioState.actionState'))
    return r


def policies():
    for degrees in (-60, -40, -20, 20, 40, 60):
        a = math.radians(degrees)
        waypoint = [round(1120+600*math.sin(a)), round(6480+600*math.cos(a))]
        through = [round(1120-1600*math.sin(a)), round(6480-1600*math.cos(a))]
        for wait in (0, 24):
            for post in ('through', 'pyramid'):
                yield dict(family='east-diagonal', prefix=350, slot=47,
                           waypoint=waypoint, radius=110, wait=wait, degrees=degrees,
                           destination=through if post == 'through' else [-2048,-1024],
                           post=post, horizon=420)
    for prefix in (2390, 2500):
        for waypoint, destination in [((-4500,1700),(-6600,1700)),
                                      ((-4650,2100),(-6400,800)),
                                      ((-5200,2400),(-5200,200)),
                                      ((-4650,1300),(-6400,2600))]:
            for radius in (80,120,180):
                yield dict(family='west-three-pillars', prefix=prefix, slot=49,
                           waypoint=list(waypoint), destination=list(destination),
                           radius=radius, wait=0, horizon=500)
    for waypoint in ((-5750,1900),(-5700,2300),(-5500,2400),
                     (-4900,2400),(-4600,2100),(-4600,1700)):
        dx=-5200-waypoint[0];dz=1700-waypoint[1];d=math.hypot(dx,dz)
        destination=[round(-5200+1700*dx/d),round(1700+1700*dz/d)]
        for radius in (70,110,160):
            yield dict(family='west-staged',prefix=2500,slot=49,waypoint=list(waypoint),
                       transit=[[-5500,2300]],destination=destination,radius=radius,
                       wait=0,horizon=650)


def summarize(t):
    rows = t['samples']; slot = t['policy']['slot']; hf = t['handsfreeExit']
    pickup = next((r for r in rows if r['held'] == slot), None)
    held = [r for r in rows if r['held'] == slot]
    hfheld = [r for r in held if hf is not None and r['n'] >= hf['sample']['n']]
    return dict(policy=t['policy'], updates=len(t['inputs']),
                inputSha256=sha_controls(t['inputs']), dive=t['dive'], pickup=pickup,
                handsfreeExit=hf, heldUpdates=len(held), handsfreeHeldUpdates=len(hfheld),
                maximumHandsfreeHeldY=max((r['movement'][1] for r in hfheld), default=None),
                nearestHandsfreeToPyramid=min(hfheld, key=lambda r:math.hypot(r['movement'][0]+2048,r['movement'][2]+1024), default=None),
                highestHandsfree=max(hfheld, key=lambda r:r['movement'][1], default=None),
                crawlUpdates=sum(r['action'] == 0x04008448 for r in rows),
                maximumPillars=max((r['pillars'] for r in rows if r['pillars'] is not None), default=None),
                spinningSamples=sum(r['topBehavior'] and r['topAction'] == 1 for r in rows),
                final=rows[-1])


def sha_controls(inputs):
    return hashlib.sha256(''.join(json.dumps(p,separators=(',',':'))+'\n' for p in inputs).encode()).hexdigest()


def run(capture):
    rows = load_capture(capture); g=create_game(); o=Observer(g)
    seeds={}; initials={}; history=[]; pool_scans=[]; previous=None; deletion=None; reuse=None; setup_history=[]
    for i,row in enumerate(rows[:2500]):
        accepted_prefix(g,o,[row],1)
        if i+1>=350:
            h=snap(g,o,47,i+1)
            if deletion is None and previous is not None and previous['boxBehavior'] and previous['boxActive'] and not h['boxActive']:
                deletion=dict(before=previous,after=h)
            if reuse is None and previous is not None and previous['boxBehavior'] and not h['boxBehavior']:
                reuse=dict(before=previous,after=h)
            if i+1 in (350,375,489,490,491,492,493,1000,1500,2000,2390,2500):history.append(h)
            if previous is None or (h['level'],h['area'],h['lives'])!=(previous['level'],previous['area'],previous['lives']):
                setup_history.append(dict(inputCount=i+1,globalTimer=h['timer'],level=h['level'],area=h['area'],lives=h['lives']))
            previous=h
        if i+1 in (350,1000,1500,2000,2390,2500):
            boxes=[]
            for slot in range(240):
                q='gObjectPool[%d].'%slot
                if g.read(q+'behavior')==g.address('bhvJumpingBox'):
                    boxes.append(dict(slot=slot,active=g.read(q+'activeFlags'),held=g.read(q+'oHeldState'),
                                      position=[g.read(q+'oPos'+a) for a in 'XYZ']))
            pool_scans.append(dict(inputCount=i+1,poolSlotsScanned=240,boxes=boxes))
        if i+1 in (350,2390,2500):
            seeds[i+1]=g.save_state()
            initials[i+1]={s:snap(g,o,s,0) for s in (47,49)}
    names=g.mario_action_names(); targets={g.constant(n) for n in ('ACT_FREEFALL','ACT_STOMACH_SLIDE','ACT_BUTT_SLIDE')}
    trials=[]
    for policy in policies():
        prefix=policy['prefix'];slot=policy['slot'];g.load_state(seeds[prefix])
        initial=snap(g,o,slot,0);assert initial == initials[prefix][slot]
        assert initial['boxBehavior'] and initial['boxActive'] and initial['held'] == -1
        inputs=[];samples=[];events=[];passed=False;pressed=False;dive=None;hf=None;pickup_n=None;previous=None;stage=0
        transit=policy.get('transit',[])
        for k in range(policy['horizon']):
            p=g.read('gMarioState.pos');box=[g.read('gObjectPool[%d].oPos%s'%(slot,a)) for a in 'XYZ']
            if stage<len(transit) and math.hypot(p[0]-transit[stage][0],p[2]-transit[stage][1])<60:stage+=1
            passed |= stage==len(transit) and math.hypot(p[0]-policy['waypoint'][0],p[2]-policy['waypoint'][1])<60
            target = transit[stage] if stage<len(transit) else policy['waypoint'] if not passed else policy['destination'] if pressed else (box[0],box[2])
            press = k >= policy['wait'] and passed and not pressed and math.hypot(p[0]-box[0],p[2]-box[2])<policy['radius'] and g.read('gMarioState.forwardVel')>=29
            if press: pressed=True;dive=dict(n=k+1,before=snap(g,o,slot,k))
            pad = dict(buttons=0,stick=[0,0]) if k<policy['wait'] else steer(g,target,0x4000 if press else 0x2000 if pressed else 0)
            advance(g,pad);inputs.append(pad);r=snap(g,o,slot,k+1);samples.append(r)
            actions=[names.get(e['action'],hex(e['action'])) for e in g.frame_log() if e['type']=='FLT_EXECUTE_ACTION']
            key=(r['action'],r['held'],r['boxBehavior'],r['boxActive'])
            if key != previous: events.append(dict(n=k+1,actionEntries=actions,sample=r));previous=key
            if pickup_n is None and r['held']==slot:pickup_n=k+1
            if hf is None and 'ACT_DIVE_PICKING_UP' in actions and r['held']==slot and r['action'] in targets:
                hf=dict(actionEntries=actions,sample=r)
            if hf is not None and k+1-hf['sample']['n']>=120:break
            if pickup_n is not None and hf is None and k+1-pickup_n>=120:break
            if r['level']!=8 or r['area']!=1 or g.read('gMarioState.area.camera').is_null():break
        t=dict(policy=policy,initial=initial,inputs=inputs,samples=samples,events=events,dive=dive,handsfreeExit=hf)
        trials.append(t)
        s=summarize(t)
        print(json.dumps(dict(policy=policy,updates=s['updates'],pickup=s['pickup'] is not None,handsfree=hf is not None,maximumHandsfreeHeldY=s['maximumHandsfreeHeldY'])),flush=True)
    selected=[]
    for family in ('east-diagonal','west-three-pillars','west-staged'):
        group=[t for t in trials if t['policy']['family']==family]
        chosen=max(group,key=lambda t:(t['handsfreeExit'] is not None,summarize(t)['maximumHandsfreeHeldY'] or -10000,summarize(t)['pickup'] is not None))
        fresh=create_game();fo=Observer(fresh);p=chosen['policy'];accepted_prefix(fresh,fo,rows,p['prefix'])
        assert snap(fresh,fo,p['slot'],0)==chosen['initial']
        for n,(pad,expected) in enumerate(zip(chosen['inputs'],chosen['samples'])):
            advance(fresh,pad);assert snap(fresh,fo,p['slot'],n+1)==expected
        full=[dict(buttons=r['buttons'],stick=r['stick']) for r in rows[:p['prefix']]]+chosen['inputs']
        selected.append(dict(summary=summarize(chosen),inputs=chosen['inputs'],fullInputs=full,
                             fullInputCount=len(full),fullInputSha256=sha_controls(full),events=chosen['events'],
                             freshReplay=dict(passed=True,prefixInputs=p['prefix'],comparedInitial=True,
                                              comparedBranchSnapshots=len(chosen['samples']),gameplaySetupWrites=[])))
    summaries=[summarize(t) for t in trials]
    decomp=Path('../../../reference-sm64-decomp')
    src=['src/game/mario_actions_object.c','src/game/mario_actions_airborne.c','src/game/mario_actions_moving.c','src/game/mario_actions_stationary.c','src/game/mario.c','src/game/behaviors/jumping_box.inc.c','src/game/interaction.c']
    return dict(schema=1,scope=__doc__,head='b53d39e5277919dc35e53a94e767d2d58bfd323e',
                scriptSha256=sha(__file__),baselineSha256=sha(capture),runtimeSha256=sha('build/wafel-pilot/sm64_jp.dll'),
                helperSha256={p:sha(Path(__file__).with_name(p)) for p in ('replay.py','ink_box_delivery.py','ink_clean_handsfree.py')},
                sourceSha256={p:sha(decomp/p) for p in src},gameplaySetupWrites=[],
                preEntrySetup='create_game sets gDebugLevelSelect=1 before level entry',
                baselineAFrames=sum(bool(r['buttons']&0x8000) for r in rows),
                acceptedHistoryAudit=dict(samples=history,firstEasternBoxInactive=deletion,
                                          firstEasternSlotReuse=reuse,fullPoolScans=pool_scans,
                                          levelAreaLivesChangesFrom350=setup_history),
                trials=trials,selected=selected,
                summary=dict(policies=len(trials),updates=sum(s['updates'] for s in summaries),
                             uniqueInputHistories=len(set((s['policy']['prefix'],s['inputSha256']) for s in summaries)),
                             pickupPolicies=sum(s['pickup'] is not None for s in summaries),
                             handsfreePolicies=sum(s['handsfreeExit'] is not None for s in summaries),
                             crawlUpdates=sum(s['crawlUpdates'] for s in summaries),
                             maximumPillars=max(s['maximumPillars'] for s in summaries),
                             spinningSamples=sum(s['spinningSamples'] for s in summaries)),
                familySummaries=[dict(family=family,policies=len(group),
                                      updates=sum(s['updates'] for s in group),
                                      uniqueInputHistories=len(set((s['policy']['prefix'],s['inputSha256']) for s in group)),
                                      diveTriggered=sum(s['dive'] is not None for s in group),
                                      pickupPolicies=sum(s['pickup'] is not None for s in group),
                                      handsfreePolicies=sum(s['handsfreeExit'] is not None for s in group),
                                      maximumHandsfreeHeldY=max((s['maximumHandsfreeHeldY'] for s in group if s['maximumHandsfreeHeldY'] is not None),default=None))
                                 for family in ('east-diagonal','west-three-pillars','west-staged')
                                 for group in [[s for s in summaries if s['policy']['family']==family]]],
                stoppingRule='66 fixed policies; at most420 east/500 direct-west/650 staged-west updates; stop120 updates after hands-free exit or non-hands-free pickup; no exhaustive claim')


def compact(raw,path):
    return {**{k:v for k,v in raw.items() if k!='trials'},'rawPath':str(path).replace('\\','/'),
            'rawSha256':sha(path),'trials':[summarize(t) for t in raw['trials']]}


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('output',type=Path)
    p.add_argument('--receipt',type=Path,required=True);a=p.parse_args();r=run(a.capture)
    with a.output.open('x',encoding='utf-8',newline='\n') as f:json.dump(r,f,indent=2,allow_nan=False);f.write('\n')
    with a.receipt.open('x',encoding='utf-8',newline='\n') as f:json.dump(compact(r,a.output),f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(r['summary'],indent=2))


if __name__=='__main__':main()
