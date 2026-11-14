"""Frozen shell lower-height checks; separate delayed riding from immediate-Z top entry."""
import argparse,copy,gzip,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
spec=importlib.util.spec_from_file_location('lower_bridge',ROOT/'instrumentation/ink-cloned-shell-bridge/search.py')
b=importlib.util.module_from_spec(spec);spec.loader.exec_module(b);iso=b.iso
HEIGHTS=[1741,1800,19839,19839.998046875,19840,19900,20000,21777]

def roots():
 g,o,slot,base,spawn=iso.roots();pick,held=iso.pickup(g,o,slot,base);states={};releases={}
 for h in HEIGHTS:
  rel,_=iso.release(g,o,slot,held,'throw',h);releases[h]=rel
  while g.read('gObjectPool[61].oTimer')<128:iso.advance(g,iso.NEUTRAL)
  for phase in [128,129,130]:
   assert g.read('gObjectPool[61].oTimer')==phase
   states['clone',h,phase]=g.save_state();iso.advance(g,iso.NEUTRAL)
 return b.Guard(g,slot),o,states,dict(spawn=spawn,pickup=pick,releases=releases)

def old_sequence(w,o,states,remove_buddy=False):
 g=w.g;g.load_state(states['clone',19900,128]);e=[]
 recipe=next(t['history']['recipe']for t in json.loads((ROOT/'docs/notes/ink-item-native-slide-combinations-receipt.json').read_text())['selectedHistories']if t['batch']=='height'and t['history']['recipe']['seed']['pos'][1]==19900)
 recipe=copy.deepcopy(recipe)
 if remove_buddy:del recipe['buddy129']
 initial=b.snap(w,o);iso.mario(g,o,[-1920,19900,-1210],e)
 iso.write(g,o,'gMarioState.vel',[0,-16,20],e);iso.write(g,o,'gMarioState.faceAngle',[0,0,0],e)
 iso.position(g,o,w.slot,[-1920,19890,-1210],e)
 t=dict(recipe=recipe,removeBuddy=remove_buddy,initial=initial,edits=e,before=b.snap(w,o),cuts=[],samples=[],events=[],controls=[])
 for i in range(36):
  cuts=[]
  for key,slot in ([('box129',49),('buddy129',15)]if i==1 else[('box130',49)]if i==2 else[]):
   if key in recipe:
    for axis,value in zip('XYZ',recipe[key]):
     path=f'gObjectPool[{slot}].oPos'+axis
     cuts.append(dict(path=path,before=g.read(path),after=value));g.write(path,value)
  if cuts:t['cuts'].append(dict(update=i+1,edits=cuts))
  pad=iso.Z if i==0 else iso.NEUTRAL;iso.advance(g,pad)
  s=b.snap(w,o);t['samples'].append(s);t['events'].append(iso.frame_events(g));t['controls'].append(pad)
  assert not s.get('input',0)&0x82
  if s['area']!=1:break
 t['capture']=any(s.get('used')==64 and s.get('floorOwner')==s.get('platform')==61 for s in t['samples'])
 arrival=next((s for s in t['samples']if s['area']==2),None)
 t['useful']=arrival is not None and arrival['M']==[365.5927734375,5500,-1096.8026123046875]
 return t

def run():
 g,o,states,prep=roots();trials=[]
 for h in HEIGHTS:
  r=dict(height=h,shellMode='clone',phase=129,pusher='bobomb',z=[1])
  trials.append(b.trial(g,o,states,r))
 trials.append(b.trial(g,o,states,dict(height=19900,shellMode='clone',phase=130,pusher='bobomb',z=[0])))
 old=[old_sequence(g,o,states,x)for x in [False,True]]
 for t in trials:print(t['recipe'],[(s['actionName'],s['M'],s['ridden'])for s in t['samples'][:2]],'useful',t['useful'],flush=True)
 for t in old:print('OLD_SEQUENCE',t['removeBuddy'],[(s['actionName'],s['M'])for s in t['samples'][:4]],'useful',t['useful'],flush=True)
 return dict(preparation=prep,trials=trials,oldSequence=old)

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',type=Path);a=ap.parse_args()
 r=run();q=run();assert r==q
 assert not any(t['bridge'] or t['useful'] for t in r['trials'])
 for t in r['trials'][:8]:
  expected='ACT_RIDING_SHELL_FALL'if t['recipe']['height']in[19839,19839.998046875]else'ACT_BACKWARD_GROUND_KB'
  assert t['samples'][0]['actionName']==expected
 assert r['oldSequence'][0]['capture'] and r['oldSequence'][0]['useful']
 assert not r['oldSequence'][1]['capture'] and not r['oldSequence'][1]['useful']
 count=sum(len(t['samples'])for t in r['trials']+r['oldSequence'])
 result=dict(schema=1,proofStart='162617b708b2244beca85af58b76ad5794e598cd',runtimeSha256=iso.sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),heights=HEIGHTS,independentlyVerified=True,checkedBoundaries=count,results=r)
 if a.verify:assert json.loads(gzip.decompress(a.verify.read_bytes()))==json.loads(json.dumps(result))
 else:
  out=HERE/'results.json.gz';assert not out.exists();out.write_bytes(gzip.compress((json.dumps(result,separators=(',',':'))+'\n').encode(),mtime=0))
 print('PASS',count,flush=True)
if __name__=='__main__':main()
