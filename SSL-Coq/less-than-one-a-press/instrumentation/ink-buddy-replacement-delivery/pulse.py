"""Actual carried small-box uphill stick/neutral cycle; no state edits."""
import argparse,gzip,json,math,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import Guard,create_game,Observer,sample,advance,steer

def run(a):
 source=json.loads(gzip.decompress(a.seed.read_bytes()))
 prefix=source['prefixInputs']+source['acquisition']['inputs']+source['selected']['inputs']
 g=Guard(create_game());o=Observer(g)
 for p in prefix:advance(g,p)
 assert sample(g,o,23)==source['selected']['samples'][-1]
 initial=sample(g,o,23);state=g.save_state();trials=[]
 for target in [[-2048,-1024],[-2048,500],[-500,0],[-2048,1200]]:
  for mode in ['continuous','pulse']:
   g.load_state(state);inputs=[];samples=[initial];events=[];prior=None
   for n in range(a.horizon):
    s=samples[-1]
    if not s['marioPresent']or s['held']!=23 or s['health']<256 or s['level']!=8 or s['area']!=1:break
    pad=dict(buttons=0,stick=[0,0])if mode=='pulse'and n%2 else steer(g,target,0)
    inputs.append(pad);advance(g,pad);s=sample(g,o,23);samples.append(s)
    s['floorNormal']=g.read('gMarioState.floor?.normal')
    key=(s['action'],s['held'])
    if key!=prior:events.append(dict(n=n+1,action=s['actionName'],M=s['M'],forward=s['forward']));prior=key
    if n%1000==0:print('pulse',target,mode,n,s['M'],s['actionName'],s['forward'],flush=True)
    if math.hypot(s['M'][0]-target[0],s['M'][2]-target[1])<30:break
   trials.append(dict(target=target,mode=mode,inputs=inputs,samples=samples,events=events,
    maximumHeldY=max(s['M'][1]for s in samples if s['held']==23)))
   print('end',target,mode,len(inputs),samples[-1]['M'],samples[-1]['actionName'],flush=True)
 result=dict(scope=__doc__,startupGrant='gDebugLevelSelect=1 only',gameplayWrites=[],AInputs=0,prefixInputs=prefix,initial=initial,trials=trials)
 with gzip.GzipFile(filename=str(a.output),mode='wb',mtime=0)as f:f.write((json.dumps(result,separators=(',',':'))+'\n').encode())
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('seed',type=Path);p.add_argument('output',type=Path);p.add_argument('--horizon',type=int,default=10000);run(p.parse_args())
