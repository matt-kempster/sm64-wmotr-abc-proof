"""Verify independent reconstruction/export consistency and package inventory."""
import argparse,gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(gzip.decompress(p.read_bytes())if p.suffix=='.gz'else p.read_bytes())
ap=argparse.ArgumentParser();ap.add_argument('--check',action='store_true');a=ap.parse_args()
case=read(HERE/'positive-case.json');recon=read(HERE/'positive-reconstruction.json.gz');trial=recon['trial']
assert recon['independentlyVerified']and trial['useful']and trial['capture']
for key,source in [('cuts','cuts'),('controls','controls'),('expectedRichSamples','samples'),('events','events'),('diagnosticForks','diagnosticForks')]:assert case[key]==trial[source]
assert case['initialEdits']==case['profileInstall']['writes']+trial['seed']['edits']
assert len(case['profileInstall']['writes'])==32
assert all(not pad['buttons']&32768 for pad in case['controls'])
assert trial['samples'][-1]['M']==[365.5927734375,5500,-1096.8026123046875]
assert case['provenance']['sourceArtifactSha256']==sha(ROOT/'instrumentation/ink-enlarged-bob-target/native-results.json.gz')
controls=read(HERE/'control-diagnostics.json.gz');assert controls['selectedPriorFieldsMatched']
assert controls['sourceArtifactSha256']==sha(ROOT/'instrumentation/ink-enlarged-bob-target/controls-results.json.gz')
assert len(controls['results'])==8 and sum(t['useful']for t in controls['results'])==1
shadow=read(HERE/'shadow-validation.json');assert shadow['fullSnapshotRestored']
assert shadow['positive']['floorY']==768 and shadow['negative']['floorY']==1933.4923095703125
note=ROOT/'docs/notes/ink-enlarged-bob-handoff.md'
files={p.relative_to(HERE).as_posix():sha(p)for p in sorted(HERE.rglob('*'))if p.is_file()and p.name!='verification.json'and '__pycache__'not in p.parts}
out=dict(schema=1,positiveIndependentFreshReconstructions=2,positiveBoundaries=len(trial['samples']),independentlyMatchedControls=8,controlBoundaries=sum(len(t['samples'])for t in controls['results']),knownNativeShadowChecks=2,expandedEarlierFrameMenuRun=False,noteSha256=sha(note),files=files)
target=HERE/'verification.json'
if a.check:assert read(target)==out
else:target.write_bytes((json.dumps(out,indent=2)+'\n').encode())
print('PASS independent positive, eight controls, two known-query diagnostics and inventory')
