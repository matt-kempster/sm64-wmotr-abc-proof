"""Full native omission and actual-profile controls for the direct Bob success."""
import argparse,copy,gzip,json,math,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
import native as n
HERE=n.HERE;r=n.r
def menu(positive):
 out=[]
 for label,prof,omit in [('positive','released91',None),('no-bob','released91',39),('no-final-box','released91',49),('stock65-exact','stock65',None),('terminal117-exact','terminal117',None)]:
  q=copy.deepcopy(positive);q['profile']=prof;q['name']=label
  if omit:q['cuts']=[c for c in q['cuts']if c['slot']!=omit]
  out.append(q)
 for distance in [98,100,101]:
  q=copy.deepcopy(positive);q['profile']='stock65';q['name']='stock65-closer-'+str(distance)
  cut=q['cuts'][0];p=cut['pos'];x,z=q['seed']['xz'];dx,dz=p[0]-x,p[2]-z;d=math.hypot(dx,dz)
  cut['pos']=[r.f32(x+distance*dx/d),p[1],r.f32(z+distance*dz/d)];out.append(q)
 return out
def run(recipes):
 donors=n.profile.native_profiles();g,o,states,prep=r.roots();ps,ledgers=n.native_states(g,o,states,donors['profiles']);ps['stock65']=states;ledgers['stock65']=None;ts=[]
 for recipe in recipes:
  t=r.full(g,o,ps[recipe['profile']],recipe);t['profileInstall']=ledgers[recipe['profile']]
  captured=False;retained=True
  for s in t['samples']:
   if s['used']==64 and s['platform']==61:captured=True
   if captured and s['area']==1 and s['platform']!=61:retained=False
  t['retainedObserved']=retained;ts.append(t)
 return dict(preparation=prep,donors=donors,trials=ts)
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',type=Path);args=ap.parse_args()
 positive=json.loads(gzip.decompress((HERE/'native-results.json.gz').read_bytes()))['results']['trials'][0]['recipe'];recipes=menu(positive);a=run(recipes);b=run(recipes);assert a==b
 for t in a['trials']:
  print(t['recipe']['name'],'collision129',t['samples'][1]['collisions'],'after129',t['samples'][1]['M'],'after130',t['samples'][2]['M'],'cache130',t['samples'][2]['floorY'],'capture',t['capture'],'useful',t['useful'],'arrival',t['samples'][-1]['M'],flush=True)
 assert a['trials'][0]['capture']and a['trials'][0]['useful']and a['trials'][0]['retainedObserved']
 out=dict(schema=1,scope=__doc__,independentlyVerifiedFreshRoots=True,results=a)
 if args.verify:assert json.loads(gzip.decompress(args.verify.read_bytes()))==json.loads(json.dumps(out))
 else:
  p=HERE/'controls-results.json.gz';assert not p.exists();p.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
if __name__=='__main__':main()
