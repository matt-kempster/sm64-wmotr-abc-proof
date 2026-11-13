"""Check a stock-camera original-JP conditional VPU/PU recording.

Snapshots are observed fields. Internal query/quarter explanations remain
source deductions. Screenshots are joined through previous-framebuffer time.
"""
import hashlib,json,re,sys
from pathlib import Path
out=Path(sys.argv[1]);mode=int(sys.argv[2]);archived='--archived' in sys.argv[3:]
raw=(out/('trace.txt' if archived else 'raw.log')).read_text(errors='replace')
preserved=json.loads((out/'receipt.json').read_text()) if archived else None
def fields(s):return dict(re.findall(r'(\w+)=((?:\([^)]*\))|[^,\n]+)',s))
def records(tag):return [fields(s) for s in raw.splitlines() if s.startswith(tag+',')]
def xyz(s):return [float(v) for v in s.strip('()').split(',')]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def near(a,b):return all(abs(x-y)<0.001 for x,y in zip(a,b))
rows=records('VPU_RENDER');by_step={int(r['step']):r for r in rows}
by_timer={int(r['timer']):r for r in rows}
writes=records('VPU_WRITE');inputs=records('VPU_INPUT');requests=records('VPU_SCREENSHOT')
assert 'VPU_ERROR' not in raw and rows and writes and inputs
assert all(int(r['A'])==0 for r in inputs)
assert all(not int(r['input'])&0x82 for r in rows)
cut=records('VPU_AFTER_CUT')[0]
x=63586 if mode>=4 else -1950;y=1741 if mode in (4,5) else 67277
assert xyz(cut['state'])==xyz(cut['collision'])==xyz(cut['display'])==[x,y,-939]
assert xyz(cut['boxXYZ'])==[x-39,y,-939]
assert int(cut['topTimer'])==130 and int(cut['topAction'])==1
assert all(int(w['step'])<=5 for w in writes)
assert {w['field'] for w in writes} <= {'movement','collision','display','boxPosition','action','actionState','actionTimer','forwardVel','velocity','facePitch','faceYaw','faceRoll','slideVelX','slideVelZ','slideYaw'}
assert len(writes)==(22 if mode==1 else 31 if mode in (3,5) else 25)
if mode in (3,5):
 assert {w['field'] for w in writes if w['step']=='5'}=={'movement','collision','display','boxPosition'}
 assert by_step[5]['action']=='04000440'
 assert cut['action']=='04000440'
 assert xyz(by_step[5]['state'])[1]==1280
split=by_step[6];capture=by_step[7]
first_area2=next((r for r in rows if r['area']=='2'),None)
useful=first_area2 is not None and not(-460<=xyz(first_area2['state'])[0]<=461 and -204<=xyz(first_area2['state'])[2]<=717)
is_success=mode in (1,2,3)
if is_success:
 assert xyz(split['state'])==xyz(split['collision'])==[-1882,768,-939]
 assert xyz(split['display'])==[-1882,67277,-939]
 assert float(split['floorY'])==768
 assert capture['action']=='00001300' and capture['actionArg']=='00040001'
 assert capture['used']=='80345918'
 assert capture['floorOwner']==capture['platform']=='803451f8'
 assert near(xyz(capture['state']),[-1882,1818.9613037109375,-939])
 assert useful and near(xyz(first_area2['state']),[365.5927734375,5500,-1096.8026123046875])
 kept=[r for r in rows if int(r['step'])>=7 and r['area']=='1']
 assert all(r['platform']==r['floorOwner']=='803451f8' for r in kept)
 assert any(r['topActive']=='0' for r in kept)
else:
 assert not useful and first_area2 is None
 assert not any(r['platform']=='803451f8' for r in rows if int(r['step'])>=6)
 assert not any(r['action']=='00001300' or r['used']=='80345918' for r in rows if int(r['step'])>=6)
 assert xyz(split['state'])[0]>63000
 if mode in (4,5):
  assert xyz(split['state'])==xyz(split['collision'])==xyz(split['display'])
  assert xyz(split['state'])[1]==1741
  assert split['action']==('0300088e' if mode==4 else '0100088c')
  assert all(xyz(r['display'])[1]<=xyz(r['state'])[1] for r in rows)
 if mode==6:
  assert xyz(split['state'])==xyz(split['collision'])==[63654,768,-939]
  assert xyz(split['display'])==[63654,67277,-939]
shots=([Path(f['file']) for f in preserved['frameMap']] if archived else
 sorted((out/'shots').glob('super_mario_64-*.png'),key=lambda p:int(p.stem.rsplit('-',1)[1])))
capture_frames=[int(x) for x in re.findall(r'Core: Captured screenshot for frame (\d+)\.',raw)]
assert len(shots)==len(capture_frames)
# --testshots 2820 also requests the final image. Usually that request merges
# with the camera callback; when death stops camera callbacks it is extra.
extra=len(shots)-len(requests)
assert extra in (0,1),(len(shots),len(requests))
if extra:
 assert capture_frames[-1]==2820 and int(requests[-1]['requestTimer'])<2820
mapping=[]
for request,shot,core_frame in zip(requests,shots,capture_frames):
 timer=int(request['requestTimer'])-1;state=by_timer.get(timer)
 entry=dict(file=shot.name,coreCaptureFrame=core_frame,requestTimer=timer+1,framebufferTimer=timer,completedInput=int(state['step']) if state else None,state=state)
 if archived:
  old=preserved['frameMap'][len(mapping)]
  assert all(old[k]==v for k,v in entry.items() if k!='state')
  assert re.fullmatch('[0-9a-f]{64}',old['sha256'])
  entry['sha256']=old['sha256']
 else: entry['sha256']=sha(shot)
 mapping.append(entry)
if extra:
 shot=shots[-1]
 mapping.append(dict(file=shot.name,coreCaptureFrame=capture_frames[-1],requestTimer=None,framebufferTimer=None,completedInput=None,state=None,sha256=preserved['frameMap'][-1]['sha256'] if archived else sha(shot),note='Final CLI testshot; no camera state join.'))
summary=records('RESULT')[-1]
assert all(summary[k]=='0' for k in ('aPressedFrames','aDownFrames','controllerAFrames'))
if not is_success:
 assert all(summary[k]=='0' for k in ('warpDisappeared','warpUsedObj','platformTop'))
milestones=dict(producerInput=6,captureInput=7 if is_success else None,split=xyz(split['display'])[1]-xyz(split['state'])[1],
 firstArea2Input=int(first_area2['step']) if first_area2 else None,area2Position=xyz(first_area2['state']) if first_area2 else None,usefulArrival=useful)
if archived:
 assert preserved['mode']==mode and preserved['milestones']==milestones
 assert preserved['renderStates']==rows and preserved['writes']==writes and preserved['inputs']==inputs
 assert preserved['initial']==cut and preserved['controllerSummary']==summary
 assert preserved['archive']['traceSha256']==sha(out/'trace.txt')
 print(json.dumps(dict(mode=mode,archivedCheck=True,snapshots=len(rows),frameJoins=len(mapping),milestones=milestones),indent=2))
 sys.exit(0)
receipt=dict(schema=1,mode=mode,scope='Original-JP ROM with explicitly supplied initial action/pose/speed/actor cuts; stock camera; not controller-reachable route',
 romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',romMd5='85d61f5525af708c9f1e84dce6dc10e9',
 emulator='Mupen64Plus2.5.9 interpreter, Rice2.5.9, HLE-RSP2.5.9, dummy audio, Ubuntu24.04; debug level-select cheat6',
 hashes={p:sha(out/p) for p in ['raw.log','trace.txt','probe-source.c','prefix-source.c','run-source.sh','probe.so']},checkerSha256=sha(Path(__file__)),
 sourceDependencies=[dict(repositoryPath='SSL-Coq/less-than-one-a-press/instrumentation/jp-clean-gap-search/jp_clean_gap_search_probe.c',preservedFile='prefix-source.c',sha256=sha(out/'prefix-source.c'),note='Only active local include; RANK13_18_COPY_AUDIT is0, so its guarded header is not compiled.')],
 setupWrites=len(writes),setupWord32Writes=sum(w['width']=='32' for w in writes),setupWord16Writes=sum(w['width']=='16' for w in writes),
 noCameraWrites=True,noFloorCacheWrites=True,noTopOrPlatformWrites=True,gameplayWritesAfterCut=0,aInputs=0,
 initial=cut,walkingPreparation=records('VPU_AFTER_WALK_PREP'),writes=writes,inputs=inputs,renderStates=rows,frameMap=mapping,controllerSummary=summary,
 milestones=milestones,
 sourceRevisions=dict(proof='55b791068e0373be4e0382ebc02608853c3b3b03',decompile='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',newProbe='Uncommitted at capture; exact source and binary hashes preserved.'),
 observationLimit='End-update positions/action/cache/owner/platform/actor fields; no per-quarter or local query hook.',
 imageMapping='Rice screenshot uses preceding framebuffer; requestTimer-1 joined to camera callback. Unknown transition mapping remains null; do not infer input from image index.')
(out/'checker-source.py').write_bytes(Path(__file__).read_bytes())
(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps(dict(mode=mode,setupWrites=len(writes),snapshots=len(rows),screenshots=len(shots),milestones=receipt['milestones']),indent=2))
