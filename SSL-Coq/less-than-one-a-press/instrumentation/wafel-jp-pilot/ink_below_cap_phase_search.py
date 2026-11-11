"""Bounded position/phase search for a below-cap crawl gap and useful Ink.

Every producer starts with synchronized Mario positions and a supplied crawl
and native actor placement. No floor, timer, RNG, platform or later position
is patched. A positive result requires native next-update top capture and a
continuous first Area-2 arrival outside the elevator. No clean route follows.
"""
import argparse
from collections import Counter
import hashlib
import itertools
import json
import math
from pathlib import Path
import sys

sys.path.insert(0,str(Path(__file__).resolve().parent))
from ink_floorless_warp import reach_after_pillars, NEUTRAL, set_input
from ink_low_fixture_producers import advance, events, digest, cap_box, clear_box
from ink_crawl_predecessors import f32
from replay import RUNTIME

CRAWL=0x04008448
SEEDS=[[float(x),float(z)] for x in (-2132,-2048,-1964)
       for z in (-1108,-1024,-940)] + [[-1950.,-939.]]
ACTORS={'box':(49,'bhvJumpingBox'), 'bobomb':(39,'bhvBobomb')}
LOWER_PHASES=[0,40,59,60,80,96,112,122,130,149]


def geometry(g,index):
    faces=[];bottoms=[]
    for i in range(g.read('gNumStaticSurfaces'),g.read('gSurfacesAllocated')):
        p='sSurfacePool[%d].'%i
        if g.read(p+'object')!=g.address('gObjectPool[61]'):continue
        vs=[g.read(p+'vertex%d'%k) for k in (1,2,3)]
        n=g.read(p+'normal')
        faces.append(dict(vertices=vs,normal=n,offset=g.read(p+'originOffset')))
        bottoms.extend(v[1] for v in vs)
    assert len(faces)==6
    return dict(index=index,storedTimer=g.read('gObjectPool[61].oTimer'),
                action=g.read('gObjectPool[61].oAction'),bottom=min(bottoms),
                origin=[g.read('gObjectPool[61].oPos'+a) for a in 'XYZ'],
                angularVelocity=g.read('gObjectPool[61].oAngleVelYaw'),faces=faces,
                capBox=cap_box(g))


def prepare(capture):
    g,o=reach_after_pillars(capture);states={};geo=[]
    while not (g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==0):
        advance(g,NEUTRAL)
    for p in range(152):
        if p<150:states[p]=g.save_state()
        geo.append(geometry(g,p))
        if p<151:advance(g,NEUTRAL)
    assert geo[150]['action']==1 and geo[150]['storedTimer']==150
    assert geo[151]['action']==2
    return g,o,states,geo


def recipe_stream(geo):
    for p in range(150):
        offsets=[101,141] if p in LOWER_PHASES else [101]
        for seed,angle,kind,push,offset in itertools.product(range(len(SEEDS)),range(8),ACTORS,(40.,68.),offsets):
            # One unit below the 100-unit body clearance at BOTH old and prepared meshes.
            y=min(geo[p]['bottom'],geo[p+1]['bottom'])-offset
            yield dict(phase=p,seed=seed,angle=angle,actor=kind,push=push,height=float(y),offset=offset)


def read(g,o):
    return dict(level=g.read('gCurrLevelNum'),area=g.read('gCurrAreaIndex'),
                movement=g.read('gMarioState.pos'),display=g.read('gMarioObject.header.gfx.pos'),
                collision=[g.read('gMarioObject.oPos'+a) for a in 'XYZ'],
                action=g.read('gMarioState.action'),floor=g.read('gMarioState.floorHeight'),
                floorOwner=o.slot(g.read('gMarioState.floor?.object')),
                floorNull=g.read('gMarioState.floor').is_null(),platform=o.slot(g.read('gMarioPlatform')),
                used=o.slot(g.read('gMarioState.usedObj')),hitbox=g.read('gMarioObject.hitboxHeight'),
                depth=g.read('gMarioState.quicksandDepth'))


def begin(g,o,state,r):
    g.load_state(state);x,z=SEEDS[r['seed']];y=r['height'];pos=[x,y,z]
    slot,beh=ACTORS[r['actor']];p='gObjectPool[%d].'%slot
    assert g.read(p+'behavior')==g.address(beh) and g.read(p+'activeFlags')
    radius=g.read(p+'hitboxRadius')+g.read('gMarioObject.hitboxRadius')-5.
    separation=radius-r['push'];assert separation>0
    angle=r['angle']*math.pi/4
    actor=[x-math.sin(angle)*separation,y,z-math.cos(angle)*separation]
    writes=[]
    def put(path,v):
        writes.append(dict(path=path,before=g.read(path),after=v));g.write(path,v)
    put('gMarioState.pos',pos);put('gMarioObject.header.gfx.pos',pos)
    for ax,v in zip('XYZ',pos):put('gMarioObject.oPos'+ax,v)
    for field,v in [('action',CRAWL),('actionState',0),('actionTimer',0),
                    ('forwardVel',0.),('vel',[0.,0.,0.]),('faceAngle',[0,208,0])]:put('gMarioState.'+field,v)
    put('gMarioObject.hitboxHeight',100.)
    for ax,v in zip('XYZ',actor):put(p+'oPos'+ax,v)
    for field in ('oForwardVel','oVelX','oVelY','oVelZ'):put(p+field,0.)
    initial=read(g,o);assert initial['movement']==initial['display']==initial['collision']
    return initial,writes,radius,actor


def top_floor(geom,x,z):
    """Native-plane calculation for proposal ranking, not a hooked floor call."""
    x,z=int(x),int(z);hits=[]
    for s in geom['faces']:
        n=s['normal'];v=s['vertices']
        if n['y']<=.01:continue
        if any((a[2]-z)*(b[0]-a[0])-(a[0]-x)*(b[2]-a[2])<0
               for a,b in zip(v,v[1:]+v[:1])):continue
        height=f32(-f32(f32(f32(n['x']*x)+f32(n['z']*z))+s['offset'])/n['y'])
        hits.append(height)
    return min(hits) if hits else None


def case(g,o,state,r,geo,finish=False,full=False):
    initial,writes,radius,actor=begin(g,o,state,r)
    b0=cap_box(g);advance(g,dict(buttons=0x2000,stick=[0,64]))
    a=read(g,o);ev=events(g);b1=cap_box(g)
    assert b0==geo[r['phase']]['capBox'] and b1==geo[r['phase']+1]['capBox']
    entries=[e['pos'] for e in ev if e['type']=='FLT_EXECUTE_ACTION']
    clear=(clear_box(initial['movement'],100.,b0) and
           all(clear_box(p,100.,b1) for p in entries) and clear_box(a['movement'],a['hitbox'],b1))
    gap=a['display'][1]-a['movement'][1]
    advance(g,NEUTRAL);n=read(g,o);ev2=events(g)
    captured=n['used']==64 and n['floorOwner']==61 and n['platform']==61
    samples=[initial,a,n];logs=[ev,ev2];arrival=None
    if captured or finish:
        for _ in range(30):
            if samples[-1]['area']==2:
                arrival=samples[-1];break
            if samples[-1]['area']!=1 or samples[-1]['level']!=8:break
            advance(g,NEUTRAL);samples.append(read(g,o));logs.append(events(g))
    outside=arrival is not None and not (-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717)
    h=top_floor(geo[r['phase']+2],a['display'][0],a['display'][2])
    margin=None if h is None else f32(h-78.)-int(a['display'][1])
    near=math.hypot(a['movement'][0]+2048,a['movement'][2]+1024)<187
    relevant=(clear and gap>0 and a['movement'][1]<=818 and near and a['movement']==a['collision'])
    result=dict(recipe=r,after=a,next=n,gap=gap,bodyClear=clear,nearWarp=near,
                relevantLowSplit=relevant,capturedTop=captured,outsideElevator=outside,
                validUseful=clear and captured and outside,topPlaneHeight=h,retryHeightShortfall=margin,
                updates=len(samples)-1,historyDigest=digest([samples,logs]),
                startRadius=radius,actorPosition=actor)
    if full:result.update(initial=initial,writes=writes,capBefore=b0,capPrepared=b1,
                          firstEvents=ev,samples=samples,events=logs,firstArea2=arrival)
    return result


def footprint_checks(geo):
    pad=[[-2149.,-1125.],[-2149.,-921.],[-1945.,-1125.],[-1945.,-921.]]
    margins=[]
    for g in geo:
        points=set(tuple(v[a] for a in (0,2)) for s in g['faces'] for v in s['vertices'] if v[1]==g['bottom'])
        cx=sum(p[0] for p in points)/len(points);cz=sum(p[1] for p in points)/len(points)
        ps=sorted(points,key=lambda p:math.atan2(p[1]-cz,p[0]-cx))
        distances=[]
        for p in pad:
            for a,b in zip(ps,ps[1:]+ps[:1]):
                cross=(b[0]-a[0])*(p[1]-a[1])-(b[1]-a[1])*(p[0]-a[0])
                distances.append(cross/math.hypot(b[0]-a[0],b[1]-a[1]))
        margins.append(min(distances))
    return dict(padCorners=pad,minCornerDistanceToCapEdge=min(margins),
                allPadPlusRadius37Inside=all(m>37 for m in margins),perMeshMinimum=margins,
                scope='Calculation from loaded integer base polygons; not a Coq geometric coverage theorem')


def run(capture):
    g,o,states,geo=prepare(capture)
    controls=[]
    for name,seed,angle,height in [('inside-973-positive',9,2,1741.),('below-632-roof',1,6,1400.)]:
        r=dict(phase=130,seed=seed,angle=angle,actor='box',push=68.,height=height,offset=None)
        c=case(g,o,states[130],r,geo,finish=True,full=True);c['name']=name;controls.append(c)
    assert controls[0]['capturedTop'] and controls[0]['outsideElevator'] and not controls[0]['bodyClear']
    assert controls[1]['gap']==632 and controls[1]['bodyClear'] and not controls[1]['capturedTop']
    rows=[];phase_counts={};best=[]
    for idx,r in enumerate(recipe_stream(geo)):
        q=case(g,o,states[r['phase']],r,geo);rows.append(q)
        if q['relevantLowSplit'] and q['retryHeightShortfall'] is not None:
            best.append((q['retryHeightShortfall'],idx))
        if (idx+1)%10000==0:print(json.dumps(dict(completed=idx+1,phase=r['phase'])),flush=True)
    for p in range(150):
        rs=[r for r in rows if r['recipe']['phase']==p]
        phase_counts[p]=dict(trials=len(rs),bodyClear=sum(r['bodyClear'] for r in rs),
                            positiveGaps=sum(r['gap']>0 for r in rs),
                            relevantLowSplits=sum(r['relevantLowSplit'] for r in rs),
                            rawCaptures=sum(r['capturedTop'] for r in rs),
                            useful=sum(r['validUseful'] for r in rs),
                            maxGap=max(r['gap'] for r in rs))
    # Retain closest retry-height misses, one per phase, plus the largest gap.
    selected=[];seen=set()
    for _,i in sorted(best):
        p=rows[i]['recipe']['phase']
        if p not in seen:selected.append(i);seen.add(p)
        if len(selected)==12:break
    if best:selected.append(max((i for _,i in best),key=lambda i:rows[i]['gap']))
    selected=sorted(set(selected))
    retained=[dict(index=i,result=case(g,o,states[rows[i]['recipe']['phase']],rows[i]['recipe'],geo,finish=True,full=True)) for i in selected]
    fresh,fo,fs,fg=prepare(capture);assert fg==geo
    fresh_checks=[]
    for c in controls:
        repeat=case(fresh,fo,fs[130],c['recipe'],fg,finish=True,full=True)
        assert repeat=={k:v for k,v in c.items() if k!='name'}
        fresh_checks.append(dict(kind='control',name=c['name'],updates=repeat['updates'],matched=True))
    for r in retained:
        v=r['result'];repeat=case(fresh,fo,fs[v['recipe']['phase']],v['recipe'],fg,finish=True,full=True)
        assert repeat==v
        fresh_checks.append(dict(kind='retained',index=r['index'],updates=v['updates'],matched=True))
    summary=dict(trials=len(rows),updates=sum(r['updates'] for r in rows),
                 bodyClear=sum(r['bodyClear'] for r in rows),bodyScreenRejected=sum(not r['bodyClear'] for r in rows),
                 positiveGaps=sum(r['gap']>0 for r in rows),
                 relevantLowSplits=sum(r['relevantLowSplit'] for r in rows),
                 rawTopCaptures=sum(r['capturedTop'] for r in rows),
                 validTopCaptures=sum(r['bodyClear'] and r['capturedTop'] for r in rows),
                 validUseful=sum(r['validUseful'] for r in rows),
                 maxRelevantGap=max((r['gap'] for r in rows if r['relevantLowSplit']),default=None),
                 minimumRetryShortfall=min((r['retryHeightShortfall'] for r in rows if r['relevantLowSplit'] and r['retryHeightShortfall'] is not None),default=None),
                 freshReplayCases=len(fresh_checks),freshReplayUpdates=sum(r['updates'] for r in fresh_checks))
    motion=dict(maxTwoUpdateDrop=max(geo[i]['bottom']-geo[i+2]['bottom'] for i in range(150)),
                maximumOneUpdateDrop=max(geo[i]['bottom']-geo[i+1]['bottom'] for i in range(151)),
                minTwoUpdateFloorMinusBodyBuffer=min(geo[i+2]['bottom']-(min(geo[i]['bottom'],geo[i+1]['bottom'])-100+78) for i in range(150)))
    source=Path(__file__);root=source.resolve().parents[2]
    return dict(schema=1,scope='Finite supplied-crawl, supplied-actor producers; synchronized initial positions; no clean controller route or all-history exclusion',
                summary=summary,seeds=SEEDS,lowerPhases=LOWER_PHASES,phaseCounts=phase_counts,
                geometry=geo,motion=motion,footprint=footprint_checks(geo),controls=controls,
                retained=retained,freshChecks=fresh_checks,rows=rows,
                inputPolicy='Z+(0,64) producer update, then neutral; zero A inputs',
                screen='Strict radius37/100hitbox separation from loaded cap AABBs at initial and first-update action/end checkpoints; no internal-write trace',
                observationLimit='Native action events and end-update state; plane heights are calculations, not floor-query hooks',
                sourceSha256=hashlib.sha256(source.read_bytes()).hexdigest(),
                runtimeSha256=hashlib.sha256((RUNTIME/'sm64_jp.dll').read_bytes()).hexdigest(),
                captureSha256=hashlib.sha256(capture.read_bytes()).hexdigest())


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path)
    p.add_argument('output',type=Path);p.add_argument('--receipt',type=Path);a=p.parse_args()
    r=run(a.capture)
    with a.output.open('x',encoding='utf8') as f:json.dump(r,f,separators=(',',':'));f.write('\n')
    if a.receipt:
        c={k:v for k,v in r.items() if k!='rows'};c['rawSha256']=hashlib.sha256(a.output.read_bytes()).hexdigest()
        c['rowsDigest']=digest(r['rows'])
        with a.receipt.open('x',encoding='utf8') as f:json.dump(c,f,indent=2);f.write('\n')
    print(json.dumps(dict(summary=r['summary'],motion=r['motion'],minPadMargin=r['footprint']['minCornerDistanceToCapEdge']),indent=2))


if __name__=='__main__':main()
