"""Finite lower-air controls for the preplaced enlarged-Bob / Crazy Box recipe.

All actor positions, native released91 profile, initialized frozen shell, and
the one initial FREEFALL Mario state remain explicit grants. No later item or
Mario write enters the history. This tests compatibility, not delivery/ascent.
"""
import argparse,gzip,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('lower_approach_handoff',ROOT/'instrumentation/ink-enlarged-bob-handoff/search.py')
h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h);r=h.r;iso=h.iso
PRIOR=ROOT/'instrumentation/ink-preplaced-pushers-search/positive-case.json'

def menu():
 return [dict(name='same-xz-'+str(y),height=y,xz=[-1960,-1230],speed=0)for y in
         [19900,1768,1809.2066650390625,1810,1830,1900,2000,2099.514892578125]]

def trial(g,o,states,prep,prior,recipe):
 g.load_state(states['released91',128]);actor_edits=[]
 for cut in prior['preplacedCuts']:
  edits=cut['edits'];pos=[e['after']for e in edits];actor_edits.extend(r.place(g,cut['slot'],pos))
 x,z=recipe['xz'];y=recipe['height'];speed=recipe['speed']
 actor_edits.extend(r.place(g,g.slot,[x,y-10,z]))
 initial=[];g.mode='initial';iso.mario(g,o,[x,y,z],initial,speed=speed)
 iso.write(g,o,'gMarioState.vel',[0,-16,speed],initial);iso.write(g,o,'gMarioState.faceAngle',[0,0,0],initial)
 g.mode='controls';before=r.snapshot(g,o,True);samples=[];events=[];controls=[];forks=[]
 for i in range(45):
  if g.read('gObjectPool[61].oTimer')==130:
   forks.append(dict(beforeUpdate=i+1,result=h.shadow(g,o)))
  pad=iso.Z if i==0 else iso.NEUTRAL
  samples.append(r.advance(g,o,pad,True));events.append(iso.frame_events(g));controls.append(pad)
  if samples[-1]['area']!=1:break
 captured=False;retained=True
 for s in samples:
  if s['used']==64 and s['platform']==s['floorOwner']==61:captured=True
  if captured and s['area']==1 and s['platform']!=61:retained=False
 arrival=next((s for s in samples if s['area']==2),None)
 return dict(recipe=recipe,profileInstall=prep['installs']['released91:128'],actorEdits=actor_edits,
             initialMarioEdits=initial,before128=before,controls=controls,samples=samples,events=events,
             diagnosticForks=forks,capture=captured,retainedObserved=retained if captured else None,
             useful=arrival is not None and arrival['M']==prior['expectedUsefulSpawn'],arrival=arrival,
             allGameplayWritesAfterInitialCutAreControllerOnly=True)

def run():
 prior=json.loads(PRIOR.read_text());g,o,states,prep=h.roots();trials=[]
 for recipe in menu():
  t=trial(g,o,states,prep,prior,recipe);trials.append(t)
  print(recipe['name'],'capture',t['capture'],'useful',t['useful'],'after128',t['samples'][0]['M'],
        t['samples'][0]['actionName'],'after129',t['samples'][1]['M'],'cache130',t['diagnosticForks'],flush=True)
 assert trials[0]['samples']==prior['expectedRichSamples'] and trials[0]['events']==prior['events']
 return dict(preparation=prep,trials=trials)

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args()
 first=run();second=run();assert first==second
 result=dict(schema=1,scope=__doc__,runtimeSha256=h.sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),
             priorCaseSha256=h.sha(PRIOR),independentFreshReconstructions=2,results=first)
 data=(json.dumps(result,separators=(',',':'))+'\n').encode();path=HERE/'results.json.gz'
 if a.verify:assert json.loads(gzip.decompress(path.read_bytes()))==json.loads(data)
 else:assert not path.exists();path.write_bytes(gzip.compress(data,mtime=0))
 print('PASS',len(first['trials']),'histories,',sum(len(t['samples'])for t in first['trials']),
       'boundaries, independently replayed twice',flush=True)
if __name__=='__main__':main()
