"""Finite earlier carried approach menu, after the same native shell/Box releases."""
import argparse,gzip,importlib.util,itertools,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('carried_refine',HERE/'check.py');c=importlib.util.module_from_spec(s);s.loader.exec_module(c)
def menu():
 return [dict(boxY=by,marioY=my,phase=127,vy=-16,forced=False,dz=dz)
  for by,my,dz in itertools.product([1920,1940,1980,2010],[1855,1860,1865],[0,23,46])]
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args()
 g,o,st,fields,prep=c.root();trials=[c.trial(g,o,st,fields,x)for x in menu()]
 q,qo,qs,qf,qp=c.root();assert prep==qp
 for t in trials:assert t==c.trial(q,qo,qs,qf,t['recipe'])
 out=dict(schema=1,scope=__doc__,independentFreshReconstructions=2,allAReleased=True,preparation=prep,trials=trials)
 p=HERE/'refine-results.json.gz'
 if a.verify:assert json.loads(gzip.decompress(p.read_bytes()))==json.loads(json.dumps(out))
 else:p.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
 print('REFINE',len(trials),'useful',sum(t['useful']for t in trials),'captures',sum(t['capture']for t in trials),flush=True)
 for t in trials:
  if t['useful']:print(t['recipe'],flush=True)
if __name__=='__main__':main()
