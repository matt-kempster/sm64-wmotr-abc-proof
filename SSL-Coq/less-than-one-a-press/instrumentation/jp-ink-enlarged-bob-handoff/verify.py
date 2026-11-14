"""Verify immutable native archives and diagnostic provenance."""
import argparse,gzip,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
ap=argparse.ArgumentParser();ap.add_argument('--check',action='store_true');a=ap.parse_args()
for name in ['positive','no-final-box']:
 d=HERE/'records'/name
 for file,h in json.loads((d/'archive-hashes.json').read_text()).items():assert sha(d/file)==h
 assert gzip.decompress((d/'checker-source.py.gz').read_bytes())==(HERE/'check.py').read_bytes()
 subprocess.run([sys.executable,str(HERE/'check.py'),str(d),'--archived'],check=True)
files={p.relative_to(HERE).as_posix():sha(p)for p in sorted(HERE.rglob('*'))if p.is_file()and p.name!='verification.json'and '__pycache__'not in p.parts}
out=dict(schema=1,originalJpRuns=2,selectedPhysicalBoundaries=50,physicalMismatches=0,retainedClockMismatches=50,missingCameraBoundariesPerCase=[25,26],positiveUseful=True,omissionOrdinary=True,nativeFloorReturns=1347,noteSha256=sha(ROOT/'docs/notes/ink-enlarged-bob-handoff-rom.md'),files=files)
target=HERE/'verification.json'
if a.check:assert json.loads(target.read_bytes())==out
else:target.write_bytes((json.dumps(out,indent=2)+'\n').encode())
print('PASS original-JP positive and ordinary-warp control; archives and inventory')
