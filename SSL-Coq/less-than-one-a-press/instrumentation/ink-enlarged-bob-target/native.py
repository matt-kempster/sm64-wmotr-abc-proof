"""Native validation of single enlarged-Bob129 / Crazy-Box130 proposals.

An exact native donor profile is conditionally transplanted before the one
supplied FREEFALL initializer. Later gameplay branches edit actor XYZ only.
An isolated, fully restored DISAPPEARED branch ranks the next geometry cache;
its changed action/M/G never enters a tested continuation. No delivery claim.
"""
import argparse,gzip,json,math,time,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
import geometry as geo
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1];r=geo.r
profile=geo.module('target_enlarged_profile','instrumentation/ink-enlarged-bob-profile/profile.py')
def shadow_cache(g,o):
 saved=g.save_state()
 try:
  g.g.write('gMarioState.action',g.constant('ACT_DISAPPEARED'));g.g.write('gMarioState.actionArg',0)
  s=r.advance(g,o);return dict(floorY=s['floorY'],floorOwner=s['floorOwner'],firstAction=r.action_pos(g),ceilHeight=g.read('gMarioState.ceilHeight'))
 finally:g.load_state(saved)
def key(q):return (tuple(q['seed']['xz']),q['seed']['speed'],q['actorRadius'])
def proposals(data,limit):
 groups={}
 for q in data['results']['candidates']:groups.setdefault(key(q),[]).append(q)
 out=[]
 for xs in groups.values():
  xs.sort(key=lambda q:math.hypot(q['target129'][0]+2140,q['target129'][2]+1115))
  out+=xs[:limit]
 return sorted(out,key=lambda q:(q['actorRadius'],math.hypot(q['target129'][0]+2140,q['target129'][2]+1115),math.hypot(q['seed']['xz'][0]+1920,q['seed']['xz'][1]+1210)))
def native_states(g,o,states,profiles):
 out={};ledgers={}
 for name,p in profiles.items():
  g.load_state(states[128]);ledgers[name]=profile.install_profile(g.g,o,p);out[name]={128:g.save_state()}
 return out,ledgers
def final_proposals(p,c):
 out=[None]
 targets=[(-2210,-1075),(-2220,-1075),(-2200,-1075),(-2190,-1075),(-2210,-1100),(-2210,-1040),(-2210,-1120),(-1882,-939),(-1890,-970),(-1882,-1075),(-1882,-1023)]
 for t in targets:
  a=geo.target_actor(p,c,t,75)
  if a:out.append(a)
 return out
def run(limit,stop):
 numeric=json.loads(gzip.decompress((HERE/'geometry-results.json.gz').read_bytes()));donors=profile.native_profiles()
 g,o,states,prep=r.roots();ps,ledgers=native_states(g,o,states,donors['profiles'])
 counts=dict(proposals=0,bobRegistered=0,fresh768=0,producerScreens=0,captures=0,useful=0);screens=[];final=[];selected=[];began=time.time()
 recipes=proposals(numeric,limit)
 for q in recipes:
  name='released91'if q['actorRadius']==91 else'terminal117';se=r.seed(g,o,ps[name],q['seed']);edits=r.place(g,39,q['actor129']);a=r.advance(g,o);events=r.iso.frame_events(g);cache=shadow_cache(g,o);state130=g.save_state()
  counts['proposals']+=1;counts['bobRegistered']+=39 in a['collisions'];counts['fresh768']+=cache['floorY']==768
  rr=dict(profile=name,seed=q['seed'],cuts=[dict(phase=129,slot=39,pos=q['actor129'])]);row=dict(recipe=rr,prediction=q,after129=a,firstAction129=r.action_pos(g),events129=events,bobAfter129=r.iso.actor_snapshot(g,39),shadow130=cache);screens.append(row)
  if cache['floorY']==768:
   for box in final_proposals(cache['firstAction'],a['C']):
    g.load_state(state130);cut=r.place(g,49,box)if box else[];p=r.advance(g,o);pe=r.iso.frame_events(g);accept=r.advance(g,o);capture=accept['used']==64 and accept['floorOwner']==accept['platform']==61
    recipe=dict(rr,cuts=rr['cuts']+([dict(phase=130,slot=49,pos=box)]if box else[]));counts['producerScreens']+=1;counts['captures']+=capture
    final.append(dict(recipe=recipe,producer=p,producerEvents=pe,accept=accept,capture=capture))
    if capture:
     t=r.full(g,o,ps[name],recipe);t['profileInstall']=ledgers[name];counts['useful']+=t['useful'];selected.append(t);print('CAPTURE',recipe,'useful',t['useful'],flush=True)
     if stop and t['useful']:break
  if counts['proposals']%100==0:print('PROGRESS',counts,'seconds',round(time.time()-began,1),flush=True)
  if stop and counts['useful']:break
 if not selected:
  near=sorted(screens,key=lambda s:(int(s['shadow130']['floorY']==768),-math.dist(s['after129']['M'],[-2140.031982421875,1830.177978515625,-1115.0291748046875])),reverse=True)[:4]
  for row in near:
   name=row['recipe']['profile'];t=r.full(g,o,ps[name],row['recipe']);t['profileInstall']=ledgers[name];selected.append(t)
 # Every selected actual history is regenerated in a fresh native runtime.
 vg,vo,vs,vprep=r.roots();assert prep==vprep;vps,vledgers=native_states(vg,vo,vs,donors['profiles']);assert ledgers==vledgers
 for t in selected:
  name=t['recipe']['profile'];v=r.full(vg,vo,vps[name],t['recipe']);v['profileInstall']=vledgers[name];assert t==v
 return dict(preparation=prep,donors=donors,profileInstalls=ledgers,menu=dict(perSeedRadiusLimit=limit,orderedProposals=len(recipes),stopAtFirstUseful=stop),counts=counts,screens=screens,producerScreens=final,trials=selected,independentlyVerifiedSelected=True,elapsed=time.time()-began)
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--limit',type=int,default=8);ap.add_argument('--continue-after-success',action='store_true');ap.add_argument('--output',type=Path,default=HERE/'native-results.json.gz');ap.add_argument('--verify',type=Path);a=ap.parse_args();out=dict(schema=1,scope=__doc__,runtimeSha256=r.sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),numericProposalSha256=r.sha(HERE/'geometry-results.json.gz'),results=run(a.limit,not a.continue_after_success))
 if a.verify:
  old=json.loads(gzip.decompress(a.verify.read_bytes()));old['results'].pop('elapsed');check=json.loads(json.dumps(out));check['results'].pop('elapsed');assert old==check
 else:
  assert not a.output.exists();a.output.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
 print('COUNTS',out['results']['counts'],flush=True)
if __name__=='__main__':main()
