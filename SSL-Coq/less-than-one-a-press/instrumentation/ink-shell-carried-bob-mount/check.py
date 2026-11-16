"""Remove the separate Mario relocation after native Bob release.

Actual remote shell throw and native Box drop precede one supplied held-Bob
approach. Only controls follow that approach. This is not actor acquisition.
"""
import argparse,gzip,importlib.util,json,itertools
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def mod(name,path):
 s=importlib.util.spec_from_file_location(name,ROOT/path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
h=mod('carried_remote','instrumentation/ink-shell-remote-functionality/handoff.py')
j=mod('carried_joint','instrumentation/ink-mario-pusher-delivery/controlled-bob/joint.py')
r=h.r;iso=h.iso;b=j.b;cb=j.cb
AIR=[-1962.4404296875,1810,-1243.34130859375]
def root():
 raw,o,slot,base,spawn=iso.roots();pickup,held=iso.pickup(raw,o,slot,base)
 release=h.release(raw,o,slot,held,[AIR[0],1800,AIR[2]])
 while raw.read('gObjectPool[61].oTimer')<126:iso.advance(raw,iso.NEUTRAL)
 dg,do,donor=b.n.profile.donor();profile=b.n.profile.detailed(dg,do)
 return r.Guard(raw,slot),o,raw.save_state(),profile['profile'],dict(spawn=spawn,pickup=pickup,release=release,donorPreparation=donor,donor=profile)
def snap(g,o):
 s=j.snap(g,o);s['bobVelocity']=[g.read('gObjectPool[39].oVel'+a)for a in 'XYZ'];s['HOLP']=g.read('gMarioState.marioBodyState.heldObjLastPosition');return s
def trial(g,o,state,fields,recipe):
 g.load_state(state);initial=[]
 cb.mario_cut(g,o,[5900,recipe['boxY'],3440],'ACT_HOLD_FREEFALL'if recipe.get('box',True)else'ACT_FREEFALL',initial)
 if recipe.get('box',True):
  cb.write(g,o,'gMarioState.heldObj',g.address('gObjectPool[49]'),initial)
  cb.write(g,o,'gObjectPool[49].oHeldState',g.constant('HELD_HELD'),initial)
  cb.write(g,o,'gMarioState.marioBodyState.heldObjLastPosition',[b.BOX[0],recipe['boxY'],b.BOX[2]],initial)
 before=snap(g,o);rows=[];events=[];controls=[]
 def step(pad):
  r.advance(g,o,pad,True);rows.append(snap(g,o));events.append(iso.frame_events(g));controls.append(pad)
 step(iso.Z)
 if recipe.get('phase',127)==128:step(iso.NEUTRAL)
 cut=b.held_setup(g,o,fields,'drop',[AIR[0]+recipe.get('dx',0),recipe['marioY'],AIR[2]+recipe.get('dz',0)])
 cb.write(g,o,'gMarioState.action',g.constant('ACT_HOLD_FREEFALL'),cut)
 cb.write(g,o,'gMarioState.actionArg',0,cut)
 cb.write(g,o,'gMarioState.vel',[0,recipe.get('vy',-16),0],cut)
 cb.write(g,o,'gMarioObject.oInteractStatus',8 if recipe.get('forced',True)else 0,cut)
 holp=[b.BOB[0]+recipe.get('bx',0),recipe['marioY'],b.BOB[2]+recipe.get('bz',0)]
 cb.write(g,o,'gMarioState.marioBodyState.heldObjLastPosition',holp,cut)
 beforeApproach=snap(g,o);g.mode='controls'
 for _ in range(46):
  phase=g.read('gObjectPool[61].oTimer')
  step(iso.Z if phase==recipe.get('zPhase',128)else iso.NEUTRAL)
  if rows[-1]['area']!=1:break
 captured=False;retained=True
 for s in rows:
  if s['used']==64 and s['floorOwner']==s['platform']==61:captured=True
  if captured and s['area']==1 and s['platform']!=61:retained=False
 arrival=next((s for s in rows if s['area']==2),None)
 return dict(recipe=recipe,initialEdits=initial,beforeInitial=before,
  cuts=[dict(phase=recipe.get('phase',127),edits=cut)],beforeApproach=beforeApproach,
  controls=controls,samples=rows,events=events,laterGameplayEdits=[],capture=captured,
  retainedObserved=retained if captured else None,arrival=arrival,
  useful=arrival is not None and arrival['M']==[365.5927734375,5500,-1096.8026123046875])
def menu():
 return [dict(boxY=by,marioY=my,phase=ph,vy=-16,forced=f)
  for by,my,ph,f in itertools.product([1920,1940,1980,2010],[1810,1830,1850,1870],[127,128],[True,False])]+[dict(boxY=1920,marioY=1810,phase=128,vy=-16,forced=False,box=False)]
def export(t,name):
 return dict(name=name,seedPhase=126,initialEdits=t['initialEdits'],cuts=t['cuts'],controls=t['controls'],
  expected=t['samples'],expectedRichSamples=t['samples'],sourceArtifact='instrumentation/ink-shell-carried-bob-mount/results.json.gz',
  shellPreparationHOLP=[AIR[0],1800,AIR[2]-32],shellTarget=[AIR[0],1800,AIR[2]],
  provenance=dict(scope=__doc__,nativeRemoteThrow=True,suppliedBoxCarry126=True,suppliedBobCarryApproach128=True,
  noMarioOrActorWritesAfterBobApproach=True,noShellXYZWritesAfterThrow=True,noBoxWritesAfter126=True,suppliedHOLP=True,
  suppliedBobExpiredDropStatus=t['recipe'].get('forced',True)))
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');ap.add_argument('--pilot',action='store_true');a=ap.parse_args()
 g,o,state,fields,prep=root();trials=[]
 for i,recipe in enumerate(menu()):
  t=trial(g,o,state,fields,recipe);trials.append(t)
  if t['useful']:print('USEFUL',recipe,flush=True)
  if i%32==0:print('tested',i+1,flush=True)
 out=dict(schema=1,scope=__doc__,allAReleased=True,preparation=prep,trials=trials)
 if not a.pilot:
  q,qo,qs,qf,qp=root();assert prep==qp
  for t in trials:assert t==trial(q,qo,qs,qf,t['recipe'])
  out['independentFreshReconstructions']=2
 p=HERE/('pilot.json.gz'if a.pilot else'results.json.gz')
 if a.verify:assert json.loads(gzip.decompress(p.read_bytes()))==json.loads(json.dumps(out))
 else:p.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
 if not a.pilot:
  positive=next(t for t in trials if t['recipe']==dict(boxY=1920,marioY=1810,phase=128,vy=-16,forced=False))
  negative=trials[-1];assert positive['useful']and positive['capture']and positive['retainedObserved']
  assert not negative['capture']and negative['arrival']['M']==[0,5500,256]
  for name,t in [('positive',positive),('no-box',negative)]:
   dst=HERE/(name+'.json');value=export(t,name)
   if a.verify:assert json.loads(dst.read_bytes())==value
   else:dst.write_bytes((json.dumps(value,indent=2)+'\n').encode())
 print('RESULT',len(trials),'useful',sum(t['useful']for t in trials),'capture',sum(t['capture']for t in trials),flush=True)
 for t in trials:
  if t['recipe']['boxY']==1920 and t['recipe']['marioY']==1810:
   print(t['recipe'],t['capture'],t['arrival']['M']if t['arrival']else None,flush=True)
   for s in t['samples'][:6]:print(s['topPhase'],s['M'],s['actionName'],'held',s['held'],'bob',s['actors']['39']['position'],s['actors']['39']['oHeldState'],'box',s['actors']['49']['position'],s['actors']['49']['activeFlags'],flush=True)
if __name__=='__main__':main()
