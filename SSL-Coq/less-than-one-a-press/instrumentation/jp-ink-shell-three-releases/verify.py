"""Recheck two native archives, exact input exports and inherited probe sources."""
import argparse,gzip,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--check',action='store_true');a=p.parse_args();rows=[]
for name in ['positive','no-box']:
 d=HERE/'records'/name
 assert (HERE/(name+'.json')).read_bytes()==(HERE.parent/'ink-shell-carried-bob-mount'/(name+'.json')).read_bytes()
 for file,h in json.loads((d/'archive-hashes.json').read_bytes()).items():assert sha(d/file)==h
 for name2,path in [('checker-source.py',HERE/'check.py'),('comparator-source.py',HERE/'compare.py')]:
  assert gzip.decompress((d/(name2+'.gz')).read_bytes())==path.read_bytes()
 subprocess.run([sys.executable,str(HERE/'check.py'),str(d),'--archived'],check=True)
 r=json.loads(gzip.decompress((d/'receipt.json.gz').read_bytes()));remote=json.loads(gzip.decompress((d/'remote-receipt.json.gz').read_bytes()))
 rows.append(dict(name=name,checked=len(r['checked']),differences=len(r['mismatches']),stationaryShellObservations=remote['stationaryReleasedObservations'],noPostThrowShellXYZWrites=remote['noPostThrowShellXYZWrites'],arrival=r['arrival']['M']))
files={x.relative_to(HERE).as_posix():sha(x)for x in sorted(HERE.rglob('*'))if x.is_file()and '__pycache__'not in x.parts and x!=HERE/'verification.json'}
deps=['jp-ink-mario-pusher-release/generate.py','jp-ink-mario-pusher-release/check.py','jp-ink-preplaced-pushers/generate.py','jp-ink-enlarged-bob-handoff/generate.py','ink-floor768-diagnosis/probe.c','jp-clean-gap-search/jp_clean_gap_search_probe.c','ink-shell-carried-bob-mount/check.py']
out=dict(schema=1,scope='Original-JP remote shell throw, actual Box drop and shell-contact Bob drop, with two supplied carrying/approach cuts; no continuous route',runs=rows,files=files,dependencies={n:sha(HERE.parent/n)for n in deps})
t=HERE/'verification.json'
if a.check:assert json.loads(t.read_bytes())==out
else:t.write_bytes((json.dumps(out,indent=2)+'\n').encode())
print('PASS native joined releases positive/control, archived bytes and exact Wafel inputs')
