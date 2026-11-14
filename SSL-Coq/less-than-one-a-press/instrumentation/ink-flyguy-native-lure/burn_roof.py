"""Keep the controller-produced burning-roof state on real support if possible."""
import gzip,json,math,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(Path(__file__).resolve().parent))
from harness import root,advance,steer,sample,dump

def main():
 cap=Path(sys.argv[1]);out=Path(sys.argv[2]);data=json.load(gzip.open(ROOT/'build/flyguy-native-lure-v1.json.gz'))
 t=next(t for t in data['trials']if t['recipe']==dict(target=[-2100,-1700],delay=60,buttons=8192))
 inputs=data['prefixInputs']+t['inputs'][:277]
 g,o,rows=root(cap)
 for pad in inputs:advance(g,pad)
 initial=sample(g,o,len(inputs));assert initial==t['samples'][277]
 assert initial['M'][1]==1280 and initial['fly']['active']
 state=g.save_state();trials=[]
 for radius in [250,300,350]:
  for lead in [.4,.7,1.0]:
   for direction in [-1,1]:
    g.load_state(state);ss=[initial];controls=[]
    for n in range(400):
     s=ss[-1]
     if s['area']!=1 or s['level']!=8 or s['health']<256 or 'DEATH'in s['actionName']or g.read('gMarioState.area.camera').is_null():break
     x,y,z=s['M'];angle=math.atan2(x+2048,z+1024)+direction*lead
     target=[-2048+radius*math.sin(angle),-1024+radius*math.cos(angle)]
     p=steer(g,target,64);p['buttons']=0 if 'BURN'in s['actionName'] else 8192
     advance(g,p);controls.append(p);ss.append(sample(g,o,len(inputs)+n+1))
    live=[s for s in ss if s['fly']['active']and s['fly']['native']]
    nonburn=[s for s in ss[1:]if 'BURN'not in s['actionName']]
    r=dict(radius=radius,lead=lead,direction=direction)
    summary=dict(final=ss[-1],firstNonBurn=nonburn[0]if nonburn else None,
      maxMarioY=max(s['M'][1]for s in ss),maxFlyY=max(s['fly']['xyz'][1]for s in live),
      maxGroundY=max((s['M'][1]for s in ss if any(x in s['actionName']for x in ['CRAWL','SLIDE','WALK','IDLE'])),default=None))
    trials.append(dict(recipe=r,inputs=controls,samples=ss,summary=summary))
    print(r,'updates',len(controls),'maxMario',summary['maxMarioY'],'maxFly',summary['maxFlyY'],'ground',summary['maxGroundY'],'last',ss[-1]['actionName'],ss[-1]['M'],'flyactive',ss[-1]['fly']['active'],flush=True)
 dump(out,dict(scope=__doc__,prefixInputs=inputs,initial=initial,trials=trials))
if __name__=='__main__':main()
