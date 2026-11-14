"""Native release at a controller-reached small-box high or near carry cut."""
import gzip,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import Guard,create_game,Observer,sample,advance

def run():
 p=json.loads(gzip.decompress(Path('build/wafel-pilot/buddy-replacement-smallbox-perimeter-v1.json.gz').read_bytes()))
 b=json.loads(gzip.decompress(Path('build/wafel-pilot/buddy-replacement-smallbox-beam-v2.json.gz').read_bytes()))
 t=p['trials'][2];idx=max(range(len(t['samples'])),key=lambda i:t['samples'][i]['M'][1]if t['samples'][i]['held']==23 else -10000)
 cuts=[dict(name='highest-carry',inputs=p['prefixInputs']+p['acquisition']['inputs']+t['inputs'][:idx],expected=t['samples'][idx]),
  dict(name='nearest-beam',inputs=b['prefixInputs']+b['acquisition']['inputs']+b['selected']['inputs'],expected=b['selected']['samples'][-1])]
 trials=[]
 for c in cuts:
  g=Guard(create_game());o=Observer(g)
  for pad in c['inputs']:advance(g,pad)
  assert sample(g,o,23)==c['expected'];state=g.save_state()
  for buttons in [0x2000,0x4000]:
   g.load_state(state);inputs=[];samples=[sample(g,o,23)]
   for n in range(45):
    pad=dict(buttons=buttons if n==0 else 0,stick=[0,0]);inputs.append(pad);advance(g,pad);samples.append(sample(g,o,23))
   result=dict(name=c['name'],prefixInputs=c['inputs'],button=buttons,inputs=inputs,samples=samples)
   trials.append(result)
   alive=[s for s in samples if s['actor']['activeFlags'] and s['actor']['behavior']=='bhvBreakableBoxSmall']
   print(c['name'],hex(buttons),'peak',max(s['actor']['xyz'][1]for s in alive),'release',next(((i,s['actor']['xyz'])for i,s in enumerate(samples)if s['held']!=23),None),'final',samples[-1]['actor']['activeFlags'],flush=True)
 out=dict(scope=__doc__,gameplayWrites=[],AInputs=0,startupGrant='gDebugLevelSelect=1 only',trials=trials)
 with gzip.GzipFile(filename='build/wafel-pilot/buddy-replacement-smallbox-release-v1.json.gz',mode='wb',mtime=0)as f:f.write((json.dumps(out,separators=(',',':'))+'\n').encode())
if __name__=='__main__':run()
