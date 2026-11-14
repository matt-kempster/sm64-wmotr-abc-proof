"""Independent enlarged-Bob handoff reconstruction and cache diagnostic.

Profiles are explicit donor-field transplants before the initial FREEFALL cut,
not joined item delivery. Actual histories never edit Mario after that cut.
An isolated DISAPPEARED diagnostic fork ranks initial floor-cache candidates;
the whole original save state is restored before every ordinary-action trial.
"""
import hashlib, importlib.util
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[1]
def module(name,path):
 s=importlib.util.spec_from_file_location(name,ROOT/path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
r=module('enlarged_retime','instrumentation/ink-bobomb-retimed-shoves/search.py')
p=module('enlarged_profile','instrumentation/ink-enlarged-bob-profile/profile.py')
iso=r.iso
def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def shadow(g,o,state=None):
 """Heuristic isolated action substitution; its state never enters a route."""
 if state is not None:g.load_state(state)
 state=g.save_state();raw=g.g
 edits=[]
 for key,value in [('action',g.constant('ACT_DISAPPEARED')),('actionArg',0)]:
  path='gMarioState.'+key;edits.append(dict(path=path,before=g.read(path),after=value));raw.write(path,value)
 iso.advance(raw,iso.NEUTRAL)
 event=next(e for e in iso.frame_events(raw)if e['type']=='FLT_EXECUTE_ACTION')
 out=dict(queryCandidate=event['pos'],floorY=g.read('gMarioState.floorHeight'),floorOwner=o.slot(g.read('gMarioState.floor?.object')),ceilY=g.read('gMarioState.ceilHeight'),diagnosticEdits=edits)
 g.load_state(state)
 return out

def roots():
 g,o,states,prep=r.roots();donor=p.native_profiles();profileStates={};installs={}
 for name,profile in donor['profiles'].items():
  for phase in [126,127,128]:
   g.load_state(states[phase]);installs[name,phase]=p.install_profile(g.g,o,profile)
   profileStates[name,phase]=g.save_state()
 return g,o,profileStates,dict(receiverPreparation=prep,donor=donor,installs={name+':'+str(phase):entry for(name,phase),entry in installs.items()})

def seed(g,o,states,recipe,full=False):
 sr=recipe['seed'];return r.seed(g,o,{sr['phase']:states[recipe['profile'],sr['phase']]},sr,full)

def full(g,o,states,recipe):
 se=seed(g,o,states,recipe,True);rows=[se['after']];events=[se['events']];controls=[iso.Z];cuts=[];oracles=[]
 for _ in range(39):
  phase=g.read('gObjectPool[61].oTimer')
  if phase==130:oracles.append(dict(phase=phase,result=shadow(g,o)))
  edits=[]
  for cut in recipe['cuts']:
   if cut['phase']==phase and cut['pos']:edits.extend(r.place(g,cut['slot'],cut['pos']))
  if edits:cuts.append(dict(phase=phase,edits=edits))
  rows.append(r.advance(g,o,full=True));events.append(iso.frame_events(g));controls.append(iso.NEUTRAL)
  if rows[-1]['area']!=1:break
 capture=any(s['used']==64 and s['floorOwner']==s['platform']==61 for s in rows)
 arrival=next((s for s in rows if s['area']==2),None)
 useful=arrival is not None and arrival['M']==[365.5927734375,5500,-1096.8026123046875]
 return dict(recipe=recipe,seed=se,cuts=cuts,controls=controls,samples=rows,events=events,diagnosticForks=oracles,capture=capture,useful=useful)
