"""Check original-JP diagnostic histories against the saved Wafel histories.

The comparison is selected state fields, not full memory. All discrepancies,
including the established native/Wafel clock offset, remain in the receipt.
"""
import argparse,gzip,hashlib,json,re,struct
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
POOL=0x8033c118
def data(p):
 p=Path(p)
 return p.read_bytes()if p.exists()else gzip.decompress(Path(str(p)+'.gz').read_bytes())
def sha(p):return hashlib.sha256(data(p)).hexdigest()
def fields(s):return dict(re.findall(r'(\w+)=((?:\([^)]*\))|[^,\n]+)',s))
def xyz(s):return [float(x)for x in s.strip('()').split(',')]
def bits(v):return struct.unpack('>I',struct.pack('>f',v))[0]
def slot(h):
 p=int(h,16)
 return (p-POOL)//0x260 if p>=POOL and(p-POOL)%0x260==0 and(p-POOL)//0x260<240 else -1 if p==0 else -2
def main():
 ap=argparse.ArgumentParser();ap.add_argument('directory',type=Path);ap.add_argument('--archived',action='store_true');a=ap.parse_args();d=a.directory
 raw=data(d/'raw.log').decode(errors='replace');lines=raw.splitlines();assert 'SC_ERROR'not in raw
 records=lambda tag:[fields(s)for s in lines if s.startswith(tag+',')]
 states=records('SC_STATE');mode=int(states[0]['mode']);queries=records('FD_QUERY')
 path=ROOT/('instrumentation/ink-shell-lower-boundary/results.json.gz'if mode==1 else'instrumentation/ink-bobomb-retimed-shoves/results.json.gz')
 result=json.loads(gzip.decompress(path.read_bytes()))
 t=result['results']['oldSequence'][0]if mode==1 else result['results']['trials'][0]
 expected=t['samples'];observed={int(s['bridge']):s for s in states if int(s['bridge'])>=1}
 mismatches=[];checked=[];missing=[]
 for i,s in enumerate(expected[:35],1):
  if i not in observed:missing.append(i);continue
  n=observed[i];pairs={k:(int(n[k]),s[k])for k in['timer','area','actionState','actionTimer','input']}
  pairs.update(action=(int(n['action'],16),s['action']),topTimer=(int(n['topTimer']),s['topTimer']),topAction=(int(n['topAction']),s['topAction']))
  for k in['held','used','ridden','platform','floorOwner']:pairs[k]=slot(n[k]),s[k]
  for k,wk in[('M','M'),('C','C'),('G','G'),('vel','velocity')]:
   for j,(x,y)in enumerate(zip(xyz(n[k]),s[wk])):pairs[k+str(j)]=bits(x),bits(y)
  for k,wk in[('floorY','floorY'),('ceilY','ceilingY'),('forward','forwardVelocity')]:pairs[k]=bits(float(n[k])),bits(s[wk])
  for nk,wk in[('shellActive','activeFlags'),('shellType','oInteractType'),('shellIntangible','oIntangibleTimer'),('shellStatus','oInteractStatus'),('shellAction','oAction'),('shellHeld','oHeldState')]:pairs[nk]=int(n[nk]),s['shell'][wk]
  nc=int(n['collidedCount']);pairs['collisions']=[slot(p)for p in n['collided'].strip('()').split(',')[:nc]],s['collisions']
  checked.append(dict(bridge=i,fields=len(pairs)))
  for k,(x,y)in pairs.items():
   if x!=y:mismatches.append(dict(bridge=i,field=k,native=x,wafel=y))
 semantic=[m for m in mismatches if m['field']!='timer'];assert not semantic,semantic
 assert all(m['native']+2==m['wafel']for m in mismatches if m['field']=='timer')
 assert missing==([25,26]if mode==1 else[]),missing
 summary=records('RESULT')[-1];assert all(summary[k]=='0'for k in['aPressedFrames','aDownFrames','controllerAFrames'])
 assert all(s['A']=='0'and not int(s['buttons'])&0x8000 for s in records('SC_INPUT'))
 cuts=records('SC_WRITE');initial=next(int(s['step'])for s in cuts if s['field']=='action'and int(s['after'],16)==0x0100088c)
 for s in cuts:
  if int(s['step'])>initial:assert s['field']in['box129','buddy129','box130','retimeBox129','retimeBox130'],s
 for bridge in range(1,6):assert any(int(q['bridge'])==bridge for q in queries)
 producer=observed[3 if mode==1 else 4]
 bridge=3 if mode==1 else 4
 sourceQueries={int(q['caller'],16):q for q in queries if int(q['bridge'])==bridge and q['current']=='80346038'and int(q['caller'],16)in[0x802538a0,0x8024d550,0x80255930]}
 assert set(sourceQueries)=={0x802538a0,0x8024d550,0x80255930}
 initialQuery=sourceQueries[0x802538a0];shoveQuery=sourceQueries[0x8024d550];quarterQuery=sourceQueries[0x80255930]
 expectedInitial=768 if mode==1 else 1933.4923095703125
 expectedLocal=1280 if mode==1 else 768
 assert bits(float(initialQuery['result']))==bits(expectedInitial)
 assert slot(initialQuery['owner'])==(-1 if mode==1 else 61)
 for q in[shoveQuery,quarterQuery]:
  assert float(q['result'])==expectedLocal and slot(q['owner'])==-1
  assert bits(float(q['cache']))==bits(expectedInitial)
 entries=[s for s in records('FD_GROUND_ENTRY')if int(s['bridge'])==bridge];assert len(entries)==1
 assert bits(float(entries[0]['floorY']))==bits(expectedInitial)
 stop=[s for s in records('FD_STEP')if int(s['bridge'])==bridge and s['pc']=='80255b4c'];assert len(stop)==1 and stop[0]['result']=='2'
 assert not any(int(s['bridge'])==bridge and s['pc']=='80255ab4'for s in records('FD_STEP'))
 local=[s for s in records('FD_LOCAL')if int(s['bridge'])==bridge and s['pc']=='80255b4c'];assert len(local)==1
 assert float(local[0]['floor'])==expectedLocal and float(local[0]['ceiling'])==1523 and local[0]['upperWall']=='00000000'
 ceiling=[]
 for j,line in enumerate(lines):
  if line.startswith('FD_LOCAL,'):
   q=fields(line)
   if int(q['bridge'])==bridge and q['pc']=='80255b4c':
    assert lines[j+1].startswith('FD_SURFACE,');s=fields(lines[j+1]);assert s['surface']==q['ceilingPointer'];ceiling.append(s)
 assert len(ceiling)==1 and slot(ceiling[0]['owner'])==61 and xyz(ceiling[0]['normal'])[1]<0
 assert bits(float(producer['floorY']))==bits(expectedInitial)
 if mode==1:
  assert float(producer['floorY'])==768
  arrival=next(s for s in states if s['area']=='2');assert list(map(bits,xyz(arrival['M'])))==list(map(bits,[365.5927734375,5500,-1096.8026123046875]))
 else:assert all(s['area']=='1'for s in observed.values());arrival=None
 out=dict(schema=1,mode=mode,scope=__doc__,proofStart='510ab2d31a625676c1ef7b3769892efd5ac8ffc6',romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',selectedFieldsMatchExceptClock=True,checked=checked,missingNativeCameraBoundaries=missing,mismatches=mismatches,producerQueryRoles=dict(initialGeometry=initialQuery,shoveValidation=shoveQuery,groundQuarter=quarterQuery),producerCeiling=ceiling[0],queries=queries,groundEntries=records('FD_GROUND_ENTRY'),quarters=records('FD_LOCAL'),stepHooks=records('FD_STEP'),topLoads=records('FD_TOP_LOAD'),producer=producer,arrival=arrival,allStateWrites=cuts,sourceHashes={n:sha(d/n)for n in['raw.log','trace.txt','probe-source.c','prefix-source.c','run-source.sh']},expectedArtifactSha256=sha(path),checkerSha256=sha(__file__))
 if a.archived:assert json.loads(data(d/'receipt.json'))==out
 else:(d/'receipt.json').write_text(json.dumps(out,indent=2)+'\n',encoding='utf-8')
 print(json.dumps(dict(mode=mode,checked=len(checked),queries=len(queries),quarters=len(out['quarters']),producerFloor=producer['floorY'],arrival=arrival['M']if arrival else None)))
if __name__=='__main__':main()
