"""Twelve focused corrected-X/Z lower-air controls; no later actor/Mario edits."""
import gzip,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
import check as c

def menu():
 # Prior low-air study's native first-step correction, translated to current X/Z.
 # Nearby offsets test contact sensitivity; all actor coordinates remain fixed.
 x,z=-1962.4404296875,-1243.34130859375
 return [dict(name='corrected-'+str(y)+'-'+str(dx)+'-'+str(dz),height=y,xz=[x+dx,z+dz],speed=0)
         for y,dx,dz in [(1768,0,0),(1810,0,0),(1830,0,0),(1900,0,0),
                        (1810,-2,0),(1810,2,0),(1810,0,-2),(1810,0,2),
                        (1810,-4,0),(1810,4,0),(1810,0,-4),(1810,0,4)]]

def run():
 prior=json.loads(c.PRIOR.read_text());g,o,states,prep=c.h.roots();trials=[]
 for recipe in menu():
  t=c.trial(g,o,states,prep,prior,recipe);trials.append(t)
  print(recipe['name'],'useful',t['useful'],'first',t['samples'][0]['M'],
        'second',t['samples'][1]['M'],'after130',t['samples'][2]['M'],
        'collision129',t['samples'][1]['collisions'],'arrival',t['arrival']['M']if t['arrival']else None,flush=True)
 return dict(preparation=prep,trials=trials)

def main():
 first=run();second=run();assert first==second
 result=dict(schema=1,scope=__doc__,runtimeSha256=c.h.sha(c.ROOT/'build/wafel-pilot/sm64_jp.dll'),
             priorCaseSha256=c.h.sha(c.PRIOR),independentFreshReconstructions=2,results=first)
 data=(json.dumps(result,separators=(',',':'))+'\n').encode();path=c.HERE/'corrected-results.json.gz'
 if '--verify'in sys.argv:assert json.loads(gzip.decompress(path.read_bytes()))==json.loads(data)
 else:assert not path.exists();path.write_bytes(gzip.compress(data,mtime=0))
 print('PASS',len(first['trials']),'histories,',sum(len(t['samples'])for t in first['trials']),'boundaries twice',flush=True)
if __name__=='__main__':main()
