"""Shell-created supported slide, then an actor-only producer cut at phase130.

Initial airborne Mario and shell are supplied; no Mario writes follow.
Native shell cancellation, top alignment, carry and slide updates run normally.
The box placement is a separate declared actor cut, not delivered gameplay.
"""
import argparse,json,sys,math,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from ink_floorless_warp import reach_after_pillars,NEUTRAL
from ink_slide_handoff import advance,rich_sample
from ink_crawl_predecessors import pose,write,f32
from ink_timer130_crawl import frame_events
from ink_pu_vpu import digest

class Guard:
    def __init__(self,g):self.g=g;self.mode='controls'
    def __getattr__(self,k):return getattr(self.g,k)
    def write(self,path,value):
        if self.mode=='controls':assert path in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},path
        if self.mode=='actor':assert path in {'gObjectPool[49].oPosX','gObjectPool[49].oPosY','gObjectPool[49].oPosZ'},path
        self.g.write(path,value)

def roots(capture):
    g,o=reach_after_pillars(capture);g=Guard(g)
    while not(g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==125):advance(g,NEUTRAL)
    g.mode='setup';prep=[];write(g,'gObjectPool[32].oAction',4,prep);g.mode='controls'
    advance(g,NEUTRAL);advance(g,NEUTRAL)
    shells=[i for i in range(240) if g.read(f'gObjectPool[{i}].activeFlags') and g.read(f'gObjectPool[{i}].behavior')==g.address('bhvKoopaShell')]
    assert len(shells)==1;states={127:g.save_state()}
    for phase in [128,129]:advance(g,NEUTRAL);states[phase]=g.save_state()
    return g,o,states,shells[0],dict(edits=prep,controls=[NEUTRAL,NEUTRAL],slot=shells[0])

def prepare(g,o,base,slot,r,full=False):
    g.load_state(base);g.mode='setup';edits=[];x,y,z=r['pos'];pose(g,[x,y,z],edits)
    yaw=r['yaw'];speed=r['speed'];a=yaw*math.tau/65536
    for k,v in [('action',g.constant('ACT_FREEFALL')),('actionState',0),('actionTimer',0),('forwardVel',speed),('vel',[f32(speed*math.sin(a)),-16,f32(speed*math.cos(a))]),('faceAngle',[0,yaw if yaw<32768 else yaw-65536,0])]:write(g,'gMarioState.'+k,v,edits)
    for a,v in zip('XYZ',[x,y-10,z]):write(g,f'gObjectPool[{slot}].oPos'+a,v,edits)
    g.mode='controls';initial=rich_sample(g,o) if full else None;rows=[];events=[];pads=[];i=0
    while g.read('gObjectPool[61].oTimer')<130:
        pad=dict(buttons=0x2000,stick=[0,0]) if i==0 else NEUTRAL
        advance(g,pad);i+=1
        if full:rows.append(rich_sample(g,o));events.append(frame_events(g));pads.append(pad)
    return dict(edits=edits,initial=initial,samples=rows,events=events,controls=pads)

def full_trial(g,o,base,slot,r,box):
    t=prepare(g,o,base,slot,r,True);t.update(recipe=r,boxAt130=box,prepared=rich_sample(g,o));g.mode='actor';actorEdits=[]
    for a,v in zip('XYZ',box):write(g,'gObjectPool[49].oPos'+a,v,actorEdits)
    t['actorEdits']=actorEdits;g.mode='controls';following=[]
    for i in range(34):
        advance(g,NEUTRAL);s=rich_sample(g,o);following.append(s);t['samples'].append(s);t['events'].append(frame_events(g));t['controls'].append(NEUTRAL)
        if s['area']!=1:break
    t['following']=following;t['capture']=any(s['floorOwner']==s['platform']==61 and s['used']==64 for s in following)
    end=next((s for s in following if s['area']==2),None);t['useful']=end is not None and not(-460<=end['movement'][0]<=461 and -204<=end['movement'][2]<=717)
    return t

def main():
    p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('output',type=Path);a=p.parse_args();g,o,states,slot,prep=roots(a.capture)
    eligible={g.constant(x) for x in ['ACT_BUTT_SLIDE','ACT_STOMACH_SLIDE','ACT_CROUCH_SLIDE','ACT_DIVE_SLIDE','ACT_WALKING']}
    seeds=prepared=boxTrials=0;outcomes=[];best=[];bestscore=None;start=time.time()
    targets=[(x,z) for x in [-1890,-1882,-1874] for z in [-970,-939,-925]]
    for phase in [127,128,129]:
      for x in range(-2240,-1759,20):
       for z in range(-1260,-779,20):
        for yaw in [0,16384,32768,49152]:
          r=dict(phase=phase,pos=[x,21700,z],yaw=yaw,speed=20);prepare(g,o,states[phase],slot,r);seeds+=1
          if g.read('gMarioState.action') not in eligible:continue
          p0=g.read('gMarioState.pos')
          if not 1700<=p0[1]<=2000:continue
          prepared+=1;state=g.save_state();collision=[g.read('gMarioObject.oPos'+a) for a in 'XYZ'];advance(g,NEUTRAL)
          ev=[e for e in frame_events(g) if e['type']=='FLT_EXECUTE_ACTION']
          if not ev:continue
          p1=ev[0]['pos']
          for tx,tz in targets:
            vx,vz=tx-p1[0],tz-p1[2];d=math.hypot(vx,vz)
            if not 1<=d<=106.5:continue
            box=[f32(tx-107*vx/d),p0[1],f32(tz-107*vz/d)]
            if math.hypot(box[0]-collision[0],box[2]-collision[2])>=112:continue
            g.load_state(state);g.mode='actor'
            for axis,v in zip('XYZ',box):g.write('gObjectPool[49].oPos'+axis,v)
            g.mode='controls';advance(g,NEUTRAL);producer=rich_sample(g,o);advance(g,NEUTRAL);accept=rich_sample(g,o);boxTrials+=1
            gap=producer['display'][1]-producer['movement'][1];cap=int(accept['used']==64 and accept['platform']==61)
            sc=(cap,int(producer['floorY']==768 and gap>800),-abs(producer['movement'][1]-768),-math.hypot(producer['movement'][0]+1882,producer['movement'][2]+939))
            if cap or sc[1]:outcomes.append(dict(recipe=r,box=box,producer=producer,accept=accept))
            if bestscore is None or sc>bestscore:bestscore=sc;best=[dict(recipe=r,box=box,score=sc)];print('BEST',best[-1],flush=True)
            elif sc==bestscore and len(best)<4:best.append(dict(recipe=r,box=box,score=sc))
          if boxTrials and boxTrials%5000==0:print('PROGRESS',seeds,prepared,boxTrials,time.time()-start,flush=True)
      print('PHASE',phase,'seeds',seeds,'prepared',prepared,'boxTrials',boxTrials,'elapsed',time.time()-start,flush=True)
    details=[full_trial(g,o,states[b['recipe']['phase']],slot,b['recipe'],b['box']) for b in best]
    q,qo,qs,qslot,qprep=roots(a.capture);assert qprep==prep
    for t in details:assert full_trial(q,qo,qs[t['recipe']['phase']],qslot,t['recipe'],t['boxAt130'])==t
    result=dict(schema=1,date='2026-11-14',scope=__doc__,scriptSha256=digest(__file__),prefixSha256=digest(a.capture),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),shellPreparation=prep,menu=dict(phases=[127,128,129],initialY=21700,x=[-2240,-1760,20],z=[-1260,-780,20],yaw=[0,16384,32768,49152],speed=20,targetXZ=targets),counts=dict(initialAirSeeds=seeds,eligibleNativePreparations=prepared,actorCuts=boxTrials,lowGapCases=sum(x['producer']['floorY']==768 and x['producer']['display'][1]-x['producer']['movement'][1]>800 for x in outcomes),captureCases=sum(x['accept']['used']==64 and x['accept']['platform']==61 for x in outcomes)),outcomes=outcomes,best=best,trials=details,verifiedFreshBoundaries=sum(len(t['samples']) for t in details),elapsed=time.time()-start)
    with a.output.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print(json.dumps(result['counts'],indent=2));print('FULL',[(t['capture'],t['useful']) for t in details],flush=True)

if __name__=='__main__':main()
