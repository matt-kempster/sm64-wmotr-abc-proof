"""Freeze the two previously verified Wafel controls; no new simulation."""
import gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
source=HERE.parent/'ink-high-item-nudge/results.json.gz'
d=json.load(gzip.open(source));chosen=[]
for h,n in [(25000,'small'),(67277,'bobomb')]:
 r=dict(family='relocated-rider',height=h,steps=[n],z=[0],basePhase=129,timingControl=True)
 t=next(t for t in d['trials']if t['recipe']==r)
 assert t['useful']and len(t['samples'])==25
 chosen.append(t)
out=dict(sourceSha256=hashlib.sha256(source.read_bytes()).hexdigest(),sourceProofRevision=d['proofRevision'],trials=chosen)
p=HERE/'expected.json.gz'
if p.exists():assert json.load(gzip.open(p))['trials']==chosen
else:p.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
print('Frozen two selected native-low-mount / supplied-high-relocation Wafel controls')
