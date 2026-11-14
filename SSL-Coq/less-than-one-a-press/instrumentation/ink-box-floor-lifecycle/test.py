"""Native JP box mesh lifecycle; all non-input cuts are recorded, no delivery claim."""
import argparse,gzip,hashlib,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from ink_floorless_warp import reach_after_pillars,NEUTRAL
from ink_slide_handoff import advance
from ink_crawl_predecessors import pose
sys.path.insert(0,str(ROOT/'instrumentation/ink-item-clone-controls'))
from fixtures import actor_snapshot
SLOT=13;OLD=[-1849,24800,-939];NEW=[-1449,24900,-939]
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def roots():
 raw=gzip.decompress((ROOT/'instrumentation/ink-high-item-nudge/prefix.jsonl.gz').read_bytes())
 assert hashlib.sha256(raw).hexdigest()=='9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72'
 p=ROOT/'build/box-floor-prefix.jsonl';p.write_bytes(raw)
 g,o=reach_after_pillars(p)
 while not(g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==129):advance(g,NEUTRAL)
 assert g.read('gObjectPool[13].behavior')==g.address('bhvBreakableBox')
 return g,o,g.save_state()
def pointer(g,o,v):
 if v.is_null():return 'null'
 slot=o.slot(v)
 if slot>=0:return 'gObjectPool[%d]'%slot
 for n in ['bhvCarrySomething3','bhvCarrySomething4','bhvCarrySomething5','gObjectPool[13].transform']:
  if v==g.address(n):return n
 return 'inherited nonnull pointer'
def write(g,o,p,v,edits):
 allowed={'gMarioState.pos','gMarioObject.header.gfx.pos','gTimeStopState','gMarioState.usedObj','gMarioState.marioBodyState.heldObjLastPosition'}
 allowed|={'gMarioObject.oPos'+a for a in 'XYZ'}|{'gObjectPool[13].oPos'+a for a in 'XYZ'}
 allowed|={'gMarioState.'+k for k in ['action','actionState','actionTimer','vel','forwardVel','faceAngle']}
 allowed|={'gObjectPool[13].'+k for k in ['parentObj','curBhvCommand','bhvStackIndex','header.gfx.throwMatrix']}
 assert p in allowed,p
 old=g.read(p)
 conv=lambda x:pointer(g,o,x) if hasattr(x,'is_null') else x
 edits.append(dict(path=p,before=conv(old),after=conv(v)));g.write(p,v)
def mario(g,o,p,edits,action='ACT_FREEFALL'):
 for k,v in [('gMarioState.pos',p),('gMarioObject.header.gfx.pos',p)]+[('gMarioObject.oPos'+a,v)for a,v in zip('XYZ',p)]:write(g,o,k,v,edits)
 for k,v in [('action',g.constant(action)),('actionState',0),('actionTimer',0),('vel',[0,0,0]),('forwardVel',0),('faceAngle',[0,0,0])]:write(g,o,'gMarioState.'+k,v,edits)
def box(g,o,p,edits):
 for a,v in zip('XYZ',p):write(g,o,'gObjectPool[13].oPos'+a,v,edits)
def freeze(g,o,edits):
 for p,v in [('parentObj',g.read('gMarioObject')),('curBhvCommand',g.address('bhvCarrySomething3')),('bhvStackIndex',0)]:write(g,o,'gObjectPool[13].'+p,v,edits)
def snapshot(g,o):
 surfaces=[];addresses={}
 for i in range(g.read('gNumStaticSurfaces'),g.read('gSurfacesAllocated')):
  s=g.read(f'sSurfacePool[{i}]')
  if s.pop('object')==g.address('gObjectPool[13]'):
   surfaces.append(dict(index=i,**s));addresses[str(g.address(f'sSurfacePool[{i}]'))]=i
 links=[];heads=g.read('gDynamicSurfacePartition');nonempty=0
 for z,row in enumerate(heads):
  for x,cell in enumerate(row):
   for kind,head in enumerate(cell):
    if head['next'].is_null():continue
    nonempty+=1;p=f'gDynamicSurfacePartition[{z}][{x}][{kind}].next';seen=0
    while not g.read(p).is_null():
     index=addresses.get(str(g.read(p+'.surface')))
     if index is not None:links.append(dict(cellZ=z,cellX=x,kind=kind,surface=index))
     p+='.next';seen+=1;assert seen<100
 a=actor_snapshot(g,13)
 a['command']=[dict(script=n,index=i)for n in ['bhvCarrySomething3','bhvCarrySomething4','bhvCarrySomething5']for i in [0,1]if g.read('gObjectPool[13].curBhvCommand')==g.address(n+f'[{i}]')]
 a['transform']=g.read('gObjectPool[13].transform');a['throwMatrix']=pointer(g,o,g.read('gObjectPool[13].header.gfx.throwMatrix'))
 return dict(timer=g.read('gGlobalTimer'),area=g.read('gCurrAreaIndex'),timeStop=g.read('gTimeStopState'),M=g.read('gMarioState.pos'),C=[g.read('gMarioObject.oPos'+a)for a in 'XYZ'],G=g.read('gMarioObject.header.gfx.pos'),action=g.read('gMarioState.action'),actionName=g.mario_action_names().get(g.read('gMarioState.action')),actionTimer=g.read('gMarioState.actionTimer'),actionState=g.read('gMarioState.actionState'),floorY=g.read('gMarioState.floorHeight'),floorOwner=o.slot(g.read('gMarioState.floor?.object')),platform=o.slot(g.read('gMarioPlatform')),held=o.slot(g.read('gMarioState.heldObj')),used=o.slot(g.read('gMarioState.usedObj')),holp=g.read('gMarioState.marioBodyState.heldObjLastPosition'),box=a,surfaceCount=len(surfaces),surfaces=surfaces,boxPartitionLinks=links,nonemptyDynamicHeads=nonempty,totalAllocated=g.read('gSurfacesAllocated'),staticAllocated=g.read('gNumStaticSurfaces'),nodesAllocated=g.read('gSurfaceNodesAllocated'),staticNodes=g.read('gNumStaticSurfaceNodes'))
def step(g,o,t,pad=NEUTRAL):
 assert not pad['buttons']&0x8000
 advance(g,pad);t.setdefault('controls',[]).append(pad);s=snapshot(g,o);t.setdefault('samples',[]).append(s);return s
def probe(g,o,state,p):
 g.load_state(state);e=[];mario(g,o,p,e);t=dict(edits=e,initial=snapshot(g,o));step(g,o,t);return t
def live_cases(g,o,base):
 g.load_state(base);edits=[];mario(g,o,[OLD[0],OLD[1]+280,OLD[2]],edits);box(g,o,OLD,edits)
 load=dict(edits=edits,initial=snapshot(g,o));s=step(g,o,load);assert s['surfaceCount']==12 and s['floorOwner']==13 and s['floorY']==25000
 loaded=g.save_state();trials=[]
 for name in ['live-moved','live-cached-transform','frozen-normal','frozen-time-stop']:
  g.load_state(loaded);e=[]
  if name.startswith('frozen'):freeze(g,o,e)
  if name=='frozen-time-stop':write(g,o,'gTimeStopState',66,e)
  if name=='live-cached-transform':write(g,o,'gObjectPool[13].header.gfx.throwMatrix',g.address('gObjectPool[13].transform'),e)
  box(g,o,NEW,e);mario(g,o,[NEW[0],NEW[1]+280,NEW[2]],e)
  t=dict(name=name,edits=e,initial=snapshot(g,o))
  for _ in range(3):step(g,o,t)
  end=g.save_state();t['queries']={name:probe(g,o,end,p)for name,p in [('old',[OLD[0],OLD[1]+280,OLD[2]]),('new',[NEW[0],NEW[1]+280,NEW[2]])]}
  if name=='frozen-time-stop':
   g.load_state(end);e=[];write(g,o,'gTimeStopState',0,e);t['resume']=dict(edits=e,initial=snapshot(g,o))
   for _ in range(3):step(g,o,t['resume'])
  trials.append(t)
 # Time stop can retain an existing mesh, not create one from the carry script.
 g.load_state(base);e=[];mario(g,o,[OLD[0],OLD[1]+280,OLD[2]],e);box(g,o,OLD,e);freeze(g,o,e);write(g,o,'gTimeStopState',66,e)
 t=dict(name='frozen-time-stop-before-loading',edits=e,initial=snapshot(g,o))
 for _ in range(3):step(g,o,t)
 trials.append(t)
 return dict(nativeHighLoad=load,trials=trials)
def native_pickup(g,o,base):
 g.load_state(base);p=[g.read('gObjectPool[23].oPos'+a)for a in 'XYZ'];p[2]-=60;e=[]
 mario(g,o,p,e,'ACT_IDLE');box(g,o,[p[0]+200,p[1],p[2]],e)
 t=dict(edits=e,initial=snapshot(g,o));retarget=False;grab=None
 for i in range(60):
  s=step(g,o,t,dict(buttons=0x4000,stick=[0,0])if i==0 else NEUTRAL)
  if not retarget and s['action']==g.constant('ACT_PICKING_UP') and s['held']==-1:
   assert s['used']==23;e=[];write(g,o,'gMarioState.usedObj',g.address('gObjectPool[13]'),e);t['usedReferenceCut']=dict(afterUpdate=i+1,edits=e);retarget=True
  if grab is None and s['held']==13:grab=g.save_state();t['grabUpdate']=i+1;assert s['surfaceCount']==12
  if s['action']==g.constant('ACT_HOLD_IDLE'):break
 else:raise AssertionError('Native pickup did not finish')
 assert t['samples'][t['grabUpdate']]['surfaceCount']==0
 return t,grab,g.save_state()
def release(g,o,start,kind,high=False):
 g.load_state(start);t=dict(kind=kind,initial=snapshot(g,o));cut=False
 for i in range(24):
  if high and not cut and g.read('gMarioState.action')==g.constant('ACT_THROWING') and g.read('gMarioState.actionTimer')==6:
   e=[];write(g,o,'gMarioState.marioBodyState.heldObjLastPosition',[-1849,24800,-971],e);t['suppliedHighHOLP']=dict(beforeUpdate=i+1,edits=e);cut=True
  s=step(g,o,t,dict(buttons=0x4000 if kind=='throw' else 0x2000,stick=[0,0])if i==0 else NEUTRAL)
  if s['held']==-1 and 'releasedUpdate'not in t:t['releasedUpdate']=i+1
 assert 'releasedUpdate'in t
 if high:assert cut and s['box']['position']==[-1849.0,24800.0,-939.0]
 return t,g.save_state()
def run(g,o,base):
 result=live_cases(g,o,base)
 pickup,grab,held=native_pickup(g,o,base);result['conditionalNativePickup']=pickup
 result['normalReleases']=[release(g,o,held,k)[0]for k in ['drop','throw']]
 g.load_state(grab);e=[];write(g,o,'gTimeStopState',66,e);t=dict(edits=e,initial=snapshot(g,o))
 for _ in range(12):step(g,o,t)
 assert g.read('gMarioState.action')==g.constant('ACT_HOLD_IDLE')
 assert all(s['surfaceCount']==12 for s in t['samples'])
 stoppedheld=g.save_state();throw,thrown=release(g,o,stoppedheld,'throw',True)
 t['highHOLPThrow']=throw
 t['queries']={n:probe(g,o,thrown,p)for n,p in [('oldFloor',[6100,331,3380]),('newHighActor',[-1849,25080,-939])]}
 g.load_state(thrown);e=[];write(g,o,'gTimeStopState',0,e);t['resume']=dict(edits=e,initial=snapshot(g,o))
 for _ in range(3):step(g,o,t['resume'])
 result['nativeCloneTimeStop']=t
 return result
def check(r):
 cases={t['name']:t for t in r['trials']}
 assert [s['floorOwner']for s in cases['live-moved']['samples']]==[13]*3
 assert [s['floorY']for s in cases['live-moved']['samples']]==[25100.0]*3
 assert cases['live-cached-transform']['samples'][0]['floorOwner']==-1
 assert cases['live-cached-transform']['samples'][1]['floorOwner']==13
 assert cases['live-cached-transform']['samples'][0]['surfaces']==cases['live-cached-transform']['initial']['surfaces']
 assert cases['live-cached-transform']['samples'][0]['box']['throwMatrix']=='null'
 for old,new in zip(cases['live-moved']['initial']['surfaces'],cases['live-moved']['samples'][0]['surfaces']):
  for k in ['vertex1','vertex2','vertex3']:assert [b-a for a,b in zip(old[k],new[k])]==[400,100,0]
 assert all(s['surfaceCount']==0 for s in cases['frozen-normal']['samples'])
 for t in [cases['frozen-time-stop'],r['nativeCloneTimeStop']]:
  assert all(s['surfaceCount']==12 for s in t['samples'])
  assert all(s['surfaces']==t['initial']['surfaces'] and s['boxPartitionLinks']==t['initial']['boxPartitionLinks'] for s in t['samples'])
  assert all(s['surfaceCount']==0 for s in t['resume']['samples'])
 assert all(s['surfaceCount']==0 for s in cases['frozen-time-stop-before-loading']['samples'])
 assert cases['frozen-time-stop']['queries']['old']['samples'][0]['floorOwner']==13
 assert cases['frozen-time-stop']['queries']['new']['samples'][0]['floorOwner']==-1
 t=r['nativeCloneTimeStop'];assert all(s['surfaceCount']==12 for s in t['highHOLPThrow']['samples'])
 assert all(s['surfaces']==t['initial']['surfaces'] and s['boxPartitionLinks']==t['initial']['boxPartitionLinks'] for s in t['highHOLPThrow']['samples'])
 assert t['queries']['oldFloor']['samples'][0]['floorOwner']==13
 assert t['queries']['newHighActor']['samples'][0]['floorOwner']!=13
 for t in r['normalReleases']:assert all(s['surfaceCount']==0 for s in t['samples'])
def count(x):
 if isinstance(x,dict):return len(x.get('samples',[]))+sum(count(v)for k,v in x.items()if k!='samples')
 if isinstance(x,list):return sum(count(v)for v in x)
 return 0
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--verify',type=Path);p.add_argument('--output',type=Path,default=HERE/'results.json.gz');a=p.parse_args()
 g,o,b=roots();r=run(g,o,b);check(r)
 q,qo,qb=roots();qr=run(q,qo,qb);check(qr);assert qr==r
 out=dict(schema=1,scope=__doc__,proofRevision='97d870c2d208f8adeb5bae88993d84ee4a9f9f6a',runtimeSha256=sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),prefixSha256=sha(ROOT/'instrumentation/ink-high-item-nudge/prefix.jsonl.gz'),startupGrant=dict(gDebugLevelSelect=1),freshVerifiedBoundaries=count(r),results=r)
 if a.verify:assert json.loads(gzip.decompress(a.verify.read_bytes()))==out
 else:
  assert not a.output.exists();a.output.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
 print('PASS independent roots and exact artifact',count(r),'update boundaries',flush=True)
 print('native pickup: reference cut',r['conditionalNativePickup']['usedReferenceCut']['afterUpdate'],'grab',r['conditionalNativePickup']['grabUpdate'])
 for t in r['trials']:print(t['name'],[(s['surfaceCount'],s['floorY'],s['floorOwner'])for s in t['samples']])
 print('time-stop high throw:',r['nativeCloneTimeStop']['highHOLPThrow']['samples'][-1]['box']['position'])
 print('old/new floor queries:',[(n,t['samples'][0]['floorY'],t['samples'][0]['floorOwner'])for n,t in r['nativeCloneTimeStop']['queries'].items()])
if __name__=='__main__':main()
