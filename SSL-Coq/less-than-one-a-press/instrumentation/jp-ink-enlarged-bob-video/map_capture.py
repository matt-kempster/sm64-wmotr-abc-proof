"""Preserve native PNGs and join Rice's previous framebuffer to logged state.

PNG indexes are not game-update indexes. Missing camera observations across
the transition remain unjoined. The final automatic testshot is unjoined.
"""
import argparse,gzip,hashlib,json,re,shutil,struct
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def fields(line):return dict(re.findall(r'(\w+)=((?:\([^)]*\))|[^,\n]+)',line))
def records(text,tag):return[fields(s)for s in text.splitlines()if s.startswith(tag+',')]
def decode(path):return gzip.decompress(path.read_bytes()).decode()if path.suffix=='.gz'else path.read_text()
def main():
 ap=argparse.ArgumentParser();ap.add_argument('directory',type=Path);ap.add_argument('name',choices=['positive','no-final-box','positive-closeup']);a=ap.parse_args();source=a.directory.resolve();closeup=a.name=='positive-closeup'
 raw=(source/'raw.log').read_text(errors='replace');receipt=json.loads((source/'receipt.json').read_text())
 original=decode(HERE.parent/'jp-ink-enlarged-bob-handoff/records'/('positive'if closeup else a.name)/'raw.log.gz')
 # Exact native-to-native comparison; unlike the Wafel comparison this needs
 # no global-clock normalization. Capture changes no gameplay edit or query.
 assert records(raw,'SC_WRITE')==records(original,'SC_WRITE')
 renderCallers={'802ce8a0','803814e4'} if closeup else set()
 matchedQueries=lambda text:[q for q in records(text,'FD_QUERY')if q['caller']not in renderCallers]
 assert matchedQueries(raw)==matchedQueries(original)
 queryComparison=dict(scope='Exact records after separately disclosing the two changed render/shadow caller classes'if closeup else'All native query records match',matched=len(matchedQueries(raw)),originalTotal=len(records(original,'FD_QUERY')),captureTotal=len(records(raw,'FD_QUERY')),excludedOriginal=[q for q in records(original,'FD_QUERY')if q['caller']in renderCallers],excludedCapture=[q for q in records(raw,'FD_QUERY')if q['caller']in renderCallers])
 assert records(raw,'FD_STEP')==records(original,'FD_STEP')
 oldstates=records(original,'SC_STATE');newstates=records(raw,'SC_STATE')
 bykey={(s['step'],s['bridge']):s for s in newstates}
 for s in oldstates:assert bykey[s['step'],s['bridge']]==s
 extendedViewComparison=None
 if closeup:
  defaultPath=HERE/'records/positive/raw.log.gz';defaultRaw=decode(defaultPath)
  assert records(defaultRaw,'SC_STATE')==newstates
  extendedViewComparison=dict(defaultCaptureRawGzipSha256=sha(defaultPath),statesMatched=len(newstates),scope='Every recorded native SC_STATE field matches the unchanged-camera capture through bridge65; not full-memory equivalence')
 oldinputs=records(original,'SC_INPUT');newinputs=records(raw,'SC_INPUT')
 assert newinputs[:len(oldinputs)]==oldinputs
 assert all(s['A']=='0'and not int(s['buttons'])&32768 for s in newinputs)
 states={int(s['timer']):s for s in newstates};assert len(states)==len(newstates)
 requests=records(raw,'VIDEO_SCREENSHOT');cores=[int(x)for x in re.findall(r'Core: Captured screenshot for frame (\d+)\.',raw)]
 shots=sorted((source/'shots').glob('super_mario_64-*.png'));assert len(shots)==len(cores)==len(requests)+1
 assert[int(q['index'])for q in requests]==list(range(len(requests)))
 destination=HERE/'frames'/a.name;destination.mkdir(parents=True,exist_ok=True);mapping=[]
 for i,p in enumerate(shots):
  request=requests[i]if i<len(requests)else None
  timer=int(request['requestTimer'])-1 if request else None;state=states.get(timer)
  width,height=struct.unpack('>II',p.read_bytes()[16:24]);assert p.read_bytes()[:8]==b'\x89PNG\r\n\x1a\n'
  item=dict(index=i,file='frames/'+a.name+'/'+p.name,sha256=sha(p),width=width,height=height,request=request,coreCaptureFrame=cores[i],framebufferTimer=timer,completedBridge=int(state['bridge'])if state else None,state=state)
  if state and int(state['bridge'])>=1:
   item['updateFromAirCut']=int(state['bridge']);item['producerLabel']=127+int(state['bridge'])if int(state['area'])==1 and int(state['bridge'])<=4 else None
  mapping.append(item);shutil.copyfile(p,destination/p.name)
 assert {1,2,3,4,27}.issubset({m['completedBridge']for m in mapping})
 selected={str(bridge):next(m['file']for m in mapping if m['completedBridge']==bridge)for bridge in[1,2,3,4,23,27,30,35,40,50,60]}
 cameraWrites=records(raw,'VIDEO_CAMERA_WRITE')
 if closeup:
  assert len(cameraWrites)==7*len(requests)
  assert all(w['field'].startswith('GraphNodeCamera.')for w in cameraWrites)
 else:assert not cameraWrites
 note=dict(schema=1,case=a.name,source=str(source.relative_to(ROOT)),scope=__doc__,renderCamera='GraphNodeCamera output pos/focus/roll override; native Camera/LakituState unchanged'if closeup else'unchanged original camera',cameraRenderWrites=cameraWrites,additionalGameplayWrites=0,join='Rice previous completed framebuffer = requestTimer - 1; independent of native+2=Wafel clock normalization',originalNativeStatesMatched=len(oldstates),originalNativeQueriesMatched=len(matchedQueries(raw)),queryComparison=queryComparison,originalNativeWritesMatched=len(records(raw,'SC_WRITE')),wafelComparedBoundaries=len(receipt['checked']),retainedWafelClockMismatches=receipt['mismatches'],missingWafelNativeCameraBoundaries=receipt['missingNativeCameraBoundaries'],capture=receipt['capture'],arrival=receipt['arrival'],sourceHashes={n:sha(source/n)for n in['raw.log','trace.txt','receipt.json','probe-source.c','prefix-source.c','run-source.sh','case.json']},selectedFrames=selected,frameMap=mapping)
 note['extendedViewComparison']=extendedViewComparison
 (HERE/(a.name+'-frame-map.json')).write_bytes((json.dumps(note,indent=2)+'\n').encode())
 archive=HERE/'records'/a.name;archive.mkdir(parents=True,exist_ok=True)
 for name in['raw.log','trace.txt','receipt.json','probe-source.c','prefix-source.c','run-source.sh','case.json']:
  (archive/(name+'.gz')).write_bytes(gzip.compress((source/name).read_bytes(),mtime=0))
 checker=HERE.parent/'jp-ink-enlarged-bob-handoff/check.py';(archive/'checker-source.py.gz').write_bytes(gzip.compress(checker.read_bytes(),mtime=0))
 (archive/'archive-hashes.json').write_bytes((json.dumps({p.name:sha(p)for p in sorted(archive.iterdir())if p.name!='archive-hashes.json'},indent=2)+'\n').encode())
 print(json.dumps(dict(case=a.name,pngs=len(shots),joined=sum(m['state']is not None for m in mapping),unjoined=[m['index']for m in mapping if m['state']is None],selectedFrames=selected,nativeStatesMatched=len(oldstates))))
if __name__=='__main__':main()
