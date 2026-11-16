"""Compare native release/handoff boundaries; preserve every mismatch explicitly."""
import argparse,gzip,hashlib,json,re,struct
from pathlib import Path
HERE=Path(__file__).resolve().parent;POOL=0x8033c118
def data(p):return p.read_bytes() if p.exists() else gzip.decompress(Path(str(p)+'.gz').read_bytes())
def sha(p):return hashlib.sha256(data(p)).hexdigest()
def fields(s):return dict(re.findall(r'(\w+)=((?:\([^)]*\))|[^,\n]+)',s))
def xyz(s):return [float(x)for x in s.strip('()').split(',')]
def bits(x):return struct.unpack('>I',struct.pack('>f',x))[0]
def slot(x):
 p=int(x,16)
 return (p-POOL)//0x260 if POOL<=p<POOL+240*0x260 and (p-POOL)%0x260==0 else -1 if p==0 else -2
def main():
 ap=argparse.ArgumentParser();ap.add_argument('directory',type=Path);ap.add_argument('--archived',action='store_true');a=ap.parse_args();d=a.directory
 case=json.loads(data(d/'case.json'));raw=data(d/'raw.log').decode(errors='replace')
 rec=lambda tag:[fields(s)for s in raw.splitlines()if s.startswith(tag+',')]
 states={int(s['bridge']):s for s in rec('SC_STATE')if int(s['bridge'])>0}
 actors={key:{int(s['bridge']):s for s in rec(tag)}for key,tag in [('39','EB_BOB'),('49','PP_BOX')]}
 mismatches=[];checked=[];missing=[]
 for i,s in enumerate(case['expected'],1):
  if i not in states:missing.append(i);continue
  n=states[i];pairs={k:(int(n[k]),s[k])for k in ['timer','area','actionState','actionTimer','input','topTimer','topAction']}
  pairs['action']=int(n['action'],16),s['action']
  for k in ['held','used','ridden','platform','floorOwner']:pairs[k]=slot(n[k]),s[k]
  for nk,wk in [('M','M'),('C','C'),('G','G'),('vel','velocity')]:
   for j,(x,y)in enumerate(zip(xyz(n[nk]),s[wk])):pairs[nk+str(j)]=bits(x),bits(y)
  for nk,wk in [('floorY','floorY'),('ceilY','ceilingY'),('forward','forwardVelocity')]:pairs[nk]=bits(float(n[nk])),bits(s[wk])
  nc=int(n['collidedCount']);pairs['collisions']=[slot(x)for x in n['collided'].strip('()').split(',')[:nc]],s['collisions']
  for nk,wk in [('shellActive','activeFlags'),('shellType','oInteractType'),('shellIntangible','oIntangibleTimer'),('shellStatus','oInteractStatus'),('shellAction','oAction'),('shellHeld','oHeldState')]:pairs[nk]=int(n[nk]),s['shell'][wk]
  for key in ['39','49']:
   b=actors[key][i];q=s['actors'][key]
   for nk,wk in [('active','activeFlags'),('type','oInteractType'),('subtype','oInteractionSubtype'),('intangible','oIntangibleTimer'),('status','oInteractStatus'),('action','oAction'),('timer','oTimer'),('held','oHeldState')]:pairs[key+'.'+nk]=int(b[nk]),q[wk]
   for nk,wk in [('radius','hitboxRadius'),('height','hitboxHeight'),('forward','oForwardVel')]:pairs[key+'.'+nk]=bits(float(b[nk])),bits(q[wk])
   for nk,wk in [('pos','position'),('scale','scale')]:
    for j,(x,y)in enumerate(zip(xyz(b[nk]),q[wk])):pairs[key+'.'+nk+str(j)]=bits(x),bits(y)
   for j,k in enumerate(['oVelX','oVelY','oVelZ']):
    if k in q:pairs[key+'.vel'+str(j)]=bits(xyz(b['vel'])[j]),bits(q[k])
  fuse=s.get('bobFuse',s.get('bobDynamics',{}).get('oBobombFuseTimer'))
  if fuse is not None:pairs['39.fuse']=int(actors['39'][i]['fuse']),fuse
  checked.append(dict(bridge=i,fields=len(pairs)))
  mismatches.extend(dict(bridge=i,field=k,native=x,wafel=y)for k,(x,y)in pairs.items()if x!=y)
 mount=128-case['seedPhase'];producer=mount+3
 writes=rec('SC_WRITE');later=[s for s in writes if int(s['bridge'])>mount]
 joint=[s for s in writes if int(s['bridge'])>=0]
 assert not later,later
 if case['seedPhase']==126:
  assert not any(s['field'].startswith('gObjectPool[49]')and int(s['bridge'])>=1 for s in joint)
  # This variant supplies the held Bob before128; native shell mount drops it
  # on128. Reject all Bob field edits after that release, not before it.
  assert not any(s['field'].startswith('gObjectPool[39]')and int(s['bridge'])>=3 for s in joint)
 assert all(not e['path'].startswith('gObjectPool[')or e['path'].startswith('gObjectPool[39]')for c in case['cuts']if c['phase']==128 for e in c['edits'])
 assert slot(states[3]['held'])==-1
 assert int(actors['39'][3]['held'])==0
 queries=rec('FD_QUERY');roles={}
 for name,addr in [('initialGeometry',0x802538a0),('shoveValidation',0x8024d550),('groundQuarter',0x80255930)]:
  roles[name]=[q for q in queries if int(q['bridge'])==producer and q['current']=='80346038' and int(q['caller'],16)==addr]
 capture=next((i for i,s in states.items()if slot(s['used'])==64 and slot(s['floorOwner'])==slot(s['platform'])==61),None)
 arrival=next((s for s in states.values()if s['area']=='2'),None)
 retained=capture is not None and all(slot(s['platform'])==61 for i,s in states.items()if i>=capture and s['area']=='1')
 result=rec('RESULT')[-1]
 out=dict(schema=1,case=case['name'],seedPhase=case['seedPhase'],checked=checked,missingNativeCameraBoundaries=missing,mismatches=mismatches,producerQueryRoles=roles,queries=queries,stateWrites=writes,noActorWritesAfterRespectiveRelease=True if case['seedPhase']==126 else None,noGameplayWritesAfterMountSetup=not later,captureBridge=capture,retainedObserved=retained,arrival=arrival,controls=rec('SC_INPUT'),prefixAudit=result,bobRows=rec('EB_BOB'),boxRows=rec('PP_BOX'),sourceHashes={n:sha(d/n)for n in ['raw.log','trace.txt','probe-source.c','prefix-source.c','run-source.sh','case.json']},checkerSha256=sha(Path(__file__)))
 if a.archived:assert json.loads(data(d/'receipt.json'))==out
 else:(d/'receipt.json').write_bytes((json.dumps(out,indent=2)+'\n').encode())
 assert 'SC_ERROR'not in raw
 unexpected=[x for x in mismatches if not(x['field']=='timer'and x['native']+2==x['wafel'])and not(x['field']=='49.subtype'and x['native']==2 and x['wafel']==0)]
 assert not unexpected,unexpected[:20]
 assert all(result[k]=='0'for k in ['aPressedFrames','aDownFrames','controllerAFrames'])
 assert all(s['A']=='0'and not int(s['buttons'])&0x8000 for s in rec('SC_INPUT'))
 assert missing==[mount+25,mount+26],missing
 assert arrival is not None
 want=case['expected'][-1]['M'];assert list(map(bits,xyz(arrival['M'])))==list(map(bits,want))
 useful=want==[365.5927734375,5500,-1096.8026123046875]
 assert (capture is not None)==useful
 if useful:assert retained and roles['initialGeometry'] and float(roles['initialGeometry'][0]['result'])==768
 print(json.dumps(dict(case=case['name'],checked=len(checked),components=sum(s['fields']for s in checked),missing=missing,mismatches=len(mismatches),capture=capture,retained=retained,arrival=arrival['M'],floorQueries=len(queries),writes=len(writes))))
if __name__=='__main__':main()
