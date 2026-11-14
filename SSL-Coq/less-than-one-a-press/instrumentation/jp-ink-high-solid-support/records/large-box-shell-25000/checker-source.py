"""Audit a supplied high air/live-solid original-JP handoff and compare Wafel observations."""
import gzip,hashlib,json,re,struct,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
out=Path(sys.argv[1]);archived='--archived'in sys.argv[2:]
raw=(out/('trace.txt'if archived else'raw.log')).read_text(errors='replace')
def fields(s):return dict(re.findall(r'(\w+)=((?:\([^)]*\))|[^,\n]+)',s))
def records(tag):return[fields(s)for s in raw.splitlines()if s.startswith(tag+',')]
def xyz(s):return[float(x)for x in s.strip('()').split(',')]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def bits(v):return struct.unpack('>I',struct.pack('>f',v))[0]
pool=0x8033c118;state=0x80339e00
def slot(h):
 p=int(h,16)
 return (p-pool)//0x260 if p>=pool and(p-pool)%0x260==0 and(p-pool)//0x260<240 else -1 if p==0 else -2
rows=records('ENTRY_RENDER');states={int(r['step']):r for r in rows};writes=records('ENTRY_WRITE');inputs=records('ENTRY_INPUT')
actors={};shells={};lines=raw.splitlines()
for i,line in enumerate(lines[:-2]):
 if line.startswith('ENTRY_RENDER,'):
  assert lines[i+1].startswith('ENTRY_ACTOR,') and lines[i+2].startswith('ENTRY_AUXSHELL,')
  a=fields(lines[i+1]);actors[int(a['step'])]=a
  a=fields(lines[i+2]);shells[int(a['step'])]=a
assert 'ENTRY_ERROR'not in raw and len(rows)>30
steps=[int(r['step'])for r in rows];assert steps==sorted(set(steps))
assert all(int(r['A'])==0 and not(int(r['buttons'])&32768)for r in inputs)
assert all(not(int(r['input'])&0x82)for r in rows)
assert all(int(r['buttons'])==(16384 if int(r['step'])==5 else 0)for r in inputs)
assert all(r['x']=='0'and r['y']=='0'for r in inputs)
def triple(a):return{(a+4*i,32)for i in range(3)}
allow={'shellBoxAction':{(pool+32*0x260+0x14c,32)},'movement':triple(state+0x3c),'collision':triple(pool+67*0x260+0xa0),'display':triple(pool+67*0x260+0x20),'action':{(state+0xc,32)},'actionState':{(state+0x18,16)},'actionTimer':{(state+0x1a,16)},'forwardVel':{(state+0x54,32)},'velocity':triple(state+0x48),'facePitch':{(state+0x2c,16)},'faceYaw':{(state+0x2e,16)},'faceRoll':{(state+0x30,16)},'shellPosition':triple(pool+69*0x260+0xa0),'supportPosition':triple(pool+13*0x260+0xa0)}
assert all(w['field']in allow and(int(w['address'],16),int(w['width']))in allow[w['field']]for w in writes)
assert all((int(w['step'])==0 and w['field']=='shellBoxAction')or(int(w['step'])==4 and w['field']not in ['shellBoxAction','shellPosition'])or(int(w['step'])==5 and w['field']=='shellPosition')for w in writes)
assert len(writes)==27 and sum(w['field']=='shellPosition'for w in writes)==3
assert all(int(w['after'],16)==0x0100088c for w in writes if w['field']=='action')
expected=json.load(gzip.open(HERE/'expected.json.gz'))['trial']
cut=records('ENTRY_AFTER_CUT')[0]
assert xyz(cut['state'])==xyz(cut['collision'])==xyz(cut['display'])==[-1950,25001,-939]
assert xyz(cut['boxXYZ'])==[-1849,24800,-939] and cut['action']=='0100088c'and cut['topTimer']=='129'
landing=states[5];producer=states[6];capture=states[7]
assert landing['action']=='00880456'and xyz(landing['state'])==xyz(landing['collision'])==xyz(landing['display'])==[-1950,25000,-939]
assert landing['topTimer']=='130'and float(landing['floorY'])==768 and slot(actors[5]['ridden'])==-1
assert xyz(producer['state'])==xyz(producer['collision'])==[-1882,768,-939]
assert xyz(producer['display'])==[-1882,25000,-939]and float(producer['floorY'])==768
assert producer['topTimer']=='131'and capture['topTimer']=='132'
assert slot(capture['used'])==64 and slot(capture['floorOwner'])==slot(capture['platform'])==61
assert all(slot(actors[i]['ridden'])==-1 for i in [5,6,7])
assert all(slot(r['held'])==-1 and slot(r['used'])!=69 and slot(actors[int(r['step'])]['ridden'])==-1 for r in rows)
assert all(xyz(r['boxXYZ'])==[-1849,24800,-939] and r['boxActive']=='257' and r['boxHeld']=='0' for r in rows if r['area']=='1' and int(r['step'])>=5)
arrival=next(r for r in rows if r['area']=='2');assert int(arrival['step'])==30
assert all(slot(r['platform'])==61 for r in rows if r['area']=='1' and 7<=int(r['step'])<30)
assert [bits(v)for v in xyz(arrival['state'])]==[bits(v)for v in [365.5927734375,5500,-1096.8026123046875]]
comparisons=[];mismatches=[]
for step,s in [(5+i,s)for i,s in enumerate(expected['samples'])]:
 if step not in states:
  assert step in [28,29],step
  continue
 r=states[step];a=actors[step];shell=shells[step]
 pairs={k:(int(r[k]),s[k])for k in ['area','topTimer','topAction','topActive','actionState','actionTimer']}
 pairs['action']=(int(r['action'],16),s['action'])
 for k in ['used','held','platform','floorOwner']:pairs[k]=(slot(r[k]),s[k])
 pairs['ridden']=(slot(a['ridden']),s['ridden'])
 for native,key in [('state','movement'),('collision','collision'),('display','display'),('velocity','velocity'),('slideVel','slideVelocity')]:
  for i,(v,e)in enumerate(zip(xyz(r[native]),s[key])):pairs[native+str(i)]=(bits(v),bits(e))
 for native,key in [('floorY','floorY'),('ceilingY','ceilingY'),('forward','forwardVelocity')]:pairs[native]=(bits(float(r[native])),bits(s[key]))
 for label,got,exp,pos in [('support',a,s['support'],r['boxXYZ']),('shell',shell,s['shell'],shell['xyz'])]:
  for native,key in [('type','oInteractType'),('subtype','oInteractionSubtype'),('status','oInteractStatus')]:pairs[label+'.'+native]=(int(got[native]),exp[key])
  for native,key in [('radius','hitboxRadius'),('height','hitboxHeight')]:pairs[label+'.'+native]=(bits(float(got[native])),bits(exp[key]))
  for i,(v,e)in enumerate(zip(xyz(pos),exp['position'])):pairs[label+'.pos'+str(i)]=(bits(v),bits(e))
 comparisons.append(dict(step=step,fieldCount=len(pairs)))
 for k,(v,e)in pairs.items():
  if v!=e:mismatches.append(dict(step=step,field=k,native=v,wafel=e))
summary=records('RESULT')[-1];assert all(summary[k]=='0'for k in ['aPressedFrames','aDownFrames','controllerAFrames'])
receipt=dict(schema=1,date='2026-11-14',scope='Original JP supplied high FREEFALL/live-solid landing then nonmounting shell shove; no ground action supplied, no later Mario edits, no delivery route.',observations=len(rows),states=rows,writes=writes,inputs=inputs,renderActors={str(k):v for k,v in actors.items()},renderShells={str(k):v for k,v in shells.items()},noA=summary,landing=landing,producer=producer,capture=capture,arrival=arrival,useful=True,retentionObserved=True,missingCameraSteps=[i for i in range(5,31)if i not in states],comparedBoundaries=len(comparisons),comparisons=comparisons,mismatches=mismatches,strictObservedFieldsMatch=not mismatches,romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',expectedSha256=sha(HERE/'expected.json.gz'),hashes={n:sha(out/n)for n in ['trace.txt','probe-source.c','prefix-source.c','run-source.sh']},checkerSha256=sha(Path(__file__)))
if archived:assert json.loads((out/'receipt.json').read_text())==receipt
else:
 (out/'checker-source.py').write_bytes(Path(__file__).read_bytes());(out/'receipt.json').write_bytes((json.dumps(receipt,indent=2)+'\n').encode())
print(json.dumps(dict(observations=len(rows),writes=len(writes),comparedBoundaries=len(comparisons),mismatches=len(mismatches),useful=True,archived=archived)))
