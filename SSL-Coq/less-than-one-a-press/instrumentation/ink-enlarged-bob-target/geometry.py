"""Bounded source-numeric targeting for an enlarged native Bob-omb.

This does not create or enlarge an actor. It extracts native loaded surfaces
and action-entry positions after supplied high FREEFALL / native shell+Z.
Pure geometric push proposals are not gameplay witnesses. Native validation
must use an independently prepared Bob-omb with the stated actual radius.
"""
import argparse,gzip,importlib.util,json,math,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def module(name,path):
 s=importlib.util.spec_from_file_location(name,ROOT/path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
r=module('target_retime','instrumentation/ink-bobomb-retimed-shoves/search.py')
geom=module('target_floor_geometry','instrumentation/ink-floor768-diagnosis/geometry.py')
def target_actor(p,c,t,radius):
 push=radius+37-5;dx,dz=t[0]-p[0],t[1]-p[2];d=math.hypot(dx,dz)
 if not .01<d<push:return None
 a=[r.f32(t[0]-push*dx/d),c[1],r.f32(t[1]-push*dz/d)]
 return a if math.hypot(a[0]-c[0],a[2]-c[2])<radius+37-.01 else None
def menu():
 return [dict(phase=128,xz=[x,z],speed=s)for x in [-2000,-1980,-1960,-1940,-1920,-1900,-1880]for z in [-1250,-1230,-1210,-1190,-1170,-1150,-1130]for s in [0,20,40]]
def run():
 g,o,states,prep=r.roots();rows=[];candidates=[];began=time.time()
 targets=[(x,z)for x in range(-2147,-1946,10)for z in range(-1123,-922,10)]
 for idx,sr in enumerate(menu()):
  seed=r.seed(g,o,states,sr);s=seed['after'];row=dict(seed=sr,initialAfter=s)
  if s['actionName']!='ACT_BUTT_SLIDE' or not 1700<s['M'][1]<1950:rows.append(row);continue
  before129=g.save_state();after129=r.advance(g,o);p=r.action_pos(g);row.update(unopposedFirstAction129=p,unopposedAfter129=after129)
  # Both mesh lists are native snapshots. Probe results are Python evaluations
  # of the source predicates, with binary32 arithmetic and list order.
  surf129,addr129=geom.pool(g,o)
  q=geom.probe(g,surf129,addr129,'incoming129',p);row['incomingFloorProbe']=q
  incoming=q['selected']
  if incoming is None:rows.append(row);continue
  cache=incoming['height'];r.advance(g,o);surf130,addr130=geom.pool(g,o)
  feasible=[]
  for t in targets:
   q=geom.probe(g,surf130,addr130,'candidatePre130',[t[0],cache,t[1]])
   if q['selected'] is None or q['selected']['height']!=768:continue
   for radius in [91,117]:
    a=target_actor(p,s['C'],t,radius)
    if a:
     z=dict(seed=sr,actorRadius=radius,actor129=a,target129=[t[0],cache,t[1]],sourceIncoming=p,previousCollision=s['C'],distance=math.hypot(t[0]-p[0],t[1]-p[2]),targetFloor130=q['selected'])
     feasible.append(z);candidates.append(z)
  row['candidateCount']=len(feasible);row['closestCandidate']=min(feasible,key=lambda q:q['distance'])if feasible else None;rows.append(row)
  if idx%21==0:print('PROGRESS',idx,len(candidates),'seconds',round(time.time()-began,1),flush=True)
 return dict(preparation=prep,menu=menu(),rows=rows,candidates=candidates,counts=dict(seeds=len(rows),groundSeeds=sum('incomingFloorProbe'in x for x in rows),proposals=len(candidates)),elapsed=time.time()-began)
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--output',type=Path,default=HERE/'geometry-results.json.gz');ap.add_argument('--verify',type=Path);a=ap.parse_args();out=dict(schema=1,scope=__doc__,results=run())
 if a.verify:
  old=json.loads(gzip.decompress(a.verify.read_bytes()));old['results'].pop('elapsed');check=json.loads(json.dumps(out));check['results'].pop('elapsed');assert old==check
 else:
  assert not a.output.exists();a.output.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
 print('COUNTS',out['results']['counts'],flush=True)
 for rad in [91,117]:
  choices=[q for q in out['results']['candidates']if q['actorRadius']==rad]
  for q in sorted(choices,key=lambda q:q['distance'])[:5]:print('BEST',q,flush=True)
if __name__=='__main__':main()
