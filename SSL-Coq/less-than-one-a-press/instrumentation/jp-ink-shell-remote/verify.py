"""Check both remote-shell native archives and bind the report and dependencies."""
import argparse,gzip,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--check',action='store_true');a=p.parse_args();rows=[]
for name in ['low-positive','no-box']:
 d=HERE/'records'/name
 for file,h in json.loads((d/'archive-hashes.json').read_bytes()).items():assert sha(d/file)==h
 for name2,path in [('checker-source.py',HERE/'check.py'),('comparator-source.py',HERE.parent/'jp-ink-mario-pusher-release/check.py')]:
  assert gzip.decompress((d/(name2+'.gz')).read_bytes())==path.read_bytes()
 subprocess.run([sys.executable,str(HERE/'check.py'),str(d),'--archived'],check=True)
 r=json.loads(gzip.decompress((d/'receipt.json.gz').read_bytes()));remote=json.loads(gzip.decompress((d/'remote-receipt.json.gz').read_bytes()))
 rows.append(dict(name=name,checked=len(r['checked']),differences=len(r['mismatches']),stationaryShellObservations=remote['stationaryReleasedObservations'],noPostThrowShellXYZWrites=remote['noPostThrowShellXYZWrites'],arrival=r['arrival']['M']))
files={x.relative_to(HERE).as_posix():sha(x)for x in sorted(HERE.rglob('*'))if x.is_file()and '__pycache__'not in x.parts and x!=HERE/'verification.json'}
deps=['jp-ink-mario-pusher-release/generate.py','jp-ink-mario-pusher-release/check.py','jp-ink-preplaced-pushers/generate.py','jp-ink-enlarged-bob-handoff/generate.py','ink-floor768-diagnosis/probe.c','jp-clean-gap-search/jp_clean_gap_search_probe.c']
out=dict(schema=1,scope='Original-JP conditional remote-shell throw plus supplied Mario/pushers; no continuous route',runs=rows,noteSha256=sha(ROOT/'docs/notes/ink-shell-remote-functionality.md'),files=files,dependencies={n:sha(HERE.parent/n)for n in deps})
t=HERE/'verification.json'
if a.check:assert json.loads(t.read_bytes())==out
else:t.write_bytes((json.dumps(out,indent=2)+'\n').encode())
print('PASS native remote shell positive/control, archived bytes and report binding')
