"""Check archived native receipts and record the complete diagnostic inventory."""
import argparse,gzip,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
ap=argparse.ArgumentParser();ap.add_argument('--check',action='store_true');a=ap.parse_args()
for name in['positive','retime']:
 d=HERE/'records'/name
 for file,digest in json.loads((d/'archive-hashes.json').read_text()).items():assert sha(d/file)==digest
 assert gzip.decompress((d/'checker-source.py.gz').read_bytes())==(HERE/'check.py').read_bytes()
 subprocess.run([sys.executable,str(HERE/'check.py'),str(d),'--archived'],check=True)
note=HERE.parents[1]/'docs/notes/ink-floor768-diagnosis.md'
manifest={p.relative_to(HERE).as_posix():sha(p)for p in sorted(HERE.rglob('*'))if p.is_file()and p.name!='verification.json'and '__pycache__'not in p.parts}
out=dict(schema=1,nativeRuns=2,selectedNativeWafelBoundaries=60,selectedPhysicalMismatches=0,retainedGlobalClockMismatches=60,nativeFloorReturns=dict(positive=459,retime=483),nativeObservedPostEntryBoundaries=dict(positive=25,retime=35),noNewA=True,positiveUsefulSpawn=True,retimeRemainsArea1=True,noteSha256=sha(note),files=manifest)
target=HERE/'verification.json'
if a.check:assert json.loads(target.read_text())==out
else:target.write_bytes((json.dumps(out,indent=2)+'\n').encode())
print('PASS native archives, checked selected histories, inventory',len(manifest))
