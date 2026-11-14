"""Finite 0/1/2-update preplacement lead with no actor writes at the air cut.

All three actor positions and the Bob donor profile are supplied at top phase
128-lead. Mario then follows the unchanged conditional preparation history
with neutral input until128, when Mario alone receives the airborne cut.
"""
import argparse,gzip,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
import check as c
h=c.h;r=c.r;iso=c.iso

def trial(g,o,states,prep,prior,lead):
 phase=128-lead;g.load_state(states['released91',phase]);cuts=[]
 for cut in prior['recipe']['cuts']:
  cuts.extend(r.place(g,cut['slot'],cut['pos']))
 cuts.extend(r.place(g,71,[-1960,19890,-1230]))
 waiting=[r.snapshot(g,o,True)]
 for _ in range(lead):waiting.append(r.advance(g,o,full=True))
 assert g.read('gObjectPool[61].oTimer')==128
 edits=[];g.mode='initial';iso.mario(g,o,[-1960,19900,-1230],edits,speed=0)
 iso.write(g,o,'gMarioState.vel',[0,-16,0],edits);iso.write(g,o,'gMarioState.faceAngle',[0,0,0],edits)
 g.mode='controls';before=r.snapshot(g,o,True);samples=[r.advance(g,o,iso.Z,True)];events=[iso.frame_events(g)];controls=[iso.Z];forks=[]
 for _ in range(39):
  if samples[-1]['area']!=1:break
  if g.read('gObjectPool[61].oTimer')==130:forks.append(dict(phase=130,result=h.shadow(g,o)))
  samples.append(r.advance(g,o,full=True));events.append(iso.frame_events(g));controls.append(iso.NEUTRAL)
 captured=False;retained=True
 for s in samples:
  if s['used']==64 and s['platform']==s['floorOwner']==61:captured=True
  if captured and s['area']==1 and s['platform']!=61:retained=False
 useful=samples[-1]['area']==2 and samples[-1]['M']==prior['expectedUsefulSpawn']
 return dict(leadUpdates=lead,placementPhase=phase,profileInstall=prep['installs']['released91:'+str(phase)],actorEdits=cuts,waitControls=[iso.NEUTRAL]*lead,waitSamples=waiting,initialMarioEdits=edits,before128=before,controls=controls,samples=samples,events=events,diagnosticForks=forks,capture=captured,retainedObserved=retained if captured else None,useful=useful,allGameplayWritesAfterInitialMarioCutAreControllerOnly=True)

def run():
 prior=json.loads(c.PRIOR.read_text());g,o,states,prep=h.roots()
 trials=[trial(g,o,states,prep,prior,lead)for lead in [0,1,2]]
 baseline=json.loads((c.HERE/'positive-case.json').read_text())
 assert trials[0]['samples']==baseline['expectedRichSamples'] and trials[0]['events']==baseline['events']
 return dict(preparation=prep,trials=trials)

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args()
 first=run();second=run();assert first==second
 result=dict(schema=1,scope=__doc__,independentFreshReconstructions=2,results=first)
 data=(json.dumps(result,separators=(',',':'))+'\n').encode();path=c.HERE/'waiting-results.json.gz'
 if a.verify:assert json.loads(gzip.decompress(path.read_bytes()))==json.loads(data)
 else:assert not path.exists();path.write_bytes(gzip.compress(data,mtime=0))
 for t in first['trials']:
  print('LEAD',t['leadUpdates'],'capture',t['capture'],'retained',t['retainedObserved'],'useful',t['useful'],'arrival',t['samples'][-1]['M'],'updates',len(t['samples']),flush=True)
  for s in t['waitSamples']:print('  wait top',s['topPhase'],'M',s['M'],'G',s['G'],'Bob',s['actors']['39']['position'],'Box',s['actors']['49']['position'],flush=True)
  print('  initial130',t['diagnosticForks'],flush=True)
 print('PASS independently replayed all three lead cases twice')
if __name__=='__main__':main()
