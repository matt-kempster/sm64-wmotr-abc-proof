"""Two focused lower1810 variants of the conditional joint native releases.

No controller-reached carrying state, HOLP or entry is claimed. Existing high
joint artifacts remain unchanged. Bob has no field edits after native release.
"""
import argparse,gzip,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
sp=importlib.util.spec_from_file_location('lower_joint_base',HERE/'joint.py');j=importlib.util.module_from_spec(sp);sp.loader.exec_module(j)
b=j.b;r=j.r;cb=j.cb
AIR=[-1962.4404296875,1810,-1243.34130859375]
COMPENSATED=[-2079.9365234375,b.BOB[1],-1233.3045654296875]

def trial(g,o,states,fields,compensate):
 g.load_state(states[126]);edits=r.place(g,g.slot,[AIR[0],1800,AIR[2]])
 cb.mario_cut(g,o,[5900,1920,3440],'ACT_HOLD_FREEFALL',edits)
 cb.write(g,o,'gMarioState.heldObj',g.address('gObjectPool[49]'),edits)
 cb.write(g,o,'gObjectPool[49].oHeldState',g.constant('HELD_HELD'),edits)
 cb.write(g,o,'gMarioState.marioBodyState.heldObjLastPosition',[b.BOX[0],1920,b.BOX[2]],edits)
 before=j.snap(g,o);r.advance(g,o,r.iso.Z,True);rows=[j.snap(g,o)];events=[r.iso.frame_events(g)];controls=[r.iso.Z]
 bob_edits=b.held_setup(g,o,fields,'drop',[5900,b.BOB[1],3440])
 if compensate:cb.write(g,o,'gMarioState.marioBodyState.heldObjLastPosition',COMPENSATED,bob_edits)
 r.advance(g,o,r.iso.NEUTRAL,True);rows.append(j.snap(g,o));events.append(r.iso.frame_events(g));controls.append(r.iso.NEUTRAL)
 air_edits=[];cb.mario_cut(g,o,AIR,'ACT_FREEFALL',air_edits)
 assert not any(e['path'].startswith('gObjectPool[')for e in air_edits)
 r.advance(g,o,r.iso.Z,True);rows.append(j.snap(g,o));events.append(r.iso.frame_events(g));controls.append(r.iso.Z)
 for _ in range(44):
  if rows[-1]['area']!=1:break
  r.advance(g,o,r.iso.NEUTRAL,True);rows.append(j.snap(g,o));events.append(r.iso.frame_events(g));controls.append(r.iso.NEUTRAL)
 captured=False;retained=True
 for s in rows:
  if s['used']==64 and s['floorOwner']==s['platform']==61:captured=True
  if captured and s['area']==1 and s['platform']!=61:retained=False
 arrival=next((s for s in rows if s['area']==2),None)
 return dict(compensatedBobHOLP=compensate,remoteBobCarrier=True,boxReleased=True,initialEdits=edits,beforeInitial=before,
  cuts=[dict(phase=127,edits=bob_edits),dict(phase=128,edits=air_edits)],
  laterGameplayEdits=[],controls=controls,samples=rows,events=events,capture=captured,retainedObserved=retained if captured else None,
  arrival=arrival,useful=arrival is not None and arrival['M']==[365.5927734375,5500,-1096.8026123046875])

def run():
 dg,do,donor=b.n.profile.donor();held=b.n.profile.detailed(dg,do);g,o,states,prep=r.roots()
 return dict(preparation=prep,heldDonor=dict(preparation=donor,snapshot=held),trials=[trial(g,o,states,held['profile'],c)for c in[False,True]])

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args()
 result=dict(schema=1,scope=__doc__,independentlyVerified=True,results=run());assert result['results']==run()
 out=HERE/'lower-joint-results.json.gz';files={}
 for t in result['results']['trials']:
  print('LOWER compensated',t['compensatedBobHOLP'],'capture',t['capture'],'useful',t['useful'],'arrival',t['arrival']['M']if t['arrival']else None,flush=True)
  for phase,s in enumerate(t['samples'][2:6],128):print(phase,s['M'],s['G'],s['actionName'],'Bob',s['actors']['39']['position'],s['actors']['39']['oHeldState'],'Box',s['actors']['49']['activeFlags'],'collisions',s['collisions'],flush=True)
  if t['useful']:
   e=j.export(t,'positive');e['sourceArtifact']='instrumentation/ink-mario-pusher-delivery/controlled-bob/lower-joint-results.json.gz';e['provenance']['sourceScope']=__doc__;e['provenance']['suppliedAirEntry128']=e['provenance'].pop('suppliedHighAirEntry128');e['provenance']['suppliedEntryY']=1810
   files[HERE/('lower-joint-compensated-positive.json'if t['compensatedBobHOLP']else'lower-joint-positive.json')]=e
 if a.verify:
  assert result==json.loads(gzip.decompress(out.read_bytes()))
  for p,v in files.items():assert json.loads(p.read_text())==v
 else:
  assert not out.exists();out.write_bytes(gzip.compress((json.dumps(result,separators=(',',':'))+'\n').encode(),mtime=0))
  for p,v in files.items():assert not p.exists();p.write_bytes((json.dumps(v,indent=2)+'\n').encode())
 print('PASS two twice-fresh lower joint controls',flush=True)
if __name__=='__main__':main()
