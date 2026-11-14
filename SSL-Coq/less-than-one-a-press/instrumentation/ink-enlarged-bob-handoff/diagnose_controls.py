"""Independent replay and initial-cache diagnostics for the existing controls."""
import gzip,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import ROOT,HERE,roots,full,r,sha
path=ROOT/'instrumentation/ink-enlarged-bob-target/controls-results.json.gz'
prior=json.loads(gzip.decompress(path.read_bytes()))['results']['trials']
g,o,states,prep=roots();stock,so,ss,sp=r.roots();stockstates={('stock65',phase):s for phase,s in ss.items()}
out=[]
for old in prior:
 rec=old['recipe'];stockcase=rec['profile']=='stock65'
 trial=full(stock,so,stockstates,rec)if stockcase else full(g,o,states,rec)
 for k in old:
  if k not in['profileInstall','retainedObserved']:assert trial[k]==old[k],(rec['name'],k)
 out.append(trial)
 print(rec['name'],'initial130',trial['diagnosticForks'][0]['result'],'capture',trial['capture'],'useful',trial['useful'],flush=True)
 if rec['name']=='stock65-closer-100':
  case=dict(schema=1,name=rec['name'],seedPhase=rec['seed']['phase'],recipe=rec,profileInstall=None,initialEdits=trial['seed']['edits'],cuts=trial['cuts'],controls=trial['controls'],expectedRichSamples=trial['samples'],events=trial['events'],diagnosticForks=trial['diagnosticForks'],expectedUsefulSpawn=None,provenance=dict(sourceArtifactSha256=sha(path),scope=__doc__))
  (HERE/'stock65-closer-100-case.json').write_bytes((json.dumps(case,indent=2)+'\n').encode())
(HERE/'control-diagnostics.json.gz').write_bytes(gzip.compress((json.dumps(dict(schema=1,scope=__doc__,sourceArtifactSha256=sha(path),results=out,selectedPriorFieldsMatched=True),separators=(',',':'))+'\n').encode(),mtime=0))
print('PASS existing control histories independently match; diagnostic forks restored')
