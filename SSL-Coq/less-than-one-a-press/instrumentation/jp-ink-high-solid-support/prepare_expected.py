"""Freeze one independently verified Wafel high-solid trial; no simulation."""
import gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
source=HERE.parent/'ink-high-solid-support/results.json.gz'
d=json.load(gzip.open(source));t=next(t for t in d['trials']if t['recipe']==dict(edge=1,pusher='shell'))
assert t['useful'] and len(t['samples'])==26
out=dict(sourceSha256=hashlib.sha256(source.read_bytes()).hexdigest(),source='ink-high-solid-support/results.json.gz',trial=t)
p=HERE/'expected.json.gz'
if p.exists():assert json.load(gzip.open(p))==out
else:p.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
print('Frozen high-solid edge1 shell witness')
