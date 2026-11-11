"""Compare the original-ROM clean chapter to the recorded clean witnesses."""
import hashlib
import json
from pathlib import Path
import re
import struct
import sys

out, acquisition_path, continuation_path = map(Path, sys.argv[1:])
raw = (out/'raw.log').read_text(errors='replace')
def fields(line):
    return dict(re.findall(r'(\w+)=((?:\([^)]*\))|[^,\n]+)',line))
def vector(s):
    return [float(v) for v in s.strip('()').split(',')]
def bits(v):
    return struct.pack('>f',v)
def slot(s):
    p=int(s,16)
    return -1 if p==0 else (p-0x8033c118)//0x260
renders={int(r['step']):r for r in map(fields,raw.splitlines()) if 'boxXYZ' in r and 'step' in r}
inputs=[fields(l) for l in raw.splitlines() if l.startswith('HANDS_INPUT,')]
assert len(inputs)==656 and all(int(r['A'])==0 and not int(r['buttons'])&0x8000 for r in inputs)
assert 'HANDS_WRITE,' not in raw and 'HANDS_ERROR' not in raw
acquisition=json.loads(acquisition_path.read_text())['selected'][0]
continuation=next(t for t in json.loads(continuation_path.read_text())
                  if t['policy']['mode']=='brake' and not t['policy']['b'])
expected={r['timer']-1:r for r in acquisition['samples'][:86]}
expected.update({r['timer']-1:r for r in continuation['samples']})
differences=[]
for step,want in sorted(expected.items()):
    got=renders[step]
    mismatch=[]
    assert want['timer']-int(got['timer'])==2
    for field in ['area','topTimer','topAction']:
        if int(got[field])!=want[field]:mismatch.append(field)
    if int(got['action'],16)!=want['action']:mismatch.append('action')
    if slot(got['held'])!=want['held']:mismatch.append('held')
    for key,target in [('state','movement'),('collision','collision'),('display','display')]:
        if list(map(bits,vector(got[key])))!=list(map(bits,want[target])):mismatch.append(target)
    if bits(float(got['floorY']))!=bits(want['floorY']):mismatch.append('floorY')
    box=([want['box']['oPos'+a] for a in 'XYZ'] if 'box' in want else want['boxPosition'])
    if list(map(bits,vector(got['boxXYZ'])))!=list(map(bits,box)):mismatch.append('boxXYZ')
    if mismatch:differences.append(dict(step=step,fields=mismatch))
assert not differences,differences[:5]
assert int(renders[436]['action'],16)==0x008c0453 and slot(renders[436]['held'])==47
assert slot(renders[515]['held'])==-1 and int(renders[516]['boxActive'])==0
assert int(renders[528]['action'],16)==0x04008448 and float(renders[528]['floorY'])==38
assert all(not int(r['input'])&0x82 for r in renders.values())
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
receipt=dict(schema=1,scope='Controller-only low hands-free/drop/crawl component from accepted debug level-select entry; not a full no-A pyramid route',
    romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',
    rawLogSha256=sha(out/'raw.log'),traceSha256=sha(out/'trace.txt'),inputSha256=sha(out/'inputs.jsonl'),
    acquisitionRecordSha256=sha(acquisition_path),continuationRecordSha256=sha(continuation_path),
    inputCount=656,aInputs=0,gameplayStateWrites=0,cameraWrites=0,
    comparedSnapshots=len(expected),matchingSnapshots=len(expected),differences=differences,
    comparisonFields=['area','topTimer','topAction','action','held','movement','collision','display','floorY','boxXYZ'],
    globalTimerConvention='Every compared Wafel after-advance timer equals native camera-callback timer + 2. Match inputs and top state, not absolute global timer.',
    imageMapping='Image index n corresponds completed total input349+n, accounting for preceding-frame capture latency. The final CLI testshot is not part of this consecutive sequence.',
    milestones=dict(pickup=dict(input=424,image=75),divePickingUp=dict(input=435,image=86),
        handsfreeStomachSlide=dict(input=436,image=87),drop=dict(input=515,image=166),
        boxInactive=dict(input=516,image=167),lowCrawl=dict(input=528,image=179,y=38)),
    screenshots=[dict(file=p.name,sha256=sha(p)) for p in sorted((out/'shots').glob('*.png'))])
(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({k:receipt[k] for k in ['inputCount','aInputs','gameplayStateWrites','comparedSnapshots','matchingSnapshots','milestones']},indent=2))
