"""Supplementary Wafel HOLP observations on the original-ROM-validated input stream.
HOLP itself was not added to the original-ROM observer; do not call it a native
HOLP field comparison. Actor release XYZ and the other documented fields were.
"""
import gzip,hashlib,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import Guard,create_game,Observer,sample,advance
HERE=Path(__file__).resolve().parent
inputs=[json.loads(x)for x in(HERE/'inputs.jsonl').read_text().splitlines()]
expected={r['poll']:r for r in json.loads(gzip.decompress((HERE/'wafel-trace.json.gz').read_bytes()))}
g=Guard(create_game());o=Observer(g);rows=[]
for i,p in enumerate(inputs):
 if i+1 in expected:
  s=sample(g,o,23);assert all(expected[i+1][k]==v for k,v in s.items())
  s.update(completedInput=i,HOLP=g.read('gMarioState.marioBodyState.heldObjLastPosition'));rows.append(s)
 advance(g,p)
selected=[r for r in rows if r['completedInput']in [500,841,842,1102,1103,1108,1109,1110,1119,1120,1147]]
receipt=dict(scope=__doc__,inputSha256=hashlib.sha256((HERE/'inputs.jsonl').read_bytes()).hexdigest(),matchedCoreFields=len(rows),milestones=selected,
 maximumHOLPY=max(r['HOLP'][1]for r in rows),maximumHOLPSample=max(rows,key=lambda r:r['HOLP'][1]),maximumActorY=max(r['actor']['xyz'][1]for r in rows),maximumHeldMovementY=max(r['M'][1]for r in rows if r['held']==23))
(HERE/'holp-observations.json').write_bytes((json.dumps(receipt,indent=2)+'\n').encode());print('HOLP',receipt['maximumHOLPY'],'boxY',receipt['maximumActorY'],'heldMarioY',receipt['maximumHeldMovementY'])
