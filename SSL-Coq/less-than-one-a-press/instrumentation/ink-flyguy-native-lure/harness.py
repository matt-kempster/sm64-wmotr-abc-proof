"""Controller-only native western Fire Fly Guy manipulation, original JP runtime.

Only inherited debug level selection is supplied; all later writes are controller.
"""
import argparse,gzip,hashlib,json,math,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
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

