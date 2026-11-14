"""Verify immutable direct-replacement evidence and its declared outcomes."""
import gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
v=json.loads((HERE/'verification.json').read_text())
for name,h in v['hashes'].items():assert hashlib.sha256((ROOT/name).read_bytes()).hexdigest()==h,name
r=json.loads(gzip.decompress((HERE/'results.json.gz').read_bytes()))
assert r['independentlyVerified']and r['checkedBoundaries']==567
ts=r['results']['trials'];assert len(ts)==16 and sum(t['useful']for t in ts)==1
assert ts[0]['useful']and ts[0]['retainedObserved']and not any(t['capture']for t in ts[1:])
for t in ts:assert all(not p['buttons']&0x8000 for p in t['controls'])
low=json.loads(gzip.decompress((HERE/'low-results.json.gz').read_bytes()))
assert low['independentlyVerified']and low['checkedBoundaries']==324
assert len(low['results']['trials'])==9
assert all(t['mounted']and not t['capture']and not t['useful']for t in low['results']['trials'])
for t in low['results']['trials']:assert all(not p['buttons']&0x8000 for p in t['controls'])
print('PASS: 25 fresh-matched histories, 891 boundaries; hashes, A-off controls and outcomes')
