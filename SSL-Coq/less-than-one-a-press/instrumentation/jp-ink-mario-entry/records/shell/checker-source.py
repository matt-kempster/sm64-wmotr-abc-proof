"""Validate original-JP entry controls; no controller reachability claim."""
import hashlib, json, re, subprocess, sys
from pathlib import Path
out=Path(sys.argv[1]); mode=int(sys.argv[2]); archived='--archived' in sys.argv[3:]
raw=(out/('trace.txt' if archived else 'raw.log')).read_text(errors='replace')
def fields(s): return dict(re.findall(r'(\w+)=((?:\([^)]*\))|[^,\n]+)',s))
def records(tag): return [fields(s) for s in raw.splitlines() if s.startswith(tag+',')]
def xyz(s): return [float(v) for v in s.strip('()').split(',')]
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def near(a,b): return all(abs(x-y)<.001 for x,y in zip(a,b))
rows=records('ENTRY_RENDER'); states={int(r['step']):r for r in rows}
writes=records('ENTRY_WRITE'); inputs=records('ENTRY_INPUT')
assert 'ENTRY_ERROR' not in raw and len(rows)>30 and writes and inputs
assert all(int(r['A'])==0 and not int(r['buttons'])&0x8000 for r in inputs)
assert all(not int(r['input'])&0x82 for r in rows)
cut=records('ENTRY_AFTER_CUT')[0]
assert xyz(cut['state'])==xyz(cut['collision'])==xyz(cut['display'])
assert near(xyz(cut['state']),[-1930,1837.8726806640625,-880] if mode>=4 else [-1950,1741,-939])
assert cut['topTimer']==('128' if mode>=4 else '130') and cut['topAction']=='1'
assert cut['action']==('04008448' if mode==1 else '0100088c')
allowed={'movement','collision','display','boxPosition','action','actionState','actionTimer',
 'forwardVel','velocity','facePitch','faceYaw','faceRoll','verticalVelocity','shellPosition','shellBoxAction'}
assert {w['field'] for w in writes}<=allowed
assert all(int(w['step'])<=5 for w in writes)
assert sum(w['field']=='shellBoxAction' for w in writes)==(1 if mode in (2,3) else 0)
assert sum(w['field']=='boxPosition' for w in writes)==(0 if mode==2 else 3)
producer=states[6]; following=states[7]
arrival=next((r for r in rows if r['area']=='2'),None)
assert arrival is not None
useful=not(-460<=xyz(arrival['state'])[0]<=461 and -204<=xyz(arrival['state'])[2]<=717)
assert xyz(producer['state'])==xyz(producer['collision'])
assert float(producer['floorY'])==768
assert abs(xyz(producer['display'])[1]-xyz(producer['state'])[1]-(1106.9208984375 if mode>=4 else 973))<.001
assert following['action']=='00001300' and following['actionArg']=='00040001'
assert following['used']=='80345918'
if mode==1:
 assert xyz(producer['state'])==[-1882,768,-939]
 assert following['floorOwner']==following['platform']=='803451f8'
 assert useful and near(xyz(arrival['state']),[365.5927734375,5500,-1096.8026123046875])
 assert all(r['floorOwner']==r['platform']=='803451f8' for r in rows if r['area']=='1' and int(r['step'])>=7)
else:
 assert near(xyz(producer['state']),[-1946.9049072265625,768,-1000.1429443359375] if mode>=4 else [-1950,768,-939])
 assert following['floorOwner']=='00000000' and following['platform']=='00000000'
 assert not useful and xyz(arrival['state'])==[0,5500,256]
if mode>=4:
 assert all(int(w['step'])==(4 if mode==4 and w['field']=='boxPosition' else 3) for w in writes)
 assert all(r['buttons']=='0' and r['x']=='0' and r['y']=='0' for r in inputs)
 assert states[4]['action']=='04000471' and states[4]['platform']=='803451f8'
 assert states[5]['action']=='00840452' and states[5]['platform']=='00000000'
 assert near(xyz(states[4]['state']),[-1930,1839.883544921875,-875.0875244140625])
 assert near(xyz(states[5]['state']),[-1946.9049072265625,1874.9208984375,-1000.1429443359375])
 assert states[5]['floorOwner']=='803451f8'
if mode==5:
 assert near(xyz(cut['boxXYZ']),[-1857.8465576171875,1716.883544921875,-940.83349609375])
 assert abs(xyz(states[4]['boxXYZ'])[1]-1725.337646484375)<.001
summary=records('RESULT')[-1]
assert all(summary[k]=='0' for k in ('aPressedFrames','aDownFrames','controllerAFrames'))
if archived:
 saved=json.loads((out/'receipt.json').read_text())
 assert saved['mode']==mode and saved['states']==rows and saved['writes']==writes
 assert saved['inputs']==inputs and saved['initial']==cut and saved['noA']==summary
 assert saved['hashes']['trace.txt']==sha(out/'trace.txt')
 for name in ['probe-source.c','prefix-source.c','run-source.sh']:
  assert saved['hashes'][name]==sha(out/name)
 assert saved['checkerSha256']==sha(out/'checker-source.py')
 assert saved['milestones']==dict(producer=producer,capture=following,firstArea2=arrival,usefulArrival=useful)
 print(json.dumps(dict(mode=mode,archivedCheck=True,states=len(rows),useful=useful)))
 sys.exit(0)
receipt=dict(schema=2,date='2026-11-14',mode=mode,
 scope='Instrumented original JP ROM with supplied pose/action/actor cuts. No continuous gameplay entry or actor delivery claim.',
 romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',
 emulator='Ubuntu24.04; Mupen64Plus2.5.9 interpreter; Rice2.5.9; HLE RSP2.5.9; dummy audio; debug level select cheat6',
 proofBase='921e4d1954d79f3b4deb6958c88419a8f4bd5a28',
 sourceDependencies=['instrumentation/jp-clean-gap-search/jp_clean_gap_search_probe.c'],
 hashes={p:sha(out/p) for p in ['raw.log','trace.txt','probe-source.c','prefix-source.c','run-source.sh','probe.so']},
 checkerSha256=sha(Path(__file__)),initial=cut,writes=writes,inputs=inputs,states=rows,shells=records('ENTRY_SHELL'),
 noA=summary,marioSetupStep=int(cut['step']),finalSetupStep=max(int(w['step']) for w in writes),
 marioWritesAfterMarioSetup=sum(int(w['step'])>int(cut['step']) and w['field']!='boxPosition' for w in writes),
 actorWritesAfterMarioSetup=sum(int(w['step'])>int(cut['step']) and w['field']=='boxPosition' for w in writes),
 observerWritesAfterFinalSetup=0,
 milestones=dict(producer=producer,capture=following,firstArea2=arrival,usefulArrival=useful),
 observationLimit='End-update native fields; shell interaction priority and absence of later grabbable processing are source deductions, not newly installed internal hooks.')
(out/'checker-source.py').write_bytes(Path(__file__).read_bytes())
(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps(dict(mode=mode,writes=len(writes),states=len(rows),producer=xyz(producer['state']),storedGraphics=xyz(producer['display']),arrival=xyz(arrival['state']),useful=useful)))
