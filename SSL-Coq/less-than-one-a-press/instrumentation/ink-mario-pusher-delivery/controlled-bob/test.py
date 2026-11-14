"""Conditional native Bob release, then established high shell entry.

This explicitly supplies a carrying/throwing state, held donor fields and HOLP.
It is release compatibility, NOT controller-reached delivery. No Bob field is
edited after the carrying setup; all release and subsequent motion is native.
"""
import argparse,gzip,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def module(name,path):
 sp=importlib.util.spec_from_file_location(name,ROOT/path);m=importlib.util.module_from_spec(sp);sp.loader.exec_module(m);return m
n=module('controlled_bob_native','instrumentation/ink-enlarged-bob-target/native.py');r=n.r
BOB=[-2080.06005859375,1809.2066650390625,-1230.322021484375]
BOX=[-2102.720703125,1839.447265625,-1119.5618896484375]

def snap(g,o):
 s=r.snapshot(g,o,True);s['bobFuse']=g.read('gObjectPool[39].oBobombFuseTimer');s['bobFloor']=g.read('gObjectPool[39].oFloorHeight');return s

def grant(g,o,path,value,edits):
 cv=lambda v:r.iso.ptr(g,o,v)if hasattr(v,'is_null')else v
 edits.append(dict(path=path,before=cv(g.read(path)),after=cv(value)));g.g.write(path,value)

def held_setup(g,o,fields,kind,mario_pos=None):
 e=[];assert g.read('gObjectPool[39].behavior')==g.address('bhvBobomb')
 for k,v in fields.items():grant(g,o,'gObjectPool[39].'+k,v,e)
 p=mario_pos or[-2200,BOB[1],-1075]
 for k,v in [('gMarioState.pos',p),('gMarioObject.header.gfx.pos',p)]+[('gMarioObject.oPos'+a,v)for a,v in zip('XYZ',p)]:grant(g,o,k,v,e)
 for k,v in [('action',g.constant('ACT_HOLD_IDLE'if kind=='drop'else'ACT_THROWING')),('actionState',0),('actionTimer',0 if kind=='drop'else 6),('vel',[0,0,0]),('forwardVel',0),('faceAngle',[0,0,0]),('heldObj',g.address('gObjectPool[39]')),('usedObj',g.address('gObjectPool[39]'))]:grant(g,o,'gMarioState.'+k,v,e)
 grant(g,o,'gMarioObject.oInteractStatus',8,e)
 holp=[BOB[0],BOB[1],BOB[2]-(32 if kind=='throw'else 0)]
 grant(g,o,'gMarioState.marioBodyState.heldObjLastPosition',holp,e)
 # Supplied near-Mario carried body; native release overwrites XYZ.
 for a,v in zip('XYZ',[p[0],p[1]+60,p[2]+100]):grant(g,o,'gObjectPool[39].oPos'+a,v,e)
 return e

def trial(g,o,states,fields,kind,box=True):
 g.load_state(states[127]);edits=held_setup(g,o,fields,kind);before=snap(g,o)
 r.advance(g,o,full=True);released=snap(g,o);events=r.iso.frame_events(g)
 assert released['held']==-1 and g.read('gObjectPool[39].oHeldState')==0
 box_edits=r.place(g,49,BOX)if box else[]
 entry=r.seed(g,o,{128:g.save_state()},dict(phase=128,xz=[-1960,-1230],speed=0),True)
 rows=[snap(g,o)];controls=[r.iso.Z];history_events=[entry['events']]
 for _ in range(44):
  r.advance(g,o,full=True);rows.append(snap(g,o));controls.append(r.iso.NEUTRAL);history_events.append(r.iso.frame_events(g))
  if rows[-1]['area']!=1:break
 arrival=next((x for x in rows if x['area']==2),None)
 return dict(kind=kind,boxPlaced=box,carryingSetupEdits=edits,beforeRelease=before,releaseControl=r.iso.NEUTRAL,
  afterRelease=released,releaseEvents=events,boxPlacementBeforeHighEntry=box_edits,highEntry=entry,
  laterGameplayEdits=[],controls=controls,samples=rows,events=history_events,
  capture=any(x['used']==64 and x['floorOwner']==x['platform']==61 for x in rows),
  arrival=arrival,useful=arrival is not None and arrival['M']==[365.5927734375,5500,-1096.8026123046875])

def run():
 dg,do,donor=n.profile.donor();held=n.profile.detailed(dg,do)
 assert held['profile']['oHeldState']==1 and held['profile']['hitboxRadius']==91
 g,o,states,prep=r.roots();trials=[trial(g,o,states,held['profile'],kind,box)for kind,box in [('drop',True),('throw',True),('throw',False)]]
 return dict(commonRootPreparation=prep,nativeHeldDonor=dict(preparation=donor,snapshot=held),trials=trials)

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args()
 data=run();assert data==run()
 result=dict(schema=1,scope=__doc__,runtimeSha256=r.sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),independentlyVerified=True,results=data)
 out=HERE/'results.json.gz'
 if a.verify:assert result==json.loads(gzip.decompress(out.read_bytes()))
 else:assert not out.exists();out.write_bytes(gzip.compress((json.dumps(result,separators=(',',':'))+'\n').encode(),mtime=0))
 for t in data['trials']:
  a=t['afterRelease']['actors']['39'];print(t['kind'],t['boxPlaced'],'released',a,'fuse',t['afterRelease']['bobFuse'],'capture',t['capture'],'useful',t['useful'],'arrival',t['arrival']['M']if t['arrival']else None,flush=True)
 print('PASS three twice-fresh controlled real-release histories',flush=True)
if __name__=='__main__':main()
