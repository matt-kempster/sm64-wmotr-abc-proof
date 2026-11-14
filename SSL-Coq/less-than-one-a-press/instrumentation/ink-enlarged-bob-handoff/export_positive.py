"""Independent reconstruction and generic original-JP recipe export.

No expanded earlier-frame search is run: the simpler direct-129 positive
found by the independent target study is replayed and checked here.
"""
import gzip,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import ROOT,HERE,roots,full,sha
path=ROOT/'instrumentation/ink-enlarged-bob-target/native-results.json.gz'
prior=json.loads(gzip.decompress(path.read_bytes()))['results']['trials'][0]
g,o,states,prep=roots();trial=full(g,o,states,prior['recipe'])
for k in prior:
 if k!='profileInstall':assert trial[k]==prior[k],k
assert trial['useful']
oracle=trial['diagnosticForks'][0];assert oracle['phase']==130 and oracle['result']['floorY']==768
q,qo,qs,qp=roots();repeat=full(q,qo,qs,prior['recipe']);assert prep==qp and trial==repeat
phase=prior['recipe']['seed']['phase'];name=prior['recipe']['profile'];install=prep['installs'][name+':'+str(phase)]
assert install==prior['profileInstall']
case=dict(schema=1,name='enlarged-bob-positive',seedPhase=phase,recipe=trial['recipe'],profileInstall=install,initialEdits=install['writes']+trial['seed']['edits'],cuts=trial['cuts'],controls=trial['controls'],expectedRichSamples=trial['samples'],events=trial['events'],diagnosticForks=trial['diagnosticForks'],expectedUsefulSpawn=[365.5927734375,5500,-1096.8026123046875],provenance=dict(sourceArtifactSha256=sha(path),independentFreshReconstructions=2,scope=__doc__))
(HERE/'positive-case.json').write_bytes((json.dumps(case,indent=2)+'\n').encode())
(HERE/'positive-reconstruction.json.gz').write_bytes(gzip.compress((json.dumps(dict(preparation=prep,trial=trial,independentlyVerified=True),separators=(',',':'))+'\n').encode(),mtime=0))
print('PASS independently reconstructed direct-129 positive twice, all prior selected boundaries match')
print('INITIAL130',oracle)
print('EXPORTED',HERE/'positive-case.json')
