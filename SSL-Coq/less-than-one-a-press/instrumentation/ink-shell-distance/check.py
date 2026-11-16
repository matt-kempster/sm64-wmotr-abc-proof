"""Finite native shell distance controls; clone freeze is not distance sleep.

Shells are genuinely initialized, and the frozen shell uses the existing
conditional native fake-pickup/release sequence. All Mario distance/approach
poses are supplied; no actor flags, type, hitbox or status is manufactured.
"""
import argparse,gzip,importlib.util,json,math
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
sp=importlib.util.spec_from_file_location('distance_shell_iso',ROOT/'instrumentation/ink-shell-clone-isolation/test.py')
iso=importlib.util.module_from_spec(sp);sp.loader.exec_module(iso)

def snapshot(g,o,slot):
 s=iso.snap(g,o,slot);p=f'gObjectPool[{slot}].'
 s['shell'].update({k:g.read(p+k)for k in ['oDrawingDistance','oDistanceToMario','oRoom','oFaceAngleYaw','oMoveFlags','oFloorHeight']})
 s['shell']['graphFlags']=g.read(p+'header.gfx.node.flags')
 s['shell']['distanceM']=math.dist(s['shell']['position'],s['M'])
 s['shell']['distanceC']=math.dist(s['shell']['position'],s['C'])
 s['shell']['distanceG']=math.dist(s['shell']['position'],s['G'])
 return s

def pose(g,o,position,edits,parts=None):
 iso.mario(g,o,position,edits,action='ACT_DISAPPEARED',speed=0)
 for part,value in (parts or {}).items():
  paths={'M':['gMarioState.pos'],'C':['gMarioObject.oPos'+a for a in 'XYZ'],'G':['gMarioObject.header.gfx.pos']}[part]
  for i,path in enumerate(paths):iso.write(g,o,path,value if len(paths)==1 else value[i],edits)

def wait_case(g,o,slot,state,mode,name,delta,steps=30,parts=None):
 g.load_state(state);p=snapshot(g,o,slot)['shell']['position'];target=[p[i]+delta[i]for i in range(3)];edits=[]
 split={k:[p[i]+d[i]for i in range(3)]for k,d in (parts or {}).items()}
 pose(g,o,target,edits,split)
 initial=snapshot(g,o,slot);samples=[]
 for _ in range(steps):
  iso.advance(g,iso.NEUTRAL);samples.append(snapshot(g,o,slot));assert not samples[-1]['input']&0x82
 return dict(mode=mode,name=name,setupEdits=edits,initial=initial,controls=[iso.NEUTRAL]*steps,samples=samples),g.save_state()

def projection(s):
 a=s['shell'];return {k:a[k]for k in ['position','oVelX','oVelY','oVelZ','oForwardVel','oAction','oTimer','oFaceAngleYaw','oIntangibleTimer','oInteractStatus','oFlags','activeFlags','oDistanceToMario','graphFlags']}

def run():
 g,o,slot,live,prep=iso.roots();pick,held=iso.pickup(g,o,slot,live)
 drop,frozen=iso.release(g,o,slot,held,'drop');throw,high=iso.release(g,o,slot,held,'throw',67277)
 menu=[('near',[400,0,0]),('1999',[1999,0,0]),('2000',[2000,0,0]),('2001',[2001,0,0]),
       ('3999',[3999,0,0]),('4000',[4000,0,0]),('4001',[4001,0,0]),('far-x',[65536,0,0]),('far-y',[0,65536,0])]
 trials=[]
 for mode,state in [('live',live),('frozen',frozen)]:
  for name,delta in menu:trials.append(wait_case(g,o,slot,state,mode,name,delta)[0])
  for part in ['M','C','G']:
   trials.append(wait_case(g,o,slot,state,mode,'split-'+part,[400,0,0],parts={part:[65536,0,0]})[0])
  mode_trials=[t for t in trials if t['mode']==mode]
  expected=[projection(s)for s in mode_trials[0]['samples']]
  for t in mode_trials:assert [projection(s)for s in t['samples']]==expected,(mode,t['name'])
  for t in mode_trials:
   assert all(s['shell']['activeFlags']&1 and not s['shell']['activeFlags']&2 for s in t['samples'])
   assert all(s['shell']['oFlags']==0x40000001 and s['shell']['oDistanceToMario']==19000 for s in t['samples'])
 delayed=[]
 for name,delta in [('near-high',[400,0,0]),('far-high',[65536,65536,0])]:
  t,end=wait_case(g,o,slot,high,'frozen-high',name,delta,steps=180)
  p=t['samples'][-1]['shell']['position'];assert p==[-1950.0,67267.0,-939.0]
  mount,_=iso.mount(g,o,slot,end,67277,True,steps=4)
  assert slot in mount['samples'][0]['collisions']
  assert any(e['type']=='FLT_CHANGE_ACTION'and e.get('to')==g.constant('ACT_RIDING_SHELL_GROUND')for e in mount['events'][0])
  assert any(e['type']=='FLT_CHANGE_ACTION'and e.get('to')==g.constant('ACT_CROUCH_SLIDE')for e in mount['events'][0])
  delayed.append(dict(wait=t,mount=mount))
 return dict(preparation=prep,pickup=pick,nativeDrop=drop,nativeHighThrow=throw,trials=trials,delayedMounts=delayed)

def main():
 p=argparse.ArgumentParser();p.add_argument('--verify',action='store_true');a=p.parse_args()
 first=run();second=run();assert first==second
 out=dict(schema=1,scope=__doc__,proofStart='4adf8faf311d1d271c57f288f51b06bf357874d1',runtimeSha256=iso.sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),independentFreshReconstructions=2,results=first)
 target=HERE/'results.json.gz';raw=(json.dumps(out,separators=(',',':'))+'\n').encode()
 if a.verify:assert json.loads(gzip.decompress(target.read_bytes()))==json.loads(raw)
 else:assert not target.exists();target.write_bytes(gzip.compress(raw,mtime=0))
 for mode in ['live','frozen']:
  t=next(t for t in first['trials']if t['mode']==mode)
  print(mode,'first',t['initial']['shell']['position'],'last',t['samples'][-1]['shell']['position'],'timer',t['initial']['shell']['oTimer'],t['samples'][-1]['shell']['oTimer'],'flags',t['samples'][-1]['shell']['oFlags'],flush=True)
 print('PASS 24 distance/split controls x30 updates, two delayed180+4 high mounts; exact shell projection agrees near/far',flush=True)
if __name__=='__main__':main()
