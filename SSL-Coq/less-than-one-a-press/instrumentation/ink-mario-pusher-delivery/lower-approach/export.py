"""Export verified lower-air positive and exact uncompensated-Bob control."""
import gzip,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent

def main():
 for filename,index,name in [('compensated-results.json.gz',0,'positive'),('corrected-results.json.gz',1,'uncompensated-bob')]:
  source=HERE/filename;data=json.loads(gzip.decompress(source.read_bytes()));t=data['results']['trials'][index]
  case=dict(schema=1,name=name,seedPhase=128,recipe=dict(profile='released91',seed=dict(phase=128,**t['recipe']),cuts=[]),
            profileInstall=t['profileInstall'],initialEdits=t['profileInstall']['writes']+t['actorEdits']+t['initialMarioEdits'],
            cuts=[],controls=t['controls'],expectedRichSamples=t['samples'],events=t['events'],
            diagnosticForks=t['diagnosticForks'],capture=t['capture'],retainedObserved=t['retainedObserved'],useful=t['useful'],
            expectedUsefulSpawn=[365.5927734375,5500,-1096.8026123046875],
            provenance=dict(source=filename,trialIndex=index,independentFreshReconstructions=2,
                            scope='Supplied low FREEFALL/initialized frozen shell/Bob profile/actor positions; zero later gameplay edits. Wafel only.'))
  payload=(json.dumps(case,indent=2)+'\n').encode();out=HERE/(name+'-case.json')
  if '--verify'in sys.argv:assert json.loads(out.read_bytes())==case
  else:assert not out.exists();out.write_bytes(payload)
  print('EXPORTED',name,'capture',t['capture'],'useful',t['useful'],'boundaries',len(t['samples']))
if __name__=='__main__':main()
