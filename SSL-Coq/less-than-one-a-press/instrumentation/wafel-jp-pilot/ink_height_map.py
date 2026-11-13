"""Finite, supplied-state height survey; never a controller reachability claim.

Each trial restores a native prefix state and makes only its recorded initial
pose/action/velocity and actor-position edits. Subsequent updates are pads only.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import struct
import sys
import time

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ink_floorless_warp import reach_after_pillars, NEUTRAL, set_input
from ink_crawl_predecessors import pose, write
from ink_pu_vpu import sample, frame_events

ACTIONS={'crawl':0x04008448,'butt':0x00840452,'stomach':0x008c0453,
         'crouch':0x04808459,'dive':0x00880456,'kick':0x0080045a}
CAPTURE=Path('build/wafel-pilot/capture.bKv95w/inputs.jsonl')

def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def f32(x):return struct.unpack('<f',struct.pack('<f',x))[0]
def bits(x):return struct.unpack('<I',struct.pack('<f',x))[0]
def frombits(x):return struct.unpack('<f',struct.pack('<I',x))[0]

def advance(g,pad):
    assert not pad['buttons']&0x8000
    before=g.read('gGlobalTimer');set_input(g,pad);g.advance()
    assert g.read('gGlobalTimer')==before+1
    assert not g.read('gMarioState.input')&0x82

def prepare(phases):
    g,o=reach_after_pillars(CAPTURE);states={}
    for _ in range(190):
        if g.read('gObjectPool[61].oAction')==1:
            p=g.read('gObjectPool[61].oTimer')
            if p in phases:states[p]=g.save_state()
        if len(states)==len(phases):return g,o,states
        advance(g,NEUTRAL)
    raise RuntimeError('phases missing')

def read(g,o):
    m=g.read('gMarioState.pos');d=g.read('gMarioObject.header.gfx.pos')
    return dict(M=m,D=d,C=[g.read('gMarioObject.oPos'+a) for a in 'XYZ'],
        action=g.read('gMarioState.action'),actionArg=g.read('gMarioState.actionArg'),floorY=g.read('gMarioState.floorHeight'),
        floorOwner=o.slot(g.read('gMarioState.floor?.object')),
        platform=o.slot(g.read('gMarioPlatform')),used=o.slot(g.read('gMarioState.usedObj')),
        area=g.read('gCurrAreaIndex'),warpOp=g.read('sDelayedWarpOp'),
        ceilingY=g.read('gMarioState.ceilHeight'),gap=d[1]-m[1])

def trial(g,o,state,r,full=False,finish=True):
    g.load_state(state);edits=[]
    y=f32(r['y']);x=r.get('x',-1950.);z=r.get('z',-939.)
    pose(g,[x,y,z],edits)
    slide=r['action']!='crawl';speed=r.get('speed',20. if slide else 5.)
    for field,value in [('action',ACTIONS[r['action']]),('actionState',0),
        ('actionTimer',0),('forwardVel',speed),('vel',[speed if slide else 4.,0.,0.]),
        ('faceAngle',[0,0x4000,0])]:write(g,'gMarioState.'+field,value,edits)
    if slide:
        for field,value in [('slideVelX',speed),('slideVelZ',0.),('slideYaw',0x4000)]:
            write(g,'gMarioState.'+field,value,edits)
    if r.get('actor',True):
        angle=math.radians(r.get('pushAngle',90.));sep=r.get('separation',39.)
        for axis,value in zip('XYZ',[x-math.sin(angle)*sep,y+r.get('actorDy',0.),z-math.cos(angle)*sep]):
            write(g,'gObjectPool[49].oPos'+axis,value,edits)
    if r.get('cache') is not None:
        raise ValueError('Cache overwrites intentionally unsupported')
    initial=sample(g,o) if full else None
    controls=[];samples=[];logs=[];rows=[]
    for i in range(32 if finish else 2):
        pad=dict(buttons=0x2000,stick=[0,64]) if i==0 else NEUTRAL
        advance(g,pad);q=read(g,o);rows.append(q)
        if full:controls.append(pad);samples.append(sample(g,o));logs.append(frame_events(g))
        if q['area']!=1:break
        if i==1 and not r.get('finishAll',False) and not(q['used']==64 and q['platform']==61 and q['floorOwner']==61):break
    after,nxt=rows[0],rows[min(1,len(rows)-1)]
    capture=(nxt['used']==64 and nxt['platform']==61 and nxt['floorOwner']==61
             and nxt['action']==0x1300 and nxt['actionArg']==0x40001)
    arrival=next((q for q in rows if q['area']==2),None)
    useful=(capture and arrival is not None and arrival['M'][1]==5500.
            and not(-460<=arrival['M'][0]<=461 and -204<=arrival['M'][2]<=717))
    result=dict(recipe=r,actualStartY=y,aliasedY=((math.trunc(y)+32768)%65536)-32768,
        after=after,next=nxt,capture=capture,useful=useful,arrival=arrival,
        updates=len(rows),retainedUntilAreaChange=capture and all(q['platform']==61 for q in rows[1:] if q['area']==1))
    if full:result.update(edits=edits,initial=initial,controls=controls,samples=samples,events=logs)
    if r.get('finishAll',False):
        result['laterTopCaptureIndices']=[i for i,q in enumerate(rows) if i>1 and q['used']==64 and q['platform']==61 and q['floorOwner']==61 and q['action']==0x1300 and q['actionArg']==0x40001]
        result['actualArea2Outside']=arrival is not None and not(-460<=arrival['M'][0]<=461 and -204<=arrival['M'][2]<=717)
    return result

def runs(rows,key='useful'):
    out=[]
    for q in rows:
        y=q['actualStartY'];value=q[key]
        if out and out[-1]['value']==value and out[-1]['last']+1==y:
            out[-1]['last']=y;out[-1]['count']+=1
        else:out.append(dict(first=y,last=y,value=value,count=1))
    return out

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('output',type=Path);p.add_argument('--mode',choices=['pilot','integer','vpu','variation','refine','replay','lateral','radial','radial-dense','recipes'],default='pilot')
    p.add_argument('--actions',default='crawl,butt');p.add_argument('--input',type=Path)
    p.add_argument('--first',type=int,default=-32768);p.add_argument('--last',type=int,default=32767)
    a=p.parse_args();assert not a.output.exists()
    phases={130} if a.mode!='variation' else {96,112,120,124,128,129,130,131,132,136,140,144,148}
    if a.mode=='replay':
        data=json.loads(a.input.read_text());recipes=[q['recipe'] for q in data['retained']];phases={r['phase'] for r in recipes}
    else:recipes=[]
    if a.mode in ('refine','recipes'):
        data=json.loads(a.input.read_text());recipes=data['recipes'];phases={r['phase'] for r in recipes}
    g,o,states=prepare(phases);actions=a.actions.split(',')
    if a.mode in ('pilot','integer'):
        ys=list(range(a.first,a.last+1,256 if a.mode=='pilot' else 1))
        if a.mode=='pilot':ys=sorted(set(ys+[688,689,690,768,1201,1202,1280,1380,1400,1500,1600,1700,1740,1741,1742,1800,2000,19839,19840,19841,21000,32767]))
        recipes=[dict(action=act,phase=130,y=y) for act in actions for y in ys]
    if a.mode=='vpu':
        ys=[-32768,-32767,-11001,-1,0,689,690,768,1201,1202,1280,1380,1400,1500,1600,1700,1740,1741,1742,1800,2000,4096,8192,16384,19839,19840,19841,21000,32766,32767,32768]
        recipes=[dict(action=act,phase=130,y=y+65536*k,offset=k*65536,baseY=y) for act in actions for k in [-2,-1,0,1,2,8,128] for y in ys]
    if a.mode=='variation':
        recipes=[dict(action=act,phase=phase,y=y,x=x,z=z,separation=sep)
            for act in actions for phase in sorted(phases)
            for x,z in [(-1950,-939),(-1950,-1024),(-1950,-1100),(-1964,-940)]
            for sep in [19.,39.,59.] for y in range(1200,2201,20)]
    if a.mode=='lateral':
        recipes=[dict(action=act,phase=130,y=1740.,x=x,z=z,separation=sep,pushAngle=angle)
            for act in actions for x in [-2148,-2114,-2080,-2046,-2012,-1978,-1946]
            for z in [-1124,-1090,-1056,-1022,-988,-954,-922]
            for sep in [9.,29.,49.,69.,89.] for angle in range(0,360,15)]
    if a.mode in ('radial','radial-dense'):
        dense=a.mode=='radial-dense'
        for act in actions:
            for deg in ([i/10 for i in range(3600)] if dense else range(360)):
                for radius in ([186.99,186.999,186.9999] if dense else [180.,185.,186.,186.9]):
                    tx=-2048+radius*math.sin(math.radians(deg));tz=-1024+radius*math.cos(math.radians(deg))
                    x=min(-1946.,max(-2148.,tx));z=min(-922.,max(-1124.,tz))
                    distance=math.hypot(tx-x,tz-z)
                    if distance<1 or distance>=107:continue
                    angle=math.degrees(math.atan2(tx-x,tz-z))
                    for y in ([1739.] if dense else [1680.,1700.,1720.,1740.]):
                        r=dict(action=act,phase=130,y=y,x=x,z=z,separation=107.-distance,pushAngle=angle)
                        if not dense:r['proposedTarget']=[tx,tz]
                        recipes.append(r)
    rows=[];retained=[];start=time.time()
    for i,r in enumerate(recipes):
        q=trial(g,o,states[r['phase']],r,full=a.mode in ('refine','replay'))
        rows.append(q)
        if a.mode in ('refine','replay'):retained.append(q)
        if (i+1)%2000==0:print(json.dumps(dict(done=i+1,total=len(recipes),seconds=time.time()-start,useful=sum(x['useful'] for x in rows))),flush=True)
    summaries={}
    for act in actions:
        rr=[q for q in rows if q['recipe']['action']==act];good=[q for q in rr if q['useful']]
        summaries[act]=dict(count=len(rr),useful=len(good),minY=min((q['actualStartY'] for q in good),default=None),maxY=max((q['actualStartY'] for q in good),default=None),maxGap=max((q['after']['gap'] for q in good),default=None))
        if a.mode=='integer':summaries[act]['runs']=runs(rr)
    if a.mode in ('pilot','vpu','variation'):
        for act in actions:
            rr=[q for q in rows if q['recipe']['action']==act];good=[q for q in rr if q['useful']]
            selected=([min(good,key=lambda q:q['actualStartY']),max(good,key=lambda q:q['actualStartY'])] if good else [])
            if a.mode=='vpu':
                selected += [q for q in rr if q['recipe']['baseY'] in (1740,1741,1742)]
            for q in selected:
                retained.append(trial(g,o,states[q['recipe']['phase']],q['recipe'],full=True))
    if a.mode=='replay':
        assert retained==data['retained'],'Fresh exact retained-trace mismatch'
    source=Path('../../../reference-sm64-decomp')
    sources={str(p):sha(source/p) for p in map(Path,['src/game/mario_actions_moving.c','src/game/mario_step.c','src/game/mario.c','src/engine/surface_collision.c','src/engine/surface_load.c','src/game/interaction.c'])}
    out=dict(schema=1,scope='Finite supplied states, no continuous controller route; fixed setup extrema only',mode=a.mode,
        recipeDescription='M=C=D=(x,Y,z); supplied action/state/timer/speed/velocity/yaw; slide velocities for slides; box49=(x-separation*sin(pushAngle),Y+actorDy,z-separation*cos(pushAngle)), default angle90; otherwise native; NO floor/cache/platform/mesh/timer/RNG writes. Z+(0,64) then neutral; A off.',
        scriptSha256=sha(__file__),runtimeSha256=sha('build/wafel-pilot/sm64_jp.dll'),prefixSha256=sha(CAPTURE),sourceSha256=sources,
        summaries=summaries,trials=len(rows),updates=sum(q['updates'] for q in rows),seconds=time.time()-start,rows=rows,retained=retained,
        observationLimit='Native end-update fields and stock frame events; alias is arithmetic inference; no floor-query or quarter-return hook')
    with a.output.open('x',encoding='utf8') as f:json.dump(out,f,separators=(',',':'));f.write('\n')
    print(json.dumps(summaries,indent=2),flush=True)

if __name__=='__main__':main()
