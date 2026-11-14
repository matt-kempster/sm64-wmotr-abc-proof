"""Check preserved lower-boundary artifact, declared outcomes and byte hashes."""
import gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
manifest=json.loads((HERE/'verification.json').read_text())
for name,digest in manifest['hashes'].items():
 assert hashlib.sha256((ROOT/name).read_bytes()).hexdigest()==digest,name
r=json.loads(gzip.decompress((HERE/'results.json.gz').read_bytes()))
assert r['independentlyVerified']and r['checkedBoundaries']==378
assert len(r['results']['trials'])==9 and len(r['results']['oldSequence'])==2
assert not any(t['bridge']or t['useful']for t in r['results']['trials'])
assert r['results']['oldSequence'][0]['useful']and not r['results']['oldSequence'][1]['capture']
for t in r['results']['trials']+r['results']['oldSequence']:
 assert all(not p['buttons']&0x8000 for p in t['controls'])
print('PASS: 11 continuations, 378 boundaries; outcomes, A-off controls and pinned hashes')
