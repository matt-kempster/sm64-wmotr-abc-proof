"""Hat-in-Hand actual Box throws and shell approaches from one initial cut.

Initial cap state, Box carry, remote HOLP, Mario pose and free native91 Bob
are diagnostic grants. Actual remote shell throw precedes them. There are
no later gameplay edits or A presses. This does not establish actor delivery.
"""
import argparse,gzip,importlib.util,json,struct
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def mod(name,path):
 s=importlib.util.spec_from_file_location(name,ROOT/path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
b=mod('hat_base','instrumentation/ink-shell-handsfree-placement/check.py')
r=b.r;iso=b.iso;h=b.h;cb=b.cb
def f32(x):return struct.unpack('<f',struct.pack('<f',x))[0]
def aim(phase,kind):
 if kind=='origin':return [b.BOX[0],1920,b.BOX[2]-32]
 n=129-(phase+3);v=40;dz=0
 for _ in range(n):v=f32(v-f32(v*v*.001));dz=f32(dz+v)
 # Heuristic only: all results are run through native floor/physics, not
 # inferred from this free-space approximation.
 dy=16+16*n-2*n*(n+1)
 return [b.BOX[0],1930-dy,f32(b.BOX[2]-32-dz)]
def snap(g,o):
 t=b.snap(g,o);t['marioFlags']=g.read('gMarioState.flags');return t
def trial(g,o,states,profile,q):
 g.load_state(states[q['phase']]);edits=list(h.h.p.install_profile(g.g,o,profile)['writes']);edits+=r.place(g,39,q.get('bob',b.BOB))
 pos=[b.AIR[0]+q.get('dx',0),q['y'],b.AIR[2]+q.get('dz',0)]
 cb.mario_cut(g,o,pos,'ACT_HOLD_FREEFALL',edits);cb.write(g,o,'gMarioState.vel',[0,q['vy'],0],edits)
 cb.write(g,o,'gMarioState.heldObj',g.address('gObjectPool[49]'),edits)
 cb.write(g,o,'gMarioState.usedObj',g.address('gObjectPool[49]'),edits)
 cb.write(g,o,'gMarioObject.oInteractStatus',0,edits)
 cb.write(g,o,'gObjectPool[49].oHeldState',g.constant('HELD_HELD'),edits)
 edits+=r.place(g,49,[pos[0],q['y']+60,pos[2]+100])
 cb.write(g,o,'gMarioState.marioBodyState.heldObjLastPosition',q.get('holp',aim(q['phase'],q['aim'])),edits)
 cb.write(g,o,'gMarioState.flags',(g.read('gMarioState.flags')&~0x10)|0x20,edits)
 before=snap(g,o);g.mode='controls';rows=[];events=[];pads=[]
 for i in range(45):
  phase=g.read('gObjectPool[61].oTimer');pad=iso.B if i==0 else iso.Z if phase==q.get('zPhase',128)else iso.NEUTRAL
  r.advance(g,o,pad,True);rows.append(snap(g,o));events.append(iso.frame_events(g));pads.append(pad)
  if rows[-1]['area']!=1:break
 captured=False;retained=True
 for x in rows:
  if x['used']==64 and x['platform']==x['floorOwner']==61:captured=True
  if captured and x['area']==1 and x['platform']!=61:retained=False
 release=next((dict(update=q['phase']+i,sample=x)for i,x in enumerate(rows)if x['held']==-1),None)
 mounts=[dict(update=q['phase']+i,event=e)for i,es in enumerate(events)for e in es if e['type']=='FLT_CHANGE_ACTION'and e.get('to')==g.constant('ACT_RIDING_SHELL_GROUND')]
 arrival=next((x for x in rows if x['area']==2),None)
 return dict(recipe=q,initialEdits=edits,beforeInitial=before,controls=pads,samples=rows,events=events,laterGameplayEdits=[],firstRelease=release,mounts=mounts,
  capture=captured,retainedObserved=retained if captured else None,arrival=arrival,useful=arrival is not None and arrival['M']==[365.5927734375,5500,-1096.8026123046875])
def menu():
 xs=[]
 for q in b.s.menu():
  if q['release']!='B':continue
  for a in ['origin','flight']:
   qq=dict(q);qq.pop('release');qq['aim']=a;xs.append(qq)
 return xs
def root():return b.root()
def main():
 p=argparse.ArgumentParser();p.add_argument('--verify',action='store_true');a=p.parse_args()
 g,o,states,profile,prep=root();trials=[]
 for i,q in enumerate(menu()):
  t=trial(g,o,states,profile,q);trials.append(t)
  if t['useful']:print('USEFUL',q,flush=True)
  if i%40==0:print('tested',i+1,flush=True)
 g2,o2,s2,p2,prep2=root();assert prep==prep2
 for t in trials:assert t==trial(g2,o2,s2,p2,t['recipe'])
 out=dict(schema=1,scope=__doc__,independentFreshRoots=2,allAReleased=True,preparation=prep,trials=trials)
 dst=HERE/'results.json.gz'
 if a.verify:assert json.loads(gzip.decompress(dst.read_bytes()))==out
 else:assert not dst.exists();dst.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
 print('RESULT',len(trials),'useful',sum(t['useful']for t in trials),'capture',sum(t['capture']for t in trials),'boundaries',sum(len(t['samples'])for t in trials),flush=True)
 for t in trials:
  if t['useful']or(t['mounts']and t['mounts'][0]['update']==128 and t['recipe']['aim']=='flight'):
   print('128MOUNT',t['recipe'],'release',t['firstRelease']['update']if t['firstRelease']else None,flush=True)
   for i,x in enumerate(t['samples']):
    if 128<=t['recipe']['phase']+i<=131:print(t['recipe']['phase']+i,x['M'],x['actionName'],'floor',x['floorY'],'Box',x['actors']['49']['position'],x['actors']['49']['activeFlags'],'collisions',x['collisions'],flush=True)
if __name__=='__main__':main()
