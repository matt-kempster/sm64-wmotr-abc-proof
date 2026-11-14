"""Fresh native preplacement positive and zero-later-cut omission control."""
import argparse,copy,gzip,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('preplaced_check',HERE/'check.py');c=importlib.util.module_from_spec(s);s.loader.exec_module(c)
def pair():
 donors=c.n.profile.native_profiles();g,o,states,prep=c.r.roots();ps,installs=c.n.native_states(g,o,states,{'released91':donors['profiles']['released91']})
 positive=c.recipes()[1];negative=copy.deepcopy(positive);negative.update(name='bob-pre128-no-box',preplacedSlots=[39],omittedPlacementSlots=[49]);negative['originalRecipe']['cuts']=[x for x in negative['originalRecipe']['cuts']if x['slot']!=49]
 trials=[c.trial(g,o,ps['released91'],installs['released91'],q)for q in[positive,negative]]
 assert all(not t['laterCuts']for t in trials)
 assert trials[0]['useful']and trials[0]['capture']and trials[0]['retainedObserved']
 assert not trials[1]['capture']and not trials[1]['useful']and trials[1]['arrival']['M']==[0,5500,256]
 old=json.loads(gzip.decompress((HERE/'results.json.gz').read_bytes()))['results']['trials'][1]
 for k,v in trials[0].items():assert v==old[k],k
 for t in trials:
  for i,es in enumerate(t['events']):
   assert not t['samples'][i]['input']&0x82
 return dict(preparation=prep,donorProfile=donors['profiles']['released91'],trials=trials)
def export(t,name):
 initial=t['profileInstall']['writes']+[e for cut in t['preplacedCuts']for e in cut['edits']]+t['seed']['edits']
 return dict(name=name,seedPhase=128,initialEdits=initial,cuts=[],controls=t['controls'],expectedRichSamples=t['samples'],expected=t['samples'],profileInstall=t['profileInstall'],recipe=t['recipe'],sourceArtifact='instrumentation/ink-preplaced-pushers-controls/zero-later-cuts-pair.json.gz',sourceScope=__doc__,provenance=dict(nativeProfileTransplant=True,preplacedActors=t['recipe']['preplacedSlots'],noGameplayWritesAfterInitialAirCut=True,originalCrazyBoxRemainsInWorld=True))
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args();data=pair();fresh=pair();assert data==fresh
 out=dict(schema=1,scope=__doc__,runtimeSha256=c.sha(c.ROOT/'build/wafel-pilot/sm64_jp.dll'),independentlyVerifiedFreshRoots=True,checkedBoundaries=sum(t['observedUpdates']for t in data['trials']),results=data)
 p=HERE/'zero-later-cuts-pair.json.gz';cases={HERE/'both-pre128-positive.json':export(data['trials'][0],'positive'),HERE/'both-pre128-no-box.json':export(data['trials'][1],'no-final-box')}
 if a.verify:
  assert json.loads(gzip.decompress(p.read_bytes()))==json.loads(json.dumps(out))
  for path,result in cases.items():assert json.loads(path.read_text())==json.loads(json.dumps(result))
 else:
  assert not p.exists();p.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
  for path,result in cases.items():assert not path.exists();path.write_bytes((json.dumps(result,indent=2)+'\n').encode())
 print('PASS both-pre positive and Bob-pre/no-Box-placement ordinary control; no later writes; two fresh roots',flush=True)
 for t in data['trials']:print(t['recipe']['name'],t['observedUpdates'],t['arrival']['M'],t['samples'][2]['M'],t['samples'][2]['G'],t['samples'][2]['floorY'],flush=True)
if __name__=='__main__':main()
