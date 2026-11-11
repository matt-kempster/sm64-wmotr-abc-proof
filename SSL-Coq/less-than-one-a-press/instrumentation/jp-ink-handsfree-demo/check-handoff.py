"""Check the separately supplied original-ROM 973-unit handoff chapter."""
import hashlib
import json
from pathlib import Path
import re
import sys

out=Path(sys.argv[1]);raw=(out/'raw.log').read_text(errors='replace')
def fields(line):return dict(re.findall(r'(\w+)=((?:\([^)]*\))|[^,\n]+)',line))
def xyz(s):return [float(v)for v in s.strip('()').split(',')]
rows={int(r['step']):r for r in [fields(l)for l in raw.splitlines()if l.startswith('HANDS_RENDER,')]}
inputs=[fields(l)for l in raw.splitlines()if l.startswith('HANDS_INPUT,')]
writes=[fields(l)for l in raw.splitlines()if l.startswith('HANDS_WRITE,')]
assert len(writes)==13 and sum(r.get('field')=='action'for r in writes)==1
assert 'HANDS_ERROR'not in raw and 'HANDS_HITBOX,height=100'in raw
assert all(int(r['A'])==0 for r in inputs)and all(not int(r['input'])&0x82 for r in rows.values())
assert xyz(rows[6]['state'])==[-1882,768,-939]and xyz(rows[6]['collision'])==[-1882,768,-939]
assert xyz(rows[6]['display'])==[-1882,1741,-939]and float(rows[6]['floorY'])==768
assert rows[7]['action']=='00001300'and rows[7]['floorOwner']==rows[7]['platform']=='803451f8'
assert int(rows[30]['area'])==2
arrival=xyz(rows[30]['state']);assert not(-460<=arrival[0]<=461 and -204<=arrival[2]<=717)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
receipt=dict(schema=1,scope='Separate supplied-crawl and supplied-position fixture; not a continuation of either hands-free clip',
    romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',
    rawLogSha256=sha(out/'raw.log'),traceSha256=sha(out/'trace.txt'),setupWordWrites=13,
    suppliedActionWrites=1,positionWordWrites=12,cameraWrites=0,aInputs=0,collisionHeight=100,
    imageMapping='Image index n corresponds completed chapter input n. Index0 is prior to first chapter input. The final CLI testshot is separate.',
    milestones=dict(suppliedCrawlBeforeInput=5,suppliedPositionBeforeInput=6,
        splitAfterInput=6,split=973,topCaptureAfterInput=7,area2ArrivalAfterInput=30,area2Position=arrival),
    screenshots=[dict(file=p.name,sha256=sha(p))for p in sorted((out/'shots').glob('*.png'))])
(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({k:receipt[k]for k in ['setupWordWrites','collisionHeight','milestones']},indent=2))
