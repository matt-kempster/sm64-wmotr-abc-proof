"""Bounded clean Bob-omb regrab/transport after actual no-A hands-free pickup.

No gameplay state is edited. This search does not use the translated teleport
fixtures. Entry uses the existing accepted pre-entry level-select flag only.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
from ink_handsfree_teleport import clean_bobomb_idle_seed,snap as base_snap,actor
from ink_box_delivery import advance,steer,accepted_prefix
from replay import load_capture,create_game,Observer

GOAL=(6930,-4871)


def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def ihash(p):return hashlib.sha256(json.dumps(p,separators=(',',':')).encode()).hexdigest()
def distance(s):return math.hypot(s['movement'][0]-GOAL[0],s['movement'][2]-GOAL[1])
def alive(s):return s['actors'][0]['behavior']=='bhvBobomb'and bool(s['actors'][0]['activeFlags'])


def snap(g,o,slots):
    s=base_snap(g,o,slots)
    top=g.read('gObjectPool[61].behavior')==g.address('bhvPyramidTop')
    s.update(interact=o.slot(g.read('gMarioState.interactObj')),hurtCounter=g.read('gMarioState.hurtCounter'),
             flyGuy38=actor(g,38),slot38IsFlyGuy=g.read('gObjectPool[38].behavior')==g.address('bhvFlyGuy'),
             floorType=g.read('gMarioState.floor?.type'),quicksandDepth=g.read('gMarioState.quicksandDepth'),
             topBehavior=top,topAction=g.read('gObjectPool[61].oAction')if top else None,
             topTimer=g.read('gObjectPool[61].oTimer')if top else None,
             pillars=g.read('gObjectPool[61].oPyramidTopPillarsTouched')if top else None)
    return s


def reconstruct(capture,seed,count):
    g=create_game();o=Observer(g);accepted_prefix(g,o,load_capture(capture),350)
    for pad,expected in zip(seed['controls'][:count],seed['samples'][:count]):
        advance(g,pad);assert base_snap(g,o,[39])==expected
    return g,o


def summary(t):
    rows=t['samples'];grabs=[];drops=[]
    for before,after in zip(rows,rows[1:]):
        if before['held']!=39 and after['held']==39:grabs.append(after)
        if before['held']==39 and after['held']!=39:drops.append(after)
    held=[s for s in rows if s['held']==39 and alive(s)]
    expired=[s for s in held if s['actors'][0]['fuse']>150]
    return dict(policy=t['policy'],updates=len(t['inputs']),inputSha256=ihash(t['inputs']),
        regrabs=len(grabs),firstRegrab=next(iter(grabs),None),lastRegrab=grabs[-1]if grabs else None,
        expiredRegrabs=sum(s['actors'][0]['fuse']>150 for s in grabs),
        drops=len(drops),firstDrop=next(iter(drops),None),lastDrop=drops[-1]if drops else None,
        expiredHeldSamples=len(expired),maximumFuse=max(s['actors'][0].get('fuse',0)for s in rows),
        maximumScale=max(s['actors'][0]['scale'][0]for s in rows if s['actors'][0]['behavior']=='bhvBobomb'),
        maximumHeldScale=max((s['actors'][0]['scale'][0]for s in held),default=None),
        maximumHeldFuse=max((s['actors'][0]['fuse']for s in held),default=None),
        maximumHeldY=max((s['movement'][1]for s in held),default=None),
        maximumPillars=max((s['pillars']for s in rows if s['pillars']is not None),default=None),
        spinningTopSamples=sum(s['topBehavior']and s['topAction']==1 for s in rows),
        closestHeld=min(held,key=distance,default=None),minimumHeldDistance=min((distance(s)for s in held),default=None),
        final=rows[-1],actorSurvives=alive(rows[-1]))


def rollout(g,o,state,policy,horizon=500):
    g.load_state(state);samples=[snap(g,o,[39])];inputs=[];events=[];prior=None;names=g.mario_action_names()
    regrabs=0;stage=0
    for k in range(horizon):
        s=samples[-1];a=s['actors'][0]
        if not alive(s)or s['area']!=1 or g.read('gMarioState.area.camera').is_null():break
        held=s['held']==39;action=s['action']
        target=policy.get('heldTarget',GOAL) if held else(a['xyz'][0],a['xyz'][2])
        if held and regrabs and policy.get('postRegrabGoal'):target=GOAL
        if policy.get('transportRoute'):
            route=policy['transportRoute'];p=s['movement']
            while stage<len(route)-1 and math.hypot(p[0]-route[stage][0],p[2]-route[stage][1])<200:stage+=1
            if held:target=(2*p[0]-route[stage][0],2*p[2]-route[stage][1])
        if policy.get('bearing')is not None and held:
            p=s['movement']
            desired=(-policy['bearing']*math.pi/180 if p[0]<policy['untilX']else math.atan2(p[0]-GOAL[0],p[2]-GOAL[1]))
            current=s['face'][1]*math.tau/65536
            change=(desired-current+math.pi)%math.tau-math.pi
            cap=policy['turnLimit']*math.tau/65536
            angle=current+max(-cap,min(cap,change))
            target=(p[0]+1000*math.sin(angle),p[2]+1000*math.cos(angle))
        if policy['aim']=='goal':target=GOAL
        elif policy['aim']=='lead'and not held:
            dx,dz=GOAL[0]-s['movement'][0],GOAL[1]-s['movement'][2];d=math.hypot(dx,dz)
            target=(a['xyz'][0]+80*dx/d,a['xyz'][2]+80*dz/d)
        buttons=0
        if(not held or action==0x0c400201)and(k-policy['phase'])%policy['period']==0:buttons=0x4000
        if policy['forcedDropB']and action in(0x08000207,0x00000442)and s['marioInteract']&8:buttons=0x4000
        if k==policy.get('releaseAt')and held:buttons=0x4000
        pad=steer(g,target,buttons)
        if policy['stationaryPick']and(not held or action==0x0c400201):pad['stick']=[0,0]
        inputs.append(pad);advance(g,pad);s=snap(g,o,[39]);samples.append(s)
        if not held and s['held']==39:regrabs+=1
        key=(s['action'],s['held'],s['actors'][0]['oHeldState'],s['actors'][0]['oAction'],s['actors'][0]['activeFlags'])
        if key!=prior:
            events.append(dict(update=k+1,entries=[names.get(e['action'],hex(e['action']))for e in g.frame_log()if e['type']=='FLT_EXECUTE_ACTION'],sample=s));prior=key
    return dict(policy=policy,inputs=inputs,samples=samples,events=events)


def run(a):
    g,o,seed=clean_bobomb_idle_seed(a.capture);state=g.save_state();trials=[]
    for aim in('actor','lead','goal'):
      for period in(2,4,6,8):
       for phase in(0,1):
        for forced in(False,True):
         policy=dict(startAfterAcquisition=197,aim=aim,period=period,phase=phase,forcedDropB=forced,stationaryPick=False)
         t=rollout(g,o,state,policy);trials.append(dict(**t,summary=summary(t)))
    for period in(2,4,6,8):
      for phase in(0,1):
        policy=dict(startAfterAcquisition=197,aim='actor',period=period,phase=phase,forcedDropB=True,stationaryPick=True)
        t=rollout(g,o,state,policy);trials.append(dict(**t,summary=summary(t)))
    for count in(115,130,150):
      g,o=reconstruct(a.capture,seed,count);state=g.save_state()
      for held_target in(GOAL,(5000,6000),(5000,5000)):
       for release in(None,0,8,16):
        for phase in(0,1):
         for redirect in(False,True):
          policy=dict(startAfterAcquisition=count,aim='actor',period=2,phase=phase,forcedDropB=True,
                      stationaryPick=False,heldTarget=held_target,releaseAt=release,postRegrabGoal=redirect)
          t=rollout(g,o,state,policy);trials.append(dict(**t,summary=summary(t)))
    recovery=[]
    base=next(t for t in trials if t['policy'].get('startAfterAcquisition')==115 and t['policy'].get('heldTarget')==(5000,6000)
              and t['policy'].get('releaseAt')==8 and t['policy']['phase']==0 and not t['policy'].get('postRegrabGoal'))
    g,o=reconstruct(a.capture,seed,115)
    for pad,expected in zip(base['inputs'][:151],base['samples'][1:152]):advance(g,pad);assert snap(g,o,[39])==expected
    recovery_state=g.save_state()
    routes=[[GOAL],[(5500,4000),(6000,2000),(6500,0),GOAL],[(6000,4000),(6500,3000),(7000,1000),GOAL],
            [(4800,3000),(5000,1500),(5800,-1000),GOAL],[(6500,4500),(7000,3500),GOAL],
            [(5000,4500),(5000,0),(7000,0),GOAL]]
    for route_index,route in enumerate(routes):
      for period in(2,4):
       for phase in(0,1):
        policy=dict(transportRoute=route,routeIndex=route_index,aim='actor',period=period,phase=phase,
            forcedDropB=True,stationaryPick=False)
        t=rollout(g,o,recovery_state,policy,horizon=800);recovery.append(dict(**t,summary=summary(t)))
    for bearing in(20,25,30,35):
      for until_x in(6500,6800):
       for turn_limit in(512,1024,2048,4096):
        policy=dict(bearing=bearing,untilX=until_x,turnLimit=turn_limit,aim='actor',period=2,phase=0,
            forcedDropB=True,stationaryPick=False)
        t=rollout(g,o,recovery_state,policy,horizon=800);recovery.append(dict(**t,summary=summary(t)))
    selected=[]
    choices=[('most-regrabs',max(trials,key=lambda t:t['summary']['regrabs'])),
             ('nearest-held',min(trials,key=lambda t:t['summary']['minimumHeldDistance'])),
             ('longest-lived',max(trials,key=lambda t:len(t['inputs'])))]
    for label,t in choices:
        fresh,fo=reconstruct(a.capture,seed,t['policy']['startAfterAcquisition'])
        assert snap(fresh,fo,[39])==t['samples'][0]
        for pad,expected in zip(t['inputs'],t['samples'][1:]):advance(fresh,pad);assert snap(fresh,fo,[39])==expected
        selected.append(dict(label=label,**t,fullControllerPrefix=[dict(buttons=r['buttons'],stick=r['stick'])for r in load_capture(a.capture)[:350]]+seed['controls'][:t['policy']['startAfterAcquisition']],
            freshReplay=dict(passed=True,comparedSnapshots=len(t['samples']),gameplayEdits=[])))
    prefix=[dict(buttons=r['buttons'],stick=r['stick'])for r in load_capture(a.capture)[:350]]+seed['controls']
    for label,t in [('recovery-nearest',min(recovery,key=lambda t:t['summary']['minimumHeldDistance'])),
                    ('recovery-longest',max(recovery,key=lambda t:len(t['inputs'])))]:
        fresh,fo=reconstruct(a.capture,seed,115)
        for pad in base['inputs'][:151]:advance(fresh,pad)
        assert snap(fresh,fo,[39])==t['samples'][0]
        for pad,expected in zip(t['inputs'],t['samples'][1:]):advance(fresh,pad);assert snap(fresh,fo,[39])==expected
        selected.append(dict(label=label,**t,fullControllerPrefix=prefix[:465]+base['inputs'][:151],
            freshReplay=dict(passed=True,comparedSnapshots=len(t['samples']),gameplayEdits=[])))
    return dict(schema=1,scope=__doc__,scriptSha256=sha(__file__),baselineSha256=sha(a.capture),
        helperSha256={n:sha(Path(__file__).with_name(n))for n in('ink_handsfree_teleport.py','ink_box_delivery.py','replay.py')},
        runtimeSha256=sha('build/wafel-pilot/sm64_jp.dll'),gameplayEdits=[],goal=list(GOAL),horizon=500,
        seed=seed,fullControllerPrefix=prefix,trials=trials,recoveryTrials=recovery,
        recoverySeed=dict(acquisitionInputs=115,basePolicy=base['policy'],baseInputs=base['inputs'][:151],gameplayEdits=[]),selected=selected,
        summary=dict(policies=len(trials),uniqueSeededInputHistories=len({(t['policy']['startAfterAcquisition'],ihash(t['inputs']))for t in trials}),
            updates=sum(len(t['inputs'])for t in trials),maxRegrabs=max(t['summary']['regrabs']for t in trials),
            survivors=sum(t['summary']['actorSurvives']for t in trials),
            minimumHeldDistance=min(t['summary']['minimumHeldDistance']for t in trials),
            maximumFuse=max(t['summary']['maximumFuse']for t in trials),
            recoveryPolicies=len(recovery),recoveryUpdates=sum(len(t['inputs'])for t in recovery),
            recoveryUniqueInputHistories=len({ihash(t['inputs'])for t in recovery}),
            recoveryMinimumHeldDistance=min(t['summary']['minimumHeldDistance']for t in recovery),
            recoveryMaxRegrabs=max(t['summary']['regrabs']for t in recovery),
            recoverySurvivors=sum(t['summary']['actorSurvives']for t in recovery),
            recoveryMaximumFuse=max(t['summary']['maximumFuse']for t in recovery),
            maximumHeldFuse=max(t['summary']['maximumHeldFuse']for t in trials+recovery),
            maximumHeldScale=max(t['summary']['maximumHeldScale']for t in trials+recovery),
            maximumHeldY=max(t['summary']['maximumHeldY']for t in trials+recovery),
            maximumPillars=max(t['summary']['maximumPillars']for t in trials+recovery),
            spinningTopSamples=sum(t['summary']['spinningTopSamples']for t in trials+recovery),
            freshReplayRuns=len(selected),distinctFreshReplayFullInputs=len({ihash(t['fullControllerPrefix']+t['inputs'])for t in selected}),
            freshReplaySnapshots=sum(t['freshReplay']['comparedSnapshots']for t in selected)))


def compact(raw,path):
    return{**{k:v for k,v in raw.items()if k not in('trials','recoveryTrials','selected')},'rawReportName':str(path).replace('\\','/'),
        'rawReportSha256':sha(path),'trials':[t['summary']for t in raw['trials']],
        'recoveryTrials':[t['summary']for t in raw['recoveryTrials']],
        'selected':[{**{k:v for k,v in t.items()if k!='samples'},'initial':t['samples'][0],'final':t['samples'][-1]}for t in raw['selected']]}


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('output',type=Path)
    p.add_argument('--receipt',type=Path,required=True);a=p.parse_args();raw=run(a)
    with a.output.open('x',encoding='utf-8',newline='\n')as f:json.dump(raw,f,indent=2,allow_nan=False);f.write('\n')
    with a.receipt.open('x',encoding='utf-8',newline='\n')as f:json.dump(compact(raw,a.output),f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(raw['summary'],indent=2))
