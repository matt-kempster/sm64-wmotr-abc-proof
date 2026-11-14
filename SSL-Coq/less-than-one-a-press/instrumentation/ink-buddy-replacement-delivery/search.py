"""Controller-only delivery probes, with A released and no gameplay cuts."""
import argparse,gzip,hashlib,json,math,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from replay import create_game,Observer,load_capture
from ink_box_delivery import advance,steer,accepted_prefix
from ink_handsfree_teleport import actor

class Guard:
 def __init__(self,g):self.g=g
 def __getattr__(self,k):return getattr(self.g,k)
 def write(self,p,v):
  assert p in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},p
  if p.endswith('.button'):assert not v&0x8000
  self.g.write(p,v)

def sample(g,o,slot):
 present=o.slot(g.read('gMarioObject'))>=0
 return dict(timer=g.read('gGlobalTimer'),level=g.read('gCurrLevelNum'),area=g.read('gCurrAreaIndex'),
  marioPresent=present,M=g.read('gMarioState.pos'),C=[g.read('gMarioObject.oPos'+a)for a in 'XYZ']if present else None,D=g.read('gMarioObject.header.gfx.pos')if present else None,
  action=g.read('gMarioState.action'),actionName=g.mario_action_names().get(g.read('gMarioState.action')),
  actionState=g.read('gMarioState.actionState'),input=g.read('gMarioState.input'),
  held=o.slot(g.read('gMarioState.heldObj')),used=o.slot(g.read('gMarioState.usedObj')),
  floorY=g.read('gMarioState.floorHeight'),floorType=g.read('gMarioState.floor?.type'),
  floorOwner=o.slot(g.read('gMarioState.floor?.object')),platform=o.slot(g.read('gMarioPlatform')),
  forward=g.read('gMarioState.forwardVel'),health=g.read('gMarioState.health'),
  quicksand=g.read('gMarioState.quicksandDepth'),actor=actor(g,slot),
  topAction=g.read('gObjectPool[61].oAction'),topTimer=g.read('gObjectPool[61].oTimer'),pillars=g.read('gObjectPool[61].oPyramidTopPillarsTouched'))

def seed(capture,prefix):
 g=Guard(create_game());o=Observer(g);rows=load_capture(capture);assert prefix<=len(rows)
 accepted_prefix(g,o,rows,prefix)
 return g,o,[dict(buttons=p['buttons'],stick=p['stick'])for p in rows[:prefix]]

def acquire(g,o,slot,target,approach,threshold=110,horizon=700,divePeriod=0):
 inputs=[];samples=[sample(g,o,slot)];events=[];stage=0
 for n in range(horizon):
  s=samples[-1]
  if not s['marioPresent'] or s['area']!=1 or s['level']!=8 or s['health']<256:break
  if s['held']==slot:break
  p=s['M'];a=s['actor'];d=math.hypot(p[0]-a['xyz'][0],p[2]-a['xyz'][2])
  if stage<len(approach) and math.hypot(p[0]-approach[stage][0],p[2]-approach[stage][1])<80:stage+=1
  aim=approach[stage] if stage<len(approach) else (a['xyz'][0],a['xyz'][2])
  pad=steer(g,aim,0)
  if divePeriod and n%divePeriod==0:pad['buttons']=0x4000
  if stage==len(approach) and d<threshold:
   pad['stick']=[round(v*0.35)for v in pad['stick']]
   if n%12==0:pad['buttons']=0x4000
  inputs.append(pad);advance(g,pad);s=sample(g,o,slot);samples.append(s)
  if (s['action'],s['held'])!=(samples[-2]['action'],samples[-2]['held']):events.append(dict(n=n+1,sample=s))
 return dict(slot=slot,target=target,approach=approach,threshold=threshold,divePeriod=divePeriod,inputs=inputs,samples=samples,events=events,acquired=samples[-1]['held']==slot)

def carry(g,o,slot,route,horizon=1500):
 inputs=[];samples=[sample(g,o,slot)];events=[];stage=0
 for n in range(horizon):
  s=samples[-1];p=s['M']
  if not s['marioPresent'] or s['area']!=1 or s['level']!=8 or s['health']<256 or s['held']!=slot:break
  while stage<len(route)-1 and math.hypot(p[0]-route[stage][0],p[2]-route[stage][1])<100:stage+=1
  pad=steer(g,route[stage],0)
  inputs.append(pad);advance(g,pad);s=sample(g,o,slot);samples.append(s)
  if (s['action'],s['held'])!=(samples[-2]['action'],samples[-2]['held']):events.append(dict(n=n+1,sample=s))
  if math.hypot(s['M'][0]-route[-1][0],s['M'][2]-route[-1][1])<50:break
 return dict(route=route,inputs=inputs,samples=samples,events=events,finalStage=stage,
  maximumHeldY=max((s['M'][1]for s in samples if s['held']==slot),default=None),
  minimumPyramidDistance=min(math.hypot(s['M'][0]+2048,s['M'][2]+1024)for s in samples))

def run(args):
 trials=[]
 policies=[(500,[(4800,4200),(5300,4000)],110),(550,[(5300,4000)],160),
  (600,[(5300,4000)],110),(700,[(5300,3500)],110)]
 for prefix,approach,threshold in policies:
  g,o,inputs=seed(args.capture,prefix);t=acquire(g,o,23,[5900,3440],approach,threshold,divePeriod=24)
  t.update(prefixInputs=inputs,prefixLength=prefix);trials.append(t)
  print('acquire',prefix,approach,threshold,t['acquired'],t['samples'][-1]['M'],t['samples'][-1]['actionName'],flush=True)
  if not t['acquired']:continue
  state=g.save_state();carries=[]
  routes=[[(5000,3440),(3500,3500),(0,4000),(-2200,2000),(-2048,-1024)],
    [(5000,3440),(3500,4000),(0,6000),(-5000,3000),(-6500,0),(-6500,-4000),(-4000,-4500),(-2200,-3000),(-2048,-1024)],
    [(5000,3440),(3500,3500),(0,3500),(-2200,2000),(-2048,-1024)],
    [(5000,3440),(3500,3000),(2500,1700),(1000,500),(0,-1000),(-2048,-1024)]]
  for route in routes:
   g.load_state(state);c=carry(g,o,23,route);carries.append(c)
   print('carry',len(c['inputs']),c['maximumHeldY'],c['minimumPyramidDistance'],c['samples'][-1]['M'],c['samples'][-1]['actionName'],flush=True)
  t['carries']=carries
 result=dict(scope=__doc__,startupGrant='gDebugLevelSelect=1 only',gameplayWrites=[],AInputs=0,proofRevision='1222ab0ee82b870ba5efe1a8afd7f3ea7e78b1bf',trials=trials)
 with gzip.GzipFile(filename=str(args.output),mode='wb',mtime=0)as f:f.write((json.dumps(result,separators=(',',':'))+'\n').encode())
 print('saved',args.output,flush=True)

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('output',type=Path);a=p.parse_args();run(a)
