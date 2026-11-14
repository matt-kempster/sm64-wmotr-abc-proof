"""Verify preplaced-pusher native archives, exact discrepancy scope and report."""
import argparse,gzip,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--check',action='store_true');a=p.parse_args()
summary=[]
for name in ['positive','no-final-box']:
 d=HERE/'records'/name
 for file,h in json.loads((d/'archive-hashes.json').read_bytes()).items():assert sha(d/file)==h
 assert gzip.decompress((d/'checker-source.py.gz').read_bytes())==(HERE/'check.py').read_bytes()
 subprocess.run([sys.executable,str(HERE/'check.py'),str(d),'--archived'],check=True)
 r=json.loads(gzip.decompress((d/'receipt.json.gz').read_bytes()))
 summary.append(dict(case=name,checked=len(r['checked']),components=sum(s['fields']for s in r['checked']),mismatches=len(r['mismatches']),floorReturns=len(r['queries']),writes=len(r['stateWrites']),noLaterSetupWrites=r['noLaterSetupWrites'],capture=r['capture'],arrival=r['arrival']['M']))
files={x.relative_to(HERE).as_posix():sha(x)for x in sorted(HERE.rglob('*'))if x.is_file()and x.name!='verification.json'and '__pycache__'not in x.parts}
dependencies={str(x.relative_to(ROOT)).replace('\\','/'):sha(x)for x in [ROOT/'instrumentation/jp-ink-enlarged-bob-handoff/generate.py',ROOT/'instrumentation/ink-floor768-diagnosis/probe.c',ROOT/'instrumentation/jp-clean-gap-search/jp_clean_gap_search_probe.c']}
out=dict(schema=1,scope='Two supplied-state original-JP checks; no delivery or global reachability claim',runs=summary,retainedClockOffsets=50,retainedBoxSubtypeDifferences=27,missingCameraBoundariesPerRun=[25,26],noteSha256=sha(ROOT/'docs/notes/ink-preplaced-pushers.md'),dependencies=dependencies,files=files)
target=HERE/'verification.json'
if a.check:assert json.loads(target.read_bytes())==out
else:target.write_bytes((json.dumps(out,indent=2)+'\n').encode())
print('PASS original-JP preplacement positive/control; no later writes, archive hashes and report binding')
