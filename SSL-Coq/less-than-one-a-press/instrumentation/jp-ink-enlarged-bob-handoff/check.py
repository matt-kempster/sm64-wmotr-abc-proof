"""Check original-JP recipe replays, preserving every comparison discrepancy."""
import argparse,gzip,hashlib,json,re,struct
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1];POOL=0x8033c118
def data(p):
 p=Path(p);return p.read_bytes()if p.exists()else gzip.decompress(Path(str(p)+'.gz').read_bytes())
def sha(p):return hashlib.sha256(data(p)).hexdigest()
def fields(s):return dict(re.findall(r'(\w+)=((?:\([^)]*\))|[^,\n]+)',s))
def xyz(s):return [float(x)for x in s.strip('()').split(',')]
def bits(v):return struct.unpack('>I',struct.pack('>f',v))[0]
def slot(h):
 p=int(h,16);return (p-POOL)//0x260 if p>=POOL and(p-POOL)%0x260==0 and(p-POOL)//0x260<240 else -1 if p==0 else -2
def main():
 ap=argparse.ArgumentParser();ap.add_argument('directory',type=Path);ap.add_argument('--archived',action='store_true');a=ap.parse_args();d=a.directory
 case=json.loads(data(d/'case.json'));raw=data(d/'raw.log').decode(errors='replace');lines=raw.splitlines()
 records=lambda tag:[fields(s)for s in lines if s.startswith(tag+',')]
 states=records('SC_STATE');observed={int(s['bridge']):s for s in states if int(s['bridge'])>=1};bobs={int(s['bridge']):s for s in records('EB_BOB')}
 mismatches=[];checked=[];missing=[]
 for i,s in enumerate(case['expected'],1):
  if i not in observed:missing.append(i);continue
  n=observed[i];pairs={k:(int(n[k]),s[k])for k in['timer','area','actionState','actionTimer','input']}
  pairs.update(action=(int(n['action'],16),s['action']),topTimer=(int(n['topTimer']),s['topTimer']),topAction=(int(n['topAction']),s['topAction']))
  for k in['held','used','ridden','platform','floorOwner']:pairs[k]=slot(n[k]),s[k]
  for k,wk in[('M','M'),('C','C'),('G','G'),('vel','velocity')]:
   for j,(x,y)in enumerate(zip(xyz(n[k]),s[wk])):pairs[k+str(j)]=bits(x),bits(y)
  for k,wk in[('floorY','floorY'),('ceilY','ceilingY'),('forward','forwardVelocity')]:pairs[k]=bits(float(n[k])),bits(s[wk])
  for nk,wk in[('shellActive','activeFlags'),('shellType','oInteractType'),('shellIntangible','oIntangibleTimer'),('shellStatus','oInteractStatus'),('shellAction','oAction'),('shellHeld','oHeldState')]:pairs[nk]=int(n[nk]),s['shell'][wk]
  nc=int(n['collidedCount']);pairs['collisions']=[slot(p)for p in n['collided'].strip('()').split(',')[:nc]],s['collisions']
  b=bobs[i];q=s['actors']['39']
  for nk,wk in[('active','activeFlags'),('type','oInteractType'),('subtype','oInteractionSubtype'),('intangible','oIntangibleTimer'),('status','oInteractStatus'),('action','oAction'),('timer','oTimer'),('held','oHeldState')]:pairs['bob.'+nk]=int(b[nk]),q[wk]
  for nk,wk in[('radius','hitboxRadius'),('height','hitboxHeight'),('forward','oForwardVel')]:pairs['bob.'+nk]=bits(float(b[nk])),bits(q[wk])
  for nk,wk in[('pos','position'),('scale','scale')]:
   for j,(x,y)in enumerate(zip(xyz(b[nk]),q[wk])):pairs['bob.'+nk+str(j)]=bits(x),bits(y)
  checked.append(dict(bridge=i,fields=len(pairs)))
  for k,(x,y)in pairs.items():
   if x!=y:mismatches.append(dict(bridge=i,field=k,native=x,wafel=y))
 queries=records('FD_QUERY');producerQueries={int(q['caller'],16):q for q in queries if int(q['bridge'])==3 and q['current']=='80346038'and int(q['caller'],16)in[0x802538a0,0x8024d550,0x80255930]}
 arrival=next((s for s in states if s['area']=='2'),None)
 capture=any(slot(s['used'])==64 and slot(s['platform'])==slot(s['floorOwner'])==61 for s in states)
 cuts=records('SC_WRITE');initial=next(int(s['step'])for s in cuts if s['field']=='gMarioState.action')
 later=[s for s in cuts if int(s['step'])>initial]
 summary=records('RESULT')[-1]
 roles={name:producerQueries[addr]for name,addr in [('initialGeometry',0x802538a0),('shoveValidation',0x8024d550),('groundQuarter',0x80255930)]}
 out=dict(schema=1,case=case['name'],proofStart='32f5eb4d5911b2e0a7972b748065c71ebe016717',romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',checked=checked,missingNativeCameraBoundaries=missing,mismatches=mismatches,producerQueryRoles=roles,queries=queries,producer=observed.get(3),arrival=arrival,capture=capture,bobRows=records('EB_BOB'),stepHooks=records('FD_STEP'),quarterLocals=records('FD_LOCAL'),stateWrites=cuts,controls=records('SC_INPUT'),prefixAudit=summary,sourceHashes={n:sha(d/n)for n in['raw.log','trace.txt','probe-source.c','prefix-source.c','run-source.sh','case.json']},checkerSha256=sha(__file__))
 if a.archived:assert json.loads(data(d/'receipt.json'))==out
 else:(d/'receipt.json').write_bytes((json.dumps(out,indent=2)+'\n').encode())
 assert 'SC_ERROR'not in raw
 assert not [m for m in mismatches if m['field']!='timer'],[m for m in mismatches if m['field']!='timer'][:10]
 assert all(m['native']+2==m['wafel']for m in mismatches if m['field']=='timer')
 assert missing==[25,26],missing
 assert all(re.fullmatch(r'gObjectPool\[\d+\]\.oPos[XYZ]',s['field'])for s in later)
 assert all(summary[k]=='0'for k in['aPressedFrames','aDownFrames','controllerAFrames'])
 assert all(s['A']=='0'and not int(s['buttons'])&0x8000 for s in records('SC_INPUT'))
 assert float(producerQueries[0x802538a0]['result'])==768
 stop=[s for s in records('FD_STEP')if s['bridge']=='3'and s['pc']=='80255b4c']
 assert len(stop)==1 and stop[0]['result']=='2' and float(stop[0]['cache'])==768
 assert not any(s['bridge']=='3'and s['pc']=='80255ab4'for s in records('FD_STEP'))
 local=[s for s in records('FD_LOCAL')if s['bridge']=='3'and s['pc']=='80255b4c'];assert len(local)==1
 assert float(local[0]['ceiling'])==1523 and local[0]['upperWall']=='00000000'
 assert float(producerQueries[0x80255930]['result'])==(1280 if case['name']=='positive' else 768)
 assert float(observed[3]['floorY'])==768 and float(observed[3]['M'].strip('()').split(',')[1])==768
 assert arrival is not None
 want=[365.5927734375,5500,-1096.8026123046875]if case['name']=='positive'else[0,5500,256]
 assert list(map(bits,xyz(arrival['M'])))==list(map(bits,want)),arrival
 assert capture==(case['name']=='positive')
 if capture:
  first=next(i for i,s in observed.items()if slot(s['used'])==64 and slot(s['platform'])==61)
  assert all(slot(s['platform'])==61 for i,s in observed.items()if i>=first and s['area']=='1')
 print(json.dumps(dict(case=case['name'],checked=len(checked),missing=missing,mismatches=len(mismatches),capture=capture,arrival=arrival['M'],floorQueries=len(queries))))
if __name__=='__main__':main()
