"""Bounded one-initial-cut Crazy Box release/approach search.

After the actual remote shell throw, one initial cut supplies Mario carrying
the Box, an exact native released91 Bob profile/placement and HOLP. Only no-A
controls follow. Bob delivery and the initial high carrying state are grants;
even a positive would not join all three actor acquisition/delivery histories.
"""
import argparse,gzip,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def mod(name,path):
 s=importlib.util.spec_from_file_location(name,ROOT/path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
h=mod('single_remote','instrumentation/ink-shell-remote-functionality/handoff.py')
j=mod('single_joint','instrumentation/ink-mario-pusher-delivery/controlled-bob/joint.py')
r=h.r;iso=h.iso;cb=j.cb
AIR=[-1962.4404296875,1810,-1243.34130859375]
BOB=[-2079.9365234375,1809.2066650390625,-1233.3045654296875]
BOX=[-2102.720703125,1920,-1119.5618896484375]
def root():
 raw,o,slot,base,spawn=iso.roots();pickup,held=iso.pickup(raw,o,slot,base)
 rel=h.release(raw,o,slot,held,[AIR[0],1800,AIR[2]])
 waits=[]
 while raw.read('gObjectPool[61].oTimer')<120:iso.advance(raw,iso.NEUTRAL);waits.append(iso.NEUTRAL)
 states={}
 for phase in range(120,127):states[phase]=raw.save_state();iso.advance(raw,iso.NEUTRAL)
 profiles=h.h.p.native_profiles();profile=profiles['profiles']['released91']
 return r.Guard(raw,slot),o,states,profile,dict(spawn=spawn,pickup=pickup,release=rel,waitControls=waits,donor=profiles)
def snap(g,o):
 s=j.snap(g,o);s['HOLP']=g.read('gMarioState.marioBodyState.heldObjLastPosition');return s
def trial(g,o,states,profile,q):
 g.load_state(states[q['phase']]);edits=list(h.h.p.install_profile(g.g,o,profile)['writes'])
 edits+=r.place(g,39,BOB)
 cb.mario_cut(g,o,[AIR[0],q['y'],AIR[2]],'ACT_HOLD_FREEFALL',edits)
 cb.write(g,o,'gMarioState.vel',[0,q['vy'],0],edits)
 cb.write(g,o,'gMarioState.heldObj',g.address('gObjectPool[49]'),edits)
 cb.write(g,o,'gMarioState.usedObj',g.address('gObjectPool[49]'),edits)
 cb.write(g,o,'gMarioObject.oInteractStatus',0,edits)
 cb.write(g,o,'gObjectPool[49].oHeldState',g.constant('HELD_HELD'),edits)
 # The carried Box's initial body position is supplied; every released XYZ
 # afterward comes from native release/callback behavior.
 edits+=r.place(g,49,[AIR[0],q['y']+60,AIR[2]+100])
 cb.write(g,o,'gMarioState.marioBodyState.heldObjLastPosition',[BOX[0],BOX[1],BOX[2]-(32 if q['release']=='B'else 0)],edits)
 before=snap(g,o);g.mode='controls';rows=[];events=[];pads=[]
 for i in range(45):
  phase=g.read('gObjectPool[61].oTimer')
  pad=(iso.B if q['release']=='B'else iso.Z)if i==0 else iso.Z if phase==128 else iso.NEUTRAL
  r.advance(g,o,pad,True);rows.append(snap(g,o));events.append(iso.frame_events(g));pads.append(pad)
  if rows[-1]['area']!=1:break
 cap=False;ret=True
 for s in rows:
  if s['used']==64 and s['platform']==s['floorOwner']==61:cap=True
  if cap and s['area']==1 and s['platform']!=61:ret=False
 arrival=next((s for s in rows if s['area']==2),None)
 release=next((dict(update=q['phase']+i,sample=s)for i,s in enumerate(rows)if s['held']==-1),None)
 mountEvents=[dict(update=q['phase']+i,event=e)for i,es in enumerate(events)for e in es if e.get('type')=='FLT_EXECUTE_ACTION'and e.get('action')==g.constant('ACT_RIDING_SHELL_GROUND')]
 return dict(recipe=q,initialEdits=edits,beforeInitial=before,laterGameplayEdits=[],controls=pads,samples=rows,events=events,
  firstRelease=release,mountEvents=mountEvents,capture=cap,retainedObserved=ret if cap else None,arrival=arrival,
  useful=arrival is not None and arrival['M']==[365.5927734375,5500,-1096.8026123046875])
def menu():
 qs=[]
 for phase in range(120,127):
  for vy in [-16,-32]:
   for y in [1850,1890,1930,1970,2010,2050,2090]:
    for release in ['B','Z']:qs.append(dict(phase=phase,y=y,vy=vy,release=release))
  n=128-phase;base=1810+16*n+2*n*(n-1)
  for dy in [-10,0,10]:qs.append(dict(phase=phase,y=base+dy,vy=-16,release='B'))
 return list({json.dumps(q,sort_keys=True):q for q in qs}.values())
def main():
 p=argparse.ArgumentParser();p.add_argument('--verify',action='store_true');a=p.parse_args()
 g,o,states,profile,prep=root();trials=[]
 for i,q in enumerate(menu()):
  t=trial(g,o,states,profile,q);trials.append(t)
  if t['useful']:print('USEFUL',q,flush=True)
  if i%40==0:print('tested',i+1,flush=True)
 q,qo,qs,qp,qr=root();assert prep==qr
 for t in trials:assert t==trial(q,qo,qs,qp,t['recipe'])
 out=dict(schema=1,scope=__doc__,allAReleased=True,independentFreshRoots=2,startRevision='ea1a4994f5157636f481723a89c6411a53e6e6d4',runtimeSha256=iso.sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),preparation=prep,trials=trials)
 dst=HERE/'results.json.gz'
 if a.verify:assert json.loads(gzip.decompress(dst.read_bytes()))==out
 else:assert not dst.exists();dst.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
 print('RESULT',len(trials),'useful',sum(t['useful']for t in trials),'capture',sum(t['capture']for t in trials),'arrival',sum(t['arrival']is not None for t in trials),'boundaries',sum(len(t['samples'])for t in trials),flush=True)
 for t in trials:
  if t['useful']or t['recipe']in[dict(phase=124,y=1890,vy=-16,release='B'),dict(phase=124,y=1890,vy=-16,release='Z')]:
   print('CASE',t['recipe'],'capture',t['capture'],flush=True)
   for i,s in enumerate(t['samples'][:10]):print(t['recipe']['phase']+i,s['M'],s['actionName'],'held',s['held'],'HOLP',s['HOLP'],'Box',s['actors']['49']['position'],s['actors']['49']['activeFlags'],'Bob',s['actors']['39']['position'],s['actors']['39']['activeFlags'],flush=True)
if __name__=='__main__':main()
