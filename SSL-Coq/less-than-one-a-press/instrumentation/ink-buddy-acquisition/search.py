"""Controller-only JP Buddy acquisition search; no supplied gameplay pointers.

Only startup grant: inherited debug level select. Every subsequent write is
to controller pads with A released. Branch states derive from recorded inputs.
"""
import argparse,hashlib,json,math,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from replay import create_game,Observer,load_capture,set_input
from ink_crawl_predecessors import steer
from ink_floorless_warp import NEUTRAL

class Guard:
 def __init__(self,g):self.g=g
 def __getattr__(self,k):return getattr(self.g,k)
 def write(self,p,v):
  assert p in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},p
  if p.endswith('.button'):assert not v&0x8000
  self.g.write(p,v)

def advance(g,pad):
 assert not pad['buttons']&0x8000
 set_input(g,pad);g.advance()
 assert not g.read('gMarioState.input')&0x82

def sample(g,o):
 return dict(timer=g.read('gGlobalTimer'),area=g.read('gCurrAreaIndex'),level=g.read('gCurrLevelNum'),
  mario=g.read('gMarioState.pos'),action=g.read('gMarioState.action'),
  actionName=g.mario_action_names().get(g.read('gMarioState.action')),
  actionState=g.read('gMarioState.actionState'),actionTimer=g.read('gMarioState.actionTimer'),
  held=o.slot(g.read('gMarioState.heldObj')),used=o.slot(g.read('gMarioState.usedObj')),
  interact=o.slot(g.read('gMarioState.interactObj')),floor=g.read('gMarioState.floorHeight'),
  buddy=[g.read('gObjectPool[15].oPos'+a) for a in 'XYZ'],
  buddyAction=g.read('gObjectPool[15].oAction'),buddyActive=g.read('gObjectPool[15].activeFlags'),
  buddyHeld=g.read('gObjectPool[15].oHeldState'),input=g.read('gMarioState.input'),
  health=g.read('gMarioState.health'),quicksand=g.read('gMarioState.quicksandDepth'),
  forward=g.read('gMarioState.forwardVel'),dialog=g.read('gDialogID'))

def root(capture):
 return Guard(create_game()),load_capture(capture)

def inventory(capture,out):
 g,rows=root(capture);o=Observer(g);frames=[];closest=[]
 for i,r in enumerate(rows[:2548]):
  if 'positions'in r:
   seen=o.snapshot();assert seen['timer']==r['timer']+1
   assert all(seen[k]==v for k,v in r.items() if k not in('poll','timer','buttons','stick'))
  advance(g,r)
  if i>=347:
   s=sample(g,o);s['poll']=i+1;s['distance']=math.dist(s['mario'],s['buddy']);frames.append(s)
 for r in sorted(frames,key=lambda s:s['distance'])[:25]:closest.append(r)
 selected=[r for r in frames if r['poll']%100==0 or r['held']==15]
 result=dict(scope=__doc__,captureSha256=hashlib.sha256(capture.read_bytes()).hexdigest(),closest=closest,coarse=selected)
 out.write_bytes((json.dumps(result,indent=2)+'\n').encode())
 print('closest',[(r['poll'],round(r['distance']),r['actionName'],r['held'],r['mario']) for r in closest[:10]])
 print('held segments',[(r['poll'],r['held'],r['mario']) for r in selected if r['held']>=0])

def base_at(capture,poll):
 g,rows=root(capture);o=Observer(g)
 assert len(rows)>=poll,(len(rows),poll)
 for r in rows[:poll]:advance(g,r)
 return g,o,g.save_state(),[dict(buttons=r['buttons'],stick=r['stick']) for r in rows[:poll]]

def talk(capture,out):
 g,o,base,prefix=base_at(capture,2339);history=[];samples=[];stage='approach';talked=False;next_b=0
 for i in range(500):
  s=sample(g,o);pos=s['mario'];b=s['buddy'];distance=math.hypot(pos[0]-b[0],pos[2]-b[2])
  pad=steer(g,[b[0],b[2]],64) if stage=='approach' else dict(NEUTRAL);pad['buttons']=0
  if stage=='approach' and distance<140:
   if i>=next_b:pad['buttons']=0x4000;next_b=i+16
   if s['used']==15:stage='talk';print('dialog accepted',i,s)
  if stage=='talk':
   pad=dict(buttons=0x4000 if i%12==0 else 0,stick=[0,0])
   if s['used']==15 and s['action']==g.constant('ACT_READING_NPC_DIALOG'):talked=True
   if talked and s['action']==g.constant('ACT_IDLE') and s['dialog']==-1:
    stage='done';print('dialog complete',i,s)
  if stage=='done':break
  advance(g,pad);history.append(pad);samples.append(sample(g,o))
  if i%80==0:print('progress',i,samples[-1]['actionName'],samples[-1]['used'],samples[-1]['mario'],samples[-1]['health'],samples[-1]['dialog'])
 result=dict(scope=__doc__,prefixPolls=2339,prefixInputs=prefix,inputs=history,samples=samples,talked=talked,completed=stage=='done')
 out.write_bytes((json.dumps(result,indent=2)+'\n').encode());print('talked',talked,'stage',stage,'final',sample(g,o))

def carry(capture,out):
 g,o,base,prefix=base_at(capture,2675);history=[];samples=[];acquired=False
 for i in range(300):
  advance(g,NEUTRAL);history.append(NEUTRAL);s=sample(g,o);samples.append(s)
  if s['held']==49:
   acquired=True;print('acquired',i+1,s);break
 result=dict(scope=__doc__,prefixPolls=2675,prefixInputs=prefix,inputs=history,samples=samples,acquired=acquired)
 out.write_bytes((json.dumps(result,indent=2)+'\n').encode());print('carry final',sample(g,o))

def transport(capture,out):
 g,o,base,prefix=base_at(capture,2675);history=[];samples=[];route=[]
 for i in range(40):
  advance(g,NEUTRAL);history.append(NEUTRAL);samples.append(sample(g,o))
  if samples[-1]['action']==g.constant('ACT_HOLD_IDLE'):break
 assert samples[-1]['held']==49
 for target in [[-7400,1000],[-7400,-2900],[-6300,-3200],[-6000,-3690]]:
  for i in range(700):
   s=sample(g,o)
   if s['level']!=8 or s['held']!=49:break
   if math.hypot(s['mario'][0]-target[0],s['mario'][2]-target[1])<70:break
   pad=steer(g,target,64);pad['buttons']=0
   advance(g,pad);history.append(pad);samples.append(sample(g,o))
  route.append(dict(target=target,updates=len(history),state=sample(g,o)))
  print('waypoint',target,'updates',len(history),sample(g,o))
  if samples[-1]['held']!=49:break
 result=dict(scope=__doc__,prefixPolls=2675,prefixInputs=prefix,inputs=history,samples=samples,route=route)
 out.write_bytes((json.dumps(result,indent=2)+'\n').encode())

def aftertalk(capture,out):
 prior=json.loads(capture.read_text());g=Guard(create_game());o=Observer(g)
 prefix=prior['prefixInputs']+prior['inputs']
 for p in prefix:advance(g,p)
 assert sample(g,o)==prior['samples'][-1]
 assert sample(g,o)['used']==15 and sample(g,o)['held']==-1
 history=[];samples=[];route=[];acquired=False
 for target in [[-7700,-4500],[-7700,1000],[-5500,1600],[-5200,1700]]:
  for i in range(400):
   s=sample(g,o)
   if s['level']!=8 or s['health']<256:break
   if math.hypot(s['mario'][0]-target[0],s['mario'][2]-target[1])<70:break
   pad=steer(g,target,64);pad['buttons']=0
   if target==[-5200,1700] and i%14==0:pad['buttons']=0x4000
   advance(g,pad);history.append(pad);samples.append(sample(g,o))
   if samples[-1]['held']!=-1:acquired=True;break
  route.append(dict(target=target,updates=len(history),state=sample(g,o)))
  print('waypoint',target,'updates',len(history),sample(g,o))
  if acquired or s['level']!=8 or s['health']<256:break
 for i in range(40):
  if acquired or sample(g,o)['level']!=8 or sample(g,o)['health']<256:break
  advance(g,dict(buttons=0x4000 if i%14==0 else 0,stick=[0,0]));history.append(dict(buttons=0x4000 if i%14==0 else 0,stick=[0,0]));samples.append(sample(g,o))
  acquired=samples[-1]['held']!=-1
 result=dict(scope=__doc__,prefixPolls=len(prefix),prefixInputs=prefix,inputs=history,samples=samples,route=route,acquired=acquired)
 out.write_bytes((json.dumps(result,indent=2)+'\n').encode());print('aftertalk acquired',acquired,'final',sample(g,o))

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('out',type=Path);p.add_argument('--mode',default='inventory',choices=['inventory','talk','carry','transport','aftertalk']);a=p.parse_args();globals()[a.mode](a.capture,a.out)
