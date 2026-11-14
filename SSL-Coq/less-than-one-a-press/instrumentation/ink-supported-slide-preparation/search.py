"""Small exterior-freefall predecessors of late supported-slide Ink fragments.

Only the exterior initial Mario freefall pose/velocity/action is supplied.
After native preparation, one declared Crazy Box XYZ placement is allowed
before behavior129; there are no later Mario edits. This is not a full route.
"""
import argparse,json,math,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from ink_floorless_warp import reach_after_pillars,NEUTRAL
from ink_slide_handoff import advance,rich_sample
from ink_crawl_predecessors import pose,write,f32
from ink_crawl_top_entry import top_snapshot,upper_floor,floor_height,contains
from ink_timer130_crawl import frame_events
from ink_pu_vpu import digest

class Guard:
    """After the initial air cut permit controllers and the declared box cut."""
    def __init__(self,g):self.game=g;self.mode='controls'
    def __getattr__(self,k):return getattr(self.game,k)
    def write(self,path,value):
        if self.mode=='controls':
            assert path in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},path
        elif self.mode=='actor':
            assert path in {'gObjectPool[49].oPosX','gObjectPool[49].oPosY','gObjectPool[49].oPosZ'},path
        self.game.write(path,value)

def roots(capture):
    g,o=reach_after_pillars(capture);g=Guard(g);states={};meshes={}
    while g.read('gObjectPool[61].oAction')!=1 or g.read('gObjectPool[61].oTimer')<129:
        p=g.read('gObjectPool[61].oTimer')
        if g.read('gObjectPool[61].oAction')==1 and 125<=p<=128:
            states[p]=g.save_state();meshes[p]=top_snapshot(g)
        advance(g,NEUTRAL)
    return g,o,states,meshes

def apply(g,r):
    g.mode='initial';edits=[];pose(g,r['pos'],edits)
    a=r['yaw']*math.tau/65536;s=r['speed']
    for field,value in [('action',g.constant('ACT_FREEFALL')),('actionState',0),('actionTimer',0),
                        ('forwardVel',s),('vel',[f32(s*math.sin(a)),-16,f32(s*math.cos(a))]),
                        ('faceAngle',[0,r['yaw'] if r['yaw']<32768 else r['yaw']-65536,0])]:
        write(g,'gMarioState.'+field,value,edits)
    g.mode='controls';return edits

def run_one(g,o,base,r,box,full=False):
    g.load_state(base);edits=apply(g,r);rows=[];events=[];pads=[]
    initial=rich_sample(g,o) if full else None
    while g.read('gObjectPool[61].oTimer')<129:
        advance(g,NEUTRAL)
        if full:rows.append(rich_sample(g,o));events.append(frame_events(g));pads.append(NEUTRAL)
    prepared=rich_sample(g,o) if full else None
    if box is not None:
        g.mode='actor'
        for a,v in zip('XYZ',box):write(g,'gObjectPool[49].oPos'+a,v,edits)
        g.mode='controls'
    following=[]
    for _ in range(32 if full else 3):
        advance(g,NEUTRAL)
        if full:
            s=rich_sample(g,o);rows.append(s);events.append(frame_events(g));pads.append(NEUTRAL)
        else:
            s=dict(movement=g.read('gMarioState.pos'),display=g.read('gMarioObject.header.gfx.pos'),
                   action=g.read('gMarioState.action'),floorY=g.read('gMarioState.floorHeight'),
                   floorOwner=o.slot(g.read('gMarioState.floor?.object')),platform=o.slot(g.read('gMarioPlatform')),
                   used=o.slot(g.read('gMarioState.usedObj')),phase=g.read('gObjectPool[61].oTimer'))
        following.append(s)
        if g.read('gCurrAreaIndex')!=1:break
    return dict(recipe=r,boxAt129=box,edits=edits if full else None,initial=initial,prepared=prepared,
                controls=pads,samples=rows,events=events,following=following)

def run(capture):
    g,o,states,meshes=roots(capture);ground={g.constant(a) for a in ['ACT_WALKING','ACT_FREEFALL_LAND','ACT_BUTT_SLIDE','ACT_STOMACH_SLIDE','ACT_CROUCH_SLIDE','ACT_DIVE_SLIDE']}
    tested=0;prepared=0;gaps=0;capture_count=0;best=[];bestscore=None;t0=time.time()
    for phase in [128,127]:
      faces=meshes[phase]['faces']
      for x in range(-2050,-1699,20):
       for z in range(-1160,-799,20):
        fy=upper_floor(faces,x,z)
        if fy is None:continue
        actual=max((floor_height(f,x,z) for f in faces if f['normal']['y']>.01 and contains(f,x,z)),default=fy)
        for clearance in [1]:
         y=f32(max(fy,actual)+clearance)
         for yaw in [0,16384,32768,49152]:
          for speed in [20]:
            r=dict(phase=phase,pos=[x,y,z],yaw=yaw,speed=speed,feetClearance=y-actual)
            g.load_state(states[phase]);apply(g,r)
            while g.read('gObjectPool[61].oTimer')<129:advance(g,NEUTRAL)
            tested+=1
            if g.read('gMarioState.action') not in ground:continue
            if o.slot(g.read('gMarioState.floor?.object'))!=61:continue
            p=g.read('gMarioState.pos')
            if not 1700<=p[1]<=2000:continue
            prepared+=1
            # Observe native carry with the original box still remote.
            # Only actor coordinates will then be written at phase129.
            prepared_state=g.save_state();collision=[g.read('gMarioObject.oPos'+a) for a in 'XYZ']
            advance(g,NEUTRAL)
            action_events=[e for e in frame_events(g) if e['type']=='FLT_EXECUTE_ACTION']
            if not action_events:continue
            before_action=action_events[0]['pos']
            for qx,qz in [(-1946,-970),(-1950,-970),(-1946,-940),(-1946,-1000)]:
             vx,vz=qx-before_action[0],qz-before_action[2];distance=math.hypot(vx,vz)
             if not 1<=distance<=106.5:continue
             box=[f32(qx-107*vx/distance),p[1],f32(qz-107*vz/distance)]
             if math.hypot(box[0]-collision[0],box[2]-collision[2])>112:continue
             t=run_one(g,o,states[phase],r,box)
             a,b,c=t['following'];gap=b['display'][1]-b['movement'][1]
             captured=int(c['used']==64 and c['platform']==61)
             usefulgap=int(gap>800 and b['floorY']==768)
             gaps+=usefulgap;capture_count+=captured
             score=(captured,usefulgap,int(a['floorOwner']==61),-abs(b['movement'][1]-768),-math.dist([b['movement'][0],b['movement'][2]],[-1946,-970]))
             if bestscore is None or score>bestscore:
                bestscore=score;best=[dict(score=score,recipe=r,box=box)];print('BEST',best[-1],flush=True)
             elif score==bestscore and len(best)<4:best.append(dict(score=score,recipe=r,box=box))
    details=[]
    q,qo,qstates,qmeshes=roots(capture)
    for b in best:
        t=run_one(g,o,states[b['recipe']['phase']],b['recipe'],b['box'],True)
        assert t==run_one(q,qo,qstates[b['recipe']['phase']],b['recipe'],b['box'],True)
        details.append(t)
    return dict(schema=1,date='2026-11-14',scope=__doc__,scriptSha256=digest(__file__),baselineSha256=digest(capture),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),
                menus=dict(phases=[128,127],x=list(range(-2050,-1699,20)),z=list(range(-1160,-799,20)),clearance=[1],yaw=[0,16384,32768,49152],speed=[20],actorTargetXZ=[[-1946,-970],[-1950,-970],[-1946,-940],[-1946,-1000]],actorRule='107-radius push toward target from observed post-carry Mario position, only when pre-carry collision overlap and push distance allow it',controls='neutral until actor-only cut129 and afterward'),
                tested=tested,prepared=prepared,gaps=gaps,captures=capture_count,elapsed=time.time()-t0,best=best,trials=details,
                verifiedFreshTrials=len(details),verifiedFreshBoundaries=sum(len(t['samples']) for t in details))

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('output',type=Path);a=p.parse_args();r=run(a.capture)
    with a.output.open('x',encoding='utf-8') as f:json.dump(r,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps({k:r[k] for k in ['tested','prepared','gaps','captures','elapsed','best','verifiedFreshBoundaries']},indent=2))
