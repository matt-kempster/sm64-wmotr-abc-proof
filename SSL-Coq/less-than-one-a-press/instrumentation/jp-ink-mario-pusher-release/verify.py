"""Recheck native archives, full retained differences and report binding."""
import argparse,gzip,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--check',action='store_true');a=p.parse_args()
rows=[]
for name in ['positive','no-box','low-entry','low-joint']:
 d=HERE/'records'/name
 for file,h in json.loads((d/'archive-hashes.json').read_bytes()).items():assert sha(d/file)==h
 assert gzip.decompress((d/'checker-source.py.gz').read_bytes())==(HERE/'check.py').read_bytes()
 subprocess.run([sys.executable,str(HERE/'check.py'),str(d),'--archived'],check=True)
 r=json.loads(gzip.decompress((d/'receipt.json.gz').read_bytes()))
 rows.append(dict(name=name,checked=len(r['checked']),components=sum(x['fields']for x in r['checked']),mismatches=len(r['mismatches']),writes=len(r['stateWrites']),queryCount=len(r['queries']),capture=r['captureBridge'],arrival=r['arrival']['M']))
files={x.relative_to(HERE).as_posix():sha(x)for x in sorted(HERE.rglob('*'))if x.is_file()and '__pycache__'not in x.parts and x!=HERE/'verification.json'}
out=dict(schema=1,scope='Supplied carrying/HOLP and/or actor/Mario entry states on original JP; no continuous player route',romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',runs=rows,noteSha256=sha(ROOT/'docs/notes/ink-mario-pusher-delivery.md'),files=files)
t=HERE/'verification.json'
if a.check:assert json.loads(t.read_bytes())==out
else:t.write_bytes((json.dumps(out,indent=2)+'\n').encode())
print('PASS four original-JP records, archive hashes and report binding')
