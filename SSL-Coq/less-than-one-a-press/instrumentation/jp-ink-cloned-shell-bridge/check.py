"""Audit original-JP frozen-shell controls; retain every selected-field mismatch."""
import argparse,gzip,hashlib,json,re,struct
from pathlib import Path
HERE=Path(__file__).resolve().parent
POOL=0x8033c118;STATE=0x80339e00;MARIO=POOL+67*0x260;SHELL=POOL+71*0x260
def data(path):
 if path.exists():return path.read_bytes()
 return gzip.decompress(Path(str(path)+'.gz').read_bytes())
def sha(b):return hashlib.sha256(b).hexdigest()
def fields(s):return dict(re.findall(r'(\w+)=((?:\([^)]*\))|[^,\n]+)',s))
def xyz(s):return[float(x)for x in s.strip('()').split(',')]
def bits(v):return struct.unpack('>I',struct.pack('>f',v))[0]
def slot(h):
 p=int(h,16)
 return(p-POOL)//0x260 if p>=POOL and(p-POOL)%0x260==0 and(p-POOL)//0x260<240 else -1 if p==0 else -2
def cut_words(edits):
 out={}
 for e in edits:
  p=e['path'];v=e['after'];width=32;floaty=False
  vectors={'gMarioState.pos':STATE+0x3c,'gMarioState.vel':STATE+0x48,'gMarioObject.header.gfx.pos':MARIO+0x20,'gMarioState.marioBodyState.heldObjLastPosition':0x8033a058}
  scalars={'gMarioState.action':(STATE+0xc,32,False),'gMarioState.actionState':(STATE+0x18,16,False),'gMarioState.actionTimer':(STATE+0x1a,16,False),'gMarioState.forwardVel':(STATE+0x54,32,True),'gMarioState.usedObj':(STATE+0x80,32,False)}
  if p in vectors:
   for i,x in enumerate(v):out[vectors[p]+4*i,32]=bits(x)
   continue
  if p=='gMarioState.faceAngle':
   for i,x in enumerate(v):out[STATE+0x2c+2*i,16]=x&0xffff
   continue
  if p in scalars:a,width,floaty=scalars[p]
  elif p.startswith('gMarioObject.oPos'):a=MARIO+0xa0+4*'XYZ'.index(p[-1]);floaty=True
  else:
   m=re.fullmatch(r'gObjectPool\[(\d+)\]\.(oPos[XYZ]|oAction)',p);assert m,p
   a=POOL+int(m[1])*0x260+(0x14c if m[2]=='oAction'else 0xa0+4*'XYZ'.index(m[2][-1]));floaty=m[2]!='oAction'
  if isinstance(v,str):v=POOL+int(re.fullmatch(r'gObjectPool\[(\d+)\]',v)[1])*0x260
  assert(a,width)not in out,p
  out[a,width]=bits(v)if floaty else int(v)&((1<<width)-1)
 return out

def main():
 ap=argparse.ArgumentParser();ap.add_argument('directory',type=Path);ap.add_argument('--archived',action='store_true');a=ap.parse_args();out=a.directory
 raw=data(out/'raw.log').decode(errors='replace');records=lambda tag:[fields(s)for s in raw.splitlines()if s.startswith(tag+',')]
 assert 'SC_ERROR'not in raw
 assert 'Core: MD5: 85D61F5525AF708C9F1E84DCE6DC10E9'in raw and 'activated cheat code 6: Have\\Level Select'in raw
 assert data(out/'trace.txt').decode()==''.join(s+'\n'for s in raw.splitlines()if s.startswith(('SC_','RESULT,')))
 rows=records('SC_STATE');states={int(s['step']):s for s in rows};writes=records('SC_WRITE');inputs=records('SC_INPUT');mode=int(rows[0]['mode'])
 assert mode in[1,2,3]and len(states)==len(rows)and all(int(s['mode'])==mode for s in rows)
 bybridge={int(s['bridge']):s for s in rows if int(s['bridge'])>=1}
 absent=sorted(set(range(1,int(rows[-1]['step'])+1))-set(states));assert absent==([]if mode==2 else[154,155])
 assert sorted(states)==[i for i in range(1,166+(mode==3))if i not in absent]
 assert[int(s['step'])for s in inputs]==list(range(1,167+(mode==3)))
 zstep=132
 assert all(s['A']=='0'and s['x']==s['y']=='0'and int(s['buttons'])==(16384 if int(s['step'])in[3,20]else 8192 if int(s['step'])==zstep else 0)for s in inputs)
 assert all(not(int(s['input'])&0x82)for s in rows)
 summary=records('RESULT')[-1];assert all(summary[k]=='0'for k in['aPressedFrames','aDownFrames','controllerAFrames'])
 expectedPath=HERE/'expected.json.gz';expected=json.loads(gzip.decompress(expectedPath.read_bytes()));trial=expected['trials'][str(mode)];prep=expected['preparation'];release=prep['releases']['25000']
 initialstep=131 if mode==3 else 130
 cuts={0:prep['shell']['edits'],2:prep['pickup']['edits'],6:prep['pickup']['targetCut']['edits'],25:release['highHOLP']['edits'],initialstep:trial['edits']}
 if mode==1:cuts[131]=trial['highCut']+trial['cuts'][0]['edits']
 elif mode==2:cuts[131]=trial['cuts'][0]['edits']
 actual={}
 triple=lambda a:{(a+4*i,32)for i in range(3)}
 labels={'movement':triple(STATE+0x3c),'collision':triple(MARIO+0xa0),'storedGraphics':triple(MARIO+0x20),'velocity':triple(STATE+0x48),'forwardVel':{(STATE+0x54,32)},'action':{(STATE+0xc,32)},'actionState':{(STATE+0x18,16)},'actionTimer':{(STATE+0x1a,16)},'facePitch':{(STATE+0x2c,16)},'faceYaw':{(STATE+0x2e,16)},'faceRoll':{(STATE+0x30,16)},'shellPosition':triple(SHELL+0xa0),'actorPosition':triple(POOL+39*0x260+0xa0),'shellBoxAction':{(POOL+32*0x260+0x14c,32)},'usedReference':{(STATE+0x80,32)},'highHOLP':triple(0x8033a058)}
 for w in writes:
  step=int(w['step']);key=int(w['address'],16),int(w['width']);assert key not in actual.setdefault(step,{})
  assert w['field']in labels and key in labels[w['field']]
  actual[step][key]=int(w['after'],16)
 assert actual=={s:cut_words(es)for s,es in cuts.items()}
 assert len(writes)=={1:61,2:49,3:46}[mode]
 # Native pickup/release timing and unchanged initialized shell fields.
 assert int(states[6]['action'],16)==0x383 and slot(states[6]['used'])==23 and slot(states[6]['held'])==-1
 assert slot(states[8]['held'])==71 and int(states[19]['action'],16)==0x08000207
 assert slot(states[26]['held'])==-1 and xyz(states[26]['shellXYZ'])==[-1950,24990,-939]
 for step,s in states.items():
  if s['area']=='1':
   assert int(s['shellBehavior'],16)==0x800ea25c and int(s['shellType'])==524288 and s['shellIntangible']=='0'
   assert float(s['shellRadius'])==float(s['shellHeight'])==50 and s['shellHeld']=='0'
   if step>=8:assert s['opcode']=='0a000000'and s['stack']=='0'
   if step>=26:assert s['command']=='800eb778'
 b1=bybridge[1];assert b1['shellStatus']==('49155'if mode==1 else'4194304')
 if mode==1:
  assert int(b1['action'],16)==0x20810446 and slot(b1['ridden'])==71 and float(b1['floorY'])==1024
  producer=bybridge[2];capture=bybridge[3]
  assert xyz(producer['M'])==xyz(producer['C'])==[-1882,768,-939]and xyz(producer['G'])==[-1882,25000,-939]
  assert slot(capture['used'])==64 and slot(capture['platform'])==slot(capture['floorOwner'])==61
  assert all(slot(s['platform'])==61 and slot(s['floorOwner'])==61 for i,s in bybridge.items()if 3<=i<=23)
  arrival=next(s for s in rows if s['area']=='2');assert int(arrival['bridge'])==26
  assert[bits(v)for v in xyz(arrival['M'])]==[bits(v)for v in[365.5927734375,5500,-1096.8026123046875]]
 elif mode==2:
  assert int(b1['action'],16)==0x20462 and slot(b1['ridden'])==-1 and xyz(b1['M'])==[-1950,25000,-939]and xyz(b1['G'])==[-1950,25045,-939]
  assert xyz(bybridge[2]['M'])==[-1861,25000,-939]and int(bybridge[2]['action'],16)==0x20462
  assert all(s['area']=='1'and slot(s['platform'])==-1 for s in bybridge.values());arrival=None
 else:
  assert int(b1['action'],16)==0x20466 and xyz(b1['M'])==[-1950,768,-939]and xyz(b1['G'])==[-1950,25000,-939]
  assert slot(bybridge[2]['used'])==64 and all(slot(s['platform'])==-1 for s in bybridge.values())
  arrival=next(s for s in rows if s['area']=='2');assert int(arrival['bridge'])==25 and xyz(arrival['M'])==[0,5500,256]
 # Compare every available selected boundary, keeping missing camera observations explicit.
 selections=[(2,prep['shell']['after'])]+[(i+3,s)for i,s in enumerate(prep['pickup']['samples'])]+[(i+20,s)for i,s in enumerate(release['samples'])]
 if mode==1:selections.append((131,trial['lowMount']['sample']))
 selections += [(initialstep+1+i+(mode==1),s)for i,s in enumerate(trial['samples'])]
 comparisons=[];mismatches=[];missing=[];semantic=[]
 commands={0x800eb764:'bhvCarrySomething3[0]',0x800eb768:'bhvCarrySomething3[1]',0x800eb774:'bhvCarrySomething5[0]',0x800eb778:'bhvCarrySomething5[1]'}
 for step,s in selections:
  if step not in states:missing.append(dict(step=step,expectedArea=s['area'],expectedM=s['M'],reason='No SC_CAMERA observation during the native transition'));continue
  n=states[step];pairs={k:(int(n[k]),s[k])for k in['timer','area','actionState','actionTimer','input']}
  pairs.update(action=(int(n['action'],16),s['action']),topTimer=(int(n['topTimer']),s['topTimer']),topAction=(int(n['topAction']),s['topAction']),topActive=(int(n['topActive']),s['topActive']))
  for k in['held','used','ridden','platform','floorOwner']:pairs[k]=slot(n[k]),s[k]
  for k,wk in[('M','M'),('C','C'),('G','G'),('vel','velocity')]:
   for j,(x,y)in enumerate(zip(xyz(n[k]),s[wk])):pairs[k+str(j)]=bits(x),bits(y)
  for k,wk in[('floorY','floorY'),('ceilY','ceilingY'),('forward','forwardVelocity')]:pairs[k]=bits(float(n[k])),bits(s[wk])
  for j,(x,y)in enumerate(zip(xyz(n['shellXYZ']),s['shell']['position'])):pairs['shellXYZ'+str(j)]=bits(x),bits(y)
  for nk,wk in[('shellActive','activeFlags'),('shellType','oInteractType'),('shellIntangible','oIntangibleTimer'),('shellStatus','oInteractStatus'),('shellAction','oAction'),('shellHeld','oHeldState'),('stack','bhvStackIndex')]:pairs[nk]=int(n[nk]),s['shell'][wk]
  for nk,wk in[('shellRadius','hitboxRadius'),('shellHeight','hitboxHeight')]:pairs[nk]=bits(float(n[nk])),bits(s['shell'][wk])
  pairs['shellBehavior']=('bhvKoopaShell'if n['shellBehavior']=='800ea25c'else n['shellBehavior']),s['shell']['behavior']
  if int(n['command'],16)in commands or str(s['shell']['command']).startswith('bhvCarrySomething'):pairs['command']=commands.get(int(n['command'],16),n['command']),s['shell']['command']
  nc=int(n['collidedCount']);assert nc<=4
  pairs['collisions']=[slot(p)for p in n['collided'].strip('()').split(',')[:nc]],s['collisions']
  comparisons.append(dict(step=step,bridge=int(n['bridge']),area=s['area'],fields=len(pairs)))
  for k,(x,y)in pairs.items():
   if x!=y:
    mm=dict(step=step,bridge=int(n['bridge']),area=s['area'],field=k,native=x,wafel=y);mismatches.append(mm)
    # Compare all selected physical fields, retaining the raw global-clock offset.
    if k!='timer':semantic.append(mm)
 assert all(m['native']-m['wafel']==-2 for m in mismatches if m['field']=='timer')
 assert len(mismatches)==len(comparisons)and{m['field']for m in mismatches}=={'timer'}
 assert [m['step']for m in missing]==([]if mode==2 else[154,155])
 receipt=dict(schema=1,date='2026-11-14',mode=mode,height=25000,scope='Original JP conditional fake pickup, high HOLP and initial-state cuts; positive has explicit high rider relocation. No legal delivery or high-Mario reachability claim.',nativeObservations=len(rows),writes=writes,inputs=inputs,states=rows,noA=summary,arrival=arrival,comparedBoundaries=len(comparisons),comparisons=comparisons,missingNativeObservations=missing,mismatches=mismatches,strictSelectedFieldsMatch=not mismatches,semanticMismatches=semantic,semanticSelectedFieldsMatch=not semantic,semanticScope='All selected fields match after the sole global timer normalization native+2=Wafel. Every raw timer mismatch remains recorded. This is not a full-memory comparison.',romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',expectedSha256=sha(expectedPath.read_bytes()),sourceHashes={n:sha(data(out/n))for n in['raw.log','trace.txt','probe-source.c','prefix-source.c','run-source.sh']},checkerSha256=sha(Path(__file__).read_bytes()))
 if a.archived:assert json.loads(data(out/'receipt.json'))==receipt
 else:(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8');(out/'checker-source.py').write_bytes(Path(__file__).read_bytes())
 print(json.dumps(dict(mode=mode,observations=len(rows),writes=len(writes),compared=len(comparisons),missing=len(missing),mismatches=len(mismatches),mismatchFields=sorted({m['field']for m in mismatches}),semanticMismatches=len(semantic))))
 if semantic:print(json.dumps(semantic[:12],indent=2))
 assert not semantic,'Unexplained selected-field differences; retained in receipt'
if __name__=='__main__':main()
