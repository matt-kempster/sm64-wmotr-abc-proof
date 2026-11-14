"""Finite native thrown-box test after supplied airborne Mario/shell seeds.

The box is supplied in HELD_THROWN before127 and then runs natively. Mario
is supplied FREEFALL before128; no Mario writes follow that cut. Optional
shell placement belongs to the same cut. No cache or platform is supplied.
"""
import json, math, sys, time
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT/'instrumentation/ink-high-action-entry'))
from prelude import roots, advance, NEUTRAL, pose, write, f32, rich_sample, frame_events, digest
from ink_crawl_top_entry import top_snapshot, upper_floor, floor_height, contains

class Guard:
    def __init__(self, g): self.g=g; self.mode='controls'; self.slot=None
    def __getattr__(self,k): return getattr(self.g,k)
    def write(self,p,v):
        allowed={'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'}
        if self.mode=='actor': allowed|={f'gObjectPool[49].{k}' for k in ['oPosX','oPosY','oPosZ','oHeldState','oMoveAngleYaw']}
        if self.mode=='seed':
            assert p.startswith('gMarioState.') or p.startswith('gMarioObject.') or p in {f'gObjectPool[{self.slot}].oPos'+a for a in 'XYZ'},p
        else: assert p in allowed,p
        self.g.write(p,v)

def create(capture):
    g,o,states,slot,prep=roots(capture); g.mode='setup'
    q=Guard(g);q.slot=slot
    return q,o,states,slot,prep

def seed(g,r):
    g.mode='seed'; edits=[];pose(g,r['pos'],edits)
    yaw=r['yaw']; a=yaw*math.tau/65536; speed=20
    for k,v in [('action',g.constant('ACT_FREEFALL')),('actionState',0),('actionTimer',0),('forwardVel',speed),('vel',[f32(speed*math.sin(a)),-16,f32(speed*math.cos(a))]),('faceAngle',[0,yaw if yaw<32768 else yaw-65536,0])]: write(g,'gMarioState.'+k,v,edits)
    if r['kind']=='shell':
        for a,v in zip('XYZ',[r['pos'][0],r['pos'][1]-10,r['pos'][2]]):write(g,f'gObjectPool[{g.slot}].oPos'+a,v,edits)
    g.mode='controls';return edits

def actor(g):
    fields={k:g.read('gObjectPool[49].'+k) for k in ['oPosX','oPosY','oPosZ','oHeldState','oMoveAngleYaw','oAction','oForwardVel','oVelX','oVelY','oVelZ','oMoveFlags','activeFlags','oIntangibleTimer','hitboxRadius','hitboxHeight','hitboxDownOffset']}
    fields['isJumpingBox']=g.read('gObjectPool[49].behavior')==g.address('bhvJumpingBox')
    return fields

def small(g,o):
    return dict(movement=g.read('gMarioState.pos'),collision=[g.read('gMarioObject.oPos'+a) for a in 'XYZ'],display=g.read('gMarioObject.header.gfx.pos'),action=g.read('gMarioState.action'),floorY=g.read('gMarioState.floorHeight'),floorOwner=o.slot(g.read('gMarioState.floor?.object')),platform=o.slot(g.read('gMarioPlatform')),used=o.slot(g.read('gMarioState.usedObj')),area=g.read('gCurrAreaIndex'))

def trial(g,o,states,r,full=False):
    g.load_state(states[127]);g.mode='actor';boxEdits=[]
    for a,v in zip('XYZ',r['box']):write(g,'gObjectPool[49].oPos'+a,v,boxEdits)
    write(g,'gObjectPool[49].oMoveAngleYaw',r['throwYaw'],boxEdits)
    write(g,'gObjectPool[49].oHeldState',2,boxEdits)
    g.mode='controls';before=actor(g);advance(g,NEUTRAL);released=actor(g)
    edits=seed(g,r['seed']);initial=rich_sample(g,o) if full else None
    samples=[];boxes=[];events=[];pads=[]
    for i in range(33 if full else 4):
        pad=dict(buttons=0x2000,stick=[0,0]) if i==0 and r['seed']['kind']=='shell' else NEUTRAL
        advance(g,pad);pads.append(pad);samples.append(rich_sample(g,o) if full else small(g,o));boxes.append(actor(g))
        if full:events.append(frame_events(g))
        if samples[-1]['area']!=1:break
    captured=any(s['used']==64 and s['floorOwner']==s['platform']==61 for s in samples)
    arrival=next((s for s in samples if s['area']==2),None)
    useful=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717)
    return dict(recipe=r,boxEdits=boxEdits if full else None,marioSeedEdits=edits if full else None,actorBeforeRelease=before,actorAfterRelease=released,initial=initial,controls=pads,samples=samples,actors=boxes,events=events,capture=captured,useful=useful)

def candidates(g,o,states,seedfile):
    supplied=json.loads(seedfile.read_text())['seeds']
    recipes=[dict(kind='shell',**x['recipe']) for x in supplied]
    g.load_state(states[128]);faces=top_snapshot(g)['faces']
    for x in range(-2180,-1739,20):
      for z in range(-1180,-799,20):
        y=upper_floor(faces,x,z)
        if y is None or not 1640<=y<=1830:continue
        exact=max(floor_height(f,x,z) for f in faces if f['normal']['y']>0.01 and contains(f,x,z))
        for yaw in [0,16384,32768,49152]:recipes.append(dict(kind='air',phase=128,pos=[x,f32(max(y,exact)+1),z],yaw=yaw,speed=20))
    kept=[];native=0
    for r in recipes:
        g.load_state(states[128]);seed(g,r)
        advance(g,dict(buttons=0x2000,stick=[0,0]) if r['kind']=='shell' else NEUTRAL)
        s=small(g,o)
        if s['platform']!=61 or not 1740<=s['movement'][1]<=1801:continue
        if s['action'] not in [g.constant('ACT_BUTT_SLIDE'),g.constant('ACT_FREEFALL_LAND')]:continue
        native+=1;advance(g,NEUTRAL);after=small(g,o)
        action=[e for e in frame_events(g) if e['type']=='FLT_EXECUTE_ACTION']
        if action:
            kept.append(dict(seed=r,before129=s,carried129=action[0]['pos'],unopposedAfter129=after))
    return dict(total=len(recipes),nativeLowBefore129=native,cacheLowAfter129=sum(k['unopposedAfter129']['floorOwner']==61 and 1740<=k['unopposedAfter129']['floorY']<=1801 for k in kept)),kept

def main():
    capture=Path(sys.argv[1]);out=Path(sys.argv[2]);seedfile=ROOT/'build/wafel-pilot/ink-high-shell-seeds-20261114.json'
    g,o,states,slot,prep=create(capture);start=time.time()
    coverage,kept=candidates(g,o,states,seedfile); print('SEEDS',coverage,flush=True)
    corners=[[-1946,-922],[-1948,-924],[-2044,-922],[-2042,-924],[-1946,-1020],[-1948,-1018],[-2044,-1020],[-2042,-1018]]
    pairs=[];near=[]
    for k in kept:
      p=k['carried129'];c=k['before129']['collision']
      for tx,tz in corners:
        dx,dz=tx-p[0],tz-p[2];dist=math.hypot(dx,dz)
        if not 5<=dist<180:continue
        # Targets beyond one push are retained as explicit nearest failures;
        # move 106 units toward them, rather than assuming a longer push.
        push=min(dist,106)
        b=[f32(p[0]-(107-push)*dx/dist),c[1],f32(p[2]-(107-push)*dz/dist)]
        item=dict(seed=k['seed'],target=[tx,tz],box129Proposal=b,carried129=p,landing=c,distance=dist,oldCollisionSeparation=math.hypot(b[0]-c[0],b[2]-c[2]))
        near.append(item)
        if item['oldCollisionSeparation']>=112:continue
        pairs.append(item)
    # Keep a bounded spread: up to two nearest predecessor recipes per kind/corner.
    selected=[]
    for kind in ['air','shell']:
      for corner in corners:
        group=sorted([p for p in pairs if p['seed']['kind']==kind and p['target']==corner],key=lambda p:(p['distance'],p['seed']['yaw']))
        seen=set()
        for p in group:
            key=tuple(p['seed']['pos'])
            if key in seen:continue
            selected.append(p);seen.add(key)
            if len(seen)>=2:break
    if not selected:
        # Two nearest NE-corner failures still exercise the actual throw
        # callback, its possible floor clamp, and all later native updates.
        for kind in ['air','shell']:
            group=sorted([p for p in near if p['seed']['kind']==kind and p['target']==corners[0]],key=lambda p:(p['distance'],p['seed']['yaw']))
            if group:selected.append(group[0])
    print('PAIRS',len(pairs),'SELECTED',len(selected),flush=True)
    counts=dict(trials=0,lowCache129=0,lowGap130=0,capture=0,actorInactive129=0);best=[];gaps=[];caps=[];screens=[];controls=[]
    for pi,p in enumerate(selected):
      for yaw in range(0,65536,4096):
       angle=yaw*math.tau/65536
       for low in [114,108,100,80,0]:
        b=p['box129Proposal'];r=dict(seed=p['seed'],target=p['target'],throwYaw=yaw,verticalSeparation=low,box=[f32(b[0]-38.4*math.sin(angle)),f32(b[1]-low-28),f32(b[2]-38.4*math.cos(angle))])
        t=trial(g,o,states,r);s0,s1,s2,s3=t['samples'];counts['trials']+=1
        screens.append(t)
        if yaw==0 and low==114:controls.append(r)
        lowcache=s1['floorOwner']==61 and 1740<=s1['floorY']<=1801
        gap=s2['floorY']==768 and s2['display'][1]-s2['movement'][1]>800
        counts['lowCache129']+=lowcache;counts['lowGap130']+=gap;counts['capture']+=t['capture'];counts['actorInactive129']+=t['actors'][1]['activeFlags']==0
        if gap:gaps.append(dict(recipe=r,samples=t['samples'],actors=t['actors']))
        if t['capture']:caps.append(r);print('CAPTURE',r,flush=True)
        sc=(int(t['capture']),int(gap),int(lowcache),int(s1['action']==g.constant('ACT_BUTT_SLIDE')),-abs(s2['movement'][1]-768),-math.hypot(s2['movement'][0]+1995,s2['movement'][2]+971))
        best.append((sc,r));best.sort(key=lambda x:x[0],reverse=True);best=best[:8]
      print('PAIR',pi+1,'/',len(selected),'TRIALS',counts['trials'],'GAPS',counts['lowGap130'],'elapsed',round(time.time()-start,1),flush=True)
    q,qo,qs,qslot,qprep=create(capture);assert qprep==prep;full=[]
    seen=set()
    for r in caps+[r for _,r in best]+controls:
        key=json.dumps(r,sort_keys=True)
        if key in seen:continue
        seen.add(key);t=trial(g,o,states,r,True);assert t==trial(q,qo,qs,r,True);full.append(t)
    sources=ROOT.parents[2]/'reference-sm64-decomp'
    result=dict(schema=1,date='2026-11-14',scope=__doc__,proofRevision='651c180e594e45c6825f9c4800da11f4afef0773',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',scriptSha256=digest(__file__),helperSha256={p:digest(ROOT/p) for p in ['instrumentation/ink-high-action-entry/prelude.py','instrumentation/wafel-jp-pilot/ink_crawl_predecessors.py','instrumentation/wafel-jp-pilot/ink_crawl_top_entry.py']},sourceSha256={p:digest(sources/p) for p in ['src/game/behaviors/jumping_box.inc.c','src/game/object_helpers.c','src/game/interaction.c','src/game/mario_step.c','src/game/platform_displacement.c','src/engine/behavior_script.c','src/game/object_collision.c']},runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),captureSha256=digest(capture),shellSeedReceiptSha256=digest(seedfile),shellPreparation=prep,seedCoverage=coverage,predecessors=kept,geometricPairs=len(pairs),selectedPairs=selected,menu=dict(corners=corners,throwYaw=list(range(0,65536,4096)),verticalSeparation=[114,108,100,80,0],priorXZ=38.4,priorY=28),counts=counts,bestScores=[s for s,r in best],gapScreens=gaps,screens=screens,trials=full,freshBoundaries=sum(len(t['samples'])+1 for t in full),elapsed=time.time()-start)
    with out.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('FINAL',counts,'FRESH',result['freshBoundaries'],'USEFUL',sum(t['useful'] for t in full),flush=True)

if __name__=='__main__':main()
