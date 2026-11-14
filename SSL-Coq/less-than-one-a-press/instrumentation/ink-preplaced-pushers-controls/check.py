"""Four finite controls moving the existing two actor XYZ cuts before128.

Uses the established native released91 donor profile and frozen-shell root.
The transplanted donor/high-air setup remains conditional. Native actor
callbacks, velocity, fuse, scaling and deletion are never frozen. The both-
preplaced case makes no gameplay writes after the one initial FREEFALL cut.
"""
import argparse,copy,gzip,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def module(name,path):
 s=importlib.util.spec_from_file_location(name,ROOT/path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
n=module('preplaced_native','instrumentation/ink-enlarged-bob-target/native.py');r=n.r
POSITIVE=ROOT/'instrumentation/ink-enlarged-bob-target/native-results.json.gz'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def snap(g,o):
 s=r.snapshot(g,o,True);s['bobDynamics']={k:g.read('gObjectPool[39].'+k)for k in ['oBobombFuseTimer','oBobombFuseLit','oPrevAction','oMoveFlags','oHomeX','oHomeY','oHomeZ','oDistanceToMario']}
 s['boxDynamics']={k:g.read('gObjectPool[49].'+k)for k in ['oPrevAction','oMoveFlags','oHomeX','oHomeY','oHomeZ','oDistanceToMario','oFloorHeight']}
 return s
def recipes():
 positive=json.loads(gzip.decompress(POSITIVE.read_bytes()))['results']['trials'][0]['recipe']
 assert positive['seed']==dict(phase=128,xz=[-1960,-1230],speed=0)
 return [dict(name=name,preplacedSlots=slots,originalRecipe=copy.deepcopy(positive))for name,slots in [('original-staged',[]),('both-pre128',[39,49]),('bob-pre128-box130',[39]),('box-pre128-bob129',[49])]]
def trial(g,o,states,profileInstall,recipe):
 original=recipe['originalRecipe'];phase=original['seed']['phase'];g.load_state(states[phase]);pre=[]
 for cut in original['cuts']:
  if cut['slot']in recipe['preplacedSlots']:pre.append(dict(originalPhase=cut['phase'],beforePhase=phase,slot=cut['slot'],edits=r.place(g,cut['slot'],cut['pos'])))
 seeded=r.seed(g,o,{phase:g.save_state()},original['seed'],True)
 t=dict(recipe=recipe,profileInstall=profileInstall,preplacedCuts=pre,seed=seeded,laterCuts=[],controls=[r.iso.Z],samples=[snap(g,o)],events=[r.iso.frame_events(g)])
 for _ in range(44):
  phase=g.read('gObjectPool[61].oTimer')
  for cut in original['cuts']:
   if cut['slot']not in recipe['preplacedSlots']and cut['phase']==phase:
    t['laterCuts'].append(dict(beforePhase=phase,slot=cut['slot'],edits=r.place(g,cut['slot'],cut['pos'])))
  r.advance(g,o);t['samples'].append(snap(g,o));t['events'].append(r.iso.frame_events(g));t['controls'].append(r.iso.NEUTRAL)
  if t['samples'][-1]['area']!=1:break
 if recipe['name']=='both-pre128':assert not t['laterCuts']
 captured=False;retained=True
 for s in t['samples']:
  if s['used']==64 and s['platform']==s['floorOwner']==61:captured=True
  if captured and s['area']==1 and s['platform']!=61:retained=False
 arrival=next((s for s in t['samples']if s['area']==2),None)
 t.update(capture=captured,retainedObserved=retained if captured else None,arrival=arrival,useful=arrival is not None and arrival['M']==[365.5927734375,5500,-1096.8026123046875],observedUpdates=len(t['samples']),boundedAt45=len(t['samples'])==45 and arrival is None)
 return t
def run():
 donors=n.profile.native_profiles();g,o,states,prep=r.roots();ps,installs=n.native_states(g,o,states,{'released91':donors['profiles']['released91']})
 ts=[trial(g,o,ps['released91'],installs['released91'],recipe)for recipe in recipes()]
 baseline=ts[0];assert baseline['useful']and baseline['capture']and baseline['retainedObserved']
 prior=json.loads(gzip.decompress(POSITIVE.read_bytes()))['results']['trials'][0]
 for s,old in zip(baseline['samples'],prior['samples']):
  for k,v in old.items():assert s[k]==v,(k,s[k],v)
 assert len(baseline['samples'])==len(prior['samples'])
 for t in ts:
  comparable=['M','C','G','action','actionState','actionTimer','floorY','floorOwner','platform','used','ridden','collisions']
  differences=[dict(updateFromAirCut=i+1,completedTopPhase=128+i,changed={k:dict(staged=a[k],trial=b[k])for k in comparable if a[k]!=b[k]})for i,(a,b)in enumerate(zip(baseline['samples'],t['samples']))if any(a[k]!=b[k]for k in comparable)]
  t['firstRecordedMarioOrContactDifferenceFromStaged']=next(iter(differences),None)
  t['firstFourDifferences']=differences[:4]
 return dict(preparation=prep,donorProfile=donors['profiles']['released91'],trials=ts)
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',type=Path);a=ap.parse_args();data=run();fresh=run();assert data==fresh
 out=dict(schema=1,scope=__doc__,runtimeSha256=sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),priorPositiveSha256=sha(POSITIVE),independentlyVerifiedFreshRoots=True,maximumUpdatesFromAirCut=45,checkedBoundaries=sum(t['observedUpdates']for t in data['trials']),results=data)
 if a.verify:assert json.loads(gzip.decompress(a.verify.read_bytes()))==json.loads(json.dumps(out))
 else:
  p=HERE/'results.json.gz';assert not p.exists();p.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
 for t in data['trials']:
  print(t['recipe']['name'],'updates',t['observedUpdates'],'capture',t['capture'],'useful',t['useful'],'arrival',t['arrival']['M']if t['arrival']else None,flush=True)
  for i,s in enumerate(t['samples'][:5]):
   b=s['actors']['39'];x=s['actors']['49'];print(' ',128+i,'M',s['M'],'G',s['G'],'action',s['actionName'],'floor',s['floorY'],'platform',s['platform'],'collisions',s['collisions'],'Bob',b['position'],b['hitboxRadius'],b['oAction'],b['oTimer'],s['bobDynamics']['oBobombFuseTimer'],'Box',x['position'],x['oAction'],x['oTimer'],flush=True)
 print('PASS four histories',out['checkedBoundaries'],'boundaries, two independent fresh roots',flush=True)
if __name__=='__main__':main()
