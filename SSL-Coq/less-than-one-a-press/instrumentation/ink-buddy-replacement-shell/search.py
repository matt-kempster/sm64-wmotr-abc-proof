"""Controller-only native SSL shell acquisition/delivery search (JP).

The only startup grant is create_game's inherited debug level selection.
No gameplay position/action/object/pointer writes are permitted.
"""
import argparse,hashlib,json,math,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from replay import create_game,Observer,load_capture,set_input
from ink_crawl_predecessors import steer

class Guard:
 def __init__(self,g):self.g=g
 def __getattr__(self,n):return getattr(self.g,n)
 def write(self,p,v):
  assert p in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},p
  if p.endswith('button'):assert not v&0x8000
  self.g.write(p,v)

def advance(g,p):
 assert not p['buttons']&0x8000
 set_input(g,p);g.advance();assert not g.read('gMarioState.input')&0x82

def sample(g,o,poll):
 return dict(poll=poll,timer=g.read('gGlobalTimer'),level=g.read('gCurrLevelNum'),area=g.read('gCurrAreaIndex'),
  pos=g.read('gMarioState.pos'),vel=g.read('gMarioState.vel'),action=g.read('gMarioState.action'),
  actionName=g.mario_action_names().get(g.read('gMarioState.action')),forward=g.read('gMarioState.forwardVel'),
  used=o.slot(g.read('gMarioState.usedObj')),held=o.slot(g.read('gMarioState.heldObj')),ridden=o.slot(g.read('gMarioState.riddenObj')),
  health=g.read('gMarioState.health'),floor=g.read('gMarioState.floorHeight'),input=g.read('gMarioState.input'),
  box=[g.read('gObjectPool[32].oPos'+a)for a in 'XYZ'],boxAction=g.read('gObjectPool[32].oAction'),
  topAction=g.read('gObjectPool[61].oAction'),topTimer=g.read('gObjectPool[61].oTimer'),pillars=g.read('gObjectPool[61].oPyramidTopPillarsTouched'))

def shells(g):
 out=[]
 for slot in range(240):
  p='gObjectPool[%d].'%slot
  if g.read(p+'activeFlags') and g.read(p+'behavior')==g.address('bhvKoopaShell'):
   out.append(dict(slot=slot,pos=[g.read(p+'oPos'+a)for a in 'XYZ'],action=g.read(p+'oAction'),
     status=g.read(p+'oInteractStatus'),active=g.read(p+'activeFlags')))
 return out

def inventory(capture,out):
 rows=load_capture(capture);g=Guard(create_game());o=Observer(g);states=[]
 for i,p in enumerate(rows):
  advance(g,p)
  if i>=348:
   s=sample(g,o,i+1);s['distance']=math.dist(s['pos'],s['box']);states.append(s)
 result=dict(prefixLength=len(rows),prefixSha256=hashlib.sha256(capture.read_bytes()).hexdigest(),
  nearest=sorted(states,key=lambda s:s['distance'])[:30],states=states,shells=shells(g))
 out.write_bytes((json.dumps(result,indent=2)+'\n').encode())
 print(json.dumps(dict(nearest=result['nearest'][:8],shells=result['shells']),indent=2))

def approach(capture,out):
 rows=load_capture(capture);g=Guard(create_game());o=Observer(g)
 prefixes=[375,400,425,450,475,500,600,656]
 bases={}
 for i,p in enumerate(rows[:max(prefixes)]):
  advance(g,p)
  if i+1 in prefixes:bases[i+1]=g.save_state()
 trials=[];best=None
 for prefix in prefixes:
  for target in [(5100,4400),(5300,4400),(5500,4400),(5900,4400),(6500,4400),(5100,4000),(5100,3500),(5100,2500),(5840,2500)]:
   g.load_state(bases[prefix]);inputs=[];samples=[];maxy=-9999;mind=1e9;release=False
   for step in range(500):
    if g.read('gMarioState.area').is_null() or g.read('gMarioState.area.camera').is_null():break
    s=sample(g,o,prefix+step);x,y,z=s['pos']
    goal=(5840,2500)if y>=760 and 5100<x<6650 and 2150<z<4500 else target
    pad=steer(g,goal,64);pad['buttons']=0
    if y>=750 and math.hypot(x-5840,z-2500)<240 and step%18==0:pad['buttons']=0x4000
    advance(g,pad);inputs.append(pad);s=sample(g,o,prefix+step+1);samples.append(s)
    maxy=max(maxy,s['pos'][1]);mind=min(mind,math.dist(s['pos'],s['box']))
    if s['boxAction']==4:
     release=True;break
    if s['area']!=1 or s['level']!=8 or s['health']<256 or 'DEATH' in s['actionName']:break
   result=dict(prefix=prefix,target=target,inputs=inputs,samples=samples,maxY=maxy,minDistance=mind,released=release,shells=shells(g))
   trials.append(result)
   score=(int(release),-mind)
   if best is None or score>best[0]:
    best=(score,len(trials)-1);print('BEST',prefix,target,'distance',round(mind,3),'maxY',round(maxy,3),'last',s['actionName'],s['pos'],'released',release,flush=True)
 out.write_bytes((json.dumps(dict(scope=__doc__,prefixSha256=hashlib.sha256(capture.read_bytes()).hexdigest(),prefixInputs=[dict(buttons=p['buttons'],stick=p['stick'])for p in rows[:max(prefixes)]],trials=trials,best=best),separators=(',',':'))+'\n').encode())
 print('FINISHED',len(trials),'trials',sum(len(t['inputs'])for t in trials),'updates',sum(t['released']for t in trials),'releases',flush=True)

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('output',type=Path);p.add_argument('--mode',choices=['inventory','approach'],default='inventory');a=p.parse_args();globals()[a.mode](a.capture,a.output)
