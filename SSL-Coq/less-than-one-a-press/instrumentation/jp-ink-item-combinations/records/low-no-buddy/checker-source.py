"""Check authentic-JP supplied-air plus actor-cut replay; not a clean route."""
import hashlib,json,re,sys
from pathlib import Path
out=Path(sys.argv[1]);mode=int(sys.argv[2]);start_y=float(sys.argv[3]);start_x=float(sys.argv[4]);start_z=float(sys.argv[5]);archived='--archived' in sys.argv[6:]
raw=(out/('trace.txt' if archived else 'raw.log')).read_text(errors='replace')
def fields(s):return dict(re.findall(r'(\w+)=((?:\([^)]*\))|[^,\n]+)',s))
def records(tag):return [fields(s) for s in raw.splitlines() if s.startswith(tag+',')]
def xyz(s):return [float(x) for x in s.strip('()').split(',')]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def near(a,b):return all(abs(x-y)<.002 for x,y in zip(a,b))
rows=records('ENTRY_RENDER');states={int(r['step']):r for r in rows};writes=records('ENTRY_WRITE');inputs=records('ENTRY_INPUT')
assert 'ENTRY_ERROR' not in raw and len(rows)>30 and writes and inputs
steps=[int(r['step']) for r in rows]
assert steps==sorted(set(steps)) and all(k in states for k in [4,5,6,7])
assert all(int(r['A'])==0 and not int(r['buttons'])&0x8000 for r in inputs)
assert all(not int(r['input'])&0x82 for r in rows)
cut=records('ENTRY_AFTER_CUT')[0]
assert near(xyz(cut['state']),[start_x,start_y,start_z])
assert xyz(cut['state'])==xyz(cut['collision'])==xyz(cut['display'])
assert cut['topTimer']=='128' and cut['topAction']=='1' and cut['action']=='0100088c'
allowed={'shellBoxAction','movement','collision','display','action','actionState','actionTimer','forwardVel','velocity','facePitch','faceYaw','faceRoll','shellPosition','boxPosition','buddyPosition'}
assert {w['field'] for w in writes}<=allowed
def triple(base):return {(base+4*i,32) for i in range(3)}
pool=0x8033c118;state=0x80339e00
addresses={'movement':triple(state+0x3c),'collision':triple(pool+67*0x260+0xa0),'display':triple(pool+67*0x260+0x20),
 'action':{(state+0xc,32)},'actionState':{(state+0x18,16)},'actionTimer':{(state+0x1a,16)},'forwardVel':{(state+0x54,32)},
 'velocity':triple(state+0x48),'facePitch':{(state+0x2c,16)},'faceYaw':{(state+0x2e,16)},'faceRoll':{(state+0x30,16)},
 'shellBoxAction':{(pool+32*0x260+0x14c,32)},'shellPosition':triple(pool+69*0x260+0xa0),'boxPosition':triple(pool+49*0x260+0xa0),'buddyPosition':triple(pool+15*0x260+0xa0)}
assert all((int(w['address'],16),int(w['width'])) in addresses[w['field']] for w in writes)
assert all((int(w['step'])==0 and w['field']=='shellBoxAction') or int(w['step'])==3 or (int(w['step']) in [4,5] and w['field'] in ['boxPosition','buddyPosition']) for w in writes)
assert sum(w['field']=='shellBoxAction' for w in writes)==1
assert sum(w['field']=='boxPosition' for w in writes)==6
assert sum(w['field']=='buddyPosition' for w in writes)==(0 if mode==2 else 3)
assert all((int(r['step'])==4 and r['buttons']=='8192') or (int(r['step'])!=4 and r['buttons']=='0') for r in inputs)
assert all(r['x']=='0' and r['y']=='0' for r in inputs)
assert states[4]['action']=='00840452'
assert near(xyz(states[4]['state']),[-1920,1799.2869873046875,-1210])
arrival=next((r for r in rows if r['area']=='2'),None)
useful=arrival is not None and near(xyz(arrival['state']),[365.5927734375,5500,-1096.8026123046875])
producer=states[6];following=states[7]
if mode==1:
 assert near(xyz(states[5]['state']),[-2140.031982421875,1830.177978515625,-1115.0291748046875])
 assert near(xyz(producer['state']),[-2210.062255859375,768,-1075.10888671875])
 assert xyz(producer['state'])==xyz(producer['collision'])
 assert float(producer['floorY'])==768 and abs(xyz(producer['display'])[1]-1830.177978515625)<.002
 assert following['used']=='80345918' and following['action']=='00001300' and following['actionArg']=='00040001'
 assert following['floorOwner']==following['platform']=='803451f8' and useful
 assert all(r['floorOwner']==r['platform']=='803451f8' for r in rows if r['area']=='1' and int(r['step'])>=7)
else:
 assert not useful
 assert arrival is None and all(r['area']=='1' for r in rows)
 assert float(producer['floorY'])>1700 and producer['floorOwner']=='803451f8'
summary=records('RESULT')[-1]
assert all(summary[k]=='0' for k in ['aPressedFrames','aDownFrames','controllerAFrames'])
milestones=dict(nativeSlide=states[4],repositioned=states[5],producer=producer,capture=following,firstArea2=arrival,usefulArrival=useful)
if archived:
 saved=json.loads((out/'receipt.json').read_text());assert saved['mode']==mode and saved['states']==rows and saved['writes']==writes and saved['inputs']==inputs and saved['milestones']==milestones
 for n in ['trace.txt','probe-source.c','prefix-source.c','run-source.sh']:assert saved['hashes'][n]==sha(out/n)
 assert saved['checkerSha256']==sha(out/'checker-source.py')
 print(json.dumps(dict(mode=mode,archived=True,states=len(rows),useful=useful)));sys.exit(0)
receipt=dict(schema=1,date='2026-11-14',mode=mode,initialXYZ=[start_x,start_y,start_z],proofBase='08b72af44fbb54aaef3ed7f8be399868ba75db98',scope='Original JP supplied AIR and stock actor cuts; no subsequent Mario writes, no actor delivery or continuous controller route claimed.',romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',emulator='Ubuntu24.04; Mupen64Plus2.5.9 interpreter/Rice2.5.9/HLE RSP2.5.9/dummy audio; pre-game debug level-select cheat6',hashes={n:sha(out/n) for n in ['raw.log','trace.txt','probe-source.c','prefix-source.c','run-source.sh','probe.so']},checkerSha256=sha(Path(__file__)),initial=cut,states=rows,writes=writes,inputs=inputs,shells=records('ENTRY_SHELL'),buddies=records('ENTRY_BUDDY'),noA=summary,milestones=milestones,marioWritesAfterSetup=0,observerWritesAfterFinalActorCut=0,observationLimit='End-update native fields, not newly installed internal quarter-step/interaction breakpoints.')
receipt['legacyPrefixHeaderScope']='The inherited SEARCH postEntryInput=controller-only,inputPluginMemoryWrites=zero describes the reused prefix, not this wrapper. ENTRY_WRITE is the complete declared wrapper setup ledger; the whole run has supplied cuts.'
(out/'checker-source.py').write_bytes(Path(__file__).read_bytes());(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps(dict(mode=mode,start=receipt['initialXYZ'],states=len(rows),useful=useful,arrival=xyz(arrival['state']) if arrival else None)))
