"""Targeted fixed-box predecessors from actual upper-face support (finite search)."""
import argparse,json,math,sys,hashlib,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from ink_floorless_warp import reach_after_pillars,NEUTRAL
from ink_slide_handoff import advance,rich_sample
from ink_crawl_predecessors import pose,write,f32
from ink_crawl_top_entry import top_snapshot,upper_floor
from ink_timer130_crawl import frame_events

def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()

class Guard:
    """Reject non-controller writes after the declared initial trial cut."""
    def __init__(self,game):self.game=game;self.setup=True
    def __getattr__(self,name):return getattr(self.game,name)
    def write(self,path,value):
        if not self.setup:
            assert path in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},path
        self.game.write(path,value)

def setup(g,recipe):
    edits=[];pose(g,recipe['pos'],edits)
    yaw=recipe['yaw'];speed=recipe['speed'];a=yaw*math.tau/65536
    for field,val in [('action',g.constant(recipe['action'])),('actionState',0),('actionTimer',0),('forwardVel',speed),('vel',[f32(math.sin(a)*speed),0,f32(math.cos(a)*speed)]),('faceAngle',[0,yaw if yaw<32768 else yaw-65536,0]),('slideVelX',f32(math.sin(a)*speed)),('slideVelZ',f32(math.cos(a)*speed)),('slideYaw',yaw if yaw<32768 else yaw-65536)]:write(g,'gMarioState.'+field,val,edits)
    for ax,v in zip('XYZ',recipe['box']):write(g,f'gObjectPool[{recipe.get("firstActorSlot",49)}].oPos'+ax,v,edits)
    if 'secondActor' in recipe:
        for ax,v in zip('XYZ',recipe['secondActor']):write(g,f'gObjectPool[{recipe.get("secondActorSlot",39)}].oPos'+ax,v,edits)
    return edits

def run_trial(g,o,base,r,full=False):
    g.load_state(base);g.setup=True;edits=setup(g,r);g.setup=False;rows=[];events=[];pads=[]
    initial=rich_sample(g,o) if full else None
    for k in range(32 if full else 3):
        pad=dict(buttons=0x2000,stick=[0,64]) if r['action']=='ACT_CRAWLING' and k<2 else NEUTRAL
        advance(g,pad);pads.append(pad)
        if full:rows.append(rich_sample(g,o));events.append(frame_events(g))
        else:
            p=g.read('gMarioState.pos');d=g.read('gMarioObject.header.gfx.pos')
            rows.append(dict(timer=g.read('gObjectPool[61].oTimer'),action=g.read('gMarioState.action'),movement=p,display=d,floorY=g.read('gMarioState.floorHeight'),floorOwner=o.slot(g.read('gMarioState.floor?.object')),platform=o.slot(g.read('gMarioPlatform')),used=o.slot(g.read('gMarioState.usedObj'))))
        if g.read('gCurrAreaIndex')!=1:break
    return dict(recipe=r,edits=edits if full else None,initial=initial,controls=pads,samples=rows,events=events)

def run(capture,out,direct=False,two=False,swap=False,shell=False):
    g,o=reach_after_pillars(capture);g=Guard(g)
    shell_prep=[];shell_slot=None
    if shell:
        while not(g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==127):advance(g,NEUTRAL)
        write(g,'gObjectPool[32].oAction',4,shell_prep);advance(g,NEUTRAL);advance(g,NEUTRAL)
        slots=[i for i in range(240) if g.read(f'gObjectPool[{i}].activeFlags') and g.read(f'gObjectPool[{i}].behavior')==g.address('bhvKoopaShell')]
        assert len(slots)==1;shell_slot=slots[0]
    while not(g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==129):advance(g,NEUTRAL)
    base=g.save_state();old=top_snapshot(g)
    advance(g,NEUTRAL);new=top_snapshot(g)
    advance(g,NEUTRAL);nxt=top_snapshot(g)
    cx,_,cz=nxt['center'];a=nxt['angularVelocity']*math.tau/65536
    count=0;selected=[];best=[];summary={};t0=time.time()
    for tx in ([-2040,-2020,-2000,-1980,-1960,-1950] if two else [-1955,-1950,-1947,-1946,-1945.5,-1945.1,-1945.01,-1945,-1944.99] if direct else [-1990,-1970,-1950,-1946]):
      for tz in range(-1010,-849,10 if direct else 20):
        qx=cx+math.cos(a)*(tx-cx)-math.sin(a)*(tz-cz)
        qz=cz+math.sin(a)*(tx-cx)+math.cos(a)*(tz-cz)
        if direct:qx,qz=tx,tz
        for ai in range(64):
          theta=ai*math.tau/64;dx,dz=math.sin(theta),math.cos(theta)
          for push in ([65,80,85,88] if shell else [60,65,70,71] if swap else [65,80,95,104,106]):
            px,pz=f32(qx-push*dx),f32(qz-push*dz)
            y=upper_floor(old['faces'],px,pz);ny=upper_floor(new['faces'],px,pz)
            if y is None or ny is None or ny-int(y)>78:continue
            for action in (['ACT_BUTT_SLIDE'] if two else ['ACT_BUTT_SLIDE','ACT_CRAWLING']):
              for speed in ([20] if two else [5,20]):
                recipe=dict(target=[tx,tz],push=push,angleIndex=ai,pos=[px,y,pz],expectedFreshY=ny,box=[f32(px-(107-push)*dx),y,f32(pz-(107-push)*dz)],action=action,yaw=ai*1024,speed=speed)
                if two:
                    recipe['secondActor']=[tx-39,ny,tz]
                if swap:
                    recipe.update(firstActorSlot=39,secondActorSlot=49,box=[f32(px-(72-push)*dx),y,f32(pz-(72-push)*dz)])
                if shell:
                    recipe.update(firstActorSlot=shell_slot,secondActorSlot=49,box=[f32(px-(89-push)*dx),y,f32(pz-(89-push)*dz)])
                trial=run_trial(g,o,base,recipe);count+=1
                s1,s2,s3=trial['samples'];gap=s2['display'][1]-s2['movement'][1]
                key=str((s1['floorOwner'],round(s2['floorY'],2),s2['action'],s3['used']==64,s3['platform']==61))
                summary[key]=summary.get(key,0)+1
                score=(int(s3['used']==64 and s3['platform']==61),int(gap>800 and s2['floorY']==768),-math.dist([s2['movement'][0],s2['movement'][2]],[-1882,-939]),-abs(s2['display'][1]-1770))
                if len(best)<8 or score>best[-1][0]:best.append((score,recipe));best.sort(reverse=True,key=lambda x:x[0]);best=best[:8]
                if s3['used']==64 and s3['platform']==61:selected.append(recipe);print('CAPTURE',recipe,flush=True)
    detailed=[]
    recipes=selected+[r for _,r in best]
    for r in recipes:
      t=run_trial(g,o,base,r,True);assert t==run_trial(g,o,base,r,True);detailed.append(t)
    source=ROOT.parents[2]/'reference-sm64-decomp'
    result=dict(schema=1,scope=__doc__,sourceRevision='921e4d1954d79f3b4deb6958c88419a8f4bd5a28',mode=dict(direct=direct,two=two,swap=swap,shell=shell),scriptSha256=digest(__file__),captureSha256=digest(capture),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),pythonVersion=sys.version,sourceSha256={p:digest(source/p) for p in ['src/game/mario_actions_moving.c','src/game/mario_step.c','src/game/interaction.c','src/game/platform_displacement.c','src/engine/surface_collision.c']},startingPhase=129,shellPreparation=shell_prep,oldMesh=old,newMesh=new,nextMesh=nxt,trialCount=count,summary=summary,elapsed=time.time()-t0,selectedCount=len(selected),bestScores=[s for s,r in best],trials=detailed)
    with out.open('x',encoding='utf-8') as f:json.dump(result,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(dict(trialCount=count,selected=len(selected),elapsed=time.time()-t0,best=[dict(score=s,recipe=r) for s,r in best]),indent=2))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('output',type=Path);p.add_argument('--direct',action='store_true');p.add_argument('--two',action='store_true');p.add_argument('--swap',action='store_true');p.add_argument('--shell',action='store_true');args=p.parse_args();run(args.capture,args.output,args.direct,args.two,args.swap,args.shell)
