"""Native shell remote throws from initialized/frozen/live pending-pickup cases.

Only HOLP is changed during each real throw. Later Mario contact poses are
separate grants. No shell XYZ, interaction type, hitbox, status or script is
written after the native pending-slot acquisition.
"""
import argparse,gzip,importlib.util,json,struct
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def mod(name,path):
 s=importlib.util.spec_from_file_location(name,ROOT/path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
p=mod('remote_pending','instrumentation/ink-shell-delivery/pending_slot.py')
iso=mod('remote_iso','instrumentation/ink-shell-clone-isolation/test.py')
def f32(x):return struct.unpack('<f',struct.pack('<f',x))[0]
def edit(g,o,path,value,rows):
 cv=lambda x:iso.ptr(g,o,x)if hasattr(x,'is_null')else x
 rows.append(dict(path=path,before=cv(g.read(path)),after=cv(value)));g.write(path,value)
def snap(g,o,slot):return iso.snap(g,o,slot)
def advance(g,o,slot,t,pad):
 iso.advance(g,pad);assert not g.read('gMarioState.input')&0x82
 t.setdefault('controls',[]).append(pad);t.setdefault('samples',[]).append(snap(g,o,slot));t.setdefault('events',[]).append(iso.frame_events(g))
 return t['samples'][-1]
def release(g,o,state,target,kind='throw'):
 g.load_state(state);slot=23;t=dict(target=target,kind=kind,initial=snap(g,o,slot),edits=[])
 changed=False
 for i in range(24):
  if not changed and ((kind=='throw'and g.read('gMarioState.action')==g.constant('ACT_THROWING')and g.read('gMarioState.actionTimer')==6)or(kind=='drop'and i==0)):
   yaw=g.read('gMarioState.faceAngle[1]')&65535
   if kind=='throw':
    sine=g.read('gSineTable[%d]'%(yaw>>4));cosine=g.read('gSineTable[%d]'%((yaw>>4)+1024))
    holp=[f32(target[0]-f32(32*sine)),target[1],f32(target[2]-f32(32*cosine))]
   else:holp=target
   edit(g,o,'gMarioState.marioBodyState.heldObjLastPosition',holp,t['edits']);t['holpCutBeforeUpdate']=i+1;changed=True
  s=advance(g,o,slot,t,(p.B if kind=='throw'else p.Z)if i==0 else p.N)
  if s['held']==-1 and 'releaseUpdate'not in t:t['releaseUpdate']=i+1
 assert changed and 'releaseUpdate'in t
 return t,g.save_state()
def contact(g,o,state,xyz,z):
 g.load_state(state);e=[];iso.mario(g,o,xyz,e,speed=0)
 iso.write(g,o,'gMarioState.vel',[0,-16,0],e);iso.write(g,o,'gMarioState.faceAngle',[0,0,0],e)
 t=dict(edits=e,z=z,initial=snap(g,o,23))
 for i in range(4):advance(g,o,23,t,p.Z if z and i==0 else p.N)
 t['mountEvents']=sum(any(x['type']=='FLT_CHANGE_ACTION'and x.get('to')==g.constant('ACT_RIDING_SHELL_GROUND')for x in es)for es in t['events'])
 t['slideEvents']=sum(any(x['type']=='FLT_EXECUTE_ACTION'and x.get('action')in[g.constant('ACT_BUTT_SLIDE'),g.constant('ACT_CROUCH_SLIDE')]for x in es)for es in t['events'])
 return t
def targets():
 return [('low1810',[-1962.4404296875,1800,-1243.34130859375]),('high25000',[-1950,24990,-939]),('vpu67277',[-1950,67267,-939]),('puplus',[63586,24990,-939]),('puminus',[-67486,24990,-939]),('negativevpu',[-1950,-40746,-939])]
def run():
 guarded,o,base,prep=p.root();g=guarded.g;trials=[]
 for spawn in [5,6,7]:
  pickup=p.trial(guarded,o,base,897,spawn);held=g.save_state()
  assert o.slot(g.read('gMarioState.heldObj'))==23
  for name,target in targets():
   rel,state=release(g,o,held,target);pos=rel['samples'][-1]['shell']['position']
   mounts=[contact(g,o,state,[pos[0],pos[1]+10,pos[2]],z)for z in [False,True]]
   trials.append(dict(spawnStep=spawn,targetName=name,pickup=pickup,release=rel,contacts=mounts))
  rel,state=release(g,o,held,[-1950,67267,-939],'drop')
  trials.append(dict(spawnStep=spawn,targetName='highHOLP-drop-control',pickup=pickup,release=rel,contacts=[]))
 return dict(preparation=prep,trials=trials)
def check(results):
 for t in results['trials']:
  initialized=t['spawnStep']!=6;r=t['release'];last=r['samples'][-1]['shell']
  assert last['command']==('bhvCarrySomething5[1]'if r['kind']=='throw'else'bhvCarrySomething4[1]')
  assert last['behavior']=='bhvKoopaShell'and last['activeFlags']&1
  assert last['oInteractType']==(524288 if initialized else 0)
  assert last['oIntangibleTimer']==(0 if initialized else -1)
  assert last['hitboxRadius']==50 and last['hitboxHeight']==(50 if initialized else 100)
  want=r['target']if r['kind']=='throw'else[r['target'][0],0,r['target'][2]]
  assert last['position']==want
  assert all(s['shell']['position']==want for s in r['samples'][r['releaseUpdate']-1:])
  for c in t['contacts']:
   assert c['mountEvents']==int(initialized)
   assert (23 in c['samples'][0]['collisions'])==initialized
   assert c['slideEvents']==int(initialized and c['z']and t['targetName']!='negativevpu')
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args();first=run();second=run();assert first==second;check(first)
 out=dict(schema=1,scope=__doc__,proofStart='4adf8faf311d1d271c57f288f51b06bf357874d1',runtimeSha256=iso.sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),independentFreshRoots=2,results=first)
 dst=HERE/'results.json.gz';raw=(json.dumps(out,separators=(',',':'))+'\n').encode()
 if a.verify:assert json.loads(gzip.decompress(dst.read_bytes()))==json.loads(raw)
 else:assert not dst.exists();dst.write_bytes(gzip.compress(raw,mtime=0))
 for t in first['trials']:
  r=t['release'];s=r['samples'][-1]['shell'];print(t['spawnStep'],t['targetName'],'release',r['releaseUpdate'],s['position'],s['command'],s['oInteractType'],s['oIntangibleTimer'],[(c['z'],c['mountEvents'],c['slideEvents'],c['samples'][0]['actionName'],c['samples'][0]['M'],c['samples'][0]['G'])for c in t['contacts']],flush=True)
 print('PASS',len(first['trials']),'remote releases twice')
if __name__=='__main__':main()
