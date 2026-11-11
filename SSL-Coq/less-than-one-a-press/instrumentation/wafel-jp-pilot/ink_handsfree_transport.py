"""Bounded controller-only transport from five clean eastern-box hands-free histories.

Only the accepted pre-entry level-select flag and controller fields are written.
Whole-state restores select native histories; no pose/action/held/cache/timer is
supplied. This finite transport search is not an Ink-route exclusion.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from replay import create_game, Observer, load_capture
from ink_box_delivery import accepted_prefix, advance
from ink_clean_handsfree import snapshot

SEEDS = [0, 5, 6, 15, 16]
ROUTES = [
    [(-2048,-1024)], [(1120,2500),(-2048,-1024)], [(0,3000),(-2048,-1024)],
    [(2600,5200),(3200,3000),(1000,1800),(-2048,1000),(-2048,-1024)],
    [(3500,5500),(5000,3500),(3000,1000),(-2048,-1024)],
    [(-1000,5500),(-4000,4000),(-4000,1500),(-2048,-1024)],
    [(-2500,5800),(-4500,3500),(-3500,0),(-2048,-1024)],
    [(1120,4800),(-1000,3500),(-2048,-1024)],
    [(2000,5700),(1000,4500),(-2048,-1024)],
]


def sha(path): return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def ihash(inputs): return hashlib.sha256(json.dumps(inputs, separators=(',', ':')).encode()).hexdigest()


def snap(g, o, n):
    s = snapshot(g, o, n)
    s.update(actionTimer=g.read('gMarioState.actionTimer'), health=g.read('gMarioState.health'),
             slideYaw=g.read('gMarioState.slideYaw'), holp=g.read('gMarioState.marioBodyState.heldObjLastPosition'))
    return s


def holding(s): return s['held'] == 47 and s['boxBehavior'] and bool(s['boxActive']) and s['boxHeld'] == 1
def distance(s): return math.hypot(s['movement'][0]+2048, s['movement'][2]+1024)


def pad_for(g, yaw, buttons=0x2000, magnitude=127):
    angle = yaw - g.read('gMarioState.area.camera.yaw')*math.tau/65536
    return dict(buttons=buttons, stick=[round(magnitude*math.sin(angle)), round(-magnitude*math.cos(angle))])


def target_pad(g, target, buttons=0x2000, magnitude=127):
    p = g.read('gMarioState.pos')
    return pad_for(g, math.atan2(target[0]-p[0], target[1]-p[2]), buttons, magnitude)


def make_seed(capture, source, index):
    g = create_game(); o = Observer(g); rows = load_capture(capture)
    accepted_prefix(g, o, rows, 350)
    trial = source['trials'][index]; count = trial['firstHandsfreeExit']['sample']['n']
    for n, (pad, expected) in enumerate(zip(trial['inputs'][:count], trial['samples'][:count])):
        advance(g, pad); assert snapshot(g,o,n+1) == expected
    prefix = [dict(buttons=r['buttons'],stick=r['stick'])for r in rows[:350]] + trial['inputs'][:count]
    return g, o, dict(sourceTrial=index, sourcePolicy=trial['policy'], acceptedPrefixInputs=350,
        fullControllerPrefix=prefix, initialEdits=[], start=snap(g,o,0))


def summarize(t):
    rows=t['samples']; held=[r for r in rows if holding(r)]
    released=next((i for i,r in enumerate(rows)if not holding(r)),None)
    return dict(policy=t['policy'], updates=len(t['inputs']), inputSha256=ihash(t['inputs']),
        heldUpdates=len(held)-1, minimumHeldDistance=min((distance(r)for r in held),default=None),
        closestHeld=min(held,key=distance,default=None), highestHeld=max(held,key=lambda r:r['movement'][1],default=None),
        firstRelease=None if released is None else dict(before=rows[max(0,released-1)],after=rows[released]),
        firstDeletion=next((r for r in rows if not r['boxBehavior']or not r['boxActive']),None),
        actionNames=sorted(set(e['name']for e in t['events'])),
        maximumPillars=max((r['pillars']for r in rows if r['pillars']is not None),default=None),
        spinningTopSamples=sum(r['topBehavior']and r['topAction']==1 for r in rows),
        highCrawlSamples=sum(r['action']==0x04008448 and r['movement'][1]>=768 for r in rows), final=rows[-1])


def event(g, s):
    names=g.mario_action_names()
    return dict(n=s['n'],name=names.get(s['action'],hex(s['action'])),sample=s,
        executed=[names.get(e['action'],hex(e['action']))for e in g.frame_log()if e['type']=='FLT_EXECUTE_ACTION'])


def rollout(g,o,state,policy):
    g.load_state(state); samples=[snap(g,o,0)]; inputs=[]; events=[event(g,samples[0])]
    stage=0; prior=(samples[0]['action'],samples[0]['held'],samples[0]['boxActive']); release=None
    for k in range(700):
        s=samples[-1]
        if s['area']!=1 or g.read('gMarioState.area.camera').is_null()or s['warpOp']!=0:break
        route=policy['route'];p=s['movement']
        while stage<len(route)-1 and math.hypot(p[0]-route[stage][0],p[2]-route[stage][1])<250:stage+=1
        airborne=bool(s['action']&0x800)
        buttons=0x4000 if policy['airDive'] and airborne and s['action']==0x0100088C else 0x2000
        pad=target_pad(g,route[stage],buttons,policy['magnitude']);inputs.append(pad);advance(g,pad)
        s=snap(g,o,k+1);samples.append(s);key=(s['action'],s['held'],s['boxActive'])
        if key!=prior:events.append(event(g,s));prior=key
        if not holding(s)and release is None:release=k+1
        if release is not None and k+1>=release+12:break
    return dict(policy=policy,inputs=inputs,samples=samples,events=events)


def beam(g,o,state,objective,width=12,horizon=360,block=4):
    g.load_state(state);start=snap(g,o,0);frontier=[dict(state=state,inputs=[],samples=[start],events=[event(g,start)])]
    last=frontier[0];best=frontier[0];highest=frontier[0];stats=[];tested=0;updates=0
    names=g.mario_action_names();actions={};held_actions={};rejected={};sampled_closest=start;sampled_highest=start
    max_pillars=start['pillars'];spinning=0;high_crawl=0
    for depth in range(1,horizon//block+1):
        candidates=[]
        for parent_index,parent in enumerate(frontier):
            for option in range(14):
                g.load_state(parent['state']);samples=[];inputs=[];events=[];valid=True
                for j in range(block):
                    p=g.read('gMarioState.pos');vel=g.read('gMarioState.vel')
                    toward=math.atan2(-2048-p[0],-1024-p[2]);direction=math.atan2(vel[0],vel[2])
                    yaw=(toward if option==0 else direction+(option-4)*math.pi/8 if option<8 else (option-8)*math.pi/2)
                    buttons=0x2000
                    if option==12 and g.read('gMarioState.action')==0x0100088C:buttons=0x4000
                    if option==13:buttons=0 if j==0 else 0x2000
                    pad=pad_for(g,yaw,buttons);inputs.append(pad);advance(g,pad);updates+=1
                    s=snap(g,o,len(parent['inputs'])+j+1);samples.append(s)
                    name=names.get(s['action'],hex(s['action']));actions[name]=actions.get(name,0)+1
                    if s['pillars']is not None:max_pillars=max(max_pillars,s['pillars'])
                    spinning+=bool(s['topBehavior']and s['topAction']==1)
                    high_crawl+=bool(s['action']==0x04008448 and s['movement'][1]>=768)
                    if holding(s):
                        held_actions[name]=held_actions.get(name,0)+1
                        if distance(s)<distance(sampled_closest):sampled_closest=s
                        if s['movement'][1]>sampled_highest['movement'][1]:
                            sampled_highest=s
                            highest=dict(inputs=parent['inputs']+inputs,samples=parent['samples']+samples,
                                         events=parent['events']+events+[event(g,s)])
                    reason=('lost-live-held-box'if not holding(s)else'area'if s['area']!=1 else'warp'if s['warpOp']!=0
                            else'health'if s['health']<0x100 else'camera'if g.read('gMarioState.area.camera').is_null()else None)
                    if reason is not None:rejected[reason]=rejected.get(reason,0)+1;valid=False;break
                    prior=parent['samples'][-1]if j==0 else samples[-2]
                    if s['action']!=prior['action']:events.append(event(g,s))
                tested+=1
                if not valid:continue
                s=samples[-1];p=s['movement'];d=distance(s)
                score=(-d+(20 if objective=='height'else 2)*p[1]+(2 if objective=='momentum'else .05)*abs(s['forward']))
                if objective=='momentum':score=-.05*d+2*p[1]+1000*abs(s['forward'])
                cell=(round(p[0]/80),round(p[2]/80),round(p[1]/80),s['action'],round(s['forward']/8),s['slideYaw']//4096)
                candidates.append(dict(parent=parent_index,inputs=inputs,samples=samples,events=events,score=score,cell=cell))
        candidates.sort(key=lambda x:x['score'],reverse=True);new=[];cells=set()
        for c in candidates:
            if c['cell']in cells:continue
            cells.add(c['cell']);parent=frontier[c['parent']];g.load_state(parent['state'])
            for pad in c['inputs']:advance(g,pad);updates+=1
            new.append(dict(state=g.save_state(),inputs=parent['inputs']+c['inputs'],samples=parent['samples']+c['samples'],events=parent['events']+c['events']))
            if len(new)==width:break
        stats.append(dict(depth=depth,passing=len(candidates),retained=len(new),bestScore=None if not candidates else candidates[0]['score']))
        frontier=new
        if not frontier:break
        last=frontier[0]
        for row in frontier:
            if distance(row['samples'][-1])<distance(best['samples'][-1]):best=row
    strip=lambda t:dict(policy=dict(mode='beam',objective=objective),inputs=t['inputs'],samples=t['samples'],events=t['events'])
    return dict(objective=objective,width=width,horizon=horizon,block=block,menuSize=14,
        pruning='Preserve live stock box47 held; area1, no delayed warp, health>=0x100, valid camera. Rank distance/height/speed with 80-unit cells and speed/yaw diversity.',
        testedBranches=tested,nativeUpdatesIncludingRetainedReconstruction=updates,depths=stats,
        evaluatedActionSamples=actions,evaluatedHeldActionSamples=held_actions,rejectedBranches=rejected,
        maximumPillars=max_pillars,spinningTopSamples=spinning,highCrawlSamples=high_crawl,
        sampledClosestHeld=sampled_closest,sampledHighestHeld=sampled_highest,
        closest=strip(best),last=strip(last),highest=strip(highest))


def run(args):
    source=json.loads(args.source.read_text());trials=[];seeds=[];beams=[];choices=[]
    for index in SEEDS:
        g,o,seed=make_seed(args.capture,source,index);state=g.save_state();seeds.append(seed)
        local=[]
        for route_index,route in enumerate(ROUTES):
            for air_dive in (False,True):
                policy=dict(routeIndex=route_index,route=route,magnitude=127,airDive=air_dive)
                t=rollout(g,o,state,policy);local.append(t)
                trials.append(dict(sourceTrial=index,summary=summarize(t),**t))
        best=min(local,key=lambda t:summarize(t)['minimumHeldDistance'])
        choices.append(('route-'+str(index),index,best))
        if not args.skip_beams:
            for objective in ('distance','height','momentum'):
                b=beam(g,o,state,objective,width=24 if objective=='momentum'else 12);beams.append(dict(sourceTrial=index,**b))
                choices.append(('beam-'+str(index)+'-'+objective,index,b['closest']))
                if objective=='momentum':choices.append(('beam-highest-'+str(index),index,b['highest']))
        s=summarize(best)
        print(json.dumps(dict(seed=index,routeMinimumHeldDistance=s['minimumHeldDistance'],routeHighestHeld=s['highestHeld']['movement'],
            beams=[dict(objective=b['objective'],tested=b['testedBranches'],closest=summarize(b['closest'])['closestHeld']['movement'],
                highest=summarize(b['closest'])['highestHeld']['movement'])for b in beams if b['sourceTrial']==index])),flush=True)
    selected=[]
    for label,index,t in choices:
        g,o,seed=make_seed(args.capture,source,index)
        assert snap(g,o,0)==t['samples'][0]
        for n,(pad,expected)in enumerate(zip(t['inputs'],t['samples'][1:])):
            advance(g,pad);assert snap(g,o,n+1)==expected
        selected.append(dict(label=label,sourceTrial=index,fullControllerPrefix=seed['fullControllerPrefix'],
            **t,summary=summarize(t),freshReplay=dict(passed=True,comparedSnapshots=len(t['samples']),
                gameplayEdits=[],prefixInputCount=len(seed['fullControllerPrefix']))))
    route_summaries=[t['summary']for t in trials]
    counts=dict(routePolicies=len(trials),distinctSeededRouteInputs=len({(t['sourceTrial'],ihash(t['inputs']))for t in trials}),
        routeUpdates=sum(len(t['inputs'])for t in trials),beams=len(beams),
        evaluatedBeamBranches=sum(b['testedBranches']for b in beams),
        evaluatedBeamUpdates=sum(sum(b['evaluatedActionSamples'].values())for b in beams),
        beamNativeUpdatesIncludingRetainedReconstruction=sum(b['nativeUpdatesIncludingRetainedReconstruction']for b in beams),
        highestHeldY=max([s['highestHeld']['movement'][1]for s in route_summaries]+[b['sampledHighestHeld']['movement'][1]for b in beams]),
        minimumHeldPyramidDistance=min([s['minimumHeldDistance']for s in route_summaries]+[distance(b['sampledClosestHeld'])for b in beams]),
        maximumPillars=max([s['maximumPillars']for s in route_summaries]+[b['maximumPillars']for b in beams]),
        spinningTopSamples=sum(s['spinningTopSamples']for s in route_summaries)+sum(b['spinningTopSamples']for b in beams),
        highCrawlSamples=sum(s['highCrawlSamples']for s in route_summaries)+sum(b['highCrawlSamples']for b in beams),
        freshReplayRuns=len(selected),freshReplaySnapshots=sum(t['freshReplay']['comparedSnapshots']for t in selected),
        distinctFreshReplayFullInputs=len({ihash(t['fullControllerPrefix']+t['inputs'])for t in selected}))
    return dict(schema=1,scope=__doc__,baseCommit='b53d39e5277919dc35e53a94e767d2d58bfd323e',
        baselineSha256=sha(args.capture),runtimeSha256=sha('build/wafel-pilot/sm64_jp.dll'),scriptSha256=sha(__file__),
        sourceReport=dict(path=str(args.source).replace('\\','/'),sha256=sha(args.source)),
        helperSha256={n:sha(Path(__file__).with_name(n))for n in ('replay.py','ink_box_delivery.py','ink_clean_handsfree.py','ink_floorless_warp.py')},
        gameplayEdits=[],preEntrySetup='create_game sets gDebugLevelSelect=1 before level entry',
        bounds=dict(routeHorizon=700,routeReleaseTail=12,routeWaypointRadius=250,beamHorizon=360,beamBlock=4,
            beamWidths=dict(distance=12,height=12,momentum=24),beamMenuSize=14,
            beamMenu='Toward pyramid; velocity-relative offsets -67.5,-45,-22.5,0,22.5,45,67.5 degrees; four cardinal headings; north with B only in FREEFALL; east with Z released then held. Other entries hold Z.'),
        seeds=seeds,trials=trials,beams=beams,selected=selected,summary=counts)


def compact(raw,path):
    return {**{k:v for k,v in raw.items()if k not in ('trials','beams','selected')},
        'rawReportName':str(path).replace('\\','/'),'rawReportSha256':sha(path),
        'trials':[dict(sourceTrial=t['sourceTrial'],**t['summary'])for t in raw['trials']],
        'beams':[{**{k:v for k,v in b.items()if k not in ('closest','last','highest')},
            'closestSummary':summarize(b['closest']),'lastSummary':summarize(b['last']),
            'highestSummary':summarize(b['highest'])}for b in raw['beams']],
        'selected':[{**{k:v for k,v in t.items()if k!='samples'},
            'samplesAtEvents':[e['sample']for e in t['events']],'final':t['samples'][-1]}for t in raw['selected']]}


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('source',type=Path)
    p.add_argument('output',type=Path);p.add_argument('--receipt',type=Path,required=True);p.add_argument('--skip-beams',action='store_true');a=p.parse_args()
    raw=run(a)
    with a.output.open('x',encoding='utf-8',newline='\n')as f:json.dump(raw,f,indent=2,allow_nan=False);f.write('\n')
    with a.receipt.open('x',encoding='utf-8',newline='\n')as f:json.dump(compact(raw,a.output),f,indent=2,allow_nan=False);f.write('\n')
