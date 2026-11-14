"""Attempt the flame/lure route before the fourth pillar, retaining a living Fly Guy."""
import gzip,json,math,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(Path(__file__).resolve().parent))
from harness import Guard,create_game,Observer,advance,steer,sample,dump

def main():
 source=Path(sys.argv[1]);out=Path(sys.argv[2]);data=json.load(gzip.open(source));prefix=data['prefixInputs']
 g=Guard(create_game());o=Observer(g);early='--early'in sys.argv;cuts=[2700,2720,2740,2760]if early else[2780,2790,2795,2800];states={}
 for i,p in enumerate(prefix[:max(cuts)]):
  advance(g,p)
  if i+1 in cuts:states[i+1]=g.save_state()
 trials=[]
 for cut in cuts:
  for target in ([[-2400,-600],[-2400,-1000],[-2400,-1400],[-2800,-800],[-2800,-1200],[-3000,-1800]]if early else[[-2800,-500],[-2800,-963],[-2900,-1500],[-2700,-1300],[-2870,-963],[-2800,-1800]]):
   for wait in [0,60]:
    g.load_state(states[cut]);ss=[sample(g,o,cut)];inputs=[];landed=None
    for n in range(700):
     s=ss[-1]
     if s['area']!=1 or s['level']!=8 or s['health']<256 or 'DEATH'in s['actionName']or not s['fly']['active']or g.read('gMarioState.area.camera').is_null():break
     if landed is None and s['held']==-1 and s['M'][1]>=1000 and s['M'][1]==s['floorY']and not any(x in s['actionName']for x in ['BOUNCE','TWIRL','FREEFALL','JUMP']):landed=n
     aim=target;button=0
     if landed is not None:
      aim=[-2100,-1700];button=8192
      if s['M'][1]>=1280 and s['floorY']>=1280:
       angle=math.atan2(s['M'][0]+2048,s['M'][2]+1024)+.4
       aim=[-2048+350*math.sin(angle),-1024+350*math.cos(angle)]
       button=0 if 'BURN'in s['actionName'] else 8192
     p=steer(g,aim,64);p['buttons']=button
     if landed is not None and n-landed<wait:p=dict(buttons=0,stick=[0,0])
     advance(g,p);inputs.append(p);ss.append(sample(g,o,cut+n+1))
    live=[s for s in ss if s['fly']['native']and s['fly']['active']]
    summary=dict(final=ss[-1],maxMarioY=max(s['M'][1]for s in ss),maxFlyY=max(s['fly']['xyz'][1]for s in live),
     flame=any('BURN'in s['actionName']for s in ss),livingRoof=any(s['M'][1]>=1280 and s['M'][1]==s['floorY']and s['fly']['active']for s in ss),landedAt=landed)
    recipe=dict(cut=cut,target=target,wait=wait);trials.append(dict(recipe=recipe,inputs=inputs,samples=ss,summary=summary))
    print(recipe,'updates',len(inputs),'maxM',summary['maxMarioY'],'maxF',summary['maxFlyY'],'flame',summary['flame'],'roof',summary['livingRoof'],'last',ss[-1]['actionName'],ss[-1]['M'],'fly',ss[-1]['fly']['active'],flush=True)
 dump(out,dict(scope=__doc__,source=str(source),prefixInputs=prefix[:max(cuts)],trials=trials))
if __name__=='__main__':main()
