"""Native Crazy Box drop from explicit carrying/HOLP grants, then Ink test.

The carrying pose, held pointer and HOLP are supplied, not reached gameplay.
Z126 performs the actual release. After neutral127 only Mario is relocated
to the existing air seed128. No actor field is edited after the release.
"""
import argparse,gzip,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('controlled_box_shared',ROOT/'instrumentation/ink-enlarged-bob-handoff/search.py')
h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h);r=h.r;iso=h.iso
BOX=[-2102.720703125,1839.447265625,-1119.5618896484375]
BOB=[-2080.06005859375,1809.2066650390625,-1230.322021484375]
def write(g,o,path,value,edits):
 def cv(v):return iso.ptr(g,o,v)if hasattr(v,'is_null')else v
 edits.append(dict(path=path,before=cv(g.read(path)),after=cv(value)));g.g.write(path,value)
def mario_cut(g,o,pos,action,edits):
 for path,value in [('gMarioState.pos',pos),('gMarioObject.header.gfx.pos',pos)]+[('gMarioObject.oPos'+a,v)for a,v in zip('XYZ',pos)]:write(g,o,path,value,edits)
 for k,v in [('action',g.constant(action)),('actionState',0),('actionTimer',0),('actionArg',0),('vel',[0,-16,0]),('forwardVel',0),('faceAngle',[0,0,0])]:write(g,o,'gMarioState.'+k,v,edits)
def snap(g,o):
 s=r.snapshot(g,o,True);s['boxFloorY']=g.read('gObjectPool[49].oFloorHeight');s['boxMoveFlags']=g.read('gObjectPool[49].oMoveFlags');s['bobFuse']=g.read('gObjectPool[39].oBobombFuseTimer');return s
def advance(g,o,pad):r.advance(g,o,pad,True);return snap(g,o)
def trial(g,o,states,prep,y):
 g.load_state(states['released91',126]);edits=[]
 edits.extend(r.place(g,39,BOB));edits.extend(r.place(g,71,[-1960,19890,-1230]))
 mario_cut(g,o,[5900,y,3440],'ACT_HOLD_FREEFALL',edits)
 write(g,o,'gMarioState.heldObj',g.address('gObjectPool[49]'),edits)
 write(g,o,'gObjectPool[49].oHeldState',g.constant('HELD_HELD'),edits)
 write(g,o,'gMarioState.marioBodyState.heldObjLastPosition',[BOX[0],y,BOX[2]],edits)
 before=snap(g,o);release=advance(g,o,iso.Z);releaseEvents=iso.frame_events(g)
 assert release['held']==-1 and release['actors']['49']['oHeldState']==0 and release['actors']['49']['oAction']==1
 wait=advance(g,o,iso.NEUTRAL);assert g.read('gObjectPool[61].oTimer')==128
 airEdits=[];mario_cut(g,o,[-1960,19900,-1230],'ACT_FREEFALL',airEdits)
 assert all(not e['path'].startswith('gObjectPool[')for e in airEdits)
 airBefore=snap(g,o);samples=[advance(g,o,iso.Z)];events=[iso.frame_events(g)];controls=[iso.Z];forks=[]
 for _ in range(39):
  if samples[-1]['area']!=1:break
  if g.read('gObjectPool[61].oTimer')==130:forks.append(dict(phase=130,result=h.shadow(g,o)))
  samples.append(advance(g,o,iso.NEUTRAL));events.append(iso.frame_events(g));controls.append(iso.NEUTRAL)
 captured=False;retained=True
 for s in samples:
  if s['used']==64 and s['platform']==s['floorOwner']==61:captured=True
  if captured and s['area']==1 and s['platform']!=61:retained=False
 useful=samples[-1]['area']==2 and samples[-1]['M']==[365.5927734375,5500,-1096.8026123046875]
 return dict(releaseY=y,profileInstall=prep['installs']['released91:126'],setupEdits=edits,beforeRelease=before,releaseInput=iso.Z,release=release,releaseEvents=releaseEvents,waitInput=iso.NEUTRAL,afterWait=wait,airEdits=airEdits,beforeAir=airBefore,controls=controls,samples=samples,events=events,diagnosticForks=forks,capture=captured,retainedObserved=retained if captured else None,useful=useful)
def run(edges=False):
 g,o,states,prep=h.roots();trials=[trial(g,o,states,prep,y)for y in ([1600,2013,2014]if edges else[1799,1870,1920,1950,2010])]
 return dict(preparation=prep,trials=trials)
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');ap.add_argument('--edges',action='store_true');a=ap.parse_args();data=run(a.edges);fresh=run(a.edges);assert data==fresh
 result=dict(schema=1,scope=__doc__,independentFreshReconstructions=2,allAReleased=True,actorWritesAfterNativeDrop=[],results=data)
 path=HERE/('edge-results.json.gz'if a.edges else'results.json.gz');raw=(json.dumps(result,separators=(',',':'))+'\n').encode()
 if a.verify:assert json.loads(gzip.decompress(path.read_bytes()))==json.loads(raw)
 else:assert not path.exists();path.write_bytes(gzip.compress(raw,mtime=0))
 for t in data['trials']:
  print('DROP',t['releaseY'],'native',t['release']['actors']['49']['position'],'capture',t['capture'],'useful',t['useful'],'arrival',t['samples'][-1]['M'],flush=True)
  for phase,s in [(126,t['release']),(127,t['afterWait'])]+[(128+i,s)for i,s in enumerate(t['samples'][:4])]:print(phase,'M',s['M'],'action',s['actionName'],'held',s['held'],'Box',s['actors']['49']['position'],'active',s['actors']['49']['activeFlags'],'action',s['actors']['49']['oAction'],'collisions',s['collisions'],flush=True)
 print('PASS',len(data['trials']),'actual native drops, two fresh roots; no actor edits after drop')
if __name__=='__main__':main()
