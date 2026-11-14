"""Verify the three capture packets independently of movie presentation files."""
import argparse,gzip,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
ap=argparse.ArgumentParser();ap.add_argument('--check',action='store_true');a=ap.parse_args()
names=['positive','no-final-box','positive-closeup'];summary=[];paths=[]
checker=HERE.parent/'jp-ink-enlarged-bob-handoff/check.py'
for name in names:
 d=HERE/'records'/name
 for file,digest in json.loads((d/'archive-hashes.json').read_text()).items():assert sha(d/file)==digest
 assert gzip.decompress((d/'checker-source.py.gz').read_bytes())==checker.read_bytes()
 subprocess.run([sys.executable,str(checker),str(d),'--archived'],check=True)
 mapfile=HERE/(name+'-frame-map.json');m=json.loads(mapfile.read_text());assert m['additionalGameplayWrites']==0
 assert m['originalNativeStatesMatched']==172 and m['wafelComparedBoundaries']==25
 assert m['missingWafelNativeCameraBoundaries']==[25,26]
 assert len(m['frameMap'])==64 and[m['index']for m in m['frameMap']if m['state']is None]==[24,63]
 for f in m['frameMap']:
  p=HERE/f['file'];assert sha(p)==f['sha256'];paths.append(p)
  if f['request']:assert f['framebufferTimer']==int(f['request']['requestTimer'])-1
 for bridge,file in m['selectedFrames'].items():assert any(f['file']==file and f['completedBridge']==int(bridge)for f in m['frameMap'])
 if name=='positive-closeup':
  assert len(m['cameraRenderWrites'])==441 and m['extendedViewComparison']['statesMatched']==192
  q=m['queryComparison'];assert q['matched']==365 and q['originalTotal']==682 and q['captureTotal']==548
  assert len(q['excludedOriginal'])==317 and len(q['excludedCapture'])==183
 else:assert not m['cameraRenderWrites']and not m['queryComparison']['excludedOriginal']
 summary.append(dict(case=name,pngs=64,joined=62,originalNativeStatesMatched=m['originalNativeStatesMatched'],originalNativeQueriesMatched=m['originalNativeQueriesMatched'],capture=m['capture'],arrival=m['arrival']['M'],renderFieldWrites=len(m['cameraRenderWrites'])))
 paths.extend([mapfile,HERE/(name+'.c'),HERE/(name+'.json')]);paths.extend(p for p in d.iterdir()if p.is_file())
paths.extend(HERE/p for p in['.gitattributes','README.md','prepare_capture.py','prepare_closeup.py','map_capture.py','run.sh','source-provenance.json','closeup-provenance.json','verify_capture.py'])
files={p.relative_to(HERE).as_posix():sha(p)for p in sorted(set(paths))}
out=dict(schema=1,scope=__doc__,startRevision='4aca530130f3c1f6b705c3060d383d8459b6d43b',captureRuns=3,romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',cases=summary,files=files)
target=HERE/'capture-receipt.json'
if a.check:assert json.loads(target.read_text())==out
else:target.write_bytes((json.dumps(out,indent=2)+'\n').encode())
print('PASS capture archives, native checks, frame joins and',len(files),'file hashes')
