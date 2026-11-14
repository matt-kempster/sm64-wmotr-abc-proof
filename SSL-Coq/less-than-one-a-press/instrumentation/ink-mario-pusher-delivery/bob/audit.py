"""Read-only archive audit, plus an exact preserved controller-only predecessor."""
import gzip,hashlib,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
import search as s

def main():
 packs=[json.loads(gzip.decompress((s.HERE/n).read_bytes()))for n in ['results.json.gz','refined-results.json.gz']]
 trials=[t for p in packs for t in p['trials']]
 for t in trials:
  assert s.summarize(t)==t['summary']
  assert len(t['samples'])==len(t['controls'])+1
  assert all(not p['buttons']&0x8000 for p in t['controls'])
  assert all(not r['input']&0x82 for r in t['samples'])
  assert t['summary']['maxPillars']==0 and not t['summary']['survives']
  assert not any(r['topAction']==1 or r['area']!=1 for r in t['samples'])
 best=min(trials,key=lambda t:t['summary']['minimumDistance'])
 full=packs[0]['prefixControls']+best['controls']
 encoded=''.join(json.dumps(p,separators=(',',':'))+'\n'for p in full).encode()
 out=s.HERE/'closest-inputs.jsonl'
 assert out.read_bytes()==encoded
 raw=json.loads(gzip.decompress((s.HERE/'release-results.json.gz').read_bytes()))
 assert len(raw['cases'])==7 and all(r['gameplayEdits']==[]for r in raw['cases'])
 for r in raw['cases']:
  assert all(not p['buttons']&0x8000 for p in r['prefixControls']+r['controls'])
  assert all(not q['input']&0x82 for q in r['samples'])
 summary=dict(policyRows=len(trials),uniqueSuffixes=len({json.dumps(t['controls'],sort_keys=True)for t in trials}),
  branchUpdates=sum(len(t['controls'])for t in trials),closestPolicy=best['policy'],
  closestDistance=best['summary']['minimumDistance'],maximumHeldY=max(t['summary']['maximumHeldY']for t in trials),
  maximumLiveActorY=max(t['summary']['maximumLiveActorY']for t in trials),
  maximumRegrabs=max(t['summary']['regrabs']for t in trials),
  maximumHeldFuse=max(t['summary']['maxHeldFuse']for t in trials),
  selectedFullInputs=len(full),selectedInputSha256=hashlib.sha256(encoded).hexdigest(),
  releaseControls=len(raw['cases']),releaseBranchUpdates=sum(len(r['controls'])for r in raw['cases']),
  artifacts={p.name:s.sha(p)for p in s.HERE.glob('*.json.gz')})
 print(json.dumps(summary,indent=2))
if __name__=='__main__':main()
