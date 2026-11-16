"""Hands-free Box holding/HOLP compatibility from one supplied approach.

The remote shell throw is native. One initial cut then supplies an airborne
action retaining Box49, HOLP and an exact native free91 Bob profile/placement.
No hand/grab-position/render freeze is supplied; no gameplay writes follow.
This is conditional functionality, not hands-free acquisition or Bob delivery.
"""
import argparse,gzip,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def mod(name,path):
 s=importlib.util.spec_from_file_location(name,ROOT/path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
s=mod('handsfree_single','instrumentation/ink-shell-single-placement-start/check.py')
h=s.h;r=s.r;iso=s.iso;j=s.j;cb=s.cb;AIR=s.AIR;BOX=s.BOX;BOB=s.BOB
def root():
 raw,o,slot,base,spawn=iso.roots();pickup,held=iso.pickup(raw,o,slot,base)
 rel=h.release(raw,o,slot,held,[AIR[0],1800,AIR[2]])
 waits=[]
 while raw.read('gObjectPool[61].oTimer')<120:iso.advance(raw,iso.NEUTRAL);waits.append(iso.NEUTRAL)
 states={}
 for phase in range(120,129):states[phase]=raw.save_state();iso.advance(raw,iso.NEUTRAL)
 profiles=h.h.p.native_profiles()
 return r.Guard(raw,slot),o,states,profiles['profiles']['released91'],dict(spawn=spawn,pickup=pickup,release=rel,waitControls=waits,donor=profiles)
def snap(g,o):
 t=s.snap(g,o);t['bodyGrabPos']=g.read('gMarioState.marioBodyState.grabPos');t['bodyHandState']=g.read('gMarioState.marioBodyState.handState');return t
def trial(g,o,states,profile,q):
 g.load_state(states[q['phase']]);edits=list(h.h.p.install_profile(g.g,o,profile)['writes']);edits+=r.place(g,39,BOB)
 cb.mario_cut(g,o,[AIR[0],q['y'],AIR[2]],q['action'],edits)
 cb.write(g,o,'gMarioState.heldObj',g.address('gObjectPool[49]'),edits)
 cb.write(g,o,'gMarioState.usedObj',g.address('gObjectPool[49]'),edits)
 cb.write(g,o,'gMarioObject.oInteractStatus',0,edits)
 cb.write(g,o,'gObjectPool[49].oHeldState',g.constant('HELD_HELD'),edits)
 edits+=r.place(g,49,[AIR[0],q['y']+60,AIR[2]+100])
 cb.write(g,o,'gMarioState.marioBodyState.heldObjLastPosition',[BOX[0],BOX[1],BOX[2]],edits)
 assert not any(any(x in e['path']for x in ['grabPos','handState','node.flags','sharedChild'])and e['path'].startswith('gMario')for e in edits)
 before=snap(g,o);g.mode='controls';rows=[];events=[];pads=[]
 for i in range(45):
  phase=g.read('gObjectPool[61].oTimer')
  pad=iso.Z if phase==q.get('zPhase',128)else iso.B if i==0 and q['first']=='B'else iso.NEUTRAL
  r.advance(g,o,pad,True);rows.append(snap(g,o));events.append(iso.frame_events(g));pads.append(pad)
  if rows[-1]['area']!=1:break
 cap=False;ret=True
 for x in rows:
  if x['used']==64 and x['platform']==x['floorOwner']==61:cap=True
  if cap and x['area']==1 and x['platform']!=61:ret=False
 arrival=next((x for x in rows if x['area']==2),None)
 release=next((dict(update=q['phase']+i,sample=x)for i,x in enumerate(rows)if x['held']==-1),None)
 return dict(recipe=q,initialEdits=edits,beforeInitial=before,laterGameplayEdits=[],controls=pads,samples=rows,events=events,firstRelease=release,
  capture=cap,retainedObserved=ret if cap else None,arrival=arrival,useful=arrival is not None and arrival['M']==[365.5927734375,5500,-1096.8026123046875])
def menu():
 return [dict(phase=p,y=y,action=a,first=f)for p,y in[(128,1810),(127,1830),(126,1850),(124,1890),(120,1930),(124,1970)]
  for a in ['ACT_FREEFALL','ACT_DIVE','ACT_BUTT_SLIDE_AIR','ACT_HOLD_FREEFALL']for f in ['neutral','B']]
def main():
 p=argparse.ArgumentParser();p.add_argument('--verify',action='store_true');a=p.parse_args()
 g,o,states,profile,prep=root();trials=[trial(g,o,states,profile,q)for q in menu()]
 q,qo,qs,qp,qr=root();assert prep==qr
 for t in trials:assert t==trial(q,qo,qs,qp,t['recipe'])
 out=dict(schema=1,scope=__doc__,independentFreshRoots=2,allAReleased=True,runtimeSha256=iso.sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),preparation=prep,trials=trials)
 dst=HERE/'results.json.gz'
 if a.verify:assert json.loads(gzip.decompress(dst.read_bytes()))==out
 else:assert not dst.exists();dst.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
 print('RESULT',len(trials),'useful',sum(t['useful']for t in trials),'capture',sum(t['capture']for t in trials),'boundaries',sum(len(t['samples'])for t in trials),flush=True)
 for t in trials:
  print(t['recipe'],'useful',t['useful'],'firstHOLP',t['samples'][0]['HOLP'],'firstHeld',t['samples'][0]['held'],'firstAction',t['samples'][0]['actionName'],flush=True)
  if t['recipe']['phase']==128:
   for i,x in enumerate(t['samples'][:4]):print(128+i,x['M'],x['actionName'],'floor',x['floorY'],'Box',x['actors']['49']['position'],'collisions',x['collisions'],flush=True)
if __name__=='__main__':main()
