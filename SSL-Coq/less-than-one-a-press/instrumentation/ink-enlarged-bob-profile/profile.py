"""Native enlarged Bob-omb donor and explicitly conditional profile transplant.

The donor is the first 616 controls of the established clean regrab witness.
Native callbacks remain enabled. No radius, scale, fuse or action is invented;
any receiving-world donor field copy is separately recorded as a setup grant.
"""
import argparse,gzip,hashlib,importlib.util,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from replay import create_game,Observer
from ink_box_delivery import advance
from ink_handsfree_teleport import snap as base_snap,actor
NEUTRAL=dict(buttons=0,stick=[0,0])
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def donor():
 p=ROOT/'instrumentation/wafel-jp-pilot/ink-bobomb-regrab-transport-inputs.jsonl'
 assert sha(p)=='5fbabbad20efe0353072ac401279b81cc696415dd87621d905755b8dcf3e641b'
 pads=[json.loads(x)for x in p.read_text().splitlines()][:616]
 g=create_game();o=Observer(g)
 for pad in pads:advance(g,pad)
 s=base_snap(g,o,[39]);assert s['held']==39 and s['actors'][0]['hitboxRadius']==91 and s['actors'][0]['fuse']==158
 return g,o,dict(inputs=616,sha256=sha(p),controls=pads,initial=s)
def detailed(g,o):
 s=base_snap(g,o,[39]);p='gObjectPool[39].'
 s['profile']={k:g.read(p+k)for k in ['oAction','oPrevAction','oTimer','oHeldState','oBobombFuseTimer','oBobombFuseLit','oBobombBlinkTimer','oFlags','oIntangibleTimer','oInteractStatus','oInteractionSubtype','oInteractType','oMoveFlags','oVelX','oVelY','oVelZ','oForwardVel','oMoveAnglePitch','oMoveAngleYaw','oMoveAngleRoll','oFaceAnglePitch','oFaceAngleYaw','oFaceAngleRoll','oGravity','oFriction','oBuoyancy','oAnimState','header.gfx.scale','header.gfx.node.flags','hitboxRadius','hitboxHeight','hitboxDownOffset','hurtboxRadius','hurtboxHeight']}
 return s
def lifecycle():
 g,o,prep=donor();rows=[detailed(g,o)]
 for i in range(30):
  advance(g,NEUTRAL);rows.append(detailed(g,o))
  if not rows[-1]['actors'][0]['activeFlags']:break
 return dict(preparation=prep,controls=[NEUTRAL]* (len(rows)-1),samples=rows)
def native_profiles():
 """Return actual free donor boundaries. This function does not edit gameplay."""
 r=lifecycle();a=r['samples'][12];b=r['samples'][18]
 assert a['held']==-1 and a['profile']['oHeldState']==0 and a['profile']['hitboxRadius']==91
 assert b['held']==-1 and b['profile']['oHeldState']==0 and b['profile']['hitboxRadius']==117
 return dict(preparation=r['preparation'],profiles={name:dict(name=name,donorCompletedInputs=616+n,donorSnapshot=s,fields=s['profile'])for name,n,s in [('released91',12,a),('terminal117',18,b)]},lifecycle=r)
def command_index(g,slot):
 v=g.read(f'gObjectPool[{slot}].curBhvCommand')
 return next(i for i in range(64)if v==g.address(f'bhvBobomb[{i}]'))
def install_profile(g,o,profile,slot=39):
 """Explicit conditional scalar-field transplant; no behavior/fuse freeze.

Call on the underlying Game BEFORE the initial airborne Mario setup. The
recipient keeps its real allocated slot, home/XYZ, parent, behavior and native
command. Donor position, cached floor pointers and other actors are not copied.
Every copied field, including hitbox and scale, is a disclosed setup write.
"""
 p=f'gObjectPool[{slot}].';assert g.read(p+'behavior')==g.address('bhvBobomb')
 assert g.read(p+'activeFlags') and profile['donorSnapshot']['actors'][0]['activeFlags']
 assert profile['fields']['oHeldState']==0
 before=actor(g,slot);cmd=command_index(g,slot);writes=[];checks={}
 for k,v in profile['fields'].items():
  if k in ['oInteractType','oInteractionSubtype']:
   assert g.read(p+k)==v;checks[k]=v;continue
  writes.append(dict(path=p+k,before=g.read(p+k),after=v));g.write(p+k,v)
 assert command_index(g,slot)==cmd and g.read(p+'behavior')==g.address('bhvBobomb')
 return dict(kind='Conditional transplant of exact native donor scalar fields, not joined delivery',profile=profile['name'],donorCompletedInputs=profile['donorCompletedInputs'],before=before,writes=writes,retainedNativeInteractionFields=checks,nativeBobombCommandIndex=cmd,after=actor(g,slot))
def main():
 r=lifecycle();q=lifecycle();assert r==q
 for n,s in enumerate(r['samples']):
  a=s['actors'][0];print(n,'Maction',hex(s['action']),'held',s['held'],'Bob',a['oHeldState'],a['oAction'],a['oTimer'],'fuse',a['fuse'],'radius',a['hitboxRadius'],'scale',a['scale'][0],'active',a['activeFlags'],flush=True)
 out=HERE/'lifecycle.json.gz';assert not out.exists();out.write_bytes(gzip.compress((json.dumps(r,separators=(',',':'))+'\n').encode(),mtime=0))
if __name__=='__main__':main()
