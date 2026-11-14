"""Finite high item nudges: airborne construction, staged timing, explicit controls.

High initial coordinates and actor XYZ are supplied. Native callbacks remain live.
The riding control obtains a native low mount then grants a high XYZ relocation;
the ground control explicitly grants BUTT_SLIDE. Neither is a high-entry route.
"""
import gzip,hashlib,itertools,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
sys.path.insert(0,str(ROOT/'instrumentation/ink-high-action-entry'))
from prelude import roots as oldroots,advance,NEUTRAL,pose,write,rich_sample,frame_events
sys.path.insert(0,str(ROOT/'instrumentation/ink-item-clone-controls'))
from fixtures import actor_snapshot
Z=dict(buttons=0x2000,stick=[0,0])
GRABS=['crazy','small','bobomb'];SLOTS={'crazy':49,'small':23,'bobomb':39}
OFF={'crazy':39,'small':24,'bobomb':29,'shell':21}

class Guard:
 def __init__(self,g,slot):self.g=g;self.slot=slot;self.mode='controls'
 def __getattr__(self,k):return getattr(self.g,k)
 def write(self,p,v):
  allowed={'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'}
  if self.mode in ['setup','actor','relocate']:
   if self.mode in ['setup','actor']:allowed|={f'gObjectPool[{s}].oPos'+a for s in [49,23,39,self.slot]for a in 'XYZ'}
   if self.mode in ['setup','relocate']:allowed|={'gMarioState.pos','gMarioObject.header.gfx.pos'}|{'gMarioObject.oPos'+a for a in 'XYZ'}
   if self.mode=='setup':allowed|={'gMarioState.'+k for k in ['action','actionState','actionTimer','forwardVel','vel','faceAngle','slideVelX','slideVelZ','slideYaw']}
  assert p in allowed,p
  self.g.write(p,v)

def roots():
 raw=gzip.decompress((HERE/'prefix.jsonl.gz').read_bytes());assert hashlib.sha256(raw).hexdigest()=='9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72'
 p=ROOT/'build/high-item-nudge-prefix.jsonl'
 if p.exists():assert p.read_bytes()==raw
 else:p.write_bytes(raw)
 g,o,states,slot,prep=oldroots(p)
 g.load_state(states[129]);advance(g,NEUTRAL);states[130]=g.save_state()
 return Guard(g.g,slot),o,states,slot,prep

def snap(g,o):
 if g.read('gMarioObject').is_null():return dict(marioPresent=False,area=g.read('gCurrAreaIndex'),movement=g.read('gMarioState.pos'),actionName=g.mario_action_names().get(g.read('gMarioState.action')),floorY=g.read('gMarioState.floorHeight'),floorOwner=-1,platform=-1,used=-1,topNative=False)
 s=rich_sample(g,o);s['marioPresent']=True;s['topNative']=g.read('gObjectPool[61].behavior')==g.address('bhvPyramidTop')
 s['collisions']=[o.slot(g.read(f'gMarioObject.collidedObjs[{i}]'))for i in range(g.read('gMarioObject.numCollidedObjs'))]
 s['ridden']=o.slot(g.read('gMarioState.riddenObj'))
 s['actors']={n:actor_snapshot(g,SLOTS[n]if n!='shell'else g.slot)for n in GRABS+['shell']}
 return s

def air(g,xyz,ledger,action='ACT_FREEFALL'):
 g.mode='setup';pose(g,xyz,ledger)
 for k,v in [('action',g.constant(action)),('actionState',0),('actionTimer',0),('forwardVel',20),('vel',[20,-16,0]),('faceAngle',[0,16384,0])]:write(g,'gMarioState.'+k,v,ledger)
 if action=='ACT_BUTT_SLIDE':
  for k,v in [('slideVelX',20),('slideVelZ',0),('slideYaw',16384)]:write(g,'gMarioState.'+k,v,ledger)
 g.mode='controls'

def place(g,n,xyz,ledger):
 slot=SLOTS[n]if n!='shell'else g.slot;g.mode='actor'
 for a,v in zip('XYZ',xyz):write(g,f'gObjectPool[{slot}].oPos'+a,v,ledger)
 g.mode='controls'

def cut(g,desc,ledger):
 p=g.read('gMarioState.pos')
 if desc=='mount':place(g,'shell',[p[0],p[1]-10,p[2]],ledger);return
 names=desc.split('+')
 for i,n in enumerate(names):
  xyz=[p[0]-OFF[n],p[1],p[2]]
  if len(names)>1 and i==1:xyz=[p[0],p[1],p[2]-OFF[n]]
  if len(names)>2 and i==2:xyz=[p[0]+OFF[n],p[1],p[2]]
  place(g,n,xyz,ledger)

def trial(g,o,states,r):
 g.load_state(states[r.get('basePhase',128)]);initial=snap(g,o);edits=[];preparation=[];H=r['height']
 if r['family']=='relocated-rider':
  # One fixed actual floor contact, not a low-coordinate search.
  p=g.read('gMarioState.pos');p[1]=g.read('gMarioState.floorHeight')+10
  air(g,p,edits);cut(g,'mount',edits);advance(g,NEUTRAL);preparation.append(dict(control=NEUTRAL,sample=snap(g,o),events=frame_events(g)))
  assert g.read('gMarioState.action')==g.constant('ACT_RIDING_SHELL_GROUND'),preparation[-1]['sample']['actionName']
  g.mode='relocate';pose(g,[-1950,H,-939],edits);g.mode='controls'
 else:
  if r['family']=='supplied-slide':
   g.load_state(states[r.get('basePhase',129)]);initial=snap(g,o)
  air(g,[-1950,H,-939],edits,'ACT_BUTT_SLIDE'if r['family']=='supplied-slide'else'ACT_FREEFALL')
 before=snap(g,o);rows=[];events=[];controls=[];cuts=[]
 for i in range(45):
  if i<len(r['steps']):
   desc=r['steps'][i];ledger=[];pre=snap(g,o);cut(g,desc,ledger);cuts.append(dict(update=i+1,description=desc,before=pre,edits=ledger))
  pad=Z if i in r['z']else NEUTRAL
  advance(g,pad);s=snap(g,o);rows.append(s);events.append(frame_events(g));controls.append(pad)
  if not s['marioPresent']or s['area']!=1:break
 arrival=next((s for s in rows if s['area']==2),None)
 return dict(recipe=r,initial=initial,edits=edits,preparation=preparation,before=before,cuts=cuts,samples=rows,events=events,controls=controls,capture=any(s['topNative']and s['used']==64 and s['floorOwner']==s['platform']==61 for s in rows),useful=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717))

def recipes():
 out=[]
 for h in [25000,67277]:
  for seq in [[n]for n in GRABS+['shell']]+[list(x)for x in itertools.permutations(GRABS,2)]+[GRABS,list(reversed(GRABS))]:
   out.append(dict(family='air-nudges',height=h,steps=seq,z=[]))
  for n in GRABS:
   for steps,z in [([n,'mount'],[1]),(['mount',n],[0]),(['shell+'+n,'mount'],[1])]:out.append(dict(family='staged-mount',height=h,steps=steps,z=z))
   out.append(dict(family='relocated-rider',height=h,steps=[n],z=[0]))
  for desc in GRABS+['shell']+['shell+'+n for n in GRABS]:out.append(dict(family='supplied-slide',height=h,steps=[desc],z=[]))
  for n in GRABS:out.append(dict(family='relocated-rider',height=h,steps=[n],z=[0],basePhase=129,timingControl=True))
  for n in GRABS+['shell']:out.append(dict(family='supplied-slide',height=h,steps=[n],z=[],basePhase=130,timingControl=True))
 for n in GRABS:
  out.append(dict(family='staged-mount',height=90536,steps=[n,'mount'],z=[1],basePhase=129,vpuInteriorControl=True))
  out.append(dict(family='staged-mount',height=90536,steps=['mount',n],z=[0],basePhase=130,vpuInteriorControl=True))
 return out

def main():
 g,o,s,slot,prep=roots();q,qo,qs,qslot,qprep=roots();assert prep==qprep
 trials=[]
 for r in recipes():
  t=trial(g,o,s,r);assert t==trial(q,qo,qs,r);trials.append(t)
  print(r,'first',t['samples'][0]['actionName'],t['samples'][0]['movement'],'capture',t['capture'],'useful',t['useful'],flush=True)
 result=dict(scope=__doc__,proofRevision='3772fb57701ad0074c9a2016c366bed7e7e3ea24',preparation=prep,trials=trials,matchedBoundaries=sum(1+len(t['samples'])+len(t['preparation'])for t in trials))
 path=HERE/'results.json.gz'
 if path.exists():assert json.load(gzip.open(path))==result
 else:path.write_bytes(gzip.compress((json.dumps(result,separators=(',',':'))+'\n').encode(),mtime=0))
 print('PASS',len(trials),result['matchedBoundaries'],flush=True)

if __name__=='__main__':main()
