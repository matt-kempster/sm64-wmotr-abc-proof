"""Initialized shell, native conditional fake pickup/release, and high mount diagnostics."""
import argparse,gzip,hashlib,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[1]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from ink_floorless_warp import reach_after_pillars,NEUTRAL
from ink_slide_handoff import advance,rich_sample
from ink_timer130_crawl import frame_events
sys.path.insert(0,str(ROOT/'instrumentation/ink-item-clone-controls'))
from fixtures import actor_snapshot
B=dict(buttons=0x4000,stick=[0,0]); Z=dict(buttons=0x2000,stick=[0,0])
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def ptr(g,o,v):
 if v.is_null():return 'null'
 slot=o.slot(v)
 if slot>=0:return 'gObjectPool[%d]'%slot
 for n in ['bhvCarrySomething3','bhvCarrySomething4','bhvCarrySomething5']:
  for i in [0,1]:
   if v==g.address(n+'[%d]'%i):return n+'[%d]'%i
 return 'inherited nonnull pointer'
def write(g,o,path,value,edits):
 allowed={'gMarioState.pos','gMarioObject.header.gfx.pos','gMarioState.usedObj','gMarioState.marioBodyState.heldObjLastPosition','gObjectPool[32].oAction'}
 allowed|={'gMarioObject.oPos'+a for a in 'XYZ'}
 allowed|={'gMarioState.'+k for k in ['action','actionState','actionTimer','vel','forwardVel','faceAngle']}
 allowed|={f'gObjectPool[{s}].oPos'+a for s in [69,70,71]for a in 'XYZ'}
 assert path in allowed,path
 conv=lambda v:ptr(g,o,v)if hasattr(v,'is_null')else v
 edits.append(dict(path=path,before=conv(g.read(path)),after=conv(value)));g.write(path,value)
def mario(g,o,p,edits,action='ACT_FREEFALL',speed=20):
 for k,v in [('gMarioState.pos',p),('gMarioObject.header.gfx.pos',p)]+[('gMarioObject.oPos'+a,v)for a,v in zip('XYZ',p)]:write(g,o,k,v,edits)
 for k,v in [('action',g.constant(action)),('actionState',0),('actionTimer',0),('vel',[speed,-16 if action=='ACT_FREEFALL'else 0,0]),('forwardVel',speed),('faceAngle',[0,16384 if action=='ACT_FREEFALL'else 0,0])]:write(g,o,'gMarioState.'+k,v,edits)
def position(g,o,slot,p,edits):
 for a,v in zip('XYZ',p):write(g,o,f'gObjectPool[{slot}].oPos'+a,v,edits)
def snap(g,o,slot):
 a=actor_snapshot(g,slot);a['command']=ptr(g,o,g.read(f'gObjectPool[{slot}].curBhvCommand'))
 a['collidedSlots']=[o.slot(g.read(f'gObjectPool[{slot}].collidedObjs[{i}]'))for i in range(g.read(f'gObjectPool[{slot}].numCollidedObjs'))]
 s=rich_sample(g,o);s['G']=s.pop('display');s['M']=s.pop('movement');s['C']=s.pop('collision')
 s.update(shell=a,ridden=o.slot(g.read('gMarioState.riddenObj')),collisions=[o.slot(g.read(f'gMarioObject.collidedObjs[{i}]'))for i in range(g.read('gMarioObject.numCollidedObjs'))],holp=g.read('gMarioState.marioBodyState.heldObjLastPosition'),input=g.read('gMarioState.input'))
 return s
def step(g,o,slot,t,pad=NEUTRAL):
 advance(g,pad);s=snap(g,o,slot);t.setdefault('controls',[]).append(pad);t.setdefault('samples',[]).append(s);t.setdefault('events',[]).append(frame_events(g));return s
def roots():
 raw=gzip.decompress((ROOT/'instrumentation/ink-high-item-nudge/prefix.jsonl.gz').read_bytes());assert hashlib.sha256(raw).hexdigest()=='9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72'
 path=ROOT/'build/ink-shell-clone-prefix.jsonl';path.write_bytes(raw);g,o=reach_after_pillars(path)
 e=[];before=dict(topAction=g.read('gObjectPool[61].oAction'),topTimer=g.read('gObjectPool[61].oTimer'),timer=g.read('gGlobalTimer'))
 write(g,o,'gObjectPool[32].oAction',4,e)
 for _ in range(2):advance(g,NEUTRAL)
 slots=[i for i in range(240)if g.read(f'gObjectPool[{i}].activeFlags')and g.read(f'gObjectPool[{i}].behavior')==g.address('bhvKoopaShell')]
 assert len(slots)==1,slots;slot=slots[0]
 assert slot in [69,70,71],slot
 return g,o,slot,g.save_state(),dict(before=before,edits=e,controls=[NEUTRAL]*2,after=snap(g,o,slot))
def pickup(g,o,slot,base):
 g.load_state(base);e=[];mario(g,o,[5900,51,3380],e,'ACT_IDLE',0);position(g,o,slot,[6100,51,3380],e)
 t=dict(edits=e,initial=snap(g,o,slot));retarget=False
 for i in range(50):
  s=step(g,o,slot,t,B if i==0 else NEUTRAL)
  if not retarget and s['action']==g.constant('ACT_PICKING_UP')and s['held']==-1:
   assert s['used']==23,s['used'];e=[];write(g,o,'gMarioState.usedObj',g.address(f'gObjectPool[{slot}]'),e);t['targetCut']=dict(afterUpdate=i+1,edits=e);retarget=True
  if s['held']==slot and 'grabUpdate'not in t:t['grabUpdate']=i+1
  if s['action']==g.constant('ACT_HOLD_IDLE'):break
 else:raise AssertionError('pickup failed')
 return t,g.save_state()
def release(g,o,slot,held,kind,height=None):
 g.load_state(held);t=dict(kind=kind,height=height,initial=snap(g,o,slot));cut=False
 for i in range(24):
  if height is not None and not cut and ((kind=='throw'and g.read('gMarioState.action')==g.constant('ACT_THROWING')and g.read('gMarioState.actionTimer')==6)or(kind=='drop'and i==0)):
   e=[];write(g,o,'gMarioState.marioBodyState.heldObjLastPosition',[-1950,height-10,-971],e);t['highHOLP']=dict(beforeUpdate=i+1,edits=e);cut=True
  s=step(g,o,slot,t,(B if kind=='throw'else Z)if i==0 else NEUTRAL)
  if s['held']==-1 and 'releaseUpdate'not in t:t['releaseUpdate']=i+1
 assert 'releaseUpdate'in t
 if height is not None:assert cut
 return t,g.save_state()
def mount(g,o,slot,start,height,sameZ=False,xyz=None,speed=20,steps=4):
 g.load_state(start);e=[];p=xyz or[-1950,height,-939];mario(g,o,p,e,speed=speed)
 t=dict(height=height,sameZ=sameZ,speed=speed,edits=e,initial=snap(g,o,slot))
 for i in range(steps):step(g,o,slot,t,Z if sameZ and i==0 else NEUTRAL)
 return t,g.save_state()
def run(g,o,slot,base):
 pick,held=pickup(g,o,slot,base);r=dict(pickup=pick,releases=[],mounts=[])
 for kind,h in [('drop',None),('drop',25000),('throw',None),('throw',25000),('throw',67277),('throw',90536)]:
  rel,state=release(g,o,slot,held,kind,h);r['releases'].append(rel)
  if kind=='drop'and h is None:
   p=rel['samples'][-1]['shell']['position'];p=[p[0],p[1]+10,p[2]]
   t,_=mount(g,o,slot,state,p[1],False,xyz=p);t['kind']='native-fake-pickup-drop-low';r['mounts'].append(t)
  if kind=='throw'and h is not None:
   for z in [False,True]:
    t,end=mount(g,o,slot,state,h,z);t['kind']='native-fake-pickup-throw';r['mounts'].append(t)
   # Test a second above-contact on a stopped shell after its first mount wrote status.
   t,end=mount(g,o,slot,state,h,True,steps=1)
   again,_=mount(g,o,slot,end,h,True);again['kind']='frozen-second-contact';again['firstContact']=t;r['mounts'].append(again)
 for h in [25000,67277,90536]:
  g.load_state(base);e=[];position(g,o,slot,[-1950,h-10,-939],e);state=g.save_state()
  for z in [False,True]:
   t,_=mount(g,o,slot,state,h,z);t['actorEdits']=e;t['kind']='live-initialized';r['mounts'].append(t)
 return r
def count(r):
 if isinstance(r,dict):return len(r.get('samples',[]))+sum(count(v)for k,v in r.items()if k!='samples')
 if isinstance(r,list):return sum(count(v)for v in r)
 return 0
def check(g,slot,r):
 assert r['pickup']['grabUpdate']==6 and r['pickup']['targetCut']['afterUpdate']==4
 assert len(r['pickup']['samples'])==17
 initial=r['pickup']['initial']['shell']
 for t in r['releases']:
  for s in t['samples']:
   a=s['shell'];assert a['behavior']=='bhvKoopaShell'and a['oInteractType']==524288
   assert a['oIntangibleTimer']==0 and a['hitboxRadius']==a['hitboxHeight']==50
   assert a['oFlags']==initial['oFlags']and not a['oFlags']&1024
  assert t['releaseUpdate']==(7 if t['kind']=='throw'else 1)
  if t['height']is not None:
   p=t['samples'][-1]['shell']['position']
   assert p==([-1950.0,t['height']-10.0,-939.0]if t['kind']=='throw'else[-1950.0,51.0,-971.0])
  assert t['samples'][-1]['shell']['command']==('bhvCarrySomething5[1]'if t['kind']=='throw'else'bhvCarrySomething4[1]')
 for t in r['mounts']:
  s=t['samples'][0];assert slot in s['collisions']
  assert any(e['type']=='FLT_CHANGE_ACTION'and e.get('to')==g.constant('ACT_RIDING_SHELL_GROUND')for e in t['events'][0])
  if t['kind']=='native-fake-pickup-drop-low':assert s['ridden']==slot and s['action']==g.constant('ACT_RIDING_SHELL_GROUND')
  else:
   assert s['ridden']==-1
   cancel=t['sameZ']and t['kind']!='frozen-second-contact'
   assert s['action']==g.constant('ACT_GROUND_BONK'if cancel else'ACT_BACKWARD_GROUND_KB')
   if not t['kind'].startswith('live'):
    assert s['shell']['oInteractStatus']==4194304
    assert s['shell']['position']==t['initial']['shell']['position']
  assert not s['input']&0x82
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--pilot',action='store_true');ap.add_argument('--verify',type=Path);ap.add_argument('--output',type=Path,default=HERE/'results.json.gz');a=ap.parse_args()
 g,o,s,b,prep=roots();r=run(g,o,s,b);check(g,s,r)
 print('PREP',prep['before'],'slot',s,'pickup',r['pickup']['grabUpdate'],flush=True)
 for t in r['releases']:print('release',t['kind'],t['height'],'at',t['releaseUpdate'],t['samples'][-1]['shell'],flush=True)
 for t in r['mounts']:print('mount',t['kind'],t['height'],t['sameZ'],[(x['actionName'],x['ridden'],x['M'],x['shell']['oInteractStatus'],s in x['collisions'])for x in t['samples']],flush=True)
 if not a.pilot:
  q,qo,qs,qb,qp=roots();qr=run(q,qo,qs,qb);check(q,qs,qr);assert prep==qp and r==qr
 out=dict(schema=1,scope=__doc__,proofStart='162617b708b2244beca85af58b76ad5794e598cd',runtimeSha256=sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),preparation=prep,results=r,boundaries=count(r),independentlyVerified=not a.pilot)
 if a.verify:assert json.loads(gzip.decompress(a.verify.read_bytes()))==out
 else:assert not a.output.exists();a.output.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
 print('PASS',count(r),'boundaries',flush=True)
if __name__=='__main__':main()
