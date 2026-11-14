"""JP Buddy motion: untouched prefix, contact controls, conditional fake pickup.

No Buddy XYZ/type/flag/status/velocity/behavior writes occur. Fake pickup grants
one usedObj retarget after an actual small-box pickup starts; no clone lineage
is claimed. Release inputs then execute native drop/throw and Buddy physics.
"""
import argparse,json,math,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from replay import create_game,Observer,load_capture,set_input
from ink_floorless_warp import NEUTRAL
from ink_slide_handoff import advance
from ink_crawl_predecessors import pose,write,steer,f32
from ink_pu_vpu import digest
sys.path.insert(0,str(ROOT/'instrumentation/ink-item-clone-controls'))
from fixtures import actor_snapshot

class Guard:
 def __init__(self,g):self.g=g;self.setup=False
 def __getattr__(self,k):return getattr(self.g,k)
 def write(self,p,v):
  if not self.setup:assert p in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},p
  assert not p.startswith('gObjectPool[15].'),p
  self.g.write(p,v)

def buddy(g,o):
 a=actor_snapshot(g,15);p='gObjectPool[15].'
 a.update(home=[g.read(p+'oHome'+x) for x in 'XYZ'],copies=[g.read(p+'oBobombBuddyPos'+x+'Copy') for x in 'XYZ'],yaw=g.read(p+'oMoveAngleYaw'),distance=g.read(p+'oDistanceToMario'),collisions=[o.slot(g.read(p+f'collidedObjs[{i}]')) for i in range(g.read(p+'numCollidedObjs'))])
 return a

def sample(g,o):
 return dict(timer=g.read('gGlobalTimer'),area=g.read('gCurrAreaIndex'),mario=g.read('gMarioState.pos'),action=g.read('gMarioState.action'),actionName=g.mario_action_names().get(g.read('gMarioState.action')),actionState=g.read('gMarioState.actionState'),actionTimer=g.read('gMarioState.actionTimer'),input=g.read('gMarioState.input'),held=o.slot(g.read('gMarioState.heldObj')),used=o.slot(g.read('gMarioState.usedObj')),holp=g.read('gMarioState.marioBodyState.heldObjLastPosition'),animID=g.read('gMarioObject.header.gfx.animInfo.animID'),animFrame=g.read('gMarioObject.header.gfx.animInfo.animFrame'),buddy=buddy(g,o))

def roots(capture):
 g=Guard(create_game());o=Observer(g);prefix=[]
 for i,r in enumerate(load_capture(capture)[:2548]):
  if 'positions' in r:
   seen=o.snapshot();assert seen['timer']==r['timer']+1
   assert all(seen[k]==v for k,v in r.items() if k not in ('poll','timer','buttons','stick'))
  assert not r['buttons']&0x8000
  set_input(g,r);g.advance()
  if g.read('gObjectPool[15].activeFlags') and g.read('gObjectPool[15].behavior')==g.address('bhvBobombBuddyOpensCannon'):
   prefix.append(dict(poll=i+1,position=[g.read('gObjectPool[15].oPos'+x) for x in 'XYZ'],forward=g.read('gObjectPool[15].oForwardVel'),velocityY=g.read('gObjectPool[15].oVelY'),action=g.read('gObjectPool[15].oAction')))
 assert g.read('gObjectPool[61].oPyramidTopPillarsTouched')==4
 while not(g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==125):advance(g,NEUTRAL)
 return g,o,g.save_state(),prefix

def mario_cut(g,pos):
 edits=[];g.setup=True;pose(g,pos,edits)
 for k,v in [('action',g.constant('ACT_IDLE')),('actionState',0),('actionTimer',0),('forwardVel',0),('vel',[0,0,0]),('faceAngle',[0,0,0])]:write(g,'gMarioState.'+k,v,edits)
 g.setup=False;return edits

def contact_trial(g,o,base,kind,yaw):
 g.load_state(base);b=buddy(g,o);x,y,z=b['position'];a=yaw*math.tau/65536
 edits=mario_cut(g,[f32(x+160*math.sin(a)),y,f32(z+160*math.cos(a))]);rows=[];inputs=[]
 for i in range(32):
  pad=steer(g,[x,z],64);pad['buttons']=0x4000 if kind=='punch' and i%6==0 else 0
  inputs.append(pad);advance(g,pad);rows.append(sample(g,o))
 return dict(kind=kind,yaw=yaw,edits=edits,inputs=inputs,samples=rows)

def object_trial(g,o,base,slot,yaw):
 g.load_state(base);b=buddy(g,o);x,y,z=b['position'];a=yaw*math.tau/65536;edits=[];before=actor_snapshot(g,slot);g.setup=True
 for axis,value in zip('XYZ',[f32(x+80*math.sin(a)),y,f32(z+80*math.cos(a))]):write(g,f'gObjectPool[{slot}].oPos'+axis,value,edits)
 g.setup=False;rows=[]
 for i in range(48):advance(g,NEUTRAL);rows.append(sample(g,o))
 return dict(kind='other-actor-nearby',slot=slot,yaw=yaw,actorBefore=before,actorAfter=actor_snapshot(g,slot),edits=edits,inputs=[NEUTRAL]*len(rows),samples=rows)

def pickup(g,o,base,retarget):
 g.load_state(base);pos=[g.read('gObjectPool[23].oPos'+x) for x in 'XYZ'];pos[2]-=60
 edits=mario_cut(g,pos);initial=sample(g,o);rows=[];inputs=[];referenceCut=None
 for i in range(80):
  pad=dict(buttons=0x4000,stick=[0,0]) if i==0 else NEUTRAL;inputs.append(pad);advance(g,pad);s=sample(g,o);rows.append(s)
  if retarget and referenceCut is None and s['action']==g.constant('ACT_PICKING_UP') and s['held']==-1:
   referenceCut=dict(afterUpdate=i+1,path='gMarioState.usedObj',beforeSlot=s['used'],afterSlot=15)
   assert s['used']==23;g.setup=True;g.write('gMarioState.usedObj',g.address('gObjectPool[15]'));g.setup=False
  if s['action']==g.constant('ACT_HOLD_IDLE'):
   assert s['held']==(15 if retarget else 23);break
 else:raise AssertionError('pickup did not complete')
 return dict(kind='conditional-used-reference' if retarget else 'ordinary-small-box-control',initial=initial,edits=edits,referenceCut=referenceCut,inputs=inputs,samples=rows),g.save_state()

def release(g,o,held,kind):
 g.load_state(held);initial=sample(g,o);rows=[];inputs=[]
 for i in range(64):
  buttons=(0x4000 if kind=='throw' else 0x2000 if kind=='drop' else 0) if i==0 else 0
  pad=dict(buttons=buttons,stick=[0,0]);inputs.append(pad);advance(g,pad);rows.append(sample(g,o))
 return dict(kind=kind,initial=initial,inputs=inputs,samples=rows)

def main():
 p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
 g,o,b,prefix=roots(a.capture);q,qo,qb,qprefix=roots(a.capture);assert prefix==qprefix
 origin=[-5990.0,0.0,-3871.0];assert len(prefix)==2201 and all(r['position']==origin for r in prefix)
 initial=sample(g,o);assert initial==sample(q,qo)
 trials=[]
 for kind in ['walk','punch']:
  for yaw in range(0,65536,8192):
   t=contact_trial(g,o,b,kind,yaw);assert t==contact_trial(q,qo,qb,kind,yaw);trials.append(t)
 for slot in [39,49]:
  for yaw in [0,16384,32768,49152]:
   t=object_trial(g,o,b,slot,yaw);assert t==object_trial(q,qo,qb,slot,yaw);trials.append(t)
 assert all(s['buddy']['position']==origin for t in trials for s in t['samples'])
 pickupControl,ch=pickup(g,o,b,False);qc,qch=pickup(q,qo,qb,False);assert pickupControl==qc
 acquire,held=pickup(g,o,b,True);qa,qheld=pickup(q,qo,qb,True);assert acquire==qa
 assert all(s['buddy']['position']==origin for s in acquire['samples'])
 releases=[]
 for kind in ['hold','drop','throw']:
  t=release(g,o,held,kind);assert t==release(q,qo,qheld,kind);releases.append(t)
  if kind=='hold':assert all(s['buddy']['position']==origin and s['held']==15 for s in t['samples'])
  else:
   assert any(s['buddy']['position']!=origin for s in t['samples']);assert t['samples'][-1]['held']==-1
   assert all(not s['buddy']['commandAtCarryStart'] and not s['buddy']['commandAtCarryBreak'] for s in t['samples'])
   assert t['samples'][-1]['buddy']['oForwardVel']==0 and t['samples'][-1]['buddy']['oVelY']==0
 sources=['src/game/behaviors/bobomb.inc.c','src/game/object_helpers.c','src/game/interaction.c','src/game/mario_actions_object.c','src/game/obj_behaviors.c','data/behavior_data.c']
 dependencies=['replay.py','ink_floorless_warp.py','ink_slide_handoff.py','ink_crawl_predecessors.py','ink_pu_vpu.py','ink_timer130_crawl.py']
 result=dict(schema=1,date='2026-11-14',scope=__doc__,proofBase='9229f9e2466782a142b595fda6d5cc64ee4c1016',decompileBase='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),captureSha256=digest(a.capture),scriptSha256=digest(__file__),helperHashes={s:digest(ROOT/'instrumentation/wafel-jp-pilot'/s) for s in dependencies},fixtureHash=digest(ROOT/'instrumentation/ink-item-clone-controls/fixtures.py'),sourceHashes={s:digest(ROOT.parents[2]/'reference-sm64-decomp'/s) for s in sources},prefixStartupGrant={'gDebugLevelSelect':1},initial=initial,nativePrefix=prefix,contactTrials=trials,ordinaryPickup=pickupControl,conditionalPickup=acquire,releases=releases,freshBoundaries=len(prefix)+sum(len(t['samples']) for t in trials)+len(pickupControl['samples'])+len(acquire['samples'])+sum(len(t['samples']) for t in releases))
 a.output.write_bytes((json.dumps(result,indent=2)+'\n').encode())
 print('PASS prefix',len(prefix),'contact histories',len(trials),'total fresh boundaries',result['freshBoundaries'])
 print('acquire',len(acquire['samples']),acquire['referenceCut'])
 for t in releases:
  changed=[(i+1,s['buddy']['position'],s['buddy']['oHeldState'],s['buddy']['oVelY']) for i,s in enumerate(t['samples']) if s['buddy']['position']!=origin]
  print(t['kind'],'first movement',changed[0] if changed else None,'last',t['samples'][-1]['buddy']['position'])
if __name__=='__main__':main()
