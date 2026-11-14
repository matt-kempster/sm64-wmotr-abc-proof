"""High live-solid landing, native B dive, then item nudge: supplied poses, no ground action."""
import argparse,gzip,hashlib,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
sys.path.insert(0,str(ROOT/'instrumentation/ink-high-action-entry'))
from prelude import roots as oldroots,advance,NEUTRAL,pose,write,rich_sample,frame_events
sys.path.insert(0,str(ROOT/'instrumentation/ink-item-clone-controls'))
from fixtures import actor_snapshot,place_actor
B=dict(buttons=0x4000,stick=[0,0])
class Guard:
 def __init__(self,g,slot):self.g=g;self.slot=slot;self.mode='controls';self.support=13
 def __getattr__(self,k):return getattr(self.g,k)
 def write(self,p,v):
  allowed={'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'}
  if self.mode in ['setup','actor']:
   allowed|={f'gObjectPool[{s}].oPos'+a for s in [self.support,49,self.slot]for a in 'XYZ'}
  if self.mode=='setup':
   allowed|={'gMarioState.pos','gMarioObject.header.gfx.pos'}|{'gMarioObject.oPos'+a for a in 'XYZ'}
   allowed|={'gMarioState.'+k for k in ['action','actionState','actionTimer','forwardVel','vel','faceAngle']}
   if self.clone:allowed|={f'gObjectPool[{self.support}].'+k for k in ['parentObj','curBhvCommand','bhvStackIndex']}
  assert p in allowed,p
  self.g.write(p,v)
def root():
 src=ROOT/'instrumentation/ink-high-item-nudge/prefix.jsonl.gz';raw=gzip.decompress(src.read_bytes())
 assert hashlib.sha256(raw).hexdigest()=='9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72'
 p=ROOT/'build/high-solid-prefix.jsonl'
 if p.exists():assert p.read_bytes()==raw
 else:p.write_bytes(raw)
 g,o,states,slot,prep=oldroots(p)
 return Guard(g.g,slot),o,states,prep
def place(g,slot,xyz,edits):
 for a,v in zip('XYZ',xyz):write(g,f'gObjectPool[{slot}].oPos'+a,v,edits)
def snap(g,o):
 if g.read('gMarioObject').is_null():return dict(marioPresent=False,area=g.read('gCurrAreaIndex'))
 s=rich_sample(g,o);s['marioPresent']=True;s['topNative']=g.read('gObjectPool[61].behavior')==g.address('bhvPyramidTop')
 s['support']=actor_snapshot(g,g.support);s['shell']=actor_snapshot(g,g.slot);s['box']=actor_snapshot(g,49)
 s['supportAngles']=[g.read(f'gObjectPool[{g.support}].oFaceAngle'+a)for a in ['Pitch','Yaw','Roll']]
 s['supportDistance']=g.read(f'gObjectPool[{g.support}].oDistanceToMario')
 s['ridden']=o.slot(g.read('gMarioState.riddenObj'))
 s['supportSurfaceCount']=sum(g.read(f'sSurfacePool[{i}].object')==g.address(f'gObjectPool[{g.support}]')for i in range(g.read('gNumStaticSurfaces'),g.read('gSurfacesAllocated')))
 return s
def trial(g,o,states,r):
 g.load_state(states[129]);g.support=r.get('slot',13);g.clone=r.get('clone',False);g.mode='setup';edits=[];H=r.get('height',25000)
 pose(g,[-1950,H+1,-939],edits)
 for k,v in [('action',g.constant('ACT_FREEFALL')),('actionState',0),('actionTimer',0),('forwardVel',32),('vel',[32,-16,0]),('faceAngle',[0,16384,0])]:write(g,'gMarioState.'+k,v,edits)
 xyz=[-1950+r.get('halfWidth',100)+r['edge'],H-r.get('meshHeight',200),-939]
 if g.clone:place_actor(g,g.support,xyz,edits,'carry_clone')
 else:place(g,g.support,xyz,edits)
 g.mode='controls'
 before=snap(g,o);rows=[];events=[];pads=[];cuts=[]
 for i in range(35):
  if i==1:
   g.mode='actor';e=[];p=g.read('gMarioState.pos');kind=r.get('pusher','shell')
   if r.get('remove'):place(g,g.support,[6000,0,6000],e)
   if kind!='none':place(g,g.slot if kind=='shell' else 49,[p[0]-(21 if kind=='shell' else 39),p[1],p[2]],e)
   g.mode='controls';cuts.append(dict(update=i+1,edits=e))
  pad=B if i==0 else NEUTRAL;advance(g,pad);s=snap(g,o);rows.append(s);events.append(frame_events(g));pads.append(pad)
  if not s['marioPresent']or s['area']!=1:break
 arrival=next((s for s in rows if s['area']==2),None)
 return dict(recipe=r,edits=edits,before=before,cuts=cuts,samples=rows,events=events,controls=pads,capture=any(s.get('topNative')and s['used']==64 and s['floorOwner']==s['platform']==61 for s in rows),useful=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717))
def main():
 parser=argparse.ArgumentParser(description=__doc__)
 parser.add_argument('--verify',type=Path,help='compare complete independently reproduced artifact without overwriting it')
 parser.add_argument('--output',type=Path,default=HERE/'results.json.gz')
 args=parser.parse_args()
 g,o,states,prep=root()
 print('INVENTORY',[(i,actor_snapshot(g,i),[g.read(f'gObjectPool[{i}].oFaceAngle'+a)for a in ['Pitch','Yaw','Roll']])for i in range(240)if g.read(f'gObjectPool[{i}].activeFlags')and g.read(f'gObjectPool[{i}].behavior')in[g.address('bhvBreakableBox'),g.address('bhvToxBox')]],flush=True)
 recipes=[dict(edge=e,pusher=p)for e in [1,4,8]for p in ['shell','crazy','none']]
 recipes += [dict(edge=1,pusher='shell',height=67277),dict(edge=1,pusher='shell',slot=59,halfWidth=255,meshHeight=256),dict(edge=1,pusher='shell',slot=60,halfWidth=255,meshHeight=256),dict(edge=1,pusher='shell',clone=True)]
 trials=[]
 for r in recipes:
  t=trial(g,o,states,r);trials.append(t)
  print(r,[(s['topTimer'],s['actionName'],s['movement'],s['display'][1],s['floorY'],s['floorOwner'])for s in t['samples'][:3]],'capture',t['capture'],'useful',t['useful'],flush=True)
 q,qo,qs,qprep=root();assert qprep==prep
 for t in trials:
  assert trial(q,qo,qs,t['recipe'])==t,t['recipe']
  print('FRESH VERIFIED',t['recipe'],flush=True)
 result=dict(schema=1,preparation=prep,trials=trials,freshVerifiedTrials=len(trials),freshVerifiedBoundaries=sum(len(t['samples'])for t in trials))
 if args.verify:
  assert result==json.loads(gzip.decompress(args.verify.read_bytes()))
  print('VERIFIED complete artifact',args.verify,flush=True)
 else:
  assert not args.output.exists();args.output.write_bytes(gzip.compress((json.dumps(result,separators=(',',':'))+'\n').encode(),mtime=0))
if __name__=='__main__':main()
