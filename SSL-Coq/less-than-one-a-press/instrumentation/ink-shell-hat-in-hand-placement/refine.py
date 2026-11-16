"""Bounded initial airborne X/Z correction for Hat-in-Hand actual Box throws."""
import argparse,gzip,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
sp=importlib.util.spec_from_file_location('hat_refine_base',HERE/'search.py');b=importlib.util.module_from_spec(sp);sp.loader.exec_module(b)
def menu():return [dict(phase=124,y=y,vy=-16,aim='flight',dx=dx,dz=dz)for dx in[-12,-8,-4,0,4,8,12]for dz in[0,4,8,12,16]for y in[1930,1940,1950]]
def main():
 p=argparse.ArgumentParser();p.add_argument('--verify',action='store_true');a=p.parse_args()
 g,o,states,profile,prep=b.root();trials=[]
 for i,q in enumerate(menu()):
  t=b.trial(g,o,states,profile,q);trials.append(t)
  if t['useful']:print('USEFUL',q,flush=True)
  if i%30==0:print('refined',i+1,flush=True)
 g2,o2,s2,p2,prep2=b.root();assert prep==prep2
 for t in trials:assert t==b.trial(g2,o2,s2,p2,t['recipe'])
 out=dict(schema=1,scope=__doc__,independentFreshRoots=2,allAReleased=True,preparation=prep,trials=trials)
 dst=HERE/'refine-results.json.gz'
 if a.verify:assert json.loads(gzip.decompress(dst.read_bytes()))==out
 else:assert not dst.exists();dst.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
 print('RESULT',len(trials),'useful',sum(t['useful']for t in trials),'capture',sum(t['capture']for t in trials),'boundaries',sum(len(t['samples'])for t in trials),flush=True)
 ranked=sorted(trials,key=lambda t:(int(t['useful']),int(any(s['floorY']==768 and s['G'][1]>1700 for s in t['samples'])),int(t['samples'][4]['platform']==-1),-abs(t['samples'][4]['M'][0]+1960)-abs(t['samples'][4]['M'][2]+1230)),reverse=True)
 for t in ranked[:8]:
  print('BEST',t['recipe'],'capture',t['capture'],flush=True)
  for i,x in enumerate(t['samples'][4:8]):print(128+i,x['M'],x['actionName'],'platform',x['platform'],'floor',x['floorY'],'Box',x['actors']['49']['position'],x['actors']['49']['activeFlags'],'collisions',x['collisions'],flush=True)
if __name__=='__main__':main()
