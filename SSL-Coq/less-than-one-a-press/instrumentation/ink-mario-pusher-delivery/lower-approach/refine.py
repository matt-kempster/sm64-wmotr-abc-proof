"""Nine explicitly bounded lower-air initial-X/Z refinements, fixed actors."""
import gzip,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
import check as c

def run():
 prior=json.loads(c.PRIOR.read_text());g,o,states,prep=c.h.roots();trials=[]
 for dx in [0.5,1,1.5]:
  for dz in [-0.5,0,0.5]:
   recipe=dict(name='refine1810-'+str(dx)+'-'+str(dz),height=1810,
               xz=[-1962.4404296875+dx,-1243.34130859375+dz],speed=0)
   t=c.trial(g,o,states,prep,prior,recipe);trials.append(t)
   print(recipe['name'],'useful',t['useful'],'after129',t['samples'][1]['M'],
         'after130',t['samples'][2]['M'],'cache130',t['diagnosticForks'][0]['result']['floorY'],
         'arrival',t['arrival']['M']if t['arrival']else None,flush=True)
 return dict(preparation=prep,trials=trials)

def main():
 first=run();second=run();assert first==second
 result=dict(schema=1,scope=__doc__,runtimeSha256=c.h.sha(c.ROOT/'build/wafel-pilot/sm64_jp.dll'),
             priorCaseSha256=c.h.sha(c.PRIOR),independentFreshReconstructions=2,results=first)
 data=(json.dumps(result,separators=(',',':'))+'\n').encode();path=c.HERE/'refine-results.json.gz'
 if '--verify'in sys.argv:assert json.loads(gzip.decompress(path.read_bytes()))==json.loads(data)
 else:assert not path.exists();path.write_bytes(gzip.compress(data,mtime=0))
 print('PASS',len(first['trials']),'histories,',sum(len(t['samples'])for t in first['trials']),'boundaries twice',flush=True)
if __name__=='__main__':main()
