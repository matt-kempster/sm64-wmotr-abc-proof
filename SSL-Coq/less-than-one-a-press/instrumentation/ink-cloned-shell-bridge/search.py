"""Finite high freefall bridge from live and natively fake-picked/released shells.

Shell availability, pickup retarget, high HOLP and initial airborne Mario are grants.
No type, hitbox, status, cache or platform is supplied. Only the separately named
relocated-rider compatibility controls edit Mario again after the initial cut.
"""
import argparse,gzip,hashlib,importlib.util,itertools,json,math,sys,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
spec=importlib.util.spec_from_file_location('shell_clone_bridge_dependency',ROOT/'instrumentation/ink-shell-clone-isolation/test.py')
iso=importlib.util.module_from_spec(spec);spec.loader.exec_module(iso)
NEUTRAL=iso.NEUTRAL;Z=iso.Z
from ink_crawl_predecessors import pose,write

def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()

class Guard:
 def __init__(self,g,slot):self.g=g;self.slot=slot;self.mode='controls'
 def __getattr__(self,n):return getattr(self.g,n)
 def write(self,p,v):
  pads={'gControllerPads[0].'+x for x in ['button','stick_x','stick_y']}
  actor={f'gObjectPool[{s}].oPos{a}' for s in [23,39,self.slot] for a in 'XYZ'}
  if self.mode=='controls':assert p in pads,p
  elif self.mode=='actor':assert p in actor,p
  elif self.mode in ['initial','relocate']:
   allowed=pads|actor|{'gMarioState.'+x for x in ['pos','action','actionState','actionTimer','forwardVel','vel','faceAngle']}
   allowed|={'gMarioObject.header.gfx.pos'}|{'gMarioObject.oPos'+a for a in 'XYZ'}
   if self.mode=='relocate':allowed={'gMarioState.pos','gMarioObject.header.gfx.pos'}|{'gMarioObject.oPos'+a for a in 'XYZ'}
   assert p in allowed,p
  else:raise AssertionError(self.mode)
  self.g.write(p,v)

def roots():
 assert sha(ROOT/'build/wafel-pilot/sm64_jp.dll')=='960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f'
 g,o,slot,base,prep=iso.roots();pick,held=iso.pickup(g,o,slot,base);states={};releases={}
 for h in [25000,67277,90536]:
  rel,state=iso.release(g,o,slot,held,'throw',h);releases[h]=rel
  while g.read('gObjectPool[61].oTimer')<127:iso.advance(g,NEUTRAL)
  for phase in [127,128,129,130]:
   assert g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==phase
   states['clone',h,phase]=g.save_state();iso.advance(g,NEUTRAL)
 g.load_state(base)
 while g.read('gObjectPool[61].oTimer')<127:iso.advance(g,NEUTRAL)
 for phase in [127,128,129,130]:states['live',phase]=g.save_state();iso.advance(g,NEUTRAL)
 return Guard(g,slot),o,states,slot,dict(shell=prep,pickup=pick,releases=releases)

def snap(g,o,full=True):
 if g.read('gMarioObject').is_null():return dict(marioPresent=False,area=g.read('gCurrAreaIndex'),M=g.read('gMarioState.pos'),actionName=g.mario_action_names().get(g.read('gMarioState.action')))
 r=iso.snap(g,o,g.slot)
 r.update(marioPresent=True,topPhase=g.read('gObjectPool[61].oTimer'),topAction=g.read('gObjectPool[61].oAction'),ceilHeight=g.read('gMarioState.ceilHeight'),ceilPresent=not g.read('gMarioState.ceil').is_null(),floorNormal=g.read('gMarioState.floor?.normal'),waterLevel=g.read('gMarioState.waterLevel'))
 if not full:
  keep=['marioPresent','area','M','C','G','action','actionName','floorY','floorOwner','platform','used','ridden','topPhase','topAction','ceilHeight','ceilPresent','collisions','shell']
  r={k:r[k]for k in keep}
 return r

def place(g,slot,xyz,edits):
 for a,v in zip('XYZ',xyz):write(g,f'gObjectPool[{slot}].oPos'+a,v,edits)

def trial(g,o,states,r,full=True):
 mode=r.get('shellMode','clone');h=r['height'];phase=r.get('phase',129)
 g.load_state(states[('clone',h,phase)if mode=='clone'else('live',phase)])
 initial=snap(g,o,full);edits=[];g.mode='initial'
 x,y,z=r.get('pos',[-1950,h,-939]);yaw=r.get('yaw',16384);speed=r.get('speed',20);angle=yaw*math.tau/65536
 relocated=r.get('family')=='relocated-rider-control'
 if relocated:x,y,z=-5862.31787109375,1034,819.5643920898438
 pose(g,[x,y,z],edits)
 vx,vz={0:(0,speed),16384:(speed,0),32768:(0,-speed),49152:(-speed,0)}.get(yaw,(speed*math.sin(angle),speed*math.cos(angle)))
 for k,v in [('action',g.constant('ACT_FREEFALL')),('actionState',0),('actionTimer',0),('forwardVel',speed),('vel',[vx,r.get('vy',-16),vz]),('faceAngle',[0,yaw if yaw<32768 else yaw-65536,0])]:write(g,'gMarioState.'+k,v,edits)
 sh=r.get('shellOffset',[0,-10,0]);wanted=[x+sh[0],y+sh[1],z+sh[2]]
 if mode=='live' or wanted!=[g.read(f'gObjectPool[{g.slot}].oPos'+a)for a in 'XYZ']:place(g,g.slot,wanted,edits)
 if r.get('preplace'):
  off=24 if r['pusher']=='small' else 29;place(g,23 if r['pusher']=='small' else 39,[x-off,y,z],edits)
 g.mode='controls';before=snap(g,o,full);rows=[];events=[];pads=[];cuts=[];lowMount=None;highCut=[]
 if relocated:
  iso.advance(g,NEUTRAL);lowMount=dict(control=NEUTRAL,sample=snap(g,o,full),events=iso.frame_events(g))
  assert lowMount['sample']['action']==g.constant('ACT_RIDING_SHELL_GROUND'),lowMount
  g.mode='relocate';pose(g,[-1950,h,-939],highCut);g.mode='controls'
 for i in range(r.get('updates',35)):
  if i==r.get('pushAt',1) and not r.get('preplace') and r.get('pusher'):
   p=g.read('gMarioState.pos');off=24 if r['pusher']=='small' else 29
   g.mode='actor';es=[];place(g,23 if r['pusher']=='small' else 39,[p[0]-off,p[1],p[2]],es);g.mode='controls';cuts.append(dict(update=i+1,edits=es))
  pad=Z if i in r.get('z',[1]) or r.get('zPulse') and i%2 else NEUTRAL
  iso.advance(g,pad);rows.append(snap(g,o,full));events.append(iso.frame_events(g));pads.append(pad)
  if not rows[-1]['marioPresent'] or rows[-1]['area']!=1:break
 arrival=next((s for s in rows if s['area']==2),None)
 capture=any(s.get('used')==64 and s.get('floorOwner')==s.get('platform')==61 for s in rows)
 useful=arrival is not None and all(abs(a-b)<0.01 for a,b in zip(arrival['M'],[365.5927734375,5500,-1096.8026123046875]))
 mounted=any(e['type']=='FLT_CHANGE_ACTION' and e.get('to')==g.constant('ACT_RIDING_SHELL_GROUND') for es in events for e in es)
 bridge=rows[0].get('action')==g.constant('ACT_RIDING_SHELL_GROUND') and rows[0]['M'][1]>20000
 return dict(recipe=r,initial=initial,edits=edits,before=before,lowMount=lowMount,highCut=highCut,cuts=cuts,controls=pads,samples=rows,events=events,mountEvent=mounted,bridge=bridge,capture=capture,useful=useful)

def recipes():
 out=[]
 for h,mode,pusher,z in itertools.product([25000,67277,90536],['live','clone'],['bobomb','small'],[[1],[0],[]]):out.append(dict(height=h,shellMode=mode,pusher=pusher,z=z))
 for h,pusher,z in itertools.product([25000,67277,90536],['bobomb','small'],[[1],[0]]):out.append(dict(height=h,shellMode='clone',pusher=pusher,z=z,preplace=True))
 for h,phase,z in itertools.product([25000,67277,90536],[128,130],[[1],[0]]):out.append(dict(height=h,shellMode='clone',pusher='bobomb',z=z,phase=phase))
 for h,pusher in itertools.product([25000,67277,90536],['bobomb','small']):out.append(dict(family='relocated-rider-control',height=h,shellMode='clone',pusher=pusher,z=[0],pushAt=0))
 for h in [25000,67277,90536]:out.append(dict(height=h,shellMode='clone',pusher='bobomb',zPulse=True,updates=90))
 return out

def screen_recipes():
 for x,z,yaw,speed,mode in itertools.product([-2030,-1950,-1882],[-1019,-939,-859],[0,16384,32768,49152],[0,20,60,-20],['live','clone']):
  yield dict(height=25000,shellMode=mode,pos=[x,25000,z],yaw=yaw,speed=speed,pusher=None,z=[],updates=1)
 for dx,dy,vy,mode in itertools.product([-80,0,80],[-1,-10,-49],[-1,-75],['live','clone']):
  yield dict(height=25000,shellMode=mode,shellOffset=[dx,dy,0],vy=vy,pusher=None,z=[],updates=1)

def screen(g,o,states,r):
 t=trial(g,o,states,r,False)
 return {k:t[k]for k in ['recipe','edits','before','samples','events','mountEvent','bridge','capture','useful']}

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--output',type=Path,default=HERE/'results.json.gz');ap.add_argument('--pilot',action='store_true');ap.add_argument('--verify',type=Path);a=ap.parse_args()
 g,o,states,slot,prep=roots()
 trials=[]
 for r in recipes():
  t=trial(g,o,states,r);trials.append(t)
  print(r,[(s.get('actionName'),s['M'],s.get('G'),s.get('ridden'),s.get('floorY')) for s in t['samples'][:2]],'capture',t['capture'],'useful',t['useful'],flush=True)
 screens=[screen(g,o,states,r)for r in screen_recipes()]
 assert len(trials)==69 and len(screens)==324
 assert all(t['mountEvent'] and not t['bridge'] for t in screens)
 for t in trials:
  relocated=t['recipe'].get('family')=='relocated-rider-control'
  assert t['capture']==relocated and t['useful']==relocated
  assert not t['bridge']
  assert relocated or t['mountEvent']
 if not a.pilot:
  q,qo,qs,qslot,qprep=roots();assert qprep==prep and qslot==slot
  for t in trials:assert t==trial(q,qo,qs,t['recipe'])
  for t in screens:assert t==screen(q,qo,qs,t['recipe'])
 boundaries=sum(len(t['samples'])+int(t['lowMount'] is not None)for t in trials)+len(screens)
 source=ROOT.parents[2]/'reference-sm64-decomp'
 result=dict(schema=1,date='2026-11-14',scope=__doc__,proofStart='162617b708b2244beca85af58b76ad5794e598cd',runtimeSha256=sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),dependencySha256=sha(ROOT/'instrumentation/ink-shell-clone-isolation/test.py'),sourceHashes={str(p):sha(source/p)for p in ['src/game/mario_step.c','src/game/mario_actions_moving.c','src/game/interaction.c','src/game/behaviors/koopa_shell.inc.c']},preparation=prep,trials=trials,screens=screens,counts=dict(continuations=len(trials),geometryChecks=len(screens),continuationMountEvents=sum(t['mountEvent']for t in trials),screenMountEvents=sum(t['mountEvent']for t in screens),bridges=sum(t['bridge']for t in trials+screens),captures=sum(t['capture']for t in trials),useful=sum(t['useful']for t in trials),checkedBoundaries=boundaries),independentlyVerified=not a.pilot)
 result=json.loads(json.dumps(result))
 if a.verify:assert json.loads(gzip.decompress(a.verify.read_bytes()))==result
 else:assert not a.output.exists();a.output.write_bytes(gzip.compress((json.dumps(result,separators=(',',':'))+'\n').encode(),mtime=0))
 print('FINAL',result['counts'],flush=True)
if __name__=='__main__':main()
