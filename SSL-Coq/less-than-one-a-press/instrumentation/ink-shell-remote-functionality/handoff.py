"""Native remote shell throw directly to the useful mount; no later shell XYZ edit.

Shell acquisition retains the existing conditional native fake-pickup root.
Only throw-time HOLP is supplied for remote placement. Pusher profile/XYZ and
Mario's later FREEFALL pose remain independent disclosed setup grants.
"""
import argparse,gzip,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def mod(name,path):
 s=importlib.util.spec_from_file_location(name,ROOT/path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
h=mod('remote_handoff_shared','instrumentation/ink-enlarged-bob-handoff/search.py');iso=h.iso;r=h.r

def release(g,o,slot,held,target):
 g.load_state(held);t=dict(target=target,initial=iso.snap(g,o,slot))
 for i in range(24):
  if i==6:
   assert g.read('gMarioState.action')==g.constant('ACT_THROWING')and g.read('gMarioState.actionTimer')==6
   assert g.read('gMarioState.faceAngle[1]')==0
   e=[];iso.write(g,o,'gMarioState.marioBodyState.heldObjLastPosition',[target[0],target[1],target[2]-32],e)
   t['HOLPCut']=dict(beforeUpdate=7,edits=e)
  s=iso.step(g,o,slot,t,iso.B if i==0 else iso.NEUTRAL)
  if s['held']==-1 and 'releaseUpdate'not in t:t['releaseUpdate']=i+1
 assert t['releaseUpdate']==7 and t['samples'][-1]['shell']['position']==target
 return t

def snapshot(g,o):
 s=r.snapshot(g,o,True);s['bobDynamics']={k:g.read('gObjectPool[39].'+k)for k in['oBobombFuseTimer','oVelX','oVelY','oVelZ']};return s

def one(raw,o,slot,held,pickup,spawn,profile,height,box):
 low=height==1810;x,z=(-1962.4404296875,-1243.34130859375)if low else(-1960,-1230)
 target=[x,height-10,z];rel=release(raw,o,slot,held,target);wait=[]
 while raw.read('gObjectPool[61].oTimer')<128:
  iso.advance(raw,iso.NEUTRAL);wait.append(iso.NEUTRAL)
 assert raw.read('gObjectPool[61].oTimer')==128
 g=r.Guard(raw,slot);install=h.p.install_profile(raw,o,profile);edits=list(install['writes'])
 bob=[-2079.9365234375,1809.2066650390625,-1233.3045654296875]if low else[-2080.06005859375,1809.2066650390625,-1230.322021484375]
 edits+=r.place(g,39,bob)
 if box:edits+=r.place(g,49,[-2102.720703125,1839.447265625,-1119.5618896484375])
 g.mode='initial';iso.mario(g,o,[x,height,z],edits,speed=0)
 iso.write(g,o,'gMarioState.vel',[0,-16,0],edits);iso.write(g,o,'gMarioState.faceAngle',[0,0,0],edits);g.mode='controls'
 assert not any(e['path'].startswith('gObjectPool[%d]'%slot)for e in edits)
 before=snapshot(g,o);samples=[];controls=[];events=[]
 for i in range(45):
  pad=iso.Z if i==0 else iso.NEUTRAL;r.advance(g,o,pad,True);samples.append(snapshot(g,o));controls.append(pad);events.append(iso.frame_events(g))
  if samples[-1]['area']!=1:break
 cap=False;ret=True
 for s in samples:
  if s['used']==64 and s['platform']==s['floorOwner']==61:cap=True
  if cap and s['area']==1 and s['platform']!=61:ret=False
 arrival=next((s for s in samples if s['area']==2),None)
 return dict(height=height,box=box,shellSlot=slot,shellTarget=target,shellPreparationHOLP=rel['HOLPCut']['edits'][0]['after'],preparation=dict(spawn=spawn,pickup=pickup,release=rel,waitControls=wait),initialEdits=edits,profileInstall=install,before128=before,cuts=[],controls=controls,samples=samples,events=events,capture=cap,retainedObserved=ret if cap else None,arrival=arrival,useful=arrival is not None and arrival['M']==[365.5927734375,5500,-1096.8026123046875])
def run():
 raw,o,slot,base,spawn=iso.roots();pick,held=iso.pickup(raw,o,slot,base);profile=h.p.native_profiles()['profiles']['released91']
 return [one(raw,o,slot,held,pick,spawn,profile,height,box)for height,box in[(1810,True),(19900,True),(1810,False)]]
def export(t,name):
 return dict(name=name,seedPhase=128,initialEdits=t['initialEdits'],cuts=[],controls=t['controls'],expected=t['samples'],expectedRichSamples=t['samples'],shellPreparationHOLP=t['shellPreparationHOLP'],shellTarget=t['shellTarget'],sourceArtifact='instrumentation/ink-shell-remote-functionality/handoff-results.json.gz',provenance=dict(scope=__doc__,nativeRemoteThrow=True,noShellXYZWritesAfterThrow=True,suppliedHOLP=True,suppliedPusherProfileAndPlacement=True,suppliedAirborneMario=True))
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args();data=run();assert data==run()
 assert all(t['useful']and t['capture']and t['retainedObserved']for t in data[:2])
 assert not data[2]['capture']and data[2]['arrival']['M']==[0,5500,256]
 out=dict(schema=1,scope=__doc__,independentFreshRoots=2,runtimeSha256=iso.sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),trials=data)
 dst=HERE/'handoff-results.json.gz';raw=(json.dumps(out,separators=(',',':'))+'\n').encode()
 cases={HERE/'low-positive.json':export(data[0],'low-positive'),HERE/'high-positive.json':export(data[1],'high-positive'),HERE/'no-box.json':export(data[2],'no-box')}
 if a.verify:
  assert json.loads(gzip.decompress(dst.read_bytes()))==json.loads(raw)
  for p,x in cases.items():assert json.loads(p.read_bytes())==x
 else:
  assert not dst.exists();dst.write_bytes(gzip.compress(raw,mtime=0))
  for p,x in cases.items():assert not p.exists();p.write_bytes((json.dumps(x,indent=2)+'\n').encode())
 for t in data:print('NATIVE THROW',t['height'],'box',t['box'],'shell',t['shellTarget'],'HOLP',t['shellPreparationHOLP'],'useful',t['useful'],'capture',t['capture'],'retained',t['retainedObserved'],'arrival',t['arrival']['M']if t['arrival']else None,flush=True)
 print('PASS three remote-throw handoff continuations twice')
if __name__=='__main__':main()
