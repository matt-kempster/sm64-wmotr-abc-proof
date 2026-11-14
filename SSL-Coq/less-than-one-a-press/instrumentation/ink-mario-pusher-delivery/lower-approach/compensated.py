"""At most three inverse corrections to the Bob's INITIAL X/Z only.

Lower Mario G activates the native Bob patrol one update earlier than the
high baseline. The measured after128 X/Z error chooses the next initial
placement. No actor move is applied after the initial airborne Mario cut.
"""
import copy,gzip,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
import check as c

def run():
 prior=json.loads(c.PRIOR.read_text());g,o,states,prep=c.h.roots();trials=[]
 target=[-2080.06005859375,1809.2066650390625,-1230.322021484375]
 position=[-2079.9365234375,target[1],-1233.3045654296875]
 for index in range(3):
  edited=copy.deepcopy(prior)
  cut=next(v for v in edited['preplacedCuts']if v['slot']==39)
  for e,value in zip(cut['edits'],position):e['after']=value
  recipe=dict(name='compensated1810-'+str(index),height=1810,
              xz=[-1962.4404296875,-1243.34130859375],speed=0,
              initialBobPosition=position,correctionTargetBobXZ=[target[0],target[2]])
  t=c.trial(g,o,states,prep,edited,recipe);trials.append(t)
  actual=t['samples'][0]['actors']['39']['position']
  print(recipe['name'],'useful',t['useful'],'initialBob',position,'actualBob128',actual,
        'after129',t['samples'][1]['M'],'after130',t['samples'][2]['M'],
        'cache130',t['diagnosticForks'][0]['result']['floorY'],
        'arrival',t['arrival']['M']if t['arrival']else None,flush=True)
  if t['useful']:break
  position=[c.r.f32(position[0]+target[0]-actual[0]),position[1],c.r.f32(position[2]+target[2]-actual[2])]
 return dict(preparation=prep,trials=trials)

def main():
 first=run();second=run();assert first==second
 result=dict(schema=1,scope=__doc__,runtimeSha256=c.h.sha(c.ROOT/'build/wafel-pilot/sm64_jp.dll'),
             priorCaseSha256=c.h.sha(c.PRIOR),independentFreshReconstructions=2,results=first)
 data=(json.dumps(result,separators=(',',':'))+'\n').encode();path=c.HERE/'compensated-results.json.gz'
 if '--verify'in sys.argv:assert json.loads(gzip.decompress(path.read_bytes()))==json.loads(data)
 else:assert not path.exists();path.write_bytes(gzip.compress(data,mtime=0))
 print('PASS',len(first['trials']),'histories,',sum(len(t['samples'])for t in first['trials']),'boundaries twice',flush=True)
if __name__=='__main__':main()
