"""Bounded native frozen-shell slide entry and consecutive Bob/Box shoves.

Mario is supplied airborne once, never as a ground action. Every later cut is
actor XYZ only. Actor callbacks, lifetime, collisions and older actors remain.
This is a finite local search, not delivery or a global exclusion.
"""
import argparse,gzip,hashlib,importlib.util,json,math,struct
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
spec=importlib.util.spec_from_file_location('retime_iso',ROOT/'instrumentation/ink-shell-clone-isolation/test.py')
iso=importlib.util.module_from_spec(spec);spec.loader.exec_module(iso)
def f32(v):return struct.unpack('<f',struct.pack('<f',v))[0]
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
class Guard:
 def __init__(self,g,slot):self.g=g;self.slot=slot;self.mode='controls'
 def __getattr__(self,k):return getattr(self.g,k)
 def write(self,p,v):
  pads={'gControllerPads[0].'+x for x in ['button','stick_x','stick_y']}
  actors={f'gObjectPool[{s}].oPos'+a for s in [39,40,49,self.slot]for a in 'XYZ'}
  mario={'gMarioState.'+x for x in ['pos','action','actionState','actionTimer','vel','forwardVel','faceAngle']}|{'gMarioObject.header.gfx.pos'}|{'gMarioObject.oPos'+a for a in 'XYZ'}
  assert p in (pads if self.mode=='controls'else actors if self.mode=='actor'else mario|actors),p
  self.g.write(p,v)
def place(g,slot,p):
 g.mode='actor';e=[]
 for a,v in zip('XYZ',p):
  k=f'gObjectPool[{slot}].oPos'+a;e.append(dict(path=k,before=g.read(k),after=v));g.write(k,v)
 g.mode='controls';return e
def snapshot(g,o,full=True):
 s=iso.snap(g,o,g.slot)
 s.update(topPhase=g.read('gObjectPool[61].oTimer'),actors={str(i):iso.actor_snapshot(g,i)for i in [39,40,49]},ceilPresent=not g.read('gMarioState.ceil').is_null())
 if not full:s={k:s[k]for k in ['M','C','G','area','actionName','floorY','floorOwner','platform','used','topPhase','collisions','forwardVelocity']}
 return s
def advance(g,o,pad=iso.NEUTRAL,full=False):
 iso.advance(g,pad);assert not g.read('gMarioState.input')&0x82
 return snapshot(g,o,full)
def roots():
 raw=gzip.decompress((ROOT/'instrumentation/ink-high-item-nudge/prefix.jsonl.gz').read_bytes());assert hashlib.sha256(raw).hexdigest()=='9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72'
 p=ROOT/'build/ink-bobomb-retimed-prefix.jsonl';p.write_bytes(raw);g,o=iso.reach_after_pillars(p)
 e=[];iso.write(g,o,'gObjectPool[32].oAction',4,e)
 for _ in range(2):iso.advance(g,iso.NEUTRAL)
 slot=next(i for i in range(240)if g.read(f'gObjectPool[{i}].activeFlags')and g.read(f'gObjectPool[{i}].behavior')==g.address('bhvKoopaShell'))
 spawn=dict(edits=e,controls=[iso.NEUTRAL]*2,after=iso.snap(g,o,slot))
 pick,held=iso.pickup(g,o,slot,g.save_state());release,_=iso.release(g,o,slot,held,'throw',19900)
 while g.read('gObjectPool[61].oTimer')<126:iso.advance(g,iso.NEUTRAL)
 states={}
 for phase in [126,127,128]:states[phase]=g.save_state();iso.advance(g,iso.NEUTRAL)
 return Guard(g,slot),o,states,dict(spawn=spawn,pickup=pick,release=release)
def seed(g,o,states,r,full=False):
 g.load_state(states[r['phase']]);g.mode='initial';e=[];x,z=r['xz'];iso.mario(g,o,[x,19900,z],e,speed=r.get('speed',20))
 iso.write(g,o,'gMarioState.vel',[0,-16,r.get('speed',20)],e);iso.write(g,o,'gMarioState.faceAngle',[0,0,0],e);iso.position(g,o,g.slot,[x,19890,z],e);g.mode='controls'
 before=snapshot(g,o,full);after=advance(g,o,iso.Z,full)
 return dict(recipe=r,edits=e,before=before,after=after,events=iso.frame_events(g),control=iso.Z)
def action_pos(g):
 return next((e['pos']for e in iso.frame_events(g)if e['type']=='FLT_EXECUTE_ACTION'),g.read('gMarioState.pos'))
def candidate_positions(g,o,state,slot,final=False):
 g.load_state(state)
 c=[g.read('gMarioObject.oPos'+a)for a in 'XYZ'];radius=g.read(f'gObjectPool[{slot}].hitboxRadius');push=radius+37-5
 advance(g,o);p=action_pos(g)
 targets=([(x,z)for x in [-2220,-2210,-2200,-2180,-2160,-1900,-1890,-1882]for z in [-1100,-1075,-1040,-1000,-960,-939]]if final else[(x,z)for x in [-2140,-2100,-2060,-2020,-1980]for z in [-1115,-1075,-1030,-980]])
 out=[None]
 for x,z in targets:
  dx,dz=x-p[0],z-p[2];d=math.hypot(dx,dz)
  if .01<d<push:
   q=[f32(x-push*dx/d),c[1],f32(z-push*dz/d)]
   if math.hypot(q[0]-c[0],q[2]-c[2])<radius+37-.01:out.append(q)
 for distance in ([20,70]if final else[30,80]):
  for yaw in range(0,65536,8192):
   a=yaw*math.tau/65536;out.append([f32(c[0]+distance*math.sin(a)),c[1],f32(c[2]+distance*math.cos(a))])
 return list(dict.fromkeys(tuple(x)if x else None for x in out))
def pad_distance(s):
 x,_,z=s['M'];return math.hypot(x-max(-2148,min(-1946,x)),z-max(-1124,min(-922,z)))
def score(s):
 ground=s['actionName']in['ACT_BUTT_SLIDE','ACT_CROUCH_SLIDE','ACT_BUTT_SLIDE_STOP','ACT_GROUND_BONK']
 return (int(ground),-pad_distance(s),-abs(s['M'][1]-1830))
def cut_trial(g,o,state,slot,pos):
 g.load_state(state);e=place(g,slot,pos)if pos else[];s=advance(g,o);return dict(edits=e,sample=s,event=action_pos(g))
def full(g,o,states,r):
 se=seed(g,o,states,r['seed'],True);rows=[se['after']];events=[se['events']];pads=[iso.Z];cuts=[]
 for _ in range(39):
  phase=g.read('gObjectPool[61].oTimer');es=[]
  for cut in r['cuts']:
   if cut['phase']==phase and cut['pos']:es.extend(place(g,cut['slot'],cut['pos']))
  if es:cuts.append(dict(phase=phase,edits=es))
  rows.append(advance(g,o,full=True));events.append(iso.frame_events(g));pads.append(iso.NEUTRAL)
  if rows[-1]['area']!=1:break
 arrival=next((s for s in rows if s['area']==2),None)
 capture=any(s['used']==64 and s['floorOwner']==s['platform']==61 for s in rows)
 useful=arrival is not None and arrival['M']==[365.5927734375,5500,-1096.8026123046875]
 return dict(recipe=r,seed=se,cuts=cuts,controls=pads,samples=rows,events=events,capture=capture,useful=useful)
def search(g,o,states):
 screens=[];stage2=[];final=[];candidates=[];seeds=[]
 # An earlier real shell/Z action constructor creates time for separate types
 # of actor instances on different updates; no action is supplied after it.
 for phase in [126,127]:
  for xz in [[-1920,-1210],[-1900,-1170],[-1940,-1210],[-1920,-1170],[-1900,-1210]]:
   sr=dict(phase=phase,xz=xz,speed=20);se=seed(g,o,states,sr);seeds.append(se)
   # First Bob shove is always one update after cancellation.
   state=g.save_state();local=[]
   for pos in candidate_positions(g,o,state,39):
    t=cut_trial(g,o,state,39,pos);r=dict(seed=sr,cuts=[dict(phase=phase+1,slot=39,pos=pos)])
    while g.read('gObjectPool[61].oTimer')<129:advance(g,o)
    s=snapshot(g,o,False);saved=g.save_state();row=dict(recipe=r,first=t,before129=s);screens.append(row);local.append((score(s),r,saved))
   local.sort(key=lambda x:x[0],reverse=True)
   # Explicit bounded beam: three first-stage outcomes per initial seed.
   for _,r,state129 in local[:3]:
    for pos in candidate_positions(g,o,state129,49):
     t=cut_trial(g,o,state129,49,pos);rr=dict(seed=sr,cuts=r['cuts']+[dict(phase=129,slot=49,pos=pos)])
     stage2.append(dict(recipe=rr,after129=t));candidates.append((score(t['sample']),rr,g.save_state()))
 candidates.sort(key=lambda x:x[0],reverse=True);selected=[]
 # Two explicit bounded rankings: horizontal pad proximity and producer Y.
 # Keep overlapping choices once; this remains a finite beam, not exhaustive.
 picked=candidates[:16]+sorted(candidates,key=lambda x:abs(snapshot_at(g,o,x[2])['M'][1]-1830))[:16]
 seen_routes=set();chosen=[]
 for item in picked:
  key=json.dumps(item[1],sort_keys=True)
  if key not in seen_routes:seen_routes.add(key);chosen.append(item)
 for _,r,state130 in chosen:
  for slot in [49,40]:
   for pos in candidate_positions(g,o,state130,slot,True):
    t=cut_trial(g,o,state130,slot,pos);accept=advance(g,o);rr=dict(seed=r['seed'],cuts=r['cuts']+[dict(phase=130,slot=slot,pos=pos)])
    capture=accept['used']==64 and accept['floorOwner']==accept['platform']==61
    row=dict(recipe=rr,producer=t,accept=accept,capture=capture);final.append(row)
    if capture:selected.append(rr);print('CAPTURE',rr,flush=True)
 # Preserve complete histories of positive captures plus best finite near misses.
 final.sort(key=lambda t:(int(t['capture']),int(t['producer']['sample']['floorY']==768),-pad_distance(t['producer']['sample'])),reverse=True)
 selected.extend(t['recipe']for t in final[:12]);seen=set();unique=[]
 for r in selected:
  key=json.dumps(r,sort_keys=True)
  if key not in seen:seen.add(key);unique.append(r)
 trials=[full(g,o,states,r)for r in unique]
 return dict(seeds=seeds,firstStage=screens,secondStage=stage2,producerScreens=final,trials=trials,counts=dict(seeds=len(seeds),firstStage=len(screens),secondStage=len(stage2),finalBeam=len(chosen),producerScreens=len(final),captures=sum(t['capture']for t in final),useful=sum(t['useful']for t in trials),completeHistories=len(trials),selectedBoundaries=sum(len(t['samples'])for t in trials)))
def snapshot_at(g,o,state):
 g.load_state(state);return snapshot(g,o,False)
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--pilot',action='store_true');ap.add_argument('--verify',type=Path);a=ap.parse_args()
 g,o,states,prep=roots();r=search(g,o,states);print('COUNTS',r['counts'],flush=True)
 if not a.pilot:
  q,qo,qs,qp=roots();assert prep==qp
  for t in r['trials']:assert t==full(q,qo,qs,t['recipe'])
  for s in r['seeds']:assert s==seed(q,qo,qs,s['recipe'])
 result=dict(schema=1,proofStart='c1f31bff1365055745d08fdd2728ac501378c4df',scope=__doc__,runtimeSha256=sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),preparation=prep,results=r,independentlyVerifiedSelectedHistories=not a.pilot)
 out=HERE/('pilot.json.gz'if a.pilot else'results.json.gz')
 if a.verify:assert json.loads(gzip.decompress(a.verify.read_bytes()))==json.loads(json.dumps(result))
 else:assert not out.exists();out.write_bytes(gzip.compress((json.dumps(result,separators=(',',':'))+'\n').encode(),mtime=0))
if __name__=='__main__':main()
