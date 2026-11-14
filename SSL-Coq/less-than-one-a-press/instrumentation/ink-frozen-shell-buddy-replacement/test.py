"""Buddy replacement in the existing frozen-shell Y19900 conditional handoff.

Positions are supplied; native actor type/hitbox/action/status and all Mario
fields after the initial FREEFALL cut are unmodified. No item delivery claim.
"""
import argparse,copy,gzip,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
spec=importlib.util.spec_from_file_location('buddy_lower',ROOT/'instrumentation/ink-shell-lower-boundary/test.py')
lower=importlib.util.module_from_spec(spec);spec.loader.exec_module(lower)
b=lower.b;iso=b.iso
EXACT=[-2054.455810546875,1799.2869873046875,-1208.867919921875]
NEAR=[-2000,1799.2869873046875,-1210]
BOX129=[-1990.710693359375,1799.2869873046875,-1280.710693359375]
BOX130=[-2117.125244140625,1830.177978515625,-1128.1343994140625]

def roots(height=19900):
 g,o,slot,base,spawn=iso.roots();pick,held=iso.pickup(g,o,slot,base)
 release,_=iso.release(g,o,slot,held,'throw',height)
 while g.read('gObjectPool[61].oTimer')<128:iso.advance(g,iso.NEUTRAL)
 assert g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==128
 return b.Guard(g,slot),o,g.save_state(),dict(spawn=spawn,pickup=pick,release=release)

def snap(w,o):
 s=b.snap(w,o)
 s['actors']={str(i):iso.actor_snapshot(w,i)for i in [15,23,39,40,49,w.slot]}
 return s

def place(g,slot,p,e):
 assert slot in[15,23,39,40,49,71]
 for axis,value in zip('XYZ',p):
  path=f'gObjectPool[{slot}].oPos'+axis
  e.append(dict(path=path,before=g.read(path),after=value));g.write(path,value)

def trial(w,o,state,recipe):
 g=w.g;g.load_state(state);initial=snap(w,o);edits=[]
 iso.mario(g,o,[-1920,19900,-1210],edits)
 iso.write(g,o,'gMarioState.vel',[0,-16,20],edits)
 iso.write(g,o,'gMarioState.faceAngle',[0,0,0],edits)
 iso.position(g,o,w.slot,[-1920,19890,-1210],edits)
 t=dict(recipe=recipe,initial=initial,edits=edits,before=snap(w,o),cuts=[],samples=[],events=[],controls=[])
 for i in range(36):
  cut=[]
  if i==1:
   if recipe['box129']:place(g,49,BOX129,cut)
   if recipe['candidate']is not None:place(g,recipe['candidate'],recipe['position'],cut)
  if i==2:place(g,49,BOX130,cut)
  if cut:t['cuts'].append(dict(beforeUpdate=i+1,edits=cut))
  pad=iso.Z if i==0 else iso.NEUTRAL;iso.advance(g,pad)
  s=snap(w,o);t['samples'].append(s);t['events'].append(iso.frame_events(g));t['controls'].append(pad)
  assert not s.get('input',0)&0x82
  if s['area']!=1:break
 t['capture']=any(s.get('used')==64 and s.get('floorOwner')==s.get('platform')==61 for s in t['samples'])
 arrival=next((s for s in t['samples']if s['area']==2),None)
 t['useful']=arrival is not None and arrival['M']==[365.5927734375,5500,-1096.8026123046875]
 t['candidateRegistered']=recipe['candidate']is not None and recipe['candidate']in t['samples'][1]['collisions']
 t['firstAction129']=next((e for e in t['events'][1]if e['type']=='FLT_EXECUTE_ACTION'),None)
 captured=False;t['retainedObserved']=True
 for s in t['samples']:
  if s.get('used')==64 and s.get('platform')==61:captured=True
  if captured and s['area']==1 and s.get('platform')!=61:t['retainedObserved']=False
 return t

def recipes():
 yield dict(name='Buddy positive',candidate=15,position=EXACT,box129=True)
 yield dict(name='Buddy omitted',candidate=None,position=None,box129=True)
 for candidate in[39,40,23]:
  for label,position in[('exact',EXACT),('closer',NEAR)]:
   for box in[True,False]:yield dict(name=f'slot{candidate}-{label}-box{int(box)}',candidate=candidate,position=position,box129=box)
 for label,position in[('exact',EXACT),('closer',NEAR)]:
  yield dict(name='frozen-shell-'+label,candidate=71,position=position,box129=True)

def run():
 g,o,state,prep=roots();trials=[trial(g,o,state,r)for r in recipes()]
 for t in trials:
  s=t['samples'][1];print(t['recipe']['name'],'hit',t['candidateRegistered'],'collisions',s['collisions'],'entry',t['firstAction129']['pos'],'after',s['M'],s['actionName'],'capture',t['capture'],'useful',t['useful'],flush=True)
 assert trials[0]['useful']and trials[0]['retainedObserved']
 assert not trials[1]['capture']
 baseline=trials[1]['samples'][1]
 for t in trials[2:]:
  assert not t['capture']and not t['useful']
  if t['recipe']['candidate']in[23,39,40]:
   assert t['candidateRegistered']==('closer'in t['recipe']['name'])
   if t['recipe']['box129']:
    for key in ['M','C','G','action','floorY','floorOwner','platform']:
     assert t['samples'][1][key]==baseline[key]
    assert t['firstAction129']['pos']==trials[1]['firstAction129']['pos']
 return dict(preparation=prep,trials=trials)

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',type=Path);a=ap.parse_args()
 r=run();q=run();assert r==q
 result=dict(schema=1,proofStart='c1f31bff1365055745d08fdd2728ac501378c4df',runtimeSha256=iso.sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),independentlyVerified=True,checkedBoundaries=sum(len(t['samples'])for t in r['trials']),results=r)
 if a.verify:assert json.loads(gzip.decompress(a.verify.read_bytes()))==json.loads(json.dumps(result))
 else:
  out=HERE/'results.json.gz';assert not out.exists();out.write_bytes(gzip.compress((json.dumps(result,separators=(',',':'))+'\n').encode(),mtime=0))
 print('PASS',len(r['trials']),'histories',result['checkedBoundaries'],'boundaries',flush=True)
if __name__=='__main__':main()
