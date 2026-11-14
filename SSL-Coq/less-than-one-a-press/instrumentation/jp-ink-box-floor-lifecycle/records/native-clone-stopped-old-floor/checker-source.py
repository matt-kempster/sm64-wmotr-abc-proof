"""Audit original JP conditional clone mesh retention; keep every Wafel mismatch."""
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
def surface_bits(ss):return[dict(s,normal={k:bits(v)for k,v in s['normal'].items()},originOffset=bits(s['originOffset']))for s in ss]
pool=0x8033c118;state=0x80339e00
def slot(h):
 p=int(h,16)
 return(p-pool)//0x260 if p>=pool and(p-pool)%0x260==0 and(p-pool)//0x260<240 else -1 if p==0 else -2
rows=records('BOX_STATE');states={int(r['step']):r for r in rows};writes=records('BOX_WRITE');inputs=records('BOX_INPUT')
assert 'BOX_ERROR'not in raw and sorted(states)==list(range(1,49)) and len(rows)==48
assert len(inputs)==48 and all(int(r['A'])==0 and int(r['buttons'])==(16384 if int(r['step'])in[1,19]else 0)and r['x']==r['y']=='0'for r in inputs)
assert all(not(int(r['input'])&0x82)for r in rows)
def triple(a):return{(a+4*i,32)for i in range(3)}
allow={'movement':triple(state+0x3c),'collision':triple(pool+67*0x260+0xa0),'storedGraphics':triple(pool+67*0x260+0x20),'action':{(state+0xc,32)},'actionState':{(state+0x18,16)},'actionTimer':{(state+0x1a,16)},'forwardVel':{(state+0x54,32)},'velocity':triple(state+0x48),'facePitch':{(state+0x2c,16)},'faceYaw':{(state+0x2e,16)},'faceRoll':{(state+0x30,16)},'boxPosition':triple(pool+13*0x260+0xa0),'usedReference':{(state+0x80,32)},'timeStop':{(0x8033c110,32)}}
# The body-state allocation address is observed in the explicit contiguous HOLP cut.
holp=[w for w in writes if w['field']=='highHOLP'];assert len(holp)==3
ha=int(holp[0]['address'],16);assert ha==0x8033a058;allow['highHOLP']=triple(ha)
assert all(w['field']in allow and(int(w['address'],16),int(w['width']))in allow[w['field']]for w in writes)
assert len(writes)==66
assert {s:sum(int(w['step'])==s for w in writes)for s in [0,4,6,24,42,43,44]}=={0:22,4:1,6:1,24:3,42:19,43:19,44:1}
assert all((int(w['step'])in[0,42,43])or(w['field']=='usedReference'and int(w['step'])==4)or(w['field']=='timeStop'and int(w['step'])in[6,44])or(w['field']=='highHOLP'and int(w['step'])==24)for w in writes)
assert [int(w['after'],16)for w in writes if w['field']=='action']==[0x0c400201,0x0100088c,0x0100088c]
assert [int(w['after'],16)for w in writes if w['field']=='timeStop']==[66,0]
assert [int(w['after'],16)for w in holp]==[bits(-1849),bits(24800),bits(-971)]
assert slot(states[4]['used'])==23 and slot(states[4]['held'])==-1 and int(states[4]['action'],16)==0x383
assert slot(states[6]['held'])==13 and int(states[6]['surfaceCount'])==12
assert int(states[18]['action'],16)==0x08000207
assert all(r['timeStop']=='66'and r['surfaceCount']=='12'for k,r in states.items()if 7<=k<=44)
assert xyz(states[25]['boxXYZ'])==[-1849,24800,-939] and slot(states[25]['held'])==-1
assert all(xyz(r['boxXYZ'])==[-1849,24800,-939]for k,r in states.items()if k>=25)
assert float(states[43]['floorY'])==251 and slot(states[43]['floorOwner'])==13
assert slot(states[44]['floorOwner'])!=13
assert all(r['surfaceCount']=='0'and r['timeStop']=='0'for k,r in states.items()if k>=45)
surfaces={i:[]for i in states};links={i:[]for i in states}
for r in records('BOX_SURFACE'):
 s={k:int(r[k])for k in ['index','type','force','flags','room','lowerY','upperY']}
 for k in ['vertex1','vertex2','vertex3']:s[k]=[int(x)for x in xyz(r[k])]
 s['normal']=dict(zip('xyz',xyz(r['normal'])));s['originOffset']=float(r['originOffset']);surfaces[int(r['step'])].append(s)
for r in records('BOX_LINK'):links[int(r['step'])].append({k:int(r[k])for k in ['cellZ','cellX','kind','surface']})
assert all(len(surfaces[k])==int(states[k]['surfaceCount'])for k in states)
assert all(surfaces[k]==surfaces[6]and links[k]==links[6]for k in range(7,45))
assert all(s['vertex1'][1]in[51,251]and s['vertex2'][1]in[51,251]and s['vertex3'][1]in[51,251]for s in surfaces[6])
assert all(not surfaces[k]and not links[k]for k in range(45,49))
assert all(int(r['boxFlags'])&0x400==0 for r in rows) # OBJ_FLAG_HOLDABLE absent.
assert all(r['boxHeld']=='0'for r in rows)
# Carry scripts are consecutive two-word BEGIN/BREAK records in this JP behavior segment.
carry3=int(states[6]['command'],16);carry5=carry3+16
assert all(int(states[k]['command'],16)==carry3 and states[k]['opcode']=='00080000'for k in range(6,25))
assert all(int(states[k]['command'],16)==carry5 and states[k]['opcode']=='00080000'for k in range(25,45))
assert all(int(states[k]['command'],16)==carry5+4 and states[k]['opcode']=='0a000000'for k in range(45,49))
expectedPath=HERE.parent/'ink-box-floor-lifecycle/results.json.gz';r=json.load(gzip.open(expectedPath))['results']
expected=r['conditionalNativePickup']['samples'][:6]+r['nativeCloneTimeStop']['samples']+r['nativeCloneTimeStop']['highHOLPThrow']['samples']
assert len(expected)==42
mismatches=[];comparisons=[]
for step,s in enumerate(expected,1):
 n=states[step];pairs={k:(int(n[k]),s[k])for k in ['timer','area','timeStop','actionState','actionTimer','surfaceCount','totalAllocated','staticAllocated','nodesAllocated','staticNodes']}
 pairs['action']=(int(n['action'],16),s['action'])
 for k in ['held','used','platform','floorOwner']:pairs[k]=(slot(n[k]),s[k])
 for k in ['M','C','G']:
  for j,(a,b)in enumerate(zip(xyz(n[k]),s[k])):pairs[k+str(j)]=(bits(a),bits(b))
 for k,vs in [('HOLP',s['holp']),('boxXYZ',s['box']['position']),('transform',s['box']['transform'][3][:3])]:
  for j,(a,b)in enumerate(zip(xyz(n[k]),vs)):pairs[k+str(j)]=(bits(a),bits(b))
 pairs['floorY']=(bits(float(n['floorY'])),bits(s['floorY']))
 for nk,wk in [('boxFlags','oFlags'),('boxHeld','oHeldState'),('boxAction','oAction'),('boxTimer','oTimer'),('boxActive','activeFlags'),('boxType','oInteractType'),('boxSubtype','oInteractionSubtype'),('boxStatus','oInteractStatus'),('stack','bhvStackIndex')]:pairs[nk]=(int(n[nk]),s['box'][wk])
 pairs['parent']=(slot(n['parent']),s['box']['parentSlot']);pairs['throwMatrixNull']=(int(n['throwMatrix'],16)==0,s['box']['throwMatrix']=='null')
 pairs['surfaces']=(surface_bits(surfaces[step]),surface_bits(s['surfaces']));pairs['partitionLinks']=(links[step],s['boxPartitionLinks'])
 comparisons.append(dict(step=step,fields=len(pairs)))
 for k,(a,b)in pairs.items():
  if a!=b:mismatches.append(dict(step=step,field=k,native=a,wafel=b))
assert len(mismatches)==147
assert set(m['field']for m in mismatches)=={'timer','boxSubtype','HOLP0','HOLP1','HOLP2','throwMatrixNull'}
assert all(m['native']-m['wafel']==-2 for m in mismatches if m['field']=='timer')
assert all(m['native']==2 and m['wafel']==0 for m in mismatches if m['field']=='boxSubtype')
assert [m['step']for m in mismatches if m['field']=='throwMatrixNull']==list(range(1,7))
assert all([m['step']for m in mismatches if m['field']==k]==list(range(6,25))for k in ['HOLP0','HOLP1','HOLP2'])
for step in range(7,25):assert[bits(v)for v in xyz(states[step]['HOLP'])]==[bits(v)for v in expected[step-2]['holp']]
summary=records('RESULT')[-1];assert all(summary[k]=='0'for k in ['aPressedFrames','aDownFrames','controllerAFrames'])
receipt=dict(schema=1,date='2026-11-14',scope='Original JP conditional native fakepickup, supplied time stop and high HOLP; low mesh survives high actor throw at old coordinates, clears on resume. No reachable clone/delivery/time-stop claim.',observations=48,writes=writes,inputs=inputs,states=rows,surfaces=surfaces,partitionLinks=links,noA=summary,comparedBoundaries=42,comparisons=comparisons,mismatches=mismatches,strictObservedFieldsMatch=not mismatches,physicalFieldsMatch=True,physicalFieldsScope='All compared fields except global timer, interaction subtype, HOLP and throwMatrix; every excluded mismatch is retained. HOLP steps7-24 match the previous Wafel post-render boundary.',romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',expectedSha256=sha(expectedPath),hashes={n:sha(out/n)for n in ['trace.txt','probe-source.c','prefix-source.c','run-source.sh']},checkerSha256=sha(Path(__file__)))
receipt=json.loads(json.dumps(receipt))
if archived:assert json.loads((out/'receipt.json').read_text())==receipt
else:
 (out/'checker-source.py').write_bytes(Path(__file__).read_bytes());(out/'receipt.json').write_bytes((json.dumps(receipt,indent=2)+'\n').encode())
print(json.dumps(dict(observations=48,writes=len(writes),comparedBoundaries=42,mismatches=len(mismatches),mismatchFields=sorted(set(m['field']for m in mismatches)),oldFloor=float(states[43]['floorY']),oldOwner=slot(states[43]['floorOwner']),newFloor=float(states[44]['floorY']),newOwner=slot(states[44]['floorOwner']),resumedBoxTriangles=int(states[45]['surfaceCount']),archived=archived)))
