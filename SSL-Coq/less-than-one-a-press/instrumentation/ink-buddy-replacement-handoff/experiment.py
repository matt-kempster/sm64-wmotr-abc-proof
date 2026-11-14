"""Conditional stock actor replacements for the supplied native slide fixture.

No pickup reference is supplied. Initial airborne Mario/shell preparation and
named actor XYZ cuts are explicit diagnostics, not actor delivery histories.
"""
import argparse,copy,gzip,hashlib,json,math,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/ink-item-native-slide-combinations'))
from search import roots as oldroots,make_seed,small,event,to_target,distance
from prelude import advance,NEUTRAL,write,f32,rich_sample,frame_events,digest
from fixtures import actor_snapshot,place_actor

SEED=dict(phase=128,pos=[-1922.4404296875,1810,-1223.34130859375],yaw=0,speed=20)
BOX129=[-1990.710693359375,1799.2869873046875,-1280.710693359375]
BUDDY129=[-2054.455810546875,1799.2869873046875,-1208.867919921875]
BOX130=[-2117.125244140625,1830.177978515625,-1128.1343994140625]

class Guard:
 def __init__(self,g,slot):self.g=g;self.slot=slot;self.mode='controls'
 def __getattr__(self,k):return getattr(self.g,k)
 def write(self,p,v):
  if self.mode=='controls':assert p in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},p
  if self.mode=='actor':assert p in {f'gObjectPool[{i}].oPos'+a for i in [6,7,13,15,23,38,39,40,44,45,49,54,self.slot] for a in 'XYZ'},p
  self.g.write(p,v)

def roots(capture):
 g,o,states,slot,prep=oldroots(capture)
 return Guard(g.g,slot),o,states,slot,prep

def cut(g,placements):
 g.mode='actor';edits=[]
 for slot,xyz in placements:
  for a,v in zip('XYZ',xyz):write(g,f'gObjectPool[{slot}].oPos'+a,v,edits)
 g.mode='controls';return edits

def full(g,o,states,r):
 phase=r['seed']['phase'];seed=make_seed(g,o,states[phase],g.slot,r['seed'],True)
 rows=[];events=[];actors=[];cuts=[]
 for i in range(35):
  p=r.get(str(phase+1+i),[])
  if p:cuts.append(dict(phase=phase+1+i,edits=cut(g,p)))
  advance(g,NEUTRAL);rows.append(rich_sample(g,o));events.append(frame_events(g))
  actors.append({str(slot):actor_snapshot(g,slot) for slot in sorted(set([g.slot,15,49]+[x[0]for v in [r.get('129',[]),r.get('130',[])]for x in v]))})
  if rows[-1]['area']!=1:break
 arrival=next((s for s in rows if s['area']==2),None)
 return dict(recipe=r,seed=seed,cuts=cuts,samples=rows,events=events,actors=actors,controls=[NEUTRAL]*len(rows),capture=any(s['used']==64 and s['floorOwner']==s['platform']==61 for s in rows),useful=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717))

def pack(path,data):
 with gzip.GzipFile(filename=str(path),mode='xb',mtime=0)as f:f.write((json.dumps(data,separators=(',',':'))+'\n').encode())

def substitutions(capture,out):
 g,o,states,slot,prep=roots(capture);q,qo,qs,qslot,qprep=roots(capture);assert prep==qprep
 recipes=[dict(name='old-buddy-positive-control',seed=SEED,**{'129':[[49,BOX129],[15,BUDDY129]],'130':[[49,BOX130]]}),dict(name='no-buddy-control',seed=SEED,**{'129':[[49,BOX129]],'130':[[49,BOX130]]})]
 for actor in [23,39,40,slot,6,13,38,54]:
  recipes.append(dict(name='replace-buddy-slot-'+str(actor),seed=SEED,**{'129':[[49,BOX129],[actor,BUDDY129]],'130':[[49,BOX130]]}))
 for actor in [23,39,40,slot]:
  close=[-2000,1799.2869873046875,-1210]
  for withbox in [False,True]:
   recipes.append(dict(name='registered-close-slot-'+str(actor)+'-box'+str(int(withbox)),seed=SEED,**{'129':([[49,BOX129]]if withbox else [])+[[actor,close]],'130':[[49,BOX130]]}))
 trials=[]
 for r in recipes:
  t=full(g,o,states,r);assert t==full(q,qo,qs,r);trials.append(t)
  print(r['name'],t['samples'][0]['movement'],t['samples'][0]['actionName'],'capture',t['capture'],'useful',t['useful'],flush=True)
 pack(out,dict(scope=__doc__,prefixSha256=digest(capture),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),preparation=prep,trials=trials,freshBoundaries=sum(len(t['samples'])+1 for t in trials)))

def inverse(capture,out,refined=False):
 g,o,states,slot,prep=roots(capture);start=time.time();counts=dict(seeds=0,groundSeeds=0,firstCuts=0,pad=0,producerCuts=0,capture=0,useful=0);best=[];positives=[];screens=[]
 # A supplied air initializer is used to isolate actor compatibility.
 # Native output determines support, carry, quarter steps and subsequent gaps.
 positions=[(x,z)for x in [-2260,-2220,-2180,-2140,-2100,-2060,-2020,-1980,-1940,-1900,-1860,-1820]for z in [-1290,-1250,-1210,-1170,-1130,-1090,-1050,-1010,-970,-930,-890,-850]]
 yaw_speeds=[(yaw,20)for yaw in [0,16384,32768,49152]]
 if refined:
  positions=[(x,z)for x in [-1940,-1930,-1922.4404296875,-1920,-1910,-1900]for z in [-1240,-1230,-1223.34130859375,-1220,-1210,-1190,-1170]]
  yaw_speeds=[(yaw,speed)for yaw in [0,8192,16384,49152,57344]for speed in [0,20,40,64]]
 for x,z in positions:
  for yaw,speed in yaw_speeds:
   sr=dict(phase=128,pos=[x,21700,z],yaw=yaw,speed=speed);make_seed(g,o,states[128],slot,sr);counts['seeds']+=1
   if g.read('gMarioState.action')!=g.constant('ACT_BUTT_SLIDE'):continue
   s0=small(g,o)
   if not 1740<=s0['movement'][1]<=1900:continue
   counts['groundSeeds']+=1;state=g.save_state();c=s0['collision']
   # Native shell is left exactly where cancellation put it in the first family.
   shell_candidates=[None]
   for radius in [40,80,86]:
    for angle in range(0,65536,4096 if refined else 8192):
     a=angle*math.tau/65536;shell_candidates.append([f32(c[0]+radius*math.sin(a)),c[1],f32(c[2]+radius*math.cos(a))])
   for shell in shell_candidates:
    g.load_state(state)
    p=[] if shell is None else [[slot,shell]]
    if p:cut(g,p)
    advance(g,NEUTRAL);ev=event(g)
    if ev is None:continue
    proposals=[None]
    for tx in [-2147,-2120,-2080,-2040,-2000,-1960]:
     for tz in [-1123,-1080,-1040,-1000,-960,-923]:
      b=to_target(ev['pos'],c,[tx,tz],107,112)
      if b is not None and b not in proposals:proposals.append(b)
    for box in proposals:
     cuts=p+([]if box is None else [[49,box]])
     if not cuts:continue
     g.load_state(state);cut(g,cuts);advance(g,NEUTRAL);s=small(g,o);ee=event(g);counts['firstCuts']+=1
     pad=distance(s['movement'])<.01 and s['action'] in [g.constant('ACT_BUTT_SLIDE'),g.constant('ACT_BUTT_SLIDE_STOP'),g.constant('ACT_CROUCH_SLIDE')]
     score=(int(pad),-distance(s['movement']),-abs(s['movement'][1]-1800))
     rec=dict(seed=sr,**{'129':cuts})
     best.append((score,rec));best.sort(key=lambda x:x[0],reverse=True);best=best[:8]
     if not pad:continue
     counts['pad']+=1;state130=g.save_state();advance(g,NEUTRAL);e130=event(g)
     bs=[None]
     for origin in [s['movement']]+([e130['pos']]if e130 else []):
      for tx in [-2220,-2210,-2190,-1890,-1882,-1874]:
       for tz in [-1120,-1075,-1023,-970,-939,-925]:
        b=to_target(origin,s['collision'],[tx,tz],107,112)
        if b is not None and b not in bs:bs.append(b)
     for b in bs:
      g.load_state(state130)
      if b:cut(g,[[49,b]])
      advance(g,NEUTRAL);producer=small(g,o);advance(g,NEUTRAL);accept=small(g,o);counts['producerCuts']+=1
      rr=dict(rec,**{'130':[[49,b]]})if b else rec
      if accept['used']==64 and accept['floorOwner']==accept['platform']==61:
       counts['capture']+=1;t=full(g,o,states,rr);counts['useful']+=int(t['useful']);positives.append(rr);print('POSITIVE',rr,'useful',t['useful'],flush=True)
      if len(screens)<150 or accept['used']==64:screens.append(dict(recipe=rr,producer=producer,accept=accept))
   if counts['seeds']%32==0:print('PROGRESS',counts,'best',best[0][0]if best else None,'elapsed',time.time()-start,flush=True)
  if positives:break
 q,qo,qs,qslot,qprep=roots(capture);assert prep==qprep;trials=[];seen=set()
 for r in positives+[r for _,r in best]:
  key=json.dumps(r,sort_keys=True)
  if key in seen:continue
  seen.add(key);t=full(g,o,states,r);assert t==full(q,qo,qs,r);trials.append(t)
 pack(out,dict(scope=__doc__,menu=dict(refined=refined,positions=positions,yawSpeeds=yaw_speeds,stopAtFirstPositivePosition=True),prefixSha256=digest(capture),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),preparation=prep,counts=counts,best=best,screens=screens,trials=trials,freshBoundaries=sum(len(t['samples'])+1 for t in trials),elapsed=time.time()-start))
 print('DONE',counts,'fresh',sum(len(t['samples'])+1for t in trials),flush=True)

def refined(capture,out):return inverse(capture,out,True)

def ground_trial(g,o,states,r):
 from prelude import pose
 g.load_state(states[128]);advance(g,NEUTRAL);advance(g,NEUTRAL)
 assert g.read('gObjectPool[61].oTimer')==130
 g.mode='setup';edits=[];pose(g,[-1950,r['height'],-939],edits)
 speed=0 if r['action']=='ACT_CRAWLING' else 20
 for k,v in [('action',g.constant(r['action'])),('actionState',0),('actionTimer',0),('forwardVel',speed),('vel',[speed,0,0]),('faceAngle',[0,16384,0]),('slideVelX',speed),('slideVelZ',0),('slideYaw',16384)]:write(g,'gMarioState.'+k,v,edits)
 xyz=[r['actorX'],r['height'],-939]
 if r.get('mode')=='carry_clone':place_actor(g,r['slot'],xyz,edits,'carry_clone')
 else:
  for a,v in zip('XYZ',xyz):write(g,f'gObjectPool[{r["slot"]}].oPos'+a,v,edits)
 g.mode='controls';initial=rich_sample(g,o);rows=[];events=[];actors=[];pads=[]
 for i in range(35):
  pad=dict(buttons=0x2000,stick=[0,64])if i==0 and r['action']=='ACT_CRAWLING'else NEUTRAL
  advance(g,pad);pads.append(pad);rows.append(rich_sample(g,o));events.append(frame_events(g));actors.append(actor_snapshot(g,r['slot']))
  if rows[-1]['area']!=1:break
 end=next((s for s in rows if s['area']==2),None)
 return dict(recipe=r,edits=edits,initial=initial,samples=rows,events=events,actors=actors,controls=pads,capture=any(s['used']==64 and s['floorOwner']==s['platform']==61 for s in rows),useful=end is not None and not(-460<=end['movement'][0]<=461 and -204<=end['movement'][2]<=717))

def ground(capture,out):
 g,o,states,slot,prep=roots(capture);q,qo,qs,qslot,qprep=roots(capture);assert prep==qprep
 trials=[]
 for height in [1741,25000,67277,90536]:
  for action in ['ACT_CRAWLING','ACT_BUTT_SLIDE']:
   for actor,x in [(49,-1989),(23,-1974),(39,-1979)]:
    r=dict(kind='supplied-ground-control',height=height,action=action,slot=actor,actorX=x)
    t=ground_trial(g,o,states,r);assert t==ground_trial(q,qo,qs,r);trials.append(t)
    print('GROUND',r,'after',t['samples'][0]['movement'],'capture',t['capture'],'useful',t['useful'],flush=True)
 pack(out,dict(scope='Supplied ground-action/height and actor XYZ only; no pickup-pointer writes; no delivery history.',prefixSha256=digest(capture),preparation=prep,trials=trials,freshBoundaries=sum(len(t['samples'])+1 for t in trials)))

def clones(capture,out):
 g,o,states,slot,prep=roots(capture);q,qo,qs,qslot,qprep=roots(capture);assert prep==qprep
 trials=[]
 for height in [1741,25000,67277,90536]:
  for action in ['ACT_CRAWLING','ACT_BUTT_SLIDE','ACT_DIVE_SLIDE']:
   for actor,x,mode in [(slot,-1971,'native'),(slot,-1971,'carry_clone'),(6,-1971,'carry_clone'),(13,-1971,'carry_clone'),(38,-1971,'carry_clone'),(54,-1971,'carry_clone')]:
    r=dict(kind='supplied-ground-clone-control',height=height,action=action,slot=actor,actorX=x,mode=mode)
    t=ground_trial(g,o,states,r);assert t==ground_trial(q,qo,qs,r);trials.append(t)
    print('CLONE',r,'after',t['samples'][0]['movement'],t['samples'][0]['actionName'],'capture',t['capture'],'useful',t['useful'],flush=True)
 pack(out,dict(scope='Supplied ground-action/height, actor XYZ and explicit valid non-HOLDABLE carry-script effects for carry_clone. No pickup-pointer writes or clone-acquisition/delivery history.',prefixSha256=digest(capture),preparation=prep,trials=trials,freshBoundaries=sum(len(t['samples'])+1 for t in trials)))

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('out',type=Path);p.add_argument('--mode',choices=['substitutions','inverse','refined','ground','clones'],default='substitutions');a=p.parse_args();globals()[a.mode](a.capture,a.out)
