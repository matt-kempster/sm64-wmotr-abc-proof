"""Controller-only native western Fire Fly Guy manipulation, original JP runtime.

Only inherited debug level selection is supplied; all later writes are controller.
"""
import argparse,gzip,hashlib,json,math,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from replay import create_game,Observer,load_capture,set_input
from ink_crawl_predecessors import steer

class Guard:
 def __init__(self,g): self.g=g
 def __getattr__(self,k): return getattr(self.g,k)
 def write(self,p,v):
  assert p in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},p
  if p.endswith('button'): assert not v&0x8000
  self.g.write(p,v)

def advance(g,p):
 assert not p['buttons']&0x8000
 set_input(g,p);g.advance();assert not g.read('gMarioState.input')&0x82

def sample(g,o,n=0):
 read=g.read;present=o.slot(read('gMarioObject'))>=0
 p='gObjectPool[45].'
 actor=dict(xyz=[read(p+'oPos'+a) for a in 'XYZ'],home=[read(p+'oHome'+a)for a in 'XYZ'],
  native=read(p+'behavior')==g.address('bhvFlyGuy'),action=read(p+'oAction'),timer=read(p+'oTimer'),active=read(p+'activeFlags'),
  velocity=[read(p+'oVel'+a)for a in 'XYZ'],forward=read(p+'oForwardVel'),
  moveYaw=read(p+'oMoveAngleYaw'),faceYaw=read(p+'oFaceAngleYaw'),
  scale=read(p+'header.gfx.scale'),intangible=read(p+'oIntangibleTimer'),
  interact=read(p+'oInteractStatus'),height=read(p+'hitboxHeight'),radius=read(p+'hitboxRadius'),
  distance=read(p+'oDistanceToMario'),flags=read(p+'oMoveFlags'))
 return dict(n=n,timer=read('gGlobalTimer'),level=read('gCurrLevelNum'),area=read('gCurrAreaIndex'),
  M=read('gMarioState.pos'),C=[read('gMarioObject.oPos'+a)for a in 'XYZ']if present else None,
  D=read('gMarioObject.header.gfx.pos')if present else None,
  action=read('gMarioState.action'),actionName=g.mario_action_names().get(read('gMarioState.action')),
  state=read('gMarioState.actionState'),arg=read('gMarioState.actionArg'),input=read('gMarioState.input'),
  velocity=read('gMarioState.vel'),forward=read('gMarioState.forwardVel'),
  used=o.slot(read('gMarioState.usedObj')),held=o.slot(read('gMarioState.heldObj')),
  floorY=read('gMarioState.floorHeight'),floorType=read('gMarioState.floor?.type'),
  floorOwner=o.slot(read('gMarioState.floor?.object')),platform=o.slot(read('gMarioPlatform')),
  health=read('gMarioState.health'),quicksand=read('gMarioState.quicksandDepth'),
  topNative=read('gObjectPool[61].behavior')==g.address('bhvPyramidTop'),topActive=read('gObjectPool[61].activeFlags'),
  topAction=read('gObjectPool[61].oAction'),topTimer=read('gObjectPool[61].oTimer'),pillars=read('gObjectPool[61].oPyramidTopPillarsTouched'),
  collisions=[o.slot(read('gMarioObject.collidedObjs[%d]'%i))for i in range(read('gMarioObject.numCollidedObjs'))]if present else [],
  rng=read('gRandomSeed16'),fly=actor)

def root(capture):
 rows=load_capture(capture);g=Guard(create_game());o=Observer(g);return g,o,rows

def dump(path,data):
 assert not path.exists(),path
 path.parent.mkdir(parents=True,exist_ok=True)
 path.write_bytes(gzip.compress((json.dumps(data,separators=(',',':'))+'\n').encode(),mtime=0))

def record(name):
 path=HERE/'records'/name
 return path if path.exists() else ROOT/'build'/name

def inventory(capture,out):
 g,o,rows=root(capture);samples=[]
 for n,p in enumerate(rows):
  advance(g,p)
  if n>=348:samples.append(sample(g,o,n+1))
 closest=sorted(samples,key=lambda s:math.dist(s['M'],s['fly']['xyz']))[:20]
 print(json.dumps([dict(n=s['n'],M=s['M'],action=s['actionName'],fly=s['fly']['xyz'],fa=s['fly']['action'],pillars=s['pillars'],health=s['health'])for s in closest],indent=2))
 dump(out,dict(scope=__doc__,prefixSha256=hashlib.sha256(capture.read_bytes()).hexdigest(),inputs=[dict(buttons=p['buttons'],stick=p['stick'])for p in rows],samples=samples))

def summarize(t):
 ss=t['samples'];valid=[s for s in ss if s['area']==1 and s['level']==8 and s['fly']['native']]
 contacts=[s for s in valid if 45 in s['collisions']]
 special=[s for s in valid if s['actionName'] in ['ACT_TWIRLING','ACT_TWIRL_LAND','ACT_BURNING_JUMP','ACT_BURNING_FALL','ACT_BURNING_GROUND']]
 ground=[s for s in valid if 'SLIDE' in s['actionName'] or 'CRAWL' in s['actionName']]
 return dict(recipe=t['recipe'],updates=len(t['inputs']),contacts=len(contacts),special=len(special),
  minDistance=min((math.dist(s['M'],s['fly']['xyz'])for s in valid),default=None),
  maxMarioY=max((s['M'][1]for s in valid),default=None),maxFlyY=max((s['fly']['xyz'][1]for s in valid),default=None),
  maxFlyDisplacement=max((math.dist(s['fly']['xyz'],s['fly']['home'])for s in valid),default=None),
  maxSlideY=max((s['M'][1]for s in ground),default=None),
  firstSpecial=special[0]if special else None,last=ss[-1])

def approaches(capture,out):
 g,o,rows=root(capture);prefixes=[2300,2390,2400,2450,2500,2675,2710,2740];states={}
 for n,p in enumerate(rows[:max(prefixes)]):
  advance(g,p)
  if n+1 in prefixes:states[n+1]=g.save_state()
 targets=[[-3400,-1120],[-4000,-1120],[-3400,-2000],[-3000,-1500],[-3000,-500]]
 trials=[]
 for prefix in prefixes:
  for target in targets:
   for button in [0,0x2000]:
    g.load_state(states[prefix]);r=dict(prefix=prefix,target=target,buttons=button);ss=[sample(g,o,prefix)];inputs=[]
    for n in range(650):
     s=ss[-1]
     if s['area']!=1 or s['level']!=8 or s['health']<256 or 'DEATH' in s['actionName'] or g.read('gMarioState.area.camera').is_null():break
     pad=steer(g,target,64);pad['buttons']=button
     if math.hypot(s['M'][0]-target[0],s['M'][2]-target[1])<45:pad['stick']=[0,0]
     advance(g,pad);inputs.append(pad);ss.append(sample(g,o,prefix+n+1))
    t=dict(recipe=r,inputs=inputs,samples=ss);t['summary']=summarize(t);trials.append(t)
    q=t['summary'];print('TRIAL',r,'updates',q['updates'],'distance',q['minDistance'],'special',q['special'],'height',q['maxMarioY'],'fly',q['maxFlyY'],'last',q['last']['actionName'],flush=True)
 dump(out,dict(scope=__doc__,prefixSha256=hashlib.sha256(capture.read_bytes()).hexdigest(),prefixInputs=[dict(buttons=p['buttons'],stick=p['stick'])for p in rows[:max(prefixes)]],trials=trials))

def twirl_land(capture,out):
 data=json.load(gzip.open(record('flyguy-approaches-v1.json.gz')))
 parent=next(t for t in data['trials']if t['recipe']==dict(prefix=2740,target=[-3400,-1120],buttons=0))
 g,o,rows=root(capture)
 controls=[dict(buttons=p['buttons'],stick=p['stick'])for p in rows[:2740]]+parent['inputs'][:117]
 for pad in controls:advance(g,pad)
 assert sample(g,o,2857)==parent['samples'][117]
 state=g.save_state();trials=[]
 targets=[[-1950,-939],[-2048,-1024],[-2300,-1024],[-2500,-1000],[-2650,-1000],[-2400,-1500],[-2400,-500],[-2000,-1500]]
 for delay in [0,8,16,24,32]:
  for target in targets:
   g.load_state(state);ss=[sample(g,o,2857)];inputs=[]
   for n in range(240):
    s=ss[-1]
    if s['area']!=1 or s['level']!=8 or s['health']<256 or 'DEATH' in s['actionName'] or g.read('gMarioState.area.camera').is_null():break
    aim=[-3400,-1120]if n<delay else target
    pad=steer(g,aim,64);pad['buttons']=0x2000 if s['actionName'] in ['ACT_IDLE','ACT_WALKING','ACT_TWIRL_LAND']else 0
    if math.hypot(s['M'][0]-aim[0],s['M'][2]-aim[1])<45:pad['stick']=[0,0]
    advance(g,pad);inputs.append(pad);ss.append(sample(g,o,2858+n))
   t=dict(recipe=dict(prefix=2857,delay=delay,target=target),inputs=inputs,samples=ss);t['summary']=summarize(t);trials.append(t)
   q=t['summary'];print('TWIRL',delay,target,'slideY',q['maxSlideY'],'last',q['last']['actionName'],q['last']['M'],'area',q['last']['area'],flush=True)
 dump(out,dict(scope=__doc__,prefixInputs=controls,trials=trials))

def buddy_approach(capture,out):
 g,o,rows=root(capture)
 for p in rows:advance(g,p)
 state=g.save_state();initial=sample(g,o,len(rows));print('INITIAL',initial,flush=True)
 trials=[]
 for delay in [0,20,40,60,80,100,120]:
  for target in [[-3400,-1120],[-2900,-1000],[-2600,-1000],[-2300,-1000]]:
   g.load_state(state);ss=[initial];inputs=[]
   for n in range(700):
    s=ss[-1]
    if s['area']!=1 or s['level']!=8 or s['health']<256 or 'DEATH' in s['actionName'] or g.read('gMarioState.area.camera').is_null():break
    aim=[-2048,-1024]if n<delay else target
    pad=steer(g,aim,64);pad['buttons']=0
    if math.hypot(s['M'][0]-aim[0],s['M'][2]-aim[1])<45:pad['stick']=[0,0]
    advance(g,pad);inputs.append(pad);ss.append(sample(g,o,len(rows)+n+1))
   t=dict(recipe=dict(prefix=len(rows),delay=delay,target=target),inputs=inputs,samples=ss);t['summary']=summarize(t);trials.append(t)
   q=t['summary'];print('BUDDY',delay,target,'height',q['maxMarioY'],'flymove',q['maxFlyDisplacement'],'special',q['special'],'last',q['last']['actionName'],q['last']['M'],flush=True)
 dump(out,dict(scope=__doc__,prefixInputs=[dict(buttons=p['buttons'],stick=p['stick'])for p in rows],trials=trials))

def pre_fourth_land(capture,out):
 g,o,rows=root(capture)
 if record('flyguy-pre-fourth-land-v1.json.gz').exists():
  controls=json.load(gzip.open(record('flyguy-pre-fourth-land-v1.json.gz')))['prefixInputs']
 else:
  old=json.load(open(ROOT/'build/wafel-pilot/ink-box-delivery-20261111-final.json'))
  parent=next(t for t in old['trials']if t['policy']==dict(family='before-fourth',seed=2500,waypoint=[-5500,2300],destination='roof'))
  controls=[dict(buttons=p['buttons'],stick=p['stick'])for p in rows[:2500]]+parent['inputs'][:304]
 for pad in controls:advance(g,pad)
 assert g.read('gMarioState.action')==g.constant('ACT_TWIRLING')
 assert g.read('gObjectPool[61].oPyramidTopPillarsTouched')==3
 state=g.save_state();trials=[]
 targets=[[-1950,-939],[-2048,-1024],[-2300,-1024],[-2500,-1000],[-2650,-1000],[-2400,-1500],[-2400,-500],[-2000,-1500],[-5888,768]]
 for delay in [0,8,16,24,32]:
  for target in targets:
   for magnitude in [32,64]:
    g.load_state(state);ss=[sample(g,o,len(controls))];inputs=[]
    for n in range(220):
     s=ss[-1]
     if s['area']!=1 or s['level']!=8 or s['health']<256 or 'DEATH' in s['actionName'] or g.read('gMarioState.area.camera').is_null():break
     aim=[-2048,-1024]if n<delay else target
     pad=steer(g,aim,magnitude);pad['buttons']=0x2000 if s['actionName'] in ['ACT_IDLE','ACT_WALKING','ACT_TWIRL_LAND','ACT_CROUCHING','ACT_START_CRAWLING','ACT_CRAWLING','ACT_STOP_CRAWLING']else 0
     if math.hypot(s['M'][0]-aim[0],s['M'][2]-aim[1])<35:pad['stick']=[0,0]
     advance(g,pad);inputs.append(pad);ss.append(sample(g,o,len(controls)+n+1))
    t=dict(recipe=dict(prefix=len(controls),delay=delay,target=target,magnitude=magnitude),inputs=inputs,samples=ss);t['summary']=summarize(t);trials.append(t)
    q=t['summary'];print('PREFOUR',delay,target,magnitude,'groundY',q['maxSlideY'],'last',q['last']['actionName'],q['last']['M'],'pillars',q['last']['pillars'],'top',q['last']['topNative'],flush=True)
 dump(out,dict(scope=__doc__,creditedParent='docs/notes/ink-box-delivery.md before-fourth Fly Guy release',prefixInputs=controls,trials=trials))

def pre_fourth_brake(capture,out):
 old=json.load(gzip.open(record('flyguy-pre-fourth-land-v1.json.gz')));controls=old['prefixInputs']
 g,o,rows=root(capture)
 for pad in controls:advance(g,pad)
 state=g.save_state();trials=[]
 for divisor in [10,15,20,25]:
  for tx in [-2150,-2100,-2048,-2000,-1950]:
   for tz in [-1120,-1060,-1024,-980,-920]:
    g.load_state(state);ss=[sample(g,o,len(controls))];inputs=[];r=dict(divisor=divisor,target=[tx,tz])
    for n in range(150):
     s=ss[-1]
     if s['area']!=1 or s['level']!=8 or s['health']<256 or 'DEATH' in s['actionName'] or g.read('gMarioState.area.camera').is_null():break
     p=s['M'];distance=math.hypot(p[0]-tx,p[2]-tz)
     if s['actionName']=='ACT_TWIRLING':
      desired=min(32,distance/divisor);f=s['forward']
      if f>desired+0.6:
       angle=g.read('gMarioState.faceAngle[1]')*math.tau/65536
       aim=[p[0]-1000*math.sin(angle),p[2]-1000*math.cos(angle)]
       pad=steer(g,aim,64);pad['buttons']=0
      elif distance<12 and f<1:pad=dict(buttons=0,stick=[0,0])
      else:pad=steer(g,[tx,tz],64);pad['buttons']=0
     else:
      pad=steer(g,[tx,tz],64);pad['buttons']=0x2000
      if distance<35:pad['stick']=[0,0]
     advance(g,pad);inputs.append(pad);ss.append(sample(g,o,len(controls)+n+1))
    t=dict(recipe=r,inputs=inputs,samples=ss);t['summary']=summarize(t);trials.append(t)
    q=t['summary'];print('BRAKE',r,'groundY',q['maxSlideY'],'last',q['last']['actionName'],q['last']['M'],flush=True)
 dump(out,dict(scope=__doc__,creditedParent=old['creditedParent'],prefixInputs=controls,trials=trials))

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('out',type=Path);p.add_argument('--mode',default='inventory');a=p.parse_args();globals()[a.mode](a.capture,a.out)
