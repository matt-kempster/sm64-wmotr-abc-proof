"""Native donor reproduction and finite common-root lifetime diagnostics."""
import argparse,gzip,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def module(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
p=module('enlarged_profile',HERE/'profile.py')
r=module('enlarged_retime',ROOT/'instrumentation/ink-bobomb-retimed-shoves/search.py')
def sample(g,o):
 s=r.snapshot(g,o,True);s['Bob39']=p.detailed(g,o)['profile'];s['Bob39Active']=g.read('gObjectPool[39].activeFlags');s['Bob39Command']=p.command_index(g,39)
 return s
def case(g,o,states,profile,phase):
 g.load_state(states[phase]);grant=p.install_profile(g.g,o,profile)if profile else None
 state=g.save_state();seed=r.seed(g,o,{phase:state},dict(phase=phase,xz=[-1920,-1170],speed=20),True)
 t=dict(profile=profile['name']if profile else'stock65',phase=phase,profileGrant=grant,seed=seed,samples=[sample(g,o)],controls=[r.iso.Z],events=[r.iso.frame_events(g)],cuts=[])
 c=t['samples'][0]['C'];t['cuts']=r.place(g,39,[c[0]-60,c[1],c[2]])
 for n in range(9):
  r.advance(g,o);s=sample(g,o);t['samples'].append(s);t['controls'].append(r.iso.NEUTRAL);t['events'].append(r.iso.frame_events(g))
  if not s['Bob39Active']:break
 t['registeredAtFirstContact']=39 in t['samples'][1]['collisions']
 assert t['registeredAtFirstContact']
 assert t['samples'][0]['Bob39']['hitboxRadius']==(profile['fields']['hitboxRadius']if profile else 65)
 if profile:
  assert t['samples'][0]['Bob39']['oBobombFuseTimer']==profile['fields']['oBobombFuseTimer'],'far native range guard should pause fuse'
  assert t['samples'][1]['Bob39']['oBobombFuseTimer']==profile['fields']['oBobombFuseTimer']+1,'near native callback must resume fuse'
  assert not t['samples'][-1]['Bob39Active'],'expired actor must not be silently preserved'
 return t
def run():
 donors=p.native_profiles();g,o,states,prep=r.roots()
 cases=[case(g,o,states,profile,phase)for phase in [126,127]for profile in [None,donors['profiles']['released91'],donors['profiles']['terminal117']]]
 return dict(donor=donors,commonRootPreparation=prep,cases=cases)
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',type=Path);a=ap.parse_args()
 data=run();fresh=run();assert data==fresh
 result=dict(schema=1,scope=__doc__,runtimeSha256=p.sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),donorScriptSha256=p.sha(HERE/'profile.py'),independentlyVerified=True,results=data)
 if a.verify:assert json.loads(gzip.decompress(a.verify.read_bytes()))==json.loads(json.dumps(result))
 else:
  target=HERE/'results.json.gz';assert not target.exists();target.write_bytes(gzip.compress((json.dumps(result,separators=(',',':'))+'\n').encode(),mtime=0))
 for t in data['cases']:
  print(t['profile'],'initialPhase',t['phase'],'registered',t['registeredAtFirstContact'],flush=True)
  for s in t['samples']:
   b=s['Bob39'];print(' phase',s['topPhase'],'radius',b['hitboxRadius'],'fuse',b['oBobombFuseTimer'],'action',b['oAction'],'timer',b['oTimer'],'active',s['Bob39Active'],'Mario',s['actionName'],flush=True)
 print('PASS clean donor and six two-fresh-root lifetime histories',flush=True)
if __name__=='__main__':main()
