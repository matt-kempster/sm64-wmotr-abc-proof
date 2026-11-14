"""Two actual native releases from separately supplied carrying states.

Crazy Box release126, Bob release127, supplied high FREEFALL128. This checks
native release compatibility only; the holds/HOLP and high journey are grants.
"""
import argparse,gzip,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
sp=importlib.util.spec_from_file_location('joint_bob',HERE/'test.py');b=importlib.util.module_from_spec(sp);sp.loader.exec_module(b)
cb=b.module('joint_box','instrumentation/ink-mario-pusher-delivery/controlled-box/check.py');r=b.r

def snap(g,o):
 s=cb.snap(g,o);s['bobFloorY']=g.read('gObjectPool[39].oFloorHeight');return s

def trial(g,o,states,fields,remote,box=True):
 g.load_state(states[126]);edits=r.place(g,g.slot,[-1960,19890,-1230])
 cb.mario_cut(g,o,[5900,1920,3440],'ACT_HOLD_FREEFALL'if box else'ACT_FREEFALL',edits)
 if box:
  cb.write(g,o,'gMarioState.heldObj',g.address('gObjectPool[49]'),edits)
  cb.write(g,o,'gObjectPool[49].oHeldState',g.constant('HELD_HELD'),edits)
  cb.write(g,o,'gMarioState.marioBodyState.heldObjLastPosition',[b.BOX[0],1920,b.BOX[2]],edits)
 before=snap(g,o);r.advance(g,o,r.iso.Z,True);rows=[snap(g,o)];events=[r.iso.frame_events(g)];controls=[r.iso.Z]
 bob_edits=b.held_setup(g,o,fields,'drop',[5900,b.BOB[1],3440]if remote else None)
 r.advance(g,o,r.iso.NEUTRAL,True);rows.append(snap(g,o));events.append(r.iso.frame_events(g));controls.append(r.iso.NEUTRAL)
 air_edits=[];cb.mario_cut(g,o,[-1960,19900,-1230],'ACT_FREEFALL',air_edits)
 assert not any(e['path'].startswith('gObjectPool[')for e in air_edits)
 r.advance(g,o,r.iso.Z,True);rows.append(snap(g,o));events.append(r.iso.frame_events(g));controls.append(r.iso.Z)
 for _ in range(44):
  if rows[-1]['area']!=1:break
  r.advance(g,o,r.iso.NEUTRAL,True);rows.append(snap(g,o));events.append(r.iso.frame_events(g));controls.append(r.iso.NEUTRAL)
 captured=False;retained=True
 for s in rows:
  if s['used']==64 and s['floorOwner']==s['platform']==61:captured=True
  if captured and s['area']==1 and s['platform']!=61:retained=False
 arrival=next((s for s in rows if s['area']==2),None)
 return dict(remoteBobCarrier=remote,boxReleased=box,initialEdits=edits,beforeInitial=before,
  cuts=[dict(phase=127,edits=bob_edits),dict(phase=128,edits=air_edits)],
  laterGameplayEdits=[],controls=controls,samples=rows,events=events,capture=captured,retainedObserved=retained if captured else None,
  arrival=arrival,useful=arrival is not None and arrival['M']==[365.5927734375,5500,-1096.8026123046875])

def run():
 dg,do,donor=b.n.profile.donor();held=b.n.profile.detailed(dg,do)
 g,o,states,prep=r.roots();trials=[trial(g,o,states,held['profile'],remote,box)for remote,box in[(False,True),(True,True),(True,False)]]
 return dict(preparation=prep,heldDonor=dict(preparation=donor,snapshot=held),trials=trials)

def export(t,name):
 return dict(name=name,seedPhase=126,initialEdits=t['initialEdits'],cuts=t['cuts'],controls=t['controls'],
  expectedRichSamples=t['samples'],expected=t['samples'],sourceArtifact='instrumentation/ink-mario-pusher-delivery/controlled-bob/joint-results.json.gz',
  provenance=dict(sourceScope=__doc__,suppliedBoxHeldReference=t['boxReleased'],suppliedBobHeldReference=True,
   nativeHeldBobProfileTransplant=True,suppliedHOLP=True,suppliedMarioCarryingStates=True,suppliedHighAirEntry128=True,
   noBoxWritesAfter126Release=True,noBobWritesAfter127Release=True,noGameplayWritesAfter128Entry=True))

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args()
 result=dict(schema=1,scope=__doc__,independentlyVerified=True,results=run());assert result['results']==run()
 for t in result['results']['trials']:
  print('JOINT remote',t['remoteBobCarrier'],'box',t['boxReleased'],'capture',t['capture'],'useful',t['useful'],'arrival',t['arrival']['M']if t['arrival']else None,flush=True)
  for phase,s in enumerate(t['samples'][:6],126):print(phase,s['M'],s['actionName'],'held',s['held'],'Box',s['actors']['49']['position'],s['actors']['49']['activeFlags'],'Bob',s['actors']['39']['position'],s['actors']['39']['oHeldState'],s['bobFuse'],'collisions',s['collisions'],flush=True)
 out=HERE/'joint-results.json.gz';files={}
 positive=next((t for t in result['results']['trials']if t['remoteBobCarrier']and t['useful']),None)
 if positive:
  files[HERE/'joint-positive.json']=export(positive,'positive')
  negative=next(t for t in result['results']['trials']if not t['boxReleased'])
  files[HERE/'joint-no-box.json']=export(negative,'no-final-box')
 if a.verify:
  assert result==json.loads(gzip.decompress(out.read_bytes()))
  for p,v in files.items():assert json.loads(p.read_text())==v
 else:
  assert not out.exists();out.write_bytes(gzip.compress((json.dumps(result,separators=(',',':'))+'\n').encode(),mtime=0))
  for p,v in files.items():assert not p.exists();p.write_bytes((json.dumps(v,indent=2)+'\n').encode())
 print('PASS three twice-fresh joint release histories',flush=True)
if __name__=='__main__':main()
