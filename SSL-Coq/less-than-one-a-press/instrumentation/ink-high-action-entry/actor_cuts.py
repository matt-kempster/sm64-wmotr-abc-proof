"""Bounded actor-XYZ-only feasibility cuts after native shell-created slides.

The initial airborne Mario/shell state and shell-box release remain supplied.
No Mario fields are written after that initial cut. Actor delivery is NOT
claimed: shell and Crazy Box positions may be supplied again before129, and
the box may be supplied again before130. Success requires useful Area2 arrival.
"""
import argparse,json,math,sys,time
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from seeds import make_seed
from prelude import ROOT,roots,advance,NEUTRAL,write,f32,rich_sample,frame_events,digest

class Guard:
    def __init__(self,g,slot):self.g=g;self.slot=slot;self.mode='controls'
    def __getattr__(self,k):return getattr(self.g,k)
    def write(self,p,v):
        if self.mode=='controls':assert p in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},p
        if self.mode=='actor':assert p in {f'gObjectPool[{i}].oPos'+a for i in [49,self.slot] for a in 'XYZ'},p
        self.g.write(p,v)

def create(capture):
    g,o,s,slot,prep=roots(capture)
    return Guard(g.g,slot),o,s,slot,prep

def small(g,o):
    return dict(movement=g.read('gMarioState.pos'),collision=[g.read('gMarioObject.oPos'+a) for a in 'XYZ'],display=g.read('gMarioObject.header.gfx.pos'),action=g.read('gMarioState.action'),floorY=g.read('gMarioState.floorHeight'),floorOwner=o.slot(g.read('gMarioState.floor?.object')),platform=o.slot(g.read('gMarioPlatform')),used=o.slot(g.read('gMarioState.usedObj')),area=g.read('gCurrAreaIndex'))

def actor(g,slot):
    return {k:g.read(f'gObjectPool[{slot}].'+k) for k in ['oPosX','oPosY','oPosZ','activeFlags','oAction','oIntangibleTimer','oInteractStatus','hitboxRadius','hitboxHeight']}

def cut(g,box=None,shell=None):
    g.mode='actor';edits=[]
    for slot,pos in [(49,box),(g.slot,shell)]:
        if pos is not None:
            for a,v in zip('XYZ',pos):write(g,f'gObjectPool[{slot}].oPos'+a,v,edits)
    g.mode='controls';return edits

def action_event(g):
    return next((e for e in frame_events(g) if e['type']=='FLT_EXECUTE_ACTION'),None)

def nearest(p):return [max(-2148,min(-1946,p[0])),max(-1124,min(-922,p[2]))]
def dist(p,q):return math.hypot(p[0]-q[0],p[2]-q[1])
def pad_distance(p):return dist(p,nearest(p))
def pad_targets(p):
    return list(dict.fromkeys([tuple(nearest(p))]+[(x,z) for x in [-2148,-2047,-1946] for z in [-1124,-1023,-922]]))

def box_to(p,c,target):
    d=dist(p,target)
    if not 0.5<d<106.8:return None
    dx,dz=(target[0]-p[0])/d,(target[1]-p[2])/d
    box=[f32(target[0]-107*dx),c[1],f32(target[1]-107*dz)]
    return box if math.hypot(box[0]-c[0],box[2]-c[2])<111.9 else None

def full(g,o,states,slot,r):
    seed=make_seed(g,o,states[128],slot,r['seed'],True)
    t=dict(recipe=r,seed=seed,actorCuts=[],controls=[],samples=[],events=[],actors=[])
    t['actorCuts'].append(dict(beforePhase=129,edits=cut(g,r.get('box129'),r.get('shell129'))))
    for i in range(35):
        if i==1 and r.get('box130') is not None:t['actorCuts'].append(dict(beforePhase=130,edits=cut(g,r['box130'])))
        advance(g,NEUTRAL);s=rich_sample(g,o);t['samples'].append(s);t['events'].append(frame_events(g));t['controls'].append(NEUTRAL);t['actors'].append(dict(box=actor(g,49),shell=actor(g,slot)))
        if s['area']!=1:break
    t['capture']=any(s['used']==64 and s['floorOwner']==s['platform']==61 for s in t['samples'])
    arrival=next((s for s in t['samples'] if s['area']==2),None)
    t['useful']=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717)
    return t

def main():
    p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
    sf=ROOT/'build/wafel-pilot/ink-high-shell-seeds-20261114.json';recipes=[s['recipe'] for s in json.loads(sf.read_text())['seeds']]
    g,o,states,slot,prep=create(a.capture);start=time.time();native=[];screens=[];best=[];promising=[];positives=[]
    counts=dict(seeds=0,singleBox129=0,singleRegistered=0,singleChangedActionPosition=0,shellOnly129=0,shellRegistered=0,shellChangedActionPosition=0,shellAndBox129=0,bothRegistered=0,secondActorChangedActionPosition=0,anyHeightGroundPad129=0,highGroundPad129=0,box130=0,captures=0,useful=0)
    changed=[];bothPushed=[]
    ground={g.constant(n) for n in ['ACT_BUTT_SLIDE','ACT_CROUCH_SLIDE','ACT_STOMACH_SLIDE','ACT_DIVE_SLIDE','ACT_CRAWLING']}
    def record(r,s,e):
        counts['anyHeightGroundPad129']+=s['action'] in ground and pad_distance(s['movement'])<=.1
        sc=(int(s['action'] in ground),int(1740<=s['movement'][1]<=1801),-pad_distance(s['movement']))
        key=tuple(r['seed']['pos'])+(r['seed']['yaw'],bool(r.get('box129')),bool(r.get('shell129')))
        old=next((i for i,x in enumerate(best) if x[2]==key),None)
        if old is None:best.append((sc,r,key))
        elif sc>best[old][0]:best[old]=(sc,r,key)
        best.sort(key=lambda x:x[0],reverse=True);del best[8:]
        if s['action'] not in ground or not 1740<=s['movement'][1]<=1801 or pad_distance(s['movement'])>0.1 or s['platform']!=-1:return
        counts['highGroundPad129']+=1;state130=g.save_state();c=s['collision'];advance(g,NEUTRAL);pe=action_event(g);unopposed=small(g,o)
        q=dict(recipe=r,after129=s,firstAction129=e,firstAction130=pe,unopposedAfter130=unopposed);promising.append(q);print('HIGH_PAD',q,flush=True)
        proposals=[]
        # The unopposed action position can already include old actor pushes.
        # Retain raw before130 M as a separate inverse-placement origin.
        for origin in [s['movement']]+([pe['pos']] if pe else []):
          for target in [(x,z) for x in [-1890,-1882,-1874] for z in [-970,-939,-925]]:
            b=box_to(origin,c,target)
            if b is not None and b not in proposals:proposals.append(b)
        for b in proposals:
            g.load_state(state130);cut(g,b);advance(g,NEUTRAL);producer=small(g,o);advance(g,NEUTRAL);accept=small(g,o);counts['box130']+=1
            rr=dict(r,box130=b);screens.append(dict(recipe=rr,producer=producer,accept=accept))
            if accept['used']==64 and accept['floorOwner']==accept['platform']==61:
                counts['captures']+=1;t=full(g,o,states,slot,rr);positives.append(rr);counts['useful']+=t['useful'];print('CAPTURE',rr,'useful',t['useful'],flush=True)
    for r in recipes:
        make_seed(g,o,states[128],slot,r);before=small(g,o);state=g.save_state();advance(g,NEUTRAL);ev=action_event(g);counts['seeds']+=1
        if not ev:continue
        p0=ev['pos'];c=before['collision'];native.append(dict(seed=r,before129=before,carried129=p0,distanceToPad=pad_distance(p0),unopposedAfter129=small(g,o)))
        boxes=[]
        for target in pad_targets(p0):
            d=dist(p0,target)
            if d<0.5:continue
            for radial in [1,30,60,90]:
                b=[f32(p0[0]-radial*(target[0]-p0[0])/d),c[1],f32(p0[2]-radial*(target[1]-p0[2])/d)]
                if math.hypot(b[0]-c[0],b[2]-c[2])<111.9:boxes.append(tuple(b))
        for b in sorted(set(boxes)):
            g.load_state(state);cut(g,list(b));advance(g,NEUTRAL);s=small(g,o);e=action_event(g);counts['singleBox129']+=1
            coll=[o.slot(g.read(f'gMarioObject.collidedObjs[{i}]')) for i in range(g.read('gMarioObject.numCollidedObjs'))];counts['singleRegistered']+=49 in coll
            moved=e is not None and math.hypot(e['pos'][0]-p0[0],e['pos'][2]-p0[2])>.01;counts['singleChangedActionPosition']+=moved
            rr=dict(seed=r,box129=list(b));record(rr,s,e)
            if moved and len(changed)<12:changed.append(dict(recipe=rr,firstAction129=e,collisions=coll,after129=s))
    print('SINGLE',counts,'nearest',min(n['distanceToPad'] for n in native),'elapsed',time.time()-start,flush=True)
    # The existing cancelled shell is still active. For each heading keep
    # twelve nearest overall and twelve with unopposed post129 low top floor.
    selected=[]
    for yaw in [0,16384,32768,49152]:
        ordered=sorted([n for n in native if n['seed']['yaw']==yaw],key=lambda n:(n['distanceToPad'],n['seed']['pos']))
        for n in ordered[:12]+[n for n in ordered if n['unopposedAfter129']['floorOwner']==61 and 1740<=n['unopposedAfter129']['floorY']<=1801][:12]:
            if n not in selected:selected.append(n)
    for ni,n in enumerate(selected):
        r=n['seed'];make_seed(g,o,states[128],slot,r);state=g.save_state();c=n['before129']['collision']
        shells=[tuple(c)]
        for radius in [40,80]:
            for yaw in range(0,65536,4096):
                angle=yaw*math.tau/65536;shells.append((f32(c[0]+radius*math.sin(angle)),c[1],f32(c[2]+radius*math.cos(angle))))
        for sh in shells:
            g.load_state(state);cut(g,shell=list(sh));advance(g,NEUTRAL);ev=action_event(g);s=small(g,o);counts['shellOnly129']+=1
            coll=[o.slot(g.read(f'gMarioObject.collidedObjs[{i}]')) for i in range(g.read('gMarioObject.numCollidedObjs'))];counts['shellRegistered']+=slot in coll
            moved=ev is not None and math.hypot(ev['pos'][0]-n['carried129'][0],ev['pos'][2]-n['carried129'][2])>.01;counts['shellChangedActionPosition']+=moved
            rr=dict(seed=r,shell129=list(sh));record(rr,s,ev)
            if moved and len(changed)<24:changed.append(dict(recipe=rr,firstAction129=ev,collisions=coll,after129=s))
            if not ev or ev['action'] not in ground:continue
            proposals=[]
            for target in pad_targets(ev['pos']):
                b=box_to(ev['pos'],c,target)
                if b is not None:proposals.append(b)
            # Also execute the closest ideal partial shove from a bounded
            # collision-compatible actor ring; direct pad reach is not assumed.
            partial=[]
            for radius in [20,60,100]:
              for yaw in range(0,65536,4096):
                angle=yaw*math.tau/65536;b=[f32(c[0]+radius*math.sin(angle)),c[1],f32(c[2]+radius*math.cos(angle))]
                dx,dz=ev['pos'][0]-b[0],ev['pos'][2]-b[2];d=math.hypot(dx,dz)
                if .1<d<107:partial.append((pad_distance([b[0]+107*dx/d,c[1],b[2]+107*dz/d]),b))
            if partial:proposals.append(min(partial,key=lambda x:x[0])[1])
            for b in proposals:
                g.load_state(state);cut(g,b,list(sh));advance(g,NEUTRAL);s=small(g,o);counts['shellAndBox129']+=1
                coll=[o.slot(g.read(f'gMarioObject.collidedObjs[{i}]')) for i in range(g.read('gMarioObject.numCollidedObjs'))];counts['bothRegistered']+=slot in coll and 49 in coll
                combined=action_event(g)
                secondMoved=combined is not None and math.hypot(combined['pos'][0]-ev['pos'][0],combined['pos'][2]-ev['pos'][2])>.01
                counts['secondActorChangedActionPosition']+=secondMoved
                if moved and secondMoved:bothPushed.append(dict(recipe=dict(rr,box129=b),before129=n['before129'],unopposedFirstAction129=n['carried129'],shellOnlyFirstAction129=ev,combinedFirstAction129=combined,after129=s,collisions=coll))
                record(dict(rr,box129=b),s,combined)
        if (ni+1)%24==0:print('SHELL_MENU',ni+1,counts,'elapsed',time.time()-start,flush=True)
    q,qo,qs,qslot,qprep=create(a.capture);assert prep==qprep;trials=[];seen=set()
    selectedBoth=[]
    for group in [bothPushed,[b for b in bothPushed if b['after129']['action'] in ground and 1740<=b['after129']['movement'][1]<=1801]]:
        if group:selectedBoth.append(min(group,key=lambda b:pad_distance(b['after129']['movement'])))
    for r in positives+[r for _,r,_ in best]+[c['recipe'] for c in changed[:1]]+[c['recipe'] for c in changed if c['recipe'].get('shell129') is not None][:1]+[b['recipe'] for b in selectedBoth]:
        key=json.dumps(r,sort_keys=True)
        if key in seen:continue
        seen.add(key);t=full(g,o,states,slot,r);assert t==full(q,qo,qs,qslot,r);trials.append(t)
    result=dict(schema=1,date='2026-11-14',scope=__doc__,scriptSha256=digest(__file__),helpersSha256={s:digest(ROOT/'instrumentation/ink-high-action-entry'/s) for s in ['prelude.py','seeds.py']},runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),captureSha256=digest(a.capture),seedReceiptSha256=digest(sf),shellPreparation=prep,counts=counts,native=native,selectedShellSeeds=selected,menu=dict(singleBoxRadial=[1,30,60,90],shellRadius=[0,40,80],shellAngles=list(range(0,65536,4096)),nearestPerYaw=dict(overall=12,post129LowTopFloor=12),secondBoxPartialRadius=[20,60,100],secondBoxPartialAngles=list(range(0,65536,4096)),padBounds=[-2148,-1946,-1124,-922],secondTargets=[(x,z) for x in [-1890,-1882,-1874] for z in [-970,-939,-925]]),changedActionExamples=changed,bothPushed=bothPushed,selectedBothPushed=selectedBoth,promising=promising,producerScreens=screens,trials=trials,freshBoundaries=sum(len(t['samples'])+1 for t in trials),elapsed=time.time()-start)
    with a.output.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('FINAL',counts,'FRESH',result['freshBoundaries'],flush=True)

if __name__=='__main__':main()
