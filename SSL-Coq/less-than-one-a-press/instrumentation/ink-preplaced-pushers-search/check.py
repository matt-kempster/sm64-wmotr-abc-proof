"""Independent pre128 placement reconstruction, initial-cache fork, JP export.

Only the exact previously successful actor coordinates are tried. Both actor
positions are supplied before the initial airborne cut; no later gameplay
edits are permitted. Native callbacks, velocities, fuse and collision run.
The restored diagnostic action-substitution fork is not part of the history.
"""
import argparse,gzip,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
spec=importlib.util.spec_from_file_location('preplaced_independent',ROOT/'instrumentation/ink-enlarged-bob-handoff/search.py')
h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h);r=h.r;iso=h.iso
PRIOR=ROOT/'instrumentation/ink-enlarged-bob-handoff/positive-case.json'
CONTROL=ROOT/'instrumentation/ink-preplaced-pushers-controls/results.json.gz'

def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()

def run():
 prior=json.loads(PRIOR.read_text());g,o,states,prep=h.roots();phase=128
 g.load_state(states['released91',phase]);pre=[]
 for cut in prior['recipe']['cuts']:
  pre.append(dict(slot=cut['slot'],beforePhase=phase,originalPhase=cut['phase'],edits=r.place(g,cut['slot'],cut['pos'])))
 state=g.save_state();recipe=dict(profile='released91',seed=prior['recipe']['seed'],cuts=[])
 seed=r.seed(g,o,{phase:state},recipe['seed'],True)
 samples=[seed['after']];events=[seed['events']];controls=[iso.Z];dynamics=[];forks=[]
 for index in range(40):
  dynamics.append(dict(updateFromAirCut=index+1,bob={k:g.read('gObjectPool[39].'+k)for k in ['oBobombFuseTimer','oBobombFuseLit','oMoveFlags','oDistanceToMario']},box={k:g.read('gObjectPool[49].'+k)for k in ['oMoveFlags','oFloorHeight','oDistanceToMario']}))
  if samples[-1]['area']!=1:break
  assert g.mode=='controls'
  if g.read('gObjectPool[61].oTimer')==130:forks.append(dict(phase=130,result=h.shadow(g,o)))
  samples.append(r.advance(g,o,full=True));events.append(iso.frame_events(g));controls.append(iso.NEUTRAL)
 assert len(samples)==27 and samples[-1]['area']==2
 captured=False;retained=True
 for s in samples:
  if s['used']==64 and s['platform']==s['floorOwner']==61:captured=True
  if captured and s['area']==1 and s['platform']!=61:retained=False
 assert captured and retained and samples[-1]['M']==prior['expectedUsefulSpawn']
 assert forks[0]['result']['floorY']==768 and forks[0]['result']['floorOwner']==-1
 trial=dict(recipe=recipe,preplacedCuts=pre,seed=seed,samples=samples,events=events,controls=controls,dynamics=dynamics,diagnosticForks=forks,cuts=[],capture=captured,retainedObserved=retained,useful=True)
 comparison=json.loads(gzip.decompress(CONTROL.read_bytes()))['results']['trials'][1]
 assert comparison['recipe']['name']=='both-pre128'
 assert len(comparison['samples'])==len(samples)
 for actual,other in zip(samples,comparison['samples']):
  for k,v in actual.items():assert other[k]==v,k
 assert comparison['seed']==seed and comparison['events']==events
 return dict(preparation=prep,trial=trial)

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args()
 first=run();second=run();assert first==second
 t=first['trial'];install=first['preparation']['installs']['released91:128']
 initial=install['writes']+[e for c in t['preplacedCuts']for e in c['edits']]+t['seed']['edits']
 case=dict(schema=1,name='both-pushers-pre128',seedPhase=128,recipe=t['recipe'],profileInstall=install,preplacedCuts=t['preplacedCuts'],initialEdits=initial,cuts=[],controls=t['controls'],expectedRichSamples=t['samples'],events=t['events'],diagnosticForks=t['diagnosticForks'],expectedUsefulSpawn=t['samples'][-1]['M'],provenance=dict(priorCaseSha256=sha(PRIOR),independentControlsSha256=sha(CONTROL),independentFreshReconstructions=2,scope=__doc__))
 result=dict(schema=1,scope=__doc__,runtimeSha256=sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),independentFreshReconstructions=2,checkedPhysicalBoundaries=27,recipeCount=1,broaderSearchRun=False,allLaterGameplayWritesAreControllerOnly=True,results=first)
 outputs={'positive-case.json':(json.dumps(case,indent=2)+'\n').encode(),'results.json.gz':gzip.compress((json.dumps(result,separators=(',',':'))+'\n').encode(),mtime=0)}
 for name,data in outputs.items():
  path=HERE/name
  if a.verify:
   decode=lambda raw:json.loads(gzip.decompress(raw)if name.endswith('.gz')else raw)
   assert decode(path.read_bytes())==decode(data),name
  else:assert not path.exists();path.write_bytes(data)
 print('PASS both pre128, 27 boundaries, two fresh independent reconstructions; controls package agrees')
 print('INITIAL130',t['diagnosticForks'][0]['result'])
 for i,s in enumerate(t['samples'][:4]):
  print(128+i,'M',s['M'],'G',s['G'],'collisions',s['collisions'],'Bob',s['actors']['39'],'dynamics',t['dynamics'][i],'Box',s['actors']['49'],flush=True)
 print('EXPORTED',HERE/'positive-case.json')
if __name__=='__main__':main()
