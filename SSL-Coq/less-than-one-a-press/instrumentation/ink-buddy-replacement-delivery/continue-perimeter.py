"""Continue actual far-south small-box carries with tested uphill pulsing."""
import gzip,json,math,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import Guard,create_game,Observer,sample,advance,steer
r=json.loads(gzip.decompress(Path('build/wafel-pilot/buddy-replacement-smallbox-perimeter-v1.json.gz').read_bytes()))
prefix=r['prefixInputs']+r['acquisition']['inputs']+r['trials'][0]['inputs']
g=Guard(create_game());o=Observer(g)
for p in prefix:advance(g,p)
assert sample(g,o,23)==r['trials'][0]['samples'][-1]
initial=sample(g,o,23);state=g.save_state();trials=[]
routes=[
 [[-6500,3500],[-6500,1500],[-5200,1000],[-4500,500],[-3500,500],[-2048,-1024]],
 [[-6500,6000],[-7000,3500],[-6500,1500],[-5200,1000],[-4500,500],[-3500,500],[-2048,-1024]],
 [[-6000,4500],[-5800,2200],[-5000,1000],[-4500,500],[-3500,500],[-2048,-1024]]]
for route in routes:
 for mode in ['continuous','pulse','slope-pulse']:
  g.load_state(state);inputs=[];samples=[initial];stage=0
  for n in range(10000):
   s=samples[-1]
   if not s['marioPresent']or s['held']!=23 or s['health']<256 or s['level']!=8 or s['area']!=1:break
   while stage<len(route)-1 and math.hypot(s['M'][0]-route[stage][0],s['M'][2]-route[stage][1])<100:stage+=1
   normal=g.read('gMarioState.floor?.normal');pulse=mode=='pulse'or(mode=='slope-pulse'and normal and normal['y']<0.9)
   pad=dict(buttons=0,stick=[0,0])if pulse and n%2 else steer(g,route[stage],0)
   inputs.append(pad);advance(g,pad);s=sample(g,o,23);s['floorNormal']=g.read('gMarioState.floor?.normal');samples.append(s)
   if n%2000==0:print('continue',routes.index(route),mode,n,stage,s['M'],s['actionName'],s['forward'],flush=True)
   if math.hypot(s['M'][0]-route[-1][0],s['M'][2]-route[-1][1])<40:break
  trials.append(dict(route=route,mode=mode,inputs=inputs,samples=samples,finalStage=stage,
   maximumHeldY=max(s['M'][1]for s in samples if s['held']==23)))
  print('end',routes.index(route),mode,len(inputs),stage,samples[-1]['M'],samples[-1]['actionName'],flush=True)
out=dict(scope=__doc__,startupGrant='gDebugLevelSelect=1 only',gameplayWrites=[],AInputs=0,prefixInputs=prefix,initial=initial,trials=trials)
with gzip.GzipFile(filename='build/wafel-pilot/buddy-replacement-smallbox-perimeter-pulse-v1.json.gz',mode='wb',mtime=0)as f:f.write((json.dumps(out,separators=(',',':'))+'\n').encode())
