"""Finite controller-only lures from a reached roof ledge with Fly Guy alive.

The inherited prefix has already lost the top. This isolates real enemy luring,
not timer-compatible Ink entry. No gameplay state field is supplied.
"""
import gzip,hashlib,json,math,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(Path(__file__).resolve().parent))
from harness import root,advance,steer,sample,dump

def main():
 cap=Path(sys.argv[1]);out=Path(sys.argv[2]);g,o,rows=root(cap)
 controls=[dict(buttons=p['buttons'],stick=p['stick'])for p in rows[:2740]]
 for p in controls:advance(g,p)
 for i in range(70):
  p=steer(g,[-3400,-1120],64);p['buttons']=0;advance(g,p);controls.append(p)
 initial=sample(g,o,len(controls));assert initial['fly']['active'] and initial['fly']['native']
 assert initial['M']==[-2870.190185546875,1024.0,-963.3748168945312]
 state=g.save_state();trials=[]
 targets=[[-2870,-963],[-2800,-1500],[-2500,-1700],[-2100,-1700],[-2800,-500],[-2500,-350],[-2500,-1000],[-2800,-1000]]
 for target in targets:
  for delay in [0,60]:
   for button in [0,0x2000]:
    g.load_state(state);ss=[initial];inputs=[]
    for n in range(600):
     s=ss[-1]
     if s['area']!=1 or s['level']!=8 or s['health']<256 or 'DEATH'in s['actionName'] or not s['fly']['active'] or g.read('gMarioState.area.camera').is_null():break
     p=steer(g,target,64);p['buttons']=button
     if n<delay or math.hypot(s['M'][0]-target[0],s['M'][2]-target[1])<30:p['stick']=[0,0]
     advance(g,p);inputs.append(p);ss.append(sample(g,o,2811+n))
    live=[s for s in ss if s['fly']['active'] and s['fly']['native']]
    summary=dict(maxFlyY=max(s['fly']['xyz'][1]for s in live),maxFlyDisplacement=max(math.dist(s['fly']['xyz'],s['fly']['home'])for s in live),
      minInkDistance=min(math.dist(s['fly']['xyz'],[-1950,1741,-939])for s in live),
      maxMarioY=max(s['M'][1]for s in ss),contacts=sum(45 in s['collisions']for s in ss),
      special=sorted(set(s['actionName']for s in ss if 'BURN'in s['actionName']or'TWIRL'in s['actionName'])),
      final=ss[-1])
    r=dict(target=target,delay=delay,buttons=button);trials.append(dict(recipe=r,inputs=inputs,samples=ss,summary=summary))
    print(r,'updates',len(inputs),'fy',round(summary['maxFlyY'],3),'disp',round(summary['maxFlyDisplacement'],3),'near',round(summary['minInkDistance'],3),'special',summary['special'],'last',ss[-1]['actionName'],ss[-1]['M'],flush=True)
 dump(out,dict(scope=__doc__,prefixSha256=hashlib.sha256(cap.read_bytes()).hexdigest(),prefixInputs=controls,initial=initial,trials=trials))
if __name__=='__main__':main()
