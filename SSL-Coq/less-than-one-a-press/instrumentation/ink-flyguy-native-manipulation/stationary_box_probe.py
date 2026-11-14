"""Conditional actor-only placement after a real pre-fourth high slide.

Mario, floor, top, action and phase receive no edits. Native small box23 XYZ is
supplied once per diagnostic trial; this is not actor delivery or a full route.
"""
import gzip,math,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE))
from search import ROOT,Guard,create_game,Observer,advance,sample,dump,record

def run():
 data=json.load(gzip.open(record('flyguy-pre-fourth-brake-v1.json.gz')))
 parent=next(t for t in data['trials']if t['recipe']==dict(divisor=15,target=[-2150,-920]))
 prefix=data['prefixInputs']+parent['inputs'][:62]
 g=Guard(create_game());o=Observer(g)
 for p in prefix:advance(g,p)
 before=sample(g,o,len(prefix));assert before['actionName']=='ACT_IDLE'
 assert g.read('gObjectPool[23].behavior')==g.address('bhvBreakableBoxSmall')
 states={62:g.save_state()};befores={62:before}
 for cut in [63,64,65]:
  advance(g,parent['inputs'][cut-1]);states[cut]=g.save_state();befores[cut]=sample(g,o,len(data['prefixInputs'])+cut)
 trials=[]
 for cut in [62,63,64,65]:
  before=befores[cut]
  for dy in [-100,0,100]:
   for radius in [0,20,40,60,80]:
    for yaw in ([0]if radius==0 else range(0,65536,4096)):
     g.load_state(states[cut]);p=before['M'];a=yaw*math.tau/65536
     xyz=[p[0]+radius*math.sin(a),p[1]+dy,p[2]+radius*math.cos(a)];ledger=[]
     for axis,v in zip('XYZ',xyz):
      path='gObjectPool[23].oPos'+axis;ledger.append(dict(path=path,before=g.read(path),after=v));g.g.write(path,v)
     ss=[sample(g,o,len(data['prefixInputs'])+cut)];inputs=[]
     for n in range(45):
      s=ss[-1]
      if s['area']!=1 or s['level']!=8 or s['health']<256 or 'DEATH' in s['actionName']:break
      pad=parent['inputs'][cut+n];advance(g,pad);inputs.append(pad);ss.append(sample(g,o,len(data['prefixInputs'])+cut+n+1))
     low=any(s['M'][1]==768 and s['floorY']==768 for s in ss)
     capture=any(s['used']==64 and s['platform']==61 and s['topNative']and s['floorOwner']==61 for s in ss)
     trials.append(dict(recipe=dict(cut=cut,dy=dy,radius=radius,yaw=yaw),edits=ledger,inputs=inputs,samples=ss,freshLow=low,capture=capture))
 print('STATIONARY BOX',len(trials),'trials',sum(t['freshLow']for t in trials),'freshLow',sum(t['capture']for t in trials),'capture')
 dump(ROOT/'build/flyguy-stationary-box-v2.json.gz',dict(scope=__doc__,prefixInputs=data['prefixInputs'],parentInputs=parent['inputs'],befores=befores,trials=trials))

if __name__=='__main__':run()
