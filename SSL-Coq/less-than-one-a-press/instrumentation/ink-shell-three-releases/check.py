"""Actual remote shell throw plus two native pusher drops, with disclosed cuts.

The three releases are native and no actor is edited after its own release.
The post-shellthrow Box carry, subsequent Bob carry and Mario1810 approach
are still supplied. This compatibility join is NOT a no-later-position-edit
controller route. A is released for every advanced update.
"""
import argparse,gzip,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def mod(name,path):
 s=importlib.util.spec_from_file_location(name,ROOT/path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
remote=mod('joined_remote','instrumentation/ink-shell-remote-functionality/handoff.py')
j=mod('joined_drops','instrumentation/ink-mario-pusher-delivery/controlled-bob/joint.py')
r=remote.r;iso=remote.iso;b=j.b;cb=j.cb
AIR=[-1962.4404296875,1810,-1243.34130859375]
TARGET=[AIR[0],1800,AIR[2]]

def trial(raw,o,slot,state,fields,box=True,entry=True):
 raw.load_state(state);g=r.Guard(raw,slot);edits=[]
 cb.mario_cut(g,o,[5900,1920,3440],'ACT_HOLD_FREEFALL'if box else'ACT_FREEFALL',edits)
 if box:
  cb.write(g,o,'gMarioState.heldObj',g.address('gObjectPool[49]'),edits)
  cb.write(g,o,'gObjectPool[49].oHeldState',g.constant('HELD_HELD'),edits)
  cb.write(g,o,'gMarioState.marioBodyState.heldObjLastPosition',[b.BOX[0],1920,b.BOX[2]],edits)
 before=j.snap(g,o);r.advance(g,o,iso.Z,True)
 rows=[j.snap(g,o)];events=[iso.frame_events(g)];controls=[iso.Z]
 bob_edits=b.held_setup(g,o,fields,'drop',[5900,b.BOB[1],3440])
 r.advance(g,o,iso.NEUTRAL,True);rows.append(j.snap(g,o));events.append(iso.frame_events(g));controls.append(iso.NEUTRAL)
 air_edits=[]
 if entry:cb.mario_cut(g,o,AIR,'ACT_FREEFALL',air_edits)
 assert not any(e['path'].startswith('gObjectPool[')for e in air_edits)
 r.advance(g,o,iso.Z,True);rows.append(j.snap(g,o));events.append(iso.frame_events(g));controls.append(iso.Z)
 for _ in range(44):
  if rows[-1]['area']!=1:break
  r.advance(g,o,iso.NEUTRAL,True);rows.append(j.snap(g,o));events.append(iso.frame_events(g));controls.append(iso.NEUTRAL)
 all_edits=edits+bob_edits+air_edits
 assert not any(e['path'].startswith('gObjectPool[%d]'%slot)for e in all_edits)
 assert not any(e['path'].startswith('gObjectPool[49]')for e in bob_edits+air_edits)
 assert not any(e['path'].startswith('gObjectPool[39]')for e in air_edits)
 cap=False;ret=True
 for s in rows:
  if s['used']==64 and s['floorOwner']==s['platform']==61:cap=True
  if cap and s['area']==1 and s['platform']!=61:ret=False
 arrival=next((s for s in rows if s['area']==2),None)
 return dict(boxReleased=box,suppliedAirEntry=entry,initialEdits=edits,beforeInitial=before,
  cuts=[dict(phase=127,edits=bob_edits),dict(phase=128,edits=air_edits)],
  laterGameplayEdits=[],controls=controls,samples=rows,events=events,capture=cap,
  retainedObserved=ret if cap else None,arrival=arrival,
  useful=arrival is not None and arrival['M']==[365.5927734375,5500,-1096.8026123046875])

def run():
 raw,o,slot,base,spawn=iso.roots();pickup,held=iso.pickup(raw,o,slot,base)
 rel=remote.release(raw,o,slot,held,TARGET);wait=[];wait_samples=[]
 while raw.read('gObjectPool[61].oTimer')<126:
  iso.advance(raw,iso.NEUTRAL);wait.append(iso.NEUTRAL);wait_samples.append(iso.snap(raw,o,slot))
 assert raw.read('gObjectPool[61].oTimer')==126
 assert [raw.read('gObjectPool[%d].oPos'%slot+a)for a in'XYZ']==TARGET
 state=raw.save_state();dg,do,donor=b.n.profile.donor();held_bob=b.n.profile.detailed(dg,do)
 assert held_bob['profile']['hitboxRadius']==91 and held_bob['profile']['oHeldState']==1
 prep=dict(spawn=spawn,pickup=pickup,release=rel,waitControls=wait,waitSamples=wait_samples,
  heldDonor=dict(preparation=donor,snapshot=held_bob))
 return dict(preparation=prep,shellSlot=slot,shellTarget=TARGET,
  trials=[trial(raw,o,slot,state,held_bob['profile'],box,entry)for box,entry in[(True,True),(False,True),(True,False)]])

def export(t,name,data):
 return dict(name=name,seedPhase=126,initialEdits=t['initialEdits'],cuts=t['cuts'],controls=t['controls'],
  expectedRichSamples=t['samples'],expected=t['samples'],shellTarget=TARGET,
  shellPreparationHOLP=data['preparation']['release']['HOLPCut']['edits'][0]['after'],
  sourceArtifact='instrumentation/ink-shell-three-releases/results.json.gz',
  provenance=dict(sourceScope=__doc__,nativeRemoteShellThrow=True,nativeBoxDrop=t['boxReleased'],nativeBobDrop=True,
   noShellWritesAfterThrow=True,noBoxWritesAfterOwnRelease=True,noBobWritesAfterOwnRelease=True,
   suppliedSeparateCarryingStates=True,suppliedHOLP=True,suppliedAirEntry128=t['suppliedAirEntry'],
   continuousControllerRoute=False,noGameplayWritesAfter128=True))

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args()
 data=run();assert data==run()
 positive,negative,no_entry=data['trials']
 assert positive['useful']and positive['capture']and positive['retainedObserved']
 assert not negative['capture']and negative['arrival']['M']==[0,5500,256]
 assert not no_entry['useful']
 result=dict(schema=1,scope=__doc__,startRevision='ea1a4994f5157636f481723a89c6411a53e6e6d4',
  runtimeSha256=iso.sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),independentFreshRoots=2,allAReleased=True,results=data)
 out=HERE/'results.json.gz';files={HERE/'positive.json':export(positive,'positive',data),HERE/'no-box.json':export(negative,'no-box',data),HERE/'no-entry.json':export(no_entry,'no-entry',data)}
 if a.verify:
  assert json.loads(gzip.decompress(out.read_bytes()))==result
  for p,v in files.items():assert json.loads(p.read_bytes())==v
 else:
  assert not out.exists();out.write_bytes(gzip.compress((json.dumps(result,separators=(',',':'))+'\n').encode(),mtime=0))
  for p,v in files.items():assert not p.exists();p.write_bytes((json.dumps(v,indent=2)+'\n').encode())
 for t in data['trials']:
  print('JOIN box',t['boxReleased'],'entry',t['suppliedAirEntry'],'useful',t['useful'],'capture',t['capture'],'arrival',t['arrival']['M']if t['arrival']else None,flush=True)
  for phase,s in enumerate(t['samples'][:6],126):print(phase,s['M'],s['G'],s['actionName'],'held',s['held'],'Box',s['actors']['49']['position'],s['actors']['49']['activeFlags'],'Bob',s['actors']['39']['position'],s['actors']['39']['oHeldState'],'floor',s['floorY'],'collisions',s['collisions'],flush=True)
 print('PASS three independently reconstructed joins; only first is positive; later setup cuts disclosed',flush=True)
if __name__=='__main__':main()
