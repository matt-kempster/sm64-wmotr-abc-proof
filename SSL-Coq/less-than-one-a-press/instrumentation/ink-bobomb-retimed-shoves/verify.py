"""Verify archived finite outcomes and exact package hashes."""
import gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
v=json.loads((HERE/'verification.json').read_text())
for p,h in v['hashes'].items():assert hashlib.sha256((ROOT/p).read_bytes()).hexdigest()==h,p
r=json.loads(gzip.decompress((HERE/'results.json.gz').read_bytes()))
assert r['independentlyVerifiedSelectedHistories']
c=r['results']['counts'];assert c==dict(seeds=10,firstStage=170,secondStage=523,finalBeam=32,producerScreens=1863,captures=0,useful=0,completeHistories=12,selectedBoundaries=480)
for t in r['results']['trials']:
 assert not t['capture']and not t['useful']and len(t['samples'])==40
 assert all(not p['buttons']&0x8000 for p in t['controls'])
 assert all(s['area']==1 for s in t['samples'])
assert all(t['producer']['sample']['floorY']!=768 for t in r['results']['producerScreens'])
print('PASS: package hashes, finite counts, A-off histories and absence of screened useful handoff')
