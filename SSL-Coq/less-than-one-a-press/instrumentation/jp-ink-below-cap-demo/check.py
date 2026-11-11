"""Verify the supplied Y1400 fixture and native screenshot/trace mapping."""
import hashlib
import json
from pathlib import Path
import re
import sys

out=Path(sys.argv[1]); view=sys.argv[2]
raw=(out/'raw.log').read_text(errors='replace')
def fields(line): return dict(re.findall(r'(\w+)=((?:\([^)]*\))|[^,\n]+)',line))
def records(prefix): return [fields(l) for l in raw.splitlines() if l.startswith(prefix+',')]
def xyz(s): return [float(v) for v in s.strip('()').split(',')]
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
rows={int(r['step']):r for r in records('HANDS_RENDER')}
inputs=records('HANDS_INPUT'); writes=records('HANDS_WRITE')
extras={int(r['step']):r for r in records('HANDS_EXTRA') if r['tag']=='HANDS_RENDER'}
assert len(writes)==13 and sum(r.get('field')=='action' for r in writes)==1
assert 'HANDS_ERROR' not in raw and 'HANDS_HITBOX,height=100' in raw
assert all(int(r['A'])==0 for r in inputs)
assert all(not int(r['input'])&0x82 for r in rows.values())
cut=records('HANDS_AFTER_CUT')[0]
assert xyz(cut['state'])==xyz(cut['collision'])==xyz(cut['display'])==[-2132,1400,-1024]
assert xyz(cut['boxXYZ'])==[-2093,1400,-1024]
assert xyz(rows[6]['state'])==xyz(rows[6]['collision'])==[-2200,768,-1024]
assert xyz(rows[6]['display'])==[-2200,1400,-1024]
assert float(rows[6]['floorY'])==768 and float(extras[6]['depth'])==0
assert rows[7]['action']=='00001300' and rows[7]['floorOwner']==rows[7]['platform']=='00000000'
assert float(rows[7]['floorY'])==1280
arrival=next(r for r in rows.values() if int(r['area'])==2)
assert xyz(arrival['state'])==[0,5500,256]
assert all(float(r['depth'])==0 for r in extras.values())
summary=records('RESULT')[-1]
assert all(summary[k]=='0' for k in ('aPressedFrames','aDownFrames','controllerAFrames'))
assert summary['maxGfxMinusObjectY']=='632' and summary['platformTop']=='0'
camera=records('HANDS_CAMERA')
assert bool(camera)==(view!='stock')
illustrations=records('HANDS_ILLUSTRATION')
assert bool(illustrations)==(view=='display')
if illustrations:
    assert [int(r['step']) for r in illustrations]==[5,6]
    assert xyz(illustrations[0]['marioXYZ'])==[-2132,1400,-1024]
    assert xyz(illustrations[1]['marioXYZ'])==[-2200,1400,-1024]
matrices=[r for r in records('HANDS_MATRIX') if r['tag']=='HANDS_RENDER']
assert len(matrices)==len(rows)
requests=records('HANDS_SCREENSHOT')
assert [int(r['index']) for r in requests]==list(range(len(requests)))
shots=sorted((out/'shots').glob('super_mario_64-*.png'),key=lambda p:int(p.stem.rsplit('-',1)[1]))
assert len(shots)==len(requests) # final CLI stop request coalesces with our last request
by_timer={int(r['timer']):r for r in rows.values()}
mapping=[]
for request,shot in zip(requests,shots):
    timer=int(request['requestTimer'])-1
    state=by_timer.get(timer)
    mapping.append(dict(file=shot.name,requestTimer=timer+1,framebufferTimer=timer,
                        completedInput=int(state['step']) if state else None,
                        state=state,kind='native-camera-frame' if state else 'initial-or-transition-frame'))
receipt=dict(schema=1,
    scope='Supplied established crawl and synchronized Y1400 Mario/box positions; native632 split, static-roof retry and ordinary Area2 arrival; not clean reachability',
    romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',
    romMd5='85d61f5525af708c9f1e84dce6dc10e9',
    rawLogSha256=sha(out/'raw.log'),traceSha256=sha(out/'trace.txt'),
    probeSourceSha256=sha(out/'probe-source.c'),prefixSourceSha256=sha(out/'prefix-source.c'),
    probeBinarySha256=sha(out/'probe.so'),
    runnerSha256=sha(out/'run-source.sh'),checkerSha256=sha(Path(__file__)),
    setupWordWrites=13,suppliedActionWrites=1,positionWordWrites=12,floorCacheWrites=0,
    camera=view,renderCameraCallbacks=len(camera),cameraRestoredBeforeEachInput=True,
    renderIllustrations=illustrations,renderMatrixStates=matrices,
    gameplayWritesAfterCut=0,AInputs=0,collisionHeight=100,depth=0,
    imageMapping='Rice screenshots show the preceding completed framebuffer. The map joins requestTimer−1 to a logged camera callback. Missing camera callbacks during warp are marked unknown; do not infer input number from PNG index after transition.',
    milestones=dict(crawlSuppliedBeforeInput=5,positionSuppliedBeforeInput=6,
        splitAfterInput=6,gap=632,staticRoofRetryAfterInput=7,
        firstArea2AfterInput=int(arrival['step']),area2Position=xyz(arrival['state'])),
    initial=cut,renderStates=list(rows.values()),extraStates=list(extras.values()),writes=writes,
    frameMap=mapping,controllerSummary=summary,
    screenshots=[dict(file=p.name,sha256=sha(p)) for p in shots])
(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({k:receipt[k] for k in ['setupWordWrites','camera','milestones']},indent=2))
