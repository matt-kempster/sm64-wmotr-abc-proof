"""Native small-box expiry/pending pickup versus a granted shell-box spawn phase.

No Mario/object pose, used/held/ridden pointer, free-list, donor action/timer,
interaction type, hitbox, or deletion write is allowed. The sole suffix grant
is oAction=4 on the existing native shell box at the named boundary.
"""
import argparse,gzip,hashlib,json,math,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from replay import create_game,Observer,load_capture,set_input
from ink_crawl_predecessors import steer
N=dict(buttons=0,stick=[0,0]);B=dict(buttons=0x4000,stick=[0,0]);Z=dict(buttons=0x2000,stick=[0,0])

class Guard:
 def __init__(self,g):self.g=g
 def __getattr__(self,k):return getattr(self.g,k)
 def write(self,p,v):
  assert p in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y','gObjectPool[32].oAction'},p
  if p.endswith('button'):assert not v&0x8000
  if p=='gObjectPool[32].oAction':assert v==4
  self.g.write(p,v)

def advance(g,p):
 assert not p['buttons']&0x8000
 set_input(g,p);g.advance();assert not g.read('gMarioState.input')&0x82

def behavior(g,slot):
 p=g.read(f'gObjectPool[{slot}].behavior')
 for n in ['bhvBreakableBoxSmall','bhvKoopaShell','bhvRespawner','bhvMistParticleSpawner','bhvMistCircParticleSpawner','bhvYellowCoin','bhvSparkleSpawn']:
  try:
   if p==g.address(n):return n
  except Exception:pass
 return 'other'

def snap(g,o):
 p='gObjectPool[23].';cmd=g.read(p+'curBhvCommand')
 command=[n+f'[{i}]'for n in ['bhvCarrySomething3','bhvCarrySomething4','bhvCarrySomething5']for i in [0,1]if cmd==g.address(n+f'[{i}]')]
 return dict(timer=g.read('gGlobalTimer'),area=g.read('gCurrAreaIndex'),actionName=g.mario_action_names().get(g.read('gMarioState.action')),action=g.read('gMarioState.action'),actionState=g.read('gMarioState.actionState'),actionTimer=g.read('gMarioState.actionTimer'),anim=g.read('gMarioObject.header.gfx.animInfo.animID'),animFrame=g.read('gMarioObject.header.gfx.animInfo.animFrame'),M=g.read('gMarioState.pos'),C=[g.read('gMarioObject.oPos'+a)for a in 'XYZ'],G=g.read('gMarioObject.header.gfx.pos'),floor=g.read('gMarioState.floorHeight'),used=o.slot(g.read('gMarioState.usedObj')),held=o.slot(g.read('gMarioState.heldObj')),ridden=o.slot(g.read('gMarioState.riddenObj')),health=g.read('gMarioState.health'),freeHead=o.slot(g.read('gFreeObjectList.next')),shellBoxAction=g.read('gObjectPool[32].oAction'),slot23=dict(behavior=behavior(g,23),active=g.read(p+'activeFlags'),flags=g.read(p+'oFlags'),parent=o.slot(g.read(p+'parentObj')),pos=[g.read(p+'oPos'+a)for a in 'XYZ'],type=g.read(p+'oInteractType'),subtype=g.read(p+'oInteractionSubtype'),status=g.read(p+'oInteractStatus'),intangible=g.read(p+'oIntangibleTimer'),heldState=g.read(p+'oHeldState'),action=g.read(p+'oAction'),timer=g.read(p+'oTimer'),releaseFrames=g.read(p+'oBreakableBoxSmallFramesSinceReleased'),released=g.read(p+'oBreakableBoxSmallReleased'),radius=g.read(p+'hitboxRadius'),height=g.read(p+'hitboxHeight'),command=command),collisions=[o.slot(g.read(f'gMarioObject.collidedObjs[{i}]'))for i in range(g.read('gMarioObject.numCollidedObjs'))])

def root():
 path=ROOT/'instrumentation/ink-buddy-replacement-delivery/inputs.jsonl';rows=load_capture(path)[:900]
 g=Guard(create_game());o=Observer(g)
 for p in rows:advance(g,p)
 assert o.slot(g.read('gMarioState.heldObj'))==23
 extra=[];samples=[]
 for _ in range(30):
  advance(g,N);extra.append(N);samples.append(snap(g,o))
  if g.read('gMarioState.action')==g.constant('ACT_HOLD_IDLE'):break
 else:raise AssertionError('no native HOLD_IDLE')
 advance(g,Z);extra.append(Z);samples.append(snap(g,o))
 approached=False
 for _ in range(950):
  pad=N
  if g.read('gObjectPool[23].oBreakableBoxSmallFramesSinceReleased')>=810 and not approached:
   target=[g.read('gObjectPool[23].oPos'+a)for a in 'XZ'];m=g.read('gMarioState.pos')
   if math.hypot(m[0]-target[0],m[2]-target[1])<=105:approached=True
   else:pad=steer(g,target,64);pad['buttons']=0
  advance(g,pad);extra.append(pad)
  if len(extra)<30 or len(extra)%50==0:samples.append(snap(g,o))
  assert g.read('gCurrAreaIndex')==1 and g.read('gMarioState.health')>=256,snap(g,o)
  if g.read('gObjectPool[23].oBreakableBoxSmallFramesSinceReleased')==890:break
 else:raise AssertionError('no released timer890')
 s=snap(g,o);assert s['slot23']['active']&1 and s['held']==-1,s
 return g,o,g.save_state(),dict(prefix=path.relative_to(ROOT).as_posix(),prefixFrames=900,prefixSha256=hashlib.sha256(path.read_bytes()).hexdigest(),controls=extra,samples=samples,end=s)

def trial(g,o,base,pickTimer,spawnStep):
 g.load_state(base);t=dict(pickTimer=pickTimer,spawnStep=spawnStep,controls=[],samples=[],edits=[])
 for _ in range(pickTimer-890):advance(g,N);t['controls'].append(N);t['samples'].append(snap(g,o))
 t['beforeB']=snap(g,o)
 for step in range(1,26):
  if step==spawnStep:
   t['edits'].append(dict(beforePickupStep=step,path='gObjectPool[32].oAction',before=g.read('gObjectPool[32].oAction'),after=4));g.write('gObjectPool[32].oAction',4)
  pad=B if step==1 else N;advance(g,pad);t['controls'].append(pad);t['samples'].append(snap(g,o))
 t['nativeShellSlots']=[i for i in range(240)if g.read(f'gObjectPool[{i}].activeFlags')&1 and g.read(f'gObjectPool[{i}].behavior')==g.address('bhvKoopaShell')]
 t['acquiredInitializedShell']=any(s['held']==23 and s['slot23']['behavior']=='bhvKoopaShell'and s['slot23']['type']==524288 and s['slot23']['intangible']==0 for s in t['samples'])
 t['acquiredUninitializedShell']=any(s['held']==23 and s['slot23']['behavior']=='bhvKoopaShell'and s['slot23']['type']==0 for s in t['samples'])
 return t

def followup(g,o,base,timer,spawn,kind):
 trial(g,o,base,timer,spawn)
 t=dict(pickTimer=timer,spawnStep=spawn,kind=kind,initial=snap(g,o),controls=[],samples=[])
 assert o.slot(g.read('gMarioState.heldObj'))==23
 for _ in range(20):
  p=steer(g,[4300,3400],64);p['buttons']=0;advance(g,p);t['controls'].append(p);t['samples'].append(snap(g,o))
 for _ in range(30):
  advance(g,N);t['controls'].append(N);t['samples'].append(snap(g,o))
  if g.read('gMarioState.action')==g.constant('ACT_HOLD_IDLE'):break
 t['beforeRelease']=len(t['samples'])
 for i in range(24):
  p=(B if kind=='throw'else Z)if i==0 else N;advance(g,p);t['controls'].append(p);t['samples'].append(snap(g,o))
 t['afterRelease']=len(t['samples'])
 for _ in range(80):
  target=[g.read('gObjectPool[23].oPos'+a)for a in 'XZ'];p=steer(g,target,64);p['buttons']=0
  advance(g,p);t['controls'].append(p);t['samples'].append(snap(g,o))
  if o.slot(g.read('gMarioState.riddenObj'))==23:break
 t['mounted']=o.slot(g.read('gMarioState.riddenObj'))==23
 print('FOLLOW',timer,spawn,kind,t['mounted'],t['samples'][-1]['M'],t['samples'][-1]['slot23'],flush=True)
 return t

def run(g,o,b):
 out=[]
 for timer in range(894,901):
  for spawn in range(2,9):
   t=trial(g,o,b,timer,spawn);out.append(t)
   if t['acquiredInitializedShell']or t['acquiredUninitializedShell']:
    print('SHELL',timer,spawn,t['acquiredInitializedShell'],t['acquiredUninitializedShell'],[(s['timer'],s['actionName'],s['used'],s['held'],s['slot23']['behavior'],s['slot23']['type'],s['freeHead'])for s in t['samples']],flush=True)
 return out

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--pilot',action='store_true');ap.add_argument('--output',type=Path,default=HERE/'pending-results.json.gz');a=ap.parse_args()
 g,o,b,prep=root();print('BASE',prep['end'],flush=True);r=run(g,o,b)
 follow=[followup(g,o,b,897,spawn,kind)for spawn in [5,6,7]for kind in ['drop','throw']]
 if not a.pilot:
  q,qo,qb,qp=root();qr=run(q,qo,qb);qf=[followup(q,qo,qb,897,spawn,kind)for spawn in [5,6,7]for kind in ['drop','throw']];assert prep==qp and r==qr and follow==qf
 result=dict(scope=__doc__,proofStart='162617b708b2244beca85af58b76ad5794e598cd',preparation=prep,trials=r,followups=follow,independentlyVerified=not a.pilot)
 assert not a.output.exists();a.output.write_bytes(gzip.compress((json.dumps(result,separators=(',',':'))+'\n').encode(),mtime=0))
 print('PASS',len(r),'trials','initialized',sum(t['acquiredInitializedShell']for t in r),'uninitialized',sum(t['acquiredUninitializedShell']for t in r),flush=True)
if __name__=='__main__':main()
