"""Supplied high AIRBORNE Mario plus native Fire Fly Guy XYZ: entry test, not route.
No ground action, cached floor, actor behavior, hitbox or phase is written.
"""
import gzip,hashlib,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from ink_floorless_warp import reach_after_pillars,NEUTRAL
from ink_slide_handoff import advance,rich_sample
from ink_crawl_predecessors import pose,write
from ink_timer130_crawl import frame_events
sys.path.insert(0,str(ROOT/'instrumentation/ink-item-clone-controls'))
from fixtures import actor_snapshot

class Guard:
 def __init__(self,g):self.g=g;self.mode='controls'
 def __getattr__(self,k):return getattr(self.g,k)
 def write(self,p,v):
  allowed={'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'}
  if self.mode=='setup':
   allowed|={'gMarioState.'+k for k in ['pos','action','actionState','actionTimer','forwardVel','vel','faceAngle']}
   allowed|={'gMarioObject.oPos'+a for a in 'XYZ'}|{'gMarioObject.header.gfx.pos'}
   allowed|={'gObjectPool[%d].oPos%s'%(slot,a)for slot in [45,49]for a in 'XYZ'}
  assert p in allowed,p
  self.g.write(p,v)

def root():
 path=HERE/'prefix.jsonl.gz'
 capture=ROOT/'build/flyguy-high-prefix.jsonl'
 raw=gzip.decompress(path.read_bytes());assert hashlib.sha256(raw).hexdigest()=='9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72'
 if capture.exists():assert capture.read_bytes()==raw
 else:capture.write_bytes(raw)
 g,o=reach_after_pillars(capture);g=Guard(g)
 while not(g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==129):advance(g,NEUTRAL)
 return g,o,g.save_state()

def snap(g,o):
 if g.read('gMarioObject').is_null():
  return dict(marioPresent=False,area=g.read('gCurrAreaIndex'),movement=g.read('gMarioState.pos'),actionName=g.mario_action_names().get(g.read('gMarioState.action')),floorY=g.read('gMarioState.floorHeight'),floorOwner=-1,platform=-1,used=-1,topNative=False,topActive=0,collisionSlots=[])
 s=rich_sample(g,o);s['marioPresent']=True
 s['topNative']=g.read('gObjectPool[61].behavior')==g.address('bhvPyramidTop')
 s['topActive']=g.read('gObjectPool[61].activeFlags')
 s['fly']=actor_snapshot(g,45);s['box']=actor_snapshot(g,49)
 s['collisionSlots']=[o.slot(g.read('gMarioObject.collidedObjs[%d]'%i))for i in range(g.read('gMarioObject.numCollidedObjs'))]
 return s

def trial(g,o,state,r,horizon=45):
 g.load_state(state);g.mode='setup';edits=[];H=r['height'];speed=r['speed']
 pose(g,[-1950,H,-939],edits)
 for field,value in [('action',g.constant('ACT_FREEFALL')),('actionState',0),('actionTimer',0),('forwardVel',speed),('vel',[speed,-16,0]),('faceAngle',[0,16384,0])]:write(g,'gMarioState.'+field,value,edits)
 for slot,xyz in [(45,[-1950,H+r['dy'],-939])]+([(49,[-1989,H,-939])]if r['box']else[]):
  for a,v in zip('XYZ',xyz):write(g,'gObjectPool[%d].oPos%s'%(slot,a),v,edits)
 g.mode='controls';before=snap(g,o);samples=[];events=[];controls=[]
 for n in range(horizon):
  pad=dict(buttons=0x2000,stick=[0,0])if n==0 else NEUTRAL
  advance(g,pad);controls.append(pad);s=snap(g,o);samples.append(s);events.append(frame_events(g))
  if not s['marioPresent']or s['area']!=1 or 'DEATH'in s['actionName']:break
  if n>=45 and not(g.read('gMarioState.action')&g.constant('ACT_FLAG_AIR')):break
 arrival=next((s for s in samples if s['area']==2),None)
 return dict(recipe=r,horizon=horizon,edits=edits,before=before,samples=samples,events=events,controls=controls,
  capture=any(s['topNative']and s['used']==64 and s['floorOwner']==s['platform']==61 for s in samples),
  useful=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717))

def main():
 g,o,state=root();q,qo,qs=root();recipes=[dict(height=h,dy=dy,speed=speed,box=box)for h in [25000,67277]for dy in [-80,0,80]for speed in [0,20]for box in [False,True]]
 trials=[]
 for r in recipes:
  t=trial(g,o,state,r);assert t==trial(q,qo,qs,r);trials.append(t)
  print(r,'registered',45 in t['samples'][0]['collisionSlots'],'first',t['samples'][0]['actionName'],'floor',t['samples'][0]['floorY'],'last',t['samples'][-1]['actionName'],'capture',t['capture'],flush=True)
 long=[]
 for h in [25000,67277]:
  for dy in [-80,0]:
   r=dict(height=h,dy=dy,speed=0,box=True);horizon=2400 if h==25000 and dy==-80 else 1200;t=trial(g,o,state,r,horizon);assert t==trial(q,qo,qs,r,horizon);long.append(t)
   print('LONG',r,len(t['samples']),t['samples'][-1]['actionName'],t['samples'][-1]['movement'],flush=True)
 result=dict(scope=__doc__,proofRevision='4813e95d33286a30882caf0759dd838c95ee48f2',preparation='Accepted A-off prefix to four pillars, then neutral to native phase129; no shell or top edit',trials=trials,extended=long,matchedBoundaries=sum(len(t['samples'])+1 for t in trials+long))
 dest=HERE/'results.json.gz'
 if dest.exists():assert json.load(gzip.open(dest))==result
 else:dest.write_bytes(gzip.compress((json.dumps(result,separators=(',',':'))+'\n').encode(),mtime=0))
 print('PASS',result['matchedBoundaries'],'matched boundaries')

if __name__=='__main__':main()
