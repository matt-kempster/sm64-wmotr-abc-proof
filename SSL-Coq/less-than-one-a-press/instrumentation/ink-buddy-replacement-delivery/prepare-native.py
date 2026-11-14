"""Fresh replay of the selected real small-box carry/throw, no setup cuts."""
import gzip,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import Guard,create_game,Observer,sample,advance
from replay import bits
HERE=Path(__file__).resolve().parent
r=json.loads(gzip.decompress(Path('build/wafel-pilot/buddy-replacement-smallbox-release-v1.json.gz').read_bytes()))
t=next(t for t in r['trials']if t['name']=='highest-carry'and t['button']==0x4000)
inputs=t['prefixInputs']+t['inputs']+[dict(buttons=0,stick=[0,0])]*2
(HERE/'controller.inputs').write_bytes((''.join('%d %d %d %d\n'%(i+1,p['buttons'],*p['stick'])for i,p in enumerate(inputs))).encode())
(HERE/'inputs.jsonl').write_bytes((''.join(json.dumps(p,separators=(',',':'))+'\n'for p in inputs)).encode())
g=Guard(create_game());o=Observer(g);rows=[]
for i,p in enumerate(inputs):
 if i>=348:
  s=sample(g,o,23);s.update(poll=i+1,observation=o.snapshot(),boxBits=[bits(v)for v in s['actor']['xyz']],boxHeld=s['actor']['oHeldState'],boxActive=s['actor']['activeFlags'],boxAction=s['actor']['oAction'])
  rows.append(s)
 if len(t['prefixInputs'])<=i<=len(t['prefixInputs'])+len(t['inputs']):assert sample(g,o,23)==t['samples'][i-len(t['prefixInputs'])]
 advance(g,p)
with gzip.GzipFile(filename=str(HERE/'wafel-trace.json.gz'),mode='wb',mtime=0)as f:f.write((json.dumps(rows,separators=(',',':'))+'\n').encode())
print('Prepared',len(inputs),'inputs;',len(rows),'before-poll observations')
