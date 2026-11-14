"""Stock Buddy/box/shell cuts after two named native slide predecessors.

Initial high FREEFALL and shell placement are supplied. No Mario writes
follow the real shell/Z initializer. Later grants are actor XYZ only.
"""
import json,math,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/ink-high-action-entry'))
from prelude import roots as old_roots,advance,NEUTRAL,write,f32,rich_sample,frame_events,digest
from seeds import make_seed
sys.path.insert(0,str(ROOT/'instrumentation/ink-item-clone-controls'))
from fixtures import actor_snapshot

NEAR=[dict(name='south-near-miss',seed=dict(phase=128,pos=[-1920,21700,-1210],yaw=0,speed=20),shell129=[-1956.9552001953125,1799.2869873046875,-1225.307373046875],box129=[-2012.387939453125,1799.2869873046875,-1248.268310546875]),dict(name='west-low-near-miss',seed=dict(phase=128,pos=[-2220,21700,-1170],yaw=16384,speed=20),shell129=[-2276.568603515625,1796.9307861328125,-1113.431396484375],box129=[-2290.710693359375,1796.9307861328125,-1099.289306640625])]

class Guard:
    def __init__(self,g,slot):self.g=g;self.slot=slot;self.mode='controls'
    def __getattr__(self,k):return getattr(self.g,k)
    def write(self,p,v):
        if self.mode=='controls':assert p in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},p
        if self.mode=='actor':assert p in {f'gObjectPool[{i}].oPos'+a for i in [49,15,self.slot] for a in 'XYZ'},p
        self.g.write(p,v)

def roots(capture):
    g,o,s,slot,prep=old_roots(capture);g=Guard(g.g,slot)
    b=actor_snapshot(g,15)
    assert b['behavior']=='bhvBobombBuddyOpensCannon' and b['hitboxRadius']==100 and b['hitboxHeight']==60 and b['oIntangibleTimer']==0
    return g,o,s,slot,dict(shell=prep,buddy=b)

def cut(g,placements):
    g.mode='actor';edits=[]
    for key,slot in [('box129',49),('shell129',g.slot),('buddy129',15)]:
        if key in placements:
            for a,v in zip('XYZ',placements[key]):write(g,f'gObjectPool[{slot}].oPos'+a,v,edits)
    g.mode='controls';return edits

def small(g,o):
    return dict(movement=g.read('gMarioState.pos'),collision=[g.read('gMarioObject.oPos'+a) for a in 'XYZ'],display=g.read('gMarioObject.header.gfx.pos'),action=g.read('gMarioState.action'),floorY=g.read('gMarioState.floorHeight'),floorOwner=o.slot(g.read('gMarioState.floor?.object')),platform=o.slot(g.read('gMarioPlatform')),used=o.slot(g.read('gMarioState.usedObj')),area=g.read('gCurrAreaIndex'),collisions=[o.slot(g.read(f'gMarioObject.collidedObjs[{i}]')) for i in range(g.read('gMarioObject.numCollidedObjs'))])

def event(g):return next((e for e in frame_events(g) if e['type']=='FLT_EXECUTE_ACTION'),None)
def nearest(p):return [max(-2148,min(-1946,p[0])),max(-1124,min(-922,p[2]))]
def distance(p):q=nearest(p);return math.hypot(p[0]-q[0],p[2]-q[1])

def to_target(p,c,target,pushRadius,collisionRadius):
    dx,dz=target[0]-p[0],target[1]-p[2];d=math.hypot(dx,dz)
    if not .01<d<pushRadius:return None
    a=[f32(target[0]-pushRadius*dx/d),c[1],f32(target[1]-pushRadius*dz/d)]
    return a if math.hypot(a[0]-c[0],a[2]-c[2])<collisionRadius-.01 else None

def full(g,o,states,r):
    seed=make_seed(g,o,states[128],g.slot,r['seed'],True);edits=cut(g,r);rows=[];events=[];actors=[];cuts=[dict(phase=129,edits=edits)]
    for i in range(35):
        if i==1 and 'box130' in r:
            cuts.append(dict(phase=130,edits=cut(g,dict(box129=r['box130']))))
        advance(g,NEUTRAL);rows.append(rich_sample(g,o));events.append(frame_events(g));actors.append({str(slot):actor_snapshot(g,slot) for slot in [49,15,g.slot]})
        if rows[-1]['area']!=1:break
    arrival=next((s for s in rows if s['area']==2),None)
    return dict(recipe=r,seed=seed,actorCuts=cuts,samples=rows,events=events,actors=actors,controls=[NEUTRAL]*len(rows),capture=any(s['used']==64 and s['floorOwner']==s['platform']==61 for s in rows),useful=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717))

def main():
    capture=Path(sys.argv[1]);out=Path(sys.argv[2]);g,o,states,slot,prep=roots(capture);screens=[];best=[];positives=[];producerScreens=[];baselines=[];start=time.time()
    ground={g.constant(n) for n in ['ACT_BUTT_SLIDE','ACT_CROUCH_SLIDE','ACT_STOMACH_SLIDE','ACT_DIVE_SLIDE','ACT_CRAWLING','ACT_WALKING']}
    counts=dict(nativeSeeds=0,buddyCombinationTrials=0,buddyRegistered=0,buddyChangedFirstAction=0,anyHeightGroundPad=0,lowGroundPad=0,box130=0,captures=0,useful=0)
    for near in NEAR:
        make_seed(g,o,states[128],slot,near['seed']);state=g.save_state();before=small(g,o);c=before['collision'];counts['nativeSeeds']+=1
        for family in ['box-buddy','shell-box-buddy']:
            base=dict(name=near['name'],seed=near['seed'],family=family,box129=near['box129'])
            if family=='shell-box-buddy':base['shell129']=near['shell129']
            g.load_state(state);cut(g,base);advance(g,NEUTRAL);baseE=event(g);baseS=small(g,o);baselines.append(dict(recipe=base,before129=before,event=baseE,after129=baseS))
            proposals=[tuple(c)]
            for radius in [40,80,120,136]:
              for yaw in range(0,65536,4096):
                a=yaw*math.tau/65536;proposals.append((f32(c[0]+radius*math.sin(a)),c[1],f32(c[2]+radius*math.cos(a))))
            for target in [nearest(baseE['pos'])]+[[x,z] for x in [-2148,-2047,-1946] for z in [-1124,-1023,-922]]:
                a=to_target(baseE['pos'],c,target,127,137)
                if a:proposals.append(tuple(a))
            for buddy in sorted(set(proposals)):
                r=dict(base,buddy129=list(buddy));g.load_state(state);cut(g,r);advance(g,NEUTRAL);s=small(g,o);e=event(g);counts['buddyCombinationTrials']+=1
                changed=e is not None and math.dist(e['pos'],baseE['pos'])>.01;counts['buddyRegistered']+=15 in s['collisions'];counts['buddyChangedFirstAction']+=changed
                pad=s['action'] in ground and distance(s['movement'])<.01;counts['anyHeightGroundPad']+=pad;counts['lowGroundPad']+=pad and 1740<=s['movement'][1]<=1801
                row=dict(recipe=r,after129=s,event=e,buddyChanged=changed,padDistance=distance(s['movement']));screens.append(row)
                sc=(int(pad),-distance(s['movement']),int(1740<=s['movement'][1]<=1801),int(changed));best.append((sc,r));best.sort(key=lambda x:x[0],reverse=True);best=best[:8]
                if not pad:continue
                # Pad arrival alone is not success. Test the actual following
                # native update, then only source-informed later box placements.
                state130=g.save_state();advance(g,NEUTRAL);unopposed=small(g,o);ue=event(g)
                targets=[[x,z] for x in [-1890,-1882,-1874] for z in [-970,-939,-925]]
                bs=[None]
                for origin in [s['movement']]+([ue['pos']] if ue else []):
                  for target in targets:
                    b=to_target(origin,s['collision'],target,107,112)
                    if b is not None and b not in bs:bs.append(b)
                for b in bs:
                    g.load_state(state130)
                    if b:cut(g,dict(box129=b));counts['box130']+=1
                    advance(g,NEUTRAL);p=small(g,o);advance(g,NEUTRAL);a=small(g,o)
                    rr=dict(r,box130=b) if b else r
                    producerScreens.append(dict(recipe=rr,producer=p,accept=a))
                    if a['used']==64 and a['floorOwner']==a['platform']==61:
                        counts['captures']+=1;t=full(g,o,states,rr);counts['useful']+=t['useful'];positives.append(rr);print('CAPTURE',rr,'useful',t['useful'],flush=True)
            print('FAMILY',near['name'],family,counts,'bestDistance',-best[0][0][1],flush=True)
    q,qo,qs,qslot,qprep=roots(capture);assert qprep==prep;trials=[];seen=set();selected=positives+[r for _,r in best]
    # Actual-effect ablation of the single closest result: all subsets of
    # the same stock placements, not an additive push approximation.
    closest=best[0][1];keys=[k for k in ['shell129','box129','buddy129'] if k in closest]
    ablations=[]
    for mask in range(1<<len(keys)):
        r={k:v for k,v in closest.items() if k not in keys};r['ablationMask']=mask
        for i,k in enumerate(keys):
            if mask&(1<<i):r[k]=closest[k]
        selected.append(r);ablations.append(r)
    for r in selected:
        key=json.dumps(r,sort_keys=True)
        if key in seen:continue
        seen.add(key);t=full(g,o,states,r);assert t==full(q,qo,qs,r);trials.append(t)
    source=ROOT.parents[2]/'reference-sm64-decomp'
    result=dict(schema=1,date='2026-11-14',scope=__doc__,proofRevision='08b72af44fbb54aaef3ed7f8be399868ba75db98',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',scriptSha256=digest(__file__),helpersSha256={str(p):digest(ROOT/p) for p in ['instrumentation/ink-high-action-entry/prelude.py','instrumentation/ink-high-action-entry/seeds.py','instrumentation/ink-item-clone-controls/fixtures.py']},sourceSha256={p:digest(source/p) for p in ['src/game/interaction.c','src/game/mario_actions_moving.c','src/game/mario_step.c','src/game/object_collision.c']},captureSha256=digest(capture),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),preparation=prep,menu=dict(seeds=NEAR,buddyRadii=[0,40,80,120,136],buddyY='native C before129',buddyAngles=list(range(0,65536,4096)),padBounds=[-2148,-1946,-1124,-922]),counts=counts,baselines=baselines,screens=screens,producerScreens=producerScreens,bestScores=[s for s,r in best],closest=closest,ablationRecipes=ablations,trials=trials,freshBoundaries=sum(len(t['samples'])+1 for t in trials),elapsed=time.time()-start)
    with out.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('FINAL',counts,'FRESH',result['freshBoundaries'],'CLOSEST',closest,flush=True)

if __name__=='__main__':main()
