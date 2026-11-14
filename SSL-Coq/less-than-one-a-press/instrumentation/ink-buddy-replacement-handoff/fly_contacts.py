"""Native Fly Guy/Fire Fly Guy contacts after native shell/Z slide entry.

Only the initial airborne Mario initializer and actor XYZ placements are supplied.
No Mario writes follow the shell/Z initializer. These are component tests, not
delivery or continuous controller histories.
"""
import argparse,collections,copy,math,time,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from experiment import roots,make_seed,SEED,BOX129,BOX130,cut,advance,NEUTRAL,small,event,full,pack,actor_snapshot,f32,digest

def run(capture,out):
 g,o,states,slot,prep=roots(capture);counts=collections.Counter();screens=[];selected={};baselines=[];start=time.time()
 menu=[(0,s)for s in [0,20,64,120]]+[(y,20)for y in [16384,24576,32768,57344]]
 for seed_yaw,speed in menu:
  sr=dict(SEED,speed=speed,yaw=seed_yaw);make_seed(g,o,states[128],slot,sr);state=g.save_state();before=small(g,o);c=before['collision']
  cut(g,[[49,BOX129]]);advance(g,NEUTRAL);baseline=small(g,o);baseevent=event(g)
  baselines.append(dict(seed=sr,before=before,after=baseline,event=baseevent))
  for actor in [38,44,45]:
   initialactor=actor_snapshot(g,actor)
   for dy in [-150,-100,-50,0,50,100,150]:
    for radius in [0,40,80,120]:
     for yaw in ([0]if radius==0 else range(0,65536,8192)):
      a=yaw*math.tau/65536;xyz=[f32(c[0]+radius*math.sin(a)),f32(c[1]+dy),f32(c[2]+radius*math.cos(a))]
      r=dict(name='native-fly-contact',seed=sr,actor=actor,offset=[radius,yaw,dy],**{'129':[[49,BOX129],[actor,xyz]],'130':[[49,BOX130]]})
      g.load_state(state);cut(g,r['129']);advance(g,NEUTRAL);s=small(g,o);e=event(g);actual=actor_snapshot(g,actor)
      counts['tested']+=1;registered=actor in s['collisions'];counts['registered']+=registered
      changed=s!=baseline;poschanged=math.dist(s['movement'],baseline['movement'])>.001
      counts['positionChanged']+=poschanged
      actionname=str(g.action_name(s['action'])) if hasattr(g,'action_name')else str(s['action'])
      key=(actor,seed_yaw,speed,registered,s['action'],poschanged,e['action']if e and 'action'in e else None)
      if key not in selected:selected[key]=r
      cut(g,r['130']);advance(g,NEUTRAL);producer=small(g,o);advance(g,NEUTRAL);accept=small(g,o)
      captured=accept['used']==64 and accept['floorOwner']==accept['platform']==61
      counts['captureScreens']+=captured
      if captured:selected[('positive',counts['tested'])]=r
      screens.append(dict(recipe=r,after=s,event=e,actor=actual,registered=registered,positionChanged=poschanged,producer=producer,accept=accept,capture=captured))
   print('CONTACTS',seed_yaw,speed,actor,dict(counts),'seconds',time.time()-start,flush=True)
 q,qo,qs,qslot,qprep=roots(capture);assert prep==qprep;trials=[]
 for r in selected.values():
  t=full(g,o,states,r);assert t==full(q,qo,qs,r);trials.append(t)
  counts['capture']+=t['capture'];counts['useful']+=t['useful']
 pack(out,dict(scope=__doc__,prefixSha256=digest(capture),preparation=prep,counts=dict(counts),menu=dict(seed=SEED,yawSpeeds=menu,actors=[38,44,45],yOffsets=[-150,-100,-50,0,50,100,150],radii=[0,40,80,120],angleStep=8192),baselines=baselines,screens=screens,trials=trials,freshBoundaries=sum(len(t['samples'])+1 for t in trials),elapsed=time.time()-start))
 print('DONE',dict(counts),'fullHistories',len(trials),flush=True)

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('out',type=Path);a=p.parse_args();run(a.capture,a.out)
